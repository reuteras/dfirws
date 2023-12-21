# Script to download files needed in sandboxes during download.

. $PSScriptRoot\common.ps1

$nodejs = Get-DownloadUrlFromPage -url https://nodejs.org/en/download/ -RegEx 'https:[^"]+win-x64.zip'

# https://www.7-zip.org/download.html - 7-Zip - installed during start
Get-FileFromUri -uri "https://www.7-zip.org/a/7z2301-x64.msi" -FilePath ".\downloads\7zip.msi"

# https://www.python.org/downloads/ - Python - installed during start
Get-FileFromUri -uri "https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe" -FilePath ".\downloads\python3.exe"

# nodejs - installed via sandbox during download and setup of tools for dfirws
Get-FileFromUri -uri "$nodejs" -FilePath ".\downloads\nodejs.zip"

# Tools to compile and build - version 2019
Get-FileFromUri -uri "https://aka.ms/vs/16/release/vs_BuildTools.exe" -FilePath ".\downloads\vs_BuildTools.exe"

# Get Amazon Corretto - installed during start
Get-FileFromUri -uri "https://corretto.aws/downloads/latest/amazon-corretto-21-x64-windows-jdk.msi" -FilePath ".\downloads\corretto.msi"

# Ghidrathon source
Get-GitHubRelease -repo "mandiant/Ghidrathon" -path "$SETUP_PATH\ghidrathon.zip" -match Source
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\ghidrathon.zip" -o"$TOOLS" | Out-Null
if (Test-Path $TOOLS\ghidrathon) {
    Remove-Item $TOOLS\ghidrathon -Recurse -Force
}
Move-Item $TOOLS\mandiant-Ghidrathon* $TOOLS\ghidrathon

# zsdt
Get-GitHubRelease -repo "facebook/zstd" -path "$SETUP_PATH\zstd.zip" -match win64.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa ".\downloads\zstd.zip" -o"$TOOLS" | Out-Null
if (Test-Path "$TOOLS\zstd") {
    Remove-Item "$TOOLS\zstd" -Recurse -Force
}
Move-Item $TOOLS\zstd-* $TOOLS\zstd | Out-Null