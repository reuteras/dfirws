# Set variables
$DATA = "C:\data"
$GIT = "C:\git"
$LOCAL_PATH = "C:\local"
$NEO_JAVA = "C:\java"
$PDFSTREAMDUMPER = "C:\Sandsprite\PDFStreamDumper"
$SETUP_PATH = "C:\downloads"
$TEMP = "C:\tmp"
$TOOLS = "C:\Tools"
$VENV = "C:\venv"

$null=$DATA
$null=$GIT
$null=$LOCAL_PATH
$null=$PDFSTREAMDUMPER

# Declare helper functions
function Add-ToUserPath {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $dir
    )

    #$dir = (Resolve-Path $dir)

    $path = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
    if (!($path.Contains($dir))) {
        # append dir to path
        [Environment]::SetEnvironmentVariable("PATH", $path + ";$dir", [EnvironmentVariableTarget]::User)
        Write-Output "Added $dir to PATH"
        return
    }
    Write-Error "$dir is already in PATH"
}

function Add-Shortcut {
    param (
        [string]$SourceLnk,
        [string]$DestinationPath,
        [string]$WorkingDirectory,
        [string]$Iconlocation,
        [switch]$IconArrayLocation
    )
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($SourceLnk)
    if ($Null -ne $WorkingDirectory) {
        $Shortcut.WorkingDirectory = $WorkingDirectory
    }
    if ($Null -ne $Iconlocation) {
        if ($Null -eq $IconArrayLocation) {
            $IconArrayLocation = 0
        }
        $Shortcut.Iconlocation = "$Iconlocation, $IconArrayLocation"
    }
    $Shortcut.TargetPath = $DestinationPath
    $Shortcut.Save()
}

function Update-WallPaper {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [parameter(Mandatory = $true)][String]$path
    )
    if($PSCmdlet.ShouldProcess($file.Name)) {
        & "$HOME\Documents\tools\Update-WallPaper" $path
    }
    C:\Tools\sysinternals\Bginfo64.exe /NOLICPROMPT /timer:0 $HOME\Documents\tools\config.bgi
}

# Write a log with a timestamp
function Write-DateLog {
    param (
        [Parameter(Mandatory=$True)] [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $fullMessage = "$timestamp - $Message"
    Write-Output $fullMessage
}

# Functions to help install programs
function Install-Apimonitor {
    Copy-Item "$SETUP_PATH\apimonitor64.exe" "$TEMP"
    & $TEMP\apimonitor64.exe /s /v/qn
    Add-ToUserPath "${env:ProgramFiles(x86)}\rohitab.com\API Monitor"
}

function Install-Autopsy {
    msiexec.exe /i "$SETUP_PATH\autopsy.msi" /qn /norestart
}

function Install-BashExtra {
    Set-Location "$env:ProgramFiles\Git"
    Get-ChildItem -Path $SETUP_PATH\bash -Include "*.tar" -Recurse |
        ForEach-Object {
            $command = "tar.exe -x -vf /C/downloads/bash/" + $_.Name
            &"$env:ProgramFiles\Git\bin\bash.exe" -c "$command"
        }    
}

function Install-Choco {
    & "$SETUP_PATH\choco\tools\chocolateyInstall.ps1"
}

function Install-CMDer {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\cmder.7z" -o"$env:ProgramFiles\cmder"
    Add-ToUserPath "$env:ProgramFiles\cmder"
    Add-ToUserPath "$env:ProgramFiles\cmder\bin"
    Write-Output "$VENV\default\scripts\activate.bat" | Out-File -Append -Encoding "ascii" $env:ProgramFiles\cmder\config\user_profile.cmd
    & "$env:ProgramFiles\cmder\cmder.exe" /REGISTER ALL
}

function Install-GitBash {
    Copy-Item "$SETUP_PATH\git.exe" "$TEMP\git.exe"
    Copy-Item "$HOME\Documents\tools\.bashrc" "$HOME\"
    & "$TEMP\git.exe" /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"
}

function Install-GoLang {
    Copy-Item "$SETUP_PATH\golang.msi" "$TEMP\golang.msi"
    Start-Process -Wait msiexec -ArgumentList "/i $TEMP\golang.msi /qn /norestart"
    Add-ToUserPath "$env:ProgramFiles\Go\bin"
}
function Install-LibreOffice {
    Copy-Item "$SETUP_PATH\LibreOffice.msi" "$TEMP\LibreOffice.msi"
    Start-Process -Wait msiexec -ArgumentList "/qb /i $TEMP\LibreOffice.msi /l* $TEMP\LibreOffice_install_log.txt REGISTER_ALL_MSO_TYPES=1 UI_LANGS=en_US ISCHECKFORPRODUCTUPDATES=0 REBOOTYESNO=No QUICKSTART=0 ADDLOCAL=ALL VC_REDIST=0 REMOVE=gm_o_Onlineupdate,gm_r_ex_Dictionary_Af,gm_r_ex_Dictionary_An,gm_r_ex_Dictionary_Ar,gm_r_ex_Dictionary_Be,gm_r_ex_Dictionary_Bg,gm_r_ex_Dictionary_Bn,gm_r_ex_Dictionary_Bo,gm_r_ex_Dictionary_Br,gm_r_ex_Dictionary_Pt_Br,gm_r_ex_Dictionary_Bs,gm_r_ex_Dictionary_Pt_Pt,gm_r_ex_Dictionary_Ca,gm_r_ex_Dictionary_Cs,gm_r_ex_Dictionary_Da,gm_r_ex_Dictionary_Nl,gm_r_ex_Dictionary_Et,gm_r_ex_Dictionary_Gd,gm_r_ex_Dictionary_Gl,gm_r_ex_Dictionary_Gu,gm_r_ex_Dictionary_He,gm_r_ex_Dictionary_Hi,gm_r_ex_Dictionary_Hu,gm_r_ex_Dictionary_Lt,gm_r_ex_Dictionary_Lv,gm_r_ex_Dictionary_Ne,gm_r_ex_Dictionary_No,gm_r_ex_Dictionary_Oc,gm_r_ex_Dictionary_Pl,gm_r_ex_Dictionary_Ro,gm_r_ex_Dictionary_Ru,gm_r_ex_Dictionary_Si,gm_r_ex_Dictionary_Sk,gm_r_ex_Dictionary_Sl,gm_r_ex_Dictionary_El,gm_r_ex_Dictionary_Es,gm_r_ex_Dictionary_Te,gm_r_ex_Dictionary_Th,gm_r_ex_Dictionary_Tr,gm_r_ex_Dictionary_Uk,gm_r_ex_Dictionary_Vi,gm_r_ex_Dictionary_Zu,gm_r_ex_Dictionary_Sq,gm_r_ex_Dictionary_Hr,gm_r_ex_Dictionary_De,gm_r_ex_Dictionary_Id,gm_r_ex_Dictionary_Is,gm_r_ex_Dictionary_Ko,gm_r_ex_Dictionary_Lo,gm_r_ex_Dictionary_Mn,gm_r_ex_Dictionary_Sr,gm_r_ex_Dictionary_Eo,gm_r_ex_Dictionary_It,gm_r_ex_Dictionary_Fr"
}

function Install-Neo4j {
    Copy-Item "$SETUP_PATH\microsoft-jdk-11.msi" "$TEMP\microsoft-jdk-11.msi"
    Start-Process -Wait msiexec -ArgumentList "/i $TEMP\microsoft-jdk-11.msi ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome INSTALLDIR=$NEO_JAVA /qn /norestart"
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\neo4j.zip" -o"$env:ProgramFiles"
    Move-Item $env:ProgramFiles\neo4j-community* $env:ProgramFiles\neo4j
    Add-ToUserPath "$env:ProgramFiles\neo4j\bin"
    & "$env:ProgramFiles\neo4j\bin\neo4j-admin" set-initial-password neo4j
    Copy-Item -Recurse "$TOOLS\neo4j" "$env:ProgramFiles"
}

function Install-Node {
    Copy-Item -r "$TOOLS\node" $HOME\Desktop    
}

function Install-PDFStreamDumper {
    Copy-Item "$SETUP_PATH\PDFStreamDumper.exe" "$TEMP\PDFStreamDumper.exe"
    & "$TEMP\PDFStreamDumper.exe" /verysilent
}

function  Install-Ruby {
    & "$SETUP_PATH\ruby.exe" /verysilent /allusers /dir="$env:ProgramFiles\ruby"
    Add-ToUserPath "$env:ProgramFiles\ruby\bin"
}

function Install-VSCode {
    Copy-Item "$SETUP_PATH\vscode.exe" "$TEMP\vscode.exe"
    Start-Process -Wait "$TEMP\vscode.exe" -ArgumentList '/verysilent /suppressmsgboxes /MERGETASKS="!runcode,desktopicon,quicklaunchicon,addcontextmenufiles,addcontextmenufolders,addtopath"'
    if ($WSDFIR_VSCODE_POWERSHELL -eq "Yes") {
        Start-Process "$HOME\AppData\Local\Programs\Microsoft VS Code\bin\code" -ArgumentList '--install-extension "$SETUP_PATH\vscode\vscode-powershell.vsix"' -WindowStyle Hidden
    }
    if ($WSDFIR_VSCODE_PYTHON -eq "Yes") {
        Start-Process "$HOME\AppData\Local\Programs\Microsoft VS Code\bin\code" -ArgumentList '--install-extension "$SETUP_PATH\vscode\vscode-python.vsix"' -WindowStyle Hidden
    }
    if ($WSDFIR_VSCODE_SPELL -eq "Yes") {
        Start-Process "$HOME\AppData\Local\Programs\Microsoft VS Code\bin\code" -ArgumentList '--install-extension "$SETUP_PATH\vscode\vscode-spell-checker.vsix"' -WindowStyle Hidden
    }
}

function Install-X64dbg {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\x64dbg.zip" -o"$env:ProgramFiles\x64dbg"
    Add-ToUserPath "$env:ProgramFiles\x64dbg\release\x32"
    Add-ToUserPath "$env:ProgramFiles\x64dbg\release\x64"
}
function Install-Zui {
    Copy-Item "$SETUP_PATH\zui.exe" "$TEMP\zui.exe"
    & "$TEMP\zui.exe" /S /AllUsers
}