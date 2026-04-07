$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

# This script runs in a Windows sandbox to scan tools with ClamAV.
# If C:\log\run_yarascan exists, a YARA scan is also started in parallel via Start-Process.
Write-DateLog "Install ClamAV and run scan" | Tee-Object -FilePath "C:\log\clamscan.txt" -Append

New-Item -ItemType Directory "${WSDFIR_TEMP}" 2>&1 | Out-Null

Write-Output "Get-Content C:\log\clamscan.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

# Start YARA scan immediately via Start-Process so it runs while ClamAV installs.
# Start-Process launches yara.exe directly in the same security context as this script,
# avoiding the restricted token that Start-Job's PowerShell subprocess runs under.
$yaraProc = $null
if (Test-Path -Path "C:\log\run_yarascan") {
    $YaraExe = "${TOOLS}\bin\yara.exe"
    $YaraDir = "C:\enrichment\yara"
    $YaraScanLog = "C:\log\yara-scan.log"
    $YaraScanErrLog = "C:\log\yara-scan-errors.log"
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
            $RuleFile = $YaraRules[0]
            Write-DateLog "Starting YARA scan in background (ruleset: $($RuleFile.Name), targets: $($ScanTargets -join ', '))..." | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
            $yaraArgs = @("--recursive", $RuleFile.FullName) + $ScanTargets
            $yaraProc = Start-Process -FilePath $YaraExe `
                -ArgumentList $yaraArgs `
                -RedirectStandardOutput $YaraScanLog `
                -RedirectStandardError $YaraScanErrLog `
                -PassThru -NoNewWindow
        }
    }
}

Install-ClamAV
while (-not (Test-Path -Path "C:\Program Files\ClamAV\clamscan.exe")) {
    Start-Sleep -Seconds 1
}

$ClamDB = "${TOOLS}\ClamAV\db"
$ScanLog = "C:\log\clamav-scan.log"

Write-DateLog "Starting ClamAV scan of C:\Tools, C:\venv and C:\git..." | Tee-Object -FilePath "C:\log\clamscan.txt" -Append

& 'C:\Program Files\ClamAV\clamscan.exe' `
    --recursive `
    --infected `
    --suppress-ok-results `
    --database=$ClamDB `
    --heuristic-alerts=yes `
    --heuristic-scan-precedence=yes `
    --alert-broken=yes `
    --alert-encrypted-archive=yes `
    --alert-macros=yes `
    --alert-exceeds-max=yes `
    --bytecode=yes `
    "--exclude-dir=^C:\\Windows" `
    "--exclude-dir=^C:\\Program Files\\Windows Defender" `
    "--exclude-dir=^C:\\ProgramData\\Microsoft\\Windows Defender" `
    "--exclude-dir=^C:\\Tools\\ClamAV" `
    "--exclude-dir=__pycache__" `
    "--exclude=\.lnk$" `
    "--exclude=\.url$" `
    "--exclude=\.mui$" `
    "--exclude=\.cat$" `
    "--exclude=\.manifest$" `
    "--exclude=\.pyc$" `
    --max-filesize=200M `
    --max-scansize=400M `
    --log=$ScanLog `
    "C:\Tools" "C:\venv" "C:\git" 2>&1 | ForEach-Object{ "$_" } | Tee-Object -FilePath "C:\log\clamscan.txt" -Append

Write-DateLog "ClamAV scan complete. Results saved to $ScanLog" | Tee-Object -FilePath "C:\log\clamscan.txt" -Append

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
