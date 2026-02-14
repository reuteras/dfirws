# Set default encoding to UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"
. "C:\Users\WDAGUtilityAccount\Documents\tools\shared.ps1"

$TOOL_DEFINITIONS = @()

Write-Output "Install Rust tools in Sandbox."

if (! (Test-Path "${WSDFIR_TEMP}")) {
    New-Item -ItemType Directory -Force -Path "${WSDFIR_TEMP}" | Out-Null
}
if (!(Test-Path "C:\cargo\autocomplete")) {
    New-Item -ItemType Directory -Force -Path "C:\cargo\autocomplete" | Out-Null
}

Write-Output "Get-Content C:\log\rust.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

Write-DateLog "Install Git (in the background)." >> "C:\log\rust.txt"
Install-Git >> "C:\log\rust.txt"
Write-DateLog "Install Rust." >> "C:\log\rust.txt"
Install-Rust >> "C:\log\rust.txt"

$env:CC  = "C:\Tools\msys64\ucrt64\bin\gcc.exe"
$env:CXX = "C:\Tools\msys64\ucrt64\bin\g++.exe"
$env:AR  = "C:\Tools\msys64\ucrt64\bin\ar.exe"

# Set PATH to include Rust and Git
$env:PATH="${RUST_DIR}\bin;${env:ProgramFiles}\Git\bin;${env:ProgramFiles}\Git\usr\bin;${env:PATH};"
$env:Path = "C:\Tools\msys64\ucrt64\bin;C:\Tools\msys64\usr\bin;$env:Path"
$env:PATH="${env:PATH};C:\cargo\bin;" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install Rust tools
Write-Output "Rust: Install dfir-toolkit in sandbox."
Write-DateLog "Rust: Install dfir-toolkit in sandbox." >> "C:\log\rust.txt"
cargo install --root "C:\cargo" "dfir-toolkit" 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"

(Get-ChildItem "C:\cargo\bin").Name | ForEach-Object { & "$_" --autocomplete powershell > "C:\cargo\autocomplete\$_.ps1"} 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"

Write-Output "Rust: Install usnjrnl in sandbox."
Write-DateLog "Rust: Install usnjrnl in sandbox." >> "C:\log\rust.txt"
cargo install --root "C:\cargo" usnjrnl 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"

Write-Output "Rust: Install CuTE-tui in sandbox."
Write-DateLog "Rust: Install CuTE-tui in sandbox." >> "C:\log\rust.txt"
cargo install --root "C:\cargo" CuTE-tui 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"

Write-Output "Rust: Install SSHniff in sandbox."
Write-DateLog "Rust: Install SSHniff in sandbox." >> "C:\log\rust.txt"
Set-Location "C:\tmp"
git clone https://github.com/CrzPhil/SSHniff.git 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"
Set-Location "C:\tmp\SSHniff\sshniff"
cargo build --release 2>&1 | ForEach-Object { "$_" } >> "C:\log\rust.txt"
Copy-Item ".\target\release\sshniff.exe" "C:\cargo\bin\sshniff.exe"

Write-DateLog "Rust: Done installing Rust based tools in sandbox." >> "C:\log\rust.txt"

$TOOL_DEFINITIONS += @{
    Name = "dfir-toolkit"
    Category = "Forensics"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\cleanhive (merges logfiles into a hive file - dfir-toolkit).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command cleanhive.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\evtvenv x2bodyfile (creates bodyfile from Windows evtx files - dfir-toolkit).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command evtx2bodyfile.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\evtxanalyze (crate provide functions to analyze evtx files - dfir-toolkit).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command evtxanalyze.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\evtxcat (Display one or more events from an evtx file - dfir-toolkit).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command evtxcat.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\evtxls (Display one or more events from an evtx file - dfir-toolkit).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command evtxls.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\evtxscan (Find time skews in an evtx file - dfir-toolkit).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command evtxscan.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\ipgrep (search for IP addresses in text files - dfir-toolkit).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command ipgrep.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\pf2bodyfile.exe (creates bodyfile from Windows Prefetch files - dfir-toolkit).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pf2bodyfile.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Disk\mactime2 (replacement for mactime - dfir-toolkit).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command mactime2.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\lnk2bodyfile (Parse Windows LNK files and create bodyfile output - dfir-toolkit).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command lnk2bodyfile.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Registry\pol_export (Exporter for Windows Registry Policy Files - dfir-toolkit).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pol_export.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Registry\regdump (parses registry hive files and prints a bodyfile - dfir-toolkit).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command regdump.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Rust"
    Verify = @(
        @{
            Type = "command"
            Name = "cleanhive"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "evtx2bodyfile"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "evtxanalyze"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "evtxcat"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "evtxls"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "evtxscan"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "hivescan"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "ipgrep"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "lnk2bodyfile"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "mactime2"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "pf2bodyfile"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "pol_export"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "regdump"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "ts2date"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "zip2bodyfile"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".evtx", ".reg", ".dat", ".lnk", ".pf", ".mft", ".zip")
    Tags = @("forensics", "timeline", "log-analysis", "event-log", "registry", "bodyfile")
    Notes = "The dfir-toolkit is a collection of command-line tools for digital forensics and incident response (DFIR) tasks. It includes various utilities for analyzing log files, registry hives, MFT files, and other artifacts commonly encountered in DFIR investigations."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("msys2")
}

$TOOL_DEFINITIONS += @{
    Name = "usnjrnl"
    Category = "OS\Windows"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\usnjrnl_dump (Parses Windows UsnJrnl files - dfir-toolkit - janstarke).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command usnjrnl_dump.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Rust"
    Verify = @(
        @{
            Type = "command"
            Name = "usnjrnl_dump"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".bin")
    Tags = @("filesystem", "forensics", "ntfs", "windows")
    Notes = "The usnjrnl tool is a command-line utility for parsing Windows UsnJrnl files. It allows you to extract and analyze information from the USN Journal, which is a feature of the NTFS file system that tracks changes to files and directories. This tool can be useful for forensic investigations and understanding file system activity."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("msys2")
}

$TOOL_DEFINITIONS += @{
    Name = "CuTE-tui"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -Rust"
    Verify = @(
        @{
            Type = "command"
            Name = "cute"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("tui", "http", "network")
    Notes = "CuTE-tui is a terminal user interface (TUI) tool for making HTTP requests and analyzing responses. It provides a user-friendly interface for crafting and sending HTTP requests, as well as viewing and analyzing the responses. This tool can be useful for testing APIs, debugging web applications, and performing various HTTP-related tasks from the command line."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("msys2")
}

$TOOL_DEFINITIONS += @{
    Name = "SSHniff"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -Rust"
    Verify = @(
        @{
            Type = "command"
            Name = "sshniff"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".pcap", ".pcapng")
    Tags = @("network-analysis", "ssh", "pcap")
    Notes = "SSHniff is a command-line tool for capturing and analyzing SSH network traffic. It can be used to monitor and inspect SSH sessions, helping in forensic analysis of network communications."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("msys2")
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "rust"

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > "C:\cargo\done"
