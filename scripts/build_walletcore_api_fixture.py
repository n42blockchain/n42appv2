#!/usr/bin/env python3
"""Build a separate offline fixture with the exact production Bitcoin V2 adapter."""

import argparse
from hashlib import sha256
from io import BytesIO
import json
from pathlib import Path
import shutil
import subprocess
from zipfile import ZipFile

import build_walletcore_fixture as prior


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "tools/android_native_smoke/walletcore_api_fixture"
ADAPTER = ROOT / "android/app/src/main/java/ai/n42/www/walletcore/BitcoinV2SigningAdapter.java"
ADAPTER_SHA256 = "aaff324d1ab949204c8613c57fae5eed860abc97d04e6b8351d56d39cd2e3ce9"
PRIOR_SCRIPT_SHA256 = "316487b2fca8f783f1ecad0d2bb667c100978799d5b579f1a9aef64a4f2f3d18"
FILES = (
    "settings.gradle.kts", "build.gradle.kts", "app/build.gradle.kts",
    "app/src/main/AndroidManifest.xml",
    "app/src/main/java/ai/n42/fixture/walletcoreapi/MainActivity.java",
)
SOURCE_SHA256 = {
    "settings.gradle.kts": "4ac4a871295d0ecc7363a843bc71f316f3175ad77aaa87ae7a0d3f2f9aa51e1a",
    "build.gradle.kts": "d427f3d52a7f790915922ae521eae46a1d6d3c194aa9d6a7ef70033016b8a98a",
    "app/build.gradle.kts": "8264dc7fe4614f203b1383b045921f7901258c96a14b300b4862d93c19022479",
    "app/src/main/AndroidManifest.xml": "ce1f1cfe13819cc4e791aef4dd0660c393a9c28f837490e7932d1493c59f61f6",
    "app/src/main/java/ai/n42/fixture/walletcoreapi/MainActivity.java": "80527f9fb27a4cc4a846abbaa21811424439726f04acc1755c61536b8c64f94b",
}


def checked_source(path, expected):
    if not path.is_file() or path.is_symlink():
        raise ValueError(f"missing or linked source: {path}")
    content = path.read_bytes()
    if sha256(content).hexdigest() != expected:
        raise ValueError(f"source SHA256 mismatch: {path}")
    return content


def build(task, out):
    if not out.is_relative_to(task) or out.exists():
        raise ValueError("new output directory must be within task root")
    checked_source(Path(prior.__file__), PRIOR_SCRIPT_SHA256)
    adapter = checked_source(ADAPTER, ADAPTER_SHA256)
    source = {name: sha256(checked_source(PROJECT / name, SOURCE_SHA256[name])).hexdigest()
              for name in FILES}
    data, inherited = prior.preflight(task)
    out.mkdir(parents=True)
    inputs = out / "inputs"
    inputs.mkdir()
    for name in ("candidate_aar", "proto_jar", "javalite_jar"):
        (inputs / prior.STAGED_NAMES[name]).write_bytes(data[name])
    adapter_root = inputs / "adapter-src"
    staged_adapter = adapter_root / "ai/n42/www/walletcore/BitcoinV2SigningAdapter.java"
    staged_adapter.parent.mkdir(parents=True)
    staged_adapter.write_bytes(adapter)

    keystore = task / "task-16f-walletcore-build/fixture-keystore.jks"
    if not keystore.is_file():
        raise ValueError("previous synthetic fixture key is missing")
    aapt2 = task / "task-16f-walletcore-build/fixture-tools/aapt2"
    prior.checked_bytes(aapt2, prior.AAPT2_SHA256)
    environment = {
        "HOME": str(task / "task-16f-walletcore-build/fixture-home"),
        "JAVA_HOME": str(prior.JDK), "ANDROID_HOME": str(prior.ANDROID_SDK),
        "ANDROID_SDK_ROOT": str(prior.ANDROID_SDK),
        "GRADLE_USER_HOME": str(task / "task-16f-walletcore-build/gradle-home"),
        "PATH": f"{prior.JDK / 'bin'}:/usr/bin:/bin:/usr/sbin:/sbin",
        "LANG": "C.UTF-8", "TMPDIR": str(out / "tmp"),
    }
    Path(environment["TMPDIR"]).mkdir()
    build_root = out / "build"
    command = [str(prior.GRADLE), "--offline", "--no-daemon", "--max-workers=2",
               "--project-cache-dir", str(out / "project-cache"),
               f"-PwalletCoreFixtureAar={inputs / prior.STAGED_NAMES['candidate_aar']}",
               f"-PwalletCoreFixtureProto={inputs / prior.STAGED_NAMES['proto_jar']}",
               f"-PwalletCoreFixtureJavalite={inputs / prior.STAGED_NAMES['javalite_jar']}",
               f"-PwalletCoreFixtureBuildRoot={build_root}",
               f"-PwalletCoreFixtureKeystore={keystore}",
               f"-PwalletCoreApiAdapterSource={adapter_root}",
               f"-Pandroid.aapt2FromMavenOverride={aapt2}", ":app:assembleRelease"]
    receipt = {"adapter_sha256": ADAPTER_SHA256,
               "prior_builder_sha256": PRIOR_SCRIPT_SHA256,
               "project_source_sha256": source,
               "input_sha256": {key: prior.PINS[key] for key in
                                ("candidate_aar", "proto_jar", "javalite_jar")},
               "candidate_arm64_jni_sha256": inherited["aar_members"]["candidate"]["arm64_jni_sha256"],
               "keystore_sha256": sha256(keystore.read_bytes()).hexdigest(),
               "tool_sha256": {"gradle": prior.GRADLE_SHA256,
                               "aapt2": prior.AAPT2_SHA256,
                               "aapt2_jar": prior.AAPT2_JAR_SHA256},
               "command": command, "environment": environment}
    (out / "preflight.json").write_text(json.dumps(receipt, indent=2) + "\n")
    with (out / "gradle.log").open("w") as log:
        result = subprocess.run(command, cwd=PROJECT, env=environment, stdout=log,
                                stderr=subprocess.STDOUT, check=False)
    receipt["gradle_exit"] = result.returncode
    for name in ("candidate_aar", "proto_jar", "javalite_jar"):
        prior.checked_bytes(inputs / prior.STAGED_NAMES[name], prior.PINS[name])
    prior.checked_bytes(aapt2, prior.AAPT2_SHA256)
    checked_source(staged_adapter, ADAPTER_SHA256)
    checked_source(ADAPTER, ADAPTER_SHA256)
    if {name: sha256((PROJECT / name).read_bytes()).hexdigest() for name in FILES} != source:
        raise ValueError("fixture source changed during build")
    if result.returncode:
        (out / "build-result.json").write_text(json.dumps(receipt, indent=2) + "\n")
        raise ValueError("fixture Gradle failed; inspect gradle.log")
    built = build_root / "app/outputs/apk/release/app-release.apk"
    apk = out / "walletcore-api-candidate.apk"
    shutil.copyfile(built, apk)
    with ZipFile(BytesIO(apk.read_bytes())) as archive:
        native = archive.read("lib/arm64-v8a/libTrustWalletCore.so")
    receipt["apk_sha256"] = sha256(apk.read_bytes()).hexdigest()
    receipt["apk_bytes"] = apk.stat().st_size
    receipt["apk_native_sha256"] = sha256(native).hexdigest()
    (out / "build-result.json").write_text(json.dumps(receipt, indent=2) + "\n")
    return receipt


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--task-root", required=True, type=Path)
    parser.add_argument("--out-dir", required=True, type=Path)
    args = parser.parse_args()
    try:
        result = build(args.task_root.resolve(), args.out_dir.resolve())
    except (OSError, ValueError, KeyError) as error:
        parser.exit(1, f"Wallet Core API fixture rejected: {error}\n")
    print(json.dumps({key: result[key] for key in
                      ("apk_sha256", "apk_bytes", "apk_native_sha256")}, indent=2))


if __name__ == "__main__":
    main()
