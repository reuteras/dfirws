# oletools

**Category:** Files and apps

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.doc`, `.docx`, `.xls`, `.xlsx`, `.ppt`, `.pptx`, `.rtf`

**Tags:** office, malware-analysis, vba

Python tools to analyze security characteristics of MS Office and OLE files (also called Structured Storage, Compound File Binary Format or Compound Document File Format), for Malware Analysis and Incident Response #DFIR.

## Tips
oleid triages, olevba extracts and deobfuscates VBA (--deobf for obfuscated macros), mraptor flags auto exec macros, msodde finds DDE links, rtfobj extracts objects from RTF and oleobj extracts embedded objects.

## Usage
olevba <file> ; oleid <file> ; mraptor <file>
