. $PSScriptRoot\common.ps1

Write-DateLog "Download tools via winget."

Remove-Item -Recurse -Force .\tmp\winget > $null 2>&1
winget download Microsoft.DotNet.Runtime.6 -d .\tmp\winget > $null 2>&1
Copy-Item .\tmp\winget\Microsoft*.exe .\downloads\dotnet6.exe
Remove-Item -Recurse -Force .\tmp\winget > $null 2>&1