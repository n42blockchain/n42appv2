import importlib.util
from io import BytesIO
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from zipfile import ZipFile


SCRIPT = Path(__file__).resolve().parents[2] / "scripts/build_walletcore_fixture.py"
SPEC = importlib.util.spec_from_file_location("build_walletcore_fixture", SCRIPT)
fixture = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(fixture)


class WalletCoreFixtureBuildTest(unittest.TestCase):
    def test_checked_buffer_cannot_be_changed_by_later_path_swap(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "input.aar"
            path.write_bytes(b"official")
            checked = fixture.checked_bytes(path, fixture.digest(b"official"))
            path.write_bytes(b"substituted")
            self.assertEqual(checked, b"official")
            with self.assertRaisesRegex(ValueError, "SHA256 changed"):
                fixture.checked_bytes(path, fixture.digest(b"official"))

    def test_aar_requires_pinned_class_and_native_bytes(self):
        with tempfile.TemporaryDirectory() as directory:
            original = b"same classes"
            native = b"baseline native"
            stream = BytesIO()
            with ZipFile(stream, "w") as archive:
                archive.writestr("classes.jar", original)
                archive.writestr(fixture.JNI_MEMBER, native)
            with patch.object(fixture, "CLASSES_SHA256", fixture.digest(original)), \
                 patch.object(fixture, "JNI_SHA256", {"baseline": fixture.digest(native)}):
                receipt = fixture.check_aar(stream.getvalue(), "baseline")
                self.assertEqual(receipt["arm64_jni_sha256"], fixture.digest(native))
                altered = BytesIO()
                with ZipFile(altered, "w") as archive:
                    archive.writestr("classes.jar", b"changed classes")
                    archive.writestr(fixture.JNI_MEMBER, native)
                with self.assertRaisesRegex(ValueError, "Java or ARM64 JNI"):
                    fixture.check_aar(altered.getvalue(), "baseline")

    def test_real_input_preflight_rejects_tampered_pin(self):
        task = fixture.ROOT / ".superpowers/sdd/dependency-completion-20260925"
        _, receipt = fixture.preflight(task)
        self.assertEqual(receipt["aar_members"]["baseline"]["classes_sha256"],
                         receipt["aar_members"]["candidate"]["classes_sha256"])
        with patch.object(fixture, "PINS", {**fixture.PINS, "proto_jar": "0" * 64}):
            with self.assertRaisesRegex(ValueError, "SHA256 changed"):
                fixture.preflight(task)
        with patch.object(fixture, "AAPT2_JAR_SHA256", "0" * 64):
            with self.assertRaisesRegex(ValueError, "SHA256 changed"):
                fixture.preflight(task)


if __name__ == "__main__":
    unittest.main()
