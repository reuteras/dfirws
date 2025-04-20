# Script to download data to use for enrichment.

# Set directories
$currentDirectory = "${PWD}"
$enrichmentDirectory = "${PWD}\enrichment"
$cveSaveDirectory = "${enrichmentDirectory}\cve"
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
Foreach ($directory in @($enrichmentDirectory, $cveSaveDirectory, $gitSaveDirectory, $IPinfoSaveDirectory, $manufSaveDirectory, $maxmindCurrentDirectory, $maxmindSaveDirectory, $maxmindUnpackDirectory, $maxmindASNUnpackDirectory, $maxmindCityUnpackDirectory, $maxmindCountryUnpackDirectory, $snortSaveDirectory, $suricataSaveDirectory, $torsaveDirectory, $yaraSaveDirectory)) {
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
$status = Get-FileFromUri -uri "https://cve.mitre.org/data/downloads/allitems.csv" -FilePath ".\enrichment\cve\allitems.csv"
$status = Get-GitHubRelease -repo "CVEProject/cvelistV5" -path ".\enrichment\cve\all_CVEs_at_midnight.zip.zip" -match "all_CVEs_at_midnight.zip.zip$"

Set-Location "${currentDirectory}"
