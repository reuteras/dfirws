# DFIRWS Tool Installation Orchestrator
# Uses the new modular tool handler system with parallel downloads
# Version: 1.0

param(
    [Parameter(HelpMessage = "Install all tools")]
    [Switch]$All,

    [Parameter(HelpMessage = "Install tools by category")]
    [ValidateSet("forensics", "malware-analysis", "utilities", "network-analysis", "reverse-engineering", "memory-forensics", "data-analysis", "windows-forensics", "disk-forensics", "document-analysis", "email-forensics", "threat-intelligence", "active-directory")]
    [string]$Category,

    [Parameter(HelpMessage = "Install tools by priority")]
    [ValidateSet("critical", "high", "medium", "low")]
    [string]$Priority,

    [Parameter(HelpMessage = "Enable parallel downloads")]
    [Switch]$Parallel,

    [Parameter(HelpMessage = "Number of parallel jobs (default: 5)")]
    [int]$ThrottleLimit = 5,

    [Parameter(HelpMessage = "Resume from previous installation")]
    [Switch]$Resume,

    [Parameter(HelpMessage = "Dry run - show what would be done")]
    [Switch]$DryRun,

    [Parameter(HelpMessage = "Show statistics from last installation")]
    [Switch]$Statistics,

    # Version Management Parameters
    [Parameter(HelpMessage = "Check for available updates")]
    [Switch]$CheckUpdates,

    [Parameter(HelpMessage = "List available updates with details")]
    [Switch]$ListUpdates,

    [Parameter(HelpMessage = "Approve update for specific tools")]
    [string[]]$ApproveUpdate,

    [Parameter(HelpMessage = "Approve all available updates")]
    [Switch]$ApproveAllUpdates,

    [Parameter(HelpMessage = "Install approved updates")]
    [Switch]$InstallUpdates,

    [Parameter(HelpMessage = "Force reinstallation even if version matches")]
    [Switch]$Force,

    [Parameter(HelpMessage = "Ignore version pins and always install latest")]
    [Switch]$IgnoreVersions,

    [Parameter(HelpMessage = "Validate SHA256 checksums during installation")]
    [Switch]$ValidateChecksums,

    [Parameter(HelpMessage = "Clear version check cache")]
    [Switch]$ClearCache,

    [Parameter(HelpMessage = "Show installed versions")]
    [Switch]$ShowVersions
)

# Import modules
. ".\resources\download\common.ps1"
. ".\resources\download\tool-handler.ps1"
. ".\resources\download\state-manager.ps1"
. ".\resources\download\version-manager.ps1"

#region Main Installation Logic

function Install-Tools {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Tools,

        [Parameter(Mandatory=$false)]
        [bool]$UseParallel = $false,

        [Parameter(Mandatory=$false)]
        [int]$Throttle = 5
    )

    $sessionId = (Get-Date).ToString("yyyyMMdd-HHmmss")
    Initialize-InstallationState -SessionId $sessionId

    # Update total tools count
    Update-InstallationState -Updates @{ total_tools = $Tools.Count }

    Write-DateLog "Starting installation of $($Tools.Count) tools (Session: $sessionId)"

    if ($UseParallel) {
        Write-DateLog "Using parallel downloads (ThrottleLimit: $Throttle)"
        Install-ToolsParallel -Tools $Tools -ThrottleLimit $Throttle
    } else {
        Write-DateLog "Using sequential downloads"
        Install-ToolsSequential -Tools $Tools
    }

    Complete-InstallationState
    Show-InstallationSummary
}

function Install-ToolsSequential {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Tools
    )

    foreach ($tool in $Tools) {
        Set-InProgressTool -ToolName $tool.name

        try {
            # Install tool with optional SHA256 validation
            $installParams = @{
                ToolDefinition = $tool
                DryRun = $DryRun
            }

            if ($ValidateChecksums) {
                $installParams.ValidateChecksum = $true
            }

            $result = Install-ToolFromDefinition @installParams

            if ($result) {
                Add-CompletedTool -ToolName $tool.name

                # Update version lock on successful installation
                if (-not $DryRun) {
                    Update-ToolVersionLock -Tool $tool -Result $result
                }
            } else {
                Add-FailedTool -ToolName $tool.name -Error "Installation returned false"
            }
        } catch {
            Add-FailedTool -ToolName $tool.name -Error $_.Exception.Message
        }
    }
}

function Install-ToolsParallel {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Tools,

        [Parameter(Mandatory=$true)]
        [int]$ThrottleLimit
    )

    # Group tools by priority for better ordering
    $priorityOrder = @("critical", "high", "medium", "low")
    $sortedTools = $Tools | Sort-Object { $priorityOrder.IndexOf($_.priority) }

    # Create script block for parallel execution
    $scriptBlock = {
        param($tool, $setupPath, $toolsPath, $ghUser, $ghPass, $dryRun, $validateChecksums)

        # Import necessary functions in the runspace
        . ".\resources\download\common.ps1"
        . ".\resources\download\tool-handler.ps1"
        . ".\resources\download\version-manager.ps1"

        # Set global variables
        $global:SETUP_PATH = $setupPath
        $global:TOOLS = $toolsPath
        $global:GH_USER = $ghUser
        $global:GH_PASS = $ghPass

        try {
            # Install tool with optional SHA256 validation
            $installParams = @{
                ToolDefinition = $tool
                DryRun = $dryRun
            }

            if ($validateChecksums) {
                $installParams.ValidateChecksum = $true
            }

            $result = Install-ToolFromDefinition @installParams

            return @{
                name = $tool.name
                tool = $tool
                success = $result
                error = $null
            }
        } catch {
            return @{
                name = $tool.name
                tool = $tool
                success = $false
                error = $_.Exception.Message
            }
        }
    }

    # Use PowerShell 7+ parallel if available
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        Write-DateLog "Using PowerShell 7+ parallel foreach"

        $results = $sortedTools | ForEach-Object -Parallel {
            $tool = $_
            & $using:scriptBlock -tool $tool -setupPath $using:SETUP_PATH -toolsPath $using:TOOLS -ghUser $using:GH_USER -ghPass $using:GH_PASS -dryRun $using:DryRun -validateChecksums $using:ValidateChecksums
        } -ThrottleLimit $ThrottleLimit

        # Process results
        foreach ($result in $results) {
            if ($result.success) {
                Add-CompletedTool -ToolName $result.name

                # Update version lock on successful installation
                if (-not $DryRun) {
                    Update-ToolVersionLock -Tool $result.tool -Result $result.success
                }
            } else {
                Add-FailedTool -ToolName $result.name -Error $result.error
            }
        }
    } else {
        # Fallback to jobs for PowerShell 5.1
        Write-DateLog "Using PowerShell jobs (consider upgrading to PowerShell 7+ for better performance)"

        $jobs = @()
        $activeJobs = 0

        foreach ($tool in $sortedTools) {
            # Wait if we've hit the throttle limit
            while ($activeJobs -ge $ThrottleLimit) {
                $completed = Get-Job -State Completed
                if ($completed) {
                    foreach ($job in $completed) {
                        $result = Receive-Job -Job $job
                        Remove-Job -Job $job

                        if ($result.success) {
                            Add-CompletedTool -ToolName $result.name

                            # Update version lock on successful installation
                            if (-not $DryRun) {
                                Update-ToolVersionLock -Tool $result.tool -Result $result.success
                            }
                        } else {
                            Add-FailedTool -ToolName $result.name -Error $result.error
                        }

                        $activeJobs--
                    }
                } else {
                    Start-Sleep -Milliseconds 500
                }
            }

            # Start new job
            Set-InProgressTool -ToolName $tool.name

            $job = Start-Job -ScriptBlock $scriptBlock -ArgumentList $tool, $SETUP_PATH, $TOOLS, $GH_USER, $GH_PASS, $DryRun, $ValidateChecksums
            $jobs += $job
            $activeJobs++
        }

        # Wait for remaining jobs
        $jobs | Wait-Job | Receive-Job | ForEach-Object {
            if ($_.success) {
                Add-CompletedTool -ToolName $_.name

                # Update version lock on successful installation
                if (-not $DryRun) {
                    Update-ToolVersionLock -Tool $_.tool -Result $_.success
                }
            } else {
                Add-FailedTool -ToolName $_.name -Error $_.error
            }
        }

        $jobs | Remove-Job
    }
}

function Update-ToolVersionLock {
    <#
    .SYNOPSIS
        Update version lock after successful tool installation
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Tool,

        [Parameter(Mandatory=$true)]
        $Result
    )

    try {
        # Determine version from tool definition
        $version = if ($Tool.version) {
            $Tool.version
        } else {
            # Try to get latest version for GitHub sources
            if ($Tool.source -eq "github") {
                $latest = Get-LatestGitHubVersion -Repo $Tool.repo
                if ($latest) {
                    $latest.version
                } else {
                    "unknown"
                }
            } else {
                "unknown"
            }
        }

        # Get SHA256 if available (from tool definition or calculate if needed)
        $sha256 = if ($Tool.sha256) {
            $Tool.sha256
        } else {
            $null
        }

        # Update version lock
        Update-VersionLock `
            -ToolName $Tool.name `
            -Version $version `
            -SHA256 $sha256 `
            -Source $Tool.source `
            -Repo $(if ($Tool.repo) { $Tool.repo } else { $null }) `
            -DownloadUrl $(if ($Tool.url) { $Tool.url } else { $null })

    } catch {
        Write-Warning "Failed to update version lock for $($Tool.name): $_"
    }
}

#endregion

#region Main Script

#region Version Management Handlers

# Clear cache
if ($ClearCache) {
    Clear-VersionCache
    Write-DateLog "Version check cache cleared"
    exit 0
}

# Show installed versions
if ($ShowVersions) {
    $lock = Get-VersionLock
    if (-not $lock.tools -or $lock.tools.PSObject.Properties.Count -eq 0) {
        Write-Output "`nNo tools installed yet`n"
    } else {
        Write-Output "`n========================================"
        Write-Output "   Installed Tool Versions"
        Write-Output "========================================`n"

        $lock.tools.PSObject.Properties | Sort-Object Name | ForEach-Object {
            $toolName = $_.Name
            $info = $_.Value
            Write-Output "📦 $toolName"
            Write-Output "   Version:       $($info.version)"
            Write-Output "   Installed:     $($info.installed_date)"
            Write-Output "   Source:        $($info.source)"
            if ($info.repo) {
                Write-Output "   Repository:    $($info.repo)"
            }
            Write-Output ""
        }
        Write-Output "========================================`n"
    }
    exit 0
}

# Check for updates
if ($CheckUpdates -or $ListUpdates) {
    Write-DateLog "Checking for available updates..."
    Initialize-VersionLock | Out-Null

    # Load all tools to check
    $tools = Get-EnabledTools

    $updates = Get-AvailableUpdates -Tools $tools
    Show-AvailableUpdates -Updates $updates

    if ($updates.Count -gt 0) {
        Write-Output "To approve updates:"
        Write-Output "  Single tool:  .\install-tools.ps1 -ApproveUpdate <tool-name>"
        Write-Output "  Multiple:     .\install-tools.ps1 -ApproveUpdate <tool1>,<tool2>"
        Write-Output "  All updates:  .\install-tools.ps1 -ApproveAllUpdates"
        Write-Output ""
        Write-Output "To install approved updates:"
        Write-Output "  .\install-tools.ps1 -InstallUpdates [-Parallel]"
        Write-Output ""
    }

    exit 0
}

# Approve specific updates
if ($ApproveUpdate) {
    Approve-Update -ToolNames $ApproveUpdate
    Write-Output ""
    Write-Output "To install approved updates, run:"
    Write-Output "  .\install-tools.ps1 -InstallUpdates [-Parallel]"
    Write-Output ""
    exit 0
}

# Approve all updates
if ($ApproveAllUpdates) {
    Write-DateLog "Approving all available updates..."

    $tools = Get-EnabledTools
    $updates = Get-AvailableUpdates -Tools $tools

    if ($updates.Count -eq 0) {
        Write-Output "No updates available to approve"
    } else {
        $toolNames = $updates | ForEach-Object { $_.tool.name }
        Approve-Update -ToolNames $toolNames

        Write-Output ""
        Write-Output "To install approved updates, run:"
        Write-Output "  .\install-tools.ps1 -InstallUpdates [-Parallel]"
        Write-Output ""
    }

    exit 0
}

# Install approved updates
if ($InstallUpdates) {
    Write-DateLog "Installing approved updates..."

    # Load all tools
    $allTools = Get-EnabledTools

    # Filter to only approved tools
    $tools = $allTools | Where-Object { Test-UpdateApproved -ToolName $_.name }

    if (-not $tools -or $tools.Count -eq 0) {
        Write-Output "No approved updates to install"
        Write-Output ""
        Write-Output "To check for updates and approve them:"
        Write-Output "  .\install-tools.ps1 -CheckUpdates"
        Write-Output "  .\install-tools.ps1 -ApproveUpdate <tool-name>"
        Write-Output ""
        exit 0
    }

    Write-DateLog "Installing $($tools.Count) approved updates"

    # Clear approvals after loading tools to install
    Clear-UpdateApprovals

    # Proceed to installation (below)
}

#endregion

# Handle statistics display
if ($Statistics) {
    Show-InstallationSummary
    exit 0
}

# Load tools
Write-DateLog "Loading tool definitions..."

if ($Category) {
    Write-DateLog "Loading tools from category: $Category"
    $tools = Get-ToolsByCategory -Category $Category
} elseif ($Priority) {
    Write-DateLog "Loading tools with priority: $Priority"
    $tools = Get-ToolsByPriority -Priority $Priority
} else {
    Write-DateLog "Loading all enabled tools"
    $tools = Get-EnabledTools
}

if (-not $tools -or $tools.Count -eq 0) {
    Write-DateLog "No tools found to install"
    exit 0
}

Write-DateLog "Found $($tools.Count) tools to process"

# Handle resume
if ($Resume) {
    Write-DateLog "Resume mode enabled, filtering already completed tools"
    $tools = Get-RemainingTools -AllTools $tools

    if (-not $tools -or $tools.Count -eq 0) {
        Write-DateLog "All tools already completed"
        Show-InstallationSummary
        exit 0
    }

    Write-DateLog "Resuming with $($tools.Count) remaining tools"
}

# Install tools
if ($DryRun) {
    Write-Output "`n=== DRY RUN MODE ==="
    Write-Output "The following tools would be installed:"
    foreach ($tool in $tools) {
        Write-Output "  - $($tool.name) ($($tool.category), priority: $($tool.priority))"
    }
    Write-Output "===================`n"
} else {
    Install-Tools -Tools $tools -UseParallel:$Parallel -Throttle $ThrottleLimit
}

#endregion
