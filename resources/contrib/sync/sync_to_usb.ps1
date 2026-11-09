# Sync files to USB disc
$SOURCE_DIRECTORY="$HOME\Documents\workspace\dfirws"
$CURRENT="$PWD"

# Read $SYNC_UV_CACHE from dfirws-config.ps1 (or the template) without dot-sourcing it,
# since the config may call a password manager to read secrets.
$SYNC_UV_CACHE = $true
foreach ($configFile in "$SOURCE_DIRECTORY\dfirws-config.ps1", "$SOURCE_DIRECTORY\dfirws-config.ps1.template") {
    if (Test-Path $configFile) {
        $match = Select-String -Path $configFile -Pattern '^\s*\$SYNC_UV_CACHE\s*=\s*\$(true|false)\b' | Select-Object -Last 1
        if ($match) {
            $SYNC_UV_CACHE = $match.Matches[0].Groups[1].Value -eq "true"
        }
        break
    }
}
$UV_CACHE_DIRECTORY = "$SOURCE_DIRECTORY\mount\venv\cache"

if ($args -contains "--zip") {
    # Resolve 7-Zip path: check PATH first, then common install locations
    if (Get-Command "7z.exe" -ErrorAction SilentlyContinue) {
        $SEVENZIP = "7z.exe"
    } else {
        $SEVENZIP = @("${env:ProgramFiles}\7-Zip\7z.exe", "${env:ProgramFiles(x86)}\7-Zip\7z.exe") |
            Where-Object { Test-Path $_ } | Select-Object -First 1
    }
    Set-Location "$SOURCE_DIRECTORY"
    $SEVENZIP_ARGS = "a .\tmp\dfirws.zip .\downloads .\enrichment .\mount .\setup"
    if (! $SYNC_UV_CACHE) {
        $SEVENZIP_ARGS += " -x!mount\venv\cache"
    }
    Start-Process -Wait $SEVENZIP -Argumentlist $SEVENZIP_ARGS
    Get-Job | Receive-Job
    Get-Job | Remove-Job
    Copy-Item ".\tmp\dfirws.zip" "$CURRENT"
    Remove-Item -Force ".\tmp\dfirws.zip"
    Set-Location "$CURRENT"
}

if (! (Test-Path .\dfirws\local) ) {
    New-Item -ItemType Directory .\dfirws\local
}

foreach ($folder in "tabby", "vscode") {
    if (! (Test-Path .\dfirws\local\$folder) ) {
        New-Item -ItemType Directory .\dfirws\local\$folder -Force
    }
}

Write-Output "Syncing downloads"
Robocopy.exe $SOURCE_DIRECTORY\downloads .\dfirws\downloads /MIR /MT:96 | Out-Null
Write-Output "Syncing enrichment"
Robocopy.exe $SOURCE_DIRECTORY\enrichment .\dfirws\enrichment /MIR /MT:96 | Out-Null
Write-Output "Syncing defaults"
Robocopy.exe $SOURCE_DIRECTORY\local\defaults .\dfirws\local\defaults /MIR /MT:96 | Out-Null
Write-Output "Syncing mount"
if ($SYNC_UV_CACHE) {
    Robocopy.exe $SOURCE_DIRECTORY\mount .\dfirws\mount /MIR /MT:96 | Out-Null
} else {
    # /MIR does not purge excluded directories, so remove an earlier copy of the cache.
    # sync_from_usb.ps1 and dfirws.ps1 then remove it downstream with their own /MIR.
    if (Test-Path .\dfirws\mount\venv\cache) {
        Write-Output "Removing uv cache from USB since SYNC_UV_CACHE is false"
        Remove-Item -Recurse -Force .\dfirws\mount\venv\cache
    }
    Robocopy.exe $SOURCE_DIRECTORY\mount .\dfirws\mount /MIR /MT:96 /XD $UV_CACHE_DIRECTORY | Out-Null
}
Write-Output "Syncing resources"
Robocopy.exe $SOURCE_DIRECTORY\resources .\dfirws\resources /MIR /MT:96 | Out-Null
Write-Output "Syncing setup"
Robocopy.exe $SOURCE_DIRECTORY\setup .\dfirws\setup /MIR /MT:96 | Out-Null

Write-Output "Copying files"
Copy-Item $SOURCE_DIRECTORY\createSandboxConfig.ps1 .\dfirws\
Copy-Item $SOURCE_DIRECTORY\README.md .\dfirws\
Write-Output "Done"
