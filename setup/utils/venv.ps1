# Script to switch between virtual environments

param(
    [Parameter(HelpMessage = "Switch to venv chepy.")]
    [Switch]$chepy,
    [Parameter(HelpMessage = "Switch to venv default.")]
    [Switch]$default,
    [Parameter(HelpMessage = "Switch to venv dfir-unfurl.")]
    [Switch]$unfurl,
    [Parameter(HelpMessage = "Switch to venv dissect.")]
    [Switch]$dissect,
    [Parameter(HelpMessage = "Switch to venv evt2sigma.")]
    [Switch]$evt2sigma,
    [Parameter(HelpMessage = "Switch to venv ghidrecomp.")]
    [Switch]$ghidrecomp,
    [Parameter(HelpMessage = "Switch to venv jep.")]
    [Switch]$jep,
    [Parameter(HelpMessage = "Switch to venv maldump.")]
    [Switch]$maldump,
    [Parameter(HelpMessage = "Switch to venv pe2pic.")]
    [Switch]$pe2pic,
    [Parameter(HelpMessage = "Switch to venv pySigma.")]
    [Switch]$pySigma,
    [Parameter(HelpMessage = "Switch to venv scare.")]
    [Switch]$scare,
    [Parameter(HelpMessage = "Switch to venv Zircolite.")]
    [Switch]$zircolite
)

$venv = "default"

if ($chepy) {
    $venv = "chepy"
} elseif ($default) {
    $venv = "default"
} elseif ($unfurl) {
    $venv = "dfir-unfurl"
} elseif ($dissect) {
    $venv = "dissect"
} elseif ($evt2sigma) {
    $venv = "evt2sigma"
} elseif ($ghidrecomp) {
    $venv = "ghidrecomp"
} elseif ($jep) {
    $venv = "jep"
} elseif ($maldump) {
    $venv = "maldump"
} elseif ($pe2pic) {
    $venv = "pe2pic"
} elseif ($pySigma) {
    $venv = "pySigma"
} elseif ($scare) {
    $venv = "scare"
} elseif ($zircolite) {
    $venv = "Zircolite"
} else {
    $venv = "default"
}

$ErrorActionPreference= "silentlycontinue"
deactivate

& "C:\venv\$venv\Scripts\Activate.ps1"
