$SLEEP_TIME = 20
Start-Process "${env:ProgramFiles}\Amazon Corretto\jdk*\bin\java.exe" -argumentlist "-jar ${TOOLS}\lib\gollum.war -S gollum --lenient-tag-lookup ${GIT_PATH}\dfirws.wiki" -WindowStyle Hidden
Write-Output "Waiting ${SLEEP_TIME} seconds for Gollum to start before opening the browser."
Start-Sleep -Seconds "${SLEEP_TIME}"
& "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --profile-directory=Default http://localhost:4567/Home