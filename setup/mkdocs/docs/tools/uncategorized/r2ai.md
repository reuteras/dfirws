# r2ai

**Category:** Uncategorized

**Homepage:** <https://github.com/radareorg/r2ai>

**Vendor:** radareorg

**License:** MIT License

**Source:** Git

**File Extensions:** `.exe`, `.dll`, `.elf`, `.bin`, `.so`

**Tags:** reverse-engineering, ai, radare2

Native AI plugin for radare2. Compiled from source in the MSYS2 sandbox using gcc and pkg-config. Provides AI-assisted analysis using local and remote language models.

## Notes
Native AI plugin for radare2. Compiled from source in the MSYS2 sandbox using gcc and pkg-config. Provides AI-assisted analysis using local and remote language models.

## Tips
Set API keys via environment variables (ANTHROPIC_API_KEY, OPENAI_API_KEY) or edit ~/.config/r2ai/apikeys.txt with r2ai -K.

## Usage
Load automatically as a radare2 core plugin. Use r2ai commands within the radare2 shell for AI-assisted binary analysis.

## Sample Commands
- `r2ai -h`
