# Error Handling and Logging Improvements

This document describes the error handling and logging improvements implemented in the dfirws codebase.

## Overview

The improvements focus on:
1. **Structured logging** with different log levels (DEBUG, INFO, WARNING, ERROR, CRITICAL)
2. **Centralized error handling** with retry logic and exponential backoff
3. **Security improvements** by eliminating command injection vulnerabilities
4. **Better error messages** with context and remediation steps
5. **Consistent error handling patterns** across the codebase

## New Modules

### 1. logging.ps1

Located in `resources/download/logging.ps1`, this module provides:

- **Structured logging** with log levels: DEBUG, INFO, WARNING, ERROR, CRITICAL
- **Thread-safe logging** using mutex for concurrent operations
- **Console and file logging** with configurable output
- **Colored console output** for better readability
- **Exception logging** with stack traces

#### Usage Examples

```powershell
# Initialize logging (optional, has sensible defaults)
Initialize-Logging -MinimumLevel INFO -LogToFile $true

# Use convenience functions
Write-InfoLog "Starting download process"
Write-WarningLog "File already exists, skipping"
Write-ErrorLog "Failed to download file" -Exception $_.Exception
Write-DebugLog "Processing item $i of $total"
```

#### Backward Compatibility

The module includes backward-compatible versions of existing functions:
- `Write-DateLog` → Maps to `Write-InfoLog`
- `Write-SynchronizedLog` → Maps to `Write-InfoLog`

### 2. error-handling.ps1

Located in `resources/download/error-handling.ps1`, this module provides:

#### Functions

**Invoke-WithRetry**
- Executes operations with retry logic and exponential backoff
- Configurable retry count, initial delay, and backoff multiplier
- Optional retry callbacks for custom handling

```powershell
# Retry a download operation
Invoke-WithRetry -ScriptBlock {
    Download-File $url
} -MaxRetries 5 -InitialDelaySeconds 2

# With custom retry callback
Invoke-WithRetry -ScriptBlock {
    Invoke-WebRequest $url
} -OnRetry {
    param($retryCount)
    Write-InfoLog "Retry attempt $retryCount"
}
```

**Remove-ItemSafe**
- Safely removes files/directories with proper error handling
- Logs success and failures

```powershell
Remove-ItemSafe -Path "C:\temp\file.txt" -Force
Remove-ItemSafe -Path "C:\temp\directory" -Recurse -Force
```

**New-DirectorySafe**
- Creates directories with error handling
- Skips if already exists (idempotent)

```powershell
New-DirectorySafe -Path "C:\tools\bin" -Force
```

**Copy-ItemSafe**
- Copies files with validation and error handling
- Creates destination directory if needed

```powershell
Copy-ItemSafe -Source "C:\source\file.txt" -Destination "C:\dest\file.txt" -Force
```

**Test-RequiredTools**
- Validates that required executables are in PATH
- Optional exception throwing on missing tools

```powershell
Test-RequiredTools -Tools @("git.exe", "7z.exe", "rclone.exe") -ThrowOnMissing
```

**Test-Configuration**
- Validates configuration hashtables
- Checks for required keys and non-empty values

```powershell
$config = @{GITHUB_TOKEN="abc123"}
Test-Configuration -Config $config -RequiredKeys @("GITHUB_TOKEN")
```

**Invoke-CommandSafe**
- Wraps command execution with error handling
- Returns structured result with success status

```powershell
$result = Invoke-CommandSafe -Command "git" -Arguments @("status") -Description "Check git status"
if ($result.Success) {
    Write-Host $result.Output
}
```

## Security Improvements

### Command Injection Prevention

**Before:**
```powershell
$COMMAND_LINE = $CMD + " " + $FLAGS -join " "
Invoke-Expression $COMMAND_LINE  # ⚠️ DANGEROUS - Command injection risk
```

**After:**
```powershell
# Build safe argument array
$curlArgs = @()
$curlArgs += "-L"
$curlArgs += "--silent"
$curlArgs += $Uri

# Execute safely with parameter array
& "C:\Windows\system32\curl.exe" @curlArgs  # ✅ SAFE
```

## Changes to Existing Files

### common.ps1

1. **Module loading**: Added imports for logging.ps1 and error-handling.ps1
2. **Security fix**: Replaced `Invoke-Expression` with safe parameter passing
3. **Directory operations**: Updated to use `New-DirectorySafe`
4. **File removal**: Updated `Clear-Tmp` to use `Remove-ItemSafe`

### downloadFiles.ps1

1. **Module loading**: Added imports for new modules
2. **Tool validation**: Replaced manual checks with `Test-RequiredTools`
3. **Directory creation**: Simplified with loop and `New-DirectorySafe`
4. **Cleanup**: Improved temp file cleanup with `Remove-ItemSafe`
5. **Debug mode**: Added log level configuration for debug mode

## Migration Guide

### For Existing Scripts

To use the new modules in existing scripts:

```powershell
# At the top of your script
if (Test-Path ".\resources\download\logging.ps1") {
    . ".\resources\download\logging.ps1"
}
if (Test-Path ".\resources\download\error-handling.ps1") {
    . ".\resources\download\error-handling.ps1"
}

# Replace manual retry logic
# Before:
$retries = 3
while ($retries -gt 0) {
    try {
        DoSomething
        break
    } catch {
        $retries--
        Start-Sleep 10
    }
}

# After:
Invoke-WithRetry -ScriptBlock { DoSomething } -MaxRetries 3
```

### Logging Migration

```powershell
# Replace:
Write-DateLog "Starting process"

# With:
Write-InfoLog "Starting process"

# For errors:
# Before:
Write-DateLog "Error: Failed to download"

# After:
Write-ErrorLog "Failed to download" -Exception $_.Exception
```

## Benefits

1. **Improved Reliability**
   - Automatic retry logic with exponential backoff
   - Consistent error handling across all operations

2. **Better Debugging**
   - Structured logs with severity levels
   - Exception details with stack traces
   - Debug mode for detailed logging

3. **Enhanced Security**
   - Eliminated command injection vulnerabilities
   - Safe parameter passing for external commands

4. **Maintainability**
   - Centralized error handling logic
   - Reusable functions reduce code duplication
   - Consistent patterns across the codebase

5. **Better User Experience**
   - Clear error messages with context
   - Colored console output
   - Remediation suggestions in error messages

## Configuration

### Logging Configuration

```powershell
# Set minimum log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
Initialize-Logging -MinimumLevel DEBUG

# Enable debug mode for detailed output
Initialize-Logging -MinimumLevel DEBUG -LogToFile $true -LogToConsole $true

# Customize log file location
Initialize-Logging -DefaultLogFile "C:\custom\path\log.txt"
```

### Retry Configuration

```powershell
# Customize retry behavior
Invoke-WithRetry `
    -ScriptBlock { Download-File } `
    -MaxRetries 5 `
    -InitialDelaySeconds 2 `
    -MaxDelaySeconds 60 `
    -BackoffMultiplier 2
```

## Testing

To test the improvements:

1. **Test logging levels:**
   ```powershell
   Initialize-Logging -MinimumLevel DEBUG
   Write-DebugLog "This should appear"
   Initialize-Logging -MinimumLevel INFO
   Write-DebugLog "This should not appear"
   ```

2. **Test retry logic:**
   ```powershell
   $attempts = 0
   Invoke-WithRetry -ScriptBlock {
       $attempts++
       if ($attempts -lt 3) { throw "Simulated failure" }
       Write-Host "Success on attempt $attempts"
   } -MaxRetries 3
   ```

3. **Test safe operations:**
   ```powershell
   New-DirectorySafe -Path "C:\test\newdir" -Force
   Copy-ItemSafe -Source "source.txt" -Destination "C:\test\newdir\dest.txt"
   Remove-ItemSafe -Path "C:\test\newdir" -Recurse -Force
   ```

## Future Improvements

Potential enhancements for future consideration:

1. **Telemetry**: Add metrics collection for monitoring
2. **Structured logging formats**: Support JSON logging for machine parsing
3. **Log rotation**: Implement automatic log file rotation
4. **Circuit breaker**: Add circuit breaker pattern for repeated failures
5. **Performance metrics**: Track execution time for operations
6. **Error recovery**: Implement automatic recovery for common errors

## Backward Compatibility

All changes maintain backward compatibility:
- Existing logging functions are mapped to new implementations
- Module loading is optional (graceful degradation)
- Existing scripts continue to work without modification
- New features are opt-in

## Support

For questions or issues:
- Review the function help: `Get-Help Write-Log -Full`
- Check examples in this document
- Review the source code comments in the modules
