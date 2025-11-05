# DFIRWS Version Management Module
# Provides version pinning, SHA256 validation, and update management
# Version: 1.0

$script:VERSION_LOCK_FILE = ".\downloads\tool-versions.lock.json"
$script:UPDATE_APPROVALS_FILE = ".\downloads\update-approvals.json"
$script:UPDATE_CHECK_CACHE = ".\downloads\.update-cache.json"
$script:CACHE_EXPIRY_HOURS = 6

#region Version Lock Management

function Initialize-VersionLock {
    <#
    .SYNOPSIS
        Initialize or load the version lock file
    #>

    if (Test-Path $script:VERSION_LOCK_FILE) {
        try {
            $lock = Get-Content $script:VERSION_LOCK_FILE | ConvertFrom-Json
            return $lock
        } catch {
            Write-Warning "Failed to load version lock file, creating new one"
        }
    }

    # Create new lock file
    $lock = @{
        schema_version = "1.0"
        last_updated = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        tools = @{}
    }

    $lock | ConvertTo-Json -Depth 10 | Set-Content $script:VERSION_LOCK_FILE
    return $lock
}

function Get-VersionLock {
    <#
    .SYNOPSIS
        Get the current version lock
    #>

    if (Test-Path $script:VERSION_LOCK_FILE) {
        return Get-Content $script:VERSION_LOCK_FILE | ConvertFrom-Json
    }

    return Initialize-VersionLock
}

function Update-VersionLock {
    <#
    .SYNOPSIS
        Update the version lock file with tool information
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ToolName,

        [Parameter(Mandatory=$true)]
        [string]$Version,

        [Parameter(Mandatory=$false)]
        [string]$SHA256,

        [Parameter(Mandatory=$false)]
        [string]$DownloadUrl,

        [Parameter(Mandatory=$false)]
        [string]$Source,

        [Parameter(Mandatory=$false)]
        [string]$Repo
    )

    $lock = Get-VersionLock

    # Convert PSCustomObject to hashtable for modification
    $lockHash = @{
        schema_version = $lock.schema_version
        last_updated = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        tools = @{}
    }

    # Copy existing tools
    if ($lock.tools) {
        $lock.tools.PSObject.Properties | ForEach-Object {
            $lockHash.tools[$_.Name] = $_.Value
        }
    }

    # Add/update tool
    $lockHash.tools[$ToolName] = @{
        version = $Version
        installed_date = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        source = $Source
        repo = $Repo
        sha256 = $SHA256
        download_url = $DownloadUrl
    }

    # Save
    $lockHash | ConvertTo-Json -Depth 10 | Set-Content $script:VERSION_LOCK_FILE
    Write-SynchronizedLog "Updated version lock: $ToolName@$Version"
}

function Get-InstalledVersion {
    <#
    .SYNOPSIS
        Get the installed version of a tool
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ToolName
    )

    $lock = Get-VersionLock

    if ($lock.tools.$ToolName) {
        return $lock.tools.$ToolName.version
    }

    return $null
}

#endregion

#region Version Detection

function Get-LatestGitHubVersion {
    <#
    .SYNOPSIS
        Get the latest version from GitHub releases
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Repo
    )

    try {
        $releasesURL = "https://api.github.com/repos/$Repo/releases/latest"

        if ($GH_USER -and $GH_PASS) {
            $release = curl.exe --silent -L -u "${GH_USER}:${GH_PASS}" $releasesURL | ConvertFrom-Json
        } else {
            $release = curl.exe --silent -L $releasesURL | ConvertFrom-Json
        }

        if ($release.tag_name) {
            # Remove 'v' prefix if present
            $version = $release.tag_name -replace '^v', ''
            return @{
                version = $version
                tag = $release.tag_name
                published_at = $release.published_at
                html_url = $release.html_url
                body = $release.body
            }
        }
    } catch {
        Write-Warning "Failed to get latest version for $Repo : $_"
    }

    return $null
}

function Get-LatestVersion {
    <#
    .SYNOPSIS
        Get the latest available version for a tool
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$ToolDefinition
    )

    # Check cache first
    $cached = Get-CachedVersion -ToolName $ToolDefinition.name
    if ($cached) {
        return $cached
    }

    switch ($ToolDefinition.source) {
        "github" {
            $latest = Get-LatestGitHubVersion -Repo $ToolDefinition.repo
            if ($latest) {
                Set-CachedVersion -ToolName $ToolDefinition.name -VersionInfo $latest
                return $latest
            }
        }
        "http" {
            # HTTP sources require manual version tracking
            Write-Warning "HTTP source version detection not implemented for $($ToolDefinition.name)"
            return $null
        }
    }

    return $null
}

#endregion

#region Version Comparison

function Compare-Versions {
    <#
    .SYNOPSIS
        Compare two version strings (semantic versioning)
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Version1,

        [Parameter(Mandatory=$true)]
        [string]$Version2
    )

    # Try semantic versioning comparison
    try {
        $v1Parts = $Version1 -split '\.' | ForEach-Object { [int]$_ }
        $v2Parts = $Version2 -split '\.' | ForEach-Object { [int]$_ }

        for ($i = 0; $i -lt [Math]::Max($v1Parts.Length, $v2Parts.Length); $i++) {
            $v1Part = if ($i -lt $v1Parts.Length) { $v1Parts[$i] } else { 0 }
            $v2Part = if ($i -lt $v2Parts.Length) { $v2Parts[$i] } else { 0 }

            if ($v1Part -lt $v2Part) { return -1 }
            if ($v1Part -gt $v2Part) { return 1 }
        }

        return 0
    } catch {
        # Fall back to string comparison
        return [string]::Compare($Version1, $Version2)
    }
}

function Test-UpdateAvailable {
    <#
    .SYNOPSIS
        Check if an update is available for a tool
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$ToolDefinition
    )

    $installed = Get-InstalledVersion -ToolName $ToolDefinition.name

    # If not installed, update is "available" (initial install)
    if (-not $installed) {
        return $true
    }

    # If version is pinned and matches installed, no update
    if ($ToolDefinition.version -and $ToolDefinition.version -ne "latest") {
        if ($installed -eq $ToolDefinition.version) {
            return $false
        }
        return $true
    }

    # Check for latest version
    $latest = Get-LatestVersion -ToolDefinition $ToolDefinition
    if (-not $latest) {
        return $false
    }

    # Compare versions
    $comparison = Compare-Versions -Version1 $installed -Version2 $latest.version
    return $comparison -lt 0
}

#endregion

#region Update Management

function Get-AvailableUpdates {
    <#
    .SYNOPSIS
        Get list of tools with available updates
    #>
    param(
        [Parameter(Mandatory=$true)]
        [array]$Tools
    )

    $updates = @()

    foreach ($tool in $Tools) {
        $installed = Get-InstalledVersion -ToolName $tool.name
        if (-not $installed) {
            continue  # Skip not installed
        }

        $latest = Get-LatestVersion -ToolDefinition $tool
        if (-not $latest) {
            continue
        }

        $comparison = Compare-Versions -Version1 $installed -Version2 $latest.version
        if ($comparison -lt 0) {
            $updates += @{
                tool = $tool
                current_version = $installed
                latest_version = $latest.version
                release_date = $latest.published_at
                release_notes = $latest.body
                url = $latest.html_url
            }
        }
    }

    return $updates
}

function Show-AvailableUpdates {
    <#
    .SYNOPSIS
        Display available updates to user
    #>
    param(
        [Parameter(Mandatory=$true)]
        [array]$Updates
    )

    if ($Updates.Count -eq 0) {
        Write-Output "`nNo updates available. All tools are up to date!`n"
        return
    }

    Write-Output "`n========================================"
    Write-Output "   Available Updates ($($Updates.Count))"
    Write-Output "========================================`n"

    foreach ($update in $Updates) {
        Write-Output "📦 $($update.tool.name)"
        Write-Output "   Current:  $($update.current_version)"
        Write-Output "   Latest:   $($update.latest_version)"
        Write-Output "   Released: $($update.release_date)"
        Write-Output "   Category: $($update.tool.category)"

        if ($update.release_notes) {
            $notes = $update.release_notes -split "`n" | Select-Object -First 3
            Write-Output "   Notes:    $($notes -join "`n             ")"
        }

        Write-Output "   Approve:  -ApproveUpdate $($update.tool.name)"
        Write-Output ""
    }

    Write-Output "To approve all: -ApproveAllUpdates"
    Write-Output "========================================`n"
}

function Approve-Update {
    <#
    .SYNOPSIS
        Approve an update for installation
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$ToolNames
    )

    $approvals = @{}
    if (Test-Path $script:UPDATE_APPROVALS_FILE) {
        $approvals = Get-Content $script:UPDATE_APPROVALS_FILE | ConvertFrom-Json
        $approvalsHash = @{}
        $approvals.PSObject.Properties | ForEach-Object {
            $approvalsHash[$_.Name] = $_.Value
        }
        $approvals = $approvalsHash
    }

    foreach ($toolName in $ToolNames) {
        $approvals[$toolName] = @{
            approved_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
            approved = $true
        }
    }

    $approvals | ConvertTo-Json | Set-Content $script:UPDATE_APPROVALS_FILE
    Write-Output "Approved updates for: $($ToolNames -join ', ')"
}

function Test-UpdateApproved {
    <#
    .SYNOPSIS
        Check if an update has been approved
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ToolName
    )

    if (-not (Test-Path $script:UPDATE_APPROVALS_FILE)) {
        return $false
    }

    $approvals = Get-Content $script:UPDATE_APPROVALS_FILE | ConvertFrom-Json
    return $approvals.$ToolName.approved -eq $true
}

function Clear-UpdateApprovals {
    <#
    .SYNOPSIS
        Clear all update approvals
    #>
    if (Test-Path $script:UPDATE_APPROVALS_FILE) {
        Remove-Item $script:UPDATE_APPROVALS_FILE
    }
}

#endregion

#region SHA256 Validation

function Get-FileSHA256 {
    <#
    .SYNOPSIS
        Calculate SHA256 hash of a file
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    if (-not (Test-Path $FilePath)) {
        throw "File not found: $FilePath"
    }

    $hash = Get-FileHash -Path $FilePath -Algorithm SHA256
    return $hash.Hash.ToLower()
}

function Test-SHA256 {
    <#
    .SYNOPSIS
        Validate file SHA256 checksum
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath,

        [Parameter(Mandatory=$true)]
        [string]$ExpectedHash
    )

    $actualHash = Get-FileSHA256 -FilePath $FilePath
    $expectedLower = $ExpectedHash.ToLower()

    if ($actualHash -eq $expectedLower) {
        Write-SynchronizedLog "✓ SHA256 validation passed: $FilePath"
        return $true
    } else {
        Write-Error "✗ SHA256 mismatch for $FilePath"
        Write-Error "  Expected: $expectedLower"
        Write-Error "  Actual:   $actualHash"
        return $false
    }
}

function Add-SHA256ToYAML {
    <#
    .SYNOPSIS
        Calculate and add SHA256 to YAML file
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$YAMLFile,

        [Parameter(Mandatory=$true)]
        [string]$ToolName,

        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    $sha256 = Get-FileSHA256 -FilePath $FilePath

    # Read YAML file
    $content = Get-Content $YAMLFile -Raw

    # Find tool definition and add SHA256
    # This is a simple implementation; could be enhanced
    $pattern = "(\s+- name: $ToolName\s+.*?)(\s+file_type:)"
    $replacement = "`$1`n  sha256: `"$sha256`"`$2"

    $newContent = $content -replace $pattern, $replacement

    if ($newContent -ne $content) {
        Set-Content -Path $YAMLFile -Value $newContent
        Write-Output "Added SHA256 to $ToolName in $YAMLFile"
    }
}

#endregion

#region Cache Management

function Get-CachedVersion {
    <#
    .SYNOPSIS
        Get cached version information
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ToolName
    )

    if (-not (Test-Path $script:UPDATE_CHECK_CACHE)) {
        return $null
    }

    $cache = Get-Content $script:UPDATE_CHECK_CACHE | ConvertFrom-Json
    $toolCache = $cache.$ToolName

    if (-not $toolCache) {
        return $null
    }

    # Check if cache is expired
    $cachedTime = [DateTime]::Parse($toolCache.cached_at)
    $expiry = $cachedTime.AddHours($script:CACHE_EXPIRY_HOURS)

    if ((Get-Date) -gt $expiry) {
        return $null
    }

    return $toolCache.version_info
}

function Set-CachedVersion {
    <#
    .SYNOPSIS
        Cache version information
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ToolName,

        [Parameter(Mandatory=$true)]
        $VersionInfo
    )

    $cache = @{}
    if (Test-Path $script:UPDATE_CHECK_CACHE) {
        $cacheObj = Get-Content $script:UPDATE_CHECK_CACHE | ConvertFrom-Json
        $cacheObj.PSObject.Properties | ForEach-Object {
            $cache[$_.Name] = $_.Value
        }
    }

    $cache[$ToolName] = @{
        cached_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        version_info = $VersionInfo
    }

    $cache | ConvertTo-Json -Depth 10 | Set-Content $script:UPDATE_CHECK_CACHE
}

function Clear-VersionCache {
    <#
    .SYNOPSIS
        Clear the version check cache
    #>
    if (Test-Path $script:UPDATE_CHECK_CACHE) {
        Remove-Item $script:UPDATE_CHECK_CACHE
        Write-Output "Version cache cleared"
    }
}

#endregion

# Export functions
Export-ModuleMember -Function @(
    'Initialize-VersionLock',
    'Get-VersionLock',
    'Update-VersionLock',
    'Get-InstalledVersion',
    'Get-LatestVersion',
    'Compare-Versions',
    'Test-UpdateAvailable',
    'Get-AvailableUpdates',
    'Show-AvailableUpdates',
    'Approve-Update',
    'Test-UpdateApproved',
    'Clear-UpdateApprovals',
    'Get-FileSHA256',
    'Test-SHA256',
    'Add-SHA256ToYAML',
    'Clear-VersionCache'
)
