# Script to install DFIRWS tools on demand

param (
    [switch]$ApiMonitor,
    [switch]$Autopsy,
    [switch]$BinaryNinja,
    [switch]$BurpSuite,
    [switch]$Chrome,
    [switch]$ClamAV,
    [switch]$CMDer,
    [switch]$Dbeaver,
    [switch]$DCode,
    [switch]$Docker,
    [switch]$Dokany,
    [switch]$Fibratus,
    [switch]$Firefox,
    [switch]$FoxitReader,
    [switch]$FQLite,
    [switch]$Git,
    [switch]$GoogleEarth,
    [switch]$GoLang,
    [switch]$Gpg4win,
    [switch]$Hashcat,
    [switch]$Jadx,
    [switch]$Kape,
    [switch]$LibreOffice,
    [switch]$LogBoost,
    [switch]$Loki,
    [switch]$Maltego,
    [switch]$Neo4j,
    [switch]$Node,
    [switch]$Obsidian,
    [switch]$OhMyPosh,
    [switch]$OSFMount,
    [switch]$PDFStreamDumper,
    [switch]$PuTTY,
    [switch]$Qemu,
    [switch]$Ruby,
    [switch]$Rust,
    [switch]$Tor,
    [switch]$Veracrypt,
    [switch]$VisualStudioBuildTools,
    [switch]$VLC,
    [switch]$VSCode,
    [switch]$WinMerge,
    [switch]$Wireshark,
    [switch]$X64Dbg,
    [switch]$ZAProxy,
    [switch]$Zui
)

# Import common functions
. $HOME\Documents\tools\wscommon.ps1

if ($ApiMonitor.IsPresent) {
    Install-Apimonitor
}

if ($Autopsy.IsPresent) {
    Install-Autopsy
}

if ($BinaryNinja.IsPresent) {
    Install-BinaryNinja
}

if ($BurpSuite.IsPresent) {
    Install-BurpSuite
}

if ($Chrome.IsPresent) {
    Install-Chrome
}

if ($ClamAV.IsPresent) {
    Install-ClamAV
}

if ($CMDer.IsPresent) {
    Install-CMDer
}

if ($Dbeaver.IsPresent) {
    Install-Dbeaver
}

if ($DCode.IsPresent) {
    Install-DCode
}

if ($Docker.IsPresent) {
    Install-Docker
}

if ($Dokany.IsPresent) {
    Install-Dokany
}

if ($Fibratus.IsPresent) {
    Install-Fibratus
}

if ($Firefox.IsPresent) {
    Install-Firefox
}

if ($FoxitReader.IsPresent) {
    Install-FoxitReader
}

if ($FQLite.IsPresent) {
    Install-FQLite
}

if ($Git.IsPresent) {
    Install-Git
}

if ($GoLang.IsPresent) {
    Install-GoLang
}

if ($GoogleEarth.IsPresent) {
    Install-GoogleEarth
}

if ($Gpg4win.IsPresent) {
    Install-Gpg4win
}

if ($Hashcat.IsPresent) {
    Install-Hashcat
}

if ($Jadx.IsPresent) {
    Install-Jadx
}

if ($Kape.IsPresent) {
    Install-Kape
}

if ($LibreOffice.IsPresent) {
    Install-LibreOffice
}

if ($LogBoost.IsPresent) {
    Install-LogBoost
}

if ($Loki.IsPresent) {
    Install-Loki
}

if ($Maltego.IsPresent) {
    Install-Maltego
}

if ($Neo4j.IsPresent) {
    Install-Neo4j
}

if ($Node.IsPresent) {
    Install-Node
}

if ($Obsidian.IsPresent) {
    Install-Obsidian
}

if ($OhMyPosh.IsPresent) {
    Install-OhMyPosh
}

if ($OSFMount.IsPresent) {
    Install-OSFMount
}

if ($PDFStreamDumper.IsPresent) {
    Install-PDFStreamDumper
}

if ($PuTTY.IsPresent) {
    Install-PuTTY
}

if ($Qemu.IsPresent) {
    Install-Qemu
}

if ($Ruby.IsPresent) {
    Install-Ruby
}

if ($Rust.IsPresent) {
    Install-Rust
}

if ($Tor.IsPresent) {
    Install-Tor
}

if ($Veracrypt.IsPresent) {
    Install-Veracrypt
}

if ($VisualStudioBuildTools.IsPresent) {
    Install-VisualStudioBuildTools
}

if ($VLC.IsPresent) {
    Install-VLC
}

if ($VSCode.IsPresent) {
    Install-VSCode
}

if ($WinMerge.IsPresent) {
    Install-WinMerge
}

if ($Wireshark.IsPresent) {
    Install-Wireshark
}

if ($X64dbg.IsPresent) {
    Install-X64dbg
}

if ($ZAProxy.IsPresent) {
    Install-ZAProxy
}

if ($Zui.IsPresent) {
    Install-Zui
}
