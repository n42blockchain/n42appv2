import importlib.util
from pathlib import Path
import subprocess
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('native_chat_fixture', ROOT / 'scripts/prepare_native_chat_fixture.py')
fixture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(fixture)


class NativeChatFixtureTest(unittest.TestCase):
    def test_refuses_non_ci_or_unscoped_container_names(self):
        for env in [{}, {'CI': 'false', 'GITHUB_RUN_ID': '12', 'GITHUB_RUN_ATTEMPT': '1'},
                    {'CI': 'true', 'GITHUB_RUN_ID': '../owned', 'GITHUB_RUN_ATTEMPT': '1'}]:
            with self.subTest(env=env), self.assertRaises(ValueError):
                fixture.container_name(env)

    def test_registration_reuses_uia_session_without_echoing_credentials(self):
        calls = []
        def send(path, body):
            import copy
            calls.append(copy.deepcopy(body))
            return (401, {'session': 'fixture-session'}) if len(calls) == 1 else (200, {'user_id': '@test:fixture', 'access_token': 'test-token'})
        with patch.object(fixture, 'request', side_effect=send):
            self.assertEqual(fixture.register('test', 'password', 'invite')['user_id'], '@test:fixture')
        self.assertNotIn('session', calls[0]['auth'])
        self.assertEqual(calls[1]['auth']['session'], 'fixture-session')

    def test_registration_failure_does_not_include_server_payload(self):
        with patch.object(fixture, 'request', return_value=(403, {'error': 'sensitive-payload'})):
            with self.assertRaisesRegex(RuntimeError, '^Disposable Matrix registration failed$'):
                fixture.register('test', 'password', 'invite')

    def test_cleanup_refuses_container_without_ownership_label(self):
        env = {'CI': 'true', 'GITHUB_RUN_ID': '12', 'GITHUB_RUN_ATTEMPT': '1'}
        with patch.object(fixture.subprocess, 'run', return_value=subprocess.CompletedProcess([], 0, 'other-owner\n')) as run:
            with self.assertRaises(ValueError):
                fixture.stop(env)
        self.assertEqual(run.call_count, 1)

    def test_cleanup_removes_only_exact_owned_run(self):
        env = {'CI': 'true', 'GITHUB_RUN_ID': '12', 'GITHUB_RUN_ATTEMPT': '1'}
        with patch.object(fixture.subprocess, 'run', return_value=subprocess.CompletedProcess([], 0, 'wallet-native-chat\n')) as run:
            fixture.stop(env)
        self.assertEqual(run.call_args.args[0], ['docker', 'rm', '--force', '--volumes', 'n42-wallet-native-chat-12-1'])


if __name__ == '__main__':
    unittest.main()
