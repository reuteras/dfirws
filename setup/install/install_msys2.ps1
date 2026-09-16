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

# Explicitly installed packages - also used for changelog version tracking.
$MSYS2_PACKAGES = @(
    "bc", "binutils", "cpio", "expect", "git", "gnu-netcat",
    "mingw-w64-ucrt-x86_64-autotools", "mingw-w64-ucrt-x86_64-cmake",
    "mingw-w64-ucrt-x86_64-gcc", "mingw-w64-ucrt-x86_64-make",
    "mingw-w64-ucrt-x86_64-toolchain", "nasm", "ncurses", "ncurses-devel",
    "pv", "rsync", "tree", "zsh", "vim"
)

if (Test-Path -Path "C:\Tools\msys64\usr\bin\bash.exe") {
    Write-DateLog "MSYS2 already installed, updating." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    Write-Output "MSYS2 already installed, updating."
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc 'pacman --noconfirm -Syuu' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    Save-Msys2Metadata -Packages $MSYS2_PACKAGES 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
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
    # pacman-key starts gpg-agent which holds msys-gcrypt-20.dll open; kill it before
    # pacman upgrade so libgcrypt can be replaced (otherwise GPGME breaks for all later runs).
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc 'gpgconf --kill all' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    Get-Process | Where-Object { try { $_.MainModule.FileName -like "C:\Tools\msys64\*" } catch { $false } } | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc 'pacman --noconfirm -Syuu' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc 'gpgconf --kill all' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    Get-Process | Where-Object { try { $_.MainModule.FileName -like "C:\Tools\msys64\*" } catch { $false } } | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc 'pacman --noconfirm -Syuu' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc "pacman --noconfirm -Syu $($MSYS2_PACKAGES -join ' ')" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    Save-Msys2Metadata -Packages $MSYS2_PACKAGES 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    Write-DateLog "MSYS2 installation done." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    Write-Output "MSYS2 installation done."
}

#
# pycdc - Python bytecode decompiler (pycdc) and disassembler (pycdas).
# Upstream publishes no binaries, so it is built here with the MSYS2 UCRT64
# toolchain and linked statically so it runs without the msys64 DLLs on PATH.
# Built from git, so the changelog version is the short commit hash.
#
Write-DateLog "Build pycdc." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
Write-Output "Build pycdc."
$BASH = "C:\Tools\msys64\usr\bin\bash.exe"
$PYCDC_SRC = "${WSDFIR_TEMP}\pycdc"
if (Test-Path -Path $PYCDC_SRC) {
    Remove-Item -Recurse -Force $PYCDC_SRC 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
}
& $BASH -lc 'git clone --depth 1 https://github.com/zrax/pycdc.git /c/tmp/pycdc' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
# CMAKE_SH=CMAKE_SH-NOTFOUND lets the MinGW generator run from an MSYS shell that has sh.exe on PATH.
& $BASH -lc 'cd /c/tmp/pycdc && cmake -S . -B build -G "MinGW Makefiles" -DCMAKE_SH=CMAKE_SH-NOTFOUND -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXE_LINKER_FLAGS="-static" && cmake --build build --config Release' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"

if ((Test-Path -Path "${PYCDC_SRC}\build\pycdc.exe") -and (Test-Path -Path "${PYCDC_SRC}\build\pycdas.exe")) {
    New-Item -ItemType Directory -Force -Path "C:\Tools\bin" | Out-Null
    Copy-Item "${PYCDC_SRC}\build\pycdc.exe" "C:\Tools\bin\pycdc.exe" -Force
    Copy-Item "${PYCDC_SRC}\build\pycdas.exe" "C:\Tools\bin\pycdas.exe" -Force
    $PYCDC_COMMIT = (& $BASH -lc 'git -C /c/tmp/pycdc rev-parse --short HEAD' 2>$null | Out-String).Trim()
    if ($PYCDC_COMMIT) {
        $metadataDir = "C:\Tools\.metadata\msys2"
        if (!(Test-Path $metadataDir)) {
            New-Item -ItemType Directory -Force -Path $metadataDir | Out-Null
        }
        $metadata = [ordered]@{
            Name      = "pycdc"
            Version   = $PYCDC_COMMIT
            Source    = "msys2"
            FetchedAt = (Get-Date).ToString("s")
        }
        Set-Content -Path "$metadataDir\pycdc.json" -Value ($metadata | ConvertTo-Json -Depth 2)
    }
    Write-DateLog "pycdc build done (commit ${PYCDC_COMMIT})." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    Write-Output "pycdc build done."
} else {
    Write-DateLog "ERROR: pycdc build failed, pycdc.exe/pycdas.exe not found." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
    Write-Output "ERROR: pycdc build failed."
}

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > "C:\Tools\msys64\done"
