# Always start with Python venv
if ( Test-Path C:\venv ) {
    C:\venv\Scripts\Activate.ps1
}

function Copy-Fakenet {
	Param (
        [string]$DestinationPath = "."
    )

	if (!(Test-Path "$DestinationPath")) {
		mkdir "$DestinationPath"
	}

	Copy-Item -r C:\Tools\fakenet\configs\ "$DestinationPath"
	Copy-Item -r C:\Tools\fakenet\defaultFiles\ "$DestinationPath"
	Copy-Item -r C:\Tools\fakenet\listeners\ "$DestinationPath"
}

function Copy-Node {
	Param (
        [string]$DestinationPath = "."
    )

	if (!(Test-Path "$DestinationPath")) {
		mkdir "$DestinationPath"
	}

	Copy-Item -r C:\Tools\node "$DestinationPath"
}

function Restore-Quarantine {
	if (!(Test-Path "C:\ProgramData\Microsoft\Windows Defender" )) {
		mkdir "C:\ProgramData\Microsoft\Windows Defender" > $null
	}


	if (Test-Path "C:\ProgramData\Microsoft\Windows Defender\Quarantine" ) {
		Write-DateLog "Directory C:\ProgramData\Microsoft\Windows Defender\Quarantine exists. Remove and try again."
		return
	}

	if (Test-Path "C:\Users\WDAGUtilityAccount\Desktop\readonly\Quarantine.zip") {
		Remove-Item -r -Force "C:\tmp\Quarantine" > $null 2>&1
		& "$env:ProgramFiles\7-Zip\7z.exe" x "C:\Users\WDAGUtilityAccount\Desktop\readonly\Quarantine.zip" -oc:\tmp > $null
		if (!(Test-Path "C:\tmp\Quarantine")) {
			Write-DateLog "Zip file didn't contain directory Quarantine."
			return
		}
		Copy-Item -r "C:\tmp\Quarantine" "C:\ProgramData\Microsoft\Windows Defender"
		return
	} elseif (Test-Path "C:\Users\WDAGUtilityAccount\Desktop\readonly\Quarantine" ) {
		Copy-Item -r "C:\Users\WDAGUtilityAccount\Desktop\readonly\Quarantine" "C:\ProgramData\Microsoft\Windows Defender"
		return
	}

	Write-DateLog "No directory ~\Desktop\readonly\Quarantine or file ~\Desktop\readonly\Quarantine.zip!"
}

# Make Windows be more like Linux :)
Set-Alias gdiff "$env:ProgramFiles\Git\usr\bin\diff.exe"
Set-Alias gfind "$env:ProgramFiles\Git\usr\bin\find.exe"

# Comment this line to see warnings from Python
$env:PYTHONWARNINGS="ignore"

# Dynamicly added functions below
