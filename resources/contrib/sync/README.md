# User Manual for sync scripts

This folder contains a set of PowerShell scripts designed to synchronize, install, and run the DFIRWS tools in a Windows Sandbox environment. This user manual provides a brief overview of each script and instructions for using them.

## sync_to_usb.ps1

This script synchronizes files from the workspace directory (*$HOME\Documents\workspace\dfirws*) to a USB drive. It compresses the *downloads*, *mount*, and *setup* directories into a zip file, copies the compressed file to the USB drive, and then syncs the directories and required files to the USB drive.

Usage: Run **sync_to_usb.ps1** from the USB drive in PowerShell to sync files to the USB drive.

## sync_from_usb.ps1

This script copies files from the USB drive to an internal file server.

Usage: Run **sync_from_usb.ps1** in PowerShell to sync files from the USB drive to the internal file server. Run it from the folder where you would like to share the files from.

## install.ps1

This script installs the DFIRWS tools on the user's computer. If the tools are not already installed, it creates a dfirws directory in the user's *Documents* folder, copies the initial zip file from the internal file server, expands the zip file, and then runs update_and_run.ps1 to get the latest files.

Usage: Run **install.ps1** in PowerShell to install the DFIRWS tools on the user's computer.

## update_and_run.ps1

This script updates the installed DFIRWS tools on the user's computer and starts the Windows Sandbox. It updates the *downloads*, *mount*, *setup*, and other required files from the internal file server. If the *dfirws.wsb* file does not exist, it runs **createSandboxConfig.ps1** to create the Windows Sandbox configuration file. Finally, it starts the Windows Sandbox if it's not already running.

Usage: Run **update_and_run.ps1** in PowerShell to update the DFIRWS tools and start the Windows Sandbox.

## Source

Most of the text was written by ChatGPT 4.0.
