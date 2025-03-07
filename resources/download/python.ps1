. ".\resources\download\common.ps1"

$ROOT_PATH = "${PWD}"

Write-DateLog "Start Sandbox to install Python pip packages for dfirws." > "${ROOT_PATH}\log\python.txt"

if (! (Test-Path -Path "${ROOT_PATH}\mount\venv\")) {
    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\venv" | Out-Null
}

if (Test-Path -Path "${ROOT_PATH}\mount\venv\default\done") {
    Remove-Item "${ROOT_PATH}\mount\venv\default\done" | Out-Null
}

Copy-Item "${ROOT_PATH}\config.ps1" "${ROOT_PATH}\mount\venv\config.ps1"

if (! (Test-Path "${ROOT_PATH}\downloads\python3.exe")) {
    Write-Output "ERROR: Python3 not found. Exiting" >> "${ROOT_PATH}\log\python.txt"
    Exit
}

$python3_hash = (Get-FileHash -Path "${ROOT_PATH}\downloads\python3.exe" -Algorithm SHA256).Hash

if (Test-Path -Path "${ROOT_PATH}\mount\venv\python3_hash.txt") {
    $python3_hash_venv = Get-Content "${ROOT_PATH}\mount\venv\python3_hash.txt"
    if ("${python3_hash}" -ne "${python3_hash_venv}") {
        Write-Output "Python3 hash changed. Remove venv and build new." >> "${ROOT_PATH}\log\python.txt"
        Remove-Item "${ROOT_PATH}\mount\venv" -Recurse -Force | Out-Null
        New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\venv" | Out-Null
        Write-Output "${python3_hash}" > "${ROOT_PATH}\mount\venv\python3_hash.txt"
    }
} else {
    Write-Output $python3_hash > "${ROOT_PATH}\mount\venv\python3_hash.txt"
}

(Get-Content ${ROOT_PATH}\resources\templates\generate_venv.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}\") | Set-Content "${ROOT_PATH}\tmp\generate_venv.wsb"

Start-Process "${ROOT_PATH}\tmp\generate_venv.wsb"

do {
    Start-Sleep 10
    if (Test-Path -Path "${ROOT_PATH}\mount\venv\default\done" ) {
        Stop-Sandbox
        Remove-Item  -Force "${ROOT_PATH}\tmp\generate_venv.wsb" | Out-Null
        break
    }
} while (
    tasklist | Select-String "(WindowsSandboxClient|WindowsSandboxRemote)"
)

Copy-Item "${ROOT_PATH}\setup\utils\hash-id.py" "${ROOT_PATH}\mount\venv\default\Scripts\"
Copy-Item "${ROOT_PATH}\setup\utils\ipexpand.py" "${ROOT_PATH}\mount\venv\default\Scripts\"
Copy-Item "${ROOT_PATH}\setup\utils\powershell-cleanup.py" "${ROOT_PATH}\mount\venv\default\Scripts\"

Get-ChildItem -Path "${ROOT_PATH}\mount\venv\default\Scripts" -Filter *.py | ForEach-Object {
    ${content} = Get-Content $_.FullName
    if (${content}[0] -match "^#!/usr/bin/python3" -or ${content}[0] -match "^#!/usr/bin/env python3") {
        ${content} -replace '^#!/usr/bin/.*', '#!/usr/bin/env python' | Set-Content $_.FullName
    }
}

Write-DateLog "Pip packages done." >> "${ROOT_PATH}\log\python.txt"