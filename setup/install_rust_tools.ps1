# Set default encoding to UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1

if (! (Test-Path "$TEMP")) {
    New-Item -ItemType Directory -Force -Path "$TEMP" > $null
}

Write-Output "Get-Content C:\log\rust.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

Write-DateLog "Install Rust tools in Sandbox." >> "C:\log\rust.txt"

Write-DateLog "Install GitBash (in the background)." >> "C:\log\rust.txt"
Install-GitBash
Write-DateLog "Install Rust." >> "C:\log\rust.txt"
Install-Rust

# Set PATH to include Rust and Git
$env:PATH="C:\Rust\bin;$env:ProgramFiles\Git\bin;$env:ProgramFiles\Git\usr\bin;$env:PATH"

# Install Rust tools
Write-DateLog "Rust: Install dfir-toolkit in sandbox." >> "C:\log\rust.txt"
cargo install --root "C:\cargo" dfir-toolkit 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"
Write-DateLog "Rust: Done installing Rust based tools in sandbox." >> "C:\log\rust.txt"

Write-Output "" > "C:\cargo\done"