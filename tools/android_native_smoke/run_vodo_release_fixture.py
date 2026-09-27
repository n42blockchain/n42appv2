#!/usr/bin/env python3
"""Run the isolated Vodo release-member fixture with strict device receipts."""

import argparse
from hashlib import sha256
import json
import os
from pathlib import Path
import re
import subprocess
import sys
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parents[2]
HARNESS = ROOT / "tools/android_native_smoke/harness"
AAR = ROOT / "build/flutter_vodozemac/outputs/aar/flutter_vodozemac-release.aar"
APK = HARNESS / "build/app/outputs/flutter-apk/app-debug.apk"
FLUTTER = Path("/Users/jieliu/.codex/toolchains/flutter-3.47.5/flutter/bin/flutter")
EXPECTED_AAR = "7878472e22facc668152fff6c9e6a8858f9906b7994fd28c8d66b2c22822501a"
EXPECTED_MEMBER = "3807e8f54bf9be576ebe55aa41e363e7b23b845efb971f5821f439ab90ca14fa"
DEVICE = "emulator-5560"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    return sha256(path.read_bytes()).hexdigest()


def command(argv, *, cwd=ROOT):
    result = subprocess.run(argv, cwd=cwd, capture_output=True, text=True, check=False)
    return {"argv": argv, "exit": result.returncode, "stdout": result.stdout.strip(), "stderr": result.stderr.strip()}


def device_snapshot():
    calls = {
        "page_size": ["getconf", "PAGE_SIZE"],
        "linker_mode": ["getprop", "bionic.linker.16kb.app_compat.enabled"],
        "package_compat_disabled": ["getprop", "pm.16kb.app_compat.disabled"],
        "airplane_mode": ["settings", "get", "global", "airplane_mode_on"],
        "ip_route": ["ip", "route"],
    }
    return {
        name: command(["adb", "-s", DEVICE, "shell", *arguments])
        for name, arguments in calls.items()
    }


def require_strict(snapshot, phase):
    expected = {
        "page_size": "16384",
        "linker_mode": "fatal",
        "package_compat_disabled": "true",
        "airplane_mode": "1",
        "ip_route": "",
    }
    for name, value in expected.items():
        observed = snapshot.get(name)
        require(isinstance(observed, dict), f"{phase} missing {name}")
        require(observed.get("exit") == 0, f"{phase} {name} command failed")
        require(observed.get("stdout") == value, f"{phase} {name} mismatch")


def run(out_dir):
    out_dir.mkdir(parents=True, exist_ok=True)
    receipt_path = out_dir / "vodo-release-inputs.json"
    log_path = out_dir / "vodo-release-runtime.log"
    probe_dir = out_dir / "task-16f-vodo-release-probe-jni"
    probe = probe_dir / "arm64-v8a/libvodozemac_release_probe.so"
    require(FLUTTER.is_file(), "isolated Flutter toolchain missing")
    require(AAR.is_file() and probe.is_file(), "release AAR or byte-identical fixture probe missing")
    with ZipFile(AAR) as archive:
        release_member = archive.read("jni/arm64-v8a/libvodozemac_bindings_dart.so")
    receipt = {
        "schema_version": 1,
        "device": DEVICE,
        "git_head": command(["git", "rev-parse", "HEAD"])["stdout"],
        "flutter_version": command([str(FLUTTER), "--version"])["stdout"],
        "aar_sha256": digest(AAR),
        "aar_arm64_member_sha256": sha256(release_member).hexdigest(),
        "probe_sha256": digest(probe),
        "source_sha256": {
            name: digest(ROOT / name)
            for name in (
                "tools/android_native_smoke/harness/android/app/build.gradle.kts",
                "tools/android_native_smoke/harness/fixtures/vodozemac-0.5-pickles.json",
                "tools/android_native_smoke/harness/integration_test/vodo_android_16k_test.dart",
                "tools/android_native_smoke/harness/pubspec.yaml",
                "tools/android_native_smoke/harness/pubspec.lock",
                "tools/android_native_smoke/verify_vodo_release_fixture.py",
                "tools/android_native_smoke/run_vodo_release_fixture.py",
            )
        },
        "pre": device_snapshot(),
    }
    receipt_path.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
    require(receipt["aar_sha256"] == EXPECTED_AAR, "reviewed release AAR hash mismatch")
    require(receipt["aar_arm64_member_sha256"] == EXPECTED_MEMBER, "release AAR member hash mismatch")
    require(receipt["probe_sha256"] == EXPECTED_MEMBER, "fixture probe differs from release member")
    require_strict(receipt["pre"], "pre")

    env = os.environ.copy()
    env.update(
        N42_SMOKE_VODO_RELEASE_JNILIBS=str(probe_dir),
        CARGO_HOME=str(out_dir / "task-16f-vodo-cargo-home"),
        CARGO_NET_OFFLINE="true",
        CARGOKIT_PUB_OFFLINE="1",
        PUB_CACHE=str(out_dir / "task-16f-vodo-pub-cache"),
        JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home",
        ANDROID_HOME="/Users/jieliu/.codex/toolchains/android-sdk-37",
    )
    for name in ("CARGO_HOME", "PUB_CACHE"):
        require(Path(env[name]).is_dir(), f"missing isolated {name}")
    argv = [
        str(FLUTTER), "test", "integration_test/vodo_android_16k_test.dart",
        "-d", DEVICE, "--no-pub", "--dart-define=N42_VODO_RELEASE_PROBE=true",
    ]
    receipt["fixture_command"] = argv
    receipt["fixture_environment"] = {
        name: env[name]
        for name in (
            "N42_SMOKE_VODO_RELEASE_JNILIBS", "CARGO_HOME", "CARGO_NET_OFFLINE",
            "CARGOKIT_PUB_OFFLINE", "PUB_CACHE", "JAVA_HOME", "ANDROID_HOME",
        )
    }
    try:
        with log_path.open("w") as output:
            process = subprocess.run(
                argv, cwd=HARNESS, env=env, stdout=output, stderr=subprocess.STDOUT, check=False
            )
        receipt["fixture_exit"] = process.returncode
        receipt["fixture_log_sha256"] = digest(log_path)
        receipt["apk_sha256"] = digest(APK)
        installed = re.findall(
            r"^VODO_INSTALLED_APK variant=release pid=(\d+) sha256=([0-9a-f]{64}) path=(/data/app/[^\s]+/base\.apk)$",
            log_path.read_text(), re.MULTILINE,
        )
        require(len(installed) == 1, "missing or duplicate device-computed APK identity")
        pid, installed_hash, installed_path = installed[0]
        receipt["installed"] = {"pid": int(pid), "sha256": installed_hash, "path": installed_path}
    finally:
        receipt["post"] = device_snapshot()
        receipt_path.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
    require(receipt["fixture_exit"] == 0, "release fixture failed")
    require_strict(receipt["post"], "post")
    require(receipt["installed"]["sha256"] == receipt["apk_sha256"], "installed and local APK hash differ")
    return receipt_path, log_path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out-dir", type=Path, required=True)
    args = parser.parse_args()
    try:
        receipt, log = run(args.out_dir.resolve())
    except (OSError, ValueError, KeyError) as error:
        print(f"Vodo release runner rejected: {error}", file=sys.stderr)
        return 1
    print("VODO_RELEASE_FIXTURE_PASS")
    print(f"receipt={receipt}")
    print(f"log={log}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
