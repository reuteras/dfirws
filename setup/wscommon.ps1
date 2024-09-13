# Set variables
$ENRICHMENT = "C:\enrichment"
$GIT_PATH = "C:\git"
$LOCAL_PATH = "C:\local"
$NEO_JAVA = "C:\java"
$PDFSTREAMDUMPER_PATH = "C:\Sandsprite\PDFStreamDumper"
$MSYS2_DIR = "C:\msys64"
$RUST_DIR = "C:\Rust"
$SETUP_PATH = "C:\downloads"
$WSDFIR_TEMP = "C:\tmp"
$TOOLS = "C:\Tools"
$VENV = "C:\venv"
$POWERSHELL_EXE = "${env:ProgramFiles}\PowerShell\7\pwsh.exe"

$null="${GIT_PATH}"
$null="${LOCAL_PATH}"
$null="${PDFSTREAMDUMPER_PATH}"
$null="${MSYS2_DIR}"
$null="${RUST_DIR}"
$null="${WSDFIR_TEMP}"

# Declare helper functions

# Adds a directory to the user's PATH environment variable.
function Add-ToUserPath {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $dir
    )

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

# Update the wallpaper for the current users desktop
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

function Write-SynchronizedLog {
    param (
        [Parameter(Mandatory=$True)] [string]$Message,
        [Parameter(Mandatory=$false)] [string]$LogFile = "C:\log\verify.txt"
    )

    $logMutex = New-Object -TypeName 'System.Threading.Mutex' -ArgumentList $false, 'Global\verifyLogMutex'

    try {
        $result = $logMutex.WaitOne()
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $fullMessage = "$timestamp - $Message"
        Add-Content -Path $LogFile -Value $fullMessage 2>&1 | Out-Null
    }
    finally {
        $result = $logMutex.ReleaseMutex()
    }

    if (!$result) {
        Write-Debug "Error"
    }
}

# Function to verify a command exists and is of a certain type
function Test-Command {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $name,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $type
    )

    try {
        $command = Get-Command -ErrorAction Stop $name
    }
    catch {
        Write-SynchronizedLog "ERROR: $name does not exist"
        return
    }

    if ( file $command.Path | Where-Object {$_ -match $type}) {
        Write-SynchronizedLog "SUCCESS: $name exists and type matches $type"
    } else {
        $actual_type = file $command.Path
        Write-SynchronizedLog "ERROR: $name exists but is not of type $type. Type is $actual_type"
    }
}

# Functions to help install programs
function Install-Apimonitor {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-apimonitor.txt")) {
        Write-Output "Installing API Monitor"
        Copy-Item "${SETUP_PATH}\apimonitor64.exe" "${WSDFIR_TEMP}" -Force
        & ${WSDFIR_TEMP}\apimonitor64.exe /s /v/qn
        Add-ToUserPath "${env:ProgramFiles(x86)}\rohitab.com\API Monitor"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-apimonitor.txt" | Out-Null
    } else {
        Write-Output "API Monitor is already installed"
    }
}

function Install-Autopsy {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-autopsy.txt")) {
        Write-Output "Installing Autopsy"
        Copy-Item "${SETUP_PATH}\autopsy.msi" "${WSDFIR_TEMP}\autopsy.msi" -Force
        Start-Process -Wait msiexec.exe -ArgumentList "/i ${WSDFIR_TEMP}\autopsy.msi /qn /norestart"
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
        Copy-Item "${SETUP_PATH}\binaryninja.exe" "${WSDFIR_TEMP}\binaryninja.exe" -Force
        Start-Process -Wait "${WSDFIR_TEMP}\binaryninja.exe" -ArgumentList '/S /V"/qn REBOOT=ReallySuppress"'
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-binaryninja.txt" | Out-Null
    } else {
        Write-Output "Binary Ninja is already installed"
    }
}

function Install-BurpSuite {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-burpsuite.txt")) {
        Write-Output "Installing Burp Suite"
        Copy-Item "${SETUP_PATH}\burp.exe" "${WSDFIR_TEMP}\burp.exe" -Force
        Start-Process -Wait "${WSDFIR_TEMP}\burp.exe" -ArgumentList '-q'
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-burpsuite.txt" | Out-Null
        Add-ToUserPath "${env:ProgramFiles}\BurpSuiteCommunity"
        Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\burp.lnk" -DestinationPath "${env:ProgramFiles}\BurpSuiteCommunity\BurpSuiteCommunity.exe" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${env:ProgramFiles}\BurpSuiteCommunity\BurpSuiteCommunity.exe"
    } else {
        Write-Output "Burp Suite is already installed"
    }
}

function Install-Chrome {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-chrome.txt")) {
        Write-Output "Installing Chrome"
        Copy-Item "${SETUP_PATH}\chrome.msi" "${WSDFIR_TEMP}\chrome.msi" -Force
        Start-Process -Wait msiexec -ArgumentList "/i ${WSDFIR_TEMP}\chrome.msi /qn /norestart"
        & "${WSDFIR_TEMP}\chrome.msi" /quiet /norestart
        Add-ToUserPath "${env:ProgramFiles}\Google\Chrome\Application"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-chrome.txt" | Out-Null
    } else {
        Write-Output "Chrome is already installed"
    }
}

function Install-ClamAV {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-clamav.txt")) {
        Write-Output "Installing ClamAV"
        Copy-Item "${SETUP_PATH}\clamav.msi" "${WSDFIR_TEMP}\clamav.msi" -Force
        Start-Process -Wait msiexec -ArgumentList "/i ${WSDFIR_TEMP}\clamav.msi /qn /norestart"
        Add-ToUserPath "${env:ProgramFiles}\ClamAV"
        (Get-Content 'C:\Program Files\ClamAV\conf_examples\clamd.conf.sample').Replace("Example", "#Example") | Out-File -FilePath 'C:\Program Files\ClamAV\clamd.conf' -Encoding "ascii"
        (Get-Content 'C:\Program Files\ClamAV\conf_examples\freshclam.conf.sample').Replace("Example", "#Example") | Out-File -FilePath 'C:\Program Files\ClamAV\freshclam.conf' -Encoding "ascii"
        Write-Output 'DatabaseDirectory "C:\Tools\ClamAV\db"' | Out-File -Append 'C:\Program Files\ClamAV\clamd.conf'
        Write-Output 'DatabaseDirectory "C:\Tools\ClamAV\db"' | Out-File -Append 'C:\Program Files\ClamAV\freshclam.conf'
        reg import "${HOME}\Documents\tools\reg\clamav.reg" | Out-Null
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-clamav.txt" | Out-Null
    } else {
        Write-Output "ClamAV is already installed"
    }
}

function Install-CMDer {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-cmder.txt")) {
        Write-Output "Installing Cmder"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\cmder.7z" -o"${env:ProgramFiles}\cmder" | Out-Null
        Add-ToUserPath "${env:ProgramFiles}\cmder"
        Add-ToUserPath "${env:ProgramFiles}\cmder\bin"
        Write-Output "$VENV\default\scripts\activate.bat" | Out-File -Append -Encoding "ascii" ${env:ProgramFiles}\cmder\config\user_profile.cmd
        & "${env:ProgramFiles}\cmder\cmder.exe" /REGISTER ALL
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-cmder.txt" | Out-Null
    } else {
        Write-Output "Cmder is already installed"
    }
}

function  Install-DCode {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-dcode.txt")) {
        Write-Output "Installing DCode"
        Copy-Item "${SETUP_PATH}\dcode\dcode.exe" "${WSDFIR_TEMP}\dcode.exe" -Force
        Start-Process -Wait "${WSDFIR_TEMP}\dcode.exe" -ArgumentList '/CURRENTUSER /VERYSILENT /NORESTART'
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-dcode.txt" | Out-Null
    } else {
        Write-Output "DCode is already installed"
    }
}

function Install-Docker {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-docker.txt")) {
        Write-Output "Installing Docker"
        Copy-Item "${SETUP_PATH}\docker.exe" "${WSDFIR_TEMP}\docker.exe" -Force
        Start-Process -Wait "${WSDFIR_TEMP}\docker.exe" -ArgumentList 'install --quiet --accept-license'
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-docker.txt" | Out-Null
    } else {
        Write-Output "Docker is already installed"
    }
}
function Install-Dokany {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-dokany.txt")) {
        Write-Output "Installing Dokany"
        Copy-Item "${SETUP_PATH}\dokany.msi" "${WSDFIR_TEMP}\dokany.msi" -Force
        Start-Process -Wait msiexec -ArgumentList "/i ${WSDFIR_TEMP}\dokany.msi /qn /norestart"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-dokany.txt" | Out-Null
    } else {
        Write-Output "Dokany is already installed"
    }
}

function Install-Fibratus {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-fibratus.txt")) {
        Write-Output "Installing Fibratus"
        Copy-Item "${SETUP_PATH}\fibratus.msi" "${WSDFIR_TEMP}\fibratus.msi" -Force
        Start-Process -Wait msiexec -ArgumentList "/i ${WSDFIR_TEMP}\fibratus.msi /qn /norestart"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-fibratus.txt" | Out-Null
        Add-ToUserPath "${env:ProgramFiles}\Fibratus\bin"
        Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\fibratus documentation (needs internet access).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command ${HOME}\Documents\tools\utils\start_fibratus.bat"
    } else {
        Write-Output "Fibratus is already installed"
    }
}

function Install-Firefox {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-firefox.txt")) {
        Write-Output "Installing Firefox"
        Start-Process -Wait msiexec -ArgumentList "/i ${SETUP_PATH}\firefox.msi /qn /norestart"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-firefox.txt" | Out-Null
    } else {
        Write-Output "Firefox is already installed"
    }
}

function Install-FoxitReader {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-foxitreader.txt")) {
        Write-Output "Installing Foxit Reader"
        Copy-Item "${SETUP_PATH}\foxitreader.exe" "${WSDFIR_TEMP}\foxitreader.exe" -Force
        Start-Process -Wait "${WSDFIR_TEMP}\foxitreader.exe" -ArgumentList '/SP- /VERYSILENT /SUPPRESSMSGBOXES /NORESTART'
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-foxitreader.txt" | Out-Null
    } else {
        Write-Output "Foxit Reader is already installed"
    }

}
function Install-GitBash {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-gitbash.txt")) {
        Write-Output "Installing Git Bash"
        Copy-Item "${SETUP_PATH}\git.exe" "${WSDFIR_TEMP}\git.exe" -Force
        & "${WSDFIR_TEMP}\git.exe" /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh" | Out-Null
        if (Test-Path "${LOCAL_PATH}\.bashrc") {
            Copy-Item "${LOCAL_PATH}\.bashrc" "${HOME}\.bashrc" -Force
        } else {
            Copy-Item "${LOCAL_PATH}\defaults\.bashrc" "${HOME}\.bashrc" -Force
        }
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-gitbash.txt" | Out-Null
        Set-Alias gdiff "$env:ProgramFiles\Git\usr\bin\diff.exe"
	    Set-Alias gfind "$env:ProgramFiles\Git\usr\bin\find.exe"
    } else {
        Write-Output "Git Bash is already installed"
    }
}

function Install-GoLang {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-golang.txt")) {
        Write-Output "Installing GoLang"
        Copy-Item "${SETUP_PATH}\golang.msi" "${WSDFIR_TEMP}\golang.msi" -Force
        Start-Process -Wait msiexec -ArgumentList "/i ${WSDFIR_TEMP}\golang.msi /qn /norestart"
        Add-ToUserPath "${env:ProgramFiles}\Go\bin"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-golang.txt" | Out-Null
    } else {
        Write-Output "GoLang is already installed"
    }
}

function Install-GoogleEarth {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-googleearth.txt")) {
        Write-Output "Installing Google Earth"
        Copy-Item "${SETUP_PATH}\googleearth.exe" "${WSDFIR_TEMP}\googleearth.exe" -Force
        Start-Process -Wait "${WSDFIR_TEMP}\googleearth.exe" -ArgumentList 'OMAHA=1'
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-googleearth.txt" | Out-Null
    } else {
        Write-Output "Google Earth is already installed"
    }
}

function Install-Gpg4win {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-gpg4win.txt")) {
        Write-Output "Installing Gpg4win"
        Copy-Item "${SETUP_PATH}\gpg4win.exe" "${WSDFIR_TEMP}\gpg4win.exe" -Force
        Start-Process -Wait "${WSDFIR_TEMP}\gpg4win.exe" -ArgumentList '/S /V"/qn REBOOT=ReallySuppress"'
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-gpg4win.txt" | Out-Null
    } else {
        Write-Output "Gpg4win is already installed"
    }

}

function Install-Hashcat {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-hashcat.txt")) {
        Write-Output "Installing Hashcat"
        Copy-Item -Recurse "${TOOLS}\hashcat" "${env:ProgramFiles}" -Force
        Add-ToUserPath "${env:ProgramFiles}\hashcat"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-hashcat.txt" | Out-Null
    } else {
        Write-Output "Hashcat is already installed"
    }
}

function Install-Jadx {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-jadx.txt")) {
        Write-Output "Installing Jadx"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\jadx.zip" -o"${env:ProgramFiles}\jadx" | Out-Null
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
        Copy-Item "${SETUP_PATH}\LibreOffice.msi" "${WSDFIR_TEMP}\LibreOffice.msi" -Force
        Start-Process -Wait msiexec -ArgumentList "/qb /i ${WSDFIR_TEMP}\LibreOffice.msi /l* ${WSDFIR_TEMP}\LibreOffice_install_log.txt REGISTER_ALL_MSO_TYPES=1 UI_LANGS=en_US ISCHECKFORPRODUCTUPDATES=0 REBOOTYESNO=No QUICKSTART=0 ADDLOCAL=ALL VC_REDIST=0 REMOVE=gm_o_Onlineupdate,gm_r_ex_Dictionary_Af,gm_r_ex_Dictionary_An,gm_r_ex_Dictionary_Ar,gm_r_ex_Dictionary_Be,gm_r_ex_Dictionary_Bg,gm_r_ex_Dictionary_Bn,gm_r_ex_Dictionary_Bo,gm_r_ex_Dictionary_Br,gm_r_ex_Dictionary_Pt_Br,gm_r_ex_Dictionary_Bs,gm_r_ex_Dictionary_Pt_Pt,gm_r_ex_Dictionary_Ca,gm_r_ex_Dictionary_Cs,gm_r_ex_Dictionary_Da,gm_r_ex_Dictionary_Nl,gm_r_ex_Dictionary_Et,gm_r_ex_Dictionary_Gd,gm_r_ex_Dictionary_Gl,gm_r_ex_Dictionary_Gu,gm_r_ex_Dictionary_He,gm_r_ex_Dictionary_Hi,gm_r_ex_Dictionary_Hu,gm_r_ex_Dictionary_Lt,gm_r_ex_Dictionary_Lv,gm_r_ex_Dictionary_Ne,gm_r_ex_Dictionary_No,gm_r_ex_Dictionary_Oc,gm_r_ex_Dictionary_Pl,gm_r_ex_Dictionary_Ro,gm_r_ex_Dictionary_Ru,gm_r_ex_Dictionary_Si,gm_r_ex_Dictionary_Sk,gm_r_ex_Dictionary_Sl,gm_r_ex_Dictionary_El,gm_r_ex_Dictionary_Es,gm_r_ex_Dictionary_Te,gm_r_ex_Dictionary_Th,gm_r_ex_Dictionary_Tr,gm_r_ex_Dictionary_Uk,gm_r_ex_Dictionary_Vi,gm_r_ex_Dictionary_Zu,gm_r_ex_Dictionary_Sq,gm_r_ex_Dictionary_Hr,gm_r_ex_Dictionary_De,gm_r_ex_Dictionary_Id,gm_r_ex_Dictionary_Is,gm_r_ex_Dictionary_Ko,gm_r_ex_Dictionary_Lo,gm_r_ex_Dictionary_Mn,gm_r_ex_Dictionary_Sr,gm_r_ex_Dictionary_Eo,gm_r_ex_Dictionary_It,gm_r_ex_Dictionary_Fr"
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

function Install-Maltego {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-maltego.txt")) {
        Write-Output "Installing Maltego"
        Start-Process -Wait "${SETUP_PATH}\maltego.exe" -ArgumentList '/S /V"/qn REBOOT=ReallySuppress"'
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-maltego.txt" | Out-Null
    } else {
        Write-Output "Maltego is already installed"
    }
}
function Install-Neo4j {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-neo4j.txt")) {
        Write-Output "Installing Neo4j"
        Copy-Item "${SETUP_PATH}\microsoft-jdk-11.msi" "${WSDFIR_TEMP}\microsoft-jdk-11.msi" -Force
        Start-Process -Wait msiexec -ArgumentList "/i ${WSDFIR_TEMP}\microsoft-jdk-11.msi ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome INSTALLDIR=$NEO_JAVA /qn /norestart"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\neo4j.zip" -o"${env:ProgramFiles}" | Out-Null
        Move-Item ${env:ProgramFiles}\neo4j-community* ${env:ProgramFiles}\neo4j
        Add-ToUserPath "${env:ProgramFiles}\neo4j\bin"
        pwsh.exe -Command { $env:PATH="C:\java\bin;$env:PATH"; $env:JAVA_HOME="C:\java" ; & "${env:ProgramFiles}\neo4j\bin\neo4j-admin" set-initial-password neo4j | Out-Null}
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
        Copy-Item "${SETUP_PATH}\obsidian.exe" "${WSDFIR_TEMP}\obsidian.exe" -Force
        Start-Process -Wait "${WSDFIR_TEMP}\obsidian.exe" -ArgumentList '/S /V"/qn REBOOT=ReallySuppress"'
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-obsidian.txt" | Out-Null
    } else {
        Write-Output "Obsidian is already installed"
    }
}

function Install-OSFMount {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-osfmount.txt")) {
        Write-Output "Installing OSFMount"
        Copy-Item "${SETUP_PATH}\osfmount.exe" "${WSDFIR_TEMP}\osfmount.exe" -Force
        Start-Process -Wait "${WSDFIR_TEMP}\osfmount.exe" -ArgumentList '/S /V"/qn /suppressmsgboxes REBOOT=ReallySuppress"'
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-osfmount.txt" | Out-Null
    } else {
        Write-Output "OSFMount is already installed"
    }
}
function Install-OhMyPosh {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-ohmyposh.txt")) {
        Write-Output "Installing OhMyPosh"
        Copy-Item "${SETUP_PATH}\oh-my-posh.exe" "${WSDFIR_TEMP}\oh-my-posh.exe" -Force
        Start-Process -Wait "${WSDFIR_TEMP}\oh-my-posh.exe" -ArgumentList '/CURRENTUSER /VERYSILENT /NORESTART'
        & "${HOME}\AppData\Local\Programs\oh-my-posh\bin\oh-my-posh.exe" font install "${SETUP_PATH}\${WSDFIR_FONT_NAME}.zip" | Out-Null
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-ohmyposh.txt" | Out-Null
    } else {
        Write-Output "OhMyPosh is already installed"
    }
}

function Install-PDFStreamDumper {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-pdfstreamdumper.txt")) {
        Write-Output "Installing PDFStreamDumper"
        Copy-Item "${SETUP_PATH}\PDFStreamDumper.exe" "${WSDFIR_TEMP}\PDFStreamDumper.exe" -Force
        & "${WSDFIR_TEMP}\PDFStreamDumper.exe" /verysilent
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-pdfstreamdumper.txt" | Out-Null
    } else {
        Write-Output "PDFStreamDumper is already installed"
    }
}

function Install-PuTTY {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-putty.txt")) {
        Write-Output "Installing PuTTY"
        Copy-Item "${SETUP_PATH}\putty.msi" "${WSDFIR_TEMP}\putty.msi" -Force
        Start-Process -Wait msiexec -ArgumentList "/i ${WSDFIR_TEMP}\putty.msi /qn /norestart"
        Add-ToUserPath "${env:ProgramFiles}\PuTTY"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-putty.txt" | Out-Null
    } else {
        Write-Output "PuTTY is already installed"
    }
}
function Install-Qemu {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-qemu.txt")) {
        Write-Output "Installing Qemu"
        Copy-Item "${SETUP_PATH}\qemu.exe" "${WSDFIR_TEMP}\qemu.exe" -Force
        Start-Process -Wait "${WSDFIR_TEMP}\qemu.exe" -ArgumentList '/S /V"/qn REBOOT=ReallySuppress"'
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
        Copy-Item "${SETUP_PATH}\rust.msi" "${WSDFIR_TEMP}\rust.msi"
        Start-Process -Wait msiexec -ArgumentList "/i ${WSDFIR_TEMP}\rust.msi INSTALLDIR=${RUST_DIR} /qn /norestart"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-rust.txt" | Out-Null
    } else {
        Write-Output "Rust is already installed"
    }
}

function Install-Tor {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-tor.txt")) {
        Write-Output "Installing Tor"
        Copy-Item "${SETUP_PATH}\torbrowser.exe" "${WSDFIR_TEMP}\torbrowser.exe" -Force
        Start-Process -Wait "${WSDFIR_TEMP}\torbrowser.exe" -ArgumentList '/S /V"/qn REBOOT=ReallySuppress"'
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-tor.txt" | Out-Null
    } else {
        Write-Output "Tor is already installed"
    }
}

function Install-Veracrypt {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-veracrypt.txt")) {
        Write-Output "Installing Veracrypt"
        Copy-Item "${SETUP_PATH}\veracrypt.msi" "${WSDFIR_TEMP}\veracrypt.msi" -Force
        Start-Process -Wait msiexec -ArgumentList "/i ${WSDFIR_TEMP}\veracrypt.msi /qn /norestart ACCEPTLICENSE=YES"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-veracrypt.txt" | Out-Null
        Add-ToUserPath "${env:ProgramFiles}\VeraCrypt"
        Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\veracrypt.lnk" -DestinationPath "${env:ProgramFiles}\VeraCrypt\VeraCrypt.exe" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${env:ProgramFiles}\VeraCrypt\VeraCrypt.exe"
    } else {
        Write-Output "Veracrypt is already installed"
    }
}

function Install-VLC {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-vlc.txt")) {
        Write-Output "Installing VLC"
        Copy-Item "${SETUP_PATH}\vlc.msi" "${WSDFIR_TEMP}\vlc.msi" -Force
        Start-Process -Wait msiexec -ArgumentList "/i ${WSDFIR_TEMP}\vlc.msi /qn /norestart"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-vlc.txt" | Out-Null
        Add-ToUserPath "${env:ProgramFiles}\VideoLAN\VLC"
        Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Media\vlc.lnk" -DestinationPath "${env:ProgramFiles}\VideoLAN\VLC\vlc.exe" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${env:ProgramFiles}\VideoLAN\VLC\vlc.exe"
    } else {
        Write-Output "VLC is already installed"
    }
}

function Install-VSCode {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-vscode.txt")) {
        Write-Output "Installing Visual Studio Code"
        Copy-Item "${SETUP_PATH}\vscode.exe" "${WSDFIR_TEMP}\vscode.exe" -Force
        Start-Process -Wait "${WSDFIR_TEMP}\vscode.exe" -ArgumentList '/verysilent /suppressmsgboxes /MERGETASKS="!runcode,!associatewithfiles,desktopicon,quicklaunchicon,addcontextmenufiles,addcontextmenufolders,addtopath"'
        if ($WSDFIR_VSCODE_C -eq "Yes") {
            & "${HOME}\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd" --install-extension "${SETUP_PATH}\vscode\vscode-cpp.vsix" 2>&1 | Out-Null
        }
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

function Install-WinMerge {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-winmerge.txt")) {
        Write-Output "Installing WinMerge"
        Copy-Item "${SETUP_PATH}\winmerge.exe" "${WSDFIR_TEMP}\winmerge.exe" -Force
        Start-Process -Wait "${WSDFIR_TEMP}\winmerge.exe" -ArgumentList '/verysilent /norestart /DIR="C:\Program Files\WinMerge" /Tasks=desktopicon,quicklaunchicon'
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-winmerge.txt" | Out-Null
        Add-ToUserPath "${env:ProgramFiles}\WinMerge"
        Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\winmerge.lnk" -DestinationPath "${env:ProgramFiles}\WinMerge\WinMergeU.exe" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${env:ProgramFiles}\WinMerge\WinMergeU.exe"
    } else {
        Write-Output "WinMerge is already installed"
    }
}

function Install-Wireshark {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-wireshark.txt")) {
        Write-Output "Installing Wireshark"
        Copy-Item "${SETUP_PATH}\wireshark.exe" "${WSDFIR_TEMP}\wireshark.exe" -Force
        Start-Process -Wait "${WSDFIR_TEMP}\wireshark.exe" -ArgumentList "/S /desktopicon=yes /quicklaunchicon=yes"
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

function Install-ZAProxy {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-zaproxy.txt")) {
        Write-Output "Installing ZAProxy"
        Copy-Item "${SETUP_PATH}\zaproxy.exe" "${WSDFIR_TEMP}\zaproxy.exe" -Force
        Start-Process -Wait "${WSDFIR_TEMP}\zaproxy.exe" -ArgumentList '-q'
        Add-ToUserPath "${env:ProgramFiles}\ZAP\Zed Attack Proxy"
        Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\zaproxy.lnk" -DestinationPath "${env:ProgramFiles}\ZAP\Zed Attack Proxy\zap.exe" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${env:ProgramFiles}\ZAP\Zed Attack Proxy\zap.ico"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-zaproxy.txt" | Out-Null
    } else {
        Write-Output "ZAProxy is already installed"
    }
}
function Install-Zui {
    if (!(Test-Path "${env:ProgramFiles}\dfirws\installed-zui.txt")) {
        Write-Output "Installing Zui"
        Copy-Item "${SETUP_PATH}\zui.exe" "${WSDFIR_TEMP}\zui.exe" -Force
        & "${WSDFIR_TEMP}\zui.exe" /S /AllUsers
        Add-ToUserPath "${env:ProgramFiles}\Zui"
        New-Item -ItemType File -Path "${env:ProgramFiles}\dfirws" -Name "installed-zui.txt" | Out-Null
    } else {
        Write-Output "Zui is already installed"
    }
}
