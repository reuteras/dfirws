Write-Output "Installing and updating files for dfirws"

$source = "M:\IT\dfirws"

if (! (Test-Path "${HOME}\dfirws")) {
	Write-Output "Creating directory ${HOME}\dfirws for dfirws"
	mkdir "${HOME}\dfirws" | Out-Null

	Set-Location "${HOME}\dfirws"

	Write-Output "Copy initial zip file"
	Copy-Item "${source}\dfirws.zip" .
	Write-Output "Expand zip"
	tar -xf dfirws.zip | Out-Null
	Write-Output "Remove zip"
	Remove-Item dfirws.zip
}

Write-Output "Update downloads"
Robocopy.exe /MT:96 /MIR "${source}\dfirws\downloads" "${HOME}\dfirws\downloads"  | Out-Null

Write-Output "Update mount"
Robocopy.exe /MT:96 /MIR "${source}\dfirws\mount" "${HOME}\dfirws\mount" | Out-Null

Write-Output "Update setup."
Robocopy.exe /MT:96 /MIR "${source}\dfirws\setup" "${HOME}\dfirws\setup" /XF "config.txt" | Out-Null

$folders = "local", "readonly", "readwrite"
foreach ($folder in $folders) {
	if (! (Test-Path "${HOME}\dfirws\$folder")) {
		mkdir "${HOME}\dfirws\$folder" | Out-Null
	}
}

Write-Output "Update other files."
if (Test-Path "${HOME}\dfirws\dfirws.ps1" ) {
	Copy-Item "${source}\dfirws.ps1" "${HOME}\dfirws\dfirws.ps1" | Out-Null
}

Copy-Item "${source}\dfirws\README.md" "${HOME}\dfirws\README.md" | Out-Null
Copy-Item "${source}\dfirws\createSandboxConfig.ps1" "${HOME}\dfirws\createSandboxConfig.ps1" | Out-Null
Copy-Item "${source}\dfirws\dfirws.wsb.template" "${HOME}\dfirws\dfirws.wsb.template" | Out-Null
Copy-Item "${source}\dfirws\local\default-config.txt" "${HOME}\dfirws\local\default-config.txt" | Out-Null
Copy-Item "${source}\dfirws\local\example-customize.ps1" "${HOME}\dfirws\local\example-customize.ps1" | Out-Null
Copy-Item "${source}\dfirws\local\.bashrc.default" "${HOME}\dfirws\local\" | Out-Null
Copy-Item "${source}\dfirws\local\.zcompdump.default" "${HOME}\dfirws\local\" | Out-Null
Copy-Item "${source}\dfirws\local\.zshrc.default" "${HOME}\dfirws\local\" | Out-Null
Copy-Item "${source}\dfirws\local\default-Microsoft.PowerShell_profile.ps1" "${HOME}\dfirws\local\" | Out-Null

if ( -not (Test-Path -Path "${HOME}\dfirws\dfirws.wsb" -PathType Leaf )) {
	Write-Output "Create default dfirws.wsb"
	(Get-Content "${HOME}\dfirws\dfirws.wsb.template").replace("__SANDBOX__", "${HOME}\dfirws") | Set-Content "${HOME}\dfirws\dfirws.wsb"
}

if($Null -eq (Get-Process "WindowsSandbox" -ea SilentlyContinue) ){
	Write-Output "Starting sandbox."
	& "${HOME}\dfirws\dfirws.wsb"
} else {
	Write-Output "Sandbox is running and can only run one at the time."
}
