# pyshark

**Category:** Network

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.pcap`, `.pcapng`

**Tags:** network-analysis, pcap, protocol-analysis

import pyshark; cap = pyshark.FileCapture('file.pcap')

## Tips
Wireshark dissectors from Python. Requires tshark, so install Wireshark on demand first.

## Usage
import pyshark; cap = pyshark.FileCapture('file.pcap')
