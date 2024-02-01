# Always start with Python venv
if ( Test-Path "C:\venv\default\Scripts\Activate.ps1" ) {
    C:\venv\default\Scripts\Activate.ps1
}

. "${HOME}\Documents\tools\wscommon.ps1"

# Source config files
. "${TEMP}\default-config.ps1"
. "${TEMP}\config.ps1"

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
$env:GHIDRA_INSTALL_DIR = (Get-ChildItem C:\Tools\ghidra\ | Select-String PUBLIC -Raw | Select-Object -Last 1)

# Autosuggestions with PSReadLine
if (-not(Get-Module -ListAvailable PSReadLine)) {
    Import-Module PSReadLine
}

# History
Set-PSReadLineOption -PredictionSource History

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
#
# The default themes are available in the directory $env:POSH_THEMES_PATH
#

if ( ${WSDFIR_OHMYPOSH} -eq "Yes" ) {
	# You can place your own theme in the local directory
	oh-my-posh init pwsh --config "${env:USERPROFILE}\Documents\tools\configurations\powerlevel10k_rainbow.omp.json" > "${HOME}\tmp\oh-my-posh-init.ps1"
	& "${HOME}\tmp\oh-my-posh-init.ps1"
	& oh-my-posh completion powershell > "${HOME}\tmp\oh-my-posh-completion.ps1"
	& "${HOME}\tmp\oh-my-posh-completion.ps1"
	${env:VIRTUAL_ENV_DISABLE_PROMPT}=$true

	# Use posh-git: https://github.com/dahlbyk/posh-git
	if (-not(Get-Module -ListAvailable posh-git)) {
		Import-Module posh-git
	}
}

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

	Copy-Item -r C:\Tools\fakenet\ "$DestinationPath"
}

function Copy-Node {
	Param (
        [string]$DestinationPath = "."
    )

	if (!(Test-Path "$DestinationPath")) {
		New-Item -ItemType Directory "$DestinationPath"
	}

	Copy-Item -r C:\Tools\node "$DestinationPath"
}

function Restore-Quarantine {
	if (!(Test-Path "C:\ProgramData\Microsoft\Windows Defender" )) {
		New-Item -ItemType Directory "C:\ProgramData\Microsoft\Windows Defender" > $null
	}


	if (Test-Path "C:\ProgramData\Microsoft\Windows Defender\Quarantine" ) {
		Write-Output "Directory C:\ProgramData\Microsoft\Windows Defender\Quarantine exists. Remove and try again."
		return
	}

	if (Test-Path "C:\Users\WDAGUtilityAccount\Desktop\readonly\Quarantine.zip") {
		Remove-Item -r -Force "C:\tmp\Quarantine" > $null 2>&1
		& "$env:ProgramFiles\7-Zip\7z.exe" x "C:\Users\WDAGUtilityAccount\Desktop\readonly\Quarantine.zip" -oc:\tmp > $null
		if (!(Test-Path "C:\tmp\Quarantine")) {
			Write-Output "Zip file didn't contain directory Quarantine."
			return
		}
		Copy-Item -r "C:\tmp\Quarantine" "C:\ProgramData\Microsoft\Windows Defender"
		return
	} elseif (Test-Path "C:\Users\WDAGUtilityAccount\Desktop\readonly\Quarantine" ) {
		Copy-Item -r "C:\Users\WDAGUtilityAccount\Desktop\readonly\Quarantine" "C:\ProgramData\Microsoft\Windows Defender"
		return
	}

	Write-Output "No directory ~\Desktop\readonly\Quarantine or file ~\Desktop\readonly\Quarantine.zip!"
}

# Dynamically added functions below
