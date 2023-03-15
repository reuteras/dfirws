# Have to run after unpack
Set-Location .\mount\Tools\node
.\npm init -y >> ..\..\..\log\log.txt
.\npm install --global deobfuscator >> ..\..\..\log\log.txt
.\npm install --global jsdom >> ..\..\..\log\log.txt
Set-Location ..\..\..