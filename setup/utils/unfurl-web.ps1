Start-Process -FilePath "C:\venv\dfir-unfurl\Scripts\python.exe" -ArgumentList "C:\venv\dfir-unfurl\Scripts\unfurl_app.py"
Start-Sleep -Seconds 2
& "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --profile-directory=Default http://127.0.0.1:5000/
