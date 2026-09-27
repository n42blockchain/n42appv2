#!/usr/bin/env python3
"""Inspect every Mach-O object in a thin iOS static archive."""

import hashlib
import json
import mmap
import struct
import sys
from collections import Counter
from pathlib import Path

AR_MAGIC = b"!<arch>\n"
MACHO_64_LE = b"\xcf\xfa\xed\xfe"
ARM64_CPU = 0x0100000C
MH_OBJECT = 1
LC_BUILD_VERSION = 0x32
LC_VERSION_MIN_IPHONEOS = 0x25
PLATFORM_IOS = 2


def version(value: int) -> str:
    return f"{value >> 16}.{(value >> 8) & 255}.{value & 255}"


def audit(path: Path) -> dict:
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    with path.open("rb") as source, mmap.mmap(source.fileno(), 0, access=mmap.ACCESS_READ) as data:
        if data[:8] != AR_MAGIC:
            raise ValueError("not an ar archive")
        offset = 8
        count = 0
        formats = Counter()
        problems = []
        while offset < len(data):
            if offset + 60 > len(data) or data[offset + 58 : offset + 60] != b"`\n":
                raise ValueError(f"invalid ar member at {offset}")
            header = data[offset : offset + 60]
            size = int(header[48:58].strip())
            start, end = offset + 60, offset + 60 + size
            if end > len(data):
                raise ValueError(f"truncated ar member at {offset}")
            name = header[:16].strip().rstrip(b"/").decode("utf-8", "replace")
            if name.startswith("#1/"):
                name_size = int(name[3:])
                name = data[start : start + name_size].rstrip(b"\x00").decode("utf-8", "replace")
                start += name_size
            offset = end + (size & 1)
            if name.startswith("__.SYMDEF") or name in ("", "/", "//"):
                continue
            count += 1
            if data[start : start + 4] != MACHO_64_LE or start + 32 > end:
                problems.append(f"{name}: not thin little-endian Mach-O 64")
                continue
            _, cpu, _, filetype, ncmds, sizeofcmds, _, _ = struct.unpack_from("<IiiIIIII", data, start)
            if cpu != ARM64_CPU or filetype != MH_OBJECT:
                problems.append(f"{name}: cpu={cpu} filetype={filetype}")
            command = start + 32
            command_end = command + sizeofcmds
            if command_end > end:
                problems.append(f"{name}: load commands overflow member")
                continue
            build = None
            for _ in range(ncmds):
                if command + 8 > command_end:
                    problems.append(f"{name}: truncated load command")
                    break
                kind, command_size = struct.unpack_from("<II", data, command)
                if command_size < 8 or command + command_size > command_end:
                    problems.append(f"{name}: invalid load command size")
                    break
                if kind == LC_BUILD_VERSION and command_size >= 24:
                    _, _, platform, minimum, _, _ = struct.unpack_from("<IIIIII", data, command)
                    build = (f"platform={platform}", version(minimum))
                elif kind == LC_VERSION_MIN_IPHONEOS and command_size >= 16:
                    _, _, minimum, _ = struct.unpack_from("<IIII", data, command)
                    build = (f"platform={PLATFORM_IOS}", version(minimum))
                command += command_size
            if build is None:
                problems.append(f"{name}: no iOS build version")
            else:
                formats[build] += 1
                if build[0] != f"platform={PLATFORM_IOS}" or tuple(map(int, build[1].split("."))) > (16, 0, 0):
                    problems.append(f"{name}: {build}")
        if offset != len(data):
            raise ValueError("ar member padding mismatch")
    return {
        "archive": str(path),
        "sha256": digest,
        "members": count,
        "build_versions": [
            {"platform": platform, "minos": minimum, "members": number}
            for (platform, minimum), number in sorted(formats.items())
        ],
        "problem_count": len(problems),
        "problems": problems[:30],
    }


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("usage: audit_ios_archive.py STATIC_ARCHIVE")
    result = audit(Path(sys.argv[1]))
    print(json.dumps(result, indent=2))
    if result["problem_count"]:
        raise SystemExit(1)
