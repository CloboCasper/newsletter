param([string]$Message = "Update content")

Write-Host "Synkroniserer med GitHub..." -ForegroundColor Cyan
git add .
$status = git status --porcelain
if (-not $status) {
    Write-Host "Ingen aendringer" -ForegroundColor Green
    exit 0
}
git commit -m $Message
if ($LASTEXITCODE -eq 0) {
    Write-Host "Committed" -ForegroundColor Green
    git push origin main
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Pushed til GitHub!" -ForegroundColor Green
    }
}
