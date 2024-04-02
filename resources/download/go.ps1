param (
    [String] $ScriptRoot=$PSScriptRoot
)

${ScriptRoot} = "${ScriptRoot}\resources\download"
${ROOT_PATH} = Resolve-Path "${ScriptRoot}\..\..\"

. "${ScriptRoot}\common.ps1"

Write-DateLog "Start Sandbox to install GoLang based tools for dfirws." > "${ROOT_PATH}\log\golang.txt"

$mutex = New-Object System.Threading.Mutex($false, $mutexName)

$STATUS = $false

$LATEST_PROTODUMP_VERSION = (curl -s https://api.github.com/repos/arkadiyt/protodump/commits | ConvertFrom-Json)[0].commit.url.Split("commits/")[1].Substring(0,12)

if (Test-Path -Path "${ROOT_PATH}\mount\golang\pkg\mod\github.com\arkadiyt\*" ) {
    $STATUS = (Get-ChildItem "${ROOT_PATH}\mount\golang\pkg\mod\github.com\arkadiyt\*" | Select-String -Pattern "${LATEST_PROTODUMP_VERSION}").Matches.Success
}

if (! ${STATUS}) {
    Write-DateLog "Install and update GoLang tools in Sandbox." >> "${ROOT_PATH}\log\golang.txt"
    if (! (Test-Path -Path "${ROOT_PATH}\tmp\golang" )) {
        New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\tmp\golang" | Out-Null
    }

    if (Test-Path -Path "${ROOT_PATH}\mount\golang" ) {
        Remove-Item -r -Force "${ROOT_PATH}\mount\golang" | Out-Null
    }

    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\golang" | Out-Null

    if (Test-Path -Path "${ROOT_PATH}\tmp\golang\done" ) {
        Remove-Item "${ROOT_PATH}\tmp\golang\done" | Out-Null
    }

    (Get-Content "${ROOT_PATH}\resources\templates\generate_golang.wsb.template").replace("__SANDBOX__", "${ROOT_PATH}") | Set-Content "${ROOT_PATH}\tmp\generate_golang.wsb"

    $mutex.WaitOne() | Out-Null
    & "${ROOT_PATH}\tmp\generate_golang.wsb"
    Start-Sleep 10
    Remove-Item "${ROOT_PATH}\tmp\generate_golang.wsb" | Out-Null

    Stop-SandboxWhenDone "${ROOT_PATH}\tmp\golang\done" $mutex | Out-Null

    rclone.exe sync --verbose --checksum "${ROOT_PATH}\tmp\golang" "${ROOT_PATH}\mount\golang"
    Remove-Item -Recurse -Force "${ROOT_PATH}\tmp\golang" 2>&1 | Out-Null

    Write-DateLog "GoLang tools done." >> "${ROOT_PATH}\log\golang.txt"
} else {
    Write-DateLog "GoLang tools already installed and up to date." >> "${ROOT_PATH}\log\golang.txt"
}