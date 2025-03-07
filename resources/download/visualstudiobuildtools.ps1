<#
.SYNOPSIS
    Downloads and configures Visual Studio Build Tools for DFIRWS.

.DESCRIPTION
    This script downloads and configures Microsoft Visual Studio Build Tools
    for use within the DFIRWS environment. The Build Tools provide the necessary
    components to compile and build applications, particularly those that require
    C/C++ support.

    The script creates a local layout of VS Build Tools with selected components
    to enable offline installation within the sandbox.

.NOTES
    File Name      : visualstudiobuildtools.ps1
    Author         : DFIRWS Project
    Prerequisite   : PowerShell 5.1 or later
    Version        : 2.0

.LINK
    https://github.com/reuteras/dfirws
    https://visualstudio.microsoft.com/downloads/
#>

[CmdletBinding()]
param()

# Source common functions
. ".\resources\download\common.ps1"

#region Initialization

# Set error action preference
$ErrorActionPreference = "Stop"

# Define paths
$vsLayoutPath = ".\mount\Tools\VSLayout"
$vsLayoutJsonPath = "$vsLayoutPath\Layout.json"
$vsBuildToolsExe = "${SETUP_PATH}\vs_BuildTools.exe"

# Log current working directory for diagnostic purposes
Write-DateLog "Current working directory: $PWD"

# Check if VS Build Tools installer exists
if (!(Test-Path -Path $vsBuildToolsExe)) {
    Write-DateLog "ERROR: Visual Studio Build Tools installer not found at $vsBuildToolsExe"
    Write-DateLog "Please run the basic.ps1 script first to download the installer."
    exit 1
}

#endregion Initialization

#region VS Build Tools Layout Creation

try {
    Write-DateLog "Starting Visual Studio Build Tools layout creation/update"
    
    # Define common arguments for the VS Build Tools installer
    $commonArgs = "--lang En-us --passive"
    
    # Determine whether we need to create a new layout or update an existing one
    if (!(Test-Path -Path $vsLayoutJsonPath)) {
        Write-DateLog "Creating new Visual Studio Build Tools layout"
        
        # Define components to include in the layout
        $componentsArgs = @(
            "--add Microsoft.VisualStudio.Workload.VCTools",
            "--includeRecommended",
            "--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
            "--add Microsoft.VisualStudio.Component.Windows10SDK.19041",
            "--add Microsoft.VisualStudio.Component.TestTools.BuildTools",
            "--add Microsoft.VisualStudio.Component.VC.CMake.Project",
            "--add Microsoft.VisualStudio.Component.VC.CLI.Support"
        ) -join " "
        
        # Full command to create a new layout
        $layoutArgs = "--layout `"$vsLayoutPath`" $componentsArgs $commonArgs"
    }
    else {
        Write-DateLog "Updating existing Visual Studio Build Tools layout"
        
        # Command to update existing layout
        $layoutArgs = "--layout `"$vsLayoutPath`" $commonArgs"
    }
    
    # Run the VS Build Tools installer to create/update the layout
    Write-DateLog "Running VS Build Tools installer with arguments: $layoutArgs"
    $process = Start-Process -FilePath $vsBuildToolsExe -ArgumentList $layoutArgs -Wait -PassThru -NoNewWindow
    
    # Check if the process completed successfully
    if ($process.ExitCode -ne 0) {
        Write-DateLog "WARNING: Visual Studio Build Tools installer exited with code $($process.ExitCode)"
    }
    else {
        Write-DateLog "Visual Studio Build Tools layout created/updated successfully"
    }
    
    # Verify the layout was created correctly
    if (Test-Path -Path $vsLayoutJsonPath) {
        $layoutSize = (Get-ChildItem -Path $vsLayoutPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-DateLog "Visual Studio Build Tools layout created at $vsLayoutPath (Size: $($layoutSize.ToString('0.00')) MB)"
    }
    else {
        Write-DateLog "WARNING: Layout.json not found after installation. The layout might not have been created correctly."
    }
}
catch {
    Write-DateLog "ERROR: Failed to create/update Visual Studio Build Tools layout: $_"
    throw $_
}

Write-DateLog "Visual Studio Build Tools layout process completed"

#endregion VS Build Tools Layout Creation
