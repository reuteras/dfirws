. ".\resources\download\common.ps1"

New-Item -ItemType Directory -Force -Path mount\git | Out-Null
Set-Location mount\git
if (Test-Path .\PatchaPalooza) {
    # Remove PatchaPalooza directory if it exists since we do a local patch
    Remove-Item -Recurse -Force .\PatchaPalooza 2>&1 | Out-Null
}

$repourls = `
    "https://github.com/ahmedkhlief/APT-Hunter.git", `
    "https://github.com/AndrewRathbun/DFIRArtifactMuseum.git", `
    "https://github.com/ANSSI-FR/bmc-tools.git", `
    "https://github.com/avasero/psexposed.git", `
    "https://github.com/Bert-JanP/Incident-Response-Powershell.git", `
    "https://github.com/BSI-Bund/RdpCacheStitcher.git", `
    "https://github.com/crypto2011/IDR.git", `
    "https://github.com/cyberark/White-Phoenix.git", `
    "https://github.com/ExeinfoASL/ASL.git", `
    "https://github.com/fr0gger/jupyter-collection.git", `
    "https://github.com/gehaxelt/Python-dsstore.git", `
    "https://github.com/import-pandas-as-numpy/chainsaw-rules", `
    "https://github.com/JavierYuste/radare2-deep-graph.git", `
    "https://github.com/jklepsercyber/defender-detectionhistory-parser.git", `
    "https://github.com/joeavanzato/Trawler.git", `
    "https://github.com/JPCERTCC/ToolAnalysisResultSheet.git", `
    "https://github.com/KasperskyLab/iShutdown.git", `
    "https://github.com/keraattin/EmailAnalyzer.git", `
    "https://github.com/keydet89/Events-Ripper.git", `
    "https://github.com/keydet89/RegRipper4.0", `
    "https://github.com/khyrenz/parseusbs.git", `
    "https://github.com/last-byte/PersistenceSniper.git", `
    "https://github.com/last-byte/PersistenceSniper.wiki.git", `
    "https://github.com/LibreOffice/dictionaries.git", `
    "https://github.com/Malandrone/PowerDecode.git", `
    "https://github.com/mandiant/flare-floss.git", `
    "https://github.com/mandiant/gootloader.git", `
    "https://github.com/mandiant/GoReSym.git", `
    "https://github.com/mandiant/gostringungarbler.git", `
    "https://github.com/mari-mari/CapaExplorer.git", `
    "https://github.com/MarkBaggett/ese-analyst.git", `
    "https://github.com/mattifestation/CimSweep.git", `
    "https://github.com/montysecurity/malware-bazaar-advanced-search.git", `
    "https://github.com/Neo23x0/god-mode-rules.git", `
    "https://github.com/Neo23x0/signature-base.git", `
    "https://github.com/netspooky/scare.git", `
    "https://github.com/ninewayhandshake/capa-explorer.git", `
    "https://github.com/pan-unit42/dotnetfile.git", `
    "https://github.com/rabbitstack/fibratus.git", `
    "https://github.com/reuteras/dfirws.wiki.git", `
    "https://github.com/reuteras/dfirws-sample-files.git", `
    "https://github.com/reuteras/MSRC.git", `
    "https://github.com/rizinorg/cutter-jupyter.git", `
    "https://github.com/Seabreg/Regshot.git", `
    "https://github.com/sbousseaden/EVTX-ATTACK-SAMPLES.git", `
    "https://github.com/SigmaHQ/legacy-sigmatools.git", `
    "https://github.com/SigmaHQ/sigma.git", `
    "https://github.com/StrangerealIntel/Shadow-Pulse.git", `
    "https://github.com/swisscom/PowerSponse.git", `
    "https://github.com/techchipnet/HiddenWave.git", `
    "https://github.com/thewhiteninja/deobshell.git", `
    "https://github.com/TrimarcJake/BlueTuxedo.git", `
    "https://github.com/ufrisk/LeechCore.wiki.git", `
    "https://github.com/ufrisk/MemProcFS.wiki.git", `
    "https://github.com/VirusTotal/gti-dev-kit.git", `
    "https://github.com/volexity/one-extract.git", `
    "https://github.com/volexity/threat-intel.git", `
    "https://github.com/wagga40/Zircolite.git", `
    "https://github.com/reuteras/PatchaPalooza.git", `
    "https://github.com/xaitax/TotalRecall.git", `
    "https://github.com/Yamato-Security/hayabusa-rules.git", `
    "https://github.com/YosfanEilay/AuthLogParser.git", `
    "https://github.com/yossizap/cutterref.git"

foreach ($repourl in $repourls) {
    $repo = Write-Output $repourl | ForEach-Object { $_ -replace "^.*/" } | ForEach-Object { $_ -replace "\.git$" }
    if ( Test-Path -Path "${repo}" ) {
        Set-Location "${repo}"
        ${result} = git pull 2>&1
        Write-SynchronizedLog "${result}"
        Set-Location ..
    } else {
        $result = git clone "${repourl}" 2>&1
        Write-SynchronizedLog "${result}"
    }
}

# Patch PatchaPalooza
Set-Location PatchaPalooza
(Get-Content .\PatchaPalooza.py -Raw) -replace "import termcolor","import termcolor`nimport colorama`ncolorama.init()" -replace '^#!/usr/bin/.*', '#!/usr/bin/env python' | Set-Content .\PatchaPalooza2.py
Copy-Item .\PatchaPalooza2.py .\PatchaPalooza.py -Force
Remove-Item .\PatchaPalooza2.py
Set-Location ..

# Copy parseUSBs.exe to bin directory
if (Test-Path -Path ".\parseusbs\parseusbs.exe") {
    Copy-Item ".\parseusbs\parseusbs.exe" "..\Tools\bin" -Force | Out-Null
}

& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "ASL\exeinfope.zip" -o"..\Tools" | Out-Null

Set-Location ..\..
