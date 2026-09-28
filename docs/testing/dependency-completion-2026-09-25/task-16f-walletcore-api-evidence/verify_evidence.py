#!/usr/bin/env python3
"""Portable replay of the exact Wallet Core production-adapter JNI fixture."""

import copy
import gzip
from hashlib import sha256
import importlib.util
import json
from pathlib import Path
import re
import sys
from tempfile import TemporaryDirectory


# The archived runtime module is imported only after bytecode writes are disabled.
sys.dont_write_bytecode = True

ROOT = Path(__file__).resolve().parent
HEAD = "92174acfe9da1a730f9671cf615b841788e4a2e9"
APK_SHA256 = "f3f627565b70b42787f15bce7cf1c8024a6c4696b916a289e196a96d6526b855"
ORIGINAL_TASK = Path("/Users/jieliu/.codex/worktrees/n42appv2-dependency-completion/.superpowers/sdd/dependency-completion-20260925")
ALIASES = ["build3/walletcore-api-candidate.apk"] + [
    f"runtime-run{run}/emulator-{serial}-installed.apk"
    for run, serials in ((1, (5560,)), (2, (5560, 5562)),
                         (3, (5560, 5562)), (4, (5560, 5562)),
                         (5, (5560, 5562))) for serial in serials
]


def require(value, reason):
    if not value:
        raise ValueError(reason)


def digest(path):
    return sha256(Path(path).read_bytes()).hexdigest()


def read_json(relative):
    return json.loads((ROOT / relative).read_bytes())


def verify_members():
    names = (ROOT / "members.txt").read_text().splitlines()
    require(names == sorted(set(names)) and
            {"README.md", "ACCEPTANCE.md", "verify_evidence.py",
             "verify_evidence_controls.py", "members.txt", "artifacts/build3-apk.gz"}
            <= set(names), "archive member list changed")
    require(all(not Path(name).is_absolute() and ".." not in Path(name).parts
                for name in names), "unsafe archive member")
    require(not any(path.is_symlink() for path in ROOT.rglob("*")),
            "archive contains a symlink")
    actual = sorted(str(path.relative_to(ROOT)) for path in ROOT.rglob("*")
                    if path.is_file() and path != ROOT / "manifest.json")
    require(actual == names, "archive has missing or extra members")
    manifest = read_json("manifest.json")
    expected = [{"path": name, "bytes": (ROOT / name).stat().st_size,
                 "sha256": digest(ROOT / name)} for name in names]
    require(manifest.get("schema_version") == 1 and manifest.get("members") == expected,
            "archive member hash mismatch")
    require(manifest.get("apk_aliases") == [
        {"logical": name, "stored_as": "artifacts/build3-apk.gz",
         "sha256": APK_SHA256, "bytes": 19801272} for name in ALIASES],
        "explicit APK alias set changed")
    return len(names)


def reviewed_module():
    path = ROOT / "source/tools/android_native_smoke/verify_walletcore_api_fixture.py"
    spec = importlib.util.spec_from_file_location("reviewed_walletcore_api_verifier", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    require(module.ROOT == ROOT / "source" and module.APK_SHA256 == APK_SHA256,
            "reviewed runtime verifier bytes or root differ")
    return module


def source_epoch(module, receipt):
    epoch = read_json("source/tools/android_native_smoke/walletcore_api_fixture/fixture-build-epoch.json")
    require(digest(ROOT / "source/tools/android_native_smoke/walletcore_api_fixture/fixture-build-epoch.json") ==
            module.EPOCH_SHA256 and receipt.get("build_epoch_sha256") == module.EPOCH_SHA256 and
            receipt.get("build_epoch") == epoch and receipt.get("git_head") == HEAD,
            "reviewed source/build epoch changed")
    require(receipt.get("source_sha256") and
            set(receipt["source_sha256"]) == set(module.SOURCES),
            "reviewed runtime source set changed")
    for relative in module.SOURCES:
        require(digest(ROOT / "source" / relative) == receipt["source_sha256"][relative],
                f"reviewed runtime source differs: {relative}")
    base = ROOT / "source/tools/android_native_smoke/walletcore_api_fixture"
    for relative, expected in epoch["compiled_fixture_source_sha256"].items():
        require(digest(base / relative) == expected,
                f"compiled fixture source differs: {relative}")
    require(digest(ROOT / "source/scripts/build_walletcore_api_fixture.py") ==
            epoch["builder_sha256"] and
            digest(ROOT / "source/android/app/src/main/java/ai/n42/www/walletcore/BitcoinV2SigningAdapter.java") ==
            epoch["compiled_adapter_sha256"], "compiled adapter/builder bytes differ")
    require(receipt.get("device_tools") == module.TOOLS and
            receipt.get("apk_sha256") == APK_SHA256,
            "recorded tool or APK pin changed")
    build = read_json("raw/build-result.json")
    require(build["apk_sha256"] == APK_SHA256 and build["apk_native_sha256"] ==
            module.NATIVE_SHA256 and build["gradle_exit"] == 0 and
            build["project_source_sha256"] == epoch["compiled_fixture_source_sha256"] and
            build["input_sha256"] == epoch["input_sha256"] and
            build["tool_sha256"] == epoch["tool_sha256"],
            "archived build/input receipt differs")
    return epoch


def ownership(module, receipt):
    owners = receipt.get("ownership", {})
    require(set(owners) == set(module.OWNERS), "runtime owner set changed")
    for serial, expected in module.OWNERS.items():
        item = owners[serial]
        source = ("raw/launch/android-16kb-environment.json" if serial == "emulator-5560"
                  else "raw/launch/task-api26-launch.json")
        require(digest(ROOT / source) == item.get("launch_receipt_sha256") ==
                expected["source_sha256"], f"{serial}: launch source differs")
        launch = read_json(source)
        require((launch["owned_avd"] if serial == "emulator-5560" else launch["avd"]) ==
                expected["avd"], f"{serial}: archived AVD differs")
        if serial == "emulator-5562":
            require(launch["pid"] == expected["pid"] and launch["serial"] == serial,
                    "API 26 launch PID/serial differs")
        module.require_adb_command(item["state"], serial, "get-state")
        module.require_adb_command(item["avd"], serial, "emu", "avd", "name")
        require(item["state"]["exit"] == item["avd"]["exit"] == 0 and
                item["state"]["stdout"] == "device" and
                item["avd"]["stdout"].splitlines()[:1] == [expected["avd"]],
                f"{serial}: recorded device owner differs")
        original_root = ORIGINAL_TASK.parents[2]
        command = expected["command"].replace(str(module.ROOT), str(original_root))
        require(item["process"]["argv"] ==
                ["ps", "-p", str(expected["pid"]), "-o", "command="] and
                item["process"]["exit"] == 0 and
                item["process"]["stdout"] == command,
                f"{serial}: recorded host owner differs")
        lock = ORIGINAL_TASK / expected["avd_dir"] / "multiinstance.lock"
        require(item["avd_files"]["argv"] ==
                ["lsof", "-nP", "-p", str(expected["pid"]), "-Fn"] and
                item["avd_files"]["exit"] == 0 and
                f"n{lock}" in item["avd_files"]["stdout"].splitlines(),
                f"{serial}: task-owned AVD lock differs")
        for port in (expected["port"], expected["port"] + 1):
            line = item["ports"][str(port)]
            require(line["argv"] ==
                    ["lsof", "-nP", f"-iTCP:{port}", "-sTCP:LISTEN", "-Fpcn"] and
                    line["exit"] == 0 and
                    set(re.findall(r"(?m)^p(\d+)$", line["stdout"])) ==
                    {str(expected["pid"])} and f":{port}" in line["stdout"],
                    f"{serial}: recorded port owner differs")


def replay_runtime(receipt=None):
    module = reviewed_module()
    if receipt is None:
        receipt = read_json("raw/run5-receipt.json")
    epoch = source_epoch(module, receipt)
    ownership(module, receipt)
    require(receipt.get("schema_version") == 1 and
            set(receipt.get("devices", {})) == set(module.DEVICES),
            "runtime schema/device set changed")
    compressed = (ROOT / "artifacts/build3-apk.gz").read_bytes()
    apk_bytes = gzip.decompress(compressed)
    require(len(apk_bytes) == 19801272 and sha256(apk_bytes).hexdigest() == APK_SHA256,
            "exact fixture APK artifact changed")
    with TemporaryDirectory(prefix="walletcore-api-evidence-") as temp:
        out = Path(temp)
        apk = out / "walletcore-api-candidate.apk"
        apk.write_bytes(apk_bytes)
        phases = {}
        for serial in module.DEVICES:
            original = receipt["devices"][serial]
            phase = copy.deepcopy(original)
            installed = out / f"{serial}-installed.apk"
            installed.write_bytes(apk_bytes)
            original_pull = ORIGINAL_TASK / "task-16f-walletcore-api-fixture" / "runtime-run5" / installed.name
            original_apk = ORIGINAL_TASK / epoch["task_artifact"]
            require(original["pull_path"] == str(original_pull) and
                    original["pull"]["argv"][-1] == str(original_pull) and
                    original["install"]["argv"][-1] == str(original_apk),
                    f"{serial}: original installed APK source path differs")
            phase["pull_path"] = str(installed)
            phase["pull"]["argv"][-1] = str(installed)
            phase["install"]["argv"][-1] = str(apk)
            phases[serial] = module.verify_device(serial, phase, apk, out)
        result = {"passed": True, "devices": phases}
    require(result == read_json("raw/run5-verification.json") ==
            read_json("raw/run5-replay-normal.json") ==
            read_json("raw/run5-replay-optimized.json"),
            "recorded standalone runtime replay differs")
    return result


def historical_failures():
    heads = {1: "c92998282e4c320765f2f8c77c74cacf613ee776",
             2: "8242168c47d89326db681bfbb71f951df0efa3ff",
             3: "dff250b50561c6b8f95a997092b7a217a0041639",
             4: "07aa285a3ad47d963fd981f94b0fb23f307a3960"}
    for run, head in heads.items():
        receipt = read_json(f"raw/run{run}-receipt.json")
        devices = receipt["devices"]
        require(receipt["git_head"] == head and
                devices["emulator-5560"]["events"][-1]["status"] == "PASS",
                f"run{run}: historical partial phase changed")
        api = devices["emulator-5562"]
        require("events" not in api, f"run{run}: API 26 was mislabeled complete")
        if run == 1:
            require("install" not in api and api["initial"]["page"]["stdout"] == "" and
                    "usage: grep" in api["initial"]["page"]["stderr"],
                    "run1: page-probe failure differs")
        elif run in (2, 3):
            require(api["pulled_apk_sha256"] == APK_SHA256 and
                    api["logcat_clear"]["exit"] == 1 and "start" not in api,
                    f"run{run}: log-clear failure differs")
        else:
            require(api["pulled_apk_sha256"] == APK_SHA256 and
                    api["start"]["exit"] == -15 and "events" not in api,
                    "run4: launch-wait failure differs")
            raw = read_json("raw/run4-api26-independent-logcat.json")
            require(raw["exit"] == 0 and raw["nonce"] == api["token"] and
                    sha256(raw["stdout"].encode()).hexdigest() == raw["stdout_sha256"],
                    "run4: independent raw log differs")
    return sorted(heads)


def main():
    try:
        members = verify_members()
        runtime = replay_runtime()
        failed = historical_failures()
    except (OSError, ValueError, KeyError, TypeError, ImportError) as error:
        print(f"Wallet Core API evidence rejected: {error}", file=sys.stderr)
        return 1
    print(json.dumps({"passed": True, "members": members,
                      "runtime_pids": {serial: item["pid"] for serial, item
                                       in runtime["devices"].items()},
                      "preserved_partial_attempts": failed}, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
