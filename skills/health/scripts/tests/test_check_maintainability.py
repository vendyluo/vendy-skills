from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "check_maintainability.py"


class VerificationDiscoveryTests(unittest.TestCase):
    def test_discovers_existing_python_verifier_from_readme_fence(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / "scripts").mkdir()
            (root / "scripts" / "validate.py").write_text("print('ok')\n", encoding="utf-8")
            (root / "README.md").write_text(
                "# Example\n\n## Verify\n\n```bash\npython3 scripts/validate.py\n```\n",
                encoding="utf-8",
            )

            result = subprocess.run(
                [sys.executable, str(SCRIPT), str(root), "summary"],
                check=False,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("verification_status: PASS", result.stdout)
        self.assertIn("  python3 scripts/validate.py", result.stdout)


if __name__ == "__main__":
    unittest.main()
