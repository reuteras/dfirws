Copy-Item D:\dfirws.zip .
Robocopy.exe D:\dfirws\ .\dfirws\ /MIR /XF "update_and_run.ps1" /XF "config.txt" /MT:96