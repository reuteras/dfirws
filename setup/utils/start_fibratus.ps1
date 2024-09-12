$SLEEP_TIME = 2
Set-Location "${GIT_PATH}\fibratus\docs"
Start-Process pwsh -argumentlist "${TOOLS}\node\docsify.ps1 serve" -WindowStyle Hidden
Write-Output "Waiting ${SLEEP_TIME} seconds for docsify to start before opening the browser."
Start-Sleep -Seconds "${SLEEP_TIME}"
& "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --profile-directory=Default http://localhost:3000/