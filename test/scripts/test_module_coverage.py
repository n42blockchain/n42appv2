"""Coverage accounting regressions (run with Python's unittest)."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[2] / 'scripts/module_coverage.py'
spec = importlib.util.spec_from_file_location('module_coverage', SCRIPT)
coverage = importlib.util.module_from_spec(spec)
spec.loader.exec_module(coverage)


class CoverageAccountingTest(unittest.TestCase):
    def trace(self, content):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'lcov.info'
            path.write_text(content)
            return coverage.read_lcov(path)

    def test_duplicate_records_merge_line_hits_without_inflating_denominator(self):
        files = self.trace('SF:lib/core/example.dart\nDA:1,0\nDA:2,2\nend_of_record\n'
                           'SF:lib/core/example.dart\nDA:1,3\nDA:2,0\nend_of_record\n')
        self.assertEqual(files, {'lib/core/example.dart': {'hit': 2, 'found': 2}})

    def test_empty_and_malformed_traces_fail_instead_of_reporting_success(self):
        for content in ['', 'DA:1,1', 'SF:lib/a.dart\nDA:1,-1']:
            with self.subTest(content=content), self.assertRaises(ValueError):
                self.trace(content)

    def test_generated_code_stays_in_overall_denominator(self):
        summary = coverage.summarize({
            'lib/core/a.dart': {'hit': 5, 'found': 10},
            'lib/generated/l10n.dart': {'hit': 0, 'found': 90},
        }, 'fixture')
        self.assertEqual(coverage.percent(summary['overall']), 5)
        self.assertEqual(summary['features']['generated']['found'], 90)

    def test_partial_report_warns_about_missing_files_and_omits_overall(self):
        path = 'lib/core/security/secure_storage.dart'
        baseline = coverage.summarize({path: {'hit': 1, 'found': 10}}, 'baseline')
        current = coverage.summarize({}, 'partial')
        report = coverage.render(current, baseline, scope='security')
        self.assertNotIn('| `overall`', report)
        self.assertIn('未出现在本次 LCOV', report)
        self.assertIn(path, report)


if __name__ == '__main__':
    unittest.main()
