<#
.SYNOPSIS
    Downloads PowerShell modules for DFIRWS environment.

.DESCRIPTION
    This script downloads and prepares PowerShell modules needed for Digital Forensics
    and Incident Response analysis in Windows Sandbox. It handles common modules like
    Terminal-Icons, posh-git, and ImportExcel.

.NOTES
    File Name      : powershell.ps1
    Author         : DFIRWS Project
    Prerequisite   : PowerShell 5.1 or later
    Version        : 2.0

.LINK
    https://github.com/reuteras/dfirws
#>

[CmdletBinding()]
param()

# Source common functions
. ".\resources\download\common.ps1"

#region Initialization

# Set error action preference
$ErrorActionPreference = "Stop"

# Define directories
$tempDir = ".\tmp\powershell"
$targetDir = ".\downloads\powershell-modules"

# Create target directory if it doesn't exist
if (!(Test-Path -Path $targetDir)) {
    Write-DateLog "Creating PowerShell modules destination directory"
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
}

# Clean temp directory
Clear-Tmp powershell

# Initialize download counters
$totalModules = 0
$successfulModules = 0
$failedModules = 0

# Define modules to download
$modules = @(
    @{Name = "Terminal-Icons"; Description = "File and folder icons for PowerShell terminal"},
    @{Name = "posh-git"; Description = "Git integration for PowerShell prompt"},
    @{Name = "ImportExcel"; Description = "Excel spreadsheet manipulation without Excel"}
)

$totalModules = $modules.Count

#endregion Initialization

#region Module Downloads

Write-DateLog "Starting PowerShell module downloads"

foreach ($module in $modules) {
    $moduleName = $module.Name
    $moduleDescription = $module.Description
    
    try {
        Write-DateLog "PowerShell: Downloading $moduleName - $moduleDescription"
        Save-Module -Name $moduleName -Path $tempDir -Force -ErrorAction Stop
        $successfulModules++
    }
    catch {
        Write-DateLog "ERROR: Failed to download PowerShell module $moduleName - $_"
        $failedModules++
    }
}

#endregion Module Downloads

#region Finalization

# Synchronize the downloaded modules to the target directory
try {
    Write-DateLog "Synchronizing PowerShell modules to $targetDir"
    
    # Check if rclone is available
    if (!(Get-Command rclone.exe -ErrorAction SilentlyContinue)) {
        throw "rclone.exe is not available. Please install rclone and add it to PATH."
    }
    
    # Synchronize using rclone
    $rcloneOutput = rclone.exe sync --verbose --checksum $tempDir $targetDir 2>&1
    Write-Verbose ($rcloneOutput | Out-String)
    
    Write-DateLog "Successfully synchronized PowerShell modules"
}
catch {
    Write-DateLog "ERROR: Failed to synchronize PowerShell modules - $_"
    
    # Fallback to native PowerShell copy if rclone fails
    try {
        Write-DateLog "Falling back to native PowerShell copy"
        if (Test-Path -Path $tempDir) {
            Get-ChildItem -Path $tempDir -Recurse | ForEach-Object {
                $targetPath = $_.FullName.Replace($tempDir, $targetDir)
                
                if ($_.PSIsContainer) {
                    # Create directory
                    if (!(Test-Path -Path $targetPath)) {
                        New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
                    }
                }
                else {
                    # Copy file
                    Copy-Item -Path $_.FullName -Destination $targetPath -Force
                }
            }
            Write-DateLog "Fallback copy completed successfully"
        }
    }
    catch {
        Write-DateLog "ERROR: Fallback copy also failed - $_"
    }
}

# Clean up temporary files
Clear-Tmp powershell

# Output summary
Write-DateLog "PowerShell module download summary: Downloaded $successfulModules of $totalModules modules"
if ($failedModules -gt 0) {
    Write-DateLog "WARNING: $failedModules modules failed to download"
}
else {
    Write-DateLog "PowerShell module downloads completed successfully"
}

#endregion Finalization
