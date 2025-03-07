<#
.SYNOPSIS
    Main handler for downloading tools based on configuration file.

.DESCRIPTION
    This script processes a tools configuration file and downloads the specified
    tools according to their configuration. It handles different types of downloads
    including GitHub releases, direct HTTP downloads, WinGet packages, and more.
    
    The script can be run with various parameters to control which tools are downloaded.

.PARAMETER ConfigFile
    Path to the tools configuration file. Default is 'config/downloads-config.json'.

.PARAMETER AllTools
    Download all tools specified in the configuration file.

.PARAMETER Categories
    List of tool categories to download (e.g., 'forensics', 'development', 'utilities').

.PARAMETER Tools
    List of specific tool names to download.

.PARAMETER NoPostProcessing
    Skip post-download processing steps.

.PARAMETER DebugDownloads
    Enable debug mode for downloads.

.EXAMPLE
    .\Invoke-ToolsDownload.ps1 -AllTools
    Downloads all tools specified in the configuration file.

.EXAMPLE
    .\Invoke-ToolsDownload.ps1 -Categories forensics,utilities
    Downloads only tools in the 'forensics' and 'utilities' categories.

.EXAMPLE
    .\Invoke-ToolsDownload.ps1 -Tools "7-Zip","Python","Visual Studio Code"
    Downloads only the specified tools.

.NOTES
    File Name      : Invoke-ToolsDownload.ps1
    Author         : DFIRWS Project
    Prerequisite   : PowerShell 5.1 or higher
    Version        : 1.0
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Path to the tools configuration file.")]
    [string]$ConfigFile = "config/downloads-config.json",
    
    [Parameter(HelpMessage = "Download all tools.")]
    [Switch]$AllTools,
    
    [Parameter(HelpMessage = "Download tools in specific categories.")]
    [string[]]$Categories,
    
    [Parameter(HelpMessage = "Download specific tools by name.")]
    [string[]]$Tools,
    
    # Add parameters from original downloadFiles.ps1
    [Parameter(HelpMessage = "Update Didier Stevens tools.")]
    [Switch]$Didier,
    
    [Parameter(HelpMessage = "Debug downloads.")]
    [Switch]$DebugDownloads,
    
    [Parameter(HelpMessage = "Update enrichment.")]
    [Switch]$Enrichment,
    
    [Parameter(HelpMessage = "Update ClamAV databases with Freshclam.")]
    [Switch]$Freshclam,
    
    [Parameter(HelpMessage = "Update git repositories.")]
    [Switch]$Git,
    
    [Parameter(HelpMessage = "Update GoLang.")]
    [Switch]$GoLang,
    
    [Parameter(HelpMessage = "Update files downloaded via HTTP.")]
    [Switch]$Http,
    
    [Parameter(HelpMessage = "Don't update Visual Studio Code Extensions via http.")]
    [Switch]$HttpNoVSCodeExtensions,
    
    [Parameter(HelpMessage = "Update KAPE.")]
    [Switch]$Kape,
    
    [Parameter(HelpMessage = "Update Threat Intel for LogBoost.")]
    [Switch]$LogBoost,
    
    [Parameter(HelpMessage = "Update MSYS2.")]
    [Switch]$MSYS2,
    
    [Parameter(HelpMessage = "Update Node.")]
    [Switch]$Node,
    
    [Parameter(HelpMessage = "Update PowerShell and modules.")]
    [Switch]$PowerShell,
    
    [Parameter(HelpMessage = "Update Python.")]
    [Switch]$Python,
    
    [Parameter(HelpMessage = "Update releases from GitHub.")]
    [Switch]$Release,
    
    [Parameter(HelpMessage = "Update Rust.")]
    [Switch]$Rust,
    
    [Parameter(HelpMessage = "Update tools downloaded via winget.")]
    [Switch]$Winget,
    
    [Parameter(HelpMessage = "Verify that tools are available.")]
    [Switch]$Verify,
    
    [Parameter(HelpMessage = "Install and Update Visual Studio buildtools.")]
    [Switch]$VisualStudioBuildTools,
    
    [Parameter(HelpMessage = "Update Zimmerman tools.")]
    [Switch]$Zimmerman,
    
    [Parameter(HelpMessage = "Skip post-download processing steps.")]
    [Switch]$NoPostProcessing
)

#region Initialization
# Source common functions
. ".\resources\download\common.ps1"

# Set error action preference
$ErrorActionPreference = "Continue"

# Setup progress tracking variables
$totalTools = 0
$downloadedTools = 0
$failedTools = 0
$skippedTools = 0

# Check if all parameters are default (no specific filter)
$noToolFilter = -not ($AllTools -or $Categories -or $Tools -or 
                       $Didier -or $Enrichment -or $Freshclam -or 
                       $Git -or $GoLang -or $Http -or $Kape -or 
                       $LogBoost -or $MSYS2 -or $Node -or $PowerShell -or 
                       $Python -or $Release -or $Rust -or $Winget -or 
                       $Zimmerman)

if ($noToolFilter) {
    Write-DateLog "No filter specified. Will download all tools."
    $AllTools = $true
}

# Compatibility with original script logic
$all = $AllTools

# Create a variable scope for evaluating conditions
$conditionScope = New-Object PSObject
$PSDefaultParameterValues.Keys | ForEach-Object {
    Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name $_ -Value $PSDefaultParameterValues[$_]
}
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "all" -Value $all
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "Didier" -Value $Didier
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "Enrichment" -Value $Enrichment
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "Freshclam" -Value $Freshclam
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "Git" -Value $Git
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "GoLang" -Value $GoLang
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "Http" -Value $Http
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "HttpNoVSCodeExtensions" -Value $HttpNoVSCodeExtensions
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "Kape" -Value $Kape
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "LogBoost" -Value $LogBoost
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "MSYS2" -Value $MSYS2
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "Node" -Value $Node
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "PowerShell" -Value $PowerShell
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "Python" -Value $Python
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "Release" -Value $Release
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "Rust" -Value $Rust
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "Winget" -Value $Winget
Add-Member -InputObject $conditionScope -MemberType NoteProperty -Name "Zimmerman" -Value $Zimmerman

# Create required directories
$directories = @(
    "${SETUP_PATH}"
    "${SETUP_PATH}\.etag"
    "${TOOLS}"
    "${TOOLS}\bin"
    "${TOOLS}\lib"
    ".\log"
)

foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        Write-DateLog "Creating directory: $dir"
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
}

# Create debug directory if debug mode is enabled
if ($DebugDownloads) {
    Write-DateLog "Debug mode enabled."
    if (!(Test-Path "${TOOLS}\Debug")) {
        New-Item -ItemType Directory -Force -Path "${TOOLS}\Debug" | Out-Null
    }
}

# Initialize log files
$logFiles = @(
    ".\log\log.txt"
    ".\log\logboost.txt"
    ".\log\jobs.txt"
    ".\log\verify.txt"
)

foreach ($file in $logFiles) {
    Get-Date > $file
}

#endregion Initialization

#region Load Configuration

Write-DateLog "Loading tools configuration from $ConfigFile"

if (!(Test-Path $ConfigFile)) {
    Write-DateLog "ERROR: Configuration file not found: $ConfigFile"
    Exit 1
}

try {
    $toolsConfig = Get-Content -Path $ConfigFile -Raw | ConvertFrom-Json
    Write-DateLog "Configuration loaded: $(($toolsConfig.tools | Measure-Object).Count) tools defined"
}
catch {
    Write-DateLog "ERROR: Failed to parse configuration file: $_"
    Exit 1
}

#endregion Load Configuration

#region Filter Tools

# Filter tools based on parameters
$filteredTools = $toolsConfig.tools | Where-Object {
    $tool = $_
    
    # Skip disabled tools
    if ($tool.enabled -eq $false) {
        return $false
    }
    
    # Include tool if it matches any of the filter criteria
    $includeByCategory = $Categories -and $tool.category -in $Categories
    $includeByName = $Tools -and $tool.name -in $Tools
    $includeByAllTools = $AllTools
    
    # Evaluate condition if present
    $includeByCondition = $true
    if ($tool.condition) {
        try {
            $conditionResult = Invoke-Expression "`$includeByCondition = `$($tool.condition)"
            $includeByCondition = $conditionResult
        }
        catch {
            Write-DateLog "ERROR: Failed to evaluate condition for $($tool.name): $_"
            $includeByCondition = $false
        }
    }
    
    return ($includeByCategory -or $includeByName -or $includeByAllTools) -and $includeByCondition
}

$totalTools = ($filteredTools | Measure-Object).Count
Write-DateLog "Filtered tools: $totalTools to process"

if ($totalTools -eq 0) {
    Write-DateLog "No tools to download. Exiting."
    Exit 0
}

#endregion Filter Tools

#region Download Functions

# Function to download GitHub release
function Get-GitHubReleaseTool {
    param (
        [Parameter(Mandatory=$true)]
        [PSObject]$Tool
    )
    
    $repo = $Tool.source.repo
    $match = $Tool.source.match
    $destPath = Resolve-VariablePath $Tool.destination.path
    $validationType = $Tool.validation.type
    
    Write-DateLog "Downloading GitHub release: $($Tool.name) from $repo"
    
    try {
        $status = Get-GitHubRelease -repo $repo -path $destPath -match $match -check $validationType
        
        if ($status) {
            Write-DateLog "Successfully downloaded $($Tool.name)"
            return $true
        }
        else {
            Write-DateLog "No update needed for $($Tool.name)"
            return $false
        }
    }
    catch {
        Write-DateLog "ERROR: Failed to download $($Tool.name): $_"
        return $false
    }
}

# Function to download via HTTP
function Get-HttpTool {
    param (
        [Parameter(Mandatory=$true)]
        [PSObject]$Tool
    )
    
    $destPath = Resolve-VariablePath $Tool.destination.path
    $validationType = $Tool.validation.type
    
    # Handle direct URL
    if ($Tool.source.url -and !$Tool.source.pattern) {
        $url = $Tool.source.url
        Write-DateLog "Downloading HTTP: $($Tool.name) from $url"
        
        try {
            $status = Get-FileFromUri -uri $url -FilePath $destPath -check $validationType
            
            if ($status) {
                Write-DateLog "Successfully downloaded $($Tool.name)"
                return $true
            }
            else {
                Write-DateLog "No update needed for $($Tool.name)"
                return $false
            }
        }
        catch {
            Write-DateLog "ERROR: Failed to download $($Tool.name): $_"
            return $false
        }
    }
    # Handle URL extraction from page
    elseif ($Tool.source.url -and $Tool.source.pattern) {
        $pageUrl = $Tool.source.url
        $pattern = $Tool.source.pattern
        $baseUrl = $Tool.source.base_url
        
        Write-DateLog "Extracting download URL for $($Tool.name) from $pageUrl with pattern $pattern"
        
        try {
            $extractedUrl = Get-DownloadUrlFromPage -url $pageUrl -RegEx $pattern
            
            if (!$extractedUrl) {
                Write-DateLog "ERROR: Failed to extract URL for $($Tool.name)"
                return $false
            }
            
            # Set variable if needed
            if ($Tool.source.variable) {
                Set-Variable -Name $Tool.source.variable -Value $extractedUrl -Scope Script
                
                # If URL template is provided, use it
                if ($Tool.source.url_template) {
                    $urlTemplate = $Tool.source.url_template
                    $url = Invoke-Expression "`"$urlTemplate`""
                }
                else {
                    if ($baseUrl) {
                        $url = "$baseUrl$extractedUrl"
                    }
                    else {
                        $url = $extractedUrl
                    }
                }
            }
            else {
                if ($baseUrl) {
                    $url = "$baseUrl$extractedUrl"
                }
                else {
                    $url = $extractedUrl
                }
            }
            
            Write-DateLog "Downloading $($Tool.name) from $url"
            $status = Get-FileFromUri -uri $url -FilePath $destPath -check $validationType
            
            if ($status) {
                Write-DateLog "Successfully downloaded $($Tool.name)"
                return $true
            }
            else {
                Write-DateLog "No update needed for $($Tool.name)"
                return $false
            }
        }
        catch {
            Write-DateLog "ERROR: Failed to download $($Tool.name): $_"
            return $false
        }
    }
    else {
        Write-DateLog "ERROR: Invalid HTTP source configuration for $($Tool.name)"
        return $false
    }
}

# Function to download via WinGet
function Get-WinGetTool {
    param (
        [Parameter(Mandatory=$true)]
        [PSObject]$Tool
    )
    
    $id = $Tool.source.id
    $destPath = Resolve-VariablePath $Tool.destination.path
    $destFileName = Split-Path $destPath -Leaf
    $validationType = $Tool.validation.type
    
    Write-DateLog "Downloading WinGet: $($Tool.name) with ID $id"
    
    try {
        $tmpFileName = "$id*.exe"
        if ($destFileName -like "*.msi") {
            $tmpFileName = "$id*.msi"
        }
        
        $status = Get-WinGet -AppName $id -TmpFileName $tmpFileName -DownloadName $destFileName -check $validationType
        
        if ($status) {
            Write-DateLog "Successfully downloaded $($Tool.name)"
            return $true
        }
        else {
            Write-DateLog "No update needed for $($Tool.name)"
            return $false
        }
    }
    catch {
        Write-DateLog "ERROR: Failed to download $($Tool.name): $_"
        return $false
    }
}

# Function to download Didier Stevens tools
function Get-DidierTool {
    param (
        [Parameter(Mandatory=$true)]
        [PSObject]$Tool
    )
    
    # Didier tools are handled differently - we'll need to call the dedicated function
    Write-DateLog "Downloading Didier Stevens tools"
    
    try {
        & ".\resources\download\didier.ps1"
        Write-DateLog "Successfully downloaded Didier Stevens tools"
        return $true
    }
    catch {
        Write-DateLog "ERROR: Failed to download Didier Stevens tools: $_"
        return $false
    }
}

# Function to download VS Code Extension
function Get-VSCodeExtension {
    param (
        [Parameter(Mandatory=$true)]
        [PSObject]$Tool
    )
    
    $url = $Tool.source.url
    $pattern = $Tool.source.pattern
    $destPath = Resolve-VariablePath $Tool.destination.path
    $validationType = $Tool.validation.type
    
    Write-DateLog "Downloading VS Code Extension: $($Tool.name)"
    
    try {
        # Extract version from the marketplace page
        $versionStr = Get-DownloadUrlFromPage -url $url -RegEx $pattern
        
        if (!$versionStr) {
            Write-DateLog "ERROR: Failed to extract version for $($Tool.name)"
            return $false
        }
        
        $versionMatch = $versionStr | Select-String -Pattern $pattern
        $version = $versionMatch.Matches.Groups[1].Value
        
        # Build the download URL
        $downloadUrl = $Tool.source.download_url_template -replace '\{version\}', $version
        
        # Download the extension
        $status = Get-FileFromUri -uri $downloadUrl -FilePath $destPath -CheckURL "Yes" -check $validationType
        
        if ($status) {
            Write-DateLog "Successfully downloaded $($Tool.name)"
            return $true
        }
        else {
            Write-DateLog "No update needed for $($Tool.name)"
            return $false
        }
    }
    catch {
        Write-DateLog "ERROR: Failed to download $($Tool.name): $_"
        return $false
    }
}

# Function to resolve variables in path
function Resolve-VariablePath {
    param (
        [string]$Path
    )
    
    $result = $Path
    
    # Replace standard variables
    $result = $result -replace '\${SETUP_PATH}', $SETUP_PATH
    $result = $result -replace '\${TOOLS}', $TOOLS
    $result = $result -replace '\${SANDBOX_TOOLS}', $SANDBOX_TOOLS
    
    return $result
}

# Function to execute post-download actions
function Invoke-PostDownloadActions {
    param (
        [Parameter(Mandatory=$true)]
        [PSObject]$Tool
    )
    
    if (!$Tool.post_download -or $NoPostProcessing) {
        return
    }
    
    Write-DateLog "Executing post-download actions for $($Tool.name)"
    
    foreach ($action in $Tool.post_download) {
        $actionType = $action.action
        
        try {
            switch ($actionType) {
                "extract" {
                    $source = Resolve-VariablePath $action.source
                    $destination = Resolve-VariablePath $action.destination
                    
                    Write-DateLog "Extracting $source to $destination"
                    
                    if (!(Test-Path $destination)) {
                        New-Item -ItemType Directory -Force -Path $destination | Out-Null
                    }
                    
                    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$source" -o"$destination" | Out-Null
                }
                "move" {
                    $source = Resolve-VariablePath $action.source
                    $destination = Resolve-VariablePath $action.destination
                    
                    Write-DateLog "Moving $source to $destination"
                    
                    $sourcePath = Resolve-Path $source -ErrorAction SilentlyContinue
                    if ($sourcePath) {
                        Move-Item -Path $sourcePath -Destination $destination -Force
                    }
                    else {
                        Write-DateLog "WARNING: Source path not found for move action: $source"
                    }
                }
                "copy" {
                    $source = Resolve-VariablePath $action.source
                    $destination = Resolve-VariablePath $action.destination
                    
                    Write-DateLog "Copying $source to $destination"
                    
                    $sourcePath = Resolve-Path $source -ErrorAction SilentlyContinue
                    if ($sourcePath) {
                        Copy-Item -Path $sourcePath -Destination $destination -Force -Recurse
                    }
                    else {
                        Write-DateLog "WARNING: Source path not found for copy action: $source"
                    }
                }
                "delete" {
                    $path = Resolve-VariablePath $action.path
                    
                    Write-DateLog "Deleting $path"
                    
                    if (Test-Path $path) {
                        Remove-Item -Path $path -Force -Recurse
                    }
                }
                "rename" {
                    $source = Resolve-VariablePath $action.source
                    $destination = Resolve-VariablePath $action.destination
                    
                    Write-DateLog "Renaming $source to $destination"
                    
                    Rename-Item -Path $source -NewName $destination -Force
                }
                "create_directory" {
                    $path = Resolve-VariablePath $action.path
                    
                    Write-DateLog "Creating directory $path"
                    
                    if (!(Test-Path $path)) {
                        New-Item -ItemType Directory -Force -Path $path | Out-Null
                    }
                }
                "run_script" {
                    $script = $action.script
                    $args = $action.args
                    
                    Write-DateLog "Running script $script with args $($args -join ' ')"
                    
                    & $script $args
                }
                default {
                    Write-DateLog "WARNING: Unknown post-download action: $actionType"
                }
            }
        }
        catch {
            Write-DateLog "ERROR: Failed to execute $actionType action for $($Tool.name): $_"
        }
    }
}

#endregion Download Functions

#region Main Download Logic

$processedTools = @{}

# Sort tools by dependencies
$sortedTools = @()
$pendingTools = @($filteredTools)
$iteration = 0
$maxIterations = 10  # Prevent infinite loops from circular dependencies

while ($pendingTools.Count -gt 0 -and $iteration -lt $maxIterations) {
    $iteration++
    $remainingTools = @()
    
    foreach ($tool in $pendingTools) {
        $dependenciesSatisfied = $true
        
        if ($tool.dependencies) {
            foreach ($dep in $tool.dependencies) {
                if (-not $processedTools.ContainsKey($dep)) {
                    $dependenciesSatisfied = $false
                    break
                }
            }
        }
        
        if ($dependenciesSatisfied) {
            $sortedTools += $tool
            $processedTools[$tool.name] = $true
        }
        else {
            $remainingTools += $tool
        }
    }
    
    $pendingTools = $remainingTools
}

# Add any remaining tools (due to circular dependencies or missing dependencies)
$sortedTools += $pendingTools

Write-DateLog "Starting download of $($sortedTools.Count) tools"

foreach ($tool in $sortedTools) {
    Write-Progress -Activity "Downloading Tools" -Status "$($downloadedTools + $skippedTools + $failedTools) of $totalTools completed" -PercentComplete (($downloadedTools + $skippedTools + $failedTools) / $totalTools * 100)
    
    $status = $false
    
    try {
        # Call appropriate download function based on tool type
        switch ($tool.type) {
            "github" {
                $status = Get-GitHubReleaseTool -Tool $tool
            }
            "http" {
                $status = Get-HttpTool -Tool $tool
            }
            "winget" {
                $status = Get-WinGetTool -Tool $tool
            }
            "didier" {
                $status = Get-DidierTool -Tool $tool
            }
            "vscode-extension" {
                $status = Get-VSCodeExtension -Tool $tool
            }
            default {
                Write-DateLog "ERROR: Unknown tool type for $($tool.name): $($tool.type)"
                $failedTools++
                continue
            }
        }
        
        # Execute post-download actions if download was successful
        if ($status) {
            $downloadedTools++
            Invoke-PostDownloadActions -Tool $tool
        }
        else {
            $skippedTools++
        }
    }
    catch {
        Write-DateLog "ERROR: Failed to process tool $($tool.name): $_"
        $failedTools++
    }
}

#endregion Main Download Logic

#region Special Handlers

# Handle special categories
if ($Enrichment) {
    Write-DateLog "Processing enrichment data"
    & ".\resources\download\enrichment.ps1"
}

if ($Freshclam) {
    Write-DateLog "Updating ClamAV databases with freshclam"
    & ".\resources\download\freshclam.ps1"
}

if ($LogBoost) {
    Write-DateLog "Updating Threat Intel for LogBoost"
    & ".\resources\download\logboost.ps1"
}

if ($Verify) {
    Write-DateLog "Verifying downloaded tools"
    & ".\resources\download\verify.ps1" -WorkingDirectory $PWD\resources\download
}

#endregion Special Handlers

#region Cleanup and Summary

# Create done.txt to track last update in sandbox
Write-Output "" > ".\downloads\done.txt"

# Clean up temporary files
$tempDirs = @(
    ".\tmp\downloads\"
    ".\tmp\enrichment"
    ".\tmp\mount\"
    ".\tmp\msys2\"
)

foreach ($dir in $tempDirs) {
    if (Test-Path $dir) {
        Remove-Item -Recurse -Force $dir -ErrorAction SilentlyContinue | Out-Null
    }
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
Write-Progress -Activity "Downloading Tools" -Completed

Write-DateLog "Download Summary:"
Write-DateLog "- Total tools: $totalTools"
Write-DateLog "- Downloaded: $downloadedTools"
Write-DateLog "- Skipped (already up to date): $skippedTools"
Write-DateLog "- Failed: $failedTools"

if ($warnings -or $errors -or $failed) {
    Write-DateLog "Errors or warnings were found in log files. Please check the log files for details."
}
else {
    Write-DateLog "Downloads and preparations completed successfully."
}

#endregion Cleanup and Summary
