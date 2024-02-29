# Script to install DFIRWS tools on demand

param (
    [switch]$ApiMonitor,
    [switch]$Autopsy,
    [switch]$BashExtra,
    [switch]$BinaryNinja,
    [switch]$Choco,
    [switch]$CMDer,
    [switch]$Docker,
    [switch]$Dokany,
    [switch]$GitBash,
    [switch]$GoLang,
    [switch]$Gpg4win,
    [switch]$Hashcat,
    [switch]$Jadx,
    [switch]$Kape,
    [switch]$LibreOffice,
    [switch]$Loki,
    [switch]$Neo4j,
    [switch]$Node,
    [switch]$Obsidian,
    [switch]$OhMyPosh,
    [switch]$PDFStreamDumper,
    [switch]$Qemu,
    [switch]$Ruby,
    [switch]$Rust,
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

if ($Choco.IsPresent) {
    Install-Choco
}

if ($CMDer.IsPresent) {
    Install-CMDer
}

if ($Docker.IsPresent) {
    Install-Docker
}

if ($Dokany.IsPresent) {
    Install-Dokany
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

if ($Qemu.IsPresent) {
    Install-Qemu
}

if ($Ruby.IsPresent) {
    Install-Ruby
}

if ($Rust.IsPresent) {
    Install-Rust
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
