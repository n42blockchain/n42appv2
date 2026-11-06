import importlib.util
import json
import os
from pathlib import Path
import plistlib
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    'ci_firebase', Path(__file__).resolve().parents[2] / 'scripts/prepare_ci_firebase.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class CiFirebaseTests(unittest.TestCase):
    def test_hosted_fixture_has_matching_app_ids_and_no_oauth(self):
        with tempfile.TemporaryDirectory() as folder, patch.dict(os.environ, {
            'GITHUB_ACTIONS': 'true', 'RUNNER_ENVIRONMENT': 'github-hosted',
        }):
            root = Path(folder)
            module.prepare(root)
            ios = plistlib.loads((root / 'ios/Runner/GoogleService-Info.plist').read_bytes())
            android = json.loads((root / 'android/app/google-services.json').read_text())
            self.assertEqual(ios['BUNDLE_ID'], 'ai.n42.www')
            self.assertEqual(ios['PROJECT_ID'], 'n42-ci-not-a-service')
            self.assertFalse(ios['IS_ANALYTICS_ENABLED'])
            self.assertFalse(ios['IS_SIGNIN_ENABLED'])
            self.assertNotIn('CLIENT_ID', ios)
            client = android['client'][0]
            self.assertEqual(client['client_info']['android_client_info']['package_name'], ios['BUNDLE_ID'])
            self.assertEqual(client['oauth_client'], [])
            before = (root / 'ios/Runner/GoogleService-Info.plist').read_bytes()
            with self.assertRaises(FileExistsError):
                module.prepare(root)
            self.assertEqual((root / 'ios/Runner/GoogleService-Info.plist').read_bytes(), before)

    def test_local_and_self_hosted_runs_cannot_create_resources(self):
        for env in [{}, {'GITHUB_ACTIONS': 'true', 'RUNNER_ENVIRONMENT': 'self-hosted'}]:
            with self.subTest(env=env), tempfile.TemporaryDirectory() as folder, patch.dict(os.environ, env, clear=True):
                with self.assertRaises(RuntimeError):
                    module.prepare(Path(folder))
                self.assertEqual(list(Path(folder).iterdir()), [])

    def test_existing_android_configuration_preserved_without_partial_ios_write(self):
        with tempfile.TemporaryDirectory() as folder, patch.dict(os.environ, {
            'GITHUB_ACTIONS': 'true', 'RUNNER_ENVIRONMENT': 'github-hosted',
        }):
            root = Path(folder)
            android = root / 'android/app/google-services.json'
            android.parent.mkdir(parents=True)
            android.write_text('preserve-existing')
            with self.assertRaises(FileExistsError):
                module.prepare(root)
            self.assertEqual(android.read_text(), 'preserve-existing')
            self.assertFalse((root / 'ios').exists())
