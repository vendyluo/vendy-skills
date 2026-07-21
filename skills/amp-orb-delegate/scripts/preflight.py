#!/usr/bin/env python3
"""Run deterministic, read-only gates before launching an Amp Orb."""

from __future__ import annotations

import argparse
import json
import shutil
import sys
from pathlib import Path

from common import parse_project_status, run


def fail(result: dict, code: str, message: str) -> None:
    result["errors"].append({"code": code, "message": message})


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", required=True)
    parser.add_argument("--kind", choices=("read-only", "branch"), default="read-only")
    parser.add_argument("--mode", choices=("low", "medium", "high", "ultra"), default="medium")
    args = parser.parse_args()

    repo = Path(args.repo).expanduser().resolve()
    result = {"ok": False, "repo": str(repo), "kind": args.kind, "mode": args.mode, "errors": [], "warnings": []}

    if not repo.is_dir():
        fail(result, "repo-missing", "repository directory does not exist")
        print(json.dumps(result, indent=2))
        return 2
    if not shutil.which("amp"):
        fail(result, "amp-missing", "amp CLI is not on PATH")

    root = run(["git", "rev-parse", "--show-toplevel"], cwd=repo)
    if root.returncode:
        fail(result, "not-git", root.stderr.strip() or "not a Git repository")
    elif Path(root.stdout.strip()).resolve() != repo:
        fail(result, "not-root", "--repo must be the Git repository root")

    head = run(["git", "rev-parse", "HEAD"], cwd=repo)
    upstream = run(["git", "rev-parse", "@{upstream}"], cwd=repo)
    status = run(["git", "status", "--porcelain=v1", "--untracked-files=all"], cwd=repo)
    if status.stdout.strip():
        fail(result, "dirty-worktree", "fresh Orbs cannot see local modified or untracked files")
    if upstream.returncode:
        fail(result, "no-upstream", "current branch has no tracked upstream")
    elif head.stdout.strip() != upstream.stdout.strip():
        fail(result, "not-synced", "HEAD must equal the tracked upstream commit")
    result["base_sha"] = head.stdout.strip() if head.returncode == 0 else None
    branch = run(["git", "branch", "--show-current"], cwd=repo)
    result["base_branch"] = branch.stdout.strip()

    setup = repo / ".agents/setup"
    resume = repo / ".agents/resume"
    tracked = run(["git", "ls-files", "--error-unmatch", ".agents/setup", ".agents/resume"], cwd=repo)
    hooks_ready = setup.is_file() and resume.is_file() and setup.stat().st_mode & 0o111 and resume.stat().st_mode & 0o111 and tracked.returncode == 0
    result["orb_hooks_ready"] = bool(hooks_ready)
    if not hooks_ready:
        result["warnings"].append("optional .agents/setup and .agents/resume hooks are not both committed and executable; verify the task has another runnable setup and feedback loop")

    project = run(["amp", "projects", "status"], cwd=repo)
    if project.returncode:
        fail(result, "project-unavailable", project.stderr.strip() or "amp projects status failed")
        project_fields = {}
    else:
        project_fields = parse_project_status(project.stdout)
        if project_fields.get("project", "").lower() == "none":
            fail(result, "project-not-joined", "repository is not joined to an Amp Workspace Project with Orbs enabled")
    result["project"] = project_fields

    usage = run(["amp", "usage"], cwd=repo)
    if usage.returncode:
        result["warnings"].append(usage.stderr.strip() or "amp usage was unavailable; confirm cost separately")
    else:
        result["usage_summary"] = [line for line in usage.stdout.splitlines() if "Subscription" in line or "Individual credits" in line]

    result["ok"] = not result["errors"]
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if result["ok"] else 2


if __name__ == "__main__":
    sys.exit(main())
