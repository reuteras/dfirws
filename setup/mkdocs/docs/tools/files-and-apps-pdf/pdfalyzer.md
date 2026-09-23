# pdfalyzer

**Category:** Files and apps / PDF

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.pdf`

**Tags:** pdf, malware-analysis, visualization

Analyze PDFs with colors (and YARA). Visualize a PDF's inner tree-like data structure, check it against a library of YARA rules, force decodes of suspicious font binaries, and more.

## Tips
Visualises the PDF object tree, runs YARA rules and decodes suspicious streams and fonts. Use --streams to dump stream contents and --extract-binary for embedded data.

## Usage
pdfalyze <file.pdf>
