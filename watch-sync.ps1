param(
    [string]$Branch = "main",
    [int]$DebounceMs = 2000
)

$extensions = @('.json', '.html')
$changedPaths = [System.Collections.Generic.HashSet[string]]::new()
$lock = New-Object Object

$timer = New-Object System.Timers.Timer $DebounceMs
$timer.AutoReset = $false
$timer.Enabled = $false
$timer.Add_Elapsed({
    $paths = @()
    lock ($lock) {
        $paths = $changedPaths.ToArray()
        $changedPaths.Clear()
    }

    if ($paths.Count -eq 0) {
        return
    }

    Write-Host "Detected changes in file(s):" -NoNewline
    Write-Host " $($paths -join ', ')" -ForegroundColor Cyan

    git add -- $paths
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to stage changes." -ForegroundColor Red
        return
    }

    $message = "Auto-sync changes $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    git commit -m $message
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Committed: $message" -ForegroundColor Green
        git push origin $Branch
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Pushed changes to origin/$Branch" -ForegroundColor Green
        } else {
            Write-Host "Push failed." -ForegroundColor Red
        }
    } else {
        Write-Host "Nothing new to commit." -ForegroundColor Yellow
    }
})

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = (Get-Location).Path
$watcher.IncludeSubdirectories = $true
$watcher.Filter = '*.*'
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::FileName

Register-ObjectEvent -InputObject $watcher -EventName Changed -SourceIdentifier WatcherChanged -Action {
    $path = $Event.SourceEventArgs.FullPath
    $extension = [System.IO.Path]::GetExtension($path).ToLower()
    if ($extensions -contains $extension -and -not $path.EndsWith('.tmp')) {
        lock ($lock) {
            $changedPaths.Add($path) | Out-Null
        }
        $timer.Stop()
        $timer.Start()
    }
}

Register-ObjectEvent -InputObject $watcher -EventName Created -SourceIdentifier WatcherCreated -Action {
    $path = $Event.SourceEventArgs.FullPath
    $extension = [System.IO.Path]::GetExtension($path).ToLower()
    if ($extensions -contains $extension -and -not $path.EndsWith('.tmp')) {
        lock ($lock) {
            $changedPaths.Add($path) | Out-Null
        }
        $timer.Stop()
        $timer.Start()
    }
}

$watcher.EnableRaisingEvents = $true
Write-Host "Watching for .json and .html saves in $(Get-Location)." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop." -ForegroundColor Cyan

while ($true) {
    Start-Sleep -Seconds 1
}
