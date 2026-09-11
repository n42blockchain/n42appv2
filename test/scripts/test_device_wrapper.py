import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]


class DeviceWrapperTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        flutter = self.root / 'flutter'
        flutter.write_text('#!/usr/bin/env python3\nimport json,sys\nprint(json.dumps(sys.argv[1:]))\n')
        flutter.chmod(0o700)
        self.env = dict(os.environ)
        self.env.pop('N42_DEVICE_DEFINES_FILE', None)
        self.env['PATH'] = str(self.root) + os.pathsep + self.env['PATH']

    def run_wrapper(self, *args):
        return subprocess.run(
            ['bash', str(ROOT / 'scripts/test_device.sh'), 'fixture-device', *args],
            cwd=ROOT, env=self.env, capture_output=True, text=True,
        )

    def test_default_preserves_application(self):
        result = self.run_wrapper()
        self.assertEqual(result.returncode, 0, result.stderr)
        args = json.loads(result.stdout)
        self.assertIn('--no-uninstall', args)
        self.assertNotIn('--uninstall', args)
        self.assertEqual(args[-1], 'integration_test/app_test.dart')

    def test_local_define_path_stays_one_argument_without_printing_token(self):
        defines = self.root / 'private defines.json'
        defines.write_text(json.dumps({'PROXY_AUTH_TOKEN': 'fixture-secret'}))
        self.env['N42_DEVICE_DEFINES_FILE'] = str(defines)
        result = self.run_wrapper()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('--dart-define-from-file=' + str(defines), json.loads(result.stdout))
        self.assertNotIn('fixture-secret', result.stdout + result.stderr)
        self.assertIn('--no-uninstall', json.loads(result.stdout))

    def test_missing_define_file_fails_before_launch(self):
        self.env['N42_DEVICE_DEFINES_FILE'] = str(self.root / 'missing.json')
        result = self.run_wrapper()
        self.assertEqual(result.returncode, 64)
        self.assertEqual(result.stdout, '')

    def test_extra_uninstall_flag_cannot_override_preservation(self):
        result = self.run_wrapper('integration_test/app_test.dart', '--uninstall')
        self.assertEqual(result.returncode, 64)
        self.assertEqual(result.stdout, '')


if __name__ == '__main__':
    unittest.main()
