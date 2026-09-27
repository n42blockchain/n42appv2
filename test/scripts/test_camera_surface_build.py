from pathlib import Path
import os
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'android/native/camera_core_surface/upstream'
SCRIPT = ROOT / 'scripts/build_camera_surface_android.sh'


def preflight(source=SOURCE, env=None):
    return subprocess.run(
        ['bash', str(SCRIPT), '--preflight', '--source-dir', str(source)],
        cwd=ROOT,
        env=env,
        text=True,
        capture_output=True,
        check=False,
    )


class CameraSurfaceBuildTest(unittest.TestCase):
    def test_exact_source_and_pinned_tools_pass_preflight(self):
        result = preflight()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('Pinned Camera surface source and tools verified', result.stdout)

    def test_changed_cpp_source_is_rejected_before_build(self):
        with tempfile.TemporaryDirectory() as folder:
            copied = Path(folder) / 'upstream'
            shutil.copytree(SOURCE, copied)
            cpp = copied / 'surface_util_jni.cc'
            cpp.write_bytes(cpp.read_bytes() + b'\n')
            result = preflight(copied)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('source hash mismatch', result.stderr)

    def test_extra_source_file_is_rejected_before_build(self):
        with tempfile.TemporaryDirectory() as folder:
            copied = Path(folder) / 'upstream'
            shutil.copytree(SOURCE, copied)
            (copied / 'unexpected.cc').write_text('int unexpected;\n')
            result = preflight(copied)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('source file set mismatch', result.stderr)

    def test_wrong_sdk_is_rejected_before_build(self):
        with tempfile.TemporaryDirectory() as folder:
            env = os.environ.copy()
            env['CAMERA_ANDROID_SDK_ROOT'] = folder
            result = preflight(env=env)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('SDK', result.stderr)

    def test_inherited_header_and_library_paths_are_cleared_for_build_child(self):
        # Run the recipe's actual unset directives without invoking CMake.
        directives = [
            line for line in SCRIPT.read_text().splitlines()
            if line.startswith('unset ')
        ]
        env = os.environ.copy()
        keys = ('CPATH', 'CPLUS_INCLUDE_PATH', 'C_INCLUDE_PATH', 'LIBRARY_PATH')
        for key in keys:
            env[key] = '/foreign/inputs'
        result = subprocess.run(
            ['bash', '-c', '\n'.join(directives) + '\nenv'],
            cwd=ROOT,
            env=env,
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        for key in keys:
            self.assertNotIn(f'{key}=', result.stdout)


if __name__ == '__main__':
    unittest.main()
