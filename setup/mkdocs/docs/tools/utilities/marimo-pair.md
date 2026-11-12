# marimo-pair

**Category:** Utilities

**Homepage:** <https://github.com/marimo-team/marimo-pair>

**Vendor:** marimo-team

**License:** [Apache-2.0](https://github.com/marimo-team/marimo-pair/blob/main/LICENSE)

**Source:** Git

**Profiles:** Full, Basic

**Tags:** ai, python, automation

Agent skill that lets an AI agent such as opencode-ai run code inside a live marimo notebook session.

## Tips
Installed as an opencode-ai skill at startup. The skill scripts need bash, curl and jq on PATH: install Git first with dfirws-install.ps1 -Git and run opencode from Git Bash. Start marimo with --no-token so the scripts can discover the server. Use a local model by configuring a provider in opencode.json; remote models only work in the network enabled sandbox.

## Usage
marimo edit --no-token notebook.py, then ask opencode to pair on the notebook.

## Sample Commands
- `marimo edit --no-token notebook.py`
