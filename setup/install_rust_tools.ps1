# Set default encoding to UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

if (! (Test-Path "${WSDFIR_TEMP}")) {
    New-Item -ItemType Directory -Force -Path "${WSDFIR_TEMP}" | Out-Null
}

Write-Output "Get-Content C:\log\rust.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

Write-DateLog "Install Rust tools in Sandbox." >> "C:\log\rust.txt"

Write-DateLog "Install Git (in the background)." >> "C:\log\rust.txt"
Install-Git >> "C:\log\rust.txt"
Write-DateLog "Install Rust." >> "C:\log\rust.txt"
Install-Rust >> "C:\log\rust.txt"
Write-DateLog "Install MSYS2." >> "C:\log\rust.txt"
Install-MSYS2 >> "C:\log\rust.txt"

# Set PATH to include Rust and Git
$env:PATH="${RUST_DIR}\bin;${env:ProgramFiles}\Git\bin;${env:ProgramFiles}\Git\usr\bin;${env:PATH};${MSYS2_DIR};${MSYS2_DIR}\ucrt64\bin;${MSYS2_DIR}\usr\bin"

# Install Rust tools
Write-DateLog "Rust: Install dfir-toolkit in sandbox." >> "C:\log\rust.txt"
cargo install --root "C:\cargo" "dfir-toolkit" 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"

if (!(Test-Path "C:\cargo\autocomplete")) {
    New-Item -ItemType Directory -Force -Path "C:\cargo\autocomplete" | Out-Null
}

$env:PATH="${env:PATH};C:\cargo\bin"
(Get-ChildItem "C:\cargo\bin").Name | ForEach-Object { & "$_" --autocomplete powershell > "C:\cargo\autocomplete\$_.ps1"} 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"

Write-DateLog "Rust: Install mft2bodyfile, usnjrnl in sandbox." >> "C:\log\rust.txt"
cargo install --root "C:\cargo" mft2bodyfile 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"
cargo install --root "C:\cargo" usnjrnl 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"
# Requires gcc to compile
cargo install --root "C:\cargo" CuTE-tui 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"

Set-Location "C:\tmp"
git clone https://github.com/CrzPhil/SSHniff.git
Set-Location "C:\tmp\SSHniff\sshniff"
cargo build --release
Copy-Item ".\target\release\sshniff.exe" "C:\cargo\bin\sshniff.exe"

Write-DateLog "Rust: Done installing Rust based tools in sandbox." >> "C:\log\rust.txt"

Write-Output "" > "C:\cargo\done"
