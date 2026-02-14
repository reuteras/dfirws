. ".\resources\download\common.ps1"

$ROOT_PATH = "${PWD}"

Write-DateLog "Start Sandbox to install Python packages for dfirws." > "${ROOT_PATH}\log\python.txt"

if (! (Test-Path "${ROOT_PATH}\mount\Tools\bin\uv.exe")) {
    Write-Output "ERROR: uv.exe not found. Exiting" >> "${ROOT_PATH}\log\python.txt"
    Exit
}

if (Test-Path -Path "${ROOT_PATH}\mount\venv\") {
    Get-ChildItem -Path "${ROOT_PATH}\mount\venv\" -Directory | Where-Object { $_.Name -ne "cache" } | Remove-Item -Recurse -Force | Out-Null
}
New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\venv" | Out-Null

(Get-Content ${ROOT_PATH}\resources\templates\generate_venv.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}\") | Set-Content "${ROOT_PATH}\tmp\generate_venv.wsb"
Start-Process "${ROOT_PATH}\tmp\generate_venv.wsb"
Wait-Sandbox -WSBPath "${ROOT_PATH}\tmp\generate_venv.wsb" -WaitForPath "${ROOT_PATH}\mount\venv\default\done"

Copy-Item "${ROOT_PATH}\setup\utils\hash-id.py" "${ROOT_PATH}\mount\Tools\bin\"
Copy-Item "${ROOT_PATH}\setup\utils\ipexpand.py" "${ROOT_PATH}\mount\Tools\bin\"
Copy-Item "${ROOT_PATH}\setup\utils\powershell-cleanup.py" "${ROOT_PATH}\mount\Tools\bin\"

# Fix shebang lines in Python scripts
Get-ChildItem -Path "${ROOT_PATH}\mount\venv\default\Scripts","${ROOT_PATH}\mount\venv\bin","${ROOT_PATH}\mount\Tools\bin" -Filter *.py | ForEach-Object {
    ${content} = Get-Content $_.FullName
    if (${content}[0] -match "^#!/usr/bin/python" -or ${content}[0] -match "^#!/usr/bin/env python3") {
        ${content} -replace '^#!/usr/bin/.*', '#!/usr/bin/env python' | Set-Content $_.FullName
    }
}

# Add .py extension to all files in bin directory that don't have an extension
Get-ChildItem -Exclude *.* .\mount\venv\bin\ | ForEach-Object { Move-Item "$_" "$_.py" }

Write-DateLog "Pip packages done." >> "${ROOT_PATH}\log\python.txt"

if (Test-Path -Path "${ROOT_PATH}\log\dfirws" ) {
    Copy-Item "${ROOT_PATH}\log\dfirws\*_python.ps1" "${ROOT_PATH}\downloads\dfirws\" -Force
    Copy-Item "${ROOT_PATH}\log\dfirws\tools_python.json" "${ROOT_PATH}\downloads\dfirws\" -Force
    Remove-Item -Recurse -Force "${ROOT_PATH}\log\dfirws" 2>&1 | Out-Null
}
