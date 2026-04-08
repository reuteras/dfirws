$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

# This script runs in a Windows sandbox to scan tools with ClamAV.
# If C:\log\run_yarascan exists, a YARA scan is also started in parallel with the ClamAV scans.
# YARA is started after ClamAV installs because the ClamAV MSI provides vcruntime140.dll
# which yara.exe depends on but is absent in a fresh sandbox.
Write-DateLog "Install ClamAV and run scan" | Tee-Object -FilePath "C:\log\clamscan.txt" -Append

New-Item -ItemType Directory "${WSDFIR_TEMP}" 2>&1 | Out-Null

Write-Output "Get-Content C:\log\clamscan.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

# Prepare YARA parameters now, but launch after Install-ClamAV provides vcruntime140.dll
$yaraProc = $null
$YaraScanLog = "C:\log\yara-scan.log"
$YaraScanErrLog = "C:\log\yara-scan-errors.log"
if (Test-Path -Path "C:\log\run_yarascan") {
    $YaraExe = "${TOOLS}\bin\yara.exe"
    $YaraDir = "C:\enrichment\yara"
    $ScanTargets = @("C:\Tools", "C:\venv", "C:\git") | Where-Object { Test-Path -Path $_ }

    if (-not (Test-Path -Path $YaraExe)) {
        Write-DateLog "WARNING: yara.exe not found at ${YaraExe}, skipping YARA scan." | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
    } elseif (-not (Test-Path -Path $YaraDir)) {
        Write-DateLog "WARNING: YARA enrichment directory not found at ${YaraDir}, skipping YARA scan." | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
    } else {
        # Find YARA rule files (prefer core, then extended, then full)
        $YaraRules = @()
        foreach ($ruleset in @("core", "extended", "full")) {
            $candidates = Get-ChildItem -Path $YaraDir -Filter "*.yar" -Recurse -ErrorAction SilentlyContinue |
                Where-Object { $_.FullName -match $ruleset }
            if ($candidates) {
                $YaraRules += $candidates
                break
            }
        }
        if ($YaraRules.Count -eq 0) {
            $YaraRules = Get-ChildItem -Path $YaraDir -Filter "*.yar" -Recurse -ErrorAction SilentlyContinue
        }

        if ($YaraRules.Count -eq 0) {
            Write-DateLog "WARNING: No YARA rule files found in ${YaraDir}, skipping YARA scan." | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
        } elseif ($ScanTargets.Count -eq 0) {
            Write-DateLog "WARNING: No YARA scan targets available, skipping YARA scan." | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
        } else {
            # Generate an exclusion-aware PowerShell YARA scan script — launched after ClamAV installs
            $RuleFile = $YaraRules[0]
            $psFile = "${WSDFIR_TEMP}\run_yarascan.ps1"

            $yaraExcludedPaths = @(
                "C:\git\Zircolite\rules",
                "C:\git\threat-intel",
                "C:\git\dfirws-sample-files",
                "C:\git\EVTX-ATTACK-SAMPLES",
                "C:\git\DFIRArtifactMuseum",
                "C:\git\APT-Hunter\Samples",
                "C:\git\APT-Hunter\rules.json",
                "C:\git\hayabusa-rules",
                "C:\git\sigma\rules",
                "C:\git\signature-base",
                "C:\Tools\capa-rules",
                "C:\Tools\hayabusa\rules\hayabusa",
                "C:\Tools\Lumen\LUMEN\dist\samples",
                "C:\Tools\Lumen\LUMEN\dist\sigma-rules",
                "C:\Tools\Lumen\LUMEN\src\sigma-master",
                "C:\venv\zircolite\zircolite\rules",
                "C:\git\PowerDecode\MalwareRepository.db",
                "C:\Tools\logboost\intel",
                "C:\Tools\logboost\threats.db"
            )

            # Build the generated script line by line (backtick-$ produces literal $ in the output file)
            $psLines = @('$ExcludePaths = @(')
            foreach ($excl in $yaraExcludedPaths) {
                $psLines += "    '$excl',"
            }
            $psLines[-1] = $psLines[-1].TrimEnd(',')
            $psLines += ')'
            $psLines += '$ScanTargets = @(''C:\Tools'', ''C:\venv'', ''C:\git'') | Where-Object { Test-Path $_ }'
            $psLines += '$files = @(foreach ($t in $ScanTargets) {'
            $psLines += '    Get-ChildItem -Path $t -Recurse -File -ErrorAction SilentlyContinue |'
            $psLines += '        Where-Object {'
            $psLines += '            $fp = $_.FullName'
            $psLines += "            -not (`$ExcludePaths | Where-Object { `$fp -eq `$_ -or `$fp.StartsWith(`$_ + '\') })"
            $psLines += '        } | Select-Object -ExpandProperty FullName'
            $psLines += '})'
            $psLines += "`$files | Set-Content -Path '${WSDFIR_TEMP}\yara-scanlist.txt' -Encoding ascii"
            $psLines += "`$output = & '${YaraExe}' --scan-list '$($RuleFile.FullName)' '${WSDFIR_TEMP}\yara-scanlist.txt' 2>'${YaraScanErrLog}'"
            $psLines += "`$output | Out-File -FilePath '${YaraScanLog}' -Encoding utf8"
            $psLines | Set-Content -Path $psFile -Encoding utf8

            Write-DateLog "YARA scan prepared (ruleset: $($RuleFile.Name), exclusions: $($yaraExcludedPaths.Count) paths)." | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
        }
    }
}

Install-ClamAV
while (-not (Test-Path -Path "C:\Program Files\ClamAV\clamscan.exe")) {
    Start-Sleep -Seconds 1
}

# Start YARA now that vcruntime140.dll is available from the ClamAV installation
if (Test-Path -Path "${WSDFIR_TEMP}\run_yarascan.ps1") {
    Write-DateLog "Starting YARA scan in background..." | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
    $yaraProc = Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -NonInteractive -File `"${WSDFIR_TEMP}\run_yarascan.ps1`"" -PassThru -WindowStyle Hidden
}

$ClamDB = "${TOOLS}\ClamAV\db"
$ClamExe = "C:\Program Files\ClamAV\clamscan.exe"
$ClamBaseArgs = @(
    "--recursive",
    "--infected",
    "--suppress-ok-results",
    "--database=$ClamDB",
    "--heuristic-alerts=yes",
    "--heuristic-scan-precedence=yes",
    "--alert-broken=no",
    "--alert-encrypted-archive=no",
    "--alert-macros=no",
    "--alert-exceeds-max=no",
    "--bytecode=yes",
    # Built-in sandbox/system exclusions
    "--exclude-dir=^C:\\Windows",
    "--exclude-dir=^C:\\Program Files\\Windows Defender",
    "--exclude-dir=^C:\\ProgramData\\Microsoft\\Windows Defender",
    "--exclude-dir=^C:\\Tools\\ClamAV",
    "--exclude-dir=__pycache__",
    # Known false-positive / rule-set directories
    "--exclude-dir=^C:[/\\\\]git[/\\\\]Zircolite[/\\\\]rules",
    "--exclude-dir=^C:[/\\\\]git[/\\\\]threat-intel",
    "--exclude-dir=^C:[/\\\\]git[/\\\\]dfirws-sample-files",
    "--exclude-dir=^C:[/\\\\]git[/\\\\]EVTX-ATTACK-SAMPLES",
    "--exclude-dir=^C:[/\\\\]git[/\\\\]DFIRArtifactMuseum",
    "--exclude-dir=^C:[/\\\\]git[/\\\\]APT-Hunter[/\\\\]Samples",
    "--exclude-dir=^C:[/\\\\]git[/\\\\]hayabusa-rules",
    "--exclude-dir=^C:[/\\\\]git[/\\\\]sigma[/\\\\]rules",
    "--exclude-dir=^C:[/\\\\]git[/\\\\]signature-base",
    "--exclude-dir=^C:[/\\\\]Tools[/\\\\]capa-rules",
    "--exclude-dir=^C:[/\\\\]Tools[/\\\\]hayabusa[/\\\\]rules[/\\\\]hayabusa",
    "--exclude-dir=^C:[/\\\\]Tools[/\\\\]Lumen[/\\\\]LUMEN[/\\\\]dist[/\\\\]samples",
    "--exclude-dir=^C:[/\\\\]Tools[/\\\\]Lumen[/\\\\]LUMEN[/\\\\]dist[/\\\\]sigma-rules",
    "--exclude-dir=^C:[/\\\\]Tools[/\\\\]Lumen[/\\\\]LUMEN[/\\\\]src[/\\\\]sigma-master",
    "--exclude-dir=^C:[/\\\\]venv[/\\\\]zircolite[/\\\\]zircolite[/\\\\]rules",
    "--exclude-dir=^C:[/\\\\]Tools[/\\\\]logboost[/\\\\]intel",
    # Specific false-positive files
    "--exclude=APT-Hunter[/\\\\]rules\\.json$",
    "--exclude=MalwareRepository\\.db$",
    "--exclude=logboost[/\\\\]threats\\.db$",
    # Standard file-type exclusions
    "--exclude=\.lnk$",
    "--exclude=\.url$",
    "--exclude=\.mui$",
    "--exclude=\.cat$",
    "--exclude=\.manifest$",
    "--exclude=\.pyc$",
    "--max-filesize=200M",
    "--max-scansize=400M"
)

# Start one clamscan process per target in parallel
$clamProcs = @()
foreach ($target in @("C:\Tools", "C:\venv", "C:\git") | Where-Object { Test-Path -Path $_ }) {
    $label = Split-Path $target -Leaf
    $targetLog = "C:\log\clamav-scan-${label}.log"
    $args = $ClamBaseArgs + @("--log=$targetLog", $target)
    Write-DateLog "Starting ClamAV scan of $target..." | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
    $proc = Start-Process -FilePath $ClamExe -ArgumentList $args -PassThru -WindowStyle Hidden
    $clamProcs += [PSCustomObject]@{ Proc = $proc; Target = $target; Log = $targetLog }
}

# Wait for all three scans to finish
Write-DateLog "Waiting for all ClamAV scans to complete..." | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
foreach ($item in $clamProcs) {
    $item.Proc.WaitForExit()
    Write-DateLog "ClamAV scan of $($item.Target) complete (exit $($item.Proc.ExitCode)). Results in $($item.Log)" | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
}

Write-DateLog "All ClamAV scans complete." | Tee-Object -FilePath "C:\log\clamscan.txt" -Append

# Wait for YARA process to finish
if ($null -ne $yaraProc) {
    Write-DateLog "Waiting for YARA scan to complete..." | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
    $yaraProc.WaitForExit()
    if ($yaraProc.ExitCode -ne 0) {
        Write-DateLog "WARNING: yara.exe exited with code $($yaraProc.ExitCode)" | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
    }
    if ((Test-Path $YaraScanErrLog) -and (Get-Item $YaraScanErrLog).Length -gt 0) {
        Write-DateLog "YARA stderr output:" | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
        Get-Content $YaraScanErrLog | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
    }
    Write-DateLog "YARA scan complete. Results saved to C:\log\yara-scan.log" | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
}

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > "C:\log\clamscan_done"
