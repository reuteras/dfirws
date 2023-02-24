New-Item -ItemType Directory -Force -Path .\tools\downloads > $null

if (Test-Path -Path .\log\log.txt) {
    Remove-Item .\log\log.txt
}

.\resources\download\didier.ps1
.\resources\download\git.ps1
.\resources\download\http.ps1
.\resources\download\python.ps1
.\resources\download\release.ps1
.\resources\download\zimmerman.ps1
Write-Output "Copy files"
Copy-Item README.md .\tools\downloads\
Copy-Item .\resources\images\copying.png .\tools\downloads\
Copy-Item .\resources\images\installing.png .\tools\downloads\
Copy-Item .\resources\images\python.png .\tools\downloads\
Write-Output "Convert background to jpg"
$sourceFile = "$PSScriptRoot\tools\downloads\sans.png"
$saveFile = "$PSScriptRoot\tools\downloads\sans.jpg"
Add-Type -AssemblyName system.drawing
$imageFormat = "System.Drawing.Imaging.ImageFormat" -as [type]
$image = [drawing.image]::FromFile($sourceFile)
$image.Save($saveFile, $imageFormat::jpeg)
Write-Output "Download done"
