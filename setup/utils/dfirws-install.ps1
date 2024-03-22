# Script to install DFIRWS tools on demand

param (
    [switch]$ApiMonitor,
    [switch]$Autopsy,
    [switch]$BashExtra,
    [switch]$BinaryNinja,
    [switch]$Chrome,
    [switch]$ClamAV,
    [switch]$CMDer,
    [switch]$DCode,
    [switch]$Docker,
    [switch]$Dokany,
    [switch]$Firefox,
    [switch]$FoxitReader,
    [switch]$GitBash,
    [switch]$GoLang,
    [switch]$Gpg4win,
    [switch]$Hashcat,
    [switch]$Jadx,
    [switch]$Kape,
    [switch]$LibreOffice,
    [switch]$Loki,
    [switch]$Maltego,
    [switch]$Neo4j,
    [switch]$Node,
    [switch]$Obsidian,
    [switch]$OhMyPosh,
    [switch]$PDFStreamDumper,
    [switch]$PuTTY,
    [switch]$Qemu,
    [switch]$Ruby,
    [switch]$Rust,
    [switch]$Tor,
    [switch]$Veracrypt,
    [switch]$VSCode,
    [switch]$Wireshark,
    [switch]$X64Dbg,
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

if ($BashExtra.IsPresent) {
    Install-BashExtra
}

if ($BinaryNinja.IsPresent) {
    Install-BinaryNinja
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

if ($DCode.IsPresent) {
    Install-DCode
}

if ($Docker.IsPresent) {
    Install-Docker
}

if ($Dokany.IsPresent) {
    Install-Dokany
}

if ($Firefox.IsPresent) {
    Install-Firefox
}

if ($FoxitReader.IsPresent) {
    Install-FoxitReader
}

if ($GitBash.IsPresent) {
    Install-GitBash
}

if ($GoLang.IsPresent) {
    Install-GoLang
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

if ($VSCode.IsPresent) {
    Install-VSCode
}

if ($Wireshark.IsPresent) {
    Install-Wireshark
}

if ($X64dbg.IsPresent) {
    Install-X64dbg
}

if ($Zui.IsPresent) {
    Install-Zui
}
