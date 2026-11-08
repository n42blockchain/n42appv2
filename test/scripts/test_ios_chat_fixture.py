import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
spec = importlib.util.spec_from_file_location('ios_chat_fixture', ROOT / 'scripts/prepare_ios_chat_fixture.py')
fixture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(fixture)


class IosChatFixtureTest(unittest.TestCase):
    def test_requires_owned_numbered_ci_run(self):
        with self.assertRaises(ValueError):
            fixture.fixture_root({'RUNNER_TEMP': '/tmp'})

    def test_occupied_port_never_starts_or_seeds(self):
        env = dict(CI='true', GITHUB_RUN_ID='12', GITHUB_RUN_ATTEMPT='1', RUNNER_TEMP='/tmp')
        with patch.object(fixture.socket, 'socket') as socket, patch.object(fixture, '_start') as start:
            socket.return_value.__enter__.return_value.bind.side_effect = OSError('occupied')
            with self.assertRaises(OSError):
                fixture.start(Path('/tmp/unused'), env)
            start.assert_not_called()

    def test_duplicate_start_never_stops_existing_server(self):
        with tempfile.TemporaryDirectory() as directory:
            env = dict(CI='true', GITHUB_RUN_ID='12', GITHUB_RUN_ATTEMPT='1', RUNNER_TEMP=directory)
            fixture.fixture_root(env).mkdir()
            with patch.object(fixture.socket, 'socket'), patch.object(fixture, 'stop') as stop:
                with self.assertRaises(FileExistsError):
                    fixture.start(Path(directory) / 'defines', env)
                stop.assert_not_called()

    def test_cleanup_refuses_reused_pid(self):
        with tempfile.TemporaryDirectory() as directory:
            env = dict(CI='true', GITHUB_RUN_ID='12', GITHUB_RUN_ATTEMPT='1', RUNNER_TEMP=directory)
            root = fixture.fixture_root(env)
            root.mkdir()
            (root / 'process.json').write_text('{"pid":123}')
            with patch.object(fixture.subprocess, 'run', return_value=subprocess.CompletedProcess([], 0, 'unrelated process')), patch.object(fixture.os, 'kill') as kill:
                with self.assertRaises(ValueError):
                    fixture.stop(env)
                kill.assert_not_called()


if __name__ == '__main__':
    unittest.main()
