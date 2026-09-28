#!/usr/bin/env python3
"""Replay the reviewed Reown WCPay native evidence without a device or build cache."""

import hashlib
import importlib.util
import json
from pathlib import Path
import sys
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parent
HISTORICAL_ROOT = "/Users/jieliu/.codex/worktrees/n42appv2-dependency-completion/"
REVIEWED_HEAD = "6b8692a375a06b957a30293d5676587f4d2bc6db"
ABIS = ("arm64-v8a", "armeabi-v7a", "x86", "x86_64")
NATIVE = "libuniffi_yttrium_wcpay.so"
PHASES = ("baseline", "candidate", "mismatch")


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    value = hashlib.sha256()
    with Path(path).open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()


def verify_members():
    names = (ROOT / "members.txt").read_text().splitlines()
    require(names == sorted(set(names)), "member list is not sorted and unique")
    require({"README.md", "members.txt", "verify_evidence.py",
             "verify_evidence_controls.py"} <= set(names), "archive controls missing")
    require(all(not Path(name).is_absolute() and ".." not in Path(name).parts
                for name in names), "unsafe member path")
    require(not any(path.is_symlink() for path in ROOT.rglob("*")),
            "archive contains a symlink")
    actual = sorted(str(path.relative_to(ROOT)) for path in ROOT.rglob("*")
                    if path.is_file() and path != ROOT / "manifest.json")
    require(actual == names, "archive has missing or extra members")
    manifest = json.loads((ROOT / "manifest.json").read_text())
    require(manifest.get("schema_version") == 1, "manifest schema mismatch")
    observed = [{"path": name, "size": (ROOT / name).stat().st_size,
                 "sha256": digest(ROOT / name)} for name in names]
    require(manifest.get("members") == observed, "archive member hash mismatch")
    return len(names)


def verify_package():
    receipt = json.loads((ROOT / "raw/stage2/package-receipt.json").read_text())
    old = ROOT / "artifacts/official-yttrium-wcpay-0.10.60.aar"
    new = ROOT / "artifacts/maintained-yttrium-wcpay-0.10.60.aar"
    require(digest(old) == receipt["official_sha256"] ==
            "07b139f458f9eda49445649cf2496b020b8664e0b0c9c7ca30c89a06259b75e8",
            "official AAR identity mismatch")
    require(digest(new) == receipt["maintained_sha256"] ==
            "edf6908e5ec8c3e0b0ef2d45b47347c55ea84c96907fd952fadb84b038607303",
            "maintained AAR identity mismatch")
    expected_changed = sorted(f"jni/{abi}/{NATIVE}" for abi in ABIS)
    with ZipFile(old) as original, ZipFile(new) as maintained:
        require(original.namelist() == maintained.namelist() and
                len(original.namelist()) == receipt["total_members"] == 13,
                "AAR member set/order mismatch")
        changed = sorted(name for name in original.namelist()
                         if original.read(name) != maintained.read(name))
        require(changed == sorted(receipt["changed_members"]) == expected_changed,
                "AAR changed members differ")
        for abi in ABIS:
            name = f"jni/{abi}/{NATIVE}"
            built = ROOT / f"source-proof/candidate1/native/{abi}/{NATIVE}"
            require(maintained.read(name) == built.read_bytes(),
                    f"{abi} candidate native differs from selected AAR")
        require(original.read("classes.jar") == maintained.read("classes.jar"),
                "compiled Kotlin/JVM API differs")
    for ext in ("aar", "pom", "module"):
        selected = ROOT / f"artifacts/maintained-yttrium-wcpay-0.10.60.{ext}"
        require(digest(selected) == receipt["output_files"][f"yttrium-wcpay-0.10.60.{ext}"],
                f"selected {ext} differs")
    require((ROOT / "artifacts/official-yttrium-wcpay-0.10.60.pom").read_bytes() ==
            (ROOT / "artifacts/maintained-yttrium-wcpay-0.10.60.pom").read_bytes(),
            "POM dependencies differ")
    old_module = json.loads((ROOT / "artifacts/official-yttrium-wcpay-0.10.60.module").read_text())
    new_module = json.loads((ROOT / "artifacts/maintained-yttrium-wcpay-0.10.60.module").read_text())
    require(len(old_module["variants"]) == len(new_module["variants"]) == 2,
            "Gradle variant count differs")
    for before, after in zip(old_module["variants"], new_module["variants"]):
        before_without_file = {key: value for key, value in before.items() if key != "files"}
        after_without_file = {key: value for key, value in after.items() if key != "files"}
        require(before_without_file == after_without_file,
                "Gradle variant or dependency graph differs")
        require(len(before["files"]) == len(after["files"]) == 1,
                "Gradle AAR file records differ")
        for record, aar in ((before["files"][0], old), (after["files"][0], new)):
            data = aar.read_bytes()
            require(record["name"] == record["url"] == "yttrium-wcpay-0.10.60.aar" and
                    record["size"] == len(data) and
                    all(record[name] == hashlib.new(name, data).hexdigest()
                        for name in ("sha512", "sha256", "sha1", "md5")),
                    "Gradle module AAR digest record differs")
    require({key: value for key, value in old_module.items() if key != "variants"} ==
            {key: value for key, value in new_module.items() if key != "variants"},
            "Gradle module component differs")
    licenses = json.loads((ROOT / "raw/stage2/license-inputs.json").read_text())
    require(set(licenses) == {path.name for path in (ROOT / "licenses").iterdir()},
            "retained license set differs")
    for name, record in licenses.items():
        path = ROOT / "licenses" / name
        require(path.stat().st_size == record["bytes"] and
                digest(path) == record["sha256"], f"retained license differs: {name}")
    require(digest(ROOT / "source-proof/candidate1/manifest.json") ==
            receipt["candidate_manifest_sha256"], "candidate source manifest differs")
    require(digest(ROOT / "source-proof/candidate1/corrected-binding-comparison.json") ==
            receipt["binding_comparison_sha256"], "corrected binding proof differs")
    selection = json.loads((ROOT / "raw/stage2/gradle-selection-receipt.json").read_text())
    require({item["scope"] for item in selection["selected"]} ==
            {"app-release-runtime", "plugin-releaseCompileClasspath",
             "plugin-releaseRuntimeClasspath"}, "Gradle selection scopes differ")
    expected_suffix = ("/android/native/reown_wcpay/maven/com/github/reown-com/"
                       "yttrium/yttrium-wcpay/0.10.60/yttrium-wcpay-0.10.60.aar")
    for item in selection["selected"]:
        require(item["coordinate"] ==
                "com.github.reown-com.yttrium:yttrium-wcpay:0.10.60" and
                item["path"].endswith(expected_suffix) and
                item["sha256"] == digest(new), "Gradle selected another Reown AAR")
    require(selection["jna"] == "net.java.dev.jna:jna:5.17.0",
            "JNA Gradle dependency differs")
    return receipt


def load_reviewed_verifier():
    path = ROOT / "source/tools/android_native_smoke/verify_reown_wcpay_fixture.py"
    spec = importlib.util.spec_from_file_location("reviewed_reown_verifier", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    require(module.ROOT == ROOT / "source", "archived verifier source root differs")
    return module


def replay_runtime(receipt=None):
    original = json.loads((ROOT / "raw/stage3-runtime-run2/reown-runtime-receipt.json").read_text())
    if receipt is None:
        receipt = original
    verifier = load_reviewed_verifier()

    # The reviewed verifier's only online dependency is `git show` for its
    # historical source commit. Replace that lookup with the archived exact
    # source bytes; all APK, build-epoch and runtime checks remain unchanged.
    def archived_git_epoch(head, observed_sources):
        require(head == REVIEWED_HEAD, "historical source commit mismatch")
        require(isinstance(observed_sources, dict), "source input map missing")
        expected = {}
        for source in verifier.SOURCE_FILES:
            relative = source.relative_to(ROOT / "source").as_posix()
            expected[HISTORICAL_ROOT + relative] = digest(source)
        require(observed_sources == expected, "source input identity mismatch")
        for relative, pinned in verifier.BUILD_INPUT_SHA256.items():
            require(digest(ROOT / "source" / relative) == pinned,
                    f"compiled fixture source differs: {relative}")

    verifier.verify_git_epoch = archived_git_epoch
    apks = {phase: ROOT / f"artifacts/run2-{phase}.apk" for phase in PHASES}
    result = verifier.verify(receipt, apks, ROOT / "artifacts/jna-5.17.0.aar",
                             ROOT / "raw/mismatch-input")
    require(json.loads(json.dumps(result)) == json.loads((ROOT / "raw/stage3-runtime-run2/"
                                                        "reown-runtime-verification.json").read_text()),
            "runtime replay differs from recorded verification")
    return result


def verify_run1_boundary():
    run1 = json.loads((ROOT / "raw/stage3-runtime-run1/reown-runtime-receipt.json").read_text())
    require(set(run1["phases"]) == {"baseline"} and
            "result" not in run1["phases"]["baseline"],
            "run 1 fixture failure boundary differs")
    require(run1["phases"]["baseline"]["apk_sha256"] ==
            digest(ROOT / "artifacts/run1-baseline.apk"), "run 1 baseline APK differs")


def main():
    try:
        members = verify_members()
        package = verify_package()
        verify_run1_boundary()
        runtime = replay_runtime()
    except (OSError, ValueError, KeyError, TypeError, AttributeError) as error:
        print(f"Reown evidence rejected: {error}", file=sys.stderr)
        return 1
    print(json.dumps({"passed": True, "members": members,
                      "maintained_aar_sha256": package["maintained_sha256"],
                      "runtime_pids": {name: item["pid"] for name, item
                                       in runtime["phases"].items()}}, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
