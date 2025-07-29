# Manual Ollama Installation Helper
# This script helps users install Ollama when automatic installation fails

Write-Host "Manual Ollama Installation Helper" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will help you install Ollama manually when automatic installation fails." -ForegroundColor Yellow
Write-Host ""

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "[ERROR] This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please right-click on PowerShell and select 'Run as administrator'" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "[INFO] Checking current Ollama installation..." -ForegroundColor Blue
if (Get-Command "ollama" -ErrorAction SilentlyContinue) {
    Write-Host "[SUCCESS] Ollama is already installed!" -ForegroundColor Green
    ollama --version
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host "[INFO] Ollama not found. Starting manual installation process..." -ForegroundColor Blue
Write-Host ""

# Method 1: Try winget
Write-Host "Method 1: Installing via Windows Package Manager (winget)" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

if (Get-Command "winget" -ErrorAction SilentlyContinue) {
    Write-Host "[INFO] winget found. Attempting installation..." -ForegroundColor Blue
    try {
        winget install Ollama.Ollama --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[SUCCESS] Ollama installed via winget!" -ForegroundColor Green
            Write-Host "[INFO] Refreshing environment variables..." -ForegroundColor Blue
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            if (Get-Command "ollama" -ErrorAction SilentlyContinue) {
                Write-Host "[SUCCESS] Ollama is now available!" -ForegroundColor Green
                ollama --version
                Read-Host "Press Enter to exit"
                exit 0
            }
        } else {
            Write-Host "[WARNING] winget installation failed" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[WARNING] winget installation failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
} else {
    Write-Host "[INFO] winget not available" -ForegroundColor Yellow
}

Write-Host ""

# Method 2: Manual download
Write-Host "Method 2: Manual Download and Installation" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

Write-Host "Since automatic installation failed, you'll need to download Ollama manually:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Open your web browser" -ForegroundColor White
Write-Host "2. Go to: https://ollama.ai/download" -ForegroundColor White
Write-Host "3. Click 'Download for Windows'" -ForegroundColor White
Write-Host "4. Run the downloaded .msi file as Administrator" -ForegroundColor White
Write-Host "5. Follow the installation wizard" -ForegroundColor White
Write-Host "6. Restart your computer" -ForegroundColor White
Write-Host "7. Run this script again to verify installation" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Do you want to open the Ollama download page now? (y/n)"
if ($choice -eq "y" -or $choice -eq "Y") {
    Write-Host "[INFO] Opening Ollama download page..." -ForegroundColor Blue
    Start-Process "https://ollama.ai/download"
}

Write-Host ""
Write-Host "Alternative download methods:" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host ""

Write-Host "If the main download doesn't work, try these alternatives:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. GitHub Releases (direct link):" -ForegroundColor White
Write-Host "   https://github.com/ollama/ollama/releases/latest/download/ollama-windows-amd64.msi" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Try downloading from a different network:" -ForegroundColor White
Write-Host "   - Mobile hotspot" -ForegroundColor Gray
Write-Host "   - Different WiFi network" -ForegroundColor Gray
Write-Host "   - Use a VPN" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Check your firewall/antivirus:" -ForegroundColor White
Write-Host "   - Temporarily disable antivirus" -ForegroundColor Gray
Write-Host "   - Allow downloads in Windows Firewall" -ForegroundColor Gray
Write-Host ""

Write-Host "After installing Ollama:" -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Cyan
Write-Host "1. Restart your computer" -ForegroundColor White
Write-Host "2. Open PowerShell as Administrator" -ForegroundColor White
Write-Host "3. Navigate to your project folder" -ForegroundColor White
Write-Host "4. Run: .\install_windows.ps1" -ForegroundColor White
Write-Host "5. Or run: ollama serve" to start Ollama manually -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to exit" 