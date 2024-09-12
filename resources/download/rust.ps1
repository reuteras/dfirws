param (
    [String] $ScriptRoot=$PSScriptRoot
)

${ScriptRoot} = "${ScriptRoot}\resources\download"
${ROOT_PATH} = Resolve-Path "${ScriptRoot}\..\..\"

. "${ScriptRoot}\common.ps1"

Write-DateLog "Start Sandbox to install Rust based tools for dfirws." > "${ROOT_PATH}\log\rust.txt"

$mutex = New-Object System.Threading.Mutex($false, $mutexName)

# Requires gcc to compile
${CURRENT_VERSION_DFIR_TOOLKIT} = (curl --silent -L "https://crates.io/api/v1/crates/dfir-toolkit" | ConvertFrom-Json).crate.max_stable_version
${CURRENT_VERSION_CUTE_TUI} = (curl --silent -L "https://crates.io/api/v1/crates/cute-tui" | ConvertFrom-Json).crate.max_stable_version
${CURRENT_VERSION_MFT2BODYFILE} = (curl --silent -L "https://crates.io/api/v1/crates/mft2bodyfile" | ConvertFrom-Json).crate.max_stable_version
${CURRENT_VERSION_USNJRNL} = (curl --silent -L "https://crates.io/api/v1/crates/usnjrnl" | ConvertFrom-Json).crate.max_stable_version

${STATUS} = $true

if (Test-Path -Path "${ROOT_PATH}\mount\Tools\cargo\.crates.toml" ) {
    ${STATUS} = (Get-Content "${ROOT_PATH}\mount\Tools\cargo\.crates.toml" | Select-String -Pattern "dfir-toolkit ${CURRENT_VERSION_DFIR_TOOLKIT}").Matches.Success
    if (${STATUS}) {
        ${STATUS} = (Get-Content "${ROOT_PATH}\mount\Tools\cargo\.crates.toml" | Select-String -Pattern "CuTE-tui ${CURRENT_VERSION_CUTE_TUI}").Matches.Success
    }
    if (${STATUS}) {
        ${STATUS} = (Get-Content "${ROOT_PATH}\mount\Tools\cargo\.crates.toml" | Select-String -Pattern "mft2bodyfile ${CURRENT_VERSION_MFT2BODYFILE}").Matches.Success
    }
    if (${STATUS}) {
        ${STATUS} = (Get-Content "${ROOT_PATH}\mount\Tools\cargo\.crates.toml" | Select-String -Pattern "usnjrnl ${CURRENT_VERSION_USNJRNL}").Matches.Success
    }
} else {
    ${STATUS} = $false
}

if (! ${STATUS}) {
    if (! (Test-Path -Path "${ROOT_PATH}\tmp\cargo" )) {
        New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\tmp\cargo" | Out-Null
    }

    if (Test-Path -Path "${ROOT_PATH}\mount\Tools\cargo" ) {
        Remove-Item -r -Force "${ROOT_PATH}\mount\Tools\cargo" | Out-Null
    }

    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\Tools\cargo" | Out-Null

    if (Test-Path -Path "${ROOT_PATH}\tmp\cargo\done" ) {
        Remove-Item "${ROOT_PATH}\tmp\cargo\done" | Out-Null
    }

    (Get-Content "${ROOT_PATH}\resources\templates\generate_rust.wsb.template").replace("__SANDBOX__", "${ROOT_PATH}") | Set-Content "${ROOT_PATH}\tmp\generate_rust.wsb"

    $mutex.WaitOne() | Out-Null
    & "${ROOT_PATH}\tmp\generate_rust.wsb"
    Start-Sleep 10
    Remove-Item "${ROOT_PATH}\tmp\generate_rust.wsb" | Out-Null

    Stop-SandboxWhenDone "${ROOT_PATH}\tmp\cargo\done" $mutex | Out-Null

    rclone.exe sync --verbose --checksum "${ROOT_PATH}\tmp\cargo" "${ROOT_PATH}\mount\Tools\cargo"
    Remove-Item -Recurse -Force "${ROOT_PATH}\tmp\cargo" 2>&1 | Out-Null

    Write-DateLog "Rust tools done." >> "${ROOT_PATH}\log\rust.txt"
} else {
    Write-DateLog "Rust tools already installed and up to date." >> "${ROOT_PATH}\log\rust.txt"
}