Write-Output "Run start_sandbox.ps1 to setup the environment."
Start-Process -Wait powershell -Verb RunAs -ArgumentList "-command & '\\vmware-host\Shared Folders\dfirws\setup\start_sandbox.ps1'"
