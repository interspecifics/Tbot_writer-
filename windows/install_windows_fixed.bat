@echo off
setlocal enabledelayedexpansion

REM Ensure we operate from the repository root (parent of this script folder)
set "SCRIPT_DIR=%~dp0"
pushd "%SCRIPT_DIR%\.."

REM Create windows folder (for generated Windows artifacts)
if not exist "windows" mkdir windows

REM GPT Neo-Style Text Co-Writer - Windows Installation Script (VS Code Compatible)
REM This script automatically installs all dependencies for the text co-writer

echo.
echo GPT Neo-Style Text Co-Writer - Windows Installation
echo ==================================================
echo.

REM Check if running on Windows
if not "%OS%"=="Windows_NT" (
    echo [ERROR] This script is for Windows only. Use install_mac.sh for macOS.
    popd
    exit /b 1
)

REM Check if running as administrator (recommended)
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] This script is not running as administrator.
    echo Some installations might require admin privileges.
    echo Continuing anyway...
    echo.
)

REM Check if Python is installed
echo [INFO] Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Python not found. Attempting automatic installation...
    echo.
    
    REM Check if we can download files
    echo [INFO] Testing download capability...
    powershell -Command "Test-NetConnection -ComputerName python.org -Port 443" >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] No internet connection. Cannot download Python automatically.
        echo.
        echo ========================================
        echo MANUAL INSTALLATION REQUIRED:
        echo ========================================
        echo 1. Download Python from: https://python.org/downloads/
        echo 2. Run the installer as Administrator
        echo 3. IMPORTANT: Check "Add Python to PATH" during installation
        echo 4. IMPORTANT: Check "Install for all users" 
        echo 5. Complete the installation and restart your computer
        echo 6. Run this script again
        echo.
        echo Press any key to open Python download page...
        pause >nul
        start https://python.org/downloads/
        popd
        exit /b 1
    )
    
    REM Try winget first (Windows Package Manager - easiest method)
    echo [INFO] Trying winget installation (Windows Package Manager)...
    winget --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo [INFO] winget found. Installing Python via winget...
        winget install Python.Python.3.11 --accept-source-agreements --accept-package-agreements
        if %errorlevel% equ 0 (
            echo [SUCCESS] Python installed via winget!
            echo [INFO] Refreshing environment variables...
            call refreshenv >nul 2>&1
            python --version >nul 2>&1
            if %errorlevel% equ 0 (
                echo [SUCCESS] Python is now available!
                python --version
                goto :python_installed
            )
        ) else (
            echo [INFO] winget installation failed, trying direct download...
        )
    ) else (
        echo [INFO] winget not available, trying direct download...
    )
    
    REM Try to detect Windows architecture
    echo [INFO] Detecting system architecture...
    if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
        set "ARCH=amd64"
        echo [INFO] Detected 64-bit system
    ) else if "%PROCESSOR_ARCHITECTURE%"=="x86" (
        set "ARCH=win32"
        echo [INFO] Detected 32-bit system
    ) else (
        set "ARCH=amd64"
        echo [INFO] Assuming 64-bit system
    )
    
    REM Download Python installer
    echo [INFO] Downloading Python installer...
    set "PYTHON_VERSION=3.11.8"
    set "PYTHON_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-%ARCH%.exe"
    set "PYTHON_INSTALLER=python-installer.exe"
    
    echo [INFO] Downloading from: %PYTHON_URL%
    powershell -Command "try { Invoke-WebRequest -Uri '%PYTHON_URL%' -OutFile '%PYTHON_INSTALLER%' -UseBasicParsing; Write-Host 'Download successful' } catch { Write-Host 'Download failed: ' + $_.Exception.Message; exit 1 }"
    
    if not exist "%PYTHON_INSTALLER%" (
        echo [ERROR] Failed to download Python installer.
        echo.
        echo ========================================
        echo MANUAL INSTALLATION REQUIRED:
        echo ========================================
        echo 1. Download Python from: https://python.org/downloads/
        echo 2. Run the installer as Administrator
        echo 3. IMPORTANT: Check "Add Python to PATH" during installation
        echo 4. IMPORTANT: Check "Install for all users" 
        echo 5. Complete the installation and restart your computer
        echo 6. Run this script again
        echo.
        echo Press any key to open Python download page...
        pause >nul
        start https://python.org/downloads/
        popd
        exit /b 1
    )
    
    echo [SUCCESS] Python installer downloaded!
    echo [INFO] Installing Python...
    echo [INFO] This may take a few minutes...
    
    REM Install Python with silent mode and PATH addition
    "%PYTHON_INSTALLER%" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    
    REM Wait for installation
    echo [INFO] Waiting for installation to complete...
    timeout /t 30 /nobreak >nul
    
    REM Clean up installer
    if exist "%PYTHON_INSTALLER%" del "%PYTHON_INSTALLER%"
    
    REM Refresh environment variables
    echo [INFO] Refreshing environment variables...
    call refreshenv >nul 2>&1
    
    REM Test if Python is now available
    echo [INFO] Testing Python installation...
    python --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo [WARNING] Python installation might not be complete.
        echo Please restart your computer and run this script again.
        echo.
        echo ========================================
        echo MANUAL INSTALLATION REQUIRED:
        echo ========================================
        echo 1. Download Python from: https://python.org/downloads/
        echo 2. Run the installer as Administrator
        echo 3. IMPORTANT: Check "Add Python to PATH" during installation
        echo 4. IMPORTANT: Check "Install for all users" 
        echo 5. Complete the installation and restart your computer
        echo 6. Run this script again
        echo.
        echo Press any key to open Python download page...
        pause >nul
        start https://python.org/downloads/
        popd
        exit /b 1
    ) else (
        echo [SUCCESS] Python installed successfully!
        python --version
    )
) else (
    echo [SUCCESS] Python already installed!
    python --version
)
    
:python_installed

REM Check if pip is installed
echo [INFO] Checking pip installation...
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Installing pip...
    python -m ensurepip --upgrade
    echo [SUCCESS] Pip installed successfully!
) else (
    echo [SUCCESS] Pip already installed!
    pip --version
)

REM Install required Python packages
echo [INFO] Installing Python dependencies...
pip install openai requests PyPDF2 python-docx
if %errorlevel% neq 0 (
    echo [WARNING] Failed to install packages globally. Trying with --user flag...
    pip install --user openai requests PyPDF2 python-docx
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install packages.
        echo.
        echo ========================================
        echo TROUBLESHOOTING:
        echo ========================================
        echo 1. Check your internet connection
        echo 2. Try running as Administrator
        echo 3. Try updating pip: python -m pip install --upgrade pip
        echo 4. Try installing packages one by one:
        echo    pip install openai
        echo    pip install requests
        echo    pip install PyPDF2
        echo    pip install python-docx
        echo.
        echo Press any key to continue anyway...
        pause >nul
    ) else (
        echo [SUCCESS] Python dependencies installed with --user flag!
    )
) else (
    echo [SUCCESS] Python dependencies installed!
)

REM Check if curl is available
echo [INFO] Checking curl availability...
curl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] curl not found. Some features might not work properly.
    echo You can install curl from: https://curl.se/windows/
)

REM Check if Ollama is installed
echo [INFO] Checking Ollama installation...
ollama --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Ollama not found. Installing Ollama...
    
    REM Check if we can download files
    echo [INFO] Testing download capability...
    powershell -Command "Test-NetConnection -ComputerName github.com -Port 443" >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] No internet connection. Please check your connection and try again.
        popd
        exit /b 1
    )
    
    REM Download Ollama installer
    echo [INFO] Downloading Ollama installer...
    powershell -Command "try { Invoke-WebRequest -Uri 'https://github.com/ollama/ollama/releases/latest/download/ollama-windows-amd64.msi' -OutFile 'ollama-installer.msi' -UseBasicParsing } catch { Write-Host 'Download failed. Please download manually from: https://ollama.ai/download' }"
    
    REM Check if download was successful
    if not exist "ollama-installer.msi" (
        echo [ERROR] Failed to download Ollama installer.
        echo Please download manually from: https://ollama.ai/download
        echo After installing Ollama, run this script again.
        popd
        exit /b 1
    )
    
    REM Install Ollama
    echo [INFO] Installing Ollama...
    msiexec /i ollama-installer.msi /quiet /norestart
    
    REM Wait for installation
    echo [INFO] Waiting for installation to complete...
    timeout /t 15 /nobreak >nul
    
    REM Clean up installer
    if exist "ollama-installer.msi" del ollama-installer.msi
    
    REM Check if installation was successful
    ollama --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo [WARNING] Ollama installation might not be complete.
        echo Please restart your computer and try again.
        echo Or download manually from: https://ollama.ai/download
    ) else (
        echo [SUCCESS] Ollama installed successfully!
    )
) else (
    echo [SUCCESS] Ollama already installed!
    ollama --version
)

REM Start Ollama service
echo [INFO] Starting Ollama service...
start /B ollama serve

REM Wait for Ollama to start
echo [INFO] Waiting for Ollama to start...
timeout /t 10 /nobreak >nul

REM Check if Ollama is running
echo [INFO] Checking if Ollama is running...
if exist "curl.exe" (
    curl -s http://localhost:11434/api/tags >nul 2>&1
    if %errorlevel% neq 0 (
        echo [WARNING] Ollama service might not be running. Please start it manually:
        echo   ollama serve
    ) else (
        echo [SUCCESS] Ollama is running!
    )
) else (
    echo [WARNING] curl not available. Cannot verify Ollama status.
    echo Please check if Ollama is running manually.
)

REM Pull some useful models
echo [INFO] Downloading AI models (this may take a while)...
echo.

REM Pull neural-chat (smaller, faster model)
echo [INFO] Downloading neural-chat model (4.1GB)...
ollama pull neural-chat
if %errorlevel% neq 0 (
    echo [WARNING] Failed to download neural-chat model. You can try again later with: ollama pull neural-chat
)

REM Pull mistral (good balance of size and quality)
echo [INFO] Downloading mistral model (4.1GB)...
ollama pull mistral
if %errorlevel% neq 0 (
    echo [WARNING] Failed to download mistral model. You can try again later with: ollama pull mistral
)

REM Pull llama2 (larger, higher quality model)
echo [INFO] Downloading llama2 model (3.8GB)...
ollama pull llama2
if %errorlevel% neq 0 (
    echo [WARNING] Failed to download llama2 model. You can try again later with: ollama pull llama2
)

echo [SUCCESS] Model download process completed!

REM Create reference materials folder
echo [INFO] Creating reference materials folder...
if not exist "reference_materials" mkdir reference_materials
echo [SUCCESS] Reference materials folder created: reference_materials\

REM Create a sample reference file
echo [INFO] Creating sample reference material...
(
echo Sample Reference Material: New Materialist Ecological Fiction
echo.
echo This document serves as a reference for writing in the style of new materialist ecological fiction, a speculative genre where matter is vibrant, agency is distributed, and the boundaries between subject and object, nature and technology, human and nonhuman are entangled.
echo.
echo.
echo Key Themes
echo 	•	The entanglement of matter, thought, and perception
echo 	•	Multispecies and machinic agency
echo 	•	Intra-action as co-constitution of beings and systems ^(Barad^)
echo 	•	Posthuman subjectivities and hybrid identities
echo 	•	Vibrant materiality and ecological becoming
echo.
echo.
echo Writing Style
echo 	•	Philosophical language merged with sensorial detail
echo 	•	Poetic metaphors grounded in material reality
echo 	•	Scientific and ontological terms used evocatively ^(e.g., "intra-action," "assemblage," "affect"^)
echo 	•	Reflexive tone, often displacing the human perspective
echo 	•	Temporality as nonlinear, distributed across species and systems
echo.
echo.
echo Example Passage
echo.
echo The wet metal of the exosynthetic moss shivered as dawn filtered through the carbon-threaded clouds. Moisture condensed on its surface was not merely water—it was memory, encoded in molecular clusters that whispered the air's chemical lineage. The moss did not grow; it negotiated growth with the pH of the soil, with light vectors, with the tremor of nearby machines.
echo.
echo A network of sensor-roots, neither plant nor tool, pulsed beneath the skin of the biome, relaying affective signals between fungal filaments and nanofiber webs. There was no hierarchy here, no command chain—only recursive participation, a choreography of entanglement.
echo.
echo A drone passed, not as observer but as participant—its wings attuned to the low-frequency hum of the earth's metabolic rhythm. It dropped a mineral spore coded to respond to local affect thresholds, then disappeared into the fog of becoming.
echo.
echo In this world, intelligence was not centralized, but distributed across filaments, wings, minerals, and desire. The question was no longer what can we control, but how do we attune to that which we are already inside of.
) > reference_materials\sample_reference.txt

echo [SUCCESS] Sample reference material created!

REM Create a configuration file (at repo root)
echo [INFO] Creating configuration file...
(
echo # Configuration file for GPT Neo-Style Text Co-Writer
echo # You can modify these settings as needed
echo.
echo # API Keys ^(add your keys here^)
echo OPENAI_API_KEY = ""  # Get from https://platform.openai.com/api-keys
echo HUGGINGFACE_API_KEY = ""  # Get from https://huggingface.co/settings/tokens
echo.
echo # Ollama Configuration
echo OLLAMA_BASE_URL = "http://localhost:11434"
echo.
echo # Default settings
echo DEFAULT_MODEL = "neural-chat"  # Options: neural-chat, mistral, llama2, gpt-3.5-turbo-instruct
echo DEFAULT_STYLE = "sci-fi"
echo DEFAULT_CHARACTER = "cyra"
echo.
echo # Model preferences ^(uncomment to set defaults^)
echo # PREFERRED_MODELS = ["neural-chat", "mistral", "llama2"]  # Order of preference for local models
) > config.py

echo [SUCCESS] Configuration file created: config.py

REM Create a quick start script (in windows folder)
echo [INFO] Creating quick start script...
(
echo @echo off
echo setlocal
echo set "SCRIPT_DIR=%%~dp0"
echo pushd "%%SCRIPT_DIR%%\.."
echo echo Starting GPT Neo-Style Text Co-Writer...
echo echo Make sure Ollama is running: ollama serve
echo echo.
echo python text_co_writer.py
echo set "code=%%errorlevel%%"
echo popd
echo if %%code%% neq 0 ^(
echo   echo.
echo   echo [ERROR] The program exited with an error.
echo ^) else ^(
echo   echo.
echo   echo [INFO] Program finished successfully.
echo ^)
echo pause
echo endlocal
) > windows\start_writer.bat

echo [SUCCESS] Quick start script created: windows\start_writer.bat

REM Create a Windows-specific README in the windows folder
echo [INFO] Creating Windows README file...
(
echo # Windows Usage - GPT Neo-Style Text Co-Writer
echo.
echo ## Quick Start
echo.
echo 1. **Start the service** ^(if not already running^):
echo    ```cmd
echo    ollama serve
echo    ```
echo.
echo 2. **Run the writer**:
echo    ```cmd
echo    windows\start_writer.bat
echo    ```
echo    or:
echo    ```powershell
echo    .\windows\start_writer.ps1
echo    ```
) > windows\README_WINDOWS.md

echo [SUCCESS] windows\README_WINDOWS.md created!

REM Create troubleshooting guide (in windows folder)
echo [INFO] Creating troubleshooting guide...
(
echo # Windows Troubleshooting Guide
echo.
echo ## Common Issues and Solutions
echo.
echo ### 1. Python Not Found
echo.
echo **Error:** `[ERROR] Python not found!`
echo.
echo **Solution:**
echo 1. Download Python from https://python.org/downloads/
echo 2. **IMPORTANT:** Check "Add Python to PATH" during installation
echo 3. **IMPORTANT:** Check "Install for all users"
echo 4. Restart your computer
echo 5. Run the installer again
echo.
echo **Alternative:** Install from Microsoft Store
echo 1. Open Microsoft Store
echo 2. Search for "Python 3.11" or "Python 3.12"
echo 3. Install the latest version
echo.
echo ### 2. Permission Errors
echo.
echo **Error:** `Permission denied` or `Access denied`
echo.
echo **Solution:**
echo 1. Right-click on `windows\install_windows_fixed.bat`
echo 2. Select "Run as administrator"
echo 3. Click "Yes" when prompted
echo.
echo ### 3. Package Installation Fails
echo.
echo **Error:** `Failed to install packages`
echo.
echo **Solutions:**
echo 1. **Update pip first:**
echo    ```cmd
echo    python -m pip install --upgrade pip
echo    ```
echo.
echo 2. **Install packages one by one:**
echo    ```cmd
echo    pip install openai
echo    pip install requests
echo    pip install PyPDF2
echo    pip install python-docx
echo    ```
echo.
echo 3. **Try with --user flag:**
echo    ```cmd
echo    pip install --user openai requests PyPDF2 python-docx
echo    ```
echo.
echo 4. **Check internet connection**
echo.
echo ## Getting Help
echo.
echo If you're still having issues:
echo.
echo 1. **Check the error message carefully**
echo 2. **Try running as Administrator**
echo 3. **Restart your computer** after installations
echo 4. **Update Windows** to the latest version
) > windows\WINDOWS_TROUBLESHOOTING.md

echo [SUCCESS] windows\WINDOWS_TROUBLESHOOTING.md created!

REM Final instructions
echo.
echo Installation Complete!
echo ========================
echo.
echo [SUCCESS] Your GPT Neo-Style Text Co-Writer is ready to use!
echo.
echo Next steps:
echo 1. Edit config.py to add your API keys ^(optional^)
echo 2. Start Ollama: ollama serve
echo 3. Run the writer: windows\start_writer.bat ^(or ^".\windows\start_writer.ps1^" in PowerShell^)
echo 4. Add reference materials to the reference_materials\ folder
echo.
echo Available models:
ollama list
echo.
echo [SUCCESS] Happy writing!
echo.
echo Reference materials folder created: reference_materials\
echo Add your PDF, DOCX, or TXT files there for style inspiration!
echo.
echo If you encounter any issues, check windows\WINDOWS_TROUBLESHOOTING.md
echo for common solutions and troubleshooting steps.
echo.
echo Installation completed successfully!

popd
endlocal


