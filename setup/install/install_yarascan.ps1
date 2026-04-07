$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

# This script runs in a Windows sandbox to scan tools with YARA.
Write-DateLog "Run YARA scan" | Tee-Object -FilePath "C:\log\yarascan.txt" -Append

New-Item -ItemType Directory "${WSDFIR_TEMP}" 2>&1 | Out-Null

Write-Output "Get-Content C:\log\yarascan.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

$YaraExe = "${TOOLS}\bin\yara.exe"
$YaraDir = "C:\enrichment\yara"
$ScanLog = "C:\log\yara-scan.log"

if (-not (Test-Path -Path $YaraExe)) {
    Write-DateLog "ERROR: yara.exe not found at ${YaraExe}" | Tee-Object -FilePath "C:\log\yarascan.txt" -Append
    Write-Output "" > "C:\log\yarascan_done"
    exit 1
}

if (-not (Test-Path -Path $YaraDir)) {
    Write-DateLog "ERROR: YARA enrichment directory not found at ${YaraDir}" | Tee-Object -FilePath "C:\log\yarascan.txt" -Append
    Write-Output "" > "C:\log\yarascan_done"
    exit 1
}

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
    Write-DateLog "ERROR: No YARA rule files found in ${YaraDir}" | Tee-Object -FilePath "C:\log\yarascan.txt" -Append
    Write-Output "" > "C:\log\yarascan_done"
    exit 1
}

$ScanTargets = @("C:\Tools", "C:\venv", "C:\git")

# Verify scan targets exist
foreach ($Target in $ScanTargets) {
    if (-not (Test-Path -Path $Target)) {
        Write-DateLog "WARNING: Scan target not found, skipping: ${Target}" | Tee-Object -FilePath "C:\log\yarascan.txt" -Append
    }
}
$ScanTargets = $ScanTargets | Where-Object { Test-Path -Path $_ }

if ($ScanTargets.Count -eq 0) {
    Write-DateLog "ERROR: No scan targets available." | Tee-Object -FilePath "C:\log\yarascan.txt" -Append
    Write-Output "" > "C:\log\yarascan_done"
    exit 1
}

Write-DateLog "Starting YARA scan of $($ScanTargets -join ', ')..." | Tee-Object -FilePath "C:\log\yarascan.txt" -Append
Write-DateLog "Using YARA rules: $($YaraRules[0].FullName)" | Tee-Object -FilePath "C:\log\yarascan.txt" -Append
Write-DateLog "YARA executable: ${YaraExe}" | Tee-Object -FilePath "C:\log\yarascan.txt" -Append

# Verify yara.exe is callable
$versionOut = & $YaraExe --version 2>&1
Write-DateLog "YARA version: ${versionOut} (exit ${LASTEXITCODE})" | Tee-Object -FilePath "C:\log\yarascan.txt" -Append

"" | Out-File -FilePath $ScanLog -Encoding utf8

foreach ($RuleFile in $YaraRules) {
    Write-DateLog "Scanning with ruleset: $($RuleFile.Name)" | Tee-Object -FilePath "C:\log\yarascan.txt" -Append
    foreach ($Target in $ScanTargets) {
        Write-DateLog "Running: & '${YaraExe}' --recursive '$($RuleFile.FullName)' '${Target}'" | Tee-Object -FilePath "C:\log\yarascan.txt" -Append
        & $YaraExe --recursive $RuleFile.FullName $Target 2>&1 |
            ForEach-Object { "$_" } | Tee-Object -FilePath $ScanLog -Append | Tee-Object -FilePath "C:\log\yarascan.txt" -Append
        if ($LASTEXITCODE -ne 0) {
            Write-DateLog "WARNING: yara.exe exited with code ${LASTEXITCODE} for target ${Target}" | Tee-Object -FilePath "C:\log\yarascan.txt" -Append
        }
    }
}

Write-DateLog "YARA scan complete. Results saved to $ScanLog" | Tee-Object -FilePath "C:\log\yarascan.txt" -Append

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > "C:\log\yarascan_done"
