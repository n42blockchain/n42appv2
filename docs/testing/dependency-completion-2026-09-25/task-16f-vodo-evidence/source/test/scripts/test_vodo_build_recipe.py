import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts/build_vodo_android.sh"
INPUTS = (
    "android/cargokit_options.yaml",
    "packages/flutter_vodozemac/rust/Cargo.toml",
    "packages/flutter_vodozemac/rust/Cargo.lock",
    "packages/flutter_vodozemac/rust/LICENSE",
    "packages/flutter_vodozemac/rust/cargokit.yaml",
    "packages/flutter_vodozemac/rust/src/bindings.rs",
    "packages/flutter_vodozemac/rust/src/frb_generated.rs",
    "packages/flutter_vodozemac/rust/src/ios_ffi_bindings.rs",
    "packages/flutter_vodozemac/rust/src/lib.rs",
    "packages/flutter_vodozemac/cargokit/build_tool/pubspec.lock",
    "packages/flutter_vodozemac/cargokit/build_tool/lib/src/android_environment.dart",
    "packages/flutter_vodozemac/cargokit/build_tool/lib/src/builder.dart",
    "packages/flutter_vodozemac/cargokit/run_build_tool.sh",
)


class VodoBuildRecipeTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="vodo-build-recipe-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for name in INPUTS:
            source = ROOT / name
            if source.exists():
                destination = self.root / name
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, destination)
        script = self.root / "scripts/build_vodo_android.sh"
        script.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(SCRIPT, script)
        sdk = self.root / "synthetic-sdk"
        clang = sdk / "ndk/28.2.13676358/toolchains/llvm/prebuilt/darwin-x86_64/bin/clang"
        clang.parent.mkdir(parents=True)
        clang.write_text("fixture clang; not executed\n")
        (sdk / "ndk/28.2.13676358/source.properties").write_text(
            "Pkg.Revision = 28.2.13676358\n"
        )
        local = self.root / "android/local.properties"
        local.write_text(f"sdk.dir={sdk}\n")
        self.bin = self.root / "bin"
        self.bin.mkdir()
        # The synthetic compiler only lets the recipe controls run without an
        # NDK installation. A separate real --preflight verifies its real hash.
        shasum = self.bin / "shasum"
        shasum.write_text(
            "#!/usr/bin/env python3\n"
            "import hashlib, pathlib, sys\n"
            "path = pathlib.Path(sys.argv[-1])\n"
            "digest = ('df85444b66234bf4cae267e22bde45ea8fef596d30ca2991b2091a27e6ea7718'\n"
            "          if path.name == 'clang' else hashlib.sha256(path.read_bytes()).hexdigest())\n"
            "print(digest, path)\n"
        )
        shasum.chmod(0o755)
        rustup = self.bin / "rustup"
        rustup.write_text(
            "#!/usr/bin/env python3\n"
            "import json, os, pathlib, sys\n"
            "args = sys.argv[1:]\n"
            "if args == ['run', 'stable', 'rustc', '--version']:\n"
            "    print('rustc 1.97.1 (8bab26f4f 2026-07-14)')\n"
            "elif args == ['run', 'stable', 'cargo', '--version']:\n"
            "    print('cargo 1.97.1 (000000000 2026-07-14)')\n"
            "elif args == ['target', 'list', '--toolchain', 'stable', '--installed']:\n"
            "    print('aarch64-linux-android\\narmv7-linux-androideabi\\n'"
            "          'i686-linux-android\\nx86_64-linux-android')\n"
            "elif args[:4] == ['run', 'stable', 'cargo', 'metadata']:\n"
            "    pathlib.Path(os.environ['VODO_TEST_MARKER']).write_text(json.dumps(dict(os.environ)))\n"
            "    print('{}')\n"
            "else:\n"
            "    raise SystemExit('unexpected rustup command: ' + repr(args))\n"
        )
        rustup.chmod(0o755)
        gradle = self.root / "android/gradlew"
        gradle.write_text(
            "#!/usr/bin/env python3\n"
            "import json, os, pathlib\n"
            "pathlib.Path(os.environ['VODO_TEST_GRADLE_MARKER']).write_text(json.dumps(dict(os.environ)))\n"
        )
        gradle.chmod(0o755)
        self.marker = self.root / "cargo-env.json"
        self.gradle_marker = self.root / "gradle-marker"
        (self.root / "cargo-home").mkdir()
        (self.root / "pub-cache").mkdir()

    def run_recipe(self, mode="--build", extra_env=None):
        env = os.environ.copy()
        env.update(
            PATH=f"{self.bin}:{env['PATH']}",
            CARGO_HOME=str(self.root / "cargo-home"),
            PUB_CACHE=str(self.root / "pub-cache"),
            VODO_TEST_MARKER=str(self.marker),
            VODO_TEST_GRADLE_MARKER=str(self.gradle_marker),
        )
        env.update(extra_env or {})
        return subprocess.run(
            ["bash", str(self.root / "scripts/build_vodo_android.sh"), mode],
            cwd=self.root,
            env=env,
            text=True,
            capture_output=True,
            check=False,
        )

    def test_unchanged_source_reaches_controlled_build(self):
        result = self.run_recipe()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.marker.is_file())
        self.assertTrue(self.gradle_marker.is_file())

    def test_changed_wrapper_source_rejected_before_cargo_or_gradle(self):
        source = self.root / "packages/flutter_vodozemac/rust/src/bindings.rs"
        source.write_bytes(source.read_bytes() + b"\n// changed wrapper input\n")
        result = self.run_recipe()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Rust source", result.stderr)
        self.assertFalse(self.marker.exists())
        self.assertFalse(self.gradle_marker.exists())

    def test_missing_or_extra_wrapper_source_rejected(self):
        source = self.root / "packages/flutter_vodozemac/rust/src/lib.rs"
        source.unlink()
        result = self.run_recipe()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Rust source", result.stderr)
        self.assertFalse(self.marker.exists())
        source.write_bytes((ROOT / "packages/flutter_vodozemac/rust/src/lib.rs").read_bytes())
        (source.parent / "extra.rs").write_text("// unexpected source\n")
        result = self.run_recipe()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Rust source", result.stderr)
        self.assertFalse(self.marker.exists())

    def test_cargo_compiler_aliases_do_not_reach_child(self):
        aliases = {
            "CARGO_BUILD_RUSTC": "/tmp/wrong-rustc",
            "CARGO_BUILD_RUSTC_WRAPPER": "/tmp/wrong-wrapper",
            "CARGO_BUILD_RUSTC_WORKSPACE_WRAPPER": "/tmp/wrong-workspace-wrapper",
            "VODO_LEGIT_SENTINEL": "preserved",
        }
        result = self.run_recipe(extra_env=aliases)
        self.assertEqual(result.returncode, 0, result.stderr)
        child_env = json.loads(self.marker.read_text())
        for name in aliases:
            if name.startswith("CARGO_BUILD_RUSTC"):
                self.assertNotIn(name, child_env)
                self.assertNotIn(name, json.loads(self.gradle_marker.read_text()))
        self.assertEqual(child_env["VODO_LEGIT_SENTINEL"], "preserved")
        self.assertEqual(json.loads(self.gradle_marker.read_text())["VODO_LEGIT_SENTINEL"], "preserved")
        self.assertTrue(self.gradle_marker.exists())


if __name__ == "__main__":
    unittest.main()
