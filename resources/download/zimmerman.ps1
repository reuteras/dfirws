. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

# Download and update Zimmerman tools.
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File .\resources\download\Get-ZimmermanTools.ps1 -Dest ".\mount\Tools\Zimmerman" 2>&1 >> ".\log\log.txt"
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File .\resources\download\Sync-EZTools.ps1 ".\mount\Tools\Zimmerman" 2>&1 >> ".\log\log.txt"

$TOOL_DEFINITIONS += @{
    Name = "Zimmerman Tools"
    Homepage = "https://github.com/EricZimmerman?tab=repositories"
    Vendor = "Eric Zimmerman"
    License = "MIT License"
    Category = "Zimmerman"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\AmcacheParser.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command AmcacheParser.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\net6\AmcacheParser.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\AppCompatCacheParser.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command AppCompatCacheParser.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\net6\AppCompatCacheParser.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\RegistryExplorer.lnk"
            Target   = "`${env:ProgramFiles}\RegistryExplorer\RegistryExplorer.exe"
            Args     = ""
            Icon     = "`${TOOLS}\Zimmerman\net6\RegistryExplorer.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\bstrings.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command bstrings.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\net6\bstrings.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
         @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\EvtxECmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command EvtxECmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\net6\EvtxECmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\EZViewer.lnk"
            Target   = "`${TOOLS}\Zimmerman\net6\EZViewer.exe"
            Args     = ""
            Icon     = "`${TOOLS}\Zimmerman\net6\EZViewer.exe"
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
            Icon     = "`${TOOLS}\Zimmerman\net6\JLECmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\LECmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command LECmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\net6\LECmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\MFTECmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command MFTECmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\net6\MFTECmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\PECmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command PECmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\net6\PECmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\RBCmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command RBCmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\net6\RBCmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\RecentFileCacheParser.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command RecentFileCacheParser.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\net6\RecentFileCacheParser.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\rla.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command rla.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\net6\rla.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\SBECmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command SBECmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\net6\SBECmd.exe"
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
            Icon     = "`${TOOLS}\Zimmerman\net6\SrumECmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\SumECmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command SumECmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\net6\SumECmd.exe"
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
            Icon     = "`${TOOLS}\Zimmerman\net6\VSCMount.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Zimmerman\WxTCmd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command WxTCmd.exe -h"
            Icon     = "`${TOOLS}\Zimmerman\net6\WxTCmd.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\net6\AmcacheParser.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\net6\AppCompatCacheParser.exe"
            Expect = "PE32"
        }
         @{
            Type = "command"
            Name = "`${env:ProgramFiles}\RegistryExplorer\RegistryExplorer.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\net6\bstrings.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\net6\EvtxeCmd\EvtxECmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\net6\EZViewer\EZViewer.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${env:ProgramFiles}\iisGeolocate\iisGeolocate.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\net6\JLECmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\net6\LECmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\net6\MFTECmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\net6\PECmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\net6\RBCmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\net6\RecentFileCacheParser.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\net6\rla.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\net6\SBECmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${env:ProgramFiles}\ShellBagsExplorer\ShellBagsExplorer.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\net6\SrumECmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\net6\SumECmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\TimeApp.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${env:ProgramFiles}\TimelineExplorer\TimelineExplorer.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\net6\VSCMount.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\Zimmerman\net6\WxTCmd.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${env:ProgramFiles}\RegistryExplorer\RegistryExplorer.exe"
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
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "zimmerman"