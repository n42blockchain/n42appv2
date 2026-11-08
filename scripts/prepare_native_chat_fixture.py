#!/usr/bin/env python3
"""Own a disposable, loopback-only Matrix fixture for Android CI."""
import argparse
import json
import os
from pathlib import Path
import secrets
import subprocess
import time
import urllib.error
import urllib.request

IMAGE = 'jevolk/tuwunel@sha256:0e86c6164d6c9f5b60291938eb61ad8395021c37fe58d47a963ea7edddbedaec'
BASE = 'http://127.0.0.1:18949'
LABEL = 'ai.n42.qa=wallet-native-chat'


def container_name(env):
    run, attempt = env.get('GITHUB_RUN_ID', ''), env.get('GITHUB_RUN_ATTEMPT', '')
    if env.get('CI') != 'true' or not run.isdigit() or not attempt.isdigit():
        raise ValueError('Requires a numbered disposable CI run')
    return f'n42-wallet-native-chat-{run}-{attempt}'


def request(path, body=None, token=None, method=None):
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = f'Bearer {token}'
    req = urllib.request.Request(BASE + path,
        data=None if body is None else json.dumps(body).encode(),
        headers=headers, method=method)
    # Never follow an unexpected redirect with fixture credentials.
    class NoRedirect(urllib.request.HTTPRedirectHandler):
        def redirect_request(self, *args, **kwargs):
            return None
    try:
        with urllib.request.build_opener(NoRedirect).open(req, timeout=15) as response:
            return response.status, json.load(response)
    except urllib.error.HTTPError as error:
        return error.code, json.load(error)


def register(username, password, registration_token):
    body = {'username': username, 'password': password,
            'auth': ({'type': 'm.login.registration_token', 'token': registration_token}
                     if registration_token else {'type': 'm.login.dummy'})}
    status, result = request('/_matrix/client/v3/register', body)
    if status == 401 and result.get('session'):
        body['auth']['session'] = result['session']
        status, result = request('/_matrix/client/v3/register', body)
    if status != 200 or not all(result.get(k) for k in ('access_token', 'user_id')):
        raise RuntimeError('Disposable Matrix registration failed')
    return result


def start(output, env):
    name = container_name(env)
    registration_token = secrets.token_urlsafe(32)
    docker_env = dict(env, TUWUNEL_REGISTRATION_TOKEN=registration_token)
    subprocess.run(['docker', 'run', '--detach', '--rm', '--name', name,
        '--label', LABEL, '--publish', '127.0.0.1:18949:6167',
        '--env', 'TUWUNEL_SERVER_NAME=native-ci.test',
        '--env', 'TUWUNEL_DATABASE_PATH=/var/lib/tuwunel',
        '--env', 'TUWUNEL_ADDRESS=0.0.0.0', '--env', 'TUWUNEL_PORT=6167',
        '--env', 'TUWUNEL_ALLOW_REGISTRATION=true',
        '--env', 'TUWUNEL_REGISTRATION_TOKEN',
        '--env', 'TUWUNEL_ALLOW_FEDERATION=false',
        '--env', 'TUWUNEL_TRUSTED_SERVERS=[]', IMAGE],
        env=docker_env, check=True, stdout=subprocess.DEVNULL)
    for attempt in range(45):
        try:
            if request('/_matrix/client/versions')[0] == 200:
                break
        except (OSError, ValueError):
            pass
        time.sleep(2)
    else:
        raise RuntimeError('Disposable Matrix startup timed out')
    # The first Tuwunel account bootstraps administration; tests use ordinary users.
    register('fixture_bootstrap', secrets.token_urlsafe(32), registration_token)
    seed(output, env, registration_token, 'http://10.0.2.2:18949')


def seed(output, env, registration_token, client_base):
    password = secrets.token_urlsafe(32)
    primary = register('wallet_fixture', password, registration_token)
    peer = register('wallet_peer', secrets.token_urlsafe(32), registration_token)
    status, room = request('/_matrix/client/v3/createRoom', {
        'name': 'Native CI conversation', 'preset': 'private_chat',
        'invite': [peer['user_id']], 'is_direct': True,
    }, primary['access_token'])
    if status != 200 or not room.get('room_id'):
        raise RuntimeError('Disposable conversation creation failed')
    from urllib.parse import quote
    room_id = quote(room['room_id'], safe='')
    if request(f'/_matrix/client/v3/join/{room_id}', {}, peer['access_token'])[0] != 200:
        raise RuntimeError('Disposable peer join failed')
    for owner, other in [(primary, peer), (peer, primary)]:
        path = '/_matrix/client/v3/user/' + quote(owner['user_id'], safe='') + '/account_data/m.direct'
        if request(path, {other['user_id']: [room['room_id']]}, owner['access_token'], 'PUT')[0] != 200:
            raise RuntimeError('Disposable direct-room metadata failed')
    if request(f'/_matrix/client/v3/rooms/{room_id}/send/m.room.message/fixture',
               {'msgtype': 'm.text', 'body': 'Disposable native CI conversation'},
               peer['access_token'], 'PUT')[0] != 200:
        raise RuntimeError('Disposable conversation seed failed')
    output.parent.mkdir(parents=True, exist_ok=True)
    # File paths only enter the workflow environment; credentials never do.
    fd = os.open(output, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, 'w') as file:
        json.dump({'N42_E2E_CHAT_HOMESERVER': client_base,
                   'N42_E2E_CHAT_USERNAME': primary['user_id'],
                   'N42_E2E_CHAT_PASSWORD': password}, file)
    with open(env['GITHUB_ENV'], 'a') as file:
        file.write(f'N42_NATIVE_CHAT_DEFINES={output.resolve()}\n')
    print('Disposable Matrix fixture ready: two users, one seeded private room')


def stop(env):
    name = container_name(env)
    result = subprocess.run(['docker', 'inspect', '--format',
        '{{ index .Config.Labels "ai.n42.qa" }}', name], capture_output=True, text=True)
    if result.returncode:
        return
    if result.stdout.strip() != 'wallet-native-chat':
        raise ValueError('Refusing to remove an unowned container')
    subprocess.run(['docker', 'rm', '--force', '--volumes', name],
                   check=True, stdout=subprocess.DEVNULL)


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
        try:
            start(args.output, os.environ)
        except Exception:
            stop(os.environ)
            raise


if __name__ == '__main__':
    main()
