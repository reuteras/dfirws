#
# dfirws directory
#

#$CLI_TOOL = "${POWERSHELL_EXE}"
#$CLI_TOOL_ARGS = "-NoExit"
$TERMINAL_INSTALL_DIR = ((Get-ChildItem "$env:ProgramFiles\Windows Terminal").Name | findstr "terminal" | Select-Object -Last 1)
$TERMINAL_INSTALL_LOCATION = "$env:ProgramFiles\Windows Terminal\$TERMINAL_INSTALL_DIR"
$CLI_TOOL = "${TERMINAL_INSTALL_LOCATION}\wt.exe"
$CLI_TOOL_ARGS = "-w 0 C:\Program Files\PowerShell\7\pwsh.exe -NoExit"

# Create directory for shortcuts to installed tools
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws" | Out-Null

# DidierStevens
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\DidierStevens" | Out-Null

# Editors
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Editors" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Editors\Bytecode Viewer.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${POWERSHELL_EXE} -w hidden -command ${TOOLS}\bin\bcv.bat"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Editors\ImHex.lnk" -DestinationPath "${TOOLS}\imhex\imhex-gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Editors\Notepad++.lnk" -DestinationPath "${env:ProgramFiles}\Notepad++\notepad++.exe"

# Files and apps
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\autoit-ripper.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command autoit-ripper -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\binlex (A Binary Genetic Traits Lexer).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command binlex.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Detect It Easy (determining types of files).lnk" -DestinationPath "${TOOLS}\die\die.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\ezhexviewer (A simple hexadecimal viewer).lnk" -DestinationPath "C:\venv\bin\ezhexviewer.exe" -WorkingDirectory "${HOME}\Desktop"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\dumpbin (Microsoft COFF Binary File Dumper).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dumpbin.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\fq (jq for binary formats).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command fq -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\jq ( commandline JSON processor).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command jq -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\lessmsi (A tool to view and extract the contents of a Windows Installer (.msi) file).lnk" -DestinationPath "${TOOLS}\lessmsi\lessmsi-gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\magika (A tool like file and file-magic based on AI).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command magika -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\msidump.py (a tool that analyzes malicious MSI installation packages, extracts files, streams, binary data and incorporates YARA scanner).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command msidump.py -h"
# Removed qrtool.lnk since project removed from GitHub
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\qrtool.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command qrtool -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\ripgrep (rg).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command rg -h"

# Files and apps - Browser
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Browser" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\hindsight (Internet history forensics for Google Chrome and Chromium).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command hindsight.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\hindsight_gui.lnk" -DestinationPath "${TOOLS}\bin\hindsight_gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\unfurl_app.exe (unfurl takes a URL and expands it into a directed graph - dfir-unfurl).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command C:\venv\dfir-unfurl\Scripts\unfurl_app.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\unfurl.exe (unfurl takes a URL and expands it into a directed graph - dfir-unfurl).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command C:\venv\dfir-unfurl\Scripts\unfurl.exe -h"

# Files and apps - Database
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Database" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\DB Browser for SQLite.lnk" -DestinationPath "${TOOLS}\sqlitebrowser\DB Browser for SQLite.exe"
Add-SHortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\dbeaver (runs dfirws-install -DBeaver).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -DBeaver"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\dsq (commandline SQL engine for data files).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dsq -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\h2 database.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${TOOLS}\h2database"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\fqlite (runs dfirws-install -FQLite).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -FQLite"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\litecli (SQLite CLI with autocompletion and syntax highlighting).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command litecli --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\SQLECmd.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\SQLECmd\SQLECmd.exe" -Arguments "${CLI_TOOL_ARGS} -command SQLECmd.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\sqlit(TUI for SQL databases).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command sqlit.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\sqldiff.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\sqlite\sqlite3.exe" -Arguments "${CLI_TOOL_ARGS} -command sqldiff.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\sqlite3.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\sqlite\sqlite3.exe" -Arguments "${CLI_TOOL_ARGS} -command sqlite3.exe -help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\sqlite3_analyzer (Analyze the SQLite3 database file and report detailing size and storage efficiency).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\sqlite\sqlite3.exe" -Arguments "${CLI_TOOL_ARGS} -command sqlite3_analyzer"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\SQLiteWalker.py.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command SQLiteWalker.py -h"

# Files and apps - Disk
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Disk" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\INDXRipper.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\INDXRipper\INDXRipper.exe" -Arguments "${CLI_TOOL_ARGS} -command INDXRipper.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\mactime2 (replacement for mactime - dfir-toolkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command mactime2.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\MFTBrowser.lnk" -DestinationPath "${TOOLS}\bin\MFTBrowser.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\fat_parser.py (Extract information from FAT files).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command fat_parser.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\ntfs_parser.py (Extract information from NTFS metadata files, volumes, and shadow copies).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command ntfs_parser.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\parseUSBs.exe (Registry parser, to extract USB connection artifacts from SYSTEM, SOFTWARE, and NTUSER.dat hives).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command parseUSBs.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\blkcalc (Calculates where data in the unallocated space image (from blkls) exists in the original image - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command blkcalc.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\blkcat (Extracts the contents of a given data unit - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command blkcat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\blkls (Lists the details about data units and can extract the unallocated space of the file system - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command blkls.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\blkstat (Displays the statistics about a given data unit in an easy to read format - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command blkstat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\fcat - sleuthkit.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command fcat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\ffind (Finds allocated and unallocated file names that point to a given meta data structure - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command ffind.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\fls (Lists allocated and deleted file names in a directory - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command fls.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\fsstat (Shows file system details and statistics including layout, sizes, and labels - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command fsstat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\hfind (Uses a binary sort algorithm to lookup hashes in the NIST NSRL, Hashkeeper, and custom hash databases created by md5sum - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command hfind.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\icat (Extracts the data units of a file, which is specified by its meta data address (instead of the file name) - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command icat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\ifind (Finds the meta data structure that has a given file name pointing to it or the meta data structure that points to a given data unit - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command ifind.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\ils (Lists the meta data structures and their contents in a pipe delimited format - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command ils.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\img_cat (This tool will show the raw contents of an image file - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command img_cat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\img_stat (tool will show the details of the image format - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command img_stat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\istat (Displays the statistics and details about a given meta data structure in an easy to read format - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command istat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\jcat (Display the contents of a specific journal block - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command jcat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\jls (List the entries in the file system journal - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command jls.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\mmcat (Extracts the contents of a specific volume to STDOUT - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command mmcat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\mmls (Displays the layout of a disk, including the unallocated space - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command mmls.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\mmstat (Display details about a volume system (typically only the type) - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command mmstat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\pstat - sleuthkit.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command pstat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\tsk_comparedir (Compares a local directory hierarchy with the contents of raw device (or disk image) - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command tsk_comparedir.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\tsk_gettimes (Extracts all of the temporal data from the image to make a timeline - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command tsk_gettimes.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\tsk_imageinfo - sleuthkit.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command tsk_imageinfo.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\tsk_loaddb (Loads the metadata from an image into a SQLite database - sleuthkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command tsk_loaddb.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\tsk_recover (Extracts the unallocated (or allocated) files from a disk image to a local directory) - sleuthkit.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command tsk_recover.exe -h"

# Files and apps - Email
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Email" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Email\email-analyzer.py.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${GIT_PATH}\EmailAnalyzer" -Arguments "${CLI_TOOL_ARGS} -command .\email-analyzer.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Email\emldump (A utility to parse and analyze EML files).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command emldump.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Email\extract_msg.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command extract_msg -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Email\Mbox Viewer.lnk" -DestinationPath "${TOOLS}\mboxviewer\mboxview64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Email\msgviewer.lnk" -DestinationPath "${TOOLS}\lib\msgviewer.jar"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Email\pst-extract.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command pst-extract.py -h"

# Files and apps - JavaScript
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\JavaScript" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\JavaScript\box-js (is a utility to analyze malicious JavaScript files).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command box-js --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\JavaScript\deobfuscator (synchrony).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command synchrony --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\JavaScript\js-beautify (Javascript beautifier).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command js-beautify --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\JavaScript\jsdom (opens README in Notepad++).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command notepad++.exe C:\Tools\node\node_modules\jsdom\README.md"

# Files and apps - Log
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Log" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\chainsaw (Rapidly work with Forensic Artefacts).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command chainsaw.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\cleanhive (merges logfiles into a hive file - dfir-toolkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command cleanhive.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\erip (Parse timeline-format events file - Events-Ripper).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command erip.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\es4forensics (This crates provides structs and functions to insert timeline data into an elasticsearch index - dfir-toolkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command es4forensics.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtx_dump (Utility to parse EVTX files).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command evtx_dump.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtvenv x2bodyfile (creates bodyfile from Windows evtx files - dfir-toolkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command evtx2bodyfile.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtxanalyze (crate provide functions to analyze evtx files - dfir-toolkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command evtxanalyze.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtxcat (Display one or more events from an evtx file - dfir-toolkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command evtxcat.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtxls (Display one or more events from an evtx file - dfir-toolkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command evtxls.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtxscan (Find time skews in an evtx file - dfir-toolkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command evtxscan.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\fx (Terminal JSON viewer and processor).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command fx -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\gron (Make JSON greppable).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command gron -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\hayabusa (is a sigma-based threat hunting and fast forensics timeline generator for Windows event logs).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command hayabusa.exe help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\ipgrep (search for IP addresses in text files - dfir-toolkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command ipgrep.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\logboost (runs dfirws-install -LogBoost).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -LogBoost"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\Lumen (Browser-based EVTX Companion).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command ${HOME}\Documents\tools\utils\lumen.ps1"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\MasterParser.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${env:ProgramFiles}\AuthLogParser" -Arguments "${CLI_TOOL_ARGS} -command .\MasterParser.ps1 -o Menu"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\Microsoft LogParser.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command LogParser.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\pf2bodyfile.exe (creates bodyfile from Windows Prefetch files - dfir-toolkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command pf2bodyfile.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\PowerSiem.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command PowerSiem.ps1"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\takajo (is a tool to analyze Windows event logs - hayabusa).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${TOOLS}\takajo" -Arguments "${CLI_TOOL_ARGS} -command takajo.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\ToolAnalysisResultSheet (Summarizes the results of examining logs recorded in Windows upon execution common tools used by attackers that has infiltrated a network).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command ToolAnalysisResultSheet.ps1"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\toolong (tl - A terminal application to view, tail, merge, and search log files (plus JSONL)).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command tl.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\ts2date (replaces UNIX timestamps in a stream by a formatted date - dfir-toolkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command ts2date.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\zircolite (Standalone SIGMA-based detection tool for EVTX, Auditd, Sysmon for linux, XML or JSONL,NDJSON Logs).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command zircolite.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\YAMAGoya (Yet Another Memory Analyzer for malware detection and Guarding Operations with YARA and SIGMA).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command YAMAGoya.exe --help"

# Files and apps - Office
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Office" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\MetadataPlus.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\bin\MetadataPlus.exe" -Arguments "${CLI_TOOL_ARGS} -command MetadataPlus.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\mraptor.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command mraptor -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\msodde.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command msodde -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\msoffcrypto-crack.py.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command msoffcrypto-crack.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\msoffcrypto-tool.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command msoffcrypto-tool -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\oledump.py.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command oledump.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\oleid.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command oleid -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\olevba.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command olevba -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\pcode2code.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command pcode2code -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\rtfdump.py.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command rtfdump.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\rtfobj.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command rtfobj -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\tree.com.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command tree.com /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\xlmdeobfuscator (XLMMacroDeobfuscator can be used to decode obfuscated XLM macros).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command xlmdeobfuscator -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\zipdump.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command zipdump.py -h"

# Files and apps - PDF
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\PDF" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\Foxit Reader for pdf files (runs dfirws-install -FoxitReader).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -FoxitReader"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\pdf-parser.py.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command pdf-parser.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\pdfalyze.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command pdfalyze -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\pdfid.py.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command pdfid.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\pdftool.py.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command pdftool.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\peepdf-3 (peepdf - peepdf-3 is a Python 3 tool to explore PDF files).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command peepdf -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\qpdf.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command qpdf.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\xray.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command echo 'xray is a tool to detect PDF files with a bad redaction'"

# Files and apps - PE
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\PE" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\4n4lDetector.lnk" -DestinationPath "${env:ProgramFiles}\4n4lDetector\4N4LDetector.exe"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\capa.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\capa\capa.exe" -Arguments "${CLI_TOOL_ARGS} -command capa.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\Debloat.lnk" -DestinationPath "${TOOLS}\bin\debloat.exe"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\dll_to_exe.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\ExeinfoPE.lnk" -DestinationPath "${TOOLS}\ExeinfoPE\exeinfope.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\hachoir-tools.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dir C:\venv\bin\hachoir-*"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\hollows_hunter (Scans running processes. Recognizes and dumps a variety of in-memory implants).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\bin\hollows_hunter.exe" -Arguments "${CLI_TOOL_ARGS} -command hollows_hunter.exe /help"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\pe2pic.ps1.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command pe2pic.ps1 -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\PE-bear.lnk" -DestinationPath "${TOOLS}\pebear\PE-bear.exe"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\PE-sieve (Scans a given process, recognizes and dumps a variety of in-memory implants).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\bin\pe-sieve.exe" -Arguments "${CLI_TOOL_ARGS} -command pe-sieve.exe /help"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\pescan.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${TOOLS}\pev" -Arguments "${CLI_TOOL_ARGS} -command pescan.exe --help"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\readpe - PE Utils.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${TOOLS}\pev" -Arguments "${CLI_TOOL_ARGS} -command readpe.exe --help"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\shellconv.py.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command shellconv.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\WinObjEx64.lnk" -DestinationPath "${TOOLS}\WinObjEx64\WinObjEx64.exe"

# Files and apps - Phone
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Phone" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\aleapp (Android Logs, Events, and Protobuf Parser).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command aleapp.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\aleappGUI.lnk" -DestinationPath "${TOOLS}\bin\aleappGUI.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\ileapp (iOS Logs, Events, And Plists Parser).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command ileapp.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\iShutdown_detect.py (sysdiagnose_file.tar.gz).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command iShutdown_detect.py"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\iShutdown_parse.py (A tool to extract and parse iOS shutdown logs from a .tar.gz archive).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command iShutdown_parse.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\iShutdown_stats.py (Process an iOS shutdown.log file to create stats on reboots).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command iShutdown_stats.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\iLEAPPGUI.lnk" -DestinationPath "${TOOLS}\bin\iLEAPPGUI.exe"

# Files and apps - RDP
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\RDP" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\RDP\bmc-tools.py (RDP Bitmap Cache parser).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command bmc-tools.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\RDP\RdpCacheStitcher.lnk" -DestinationPath "${TOOLS}\RdpCacheStitcher\RdpCacheStitcher.exe"

# Forensics
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Forensics" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\artemis.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command artemis.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\acquire-decrypt.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command acquire-decrypt.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\acquire.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command acquire.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\asdf-dd.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command asdf-dd.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\asdf-meta.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command asdf-meta.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\asdf-repair.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command asdf-repair.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\asdf-verify.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command asdf-verify.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\dump-nskeyedarchiver.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dump-nskeyedarchiver.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\envelope-decrypt.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command envelope-decrypt.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\keyring.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command keyring.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\normalizer.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command normalizer.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\parse-lnk.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command parse-lnk.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\rdump.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command rdump.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\rgeoip.exe (use rgeoip.ps1 if you have maxmind in enrichment- dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command rgeoip.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-build-pluginlist.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command target-build-pluginlist.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-dd.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command target-dd.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-dump.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command target-dump.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-fs.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command target-fs.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-info.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command target-info.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-mount.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command target-mount.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-query.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command target-query.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-reg.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command target-reg.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-shell.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command target-shell.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\thumbcache-extract-indexed.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command thumbcache-extract-indexed.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\thumbcache-extract.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command thumbcache-extract.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\binary-refinery.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command binref -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\vma-extract.exe (dissect).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command vma-extract.exe -h"

# Incident response
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\IR" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\Forensic Timeliner (runs dfirws-install -ForensicTimeliner).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -ForensicTimeliner"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\Kanvas (runs dfirws-install -Kanvas).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Kanvas"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\Kape (runs dfirws-install -Kape).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Kape"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\Trawler.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command Get-Help trawler"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\PersistenceSniper.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command Import-Module ${GIT_PATH}\PersistenceSniper\PersistenceSniper\PersistenceSniper.psd1 ; Get-Help -Name Find-AllPersistence"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\PowerSponse.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${GIT_PATH}\PowerSponse" -Arguments "${CLI_TOOL_ARGS} -command Import-Module ${GIT_PATH}\PowerSponse\PowerSponse.psd1 ; Get-Help -Name Invoke-PowerSponse"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\White-Phoenix.py (recovers content from files encrypted by Ransomware using intermittent encryption).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command venv.ps1 -whitephoenix ; White-Phoenix.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\velociraptor.exe (Velociraptor is an advanced digital forensic and incident response tool that enhances your visibility into your endpoints).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command velociraptor.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\Shadow-pulse (csv with information about ransomware groups).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command EZViewer.exe ${GIT_PATH}\Shadow-pulse\Ransomlist.csv"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\witr (Why is this running).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command witr.exe --help"

# Malware tools
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Malware tools" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\csvkit (tools for working with csv files).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command csv --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\defender-detectionhistory-parser (dhparser).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dhparser -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\defender-dump.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command defender-dump.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\maldump.exe (Multi-quarantine extractor).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command maldump.exe -h"

# Malware tools - Cobalt Strike
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Malware tools\Cobalt Strike" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\Cobalt Strike\1768.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command 1768.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\Cobalt Strike\BeaconHunter.lnk" -DestinationPath "${env:ProgramFiles}\BeaconHunter\BeaconHunter.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\Cobalt Strike\CobaltStrikeScan.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command CobaltStrikeScan.exe -h"

# Malware tools - Gootloader
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Malware tools\Gootloader" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\Gootloader\Gootloader (Mandiant).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${GIT_PATH}\gootloader" -Arguments "${CLI_TOOL_ARGS} -command dir"

# Memory
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Memory" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Memory\Dokany (runs dfirws-install -Dokany).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Dokany"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Memory\MemProcFS.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command MemProcFS.exe -h"

# Network
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Network" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\Fakenet.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\fakenet\fakenet.exe" -Arguments "${CLI_TOOL_ARGS} -command fakenet.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\hfs.exe.lnk" -DestinationPath "${TOOLS}\hfs\hfs.exe" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\ipexpand.py.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command ipexpand.py"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\scapy.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command scapy -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\tailscale installer.lnk" -DestinationPath "${SETUP_PATH}\tailscale.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\wireguard installer.lnk" -DestinationPath "${SETUP_PATH}\wireguard.msi"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\Wireshark (runs dfirws-install -Wireshark).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Wireshark"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\Zaproxy (runs dfirws-install -Zaproxy).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Zaproxy"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\Zui (runs dfirws-install -Zui).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Zui"

# OS
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\OS" | Out-Null

# OS- Android
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\OS\Android" | Out-Null

# OS - Linux
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\OS\Linux" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Linux\elfparser-ng.lnk" -DestinationPath "${TOOLS}\elfparser-ng\Release\elfparser-ng.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Linux\xelfviewer.lnk" -DestinationPath "${TOOLS}\XELFViewer\xelfviewer.exe"

# OS - macOS
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\OS\macOS" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\macOS\dsstore.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${GIT_PATH}\Python-dsstore" -Arguments "${CLI_TOOL_ARGS} -command cat .\README.md"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\macOS\machofile-cli.py.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command machofile-cli.py -h"

# OS - Windows
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\OS\Windows" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\ese2csv.exe (Find and dump ESE databases).lnk" -DestinationPath "${CLI_TOOL}" -Arguments "${CLI_TOOL_ARGS} -command ese2csv.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\fibratus (runs dfirws-install -Fibratus).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Fibratus"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Jumplist-Browser.lnk" -DestinationPath "${TOOLS}\bin\JumplistBrowser.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\lnk2bodyfile (Parse Windows LNK files and create bodyfile output - dfir-toolkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command lnk2bodyfile.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Prefetch-Browser.lnk" -DestinationPath "${TOOLS}\bin\PrefetchBrowser.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\sidr (Search Index DB Reporter - handles both ESE (.edb) and SQLite).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command sidr --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\srum-dump (Parses Windows System Resource Usage Monitor (SRUM) database).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command srum_dump.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Thumbcache Viewer.lnk" -DestinationPath "${TOOLS}\thumbcacheviewer\thumbcache_viewer.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\usnjrnl_dump (Parses Windows UsnJrnl files - dfir-toolkit - janstarke).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command usnjrnl_dump.exe --help"

# OS - Windows - Active Directory (AD)
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\OS\Windows\Active Directory (AD)" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Active Directory (AD)\adalanche (Active Directory ACL Visualizer and Explorer).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command adalanche.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Active Directory (AD)\CimSweep.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${GIT_PATH}\CimSweep" -Arguments "${CLI_TOOL_ARGS} -command Import-Module .\CimSweep\CimSweep.psd1"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Active Directory (AD)\DitExplorer (Active Directory Database Explorer).lnk" -DestinationPath "${TOOLS}\DitExplorer\DitExplorer.UI.WpfApp.exe"

# OS - Windows - Registry
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\OS\Windows\Registry" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\hivescan (scans a registry hive file for deleted entries - dfir-toolkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command hivescan.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\pol_export (Exporter for Windows Registry Policy Files - dfir-toolkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command pol_export.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\regdump (parses registry hive files and prints a bodyfile - dfir-toolkit).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command regdump.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\regipy-diff.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command regipy-diff.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\regipy-dump.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command regipy-dump.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\regipy-parse-header.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command regipy-parse-header.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\regipy-plugins-list.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command regipy-plugins-list.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\regipy-plugins-run.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command regipy-plugins-run.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\regipy-process-transaction-logs.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command regipy-process-transaction-logs.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\Registry Explorer.lnk" -DestinationPath "${TOOLS}\Zimmerman\net6\RegistryExplorer\RegistryExplorer.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\RegRipper (rip).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command rip.exe -h"

# Programming and Development
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Programming" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\java.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\node.lnk" -DestinationPath "${TOOLS}\node\node.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\perl.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Python.lnk" -DestinationPath "${VENV}\bin\python.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Visual Studio Buildtools (runs dfirws-install -VisualStudioBuildTools).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -VisualStudioBuildTools"

# Programming - dotNET
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Programming\dotNET" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\dotNET\dotnetfile_dump.py.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dotnetfile_dump.py -h"

# Programming - Delphi
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Delphi" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Delphi\idr.lnk" -DestinationPath "${env:ProgramFiles}\idr\bin\Idr.exe"

# Programming - Go
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Go" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Go\GoLang (runs dfirws-install -GoLang).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -GoLang"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Go\gftrace.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command gftrace"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Go\GoReSym.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command GoReSym.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Go\Redress.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command Redress.exe -h"

# Programming - Java
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Java" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Java\Jadx (runs dfirws-install -Jadx).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Jadx"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Java\jd-gui.lnk" -DestinationPath "${TOOLS}\jd-gui\jd-gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Java\jwt (JWT tool).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command jwt -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Java\recaf (The modern Java bytecode editor).lnk" -DestinationPath "${TOOLS}\bin\recaf.bat" -Arguments "${CLI_TOOL_ARGS} -command recaf.bat" -Iconlocation "${TOOLS}\lib\recaf.jar"

# Programming - Node
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Node" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Node\Node (runs dfirws-install -Node).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Node"

# Programming - PowerShell
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Programming\PowerShell" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\PowerShell\deobshell (main.py).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${GIT_PATH}\deobshell" -Arguments "${CLI_TOOL_ARGS} -command .\main.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\PowerShell\PowerDecode.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${GIT_PATH}\PowerDecode" -Arguments "${CLI_TOOL_ARGS} -command .\GUI.ps1"

# Programming - Python
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Python" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Python\pydisasm.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command venv.ps1 -binaryrefinery ; pydisasm --help"

# Programming - Ruby
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Ruby" | Out-Null

# Programming - Rust
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Rust" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Rust\Rust (runs dfirws-install -Rust).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Rust"

# Reverse Engineering
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Reverse Engineering" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\Cutter.lnk" -DestinationPath "${TOOLS}\cutter\cutter.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\dnSpy32.lnk" -DestinationPath "${TOOLS}\dnSpy32\dnSpy.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\dnSpy64.lnk" -DestinationPath "${TOOLS}\dnSpy64\dnSpy.exe"
if (Test-Path "${TOOLS}\ghidra") {
    (Get-ChildItem "${TOOLS}\ghidra").Name | Where-Object { $_ -match "ghidra_" } | ForEach-Object {
        $VERSION = "$_"
        Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\${VERSION}.lnk" -DestinationPath "${TOOLS}\ghidra\${VERSION}\ghidraRun.bat"
    }
}
#if (Test-Path "${VENV}\jep") {
#    Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\Ghidrathon (Ghidra with JEP and Ghidrathon).lnk" -DestinationPath "${HOME}\Documents\tools\utils\ghidrathon.bat"
#}
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\iaito.lnk" -DestinationPath "${TOOLS}\iaito\iaito.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\ImHex.lnk" -DestinationPath "${TOOLS}\imhex\imhex-gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\radare2.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command radare2 -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\rizin.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command rizin -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\scare.ps1.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command scare.ps1 -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\X64dbg (runs dfirws-install -X64dbg).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -X64dbg"

# Signatures and information
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Signatures and information" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\blyara.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command blyara -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\evt2sigma.ps1 (python package).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command evt2sigma.ps1 -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\loki (runs dfirws-install -Loki).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Loki"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\mkyara.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command mkyara -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\PatchaPalooza.py.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${GIT_PATH}\PatchaPalooza" -Arguments "${CLI_TOOL_ARGS} -command .\PatchaPalooza.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\sigma-cli (This is the Sigma command line interface using the pySigma library to manage, list and convert Sigma rules into query languages).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command sigma.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\yara.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command yara.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\yarac.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command yarac.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\yq (is a portable command-line YAML, JSON, XML, CSV, TOML and properties processor).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command yq.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\yr (yara-x).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command yr.exe -h"

# Signatures and information - Online tools
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Signatures and information\Online tools" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\Online tools\bazaar.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command bazaar --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\Online tools\malware-bazaar-advanced-search (search.py).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${GIT_PATH}\malware-bazaar-advanced-search"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\Online tools\shodan.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command shodan"

# Sysinternals
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Sysinternals" | Out-Null

# Utilities
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Utilities" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\bash (Git-version).lnk" -DestinationPath "${env:ProgramFiles}\Git\bin\bash.exe" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\cmder (runs dfirws-install -Cmder).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Cmder"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\floss.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\floss\floss.exe" -Arguments "${CLI_TOOL_ARGS} -command venv.ps1 -floss ; floss --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\git.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${env:ProgramFiles}\Git\cmd\git-gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\godap (LDAP tool).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command godap --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\jpterm (Jupyter in the terminal).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command jpterm --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\jupyter notebook.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command ${HOME}\Documents\tools\utils\jupyter.bat"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\markitdown (Python tool for converting files and office documents to Markdown).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command markitdown --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\mmdbinspect (Tool for GeoIP lookup).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command mmdbinspect --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\pwncat.py (Fancy reverse and bind shell handler).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command pwncat.py --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\pygmentize.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command pygmentize --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\rexi.exe (Terminal UI for Regex Testing).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command rexi.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\time-decode.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command time-decode --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\upx.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command upx"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\visidata (VisiData or vd is an interactive multitool for tabular data).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command visidata --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\zstd.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command zstd -h"

# Utilities - _dfirws
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Utilities\_dfirws" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\_dfirws\dfirws-install.ps1.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command Get-Help dfirws-install.ps1"

# Utilities - Browsers
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Utilities\Browsers" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Browsers\Firefox (runs dfirws-install -Firefox).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Firefox"

# Utilities - Crypto
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Utilities\Cryptography" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\ares.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command ares --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\chepy.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command venv.ps1 -chepy ; chepy -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\CyberChef.lnk" -DestinationPath "${TOOLS}\CyberChef\CyberChef.html"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\hash-id.py.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command hash-id.py"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\name-that-hash (also available as nth).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command name-that-hash --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\openssl.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command openssl --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\sigs.py.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command sigs.py --help"

# Utilities - CTF
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Utilities\CTF" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\CTF\HiddenWave (and ExWave).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${GIT_PATH}\HiddenWave" -Arguments "${CLI_TOOL_ARGS} -command dir"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\CTF\stegolsb.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command stegolsb --help"

# Utilities - Media
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Utilities\Media" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Media\Audacity.lnk" -DestinationPath "${TOOLS}\Audacity\audacity.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Media\ffmpeg.lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command ffmpeg --help"

# Zimmerman
New-Item -Force -ItemType Directory "${HOME}\Desktop\dfirws\Zimmerman" | Out-Null

# Add shortcuts from in $SETUP_PATH\dfirws\dfirws_folder_*.ps1 if they exists
$FOLDER_SCRIPTS = Get-ChildItem -Path "${SETUP_PATH}\dfirws" -Filter "dfirws_folder_*.ps1" -ErrorAction SilentlyContinue
foreach ($script in $FOLDER_SCRIPTS) {
    Write-SynchronizedLog "Running dfirws folder script: $($script.FullName)"
    & $script.FullName
}

# Pin to explorer
$shell = new-object -com "Shell.Application"
$folder = ${shell}.Namespace("${HOME}\Desktop")
$item = ${folder}.Parsename('dfirws')
$verb = ${item}.Verbs() | Where-Object { $_.Name -like 'Pin to *Quick access' }
if ("${verb}") {
    ${verb}.DoIt()
}

# Copy shortcuts to Start menu
if ("${WSDFIR_START_MENU}" -eq "Yes") {
    ${sourceDir} = "${HOME}\Desktop\dfirws"
    ${DestinationDir} = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"

    if (-not (Test-Path -Path ${DestinationDir})) {
        New-Item -Force -ItemType Directory -Path ${DestinationDir}
    }

    # Find all files in the source directory, including subdirectories
    $files = Get-ChildItem -Path ${sourceDir} -Recurse -File

    foreach ($file in $files) {
        $newFolderName = "dfirws - " + $file.DirectoryName.Replace($sourceDir, '').TrimStart('\').Replace('\', ' - ').Replace('\', ' - ').Replace('\', ' - ')
        $newFolderPath = Join-Path -Path $DestinationDir -ChildPath $newFolderName

        # Ensure the new folder exists
        if (-not (Test-Path -Path $newFolderPath)) {
            New-Item -Force -ItemType Directory -Path $newFolderPath | Out-Null
        }

        # Define the new file path within the new folder structure
        $newFilePath = Join-Path -Path $newFolderPath -ChildPath $file.Name

        # Copy the file to the new location
        Copy-Item -Path $file.FullName -Destination $newFilePath | Out-Null
    }

    Write-DateLog "Files have been copied to the destination directory: ${DestinationDir}"
}
