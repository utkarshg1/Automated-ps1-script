# Automated dev-environment setup: Chocolatey, Git, GitHub CLI, VS Code & extensions, Git identity, GitHub auth, Python tooling
# Uses Chocolatey builtin `refreshenv` to reload environment variables

# ---------------------------------------
# Globals & Logging
# ---------------------------------------
$TranscriptStarted = $false
$ScriptDir         = $PSScriptRoot
$LogFile           = Join-Path $ScriptDir "setup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Start-Logging {
    Start-Transcript -Path $LogFile -Force
    $global:TranscriptStarted = $true
    Write-Host "Logging to $LogFile"
}

function Stop-Logging {
    if ($global:TranscriptStarted) {
        Stop-Transcript
        Write-Host "Setup complete. Log file: $LogFile"
    }
}

# ---------------------------------------
# Chocolatey & Environment
# ---------------------------------------
function Install-Chocolatey {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Chocolatey..."
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        iex ((New-Object Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "Chocolatey installed."
    } else {
        Write-Host "Chocolatey already present."
    }
}

# ---------------------------------------
# Package Installation
# ---------------------------------------
function Install-PackageIfMissing {
    param(
        [string]$CommandName,
        [string]$ChocoName
    )
    if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
        Write-Host "$ChocoName not found. Installing..."
        choco install $ChocoName -y
        refreshenv
    } else {
        Write-Host "$ChocoName already installed."
    }
}

# ---------------------------------------
# VS Code Extensions
# ---------------------------------------
function Is-VSCodeExtensionInstalled {
    param([string]$ExtensionId)
    Try { (code --list-extensions) -contains $ExtensionId } Catch { $false }
}

function Install-VSCodeExtensionIfMissing {
    param([string]$ExtensionId)
    if (-not (Is-VSCodeExtensionInstalled $ExtensionId)) {
        Write-Host "$ExtensionId not found. Installing..."
        code --install-extension $ExtensionId
    } else {
        Write-Host "$ExtensionId already installed."
    }
}

# ---------------------------------------
# Git Configuration
# ---------------------------------------
function Prompt-NonEmpty {
    param([string]$PromptText)
    do { $resp = Read-Host -Prompt $PromptText }
    while ([string]::IsNullOrWhiteSpace($resp))
    return $resp
}

function Configure-GitIdentity {
    Write-Host ""
    $existingName  = git config --global user.name
    $existingEmail = git config --global user.email

    if (-not $existingName -or -not $existingEmail) {
        Write-Host "Configuring Git global user.name and user.email..."
        if (-not $existingName) {
            $name = Prompt-NonEmpty 'Enter your Git user.name'
            git config --global user.name $name
        } else {
            Write-Host "Git user.name already configured: $existingName"
        }

        if (-not $existingEmail) {
            $email = Prompt-NonEmpty 'Enter your Git user.email'
            git config --global user.email $email
        } else {
            Write-Host "Git user.email already configured: $existingEmail"
        }
    } else {
        Write-Host "Git user.name and user.email already configured."
    }
}

# ---------------------------------------
# GitHub CLI Login
# ---------------------------------------
function Authenticate-GitHubCLI {
    Write-Host ""
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "GitHub CLI already authenticated."
    } else {
        Write-Host "GitHub CLI not authenticated. Launching login..."
        gh auth login --hostname github.com
    }
}

# ---------------------------------------
# Validation
# ---------------------------------------
function Validate-Setup {
    Write-Host ""
    Write-Host "Validation Results:"
    Write-Host "  Chocolatey version: $(choco --version)"
    Write-Host "  Git version: $(git --version)"
    Write-Host "  gh version:  $(gh --version)"
    Write-Host "  Code version: $(code --version)"
    Write-Host "  Python version: $(python --version)"
    Write-Host "  pip version: $(pip --version)"
    Write-Host "  pipx version: $(pipx --version)"
    Write-Host "  uv version: $(uv --version)"
    Write-Host "  utkarshpy version: $(utkarshpy --version)"
    Write-Host "  PATH entries:"
    $env:Path -split ';' | Where-Object { $_ -match 'Git|gh.exe|Code.exe' } |
      ForEach-Object { Write-Host "    $_" }
}

# ---------------------------------------
# Main
# ---------------------------------------
try {
    Start-Logging

    # Install Chocolatey, then load helper and refresh session
    Install-Chocolatey
    Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1" -ErrorAction SilentlyContinue
    Write-Host "Refreshing environment via refreshenv..."
    refreshenv

    Write-Host ""
    Write-Host "Updating Chocolatey..."
    choco upgrade chocolatey -y
    refreshenv

    Write-Host ""
    Write-Host "Installing core packages..."
    Install-PackageIfMissing -CommandName python -ChocoName python313
    Install-PackageIfMissing -CommandName git    -ChocoName git
    Install-PackageIfMissing -CommandName gh     -ChocoName gh
    Install-PackageIfMissing -CommandName code   -ChocoName vscode

    Write-Host ""
    Write-Host "Upgrading pip and installing pipx via Python..."
    python -m pip install --upgrade pip
    python -m pip install --user pipx
    python -m pipx ensurepath
    refreshenv

    Write-Host "Installing UV and utkarshpy via pipx..."
    pipx install uv
    pipx install utkarshpy
    refreshenv

    Write-Host ""
    Write-Host "Installing VS Code extensions..."
    Install-VSCodeExtensionIfMissing -ExtensionId "ms-python.python"
    Install-VSCodeExtensionIfMissing -ExtensionId "ms-toolsai.jupyter"
    Install-VSCodeExtensionIfMissing -ExtensionId "ms-python.black-formatter"

    Configure-GitIdentity
    Authenticate-GitHubCLI

    Validate-Setup
}
catch {
    Write-Error "Setup error: $($_.Exception.Message)"
    Stop-Logging
    exit 1
}

Stop-Logging
