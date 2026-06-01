# Tools missing from the changelog

This document lists tools installed by dfirws that are **not yet tracked** in the
automated changelog (`downloads/CHANGELOG.md`). The changelog currently covers
tools installed via GitHub releases, winget, npm, and uv tools
(`uv tool install`).

## Go tools (`go install @latest`)

Version is not captured at install time; `go version -m <binary>` can read the
embedded version from the compiled binary after install, but no metadata write has
been added yet.

| Tool | Install script | Module path |
|------|---------------|-------------|
| govulncheck | `setup/install/install_golang_tools.ps1` | `golang.org/x/vuln/cmd/govulncheck` |
| protodump | `setup/install/install_golang_tools.ps1` | `github.com/arkadiyt/protodump/cmd/protodump` |

## Rust / Cargo tools (`cargo install`)

`cargo install` does not write a machine-readable version file by default.
`cargo install --list` can report installed versions after the fact.

| Tool | Install script |
|------|---------------|
| dfir-toolkit | `setup/install/install_rust_tools.ps1` |
| usnjrnl | `setup/install/install_rust_tools.ps1` |
| CuTE-tui | `setup/install/install_rust_tools.ps1` |
| cargo-audit | `setup/install/install_rust_tools.ps1` (optional) |

## Python venv packages (`uv pip install -U` / `uv venv`)

These are library/runtime packages installed into shared or per-tool virtual
environments rather than as standalone `uv tool` entries. Tracking individual
library versions would produce very noisy changelogs; consider tracking only
the venv-level tools that have CLI entry points.

| Environment | Script |
|-------------|--------|
| `C:\venv\default` (≈70 packages) | `setup/install/install_python_tools.ps1` |
| `C:\venv\dfir-unfurl` | `setup/install/install_python_tools.ps1` |
| `C:\venv\speakeasy` (pip) | `setup/install/install_python_tools.ps1` |
| `C:\venv\white-phoenix` (optional) | `setup/install/install_python_tools.ps1` |
| `C:\venv\Kanvas` (optional) | `setup/install/install_python_tools.ps1` |
| `C:\venv\gostringungarbler` | `setup/install/install_python_tools.ps1` |
| `C:\venv\pe2pic` | `setup/install/install_python_tools.ps1` |
| `C:\venv\evt2sigma` (optional) | `setup/install/install_python_tools.ps1` |
| `C:\venv\scare` | `setup/install/install_python_tools.ps1` |
| `C:\venv\zircolite` | `setup/install/install_python_tools.ps1` |

## Direct HTTP downloads

Tools fetched via plain URL are now **partially tracked** via `tools_downloaded.csv`.
The changelog compares the URL from the previous run against the current URL:

- If the URL changed and contains a version string (e.g. `/v1.2.3/`), the old and
  new versions are shown.
- If the URL changed but contains no parseable version, the entry is flagged as
  "updated (version not available in URL)" and both URLs are shown.
- If the URL is unchanged (mutable URL, file content may have changed silently),
  no entry is generated. This is a known gap.

Tools fetched **inside the sandbox** (raw GitHub scripts downloaded by
`install_python_tools.ps1`) are not in `tools_downloaded.csv` and therefore
not tracked at all:

| Tool | Location |
|------|----------|
| machofile-cli.py | `setup/install/install_python_tools.ps1` (raw GitHub) |
| msidump.py | `setup/install/install_python_tools.ps1` (raw GitHub) |
| shellconv.py | `setup/install/install_python_tools.ps1` (raw GitHub) |
| smtpsmug.py | `setup/install/install_python_tools.ps1` (raw GitHub) |
| SQLiteWalker.py | `setup/install/install_python_tools.ps1` (raw GitHub) |
| CanaryTokenScanner.py | `setup/install/install_python_tools.ps1` (raw GitHub) |
| sigs.py | `setup/install/install_python_tools.ps1` (raw GitHub) |
| defender-dump.py | `setup/install/install_python_tools.ps1` (raw GitHub) |
| Various (pe2pic, evt2sigma scripts) | `setup/install/install_python_tools.ps1` (raw GitHub) |

## MSYS2 packages (`pacman -S`)

Version tracking would require querying `pacman -Q` after install.
See `setup/install/install_msys2.ps1`.

## npm project installs (`npm install` inside a project directory)

LUMEN is cloned from GitHub and built locally — its version comes from the
repository, not from the npm registry, so `npm list` does not report a useful
version. Tracked via the GitHub metadata path instead if the repo is listed.
