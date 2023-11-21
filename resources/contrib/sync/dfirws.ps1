Write-Output "Installing and updating files for dfirws"

$source = "M:\IT\dfirws"

if (! (Test-Path "$HOME\dfirws")) {
	Write-Output "Creating directory $HOME\dfirws for dfirws"
	mkdir "$HOME\dfirws" > $null

	Set-Location "$HOME\dfirws"

	Write-Output "Copy initial zip file"
	Copy-Item '$source\dfirws.zip' .
	Write-Output "Expand zip"
	tar -xf dfirws.zip > $null
	Write-Output "Remove zip"
	Remove-Item dfirws.zip
}

Write-Output "Update downloads"
Robocopy.exe /MT:96 /MIR "$source\dfirws\downloads" "$HOME\dfirws\downloads"  > $null

Write-Output "Update mount"
Robocopy.exe /MT:96 /MIR "$source\dfirws\mount" "$HOME\dfirws\mount" > $null

Write-Output "Update setup."
Robocopy.exe /MT:96 /MIR "$source\dfirws\setup" "$HOME\dfirws\setup" /XF "config.txt" > $null

$folders = "local", "readonly", "readwrite"
foreach ($folder in $folders) {
	if (! (Test-Path "$HOME\dfirws\$folder")) {
		mkdir "$HOME\dfirws\$folder" > $null
	}
}

Write-Output "Update other files."
Copy-Item "$source\dfirws\README.md" "$HOME\dfirws\README.md" > $null
Copy-Item "$source\dfirws\createSandboxConfig.ps1" "$HOME\dfirws\createSandboxConfig.ps1" > $null
Copy-Item "$source\dfirws\dfirws.wsb.template" "$HOME\dfirws\dfirws.wsb.template" > $null
Copy-Item "$source\dfirws\setup\default-config.txt" "$HOME\dfirws\setup\default-config.txt" > $null
Copy-Item "$source\dfirws\local\example-customize.ps1" "$HOME\dfirws\local\example-customize.ps1" > $null

if ( -not (Test-Path -Path "$HOME\dfirws\dfirws.wsb" -PathType Leaf )) {
	Write-Output "Create default dfirws.wsb"
	(Get-Content "$HOME\dfirws\dfirws.wsb.template").replace('__SANDBOX__', "$HOME\dfirws") | Set-Content "$HOME\dfirws\dfirws.wsb"

	if (! (Test-Path -Path "$HOME\dfirws\setup\config.txt")) {
		Copy-Item "$HOME\dfirws\setup\default-config.txt" "$HOME\dfirws\setup\config.txt"
		Write-Output "Created $HOME\dfirws\tools\config.txt. You can use it to customize tools to install based on your needs."
	}
}

if($Null -eq (Get-Process "WindowsSandbox" -ea SilentlyContinue) ){
	Write-Output "Starting sandbox."
	& "$HOME\dfirws\dfirws.wsb"
} else {
	Write-Output "Sandbox is running and can only run one at the time."
}
