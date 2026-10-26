# Create metadata for KAPE if kape.zip is present. KAPE is extracted and updated in the
# Zimmerman sandbox by zimmerman.ps1.

. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

if (test-path .\local\kape.zip) {
    Write-DateLog "kape.zip found. Will add and update Kape for dfirws."
} else {
    Write-DateLog "kape.zip not found. Will not add or update Kape for dfirws."
    Write-dateLog "If you want to add Kape place your copy of kape.zip in the local directory."
    Exit
}

$TOOL_DEFINITIONS += @{
    Name = "KAPE"
    Homepage = "https://www.kroll.com/en/insights/publications/cyber/kroll-artifact-parser-extractor-kape"
    Vendor = "Kroll"
    License = "Commercial"
    Category = "Incident Response"
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
    Tags = @("forensics", "incident-response", "acquisition", "artifact-extraction", "triage")
    Notes = "Kroll Artifact Parser and Extractor (KAPE) is an efficient and highly configurable triage program that will target essentially any device or storage location, find forensically useful artifacts, and parse them within a few minutes."
    Tips = "KAPE is only included when you place kape.zip in the local folder. Use gkape for the GUI, --module to run parsers on a collection and --mdest for module output. Targets and modules are updated separately from the binary."
    Usage = "kape --tsource C: --tdest <destination> --target !SANS_Triage"
    SampleCommands = @(
        "kape --help"
    )
    SampleFiles = @()
    Dependencies = @()
    LicenseUrl = ""
    PythonVersion = ""
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "kape"
