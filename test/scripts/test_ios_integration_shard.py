import importlib.util
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('ios_shard', ROOT / 'scripts/select_ios_integration_shard.py')
shard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(shard)


class IosIntegrationShardTest(unittest.TestCase):
    def test_complete_source_suite_is_partitioned_once_without_omissions(self):
        partitions = [shard.select(ROOT, i, 3) for i in range(3)]
        expected = sorted(p.relative_to(ROOT).as_posix() for p in (ROOT / 'integration_test').rglob('*_test.dart'))
        flat = [target for _, targets in partitions for target in targets]
        self.assertEqual(sorted(flat), expected)
        self.assertEqual(len(flat), len(set(flat)))
        self.assertTrue(all(targets for _, targets in partitions))
        self.assertIn('integration_test/flows/wallet_flow_test.dart', flat)
        for all_targets, _ in partitions:
            self.assertEqual(all_targets, expected)

    def test_single_shard_retains_the_complete_suite(self):
        all_targets, targets = shard.select(ROOT, 0, 1)
        self.assertEqual(targets, all_targets)

    def test_invalid_or_empty_shards_fail_closed(self):
        for index, count in [(-1, 3), (3, 3), (0, 0), (0, 9)]:
            with self.subTest(index=index, count=count), self.assertRaises(ValueError):
                shard.select(ROOT, index, count)
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(ValueError):
                shard.select(Path(directory), 0, 3)


if __name__ == '__main__':
    unittest.main()
