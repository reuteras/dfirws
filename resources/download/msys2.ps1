. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

$ROOT_PATH = "${PWD}"

Write-DateLog "Setup MSYS2 and install packages in Sandbox." > ${ROOT_PATH}\log\msys2.txt

# Create install directory for MSYS2
if (! (Test-Path -Path "${ROOT_PATH}\mount\Tools\msys64" )) {
    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\Tools\msys64" | Out-Null
} elseif (Test-Path -Path "${ROOT_PATH}\mount\Tools\msys64\done") {
    Remove-Item "${ROOT_PATH}\mount\Tools\msys64\done" | Out-Null
}

# Ensure git directory exists for sandbox mapping
if (! (Test-Path -Path "${ROOT_PATH}\mount\git" )) {
    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\git" | Out-Null
}

# Create WSB file for MSYS2 and run it
(Get-Content ${ROOT_PATH}\resources\templates\generate_msys2.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}\") | Set-Content "${ROOT_PATH}\tmp\generate_msys2.wsb"
Start-Process "${ROOT_PATH}\tmp\generate_msys2.wsb"
Wait-Sandbox -WSBPath "${ROOT_PATH}\tmp\generate_msys2.wsb" -WaitForPath "${ROOT_PATH}\mount\Tools\msys64\done"

# Change tmp directory
Write-Output "C:/tmp/msys2 /tmp ntfs auto 0 0" >> "${ROOT_PATH}\mount\Tools\msys64\etc\fstab"

Write-DateLog "MSYS2 and packages done." >> ${ROOT_PATH}\log\msys2.txt 2>&1

$TOOL_DEFINITIONS += @{
    Name = "MSYS2"
    Category = "Programming"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\msys64\msys2.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "bash"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "gcc"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "gdb"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\Tools\msys64\usr\bin\msys-2.0.dll"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("shell", "linux", "debugging")
    Notes = "MSYS2 is a collection of tools and libraries providing you with an easy-to-use environment for building, installing and running native Windows software."
    Tips = "Provides gcc, cmake, make, git and Unix utilities. The ucrt64\bin and usr\bin directories are on PATH in the sandbox so gcc and bash work directly from PowerShell. Not included in the Basic profile."
    Usage = "bash -lc '<command>' or start the MSYS2 UCRT64 shell"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

# Built from source in the MSYS2 sandbox by setup\install\install_msys2.ps1.
$TOOL_DEFINITIONS += @{
    Name = "pycdc"
    Category = "Reverse Engineering"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Reverse Engineering\pycdc (Python bytecode decompiler, pycdas disassembler).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pycdc --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "pycdc.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "pycdas.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".pyc", ".pyo")
    Tags = @("decompiler", "reverse-engineering", "python")
    Notes = "pycdc (Decompyle++) is a C++ decompiler and disassembler for Python bytecode covering Python 1.0 through 3.13. pycdc produces Python source, pycdas a bytecode listing."
    Tips = "Use pycdc on the .pyc files produced by pyinstxtractor-ng. When decompilation of newer bytecode fails, pycdas still gives a readable disassembly. Only available when the MSYS2 build sandbox is enabled in the profile."
    Usage = "pycdc file.pyc"
    SampleCommands = @(
        "pycdc file.pyc",
        "pycdas file.pyc"
    )
    SampleFiles = @()
    Dependencies = @("msys2")
    Homepage = "https://github.com/zrax/pycdc"
    Vendor = "Michael Hansen (zrax)"
    License = "GNU General Public License v3.0"
    LicenseUrl = "https://github.com/zrax/pycdc/blob/master/LICENSE"
    PythonVersion = ""
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "msys2"
