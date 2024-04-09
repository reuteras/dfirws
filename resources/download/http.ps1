param(
    [Parameter(HelpMessage = "Don't update Visual Studio Code Extensions via http.")]
    [Switch]$NoVSCodeExtensions
)

. "$PSScriptRoot\common.ps1"

if (! $NoVSCodeExtensions.IsPresent) {
    # Get URI for Visual Studio Code python extension - ugly
    $vscode_python_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=ms-python.python -RegEx '"AssetUri":"[^"]+python/([^/]+)/'

    if ("$vscode_python_string" -ne "") {
        $vscode_tmp = $vscode_python_string | Select-String -Pattern '"AssetUri":"[^"]+python/([^/]+)/'
        $vscode_python_version = $vscode_tmp.Matches.Groups[1].Value
        # Visual Studio Code python extension
        $status = Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/python/$vscode_python_version/vspackage" -FilePath ".\downloads\vscode\vscode-python.vsix" -CheckURL "Yes"
    } else {
        Write-DateLog "ERROR: Could not get URI for Visual Studio Code python extension"
    }

    # Get URI for Visual Studio Code mermaid extension - ugly
    $vscode_mermaid_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid -RegEx '"AssetUri":"[^"]+markdown-mermaid/([^/]+)/'

    if ("$vscode_mermaid_string" -ne "") {
        $vscode_tmp = $vscode_mermaid_string | Select-String -Pattern '"AssetUri":"[^"]+markdown-mermaid/([^/]+)/'
        $vscode_mermaid_version = $vscode_tmp.Matches.Groups[1].Value
        # Visual Studio Code mermaid extension
        $status = Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/bierner/vsextensions/markdown-mermaid/$vscode_mermaid_version/vspackage" -FilePath ".\downloads\vscode\vscode-mermaid.vsix" -CheckURL "Yes"
    } else {
        Write-DateLog "ERROR: Could not get URI for Visual Studio Code mermaid extension"
    }

    # Get URI for Visual Studio Code ruff extension - ugly
    $vscode_ruff_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=charliermarsh.ruff -RegEx '"AssetUri":"[^"]+charliermarsh.ruff/([^/]+)/'

    if ("$vscode_ruff_string" -ne "") {
        $vscode_tmp = $vscode_ruff_string | Select-String -Pattern '"AssetUri":"[^"]+charliermarsh.ruff/([^/]+)/'
        $vscode_ruff_version = $vscode_tmp.Matches.Groups[1].Value
        # Visual Studio Code ruff extension
        $status = Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/charliermarsh/vsextensions/ruff/$vscode_ruff_version/vspackage" -FilePath ".\downloads\vscode\vscode-ruff.vsix" -CheckURL "Yes"
    } else {
        Write-DateLog "ERROR: Could not get URI for Visual Studio Code ruff extension"
    }
}

# Get Visual Studio Code - installed during start
$status = Get-FileFromUri -uri "https://update.code.visualstudio.com/latest/win32-x64-user/stable" -FilePath ".\downloads\vscode.exe"

# Get SwiftOnSecurity sysmon config - used from Sysmon
$status = Get-FileFromUri -uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -FilePath ".\downloads\sysmonconfig-export.xml"

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
#Get-FileFromUri -uri "https://services.gradle.org/distributions/gradle-8.4-bin.zip" -FilePath ".\downloads\gradle.zip"
#& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\gradle.zip" -o"${TOOLS}" | Out-Null
#if (Test-Path -Path ${TOOLS}\gradle) {
#    Remove-Item -Recurse -Force ${TOOLS}\gradle | Out-Null 2>&1
#}
#Move-Item ${TOOLS}\gradle-* ${TOOLS}\gradle

# Get exiftool
$EXIFTOOL_VERSION = Get-DownloadUrlFromPage -url https://exiftool.org/index.html -RegEx 'exiftool-[^zip]+.zip'
$status = Get-FileFromUri -uri "https://exiftool.org/$EXIFTOOL_VERSION" -FilePath ".\downloads\exiftool.zip"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\exiftool.zip" -o"${TOOLS}\exiftool" | Out-Null
    Copy-Item "${TOOLS}\exiftool\exiftool(-k).exe" ${TOOLS}\exiftool\exiftool.exe
    Remove-Item "${TOOLS}\exiftool\exiftool(-k).exe" -Force | Out-Null
}

# Get pestudio
$status = Get-FileFromUri -uri "https://www.winitor.com/tools/pestudio/current/pestudio.zip" -FilePath ".\downloads\pestudio.zip"
if ($status) {
    if (Test-Path -Path "${TOOLS}\pestudio") {
        Remove-Item -Recurse -Force "${TOOLS}\pestudio" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\pestudio.zip" -o"${TOOLS}" | Out-Null
}

# Get HxD
$status = Get-FileFromUri -uri "https://mh-nexus.de/downloads/HxDSetup.zip" -FilePath ".\downloads\hxd.zip"
if ($status) {
    if (Test-Path -Path "${TOOLS}\hxd") {
        Remove-Item -Recurse -Force "${TOOLS}\hxd" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\hxd.zip" -o"${TOOLS}\hxd" | Out-Null
}

# Get trid and triddefs
$status = Get-FileFromUri -uri "https://mark0.net/download/trid_w32.zip" -FilePath ".\downloads\trid.zip"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\trid.zip" -o"${TOOLS}\trid" | Out-Null
}
$status = Get-FileFromUri -uri "https://mark0.net/download/triddefs.zip" -FilePath ".\downloads\triddefs.zip"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\triddefs.zip" -o"${TOOLS}\trid" | Out-Null
}

# Get malcat - installed during start
$status = Get-FileFromUri -uri "https://malcat.fr/latest/malcat_win64_lite.zip" -FilePath ".\downloads\malcat.zip"

# Get ssview
$status = Get-FileFromUri -uri "https://www.mitec.cz/Downloads/SSView.zip" -FilePath ".\downloads\ssview.zip"
if ($status) {
    if (Test-Path -Path "${TOOLS}\ssview") {
        Remove-Item -Recurse -Force "${TOOLS}\ssview" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ssview.zip" -o"${TOOLS}\ssview" | Out-Null
}

# FullEventLogView
$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/fulleventlogview-x64.zip" -FilePath ".\downloads\logview.zip"
if ($status) {
    if (Test-Path -Path "${TOOLS}\FullEventLogView") {
        Remove-Item -Recurse -Force "${TOOLS}\FullEventLogView" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\logview.zip" -o"${TOOLS}\FullEventLogView" | Out-Null
}

# pstwalker
$status = Get-FileFromUri -uri "https://downloads.pstwalker.com/pstwalker-portable" -FilePath ".\downloads\pstwalker.zip"
if ($status) {
    if (Test-Path -Path "${TOOLS}\pstwalker") {
        Remove-Item -Recurse -Force "${TOOLS}\pstwalker" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\pstwalker.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\pstwalker*portable "${TOOLS}\pstwalker"
}

# fqlite
$status = Get-FileFromUri -uri "https://www.staff.hs-mittweida.de/~pawlaszc/fqlite/downloads/fqlite_windows_x64.zip" -FilePath ".\downloads\fqlite.zip"
if ($status) {
    if (Test-Path -Path "${TOOLS}\fqlite") {
        Remove-Item -Recurse -Force "${TOOLS}\fqlite" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\fqlite.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path -Path "${TOOLS}\__MACOSX") {
        Remove-Item -Recurse -Force "${TOOLS}\__MACOSX" | Out-Null 2>&1
    }
    if (Test-Path -Path "${TOOLS}\fqlite\.DS_Store") {
        Remove-Item -Recurse -Force "${TOOLS}\fqlite\.DS_Store" | Out-Null 2>&1
    }
}

# Win API Search
$status = Get-FileFromUri -uri "https://dennisbabkin.com/php/downloads/WinApiSearch.zip" -FilePath ".\downloads\WinApiSearch.zip"
if ($status) {
    if (Test-Path -Path "${TOOLS}\WinApiSearch") {
        Remove-Item -Recurse -Force "${TOOLS}\WinApiSearch" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\WinApiSearch.zip" -o"${TOOLS}\WinApiSearch" | Out-Null
}

# Capa integration with Ghidra - installed during start
$status = Get-FileFromUri -uri "https://raw.githubusercontent.com/mandiant/capa/master/capa/ghidra/capa_explorer.py" -FilePath ".\downloads\capa_explorer.py"
$status = Get-FileFromUri -uri "https://raw.githubusercontent.com/mandiant/capa/master/capa/ghidra/capa_ghidra.py" -FilePath ".\downloads\capa_ghidra.py"

# pdfstreamdumper - installed during start
$status = Get-FileFromUri -uri "http://sandsprite.com/CodeStuff/PDFStreamDumper_Setup.exe" -FilePath ".\downloads\pdfstreamdumper.exe"

# Scripts for Cutter
$status = Get-FileFromUri -uri "https://raw.githubusercontent.com/yossizap/x64dbgcutter/master/x64dbgcutter.py" -FilePath ".\downloads\x64dbgcutter.py"
$status = Get-FileFromUri -uri "https://raw.githubusercontent.com/malware-kitten/cutter_scripts/master/scripts/cutter_stackstrings.py" -FilePath ".\downloads\cutter_stackstrings.py"

# Dependence for PE-bear
$status = Get-FileFromUri -uri "https://aka.ms/vs/17/release/vc_redist.x64.exe" -FilePath ".\downloads\vcredist_17_x64.exe"

# Dependence for ncat
$status = Get-FileFromUri -uri "https://aka.ms/vs/16/release/vc_redist.x86.exe" -FilePath ".\downloads\vcredist_16_x64.exe"

# Artifacts Exchange for Velociraptor
$status = Get-FileFromUri -uri "https://github.com/Velocidex/velociraptor-docs/raw/gh-pages/exchange/artifact_exchange_v2.zip" -FilePath ".\downloads\artifact_exchange.zip"

# Mail Viewer
$status = Get-FileFromUri -uri "https://www.mitec.cz/Downloads/MailView.zip" -FilePath ".\downloads\mailview.zip"
if ($status) {
    if (Test-Path -Path "${TOOLS}\MailView") {
        Remove-Item -Recurse -Force "${TOOLS}\MailView" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\mailview.zip" -o"${TOOLS}\MailView" | Out-Null
}

# Volatility Workbench 3
$status = Get-FileFromUri -uri "https://www.osforensics.com/downloads/VolatilityWorkbench.zip" -FilePath ".\downloads\volatilityworkbench.zip"
if ($status) {
    if (Test-Path -Path "${TOOLS}\VolatilityWorkbench") {
        Remove-Item -Recurse -Force "${TOOLS}\VolatilityWorkbench" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\volatilityworkbench.zip" -o"${TOOLS}\VolatilityWorkbench" | Out-Null
}

# Volatility Workbench 2
$status = Get-FileFromUri -uri "https://www.osforensics.com/downloads/VolatilityWorkbench-v2.1.zip" -FilePath ".\downloads\volatilityworkbench2.zip"
if ($status) {
    if (Test-Path -Path "${TOOLS}\VolatilityWorkbench2") {
        Remove-Item -Recurse -Force "${TOOLS}\VolatilityWorkbench2" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\volatilityworkbench2.zip" -o"${TOOLS}\VolatilityWorkbench2" | Out-Null
}

# Volatility Workbench 2 Profiles
$status = Get-FileFromUri -uri "https://www.osforensics.com/downloads/Collection.zip" -FilePath ".\downloads\volatilityworkbench2profiles.zip"

# Nirsoft tools
New-Item -Path "${TOOLS}\nirsoft" -ItemType Directory -Force | Out-Null
if (Test-Path -Path "${TOOLS}\ntemp") {
    Remove-Item -Recurse -Force "${TOOLS}\ntemp" | Out-Null 2>&1
}

$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/lastactivityview.zip" -FilePath ".\downloads\lastactivityview.zip"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\lastactivityview.zip" -o"${TOOLS}\ntemp" | Out-Null
    if (Test-Path -Path ${TOOLS}\ntemp\readme.txt) {
        Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\lastactivityview.txt"
    }
    Copy-Item ${TOOLS}\ntemp\* "${TOOLS}\nirsoft"
    Remove-Item -Recurse -Force "${TOOLS}\ntemp" | Out-Null 2>&1
}

# Microsoft Defender is flagging this as malware
#Get-FileFromUri -uri "https://www.nirsoft.net/utils/chromecookiesview.zip" -FilePath ".\downloads\chromecookiesview.zip"
#& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\chromecookiesview.zip" -o"${TOOLS}\ntemp" | Out-Null
#if (Test-Path -Path ${TOOLS}\ntemp\readme.txt) {
#    Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\chromecookiesview.txt"
#}
#Copy-Item ${TOOLS}\ntemp\* ${TOOLS}\nirsoft\
#Remove-Item -Recurse -Force ${TOOLS}\ntemp | Out-Null 2>&1

$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/iecv.zip" -FilePath ".\downloads\iecookiesview.zip"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\iecookiesview.zip" -o"${TOOLS}\ntemp" | Out-Null
    if (Test-Path -Path ${TOOLS}\ntemp\readme.txt) {
        Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\iecookiesview.txt"
    }
    Copy-Item ${TOOLS}\ntemp\* "${TOOLS}\nirsoft"
    Remove-Item -Recurse -Force "${TOOLS}\ntemp" | Out-Null 2>&1
}

$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/mzcv-x64.zip" -FilePath ".\downloads\MZCookiesView.zip"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\MZCookiesView.zip" -o"${TOOLS}\ntemp" | Out-Null
    if (Test-Path -Path "${TOOLS}\ntemp\readme.txt") {
        Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\MZCookiesView.txt"
    }
    Copy-Item ${TOOLS}\ntemp\* "${TOOLS}\nirsoft"
    Remove-Item -Recurse -Force "${TOOLS}\ntemp" | Out-Null 2>&1
}

$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/chromecacheview.zip" -FilePath ".\downloads\chromecacheview.zip"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\chromecacheview.zip" -o"${TOOLS}\ntemp" | Out-Null
    if (Test-Path -Path "${TOOLS}\ntemp\readme.txt") {
        Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\chromecacheview.txt"
    }
    Copy-Item ${TOOLS}\ntemp\* "${TOOLS}\nirsoft"
Remove-Item -Recurse -Force "${TOOLS}\ntemp" | Out-Null 2>&1
}

$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/mzcacheview.zip" -FilePath ".\downloads\mzcacheview.zip"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\mzcacheview.zip" -o"${TOOLS}\ntemp" | Out-Null
    if (Test-Path -Path ${TOOLS}\ntemp\readme.txt) {
        Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\mzcacheview.txt"
    }
    Copy-Item ${TOOLS}\ntemp\* "${TOOLS}\nirsoft"
    Remove-Item -Recurse -Force "${TOOLS}\ntemp" | Out-Null 2>&1
}

$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/iecacheview.zip" -FilePath ".\downloads\iecacheview.zip"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\iecacheview.zip" -o"${TOOLS}\ntemp" | Out-Null
    if (Test-Path -Path "${TOOLS}\ntemp\readme.txt") {
        Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\iecacheview.txt"
    }
    Copy-Item ${TOOLS}\ntemp\* "${TOOLS}\nirsoft"
    Remove-Item -Recurse -Force "${TOOLS}\ntemp" | Out-Null
}

$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/browsinghistoryview-x64.zip" -FilePath ".\downloads\browsinghistoryview.zip"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\browsinghistoryview.zip" -o"${TOOLS}\ntemp" | Out-Null
    if (Test-Path -Path "${TOOLS}\ntemp\readme.txt") {
        Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\browsinghistoryview.txt"
    }
    Copy-Item ${TOOLS}\ntemp\* "${TOOLS}\nirsoft"
    Remove-Item -Recurse -Force "${TOOLS}\ntemp" | Out-Null 2>&1
}

if (Test-Path -Path "${TOOLS}\nirsoft\readme.txt") {
    Remove-Item -Force "${TOOLS}\nirsoft\readme.txt" | Out-Null 2>&1
}

# Get winpmem
$status = Get-FileFromUri -uri "https://github.com/Velocidex/c-aff4/raw/master/tools/pmem/resources/winpmem/winpmem_64.sys" -FilePath ".\downloads\winpmem_64.sys"

# Binary Ninja - manual installation
$status = Get-FileFromUri -uri "https://cdn.binary.ninja/installers/BinaryNinja-free.exe" -FilePath ".\downloads\binaryninja.exe"

# gpg4win
$status = Get-FileFromUri -uri "https://files.gpg4win.org/gpg4win-latest.exe" -FilePath ".\downloads\gpg4win.exe"

# Firefox
$status = Get-FileFromUri -uri "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US" -FilePath ".\downloads\firefox.msi"

# Tor browser
$TorBrowserUrl = Get-DownloadUrlFromPage -Url "https://www.torproject.org/download/" -RegEx '/dist/[^"]+exe'
$status = Get-FileFromUri -uri "https://www.torproject.org$TorBrowserUrl" -FilePath ".\downloads\torbrowser.exe"

# DCode
$DCodeUrl = Get-DownloadUrlFromPage -Url "https://www.digital-detective.net/dcode/" -RegEx "https://www.digital-detective.net/download/download[^']+"
$status = Get-FileFromUri -uri "${DCodeURL}" -FilePath ".\downloads\dcode.zip"
if ($status) {
    if (Test-Path -Path ${SETUP_PATH}\dcode) {
        Remove-Item -Recurse -Force ${SETUP_PATH}\dcode | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\dcode.zip" -o"${SETUP_PATH}\dcode" | Out-Null
    Move-Item ${SETUP_PATH}\dcode\Dcode-* "${SETUP_PATH}\dcode\dcode.exe" | Out-Null
}

# HFS - HTTP File Server
$status = Get-FileFromUri -uri "https://rejetto.com/hfs/download" -FilePath ".\downloads\hfs.exe"
Copy-Item ".\downloads\hfs.exe" "${TOOLS}\bin\hfs.exe" -Force

# Veracrypt - manual installation
$VeracryptUrl = Get-DownloadUrlFromPage -Url "https://www.veracrypt.fr/en/Downloads.html" -RegEx 'https://[^"]+VeraCrypt_Setup[^"]+.msi'
$status = Get-FileFromUri -uri "${VeracryptUrl}" -FilePath ".\downloads\veracrypt.msi"

# Microsoft OpenJDK 11 - installed during start
$MicrosoftJDKUrl = get-downloadUrlFromPage -url "https://learn.microsoft.com/en-us/java/openjdk/download" -RegEx 'https://aka.ms/download-jdk/microsoft-jdk-11.[.0-9]+-windows-x64.msi'
$status = Get-FileFromUri -uri "${MicrosoftJDKUrl}" -FilePath ".\downloads\microsoft-jdk-11.msi" -CheckURL "Yes"

# https://neo4j.com/deployment-center/#community - Neo4j - installed during start
$NeoVersion = Get-DownloadUrlFromPage -Url "https://neo4j.com/deployment-center/#community" -RegEx '4.4.[^"]+-windows\.zip'
$status = Get-FileFromUri -uri "https://neo4j.com/artifact.php?name=neo4j-community-${NeoVersion}" -FilePath ".\downloads\neo4j.zip" -CheckURL "Yes"

# https://www.libreoffice.org/download/download-libreoffice/ - LibreOffice - installed during start
$LibreOfficeVersionDownloadPage = Get-DownloadUrlFromPage -Url "https://www.libreoffice.org/download/download-libreoffice/" -RegEx 'https://[^"]+.msi'
$LibreOfficeVersion = Get-DownloadUrlFromPage -Url "${LibreOfficeVersionDownloadPage}" -RegEx 'https://[^"]+.msi'
$status = Get-FileFromUri -uri "${LibreOfficeVersion}" -FilePath ".\downloads\LibreOffice.msi" -CheckURL "Yes"

# https://npcap.com/#download - Npcap - available for manual installation
$NpcapVersion = Get-DownloadUrlFromPage -Url "https://npcap.com/" -RegEx 'dist/npcap-[.0-9]+.exe'
$status = Get-FileFromUri -uri "https://npcap.com/dist/${NpcapVersion}" -FilePath ".\downloads\npcap.exe" -CheckURL "Yes"

# https://www.wireshark.org/download.html - Wireshark - available for manual installation
$WiresharkVersion = Get-DownloadUrlFromPage -Url "https://wireshark.org/" -RegEx 'https://[^"]+/win64/Wireshark-4.2.[0-9]+-x64.exe'
$status = Get-FileFromUri -uri "${WiresharkVersion}" -FilePath ".\downloads\wireshark.exe" -CheckURL "Yes"

# https://www.sqlite.org/download.html - SQLite
$SQLiteVersion = Get-DownloadUrlFromPage -Url "https://sqlite.org/download.html" -RegEx '[0-9]+/sqlite-tools-win-x64-[^"]+.zip'
$status = Get-FileFromUri -uri "https://sqlite.org/${SQLiteVersion}" -FilePath ".\downloads\sqlite.zip" -CheckURL "Yes"
if ($status) {
    if (Test-Path -Path "${TOOLS}\sqlite") {
        Remove-Item -Recurse -Force "${TOOLS}\sqlite" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\sqlite.zip" -o"${TOOLS}\sqlite" | Out-Null
}

# Foxit Reader - manual installation
$status = Get-FileFromUri -uri "https://www.foxit.com/downloads/latest.html?product=Foxit-Reader&platform=Windows&version=&package_type=&language=English&distID=" -FilePath ".\downloads\foxitreader.exe"

# Update the links below when new versions are released

# https://downloads.digitalcorpora.org/downloads/bulk_extractor - bulk_extractor
$status = Get-FileFromUri -uri "https://digitalcorpora.s3.amazonaws.com/downloads/bulk_extractor/bulk_extractor-2.0.0-windows.zip" -FilePath ".\downloads\bulk_extractor.zip" -CheckURL "Yes"
if ($status) {
    if (Test-Path -Path "${TOOLS}\bulk_extractor") {
        Remove-Item -Recurse -Force "${TOOLS}\bulk_extractor" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\bulk_extractor.zip" -o"${TOOLS}\bulk_extractor" | Out-Null
}

# https://cert.at/en/downloads/software/software-densityscout - DensityScout
$status = Get-FileFromUri -uri "https://cert.at/media/files/downloads/software/densityscout/files/densityscout_build_45_windows.zip" -FilePath ".\downloads\DensityScout.zip" -CheckURL "Yes"
if ($status) {
    if (Test-Path -Path "${TOOLS}\bin\densityscout.exe") {
        Remove-Item -Recurse -Force "${TOOLS}\bin\densityscout.exe" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\DensityScout.zip" -o"${TOOLS}" | Out-Null
    Move-Item "${TOOLS}\win64\densityscout.exe" "${TOOLS}\bin\densityscout.exe"
}

# https://nmap.org/download.html - Nmap
$status = Get-FileFromUri -uri "https://nmap.org/dist/nmap-7.94-setup.exe" -FilePath ".\downloads\nmap.exe" -CheckURL "Yes"
if ($status) {
    if (Test-Path -Path "${TOOLS}\nmap") {
        Remove-Item -Recurse -Force "${TOOLS}\nmap" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\nmap.exe" -o"${TOOLS}\nmap" | Out-Null
}

# https://sqlitebrowser.org/dl/ - DB Browser for SQLite
$status = Get-FileFromUri -uri "https://download.sqlitebrowser.org/DB.Browser.for.SQLite-3.12.2-win64.zip" -FilePath ".\downloads\sqlitebrowser.zip" -CheckURL "Yes"
if ($status) {
    if (Test-Path -Path "${TOOLS}\DB Browser for SQLite") {
        Remove-Item -Recurse -Force "${TOOLS}\DB Browser for SQLite" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\sqlitebrowser.zip" -o"${TOOLS}\" | Out-Null
}

# https://flatassembler.net/download.php - FASM
$status = Get-FileFromUri -uri "https://flatassembler.net/fasmw17332.zip" -FilePath ".\downloads\fasm.zip" -CheckURL "Yes"
if ($status) {
    if (Test-Path -Path "${TOOLS}\fasm") {
        Remove-Item -Recurse -Force "${TOOLS}\fasm" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\fasm.zip" -o"${TOOLS}\fasm" | Out-Null
}

# https://procdot.com/downloadprocdotbinaries.htm - Procdot
$status = Get-FileFromUri -uri "https://procdot.com/download/procdot/binaries/procdot_1_22_57_windows.zip" -FilePath ".\downloads\procdot.zip" -CheckURL "Yes"
if ($status) {
    if (Test-Path -Path "${TOOLS}\procdot") {
        Remove-Item -Recurse -Force "${TOOLS}\procdot" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -pprocdot -aoa "${SETUP_PATH}\procdot.zip" -o"${TOOLS}\procdot" | Out-Null
}

# https://www.graphviz.org/download/ - Graphviz - available for manual installation
$status = Get-FileFromUri -uri "https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/10.0.1/windows_10_cmake_Release_graphviz-install-10.0.1-win64.exe" -FilePath ".\downloads\graphviz.exe" -CheckURL "Yes"

# http://www.rohitab.com/apimonitor - API Monitor - installed during start
$status = Get-FileFromUri -uri "http://www.rohitab.com/download/api-monitor-v2r13-setup-x64.exe" -FilePath ".\downloads\apimonitor64.exe" -CheckURL "Yes"

# https://gluonhq.com/products/javafx/ - JavaFX
$status = Get-FileFromUri -uri "https://download2.gluonhq.com/openjfx/21.0.2/openjfx-21.0.2_windows-x64_bin-sdk.zip" -FilePath ".\downloads\openjfx.zip" -CheckURL "Yes"
if ($status) {
    if (Test-Path -Path "${TOOLS}\javafx-sdk") {
        Remove-Item -Recurse -Force "${TOOLS}\javafx-sdk" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\openjfx.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\javafx-sdk-* "${TOOLS}\javafx-sdk"
}

# https://bitbucket.org/iBotPeaches/apktool/downloads/ - apktool
$status = Get-FileFromUri -uri "https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.3.jar" -FilePath ".\downloads\apktool.jar" -CheckURL "Yes"
if ($status) {
    Copy-Item ".\downloads\apktool.jar" "${TOOLS}\bin\apktool.jar" -Force
    Copy-Item "setup\utils\apktool.bat" "${TOOLS}\bin\apktool.bat" -Force
}

# https://windows.php.net/download - PHP
$PHP_URL = Get-DownloadUrlFromPage -Url "https://windows.php.net/download" -RegEx '/downloads/releases/php-8.[.0-9]+-nts-Win32-vs16-x64.zip'
$status = Get-FileFromUri -uri "https://windows.php.net${PHP_URL}" -FilePath ".\downloads\php.zip" -CheckURL "Yes"
if ($status) {
    if (Test-Path -Path "${TOOLS}\php") {
        Remove-Item -Recurse -Force "${TOOLS}\php" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\php.zip" -o"${TOOLS}\php" | Out-Null
}

# https://hashcat.net/hashcat/ - hashcat
$status = Get-FileFromUri -uri "https://hashcat.net/files/hashcat-6.2.6.7z" -FilePath ".\downloads\hashcat.7z" -CheckURL "Yes"
if ($status) {
    if (Test-Path -Path "${TOOLS}\hashcat") {
        Remove-Item -Recurse -Force "${TOOLS}\hashcat" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\hashcat.7z" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\hashcat-* "${TOOLS}\hashcat" | Out-Null
}

# https://www.maltego.com/downloads/ - Maltego
$status = Get-FileFromUri -uri "https://downloads.maltego.com/maltego-v4/windows/MaltegoSetup.v4.6.0.exe" -FilePath ".\downloads\maltego.exe" -CheckURL "Yes"


# ELK
$ELK_VERSION = "8.13.2"
Set-Content -Path ".\downloads\elk_version.txt" -Value "${ELK_VERSION}"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\elasticsearch.zip" -CheckURL "Yes"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/kibana/kibana-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\kibana.zip" -CheckURL "Yes"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/logstash/logstash-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\logstash.zip" -CheckURL "Yes"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\elastic-agent.zip" -CheckURL "Yes"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\filebeat.zip" -CheckURL "Yes"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\metricbeat.zip" -CheckURL "Yes"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\packetbeat.zip" -CheckURL "Yes"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\heartbeat.zip" -CheckURL "Yes"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\auditbeat.zip" -CheckURL "Yes"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\winlogbeat.zip" -CheckURL "Yes"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/functionbeat/functionbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\functionbeat.zip" -CheckURL "Yes"

# Remove unused files and directories
if (Test-Path -Path "${TOOLS}\win32") {
    Remove-Item -Recurse -Force "${TOOLS}\win32" | Out-Null 2>&1
}

if (Test-Path -Path "${TOOLS}\win64") {
    Remove-Item -Recurse -Force "${TOOLS}\win64" | Out-Null 2>&1
}

if (Test-Path -Path "${TOOLS}\license.txt") {
    Remove-Item -Force "${TOOLS}\license.txt"
}