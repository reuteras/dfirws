# Rename to customize.ps1 to use.
# Add files to this folder and they will be available as C:\local

# Source common functions
. "${HOME}\Documents\tools\wscommon.ps1"

. "${WSDFIR_TEMP}\config.ps1"

# Customize background image:
# Update-Wallpaper "C:\local\image.jpg"

# Create extra shortcuts - third option is optional and is the start directory
# Set-Shortcut "${HOME}\Desktop\debloat.lnk" "C:\Tools\bin\debloat.exe" "${HOME}\Desktop"

#Add-Shortcut -SourceLnk "${HOME}\Desktop\bash.lnk" -DestinationPath "${env:ProgramFiles}\Git\bin\bash.exe" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\CyberChef.lnk" -DestinationPath "C:\Tools\CyberChef\CyberChef.html"
#Add-Shortcut -SourceLnk "${HOME}\Desktop\cmder.lnk" -DestinationPath "${env:ProgramFiles}\cmder\cmder.exe" -WorkingDirectory "${HOME}\Desktop"
#Add-Shortcut -SourceLnk "${HOME}\Desktop\Cutter.lnk" -DestinationPath "C:\Tools\cutter\cutter.exe"
#Add-Shortcut -SourceLnk "${HOME}\Desktop\FullEventLogView.lnk" -DestinationPath "C:\Tools\FullEventLogView\FullEventLogView.exe"
#Add-Shortcut -SourceLnk "${HOME}\Desktop\ghidraRun.lnk" -DestinationPath "C:\Tools\ghidra\ghidraRun.bat"
#Add-Shortcut -SourceLnk "${HOME}\Desktop\HxD.lnk" -DestinationPath "${env:ProgramFiles}\HxD\HxD.exe"
#Add-Shortcut -SourceLnk "${HOME}\Desktop\msgviewer.lnk" -DestinationPath "C:\Tools\lib\msgviewer.jar"
#Add-Shortcut -SourceLnk "${HOME}\Desktop\Malcat.lnk" -DestinationPath "C:\Tools\Malcat\bin\malcat.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\Notepad++.lnk" -DestinationPath "${env:ProgramFiles}\Notepad++\notepad++.exe"
#Add-Shortcut -SourceLnk "${HOME}\Desktop\PE-bear.lnk" -DestinationPath "C:\Tools\pebear\PE-bear.exe"
#Add-Shortcut -SourceLnk "${HOME}\Desktop\pestudio.lnk" -DestinationPath "C:\Tools\pestudio\pestudio\pestudio.exe"

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

foreach ($version in (Get-ChildItem "${TOOLS}\ghidra\" -Directory).Name) {
    New-Item -Path "${HOME}\.ghidra\.${version}" -ItemType Directory -Force | Out-Null
    ${GHIDRA_CONFIG} | Out-File -FilePath "${HOME}\.ghidra\.${version}\preferences" -Encoding ascii
}

#New-Item -Path "${HOME}/.ghidra\.ghidra_10.4_PUBLIC\Extensions" -ItemType Directory -Force | Out-Null
#& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\GolangAnalyzerExtension.zip" -o"${HOME}/.ghidra/.ghidra_10.4_PUBLIC/Extensions" | Out-Null

# Install extra programs
#Install-Ruby
#Install-Rust

# Start explorer in ${HOME}\Desktop\dfirws - use search box for easy access to tools
& "C:\Windows\explorer.exe" "${HOME}\Desktop\dfirws"

# Automation example
# Have a script that collects Quarantine files from a client and stores them in Quarantine.zip.
# If a file with that name exits in the readonly folder use Restore-Quarantine to restore the files and maldump to extract the malware file from the store.
if (Test-Path "${HOME}\Desktop\readonly\Quarantine.zip") {
    . 'C:\Users\WDAGUtilityAccount\Documents\PowerShell\Microsoft.PowerShell_profile.ps1'
    Set-Location "${HOME}\Desktop\"
    Restore-Quarantine
    C:\venv\maldump\Scripts\maldump.exe -a C:\
    if (Test-Path "${HOME}\Desktop\quarantine.tar") {
        tar xvf ".\quarantine.tar"
    }
}