<#

.SYNOPSIS
    Deduplicate enrichment folder.

.DESCRIPTION
    This script deduplicates the enrichment folder.

.EXAMPLE
    .\resources\contrib\deduplicate_enrichments.ps1
    This will deduplicate the enrichment folder.

.NOTES
    File Name      : deduplicate_enrichments.ps1
    Author         : Peter R

.LINK
    https://github.com/reuteras/dfirws
#>

param(
    [Parameter(HelpMessage = "Dry run.")]
    [Switch]$DryRun
)

$startDirectory = Get-Location

if ($DryRun.IsPresent) {
    Write-Output "Dry run enabled."
}

try {
    foreach ($folder in "ipinfo", "manuf", "maxmind", "snort", "suricata") {
        $directory = "${startDirectory}\enrichment\${folder}"
        if (-not (Test-Path "${directory}")) {
            Write-Output "Directory ${directory} does not exist."
            continue
        } else {
            Set-Location "${directory}"
        }
        Write-Output "Deduplicating ${directory}..."
        Get-ChildItem *-2* | Get-FileHash | Group-Object -Property Hash | `
            Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Group | Select-Object -Skip 1 } | `
            ForEach-Object {
                if ($DryRun.IsPresent) {
                    Write-Output "Would remove $(${_}.Path)"
                } else {
                    Remove-Item $_.Path -Force
                }
            }
    }
}
catch {
    Write-Output "An error occurred during deduplication of ${directory}: $_"
}
finally {
    Set-Location $startDirectory
}