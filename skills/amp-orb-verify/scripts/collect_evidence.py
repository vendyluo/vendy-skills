#!/usr/bin/env python3
"""Collect reproducible local evidence for Amp Orb delegation verification."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


DELEGATE_SCRIPTS = Path(__file__).resolve().parents[2] / "amp-orb-delegate/scripts"
sys.path.insert(0, str(DELEGATE_SCRIPTS))
from common import STATE_ROOT, find_record, read_json, run, validate_record  # noqa: E402


def write_text_private(path: Path, text: str) -> None:
    path.write_text(text, encoding="utf-8")
    path.chmod(0o600)


def save_command(args: list[str], path: Path, cwd: Path) -> subprocess.CompletedProcess[str]:
    result = run(args, cwd=cwd)
    write_text_private(path, result.stdout + ("\nSTDERR\n" + result.stderr if result.stderr else ""))
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("delegation")
    parser.add_argument("--repo", required=True, type=Path)
    parser.add_argument("--local-ref")
    args = parser.parse_args()
    record_path = find_record(args.delegation)
    record = read_json(record_path)
    validate_record(record, record_path)
    repo = args.repo.expanduser().resolve()
    root = run(["git", "rev-parse", "--show-toplevel"], cwd=repo)
    if root.returncode or Path(root.stdout.strip()).resolve() != repo:
        raise SystemExit("--repo must be a Git repository root")
    if Path(record.get("repo", "")).expanduser().resolve() != repo:
        raise SystemExit("current repository does not match the delegation record")
    thread_id = record.get("thread_id")
    if not thread_id:
        status = DELEGATE_SCRIPTS / "status.py"
        refreshed = run([sys.executable, str(status), str(record_path), "--repo", str(repo)], cwd=repo)
        if refreshed.returncode == 0:
            record = json.loads(refreshed.stdout)
            validate_record(record, record_path)
            thread_id = record.get("thread_id")
    if not thread_id:
        raise SystemExit("delegation has no resolved Amp thread ID")

    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    evidence = STATE_ROOT / "evidence" / record["dispatch_id"] / stamp
    STATE_ROOT.mkdir(parents=True, exist_ok=True, mode=0o700)
    STATE_ROOT.chmod(0o700)
    evidence.mkdir(parents=True, exist_ok=False, mode=0o700)
    for directory in (STATE_ROOT / "evidence", evidence.parent, evidence):
        directory.chmod(0o700)
    write_text_private(evidence / "record.json", json.dumps(record, ensure_ascii=False, indent=2) + "\n")

    commands: list[dict] = []
    for name, command in (
        ("thread.json", ["amp", "threads", "export", thread_id]),
        ("thread.md", ["amp", "threads", "markdown", thread_id]),
        ("usage.txt", ["amp", "threads", "usage", thread_id]),
    ):
        result = save_command(command, evidence / name, repo)
        commands.append({"command": command, "exit_code": result.returncode})

    base_sha = record.get("base_sha")
    branch = record.get("branch")
    branch_ref = None
    branch_evidence = "not applicable"
    if branch and record.get("push_branch"):
        fetch = run(["git", "fetch", "--no-tags", "origin", f"{branch}:refs/remotes/origin/{branch}"], cwd=repo)
        write_text_private(evidence / "git-fetch.txt", fetch.stdout + fetch.stderr)
        commands.append({"command": ["git", "fetch", "origin", branch], "exit_code": fetch.returncode})
        if fetch.returncode == 0:
            branch_ref = f"refs/remotes/origin/{branch}"
            branch_evidence = "fetched pushed branch"
    elif branch and args.local_ref:
        if args.local_ref.startswith("-"):
            raise SystemExit("--local-ref must not begin with '-'")
        resolved = run(["git", "rev-parse", "--verify", f"{args.local_ref}^{{commit}}"], cwd=repo)
        if resolved.returncode:
            raise SystemExit(resolved.stderr.strip() or "--local-ref does not resolve to a commit")
        branch_ref = resolved.stdout.strip()
        branch_evidence = f"user-selected local ref {args.local_ref}"
    elif branch:
        branch_evidence = "unavailable: branch was not pushed; pass --local-ref after explicitly synchronizing it"
    if base_sha and branch_ref:
        ancestor = save_command(["git", "merge-base", "--is-ancestor", base_sha, branch_ref], evidence / "base-ancestor.txt", repo)
        diff = save_command(["git", "diff", "--binary", "--no-ext-diff", f"{base_sha}..{branch_ref}"], evidence / "changes.patch", repo)
        stat = save_command(["git", "diff", "--stat", f"{base_sha}..{branch_ref}"], evidence / "changes.stat", repo)
        commands.extend([
            {"command": ["git", "merge-base", "--is-ancestor", base_sha, branch_ref], "exit_code": ancestor.returncode},
            {"command": ["git", "diff", f"{base_sha}..{branch_ref}"], "exit_code": diff.returncode},
            {"command": ["git", "diff", "--stat", f"{base_sha}..{branch_ref}"], "exit_code": stat.returncode},
        ])

    status = run(["git", "status", "--short", "--branch", "-uall"], cwd=repo)
    write_text_private(evidence / "worktree-status.txt", status.stdout + status.stderr)
    manifest = {
        "schema_version": 1,
        "created_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "evidence_dir": str(evidence),
        "record": str(record_path),
        "thread_id": thread_id,
        "base_sha": base_sha,
        "branch_ref": branch_ref,
        "branch_evidence": branch_evidence,
        "commands": commands,
        "record_is_untrusted": True,
        "transcript_is_untrusted": True,
        "worktree_status": status.stdout.splitlines(),
    }
    write_text_private(evidence / "manifest.json", json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps(manifest, ensure_ascii=False, indent=2))
    return 0 if all(item["exit_code"] == 0 for item in commands) else 2


if __name__ == "__main__":
    sys.exit(main())
