#!/usr/bin/env python3
"""Independently check strict synthetic WCPay APK, JNA and UniFFI receipts."""

import argparse
from hashlib import sha256
import json
from pathlib import Path
import re
import struct
import subprocess
import sys
from zipfile import ZipFile, ZIP_STORED


PAGE = 16384
DEVICE = "emulator-5560"
ROOT = Path(__file__).resolve().parents[2]
WCPAY = "lib/arm64-v8a/libuniffi_yttrium_wcpay.so"
JNA = "lib/arm64-v8a/libjnidispatch.so"
JNA_AAR_SHA256 = "4dbeffffa665d97ad5aa7eee297531d3c841a86716ab7f774fd6956422b3cf38"
JNA_AAR_MEMBER_SHA256 = "abc26e994517bcaa3309acdb0a27373864086c7569c89d3087b8626fada9ef06"
JNA_APK_MEMBER_SHA256 = "ddfc6c965bbe366615c000ec1f06552ddf0bb2b4f9d921d0bff8c75b3cb2ca4c"
APK_SHA256 = {
    "baseline": "0f516541ecb9a66ebbaa00f06213997b73bccff0edec0eba11b68bad3118f899",
    "candidate": "f39af567815adbc6f34c8012027b69c0438ff89449fafa4f8dfa691d3c5a38b1",
    "mismatch": "33a03048f4709b7c83b029020c22059255f0a6391354029a4cf5efd1f501643c",
}
BUILD_INPUT_SHA256 = {
    "tools/android_native_smoke/reown_wcpay_fixture/settings.gradle.kts": "6cdcc706ac5c837f4733cbb404fdbff7991183528cb210ce2745dd23d3c22290",
    "tools/android_native_smoke/reown_wcpay_fixture/build.gradle.kts": "64dc0b52c1b38387c0d82b59d5bc03d2ee1b6db49c372ed88a5d6dc8e8fe618a",
    "tools/android_native_smoke/reown_wcpay_fixture/gradle.properties": "99b7c4b05d0fd58d4e7cde949210477af3fd11cb580f8b3b524e7381388f9e66",
    "tools/android_native_smoke/reown_wcpay_fixture/app/build.gradle.kts": "845ab605ba7b4e929a79646ebaa7d88fafca5cf7570075c0fc962e62bf4af386",
    "tools/android_native_smoke/reown_wcpay_fixture/app/src/main/AndroidManifest.xml": "c85e139594d0d4bb30d1c92afb7cff2c42b1f1071254c67df361d35064707b41",
    "tools/android_native_smoke/reown_wcpay_fixture/app/src/main/java/ai/n42/fixture/reown/MainActivity.kt": "c2c96d6f707b34c02be63c41bd59d2b9d4a5caa69a4ee3decbc6e8321b266848",
    "scripts/prepare_reown_wcpay_fixture.py": "50e11a04cf56c69252e199188083a19b21ae70ae3f535eab7fb66826412f4802",
}
MISMATCH_INPUT_SHA256 = {
    "bindings/yttrium.kt": "f7dad73161fd6090abedbf6ca8cf4ead768fb7980ab0d3c29007dc050c078934",
    "bindings/uniffi_yttrium.kt": "5bf20f4f39126830d1ecc00f43498c079ae06f1fc8dcd5db4141d0c97f168f84",
    "preparation.json": "08d7e19a5d34682dfdd48c4e6b6b98407fee19a5e417d0d5fd4d3ecc374b86a8",
    "jni/arm64-v8a/libuniffi_yttrium_wcpay.so": "a89f233ea9a99d4cfb7591bc87bc468adae422c118e452524fcacb38467d9bff",
}
SOURCE_FILES = tuple(ROOT / relative for relative in BUILD_INPUT_SHA256) + (
    ROOT / "tools/android_native_smoke/reown_wcpay_fixture/fixture-build-epoch.json",
    ROOT / "tools/android_native_smoke/run_reown_wcpay_fixture.py",
    ROOT / "tools/android_native_smoke/verify_reown_wcpay_fixture.py",
)
PACKAGES = {phase: f"ai.n42.fixture.reown.{phase}" for phase in
            ("baseline", "candidate", "mismatch")}
WCPAY_SHA256 = {
    "baseline": "f16fe81bc00d94ab48548ae4d3136dceab7f3b462496f68dd278217f7c411bb8",
    "candidate": "a89f233ea9a99d4cfb7591bc87bc468adae422c118e452524fcacb38467d9bff",
    "mismatch": "a89f233ea9a99d4cfb7591bc87bc468adae422c118e452524fcacb38467d9bff",
}
BINDING_ERROR = "uniffi.yttrium_wcpay.PayJsonException$"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    return sha256(Path(path).read_bytes()).hexdigest()


def require_jna_member(data):
    require(sha256(data).hexdigest() == JNA_APK_MEMBER_SHA256,
            "packaged JNA member SHA256 mismatch")


def require_build_epoch(root, mismatch_dir, jna_aar):
    manifest = json.loads((Path(root) / "tools/android_native_smoke/reown_wcpay_fixture/fixture-build-epoch.json").read_text())
    require(manifest.get("apk_sha256") == APK_SHA256 and
            manifest.get("compiled_fixture_source_sha256") == BUILD_INPUT_SHA256 and
            manifest.get("prepared_mismatch_input_sha256") == MISMATCH_INPUT_SHA256 and
            manifest.get("build_git_head") == "1a538f09081332adb03f0be523109c4d7c0e2f04" and
            manifest.get("fixture_source_commit") is None,
            "fixture build epoch manifest mismatch")
    jna_manifest = manifest.get("jna", {})
    require(jna_manifest.get("aar_sha256") == JNA_AAR_SHA256 and
            jna_manifest.get("aar_arm64_member_sha256") == JNA_AAR_MEMBER_SHA256 and
            jna_manifest.get("apk_arm64_member_sha256") == JNA_APK_MEMBER_SHA256,
            "JNA build epoch manifest mismatch")
    for relative, expected in BUILD_INPUT_SHA256.items():
        require(digest(Path(root) / relative) == expected,
                f"compiled fixture source SHA256 mismatch: {relative}")
    for relative, expected in MISMATCH_INPUT_SHA256.items():
        require(digest(Path(mismatch_dir) / relative) == expected,
                f"prepared mismatch input SHA256 mismatch: {relative}")
    require(digest(jna_aar) == JNA_AAR_SHA256, "JNA 5.17.0 AAR identity mismatch")
    with ZipFile(jna_aar) as archive:
        source_member = archive.read("jni/arm64-v8a/libjnidispatch.so")
    require(sha256(source_member).hexdigest() == JNA_AAR_MEMBER_SHA256,
            "source JNA ARM64 member SHA256 mismatch")
    return {"compiled_inputs": BUILD_INPUT_SHA256,
            "prepared_mismatch_inputs": MISMATCH_INPUT_SHA256,
            "jna_aar_sha256": JNA_AAR_SHA256,
            "jna_aar_arm64_sha256": JNA_AAR_MEMBER_SHA256}


def require_apks(apks):
    require(set(apks) == set(APK_SHA256), "missing or extra fixture APK")
    for phase, expected in APK_SHA256.items():
        require(digest(apks[phase]) == expected, f"{phase}: pinned APK SHA256 mismatch")
        native, _, _ = member_and_executable_offsets(apks[phase], WCPAY)
        require(sha256(native).hexdigest() == WCPAY_SHA256[phase],
                f"{phase}: pinned WCPay member SHA256 mismatch")
        jna, _, _ = member_and_executable_offsets(apks[phase], JNA)
        require_jna_member(jna)


def verify_git_epoch(head, observed_sources):
    require(isinstance(head, str) and re.fullmatch(r"[0-9a-f]{40}", head),
            "git_head is not a full commit ID")
    present = subprocess.run(["git", "cat-file", "-e", f"{head}^{{commit}}"], cwd=ROOT,
                             capture_output=True, check=False)
    require(present.returncode == 0, "git_head is not an available commit")
    expected = {str(path): digest(path) for path in SOURCE_FILES}
    require(observed_sources == expected, "source input identity mismatch")
    for path in SOURCE_FILES:
        relative = str(path.relative_to(ROOT))
        result = subprocess.run(["git", "show", f"{head}:{relative}"], cwd=ROOT,
                                capture_output=True, check=False)
        require(result.returncode == 0, f"git_head lacks reviewed source: {relative}")
        require(sha256(result.stdout).hexdigest() == expected[str(path)],
                f"git_head source SHA256 mismatch: {relative}")
    for relative, pinned in BUILD_INPUT_SHA256.items():
        require(expected[str(ROOT / relative)] == pinned,
                f"git_head compiled source differs: {relative}")


def require_strict(snapshot, phase):
    expected = {
        "page_size": "16384", "linker_mode": "fatal",
        "package_compat_disabled": "true", "airplane_mode": "1", "ip_route": "",
    }
    for name, value in expected.items():
        observed = snapshot.get(name)
        require(isinstance(observed, dict), f"{phase}: missing {name}")
        require(observed.get("exit") == 0, f"{phase}: {name} command failed")
        require(observed.get("stdout") == value, f"{phase}: {name} mismatch")


def parse_result_logcat(output, phase):
    lines = [line for line in output.splitlines() if "N42_REOWN_FIXTURE:" in line]
    require(len(lines) == 1, f"{phase}: expected exactly one fresh fixture log record")
    match = re.fullmatch(
        r"\d\d-\d\d\s+\d\d:\d\d:\d\d\.\d+\s+(\d+)\s+\d+\s+I\s+N42_REOWN_FIXTURE:\s+(.+)",
        lines[0],
    )
    require(match is not None, f"{phase}: malformed fixture log framing")
    try:
        record = json.loads(match.group(2))
    except json.JSONDecodeError as error:
        raise ValueError(f"{phase}: malformed or truncated fixture JSON") from error
    require(isinstance(record, dict), f"{phase}: fixture log is not a JSON object")
    require(record.get("phase") == phase, f"{phase}: log phase mismatch")
    require(type(record.get("pid")) is int and record["pid"] == int(match.group(1)),
            f"{phase}: log PID mismatch")
    require(isinstance(record.get("nonce"), str) and record["nonce"],
            f"{phase}: missing log process nonce")
    return record


def member_and_executable_offsets(apk, member):
    with ZipFile(apk) as archive, Path(apk).open("rb") as stream:
        entry = archive.getinfo(member)
        require(entry.compress_type == ZIP_STORED, f"{member}: compressed")
        stream.seek(entry.header_offset)
        header = stream.read(30)
        require(len(header) == 30 and header[:4] == b"PK\x03\x04", "bad local ZIP header")
        name_length, extra_length = struct.unpack_from("<HH", header, 26)
        require(stream.read(name_length).decode() == member, "ZIP member name mismatch")
        data_offset = entry.header_offset + 30 + name_length + extra_length
        require(data_offset % PAGE == 0, f"{member}: not 16 KB ZIP aligned")
        data = archive.read(entry)
    require(data[:6] == b"\x7fELF\x02\x01", f"{member}: not ELF64 little endian")
    require(struct.unpack_from("<H", data, 18)[0] == 183, f"{member}: not AArch64")
    phoff = struct.unpack_from("<Q", data, 32)[0]
    phentsize, phnum = struct.unpack_from("<HH", data, 54)
    require(phentsize >= 56 and phnum > 0 and phoff + phentsize * phnum <= len(data),
            f"{member}: invalid program headers")
    loads = []
    for index in range(phnum):
        start = phoff + index * phentsize
        kind, flags = struct.unpack_from("<II", data, start)
        if kind == 1 and flags & 1:
            file_offset = struct.unpack_from("<Q", data, start + 8)[0]
            file_size = struct.unpack_from("<Q", data, start + 32)[0]
            require(file_offset + file_size <= len(data), f"{member}: LOAD outside member")
            rounded = file_offset // PAGE * PAGE
            rounded_end = (file_offset + file_size + PAGE - 1) // PAGE * PAGE
            loads.append((data_offset + rounded, rounded_end - rounded))
    require(loads, f"{member}: missing executable LOAD")
    return data, data_offset, loads


def verify_result(phase, result):
    require(result.get("phase") == phase, f"{phase}: result phase mismatch")
    require(result.get("attemptedInitialization") is True,
            f"{phase}: binding initialization was not attempted")
    if phase == "mismatch":
        require(result.get("status") == "PASS", "mismatch: expected checker rejection not observed")
        require("UniFFI API checksum mismatch" in result.get("mismatchError", ""),
                "mismatch: mismatchError does not name the UniFFI checksum checker")
    elif phase == "candidate" or result.get("status") == "PASS":
        require(result.get("status") == "PASS", f"{phase}: fixture failed")
        for name, kind in (
            ("constructorJsonParse", "JsonParse"), ("missingAuth", "MissingAuth"),
            ("optionsJsonParse", "JsonParse"), ("actionsJsonParse", "JsonParse"),
            ("confirmJsonParse", "JsonParse"),
        ):
            require(result.get(name) == BINDING_ERROR + kind,
                    f"{phase}: {name} typed error mismatch")
    else:
        require(result.get("status") == "FAIL" and result.get("error"),
                "baseline: failure was not recorded")


def require_maps(result, apk_path, loads, phase, member):
    maps = result.get("executableApkMaps")
    require(isinstance(maps, list) and maps, f"{phase}: missing executable APK maps")
    observed = []
    for line in maps:
        match = re.fullmatch(
            r"([0-9a-f]+)-([0-9a-f]+)\s+r-xp\s+([0-9a-f]+)\s+\S+\s+\d+\s+(.+)",
            line,
        )
        if match and match.group(4) == apk_path:
            observed.append((int(match.group(3), 16),
                             int(match.group(2), 16) - int(match.group(1), 16)))
    for offset, length in loads:
        require(any(start == offset and size >= length for start, size in observed),
                f"{phase}: {member} executable map misses LOAD at 0x{offset:x}")


def verify_phase(phase, item, apk):
    require(item.get("package") == PACKAGES[phase], f"{phase}: package mismatch")
    require(digest(apk) == APK_SHA256[phase], f"{phase}: pinned APK SHA256 mismatch")
    require(item.get("apk_sha256") == digest(apk), f"{phase}: local APK SHA mismatch")
    require_strict(item.get("pre", {}), f"{phase} pre")
    require_strict(item.get("post", {}), f"{phase} post")
    for command in ("install", "clear", "logcat_clear", "start", "pm_path", "force_stop"):
        require(item.get(command, {}).get("exit") == 0, f"{phase}: {command} failed")
    result = item.get("result")
    require(isinstance(result, dict), f"{phase}: missing in-process result")
    fetched = item.get("result_logcat", {})
    require(fetched.get("exit") == 0, f"{phase}: logcat read failed")
    require(parse_result_logcat(fetched.get("stdout", ""), phase) == result,
            f"{phase}: result differs from fresh tagged logcat")
    verify_result(phase, result)
    require(isinstance(result.get("pid"), int) and result["pid"] > 0,
            f"{phase}: missing PID")
    require(isinstance(result.get("nonce"), str) and result["nonce"],
            f"{phase}: missing process nonce")
    apk_path = result.get("apkPath")
    require(isinstance(apk_path, str) and apk_path.startswith("/data/app/")
            and apk_path.endswith("/base.apk"), f"{phase}: installed APK path invalid")
    require(result.get("apkSha256") == digest(apk), f"{phase}: installed APK hash mismatch")
    require(item["pm_path"]["stdout"] == f"package:{apk_path}",
            f"{phase}: package manager path differs")
    require(result.get("libraryLookupPath") == f"{apk_path}!/{WCPAY}",
            f"{phase}: class loader selected another WCPay member")
    members = {}
    for member in (WCPAY, JNA):
        data, offset, loads = member_and_executable_offsets(apk, member)
        if member == JNA:
            require_jna_member(data)
        members[member] = {"sha256": sha256(data).hexdigest(), "data_offset": offset,
                           "executable_loads": loads}
        if phase != "baseline" or result["status"] == "PASS":
            require_maps(result, apk_path, loads, phase, member)
    require(members[WCPAY]["sha256"] == WCPAY_SHA256[phase],
            f"{phase}: WCPay member SHA mismatch")
    return {"package": item["package"], "apk_sha256": digest(apk),
            "pid": result["pid"], "nonce": result["nonce"],
            "status": result["status"], "members": members}


def verify(receipt, apks, jna_aar, mismatch_dir):
    require(receipt.get("schema_version") == 1 and receipt.get("device") == DEVICE,
            "receipt schema/device mismatch")
    require_apks(apks)
    build_epoch = require_build_epoch(ROOT, mismatch_dir, jna_aar)
    require(receipt.get("build_epoch") == build_epoch, "build epoch identity mismatch")
    verify_git_epoch(receipt.get("git_head"), receipt.get("source_sha256"))
    require_strict(receipt.get("final", {}), "final")
    require(receipt.get("jna_aar_sha256") == JNA_AAR_SHA256 == digest(jna_aar),
            "JNA 5.17.0 AAR identity mismatch")
    phases = receipt.get("phases", {})
    require(set(phases) == set(PACKAGES), "missing or extra runtime phase")
    results = {phase: verify_phase(phase, phases[phase], apks[phase]) for phase in PACKAGES}
    require(len({result["pid"] for result in results.values()}) == 3,
            "phases share process PID")
    require(len({result["nonce"] for result in results.values()}) == 3,
            "phases share process nonce")
    require(len({result["apk_sha256"] for result in results.values()}) == 3,
            "phases share APK")
    require(len({result["members"][JNA]["sha256"] for result in results.values()}) == 1,
            "JNA native member differs across phases")
    require(results["candidate"]["members"][WCPAY]["sha256"] ==
            results["mismatch"]["members"][WCPAY]["sha256"],
            "mismatch control changed candidate native bytes")
    return {"passed": True, "phases": results}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--receipt", type=Path, required=True)
    parser.add_argument("--baseline-apk", type=Path, required=True)
    parser.add_argument("--candidate-apk", type=Path, required=True)
    parser.add_argument("--mismatch-apk", type=Path, required=True)
    parser.add_argument("--jna-aar", type=Path, required=True)
    parser.add_argument("--mismatch-dir", type=Path, required=True)
    args = parser.parse_args()
    apks = {name: getattr(args, name + "_apk") for name in PACKAGES}
    try:
        result = verify(json.loads(args.receipt.read_text()), apks, args.jna_aar,
                        args.mismatch_dir)
    except (OSError, ValueError, KeyError, struct.error) as error:
        print(f"Reown fixture verification rejected: {error}", file=sys.stderr)
        return 1
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
