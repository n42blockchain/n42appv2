#!/usr/bin/env python3
"""Compare the valid, synthetic Go V1 Emit device vectors in runner logs."""

import json
import pathlib
import sys


VALID_OPERATIONS = (
    "setting",
    "state",
    "stop",
    "repeatStop",
    "partialSetting",
    "lowPubkey",
    "lowSignature",
    "highPubkey",
    "highSignature",
)
PREFIX = "GO_EVM_VECTOR_JSON:"


def vectors(path: pathlib.Path) -> dict:
    records = [
        line.removeprefix(PREFIX)
        for line in path.read_text().splitlines()
        if line.startswith(PREFIX)
    ]
    if len(records) != 1:
        raise ValueError(f"{path}: expected one vector record, got {len(records)}")
    response = json.loads(records[0])
    if not isinstance(response, dict):
        raise ValueError(f"{path}: vector record is not an object")
    result = {}
    for operation in VALID_OPERATIONS:
        if operation not in response:
            raise ValueError(f"{path}: missing {operation}")
        value = json.loads(response[operation])
        if not isinstance(value, dict) or set(value) != {"code", "message", "data"}:
            raise ValueError(f"{path}: malformed {operation} response")
        result[operation] = value
    return result


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} OLD_LOG CANDIDATE_LOG", file=sys.stderr)
        return 2
    try:
        old = vectors(pathlib.Path(sys.argv[1]))
        candidate = vectors(pathlib.Path(sys.argv[2]))
    except (OSError, ValueError, TypeError, KeyError) as error:
        print(error, file=sys.stderr)
        return 2
    mismatches = [name for name in VALID_OPERATIONS if old[name] != candidate[name]]
    if mismatches:
        print("mismatched valid operations: " + ", ".join(mismatches), file=sys.stderr)
        return 1
    print(f"MATCH valid Emit responses: {', '.join(VALID_OPERATIONS)}")
    print("Old log is a compatibility-mode protocol baseline; candidate ran strict 16KB.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
