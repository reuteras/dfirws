#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import re
from pathlib import Path
from typing import Dict, List


def get_slug(value: str | None) -> str:
    if not value:
        return "category"
    slug = value.lower()
    slug = re.sub(r"[^a-z0-9]+", "-", slug)
    slug = slug.strip("-")
    return slug or "category"


def get_nav_label(value: str | None) -> str:
    if not value:
        return "Docs"
    label = re.sub(r"[-_]+", " ", value).strip()
    if not label:
        return "Docs"
    words = [w if len(w) <= 1 else (w[0].upper() + w[1:]) for w in label.split()]
    return " ".join(words)


def get_nav_label_from_file(path: Path) -> str:
    if not path.exists():
        return get_nav_label(path.stem)
    try:
        with path.open("r", encoding="utf-8") as fh:
            for line in fh:
                m = re.match(r"^\s*#\s+(.+)$", line)
                if m:
                    title = m.group(1).strip()
                    if title:
                        return title
                    break
    except OSError:
        pass
    return get_nav_label(path.stem)


def get_string_list(value) -> List[str]:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    if isinstance(value, str) and value:
        return [value]
    return []


def get_tool_summary(tool: dict) -> str:
    notes = tool.get("Notes")
    if isinstance(notes, list) and notes:
        if notes[0]:
            return notes[0]
    if isinstance(notes, str) and notes:
        return notes
    usage = tool.get("Usage")
    if isinstance(usage, list) and usage:
        if usage[0]:
            return usage[0]
    if isinstance(usage, str) and usage:
        return usage
    return ""


def get_tool_page_slug(name: str, used: Dict[str, int]) -> str:
    slug = get_slug(name)
    if slug not in used:
        used[slug] = 1
        return slug
    used[slug] += 1
    return f"{slug}-{used[slug]}"


def write_tool_page(docs_root: Path, tool: dict, category_path: str, slug: str) -> Path:
    category_slug = get_slug(category_path)
    category_dir = docs_root / "tools" / category_slug
    category_dir.mkdir(parents=True, exist_ok=True)
    page_path = category_dir / f"{slug}.md"

    lines: List[str] = []
    lines.append(f"# {tool.get('Name', '')}")
    lines.append("")
    lines.append(f"**Category:** {category_path.replace('\\\\', ' / ')}")
    lines.append("")

    meta_added = False
    homepage = tool.get("Homepage")
    if homepage:
        lines.append(f"**Homepage:** <{homepage}>")
        lines.append("")
        meta_added = True
    vendor = tool.get("Vendor")
    if vendor:
        lines.append(f"**Vendor:** {vendor}")
        lines.append("")
        meta_added = True
    license_name = tool.get("License")
    license_url = tool.get("LicenseUrl")
    if license_name:
        if license_url:
            lines.append(f"**License:** [{license_name}]({license_url})")
        else:
            lines.append(f"**License:** {license_name}")
        meta_added = True
    elif license_url:
        lines.append(f"**License:** <{license_url}>")
        meta_added = True
    if meta_added:
        lines.append("")

    # Show version and source info for auto-extracted metadata
    version = tool.get("Version")
    if version:
        lines.append(f"**Version:** {version}")
        lines.append("")

    source = tool.get("Source")
    if source == "github":
        repo = tool.get("SourceRepo", "")
        if repo:
            lines.append(f"**Source:** [GitHub](<https://github.com/{repo}>)")
            lines.append("")
    elif source == "pypi":
        pypi_pkg = tool.get("PypiPackage", "")
        if pypi_pkg:
            lines.append(f"**Source:** [PyPI](<https://pypi.org/project/{pypi_pkg}/>)")
            lines.append("")
        source_url = tool.get("SourceUrl")
        if source_url:
            lines.append(f"**Repository:** <{source_url}>")
            lines.append("")
    elif source == "winget":
        winget_id = tool.get("WingetId", "")
        if winget_id:
            lines.append(f"**Winget ID:** `{winget_id}`")
            lines.append("")

    topics = tool.get("Topics")
    if isinstance(topics, list) and topics:
        lines.append(f"**Topics:** {', '.join(topics)}")
        lines.append("")

    summary = get_tool_summary(tool)
    if summary:
        lines.append(summary)
        lines.append("")

    notes = get_string_list(tool.get("Notes"))
    if notes:
        lines.append("## Notes")
        for note in notes:
            lines.append(note)
            lines.append("")

    tips = get_string_list(tool.get("Tips"))
    if tips:
        lines.append("## Tips")
        for tip in tips:
            lines.append(tip)
            lines.append("")

    usage = get_string_list(tool.get("Usage"))
    if usage:
        lines.append("## Usage")
        for item in usage:
            lines.append(item)
            lines.append("")

    sample_commands = get_string_list(tool.get("SampleCommands"))
    if sample_commands:
        lines.append("## Sample Commands")
        for command in sample_commands:
            lines.append(f"- `{command}`")
        lines.append("")

    sample_files = get_string_list(tool.get("SampleFiles"))
    if sample_files:
        lines.append("## Sample Files")
        for file in sample_files:
            lines.append(f"- {file}")
        lines.append("")

    page_path.write_text("\n".join(lines), encoding="utf-8")
    return page_path


def get_docs_nav_lines(root: Path, relative: Path = Path(""), indent: int = 2) -> List[str]:
    lines: List[str] = []
    current = root / relative if relative != Path("") else root
    if not current.exists():
        return lines

    indent_text = " " * indent
    index_file = current / "index.md"
    files = sorted([p for p in current.glob("*.md") if p.name != "index.md"], key=lambda p: p.name)
    dirs = sorted([p for p in current.iterdir() if p.is_dir()], key=lambda p: p.name)

    if index_file.exists():
        rel = "index.md" if relative == Path("") else str(relative / "index.md").replace("\\", "/")
        label = "Home" if relative == Path("") else "Overview"
        lines.append(f"{indent_text}- {label}: {rel}")

    for file in files:
        label = get_nav_label_from_file(file)
        rel = str(relative / file.name).replace("\\", "/") if relative != Path("") else file.name
        lines.append(f"{indent_text}- {label}: {rel}")

    for d in dirs:
        child_lines = get_docs_nav_lines(root, relative / d.name, indent + 2)
        if child_lines:
            lines.append(f"{indent_text}- {get_nav_label(d.name)}:")
            lines.extend(child_lines)

    return lines


def update_mkdocs_nav(config_path: Path, docs_root: Path) -> None:
    if not config_path.exists():
        print(f"mkdocs.yml not found at {config_path}. Skipping nav update.")
        return

    existing = config_path.read_text(encoding="utf-8").splitlines()
    before: List[str] = []
    after: List[str] = []
    in_nav = False
    found_nav = False
    in_loose_nav = False

    for line in existing:
        if not in_nav:
            if re.match(r"^\s*nav\s*:", line):
                in_nav = True
                found_nav = True
                continue
            if not found_nav and not in_loose_nav and line.startswith("- "):
                in_loose_nav = True
                continue
            if in_loose_nav:
                if re.match(r"^\S", line) and not line.startswith("- "):
                    in_loose_nav = False
                    after.append(line)
                continue
            before.append(line)
            continue
        if re.match(r"^\S", line) and not line.startswith("- "):
            in_nav = False
            after.append(line)

    nav_lines: List[str] = ["nav:"]
    root_index = docs_root / "index.md"
    if root_index.exists():
        nav_lines.append("- Home: index.md")

    top_files = sorted([p for p in docs_root.glob("*.md") if p.name != "index.md"], key=lambda p: p.name)
    for file in top_files:
        label = get_nav_label_from_file(file)
        nav_lines.append(f"- {label}: {file.name}")

    top_dirs = sorted([p for p in docs_root.iterdir() if p.is_dir()], key=lambda p: p.name)
    for d in top_dirs:
        child_lines = get_docs_nav_lines(docs_root, Path(d.name), 2)
        if child_lines:
            nav_lines.append(f"- {get_nav_label(d.name)}:")
            nav_lines.extend(child_lines)

    output: List[str] = []
    output.extend(before)
    if output and output[-1] != "":
        output.append("")
    output.extend(nav_lines)
    if after:
        output.append("")
        output.extend(after)

    output = [line for line in output if not re.match(r"^\s*-\s*navigation\.expand\s*$", line)]

    if not any(re.match(r"^\s*nav\s*:", line) for line in output):
        output.append("")
        output.extend(nav_lines)

    config_path.write_text("\n".join(output), encoding="utf-8")


def collect_tools_json_paths(path: Path) -> list[Path]:
    if path.is_dir():
        return sorted([p for p in path.glob("*.json") if p.is_file()])
    return [path]


def load_tools(json_paths: list[Path]) -> list[dict]:
    tools: list[dict] = []
    for path in json_paths:
        if not path.exists():
            raise FileNotFoundError(
                f"Tools JSON not found at {path}. Run resources\\download\\http.ps1 to generate it."
            )
        tools_doc = json.loads(path.read_text(encoding="utf-8"))
        tools.extend(tools_doc.get("Tools") or [])
    return tools


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate dfirws tools docs and mkdocs nav.")
    parser.add_argument(
        "--tools-json",
        dest="tools_json",
        default=os.environ.get("TOOLS_JSON", "./downloads/dfirws"),
        help="Path to tools JSON file or directory (default: ./downloads/dfirws).",
    )
    parser.add_argument(
        "--docs-root",
        dest="docs_root",
        default=os.environ.get("DOCS_ROOT", "./docs"),
        help="Docs root directory (default: ./docs).",
    )
    parser.add_argument(
        "--mkdocs-config",
        dest="mkdocs_config",
        default=os.environ.get("MKDOCS_CONFIG", "./mkdocs.yml"),
        help="Path to mkdocs.yml (default: ./mkdocs.yml).",
    )
    args = parser.parse_args()

    json_path = Path(args.tools_json)
    docs_root = Path(args.docs_root)
    mkdocs_config = Path(args.mkdocs_config)

    json_paths = collect_tools_json_paths(json_path)
    if not json_paths:
        raise FileNotFoundError(
            f"No tools JSON files found in {json_path}. Run resources\\download\\http.ps1 to generate them."
        )
    tools = load_tools(json_paths)

    grouped: Dict[str, List[dict]] = {}
    for tool in tools:
        category_path = tool.get("CategoryPath") or tool.get("Category") or "Uncategorized"
        grouped.setdefault(category_path, []).append(tool)

    ordered_categories = sorted(grouped.keys())

    docs_root.mkdir(parents=True, exist_ok=True)
    tools_root = docs_root / "tools"
    tools_root.mkdir(parents=True, exist_ok=True)

    # Clean old layout artifacts
    pages_dir = tools_root / "pages"
    if pages_dir.exists():
        for p in pages_dir.rglob("*"):
            if p.is_file():
                p.unlink()
        for p in sorted(pages_dir.rglob("*"), reverse=True):
            if p.is_dir():
                p.rmdir()
        pages_dir.rmdir()

    for file in tools_root.glob("*.md"):
        if file.name != "index.md":
            file.unlink()

    tools_index_path = tools_root / "index.md"

    tools_index_lines: List[str] = []
    tools_index_lines.append("# Categories")
    tools_index_lines.append("")
    tools_index_lines.append("Categories generated from dfirws shortcuts.")
    tools_index_lines.append("")
    tools_index_lines.append("## Categories Index")
    tools_index_lines.append("")
    for category_path in ordered_categories:
        display_name = category_path.replace("\\", " / ")
        slug = get_slug(category_path)
        tools_index_lines.append(f"- [{display_name}](./{slug}/index.md)")
    tools_index_lines.append("")

    tools_index_entries: List[tuple[str, str]] = []
    for category_path in ordered_categories:
        display_name = category_path.replace("\\", " / ")
        slug = get_slug(category_path)
        category_dir = tools_root / slug
        category_dir.mkdir(parents=True, exist_ok=True)
        category_file = category_dir / "index.md"

        lines: List[str] = []
        lines.append(f"# {display_name}")
        lines.append("")
        lines.append("| Tool | Description |")
        lines.append("| --- | --- |")

        tools_in_category = sorted(grouped[category_path], key=lambda t: t.get("Name", ""))
        used_slugs: Dict[str, int] = {}
        for tool in tools_in_category:
            tool_slug = get_tool_page_slug(tool.get("Name", ""), used_slugs)
            write_tool_page(docs_root, tool, category_path, tool_slug)
            tool_link = f"{tool_slug}.md"
            summary = get_tool_summary(tool).replace("|", "\\|")
            lines.append(f"| [{tool.get('Name', '')}]({tool_link}) | {summary} |")
            tools_index_entries.append(
                (tool.get("Name", ""), f"./{slug}/{tool_slug}.md")
            )

        category_file.write_text("\n".join(lines), encoding="utf-8")

    tools_index_lines.append("## Tools Index")
    tools_index_lines.append("")
    for tool_name, tool_link in sorted(tools_index_entries, key=lambda item: item[0].lower()):
        tools_index_lines.append(f"- [{tool_name}]({tool_link})")

    tools_index_path.write_text("\n".join(tools_index_lines), encoding="utf-8")

    update_mkdocs_nav(mkdocs_config, docs_root)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
