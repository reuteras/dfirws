. ".\resources\download\common.ps1"

$ROOT_PATH = "${PWD}"

Write-Output "${ROOT_PATH}"
Write-DateLog "Setup MSYS2 and install packages in Sandbox." > ${ROOT_PATH}\log\msys2.txt

# Create install directory for MSYS2
if (! (Test-Path -Path "${ROOT_PATH}\mount\Tools\msys64" )) {
    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\Tools\msys64" | Out-Null
} elseif (Test-Path -Path "${ROOT_PATH}\mount\Tools\msys64\done") {
    Remove-Item "${ROOT_PATH}\mount\Tools\msys64\done" | Out-Null
}

# Create WSB file for MSYS2 and run it
(Get-Content ${ROOT_PATH}\resources\templates\generate_msys2.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}\") | Set-Content "${ROOT_PATH}\tmp\generate_msys2.wsb"
Start-Process "${ROOT_PATH}\tmp\generate_msys2.wsb"

do {
    Start-Sleep 10
    if (Test-Path -Path "${ROOT_PATH}\mount\Tools\msys64\done" ) {
        Stop-Sandbox
        Remove-Item "${ROOT_PATH}\tmp\generate_msys2.wsb" | Out-Null
        Start-Sleep 1
    }
} while (
    tasklist | Select-String "(WindowsSandboxClient|WindowsSandboxRemote)"
)

# Change tmp directory
Write-Output "C:/tmp/msys2 /tmp ntfs auto 0 0" >> "${ROOT_PATH}\mount\Tools\msys64\etc\fstab"

# Copy MSYS2 to Tools
Write-DateLog "MSYS2 and packages done." >> ${ROOT_PATH}\log\msys2.txt 2>&1
