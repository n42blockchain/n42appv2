#!/usr/bin/env python3
"""Verify the Task 16C text evidence archive without extracting it."""

import hashlib
import json
from pathlib import Path, PurePosixPath
import tarfile


HERE = Path(__file__).resolve().parent


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def main() -> None:
    manifest = json.loads((HERE / "manifest.json").read_text())
    archive_name = manifest["archive"]["path"]
    archive_path = PurePosixPath(archive_name)
    if archive_path.is_absolute() or len(archive_path.parts) != 1:
        raise ValueError("unsafe archive path")
    archive = HERE / archive_name
    raw_archive = archive.read_bytes()
    if len(raw_archive) != manifest["archive"]["bytes"]:
        raise ValueError("archive byte count differs")
    if digest(raw_archive) != manifest["archive"]["sha256"]:
        raise ValueError("archive SHA-256 differs")

    expected = manifest["members"]
    seen = set()
    with tarfile.open(archive, mode="r:gz") as bundle:
        for item in bundle:
            name = PurePosixPath(item.name)
            if name.is_absolute() or ".." in name.parts or not item.isfile():
                raise ValueError(f"unsafe member: {item.name}")
            if item.name in seen or item.name not in expected:
                raise ValueError(f"unexpected or duplicate member: {item.name}")
            seen.add(item.name)
            stream = bundle.extractfile(item)
            if stream is None:
                raise ValueError(f"cannot read member: {item.name}")
            payload = stream.read()
            record = expected[item.name]
            if len(payload) != record["bytes"] or digest(payload) != record["sha256"]:
                raise ValueError(f"member differs: {item.name}")
    if seen != set(expected):
        raise ValueError(f"missing members: {sorted(set(expected) - seen)}")

    app_root = HERE.parents[4]
    old_manifest = HERE.parent / "manifest.json"
    if digest(old_manifest.read_bytes()) != manifest["preserved_task16b_manifest_sha256"]:
        raise ValueError("Task 16B manifest differs")
    for relative, want in manifest["app_aar_sha256"].items():
        path = PurePosixPath(relative)
        if path.is_absolute() or ".." in path.parts:
            raise ValueError(f"unsafe app path: {relative}")
        if digest((app_root / relative).read_bytes()) != want:
            raise ValueError(f"app AAR differs: {relative}")
    print(f"Task 16C evidence verified: {len(seen)} regular members, archive, Task 16B manifest and both app AARs")


if __name__ == "__main__":
    main()
