# Import common functions
. $HOME\Documents\tools\wscommon.ps1

if ($args.Count -eq 0) {
    Write-Host "Need at least one argument. Available tools are: "
    Write-Host "   --apimonitor"
    Write-Host "   --autopsy"
    Write-Host "   --bashextra"
    Write-Host "   --choco" 
    Write-Host "   --cmder"
    Write-Host "   --gitbash"
    Write-Host "   --golang"
    Write-Host "   --libreoffice"
    Write-Host "   --neo4j"
    Write-Host "   --node"
    Write-Host "   --pdfstreamdumper"
    Write-Host "   --ruby"
    Write-Host "   --vscode"
    Write-Host "   --x64dbg"
    Write-Host "   --zui"
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
