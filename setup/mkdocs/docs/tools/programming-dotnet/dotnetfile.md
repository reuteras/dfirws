# dotnetfile

**Category:** Programming / dotNET

**Homepage:** <https://github.com/pan-unit42/dotnetfile>

**Vendor:** Unit42

**License:** [MIT License](https://github.com/pan-unit42/dotnetfile/blob/main/LICENSE)

**Source:** Git

**Profiles:** Full, Basic

**Tags:** pe-analysis, dotnet

dotnetfile is a Common Language Runtime (CLR) header parser library for Windows .NET files built in Python. The CLR header is present in every Windows .NET assembly beside the Portable Executable (PE) header. It stores a plethora of metadata information for the managed part of the file.

## Tips
Dumps CLR header metadata, streams and metadata tables from .NET assemblies without loading them. Use it to compare against dnSpy or ILSpy when a file refuses to decompile.

## Usage
python C:\git\dotnetfile\dotnetfile_dump.py <assembly.exe>
