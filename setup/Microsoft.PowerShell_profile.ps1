
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

function Restore-Quarantine {
	if (!(Test-Path "C:\ProgramData\Microsoft\Windows Defender" )) {
		mkdir "C:\ProgramData\Microsoft\Windows Defender" > $null
	}


	if (Test-Path "C:\ProgramData\Microsoft\Windows Defender\Quarantine" ) {
		Write-Output "Directory C:\ProgramData\Microsoft\Windows Defender\Quarantine exists. Remove and try again."
		return
	}

	if (Test-Path "C:\Users\WDAGUtilityAccount\Desktop\readonly\Quarantine.zip") {
		Remove-Item -r -Force "C:\tmp\Quarantine"
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
function docx2txt() { python C:\venv\Scripts\docx2txt $PsBoundParameters.Values + $args }
function prichunkpng() { python C:\venv\Scripts\prichunkpng $PsBoundParameters.Values + $args }
function pricolpng() { python C:\venv\Scripts\pricolpng $PsBoundParameters.Values + $args }
function priditherpng() { python C:\venv\Scripts\priditherpng $PsBoundParameters.Values + $args }
function priforgepng() { python C:\venv\Scripts\priforgepng $PsBoundParameters.Values + $args }
function prigreypng() { python C:\venv\Scripts\prigreypng $PsBoundParameters.Values + $args }
function pripalpng() { python C:\venv\Scripts\pripalpng $PsBoundParameters.Values + $args }
function pripamtopng() { python C:\venv\Scripts\pripamtopng $PsBoundParameters.Values + $args }
function priplan9topng() { python C:\venv\Scripts\priplan9topng $PsBoundParameters.Values + $args }
function pripnglsch() { python C:\venv\Scripts\pripnglsch $PsBoundParameters.Values + $args }
function pripngtopam() { python C:\venv\Scripts\pripngtopam $PsBoundParameters.Values + $args }
function prirowpng() { python C:\venv\Scripts\prirowpng $PsBoundParameters.Values + $args }
function priweavepng() { python C:\venv\Scripts\priweavepng $PsBoundParameters.Values + $args }
function spark-parser-coverage() { python C:\venv\Scripts\spark-parser-coverage $PsBoundParameters.Values + $args }
function unpy2exe() { python C:\venv\Scripts\unpy2exe $PsBoundParameters.Values + $args }
function vd() { python C:\venv\Scripts\vd $PsBoundParameters.Values + $args }
