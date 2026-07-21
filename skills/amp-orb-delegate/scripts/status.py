#!/usr/bin/env python3
"""Refresh an Amp Orb delegation record from its stream or label fallback."""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

from common import STATE_ROOT, find_record, now_iso, read_json, run, valid_thread_id, validate_record, write_json


def alive(pid: int | None) -> bool:
    if not pid:
        return False
    try:
        os.kill(pid, 0)
        return True
    except OSError:
        return False


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("delegation")
    parser.add_argument("--repo", required=True, type=Path)
    args = parser.parse_args()
    path = find_record(args.delegation)
    record = read_json(path)
    validate_record(record, path)
    repo = args.repo.expanduser().resolve()
    root = run(["git", "rev-parse", "--show-toplevel"], cwd=repo)
    if root.returncode or Path(root.stdout.strip()).resolve() != repo:
        raise SystemExit("--repo must be a Git repository root")
    if Path(record.get("repo", "")).expanduser().resolve() != repo:
        raise SystemExit("current repository does not match the delegation record")

    result_event = None
    stream_path = STATE_ROOT / "runs" / record["dispatch_id"] / "stream.jsonl"
    if stream_path.is_file():
        for line in stream_path.read_text(encoding="utf-8", errors="replace").splitlines():
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue
            if event.get("type") == "system" and event.get("subtype") == "init" and valid_thread_id(event.get("session_id")):
                record["thread_id"] = event["session_id"]
            if event.get("type") == "result":
                result_event = event

    if not record.get("thread_id"):
        searched = run(["amp", "threads", "search", f"label:{record['dispatch_id']}", "--json"], cwd=repo)
        if searched.returncode == 0:
            try:
                matches = json.loads(searched.stdout)
                if len(matches) == 1 and valid_thread_id(matches[0].get("id")):
                    record["thread_id"] = matches[0].get("id")
            except json.JSONDecodeError:
                pass

    if record.get("thread_id"):
        record["thread_url"] = f"https://ampcode.com/threads/{record['thread_id']}"
    if result_event:
        record["status"] = "failed" if result_event.get("is_error") or result_event.get("subtype") != "success" else "completed"
        record["result"] = result_event.get("result")
        record["duration_ms"] = result_event.get("duration_ms")
    elif alive(record.get("pid")):
        record["status"] = "running"
    elif record.get("status") not in {"dry-run", "completed", "failed"}:
        record["status"] = "unknown"
    record["updated_at"] = now_iso()
    validate_record(record, path)
    write_json(path, record)
    print(json.dumps(record, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
