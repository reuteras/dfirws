# uv

**Category:** Programming / Python

**Homepage:** <https://docs.astral.sh/uv/>

**Vendor:** Astral

**License:** MIT and Apache-2

**Source:** Installer

**Profiles:** Full, Basic

**File Extensions:** `.py`

**Tags:** python

uv is a fast Python package installer and manager. It can be used to create and manage virtual environments, install packages, and run Python scripts. It is designed to be a faster and more efficient alternative to pip and virtualenv.

## Tips
uv builds all Python tools in the Python sandbox and is available in the analysis sandbox for throwaway environments (uv venv, uv pip). The analysis sandbox is offline, so only packages already in the uv cache under C:\venv\cache can be installed.

## Usage
uv pip install <package>
