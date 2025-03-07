#Requires -Version 5.1

<#
.SYNOPSIS
    Downloads and prepares Digital Forensics and Incident Response tools for use in Windows Sandbox.

.DESCRIPTION
    This script downloads and prepares various tools needed for Digital Forensics and 
    Incident Response (DFIR) work in a Windows Sandbox environment. It can also prepare
    tools for use in a VM. The tools are downloaded and organized to enable offline 
    DFIR work without requiring internet access in the sandbox or VM.

.PARAMETER AllTools
    Downloads and updates all tools.

.PARAMETER Didier
    Updates Didier Stevens tools.

.PARAMETER DebugDownloads
    Enables debug mode for downloads.

.PARAMETER Enrichment
    Downloads and updates enrichment data like threat intelligence feeds.

.PARAMETER Freshclam
    Updates ClamAV virus databases using Freshclam.

.PARAMETER Git
    Updates git repositories.

.PARAMETER GoLang
    Updates GoLang and related packages.

.PARAMETER Http
    Updates files downloaded via HTTP.

.PARAMETER HttpNoVSCodeExtensions
    Skip updating Visual Studio Code Extensions.

.PARAMETER Kape
    Updates KAPE and related tools.

.PARAMETER LogBoost
    Updates Threat Intel for LogBoost.

.PARAMETER MSYS2
    Updates MSYS2 environment.

.PARAMETER Node
    Updates Node.js and npm packages.

.PARAMETER PowerShell
    Updates PowerShell and modules.

.PARAMETER Python
    Updates Python and packages in virtual environments.

.PARAMETER Release
    Updates releases from GitHub.

.PARAMETER Rust
    Updates Rust and cargo packages.

.PARAMETER Winget
    Updates tools installed via winget.

.PARAMETER Verify
    Verifies that all tools are available and properly installed.

.PARAMETER VisualStudioBuildTools
    Downloads and updates Visual Studio Build Tools.

.PARAMETER Zimmerman
    Updates Zimmerman tools.

.EXAMPLE
    .\downloadFiles.ps1
    Downloads all files needed for DFIRWS.

.EXAMPLE
    .\downloadFiles.ps1 -AllTools -Enrichment
    Downloads all files needed for DFIRWS and updates enrichment data.

.EXAMPLE
    .\downloadFiles.ps1 -Python
    Downloads and updates only Python packages.

.EXAMPLE
    .\downloadFiles.ps1 -AllTools -Enrichment -Freshclam
    Downloads all files, enrichment data, and updates ClamAV databases.

.LINK
    https://github.com/reuteras/dfirws
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Download all tools for DFIRWS")]
    [Switch]$AllTools,
    
    [Parameter(HelpMessage = "Update Didier Stevens tools")]
    [Switch]$Didier,
    
    [Parameter(HelpMessage = "Debug downloads")]
    [Switch]$DebugDownloads,
    
    [Parameter(HelpMessage = "Update enrichment data")]
    [Switch]$Enrichment,
    
    [Parameter(HelpMessage = "Update ClamAV databases with Freshclam")]
    [Switch]$Freshclam,
    
    [Parameter(HelpMessage = "Update git repositories")]
    [Switch]$Git,
    
    [Parameter(HelpMessage = "Update GoLang")]
    [Switch]$GoLang,
    
    [Parameter(HelpMessage = "Update files downloaded via HTTP")]
    [Switch]$Http,
    
    [Parameter(HelpMessage = "Don't update Visual Studio Code Extensions via HTTP")]
    [Switch]$HttpNoVSCodeExtensions,
    
    [Parameter(HelpMessage = "Update KAPE")]
    [Switch]$Kape,
    
    [Parameter(HelpMessage = "Update Threat Intel for LogBoost")]
    [Switch]$LogBoost,
    
    [Parameter(HelpMessage = "Update MSYS2")]
    [Switch]$MSYS2,
    
    [Parameter(HelpMessage = "Update Node.js")]
    [Switch]$Node,
    
    [Parameter(HelpMessage = "Update PowerShell and modules")]
    [Switch]$PowerShell,
    
    [Parameter(HelpMessage = "Update Python")]
    [Switch]$Python,
    
    [Parameter(HelpMessage = "Update releases from GitHub")]
    [Switch]$Release,
    
    [Parameter(HelpMessage = "Update Rust")]
    [Switch]$Rust,
    
    [Parameter(HelpMessage = "Update tools downloaded via winget")]
    [Switch]$Winget,
    
    [Parameter(HelpMessage = "Verify that tools are available")]
    [Switch]$Verify,
    
    [Parameter(HelpMessage = "Install and Update Visual Studio buildtools")]
    [Switch]$VisualStudioBuildTools,
    
    [Parameter(HelpMessage = "Update Zimmerman tools")]
    [Switch]$Zimmerman
)

#region Initialization

# Set the preference to suppress progress bars
$ProgressPreference = "SilentlyContinue"

# Source the common functions
if (Test-Path ".\resources\download\common.ps1") {
    . ".\resources\download\common.ps1"
} else {
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Error: common.ps1 not found. Please check your installation."
    Exit 1
}

# Load configuration
if (Test-Path ".\config.ps1") {
    . ".\config.ps1"
} elseif (Test-Path ".\config.ps1.template") {
    . ".\config.ps1.template"
} else {
    Write-DateLog "Error: Neither config.ps1 nor config.ps1.template found. Please check your installation."
    Exit 1
}

#endregion Initialization

#region Prerequisite Checks

# Check for required executables
$requiredTools = @("git.exe", "rclone.exe", "7z.exe")
foreach ($tool in $requiredTools) {
    if (!(Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-DateLog "Error: $tool not found. Please install it and add it to PATH."
        Exit 1
    }
}

# Ensure rclone configuration exists
rclone.exe config touch | Out-Null

# Check if sandbox is running
if (Get-Process -Name "WindowsSandboxClient", "WindowsSandboxRemote" -ErrorAction SilentlyContinue) {
    Write-DateLog "Error: Sandbox can't be running while updating. Please close the sandbox and try again."
    Exit 1
}

#endregion Prerequisite Checks

#region Parameter Handling

# Determine if we're updating all tools or specific ones
if ($AllTools.IsPresent) {
    Write-DateLog "Downloading all tools for DFIRWS."
    $all = $true
} elseif ($PSBoundParameters.Count -gt 0) {
    # At least one parameter is specified
    $all = $false
} else {
    Write-DateLog "No arguments given. Will download all tools for DFIRWS."
    $all = $true
}

# Check if tools directory exists for partial updates
if ($all -eq $false) {
    if (!(Test-Path "${TOOLS}\bin")) {
        Write-DateLog "No tools directory found. You have to run this script without arguments first."
        Exit 1
    }
}

#endregion Parameter Handling

#region Directory Setup

# Clean up old temp files
Remove-Item -Recurse -Force .\tmp\downloads\ -ErrorAction SilentlyContinue | Out-Null

# Create necessary directories
$directories = @(
    "${SETUP_PATH}",
    "${SETUP_PATH}\.etag",
    "${TOOLS}",
    "${TOOLS}\bin",
    "${TOOLS}\lib",
    "${TOOLS}\Zimmerman",
    ".\log"
)

foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
}

# Remove Debug directory if it exists
if (Test-Path "${TOOLS}\Debug") {
    Remove-Item -Recurse -Force "${TOOLS}\Debug" -ErrorAction SilentlyContinue | Out-Null
}

# Create Debug directory if debug mode is enabled
if ($DebugDownloads.IsPresent) {
    Write-DateLog "Debug mode enabled."
    New-Item -ItemType Directory -Force -Path "${TOOLS}\Debug" | Out-Null
}

# Initialize log files
$logFiles = @(
    ".\log\log.txt",
    ".\log\logboost.txt",
    ".\log\jobs.txt",
    ".\log\verify.txt"
)

foreach ($file in $logFiles) {
    Get-Date > $file
}

# Move tools_downloaded.csv to downloads if needed
if (Test-Path ".\tools_downloaded.csv") {
    Move-Item -Path ".\tools_downloaded.csv" -Destination ".\downloads\tools_downloaded.csv" -Force
}

#endregion Directory Setup

#region GitHub Authentication

# Set up GitHub authentication if needed
if ($all -or $Didier.IsPresent -or $GoLang.IsPresent -or $Http.IsPresent -or $Python.IsPresent -or $Release.IsPresent) {
    # Get GitHub credentials
    if ($GITHUB_USERNAME -ne "YOUR GITHUB USERNAME" -and $GITHUB_TOKEN -ne "YOUR GITHUB TOKEN") {
        $GH_USER = $GITHUB_USERNAME
        $GH_PASS = $GITHUB_TOKEN
    } else {
        Write-DateLog "Use GitHub username and token to avoid problems with rate limits on GitHub."
        $GH_USER = Read-Host "Enter GitHub user name"
        $PASS = Read-Host "Enter GitHub token" -AsSecureString
        $GH_PASS = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PASS))
    }
    
    if ([string]::IsNullOrWhiteSpace($GH_USER) -or [string]::IsNullOrWhiteSpace($GH_PASS)) {
        Write-DateLog "Error: No GitHub username or token given. Can't continue."
        Exit 1
    }
}

#endregion GitHub Authentication

#region Download and Update Tools

# Download common files needed for installations in sandboxes
if ($all -or $Freshclam.IsPresent -or $GoLang.IsPresent -or $LogBoost.IsPresent -or $MSYS2.IsPresent -or $Node.IsPresent -or $Python.IsPresent -or $Rust.IsPresent) {
    Write-DateLog "Downloading common files needed in Sandboxes for installation."
    .\resources\download\basic.ps1
}

# Visual Studio Build Tools
if ($VisualStudioBuildTools.IsPresent) {
    Write-DateLog "Download or update Visual Studio buildtools."
    .\resources\download\visualstudiobuildtools.ps1 | Out-Null
}

# MSYS2
if ($all -or $MSYS2.IsPresent) {
    Write-DateLog "Download MSYS2."
    .\resources\download\msys2.ps1 | Out-Null
}

# GitHub Releases
if ($all -or $Release.IsPresent) {
    Write-DateLog "Download releases from GitHub."
    .\resources\download\release.ps1
}

# HTTP Downloads
if ($all -or $Http.IsPresent) {
    Write-DateLog "Download files via HTTP."
    $httpArgs = if ($HttpNoVSCodeExtensions) { "-NoVSCodeExtensions" } else { "" }
    powershell -noprofile .\resources\download\http.ps1 $httpArgs
}

# Node.js
if ($all -or $Node.IsPresent) {
    Write-Output "" > .\log\node.txt
    Write-DateLog "Setup Node and install npm packages."
    .\resources\download\node.ps1 | Out-Null
}

# Git Repositories
if ($all -or $Git.IsPresent) {
    Write-DateLog "Download and update git repositories"
    .\resources\download\git.ps1
}

# GoLang
if ($all -or $GoLang.IsPresent) {
    Write-Output "" > .\log\golang.txt
    Write-DateLog "Setup GoLang and install packages."
    .\resources\download\go.ps1 | Out-Null
}

# Python
if ($all -or $Python.IsPresent) {
    Write-Output "" > .\log\python.txt
    Write-DateLog "Setup Python and install packages in virtual environments."
    .\resources\download\python.ps1 | Out-Null
}

# Rust
if ($all -or $Rust.IsPresent) {
    Write-Output "" > .\log\rust.txt
    Write-DateLog "Setup Rust and install packages with cargo."
    .\resources\download\rust.ps1 | Out-Null
}

# Didier Stevens Tools
if ($all -or $Didier.IsPresent) {
    Write-DateLog "Download Didier Stevens tools."
    .\resources\download\didier.ps1
}

# Winget Packages
if ($all -or $Winget.IsPresent) {
    Write-DateLog "Download tools via winget."
    .\resources\download\winget.ps1
}

# Zimmerman Tools
if ($all -or $Zimmerman.IsPresent) {
    Write-DateLog "Download Zimmerman tools."
    .\resources\download\zimmerman.ps1
}

# KAPE
if ($all -or $Kape.IsPresent) {
    if (Test-Path ".\local\kape.zip") {
        Write-DateLog "Download and update KAPE and related tools."
        .\resources\download\kape.ps1
    }
}

# PowerShell
if ($all -or $PowerShell.IsPresent) {
    Write-DateLog "Download PowerShell and modules."
    .\resources\download\powershell.ps1
}

# ClamAV
if ($Freshclam.IsPresent) {
    Write-DateLog "Download and update ClamAV databases with freshclam."
    .\resources\download\freshclam.ps1 | Out-Null
}

# Enrichment Data
if ($Enrichment.IsPresent) {
    Write-DateLog "Download enrichment data."
    .\resources\download\enrichment.ps1
}

# LogBoost
if ($all -or $LogBoost.IsPresent) {
    Write-DateLog "Update Threat Intel for LogBoost."
    .\resources\download\logboost.ps1 | Out-Null
}

#endregion Download and Update Tools

#region File Cleanup and Configuration

# Copy necessary files
Copy-Item "README.md" ".\downloads\" -Force | Out-Null
Copy-Item ".\resources\images\dfirws.jpg" ".\downloads\" -Force | Out-Null
Copy-Item ".\setup\utils\PowerSiem.ps1" ".\mount\Tools\bin\" -Force | Out-Null

# Copy capaexplorer.py to Ghidra directories
foreach ($directory in (Get-ChildItem ".\mount\Tools\Ghidra\" -Directory).Name | Where-Object { $_ -match "PUBLIC" }) {
    if (Test-Path ".\mount\Tools\Ghidra\${directory}\Ghidra\Features\Python\") {
        Copy-Item ".\mount\git\CapaExplorer\capaexplorer.py" ".\mount\Tools\Ghidra\${directory}\Ghidra\Features\Python\ghidra_scripts" -Force
    } elseif (Test-Path ".\mount\Tools\Ghidra\${directory}\Ghidra\Features\Jython\") {
        Copy-Item ".\mount\git\CapaExplorer\capaexplorer.py" ".\mount\Tools\Ghidra\${directory}\Ghidra\Features\Jython\ghidra_scripts" -Force
    }
}

# Create done.txt to track last update in sandbox
Write-Output "" > ".\downloads\done.txt"

# Clean up temporary files
$tempDirs = @(
    ".\tmp\downloads\",
    ".\tmp\enrichment",
    ".\tmp\mount\",
    ".\tmp\msys2\"
)

foreach ($dir in $tempDirs) {
    if (Test-Path $dir) {
        Remove-Item -Recurse -Force $dir -ErrorAction SilentlyContinue | Out-Null
    }
}

#endregion File Cleanup and Configuration

#region Verification and Error Checking

# Verify tools
if ($Verify.IsPresent) {
    Write-DateLog "Verify that tools are available."
    .\resources\download\verify.ps1 -WorkingDirectory $PWD\resources\download | Out-Null
    Write-DateLog "Verify done."
}

# Check for errors and warnings in log files
$warnings = Get-ChildItem .\log\* -Recurse | Select-String -Pattern "warning" | Where-Object {
    $_.Line -notmatch " INFO " -and
    $_.Line -notmatch "This is taking longer than usual" -and
    $_.Line -notmatch "Installing collected packages" -and
    $_.Line -notmatch "pymispwarninglists" -and
    $_.Line -notmatch "warning: be sure to add" -and
    $_.Line -notmatch "create mode " -and
    $_.Line -notmatch "delete mode " -and
    $_.Line -notmatch "rename " -and
    $_.Line -notmatch "reinstalling" -and
    $_.Line -notmatch "origin/main Updating" -and
    $_.Line -notmatch "new branch" -and
    $_.Line -notmatch "warnings.py" -and
    $_.Line -notmatch "core_perl"
}

$errors = Get-ChildItem .\log\* -Recurse | Select-String -Pattern "error" | Where-Object {
    $_.Line -notmatch "Error: no test specified" -and
    $_.Line -notmatch "pretty.errors" -and
    $_.Line -notmatch "Copied (replaced existing)" -and
    $_.Line -notmatch "INFO" -and
    $_.Line -notmatch "perl-Error" -and
    $_.Line -notmatch "Downloaded " -and
    $_.Line -notmatch "/cffi/error.py" -and
    $_.Line -notmatch "github/workflows" -and
    $_.Line -notmatch " Compiling " -and
    $_.Line -notmatch "create mode " -and
    $_.Line -notmatch "delete mode " -and
    $_.Line -notmatch "rename " -and
    $_.Line -notmatch "new branch" -and
    $_.Line -notmatch "origin/main Updating" -and
    $_.Line -notmatch "libgpg-error" -and
    $_.Line -notmatch "could not be locally" -and
    $_.Line -notmatch "via WKD" -and
    $_.Line -notmatch "ERROR: 9DD0D4217D75" -and
    $_.Line -notmatch "msys64\\usr\\" -and
    $_.Line -notmatch "gpg-error.exe" -and
    $_.Line -notmatch "gpg: error reading key: Network error" -and
    $_.Line -notmatch "gpg: error reading key: No data" -and
    $_.Line -notmatch "gpg: error reading key: general error" -and
    $_.Line -notmatch "ERROR: Could not update key:" -and
    $_.Line -notmatch "Error Getting File from" -and
    $_.Line -notmatch "Adding thiserror" -and
    $_.Line -notmatch "gpg-error"
}

$failed = Get-ChildItem .\log\* -Recurse | Select-String -Pattern "Failed" | Where-Object {
    $_.Line -notmatch "A connection attempt failed because the connected party did not" -and
    $_.Line -notmatch "ucrt64/share"
}

# Output final status
if ($warnings -or $errors -or $failed) {
    Write-DateLog "Errors or warnings were found in log files. Please check the log files for details."
} else {
    Write-DateLog "Downloads and preparations done."
}

#endregion Verification and Error Checking
