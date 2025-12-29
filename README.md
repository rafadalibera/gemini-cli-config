# Gemini CLI Setup Environment

## Overview

This repository provides a set of scripts to quickly and automatically set up the necessary environment for using the Google Gemini CLI (`@google/gemini-cli`). It handles the installation of dependencies like NPM and configures the user's shell to streamline authentication.

## Prerequisites

Before running the setup scripts, you must have the [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) (`gcloud`) installed and authenticated on your system. The scripts rely on `gcloud` for Application Default Credentials (ADC) to authenticate with Google services.

## Setup

Follow the instructions for your operating system.

### For Linux (Debian/Ubuntu-based)

The script will:
- Check for and install `npm` (via `nodejs`) if it's not present.
- Install the Gemini CLI (`@google/gemini-cli`) globally.
- Copy configuration files to `~/.gemini`.
- Append a helper function to your `~/.bashrc` to manage `gcloud` authentication automatically.

**Instructions:**
1.  Open a terminal and navigate to the root of this repository.
2.  Make the script executable:
    ```bash
    chmod +x ./linux/setup_gemini.sh
    ```
3.  Run the script:
    ```bash
    ./linux/setup_gemini.sh
    ```
4.  The script will prompt for your `sudo` password to install packages.
5.  After the script completes, **restart your terminal** for the changes to take effect.

### For Windows

The script will:
- Check for and install `npm` (by downloading and running the Node.js LTS installer) if it's not present.
- Install the Gemini CLI (`@google/gemini-cli`) globally.
- Copy configuration files to `%USERPROFILE%/.gemini`.
- Append a helper function to your PowerShell profile to manage `gcloud` authentication automatically.

**Instructions:**
1.  Open a PowerShell terminal and navigate to the root of this repository.
2.  Run the script:
    ```powershell
    .\windows\setup_gemini.ps1
    ```
3.  The script will check for Administrator privileges. If it doesn't have them, it will attempt to re-launch itself in a new, elevated PowerShell window. You must approve the User Account Control (UAC) prompt.
4.  After the script completes, **restart your PowerShell terminal** for all changes (PATH and profile) to take effect.

---

## Configuration Files (`./settings` directory)

This directory contains the configuration files that are automatically copied to your Gemini CLI home directory (`~/.gemini` on Linux or `%USERPROFILE%/.gemini` on Windows) during the setup process.

-   `settings.json`: This is the primary configuration file for the Gemini CLI. You can modify it to change the default behavior, logging, output formats, and other tool settings.
-   `.env`: This file is used to store environment variables. While the current setup uses `gcloud` ADC for authentication, you could use this file to set an `API_KEY` or other sensitive information if you were using a different authentication method.
