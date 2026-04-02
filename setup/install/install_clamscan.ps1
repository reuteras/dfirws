$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

# This script runs in a Windows sandbox to scan tools with ClamAV.
Write-DateLog "Install ClamAV and run scan" | Tee-Object -FilePath "C:\log\clamscan.txt" -Append

New-Item -ItemType Directory "${WSDFIR_TEMP}" 2>&1 | Out-Null

Write-Output "Get-Content C:\log\clamscan.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

Install-ClamAV
while (-not (Test-Path -Path "C:\Program Files\ClamAV\clamscan.exe")) {
    Start-Sleep -Seconds 1
}

$ClamDB = "${TOOLS}\ClamAV\db"
$ClamscanExe = 'C:\Program Files\ClamAV\clamscan.exe'
$ClamscanArgs = @(
    '--recursive',
    '--infected',
    '--suppress-ok-results',
    "--database=$ClamDB",
    '--heuristic-alerts=yes',
    '--heuristic-scan-precedence=yes',
    '--alert-broken=yes',
    '--alert-encrypted-archive=yes',
    '--alert-macros=yes',
    '--alert-exceeds-max=yes',
    '--bytecode=yes',
    '--exclude-dir=^C:\\Windows',
    '--exclude-dir=^C:\\Program Files\\Windows Defender',
    '--exclude-dir=^C:\\ProgramData\\Microsoft\\Windows Defender',
    '--exclude-dir=^C:\\Tools\\ClamAV',
    '--exclude-dir=__pycache__',
    '--exclude=\.lnk$',
    '--exclude=\.url$',
    '--exclude=\.mui$',
    '--exclude=\.cat$',
    '--exclude=\.manifest$',
    '--exclude=\.pyc$',
    '--max-filesize=200M',
    '--max-scansize=400M'
)

# Run one clamscan job per target directory in parallel to use multiple cores
Write-DateLog "Starting parallel ClamAV scan of C:\Tools, C:\venv and C:\git..." | Tee-Object -FilePath "C:\log\clamscan.txt" -Append

$ScanTargets = @("C:\Tools", "C:\venv", "C:\git")
$Jobs = foreach ($Target in $ScanTargets) {
    $TargetName = Split-Path $Target -Leaf
    $TargetLog  = "C:\log\clamav-scan-${TargetName}.log"
    Start-Job -Name "clamav-${TargetName}" -ScriptBlock {
        param($Exe, $Args, $Target, $Log)
        & $Exe @Args "--log=$Log" $Target 2>&1
    } -ArgumentList $ClamscanExe, $ClamscanArgs, $Target, $TargetLog
}

# Wait for all jobs and stream their output to the progress log
$Jobs | Wait-Job | Receive-Job | ForEach-Object{ "$_" } | Tee-Object -FilePath "C:\log\clamscan.txt" -Append
$Jobs | Remove-Job

# Merge per-target logs into one combined log
$ScanLog = "C:\log\clamav-scan.log"
foreach ($Target in $ScanTargets) {
    $TargetName = Split-Path $Target -Leaf
    $TargetLog  = "C:\log\clamav-scan-${TargetName}.log"
    if (Test-Path $TargetLog) {
        Get-Content $TargetLog | Add-Content $ScanLog
    }
}

Write-DateLog "ClamAV scan complete. Results saved to $ScanLog" | Tee-Object -FilePath "C:\log\clamscan.txt" -Append

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > "C:\log\clamscan_done"
