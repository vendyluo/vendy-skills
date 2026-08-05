#!/usr/bin/env python3
"""Validate the Vendy Skills source.

Exit 0: structural checks passed.
Exit 1: source validation failed.
"""

from __future__ import annotations

import ast
import pathlib
import re
import subprocess
import sys
import urllib.parse


ROOT = pathlib.Path(__file__).resolve().parent.parent
SKILLS = ROOT / "skills"
NAME_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
MARKDOWN_LINK_RE = re.compile(r"!?\[[^\]]*\]\(([^)]+)\)")
FRONTMATTER_FIELDS = {"name", "description", "license", "compatibility"}
FORBIDDEN_TOKENS = ("CLAUDE_SKILL_DIR", "when_to_use", "dispatch_intent")


def parse_frontmatter(path: pathlib.Path) -> tuple[dict[str, str], str] | None:
    """Parse this repository's deliberately flat YAML frontmatter subset."""
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if not lines or lines[0] != "---":
        return None

    closing = [index for index, line in enumerate(lines[1:], 1) if line == "---"]
    if not closing:
        return None

    fields: dict[str, str] = {}
    for line in lines[1 : closing[0]]:
        if not line or line.startswith((" ", "\t")) or ":" not in line:
            return None
        key, raw_value = line.split(":", 1)
        key = key.strip()
        value = raw_value.strip()
        if not key or not value or key in fields:
            return None
        if value[:1] in {'"', "'"}:
            if len(value) < 2 or value[-1] != value[0]:
                return None
            value = value[1:-1]
        fields[key] = value

    return fields, text


def check_skill(skill_dir: pathlib.Path, failures: list[str]) -> None:
    skill_file = skill_dir / "SKILL.md"
    if not skill_file.is_file():
        failures.append(f"{skill_dir.name}: missing SKILL.md")
        return

    parsed = parse_frontmatter(skill_file)
    if parsed is None:
        failures.append(f"{skill_dir.name}: frontmatter must use unique flat key/value fields between YAML delimiters")
        return
    fields, text = parsed

    unknown = sorted(set(fields) - FRONTMATTER_FIELDS)
    if unknown:
        failures.append(f"{skill_dir.name}: unsupported frontmatter fields: {', '.join(unknown)}")

    name = fields.get("name", "")
    if name != skill_dir.name:
        failures.append(f"{skill_dir.name}: frontmatter name is {name!r}")
    if len(name) > 64 or not NAME_RE.fullmatch(name):
        failures.append(f"{skill_dir.name}: name must be at most 64 lowercase alphanumeric/hyphen characters")
    if not name.split("-", 1)[0].endswith("ing"):
        failures.append(f"{skill_dir.name}: catalog policy requires the first name token to end in 'ing'")

    description = fields.get("description", "")
    if not description:
        failures.append(f"{skill_dir.name}: description is required")
    elif len(description) > 1024:
        failures.append(f"{skill_dir.name}: description exceeds 1024 characters")
    elif "Use when" not in description:
        failures.append(f"{skill_dir.name}: description must state when the skill applies")

    compatibility = fields.get("compatibility", "")
    if len(compatibility) > 500:
        failures.append(f"{skill_dir.name}: compatibility exceeds 500 characters")

    line_count = len(text.splitlines())
    if line_count >= 500:
        failures.append(f"{skill_dir.name}: SKILL.md has {line_count} lines; must be under 500")

    for token in FORBIDDEN_TOKENS:
        if token in text:
            failures.append(f"{skill_dir.name}: contains forbidden runtime/inert token {token}")

    check_links(skill_dir, failures)
    check_scripts(skill_dir, failures)


def check_links(skill_dir: pathlib.Path, failures: list[str]) -> None:
    root = skill_dir.resolve()
    for markdown in sorted(skill_dir.rglob("*.md")):
        text = markdown.read_text(encoding="utf-8")
        for raw in MARKDOWN_LINK_RE.findall(text):
            target = raw.strip().split()[0].strip("<>")
            if not target or target.startswith("#") or urllib.parse.urlparse(target).scheme:
                continue
            relative = urllib.parse.unquote(target.split("#", 1)[0])
            candidate = (markdown.parent / relative).resolve()
            try:
                candidate.relative_to(root)
            except ValueError:
                failures.append(f"{skill_dir.name}: bundled link escapes the skill directory: {relative}")
                continue
            if relative and not candidate.exists():
                source = markdown.relative_to(skill_dir)
                failures.append(f"{skill_dir.name}: {source} has unresolved link {relative}")


def check_scripts(skill_dir: pathlib.Path, failures: list[str]) -> None:
    for shell in sorted(skill_dir.rglob("*.sh")):
        result = subprocess.run(["bash", "-n", str(shell)], capture_output=True, text=True)
        if result.returncode:
            failures.append(f"{skill_dir.name}: shell syntax failed for {shell.name}: {result.stderr.strip()}")

    for python in sorted(skill_dir.rglob("*.py")):
        try:
            ast.parse(python.read_text(encoding="utf-8"), filename=str(python))
        except SyntaxError as error:
            failures.append(f"{skill_dir.name}: Python syntax failed for {python.name}:{error.lineno}: {error.msg}")


def run_validator_tests(failures: list[str]) -> None:
    test = ROOT / "scripts" / "test_validate.py"
    result = subprocess.run([sys.executable, str(test)], cwd=ROOT, capture_output=True, text=True)
    if result.returncode:
        failures.append(f"validator: focused tests failed\n{(result.stdout + result.stderr).strip()}")
    else:
        print("PASS: validator focused tests")


def main() -> int:
    failures: list[str] = []

    if not SKILLS.is_dir():
        print("FAIL: skills directory is missing")
        return 1

    skill_dirs = sorted(path for path in SKILLS.iterdir() if path.is_dir())
    for skill_dir in skill_dirs:
        check_skill(skill_dir, failures)
    run_validator_tests(failures)

    if failures:
        print(f"FAIL ({len(failures)}):")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(f"PASS: {len(skill_dirs)} skills validated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
