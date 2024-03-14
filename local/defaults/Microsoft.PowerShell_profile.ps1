. "${HOME}\Documents\tools\wscommon.ps1"

# Source config files
. "${WSDFIR_TEMP}\config.ps1"

# Make Windows be more like Linux
Set-Alias gdiff "$env:ProgramFiles\Git\usr\bin\diff.exe"
Set-Alias gfind "$env:ProgramFiles\Git\usr\bin\find.exe"

# Python
# Comment this line to see warnings from Python
$env:PYTHONWARNINGS = "ignore"
# Fix encoding issues - https://discuss.python.org/t/unicodeencodeerror-charmap-codec-cant-encode-characters-in-position-0-14-character-maps-to-undefined/12814/3
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUTF8 = "1"

# Set environment variables
$env:PATH_TO_FX = "C:\Tools\javafx-sdk\lib"
$env:POSH_THEMES_PATH = "${HOME}\AppData\Local\Programs\oh-my-posh\themes"
$env:PSModulePath = "$env:PSModulePath;C:\Downloads\powershell-modules"
# Find last version of Ghidra
$env:GHIDRA_INSTALL_DIR = (Get-ChildItem C:\Tools\ghidra\ | findstr.exe PUBLIC | Select-Object -Last 1)

# Autosuggestions with PSReadLine
if (-not(Get-Module -ListAvailable PSReadLine)) {
    Import-Module PSReadLine
}

# History
if (Get-PSReadLineOption | Get-Member | findstr PredictionSource) {
	Set-PSReadLineOption -PredictionSource History | Out-Null
}

# https://techcommunity.microsoft.com/t5/itops-talk-blog/autocomplete-in-powershell/ba-p/2604524
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# Use Vi keybindings
Set-PSReadLineOption -EditMode Vi

# Other options:
# Set-PSReadLineOption -PredictionViewStyle ListView

# Add icons to dir and ls.
if (-not(Get-Module -ListAvailable Terminal-Icons)) {
    Import-Module -Name Terminal-Icons
}

# Make sure that there is a tmp directory in $HOME
if (-not(Test-Path "${HOME}\tmp")) {
	New-Item -ItemType Directory "${HOME}\tmp" | Out-Null
}

#
# Init oh-my-posh and set theme
##

if ( ${WSDFIR_OHMYPOSH} -eq "Yes" ) {
	# You can place your own theme in the local directory
	if ("${WSDFIR_TABBY}" -eq "Yes") {
		& "${HOME}\AppData\Local\Programs\oh-my-posh\bin\oh-my-posh.exe" init pwsh --config "${LOCAL_PATH}\${WSDFIR_OHMYPOSH_CONFIG_POWERLINE}" > "${HOME}\tmp\oh-my-posh-init.ps1"
	} else {
		& "${HOME}\AppData\Local\Programs\oh-my-posh\bin\oh-my-posh.exe" init pwsh --config "${LOCAL_PATH}\${WSDFIR_OHMYPOSH_CONFIG_PLAIN}" > "${HOME}\tmp\oh-my-posh-init.ps1"
	}
	if (!(Test-Path "${HOME}\tmp\oh-my-posh-completion.ps1")) {
		& "${HOME}\AppData\Local\Programs\oh-my-posh\bin\oh-my-posh.exe" completion powershell > "${HOME}\tmp\oh-my-posh-completion.ps1"
	}
	& "${HOME}\tmp\oh-my-posh-init.ps1"
	& "${HOME}\tmp\oh-my-posh-completion.ps1"
	${env:VIRTUAL_ENV_DISABLE_PROMPT}=$true

	# Use posh-git: https://github.com/dahlbyk/posh-git
	if (-not(Get-Module -ListAvailable posh-git)) {
		Import-Module posh-git
	}
}

# Always start with Python venv default
& "${env:USERPROFILE}\Documents\tools\utils\venv.ps1"

# Add autocomplete for commands
if (Test-Path "C:\Tools\cargo\autocomplete") {
    Get-ChildItem "C:\Tools\cargo\autocomplete" *.ps1 | ForEach-Object {
        . $_.FullName
    }
}

#
# Functions to help in dfirws
#

function Copy-Fakenet {
	Param (
        [string]$DestinationPath = "."
    )

	if (!(Test-Path "$DestinationPath")) {
		New-Item -ItemType Directory "$DestinationPath"
	}

	Copy-Item -r C:\Tools\fakenet\ "$DestinationPath" -Force
}

function Copy-Node {
	Param (
        [string]$DestinationPath = "."
    )

	if (!(Test-Path "$DestinationPath")) {
		New-Item -ItemType Directory "$DestinationPath"
	}

	Copy-Item -r C:\Tools\node "$DestinationPath" -Force
}

function Restore-Quarantine {
	if (!(Test-Path "C:\ProgramData\Microsoft\Windows Defender" )) {
		New-Item -ItemType Directory "C:\ProgramData\Microsoft\Windows Defender" > $null
	}


	if (Test-Path "C:\ProgramData\Microsoft\Windows Defender\Quarantine" ) {
		Write-Output "Directory C:\ProgramData\Microsoft\Windows Defender\Quarantine exists. Remove and try again."
		return
	}

	if (Test-Path "C:\Users\${env:USERNAME}\Desktop\readonly\Quarantine.zip") {
		Remove-Item -r -Force "C:\tmp\Quarantine" > $null 2>&1
		& "$env:ProgramFiles\7-Zip\7z.exe" x "C:\Users\${env:USERNAME}\Desktop\readonly\Quarantine.zip" -oc:\tmp > $null
		if (!(Test-Path "C:\tmp\Quarantine")) {
			Write-Output "Zip file didn't contain directory Quarantine."
			return
		}
		Copy-Item -r "C:\tmp\Quarantine" "C:\ProgramData\Microsoft\Windows Defender" -Force
		return
	} elseif (Test-Path "C:\Users\${env:USERNAME}\Desktop\readonly\Quarantine" ) {
		Copy-Item -r "C:\Users\${env:USERNAME}\Desktop\readonly\Quarantine" "C:\ProgramData\Microsoft\Windows Defender" -Force
		return
	}

	Write-Output "No directory ~\Desktop\readonly\Quarantine or file ~\Desktop\readonly\Quarantine.zip!"
}

# Dynamically added functions below
