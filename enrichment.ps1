# Script to download data to use for enchrichment.
# Data included are:
# - Tor exit nodes
# - Maxmind GeoLite2 ASN database

# Set the currentDirectory to the current directory
$currentDirectory = "${PWD}"

$enrichmentDirectory = "${PWD}\enrichment"

# Create the enrichment directory if it doesn't exist
if (-not (Test-Path -Path ${enrichmentDirectory})) {
    New-Item -ItemType Directory -Path ${enrichmentDirectory} -Force | Out-Null
}

# Get the current date
$DATE = Get-Date -Format "yyyy-MM-dd"

# Read config file
if (-not (Test-Path -Path "${PWD}\config.ps1")) {
    Write-Output "Please create a config.ps1 to download Maxmind databases"
} else {
    . .\config.ps1
}

# Download Tor exit nodes
$folderUrl = "https://collector.torproject.org/archive/exit-lists/"
$torsaveDirectory = "${enrichmentDirectory}\tor"

# Create the save directory for tor if it doesn't exist
if (-not (Test-Path -Path $torsaveDirectory)) {
    New-Item -ItemType Directory -Path $torsaveDirectory -Force | Out-Null
}


#
# TOR exit nodes
#

# Download all exit files for TOR
$webClient = New-Object System.Net.WebClient
$files = $webClient.DownloadString($folderUrl).Split("`n") | Select-String -Pattern '<a href="(exit[^"]+)"' | ForEach-Object { $_.Matches.Groups[1].Value }

foreach ($file in $files) {
    $fileUrl = $folderUrl + $file
    $savePath = Join-Path -Path "${torsaveDirectory}" -ChildPath "${file}"
    Write-Output "Downloading $fileUrl to $savePath"
    $webClient.DownloadFile("${fileUrl}", "${savePath}")
}
$webClient.Dispose()

#
# MAC address lookup files
#

# Get manuf file for MAC address lookup
$manufSaveDirectory = "${enrichmentDirectory}\manuf"
if (-not (Test-Path -Path $manufSaveDirectory)) {
    New-Item -ItemType Directory -Path $manufSaveDirectory -Force | Out-Null
}

$manufUrl = "https://www.wireshark.org/download/automated/data/manuf"
$manufSavePath = Join-Path -Path "${manufSaveDirectory}" -ChildPath "manuf.txt"
Write-Output "Downloading $manufUrl to $manufSavePath"
Invoke-WebRequest -Uri $manufUrl -OutFile $manufSavePath
Copy-Item -Path $manufSavePath -Destination "${manufSaveDirectory}\manuf-${DATE}.txt"

#
# Maxmind GeoLite2 databases
#

# Check if the Maxmind license key is set
if (-not $MAXMIND_LICENSE_KEY) {
    Write-Output "Please set the MAXMIND_LICENSE_KEY variable in config.ps1 if you want to download Maxmind databases"
} else {
    $maxmindSaveDirectory = "${enrichmentDirectory}\maxmind"

    # Create the save directory for maxmind if it doesn't exist
    if (-not (Test-Path -Path $maxmindSaveDirectory)) {
        New-Item -ItemType Directory -Path $maxmindSaveDirectory -Force | Out-Null
    }

    # Download Maxmind GeoLite2 ASN database
    $folderUrl = "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=${MAXMIND_LICENSE_KEY}&suffix=tar.gz"
    $savePath = Join-Path -Path "${maxmindSaveDirectory}" -ChildPath "GeoLite2-ASN.tar.gz"
    Write-Output "Downloading GeoLite2-ASN.tar.gz"
    Invoke-WebRequest -Uri $folderUrl -OutFile $savePath
    Copy-Item -Path $savePath -Destination "${maxmindSaveDirectory}\GeoLite2-ASN-${DATE}.tar.gz"

    # Download Maxmind GeoLite2 City database
    $folderUrl = "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${MAXMIND_LICENSE_KEY}&suffix=tar.gz"
    $savePath = Join-Path -Path "${maxmindSaveDirectory}" -ChildPath "GeoLite2-City.tar.gz"
    Write-Output "Downloading GeoLite2-City.tar.gz"
    Invoke-WebRequest -Uri $folderUrl -OutFile $savePath
    Copy-Item -Path $savePath -Destination "${maxmindSaveDirectory}\GeoLite2-City-${DATE}.tar.gz"

    # Download Maxmind GeoLite2 Country database
    $folderUrl = "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=${MAXMIND_LICENSE_KEY}&suffix=tar.gz"
    $savePath = Join-Path -Path "${maxmindSaveDirectory}" -ChildPath "GeoLite2-Country.tar.gz"
    Write-Output "Downloading GeoLite2-Country.tar.gz"
    Invoke-WebRequest -Uri $folderUrl -OutFile $savePath
    Copy-Item -Path $savePath -Destination "${maxmindSaveDirectory}\GeoLite2-Country-${DATE}.tar.gz"
}

#
# Download the latest version of Suricata rules
#

# Download the latest version of Suricata rules
$suricataUrl = "https://rules.emergingthreats.net/open/suricata-5.0/emerging.rules.zip"
$suricataSaveDirectory = "${enrichmentDirectory}\suricata"

# Create the save directory for suricata if it doesn't exist
if (-not (Test-Path -Path $suricataSaveDirectory)) {
    New-Item -ItemType Directory -Path $suricataSaveDirectory -Force | Out-Null
}

$suricataSavePath = Join-Path -Path "${suricataSaveDirectory}" -ChildPath "emerging.rules.zip"
Write-Output "Downloading $suricataUrl to $suricataSavePath"
Invoke-WebRequest -Uri $suricataUrl -OutFile $suricataSavePath
Copy-Item -Path $suricataSavePath -Destination "${suricataSaveDirectory}\emerging-${DATE}.rules.zip"

#
# Download the latest version of Snort rules
#

# Download the latest version of Snort rules
$snortUrl = "https://www.snort.org/downloads/community/community-rules.tar.gz"
$snortSaveDirectory = "${enrichmentDirectory}\snort"

# Create the save directory for snort if it doesn't exist
if (-not (Test-Path -Path $snortSaveDirectory)) {
    New-Item -ItemType Directory -Path $snortSaveDirectory -Force | Out-Null
}

$snortSavePath = Join-Path -Path "${snortSaveDirectory}" -ChildPath "community-rules.tar.gz"
Write-Output "Downloading $snortUrl to $snortSavePath"
Invoke-WebRequest -Uri $snortUrl -OutFile $snortSavePath
Copy-Item -Path $snortSavePath -Destination "${snortSaveDirectory}\community-rules-${DATE}.rules.tar.gz"

#
# Git repositories for enrichment
#

if (! (Get-Command git )) {
    Write-Output "Need git to checkout git repositories."
    Exit
}

$gitSaveDirectory = "${enrichmentDirectory}\git"
if (-not (Test-Path -Path $gitSaveDirectory)) {
    New-Item -ItemType Directory -Path $gitSaveDirectory -Force | Out-Null
}
Set-Location $gitSaveDirectory

$repourls = `
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
    if ( Test-Path -Path $repo ) {
        Set-Location $repo
        $result = git pull 2>&1
        Write-Output "${repourl}: $result"
        Set-Location ..
    } else {
        $result = git clone $repourl 2>&1
        Write-Output "${repourl}: $result"
    }
}

Set-Location "$currentDirectory"
