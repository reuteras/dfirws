# Script to switch between virtual environments

param(
    [Parameter(HelpMessage = "Switch to venv default.")]
    [Switch]$default,
    [Parameter(HelpMessage = "Switch to venv dfir-unfurl.")]
    [Switch]$unfurl,
    [Parameter(HelpMessage = "Switch to venv evt2sigma.")]
    [Switch]$evt2sigma,
    [Parameter(HelpMessage = "Switch to venv gostringungarbler.")]
    [Switch]$gostringungarbler,
    [Parameter(HelpMessage = "Switch to venv Kanvas.")]
    [Switch]$Kanvas,
    [Parameter(HelpMessage = "Switch to venv pe2pic.")]
    [Switch]$pe2pic,
    [Parameter(HelpMessage = "Switch to venv scare.")]
    [Switch]$scare,
    [Parameter(HelpMessage = "Switch to venv white-phoenix.")]
    [Switch]$whitephoenix,
    [Parameter(HelpMessage = "Switch to venv zircolite.")]
    [Switch]$zircolite
)

$venv = "default"

if ( ${WSDFIR_OHMYPOSH} -eq "Yes" ) {
	${env:VIRTUAL_ENV_DISABLE_PROMPT}=$true
}

if ($default) {
    $venv = "default"
} elseif ($unfurl) {
    $venv = "dfir-unfurl"
} elseif ($gostringungarbler) {
    $venv = "gostringungarbler"
    & "C:\venv\gostringungarbler\.venv\Scripts\Activate.ps1"
    Exit
} elseif ($Kanvas) {
    $venv = "Kanvas"
    & "${env:ProgramFiles}\Kanvas\.venv\Scripts\Activate.ps1"
    Exit
} elseif ($pe2pic) {
    $venv = "pe2pic"
} elseif ($scare) {
    $venv = "scare"
} elseif ($whitephoenix) {
    $venv = "white-phoenix"
} elseif ($zircolite) {
    $venv = "zircolite"
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
