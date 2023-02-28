Remove-Item -Recurse -Force downloads > $null 2>&1
Remove-Item -Force log/log.txt > $null 2>&1
Remove-Item -Recurse -Force mount > $null 2>&1
Remove-Item -Recurse -Force tmp > $null 2>&1
