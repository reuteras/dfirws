---
name: sandbox-tools
description: Use this skill when working in the DFIRWS Windows Sandbox to analyze artifacts with built-in tools, especially when the task mentions C:\\Tools, C:\\venv, C:\\git, Desktop\\readwrite, Desktop\\readonly, or DFIR triage workflows. It provides deterministic workflows for selecting tools, running quick triage, and reporting repeatable commands.
---

# Sandbox Tools Skill

## When to use
Use this skill when the user asks to:
- analyze files inside the DFIRWS sandbox,
- choose the right built-in forensic tools,
- run quick triage on logs, registry hives, browser artifacts, or executables,
- convert ad-hoc commands into repeatable investigation steps.

If the request is about environment-specific command syntax or tool locations, first read `references/dfirws-paths-and-tools.md`.

## Workflow
1. **Confirm scope**
   - Identify artifact type (event log, registry hive, binary, PCAP, archive, memory image, timeline source).
   - Confirm where artifacts are expected (`Desktop\\readonly` for input artifacts, `Desktop\\readwrite` for analysis output).

2. **Pick the least-friction toolchain**
   - Prefer tools that are already bundled in `C:\\Tools`.
   - If a Python package tool is needed, use launchers from `C:\\venv`.
   - If source-based helper scripts are needed, check `C:\\git`.

3. **Run a quick triage pass before deep analysis**
   - Hash and identify file type.
   - Extract high-signal metadata (timestamps, signer/imports for binaries, key fields for logs).
   - Save outputs into a case subfolder under `Desktop\\readwrite`.

4. **Escalate only when needed**
   - Start with broad, low-cost checks.
   - Move to heavier tooling (decompilers, disassemblers, yara-at-scale, timeline fusion) only after triage identifies leads.

5. **Return reproducible output**
   - Provide exact commands.
   - Explain why each tool was chosen.
   - Include assumptions and next-step branches.

## Output template
Use this structure in responses:

- **Objective**: What question the analysis answers.
- **Tool choices**: Why these tools were selected.
- **Commands**: Copy/paste-ready commands.
- **Findings**: Concise, evidence-first observations.
- **Next checks**: 2-4 concrete follow-ups.

## Guardrails
- Prefer offline-capable workflows; do not assume internet access in the final analysis sandbox.
- Never invent tool output; clearly mark estimated or pending results.
- Keep pathing Windows-native unless the user explicitly asks for PowerShell-to-Bash translation.
- Treat `Desktop\\readonly` as evidence input and keep all derived files in `Desktop\\readwrite`.
- If a command may alter evidence, provide a read-only alternative first.
