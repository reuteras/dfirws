# Script to switch between virtual environments

param(
    [Parameter(HelpMessage = "Switch to venv aspose.")]
    [Switch]$aspose,
    [Parameter(HelpMessage = "Switch to venv binary-refinery.")]
    [Switch]$binaryrefinery,
    [Parameter(HelpMessage = "Switch to venv chepy.")]
    [Switch]$chepy,
    [Parameter(HelpMessage = "Switch to venv csvkit.")]
    [Switch]$csvkit,
    [Parameter(HelpMessage = "Switch to venv default.")]
    [Switch]$default,
    [Parameter(HelpMessage = "Switch to venv dfir-unfurl.")]
    [Switch]$unfurl,
    [Parameter(HelpMessage = "Switch to venv dissect.")]
    [Switch]$dissect,
    [Parameter(HelpMessage = "Switch to venv evt2sigma.")]
    [Switch]$evt2sigma,
    [Parameter(HelpMessage = "Switch to venv flare-floss.")]
    [Switch]$floss,
    [Parameter(HelpMessage = "Switch to venv ghidrecomp.")]
    [Switch]$ghidrecomp,
    [Parameter(HelpMessage = "Switch to venv jep.")]
    [Switch]$jep,
    [Parameter(HelpMessage = "Switch to venv jpterm.")]
    [Switch]$jpterm,
    [Parameter(HelpMessage = "Switch to venv litecli.")]
    [Switch]$litecli,
    [Parameter(HelpMessage = "Switch to venv magika.")]
    [Switch]$magika,
    [Parameter(HelpMessage = "Switch to venv maldump.")]
    [Switch]$maldump,
    [Parameter(HelpMessage = "Switch to venv mwcp.")]
    [Switch]$mwcp,
    [Parameter(HelpMessage = "Switch to venv pe2pic.")]
    [Switch]$pe2pic,
    [Parameter(HelpMessage = "Switch to venv peepdf3.")]
    [Switch]$peepdf3,
    [Parameter(HelpMessage = "Switch to venv regipy.")]
    [Switch]$regipy,
    [Parameter(HelpMessage = "Switch to venv rexi.")]
    [Switch]$rexi,
    [Parameter(HelpMessage = "Switch to venv scare.")]
    [Switch]$scare,
    [Parameter(HelpMessage = "Switch to venv sigma-cli.")]
    [Switch]$sigma,
    [Parameter(HelpMessage = "Switch to venv white-phoenix.")]
    [Switch]$whitephoenix
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
} elseif ($mwcp) {
    $venv = "mwcp"
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
} elseif (Test-Path "C:\venv\uv\$venv\bin\Activate.ps1") {
    & "C:\venv\uv\$venv\bin\Activate.ps1"
} else {
    Write-Output "ERROR: Activate.ps1 not found. Exiting"
    Exit
}
