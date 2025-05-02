@echo off
REM Development Environment Setup using Chocolatey
REM Run this script as Administrator
REM Only installs VS Code, Python, Git, and GitHub CLI if they don't already exist

echo ====================================================
echo   Conditional Development Environment Setup
echo ====================================================
echo.

REM Check for administrative privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This installer requires administrator privileges.
    echo Please right-click on this file and select "Run as administrator".
    echo.
    pause
    exit /b 1
)

echo Setting up log file...
set LOGFILE=%TEMP%\dev_env_setup.log
echo Development Environment Setup Log > %LOGFILE%
echo Started at %date% %time% >> %LOGFILE%
echo. >> %LOGFILE%

REM Check if Chocolatey is installed
echo Checking for Chocolatey installation...
where choco >nul 2>&1
if %errorLevel% neq 0 (
    echo Installing Chocolatey...
    echo Installing Chocolatey... >> %LOGFILE%
    powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" >> %LOGFILE% 2>&1
    
    if %errorLevel% neq 0 (
        echo Failed to install Chocolatey. See %LOGFILE% for details.
        echo Failed to install Chocolatey at %date% %time% >> %LOGFILE%
        pause
        exit /b 1
    )
    
    echo Chocolatey installed successfully.
    echo Chocolatey installed at %date% %time% >> %LOGFILE%
    
    REM Add Chocolatey to PATH for current session
    set "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
) else (
    echo Chocolatey is already installed.
    echo Chocolatey was already installed >> %LOGFILE%
)

echo.
echo Checking and installing required applications only if they don't exist...
echo Checking applications at %date% %time% >> %LOGFILE%

REM Check and install VS Code if needed
where code >nul 2>&1
if %errorLevel% neq 0 (
    echo VS Code not found. Installing Visual Studio Code...
    echo Installing Visual Studio Code at %date% %time% >> %LOGFILE%
    choco install vscode -y >> %LOGFILE% 2>&1
    if %errorLevel% neq 0 (
        echo Failed to install VS Code. See %LOGFILE% for details.
        echo Failed to install VS Code at %date% %time% >> %LOGFILE%
    ) else {
        echo VS Code installed successfully.
        echo VS Code installed successfully at %date% %time% >> %LOGFILE%
    }
) else (
    echo VS Code is already installed. Skipping installation.
    echo VS Code already installed, skipped at %date% %time% >> %LOGFILE%
)

REM Check and install Python if needed
where python >nul 2>&1
if %errorLevel% neq 0 (
    echo Python not found. Installing Python 3.11...
    echo Installing Python 3.11 at %date% %time% >> %LOGFILE%
    choco install python --version=3.11.4 -y >> %LOGFILE% 2>&1
    if %errorLevel% neq 0 (
        echo Failed to install Python. See %LOGFILE% for details.
        echo Failed to install Python at %date% %time% >> %LOGFILE%
    ) else {
        echo Python installed successfully.
        echo Python installed successfully at %date% %time% >> %LOGFILE%
    }
) else (
    echo Python is already installed. Skipping installation.
    echo Python already installed, skipped at %date% %time% >> %LOGFILE%
)

REM Check and install Git if needed
where git >nul 2>&1
if %errorLevel% neq 0 (
    echo Git not found. Installing Git...
    echo Installing Git at %date% %time% >> %LOGFILE%
    choco install git -y >> %LOGFILE% 2>&1
    if %errorLevel% neq 0 (
        echo Failed to install Git. See %LOGFILE% for details.
        echo Failed to install Git at %date% %time% >> %LOGFILE%
    ) else {
        echo Git installed successfully.
        echo Git installed successfully at %date% %time% >> %LOGFILE%
    }
) else (
    echo Git is already installed. Skipping installation.
    echo Git already installed, skipped at %date% %time% >> %LOGFILE%
)

REM Check and install GitHub CLI if needed
where gh >nul 2>&1
if %errorLevel% neq 0 (
    echo GitHub CLI not found. Installing GitHub CLI...
    echo Installing GitHub CLI at %date% %time% >> %LOGFILE%
    choco install gh -y >> %LOGFILE% 2>&1
    if %errorLevel% neq 0 (
        echo Failed to install GitHub CLI. See %LOGFILE% for details.
        echo Failed to install GitHub CLI at %date% %time% >> %LOGFILE%
    ) else {
        echo GitHub CLI installed successfully.
        echo GitHub CLI installed successfully at %date% %time% >> %LOGFILE%
    }
) else (
    echo GitHub CLI is already installed. Skipping installation.
    echo GitHub CLI already installed, skipped at %date% %time% >> %LOGFILE%
)

REM Refresh environment variables in current session
echo Refreshing environment variables...
call refreshenv >> %LOGFILE% 2>&1

REM Verify installations
echo.
echo Verifying installations...
echo Verifying installations at %date% %time% >> %LOGFILE%

where code >nul 2>&1
if %errorLevel% neq 0 (
    echo WARNING: VS Code executable not found in PATH.
    echo WARNING: VS Code executable not found in PATH at %date% %time% >> %LOGFILE%
) else (
    echo VS Code is correctly installed.
    echo VS Code is correctly installed >> %LOGFILE%
)

where python >nul 2>&1
if %errorLevel% neq 0 (
    echo WARNING: Python executable not found in PATH.
    echo WARNING: Python executable not found in PATH at %date% %time% >> %LOGFILE%
) else (
    echo Python is correctly installed.
    python --version >> %LOGFILE% 2>&1
    echo Python is correctly installed >> %LOGFILE%
)

where git >nul 2>&1
if %errorLevel% neq 0 (
    echo WARNING: Git executable not found in PATH.
    echo WARNING: Git executable not found in PATH at %date% %time% >> %LOGFILE%
) else (
    echo Git is correctly installed.
    git --version >> %LOGFILE% 2>&1
    echo Git is correctly installed >> %LOGFILE%
)

where gh >nul 2>&1
if %errorLevel% neq 0 (
    echo WARNING: GitHub CLI executable not found in PATH.
    echo WARNING: GitHub CLI executable not found in PATH at %date% %time% >> %LOGFILE%
) else (
    echo GitHub CLI is correctly installed.
    gh --version >> %LOGFILE% 2>&1
    echo GitHub CLI is correctly installed >> %LOGFILE%
)

echo.
echo Installing VS Code extensions only if VS Code is installed...
echo Checking VS Code for extensions installation at %date% %time% >> %LOGFILE%

REM Install VS Code extensions only if VS Code is installed
where code >nul 2>&1
if %errorLevel% equ 0 (
    echo  - Installing Python extension...
    code --install-extension ms-python.python >> %LOGFILE% 2>&1
    
    echo  - Installing Jupyter extension...
    code --install-extension ms-toolsai.jupyter >> %LOGFILE% 2>&1
    
    echo  - Installing Black formatter...
    code --install-extension ms-python.black-formatter >> %LOGFILE% 2>&1
    
    echo  - Installing Pylance...
    code --install-extension ms-python.vscode-pylance >> %LOGFILE% 2>&1
    
    echo  - Installing Python debugger...
    code --install-extension ms-vscode.vscode-python-debugger >> %LOGFILE% 2>&1
    
    echo  - Installing Python Environment Manager...
    code --install-extension donjayamanne.python-environment-manager >> %LOGFILE% 2>&1
    
    echo  - Installing IntelliCode...
    code --install-extension visualstudioexptteam.vscodeintellicode >> %LOGFILE% 2>&1
    
    echo  - Installing isort...
    code --install-extension ms-python.isort >> %LOGFILE% 2>&1
    
    echo  - Installing flake8...
    code --install-extension ms-python.flake8 >> %LOGFILE% 2>&1
    
    echo  - Installing GitHub Pull Requests...
    code --install-extension github.vscode-pull-request-github >> %LOGFILE% 2>&1
    
    echo  - Installing Git Graph...
    code --install-extension mhutchie.git-graph >> %LOGFILE% 2>&1
    
    echo  - Installing GitLens...
    code --install-extension eamodio.gitlens >> %LOGFILE% 2>&1
    
    echo  - Installing Python Docstring Generator...
    code --install-extension njpwerner.autodocstring >> %LOGFILE% 2>&1
    
    echo VS Code extensions installed successfully.
    echo VS Code extensions installed at %date% %time% >> %LOGFILE%

    echo.
    echo Configuring VS Code settings...
    echo Configuring VS Code settings at %date% %time% >> %LOGFILE%

    REM Create VS Code settings directory if it doesn't exist
    if not exist "%APPDATA%\Code\User" mkdir "%APPDATA%\Code\User"

    REM Create settings.json with configuration
    echo { > "%APPDATA%\Code\User\settings.json"
    echo   "editor.formatOnSave": true, >> "%APPDATA%\Code\User\settings.json"
    echo   "python.formatting.provider": "black", >> "%APPDATA%\Code\User\settings.json"
    echo   "python.linting.enabled": true, >> "%APPDATA%\Code\User\settings.json"
    echo   "python.linting.flake8Enabled": true, >> "%APPDATA%\Code\User\settings.json"
    echo   "editor.defaultFormatter": "ms-python.black-formatter", >> "%APPDATA%\Code\User\settings.json"
    echo   "python.defaultInterpreterPath": "python" >> "%APPDATA%\Code\User\settings.json"
    echo } >> "%APPDATA%\Code\User\settings.json"

    echo VS Code settings configured.
    echo VS Code settings configured at %date% %time% >> %LOGFILE%
) else (
    echo VS Code not found in PATH. Skipping extensions installation.
    echo VS Code not found, skipped extension installation at %date% %time% >> %LOGFILE%
)

echo ====================================================
echo   Conditional Development Environment Setup Complete!
echo ====================================================
echo.
echo Installation status:
echo  - VS Code: Installed only if not present
echo  - Python 3.11: Installed only if not present
echo  - Git: Installed only if not present
echo  - GitHub CLI: Installed only if not present
echo.
echo VS Code extensions and settings were configured only if VS Code was installed.
echo.
echo Log file located at: %LOGFILE%
echo.
echo ====================================================
echo.
pause