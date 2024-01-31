# Script to download files needed in sandboxes during download.

. "$PSScriptRoot\common.ps1"

#
# Packages used in all sandboxes
#

# https://www.7-zip.org/download.html - 7-Zip - installed during start
Get-FileFromUri -uri "https://www.7-zip.org/a/7z2301-x64.msi" -FilePath ".\downloads\7zip.msi" -CheckURL "Yes"

#
# Packages used in NodeJS sandbox
#

if ($all -or $Node) {
    $nodejs = Get-DownloadUrlFromPage -url "https://nodejs.org/en/download/" -RegEx 'https:[^"]+win-x64.zip'

    # nodejs - installed via sandbox during download and setup of tools for dfirws
    Get-FileFromUri -uri "${nodejs}" -FilePath ".\downloads\nodejs.zip" -CheckURL "Yes"
}

#
# Packages used in Python sandbox
#

if ($all -or $Python) {
    # https://www.python.org/downloads/ - Python - installed during start
    Get-FileFromUri -uri "https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe" -FilePath ".\downloads\python3.exe" -CheckURL "Yes"

    # Get Amazon Corretto - installed during start
    Get-FileFromUri -uri "https://corretto.aws/downloads/latest/amazon-corretto-21-x64-windows-jdk.msi" -FilePath ".\downloads\corretto.msi"

    # Ghidra - latest release
    Get-GitHubRelease -repo "NationalSecurityAgency/ghidra" -path "${SETUP_PATH}\ghidra.zip" -match "ghidra"
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ghidra.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\ghidra") {
        Remove-Item "${TOOLS}\ghidra" -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path "${TOOLS}\ghidra" | Out-Null
    Move-Item ${TOOLS}\ghidra_* "${TOOLS}\ghidra\"

    # Ghidra - older release
    Get-FileFromUri -uri "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.4_build/ghidra_10.4_PUBLIC_20230928.zip" -FilePath "${SETUP_PATH}\ghidra_10.4_PUBLIC_20230928.zip" -CheckURL "Yes"
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ghidra_10.4_PUBLIC_20230928.zip" -o"${TOOLS}\ghidra" | Out-Null

    # Ghidrathon source
    Get-GitHubRelease -repo "mandiant/Ghidrathon" -path "${SETUP_PATH}\ghidrathon.zip" -match "Source"
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ghidrathon.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\ghidrathon") {
        Remove-Item "${TOOLS}\ghidrathon" -Recurse -Force
    }
    Move-Item ${TOOLS}\mandiant-Ghidrathon* "${TOOLS}\ghidrathon"

    # Tools to compile and build - version 2019
    Get-FileFromUri -uri "https://aka.ms/vs/16/release/vs_BuildTools.exe" -FilePath ".\downloads\vs_BuildTools.exe"
}

#
# Packages used in Bash sandbox
#

if ($all -or $Bash) {
    # zsdt
    Get-GitHubRelease -repo "facebook/zstd" -path "${SETUP_PATH}\zstd.zip" -match "win64.zip"
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa ".\downloads\zstd.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\zstd") {
        Remove-Item "${TOOLS}\zstd" -Recurse -Force
    }
    Move-Item ${TOOLS}\zstd-* "${TOOLS}\zstd" | Out-Null
}

#
# Packages used in Rust sandbox
#

if ($all -or $Rust) {
    # git - installed during start
    Get-GitHubRelease -repo "git-for-windows/git" -path "${SETUP_PATH}\git.exe" -match "64-bit.exe"

    # Rust - available for installation via dfirws-install.ps1
    Clear-Tmp winget
    Write-SynchronizedLog "winget: Downloading Rust."
    Get-WinGet "Rustlang.Rust.GNU"
    if (Test-Path .\tmp\winget\Rust*.msi) {
        Copy-Item .\tmp\winget\Rust*.msi ".\downloads\rust.msi"
    }
    Clear-Tmp winget
}
