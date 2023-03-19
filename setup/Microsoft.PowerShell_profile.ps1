
if ( Test-Path C:\venv ) {
    C:\venv\Scripts\Activate.ps1
}

# Use git to diff to files
function Compare-File1AndFile2 ($file1, $file2) {
    git diff $file1 $file2
}
Set-Alias gdiff Compare-File1AndFile2

function tailf {
    Get-Content -Wait $args
}

function Copy-Node {
	Param (
        [string]$DestinationPath = "."
    )

	Copy-Item -r C:\Tools\node "$DestinationPath"
}

function Restore-Quarantine {
	if (!(Test-Path "C:\ProgramData\Microsoft\Windows Defender" )) {
		mkdir "C:\ProgramData\Microsoft\Windows Defender" > $null
	}


	if (Test-Path "C:\ProgramData\Microsoft\Windows Defender\Quarantine" ) {
		Write-Output "Directory C:\ProgramData\Microsoft\Windows Defender\Quarantine exists. Remove and try again."
		return
	}

	if (Test-Path "C:\Users\WDAGUtilityAccount\Desktop\readonly\Quarantine.zip") {
		Remove-Item -r -Force "C:\tmp\Quarantine" > $null 2>&1
		& 'C:\Program Files\7-Zip\7z.exe' x "C:\Users\WDAGUtilityAccount\Desktop\readonly\Quarantine.zip" -oc:\tmp > $null
		if (!(Test-Path "C:\tmp\Quarantine")) {
			Write-Output "Zip file didn't contain directory Quarantine."
			return
		}
		Copy-Item -r "C:\tmp\Quarantine" "C:\ProgramData\Microsoft\Windows Defender"
		return
	} elseif (Test-Path "C:\Users\WDAGUtilityAccount\Desktop\readonly\Quarantine" ) {
		Copy-Item -r "C:\Users\WDAGUtilityAccount\Desktop\readonly\Quarantine" "C:\ProgramData\Microsoft\Windows Defender"
		return
	}

	Write-Output "No directory ~\Desktop\readonly\Quarantine or file ~\Desktop\readonly\Quarantine.zip!"
}

# Make Windows be more like Linux :)
Set-Alias less more
Set-Alias grep findstr
Set-Alias tail Get-Content

# Dynamicly added functions below
