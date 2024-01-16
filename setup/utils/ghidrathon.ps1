# Import common functions
. $HOME\Documents\tools\wscommon.ps1

if (! (Test-Path -Path "${VENV}\jep" )) {
    Write-Output "ERROR: JEP and ghidrathon not installed. Change config.ps1 and rerun downloadFiles.ps1."
    Exit
}

deactivate
& "${VENV}\jep\Scripts\Activate.ps1"
$env:PYTHONPATH="${VENV}\jep\Lib\site-packages;C:\Program Files\Python311\Lib"

if (!(Test-Path -Path "${HOME}\.ghidra\.ghidra_10.4_PUBLIC\Extensions\ghidrathon")) {
    & "$env:programfiles\7-Zip\7z.exe" x -o"${HOME}\.ghidra\.ghidra_10.4_PUBLIC\Extensions" "$TOOLS\ghidra_extensions\ghidrathon.zip"
}

& "${TOOLS}\ghidra\ghidra_10.4_PUBLIC\ghidraRun.bat"
