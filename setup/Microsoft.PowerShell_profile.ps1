
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

# Make Windows be more like Linux :)
Set-Alias less more
Set-Alias grep findstr
Set-Alias tail Get-Content

# Dynamicly added functions below
