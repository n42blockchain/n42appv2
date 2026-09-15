import json
from pathlib import Path
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
import quality_gate


class QualityGateTest(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.path = Path(directory.name) / 'evidence'

    def coverage(self, content, threshold=70):
        self.path.write_text(content)
        return quality_gate.coverage_result(self.path, threshold)

    def report(self, events):
        self.path.write_text('\n'.join(json.dumps(e) for e in events))
        return quality_gate.test_result(self.path)

    def test_coverage_below_threshold_fails_without_rounding_up(self):
        lines = ''.join(f'DA:{n},{int(n <= 699)}\n' for n in range(1, 1001))
        self.assertFalse(self.coverage(f'SF:lib/app.dart\n{lines}end_of_record\n')['passed'])

    def test_duplicate_records_merge_unique_source_lines(self):
        result = self.coverage('SF:lib/app.dart\nDA:1,0\nDA:2,1\nend_of_record\n'
                               'SF:lib/app.dart\nDA:1,1\nend_of_record\n')
        self.assertEqual((result['hit'], result['found']), (2, 2))
        self.assertTrue(result['passed'])

    def test_empty_invalid_and_zero_line_coverage_fail(self):
        for content in ['', 'SF:lib/app.dart\nend_of_record', 'DA:1,1',
                        'SF:lib/app.dart\nDA:0,1', 'SF:lib/app.dart\nDA:1,-1']:
            with self.subTest(content=content), self.assertRaises(ValueError):
                self.coverage(content)

    def test_invalid_thresholds_fail(self):
        for threshold in [0, -1, 101, float('nan')]:
            with self.subTest(threshold=threshold), self.assertRaises(ValueError):
                self.coverage('SF:lib/app.dart\nDA:1,1\nend_of_record', threshold)

    def test_machine_report_counts_visible_results_and_skips(self):
        result = self.report([
            [{'event': 'test.startedProcess', 'params': {'vmServiceUri': 'http://127.0.0.1:1234'}}],
            {'type': 'testDone', 'testID': 0, 'result': 'success', 'hidden': True},
            {'type': 'testDone', 'testID': 1, 'result': 'success'},
            {'type': 'testDone', 'testID': 2, 'result': 'success', 'skipped': True},
            {'type': 'done', 'success': True},
        ])
        self.assertEqual((result['tests_passed'], result['skipped']), (1, 1))
        self.assertTrue(result['passed'])

    def test_blank_report_lines_are_allowed_but_malformed_events_are_not(self):
        self.path.write_text('\n{"type":"testDone","testID":1,"result":"success"}\n'
                             '\n{"type":"done","success":true}\n')
        self.assertTrue(quality_gate.test_result(self.path)['passed'])
        self.path.write_text('[1,2,3]\n')
        with self.assertRaises(ValueError):
            quality_gate.test_result(self.path)

    def test_failed_interrupted_empty_and_hidden_errors_cannot_pass(self):
        for events in [[], [{'type': 'done', 'success': True}],
                       [{'type': 'testDone', 'testID': 1, 'result': 'success'}],
                       [{'type': 'testDone', 'testID': 1, 'result': 'failure'}, {'type': 'done', 'success': True}],
                       [{'type': 'testDone', 'testID': 1, 'result': 'success'}, {'type': 'error'}, {'type': 'done', 'success': True}]]:
            with self.subTest(events=events):
                self.assertFalse(self.report(events)['passed'])

    def test_release_tag_must_match_name_and_build(self):
        self.path.write_text('version: 2.4.8+2026072654\n')
        self.assertTrue(quality_gate.version_result(self.path, 'v2.4.8+2026072654')['passed'])
        for tag in ['v2.4.8', 'v2.4.8+2026072653', 'v2.4.8-chat-audit']:
            with self.subTest(tag=tag), self.assertRaises(ValueError):
                quality_gate.version_result(self.path, tag)

    def test_invalid_android_build_numbers_fail(self):
        for version in ['2.4.8', '2.4.8+0', '2.4.8+-1', '2.4.8+2100000001']:
            self.path.write_text(f'version: {version}\n')
            with self.subTest(version=version), self.assertRaises(ValueError):
                quality_gate.version_result(self.path)


if __name__ == '__main__':
    unittest.main()
