@echo off
setlocal enabledelayedexpansion

REM GPT Neo-Style Text Co-Writer - Windows Installation Script (VS Code Compatible)
REM This script automatically installs all dependencies for the text co-writer

echo.
echo GPT Neo-Style Text Co-Writer - Windows Installation
echo ==================================================
echo.

REM Check if running on Windows
if not "%OS%"=="Windows_NT" (
    echo [ERROR] This script is for Windows only. Use install_mac.sh for macOS.
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

REM Create a configuration file
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

REM Create a quick start script
echo [INFO] Creating quick start script...
(
echo @echo off
echo echo Starting GPT Neo-Style Text Co-Writer...
echo echo Make sure Ollama is running: ollama serve
echo echo.
echo python text_co_writer.py
echo pause
) > start_writer.bat

echo [SUCCESS] Quick start script created: start_writer.bat

REM Create a README file
echo [INFO] Creating README file...
(
echo # GPT Neo-Style Text Co-Writer
echo.
echo A powerful AI text co-writing tool with support for multiple models, writer characters, custom elements, and reference materials.
echo.
echo ## Features
echo.
echo - **Multiple AI Models**: OpenAI, Ollama ^(local^), and Hugging Face
echo - **Writer Characters**: 5 pre-defined fictional writer personalities
echo - **Custom Elements**: Sci-fi world-building elements
echo - **Writing Styles**: Sci-fi, academic, poetry, journalistic, and more
echo - **Reference Materials**: Support for PDF, DOCX, and TXT files ^(style inspiration only^)
echo - **Narrative Continuation**: Continues your story in the same direction
echo - **Continuous Operation**: Keep writing without restarting
echo - **Numbered Selection**: Easy model and character selection by number
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
echo    start_writer.bat
echo    ```
echo    or manually:
echo    ```cmd
echo    python text_co_writer.py
echo    ```
echo.
echo ## Available Models
echo.
echo ### Local Models ^(Free^)
echo - **neural-chat**: Fast, good for quick responses
echo - **mistral**: Balanced performance and quality
echo - **llama2**: High quality, larger model
echo.
echo ### Cloud Models ^(Require API Keys^)
echo - **gpt-3.5-turbo-instruct**: OpenAI's model
echo - **gpt-4**: OpenAI's latest model
echo.
echo ## Writer Characters
echo.
echo 1. **Cyra the Posthumanist**: Radical thinker who dissolves boundaries between species, machines, and matter
echo 2. **Lia the Affective Nomad**: Restless and fluid, believes identity is a constant becoming
echo 3. **Dr. Orin**: Philosopher-scientist who sees phenomena as entangled events
echo 4. **Fynn**: Analytical yet whimsical observer who maps relationships between humans, nonhumans, and objects
echo 5. **ArwenDreamer**: Visionary who thrives in hybrid worlds of machines, animals, and spirits
echo.
echo ## Custom Elements
echo.
echo Include sci-fi elements like:
echo - hybrid_plants, mechanical_bees, glacial_memory
echo - permafrost_seeds, siren_sounds, quantum_ecology
echo - neural_networks, time_crystals, atmospheric_poetry
echo.
echo ## Reference Materials
echo.
echo Add your own reference materials to the `reference_materials\` folder:
echo - **PDF files** ^(.pdf^) - Research papers, books, articles
echo - **Word documents** ^(.docx, .doc^) - Manuscripts, notes
echo - **Text files** ^(.txt^) - Any plain text content
echo.
echo The AI will use these as **style inspiration only** - it won't copy content but will adopt the writing style and approach.
echo.
echo ## Commands
echo.
echo - `quit`: Exit the program
echo - `new style`: Change writing style and elements
echo - `new character`: Change writer character ^(numbered selection available^)
echo - `new model`: Switch to different AI model ^(numbered selection available^)
echo - `reload refs`: Reload reference materials
echo.
echo ## Troubleshooting
echo.
echo 1. **Ollama not running**: `ollama serve`
echo 2. **Model not found**: `ollama pull model-name`
echo 3. **API errors**: Check your API keys in config.py
echo 4. **Reference materials not loading**: Check file formats ^(PDF, DOCX, TXT only^)
echo 5. **AI copying reference content**: Reference materials are for style inspiration only
echo.
echo ## Requirements
echo.
echo - Windows 10 or later
echo - Python 3.7+
echo - Ollama ^(for local models^)
echo - Internet connection ^(for cloud models^)
echo.
echo ## Dependencies
echo.
echo - **openai**: OpenAI API client
echo - **requests**: HTTP library
echo - **PyPDF2**: PDF text extraction
echo - **python-docx**: Word document text extraction
) > README.md

echo [SUCCESS] README.md created!

REM Create start script for Windows
echo [INFO] Creating start script...
(
echo @echo off
echo echo Starting GPT Neo-Style Text Co-Writer...
echo echo.
echo.
echo REM Check if Python is available
echo python --version ^>nul 2^>^&1
echo if %%errorlevel%% neq 0 ^(
echo     echo [ERROR] Python not found!
echo     echo Please install Python from https://python.org
echo     echo Make sure to check 'Add Python to PATH' during installation
echo     pause
echo     exit /b 1
echo ^)
echo.
echo REM Check if the main script exists
echo if not exist "text_co_writer.py" ^(
echo     echo [ERROR] text_co_writer.py not found!
echo     echo Please run this script from the project directory.
echo     pause
echo     exit /b 1
echo ^)
echo.
echo REM Run the text co-writer
echo echo [INFO] Starting the text co-writer...
echo python text_co_writer.py
echo.
echo REM If the script exits, pause so user can see any error messages
echo if %%errorlevel%% neq 0 ^(
echo     echo.
echo     echo [ERROR] The program exited with an error.
echo     echo Check the error message above for details.
echo     pause
echo ^) else ^(
echo     echo.
echo     echo [INFO] Program finished successfully.
echo     pause
echo ^)
) > start_writer.bat
echo [SUCCESS] start_writer.bat created!

REM Create troubleshooting guide
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
echo 1. Right-click on `install_windows_fixed.bat`
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
echo ### 4. VS Code Terminal Issues
echo.
echo **Problem:** Script stops at first echo
echo.
echo **Solutions:**
echo 1. **Use Command Prompt instead of PowerShell:**
echo    - Press `Win + R`
echo    - Type `cmd`
echo    - Navigate to project folder
echo    - Run `install_windows_fixed.bat`
echo.
echo 2. **Run as Administrator in VS Code:**
echo    - Right-click VS Code
echo    - Select "Run as administrator"
echo.
echo ## Getting Help
echo.
echo If you're still having issues:
echo.
echo 1. **Check the error message carefully**
echo 2. **Try running as Administrator**
echo 3. **Restart your computer** after installations
echo 4. **Check Windows Event Viewer** for system errors
echo 5. **Update Windows** to the latest version
) > WINDOWS_TROUBLESHOOTING.md
echo [SUCCESS] WINDOWS_TROUBLESHOOTING.md created!

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
echo 3. Run the writer: start_writer.bat ^(or python text_co_writer.py^)
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
echo If you encounter any issues, check WINDOWS_TROUBLESHOOTING.md
echo for common solutions and troubleshooting steps.
echo.
echo Installation completed successfully!