# Install and update kape if kape.zip is present

. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

if (test-path .\local\kape.zip) {
    Write-DateLog "kape.zip found. Will add and update Kape for dfirws."
} else {
    Write-DateLog "kape.zip not found. Will not add or update Kape for dfirws."
    Write-dateLog "If you want to add Kape place your copy of kape.zip in the local directory."
    Exit
}

if (! (Test-Path -Path "$SETUP_PATH\KAPE" )) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa ".\local\kape.zip" -o"$SETUP_PATH" | Out-Null
    if (Test-Path "$SETUP_PATH\Get-KAPEUpdate.ps1") {
        Remove-Item "$SETUP_PATH\Get-KAPEUpdate.ps1"  -Force
    }
}

$CURRENT_DIR = $PWD
Copy-Item ".\resources\external\KAPE-EZToolsAncillaryUpdater.ps1" "$SETUP_PATH\KAPE\KAPE-EZToolsAncillaryUpdater.ps1" -Force
Set-Location "$SETUP_PATH\KAPE"
& .\KAPE-EZToolsAncillaryUpdater.ps1 -silent -net 6 *> $CURRENT_DIR\log\kape.txt
Set-Location $CURRENT_DIR

$TOOL_DEFINITIONS += @{
    Name = "KAPE"
    Homepage = "https://www.kroll.com/en/insights/publications/cyber/kroll-artifact-parser-extractor-kape"
    Vendor = "Kroll"
    License = "Commercial"
    Category = "IR"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\IR\gkape.lnk"
            Target   = "`${env:ProgramFiles}\KAPE\gkape.exe"
            Args     = ""
            Icon     = "`${env:ProgramFiles}\KAPE\gkape.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\IR\kape (Krolls Artifact Parser and Extractor).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command kape --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Kape"
    Verify = @(
        @{
            Type = "command"
            Name = "`${env:ProgramFiles}\KAPE\gkape.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("forensics", "incident-response", "artifact-collection", "triage")
    Notes = "Kroll Artifact Parser and Extractor (KAPE) is an efficient and highly configurable triage program that will target essentially any device or storage location, find forensically useful artifacts, and parse them within a few minutes."
    Tips = ""
    Usage = ""
    SampleCommands = @(
        "kape --help"
    )
    SampleFiles = @()
    Dependencies = @()
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "kape"
