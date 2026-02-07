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
    Category = ""
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
    Name = "binary-refinery"
    Category = ""
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
    Name = "regipy"
    Category = ""
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
    Name = "peepdf-3"
    Category = ""
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
    Name = "mkdocs"
    Category = ""
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
    Category = ""
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
    Name = "cart"
    Category = ""
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
    Name = "chepy"
    Category = ""
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
    Name = "csvkit"
    Category = ""
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
    Name = "deep_translator"
    Category = ""
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
    Name = "docx2txt"
    Category = ""
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
    Name = "extract-msg"
    Category = ""
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
    Name = "flatten_json"
    Category = ""
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
    Name = "frida-tools"
    Category = ""
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
    Name = "ghidrecomp"
    Category = ""
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
    Name = "ghidriff"
    Category = ""
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
    Name = "grip"
    Category = ""
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
    Name = "hachoir"
    Category = ""
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
    Name = "jpterm"
    Category = ""
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
    Name = "jsbeautifier"
    Category = ""
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
    Name = "jupyterlab"
    Category = ""
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
    Name = "litecli"
    Category = ""
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
    Name = "LnkParse3"
    Category = ""
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
    Name = "magika"
    Category = ""
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
    Name = "maldump"
    Category = ""
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
    Name = "malwarebazaar"
    Category = ""
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
    Name = "markitdown"
    Category = ""
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
    Name = "minidump"
    Category = ""
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
    Name = "mkyara"
    Category = ""
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
    Name = "msoffcrypto-tool"
    Category = ""
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
    Name = "mwcp"
    Category = ""
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
    Name = "name-that-hash"
    Category = ""
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
    Name = "netaddr"
    Category = ""
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
    Name = "numpy"
    Category = ""
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
    Category = ""
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
    Name = "pcode2code"
    Category = ""
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
    Name = "pdfalyzer"
    Category = ""
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
    Category = ""
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
    Name = "ptpython"
    Category = ""
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
    Name = "pwncat"
    Category = ""
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
    Name = "pyghidra"
    Category = ""
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
    Category = ""
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
    Name = "pypng"
    Category = ""
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
    Name = "rexi"
    Category = ""
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
    Name = "scapy"
    Category = ""
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
    Name = "shodan"
    Category = ""
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
    Name = "stego-lsb"
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Name = "toolong"
    Category = ""
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
    Name = "unpy2exe"
    Category = ""
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
    Name = "visidata"
    Category = ""
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
    Name = "xlrd"
    Category = ""
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
    Name = "XLMMacroDeobfuscator"
    Category = ""
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
    Name = "XlsxWriter"
    Category = ""
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
    Category = ""
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
    Name = "aiodns"
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Name = "dissect.target"
    Category = ""
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
    Name = "dnslib"
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Name = "openpyxl"
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Name = "pysigma-backend-elasticsearch"
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Category = ""
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
    Name = "hexdump"
    Category = ""
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
    Category = ""
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