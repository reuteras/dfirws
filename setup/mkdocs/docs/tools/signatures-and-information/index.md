# Signatures and information

| Tool | Source | Description | Tags | File Extensions | Profiles |
| --- | --- | --- | --- | --- | --- |
| [Loki](loki.md) | GitHub Release | Loki - Simple IOC and YARA Scanner | malware-analysis, ioc-scanner, yara, detection | `.exe`, `.dll`, `.bin` |  |
| [MSRC](msrc.md) | Git | Data from Microsoft patch tuesdays. | vulnerability, windows |  |  |
| [PatchaPalooza](patchapalooza.md) | Git | A comprehensive tool that provides an insightful analysis of Microsoft's monthly security updates. | vulnerability, windows, binary-diffing |  |  |
| [Shadow-Pulse](shadow-pulse.md) | Git | Information about ransomware groups (Ransomware Analysis Notes) | threat-intelligence, ioc |  |  |
| [YARA](yara.md) | GitHub Release | YARA is a tool for identifying and classifying malware. | yara, malware-analysis, detection, detection-rules | `.yar`, `.yara`, `.exe`, `.dll`, `.bin` |  |
| [chainsaw-rules](chainsaw-rules.md) | Git | A set of custom Chainsaw rules for event log threat hunting. | sigma, detection-rules |  |  |
| [god-mode-rules](god-mode-rules.md) | Git | God Mode Detection Rules | yara, sigma, detection-rules |  |  |
| [legacy-sigmatools](legacy-sigmatools.md) | Git | Legacy Sigma Tools (sigmac etc.) | sigma, detection-rules |  |  |
| [mkyara](mkyara.md) | Python | mkyara -i <file> -s <start offset> -e <end offset> | yara, detection-rules, malware-analysis | `.exe`, `.dll`, `.bin` |  |
| [ppdeep](ppdeep.md) | Python | import ppdeep | hashing, fuzzy-hashing, binary-diffing |  |  |
| [pySigma-backend-loki](pysigma-backend-loki.md) | Python | sigma convert -t loki <rules dir> | sigma, detection | `.yml`, `.yaml` |  |
| [pysigma-backend-elasticsearch](pysigma-backend-elasticsearch.md) | Python | sigma convert -t lucene <rules dir> | sigma, detection, log-analysis, search | `.yml`, `.yaml` |  |
| [pysigma-backend-splunk](pysigma-backend-splunk.md) | Python | sigma convert -t splunk <rules dir> | sigma, detection, siem | `.yml`, `.yaml` |  |
| [pysigma-backend-sqlite](pysigma-backend-sqlite.md) | Python | sigma convert -t sqlite <rules dir> | sigma, detection, sqlite | `.yml`, `.yaml` |  |
| [pysigma-pipeline-sysmon](pysigma-pipeline-sysmon.md) | Python | sigma convert -t <target> -p sysmon <rules dir> | sigma, detection, event-log, windows | `.yml`, `.yaml` |  |
| [pysigma-pipeline-windows](pysigma-pipeline-windows.md) | Python | sigma convert -t <target> -p windows-logsources <rules dir> | sigma, detection, windows | `.yml`, `.yaml` |  |
| [sigma](sigma.md) | Git | Main Sigma Rule Repository | sigma, detection-rules, siem |  |  |
| [sigma-cli](sigma-cli.md) | Python | sigma convert -t <target> -p <pipeline> <rules dir> | sigma, detection, log-analysis | `.yml`, `.yaml` |  |
| [signature-base](signature-base.md) | Git | YARA signature and IOC database for my scanners and tools. | yara, detection-rules, ioc | `.yara` |  |
| [threat-intel](threat-intel.md) | Git | Signatures and IoCs from public Volexity blog posts. | threat-intelligence, ioc |  |  |
| [yara-python](yara-python.md) | Python | import yara; rules = yara.compile('rules.yar') | yara, malware-analysis, detection | `.yar`, `.yara` |  |
| [yara-x](yara-x.md) | GitHub Release | yara-x is a faster and more flexible version of YARA. | yara, malware-analysis, detection, detection-rules | `.yar`, `.yara`, `.exe`, `.dll`, `.bin` |  |
| [yq](yq.md) | GitHub Release | yq is a portable command-line YAML, JSON, XML, CSV, TOML and properties processor. | yaml, data-processing, cli | `.yaml`, `.yml`, `.json`, `.xml`, `.toml` |  |