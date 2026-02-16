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

    # Copy source repository to writable location (git mount is read-only)
    New-Item -ItemType Directory -Force -Path "C:\tmp\r2ai_build" | Out-Null
    Copy-Item -Recurse "C:\git\r2ai\*" "C:\tmp\r2ai_build\" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"

    # Build r2ai with msys2 toolchain.
    # Prefer explicit plugin targets to avoid optional `r2check` failures in CI.
    $r2aiBuildScriptPathWin = "C:\tmp\r2ai_build\build-r2ai.sh"
$r2aiBuildScript = @'
set -euo pipefail
export PKG_CONFIG_PATH=/c/Tools/radare2/lib/pkgconfig
export PATH=/ucrt64/bin:/usr/bin:/c/Tools/radare2/bin:$PATH
MAKE_BIN=$(command -v make || command -v mingw32-make || command -v gmake || true)
if [ -z "$MAKE_BIN" ]; then
  echo "make not found in PATH=$PATH"
  ls -l /usr/bin/make /ucrt64/bin/make* 2>/dev/null || true
  exit 127
fi
cd /c/tmp/r2ai_build
"$MAKE_BIN" -C src clean >/dev/null 2>&1 || true
# r2pm uses `make -C src`; try explicit plugin targets first to bypass `r2check`.
"$MAKE_BIN" -C src DOTLIB=.dll DOTEXE=.exe r2ai.dll || "$MAKE_BIN" -C src DOTLIB=.dll DOTEXE=.exe r2ai || "$MAKE_BIN" -C src DOTLIB=.dll DOTEXE=.exe all || true
'@
    $r2aiBuildScript | Out-File -FilePath $r2aiBuildScriptPathWin -Encoding ascii -Force
    & "C:\Tools\msys64\usr\bin\bash.exe" -lc 'bash /c/tmp/r2ai_build/build-r2ai.sh' 2>&1 | Tee-Object -FilePath "C:\log\msys2.txt" -Append
    $r2aiBuildExitCode = $LASTEXITCODE
    if ($r2aiBuildExitCode -ne 0) {
        Write-DateLog "r2ai build command exited with code $r2aiBuildExitCode." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
        Write-Output "r2ai build command exited with code $r2aiBuildExitCode"
    }
    # Copy output to persistent location
    $r2ai_output = "C:\Tools\msys64\r2ai_build"
    New-Item -ItemType Directory -Force -Path "$r2ai_output" | Out-Null
    $pluginCandidates = @(
        "C:\tmp\r2ai_build\src\r2ai.dll",
        "C:\tmp\r2ai_build\src\r2ai",
        "C:\tmp\r2ai_build\src\*r2ai*.dll",
        "C:\tmp\r2ai_build\src\*.dll"
    )
    $pluginPath = $null
    foreach ($candidate in $pluginCandidates) {
        $match = Get-Item $candidate -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($match) {
            $pluginPath = $match.FullName
            break
        }
    }

    if ($pluginPath) {
        Copy-Item $pluginPath "$r2ai_output\r2ai.dll" -Force
        if (Test-Path "C:\tmp\r2ai_build\src\r2ai.exe") {
            Copy-Item "C:\tmp\r2ai_build\src\r2ai.exe" "$r2ai_output\r2ai.exe" -Force
        }
        Write-DateLog "r2ai plugin compiled successfully from $pluginPath." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
        Write-Output "r2ai plugin compiled successfully."
    } else {
        Write-DateLog "r2ai build artifacts in C:\tmp\r2ai_build:" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\msys2.txt"
        Get-ChildItem -Path "C:\tmp\r2ai_build" -Force 2>&1 | Tee-Object -FilePath "C:\log\msys2.txt" -Append
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
