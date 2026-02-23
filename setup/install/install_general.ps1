# Set default encoding to UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

Write-DateLog "Install general tools in Sandbox." | Tee-Object -FilePath "C:\log\general.txt" -Append

if (! (Test-Path "${WSDFIR_TEMP}")) {
    New-Item -ItemType Directory -Force -Path "${WSDFIR_TEMP}" | Out-Null
}

Write-Output "Get-Content C:\log\general.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

# Find r2pm in the Tools directory
$r2pm = $null
$r2pmPaths = @(
    "${TOOLS}\radare2\bin\r2pm.cmd",
    "${TOOLS}\radare2\bin\r2pm.bat",
    "${TOOLS}\radare2\bin\r2pm"
)

foreach ($path in $r2pmPaths) {
    if (Test-Path $path) {
        $r2pm = $path
        break
    }
}

if ($null -eq $r2pm) {
    Write-DateLog "Error: r2pm not found in ${TOOLS}\radare2\bin. Is radare2 installed?" | Tee-Object -FilePath "C:\log\general.txt" -Append
} else {
    Write-DateLog "General: Found r2pm at $r2pm." | Tee-Object -FilePath "C:\log\general.txt" -Append

    # Install r2mcp
    Write-DateLog "General: Installing r2mcp via r2pm." | Tee-Object -FilePath "C:\log\general.txt" -Append
    & $r2pm -ci r2mcp 2>&1 | ForEach-Object { "$_" } | Tee-Object -FilePath "C:\log\general.txt" -Append

    # Install r2ai
    Write-DateLog "General: Installing r2ai via r2pm." | Tee-Object -FilePath "C:\log\general.txt" -Append
    & $r2pm -ci r2ai 2>&1 | ForEach-Object { "$_" } | Tee-Object -FilePath "C:\log\general.txt" -Append
}

Write-DateLog "General: Done installing general tools in sandbox." | Tee-Object -FilePath "C:\log\general.txt" -Append

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > "C:\log\general_done"
