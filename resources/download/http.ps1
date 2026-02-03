param(
    [Parameter(HelpMessage = "Don't update Visual Studio Code Extensions via http.")]
    [Switch]$NoVSCodeExtensions
)

. ".\resources\download\common.ps1"

$TOOL_DEFINITIONS = @()

if (! $NoVSCodeExtensions.IsPresent) {
    # Get URI for Visual Studio Code C++ extension - ugly
    $vscode_cpp_string = Get-DownloadUrlFromPage -url "https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools" -RegEx '"AssetUri":"[^"]+ms-vscode.cpptools/([^/]+)/'

    if ("$vscode_cpp_string" -ne "") {
        $vscode_tmp = $vscode_cpp_string | Select-String -Pattern '"AssetUri":"[^"]+ms-vscode.cpptools/([^/]+)/'
        $vscode_cpp_version = $vscode_tmp.Matches.Groups[1].Value
        # Visual Studio Code C++ extension
        $status = Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/cpptools/$vscode_cpp_version/vspackage?targetPlatform=win32-x64" -FilePath ".\downloads\vscode\vscode-cpp.vsix" -CheckURL "Yes" -check "Zip archive data"
    } else {
        Write-DateLog "ERROR: Could not get URI for Visual Studio Code C++ extension"
    }
    # Get URI for Visual Studio Code python extension - ugly
    $vscode_python_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=ms-python.python -RegEx '"AssetUri":"[^"]+python/([^/]+)/'

    if ("$vscode_python_string" -ne "") {
        $vscode_tmp = $vscode_python_string | Select-String -Pattern '"AssetUri":"[^"]+python/([^/]+)/'
        $vscode_python_version = $vscode_tmp.Matches.Groups[1].Value
        # Visual Studio Code python extension
        $status = Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/python/$vscode_python_version/vspackage" -FilePath ".\downloads\vscode\vscode-python.vsix" -CheckURL "Yes" -check "Zip archive data"
    } else {
        Write-DateLog "ERROR: Could not get URI for Visual Studio Code python extension"
    }

    # Get URI for Visual Studio Code mermaid extension - ugly
    $vscode_mermaid_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid -RegEx '"AssetUri":"[^"]+markdown-mermaid/([^/]+)/'

    if ("$vscode_mermaid_string" -ne "") {
        $vscode_tmp = $vscode_mermaid_string | Select-String -Pattern '"AssetUri":"[^"]+markdown-mermaid/([^/]+)/'
        $vscode_mermaid_version = $vscode_tmp.Matches.Groups[1].Value
        # Visual Studio Code mermaid extension
        $status = Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/bierner/vsextensions/markdown-mermaid/$vscode_mermaid_version/vspackage" -FilePath ".\downloads\vscode\vscode-mermaid.vsix" -CheckURL "Yes" -check "Zip archive data"
    } else {
        Write-DateLog "ERROR: Could not get URI for Visual Studio Code mermaid extension"
    }

    # Get URI for Visual Studio Code ruff extension - ugly
    $vscode_ruff_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=charliermarsh.ruff -RegEx '"AssetUri":"[^"]+charliermarsh.ruff/([^/]+)/'

    if ("$vscode_ruff_string" -ne "") {
        $vscode_tmp = $vscode_ruff_string | Select-String -Pattern '"AssetUri":"[^"]+charliermarsh.ruff/([^/]+)/'
        $vscode_ruff_version = $vscode_tmp.Matches.Groups[1].Value
        # Visual Studio Code ruff extension
        $status = Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/charliermarsh/vsextensions/ruff/$vscode_ruff_version/vspackage" -FilePath ".\downloads\vscode\vscode-ruff.vsix" -CheckURL "Yes" -check "Zip archive data"
    } else {
        Write-DateLog "ERROR: Could not get URI for Visual Studio Code ruff extension"
    }
}

# Get Visual Studio Code installer
$status = Get-FileFromUri -uri "https://update.code.visualstudio.com/latest/win32-x64-user/stable" -FilePath ".\downloads\vscode.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "Visual Studio Code"
    Homepage = "https://code.visualstudio.com/"
    Vendor = "Microsoft"
    License = "Microsoft Software License Terms"
    LicenseUrl = "https://code.visualstudio.com/License"
    Category = "Editors"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Editors\Visual Studio code (runs dfirws-install -VSCode).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -VSCode"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -VSCode"
    Verify = @(
        @{
            Type = "command"
            Name = "code.exe"
            Expect = "DOS"
        }
    )
    Notes = "Visual Studio Code is a source-code editor."
    Tips = "After installation, you can add more extensions via Visual Studio Code Marketplace."
    Usage = "Visual Studio Code is a source-code editor made by Microsoft for Windows, Linux and macOS. It includes support for debugging, embedded Git control, syntax highlighting, intelligent code completion, snippets, and code refactoring."
    SampleCommands = @(
        "code ."
        "code --install-extension ms-vscode.cpptools"
    )
    SampleFiles = @(
        "N/A"
    )
}

# Get SwiftOnSecurity sysmon config - used from Sysmon
$status = Get-FileFromUri -uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -FilePath ".\downloads\sysmonconfig-export.xml" -check "ASCII text"

# Get Sysinternals Suite
$status = Get-FileFromUri -uri "https://download.sysinternals.com/files/SysinternalsSuite.zip" -FilePath ".\downloads\sysinternals.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\sysinternals") {
        Remove-Item -Recurse -Force "${TOOLS}\sysinternals" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\sysinternals.zip" -o"${TOOLS}\sysinternals" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "Sysinternals Suite"
    Homepage = "https://docs.microsoft.com/en-us/sysinternals/"
    Vendor = "Microsoft"
    License = "Sysinternals Software License Terms"
    LicenseUrl = "https://docs.microsoft.com/en-us/sysinternals/license-terms"
    Category = "Sysinternals"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\accesschk64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command accesschk64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\AccessEnum.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\AccessEnum.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\ADExplorer64.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\ADExplorer64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\ADInsight64.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\ADInsight64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\adrestore64.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\adrestore64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\Autologon64.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\Autologon64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\Autoruns64.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\Autoruns64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\autorunsc64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command autorunsc64.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\Bginfo64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command Bginfo64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\CacheSet64.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\CacheSet64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\Contig64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command Contig64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\Coreinfo64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command Coreinfo64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\Ctrl2cap.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command Ctrl2cap.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\CPUSTRES64.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\CPUSTRES64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\DebugView64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command DebugView64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\Desktops64.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\Desktops64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\disk2vhd64.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\disk2vhd64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\DiskExt64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command diskext64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\DiskMon64.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\DiskMon64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\DiskView64.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\DiskView64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\du64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command du64.exe /?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\EfsInfo64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command EfsInfo64.exe /?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\FindLinks64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command FindLinks64.exe /?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\Handle64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command Handle64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\Hex2dec64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command Hex2dec64.exe /?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\junction64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command junction64.exe /?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\ldmdump.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command ldmdump.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\listdlls64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command listdlls64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\LiveKd64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command LiveKd64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\LoadOrd64.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\LoadOrd64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\LoadOrdC64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command LoadOrdC64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\LogonSessions64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command LogonSessions64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\MoveFile64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command MoveFile64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\notmyfault64.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\notmyfault64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\notmyfaultc64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command notmyfaultc64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\ntfsinfo64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command ntfsinfo64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\PendMoves64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command PendMoves64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\pipelist64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pipelist64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\portmon.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command portmon.exe /?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\ProcDump64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command procdump64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\ProcessExplorer.lnk"
            Target   = "`${TOOLS}\sysinternals\procexp64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\ProcessMonitor.lnk"
            Target   = "`${TOOLS}\sysinternals\procmon64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\PsExec64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command PsExec64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\PsFile64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command psfile64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\PsGetsid64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command PsGetsid64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\PsInfo64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command PsInfo64.exe"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\pskill64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pskill64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\pslist64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pslist64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\PsLoggedon64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command PsLoggedon64.exe /?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\PsLogList64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command psloglist64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\PsPasswd64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pspasswd64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\PsPing64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command psping64.exe /?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\PsService64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command PsService64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\psshutdown64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command psshutdown64.exe /?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\pssuspend64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pssuspend64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\RAMMap64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command RAMMap64.exe /?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\RDCMan.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\RDCMan.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\RegDelNull64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command RegDelNull64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\Reghide.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command Reghide.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\RegJump.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command regjump.exe /?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\RootkitRevealer.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\RootkitRevealer.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\ru64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command ru64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\SDelete64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command sdelete64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\ShareEnum64.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\ShareEnum64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\ShellRunas.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command ShellRunas.exe /?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\sigcheck64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command sigcheck64.exe /?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\streams64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command streams64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\strings64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command strings64.exe /?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\Sync64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command sync64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\Sysmon64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command Sysmon64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\tcpvcon64.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command tcpvcon64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\TCPView64.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\TCPView64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\Testlimit64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command Testlimit64.exe /?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\vmmap64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command vmmap64.exe /?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\Volumeid64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command Volumeid64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\whois64.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command whois64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\WinObj64.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\Winobj64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\ZoomIt64.exe.lnk"
            Target   = "`${TOOLS}\sysinternals\ZoomIt64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "accesschk64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "AccessEnum.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "ADExplorer64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "ADInsight64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "adrestore64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "Autologon64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "Autoruns64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "autorunsc64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "Bginfo64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "CacheSet64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "Contig64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "Coreinfo64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "Ctrl2cap.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "CPUSTRES64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "DebugView64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "Desktops64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "disk2vhd64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "DiskExt64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "DiskMon64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "DiskView64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "du64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "EfsInfo64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "FindLinks64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "Handle64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "Hex2dec64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "junction64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "ldmdump.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "listdlls64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "LiveKd64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "LoadOrd64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "LoadOrdC64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "LogonSessions64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "MoveFile64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "notmyfault64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "notmyfaultc64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "ntfsinfo64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "PendMoves64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "pipelist64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "portmon.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "ProcDump64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "ProcessExplorer.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "ProcessMonitor.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "PsExec64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "PsFile64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "PsGetsid64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "PsInfo64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "pskill64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "pslist64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "PsLoggedon64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "PsLogList64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "PsPasswd64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "PsPing64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "PsService64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "psshutdown64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "pssuspend64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "RAMMap64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "RDCMan.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "RegDelNull64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "Reghide.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "RegJump.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "RootkitRevealer.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "ru64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "SDelete64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "ShareEnum64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "ShellRunas.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "sigcheck64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "streams64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "strings64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "Sync64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "Sysmon64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "tcpvcon64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "TCPView64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "Testlimit64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "vmmap64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "Volumeid64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "whois64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "WinObj64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "ZoomIt64.exe"
            Expect = "PE32"
        }
    )
    Notes = "Sysinternals Suite is a collection of utilities for Windows."
    Tips = "Sysinternals Suite is installed in ${TOOLS}\sysinternals."
    Usage = "Sysinternals Suite is a collection of utilities for Windows. It includes tools for process management, file system analysis, network monitoring, and more."
    SampleCommands = @(
        "accesschk64.exe"
        "AccessEnum.exe"
        "ADExplorer64.exe"
        "ADInsight64.exe"
        "adrestore64.exe"
        "Autologon64.exe"
        "Autoruns64.exe"
        "autorunsc64.exe"
        "Bginfo64.exe"
        "CacheSet64.exe"
        "Contig64.exe"
        "Coreinfo64.exe"
        "Ctrl2cap.exe"
        "CPUSTRES64.exe"
        "DebugView64.exe"
        "Desktops64.exe"
        "disk2vhd64.exe"
        "DiskExt64.exe"
        "DiskMon64.exe"
        "DiskView64.exe"
        "du64.exe"
        "EfsInfo64.exe"
        "FindLinks64.exe"
        "Handle64.exe"
        "Hex2dec64.exe"
        "junction64.exe"
        "ldmdump.exe"
        "listdlls64.exe"
        "LiveKd64.exe"
        "LoadOrd64.exe"
        "LoadOrdC64.exe"
        "LogonSessions64.exe"
        "MoveFile64.exe"
        "notmyfault64.exe"
        "notmyfaultc64.exe"
        "ntfsinfo64.exe"
        "PendMoves64.exe"
        "pipelist64.exe"
        "portmon.exe"
        "ProcDump64.exe"
        "ProcessExplorer.exe"
        "ProcessMonitor.exe"
        "PsExec64.exe"
        "PsFile64.exe"
        "PsGetsid64.exe"
        "PsInfo64.exe"
        "pskill64.exe"
        "pslist64.exe"
        "PsLoggedon64.exe"
        "PsLogList64.exe"
        "PsPasswd64.exe"
        "PsPing64.exe"
        "PsService64.exe"
        "psshutdown64.exe"
        "pssuspend64.exe"
        "RAMMap64.exe"
        "RDCMan.exe"
        "RegDelNull64.exe"
        "Reghide.exe"
        "RegJump.exe"
        "RootkitRevealer.exe"
        "ru64.exe"
        "SDelete64.exe"
        "ShareEnum64.exe"
        "ShellRunas.exe"
        "sigcheck64.exe"
        "streams64.exe"
        "strings64.exe"
        "Sync64.exe"
        "Sysmon64.exe"
        "tcpvcon64.exe"
        "TCPView64.exe"
        "Testlimit64.exe"
        "vmmap64.exe"
        "Volumeid64.exe"
        "whois64.exe"
        "WinObj64.exe"
        "ZoomIt64.exe"
    )
    SampleFiles = @(
        "N/A"
    )
}

# Get exiftool
$EXIFTOOL_VERSION = Get-DownloadUrlFromPage -url https://exiftool.org/index.html -RegEx 'exiftool-[^zip]+_64.zip'
$status = Get-FileFromUri -uri "https://exiftool.org/$EXIFTOOL_VERSION" -FilePath ".\downloads\exiftool.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\exiftool") {
        Remove-Item -Recurse -Force "${TOOLS}\exiftool" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\exiftool.zip" -o"${TOOLS}" | Out-Null
    Start-Sleep -Seconds 3
    Move-Item ${TOOLS}\exiftool-* "${TOOLS}\exiftool" -Force
    Copy-Item "${TOOLS}\exiftool\exiftool(-k).exe" ${TOOLS}\exiftool\exiftool.exe
    Remove-Item "${TOOLS}\exiftool\exiftool(-k).exe" -Force | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "ExifTool"
    Homepage = "https://exiftool.org/"
    Vendor = "Phil Harvey"
    License = "GNU General Public License"
    LicenseUrl = "https://exiftool.org/#license"
    Category = "Utilities"

    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\ExifTool.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "${CLI_TOOL_ARGS} -command exiftool --help"
            Icon     = "`${TOOLS}\exiftool\exiftool.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "exiftool.exe"
            Expect = "PE32"
        }
    )
    Notes = "ExifTool is a platform-independent Perl library plus a command-line application for reading, writing and editing meta information in a wide variety of files."
    Tips = "ExifTool is installed in ${TOOLS}\exiftool."
    Usage = ""
    SampleCommands = @(
        "exiftool image.jpg"
    )
    SampleFiles = @(
        "N/A"
    )
}

# Get pestudio
$status = Get-FileFromUri -uri "https://www.winitor.com/tools/pestudio/current/pestudio.zip" -FilePath ".\downloads\pestudio.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\pestudio") {
        Remove-Item -Recurse -Force "${TOOLS}\pestudio" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\pestudio.zip" -o"${TOOLS}" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "pestudio"
    Homepage = "https://www.winitor.com/"
    Vendor = "Winitor"
    License = "Proprietary"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\pestudio.lnk"
            Target   = "`${TOOLS}\pestudio\pestudio.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -VSCode"
    Verify = @(
        @{
            Type = "command"
            Name = "pestudio.exe"
            Expect = "PE32"
        }
    )
    Notes = "pestudio is a tool for analyzing PE files."
    Tips = "After installation, you can use pestudio to analyze PE files."
    Usage = "pestudio is a tool for analyzing PE files. It provides detailed information about the structure and content of Portable Executable (PE) files."
    SampleCommands = @(
        "pestudio.exe sample.exe"
    )
    SampleFiles = @(
        "N/A"
    )
}

# Get HxD
$status = Get-FileFromUri -uri "https://mh-nexus.de/downloads/HxDSetup.zip" -FilePath ".\downloads\hxd.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\hxd") {
        Remove-Item -Recurse -Force "${TOOLS}\hxd" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\hxd.zip" -o"${TOOLS}\hxd" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "HxD"
    Homepage = "https://mh-nexus.de/en/hxd/"
    Vendor = "Maël Hörz"
    License = "HxD License"
    LicenseUrl = "https://mh-nexus.de/en/hxd/license.php"
    Category = "Editors"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Editors\HxD.lnk"
            Target   = "`${env:ProgramFiles}\HxD\HxD.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "HxD.exe"
            Expect = "PE32"
        }
    )
    Notes = "HxD is a hex editor, disk editor, and memory editor for Windows."
    Tips = "HxD is installed in ${env:ProgramFiles}\HxD."
    Usage = "HxD is a hex editor, disk editor, and memory editor for Windows. It allows you to view and edit binary files, disks, and memory."
    SampleCommands = @(
        "HxD.exe file.bin"
    )
    SampleFiles = @(
        "N/A"
    )
}

# Get trid and triddefs
$status = Get-FileFromUri -uri "https://mark0.net/download/trid_w32.zip" -FilePath ".\downloads\trid.zip" -check "Zip archive data"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\trid.zip" -o"${TOOLS}\trid" | Out-Null
}
$status = Get-FileFromUri -uri "https://mark0.net/download/triddefs.zip" -FilePath ".\downloads\triddefs.zip" -check "Zip archive data"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\triddefs.zip" -o"${TOOLS}\trid" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "TrID"
    Homepage = "https://mark0.net/soft-trid-e.html"
    Vendor = "Marco Pontello"
    License = "TrID is free for personal / non commercial use."
    Category = "Files and apps"

    Shortcuts = @(
            @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\TrID (File Identifier).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command trid.exe -?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "trid.exe"
            Expect = "PE32"
        }
    )
    Notes = "TrID is a file identifier utility."
    Tips = "TrID is installed in ${TOOLS}\trid."
    Usage = "TrID is a file identifier utility that can identify file types based on their binary signatures."
    SampleCommands = @(
        "trid.exe sample_file.bin"
    )
    SampleFiles = @(
        "N/A"
    )
}

# Get malcat - installed during start - 313 indicates use of Python 3.13
$status = Get-FileFromUri -uri "https://malcat.fr/latest/malcat_win313_lite.zip" -FilePath ".\downloads\malcat.zip" -check "Zip archive data"

$TOOL_DEFINITIONS += @{
    Name = "Malcat Lite"
    Homepage = "https://malcat.fr/"
    Vendor = "Malcat EI"
    License = "Proprietary"
    Category = "Editors"

    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Editors\Malcat.lnk"
            Target   = "`${env:ProgramFiles}\malcat\bin\malcat.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "`${env:ProgramFiles}\malcat\bin\malcat.exe"
            Expect = "PE32"
        }
    )
    Notes = "Malcat is a malware analysis and reverse engineering tool."
    Tips = "Beside these limitations (missing features), please not that the lite edition cannot be used in a professional environment."
    Usage = "Malcat is a malware analysis and reverse engineering tool that provides various features for analyzing binary files."
    SampleCommands = @(
        "malcat.exe sample.exe"
    )
    SampleFiles = @(
        "N/A"
    )
}

# Get ssview
$status = Get-FileFromUri -uri "https://www.mitec.cz/Downloads/SSView.zip" -FilePath ".\downloads\ssview.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\ssview") {
        Remove-Item -Recurse -Force "${TOOLS}\ssview" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ssview.zip" -o"${TOOLS}\ssview" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "MiTeC Structured Storage Viewer"
    Homepage = "https://www.mitec.cz/wp/mssv/"
    Vendor = "MiTeC"
    License = "Proprietary"
    Category = "Files and apps\Office"

    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\Structured Storage Viewer (SSView).lnk"
            Target   = "`${TOOLS}\ssview\SSView.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "SSView.exe"
            Expect = "PE32"
        }
    )
    Notes = "Full-featured MS OLE Structured Storage based file management tool."
    Tips = "SSView is installed in ${TOOLS}\ssview."
    Usage = "This tool allows to completely manage any MS OLE Structured Storage based file. You can save and load streams, add, delete, rename and edit items and property sets. Embedded streams can be viewed as hexadecimal listing or text or interpreted as pictures, RTF or HTML."
    SampleCommands = @(
        "SSView.exe file.doc"
    )
    SampleFiles = @(
        "N/A"
    )
}

# FullEventLogView
$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/fulleventlogview-x64.zip" -FilePath ".\downloads\logview.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\FullEventLogView") {
        Remove-Item -Recurse -Force "${TOOLS}\FullEventLogView" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\logview.zip" -o"${TOOLS}\FullEventLogView" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "FullEventLogView"
    Homepage = "https://www.nirsoft.net/utils/full_event_log_view.html"
    Vendor = "NirSoft"
    License = "Freeware"
    Category = "Logs"

    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Logs\FullEventLogView.lnk"
            Target   = "`${TOOLS}\FullEventLogView\FullEventLogView.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "FullEventLogView.exe"
            Expect = "PE32"
        }
    )
    Notes = "FullEventLogView is a tool for viewing Windows event logs."
    Tips = "FullEventLogView is installed in ${TOOLS}\FullEventLogView."
    Usage = "FullEventLogView allows you to view and export Windows event logs from local and remote computers."
    SampleCommands = @(
        "FullEventLogView.exe"
    )
    SampleFiles = @(
        "N/A"
    )
}

# pstwalker
$status = Get-FileFromUri -uri "https://downloads.pstwalker.com/pstwalker-portable" -FilePath ".\downloads\pstwalker.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\pstwalker") {
        Remove-Item -Recurse -Force "${TOOLS}\pstwalker" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\pstwalker.zip" -o"${TOOLS}" | Out-Null
    Start-Sleep -Seconds 3
    Move-Item ${TOOLS}\pstwalker*portable "${TOOLS}\pstwalker"
}

$TOOL_DEFINITIONS += @{
    Name = "PST Walker"
    Homepage = "https://www.pstwalker.com/"
    Vendor = "PST Walker"
    License = "Proprietary"
    LicenseUrl = "https://www.pstwalker.com/licensing-policy.html"
    Category = "Files and apps\Email"

    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Email\PST Walker.lnk"
            Target   = "`${TOOLS}\pstwalker\PSTWalker.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "PSTWalker.exe"
            Expect = "PE32"
        }
    )
    Notes = "PST Walker is a tool for analyzing PST files."
    Tips = "PST Walker is installed in ${TOOLS}\pstwalker."
    Usage = "PST Walker is a tool for analyzing PST files. It allows you to view and extract data from PST files."
    SampleCommands = @(
        "PSTWalker.exe sample.pst"
    )
    SampleFiles = @(
        "N/A"
    )
}

# Win API Search
$status = Get-FileFromUri -uri "https://dennisbabkin.com/php/downloads/WinApiSearch.zip" -FilePath ".\downloads\WinApiSearch.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\WinApiSearch") {
        Remove-Item -Recurse -Force "${TOOLS}\WinApiSearch" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\WinApiSearch.zip" -o"${TOOLS}\WinApiSearch" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "Win API Search"
    Homepage = "https://dennisbabkin.com/winapisearch/"
    Vendor = "Dennis Babkin"
    License = "You may use this software for as long as you need it, make as many copies of the downloaded package as required, and distribute it among any people and organizations at no cost."
    LicenseUrl = "https://dennisbabkin.com/winapisearch/#lic"
    Category = "Development"

    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Development\Win API Search.lnk"
            Target   = "`${TOOLS}\WinApiSearch\WinApiSearch64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "WinApiSearch32.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "WinApiSearch64.exe"
            Expect = "PE32"
        }
    )
    Notes = "Win API Search is a tool for searching Windows API functions."
    Tips = "Win API Search is installed in ${TOOLS}\WinApiSearch."
    Usage = "Win API Search allows you to search for Windows API functions and view their documentation."
    SampleCommands = @(
        "WinApiSearch.exe"
    )
    SampleFiles = @(
        "N/A"
    )
}

# pdfstreamdumper - installed during start
$status = Get-FileFromUri -uri "http://sandsprite.com/CodeStuff/PDFStreamDumper_Setup.exe" -FilePath ".\downloads\pdfstreamdumper.exe" -check "PE32"

# Capa integration with Ghidra - installed during start
$status = Get-FileFromUri -uri "https://raw.githubusercontent.com/mandiant/capa/master/capa/ghidra/capa_explorer.py" -FilePath ".\downloads\capa_explorer.py" -check "ASCII text"
$status = Get-FileFromUri -uri "https://raw.githubusercontent.com/mandiant/capa/master/capa/ghidra/capa_ghidra.py" -FilePath ".\downloads\capa_ghidra.py" -check "ASCII text"

# Scripts for Cutter
$status = Get-FileFromUri -uri "https://raw.githubusercontent.com/yossizap/x64dbgcutter/master/x64dbgcutter.py" -FilePath ".\downloads\x64dbgcutter.py" -check "ASCII text"
$status = Get-FileFromUri -uri "https://raw.githubusercontent.com/malware-kitten/cutter_scripts/master/scripts/cutter_stackstrings.py" -FilePath ".\downloads\cutter_stackstrings.py" -check "ASCII text"

# Dependence different tools
$status = Get-FileFromUri -uri "https://aka.ms/vs/17/release/vc_redist.x64.exe" -FilePath ".\downloads\vcredist_17_x64.exe" -check "PE32"
$status = Get-FileFromUri -uri "https://aka.ms/vs/16/release/vc_redist.x86.exe" -FilePath ".\downloads\vcredist_16_x64.exe" -check "PE32"

# Artifacts Exchange for Velociraptor
$status = Get-FileFromUri -uri "https://github.com/Velocidex/velociraptor-docs/raw/gh-pages/exchange/artifact_exchange_v2.zip" -FilePath ".\downloads\artifact_exchange.zip" -check "Zip archive data"

# Mail Viewer
$status = Get-FileFromUri -uri "https://www.mitec.cz/Downloads/MailView.zip" -FilePath ".\downloads\mailview.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\MailView") {
        Remove-Item -Recurse -Force "${TOOLS}\MailView" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\mailview.zip" -o"${TOOLS}\MailView" | Out-Null
}

# Volatility Workbench 3
$status = Get-FileFromUri -uri "https://www.osforensics.com/downloads/VolatilityWorkbench.zip" -FilePath ".\downloads\volatilityworkbench.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\VolatilityWorkbench") {
        Remove-Item -Recurse -Force "${TOOLS}\VolatilityWorkbench" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\volatilityworkbench.zip" -o"${TOOLS}\VolatilityWorkbench" | Out-Null
}

# Volatility Workbench 2
$status = Get-FileFromUri -uri "https://www.osforensics.com/downloads/VolatilityWorkbench-v2.1.zip" -FilePath ".\downloads\volatilityworkbench2.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\VolatilityWorkbench2") {
        Remove-Item -Recurse -Force "${TOOLS}\VolatilityWorkbench2" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\volatilityworkbench2.zip" -o"${TOOLS}\VolatilityWorkbench2" | Out-Null
}

# Volatility Workbench 2 Profiles
$status = Get-FileFromUri -uri "https://www.osforensics.com/downloads/Collection.zip" -FilePath ".\downloads\volatilityworkbench2profiles.zip" -check "Zip archive data"

# Nirsoft tools
New-Item -Path "${TOOLS}\nirsoft" -ItemType Directory -Force | Out-Null
if (Test-Path -Path "${TOOLS}\ntemp") {
    Remove-Item -Recurse -Force "${TOOLS}\ntemp" | Out-Null 2>&1
}

$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/lastactivityview.zip" -FilePath ".\downloads\lastactivityview.zip" -check "Zip archive data"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\lastactivityview.zip" -o"${TOOLS}\ntemp" | Out-Null
    if (Test-Path -Path ${TOOLS}\ntemp\readme.txt) {
        Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\lastactivityview.txt"
    }
    Copy-Item ${TOOLS}\ntemp\* "${TOOLS}\nirsoft"
    Remove-Item -Recurse -Force "${TOOLS}\ntemp" | Out-Null 2>&1
}

$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/iecv.zip" -FilePath ".\downloads\iecookiesview.zip" -check "Zip archive data"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\iecookiesview.zip" -o"${TOOLS}\ntemp" | Out-Null
    if (Test-Path -Path ${TOOLS}\ntemp\readme.txt) {
        Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\iecookiesview.txt"
    }
    Copy-Item ${TOOLS}\ntemp\* "${TOOLS}\nirsoft"
    Remove-Item -Recurse -Force "${TOOLS}\ntemp" | Out-Null 2>&1
}

$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/mzcv-x64.zip" -FilePath ".\downloads\MZCookiesView.zip" -check "Zip archive data"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\MZCookiesView.zip" -o"${TOOLS}\ntemp" | Out-Null
    if (Test-Path -Path "${TOOLS}\ntemp\readme.txt") {
        Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\MZCookiesView.txt"
    }
    Copy-Item ${TOOLS}\ntemp\* "${TOOLS}\nirsoft"
    Remove-Item -Recurse -Force "${TOOLS}\ntemp" | Out-Null 2>&1
}

$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/chromecacheview.zip" -FilePath ".\downloads\chromecacheview.zip" -check "Zip archive data"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\chromecacheview.zip" -o"${TOOLS}\ntemp" | Out-Null
    if (Test-Path -Path "${TOOLS}\ntemp\readme.txt") {
        Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\chromecacheview.txt"
    }
    Copy-Item ${TOOLS}\ntemp\* "${TOOLS}\nirsoft"
Remove-Item -Recurse -Force "${TOOLS}\ntemp" | Out-Null 2>&1
}

$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/mzcacheview.zip" -FilePath ".\downloads\mzcacheview.zip" -check "Zip archive data"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\mzcacheview.zip" -o"${TOOLS}\ntemp" | Out-Null
    if (Test-Path -Path ${TOOLS}\ntemp\readme.txt) {
        Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\mzcacheview.txt"
    }
    Copy-Item ${TOOLS}\ntemp\* "${TOOLS}\nirsoft"
    Remove-Item -Recurse -Force "${TOOLS}\ntemp" | Out-Null 2>&1
}

$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/iecacheview.zip" -FilePath ".\downloads\iecacheview.zip" -check "Zip archive data"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\iecacheview.zip" -o"${TOOLS}\ntemp" | Out-Null
    if (Test-Path -Path "${TOOLS}\ntemp\readme.txt") {
        Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\iecacheview.txt"
    }
    Copy-Item ${TOOLS}\ntemp\* "${TOOLS}\nirsoft"
    Remove-Item -Recurse -Force "${TOOLS}\ntemp" | Out-Null
}

$status = Get-FileFromUri -uri "https://www.nirsoft.net/utils/browsinghistoryview-x64.zip" -FilePath ".\downloads\browsinghistoryview.zip" -check "Zip archive data"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\browsinghistoryview.zip" -o"${TOOLS}\ntemp" | Out-Null
    if (Test-Path -Path "${TOOLS}\ntemp\readme.txt") {
        Copy-Item "${TOOLS}\ntemp\readme.txt" "${TOOLS}\ntemp\browsinghistoryview.txt"
    }
    Copy-Item ${TOOLS}\ntemp\* "${TOOLS}\nirsoft"
    Remove-Item -Recurse -Force "${TOOLS}\ntemp" | Out-Null 2>&1
}

if (Test-Path -Path "${TOOLS}\nirsoft\readme.txt") {
    Remove-Item -Force "${TOOLS}\nirsoft\readme.txt" | Out-Null 2>&1
}

# Get winpmem
$status = Get-FileFromUri -uri "https://github.com/Velocidex/c-aff4/raw/master/tools/pmem/resources/winpmem/winpmem_64.sys" -FilePath ".\downloads\winpmem_64.sys" -check "PE32"

# Binary Ninja - manual installation
$status = Get-FileFromUri -uri "https://cdn.binary.ninja/installers/binaryninja_free_win64.exe" -FilePath ".\downloads\binaryninja.exe" -check "PE32"

# gpg4win
$status = Get-FileFromUri -uri "https://files.gpg4win.org/gpg4win-latest.exe" -FilePath ".\downloads\gpg4win.exe" -check "PE32"

# Tor browser
$TorBrowserUrl = Get-DownloadUrlFromPage -Url "https://www.torproject.org/download/" -RegEx '/dist/[^"]+exe'
$status = Get-FileFromUri -uri "https://www.torproject.org$TorBrowserUrl" -FilePath ".\downloads\torbrowser.exe" -check "PE32"

# DCode
$DCodeUrl = Get-DownloadUrlFromPage -Url "https://www.digital-detective.net/dcode/" -RegEx "https://www.digital-detective.net/download/download[^']+"
$status = Get-FileFromUri -uri "${DCodeURL}" -FilePath ".\downloads\dcode.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path ${SETUP_PATH}\dcode) {
        Remove-Item -Recurse -Force ${SETUP_PATH}\dcode | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\dcode.zip" -o"${SETUP_PATH}\dcode" | Out-Null
    Start-Sleep -Seconds 3
    Move-Item ${SETUP_PATH}\dcode\Dcode-* "${SETUP_PATH}\dcode\dcode.exe" | Out-Null
}

# Veracrypt - manual installation
$VeracryptUrl = Get-DownloadUrlFromPage -Url "https://www.veracrypt.fr/en/Downloads.html" -RegEx 'https://[^"]+VeraCrypt_Setup[^"]+.msi'
$status = Get-FileFromUri -uri "${VeracryptUrl}" -FilePath ".\downloads\veracrypt.msi" -check "Composite Document File V2 Document"

# Microsoft OpenJDK 11 - installed during start
$MicrosoftJDKUrl = get-downloadUrlFromPage -url "https://learn.microsoft.com/en-us/java/openjdk/download" -RegEx 'https://aka.ms/download-jdk/microsoft-jdk-11.[.0-9]+-windows-x64.msi'
$status = Get-FileFromUri -uri "${MicrosoftJDKUrl}" -FilePath ".\downloads\microsoft-jdk-11.msi" -CheckURL "Yes" -check "Composite Document File V2 Document"

# https://neo4j.com/deployment-center/#community - Neo4j - installed during start
$NeoVersion = Get-DownloadUrlFromPage -Url "https://neo4j.com/deployment-center/#community" -RegEx '4.4.[^"]+-windows\.zip'
$status = Get-FileFromUri -uri "https://neo4j.com/artifact.php?name=neo4j-community-${NeoVersion}" -FilePath ".\downloads\neo4j.zip" -CheckURL "Yes" -check "Zip archive data"

# recbin
$status = Get-FileFromUri -uri "https://github.com/keydet89/Tools/raw/refs/heads/master/exe/recbin.exe" -FilePath ".\downloads\recbin.exe" -check "PE32"
if ($status) {
    if (Test-Path -Path "${TOOLS}\bin\recbin.exe") {
        Remove-Item -Force "${TOOLS}\bin\recbin.exe" | Out-Null 2>&1
    }
    Copy-Item ".\downloads\recbin.exe" "${TOOLS}\bin\recbin.exe"
}

# capa Explorer web
$status = Get-FileFromUri -uri "https://mandiant.github.io/capa/explorer/capa-explorer-web.zip" -FilePath ".\downloads\capa-explorer-web.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\capa-explorer-web") {
        Remove-Item -Recurse -Force "${TOOLS}\capa-explorer-web" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\capa-explorer-web.zip" -o"${TOOLS}" | Out-Null
}

# https://www.libreoffice.org/download/download-libreoffice/ - LibreOffice - installed during start
$LibreOfficeVersionDownloadPage = Get-DownloadUrlFromPage -Url "https://www.libreoffice.org/download/download-libreoffice/" -RegEx 'https://[^"]+.msi'
$LibreOfficeVersion = Get-DownloadUrlFromPage -Url "${LibreOfficeVersionDownloadPage}" -RegEx 'https://[^"]+.msi'
$status = Get-FileFromUri -uri "${LibreOfficeVersion}" -FilePath ".\downloads\LibreOffice.msi" -CheckURL "Yes" -check "Composite Document File V2 Document"

# https://npcap.com/#download - Npcap - available for manual installation
$NpcapVersion = Get-DownloadUrlFromPage -Url "https://npcap.com/" -RegEx 'dist/npcap-[.0-9]+.exe'
$status = Get-FileFromUri -uri "https://npcap.com/${NpcapVersion}" -FilePath ".\downloads\npcap.exe" -CheckURL "Yes" -check "PE32"

# https://www.sqlite.org/download.html - SQLite
$SQLiteVersion = Get-DownloadUrlFromPage -Url "https://sqlite.org/download.html" -RegEx '[0-9]+/sqlite-tools-win-x64-[^"]+.zip'
$status = Get-FileFromUri -uri "https://sqlite.org/${SQLiteVersion}" -FilePath ".\downloads\sqlite.zip" -CheckURL "Yes"
if ($status) {
    if (Test-Path -Path "${TOOLS}\sqlite") {
        Remove-Item -Recurse -Force "${TOOLS}\sqlite" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\sqlite.zip" -o"${TOOLS}\sqlite" | Out-Null
}

# OpenVPN - manual installation
$status = Get-FileFromUri -uri "https://openvpn.net/downloads/openvpn-connect-v3-windows.msi" -FilePath ".\downloads\openvpn.msi" -check "Composite Document File V2 Document"

# https://downloads.digitalcorpora.org/downloads/bulk_extractor - bulk_extractor
$digitalcorpora_url = "https://digitalcorpora.s3.amazonaws.com/downloads/bulk_extractor/bulk_extractor-2.0.0-windows.zip"
$status = Get-FileFromUri -uri "${digitalcorpora_url}" -FilePath ".\downloads\bulk_extractor.zip" -CheckURL "Yes" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\bulk_extractor") {
        Remove-Item -Recurse -Force "${TOOLS}\bulk_extractor" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\bulk_extractor.zip" -o"${TOOLS}\bulk_extractor" | Out-Null
}

# https://cert.at/en/downloads/software/software-densityscout - DensityScout
$densityscout_url = Get-DownloadUrlFromPage -url "https://cert.at/en/downloads/software/software-densityscout" -RegEx '[^"]+windows.zip'
$status = Get-FileFromUri -uri "${densityscout_url}" -FilePath ".\downloads\DensityScout.zip" -CheckURL "Yes" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\bin\densityscout.exe") {
        Remove-Item -Recurse -Force "${TOOLS}\bin\densityscout.exe" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\DensityScout.zip" -o"${TOOLS}" | Out-Null
    Start-Sleep -Seconds 3
    Move-Item "${TOOLS}\win64\densityscout.exe" "${TOOLS}\bin\densityscout.exe"
}

# https://nmap.org/download.html - Nmap
$nmap_url = Get-DownloadUrlFromPage -url "https://nmap.org/download.html" -RegEx 'https[^"]+setup.exe'
$status = Get-FileFromUri -uri "${nmap_url}" -FilePath ".\downloads\nmap.exe" -CheckURL "Yes" -check "PE32"
if ($status) {
    if (Test-Path -Path "${TOOLS}\nmap") {
        Remove-Item -Recurse -Force "${TOOLS}\nmap" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\nmap.exe" -o"${TOOLS}\nmap" | Out-Null
}

# https://flatassembler.net/download.php - FASM
$flatassembler_version = Get-DownloadUrlFromPage -url "https://flatassembler.net/download.php" -RegEx 'fasmw[^"]+zip'
$status = Get-FileFromUri -uri "https://flatassembler.net/${flatassembler_version}" -FilePath ".\downloads\fasm.zip" -CheckURL "Yes" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\fasm") {
        Remove-Item -Recurse -Force "${TOOLS}\fasm" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\fasm.zip" -o"${TOOLS}\fasm" | Out-Null
}

# Terminal for Windows - automatically installed during start
$status = Get-FileFromUri -uri "https://aka.ms/terminal-canary-zip-x64" -FilePath ".\downloads\terminal.zip" -CheckURL "Yes" -check "Zip archive data"

# https://procdot.com/downloadprocdotbinaries.htm - Procdot
$procdot_path = Get-DownloadUrlFromPage -url "https://procdot.com/downloadprocdotbinaries.htm" -RegEx 'download[^"]+windows.zip'
$status = Get-FileFromUri -uri "https://procdot.com/${procdot_path}" -FilePath ".\downloads\procdot.zip" -CheckURL "Yes" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\procdot") {
        Remove-Item -Recurse -Force "${TOOLS}\procdot" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -pprocdot -aoa "${SETUP_PATH}\procdot.zip" -o"${TOOLS}\procdot" | Out-Null
}


# https://codeberg.org/hrbrmstr/geolocus-cli/releases - Geolocus CLI
$geolocus_url = Get-DownloadUrlFromPage -url "https://codeberg.org/hrbrmstr/geolocus-cli/releases" -RegEx 'https://[^"]*geolocus-cli-windows\.exe\.zip' -last
$status = Get-FileFromUri -uri "${geolocus_url}" -FilePath ".\downloads\geolocus.zip" -CheckURL "Yes" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\geolocus") {
        Remove-Item -Recurse -Force "${TOOLS}\geolocus" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\geolocus.zip" -o"${TOOLS}\geolocus" | Out-Null
    Copy-Item "${TOOLS}\geolocus\geolocus-cli-windows.exe" -Destination "${TOOLS}\bin\geolocus-cli.exe" -Force
    Remove-Item -Recurse -Force "${TOOLS}\geolocus\__MACOSX" | Out-Null 2>&1
}

# https://www.graphviz.org/download/ - Graphviz - available for manual installation
$graphviz_url = Get-DownloadUrlFromPage -url "https://www.graphviz.org/download/" -RegEx 'https://[^"]+win64.exe'
$status = Get-FileFromUri -uri "${graphviz_url}" -FilePath ".\downloads\graphviz.exe" -CheckURL "Yes" -check "PE32"

# http://www.rohitab.com/apimonitor - API Monitor - installed during start
$status = Get-FileFromUri -uri "http://www.rohitab.com/download/api-monitor-v2r13-setup-x64.exe" -FilePath ".\downloads\apimonitor64.exe" -CheckURL "Yes" -check "PE32"

# https://gluonhq.com/products/javafx/ - JavaFX 21
$javafx_version = Get-DownloadUrlFromPage -url "https://gluonhq.com/products/javafx/" -RegEx '21\.[0-9.]+'
$status = Get-FileFromUri -uri "https://download2.gluonhq.com/openjfx/${javafx_version}/openjfx-${javafx_version}_windows-x64_bin-sdk.zip" -FilePath ".\downloads\openjfx.zip" -CheckURL "Yes" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\javafx-sdk") {
        Remove-Item -Recurse -Force "${TOOLS}\javafx-sdk" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\openjfx.zip" -o"${TOOLS}" | Out-Null
    Start-Sleep -Seconds 3
    Move-Item ${TOOLS}\javafx-sdk-* "${TOOLS}\javafx-sdk"
}

# https://bitbucket.org/iBotPeaches/apktool/downloads/ - apktool
$apktool_version = Get-DownloadUrlFromPage -url "https://apktool.org/" -RegEx 'apktool_[^"]+'
$status = Get-FileFromUri -uri "https://bitbucket.org/iBotPeaches/apktool/downloads/${apktool_version}" -FilePath ".\downloads\apktool.jar" -CheckURL "Yes" -check "Zip archive data"
if ($status) {
    Copy-Item ".\downloads\apktool.jar" "${TOOLS}\bin\apktool.jar" -Force
    Copy-Item "setup\utils\apktool.bat" "${TOOLS}\bin\apktool.bat" -Force
}

# https://windows.php.net/download - PHP 8
$PHP_URL = Get-DownloadUrlFromPage -Url "https://windows.php.net/download" -RegEx '/downloads/releases/php-8.[.0-9]+-nts-Win32-vs16-x64.zip'
$status = Get-FileFromUri -uri "https://windows.php.net${PHP_URL}" -FilePath ".\downloads\php.zip" -CheckURL "Yes" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\php") {
        Remove-Item -Recurse -Force "${TOOLS}\php" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\php.zip" -o"${TOOLS}\php" | Out-Null
}

# https://hashcat.net/hashcat/ - hashcat
$hashcat_version = Get-DownloadUrlFromPage -url "https://hashcat.net/hashcat/" -RegEx 'fil[^"]+\.7z'
$status = Get-FileFromUri -uri "https://hashcat.net/${hashcat_version}" -FilePath ".\downloads\hashcat.7z" -CheckURL "Yes" -check "7-zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\hashcat") {
        Remove-Item -Recurse -Force "${TOOLS}\hashcat" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\hashcat.7z" -o"${TOOLS}" | Out-Null
    Start-Sleep -Seconds 3
    Move-Item ${TOOLS}\hashcat-* "${TOOLS}\hashcat" | Out-Null
}

# vmss2core
$status = Get-FileFromUri -uri "https://archive.org/download/flings.vmware.com/Flings/Vmss2core/vmss2core-sb-8456865.exe" -FilePath ".\downloads\vmss2core.exe" -CheckURL "Yes" -check "PE32"
if ($status) {
    Copy-Item ".\downloads\vmss2core.exe" "${TOOLS}\bin\vmss2core.exe" -Force
}

# Drivers for hashcat
$intel_driver = Get-DownloadUrlFromPage -url "https://www.intel.com/content/www/us/en/developer/articles/technical/intel-cpu-runtime-for-opencl-applications-with-sycl-support.html" -RegEx 'https://[^"]+\.exe'
$status = Get-FileFromUri -uri "${intel_driver}" -FilePath ".\downloads\intel_driver.exe" -CheckURL "Yes" -check "PE32"

# Mex for WinDbg
$status = Get-FileFromUri -uri "https://download.microsoft.com/download/0/c/4/0c4c45e3-bf02-49bf-8d68-6fa611f442e6/Mex.exe" -FilePath ".\downloads\mex.exe" -CheckURL "Yes" -check "PE32"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\mex.exe" -o"${SETUP_PATH}" | Out-Null
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\mex.zip" -o"${TOOLS}\mex" | Out-Null
}

# ELK
$ELK_VERSION = ((curl.exe --silent -L "https://api.github.com/repos/elastic/elasticsearch/releases/latest" | ConvertFrom-Json).tag_name).Replace("v", "")
Set-Content -Path ".\downloads\elk_version.txt" -Value "${ELK_VERSION}"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\elasticsearch.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/kibana/kibana-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\kibana.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/logstash/logstash-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\logstash.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\elastic-agent.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\filebeat.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\metricbeat.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\packetbeat.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\heartbeat.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\auditbeat.zip" -CheckURL "Yes" -check "Zip archive data"
$status = Get-FileFromUri -uri "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-${ELK_VERSION}-windows-x86_64.zip" -FilePath ".\downloads\winlogbeat.zip" -CheckURL "Yes" -check "Zip archive data"

# Remove unused files and directories
if (Test-Path -Path "${TOOLS}\win32") {
    Remove-Item -Recurse -Force "${TOOLS}\win32" | Out-Null 2>&1
}

if (Test-Path -Path "${TOOLS}\win64") {
    Remove-Item -Recurse -Force "${TOOLS}\win64" | Out-Null 2>&1
}

if (Test-Path -Path "${TOOLS}\license.txt") {
    Remove-Item -Force "${TOOLS}\license.txt"
}

# Remove old helper files for HTTP installations and create new ones.
if (Test-Path -Path ".\downloads\dfirws\verify_http.ps1") {
    Remove-Item -Force ".\downloads\dfirws\verify_http.ps1" | Out-Null 2>&1
}
Set-Content -Path ".\downloads\dfirws\verify_http.ps1" -Value "# verify_http.ps1`n# This file is autogenerated during setup. Do not edit manually.`n"

if (Test-Path -Path ".\downloads\dfirws\install_http.ps1") {
    Remove-Item -Force ".\downloads\dfirws\install_http.ps1" | Out-Null 2>&1
}
Set-Content -Path ".\downloads\dfirws\install_http.ps1" -Value "# install_http.ps1`n# This file is autogenerated during setup. Do not edit manually.`n"

if (Test-Path -Path ".\downloads\dfirws\dfirws_folder_http.ps1") {
    Remove-Item -Force ".\downloads\dfirws\dfirws_folder_http.ps1" | Out-Null 2>&1
}
Set-Content -Path ".\downloads\dfirws\dfirws_folder_http.ps1" -Value "# dfirws_folder_http.ps1`n# This file is autogenerated during setup. Do not edit manually.`n"

# Iterate over $TOOL_DEFINITIONS to create helper files for HTTP installations.
for ($i = 0; $i -lt $TOOL_DEFINITIONS.Count; $i++) {
    # Create helper file verify_http.ps1 called from verify.ps1.
    # Use $TOOL_DEFINITIONS from this script.
   
    foreach ($test in $TOOL_DEFINITIONS[$i].Verify) {
        $verify_type = $test.Type
        $verify_name = $test.Name
        $verify_expect = $test.Expect 

        if ("command" -eq $verify_type) {
            Add-Content -Path ".\downloads\dfirws\verify_http.ps1" -Value "Test-Command `"$verify_name`" `"$verify_expect`""
        }
    }

    # Create helper file install_http.ps1 called from install_all.ps1.
    # Use $TOOL_DEFINITIONS from this script.
    $install_verify_command = $TOOL_DEFINITIONS[$i].InstallVerifyCommand

    if ($null -ne $install_verify_command) {
        Add-Content -Path ".\downloads\dfirws\install_http.ps1" -Value "$install_verify_command"
    }

    # Create helper file dfirws_folder_http.ps1 called from dfirws-install.ps1.
    # Use $TOOL_DEFINITIONS from this script.
    foreach ($link in $TOOL_DEFINITIONS[$i].Shortcuts) {
        $lnk = $link.Lnk
        $target = $link.Target
        $args = $link.Args
        $icon = $link.Icon
        $workdir = $link.WorkDir

        if ($null -eq $icon) {
            if ($null -eq $args) {
                Add-Content -Path ".\downloads\dfirws\dfirws_folder_http.ps1" -Value "Add-Shortcut -SourceLnk `"$lnk`" -DestinationPath `"$target`" -WorkingDirectory `"$workdir`""
            } else {
                Add-Content -Path ".\downloads\dfirws\dfirws_folder_http.ps1" -Value "Add-Shortcut -SourceLnk `"$lnk`" -DestinationPath `"$target`" -Arguments `"$args`" -WorkingDirectory `"$workdir`""
            }
        } else {
            if ($null -eq $args) {
                Add-Content -Path ".\downloads\dfirws\dfirws_folder_http.ps1" -Value "Add-Shortcut -SourceLnk `"$lnk`" -DestinationPath `"$target`" -IconLocation `"$icon`" -WorkingDirectory `"$workdir`""
            } else {
                Add-Content -Path ".\downloads\dfirws\dfirws_folder_http.ps1" -Value "Add-Shortcut -SourceLnk `"$lnk`" -DestinationPath `"$target`" -Arguments `"$args`" -IconLocation `"$icon`" -WorkingDirectory `"$workdir`""
            }
        }
    }
}

# Export tool metadata for documentation generation.
$tools_export = @()
for ($i = 0; $i -lt $TOOL_DEFINITIONS.Count; $i++) {
    $tool = $TOOL_DEFINITIONS[$i]
    $category_path = $null

    if ($null -ne $tool.Shortcuts -and $tool.Shortcuts.Count -gt 0) {
        $lnk = $tool.Shortcuts[0].Lnk
        if ($null -ne $lnk) {
            $category_match = [regex]::Match($lnk, "\\Desktop\\dfirws\\(.+)\\[^\\]+$")
            if ($category_match.Success) {
                $category_path = $category_match.Groups[1].Value
            }
        }
    }

    $category = "Uncategorized"
    if ($null -ne $category_path -and $category_path -ne "") {
        $category = ($category_path -split "\\")[0]
    }

    $tools_export += [ordered]@{
        Name                 = $tool.Name
        Homepage             = $tool.Homepage
        Vendor               = $tool.Vendor
        License              = $tool.License
        LicenseUrl           = $tool.LicenseUrl
        Category             = $category
        CategoryPath         = $category_path
        InstallVerifyCommand = $tool.InstallVerifyCommand
        Shortcuts            = $tool.Shortcuts
        Verify               = $tool.Verify
        Notes                = $tool.Notes
        Tips                 = $tool.Tips
        Usage                = $tool.Usage
        SampleCommands       = $tool.SampleCommands
        SampleFiles          = $tool.SampleFiles
    }
}

$tools_doc = [ordered]@{
    GeneratedAt  = (Get-Date).ToString("s")
    SourceScript = "resources/download/http.ps1"
    Tools        = $tools_export
}

Set-Content -Path ".\downloads\dfirws\tools_http.json" -Value ($tools_doc | ConvertTo-Json -Depth 8)
