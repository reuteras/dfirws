---
name: sandbox-tools
description: Use this skill when working in the DFIRWS Windows Sandbox to analyze artifacts with built-in tools, especially when the task mentions C:\Tools, C:\venv, C:\git, Desktop\readwrite, Desktop\readonly, or DFIR triage workflows. It provides deterministic workflows for selecting tools, running quick triage, and reporting repeatable commands.
---

# Sandbox Tools Skill

## When to use

Use this skill when the user asks to:

- analyze files inside the DFIRWS sandbox,
- choose the right built-in forensic tools,
- run quick triage on logs, registry hives, browser artifacts, executables, memory images, PCAPs, Office documents, PDFs, email, or archives,
- convert ad-hoc commands into repeatable investigation steps,
- use MCP servers for interactive analysis (Ghidra, radare2, regipy),
- query enrichment data (YARA rules, GeoIP, IOC databases, Sigma rules).

Before answering, read the relevant reference files:

- **Tool paths and selection**: `references/dfirws-paths-and-tools.md`
- **MCP servers**: `references/mcp-servers.md`
- **Common investigation workflows**: `references/common-workflows.md`
- **Enrichment and threat intel data**: `references/enrichment-data.md`
- **Python tool invocation**: `references/python-tools.md`

## Workflow

1. **Confirm scope**
   - Identify artifact type (event log, registry hive, binary, PCAP, archive, memory image, timeline source, Office document, PDF, email, disk image, phone extraction, browser data).
   - Confirm where artifacts are expected (`Desktop\readonly` for input artifacts, `Desktop\readwrite` for analysis output).
   - Ask the user to clarify if the artifact type is ambiguous.

2. **Check for MCP server availability**
   - If the task involves registry analysis, check whether the regipy MCP server is enabled.
   - If the task involves reverse engineering, check whether Ghidra or radare2 MCP servers are enabled.
   - MCP servers allow interactive, iterative analysis. Prefer them when enabled and the task benefits from back-and-forth exploration.
   - If an MCP server is not enabled, fall back to CLI tools for the same artifact type.

3. **Pick the least-friction toolchain**
   - Prefer tools that are already bundled in `C:\Tools` (native binaries, fastest).
   - If a Python-based tool is needed, use launchers from `C:\venv` (see `references/python-tools.md`).
   - If source-based helper scripts are needed, check `C:\git`.
   - If enrichment data is needed (YARA rules, GeoIP, Sigma rules), check `C:\enrichment` (see `references/enrichment-data.md`).
   - When multiple tools can do the job, prefer the one with structured output (JSON/CSV) over plain text, as it enables further processing.

4. **Run a quick triage pass before deep analysis**
   - Hash and identify file type.
   - Extract high-signal metadata (timestamps, signer/imports for binaries, key fields for logs).
   - Save outputs into a case subfolder under `Desktop\readwrite`.

5. **Escalate only when needed**
   - Start with broad, low-cost checks.
   - Move to heavier tooling (decompilers, disassemblers, yara-at-scale, timeline fusion, memory forensics) only after triage identifies leads.

6. **Cross-reference with enrichment data when appropriate**
   - Match hashes or IOCs against available threat intel.
   - Run YARA rules against suspicious files.
   - Enrich IP addresses with GeoIP data.

7. **Return reproducible output**
   - Provide exact commands with full paths.
   - Explain why each tool was chosen.
   - Include assumptions and next-step branches.

## Output template

Use this structure in responses:

- **Objective**: What question the analysis answers.
- **Tool choices**: Why these tools were selected (with full paths).
- **Commands**: Copy/paste-ready commands with absolute paths.
- **Findings**: Concise, evidence-first observations.
- **Next checks**: 2-4 concrete follow-ups.

## Guardrails

- Prefer offline-capable workflows; do not assume internet access in the final analysis sandbox.
- Never invent tool output; clearly mark estimated or pending results.
- Keep pathing Windows-native unless the user explicitly asks for PowerShell-to-Bash translation.
- Always use absolute paths in commands (e.g., `C:\Tools\hayabusa\hayabusa.exe`, not just `hayabusa`).
- Treat `Desktop\readonly` as evidence input and keep all derived files in `Desktop\readwrite`.
- If a command may alter evidence, provide a read-only alternative first.
- If a tool is missing or a command fails, suggest an alternative tool that provides similar functionality rather than stopping. Multiple tools exist for most artifact types.
- When writing output files, use descriptive names that include the artifact name and analysis type (e.g., `evtx_security_hayabusa_results.csv`).
- Prefer structured output formats (JSON, CSV) when the tool supports them, to enable downstream processing.
