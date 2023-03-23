# Rename to customize.ps1 to use.
# Add files to this folder and they will be available as C:\local

# Source common functions
. C:\Users\WDAGUtilityAccount\Documents\tools\common.ps1

# Customize background image:
# Update-Wallpaper "C:\local\image.jpg"

# Create extra shortcuts - third option is optional and is the start directory
# Set-Shortcut "C:\Users\WDAGUtilityAccount\Desktop\debloat.lnk" "C:\Tools\bin\debloat.exe" "C:\Users\WDAGUtilityAccount\Desktop"

# Add new path for user
# Add-ToUserPath "C:\local\bin"

# Chocolately
# You must have 'set SET WSDFIR_CHOCO="Yes"' in your setup\config.txt
# To install a package named die.3.07.nupkg added to .\local and therefore available in C:\local in the sandbox do:
# choco install die --version="3.7.0" --source="C:\local" -y
