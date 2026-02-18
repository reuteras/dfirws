# Events-Ripper

**Category:** Uncategorized

**Source:** Git

**Tags:** event-log, forensics, windows

This project is based on RegRipper, to easily extract additional value/pivot points from a TLN events file.

## Usage
Events-Ripper is based on the 5-field, pipe-delimited TLN "intermediate" events file format. This file is intermediate, as it the culmination or collection of normalized events from different data sources (i.e., Registry, WEVTX, MFT, etc.) that are then parsed into a deduped timeline.

The current iteration of Events-Ripper includes plugins that are written specifically for Windows Event Log (*.evtx) events.

This tool is intended to address a very specific problem set, one that leverages a limited data set to develop as much insight and situational awareness as possible from that data set.


