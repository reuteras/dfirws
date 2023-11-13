# Download and update files for the sandbox

. .\resources\download\common.ps1

# Check if sandbox is running
if ( tasklist | findstr WindowsSandbox ) {
    Write-DateLog "Sandbox can't be running during install or upgrade."
    Exit
}

if ($args.Count -eq 0) {
    Write-DateLog "No arguments given. Will download all files."
    $all = $true
}

# Remove old files
if ($all) {
    Remove-Item -r $TOOLS > $null 2>$1
    mkdir $TOOLS > $null 2>$1
    mkdir $TOOLS\bin > $null 2>$1
    mkdir $TOOLS\lib > $null 2>$1
    mkdir $TOOLS\Zimmerman > $null 2>$1
}
Remove-Item -Recurse -Force .\tmp\downloads\ > $null 2>&1

if (!(Test-Path .\downloads)) {
    New-Item -ItemType Directory -Force -Path .\downloads > $null 2>&1
}

# Ensure that we have a log directory and a clean log files
if (! (Test-Path -Path ".\log" )) {
    New-Item -ItemType Directory -Force -Path ".\log" > $null
}
Get-Date > ".\log\log.txt"
Get-Date > ".\log\jobs.txt"

# The scripts git and http are needed by the Python script.
# Most scripts need http.ps1.
# Get GitHub password from user input
write-dateLog "Use GitHub token to avoid problems with ratelimits."
$GH_USER = Read-Host "Enter GitHub user name"
$PASS = Read-Host "Enter GitHub token" -AsSecureString
$GH_PASS =[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PASS))
$null = $GH_PASS
$null = $GH_USER

# Download files
.\resources\download\http.ps1
Write-DateLog "Download packages for Git for Windows (bash)."
Start-Job -FilePath .\resources\download\bash.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList $PSScriptRoot | Out-Null
Write-DateLog "Setup Node and install npm packages."
Start-Job -FilePath .\resources\download\node.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList $PSScriptRoot | Out-Null
.\resources\download\git.ps1
if ($all || $args -contains "python") {
    Write-Output "" > .\log\python.txt
    Write-DateLog "Setup Python and install packages."
    Start-Job -FilePath .\resources\download\python.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList $PSScriptRoot | Out-Null
}
.\resources\download\release.ps1
.\resources\download\didier.ps1
.\resources\download\winget-download.ps1
.\resources\download\zimmerman.ps1
Write-DateLog "Wait for sandboxes."
Get-Job | Wait-Job | Out-Null
Get-Job | Receive-Job > .\log\jobs.txt 2>&1
Get-Job | Remove-Job | Out-Null
Write-DateLog "Sandboxes done."
Copy-Item README.md .\downloads\
Copy-Item .\resources\images\dfirws.jpg .\downloads\
Copy-Item ".\setup\utils\PowerSiem.ps1" ".\mount\Tools\bin\"
Copy-Item .\mount\git\CapaExplorer\capaexplorer.py ./mount/Tools/ghidra/Ghidra/Features/Python/ghidra_scripts
# done.txt is used to check last update in sandbox
Write-Output "" > .\downloads\done.txt
Write-DateLog "Download and preparations done."
