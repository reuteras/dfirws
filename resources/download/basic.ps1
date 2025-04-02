# Script to download files needed in sandboxes during download.

. ".\resources\download\common.ps1"

# https://www.7-zip.org/download.html - 7-Zip - installed during start
Write-SynchronizedLog "Downloading 7-Zip."
$7zip_path = Get-DownloadUrlFromPage -url "https://www.7-zip.org/download.html" -RegEx '[^"]+x64.msi'
$status = Get-FileFromUri -uri "https://www.7-zip.org/${7zip_path}" -FilePath ".\downloads\7zip.msi" -CheckURL "Yes" -check "Composite Document File V2 Document"

#
# Packages used in freshclam sandbox
if ($all -or $Freshclam) {
    # ClamAV - installed during start
    $status = Get-GitHubRelease -repo "Cisco-Talos/clamav" -path "${SETUP_PATH}\clamav.msi" -match "win.x64.msi$" -check "Composite Document File V2 Document"
}

#
# Packages used in NodeJS sandbox
if ($all -or $Node) {
    $NodeJSVersion = (Get-DownloadUrlFromPage -url "https://nodejs.org/en/download/prebuilt-binaries" -RegEx 'https://nodejs.org/dist/(v[^/]+)').split('/')[4]

    # nodejs - installed via sandbox during download and setup of tools for dfirws
    $status = Get-FileFromUri -uri "https://nodejs.org/dist/${NodeJSVersion}/node-${NodeJSVersion}-win-x64.zip" -FilePath ".\downloads\nodejs.zip" -CheckURL "Yes" -check "Zip archive data"
}

#
# Packages used in Python sandbox
if ($all -or $Python) {
    # https://www.python.org/downloads/ - Python - installed during start
    Write-SynchronizedLog "winget: Downloading Python."
    $status = Get-WinGet "Python.Python.3.11" "Python*.exe" "python3.exe" -check "PE32"

    # Get Amazon Corretto - installed during start
    $status = Get-FileFromUri -uri "https://corretto.aws/downloads/latest/amazon-corretto-21-x64-windows-jdk.msi" -FilePath ".\downloads\corretto.msi" -check "Composite Document File V2 Document"

    # Ghidra - latest release
    $status_current = Get-GitHubRelease -repo "NationalSecurityAgency/ghidra" -path "${SETUP_PATH}\ghidra.zip" -match "_PUBLIC_" -check "Zip archive data"
    $status_old = Get-FileFromUri -uri "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.4_build/ghidra_10.4_PUBLIC_20230928.zip" -FilePath "${SETUP_PATH}\ghidra_10.4_PUBLIC_20230928.zip" -CheckURL "Yes" -check "Zip archive data"
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
    $status = Get-GitHubRelease -repo "mandiant/Ghidrathon" -path "${SETUP_PATH}\ghidrathon.zip" -match "Ghidrathon" -check "Zip archive data"
    if ($status) {
        if (Test-Path "${TOOLS}\ghidrathon") {
            Remove-Item "${TOOLS}\ghidrathon" -Recurse -Force
        }
        & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ghidrathon.zip" -o"${TOOLS}\ghidrathon" | Out-Null
    }

    # Tools to compile and build - version 2019
    $status = Get-FileFromUri -uri "https://aka.ms/vs/16/release/vs_BuildTools.exe" -FilePath ".\downloads\vs_BuildTools.exe" -check "PE32"
}

# MSYS2
if ($all -or $MSYS2) {
    $status = Get-FileFromUri -uri "https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe" -FilePath "${SETUP_PATH}\msys2.exe" -CheckURL "No" -check "PE32"
    if ($status) {
        Copy-Item "${SETUP_PATH}\msys2.exe" "${TOOLS}\bin\msys2.exe"
    }
}

#
# Packages used in Go sandbox
if ($all -or $Go) {
    # GoLang - available for installation via dfirws-install.ps1
    Write-SynchronizedLog "winget: Downloading GoLang."
    $status = Get-WinGet "GoLang.Go" "Go*.msi" "golang.msi" -check "Composite Document File V2 Document"
}

#
# Packages used in Rust sandbox
if ($all -or $Rust) {
    # git - installed during start
    $status = Get-GitHubRelease -repo "git-for-windows/git" -path "${SETUP_PATH}\git.exe" -match "64-bit.exe" -check "PE32"

    # Rust - available for installation via dfirws-install.ps1
    Write-SynchronizedLog "winget: Downloading Rust."
    $status = Get-WinGet "Rustlang.Rust.GNU" "Rust*.msi" "rust.msi" -check "Composite Document File V2 Document"
}
