#!/usr/bin/env python3
"""Verify the separate exact-adapter Wallet Core fixture on two distinct page modes."""

import argparse
from hashlib import sha256
import json
from pathlib import Path
import re
import struct
import subprocess
from zipfile import ZipFile, ZIP_STORED


ROOT = Path(__file__).resolve().parents[2]
EPOCH = ROOT / "tools/android_native_smoke/walletcore_api_fixture/fixture-build-epoch.json"
EPOCH_SHA256 = "ccc3aaf38b5e82c762fd861c5e3f8781ea2ed5b72571a4843a43e6582dcd1a39"
APK_SHA256 = "f3f627565b70b42787f15bce7cf1c8024a6c4696b916a289e196a96d6526b855"
NATIVE_SHA256 = "f2ad3625ae3e691369baaf3bede441f9b56500e5a2655b33baa0ca2866fa3a3d"
MEMBER = "lib/arm64-v8a/libTrustWalletCore.so"
PACKAGE = "ai.n42.fixture.walletcoreapi"
TAG = "N42_WC_API_FIXTURE"
DEVICES = {"emulator-5560": {"sdk": None, "page": 16384, "strict": True},
           "emulator-5562": {"sdk": "26", "page": 4096, "strict": False}}
TOOLS = {
    "/opt/homebrew/share/android-commandlinetools/platform-tools/adb": "534893b946847fdf6f9998108af469e646679824d75098247ca438948fa2dffc",
    "/opt/homebrew/share/android-commandlinetools/build-tools/36.0.0/aapt": "170717682f714712c5b6854af73cfe37aeda342ff422384e98d67fc1b490f49b",
    "/opt/homebrew/share/android-commandlinetools/build-tools/36.0.0/zipalign": "0427144f4a3fd242c5a159e7088637082539ae556bc1d2bbc2032bb775d47cea",
    "/opt/homebrew/share/android-commandlinetools/build-tools/36.0.0/apksigner": "b47549e373b895ce6ca620d0c7887e674d9615ffa837a86ac601dcfd04adb0f0",
}
SOURCES = (
    "android/app/src/main/java/ai/n42/www/walletcore/BitcoinV2SigningAdapter.java",
    "android/app/src/main/kotlin/ai/n42/www/walletcore/TransactionSignerHandler.kt",
    "scripts/build_walletcore_api_fixture.py",
    "tools/android_native_smoke/walletcore_api_fixture/settings.gradle.kts",
    "tools/android_native_smoke/walletcore_api_fixture/build.gradle.kts",
    "tools/android_native_smoke/walletcore_api_fixture/app/build.gradle.kts",
    "tools/android_native_smoke/walletcore_api_fixture/app/src/main/AndroidManifest.xml",
    "tools/android_native_smoke/walletcore_api_fixture/app/src/main/java/ai/n42/fixture/walletcoreapi/MainActivity.java",
    "tools/android_native_smoke/walletcore_api_fixture/fixture-build-epoch.json",
    "tools/android_native_smoke/run_walletcore_api_fixture.py",
    "tools/android_native_smoke/verify_walletcore_api_fixture.py",
)
EXPECTED_ENCODED = "02000000017be4e642bb278018ab12277de9427773ad1c5f5b1d164a157e0d99aa48dc1c1e000000006a473044022078eda020d4b86fcb3af78ef919912e6d79b81164dbbb0b0b96da6ac58a2de4b102201a5fd8d48734d5a02371c4b5ee551a69dca3842edbf577d863cf8ae9fdbbd4590121036666dd712e05a487916384bfcd5973eb53e8038eccbbf97f7eed775b87389536ffffffff01c0aff629010000001976a9145eaaa4f458f9158f86afcba08dd7448d27045e3d88ac00000000"
EXPECTED_TXID = "c19f410bf1d70864220e93bca20f836aaaf8cdde84a46692616e9f4480d54885"


def require(value, reason):
    if not value:
        raise ValueError(reason)


def digest(path):
    return sha256(Path(path).read_bytes()).hexdigest()


def inspect_apk(apk, page):
    with ZipFile(apk) as archive, Path(apk).open("rb") as stream:
        names = archive.namelist()
        require(len(names) == len(set(names)), "duplicate APK ZIP members")
        entry = archive.getinfo(MEMBER)
        require(entry.compress_type == ZIP_STORED, "APK native member compressed")
        stream.seek(entry.header_offset)
        header = stream.read(30)
        require(len(header) == 30 and header[:4] == b"PK\x03\x04", "APK local header invalid")
        name_len, extra_len = struct.unpack_from("<HH", header, 26)
        require(stream.read(name_len).decode() == MEMBER, "APK local member name differs")
        offset = entry.header_offset + 30 + name_len + extra_len
        require(offset % 16384 == 0, "APK native ZIP member lacks 16 KB alignment")
        native = archive.read(entry)
    require(sha256(native).hexdigest() == NATIVE_SHA256, "APK native bytes changed")
    require(native[:6] == b"\x7fELF\x02\x01" and
            struct.unpack_from("<H", native, 18)[0] == 183, "APK native is not ELF64 AArch64")
    phoff = struct.unpack_from("<Q", native, 32)[0]
    entsize, count = struct.unpack_from("<HH", native, 54)
    require(entsize >= 56 and count > 0 and phoff + entsize * count <= len(native),
            "APK native program headers invalid")
    loads, relro, executable = [], [], []
    for index in range(count):
        start = phoff + index * entsize
        kind, flags = struct.unpack_from("<II", native, start)
        file_offset, address = struct.unpack_from("<QQ", native, start + 8)
        file_size = struct.unpack_from("<Q", native, start + 32)[0]
        if kind == 1:
            alignment = struct.unpack_from("<Q", native, start + 48)[0]
            require(alignment >= 16384 and (address - file_offset) % 16384 == 0,
                    "native LOAD lacks 16 KB link alignment")
            loads.append(index)
            if flags & 1:
                require(file_offset + file_size <= len(native), "native executable LOAD exceeds member")
                begin = offset + file_offset // page * page
                length = (file_offset + file_size + page - 1) // page * page - file_offset // page * page
                executable.append([begin, length])
        elif kind == 0x6474e552:
            size = struct.unpack_from("<Q", native, start + 40)[0]
            relro.append((address + size) % 16384 == 0)
    require(loads and relro and all(relro) and executable, "native LOAD/RELRO or executable LOAD missing")
    return {"native_sha256": NATIVE_SHA256, "member_data_offset": offset,
            "executable_loads": executable, "static_16kb_aligned": True}


def require_epoch(task, apk):
    raw = EPOCH.read_bytes()
    require(sha256(raw).hexdigest() == EPOCH_SHA256, "fixture build epoch changed")
    epoch = json.loads(raw)
    require(epoch.get("schema_version") == 1 and epoch.get("apk_sha256") == APK_SHA256 and
            epoch.get("apk_arm64_member_sha256") == NATIVE_SHA256 and
            (task / epoch["task_artifact"]).resolve() == Path(apk).resolve(),
            "fixture build epoch fields/path changed")
    require(digest(apk) == APK_SHA256, "pinned fixture APK changed")
    require(digest(ROOT / "scripts/build_walletcore_api_fixture.py") == epoch["builder_sha256"],
            "compiled builder source changed")
    require(digest(ROOT / "android/app/src/main/java/ai/n42/www/walletcore/BitcoinV2SigningAdapter.java") ==
            epoch["compiled_adapter_sha256"], "compiled production adapter changed")
    base = ROOT / "tools/android_native_smoke/walletcore_api_fixture"
    for relative, expected in epoch["compiled_fixture_source_sha256"].items():
        require(digest(base / relative) == expected, f"compiled fixture source changed: {relative}")
    require(inspect_apk(apk, 16384)["member_data_offset"] ==
            epoch["apk_arm64_member_data_offset"], "pinned APK ZIP offset changed")
    return epoch


def require_git_head(head, hashes):
    require(isinstance(head, str) and re.fullmatch(r"[a-f0-9]{40}", head), "git HEAD invalid")
    require(set(hashes) == set(SOURCES), "reviewed source set changed")
    for relative in SOURCES:
        expected = digest(ROOT / relative)
        require(hashes[relative] == expected, f"source receipt changed: {relative}")
        shown = subprocess.run(["git", "show", f"{head}:{relative}"], cwd=ROOT,
                               capture_output=True, check=False)
        require(shown.returncode == 0 and sha256(shown.stdout).hexdigest() == expected,
                f"source differs from reviewed git HEAD: {relative}")


def require_snapshot(snapshot, serial, label):
    policy = DEVICES[serial]
    common = {"state": "device", "boot": "1",
              "abi": "arm64-v8a", "airplane": "1", "wifi": "0", "route": ""}
    for key, expected in common.items():
        item = snapshot.get(key, {})
        require(item.get("exit") == 0 and item.get("stdout") == expected,
                f"{label}: {serial} {key} state changed")
    sdk = snapshot.get("sdk", {})
    require(sdk.get("exit") == 0 and
            (sdk.get("stdout") == "26" if serial == "emulator-5562" else
             sdk.get("stdout", "").isdigit() and int(sdk["stdout"]) >= 35),
            f"{label}: {serial} SDK identity changed")
    require(snapshot.get("default_network", {}).get("exit") == 0 and
            "Active default network: none" in snapshot["default_network"]["stdout"],
            f"{label}: {serial} active network present")
    if policy["strict"]:
        for key, expected in (("page", "16384"), ("linker", "fatal"), ("compat", "true")):
            item = snapshot.get(key, {})
            require(item.get("exit") == 0 and item.get("stdout") == expected,
                    f"{label}: strict 16 KB {key} changed")
    else:
        item = snapshot.get("page", {})
        require(item.get("exit") == 0 and
                re.fullmatch(r"KernelPageSize:\s+4 kB", item.get("stdout", "")),
                f"{label}: API 26 /proc/1/smaps did not prove 4 KB pages")


def parse_events(log, token):
    lines = [row for row in log.splitlines() if f"{TAG}:" in row]
    require(lines, "fixture logcat records missing")
    events = []
    for row in lines:
        match = re.fullmatch(
            rf"\d\d-\d\d\s+\d\d:\d\d:\d\d\.\d+\s+(\d+)\s+\d+\s+I\s+{TAG}:\s+(.+)",
            row)
        require(match, "malformed fixture logcat framing")
        try:
            event = json.loads(match.group(2))
        except json.JSONDecodeError as error:
            raise ValueError("malformed or truncated fixture record") from error
        require(isinstance(event, dict) and event.get("token") == token and
                type(event.get("pid")) is int and event["pid"] == int(match.group(1)),
                "stale, foreign or PID-mismatched fixture record")
        events.append(event)
    require([event.get("kind") for event in events] ==
            ["BEGIN", "LOADED", "CASE", "CASE", "END"], "fixture records missing/out of order")
    require(len({event["pid"] for event in events}) == 1, "fixture records span processes")
    require([event.get("name") for event in events[2:4]] ==
            ["taggedP2pkh", "unsupportedP2wsh"], "fixture case set changed")
    return events


def require_maps(rows, apk_path, loads):
    require(isinstance(rows, list) and rows, "native executable mappings missing")
    observed = []
    for row in rows:
        match = re.fullmatch(
            r"([0-9a-f]+)-([0-9a-f]+)\s+r-xp\s+([0-9a-f]+)\s+\S+\s+\d+\s+(.+)", row)
        if match and match.group(4) == apk_path:
            observed.append([int(match.group(3), 16),
                             int(match.group(2), 16) - int(match.group(1), 16)])
    for offset, length in loads:
        require(any(start == offset and size >= length for start, size in observed),
                f"executable APK map misses native LOAD at {offset}")


def verify_device(serial, item, apk):
    policy = DEVICES[serial]
    require_snapshot(item.get("pre", {}), serial, "pre")
    require_snapshot(item.get("post", {}), serial, "post")
    for key in ("install", "clear", "pm_path", "pull", "logcat_clear", "start", "force_stop"):
        require(item.get(key, {}).get("exit") == 0, f"{serial}: {key} failed")
    require(item.get("badging", {}).get("exit") == 0 and
            f"package: name='{PACKAGE}'" in item["badging"]["stdout"] and
            item.get("permissions", {}).get("exit") == 0 and
            "uses-permission" not in item["permissions"]["stdout"] and
            item.get("zipalign", {}).get("exit") == 0 and
            item.get("apksigner", {}).get("exit") == 0,
            f"{serial}: APK package, permission, ZIP or signature proof changed")
    if policy["strict"]:
        require(len(item.get("strict_setup", [])) == 4 and
                all(step.get("exit") == 0 for step in item["strict_setup"]),
                "strict 16 KB setup proof missing")
    else:
        require_snapshot(item.get("initial", {}), serial, "initial")
    require(item.get("pulled_apk_sha256") == APK_SHA256, f"{serial}: installed APK bytes differ")
    require(item.get("token") and re.fullmatch(r"[a-f0-9]{32}", item["token"]),
            f"{serial}: launch nonce missing")
    require(item.get("result_logcat", {}).get("exit") == 0, f"{serial}: logcat read failed")
    events = parse_events(item["result_logcat"]["stdout"], item["token"])
    require(events == item.get("events"), f"{serial}: parsed events differ from raw logcat")
    begin, loaded, positive, negative, end = events
    apk_path = begin.get("apkPath")
    require(isinstance(apk_path, str) and apk_path.startswith("/data/app/") and
            apk_path.endswith("/base.apk") and
            item["pm_path"]["stdout"] == f"package:{apk_path}",
            f"{serial}: installed APK path changed")
    require(begin.get("apkSha256") == APK_SHA256 and
            begin.get("libraryLookupPath") == f"{apk_path}!/{MEMBER}",
            f"{serial}: classloader selected different APK/native bytes")
    info = inspect_apk(apk, policy["page"])
    require(item.get("apk_info") == info, f"{serial}: APK native map inputs differ")
    require_maps(loaded.get("nativeMaps"), apk_path, info["executable_loads"])
    require(end.get("status") == "PASS" and positive.get("outcome") ==
            negative.get("outcome") == "PASS", f"{serial}: fixture JNI case failed")
    result = positive.get("result", {})
    require(result.get("encoded") == EXPECTED_ENCODED and
            result.get("encodedSha256") == sha256(bytes.fromhex(EXPECTED_ENCODED)).hexdigest() and
            result.get("rawSignatureControlSha256") == result["encodedSha256"] and
            result.get("txid") == EXPECTED_TXID,
            f"{serial}: direct adapter tagged golden differs")
    require("Error_not_supported" in negative.get("result", {}).get("error", ""),
            f"{serial}: unsupported P2WSH did not propagate explicit error")
    return {"pid": begin["pid"], "sdk": item["pre"]["sdk"]["stdout"], "page": policy["page"],
            "strict_16kb": policy["strict"], "apk_sha256": APK_SHA256,
            "native_sha256": NATIVE_SHA256, "cases": [positive, negative]}


def verify(receipt, task, apk):
    require(receipt.get("schema_version") == 1 and set(receipt.get("devices", {})) == set(DEVICES),
            "receipt schema/device set changed")
    epoch = require_epoch(task, apk)
    require(receipt.get("build_epoch") == epoch and
            receipt.get("build_epoch_sha256") == EPOCH_SHA256 and
            receipt.get("apk_sha256") == APK_SHA256, "receipt epoch/APK differs")
    require(receipt.get("device_tools") == TOOLS and
            all(Path(path).is_file() and digest(path) == expected for path, expected in TOOLS.items()),
            "device tool identity changed")
    require_git_head(receipt.get("git_head"), receipt.get("source_sha256", {}))
    devices = {serial: verify_device(serial, receipt["devices"][serial], apk)
               for serial in DEVICES}
    return {"passed": True, "devices": devices}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--task-root", required=True, type=Path)
    parser.add_argument("--apk", required=True, type=Path)
    parser.add_argument("--receipt", required=True, type=Path)
    args = parser.parse_args()
    result = verify(json.loads(args.receipt.read_text()), args.task_root.resolve(),
                    args.apk.resolve())
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
