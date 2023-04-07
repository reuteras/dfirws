. $PSScriptRoot\common.ps1

Write-DateLog "Download git repositories"

if (! (Get-Command git )) {
    Write-DateLog "Need git to checkout git repositories."
    Exit
}

New-Item -ItemType Directory -Force -Path mount\git > $null
Set-Location mount\git

$repourls = `
    "https://github.com/gehaxelt/Python-dsstore.git", `
    "https://github.com/keydet89/Events-Ripper.git", `
    "https://github.com/last-byte/PersistenceSniper.git", `
    "https://github.com/Neo23x0/evt2sigma.git", `
    "https://github.com/netspooky/scare.git", `
    "https://github.com/pan-unit42/dotnetfile.git", `
    "https://github.com/reuteras/dfirws.wiki.git", `
    "https://github.com/SigmaHQ/sigma.git", `
    "https://github.com/volexity/threat-intel.git", `
    "https://github.com/wagga40/Zircolite.git", `
    "https://github.com/Yamato-Security/hayabusa-rules.git"

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

Set-Location ..\..
