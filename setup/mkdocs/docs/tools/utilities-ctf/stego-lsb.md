# stego-lsb

**Category:** Utilities / CTF

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.png`, `.bmp`, `.wav`

**Tags:** steganography, audio

stegolsb steglsb -r -i stego.png -o out.bin -n 1

## Tips
Hides and recovers data in the least significant bits of PNG and WAV files. Try -n 1 to 4 bits when recovering unknown payloads.

## Usage
stegolsb steglsb -r -i stego.png -o out.bin -n 1
