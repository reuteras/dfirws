# PolarProxy

**Category:** Network / Proxies

**Homepage:** <https://www.netresec.com/?page=PolarProxy>

**Vendor:** Netresec

**License:** free edition, CC BY-ND 4.0

**Source:** HTTP

**Profiles:** Full (not included in Basic profile)

**File Extensions:** `.pcap`, `.pcapng`

**Tags:** network-analysis, proxy

PolarProxy is a transparent TLS and SSL inspection proxy created for incident responders, malware analysts and security researchers.

## Tips
Transparent TLS proxy that writes decrypted traffic as PCAP for Wireshark and NetworkMiner. Install its root CA in the client you are inspecting and use the network enabled sandbox when the client needs internet.

## Usage
PolarProxy.exe -p 10443,80,443 -w C:\Users\WDAGUtilityAccount\Desktop\readwrite\decrypted.pcap

## Sample Files
- N/A
