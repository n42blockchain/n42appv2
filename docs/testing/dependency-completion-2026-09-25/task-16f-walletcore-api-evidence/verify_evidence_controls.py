#!/usr/bin/env python3
"""Small negative controls for the portable Wallet Core API evidence."""

import json
from pathlib import Path
import shutil
import sys
from tempfile import TemporaryDirectory


sys.dont_write_bytecode = True
import verify_evidence as evidence


def rejected(action, reason, check):
    with TemporaryDirectory(prefix="walletcore-api-control-") as temp:
        root = Path(temp) / "archive"
        shutil.copytree(evidence.ROOT, root, copy_function=shutil.copy2)
        old_root = evidence.ROOT
        try:
            evidence.ROOT = root
            action(root)
            try:
                check()
            except (OSError, ValueError, KeyError, TypeError, ImportError):
                return
            raise AssertionError(f"accepted {reason}")
        finally:
            evidence.ROOT = old_root


def main():
    if evidence.main() != 0:
        raise AssertionError("unchanged archive failed")

    def altered_member(root):
        path = root / "README.md"
        path.write_bytes(path.read_bytes() + b"\nchanged\n")

    rejected(altered_member, "altered archive member", evidence.verify_members)

    def missing_apk(root):
        (root / "artifacts/build3-apk.gz").unlink()

    rejected(missing_apk, "missing exact APK", evidence.verify_members)

    def wrong_page(root):
        path = root / "raw/run5-receipt.json"
        receipt = json.loads(path.read_bytes())
        old = receipt["devices"]["emulator-5562"]["initial"]["page"]["stdout"]
        if "KernelPageSize:        4 kB" not in old:
            raise AssertionError("expected API 26 page proof missing")
        receipt["devices"]["emulator-5562"]["initial"]["page"]["stdout"] = old.replace(
            "KernelPageSize:        4 kB", "KernelPageSize:       16 kB")
        path.write_text(json.dumps(receipt))

    rejected(wrong_page, "altered API 26 page proof", evidence.replay_runtime)

    def wrong_log(root):
        path = root / "raw/run5-receipt.json"
        receipt = json.loads(path.read_bytes())
        receipt["devices"]["emulator-5562"]["result_logcat"]["stdout"] = ""
        path.write_text(json.dumps(receipt))

    rejected(wrong_log, "missing API 26 raw log", evidence.replay_runtime)

    def false_final_java_count(root):
        path = root / "raw/focused-source/historical/app-api-test/adapter-unit-green-final.log"
        path.write_text(path.read_text().replace("OK (6 tests)", "OK (5 tests)"))

    rejected(false_final_java_count, "false final Java test count",
             evidence.focused_source_checks)

    rerun = Path("raw/focused-source/new-no-device-rerun/focused-rerun.json")

    def changed_rerun(root, change):
        path = root / rerun
        receipt = json.loads(path.read_bytes())
        change(receipt)
        path.write_text(json.dumps(receipt))

    rejected(lambda root: changed_rerun(root, lambda item: item.update(source_sha256={})),
             "empty focused source set", evidence.focused_source_checks)

    def drop_source(item):
        item["source_sha256"].pop("tools/android_native_smoke/test_walletcore_api_builder.py")

    rejected(lambda root: changed_rerun(root, drop_source),
             "dropped focused source", evidence.focused_source_checks)

    def change_executable(item):
        item["records"][0]["command"][0] = "/tmp/unreviewed-python3"

    rejected(lambda root: changed_rerun(root, change_executable),
             "changed focused executable", evidence.focused_source_checks)
    print(json.dumps({"passed": True, "negative_controls": 8}, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
