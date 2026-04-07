$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

# This script runs in a Windows sandbox to scan tools with ClamAV.
# If C:\log\run_yarascan exists, a YARA scan is also started in parallel as a background job.
Write-DateLog "Install ClamAV and run scan" | Tee-Object -FilePath "C:\log\clamscan.txt" -Append

New-Item -ItemType Directory "${WSDFIR_TEMP}" 2>&1 | Out-Null

Write-Output "Get-Content C:\log\clamscan.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

# Start YARA scan as a background job immediately if requested, so it runs while ClamAV installs
$yaraJob = $null
if (Test-Path -Path "C:\log\run_yarascan") {
    $YaraExe = "${TOOLS}\bin\yara.exe"
    $YaraDir = "C:\enrichment\yara"
    $YaraScanLog = "C:\log\yara-scan.log"
    $ScanTargets = @("C:\Tools", "C:\venv", "C:\git")

    if ((Test-Path -Path $YaraExe) -and (Test-Path -Path $YaraDir)) {
        Write-DateLog "Starting YARA scan in background..." | Tee-Object -FilePath "C:\log\clamscan.txt" -Append

        $yaraJob = Start-Job -ScriptBlock {
            param($YaraExe, $YaraDir, $YaraScanLog, $ScanTargets)

            "" | Out-File -FilePath $YaraScanLog -Encoding utf8

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

            foreach ($RuleFile in $YaraRules) {
                foreach ($Target in ($ScanTargets | Where-Object { Test-Path -Path $_ })) {
                    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Scanning $Target ..." | Out-File -FilePath $YaraScanLog -Append
                    & $YaraExe --recursive $RuleFile.FullName $Target 2>&1 |
                        ForEach-Object { "$_" } | Out-File -FilePath $YaraScanLog -Append
                    if ($LASTEXITCODE -ne 0) {
                        "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - WARNING: yara.exe exited with code ${LASTEXITCODE} for target ${Target}" | Out-File -FilePath $YaraScanLog -Append
                    }
                }
            }
        } -ArgumentList $YaraExe, $YaraDir, $YaraScanLog, $ScanTargets
    } else {
        Write-DateLog "WARNING: YARA not available (yara.exe or enrichment\yara missing), skipping YARA scan." | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
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

# Wait for YARA background job to finish
if ($null -ne $yaraJob) {
    Write-DateLog "Waiting for YARA scan to complete..." | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
    Wait-Job $yaraJob | Out-Null
    Remove-Job $yaraJob
    Write-DateLog "YARA scan complete. Results saved to C:\log\yara-scan.log" | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
}

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > "C:\log\clamscan_done"
