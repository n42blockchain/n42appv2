#!/usr/bin/env python3
"""Verify the archived Vodo release AAR, exact APK and strict runtime proof."""

import gzip
from hashlib import sha256
import json
from pathlib import Path
import subprocess
import sys
import tempfile
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parent


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    h = sha256()
    with path.open("rb") as stream:
        while chunk := stream.read(1024 * 1024):
            h.update(chunk)
    return h.hexdigest()


def verify():
    manifest = json.loads((ROOT / "manifest.json").read_text())
    expected = manifest["files"]
    actual = {
        str(path.relative_to(ROOT))
        for path in ROOT.rglob("*")
        if path.is_file() and path.name != "manifest.json"
    }
    require(actual == expected.keys(), "archive member set differs from manifest")
    for name, expected_hash in expected.items():
        require(digest(ROOT / name) == expected_hash, f"archive member hash mismatch: {name}")
    for name, expected_hash in manifest["implementation_files_at_fixture_commit"].items():
        require(digest(ROOT / "source" / name) == expected_hash, f"source snapshot mismatch: {name}")

    aar = ROOT / "artifacts/flutter_vodozemac-release.aar"
    require(digest(aar) == manifest["release_aar_sha256"], "release AAR hash mismatch")
    with ZipFile(aar) as archive:
        member = archive.read("jni/arm64-v8a/libvodozemac_bindings_dart.so")
    require(sha256(member).hexdigest() == manifest["release_arm64_member_sha256"],
            "release AAR arm64 member mismatch")
    compressed = ROOT / "artifacts/vodo-release-run2.apk.gz"
    require(digest(compressed) == manifest["fixture_apk_gzip_sha256"], "gzip APK hash mismatch")

    with tempfile.TemporaryDirectory(prefix="vodo-evidence-") as directory:
        temporary = Path(directory)
        apk = temporary / "fixture.apk"
        with gzip.open(compressed, "rb") as source, apk.open("wb") as destination:
            while chunk := source.read(1024 * 1024):
                destination.write(chunk)
        require(apk.stat().st_size == manifest["fixture_apk_uncompressed_bytes"],
                "decompressed APK size mismatch")
        require(digest(apk) == manifest["fixture_apk_sha256"], "decompressed APK hash mismatch")

        runtime_log = temporary / "runtime.log"
        with gzip.open(ROOT / "logs/vodo-release-runtime.log.gz", "rb") as source:
            runtime_log.write_bytes(source.read())
        receipt = ROOT / "checks/vodo-release-inputs.json"
        verifier = ROOT / "source/tools/android_native_smoke/verify_vodo_release_fixture.py"
        result = subprocess.run(
            [sys.executable, str(verifier), "--aar", str(aar), "--apk", str(apk),
             "--log", str(runtime_log), "--receipt", str(receipt)],
            capture_output=True, text=True, check=False,
        )
        require(result.returncode == 0, f"archived runtime verifier failed: {result.stderr.strip()}")
        recorded = json.loads((ROOT / "checks/task-16f-vodo-release-verifier-run2.json").read_text())
        require(json.loads(result.stdout) == recorded, "replayed runtime receipt differs")

    return len(expected)


def main():
    try:
        count = verify()
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(f"Vodo evidence rejected: {error}", file=sys.stderr)
        return 1
    print(f"VODO_EVIDENCE_PASS members={count} strict_release_runtime=true")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
