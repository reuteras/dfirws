# Forensics

| Tool | Source | Description | Tags | File Extensions | Profiles |
| --- | --- | --- | --- | --- | --- |
| [Autopsy](autopsy.md) | GitHub Release | Autopsy is a digital forensics platform that allows users to analyze disk images and extract artifacts from them. It provides a graphical user interface for examining file systems, recovering deleted files, and analyzing network traffic. | disk-forensics, forensics, gui, artifact-extraction | `.dd`, `.raw`, `.E01`, `.img`, `.vmdk` | Full only |
| [DFIRArtifactMuseum](dfirartifactmuseum.md) | Git | The goal of this repo is to archive artifacts from all versions of various OS's and categorizing them by type. This will help with artifact validation processes as well as increase access to artifacts that may no longer be readily available anymore. | forensics, artifact-extraction, documentation |  |  |
| [PyrsistenceSniper](pyrsistencesniper.md) | Python | Point it at a KAPE dump, a Velociraptor collection, or a mounted disk image and get offline Windows persistence detection in seconds. No live system access, no admin privileges, no PowerShell. Runs on Windows, Linux, and macOS because investigators don't always get to pick their workstation. | malware-analysis, forensics, ioc, data-extraction, enrichment |  |  |
| [RDPCacheStitcher](rdpcachestitcher.md) | GitHub Release | RdpCacheStitcher is a tool for analyzing RDP cache files. | network, forensics, windows | `.bmc`, `.bin` |  |
| [White-Phoenix](white-phoenix.md) | Git | A tool to recover content from files encrypted with intermittent encryption | ransomware, decryption, data-recovery |  | Full only |
| [acquire](acquire.md) | Python |  | forensics, incident-response, acquisition, disk-forensics | `.tar` |  |
| [artemis](artemis.md) | GitHub Release | Artemis is a tool for extracting and analyzing Windows artifacts. It can be used for triage and forensic analysis of Windows systems, allowing investigators to quickly gather information about the system and its activity. | forensics, artifact-extraction, triage | `.exe`, `.dll`, `.evtx`, `.reg` |  |
| [autopsy_addon_modules](autopsy-addon-modules.md) | Git | Collection of third-party add-on modules for Autopsy — ingest modules, content viewers, report modules, and data source processors. | forensics, disk-forensics, plugins, documentation |  |  |
| [binary-refinery](binary-refinery.md) | Python | The Binary Refinery is a collection of Python scripts that implement transformations of binary data such as compression and encryption. We will often refer to it simply by refinery, which is also the name of the corresponding package. | malware-analysis, deobfuscation, data-extraction, scripting | `.exe`, `.dll`, `.bin` |  |
| [cart](cart.md) | Python | Compressed and RC4 Transport (CaRT) Neutering format. This is a file format that is used to neuter malware files for distribution in the malware analyst community. | malware-analysis | `.cart` |  |
| [dfirws-sample-files](dfirws-sample-files.md) | Git | Sample files to test forensics tools. | forensics |  |  |
| [dissect](dissect.md) | Python |  | forensics, incident-response, data-extraction | `.dd`, `.raw`, `.tar` |  |
| [dissect.target](dissect-target.md) | Python |  | forensics, incident-response, artifact-extraction | `.dd`, `.raw`, `.tar`, `.vmdk`, `.E01` |  |
| [flow.record](flow-record.md) | Python |  | forensics, data-processing | `.rec` |  |
| [msticpy](msticpy.md) | Python |  | threat-intelligence, incident-response, python | `.json`, `.csv` |  |
| [one-extract](one-extract.md) | Git | Python library for extracting objects from OneNote files. | forensics, office, data-extraction |  |  |
| [pathlab](pathlab.md) | Python |  | forensics, filesystem |  |  |