# Validates the $TOOL_DEFINITIONS metadata blocks in the download/install
# scripts without executing them (static AST parse via lib/Get-ToolDefinitionAst.ps1).
#
# Severity tiers:
#   error   - missing/empty Name or Category, unknown keys (typos)
#   warning - empty Homepage, Vendor, License, LicenseUrl; duplicate Names
#             across files (some tools are intentionally delivered via two
#             channels, e.g. a git clone and a release binary)
#   info    - empty Usage, Tips (human-authored backlog)
#
# Exit code is non-zero when errors are found; -Strict also fails on warnings.
# Run from anywhere: pwsh ./scripts/validate-tool-metadata.ps1

param (
    [switch]$Strict,
    [switch]$ShowInfo
)

Set-StrictMode -Version Latest

. "$PSScriptRoot/lib/Get-ToolDefinitionAst.ps1"

$repoRoot = Resolve-Path "$PSScriptRoot/.."
$scanDirs = @(
    (Join-Path $repoRoot "resources/download"),
    (Join-Path $repoRoot "setup/install")
)

$warningKeys = @("Homepage", "Vendor", "License", "LicenseUrl")
$infoKeys    = @("Usage", "Tips")

$errors   = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()
$infos    = [System.Collections.Generic.List[string]]::new()
$allDefinitions = [System.Collections.Generic.List[PSCustomObject]]::new()

foreach ($dir in $scanDirs) {
    foreach ($file in (Get-ChildItem -Path $dir -Filter "*.ps1" | Sort-Object Name)) {
        try {
            $definitions = @(Get-ToolDefinitionsFromFile -Path $file.FullName)
        } catch {
            $errors.Add("$($file.Name): $($_.Exception.Message)")
            continue
        }

        foreach ($def in $definitions) {
            $allDefinitions.Add($def)
            $where = "$($file.Name):$($def.Line)"
            $label = if ($def.Name) { $def.Name } else { "<unnamed>" }

            if (-not $def.Name) {
                $errors.Add("${where}: tool definition has missing or empty Name")
            }
            if (-not $def.Keys.Contains("Category") -or $def.Keys["Category"].IsEmpty) {
                $errors.Add("${where} (${label}): missing or empty Category")
            }

            foreach ($key in $def.Keys.Keys) {
                if ($key -notin $TOOL_DEFINITION_KEYS) {
                    $errors.Add("${where} (${label}): unknown key '$key' (typo? schema is defined in setup/shared.ps1)")
                }
            }

            foreach ($key in $warningKeys) {
                if (-not $def.Keys.Contains($key) -or $def.Keys[$key].IsEmpty) {
                    $warnings.Add("${where} (${label}): empty $key")
                }
            }

            foreach ($key in $infoKeys) {
                if (-not $def.Keys.Contains($key) -or $def.Keys[$key].IsEmpty) {
                    $infos.Add("${where} (${label}): empty $key")
                }
            }
        }
    }
}

# Duplicate tool names across all scanned files.
$allDefinitions | Where-Object { $_.Name } | Group-Object Name |
    Where-Object { $_.Count -gt 1 } | ForEach-Object {
        $locations = ($_.Group | ForEach-Object { "$(Split-Path $_.File -Leaf):$($_.Line)" }) -join ", "
        $warnings.Add("duplicate tool name '$($_.Name)' defined at: $locations")
    }

Write-Output "Scanned $($allDefinitions.Count) tool definitions."
Write-Output ""

if ($errors.Count -gt 0) {
    Write-Output "=== Errors ($($errors.Count)) ==="
    $errors | ForEach-Object { Write-Output "  $_" }
    Write-Output ""
}

if ($warnings.Count -gt 0) {
    Write-Output "=== Warnings ($($warnings.Count)) ==="
    $warnings | ForEach-Object { Write-Output "  $_" }
    Write-Output ""
}

if ($ShowInfo -and $infos.Count -gt 0) {
    Write-Output "=== Info ($($infos.Count)) ==="
    $infos | ForEach-Object { Write-Output "  $_" }
    Write-Output ""
}

Write-Output "Summary: $($errors.Count) error(s), $($warnings.Count) warning(s), $($infos.Count) info."

if ($errors.Count -gt 0) {
    exit 1
}
if ($Strict -and $warnings.Count -gt 0) {
    exit 1
}
exit 0
