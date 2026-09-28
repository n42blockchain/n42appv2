#!/usr/bin/env python3
"""Run the official, maintained and checksum-negative WCPay APKs on emulator-5560."""

import argparse
from datetime import datetime, timezone
from hashlib import sha256
import json
from pathlib import Path
import re
import subprocess
import sys
import time

from verify_reown_wcpay_fixture import (
    DEVICE, JNA_AAR_SHA256, PACKAGES, WCPAY, WCPAY_SHA256,
    digest, member_and_executable_offsets, require, require_strict, verify,
)


ROOT = Path(__file__).resolve().parents[2]
ADB = Path("/opt/homebrew/share/android-commandlinetools/platform-tools/adb")
AAPT = Path("/opt/homebrew/share/android-commandlinetools/build-tools/36.0.0/aapt")
ZIPALIGN = Path("/opt/homebrew/share/android-commandlinetools/build-tools/36.0.0/zipalign")
FIXTURE = ROOT / "tools/android_native_smoke/reown_wcpay_fixture"
SOURCE_FILES = (
    FIXTURE / "settings.gradle.kts",
    FIXTURE / "build.gradle.kts",
    FIXTURE / "gradle.properties",
    FIXTURE / "app/build.gradle.kts",
    FIXTURE / "app/src/main/AndroidManifest.xml",
    FIXTURE / "app/src/main/java/ai/n42/fixture/reown/MainActivity.kt",
    ROOT / "scripts/prepare_reown_wcpay_fixture.py",
    ROOT / "tools/android_native_smoke/run_reown_wcpay_fixture.py",
    ROOT / "tools/android_native_smoke/verify_reown_wcpay_fixture.py",
)


def call(argv):
    result = subprocess.run([str(value) for value in argv], cwd=ROOT,
                            capture_output=True, text=True, check=False)
    return {"argv": [str(value) for value in argv], "exit": result.returncode,
            "stdout": result.stdout.strip(), "stderr": result.stderr.strip()}


def adb(*args):
    return call([ADB, "-s", DEVICE, *args])


def device_snapshot():
    checks = {
        "page_size": ("getconf", "PAGE_SIZE"),
        "linker_mode": ("getprop", "bionic.linker.16kb.app_compat.enabled"),
        "package_compat_disabled": ("getprop", "pm.16kb.app_compat.disabled"),
        "airplane_mode": ("settings", "get", "global", "airplane_mode_on"),
        "ip_route": ("ip", "route"),
    }
    return {name: adb("shell", *args) for name, args in checks.items()}


def configure_strict_offline():
    return [
        adb("shell", "cmd", "connectivity", "airplane-mode", "enable"),
        adb("shell", "svc", "wifi", "disable"),
        adb("shell", "setprop", "bionic.linker.16kb.app_compat.enabled", "fatal"),
        adb("shell", "setprop", "pm.16kb.app_compat.disabled", "true"),
    ]


def run_phase(phase, apk, record):
    package = PACKAGES[phase]
    native, offset, loads = member_and_executable_offsets(apk, WCPAY)
    require(sha256(native).hexdigest() == WCPAY_SHA256[phase],
            f"{phase}: wrong WCPay APK member before install")
    record.update({"package": package, "apk_sha256": digest(apk),
                   "apk_bytes": apk.stat().st_size, "wcpay_member_sha256": sha256(native).hexdigest(),
                   "wcpay_data_offset": offset, "wcpay_executable_loads": loads,
                   "pre": device_snapshot()})
    require_strict(record["pre"], f"{phase} pre")
    record["badging"] = call([AAPT, "dump", "badging", apk])
    require(record["badging"]["exit"] == 0, f"{phase}: aapt failed")
    package_match = re.search(r"^package: name='([^']+)'", record["badging"]["stdout"], re.M)
    target_match = re.search(r"^targetSdkVersion:'([^']+)'", record["badging"]["stdout"], re.M)
    require(package_match and package_match.group(1) == package and
            target_match and target_match.group(1) == "37", f"{phase}: wrong package/target")
    record["zipalign"] = call([ZIPALIGN, "-c", "-P", "16", "-v", "4", apk])
    require(record["zipalign"]["exit"] == 0, f"{phase}: APK ZIP alignment failed")
    record["install"] = adb("install", "-r", apk)
    require(record["install"]["exit"] == 0, f"{phase}: install failed")
    record["clear"] = adb("shell", "pm", "clear", package)
    require(record["clear"]["exit"] == 0, f"{phase}: cannot clear synthetic app")
    record["pm_path"] = adb("shell", "pm", "path", package)
    record["start"] = adb("shell", "am", "start", "-W", "-n",
                          f"{package}/ai.n42.fixture.reown.MainActivity",
                          "--es", "phase", phase)
    require(record["start"]["exit"] == 0, f"{phase}: launch failed")
    for attempt in range(60):
        fetched = adb("shell", "run-as", package, "cat", "files/result.json")
        if fetched["exit"] == 0:
            record["result_fetch"] = fetched
            record["result_attempt"] = attempt + 1
            record["result"] = json.loads(fetched["stdout"])
            break
        time.sleep(0.2)
    record["post"] = device_snapshot()
    record["force_stop"] = adb("shell", "am", "force-stop", package)
    require("result" in record, f"{phase}: no in-process result; preserve log and inspect crash")
    require_strict(record["post"], f"{phase} post")
    require(record["force_stop"]["exit"] == 0, f"{phase}: force-stop failed")


def run(apks, jna_aar, out_dir):
    for tool in (ADB, AAPT, ZIPALIGN):
        require(tool.is_file(), f"missing tool: {tool}")
    for phase, apk in apks.items():
        require(apk.is_file(), f"missing {phase} APK: {apk}")
    require(jna_aar.is_file() and digest(jna_aar) == JNA_AAR_SHA256,
            "JNA 5.17.0 input identity mismatch")
    require(not out_dir.exists(), f"output already exists: {out_dir}")
    out_dir.mkdir(parents=True)
    receipt_file = out_dir / "reown-runtime-receipt.json"
    verification_file = out_dir / "reown-runtime-verification.json"
    receipt = {
        "schema_version": 1, "device": DEVICE,
        "started_utc": datetime.now(timezone.utc).isoformat(),
        "git_head": call(["git", "rev-parse", "HEAD"])["stdout"],
        "source_sha256": {str(path): digest(path) for path in SOURCE_FILES},
        "tool_sha256": {str(path): digest(path) for path in (ADB, AAPT, ZIPALIGN)},
        "jna_aar_sha256": digest(jna_aar),
        "device_state": adb("get-state"),
        "initial": device_snapshot(), "phases": {},
    }
    receipt_file.write_text(json.dumps(receipt, indent=2) + "\n")
    require(receipt["device_state"]["exit"] == 0 and
            receipt["device_state"]["stdout"] == "device",
            "dedicated emulator unavailable")
    try:
        receipt["strict_setup"] = configure_strict_offline()
        require(all(item["exit"] == 0 for item in receipt["strict_setup"]),
                "cannot establish strict offline state")
        for phase in PACKAGES:
            receipt["phases"][phase] = {}
            try:
                run_phase(phase, apks[phase], receipt["phases"][phase])
            finally:
                receipt_file.write_text(json.dumps(receipt, indent=2) + "\n")
    finally:
        receipt["strict_restore"] = configure_strict_offline()
        receipt["final"] = device_snapshot()
        receipt_file.write_text(json.dumps(receipt, indent=2) + "\n")
    require(all(item["exit"] == 0 for item in receipt["strict_restore"]),
            "strict/offline restoration failed")
    result = verify(receipt, apks, SOURCE_FILES, jna_aar)
    verification_file.write_text(json.dumps(result, indent=2) + "\n")
    return receipt_file, verification_file


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for phase in PACKAGES:
        parser.add_argument(f"--{phase}-apk", type=Path, required=True)
    parser.add_argument("--jna-aar", type=Path, required=True)
    parser.add_argument("--out-dir", type=Path, required=True)
    args = parser.parse_args()
    apks = {phase: getattr(args, phase + "_apk").resolve() for phase in PACKAGES}
    try:
        receipt, verification = run(apks, args.jna_aar.resolve(), args.out_dir.resolve())
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as error:
        print(f"Reown fixture rejected: {error}", file=sys.stderr)
        return 1
    print(f"REOWN_WCPAY_FIXTURE_PASS receipt={receipt} verification={verification}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
