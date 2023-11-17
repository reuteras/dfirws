
$SOURCE = "M:\IT\dfirws"

Write-Output "Installing and updating files."
Write-Output "Update downloads."
Robocopy.exe /MT:96 /MIR "$SOURCE\dfirws\downloads" .\downloads  > $null
Write-Output "Update mount."
Robocopy.exe /MT:96 /MIR "$SOURCE\dfirws\mount" .\mount > $null
Write-Output "Update setup."
Robocopy.exe /MT:96 /MIR "$SOURCE\dfirws\setup" .\setup /XF "config.txt" > $null
Write-Output "Update other files."
Copy-Item "$SOURCE\dfirws\README.md" .\README.md > $null
Copy-Item "$SOURCE\dfirws\createSandboxConfig.ps1" .\createSandboxConfig.ps1 > $null
Copy-Item "$SOURCE\dfirws\dfirws.wsb.template" .\dfirws.wsb.template > $null

if ( -not (Test-Path -Path dfirws.wsb -PathType Leaf )) {
	.\createSandboxConfig.ps1
	Write-Output "Created wsb configuration"
}

$folders = "local", "readonly", "readwrite"

foreach ($folder in $folders) {
	if (! (Test-Path .\$folder)) {
		New-Item -ItemType Directory .\$folder
	}
}

Copy-Item "$SOURCE\dfirws\local\example-customize.ps1" .\local\example-customize.ps1 > $null

if($Null -eq (Get-Process "WindowsSandbox" -ea SilentlyContinue) ){
	Write-Output "Starting sandbox."
	.\dfirws.wsb
} else {
	Write-Output "Sandbox is running."
}

if ($MyInvocation.InvocationName -eq "&") {
	read-host "Press ENTER to close window..."
}