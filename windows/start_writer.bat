@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
pushd "%SCRIPT_DIR%\.."

REM Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
  echo [ERROR] Python not found!
  echo Please install Python from https://python.org and add it to PATH
  popd
  pause
  exit /b 1
)

REM Check main script
if not exist "text_co_writer.py" (
  echo [ERROR] text_co_writer.py not found at repo root.
  popd
  pause
  exit /b 1
)

echo [INFO] Starting the text co-writer...
python text_co_writer.py
set "code=%errorlevel%"

popd
if %code% neq 0 (
  echo.
  echo [ERROR] The program exited with an error.
) else (
  echo.
  echo [INFO] Program finished successfully.
)
pause
endlocal


