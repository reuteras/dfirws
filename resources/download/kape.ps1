<#
.SYNOPSIS
    Installs and updates KAPE (Kroll Artifact Parser and Extractor) for DFIRWS.

.DESCRIPTION
    This script handles the installation and updating of KAPE within the DFIRWS
    environment. KAPE is a powerful triage tool that can be used to quickly process
    and parse forensic artifacts from a system.
    
    The script:
    1. Checks for the presence of a local kape.zip file
    2. Extracts and updates KAPE if the zip file is present
    3. Runs the KAPE updater to ensure all components are current

.NOTES
    File Name      : kape.ps1
    Author         : DFIRWS Project
    Prerequisite   : PowerShell 5.1 or later, 7-Zip
    Version        : 2.0

.LINK
    https://github.com/reuteras/dfirws
    https://www.kroll.com/en/services/cyber-risk/incident-response-litigation-support/kroll-artifact-parser-extractor-kape
#>

[CmdletBinding()]
param()

# Source common functions
. ".\resources\download\common.ps1"

#region Initialization

# Set error action preference
$ErrorActionPreference = "Stop"

# Define paths
$kapeZipPath = ".\local\kape.zip"
$kapeDestDir = "$SETUP_PATH\KAPE"
$updaterPath = ".\resources\external\KAPE-EZToolsAncillaryUpdater.ps1"
$logPath = "$PWD\log\kape.txt"

# Check if KAPE zip file exists
if (!(Test-Path -Path $kapeZipPath)) {
    Write-DateLog "KAPE zip file not found at $kapeZipPath."
    Write-DateLog "If you want to add KAPE, place your copy of kape.zip in the local directory."
    exit 0
}

#endregion Initialization

#region KAPE Installation

try {
    Write-DateLog "KAPE zip file found. Installing/updating KAPE for DFIRWS."
    
    # Extract KAPE if it doesn't exist already
    if (!(Test-Path -Path $kapeDestDir)) {
        Write-DateLog "Extracting KAPE to $kapeDestDir"
        
        # Check if 7-Zip is available
        $sevenZipPath = "$env:ProgramFiles\7-Zip\7z.exe"
        if (!(Test-Path -Path $sevenZipPath)) {
            throw "7-Zip is not installed or not found at $sevenZipPath"
        }
        
        # Create directory if it doesn't exist
        if (!(Test-Path -Path $kapeDestDir)) {
            New-Item -ItemType Directory -Path $kapeDestDir -Force | Out-Null
        }
        
        # Extract KAPE
        $extractResult = & "$sevenZipPath" x -aoa "$kapeZipPath" -o"$kapeDestDir" | Out-String
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to extract KAPE: $extractResult"
        }
        
        # Remove automatic updater if present
        if (Test-Path "$kapeDestDir\Get-KAPEUpdate.ps1") {
            Remove-Item "$kapeDestDir\Get-KAPEUpdate.ps1" -Force
        }
    }
    else {
        Write-DateLog "KAPE directory already exists at $kapeDestDir. Skipping extraction."
    }
    
    # Copy and run the KAPE updater
    Write-DateLog "Updating KAPE components using KAPE-EZToolsAncillaryUpdater.ps1"
    
    # Store current directory
    $currentDir = $PWD
    
    # Copy updater script to KAPE directory
    Copy-Item -Path $updaterPath -Destination "$kapeDestDir\KAPE-EZToolsAncillaryUpdater.ps1" -Force
    
    # Run the updater
    Set-Location -Path $kapeDestDir
    
    # Create or clear the log file
    if (Test-Path -Path $logPath) {
        Clear-Content -Path $logPath
    }
    else {
        New-Item -ItemType File -Path $logPath -Force | Out-Null
    }
    
    # Run the updater with silent flag and redirect output to log file
    $updaterProcess = Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File .\KAPE-EZToolsAncillaryUpdater.ps1 -silent" -Wait -PassThru -NoNewWindow -RedirectStandardOutput $logPath -RedirectStandardError "$logPath.error"
    
    # Check if the updater ran successfully
    if ($updaterProcess.ExitCode -ne 0) {
        Write-DateLog "WARNING: KAPE updater exited with code $($updaterProcess.ExitCode). Check the log at $logPath"
    }
    else {
        Write-DateLog "KAPE components updated successfully"
    }
    
    # Return to original directory
    Set-Location -Path $currentDir
    
    Write-DateLog "KAPE installation and update completed."
}
catch {
    Write-DateLog "ERROR: Failed to install or update KAPE: $_"
    # Return to original directory in case of error
    if ($currentDir) {
        Set-Location -Path $currentDir
    }
    throw $_
}

#endregion KAPE Installation
