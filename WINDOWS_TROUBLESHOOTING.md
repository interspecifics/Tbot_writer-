# Windows Troubleshooting Guide

## Common Issues and Solutions

### 1. Python Not Found

**Error:** `[ERROR] Python not found!` or `no se encontró Python`

**Microsoft Store Alias Issue:**
If you see "no se encontró Python" or similar messages, Windows has a Python alias that points to the Microsoft Store but Python isn't actually installed.

**Solution:**
1. **Run the Python alias fix script:**
   ```powershell
   .\fix_python_alias.ps1
   ```
   (Run as Administrator)

2. **Or manually disable the Python alias:**
   - Open Windows Settings
   - Go to Apps > Apps & features > App execution aliases
   - Turn off 'python.exe' and 'python3.exe'
   - Restart your terminal/PowerShell

3. **Then install Python properly:**
   - Download from https://python.org/downloads/
   - **IMPORTANT:** Check "Add Python to PATH" during installation
   - **IMPORTANT:** Check "Install for all users"
   - Restart your computer

**Automatic Installation:**
The installer will now attempt to install Python automatically using:
1. **Windows Package Manager (winget)** - if available
2. **Direct download** from python.org
3. **Silent installation** with PATH configuration

**Manual Installation (if automatic fails):**
1. Download Python from https://python.org/downloads/
2. **IMPORTANT:** Check "Add Python to PATH" during installation
3. **IMPORTANT:** Check "Install for all users"
4. Restart your computer
5. Run the installer again

**Alternative:** Install from Microsoft Store
1. Open Microsoft Store
2. Search for "Python 3.11" or "Python 3.12"
3. Install the latest version

### 2. Permission Errors

**Error:** `Permission denied` or `Access denied`

**Solution:**
1. Right-click on `install_windows_fixed.bat`
2. Select "Run as administrator"
3. Click "Yes" when prompted

### 3. Package Installation Fails

**Error:** `Failed to install packages`

**Solutions:**
1. **Update pip first:**
   ```cmd
   python -m pip install --upgrade pip
   ```

2. **Install packages one by one:**
   ```cmd
   pip install openai
   pip install requests
   pip install PyPDF2
   pip install python-docx
   ```

3. **Try with --user flag:**
   ```cmd
   pip install --user openai requests PyPDF2 python-docx
   ```

4. **Check internet connection**

### 4. Ollama Installation Issues

**Error:** `Failed to download Ollama installer` or `Download failed`

**Solutions:**
1. **Run the manual installation helper:**
   ```powershell
   .\install_ollama_manual.ps1
   ```
   (Run as Administrator)

2. **Manual download:**
   - Go to https://ollama.ai/download
   - Download the Windows MSI installer
   - Run the installer manually

3. **Try winget installation:**
   ```cmd
   winget install Ollama.Ollama --accept-source-agreements --accept-package-agreements
   ```

4. **Check network restrictions:**
   - Temporarily disable antivirus
   - Check Windows Firewall settings
   - Try from a different network (not corporate)
   - Check if GitHub is blocked

5. **Alternative download methods:**
   - Use a different browser
   - Try downloading from a mobile hotspot
   - Use a VPN if available

### 5. Ollama Not Starting

**Error:** `ollama command not found`

**Solutions:**
1. **Restart your computer** after Ollama installation
2. **Start Ollama service:**
   ```cmd
   ollama serve
   ```

3. **Check if Ollama is in PATH:**
   - Search for "Environment Variables" in Windows
   - Check if Ollama path is in System PATH

### 6. Model Not Found

**Error:** `Model not found` when selecting a model

**Solution:**
1. **Pull the model:**
   ```cmd
   ollama pull neural-chat
   ollama pull mistral
   ollama pull llama2
   ```

2. **Check available models:**
   ```cmd
   ollama list
   ```

### 7. API Key Issues

**Error:** `OpenAI API key not configured`

**Solution:**
1. Edit `config.py`
2. Add your API keys:
   ```python
   OPENAI_API_KEY = "your-openai-api-key-here"
   HUGGINGFACE_API_KEY = "your-huggingface-api-key-here"
   ```

### 8. Reference Materials Not Loading

**Error:** `No reference materials found`

**Solutions:**
1. **Check file formats:** Only PDF, DOCX, and TXT files are supported
2. **Check file location:** Files must be in the `reference_materials\` folder
3. **Check file permissions:** Make sure files are readable

### 9. Script Not Found

**Error:** `'start_writer.sh' is not recognized`

**Solution:**
- Use `start_writer.bat` instead (Windows batch file)
- Or run directly: `python text_co_writer.py`

### 10. VS Code Terminal Issues

**Problem:** Script stops at first echo or syntax errors

**Solutions:**
1. **Use PowerShell installer (recommended):**
   ```powershell
   .\install_windows.ps1
   ```

2. **Use Command Prompt instead of PowerShell:**
   - Press `Win + R`
   - Type `cmd`
   - Navigate to project folder
   - Run `install_windows_fixed.bat`

3. **Run as Administrator in VS Code:**
   - Right-click VS Code
   - Select "Run as administrator"

## Getting Help

If you're still having issues:

1. **Check the error message carefully**
2. **Try running as Administrator**
3. **Restart your computer** after installations
4. **Check Windows Event Viewer** for system errors
5. **Update Windows** to the latest version

## System Requirements

- **Windows 10 or later**
- **Python 3.7 or higher**
- **4GB RAM minimum** (8GB recommended)
- **Internet connection** (for downloads and cloud models)
- **Administrator privileges** (recommended for installation) 