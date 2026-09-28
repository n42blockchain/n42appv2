import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[2] / 'scripts/walletcore_android_generate.py'
SPEC = importlib.util.spec_from_file_location('walletcore_android_generate', SCRIPT)
generate = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(generate)


class WalletCoreAndroidGenerateTest(unittest.TestCase):
    def test_cargo_inserts_locked_before_program_arguments(self):
        self.assertEqual(generate.locked_cargo_args(['run', '--', 'cpp']),
                         ['run', '--locked', '--', 'cpp'])
        self.assertEqual(generate.locked_cargo_args(['build', '--release', '--lib']),
                         ['build', '--locked', '--release', '--lib'])
        with self.assertRaisesRegex(ValueError, 'unsupported Cargo command'):
            generate.locked_cargo_args(['update'])

    def test_preflight_requires_process_success_despite_existing_receipt(self):
        with tempfile.TemporaryDirectory() as directory:
            receipt = Path(directory) / 'preflight.json'
            receipt.write_text(json.dumps({'passed': True}))
            with patch.object(generate.subprocess, 'run', return_value=
                              subprocess.CompletedProcess([], 1, '', 'changed input')):
                with self.assertRaisesRegex(ValueError, 'preflight process failed'):
                    generate.require_preflight(['python3', 'preflight.py'], receipt)


if __name__ == '__main__':
    unittest.main()
