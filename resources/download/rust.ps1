. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

$ROOT_PATH = "${PWD}"

Write-DateLog "Start Sandbox to install Rust based tools for dfirws." > "${ROOT_PATH}\log\rust.txt"

# Requires gcc to compile
${CURRENT_VERSION_DFIR_TOOLKIT} = (curl --silent -L "https://crates.io/api/v1/crates/dfir-toolkit" | ConvertFrom-Json).crate.max_stable_version
${CURRENT_VERSION_CUTE_TUI} = (curl --silent -L "https://crates.io/api/v1/crates/cute-tui" | ConvertFrom-Json).crate.max_stable_version
${CURRENT_VERSION_MFT2BODYFILE} = (curl --silent -L "https://crates.io/api/v1/crates/mft2bodyfile" | ConvertFrom-Json).crate.max_stable_version
${CURRENT_VERSION_USNJRNL} = (curl --silent -L "https://crates.io/api/v1/crates/usnjrnl" | ConvertFrom-Json).crate.max_stable_version
${STATUS} = $true

if (Test-Path -Path "${ROOT_PATH}\mount\Tools\cargo\.crates.toml" ) {
    ${STATUS} = (Get-Content "${ROOT_PATH}\mount\Tools\cargo\.crates.toml" | Select-String -Pattern "dfir-toolkit ${CURRENT_VERSION_DFIR_TOOLKIT}").Matches.Success
    if (${STATUS}) {
        ${STATUS} = (Get-Content "${ROOT_PATH}\mount\Tools\cargo\.crates.toml" | Select-String -Pattern "CuTE-tui ${CURRENT_VERSION_CUTE_TUI}").Matches.Success
    }
    if (${STATUS}) {
        ${STATUS} = (Get-Content "${ROOT_PATH}\mount\Tools\cargo\.crates.toml" | Select-String -Pattern "mft2bodyfile ${CURRENT_VERSION_MFT2BODYFILE}").Matches.Success
    }
    if (${STATUS}) {
        ${STATUS} = (Get-Content "${ROOT_PATH}\mount\Tools\cargo\.crates.toml" | Select-String -Pattern "usnjrnl ${CURRENT_VERSION_USNJRNL}").Matches.Success
    }
} else {
    ${STATUS} = $false
}

if (! ${STATUS}) {
    if (! (Test-Path -Path "${ROOT_PATH}\tmp\cargo" )) {
        New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\tmp\cargo" | Out-Null
    } elseif (Test-Path -Path "${ROOT_PATH}\tmp\cargo\done" ) {
        Remove-Item "${ROOT_PATH}\tmp\cargo\done" | Out-Null
    }

    if (Test-Path -Path "${ROOT_PATH}\mount\Tools\cargo" ) {
        Remove-Item -r -Force "${ROOT_PATH}\mount\Tools\cargo" | Out-Null
    }
    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\Tools\cargo" | Out-Null

    (Get-Content "${ROOT_PATH}\resources\templates\generate_rust.wsb.template").replace("__SANDBOX__", "${ROOT_PATH}\") | Set-Content "${ROOT_PATH}\tmp\generate_rust.wsb"
    Start-Process "${ROOT_PATH}\tmp\generate_rust.wsb"
    Wait-Sandbox -WSBPath "${ROOT_PATH}\tmp\generate_rust.wsb" -WaitForPath "${ROOT_PATH}\tmp\cargo\done"

    rclone.exe sync --verbose --checksum "${ROOT_PATH}\tmp\cargo" "${ROOT_PATH}\mount\Tools\cargo" >> "${ROOT_PATH}\log\rust.txt" 2>&1
    Remove-Item -Recurse -Force "${ROOT_PATH}\tmp\cargo" 2>&1 | Out-Null

    Write-DateLog "Rust tools done." >> "${ROOT_PATH}\log\rust.txt"
} else {
    Write-DateLog "Rust tools already installed and up to date." >> "${ROOT_PATH}\log\rust.txt"
}

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
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Disk\mft2bodyfile (parses an MFT file (and optionally the corresponding UsnJrnl) to bodyfile - dfir-toolkit - janstarke).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command mft2bodyfile.exe --help"
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
}

$TOOL_DEFINITIONS += @{
    Name = "mft2bodyfile"
    Category = "Files and apps\Disk"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Disk\mft2bodyfile (parses an MFT file (and optionally the corresponding UsnJrnl) to bodyfile - dfir-toolkit - janstarke).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command mft2bodyfile.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Rust"
    Verify = @(
        @{
            Type = "command"
            Name = "mft2bodyfile"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".mft")
    Tags = @("filesystem", "forensics", "ntfs", "bodyfile")
    Notes = "The mft2bodyfile tool is a command-line utility for parsing Master File Table (MFT) files from NTFS file systems and optionally the corresponding USN Journal to create bodyfile output. The bodyfile format is commonly used in digital forensics for timeline analysis. This tool can help investigators extract valuable information about files and directories from MFT records, such as file names, timestamps, and metadata."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
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
}
