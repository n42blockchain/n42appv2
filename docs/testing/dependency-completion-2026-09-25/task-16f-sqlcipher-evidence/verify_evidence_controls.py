#!/usr/bin/env python3
"""Show the SQLCipher archive verifier rejects altered manifest and source maps."""

import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


ROOT = Path(__file__).resolve().parent
SOURCE = 'tools/android_native_smoke/harness/integration_test/sqlcipher_migration_test.dart'


def replace_json(path, update):
    record = json.loads(path.read_text())
    update(record)
    path.unlink()  # copytree hardlinks unchanged archive members for efficiency
    path.write_text(json.dumps(record, indent=2, sort_keys=True) + '\n')


def check(name, update, expected):
    with tempfile.TemporaryDirectory(prefix='sqlcipher-archive-control-') as folder:
        stage = Path(folder) / 'evidence'
        shutil.copytree(ROOT, stage, copy_function=os.link)
        update(stage)
        command = [sys.executable]
        if sys.flags.optimize:
            command.append('-O')
        command.append(str(stage / 'verify_evidence.py'))
        run = subprocess.run(command, capture_output=True, text=True, check=False)
        if run.returncode == 0 or expected not in run.stderr:
            raise RuntimeError(f'{name}: unexpected exit={run.returncode}, stderr={run.stderr}')
        print(f'{name}: rejected: {run.stderr.strip()}')


def wrong_manifest(stage):
    replace_json(stage / 'manifest.json',
                 lambda record: record['members'][0].__setitem__('sha256', '0' * 64))


def same_wrong_source_hash(stage):
    manifest_path = stage / 'manifest.json'
    manifest = json.loads(manifest_path.read_text())
    for phase in ('seed', 'official', 'candidate'):
        path = stage / 'runs' / phase / 'receipt.json'
        replace_json(path, lambda record: record['source_sha256'].__setitem__(
            SOURCE, '0' * 64))
        member = next(item for item in manifest['members'] if
                      item['path'] == f'runs/{phase}/receipt.json')
        member['size'] = path.stat().st_size
        member['sha256'] = hashlib.sha256(path.read_bytes()).hexdigest()
    manifest_path.unlink()
    manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + '\n')


def main():
    check('wrong_manifest', wrong_manifest, 'archive member hash mismatch')
    check('same_wrong_source_hash', same_wrong_source_hash,
          'historical source differs')
    print('2/2 archive negative controls rejected')


if __name__ == '__main__':
    main()
