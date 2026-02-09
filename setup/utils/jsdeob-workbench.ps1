# Create junctions for jsdeob-workbench files from C:\Tools\jsdeob-workbench to Desktop if not already present
$jsdeobSourcePath = "C:\Tools\jsdeob-workbench\jsdeob-workbench"
$jsdeobDestPath = "$HOME\Desktop\jsdeob-workbench"

if (Test-Path -Path $jsdeobSourcePath) {
    if (-not (Test-Path -Path $jsdeobDestPath)) {
        New-Item -ItemType Directory -Path $jsdeobDestPath | Out-Null
        Set-Location $jsdeobDestPath
        Get-ChildItem $jsdeobSourcePath -File | ForEach-Object {

            Copy-Item $_.FullName -Destination (Join-Path (Get-Location) $_.Name) | Out-Null
        }
        Get-ChildItem $jsdeobSourcePath -Directory | ForEach-Object {
            New-Item -ItemType Junction -Path (Join-Path (Get-Location) $_.Name) -Target $_.FullName | Out-Null
        }
        Remove-Item .\node_modules
        New-Item -ItemType Directory -Path .\node_modules | Out-Null
        Set-Location  "$jsdeobDestPath\node_modules"
        Get-ChildItem 'C:\Tools\jsdeob-workbench\jsdeob-workbench\node_modules\' -File | ForEach-Object {
           Copy-Item $_.FullName -Destination (Join-Path (Get-Location) $_.Name) | Out-Null
        }
        Get-ChildItem 'C:\Tools\jsdeob-workbench\jsdeob-workbench\node_modules\' -Directory | ForEach-Object {
            New-Item -ItemType Junction -Path (Join-Path (Get-Location) $_.Name) -Target $_.FullName | Out-Null
        }
        Write-DateLog "jsdeob-workbench linked to Desktop."
        & "${HOME}\Documents\tools\utils\patch-vite-config.ps1" -ConfigPath "$jsdeobDestPath\vite.config.ts"
    }
} else {
    Write-DateLog "jsdeob-workbench source path does not exist: $jsdeobSourcePath"
}

Set-Location ${jsdeobDestPath}
npm run dev
