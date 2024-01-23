# Script to clean up directories created by this tool.
Remove-Item -Recurse -Force "downloads" 2>&1 | Out-Null
Remove-Item -Recurse -Force "log" 2>&1 | Out-Null
Remove-Item -Recurse -Force "mount" 2>&1 | Out-Null
Remove-Item -Recurse -Force "tmp" 2>&1 | Out-Null
Remove-Item -Force tools_"downloaded.csv" 2>&1 | Out-Null
