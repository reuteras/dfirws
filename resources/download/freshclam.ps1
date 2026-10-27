. ".\resources\download\common.ps1"

$ROOT_PATH = "${PWD}"

Write-DateLog "Start Sandbox to install ClamAV and run freshclam." > "${ROOT_PATH}\log\freshclam.txt"

if (! (Test-Path -Path "${ROOT_PATH}\mount\Tools\ClamAV")) {
    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\Tools\ClamAV" | Out-Null
}

# The URLhaus ClamAV feed now requires an abuse.ch Auth-Key and is no longer
# downloaded. Remove the stale copy left by earlier runs.
if (Test-Path -Path "${ROOT_PATH}\mount\Tools\ClamAV\db\urlhaus.ndb") {
    Remove-Item "${ROOT_PATH}\mount\Tools\ClamAV\db\urlhaus.ndb" -Force | Out-Null
}

if (Test-Path -Path "${ROOT_PATH}\mount\Tools\ClamAV\done") {
    Remove-Item "${ROOT_PATH}\mount\Tools\ClamAV\done" | Out-Null
}

(Get-Content ${ROOT_PATH}\resources\templates\generate_freshclam.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}\") | Set-Content "${ROOT_PATH}\tmp\generate_freshclam.wsb"
Start-Process "${ROOT_PATH}\tmp\generate_freshclam.wsb"
Wait-Sandbox -WSBPath "${ROOT_PATH}\tmp\generate_freshclam.wsb" -WaitForPath "${ROOT_PATH}\mount\Tools\ClamAV\done"

Write-DateLog "Freshclam update done." >> "${ROOT_PATH}\log\freshclam.txt"