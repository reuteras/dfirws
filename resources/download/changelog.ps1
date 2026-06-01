# Changelog tracking for dfirws tool downloads.
# Compares current .metadata/ JSON files against the persisted versions.json
# state file to produce a Markdown changelog entry per run.

function Get-ChangelogCurrentVersions {
    $versions = [ordered]@{}
    $metadataBase = "$PSScriptRoot\..\..\downloads\.metadata"

    $githubDir = "$metadataBase\github"
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

    $wingetDir = "$metadataBase\winget"
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

    $npmDir = "$metadataBase\npm"
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

    $uvDir = "$metadataBase\uv"
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
        if ($oldVersions.ContainsKey($key)) {
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

    if ($updated.Count -eq 0 -and $added.Count -eq 0) {
        Write-DateLog "Changelog: No tool version changes detected."
        return
    }

    $date  = Get-Date -Format "yyyy-MM-dd"
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("### $date")
    $lines.Add("")

    if ($updated.Count -gt 0) {
        $lines.Add("#### Updated Tools")
        foreach ($t in ($updated | Sort-Object Name)) {
            $src = switch ($t.Source) {
                "github" { "GitHub: $($t.Identifier)" }
                "winget" { "winget: $($t.Identifier)" }
                "npm"    { "npm: $($t.Identifier)" }
                "uv"     { "uv: $($t.Identifier)" }
                default  { "$($t.Source): $($t.Identifier)" }
            }
            $lines.Add("- **$($t.Name)** ($src): $($t.OldVersion) -> $($t.NewVersion)")
        }
        $lines.Add("")
    }

    if ($added.Count -gt 0) {
        $lines.Add("#### New Tools")
        foreach ($t in ($added | Sort-Object Name)) {
            $src = switch ($t.Source) {
                "github" { "GitHub: $($t.Identifier)" }
                "winget" { "winget: $($t.Identifier)" }
                "npm"    { "npm: $($t.Identifier)" }
                "uv"     { "uv: $($t.Identifier)" }
                default  { "$($t.Source): $($t.Identifier)" }
            }
            $lines.Add("- **$($t.Name)** ($src): $($t.Version)")
        }
        $lines.Add("")
    }

    $newEntry      = $lines -join "`n"
    $changelogFile = "$PSScriptRoot\..\..\downloads\CHANGELOG.md"

    if (Test-Path $changelogFile) {
        $existing = Get-Content $changelogFile -Raw -Encoding UTF8
        if ($existing -match "(?s)^(# DFIRWS Changelog\r?\n\r?\n?)(.*)$") {
            $newContent = "# DFIRWS Changelog`n`n${newEntry}`n$($Matches[2].TrimStart())"
        } else {
            $newContent = "# DFIRWS Changelog`n`n${newEntry}`n${existing}"
        }
    } else {
        $newContent = "# DFIRWS Changelog`n`n${newEntry}"
    }

    Set-Content -Path $changelogFile -Value $newContent -Encoding UTF8 -NoNewline
    Write-DateLog "Changelog: $($updated.Count) updated, $($added.Count) new tool(s). See downloads\CHANGELOG.md"
}
