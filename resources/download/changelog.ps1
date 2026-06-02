# Changelog tracking for dfirws tool downloads.
# Compares current .metadata/ JSON files against the persisted versions.json
# state file to produce a Markdown changelog entry per run.

function Get-ChangelogCurrentVersions {
    $versions = [ordered]@{}
    $downloadsMetadata = "$PSScriptRoot\..\..\downloads\.metadata"
    $toolsMetadata     = "$PSScriptRoot\..\..\mount\Tools\.metadata"

    $githubDir = "$downloadsMetadata\github"
    if (Test-Path $githubDir) {
        Get-ChildItem $githubDir -Filter "*.json" -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $data = Get-Content $_.FullName -Raw | ConvertFrom-Json -ErrorAction Stop
                if ($data.FullName -and $data.LatestRelease -and $data.LatestRelease.TagName) {
                    $versions[$data.FullName] = [PSCustomObject]@{
                        Name       = $data.Name
                        Version    = $data.LatestRelease.TagName
                        Source     = "github"
                        Identifier = $data.FullName
                    }
                }
            } catch { }
        }
    }

    $wingetDir = "$downloadsMetadata\winget"
    if (Test-Path $wingetDir) {
        Get-ChildItem $wingetDir -Filter "*.json" -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $data = Get-Content $_.FullName -Raw | ConvertFrom-Json -ErrorAction Stop
                if ($data.AppId -and $data.Version) {
                    $versions[$data.AppId] = [PSCustomObject]@{
                        Name       = if ($data.Name) { $data.Name } else { $data.AppId }
                        Version    = $data.Version
                        Source     = "winget"
                        Identifier = $data.AppId
                    }
                }
            } catch { }
        }
    }

    $npmDir = "$toolsMetadata\npm"
    if (Test-Path $npmDir) {
        Get-ChildItem $npmDir -Filter "*.json" -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $data = Get-Content $_.FullName -Raw | ConvertFrom-Json -ErrorAction Stop
                if ($data.Name -and $data.Version) {
                    $versions["npm:$($data.Name)"] = [PSCustomObject]@{
                        Name       = $data.Name
                        Version    = $data.Version
                        Source     = "npm"
                        Identifier = $data.Name
                    }
                }
            } catch { }
        }
    }

    $uvDir = "$toolsMetadata\uv"
    if (Test-Path $uvDir) {
        Get-ChildItem $uvDir -Filter "*.json" -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $data = Get-Content $_.FullName -Raw | ConvertFrom-Json -ErrorAction Stop
                if ($data.Name -and $data.Version) {
                    $versions["uv:$($data.Name)"] = [PSCustomObject]@{
                        Name       = $data.Name
                        Version    = $data.Version
                        Source     = "uv"
                        Identifier = $data.Name
                    }
                }
            } catch { }
        }
    }

    return $versions
}

function Get-ChangelogSavedVersions {
    $versionsFile = "$PSScriptRoot\..\..\downloads\.changelog\versions.json"
    if (-not (Test-Path $versionsFile)) {
        return [ordered]@{}
    }
    try {
        $raw = Get-Content $versionsFile -Raw | ConvertFrom-Json -ErrorAction Stop
        $versions = [ordered]@{}
        foreach ($prop in $raw.PSObject.Properties) {
            $versions[$prop.Name] = $prop.Value
        }
        return $versions
    } catch {
        return [ordered]@{}
    }
}

function Save-ChangelogVersions {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param([object]$Versions)
    $changelogDir = "$PSScriptRoot\..\..\downloads\.changelog"
    if (-not (Test-Path $changelogDir)) {
        New-Item -ItemType Directory -Force -Path $changelogDir | Out-Null
    }
    $Versions | ConvertTo-Json -Depth 4 |
        Set-Content -Path "$changelogDir\versions.json" -Encoding UTF8
}

# Extracts a version string from a URL, e.g. ".../v1.2.3/..." -> "1.2.3".
# Returns $null if no version-like pattern is found.
function Get-VersionFromUrl {
    param([string]$Url)
    # Match common patterns: /v1.2.3/, /1.2.3/, _1.2.3_, -1.2.3-, filename-1.2.3.ext
    if ($Url -match '(?:^|[/_\-v])(\d+\.\d+(?:\.\d+){0,3})(?:[/_\-\.]|$)') {
        return $Matches[1]
    }
    return $null
}

# Reads tools_downloaded.csv and returns a hashtable keyed by Name with URL values.
function Get-HttpToolsCurrentSnapshot {
    $csvFile = "$PSScriptRoot\..\..\downloads\tools_downloaded.csv"
    $snapshot = [ordered]@{}
    if (-not (Test-Path $csvFile)) {
        return $snapshot
    }
    try {
        Import-Csv $csvFile -ErrorAction Stop | ForEach-Object {
            if ($_.Name -and $_.URL) {
                $snapshot[$_.Name] = $_.URL
            }
        }
    } catch { }
    return $snapshot
}

# Loads the persisted HTTP tools snapshot from .changelog\http_snapshot.json.
function Get-HttpToolsSavedSnapshot {
    $snapshotFile = "$PSScriptRoot\..\..\downloads\.changelog\http_snapshot.json"
    $snapshot = [ordered]@{}
    if (-not (Test-Path $snapshotFile)) {
        return $snapshot
    }
    try {
        $raw = Get-Content $snapshotFile -Raw | ConvertFrom-Json -ErrorAction Stop
        foreach ($prop in $raw.PSObject.Properties) {
            $snapshot[$prop.Name] = $prop.Value
        }
    } catch { }
    return $snapshot
}

# Persists the current HTTP tools snapshot to .changelog\http_snapshot.json.
function Save-HttpToolsSnapshot {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param([object]$Snapshot)
    $changelogDir = "$PSScriptRoot\..\..\downloads\.changelog"
    if (-not (Test-Path $changelogDir)) {
        New-Item -ItemType Directory -Force -Path $changelogDir | Out-Null
    }
    $Snapshot | ConvertTo-Json -Depth 2 |
        Set-Content -Path "$changelogDir\http_snapshot.json" -Encoding UTF8
}

function Update-ToolChangelog {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param()

    $oldVersions = Get-ChangelogSavedVersions
    $newVersions = Get-ChangelogCurrentVersions

    if ($newVersions.Count -eq 0) {
        Write-DateLog "Changelog: No tool metadata found; skipping."
        return
    }

    Save-ChangelogVersions -Versions $newVersions

    # First run: record baseline only, no entry yet
    if ($oldVersions.Count -eq 0) {
        Write-DateLog "Changelog: Baseline recorded for $($newVersions.Count) tools (first run, no entry generated)."
        return
    }

    $updated = [System.Collections.Generic.List[PSCustomObject]]::new()
    $added   = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($key in $newVersions.Keys) {
        $cur = $newVersions[$key]
        if ($oldVersions.Contains($key)) {
            if ($oldVersions[$key].Version -ne $cur.Version) {
                $updated.Add([PSCustomObject]@{
                    Name       = $cur.Name
                    OldVersion = $oldVersions[$key].Version
                    NewVersion = $cur.Version
                    Source     = $cur.Source
                    Identifier = $cur.Identifier
                })
            }
        } else {
            $added.Add([PSCustomObject]@{
                Name       = $cur.Name
                Version    = $cur.Version
                Source     = $cur.Source
                Identifier = $cur.Identifier
            })
        }
    }

    # HTTP tools: compare URL snapshots
    $oldHttp = Get-HttpToolsSavedSnapshot
    $newHttp = Get-HttpToolsCurrentSnapshot

    $httpUpdated = [System.Collections.Generic.List[PSCustomObject]]::new()
    $httpAdded   = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($name in $newHttp.Keys) {
        $newUrl = $newHttp[$name]
        if ($oldHttp.Contains($name)) {
            $oldUrl = $oldHttp[$name]
            if ($oldUrl -ne $newUrl) {
                $oldVer = Get-VersionFromUrl -Url $oldUrl
                $newVer = Get-VersionFromUrl -Url $newUrl
                $httpUpdated.Add([PSCustomObject]@{
                    Name   = $name
                    OldUrl = $oldUrl
                    NewUrl = $newUrl
                    OldVer = $oldVer
                    NewVer = $newVer
                })
            }
        } else {
            $ver = Get-VersionFromUrl -Url $newUrl
            $httpAdded.Add([PSCustomObject]@{
                Name = $name
                Url  = $newUrl
                Ver  = $ver
            })
        }
    }

    $isFirstHttpRun = ($oldHttp.Count -eq 0)
    Save-HttpToolsSnapshot -Snapshot $newHttp

    if ($isFirstHttpRun) {
        Write-DateLog "Changelog: HTTP baseline recorded for $($newHttp.Count) tools."
    }

    if ($updated.Count -eq 0 -and $added.Count -eq 0 -and $httpUpdated.Count -eq 0 -and ($httpAdded.Count -eq 0 -or $isFirstHttpRun)) {
        Write-DateLog "Changelog: No tool version changes detected."
        return
    }

    $date = Get-Date -Format "yyyy-MM-dd"

    # Build section lines (no date heading yet — we handle that when writing the file).
    $sections = [System.Collections.Generic.List[string]]::new()

    if ($updated.Count -gt 0) {
        $sections.Add("#### Updated Tools")
        foreach ($t in ($updated | Sort-Object Name)) {
            $src = switch ($t.Source) {
                "github" { "GitHub: $($t.Identifier)" }
                "winget" { "winget: $($t.Identifier)" }
                "npm"    { "npm: $($t.Identifier)" }
                "uv"     { "uv: $($t.Identifier)" }
                default  { "$($t.Source): $($t.Identifier)" }
            }
            $sections.Add("- **$($t.Name)** ($src): $($t.OldVersion) -> $($t.NewVersion)")
        }
        $sections.Add("")
    }

    if ($httpUpdated.Count -gt 0) {
        $sections.Add("#### Updated Tools (HTTP)")
        foreach ($t in ($httpUpdated | Sort-Object Name)) {
            if ($t.OldVer -and $t.NewVer) {
                $sections.Add("- **$($t.Name)**: $($t.OldVer) -> $($t.NewVer)")
            } else {
                $sections.Add("- **$($t.Name)**: updated (version not available in URL)")
            }
            $sections.Add("  - old: $($t.OldUrl)")
            $sections.Add("  - new: $($t.NewUrl)")
        }
        $sections.Add("")
    }

    if ($added.Count -gt 0) {
        $sections.Add("#### New Tools")
        foreach ($t in ($added | Sort-Object Name)) {
            $src = switch ($t.Source) {
                "github" { "GitHub: $($t.Identifier)" }
                "winget" { "winget: $($t.Identifier)" }
                "npm"    { "npm: $($t.Identifier)" }
                "uv"     { "uv: $($t.Identifier)" }
                default  { "$($t.Source): $($t.Identifier)" }
            }
            $sections.Add("- **$($t.Name)** ($src): $($t.Version)")
        }
        $sections.Add("")
    }

    if (-not $isFirstHttpRun -and $httpAdded.Count -gt 0) {
        $sections.Add("#### New Tools (HTTP)")
        foreach ($t in ($httpAdded | Sort-Object Name)) {
            $verStr = if ($t.Ver) { ": $($t.Ver)" } else { "" }
            $sections.Add("- **$($t.Name)**$verStr")
            $sections.Add("  - url: $($t.Url)")
        }
        $sections.Add("")
    }

    $newSections   = $sections -join "`n"
    $changelogFile = "$PSScriptRoot\..\..\downloads\CHANGELOG.md"
    $todayHeading  = "### $date"

    if (Test-Path $changelogFile) {
        $existing = Get-Content $changelogFile -Raw -Encoding UTF8
        # Normalise line endings for matching
        $existingLf = $existing -replace "`r`n", "`n"

        if ($existingLf -match "(?s)(.*\Q$todayHeading\E\n\n)(.*)") {
            # An entry for today already exists — append new sections after it.
            $before      = $Matches[1]
            $after       = $Matches[2]
            $newContent  = "${before}${newSections}`n${after}"
        } elseif ($existingLf -match "(?s)^(# DFIRWS Changelog\n\n?)(.*)$") {
            # No entry for today — prepend a new dated section.
            $newContent = "# DFIRWS Changelog`n`n${todayHeading}`n`n${newSections}`n$($Matches[2].TrimStart())"
        } else {
            $newContent = "# DFIRWS Changelog`n`n${todayHeading}`n`n${newSections}`n${existingLf}"
        }
    } else {
        $newContent = "# DFIRWS Changelog`n`n${todayHeading}`n`n${newSections}"
    }

    Set-Content -Path $changelogFile -Value $newContent -Encoding UTF8 -NoNewline
    $httpCount = $httpUpdated.Count + $(if (-not $isFirstHttpRun) { $httpAdded.Count } else { 0 })
    Write-DateLog "Changelog: $($updated.Count) updated, $($added.Count) new, $httpCount HTTP change(s). See downloads\CHANGELOG.md"
}
