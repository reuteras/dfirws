# DFIRWS Tool Handler Module
# Provides functions to install tools based on YAML definitions
# Version: 1.0

# Requires the powershell-yaml module for YAML parsing
# Install with: Install-Module -Name powershell-yaml -Force

$script:TOOLS_DEFINITIONS_PATH = ".\resources\tools"

# Import common functions
. ".\resources\download\common.ps1"

#region YAML Parsing

function Import-ToolDefinitions {
    <#
    .SYNOPSIS
        Import tool definitions from YAML files

    .PARAMETER Category
        Specific category to import (forensics, malware-analysis, etc.)
        If not specified, imports all categories

    .PARAMETER Path
        Path to the tools definitions directory
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$Category,

        [Parameter(Mandatory=$false)]
        [string]$Path = $script:TOOLS_DEFINITIONS_PATH
    )

    $allTools = @()

    if ($Category) {
        $yamlFiles = Get-ChildItem -Path $Path -Filter "${Category}.yaml"
    } else {
        $yamlFiles = Get-ChildItem -Path $Path -Filter "*.yaml"
    }

    foreach ($file in $yamlFiles) {
        try {
            Write-SynchronizedLog "Loading tool definitions from $($file.Name)"

            # Try to use powershell-yaml module if available
            if (Get-Module -ListAvailable -Name powershell-yaml) {
                Import-Module powershell-yaml -ErrorAction SilentlyContinue
                $content = Get-Content -Path $file.FullName -Raw
                $definition = ConvertFrom-Yaml -Yaml $content

                # Add category info to each tool and fix escape sequences
                foreach ($tool in $definition.tools) {
                    $tool | Add-Member -NotePropertyName "category" -NotePropertyValue $definition.category -Force

                    # Fix escape sequences in string properties (especially match patterns)
                    foreach ($prop in $tool.PSObject.Properties) {
                        if ($prop.Value -is [string]) {
                            $fixedValue = $prop.Value -replace '\\\\', '\'  # Convert \\ to \
                            $fixedValue = $fixedValue -replace '\\n', "`n"  # Convert \n to newline
                            $fixedValue = $fixedValue -replace '\\t', "`t"  # Convert \t to tab
                            $tool.$($prop.Name) = $fixedValue
                        }
                    }

                    $allTools += $tool
                }
            } else {
                # Fallback: Simple YAML parser for our specific format
                $content = Get-Content -Path $file.FullName
                $currentTool = $null
                $inTools = $false
                $categoryName = ""

                foreach ($line in $content) {
                    $line = $line.TrimStart()

                    if ($line -match "^category:\s*(.+)") {
                        $categoryName = $matches[1]
                        continue
                    }

                    if ($line -eq "tools:") {
                        $inTools = $true
                        continue
                    }

                    if ($inTools) {
                        if ($line -match "^\s*-\s*name:\s*(.+)") {
                            # Save previous tool if exists
                            if ($currentTool) {
                                $currentTool.category = $categoryName
                                $allTools += $currentTool
                            }
                            # Start new tool
                            $currentTool = [PSCustomObject]@{
                                name = $matches[1]
                                category = $categoryName
                            }
                        } elseif ($currentTool -and $line -match "^\s*(\w+):\s*(.+)") {
                            $key = $matches[1]
                            $value = $matches[2].Trim('"').Trim("'")
                            # Handle YAML escape sequences
                            $value = $value -replace '\\\\', '\'  # Convert \\ to \
                            $value = $value -replace '\\n', "`n"  # Convert \n to newline
                            $value = $value -replace '\\t', "`t"  # Convert \t to tab
                            $currentTool | Add-Member -NotePropertyName $key -NotePropertyValue $value -Force
                        }
                    }
                }

                # Add last tool
                if ($currentTool) {
                    $currentTool.category = $categoryName
                    $allTools += $currentTool
                }
            }
        } catch {
            Write-Error "Failed to parse $($file.Name): $_"
        }
    }

    Write-SynchronizedLog "Loaded $($allTools.Count) tool definitions"
    return $allTools
}

#endregion

#region Tool Installation

function Install-ToolFromDefinition {
    <#
    .SYNOPSIS
        Install a tool based on its YAML definition

    .PARAMETER ToolDefinition
        Tool definition object from YAML

    .PARAMETER DryRun
        If specified, only show what would be done without actually doing it

    .PARAMETER ValidateChecksum
        If specified, validate SHA256 checksum after download

    .PARAMETER DownloadOnly
        If specified, only download the tool without installing it
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$ToolDefinition,

        [Parameter(Mandatory=$false)]
        [switch]$DryRun,

        [Parameter(Mandatory=$false)]
        [switch]$ValidateChecksum,

        [Parameter(Mandatory=$false)]
        [switch]$DownloadOnly
    )

    $toolName = $ToolDefinition.name

    # Check if tool is enabled
    if ($ToolDefinition.enabled -eq $false -or $ToolDefinition.enabled -eq "false") {
        Write-SynchronizedLog "Tool '$toolName' is disabled, skipping"
        return $false
    }

    Write-SynchronizedLog "Processing tool: $toolName ($($ToolDefinition.category))"

    if ($DryRun) {
        Write-Output "[DRY RUN] Would install: $toolName"
        return $true
    }

    # Download the tool
    $downloaded = Get-ToolBinary -ToolDefinition $ToolDefinition -ValidateChecksum:$ValidateChecksum

    if (-not $downloaded) {
        Write-Error "Failed to download $toolName"
        return $false
    }

    # Determine if we should skip installation
    $installMethod = $ToolDefinition.install_method

    # In DownloadOnly mode, skip installer methods but still do extract/copy
    if ($DownloadOnly -and $installMethod -eq "installer") {
        Write-SynchronizedLog "Successfully downloaded: $toolName (download-only mode, skipping installer)"
        return $true
    }

    # Install the tool based on install method (extract, copy, or installer)
    $installed = Install-ToolBinary -ToolDefinition $ToolDefinition

    if (-not $installed) {
        Write-Error "Failed to install $toolName"
        return $false
    }

    # Run post-install steps (rename, copy, etc.) - needed even in DownloadOnly for extract/copy methods
    Invoke-PostInstallSteps -ToolDefinition $ToolDefinition

    if ($DownloadOnly) {
        Write-SynchronizedLog "Successfully prepared: $toolName (download-only mode)"
    } else {
        Write-SynchronizedLog "Successfully installed: $toolName"
    }
    return $true
}

function Get-ToolBinary {
    <#
    .SYNOPSIS
        Download the tool binary based on source type
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$ToolDefinition,

        [Parameter(Mandatory=$false)]
        [switch]$ValidateChecksum
    )

    $source = $ToolDefinition.source
    $toolName = $ToolDefinition.name

    # Determine file path
    $extension = switch ($ToolDefinition.file_type) {
        "zip" { ".zip" }
        "exe" { ".exe" }
        "msi" { ".msi" }
        "jar" { ".jar" }
        "war" { ".war" }
        default { "" }
    }

    $filePath = "${SETUP_PATH}\${toolName}${extension}"

    # Check if version pinning is specified
    $versionToInstall = if ($ToolDefinition.version -and $ToolDefinition.version -ne "latest") {
        $ToolDefinition.version
    } else {
        $null
    }

    try {
        # Convert file_type to file command output for validation
        $fileCheckString = switch ($ToolDefinition.file_type) {
            "zip" { "Zip archive data" }
            "exe" { "PE32" }
            "msi" { "Composite Document File V2 Document" }
            "jar" { "Java archive data" }
            "war" { "Java archive data" }
            default { "" }
        }

        switch ($source) {
            "github" {
                Write-SynchronizedLog "Downloading $toolName from GitHub: $($ToolDefinition.repo)"

                # Get version-specific release if pinned
                if ($versionToInstall) {
                    Write-SynchronizedLog "Using pinned version: $versionToInstall"
                    $status = Get-GitHubRelease `
                        -repo $ToolDefinition.repo `
                        -path $filePath `
                        -match $ToolDefinition.match `
                        -version $versionToInstall `
                        -check $fileCheckString
                } else {
                    $status = Get-GitHubRelease `
                        -repo $ToolDefinition.repo `
                        -path $filePath `
                        -match $ToolDefinition.match `
                        -check $fileCheckString
                }

                # Get-GitHubRelease returns false when file already exists (etag match)
                # Verify file actually exists regardless of download status
                if (-not (Test-Path $filePath)) {
                    Write-Error "Download failed and file does not exist: $filePath"
                    return $false
                }

                # Validate SHA256 if specified
                if ($ToolDefinition.sha256 -and $ValidateChecksum) {
                    Write-SynchronizedLog "Validating SHA256 checksum for $toolName"
                    $valid = Test-SHA256 -FilePath $filePath -ExpectedHash $ToolDefinition.sha256
                    if (-not $valid) {
                        Write-Error "SHA256 validation failed for $toolName"
                        return $false
                    }
                }

                return $true
            }

            "http" {
                Write-SynchronizedLog "Downloading $toolName from HTTP: $($ToolDefinition.url)"

                # Handle URL patterns (for dynamic URLs)
                if ($ToolDefinition.url_pattern) {
                    $url = Get-DownloadUrlFromPage `
                        -url $ToolDefinition.url_pattern `
                        -RegEx $ToolDefinition.match

                    if (-not $url) {
                        Write-Error "Could not determine download URL for $toolName"
                        return $false
                    }
                } else {
                    $url = $ToolDefinition.url
                }

                $status = Get-FileFromUri `
                    -uri $url `
                    -FilePath $filePath `
                    -check $fileCheckString

                # Get-FileFromUri returns false when file already exists (etag match)
                # Verify file actually exists regardless of download status
                if (-not (Test-Path $filePath)) {
                    Write-Error "Download failed and file does not exist: $filePath"
                    return $false
                }

                # Validate SHA256 if specified
                if ($ToolDefinition.sha256 -and $ValidateChecksum) {
                    Write-SynchronizedLog "Validating SHA256 checksum for $toolName"
                    $valid = Test-SHA256 -FilePath $filePath -ExpectedHash $ToolDefinition.sha256
                    if (-not $valid) {
                        Write-Error "SHA256 validation failed for $toolName"
                        return $false
                    }
                }

                return $true
            }

            "local" {
                Write-SynchronizedLog "Copying $toolName from local source"

                # Expected local file path (in .\local\ directory)
                $localFilePath = "${CONFIGURATION_FILES}\${toolName}${extension}"

                if (-not (Test-Path $localFilePath)) {
                    Write-Error "Local file not found: $localFilePath"
                    return $false
                }

                try {
                    Copy-Item -Path $localFilePath -Destination $filePath -Force
                    Write-SynchronizedLog "Copied $toolName from $localFilePath to $filePath"

                    # Validate SHA256 if specified
                    if ($ToolDefinition.sha256 -and $ValidateChecksum) {
                        Write-SynchronizedLog "Validating SHA256 checksum for $toolName"
                        $valid = Test-SHA256 -FilePath $filePath -ExpectedHash $ToolDefinition.sha256
                        if (-not $valid) {
                            Write-Error "SHA256 validation failed for $toolName"
                            return $false
                        }
                    }

                    return $true
                } catch {
                    Write-Error "Failed to copy local file: $_"
                    return $false
                }
            }

            default {
                Write-Error "Unknown source type: $source"
                return $false
            }
        }
    } catch {
        Write-Error "Error downloading $toolName : $_"
        return $false
    }
}

function Install-ToolBinary {
    <#
    .SYNOPSIS
        Install the downloaded tool binary
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$ToolDefinition
    )

    $toolName = $ToolDefinition.name
    $installMethod = $ToolDefinition.install_method

    # Determine source file path
    $extension = switch ($ToolDefinition.file_type) {
        "zip" { ".zip" }
        "exe" { ".exe" }
        "msi" { ".msi" }
        default { "" }
    }

    $sourcePath = "${SETUP_PATH}\${toolName}${extension}"

    if (-not (Test-Path $sourcePath)) {
        Write-Error "Source file not found: $sourcePath"
        return $false
    }

    try {
        switch ($installMethod) {
            "extract" {
                $extractTo = Expand-EnvironmentVariables -Path $ToolDefinition.extract_to

                Write-SynchronizedLog "Extracting $toolName to $extractTo"

                # Remove existing directory if it exists
                if (Test-Path $extractTo) {
                    Remove-Item -Recurse -Force $extractTo
                }

                # Extract
                & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa $sourcePath -o"$extractTo" | Out-Null

                return $true
            }

            "copy" {
                $copyTo = Expand-EnvironmentVariables -Path $ToolDefinition.copy_to
                $copyDir = Split-Path -Parent $copyTo

                Write-SynchronizedLog "Copying $toolName to $copyTo"

                # Ensure directory exists
                if (-not (Test-Path $copyDir)) {
                    New-Item -ItemType Directory -Path $copyDir -Force | Out-Null
                }

                Copy-Item $sourcePath $copyTo -Force

                return $true
            }

            "installer" {
                Write-SynchronizedLog "Installing $toolName via installer"

                $args = $ToolDefinition.installer_args
                if (-not $args) {
                    $args = "/quiet /norestart"
                }

                if ($extension -eq ".msi") {
                    Start-Process -Wait msiexec -ArgumentList "/i `"$sourcePath`" $args"
                } else {
                    Start-Process -Wait $sourcePath -ArgumentList $args
                }

                return $true
            }

            default {
                Write-Error "Unknown install method: $installMethod"
                return $false
            }
        }
    } catch {
        Write-Error "Error installing $toolName : $_"
        return $false
    }
}

function Invoke-PostInstallSteps {
    <#
    .SYNOPSIS
        Execute post-installation steps
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$ToolDefinition
    )

    if (-not $ToolDefinition.post_install) {
        return
    }

    $toolName = $ToolDefinition.name
    Write-SynchronizedLog "Running post-install steps for $toolName"

    foreach ($step in $ToolDefinition.post_install) {
        try {
            $stepType = $step.type

            switch ($stepType) {
                "rename" {
                    $pattern = Expand-EnvironmentVariables -Path $step.pattern
                    $target = Expand-EnvironmentVariables -Path $step.target

                    $items = Get-ChildItem -Path (Split-Path $pattern) -Filter (Split-Path -Leaf $pattern)
                    foreach ($item in $items) {
                        $newPath = Join-Path (Split-Path $item.FullName) $target
                        Move-Item $item.FullName $newPath -Force
                        Write-SynchronizedLog "Renamed: $($item.Name) -> $target"
                    }
                }

                "copy" {
                    $source = Expand-EnvironmentVariables -Path $step.source
                    $target = Expand-EnvironmentVariables -Path $step.target

                    Copy-Item $source $target -Force
                    Write-SynchronizedLog "Copied: $source -> $target"
                }

                "remove" {
                    $target = Expand-EnvironmentVariables -Path $step.target

                    if (Test-Path $target) {
                        Remove-Item $target -Recurse -Force
                        Write-SynchronizedLog "Removed: $target"
                    }
                }

                "add_to_path" {
                    $pathToAdd = Expand-EnvironmentVariables -Path $step.path
                    # Note: This would need to be implemented in the sandbox startup script
                    Write-SynchronizedLog "Mark for PATH: $pathToAdd"
                }

                default {
                    Write-Warning "Unknown post-install step type: $stepType"
                }
            }
        } catch {
            Write-Warning "Post-install step failed for $toolName : $_"
        }
    }
}

function Expand-EnvironmentVariables {
    <#
    .SYNOPSIS
        Expand environment variables in paths
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    # Get variables from the caller's scope hierarchy
    # Using Get-Variable without -Scope walks up the scope chain
    try {
        $toolsPath = Get-Variable -Name TOOLS -ValueOnly -Scope Global -ErrorAction Stop
    } catch {
        $toolsPath = ".\mount\Tools"
        Write-SynchronizedLog "WARNING: TOOLS variable not found in global scope, using default: $toolsPath"
    }

    try {
        $setupPath = Get-Variable -Name SETUP_PATH -ValueOnly -Scope Global -ErrorAction Stop
    } catch {
        $setupPath = ".\downloads"
        Write-SynchronizedLog "WARNING: SETUP_PATH variable not found in global scope, using default: $setupPath"
    }

    try {
        $sandboxTools = Get-Variable -Name SANDBOX_TOOLS -ValueOnly -Scope Global -ErrorAction Stop
    } catch {
        $sandboxTools = "C:\Tools"
        Write-SynchronizedLog "WARNING: SANDBOX_TOOLS variable not found in global scope, using default: $sandboxTools"
    }

    # Log the values for debugging
    Write-SynchronizedLog "Variable expansion: TOOLS='$toolsPath', SETUP_PATH='$setupPath', SANDBOX_TOOLS='$sandboxTools'"
    Write-SynchronizedLog "Expanding path: $Path"

    # Replace common variables
    $expanded = $Path -replace '\$\{TOOLS\}', [regex]::Escape($toolsPath)
    $expanded = $expanded -replace '\$\{SETUP_PATH\}', [regex]::Escape($setupPath)
    $expanded = $expanded -replace '\$\{SANDBOX_TOOLS\}', [regex]::Escape($sandboxTools)

    Write-SynchronizedLog "Expanded to: $expanded"

    return $expanded
}

#endregion

#region Filtering and Selection

function Get-ToolsByCategory {
    <#
    .SYNOPSIS
        Get tools filtered by category
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Category
    )

    $tools = Import-ToolDefinitions
    return $tools | Where-Object { $_.category -eq $Category }
}

function Get-ToolsByPriority {
    <#
    .SYNOPSIS
        Get tools filtered by priority
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Priority
    )

    $tools = Import-ToolDefinitions
    return $tools | Where-Object { $_.priority -eq $Priority }
}

function Get-EnabledTools {
    <#
    .SYNOPSIS
        Get only enabled tools
    #>
    $tools = Import-ToolDefinitions
    return $tools | Where-Object { $_.enabled -ne $false -and $_.enabled -ne "false" }
}

#endregion

# Note: Export-ModuleMember removed - this script is dot-sourced, not imported as a module
# Functions are automatically available when dot-sourced
