if (-not (Test-Path -Path "C:\enrichment\maxmind_current\GeoLite2-City.mmdb")) {
    Write-Output "You must have the MaxMind GeoLite2-City.mmdb file in C:\enrichment\maxmind_current."
    Write-Output "Use .\enrichment.ps1 to download the files after adding your license key to config.ps1."
    return
}

$input | C:\venv\dissect\Scripts\rgeoip.exe -c "C:\enrichment\maxmind_current\GeoLite2-City.mmdb" -a "C:\enrichment\maxmind_current\GeoLite2-ASN.mmdb" $args