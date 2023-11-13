# Rename to customize.ps1 to use.
# Add files to this folder and they will be available as C:\local

# Source common functions
. $HOME\Documents\tools\wscommon.ps1

# Customize background image:
# Update-Wallpaper "C:\local\image.jpg"

# Create extra shortcuts - third option is optional and is the start directory
# Set-Shortcut "$HOME\Desktop\debloat.lnk" "C:\Tools\bin\debloat.exe" "$HOME\Desktop"

#Add-Shortcut -SourceLnk "$HOME\Desktop\bash.lnk" -DestinationPath "$env:ProgramFiles\Git\bin\bash.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\CyberChef.lnk" -DestinationPath "C:\Tools\CyberChef\CyberChef.html"
#Add-Shortcut -SourceLnk "$HOME\Desktop\cmder.lnk" -DestinationPath "$env:ProgramFiles\cmder\cmder.exe" -WorkingDirectory "$HOME\Desktop"
#Add-Shortcut -SourceLnk "$HOME\Desktop\Cutter.lnk" -DestinationPath "C:\Tools\cutter\cutter.exe"
#Add-Shortcut -SourceLnk "$HOME\Desktop\FullEventLogView.lnk" -DestinationPath "C:\Tools\FullEventLogView\FullEventLogView.exe"
#Add-Shortcut -SourceLnk "$HOME\Desktop\ghidraRun.lnk" -DestinationPath "C:\Tools\ghidra\ghidraRun.bat"
#Add-Shortcut -SourceLnk "$HOME\Desktop\HxD.lnk" -DestinationPath "$env:ProgramFiles\HxD\HxD.exe"
#Add-Shortcut -SourceLnk "$HOME\Desktop\msgviewer.lnk" -DestinationPath "C:\Tools\lib\msgviewer.jar"
#Add-Shortcut -SourceLnk "$HOME\Desktop\Malcat.lnk" -DestinationPath "C:\Tools\Malcat\bin\malcat.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\Notepad++.lnk" -DestinationPath "$env:ProgramFiles\Notepad++\notepad++.exe"
#Add-Shortcut -SourceLnk "$HOME\Desktop\PE-bear.lnk" -DestinationPath "C:\Tools\pebear\PE-bear.exe"
#Add-Shortcut -SourceLnk "$HOME\Desktop\pestudio.lnk" -DestinationPath "C:\Tools\pestudio\pestudio\pestudio.exe"

# Add new path for user
# Add-ToUserPath "C:\local\bin"

# Chocolately
# You must have 'set SET WSDFIR_CHOCO="Yes"' in your setup\config.txt
# To install a package named die.3.07.nupkg added to .\local and therefore available in C:\local in the sandbox do:
# choco install die --version="3.7.0" --source="C:\local" -y
