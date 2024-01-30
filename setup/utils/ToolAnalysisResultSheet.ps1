Start-Process -FilePath "C:\venv\default\Scripts\python.exe" -ArgumentList "-m http.server -d C:\git\ToolAnalysisResultSheet 8001"
& "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --profile-directory=Default http://127.0.0.1:8001/
