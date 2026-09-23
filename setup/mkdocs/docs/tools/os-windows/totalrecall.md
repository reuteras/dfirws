# TotalRecall

**Category:** OS / Windows

**Homepage:** <https://github.com/xaitax/TotalRecall>

**Vendor:** xaitax


**Source:** Git

**Profiles:** Full, Basic

**Tags:** windows, forensics

This tool extracts and displays data from the Recall feature in Windows 11, providing an easy way to access information about your PC's activity snapshots.

## Tips
Extracts Windows Recall screenshots and the ukg.db database from a user profile. Copy the CoreAIPlatform.00 folder out of the image and point the script at it with --from_folder.

## Usage
python C:\git\TotalRecall\totalrecall.py --from_folder <copied CoreAIPlatform.00 folder>
