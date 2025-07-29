# PowerShell script to start the GPT Neo-Style Text Co-Writer

Write-Host "Starting GPT Neo-Style Text Co-Writer..." -ForegroundColor Cyan
Write-Host ""

# Check if Python is available
if (-not (Get-Command "python" -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Python not found!" -ForegroundColor Red
    Write-Host "Please install Python from https://python.org" -ForegroundColor Red
    Write-Host "Make sure to check 'Add Python to PATH' during installation" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if the main script exists
if (-not (Test-Path "text_co_writer.py")) {
    Write-Host "[ERROR] text_co_writer.py not found!" -ForegroundColor Red
    Write-Host "Please run this script from the project directory." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Run the text co-writer
Write-Host "[INFO] Starting the text co-writer..." -ForegroundColor Blue
try {
    python text_co_writer.py
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "[INFO] Program finished successfully." -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "[ERROR] The program exited with an error." -ForegroundColor Red
        Write-Host "Check the error message above for details." -ForegroundColor Red
    }
} catch {
    Write-Host ""
    Write-Host "[ERROR] Failed to start the program." -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Read-Host "Press Enter to exit" 