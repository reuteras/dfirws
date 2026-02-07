#!/usr/bin/env python3
"""Extract tool metadata from GitHub cache, winget cache, and PyPI API.

Reads cached metadata produced during downloads (by Save-GitHubRepoMetadata and
Save-WingetMetadata in common.ps1) and queries the PyPI JSON API for Python
packages. Outputs tools_release.json, tools_winget.json, and tools_python.json
in the same format consumed by generate-tools-docs.py.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
import urllib.request
import urllib.error
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def write_tools_json(output_dir: Path, source: str, tools: List[dict]) -> Path:
    doc = {
        "GeneratedAt": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S"),
        "SourceScript": f"resources/download/{source}.ps1",
        "Tools": tools,
    }
    out = output_dir / f"tools_{source}.json"
    out.write_text(json.dumps(doc, indent=2, ensure_ascii=False), encoding="utf-8")
    return out


def safe_get(d: dict, *keys, default=None):
    for k in keys:
        if d is None:
            return default
        d = d.get(k) if isinstance(d, dict) else default
    return d if d is not None else default


def normalize_package_name(name: str) -> str:
    """Strip extras and version specifiers to get the base package name."""
    name = re.split(r"[\[>=<!\s]", name)[0]
    return name.strip().strip('"').strip("'")


# ---------------------------------------------------------------------------
# GitHub metadata -> tools_release.json
# ---------------------------------------------------------------------------

def github_topics_to_category(topics: list) -> str:
    """Map GitHub topics to a dfirws tool category."""
    if not topics:
        return "Uncategorized"
    topic_set = {t.lower() for t in topics}

    category_map = [
        ({"forensics", "dfir", "digital-forensics", "incident-response"}, "Forensics"),
        ({"malware", "malware-analysis", "reverse-engineering", "disassembler", "decompiler"}, "Reverse Engineering"),
        ({"network", "networking", "pcap", "packet-capture", "wireshark"}, "Network"),
        ({"pe", "elf", "binary-analysis", "executable"}, "Files And Apps PE"),
        ({"pdf", "pdf-analysis"}, "Files And Apps PDF"),
        ({"office", "oletools", "maldoc"}, "Files And Apps Office"),
        ({"email", "email-analysis"}, "Files And Apps Email"),
        ({"database", "sqlite", "sql"}, "Files And Apps Database"),
        ({"browser", "chrome", "firefox"}, "Files And Apps Browser"),
        ({"memory", "memory-forensics", "volatility"}, "Memory"),
        ({"registry", "windows-registry"}, "OS Windows Registry"),
        ({"windows", "windows-forensics"}, "OS Windows"),
        ({"android", "mobile-forensics"}, "OS Android"),
        ({"log", "logging", "log-analysis", "evtx", "syslog"}, "Logs"),
        ({"crypto", "cryptography", "encryption"}, "Utilities Cryptography"),
        ({"editor", "hex-editor", "text-editor"}, "Editors"),
        ({"development", "developer-tools", "programming"}, "Development"),
        ({"utility", "tool", "cli"}, "Utilities"),
        ({"security", "cybersecurity", "infosec"}, "Security"),
    ]

    for keywords, category in category_map:
        if topic_set & keywords:
            return category
    return "Uncategorized"


def build_github_tool(meta: dict) -> dict:
    """Convert cached GitHub metadata into a tool definition."""
    repo = meta.get("Repo", "")
    name = meta.get("Name", repo.split("/")[-1] if "/" in repo else repo)
    description = meta.get("Description") or ""
    homepage = meta.get("Homepage") or meta.get("HtmlUrl") or ""
    owner = meta.get("Owner") or ""
    topics = meta.get("Topics") or []

    license_name = safe_get(meta, "License", "Name", default="")
    license_spdx = safe_get(meta, "License", "SpdxId", default="")
    license_url = safe_get(meta, "License", "Url", default="")
    # GitHub license API URLs point to api.github.com — convert to human-readable
    if license_url and "api.github.com" in license_url:
        license_url = f"https://github.com/{repo}/blob/main/LICENSE"

    # Use SPDX ID as license name if the display name is generic
    license_display = license_name
    if license_spdx and license_spdx != "NOASSERTION" and license_name in ("Other", ""):
        license_display = license_spdx

    release = meta.get("LatestRelease") or {}
    version = release.get("TagName") or ""

    notes = description

    category = github_topics_to_category(topics)

    return {
        "Name": name,
        "Homepage": homepage,
        "Vendor": owner,
        "License": license_display,
        "LicenseUrl": license_url,
        "Category": category,
        "CategoryPath": category,
        "Notes": notes,
        "Tips": "",
        "Usage": description,
        "SampleCommands": [],
        "SampleFiles": [],
        "Source": "github",
        "SourceRepo": repo,
        "Version": version,
        "Topics": topics,
    }


def process_github_metadata(metadata_dir: Path) -> List[dict]:
    tools: List[dict] = []
    github_dir = metadata_dir / "github"
    if not github_dir.exists():
        return tools

    seen_repos: set = set()
    for path in sorted(github_dir.glob("*.json")):
        try:
            meta = read_json(path)
        except (json.JSONDecodeError, OSError) as e:
            print(f"  Warning: Could not read {path}: {e}", file=sys.stderr)
            continue

        repo = meta.get("Repo", "")
        if repo in seen_repos:
            continue
        seen_repos.add(repo)

        tool = build_github_tool(meta)
        tools.append(tool)
        print(f"  GitHub: {repo} -> {tool['Name']} [{tool['Category']}]")

    return tools


# ---------------------------------------------------------------------------
# Winget metadata -> tools_winget.json
# ---------------------------------------------------------------------------

def build_winget_tool(meta: dict) -> dict:
    """Convert cached winget metadata into a tool definition."""
    app_id = meta.get("AppId", "")
    name = meta.get("Name") or app_id.split(".")[-1]
    publisher = meta.get("Publisher") or meta.get("Author") or ""
    description = meta.get("Description") or ""
    homepage = meta.get("Homepage") or meta.get("PublisherUrl") or ""
    license_name = meta.get("License") or ""
    license_url = meta.get("LicenseUrl") or ""
    version = meta.get("Version") or ""
    tags = meta.get("Tags") or ""

    notes = description

    return {
        "Name": name,
        "Homepage": homepage,
        "Vendor": publisher,
        "License": license_name,
        "LicenseUrl": license_url,
        "Category": "Uncategorized",
        "CategoryPath": "Uncategorized",
        "Notes": notes,
        "Tips": "",
        "Usage": description,
        "SampleCommands": [],
        "SampleFiles": [],
        "Source": "winget",
        "WingetId": app_id,
        "Version": version,
        "Tags": tags,
    }


def process_winget_metadata(metadata_dir: Path) -> List[dict]:
    tools: List[dict] = []
    winget_dir = metadata_dir / "winget"
    if not winget_dir.exists():
        return tools

    for path in sorted(winget_dir.glob("*.json")):
        try:
            meta = read_json(path)
        except (json.JSONDecodeError, OSError) as e:
            print(f"  Warning: Could not read {path}: {e}", file=sys.stderr)
            continue

        tool = build_winget_tool(meta)
        tools.append(tool)
        print(f"  Winget: {meta.get('AppId', '?')} -> {tool['Name']}")

    return tools


# ---------------------------------------------------------------------------
# PyPI metadata -> tools_python.json
# ---------------------------------------------------------------------------

def fetch_pypi_metadata(package_name: str) -> Optional[dict]:
    """Fetch package metadata from the PyPI JSON API."""
    url = f"https://pypi.org/pypi/{package_name}/json"
    try:
        req = urllib.request.Request(url, headers={"Accept": "application/json"})
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except (urllib.error.HTTPError, urllib.error.URLError, OSError) as e:
        print(f"  Warning: PyPI lookup failed for {package_name}: {e}", file=sys.stderr)
        return None


def pypi_classifiers_to_category(classifiers: list) -> str:
    """Map PyPI classifiers to a dfirws tool category."""
    classifier_set = " ".join(classifiers).lower()

    category_map = [
        ("forensic", "Forensics"),
        ("malware", "Reverse Engineering"),
        ("reverse engineer", "Reverse Engineering"),
        ("disassembl", "Reverse Engineering"),
        ("network", "Network"),
        ("security", "Security"),
        ("cryptograph", "Utilities Cryptography"),
        ("database", "Files And Apps Database"),
        ("text processing", "Utilities"),
        ("office", "Files And Apps Office"),
    ]

    for keyword, category in category_map:
        if keyword in classifier_set:
            return category
    return "Uncategorized"


def build_pypi_tool(pypi_data: dict, package_name: str) -> dict:
    """Convert PyPI API response into a tool definition."""
    info = pypi_data.get("info", {})

    name = info.get("name") or package_name
    summary = info.get("summary") or ""
    author = info.get("author") or info.get("maintainer") or ""
    license_name = info.get("license") or ""
    # Some packages put the full license text in the license field — truncate
    if len(license_name) > 100:
        license_name = license_name[:80] + "..."
    homepage = info.get("home_page") or ""
    version = info.get("version") or ""
    classifiers = info.get("classifiers") or []

    # Try project_urls for better homepage
    project_urls = info.get("project_urls") or {}
    if not homepage:
        for key in ("Homepage", "Home", "homepage", "Source", "Repository", "GitHub"):
            if key in project_urls:
                homepage = project_urls[key]
                break

    # Get source/repo URL
    source_url = ""
    for key in ("Source", "Repository", "Source Code", "GitHub", "Code"):
        if key in project_urls:
            source_url = project_urls[key]
            break

    category = pypi_classifiers_to_category(classifiers)

    notes = summary

    return {
        "Name": name,
        "Homepage": homepage or source_url,
        "Vendor": author,
        "License": license_name,
        "LicenseUrl": "",
        "Category": category,
        "CategoryPath": category,
        "Notes": notes,
        "Tips": "",
        "Usage": summary,
        "SampleCommands": [],
        "SampleFiles": [],
        "Source": "pypi",
        "PypiPackage": package_name,
        "Version": version,
        "SourceUrl": source_url,
        "RequiresPython": info.get("requires_python") or "",
    }


def extract_python_packages(install_script: Path) -> List[str]:
    """Parse install_python_tools.ps1 to extract package names.

    Targets three patterns in the script:
    1. ``uv tool install [--with "deps"] "package"``
    2. ``foreach ($package in "pkg1", "pkg2", ...)``
    3. ``uv pip install [-U] pkg1 pkg2 ...`` (multi-line with backtick continuation)
    """
    if not install_script.exists():
        print(f"  Warning: {install_script} not found", file=sys.stderr)
        return []

    content = install_script.read_text(encoding="utf-8")
    lines = content.splitlines()
    packages: List[str] = []

    # Pattern 1: uv tool install "package" and uv tool install --with "..." "package"
    for m in re.finditer(
        r'uv tool install(?:\s+--with\s+"[^"]*")?\s+"([^"]+)"', content
    ):
        pkg = m.group(1)
        if pkg.startswith("git+"):
            repo_name = pkg.rstrip("/").split("/")[-1].replace(".git", "")
            packages.append(repo_name)
        else:
            packages.append(normalize_package_name(pkg))

    # Pattern 2: foreach ($package in "pkg1", "pkg2", ...) { uv tool install }
    # Find the foreach block and extract quoted package names
    foreach_match = re.search(
        r'foreach\s*\(\$package\s+in\s*`?\s*\n?(.*?)\)\s*\{',
        content,
        re.DOTALL,
    )
    if foreach_match:
        block = foreach_match.group(1)
        for m in re.finditer(r'"([a-zA-Z][a-zA-Z0-9_.+-]*(?:\[[a-z,]+\])?(?:>=?[0-9.]+)?)"', block):
            pkg = normalize_package_name(m.group(1))
            if pkg and pkg not in packages:
                packages.append(pkg)

    # Pattern 3: uv pip install [-U] pkg1, pkg2, ... (with backtick line continuation)
    # Collect multi-line uv pip install commands
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if re.match(r'^uv pip install\b', line) and "-r " not in line:
            # Collect continuation lines (backtick at end)
            full_line = line
            while full_line.rstrip().endswith("`") and i + 1 < len(lines):
                full_line = full_line.rstrip().rstrip("`") + " "
                i += 1
                full_line += lines[i].strip()

            # Remove the "uv pip install" prefix and flags
            args = re.sub(r'^uv pip install\s*', '', full_line)
            args = re.sub(r'\s+2>&1.*$', '', args)

            for token in re.split(r'[,\s]+', args):
                token = token.strip().strip('"').strip("'").strip(",").strip("`")
                if not token or token.startswith("-"):
                    continue
                # Must look like a Python package name
                if re.match(r'^[a-zA-Z][a-zA-Z0-9_.-]*(?:\[[a-z,]+\])?(?:>=?[0-9.]+)?$', token):
                    pkg = normalize_package_name(token)
                    if pkg and pkg not in packages:
                        packages.append(pkg)
        i += 1

    # Deduplicate while preserving order, exclude meta-packages
    skip = {"pip", "setuptools", "wheel"}
    seen: set = set()
    unique: List[str] = []
    for pkg in packages:
        key = pkg.lower()
        if key not in seen and key not in skip:
            seen.add(key)
            unique.append(pkg)

    return unique


def process_pypi_metadata(
    install_script: Path,
    cache_dir: Optional[Path] = None,
    rate_limit: float = 0.2,
) -> List[dict]:
    packages = extract_python_packages(install_script)
    if not packages:
        return []

    print(f"  Found {len(packages)} Python packages to look up on PyPI")

    # Use a cache directory to avoid repeated API calls
    if cache_dir:
        cache_dir.mkdir(parents=True, exist_ok=True)

    tools: List[dict] = []
    for pkg in packages:
        cached = None
        if cache_dir:
            cache_file = cache_dir / f"{pkg.lower()}.json"
            if cache_file.exists():
                try:
                    cached = read_json(cache_file)
                except (json.JSONDecodeError, OSError):
                    cached = None

        if cached:
            pypi_data = cached
        else:
            pypi_data = fetch_pypi_metadata(pkg)
            if pypi_data and cache_dir:
                cache_file = cache_dir / f"{pkg.lower()}.json"
                cache_file.write_text(
                    json.dumps(pypi_data, indent=2, ensure_ascii=False),
                    encoding="utf-8",
                )
            if rate_limit > 0:
                time.sleep(rate_limit)

        if not pypi_data:
            print(f"  PyPI: {pkg} -> SKIPPED (no data)")
            continue

        tool = build_pypi_tool(pypi_data, pkg)
        tools.append(tool)
        print(f"  PyPI: {pkg} -> {tool['Name']} [{tool['Category']}]")

    return tools


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(
        description="Extract tool metadata from GitHub cache, winget cache, and PyPI."
    )
    parser.add_argument(
        "--metadata-dir",
        default=os.environ.get("METADATA_DIR", "./downloads/.metadata"),
        help="Directory with cached metadata (default: ./downloads/.metadata).",
    )
    parser.add_argument(
        "--output-dir",
        default=os.environ.get("OUTPUT_DIR", "./downloads/dfirws"),
        help="Output directory for tools_*.json (default: ./downloads/dfirws).",
    )
    parser.add_argument(
        "--python-install-script",
        default=os.environ.get(
            "PYTHON_INSTALL_SCRIPT", "./setup/install/install_python_tools.ps1"
        ),
        help="Path to install_python_tools.ps1.",
    )
    parser.add_argument(
        "--skip-github", action="store_true", help="Skip GitHub metadata extraction."
    )
    parser.add_argument(
        "--skip-winget", action="store_true", help="Skip winget metadata extraction."
    )
    parser.add_argument(
        "--skip-pypi", action="store_true", help="Skip PyPI metadata extraction."
    )
    parser.add_argument(
        "--pypi-rate-limit",
        type=float,
        default=0.2,
        help="Seconds to wait between PyPI API calls (default: 0.2).",
    )
    args = parser.parse_args()

    metadata_dir = Path(args.metadata_dir)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # --- GitHub ---
    if not args.skip_github:
        print("Processing GitHub metadata...")
        github_tools = process_github_metadata(metadata_dir)
        if github_tools:
            out = write_tools_json(output_dir, "release", github_tools)
            print(f"  Wrote {len(github_tools)} tools to {out}")
        else:
            print("  No GitHub metadata found. Run release.ps1 first to populate cache.")

    # --- Winget ---
    if not args.skip_winget:
        print("Processing winget metadata...")
        winget_tools = process_winget_metadata(metadata_dir)
        if winget_tools:
            out = write_tools_json(output_dir, "winget", winget_tools)
            print(f"  Wrote {len(winget_tools)} tools to {out}")
        else:
            print("  No winget metadata found. Run winget.ps1 first to populate cache.")

    # --- PyPI ---
    if not args.skip_pypi:
        print("Processing PyPI metadata...")
        install_script = Path(args.python_install_script)
        pypi_cache = metadata_dir / "pypi"
        pypi_tools = process_pypi_metadata(
            install_script, cache_dir=pypi_cache, rate_limit=args.pypi_rate_limit
        )
        if pypi_tools:
            out = write_tools_json(output_dir, "python", pypi_tools)
            print(f"  Wrote {len(pypi_tools)} tools to {out}")
        else:
            print("  No Python packages found or PyPI lookups failed.")

    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
