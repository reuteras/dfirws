param (
    [String] $ScriptRoot=$PSScriptRoot
)

$ScriptRoot = "$ScriptRoot\resources\download"
${ROOT_PATH} = Resolve-Path "$ScriptRoot\..\..\"

. $ScriptRoot\common.ps1

Write-DateLog "Start Sandbox to install Python pip packages for dfirws." > ${ROOT_PATH}\log\python.txt

$mutex = New-Object System.Threading.Mutex($false, $mutexName)

if (! (Test-Path -Path ${ROOT_PATH}\mount\venv )) {
    New-Item -ItemType Directory -Force -Path ${ROOT_PATH}\mount\venv | Out-Null
}

$venvs = @("chepy", "default", "dfir-unfurl", "dissect", "evt2sigma", "jep", "maldump", "pe2pic", "pySigma", "scare", "Zircolite")

foreach ($venv in $venvs) {
    if (! (Test-Path -Path ${ROOT_PATH}\mount\venv\${venv} )) {
        New-Item -ItemType Directory -Force -Path ${ROOT_PATH}\mount\venv\${venv} | Out-Null
    }
}

foreach ($venv in $venvs) {
    if (Test-Path -Path ${ROOT_PATH}\mount\venv\${venv}\${venv}.txt ) {
        Copy-Item "${ROOT_PATH}\mount\venv\${venv}\${venv}.txt" "${ROOT_PATH}\tmp\mount\venv\${venv}\${venv}.txt"
    }
}

if (Test-Path -Path ${ROOT_PATH}\mount\venv\default\done ) {
    Remove-Item ${ROOT_PATH}\mount\venv\default\done | Out-Null
}

Copy-Item "${ROOT_PATH}\config.ps1" "${ROOT_PATH}\mount\venv\default\config.ps1"

(Get-Content ${ROOT_PATH}\resources\templates\generate_venv.wsb.template).replace('__SANDBOX__', ${ROOT_PATH}) | Set-Content ${ROOT_PATH}\tmp\generate_venv.wsb

$mutex.WaitOne() | Out-Null
& ${ROOT_PATH}\tmp\generate_venv.wsb
Start-Sleep 10
Remove-Item ${ROOT_PATH}\tmp\generate_venv.wsb | Out-Null

Stop-SandboxWhenDone "${ROOT_PATH}\mount\venv\default\done" $mutex | Out-Null

Copy-Item "${ROOT_PATH}\setup\utils\hash-id.py" "${ROOT_PATH}\mount\venv\default\Scripts\"
Copy-Item "${ROOT_PATH}\setup\utils\ipexpand.py" "${ROOT_PATH}\mount\venv\default\Scripts\"
Copy-Item "${ROOT_PATH}\setup\utils\powershell-cleanup.py" "${ROOT_PATH}\mount\venv\default\Scripts\"

Get-ChildItem -Path "${ROOT_PATH}\mount\venv\default\Scripts" -Filter *.py | ForEach-Object {
    ${content} = Get-Content $_.FullName
    if (${content}[0] -match "^#!/usr/bin/python3" -or ${content}[0] -match "^#!/usr/bin/env python3") {
        ${content} -replace '^#!/usr/bin/.*', '#!/usr/bin/env python' | Set-Content $_.FullName
    }
}

Write-DateLog "Pip packages done." >> ${ROOT_PATH}\log\python.txt