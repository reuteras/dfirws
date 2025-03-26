. ".\resources\download\common.ps1"

$ROOT_PATH = "${PWD}"

Write-DateLog "Start Sandbox to install Python packages for dfirws." > "${ROOT_PATH}\log\python.txt"

if (! (Test-Path "${ROOT_PATH}\mount\Tools\bin\uv.exe")) {
    Write-Output "ERROR: uv.exe not found. Exiting" >> "${ROOT_PATH}\log\python.txt"
    Exit
}

if (Test-Path -Path "${ROOT_PATH}\mount\venv\") {
    Remove-Item -Recurse -Force -Path "${ROOT_PATH}\mount\venv" | Out-Null
}
New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\venv" | Out-Null

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

Copy-Item "${ROOT_PATH}\setup\utils\hash-id.py" "${ROOT_PATH}\mount\Tools\bin\"
Copy-Item "${ROOT_PATH}\setup\utils\ipexpand.py" "${ROOT_PATH}\mount\Tools\bin\"
Copy-Item "${ROOT_PATH}\setup\utils\powershell-cleanup.py" "${ROOT_PATH}\mount\Tools\bin\"

#Get-ChildItem -Path "${ROOT_PATH}\mount\venv\default\Scripts" -Filter *.py | ForEach-Object {
#    ${content} = Get-Content $_.FullName
#    if (${content}[0] -match "^#!/usr/bin/python3" -or ${content}[0] -match "^#!/usr/bin/env python3") {
#        ${content} -replace '^#!/usr/bin/.*', '#!/usr/bin/env python' | Set-Content $_.FullName
#    }
#}

Write-DateLog "Pip packages done." >> "${ROOT_PATH}\log\python.txt"