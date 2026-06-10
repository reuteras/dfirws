# Fills empty Homepage/Vendor/License/LicenseUrl fields in $TOOL_DEFINITIONS
# blocks from authoritative sources:
#   - release.ps1 (and any file using Get-GitHubRelease): the GitHub repo of the
#     nearest preceding Get-GitHubRelease call
#   - git.ps1: the $repourls entry whose basename matches the tool name
#   - winget.ps1: the cached `winget show` metadata in downloads/.metadata/winget/
#
# Data sources, in order:
#   1. Cached downloads/.metadata/github/<owner_repo>.json and
#      downloads/.metadata/winget/<AppId>.json (populated on the Windows box by
#      every download run - no network needed)
#   2. GitHub API fallback (uses $GITHUB_TOKEN from dfirws-config.ps1 when set;
#      skip with -NoApi)
#
# Default mode prints a report of proposed values. -Apply splices them into the
# script files, only ever replacing values that are exactly "".
# Usage/Tips/Notes are intentionally never generated - they are human-authored.
#
# Run: pwsh ./scripts/update-tool-metadata.ps1 [-Apply] [-NoApi]

param (
    [switch]$Apply,
    [switch]$NoApi
)

Set-StrictMode -Version Latest

. "$PSScriptRoot/lib/Get-ToolDefinitionAst.ps1"

$repoRoot = Resolve-Path "$PSScriptRoot/.."
$fillKeys = @("Homepage", "Vendor", "License", "LicenseUrl")

# GitHub credentials from dfirws-config.ps1 (same convention as downloadFiles.ps1).
$GITHUB_TOKEN = ""
if (Test-Path (Join-Path $repoRoot "dfirws-config.ps1")) {
    . (Join-Path $repoRoot "dfirws-config.ps1")
}
$apiHeaders = @{ "User-Agent" = "dfirws-metadata-updater" }
if ($GITHUB_TOKEN -and $GITHUB_TOKEN -ne "YOUR GITHUB TOKEN") {
    $apiHeaders["Authorization"] = "token $GITHUB_TOKEN"
}

$script:apiBudgetExhausted = $false

# Returns @{Homepage; Vendor; License; LicenseUrl; Origin} for a GitHub repo,
# from the local metadata cache when present, otherwise from the GitHub API.
function Get-GitHubRepoFacts {
    param([string]$Repo)

    $safeRepo = $Repo -replace "/", "_"
    $cacheFile = Join-Path $repoRoot "downloads/.metadata/github/$safeRepo.json"
    if (Test-Path $cacheFile) {
        try {
            $data = Get-Content $cacheFile -Raw | ConvertFrom-Json
            $license = $null
            if ($data.PSObject.Properties["License"] -and $data.License -and
                $data.License.SpdxId -and $data.License.SpdxId -ne "NOASSERTION") {
                $license = $data.License.SpdxId
            }
            return [PSCustomObject]@{
                Homepage   = if ($data.Homepage) { $data.Homepage } else { $data.HtmlUrl }
                Vendor     = $data.Owner
                License    = $license
                LicenseUrl = $null  # cache stores only the generic SPDX API URL
                Origin     = "cache"
            }
        } catch { }
    }

    if ($NoApi -or $script:apiBudgetExhausted) {
        return $null
    }

    try {
        $data = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo" -Headers $apiHeaders -ErrorAction Stop
    } catch {
        if ($_.Exception.Response -and [int]$_.Exception.Response.StatusCode -in @(403, 429)) {
            Write-Warning "GitHub API rate limit hit - remaining repos use cache only. Set GITHUB_TOKEN in dfirws-config.ps1 to raise the limit."
            $script:apiBudgetExhausted = $true
        }
        return $null
    }

    $license = $null
    if ($data.license -and $data.license.spdx_id -and $data.license.spdx_id -ne "NOASSERTION") {
        $license = $data.license.spdx_id
    }

    # The license endpoint returns the html_url of the actual license file.
    $licenseUrl = $null
    if ($license) {
        try {
            $licenseData = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/license" -Headers $apiHeaders -ErrorAction Stop
            $licenseUrl = $licenseData.html_url
        } catch { }
    }

    return [PSCustomObject]@{
        Homepage   = if ($data.homepage) { $data.homepage } else { $data.html_url }
        Vendor     = $data.owner.login
        License    = $license
        LicenseUrl = $licenseUrl
        Origin     = "api"
    }
}

# Returns facts for a winget AppId from the local metadata cache (winget itself
# is only available on the Windows box).
function Get-WingetFacts {
    param([string]$AppId)

    $cacheFile = Join-Path $repoRoot "downloads/.metadata/winget/$AppId.json"
    if (-not (Test-Path $cacheFile)) {
        return $null
    }
    try {
        $data = Get-Content $cacheFile -Raw | ConvertFrom-Json
        $get = { param($key) if ($data.PSObject.Properties[$key]) { $data.$key } else { $null } }
        return [PSCustomObject]@{
            Homepage   = & $get "Homepage"
            Vendor     = & $get "Publisher"
            License    = & $get "License"
            LicenseUrl = & $get "LicenseUrl"
            Origin     = "winget-cache"
        }
    } catch {
        return $null
    }
}

# Maps repo basenames (lowercased, without .git) to owner/name for git.ps1.
function Get-GitRepoBasenames {
    param([string]$Path)

    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile(
        (Resolve-Path $Path), [ref]$null, [ref]$parseErrors)
    $map = @{}
    $strings = $ast.FindAll({ param($node)
        $node -is [System.Management.Automation.Language.StringConstantExpressionAst] -and
        $node.Value -match '^https://github\.com/[^/]+/[^/]+' }, $true)
    foreach ($s in $strings) {
        if ($s.Value -match '^https://github\.com/([^/]+)/([^/]+?)(\.git)?/?$') {
            $map[$Matches[2].ToLower()] = "$($Matches[1])/$($Matches[2])"
        }
    }
    return $map
}

# Escapes a value for splicing into a double-quoted PowerShell string literal.
function ConvertTo-QuotedLiteral {
    param([string]$Value)
    $escaped = $Value -replace '`', '``' -replace '"', '`"' -replace '\$', '`$'
    return "`"$escaped`""
}

$proposals = [System.Collections.Generic.List[PSCustomObject]]::new()
$unmatched = [System.Collections.Generic.List[string]]::new()
$backlog = @{}

$scanFiles = Get-ChildItem -Path (Join-Path $repoRoot "resources/download") -Filter "*.ps1"
foreach ($file in $scanFiles) {
    $definitions = @(Get-ToolDefinitionsFromFile -Path $file.FullName)
    if ($definitions.Count -eq 0) {
        continue
    }

    $gitRepoMap = @{}
    if ($file.Name -eq "git.ps1") {
        $gitRepoMap = Get-GitRepoBasenames -Path $file.FullName
    }

    foreach ($def in $definitions) {
        if (-not $def.Name) {
            continue
        }

        foreach ($key in @("Usage", "Tips")) {
            if (-not $def.Keys.Contains($key) -or $def.Keys[$key].IsEmpty) {
                if (-not $backlog.ContainsKey($file.Name)) { $backlog[$file.Name] = 0 }
                $backlog[$file.Name]++
            }
        }

        $emptyKeys = $fillKeys | Where-Object { $def.Keys.Contains($_) -and $def.Keys[$_].IsEmpty }
        if (-not $emptyKeys) {
            continue
        }

        $facts = $null
        if ($def.GitHubRepo) {
            $facts = Get-GitHubRepoFacts -Repo $def.GitHubRepo
        } elseif ($file.Name -eq "git.ps1") {
            # Match the tool name against repo basenames (spaces/underscores vs hyphens).
            $repo = $null
            $candidates = @(
                $def.Name.ToLower(),
                ($def.Name.ToLower() -replace "[ _]", "-")
            ) | Select-Object -Unique
            foreach ($candidate in $candidates) {
                if ($gitRepoMap.ContainsKey($candidate)) {
                    $repo = $gitRepoMap[$candidate]
                    break
                }
            }
            if ($null -eq $repo) {
                $unmatched.Add("$($file.Name):$($def.Line) ($($def.Name)): no matching repo URL found - fill manually")
                continue
            }
            $facts = Get-GitHubRepoFacts -Repo $repo
        } elseif ($def.WingetId) {
            $facts = Get-WingetFacts -AppId $def.WingetId
        }

        # No cache entry and no API data - nothing to propose for this tool.
        if ($null -eq $facts) {
            continue
        }

        foreach ($key in $emptyKeys) {
            $value = $facts.$key
            if ([string]::IsNullOrWhiteSpace($value)) {
                continue
            }
            $proposals.Add([PSCustomObject]@{
                File        = $file.FullName
                FileName    = $file.Name
                Line        = $def.Line
                Tool        = $def.Name
                Key         = $key
                Value       = $value
                Origin      = $facts.Origin
                StartOffset = $def.Keys[$key].StartOffset
                EndOffset   = $def.Keys[$key].EndOffset
            })
        }
    }
}

if ($proposals.Count -eq 0) {
    Write-Output "No fillable fields found (or no cache/API data available)."
} else {
    $proposals | Sort-Object FileName, Line, Key |
        Format-Table @{n="File";e={$_.FileName}}, Line, Tool, Key, Value, Origin -AutoSize |
        Out-String -Width 4096 | Write-Output
    Write-Output "Proposed values: $($proposals.Count)"
}

if ($unmatched.Count -gt 0) {
    Write-Output ""
    Write-Output "Unmatched tools (no repo association, fill manually):"
    $unmatched | ForEach-Object { Write-Output "  $_" }
}

if ($backlog.Count -gt 0) {
    Write-Output ""
    Write-Output "Human-authored backlog (empty Usage/Tips fields):"
    $backlog.GetEnumerator() | Sort-Object Name | ForEach-Object {
        Write-Output "  $($_.Key): $($_.Value)"
    }
}

if (-not $Apply) {
    if ($proposals.Count -gt 0) {
        Write-Output ""
        Write-Output "Report mode - rerun with -Apply to write these values."
    }
    exit 0
}

# Apply: splice values into the files, from the end backwards so earlier
# offsets stay valid. Only extents whose current text is exactly '""' are
# touched - anything else means the file changed since parsing.
foreach ($group in ($proposals | Group-Object File)) {
    $path = $group.Name
    $hasBom = $false
    $bytes = [System.IO.File]::ReadAllBytes($path)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $hasBom = $true
    }
    $text = Get-Content $path -Raw

    $applied = 0
    foreach ($edit in ($group.Group | Sort-Object StartOffset -Descending)) {
        $current = $text.Substring($edit.StartOffset, $edit.EndOffset - $edit.StartOffset)
        if ($current -ne '""') {
            Write-Warning "$($edit.FileName):$($edit.Line) ($($edit.Tool)) $($edit.Key): expected empty string at offset $($edit.StartOffset), found '$current' - skipped"
            continue
        }
        $text = $text.Substring(0, $edit.StartOffset) +
            (ConvertTo-QuotedLiteral -Value $edit.Value) +
            $text.Substring($edit.EndOffset)
        $applied++
    }

    $encoding = if ($hasBom) { [System.Text.UTF8Encoding]::new($true) } else { [System.Text.UTF8Encoding]::new($false) }
    [System.IO.File]::WriteAllText($path, $text, $encoding)
    Write-Output "Applied $applied change(s) to $(Split-Path $path -Leaf)."
}

Write-Output "Done. Review with git diff, then run scripts/validate-tool-metadata.ps1."
