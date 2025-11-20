# DFIRWS State Management Module
# Provides functions to track installation state and enable resume capability
# Version: 1.0

$script:STATE_FILE = ".\downloads\installation-state.json"
$script:ERROR_LOG_FILE = ".\log\tool-errors.json"

#region State Management

function Initialize-InstallationState {
    <#
    .SYNOPSIS
        Initialize a new installation state
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$SessionId
    )

    $state = @{
        session_id = $SessionId
        start_time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        end_time = $null
        status = "in_progress"
        total_tools = 0
        completed_tools = @()
        failed_tools = @()
        skipped_tools = @()
        in_progress = $null
        last_updated = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }

    $state | ConvertTo-Json -Depth 10 | Set-Content $script:STATE_FILE
    Write-Output "Initialized installation state: $SessionId"
    return $state
}

function Get-InstallationState {
    <#
    .SYNOPSIS
        Load the current installation state
    #>
    if (Test-Path $script:STATE_FILE) {
        try {
            $state = Get-Content $script:STATE_FILE | ConvertFrom-Json
            return $state
        } catch {
            Write-Warning "Failed to load state file, creating new state"
            return $null
        }
    }
    return $null
}

function Update-InstallationState {
    <#
    .SYNOPSIS
        Update the installation state
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Updates
    )

    $state = Get-InstallationState

    if (-not $state) {
        Write-Error "No active installation state found"
        return
    }

    # Update fields
    foreach ($key in $Updates.Keys) {
        $state.$key = $Updates[$key]
    }

    # Always update last_updated timestamp
    $state.last_updated = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

    # Save state
    $state | ConvertTo-Json -Depth 10 | Set-Content $script:STATE_FILE
}

function Add-CompletedTool {
    <#
    .SYNOPSIS
        Mark a tool as completed
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ToolName,

        [Parameter(Mandatory=$false)]
        [string]$Version = "unknown"
    )

    $state = Get-InstallationState

    if (-not $state) {
        Write-Warning "No active state to update"
        return
    }

    # Convert from PSCustomObject to hashtable for modification
    $stateHash = @{}
    $state.PSObject.Properties | ForEach-Object { $stateHash[$_.Name] = $_.Value }

    $completedTools = @($stateHash.completed_tools)
    $completedTools += @{
        name = $ToolName
        version = $Version
        completed_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }

    $stateHash.completed_tools = $completedTools
    $stateHash.in_progress = $null

    Update-InstallationState -Updates $stateHash
    Write-SynchronizedLog "Marked as completed: $ToolName"
}

function Add-FailedTool {
    <#
    .SYNOPSIS
        Mark a tool as failed
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ToolName,

        [Parameter(Mandatory=$true)]
        [string]$Error
    )

    $state = Get-InstallationState

    if (-not $state) {
        Write-Warning "No active state to update"
        return
    }

    # Convert from PSCustomObject to hashtable for modification
    $stateHash = @{}
    $state.PSObject.Properties | ForEach-Object { $stateHash[$_.Name] = $_.Value }

    $failedTools = @($stateHash.failed_tools)
    $failedTools += @{
        name = $ToolName
        error = $Error
        failed_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }

    $stateHash.failed_tools = $failedTools
    $stateHash.in_progress = $null

    Update-InstallationState -Updates $stateHash

    # Also log to error file
    Write-ToolError -ToolName $ToolName -Error $Error
    Write-SynchronizedLog "Marked as failed: $ToolName - $Error"
}

function Set-InProgressTool {
    <#
    .SYNOPSIS
        Mark a tool as currently in progress
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ToolName
    )

    Update-InstallationState -Updates @{
        in_progress = @{
            name = $ToolName
            started_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }
    }

    Write-SynchronizedLog "Started: $ToolName"
}

function Complete-InstallationState {
    <#
    .SYNOPSIS
        Mark the installation as complete
    #>
    $state = Get-InstallationState

    if (-not $state) {
        return
    }

    Update-InstallationState -Updates @{
        status = "completed"
        end_time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        in_progress = $null
    }

    Write-SynchronizedLog "Installation session completed"
}

function Get-RemainingTools {
    <#
    .SYNOPSIS
        Get tools that haven't been completed yet
    #>
    param(
        [Parameter(Mandatory=$true)]
        [array]$AllTools
    )

    $state = Get-InstallationState

    if (-not $state) {
        # No state, all tools are remaining
        return $AllTools
    }

    $completedNames = $state.completed_tools | ForEach-Object { $_.name }

    return $AllTools | Where-Object { $_.name -notin $completedNames }
}

#endregion

#region Error Logging

function Write-ToolError {
    <#
    .SYNOPSIS
        Write structured error information to log
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ToolName,

        [Parameter(Mandatory=$true)]
        [string]$Error,

        [Parameter(Mandatory=$false)]
        [hashtable]$Context = @{}
    )

    $errorEntry = @{
        tool = $ToolName
        error = $Error
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        context = $Context
    }

    # Append to error log file
    if (Test-Path $script:ERROR_LOG_FILE) {
        $errors = Get-Content $script:ERROR_LOG_FILE | ConvertFrom-Json
        $errors = @($errors) + $errorEntry
    } else {
        $errors = @($errorEntry)
    }

    $errors | ConvertTo-Json -Depth 10 | Set-Content $script:ERROR_LOG_FILE
}

function Get-ToolErrors {
    <#
    .SYNOPSIS
        Get all tool errors from the log
    #>
    if (Test-Path $script:ERROR_LOG_FILE) {
        return Get-Content $script:ERROR_LOG_FILE | ConvertFrom-Json
    }
    return @()
}

#endregion

#region Statistics and Reporting

function Get-InstallationStatistics {
    <#
    .SYNOPSIS
        Get statistics about the installation
    #>
    $state = Get-InstallationState

    if (-not $state) {
        Write-Output "No installation state found"
        return
    }

    $completedCount = ($state.completed_tools | Measure-Object).Count
    $failedCount = ($state.failed_tools | Measure-Object).Count
    $skippedCount = ($state.skipped_tools | Measure-Object).Count

    $stats = @{
        session_id = $state.session_id
        status = $state.status
        start_time = $state.start_time
        end_time = $state.end_time
        total_tools = $state.total_tools
        completed = $completedCount
        failed = $failedCount
        skipped = $skippedCount
        remaining = $state.total_tools - $completedCount - $failedCount - $skippedCount
        success_rate = if ($state.total_tools -gt 0) {
            [math]::Round(($completedCount / $state.total_tools) * 100, 2)
        } else { 0 }
    }

    return $stats
}

function Show-InstallationSummary {
    <#
    .SYNOPSIS
        Display a summary of the installation
    #>
    $stats = Get-InstallationStatistics

    if (-not $stats) {
        return
    }

    Write-Output "`n========================================="
    Write-Output "   DFIRWS Installation Summary"
    Write-Output "========================================="
    Write-Output "Session ID    : $($stats.session_id)"
    Write-Output "Status        : $($stats.status)"
    Write-Output "Start Time    : $($stats.start_time)"
    if ($stats.end_time) {
        Write-Output "End Time      : $($stats.end_time)"
    }
    Write-Output "-----------------------------------------"
    Write-Output "Total Tools   : $($stats.total_tools)"
    Write-Output "Completed     : $($stats.completed) ($('{0:N2}' -f $stats.success_rate)%)"
    Write-Output "Failed        : $($stats.failed)"
    Write-Output "Skipped       : $($stats.skipped)"
    Write-Output "Remaining     : $($stats.remaining)"
    Write-Output "=========================================`n"

    # Show failed tools if any
    $state = Get-InstallationState
    if ($state.failed_tools -and ($state.failed_tools | Measure-Object).Count -gt 0) {
        Write-Output "`nFailed Tools:"
        foreach ($failed in $state.failed_tools) {
            Write-Output "  - $($failed.name): $($failed.error)"
        }
        Write-Output ""
    }
}

#endregion

# Note: Export-ModuleMember removed - this script is dot-sourced, not imported as a module
# Functions are automatically available when dot-sourced
