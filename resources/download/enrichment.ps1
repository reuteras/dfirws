# Script to download data to use for enrichment.

. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

# Set directories
$currentDirectory = "${PWD}"
$enrichmentDirectory = "${PWD}\enrichment"
$cveSaveDirectory = "${enrichmentDirectory}\cve"
$geolocusSaveDirectory = "${enrichmentDirectory}\geolocus"
$gitSaveDirectory = "${enrichmentDirectory}\git"
$IPinfoSaveDirectory = "${enrichmentDirectory}\ipinfo"
$manufSaveDirectory = "${enrichmentDirectory}\manuf"
$maxmindCurrentDirectory = "${enrichmentDirectory}\maxmind_current"
$maxmindSaveDirectory = "${enrichmentDirectory}\maxmind"
$maxmindUnpackDirectory = "${maxmindSaveDirectory}\unpack"
$snortSaveDirectory = "${enrichmentDirectory}\snort"
$suricataSaveDirectory = "${enrichmentDirectory}\suricata"
$torsaveDirectory = "${enrichmentDirectory}\tor"
$yaraSaveDirectory = "${enrichmentDirectory}\yara"
$maxmindASNUnpackDirectory = "${maxmindUnpackDirectory}\GeoLite2-ASN"
$maxmindCityUnpackDirectory = "${maxmindUnpackDirectory}\GeoLite2-City"
$maxmindCountryUnpackDirectory = "${maxmindUnpackDirectory}\GeoLite2-Country"

# Create directories if they don't exist
Foreach ($directory in @($enrichmentDirectory, $cveSaveDirectory, $geolocusSaveDirectory, $gitSaveDirectory, $IPinfoSaveDirectory, $manufSaveDirectory, $maxmindCurrentDirectory, $maxmindSaveDirectory, $maxmindUnpackDirectory, $maxmindASNUnpackDirectory, $maxmindCityUnpackDirectory, $maxmindCountryUnpackDirectory, $snortSaveDirectory, $suricataSaveDirectory, $torsaveDirectory, $yaraSaveDirectory)) {
    if (-not (Test-Path -Path "${directory}")) {
        New-Item -ItemType Directory -Path "${directory}" -Force | Out-Null
    }
}

if (-not (Test-Path -Path "${maxmindCurrentDirectory}")) {
    New-Item -ItemType Directory -Path "${maxmindCurrentDirectory}" -Force | Out-Null
} else {
    Remove-Item -Path "${maxmindCurrentDirectory}" -Recurse -Force
    New-Item -ItemType Directory -Path "${maxmindCurrentDirectory}" -Force | Out-Null
}

if (!(Test-Path -Path "$geolocusSaveDirectory\.cache\geolocus-cli")) {
    New-Item -ItemType Directory -Path "$geolocusSaveDirectory\.cache\geolocus-cli" -Force | Out-Null
}

if (!(Test-Path -Path "$geolocusSaveDirectory\mmdb")) {
    New-Item -ItemType Directory -Path "$geolocusSaveDirectory\mmdb" -Force | Out-Null
}

# Get the current date
$DATE = Get-Date -Format "yyyy-MM-dd"

# Download Tor exit nodes
$folderUrl = "https://collector.torproject.org/archive/exit-lists/"

#
# TOR exit nodes
$webClient = New-Object System.Net.WebClient
$files = $webClient.DownloadString($folderUrl).Split("`n") | Select-String -Pattern '<a href="(exit[^"]+)"' | ForEach-Object { $_.Matches.Groups[1].Value }

Write-Output "Downloading TOR exit files"
foreach ($file in $files) {
    $fileUrl = "$folderUrl" + "$file"
    $savePath = Join-Path -Path "${torsaveDirectory}" -ChildPath "${file}"
    curl --silent -L -z "$savePath" -o "$savePath" "$fileUrl"
}
$webClient.Dispose()

#
# MAC address lookup files - manuf file
$manufUrl = "https://www.wireshark.org/download/automated/data/manuf"
$manufSavePath = Join-Path -Path "${manufSaveDirectory}" -ChildPath "manuf.txt"
Write-Output "Downloading ${manufUrl}"
Invoke-WebRequest -Uri "${manufUrl}" -OutFile "${manufSavePath}"
Copy-Item -Path "${manufSavePath}" -Destination "${manufSaveDirectory}\manuf-${DATE}.txt" -Force

#
# IPinfo.io Free IP to Country + IP to ASN databases
if (-not "${IPINFO_API_KEY}") {
    Write-Output "Please set the IPINFO_API_KEY variable in config.ps1 if you want to download IPinfo databases"
} elseif ($IPINFO_API_KEY -eq "YOUR KEY") {
    Write-Output "Please enter your key for the IPINFO_API_KEY variable in config.ps1 if you like to download databases from IPinfo."
} else {
    # Download IPinfo.io Free IP to Country database
    $folderUrl = "https://ipinfo.io/data/free/country_asn.mmdb?token=${IPINFO_API_KEY}"
    $savePath = Join-Path -Path "${IPinfoSaveDirectory}" -ChildPath "country_asn.mmdb"
    Write-Output "Downloading country_asn.mmdb from IPinfo.io"
    Invoke-WebRequest -Uri "${folderUrl}" -OutFile "${savePath}"
    Copy-Item -Path "${savePath}" -Destination "${IPinfoSaveDirectory}\country_asn-${DATE}.mmdb" -Force
}

#
# Maxmind GeoLite2 databases

# Check if the Maxmind license key is set
if (-not "${MAXMIND_LICENSE_KEY}") {
    Write-Output "Please set the MAXMIND_LICENSE_KEY variable in config.ps1 if you want to download Maxmind databases"
} elseif ($MAXMIND_LICENSE_KEY -eq "YOUR KEY") {
    Write-Output "Please enter your key for the MAXMIND_LICENSE_KEY variable in config.ps1."
} else {
    # Download Maxmind GeoLite2 ASN database
    $folderUrl = "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=${MAXMIND_LICENSE_KEY}&suffix=tar.gz"
    $savePath = Join-Path -Path "${maxmindSaveDirectory}" -ChildPath "GeoLite2-ASN.tar.gz"
    Write-Output "Downloading GeoLite2-ASN.tar.gz"
    Invoke-WebRequest -Uri "${folderUrl}" -OutFile "${savePath}"
    Copy-Item -Path "${savePath}" -Destination "${maxmindSaveDirectory}\GeoLite2-ASN-${DATE}.tar.gz" -Force

    # Download Maxmind GeoLite2 City database
    $folderUrl = "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${MAXMIND_LICENSE_KEY}&suffix=tar.gz"
    $savePath = Join-Path -Path "${maxmindSaveDirectory}" -ChildPath "GeoLite2-City.tar.gz"
    Write-Output "Downloading GeoLite2-City.tar.gz"
    Invoke-WebRequest -Uri "${folderUrl}" -OutFile "${savePath}"
    Copy-Item -Path "${savePath}" -Destination "${maxmindSaveDirectory}\GeoLite2-City-${DATE}.tar.gz" -Force

    # Download Maxmind GeoLite2 Country database
    $folderUrl = "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=${MAXMIND_LICENSE_KEY}&suffix=tar.gz"
    $savePath = Join-Path -Path "${maxmindSaveDirectory}" -ChildPath "GeoLite2-Country.tar.gz"
    Write-Output "Downloading GeoLite2-Country.tar.gz"
    Invoke-WebRequest -Uri "${folderUrl}" -OutFile "${savePath}"
    Copy-Item -Path "${savePath}" -Destination "${maxmindSaveDirectory}\GeoLite2-Country-${DATE}.tar.gz" -Force

    # Unpack latest Maxmind GeoLite2 databases
    Write-Output "Unpacking Maxmind GeoLite2 databases"

    $maxmindASNUnpackPath = Join-Path -Path "${maxmindSaveDirectory}" -ChildPath "GeoLite2-ASN.tar.gz"
    tar xzf "${maxmindASNUnpackPath}" -C $maxmindASNUnpackDirectory

    $maxmindCityUnpackPath = Join-Path -Path "${maxmindSaveDirectory}" -ChildPath "GeoLite2-City.tar.gz"
    tar xzf "${maxmindCityUnpackPath}" -C "${maxmindCityUnpackDirectory}"

    $maxmindCountryUnpackPath = Join-Path -Path "${maxmindSaveDirectory}" -ChildPath "GeoLite2-Country.tar.gz"
    tar xzf "${maxmindCountryUnpackPath}" -C "${maxmindCountryUnpackDirectory}"

    Write-Output "Copying Maxmind GeoLite2 databases to maxmind_current"
    $maxmindUnpackFiles = Get-ChildItem -Path "${maxmindUnpackDirectory}" -Recurse -Filter "*.mmdb"
    foreach ($maxmindUnpackFile in $maxmindUnpackFiles) {
        Copy-Item -Path "${maxmindUnpackFile}" -Destination "${maxmindCurrentDirectory}" -Force
    }

    if (Test-Path -Path ".\mount\Tools\logboost") {
        Copy-Item -Path "${maxmindCurrentDirectory}\*.mmdb" -Destination ".\mount\Tools\logboost\"  -Force
    }

    # Remove unpack directory
    Remove-Item -Path "${maxmindUnpackDirectory}" -Recurse -Force
}

#
# Download Geolocus mmdb file
$geolocus_url = "https://www.geolocus.io/geolocus.mmdb"
$geolocusSavePath = Join-Path -Path "$geolocusSaveDirectory" -ChildPath "geolocus.mmdb"
Write-Output "Downloading Geolocus mmdb file"
Invoke-WebRequest -Uri "${geolocus_url}" -OutFile "${geolocusSavePath}"
Copy-Item -Path "${geolocusSavePath}" -Destination "$geolocusSaveDirectory\mmdb\geolocus-${DATE}.mmdb" -Force
Copy-Item -Path "${geolocusSavePath}" -Destination "$geolocusSaveDirectory\.cache\geolocus-cli\geolocus.mmdb" -Force
Remove-Item -Path "${geolocusSavePath}" -Force

#
# Download the latest version of Suricata rules
$suricataUrl = "https://rules.emergingthreats.net/open/suricata-5.0/emerging.rules.zip"
$suricataSavePath = Join-Path -Path "${suricataSaveDirectory}" -ChildPath "emerging.rules.zip"
Write-Output "Downloading $suricataUrl"
Invoke-WebRequest -Uri "${suricataUrl}" -OutFile "${suricataSavePath}"
Copy-Item -Path "${suricataSavePath}" -Destination "${suricataSaveDirectory}\emerging-${DATE}.rules.zip" -Force

#
# Download the latest version of Snort rules
$snortUrl = "https://www.snort.org/downloads/community/snort3-community-rules.tar.gz"
$snortSavePath = Join-Path -Path "${snortSaveDirectory}" -ChildPath "community-rules.tar.gz"
Write-Output "Downloading $snortUrl"
Invoke-WebRequest -Uri "${snortUrl}" -OutFile "${snortSavePath}"
Copy-Item -Path "${snortSavePath}" -Destination "${snortSaveDirectory}\community-rules-${DATE}.rules.tar.gz" -Force

#
# Git repositories for enrichment
Write-Output "Updating git repositories."
Set-Location "${gitSaveDirectory}"
$repourls = `
    "https://github.com/securityscorecard/SSC-Threat-Intel-IoCs.git", `
    "https://github.com/volexity/threat-intel", `
    "https://github.com/X4BNet/lists_vpn.git", `
    "https://github.com/X4BNet/lists_torexit.git", `
    "https://github.com/X4BNet/lists_stopforumspam.git", `
    "https://github.com/X4BNet/lists_searchengine.git", `
    "https://github.com/X4BNet/lists_bots.git", `
    "https://github.com/X4BNet/lists_uptimerobot.git", `
    "https://github.com/X4BNet/lists_cloudflare.git", `
    "https://github.com/X4BNet/lists_route53.git"

foreach ($repourl in $repourls) {
    $repo = Write-Output $repourl | ForEach-Object { $_ -replace "^.*/" } | ForEach-Object { $_ -replace "\.git$" }
    if ( Test-Path -Path "${repo}" ) {
        Set-Location "${repo}"
        git pull 2>&1 | ForEach-Object{ "$_" } | Out-Null
        Set-Location ..
    } else {
        git clone "${repourl}" 2>&1 | ForEach-Object{ "$_" } | Out-Null
    }
}

# Yara rules
Write-Output "Downloading Yara rules"
Set-Location "${yaraSaveDirectory}"
$status = Get-FileFromUri -uri "https://github.com/YARAHQ/yara-forge/releases/latest/download/yara-forge-rules-core.zip" -FilePath ".\enrichment\yara\yara-forge-rules-core.zip"
$status = Get-FileFromUri -uri "https://github.com/YARAHQ/yara-forge/releases/latest/download/yara-forge-rules-extended.zip" -FilePath ".\enrichment\yara\yara-forge-rules-extended.zip"
$status = Get-FileFromUri -uri "https://github.com/YARAHQ/yara-forge/releases/latest/download/yara-forge-rules-full.zip" -FilePath ".\enrichment\yara\yara-forge-rules-full.zip"
$null = $status

# Unzip yara signatures
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${yaraSaveDirectory}\yara-forge-rules-core.zip" -o"${yaraSaveDirectory}" | Out-Null
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${yaraSaveDirectory}\yara-forge-rules-extended.zip" -o"${yaraSaveDirectory}" | Out-Null
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${yaraSaveDirectory}\yara-forge-rules-full.zip" -o"${yaraSaveDirectory}" | Out-Null

# Get CVE data
Write-Output "Downloading CVE data"
Set-Location "${cveSaveDirectory}"
$status = Get-FileFromUri -uri "https://github.com/CVEProject/cvelistV5/archive/refs/heads/main.zip" -FilePath ".\enrichment\cve\main.zip"
$status = Get-GitHubRelease -repo "CVEProject/cvelistV5" -path ".\enrichment\cve\all_CVEs_at_midnight.zip.zip" -match "all_CVEs_at_midnight.zip.zip$"

Set-Location "${currentDirectory}"

#
# TOR Exit Nodes
#
$TOOL_DEFINITIONS += @{
    Name = "TOR Exit Nodes"
    Homepage = "https://collector.torproject.org/archive/exit-lists/"
    Vendor = "The Tor Project"
    License = "Public Data"
    LicenseUrl = "https://www.torproject.org/"
    Category = "Enrichment\Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("tor", "exit-nodes", "network", "threat-intel")
    Notes = "TOR exit node lists from the Tor Project collector archive."
    Tips = "Use these lists to identify if an IP address is a known TOR exit node. Useful for network forensics and threat intelligence."
    Usage = "The exit node lists are downloaded from the Tor Project collector archive and stored in the enrichment\tor directory. Each file contains exit relay information for a specific time period."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# Wireshark MAC Address Lookup (manuf)
#
$TOOL_DEFINITIONS += @{
    Name = "Wireshark Manuf"
    Homepage = "https://www.wireshark.org/download/automated/data/manuf"
    Vendor = "Wireshark Foundation"
    License = "GPL-2.0"
    LicenseUrl = "https://www.wireshark.org/about.html"
    Category = "Enrichment\Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".txt")
    Tags = @("mac-address", "network", "wireshark")
    Notes = "Wireshark OUI/MAC address manufacturer lookup file."
    Tips = "Use the manuf file to resolve MAC address prefixes (OUI) to vendor/manufacturer names. Useful for identifying devices on a network."
    Usage = "The manuf file is downloaded from Wireshark and stored in enrichment\manuf. It maps MAC address prefixes to manufacturer names."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# IPinfo.io Free IP to Country + ASN database
#
$TOOL_DEFINITIONS += @{
    Name = "IPinfo Country ASN"
    Homepage = "https://ipinfo.io/"
    Vendor = "IPinfo"
    License = "Creative Commons Attribution-ShareAlike 4.0"
    LicenseUrl = "https://ipinfo.io/terms-of-service"
    Category = "Enrichment\Geolocation"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".mmdb")
    Tags = @("geolocation", "ip-address", "asn")
    Notes = "IPinfo.io free IP to Country and ASN database in MMDB format. Requires IPINFO_API_KEY."
    Tips = "Use this MMDB file with tools that support MaxMind DB format to resolve IP addresses to country and ASN information. Set IPINFO_API_KEY in config.ps1 to download."
    Usage = "The country_asn.mmdb file is downloaded from IPinfo.io and stored in enrichment\ipinfo. It provides IP to country and ASN lookups."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# MaxMind GeoLite2 ASN
#
$TOOL_DEFINITIONS += @{
    Name = "MaxMind GeoLite2 ASN"
    Homepage = "https://dev.maxmind.com/geoip/geolite2-free-geolocation-data"
    Vendor = "MaxMind"
    License = "GeoLite2 End User License Agreement"
    LicenseUrl = "https://www.maxmind.com/en/geolite2/eula"
    Category = "Enrichment\Geolocation"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".mmdb", ".tar.gz")
    Tags = @("geolocation", "asn", "maxmind")
    Notes = "MaxMind GeoLite2 ASN database for mapping IP addresses to Autonomous System Numbers. Requires MAXMIND_LICENSE_KEY."
    Tips = "Use this database with tools that support MaxMind DB format to resolve IP addresses to ASN information. Set MAXMIND_LICENSE_KEY in config.ps1 to download."
    Usage = "The GeoLite2-ASN.mmdb file is downloaded from MaxMind and stored in enrichment\maxmind_current. It provides IP to ASN lookups."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# MaxMind GeoLite2 City
#
$TOOL_DEFINITIONS += @{
    Name = "MaxMind GeoLite2 City"
    Homepage = "https://dev.maxmind.com/geoip/geolite2-free-geolocation-data"
    Vendor = "MaxMind"
    License = "GeoLite2 End User License Agreement"
    LicenseUrl = "https://www.maxmind.com/en/geolite2/eula"
    Category = "Enrichment\Geolocation"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".mmdb", ".tar.gz")
    Tags = @("geolocation", "city", "maxmind")
    Notes = "MaxMind GeoLite2 City database for mapping IP addresses to city-level geolocation. Requires MAXMIND_LICENSE_KEY."
    Tips = "Use this database with tools that support MaxMind DB format to resolve IP addresses to city-level location data. Set MAXMIND_LICENSE_KEY in config.ps1 to download."
    Usage = "The GeoLite2-City.mmdb file is downloaded from MaxMind and stored in enrichment\maxmind_current. It provides IP to city-level geolocation lookups."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# MaxMind GeoLite2 Country
#
$TOOL_DEFINITIONS += @{
    Name = "MaxMind GeoLite2 Country"
    Homepage = "https://dev.maxmind.com/geoip/geolite2-free-geolocation-data"
    Vendor = "MaxMind"
    License = "GeoLite2 End User License Agreement"
    LicenseUrl = "https://www.maxmind.com/en/geolite2/eula"
    Category = "Enrichment\Geolocation"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".mmdb", ".tar.gz")
    Tags = @("geolocation", "country", "maxmind")
    Notes = "MaxMind GeoLite2 Country database for mapping IP addresses to countries. Requires MAXMIND_LICENSE_KEY."
    Tips = "Use this database with tools that support MaxMind DB format to resolve IP addresses to country-level location data. Set MAXMIND_LICENSE_KEY in config.ps1 to download."
    Usage = "The GeoLite2-Country.mmdb file is downloaded from MaxMind and stored in enrichment\maxmind_current. It provides IP to country lookups."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# Geolocus MMDB
#
$TOOL_DEFINITIONS += @{
    Name = "Geolocus"
    Homepage = "https://www.geolocus.io/"
    Vendor = "Geolocus"
    License = "See website"
    LicenseUrl = "https://www.geolocus.io/"
    Category = "Enrichment\Geolocation"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".mmdb")
    Tags = @("geolocation", "mmdb")
    Notes = "Geolocus MMDB geolocation database."
    Tips = "Use this MMDB file with tools that support MaxMind DB format for IP geolocation lookups."
    Usage = "The geolocus.mmdb file is downloaded from geolocus.io and stored in enrichment\geolocus. It provides an alternative IP geolocation database."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# Suricata Rules (Emerging Threats)
#
$TOOL_DEFINITIONS += @{
    Name = "Suricata Rules"
    Homepage = "https://rules.emergingthreats.net/"
    Vendor = "Proofpoint (Emerging Threats)"
    License = "BSD License"
    LicenseUrl = "https://rules.emergingthreats.net/OPEN_download_instructions.html"
    Category = "Enrichment\IDS"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".rules", ".zip")
    Tags = @("suricata", "ids", "detection-rules", "network")
    Notes = "Emerging Threats open ruleset for Suricata IDS."
    Tips = "Use these rules with Suricata to detect network-based threats. The rules are updated regularly and cover a wide range of threat categories."
    Usage = "The emerging.rules.zip is downloaded from Emerging Threats and stored in enrichment\suricata. Extract and use with Suricata IDS for network traffic analysis."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# Snort Rules (Community)
#
$TOOL_DEFINITIONS += @{
    Name = "Snort Rules"
    Homepage = "https://www.snort.org/downloads"
    Vendor = "Cisco Talos"
    License = "GPL-2.0"
    LicenseUrl = "https://www.snort.org/license"
    Category = "Enrichment\IDS"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".rules", ".tar.gz")
    Tags = @("snort", "ids", "detection-rules", "network")
    Notes = "Snort 3 community ruleset for network intrusion detection."
    Tips = "Use these rules with Snort or compatible IDS tools to detect network-based threats."
    Usage = "The community-rules.tar.gz is downloaded from snort.org and stored in enrichment\snort. Extract and use with Snort IDS for network traffic analysis."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# YARA Forge Rules (Core)
#
$TOOL_DEFINITIONS += @{
    Name = "YARA Forge Rules Core"
    Homepage = "https://github.com/YARAHQ/yara-forge"
    Vendor = "YARAHQ"
    License = "See individual rule licenses"
    LicenseUrl = "https://github.com/YARAHQ/yara-forge/blob/main/LICENSE"
    Category = "Enrichment\YARA"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".yar", ".zip")
    Tags = @("yara", "detection-rules", "malware-detection")
    Notes = "YARA Forge core ruleset - curated set of high-quality YARA rules."
    Tips = "The core ruleset contains the most reliable and well-tested YARA rules. Use with YARA or YARA-compatible tools for malware detection and classification."
    Usage = "The yara-forge-rules-core.zip is downloaded from YARA Forge GitHub releases and stored in enrichment\yara. Extract and use with YARA-compatible tools."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# YARA Forge Rules (Extended)
#
$TOOL_DEFINITIONS += @{
    Name = "YARA Forge Rules Extended"
    Homepage = "https://github.com/YARAHQ/yara-forge"
    Vendor = "YARAHQ"
    License = "See individual rule licenses"
    LicenseUrl = "https://github.com/YARAHQ/yara-forge/blob/main/LICENSE"
    Category = "Enrichment\YARA"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".yar", ".zip")
    Tags = @("yara", "detection-rules", "malware-detection")
    Notes = "YARA Forge extended ruleset - broader set of YARA rules beyond the core set."
    Tips = "The extended ruleset includes additional YARA rules that go beyond the core set. May have higher false positive rates but covers more threats."
    Usage = "The yara-forge-rules-extended.zip is downloaded from YARA Forge GitHub releases and stored in enrichment\yara. Extract and use with YARA-compatible tools."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# YARA Forge Rules (Full)
#
$TOOL_DEFINITIONS += @{
    Name = "YARA Forge Rules Full"
    Homepage = "https://github.com/YARAHQ/yara-forge"
    Vendor = "YARAHQ"
    License = "See individual rule licenses"
    LicenseUrl = "https://github.com/YARAHQ/yara-forge/blob/main/LICENSE"
    Category = "Enrichment\YARA"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".yar", ".zip")
    Tags = @("yara", "detection-rules", "malware-detection")
    Notes = "YARA Forge full ruleset - comprehensive collection of all available YARA rules."
    Tips = "The full ruleset contains all available YARA rules from YARA Forge. Most comprehensive coverage but may have higher false positive rates."
    Usage = "The yara-forge-rules-full.zip is downloaded from YARA Forge GitHub releases and stored in enrichment\yara. Extract and use with YARA-compatible tools."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# CVE Data (CVEProject/cvelistV5)
#
$TOOL_DEFINITIONS += @{
    Name = "CVE Data"
    Homepage = "https://github.com/CVEProject/cvelistV5"
    Vendor = "CVE Project"
    License = "See repository"
    LicenseUrl = "https://github.com/CVEProject/cvelistV5/blob/main/LICENSE"
    Category = "Enrichment\Vulnerability"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".json", ".zip")
    Tags = @("cve", "vulnerability", "threat-intel")
    Notes = "CVE list data from the CVEProject cvelistV5 repository."
    Tips = "Use this data to look up CVE details for vulnerability analysis. The data includes both the main branch archive and the all_CVEs_at_midnight snapshot."
    Usage = "CVE data is downloaded from the CVEProject/cvelistV5 GitHub repository and stored in enrichment\cve. Contains JSON-formatted CVE records."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# SSC-Threat-Intel-IoCs
#
$TOOL_DEFINITIONS += @{
    Name = "SSC-Threat-Intel-IoCs"
    Homepage = "https://github.com/securityscorecard/SSC-Threat-Intel-IoCs"
    Vendor = "SecurityScorecard"
    License = "See repository"
    LicenseUrl = "https://github.com/securityscorecard/SSC-Threat-Intel-IoCs"
    Category = "Enrichment\Threat Intelligence"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("threat-intel", "ioc")
    Notes = "SecurityScorecard threat intelligence indicators of compromise."
    Tips = "Use these IoCs for threat hunting and incident response. Contains indicators from SecurityScorecard threat research."
    Usage = "The repository is cloned to enrichment\git\SSC-Threat-Intel-IoCs and updated via git pull."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# Volexity Threat Intel
#
$TOOL_DEFINITIONS += @{
    Name = "Volexity Threat Intel"
    Homepage = "https://github.com/volexity/threat-intel"
    Vendor = "Volexity"
    License = "See repository"
    LicenseUrl = "https://github.com/volexity/threat-intel"
    Category = "Enrichment\Threat Intelligence"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("threat-intel", "ioc")
    Notes = "Volexity threat intelligence indicators and YARA rules."
    Tips = "Use these indicators and rules for threat hunting. Contains YARA rules and IoCs from Volexity threat research."
    Usage = "The repository is cloned to enrichment\git\threat-intel and updated via git pull."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# X4BNet VPN List
#
$TOOL_DEFINITIONS += @{
    Name = "X4BNet VPN List"
    Homepage = "https://github.com/X4BNet/lists_vpn"
    Vendor = "X4BNet"
    License = "See repository"
    LicenseUrl = "https://github.com/X4BNet/lists_vpn"
    Category = "Enrichment\Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("vpn", "network", "blocklist")
    Notes = "X4BNet list of known VPN IP addresses."
    Tips = "Use this list to identify VPN exit nodes in network traffic. Useful for network forensics and access log analysis."
    Usage = "The repository is cloned to enrichment\git\lists_vpn and updated via git pull."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# X4BNet TOR Exit List
#
$TOOL_DEFINITIONS += @{
    Name = "X4BNet TOR Exit List"
    Homepage = "https://github.com/X4BNet/lists_torexit"
    Vendor = "X4BNet"
    License = "See repository"
    LicenseUrl = "https://github.com/X4BNet/lists_torexit"
    Category = "Enrichment\Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("tor", "network", "blocklist")
    Notes = "X4BNet list of known TOR exit node IP addresses."
    Tips = "Use this list to identify TOR exit nodes in network traffic. Complements the Tor Project exit node data."
    Usage = "The repository is cloned to enrichment\git\lists_torexit and updated via git pull."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# X4BNet StopForumSpam List
#
$TOOL_DEFINITIONS += @{
    Name = "X4BNet StopForumSpam"
    Homepage = "https://github.com/X4BNet/lists_stopforumspam"
    Vendor = "X4BNet"
    License = "See repository"
    LicenseUrl = "https://github.com/X4BNet/lists_stopforumspam"
    Category = "Enrichment\Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("spam", "network", "blocklist")
    Notes = "X4BNet list of known spam IP addresses from StopForumSpam."
    Tips = "Use this list to identify known spammer IP addresses in network traffic or access logs."
    Usage = "The repository is cloned to enrichment\git\lists_stopforumspam and updated via git pull."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# X4BNet Search Engine List
#
$TOOL_DEFINITIONS += @{
    Name = "X4BNet Search Engine List"
    Homepage = "https://github.com/X4BNet/lists_searchengine"
    Vendor = "X4BNet"
    License = "See repository"
    LicenseUrl = "https://github.com/X4BNet/lists_searchengine"
    Category = "Enrichment\Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("search-engine", "network", "blocklist")
    Notes = "X4BNet list of known search engine crawler IP addresses."
    Tips = "Use this list to identify search engine crawlers in network traffic or access logs."
    Usage = "The repository is cloned to enrichment\git\lists_searchengine and updated via git pull."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# X4BNet Bots List
#
$TOOL_DEFINITIONS += @{
    Name = "X4BNet Bots List"
    Homepage = "https://github.com/X4BNet/lists_bots"
    Vendor = "X4BNet"
    License = "See repository"
    LicenseUrl = "https://github.com/X4BNet/lists_bots"
    Category = "Enrichment\Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("bots", "network", "blocklist")
    Notes = "X4BNet list of known bot IP addresses."
    Tips = "Use this list to identify known bot IP addresses in network traffic or access logs."
    Usage = "The repository is cloned to enrichment\git\lists_bots and updated via git pull."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# X4BNet UptimeRobot List
#
$TOOL_DEFINITIONS += @{
    Name = "X4BNet UptimeRobot List"
    Homepage = "https://github.com/X4BNet/lists_uptimerobot"
    Vendor = "X4BNet"
    License = "See repository"
    LicenseUrl = "https://github.com/X4BNet/lists_uptimerobot"
    Category = "Enrichment\Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("monitoring", "network", "blocklist")
    Notes = "X4BNet list of known UptimeRobot monitoring IP addresses."
    Tips = "Use this list to identify UptimeRobot monitoring service IP addresses in network traffic or access logs."
    Usage = "The repository is cloned to enrichment\git\lists_uptimerobot and updated via git pull."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# X4BNet Cloudflare List
#
$TOOL_DEFINITIONS += @{
    Name = "X4BNet Cloudflare List"
    Homepage = "https://github.com/X4BNet/lists_cloudflare"
    Vendor = "X4BNet"
    License = "See repository"
    LicenseUrl = "https://github.com/X4BNet/lists_cloudflare"
    Category = "Enrichment\Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("cloudflare", "network", "blocklist")
    Notes = "X4BNet list of known Cloudflare IP addresses."
    Tips = "Use this list to identify Cloudflare CDN IP addresses in network traffic. Useful for distinguishing CDN traffic from direct connections."
    Usage = "The repository is cloned to enrichment\git\lists_cloudflare and updated via git pull."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

#
# X4BNet Route53 List
#
$TOOL_DEFINITIONS += @{
    Name = "X4BNet Route53 List"
    Homepage = "https://github.com/X4BNet/lists_route53"
    Vendor = "X4BNet"
    License = "See repository"
    LicenseUrl = "https://github.com/X4BNet/lists_route53"
    Category = "Enrichment\Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("route53", "network", "blocklist")
    Notes = "X4BNet list of known AWS Route53 health check IP addresses."
    Tips = "Use this list to identify AWS Route53 health check IP addresses in network traffic or access logs."
    Usage = "The repository is cloned to enrichment\git\lists_route53 and updated via git pull."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

# ============================================================================
# Generate tool files for enrichment data sources
# ============================================================================
New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "enrichment"
