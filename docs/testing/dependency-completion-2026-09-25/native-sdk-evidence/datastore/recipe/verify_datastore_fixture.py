#!/usr/bin/env python3
"""Verify two fixture runs against the actual ZIP-mapped DataStore JNI member."""

import argparse
import hashlib
import json
import pathlib
import re
import struct
import subprocess
import tempfile
import zipfile

MEMBER = "lib/arm64-v8a/libdatastore_shared_counter.so"
AAR_MEMBER = "jni/arm64-v8a/libdatastore_shared_counter.so"
EXPECTED_AAR = "435edad7bcb1fbb1a2a46de7be4d6daf299479b3328ebf757ebdfe02810cbdd8"


def sha256(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def mapped_member(apk: pathlib.Path) -> tuple[bytes, int, int]:
    with zipfile.ZipFile(apk) as archive, apk.open("rb") as stream:
        info = archive.getinfo(MEMBER)
        assert info.compress_type == zipfile.ZIP_STORED, "native ZIP entry is compressed"
        stream.seek(info.header_offset)
        header = stream.read(30)
        assert len(header) == 30 and header[:4] == b"PK\x03\x04", "bad local ZIP header"
        name_length, extra_length = struct.unpack_from("<HH", header, 26)
        assert stream.read(name_length).decode() == MEMBER, "local ZIP member differs"
        data_offset = info.header_offset + 30 + name_length + extra_length
        data_end = data_offset + info.file_size
        return archive.read(info), data_offset, data_end


def observed_counter(
    result: pathlib.Path, apk: pathlib.Path, phase: str, before: int, after: int,
    offset_delta: int,
) -> dict:
    record = json.loads(result.read_text())
    assert record["status"] == "PASS", f"fixture {phase} failed: {record}"
    assert record["phase"] == phase, "fixture phase differs"
    counter = record["counter"]
    assert counter["before"] == before and counter["after"] == after, "counter sequence mismatch"
    lookup = counter["lookupPath"]
    maps = counter["packageMaps"]
    pid = counter["pid"]
    assert lookup.endswith("base.apk!/" + MEMBER), "class loader resolves another member"
    package_path = lookup.split("!/", 1)[0]
    member, data_offset, data_end = mapped_member(apk)
    offset = f"{data_offset + offset_delta:08x}"
    map_match = any(
        re.search(rf"\br-xp\s+{offset}\s+.*{re.escape(package_path)}", line)
        for line in maps
    )
    assert map_match, f"no executable base.apk mapping at DataStore member offset 0x{offset}"
    assert data_offset % 16384 == 0, "native ZIP entry data is not 16 KB aligned"
    return {
        "apk_sha256": sha256(apk.read_bytes()),
        "member_sha256": sha256(member),
        "member_data_offset": data_offset,
        "member_data_end": data_end,
        "mapping_offset": int(offset, 16),
        "pid": pid,
        "counter_before": before,
        "counter_after": after,
        "lookup_path": lookup,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--aar", type=pathlib.Path, required=True)
    parser.add_argument("--strip", type=pathlib.Path, required=True)
    parser.add_argument("--seed-apk", type=pathlib.Path, required=True)
    parser.add_argument("--seed-result", type=pathlib.Path, required=True)
    parser.add_argument("--verify-apk", type=pathlib.Path, required=True)
    parser.add_argument("--verify-result", type=pathlib.Path, required=True)
    parser.add_argument("--expected-aar-sha", default=EXPECTED_AAR)
    parser.add_argument("--expected-offset-delta", type=int, default=0)
    args = parser.parse_args()

    aar_bytes = args.aar.read_bytes()
    assert sha256(aar_bytes) == args.expected_aar_sha, "AAR SHA256 mismatch"
    with zipfile.ZipFile(args.aar) as archive:
        original = archive.read(AAR_MEMBER)
    with tempfile.TemporaryDirectory() as directory:
        native = pathlib.Path(directory) / "libdatastore_shared_counter.so"
        native.write_bytes(original)
        subprocess.run([str(args.strip), "--strip-unneeded", str(native)], check=True)
        stripped = native.read_bytes()

    seed = observed_counter(args.seed_result, args.seed_apk, "seed", 0, 1, args.expected_offset_delta)
    verify = observed_counter(args.verify_result, args.verify_apk, "verify", 1, 2, args.expected_offset_delta)
    for record, apk in ((seed, args.seed_apk), (verify, args.verify_apk)):
        member, _, _ = mapped_member(apk)
        assert member in (original, stripped), "packaged member differs from AAR and strip output"
    assert seed["pid"] != verify["pid"], "seed and verify ran in the same process"
    assert seed["apk_sha256"] == verify["apk_sha256"], "the two phases used different APKs"
    print(
        json.dumps(
            {
                "aar_sha256": sha256(aar_bytes),
                "aar_member_sha256": sha256(original),
                "stripped_member_sha256": sha256(stripped),
                "seed": seed,
                "verify": verify,
                "process_restart_proven": True,
            },
            sort_keys=True,
            indent=2,
        )
    )


if __name__ == "__main__":
    main()
