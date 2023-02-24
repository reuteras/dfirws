Write-Host "Download git repositories"

if (! (Get-Command git )) {
    Write-Host "Need git to checkout git repositories."
    Exit
}

New-Item -ItemType Directory -Force -Path tools\downloads\git > $null
Set-Location tools\downloads\git

$repourls = `
    "https://github.com/keydet89/Events-Ripper.git", `
    "https://github.com/Neo23x0/evt2sigma.git", `
    "https://github.com/Neo23x0/signature-base.git", `
    "https://github.com/SigmaHQ/sigma.git", `
    "https://github.com/volexity/threat-intel.git"

foreach ($repourl in $repourls) {
    $repo = Write-Output $repourl | ForEach-Object { $_ -replace "^.*/" } | ForEach-Object { $_ -replace "\..*$" }
    if ( Test-Path -Path $repo ) {
        Set-Location $repo
        git pull >> ..\..\..\..\log\log.txt 2>&1
        Set-Location ..
    } else {
        git clone $repourl >> ..\..\..\log\log.txt 2>&1
    }
}

Set-Location ..\..\..
