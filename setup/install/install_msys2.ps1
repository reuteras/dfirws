$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

# This script runs in a Windows sandbox to install msys2 tools.
Write-Output "Install or upgrade MSYS2."
Write-DateLog "Install or upgrade MSYS2" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"

New-Item -ItemType Directory "${WSDFIR_TEMP}" 2>&1 | ForEach-Object{ "$_" } | Out-Null

Write-Output "Get-Content C:\log\msys2.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

# Update path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$env:CHERE_INVOKING = 'yes'
$env:MSYSTEM = 'UCRT64'

if (Test-Path -Path "C:\Tools\msys64\usr\bin\bash.exe") {
    Write-DateLog "MSYS2 already installed, updating." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    Write-Output "MSYS2 already installed, updating."
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc 'pacman --noconfirm -Syuu' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    Write-DateLog "MSYS2 update done." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    Write-Output "MSYS2 update done."
} else {
    Write-DateLog "MSYS2 installation." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    Write-Output "MSYS2 installation."
    & "${SETUP_PATH}\msys2.exe" -y -oC:\Tools 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc ' ' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc 'rm -rf /etc/pacman.d/gnupg/' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc 'pacman-key --init' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc 'pacman-key --populate msys2' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc 'pacman-key --populate' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc 'pacman-key --populate' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc 'pacman --noconfirm -Syuu' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc 'pacman --noconfirm -Syuu' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc 'pacman --noconfirm -Syu bc binutils cpio expect git gnu-netcat mingw-w64-ucrt-x86_64-autotools mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-make mingw-w64-ucrt-x86_64-toolchain nasm ncurses ncurses-devel pv rsync tree zsh vim' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    Write-DateLog "MSYS2 installation done." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    Write-Output "MSYS2 installation done."
}

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > "C:\Tools\msys64\done"
