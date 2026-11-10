# SSHniff

**Category:** Network

**Source:** Cargo

**Profiles:** Full, Basic

**File Extensions:** `.pcap`, `.pcapng`

**Tags:** network-analysis, network, pcap

SSHniff is a command-line tool for capturing and analyzing SSH network traffic. It can be used to monitor and inspect SSH sessions, helping in forensic analysis of network communications.

## Tips
Fingerprints SSH sessions in a PCAP and infers keystrokes, commands, sudo prompts and file transfers from packet sizes and timing. Works best on captures containing a single interactive session.

## Usage
sshniff -f capture.pcap
