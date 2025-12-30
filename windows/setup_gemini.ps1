# ==============================================================================
#
#          FILE: setup_gemini.ps1
#
#         USAGE: .\setup_gemini.ps1
#
#   DESCRIPTION: Script to automate the installation and configuration of the 
#                Gemini CLI on Windows systems.
#
# ==============================================================================

# --- HELPER FUNCTIONS ---

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host "[INFO] $Message" -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
    # Pause for user to see the error, then exit
    Read-Host "Press Enter to exit"
    exit 1
}

# --- SCRIPT START ---

# 1. CHECK FOR ADMIN PRIVILEGES
Write-Log "Checking for Administrator privileges..."
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Log "This script needs to be run as Administrator. Trying to re-launch..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-File `"$PSCommandPath`""
    exit
}
Write-Success "Running as Administrator."

# Set TLS 1.2 for web requests
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# --- 2. CHECK AND INSTALL NPM (via NVM) ---
Write-Log "Checking for NPM..."
$npmExists = Get-Command npm -ErrorAction SilentlyContinue
if ($npmExists) {
    Write-Success "NPM is already installed."
} else {
    Write-Log "NPM not found. Checking for NVM for Windows..."
    $nvmExists = Get-Command nvm -ErrorAction SilentlyContinue
    if (-NOT $nvmExists) {
        Write-Error "NVM for Windows is not installed. Please install it from https://github.com/coreybutler/nvm-windows/releases and re-run this script."
    }
    
    Write-Log "NVM found. Installing the latest LTS version of Node.js. This may take a moment..."
    try {
        nvm install lts
        nvm use lts
    } catch {
        Write-Error "Failed to install Node.js using NVM. Please check your NVM installation and try again."
    }

    # Verify installation
    if (!(Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Error "Node.js installation via NVM failed. Please try installing it manually."
    }
    Write-Success "Node.js and NPM installed successfully via NVM."
}
Write-Log "NPM Version: $(npm --version)"

# --- 3. CHECK AND INSTALL GEMINI CLI ---
Write-Log "Checking for Gemini CLI..."
$geminiExists = Get-Command gemini -ErrorAction SilentlyContinue
if ($geminiExists) {
    Write-Success "Gemini CLI is already installed."
} else {
    Write-Log "Gemini CLI not found. Installing via NPM..."
    npm install -g @google/gemini-cli
    if (!(Get-Command gemini -ErrorAction SilentlyContinue)) {
        Write-Error "Gemini CLI installation failed. Please check the errors above."
    }
    Write-Success "Gemini CLI installed successfully."
}
Write-Log "To check the Gemini version, use the command: gemini --version"


# --- 4. CONFIGURE GEMINI CLI ---
Write-Log "Configuring Gemini CLI..."
$geminiDir = Join-Path $env:USERPROFILE ".gemini"

if (-NOT (Test-Path $geminiDir)) {
    New-Item -ItemType Directory -Path $geminiDir -Force | Out-Null
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Log "Copying settings files to $geminiDir..."
Copy-Item -Path (Join-Path $scriptDir "..\settings\.env") -Destination $geminiDir -Force
Copy-Item -Path (Join-Path $scriptDir "..\settings\settings.json") -Destination $geminiDir -Force
Write-Success "Gemini CLI configuration files copied."

# --- 5. APPEND POWERSHELL PROFILE CONFIGURATION ---
Write-Log "Appending Gemini configuration to PowerShell profile..."
if (-NOT (Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force | Out-Null
    Write-Log "Created PowerShell profile file at $PROFILE"
}

$profileContent = Get-Content $PROFILE
$geminiProfileFunction = Get-Content (Join-Path $scriptDir "gemini_profile.ps1")

if ($profileContent -match "# --- START GEMINI CLI CONFIG ---") {
    Write-Log "Gemini CLI configuration already exists in PowerShell profile. Skipping."
} else {
    Add-Content -Path $PROFILE -Value "`n# --- START GEMINI CLI CONFIG ---`n"
    Add-Content -Path $PROFILE -Value $geminiProfileFunction
    Add-Content -Path $PROFILE -Value "`n# --- END GEMINI CLI CONFIG ---`n"
    Write-Success "Gemini configuration appended to PowerShell profile."
}

Write-Success "Setup complete! Please RESTART your terminal to apply all changes."
Read-Host "Press Enter to exit"
