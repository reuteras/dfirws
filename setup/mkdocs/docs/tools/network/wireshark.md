# Wireshark

**Category:** Network

**Homepage:** <https://www.wireshark.org/>

**Vendor:** The Wireshark developer community, https://www.wireshark.org

**License:** [GPL-2.0](https://gitlab.com/wireshark/wireshark/-/blob/HEAD/COPYING)

**Source:** Winget

**Profiles:** Full, Basic

**File Extensions:** `.pcap`, `.pcapng`, `.cap`

**Tags:** network-analysis, pcap, protocol-analysis

Wireshark is a widely used network protocol analyzer that allows you to capture and analyze network traffic. It can be used for troubleshooting network issues, analyzing security incidents, and learning about network protocols. Wireshark provides a graphical interface for viewing and filtering captured packets, making it easier to analyze complex network traffic.

## Tips
Install on demand. tshark is added to PATH too so you can script extraction (tshark -r file.pcap -Y http -T fields -e http.host). Add the PacketCircle plugin for a traffic matrix view.

## Usage
dfirws-install.ps1 -Wireshark
