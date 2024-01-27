# Script to install DFIRWS tools on demand

param (
    [switch]$ApiMonitor,
    [switch]$Autopsy,
    [switch]$BashExtra,
    [switch]$Choco,
    [switch]$CMDer,
    [switch]$GitBash,
    [switch]$GoLang,
    [switch]$Hashcat,
    [switch]$Jadx,
    [switch]$Kape,
    [switch]$LibreOffice,
    [switch]$Loki,
    [switch]$Neo4j,
    [switch]$Node,
    [switch]$Obsidian,
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

if ($Choco.IsPresent) {
    Install-Choco
}

if ($CMDer.IsPresent) {
    Install-CMDer
}

if ($GitBash.IsPresent) {
    Install-GitBash
}

if ($GoLang.IsPresent) {
    Install-GoLang
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

if ($Loki) {
    Install-Loki
}

if ($Neo4j) {
    Install-Neo4j
}

if ($Node) {
    Install-Node
}

if ($Obsidian) {
    Install-Obsidian
}

if ($PDFStreamDumper) {
    Install-PDFStreamDumper
}

if ($Qemu) {
    Install-Qemu
}

if ($Ruby) {
    Install-Ruby
}

if ($Rust) {
    Install-Rust
}

if ($VSCode) {
    Install-VSCode
}

if ($Wireshark) {
    Install-Wireshark
}

if ($X64dbg) {
    Install-X64dbg
}

if ($Zui) {
    Install-Zui
}
