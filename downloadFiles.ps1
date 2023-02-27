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
Copy-Item .\resources\images\sans.jpg .\tools\downloads\
Write-Output "Download done"
