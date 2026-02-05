# Set default encoding to UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"
. "C:\Users\WDAGUtilityAccount\Documents\tools\shared.ps1"

$TOOL_DEFINITIONS = @()

if (! (Test-Path "${WSDFIR_TEMP}")) {
    New-Item -ItemType Directory -Force -Path "${WSDFIR_TEMP}" | Out-Null
}

Write-Output "Install Golang tools."
Write-DateLog "Install Golang tools in Sandbox." >> "C:\log\golang.txt"

Write-Output "Get-Content C:\log\golang.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

Write-DateLog "Install Git (in the background)." >> "C:\log\golang.txt"
Install-Git 2>&1 | ForEach-Object{ "$_" } >> "C:\log\golang.txt"
Write-DateLog "Install Golang." >> "C:\log\golang.txt"
Install-GoLang 2>&1 | ForEach-Object{ "$_" } >> "C:\log\golang.txt"
$env:PATH="${env:ProgramFiles}\Go\bin;${env:ProgramFiles}\Git\bin;${env:ProgramFiles}\Git\usr\bin;${env:PATH}"

Write-DateLog "Golang: Install protodump in sandbox." >> "C:\log\golang.txt"
go install github.com/arkadiyt/protodump/cmd/protodump@latest 2>&1 | ForEach-Object{ "$_" } >> "C:\log\golang.txt"

$TOOL_DEFINITIONS += @{
    Name = "protodump"
    Homepage = "https://github.com/arkadiyt/protodump"
    Vendor = "arkadiyt"
    License = "Unknown"
    Category = "Utilities\Cryptography"
    Shortcuts = @(    
         @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Cryptography\protodump.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command protodump --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "`${HOME}\go\bin\protodump.exe"
            Expect = "PE32"
        }
    )
    Notes = "Protodump is a tool to extract protobuf messages from binary files without having the .proto schema files."
    Tips = "Protodump can be used to analyze and extract protobuf messages from various binary formats, making it useful for reverse engineering and forensic analysis."
    Usage = "Protodump is a command-line tool that extracts protobuf messages from binary files."
    SampleCommands = @(
        "protodump --help"
        "protodump -f input_file.bin"
    )
    SampleFiles = @(
        "N/A"
    )
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "go"

Write-DateLog "Golang: Done installing Golang based tools in sandbox." >> "C:\log\golang.txt"

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > "C:\Users\WDAGUtilityAccount\go\done"
