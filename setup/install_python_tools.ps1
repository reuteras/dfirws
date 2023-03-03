# This script runs in a Windows sandbox to prebuild the venv environment.
Write-Host "Install Python based tools"
# Update path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
rm -r "C:\venv\data" > $null 2>&1
rm -r "C:\venv\Include" > $null 2>&1
rm -r "C:\venv\Lib" > $null 2>&1
rm -r "C:\venv\Scripts" > $null 2>&1
rm -r "C:\venv\share" > $null 2>&1
rm -r "C:\venv\pyvenv.cfg" > $null 2>&1
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
Write-Host "Installed Python based tools done"
