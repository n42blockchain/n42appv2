"""Exercise the actual CI Chat exporter against an isolated Git checkout."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import textwrap
import unittest


class ChatExportWorkflowTests(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.addCleanup(self.folder.cleanup)
        self.root = Path(self.folder.name)
        self.source = self.root / 'chat checkout'
        self.source.mkdir()
        (self.source / 'sentinel.txt').write_text('pinned Chat content\n')
        for args in [
            ['init', '-q'], ['add', 'sentinel.txt'],
            ['-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid',
             'commit', '-qm', 'test: create Chat export fixture'],
        ]:
            subprocess.run(['git', '-C', str(self.source), *args], check=True,
                           capture_output=True)
        self.revision = subprocess.check_output(
            ['git', '-C', str(self.source), 'rev-parse', 'HEAD'], text=True).strip()
        config = self.root / '.dart_tool/package_config.json'
        config.parent.mkdir()
        config.write_text(json.dumps({'packages': [{
            'name': 'n42_chat', 'rootUri': self.source.as_uri() + '/',
        }]}))
        self.exports = self.root / 'exports'
        self.exports.mkdir()
        self.environment_file = self.root / 'github-env'
        workflow = (Path(__file__).resolve().parents[2] /
                    '.github/workflows/ci.yml').read_text()
        self.code = textwrap.dedent(workflow.split(
            "python3 - <<'PY_CHAT'\n", 1)[1].split('          PY_CHAT', 1)[0])

    def run_export(self, declared=None, resolved=None, source='git', last=False):
        (self.root / 'pubspec.yaml').write_text(
            'dependencies:\n  another_package:\n    git:\n'
            f"      ref: {'1' * 40}\n  n42_chat:\n    git:\n"
            f'      ref: {declared or self.revision}\n'
            f"  later_package:\n    git:\n      ref: {'9' * 40}\n")
        lock = ('packages:\n  n42_chat:\n    description:\n'
                f'      resolved-ref: {resolved or self.revision}\n'
                f'    source: {source}\n')
        if not last:
            lock += '  next_package:\n    source: hosted\n'
        (self.root / 'pubspec.lock').write_text(lock)
        return subprocess.run(
            [sys.executable, '-c', self.code], cwd=self.root,
            env={**os.environ, 'GITHUB_ENV': str(self.environment_file),
                 'RUNNER_TEMP': str(self.exports)}, capture_output=True, text=True)

    def test_export_uses_chat_ref_instead_of_other_git_dependencies(self):
        result = self.run_export()
        self.assertEqual(result.returncode, 0, result.stderr)
        target = Path(self.environment_file.read_text().strip().split('=', 1)[1])
        self.assertEqual((target / 'sentinel.txt').read_text(), 'pinned Chat content\n')
        self.assertFalse((target / '.git').exists())

    def test_last_lock_dependency_is_supported(self):
        result = self.run_export(last=True)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_mismatches_and_path_resolution_fail_before_export(self):
        for options in [
            {'declared': '2' * 40},
            {'declared': '3' * 40, 'resolved': '3' * 40},
            {'source': 'path'},
        ]:
            with self.subTest(options=options):
                result = self.run_export(**options)
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse(self.environment_file.exists())
                self.assertEqual(list(self.exports.iterdir()), [])


if __name__ == '__main__':
    unittest.main()
