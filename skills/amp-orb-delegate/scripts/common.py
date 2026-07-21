#!/usr/bin/env python3
"""Shared stdlib helpers for the Amp Orb delegation scripts."""

from __future__ import annotations

import json
import os
import re
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


STATE_ROOT = Path(os.environ.get("AMP_ORB_STATE_DIR", Path.home() / ".local/state/amp-orbs"))
LABEL_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9-]{0,31}$")
THREAD_ID_RE = re.compile(r"^T-[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$")


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def run(args: list[str], cwd: Path | None = None, check: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(args, cwd=cwd, text=True, capture_output=True, check=check)


def read_json(path: Path) -> dict[str, Any]:
    with path.open(encoding="utf-8") as handle:
        value = json.load(handle)
    if not isinstance(value, dict):
        raise ValueError(f"expected JSON object: {path}")
    return value


def write_json(path: Path, value: dict[str, Any]) -> None:
    STATE_ROOT.mkdir(parents=True, exist_ok=True, mode=0o700)
    STATE_ROOT.chmod(0o700)
    path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    path.parent.chmod(0o700)
    temporary = path.with_suffix(path.suffix + ".tmp")
    with temporary.open("w", encoding="utf-8") as handle:
        json.dump(value, handle, ensure_ascii=False, indent=2, sort_keys=True)
        handle.write("\n")
    temporary.chmod(0o600)
    temporary.replace(path)


def parse_project_status(text: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for line in text.splitlines():
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        normalized = key.strip().lower().replace(" ", "_")
        fields[normalized] = value.strip()
    return fields


def record_path(dispatch_id: str) -> Path:
    if not LABEL_RE.fullmatch(dispatch_id):
        raise ValueError("dispatch ID must be 1-32 alphanumeric/hyphen characters")
    return STATE_ROOT / "delegations" / f"{dispatch_id}.json"


def find_record(value: str) -> Path:
    candidate = Path(value).expanduser()
    if candidate.is_file():
        candidate = candidate.resolve()
        managed = (STATE_ROOT / "delegations").resolve()
        if candidate.parent != managed:
            raise ValueError("delegation record path must be under the managed state directory")
        if not LABEL_RE.fullmatch(candidate.stem):
            raise ValueError("delegation record has an invalid dispatch ID")
        return candidate
    direct = record_path(value)
    if direct.is_file():
        return direct
    for path in (STATE_ROOT / "delegations").glob("*.json"):
        record = read_json(path)
        if record.get("thread_id") == value:
            return path
    raise FileNotFoundError(f"no delegation record for {value}")


def validate_record(record: dict[str, Any], path: Path) -> None:
    dispatch_id = record.get("dispatch_id")
    if not isinstance(dispatch_id, str) or not LABEL_RE.fullmatch(dispatch_id):
        raise ValueError("delegation record has an invalid dispatch ID")
    if path.resolve() != record_path(dispatch_id).resolve():
        raise ValueError("delegation record path does not match its dispatch ID")
    base_sha = record.get("base_sha")
    if base_sha is not None and (not isinstance(base_sha, str) or not re.fullmatch(r"[0-9a-fA-F]{40}", base_sha)):
        raise ValueError("delegation record has an invalid base SHA")
    branch = record.get("branch")
    if branch is not None:
        if not isinstance(branch, str) or run(["git", "check-ref-format", "--branch", branch]).returncode:
            raise ValueError("delegation record has an invalid branch")
        if base_sha is None:
            raise ValueError("branch delegation record has no base SHA")
    if not isinstance(record.get("push_branch", False), bool):
        raise ValueError("delegation record has an invalid push authorization value")
    thread_id = record.get("thread_id")
    if thread_id is not None and not valid_thread_id(thread_id):
        raise ValueError("delegation record has an invalid Amp thread ID")


def valid_thread_id(value: Any) -> bool:
    return isinstance(value, str) and THREAD_ID_RE.fullmatch(value) is not None
