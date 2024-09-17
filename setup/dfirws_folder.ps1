#
# dfirws directory
#

# Create directory for shortcuts to installed tools
Write-DateLog "Start creation of Desktop/dfirws" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
New-Item -ItemType Directory "${HOME}\Desktop\dfirws" | Out-Null

# DidierStevens
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\DidierStevens" | Out-Null
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\1768.py (Analyze Cobalt Strike beacons).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command 1768.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\amsiscan.py (Scan input with AmsiScanBuffer).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command amsiscan.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\base64dump.py (Extract base64 strings from file).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command base64dump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\byte-stats.py (Calculate byte statistics).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command byte-stats.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\cipher-tool.py (Cipher tool).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command cipher-tool.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\count.py (count unique items).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command count.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\cs-analyze-processdump.py (Analyze Cobalt Strike beacon process dumps for further analysis).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command cs-analyze-processdump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\cs-decrypt-metadata.py (Cobalt Strike - RSA decrypt metadata).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command cs-decrypt-metadata.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\cs-extract-key.py (Extract cryptographic keys from Cobalt Strike beacon process dump).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command cs-extract-key.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\csv-stats.py (Tool to produce statistics for CSV files).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command csv-stats.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\cut-bytes.py (Cut a section of bytes out of a file).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command cut-bytes.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\decode-vbe.py (Decode VBE script).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command decode-vbe.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\decompress_rtf.py (Tool to decompress compressed RTF).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command decompress_rtf.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\defuzzer.py (Merge 3 or more fuzzed files back to original).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command defuzzer.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\disitool.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command disitool.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\emldump.py (EML dump utility).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command emldump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\file-magic.py (Essentially a wrapper for file (libmagic)).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command file-magic.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\find-file-in-file.py (Find if a file is present in another file).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command find-file-in-file.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\format-bytes.py (This is essentially a wrapper for the struct module).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command format-bytes.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\hash.py (This is essentially a wrapper for the hashlib module).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command hash.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\headtail.py (Output head and tail of input).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command headtail.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\hex-to-bin.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command hex-to-bin.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\jpegdump.py (JPEG file analysis tool).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command jpegdump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\js-ascii.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command js-ascii.exe -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\js-file.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command js-file.exe -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\metatool.py (Tool for Metasploit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command metatool.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\msoffcrypto-crack.py (Crack MS Office document password).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command msoffcrypto-crack.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\myjson-filter.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command myjson-filter.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\myjson-transform.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command myjson-transform.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\nsrl.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command nsrl.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\numbers-to-hex.py (Program to convert decimal numbers into hex numbers).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command numbers-to-hex.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\numbers-to-string.py (Program to convert numbers into a string).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command numbers-to-string.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\oledump.py (Analyze OLE files (Compound Binary Files)).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command oledump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\onedump.py (Dump tool for OneNote files).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command onedump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\pdf-parser.py (pdf-parser, use it to parse a PDF document).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pdf-parser.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\pdfid.py (Tool to test a PDF file).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pdfid.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\pdftool.py (Tool to process PDFs).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pdftool.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\pecheck.py (Tool for displaying PE file info).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pecheck.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\pngdump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pngdump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\python-per-line.py (Program to evaluate a Python expression for each line in the provided text file(s)).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command python-per-line.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\re-search.py (Program to use Python's re.findall on files).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command re-search.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\rtfdump.py (Analyze RTF files).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command rtfdump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\sets.py (Set operations on 2 (or 1) files: union, intersection, subtraction, exclusive or, sample, join, unique, product, substitute, sort).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command sets.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\sortcanon.py (Sort with canonicalization function).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command sortcanon.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\split-overlap.py (Split file with overlap).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command split-overlap.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\split.py (Split a text file into X number of files (2 by default)).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command split.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\ssdeep.py (ssdeep tool).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ssdeep.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\strings.py (Strings command in Python).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command strings.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\teeplus.py (Save binary data while piping it from stdin to stdout. Like the tee command, but plus).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command teeplus.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\translate.py (Translate bytes according to a Python expression).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command translate.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\what-is-new.py (Tool to monitor new items).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command what-is-new.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\xlsbdump.py (XLSB parser).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command xlsbdump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\xmldump.py (This is essentially a wrapper for xml.etree.ElementTree).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command xmldump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\xor-kpa.py (XOR known-plaintext attack).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command xor-kpa.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\xorsearch.py (Bruteforce a file for encodings and search).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command xorsearch.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\zipdump.py (ZIP dump utility).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command zipdump.py -h"

# Editors
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Editors" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Editors\Bytecode Viewer.lnk" -DestinationPath "${POwERShell_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-w hidden -command ${TOOLS}\bin\bcv.bat"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Editors\HxD.lnk" -DestinationPath "${env:ProgramFiles}\HxD\HxD.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Editors\ImHex.lnk" -DestinationPath "${TOOLS}\imhex\imhex-gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Editors\Malcat.lnk" -DestinationPath "${env:ProgramFiles}\malcat\bin\malcat.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Editors\Notepad++.lnk" -DestinationPath "${env:ProgramFiles}\Notepad++\notepad++.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Editors\Obsidian (runs dfirws-install -Obsidian).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Obsidian"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Editors\Visual Studio code (runs dfirws-install -VSCode).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -VSCode"

# Files and apps
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\autoit-ripper.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command autoit-ripper -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\binlex (A Binary Genetic Traits Lexer).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command binlex.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\bulk_extractor64.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command bulk_extractor64.exe -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\densityscout (calculates density (like entropy)).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command densityscout -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Detect It Easy (determining types of files).lnk" -DestinationPath "${TOOLS}\die\die.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\ezhexviewer (A simple hexadecimal viewer).lnk" -DestinationPath "C:\venv\default\Scripts\ezhexviewer.exe" -WorkingDirectory "${HOME}\Desktop"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\dumpbin (Microsoft COFF Binary File Dumper).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dumpbin.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\fq (jq for binary formats).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command fq -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\jq ( commandline JSON processor).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command jq -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\lessmsi (A tool to view and extract the contents of a Windows Installer (.msi) file).lnk" -DestinationPath "${TOOLS}\lessmsi\lessmsi-gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\magika (A tool like file and file-magic based on AI).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command magika -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\msidump.py (a tool that analyzes malicious MSI installation packages, extracts files, streams, binary data and incorporates YARA scanner).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command msidump.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Qemu (runs dfirws-install -Qemu).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dfirws-install.ps1 -Qemu"
# Removed qrtool.lnk since project removed from GitHub
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\qrtool.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command qrtool -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\ripgrep (rg).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command rg -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\trid (File Identifier).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command trid.exe -?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\WinMerge (runs dfirws-install -WinMerge).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dfirws-install.ps1 -WinMerge"

# Files and apps - Browser
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Browser" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\BrowsingHistoryView.lnk" -DestinationPath "${TOOLS}\nirsoft\BrowsingHistoryView.exe" -Iconlocation "${TOOLS}\nirsoft\BrowsingHistoryView.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\ChromeCacheView.lnk" -DestinationPath "${TOOLS}\nirsoft\ChromeCacheView.exe" -Iconlocation "${TOOLS}\nirsoft\ChromeCacheView.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\hindsight (Internet history forensics for Google Chrome and Chromium).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command hindsight.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\hindsight_gui.lnk" -DestinationPath "${TOOLS}\bin\hindsight_gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\unfurl_app.exe (unfurl takes a URL and expands it into a directed graph - dfir-unfurl).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command C:\venv\dfir-unfurl\Scripts\unfurl_app.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\unfurl.exe (unfurl takes a URL and expands it into a directed graph - dfir-unfurl).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command C:\venv\dfir-unfurl\Scripts\unfurl.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\IECacheView.lnk" -DestinationPath "${TOOLS}\nirsoft\IECacheView.exe" -Iconlocation "${TOOLS}\nirsoft\IECacheView.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\LastActivityView.lnk" -DestinationPath "${TOOLS}\nirsoft\LastActivityView.exe" -Iconlocation "${TOOLS}\nirsoft\LastActivityView.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\MZCacheView.lnk" -DestinationPath "${TOOLS}\nirsoft\MZCacheView.exe" -Iconlocation "${TOOLS}\nirsoft\MZCacheView.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\MZCookiesView.lnk" -DestinationPath "${TOOLS}\nirsoft\mzcv.exe" -Iconlocation "${TOOLS}\nirsoft\mzcv.exe"

# Files and apps - Database
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Database" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\DB Browser for SQLite.lnk" -DestinationPath "${TOOLS}\sqlitebrowser\DB Browser for SQLite.exe"
Add-SHortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\dbeaver (runs dfirws-install -DBeaver).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dfirws-install.ps1 -DBeaver"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\dsq (commandline SQL engine for data files).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dsq -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\h2 database.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${TOOLS}\h2database"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\fqlite.lnk" -DestinationPath "${TOOLS}\fqlite\run.bat"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\ingestr (is a cli that allows you to ingest data from any source into any destination).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ingestr --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\SQLECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\SQLECmd\SQLECmd.exe" -Arguments "-NoExit -command SQLECmd.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\sqldiff.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\sqlite\sqlite3.exe" -Arguments "-NoExit -command sqldiff.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\sqlite3.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\sqlite\sqlite3.exe" -Arguments "-NoExit -command sqlite3.exe -help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\sqlite3_analyzer (Analyze the SQLite3 database file and report detailing size and storage efficiency).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\sqlite\sqlite3.exe" -Arguments "-NoExit -command sqlite3_analyzer"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\SQLiteWalker.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command SQLiteWalker.py -h"

# Files and apps - Disk
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Disk" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\INDXRipper.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\INDXRipper\INDXRipper.exe" -Arguments "-NoExit -command INDXRipper.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\mactime2 (replacement for mactime - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command mactime2.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\mft2bodyfile (parses an MFT file (and optionally the corresponding UsnJrnl) to bodyfile - dfir-toolkit - janstarke).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command mft2bodyfile.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\MFTBrowser.lnk" -DestinationPath "${TOOLS}\bin\MFTBrowser.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\ntfs_parser.py (Extract information from NTFS metadata files, volumes, and shadow copies).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ntfs_parser.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\parseUSBs.py (Registry parser, to extract USB connection artifacts from SYSTEM, SOFTWARE, and NTUSER.dat hives).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command venv.ps1 -regipy ; parseUSBs.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\blkcalc (Calculates where data in the unallocated space image (from blkls) exists in the original image. This is used when evidence is found in unallocated space - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command blkcalc.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\blkcat (Extracts the contents of a given data unit - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command blkcat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\blkls (Lists the details about data units and can extract the unallocated space of the file system - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command blkls.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\blkstat (Displays the statistics about a given data unit in an easy to read format - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command blkstat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\fcat - sleuthkit.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command fcat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\ffind (Finds allocated and unallocated file names that point to a given meta data structure - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ffind.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\fls (Lists allocated and deleted file names in a directory - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command fls.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\fsstat (Shows file system details and statistics including layout, sizes, and labels - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command fsstat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\hfind (Uses a binary sort algorithm to lookup hashes in the NIST NSRL, Hashkeeper, and custom hash databases created by md5sum - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command hfind.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\icat (Extracts the data units of a file, which is specified by its meta data address (instead of the file name) - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command icat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\ifind (Finds the meta data structure that has a given file name pointing to it or the meta data structure that points to a given data unit - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ifind.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\ils (Lists the meta data structures and their contents in a pipe delimited format - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ils.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\img_cat (This tool will show the raw contents of an image file - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command img_cat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\img_stat (tool will show the details of the image format - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command img_stat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\istat (Displays the statistics and details about a given meta data structure in an easy to read format - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command istat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\jcat (Display the contents of a specific journal block - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command jcat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\jls (List the entries in the file system journal - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command jls.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\mmcat (Extracts the contents of a specific volume to STDOUT - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command mmcat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\mmls (Displays the layout of a disk, including the unallocated space - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command mmls.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\mmstat (Display details about a volume system (typically only the type) - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command mmstat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\pstat - sleuthkit.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pstat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\tsk_comparedir (Compares a local directory hierarchy with the contents of raw device (or disk image) - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command tsk_comparedir.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\tsk_gettimes (Extracts all of the temporal data from the image to make a timeline - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command tsk_gettimes.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\tsk_imageinfo - sleuthkit.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command tsk_imageinfo.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\tsk_loaddb (Loads the metadata from an image into a SQLite database - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command tsk_loaddb.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\tsk_recover (Extracts the unallocated (or allocated) files from a disk image to a local directory) - sleuthkit.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command tsk_recover.exe -h"

# Files and apps - Email
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Email" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Email\email-analyzer.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${GIT_PATH}\EmailAnalyzer" -Arguments "-NoExit -command .\email-analyzer.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Email\emldump (A utility to parse and analyze EML files).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command emldump.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Email\extract_msg.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command extract_msg -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Email\Mail Viewer.lnk" -DestinationPath "${TOOLS}\MailView\MailView.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Email\Mbox Viewer.lnk" -DestinationPath "${TOOLS}\mboxviewer\mboxview64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Email\msgviewer.lnk" -DestinationPath "${TOOLS}\lib\msgviewer.jar"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Email\pst-extract.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pst-extract.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Email\pstwalker.lnk" -DestinationPath "${TOOLS}\pstwalker\pstwalker.exe"

# Files and apps - JavaScript
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\JavaScript" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\JavaScript\box-js (is a utility to analyze malicious JavaScript files).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command box-js --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\JavaScript\deobfuscator (synchrony).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command synchrony --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\JavaScript\js-beautify (Javascript beautifier).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command js-beautify --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\JavaScript\jsdom (opens README in Notepad++).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command notepad++.exe C:\Tools\node\node_modules\jsdom\README.md"

# Files and apps - Log
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Log" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\chainsaw (Rapidly work with Forensic Artefacts).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command chainsaw.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\cleanhive (merges logfiles into a hive file - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command cleanhive.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\erip (Parse timeline-format events file - Events-Ripper).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command erip.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\es4forensics (This crates provides structs and functions to insert timeline data into an elasticsearch index - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command es4forensics.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtx_dump (Utility to parse EVTX files).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command evtx_dump.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtvenv x2bodyfile (creates bodyfile from Windows evtx files - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command evtx2bodyfile.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtxanalyze (crate provide functions to analyze evtx files - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command evtxanalyze.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtxcat (Display one or more events from an evtx file - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command evtxcat.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtxls (Display one or more events from an evtx file - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command evtxls.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtxscan (Find time skews in an evtx file - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command evtxscan.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\FullEventLogView.lnk" -DestinationPath "${TOOLS}\FullEventLogView\FullEventLogView.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\fx (Terminal JSON viewer and processor).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command fx -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\gron (Make JSON greppable).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command gron -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\hayabusa (is a sigma-based threat hunting and fast forensics timeline generator for Windows event logs).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command hayabusa.exe help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\ipgrep (search for IP addresses in text files - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ipgrep.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\MasterParser.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${env:ProgramFiles}\AuthLogParser" -Arguments "-NoExit -command .\MasterParser.ps1 -o Menu"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\Microsoft LogParser.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command LogParser.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\pf2bodyfile.exe (creates bodyfile from Windows Prefetch files - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pf2bodyfile.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\PowerSiem.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command PowerSiem.ps1"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\ToolAnalysisResultSheet (Summarizes the results of examining logs recorded in Windows upon execution of 49 tools which are likely used by a attacker that has infiltrated a network).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command ToolAnalysisResultSheet.ps1"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\toolong (tl - A terminal application to view, tail, merge, and search log files (plus JSONL)).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command tl.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\ts2date (replaces UNIX timestamps in a stream by a formatted date - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ts2date.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\zircolite (Standalone SIGMA-based detection tool for EVTX, Auditd, Sysmon for linux, XML or JSONL,NDJSON Logs - use zircolite.ps1).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command zircolite.exe -h"

# Files and apps - Office
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Office" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\LibreOffice (runs dfirws-install -LibreOffice).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -LibreOffice"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\MetadataPlus.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\bin\MetadataPlus.exe" -Arguments "-NoExit -command MetadataPlus.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\mraptor.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command mraptor -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\msodde.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command msodde -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\msoffcrypto-crack.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command msoffcrypto-crack.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\msoffcrypto-tool.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command msoffcrypto-tool -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\oledump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command oledump.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\oleid.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command oleid -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\olevba.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command olevba -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\pcode2code.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pcode2code -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\pcodedmp.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pcodedmp -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\rtfdump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command rtfdump.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\rtfobj.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command rtfobj -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\Structured Storage Viewer (SSView).lnk" -DestinationPath "${TOOLS}\ssview\SSView.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\tree.com.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command tree.com /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\xlmdeobfuscator (XLMMacroDeobfuscator can be used to decode obfuscated XLM macros).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command xlmdeobfuscator -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office\zipdump.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command zipdump.py -h"

# Files and apps - PDF
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\PDF" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\Foxit Reader for pdf files (runs dfirws-install -FoxitReader).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -FoxitReader"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\pdf-parser.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pdf-parser.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\pdfalyze.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command venv.ps1 -pdfalyzer ; pdfalyze -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\pdfid.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pdfid.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\pdfstreamdumper install (runs dfirws-install -LibreOffice).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -PDFStreamDumper"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\pdftool.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pdftool.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\peepdf-3 (peepdf - peepdf-3 is a Python 3 tool to explore PDF files).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command peepdf -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\qpdf.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command qpdf.exe --help"

# Files and apps - PE
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\PE" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\4n4lDetector.lnk" -DestinationPath "${env:ProgramFiles}\4n4lDetector\4N4LDetector.exe"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\capa.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\capa\capa.exe" -Arguments "-NoExit -command capa.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\Debloat.lnk" -DestinationPath "${TOOLS}\bin\debloat.exe"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\dll_to_exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\ExeinfoPE.lnk" -DestinationPath "${TOOLS}\ExeinfoPE\exeinfope.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\hachoir-tools.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dir C:\venv\default\Scripts\hachoir-*"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\hollows_hunter (Scans running processes. Recognizes and dumps a variety of in-memory implants).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\bin\hollows_hunter.exe" -Arguments "-NoExit -command hollows_hunter.exe /help"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\pe2pic.ps1.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pe2pic.ps1 -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\PE-bear.lnk" -DestinationPath "${TOOLS}\pebear\PE-bear.exe"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\PE-sieve (Scans a given process, recognizes and dumps a variety of in-memory implants).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\bin\pe-sieve.exe" -Arguments "-NoExit -command pe-sieve.exe /help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\pestudio.lnk" -DestinationPath "${TOOLS}\pestudio\pestudio.exe"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\pescan.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${TOOLS}\pev" -Arguments "-NoExit -command pescan.exe --help"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\readpe - PE Utils.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${TOOLS}\pev" -Arguments "-NoExit -command readpe.exe --help"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\shellconv.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command shellconv.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\WinObjEx64.lnk" -DestinationPath "${TOOLS}\WinObjEx64\WinObjEx64.exe"

# Files and apps - Phone
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Phone" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\aleapp (Android Logs, Events, and Protobuf Parser).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command aleapp.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\aleappGUI.lnk" -DestinationPath "${TOOLS}\bin\aleappGUI.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\ileapp (iOS Logs, Events, And Plists Parser).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ileapp.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\iShutdown_detect.py (sysdiagnose_file.tar.gz).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command iShutdown_detect.py"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\iShutdown_parse.py (A tool to extract and parse iOS shutdown logs from a .tar.gz archive).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command iShutdown_parse.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\iShutdown_stats.py (Process an iOS shutdown.log file to create stats on reboots).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command iShutdown_stats.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\iLEAPPGUI.lnk" -DestinationPath "${TOOLS}\bin\iLEAPPGUI.exe"

# Files and apps - RDP
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\RDP" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\RDP\bmc-tools.py (RDP Bitmap Cache parser).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command bmc-tools.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\RDP\RdpCacheStitcher.lnk" -DestinationPath "${TOOLS}\RdpCacheStitcher\RdpCacheStitcher.exe"

# Forensics
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Forensics" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\Autopsy (runs dfirws-install -Autopsy).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Autopsy"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\venv-dissect.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ${HOME}\Documents\tools\utils\venv.ps1 -Dissect"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\acquire-decrypt.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command acquire-decrypt.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\acquire.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command acquire.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\asdf-dd.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command asdf-dd.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\asdf-meta.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command asdf-meta.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\asdf-repair.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command asdf-repair.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\asdf-verify.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command asdf-verify.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\dump-nskeyedarchiver.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dump-nskeyedarchiver.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\envelope-decrypt.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command envelope-decrypt.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\keyring.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command keyring.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\normalizer.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command normalizer.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\parse-lnk.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command parse-lnk.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\rdump.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command rdump.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\rgeoip.exe (use rgeoip.ps1 if you have maxmind in enrichment- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command rgeoip.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-build-pluginlist.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-build-pluginlist.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-dd.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-dd.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-dump.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-dump.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-fs.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-fs.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-info.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-info.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-mount.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-mount.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-query.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-query.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-reg.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-reg.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-shell.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-shell.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\thumbcache-extract-indexed.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command thumbcache-extract-indexed.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\thumbcache-extract.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command thumbcache-extract.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\venv-binary-refinery.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ${HOME}\Documents\tools\utils\venv.ps1 -binaryrefinery ; binref -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\venv-dissect.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ${HOME}\Documents\tools\utils\venv.ps1 -Dissect"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\vma-extract.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command vma-extract.exe -h"

# Incident response
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\IR" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\Kape (runs dfirws-install -Kape).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Kape"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\Trawler.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Get-Help trawler"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\PersistenceSniper.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Import-Module ${GIT_PATH}\PersistenceSniper\PersistenceSniper\PersistenceSniper.psd1 ; Get-Help -Name Find-AllPersistence"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\PowerSponse.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${GIT_PATH}\PowerSponse" -Arguments "-NoExit -command Import-Module ${GIT_PATH}\PowerSponse\PowerSponse.psd1 ; Get-Help -Name Invoke-PowerSponse"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\White-Phoenix.py (recovers content from files encrypted by Ransomware using intermittent encryption).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command venv.ps1 -whitephoenix ; White-Phoenix.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\velociraptor.exe (Velociraptor is an advanced digital forensic and incident response tool that enhances your visibility into your endpoints).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command velociraptor.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\Shadow-pulse (csv with information about ransomware groups).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command EZViewer.exe ${GIT_PATH}\Shadow-pulse\Ransomlist.csv"

# Malware tools
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Malware tools" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\clamav (runs dfirws-install -ClamAV).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -ClamAV"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\csvkit (tools for working with csv files - venv).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ${HOME}\Documents\tools\utils\venv.ps1 -csvkit"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\maldump.exe (Multi-quarantine extractor).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command maldump.exe -h"

# Malware tools - Cobalt Strike
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Malware tools\Cobalt Strike" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\Cobalt Strike\1768.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command 1768.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\Cobalt Strike\BeaconHunter.lnk" -DestinationPath "${env:ProgramFiles}\BeaconHunter\BeaconHunter.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\Cobalt Strike\CobaltStrikeScan.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command CobaltStrikeScan.exe -h"

# Malware tools - Gootloader
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Malware tools\Gootloader" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\Gootloader\Gootloader (Mandiant).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${GIT_PATH}\gootloader" -Arguments "-NoExit -command dir"

# Memory
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Memory" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Memory\Dokany (runs dfirws-install -Dokany).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Dokany"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Memory\MemProcFS.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command MemProcFS.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Memory\Volatility Workbench 2.1.lnk" -DestinationPath "${TOOLS}\VolatilityWorkbench2\VolatilityWorkbench.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Memory\Volatility Workbench 3.lnk" -DestinationPath "${TOOLS}\VolatilityWorkbench\VolatilityWorkbench.exe"

# Network
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Network" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\Fakenet.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\fakenet\fakenet.exe" -Arguments "-NoExit -command fakenet.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\hfs.exe.lnk" -DestinationPath "${TOOLS}\hfs\hfs.exe" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\ipexpand.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ipexpand.py"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\ngrok.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ngrok.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\openvpn installer.lnk" -DestinationPath "${SETUP_PATH}\openvpn.msi"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\PuTTY (runs dfirws-install -PuTTY).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -PuTTY"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\scapy.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command venv.ps1 -chepy; scapy -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\tailscale installer.lnk" -DestinationPath "${SETUP_PATH}\tailscale.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\wireguard installer.lnk" -DestinationPath "${SETUP_PATH}\wireguard.msi"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\Wireshark (runs dfirws-install -Wireshark).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Wireshark"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\Zui (runs dfirws-install -Zui).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Zui"

# OS
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\OS" | Out-Null

# OS- Android
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\OS\Android" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Android\apktool.bat.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command apktool.bat -h"

# OS - Linux
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\OS\Linux" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Linux\elfparser-ng.lnk" -DestinationPath "${TOOLS}\elfparser-ng\Release\elfparser-ng.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Linux\xelfviewer.lnk" -DestinationPath "${TOOLS}\XELFViewer\xelfviewer.exe"

# OS - macOS
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\OS\macOS" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\macOS\dsstore.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${GIT_PATH}\Python-dsstore" -Arguments "-NoExit -command cat .\README.md"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\macOS\machofile-cli.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command machofile-cli.py -h"

# OS - Windows
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\OS\Windows" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\ese2csv.exe (Find and dump ESE databases).lnk" -DestinationPath "${POWERSHELL_EXE}" -Arguments "-NoExit -command ese2csv.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\fibratus (runs dfirws-install -Fibratus).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Fibratus"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Jumplist-Browser.lnk" -DestinationPath "${TOOLS}\bin\JumplistBrowser.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\lnk2bodyfile (Parse Windows LNK files and create bodyfile output - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command lnk2bodyfile.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Prefetch-Browser.lnk" -DestinationPath "${TOOLS}\bin\PrefetchBrowser.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\procdot.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\sidr (Search Index DB Reporter - handles both ESE (.edb) and SQLite).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command sidr --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Thumbcache Viewer.lnk" -DestinationPath "${TOOLS}\thumbcacheviewer\thumbcache_viewer.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\usnjrnl_dump (Parses Windows UsnJrnl files - dfir-toolkit - janstarke).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command usnjrnl_dump.exe --help"

# OS - Windows - Active Directory (AD)
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\OS\Windows\Active Directory (AD)" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Active Directory (AD)\adalanche (Active Directory ACL Visualizer and Explorer).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command adalanche.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Active Directory (AD)\CimSweep.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${GIT_PATH}\CimSweep" -Arguments "-NoExit -command Import-Module .\CimSweep\CimSweep.psd1"

# OS - Windows - Registry
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\OS\Windows\Registry" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\hivescan (scans a registry hive file for deleted entries - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command hivescan.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\pol_export (Exporter for Windows Registry Policy Files - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pol_export.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\regdump (parses registry hive files and prints a bodyfile - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command regdump.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\regipy-diff.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command regipy-diff.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\regipy-dump.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command regipy-dump.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\regipy-parse-header.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command regipy-parse-header.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\regipy-plugins-list.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command regipy-plugins-list.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\regipy-plugins-run.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command regipy-plugins-run.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\regipy-process-transaction-logs.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command regipy-process-transaction-logs.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\Registry Explorer.lnk" -DestinationPath "${TOOLS}\Zimmerman\net6\RegistryExplorer\RegistryExplorer.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\RegRipper (rip).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command rip.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\RegShot-x64-ANSI.lnk" -DestinationPath "${GIT_PATH}\Regshot\Regshot-x64-ANSI.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\RegShot-x64-Unicode.lnk" -DestinationPath "${GIT_PATH}\Regshot\Regshot-x64-Unicode.exe"

# OSINT
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\OSINT" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OSINT\Maltego (runs dfirws-install -Maltego).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Maltego"

# Programming and Development
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Programming" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\java.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\msys2 (runs dfirws-install -MSYS2).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -MSYS2"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\node.lnk" -DestinationPath "${TOOLS}\node\node.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\perl.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\php.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Python.lnk" -DestinationPath "${VENV}\default\Scripts\python.exe"

# Programming - dotNET
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Programming\dotNET" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\dotNET\dotnetfile_dump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dotnetfile_dump.py -h"

# Programming - Delphi
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Delphi" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Delphi\idr.lnk" -DestinationPath "${env:ProgramFiles}\idr\bin\Idr.exe"

# Programming - Go
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Go" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Go\GoLang (runs dfirws-install -GoLang).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -GoLang"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Go\gftrace.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command gftrace"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Go\GoReSym.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command GoReSym.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Go\Redress.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Redress.exe -h"

# Programming - Java
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Java" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Java\Jadx (runs dfirws-install -Jadx).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Jadx"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Java\jd-gui.lnk" -DestinationPath "${TOOLS}\jd-gui\jd-gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Java\recaf (The modern Java bytecode editor).lnk" -DestinationPath "${TOOLS}\bin\recaf.bat" -Arguments "-NoExit -command recaf.bat" -Iconlocation "${TOOLS}\lib\recaf.jar"

# Programming - Node
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Node" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Node\Node (runs dfirws-install -Node).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Node"

# Programming - PowerShell
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Programming\PowerShell" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\PowerShell\deobshell (main.py).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${GIT_PATH}\deobshell" -Arguments "-NoExit -command .\main.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\PowerShell\PowerDecode.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${GIT_PATH}\PowerDecode" -Arguments "-NoExit -command .\GUI.ps1"

# Programming - Python
New-item -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Python" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Python\pydisasm.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command venv.ps1 -binaryrefinery ; pydisasm --help"

# Programming - Ruby
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Ruby" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Ruby\Ruby (runs dfirws-install -Ruby).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Ruby"

# Programming - Rust
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Rust" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Rust\Rust (runs dfirws-install -Rust).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Rust"

# Reverse Engineering
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Reverse Engineering" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\Binary Ninja (runs dfirws-install -BinaryNinja).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -BinaryNinja"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\Cutter.lnk" -DestinationPath "${TOOLS}\cutter\cutter.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\dnSpy32.lnk" -DestinationPath "${TOOLS}\dnSpy32\dnSpy.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\dnSpy64.lnk" -DestinationPath "${TOOLS}\dnSpy64\dnSpy.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\fasm.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command fasm.exe -h"
(Get-ChildItem "${TOOLS}\ghidra").Name | Where-Object { $_ -match "ghidra_" } | ForEach-Object {
    $VERSION = "$_"
    Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\${VERSION}.lnk" -DestinationPath "${TOOLS}\ghidra\${VERSION}\ghidraRun.bat"
}
if (Test-Path "${VENV}\jep") {
    Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\Ghidrathon (Ghidra with JEP and Ghidrathon).lnk" -DestinationPath "${HOME}\Documents\tools\utils\ghidrathon.bat"
}
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\iaito.lnk" -DestinationPath "${TOOLS}\iaito\iaito.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\ImHex.lnk" -DestinationPath "${TOOLS}\imhex\imhex-gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\Malcat.lnk" -DestinationPath "${env:ProgramFiles}\malcat\bin\malcat.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\radare2.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command radare2 -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\rizin.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command rizin -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\scare.ps1.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command scare.ps1 -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\X64dbg (runs dfirws-install -X64dbg).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -X64dbg"

# Signatures and information
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Signatures and information" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\blyara.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command blyara -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\evt2sigma.ps1 (python package).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command evt2sigma.ps1 -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\loki (runs dfirws-install -Loki).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Loki"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\mkyara.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command mkyara -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\PatchaPalooza.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${GIT_PATH}\PatchaPalooza" -Arguments "-NoExit -command .\PatchaPalooza.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\sigma-cli (This is the Sigma command line interface using the pySigma library to manage, list and convert Sigma rules into query languages).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command sigma.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\WinApiSearch64.lnk" -DestinationPath "${TOOLS}\WinApiSearch\WinApiSearch64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\yara.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command yara.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\yarac.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command yarac.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\yq (is a portable command-line YAML, JSON, XML, CSV, TOML and properties processor).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command yq.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\yr (yara-x).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command yr.exe -h"

# Signatures and information - Online tools
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Signatures and information\Online tools" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\Online tools\bazaar.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command bazaar --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\Online tools\malware-bazaar-advanced-search (search.py).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${GIT_PATH}\malware-bazaar-advanced-search"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\Online tools\shodan.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command shodan"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\Online tools\vt (A command-line tool for interacting with VirusTotal).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command vt help"

# Sysinternals
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Sysinternals" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\accesschk64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command accesschk64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\AccessEnum.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\AccessEnum.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ADExplorer64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\ADExplorer64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ADInsight64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\ADInsight64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\adrestore64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command adrestore64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Autologon64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\Autologon64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Autoruns64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\Autoruns64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\autorunsc64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command autorunsc64.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Bginfo64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Bginfo64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Cacheset64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\Cacheset64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Clockres64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Clockres64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Contig64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Contig64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Coreinfo64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Coreinfo64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\CPUSTRES64.EXE.lnk" -DestinationPath "${TOOLS}\sysinternals\CPUSTRES64.EXE"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ctrl2cap.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ctrl2cap.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\dbgview64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dbgview64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Desktops64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\Desktops64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\disk2vhd64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\disk2vhd64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\diskext64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command diskext64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Diskmon64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\Diskmon64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\DiskView64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\DiskView64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\du64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command du64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\efsdump.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command efsdump.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\FindLinks64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command FindLinks64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\handle64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command handle64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\hex2dec64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command hex2dec64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\junction64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command junction64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ldmdump.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ldmdump.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Listdlls64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Listdlls64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\livekd64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command livekd64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\LoadOrd64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\LoadOrd64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\LoadOrdC64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\logonsessions64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command logonsessions64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\movefile64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command movefile64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\notmyfault64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command notmyfault64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\notmyfaultc64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command notmyfaultc64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ntfsinfo64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ntfsinfo64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\pendmoves64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pendmoves64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\pipelist64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pipelist64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\portmon.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command portmon.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\procdump64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command procdump64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\procexp64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\procexp64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Procmon64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\Procmon64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\PsExec64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command PsExec64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\psfile64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command psfile64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\PsGetsid64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command PsGetsid64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\PsInfo64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command PsInfo64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\pskill64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pskill64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\pslist64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pslist64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\PsLoggedon64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command PsLoggedon64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\psloglist64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command psloglist64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\pspasswd64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pspasswd64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\psping64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command psping64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\PsService64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command PsService64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\psshutdown64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command psshutdown64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\pssuspend64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pssuspend64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\RAMMap64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command RAMMap64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\RDCMan.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\RDCMan.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\RegDelNull64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command RegDelNull64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Reghide.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\regjump.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command regjump.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\RootkitRevealer.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ru64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ru64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\sdelete64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command sdelete64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ShareEnum64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\ShareEnum64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ShellRunas.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ShellRunas.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\sigcheck64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command sigcheck64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\streams64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command streams64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\strings64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command strings64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\sync64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command sync64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Sysmon64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Sysmon64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\tcpvcon64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command tcpvcon64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\tcpview64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\tcpview64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Testlimit64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Testlimit64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\vmmap64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command vmmap64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Volumeid64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Volumeid64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\whois64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command whois64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Winobj64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\Winobj64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ZoomIt64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\ZoomIt64.exe"

# Utilities
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Utilities" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\7-Zip.lnk" -DestinationPath "${env:ProgramFiles}\7-Zip\7zFM.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\bash (Git-version).lnk" -DestinationPath "${env:ProgramFiles}\Git\bin\bash.exe" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\cmder (runs dfirws-install -Cmder).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Cmder"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\DCode (runs dfirws-install -DCode).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -DCode"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Docker (runs dfirws-install.ps1 -Docker).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Docker"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\exiftool.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\exiftool\exiftool.exe" -Arguments "-NoExit -command exiftool --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\floss.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\floss\floss.exe" -Arguments "-NoExit -command floss --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\git.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${env:ProgramFiles}\Git\cmd\git-gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Graphviz.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dot -?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\jpterm (Jupyter in the terminal).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command jpterm --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\jupyter notebook.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command ${HOME}\Documents\tools\utils\jupyter.bat"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\mmdbinspect (Tool for GeoIP lookup).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command mmdbinspect --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\pwncat.py (Fancy reverse and bind shell handler).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pwncat.py --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\pygmentize.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pygmentize --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\rexi.exe (Terminal UI for Regex Testing).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command rexi.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\tabby.lnk" -DestinationPath "${TOOLS}\tabby\Tabby.exe" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\tabby\Tabby.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\time-decode.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command time-decode --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\upx.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command upx"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\visidata (VisiData or vd is an interactive multitool for tabular data).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command visidata --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\zstd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command zstd -h"

# Utilities - _dfirws
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Utilities\_dfirws" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\_dfirws\dfirws-install.ps1.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Get-Help dfirws-install.ps1"

# Utilities - Browsers
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Utilities\Browsers" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Browsers\Chrome (runs dfirws-install -Chrome).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Chrome"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Browsers\Firefox (runs dfirws-install -Firefox).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Firefox"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Browsers\Tor Browser (runs dfirws-install -Tor).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Tor"

# Utilities - Crypto
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Utilities\Crypto" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\ares.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ares --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\chepy.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command venv.ps1 -chepy ; chepy -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\CyberChef.lnk" -DestinationPath "${TOOLS}\CyberChef\CyberChef.html"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\gpg4win (runs dfirws-install -Gpg4win).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Gpg4win"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\hash-id.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command hash-id.py"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\hashcat (runs dfirws-install -Hashcat).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Hashcat"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\name-that-hash (also available as nth).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command name-that-hash --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\openssl.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command openssl --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\protodump.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command protodump --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\sigs.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command sigs.py --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\veracrypt (runs dfirws-install -Veracrypt).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Veracrypt"

# Utilities - CTF
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Utilities\CTF" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\CTF\HiddenWave (and ExWave).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${GIT_PATH}\HiddenWave" -Arguments "-NoExit -command dir"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\CTF\stegolsb.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command stegolsb --help"

# Utilities - Media
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Utilities\Media" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Media\Audacity.lnk" -DestinationPath "${TOOLS}\Audacity\audacity.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Media\ffmpeg.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ffmpeg --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Media\VLC (runs dfirws-install -VLC).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -VLC"

# Zimmerman
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Zimmerman" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\AmcacheParser.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\AmcacheParser.exe" -Arguments "-NoExit -command AmcacheParser.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\AppCompatCacheParser.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\AppCompatCacheParser.exe" -Arguments "-NoExit -command AppCompatCacheParser.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\bstrings.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\bstrings.exe" -Arguments "-NoExit -command bstrings.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\EvtxECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\EvtxECmd\EvtxECmd.exe" -Arguments "-NoExit -command EvtxECmd.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\EZViewer.lnk" -DestinationPath "${TOOLS}\Zimmerman\net6\EZViewer\EZViewer.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\iisGeolocate.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${env:ProgramFiles}\iisGeolocate\iisGeolocate.exe" -Arguments "-NoExit -command iisGeolocate.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\JLECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\JLECmd.exe" -Arguments "-NoExit -command JLECmd.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\LECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\LECmd.exe" -Arguments "-NoExit -command LECmd.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\MFTECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\MFTECmd.exe" -Arguments "-NoExit -command MFTECmd.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\PECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\PECmd.exe" -Arguments "-NoExit -command PECmd.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\RBCmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\RBCmd.exe" -Arguments "-NoExit -command RBCmd.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\RecentFileCacheParser.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\RecentFileCacheParser.exe" -Arguments "-NoExit -command RecentFileCacheParser.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\RegistryExplorer.lnk" -DestinationPath "${env:ProgramFiles}\RegistryExplorer\RegistryExplorer.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\rla.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\rla.exe" -Arguments "-NoExit -command rla.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\SBECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\SBECmd.exe" -Arguments "-NoExit -command SBECmd.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\ShellBagsExplorer.lnk" -DestinationPath "${env:ProgramFiles}\ShellBagsExplorer\ShellBagsExplorer.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\SrumECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\SrumECmd.exe" -Arguments "-NoExit -command SrumECmd.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\SumECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\SumECmd.exe" -Arguments "-NoExit -command SumECmd.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\TimeApp.lnk" -DestinationPath "${TOOLS}\Zimmerman\TimeApp.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\TimelineExplorer.lnk" -DestinationPath "${env:ProgramFiles}\TimelineExplorer\TimelineExplorer.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\VSCMount.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\VSCMount.exe" -Arguments "-NoExit -command VSCMount.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\WxTCmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\net6\WxTCmd.exe" -Arguments "-NoExit -command WxTCmd.exe -h"

Write-DateLog "Creating shortcuts in ${HOME}\Desktop\dfirws done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Pin to explorer
$shell = new-object -com "Shell.Application"
$folder = ${shell}.Namespace("${HOME}\Desktop")
$item = ${folder}.Parsename('dfirws')
$verb = ${item}.Verbs() | Where-Object { $_.Name -like 'Pin to *Quick access' }
if ("${verb}") {
    ${verb}.DoIt()
}
Write-DateLog "Pinning ${HOME}\Desktop\dfirws to explorer done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
