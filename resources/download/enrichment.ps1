<#
.SYNOPSIS
    Script to download data to use for enrichment.

.DESCRIPTION
    This script downloads data to use for enrichment. Data included are:
    - Tor exit nodes
    - Maxmind GeoLite2 ASN database

.NOTES
    File Name      : enrichment.ps1
    Author         : Peter R

.LINK
    https://github.com/reuteras/dfirws
#>

# Set the currentDirectory to the current directory
$currentDirectory = "${PWD}"

$enrichmentDirectory = "${PWD}\enrichment"

# Create the enrichment directory if it doesn't exist
if (-not (Test-Path -Path "${enrichmentDirectory}")) {
    New-Item -ItemType Directory -Path "${enrichmentDirectory}" -Force | Out-Null
}

# Get the current date
$DATE = Get-Date -Format "yyyy-MM-dd"

# Read config file
if (-not (Test-Path -Path "${PWD}\config.ps1")) {
    Write-Output "Please create a config.ps1 to download Maxmind databases"
} else {
    . ".\config.ps1"
}

# Download Tor exit nodes
$folderUrl = "https://collector.torproject.org/archive/exit-lists/"
$torsaveDirectory = "${enrichmentDirectory}\tor"

# Create the save directory for tor if it doesn't exist
if (-not (Test-Path -Path "$torsaveDirectory")) {
    New-Item -ItemType Directory -Path "$torsaveDirectory" -Force | Out-Null
}

#
# TOR exit nodes
#

# Download all exit files for TOR
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
# MAC address lookup files
#

# Get manuf file for MAC address lookup
$manufSaveDirectory = "${enrichmentDirectory}\manuf"
if (-not (Test-Path -Path "${manufSaveDirectory}")) {
    New-Item -ItemType Directory -Path "${manufSaveDirectory}" -Force | Out-Null
}

$manufUrl = "https://www.wireshark.org/download/automated/data/manuf"
$manufSavePath = Join-Path -Path "${manufSaveDirectory}" -ChildPath "manuf.txt"
Write-Output "Downloading ${manufUrl}"
Invoke-WebRequest -Uri "${manufUrl}" -OutFile "${manufSavePath}"
Copy-Item -Path "${manufSavePath}" -Destination "${manufSaveDirectory}\manuf-${DATE}.txt" -Force


#
# IPinfo.io Free IP to Country + IP to ASN databases
#

if (-not "${IPINFO_API_KEY}") {
    Write-Output "Please set the IPINFO_API_KEY variable in config.ps1 if you want to download IPinfo databases"
} elseif ($IPINFO_API_KEY -eq "YOUR KEY") {
    Write-Output "Please enter your key for the IPINFO_API_KEY variable in config.ps1 if you like to download databases from IPinfo."
} else {
    $IPinfoSaveDirectory = "${enrichmentDirectory}\ipinfo"
    if (-not (Test-Path -Path "${IPinfoSaveDirectory}")) {
        New-Item -ItemType Directory -Path "${IPinfoSaveDirectory}" -Force | Out-Null
    }

    # Download IPinfo.io Free IP to Country database
    $folderUrl = "https://ipinfo.io/data/free/country_asn.mmdb?token=${IPINFO_API_KEY}"
    $savePath = Join-Path -Path "${IPinfoSaveDirectory}" -ChildPath "country_asn.mmdb"
    Write-Output "Downloading country_asn.mmdb from IPinfo.io"
    Invoke-WebRequest -Uri "${folderUrl}" -OutFile "${savePath}"
    Copy-Item -Path "${savePath}" -Destination "${IPinfoSaveDirectory}\country_asn-${DATE}.mmdb" -Force
}


#
# Maxmind GeoLite2 databases
#

# Check if the Maxmind license key is set
if (-not "${MAXMIND_LICENSE_KEY}") {
    Write-Output "Please set the MAXMIND_LICENSE_KEY variable in config.ps1 if you want to download Maxmind databases"
} elseif ($MAXMIND_LICENSE_KEY -eq "YOUR KEY") {
    Write-Output "Please enter your key for the MAXMIND_LICENSE_KEY variable in config.ps1."
} else {
    $maxmindSaveDirectory = "${enrichmentDirectory}\maxmind"

    # Create the save directory for maxmind if it doesn't exist
    if (-not (Test-Path -Path "${maxmindSaveDirectory}")) {
        New-Item -ItemType Directory -Path "${maxmindSaveDirectory}" -Force | Out-Null
    }

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
    $maxmindUnpackDirectory = "${maxmindSaveDirectory}\unpack"
    if (-not (Test-Path -Path "${maxmindUnpackDirectory}")) {
        New-Item -ItemType Directory -Path "${maxmindUnpackDirectory}" -Force | Out-Null
    }

    $maxmindASNUnpackDirectory = "${maxmindUnpackDirectory}\GeoLite2-ASN"
    if (-not (Test-Path -Path "${maxmindASNUnpackDirectory}")) {
        New-Item -ItemType Directory -Path "${maxmindASNUnpackDirectory}" -Force | Out-Null
    }

    $maxmindCityUnpackDirectory = "${maxmindUnpackDirectory}\GeoLite2-City"
    if (-not (Test-Path -Path "${maxmindCityUnpackDirectory}")) {
        New-Item -ItemType Directory -Path "${maxmindCityUnpackDirectory}" -Force | Out-Null
    }

    $maxmindCountryUnpackDirectory = "${maxmindUnpackDirectory}\GeoLite2-Country"
    if (-not (Test-Path -Path "${maxmindCountryUnpackDirectory}")) {
        New-Item -ItemType Directory -Path "${maxmindCountryUnpackDirectory}" -Force | Out-Null
    }

    Write-Output "Unpacking Maxmind GeoLite2 databases"

    $maxmindASNUnpackPath = Join-Path -Path "${maxmindSaveDirectory}" -ChildPath "GeoLite2-ASN.tar.gz"
    tar xzf "${maxmindASNUnpackPath}" -C $maxmindASNUnpackDirectory

    $maxmindCityUnpackPath = Join-Path -Path "${maxmindSaveDirectory}" -ChildPath "GeoLite2-City.tar.gz"
    tar xzf "${maxmindCityUnpackPath}" -C "${maxmindCityUnpackDirectory}"

    $maxmindCountryUnpackPath = Join-Path -Path "${maxmindSaveDirectory}" -ChildPath "GeoLite2-Country.tar.gz"
    tar xzf "${maxmindCountryUnpackPath}" -C "${maxmindCountryUnpackDirectory}"

    Write-Output "Copying Maxmind GeoLite2 databases to maxmind_current"
    $maxmindCurrentDirectory = "${enrichmentDirectory}\maxmind_current"
    if (-not (Test-Path -Path "${maxmindCurrentDirectory}")) {
        New-Item -ItemType Directory -Path "${maxmindCurrentDirectory}" -Force | Out-Null
    } else {
        Remove-Item -Path "${maxmindCurrentDirectory}" -Recurse -Force
        New-Item -ItemType Directory -Path "${maxmindCurrentDirectory}" -Force | Out-Null
    }

    $maxmindUnpackFiles = Get-ChildItem -Path "${maxmindUnpackDirectory}" -Recurse -Filter "*.mmdb"
    foreach ($maxmindUnpackFile in $maxmindUnpackFiles) {
        Copy-Item -Path "${maxmindUnpackFile}" -Destination "${maxmindCurrentDirectory}" -Force
    }

    # Remove unpack directory
    Remove-Item -Path "${maxmindUnpackDirectory}" -Recurse -Force
}

#
# Download the latest version of Suricata rules
#

# Download the latest version of Suricata rules
$suricataUrl = "https://rules.emergingthreats.net/open/suricata-5.0/emerging.rules.zip"
$suricataSaveDirectory = "${enrichmentDirectory}\suricata"

# Create the save directory for suricata if it doesn't exist
if (-not (Test-Path -Path "${suricataSaveDirectory}")) {
    New-Item -ItemType Directory -Path "${suricataSaveDirectory}" -Force | Out-Null
}

$suricataSavePath = Join-Path -Path "${suricataSaveDirectory}" -ChildPath "emerging.rules.zip"
Write-Output "Downloading $suricataUrl"
Invoke-WebRequest -Uri "${suricataUrl}" -OutFile "${suricataSavePath}"
Copy-Item -Path "${suricataSavePath}" -Destination "${suricataSaveDirectory}\emerging-${DATE}.rules.zip" -Force

#
# Download the latest version of Snort rules
#

# Download the latest version of Snort rules
$snortUrl = "https://www.snort.org/downloads/community/community-rules.tar.gz"
$snortSaveDirectory = "${enrichmentDirectory}\snort"

# Create the save directory for snort if it doesn't exist
if (-not (Test-Path -Path "${snortSaveDirectory}")) {
    New-Item -ItemType Directory -Path "${snortSaveDirectory}" -Force | Out-Null
}

$snortSavePath = Join-Path -Path "${snortSaveDirectory}" -ChildPath "community-rules.tar.gz"
Write-Output "Downloading $snortUrl"
Invoke-WebRequest -Uri "${snortUrl}" -OutFile "${snortSavePath}"
Copy-Item -Path "${snortSavePath}" -Destination "${snortSaveDirectory}\community-rules-${DATE}.rules.tar.gz" -Force

#
# Git repositories for enrichment
#

if (! (Get-Command git )) {
    Write-Output "Need git to checkout git repositories."
    Exit
} else {
    Write-Output "Updating git repositories."
}

$gitSaveDirectory = "${enrichmentDirectory}\git"
if (-not (Test-Path -Path "${gitSaveDirectory}")) {
    New-Item -ItemType Directory -Path "${gitSaveDirectory}" -Force | Out-Null
}
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
        git pull 2>&1 | Out-Null
        Set-Location ..
    } else {
        git clone "${repourl}" 2>&1 | Out-Null
    }
}

# Yara rules
Write-Output "Downloading Yara rules"
$yaraSaveDirectory = "${enrichmentDirectory}\yara"
if (-not (Test-Path -Path "${yaraSaveDirectory}")) {
    New-Item -ItemType Directory -Path "${yaraSaveDirectory}" -Force | Out-Null
}
Set-Location "${yaraSaveDirectory}"

$status = Get-FileFromUri -uri "https://github.com/YARAHQ/yara-forge/releases/latest/download/yara-forge-rules-core.zip" -FilePath ".\enrichment\yara\yara-forge-rules-core.zip"
$status = Get-FileFromUri -uri "https://github.com/YARAHQ/yara-forge/releases/latest/download/yara-forge-rules-extended.zip" -FilePath ".\enrichment\yara\yara-forge-rules-extended.zip"
$status = Get-FileFromUri -uri "https://github.com/YARAHQ/yara-forge/releases/latest/download/yara-forge-rules-full.zip" -FilePath ".\enrichment\yara\yara-forge-rules-full.zip"

$null = $status

# Unzip yara signatures
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${yaraSaveDirectory}\yara-forge-rules-core.zip" -o"${yaraSaveDirectory}" | Out-Null
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${yaraSaveDirectory}\yara-forge-rules-extended.zip" -o"${yaraSaveDirectory}" | Out-Null
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${yaraSaveDirectory}\yara-forge-rules-full.zip" -o"${yaraSaveDirectory}" | Out-Null

Set-Location "${currentDirectory}"
