param(
    [Parameter(HelpMessage = "Don't update Visual Studio Code Extensions via http.")]
    [Switch]$NoVSCodeExtensions
)

. ".\resources\download\common.ps1"

if (! $NoVSCodeExtensions.IsPresent) {
    # Get URI for Visual Studio Code C++ extension - ugly
    $vscode_cpp_string = Get-DownloadUrlFromPage -url "https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools" -RegEx '"AssetUri":"[^"]+ms-vscode.cpptools/([^/]+)/'

    if ("$vscode_cpp_string" -ne "") {
        $vscode_tmp = $vscode_cpp_string | Select-String -Pattern '"AssetUri":"[^"]+ms-vscode.cpptools/([^/]+)/'
        $vscode_cpp_version = $vscode_tmp.Matches.Groups[1].Value
        # Visual Studio Code C++ extension
        $status = Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/cpptools/$vscode_cpp_version/vspackage?targetPlatform=win32-x64" -FilePath ".\downloads\vscode\vscode-cpp.vsix" -CheckURL "Yes" -check "Zip archive data"
    } else {
        Write-DateLog "ERROR: Could not get URI for Visual Studio Code C++ extension"
    }
    # Get URI for Visual Studio Code python extension - ugly
    $vscode_python_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=ms-python.python -RegEx '"AssetUri":"[^"]+python/([^/]+)/'

    if ("$vscode_python_string" -ne "") {
        $vscode_tmp = $vscode_python_string | Select-String -Pattern '"AssetUri":"[^"]+python/([^/]+)/'
        $vscode_python_version = $vscode_tmp.Matches.Groups[1].Value
        # Visual Studio Code python extension
        $status = Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/python/$vscode_python_version/vspackage" -FilePath ".\downloads\vscode\vscode-python.vsix" -CheckURL "Yes" -check "Zip archive data"
    } else {
        Write-DateLog "ERROR: Could not get URI for Visual Studio Code python extension"
    }

    # Get URI for Visual Studio Code mermaid extension - ugly
    $vscode_mermaid_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid -RegEx '"AssetUri":"[^"]+markdown-mermaid/([^/]+)/'

    if ("$vscode_mermaid_string" -ne "") {
        $vscode_tmp = $vscode_mermaid_string | Select-String -Pattern '"AssetUri":"[^"]+markdown-mermaid/([^/]+)/'
        $vscode_mermaid_version = $vscode_tmp.Matches.Groups[1].Value
        # Visual Studio Code mermaid extension
        $status = Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/bierner/vsextensions/markdown-mermaid/$vscode_mermaid_version/vspackage" -FilePath ".\downloads\vscode\vscode-mermaid.vsix" -CheckURL "Yes" -check "Zip archive data"
    } else {
        Write-DateLog "ERROR: Could not get URI for Visual Studio Code mermaid extension"
    }

    # Get URI for Visual Studio Code ruff extension - ugly
    $vscode_ruff_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=charliermarsh.ruff -RegEx '"AssetUri":"[^"]+charliermarsh.ruff/([^/]+)/'

    if ("$vscode_ruff_string" -ne "") {
        $vscode_tmp = $vscode_ruff_string | Select-String -Pattern '"AssetUri":"[^"]+charliermarsh.ruff/([^/]+)/'
        $vscode_ruff_version = $vscode_tmp.Matches.Groups[1].Value
        # Visual Studio Code ruff extension
        $status = Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/charliermarsh/vsextensions/ruff/$vscode_ruff_version/vspackage" -FilePath ".\downloads\vscode\vscode-ruff.vsix" -CheckURL "Yes" -check "Zip archive data"
    } else {
        Write-DateLog "ERROR: Could not get URI for Visual Studio Code ruff extension"
    }
}

# Get Visual Studio Code - installed during start
$status = Get-FileFromUri -uri "https://update.code.visualstudio.com/latest/win32-x64-user/stable" -FilePath ".\downloads\vscode.exe" -check "PE32"

# Get SwiftOnSecurity sysmon config - used from Sysmon
$status = Get-FileFromUri -uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -FilePath ".\downloads\sysmonconfig-export.xml" -check "ASCII text"

# Get Sysinternals Suite
$status = Get-FileFromUri -uri "https://download.sysinternals.com/files/SysinternalsSuite.zip" -FilePath ".\downloads\sysinternals.zip" -check "Zip archive data"

# Get exiftool - NOW HANDLED BY V2 YAML (utilities.yaml)
# Removed duplicate - use: .\downloadFiles.ps1 -Release
<# LEGACY CODE - REMOVED
$EXIFTOOL_VERSION = Get-DownloadUrlFromPage -url https://exiftool.org/index.html -RegEx 'exiftool-[^zip]+_64.zip'
$status = Get-FileFromUri -uri "https://exiftool.org/$EXIFTOOL_VERSION" -FilePath ".\downloads\exiftool.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\exiftool") {
        Remove-Item -Recurse -Force "${TOOLS}\exiftool" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\exiftool.zip" -o"${TOOLS}" | Out-Null
    Start-Sleep -Seconds 3
    Move-Item ${TOOLS}\exiftool-* "${TOOLS}\exiftool" -Force
    Copy-Item "${TOOLS}\exiftool\exiftool(-k).exe" ${TOOLS}\exiftool\exiftool.exe
    Remove-Item "${TOOLS}\exiftool\exiftool(-k).exe" -Force | Out-Null
}
#>

# Get pestudio
$status = Get-FileFromUri -uri "https://www.winitor.com/tools/pestudio/current/pestudio.zip" -FilePath ".\downloads\pestudio.zip" -check "Zip archive data"

# Get HxD
$status = Get-FileFromUri -uri "https://mh-nexus.de/downloads/HxDSetup.zip" -FilePath ".\downloads\hxd.zip" -check "Zip archive data"

# Get trid and triddefs - NOW HANDLED BY V2 YAML (document-analysis.yaml)
# Removed duplicates - use: .\downloadFiles.ps1 -Release
<# LEGACY CODE - REMOVED
$status = Get-FileFromUri -uri "https://mark0.net/download/trid_w32.zip" -FilePath ".\downloads\trid.zip" -check "Zip archive data"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\trid.zip" -o"${TOOLS}\trid" | Out-Null
}
$status = Get-FileFromUri -uri "https://mark0.net/download/triddefs.zip" -FilePath ".\downloads\triddefs.zip" -check "Zip archive data"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\triddefs.zip" -o"${TOOLS}\trid" | Out-Null
}
#>

# Get malcat - NOW HANDLED BY V2 YAML (document-analysis.yaml)
# Removed duplicate - use: .\downloadFiles.ps1 -Release
<# LEGACY CODE - REMOVED
$status = Get-FileFromUri -uri "https://malcat.fr/latest/malcat_win313_lite.zip" -FilePath ".\downloads\malcat.zip" -check "Zip archive data"
#>

# Get ssview
$status = Get-FileFromUri -uri "https://www.mitec.cz/Downloads/SSView.zip" -FilePath ".\downloads\ssview.zip" -check "Zip archive data"

# FullEventLogView
$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/fulleventlogview-x64.zip" -FilePath ".\downloads\logview.zip" -check "Zip archive data"

# pstwalker - NOW HANDLED BY V2 YAML (email-forensics.yaml)
# Removed duplicate - use: .\downloadFiles.ps1 -Release
<# LEGACY CODE - REMOVED
$status = Get-FileFromUri -uri "https://downloads.pstwalker.com/pstwalker-portable" -FilePath ".\downloads\pstwalker.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\pstwalker") {
        Remove-Item -Recurse -Force "${TOOLS}\pstwalker" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\pstwalker.zip" -o"${TOOLS}" | Out-Null
    Start-Sleep -Seconds 3
    Move-Item ${TOOLS}\pstwalker*portable "${TOOLS}\pstwalker"
}
#>

# Win API Search
$status = Get-FileFromUri -uri "https://dennisbabkin.com/php/downloads/WinApiSearch.zip" -FilePath ".\downloads\WinApiSearch.zip" -check "Zip archive data"

# Capa integration with Ghidra - installed during start
$status = Get-FileFromUri -uri "https://raw.githubusercontent.com/mandiant/capa/master/capa/ghidra/capa_explorer.py" -FilePath ".\downloads\capa_explorer.py" -check "ASCII text"
$status = Get-FileFromUri -uri "https://raw.githubusercontent.com/mandiant/capa/master/capa/ghidra/capa_ghidra.py" -FilePath ".\downloads\capa_ghidra.py" -check "ASCII text"

# pdfstreamdumper - installed during start
$status = Get-FileFromUri -uri "http://sandsprite.com/CodeStuff/PDFStreamDumper_Setup.exe" -FilePath ".\downloads\pdfstreamdumper.exe" -check "PE32"

# Scripts for Cutter
$status = Get-FileFromUri -uri "https://raw.githubusercontent.com/yossizap/x64dbgcutter/master/x64dbgcutter.py" -FilePath ".\downloads\x64dbgcutter.py" -check "ASCII text"
$status = Get-FileFromUri -uri "https://raw.githubusercontent.com/malware-kitten/cutter_scripts/master/scripts/cutter_stackstrings.py" -FilePath ".\downloads\cutter_stackstrings.py" -check "ASCII text"

# Dependence for PE-bear
$status = Get-FileFromUri -uri "https://aka.ms/vs/17/release/vc_redist.x64.exe" -FilePath ".\downloads\vcredist_17_x64.exe" -check "PE32"

# Dependence for ncat
$status = Get-FileFromUri -uri "https://aka.ms/vs/16/release/vc_redist.x86.exe" -FilePath ".\downloads\vcredist_16_x64.exe" -check "PE32"

# Artifacts Exchange for Velociraptor
$status = Get-FileFromUri -uri "https://github.com/Velocidex/velociraptor-docs/raw/gh-pages/exchange/artifact_exchange_v2.zip" -FilePath ".\downloads\artifact_exchange.zip" -check "Zip archive data"

# Mail Viewer
$status = Get-FileFromUri -uri "https://www.mitec.cz/Downloads/MailView.zip" -FilePath ".\downloads\mailview.zip" -check "Zip archive data"

# Volatility Workbench 3
$status = Get-FileFromUri -uri "https://www.osforensics.com/downloads/VolatilityWorkbench.zip" -FilePath ".\downloads\volatilityworkbench.zip" -check "Zip archive data"

# Volatility Workbench 2
$status = Get-FileFromUri -uri "https://www.osforensics.com/downloads/VolatilityWorkbench-v2.1.zip" -FilePath ".\downloads\volatilityworkbench2.zip" -check "Zip archive data"

# Volatility Workbench 2 Profiles
$status = Get-FileFromUri -uri "https://www.osforensics.com/downloads/Collection.zip" -FilePath ".\downloads\volatilityworkbench2profiles.zip" -check "Zip archive data"

# Nirsoft tools
$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/lastactivityview.zip" -FilePath ".\downloads\lastactivityview.zip" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/iecv.zip" -FilePath ".\downloads\iecookiesview.zip" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/mzcv-x64.zip" -FilePath ".\downloads\MZCookiesView.zip" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/chromecacheview.zip" -FilePath ".\downloads\chromecacheview.zip" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/mzcacheview.zip" -FilePath ".\downloads\mzcacheview.zip" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/iecacheview.zip" -FilePath ".\downloads\iecacheview.zip" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/browsinghistoryview-x64.zip" -FilePath ".\downloads\browsinghistoryview.zip" -check "Zip archive data"

# Get winpmem
$status = Get-FileFromUri -uri "https://github.com/Velocidex/c-aff4/raw/master/tools/pmem/resources/winpmem/winpmem_64.sys" -FilePath ".\downloads\winpmem_64.sys" -check "PE32"

# Binary Ninja - manual installation
$status = Get-FileFromUri -uri "https://cdn.binary.ninja/installers/binaryninja_free_win64.exe" -FilePath ".\downloads\binaryninja.exe" -check "PE32"

# gpg4win
$status = Get-FileFromUri -uri "https://files.gpg4win.org/gpg4win-latest.exe" -FilePath ".\downloads\gpg4win.exe" -check "PE32"

# Tor browser
$TorBrowserUrl = Get-DownloadUrlFromPage -Url "https://www.torproject.org/download/" -RegEx '/dist/[^"]+exe'
$status = Get-FileFromUri -uri "https://www.torproject.org$TorBrowserUrl" -FilePath ".\downloads\torbrowser.exe" -check "PE32"

# DCode
$DCodeUrl = Get-DownloadUrlFromPage -Url "https://www.digital-detective.net/dcode/" -RegEx "https://www.digital-detective.net/download/download[^']+"
$status = Get-FileFromUri -uri "${DCodeURL}" -FilePath ".\downloads\dcode.zip" -check "Zip archive data"

# Veracrypt - manual installation
$VeracryptUrl = Get-DownloadUrlFromPage -Url "https://www.veracrypt.fr/en/Downloads.html" -RegEx 'https://[^"]+VeraCrypt_Setup[^"]+.msi'
$status = Get-FileFromUri -uri "${VeracryptUrl}" -FilePath ".\downloads\veracrypt.msi" -check "Composite Document File V2 Document"

# Microsoft OpenJDK 11 - installed during start
$MicrosoftJDKUrl = get-downloadUrlFromPage -url "https://learn.microsoft.com/en-us/java/openjdk/download" -RegEx 'https://aka.ms/download-jdk/microsoft-jdk-11.[.0-9]+-windows-x64.msi'
$status = Get-FileFromUri -uri "${MicrosoftJDKUrl}" -FilePath ".\downloads\microsoft-jdk-11.msi" -CheckURL "Yes" -check "Composite Document File V2 Document"

# https://neo4j.com/deployment-center/#community - Neo4j - installed during start
$NeoVersion = Get-DownloadUrlFromPage -Url "https://neo4j.com/deployment-center/#community" -RegEx '4.4.[^"]+-windows\.zip'
$status = Get-FileFromUri -uri "https://neo4j.com/artifact.php?name=neo4j-community-${NeoVersion}" -FilePath ".\downloads\neo4j.zip" -CheckURL "Yes" -check "Zip archive data"

# recbin
$status = Get-FileFromUri -uri "https://github.com/keydet89/Tools/raw/refs/heads/master/exe/recbin.exe" -FilePath ".\downloads\recbin.exe" -check "PE32"

# capa Explorer web
$status = Get-FileFromUri -uri "https://mandiant.github.io/capa/explorer/capa-explorer-web.zip" -FilePath ".\downloads\capa-explorer-web.zip" -check "Zip archive data"

# https://www.libreoffice.org/download/download-libreoffice/ - LibreOffice - installed during start
$LibreOfficeVersionDownloadPage = Get-DownloadUrlFromPage -Url "https://www.libreoffice.org/download/download-libreoffice/" -RegEx 'https://[^"]+.msi'
$LibreOfficeVersion = Get-DownloadUrlFromPage -Url "${LibreOfficeVersionDownloadPage}" -RegEx 'https://[^"]+.msi'
$status = Get-FileFromUri -uri "${LibreOfficeVersion}" -FilePath ".\downloads\LibreOffice.msi" -CheckURL "Yes" -check "Composite Document File V2 Document"

# https://npcap.com/#download - Npcap - available for manual installation
$NpcapVersion = Get-DownloadUrlFromPage -Url "https://npcap.com/" -RegEx 'dist/npcap-[.0-9]+.exe'
$status = Get-FileFromUri -uri "https://npcap.com/${NpcapVersion}" -FilePath ".\downloads\npcap.exe" -CheckURL "Yes" -check "PE32"

# https://www.sqlite.org/download.html - SQLite
$SQLiteVersion = Get-DownloadUrlFromPage -Url "https://sqlite.org/download.html" -RegEx '[0-9]+/sqlite-tools-win-x64-[^"]+.zip'
$status = Get-FileFromUri -uri "https://sqlite.org/${SQLiteVersion}" -FilePath ".\downloads\sqlite.zip" -CheckURL "Yes" -check "Zip archive data"

# OpenVPN - manual installation
$status = Get-FileFromUri -uri "https://openvpn.net/downloads/openvpn-connect-v3-windows.msi" -FilePath ".\downloads\openvpn.msi" -check "Composite Document File V2 Document"

# https://downloads.digitalcorpora.org/downloads/bulk_extractor - bulk_extractor
$digitalcorpora_url = "https://digitalcorpora.s3.amazonaws.com/downloads/bulk_extractor/bulk_extractor-2.0.0-windows.zip"
$status = Get-FileFromUri -uri "${digitalcorpora_url}" -FilePath ".\downloads\bulk_extractor.zip" -CheckURL "Yes" -check "Zip archive data"

# https://cert.at/en/downloads/software/software-densityscout - DensityScout
$densityscout_url = Get-DownloadUrlFromPage -url "https://cert.at/en/downloads/software/software-densityscout" -RegEx '[^"]+windows.zip'
$status = Get-FileFromUri -uri "${densityscout_url}" -FilePath ".\downloads\DensityScout.zip" -CheckURL "Yes" -check "Zip archive data"

# https://nmap.org/download.html - Nmap
$nmap_url = Get-DownloadUrlFromPage -url "https://nmap.org/download.html" -RegEx 'https[^"]+setup.exe'
$status = Get-FileFromUri -uri "${nmap_url}" -FilePath ".\downloads\nmap.exe" -CheckURL "Yes" -check "PE32"

# https://flatassembler.net/download.php - FASM
$flatassembler_version = Get-DownloadUrlFromPage -url "https://flatassembler.net/download.php" -RegEx 'fasmw[^"]+zip'
$status = Get-FileFromUri -uri "https://flatassembler.net/${flatassembler_version}" -FilePath ".\downloads\fasm.zip" -CheckURL "Yes" -check "Zip archive data"

# Terminal for Windows - automatically installed during start
$status = Get-FileFromUri -uri "https://aka.ms/terminal-canary-zip-x64" -FilePath ".\downloads\terminal.zip" -CheckURL "Yes" -check "Zip archive data"

# https://procdot.com/downloadprocdotbinaries.htm - Procdot
$procdot_path = Get-DownloadUrlFromPage -url "https://procdot.com/downloadprocdotbinaries.htm" -RegEx 'download[^"]+windows.zip'
$status = Get-FileFromUri -uri "https://procdot.com/${procdot_path}" -FilePath ".\downloads\procdot.zip" -CheckURL "Yes" -check "Zip archive data"

# https://codeberg.org/hrbrmstr/geolocus-cli/releases - Geolocus CLI
$geolocus_url = Get-DownloadUrlFromPage -url "https://codeberg.org/hrbrmstr/geolocus-cli/releases" -RegEx 'https://[^"]*geolocus-cli-windows\.exe\.zip' -last
$status = Get-FileFromUri -uri "${geolocus_url}" -FilePath ".\downloads\geolocus.zip" -CheckURL "Yes" -check "Zip archive data"

# https://www.graphviz.org/download/ - Graphviz - available for manual installation
$graphviz_url = Get-DownloadUrlFromPage -url "https://www.graphviz.org/download/" -RegEx 'https://[^"]+win64.exe'
$status = Get-FileFromUri -uri "${graphviz_url}" -FilePath ".\downloads\graphviz.exe" -CheckURL "Yes" -check "PE32"

# http://www.rohitab.com/apimonitor - API Monitor - installed during start
$status = Get-FileFromUri -uri "http://www.rohitab.com/download/api-monitor-v2r13-setup-x64.exe" -FilePath ".\downloads\apimonitor64.exe" -CheckURL "Yes" -check "PE32"

# https://gluonhq.com/products/javafx/ - JavaFX 21
$javafx_version = Get-DownloadUrlFromPage -url "https://gluonhq.com/products/javafx/" -RegEx '21\.[0-9.]+'
$status = Get-FileFromUri -uri "https://download2.gluonhq.com/openjfx/${javafx_version}/openjfx-${javafx_version}_windows-x64_bin-sdk.zip" -FilePath ".\downloads\openjfx.zip" -CheckURL "Yes" -check "Zip archive data"

# https://bitbucket.org/iBotPeaches/apktool/downloads/ - apktool
$apktool_version = Get-DownloadUrlFromPage -url "https://apktool.org/" -RegEx 'apktool_[^"]+'
$status = Get-FileFromUri -uri "https://bitbucket.org/iBotPeaches/apktool/downloads/${apktool_version}" -FilePath ".\downloads\apktool.jar" -CheckURL "Yes" -check "Zip archive data"

# https://windows.php.net/download - PHP 8
$PHP_URL = Get-DownloadUrlFromPage -Url "https://windows.php.net/download" -RegEx '/downloads/releases/php-8.[.0-9]+-nts-Win32-vs16-x64.zip'
$status = Get-FileFromUri -uri "https://windows.php.net${PHP_URL}" -FilePath ".\downloads\php.zip" -CheckURL "Yes" -check "Zip archive data"

# https://hashcat.net/hashcat/ - hashcat
$hashcat_version = Get-DownloadUrlFromPage -url "https://hashcat.net/hashcat/" -RegEx 'fil[^"]+\.7z'
$status = Get-FileFromUri -uri "https://hashcat.net/${hashcat_version}" -FilePath ".\downloads\hashcat.7z" -CheckURL "Yes" -check "7-zip archive data"

# vmss2core
$status = Get-FileFromUri -uri "https://archive.org/download/flings.vmware.com/Flings/Vmss2core/vmss2core-sb-8456865.exe" -FilePath ".\downloads\vmss2core.exe" -CheckURL "Yes" -check "PE32"

# Drivers for hashcat
$intel_driver = Get-DownloadUrlFromPage -url "https://www.intel.com/content/www/us/en/developer/articles/technical/intel-cpu-runtime-for-opencl-applications-with-sycl-support.html" -RegEx 'https://[^"]+\.exe'
$status = Get-FileFromUri -uri "${intel_driver}" -FilePath ".\downloads\intel_driver.exe" -CheckURL "Yes" -check "PE32"

# ELK
$ELK_VERSION = ((curl.exe --silent -L "https://api.github.com/repos/elastic/elasticsearch/releases/latest" | ConvertFrom-Json).tag_name).Replace("v", "")
Set-Content -Path ".\downloads\elk_version.txt" -Value "${ELK_VERSION}"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\elasticsearch.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/kibana/kibana-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\kibana.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/logstash/logstash-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\logstash.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\elastic-agent.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\filebeat.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\metricbeat.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\packetbeat.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\heartbeat.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\auditbeat.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\winlogbeat.zip" -CheckURL "Yes" -check "Zip archive data"

