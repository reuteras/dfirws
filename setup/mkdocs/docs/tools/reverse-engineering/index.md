# Reverse Engineering

| Tool | Source | Description | Tags | File Extensions | Profiles |
| --- | --- | --- | --- | --- | --- |
| [Binary Ninja](binary-ninja.md) | HTTP | Binary Ninja is a reverse engineering platform. | reverse-engineering, disassembler, decompiler | `.exe`, `.dll`, `.elf`, `.bin`, `.so`, `.dylib` | Full only |
| [CapaExplorer](capaexplorer.md) | Git | Capa analysis importer for Ghidra. | reverse-engineering, malware-analysis, visualization, plugins |  |  |
| [Cutter](cutter.md) | GitHub Release | Cutter is a Qt and C++ GUI powered by Rizin that provides an intuitive interface for reverse engineering and analyzing binaries across multiple platforms. | reverse-engineering, disassembler, decompiler, gui | `.exe`, `.dll`, `.elf`, `.bin`, `.so`, `.dylib` | Full only |
| [FASM](fasm.md) | HTTP | FASM is a fast assembler for x86 and x86-64 architectures. | reverse-engineering | `.asm` |  |
| [Ghidra](ghidra.md) | Installer | Ghidra is a software reverse engineering (SRE) framework developed by NSA's Research Directorate. |  |  | Full only |
| [Ghidra BTIGhidra](ghidra-btighidra.md) | GitHub Release | Binary Type Inference Ghidra Plugin | reverse-engineering, disassembler, decompiler | `.exe`, `.dll`, `.elf`, `.bin`, `.so` |  |
| [Ghidra Cartographer](ghidra-cartographer.md) | GitHub Release | Code Coverage Exploration Plugin for Ghidra. | reverse-engineering, disassembler, visualization | `.exe`, `.dll`, `.elf`, `.bin`, `.so` |  |
| [Ghidra GhidrAssistMCP](ghidra-ghidrassistmcp.md) | GitHub Release | Ghidra extension implementing MCP server for AI-assisted reverse engineering. Enable in Ghidra via File > Configure > Configure Plugins. Server runs on localhost:8080 by default. | reverse-engineering, mcp, ai, plugins | `.exe`, `.dll`, `.elf`, `.bin`, `.so` |  |
| [Ghidra GolangAnalyzerExtension](ghidra-golanganalyzerextension.md) | GitHub Release | GoLang extension for Ghidra. | reverse-engineering, golang | `.exe`, `.elf` |  |
| [IDR](idr.md) | Git | Interactive Delphi Reconstructor | reverse-engineering, decompiler |  |  |
| [ILSpy](ilspy.md) | GitHub Release | ILSpy is a .NET assembly browser and decompiler. | dotnet, decompiler, reverse-engineering | `.exe`, `.dll` |  |
| [Iaito](iaito.md) | GitHub Release | iaito is the official graphical interface for radare2, a libre reverse engineering framework. | reverse-engineering, disassembler, gui | `.exe`, `.dll`, `.elf`, `.bin`, `.so` |  |
| [NetExt](netext.md) | GitHub Release | WinDbg extension for data mining managed heap. It also includes commands to list http request, wcf services, WIF tokens among others | debugging, memory-forensics, dotnet, plugins | `.dmp` |  |
| [Radare2](radare2.md) | GitHub Release | UNIX-like reverse engineering framework and command-line toolset | reverse-engineering, disassembler, debugging | `.exe`, `.dll`, `.elf`, `.bin`, `.so`, `.mach-o` |  |
| [WinDbg](windbg.md) | Winget | WinDbg is a powerful debugger from Microsoft that can be used for analyzing crash dumps, debugging applications, and performing memory forensics. It is commonly used in incident response and malware analysis to investigate system crashes and analyze the behavior of malicious software. | debugging, memory-forensics, windows | `.dmp`, `.exe`, `.dll`, `.sys` |  |
| [cutter-jupyter](cutter-jupyter.md) | Git | Jupyter Plugin for Cutter. | reverse-engineering |  |  |
| [cutterref](cutterref.md) | Git | Cutter Instruction Reference Plugin | reverse-engineering, documentation, plugins |  |  |
| [decai](decai.md) | Git | r2js plugin for radare2 with special focus on AI-assisted decompilation. Installed by copying decai.r2.js to the radare2 plugins directory. | reverse-engineering, ai, decompiler | `.exe`, `.dll`, `.elf`, `.bin`, `.so` |  |
| [dnSpy](dnspy.md) | GitHub Release | dnSpy is a .NET debugger and decompiler. It can be used to analyze and debug .NET applications, including malware. | dotnet, debugging, reverse-engineering |  |  |
| [frida-tools](frida-tools.md) | Python | Frida CLI tools. | reverse-engineering, dynamic-analysis | `.exe`, `.apk`, `.ipa` |  |
| [ghidrecomp](ghidrecomp.md) | Python | Python Command-Line Ghidra Decomplier. | reverse-engineering, decompiler | `.exe`, `.dll`, `.elf` |  |
| [ghidriff](ghidriff.md) | Python | Ghidra Binary Diffing Engine. | reverse-engineering, binary-diffing | `.exe`, `.dll`, `.elf` |  |
| [keystone-engine](keystone-engine.md) | Python |  | reverse-engineering |  |  |
| [pyghidra](pyghidra.md) | Python | The PyGhidra Python library, originally developed by the Department of Defense Cyber Crime Center (DC3) under the name "Pyhidra", is a Python library that provides direct access to the Ghidra API within a native CPython 3 interpreter using JPype. PyGhidra contains some conveniences for setting up analysis on a given sample and running a Ghidra script locally. It also contains a Ghidra plugin to allow the use of CPython 3 from the Ghidra GUI. | reverse-engineering, decompiler, scripting | `.exe`, `.dll`, `.elf` |  |
| [r2ai](r2ai.md) | Git | Native AI plugin for radare2. Compiled from source in the MSYS2 sandbox using gcc and pkg-config. Provides AI-assisted analysis using local and remote language models. | reverse-engineering, ai | `.exe`, `.dll`, `.elf`, `.bin`, `.so` |  |
| [r2ai](r2ai-2.md) | GitHub Release | LLM-based reversing for radare2. | reverse-engineering, mcp, ai | `.exe`, `.dll`, `.elf`, `.bin`, `.so` |  |
| [radare2-deep-graph](radare2-deep-graph.md) | Git | A Cutter plugin to generate radare2 graphs. | reverse-engineering, visualization, plugins |  |  |
| [radare2-mcp](radare2-mcp.md) | GitHub Release | MCP stdio server for radare2. Enables AI assistants to interact with radare2 for binary analysis. Known issue: Windows binary may crash with stack overflow (GitHub issue #24). | reverse-engineering, mcp, ai | `.exe`, `.dll`, `.elf`, `.bin`, `.so` |  |
| [rzpipe](rzpipe.md) | Python |  | reverse-engineering, scripting | `.exe`, `.dll`, `.elf`, `.bin` |  |
| [scare](scare.md) | Git | A multi-arch assembly REPL and emulator for your command line. | reverse-engineering, emulation, scripting |  |  |
| [unicorn](unicorn.md) | Python |  | reverse-engineering, emulation |  |  |
| [x64dbg](x64dbg.md) | GitHub Release | An open-source user mode debugger for Windows. Optimized for reverse engineering and malware analysis. | reverse-engineering, debugging, dynamic-analysis | `.exe`, `.dll` |  |