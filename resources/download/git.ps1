. $PSScriptRoot\common.ps1

if (! (Get-Command git )) {
    Write-DateLog "Need git to checkout git repositories."
    Exit
}

New-Item -ItemType Directory -Force -Path mount\git > $null
Set-Location mount\git
if (! (Test-Path .\PatchaPalooza )) {
    # Remove PatchaPalooza directory if it exists since we do a local patch
    Remove-Item -Recurse -Force .\PatchaPalooza > $null 2>&1
}

$repourls = `
    "https://github.com/crypto2011/IDR.git", `
    "https://github.com/cyberark/White-Phoenix.git", `
    "https://github.com/gehaxelt/Python-dsstore.git", `
    "https://github.com/JavierYuste/radare2-deep-graph.git", `
    "https://github.com/joeavanzato/Trawler.git", `
    "https://github.com/keydet89/Events-Ripper.git", `
    "https://github.com/keydet89/RegRipper3.0", `
    "https://github.com/last-byte/PersistenceSniper.git", `
    "https://github.com/last-byte/PersistenceSniper.wiki.git", `
    "https://github.com/MacDue/ssdeep-windows-32_64.git", `
    "https://github.com/Malandrone/PowerDecode.git", `
    "https://github.com/mari-mari/CapaExplorer.git", `
    "https://github.com/MarkBaggett/ese-analyst.git", `
    "https://github.com/netspooky/scare.git", `
    "https://github.com/ninewayhandshake/capa-explorer.git", `
    "https://github.com/pan-unit42/dotnetfile.git", `
    "https://github.com/reuteras/dfirws.wiki.git", `
    "https://github.com/rizinorg/cutter-jupyter.git", `
    "https://github.com/SigmaHQ/sigma.git", `
    "https://github.com/volexity/one-extract.git", `
    "https://github.com/volexity/threat-intel.git", `
    "https://github.com/wagga40/Zircolite.git", `
    "https://github.com/xaitax/PatchaPalooza.git", `
    "https://github.com/Yamato-Security/hayabusa-rules.git", `
    "https://github.com/yossizap/cutterref.git"

foreach ($repourl in $repourls) {
    $repo = Write-Output $repourl | ForEach-Object { $_ -replace "^.*/" } | ForEach-Object { $_ -replace "\.git$" }
    if ( Test-Path -Path $repo ) {
        Set-Location $repo
        $result = git pull 2>&1
        Write-SynchronizedLog "$result"
        Set-Location ..
    } else {
        $result = git clone $repourl 2>&1
        Write-SynchronizedLog "$result"
    }
}

# Patch PatchaPalooza
Set-Location PatchaPalooza
(Get-Content .\PatchaPalooza.py -Raw) -replace "import termcolor","import termcolor`nimport colorama`ncolorama.init()" | Set-Content .\PatchaPalooza2.py
Copy-Item .\PatchaPalooza2.py .\PatchaPalooza.py -Force
Remove-Item .\PatchaPalooza2.py

Set-Location ..\..\..
