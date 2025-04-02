. ".\resources\download\common.ps1"

${ROOT_PATH} = "${PWD}"

Write-DateLog "Start Sandbox to install GoLang based tools for dfirws." > "${ROOT_PATH}\log\golang.txt"

$STATUS = $false

$LATEST_PROTODUMP_VERSION = (curl -s https://api.github.com/repos/arkadiyt/protodump/commits | ConvertFrom-Json)[0].commit.url.Split("commits/")[1].Substring(0,12)

if (Test-Path -Path "${ROOT_PATH}\mount\golang\pkg\mod\github.com\arkadiyt\*" ) {
    $STATUS = (Get-ChildItem "${ROOT_PATH}\mount\golang\pkg\mod\github.com\arkadiyt\*" | Select-String -Pattern "${LATEST_PROTODUMP_VERSION}").Matches.Success
}

if (! ${STATUS}) {
    Write-DateLog "Install and update GoLang tools in Sandbox." >> "${ROOT_PATH}\log\golang.txt"
    if (! (Test-Path -Path "${ROOT_PATH}\tmp\golang" )) {
        New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\tmp\golang" | Out-Null
    } elseif (Test-Path -Path "${ROOT_PATH}\tmp\golang\done" ) {
        Remove-Item "${ROOT_PATH}\tmp\golang\done" | Out-Null
    }

    if (Test-Path -Path "${ROOT_PATH}\mount\golang" ) {
        Remove-Item -r -Force "${ROOT_PATH}\mount\golang" | Out-Null
    }

    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\golang" | Out-Null

    (Get-Content "${ROOT_PATH}\resources\templates\generate_golang.wsb.template").replace("__SANDBOX__", "${ROOT_PATH}\") | Set-Content "${ROOT_PATH}\tmp\generate_golang.wsb"
    Start-Process "${ROOT_PATH}\tmp\generate_golang.wsb"
    Wait-Sandbox -WSBPath "${ROOT_PATH}\tmp\generate_golang.wsb" -WaitForPath "${ROOT_PATH}\tmp\golang\done"

    rclone.exe sync --verbose --checksum "${ROOT_PATH}\tmp\golang" "${ROOT_PATH}\mount\golang" >> "${ROOT_PATH}\log\golang.txt" 2>&1
    Remove-Item -Recurse -Force "${ROOT_PATH}\tmp\golang" 2>&1 | Out-Null

    Write-DateLog "GoLang tools done." >> "${ROOT_PATH}\log\golang.txt"
} else {
    Write-DateLog "GoLang tools already installed and up to date." >> "${ROOT_PATH}\log\golang.txt"
}