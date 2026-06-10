# Changelog coverage

This document tracks which installed tools are covered by the automated
changelog (`downloads/CHANGELOG.md`) and which are deliberately excluded.

## Tracked sources

| Source | Mechanism | Metadata location |
|--------|-----------|-------------------|
| GitHub releases | `Save-GitHubRepoMetadata` (release tag) | `downloads/.metadata/github/` |
| winget | `Save-WingetMetadata` (`winget show`) | `downloads/.metadata/winget/` |
| npm (global) | `Save-NpmMetadata` (`npm list --global`) | `mount/Tools/.metadata/npm/` |
| uv tools | `Save-UvToolMetadata` (`uv tool list`) | `mount/Tools/.metadata/uv/` |
| Cargo tools | `Save-CargoToolMetadata` (`cargo install --list`) | `mount/Tools/.metadata/cargo/` (via `C:\log`, copied by `resources/download/rust.ps1`) |
| Go tools | `Save-GoToolMetadata` (`go version -m`) | `mount/Tools/.metadata/go/` (via `C:\log`, copied by `resources/download/go.ps1`) |
| MSYS2 (explicit packages) | `Save-Msys2Metadata` (`pacman -Q`) | `mount/Tools/.metadata/msys2/` |
| Raw script downloads | `Get-RawGitHubFile` (SHA256 content hash as version) | `mount/Tools/.metadata/raw/` |
| Python venv packages | `Save-VenvPackageMetadata` (`uv pip list`) per venv | `mount/Tools/.metadata/pip/` |
| Direct HTTP downloads | URL + etag snapshot from `tools_downloaded.csv` and `downloads/.etag/` | `downloads/.changelog/http_snapshot.json` |

Notes on specific tools:

- **SSHniff** is built from a git checkout, so its tracked version is the short
  commit hash.
- Raw script downloads (machofile-cli.py, msidump.py, shellconv.py, smtpsmug.py,
  SQLiteWalker.py, CanaryTokenScanner.py, sigs.py, defender-dump.py, pe2pic.py,
  evt2sigma.py) come from mutable branch URLs, so the version is a content hash
  and the changelog reports "updated (content changed)".
- Direct HTTP downloads with mutable URLs are detected via the cached etag: if
  the URL is unchanged but the etag differs, the changelog reports
  "updated (content changed, same URL)". Servers that do not return an etag
  remain undetectable when the URL stays the same.

## The changelog ignore list

All packages in every virtual environment (`C:\venv\default`,
`C:\venv\dfir-unfurl`, `C:\venv\speakeasy`, `C:\venv\white-phoenix`,
`C:\venv\Kanvas`, `C:\venv\gostringungarbler`, `C:\venv\pe2pic`,
`C:\venv\evt2sigma`, `C:\venv\scare`, `C:\venv\zircolite`) are recorded, keyed
per venv (the changelog shows e.g. `pip: default/oletools`). Many of these are
relevant DFIR tools (flare-capa, oletools, dissect, sigma-cli, capstone, ...),
so they are tracked - but pure library dependencies would drown the changelog
in noise. Those are filtered out via an ignore list:

- `local/defaults/changelog-ignore.txt` - defaults shipped with dfirws
- `local/changelog-ignore.txt` - your own additions (merged with the defaults)

One entry per line. A plain name applies to every source; a `source:` prefix
(e.g. `pip:six`) limits it. Matching is case-insensitive and `_` equals `-`.
The list works for all changelog sources, so a noisy GitHub/winget/msys2 entry
can be silenced the same way.

## Deliberately excluded

### MSYS2 dependency packages

Only the explicitly requested packages (see `$MSYS2_PACKAGES` in
`setup/install/install_msys2.ps1`) plus `msys2-runtime` are tracked. The full
`pacman -Q` output lists hundreds of transitive dependencies.

### npm project installs (`npm install` inside a project directory)

LUMEN is cloned from GitHub and built locally — its version comes from the
repository, not from the npm registry, so `npm list` does not report a useful
version. Tracked via the GitHub metadata path instead if the repo is listed.
