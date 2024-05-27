# Set default encoding to UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

if (! (Test-Path "${WSDFIR_TEMP}")) {
    New-Item -ItemType Directory -Force -Path "${WSDFIR_TEMP}" | Out-Null
}

Write-Output "Get-Content C:\log\rust.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

Write-DateLog "Install Rust tools in Sandbox." >> "C:\log\rust.txt"

Write-DateLog "Install GitBash (in the background)." >> "C:\log\rust.txt"
Install-GitBash >> "C:\log\rust.txt"
Write-DateLog "Install Rust." >> "C:\log\rust.txt"
Install-Rust >> "C:\log\rust.txt"

# Alternative install method for Rust
#Set-Location "${HOME}" >> "C:\log\rust.txt"
#curl -o "rustup-init.exe" "https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe" >> "C:\log\rust.txt"
#& ".\rustup-init.exe" --default-host x86_64-pc-windows-gnu -y >> "C:\log\rust.txt"
#$env:PATH="${env:HOME}\.cargo\bin;${env:ProgramFiles}\Git\bin;${env:ProgramFiles}\Git\usr\bin;${env:PATH}"

# Set PATH to include Rust and Git
$env:PATH="${RUST_DIR}\bin;${env:ProgramFiles}\Git\bin;${env:ProgramFiles}\Git\usr\bin;${env:PATH}"

# Install Rust tools
# Currently disabled due to issues with the Rust compiler
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
#cargo install --root "C:\cargo" CuTE-tui 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"
# https://github.com/janstarke/regview
# https://github.com/janstarke/ntdsextract2

Write-DateLog "Rust: Done installing Rust based tools in sandbox." >> "C:\log\rust.txt"

Write-Output "" > "C:\cargo\done"
