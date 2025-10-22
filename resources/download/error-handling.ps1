# Centralized error handling module for DFIRWS
# Provides retry logic, error handling patterns, and utilities

# Ensure logging module is available
if (Test-Path "$PSScriptRoot\logging.ps1") {
    . "$PSScriptRoot\logging.ps1"
}

# Constants
Set-Variable -Name DEFAULT_MAX_RETRIES -Value 3 -Option Constant
Set-Variable -Name DEFAULT_INITIAL_DELAY_SECONDS -Value 2 -Option Constant
Set-Variable -Name DEFAULT_MAX_DELAY_SECONDS -Value 60 -Option Constant
Set-Variable -Name DEFAULT_BACKOFF_MULTIPLIER -Value 2 -Option Constant

<#
.SYNOPSIS
    Invokes a script block with retry logic and exponential backoff.

.DESCRIPTION
    Executes the provided script block and retries on failure with exponential backoff.
    Useful for network operations, file operations, and other transient failures.

.PARAMETER ScriptBlock
    The script block to execute.

.PARAMETER MaxRetries
    Maximum number of retry attempts (default: 3).

.PARAMETER InitialDelaySeconds
    Initial delay in seconds before first retry (default: 2).

.PARAMETER MaxDelaySeconds
    Maximum delay in seconds between retries (default: 60).

.PARAMETER BackoffMultiplier
    Multiplier for exponential backoff (default: 2).

.PARAMETER RetryableExceptions
    Array of exception types that should trigger a retry. If not specified, all exceptions trigger retries.

.PARAMETER OnRetry
    Optional script block to execute before each retry. Receives retry count as parameter.

.EXAMPLE
    Invoke-WithRetry -ScriptBlock { Download-File $url } -MaxRetries 5

.EXAMPLE
    Invoke-WithRetry -ScriptBlock {
        Invoke-WebRequest $url
    } -MaxRetries 3 -OnRetry {
        param($retryCount)
        Write-InfoLog "Retry attempt $retryCount"
    }
#>
function Invoke-WithRetry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [scriptblock]$ScriptBlock,

        [Parameter(Mandatory=$false)]
        [int]$MaxRetries = $DEFAULT_MAX_RETRIES,

        [Parameter(Mandatory=$false)]
        [int]$InitialDelaySeconds = $DEFAULT_INITIAL_DELAY_SECONDS,

        [Parameter(Mandatory=$false)]
        [int]$MaxDelaySeconds = $DEFAULT_MAX_DELAY_SECONDS,

        [Parameter(Mandatory=$false)]
        [double]$BackoffMultiplier = $DEFAULT_BACKOFF_MULTIPLIER,

        [Parameter(Mandatory=$false)]
        [Type[]]$RetryableExceptions = @(),

        [Parameter(Mandatory=$false)]
        [scriptblock]$OnRetry = $null
    )

    $attempt = 0
    $delay = $InitialDelaySeconds
    $lastException = $null

    while ($attempt -le $MaxRetries) {
        try {
            $attempt++
            if ($attempt -gt 1) {
                Write-DebugLog "Attempt $attempt of $($MaxRetries + 1)"
            }

            # Execute the script block and return result
            $result = & $ScriptBlock
            return $result
        }
        catch {
            $lastException = $_.Exception

            # Check if this exception type is retryable
            $shouldRetry = $true
            if ($RetryableExceptions.Count -gt 0) {
                $shouldRetry = $false
                foreach ($retryableType in $RetryableExceptions) {
                    if ($lastException -is $retryableType) {
                        $shouldRetry = $true
                        break
                    }
                }
            }

            # If not retryable or out of retries, throw
            if (-not $shouldRetry) {
                Write-DebugLog "Exception type $($lastException.GetType().FullName) is not retryable"
                throw
            }

            if ($attempt -gt $MaxRetries) {
                Write-ErrorLog "Maximum retry attempts ($MaxRetries) exceeded" -Exception $lastException
                throw
            }

            # Log the retry
            Write-WarningLog "Operation failed (attempt $attempt/$($MaxRetries + 1)): $($lastException.Message). Retrying in $delay seconds..."

            # Execute OnRetry callback if provided
            if ($OnRetry) {
                & $OnRetry $attempt
            }

            # Wait before retrying
            Start-Sleep -Seconds $delay

            # Calculate next delay with exponential backoff
            $delay = [Math]::Min($delay * $BackoffMultiplier, $MaxDelaySeconds)
        }
    }

    # Should not reach here, but just in case
    throw $lastException
}

<#
.SYNOPSIS
    Safely removes a file or directory with proper error handling.

.DESCRIPTION
    Attempts to remove a file or directory with error handling and logging.

.PARAMETER Path
    The path to remove.

.PARAMETER Recurse
    Whether to recursively remove directories.

.PARAMETER Force
    Force removal of read-only items.

.EXAMPLE
    Remove-ItemSafe -Path "C:\temp\file.txt"

.EXAMPLE
    Remove-ItemSafe -Path "C:\temp\directory" -Recurse -Force
#>
function Remove-ItemSafe {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$false)]
        [switch]$Recurse,

        [Parameter(Mandatory=$false)]
        [switch]$Force
    )

    if (-not (Test-Path -Path $Path)) {
        Write-DebugLog "Path does not exist, skipping removal: $Path"
        return $true
    }

    try {
        $params = @{
            Path = $Path
            ErrorAction = 'Stop'
        }

        if ($Recurse) { $params['Recurse'] = $true }
        if ($Force) { $params['Force'] = $true }

        if ($PSCmdlet.ShouldProcess($Path, "Remove item")) {
            Remove-Item @params
            Write-DebugLog "Successfully removed: $Path"
            return $true
        }
    }
    catch {
        Write-ErrorLog "Failed to remove item: $Path" -Exception $_.Exception
        return $false
    }
}

<#
.SYNOPSIS
    Safely creates a directory with proper error handling.

.DESCRIPTION
    Creates a directory if it doesn't exist, with error handling and logging.

.PARAMETER Path
    The directory path to create.

.PARAMETER Force
    Create parent directories if they don't exist.

.EXAMPLE
    New-DirectorySafe -Path "C:\temp\newdir"
#>
function New-DirectorySafe {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$false)]
        [switch]$Force
    )

    if (Test-Path -Path $Path) {
        Write-DebugLog "Directory already exists: $Path"
        return $true
    }

    try {
        if ($PSCmdlet.ShouldProcess($Path, "Create directory")) {
            $params = @{
                ItemType = 'Directory'
                Path = $Path
                ErrorAction = 'Stop'
            }

            if ($Force) { $params['Force'] = $true }

            New-Item @params | Out-Null
            Write-DebugLog "Successfully created directory: $Path"
            return $true
        }
    }
    catch {
        Write-ErrorLog "Failed to create directory: $Path" -Exception $_.Exception
        return $false
    }
}

<#
.SYNOPSIS
    Safely copies a file with proper error handling.

.DESCRIPTION
    Copies a file with error handling, validation, and logging.

.PARAMETER Source
    The source file path.

.PARAMETER Destination
    The destination file path.

.PARAMETER Force
    Overwrite destination if it exists.

.EXAMPLE
    Copy-ItemSafe -Source "C:\source\file.txt" -Destination "C:\dest\file.txt"
#>
function Copy-ItemSafe {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Source,

        [Parameter(Mandatory=$true)]
        [string]$Destination,

        [Parameter(Mandatory=$false)]
        [switch]$Force
    )

    if (-not (Test-Path -Path $Source)) {
        Write-ErrorLog "Source file does not exist: $Source"
        return $false
    }

    try {
        # Ensure destination directory exists
        $destDir = Split-Path -Path $Destination -Parent
        if ($destDir -and -not (Test-Path -Path $destDir)) {
            New-DirectorySafe -Path $destDir -Force | Out-Null
        }

        if ($PSCmdlet.ShouldProcess($Source, "Copy to $Destination")) {
            $params = @{
                Path = $Source
                Destination = $Destination
                ErrorAction = 'Stop'
            }

            if ($Force) { $params['Force'] = $true }

            Copy-Item @params
            Write-DebugLog "Successfully copied: $Source -> $Destination"
            return $true
        }
    }
    catch {
        Write-ErrorLog "Failed to copy file: $Source -> $Destination" -Exception $_.Exception
        return $false
    }
}

<#
.SYNOPSIS
    Validates required tools are available in PATH.

.DESCRIPTION
    Checks if required executables are available and logs errors if not found.

.PARAMETER Tools
    Array of tool names to validate.

.PARAMETER ThrowOnMissing
    Throw an exception if any tool is missing.

.EXAMPLE
    Test-RequiredTools -Tools @("git.exe", "7z.exe", "rclone.exe")

.EXAMPLE
    Test-RequiredTools -Tools @("git.exe") -ThrowOnMissing
#>
function Test-RequiredTools {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Tools,

        [Parameter(Mandatory=$false)]
        [switch]$ThrowOnMissing
    )

    $allFound = $true
    $missingTools = @()

    foreach ($tool in $Tools) {
        $command = Get-Command $tool -ErrorAction SilentlyContinue
        if (-not $command) {
            Write-ErrorLog "Required tool not found: $tool"
            $missingTools += $tool
            $allFound = $false
        } else {
            Write-DebugLog "Found required tool: $tool at $($command.Source)"
        }
    }

    if (-not $allFound) {
        $errorMessage = "Missing required tools: $($missingTools -join ', '). Please install them and add to PATH."
        if ($ThrowOnMissing) {
            throw $errorMessage
        } else {
            Write-ErrorLog $errorMessage
        }
    }

    return $allFound
}

<#
.SYNOPSIS
    Validates configuration values.

.DESCRIPTION
    Checks if required configuration values are set and valid.

.PARAMETER Config
    Hashtable of configuration values to validate.

.PARAMETER RequiredKeys
    Array of required configuration keys.

.EXAMPLE
    Test-Configuration -Config @{GITHUB_TOKEN="abc123"} -RequiredKeys @("GITHUB_TOKEN")
#>
function Test-Configuration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$Config,

        [Parameter(Mandatory=$true)]
        [string[]]$RequiredKeys
    )

    $allValid = $true

    foreach ($key in $RequiredKeys) {
        if (-not $Config.ContainsKey($key)) {
            Write-ErrorLog "Missing required configuration key: $key"
            $allValid = $false
        } elseif ([string]::IsNullOrWhiteSpace($Config[$key])) {
            Write-ErrorLog "Configuration key has empty value: $key"
            $allValid = $false
        } else {
            Write-DebugLog "Configuration key validated: $key"
        }
    }

    return $allValid
}

<#
.SYNOPSIS
    Wraps a command execution with error handling and logging.

.DESCRIPTION
    Executes a command and provides detailed logging of success or failure.

.PARAMETER Command
    The command name.

.PARAMETER Arguments
    Array of arguments for the command.

.PARAMETER Description
    Human-readable description of what the command does.

.EXAMPLE
    Invoke-CommandSafe -Command "git" -Arguments @("status") -Description "Check git status"
#>
function Invoke-CommandSafe {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Command,

        [Parameter(Mandatory=$false)]
        [string[]]$Arguments = @(),

        [Parameter(Mandatory=$false)]
        [string]$Description = "Execute command"
    )

    try {
        Write-DebugLog "$Description : $Command $($Arguments -join ' ')"

        $result = & $Command @Arguments 2>&1

        if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
            Write-ErrorLog "$Description failed with exit code $LASTEXITCODE"
            return @{
                Success = $false
                ExitCode = $LASTEXITCODE
                Output = $result
            }
        }

        Write-DebugLog "$Description completed successfully"
        return @{
            Success = $true
            ExitCode = 0
            Output = $result
        }
    }
    catch {
        Write-ErrorLog "$Description failed" -Exception $_.Exception
        return @{
            Success = $false
            ExitCode = -1
            Output = $null
            Exception = $_.Exception
        }
    }
}

# Export functions
Export-ModuleMember -Function @(
    'Invoke-WithRetry',
    'Remove-ItemSafe',
    'New-DirectorySafe',
    'Copy-ItemSafe',
    'Test-RequiredTools',
    'Test-Configuration',
    'Invoke-CommandSafe'
)
