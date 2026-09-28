#!/usr/bin/env python3
"""Verify the exact two-APK Wallet Core synthetic JNI build and device receipt."""

import argparse
from hashlib import sha256
import json
from pathlib import Path
import re
import struct
import subprocess
import sys
from zipfile import ZipFile, ZIP_STORED


ROOT = Path(__file__).resolve().parents[2]
DEVICE = "emulator-5560"
PAGE = 16384
MEMBER = "lib/arm64-v8a/libTrustWalletCore.so"
EPOCH = ROOT / "tools/android_native_smoke/walletcore_fixture/fixture-build-epoch.json"
EPOCH_SHA256 = "7972005cc581a681c2921b101eacb8e49157eaf424c9f05479abef1b3e471ac9"
BUILD_HEAD = "89e214c2a6f30c0a5ee7c7c26682eeb110207df0"
APK_SHA256 = {
    "baseline": "ac812aa92dcbd548cf255fe7fa16d1bb6a87d3cc2b7148877fedc2eab9ddcd19",
    "candidate": "86f81f61703dbdb31d52ce0c643fb03cc0797dc09a095e20cf72066724259f90",
}
MEMBER_SHA256 = {
    "baseline": "d01ca3db4312b3b64e3f8feddf581c3be8d25d729456873bb9042ed8c2d447e7",
    "candidate": "f2ad3625ae3e691369baaf3bede441f9b56500e5a2655b33baa0ca2866fa3a3d",
}
PACKAGES = {phase: f"ai.n42.fixture.walletcore.{phase}" for phase in APK_SHA256}
DEVICE_TOOL_SHA256 = {
    "/opt/homebrew/share/android-commandlinetools/platform-tools/adb": "534893b946847fdf6f9998108af469e646679824d75098247ca438948fa2dffc",
    "/opt/homebrew/share/android-commandlinetools/build-tools/36.0.0/aapt": "170717682f714712c5b6854af73cfe37aeda342ff422384e98d67fc1b490f49b",
    "/opt/homebrew/share/android-commandlinetools/build-tools/36.0.0/zipalign": "0427144f4a3fd242c5a159e7088637082539ae556bc1d2bbc2032bb775d47cea",
    "/opt/homebrew/share/android-commandlinetools/build-tools/36.0.0/apksigner": "b47549e373b895ce6ca620d0c7887e674d9615ffa837a86ac601dcfd04adb0f0",
}
CASES = ("hdwallet", "ethereumLegacy", "ethereum1559", "bitcoinCompilerV2", "bitcoinAppP2wsh")
BUILD_SOURCES = (
    "tools/android_native_smoke/walletcore_fixture/settings.gradle.kts",
    "tools/android_native_smoke/walletcore_fixture/build.gradle.kts",
    "tools/android_native_smoke/walletcore_fixture/app/build.gradle.kts",
    "tools/android_native_smoke/walletcore_fixture/app/src/main/AndroidManifest.xml",
    "tools/android_native_smoke/walletcore_fixture/app/src/main/java/ai/n42/fixture/walletcore/MainActivity.java",
)
REVIEWED_SOURCES = BUILD_SOURCES + (
    "scripts/build_walletcore_fixture.py",
    "tools/android_native_smoke/walletcore_fixture/fixture-build-epoch.json",
    "tools/android_native_smoke/run_walletcore_fixture.py",
    "tools/android_native_smoke/verify_walletcore_fixture.py",
)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(value):
    return sha256(Path(value).read_bytes()).hexdigest()


def require_epoch(task, apks):
    raw = EPOCH.read_bytes()
    require(sha256(raw).hexdigest() == EPOCH_SHA256, "fixture build epoch changed")
    epoch = json.loads(raw)
    require(epoch.get("schema_version") == 1 and epoch.get("build_git_head") == BUILD_HEAD and
            epoch.get("fixture_source_commit") is None and
            epoch.get("apk_sha256") == APK_SHA256 and
            epoch.get("apk_arm64_member_sha256") == MEMBER_SHA256 and
            set(epoch.get("compiled_fixture_source_sha256", {})) == set(BUILD_SOURCES),
            "fixture build epoch fields changed")
    for name, expected in epoch["compiled_fixture_source_sha256"].items():
        require(digest(ROOT / name) == expected, f"compiled fixture source changed: {name}")
    require(digest(ROOT / "scripts/build_walletcore_fixture.py") ==
            epoch["build_script_sha256"], "fixture build script changed")
    for phase, apk in apks.items():
        require(digest(apk) == APK_SHA256[phase], f"{phase}: pinned APK changed")
        relative = epoch["apk_locations"][phase]
        require((task / relative).resolve() == apk.resolve(), f"{phase}: APK path changed")
        native, offset, _ = member_and_executable_offsets(apk)
        require(sha256(native).hexdigest() == MEMBER_SHA256[phase],
                f"{phase}: packaged native bytes changed")
        if phase == "candidate":
            require(aligned_elf(native), "candidate: APK member LOAD/RELRO is not 16 KB aligned")
        require(offset == epoch["apk_member_data_offset"][phase],
                f"{phase}: packaged native ZIP offset changed")
    sys.path.insert(0, str(ROOT / "scripts"))
    from build_walletcore_fixture import preflight
    _, inputs = preflight(task)
    require(inputs["input_sha256"] == epoch["input_sha256"] and
            inputs["aar_members"] == epoch["aar_members"] and
            inputs["gradle_sha256"] == epoch["gradle_sha256"] and
            inputs["aapt2_jar_sha256"] == epoch["aapt2_jar_sha256"] and
            inputs["aapt2_executable_sha256"] == epoch["aapt2_executable_sha256"],
            "fixture source/tool input epoch changed")
    return epoch


def require_git_epoch(head, observed_sources):
    require(isinstance(head, str) and re.fullmatch(r"[0-9a-f]{40}", head),
            "git head must be a full commit")
    require(set(observed_sources) == set(REVIEWED_SOURCES), "source receipt set changed")
    for relative in REVIEWED_SOURCES:
        expected = digest(ROOT / relative)
        require(observed_sources[relative] == expected, f"source receipt changed: {relative}")
        result = subprocess.run(["git", "show", f"{head}:{relative}"], cwd=ROOT,
                                capture_output=True, check=False)
        require(result.returncode == 0 and sha256(result.stdout).hexdigest() == expected,
                f"git commit does not contain reviewed source: {relative}")


def member_and_executable_offsets(apk):
    with ZipFile(apk) as archive, Path(apk).open("rb") as stream:
        names = archive.namelist()
        require(len(names) == len(set(names)), "duplicate APK ZIP entries")
        entry = archive.getinfo(MEMBER)
        require(entry.compress_type == ZIP_STORED, "native APK member is compressed")
        stream.seek(entry.header_offset)
        header = stream.read(30)
        require(len(header) == 30 and header[:4] == b"PK\x03\x04", "bad APK local ZIP header")
        name_len, extra_len = struct.unpack_from("<HH", header, 26)
        require(stream.read(name_len).decode() == MEMBER, "APK local member name differs")
        offset = entry.header_offset + 30 + name_len + extra_len
        require(offset % PAGE == 0, "native APK member lacks 16 KB ZIP alignment")
        data = archive.read(entry)
    require(data[:6] == b"\x7fELF\x02\x01" and struct.unpack_from("<H", data, 18)[0] == 183,
            "native APK member is not little-endian ELF64 AArch64")
    phoff = struct.unpack_from("<Q", data, 32)[0]
    phentsize, phnum = struct.unpack_from("<HH", data, 54)
    require(phentsize >= 56 and phnum > 0 and phoff + phentsize * phnum <= len(data),
            "native APK ELF headers invalid")
    loads = []
    for index in range(phnum):
        start = phoff + index * phentsize
        kind, flags = struct.unpack_from("<II", data, start)
        if kind == 1 and flags & 1:
            file_offset = struct.unpack_from("<Q", data, start + 8)[0]
            file_size = struct.unpack_from("<Q", data, start + 32)[0]
            require(file_offset + file_size <= len(data), "executable LOAD exceeds member")
            rounded = file_offset // PAGE * PAGE
            rounded_end = (file_offset + file_size + PAGE - 1) // PAGE * PAGE
            loads.append((offset + rounded, rounded_end - rounded))
    require(loads, "native APK ELF has no executable LOAD")
    return data, offset, loads


def aligned_elf(data):
    phoff = struct.unpack_from("<Q", data, 32)[0]
    phentsize, phnum = struct.unpack_from("<HH", data, 54)
    loads, relro = [], []
    for index in range(phnum):
        start = phoff + index * phentsize
        kind = struct.unpack_from("<I", data, start)[0]
        if kind == 1:
            file_offset, address = struct.unpack_from("<QQ", data, start + 8)
            alignment = struct.unpack_from("<Q", data, start + 48)[0]
            loads.append(alignment >= PAGE and (address - file_offset) % PAGE == 0)
        elif kind == 0x6474e552:
            address = struct.unpack_from("<Q", data, start + 16)[0]
            size = struct.unpack_from("<Q", data, start + 40)[0]
            relro.append((address + size) % PAGE == 0)
    return bool(loads) and bool(relro) and all(loads) and all(relro)


def require_strict(snapshot, label):
    for name, expected in (("page_size", "16384"), ("linker_mode", "fatal"),
                           ("package_compat_disabled", "true"),
                           ("airplane_mode", "1"), ("wifi_on", "0"),
                           ("ip_route", "")):
        item = snapshot.get(name)
        require(isinstance(item, dict) and item.get("exit") == 0 and
                item.get("stdout") == expected, f"{label}: strict/offline {name} changed")


def parse_events(output, phase, token):
    lines = [line for line in output.splitlines() if "N42_WALLETCORE_FIXTURE:" in line]
    require(lines, f"{phase}: no tagged in-process records")
    events = []
    for line in lines:
        match = re.fullmatch(
            r"\d\d-\d\d\s+\d\d:\d\d:\d\d\.\d+\s+(\d+)\s+\d+\s+I\s+N42_WALLETCORE_FIXTURE:\s+(.+)",
            line)
        require(match is not None, f"{phase}: malformed tagged logcat framing")
        try:
            event = json.loads(match.group(2))
        except json.JSONDecodeError as error:
            raise ValueError(f"{phase}: malformed or truncated fixture JSON") from error
        require(isinstance(event, dict) and event.get("phase") == phase and
                event.get("token") == token and
                type(event.get("pid")) is int and event["pid"] == int(match.group(1)),
                f"{phase}: stale, foreign or PID-mismatched record")
        events.append(event)
    kinds = [event.get("kind") for event in events]
    require(kinds[0] == "BEGIN" and kinds[-1] == "END" and
            kinds.count("BEGIN") == kinds.count("END") == 1,
            f"{phase}: incomplete or duplicate process framing")
    require(len({event["pid"] for event in events}) == 1, f"{phase}: records span PIDs")
    require(kinds.count("LOADED") <= 1, f"{phase}: duplicate native load record")
    if "LOADED" in kinds:
        require(kinds == ["BEGIN", "LOADED", *("CASE" for _ in CASES), "END"],
                f"{phase}: missing or unordered test cases")
        names = [event.get("name") for event in events if event.get("kind") == "CASE"]
        require(names == list(CASES), f"{phase}: test case names changed")
    else:
        require(kinds == ["BEGIN", "END"] and events[-1].get("status") == "FAIL",
                f"{phase}: missing native load without recorded failure")
    return events


def require_maps(lines, apk_path, loads, phase):
    require(isinstance(lines, list) and lines, f"{phase}: executable native maps missing")
    observed = []
    for line in lines:
        match = re.fullmatch(
            r"([0-9a-f]+)-([0-9a-f]+)\s+r-xp\s+([0-9a-f]+)\s+\S+\s+\d+\s+(.+)", line)
        if match and match.group(4) == apk_path:
            observed.append((int(match.group(3), 16),
                             int(match.group(2), 16) - int(match.group(1), 16)))
    for offset, length in loads:
        require(any(start == offset and size >= length for start, size in observed),
                f"{phase}: executable APK maps miss native LOAD at 0x{offset:x}")


def verify_phase(phase, item, apk):
    require(item.get("package") == PACKAGES[phase], f"{phase}: package changed")
    require(item.get("apk_sha256") == APK_SHA256[phase] == digest(apk),
            f"{phase}: local APK identity changed")
    for name in ("install", "clear", "pm_path", "pull", "logcat_clear", "start", "force_stop"):
        require(item.get(name, {}).get("exit") == 0, f"{phase}: {name} failed")
    require_strict(item.get("pre", {}), f"{phase} pre")
    require_strict(item.get("post", {}), f"{phase} post")
    require(item.get("pulled_apk_sha256") == APK_SHA256[phase],
            f"{phase}: installed pulled APK bytes differ")
    require(item.get("zipalign", {}).get("exit") == 0 and
            item.get("badging", {}).get("exit") == 0 and
            item.get("permissions", {}).get("exit") == 0 and
            "uses-permission" not in item["permissions"]["stdout"] and
            item.get("apksigner", {}).get("exit") == 0,
            f"{phase}: APK ZIP/package inspection failed")
    require(item.get("token") and re.fullmatch(r"[a-f0-9]{32}", item["token"]),
            f"{phase}: missing fresh launch token")
    fetched = item.get("result_logcat", {})
    require(fetched.get("exit") == 0, f"{phase}: logcat read failed")
    events = parse_events(fetched.get("stdout", ""), phase, item["token"])
    require(item.get("events") == events, f"{phase}: parsed records differ from raw logcat")
    begin, end = events[0], events[-1]
    apk_path = begin.get("apkPath")
    require(isinstance(apk_path, str) and apk_path.startswith("/data/app/") and
            apk_path.endswith("/base.apk") and
            item["pm_path"]["stdout"] == f"package:{apk_path}",
            f"{phase}: installed package path changed")
    require(begin.get("apkSha256") == APK_SHA256[phase],
            f"{phase}: in-process installed APK hash differs")
    require(begin.get("libraryLookupPath") == f"{apk_path}!/{MEMBER}",
            f"{phase}: classloader selected a different native member")
    require(begin["pid"] > 0, f"{phase}: missing process PID")
    native, offset, loads = member_and_executable_offsets(apk)
    require(sha256(native).hexdigest() == MEMBER_SHA256[phase],
            f"{phase}: packaged native hash changed")
    if phase == "candidate":
        require(aligned_elf(native), "candidate: APK native LOAD/RELRO alignment failed")
    require(item.get("member_data_offset") == offset and
            item.get("member_executable_loads") == loads,
            f"{phase}: recorded native ZIP mapping differs")
    cases = {event["name"]: event for event in events if event["kind"] == "CASE"}
    if phase == "candidate":
        require(len(events) == len(CASES) + 3 and end.get("status") == "PASS",
                "candidate: required tagged JNI path failed")
        for name in CASES[:-1]:
            require(cases[name].get("required") is True and
                    cases[name].get("outcome") == "PASS" and
                    isinstance(cases[name].get("result"), dict),
                    f"candidate: {name} golden failed")
        require(cases[CASES[-1]].get("required") is False and
                cases[CASES[-1]].get("outcome") in ("OBSERVED", "OBSERVED_ERROR"),
                "candidate: app-shaped case not characterized")
    elif end.get("status") == "PASS":
        require(len(events) == len(CASES) + 3 and
                all(cases[name].get("outcome") == "PASS" for name in CASES[:-1]),
                "baseline: PASS lacks required tagged goldens")
    else:
        require(end.get("status") == "FAIL" and
                (end.get("error") or any(event.get("outcome") == "FAIL" for event in cases.values())),
                "baseline: failure lacks a cause")
    if len(events) > 2:
        require_maps(events[1].get("nativeMaps"), apk_path, loads, phase)
    return {"pid": begin["pid"], "token": item["token"], "status": end["status"],
            "apk_sha256": APK_SHA256[phase], "member_sha256": MEMBER_SHA256[phase],
            "member_data_offset": offset, "elf64_aligned": aligned_elf(native),
            "cases": cases}


def verify(receipt, task, apks):
    require(receipt.get("schema_version") == 1 and receipt.get("device") == DEVICE,
            "fixture receipt schema/device changed")
    require(set(apks) == set(APK_SHA256), "fixture APK set changed")
    epoch = require_epoch(task, apks)
    require(receipt.get("build_epoch_sha256") == EPOCH_SHA256 and
            receipt.get("build_epoch") == epoch, "receipt build epoch differs")
    require(receipt.get("device_tool_sha256") == DEVICE_TOOL_SHA256 and
            all(Path(path).is_file() and digest(path) == expected
                for path, expected in DEVICE_TOOL_SHA256.items()),
            "device tool identity changed")
    require_git_epoch(receipt.get("git_head"), receipt.get("source_sha256", {}))
    require_strict(receipt.get("final", {}), "final")
    require(all(item.get("exit") == 0 for item in receipt.get("strict_setup", [])) and
            len(receipt.get("strict_setup", [])) == 4,
            "strict/offline setup incomplete")
    require(all(item.get("exit") == 0 for item in receipt.get("strict_restore", [])) and
            len(receipt.get("strict_restore", [])) == 4,
            "strict/offline final setup incomplete")
    require(set(receipt.get("phases", {})) == set(PACKAGES), "fixture runtime phase set changed")
    phases = {phase: verify_phase(phase, receipt["phases"][phase], apks[phase])
              for phase in PACKAGES}
    require(phases["baseline"]["pid"] != phases["candidate"]["pid"] and
            phases["baseline"]["token"] != phases["candidate"]["token"],
            "baseline and candidate reused process identity")
    parity = "baseline unavailable"
    if phases["baseline"]["status"] == "PASS":
        for name in CASES:
            left, right = phases["baseline"]["cases"][name], phases["candidate"]["cases"][name]
            require(left.get("outcome") == right.get("outcome") and
                    left.get("result") == right.get("result") and
                    left.get("errorClass") == right.get("errorClass") and
                    left.get("errorMessage") == right.get("errorMessage"),
                    f"{name}: baseline/candidate behavior differs")
        parity = "all five cases equal"
    return {"candidate_passed": True, "baseline_status": phases["baseline"]["status"],
            "parity": parity, "phases": phases}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--receipt", type=Path, required=True)
    parser.add_argument("--task-root", type=Path, required=True)
    for phase in PACKAGES:
        parser.add_argument(f"--{phase}-apk", type=Path, required=True)
    args = parser.parse_args()
    apks = {phase: getattr(args, phase + "_apk").resolve() for phase in PACKAGES}
    try:
        result = verify(json.loads(args.receipt.read_text()), args.task_root.resolve(), apks)
    except (OSError, ValueError, KeyError, struct.error) as error:
        print(f"Wallet Core fixture verification rejected: {error}", file=sys.stderr)
        return 1
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
