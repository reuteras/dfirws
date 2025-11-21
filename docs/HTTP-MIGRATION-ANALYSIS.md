# HTTP.ps1 Migration Analysis

## Overview

Analysis of `http.ps1` to determine migration path to v2 YAML architecture.

**Date**: 2025-11-17
**Current State**: http.ps1 contains 75 Get-FileFromUri calls
**Goal**: Migrate to YAML or eliminate duplication

---

## Key Findings

### 1. Significant Duplication Found

Many tools in `http.ps1` are **already defined in YAML files**:

| Tool | http.ps1 | YAML File | Status |
|------|----------|-----------|--------|
| **TrID** | ✅ Line 106 | document-analysis.yaml:11 | ⚠️ DUPLICATE |
| **TrIDDefs** | ✅ Line 110 | document-analysis.yaml:21 | ⚠️ DUPLICATE |
| **Malcat** | ✅ Line 116 | document-analysis.yaml:156 | ⚠️ DUPLICATE |
| **PSTWalker** | ✅ Line 137 | email-forensics.yaml | ⚠️ DUPLICATE |
| **ExifTool** | ✅ Line 74 | utilities.yaml | ⚠️ DUPLICATE |

### 2. Unique HTTP Downloads

The following appear to be unique to http.ps1:

#### VSCode Extensions (Marketplace API)
- `vscode-cpp.vsix` - C++ extension
- `vscode-python.vsix` - Python extension
- `vscode-mermaid.vsix` - Mermaid extension
- `vscode-ruff.vsix` - Ruff extension
- **Reason**: Downloaded from VS Marketplace API, not GitHub releases

#### Direct HTTP Tools
- **VSCode**: update.code.visualstudio.com
- **Sysinternals Suite**: download.sysinternals.com
- **PEStudio**: www.winitor.com
- **HxD**: mh-nexus.de
- **SSView**: www.mitec.cz
- **FullEventLogView**: www.nirsoft.net (NirSoft tool)
- **WinApiSearch**: dennisbabkin.com
- **Sysmon Config**: SwiftOnSecurity GitHub (raw file)

#### Special Cases
- Various installers (MSI, EXE files)
- Configuration files
- Tools without GitHub releases

### 3. Source Domains

HTTP downloads come from 34 unique domains:
- `marketplace.visualstudio.com` - VSCode extensions
- `download.sysinternals.com` - Microsoft tools
- `www.nirsoft.net` - NirSoft utilities
- `www.mitec.cz` - Mitec tools
- `exiftool.org`, `malcat.fr`, `mark0.net` - Individual tool sites
- Many others (see full list below)

---

## Migration Categories

### Category A: Already in YAML (Remove from http.ps1)
These are duplicates and should be removed from http.ps1:
- TrID, TrIDDefs
- Malcat
- PSTWalker
- ExifTool
- *(Need full audit)*

### Category B: Can Migrate to YAML
HTTP downloads that can be added to YAML with `source: http`:
- Sysinternals Suite
- PEStudio
- HxD
- SSView
- FullEventLogView
- WinApiSearch
- *(Many more - need full list)*

### Category C: Special Handling Required
Tools that need custom handling:
- **VSCode Extensions**: Marketplace API requires dynamic version lookup
- **Installers**: MSI/EXE files that need installation, not extraction
- **Raw Files**: Single-file downloads (configs, scripts)

### Category D: Keep in http.ps1
Items that should remain:
- VSCode marketplace extensions (complex API)
- Special installers with unique logic
- Dynamic version lookups

---

## Recommendation

### Phase 1: Identify & Remove Duplicates
1. Audit all http.ps1 downloads
2. Check against all YAML files
3. Remove duplicates from http.ps1
4. **Estimated**: Remove 15-20 duplicate downloads

### Phase 2: Migrate HTTP-Only Tools to YAML
1. Add `source: http` support to YAML (already exists)
2. Migrate straightforward HTTP downloads
3. **Estimated**: Migrate 30-40 tools to YAML

### Phase 3: Consolidate Special Cases
1. Keep VSCode marketplace logic in http.ps1
2. Keep complex installers in http.ps1
3. Document why they remain
4. **Estimated**: Keep 10-15 downloads in http.ps1

### Expected Result
- **Before**: 75 downloads in http.ps1
- **After**: 10-15 downloads in http.ps1 (80% reduction)
- **YAML**: Add 30-40 HTTP downloads to YAML
- **Eliminated**: 15-20 duplicates

---

## Implementation Plan

### Step 1: Audit (1-2 hours)
```powershell
# Extract all http.ps1 downloads
# Cross-reference with YAML files
# Create comprehensive mapping
```

### Step 2: Remove Duplicates (30 min)
```powershell
# Comment out or remove duplicate downloads
# Test that YAML versions work
```

### Step 3: Migrate to YAML (2-3 hours)
```yaml
# Add HTTP downloads to appropriate YAML files
# Example:
tools:
  - name: sysinternals-suite
    source: http
    url: "https://download.sysinternals.com/files/SysinternalsSuite.zip"
    file_type: zip
    install_method: extract
    extract_to: "${TOOLS}/sysinternals"
```

### Step 4: Test (1 hour)
```powershell
.\downloadFiles.ps1 -Http  # Should still work
.\downloadFiles.ps1 -AllTools  # Full test
```

### Step 5: Document (30 min)
- Update http.ps1 comments
- Document why remaining items stay
- Update V2-INTEGRATION-STATUS.md

---

## Benefits

### Code Reduction
- **Before**: ~515 lines in http.ps1
- **After**: ~100-150 lines in http.ps1
- **Reduction**: 70-80% fewer lines

### Consistency
- ✅ More tools managed by YAML
- ✅ Consistent installation patterns
- ✅ Better maintainability

### Clarity
- ✅ Clear separation: YAML (most tools) vs http.ps1 (special cases)
- ✅ Documented reasons for exceptions
- ✅ Easier to understand architecture

---

## Risks & Mitigation

### Risk 1: Breaking Existing Workflows
- **Mitigation**: Keep http.ps1 parameter working
- **Mitigation**: Test thoroughly before removing

### Risk 2: Missing Dependencies
- **Mitigation**: Audit carefully
- **Mitigation**: Test each tool after migration

### Risk 3: VSCode Extension Complexity
- **Mitigation**: Keep marketplace logic in http.ps1
- **Mitigation**: Don't migrate complex cases

---

## Full Domain List

Downloads come from these domains:
```
aka.ms
archive.org
artifacts.elastic.co
bitbucket.org
cdn.binary.ninja
dennisbabkin.com
download.sysinternals.com
download2.gluonhq.com
downloads.pstwalker.com
exiftool.org
files.gpg4win.org
flatassembler.net
github.com
hashcat.net
malcat.fr
mandiant.github.io
mark0.net
marketplace.visualstudio.com
mh-nexus.de
neo4j.com
npcap.com
openvpn.net
procdot.com
raw.githubusercontent.com
sandsprite.com
sqlite.org
update.code.visualstudio.com
windows.php.net
www.mitec.cz
www.nirsoft.net
www.osforensics.com
www.rohitab.com
www.torproject.org
www.winitor.com
```

---

## Next Actions

1. ✅ Create this analysis document
2. [ ] Create GitHub issue for http.ps1 migration
3. [ ] Perform detailed audit of all 75 downloads
4. [ ] Create migration PR (duplicates removal)
5. [ ] Create migration PR (YAML additions)
6. [ ] Update documentation

---

**Last Updated**: 2025-11-17
**Status**: Analysis Complete, Ready for Implementation
