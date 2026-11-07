import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[2] / 'scripts/prepare_android_emulator.py'
spec = importlib.util.spec_from_file_location('prepare_emulator', SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
ENV = {'CI': 'true', 'GITHUB_ACTIONS': 'true'}


class PrepareEmulatorTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.calls = []
        self.sleeps = []

    def runner(self, failures=0, corrupt_success=False):
        def run(args, **kwargs):
            self.calls.append(args)
            self.assertEqual(kwargs['timeout'], 300)
            self.assertNotIn('shell', kwargs)
            if len(self.calls) <= failures:
                temporary = self.root / '.temp/PackageOperation1'
                temporary.mkdir(parents=True, exist_ok=True)
                (temporary / 'partial.zip').write_bytes(b'corrupt')
                return subprocess.CompletedProcess(args, 0 if corrupt_success else 1,
                                                   'Error reading Zip content')
            package = args[3]
            marker = dict(module.PACKAGES)[package]
            path = self.root / marker
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(b'installed fixture')
            return subprocess.CompletedProcess(args, 0, '')
        return run

    def test_local_environment_is_rejected_before_commands(self):
        with self.assertRaises(RuntimeError):
            module.prepare(self.root, {}, run=self.runner())
        self.assertEqual(self.calls, [])

    def test_both_exact_packages_are_prepared(self):
        module.prepare(self.root, ENV, run=self.runner(), sleep=self.sleeps.append)
        self.assertEqual([call[3] for call in self.calls],
                         [package for package, _ in module.PACKAGES])
        self.assertEqual(self.sleeps, [])

    def test_retry_cleans_only_failed_extraction(self):
        keep = self.root / '.temp/keep'
        keep.mkdir(parents=True)
        module.prepare(self.root, ENV, run=self.runner(1), sleep=self.sleeps.append)
        self.assertFalse((self.root / '.temp/PackageOperation1').exists())
        self.assertTrue(keep.exists())
        self.assertEqual(len(self.calls), 3)
        self.assertEqual(self.sleeps, [2])

    def test_failure_stops_after_three_attempts(self):
        with self.assertRaises(RuntimeError):
            module.prepare(self.root, ENV, run=self.runner(3), sleep=self.sleeps.append)
        self.assertEqual(len(self.calls), 3)
        self.assertEqual(self.sleeps, [2, 2])

    def test_corrupt_zip_warning_is_not_success_even_with_exit_zero(self):
        module.prepare(self.root, ENV, run=self.runner(1, True), sleep=self.sleeps.append)
        self.assertEqual(len(self.calls), 3)

    def test_download_timeout_is_bounded(self):
        def timeout(args, **kwargs):
            self.calls.append(args)
            raise subprocess.TimeoutExpired(args, kwargs['timeout'])
        with self.assertRaises(RuntimeError):
            module.prepare(self.root, ENV, run=timeout, sleep=self.sleeps.append)
        self.assertEqual(len(self.calls), 3)
        self.assertEqual(self.sleeps, [2, 2])

    def test_redirected_temporary_directory_is_rejected(self):
        (self.root / '.temp').symlink_to(self.root, target_is_directory=True)
        with self.assertRaises(RuntimeError):
            module.prepare(self.root, ENV, run=self.runner())
        self.assertEqual(self.calls, [])


if __name__ == '__main__':
    unittest.main()
