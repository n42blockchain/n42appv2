#!/usr/bin/env python3
"""Independently check strict synthetic WCPay APK, JNA and UniFFI receipts."""

import argparse
from hashlib import sha256
import json
from pathlib import Path
import re
import struct
import sys
from zipfile import ZipFile, ZIP_STORED


PAGE = 16384
DEVICE = "emulator-5560"
WCPAY = "lib/arm64-v8a/libuniffi_yttrium_wcpay.so"
JNA = "lib/arm64-v8a/libjnidispatch.so"
JNA_AAR_SHA256 = "4dbeffffa665d97ad5aa7eee297531d3c841a86716ab7f774fd6956422b3cf38"
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
    require(item.get("apk_sha256") == digest(apk), f"{phase}: local APK SHA mismatch")
    require_strict(item.get("pre", {}), f"{phase} pre")
    require_strict(item.get("post", {}), f"{phase} post")
    for command in ("install", "clear", "start", "pm_path", "force_stop"):
        require(item.get(command, {}).get("exit") == 0, f"{phase}: {command} failed")
    result = item.get("result")
    require(isinstance(result, dict), f"{phase}: missing in-process result")
    fetched = item.get("result_fetch", {})
    require(fetched.get("exit") == 0 and json.loads(fetched.get("stdout", "null")) == result,
            f"{phase}: result differs from fetched app file")
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
        members[member] = {"sha256": sha256(data).hexdigest(), "data_offset": offset,
                           "executable_loads": loads}
        if phase != "baseline" or result["status"] == "PASS":
            require_maps(result, apk_path, loads, phase, member)
    require(members[WCPAY]["sha256"] == WCPAY_SHA256[phase],
            f"{phase}: WCPay member SHA mismatch")
    return {"package": item["package"], "apk_sha256": digest(apk),
            "pid": result["pid"], "nonce": result["nonce"],
            "status": result["status"], "members": members}


def verify(receipt, apks, source_files, jna_aar):
    require(receipt.get("schema_version") == 1 and receipt.get("device") == DEVICE,
            "receipt schema/device mismatch")
    require_strict(receipt.get("final", {}), "final")
    require(receipt.get("jna_aar_sha256") == JNA_AAR_SHA256 == digest(jna_aar),
            "JNA 5.17.0 AAR identity mismatch")
    expected_sources = {str(path): digest(path) for path in source_files}
    require(receipt.get("source_sha256") == expected_sources, "source input identity mismatch")
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
    parser.add_argument("--source", type=Path, action="append", required=True)
    args = parser.parse_args()
    apks = {name: getattr(args, name + "_apk") for name in PACKAGES}
    try:
        result = verify(json.loads(args.receipt.read_text()), apks, args.source, args.jna_aar)
    except (OSError, ValueError, KeyError, struct.error) as error:
        print(f"Reown fixture verification rejected: {error}", file=sys.stderr)
        return 1
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
