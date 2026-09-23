# srum_dump

**Category:** OS / Windows

**Homepage:** <https://github.com/MarkBaggett/srum-dump>

**Vendor:** MarkBaggett

**License:** GPL-3.0

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.dat`

**Tags:** windows, forensics, filesystem

A forensics tool to convert the data in the Windows srum (System Resource Usage Monitor) database to an xlsx spreadsheet.

## Tips
Converts SRUM to Excel with per application network usage, energy and push notification data. Provide the SOFTWARE hive to resolve names and use the dirty file option for an unclean ESE database.

## Usage
srum_dump.exe -i SRUDB.dat -o srum.xlsx -r <SOFTWARE hive>
