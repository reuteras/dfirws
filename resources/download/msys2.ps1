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

# Ensure git directory exists for sandbox mapping (may contain r2ai source)
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
            Name = "msys2"
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
    )
    FileExtensions = @()
    Tags = @("build-environment", "shell", "linux-tools", "gcc", "debugging")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}
