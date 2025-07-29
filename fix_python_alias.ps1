# Script to fix Python alias issues on Windows
# This script helps disable the Microsoft Store Python alias that causes problems

Write-Host "Python Alias Fix Tool" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will help you disable the Microsoft Store Python alias" -ForegroundColor Yellow
Write-Host "that prevents proper Python installation and usage." -ForegroundColor Yellow
Write-Host ""

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "[ERROR] This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please right-click on PowerShell and select 'Run as administrator'" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "[INFO] Checking for Python aliases..." -ForegroundColor Blue

# Check current Python aliases
$pythonAlias = Get-Alias -Name "python" -ErrorAction SilentlyContinue
$python3Alias = Get-Alias -Name "python3" -ErrorAction SilentlyContinue

if ($pythonAlias) {
    Write-Host "Found Python alias: $($pythonAlias.Name) -> $($pythonAlias.Definition)" -ForegroundColor Yellow
} else {
    Write-Host "No Python alias found." -ForegroundColor Green
}

if ($python3Alias) {
    Write-Host "Found Python3 alias: $($python3Alias.Name) -> $($python3Alias.Definition)" -ForegroundColor Yellow
} else {
    Write-Host "No Python3 alias found." -ForegroundColor Green
}

Write-Host ""
Write-Host "To fix the Python alias issue:" -ForegroundColor Cyan
Write-Host "1. Open Windows Settings" -ForegroundColor White
Write-Host "2. Go to Apps > Apps & features > App execution aliases" -ForegroundColor White
Write-Host "3. Find 'python.exe' and 'python3.exe'" -ForegroundColor White
Write-Host "4. Turn them OFF (toggle to disabled)" -ForegroundColor White
Write-Host "5. Restart your terminal/PowerShell" -ForegroundColor White
Write-Host ""

Write-Host "Alternative method (Registry):" -ForegroundColor Cyan
Write-Host "The script can also try to disable aliases via registry (requires admin):" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Do you want to try the registry method? (y/n)"
if ($choice -eq "y" -or $choice -eq "Y") {
    Write-Host "[INFO] Attempting to disable Python aliases via registry..." -ForegroundColor Blue
    
    try {
        # Disable python.exe alias
        $pythonPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-ItemProperty -Path $pythonPath -Name "python.exe" -Value 0 -ErrorAction SilentlyContinue
        
        # Disable python3.exe alias
        Set-ItemProperty -Path $pythonPath -Name "python3.exe" -Value 0 -ErrorAction SilentlyContinue
        
        Write-Host "[SUCCESS] Registry changes applied!" -ForegroundColor Green
        Write-Host "Please restart your terminal/PowerShell for changes to take effect." -ForegroundColor Yellow
    } catch {
        Write-Host "[WARNING] Could not modify registry. Use the manual method above." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "After disabling the aliases:" -ForegroundColor Cyan
Write-Host "1. Install Python from https://python.org/downloads/" -ForegroundColor White
Write-Host "2. Make sure to check 'Add Python to PATH' during installation" -ForegroundColor White
Write-Host "3. Restart your computer" -ForegroundColor White
Write-Host "4. Run the installer again: .\install_windows.ps1" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to exit" 