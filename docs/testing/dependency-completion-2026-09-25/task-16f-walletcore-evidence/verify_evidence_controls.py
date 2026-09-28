#!/usr/bin/env python3
"""Exercise bounded archive and runtime semantic rejection controls."""

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


def changed_member():
    with tempfile.TemporaryDirectory(prefix="walletcore-archive-control-") as temp:
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


def edit_event(receipt, phase, index, edit):
    item = receipt["phases"][phase]
    edit(item["events"][index])
    marker = "N42_WALLETCORE_FIXTURE: "
    lines = item["result_logcat"]["stdout"].splitlines()
    positions = [i for i, line in enumerate(lines) if marker in line]
    if len(positions) != len(item["events"]):
        raise ValueError("control source logcat event count differs")
    line = positions[index]
    prefix = lines[line].split(marker, 1)[0] + marker
    lines[line] = prefix + json.dumps(item["events"][index], separators=(",", ":"))
    item["result_logcat"]["stdout"] = "\n".join(lines)


def run():
    archive.verify_members()
    archive.verify_package()
    archive.replay_runtime()
    source = archive.read_json("raw/runtime-receipt.json")
    results = [rejected("changed_member", changed_member,
                        "archive member hash mismatch")]
    state = copy.deepcopy(source)
    state["phases"]["candidate"]["pre"]["page_size"]["stdout"] = "4096"
    results.append(rejected("wrong_strict_state", lambda: archive.replay_runtime(state),
                            "candidate pre: strict/offline page_size changed"))
    missing = copy.deepcopy(source)
    missing.pop("source_sha256")
    results.append(rejected("missing_source_map", lambda: archive.replay_runtime(missing),
                            "reviewed source input map differs"))
    native_map = copy.deepcopy(source)
    edit_event(native_map, "candidate", 1,
               lambda event: event["nativeMaps"].__setitem__(
                   0, event["nativeMaps"][0].replace("001f4000", "001f5000")))
    results.append(rejected("wrong_native_map", lambda: archive.replay_runtime(native_map),
                            "candidate: executable APK maps miss native LOAD"))
    bad_golden = copy.deepcopy(source)
    edit_event(bad_golden, "candidate", 2,
               lambda event: event.__setitem__("outcome", "FAIL"))
    results.append(rejected("failed_candidate_golden",
                            lambda: archive.replay_runtime(bad_golden),
                            "candidate: hdwallet golden failed"))
    print(json.dumps({"passed": True, "rejected": results}, sort_keys=True))


if __name__ == "__main__":
    run()
