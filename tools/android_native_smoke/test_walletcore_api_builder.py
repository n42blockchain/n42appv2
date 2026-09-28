"""Focused source and artifact gates for the separate Wallet Core API fixture."""

import sys
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[2]
TASK = ROOT / ".superpowers/sdd/dependency-completion-20260925"
sys.path.insert(0, str(ROOT / "scripts"))
import build_walletcore_api_fixture as fixture  # noqa: E402


class FixtureBuilderTests(unittest.TestCase):
    def test_production_adapter_tamper_rejected_before_output(self):
        with TemporaryDirectory(dir=TASK) as temp:
            task = Path(temp)
            altered = task / "BitcoinV2SigningAdapter.java"
            altered.write_bytes(fixture.ADAPTER.read_bytes() + b"\n// changed\n")
            with patch.object(fixture, "ADAPTER", altered):
                with self.assertRaisesRegex(ValueError, "source SHA256 mismatch"):
                    fixture.build(TASK, task / "out")
            self.assertFalse((task / "out").exists())

    def test_fixture_activity_tamper_rejected_before_output(self):
        with TemporaryDirectory(dir=TASK) as temp:
            task = Path(temp)
            project = task / "project"
            for name in fixture.FILES:
                target = project / name
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes((fixture.PROJECT / name).read_bytes())
            activity = project / fixture.FILES[-1]
            activity.write_bytes(activity.read_bytes() + b"\n// changed\n")
            with patch.object(fixture, "PROJECT", project):
                with self.assertRaisesRegex(ValueError, "source SHA256 mismatch"):
                    fixture.build(TASK, task / "out")
            self.assertFalse((task / "out").exists())

    def test_candidate_aar_tamper_rejected_before_output(self):
        with TemporaryDirectory(dir=TASK) as temp:
            task = Path(temp)
            altered = task / "candidate.aar"
            altered.write_bytes(b"changed")
            original = fixture.prior.input_paths

            def paths(root):
                values = original(root)
                values["candidate_aar"] = altered
                return values

            with patch.object(fixture.prior, "input_paths", paths):
                with self.assertRaisesRegex(ValueError, "pinned input SHA256 changed"):
                    fixture.build(TASK, task / "out")
            self.assertFalse((task / "out").exists())

    def test_manifest_has_no_internet_permission(self):
        manifest = (fixture.PROJECT / "app/src/main/AndroidManifest.xml").read_text()
        self.assertNotIn("uses-permission", manifest)
        self.assertNotIn("INTERNET", manifest)


if __name__ == "__main__":
    unittest.main()
