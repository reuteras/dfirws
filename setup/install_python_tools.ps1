# This script runs in a Windows sandbox to prebuild the venv environment.
Write-Output "Install Python based tools"
# Update path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
Remove-Item -r "C:\venv\data" > $null 2>&1
Remove-Item -r "C:\venv\Include" > $null 2>&1
Remove-Item -r "C:\venv\Lib" > $null 2>&1
Remove-Item -r "C:\venv\Scripts" > $null 2>&1
Remove-Item -r "C:\venv\share" > $null 2>&1
Remove-Item -r "C:\venv\pyvenv.cfg" > $null 2>&1
python -m venv C:\venv
C:\venv\Scripts\Activate.ps1
python -m pip config set global.disable-pip-version-check true
Set-Location C:\downloads\pip
Get-ChildItem . -Filter wheel* | Foreach-Object { python -m pip install --disable-pip-version-check $_ }
Get-ChildItem . -Filter *.gz | Foreach-Object { python -m pip install --disable-pip-version-check --no-deps --no-build-isolation $_ }
Get-ChildItem . -Filter *.whl | Foreach-Object { python -m pip install --disable-pip-version-check --no-deps --no-build-isolation $_ }
Get-ChildItem . -Filter *.zip | Foreach-Object { python -m pip install --disable-pip-version-check --no-deps --no-build-isolation $_ }
mkdir c:\tmp
Copy-Item -r C:\git\threat-intel C:\tmp
Copy-Item -r C:\git\dotnetfile C:\tmp
Set-Location C:\tmp\threat-intel\tools\one-extract
python -m pip install --disable-pip-version-check .
Set-Location C:\tmp\dotnetfile
python setup.py install
deactivate
Write-Output "Installed Python based tools done"
