# Import common functions
. $HOME\Documents\tools\wscommon.ps1

if (! (Test-Path -Path "${VENV}\jep" )) {
    Write-Output "ERROR: JEP and ghidrathon not installed. Change config.ps1 and rerun downloadFiles.ps1."
    Exit
}

deactivate
& "${VENV}\jep\Scripts\Activate.ps1"
$env:PYTHONPATH="${VENV}\jep\Lib\site-packages;C:\Program Files\Python311\Lib"

$LATEST_GHIDRA_RELEASE = (Get-ChildItem C:\Tools\ghidra\ | Select-String PUBLIC -Raw | Select-Object -Last 1).Split("\")[-1]

if (!(Test-Path -Path "${HOME}\.ghidra\.${LATEST_GHIDRA_RELEASE}\Extensions\ghidrathon")) {
    & "$env:programfiles\7-Zip\7z.exe" x -o"${HOME}\.ghidra\.${LATEST_GHIDRA_RELEASE}\Extensions" "${TOOLS}\ghidra_extensions\ghidrathon.zip"
}

& "${TOOLS}\ghidra\${LATEST_GHIDRA_RELEASE}\ghidraRun.bat"
