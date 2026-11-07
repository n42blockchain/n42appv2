#!/usr/bin/env python3
"""Build the resolved Chat crypto crate outside the package cache for host tests."""
import argparse
import json
import platform
import subprocess
from pathlib import Path
from urllib.parse import urljoin, urlparse, unquote


def prepare(chat_root: Path, target: Path) -> Path:
    config = (chat_root / '.dart_tool/package_config.json').resolve()
    packages = json.loads(config.read_text())['packages']
    package = next(p for p in packages if p['name'] == 'flutter_vodozemac')
    uri = urlparse(urljoin(config.as_uri(), package['rootUri']))
    if uri.scheme != 'file':
        raise ValueError('Native crypto package must resolve to a local directory')
    manifest = Path(unquote(uri.path)) / 'rust/Cargo.toml'
    if not manifest.is_file() or not manifest.with_name('Cargo.lock').is_file():
        raise FileNotFoundError('Resolved crypto package lacks locked Rust sources')
    target = target.resolve()
    subprocess.run(['cargo', 'build', '--release', '--locked', '--jobs', '2',
                    '--manifest-path', str(manifest), '--target-dir', str(target)],
                   check=True)
    suffix = {'Linux': 'so', 'Darwin': 'dylib'}[platform.system()]
    library = target / 'release' / f'libvodozemac_bindings_dart.{suffix}'
    if not library.is_file():
        raise FileNotFoundError(f'Cargo did not produce {library}')
    return library


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--chat-root', type=Path, required=True)
    parser.add_argument('--target-dir', type=Path, required=True)
    parser.add_argument('--github-env', type=Path, required=True)
    args = parser.parse_args()
    library = prepare(args.chat_root, args.target_dir)
    # flutter_rust_bridge's supported loader override applies to all test isolates.
    with args.github_env.open('a') as output:
        output.write(f'FRB_DART_LOAD_EXTERNAL_LIBRARY_NATIVE_LIB_DIR={library.parent}\n')
        output.write(f'N42_VODOZEMAC_TEST_LIB={library}\n')


if __name__ == '__main__':
    main()
