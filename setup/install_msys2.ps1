$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

# This script runs in a Windows sandbox to install msys2 tools.
Write-DateLog "Install MSYS2" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"

New-Item -ItemType Directory "${WSDFIR_TEMP}" 2>&1 | ForEach-Object{ "$_" } | Out-Null

Write-Output "Get-Content C:\log\msys2.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

# Update path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
& "${SETUP_PATH}\msys2.exe" -y -oC:\ 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
$env:CHERE_INVOKING = 'yes'
$env:MSYSTEM = 'UCRT64'

& "C:\msys64\usr\bin\bash.exe" -lc ' ' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
& "C:\msys64\usr\bin\bash.exe" -lc 'rm -rf /etc/pacman.d/gnupg/' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
& "C:\msys64\usr\bin\bash.exe" -lc 'pacman-key --init' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
& "C:\msys64\usr\bin\bash.exe" -lc 'pacman-key --populate msys2' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
& "C:\msys64\usr\bin\bash.exe" -lc 'pacman-key --populate' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
& "C:\msys64\usr\bin\bash.exe" -lc 'pacman-key --populate' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
& "C:\msys64\usr\bin\bash.exe" -lc 'pacman --noconfirm -Syuu' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
& "C:\msys64\usr\bin\bash.exe" -lc 'pacman --noconfirm -Syuu' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
& "C:\msys64\usr\bin\bash.exe" -lc 'pacman --noconfirm -Syu bc binutils cpio expect git gnu-netcat mingw-w64-ucrt-x86_64-autotools mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-make mingw-w64-ucrt-x86_64-toolchain nasm ncurses ncurses-devel pv rsync tree zsh vim' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"

Write-DateLog "MSYS2 installation done." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
Write-Output "" > "C:\msys64\done"
