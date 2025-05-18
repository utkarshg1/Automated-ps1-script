@echo off
setlocal

REM Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

REM We now have admin rights, run the PS script directly
cd /d "%~dp0"
echo Running PowerShell script with admin rights...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0automation.ps1"

echo Execution complete.
pause
endlocal