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

## Compile r2ai plugin if radare2 and r2ai source are available
if ((Test-Path "C:\git\r2ai\src\Makefile") -and (Test-Path "C:\Tools\radare2\bin\radare2.exe")) {
    Write-DateLog "Compiling r2ai plugin for radare2." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    Write-Output "Compiling r2ai plugin for radare2."

    # Set up build environment
    $env:CHERE_INVOKING = 'yes'
    $env:MSYSTEM = 'UCRT64'
    $env:PKG_CONFIG_PATH = "C:\Tools\radare2\lib\pkgconfig"

    # Create r2 alias for radare2 (the Makefile expects 'r2' command in PATH)
    Copy-Item "C:\Tools\radare2\bin\radare2.exe" "C:\Tools\radare2\bin\r2.exe" -Force

    # Copy source to writable location (git mount is read-only)
    New-Item -ItemType Directory -Force -Path "C:\tmp\r2ai_build" | Out-Null
    Copy-Item -Recurse "C:\git\r2ai\src\*" "C:\tmp\r2ai_build\" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"

    # Build r2ai with msys2 toolchain
    # Ensure r2 is accessible in MSYS2 PATH (r2check target runs 'r2 -NN -qcq --')
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc "export PKG_CONFIG_PATH=/c/Tools/radare2/lib/pkgconfig && export PATH=/ucrt64/bin:/usr/bin:/c/Tools/radare2/bin:\$PATH && command -v r2 || cp /c/Tools/radare2/bin/radare2.exe /ucrt64/bin/r2.exe && cd /c/tmp/r2ai_build && make DOTEXE=.exe" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"

    # Copy output to persistent location
    $r2ai_output = "C:\Tools\msys64\r2ai_build"
    New-Item -ItemType Directory -Force -Path "$r2ai_output" | Out-Null
    if (Test-Path "C:\tmp\r2ai_build\r2ai.dll") {
        Copy-Item "C:\tmp\r2ai_build\r2ai.dll" "$r2ai_output\r2ai.dll" -Force
        if (Test-Path "C:\tmp\r2ai_build\r2ai.exe") {
            Copy-Item "C:\tmp\r2ai_build\r2ai.exe" "$r2ai_output\r2ai.exe" -Force
        }
        Write-DateLog "r2ai plugin compiled successfully." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
        Write-Output "r2ai plugin compiled successfully."
    } else {
        Write-DateLog "r2ai compilation failed - r2ai.dll not found." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
        Write-Output "r2ai compilation failed - check C:\log\msys2.txt for details."
    }
} else {
    Write-DateLog "Skipping r2ai compilation (prerequisites not available)." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
}

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > "C:\Tools\msys64\done"
