#!/usr/bin/env python3
"""Fail closed on missing or failed release evidence; never change thresholds."""

import argparse
import json
from pathlib import Path
import re
import sys

from module_coverage import read_lcov


def coverage_result(path, threshold):
    if not 0 < threshold <= 100:
        raise ValueError('Coverage threshold must be greater than 0 and at most 100')
    records = read_lcov(path)
    found = sum(row['found'] for row in records.values())
    hit = sum(row['hit'] for row in records.values())
    if found == 0:
        raise ValueError('Coverage contains no executable lines')
    return {'hit': hit, 'found': found, 'percent': hit * 100 / found,
            'threshold': threshold, 'passed': hit * 100 >= found * threshold}


def test_result(path):
    done = {}
    success = None
    errors = 0
    for line in Path(path).read_text().splitlines():
        if not line.strip():
            continue
        event = json.loads(line)
        # Flutter also emits daemon protocol envelopes (VM service startup),
        # interleaved with package:test's machine reporter events.
        if isinstance(event, list) and all(
            isinstance(item, dict) and isinstance(item.get('event'), str)
            for item in event
        ):
            continue
        if not isinstance(event, dict):
            raise ValueError('Invalid test reporter event')
        if event.get('type') == 'testDone' and not event.get('hidden', False):
            done[event['testID']] = event
        elif event.get('type') == 'done':
            success = event.get('success') is True
        elif event.get('type') == 'error':
            errors += 1
    skipped = sum(e.get('skipped', False) for e in done.values())
    failed = sum(e.get('result') != 'success' and not e.get('skipped', False)
                 for e in done.values())
    passed = len(done) - skipped - failed
    return {'tests_passed': passed, 'tests_failed': failed, 'skipped': skipped,
            'errors': errors, 'passed': success is True and passed > 0 and failed == 0 and errors == 0}


def version_result(path, tag=None):
    match = re.search(r'^version:\s*(\d+\.\d+\.\d+)\+([1-9]\d*)\s*$',
                      Path(path).read_text(), re.M)
    if not match or int(match[2]) > 2100000000:
        raise ValueError('pubspec requires X.Y.Z+BUILD with Android-compatible positive build number')
    version = f'{match[1]}+{match[2]}'
    if tag is not None and tag != f'v{version}':
        raise ValueError(f'Release tag must exactly match v{version}')
    return {'version': version, 'passed': True}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    coverage = commands.add_parser('coverage')
    coverage.add_argument('path', type=Path)
    coverage.add_argument('--threshold', type=float, default=70)
    tests = commands.add_parser('tests')
    tests.add_argument('path', type=Path)
    version = commands.add_parser('version')
    version.add_argument('path', type=Path)
    version.add_argument('--tag')
    args = parser.parse_args()
    try:
        if args.command == 'coverage':
            result = coverage_result(args.path, args.threshold)
        elif args.command == 'tests':
            result = test_result(args.path)
        else:
            result = version_result(args.path, args.tag)
        print(json.dumps(result, sort_keys=True))
        return 0 if result['passed'] else 1
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(f'Quality gate failed: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
