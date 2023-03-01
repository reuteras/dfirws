# Script to clean up directories created by this tool.
Remove-Item -Recurse -Force downloads > $null 2>&1
Remove-Item -Recurse -Force log > $null 2>&1
Remove-Item -Recurse -Force mount > $null 2>&1
Remove-Item -Recurse -Force tmp > $null 2>&1
