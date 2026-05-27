<#
  sync_content.ps1
  Watch content_*.json in the current folder and copy changes to ./public

  Run: Open PowerShell in the `newsletter` folder and run:
    powershell -ExecutionPolicy Bypass -File .\sync_content.ps1

  Or run interactively: .\sync_content.ps1
#>

$source = Split-Path -Parent $MyInvocation.MyCommand.Path
$public = Join-Path $source 'public'

if (-not (Test-Path $public)) {
  New-Item -ItemType Directory -Path $public | Out-Null
}

Write-Host "Watching content_*.json in $source -> syncing to $public`n" -ForegroundColor Cyan

$copyAction = {
  param($path)
  try {
    Copy-Item -Path $path -Destination $using:public -Force -ErrorAction Stop
    Write-Host "Copied: $(Split-Path $path -Leaf) -> public" -ForegroundColor Green
  } catch {
    Write-Host "Copy failed: $_" -ForegroundColor Red
  }
}

$deleteAction = {
  param($path)
  $dest = Join-Path $using:public (Split-Path $path -Leaf)
  if (Test-Path $dest) {
    Remove-Item $dest -Force
    Write-Host "Deleted from public: $(Split-Path $path -Leaf)" -ForegroundColor Yellow
  }
}

$fsw = New-Object System.IO.FileSystemWatcher $source, 'content_*.json'
$fsw.IncludeSubdirectories = $false
$fsw.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite'

Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action {
  $p = $Event.SourceEventArgs.FullPath; Start-Sleep -Milliseconds 50; & $copyAction $p
}

Register-ObjectEvent $fsw Changed -SourceIdentifier FileChanged -Action {
  $p = $Event.SourceEventArgs.FullPath; Start-Sleep -Milliseconds 50; & $copyAction $p
}

Register-ObjectEvent $fsw Renamed -SourceIdentifier FileRenamed -Action {
  $p = $Event.SourceEventArgs.FullPath; Start-Sleep -Milliseconds 50; & $copyAction $p
}

Register-ObjectEvent $fsw Deleted -SourceIdentifier FileDeleted -Action {
  $p = $Event.SourceEventArgs.FullPath; Start-Sleep -Milliseconds 50; & $deleteAction $p
}

# Initial sync
Get-ChildItem -Path $source -Filter 'content_*.json' -File | ForEach-Object { Copy-Item $_.FullName -Destination $public -Force }

Write-Host "Initial sync complete. Press Ctrl+C to stop watcher." -ForegroundColor Cyan

try {
  while ($true) { Start-Sleep -Seconds 1 }
} finally {
  Unregister-Event -SourceIdentifier FileCreated -ErrorAction SilentlyContinue
  Unregister-Event -SourceIdentifier FileChanged -ErrorAction SilentlyContinue
  Unregister-Event -SourceIdentifier FileRenamed -ErrorAction SilentlyContinue
  Unregister-Event -SourceIdentifier FileDeleted -ErrorAction SilentlyContinue
  $fsw.Dispose()
}
