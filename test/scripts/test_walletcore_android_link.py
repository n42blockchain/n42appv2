import importlib.util
import json
from pathlib import Path
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[2] / 'scripts/walletcore_android_link.py'
ENVIRONMENT = (SCRIPT.parents[1] / '.superpowers/sdd/dependency-completion-20260925'
               / 'task-16f-walletcore-build/generation-environment.json')
SPEC = importlib.util.spec_from_file_location('walletcore_android_link', SCRIPT)
link = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(link)


class WalletCoreAndroidLinkTest(unittest.TestCase):
    def test_patch_changes_only_android_shared_target(self):
        original = (b'if (${ANDROID})\n'
                    b'    add_library(TrustWalletCore SHARED ${sources} ${PROTO_SRCS} ${PROTO_HDRS})\n'
                    b'    find_library(log-lib log)\n'
                    b'elseif (${TW_COMPILE_JAVA})\n'
                    b'    add_library(TrustWalletCore SHARED ${sources} ${PROTO_SRCS} ${PROTO_HDRS})\n')
        updated = link.patch_cmake_text(original)
        self.assertEqual(updated.count(b'-Wl,-z,max-page-size=16384'), 1)
        self.assertEqual(updated.count(b'-Wl,-z,common-page-size=16384'), 1)
        self.assertIn(b'    target_link_options(TrustWalletCore PRIVATE ', updated)
        self.assertEqual(updated.split(b'elseif (${TW_COMPILE_JAVA})')[1],
                         original.split(b'elseif (${TW_COMPILE_JAVA})')[1])
        with self.assertRaisesRegex(ValueError, 'Android shared target anchor'):
            link.patch_cmake_text(b'add_library(TrustWalletCore STATIC x)')

    def test_generated_manifest_detects_changed_output(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            output = root / 'jni/android/generated/HDWallet.c'
            output.parent.mkdir(parents=True)
            output.write_bytes(b'original')
            manifest = {'files': {'jni/android/generated/HDWallet.c':
                       {'bytes': 8, 'sha256': link.sha256_bytes(b'original')}}}
            link.verify_generated_files(root, manifest)
            output.write_bytes(b'changed!')
            with self.assertRaisesRegex(ValueError, 'generated file mismatch'):
                link.verify_generated_files(root, manifest)

    def test_link_environment_rejects_added_changed_and_missing_values(self):
        original = ENVIRONMENT.read_bytes()
        expected = json.loads(original)
        self.assertEqual(link.load_pinned_environment(ENVIRONMENT), expected)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'generation-environment.json'
            for change in ('add', 'change', 'remove'):
                altered = dict(expected)
                if change == 'add':
                    altered['CPATH'] = '/tmp/poison'
                elif change == 'change':
                    altered['PATH'] = '/tmp/poison:' + altered['PATH']
                else:
                    del altered['ANDROID_NDK_HOME']
                path.write_text(json.dumps(altered, indent=2, sort_keys=True) + '\n')
                with self.subTest(change=change):
                    with self.assertRaisesRegex(ValueError, 'generation environment changed'):
                        link.load_pinned_environment(path)

    def test_link_environment_parses_the_checked_bytes(self):
        original = ENVIRONMENT.read_bytes()
        poisoned = json.loads(original)
        poisoned['PATH'] = '/tmp/poison:' + poisoned['PATH']

        class ReplacedBetweenReads:
            def __fspath__(self):
                return str(ENVIRONMENT)

            def read_text(self):
                return json.dumps(poisoned)

            def read_bytes(self):
                return original

        self.assertEqual(link.load_pinned_environment(ReplacedBetweenReads()),
                         json.loads(original))


if __name__ == '__main__':
    unittest.main()
