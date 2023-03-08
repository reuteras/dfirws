# Rename to customize.ps1 to use.
# Add files to this folder and they will be available as C:\local

# Customize background image:
# PowerShell.exe -ExecutionPolicy Bypass -File C:\Users\WDAGUtilityAccount\Documents\tools\Update-Wallpaper.ps1 C:\local\image.png

# Create extra shortcuts - third option is optional and is the start directory
# Set-Shortcut "C:\Users\WDAGUtilityAccount\Desktop\debloat.lnk" "C:\Tools\bin\debloat.exe" "C:\Users\WDAGUtilityAccount\Desktop"

# Chocolately
# You must have 'set SET WSDFIR_CHOCO="Yes"' in your setup\config.txt
# To install a package named die.3.07.nupkg added to .\local and therefore available in C:\local in the sandbox do:
# choco install die --version="3.7.0" --source="C:\local" -y
