# gron

**Category:** Files and apps / Log

**Homepage:** <https://github.com/tomnomnom/gron>

**Vendor:** tomnomnom

**License:** MIT

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.json`

**Tags:** json, data-processing, search

gron makes JSON greppable by transforming it into discrete assignments that can be easily searched and filtered using standard command-line tools.

## Tips
Turns JSON into greppable assignments. Pipe the matching lines back through 'gron --ungron' to rebuild JSON from the selection.

## Usage
gron file.json | rg <term>
