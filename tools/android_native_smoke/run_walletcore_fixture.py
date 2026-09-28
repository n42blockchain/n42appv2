#!/usr/bin/env python3
"""Run two exact Wallet Core JNI fixture APKs on offline strict emulator-5560."""

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

from verify_walletcore_fixture import (
    APK_SHA256, DEVICE, DEVICE_TOOL_SHA256, EPOCH_SHA256, PACKAGES, REVIEWED_SOURCES, ROOT,
    digest, member_and_executable_offsets, parse_events, require,
    require_epoch, require_git_epoch, require_strict, verify,
)


ADB = Path("/opt/homebrew/share/android-commandlinetools/platform-tools/adb")
AAPT = Path("/opt/homebrew/share/android-commandlinetools/build-tools/36.0.0/aapt")
ZIPALIGN = Path("/opt/homebrew/share/android-commandlinetools/build-tools/36.0.0/zipalign")
APKSIGNER = Path("/opt/homebrew/share/android-commandlinetools/build-tools/36.0.0/apksigner")
TOOL_SHA256 = {Path(path): expected for path, expected in DEVICE_TOOL_SHA256.items()}


def call(argv):
    result = subprocess.run([str(value) for value in argv], cwd=ROOT,
                            capture_output=True, text=True, check=False)
    return {"argv": [str(value) for value in argv], "exit": result.returncode,
            "stdout": result.stdout.strip(), "stderr": result.stderr.strip()}


def adb(*args):
    return call([ADB, "-s", DEVICE, *args])


def device_snapshot():
    commands = {
        "page_size": ("getconf", "PAGE_SIZE"),
        "linker_mode": ("getprop", "bionic.linker.16kb.app_compat.enabled"),
        "package_compat_disabled": ("getprop", "pm.16kb.app_compat.disabled"),
        "airplane_mode": ("settings", "get", "global", "airplane_mode_on"),
        "wifi_on": ("settings", "get", "global", "wifi_on"),
        "ip_route": ("ip", "route"),
    }
    return {name: adb("shell", *argv) for name, argv in commands.items()}


def configure_strict_offline():
    return [
        adb("shell", "cmd", "connectivity", "airplane-mode", "enable"),
        adb("shell", "svc", "wifi", "disable"),
        adb("shell", "setprop", "bionic.linker.16kb.app_compat.enabled", "fatal"),
        adb("shell", "setprop", "pm.16kb.app_compat.disabled", "true"),
    ]


def run_phase(phase, apk, out_dir, item):
    package = PACKAGES[phase]
    _, offset, loads = member_and_executable_offsets(apk)
    item.update({"package": package, "apk_sha256": APK_SHA256[phase],
                 "apk_bytes": apk.stat().st_size, "member_data_offset": offset,
                 "member_executable_loads": [list(pair) for pair in loads],
                 "pre": device_snapshot()})
    require_strict(item["pre"], f"{phase} pre")
    item["badging"] = call([AAPT, "dump", "badging", apk])
    require(item["badging"]["exit"] == 0, f"{phase}: aapt badging failed")
    item["permissions"] = call([AAPT, "dump", "permissions", apk])
    require(item["permissions"]["exit"] == 0 and
            "uses-permission" not in item["permissions"]["stdout"],
            f"{phase}: synthetic APK has an unexpected permission")
    match = re.search(r"^package: name='([^']+)'", item["badging"]["stdout"], re.M)
    target = re.search(r"^targetSdkVersion:'([^']+)'", item["badging"]["stdout"], re.M)
    require(match and match.group(1) == package and target and target.group(1) == "37",
            f"{phase}: APK package/target changed")
    item["zipalign"] = call([ZIPALIGN, "-c", "-P", "16", "-v", "4", apk])
    item["apksigner"] = call([APKSIGNER, "verify", "--verbose", apk])
    require(item["zipalign"]["exit"] == item["apksigner"]["exit"] == 0,
            f"{phase}: APK ZIP alignment/signature failed")
    try:
        item["install"] = adb("install", "-r", apk)
        require(item["install"]["exit"] == 0, f"{phase}: APK install failed")
        item["clear"] = adb("shell", "pm", "clear", package)
        require(item["clear"]["exit"] == 0, f"{phase}: synthetic app clear failed")
        item["pm_path"] = adb("shell", "pm", "path", package)
        require(item["pm_path"]["exit"] == 0, f"{phase}: installed package path missing")
        pm_path = item["pm_path"]["stdout"]
        require(re.fullmatch(r"package:/data/app/.+/base\.apk", pm_path),
                f"{phase}: installed APK path malformed")
        pulled = out_dir / f"{phase}-installed.apk"
        item["pull"] = adb("pull", pm_path.removeprefix("package:"), pulled)
        require(item["pull"]["exit"] == 0 and pulled.is_file(),
                f"{phase}: cannot pull installed APK")
        item["pulled_apk_sha256"] = digest(pulled)
        require(item["pulled_apk_sha256"] == APK_SHA256[phase],
                f"{phase}: installed APK bytes differ from reviewed local APK")
        item["logcat_clear"] = adb("logcat", "-c")
        require(item["logcat_clear"]["exit"] == 0, f"{phase}: logcat clear failed")
        item["token"] = secrets.token_hex(16)
        item["start"] = adb("shell", "am", "start", "-W", "-n",
                            f"{package}/ai.n42.fixture.walletcore.MainActivity",
                            "--es", "phase", phase, "--es", "token", item["token"])
        require(item["start"]["exit"] == 0, f"{phase}: synthetic app launch failed")
        for attempt in range(60):
            fetched = adb("logcat", "-d", "-v", "threadtime", "-s",
                          "N42_WALLETCORE_FIXTURE:I")
            item["last_logcat"] = fetched
            require(fetched["exit"] == 0, f"{phase}: logcat read failed")
            if '"kind":"END"' in fetched["stdout"] and item["token"] in fetched["stdout"]:
                item["result_logcat"] = fetched
                item["result_attempt"] = attempt + 1
                item["events"] = parse_events(fetched["stdout"], phase, item["token"])
                break
            time.sleep(0.2)
    finally:
        item["post"] = device_snapshot()
        item["force_stop"] = adb("shell", "am", "force-stop", package)
    require("events" in item, f"{phase}: no complete in-process result; inspect preserved logcat")
    require_strict(item["post"], f"{phase} post")
    require(item["force_stop"]["exit"] == 0, f"{phase}: force-stop failed")


def run(task, apks, out_dir):
    require(set(apks) == set(APK_SHA256), "missing or extra fixture APK")
    try:
        out_dir.relative_to(task)
    except ValueError as error:
        raise ValueError("runtime receipt output must be under task root") from error
    for path, expected in TOOL_SHA256.items():
        require(path.is_file() and digest(path) == expected, f"device tool changed: {path}")
    epoch = require_epoch(task, apks)
    head = call(["git", "rev-parse", "HEAD"])["stdout"]
    sources = {relative: digest(ROOT / relative) for relative in REVIEWED_SOURCES}
    require_git_epoch(head, sources)
    require(not out_dir.exists(), f"output already exists: {out_dir}")
    out_dir.mkdir(parents=True)
    receipt_path = out_dir / "walletcore-runtime-receipt.json"
    verification_path = out_dir / "walletcore-runtime-verification.json"
    receipt = {"schema_version": 1, "device": DEVICE,
               "started_utc": datetime.now(timezone.utc).isoformat(),
               "git_head": head, "source_sha256": sources,
               "build_epoch_sha256": EPOCH_SHA256, "build_epoch": epoch,
               "device_tool_sha256": {str(path): value for path, value in TOOL_SHA256.items()},
               "device_state": adb("get-state"), "initial": device_snapshot(), "phases": {}}
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n")
    require(receipt["device_state"]["exit"] == 0 and
            receipt["device_state"]["stdout"] == "device",
            "dedicated emulator-5560 is unavailable")
    try:
        receipt["strict_setup"] = configure_strict_offline()
        require(all(item["exit"] == 0 for item in receipt["strict_setup"]),
                "strict/offline setup failed")
        for phase in PACKAGES:
            receipt["phases"][phase] = {}
            try:
                run_phase(phase, apks[phase], out_dir, receipt["phases"][phase])
            finally:
                receipt_path.write_text(json.dumps(receipt, indent=2) + "\n")
    finally:
        receipt["strict_restore"] = configure_strict_offline()
        receipt["final"] = device_snapshot()
        receipt_path.write_text(json.dumps(receipt, indent=2) + "\n")
    require(all(item["exit"] == 0 for item in receipt["strict_restore"]),
            "strict/offline final state failed")
    result = verify(receipt, task, apks)
    verification_path.write_text(json.dumps(result, indent=2) + "\n")
    return receipt_path, verification_path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--task-root", type=Path, required=True)
    parser.add_argument("--baseline-apk", type=Path, required=True)
    parser.add_argument("--candidate-apk", type=Path, required=True)
    parser.add_argument("--out-dir", type=Path, required=True)
    args = parser.parse_args()
    apks = {phase: getattr(args, phase + "_apk").resolve() for phase in PACKAGES}
    try:
        receipt, verification = run(args.task_root.resolve(), apks, args.out_dir.resolve())
    except (OSError, ValueError, KeyError, struct.error) as error:
        print(f"Wallet Core fixture rejected: {error}", file=sys.stderr)
        return 1
    print(f"WALLETCORE_FIXTURE_PASS receipt={receipt} verification={verification}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
