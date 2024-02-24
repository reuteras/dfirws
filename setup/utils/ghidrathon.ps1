# Import common functions
. "${HOME}\Documents\tools\wscommon.ps1"

if (! (Test-Path -Path "${VENV}\jep" )) {
    Write-Output "ERROR: JEP and ghidrathon not installed. Change config.ps1 and rerun downloadFiles.ps1."
    Exit
}

deactivate
& "${VENV}\jep\Scripts\Activate.ps1"
$env:PYTHONPATH="${VENV}\jep\Lib\site-packages;C:\Program Files\Python311\Lib"

$LATEST_GHIDRA_RELEASE = (Get-ChildItem C:\Tools\ghidra\).Name | findstr.exe PUBLIC | Select-Object -Last 1
$LATEST_GHIDRATHON = (Get-ChildItem C:\Tools\ghidra_extensions\).FullName | Select-Object -Last 1

if (!(Test-Path -Path "${HOME}\.ghidra\.${LATEST_GHIDRA_RELEASE}\Extensions\ghidrathon")) {
    & "$env:programfiles\7-Zip\7z.exe" x -o"${HOME}\.ghidra\.${LATEST_GHIDRA_RELEASE}\Extensions" "${LATEST_GHIDRATHON}" | Out-Null
}

& "${TOOLS}\ghidra\${LATEST_GHIDRA_RELEASE}\ghidraRun.bat"
