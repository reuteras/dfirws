# Set default encoding to UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

Write-Output "Install Rust tools in Sandbox."

if (! (Test-Path "${WSDFIR_TEMP}")) {
    New-Item -ItemType Directory -Force -Path "${WSDFIR_TEMP}" | Out-Null
}
if (!(Test-Path "C:\cargo\autocomplete")) {
    New-Item -ItemType Directory -Force -Path "C:\cargo\autocomplete" | Out-Null
}

Write-Output "Get-Content C:\log\rust.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

Write-DateLog "Install Git (in the background)." >> "C:\log\rust.txt"
Install-Git >> "C:\log\rust.txt"
Write-DateLog "Install Rust." >> "C:\log\rust.txt"
Install-Rust >> "C:\log\rust.txt"

# Set PATH to include Rust and Git
$env:PATH="${RUST_DIR}\bin;${env:ProgramFiles}\Git\bin;${env:ProgramFiles}\Git\usr\bin;${env:PATH}"
Add-ToUserPath "${MSYS2_DIR}"
Add-ToUserPath "${MSYS2_DIR}\ucrt64\bin"
Add-ToUserPath "${MSYS2_DIR}\usr\bin"
$env:PATH="${env:PATH};C:\cargo\bin;" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install Rust tools
Write-Output "Rust: Install dfir-toolkit in sandbox."
Write-DateLog "Rust: Install dfir-toolkit in sandbox." >> "C:\log\rust.txt"
cargo install --root "C:\cargo" "dfir-toolkit" 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"

(Get-ChildItem "C:\cargo\bin").Name | ForEach-Object { & "$_" --autocomplete powershell > "C:\cargo\autocomplete\$_.ps1"} 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"

Write-Output "Rust: Install mft2bodyfile, usnjrnl in sandbox."
Write-DateLog "Rust: Install mft2bodyfile, usnjrnl in sandbox." >> "C:\log\rust.txt"
cargo install --root "C:\cargo" mft2bodyfile 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"

Write-Output "Rust: Install usnjrnl in sandbox."
Write-DateLog "Rust: Install usnjrnl in sandbox." >> "C:\log\rust.txt"
cargo install --root "C:\cargo" usnjrnl 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"

Write-Output "Rust: Install CuTE-tui in sandbox."
Write-DateLog "Rust: Install CuTE-tui in sandbox." >> "C:\log\rust.txt"
cargo install --root "C:\cargo" CuTE-tui 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"

Write-Output "Rust: Install SSHniff in sandbox."
Write-DateLog "Rust: Install SSHniff in sandbox." >> "C:\log\rust.txt"
Set-Location "C:\tmp"
git clone https://github.com/CrzPhil/SSHniff.git 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"
Set-Location "C:\tmp\SSHniff\sshniff"
cargo build --release 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"
Copy-Item ".\target\release\sshniff.exe" "C:\cargo\bin\sshniff.exe"

Write-DateLog "Rust: Done installing Rust based tools in sandbox." >> "C:\log\rust.txt"

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > "C:\cargo\done"
