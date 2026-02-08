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
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Disk\ntfs_parser.py (Extract information from NTFS metadata files, volumes, and shadow copies).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command ntfs_parser.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Disk\fat_parser.py (Extract information from FAT files).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command fat_parser.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\ntfs_parser.py"
            Expect = "Python"
        }
        @{
            Type = "command"
            Name = "C:\venv\bin\fat_parser.py"
            Expect = "Python"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "binary-refinery"
    Category = "Forensics"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Forensics\binary-refinery.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command binref -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\binref.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "regipy"
    Category = "OS\Windows\Registry"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Registry\regipy-diff.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command regipy-diff.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Registry\regipy-dump.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command regipy-dump.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\uv\regipy\Scripts\evtx_dump.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "peepdf-3"
    Category = "Files and apps\PDF"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PDF\peepdf-3 (peepdf - peepdf-3 is a Python 3 tool to explore PDF files).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command peepdf -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\peepdf.exe"
            Expect = "PE32"
        }
    )
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
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\autoit-ripper.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command autoit-ripper -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\autoit-ripper.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\cart.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "chepy"
    Category = "Utilities\Cryptography"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Cryptography\chepy.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\chepy.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "csvkit"
    Category = "Malware tools"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Malware tools\csvkit (tools for working with csv files).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command csv --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\csvclean.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\venv\bin\csvcut.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\deep-translator.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\docx2txt.py"
            Expect = "Python"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "extract-msg"
    Category = "Files and apps\Email"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Email\extract_msg.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command extract_msg -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\extract_msg.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\flatten_json.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\frida.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\venv\bin\frida-apk.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\ghidrecomp.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\ghidriff.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\grip.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "hachoir"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\hachoir-tools.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dir C:\venv\bin\hachoir-*"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\hachoir-wx.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "jpterm"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\jpterm (Jupyter in the terminal).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command jpterm --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\jpterm.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "jsbeautifier"
    Category = "Files and apps\JavaScript"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\JavaScript\js-beautify (Javascript beautifier).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command js-beautify --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\js-beautify.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\uv\jupyterlab\Scripts\jupyter.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "litecli"
    Category = "Files and apps\Database"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Database\litecli (SQLite CLI with autocompletion and syntax highlighting).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command litecli --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\litecli.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\lnkparse.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "magika"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\magika (A tool like file and file-magic based on AI).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command magika -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\magika.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "maldump"
    Category = "Malware tools"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Malware tools\maldump.exe (Multi-quarantine extractor).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command maldump.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\maldump.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "malwarebazaar"
    Category = "Signatures and information\Online tools"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\Online tools\bazaar.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command bazaar --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\bazaar.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\venv\bin\yaraify.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "markitdown"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\markitdown (Python tool for converting files and office documents to Markdown).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command markitdown --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\minidump.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "mkyara"
    Category = "Signatures and information"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\mkyara.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command mkyara -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\mkyara.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "msoffcrypto-tool"
    Category = "Files and apps\Office"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\msoffcrypto-tool.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command msoffcrypto-tool -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\msoffcrypto-tool.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\mwcp.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "name-that-hash"
    Category = "Utilities\Cryptography"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Cryptography\name-that-hash (also available as nth).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\name-that-hash.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\netaddr.exe"
            Expect = "PE32"
        }
    )
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
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\oleid.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command oleid -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\olevba.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command olevba -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\mraptor.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command mraptor -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\msodde.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command msodde -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\oleid.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\venv\bin\olevba.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\venv\bin\mraptor.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pcode2code"
    Category = "Files and apps\Office"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\pcode2code.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pcode2code -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\pcode2code.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\protodeep.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\ptpython.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "pwncat"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\pwncat.py (Fancy reverse and bind shell handler).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pwncat.py --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\pwncat.py"
            Expect = "Python"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\pyonenote.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\priweavepng.py"
            Expect = "Python"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "rexi"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\rexi.exe (Terminal UI for Regex Testing).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command rexi.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\rexi.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "scapy"
    Category = "Network"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Network\scapy.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command scapy -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\scapy.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "shodan"
    Category = "Signatures and information\Online tools"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\Online tools\shodan.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command shodan"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\shodan.exe"
            Expect = "PE32"
        }
    )
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
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\time-decode.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command time-decode --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\time-decode.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "toolong"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\toolong (tl - A terminal application to view, tail, merge, and search log files (plus JSONL)).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command tl.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\tl.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\unpy2exe.py"
            Expect = "Python"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "visidata"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\visidata (VisiData or vd is an interactive multitool for tabular data).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command visidata --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\visidata.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\runxlrd.py"
            Expect = "Python"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "XLMMacroDeobfuscator"
    Category = "Files and apps\Office"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\xlmdeobfuscator (XLMMacroDeobfuscator can be used to decode obfuscated XLM macros).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command xlmdeobfuscator -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\xlmdeobfuscator.exe"
            Expect = "PE32"
        }
    )
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
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Forensics\acquire.exe (dissect).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command acquire.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Forensics\acquire-decrypt.exe (dissect).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command acquire-decrypt.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\default\Scripts\acquire.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\venv\default\Scripts\acquire-decrypt.exe"
            Expect = "PE32"
        }
    )
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
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Forensics\rdump.exe (dissect).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command rdump.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\default\Scripts\rdump.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "dissect.target"
    Category = "Forensics"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Forensics\target-query.exe (dissect).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command target-query.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Forensics\target-shell.exe (dissect).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command target-shell.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\default\Scripts\target-shell.exe"
            Expect = "PE32"
        }
    )
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
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\olefile.exe"
            Expect = "PE32"
        }
    )
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
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\sigma-cli (This is the Sigma command line interface using the pySigma library to manage, list and convert Sigma rules into query languages).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command sigma.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\default\Scripts\sigma.exe"
            Expect = "PE32"
        }
    )
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
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Browser\unfurl_app.exe (unfurl takes a URL and expands it into a directed graph - dfir-unfurl).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command C:\venv\dfir-unfurl\Scripts\unfurl_app.exe"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Browser\unfurl.exe (unfurl takes a URL and expands it into a directed graph - dfir-unfurl).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command C:\venv\dfir-unfurl\Scripts\unfurl.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\dfir-unfurl\Scripts\unfurl.exe"
            Expect = "PE32"
        }
    )
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