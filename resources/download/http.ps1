param(
    [Parameter(HelpMessage = "Don't update Visual Studio Code Extensions via http.")]
    [Switch]$NoVSCodeExtensions
)

. ".\resources\download\common.ps1"

$TOOL_DEFINITIONS = @()

if (! $NoVSCodeExtensions.IsPresent) {
    # Get URI for Visual Studio Code C++ extension - ugly
    try {
        $vscode_cpp_string = Get-DownloadUrlFromPage -url "https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools" -RegEx '"AssetUri":"[^"]+ms-vscode.cpptools/([^/]+)/'

        if ("$vscode_cpp_string" -ne "") {
            $vscode_tmp = $vscode_cpp_string | Select-String -Pattern '"AssetUri":"[^"]+ms-vscode.cpptools/([^/]+)/'
            if ($null -ne $vscode_tmp -and $null -ne $vscode_tmp.Matches -and $vscode_tmp.Matches.Count -gt 0) {
                $vscode_cpp_version = $vscode_tmp.Matches.Groups[1].Value
                # Visual Studio Code C++ extension
                $status = Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/cpptools/$vscode_cpp_version/vspackage?targetPlatform=win32-x64" -FilePath ".\downloads\vscode\vscode-cpp.vsix" -CheckURL "Yes" -check "Zip archive data"
            } else {
                Write-DateLog "ERROR: Could not parse version for Visual Studio Code C++ extension"
            }
        } else {
            Write-DateLog "ERROR: Could not get URI for Visual Studio Code C++ extension"
        }
    } catch {
        Write-DateLog "ERROR: Failed to download Visual Studio Code C++ extension: $($_.Exception.Message)"
    }

    # Get URI for Visual Studio Code python extension - ugly
    try {
        $vscode_python_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=ms-python.python -RegEx '"AssetUri":"[^"]+python/([^/]+)/'

        if ("$vscode_python_string" -ne "") {
            $vscode_tmp = $vscode_python_string | Select-String -Pattern '"AssetUri":"[^"]+python/([^/]+)/'
            if ($null -ne $vscode_tmp -and $null -ne $vscode_tmp.Matches -and $vscode_tmp.Matches.Count -gt 0) {
                $vscode_python_version = $vscode_tmp.Matches.Groups[1].Value
                # Visual Studio Code python extension
                $status = Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/python/$vscode_python_version/vspackage" -FilePath ".\downloads\vscode\vscode-python.vsix" -CheckURL "Yes" -check "Zip archive data"
            } else {
                Write-DateLog "ERROR: Could not parse version for Visual Studio Code python extension"
            }
        } else {
            Write-DateLog "ERROR: Could not get URI for Visual Studio Code python extension"
        }
    } catch {
        Write-DateLog "ERROR: Failed to download Visual Studio Code python extension: $($_.Exception.Message)"
    }

    # Get URI for Visual Studio Code mermaid extension - ugly
    try {
        $vscode_mermaid_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid -RegEx '"AssetUri":"[^"]+markdown-mermaid/([^/]+)/'

        if ("$vscode_mermaid_string" -ne "") {
            $vscode_tmp = $vscode_mermaid_string | Select-String -Pattern '"AssetUri":"[^"]+markdown-mermaid/([^/]+)/'
            if ($null -ne $vscode_tmp -and $null -ne $vscode_tmp.Matches -and $vscode_tmp.Matches.Count -gt 0) {
                $vscode_mermaid_version = $vscode_tmp.Matches.Groups[1].Value
                # Visual Studio Code mermaid extension
                $status = Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/bierner/vsextensions/markdown-mermaid/$vscode_mermaid_version/vspackage" -FilePath ".\downloads\vscode\vscode-mermaid.vsix" -CheckURL "Yes" -check "Zip archive data"
            } else {
                Write-DateLog "ERROR: Could not parse version for Visual Studio Code mermaid extension"
            }
        } else {
            Write-DateLog "ERROR: Could not get URI for Visual Studio Code mermaid extension"
        }
    } catch {
        Write-DateLog "ERROR: Failed to download Visual Studio Code mermaid extension: $($_.Exception.Message)"
    }

    # Get URI for Visual Studio Code ruff extension - ugly
    try {
        $vscode_ruff_string = Get-DownloadUrlFromPage -url https://marketplace.visualstudio.com/items?itemName=charliermarsh.ruff -RegEx '"AssetUri":"[^"]+charliermarsh.ruff/([^/]+)/'

        if ("$vscode_ruff_string" -ne "") {
            $vscode_tmp = $vscode_ruff_string | Select-String -Pattern '"AssetUri":"[^"]+charliermarsh.ruff/([^/]+)/'
            if ($null -ne $vscode_tmp -and $null -ne $vscode_tmp.Matches -and $vscode_tmp.Matches.Count -gt 0) {
                $vscode_ruff_version = $vscode_tmp.Matches.Groups[1].Value
                # Visual Studio Code ruff extension
                $status = Get-FileFromUri -uri "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/charliermarsh/vsextensions/ruff/$vscode_ruff_version/vspackage" -FilePath ".\downloads\vscode\vscode-ruff.vsix" -CheckURL "Yes" -check "Zip archive data"
            } else {
                Write-DateLog "ERROR: Could not parse version for Visual Studio Code ruff extension"
            }
        } else {
            Write-DateLog "ERROR: Could not get URI for Visual Studio Code ruff extension"
        }
    } catch {
        Write-DateLog "ERROR: Failed to download Visual Studio Code ruff extension: $($_.Exception.Message)"
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
            Name = "C:\Users\WDAGUtilityAccount\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd"
            Expect = "DOS"
        }
    )
    FileExtensions = @(".ps1", ".py", ".js", ".ts", ".json", ".xml", ".yaml", ".md")
    Tags = @("text-editor", "ide", "powershell")
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
    Dependencies = @()
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
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\Dbgview.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command Dbgview.exe -h"
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
            Lnk      = "`${HOME}\Desktop\dfirws\Sysinternals\RegJump.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command regjump.exe /?"
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
            Name = "Dbgview.exe"
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
            Name = "procexp64.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "procmon64.exe"
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
            Name = "RegJump.exe"
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
    FileExtensions = @(".exe", ".dll", ".sys")
    Tags = @("windows", "debugging", "monitoring", "system-administration")
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
        "Dbgview.exe"
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
        "procexp64.exe"
        "Procmon64.exe"
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
    Dependencies = @()
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
    FileExtensions = @(".jpg", ".jpeg", ".png", ".gif", ".tiff", ".pdf", ".doc", ".docx", ".mp4")
    Tags = @("metadata", "file-analysis", "image")
    Notes = "ExifTool is a platform-independent Perl library plus a command-line application for reading, writing and editing meta information in a wide variety of files."
    Tips = "ExifTool is installed in ${TOOLS}\exiftool."
    Usage = ""
    SampleCommands = @(
        "exiftool image.jpg"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
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
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "pestudio.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".sys")
    Tags = @("pe-analysis", "malware-analysis", "static-analysis")
    Notes = "pestudio is a tool for analyzing PE files."
    Tips = "After installation, you can use pestudio to analyze PE files."
    Usage = "pestudio is a tool for analyzing PE files. It provides detailed information about the structure and content of Portable Executable (PE) files."
    SampleCommands = @(
        "pestudio.exe sample.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
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
    FileExtensions = @(".exe", ".dll", ".bin", ".hex")
    Tags = @("hex-editor", "binary-analysis")
    Notes = "HxD is a hex editor, disk editor, and memory editor for Windows."
    Tips = "HxD is installed in ${env:ProgramFiles}\HxD."
    Usage = "HxD is a hex editor, disk editor, and memory editor for Windows. It allows you to view and edit binary files, disks, and memory."
    SampleCommands = @(
        "HxD.exe file.bin"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
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
    FileExtensions = @()
    Tags = @("file-identification")
    Notes = "TrID is a file identifier utility."
    Tips = "TrID is installed in ${TOOLS}\trid."
    Usage = "TrID is a file identifier utility that can identify file types based on their binary signatures."
    SampleCommands = @(
        "trid.exe sample_file.bin"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# Get malcat - installed during start - 313 indicates use of Python 3.13
$status = Get-FileFromUri -uri "https://malcat.fr/latest/malcat_win313_lite.zip" -FilePath ".\downloads\malcat.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\malcat") {
        Remove-Item -Recurse -Force "${TOOLS}\malcat" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\malcat.zip" -o"${TOOLS}\malcat" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "Malcat Lite"
    Homepage = "https://malcat.fr/"
    Vendor = "Malcat EI"
    License = "Proprietary"
    Category = "Editors"

    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Editors\Malcat.lnk"
            Target   = "`${TOOLS}\malcat\bin\malcat.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "`${TOOLS}\malcat\bin\malcat.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".elf", ".bin", ".sys")
    Tags = @("pe-analysis", "malware-analysis", "hex-editor", "disassembler")
    Notes = "Malcat is a malware analysis and reverse engineering tool."
    Tips = "Beside these limitations (missing features), please not that the lite edition cannot be used in a professional environment."
    Usage = "Malcat is a malware analysis and reverse engineering tool that provides various features for analyzing binary files."
    SampleCommands = @(
        "malcat.exe sample.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
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
    FileExtensions = @(".doc", ".xls", ".ppt", ".msg")
    Tags = @("office", "ole", "data-extraction")
    Notes = "Full-featured MS OLE Structured Storage based file management tool."
    Tips = "SSView is installed in ${TOOLS}\ssview."
    Usage = "This tool allows to completely manage any MS OLE Structured Storage based file. You can save and load streams, add, delete, rename and edit items and property sets. Embedded streams can be viewed as hexadecimal listing or text or interpreted as pictures, RTF or HTML."
    SampleCommands = @(
        "SSView.exe file.doc"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
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
    FileExtensions = @(".evtx")
    Tags = @("log-analysis", "event-log", "windows")
    Notes = "FullEventLogView is a tool for viewing Windows event logs."
    Tips = "FullEventLogView is installed in ${TOOLS}\FullEventLogView."
    Usage = "FullEventLogView allows you to view and export Windows event logs from local and remote computers."
    SampleCommands = @(
        "FullEventLogView.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
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
    FileExtensions = @(".pst")
    Tags = @("email", "forensics", "outlook")
    Notes = "PST Walker is a tool for analyzing PST files."
    Tips = "PST Walker is installed in ${TOOLS}\pstwalker."
    Usage = "PST Walker is a tool for analyzing PST files. It allows you to view and extract data from PST files."
    SampleCommands = @(
        "PSTWalker.exe sample.pst"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
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
            Name = "`${TOOLS}\WinApiSearch\WinApiSearch32.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\WinApiSearch\WinApiSearch64.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("reverse-engineering", "windows", "api")
    Notes = "Win API Search is a tool for searching Windows API functions."
    Tips = "Win API Search is installed in ${TOOLS}\WinApiSearch."
    Usage = "Win API Search allows you to search for Windows API functions and view their documentation."
    SampleCommands = @(
        "WinApiSearch.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# pdfstreamdumper - installed during start
$status = Get-FileFromUri -uri "http://sandsprite.com/CodeStuff/PDFStreamDumper_Setup.exe" -FilePath ".\downloads\pdfstreamdumper.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "PDFStreamDumper"
    Homepage = "https://sandsprite.com/tools.php?id=17"
    Vendor = "Sandsprite"
    License = "Proprietary"
    Category = "Files and apps\PDF"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PDF\pdfstreamdumper install (runs dfirws-install -PDFStreamDumper).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -PDFStreamDumper"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -PDFStreamDumper"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Sandsprite\PDFStreamDumper\PDFStreamDumper.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".pdf")
    Tags = @("pdf", "malware-analysis", "javascript")
    Notes = "PDFStreamDumper is a tool for inspecting PDF files."
    Tips = "After installation, the shortcut is replaced with the installed application."
    Usage = "PDFStreamDumper helps analyze PDF structure and embedded streams."
    SampleCommands = @(
        "PDFStreamDumper.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

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

$TOOL_DEFINITIONS += @{
    Name = "Velociraptor Artifact Exchange"
    Homepage = "https://github.com/Velocidex/velociraptor-docs/tree/gh-pages/exchange"
    Vendor = "Velocidex"
    Category = "Utilities"
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("velociraptor")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# Mail Viewer
$status = Get-FileFromUri -uri "https://www.mitec.cz/Downloads/MailView.zip" -FilePath ".\downloads\mailview.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\MailView") {
        Remove-Item -Recurse -Force "${TOOLS}\MailView" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\mailview.zip" -o"${TOOLS}\MailView" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "Mail Viewer"
    Homepage = "https://www.mitec.cz/wp/mmv/"
    Vendor = "MiTeC"
    License = "Freeware"
    Category = "Files and apps\Email"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Email\Mail Viewer.lnk"
            Target   = "`${TOOLS}\MailView\MailView.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "MailView"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".eml", ".msg")
    Tags = @("email", "forensics")
    Notes = "Mail Viewer is a tool for viewing email files and mailboxes."
    Tips = "Mail Viewer is installed in ${TOOLS}\MailView."
    Usage = "Use Mail Viewer to inspect emails and mail archives."
    SampleCommands = @(
        "MailView.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# Volatility Workbench 3
if (Test-ToolIncluded -ToolName "Volatility Workbench 3") {
    $status = Get-FileFromUri -uri "https://www.osforensics.com/downloads/VolatilityWorkbench.zip" -FilePath ".\downloads\volatilityworkbench.zip" -check "Zip archive data"
    if ($status) {
        if (Test-Path -Path "${TOOLS}\VolatilityWorkbench") {
            Remove-Item -Recurse -Force "${TOOLS}\VolatilityWorkbench" | Out-Null 2>&1
        }
        & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\volatilityworkbench.zip" -o"${TOOLS}\VolatilityWorkbench" | Out-Null
    }
}

$TOOL_DEFINITIONS += @{
    Name = "Volatility Workbench 3"
    Homepage = "https://www.osforensics.com/tools/volatility-workbench.html"
    Vendor = "OSForensics"
    License = "Freeware"
    Category = "Memory"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Memory\Volatility Workbench 3.lnk"
            Target   = "`${TOOLS}\VolatilityWorkbench\VolatilityWorkbench.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\VolatilityWorkbench\VolatilityWorkbench.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".dmp", ".raw", ".vmem", ".img")
    Tags = @("memory-forensics", "gui")
    Notes = "Volatility Workbench is a GUI for the Volatility memory analysis framework."
    Tips = "Volatility Workbench 3 is installed in ${TOOLS}\VolatilityWorkbench."
    Usage = "Use Volatility Workbench to manage memory images and run Volatility plugins."
    SampleCommands = @(
        "VolatilityWorkbench.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# Volatility Workbench 2
if (Test-ToolIncluded -ToolName "Volatility Workbench 2.1") {
    $status = Get-FileFromUri -uri "https://www.osforensics.com/downloads/VolatilityWorkbench-v2.1.zip" -FilePath ".\downloads\volatilityworkbench2.zip" -check "Zip archive data"
    if ($status) {
        if (Test-Path -Path "${TOOLS}\VolatilityWorkbench2") {
            Remove-Item -Recurse -Force "${TOOLS}\VolatilityWorkbench2" | Out-Null 2>&1
        }
        & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\volatilityworkbench2.zip" -o"${TOOLS}\VolatilityWorkbench2" | Out-Null
    }
}

$TOOL_DEFINITIONS += @{
    Name = "Volatility Workbench 2.1"
    Homepage = "https://www.osforensics.com/tools/volatility-workbench.html"
    Vendor = "OSForensics"
    License = "Freeware"
    Category = "Memory"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Memory\Volatility Workbench 2.1.lnk"
            Target   = "`${TOOLS}\VolatilityWorkbench2\VolatilityWorkbench.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\VolatilityWorkbench2\VolatilityWorkbench.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".dmp", ".raw", ".vmem", ".img")
    Tags = @("memory-forensics", "gui")
    Notes = "Volatility Workbench is a GUI for the Volatility memory analysis framework."
    Tips = "Volatility Workbench 2.1 is installed in ${TOOLS}\VolatilityWorkbench2."
    Usage = "Use Volatility Workbench to manage memory images and run Volatility plugins."
    SampleCommands = @(
        "VolatilityWorkbench.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# Volatility Workbench 2 Profiles
if (Test-ToolIncluded -ToolName "Volatility Workbench 2.1") {
    $status = Get-FileFromUri -uri "https://www.osforensics.com/downloads/Collection.zip" -FilePath ".\downloads\volatilityworkbench2profiles.zip" -check "Zip archive data"
}

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

$TOOL_DEFINITIONS += @{
    Name = "NirSoft Browser Utilities"
    Homepage = "https://www.nirsoft.net/"
    Vendor = "NirSoft"
    License = "Freeware"
    Category = "Files and apps\Browser"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Browser\BrowsingHistoryView.lnk"
            Target   = "`${TOOLS}\nirsoft\BrowsingHistoryView.exe"
            Args     = ""
            Icon     = "`${TOOLS}\nirsoft\BrowsingHistoryView.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Browser\ChromeCacheView.lnk"
            Target   = "`${TOOLS}\nirsoft\ChromeCacheView.exe"
            Args     = ""
            Icon     = "`${TOOLS}\nirsoft\ChromeCacheView.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Browser\IECacheView.lnk"
            Target   = "`${TOOLS}\nirsoft\IECacheView.exe"
            Args     = ""
            Icon     = "`${TOOLS}\nirsoft\IECacheView.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Browser\LastActivityView.lnk"
            Target   = "`${TOOLS}\nirsoft\LastActivityView.exe"
            Args     = ""
            Icon     = "`${TOOLS}\nirsoft\LastActivityView.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Browser\MZCacheView.lnk"
            Target   = "`${TOOLS}\nirsoft\MZCacheView.exe"
            Args     = ""
            Icon     = "`${TOOLS}\nirsoft\MZCacheView.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Browser\MZCookiesView.lnk"
            Target   = "`${TOOLS}\nirsoft\mzcv.exe"
            Args     = ""
            Icon     = "`${TOOLS}\nirsoft\mzcv.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\nirsoft\BrowsingHistoryView.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\Tools\nirsoft\ChromeCacheView.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\Tools\nirsoft\IECacheView.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\Tools\nirsoft\iecv.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\Tools\nirsoft\LastActivityView.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\Tools\nirsoft\MZCacheView.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\Tools\nirsoft\mzcv.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".db", ".sqlite")
    Tags = @("browser-forensics", "artifact-extraction")
    Notes = "NirSoft browser utilities for cache and history analysis."
    Tips = "Tools are installed in ${TOOLS}\nirsoft."
    Usage = "Use these utilities to inspect browser artifacts."
    SampleCommands = @(
        "N/A"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# Get winpmem
$status = Get-FileFromUri -uri "https://github.com/Velocidex/c-aff4/raw/master/tools/pmem/resources/winpmem/winpmem_64.sys" -FilePath ".\downloads\winpmem_64.sys" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "winpmem"
    Homepage = "https://github.com/Velocidex/c-aff4"
    Vendor = "Velocidex"
    License = "Apache License 2.0"
    Category = "Memory"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\downloads\winpmem_64.sys"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".raw", ".aff4")
    Tags = @("memory-forensics", "acquisition")
    Notes = "winpmem is a Windows memory acquisition driver."
    Tips = "The driver is downloaded to C:\downloads."
    Usage = "Use winpmem with compatible acquisition tools."
    SampleCommands = @(
        "N/A"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# Binary Ninja - manual installation
if (Test-ToolIncluded -ToolName "Binary Ninja") {
    $status = Get-FileFromUri -uri "https://cdn.binary.ninja/installers/binaryninja_free_win64.exe" -FilePath ".\downloads\binaryninja.exe" -check "PE32"
}

$TOOL_DEFINITIONS += @{
    Name = "Binary Ninja"
    Homepage = "https://binary.ninja/"
    Vendor = "Vector 35"
    License = "Proprietary"
    Category = "Reverse Engineering"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Reverse Engineering\Binary Ninja (runs dfirws-install -BinaryNinja).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -BinaryNinja"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -BinaryNinja"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Users\WDAGUtilityAccount\AppData\Local\Programs\Vector35\BinaryNinja\binaryninja.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".elf", ".bin", ".so", ".dylib")
    Tags = @("reverse-engineering", "disassembler", "decompiler")
    Notes = "Binary Ninja is a reverse engineering platform."
    Tips = "After installation, the shortcut is replaced with the installed application."
    Usage = "Use Binary Ninja to analyze binaries."
    SampleCommands = @(
        "binaryninja.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# gpg4win
$status = Get-FileFromUri -uri "https://files.gpg4win.org/gpg4win-latest.exe" -FilePath ".\downloads\gpg4win.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "Gpg4win"
    Homepage = "https://www.gpg4win.org/"
    Vendor = "Gpg4win Project"
    License = "Open source"
    Category = "Utilities\Cryptography"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Cryptography\gpg4win (runs dfirws-install -Gpg4win).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Gpg4win"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Gpg4win"
    Verify = @(
        @{
            Type = "command"
            Name = "gpg"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".gpg", ".asc", ".pgp")
    Tags = @("encryption", "pgp", "signing")
    Notes = "Gpg4win provides GnuPG and related tools for Windows."
    Tips = "After installation, the shortcut is replaced with the installed application."
    Usage = "Gpg4win includes GPG, Kleopatra, and other tools for encryption and signing."
    SampleCommands = @(
        "gpg --version"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# Tor browser
$TorBrowserUrl = Get-DownloadUrlFromPage -Url "https://www.torproject.org/download/" -RegEx '/dist/[^"]+exe'
$status = Get-FileFromUri -uri "https://www.torproject.org$TorBrowserUrl" -FilePath ".\downloads\torbrowser.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "Tor Browser"
    Homepage = "https://www.torproject.org/"
    Vendor = "Tor Project"
    License = "Open source"
    Category = "Utilities\Browsers"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Browsers\Tor Browser (runs dfirws-install -Tor).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Tor"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Tor"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Users\WDAGUtilityAccount\Desktop\Tor Browser\Browser\firefox.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".html", ".htm")
    Tags = @("browser", "privacy", "network")
    Notes = "Tor Browser is a privacy-focused web browser based on Firefox."
    Tips = "After installation, the shortcut is replaced with the installed application."
    Usage = "Tor Browser routes traffic through the Tor network for privacy."
    SampleCommands = @(
        "firefox.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

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

$TOOL_DEFINITIONS += @{
    Name = "DCode"
    Homepage = "https://www.digital-detective.net/dcode/"
    Vendor = "Digital Detective"
    License = "Proprietary"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\DCode (runs dfirws-install -DCode).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -DCode"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -DCode"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Program Files (x86)\Digital Detective\DCode v5\DCode.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("timestamp", "forensics", "decoding")
    Notes = "DCode is a date/time conversion and analysis tool."
    Tips = "After installation, the shortcut is replaced with the installed application."
    Usage = "DCode helps convert and analyze timestamps across formats and timezones."
    SampleCommands = @(
        "DCode.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# Veracrypt - manual installation
$VeracryptUrl = Get-DownloadUrlFromPage -Url "https://www.veracrypt.fr/en/Downloads.html" -RegEx 'https://[^"]+VeraCrypt_Setup[^"]+.msi'
$status = Get-FileFromUri -uri "${VeracryptUrl}" -FilePath ".\downloads\veracrypt.msi" -check "Composite Document File V2 Document"

$TOOL_DEFINITIONS += @{
    Name = "VeraCrypt"
    Homepage = "https://www.veracrypt.fr/"
    Vendor = "IDRIX"
    License = "VeraCrypt License"
    Category = "Utilities\Cryptography"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Cryptography\veracrypt (runs dfirws-install -Veracrypt).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Veracrypt"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Veracrypt"
    Verify = @(
        @{
            Type = "command"
            Name = "veracrypt"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".hc", ".tc")
    Tags = @("encryption", "disk-encryption")
    Notes = "VeraCrypt is a disk encryption tool."
    Tips = "After installation, the shortcut is replaced with the installed application."
    Usage = "VeraCrypt enables encrypted containers and full-disk encryption."
    SampleCommands = @(
        "VeraCrypt.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# Microsoft OpenJDK 11 - installed during start
$MicrosoftJDKUrl = get-downloadUrlFromPage -url "https://learn.microsoft.com/en-us/java/openjdk/download" -RegEx 'https://aka.ms/download-jdk/microsoft-jdk-11.[.0-9]+-windows-x64.msi'
$status = Get-FileFromUri -uri "${MicrosoftJDKUrl}" -FilePath ".\downloads\microsoft-jdk-11.msi" -CheckURL "Yes" -check "Composite Document File V2 Document"

$TOOL_DEFINITIONS += @{
    Name = "Microsoft OpenJDK 11"
    Homepage = "https://learn.microsoft.com/en-us/java/openjdk/download"
    Vendor = "Microsoft"
    License = "GPLv2 with Classpath Exception"
    LicenseUrl = "https://openjdk.org/legal/gplv2+ce.html"
    Category = "Development"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("java", "runtime", "development")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# https://neo4j.com/deployment-center/#community - Neo4j - installed during start
if (Test-ToolIncluded -ToolName "Neo4j") {
    $NeoVersion = Get-DownloadUrlFromPage -Url "https://neo4j.com/deployment-center/#community" -RegEx '4.4.[^"]+-windows\.zip'
    $status = Get-FileFromUri -uri "https://neo4j.com/artifact.php?name=neo4j-community-${NeoVersion}" -FilePath ".\downloads\neo4j.zip" -CheckURL "Yes" -check "Zip archive data"
}

$TOOL_DEFINITIONS += @{
    Name = "Neo4j"
    Homepage = "https://neo4j.com/"
    Vendor = "Neo4j"
    License = "Neo4j Community License"
    Category = "Files and apps\Database"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Database\Neo4j 4 (runs dfirws-install -Neo4j).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Neo4j"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Neo4j"
    Verify = @(
        @{
            Type = "command"
            Name = "neo4j"
            Expect = "ASCII"
        }
    )
    FileExtensions = @()
    Tags = @("database", "graph", "visualization")
    Notes = "Neo4j is a graph database."
    Tips = "After installation, the shortcut is replaced with the installed application."
    Usage = "Neo4j stores data as nodes and relationships for graph analysis."
    SampleCommands = @(
        "neo4j.bat console"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# recbin
$status = Get-FileFromUri -uri "https://github.com/keydet89/Tools/raw/refs/heads/master/exe/recbin.exe" -FilePath ".\downloads\recbin.exe" -check "PE32"
if ($status) {
    if (Test-Path -Path "${TOOLS}\bin\recbin.exe") {
        Remove-Item -Force "${TOOLS}\bin\recbin.exe" | Out-Null 2>&1
    }
    Copy-Item ".\downloads\recbin.exe" "${TOOLS}\bin\recbin.exe"
}

$TOOL_DEFINITIONS += @{
    Name = "recbin"
    Homepage = "https://github.com/keydet89/Tools"
    Vendor = "keydet89"
    License = "Unspecified"
    Category = "OS\Windows"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\recbin (Parse Windows Recycle Bin INFO2 & `$Ixxxxx files in binary mode).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command recbin.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\bin\recbin.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".bin")
    Tags = @("binary-analysis", "carving")
    Notes = "recbin parses Windows Recycle Bin files."
    Tips = "recbin is installed in ${TOOLS}\bin."
    Usage = "Use recbin to parse `$I` and INFO2 files."
    SampleCommands = @(
        "recbin.exe -h"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# capa Explorer web
$status = Get-FileFromUri -uri "https://mandiant.github.io/capa/explorer/capa-explorer-web.zip" -FilePath ".\downloads\capa-explorer-web.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\capa-explorer-web") {
        Remove-Item -Recurse -Force "${TOOLS}\capa-explorer-web" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\capa-explorer-web.zip" -o"${TOOLS}" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "capa Explorer Web"
    Homepage = "https://mandiant.github.io/capa/"
    Vendor = "Mandiant"
    License = "Apache License 2.0"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\capa Explorer Web.lnk"
            Target   = "`${TOOLS}\capa-explorer-web\index.html"
            Args     = ""
            Icon     = "`${TOOLS}\capa\capa.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\capa-explorer-web\index.html"
            Expect = "HTML"
        }
    )
    FileExtensions = @(".exe", ".dll")
    Tags = @("malware-analysis", "capability-analysis", "visualization")
    Notes = "capa Explorer Web is a web UI for exploring capa results."
    Tips = "Open the HTML file in a browser."
    Usage = "Use it to explore capa output."
    SampleCommands = @(
        "index.html"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# https://www.libreoffice.org/download/download-libreoffice/ - LibreOffice - installed during start
if (Test-ToolIncluded -ToolName "LibreOffice") {
    $LibreOfficeVersionDownloadPage = Get-DownloadUrlFromPage -Url "https://www.libreoffice.org/download/download-libreoffice/" -RegEx 'https://[^"]+.msi'
    $LibreOfficeVersionDownloadPage_64 = $LibreOfficeVersionDownloadPage.Replace("dl/win-x86/", "dl/win-x86_64/").Replace("x86.msi", "x86-64.msi").Replace("https://download.documentfoundation.org/libreoffice/stable/", "https://www.libreoffice.org/donate/dl/")
    $LibreOfficeVersion = Get-DownloadUrlFromPage -Url "${LibreOfficeVersionDownloadPage_64}" -RegEx 'https://[^"]+.msi'
    $status = Get-FileFromUri -uri ${LibreOfficeVersion} -FilePath ".\downloads\LibreOffice.msi" -CheckURL "Yes" -check "Composite Document File V2 Document"
}

$TOOL_DEFINITIONS += @{
    Name = "LibreOffice"
    Homepage = "https://www.libreoffice.org/"
    Vendor = "The Document Foundation"
    License = "Mozilla Public License 2.0"
    Category = "Files and apps\Office"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\LibreOffice (runs dfirws-install -LibreOffice).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -LibreOffice"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -LibreOffice"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Program Files\LibreOffice\program\soffice.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx", ".odt", ".ods", ".odp")
    Tags = @("office", "document-viewer")
    Notes = "LibreOffice is a free and open-source office suite."
    Tips = "After installation, the shortcut is replaced with the installed application."
    Usage = "LibreOffice provides Writer, Calc, Impress, and other office tools."
    SampleCommands = @(
        "soffice.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# https://npcap.com/#download - Npcap - available for manual installation
$NpcapVersion = Get-DownloadUrlFromPage -Url "https://npcap.com/" -RegEx 'dist/npcap-[.0-9]+.exe'
$status = Get-FileFromUri -uri "https://npcap.com/${NpcapVersion}" -FilePath ".\downloads\npcap.exe" -CheckURL "Yes" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "Npcap"
    Homepage = "https://npcap.com/"
    Vendor = "Nmap Project"
    License = "Npcap License"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".pcap", ".pcapng")
    Tags = @("network-analysis", "packet-capture")
    Notes = "Npcap packet capture driver installer."
    Tips = "This is a manual install."
    Usage = "Install Npcap to enable packet capture tools."
    SampleCommands = @(
        "npcap.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# https://www.sqlite.org/download.html - SQLite
$SQLiteVersion = Get-DownloadUrlFromPage -Url "https://sqlite.org/download.html" -RegEx '[0-9]+/sqlite-tools-win-x64-[^"]+.zip'
$status = Get-FileFromUri -uri "https://sqlite.org/${SQLiteVersion}" -FilePath ".\downloads\sqlite.zip" -CheckURL "Yes"
if ($status) {
    if (Test-Path -Path "${TOOLS}\sqlite") {
        Remove-Item -Recurse -Force "${TOOLS}\sqlite" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\sqlite.zip" -o"${TOOLS}\sqlite" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "SQLite Tools"
    Homepage = "https://sqlite.org/download.html"
    Vendor = "SQLite"
    License = "Public Domain"
    Category = "Files and apps\Database"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "sqldiff"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "sqlite3"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".db", ".sqlite", ".sqlite3")
    Tags = @("database", "sqlite", "cli")
    Notes = "SQLite command-line tools."
    Tips = "Tools are installed in ${TOOLS}\sqlite."
    Usage = "Use sqlite3 and companion tools to inspect SQLite databases."
    SampleCommands = @(
        "sqlite3 --help"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# OpenVPN - manual installation
$status = Get-FileFromUri -uri "https://openvpn.net/downloads/openvpn-connect-v3-windows.msi" -FilePath ".\downloads\openvpn.msi" -check "Composite Document File V2 Document"

$TOOL_DEFINITIONS += @{
    Name = "OpenVPN Connect"
    Homepage = "https://openvpn.net/client/"
    Vendor = "OpenVPN"
    License = "Proprietary"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\downloads\openvpn.msi"
            Expect = "MSI Installer"
        }
    )
    FileExtensions = @(".ovpn")
    Tags = @("vpn", "network")
    Notes = "OpenVPN Connect installer."
    Tips = "This is a manual install."
    Usage = "Install the MSI to use OpenVPN Connect."
    SampleCommands = @(
        "msiexec /i C:\downloads\openvpn.msi"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# https://downloads.digitalcorpora.org/downloads/bulk_extractor - bulk_extractor
$digitalcorpora_url = "https://digitalcorpora.s3.amazonaws.com/downloads/bulk_extractor/bulk_extractor-2.0.0-windows.zip"
$status = Get-FileFromUri -uri "${digitalcorpora_url}" -FilePath ".\downloads\bulk_extractor.zip" -CheckURL "Yes" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\bulk_extractor") {
        Remove-Item -Recurse -Force "${TOOLS}\bulk_extractor" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\bulk_extractor.zip" -o"${TOOLS}\bulk_extractor" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "bulk_extractor"
    Homepage = "https://downloads.digitalcorpora.org/downloads/bulk_extractor/"
    Vendor = "Digital Corpora"
    License = "Open source"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\bulk_extractor64.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command bulk_extractor64.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "bulk_extractor64"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".dd", ".raw", ".E01", ".img")
    Tags = @("forensics", "carving", "data-extraction")
    Notes = "bulk_extractor extracts features such as email addresses and URLs from disk images."
    Tips = "bulk_extractor is installed in ${TOOLS}\bulk_extractor."
    Usage = "Use bulk_extractor for bulk feature extraction from disk images and files."
    SampleCommands = @(
        "bulk_extractor64.exe -h"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
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

$TOOL_DEFINITIONS += @{
    Name = "DensityScout"
    Homepage = "https://cert.at/en/downloads/software/software-densityscout"
    Vendor = "CERT.at"
    License = "Freeware"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\densityscout (calculates density (like entropy)).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command densityscout -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "densityscout"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".bin")
    Tags = @("malware-analysis", "entropy-analysis")
    Notes = "DensityScout calculates file entropy and density."
    Tips = "DensityScout is installed in ${TOOLS}\bin."
    Usage = "Use DensityScout to compute entropy-like metrics on files."
    SampleCommands = @(
        "densityscout -h"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
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

$TOOL_DEFINITIONS += @{
    Name = "Nmap"
    Homepage = "https://nmap.org/"
    Vendor = "Nmap Project"
    License = "Nmap Public Source License"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "`${TOOLS}\nmap\nmap.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\nmap\ncat.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("network-analysis", "port-scanning", "reconnaissance")
    Notes = "Nmap is a network exploration and security auditing tool."
    Tips = "Nmap is installed in ${TOOLS}\nmap."
    Usage = "Use Nmap to scan hosts and services."
    SampleCommands = @(
        "nmap --help"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
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

$TOOL_DEFINITIONS += @{
    Name = "FASM"
    Homepage = "https://flatassembler.net/"
    Vendor = "Flat Assembler"
    License = "Freeware"
    Category = "Reverse Engineering"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Reverse Engineering\fasm.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command fasm.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "FASM"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".asm")
    Tags = @("reverse-engineering", "assembler")
    Notes = "FASM is a fast assembler for x86 and x86-64 architectures."
    Tips = "FASM is installed in ${TOOLS}\fasm."
    Usage = "Use FASM to assemble x86/x64 source code."
    SampleCommands = @(
        "fasm.exe -h"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# Terminal for Windows - automatically installed during start
$status = Get-FileFromUri -uri "https://aka.ms/terminal-canary-zip-x64" -FilePath ".\downloads\terminal.zip" -CheckURL "Yes" -check "Zip archive data"

$TOOL_DEFINITIONS += @{
    Name = "Windows Terminal (Canary)"
    Homepage = "https://aka.ms/terminal"
    Vendor = "Microsoft"
    License = "MIT License"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("terminal", "shell")
    Notes = "Windows Terminal Canary package."
    Tips = "This is downloaded during setup."
    Usage = "Use Windows Terminal for shell access."
    SampleCommands = @(
        "wt.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# https://procdot.com/downloadprocdotbinaries.htm - Procdot
$procdot_path = Get-DownloadUrlFromPage -url "https://procdot.com/downloadprocdotbinaries.htm" -RegEx 'download[^"]+windows.zip'
$status = Get-FileFromUri -uri "https://procdot.com/${procdot_path}" -FilePath ".\downloads\procdot.zip" -CheckURL "Yes" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\procdot") {
        Remove-Item -Recurse -Force "${TOOLS}\procdot" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -pprocdot -aoa "${SETUP_PATH}\procdot.zip" -o"${TOOLS}\procdot" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "ProcDOT"
    Homepage = "https://procdot.com/"
    Vendor = "ProcDOT"
    License = "Freeware"
    Category = "OS\Windows"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\procdot.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command procdot.exe"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "`${TOOLS}\procdot\win64\procdot.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".csv", ".log")
    Tags = @("malware-analysis", "visualization", "dynamic-analysis")
    Notes = "ProcDOT is a visual malware analysis tool for process, file, and network activity."
    Tips = "ProcDOT is installed in ${TOOLS}\procdot."
    Usage = "Use ProcDOT to visualize procmon logs."
    SampleCommands = @(
        "procdot.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
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

$TOOL_DEFINITIONS += @{
    Name = "geolocus-cli"
    Homepage = "https://codeberg.org/hrbrmstr/geolocus-cli"
    Vendor = "hrbrmstr"
    License = "MIT License"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\geolocus (Geolocation tool).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command geolocus-cli.exe -h"
            Icon     = ""
            WorkDir  = "C:\enrichment\geolocus"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "geolocus-cli.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".json")
    Tags = @("geolocation", "osint")
    Notes = "geolocus-cli is a geolocation lookup tool."
    Tips = "geolocus-cli is installed in ${TOOLS}\bin."
    Usage = "Use geolocus-cli for IP geolocation lookups."
    SampleCommands = @(
        "geolocus-cli.exe -h"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @("enrichment")
}

# https://www.graphviz.org/download/ - Graphviz - available for manual installation
$graphviz_url = Get-DownloadUrlFromPage -url "https://www.graphviz.org/download/" -RegEx 'https://[^"]+win64.exe'
$status = Get-FileFromUri -uri "${graphviz_url}" -FilePath ".\downloads\graphviz.exe" -CheckURL "Yes" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "Graphviz"
    Homepage = "https://www.graphviz.org/"
    Vendor = "Graphviz"
    License = "Eclipse Public License 1.0"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Graphviz.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dot -?"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "`${env:ProgramFiles}\Graphviz\bin\dot.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".dot", ".gv")
    Tags = @("visualization", "graph")
    Notes = "Graphviz is a graph visualization software suite."
    Tips = "Graphviz is installed via its MSI and adds tools like dot."
    Usage = "Use dot to render graphs from DOT files."
    SampleCommands = @(
        "dot -?"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# http://www.rohitab.com/apimonitor - API Monitor - installed during start
$status = Get-FileFromUri -uri "http://www.rohitab.com/download/api-monitor-v2r13-setup-x64.exe" -FilePath ".\downloads\apimonitor64.exe" -CheckURL "Yes" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "API Monitor"
    Homepage = "http://www.rohitab.com/apimonitor"
    Vendor = "Rohitab"
    License = "Proprietary"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -ApiMonitor"
    Verify = @(
        @{
            Type = "command"
            Name = "apimonitor-x86.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "apimonitor-x64.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll")
    Tags = @("reverse-engineering", "api-tracing", "dynamic-analysis")
    Notes = "API Monitor is a tool for monitoring Windows API calls."
    Tips = "After installation, API Monitor is added to the system path."
    Usage = "Use API Monitor to trace API calls in processes."
    SampleCommands = @(
        "apimonitor-x64.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

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

$TOOL_DEFINITIONS += @{
    Name = "JavaFX SDK"
    Homepage = "https://gluonhq.com/products/javafx/"
    Vendor = "Gluon"
    License = "GPL + Classpath Exception"
    Category = "Programming"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".jar")
    Tags = @("java", "gui", "runtime")
    Notes = "JavaFX SDK provides UI libraries for Java applications."
    Tips = "JavaFX SDK is installed in ${TOOLS}\javafx-sdk."
    Usage = "Use JavaFX SDK with Java development."
    SampleCommands = @(
        "N/A"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# https://bitbucket.org/iBotPeaches/apktool/downloads/ - apktool
$apktool_version = Get-DownloadUrlFromPage -url "https://apktool.org/" -RegEx 'apktool_[^"]+'
$status = Get-FileFromUri -uri "https://bitbucket.org/iBotPeaches/apktool/downloads/${apktool_version}" -FilePath ".\downloads\apktool.jar" -CheckURL "Yes" -check "Zip archive data"
if ($status) {
    Copy-Item ".\downloads\apktool.jar" "${TOOLS}\bin\apktool.jar" -Force
    Copy-Item "setup\utils\apktool.bat" "${TOOLS}\bin\apktool.bat" -Force
}

$TOOL_DEFINITIONS += @{
    Name = "apktool"
    Homepage = "https://apktool.org/"
    Vendor = "iBotPeaches"
    License = "Apache License 2.0"
    Category = "OS\Android"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Android\apktool.bat.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command apktool.bat -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "apktool.jar"
            Expect = "Zip archive data"
        }
    )
    FileExtensions = @(".apk")
    Tags = @("reverse-engineering", "android", "decompiler")
    Notes = "apktool is a tool for reverse engineering Android APK files."
    Tips = "apktool is installed in ${TOOLS}\bin."
    Usage = "Use apktool to decode and rebuild APK files."
    SampleCommands = @(
        "apktool.bat -h"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
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

$TOOL_DEFINITIONS += @{
    Name = "PHP"
    Homepage = "https://www.php.net/"
    Vendor = "PHP Group"
    License = "PHP License"
    Category = "Programming"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Programming\php.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command php -v"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "php"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".php")
    Tags = @("scripting", "web")
    Notes = "PHP is a scripting language widely used for web development."
    Tips = "PHP is installed in ${TOOLS}\php."
    Usage = "Use PHP to run scripts and utilities."
    SampleCommands = @(
        "php -v"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# https://hashcat.net/hashcat/ - hashcat
if (Test-ToolIncluded -ToolName "hashcat") {
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
}

$TOOL_DEFINITIONS += @{
    Name = "hashcat"
    Homepage = "https://hashcat.net/hashcat/"
    Vendor = "hashcat"
    License = "MIT License"
    Category = "Utilities\Cryptography"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Cryptography\hashcat (runs dfirws-install -Hashcat).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Hashcat"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Hashcat"
    Verify = @(
        @{
            Type = "command"
            Name = "hashcat"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("password-cracking", "hashing")
    Notes = "hashcat is a password recovery tool."
    Tips = "After installation, the shortcut is replaced with the installed application."
    Usage = "hashcat supports GPU-accelerated password recovery."
    SampleCommands = @(
        "hashcat --help"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# Drivers for hashcat
if (Test-ToolIncluded -ToolName "hashcat") {
    $intel_driver = Get-DownloadUrlFromPage -url "https://www.intel.com/content/www/us/en/developer/articles/technical/intel-cpu-runtime-for-opencl-applications-with-sycl-support.html" -RegEx 'https://[^"]+\.exe'
    $status = Get-FileFromUri -uri "${intel_driver}" -FilePath ".\downloads\intel_driver.exe" -CheckURL "Yes" -check "PE32"
}

# Mex for WinDbg
$status = Get-FileFromUri -uri "https://download.microsoft.com/download/0/c/4/0c4c45e3-bf02-49bf-8d68-6fa611f442e6/Mex.exe" -FilePath ".\downloads\mex.exe" -CheckURL "Yes" -check "PE32"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\mex.exe" -o"${SETUP_PATH}" | Out-Null
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\mex.zip" -o"${TOOLS}\mex" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "MEX"
    Homepage = "https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/"
    Vendor = "Microsoft"
    License = "Proprietary"
    Category = "Development"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".dmp")
    Tags = @("debugging", "windbg", "dotnet")
    Notes = "MEX is an extension for WinDbg."
    Tips = "MEX is installed in ${TOOLS}\mex."
    Usage = "Use MEX with WinDbg."
    SampleCommands = @(
        "N/A"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

# ELK
if (Test-ToolIncluded -ToolName "Elastic Stack (ELK + Beats)") {
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
}

$TOOL_DEFINITIONS += @{
    Name = "Elastic Stack (ELK + Beats)"
    Homepage = "https://www.elastic.co/elastic-stack"
    Vendor = "Elastic"
    License = "Elastic License"
    Category = "Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".json", ".log")
    Tags = @("siem", "log-analysis", "elasticsearch", "visualization")
    Notes = "Downloads Elasticsearch, Kibana, Logstash, Elastic Agent, and Beats."
    Tips = "Packages are downloaded to ${SETUP_PATH}."
    Usage = "Use the downloaded zips to install ELK components."
    SampleCommands = @(
        "N/A"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

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

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "http"
