#!/usr/bin/env python3
"""Replay the pinned Wallet Core package and synthetic runtime evidence offline."""

import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parent
ABIS = ("arm64-v8a", "armeabi-v7a", "x86", "x86_64")
NATIVE = "libTrustWalletCore.so"
HEAD = "9e755995b78c08275e390a87914a04ce69d8fb34"
OFFICIAL = "04ea7ab9527beeb3f4d650b13108deb08ec8a857f4e62b86df3e953dfa9e4d87"
MAINTAINED = "560cf86e132e4b4ee18afb70daf670e12e8fd34684a03eb38b9e49e39cd0f57d"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    hasher = hashlib.sha256()
    with Path(path).open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            hasher.update(block)
    return hasher.hexdigest()


def read_json(name):
    return json.loads((ROOT / name).read_text())


def verify_members():
    names = (ROOT / "members.txt").read_text().splitlines()
    require(names == sorted(set(names)), "member list is not sorted and unique")
    require({"README.md", "members.txt", "verify_evidence.py",
             "verify_evidence_controls.py"} <= set(names), "archive controls missing")
    require(all(not Path(name).is_absolute() and ".." not in Path(name).parts
                for name in names), "unsafe archive path")
    require(not any(path.is_symlink() for path in ROOT.rglob("*")),
            "archive contains a symlink")
    actual = sorted(str(path.relative_to(ROOT)) for path in ROOT.rglob("*")
                    if path.is_file() and path != ROOT / "manifest.json")
    require(actual == names, "archive has missing or extra members")
    expected = [{"path": name, "size": (ROOT / name).stat().st_size,
                 "sha256": digest(ROOT / name)} for name in names]
    manifest = read_json("manifest.json")
    require(manifest.get("schema_version") == 1 and
            manifest.get("members") == expected, "archive member hash mismatch")
    return len(names)


def verify_package():
    report = read_json("raw/build/tracked-packaging-report.json")
    baseline = ROOT / "artifacts/official-wallet-core-4.8.4.aar"
    candidate = ROOT / "artifacts/maintained-wallet-core-4.8.4.aar"
    require(digest(baseline) == report["official_sha256"] == OFFICIAL,
            "official AAR bytes differ")
    require(digest(candidate) == report["maintained_sha256"] == MAINTAINED,
            "maintained AAR bytes differ")
    expected_jni = sorted(f"jni/{abi}/{NATIVE}" for abi in ABIS)
    with ZipFile(baseline) as old, ZipFile(candidate) as new:
        require(old.namelist() == new.namelist() and len(old.namelist()) == 13,
                "AAR member order/count differs")
        observed = sorted(name for name in old.namelist()
                          if old.read(name) != new.read(name))
        require(observed == sorted(report["changed_members"]) == expected_jni,
                "AAR changes extend beyond the four JNI members")
        require(set(report["members"]) == set(old.namelist()),
                "packaging member receipt differs")
        for name in old.namelist():
            item = report["members"][name]
            require(hashlib.sha256(old.read(name)).hexdigest() == item["official_sha256"]
                    and hashlib.sha256(new.read(name)).hexdigest() ==
                    item["maintained_sha256"] and item["changed"] == (name in observed),
                    f"AAR member receipt differs: {name}")
        require(old.read("classes.jar") == new.read("classes.jar"),
                "published Java classes differ")
    require((ROOT / "artifacts/official-wallet-core-4.8.4.pom").read_bytes() ==
            (ROOT / "artifacts/maintained-wallet-core-4.8.4.pom").read_bytes(),
            "core POM dependencies differ")
    old_module = read_json("artifacts/official-wallet-core-4.8.4.module")
    new_module = read_json("artifacts/maintained-wallet-core-4.8.4.module")
    require({key: value for key, value in old_module.items() if key != "variants"} ==
            {key: value for key, value in new_module.items() if key != "variants"} and
            len(old_module["variants"]) == len(new_module["variants"]) == 3,
            "Gradle module component or variant count differs")
    for before, after in zip(old_module["variants"], new_module["variants"]):
        require({key: value for key, value in before.items() if key != "files"} ==
                {key: value for key, value in after.items() if key != "files"},
                "Gradle variant or dependency graph differs")
        require(len(before["files"]) == len(after["files"]) == 1,
                "Gradle variant file set differs")
        for item, prefix in ((before["files"][0], "official"),
                             (after["files"][0], "maintained")):
            artifact = ROOT / "artifacts" / f"{prefix}-{item['name']}"
            require(artifact.is_file() and item["size"] == artifact.stat().st_size and
                    all(item[name] == hashlib.new(name, artifact.read_bytes()).hexdigest()
                        for name in ("sha512", "sha256", "sha1", "md5")),
                    "Gradle module file digest differs")
    for name, expected in report["core_files"].items():
        archived = "maintained-wallet-core-4.8.4" + name.removeprefix("wallet-core-4.8.4")
        require(digest(ROOT / "artifacts" / archived) == expected,
                f"selected core metadata differs: {name}")
    for name, expected in report["proto_files"].items():
        archived = "proto-wallet-core-4.8.4" + name.removeprefix("wallet-core-proto-4.8.4")
        require(digest(ROOT / "artifacts" / archived) == expected,
                f"selected proto metadata differs: {name}")
    strip = read_json("raw/build/candidate-stripped/strip-manifest.json")
    audit = read_json("raw/build/candidate-stripped/audit/summary.json")
    require(set(strip["abis"]) == set(audit) == set(ABIS), "four-ABI build proof missing")
    with ZipFile(candidate) as jar:
        for abi in ABIS:
            member_hash = hashlib.sha256(jar.read(f"jni/{abi}/{NATIVE}")).hexdigest()
            require(member_hash == strip["abis"][abi]["output"]["sha256"] ==
                    audit[abi]["sha256"], f"{abi}: linked/stripped AAR bytes differ")
            checks = audit[abi]["checks"]
            require(all(checks.get(name) is True for name in (
                "hash", "global_exports_equal_official", "soname_equal",
                "needed_equal", "load_16k", "relro_16k")),
                f"{abi}: retained ABI or ELF audit failed")
    elf = read_json("raw/build/maintained-aar-elf-audit.json")
    require(elf["passed"] is True and not elf["unaligned_libraries"],
            "maintained 64-bit AAR ELF audit failed")
    selection = (ROOT / "logs/app-selection.log").read_text()
    for scope in ("releaseCompileClasspath", "releaseRuntimeClasspath"):
        core_line = re.search(rf"^WALLET_SELECTION {scope} "
                              r"com\.trustwallet:wallet-core:4\.8\.4 (.+)$",
                              selection, re.MULTILINE)
        proto_line = re.search(rf"^WALLET_SELECTION {scope} "
                               r"com\.trustwallet:wallet-core-proto:4\.8\.4 (.+)$",
                               selection, re.MULTILINE)
        require(core_line is not None and
                core_line.group(1).endswith(f"sha256={MAINTAINED}") and
                "/android/native/wallet_core/maven/" in core_line.group(1),
                f"app {scope}: maintained core selection missing")
        require(proto_line is not None and
                proto_line.group(1).endswith(
                    f"sha256={digest(ROOT / 'artifacts/proto-wallet-core-4.8.4.jar')}") and
                "/android/native/wallet_core/maven/" in proto_line.group(1) and
                f"WALLET_PROTOBUF_RUNTIME {scope} "
                "com.google.protobuf:protobuf-javalite:4.36.2" in selection,
                f"app {scope}: proto/Javalite selection missing")
    licenses = sorted(path.name for path in (ROOT / "licenses").iterdir())
    require(len(licenses) == 6 and
            all((ROOT / "licenses" / name).is_file() for name in licenses),
            "retained source license/notice set missing")
    return report


def load_reviewed_verifier():
    path = ROOT / "source/tools/android_native_smoke/verify_walletcore_fixture.py"
    spec = importlib.util.spec_from_file_location("archived_walletcore_verifier", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    require(module.ROOT == ROOT / "source", "archived verifier root differs")
    return module


def replay_runtime(receipt=None):
    verifier = load_reviewed_verifier()
    if receipt is None:
        receipt = read_json("raw/runtime-receipt.json")
    epoch = read_json("source/tools/android_native_smoke/walletcore_fixture/fixture-build-epoch.json")
    require(digest(verifier.EPOCH) == verifier.EPOCH_SHA256 and
            receipt.get("build_epoch_sha256") == verifier.EPOCH_SHA256 and
            receipt.get("build_epoch") == epoch,
            "runtime build epoch differs")
    require(receipt.get("schema_version") == 1 and
            receipt.get("device") == verifier.DEVICE and receipt.get("git_head") == HEAD,
            "runtime schema/device/source commit differs")
    source_map = receipt.get("source_sha256")
    require(isinstance(source_map, dict) and
            set(source_map) == set(verifier.REVIEWED_SOURCES),
            "reviewed source input map differs")
    for name in verifier.REVIEWED_SOURCES:
        require(source_map[name] == digest(ROOT / "source" / name),
                f"reviewed source bytes differ: {name}")
    for name, expected in epoch["compiled_fixture_source_sha256"].items():
        require(digest(ROOT / "source" / name) == expected,
                f"compiled fixture source differs: {name}")
    require(digest(ROOT / "source/scripts/build_walletcore_fixture.py") ==
            epoch["build_script_sha256"], "fixture build script differs")
    inputs = epoch["input_sha256"]
    for field, name in (("baseline_aar", "official-wallet-core-4.8.4.aar"),
                        ("candidate_aar", "maintained-wallet-core-4.8.4.aar"),
                        ("proto_jar", "proto-wallet-core-4.8.4.jar"),
                        ("javalite_jar", "protobuf-javalite-4.36.2.jar")):
        require(digest(ROOT / "artifacts" / name) == inputs[field],
                f"fixture input differs: {field}")
    require(receipt.get("device_tool_sha256") == verifier.DEVICE_TOOL_SHA256,
            "recorded device tool pins differ")
    for label in ("initial", "final"):
        verifier.require_strict(receipt.get(label, {}), label)
    for label in ("strict_setup", "strict_restore"):
        steps = receipt.get(label, [])
        require(len(steps) == 4 and all(step.get("exit") == 0 for step in steps),
                f"{label}: device transition incomplete")
    require(set(receipt.get("phases", {})) == set(verifier.PACKAGES),
            "runtime phase set differs")
    apks = {phase: ROOT / f"artifacts/run1-{phase}.apk"
            for phase in verifier.PACKAGES}
    for phase, apk in apks.items():
        require(digest(apk) == verifier.APK_SHA256[phase] ==
                epoch["apk_sha256"][phase], f"{phase}: exact APK differs")
    phases = {phase: verifier.verify_phase(phase, receipt["phases"][phase], apks[phase])
              for phase in verifier.PACKAGES}
    require(phases["baseline"]["pid"] != phases["candidate"]["pid"] and
            phases["baseline"]["token"] != phases["candidate"]["token"],
            "fresh process identity reused")
    require(phases["baseline"]["status"] == phases["candidate"]["status"] == "PASS",
            "recorded runtime phase did not pass")
    for name in verifier.CASES:
        left = phases["baseline"]["cases"][name]
        right = phases["candidate"]["cases"][name]
        require(all(left.get(field) == right.get(field)
                    for field in ("outcome", "result", "errorClass", "errorMessage")),
                f"{name}: baseline/candidate result differs")
    app = phases["candidate"]["cases"]["bitcoinAppP2wsh"]
    require(app["outcome"] == "OBSERVED" and
            app["result"]["compilerError"] == "Error_invalid_params" and
            app["result"]["encodedBytes"] == 0,
            "app-shaped P2WSH observation differs")
    recorded = read_json("raw/runtime-verification.json")
    require(recorded["candidate_passed"] is True and
            recorded["baseline_status"] == "PASS" and
            recorded["parity"] == "all five cases equal" and
            recorded["phases"] == phases,
            "runtime verifier result differs")
    return recorded


def main():
    try:
        members = verify_members()
        package = verify_package()
        runtime = replay_runtime()
    except (OSError, ValueError, KeyError, TypeError, AttributeError,
            ImportError) as error:
        print(f"Wallet Core evidence rejected: {error}", file=sys.stderr)
        return 1
    print(json.dumps({"passed": True, "members": members,
                      "maintained_aar_sha256": package["maintained_sha256"],
                      "runtime_pids": {name: phase["pid"] for name, phase
                                       in runtime["phases"].items()}}, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
