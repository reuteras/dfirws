# DFIRWS

# Import common functions
if (Test-Path "${HOME}\Documents\tools\wscommon.ps1") {
    . "${HOME}\Documents\tools\wscommon.ps1"
} else {
    . '\\vmware-host\Shared Folders\dfirws\setup\wscommon.ps1'
}

# Verify that the file command is installed

try {
    Get-Command -ErrorAction Stop file.exe | Out-Null
}
catch {
    Write-Output "ERROR: Command file.exe isn't available. Exiting."
    return
}

# Basic tools
Test-Command 7z PE32

# Run tests in $SETUP_PATH\dfirws\verify_*.ps1 if they exists
$VERIFY_SCRIPTS = Get-ChildItem -Path "${SETUP_PATH}\dfirws" -Filter "verify_*.ps1" -ErrorAction SilentlyContinue
foreach ($script in $VERIFY_SCRIPTS) {
    Write-SynchronizedLog "Running verify script: $($script.FullName)"
    & $script.FullName
}

# Extra tools
if (Test-Path "${SETUP_PATH}\dokany.msi") {
    $DokanyExecutable = (Get-ChildItem 'C:\Program Files\Dokan\' -Recurse -Include dokanctl.exe).FullName | Select-Object -Last 1
    Test-Command $DokanyExecutable PE32
}
if (Test-Path "${SETUP_PATH}\jadx.zip") {
    $JadxLibrary = (Get-ChildItem 'C:\Program Files\Jadx\' -Recurse -Include *.jar).FullName
    Test-Command $JadxLibrary "Zip archive data"
}
if (Test-Path "${SETUP_PATH}\corretto.msi") {
    $jaccessinspectorExecutable = (Get-ChildItem 'C:\Program Files\Amazon Corretto' -Recurse -Include jaccessinspector.exe).FullName
    Test-Command $jaccessinspectorExecutable PE32
}

# Verify length of file names in Start Menu
(Get-ChildItem "C:\ProgramData\Microsoft\Windows\Start Menu\Programs" -Recurse).FullName | ForEach-Object { if ($_.Length -gt 250) {$message = "ERROR: Folder name to long " + ${_}.Length + " " + $_ ; Write-Output $message} }
