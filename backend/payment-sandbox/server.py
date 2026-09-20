"""Explicit localSimulation HTTP fixture; never a public payment endpoint."""
import hmac
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import re
from socketserver import TCPServer
import time
from urllib.parse import parse_qs, urlsplit

from common import MAX_UNITS, MODE, SandboxError, identifier

MAX_BODY = 64 * 1024


class RequestError(Exception):
    def __init__(self, status, code):
        self.status, self.code = status, code


def integer_string(value):
    if not isinstance(value, str) or not re.fullmatch(r'0|[1-9][0-9]{0,15}', value):
        raise RequestError(400, 'invalid_request')
    result = int(value)
    if result > MAX_UNITS:
        raise RequestError(400, 'invalid_request')
    return result


def wire(value):
    if type(value) is int:
        return str(value)
    if isinstance(value, dict):
        return {key: wire(item) for key, item in value.items()}
    return value


def strict_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise RequestError(400, 'invalid_request')
        result[key] = value
    return result


class LocalPaymentServer(ThreadingHTTPServer):
    daemon_threads = True

    def __init__(self, sandbox, *, mode, tokens, host='127.0.0.1', port=0, clock=None):
        if mode != MODE or host != '127.0.0.1':
            raise ValueError('only explicit localSimulation on 127.0.0.1 is allowed')
        if not isinstance(tokens, dict) or not tokens:
            raise ValueError('explicit synthetic token mapping required')
        for token, account in tokens.items():
            if not isinstance(token, str) or not re.fullmatch(r'synthetic-test-[A-Za-z0-9_-]{8,128}', token):
                raise ValueError('only synthetic-test tokens are accepted')
            identifier(account)
        self.sandbox, self.tokens = sandbox, dict(tokens)
        self.clock = clock or (lambda: int(time.time()))
        # Bind keys before money actions. A crashed pending action can safely be
        # retried because every core operation is independently idempotent.
        with sandbox._transaction() as db:
            db.execute('''CREATE TABLE IF NOT EXISTS http_idempotency (
                actor TEXT, key TEXT, request TEXT NOT NULL, PRIMARY KEY(actor,key))''')
        super().__init__((host, port), Handler)

    def server_bind(self):
        # HTTPServer normally performs reverse DNS. This fixture is strictly
        # numeric loopback and must not perform even incidental external lookup.
        TCPServer.server_bind(self)
        self.server_name = '127.0.0.1'
        self.server_port = self.server_address[1]

    def bind_key(self, actor, key, route, body):
        canonical = json.dumps([route, body], sort_keys=True, separators=(',', ':'))
        with self.sandbox._transaction() as db:
            previous = db.execute('SELECT request FROM http_idempotency WHERE actor=? AND key=?', (actor, key)).fetchone()
            if previous and previous[0] != canonical:
                raise RequestError(409, 'conflict')
            db.execute('INSERT INTO http_idempotency VALUES (?,?,?) ON CONFLICT DO NOTHING', (actor, key, canonical))


class Handler(BaseHTTPRequestHandler):
    server_version = 'LocalSimulation'
    sys_version = ''

    def setup(self):
        super().setup()
        self.connection.settimeout(5)

    def log_message(self, *_args):
        pass  # Never log bearer tokens, account IDs or payloads.

    def _single_header(self, name):
        values = self.headers.get_all(name, [])
        if len(values) != 1:
            raise RequestError(400, 'invalid_request')
        return values[0]

    def _actor(self):
        # Reject browser origins (no CORS) and DNS-rebinding Host values.
        if self.headers.get('Origin') is not None:
            raise RequestError(400, 'invalid_request')
        expected = '127.0.0.1:' + str(self.server.server_port)
        if self._single_header('Host') != expected:
            raise RequestError(400, 'invalid_request')
        values = self.headers.get_all('Authorization', [])
        if len(values) != 1 or not values[0].startswith('Bearer '):
            raise RequestError(401, 'unauthorized')
        provided = values[0][7:]
        for token, actor in self.server.tokens.items():
            if hmac.compare_digest(provided.encode(), token.encode()):
                return actor
        raise RequestError(401, 'unauthorized')

    def _body(self):
        if self.headers.get('Transfer-Encoding') is not None:
            raise RequestError(400, 'invalid_request')
        length = self._single_header('Content-Length')
        if not re.fullmatch(r'0|[1-9][0-9]{0,9}', length):
            raise RequestError(400, 'invalid_request')
        length = int(length)
        if length > MAX_BODY:
            raise RequestError(413, 'payload_too_large')
        if self._single_header('Content-Type').lower() != 'application/json':
            raise RequestError(400, 'invalid_request')
        raw = self.rfile.read(length)
        if len(raw) != length:
            raise RequestError(400, 'invalid_request')
        try:
            value = json.loads(raw.decode('utf-8'), object_pairs_hook=strict_object,
                               parse_constant=lambda _: (_ for _ in ()).throw(ValueError()))
        except (ValueError, UnicodeError, RecursionError):
            raise RequestError(400, 'invalid_request') from None
        if not isinstance(value, dict):
            raise RequestError(400, 'invalid_request')
        return value

    def _dispatch(self):
        actor = self._actor()
        account = self.server.sandbox.account(actor)
        route = urlsplit(self.path)
        if route.scheme or route.netloc or route.fragment:
            raise RequestError(400, 'invalid_request')
        if self.command == 'GET':
            operation = re.fullmatch(r'/operations/((?:transfer|packet|refund)_[a-f0-9]{64})', route.path)
            if operation is not None:
                lengths = self.headers.get_all('Content-Length', [])
                if (route.query or self.headers.get('Transfer-Encoding') is not None
                        or (lengths and lengths != ['0'])):
                    raise RequestError(400, 'invalid_request')
                with self.server.sandbox._transaction() as db:
                    row = db.execute(
                        "SELECT result FROM operations WHERE id=? AND actor=? AND kind IN ('transfer','packet','refund')",
                        (operation[1], actor)).fetchone()
                if row is None:
                    # Missing and another account's receipts are indistinguishable.
                    raise RequestError(404, 'not_found')
                return json.loads(row['result'])
            if route.path != '/balances':
                raise RequestError(404, 'not_found')
            query = parse_qs(route.query, keep_blank_values=True)
            if set(query) != {'asset'} or len(query['asset']) != 1:
                raise RequestError(400, 'invalid_request')
            try:
                return account.balance(query['asset'][0])
            except SandboxError:
                raise RequestError(400, 'invalid_request') from None
        if route.query:
            raise RequestError(400, 'invalid_request')
        match = re.fullmatch(r'/packets/(packet_[a-f0-9]{64})/(claims|refunds)', route.path)
        if route.path not in ('/transfers', '/packets') and match is None:
            raise RequestError(404, 'not_found')
        key = self._single_header('Idempotency-Key')
        if not re.fullmatch(r'[\x21-\x7e]{1,128}', key):
            raise RequestError(400, 'invalid_request')
        body = self._body()
        fields = ({'recipient', 'asset', 'amount'} if route.path == '/transfers' else
                  {'room', 'asset', 'total', 'slots', 'expiresAt'} if route.path == '/packets' else set())
        if set(body) != fields:
            raise RequestError(400, 'invalid_request')
        parsed = dict(body)
        try:
            for field, value in body.items():
                if field in ('amount', 'total', 'slots', 'expiresAt'):
                    parsed[field] = integer_string(value)
                else:
                    identifier(value)
            if 'asset' in body:
                self.server.sandbox._asset(body['asset'])
        except SandboxError:
            raise RequestError(400, 'invalid_request') from None
        self.server.bind_key(actor, key, route.path, body)
        now = self.server.clock()
        if type(now) is not int or not 0 <= now <= MAX_UNITS:
            raise RuntimeError('invalid fixture clock')
        try:
            if route.path == '/transfers':
                return account.transfer(parsed['recipient'], parsed['asset'], parsed['amount'], key=key)
            if route.path == '/packets':
                return account.create_packet(parsed['room'], parsed['asset'], parsed['total'], parsed['slots'],
                                             expires_at=parsed['expiresAt'], now=now, key=key)
            if match[2] == 'claims':
                return account.claim(match[1], now=now)
            return account.refund_expired(match[1], now=now)
        except SandboxError:
            raise RequestError(409, 'conflict') from None

    def _handle(self):
        try:
            result = wire(self._dispatch())
            status = 200
        except RequestError as error:
            status = error.status
            result = {'mode': MODE, 'error': {'code': error.code, 'message': error.code.replace('_', ' ')}}
        except Exception:
            status = 500
            result = {'mode': MODE, 'error': {'code': 'internal_error', 'message': 'local operation failed'}}
        data = json.dumps(result, separators=(',', ':')).encode()
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(data)))
        self.send_header('Cache-Control', 'no-store')
        self.send_header('Connection', 'close')
        self.end_headers()
        self.wfile.write(data)
        self.close_connection = True

    do_GET = _handle
    do_POST = _handle
