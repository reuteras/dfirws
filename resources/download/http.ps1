Write-Output "Download files via HTTP."

. $PSScriptRoot\common.ps1

# Get uri for latest nuget - ugly
$choco = Get-ChocolateyUrl chocolatey
$nodejs = Get-DownloadUrlFromPage -url https://nodejs.org/en/download/ -regex 'https:[^"]+win-x64.zip'

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
Get-FileFromUri -uri "https://raw.githubusercontent.com/reuteras/yara-rules/master/signature/signature.7z" -FilePath ".\downloads\signature.7z"
Get-FileFromUri -uri "https://raw.githubusercontent.com/reuteras/yara-rules/master/total/total.7z" -FilePath ".\downloads\total.7z"
Get-FileFromUri -uri "https://raw.githubusercontent.com/hasherezade/pe2pic/master/pe2pic.py" -FilePath ".\downloads\pe2pic.py"
Get-FileFromUri -uri "https://github.com/hasherezade/shellconv/blob/master/shellconv.py" -FilePath ".\downloads\shellconv.py"
Get-FileFromUri -uri "https://www.nirsoft.net/utils/fulleventlogview-x64.zip" -FilePath ".\downloads\logview.zip"
Get-FileFromUri -uri "https://downloads.pstwalker.com/pstwalker-portable" -FilePath ".\downloads\pstwalker.zip"
Get-FileFromUri -uri "$choco" -FilePath ".\downloads\choco.zip"
Get-FileFromUri -uri "$nodejs" -FilePath ".\downloads\nodejs.zip"
# Update the following when new versions are released
Get-FileFromUri -uri "https://download.documentfoundation.org/libreoffice/stable/7.5.1/win/x86_64/LibreOffice_7.5.1_Win_x86-64.msi" -FilePath ".\downloads\LibreOffice.msi"
Get-FileFromUri -uri "https://www.python.org/ftp/python/3.10.10/python-3.10.10-amd64.exe" -FilePath ".\downloads\python3.exe"
Get-FileFromUri -uri "https://npcap.com/dist/npcap-1.72.exe" -FilePath ".\downloads\npcap.exe"
Get-FileFromUri -uri "https://1.eu.dl.wireshark.org/win64/Wireshark-win64-4.0.4.exe" -FilePath ".\downloads\wireshark.exe"
Get-FileFromUri -uri "https://sqlite.org/2023/sqlite-tools-win32-x86-3410100.zip" -FilePath ".\downloads\sqlite.zip"
Get-FileFromUri -uri "https://www.7-zip.org/a/7z2201-x64.msi" -FilePath ".\downloads\7zip.msi"
Get-FileFromUri -uri "https://cert.at/media/files/downloads/software/densityscout/files/densityscout_build_45_windows.zip" -FilePath ".\downloads\DensityScout.zip"
Get-FileFromUri -uri "https://nmap.org/dist/nmap-7.93-setup.exe" -FilePath ".\downloads\nmap.exe"
# Dependence for PE-bear
Get-FileFromUri -uri "https://aka.ms/vs/17/release/vc_redist.x64.exe" -FilePath ".\downloads\vcredist_17_x64.exe"
# Dependence for ncat
Get-FileFromUri -uri "https://aka.ms/vs/16/release/vc_redist.x86.exe" -FilePath ".\downloads\vcredist_16_x64.exe"
