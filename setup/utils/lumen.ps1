# Create a junction link for Lumen on the Desktop if it doesn't already exist, and then run the development server.
$LumenSourcePath = "C:\Tools\Lumen\LUMEN"
$LumenDestPath = "$HOME\Desktop\Lumen"

if (Test-Path -Path $LumenSourcePath) {
    if (-not (Test-Path -Path $LumenDestPath)) {
        New-Item -ItemType Directory -Path $LumenDestPath | Out-Null
        Set-Location $LumenDestPath
        Get-ChildItem 'C:\Tools\lumen\lumen' -File | ForEach-Object {
            Copy-Item $_.FullName -Destination (Join-Path (Get-Location) $_.Name) | Out-Null
        }
        Get-ChildItem 'C:\Tools\lumen\lumen' -Directory | ForEach-Object {
            New-Item -ItemType Junction -Path (Join-Path (Get-Location) $_.Name) -Target $_.FullName | Out-Null
        }
        Remove-Item .\node_modules
        New-Item -ItemType Directory -Path .\node_modules | Out-Null
        Set-Location  "$LumenDestPath\node_modules"
        Get-ChildItem 'C:\Tools\lumen\lumen\node_modules\' -File | ForEach-Object {
           Copy-Item $_.FullName -Destination (Join-Path (Get-Location) $_.Name) | Out-Null
        }
        Get-ChildItem 'C:\Tools\lumen\lumen\node_modules\' -Directory | ForEach-Object {
            New-Item -ItemType Junction -Path (Join-Path (Get-Location) $_.Name) -Target $_.FullName | Out-Null
        }
        Write-DateLog "Lumen linked to Desktop."
        & "${HOME}\Documents\tools\utils\patch-vite-config.ps1" -ConfigPath "$LumenDestPath\vite.config.ts"
    }
} else {
    Write-DateLog "Lumen source path does not exist: $LumenSourcePath"
}

Set-Location ${LumenDestPath}
npm run dev
