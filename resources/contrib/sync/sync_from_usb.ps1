Write-Output "Copy dfirws.zip"
Robocopy.exe E:\ M:\IT\dfirws\ dfirws.zip | Out-Null
Write-Output "Sync downloads"
Robocopy.exe E:\dfirws\downloads M:\IT\dfirws\dfirws\downloads /MIR /MT:96 | Out-Null
Write-Output "Sync enrichment"
Robocopy.exe E:\dfirws\enrichment M:\IT\dfirws\dfirws\enrichment /MIR /MT:96 | Out-Null
Write-Output "Sync local\defaults"
Robocopy.exe E:\dfirws\local\defaults M:\IT\dfirws\dfirws\local\defaults /MIR /MT:96 | Out-Null
Write-Output "Sync mount"
Robocopy.exe E:\dfirws\mount M:\IT\dfirws\dfirws\mount /MIR /MT:96 | Out-Null
Write-Output "Sync resources"
Robocopy.exe E:\dfirws\resources M:\IT\dfirws\dfirws\resources /MIR /MT:96 | Out-Null
Write-Output "Sync setup"
Robocopy.exe E:\dfirws\setup M:\IT\dfirws\dfirws\setup /MIR /MT:96 | Out-Null
Robocopy.exe E:\dfirws\ M:\IT\dfirws\dfirws\ createSandboxConfig.ps1 | Out-Null
Robocopy.exe E:\dfirws\ M:\IT\dfirws\dfirws\ README.md | Out-Null
