#!/usr/bin/env python3
"""Verify SQLCipher exports in the exact library selected by Dart's IPA manifest."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import subprocess
import tempfile
import zipfile

ASSET = 'package:sqlite3/src/ffi/libsqlite3.g.dart'
REQUIRED = ('_sqlite3_open_v2', '_sqlite3_key', '_sqlite3_rekey')


def read_symbols(binary):
    result = subprocess.run(['/usr/bin/nm', '-gU', str(binary)],
                            capture_output=True, text=True, check=True)
    return {line.split()[-1] for line in result.stdout.splitlines() if line.split()}


def inspect_ipa(ipa):
    report = {'passed': False, 'checks': [], 'failures': []}

    def check(name, valid):
        report['checks'].append({'name': name, 'passed': bool(valid)})
        if not valid:
            raise ValueError(name)

    try:
        with ipa.open('rb') as stream:
            report['sha256'] = hashlib.file_digest(stream, 'sha256').hexdigest()
        with zipfile.ZipFile(ipa) as archive:
            manifests = [name for name in archive.namelist() if name.startswith('Payload/')
                         and name.endswith('/Frameworks/App.framework/flutter_assets/NativeAssetsManifest.json')]
            check('one_dart_native_manifest', len(manifests) == 1)
            manifest = json.loads(archive.read(manifests[0]))
            check('supported_manifest_version', manifest.get('format-version') == [1, 0, 0])
            binding = manifest.get('native-assets', {}).get('ios_arm64', {}).get(ASSET)
            check('ios_sqlite_binding', isinstance(binding, list) and len(binding) == 2)
            check('bundled_sqlite_library', binding[0] == 'absolute' and isinstance(binding[1], str))
            relative = binding[1].removeprefix('@rpath/')
            path = PurePosixPath(relative)
            check('safe_library_path', bool(relative) and not path.is_absolute() and '..' not in path.parts)
            app_root = manifests[0].split('/Frameworks/', 1)[0]
            member = app_root + '/Frameworks/' + relative
            check('bound_library_packaged', archive.namelist().count(member) == 1)
            with tempfile.TemporaryDirectory(prefix='n42-chat-crypto-') as temporary:
                binary = Path(temporary) / 'sqlite-library'
                binary.write_bytes(archive.read(member))
                symbols = read_symbols(binary)
            report['library'] = relative
            for symbol in REQUIRED:
                check('export:' + symbol, symbol in symbols)
        report['passed'] = True
    except Exception as error:
        report['failures'].append(str(error))
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ipa', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    report = inspect_ipa(args.ipa)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({'passed': report['passed'], 'checks': len(report['checks']),
                      'failures': report['failures']}))
    raise SystemExit(0 if report['passed'] else 1)


if __name__ == '__main__':
    main()
