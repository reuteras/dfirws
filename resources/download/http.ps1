. $PSScriptRoot\common.ps1

$TOOLS=".\mount\Tools"
$SETUP_PATH=".\downloads"

Write-DateLog "Download files via HTTP."

# Get uri for latest nuget - ugly
$choco = Get-ChocolateyUrl chocolatey
$nodejs = Get-DownloadUrlFromPage -url https://nodejs.org/en/download/ -regex 'https:[^"]+win-x64.zip'

# Get URI for Visual Studio Code python extension - ugly
$vscode_python_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=ms-python.python -regex '"AssetUri":"[^"]+python/([^/]+)/'
$vscode_tmp = $vscode_python_string | Select-String -Pattern '"AssetUri":"[^"]+python/([^/]+)/'
$vscode_python_version=$vscode_tmp.Matches.Groups[1].Value

# Get Visual Studio Code
Get-FileFromUri -uri "https://update.code.visualstudio.com/latest/win32-x64-user/stable" -FilePath ".\downloads\vscode.exe"
# Install during start

# Get SwiftOnSecurity sysmon config
Get-FileFromUri -uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -FilePath ".\downloads\sysmonconfig-export.xml"
# Used from sysmon

# Get Amazon Corretto
Get-FileFromUri -uri "https://corretto.aws/downloads/latest/amazon-corretto-17-x64-windows-jdk.msi" -FilePath ".\downloads\corretto.msi"
# Install during start

# Get Sysinternals Suite
Get-FileFromUri -uri "https://download.sysinternals.com/files/SysinternalsSuite.zip" -FilePath ".\downloads\sysinternals.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\sysinternals.zip" -o"$TOOLS\sysinternals" | Out-Null

# Get x64dbg
Get-FileFromUri -uri "https://sourceforge.net/projects/x64dbg/files/latest/download" -FilePath ".\downloads\x64dbg.zip"
# Install during start

# Get exiftool
Get-FileFromUri -uri "https://sourceforge.net/projects/exiftool/files/latest/download" -FilePath ".\downloads\exiftool.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\exiftool.zip" -o"$TOOLS\exiftool" | Out-Null
Move-Item "$TOOLS\exiftool\exiftool(-k).exe" $TOOLS\exiftool\exiftool.exe

# Get pestudio
Get-FileFromUri -uri "https://www.winitor.com/tools/pestudio/current/pestudio.zip" -FilePath ".\downloads\pestudio.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\pestudio.zip" -o"$TOOLS\pestudio" | Out-Null

# Get HxD
Get-FileFromUri -uri "https://mh-nexus.de/downloads/HxDSetup.zip" -FilePath ".\downloads\hxd.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\hxd.zip" -o"$TOOLS\hxd" | Out-Null

# Get trid and triddefs
Get-FileFromUri -uri "https://mark0.net/download/trid_w32.zip" -FilePath ".\downloads\trid.zip"
Get-FileFromUri -uri "https://mark0.net/download/triddefs.zip" -FilePath ".\downloads\triddefs.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\trid.zip" -o"$TOOLS\trid" | Out-Null
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\triddefs.zip" -o"$TOOLS\trid" | Out-Null

# Get malcat
Get-FileFromUri -uri "https://malcat.fr/latest/malcat_win64_lite.zip" -FilePath ".\downloads\malcat.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\malcat.zip" -o"$TOOLS\malcat" | Out-Null

# Get ssview
Get-FileFromUri -uri "https://www.mitec.cz/Downloads/SSView.zip" -FilePath ".\downloads\ssview.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\ssview.zip" -o"$TOOLS\ssview" | Out-Null

# Get yara rules
Get-FileFromUri -uri "https://raw.githubusercontent.com/reuteras/yara-rules/master/signature/signature.7z" -FilePath ".\downloads\signature.7z"
Get-FileFromUri -uri "https://raw.githubusercontent.com/reuteras/yara-rules/master/total/total.7z" -FilePath ".\downloads\total.7z"

# msidump
Get-FileFromUri -uri "https://raw.githubusercontent.com/mgeeky/msidump/main/msidump.py" -FilePath ".\downloads\msidump.py"
# Add by install_python_tools.ps1

# FullEventLogView
Get-FileFromUri -uri "https://www.nirsoft.net/utils/fulleventlogview-x64.zip" -FilePath ".\downloads\logview.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\logview.zip" -o"$TOOLS\FullEventLogView" | Out-Null

# pstwalker
Get-FileFromUri -uri "https://downloads.pstwalker.com/pstwalker-portable" -FilePath ".\downloads\pstwalker.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\pstwalker.zip" -o"$TOOLS" | Out-Null
if (Test-Path -Path $TOOLS\pstwalker) {
    Remove-Item -Recurse -Force $TOOLS\pstwalker | Out-Null 2>&1
}
Move-Item $TOOLS\pstwalker* $TOOLS\pstwalker

# fqlite
Get-FileFromUri -uri "https://www.staff.hs-mittweida.de/~pawlaszc/fqlite/downloads/fqlite_windows_x64.zip" -FilePath ".\downloads\fqlite.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\fqlite.zip" -o"$TOOLS" | Out-Null
if (Test-Path -Path $TOOLS\__MACOSX) {
    Remove-Item -Recurse -Force $TOOLS\__MACOSX | Out-Null 2>&1
}

# Win API Search
Get-FileFromUri -uri "https://dennisbabkin.com/php/downloads/WinApiSearch.zip" -FilePath ".\downloads\WinApiSearch.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\WinApiSearch.zip" -o"$TOOLS\WinApiSearch" | Out-Null

# pdfstreamdumper
Get-FileFromUri -uri "http://sandsprite.com/CodeStuff/PDFStreamDumper_Setup.exe" -FilePath ".\downloads\pdfstreamdumper.exe"
# Install during start

# Plugins for Cutter
Get-FileFromUri -uri "https://raw.githubusercontent.com/yossizap/x64dbgcutter/master/x64dbgcutter.py" -FilePath ".\downloads\x64dbgcutter.py"
Get-FileFromUri -uri "https://raw.githubusercontent.com/malware-kitten/cutter_scripts/master/scripts/cutter_stackstrings.py" -FilePath ".\downloads\cutter_stackstrings.py"

# Resource Hacker
Get-FileFromUri -uri "https://www.angusj.com/resourcehacker/resource_hacker.zip" -FilePath ".\downloads\resource_hacker.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\resource_hacker.zip" -o"$TOOLS\resource_hacker" | Out-Null

# chocolatey
Get-FileFromUri -uri "$choco" -FilePath ".\downloads\choco.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\choco.zip" -o"$SETUP_PATH\choco" | Out-Null

# nodejs
Get-FileFromUri -uri "$nodejs" -FilePath ".\downloads\nodejs.zip"
# Installed via sandbox

# Visual Studio Code python extension
Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/python/$vscode_python_version/vspackage" -FilePath ".\downloads\vscode\vscode-python.vsix"

# Dependence for PE-bear
Get-FileFromUri -uri "https://aka.ms/vs/17/release/vc_redist.x64.exe" -FilePath ".\downloads\vcredist_17_x64.exe"

# Dependence for ncat
Get-FileFromUri -uri "https://aka.ms/vs/16/release/vc_redist.x86.exe" -FilePath ".\downloads\vcredist_16_x64.exe"

# Update the following when new versions are released
# https://learn.microsoft.com/en-us/java/openjdk/download
Get-FileFromUri -uri "https://aka.ms/download-jdk/microsoft-jdk-11.0.21-windows-x64.msi" -FilePath ".\downloads\microsoft-jdk-11.msi"

# https://neo4j.com/download-center/#community
Get-FileFromUri -uri "https://neo4j.com/artifact.php?name=neo4j-community-4.4.25-windows.zip" -FilePath ".\downloads\neo4j.zip"

# https://downloads.digitalcorpora.org/downloads/bulk_extractor
Get-FileFromUri -uri "https://digitalcorpora.s3.amazonaws.com/downloads/bulk_extractor/bulk_extractor-2.0.0-windows.zip" -FilePath ".\downloads\bulk_extractor.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\bulk_extractor.zip" -o"$TOOLS\bulk_extractor" | Out-Null

# https://www.libreoffice.org/download/download-libreoffice/
Get-FileFromUri -uri "https://download.documentfoundation.org/libreoffice/stable/7.6.2/win/x86_64/LibreOffice_7.6.2_Win_x86-64.msi" -FilePath ".\downloads\LibreOffice.msi"

# https://www.python.org/downloads/
Get-FileFromUri -uri "https://www.python.org/ftp/python/3.11.6/python-3.11.6-amd64.exe" -FilePath ".\downloads\python3.exe"

# https://npcap.com/#download
Get-FileFromUri -uri "https://npcap.com/dist/npcap-1.78.exe" -FilePath ".\downloads\npcap.exe"

# https://www.wireshark.org/download.html
Get-FileFromUri -uri "https://1.eu.dl.wireshark.org/win64/Wireshark-win64-4.0.10.exe" -FilePath ".\downloads\wireshark.exe"

# https://www.sqlite.org/download.html
Get-FileFromUri -uri "https://sqlite.org/2023/sqlite-tools-win-x64-3440000.zip" -FilePath ".\downloads\sqlite.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\sqlite.zip" -o"$TOOLS\sqlite" | Out-Null
Move-Item $TOOLS\sqlite-* $TOOLS\sqlite

# https://www.7-zip.org/download.html
Get-FileFromUri -uri "https://www.7-zip.org/a/7z2301-x64.msi" -FilePath ".\downloads\7zip.msi"

# https://cert.at/en/downloads/software/software-densityscout
Get-FileFromUri -uri "https://cert.at/media/files/downloads/software/densityscout/files/densityscout_build_45_windows.zip" -FilePath ".\downloads\DensityScout.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\DensityScout.zip" -o"$TOOLS" | Out-Null
Move-Item $TOOLS\win64\densityscout.exe $TOOLS\bin\densityscout.exe

# https://nmap.org/download.html
Get-FileFromUri -uri "https://nmap.org/dist/nmap-7.94-setup.exe" -FilePath ".\downloads\nmap.exe"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\nmap.exe" -o"$TOOLS\nmap" | Out-Null

# https://sqlitebrowser.org/dl/
Get-FileFromUri -uri "https://download.sqlitebrowser.org/DB.Browser.for.SQLite-3.12.2-win64.zip" -FilePath ".\downloads\sqlitebrowser.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\sqlitebrowser.zip" -o"$TOOLS\" | Out-Null

# fasm
Get-FileFromUri -uri "https://flatassembler.net/fasmw17331.zip" -FilePath ".\downloads\fasm.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\fasm.zip" -o"$TOOLS\fasm" | Out-Null

# Remove unused
Remove-Item -r $TOOLS\win32
Remove-Item -r $TOOLS\win64
Remove-Item $TOOLS\license.txt