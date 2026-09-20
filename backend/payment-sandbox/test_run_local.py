import http.client
import json
from pathlib import Path
import queue
import re
import signal
import subprocess
import sys
import tempfile
import threading
import unittest
from unittest.mock import patch
from urllib.parse import urlencode

from run_local import ASSET, local_fixture


class LauncherTests(unittest.TestCase):
    def test_factory_seeds_isolated_accounts_and_cleans_database(self):
        with local_fixture(0) as server:
            path = Path(server.sandbox.path)
            self.assertTrue(path.exists())
            self.assertEqual(server.server_address[0], '127.0.0.1')
            for actor in ('a', 'b'):
                self.assertEqual(server.sandbox.account(actor).balance(ASSET)['available'], 100_000_000)
            self.assertEqual(server.sandbox.audit_test_asset(ASSET)['issued'], 200_000_000)
        self.assertFalse(path.parent.exists())

    def test_factory_cleans_database_on_failure(self):
        with self.assertRaises(RuntimeError):
            with local_fixture(0) as server:
                path = Path(server.sandbox.path)
                raise RuntimeError('fixture test')
        self.assertFalse(path.parent.exists())

    def test_subprocess_start_and_ctrl_c(self):
        with tempfile.TemporaryDirectory() as temporary_root:
            import os
            environment = dict(os.environ, TMPDIR=temporary_root, TMP=temporary_root, TEMP=temporary_root)
            process = subprocess.Popen(
                [sys.executable, '-u', str(Path(__file__).with_name('run_local.py')), '--port', '0'],
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, env=environment)
            try:
                lines = queue.Queue()
                def read_lines():
                    for line in process.stdout:
                        lines.put(line)
                reader = threading.Thread(target=read_lines, daemon=True)
                reader.start()
                self.assertIn('LOCAL SIMULATION', lines.get(timeout=5))
                endpoint = lines.get(timeout=5)
                match = re.fullmatch(r'Endpoint: http://127\.0\.0\.1:(\d+)\n', endpoint)
                self.assertIsNotNone(match)
                connection = http.client.HTTPConnection('127.0.0.1', int(match[1]), timeout=5)
                try:
                    connection.request('GET', '/balances?' + urlencode({'asset': ASSET}),
                                       headers={'Authorization': 'Bearer synthetic-test-accounta'})
                    response = connection.getresponse()
                    result = json.loads(response.read())
                    self.assertEqual(response.status, 200)
                    self.assertEqual(result['available'], '100000000')
                    self.assertEqual(result['mode'], 'localSimulation')
                finally:
                    connection.close()
                self.assertTrue(list(Path(temporary_root).glob('n42-local-payment-*')))
                process.send_signal(signal.SIGINT)
                self.assertEqual(process.wait(timeout=5), 0)
                reader.join(timeout=2)
                self.assertEqual(list(Path(temporary_root).glob('n42-local-payment-*')), [])
                self.assertEqual(process.stderr.read(), '')
            finally:
                if process.poll() is None:
                    process.kill()
                    process.wait(timeout=5)
                process.stdout.close()
                process.stderr.close()

    def test_cli_rejects_production_or_remote_options(self):
        from run_local import main
        for args in [['--production'], ['--host', '0.0.0.0'], ['--port', '-1'], ['--port', '65536']]:
            with self.subTest(args=args), patch('sys.stderr'), self.assertRaises(SystemExit) as raised:
                main(args)
            self.assertEqual(raised.exception.code, 2)
