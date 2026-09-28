#!/usr/bin/env python3
"""Run the pinned Wallet Core 4.8.4 Android generator in a task-owned tree."""

import argparse
from hashlib import sha256
import json
import os
from pathlib import Path
import shlex
import subprocess
import sys


SOURCE_COMMIT = 'd40d24a63d92619167903369308bf0e2f7eb3a59'
LOCKS = {
    'rust/Cargo.lock': '2e0a91cecf4cc5305e000af96b3dd9c4baefe0171cf736bf06e59f016e5fd337',
    'codegen-v2/Cargo.lock': '00a85d477f89f73cefe844b29b3c1e0deebd57a67d7dab2e38acc768e173dd03',
}
TARGETS = {
    'arm64-v8a': 'aarch64-linux-android',
    'armeabi-v7a': 'armv7-linux-androideabi',
    'x86': 'i686-linux-android',
    'x86_64': 'x86_64-linux-android',
}


def digest(path):
    value = sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            value.update(block)
    return value.hexdigest()


def require(condition, message):
    if not condition:
        raise ValueError(message)


def locked_cargo_args(arguments):
    require(arguments and arguments[0] in ('build', 'run', 'metadata'),
            'unsupported Cargo command')
    before_program = arguments.index('--') if '--' in arguments else len(arguments)
    require('--locked' not in arguments[:before_program], 'duplicate Cargo --locked')
    return arguments[:1] + ['--locked'] + arguments[1:]


def run_cargo_wrapper(arguments):
    source = Path(os.environ['WALLETCORE_SOURCE']).resolve()
    cwd = Path.cwd().resolve()
    require(cwd == source / 'rust' or cwd == source / 'codegen-v2',
            'Cargo invoked outside pinned Wallet Core workspaces')
    for relative, expected in LOCKS.items():
        require(digest(source / relative) == expected, f'Cargo lock changed: {relative}')
    command = [os.environ['WALLETCORE_CARGO_BIN']] + locked_cargo_args(arguments)
    log = Path(os.environ['WALLETCORE_CARGO_CALLS'])
    with log.open('a') as stream:
        stream.write(json.dumps({'cwd': str(cwd), 'command': command}) + '\n')
    return subprocess.run(command, check=False).returncode


def require_preflight(command, receipt):
    result = subprocess.run(command, capture_output=True, text=True, check=False)
    require(result.returncode == 0, f'preflight process failed: {result.stderr.strip()}')
    data = json.loads(receipt.read_text())
    require(data.get('passed') is True and data.get('built_candidate') is False and
            data.get('source', {}).get('commit') == SOURCE_COMMIT,
            'preflight receipt does not match pinned source')
    return {'stdout': result.stdout.strip(), 'receipt': data}


def generator_environment(build, source, files):
    env = {name: value for name, value in os.environ.items()
           if not name.startswith(('CARGO_', 'RUST', 'OPENSSL_', 'PKG_CONFIG_')) and
           name not in ('AR', 'CC', 'CXX', 'PREFIX', 'JAVA_HOME', 'ANDROID_NDK_HOME',
                        'ANDROID_HOME', 'BOOST_ROOT', 'LD_LIBRARY_PATH',
                        'DYLD_LIBRARY_PATH')}
    ndk = Path(files['ndk_source_properties']['path']).parent
    ndk_bin = Path(files['ndk_clang']['path']).parent
    java_home = Path(files['jdk17_java']['path']).parent.parent
    rust_bin = Path(files['rustc']['path']).parent
    prefix = source / 'build/local'
    wrapper_dir = build / 'locked-cargo'
    env.update({
        'PATH': os.pathsep.join(map(str, (wrapper_dir, prefix / 'bin',
            Path(files['cbindgen']['path']).parent, rust_bin,
            Path(files['android_cmake']['path']).parent, java_home / 'bin',
            ndk_bin, Path('/usr/bin'), Path('/bin'), Path('/usr/sbin'),
            Path('/sbin')))),
        'PREFIX': str(prefix),
        'CARGO_HOME': str(build / 'cargo-home'),
        'RUSTUP_HOME': str(build / 'rustup'),
        'RUSTC': files['rustc']['path'],
        'RUSTDOC': files['rustdoc']['path'],
        'CARGO_BUILD_JOBS': '2',
        'ANDROID_NDK_HOME': str(ndk),
        'ANDROID_HOME': str(ndk.parent.parent),
        'JAVA_HOME': str(java_home),
        'BOOST_ROOT': str(build / 'host-tools/boost-1.90.0_1'),
        'WALLETCORE_SOURCE': str(source),
        'WALLETCORE_CARGO_BIN': files['cargo']['path'],
        'WALLETCORE_CARGO_CALLS': str(build / 'cargo-calls.jsonl'),
    })
    return env


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--task-root', type=Path, required=True)
    arguments = parser.parse_args()
    build = (arguments.task_root.resolve() / 'task-16f-walletcore-build')
    source = build / 'source'
    require(source.is_dir() and build.is_dir(), 'task-owned source/build missing')
    app_root = Path(__file__).resolve().parents[1]
    preflight_receipt = build / 'generation-preflight.json'
    preflight = [sys.executable, str(app_root / 'scripts/walletcore_android_preflight.py'),
                 '--source', str(source), '--source-inputs',
                 str(arguments.task_root.resolve() / 'task-16f-walletcore-source-inputs/manifest.json'),
                 '--tool-inputs', str(build / 'tool-inputs.json'),
                 '--boost-manifest', str(build / 'boost-header-manifest.json'),
                 '--boost-headers', str(build / 'host-tools/boost-1.90.0_1/include/boost'),
                 '--official-dir', str(build / 'official'), '--receipt', str(preflight_receipt)]
    result = require_preflight(preflight, preflight_receipt)
    (build / 'generation-preflight-process.json').write_text(json.dumps(result, indent=2) + '\n')
    tools = json.loads((build / 'tool-inputs.json').read_text())
    files = tools['files']
    wrapper = build / 'locked-cargo/cargo'
    wrapper.parent.mkdir(exist_ok=True)
    wrapper.write_text('#!/bin/sh\nexec ' + shlex.quote(sys.executable) + ' ' +
                       shlex.quote(str(Path(__file__).resolve())) + ' --cargo "$@"\n')
    wrapper.chmod(0o755)
    env = generator_environment(build, source, files)
    selected = {name: env[name] for name in ('PATH', 'PREFIX', 'CARGO_HOME',
                'RUSTUP_HOME', 'RUSTC', 'RUSTDOC', 'CARGO_BUILD_JOBS',
                'ANDROID_NDK_HOME', 'ANDROID_HOME', 'JAVA_HOME', 'BOOST_ROOT')}
    (build / 'generation-environment.json').write_text(json.dumps(selected, indent=2) + '\n')
    command = ['/bin/bash', 'tools/generate-files', 'android']
    with (build / 'generation.log').open('w') as log:
        log.write(json.dumps({'cwd': str(source), 'command': command}) + '\n')
        log.flush()
        status = subprocess.run(command, cwd=source, env=env, stdout=log,
                                stderr=subprocess.STDOUT, check=False).returncode
        log.write(f'generator_exit={status}\n')
    require(status == 0, f'tagged Android generator failed: see {build / "generation.log"}')
    archives = {}
    for abi, target in TARGETS.items():
        path = source / 'rust/target' / target / 'release/libwallet_core_rs.a'
        require(path.is_file(), f'Rust archive missing: {abi}')
        archives[abi] = {'path': str(path), 'bytes': path.stat().st_size,
                         'sha256': digest(path)}
    (build / 'rust-archives.json').write_text(json.dumps(archives, indent=2) + '\n')
    print(json.dumps({'generator_exit': status, 'rust_archives': archives}, sort_keys=True))
    return 0


if __name__ == '__main__':
    try:
        if len(sys.argv) > 1 and sys.argv[1] == '--cargo':
            raise SystemExit(run_cargo_wrapper(sys.argv[2:]))
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as error:
        print(f'Wallet Core generator rejected: {error}', file=sys.stderr)
        raise SystemExit(1)
