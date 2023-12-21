. $PSScriptRoot\common.ps1

# Get uri for latest nuget - ugly
$choco = Get-ChocolateyUrl chocolatey
$nodejs = Get-DownloadUrlFromPage -url https://nodejs.org/en/download/ -RegEx 'https:[^"]+win-x64.zip'

# Get URI for Visual Studio Code python extension - ugly
$vscode_python_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=ms-python.python -RegEx '"AssetUri":"[^"]+python/([^/]+)/'
$vscode_tmp = $vscode_python_string | Select-String -Pattern '"AssetUri":"[^"]+python/([^/]+)/'
$vscode_python_version=$vscode_tmp.Matches.Groups[1].Value

# Get URI for Visual Studio Code mermaid extension - ugly
$vscode_mermaid_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid -RegEx '"AssetUri":"[^"]+markdown-mermaid/([^/]+)/'
$vscode_tmp = $vscode_mermaid_string | Select-String -Pattern '"AssetUri":"[^"]+markdown-mermaid/([^/]+)/'
$vscode_mermaid_version=$vscode_tmp.Matches.Groups[1].Value

# Get Visual Studio Code
Get-FileFromUri -uri "https://update.code.visualstudio.com/latest/win32-x64-user/stable" -FilePath ".\downloads\vscode.exe"
# Install during start

# Get SwiftOnSecurity sysmon config
Get-FileFromUri -uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -FilePath ".\downloads\sysmonconfig-export.xml"
# Used from sysmon

# Yara rules
Get-FileFromUri -uri "https://github.com/YARAHQ/yara-forge/releases/latest/download/yara-forge-rules-core.zip" -FilePath ".\downloads\yara-forge-rules-core.zip"
Get-FileFromUri -uri "https://github.com/YARAHQ/yara-forge/releases/latest/download/yara-forge-rules-extended.zip" -FilePath ".\downloads\yara-forge-rules-extended.zip"
Get-FileFromUri -uri "https://github.com/YARAHQ/yara-forge/releases/latest/download/yara-forge-rules-full.zip" -FilePath ".\downloads\yara-forge-rules-full.zip"

# Get Amazon Corretto
Get-FileFromUri -uri "https://corretto.aws/downloads/latest/amazon-corretto-21-x64-windows-jdk.msi" -FilePath ".\downloads\corretto.msi"
# Install during start

# Get Sysinternals Suite
Get-FileFromUri -uri "https://download.sysinternals.com/files/SysinternalsSuite.zip" -FilePath ".\downloads\sysinternals.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\sysinternals.zip" -o"$TOOLS\sysinternals" | Out-Null

# Get x64dbg
Get-FileFromUri -uri "https://sourceforge.net/projects/x64dbg/files/latest/download" -FilePath ".\downloads\x64dbg.zip"
# Install during start

# Gradle
Get-FileFromUri -uri "https://services.gradle.org/distributions/gradle-8.4-bin.zip" -FilePath ".\downloads\gradle.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\gradle.zip" -o"$TOOLS" | Out-Null
if (Test-Path -Path $TOOLS\gradle) {
    Remove-Item -Recurse -Force $TOOLS\gradle | Out-Null 2>&1
}
Move-Item $TOOLS\gradle-* $TOOLS\gradle

# Get exiftool
Get-FileFromUri -uri "https://sourceforge.net/projects/exiftool/files/latest/download" -FilePath ".\downloads\exiftool.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\exiftool.zip" -o"$TOOLS\exiftool" | Out-Null
Copy-Item "$TOOLS\exiftool\exiftool(-k).exe" $TOOLS\exiftool\exiftool.exe
Remove-Item "$TOOLS\exiftool\exiftool(-k).exe" -Force | Out-Null

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
# Should be updated to use yara-forge instead - TODO
Get-FileFromUri -uri "https://raw.githubusercontent.com/reuteras/yara-rules/master/signature/signature.7z" -FilePath ".\downloads\signature.7z"
Get-FileFromUri -uri "https://raw.githubusercontent.com/reuteras/yara-rules/master/total/total.7z" -FilePath ".\downloads\total.7z"

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

# capa_ghidra.py
Get-FileFromUri -uri "https://raw.githubusercontent.com/mandiant/capa/master/capa/ghidra/capa_ghidra.py" -FilePath ".\downloads\capa_ghidra.py"
# Install during start

# pdfstreamdumper
Get-FileFromUri -uri "http://sandsprite.com/CodeStuff/PDFStreamDumper_Setup.exe" -FilePath ".\downloads\pdfstreamdumper.exe"
# Install during start

# Plugins for Cutter
Get-FileFromUri -uri "https://raw.githubusercontent.com/yossizap/x64dbgcutter/master/x64dbgcutter.py" -FilePath ".\downloads\x64dbgcutter.py"
Get-FileFromUri -uri "https://raw.githubusercontent.com/malware-kitten/cutter_scripts/master/scripts/cutter_stackstrings.py" -FilePath ".\downloads\cutter_stackstrings.py"

# Resource Hacker - not used since Microsoft AV detects it as PUA
#Get-FileFromUri -uri "https://www.angusj.com/resourcehacker/resource_hacker.zip" -FilePath ".\downloads\resource_hacker.zip"
#& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\resource_hacker.zip" -o"$TOOLS\resource_hacker" | Out-Null

# chocolatey
Get-FileFromUri -uri "$choco" -FilePath ".\downloads\choco.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\choco.zip" -o"$SETUP_PATH\choco" | Out-Null

# nodejs
Get-FileFromUri -uri "$nodejs" -FilePath ".\downloads\nodejs.zip"
# Installed via sandbox

# Visual Studio Code python extension
Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/python/$vscode_python_version/vspackage" -FilePath ".\downloads\vscode\vscode-python.vsix"

# Visual Studio Code mermaid extension
Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/bierner/vsextensions/markdown-mermaid/$vscode_mermaid_version/vspackage" -FilePath ".\downloads\vscode\vscode-mermaid.vsix"

# Dependence for PE-bear
Get-FileFromUri -uri "https://aka.ms/vs/17/release/vc_redist.x64.exe" -FilePath ".\downloads\vcredist_17_x64.exe"

# Dependence for ncat
Get-FileFromUri -uri "https://aka.ms/vs/16/release/vc_redist.x86.exe" -FilePath ".\downloads\vcredist_16_x64.exe"

# Tools to compile and build
Get-FileFromUri -uri "https://aka.ms/vs/16/release/vs_BuildTools.exe" -FilePath ".\downloads\vs_BuildTools.exe"

# Artifacts Echange for Velociraptor
Get-FileFromUri -uri "https://github.com/Velocidex/velociraptor-docs/raw/gh-pages/exchange/artifact_exchange_v2.zip" -FilePath ".\downloads\artifact_exchange.zip"

# Update the following when new versions are released
# https://learn.microsoft.com/en-us/java/openjdk/download
Get-FileFromUri -uri "https://aka.ms/download-jdk/microsoft-jdk-11.0.21-windows-x64.msi" -FilePath ".\downloads\microsoft-jdk-11.msi"

# https://neo4j.com/deployment-center/#community
Get-FileFromUri -uri "https://neo4j.com/artifact.php?name=neo4j-community-4.4.28-windows.zip" -FilePath ".\downloads\neo4j.zip"

# https://downloads.digitalcorpora.org/downloads/bulk_extractor
Get-FileFromUri -uri "https://digitalcorpora.s3.amazonaws.com/downloads/bulk_extractor/bulk_extractor-2.0.0-windows.zip" -FilePath ".\downloads\bulk_extractor.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\bulk_extractor.zip" -o"$TOOLS\bulk_extractor" | Out-Null

# https://www.libreoffice.org/download/download-libreoffice/
Get-FileFromUri -uri "https://download.documentfoundation.org/libreoffice/stable/7.6.4/win/x86_64/LibreOffice_7.6.4_Win_x86-64.msi" -FilePath ".\downloads\LibreOffice.msi"

# https://www.python.org/downloads/
Get-FileFromUri -uri "https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe" -FilePath ".\downloads\python3.exe"

# https://npcap.com/#download
Get-FileFromUri -uri "https://npcap.com/dist/npcap-1.78.exe" -FilePath ".\downloads\npcap.exe"

# https://www.wireshark.org/download.html
Get-FileFromUri -uri "https://1.eu.dl.wireshark.org/win64/Wireshark-4.2.0-x64.exe" -FilePath ".\downloads\wireshark.exe"

# https://www.sqlite.org/download.html
Get-FileFromUri -uri "https://sqlite.org/2023/sqlite-tools-win-x64-3440200.zip" -FilePath ".\downloads\sqlite.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\sqlite.zip" -o"$TOOLS\sqlite" | Out-Null
if (Test-Path -Path $TOOLS\sqlite) {
    Remove-Item -Recurse -Force $TOOLS\sqlite | Out-Null 2>&1
}
Move-Item $TOOLS\sqlite-* $TOOLS\sqlite

# https://www.7-zip.org/download.html
Get-FileFromUri -uri "https://www.7-zip.org/a/7z2301-x64.msi" -FilePath ".\downloads\7zip.msi"

# https://cert.at/en/downloads/software/software-densityscout
Get-FileFromUri -uri "https://cert.at/media/files/downloads/software/densityscout/files/densityscout_build_45_windows.zip" -FilePath ".\downloads\DensityScout.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\DensityScout.zip" -o"$TOOLS" | Out-Null
if (Test-Path -Path $TOOLS\bin\densityscout.exe) {
    Remove-Item -Recurse -Force $TOOLS\bin\densityscout.exe | Out-Null 2>&1
}
Move-Item $TOOLS\win64\densityscout.exe $TOOLS\bin\densityscout.exe

# https://nmap.org/download.html
Get-FileFromUri -uri "https://nmap.org/dist/nmap-7.94-setup.exe" -FilePath ".\downloads\nmap.exe"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\nmap.exe" -o"$TOOLS\nmap" | Out-Null

# https://sqlitebrowser.org/dl/
Get-FileFromUri -uri "https://download.sqlitebrowser.org/DB.Browser.for.SQLite-3.12.2-win64.zip" -FilePath ".\downloads\sqlitebrowser.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\sqlitebrowser.zip" -o"$TOOLS\" | Out-Null

# https://flatassembler.net/download.php
Get-FileFromUri -uri "https://flatassembler.net/fasmw17331.zip" -FilePath ".\downloads\fasm.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\fasm.zip" -o"$TOOLS\fasm" | Out-Null

# https://procdot.com/downloadprocdotbinaries.htm
Get-FileFromUri -uri "https://procdot.com/download/procdot/binaries/procdot_1_22_57_windows.zip" -FilePath ".\downloads\procdot.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -pprocdot -aoa "$SETUP_PATH\procdot.zip" -o"$TOOLS\procdot" | Out-Null

# https://www.graphviz.org/download/
Get-FileFromUri -uri "https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/9.0.0/windows_10_cmake_Release_graphviz-install-9.0.0-win64.exe" -FilePath ".\downloads\graphviz.exe"

# http://www.rohitab.com/apimonitor
Get-FileFromUri -uri "http://www.rohitab.com/download/api-monitor-v2r13-setup-x64.exe" -FilePath ".\downloads\apimonitor64.exe"

# https://gluonhq.com/products/javafx/
Get-FileFromUri -uri "https://download2.gluonhq.com/openjfx/21.0.1/openjfx-21.0.1_windows-x64_bin-sdk.zip" -FilePath ".\downloads\openjfx.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\openjfx.zip" -o"$TOOLS" | Out-Null
if (Test-Path -Path $TOOLS\javafx-sdk) {
    Remove-Item -Recurse -Force $TOOLS\javafx-sdk | Out-Null 2>&1
}
Move-Item $TOOLS\javafx-sdk-* $TOOLS\javafx-sdk

# https://bitbucket.org/iBotPeaches/apktool/downloads/
Get-FileFromUri -uri "https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.1.jar" -FilePath ".\downloads\apktool.jar"
Copy-Item ".\downloads\apktool.jar" "$TOOLS\bin\apktool.jar" -Force
Copy-Item "setup\utils\apktool.bat" "$TOOLS\bin\apktool.bat" -Force

# https://windows.php.net/download
Get-FileFromUri -uri "https://windows.php.net/downloads/releases/php-8.3.0-nts-Win32-vs16-x64.zip" -FilePath ".\downloads\php.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\php.zip" -o"$TOOLS\php" | Out-Null

# https://hashcat.net/hashcat/
Get-FileFromUri -uri "https://hashcat.net/files/hashcat-6.2.6.7z" -FilePath ".\downloads\hashcat.7z"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\hashcat.7z" -o"$TOOLS" | Out-Null
if (Test-Path -Path $TOOLS\hashcat) {
    Remove-Item -Recurse -Force $TOOLS\hashcat | Out-Null 2>&1
}
Move-Item $TOOLS\hashcat-* $TOOLS\hashcat

# https://www.winitor.com/download2
Get-FileFromUri -uri "https://www.winitor.com/tools/pestudio/current/pestudio-9.56.zip" -FilePath ".\downloads\pestudio.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\pestudio.zip" -o"$TOOLS" | Out-Null

# ELK
$ELK_VERSION = "8.11.3"
Set-Content -Path ".\downloads\elk_version.txt" -Value "${ELK_VERSION}"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\elasticsearch.zip"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/kibana/kibana-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\kibana.zip"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/logstash/logstash-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\logstash.zip"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\elastic-agent.zip"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\filebeat.zip"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\metricbeat.zip"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\packetbeat.zip"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\heartbeat.zip"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\auditbeat.zip"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\winlogbeat.zip"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/functionbeat/functionbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\functionbeat.zip"

# Remove unused
Remove-Item -r $TOOLS\win32
Remove-Item -r $TOOLS\win64
Remove-Item $TOOLS\license.txt