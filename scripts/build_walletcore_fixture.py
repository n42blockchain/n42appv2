#!/usr/bin/env python3
"""Build one offline, task-owned Wallet Core synthetic Android fixture APK."""

import argparse
from hashlib import sha256
from io import BytesIO
import json
import os
from pathlib import Path
import shutil
import subprocess
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "tools/android_native_smoke/walletcore_fixture"
GRADLE = Path("/Users/jieliu/.gradle/wrapper/dists/gradle-9.8.0-all/619e6l8zt76uzaekhqdol0b60/gradle-9.8.0/bin/gradle")
GRADLE_SHA256 = "f1a69bc070c613e5818d469a1248c1833519dd096d6828bb6fa4cde76de769e0"
AAPT2_JAR = Path("/Users/jieliu/.gradle/caches/modules-2/files-2.1/com.android.tools.build/aapt2/9.4.1-15978811/8923869d6019c87d3f66294df0a82118d4488abd/aapt2-9.4.1-15978811-osx.jar")
AAPT2_JAR_SHA256 = "eb93ce9d0fa121333f12395b3ab30822c5cdb9155737f20d342fe71809757059"
AAPT2_SHA256 = "a6d0102e909213b2bbc50f5bf6e082a9727c029c4a48fca02fbaebbf87e65155"
JDK = Path("/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home")
ANDROID_SDK = Path("/opt/homebrew/share/android-commandlinetools")
PINS = {
    "baseline_aar": "04ea7ab9527beeb3f4d650b13108deb08ec8a857f4e62b86df3e953dfa9e4d87",
    "candidate_aar": "560cf86e132e4b4ee18afb70daf670e12e8fd34684a03eb38b9e49e39cd0f57d",
    "proto_jar": "95659a930e640196ace64743377d013f9cc71cdbfe471c1279fa9f7d65812a4b",
    "javalite_jar": "8f4f93d08cb37130ecb0bc69d376d7d27c36ff04ddb1bb27430b06caa9fa062e",
}
JNI_MEMBER = "jni/arm64-v8a/libTrustWalletCore.so"
JNI_SHA256 = {
    "baseline": "d01ca3db4312b3b64e3f8feddf581c3be8d25d729456873bb9042ed8c2d447e7",
    "candidate": "f2ad3625ae3e691369baaf3bede441f9b56500e5a2655b33baa0ca2866fa3a3d",
}
CLASSES_SHA256 = "5e86c61d0121af19c1bcf99043b21a6e4c8fa479bb6d1c9a20967eadb8bb6d4b"
SOURCE_FILES = (
    "settings.gradle.kts", "build.gradle.kts", "app/build.gradle.kts",
    "app/src/main/AndroidManifest.xml",
    "app/src/main/java/ai/n42/fixture/walletcore/MainActivity.java",
)
STAGED_NAMES = {"baseline_aar": "baseline.aar", "candidate_aar": "candidate.aar",
                "proto_jar": "wallet-core-proto.jar", "javalite_jar": "protobuf-javalite.jar"}


def digest(data):
    return sha256(data).hexdigest()


def checked_bytes(path, expected):
    if not path.is_file() or path.is_symlink():
        raise ValueError(f"missing or linked pinned input: {path}")
    data = path.read_bytes()
    if digest(data) != expected:
        raise ValueError(f"pinned input SHA256 changed: {path}")
    return data


def check_aar(data, phase):
    with ZipFile(BytesIO(data)) as archive:
        names = archive.namelist()
        if len(names) != len(set(names)) or JNI_MEMBER not in names:
            raise ValueError(f"{phase}: native AAR ZIP members changed")
        classes = archive.read("classes.jar")
        native = archive.read(JNI_MEMBER)
    if digest(classes) != CLASSES_SHA256 or digest(native) != JNI_SHA256[phase]:
        raise ValueError(f"{phase}: Java or ARM64 JNI member changed")
    return {"classes_sha256": digest(classes), "arm64_jni_sha256": digest(native)}


def input_paths(task):
    build = task / "task-16f-walletcore-build"
    return {
        "baseline_aar": build / "official/wallet-core-4.8.4.aar",
        "candidate_aar": ROOT / "android/native/wallet_core/maven/com/trustwallet/wallet-core/4.8.4/wallet-core-4.8.4.aar",
        "proto_jar": build / "official/wallet-core-proto-4.8.4.jar",
        "javalite_jar": build / "gradle-home/caches/modules-2/files-2.1/com.google.protobuf/protobuf-javalite/4.36.2/c932baa4d773e370af933797cde8e0d8ecaeb052/protobuf-javalite-4.36.2.jar",
    }


def preflight(task):
    data = {name: checked_bytes(path, PINS[name])
            for name, path in input_paths(task).items()}
    members = {phase: check_aar(data[f"{phase}_aar"], phase)
               for phase in ("baseline", "candidate")}
    if members["baseline"]["classes_sha256"] != members["candidate"]["classes_sha256"]:
        raise ValueError("baseline/candidate Java classes differ")
    source = {name: digest((PROJECT / name).read_bytes()) for name in SOURCE_FILES}
    checked_bytes(GRADLE, GRADLE_SHA256)
    with ZipFile(BytesIO(checked_bytes(AAPT2_JAR, AAPT2_JAR_SHA256))) as archive:
        aapt2 = archive.read("aapt2")
    if digest(aapt2) != AAPT2_SHA256:
        raise ValueError("pinned AAPT2 executable changed")
    if not (JDK / "bin/java").is_file() or not (JDK / "bin/keytool").is_file():
        raise ValueError("pinned JDK 17 is missing")
    if not ANDROID_SDK.is_dir():
        raise ValueError("Android SDK is missing")
    return data, {"input_sha256": PINS, "aar_members": members,
                  "source_sha256": source, "gradle_sha256": GRADLE_SHA256,
                  "aapt2_jar_sha256": AAPT2_JAR_SHA256,
                  "aapt2_executable_sha256": AAPT2_SHA256}


def build(task, phase, out_dir):
    if phase not in ("baseline", "candidate"):
        raise ValueError("unknown fixture phase")
    try:
        out_dir.relative_to(task)
    except ValueError as error:
        raise ValueError("fixture output must be under task root") from error
    if out_dir.exists():
        raise ValueError(f"fixture output already exists: {out_dir}")
    data, receipt = preflight(task)
    out_dir.mkdir(parents=True)
    staged = out_dir / "inputs"
    staged.mkdir()
    for name, contents in data.items():
        (staged / STAGED_NAMES[name]).write_bytes(contents)
    keystore = task / "task-16f-walletcore-build/fixture-keystore.jks"
    if not keystore.exists():
        command = [str(JDK / "bin/keytool"), "-genkeypair", "-keystore", str(keystore),
                   "-storepass", "synthetic-only", "-keypass", "synthetic-only",
                   "-alias", "fixture", "-dname", "CN=Wallet Core Synthetic Fixture",
                   "-keyalg", "RSA", "-keysize", "2048", "-validity", "3650", "-noprompt"]
        with (out_dir / "keytool.log").open("w") as log:
            key_result = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT,
                                        check=False)
        if key_result.returncode:
            raise ValueError("synthetic fixture keytool failed; inspect keytool.log")
    receipt["fixture_keystore_sha256"] = digest(keystore.read_bytes())
    tools_dir = task / "task-16f-walletcore-build/fixture-tools"
    tools_dir.mkdir(exist_ok=True)
    aapt2 = tools_dir / "aapt2"
    with ZipFile(BytesIO(checked_bytes(AAPT2_JAR, AAPT2_JAR_SHA256))) as archive:
        tool_bytes = archive.read("aapt2")
    if digest(tool_bytes) != AAPT2_SHA256:
        raise ValueError("pinned AAPT2 executable changed")
    if not aapt2.exists():
        aapt2.write_bytes(tool_bytes)
        aapt2.chmod(0o755)
    checked_bytes(aapt2, AAPT2_SHA256)
    receipt["aapt2_override"] = str(aapt2)
    apk = out_dir / f"walletcore-{phase}.apk"
    build_root = out_dir / "build"
    env = {"HOME": str(task / "task-16f-walletcore-build/fixture-home"),
           "JAVA_HOME": str(JDK), "ANDROID_HOME": str(ANDROID_SDK),
           "ANDROID_SDK_ROOT": str(ANDROID_SDK),
           "GRADLE_USER_HOME": str(task / "task-16f-walletcore-build/gradle-home"),
           "PATH": f"{JDK / 'bin'}:/usr/bin:/bin:/usr/sbin:/sbin",
           "LANG": "C.UTF-8", "TMPDIR": str(out_dir / "tmp")}
    Path(env["HOME"]).mkdir(parents=True, exist_ok=True)
    Path(env["TMPDIR"]).mkdir()
    command = [str(GRADLE), "--offline", "--no-daemon", "--max-workers=2",
               "--project-cache-dir", str(out_dir / "project-cache"),
               f"-PwalletCoreFixturePhase={phase}",
               f"-PwalletCoreFixtureAar={staged / STAGED_NAMES[phase + '_aar']}",
               f"-PwalletCoreFixtureProto={staged / STAGED_NAMES['proto_jar']}",
               f"-PwalletCoreFixtureJavalite={staged / STAGED_NAMES['javalite_jar']}",
               f"-PwalletCoreFixtureBuildRoot={build_root}",
               f"-PwalletCoreFixtureKeystore={keystore}", ":app:assembleRelease"]
    command.insert(-1, f"-Pandroid.aapt2FromMavenOverride={aapt2}")
    receipt["gradle_argv"] = command
    receipt["gradle_env"] = env
    (out_dir / "preflight.json").write_text(json.dumps(receipt, indent=2) + "\n")
    with (out_dir / "gradle.log").open("w") as log:
        result = subprocess.run(command, cwd=PROJECT, env=env, stdout=log,
                                stderr=subprocess.STDOUT, check=False)
    receipt["gradle_exit"] = result.returncode
    for name, expected in PINS.items():
        checked_bytes(staged / STAGED_NAMES[name], expected)
    checked_bytes(aapt2, AAPT2_SHA256)
    if {name: digest((PROJECT / name).read_bytes()) for name in SOURCE_FILES} != receipt["source_sha256"]:
        raise ValueError("fixture source changed during build")
    if result.returncode:
        (out_dir / "build-result.json").write_text(json.dumps(receipt, indent=2) + "\n")
        raise ValueError(f"fixture Gradle build failed: {phase}; inspect gradle.log")
    built = build_root / "app/outputs/apk/release/app-release.apk"
    if not built.is_file():
        raise ValueError("Gradle did not produce the release fixture APK")
    shutil.copyfile(built, apk)
    receipt["apk_sha256"] = digest(apk.read_bytes())
    receipt["apk_bytes"] = apk.stat().st_size
    (out_dir / "build-result.json").write_text(json.dumps(receipt, indent=2) + "\n")
    return receipt


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--task-root", required=True, type=Path)
    parser.add_argument("--phase", required=True, choices=("baseline", "candidate"))
    parser.add_argument("--out-dir", required=True, type=Path)
    args = parser.parse_args()
    try:
        result = build(args.task_root.resolve(), args.phase, args.out_dir.resolve())
    except (OSError, ValueError) as error:
        parser.exit(1, f"Wallet Core fixture rejected: {error}\n")
    print(json.dumps({"phase": args.phase, "apk_sha256": result["apk_sha256"],
                      "apk_bytes": result["apk_bytes"]}, indent=2))


if __name__ == "__main__":
    main()
