# DFIRWS Tool Installation Orchestrator
# Uses the new modular tool handler system with parallel downloads
# Version: 1.0

param(
    [Parameter(HelpMessage = "Install all tools")]
    [Switch]$All,

    [Parameter(HelpMessage = "Install tools by category")]
    [ValidateSet("forensics", "malware-analysis", "utilities", "network-analysis")]
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
    [Switch]$Statistics
)

# Import modules
. ".\resources\download\common.ps1"
. ".\resources\download\tool-handler.ps1"
. ".\resources\download\state-manager.ps1"

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
            $result = Install-ToolFromDefinition -ToolDefinition $tool -DryRun:$DryRun

            if ($result) {
                Add-CompletedTool -ToolName $tool.name
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
        param($tool, $setupPath, $toolsPath, $ghUser, $ghPass, $dryRun)

        # Import necessary functions in the runspace
        . ".\resources\download\common.ps1"
        . ".\resources\download\tool-handler.ps1"

        # Set global variables
        $global:SETUP_PATH = $setupPath
        $global:TOOLS = $toolsPath
        $global:GH_USER = $ghUser
        $global:GH_PASS = $ghPass

        try {
            $result = Install-ToolFromDefinition -ToolDefinition $tool -DryRun:$dryRun

            return @{
                name = $tool.name
                success = $result
                error = $null
            }
        } catch {
            return @{
                name = $tool.name
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
            & $using:scriptBlock -tool $tool -setupPath $using:SETUP_PATH -toolsPath $using:TOOLS -ghUser $using:GH_USER -ghPass $using:GH_PASS -dryRun $using:DryRun
        } -ThrottleLimit $ThrottleLimit

        # Process results
        foreach ($result in $results) {
            if ($result.success) {
                Add-CompletedTool -ToolName $result.name
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

            $job = Start-Job -ScriptBlock $scriptBlock -ArgumentList $tool, $SETUP_PATH, $TOOLS, $GH_USER, $GH_PASS, $DryRun
            $jobs += $job
            $activeJobs++
        }

        # Wait for remaining jobs
        $jobs | Wait-Job | Receive-Job | ForEach-Object {
            if ($_.success) {
                Add-CompletedTool -ToolName $_.name
            } else {
                Add-FailedTool -ToolName $_.name -Error $_.error
            }
        }

        $jobs | Remove-Job
    }
}

#endregion

#region Main Script

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
