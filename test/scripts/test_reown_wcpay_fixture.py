"""Focused controls for the synthetic Reown fixture inputs."""

import hashlib
import shutil
import tempfile
import unittest
from pathlib import Path
from zipfile import ZipFile, ZIP_STORED

from scripts.prepare_reown_wcpay_fixture import prepare_mismatch
from tools.android_native_smoke.verify_reown_wcpay_fixture import (
    BUILD_INPUT_SHA256, APK_SHA256, member_and_executable_offsets,
    require_apks, require_build_epoch, require_jna_member, require_maps,
    require_strict,
    verify_git_epoch,
    verify_result,
)


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / ".superpowers/sdd/dependency-completion-20260925/task-16f-reown-source-inputs"
AAR = ROOT / "android/native/reown_wcpay/maven/com/github/reown-com/yttrium/yttrium-wcpay/0.10.60/yttrium-wcpay-0.10.60.aar"


class ReownFixturePrepTest(unittest.TestCase):
    def test_mismatch_changes_one_checksum_and_preserves_native_member(self):
        with tempfile.TemporaryDirectory() as folder:
            output = Path(folder) / "output"
            receipt = prepare_mismatch(SOURCE, AAR, output)
            generated = output / "bindings/yttrium.kt"
            original = (SOURCE / "generated-yttrium.kt").read_bytes()
            changed = generated.read_bytes()
            self.assertEqual(
                changed,
                original.replace(
                    b"uniffi_yttrium_checksum_func_register_logger() != 32546.toShort()",
                    b"uniffi_yttrium_checksum_func_register_logger() != 32547.toShort()",
                    1,
                ),
            )
            self.assertEqual(
                (output / "bindings/uniffi_yttrium.kt").read_bytes(),
                (SOURCE / "generated-uniffi_yttrium.kt").read_bytes(),
            )
            native = output / "jni/arm64-v8a/libuniffi_yttrium_wcpay.so"
            with ZipFile(AAR) as aar:
                self.assertEqual(native.read_bytes(), aar.read("jni/arm64-v8a/libuniffi_yttrium_wcpay.so"))
            self.assertEqual(receipt["native_sha256"], hashlib.sha256(native.read_bytes()).hexdigest())

    def test_bad_aar_is_rejected_before_staging(self):
        with tempfile.TemporaryDirectory() as folder:
            aar = Path(folder) / "wrong.aar"
            with ZipFile(aar, "w", ZIP_STORED) as archive:
                archive.writestr("jni/arm64-v8a/libuniffi_yttrium_wcpay.so", b"wrong")
            output = Path(folder) / "output"
            with self.assertRaisesRegex(ValueError, "AAR SHA256 mismatch"):
                prepare_mismatch(SOURCE, aar, output)
            self.assertFalse(output.exists())


class ReownFixtureVerifierTest(unittest.TestCase):
    def test_candidate_apk_members_are_page_aligned_and_exact(self):
        apk = ROOT / ".superpowers/sdd/dependency-completion-20260925/task-16f-reown-stage3-build/candidate.apk"
        if not apk.is_file():
            self.skipTest("Candidate fixture APK has not been built")
        native, offset, loads = member_and_executable_offsets(
            apk, "lib/arm64-v8a/libuniffi_yttrium_wcpay.so"
        )
        self.assertEqual(hashlib.sha256(native).hexdigest(),
                         "a89f233ea9a99d4cfb7591bc87bc468adae422c118e452524fcacb38467d9bff")
        self.assertEqual(offset % 16384, 0)
        self.assertTrue(loads)

    def test_wrong_strict_device_state_is_rejected(self):
        good = {
            "page_size": "16384", "linker_mode": "fatal",
            "package_compat_disabled": "true", "airplane_mode": "1", "ip_route": "",
        }
        snapshot = {key: {"exit": 0, "stdout": value} for key, value in good.items()}
        snapshot["package_compat_disabled"]["stdout"] = "false"
        with self.assertRaisesRegex(ValueError, "package_compat_disabled mismatch"):
            require_strict(snapshot, "candidate pre")

    def test_candidate_missing_typed_method_error_is_rejected(self):
        result = {
            "status": "PASS", "phase": "candidate", "attemptedInitialization": True,
            "constructorJsonParse": "uniffi.yttrium_wcpay.PayJsonException$JsonParse",
            "missingAuth": "uniffi.yttrium_wcpay.PayJsonException$MissingAuth",
            "optionsJsonParse": "uniffi.yttrium_wcpay.PayJsonException$JsonParse",
            "actionsJsonParse": "uniffi.yttrium_wcpay.PayJsonException$JsonParse",
            "confirmJsonParse": "uniffi.yttrium_wcpay.PayJsonException$JsonParse",
        }
        verify_result("candidate", result)
        result.pop("confirmJsonParse")
        with self.assertRaisesRegex(ValueError, "confirmJsonParse"):
            verify_result("candidate", result)

    def test_mismatch_acceptance_is_rejected(self):
        result = {"status": "PASS", "phase": "mismatch", "attemptedInitialization": True,
                  "mismatchError": "UniFFI API checksum mismatch"}
        verify_result("mismatch", result)
        result["mismatchError"] = "Mismatched binding was accepted"
        with self.assertRaisesRegex(ValueError, "mismatchError"):
            verify_result("mismatch", result)

    def test_substituted_apk_is_rejected_before_device(self):
        built = ROOT / ".superpowers/sdd/dependency-completion-20260925/task-16f-reown-stage3-build"
        with tempfile.TemporaryDirectory() as folder:
            candidate = Path(folder) / "candidate.apk"
            candidate.write_bytes((built / "candidate.apk").read_bytes() + b"substituted")
            apks = {phase: built / f"{phase}.apk" for phase in APK_SHA256}
            apks["candidate"] = candidate
            with self.assertRaisesRegex(ValueError, "candidate: pinned APK SHA256 mismatch"):
                require_apks(apks)

    def test_changed_compiled_source_is_rejected(self):
        mismatch = ROOT / ".superpowers/sdd/dependency-completion-20260925/task-16f-reown-stage3-build/mismatch-input"
        jna = next(Path("/Users/jieliu/.gradle/caches/modules-2/files-2.1/net.java.dev.jna/jna/5.17.0").rglob("*.aar"))
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            for relative in (*BUILD_INPUT_SHA256,
                             "tools/android_native_smoke/reown_wcpay_fixture/fixture-build-epoch.json"):
                target = root / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(ROOT / relative, target)
            changed = root / "tools/android_native_smoke/reown_wcpay_fixture/app/src/main/java/ai/n42/fixture/reown/MainActivity.kt"
            changed.write_bytes(changed.read_bytes() + b"\n// changed after build\n")
            with self.assertRaisesRegex(ValueError, "compiled fixture source SHA256 mismatch"):
                require_build_epoch(root, mismatch, jna)

    def test_same_wrong_jna_in_all_phases_is_rejected(self):
        for phase in APK_SHA256:
            with self.subTest(phase=phase):
                with self.assertRaisesRegex(ValueError, "packaged JNA member SHA256 mismatch"):
                    require_jna_member(b"same wrong JNI bytes")

    def test_all_missing_maps_are_rejected(self):
        with self.assertRaisesRegex(ValueError, "missing executable APK maps"):
            require_maps({"executableApkMaps": []}, "/data/app/x/base.apk",
                         [(16384, 16384)], "candidate", "lib/arm64-v8a/libjnidispatch.so")

    def test_unreviewed_git_head_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "git_head"):
            verify_git_epoch("0" * 40, {})


if __name__ == "__main__":
    unittest.main()
