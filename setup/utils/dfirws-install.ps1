# Import common functions
. $HOME\Documents\tools\wscommon.ps1

if ($args.Count -eq 0) {
    Write-Output "Need at least one argument. Available tools are: "
    Write-Output "   --apimonitor"
    Write-Output "   --autopsy"
    Write-Output "   --bashextra"
    Write-Output "   --choco" 
    Write-Output "   --cmder"
    Write-Output "   --gitbash"
    Write-Output "   --golang"
    Write-Output "   --libreoffice"
    Write-Output "   --neo4j"
    Write-Output "   --node"
    Write-Output "   --pdfstreamdumper"
    Write-Output "   --ruby"
    Write-Output "   --vscode"
    Write-Output "   --x64dbg"
    Write-Output "   --zui"
    exit
}

if ($args -contains "--apimonitor") {
    Install-Apimonitor
}

if ($args -contains "--autopsy") {
    Install-Autopsy
}

if ($args -contains "--bashextra") {
    Install-BashExtra
}

if ($args -contains "--choco") {
    Install-Choco
}

if ($args -contains "--cmder") {
    Install-CMDer
}

if ($args -contains "--gitbash") {
    Install-GitBash
}

if ($args -contains "--golang") {
    Install-GoLang
}

if ($args -contains "--libreoffice") {
    Install-LibreOffice
}

if ($args -contains "--neo4j") {
    Install-Neo4j
}

if ($args -contains "--node") {
    Install-Node
}

if ($args -contains "--pdfstreamdumper") {
    Install-PDFStreamDumper
}

if ($args -contains "--ruby") {
    Install-Ruby
}

if ($args -contains "--vscode") {
    Install-VSCode
}

if ($args -contains "--x64dbg") {
    Install-X64dbg
}

if ($args -contains "--zui") {
    Install-Zui
}
