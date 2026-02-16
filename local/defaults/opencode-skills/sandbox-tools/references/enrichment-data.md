# Enrichment Data Reference

The DFIRWS sandbox includes pre-downloaded threat intelligence and enrichment data at `C:\enrichment\`. This data is read-only and available offline.

## Available enrichment data

### YARA rules (`C:\enrichment\yara\`)

Pre-compiled YARA rule sets from YARA Forge:

| File | Description | Use case |
|------|-------------|----------|
| `yara-forge-rules-core.yar` | High-confidence rules, low false positives | Default choice for file scanning |
| `yara-forge-rules-extended.yar` | Broader coverage, some false positives | Wider sweep when core has no matches |
| `yara-forge-rules-full.yar` | All available rules | Maximum coverage, expect noise |

**Usage:**
```
C:\Tools\yara\yara64.exe -r C:\enrichment\yara\yara-forge-rules-core.yar Desktop\readonly\suspect.exe
C:\Tools\yara\yara64.exe -r C:\enrichment\yara\yara-forge-rules-core.yar -r Desktop\readonly\samples\
C:\Tools\yara-x\yr.exe scan C:\enrichment\yara\yara-forge-rules-core.yar Desktop\readonly\suspect.exe
```

**Choosing a rule set**: Start with `core` for targeted scanning. Escalate to `extended` or `full` only if core produces no matches and suspicion remains.

### GeoIP databases

#### MaxMind GeoLite2 (`C:\enrichment\maxmind_current\`)

| File | Description |
|------|-------------|
| `GeoLite2-ASN.mmdb` | IP to ASN (organization) lookup |
| `GeoLite2-City.mmdb` | IP to city-level geolocation |
| `GeoLite2-Country.mmdb` | IP to country lookup |

Also copied to `C:\Program Files\iisGeolocate\` for the iisGeolocate tool.

**Usage with Python:**
```python
import geoip2.database
reader = geoip2.database.Reader(r"C:\enrichment\maxmind_current\GeoLite2-City.mmdb")
response = reader.city("8.8.8.8")
print(response.country.name, response.city.name)
```

#### IPinfo (`C:\enrichment\ipinfo\`)

| File | Description |
|------|-------------|
| `country.mmdb` | IP to country mapping |
| `asn.mmdb` | IP to ASN mapping |

#### Geolocus (`C:\enrichment\geolocus\`)

MMDB files also cached at `%USERPROFILE%\.cache\geolocus-cli\geolocus.mmdb`.

### IDS/IPS rules

| Source | Path | Format |
|--------|------|--------|
| Snort 3 community rules | `C:\enrichment\snort\` | `.tar.gz` (extract before use) |
| Suricata rules | `C:\enrichment\suricata\` | `.zip` (extract before use) |

**Note**: These rules are in compressed format. Extract them to `Desktop\readwrite\` before use:
```
"C:\Program Files\7-Zip\7z.exe" x C:\enrichment\snort\*.tar.gz -oDesktop\readwrite\snort_rules
"C:\Program Files\7-Zip\7z.exe" x C:\enrichment\suricata\*.zip -oDesktop\readwrite\suricata_rules
```

### Threat intelligence feeds (`C:\enrichment\git\`)

| Repository | Path | Content |
|------------|------|---------|
| SSC-Threat-Intel-IoCs | `C:\enrichment\git\SSC-Threat-Intel-IoCs\` | IOC lists |
| Volexity threat-intel | `C:\enrichment\git\threat-intel\` | IOCs from Volexity research |

### IP reputation lists (`C:\enrichment\git\`)

| List | Path | Description |
|------|------|-------------|
| VPN providers | `C:\enrichment\git\lists_vpn\` | Known VPN exit IPs |
| Tor exit nodes | `C:\enrichment\git\lists_torexit\` | Tor exit node IPs |
| StopForumSpam | `C:\enrichment\git\lists_stopforumspam\` | Known spam IPs |
| Search engines | `C:\enrichment\git\lists_searchengine\` | Search engine crawler IPs |
| Bots | `C:\enrichment\git\lists_bots\` | Known bot IPs |
| UptimeRobot | `C:\enrichment\git\lists_uptimerobot\` | Monitoring service IPs |
| Cloudflare | `C:\enrichment\git\lists_cloudflare\` | Cloudflare edge IPs |
| Route53 | `C:\enrichment\git\lists_route53\` | AWS Route53 IPs |

### Tor exit nodes (`C:\enrichment\tor\`)

Downloaded from Tor Project collector. Use to check if an IP was a Tor exit at a given time.

### CVE data (`C:\enrichment\cve\`)

CVE Project JSON data for vulnerability lookup.

### MAC address lookup (`C:\enrichment\manuf\`)

Wireshark manufacturer database for MAC address vendor identification.

## Sigma detection rules (`C:\git\`)

| Repository | Path | Description |
|------------|------|-------------|
| Sigma rules | `C:\git\sigma\` | Official Sigma detection rules |
| Legacy sigmatools | `C:\git\legacy-sigmatools\` | Older Sigma tooling |
| Chainsaw rules | `C:\git\chainsaw-rules\` | Rules packaged for Chainsaw |
| Hayabusa rules | `C:\git\hayabusa-rules\` | Rules packaged for Hayabusa |
| God Mode rules | `C:\git\god-mode-rules\` | Community detection rules |

**Usage with tools:**
```
C:\Tools\hayabusa\hayabusa.exe csv-timeline -d Desktop\readonly\evtx -r C:\git\hayabusa-rules
C:\Tools\chainsaw\chainsaw.exe hunt Desktop\readonly\evtx -s C:\git\sigma\rules
```

## YARA signature repositories (`C:\git\`)

| Repository | Path | Description |
|------------|------|-------------|
| signature-base | `C:\git\signature-base\` | Neo23x0 YARA/IOC signature database |
| capa rules | `C:\git\capa-rules\` | Mandiant capa detection rules |

**Usage:**
```
C:\Tools\yara\yara64.exe -r C:\git\signature-base\yara\*.yar Desktop\readonly\suspect.exe
C:\Tools\capa\capa.exe -r C:\git\capa-rules Desktop\readonly\suspect.exe
```

## Enrichment workflow pattern

1. **Identify what to enrich**: Extract IOCs (IPs, hashes, domains) from the artifact.
2. **Choose the right data source**: Match the IOC type to the enrichment database.
3. **Run the enrichment**: Use the appropriate tool/database.
4. **Document the result**: Save enrichment output alongside the analysis.

| IOC type | Enrichment source | Tool |
|----------|-------------------|------|
| IP address | MaxMind GeoIP, IP lists | Python geoip2, grep against lists |
| File hash | YARA rules, signature-base | yara64.exe, Loki |
| Domain/URL | Threat intel feeds | grep against IOC lists |
| MAC address | Wireshark manuf | Wireshark OUI lookup |
| CVE ID | CVE data | grep CVE JSON files |
