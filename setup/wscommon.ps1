# Set variables
$DATA = "C:\data"
$ENRICHMENT = "C:\enrichment"
$GIT_PATH = "C:\git"
$LOCAL_PATH = "C:\local"
$NEO_JAVA = "C:\java"
$PDFSTREAMDUMPER_PATH = "C:\Sandsprite\PDFStreamDumper"
$RUST_DIR = "C:\Rust"
$SETUP_PATH = "C:\downloads"
$WSDFIR_TEMP = "C:\tmp"
$TOOLS = "C:\Tools"
$VENV = "C:\venv"
$POWERSHELL_EXE = "${env:ProgramFiles}\PowerShell\7\pwsh.exe"

$null="${DATA}"
$null="${GIT_PATH}"
$null="${LOCAL_PATH}"
$null="${PDFSTREAMDUMPER_PATH}"
$null="${RUST_DIR}"
$null="${WSDFIR_TEMP}"

# Declare helper functions


<#
.SYNOPSIS
Adds a directory to the user's PATH environment variable.

.DESCRIPTION
The Add-ToUserPath function adds a specified directory to the user's PATH environment variable. This allows the user to run executables located in the specified directory from any location in the command prompt.

.PARAMETER dir
Specifies the directory to be added to the PATH environment variable. The directory must be a valid path.

.EXAMPLE
Add-ToUserPath -dir "C:\Program Files\MyApp"
Adds the directory "C:\Program Files\MyApp" to the user's PATH environment variable.

.NOTES
Author: Your Name
Date:   Current Date
#>
function Add-ToUserPath {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $dir
    )

    #$dir = (Resolve-Path $dir)

    $path = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
    if (!(${path}.Contains("${dir}"))) {
        # append dir to path
        [Environment]::SetEnvironmentVariable("PATH", "${path}" + ";${dir}", [EnvironmentVariableTarget]::User)
        Write-Output "Added ${dir} to PATH"
        return
    }
    Write-Output "${dir} is already in PATH"
}

function Add-Shortcut {
    param (
        [string]$SourceLnk,
        [string]$DestinationPath,
        [string]$WorkingDirectory = "${HOME}\Desktop",
        [string]$Iconlocation = $Null,
        [switch]$IconArrayLocation,
        [string]$Arguments = $Null
    )
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = ${WshShell}.CreateShortcut("${SourceLnk}")
    if ($Null -ne ${WorkingDirectory}) {
        $Shortcut.WorkingDirectory = "${WorkingDirectory}"
    }
    if ($Null -ne ${Iconlocation}) {
        if ($Null -eq ${IconArrayLocation}) {
            ${IconArrayLocation} = 0
        }
        ${Shortcut}.Iconlocation = "${Iconlocation}, ${IconArrayLocation}"
    }
    if ($Null -ne ${Arguments}) {
        ${Shortcut}.Arguments = "${Arguments}"
    }
    ${Shortcut}.TargetPath = "${DestinationPath}"
    ${Shortcut}.Save()
}

function Update-WallPaper {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [parameter(Mandatory = $true)][String]$path
    )
    if($PSCmdlet.ShouldProcess(${file}.Name)) {
        & "${HOME}\Documents\tools\Update-WallPaper" "${path}"
    }
    & "${TOOLS}\sysinternals\Bginfo64.exe" /NOLICPROMPT /timer:0 "${HOME}\Documents\tools\config.bgi"
}

# Write a log with a timestamp
function Write-DateLog {
    param (
        [Parameter(Mandatory=$True)] [string]$Message
    )
    ${timestamp} = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    ${fullMessage} = "${timestamp} - ${Message}"
    Write-Output "${fullMessage}"
}

# Functions to help install programs
function Install-Apimonitor {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-apimonitor.txt")) {
        Write-Output "Installing API Monitor"
        Copy-Item "${SETUP_PATH}\apimonitor64.exe" "${TEMP}" -Force
        & ${TEMP}\apimonitor64.exe /s /v/qn
        Add-ToUserPath "${env:ProgramFiles(x86)}\rohitab.com\API Monitor"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-apimonitor.txt" | Out-Null
    } else {
        Write-Output "API Monitor is already installed"
    }
}

function Install-Autopsy {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-autopsy.txt")) {
        Write-Output "Installing Autopsy"
        Copy-Item "${SETUP_PATH}\autopsy.msi" "${TEMP}\autopsy.msi" -Force
        Start-Process -Wait msiexec.exe -ArgumentList "/i ${TEMP}\autopsy.msi /qn /norestart"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-autopsy.txt" | Out-Null
    } else {
        Write-Output "Autopsy is already installed"
    }
}

function Install-BashExtra {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-gitbash.txt")) {
        Install-GitBash
    }
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-bash-extras.txt")) {
        Write-Output "Installing Bash extras"
        Set-Location "${env:ProgramFiles}\Git" | Out-Null
        Get-ChildItem -Path ${SETUP_PATH}\bash -Include "*.tar" -Recurse |
            ForEach-Object {
                $command = "tar.exe -x --overwrite -f /C/downloads/bash/" + $_.Name
                Start-Process -NoNewWindow -FilePath "${env:ProgramFiles}\Git\bin\bash.exe" -ArgumentList "-c '$command'"
            }
        if (Test-Path "${LOCAL_PATH}\.zshrc") {
            Copy-Item "${LOCAL_PATH}\.zshrc" "${HOME}\.zshrc" -Force
        } else {
            Copy-Item "${LOCAL_PATH}\defaults\.zshrc" "${HOME}\.zshrc" -Force
        }
        if (Test-Path "${LOCAL_PATH}\.zcompdump") {
            Copy-Item "${LOCAL_PATH}\.zcompdump" "${HOME}\.zcompdump" -Force
        } else {
            Copy-Item "${LOCAL_PATH}\defaults\.zcompdump" "${HOME}\.zcompdump" -Force
        }
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-bash-extras.txt" | Out-Null
    } else {
        Write-Output "Bash extras are already installed"
    }
}

function Install-BinaryNinja {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-binaryninja.txt")) {
        Write-Output "Installing Binary Ninja"
        Copy-Item "${SETUP_PATH}\binaryninja.exe" "${TEMP}\binaryninja.exe" -Force
        Start-Process -Wait "${TEMP}\binaryninja.exe" -ArgumentList '/S /V"/qn REBOOT=ReallySuppress"'
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-binaryninja.txt" | Out-Null
    } else {
        Write-Output "Binary Ninja is already installed"
    }

}
function Install-Choco {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-choco.txt")) {
        Write-Output "Installing Chocolatey"
        & "${SETUP_PATH}\choco\tools\chocolateyInstall.ps1"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-choco.txt" | Out-Null
    } else {
        Write-Output "Chocolatey is already installed"
    }
}

function Install-CMDer {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-cmder.txt")) {
        Write-Output "Installing Cmder"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\cmder.7z" -o"${env:ProgramFiles}\cmder"
        Add-ToUserPath "${env:ProgramFiles}\cmder"
        Add-ToUserPath "${env:ProgramFiles}\cmder\bin"
        Write-Output "$VENV\default\scripts\activate.bat" | Out-File -Append -Encoding "ascii" ${env:ProgramFiles}\cmder\config\user_profile.cmd
        & "${env:ProgramFiles}\cmder\cmder.exe" /REGISTER ALL
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-cmder.txt" | Out-Null
    } else {
        Write-Output "Cmder is already installed"
    }
}


function Install-Docker {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-docker.txt")) {
        Write-Output "Installing Docker"
        Copy-Item "${SETUP_PATH}\docker.exe" "${TEMP}\docker.exe" -Force
        Start-Process -Wait "${TEMP}\docker.exe" -ArgumentList 'install --quiet --accept-license'
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-docker.txt" | Out-Null
    } else {
        Write-Output "Docker is already installed"
    }
}
function Install-Dokany {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-dokany.txt")) {
        Write-Output "Installing Dokany"
        Copy-Item "${SETUP_PATH}\dokany.msi" "${TEMP}\dokany.msi" -Force
        Start-Process -Wait msiexec -ArgumentList "/i ${TEMP}\dokany.msi /qn /norestart"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-dokany.txt" | Out-Null
    } else {
        Write-Output "Dokany is already installed"
    }
}

function Install-GitBash {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-gitbash.txt")) {
        Write-Output "Installing Git Bash"
        Copy-Item "${SETUP_PATH}\git.exe" "${TEMP}\git.exe" -Force
        & "${TEMP}\git.exe" /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh" | Out-Null
        if (Test-Path "${LOCAL_PATH}\.bashrc") {
            Copy-Item "${LOCAL_PATH}\.bashrc" "${HOME}\.bashrc" -Force
        } else {
            Copy-Item "${LOCAL_PATH}\defaults\.bashrc" "${HOME}\.bashrc" -Force
        }
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-gitbash.txt" | Out-Null
    } else {
        Write-Output "Git Bash is already installed"
    }
}

function Install-GoLang {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-golang.txt")) {
        Write-Output "Installing GoLang"
        Copy-Item "${SETUP_PATH}\golang.msi" "${TEMP}\golang.msi" -Force
        Start-Process -Wait msiexec -ArgumentList "/i ${TEMP}\golang.msi /qn /norestart"
        Add-ToUserPath "${env:ProgramFiles}\Go\bin"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-golang.txt" | Out-Null
    } else {
        Write-Output "GoLang is already installed"
    }
}

function Install-Hashcat {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-hashcat.txt")) {
        Write-Output "Installing Hashcat"
        Copy-Item -Recurse "${SETUP_PATH}\hashcat" "${env:ProgramFiles}" -Force
        Add-ToUserPath "${env:ProgramFiles}\hashcat"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-hashcat.txt" | Out-Null
    } else {
        Write-Output "Hashcat is already installed"
    }
}

function Install-Jadx {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-jadx.txt")) {
        Write-Output "Installing Jadx"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\jadx.zip" -o"${env:ProgramFiles}\jadx"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-jadx.txt" | Out-Null
    } else {
        Write-Output "Jadx is already installed"
    }
}

function Install-Kape {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-kape.txt")) {
        if (Test-Path "${SETUP_PATH}\KAPE" ) {
           Write-Output "Installing Kape"
            Copy-Item -Recurse "${SETUP_PATH}\KAPE" "${env:ProgramFiles}" -Force
            Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\gkape.lnk" -DestinationPath "${env:ProgramFiles}\KAPE\gkape.exe" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${env:ProgramFiles}\KAPE\gkape.exe"
            Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\kape.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "${HOME}\Desktop"
            New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-kape.txt" | Out-Null
        } else {
            Write-Output "KAPE not found in ${SETUP_PATH}"
        }
    } else {
        Write-Output "Kape is already installed"
    }
}

function Install-LibreOffice {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-libreoffice.txt")) {
        Write-Output "Installing LibreOffice"
        Copy-Item "${SETUP_PATH}\LibreOffice.msi" "${TEMP}\LibreOffice.msi" -Force
        Start-Process -Wait msiexec -ArgumentList "/qb /i ${TEMP}\LibreOffice.msi /l* ${TEMP}\LibreOffice_install_log.txt REGISTER_ALL_MSO_TYPES=1 UI_LANGS=en_US ISCHECKFORPRODUCTUPDATES=0 REBOOTYESNO=No QUICKSTART=0 ADDLOCAL=ALL VC_REDIST=0 REMOVE=gm_o_Onlineupdate,gm_r_ex_Dictionary_Af,gm_r_ex_Dictionary_An,gm_r_ex_Dictionary_Ar,gm_r_ex_Dictionary_Be,gm_r_ex_Dictionary_Bg,gm_r_ex_Dictionary_Bn,gm_r_ex_Dictionary_Bo,gm_r_ex_Dictionary_Br,gm_r_ex_Dictionary_Pt_Br,gm_r_ex_Dictionary_Bs,gm_r_ex_Dictionary_Pt_Pt,gm_r_ex_Dictionary_Ca,gm_r_ex_Dictionary_Cs,gm_r_ex_Dictionary_Da,gm_r_ex_Dictionary_Nl,gm_r_ex_Dictionary_Et,gm_r_ex_Dictionary_Gd,gm_r_ex_Dictionary_Gl,gm_r_ex_Dictionary_Gu,gm_r_ex_Dictionary_He,gm_r_ex_Dictionary_Hi,gm_r_ex_Dictionary_Hu,gm_r_ex_Dictionary_Lt,gm_r_ex_Dictionary_Lv,gm_r_ex_Dictionary_Ne,gm_r_ex_Dictionary_No,gm_r_ex_Dictionary_Oc,gm_r_ex_Dictionary_Pl,gm_r_ex_Dictionary_Ro,gm_r_ex_Dictionary_Ru,gm_r_ex_Dictionary_Si,gm_r_ex_Dictionary_Sk,gm_r_ex_Dictionary_Sl,gm_r_ex_Dictionary_El,gm_r_ex_Dictionary_Es,gm_r_ex_Dictionary_Te,gm_r_ex_Dictionary_Th,gm_r_ex_Dictionary_Tr,gm_r_ex_Dictionary_Uk,gm_r_ex_Dictionary_Vi,gm_r_ex_Dictionary_Zu,gm_r_ex_Dictionary_Sq,gm_r_ex_Dictionary_Hr,gm_r_ex_Dictionary_De,gm_r_ex_Dictionary_Id,gm_r_ex_Dictionary_Is,gm_r_ex_Dictionary_Ko,gm_r_ex_Dictionary_Lo,gm_r_ex_Dictionary_Mn,gm_r_ex_Dictionary_Sr,gm_r_ex_Dictionary_Eo,gm_r_ex_Dictionary_It,gm_r_ex_Dictionary_Fr"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-libreoffice.txt" | Out-Null
    } else {
        Write-Output "LibreOffice is already installed"
    }
}

function Install-Loki {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-loki.txt")) {
        Write-Output "Installing Loki"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\loki.zip" -o"${env:ProgramFiles}\" | Out-Null
        Copy-Item ${GIT_PATH}\signature-base "${env:ProgramFiles}\loki" -Recurse -Force
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-loki.txt" | Out-Null
    } else {
        Write-Output "Loki is already installed"
    }
}

function Install-Malcat {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-malcat.txt")) {
        Write-Output "Installing Malcat"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\malcat.zip" -o"${env:ProgramFiles}\malcat" | Out-Null
        Add-ToUserPath "${env:ProgramFiles}\malcat\bin"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-malcat.txt" | Out-Null
    } else {
        Write-Output "Malcat is already installed"
    }
}
function Install-Neo4j {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-neo4j.txt")) {
        Write-Output "Installing Neo4j"
        Copy-Item "${SETUP_PATH}\microsoft-jdk-11.msi" "${TEMP}\microsoft-jdk-11.msi" -Force
        Start-Process -Wait msiexec -ArgumentList "/i ${TEMP}\microsoft-jdk-11.msi ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome INSTALLDIR=$NEO_JAVA /qn /norestart"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\neo4j.zip" -o"${env:ProgramFiles}"
        Move-Item ${env:ProgramFiles}\neo4j-community* ${env:ProgramFiles}\neo4j
        Add-ToUserPath "${env:ProgramFiles}\neo4j\bin"
        & "${env:ProgramFiles}\neo4j\bin\neo4j-admin" set-initial-password neo4j
        Copy-Item -Recurse "$TOOLS\neo4j" "${env:ProgramFiles}" -Force
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-neo4j.txt" | Out-Null
    } else {
        Write-Output "Neo4j is already installed"
    }
}

function Install-Node {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-node.txt")) {
        Write-Output "Installing Node"
        Copy-Item -r "${TOOLS}\node" "${HOME}\Desktop" -Force
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-node.txt" | Out-Null
    } else {
        Write-Output "Node is already installed"
    }
}

function Install-Obsidian {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-obsidian.txt")) {
        Write-Output "Installing Obsidian"
        Copy-Item "${SETUP_PATH}\obsidian.exe" "${TEMP}\obsidian.exe" -Force
        Start-Process -Wait "${TEMP}\obsidian.exe" -ArgumentList '/S /V"/qn REBOOT=ReallySuppress"'
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-obsidian.txt" | Out-Null
    } else {
        Write-Output "Obsidian is already installed"
    }
}

function Install-OhMyPosh {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-ohmyposh.txt")) {
        Write-Output "Installing OhMyPosh"
        Copy-Item "${SETUP_PATH}\oh-my-posh.exe" "${TEMP}\oh-my-posh.exe" -Force
        Start-Process -Wait "${TEMP}\oh-my-posh.exe" -ArgumentList '/CURRENTUSER /VERYSILENT /NORESTART'
        & "${HOME}\AppData\Local\Programs\oh-my-posh\bin\oh-my-posh.exe" font install --user "${SETUP_PATH}\${WSDFIR_FONT_NAME}.zip"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-ohmyposh.txt" | Out-Null
    } else {
        Write-Output "OhMyPosh is already installed"
    }
}

function Install-PDFStreamDumper {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-pdfstreamdumper.txt")) {
        Write-Output "Installing PDFStreamDumper"
        Copy-Item "${SETUP_PATH}\PDFStreamDumper.exe" "${TEMP}\PDFStreamDumper.exe" -Force
        & "${TEMP}\PDFStreamDumper.exe" /verysilent
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-pdfstreamdumper.txt" | Out-Null
    } else {
        Write-Output "PDFStreamDumper is already installed"
    }
}

function Install-Qemu {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-qemu.txt")) {
        Write-Output "Installing Qemu"
        Copy-Item "${SETUP_PATH}\qemu.exe" "${TEMP}\qemu.exe" -Force
        Start-Process -Wait "${TEMP}\qemu.exe" -ArgumentList '/S /V"/qn REBOOT=ReallySuppress"'
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-qemu.txt" | Out-Null
    } else {
        Write-Output "Qemu is already installed"
    }
}

function  Install-Ruby {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-ruby.txt")) {
        Write-Output "Installing Ruby"
        & "${SETUP_PATH}\ruby.exe" /verysilent /allusers /dir="${env:ProgramFiles}\ruby"
        Add-ToUserPath "${env:ProgramFiles}\ruby\bin"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-ruby.txt" | Out-Null
    } else {
        Write-Output "Ruby is already installed"
    }
}

function Install-Rust {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-rust.txt")) {
        Write-Output "Installing Rust"
        Copy-Item "${SETUP_PATH}\rust.msi" "${TEMP}\rust.msi"
        Start-Process -Wait msiexec -ArgumentList "/i ${TEMP}\rust.msi INSTALLDIR=${RUST_DIR} /qn /norestart"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-rust.txt" | Out-Null
    } else {
        Write-Output "Rust is already installed"
    }
}

function Install-VSCode {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-vscode.txt")) {
        Write-Output "Installing Visual Studio Code"
        Copy-Item "${SETUP_PATH}\vscode.exe" "${TEMP}\vscode.exe" -Force
        Start-Process -Wait "${TEMP}\vscode.exe" -ArgumentList '/verysilent /suppressmsgboxes /MERGETASKS="!runcode,!associatewithfiles,desktopicon,quicklaunchicon,addcontextmenufiles,addcontextmenufolders,addtopath"'
        if ($WSDFIR_VSCODE_POWERSHELL -eq "Yes") {
            & "${HOME}\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd" --install-extension "${SETUP_PATH}\vscode\vscode-powershell.vsix" 2>&1 | Out-Null
        }
        if ($WSDFIR_VSCODE_PYTHON -eq "Yes") {
            & "${HOME}\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd" --install-extension "${SETUP_PATH}\vscode\vscode-python.vsix" 2>&1 | Out-Null
        }
        if ($WSDFIR_VSCODE_SPELL -eq "Yes") {
            & "${HOME}\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd" --install-extension "${SETUP_PATH}\vscode\vscode-spell-checker.vsix" 2>&1 | Out-Null
        }
        if ($WSDFIR_VSCODE_MERMAID -eq "Yes") {
            & "${HOME}\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd" --install-extension "${SETUP_PATH}\vscode\vscode-mermaid.vsix" 2>&1 | Out-Null
        }
        if ($WSDFIR_VSCODE_RUFF -eq "Yes") {
            & "${HOME}\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd" --install-extension "${SETUP_PATH}\vscode\vscode-ruff.vsix" 2>&1 | Out-Null
        }
        if ($WSDFIR_VSCODE_SHELLCHECK -eq "Yes") {
            & "${HOME}\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd" --install-extension "${SETUP_PATH}\vscode\vscode-shellcheck.vsix" 2>&1 | Out-Null
        }
        if (Test-Path "${HOME}\.vscode\argv.json") {
            (Get-Content "${HOME}\.vscode\argv.json").Replace('"enable-crash-reporter": true,"', '"enable-crash-reporter": false,"') | Set-Content "${HOME}\.vscode\argv.json" -Force
        }
        if (!(Test-Path "${HOME}\AppData\Roaming\Code\User")) {
            New-Item -Path "${HOME}\AppData\Roaming\Code\User" -ItemType Directory -Force | Out-Null
        }
        if (Test-Path "${LOCAL_PATH}\vscode\settings.json") {
            Copy-Item "${LOCAL_PATH}\vscode\settings.json" "${HOME}\AppData\Roaming\Code\User\settings.json" -Force
        } else {
            (Get-Content "${LOCAL_PATH}\defaults\vscode\settings.json").Replace("FONT_NAME", "${WSDFIR_FONT_FULL_NAME}") | Set-Content "${HOME}\AppData\Roaming\Code\User\settings.json" -Force
        }
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-vscode.txt" | Out-Null
    } else {
        Write-Output "Visual Studio Code is already installed"
    }
}

function Install-W10Loopback {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-loopback.txt")) {
        Write-Output "Installing Windows 10 Loopback adapter"
        $WIN10=(Get-ComputerInfo | Select-Object -expand OsName) -match 10
        if ($WIN10) {
            & "${HOME}\Documents\tools\utils\devcon.exe" install "${env:windir}\inf\netloop.inf" *msloop
            Write-DateLog "Loopback adapter installed"
        } else {
            Write-DateLog "Loopback adapter not installed since not running Windows 10"
        }
    } else {
        Write-Output "Windows 10 Loopback adapter is already installed"
    }
}

function Install-Wireshark {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-wireshark.txt")) {
        Write-Output "Installing Wireshark"
        Copy-Item "${SETUP_PATH}\wireshark.exe" "${TEMP}\wireshark.exe" -Force
        Start-Process -Wait "${TEMP}\wireshark.exe" -ArgumentList "/S /desktopicon=yes /quicklaunchicon=yes"
        New-Item -Path "${env:USERPROFILE}\AppData\Roaming\Wireshark" -Force -Type Directory | Out-Null
        if (Test-Path "${ENRICHMENT}\maxmind_current") {
            Set-Content '"C:/enrichment/maxmind_current"' -Encoding Ascii -Path "${env:USERPROFILE}\AppData\Roaming\Wireshark\maxmind_db_paths"
        }
        Add-ToUserPath "${env:ProgramFiles}\Wireshark"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-wireshark.txt" | Out-Null
    } else {
        Write-Output "Wireshark is already installed"
    }
}

function Install-X64dbg {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-x64dbg.txt")) {
        Write-Output "Installing x64dbg"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\x64dbg.zip" -o"${env:ProgramFiles}\x64dbg" | Out-Null
        Add-ToUserPath "${env:ProgramFiles}\x64dbg\release\x32"
        Add-ToUserPath "${env:ProgramFiles}\x64dbg\release\x64"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-x64dbg.txt" | Out-Null
    } else {
        Write-Output "x64dbg is already installed"
    }
}
function Install-Zui {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-zui.txt")) {
        Write-Output "Installing Zui"
        Copy-Item "${SETUP_PATH}\zui.exe" "${TEMP}\zui.exe" -Force
        & "${TEMP}\zui.exe" /S /AllUsers
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-zui.txt" | Out-Null
    } else {
        Write-Output "Zui is already installed"
    }
}
