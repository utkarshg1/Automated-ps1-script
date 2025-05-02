<#
.SYNOPSIS
  Automated dev-environment setup: Chocolatey, Git, GitHub CLI, VS Code & extensions, Git identity, and GitHub auth.
  Modular version—with each major step in its own function.

.DESCRIPTION
  - Bypass PS execution policy for this session.
  - Ensure elevated (Admin) privileges.
  - Install Chocolatey if missing.
  - Import Chocolatey profile & refresh env.
  - Install Git, gh, VS Code (checks for existing).
  - Refresh env again.
  - Install VS Code Python, Jupyter, Black extensions (checks for existing).
  - Prompt for Git user.name/email (validated).
  - Configure Git global identity.
  - Run interactive GitHub CLI login.
  - Log all actions, trap errors.
#>

# -------------------------------
# Initialization & Helper Functions
# -------------------------------
function Ensure-ExecutionPolicy {
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
}

function Ensure-Admin {
    if (-not ([Security.Principal.WindowsPrincipal] `
           [Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
        Write-Host "🔄 Relaunching as Administrator…"
        Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile", "-ExecutionPolicy Bypass", "-File `"$PSCommandPath`""
        exit
    }
}

function Start-Logging {
    $global:LogFilePath = Join-Path $env:TEMP "setup_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    Start-Transcript -Path $LogFilePath
}

function Stop-Logging {
    Stop-Transcript
    Write-Host "🚀 Setup complete! Log file: $global:LogFilePath"
}

# -------------------------------
# Chocolatey Installation & Environment Refresh
# -------------------------------
function Install-Chocolatey {
    if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
        Write-Host "🔄 Installing Chocolatey..."
        [System.Net.ServicePointManager]::SecurityProtocol = `
          [System.Net.SecurityProtocolType]::Tls12
        iex ((New-Object System.Net.WebClient).DownloadString(
            'https://community.chocolatey.org/install.ps1'))
        Write-Host "✅ Chocolatey installed."
    } else {
        Write-Host "✅ Chocolatey already present."
    }
}

function Refresh-Environment {
    $env:ChocolateyInstall = Split-Path (Split-Path (Get-Command choco).Source) -Parent
    $profilePath = Join-Path $env:ChocolateyInstall 'helpers\chocolateyProfile.psm1'
    if (Test-Path $profilePath) { Import-Module $profilePath }
    Update-SessionEnvironment
}

# -------------------------------
# Package Installation
# -------------------------------
function Install-PackageIfMissing {
    param($CommandName, $ChocoName)
    if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
        Write-Host "  ➡️ $ChocoName not found. Installing..."
        choco install $ChocoName -y
    } else {
        Write-Host "  ✅ $ChocoName already installed."
    }
}

# -------------------------------
# VS Code Extension Installation
# -------------------------------
function Is-VSCodeExtensionInstalled {
    param($extensionId)
    try {
        $installed = code --list-extensions
        return $installed -contains $extensionId
    } catch {
        Write-Warning "⚠️ Could not list VS Code extensions. Assuming not installed."
        return $false
    }
}

function Install-VSCodeExtensionIfMissing {
    param($extensionId)
    if (-not (Is-VSCodeExtensionInstalled $extensionId)) {
        Write-Host "  ➡️ $extensionId not found. Installing..."
        code --install-extension $extensionId
    } else {
        Write-Host "  ✅ $extensionId already installed."
    }
}

# -------------------------------
# Git Configuration
# -------------------------------
function Prompt-NonEmpty {
    param($prompt)
    do {
        $resp = Read-Host -Prompt $prompt
    } while ([string]::IsNullOrWhiteSpace($resp))
    return $resp
}

function Configure-GitIdentity {
    Write-Host "`n🔧 Configuring Git global user.name and user.email…"
    $global:UserName  = Prompt-NonEmpty 'Enter your Git user.name'
    $global:UserEmail = Prompt-NonEmpty 'Enter your Git user.email'
    git config --global user.name  $global:UserName
    git config --global user.email $global:UserEmail
}

# -------------------------------
# GitHub CLI Authentication
# -------------------------------
function Authenticate-GitHubCLI {
    Write-Host "`n🔐 Launching GitHub CLI login…"
    gh auth login --hostname github.com --scopes repo,workflow
}

# -------------------------------
# Final Validation
# -------------------------------
function Validate-Setup {
    Write-Host "`n🛠️  Validation Results:"
    Write-Host "• Git version: $(git --version)"
    Write-Host "• gh version:  $(gh --version)"
    Write-Host "• VS Code version: $(code --version)"
    Write-Host "🔍 PATH entries:"
    $env:Path -split ';' |
      Where-Object { $_ -match 'Git|GitHubCLI|VSCode' } |
      ForEach-Object { Write-Host "   $_" }
}

# -------------------------------
# Main Script Execution
# -------------------------------
try {
    Ensure-ExecutionPolicy
    Ensure-Admin

    Install-Chocolatey
    Refresh-Environment

    Write-Host "`n🔄 Checking and installing Git, GitHub CLI, and VS Code..."
    Install-PackageIfMissing -CommandName git -ChocoName git
    Install-PackageIfMissing -CommandName gh  -ChocoName gh
    Install-PackageIfMissing -CommandName code -ChocoName vscode

    Refresh-Environment

    Write-Host "`n🔄 Checking and installing VS Code extensions..."
    Install-VSCodeExtensionIfMissing -extensionId "ms-python.python"
    Install-VSCodeExtensionIfMissing -extensionId "ms-toolsai.jupyter"
    Install-VSCodeExtensionIfMissing -extensionId "ms-python.black-formatter"

    Configure-GitIdentity
    Authenticate-GitHubCLI

    Start-Logging
    Validate-Setup
} catch {
    Write-Error "❌ Setup error: $($_.Exception.Message)"
    exit 1
} finally {
    Stop-Logging
}
