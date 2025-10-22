# Centralized logging module for DFIRWS
# Provides structured logging with different log levels

# Log levels
enum LogLevel {
    DEBUG = 0
    INFO = 1
    WARNING = 2
    ERROR = 3
    CRITICAL = 4
}

# Global logging configuration
$Script:LoggingConfig = @{
    MinimumLevel = [LogLevel]::INFO
    LogToFile = $true
    LogToConsole = $true
    DefaultLogFile = ".\log\log.txt"
    IncludeTimestamp = $true
    IncludeLevel = $true
    IncludeCallerInfo = $false
}

<#
.SYNOPSIS
    Initializes the logging system with custom configuration.

.DESCRIPTION
    Sets up the logging system with the specified minimum log level and output options.

.PARAMETER MinimumLevel
    The minimum log level to output (DEBUG, INFO, WARNING, ERROR, CRITICAL).

.PARAMETER LogToFile
    Whether to write logs to a file.

.PARAMETER LogToConsole
    Whether to write logs to the console.

.PARAMETER DefaultLogFile
    The default log file path.

.EXAMPLE
    Initialize-Logging -MinimumLevel INFO -LogToFile $true
#>
function Initialize-Logging {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [LogLevel]$MinimumLevel = [LogLevel]::INFO,

        [Parameter(Mandatory=$false)]
        [bool]$LogToFile = $true,

        [Parameter(Mandatory=$false)]
        [bool]$LogToConsole = $true,

        [Parameter(Mandatory=$false)]
        [string]$DefaultLogFile = ".\log\log.txt",

        [Parameter(Mandatory=$false)]
        [bool]$IncludeCallerInfo = $false
    )

    $Script:LoggingConfig.MinimumLevel = $MinimumLevel
    $Script:LoggingConfig.LogToFile = $LogToFile
    $Script:LoggingConfig.LogToConsole = $LogToConsole
    $Script:LoggingConfig.DefaultLogFile = $DefaultLogFile
    $Script:LoggingConfig.IncludeCallerInfo = $IncludeCallerInfo

    # Ensure log directory exists
    $logDir = Split-Path -Path $DefaultLogFile -Parent
    if ($logDir -and !(Test-Path -Path $logDir)) {
        try {
            New-Item -ItemType Directory -Force -Path $logDir -ErrorAction Stop | Out-Null
        } catch {
            Write-Warning "Failed to create log directory: $logDir"
        }
    }
}

<#
.SYNOPSIS
    Writes a log message with the specified level.

.DESCRIPTION
    Writes a structured log message to the console and/or file based on configuration.

.PARAMETER Level
    The log level (DEBUG, INFO, WARNING, ERROR, CRITICAL).

.PARAMETER Message
    The message to log.

.PARAMETER Exception
    Optional exception object to include in the log.

.PARAMETER LogFile
    Optional custom log file path (overrides default).

.EXAMPLE
    Write-Log -Level INFO -Message "Starting download process"

.EXAMPLE
    Write-Log -Level ERROR -Message "Failed to download file" -Exception $_.Exception
#>
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [LogLevel]$Level,

        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [System.Exception]$Exception = $null,

        [Parameter(Mandatory=$false)]
        [string]$LogFile = ""
    )

    # Check if this log level should be output
    if ($Level -lt $Script:LoggingConfig.MinimumLevel) {
        return
    }

    # Build the log message
    $logParts = @()

    if ($Script:LoggingConfig.IncludeTimestamp) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
        $logParts += $timestamp
    }

    if ($Script:LoggingConfig.IncludeLevel) {
        $levelString = $Level.ToString().PadRight(8)
        $logParts += "[$levelString]"
    }

    if ($Script:LoggingConfig.IncludeCallerInfo) {
        $caller = (Get-PSCallStack)[1]
        if ($caller) {
            $callerInfo = "$($caller.Command):$($caller.ScriptLineNumber)"
            $logParts += "[$callerInfo]"
        }
    }

    $logParts += $Message

    # Add exception details if provided
    if ($Exception) {
        $logParts += "`n    Exception: $($Exception.GetType().FullName)"
        $logParts += "`n    Message: $($Exception.Message)"
        if ($Exception.StackTrace) {
            $logParts += "`n    StackTrace: $($Exception.StackTrace)"
        }
        if ($Exception.InnerException) {
            $logParts += "`n    InnerException: $($Exception.InnerException.Message)"
        }
    }

    $fullMessage = $logParts -join " "

    # Output to console with color coding
    if ($Script:LoggingConfig.LogToConsole) {
        $color = switch ($Level) {
            ([LogLevel]::DEBUG) { "Gray" }
            ([LogLevel]::INFO) { "White" }
            ([LogLevel]::WARNING) { "Yellow" }
            ([LogLevel]::ERROR) { "Red" }
            ([LogLevel]::CRITICAL) { "Magenta" }
            default { "White" }
        }
        Write-Host $fullMessage -ForegroundColor $color
    }

    # Output to file
    if ($Script:LoggingConfig.LogToFile) {
        $targetLogFile = if ($LogFile) { $LogFile } else { $Script:LoggingConfig.DefaultLogFile }

        # Use mutex for thread-safe file writing
        $logMutex = New-Object -TypeName 'System.Threading.Mutex' -ArgumentList $false, 'Global\dfirwsLogMutex'

        try {
            $null = $logMutex.WaitOne()
            Add-Content -Path $targetLogFile -Value $fullMessage -ErrorAction SilentlyContinue
        } catch {
            Write-Warning "Failed to write to log file: $targetLogFile"
        } finally {
            $null = $logMutex.ReleaseMutex()
        }
    }
}

<#
.SYNOPSIS
    Convenience function for DEBUG level logging.

.PARAMETER Message
    The message to log.

.PARAMETER LogFile
    Optional custom log file path.

.EXAMPLE
    Write-DebugLog "Processing item $i of $total"
#>
function Write-DebugLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [string]$LogFile = ""
    )

    Write-Log -Level ([LogLevel]::DEBUG) -Message $Message -LogFile $LogFile
}

<#
.SYNOPSIS
    Convenience function for INFO level logging.

.PARAMETER Message
    The message to log.

.PARAMETER LogFile
    Optional custom log file path.

.EXAMPLE
    Write-InfoLog "Download completed successfully"
#>
function Write-InfoLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [string]$LogFile = ""
    )

    Write-Log -Level ([LogLevel]::INFO) -Message $Message -LogFile $LogFile
}

<#
.SYNOPSIS
    Convenience function for WARNING level logging.

.PARAMETER Message
    The message to log.

.PARAMETER LogFile
    Optional custom log file path.

.EXAMPLE
    Write-WarningLog "File already exists, skipping download"
#>
function Write-WarningLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [string]$LogFile = ""
    )

    Write-Log -Level ([LogLevel]::WARNING) -Message $Message -LogFile $LogFile
}

<#
.SYNOPSIS
    Convenience function for ERROR level logging.

.PARAMETER Message
    The message to log.

.PARAMETER Exception
    Optional exception object.

.PARAMETER LogFile
    Optional custom log file path.

.EXAMPLE
    Write-ErrorLog "Failed to connect to server" -Exception $_.Exception
#>
function Write-ErrorLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [System.Exception]$Exception = $null,

        [Parameter(Mandatory=$false)]
        [string]$LogFile = ""
    )

    Write-Log -Level ([LogLevel]::ERROR) -Message $Message -Exception $Exception -LogFile $LogFile
}

<#
.SYNOPSIS
    Convenience function for CRITICAL level logging.

.PARAMETER Message
    The message to log.

.PARAMETER Exception
    Optional exception object.

.PARAMETER LogFile
    Optional custom log file path.

.EXAMPLE
    Write-CriticalLog "System failure, cannot continue" -Exception $_.Exception
#>
function Write-CriticalLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [System.Exception]$Exception = $null,

        [Parameter(Mandatory=$false)]
        [string]$LogFile = ""
    )

    Write-Log -Level ([LogLevel]::CRITICAL) -Message $Message -Exception $Exception -LogFile $LogFile
}

# Backward compatibility - map old functions to new logging system
function Write-DateLog {
    param (
        [Parameter(Mandatory=$True)]
        [string]$Message
    )
    Write-InfoLog -Message $Message
}

function Write-SynchronizedLog {
    param (
        [Parameter(Mandatory=$True)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [string]$LogFile = ".\log\log.txt"
    )
    Write-InfoLog -Message $Message -LogFile $LogFile
}

# Initialize with default settings
Initialize-Logging

# Export functions
Export-ModuleMember -Function @(
    'Initialize-Logging',
    'Write-Log',
    'Write-DebugLog',
    'Write-InfoLog',
    'Write-WarningLog',
    'Write-ErrorLog',
    'Write-CriticalLog',
    'Write-DateLog',
    'Write-SynchronizedLog'
)
