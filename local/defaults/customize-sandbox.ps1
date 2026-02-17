# Copy this file to local\customize.ps1 to customize the sandbox.
# Add files to this folder and they will be available as C:\local

# Source common functions
. "${HOME}\Documents\tools\wscommon.ps1"

. "${WSDFIR_TEMP}\config.ps1"

# Customize background image:
# Update-Wallpaper "C:\local\image.jpg"

# Add-Shortcut -SourceLnk "${HOME}\Desktop\bash.lnk" -DestinationPath "${env:ProgramFiles}\Git\bin\bash.exe" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\CyberChef.lnk" -DestinationPath "C:\Tools\CyberChef\CyberChef.html" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "C:\Tools\CyberChef\CyberChef.ico"
# Add-Shortcut -SourceLnk "${HOME}\Desktop\cmder.lnk" -DestinationPath "${env:ProgramFiles}\cmder\cmder.exe" -WorkingDirectory "${HOME}\Desktop"
# Add-Shortcut -SourceLnk "${HOME}\Desktop\Cutter.lnk" -DestinationPath "C:\Tools\cutter\cutter.exe"
# Add-Shortcut -SourceLnk "${HOME}\Desktop\FullEventLogView.lnk" -DestinationPath "C:\Tools\FullEventLogView\FullEventLogView.exe"
# Add-Shortcut -SourceLnk "${HOME}\Desktop\ghidraRun.lnk" -DestinationPath "C:\Tools\ghidra\ghidraRun.bat"
# Add-Shortcut -SourceLnk "${HOME}\Desktop\HxD.lnk" -DestinationPath "${env:ProgramFiles}\HxD\HxD.exe"
# Add-Shortcut -SourceLnk "${HOME}\Desktop\msgviewer.lnk" -DestinationPath "C:\Tools\lib\msgviewer.jar"
# Add-Shortcut -SourceLnk "${HOME}\Desktop\Malcat.lnk" -DestinationPath "C:\Tools\Malcat\bin\malcat.exe"
# Add-Shortcut -SourceLnk "${HOME}\Desktop\PE-bear.lnk" -DestinationPath "C:\Tools\pebear\PE-bear.exe"
# Add-Shortcut -SourceLnk "${HOME}\Desktop\pestudio.lnk" -DestinationPath "C:\Tools\pestudio\pestudio\pestudio.exe"

if ($WSDFIR_NOTEPAD -eq "Yes") {
    # Configure Notepad++
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\comparePlus.zip" -o"${env:ProgramFiles}\Notepad++\Plugins\ComparePlus" | Out-Null
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\DSpellCheck.zip" -o"${env:ProgramFiles}\Notepad++\Plugins\DSpellCheck" | Out-Null
    New-Item -Path "${env:USERPROFILE}\AppData\Roaming\Notepad++\plugins\config\Hunspell" -ItemType Directory -Force | Out-Null
    if ("${WSDFIR_DARK}" -eq "Yes") {
        if (Test-Path "${LOCAL_PATH}\notepad++_dark.xml") {
            Copy-Item "${LOCAL_PATH}\notepad++_dark.xml" "${env:USERPROFILE}\AppData\Roaming\Notepad++\config.xml" -Force
        } else {
            Copy-Item "${LOCAL_PATH}\defaults\notepad++_dark.xml" "${env:USERPROFILE}\AppData\Roaming\Notepad++\config.xml" -Force
        }
    }
    if (Test-Path "${LOCAL_PATH}\DSpellCheck.ini") {
        Copy-Item "${LOCAL_PATH}\DSpellCheck.ini" "${env:USERPROFILE}\AppData\Roaming\Notepad++\plugins\config\DSpellCheck.ini" -Force
    } else {
        Copy-Item "${LOCAL_PATH}\defaults\DSpellCheck.ini" "${env:USERPROFILE}\AppData\Roaming\Notepad++\plugins\config\DSpellCheck.ini" -Force
    }

    # Add US English dictionary
    if (Test-Path "${GIT_PATH}\dictionaries") {
        Copy-Item "${GIT_PATH}\dictionaries\en\en_US.dic" "${env:USERPROFILE}\AppData\Roaming\Notepad++\plugins\config\Hunspell\en_US.dic" -Force
        Copy-Item "${GIT_PATH}\dictionaries\en\en_US.aff" "${env:USERPROFILE}\AppData\Roaming\Notepad++\plugins\config\Hunspell\en_US.aff" -Force
    }
}

# Add new path for user
# Add-ToUserPath "C:\local\bin"

# Configure Ghidra

if ( "${WSDFIR_DARK}" -eq "Yes") {
    ${GHIDRA_THEME} = "Theme=Class\:generic.theme.builtin.FlatDarkTheme"
} else {
    ${GHIDRA_THEME} = "Theme=Class\:generic.theme.builtin.FlatLightTheme"
}

${GHIDRA_CONFIG} = @"
#User Preferences
#Thu Nov 23 11:55:41 CET 2023
GhidraShowWhatsNew=false
LAST_USED_OPTIONS_CONFIG=Standard Defaults
LastExtensionImportDirectory=C\:\\Tools\\ghidra_extensions
LastNewProjectDirectory=C\:\\Users\\${env:USERNAME}
ProjectDirectory=C\:\\Users\\${env:USERNAME}
RECENT_0=C\:\\Tools\\ghidra_extensions
RECENT_1=C\:\\Users\\${env:USERNAME}\\Desktop
SHOW_TIPS=false
${GHIDRA_THEME}
USER_AGREEMENT=ACCEPT
"@

if (Test-Path "${TOOLS}\ghidra\") {
    foreach ($version in (Get-ChildItem "${TOOLS}\ghidra\" -Directory).Name) {
        New-Item -Path "${HOME}\AppData\Roaming\ghidra\${version}" -ItemType Directory -Force | Out-Null
        ${GHIDRA_CONFIG} | Out-File -FilePath "${HOME}\AppData\Roaming\ghidra\${version}\preferences" -Encoding ascii
    }
}

# Start explorer in ${HOME}\Desktop\dfirws - use search box for easy access to tools
& "C:\Windows\explorer.exe" "${HOME}\Desktop\dfirws"

# Install extra programs
# See setup\wscommon.ps1 for available install functions
#Install-Obsidian

# Automation example
# Have a script that collects Quarantine files from a client and stores them in Quarantine.zip.
# If a file with that name exits in the readonly folder use Restore-Quarantine to restore the files and maldump to extract the malware file from the store.
if (Test-Path "${HOME}\Desktop\readonly\Quarantine.zip") {
    . 'C:\Users\WDAGUtilityAccount\Documents\PowerShell\Microsoft.PowerShell_profile.ps1'
    Set-Location "${HOME}\Desktop\"
    Restore-Quarantine
    C:\venv\bin\maldump.exe -a C:\
    if (Test-Path "${HOME}\Desktop\quarantine.tar") {
        tar xvf ".\quarantine.tar"
    }
}

# You can access the arguments used to start the sandbox like this
# Write-Output @args | Out-File -FilePath "${HOME}\Desktop\args.txt" -Encoding ascii

# PowerShell shortcut to start pwsh in Desktop folder
# Add-Shortcut -SourceLnk "${HOME}\Desktop\PowerShell.lnk" -DestinationPath "${env:ProgramFiles}\PowerShell\7\pwsh.exe" -WorkingDirectory "${HOME}\Desktop"

# Add your own customizations here
