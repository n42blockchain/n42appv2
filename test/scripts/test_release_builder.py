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
        (self.root / 'assets').mkdir()
        (self.root / 'pubspec.lock').write_text('packages: {}\n')
        shutil.copy2(ROOT / 'assets/wallet_capabilities.json',
                     self.root / 'assets/wallet_capabilities.json')
        self.pubspec = self.root / 'pubspec.yaml'
        self.pubspec.write_text('name: fixture\nversion: 2.4.8+123\n')
        (self.root / 'android/key.properties').write_text('fixture only')
        for name in ['build_release.sh', 'scripts/quality_gate.py', 'scripts/module_coverage.py',
                     'scripts/prepare_android_release.sh', 'scripts/prepare_ios_release.sh',
                     'scripts/release/wallet_capability_manifest.py']:
            (self.root / name).parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / name, self.root / name)
        (self.root / 'scripts/build_ipa.sh').write_text(
            '#!/bin/bash\nexec flutter ipa-helper "$@"\n')
        self.calls = self.root / 'calls.jsonl'
        flutter = self.root / 'flutter'
        flutter.write_text(r'''#!/usr/bin/env python3
import json, os, sys, zipfile
from pathlib import Path
with open(os.environ["FIXTURE_CALLS"], "a") as f:
    f.write(json.dumps(sys.argv[1:]) + "\n")
code = int(os.environ.get("FIXTURE_EXIT", "0"))
if code:
    sys.exit(code)
if sys.argv[1:3] in [["build", "apk"], ["build", "appbundle"]]:
    artifact = ("build/app/outputs/flutter-apk/app-release.apk"
                if sys.argv[2] == "apk" else
                "build/app/outputs/bundle/release/app-release.aab")
    Path(artifact).parent.mkdir(parents=True, exist_ok=True)
    asset = Path("assets/wallet_capabilities.json").read_bytes()
    if os.environ.get("FIXTURE_BAD_ASSET"):
        asset = b"{}"
    with zipfile.ZipFile(artifact, "w") as archive:
        archive.writestr("assets/flutter_assets/assets/wallet_capabilities.json", asset)
''')
        flutter.chmod(0o700)
        self.env = dict(os.environ, PATH=str(self.root) + os.pathsep + os.environ['PATH'],
                        FIXTURE_CALLS=str(self.calls))

        # Exercise the real source/artifact manifest, including its Git binding.
        for args in [
            ['init', '-q'], ['add', '.'],
            ['-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid',
             '-c', 'core.hooksPath=/dev/null', '-c', 'commit.gpgsign=false', 'commit', '-qm', 'test: initial fixture'],
        ]:
            subprocess.run(['git', *args], cwd=self.root, check=True,
                           capture_output=True)

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

    def test_release_records_actual_packaged_capabilities(self):
        result = self.run_build('android')
        self.assertEqual(result.returncode, 0, result.stderr)
        for kind in ['apk', 'aab']:
            evidence = json.loads((self.root / 'build/release-evidence' /
                                   f'wallet-{kind}.json').read_text())
            self.assertTrue(evidence['artifactVerified'])
            self.assertTrue(evidence['buildSourceStable'])
            self.assertEqual(evidence['sourceVersion'], '2.4.8+123')

    def test_mismatched_packaged_capabilities_fail_release(self):
        self.env['FIXTURE_BAD_ASSET'] = '1'
        result = self.run_build('apk')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Artifact capability asset does not match', result.stderr)
        self.assertFalse((self.root / 'build/release-evidence/wallet-apk.json').exists())

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
        xcrun.write_text('#!/bin/bash\necho 27.1\n')
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
        for sdk in ['18.0', '26.6', '27.0']:
            with self.subTest(sdk=sdk):
                xcrun.write_text(f'#!/bin/bash\necho {sdk}\n')
                xcrun.chmod(0o700)
                result = self.run_build(script='scripts/build_ipa.sh')
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse(self.calls.exists())
                self.assertIn('2.4.8+123', self.pubspec.read_text())



if __name__ == '__main__':
    unittest.main()
