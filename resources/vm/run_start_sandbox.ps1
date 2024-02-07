Write-Output "Run start_sandbox.ps1 to setup the environment."
Start-Process -wait powershell -Verb RunAs -ArgumentList "-NoProfile -NoExit -command & { & '\\vmware-host\Shared Folders\dfirws\setup\start_sandbox.ps1' }"
