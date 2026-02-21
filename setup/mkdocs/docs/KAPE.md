# KAPE

- [KAPE documentation](https://ericzimmerman.github.io/KapeDocs/#!index.md)

**Notice:** For Kape to be installed and available you will have to place your copy of kape.zip in the *local* subdirectory and then run **.\downloadFiles.ps1** or **.\downloadFiles.ps1 --kape**. You also have to install the following package on the host:

```bash
winget install Microsoft.DotNet.Runtime.6
```

## Usage

The best way to use KAPE in dfirws is to only run the *modules* part of KAPE inside the sandbox and run the *targets* part outside of the sandbox.

## Example

This example uses the *Windows Laptop Image* from [2019 Digital Forensics Downloads](https://cci.calpoly.edu/2019-digital-forensics-downloads) from [California Cybersecurity Institute](https://cci.calpoly.edu/).

First open a **PowerShell** window with administrative privileges and mount the downloaded E01-image:

```bash
aim_cli.exe --readonly --filename='<path to>\Laptop Image\Craig Tucker Desktop.E01' --mount
Opening image file '<path to>\Laptop Image\Craig Tucker Desktop.E01' with format provider 'LibEwf'...
Image virtual size is 60,0 GB
Mounting as virtual disk...
Device number 000000
Device is \\?\PhysicalDrive2

Contains volume \\?\Volume{2cd00884-0000-0000-0000-100000000000}\
  Mounted at E:\
Virtual disk created. Press Ctrl+C to remove virtual disk and exit.
```

In a separate **PowerShell** window with administrative privileges change current directory to where you have KAPE installed and run:

```bash
cd <KAPE directory>
.\kape.exe --tsource E: --tdest <path to>\dfirws\readonly\kape --tflush --target !SANS_Triage
```

After getting the data it is now possible to use KAPE in the dfirws sandbox. Start a sandbox and in the sandbox start *PowerShell*. There you have to install KAPE and then you can use kape (or gkape for a GUI) to extract information.

```bash
dfirws-install.ps1 --kape
cd 'C:\Program Files\KAPE\'
.\kape.exe --msource C:\Users\WDAGUtilityAccount\Desktop\readonly\kape --mdest C:\Users\WDAGUtilityAccount\Desktop\kape --mflush --module Bulk_extractor,Chainsaw,!EZParser,Events-Ripper,Hayabusa,RegRipper --gui
(default) PS C:\Program Files\KAPE> dir ~\Desktop\kape\

    Directory: C:\Users\WDAGUtilityAccount\Desktop\kape

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----          2024-01-03    14:40                EventLogs
d----          2024-01-03    14:40                FileDeletion
d----          2024-01-03    14:40                FileFolderAccess
d----          2024-01-03    14:40                FileSystem
d----          2024-01-03    14:40                ProgramExecution
d----          2024-01-03    14:40                Registry
d----          2024-01-03    14:40                SQLDatabases
d----          2024-01-03    14:41                SRUMDatabase
d----          2024-01-03    14:41                SUMDatabase
-a---          2024-01-03    14:41          16649 2024-01-03T13_40_21_8154977_ConsoleLog.txt

```

In the output directory there will be many result files. To look at csv-files you could for instance use **EZViewer.exe** from Eric Zimmerman:

```bash
EZViewer.exe C:\Users\WDAGUtilityAccount\Desktop\kape\ProgramExecution\20240103134040_PECmd_Output_Timeline.csv
```

## Image mounting

KAPE recommends using [Arsenal Image Mounter](https://arsenalrecon.com/downloadsI) (AIM) over tools like FTK Imager. Arsenal Image Mounter is distributed via MEGA.nz and can't easily be added to DFIRWS so you have to download it manually if it is needed. The driver for AIM requires a reboot and it is therefore not suitable for the DFIRWS sandbox. It is still relevant for when there is an installation option for virtual machines.

