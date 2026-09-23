# msoffcrypto-tool

**Category:** Files and apps / Office

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.doc`, `.docx`, `.xls`, `.xlsx`, `.ppt`, `.pptx`

**Tags:** office, encryption, decryption

Python tool and library for decrypting and encrypting MS Office files using a password or other keys

## Tips
Decrypts password protected Office files (including the default VelvetSweatshop password) so olevba and oledump can analyse them. Use -t to test whether a file is encrypted.

## Usage
msoffcrypto-tool -p <password> encrypted.docx decrypted.docx
