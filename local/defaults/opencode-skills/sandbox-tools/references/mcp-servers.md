# MCP Server Integration Reference

The DFIRWS sandbox can optionally enable MCP (Model Context Protocol) servers that allow interactive, iterative analysis through the AI assistant. All servers are **disabled by default** for security. Configuration is at `~/.config/opencode/opencode.json`.

## Available MCP servers

### GhidrAssist (Ghidra reverse engineering)

- **Type**: Remote (SSE)
- **URL**: `http://localhost:8080/sse`
- **Prerequisite**: Ghidra must be running with the GhidrAssist plugin enabled
- **Use when**: Deep reverse engineering tasks requiring decompilation, function analysis, cross-references, or data type recovery
- **Capabilities**: Decompile functions, query symbol tables, navigate call graphs, analyze data structures

**When to use MCP vs. CLI**: Use the MCP server when the task requires iterative exploration (e.g., "what does this function do?" followed by "trace its callers"). Use CLI radare2 for one-shot disassembly or scripted batch analysis.

### radare2 (binary analysis)

- **Type**: Local (stdio)
- **Command**: `r2mcp`
- **Known issue**: May crash on Windows (see project issue #24)
- **Use when**: Interactive binary analysis, disassembly, string analysis, or format parsing
- **Capabilities**: Disassemble, analyze functions, extract strings, search patterns, debug

**Fallback if unavailable**: Use `C:\Tools\radare2\bin\radare2.exe` directly via CLI commands:

```pwsh
C:\Tools\radare2\bin\radare2.exe -q -c "aaa; afl" Desktop\readonly\suspect.exe
C:\Tools\radare2\bin\radare2.exe -q -c "iz" Desktop\readonly\suspect.exe
```

### regipy (registry analysis)

- **Type**: Local (stdio)
- **Command**: `C:\venv\uv\regipy\Scripts\python.exe C:\git\regipy\regipy_mcp_server\server.py --hives-dir C:\cases`
- **Use when**: Interactive registry hive analysis requiring exploration of keys, values, and timestamps
- **Capabilities**: Parse registry hives, enumerate keys, extract values, search for patterns, timeline registry changes

**Fallback if unavailable**: Use the regipy CLI or RegRipper:

```pwsh
C:\venv\bin\registry-dump.exe Desktop\readonly\NTUSER.DAT
C:\git\RegRipper4.0\rip.exe -r Desktop\readonly\NTUSER.DAT -a
```

## Related radare2 plugins (non-MCP)

These are loaded directly by radare2, not as MCP servers:

- **decai** - AI-assisted decompilation plugin (JavaScript, loaded by radare2 directly)
- **r2ai** - Native C plugin for AI-assisted analysis (`r2ai.dll` in radare2 plugins dir, `r2ai.exe` in `C:\Tools\radare2\bin\`)

## Checking MCP server status

To determine if an MCP server is enabled, check the opencode configuration:
- Default config: `C:\local\opencode.json` (all disabled by default)
- User override: `~/.config/opencode/opencode.json`

If a user asks to use an MCP-enabled workflow and the server is not enabled, explain that it needs to be enabled in the configuration and offer the CLI fallback instead.

## When to recommend MCP vs. CLI

| Scenario | Recommendation |
| -------- | -------------- |
| One-shot extraction (e.g., "dump all registry keys") | Command-line tool |
| Iterative exploration (e.g., "find suspicious keys, then dig deeper") | MCP if enabled |
| Batch processing multiple files | Command-line tool |
| Interactive debugging session | MCP if enabled |
| Scripted/reproducible workflow | Command-line tool (easier to copypaste commands) |
