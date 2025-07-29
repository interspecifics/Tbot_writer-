# GPT Neo-Style Text Co-Writer - Windows Installation Script (PowerShell)
# This script automatically installs all dependencies for the text co-writer

Write-Host ""
Write-Host "GPT Neo-Style Text Co-Writer - Windows Installation" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Check if running on Windows
if ($env:OS -ne "Windows_NT") {
    Write-Host "[ERROR] This script is for Windows only. Use install_mac.sh for macOS." -ForegroundColor Red
    exit 1
}

# Check if running as administrator (recommended)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "[WARNING] This script is not running as administrator." -ForegroundColor Yellow
    Write-Host "Some installations might require admin privileges." -ForegroundColor Yellow
    Write-Host "Continuing anyway..." -ForegroundColor Yellow
    Write-Host ""
}

# Function to check if command exists and actually works
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Function to test if Python actually works
function Test-PythonWorking() {
    try {
        $result = python --version 2>&1
        if ($LASTEXITCODE -eq 0 -and $result -notlike "*no se encontr*" -and $result -notlike "*not found*") {
            return $true
        }
        return $false
    } catch {
        return $false
    }
}

# Check if Python is installed
Write-Host "[INFO] Checking Python installation..." -ForegroundColor Blue

# Check if there's a Python alias that's causing issues
$pythonAlias = Get-Alias -Name "python" -ErrorAction SilentlyContinue
if ($pythonAlias -and $pythonAlias.Definition -like "*Microsoft*") {
    Write-Host "[WARNING] Found Microsoft Store Python alias. This may cause issues." -ForegroundColor Yellow
    Write-Host "To disable this alias:" -ForegroundColor Yellow
    Write-Host "1. Open Windows Settings" -ForegroundColor White
    Write-Host "2. Go to Apps > Apps & features > App execution aliases" -ForegroundColor White
    Write-Host "3. Turn off 'python.exe' and 'python3.exe'" -ForegroundColor White
    Write-Host ""
}

if (Test-Command "python" -and (Test-PythonWorking)) {
    Write-Host "[SUCCESS] Python already installed!" -ForegroundColor Green
    python --version
} else {
    Write-Host "[INFO] Python not found. Attempting automatic installation..." -ForegroundColor Yellow
    Write-Host ""
    
    # Check internet connection
    Write-Host "[INFO] Testing download capability..." -ForegroundColor Blue
    try {
        Test-NetConnection -ComputerName python.org -Port 443 -InformationLevel Quiet | Out-Null
    } catch {
        Write-Host "[ERROR] No internet connection. Cannot download Python automatically." -ForegroundColor Red
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "MANUAL INSTALLATION REQUIRED:" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "1. Download Python from: https://python.org/downloads/" -ForegroundColor White
        Write-Host "2. Run the installer as Administrator" -ForegroundColor White
        Write-Host "3. IMPORTANT: Check 'Add Python to PATH' during installation" -ForegroundColor White
        Write-Host "4. IMPORTANT: Check 'Install for all users'" -ForegroundColor White
        Write-Host "5. Complete the installation and restart your computer" -ForegroundColor White
        Write-Host "6. Run this script again" -ForegroundColor White
        Write-Host ""
        Write-Host "Press any key to open Python download page..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Start-Process "https://python.org/downloads/"
        exit 1
    }
    
    # Try winget first (Windows Package Manager - easiest method)
    Write-Host "[INFO] Trying winget installation (Windows Package Manager)..." -ForegroundColor Blue
    if (Test-Command "winget") {
        Write-Host "[INFO] winget found. Installing Python via winget..." -ForegroundColor Blue
        try {
            winget install Python.Python.3.11 --accept-source-agreements --accept-package-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[SUCCESS] Python installed via winget!" -ForegroundColor Green
                Write-Host "[INFO] Refreshing environment variables..." -ForegroundColor Blue
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
                if (Test-Command "python") {
                    Write-Host "[SUCCESS] Python is now available!" -ForegroundColor Green
                    python --version
                } else {
                    Write-Host "[WARNING] Python installation might not be complete." -ForegroundColor Yellow
                    Write-Host "Please restart your computer and run this script again." -ForegroundColor Yellow
                    exit 1
                }
            } else {
                Write-Host "[INFO] winget installation failed, trying direct download..." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "[INFO] winget installation failed, trying direct download..." -ForegroundColor Yellow
        }
    } else {
        Write-Host "[INFO] winget not available, trying direct download..." -ForegroundColor Yellow
    }
    
    # Try direct download if winget failed
    if (-not (Test-Command "python")) {
        Write-Host "[INFO] Downloading Python installer..." -ForegroundColor Blue
        
        # Detect architecture
        if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
            $arch = "amd64"
            Write-Host "[INFO] Detected 64-bit system" -ForegroundColor Blue
        } elseif ($env:PROCESSOR_ARCHITECTURE -eq "x86") {
            $arch = "win32"
            Write-Host "[INFO] Detected 32-bit system" -ForegroundColor Blue
        } else {
            $arch = "amd64"
            Write-Host "[INFO] Assuming 64-bit system" -ForegroundColor Blue
        }
        
        $pythonVersion = "3.11.8"
        $pythonUrl = "https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion-$arch.exe"
        $pythonInstaller = "python-installer.exe"
        
        Write-Host "[INFO] Downloading from: $pythonUrl" -ForegroundColor Blue
        try {
            Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller -UseBasicParsing
            Write-Host "[SUCCESS] Python installer downloaded!" -ForegroundColor Green
            
            Write-Host "[INFO] Installing Python..." -ForegroundColor Blue
            Write-Host "[INFO] This may take a few minutes..." -ForegroundColor Blue
            
            # Install Python with silent mode and PATH addition
            Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1", "Include_test=0" -Wait
            
            # Wait for installation
            Write-Host "[INFO] Waiting for installation to complete..." -ForegroundColor Blue
            Start-Sleep -Seconds 30
            
            # Clean up installer
            if (Test-Path $pythonInstaller) {
                Remove-Item $pythonInstaller
            }
            
            # Refresh environment variables
            Write-Host "[INFO] Refreshing environment variables..." -ForegroundColor Blue
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            # Test if Python is now available
            Write-Host "[INFO] Testing Python installation..." -ForegroundColor Blue
            if (Test-Command "python") {
                Write-Host "[SUCCESS] Python installed successfully!" -ForegroundColor Green
                python --version
            } else {
                Write-Host "[WARNING] Python installation might not be complete." -ForegroundColor Yellow
                Write-Host "Please restart your computer and run this script again." -ForegroundColor Yellow
                Write-Host ""
                Write-Host "========================================" -ForegroundColor Cyan
                Write-Host "MANUAL INSTALLATION REQUIRED:" -ForegroundColor Cyan
                Write-Host "========================================" -ForegroundColor Cyan
                Write-Host "1. Download Python from: https://python.org/downloads/" -ForegroundColor White
                Write-Host "2. Run the installer as Administrator" -ForegroundColor White
                Write-Host "3. IMPORTANT: Check 'Add Python to PATH' during installation" -ForegroundColor White
                Write-Host "4. IMPORTANT: Check 'Install for all users'" -ForegroundColor White
                Write-Host "5. Complete the installation and restart your computer" -ForegroundColor White
                Write-Host "6. Run this script again" -ForegroundColor White
                Write-Host ""
                Write-Host "Press any key to open Python download page..." -ForegroundColor Yellow
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                Start-Process "https://python.org/downloads/"
                exit 1
            }
        } catch {
            Write-Host "[ERROR] Failed to download Python installer." -ForegroundColor Red
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host "MANUAL INSTALLATION REQUIRED:" -ForegroundColor Cyan
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host "1. Download Python from: https://python.org/downloads/" -ForegroundColor White
            Write-Host "2. Run the installer as Administrator" -ForegroundColor White
            Write-Host "3. IMPORTANT: Check 'Add Python to PATH' during installation" -ForegroundColor White
            Write-Host "4. IMPORTANT: Check 'Install for all users'" -ForegroundColor White
            Write-Host "5. Complete the installation and restart your computer" -ForegroundColor White
            Write-Host "6. Run this script again" -ForegroundColor White
            Write-Host ""
            Write-Host "Press any key to open Python download page..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Start-Process "https://python.org/downloads/"
            exit 1
        }
    }
}

# Function to test if pip actually works
function Test-PipWorking() {
    try {
        $result = pip --version 2>&1
        if ($LASTEXITCODE -eq 0 -and $result -notlike "*no se encontr*" -and $result -notlike "*not found*") {
            return $true
        }
        return $false
    } catch {
        return $false
    }
}

# Check if pip is installed
Write-Host "[INFO] Checking pip installation..." -ForegroundColor Blue
if (Test-Command "pip" -and (Test-PipWorking)) {
    Write-Host "[SUCCESS] Pip already installed!" -ForegroundColor Green
    pip --version
} else {
    Write-Host "[INFO] Installing pip..." -ForegroundColor Blue
    try {
        python -m ensurepip --upgrade
        Write-Host "[SUCCESS] Pip installed successfully!" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to install pip. Python may not be properly installed." -ForegroundColor Red
        Write-Host "Please install Python manually from https://python.org/downloads/" -ForegroundColor Red
        exit 1
    }
}

# Install required Python packages
Write-Host "[INFO] Installing Python dependencies..." -ForegroundColor Blue
try {
    pip install openai requests PyPDF2 python-docx
    Write-Host "[SUCCESS] Python dependencies installed!" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Failed to install packages globally. Trying with --user flag..." -ForegroundColor Yellow
    try {
        pip install --user openai requests PyPDF2 python-docx
        Write-Host "[SUCCESS] Python dependencies installed with --user flag!" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to install packages." -ForegroundColor Red
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "TROUBLESHOOTING:" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "1. Check your internet connection" -ForegroundColor White
        Write-Host "2. Try running as Administrator" -ForegroundColor White
        Write-Host "3. Try updating pip: python -m pip install --upgrade pip" -ForegroundColor White
        Write-Host "4. Try installing packages one by one:" -ForegroundColor White
        Write-Host "   pip install openai" -ForegroundColor White
        Write-Host "   pip install requests" -ForegroundColor White
        Write-Host "   pip install PyPDF2" -ForegroundColor White
        Write-Host "   pip install python-docx" -ForegroundColor White
        Write-Host ""
        Write-Host "Press any key to continue anyway..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

# Check if curl is available
Write-Host "[INFO] Checking curl availability..." -ForegroundColor Blue
if (Test-Command "curl") {
    Write-Host "[SUCCESS] curl found!" -ForegroundColor Green
} else {
    Write-Host "[WARNING] curl not found. Some features might not work properly." -ForegroundColor Yellow
    Write-Host "You can install curl from: https://curl.se/windows/" -ForegroundColor Yellow
}

# Check if Ollama is installed
Write-Host "[INFO] Checking Ollama installation..." -ForegroundColor Blue
if (Test-Command "ollama") {
    Write-Host "[SUCCESS] Ollama already installed!" -ForegroundColor Green
    ollama --version
} else {
    Write-Host "[INFO] Ollama not found. Installing Ollama..." -ForegroundColor Blue
    
    # Check if we can download files
    Write-Host "[INFO] Testing download capability..." -ForegroundColor Blue
    try {
        Test-NetConnection -ComputerName github.com -Port 443 -InformationLevel Quiet | Out-Null
    } catch {
        Write-Host "[ERROR] No internet connection. Please check your connection and try again." -ForegroundColor Red
        exit 1
    }
    
    # Try multiple download methods for Ollama
    Write-Host "[INFO] Downloading Ollama installer..." -ForegroundColor Blue
    $ollamaDownloaded = $false
    
    # Method 1: Direct download from GitHub
    try {
        Write-Host "[INFO] Trying direct download from GitHub..." -ForegroundColor Blue
        Invoke-WebRequest -Uri "https://github.com/ollama/ollama/releases/latest/download/ollama-windows-amd64.msi" -OutFile "ollama-installer.msi" -UseBasicParsing -TimeoutSec 30
        if (Test-Path "ollama-installer.msi") {
            $ollamaDownloaded = $true
            Write-Host "[SUCCESS] Ollama installer downloaded from GitHub!" -ForegroundColor Green
        }
    } catch {
        Write-Host "[WARNING] GitHub download failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Method 2: Try winget if direct download failed
    if (-not $ollamaDownloaded) {
        Write-Host "[INFO] Trying winget installation..." -ForegroundColor Blue
        if (Test-Command "winget") {
            try {
                winget install Ollama.Ollama --accept-source-agreements --accept-package-agreements
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "[SUCCESS] Ollama installed via winget!" -ForegroundColor Green
                    $ollamaDownloaded = $true
                } else {
                    Write-Host "[WARNING] winget installation failed" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "[WARNING] winget installation failed: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "[INFO] winget not available" -ForegroundColor Yellow
        }
    }
    
    # Method 3: Try alternative download URL
    if (-not $ollamaDownloaded) {
        try {
            Write-Host "[INFO] Trying alternative download method..." -ForegroundColor Blue
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile("https://github.com/ollama/ollama/releases/latest/download/ollama-windows-amd64.msi", "ollama-installer.msi")
            if (Test-Path "ollama-installer.msi") {
                $ollamaDownloaded = $true
                Write-Host "[SUCCESS] Ollama installer downloaded with alternative method!" -ForegroundColor Green
            }
        } catch {
            Write-Host "[WARNING] Alternative download failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    # If all download methods failed
    if (-not $ollamaDownloaded) {
        Write-Host "[ERROR] All download methods failed." -ForegroundColor Red
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "MANUAL OLLAMA INSTALLATION REQUIRED:" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "1. Download Ollama from: https://ollama.ai/download" -ForegroundColor White
        Write-Host "2. Run the installer as Administrator" -ForegroundColor White
        Write-Host "3. Restart your computer" -ForegroundColor White
        Write-Host "4. Run this script again" -ForegroundColor White
        Write-Host ""
        Write-Host "Common issues:" -ForegroundColor Yellow
        Write-Host "- Firewall blocking downloads" -ForegroundColor White
        Write-Host "- Corporate network restrictions" -ForegroundColor White
        Write-Host "- Antivirus blocking downloads" -ForegroundColor White
        Write-Host ""
        Write-Host "Press any key to open Ollama download page..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Start-Process "https://ollama.ai/download"
        exit 1
    }
    
    # Check if download was successful
    if (-not (Test-Path "ollama-installer.msi")) {
        Write-Host "[ERROR] Failed to download Ollama installer." -ForegroundColor Red
        Write-Host "Please download manually from: https://ollama.ai/download" -ForegroundColor Red
        Write-Host "After installing Ollama, run this script again." -ForegroundColor Red
        exit 1
    }
    
    # Install Ollama (only if we downloaded the installer)
    if (Test-Path "ollama-installer.msi") {
        Write-Host "[INFO] Installing Ollama..." -ForegroundColor Blue
        Start-Process -FilePath "msiexec" -ArgumentList "/i", "ollama-installer.msi", "/quiet", "/norestart" -Wait
        
        # Wait for installation
        Write-Host "[INFO] Waiting for installation to complete..." -ForegroundColor Blue
        Start-Sleep -Seconds 15
        
        # Clean up installer
        Remove-Item "ollama-installer.msi"
    }
    
    # Check if installation was successful
    if (Test-Command "ollama") {
        Write-Host "[SUCCESS] Ollama installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Ollama installation might not be complete." -ForegroundColor Yellow
        Write-Host "Please restart your computer and try again." -ForegroundColor Yellow
        Write-Host "Or download manually from: https://ollama.ai/download" -ForegroundColor Yellow
    }
}

# Start Ollama service
Write-Host "[INFO] Starting Ollama service..." -ForegroundColor Blue
try {
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden
    Write-Host "[SUCCESS] Ollama service started!" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Could not start Ollama service automatically." -ForegroundColor Yellow
    Write-Host "You may need to start it manually with: ollama serve" -ForegroundColor Yellow
}

# Pull default models
Write-Host "[INFO] Pulling default models..." -ForegroundColor Blue
$models = @("neural-chat", "mistral", "llama2")
foreach ($model in $models) {
    Write-Host "[INFO] Pulling $model..." -ForegroundColor Blue
    try {
        ollama pull $model
        Write-Host "[SUCCESS] $model pulled successfully!" -ForegroundColor Green
    } catch {
        Write-Host "[WARNING] Failed to pull $model. You can pull it manually later with: ollama pull $model" -ForegroundColor Yellow
    }
}

# Create reference materials folder
Write-Host "[INFO] Creating reference materials folder..." -ForegroundColor Blue
if (-not (Test-Path "reference_materials")) {
    New-Item -ItemType Directory -Path "reference_materials" | Out-Null
    Write-Host "[SUCCESS] Reference materials folder created!" -ForegroundColor Green
} else {
    Write-Host "[SUCCESS] Reference materials folder already exists!" -ForegroundColor Green
}

# Create a sample reference file
Write-Host "[INFO] Creating sample reference material..." -ForegroundColor Blue
$sampleContent = @"
Sample Reference Material: New Materialist Ecological Fiction

This document serves as a reference for writing in the style of new materialist ecological fiction, a speculative genre where matter is vibrant, agency is distributed, and the boundaries between subject and object, nature and technology, human and nonhuman are entangled.


Key Themes
	•	The entanglement of matter, thought, and perception
	•	Multispecies and machinic agency
	•	Intra-action as co-constitution of beings and systems (Barad)
	•	Posthuman subjectivities and hybrid identities
	•	Vibrant materiality and ecological becoming


Writing Style
	•	Philosophical language merged with sensorial detail
	•	Poetic metaphors grounded in material reality
	•	Scientific and ontological terms used evocatively (e.g., "intra-action," "assemblage," "affect")
	•	Reflexive tone, often displacing the human perspective
	•	Temporality as nonlinear, distributed across species and systems


Example Passage

The wet metal of the exosynthetic moss shivered as dawn filtered through the carbon-threaded clouds. Moisture condensed on its surface was not merely water—it was memory, encoded in molecular clusters that whispered the air's chemical lineage. The moss did not grow; it negotiated growth with the pH of the soil, with light vectors, with the tremor of nearby machines.

A network of sensor-roots, neither plant nor tool, pulsed beneath the skin of the biome, relaying affective signals between fungal filaments and nanofiber webs. There was no hierarchy here, no command chain—only recursive participation, a choreography of entanglement.

A drone passed, not as observer but as participant—its wings attuned to the low-frequency hum of the earth's metabolic rhythm. It dropped a mineral spore coded to respond to local affect thresholds, then disappeared into the fog of becoming.

In this world, intelligence was not centralized, but distributed across filaments, wings, minerals, and desire. The question was no longer what can we control, but how do we attune to that which we are already inside of.
"@

$sampleContent | Out-File -FilePath "reference_materials\sample_reference.txt" -Encoding UTF8
Write-Host "[SUCCESS] Sample reference material created!" -ForegroundColor Green

# Create a configuration file
Write-Host "[INFO] Creating configuration file..." -ForegroundColor Blue
$configContent = @"
# Configuration file for GPT Neo-Style Text Co-Writer
# You can modify these settings as needed

# API Keys (add your keys here)
OPENAI_API_KEY = ""  # Get from https://platform.openai.com/api-keys
HUGGINGFACE_API_KEY = ""  # Get from https://huggingface.co/settings/tokens

# Ollama Configuration
OLLAMA_BASE_URL = "http://localhost:11434"

# Default settings
DEFAULT_MODEL = "neural-chat"  # Options: neural-chat, mistral, llama2, gpt-3.5-turbo-instruct
DEFAULT_STYLE = "sci-fi"
DEFAULT_CHARACTER = "cyra"

# Model preferences (uncomment to set defaults)
# PREFERRED_MODELS = ["neural-chat", "mistral", "llama2"]  # Order of preference for local models
"@

$configContent | Out-File -FilePath "config.py" -Encoding UTF8
Write-Host "[SUCCESS] Configuration file created!" -ForegroundColor Green

# Create start script for Windows
Write-Host "[INFO] Creating start script..." -ForegroundColor Blue
$startScriptContent = @"
@echo off
echo Starting GPT Neo-Style Text Co-Writer...
echo.

REM Check if Python is available
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found!
    echo Please install Python from https://python.org
    echo Make sure to check 'Add Python to PATH' during installation
    pause
    exit /b 1
)

REM Check if the main script exists
if not exist "text_co_writer.py" (
    echo [ERROR] text_co_writer.py not found!
    echo Please run this script from the project directory.
    pause
    exit /b 1
)

REM Run the text co-writer
echo [INFO] Starting the text co-writer...
python text_co_writer.py

REM If the script exits, pause so user can see any error messages
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] The program exited with an error.
    echo Check the error message above for details.
    pause
) else (
    echo.
    echo [INFO] Program finished successfully.
    pause
)
"@

$startScriptContent | Out-File -FilePath "start_writer.bat" -Encoding ASCII
Write-Host "[SUCCESS] start_writer.bat created!" -ForegroundColor Green

# Create README
Write-Host "[INFO] Creating README..." -ForegroundColor Blue
$readmeContent = @"
# GPT Neo-Style Text Co-Writer

A sophisticated AI-powered text co-writing tool that continues your narratives with various AI models and writer characters.

## Quick Start

1. **Start Ollama** (if not already running):
   ```cmd
   ollama serve
   ```

2. **Run the writer**:
   ```cmd
   start_writer.bat
   ```
   or manually:
   ```cmd
   python text_co_writer.py
   ```

## Available Models

### Local Models (Free)
- **neural-chat**: Fast, good for quick responses
- **mistral**: Balanced performance and quality
- **llama2**: High quality, larger model

### Cloud Models (Require API Keys)
- **gpt-3.5-turbo-instruct**: OpenAI's model
- **gpt-4**: OpenAI's latest model

## Writer Characters

1. **Cyra the Posthumanist**: Radical thinker who dissolves boundaries between species, machines, and matter
2. **Lia the Affective Nomad**: Restless and fluid, believes identity is a constant becoming
3. **Dr. Orin**: Philosopher-scientist who sees phenomena as entangled events
4. **Fynn**: Analytical yet whimsical observer who maps relationships between humans, nonhumans, and objects
5. **ArwenDreamer**: Visionary who thrives in hybrid worlds of machines, animals, and spirits

## Custom Elements

Include sci-fi elements like:
- hybrid_plants, mechanical_bees, glacial_memory
- permafrost_seeds, siren_sounds, quantum_ecology
- neural_networks, time_crystals, atmospheric_poetry

## Reference Materials

Add your own reference materials to the `reference_materials\` folder:
- **PDF files** (.pdf) - Research papers, books, articles
- **Word documents** (.docx, .doc) - Manuscripts, notes
- **Text files** (.txt) - Any plain text content

The AI will use these as **style inspiration only** - it won't copy content but will adopt the writing style and approach.

## Commands

- `quit`: Exit the program
- `new style`: Change writing style and elements
- `new character`: Change writer character (numbered selection available)
- `new model`: Switch to different AI model (numbered selection available)
- `reload refs`: Reload reference materials

## Troubleshooting

1. **Ollama not running**: `ollama serve`
2. **Model not found**: `ollama pull model-name`
3. **API errors**: Check your API keys in config.py
4. **Reference materials not loading**: Check file formats (PDF, DOCX, TXT only)
5. **AI copying reference content**: Reference materials are for style inspiration only

## Requirements

- Windows 10 or later
- Python 3.7+
- Ollama (for local models)
- Internet connection (for cloud models)

## Dependencies

- **openai**: OpenAI API client
- **requests**: HTTP library
- **PyPDF2**: PDF text extraction
- **python-docx**: Word document text extraction
"@

$readmeContent | Out-File -FilePath "README.md" -Encoding UTF8
Write-Host "[SUCCESS] README.md created!" -ForegroundColor Green

# Final instructions
Write-Host ""
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host ""
Write-Host "[SUCCESS] Your GPT Neo-Style Text Co-Writer is ready to use!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Edit config.py to add your API keys (optional)" -ForegroundColor White
Write-Host "2. Start Ollama: ollama serve" -ForegroundColor White
Write-Host "3. Run the writer: start_writer.bat (or python text_co_writer.py)" -ForegroundColor White
Write-Host "4. Add reference materials to the reference_materials\ folder" -ForegroundColor White
Write-Host ""
Write-Host "Available models:" -ForegroundColor Cyan
ollama list
Write-Host ""
Write-Host "[SUCCESS] Happy writing!" -ForegroundColor Green
Write-Host ""
Write-Host "Reference materials folder created: reference_materials\" -ForegroundColor Cyan
Write-Host "Add your PDF, DOCX, or TXT files there for style inspiration!" -ForegroundColor White
Write-Host ""
Write-Host "If you encounter any issues, check WINDOWS_TROUBLESHOOTING.md" -ForegroundColor Yellow
Write-Host "for common solutions and troubleshooting steps." -ForegroundColor Yellow
Write-Host ""
Write-Host "Installation completed successfully!" -ForegroundColor Green 