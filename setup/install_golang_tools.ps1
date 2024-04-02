# Set default encoding to UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

if (! (Test-Path "${WSDFIR_TEMP}")) {
    New-Item -ItemType Directory -Force -Path "${WSDFIR_TEMP}" | Out-Null
}

Write-Output "Get-Content C:\log\golang.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

Write-DateLog "Install Golang tools in Sandbox." >> "C:\log\golang.txt"

Write-DateLog "Install GitBash (in the background)." >> "C:\log\golang.txt"
Install-GitBash >> "C:\log\golang.txt"
Write-DateLog "Install Golang." >> "C:\log\golang.txt"
Install-GoLang >> "C:\log\golang.txt"

# Install Golang tools

$env:PATH="${env:ProgramFiles}\Go\bin;${env:ProgramFiles}\Git\bin;${env:ProgramFiles}\Git\usr\bin;${env:PATH}"

Write-DateLog "Golang: Install protodump in sandbox." >> "C:\log\golang.txt"
go install github.com/arkadiyt/protodump/cmd/protodump@latest >> "C:\log\golang.txt"

Write-DateLog "Golang: Done installing Golang based tools in sandbox." >> "C:\log\golang.txt"

Write-Output "" > "C:\Users\WDAGUtilityAccount\go\done"
