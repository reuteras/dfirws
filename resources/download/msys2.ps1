. ".\resources\download\common.ps1"

$ROOT_PATH = "${PWD}"

Write-Output "${ROOT_PATH}"
Write-DateLog "Setup MSYS2 and install packages in Sandbox." > ${ROOT_PATH}\log\msys2.txt

if (! (Test-Path -Path "${ROOT_PATH}\tmp" )) {
    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\tmp" | Out-Null
}

# Remove old MSYS2 and create new directory
if (Test-Path -Path "${ROOT_PATH}\tmp\Tools" ) {
    Remove-Item -Recurse -Force "${ROOT_PATH}\tmp\Tools" | Out-Null
}

New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\tmp\Tools" | Out-Null

if (Test-Path -Path "${ROOT_PATH}\Tools\Debug" ) {
    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\tmp\Tools\Debug" | Out-Null
}

# Create install directory for MSYS2
if (! (Test-Path -Path "${ROOT_PATH}\mount\Tools\msys64" )) {
    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\Tools\msys64" | Out-Null
}

# Create WSB file for MSYS2 and run it
(Get-Content ${ROOT_PATH}\resources\templates\generate_msys2.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}\") | Set-Content "${ROOT_PATH}\tmp\generate_msys2.wsb"
Start-Process "${ROOT_PATH}\tmp\generate_msys2.wsb"

do {
    Start-Sleep 10
    if (Test-Path -Path "${ROOT_PATH}\tmp\Tools\msys64\done" ) {
        Stop-Sandbox
        Remove-Item "${ROOT_PATH}\tmp\generate_msys2.wsb" | Out-Null
        Start-Sleep 1
    }
} while (
    tasklist | Select-String "(WindowsSandboxClient|WindowsSandboxRemote)"
)

# Remove debug directory - use -recurse if there is any file created in the directory
if (Test-Path -Path "${ROOT_PATH}\tmp\Tools\Debug" ) {
    Remove-Item -Recurse -Force "${ROOT_PATH}\tmp\Tools\Debug" | Out-Null
}

# Change tmp directory
Write-Output "C:/tmp/msys2 /tmp ntfs auto 0 0" >> "${ROOT_PATH}\tmp\Tools\msys64\etc\fstab"

# Copy MSYS2 to Tools
rclone.exe sync --verbose --checksum "${ROOT_PATH}\tmp\Tools\msys64" "${ROOT_PATH}\mount\Tools\msys64" >> ${ROOT_PATH}\log\msys2.txt 2>&1
Write-DateLog "MSYS2 and packages done." >> ${ROOT_PATH}\log\msys2.txt 2>&1

Remove-Item -Recurse -Force "${ROOT_PATH}\tmp\Tools" 2>&1 | Out-Null
