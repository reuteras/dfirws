# Download and update files for the sandbox

. .\resources\download\common.ps1

# Check if sandbox is running

if ($args.Count -eq 0) {
    Write-DateLog "No arguments given. Will download all files."
    $all = $true
} else {
    $all = $false
}

if ($all -or $args -contains "--bash" -or $args -contains "--node" -or $args -contains "--python") {
    if ( tasklist | findstr WindowsSandbox ) {
        Write-DateLog "Sandbox can't be running during install or upgrade."
        Exit
    }
}

# Remove old files
if ($all) {
    Remove-Item -r $TOOLS > $null 2>$1
    New-Item -ItemType Directory $TOOLS > $null 2>$1
    New-Item -ItemType Directory $TOOLS\bin > $null 2>$1
    New-Item -ItemType Directory $TOOLS\lib > $null 2>$1
    New-Item -ItemType Directory $TOOLS\Zimmerman > $null 2>$1
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
if ($all -or $args -contains "--git" -or $args -contains "--http" -or $args -contains "--release" -or $args -contains "--didier") {
    write-dateLog "Use GitHub token to avoid problems with rate limits."
    $GH_USER = Read-Host "Enter GitHub user name"
    $PASS = Read-Host "Enter GitHub token" -AsSecureString
    $GH_PASS =[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PASS))
    $null = $GH_PASS
    $null = $GH_USER
}

if ($all -or $args -contains "--http") {
    Write-DateLog "Download files via HTTP."
    .\resources\download\http.ps1
}

if ($all -or $args -contains "--bash") {
    Write-DateLog "Download packages for Git for Windows (bash)."
    Start-Job -FilePath .\resources\download\bash.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList $PSScriptRoot | Out-Null
}

if ($all -or $args -contains "--node") {
    Write-DateLog "Setup Node and install npm packages."
    Start-Job -FilePath .\resources\download\node.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList $PSScriptRoot | Out-Null
}

if ($all -or $args -contains "--git") {
    Write-DateLog "Download git repositories"
    .\resources\download\git.ps1
}

if ($all -or $args -contains "--python") {
    Write-Output "" > .\log\python.txt
    Write-DateLog "Setup Python and install packages."
    Start-Job -FilePath .\resources\download\python.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList $PSScriptRoot | Out-Null
}

if ($all -or $args -contains "--release") {
    Write-DateLog "Download releases from GitHub."
    .\resources\download\release.ps1
}

if ($all -or $args -contains "--didier") {
    Write-DateLog "Download Didier Stevens tools."
    .\resources\download\didier.ps1
}

if ($all -or $args -contains "--winget") {
    Write-DateLog "Download tools via winget."
    .\resources\download\winget-download.ps1
}

if ($all -or $args -contains "--zimmerman") {
    Write-DateLog "Download Zimmerman tools."
    .\resources\download\zimmerman.ps1
}

if ($all -or $args -contains "--bash" -or $args -contains "--node" -or $args -contains "--python") {
    Write-DateLog "Wait for sandboxes."
    Get-Job | Wait-Job | Out-Null
    Get-Job | Receive-Job > .\log\jobs.txt 2>&1
    Get-Job | Remove-Job | Out-Null
    Write-DateLog "Sandboxes done."
}

Copy-Item README.md .\downloads\
Copy-Item .\resources\images\dfirws.jpg .\downloads\
Copy-Item ".\setup\utils\PowerSiem.ps1" ".\mount\Tools\bin\"
Copy-Item .\mount\git\CapaExplorer\capaexplorer.py ./mount/Tools/ghidra/Ghidra/Features/Python/ghidra_scripts
# done.txt is used to check last update in sandbox
Write-Output "" > .\downloads\done.txt
Write-DateLog "Downloads and preparations done."