#!/bin/bash
#
# Script to check and install NPM and the Gemini CLI.
#

# --- COLORS AND FORMATTING (for more readable output) ---
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_BLUE='\033[1;34m'

# --- HELPER FUNCTIONS ---
log() {
    echo -e "${C_BLUE}[INFO]${C_RESET} $1"
}

success() {
    echo -e "${C_GREEN}[SUCCESS]${C_RESET} $1"
}

error() {
    echo -e "${C_RED}[ERROR]${C_RESET} $1" >&2
    exit 1
}

# Function to check if a command exists on the system
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- MAIN FUNCTION ---
main() {
    log "Starting environment check..."

    # --- 1. CHECK AND INSTALL NPM ---
    if command_exists npm; then
        success "NPM is already installed."
    else
        log "NPM was not found. Attempting to install..."
        
        # Checks if 'apt-get' is available (Debian/Ubuntu systems)
        if command_exists apt-get; then
            echo "This script requires superuser permission to install packages."
            sudo apt-get update -y
            sudo apt-get install -y nodejs npm
        else
            error "'apt-get' package manager not found. Please install Node.js and NPM manually for your system."
        fi

        # Confirm the installation
        if ! command_exists npm; then
            error "NPM installation failed. Please check the errors above."
        fi
        success "NPM installed successfully."
    fi
    log "NPM Version: $(npm --version)"

    # --- 2. CHECK AND INSTALL GEMINI CLI ---
    if command_exists gemini; then
        success "Gemini CLI is already installed."
    else
        log "Gemini CLI not found. Installing via NPM..."
        # Use 'sudo' to install the package globally
        if sudo npm install -g @google/gemini-cli; then
            success "Gemini CLI installed successfully."
        else
            error "Gemini CLI installation failed. Please check the errors above."
        fi
    fi
    # The --version flag may not work on all versions, but it's a good check
    log "To check the Gemini version, use the command: gemini --version"

    # --- 3. CONFIGURE GEMINI CLI ---
    log "Configuring Gemini CLI..."
    
    GEMINI_DIR="$HOME/.gemini"
    mkdir -p "$GEMINI_DIR"
    
    # Copy settings files
    log "Copying settings files to $GEMINI_DIR..."
    cp "./settings/.env" "$GEMINI_DIR/" || warning "Failed to copy .env to $GEMINI_DIR."
    cp "./settings/settings.json" "$GEMINI_DIR/" || warning "Failed to copy settings.json to $GEMINI_DIR."
    success "Gemini CLI configuration files copied."

    # --- 4. APPEND .bashrc CONFIGURATION ---
    log "Appending Gemini CLI configuration to ~/.bashrc..."
    BASHRC_FILE="$HOME/.bashrc"
    
    # Add a marker to prevent multiple appends and for easy removal
    if ! grep -q "# --- START GEMINI CLI CONFIG ---" "$BASHRC_FILE"; then
        {
            echo ""
            echo "# --- START GEMINI CLI CONFIG ---"
            cat "./linux/.bashrc"
            echo "# --- END GEMINI CLI CONFIG ---"
            echo ""
        } >> "$BASHRC_FILE"
        success "Gemini CLI configuration appended to ~/.bashrc."
    else
        log "Gemini CLI configuration already exists in ~/.bashrc. Skipping append."
    fi

    success "Environment is ready to use the Gemini CLI!"
}

# --- SCRIPT ENTRY POINT ---
main