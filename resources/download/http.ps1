Write-Host "Download files via HTTP."

. $PSScriptRoot\common.ps1

# Get uri for latest nuget - ugly
$choco = Get-ChocolateyUrl chocolatey

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
Get-FileFromUri -uri "https://www.nirsoft.net/utils/fulleventlogview-x64.zip" -FilePath ".\downloads\logview.zip"
Get-FileFromUri -uri "$choco" -FilePath ".\downloads\choco.zip"
# Update the following when new versions are released
Get-FileFromUri -uri "https://download.documentfoundation.org/libreoffice/stable/7.5.0/win/x86_64/LibreOffice_7.5.0_Win_x86-64.msi" -FilePath ".\downloads\LibreOffice.msi"
Get-FileFromUri -uri "https://www.python.org/ftp/python/3.10.10/python-3.10.10-amd64.exe" -FilePath ".\downloads\python3.exe"
Get-FileFromUri -uri "https://npcap.com/dist/npcap-1.72.exe" -FilePath ".\downloads\npcap.exe"
Get-FileFromUri -uri "https://1.eu.dl.wireshark.org/win64/Wireshark-win64-4.0.4.exe" -FilePath ".\downloads\wireshark.exe"
Get-FileFromUri -uri "https://sqlite.org/2023/sqlite-tools-win32-x86-3410000.zip" -FilePath ".\downloads\sqlite.zip"
Get-FileFromUri -uri "https://www.7-zip.org/a/7z2201-x64.msi" -FilePath ".\downloads\7zip.msi"
Get-FileFromUri -uri "https://cert.at/media/files/downloads/software/densityscout/files/densityscout_build_45_windows.zip" -FilePath ".\downloads\DensityScout.zip"
Get-FileFromUri -uri "https://nmap.org/dist/nmap-7.93-setup.exe" -FilePath ".\downloads\nmap.exe"
# Dependence for PE-bear
Get-FileFromUri -uri "https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x64.exe" -FilePath ".\downloads\vcredist_x64.exe"
# Dependence for ncat
Get-FileFromUri -uri "https://aka.ms/vs/16/release/vc_redist.x86.exe" -FilePath ".\downloads\vcredist_16_x64.exe"
