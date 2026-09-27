#!/usr/bin/env python3
"""Classify Cargo audit records against a selected target's Cargo trees."""

import json
import re
import sys
from pathlib import Path

PACKAGE = re.compile(r"(?:^|[─ ])([A-Za-z0-9_-]+) v([0-9][^\s(]*)", re.M)


def packages(path: str) -> set[tuple[str, str]]:
    return set(PACKAGE.findall(Path(path).read_text()))


def main() -> None:
    if len(sys.argv) != 4:
        raise SystemExit("usage: scope_cargo_audit.py NORMAL_TREE NORMAL_BUILD_TREE AUDIT_JSON")
    normal = packages(sys.argv[1])
    normal_build = packages(sys.argv[2])
    if not normal <= normal_build:
        raise SystemExit("normal tree is not a subset of normal+build tree")
    audit = json.loads(Path(sys.argv[3]).read_text())
    groups = {"vulnerability": audit["vulnerabilities"]["list"], **audit["warnings"]}
    records = []
    for kind, items in groups.items():
        for item in items:
            package = item["package"]
            pair = (package["name"], package["version"])
            advisory = item.get("advisory") or {}
            records.append({
                "kind": kind,
                "id": advisory.get("id"),
                "package": pair[0],
                "version": pair[1],
                "scope": "normal" if pair in normal else
                         "build_only" if pair in normal_build else "whole_lock_only",
            })
    result = {
        "normal_package_versions": len(normal),
        "normal_plus_build_package_versions": len(normal_build),
        "build_only_package_versions": len(normal_build - normal),
        "records": sorted(records, key=lambda row: (
            row["kind"], row["package"], row["version"], row["id"] or "")),
    }
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
