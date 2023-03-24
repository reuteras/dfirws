$SOURCE = "M:\IT\dfirws"

if (! (Test-Path "$HOME\Documents\dfirws")) {
	mkdir "$HOME\Documents\dfirws" > $null 2>&1
} else {
	Write-Output "Already installed! To reinstall delete the folder $HOME\Documents\dfirws and rerun the script."
	Exit
}

Set-Location "$HOME\Documents\dfirws"

if (! (Test-Path setup)) {
	Write-Output "Copy initial zip file to save time."
	Copy-Item "$SOURCE\dfirws.zip" . > $null
	Write-Output "Expand zip."
	tar -xf dfirws.zip > $null
	Write-Output "Remove zip."
	Remove-Item dfirws.zip
}

Copy-Item "$SOURCE\dfirws\update_and_run.ps1" .\update_and_run.ps1 > $null
.\update_and_run.ps1
