# Copy Lumen files from C:\Tools\Lumen to Desktop if not already present
$LumenSourcePath = "C:\Tools\Lumen\LUMEN"
$LumenDestPath = "$HOME\Desktop\Lumen"

if (Test-Path -Path $LumenSourcePath) {
    if (-not (Test-Path -Path $LumenDestPath)) {
        Copy-Item -Path $LumenSourcePath -Destination $LumenDestPath -Recurse -Force -Exclude ".git"
        Write-DateLog "Lumen copied to Desktop."
    }
} else {
    Write-DateLog "Lumen source path does not exist: $LumenSourcePath"
}

Set-Location ${LumenDestPath}
npm run dev
