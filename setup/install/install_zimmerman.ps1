# Set default encoding to UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

Write-Output "Download Zimmerman tools."
Write-DateLog "Download Zimmerman tools in Sandbox." >> "C:\log\zimmerman.txt"

Write-Output "Get-Content C:\log\zimmerman.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

# The Zimmerman tools are built for .NET 10. Install the runtime here so the host doesn't need it.
Write-DateLog "Install .NET 10 Desktop runtime." >> "C:\log\zimmerman.txt"
$procDotnet10 = Start-Process -Wait -PassThru "C:\downloads\dotnet10desktop.exe" -ArgumentList "/install /quiet /norestart"
if ($procDotnet10.ExitCode -ne 0) {
    Write-DateLog "WARNING: .NET 10 installer exited with code $($procDotnet10.ExitCode)" >> "C:\log\zimmerman.txt"
}
$env:PATH = "${env:ProgramFiles}\dotnet;${env:PATH}"

Write-DateLog "Run Get-ZimmermanTools.ps1." >> "C:\log\zimmerman.txt"
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File C:\resources\download\Get-ZimmermanTools.ps1 -Dest "C:\Zimmerman" -NetVersion 10 -NoUpdate 2>&1 | ForEach-Object{ "$_" } >> "C:\log\zimmerman.txt"

# Get-ZimmermanTools.ps1 extracts the .NET 10 builds to Zimmerman\net. Move them up one level so the paths used by dfirws stay the same.
if (Test-Path "C:\Zimmerman\net") {
    robocopy "C:\Zimmerman\net" "C:\Zimmerman" /E /MOVE /IS /IT /NFL /NDL /NJH /NJS /NP | Out-Null
}

# Remove the .NET 9 builds left by older versions of Get-ZimmermanTools.ps1
if (Test-Path "C:\Zimmerman\net9") {
    Remove-Item -Recurse -Force "C:\Zimmerman\net9"
}

Write-DateLog "Sync maps and batch files for EvtxECmd, RECmd and SQLECmd." >> "C:\log\zimmerman.txt"
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File C:\resources\external\Sync-EZTools.ps1 "C:\Zimmerman" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\zimmerman.txt"

Write-DateLog "Zimmerman tools done." >> "C:\log\zimmerman.txt"
Write-Output "" > "C:\tmp\zimmerman\done"
