# qpdf

**Category:** Files and apps / PDF

**Homepage:** <https://qpdf.sourceforge.io/>

**Vendor:** qpdf

**License:** Apache-2.0

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.pdf`

**Tags:** pdf, data-processing

qpdf: A content-preserving PDF document transformer

## Tips
Use --qdf --object-streams=disable to rewrite a PDF into a readable form before inspecting objects and --decrypt to remove owner passwords. qpdf never executes PDF content, so it is safe on malicious files.

## Usage
qpdf is a command-line tool and C++ library that performs content-preserving transformations on PDF files. It supports linearization, encryption, and numerous other features. It can also be used for splitting and merging files, creating PDF files (but you have to supply all the content yourself), and inspecting files for study or analysis. qpdf does not render PDFs or perform text extraction, and it does not contain higher-level interfaces for working with page contents. It is a low-level tool for working with the structure of PDF files and can be a valuable tool for anyone who wants to do programmatic or command-line-based manipulation of PDF files.
