<#

.SYNOPSIS
    Download files and prepare the sandbox.

.DESCRIPTION
    This script downloads files and prepares the sandbox for DFIRWS.

.EXAMPLE
    .\downloadFiles.ps1
    This will download all files needed for DFIRWS.

.EXAMPLE
    .\downloadFiles.ps1 -AllTools -Enrichment
    This will download all files needed for DFIRWS and update enrichments.

.EXAMPLE
    .\downloadFiles.ps1 -Python
    This will download and update packages for Python but no other files.

.EXAMPLE
    .\downloadFiles.ps1 -Freshclam
    This will download and update ClamAV databases with Freshclam.

.EXAMPLE
    .\downloadFiles.ps1 -AllTools -Enrichment -Freshclam
    This will download all files needed for DFIRWS, update enrichments and ClamAV databases with Freshclam.

.EXAMPLE
    .\downloadFiles.ps1 -Profile Basic
    Download a basic distribution without large optional tools and without Rust, Go, and MSYS2 toolchains.

.EXAMPLE
    .\downloadFiles.ps1 -Profile Full
    Download all tools (same as default behavior).

.NOTES
    File Name      : downloadFiles.ps1
    Author         : Peter R

.LINK
    https://github.com/reuteras/dfirws
#>

param(
    [Parameter(HelpMessage = "Select distribution profile (Basic or Full).")]
    [ValidateSet("Basic", "Full")]
    [string]$Profile = "",
    [Parameter(HelpMessage = "Download all tools for dfirws.")]
    [Switch]$AllTools,
    [Parameter(HelpMessage = "Update Didier Stevens tools.")]
    [Switch]$Didier,
    [Parameter(HelpMessage = "Debug downloads.")]
    [Switch]$DebugDownloads,
    [Parameter(HelpMessage = "Update enrichment.")]
    [Switch]$Enrichment,
    [Parameter(HelpMessage = "Update ClamAV databases with Freshclam.")]
    [Switch]$Freshclam,
    [Parameter(HelpMessage = "Update git repositories.")]
    [Switch]$Git,
    [Parameter(HelpMessage = "Update GoLang.")]
    [Switch]$GoLang,
    [Parameter(HelpMessage = "Update files downloaded via HTTP.")]
    [Switch]$Http,
    [Parameter(HelpMessage = "Don't update Visual Studio Code Extensions via http.")]
    [Switch]$HttpNoVSCodeExtensions,
    [Parameter(HelpMessage = "Update KAPE.")]
    [Switch]$Kape,
    [Parameter(HelpMessage = "Update Threat Intel for LogBoost.")]
    [Switch]$LogBoost,
    [Parameter(HelpMessage = "Update MSYS2.")]
    [Switch]$MSYS2,
    [Parameter(HelpMessage = "Update Node.")]
    [Switch]$Node,
    [Parameter(HelpMessage = "Update PowerShell and modules.")]
    [Switch]$PowerShell,
    [Parameter(HelpMessage = "Update Python.")]
    [Switch]$Python,
    [Parameter(HelpMessage = "Update releases from GitHub.")]
    [Switch]$Release,
    [Parameter(HelpMessage = "Update Rust.")]
    [Switch]$Rust,
    [Parameter(HelpMessage = "Update tools downloaded via winget.")]
    [Switch]$Winget,
    [Parameter(HelpMessage = "Verify that tools are available.")]
    [Switch]$Verify,
    [Parameter(HelpMessage = "Install and Update Visual Studio buildtools.")]
    [Switch]$VisualStudioBuildTools,
    [Parameter(HelpMessage = "Update Zimmerman tools.")]
    [Switch]$Zimmerman
    )

if (Test-Path ".\resources\download\common.ps1") {
    . ".\resources\download\common.ps1"
} else {
    Write-DateLog "Error: common.ps1 not found. Please check your installation."
    Exit
}

if (Test-Path ".\config.ps1") {
    . ".\config.ps1"
} elseif (Test-Path ".\config.ps1.template") {
    . ".\config.ps1.template"
} else {
    Write-DateLog "Error: Neither config.ps1 nor config.ps1.template found. Please check your installation."
    Exit
}

# Load profile definitions
if (Test-Path ".\local\defaults\profiles.ps1") {
    . ".\local\defaults\profiles.ps1"
}

# Load user profile config
if (Test-Path ".\local\profile-config.ps1") {
    . ".\local\profile-config.ps1"
}

# Resolve active profile: CLI parameter > config file > none (Full)
if ($Profile -ne "") {
    $activeProfileName = $Profile
} elseif ((Test-Path variable:DFIRWS_PROFILE) -and $DFIRWS_PROFILE -ne "") {
    $activeProfileName = $DFIRWS_PROFILE
} else {
    $activeProfileName = ""
}

# Build effective configuration from profile
if ($activeProfileName -ne "" -and (Test-Path variable:DFIRWS_PROFILES) -and $DFIRWS_PROFILES.ContainsKey($activeProfileName)) {
    Write-DateLog "Using profile: $activeProfileName"
    $activeProfile = $DFIRWS_PROFILES[$activeProfileName]

    # Script toggles (with per-script overrides from user config)
    $profileNodeEnabled = $activeProfile.Scripts["node"]
    $profileRustEnabled = $activeProfile.Scripts["rust"]
    $profileGoEnabled   = $activeProfile.Scripts["go"]
    $profileMsys2Enabled = $activeProfile.Scripts["msys2"]

    if (Test-Path variable:DFIRWS_PROFILE_NODE)  { $profileNodeEnabled  = $DFIRWS_PROFILE_NODE }
    if (Test-Path variable:DFIRWS_PROFILE_RUST)  { $profileRustEnabled  = $DFIRWS_PROFILE_RUST }
    if (Test-Path variable:DFIRWS_PROFILE_GO)    { $profileGoEnabled    = $DFIRWS_PROFILE_GO }
    if (Test-Path variable:DFIRWS_PROFILE_MSYS2) { $profileMsys2Enabled = $DFIRWS_PROFILE_MSYS2 }

    # Resolve extras include list
    $DFIRWS_EXTRAS_RESOLVED = @()
    if ((Test-Path variable:DFIRWS_EXTRAS) -and $null -ne $DFIRWS_EXTRAS) {
        $DFIRWS_EXTRAS_RESOLVED = $DFIRWS_EXTRAS
    }

    # Build effective exclude list (extras override exclusions)
    $DFIRWS_EXCLUDE_TOOLS = [System.Collections.Generic.List[string]]::new()
    foreach ($tool in $activeProfile.ExcludeTools) {
        if ($DFIRWS_EXTRAS_RESOLVED -notcontains $tool) {
            $DFIRWS_EXCLUDE_TOOLS.Add($tool)
        }
    }

    if ($DFIRWS_EXCLUDE_TOOLS.Count -gt 0) {
        Write-DateLog "Profile excludes: $($DFIRWS_EXCLUDE_TOOLS -join ', ')"
    }
    if ($DFIRWS_EXTRAS_RESOLVED.Count -gt 0) {
        Write-DateLog "Extras included: $($DFIRWS_EXTRAS_RESOLVED -join ', ')"
    }

    # Build git repo exclude list
    $DFIRWS_EXCLUDE_GIT_REPOS = @()
    if ($null -ne $activeProfile.ExcludeGitRepos) {
        $DFIRWS_EXCLUDE_GIT_REPOS = $activeProfile.ExcludeGitRepos
    }
} else {
    # No profile = Full behavior (everything included)
    $profileNodeEnabled  = $true
    $profileRustEnabled  = $true
    $profileGoEnabled    = $true
    $profileMsys2Enabled = $true
    $DFIRWS_EXCLUDE_TOOLS = @()
    $DFIRWS_EXTRAS_RESOLVED = @()
    $DFIRWS_EXCLUDE_GIT_REPOS = @()
}

$ProgressPreference = "SilentlyContinue"

# Ensure that we have the necessary tools installed
if (! (Get-Command "git.exe" -ErrorAction SilentlyContinue)) {
    Write-DateLog "Error: git.exe not found. Please install Git for Windows and add it to PATH."
    Exit
}

if (! (Get-Command "rclone.exe" -ErrorAction SilentlyContinue)) {
    Write-DateLog "Error: rclone.exe not found. Please install rclone and add it to PATH."
    Exit
}

if (! (Get-Command "7z.exe" -ErrorAction SilentlyContinue)) {
    Write-DateLog "Error: 7z.exe not found. Please install 7-Zip and add it to PATH."
    Exit
}

# Ensure configuration exists for rclone
rclone.exe config touch | Out-Null

# Check if sandbox is running
if ( tasklist | Select-String "(WindowsSandboxClient|WindowsSandboxRemote)" ) {
    Write-DateLog "Sandbox can't be running while updating."
    Exit
}

if ($AllTools.IsPresent) {
    Write-DateLog "Download all tools for dfirws."
    $all = $true
} elseif ($Didier.IsPresent -or $Enrichment.IsPresent -or $Freshclam.IsPresent -or $Git.IsPresent -or $GoLang.IsPresent -or $Http.IsPresent -or $Kape.IsPresent -or $LogBoost.IsPresent -or $MSYS2.IsPresent -or $Node.IsPresent -or $PowerShell.IsPresent -or $Python.IsPresent -or $Release.IsPresent -or $Rust.IsPresent -or $Winget.IsPresent -or $Verify.IsPresent -or $VisualStudioBuildTools.IsPresent -or $Zimmerman.IsPresent) {
    $all = $false
} elseif ($Profile -ne "") {
    Write-DateLog "Download tools for dfirws using profile: $Profile"
    $all = $true
} else {
    Write-DateLog "No arguments given. Will download all tools for dfirws."
    $all = $true
}

if ($all -eq $false) {
    if (! (Test-Path "${TOOLS}\bin" )) {
        Write-DateLog "No tools directory found. You have to run this script without arguments first."
        Exit
    }
}

# Create directories
if (!(Test-Path "${SETUP_PATH}")) {
    New-Item -ItemType Directory -Force -Path "${SETUP_PATH}" 2>&1 | Out-Null
}

if (!(Test-Path "${SETUP_PATH}\dfirws")) {
    New-Item -ItemType Directory -Force -Path "${SETUP_PATH}\dfirws" 2>&1 | Out-Null
}

if (!(Test-Path "${SETUP_PATH}\.etag")) {
    New-Item -ItemType Directory -Force -Path "${SETUP_PATH}\.etag" 2>&1 | Out-Null
}

if (!(Test-Path "${TOOLS}")) {
    New-Item -ItemType Directory -Force -Path "${TOOLS}" 2>&1 | Out-Null
}

if (!(Test-Path "${TOOLS}\bin")) {
    New-Item -ItemType Directory -Force -Path "${TOOLS}\bin" 2>&1 | Out-Null
}

# Write profile exclude list for sandbox scripts to read
$profileContent = @"
# Auto-generated by downloadFiles.ps1 - do not edit
`$DFIRWS_EXCLUDE_TOOLS = @($( ($DFIRWS_EXCLUDE_TOOLS | ForEach-Object { "`"$_`"" }) -join ", " ))
"@
$profileContent | Set-Content "${TOOLS}\dfirws-profile.ps1" -Encoding UTF8

if (!(Test-Path "${TOOLS}\lib")) {
    New-Item -ItemType Directory -Force -Path "${TOOLS}\lib" 2>&1 | Out-Null
}

if (!(Test-Path "${TOOLS}\Zimmerman")) {
    New-Item -ItemType Directory -Force -Path "${TOOLS}\Zimmerman" 2>&1 | Out-Null
}

if (Test-Path "${TOOLS}\Debug") {
    Remove-Item -Recurse -Force "${TOOLS}\Debug" 2>&1 | Out-Null
}

if (! (Test-Path -Path ".\log" )) {
    New-Item -ItemType Directory -Force -Path ".\log" > $null
}
Get-Date > ".\log\log.txt"
Get-Date > ".\log\logboost.txt"
Get-Date > ".\log\jobs.txt"
Get-Date > ".\log\verify.txt"

if ($DebugDownloads.IsPresent) {
    Write-DateLog "Debug mode enabled."
    New-Item -ItemType Directory -Force -Path "${TOOLS}\Debug" 2>&1 | Out-Null
}

if ($all -or $Didier.IsPresent -or $GoLang.IsPresent -or $Http.IsPresent -or $Python.IsPresent -or $Release.IsPresent) {
    # Get GitHub password from user input
    if ($GITHUB_USERNAME -ne "YOUR GITHUB USERNAME" -and $GITHUB_TOKEN -ne "YOUR GITHUB TOKEN") {
        $GH_USER = "${GITHUB_USERNAME}"
        $GH_PASS = "${GITHUB_TOKEN}"
    } else {
        Write-DateLog "Use GitHub username and token to avoid problems with rate limits on GitHub."
        $GH_USER = Read-Host "Enter GitHub user name"
        $PASS = Read-Host "Enter GitHub token" -AsSecureString
        $GH_PASS =[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PASS))
        $null = $GH_PASS
        $null = $GH_USER
    }
    if (("" -eq $GH_USER) -or ("" -eq $GH_PASS)) {
        Write-DateLog "Error: No GitHub username or token given. Can't continue."
        Exit
    }
}

if ($all -or $Freshclam.IsPresent -or $GoLang.IsPresent -or $LogBoost.IsPresent -or $MSYS2.IsPresent -or $Node.IsPresent -or $Python.IsPresent -or $Ruby.IsPresent -or $Rust.IsPresent) {
    Write-DateLog "Download common files needed in Sandboxes for installation."
    .\resources\download\basic.ps1
}

if ($VisualStudioBuildTools.IsPresent) {
    Write-DateLog "Download or update Visual Studio buildtools."
    .\resources\download\visualstudiobuildtools.ps1 | Out-Null
}

if ($all -or $Release.IsPresent) {
    Write-DateLog "Download releases from GitHub."
    .\resources\download\release.ps1
}

if ($all -or $Http.IsPresent) {
    Write-DateLog "Download files via HTTP."
    if ($HttpNoVSCodeExtensions) {
        .\resources\download\http.ps1 -NoVSCodeExtensions
    } else {
        .\resources\download\http.ps1
    }
}

if (($all -and $profileNodeEnabled) -or $Node.IsPresent) {
    Write-Output "" > .\log\node.txt
    Write-DateLog "Setup Node and install npm packages."
    .\resources\download\node.ps1 | Out-Null
}

if ($all -or $Git.IsPresent) {
    Write-DateLog "Download and update git repositories"
    .\resources\download\git.ps1
}

if (($all -and $profileMsys2Enabled) -or $MSYS2.IsPresent) {
    Write-DateLog "Download MSYS2."
    .\resources\download\msys2.ps1 | Out-Null
}

if (($all -and $profileGoEnabled) -or $GoLang.IsPresent) {
    Write-Output "" > .\log\golang.txt
    Write-DateLog "Setup GoLang and install packages."
    .\resources\download\go.ps1 | Out-Null
}

if ($all -or $Python.IsPresent) {
    Write-Output "" > .\log\python.txt
    Write-DateLog "Setup Python and install packages in virtual environments."
    .\resources\download\python.ps1 | Out-Null
}

if (($all -and $profileRustEnabled) -or $Rust.IsPresent) {
    Write-Output "" > .\log\rust.txt
    Write-DateLog "Setup Rust and install packages with cargo."
    .\resources\download\rust.ps1 | Out-Null
}

if ($all -or $Didier.IsPresent) {
    Write-DateLog "Download Didier Stevens tools."
    .\resources\download\didier.ps1
}

if ($all -or $Winget.IsPresent) {
    Write-DateLog "Download tools via winget."
    .\resources\download\winget.ps1
}

if ($all -or $Zimmerman.IsPresent) {
    Write-DateLog "Download Zimmerman tools."
    .\resources\download\zimmerman.ps1
}

if ($all -or $Kape.IsPresent) {
    if (Test-Path ".\local\kape.zip") {
        Write-DateLog "Download and update KAPE and related tools."
        .\resources\download\kape.ps1
    }
}

if ($all -or $PowerShell.IsPresent) {
    Write-DateLog "Download PowerShell and modules."
    .\resources\download\powershell.ps1
}

if ($Freshclam.IsPresent) {
    Write-DateLog "Download and update ClamAV databases with freshclam."
    .\resources\download\freshclam.ps1 | Out-Null
}

if ($Enrichment.IsPresent) {
    Write-DateLog "Download enrichment data."
    .\resources\download\enrichment.ps1
}

if ($all -or $LogBoost.IsPresent) {
    if ($null -eq $DFIRWS_EXCLUDE_TOOLS -or $DFIRWS_EXCLUDE_TOOLS -notcontains "LogBoost") {
        Write-DateLog "Update Threat Intel for LogBoost."
        .\resources\download\logboost.ps1 | Out-Null
    } else {
        Write-DateLog "Skipping LogBoost TI update (excluded by profile)."
    }
}

Copy-Item "README.md" ".\downloads\" -Force | Out-Null
Copy-Item ".\resources\images\dfirws.jpg" .\downloads\ -Force | Out-Null
Copy-Item ".\setup\utils\PowerSiem.ps1" ".\mount\Tools\bin\" -Force | Out-Null

if (Test-Path ".\mount\Tools\Ghidra\") {
    foreach ($directory in (Get-ChildItem ".\mount\Tools\Ghidra\" -Directory).Name | findstr PUBLIC) {
        if (Test-Path ".\mount\Tools\Ghidra\${directory}\Ghidra\Features\Python\") {
            Copy-Item ".\mount\git\CapaExplorer\capaexplorer.py" ".\mount\Tools\Ghidra\${directory}\Ghidra\Features\Python\ghidra_scripts" -Force
        } elseif (Test-Path ".\mount\Tools\Ghidra\${directory}\Ghidra\Features\Jython\") {
            Copy-Item ".\mount\git\CapaExplorer\capaexplorer.py" ".\mount\Tools\Ghidra\${directory}\Ghidra\Features\Jython\ghidra_scripts" -Force
        }
    }
}

# done.txt is used to display last update in sandbox with bginfo
Write-Output "" > ".\downloads\done.txt"

# Remove temp files
if (Test-Path ".\tmp\downloads") {
    Remove-Item -Recurse -Force .\tmp\downloads\ 2>&1 | Out-Null
}
if (Test-Path ".\tmp\enrichment") {
    Remove-Item -Recurse -Force .\tmp\enrichment 2>&1 | Out-Null
}
if (Test-Path ".\tmp\mount") {
    Remove-Item -Recurse -Force .\tmp\mount\ 2>&1 | Out-Null
}
if (Test-Path ".\tmp\msys2") {
    Remove-Item -Recurse -Force .\tmp\msys2\ 2>&1 | Out-Null
}

if (!(Test-Path ".\mount\golang")){
    New-Item -ItemType Directory -Force -Path ".\mount\golang" 2>&1 | Out-Null
}

# Verify that tools are available
if ($Verify.IsPresent) {
    Write-DateLog "Verify that tools are available."
    .\resources\download\verify.ps1 -WorkingDirectory $PWD\resources\download | Out-Null
    Write-DateLog "Verify done."
}

# Check for errors and warnings in log files
$warnings = Get-ChildItem .\log\* -Recurse | Select-String -Pattern "warning" | Where-Object {
    $_.Line -notmatch " INFO " -and
    $_.Line -notmatch "This is taking longer than usual" -and
    $_.Line -notmatch "Installing collected packages" -and
    $_.Line -notmatch "pymispwarninglists" -and
    $_.Line -notmatch "warning: be sure to add" -and
    $_.Line -notmatch "create mode " -and
    $_.Line -notmatch "delete mode " -and
    $_.Line -notmatch "rename " -and
    $_.Line -notmatch "reinstalling" -and
    $_.Line -notmatch "origin/main Updating" -and
    $_.Line -notmatch "new branch" -and
    $_.Line -notmatch "warnings.py" -and
    $_.Line -notmatch "core_perl" -and
    $_.Line -notmatch "unused import" -and
    $_.Line -notmatch "unused variable" -and
    $_.Line -notmatch "is never used" -and
    $_.Line -notmatch "is never constructed" -and
    $_.Line -notmatch "elided elsewhere is confusing" -and
    $_.Line -notmatch "generated [0-9]+ warnings" -and
    $_.Line -notmatch "EVTX-ATTACK-SAMPLES"
}

$errors = Get-ChildItem .\log\* -Recurse | Select-String -Pattern "error" | Where-Object {
    $_.Line -notmatch "Error: no test specified" -and
    $_.Line -notmatch "pretty.errors" -and
    $_.Line -notmatch "Copied (replaced existing)" -and
    $_.Line -notmatch "INFO" -and
    $_.Line -notmatch "perl-Error" -and
    $_.Line -notmatch "Downloaded " -and
    $_.Line -notmatch "/cffi/error.py" -and
    $_.Line -notmatch "github/workflows" -and
    $_.Line -notmatch " Compiling " -and
    $_.Line -notmatch "create mode " -and
    $_.Line -notmatch "delete mode " -and
    $_.Line -notmatch "rename " -and
    $_.Line -notmatch "new branch" -and
    $_.Line -notmatch "origin/main Updating" -and
    $_.Line -notmatch "libgpg-error" -and
    $_.Line -notmatch "could not be locally" -and
    $_.Line -notmatch "via WKD" -and
    $_.Line -notmatch "ERROR: 9DD0D4217D75" -and
    $_.Line -notmatch "msys64\\usr\\" -and
    $_.Line -notmatch "gpg-error.exe" -and
    $_.Line -notmatch "gpg: error reading key: Network error" -and
    $_.Line -notmatch "gpg: error reading key: No data" -and
    $_.Line -notmatch "gpg: error reading key: general error" -and
    $_.Line -notmatch "ERROR: Could not update key:" -and
    $_.Line -notmatch "Error Getting File from" -and
    $_.Line -notmatch "Adding thiserror" -and
    $_.Line -notmatch "gpg-error" -and
    $_.Line -notmatch "gpg: error reading key: Try again later" -and
    $_.Line -notmatch "EVTX-ATTACK-SAMPLES"
}

$failed = Get-ChildItem .\log\* -Recurse | Select-String -Pattern "Failed" | Where-Object {
    $_.Line -notmatch "A connection attempt failed because the connected party did not" -and
    $_.Line -notmatch "ucrt64/share" -and
    $_.Line -notmatch "origin/main Updating" -and
    $_.Line -notmatch "origin/master Updating" -and
    $_.Line -notmatch "EVTX-ATTACK-SAMPLES"
}

if ($warnings -or $errors -or $failed) {
    Write-DateLog "Errors or warnings were found in log files. Please check the log files for details."
} else {
    Write-DateLog "Downloads and preparations done."
}
