. $PSScriptRoot\common.ps1

Write-DateLog "Download files via HTTP."

# Get uri for latest nuget - ugly
$choco = Get-ChocolateyUrl chocolatey
$nodejs = Get-DownloadUrlFromPage -url https://nodejs.org/en/download/ -regex 'https:[^"]+win-x64.zip'

# Get URI for Visual Studio Code python extension - ugly
$vscode_python_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=ms-python.python -regex '"AssetUri":"[^"]+python/([^/]+)/'
$vscode_tmp = $vscode_python_string | Select-String -Pattern '"AssetUri":"[^"]+python/([^/]+)/'
$vscode_python_version=$vscode_tmp.Matches.Groups[1].Value

Get-FileFromUri -uri "https://update.code.visualstudio.com/latest/win32-x64-user/stable" -FilePath ".\downloads\vscode.exe"
Get-FileFromUri -uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -FilePath ".\downloads\sysmonconfig-export.xml"
Get-FileFromUri -uri "https://corretto.aws/downloads/latest/amazon-corretto-17-x64-windows-jdk.msi" -FilePath ".\downloads\corretto.msi"
Get-FileFromUri -uri "https://download.sysinternals.com/files/SysinternalsSuite.zip" -FilePath ".\downloads\sysinternals.zip"
Get-FileFromUri -uri "https://sourceforge.net/projects/x64dbg/files/latest/download" -FilePath ".\downloads\x64dbg.zip"
Get-FileFromUri -uri "https://sourceforge.net/projects/exiftool/files/latest/download" -FilePath ".\downloads\exiftool.zip"
Get-FileFromUri -uri "https://www.winitor.com/tools/pestudio/current/pestudio.zip" -FilePath ".\downloads\pestudio.zip"
Get-FileFromUri -uri "https://mh-nexus.de/downloads/HxDSetup.zip" -FilePath ".\downloads\hxd.zip"
Get-FileFromUri -uri "https://mark0.net/download/trid_w32.zip" -FilePath ".\downloads\trid.zip"
Get-FileFromUri -uri "https://mark0.net/download/triddefs.zip" -FilePath ".\downloads\triddefs.zip"
Get-FileFromUri -uri "https://malcat.fr/latest/malcat_win64_lite.zip" -FilePath ".\downloads\malcat.zip"
Get-FileFromUri -uri "https://www.mitec.cz/Downloads/SSView.zip" -FilePath ".\downloads\ssview.zip"
Get-FileFromUri -uri "https://raw.githubusercontent.com/reuteras/yara-rules/master/signature/signature.7z" -FilePath ".\downloads\signature.7z"
Get-FileFromUri -uri "https://raw.githubusercontent.com/reuteras/yara-rules/master/total/total.7z" -FilePath ".\downloads\total.7z"
Get-FileFromUri -uri "https://raw.githubusercontent.com/hasherezade/pe2pic/master/pe2pic.py" -FilePath ".\downloads\pe2pic.py"
Get-FileFromUri -uri "https://raw.githubusercontent.com/hasherezade/shellconv/master/shellconv.py" -FilePath ".\downloads\shellconv.py"
Get-FileFromUri -uri "https://raw.githubusercontent.com/mgeeky/msidump/main/msidump.py" -FilePath ".\downloads\msidump.py"
Get-FileFromUri -uri "https://www.nirsoft.net/utils/fulleventlogview-x64.zip" -FilePath ".\downloads\logview.zip"
Get-FileFromUri -uri "https://downloads.pstwalker.com/pstwalker-portable" -FilePath ".\downloads\pstwalker.zip"
Get-FileFromUri -uri "http://sandsprite.com/CodeStuff/PDFStreamDumper_Setup.exe" -FilePath ".\downloads\pdfstreamdumper.exe"
Get-FileFromUri -uri "$choco" -FilePath ".\downloads\choco.zip"
Get-FileFromUri -uri "$nodejs" -FilePath ".\downloads\nodejs.zip"
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
# https://www.7-zip.org/download.html
Get-FileFromUri -uri "https://www.7-zip.org/a/7z2301-x64.msi" -FilePath ".\downloads\7zip.msi"
# https://cert.at/en/downloads/software/software-densityscout
Get-FileFromUri -uri "https://cert.at/media/files/downloads/software/densityscout/files/densityscout_build_45_windows.zip" -FilePath ".\downloads\DensityScout.zip"
# https://nmap.org/download.html
Get-FileFromUri -uri "https://nmap.org/dist/nmap-7.94-setup.exe" -FilePath ".\downloads\nmap.exe"