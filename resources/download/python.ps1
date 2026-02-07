. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

$ROOT_PATH = "${PWD}"

Write-DateLog "Start Sandbox to install Python packages for dfirws." > "${ROOT_PATH}\log\python.txt"

if (! (Test-Path "${ROOT_PATH}\mount\Tools\bin\uv.exe")) {
    Write-Output "ERROR: uv.exe not found. Exiting" >> "${ROOT_PATH}\log\python.txt"
    Exit
}

if (Test-Path -Path "${ROOT_PATH}\mount\venv\") {
    Get-ChildItem -Path "${ROOT_PATH}\mount\venv\" -Directory | Where-Object { $_.Name -ne "cache" } | Remove-Item -Recurse -Force | Out-Null
}
New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\venv" | Out-Null

(Get-Content ${ROOT_PATH}\resources\templates\generate_venv.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}\") | Set-Content "${ROOT_PATH}\tmp\generate_venv.wsb"
Start-Process "${ROOT_PATH}\tmp\generate_venv.wsb"
Wait-Sandbox -WSBPath "${ROOT_PATH}\tmp\generate_venv.wsb" -WaitForPath "${ROOT_PATH}\mount\venv\default\done"

Copy-Item "${ROOT_PATH}\setup\utils\hash-id.py" "${ROOT_PATH}\mount\Tools\bin\"
Copy-Item "${ROOT_PATH}\setup\utils\ipexpand.py" "${ROOT_PATH}\mount\Tools\bin\"
Copy-Item "${ROOT_PATH}\setup\utils\powershell-cleanup.py" "${ROOT_PATH}\mount\Tools\bin\"

# Fix shebang lines in Python scripts
Get-ChildItem -Path "${ROOT_PATH}\mount\venv\default\Scripts","${ROOT_PATH}\mount\venv\bin","${ROOT_PATH}\mount\Tools\bin" -Filter *.py | ForEach-Object {
    ${content} = Get-Content $_.FullName
    if (${content}[0] -match "^#!/usr/bin/python" -or ${content}[0] -match "^#!/usr/bin/env python3") {
        ${content} -replace '^#!/usr/bin/.*', '#!/usr/bin/env python' | Set-Content $_.FullName
    }
}

# Add .py extension to all files in bin directory that don't have an extension
Get-ChildItem -Exclude *.* .\mount\venv\bin\ | ForEach-Object { Move-Item "$_" "$_.py" }

Write-DateLog "Pip packages done." >> "${ROOT_PATH}\log\python.txt"

#
# Tool definitions for documentation generation.
# Fill in the dfirws-specific fields below. Auto-extracted metadata (Homepage,
# Vendor, License) comes from the PyPI API via extract-tool-metadata.py.
#

$TOOL_DEFINITIONS += @{
    Name = "dfir_ntfs"
    Category = "Files and apps\Disk"
    Shortcuts = @("Files and apps\Disk\ntfs_parser.py (Extract information from NTFS metadata files, volumes, and shadow copies)", "Files and apps\Disk\fat_parser.py (Extract information from FAT files)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\ntfs_parser.py Python", "C:\venv\bin\fat_parser.py Python")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "binary-refinery"
    Category = "Forensics"
    Shortcuts = @("Forensics\binary-refinery")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\binref.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "regipy"
    Category = "OS\Windows\Registry"
    Shortcuts = @("OS\Windows\Registry\regipy-diff", "OS\Windows\Registry\regipy-dump")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\uv\regipy\Scripts\evtx_dump.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "peepdf-3"
    Category = "Files and apps\PDF"
    Shortcuts = @("Files and apps\PDF\peepdf-3 (peepdf - peepdf-3 is a Python 3 tool to explore PDF files)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\peepdf.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "mkdocs"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "autoit-ripper"
    Category = "Files and apps"
    Shortcuts = @("Files and apps\autoit-ripper")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\autoit-ripper.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "cart"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\cart.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "chepy"
    Category = "Utilities\Cryptography"
    Shortcuts = @("Utilities\Cryptography\chepy")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\chepy.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "csvkit"
    Category = "Malware tools"
    Shortcuts = @("Malware tools\csvkit (tools for working with csv files)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\csvclean.exe PE32", "C:\venv\bin\csvcut.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "deep_translator"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\deep-translator.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "docx2txt"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\docx2txt.py Python")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "extract-msg"
    Category = "Files and apps\Email"
    Shortcuts = @("Files and apps\Email\extract_msg")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\extract_msg.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "flatten_json"
    Category = "Files and apps\Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\flatten_json.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "frida-tools"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\frida.exe PE32", "C:\venv\bin\frida-apk.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "ghidrecomp"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\ghidrecomp.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "ghidriff"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\ghidriff.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "grip"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\grip.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "hachoir"
    Category = "Files and apps\PE"
    Shortcuts = @("Files and apps\PE\hachoir-tools")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\hachoir-wx.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "jpterm"
    Category = "Utilities"
    Shortcuts = @("Utilities\jpterm (Jupyter in the terminal)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\jpterm.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "jsbeautifier"
    Category = "Files and apps\JavaScript"
    Shortcuts = @("Files and apps\JavaScript\js-beautify (Javascript beautifier)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\js-beautify.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "jupyterlab"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\uv\jupyterlab\Scripts\jupyter.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "litecli"
    Category = "Files and apps\Database"
    Shortcuts = @("Files and apps\Database\litecli (SQLite CLI with autocompletion and syntax highlighting)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\litecli.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "LnkParse3"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\lnkparse.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "magika"
    Category = "Files and apps"
    Shortcuts = @("Files and apps\magika (A tool like file and file-magic based on AI)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\magika.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "maldump"
    Category = "Malware tools"
    Shortcuts = @("Malware tools\maldump.exe (Multi-quarantine extractor)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\maldump.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "malwarebazaar"
    Category = "Signatures and information\Online tools"
    Shortcuts = @("Signatures and information\Online tools\bazaar")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\bazaar.exe PE32", "C:\venv\bin\yaraify.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "markitdown"
    Category = "Utilities"
    Shortcuts = @("Utilities\markitdown (Python tool for converting files and office documents to Markdown)")
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "minidump"
    Category = "Memory"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\minidump.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "mkyara"
    Category = "Signatures and information"
    Shortcuts = @("Signatures and information\mkyara")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\mkyara.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "msoffcrypto-tool"
    Category = "Files and apps\Office"
    Shortcuts = @("Files and apps\Office\msoffcrypto-tool")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\msoffcrypto-tool.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "mwcp"
    Category = "Malware tools"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\mwcp.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "name-that-hash"
    Category = "Utilities\Cryptography"
    Shortcuts = @("Utilities\Cryptography\name-that-hash (also available as nth)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\name-that-hash.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "netaddr"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\netaddr.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "numpy"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "oletools"
    Category = "Files and apps\Office"
    Shortcuts = @("Files and apps\Office\oleid", "Files and apps\Office\olevba", "Files and apps\Office\mraptor", "Files and apps\Office\msodde")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\oleid.exe PE32", "C:\venv\bin\olevba.exe PE32", "C:\venv\bin\mraptor.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pcode2code"
    Category = "Files and apps\Office"
    Shortcuts = @("Files and apps\Office\pcode2code")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\pcode2code.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pdfalyzer"
    Category = "Files and apps\PDF"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "protodeep"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\protodeep.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "ptpython"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\ptpython.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pwncat"
    Category = "Utilities"
    Shortcuts = @("Utilities\pwncat.py (Fancy reverse and bind shell handler)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\pwncat.py Python")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pyghidra"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pyOneNote"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\pyonenote.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pypng"
    Category = "Utilities\CTF"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\priweavepng.py Python")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "rexi"
    Category = "Utilities"
    Shortcuts = @("Utilities\rexi.exe (Terminal UI for Regex Testing)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\rexi.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "scapy"
    Category = "Network"
    Shortcuts = @("Network\scapy")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\scapy.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "shodan"
    Category = "Signatures and information\Online tools"
    Shortcuts = @("Signatures and information\Online tools\shodan")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\shodan.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "stego-lsb"
    Category = "Utilities\CTF"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "sqlit-tui"
    Category = "Files and apps\Database"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "time-decode"
    Category = "Utilities"
    Shortcuts = @("Utilities\time-decode")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\time-decode.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "toolong"
    Category = "Files and apps\Log"
    Shortcuts = @("Files and apps\Log\toolong (tl - A terminal application to view, tail, merge, and search log files)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\tl.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "unpy2exe"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\unpy2exe.py Python")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "visidata"
    Category = "Utilities"
    Shortcuts = @("Utilities\visidata (VisiData or vd is an interactive multitool for tabular data)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\visidata.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "xlrd"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\runxlrd.py Python")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "XLMMacroDeobfuscator"
    Category = "Files and apps\Office"
    Shortcuts = @("Files and apps\Office\xlmdeobfuscator (XLMMacroDeobfuscator can be used to decode obfuscated XLM macros)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\bin\xlmdeobfuscator.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "XlsxWriter"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "acquire"
    Category = "Forensics"
    Shortcuts = @("Forensics\acquire.exe (dissect)", "Forensics\acquire-decrypt.exe (dissect)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\default\Scripts\acquire.exe PE32", "C:\venv\default\Scripts\acquire-decrypt.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "aiodns"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "aiohttp"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Aspose.Email-for-Python-via-Net"
    Category = "Files and apps\Email"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "BeautifulSoup4"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "bitstruct"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "compressed_rtf"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "dissect"
    Category = "Forensics"
    Shortcuts = @("Forensics\rdump.exe (dissect)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\default\Scripts\rdump.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "dissect.target"
    Category = "Forensics"
    Shortcuts = @("Forensics\target-query.exe (dissect)", "Forensics\target-shell.exe (dissect)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\default\Scripts\target-shell.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "dnslib"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "flow.record"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "geoip2"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "cabarchive"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "dotnetfile"
    Category = "Programming\dotNET"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "dpkt"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "elasticsearch"
    Category = "Files and apps\Database"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "evtx"
    Category = "Files and apps\Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "graphviz"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "javaobj-py3"
    Category = "Programming\Java"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "keystone-engine"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "lief"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "matplotlib"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "msticpy"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "neo4j"
    Category = "Files and apps\Database"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "networkx"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "olefile"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(""C:\venv\bin\olefile.exe" PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "openpyxl"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "orjson"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "paramiko"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pathlab"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pefile"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "peutils"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pfp"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "ppdeep"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "prettytable"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pyasn1"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pycares"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pycryptodome"
    Category = "Utilities\Cryptography"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pydivert"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pypdf"
    Category = "Files and apps\PDF"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pyshark"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "PySocks"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "python-docx"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "python-dotenv"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "python-magic"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "python-registry"
    Category = "OS\Windows\Registry"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pyvis"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pyzipper"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "requests"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "rzpipe"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "sigma-cli"
    Category = "Signatures and information"
    Shortcuts = @("Signatures and information\sigma-cli (This is the Sigma command line interface)")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\default\Scripts\sigma.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pysigma-backend-elasticsearch"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pySigma-backend-loki"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pysigma-backend-splunk"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pysigma-backend-sqlite"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pysigma-pipeline-sysmon"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pysigma-pipeline-windows"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "simplejson"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "termcolor"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "textsearch"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "tomlkit"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "treelib"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "unicorn"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "xxhash"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "yara-python"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "dfir-unfurl"
    Category = "Files and apps\Browser"
    Shortcuts = @("Files and apps\Browser\unfurl_app.exe (unfurl takes a URL and expands it into a directed graph - dfir-unfurl)", "Files and apps\Browser\unfurl.exe")
    InstallVerifyCommand = ""
    Verify = @("C:\venv\dfir-unfurl\Scripts\unfurl.exe PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "hexdump"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "maclookup"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "python"