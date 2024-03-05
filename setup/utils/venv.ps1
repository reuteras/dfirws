# Script to switch between virtual environments

param(
    [Parameter(HelpMessage = "Switch to venv aspose.")]
    [Switch]$aspose,
    [Parameter(HelpMessage = "Switch to venv binary-refinery.")]
    [Switch]$binaryrefinery,
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
    [Parameter(HelpMessage = "Switch to venv jpterm.")]
    [Switch]$jpterm,
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
    [Parameter(HelpMessage = "Switch to venv toolong.")]
    [Switch]$toolong,
    [Parameter(HelpMessage = "Switch to venv Zircolite.")]
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
} elseif ($jpterm) {
    $venv = "jpterm"
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
} elseif ($toolong) {
    $venv = "toolong"
} elseif ($zircolite) {
    $venv = "Zircolite"
} else {
    $venv = "default"
}

$ErrorActionPreference= "silentlycontinue"
deactivate

& "C:\venv\$venv\Scripts\Activate.ps1"
