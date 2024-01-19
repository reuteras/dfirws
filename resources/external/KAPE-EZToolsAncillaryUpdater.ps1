<#
	.SYNOPSIS
		Keep KAPE and all the included EZ Tools updated! Be sure to run this script from the root of your KAPE folder, i.e., where kape.exe, gkape.exe, Targets, Modules, and Documentation folders exists

	.DESCRIPTION
		Updates the following:

		KAPE binary (.KAPE\kape.exe) - https://www.kroll.com/en/services/cyber-risk/incident-response-litigation-support/kroll-artifact-parser-extractor-kape
		KAPE Targets (.\KAPE\Targets\*.tkape) - https://github.com/EricZimmerman/KapeFiles/tree/master/Targets
		KAPE Modules (.\KAPE\Modules\*.mkape) - https://github.com/EricZimmerman/KapeFiles/tree/master/Modules
		RECmd Batch Files (.\KAPE\Modules\bin\RECmd\BatchExamples\*.reb) - https://github.com/EricZimmerman/RECmd/tree/master/BatchExamples
		EvtxECmd Maps (.\KAPE\Modules\bin\EvtxECmd\Maps\*.map) - https://github.com/EricZimmerman/evtx/tree/master/evtx/Maps
		SQLECmd Maps (.\KAPE\Modules\bin\SQLECmd\Maps\*.smap) - https://github.com/EricZimmerman/SQLECmd/tree/master/SQLMap/Maps
		All other EZ Tools used by KAPE in the !EZParser Module

	.USAGE
		As of 4.0, this script will only download .NET 6 tools, so you can just run the script in your .\KAPE folder!

	.CHANGELOG
		1.0 - (Sep 09, 2021) Initial release
		2.0 - (Oct 22, 2021) Updated version of KAPE-EZToolsAncillaryUpdater PowerShell script which leverages Get-KAPEUpdate.ps1 and Get-ZimmermanTools.ps1 as well as other various --sync commands to keep all of KAPE and the command line EZ Tools updated to their fullest potential with minimal effort. Signed script with certificate
		3.0 - (Feb 22, 2022) Updated version of KAPE-EZToolsAncillaryUpdater PowerShell script which gives user option to leverage either the .NET 4 or .NET 6 version of EZ Tools in the .\KAPE\Modules\bin folder. Changed logic so EZ Tools are downloaded using the script from .\KAPE\Modules\bin rather than $PSScriptRoot for cleaner operation and less chance for issues. Added changelog. Added logging capabilities
		3.1 - (Mar 17, 2022) Added a "silent" parameter that disables the progress bar and exits the script without pausing in the end
		3.2 - (Apr 04, 2022) Updated Move-EZToolNET6 to use glob searching instead of hardcoded folder and file paths
		3.3 - (Apr 25, 2022) Updated Move-EZToolsNET6 to correct Issue #9 - https://github.com/AndrewRathbun/KAPE-EZToolsAncillaryUpdater/issues/9. Also updated content and formatting of some of the comments
		3.4 - (Jun 24, 2022) Added version checker for the script - https://github.com/AndrewRathbun/KAPE-EZToolsAncillaryUpdater/issues/11. Added new messages re: GitHub repositories to follow at the end of each successful run
		3.5 - (Jul 27, 2022) Bug fix for version checker added in 3.4 - https://github.com/AndrewRathbun/KAPE-EZToolsAncillaryUpdater/pull/15
		3.6 - (Aug 17, 2022) Added iisGeolocate now that a KAPE Module exists for it, updated comments and log messages
		4.0 - (June 13, 2023) Made adjustments to script based on Get-ZimmermanTools.ps1 update - https://github.com/EricZimmerman/Get-ZimmermanTools/commit/c40e8ddc8df5a210c5d9155194e602a81532f23d, script now defaults to .NET 6, modified lots of comments, variables, etc, and overall made the script more readable and maintainable
		4.1 - (June 16, 2023) Minor adjustments based on feedback from version 4.0. Additionally, added script info to the log output
		4.2 - (August 04, 2023) Added PowerShell 5 requirement to avoid any potential complications
		x.x - (January 19, 2024) Minimize script for use with dfirws.

	.PARAMETER silent
		Disable the progress bar and exit the script without pausing in the end

	.PARAMETER DoNotUpdate
		Use this if you do not want to check for and update the script

	.NOTES
		===========================================================================
		Created with:	 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.201
		Created on:   		2022-02-22 23:29
		Created by:	   		Andrew Rathbun
		Organization: 		Kroll
		Filename:			KAPE-EZToolsAncillaryUpdater.ps1
		GitHub:				https://github.com/AndrewRathbun/KAPE-EZToolsAncillaryUpdater
		Version:			4.2
		===========================================================================
#>

#Requires -Version 5

param()

function Get-TimeStamp {
	return '[{0:yyyy/MM/dd} {0:HH:mm:ss}]' -f (Get-Date)
}

function Log {
	param (
		[Parameter(Mandatory = $true)]
		[string]$logFilePath,
		[string]$msg
	)

	$msg = Write-Output "$(Get-TimeStamp) | $msg"
	Out-File $logFilePath -Append -InputObject $msg -Encoding ASCII
	Write-Output $msg
}

$script:logFilePath = Join-Path $PSScriptRoot -ChildPath "KAPEUpdateLog.log"
$ProgressPreference = 'SilentlyContinue'

function Start-Script {
	[CmdletBinding()]
	param ()

	# Validate that logFilePath exists and shoot a message to the user one way or another
	if (!(Test-Path -Path $logFilePath)) {
		New-Item -ItemType File -Path $logFilePath -Force | Out-Null
	}
}

function Set-Environment {
	[CmdletBinding()]
	param ()

	# Setting variables the script relies on. Comments show expected values stored within each respective variable
	$script:kapeTargetsFolder = Join-Path -Path $PSScriptRoot -ChildPath 'Targets' # .\KAPE\Targets
	$script:kapeModulesFolder = Join-Path -Path $PSScriptRoot -ChildPath 'Modules' # .\KAPE\Modules
	$script:kapeModulesBin = Join-Path -Path $kapeModulesFolder -ChildPath 'bin' # .\KAPE\Modules\bin
	$script:getZimmermanToolsFolderKape = Join-Path -Path $kapeModulesBin -ChildPath 'ZimmermanTools' # .\KAPE\Modules\bin\ZimmermanTools, also serves as our .NET 4 folder, if needed
	$script:getZimmermanToolsFolderKapeNet6 = Join-Path -Path $getZimmermanToolsFolderKape -ChildPath 'net6' # .\KAPE\Modules\bin\ZimmermanTools\net6

	$script:ZTZipFile = 'Get-ZimmermanTools.zip'
	$script:ZTdlUrl = "https://f001.backblazeb2.com/file/EricZimmermanTools/$ZTZipFile" # https://f001.backblazeb2.com/file/EricZimmermanTools\Get-ZimmermanTools.zip
	$script:getZimmermanToolsFolderKapeZip = Join-Path -Path $getZimmermanToolsFolderKape -ChildPath $ZTZipFile # .\KAPE\Modules\bin\ZimmermanTools\Get-ZimmermanTools.zip - this currently doesn't get used...
	$script:kapeDownloadUrl = 'https://www.kroll.com/en/services/cyber-risk/incident-response-litigation-support/kroll-artifact-parser-extractor-kape'
	$script:kapeEzToolsAncillaryUpdaterFileName = 'KAPE-EZToolsAncillaryUpdater.ps1'
	$script:getZimmermanToolsFileName = 'Get-ZimmermanTools.ps1'
	$script:getKapeUpdatePs1FileName = 'Get-KAPEUpdate.ps1'
	$script:kape = Join-Path -Path $PSScriptRoot -ChildPath 'kape.exe' # .\KAPE\kape.exe
	$script:getZimmermanToolsZipKape = Join-Path -Path $kapeModulesBin -ChildPath $ZTZipFile # .\KAPE\Modules\bin\Get-ZimmermanTools.zip
	$script:getZimmermanToolsPs1Kape = Join-Path -Path $kapeModulesBin -ChildPath $getZimmermanToolsFileName # .\KAPE\Modules\bin\Get-ZimmermanTools.ps1

	# setting variables for EZ Tools binaries, folders, and folders containing ancillary files within .\KAPE\Modules\bin
	$script:kapeRecmd = Join-Path $kapeModulesBin -ChildPath 'RECmd' #.\KAPE\Modules\bin\RECmd
	$script:kapeRecmdExe = Get-ChildItem $kapeRecmd -Filter 'RECmd.exe' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName #.\KAPE\Modules\bin\RECmd\RECmd.exe
	$script:kapeRecmdBatchExamples = Join-Path $kapeRecmd -ChildPath 'BatchExamples' #.\KAPE\Modules\bin\RECmd\BatchExamples
	$script:kapeEvtxECmd = Join-Path $kapeModulesBin -ChildPath 'EvtxECmd' #.\KAPE\Modules\bin\EvtxECmd
	$script:kapeEvtxECmdExe = Get-ChildItem $kapeEvtxECmd -Filter 'EvtxECmd.exe' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName #.\KAPE\Modules\bin\EvtxECmd\EvtxECmd.exe
	$script:kapeEvtxECmdMaps = Join-Path $kapeEvtxECmd -ChildPath 'Maps' #.\KAPE\Modules\bin\EvtxECmd\Maps
	$script:kapeSQLECmd = Join-Path $kapeModulesBin -ChildPath 'SQLECmd' #.\KAPE\Modules\bin\SQLECmd
	$script:kapeSQLECmdExe = Get-ChildItem $kapeSQLECmd -Filter 'SQLECmd.exe' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName #.\KAPE\Modules\bin\SQLECmd\SQLECmd.exe
	$script:kapeSQLECmdMaps = Join-Path $kapeSQLECmd -ChildPath 'Maps' #.\KAPE\Modules\bin\SQLECmd\Maps
}

<#
	.SYNOPSIS
		Updates the KAPE binary (kape.exe)

	.DESCRIPTION
		Uses the preexisting .\Get-KAPEUpdate.ps1 script to update the KAPE binary (kape.exe)
#>
function Get-KAPEUpdateEXE {
	[CmdletBinding()]
	param ()
	Log -logFilePath $logFilePath -msg ' --- Update KAPE ---'

	$script:getKapeUpdatePs1 = Get-ChildItem -Path $PSScriptRoot -Filter $getKapeUpdatePs1FileName # .\KAPE\Get-KAPEUpdate.ps1
	Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$($getKapeUpdatePs1.FullName)`"" -NoNewWindow -Wait
}

<#
	.SYNOPSIS
		Downloads all EZ Tools!

	.DESCRIPTION
		Downloads Get-ZimmermanTools.zip, extracts Get-ZimmermanTools.ps1 from the ZIP file into .\KAPE\Modules\bin\ZimmermanTools
#>
function Get-Zimmerman {
	[CmdletBinding()]
	param ()

	Log -logFilePath $logFilePath -msg ' --- Get-ZimmermanTools.ps1 ---'

	if (! (Test-Path $getZimmermanToolsFolderKape)) {
		New-Item -ItemType Directory -Path $getZimmermanToolsFolderKape | Out-Null
	}

	$scriptArgs = @{
		Dest = "$getZimmermanToolsFolderKape"
	}

	try {
		Start-BitsTransfer -Source $ZTdlUrl -Destination $kapeModulesBin -ErrorAction Stop
	} catch {
		Log -logFilePath $logFilePath -msg "Failed to download $ZTZipFile from $ZTdlUrl. Error: $($_.Exception.Message)"
	}

	Expand-Archive -Path "$getZimmermanToolsZipKape" -DestinationPath "$kapeModulesBin" -Force
	$getZimmermanToolsPs1 = (Get-ChildItem -Path $kapeModulesBin -Filter $getZimmermanToolsFileName).FullName

	# Move Get-ZimmermanTools.ps1 from .\KAPE\Modules\bin to .\KAPE\Modules\bin\ZimmermanTools
	Move-Item -Path $getZimmermanToolsPs1 -Destination $getZimmermanToolsFolderKape -Force

	$getZimmermanToolsPs1ZT = (Get-ChildItem -Path $getZimmermanToolsFolderKape -Filter $getZimmermanToolsFileName).FullName

	Log -logFilePath $logFilePath -msg "Running $getZimmermanToolsFileName! Downloading .NET 6 version of EZ Tools to $getZimmermanToolsFolderKape"

	# executing .\KAPE\Modules\bin\Get-ZimmermanTools.ps1 -Dest .\KAPE\Modules\bin\ZimmermanTools
	Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile", "-File $getZimmermanToolsPs1ZT", "-Dest $($scriptArgs.Dest)" -Wait -NoNewWindow
}

<#
	.SYNOPSIS
		Sync with GitHub for the latest KAPE Targets and Modules!

	.DESCRIPTION
		This function will download the latest KAPE Targets and Modules from https://github.com/EricZimmerman/KapeFiles

	.NOTES
		Sync works without Admin privileges as of KAPE 1.0.0.3
#>
function Sync-KAPETargetsModule {
	[CmdletBinding()]
	param ()

	Log -logFilePath $logFilePath -msg 'Syncing KAPE with GitHub for the latest Targets and Modules'
	Start-Process $kape -ArgumentList '--sync' -NoNewWindow -Wait
}

<#
	.SYNOPSIS
		Sync with GitHub for the latest EvtxECmd Maps!

	.DESCRIPTION
		This function will download the latest EvtxECmd Maps from https://github.com/EricZimmerman/evtx
#>
function Sync-EvtxECmdMap {
	[CmdletBinding()]
	param ()

	Log -logFilePath $logFilePath -msg ' --- EvtxECmd Sync ---'

	# Check if $kapeEvtxECmdExe holds a value
	if ([string]::IsNullOrEmpty($kapeEvtxECmdExe)) {
		# Redo the original declaration
		$script:kapeEvtxECmdExe = (Get-ChildItem $kapeEvtxECmd -Filter 'EvtxECmd.exe').FullName
	}

	Start-Process $kapeEvtxECmdExe -ArgumentList '--sync' -NoNewWindow -Wait
}


<#
	.SYNOPSIS
		Sync with GitHub for the latest RECmd Batch files!

	.DESCRIPTION
		This function will download the latest RECmd Batch Files from https://github.com/EricZimmerman/RECmd
#>
function Sync-RECmdBatchFile {
	[CmdletBinding()]
	param ()

	Log -logFilePath $logFilePath -msg ' --- RECmd Sync ---'

	# This ensures all the latest RECmd Batch files are present on disk
	Log -logFilePath $logFilePath -msg 'Syncing RECmd with GitHub for the latest Maps'

	Start-Process $kapeRECmdExe -ArgumentList '--sync' -NoNewWindow -Wait
}

<#
	.SYNOPSIS
		Sync with GitHub for the latest SQLECmd Maps!

	.DESCRIPTION
		This function will download the latest Maps from https://github.com/EricZimmerman/SQLECmd
#>
function Sync-SQLECmdMap {
	[CmdletBinding()]
	param ()

	Log -logFilePath $logFilePath -msg ' --- SQLECmd Sync ---'

	# This ensures all the latest SQLECmd Maps are downloaded
	Log -logFilePath $logFilePath -msg 'Syncing SQLECmd with GitHub for the latest Maps'

	Start-Process $kapeSQLECmdExe -ArgumentList '--sync' -NoNewWindow -Wait
}

<#
	.SYNOPSIS
		Set up KAPE for use with .NET 6 EZ Tools!

	.DESCRIPTION
		Ensures all .NET 6 EZ Tools that were downloaded using Get-ZimmermanTools.ps1 are copied into the correct folders within .\KAPE\Modules\bin
#>
function Move-EZToolsNET6 {
	[CmdletBinding()]
	param ()

	# Only run if Get-ZimmermanTools.ps1 has downloaded new .NET 6 tools, otherwise continue on.
	if (Test-Path -Path "$getZimmermanToolsFolderKapeNet6") {
		# Create array of folders to be copied
		$folders = @(
			"$getZimmermanToolsFolderKapeNet6\EvtxECmd",
			"$getZimmermanToolsFolderKapeNet6\RECmd",
			"$getZimmermanToolsFolderKapeNet6\SQLECmd",
			"$getZimmermanToolsFolderKapeNet6\iisGeolocate"
		)

		# Copy each folder that exists
		$folderSuccess = @()
		foreach ($folder in $folders) {
			if (Test-Path -Path $folder) {
				Copy-Item -Path $folder -Destination $kapeModulesBin -Recurse -Force
				$folderSuccess += $folder.Split('\')[-1]
				Log -logFilePath $logFilePath -msg "Copying $folder and all contents to $kapeModulesBin"
			}
		}

		Log -logFilePath $logFilePath -msg ' --- EZ Tools File Copy ---'

		# Create an array of the file extensions to copy
		$fileExts = @('*.dll', '*.exe', '*.json')

		# Get all files in $getZimmermanToolsFolderKapeNet6 that match any of the extensions in $fileExts
		$files = Get-ChildItem -Path "$getZimmermanToolsFolderKapeNet6\*" -Include $fileExts

		# Copy the files to the destination
		foreach ($file in $files) {
			if (Test-Path $file) {
				Copy-Item -Path $file -Destination $kapeModulesBin -Recurse -Force
				Log -logFilePath $logFilePath -msg "Copying $file to $kapeModulesBin"
			}
		}

		# This removes the downloaded EZ Tools that we no longer need to reside on disk
		Log -logFilePath $logFilePath -msg "Removing extra copies of EZ Tools from $getZimmermanToolsFolderKapeNet6"
		Remove-Item -Path $getZimmermanToolsFolderKapeNet6 -Recurse -Force -ErrorAction SilentlyContinue
	} else {
		Log -logFilePath $logFilePath -msg "$getZimmermanToolsFolderKapeNet6 doesn't exist. Make sure you have the latest version of Get-ZimmermanTools.ps1 in $kapeModulesBin"
	}
}


# Now that all functions have been declared, let's start executing them in order
try
{
	# Let's get some basic info about the script and output it to the log
	Start-Script

	# Let's set up the variables we're going to need for the rest of the script
	Set-Environment

	# Let's update KAPE first
	& Get-KAPEUpdateEXE

	# Let's download Get-ZimmermanTools.zip and extract Get-ZimmermanTools.ps1
	& Get-Zimmerman

	# Let's move all EZ Tools and place them into .\KAPE\Modules\bin
	Move-EZToolsNET6

	# Let's update KAPE, EvtxECmd, RECmd, and SQLECmd's ancillary files
	& Sync-KAPETargetsModule
	& Sync-EvtxECmdMap
	& Sync-RECmdBatchFile
	& Sync-SQLECmdMap
}
catch [System.IO.IOException] {
	# Handle specific IOException related to file operations
	Log -logFilePath $logFilePath -msg "IOException occurred: $($_.Message)"
}
catch [System.Exception] {
	# Handle any other exception that may have occurred
	Log -logFilePath $logFilePath -msg "Exception occurred: $($_.Exception.Message)"
}
