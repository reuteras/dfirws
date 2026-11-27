# Tool Inclusion Guidelines

**Status: draft.** These guidelines describe what DFIRWS looks for when deciding whether to add (or keep) a tool. They are guidance for discussion in issues and pull requests, not hard gates. A tool that misses one criterion can still be included if it is strong on the others and the reason is stated in the PR.

DFIRWS ships 400+ tools in an offline Windows Sandbox. Every tool adds download time, disk space, maintenance work and attack surface, so the bar is "would a DFIR analyst reasonably reach for this?", not "is it related to security?".

## Summary checklist

A new tool should meet most of these:

1. It does a DFIR job that is not already covered well by an included tool.
2. It is a de facto standard, or a well-regarded niche tool, or it fills a clear gap.
3. It is maintained, or it is stable and feature-complete.
4. It runs on Windows in the sandbox, offline by default. If it needs network access, that is clearly labeled (see [section 4](#4-works-in-the-sandbox)).
5. It can be obtained from a trustworthy, reproducible source.
6. Its license allows it to be downloaded and used by the end user.
7. It has complete metadata and a verification entry.

## 1. Purpose and fit

- The tool must support forensics, incident response, malware analysis, threat hunting, reverse engineering, or the infrastructure around them (viewers, editors, runtimes, enrichment data).
- Prefer tools that handle a specific artifact, file format or technique that analysts meet in real cases (EVTX, registry, memory, PE, Office, PDF, email, network captures, mobile backups, and so on).
- Overlap is fine, up to a point. Having two tools that do the same job is useful for **cross-validation**: analysts can check one parser's output against another's, and parsers do disagree. A new tool that overlaps an existing one should still add something, such as extra functionality, support for more formats or versions, a different approach (static vs. dynamic, GUI vs. CLI, AST-based vs. regex-based), or better output. Say what it adds in `Notes` or the PR.
- Avoid piling up. We do not need ten tools that do the same thing. When a category already has two or three solid options, a further one needs a strong reason: it is clearly better, or it is what analysts are commonly expected to know. A tool that adds nothing over the existing ones is a candidate for removal (see [section 10](#10-review-and-removal)).
- Offensive tooling is only in scope when it is mainly used for analysis, detection or authorized testing (for example, Cobalt Strike beacon parsers, not implants or payload generators).
- General productivity software is acceptable when it directly helps an analyst work in the sandbox (editors, browsers, terminals, diff tools). Keep this list short.

## 2. Maturity and reputation

Show at least one of the following:

- **De facto standard.** Widely used and referenced in DFIR training, vendor documentation, SANS material, blogs or conference talks (for example, Sysinternals, Zimmerman tools, Volatility, YARA, Wireshark, Ghidra).
- **Community-validated.** Meaningful adoption: stars, forks, dependents, packaging in other DFIR distributions (SIFT, REMnux, FLARE-VM), or recommendation by known practitioners.
- **Gap filler.** The only practical tool for a given format or task, even if small. Say so in `Notes`.

New, unproven or one-person experiments can be accepted when they are clearly useful. Mark them in `Notes` so users know what to expect, and expect them to be reviewed more critically later.

## 3. Maintenance status

Look at the upstream project when adding a tool, and again when reviewing the inventory.

| Signal | Preferred | Acceptable with justification | Avoid |
|--------|-----------|-------------------------------|-------|
| Last release or commit | Within the last 12 months | Older, but the tool is stable and complete (a small parser for a frozen format) | Abandoned and known to be broken |
| Repository state | Active | Maintenance mode | Archived, unless there is no alternative |
| Issues and PRs | Triaged | Slow responses | Ignored, with critical bugs open |
| Releases | Tagged versions | Rolling `main` for scripts and rule sets | Only unversioned snapshots of a binary |

The `Save-GitHubMetadata` helper in `resources/download/common.ps1` records `Archived`, stars, license and latest release. Use it instead of checking by hand.

Archived or unmaintained tools may stay when they are still the best option for their niche and still work. Put the status in `Notes`. Remove a tool when it no longer builds or runs, upstream has vanished, or a maintained replacement exists.

## 4. Works in the sandbox

The final sandbox is **offline**, runs as `WDAGUtilityAccount`, and mounts tools read-only. Before adding a tool, check that it:

- Runs on Windows 10/11 x64 and is useful **offline**, without an account, login or license server. Offline is the default, but see [Online tools](#online-tools) for the exception.
- Does not need installation into protected locations, drivers, or reboots. Portable or extractable tools are strongly preferred over installers.
- Does not need runtimes the sandbox lacks. Declare needed runtimes in `Dependencies` (`dotnet8`, `dotnet10`, `corretto25`, `nodejs`, `golang`, `msys2`, and so on). Prefer self-contained builds or one of the runtimes already shipped.
- Works with the sandbox's resources. Tools that need a GPU, large memory or a lot of disk should be optional, and are candidates for exclusion in the smaller profiles (see `local/defaults/profiles.ps1`).
- Has a way to verify the install, using a `Verify` entry that runs a harmless command (`--help`, `--version`) and checks the output.
- Does not phone home unexpectedly during normal use, or the call can be turned off.

### Online tools

Some tools are only useful with network access, such as lookups against external services (the VirusTotal CLI `vt`, MalwareBazaar search, Google Threat Intelligence examples), tools that fetch rules or data on demand, or tools that talk to remote hosts. These are fine to include when they are **clearly labeled**, so nobody sends data out of the sandbox by accident.

- Run them from the network sandbox (`network_dfirws.wsb`). The analysis sandbox has no network.
- Add `Dependencies = @("online")` to the metadata, as `malware-bazaar-advanced-search` does.
- Put lookup and reference tools in the `Signatures and information\Online tools` category, so the desktop shortcut and wiki entry sit with the other online tools.
- Say in `Notes` or `Tips` that the tool needs the network sandbox, and mention any API key or account it needs and where the key goes (for example `VTCLI_APIKEY` for `vt`, an abuse.ch auth key for MalwareBazaar).
- Warn about what leaves the sandbox. Prefer lookups by hash, which don't upload the sample, over uploads. For `vt`, `vt file <hash>` looks up a sample without sharing it, while an upload shares the sample with the VirusTotal community.
- Keep an offline mode if the tool has one (for example, a bundled data set), and say what works offline.
- Keys and accounts are supplied by the user. Never bundle credentials.

Online tools should complement the offline toolset, not replace an offline tool that does the same job.

Python packages should work on the default interpreter, or declare `PythonVersion` explicitly (see `Agents.md`). Check for removed standard library modules before moving a package to a newer Python.

## 5. Source and supply chain

Tools execute with analyst privileges next to sensitive evidence, so provenance matters.

Prefer sources in this order:

1. Official release assets from the upstream GitHub repository (`release.ps1`).
2. Official package registries: PyPI via uv, crates.io, npm, Go modules, winget.
3. Official vendor download pages (`http.ps1`).
4. A git clone of the upstream repository (`git.ps1`), for scripts, rule sets and documentation.

Requirements:

- Download from the **upstream** project or vendor. Do not use third-party mirrors, re-uploads or unofficial forks unless upstream is gone, and explain why.
- Use HTTPS. Verify hashes or signatures when upstream publishes them.
- The download must be scriptable and repeatable by the existing helpers (`Get-FileFromUri`, `Get-GitHubRelease`, `Get-DownloadUrlFromPage`). Avoid fragile page scraping when a stable URL or API exists.
- Pin or at least review dependency trees for packages built in the build sandboxes. Avoid packages with a history of typosquatting, ownership transfers or malicious releases.
- Do not include closed-source binaries from unknown authors. Closed-source tools from known vendors or well-known community authors are fine (for example, many classic Windows analysis utilities).

## 6. Licensing

DFIRWS does not redistribute tools. Each user downloads them directly from upstream, so license terms apply to the user, but they still matter.

- Open-source licenses (MIT, BSD, Apache-2.0, GPL, LGPL, AGPL, Unlicense) are fine. Record the real SPDX-style name in `License`, not "See repository", whenever it can be found.
- Freeware and "free for non-commercial use" tools are acceptable if the restriction is stated in `License` and `Notes`. Users in commercial or corporate IR should be able to see the restriction before they rely on the tool.
- Commercial software that needs a purchased license is only acceptable as an opt-in the user supplies (the pattern used for KAPE: it is only handled if the user puts `kape.zip` in `local/`). Never bundle license keys.
- Data feeds that need an account or key (MaxMind, IPinfo, abuse.ch) must be opt-in through `dfirws-config.ps1` and the requirement stated in `Notes`.
- If the license forbids automated download or redistribution of the binaries, do not add automation. Document a manual procedure instead.

## 7. Safety and handling

- Tools must not be malware, nor ship malware as part of normal operation. Some tools legitimately include samples or rule strings that antivirus flags. Mention this in `Notes` and keep sample sets separate (`dfirws-sample-files`, `EVTX-ATTACK-SAMPLES`).
- Review what a new tool does on first run: network connections, telemetry, auto-updaters, file writes outside the working directory. Disable or document these.
- Avoid tools that require disabling Windows security features to run, or that install kernel drivers (live-acquisition drivers are the one exception, and need discussion first).

## 8. Metadata requirements

A tool is not complete until its `TOOL_DEFINITIONS` entry is. `scripts/validate-tool-metadata.ps1` runs in CI, and these fields are expected:

- `Name`, `Homepage`, `Vendor`, `License` (and `LicenseUrl` when available).
- `Category` from the canonical list, and 2-6 `Tags` from the canonical list. See [categories-and-tags.md](categories-and-tags.md).
- `Notes` with a one- or two-sentence description. Include maintenance status, opt-in requirements or licensing limits when relevant.
- `Tips`, `Usage` and `SampleCommands` where they help someone use the tool offline.
- `FileExtensions` when the tool is tied to specific formats.
- `Verify` entries and, when needed, `InstallVerifyCommand`.
- `Dependencies` for runtimes and other tools it needs, including `"online"` for tools that need the network sandbox.
- `Shortcuts` placed in the right desktop category folder, so the `Category` matches.

Use `scripts/update-tool-metadata.ps1` to fill empty `Homepage`, `Vendor` and `License` fields.

## 9. Proposing a tool

Open an issue or PR that answers these questions:

1. What does the tool do, and which DFIR task does it serve?
2. Which included tools overlap, and why is this one needed?
3. Why is it trustworthy and maintained? Give a link, last release date and a rough adoption signal.
4. Where is it downloaded from, and which download helper fits?
5. What are the license terms?
6. Does it run offline in the sandbox? Say what you tested and on what.
7. What does it cost in size, in build time and in dependencies? Should it be excluded from the Basic profile?

## 10. Review and removal

Periodically (for example, once or twice a year, or when a tool breaks) review the inventory against these guidelines. A tool becomes a removal candidate when:

- Its download or build fails repeatedly and upstream has not fixed it.
- Upstream is archived or gone and a maintained alternative exists.
- It has been superseded by an included tool that does the same job better and adds nothing of its own, such as extra functionality or a useful second opinion for cross-validation.
- Its license changes in a way that prevents use by the intended audience.
- It is found to be unsafe, trojanized or tampered with.

Removal should be announced in the changelog. Where it is practical, mention the replacement.

## Examples

These examples show how the criteria apply to tools already in DFIRWS. They are illustrative, not a ruling on any tool.

| Tool type | Example | Why it fits |
|-----------|---------|-------------|
| De facto standard, open source | [Volatility 3](https://github.com/volatilityfoundation/volatility3), [YARA](https://virustotal.github.io/yara/), [Ghidra](https://ghidra-sre.org/), [Wireshark](https://www.wireshark.org/) | Widely taught and used, active, offline-capable |
| De facto standard, free and closed source | [Sysinternals](https://learn.microsoft.com/en-us/sysinternals/), [Eric Zimmerman's tools](https://ericzimmerman.github.io/) | Known vendor or author, scriptable official download, free for the intended use |
| Community-validated tool | [Chainsaw](https://github.com/WithSecureLabs/chainsaw), [Hayabusa](https://github.com/Yamato-Security/hayabusa), [capa](https://github.com/mandiant/capa) | Active, popular in the community, covers a specific task. Chainsaw and Hayabusa overlap, which is useful for cross-validation |
| Gap filler | Small parsers for a single format or artifact, such as [bmc-tools](https://github.com/ANSSI-FR/bmc-tools) | Unique function, low cost to carry |
| Rule sets and data | [sigma](https://github.com/SigmaHQ/sigma), [signature-base](https://github.com/Neo23x0/signature-base) | Maintained upstream, updated on each download |
| Opt-in commercial or keyed | [KAPE](https://www.kroll.com/en/insights/publications/cyber/kroll-artifact-parser-extractor-kape), [MaxMind GeoLite2](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data) | User supplies the license or key, so DFIRWS never ships it |
| Online (network sandbox) | [vt (VirusTotal CLI)](https://github.com/VirusTotal/vt-cli), [gti-dev-kit](https://github.com/VirusTotal/gti-dev-kit) | Need the network sandbox and an API key. Clearly labeled, and hash lookups are preferred over uploads |

## References

Project documents:

- [Agents.md](../Agents.md): architecture, `TOOL_DEFINITIONS` format, download scripts and build sandboxes.
- [categories-and-tags.md](categories-and-tags.md): canonical categories, tags and source types.
- [README](../README.md): overview, profiles, and how to build and run the sandbox.
- `resources/download/common.ps1`: download helpers and `Save-GitHubMetadata`.
- `local/defaults/profiles.ps1`: profile definitions and the tools each profile excludes.
- `scripts/validate-tool-metadata.ps1`: the metadata lint that runs in CI.
- `scripts/update-tool-metadata.ps1`: fills empty `Homepage`, `Vendor` and `License` fields.

External:

- [DFIRWS repository](https://github.com/reuteras/dfirws) and [published tool wiki](https://reuteras.github.io/dfirws/tools/).
- [SPDX license list](https://spdx.org/licenses/) for the `License` field.
- [Windows Sandbox documentation](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/) for sandbox limits and configuration.
