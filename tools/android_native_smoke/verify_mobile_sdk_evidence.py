#!/usr/bin/env python3
"""Write or check the bounded Task16B evidence manifest without running an SDK."""

import argparse
import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / "docs/testing/dependency-completion-2026-09-25/native-sdk-evidence"
MANIFEST = EVIDENCE / "manifest.json"
RUNNER = ROOT / "tools/android_native_smoke/run_mobile_sdk_fixture.sh"
EXPECTED_AARS = {
    "native": "ec2dce904f925ca044089164e6b7e7821ded77788c214676a18ed357f27e87a5",
    "tls": "bc8b8962df31a35fe67c37104de1202dd2451f7b5b31a77908252b929f8e7ac4",
    "bls": "ec2dce904f925ca044089164e6b7e7821ded77788c214676a18ed357f27e87a5",
    "legacy": "784783d758533826a768bc0697525d9b28caa857a3f4819707877fb790d6b254",
    "maintained": "ec2dce904f925ca044089164e6b7e7821ded77788c214676a18ed357f27e87a5",
}
DEVICE = "device=emulator-5560 PAGE_SIZE=16384 linker_compat=fatal package_compat_disabled=true"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def one_value(lines: list[str], key: str) -> str:
    matches = [line.split("=", 1)[1] for line in lines if line.startswith(key + "=")]
    if len(matches) != 1:
        raise ValueError(f"Expected one {key}, found {len(matches)}")
    return matches[0]


def run_record(mode: str) -> dict:
    path = EVIDENCE / f"{mode}-runtime.log"
    lines = path.read_text().splitlines()
    if lines.count(DEVICE) != 2:
        raise ValueError(f"{mode}: missing pre/post strict16KB device properties")
    if not any("All tests passed!" in line for line in lines):
        raise ValueError(f"{mode}: Flutter test result missing")
    if sum(line.startswith(f"mode={mode} result=PASS finished_utc=") for line in lines) != 1:
        raise ValueError(f"{mode}: runner success marker missing")
    if one_value(lines, "app_commit") != "f2f8920230b6f1dda3816c98d617a42fa59fdd76":
        raise ValueError(f"{mode}: source commit at run differs")
    if one_value(lines, "runner_sha256") != sha256(RUNNER):
        raise ValueError(f"{mode}: runner source digest differs")
    if one_value(lines, "input_aar_sha256") != EXPECTED_AARS[mode]:
        raise ValueError(f"{mode}: input AAR digest differs")
    test_file = "native_mobile_sdk_legacy_probe_test.dart" if mode in ("legacy", "maintained") else (
        "native_mobile_sdk_tls_fixture_test.dart" if mode == "tls" else
        "native_mobile_sdk_bls_oracle_test.dart" if mode == "bls" else
        "native_mobile_sdk_test.dart"
    )
    if one_value(lines, "test_source_sha256") != sha256(
        ROOT / "tools/android_native_smoke/harness/integration_test" / test_file
    ):
        raise ValueError(f"{mode}: fixture test source differs")
    if one_value(lines, "harness_kotlin_sha256") != sha256(
        ROOT / "tools/android_native_smoke/harness/android/app/src/main/kotlin/com/n42/android_native_smoke/MainActivity.kt"
    ):
        raise ValueError(f"{mode}: harness Kotlin source differs")
    if one_value(lines, "harness_gradle_sha256") != sha256(
        ROOT / "tools/android_native_smoke/harness/android/app/build.gradle.kts"
    ):
        raise ValueError(f"{mode}: harness Gradle source differs")
    apk_native = one_value(lines, "arm64_libmobile_sdk_apk_sha256")
    if apk_native != one_value(lines, "arm64_libmobile_sdk_stripped_input_sha256"):
        raise ValueError(f"{mode}: APK native member does not match stripped input")
    if mode == "bls" and one_value(lines, "bls_oracle_apk_sha256") != one_value(
        lines, "bls_oracle_stripped_input_sha256"
    ):
        raise ValueError("BLS oracle APK member does not match stripped input")
    if mode == "tls":
        if one_value(lines, "tls_certificate_decisions") != "20/20":
            raise ValueError("TLS certificate decision count differs")
        if sum("mock tests: test passed" in line for line in lines) != 19:
            raise ValueError("TLS mock certificate cases differ")
        if sum("mock root verification: test passed" in line for line in lines) != 1:
            raise ValueError("TLS default-root case differs")
    return {
        "exit_code": 0,
        "input_aar_sha256": one_value(lines, "input_aar_sha256"),
        "debug_apk_sha256": one_value(lines, "fixture_debug_apk_sha256"),
        "apk_arm64_libmobile_sdk_sha256": apk_native,
        "log": str(path.relative_to(ROOT)),
        "log_sha256": sha256(path),
    }


def evidence_files() -> list[Path]:
    dirs = [EVIDENCE, ROOT / "tools/android_native_smoke/tls_fixture_v0_5_3"]
    files = [path for directory in dirs for path in directory.rglob("*") if path.is_file()]
    bls = ROOT / "tools/android_native_smoke/bls_oracle"
    files.extend(bls / name for name in (
        "Cargo.lock", "Cargo.toml", "README.md", "rebuild_android.sh", "src/lib.rs"
    ))
    files.extend([
        RUNNER,
        Path(__file__).resolve(),
        ROOT / "tools/android_native_smoke/compare_mobile_sdk_vectors.py",
        ROOT / "tools/android_native_smoke/harness/android/app/build.gradle.kts",
        ROOT / "tools/android_native_smoke/harness/android/app/src/main/kotlin/com/n42/android_native_smoke/MainActivity.kt",
    ])
    files.extend((ROOT / "tools/android_native_smoke/harness/integration_test").glob("native_mobile_sdk*_test.dart"))
    return sorted(set(path for path in files if path != MANIFEST and path.suffix != ".pyc"))


def make_manifest() -> dict:
    for relative, expected in (
        ("android/app/libs/mobile-sdk-android.aar", EXPECTED_AARS["native"]),
        ("plugins/flutter_mining/android/libs/mobile-sdk-release.aar", EXPECTED_AARS["native"]),
        ("plugins/flutter_mining/android/libs/rustls-platform-verifier-0.1.1.aar",
         "667292cadd8fa589229dd0f716541236a761f29b774930868d218175633830fd"),
    ):
        if sha256(ROOT / relative) != expected:
            raise ValueError(f"Tracked artifact digest differs: {relative}")
    archived_diff = json.loads((EVIDENCE / "rust/legacy-v0.2.2-transaction-diff.json").read_text())
    for mode, expected in (("legacy", archived_diff["old_raw"]),
                           ("maintained", archived_diff["new_raw"])):
        log = (EVIDENCE / f"{mode}-runtime.log").read_text().splitlines()
        vectors = [line.split("LEGACY_VECTOR_JSON:", 1)[1]
                   for line in log if "LEGACY_VECTOR_JSON:" in line]
        if len(vectors) != 1:
            raise ValueError(f"{mode}: expected one raw vector, found {len(vectors)}")
        actual = json.loads(vectors[0])
        if {name: actual[name] for name in ("deposit", "exit", "feeCall")} != expected:
            raise ValueError(f"{mode}: current device vector differs from archived raw output")
    if "Old/new transaction payloads match" not in (EVIDENCE / "vector-comparison.log").read_text():
        raise ValueError("Current old/new comparator PASS is missing")
    if "ValueError: Unexpected new deposit gas" not in (
        EVIDENCE / "vector-comparison-negative.log"
    ).read_text():
        raise ValueError("Mutated-gas comparator rejection is missing")
    files = {str(path.relative_to(ROOT)): {"sha256": sha256(path), "bytes": path.stat().st_size}
             for path in evidence_files()}
    for relative in (
        "android/app/libs/mobile-sdk-android.aar",
        "plugins/flutter_mining/android/libs/mobile-sdk-release.aar",
        "plugins/flutter_mining/android/libs/rustls-platform-verifier-0.1.1.aar",
    ):
        path = ROOT / relative
        files[relative] = {"sha256": sha256(path), "bytes": path.stat().st_size}
    runs = {mode: run_record(mode) for mode in EXPECTED_AARS}
    return {
        "schema": 1,
        "description": "Task16B bounded evidence; debug fixture APKs are not release artifacts",
        "source_commit_at_run": "f2f8920230b6f1dda3816c98d617a42fa59fdd76",
        "selected_maintained_aar_sha256": EXPECTED_AARS["native"],
        "release_apk_sha256": "9da4974f11427749786996d1f40e26c99e402db8a4640c9e5c5499848171ecc0",
        "release_aab_sha256": "0fe3da0660c5b35011516bcb49a5e041855304f5e2f4293de238fd23c540b9c4",
        "runs": runs,
        "files": files,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true", help="replace manifest after adding evidence")
    args = parser.parse_args()
    generated = make_manifest()
    if args.write:
        MANIFEST.write_text(json.dumps(generated, indent=2, sort_keys=True) + "\n")
    elif json.loads(MANIFEST.read_text()) != generated:
        raise SystemExit("Evidence file digest or run binding differs from manifest")
    print(f"verified {len(generated['files'])} files and {len(generated['runs'])} strict16KB runs")


if __name__ == "__main__":
    main()
