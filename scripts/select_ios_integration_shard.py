#!/usr/bin/env python3
"""Partition every integration test exactly once across disposable iOS jobs."""
import argparse
import hashlib
import json
from pathlib import Path


def select(root, index, count):
    if count < 1 or count > 8 or index < 0 or index >= count:
        raise ValueError('Invalid iOS shard index/count')
    targets = sorted(path.relative_to(root).as_posix()
                     for path in (root / 'integration_test').rglob('*_test.dart')
                     if path.is_file())
    if not targets or count > len(targets):
        raise ValueError('No tests or empty iOS shards')
    return targets, targets[index::count]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--index', type=int, required=True)
    parser.add_argument('--count', type=int, required=True)
    parser.add_argument('--manifest', type=Path, required=True)
    args = parser.parse_args()
    root = Path.cwd()
    all_targets, targets = select(root, args.index, args.count)
    args.manifest.write_text(json.dumps({
        'index': args.index, 'count': args.count,
        'allTargets': all_targets, 'targets': targets,
        'sha256': {name: hashlib.sha256((root / name).read_bytes()).hexdigest()
                   for name in targets},
    }, indent=2) + '\n')
    print('\n'.join(targets))


if __name__ == '__main__':
    main()
