if (!(Test-Path -Path ".\tmp")) {
    New-Item -ItemType Directory -Path ".\tmp" -Force | Out-Null
}

# Resolve 7-Zip path: check PATH first, then common install locations
if (Get-Command "7z.exe" -ErrorAction SilentlyContinue) {
    $SEVENZIP = "7z.exe"
} else {
    $SEVENZIP = @("${env:ProgramFiles}\7-Zip\7z.exe", "${env:ProgramFiles(x86)}\7-Zip\7z.exe") |
        Where-Object { Test-Path $_ } | Select-Object -First 1
}

Write-Output "Creating zip for git"

foreach ($zip in ("git.zip", "tools.zip", "venv.zip")) {
    if (Test-Path ".\tmp\$zip") {
        Remove-Item ".\tmp\$zip" -Force
    }
}

Set-Location ".\mount"
& $SEVENZIP a "..\tmp\git.zip" "git" | Out-Null
Write-Output "Creating zip for Tools"
& $SEVENZIP a "..\tmp\tools.zip" "Tools" | Out-Null
Write-Output "Creating zip for venv"
& $SEVENZIP a "..\tmp\venv.zip" "venv" | Out-Null
Set-Location ".."
Write-Output "Creating zip done"
