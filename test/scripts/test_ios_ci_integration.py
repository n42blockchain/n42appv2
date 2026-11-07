import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
UUID = '11111111-2222-3333-4444-555555555555'


class IosCiIntegrationTest(unittest.TestCase):
    def run_helper(self, *, ci='true', uuid=UUID, actual=UUID, grant_error=False):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            log = root / 'calls'
            for name in ['xcrun', 'flutter']:
                tool = root / name
                tool.write_text('''#!/usr/bin/env python3
import os,sys,json
with open(os.environ['CALL_LOG'],'a') as out:
 out.write(json.dumps([os.path.basename(sys.argv[0])]+sys.argv[1:])+'\\n')
if sys.argv[1:3] == ['simctl','getenv']:
 print(os.environ['ACTUAL_UUID'])
if sys.argv[1:3] == ['simctl','privacy'] and os.environ['GRANT_ERROR']=='1':
 sys.exit(1)
''')
                tool.chmod(0o700)
            env = dict(os.environ, CI=ci, IOS_SIMULATOR_ID=uuid, ACTUAL_UUID=actual,
                       CALL_LOG=str(log), GRANT_ERROR=str(int(grant_error)))
            env['PATH'] = str(root) + os.pathsep + env['PATH']
            result = subprocess.run(['bash', str(ROOT / 'scripts/run_ios_ci_integration.sh')],
                                    env=env, capture_output=True, text=True)
            calls = [json.loads(line) for line in log.read_text().splitlines()] if log.exists() else []
            return result, calls

    def test_rejects_non_ci_before_any_device_access(self):
        result, calls = self.run_helper(ci='false')
        self.assertEqual(result.returncode, 64)
        self.assertEqual(calls, [])

    def test_requires_explicit_uuid_not_booted_alias(self):
        result, calls = self.run_helper(uuid='booted')
        self.assertEqual(result.returncode, 64)
        self.assertEqual(calls, [])

    def test_rejects_wrong_or_unbooted_simulator(self):
        result, calls = self.run_helper(actual='')
        self.assertEqual(result.returncode, 64)
        self.assertEqual(len(calls), 1)

    def test_grants_only_camera_before_running_full_suite(self):
        result, calls = self.run_helper()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[1], ['xcrun','simctl','privacy',UUID,'grant','camera','ai.n42.www'])
        self.assertEqual(calls[2][:3], ['flutter','test','integration_test/'])
        self.assertIn('--no-uninstall', calls[2])
        self.assertIn(UUID, calls[2])
        self.assertEqual(len(calls), 3)

    def test_failed_grant_stops_before_test_launch(self):
        result, calls = self.run_helper(grant_error=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(calls), 2)


if __name__ == '__main__':
    unittest.main()
