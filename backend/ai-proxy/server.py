"""Authenticated, bounded text/image OpenRouter gateway. No third-party dependencies."""
import base64
import binascii
import datetime
import http.server
import json
import os
import sqlite3
import threading
import urllib.error
import urllib.request

MAX_BODY = 3 * 1024 * 1024
MAX_RESPONSE = 1024 * 1024


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None


class Gateway:
    def __init__(self, key, database, homeserver, upstream, user_daily=40,
                 total_daily=50, minute_limit=15):
        self.key, self.database = key, database
        self.homeserver, self.upstream = homeserver.rstrip('/'), upstream
        self.user_daily, self.total_daily = user_daily, total_daily
        self.minute_limit = minute_limit
        self.slots = threading.BoundedSemaphore(4)
        self.opener = urllib.request.build_opener(NoRedirect)
        with sqlite3.connect(database) as db:
            db.execute('CREATE TABLE IF NOT EXISTS usage (day TEXT, minute TEXT, user TEXT)')
            db.execute('CREATE INDEX IF NOT EXISTS usage_day ON usage(day)')

    def reserve(self, user, now=None):
        now = now or datetime.datetime.now(datetime.timezone.utc)
        day, minute = now.strftime('%Y-%m-%d'), now.strftime('%Y-%m-%dT%H:%M')
        with sqlite3.connect(self.database, timeout=5) as db:
            db.execute('BEGIN IMMEDIATE')
            db.execute('DELETE FROM usage WHERE day < ?', (day,))
            total, personal, recent = db.execute(
                'SELECT count(*), coalesce(sum(user=?),0), coalesce(sum(minute=?),0) '
                'FROM usage WHERE day=?', (user, minute, day)).fetchone()
            if total >= self.total_daily or personal >= self.user_daily or recent >= self.minute_limit:
                return False
            db.execute('INSERT INTO usage VALUES (?,?,?)', (day, minute, user))
        return True

    def request(self, url, token, payload=None):
        data = None if payload is None else json.dumps(payload).encode()
        req = urllib.request.Request(url, data=data, headers={
            'Authorization': 'Bearer ' + token, 'Content-Type': 'application/json'})
        with self.opener.open(req, timeout=45 if data else 10) as response:
            body = response.read(MAX_RESPONSE + 1)
            if len(body) > MAX_RESPONSE:
                raise ValueError('Response too large')
            return json.loads(body)

    def complete(self, token, payload):
        try:
            identity = self.request(self.homeserver + '/_matrix/client/v3/account/whoami', token)
            user = identity.get('user_id', '')
            if not isinstance(user, str) or not user.startswith('@'):
                return 401, {'error': {'message': 'Authentication required'}}
        except urllib.error.HTTPError as error:
            return (401 if error.code in (401, 403) else 503), {'error': {'message': 'Authentication unavailable'}}
        except Exception:
            return 503, {'error': {'message': 'Authentication unavailable'}}
        if not self.slots.acquire(blocking=False):
            return 429, {'error': {'message': 'Please retry later'}}
        try:
            if not self.reserve(user):
                return 429, {'error': {'code': 'daily_or_rate_limit', 'message': 'Free AI quota reached. Please try again later.'}}
            # Enforce a free model and no training/data collection, regardless of caller input.
            result = self.request(self.upstream, self.key, {
                'model': 'openrouter/free', 'messages': payload['messages'],
                'max_tokens': min(payload.get('max_tokens', 1024), 2048),
                'temperature': 0.3, 'stream': False,
                'provider': {'data_collection': 'deny'},
            })
            content = result['choices'][0]['message']['content']
            if not isinstance(content, str) or not content.strip():
                raise ValueError('Empty completion')
            return 200, {'choices': [{'message': {'role': 'assistant', 'content': content}}]}
        except urllib.error.HTTPError as error:
            return (429 if error.code == 429 else 503), {'error': {'message': 'AI temporarily unavailable'}}
        except Exception:
            return 503, {'error': {'message': 'AI temporarily unavailable'}}
        finally:
            self.slots.release()


def valid_payload(body):
    if not isinstance(body, dict) or body.get('stream', False) is not False:
        return False
    messages = body.get('messages')
    if not isinstance(messages, list) or not 1 <= len(messages) <= 200:
        return False
    total = 0
    images = 0
    for message in messages:
        if not isinstance(message, dict) or message.get('role') not in ('system', 'user', 'assistant'):
            return False
        content = message.get('content')
        if isinstance(content, str):
            total += len(content)
        elif isinstance(content, list) and message['role'] == 'user' and 1 <= len(content) <= 4:
            for part in content:
                if not isinstance(part, dict):
                    return False
                if part.get('type') == 'text' and isinstance(part.get('text'), str):
                    total += len(part['text'])
                elif part.get('type') == 'image_url' and isinstance(part.get('image_url'), dict):
                    url = part['image_url'].get('url', '')
                    if not isinstance(url, str) or ',' not in url:
                        return False
                    header, encoded = url.split(',', 1)
                    if header not in ('data:image/png;base64', 'data:image/jpeg;base64', 'data:image/webp;base64'):
                        return False
                    try:
                        image = base64.b64decode(encoded, validate=True)
                    except (ValueError, binascii.Error):
                        return False
                    if not 0 < len(image) <= 2 * 1024 * 1024:
                        return False
                    valid_image = (image.startswith(b'\x89PNG\r\n\x1a\n') if 'image/png' in header
                                   else image.startswith(b'\xff\xd8\xff') if 'image/jpeg' in header
                                   else image.startswith(b'RIFF') and image[8:12] == b'WEBP')
                    if not valid_image:
                        return False
                    images += 1
                    if images > 1:
                        return False
                else:
                    return False
        else:
            return False
    tokens = body.get('max_tokens', 1024)
    return 0 < total <= 128000 and type(tokens) is int and tokens > 0


class Handler(http.server.BaseHTTPRequestHandler):
    server_version = 'N42-AI'

    def log_message(self, *args):
        pass  # Never log message contents, headers, access tokens or upstream bodies.

    def reply(self, status, body):
        data = json.dumps(body).encode()
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Cache-Control', 'no-store')
        self.send_header('Content-Length', str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        self.reply(200 if self.path == '/health' else 404, {'status': 'ok' if self.path == '/health' else 'not_found'})

    def do_POST(self):
        self.connection.settimeout(15)
        if self.path != '/v1/chat/completions':
            return self.reply(404, {'error': {'message': 'Not found'}})
        auth = self.headers.get('Authorization', '')
        if not auth.startswith('Bearer ') or not auth[7:].strip() or len(auth) > 8192:
            return self.reply(401, {'error': {'message': 'Authentication required'}})
        try:
            length = int(self.headers.get('Content-Length', '0'))
            if self.headers.get('Transfer-Encoding') or not 0 < length <= MAX_BODY:
                return self.reply(413, {'error': {'message': 'Invalid request size'}})
            body = json.loads(self.rfile.read(length))
            if not valid_payload(body):
                return self.reply(400, {'error': {'message': 'Invalid text or image completion'}})
        except (ValueError, OSError):
            return self.reply(400, {'error': {'message': 'Invalid request'}})
        status, result = self.server.gateway.complete(auth[7:].strip(), body)
        self.reply(status, result)


if __name__ == '__main__':
    os.umask(0o077)
    key = os.environ.get('OPENROUTER_API_KEY', '').strip()
    if not key:
        raise SystemExit('OPENROUTER_API_KEY is required')
    server = http.server.ThreadingHTTPServer(('127.0.0.1', int(os.environ.get('PORT', '8099'))), Handler)
    server.gateway = Gateway(key, os.environ.get('AI_USAGE_DB', '/var/lib/n42-ai/usage.sqlite'),
                             'https://m.si46.world', 'https://openrouter.ai/api/v1/chat/completions')
    server.serve_forever()
