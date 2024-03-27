# Script to download files needed in sandboxes during download.

. "$PSScriptRoot\common.ps1"

#
# Packages used in all sandboxes
#

# https://www.7-zip.org/download.html - 7-Zip - installed during start
$status = Get-FileFromUri -uri "https://www.7-zip.org/a/7z2301-x64.msi" -FilePath ".\downloads\7zip.msi" -CheckURL "Yes"

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
    $NodeJSVersion = (Get-DownloadUrlFromPage -url "https://nodejs.org/en/download/prebuilt-binaries" -RegEx 'Active LTS[^W]+versionWithPrefix[^,]+').Split(",")[3].Split(":")[1].Replace('\"', '')

    # nodejs - installed via sandbox during download and setup of tools for dfirws
    $status = Get-FileFromUri -uri "https://nodejs.org/dist/${NodeJSVersion}/node-${NodeJSVersion}-win-x64.zip" -FilePath ".\downloads\nodejs.zip" -CheckURL "Yes"
}

#
# Packages used in Python sandbox
#

if ($all -or $Python) {
    # https://www.python.org/downloads/ - Python - installed during start
    Clear-Tmp winget
    Write-SynchronizedLog "winget: Downloading Python."
    Get-WinGet "Python.Python.3.11"
    if (Test-Path .\tmp\winget\Python*.exe) {
        Copy-Item .\tmp\winget\Python*.exe ".\downloads\python3.exe"
    }
    Clear-Tmp winget

    # Get Amazon Corretto - installed during start
    $status = Get-FileFromUri -uri "https://corretto.aws/downloads/latest/amazon-corretto-21-x64-windows-jdk.msi" -FilePath ".\downloads\corretto.msi"

    # Ghidra - latest release
    $status = Get-GitHubRelease -repo "NationalSecurityAgency/ghidra" -path "${SETUP_PATH}\ghidra.zip" -match "_PUBLIC_"
    if ($status) {
        & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ghidra.zip" -o"${TOOLS}" | Out-Null
        if (Test-Path "${TOOLS}\ghidra") {
            Remove-Item "${TOOLS}\ghidra" -Recurse -Force
        }
        New-Item -ItemType Directory -Force -Path "${TOOLS}\ghidra" | Out-Null
        Move-Item ${TOOLS}\ghidra_* "${TOOLS}\ghidra\"
        Copy-Item "${TOOLS}\ghidra\*\support\ghidra.ico" "${TOOLS}\ghidra" -Recurse -Force
    }

    # Ghidra - older release
    $status = Get-FileFromUri -uri "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.4_build/ghidra_10.4_PUBLIC_20230928.zip" -FilePath "${SETUP_PATH}\ghidra_10.4_PUBLIC_20230928.zip" -CheckURL "Yes"
    if ($status) {
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

#
# Packages used in Bash sandbox
#

if ($all -or $Bash) {
    # zsdt
    $status = Get-GitHubRelease -repo "facebook/zstd" -path "${SETUP_PATH}\zstd.zip" -match "win64.zip$"
    if ($status) {
        & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa ".\downloads\zstd.zip" -o"${TOOLS}" | Out-Null
        if (Test-Path "${TOOLS}\zstd") {
            Remove-Item "${TOOLS}\zstd" -Recurse -Force
        }
        Move-Item ${TOOLS}\zstd-* "${TOOLS}\zstd" | Out-Null
    }
}

#
# Packages used in Rust sandbox
#

if ($all -or $Rust) {
    # git - installed during start
    $status = Get-GitHubRelease -repo "git-for-windows/git" -path "${SETUP_PATH}\git.exe" -match "64-bit.exe"

    # Rust - available for installation via dfirws-install.ps1
    Clear-Tmp winget
    Write-SynchronizedLog "winget: Downloading Rust."
    Get-WinGet "Rustlang.Rust.GNU"
    if (Test-Path .\tmp\winget\Rust*.msi) {
        Copy-Item .\tmp\winget\Rust*.msi ".\downloads\rust.msi"
    }
    Clear-Tmp winget
}
