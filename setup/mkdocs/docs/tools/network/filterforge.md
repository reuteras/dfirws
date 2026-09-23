# filterforge

**Category:** Network

**Homepage:** <https://github.com/cloudflare/filterforge>

**Vendor:** Cloudflare

**License:** [Apache License 2.0](https://github.com/cloudflare/filterforge/blob/main/LICENSE)

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.pcap`, `.pcapng`

**Tags:** network-analysis, network, pcap

filterforge from Cloudflare solves BPF filters with the z3 SMT solver and crafts packets that match (or do not match) a given filter expression.

## Tips
The command is ff. Useful for validating capture and firewall filters and generating test packets for them. Requires Python 3.13 and is skipped when python3.13 is excluded by the profile.

## Usage
ff --help

## Sample Commands
- `ff --help`
