#!/usr/bin/env python3
"""Focused negative tests for the repository validator."""

from __future__ import annotations

import importlib.util
import pathlib
import sys
import tempfile


VALIDATOR = pathlib.Path(__file__).with_name("validate.py")
sys.dont_write_bytecode = True
SPEC = importlib.util.spec_from_file_location("vendy_validate", VALIDATOR)
assert SPEC and SPEC.loader
validate = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(validate)


def write_skill(root: pathlib.Path, name: str, frontmatter: str, body: str = "# Test\n") -> pathlib.Path:
    skill = root / name
    skill.mkdir()
    (skill / "SKILL.md").write_text(f"---\n{frontmatter}---\n\n{body}", encoding="utf-8")
    return skill


def assert_failure(skill: pathlib.Path, expected: str) -> None:
    failures: list[str] = []
    validate.check_skill(skill, failures)
    assert any(expected in failure for failure in failures), failures


def main() -> None:
    with tempfile.TemporaryDirectory() as temporary:
        root = pathlib.Path(temporary)

        duplicate = write_skill(
            root,
            "testing-duplicate",
            "name: testing-duplicate\nname: testing-again\ndescription: Tests duplicates. Use when validating.\n",
        )
        assert_failure(duplicate, "unique flat key/value")

        nested = write_skill(
            root,
            "testing-nested",
            "name: testing-nested\ndescription: Tests nesting. Use when validating.\nmetadata:\n  owner: test\n",
        )
        assert_failure(nested, "unique flat key/value")

        unsupported = write_skill(
            root,
            "testing-fields",
            "name: testing-fields\ndescription: Tests fields. Use when validating.\nmodel: example\n",
        )
        assert_failure(unsupported, "unsupported frontmatter")

        escaping = write_skill(
            root,
            "testing-links",
            "name: testing-links\ndescription: Tests links. Use when validating.\n",
            "# Test\n\n[escape](../outside.md)\n",
        )
        (root / "outside.md").write_text("outside", encoding="utf-8")
        assert_failure(escaping, "escapes the skill directory")

        valid = write_skill(
            root,
            "testing-valid",
            "name: testing-valid\ndescription: Validates a flat skill contract. Use when testing the validator.\n",
        )
        failures: list[str] = []
        validate.check_skill(valid, failures)
        assert failures == [], failures

    print("PASS: 5 validator fixtures")


if __name__ == "__main__":
    main()
