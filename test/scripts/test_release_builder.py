import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]


class ReleaseBuilderTest(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory(prefix='release builder ')
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        (self.root / 'scripts').mkdir()
        (self.root / 'android').mkdir()
        self.pubspec = self.root / 'pubspec.yaml'
        self.pubspec.write_text('name: fixture\nversion: 2.4.8+123\n')
        (self.root / 'android/key.properties').write_text('fixture only')
        for name in ['build_release.sh', 'scripts/quality_gate.py', 'scripts/module_coverage.py',
                     'scripts/prepare_android_release.sh', 'scripts/prepare_ios_release.sh']:
            shutil.copy2(ROOT / name, self.root / name)
        (self.root / 'scripts/build_ipa.sh').write_text(
            '#!/bin/bash\nexec flutter ipa-helper "$@"\n')
        self.calls = self.root / 'calls.jsonl'
        flutter = self.root / 'flutter'
        flutter.write_text('#!/usr/bin/env python3\nimport json,os,sys\n'
                           'with open(os.environ["FIXTURE_CALLS"], "a") as f: f.write(json.dumps(sys.argv[1:])+"\\n")\n'
                           'sys.exit(int(os.environ.get("FIXTURE_EXIT", "0")))\n')
        flutter.chmod(0o700)
        self.env = dict(os.environ, PATH=str(self.root) + os.pathsep + os.environ['PATH'],
                        FIXTURE_CALLS=str(self.calls))

    def run_build(self, *args, script='build_release.sh'):
        return subprocess.run(['bash', str(self.root / script), *args], cwd='/',
                              env=self.env, text=True, capture_output=True)

    def commands(self):
        return [json.loads(line) for line in self.calls.read_text().splitlines()]

    def test_android_release_and_committed_version_are_preserved(self):
        before = self.pubspec.read_bytes()
        result = self.run_build('android')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.pubspec.read_bytes(), before)
        self.assertEqual(self.commands(), [['pub', 'get', '--enforce-lockfile'],
                                          ['build', 'appbundle', '--release'],
                                          ['build', 'apk', '--release']])

    def test_private_configuration_is_one_argument_and_not_printed(self):
        config = self.root / 'private defines.json'
        config.write_text('{"PROXY_AUTH_TOKEN":"fixture-secret"}')
        result = self.run_build('apk', '--dart-define-from-file', str(config))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('--dart-define-from-file=' + str(config), self.commands()[-1])
        self.assertNotIn('fixture-secret', result.stdout + result.stderr)

    def test_dotenv_is_never_executed_as_shell(self):
        sentinel = self.root / 'executed'
        (self.root / '.env').write_text(f'PROXY_AUTH_TOKEN=$(touch "{sentinel}")\n')
        result = self.run_build('apk')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(sentinel.exists())
        self.assertIn('--dart-define-from-file=' + str(self.root / '.env'), self.commands()[-1])

    def test_missing_config_unknown_target_and_options_fail_before_build(self):
        for args in [('bad-target',), ('apk', '--bad-option'), ('apk', '--dart-define-from-file', '/missing')]:
            with self.subTest(args=args):
                self.assertNotEqual(self.run_build(*args).returncode, 0)
                self.assertFalse(self.calls.exists())
                self.assertIn('2.4.8+123', self.pubspec.read_text())

    def test_missing_android_signing_fails_before_build(self):
        (self.root / 'android/key.properties').unlink()
        self.assertNotEqual(self.run_build('apk').returncode, 0)
        self.assertFalse(self.calls.exists())

    def test_failed_dependency_resolution_stops_the_release(self):
        self.env['FIXTURE_EXIT'] = '23'
        self.assertEqual(self.run_build('all').returncode, 23)
        self.assertEqual(len(self.commands()), 1)

    def test_ios_wrapper_does_not_modify_entitlements_and_disables_bump(self):
        entitlements = self.root / 'ios/Runner/Runner.entitlements'
        entitlements.parent.mkdir(parents=True)
        entitlements.write_text('fixture-development-entitlements')
        result = self.run_build(script='scripts/prepare_ios_release.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(entitlements.read_text(), 'fixture-development-entitlements')
        self.assertEqual(self.commands()[-1], ['ipa-helper', '--no-bump'])

    def test_real_ipa_helper_passes_release_export_and_preserves_version(self):
        shutil.copy2(ROOT / 'scripts/build_ipa.sh', self.root / 'scripts/build_ipa.sh')
        xcrun = self.root / 'xcrun'
        xcrun.write_text('#!/bin/bash\necho 26.6\n')
        xcrun.chmod(0o700)
        self.env['FIXTURE_EXIT'] = '23'
        result = self.run_build('--no-bump', script='scripts/build_ipa.sh')
        self.assertEqual(result.returncode, 23, result.stderr)
        command = self.commands()[0]
        self.assertEqual(command[:2], ['build', 'ipa'])
        self.assertIn('--release', command)
        self.assertIn('--export-options-plist=ios/ExportOptions-AppStore.plist', command)
        self.assertIn('--build-number=123', command)
        self.assertIn('2.4.8+123', self.pubspec.read_text())

    def test_outdated_ios_sdk_fails_before_version_bump(self):
        shutil.copy2(ROOT / 'scripts/build_ipa.sh', self.root / 'scripts/build_ipa.sh')
        xcrun = self.root / 'xcrun'
        xcrun.write_text('#!/bin/bash\necho 18.0\n')
        xcrun.chmod(0o700)
        result = self.run_build(script='scripts/build_ipa.sh')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.calls.exists())
        self.assertIn('2.4.8+123', self.pubspec.read_text())


if __name__ == '__main__':
    unittest.main()
