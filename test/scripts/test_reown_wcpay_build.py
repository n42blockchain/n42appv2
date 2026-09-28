import importlib.util
from pathlib import Path
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[2] / 'scripts/build_reown_wcpay_android.py'
SPEC = importlib.util.spec_from_file_location('build_reown_wcpay_android', SCRIPT)
assert SPEC is not None and SPEC.loader is not None
recipe = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(recipe)


class ReownWcpayBuildTest(unittest.TestCase):
    def test_release_binding_rewrite_preserves_contract_checks(self):
        original = ('package uniffi.yttrium\n'
                    'import uniffi.uniffi_yttrium.Ffi\n'
                    'private val contract = 30\n'
                    'if (checksum() != 6253.toShort()) error("mismatch")\n'
                    'return "uniffi_yttrium"\n')
        actual = recipe.rewrite_binding(original)
        self.assertIn('package uniffi.yttrium_wcpay', actual)
        self.assertIn('import uniffi.uniffi_yttrium_wcpay.Ffi', actual)
        self.assertIn('return "uniffi_yttrium_wcpay"', actual)
        self.assertIn('contract = 30', actual)
        self.assertIn('6253.toShort()', actual)

    def test_wrong_source_or_tool_bytes_are_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'input'
            path.write_bytes(b'altered')
            with self.assertRaisesRegex(ValueError, 'byte mismatch'):
                recipe.checked_hash(path, recipe.SOURCE_HASHES['Cargo.lock'])
            with self.assertRaisesRegex(ValueError, 'byte mismatch'):
                recipe.checked_hash(path, recipe.TOOL_HASHES['rustc'])

    def test_four_release_targets_and_link_flags(self):
        self.assertEqual(set(recipe.TARGETS.values()),
                         {'arm64-v8a', 'armeabi-v7a', 'x86', 'x86_64'})
        self.assertEqual(set(recipe.RUST_STD_HASHES), set(recipe.TARGETS))
        self.assertEqual(recipe.PROFILE, 'uniffi-release-kotlin-wcpay')
        self.assertEqual(recipe.FEATURES, 'android,pay,uniffi/cli')
        for flag in ('--gc-sections', 'max-page-size=16384',
                     'common-page-size=16384'):
            self.assertIn(flag, recipe.FLAGS)

    def test_inherited_global_and_target_flags_cannot_override_link(self):
        inherited = {'RUSTFLAGS': '-C panic=unwind',
                     'CARGO_ENCODED_RUSTFLAGS': 'bad',
                     'CARGO_TARGET_AARCH64_LINUX_ANDROID_RUSTFLAGS': 'bad',
                     'CARGO_NDK_PLATFORM': '35',
                     'CC_aarch64_linux_android': '/tmp/other-clang',
                     'OPENSSL_NO_VENDOR': '1', 'OTHER': 'retained'}
        env = recipe.child_environment(inherited, Path('/tmp/wcpay-test'),
                                       Path('/tmp/sdk/ndk/28.2.13676358'))
        self.assertNotIn('RUSTFLAGS', env)
        self.assertNotIn('CARGO_ENCODED_RUSTFLAGS', env)
        self.assertNotIn('CC_aarch64_linux_android', env)
        self.assertNotIn('OPENSSL_NO_VENDOR', env)
        self.assertEqual(env['CARGO_TARGET_AARCH64_LINUX_ANDROID_RUSTFLAGS'],
                         recipe.FLAGS)
        self.assertEqual(env['ANDROID_NDK_HOME'],
                         '/tmp/sdk/ndk/28.2.13676358')
        self.assertEqual(env['OTHER'], 'retained')

    def test_bindgen_uses_original_cdylib_filename(self):
        linked = Path('/tmp/target/libuniffi_yttrium.so')
        command = recipe.binding_command(Path('/tmp/cargo'), linked,
                                         Path('/tmp/bindings'))
        self.assertEqual(command[command.index('--library') + 1], str(linked))
        with self.assertRaisesRegex(ValueError, 'filename'):
            recipe.binding_command(Path('/tmp/cargo'),
                                   Path('/tmp/target/libuniffi_yttrium.raw.so'),
                                   Path('/tmp/bindings'))


if __name__ == '__main__':
    unittest.main()
