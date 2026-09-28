#!/usr/bin/env python3
"""Require archive hash and runtime semantic tampering to fail offline."""

import copy
import json
import os
from pathlib import Path
import shutil
import tempfile

import verify_evidence as archive


def rejected(name, action, expected):
    try:
        action()
    except ValueError as error:
        if expected not in str(error):
            raise ValueError(f"{name}: wrong rejection: {error}") from error
        return {"control": name, "rejected": str(error)}
    raise ValueError(f"{name}: altered evidence was accepted")


def edit_result(receipt, phase, field, value):
    item = receipt["phases"][phase]
    item["result"][field] = value
    lines = item["result_logcat"]["stdout"].splitlines()
    marker = "N42_REOWN_FIXTURE: "
    frames = [index for index, line in enumerate(lines) if marker in line]
    if len(frames) != 1:
        raise ValueError("control source lacks one fresh log frame")
    index = frames[0]
    lines[index] = lines[index].split(marker, 1)[0] + marker + json.dumps(
        item["result"], separators=(",", ":"))
    item["result_logcat"]["stdout"] = "\n".join(lines)


def tampered_member():
    with tempfile.TemporaryDirectory(prefix="reown-evidence-control-") as temp:
        destination = Path(temp) / "archive"
        shutil.copytree(archive.ROOT, destination, copy_function=os.link)
        readme = destination / "README.md"
        replacement = destination / "changed-readme"
        replacement.write_bytes(readme.read_bytes() + b"\nchanged\n")
        replacement.replace(readme)
        original = archive.ROOT
        try:
            archive.ROOT = destination
            archive.verify_members()
        finally:
            archive.ROOT = original


def run():
    archive.verify_members()
    archive.verify_package()
    archive.replay_runtime()
    source = json.loads((archive.ROOT / "raw/stage3-runtime-run2/"
                         "reown-runtime-receipt.json").read_text())
    results = [rejected("changed_member", tampered_member,
                        "archive member hash mismatch")]
    wrong_state = copy.deepcopy(source)
    wrong_state["phases"]["candidate"]["pre"]["page_size"]["stdout"] = "4096"
    results.append(rejected("wrong_strict_state", lambda: archive.replay_runtime(wrong_state),
                            "candidate pre: page_size mismatch"))
    missing_source = copy.deepcopy(source)
    missing_source.pop("source_sha256")
    results.append(rejected("missing_source_map", lambda: archive.replay_runtime(missing_source),
                            "source input map missing"))
    accepted_mismatch = copy.deepcopy(source)
    edit_result(accepted_mismatch, "mismatch", "mismatchError", "binding accepted")
    results.append(rejected("accepted_mismatch_binding",
                            lambda: archive.replay_runtime(accepted_mismatch),
                            "mismatchError does not name the UniFFI checksum checker"))
    print(json.dumps({"passed": True, "rejected": results}, sort_keys=True))


if __name__ == "__main__":
    run()
