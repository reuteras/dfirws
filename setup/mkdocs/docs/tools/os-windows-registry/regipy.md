# regipy

**Category:** OS / Windows / Registry

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.reg`, `.dat`

**Tags:** registry, windows, forensics

Regipy is a python library for parsing offline registry hives.

## Tips
Parses offline registry hives. regipy-plugins-run executes all plugins (run keys, services, user assist, shellbags and more), regipy-dump exports a hive, regipy-diff compares two hives, and --transaction-logs applies dirty LOG files first.

## Usage
regipy-plugins-run <hive> -o out.json
