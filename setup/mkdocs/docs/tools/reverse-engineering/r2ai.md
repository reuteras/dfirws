# r2ai

**Category:** Reverse Engineering

**Homepage:** <https://github.com/radareorg/r2ai>

**Vendor:** radareorg

**License:** MIT License

**Source:** Git

**Profiles:** Full, Basic

**File Extensions:** `.exe`, `.dll`, `.elf`, `.bin`, `.so`

**Tags:** reverse-engineering, ai

Native AI plugin for radare2. Compiled from source in the MSYS2 sandbox using gcc and pkg-config. Provides AI-assisted analysis using local and remote language models.

## Tips
Configure an API key or a local model before use. The analysis sandbox is offline, so remote models only work in the network enabled sandbox. See decai for AI assisted decompilation inside radare2.

## Usage
r2ai -h (inside radare2: r2ai -m to choose a model)

## Sample Commands
- `r2ai -h`
