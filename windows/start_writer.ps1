# Ensure we run from the repo root (parent of this script folder)
$root = Split-Path $PSScriptRoot -Parent
Push-Location $root

if (-not (Get-Command "python" -ErrorAction SilentlyContinue)) {
  Write-Host "[ERROR] Python not found! Install from https://python.org and add to PATH" -ForegroundColor Red
  Pop-Location
  Read-Host "Press Enter to exit"
  exit 1
}

if (-not (Test-Path "text_co_writer.py")) {
  Write-Host "[ERROR] text_co_writer.py not found at repo root." -ForegroundColor Red
  Pop-Location
  Read-Host "Press Enter to exit"
  exit 1
}

Write-Host "[INFO] Starting the text co-writer..." -ForegroundColor Blue
python text_co_writer.py
$code = $LASTEXITCODE

Pop-Location
if ($code -eq 0) {
  Write-Host "`n[INFO] Program finished successfully." -ForegroundColor Green
} else {
  Write-Host "`n[ERROR] The program exited with an error." -ForegroundColor Red
}
Read-Host "Press Enter to exit"


