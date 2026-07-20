#!/usr/bin/env python3
"""Repo validation contract for vendyluo/skills.

Checks, per skill under skills/:
  1. SKILL.md exists and its YAML frontmatter parses with name + description.
  2. Every relative reference to references/, assets/, scripts/ mentioned in
     the skill's markdown files points to an existing file or directory.
  3. .sh / .py scripts are syntactically loadable (bash -n / py_compile).
  4. No project-specific tokens leak into shared skills (they belong in that
     project's own CLAUDE.md / project skills).

Exit 0 = pass, 1 = failures found.
"""
import ast
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SKILLS = ROOT / "skills"

# Names that must stay in each project's own context, never in shared skills.
FORBIDDEN_TOKENS = [
    "hunger_api2", "hotcake",
    "stg_release", "pr_release", "prod_prepare", "prod_release",
]

# Referenced paths that are created at runtime (fonts downloaded on demand)
# or deliberately not bundled (upstream demo/gallery assets; user-supplied files).
NOT_BUNDLED = {
    "assets/fonts",
    "assets/demos", "assets/demos/images",
    "assets/examples",
    "assets/illustrations",
    "assets/client-logo.svg",  # user-supplied brand asset, path is an example
}

REF_RE = re.compile(r"(?<![\w/])((?:references|assets|scripts)/[\w./-]+)")
PLACEHOLDER_RE = re.compile(r"[<>*{}$]")

failures = []


def check_frontmatter(skill_dir: pathlib.Path):
    md = skill_dir / "SKILL.md"
    if not md.is_file():
        failures.append(f"{skill_dir.name}: missing SKILL.md")
        return
    text = md.read_text()
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m:
        failures.append(f"{skill_dir.name}: SKILL.md has no frontmatter block")
        return
    fm = m.group(1)
    for field in ("name:", "description:"):
        if not re.search(rf"^{field}", fm, re.M):
            failures.append(f"{skill_dir.name}: frontmatter missing {field}")


def check_references(skill_dir: pathlib.Path):
    for md in skill_dir.rglob("*.md"):
        text = md.read_text()
        for ref in sorted(set(REF_RE.findall(text))):
            clean = ref.rstrip("/")
            if PLACEHOLDER_RE.search(ref) or ".." in ref:
                continue
            if clean in NOT_BUNDLED or any(clean.startswith(p + "/") for p in NOT_BUNDLED):
                continue
            target = skill_dir / clean
            if target.exists():
                continue
            # extensionless refs like `slides-marp(.md|.css)` -> prefix match
            if not target.suffix and any(target.parent.glob(target.name + ".*")):
                continue
            failures.append(
                f"{skill_dir.name}: {md.relative_to(skill_dir)} references missing {ref}")


def check_scripts(skill_dir: pathlib.Path):
    for sh in skill_dir.rglob("*.sh"):
        r = subprocess.run(["bash", "-n", str(sh)], capture_output=True)
        if r.returncode != 0:
            failures.append(f"{skill_dir.name}: bash -n failed for {sh.name}: "
                            f"{r.stderr.decode().strip().splitlines()[:1]}")
    for py in skill_dir.rglob("*.py"):
        try:
            ast.parse(py.read_text(), filename=str(py))
        except SyntaxError as e:
            failures.append(f"{skill_dir.name}: syntax error in {py.name}: {e.msg} (line {e.lineno})")


def check_forbidden(skill_dir: pathlib.Path):
    for md in skill_dir.rglob("*.md"):
        text = md.read_text()
        for tok in FORBIDDEN_TOKENS:
            for i, line in enumerate(text.splitlines(), 1):
                if tok in line:
                    failures.append(
                        f"{skill_dir.name}: project-specific token '{tok}' at "
                        f"{md.relative_to(skill_dir)}:{i}")


def main():
    skill_dirs = sorted(p for p in SKILLS.iterdir() if p.is_dir())
    for d in skill_dirs:
        check_frontmatter(d)
        check_references(d)
        check_scripts(d)
        check_forbidden(d)
    if failures:
        print(f"FAIL ({len(failures)}):")
        for f in failures:
            print(f"  - {f}")
        sys.exit(1)
    print(f"PASS: {len(skill_dirs)} skills validated")


if __name__ == "__main__":
    main()
