# DFIRWS Paths and Tool Selection Reference

Use this file only when command/path specificity matters.

## Core paths
- `C:\\Tools\\` - pre-extracted forensic and reverse engineering binaries.
- `C:\\venv\\` - Python virtual environments and script launchers.
- `C:\\git\\` - cloned repositories used by some toolchains.
- `Desktop\\readonly\\` - read-only evidence/input directory.
- `Desktop\\readwrite\\` - writable analyst workspace (default for case output).

## Tool selection by artifact type

### Event logs (`.evtx`)
- Fast summary: chainsaw / hayabusa style event triage tools if available in `C:\\Tools`.
- Field extraction and custom filtering: Python-based parsers from `C:\\venv`.

### Registry hives (`NTUSER.DAT`, `SYSTEM`, `SOFTWARE`, etc.)
- Use RegRipper/Registry Explorer family tools for broad extraction.
- Use `regipy` workflows for scripted extraction and repeatable parsing.

### Executables / DLLs
- Initial triage: hash, file type, strings, entropy, signer metadata.
- Deep static RE: Ghidra/radare2 workflows from `C:\\Tools`.

### Browser artifacts / SQLite
- Use dedicated browser parsers first.
- Fall back to SQLite CLI/DB Browser plus timeline scripting if parser coverage is incomplete.

### Archives and unknown containers
- Use 7-Zip and signature tools first.
- If nested payloads exist, recurse extraction into separate case subfolders.

## Reproducibility pattern
For each task, return:
1. Input path assumptions.
2. Command block(s).
3. Output location.
4. Validation command for sanity-checking generated output.

## Safety notes
- Prefer command options that avoid modifying source artifacts.
- Treat `Desktop\\readonly` as source evidence and avoid writing back to it.
- Write derived artifacts (CSV/JSON/reports) under `Desktop\\readwrite\\cases\\<case-id>\\`.
- If a tool requires write access to source paths, copy source to a working folder first and preserve original hashes.
