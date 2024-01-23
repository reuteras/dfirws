. "$PSScriptRoot\common.ps1"

# Get uri for latest nuget - ugly
$choco = Get-ChocolateyUrl chocolatey

# Get URI for Visual Studio Code python extension - ugly
$vscode_python_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=ms-python.python -RegEx '"AssetUri":"[^"]+python/([^/]+)/'

if ("$vscode_python_string" -ne "") {
    $vscode_tmp = $vscode_python_string | Select-String -Pattern '"AssetUri":"[^"]+python/([^/]+)/'
    $vscode_python_version = $vscode_tmp.Matches.Groups[1].Value
    # Visual Studio Code python extension
    Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/python/$vscode_python_version/vspackage" -FilePath ".\downloads\vscode\vscode-python.vsix" -CheckURL "Yes"
} else {
    Write-DateLog "ERROR: Could not get URI for Visual Studio Code python extension"
}

# Get URI for Visual Studio Code mermaid extension - ugly
$vscode_mermaid_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid -RegEx '"AssetUri":"[^"]+markdown-mermaid/([^/]+)/'

if ("$vscode_mermaid_string" -ne "") {
    $vscode_tmp = $vscode_mermaid_string | Select-String -Pattern '"AssetUri":"[^"]+markdown-mermaid/([^/]+)/'
    $vscode_mermaid_version = $vscode_tmp.Matches.Groups[1].Value
    # Visual Studio Code mermaid extension
    Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/bierner/vsextensions/markdown-mermaid/$vscode_mermaid_version/vspackage" -FilePath ".\downloads\vscode\vscode-mermaid.vsix" -CheckURL "Yes"
} else {
    Write-DateLog "ERROR: Could not get URI for Visual Studio Code mermaid extension"
}

# Get Visual Studio Code - installed during start
Get-FileFromUri -uri "https://update.code.visualstudio.com/latest/win32-x64-user/stable" -FilePath ".\downloads\vscode.exe"

# Get SwiftOnSecurity sysmon config - used from Sysmon
Get-FileFromUri -uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -FilePath ".\downloads\sysmonconfig-export.xml"

# Yara rules - unpacked during start from start_sandbox.ps1
Get-FileFromUri -uri "https://github.com/YARAHQ/yara-forge/releases/latest/download/yara-forge-rules-core.zip" -FilePath ".\downloads\yara-forge-rules-core.zip"
Get-FileFromUri -uri "https://github.com/YARAHQ/yara-forge/releases/latest/download/yara-forge-rules-extended.zip" -FilePath ".\downloads\yara-forge-rules-extended.zip"
Get-FileFromUri -uri "https://github.com/YARAHQ/yara-forge/releases/latest/download/yara-forge-rules-full.zip" -FilePath ".\downloads\yara-forge-rules-full.zip"

# Get Sysinternals Suite
# Change download of Sysinternals to download of individual tools from live.sysinternals.com since
# the zip file is behind a Cloudflare captcha at the moment.
# Get-FileFromUri -uri "https://download.sysinternals.com/files/SysinternalsSuite.zip" -FilePath ".\downloads\sysinternals.zip"
#& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\sysinternals.zip" -o"${TOOLS}\sysinternals" | Out-Null
if (!(Test-Path -Path ${TOOLS}\sysinternals)) {
    New-Item -Path ${TOOLS}\sysinternals -ItemType Directory -Force | Out-Null
}

$folderUrl = "https://live.sysinternals.com/tools/"
$webClient = New-Object System.Net.WebClient
$files = $webClient.DownloadString($folderUrl).Split("<br>") | Select-String -Pattern '<A HREF="(/tools[^"]+)"' | ForEach-Object { if ($_.Matches.Groups[1].Value -ne "/tools/ARM64/") { ($_.Matches.Groups[1].Value  -split("/"))[2] }}
foreach ($file in $files) {
    $fileUrl = $folderUrl + $file
    $savePath = Join-Path -Path "${TOOLS}\sysinternals" -ChildPath "${file}"
    curl --silent -L -z $savePath -o $savePath $fileUrl
}
$webClient.Dispose()

# Gradle - is used during download and setup of tools for dfirws
Get-FileFromUri -uri "https://services.gradle.org/distributions/gradle-8.4-bin.zip" -FilePath ".\downloads\gradle.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\gradle.zip" -o"${TOOLS}" | Out-Null
if (Test-Path -Path ${TOOLS}\gradle) {
    Remove-Item -Recurse -Force ${TOOLS}\gradle | Out-Null 2>&1
}
Move-Item ${TOOLS}\gradle-* ${TOOLS}\gradle

# Get exiftool
$EXIFTOOL_VERSION = Get-DownloadUrlFromPage -url https://exiftool.org/index.html -RegEx 'exiftool-[^zip]+.zip'
Get-FileFromUri -uri "https://exiftool.org/$EXIFTOOL_VERSION" -FilePath ".\downloads\exiftool.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\exiftool.zip" -o"${TOOLS}\exiftool" | Out-Null
Copy-Item "${TOOLS}\exiftool\exiftool(-k).exe" ${TOOLS}\exiftool\exiftool.exe
Remove-Item "${TOOLS}\exiftool\exiftool(-k).exe" -Force | Out-Null

# Get pestudio
Get-FileFromUri -uri "https://www.winitor.com/tools/pestudio/current/pestudio.zip" -FilePath ".\downloads\pestudio.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\pestudio.zip" -o"${TOOLS}\pestudio" | Out-Null

# Get HxD
Get-FileFromUri -uri "https://mh-nexus.de/downloads/HxDSetup.zip" -FilePath ".\downloads\hxd.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\hxd.zip" -o"${TOOLS}\hxd" | Out-Null

# Get trid and triddefs
Get-FileFromUri -uri "https://mark0.net/download/trid_w32.zip" -FilePath ".\downloads\trid.zip"
Get-FileFromUri -uri "https://mark0.net/download/triddefs.zip" -FilePath ".\downloads\triddefs.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\trid.zip" -o"${TOOLS}\trid" | Out-Null
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\triddefs.zip" -o"${TOOLS}\trid" | Out-Null

# Get malcat
Get-FileFromUri -uri "https://malcat.fr/latest/malcat_win64_lite.zip" -FilePath ".\downloads\malcat.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\malcat.zip" -o"${TOOLS}\malcat" | Out-Null

# Get ssview
Get-FileFromUri -uri "https://www.mitec.cz/Downloads/SSView.zip" -FilePath ".\downloads\ssview.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ssview.zip" -o"${TOOLS}\ssview" | Out-Null

# FullEventLogView
Get-FileFromUri -uri "https://www.nirsoft.net/utils/fulleventlogview-x64.zip" -FilePath ".\downloads\logview.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\logview.zip" -o"${TOOLS}\FullEventLogView" | Out-Null

# pstwalker
Get-FileFromUri -uri "https://downloads.pstwalker.com/pstwalker-portable" -FilePath ".\downloads\pstwalker.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\pstwalker.zip" -o"${TOOLS}" | Out-Null
if (Test-Path -Path ${TOOLS}\pstwalker) {
    Remove-Item -Recurse -Force ${TOOLS}\pstwalker | Out-Null 2>&1
}
Move-Item ${TOOLS}\pstwalker* ${TOOLS}\pstwalker

# fqlite
Get-FileFromUri -uri "https://www.staff.hs-mittweida.de/~pawlaszc/fqlite/downloads/fqlite_windows_x64.zip" -FilePath ".\downloads\fqlite.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\fqlite.zip" -o"${TOOLS}" | Out-Null
if (Test-Path -Path ${TOOLS}\__MACOSX) {
    Remove-Item -Recurse -Force ${TOOLS}\__MACOSX | Out-Null 2>&1
}

# Win API Search
Get-FileFromUri -uri "https://dennisbabkin.com/php/downloads/WinApiSearch.zip" -FilePath ".\downloads\WinApiSearch.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\WinApiSearch.zip" -o"${TOOLS}\WinApiSearch" | Out-Null

# capa_ghidra.py - installed during start
Get-FileFromUri -uri "https://raw.githubusercontent.com/mandiant/capa/master/capa/ghidra/capa_ghidra.py" -FilePath ".\downloads\capa_ghidra.py"

# pdfstreamdumper - installed during start
Get-FileFromUri -uri "http://sandsprite.com/CodeStuff/PDFStreamDumper_Setup.exe" -FilePath ".\downloads\pdfstreamdumper.exe"

# Scripts for Cutter
Get-FileFromUri -uri "https://raw.githubusercontent.com/yossizap/x64dbgcutter/master/x64dbgcutter.py" -FilePath ".\downloads\x64dbgcutter.py"
Get-FileFromUri -uri "https://raw.githubusercontent.com/malware-kitten/cutter_scripts/master/scripts/cutter_stackstrings.py" -FilePath ".\downloads\cutter_stackstrings.py"

# Resource Hacker - not used since Microsoft AV detects it as PUA
#Get-FileFromUri -uri "https://www.angusj.com/resourcehacker/resource_hacker.zip" -FilePath ".\downloads\resource_hacker.zip"
#& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\resource_hacker.zip" -o"${TOOLS}\resource_hacker" | Out-Null

# chocolatey
Get-FileFromUri -uri "$choco" -FilePath ".\downloads\choco.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\choco.zip" -o"${SETUP_PATH}\choco" | Out-Null

# Dependence for PE-bear
Get-FileFromUri -uri "https://aka.ms/vs/17/release/vc_redist.x64.exe" -FilePath ".\downloads\vcredist_17_x64.exe"

# Dependence for ncat
Get-FileFromUri -uri "https://aka.ms/vs/16/release/vc_redist.x86.exe" -FilePath ".\downloads\vcredist_16_x64.exe"

# Artifacts Exchange for Velociraptor
Get-FileFromUri -uri "https://github.com/Velocidex/velociraptor-docs/raw/gh-pages/exchange/artifact_exchange_v2.zip" -FilePath ".\downloads\artifact_exchange.zip"

# Mail Viewer
Get-FileFromUri -uri "https://www.mitec.cz/Downloads/MailView.zip" -FilePath ".\downloads\mailview.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\mailview.zip" -o"${TOOLS}\MailView" | Out-Null

# Volatility Workbench 3
Get-FileFromUri -uri "https://www.osforensics.com/downloads/VolatilityWorkbench.zip" -FilePath ".\downloads\volatilityworkbench.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\volatilityworkbench.zip" -o"${TOOLS}\VolatilityWorkbench" | Out-Null

# Volatility Workbench 2
Get-FileFromUri -uri "https://www.osforensics.com/downloads/VolatilityWorkbench-v2.1.zip" -FilePath ".\downloads\volatilityworkbench2.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\volatilityworkbench2.zip" -o"${TOOLS}\VolatilityWorkbench2" | Out-Null

# Volatility Workbench 2 Profiles
Get-FileFromUri -uri "https://www.osforensics.com/downloads/Collection.zip" -FilePath ".\downloads\volatilityworkbench2profiles.zip"

# Nirsoft tools
New-Item -Path "${TOOLS}\nirsoft" -ItemType Directory -Force | Out-Null
Get-FileFromUri -uri "https://www.nirsoft.net/utils/lastactivityview.zip" -FilePath ".\downloads\lastactivityview.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\lastactivityview.zip" -o"${TOOLS}\ntemp" | Out-Null
if (Test-Path -Path ${TOOLS}\ntemp\readme.txt) {
    Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\lastactivityview.txt"
}
Copy-Item ${TOOLS}\ntemp\* ${TOOLS}\nirsoft\
Remove-Item -Recurse -Force ${TOOLS}\ntemp | Out-Null 2>&1

# Microsoft Defender is flagging this as malware
#Get-FileFromUri -uri "https://www.nirsoft.net/utils/chromecookiesview.zip" -FilePath ".\downloads\chromecookiesview.zip"
#& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\chromecookiesview.zip" -o"${TOOLS}\ntemp" | Out-Null
#if (Test-Path -Path ${TOOLS}\ntemp\readme.txt) {
#    Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\chromecookiesview.txt"
#}
#Copy-Item ${TOOLS}\ntemp\* ${TOOLS}\nirsoft\
#Remove-Item -Recurse -Force ${TOOLS}\ntemp | Out-Null 2>&1

Get-FileFromUri -uri "https://www.nirsoft.net/utils/iecv.zip" -FilePath ".\downloads\iecookiesview.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\iecookiesview.zip" -o"${TOOLS}\ntemp" | Out-Null
if (Test-Path -Path ${TOOLS}\ntemp\readme.txt) {
    Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\iecookiesview.txt"
}
Copy-Item ${TOOLS}\ntemp\* ${TOOLS}\nirsoft\
Remove-Item -Recurse -Force ${TOOLS}\ntemp | Out-Null 2>&1

Get-FileFromUri -uri "https://www.nirsoft.net/utils/mzcv-x64.zip" -FilePath ".\downloads\MZCookiesView.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\MZCookiesView.zip" -o"${TOOLS}\ntemp" | Out-Null
if (Test-Path -Path ${TOOLS}\ntemp\readme.txt) {
    Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\MZCookiesView.txt"
}
Copy-Item ${TOOLS}\ntemp\* ${TOOLS}\nirsoft\
Remove-Item -Recurse -Force ${TOOLS}\ntemp | Out-Null 2>&1

Get-FileFromUri -uri "https://www.nirsoft.net/utils/chromecacheview.zip" -FilePath ".\downloads\chromecacheview.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\chromecacheview.zip" -o"${TOOLS}\ntemp" | Out-Null
if (Test-Path -Path ${TOOLS}\ntemp\readme.txt) {
    Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\chromecacheview.txt"
}
Copy-Item ${TOOLS}\ntemp\* ${TOOLS}\nirsoft\
Remove-Item -Recurse -Force ${TOOLS}\ntemp | Out-Null 2>&1

Get-FileFromUri -uri "https://www.nirsoft.net/utils/mzcacheview.zip" -FilePath ".\downloads\mzcacheview.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\mzcacheview.zip" -o"${TOOLS}\ntemp" | Out-Null
if (Test-Path -Path ${TOOLS}\ntemp\readme.txt) {
    Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\mzcacheview.txt"
}
Copy-Item ${TOOLS}\ntemp\* ${TOOLS}\nirsoft\
Remove-Item -Recurse -Force ${TOOLS}\ntemp | Out-Null 2>&1

Get-FileFromUri -uri "https://www.nirsoft.net/utils/iecacheview.zip" -FilePath ".\downloads\iecacheview.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\iecacheview.zip" -o"${TOOLS}\ntemp" | Out-Null
if (Test-Path -Path ${TOOLS}\ntemp\readme.txt) {
    Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\iecacheview.txt"
}
Copy-Item ${TOOLS}\ntemp\* ${TOOLS}\nirsoft\
Remove-Item -Recurse -Force ${TOOLS}\ntemp | Out-Null 2>&1

Get-FileFromUri -uri "https://www.nirsoft.net/utils/browsinghistoryview-x64.zip" -FilePath ".\downloads\browsinghistoryview.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\browsinghistoryview.zip" -o"${TOOLS}\ntemp" | Out-Null
if (Test-Path -Path ${TOOLS}\ntemp\readme.txt) {
    Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\browsinghistoryview.txt"
}
Copy-Item ${TOOLS}\ntemp\* ${TOOLS}\nirsoft\
Remove-Item -Recurse -Force ${TOOLS}\ntemp | Out-Null 2>&1

Remove-Item -Force ${TOOLS}\nirsoft\readme.txt | Out-Null 2>&1

# Update the links below when new versions are released

# https://learn.microsoft.com/en-us/java/openjdk/download - Microsoft OpenJDK - installed during start
Get-FileFromUri -uri "https://aka.ms/download-jdk/microsoft-jdk-11.0.21-windows-x64.msi" -FilePath ".\downloads\microsoft-jdk-11.msi" -CheckURL "Yes"

# https://neo4j.com/deployment-center/#community - Neo4j - installed during start
Get-FileFromUri -uri "https://neo4j.com/artifact.php?name=neo4j-community-4.4.29-windows.zip" -FilePath ".\downloads\neo4j.zip" -CheckURL "Yes"

# https://downloads.digitalcorpora.org/downloads/bulk_extractor - bulk_extractor
Get-FileFromUri -uri "https://digitalcorpora.s3.amazonaws.com/downloads/bulk_extractor/bulk_extractor-2.0.0-windows.zip" -FilePath ".\downloads\bulk_extractor.zip" -CheckURL "Yes"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\bulk_extractor.zip" -o"${TOOLS}\bulk_extractor" | Out-Null

# https://www.libreoffice.org/download/download-libreoffice/ - LibreOffice - installed during start
Get-FileFromUri -uri "https://download.documentfoundation.org/libreoffice/stable/7.6.4/win/x86_64/LibreOffice_7.6.4_Win_x86-64.msi" -FilePath ".\downloads\LibreOffice.msi" -CheckURL "Yes"

# https://npcap.com/#download - Npcap - available for manual installation
Get-FileFromUri -uri "https://npcap.com/dist/npcap-1.78.exe" -FilePath ".\downloads\npcap.exe" -CheckURL "Yes"

# https://www.wireshark.org/download.html - Wireshark - available for manual installation
Get-FileFromUri -uri "https://1.eu.dl.wireshark.org/win64/Wireshark-4.2.2-x64.exe" -FilePath ".\downloads\wireshark.exe" -CheckURL "Yes"

# https://www.sqlite.org/download.html - SQLite
Get-FileFromUri -uri "https://sqlite.org/2024/sqlite-tools-win-x64-3450000.zip" -FilePath ".\downloads\sqlite.zip" -CheckURL "Yes"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\sqlite.zip" -o"${TOOLS}\sqlite" | Out-Null
if (Test-Path -Path ${TOOLS}\sqlite) {
    Remove-Item -Recurse -Force ${TOOLS}\sqlite | Out-Null 2>&1
}
Move-Item ${TOOLS}\sqlite-* ${TOOLS}\sqlite

# https://cert.at/en/downloads/software/software-densityscout - DensityScout
Get-FileFromUri -uri "https://cert.at/media/files/downloads/software/densityscout/files/densityscout_build_45_windows.zip" -FilePath ".\downloads\DensityScout.zip" -CheckURL "Yes"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\DensityScout.zip" -o"${TOOLS}" | Out-Null
if (Test-Path -Path ${TOOLS}\bin\densityscout.exe) {
    Remove-Item -Recurse -Force ${TOOLS}\bin\densityscout.exe | Out-Null 2>&1
}
Move-Item ${TOOLS}\win64\densityscout.exe ${TOOLS}\bin\densityscout.exe

# https://nmap.org/download.html - Nmap
Get-FileFromUri -uri "https://nmap.org/dist/nmap-7.94-setup.exe" -FilePath ".\downloads\nmap.exe" -CheckURL "Yes"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\nmap.exe" -o"${TOOLS}\nmap" | Out-Null

# https://sqlitebrowser.org/dl/ - DB Browser for SQLite
Get-FileFromUri -uri "https://download.sqlitebrowser.org/DB.Browser.for.SQLite-3.12.2-win64.zip" -FilePath ".\downloads\sqlitebrowser.zip" -CheckURL "Yes"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\sqlitebrowser.zip" -o"${TOOLS}\" | Out-Null

# https://flatassembler.net/download.php - FASM
Get-FileFromUri -uri "https://flatassembler.net/fasmw17332.zip" -FilePath ".\downloads\fasm.zip" -CheckURL "Yes"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\fasm.zip" -o"${TOOLS}\fasm" | Out-Null

# https://procdot.com/downloadprocdotbinaries.htm - Procdot
Get-FileFromUri -uri "https://procdot.com/download/procdot/binaries/procdot_1_22_57_windows.zip" -FilePath ".\downloads\procdot.zip" -CheckURL "Yes"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -pprocdot -aoa "${SETUP_PATH}\procdot.zip" -o"${TOOLS}\procdot" | Out-Null

# https://www.graphviz.org/download/ - Graphviz - available for manual installation
Get-FileFromUri -uri "https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/9.0.0/windows_10_cmake_Release_graphviz-install-9.0.0-win64.exe" -FilePath ".\downloads\graphviz.exe" -CheckURL "Yes"

# http://www.rohitab.com/apimonitor - API Monitor - installed during start
Get-FileFromUri -uri "http://www.rohitab.com/download/api-monitor-v2r13-setup-x64.exe" -FilePath ".\downloads\apimonitor64.exe" -CheckURL "Yes"

# https://gluonhq.com/products/javafx/ - JavaFX
Get-FileFromUri -uri "https://download2.gluonhq.com/openjfx/21.0.1/openjfx-21.0.1_windows-x64_bin-sdk.zip" -FilePath ".\downloads\openjfx.zip" -CheckURL "Yes"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\openjfx.zip" -o"${TOOLS}" | Out-Null
if (Test-Path -Path ${TOOLS}\javafx-sdk) {
    Remove-Item -Recurse -Force ${TOOLS}\javafx-sdk | Out-Null 2>&1
}
Move-Item ${TOOLS}\javafx-sdk-* ${TOOLS}\javafx-sdk

# https://bitbucket.org/iBotPeaches/apktool/downloads/ - apktool
Get-FileFromUri -uri "https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.1.jar" -FilePath ".\downloads\apktool.jar" -CheckURL "Yes"
Copy-Item ".\downloads\apktool.jar" "${TOOLS}\bin\apktool.jar" -Force
Copy-Item "setup\utils\apktool.bat" "${TOOLS}\bin\apktool.bat" -Force

# https://windows.php.net/download - PHP
Get-FileFromUri -uri "https://windows.php.net/downloads/releases/php-8.3.2-nts-Win32-vs16-x64.zip" -FilePath ".\downloads\php.zip" -CheckURL "Yes"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\php.zip" -o"${TOOLS}\php" | Out-Null

# https://hashcat.net/hashcat/ - hashcat
Get-FileFromUri -uri "https://hashcat.net/files/hashcat-6.2.6.7z" -FilePath ".\downloads\hashcat.7z" -CheckURL "Yes"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\hashcat.7z" -o"${TOOLS}" | Out-Null
if (Test-Path -Path ${TOOLS}\hashcat) {
    Remove-Item -Recurse -Force ${TOOLS}\hashcat | Out-Null 2>&1
}
Move-Item ${TOOLS}\hashcat-* ${TOOLS}\hashcat

# ELK
$ELK_VERSION = "8.12.0"
Set-Content -Path ".\downloads\elk_version.txt" -Value "${ELK_VERSION}"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\elasticsearch.zip" -CheckURL "Yes"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/kibana/kibana-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\kibana.zip" -CheckURL "Yes"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/logstash/logstash-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\logstash.zip" -CheckURL "Yes"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\elastic-agent.zip" -CheckURL "Yes"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\filebeat.zip" -CheckURL "Yes"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\metricbeat.zip" -CheckURL "Yes"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\packetbeat.zip" -CheckURL "Yes"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\heartbeat.zip" -CheckURL "Yes"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\auditbeat.zip" -CheckURL "Yes"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\winlogbeat.zip" -CheckURL "Yes"
Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/functionbeat/functionbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\functionbeat.zip" -CheckURL "Yes"

# Remove unused files and directories
Remove-Item -r ${TOOLS}\win32
Remove-Item -r ${TOOLS}\win64
Remove-Item ${TOOLS}\license.txt