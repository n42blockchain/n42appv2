#!/usr/bin/env python3
"""Bind the isolated Vodo release runtime log to its reviewed ELF bytes."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import sys
from zipfile import BadZipFile, ZipFile, ZIP_STORED


EXPECTED_AAR_SHA256 = "7878472e22facc668152fff6c9e6a8858f9906b7994fd28c8d66b2c22822501a"
EXPECTED_RELEASE_SHA256 = "3807e8f54bf9be576ebe55aa41e363e7b23b845efb971f5821f439ab90ca14fa"
AAR_MEMBER = "jni/arm64-v8a/libvodozemac_bindings_dart.so"
APK_MEMBER = "lib/arm64-v8a/libvodozemac_release_probe.so"
DEBUG_MEMBER = "lib/arm64-v8a/libvodozemac_bindings_dart.so"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha256(body):
    return hashlib.sha256(body).hexdigest()


def member(zipped, name, *, require_stored=False):
    info = zipped.getinfo(name)
    body = zipped.read(name)
    if require_stored:
        require(info.compress_type == ZIP_STORED, f"{name} is not stored in the ZIP")
    require(info.file_size == len(body), f"{name} size mismatch")
    return info, body


def stored_data_range(zip_path, info):
    with zip_path.open("rb") as stream:
        stream.seek(info.header_offset)
        header = stream.read(30)
        require(len(header) == 30 and header[:4] == b"PK\x03\x04", "bad local ZIP header")
        name_length, extra_length = struct.unpack_from("<HH", header, 26)
        name = stream.read(name_length)
        require(name.decode("utf-8") == info.filename, "local and central ZIP names differ")
        start = info.header_offset + 30 + name_length + extra_length
        return start, start + info.file_size


def verify_strict_snapshot(snapshot, phase):
    expected = {
        "page_size": "16384",
        "linker_mode": "fatal",
        "package_compat_disabled": "true",
        "airplane_mode": "1",
        "ip_route": "",
    }
    require(isinstance(snapshot, dict), f"missing {phase} device snapshot")
    for name, value in expected.items():
        observed = snapshot.get(name)
        require(isinstance(observed, dict), f"{phase} missing {name}")
        require(observed.get("exit") == 0, f"{phase} {name} command failed")
        require(observed.get("stdout") == value, f"{phase} {name} mismatch")


def verify(aar_path, apk_path, log_path, receipt_path):
    receipt = json.loads(receipt_path.read_text())
    require(receipt.get("schema_version") == 1, "receipt schema mismatch")
    require(receipt.get("device") == "emulator-5560", "device mismatch")
    verify_strict_snapshot(receipt.get("pre"), "pre")
    verify_strict_snapshot(receipt.get("post"), "post")
    command = receipt.get("fixture_command")
    require(
        isinstance(command, list)
        and len(command) == 7
        and command[0].endswith("/flutter")
        and command[1:] == [
            "test", "integration_test/vodo_android_16k_test.dart", "-d",
            "emulator-5560", "--no-pub", "--dart-define=N42_VODO_RELEASE_PROBE=true",
        ],
        "release fixture invocation mismatch",
    )
    require(receipt.get("fixture_exit") == 0, "release fixture command failed")
    environment = receipt.get("fixture_environment")
    require(isinstance(environment, dict), "missing fixture environment")
    require(environment.get("CARGO_NET_OFFLINE") == "true", "Cargo offline mode missing")
    require(environment.get("CARGOKIT_PUB_OFFLINE") == "1", "pub offline mode missing")
    require(environment.get("N42_SMOKE_VODO_RELEASE_JNILIBS"), "release probe source missing")
    sources = receipt.get("source_sha256")
    require(isinstance(sources, dict) and len(sources) >= 7, "source identity missing")
    require(
        sources.get("tools/android_native_smoke/harness/fixtures/vodozemac-0.5-pickles.json")
        == "fb333c76054d891503537433db553aa25c1210581a6c96540b617e0c536d74da",
        "synthetic vector identity mismatch",
    )

    aar_body = aar_path.read_bytes()
    aar_hash = sha256(aar_body)
    require(aar_hash == EXPECTED_AAR_SHA256, "release AAR hash mismatch")
    with ZipFile(aar_path) as aar:
        _, release_body = member(aar, AAR_MEMBER)
    release_hash = sha256(release_body)
    require(release_hash == EXPECTED_RELEASE_SHA256, "release AAR arm64 member hash mismatch")
    require(receipt.get("aar_sha256") == aar_hash, "receipt AAR hash mismatch")
    require(receipt.get("aar_arm64_member_sha256") == release_hash, "receipt release member mismatch")
    require(receipt.get("probe_sha256") == release_hash, "fixture probe hash mismatch")

    apk_hash = sha256(apk_path.read_bytes())
    require(receipt.get("apk_sha256") == apk_hash, "receipt APK hash mismatch")
    with ZipFile(apk_path) as apk:
        release_info, packaged_body = member(apk, APK_MEMBER, require_stored=True)
        _, debug_body = member(apk, DEBUG_MEMBER)
        start, end = stored_data_range(apk_path, release_info)
    require(packaged_body == release_body, "packaged release probe differs from AAR member")
    require(start % 16384 == 0, "release probe ZIP data is not 16 KiB aligned")
    require(sha256(debug_body) != release_hash, "release probe not distinct from debug member")

    log_body = log_path.read_bytes()
    require(receipt.get("fixture_log_sha256") == sha256(log_body), "runtime log hash mismatch")
    log = log_body.decode("utf-8")
    lines = re.findall(
        r"^VODO_NATIVE_MAP variant=release pid=(\d+) symbol=account_ed25519_key "
        r"map=([0-9a-f]+)-([0-9a-f]+) (r-xp) ([0-9a-f]+) .*?(/data/app/[^\s]+/base\.apk)$",
        log,
        re.MULTILINE,
    )
    require(len(lines) == 1, "expected one release FRB executable map")
    pid, map_start, map_end, _, map_offset, mapped_apk = lines[0]
    installed = re.findall(
        r"^VODO_INSTALLED_APK variant=release pid=(\d+) sha256=([0-9a-f]{64}) "
        r"path=(/data/app/[^\s]+/base\.apk)$",
        log,
        re.MULTILINE,
    )
    require(len(installed) == 1, "expected one device-computed APK identity")
    installed_pid, installed_hash, installed_path = installed[0]
    require(installed_pid == pid, "installed APK process differs from FRB map")
    require(installed_path == mapped_apk, "installed APK path differs from FRB map")
    require(installed_hash == apk_hash, "installed APK hash differs from local artifact")
    require(
        receipt.get("installed") == {
            "pid": int(pid), "sha256": installed_hash, "path": installed_path,
        },
        "receipt installed APK identity mismatch",
    )
    mapped_length = int(map_end, 16) - int(map_start, 16)
    map_offset_int = int(map_offset, 16)
    require(int(pid) > 0 and mapped_length > 0, "invalid release process or map")
    require(
        start <= map_offset_int and map_offset_int + mapped_length <= end,
        "FRB executable map is outside the packaged release ELF",
    )
    require(
        log.count("VODO_CRYPTO_PASS legacy_account=true legacy_sessions=true fresh=true") == 1,
        "missing or duplicate release crypto result",
    )
    require("+1: All tests passed!" in log, "release fixture did not pass")

    return {
        "aar_sha256": aar_hash,
        "aar_arm64_member_sha256": release_hash,
        "apk_sha256": apk_hash,
        "apk_release_member_sha256": sha256(packaged_body),
        "apk_debug_member_sha256": sha256(debug_body),
        "log_sha256": sha256(log_path.read_bytes()),
        "receipt_sha256": sha256(receipt_path.read_bytes()),
        "installed_apk_sha256": installed_hash,
        "installed_apk_path": installed_path,
        "release_member_data_range": [start, end],
        "release_executable_map_file_range": [map_offset_int, map_offset_int + mapped_length],
        "runtime_pid": int(pid),
        "runtime_crypto_pass": True,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--aar", required=True, type=Path)
    parser.add_argument("--apk", required=True, type=Path)
    parser.add_argument("--log", required=True, type=Path)
    parser.add_argument("--receipt", required=True, type=Path)
    args = parser.parse_args()
    try:
        result = verify(args.aar, args.apk, args.log, args.receipt)
    except (OSError, ValueError, KeyError, TypeError, struct.error, BadZipFile) as error:
        print(f"Vodo release fixture rejected: {error}", file=sys.stderr)
        return 1
    print(json.dumps(result, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
