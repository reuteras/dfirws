Write-Host "Install Python based tools"
# Update path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
python -m venv C:\venv *>> "C:\temp\python.txt"
C:\venv\Scripts\Activate.ps1 *>> C:\temp\python.txt
python -m pip config set global.disable-pip-version-check true
Set-Location C:\Users\WDAGUtilityAccount\Documents\tools\downloads\pip *>> C:\temp\python.txt
Get-ChildItem . -Filter wheel* | Foreach-Object { python -m pip install --disable-pip-version-check $_ } *>> c:\temp\python.txt
Get-ChildItem . -Filter *.gz | Foreach-Object { python -m pip install --disable-pip-version-check --no-deps --no-build-isolation $_ } *>> c:\temp\python.txt
Get-ChildItem . -Filter *.whl | Foreach-Object { python -m pip install --disable-pip-version-check --no-deps --no-build-isolation $_ } *>> c:\temp\python.txt
Get-ChildItem . -Filter *.zip | Foreach-Object { python -m pip install --disable-pip-version-check --no-deps --no-build-isolation $_ } *>> c:\temp\python.txt
Copy-Item -r C:\Users\WDAGUtilityAccount\Documents\tools\downloads\git\threat-intel c:\temp
Set-Location C:\temp\threat-intel\tools\one-extract
python -m pip install --disable-pip-version-check . *>> c:\temp\one-extract.txt
deactivate
Write-Host "Installed Python based tools done"
