# Script to switch between virtual environments

param(
    [Parameter(HelpMessage = "Switch to venv default.")]
    [Switch]$default,
    [Parameter(HelpMessage = "Switch to venv dfir-unfurl.")]
    [Switch]$unfurl,
    [Parameter(HelpMessage = "Switch to venv evt2sigma.")]
    [Switch]$evt2sigma,
    [Parameter(HelpMessage = "Switch to venv Kanvas.")]
    [Switch]$Kanvas,
    [Parameter(HelpMessage = "Switch to venv pe2pic.")]
    [Switch]$pe2pic,
    [Parameter(HelpMessage = "Switch to venv scare.")]
    [Switch]$scare,
    [Parameter(HelpMessage = "Switch to venv srum-dump.")]
    [Switch]$srumdump,
    [Parameter(HelpMessage = "Switch to venv white-phoenix.")]
    [Switch]$whitephoenix,
    [Parameter(HelpMessage = "Switch to venv zircolite.")]
    [Switch]$zircolite
)

$venv = "default"

if ( ${WSDFIR_OHMYPOSH} -eq "Yes" ) {
	${env:VIRTUAL_ENV_DISABLE_PROMPT}=$true
}

if ($aspose) {
    $venv = "aspose"
} elseif ($binaryrefinery) {
    $venv = "binary-refinery"
} elseif ($chepy) {
    $venv = "chepy"
} elseif ($csvkit) {
    $venv = "csvkit"
} elseif ($default) {
    $venv = "default"
} elseif ($unfurl) {
    $venv = "dfir-unfurl"
} elseif ($dissect) {
    $venv = "dissect"
} elseif ($evt2sigma) {
    $venv = "evt2sigma"
} elseif ($floss) {
    $venv = "flare-floss"
} elseif ($ghidrecomp) {
    $venv = "ghidrecomp"
} elseif ($jep) {
    $venv = "jep"
} elseif ($jpterm) {
    $venv = "jpterm"
} elseif ($litecli) {
    $venv = "litecli"
} elseif ($magika) {
    $venv = "magika"
} elseif ($maldump) {
    $venv = "maldump"
} elseif ($Kanvas) {
    $venv = "Kanvas"
} elseif ($pe2pic) {
    $venv = "pe2pic"
} elseif ($peepdf3) {
    $venv = "peepdf3"
} elseif ($regipy) {
    $venv = "regipy"
} elseif ($rexi) {
    $venv = "rexi"
} elseif ($scare) {
    $venv = "scare"
} elseif ($sigma) {
    $venv = "sigma-cli"
} elseif ($whitephoenix) {
    $venv = "white-phoenix"
} else {
    $venv = "default"
}

$ErrorActionPreference= "silentlycontinue"
deactivate

if (Test-Path "C:\venv\$venv\Scripts\Activate.ps1") {
    & "C:\venv\$venv\Scripts\Activate.ps1"
} elseif (Test-Path "C:\venv\uv\$venv\Scripts\Activate.ps1") {
    & "C:\venv\uv\$venv\Scripts\Activate.ps1"
} elseif (Test-Path "C:\venv\Kanvas\.venv\Scripts\Activate.ps1") {
    & "${env:ProgramFiles}\Kanvas\.venv\Scripts\Activate.ps1"
} else {
    Write-Output "ERROR: Activate.ps1 not found. Exiting"
    Exit
}
