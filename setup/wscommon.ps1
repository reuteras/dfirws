# Set variables
$SETUP_PATH="C:\downloads"
$TEMP="C:\tmp"
$TOOLS="C:\Tools"

$null=$SETUP_PATH
$null=$TEMP
$null=$TOOLS

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