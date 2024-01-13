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
} else {
    $all = $false
}

if ($all -eq $false) {
    if (! (Test-Path "$TOOLS\bin" )) {
        Write-DateLog "No tools directory found. You have to run this script without arguments first."
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

if ($all -or $args -contains "--didier" -or $args -contains "--http" -or $args -contains "--release") {
    # Get GitHub password from user input
    write-dateLog "Use GitHub token to avoid problems with rate limits."
    $GH_USER = Read-Host "Enter GitHub user name"
    $PASS = Read-Host "Enter GitHub token" -AsSecureString
    $GH_PASS =[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PASS))
    $null = $GH_PASS
    $null = $GH_USER
}

if ($all -or $args -contains "--bash" -or $args -contains "--node" -or $args -contains "--python" -or $args -contains "--rust") {
    Write-DateLog "Download files needed in Sandboxes."
    . .\resources\download\basic.ps1
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

if ($all -or $args -contains "--rust") {
    Write-Output "" > .\log\rust.txt
    Write-DateLog "Setup Rust and install packages."
    Start-Job -FilePath .\resources\download\rust.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList $PSScriptRoot | Out-Null
}

if ($all -or $args -contains "--http") {
    Write-DateLog "Download files via HTTP."
    .\resources\download\http.ps1
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
    .\resources\download\winget.ps1
}

if ($all -or $args -contains "--zimmerman") {
    Write-DateLog "Download Zimmerman tools."
    .\resources\download\zimmerman.ps1
}

if ($all -or $args -contains "--kape") {
    if (Test-Path .\local\kape.zip) {
        Write-DateLog "Download KAPE."
        .\resources\download\kape.ps1
    }
}

if ($all -or $args -contains "--bash" -or $args -contains "--node" -or $args -contains "--python" -or $args -contains "--rust") {
    Write-DateLog "Wait for sandboxes."
    Get-Job | Wait-Job | Out-Null
    Get-Job | Receive-Job >> .\log\jobs.txt 2>&1
    Get-Job | Remove-Job | Out-Null
    Write-DateLog "Sandboxes done."
}

Copy-Item README.md .\downloads\
Copy-Item .\resources\images\dfirws.jpg .\downloads\
Copy-Item ".\setup\utils\PowerSiem.ps1" ".\mount\Tools\bin\"
Copy-Item .\mount\git\CapaExplorer\capaexplorer.py ./mount/Tools/ghidra/ghidra_10.4_PUBLIC/Ghidra/Features/Python/ghidra_scripts
# done.txt is used to check last update in sandbox
Write-Output "" > .\downloads\done.txt

$warnings = Get-ChildItem .\log\* -Recurse | Select-String -Pattern "warning" | Where-Object {
    $_.Line -notmatch " INFO " -and
    $_.Line -notmatch "This is taking longer than usual" -and
    $_.Line -notmatch "Installing collected packages" -and
    $_.Line -notmatch "pymispwarninglists" -and
    $_.Line -notmatch "warning: be sure to add"
}

$errors = Get-ChildItem .\log\* -Recurse | Select-String -Pattern "error" | Where-Object {
    $_.Line -notmatch "Error: no test specified" -and
    $_.Line -notmatch "pretty.errors" -and
    $_.Line -notmatch "Copied (replaced existing)" -and
    $_.Line -notmatch "INFO" -and
    $_.Line -notmatch "Downloaded " -and
    $_.Line -notmatch " Compiling "
}

if ($warnings -or $errors) {
    Write-DateLog "Errors or warnings were found in the logs. Please check them."
} else {
    Write-DateLog "Downloads and preparations done."
}
