. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

${ROOT_PATH} = "${PWD}"

# Download the Zimmerman tools and sync their maps in a sandbox, since running --sync needs the
# .NET 10 runtime and we don't want to require it on the host. dotnet10desktop.exe is downloaded by basic.ps1.
# KAPE is updated in the same sandbox if local\kape.zip exists, since its updater also runs the EZ Tools.
if (Test-Path -Path "${ROOT_PATH}\downloads\dotnet10desktop.exe") {
    Write-DateLog "Start Sandbox to download Zimmerman tools." > "${ROOT_PATH}\log\zimmerman.txt"

    $kapeMapping = "<!-- KAPE not used, local\kape.zip not found -->"
    if (Test-Path -Path "${ROOT_PATH}\local\kape.zip") {
        if (! (Test-Path -Path "${SETUP_PATH}\KAPE")) {
            & $SEVENZIP x -aoa "${ROOT_PATH}\local\kape.zip" -o"${SETUP_PATH}" | Out-Null
        }
        if (Test-Path -Path "${SETUP_PATH}\KAPE\Get-KAPEUpdate.ps1") {
            Remove-Item "${SETUP_PATH}\KAPE\Get-KAPEUpdate.ps1" -Force
        }
        Copy-Item "${ROOT_PATH}\resources\external\KAPE-EZToolsAncillaryUpdater.ps1" "${SETUP_PATH}\KAPE\KAPE-EZToolsAncillaryUpdater.ps1" -Force
        Copy-Item "${ROOT_PATH}\resources\download\Get-ZimmermanTools.ps1" "${SETUP_PATH}\KAPE\Get-ZimmermanTools.ps1" -Force
        $kapeMapping = "<MappedFolder><HostFolder>__SANDBOX__downloads\KAPE</HostFolder><SandboxFolder>C:\KAPE</SandboxFolder><ReadOnly>false</ReadOnly></MappedFolder>"
    }

    if (! (Test-Path -Path "${ROOT_PATH}\tmp\zimmerman")) {
        New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\tmp\zimmerman" | Out-Null
    } elseif (Test-Path -Path "${ROOT_PATH}\tmp\zimmerman\done") {
        Remove-Item "${ROOT_PATH}\tmp\zimmerman\done" | Out-Null
    }

    (Get-Content "${ROOT_PATH}\resources\templates\generate_zimmerman.wsb.template").replace("<!-- __KAPE__ -->", $kapeMapping).replace("__SANDBOX__", "${ROOT_PATH}\") | Set-Content "${ROOT_PATH}\tmp\generate_zimmerman.wsb"
    Start-Process "${ROOT_PATH}\tmp\generate_zimmerman.wsb"
    Wait-Sandbox -WSBPath "${ROOT_PATH}\tmp\generate_zimmerman.wsb" -WaitForPath "${ROOT_PATH}\tmp\zimmerman\done"

    Remove-Item -Recurse -Force "${ROOT_PATH}\tmp\zimmerman" 2>&1 | Out-Null
    Write-DateLog "Zimmerman tools done." >> "${ROOT_PATH}\log\zimmerman.txt"
} else {
    Write-SynchronizedLog "Error: ${ROOT_PATH}\downloads\dotnet10desktop.exe not found, it should have been downloaded by basic.ps1. Skipping Zimmerman tools."
}

$TOOL_DEFINITIONS += @{
    Name = "Zimmerman Tools"
    Homepage = "https://github.com/EricZimmerman?tab=repositories"
    Vendor = "Eric Zimmerman"
    License = "MIT License"
    Category = "Forensics\Zimmerman"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\AmcacheParser.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command AmcacheParser.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\AmcacheParser.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\AppCompatCacheParser.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command AppCompatCacheParser.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\AppCompatCacheParser.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\RegistryExplorer.lnk"
            Target   = "`${env:ProgramFiles}\RegistryExplorer\RegistryExplorer.exe"
            Args     = ""
            Icon     = "`${TOOLS}\Zimmerman\RegistryExplorer\RegistryExplorer.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\SDBExplorer.lnk"
            Target   = "`${env:ProgramFiles}\SDBExplorer\SDBExplorer.exe"
            Args     = ""
            Icon     = "`${TOOLS}\Zimmerman\SDBExplorer\SDBExplorer.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\bstrings.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command bstrings.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\bstrings.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
         @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\EvtxECmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command EvtxECmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\EvtxECmd\EvtxECmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\EZViewer.lnk"
            Target   = "`${TOOLS}\Zimmerman\EZViewer\EZViewer.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\iisGeolocate.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command iisGeolocate.exe -h"
            Icon     = "`${env:ProgramFiles}\iisGeolocate\iisGeolocate.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\JLECmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command JLECmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\JLECmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\JumpListExplorer.lnk"
            Target   = "`${TOOLS}\Zimmerman\JumpListExplorer\JumpListExplorer.exe"
            Args     = ""
            Icon     = "`${TOOLS}\Zimmerman\JumpListExplorer\JumpListExplorer.exe"
            WorkDir  = "`${HOME}\Desktop"

        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\MFTExplorer.lnk"
            Target   = "`${TOOLS}\Zimmerman\MFTExplorer\MFTExplorer.exe"
            Args     = ""
            Icon     = "`${TOOLS}\Zimmerman\MFTExplorer\MFTExplorer.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\LECmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command LECmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\LECmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\RECmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command RBCmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\RBCmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\MFTECmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command MFTECmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\MFTECmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\PECmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command PECmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\PECmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\RBCmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command RBCmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\RBCmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\RecentFileCacheParser.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command RecentFileCacheParser.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\RecentFileCacheParser.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\rla.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command rla.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\rla.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\SBECmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command SBECmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\SBECmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\SQLECmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command SQLECmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\SQLECmd\SQLECmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\ShellBagsExplorer.lnk"
            Target   = "`${env:ProgramFiles}\ShellBagsExplorer\ShellBagsExplorer.exe"
            Args     = ""
            Icon     = "`${env:ProgramFiles}\ShellBagsExplorer\ShellBagsExplorer.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\SrumECmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command SrumECmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\SrumECmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\SumECmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command SumECmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\SumECmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\TimelineExplorer.lnk"
            Target   = "`${env:ProgramFiles}\TimelineExplorer\TimelineExplorer.exe"
            Args     = ""
            Icon     = "`${env:ProgramFiles}\TimelineExplorer\TimelineExplorer.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\VSCMount.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command VSCMount.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\VSCMount.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\WxTCmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command WxTCmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\WxTCmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\AmcacheParser.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\AppCompatCacheParser.exe"
            Expect = "PE32"
        }
         @{
            Type = "command"
            Name = "`${env:ProgramFiles}\RegistryExplorer\RegistryExplorer.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\bstrings.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\EvtxeCmd\EvtxECmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\EZViewer\EZViewer.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${env:ProgramFiles}\iisGeolocate\iisGeolocate.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\JLECmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\LECmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\MFTECmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\PECmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\RBCmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\RecentFileCacheParser.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\rla.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\SBECmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${env:ProgramFiles}\ShellBagsExplorer\ShellBagsExplorer.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\SrumECmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\SumECmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${env:ProgramFiles}\TimelineExplorer\TimelineExplorer.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\VSCMount.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\WxTCmd.exe"
            Expect = "PE32"
        }
    )
    Notes = "Zimmerman Tools is a collection of Windows forensics tools developed by Eric Zimmerman."
    Tips = "Zimmerman Tools includes a variety of tools for analyzing Windows artifacts, such as the registry, event logs, and more."
    Usage = "Zimmerman Tools is a collection of command-line and GUI tools for Windows forensics analysis."
    SampleCommands = @(
        "AmcacheParser.exe -h",
        "AppCompatCacheParser.exe -h",
        "bstrings.exe -h",
        "EvtxECmd.exe -h",
        "JLECmd.exe -h",
        "LECmd.exe -h",
        "MFTECmd.exe -h",
        "PECmd.exe -h",
        "RBCmd.exe -h",
        "RecentFileCacheParser.exe -h",
        "rla.exe -h",
        "SBECmd.exe -h",
        "SrumECmd.exe -h",
        "SumECmd.exe -h",
        "VSCMount.exe -h",
        "WxTCmd.exe -h"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @("dotnet9", "dotnet10")
    LicenseUrl = ""
    Tags = @()
    FileExtensions = @()
    PythonVersion = ""
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "zimmerman"
