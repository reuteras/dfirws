Start-Sleep 5

Set-Location "\\vmware-host\Shared Folders\dfirws"

. ".\setup\wscommon.ps1"

# Create C:\tmp
if (-not (Test-Path -Path "C:\tmp")) {
    New-Item -ItemType Directory -Path "C:\tmp"
}

if (Test-Path ".\local\config.txt") {
    Copy-Item -Force -Path ".\local\config.txt" -Destination "C:\tmp\config.ps1"
} else {
    Copy-Item -Force -Path ".\local\default-config.txt" -Destination "C:\tmp\config.ps1"
}

. "C:\tmp\config.ps1"

Write-Output "Copying files to ${WSDFIR_ROOT}"

# Copy files to the root directory
Write-Output "Copying downloads to the root directory..."
Copy-Item -Recurse -Force ".\downloads" "${WSDFIR_ROOT}"
Write-Output "Copying enrichment to the root directory..."
Copy-Item -Recurse -Force ".\enrichment" "${WSDFIR_ROOT}"
Write-Output "Copying local to the root directory..."
Copy-Item -Recurse -Force ".\local" "${WSDFIR_ROOT}"
Write-Output "Extracting git.zip to the root directory..."
& "${env:ProgramFiles}\7-Zip\7z.exe" x -o"${WSDFIR_ROOT}" ".\tmp\git.zip" | Out-Null
Write-Output "Extracting Tools.zip to the root directory..."
& "${env:ProgramFiles}\7-Zip\7z.exe" x -o"${WSDFIR_ROOT}" ".\tmp\tools.zip" | Out-Null
Write-Output "Extracting venv.zip to the root directory..."
& "${env:ProgramFiles}\7-Zip\7z.exe" x -o"${WSDFIR_ROOT}" ".\tmp\venv.zip" | Out-Null

if (-not (Test-Path -Path "${HOME}\Documents\tools")) {
    New-Item -ItemType Directory -Force -Path "${HOME}\Documents\tools" | Out-Null
}

Write-Output "Copying setup to the tools directory in the user's directory..."
Copy-Item -Recurse -Force .\setup\* "${HOME}\Documents\tools"
