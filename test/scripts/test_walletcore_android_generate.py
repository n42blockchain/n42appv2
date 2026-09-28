import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[2] / 'scripts/walletcore_android_generate.py'
SPEC = importlib.util.spec_from_file_location('walletcore_android_generate', SCRIPT)
generate = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(generate)


class WalletCoreAndroidGenerateTest(unittest.TestCase):
    def test_generator_environment_excludes_injected_build_overrides(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            build = root / 'build'
            source = build / 'source'
            files = {
                'ndk_source_properties': {'path': str(root / 'sdk/ndk/28.2/source.properties')},
                'ndk_clang': {'path': str(root / 'sdk/ndk/28.2/bin/clang')},
                'jdk17_java': {'path': str(root / 'jdk17/bin/java')},
                'rustc': {'path': str(root / 'rust/bin/rustc')},
                'rustdoc': {'path': str(root / 'rust/bin/rustdoc')},
                'cargo': {'path': str(root / 'rust/bin/cargo')},
                'cbindgen': {'path': str(root / 'host/bin/cbindgen')},
                'android_cmake': {'path': str(root / 'cmake/bin/cmake')},
            }
            poison = {name: '/tmp/untrusted' for name in (
                'RUBYOPT', 'RUBYLIB', 'PERL5OPT', 'PERL5LIB', 'CPATH',
                'C_INCLUDE_PATH', 'CPLUS_INCLUDE_PATH', 'LIBRARY_PATH',
                'CFLAGS', 'CXXFLAGS', 'CPPFLAGS', 'LDFLAGS', 'SDKROOT',
                'CC_aarch64_linux_android', 'CARGO_TARGET_DIR')}
            with patch.dict(os.environ, poison):
                env = generate.generator_environment(build, source, files)
            for name in poison:
                self.assertNotIn(name, env)
            self.assertEqual(env['RUSTC'], files['rustc']['path'])
            self.assertEqual(env['CARGO_BUILD_JOBS'], '2')
            self.assertEqual(env['ANDROID_NDK_HOME'], str(root / 'sdk/ndk/28.2'))

    def test_cargo_inserts_locked_before_program_arguments(self):
        self.assertEqual(generate.locked_cargo_args(['run', '--', 'cpp']),
                         ['run', '--locked', '--', 'cpp'])
        self.assertEqual(generate.locked_cargo_args(['build', '--release', '--lib']),
                         ['build', '--locked', '--release', '--lib'])
        with self.assertRaisesRegex(ValueError, 'unsupported Cargo command'):
            generate.locked_cargo_args(['update'])

    def test_preflight_requires_process_success_despite_existing_receipt(self):
        with tempfile.TemporaryDirectory() as directory:
            receipt = Path(directory) / 'preflight.json'
            receipt.write_text(json.dumps({'passed': True}))
            with patch.object(generate.subprocess, 'run', return_value=
                              subprocess.CompletedProcess([], 1, '', 'changed input')):
                with self.assertRaisesRegex(ValueError, 'preflight process failed'):
                    generate.require_preflight(['python3', 'preflight.py'], receipt)


if __name__ == '__main__':
    unittest.main()
