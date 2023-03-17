# This script runs in a Windows sandbox to prebuild the venv environment.
Write-Output "Install npm packages"
# Update path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$env:SETUP_PATH\nodejs.zip" -o"$env:TOOLS\node"
Set-Location "$env:TOOLS\node\node-*"
Move-Item * ..

Set-Location $env:TOOLS\node
Remove-Item -r -Force node-v*
.\npm init -y
.\npm install --global deobfuscator
.\npm install --global jsdom
