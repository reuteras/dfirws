# mkyara

**Category:** Signatures and information

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.exe`, `.dll`, `.bin`

**Tags:** yara, detection-rules, malware-analysis

mkyara -i <file> -s <start offset> -e <end offset>

## Tips
Generates YARA rules from a code region by masking operands. Use it to write a signature for a unique function in a sample.

## Usage
mkyara -i <file> -s <start offset> -e <end offset>
