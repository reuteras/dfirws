# Common Investigation Workflows

Step-by-step workflows for common DFIR tasks. Each workflow follows the triage-first approach: start broad, escalate when findings warrant it.

## Workflow 1: Windows event log analysis

**Goal**: Identify suspicious activity in collected event logs.

### Step 1: Quick SIGMA scan with Hayabusa

```pwsh
mkdir Desktop\readwrite\case_evtx
C:\Tools\hayabusa\hayabusa.exe csv-timeline -d Desktop\readonly\evtx -o Desktop\readwrite\case_evtx\hayabusa_timeline.csv -p super-verbose
```

Review the CSV in TimelineExplorer or with dsq:

```pwsh
C:\Tools\bin\dsq.exe Desktop\readwrite\case_evtx\hayabusa_timeline.csv "SELECT * WHERE Level IN ('critical','high') ORDER BY Timestamp"
```

### Step 2: Targeted hunt with Chainsaw

```pwsh
C:\Tools\chainsaw\chainsaw.exe hunt Desktop\readonly\evtx -s C:\Tools\chainsaw\sigma\ --mapping C:\Tools\chainsaw\mappings\sigma-event-logs-all.yml -o Desktop\readwrite\case_evtx\chainsaw_results.csv --csv
```

### Step 3: Detailed parsing of specific logs

```pwsh
C:\Tools\Zimmerman\net6\EvtxeCmd\EvtxECmd.exe -f Desktop\readonly\evtx\Security.evtx --csv Desktop\readwrite\case_evtx\security_parsed
```

### Step 4: Post-process Hayabusa output (optional)

```pwsh
C:\Tools\takajo\takajo.exe -t Desktop\readwrite\case_evtx\hayabusa_timeline.csv
```

## Workflow 2: Suspicious executable triage

**Goal**: Determine whether a binary is malicious and understand its capabilities.

### Step 1: File identification

```pwsh
C:\Tools\trid\trid.exe Desktop\readonly\suspect.exe
C:\Tools\die\diec.exe Desktop\readonly\suspect.exe
certutil -hashfile Desktop\readonly\suspect.exe SHA256
```

### Step 2: Static analysis - strings and capabilities

```pwsh
C:\Tools\floss\floss.exe Desktop\readonly\suspect.exe -j > Desktop\readwrite\floss_output.json
C:\Tools\capa\capa.exe Desktop\readonly\suspect.exe -j > Desktop\readwrite\capa_output.json
C:\Tools\sysinternals\sigcheck.exe -accepteula -a -h Desktop\readonly\suspect.exe
```

### Step 3: YARA scanning

```pwsh
C:\Tools\yara\yara64.exe -r C:\enrichment\yara\yara-forge-rules-core.yar Desktop\readonly\suspect.exe
C:\Tools\yara\yara64.exe -r C:\git\signature-base\yara\*.yar Desktop\readonly\suspect.exe
```

### Step 4: AV scanning

To use clamscan the first command to run is.

```pwsh
dfirws-install.ps1 -ClamAV
```

```pwsh
"C:\Program Files\ClamAV\clamscan.exe" Desktop\readonly\suspect.exe
```

### Step 5: Escalate to deep RE (only if prior steps indicate it's needed)

- GUI: Open in Ghidra, Cutter, or pestudio
- CLI: `C:\Tools\radare2\bin\radare2.exe -A Desktop\readonly\suspect.exe`

## Workflow 3: Suspicious Office document triage

**Goal**: Determine whether a document contains malicious macros or exploits.

### Step 1: Identify document type and properties

```pwsh
C:\venv\bin\oleid.exe Desktop\readonly\document.docx
python C:\Tools\DidierStevens\oledump.py Desktop\readonly\document.docx
```

### Step 2: Check for macros

```pwsh
C:\venv\bin\olevba.exe Desktop\readonly\document.docx
C:\venv\bin\mraptor.exe Desktop\readonly\document.docx
```

### Step 3: If VBA macros found, decompile P-code

```pwsh
C:\venv\bin\pcode2code.exe Desktop\readonly\document.docx
```

### Step 4: If Excel 4.0 macros suspected

```pwsh
C:\venv\bin\xlmdeobfuscator.exe -f Desktop\readonly\document.xlsm
```

### Step 5: If password-protected

```pwsh
C:\venv\bin\msoffcrypto-tool.exe Desktop\readonly\document.docx Desktop\readwrite\decrypted.docx -p <password>
```

## Workflow 4: Suspicious PDF analysis

**Goal**: Check a PDF for embedded scripts, launch actions, or exploits.

### Step 1: Structure identification

```pwsh
python C:\Tools\DidierStevens\pdfid.py Desktop\readonly\suspect.pdf
```

Look for: `/JavaScript`, `/OpenAction`, `/Launch`, `/EmbeddedFile`, `/AcroForm`.

### Step 2: Extract suspicious objects

```pwsh
python C:\Tools\DidierStevens\pdf-parser.py --stats Desktop\readonly\suspect.pdf
python C:\Tools\DidierStevens\pdf-parser.py --object <id> --filter --dump Desktop\readonly\suspect.pdf
```

### Step 3: If JavaScript found, extract and analyze

```pwsh
python C:\Tools\DidierStevens\pdf-parser.py --object <id> --filter --raw Desktop\readonly\suspect.pdf > Desktop\readwrite\pdf_js_extracted.js
```

## Workflow 5: Registry hive analysis

**Goal**: Extract forensic artifacts from Windows registry hives.

### Step 1: Broad extraction with RegRipper

```pwsh
C:\git\RegRipper4.0\rip.exe -r Desktop\readonly\SYSTEM -a > Desktop\readwrite\system_rip.txt
C:\git\RegRipper4.0\rip.exe -r Desktop\readonly\SOFTWARE -a > Desktop\readwrite\software_rip.txt
C:\git\RegRipper4.0\rip.exe -r Desktop\readonly\NTUSER.DAT -a > Desktop\readwrite\ntuser_rip.txt
```

### Step 2: Targeted artifact extraction

```pwsh
C:\Tools\Zimmerman\net6\AmcacheParser.exe -f Desktop\readonly\Amcache.hve --csv Desktop\readwrite\amcache_output
C:\Tools\Zimmerman\net6\AppCompatCacheParser.exe -f Desktop\readonly\SYSTEM --csv Desktop\readwrite\shimcache_output
C:\Tools\Zimmerman\net6\SBECmd.exe -d Desktop\readonly\UsrClass.dat --csv Desktop\readwrite\shellbags_output
```

### Step 3: Interactive exploration (if regipy MCP is enabled)

Use the regipy MCP server to explore specific keys interactively.

### Step 4: Fallback to GUI

Open hives in RegistryExplorer: `"C:\Program Files\RegistryExplorer\RegistryExplorer.exe"`

## Workflow 6: Memory image analysis

**Goal**: Extract forensic artifacts from a memory dump.

### Step 1: Identify the image

```pwsh
C:\venv\default\Scripts\vol.exe -f Desktop\readonly\memory.raw windows.info
```

### Step 2: Process listing and network connections

```pwsh
C:\venv\default\Scripts\vol.exe -f Desktop\readonly\memory.raw windows.pslist > Desktop\readwrite\mem_pslist.txt
C:\venv\default\Scripts\vol.exe -f Desktop\readonly\memory.raw windows.pstree > Desktop\readwrite\mem_pstree.txt
C:\venv\default\Scripts\vol.exe -f Desktop\readonly\memory.raw windows.netscan > Desktop\readwrite\mem_netscan.txt
```

### Step 3: Check for injected code and suspicious handles

```pwsh
C:\venv\default\Scripts\vol.exe -f Desktop\readonly\memory.raw windows.malfind > Desktop\readwrite\mem_malfind.txt
C:\venv\default\Scripts\vol.exe -f Desktop\readonly\memory.raw windows.handles > Desktop\readwrite\mem_handles.txt
```

### Step 4: Extract specific process or DLL for further analysis

```pwsh
C:\venv\default\Scripts\vol.exe -f Desktop\readonly\memory.raw windows.dumpfiles --pid <PID> -o Desktop\readwrite\mem_dumps\
```

### Step 5: Alternatively, use MemProcFS for filesystem-like access

Mount the memory image and browse it as a filesystem with MemProcFS.

## Workflow 7: Windows artifact triage (KAPE-style collection)

**Goal**: Parse a collection of Windows artifacts (prefetch, jump lists, LNK files, etc.).

### Step 1: Parse prefetch files

```pwsh
C:\Tools\Zimmerman\net6\PECmd.exe -d Desktop\readonly\Prefetch --csv Desktop\readwrite\prefetch_output
```

### Step 2: Parse jump lists

```pwsh
C:\Tools\Zimmerman\net6\JLECmd.exe -d Desktop\readonly\JumpLists --csv Desktop\readwrite\jumplist_output
```

### Step 3: Parse LNK files

```pwsh
C:\Tools\Zimmerman\net6\LECmd.exe -d Desktop\readonly\LNK --csv Desktop\readwrite\lnk_output
```

### Step 4: Parse Recycle Bin

```pwsh
C:\Tools\Zimmerman\net6\RBCmd.exe -d "Desktop\readonly\$Recycle.Bin" --csv Desktop\readwrite\recyclebin_output
```

### Step 5: Parse SRUM database

```pwsh
C:\Tools\Zimmerman\net6\SrumECmd.exe -f Desktop\readonly\SRUDB.dat --csv Desktop\readwrite\srum_output
```

### Step 6: Correlate in TimelineExplorer

Open CSV outputs in `"C:\Program Files\TimelineExplorer\TimelineExplorer.exe"` for visual correlation.

## Workflow 8: Email analysis

**Goal**: Extract and analyze suspicious email attachments.

### Step 1: Parse the email

For `.eml`:

```pwsh
python C:\Tools\DidierStevens\emldump.py Desktop\readonly\suspicious.eml
```

For `.msg`:

```pwsh
C:\venv\bin\extract_msg.exe Desktop\readonly\suspicious.msg -o Desktop\readwrite\email_extracted
```

### Step 2: Extract attachments

```pwsh
python C:\Tools\DidierStevens\emldump.py Desktop\readonly\suspicious.eml -d -s <stream_id>
```

### Step 3: Analyze attachments using the appropriate workflow

- Office document? Use Workflow 3.
- PDF? Use Workflow 4.
- Executable? Use Workflow 2.
- Archive? Extract with 7-Zip, then analyze contents.

## Workflow 9: Disk image analysis

**Goal**: Examine a disk image for evidence.

### Step 1: Identify partitions

```pwsh
C:\Tools\sleuthkit\bin\mmls.exe Desktop\readonly\disk.dd
```

### Step 2: List files

```pwsh
C:\Tools\sleuthkit\bin\fls.exe -r -o <partition_offset> Desktop\readonly\disk.dd > Desktop\readwrite\file_listing.txt
```

### Step 3: Extract specific files

```pwsh
C:\Tools\sleuthkit\bin\icat.exe -o <partition_offset> Desktop\readonly\disk.dd <inode> > Desktop\readwrite\extracted_file
```

### Step 4: Parse MFT if NTFS

```pwsh
C:\Tools\Zimmerman\net6\MFTECmd.exe -f Desktop\readonly\$MFT --csv Desktop\readwrite\mft_output
```

### Step 5: Mount for interactive browsing

Use OSFMount to mount the image as a read-only drive letter for file browsing.
