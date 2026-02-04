. "${HOME}\Documents\tools\wscommon.ps1"

if (!(Test-Path "C:\mkdocs")) {
    New-Item -ItemType Directory -Force -Path "C:\mkdocs" 2>&1 | Out-Null
    Copy-Item -R "${HOME}\Documents\tools\mkdocs" C:\ | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    #Copy-Item C:\downloads\mkdocs.yml C:\mkdocs | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

Set-Location "C:\mkdocs"
& "C:\venv\bin\mkdocs.exe" build | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
$SLEEP_TIME = 2
Start-Process "C:\venv\bin\mkdocs.exe" -argumentlist "serve" -WindowStyle Hidden
Start-Sleep -Seconds "${SLEEP_TIME}"
& "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --profile-directory=Default http://localhost:8000/
