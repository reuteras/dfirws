# Microsoft.etl2pcapng

**Category:** Network

**Homepage:** <https://github.com/microsoft/etl2pcapng>

**Vendor:** Microsoft

**License:** MIT

**Source:** Winget

**Profiles:** Full, Basic

**File Extensions:** `.etl`

**Tags:** network-analysis, pcap, protocol-analysis

Microsoft.etl2pcapng is a tool for converting ETL (Event Trace Log) files to PCAPNG format, allowing you to analyze network traffic captured in ETL files using tools like Wireshark.

## Tips
Converts Windows network traces captured with 'netsh trace' or pktmon to PCAPNG for Wireshark and NetworkMiner. Only the packet capture provider events are converted.

## Usage
etl2pcapng trace.etl trace.pcapng
