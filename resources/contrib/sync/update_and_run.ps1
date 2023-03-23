
$SOURCE = "M:\IT\dfirws"

Write-Host "Installing and updating files."
Write-Host "Update downloads."
Robocopy.exe /MT:96 /MIR "$SOURCE\dfirws\downloads" .\downloads  > $null
Write-Host "Update mount."
Robocopy.exe /MT:96 /MIR "$SOURCE\dfirws\mount" .\mount > $null
Write-Host "Update setup."
Robocopy.exe /MT:96 /MIR "$SOURCE\dfirws\setup" .\setup /XF "config.txt" > $null
Write-Host "Update other files."
Copy-Item "$SOURCE\dfirws\README.md" .\README.md > $null
Copy-Item "$SOURCE\dfirws\createSandboxConfig.ps1" .\createSandboxConfig.ps1 > $null
Copy-Item "$SOURCE\dfirws\dfirws.wsb.template" .\dfirws.wsb.template > $null

if ( -not (Test-Path -Path dfirws.wsb -PathType Leaf )) {
	.\createSandboxConfig.ps1
	Write-Host "Created wsb configuration"
}

$folders = "local", "readonly", "readwrite"

foreach ($folder in $folders) {
	if (! (Test-Path .\$folder)) {
		mkdir .\$folder
	}
}

Copy-Item "$SOURCE\dfirws\local\example-customize.ps1" .\local\example-customize.ps1 > $null

if($Null -eq (Get-Process "WindowsSandbox" -ea SilentlyContinue) ){
	Write-Host "Starting sandbox."
	.\dfirws.wsb
} else {
	Write-Host "Sandbox is running."
}

if ($MyInvocation.InvocationName -eq "&") {
	read-host "Press ENTER to close window..."
}