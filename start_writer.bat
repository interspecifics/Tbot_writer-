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