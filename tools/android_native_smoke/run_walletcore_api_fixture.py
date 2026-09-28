#!/usr/bin/env python3
"""Run the exact production-adapter fixture on offline 16 KB and API 26 emulators."""

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import secrets
import struct
import subprocess
import sys
import time

from verify_walletcore_api_fixture import (
    APK_SHA256, DEVICES, EPOCH_SHA256, PACKAGE, ROOT, SOURCES, TAG, TOOLS,
    digest, inspect_apk, parse_events, require, require_epoch, require_git_head,
    require_snapshot, verify,
)


ADB = Path("/opt/homebrew/share/android-commandlinetools/platform-tools/adb")
AAPT = Path("/opt/homebrew/share/android-commandlinetools/build-tools/36.0.0/aapt")
ZIPALIGN = Path("/opt/homebrew/share/android-commandlinetools/build-tools/36.0.0/zipalign")
APKSIGNER = Path("/opt/homebrew/share/android-commandlinetools/build-tools/36.0.0/apksigner")


def call(argv):
    result = subprocess.run([str(value) for value in argv], cwd=ROOT,
                            capture_output=True, text=True, check=False)
    return {"argv": [str(value) for value in argv], "exit": result.returncode,
            "stdout": result.stdout.strip(), "stderr": result.stderr.strip()}


def adb(serial, *args):
    require(serial in DEVICES, "unreviewed device serial")
    return call([ADB, "-s", serial, *args])


def snapshot(serial):
    commands = {
        "boot": ("shell", "getprop", "sys.boot_completed"),
        "sdk": ("shell", "getprop", "ro.build.version.sdk"),
        "abi": ("shell", "getprop", "ro.product.cpu.abi"),
        "airplane": ("shell", "settings", "get", "global", "airplane_mode_on"),
        "wifi": ("shell", "settings", "get", "global", "wifi_on"),
        "route": ("shell", "ip", "route"),
        "default_network": ("shell", "sh", "-c",
                            "dumpsys connectivity | grep 'Active default network'"),
    }
    if DEVICES[serial]["strict"]:
        commands.update({
            "page": ("shell", "getconf", "PAGE_SIZE"),
            "linker": ("shell", "getprop", "bionic.linker.16kb.app_compat.enabled"),
            "compat": ("shell", "getprop", "pm.16kb.app_compat.disabled"),
        })
    else:
        commands["page"] = ("shell", "sh", "-c",
                            "grep KernelPageSize /proc/1/smaps | head -1")
    state = {"state": adb(serial, "get-state")}
    state.update({key: adb(serial, *argv) for key, argv in commands.items()})
    return state


def prepare_strict(serial):
    require(serial == "emulator-5560", "strict setup targeted wrong emulator")
    return [
        adb(serial, "shell", "cmd", "connectivity", "airplane-mode", "enable"),
        adb(serial, "shell", "svc", "wifi", "disable"),
        adb(serial, "shell", "setprop", "bionic.linker.16kb.app_compat.enabled", "fatal"),
        adb(serial, "shell", "setprop", "pm.16kb.app_compat.disabled", "true"),
    ]


def run_device(serial, apk, out, item):
    page = DEVICES[serial]["page"]
    item["apk_info"] = inspect_apk(apk, page)
    item["pre"] = snapshot(serial)
    require_snapshot(item["pre"], serial, "pre")
    item["badging"] = call([AAPT, "dump", "badging", apk])
    item["permissions"] = call([AAPT, "dump", "permissions", apk])
    require(item["badging"]["exit"] == item["permissions"]["exit"] == 0 and
            f"package: name='{PACKAGE}'" in item["badging"]["stdout"] and
            "uses-permission" not in item["permissions"]["stdout"],
            f"{serial}: package or permission changed")
    item["zipalign"] = call([ZIPALIGN, "-c", "-P", "16", "-v", "4", apk])
    item["apksigner"] = call([APKSIGNER, "verify", "--verbose", apk])
    require(item["zipalign"]["exit"] == item["apksigner"]["exit"] == 0,
            f"{serial}: APK alignment/signature failed")
    try:
        item["install"] = adb(serial, "install", "-r", apk)
        require(item["install"]["exit"] == 0, f"{serial}: install failed")
        item["clear"] = adb(serial, "shell", "pm", "clear", PACKAGE)
        require(item["clear"]["exit"] == 0, f"{serial}: clear failed")
        item["pm_path"] = adb(serial, "shell", "pm", "path", PACKAGE)
        path = item["pm_path"]["stdout"]
        require(item["pm_path"]["exit"] == 0 and
                re.fullmatch(r"package:/data/app/.+/base\.apk", path),
                f"{serial}: installed APK path invalid")
        pulled = out / f"{serial}-installed.apk"
        item["pull"] = adb(serial, "pull", path.removeprefix("package:"), pulled)
        require(item["pull"]["exit"] == 0 and pulled.is_file(),
                f"{serial}: installed APK pull failed")
        item["pulled_apk_sha256"] = digest(pulled)
        require(item["pulled_apk_sha256"] == APK_SHA256,
                f"{serial}: installed APK differs")
        item["logcat_clear"] = adb(serial, "logcat", "-c")
        require(item["logcat_clear"]["exit"] == 0, f"{serial}: logcat clear failed")
        item["token"] = secrets.token_hex(16)
        item["start"] = adb(serial, "shell", "am", "start", "-W", "-n",
                            f"{PACKAGE}/ai.n42.fixture.walletcoreapi.MainActivity",
                            "--es", "token", item["token"])
        require(item["start"]["exit"] == 0, f"{serial}: start failed")
        for attempt in range(60):
            fetched = adb(serial, "logcat", "-d", "-v", "threadtime", "-s", f"{TAG}:I")
            item["last_logcat"] = fetched
            require(fetched["exit"] == 0, f"{serial}: logcat failed")
            if '"kind":"END"' in fetched["stdout"] and item["token"] in fetched["stdout"]:
                item["result_logcat"] = fetched
                item["result_attempt"] = attempt + 1
                item["events"] = parse_events(fetched["stdout"], item["token"])
                break
            time.sleep(0.2)
    finally:
        item["post"] = snapshot(serial)
        item["force_stop"] = adb(serial, "shell", "am", "force-stop", PACKAGE)
    require("events" in item, f"{serial}: no complete fixture record; inspect receipt")
    require_snapshot(item["post"], serial, "post")
    require(item["force_stop"]["exit"] == 0, f"{serial}: force-stop failed")


def run(task, apk, out):
    require(out.is_relative_to(task) and not out.exists(),
            "new receipt directory must be under task root")
    for path, expected in TOOLS.items():
        require(Path(path).is_file() and digest(path) == expected,
                f"device tool changed: {path}")
    epoch = require_epoch(task, apk)
    head = call(["git", "rev-parse", "HEAD"])["stdout"]
    hashes = {name: digest(ROOT / name) for name in SOURCES}
    require_git_head(head, hashes)
    out.mkdir(parents=True)
    path = out / "walletcore-api-runtime-receipt.json"
    receipt = {"schema_version": 1,
               "started_utc": datetime.now(timezone.utc).isoformat(),
               "git_head": head, "source_sha256": hashes,
               "build_epoch": epoch, "build_epoch_sha256": EPOCH_SHA256,
               "device_tools": TOOLS, "apk_sha256": APK_SHA256, "devices": {}}
    path.write_text(json.dumps(receipt, indent=2) + "\n")
    for serial in DEVICES:
        item = receipt["devices"][serial] = {}
        try:
            if DEVICES[serial]["strict"]:
                item["strict_setup"] = prepare_strict(serial)
                require(all(result["exit"] == 0 for result in item["strict_setup"]),
                        "strict setup failed")
            else:
                item["initial"] = snapshot(serial)
                require_snapshot(item["initial"], serial, "initial")
            run_device(serial, apk, out, item)
        finally:
            path.write_text(json.dumps(receipt, indent=2) + "\n")
    result = verify(receipt, task, apk)
    verified = out / "walletcore-api-runtime-verification.json"
    verified.write_text(json.dumps(result, indent=2) + "\n")
    return path, verified


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--task-root", required=True, type=Path)
    parser.add_argument("--apk", required=True, type=Path)
    parser.add_argument("--out-dir", required=True, type=Path)
    args = parser.parse_args()
    try:
        receipt, verified = run(args.task_root.resolve(), args.apk.resolve(),
                                args.out_dir.resolve())
    except (OSError, ValueError, KeyError, struct.error) as error:
        print(f"Wallet Core API fixture rejected: {error}", file=sys.stderr)
        return 1
    print(f"WALLETCORE_API_FIXTURE_PASS receipt={receipt} verification={verified}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
