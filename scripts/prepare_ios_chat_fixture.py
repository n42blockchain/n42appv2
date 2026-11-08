#!/usr/bin/env python3
"""Own a loopback Synapse process for disposable macOS CI; never use real accounts."""
import argparse
import json
import os
from pathlib import Path
import secrets
import signal
import socket
import subprocess
import sys
import time

import prepare_native_chat_fixture as matrix


def shard_index(env):
    value = env.get('N42_IOS_NATIVE_SHARD_INDEX', '0')
    count = env.get('N42_IOS_NATIVE_SHARD_COUNT', '1')
    if not value.isdigit() or not count.isdigit() or not (0 <= int(value) < int(count) <= 8):
        raise ValueError('Invalid owned Matrix shard')
    return int(value)


def fixture_root(env):
    name = matrix.container_name(env)
    if 'N42_IOS_NATIVE_SHARD_INDEX' in env:
        name += f'-shard-{shard_index(env)}'
    return Path(env['RUNNER_TEMP']).resolve() / name


def stop(env):
    root = fixture_root(env)
    state = root / 'process.json'
    if not state.exists():
        return
    pid = json.loads(state.read_text())['pid']
    if not isinstance(pid, int) or pid <= 1:
        raise ValueError('Invalid owned fixture process')
    process = subprocess.run(['ps', '-p', str(pid), '-o', 'command='],
                             capture_output=True, text=True)
    if process.returncode:
        state.unlink()
        return
    if 'synapse.app.homeserver' not in process.stdout or str(root / 'homeserver.json') not in process.stdout:
        raise ValueError('Refusing to stop an unowned Matrix process')
    os.kill(pid, signal.SIGTERM)
    for _ in range(50):
        try:
            os.kill(pid, 0)
        except ProcessLookupError:
            state.unlink()
            return
        time.sleep(.1)
    raise RuntimeError('Owned Matrix process did not stop; retained ownership record')


def start(output, env):
    root = fixture_root(env)
    # Refuse an occupied endpoint before creating any account or process state.
    with socket.socket() as probe:
        probe.bind(('127.0.0.1', 18949 + shard_index(env)))
    root.mkdir(mode=0o700, parents=False, exist_ok=False)
    try:
        _start(root, output, env)
    except Exception:
        stop(env)
        raise


def _start(root, output, env):
    port = 18949 + shard_index(env)
    matrix.BASE = f'http://127.0.0.1:{port}'
    config = root / 'homeserver.json'
    # JSON is valid YAML. All listeners and the SQLite database are disposable.
    config.write_text(json.dumps({
        'server_name': 'native-ci.test', 'public_baseurl': matrix.BASE,
        'pid_file': str(root / 'synapse.pid'), 'report_stats': False,
        'listeners': [{'port': port, 'type': 'http', 'tls': False,
                       'bind_addresses': ['127.0.0.1'],
                       'resources': [{'names': ['client'], 'compress': False}]}],
        'database': {'name': 'sqlite3', 'args': {'database': str(root / 'homeserver.db')}},
        'media_store_path': str(root / 'media'),
        'signing_key_path': str(root / 'signing.key'),
        'macaroon_secret_key': secrets.token_urlsafe(32),
        'form_secret': secrets.token_urlsafe(32),
        'enable_registration': True, 'enable_registration_without_verification': True,
        'trusted_key_servers': [], 'federation_domain_whitelist': [],
        'rc_registration': {'per_second': 100, 'burst_count': 100},
        'rc_message': {'per_second': 100, 'burst_count': 100},
    }))
    config.chmod(0o600)
    with (root / 'server.log').open('w') as log:
        process = subprocess.Popen([sys.executable, '-m', 'synapse.app.homeserver',
                                    '--config-path', str(config)],
                                   stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
    (root / 'process.json').write_text(json.dumps({'pid': process.pid}))
    for _ in range(60):
        if process.poll() is not None:
            raise RuntimeError('Disposable Synapse exited; inspect private fixture log')
        try:
            owner = subprocess.run(['lsof', '-nP', '-t', f'-iTCP:{port}', '-sTCP:LISTEN'],
                                   capture_output=True, text=True)
            if owner.stdout.strip() != str(process.pid):
                time.sleep(1)
                continue
            if matrix.request('/_matrix/client/versions')[0] == 200:
                matrix.seed(output, env, None, matrix.BASE)
                return
        except (OSError, ValueError):
            pass
        time.sleep(1)
    raise RuntimeError('Disposable Synapse startup timed out')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['start', 'stop'])
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    if args.action == 'stop':
        stop(os.environ)
    elif args.output is None:
        parser.error('start requires --output')
    else:
        start(args.output, os.environ)


if __name__ == '__main__':
    main()
