# Force a desktop wallpaper refresh without logoff/login
# Source: https://c-nergy.be/blog/?p=17309

[CmdletBinding()]
param(
    [Parameter()]
    [string]$Path,
    [ValidateSet('Centered', 'Stretched', 'Fill', 'Fit', 'Span')] $Style = 'Fill',
    [ValidateSet('Tiles', 'NoTiles')] $Tiled = '0'
)

$Wstyle = @{
    'Centered'  = 0
    'Stretched' = 2
    'Fill'      = 10
    'Fit'       = 6
    'Span'      = 22
}

$WTile = @{
    'Tiles'     = 1
    'NoTiles'   = 0
}

$code = @'
    using System.Runtime.InteropServices;
    namespace Win32 {
        public class Wallpaper {
            [DllImport("user32.dll", CharSet=CharSet.Auto)]
            static extern int SystemParametersInfo (int uAction , int uParam , string lpvParam , int fuWinIni) ;
            public static void SetWallpaper(string thePath) {
                SystemParametersInfo(20, 0, thePath, 3);
            }
        }
    }
'@

if ($error[0].exception -like "*Cannot add type. The type name 'Win32.Wallpaper' already exists.*") {
    Write-Output "Win32.Wallpaer assemblies already loaded"
    Write-Output "Proceeding"
} else {
    Add-Type $code
}

# Set TileStyle and Wallpaper Style
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name wallpaperstyle -Value $Wstyle[$Style]
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value $WTile[$Tiled]

# Apply the change on the system
[Win32.Wallpaper]::SetWallpaper($Path)
