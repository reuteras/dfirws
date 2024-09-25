# Script to download files needed in sandboxes during download.

. "$PSScriptRoot\common.ps1"

#
# Packages used in all sandboxes
#

# 7-Zip - installed during startup
Write-SynchronizedLog "winget: Downloading 7-Zip."
Get-WinGet "7zip.7zip" "7z*.msi" "7zip.msi"

#
# Packages used in freshclam sandbox
#

if ($all -or $Freshclam) {
    # ClamAV - installed during start
    $status = Get-GitHubRelease -repo "Cisco-Talos/clamav" -path "${SETUP_PATH}\clamav.msi" -match "win.x64.msi$"
}

#
# Packages used in NodeJS sandbox
#

if ($all -or $Node) {
    $NodeJSVersion = (Get-DownloadUrlFromPage -url "https://nodejs.org/en/download/prebuilt-binaries" -RegEx 'Download Node.js v[^<]+').split(' ')[2]

    # nodejs - installed via sandbox during download and setup of tools for dfirws
    $status = Get-FileFromUri -uri "https://nodejs.org/dist/${NodeJSVersion}/node-${NodeJSVersion}-win-x64.zip" -FilePath ".\downloads\nodejs.zip" -CheckURL "Yes"
}

#
# Packages used in Python sandbox
#

if ($all -or $Python) {
    # https://www.python.org/downloads/ - Python - installed during start
    Write-SynchronizedLog "winget: Downloading Python."
    Get-WinGet "Python.Python.3.11" "Python*.exe" "python3.exe"

    # Get Amazon Corretto - installed during start
    $status = Get-FileFromUri -uri "https://corretto.aws/downloads/latest/amazon-corretto-21-x64-windows-jdk.msi" -FilePath ".\downloads\corretto.msi"

    # Ghidra - latest release
    $status_current = Get-GitHubRelease -repo "NationalSecurityAgency/ghidra" -path "${SETUP_PATH}\ghidra.zip" -match "_PUBLIC_"
    $status_old = Get-FileFromUri -uri "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.4_build/ghidra_10.4_PUBLIC_20230928.zip" -FilePath "${SETUP_PATH}\ghidra_10.4_PUBLIC_20230928.zip" -CheckURL "Yes"
    if ($status_current -or $status_old) {
        if (Test-Path "${TOOLS}\ghidra") {
            Remove-Item "${TOOLS}\ghidra" -Recurse -Force
        }
        & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ghidra.zip" -o"${TOOLS}" | Out-Null
        New-Item -ItemType Directory -Force -Path "${TOOLS}\ghidra" | Out-Null
        Move-Item ${TOOLS}\ghidra_1* "${TOOLS}\ghidra\"
        Copy-Item "${TOOLS}\ghidra\*\support\ghidra.ico" "${TOOLS}\ghidra" -Recurse -Force
        & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ghidra_10.4_PUBLIC_20230928.zip" -o"${TOOLS}\ghidra" | Out-Null
    }

    # Ghidrathon source
    $status = Get-GitHubRelease -repo "mandiant/Ghidrathon" -path "${SETUP_PATH}\ghidrathon.zip" -match "Ghidrathon"
    if ($status) {
        if (Test-Path "${TOOLS}\ghidrathon") {
            Remove-Item "${TOOLS}\ghidrathon" -Recurse -Force
        }
        & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ghidrathon.zip" -o"${TOOLS}\ghidrathon" | Out-Null
    }

    # Tools to compile and build - version 2019
    $status = Get-FileFromUri -uri "https://aka.ms/vs/16/release/vs_BuildTools.exe" -FilePath ".\downloads\vs_BuildTools.exe"
}

# MSYS2
$status = Get-FileFromUri -uri "https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe" -FilePath "${SETUP_PATH}\msys2.exe" -CheckURL "No"
if ($status) {
    Copy-Item "${SETUP_PATH}\msys2.exe" "${TOOLS}\bin\msys2.exe"
}


#
# Pages used in Go sandbox
#

if ($all -or $Go) {
    # GoLang - available for installation via dfirws-install.ps1
    Write-SynchronizedLog "winget: Downloading GoLang."
    Get-WinGet "GoLang.Go" "Go*.msi" "golang.msi"
}


#
# Packages used in Rust sandbox
#

if ($all -or $Rust) {
    # git - installed during start
    $status = Get-GitHubRelease -repo "git-for-windows/git" -path "${SETUP_PATH}\git.exe" -match "64-bit.exe"

    # Rust - available for installation via dfirws-install.ps1
    Write-SynchronizedLog "winget: Downloading Rust."
    Get-WinGet "Rustlang.Rust.GNU" "Rust*.msi" "rust.msi"
}
