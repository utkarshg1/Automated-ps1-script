# Automated Development Environment Setup

This script automates the setup of a complete development environment on Windows, including:

## What it installs

- Chocolatey package manager
- Git and GitHub CLI
- Visual Studio Code with Python extensions
- Python tooling (pip, pipx, uv, utkarshpy)

## What it configures

- Git global identity (user.name and user.email)
- GitHub CLI authentication
- VS Code extensions:
  - Python extension
  - Jupyter extension
  - Black formatter extension

## How to Run

### Option 1: Double-click the batch file

Simply double-click `run.bat` to execute the script with the necessary privileges.

### Option 2: Manual execution

If you prefer to run the script manually:

1. Open PowerShell as Administrator
2. Run the following commands:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
cd <path-to-this-directory>
.\automation.ps1
```

## Logs

The script creates a timestamped log file in the same directory for troubleshooting.
