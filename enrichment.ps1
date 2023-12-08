# Script to download data to use for enchrichment.
# Data included are:
# - Tor exit nodes
# - Maxmind GeoLite2 ASN database

$enrichmentDirectory = "${PWD}\downloads\enrichment"

# Create the enrichment directory if it doesn't exist
if (-not (Test-Path -Path ${enrichmentDirectory})) {
    New-Item -ItemType Directory -Path ${enrichmentDirectory} -Force | Out-Null
}

# Download Tor exit nodes
$folderUrl = "https://collector.torproject.org/archive/exit-lists/"
$torsaveDirectory = "${enrichmentDirectory}\tor"

# Create the save directory for tor if it doesn't exist
if (-not (Test-Path -Path $torsaveDirectory)) {
    New-Item -ItemType Directory -Path $torsaveDirectory -Force | Out-Null
}

# Download all exit files
$webClient = New-Object System.Net.WebClient
$files = $webClient.DownloadString($folderUrl).Split("`n") | Select-String -Pattern '<a href="(exit[^"]+)"' | ForEach-Object { $_.Matches.Groups[1].Value }

foreach ($file in $files) {
    $fileUrl = $folderUrl + $file
    $savePath = Join-Path -Path "${PWD}${torsaveDirectory}" -ChildPath "${file}"
    Write-Output "Downloading $fileUrl to $savePath"
    #$webClient.DownloadFile("${fileUrl}", "${savePath}")
}

$webClient.Dispose()

if (-not (Test-Path -Path "${PWD}\config.ps1")) {
    Write-Output "Please create a config.ps1 to download Maxmind databases"
} else {
    . .\config.ps1
}

# Check if the Maxmind license key is set
if (-not $MAXMIND_LICENSE_KEY) {
    Write-Output "Please set the MAXMIND_LICENSE_KEY variable in config.ps1 if you want to download Maxmind databases"
} else {
    # Download Maxmind GeoLite2 ASN database
    $folderUrl = "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=${MAXMIND_LICENSE_KEY}&suffix=tar.gz"
    $savePath = Join-Path -Path "${enrichmentDirectory}" -ChildPath "GeoLite2-ASN.tar.gz"
    Write-Output "Downloading GeoLite2-ASN.tar.gz"
    Invoke-WebRequest -Uri $folderUrl -OutFile $savePath

    # Download Maxmind GeoLite2 City database
    $folderUrl = "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${MAXMIND_LICENSE_KEY}&suffix=tar.gz"
    $savePath = Join-Path -Path "${enrichmentDirectory}" -ChildPath "GeoLite2-City.tar.gz"
    Write-Output "Downloading GeoLite2-City.tar.gz"
    Invoke-WebRequest -Uri $folderUrl -OutFile $savePath

    # Download Maxmind GeoLite2 Country database
    $folderUrl = "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=${MAXMIND_LICENSE_KEY}&suffix=tar.gz"
    $savePath = Join-Path -Path "${enrichmentDirectory}" -ChildPath "GeoLite2-Country.tar.gz"
    Write-Output "Downloading GeoLite2-Country.tar.gz"
    Invoke-WebRequest -Uri $folderUrl -OutFile $savePath
}
