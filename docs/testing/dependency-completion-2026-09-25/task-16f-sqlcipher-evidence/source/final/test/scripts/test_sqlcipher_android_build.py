"""Guard the SQLCipher 4.19 Android native rebuild recipe."""

import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    'build_sqlcipher_android', REPO / 'scripts/build_sqlcipher_android.py')
if SPEC is not None and SPEC.loader is not None:
    build = importlib.util.module_from_spec(SPEC)
    SPEC.loader.exec_module(build)


class SQLCipherAndroidBuildTest(unittest.TestCase):
    def test_link_patch_preserves_max_and_adds_common_page_size(self):
        original = 'LOCAL_LDFLAGS += -Wl,-z,max-page-size=16384\n'
        patched = build.patch_android_mk(original)
        self.assertIn(original.strip(), patched)
        self.assertIn('LOCAL_LDFLAGS += -Wl,-z,common-page-size=16384', patched)
        self.assertEqual(patched.count('common-page-size=16384'), 1)

    def test_link_patch_rejects_changed_or_duplicate_input(self):
        with self.assertRaises(ValueError):
            build.patch_android_mk('LOCAL_LDFLAGS += -Wl,-z,max-page-size=4096\n')
        with self.assertRaises(ValueError):
            build.patch_android_mk(
                'LOCAL_LDFLAGS += -Wl,-z,max-page-size=16384\n'
                'LOCAL_LDFLAGS += -Wl,-z,common-page-size=16384\n')

    def test_jni_error_patch_uses_posix_bionic_return_value(self):
        original = (
            '#if __GLIBC__\n'
            '    // Note: glibc has a nonstandard strerror_r that returns char* rather than POSIX\'s int.\n'
            '    // char *strerror_r(int errnum, char *buf, size_t n);\n'
            '    return strerror_r(errnum, buf, buflen);\n'
            '#else\n'
            '    char* msg = strerror_r(errnum, buf, buflen);\n'
            '    if (msg != nullptr){\n'
            '        return msg;\n'
            '    }\n'
            '    snprintf(buf, buflen, "errno %d", errnum);\n'
            '    return buf;\n'
            '#endif\n'
        )
        patched = build.patch_jni_help(original)
        self.assertIn('defined(__USE_GNU) && __ANDROID_API__ >= 23', patched)
        self.assertIn('char* msg = strerror_r(errnum, buf, buflen);', patched)
        self.assertIn('int status = strerror_r(errnum, buf, buflen);', patched)
        self.assertIn('if (status == 0)', patched)
        self.assertIn('return buf;', patched)
        with self.assertRaises(ValueError):
            build.patch_jni_help(patched)

    def test_ndk_command_sets_abi_and_api_as_make_arguments(self):
        command = build.ndk_command(Path('/ndk/ndk-build'), 'armeabi-v7a')
        self.assertIn('APP_ABI=armeabi-v7a', command)
        self.assertIn('APP_PLATFORM=android-23', command)
        self.assertIn('V=1', command)
        with self.assertRaises(ValueError):
            build.ndk_command(Path('/ndk/ndk-build'), 'mips')

    def test_stale_amalgamation_is_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            jni = Path(tmp)
            build.reject_stale_amalgamation(jni)
            (jni / 'sqlite3.c').write_text('old')
            with self.assertRaises(ValueError):
                build.reject_stale_amalgamation(jni)
            (jni / 'sqlite3.c').unlink()
            (jni / 'sqlite3.h').write_text('old')
            with self.assertRaises(ValueError):
                build.reject_stale_amalgamation(jni)

    def test_ignored_autosetup_bootstrap_is_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            subprocess.run(['git', 'init', '-q', str(repo)], check=True)
            (repo / '.gitignore').write_text('jimsh0\n')
            subprocess.run(['git', '-C', str(repo), 'add', '.gitignore'], check=True)
            subprocess.run(['git', '-C', str(repo), '-c', 'user.name=Test',
                            '-c', 'user.email=test@example.invalid', 'commit',
                            '-qm', 'Record ignore rule'], check=True)
            build.require_clean_repository(repo)
            (repo / 'jimsh0').write_text('stale executable')
            with self.assertRaisesRegex(ValueError, 'dirty or generated source'):
                build.require_clean_repository(repo)

    def test_child_environment_clears_external_compiler_and_crypto_overrides(self):
        inherited = {
            'SQLCIPHER_CFLAGS': '-DSQLCIPHER_CRYPTO_OPENSSL',
            'CC': '/tmp/foreign-clang', 'CXX': '/tmp/foreign-clang++',
            'CFLAGS': '-fno-stack-protector', 'CPPFLAGS': '-DOTHER',
            'LDFLAGS': '-Wl,-z,norelro', 'MAKEFLAGS': '-j99',
            'MAKEFILES': '/tmp/foreign.mk',
            'NDK_PROJECT_PATH': '/tmp/foreign-project',
            'ANDROID_NDK_HOME': '/tmp/foreign-ndk',
            'LC_ALL': 'fr_CA.UTF-8',
        }
        child = build.child_environment(inherited)
        for key in inherited:
            if key != 'LC_ALL':
                self.assertNotIn(key, child)
        self.assertEqual(child['LC_ALL'], 'C')

    def test_revisions_and_all_four_abis_are_fixed(self):
        self.assertEqual(build.WRAPPER_REV,
                         '9a5d685404489cbff14d4c46da81555de1a38787')
        self.assertEqual(build.CORE_REV,
                         'c4b275a47932888216bade83aff2bbc73df0ff85')
        self.assertEqual(build.CRYPT_REV,
                         '476a9579ae94f32b9ea9e2747bfb04b302370259')
        self.assertEqual(build.ABIS,
                         ('armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'))

    def test_tool_byte_guard_rejects_changed_input(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / 'tool'
            path.write_bytes(b'known tool')
            build.require_digest(path, build.digest(path), 'fixture tool')
            path.write_bytes(b'changed tool')
            with self.assertRaisesRegex(ValueError, 'fixture tool byte mismatch'):
                build.require_digest(path, '0' * 64, 'fixture tool')


if __name__ == '__main__':
    unittest.main()
