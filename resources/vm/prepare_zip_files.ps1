if (!(Test-Path -Path ".\tmp")) {
    New-Item -ItemType Directory -Path ".\tmp" -Force | Out-Null
}

Write-Output "Creating zip for git"

foreach ($zip in ("git.zip", "tools.zip", "venv.zip")) {
    if (Test-Path ".\tmp\$zip") {
        Remove-Item ".\tmp\$zip" -Force
    }
}

Set-Location ".\mount"
& "${env:ProgramFiles}\7-Zip\7z.exe" a "..\tmp\git.zip" "git" | Out-Null
Write-Output "Creating zip for Tools"
& "${env:ProgramFiles}\7-Zip\7z.exe" a "..\tmp\tools.zip" "Tools" | Out-Null
Write-Output "Creating zip for venv"
& "${env:ProgramFiles}\7-Zip\7z.exe" a "..\tmp\venv.zip" "venv" | Out-Null
Set-Location ".."
Write-Output "Creating zip done"
