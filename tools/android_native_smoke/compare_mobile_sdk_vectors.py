#!/usr/bin/env python3
"""Compare synthetic MobileSdk transaction results from old and new fixture logs."""

import argparse
import json
from pathlib import Path


def vectors(path: Path):
    for line in path.read_text().splitlines():
        if "LEGACY_VECTOR_JSON:" in line:
            raw = json.loads(line.split("LEGACY_VECTOR_JSON:", 1)[1])
            return raw, {name: json.loads(raw[name]) for name in ("deposit", "exit", "feeCall")}
    raise ValueError(f"Missing fixture vectors in {path}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("old_log", type=Path)
    parser.add_argument("new_log", type=Path)
    args = parser.parse_args()
    old_raw, old = vectors(args.old_log)
    new_raw, new = vectors(args.new_log)

    if old_raw["exit"] != new_raw["exit"]:
        raise ValueError("Exit bytes differ")
    if old_raw["feeCall"] != new_raw["feeCall"]:
        raise ValueError("Fee call bytes differ")
    if "gas" in old["deposit"]:
        raise ValueError("Unexpected old deposit gas field")
    if new["deposit"].pop("gas", None) != "0x493e0":
        raise ValueError("Unexpected new deposit gas")
    if old["deposit"] != new["deposit"]:
        raise ValueError("Deposit transaction payload differs")
    print("Old/new transaction payloads match; v0.2.2 adds deposit gas=0x493e0 only")


if __name__ == "__main__":
    main()
