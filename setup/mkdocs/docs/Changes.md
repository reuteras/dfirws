# Changelog

This changelog is for changes affecting the usage of the **dfirws** sandbox. Most updates to installed tools will not be listed here.

## 2026-02-09

- Start updating the changelog. Lots of changes from 2024-11-12 until now is not listed here.
- Documentation has been changed from using GitHub wiki to using MkDocs. This file is now located in the *docs* folder and will be used to generate the documentation site.

## 2024-11-12

- Add [artemis](https://github.com/puffyCid/artemis)
- Add [godap](https://github.com/Macmod/godap)
- Add [DetectionHistory Parser](https://github.com/jklepsercyber/defender-detectionhistory-parser)
- Add [litecli](https://github.com/dbcli/litecli)

## 2024-10-17

- Add cache for Visual Studio Buildtools and make it available to install in sandbox.
- Add [LogBoost](https://github.com/joeavanzato/LogBoost)

## 2024-10-06

- Add [takajo](https://github.com/Yamato-Security/takajo)
- Add Intel driver for **hashcat**
- Add DSpellCheck and NppMarkdownPanel plugins for **Notepad++**

## 2024-10-05

- Add recbin based on the blog post [Windows RecycleBin Forensics](https://medium.com/@mehrnoush/windows-recyclebin-forensics-a0855b957a31)
- Add capa Explorer Web

## 2024-09-13

- Added Google Earth Pro
- Added [OSFMount](https://www.osforensics.com/tools/mount-disk-images.html)
- Added installers for Tailscale, Wireguard and OpenVPN
- Added [ngrok](https://ngrok.com)

## 2024-09-12

- Added the option *-verify* do `downloadFiles.ps1` to verify that downloads are correct and tool are available in a running sandbox.
- Added [yq](https://github.com/mikefarah/yq/)
- Added [yara-x](https://github.com/VirusTotal/yara-x)
- Added [ffmpeg](https://github.com/BtbN/FFmpeg-Builds) built for Windows
- Added alias `di` for `dfirws-install.ps1` to save typing
- Added [fibratus](https://github.com/rabbitstack/fibratus) - An adversary tradecraft detection, protection, and hunting tool
- Added [SSHniff](https://github.com/CrzPhil/SSHniff) - More information in the authors post, [SSH Keystroke Obfuscation Bypass](https://crzphil.github.io/posts/ssh-obfuscation-bypass/)
- Added [Audacity](https://github.com/audacity/audacity)
- Added [HiddenWave](https://github.com/techchipnet/HiddenWave) repository
- Added [stego-lsb](https://pypi.org/project/stego-lsb/)

## 2024-09-03

- Added MSYS2 compiler and plugin for Visual Studio Code to use it.

## 2024-05-20

- Switch to download release version of Zircolite.

## 2024-05-08

- Download some Obsidian plugins.

## 2024-04-20

- Added repository cvelistV5 that contains CVE information in JSON format.

## 2024-04-03

- Added ZAProxy and Burp Suite

## 2024-04-02

- Added VLC
- Added PowerShell module ImportExcel
- Added DBeaver
- Added GoLang package install and added protodump. **Requires** that you create new .wsb files for it to work!

## 2024-04-01

- Add cvs-stats.py by Didier Stevens
- Added sigs.py

## 2024-03-27

- Added mmdbinspect from Maxmind

## 2024-03-26

- Added Irfanview

## 2024-03-22

- Add Foxit Reader as an installable option for **dfirws-install.ps1**
- Context menu options for .js, .pdf and Office files

## 2024-03-21

- Add [ingestr](https://bruin-data.github.io/ingestr/)
- Start adding more programs to context menus.

## 2024-03-17

- Added Veracrypt
- Added Google magika, AI based version of the file command.
- Added ClamAV. Freshclam is also an option to **downloadFiles.ps1**

## 2024-03-15

- IPinfo.io added as an option to enrichment
- Added helper script to show automation if a file Quarantine.zip exits in the *readonly* folder.
- Content of dfirws folder are now added to the Start menu. Can be disabled.

## 2024-03-13

- Added Chrome, Firefox and Tor browser
- Added Putty
- Added DCode
- Added HFS
- Added Maltego
- Add option to add programs in the dfirws folder to the start menu (enabled in default config)

## 2024-03-08

- Added [malwarebazaar](https://github.com/3c7/bazaar) - a command-line tool to access [MalwareBazaar](https://bazaar.abuse.ch/).
- Also added [malware-bazaar-advanced-search](https://github.com/montysecurity/malware-bazaar-advanced-search) introduced [in this blog](https://montysecurity.medium.com/hunting-cobalt-strike-lnk-loaders-f3c407a991c0)
- Add [pdfalyzer](https://github.com/michelcrypt4d4mus/pdfalyzer)

## 2024-03-05

- Added [peepdf-3](https://github.com/digitalsleuth/peepdf-3) in a separate venv with pyreadline and stpyv8 installed.

## 2024-03-04

- Install full regipy in separate venv
- Add gootloader and Sigma-Rules Git repositories.
- Moved yara-forge rules to *C:\enrichment* from *C:\Data*
- Use **.\downloadFiles.ps1 -Enrichment** instead of **.\enrichment.ps1**

## 2024-02-29

- Add simple script pst-extrac.py to extract msg-files from pst-files. Also save all attachments (added venv aspose).
- Add fx and gron for JSON
- Add gpg4win
- Add BinaryNinja-Free for test
- Split office and email in the dfirws link folder on the desktop

## 2024-02-27

- Add jpterm
- Add toolong (tl)
- Add option to auto hide toolbar (defaults to hide)

## 2024-02-25

- Add plugins to sigma in venv sigma-cli

## 2024-02-19

- Fix capa integration in Ghidra with ghidrathon

## 2024-02-15

- Move configuration files to *local* and defaults to *local\defaults*
- Better handling of fonts and oh-my-posh settings
- Added [tabby.sh](https://tabby.sh)
- Added ruff and shellcheck extensions to Visual Studio Code
- Gollum is not started on boot, only after clicking the link
- Added [rexi](https://github.com/royreznik/rexi) for testing regular expressions
- Added [shodan cli](https://github.com/achillean/shodan-python)
- Added [DC3-MWCP](https://github.com/dod-cyber-crime-center/DC3-MWCP) venv

## 2024-02-09

- Add [MemProcFS](https://github.com/ufrisk/MemProcFS) to sandbox. Also add [Dokany](https://github.com/dokan-dev/dokany).
- It is now possible to create a VM.

## 2024-02-08

- First support for using downloaded files to build a VM with VMware Workstation is done. Documentation will come later.

## 2024-02-01

- Add option to add oh-my-posh and NerdFonts
- Switch venv pySigma to venv sigma-cli
- Autocomplete added for some Rust tools
- Add Rust based tools:  mft2bodyfile and usnjrnl
- Add script to download PowerShell modules
- Add iShutdown to Path
- Always add PersistenceSniper to Path
- Copy AuthLogParser to Program Files
- Updated links to programs in the *dfirws* folder on the desktop. Clicking on links now runs the cli commands to output help information.

## 2024-01-29

- Add more links to the *dfirws* folder on the desktop, now for Sysinternals and Didier Stevens tools. Also more comments to help describe some of the tools. More to come later.

## 2024-01-28

- Links in the *dfirws* folder on the desktop to Zimmerman tools.
- More Zimmerman tools are copied to *Program Files* during sandbox start to be able to write files in their respective installation directory.
- If the **enrichment.ps1** script is used, then **iisGeolocate** will get the latest database from Maxmind.
- Add default configuration for xelfviewer and hasher.
- Move configuration files to *local* directory. Defaults are used if no custom one has been created.
- Fixed script **recaf.bat**
- Fix download and unpack of **pestudio** and **hayabusa**.
- Since the sandbox has no permanent storage the license for most Sysinternal scripts have been accepted. Please read the license and EULA on your regular desktop computer.
- Modify **dfirws-install.ps1** to use **PowerShell** *switch* statements instead of custom *--switch* statements. Now it is possible to use tab-complete and also to list options by running **Get-Help dfirws-install.ps1**.

## 2024-01-26

- Add Visual Studio dumpbin tools via the repository [Delphier/dumpbin](https://github.com/Delphier/dumpbin).

## 2024-01-24

- Move **Malcat** from *C:\Tools* to C:\Program files* since the program writes data and configuration to the installation directory.
- Add the GitHub repository [TrimarcJake/BlueTuxedo](https://github.com/TrimarcJake/BlueTuxedo.git).
- Add Python venv with [clearbluejar/ghidrecomp](https://github.com/clearbluejar/ghidrecomp).

## 2024-01-22

- **Important:** The template for the sandbox files have been updated to add *C:\enrichment*. Add it yourself from the template or remove the *.wsb* files and run **.\createSandboxConfig.ps1** again.
- Install option *--wireshark* has been added to **dfirws-install.ps1* which also adds a configuration to enable GeoIP if Maxmind is available.
- If dark mode is enabled, **Notepad++** will start with dark mode.

## 2024-01-19

- Add Git repository [iShutdown](https://github.com/KasperskyLab/iShutdown) see the blog post [A lightweight method to detect potential iOS malware](https://securelist.com/shutdown-log-lightweight-ios-malware-detection-method/111734/).
- Made the update script much faster making it easier to keep the tools updated.

## 2024-01-16

- Download [Adalanche](https://github.com/lkarlslund/Adalanche) to the sandbox. Description: *Active Directory ACL Visualizer and Explorer - who's really Domain Admin?*
- Make it possible to now download and install jep and ghidrathon to save time if not needed.

## 2024-01-15

- Add [CanaryTokenScanner.py](https://github.com/0xNslabs/CanaryTokenScanner/)
- Fix installation of Visual Studio Code so it isn't associated with any file types to avoid questions about using it or Python for .py-files.

## 2024-01-04

- Add Perl to the sandbox. This way it is possible to test code from Perl based malware.
- Add script to enable Ghidrathon in Ghidra.

## 2024-01-03

- Add support for having KAPE in the sandbox. If you place your kape.zip in the *local* directory it will get installed and updated in *C:\Tools\KAPE*.

## 2023-12-29

- Add repository from JPCERT named [Tool Analysis Result Sheet](https://github.com/JPCERTCC/ToolAnalysisResultSheet), run **ToolAnalysisResultSheet.ps1** to start a local web server with its content.
- Add Rust and the tool [dfir-toolkit](https://github.com/dfir-dd/dfir-toolkit) that is written in Rust.
- Add [Volatility Workbench](https://www.osforensics.com/tools/volatility-workbench.html) 2.1 and 3.
- Add tools from Nirsoft for viewing browser data.

## 2023-12-28

- Install both Ghidra 10.4 and the latest version (currently 11.0).
- Download h2database for use with Ghidra BSIM (also download h2.pdf).
- Add [AuthLogParser](https://github.com/YosfanEilay/AuthLogParser/) repository.
- Add [Shadow-Pulse](https://github.com/StrangerealIntel/Shadow-Pulse) repository with information about ransomware.
- Add [CaRT (Compressed and RC4 Transport)](https://github.com/CybercentreCanada/cart) package from pypi. The CaRT file format is used to store/transfer malware and its associated metadata. It neuters the malware so it cannot be executed and encrypts it so anti-virus software cannot flag the CaRT file as malware.

## 2023-12-21

- Add Yara rules from [Yara Forge](https://yarahq.github.io/). Currently available under *C:\data\packages\* in the directories *core*, *extended* and *full*.

## 2023-12-18

- Add [evtx_dump](https://github.com/omerbenamram/evtx)

## 2023-12-13

- Switch to own fork of [PatchaPalooza](https://github.com/reuteras/PatchaPalooza) to get updates for December 2023.

## 2023-12-11

- Update Python to 3.11.7

## 2023-12-08

- Add script *ipexpand.py* to the sandbox.
- Add *enrichment.ps1* that can be used to download lists of Tor exit nodes, Maxmind databases and more to be used in the sandbox during investigations. Data is stored in the folder *C:\Downloads\enrichment*.
- Download Elasticsearch, Kibana, Logstash and some beats.
- Add [sorairolake/qrtool](https://github.com/sorairolake/qrtool)

## 2023-12-05

- Add two Git repositories with sample files, [reuteras/dfirws-sample-files](https://github.com/reuteras/dfirws-sample-files) and [AndrewRathbun/DFIRArtifactMuseum](https://github.com/AndrewRathbun/DFIRArtifactMuseum)

## 2023-12-04

- Add [box-js](https://github.com/CapacitorSet/box-js)
- Add [pestudio](https://www.winitor.com/download)
- Add [Exeinfo Pe](https://github.com/ExeinfoASL/ASL)
- Add [email-analyzer.py](https://github.com/keraattin/EmailAnalyzer)
- Add [aLEAPP](https://github.com/abrignoni/aLEAPP)
- Add [iLEAPP](https://github.com/abrignoni/iLEAPP)
- Add [MFTBrowser](https://github.com/kacos2000/MFT_Browser)
- Add [RdpCacheStitcher](https://github.com/BSI-Bund/RdpCacheStitcher) by BSI
- Add [Sleuthkit](https://www.sleuthkit.org/sleuthkit/)
- Download [Velociraptor](https://github.com/Velocidex/velociraptor)
- Create new venv *dissect* and install package [dissect](https://www.fox-it.com/nl-en/dissect/) by FOX IT (NCCgroup)

Added Git repositories:
- <https://github.com/mattifestation/CimSweep.git>
- <https://github.com/swisscom/PowerSponse.git>
- <https://github.com/ahmedkhlief/APT-Hunter.git>

## 2023-12-02

- Add Iaito from Radareorg (Reversing tools)
- Log startup times to *C:\tmp\start_sandbox.log*
- Update [Jupyter notebooks](Jupyter-notebooks.md) for PE files

## 2023-11-28

- Update IO output limit for Jupyter Notebooks

## 2023-11-24

- Added [Ares](https://github.com/bee-san/Ares) as a replacement for ciphey. Ciphey is being [deprecated](https://github.com/Ciphey/Ciphey/issues/764).
- Added [Binary Refinary](https://github.com/binref/refinery/) via [pypi](https://pypi.org/project/binary-refinery/). [Documentation](https://binref.github.io/).

## 2023-11-23

- Added customization for Ghidra to [local/example-customize.ps1](https://github.com/reuteras/dfirws/blob/main/local/example-customize.ps1). If you already have a *local/customize.ps1* now is a good time to merge the updates into that file.
- A GoLang-extension for Ghidra is available for installation in *C:\Tools\ghidra_extensions*.

## Start

This file only contains changes from 2023-11-23 and onward.
