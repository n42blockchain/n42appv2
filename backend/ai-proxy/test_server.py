import base64
import concurrent.futures
import contextlib
import http.client
import http.server
import json
import threading
import tempfile
import unittest
from unittest.mock import Mock
import urllib.error
import urllib.request
from server import Gateway, Handler, NoRedirect, valid_payload


@contextlib.contextmanager
def serve_handler(gateway):
    server = http.server.ThreadingHTTPServer(('127.0.0.1', 0), Handler)
    server.gateway = gateway
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    try:
        yield server.server_address[0], server.server_address[1]
    finally:
        server.shutdown()
        server.server_close()
        thread.join(timeout=2)


class _Response:
    def __init__(self, body):
        self.body = body

    def __enter__(self):
        return self

    def __exit__(self, *_):
        return False

    def read(self, _size=-1):
        return self.body


class _GatewayStub:
    def __init__(self, result=(200, {'choices': []})):
        self.result = result
        self.calls = []

    def complete(self, token, payload):
        self.calls.append((token, payload))
        return self.result


class GatewayTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.gateway = Gateway('server-secret', self.tmp.name + '/quota.db',
                               'https://matrix.example', 'https://ai.example', user_daily=10, total_daily=40)
        self.payload = {'messages': [{'role': 'user', 'content': 'Synthetic test'}]}

    def test_enforces_free_model_and_replaces_credentials(self):
        self.gateway.request = Mock(side_effect=[{'user_id': '@a:example'},
            {'choices': [{'message': {'content': 'Summary'}}]}])
        status, _ = self.gateway.complete('matrix-token', dict(self.payload, model='expensive', provider={}))
        self.assertEqual(status, 200)
        call = self.gateway.request.call_args.args
        self.assertEqual(call[1], 'server-secret')
        self.assertEqual(call[2]['model'], 'openrouter/free')
        self.assertEqual(call[2]['provider'], {'data_collection': 'deny'})

    def test_invalid_identity_never_calls_provider(self):
        self.gateway.request = Mock(return_value={})
        self.assertEqual(self.gateway.complete('bad', self.payload)[0], 401)
        self.assertEqual(self.gateway.request.call_count, 1)

    def test_quota_is_atomic_and_survives_restart(self):
        with concurrent.futures.ThreadPoolExecutor(max_workers=12) as pool:
            allowed = list(pool.map(lambda _: self.gateway.reserve('@a:example'), range(20)))
        self.assertEqual(sum(allowed), 10)
        again = Gateway('secret', self.gateway.database, '', '', user_daily=10)
        self.assertFalse(again.reserve('@a:example'))

    def test_global_quota_cannot_be_bypassed_by_accounts(self):
        self.gateway.minute_limit = 100
        self.assertEqual(sum(self.gateway.reserve(str(i)) for i in range(50)), 40)

    def test_provider_error_does_not_leak_body(self):
        self.gateway.request = Mock(side_effect=[{'user_id': '@a:example'},
            urllib.error.HTTPError('https://ai.example', 403, 'secret error', {}, None)])
        status, response = self.gateway.complete('token', self.payload)
        self.assertEqual(status, 503)
        self.assertNotIn('secret', str(response))

    def test_inline_image_validation(self):
        image = 'data:image/png;base64,' + base64.b64encode(b'\x89PNG\r\n\x1a\nfixture').decode()
        def payload(url):
            return {'messages': [{'role': 'user', 'content': [
                {'type': 'text', 'text': 'Describe'},
                {'type': 'image_url', 'image_url': {'url': url}}]}]}
        self.assertTrue(valid_payload(payload(image)))
        self.assertFalse(valid_payload(payload('https://private.example/image.png')))
        self.assertFalse(valid_payload(payload('data:image/png;base64,broken')))
        self.assertFalse(valid_payload(payload('data:image/png;base64,' + base64.b64encode(b'not an image').decode())))
        duplicate = payload(image)
        duplicate['messages'][0]['content'].append(duplicate['messages'][0]['content'][1])
        self.assertFalse(valid_payload(duplicate))

    def test_rejects_streaming_images_and_oversize_text(self):
        self.assertTrue(valid_payload(self.payload))
        self.assertFalse(valid_payload(dict(self.payload, stream=True)))
        self.assertFalse(valid_payload({'messages': [{'role': 'user', 'content': []}]}))
        self.assertFalse(valid_payload({'messages': [{'role': 'user', 'content': 'a' * 128001}]}))
        self.assertFalse(valid_payload(dict(self.payload, max_tokens=True)))

    def test_request_encodes_payload_and_applies_upstream_limits(self):
        response = _Response(b'{"ok":true}')
        self.gateway.opener.open = Mock(return_value=response)
        result = self.gateway.request('https://ai.example/chat', 'server-key', {'x': 1})
        self.assertEqual(result, {'ok': True})
        request, = self.gateway.opener.open.call_args.args
        self.assertEqual(request.get_header('Authorization'), 'Bearer server-key')
        self.assertEqual(request.get_header('Content-type'), 'application/json')
        self.assertEqual(request.data, b'{"x": 1}')
        self.assertEqual(self.gateway.opener.open.call_args.kwargs['timeout'], 45)

    def test_request_uses_short_timeout_without_payload(self):
        self.gateway.opener.open = Mock(return_value=_Response(b'{"user_id":"@a:hs"}'))
        self.gateway.request('https://matrix.example/whoami', 'matrix-token')
        self.assertEqual(self.gateway.opener.open.call_args.kwargs['timeout'], 10)

    def test_request_rejects_oversize_and_malformed_upstream_bodies(self):
        self.gateway.opener.open = Mock(return_value=_Response(b'x' * (1024 * 1024 + 1)))
        with self.assertRaisesRegex(ValueError, 'Response too large'):
            self.gateway.request('https://ai.example/chat', 'server-key')
        self.gateway.opener.open = Mock(return_value=_Response(b'not-json'))
        with self.assertRaises(json.JSONDecodeError):
            self.gateway.request('https://ai.example/chat', 'server-key')

    def test_no_redirect_handler_does_not_follow_redirects(self):
        request = urllib.request.Request('https://ai.example/chat')
        self.assertIsNone(NoRedirect().redirect_request(request, None, 302, 'Found', {}, 'https://elsewhere.invalid'))

    def test_auth_transport_failure_is_sanitized(self):
        for error, expected in [
            (urllib.error.HTTPError('https://matrix.example', 401, 'secret', {}, None), 401),
            (urllib.error.HTTPError('https://matrix.example', 403, 'secret', {}, None), 401),
            (urllib.error.HTTPError('https://matrix.example', 500, 'secret', {}, None), 503),
            (OSError('secret internal detail'), 503),
        ]:
            with self.subTest(expected=expected, error=type(error).__name__):
                self.gateway.request = Mock(side_effect=error)
                status, response = self.gateway.complete('matrix-token', self.payload)
                self.assertEqual(status, expected)
                self.assertNotIn('secret', str(response))

    def test_saturated_workers_and_quota_do_not_call_provider(self):
        self.gateway.request = Mock(return_value={'user_id': '@a:example'})
        self.gateway.slots = threading.BoundedSemaphore(0)
        self.assertEqual(self.gateway.complete('token', self.payload)[0], 429)
        self.assertEqual(self.gateway.request.call_count, 1)

        self.gateway.slots = threading.BoundedSemaphore(1)
        self.gateway.reserve = Mock(return_value=False)
        self.gateway.request = Mock(return_value={'user_id': '@a:example'})
        status, response = self.gateway.complete('token', self.payload)
        self.assertEqual(status, 429)
        self.assertEqual(response['error']['code'], 'daily_or_rate_limit')
        self.assertEqual(self.gateway.request.call_count, 1)
        self.assertTrue(self.gateway.slots.acquire(blocking=False))
        self.gateway.slots.release()

    def test_upstream_invalid_completion_releases_worker_slot(self):
        for result in [{}, {'choices': [{'message': {'content': '  '}}]}]:
            with self.subTest(result=result):
                self.gateway.slots = threading.BoundedSemaphore(1)
                self.gateway.request = Mock(side_effect=[{'user_id': '@a:example'}, result])
                status, response = self.gateway.complete('token', self.payload)
                self.assertEqual(status, 503)
                self.assertEqual(response['error']['message'], 'AI temporarily unavailable')
                self.assertTrue(self.gateway.slots.acquire(blocking=False))
                self.gateway.slots.release()

    def test_upstream_rate_limit_is_reported_without_upstream_details(self):
        error = urllib.error.HTTPError('https://ai.example', 429, 'secret', {}, None)
        self.gateway.request = Mock(side_effect=[{'user_id': '@a:example'}, error])
        status, response = self.gateway.complete('token', self.payload)
        self.assertEqual(status, 429)
        self.assertNotIn('secret', str(response))

    def test_valid_payload_rejects_invalid_roles_content_parts_and_image_types(self):
        invalid = [
            {'messages': [None]},
            {'messages': [{'role': 'tool', 'content': 'x'}]},
            {'messages': [{'role': 'user', 'content': 5}]},
            {'messages': [{'role': 'assistant', 'content': [{'type': 'text', 'text': 'x'}]}]},
            {'messages': [{'role': 'user', 'content': [{}]}]},
            {'messages': [{'role': 'user', 'content': [None]}]},
            {'messages': [{'role': 'user', 'content': [{'type': 'text', 'text': 1}]}]},
            {'messages': [{'role': 'user', 'content': [{'type': 'image_url', 'image_url': {'url': 'data:image/gif;base64,R0lG'}}]}]},
            {'messages': [{'role': 'user', 'content': [{'type': 'image_url', 'image_url': {'url': 'data:image/png;base64,' + base64.b64encode(b'\x89PNG\r\n\x1a\n').decode()}}]}]},
            {'messages': [{'role': 'user', 'content': [
                {'type': 'text', 'text': 'Describe'},
                {'type': 'image_url', 'image_url': {'url': 'data:image/png;base64,'}},
            ]}]},
        ]
        for payload in invalid:
            with self.subTest(payload=payload):
                self.assertFalse(valid_payload(payload))

    def test_valid_payload_accepts_supported_jpeg_and_webp_headers(self):
        for content_type, signature in [
            ('image/jpeg', b'\xff\xd8\xfffixture'),
            ('image/webp', b'RIFFxxxxWEBPfixture'),
        ]:
            encoded = base64.b64encode(signature).decode()
            payload = {'messages': [{'role': 'user', 'content': [
                {'type': 'text', 'text': 'Describe'},
                {'type': 'image_url', 'image_url': {'url': f'data:{content_type};base64,{encoded}'}},
            ]}]}
            with self.subTest(content_type=content_type):
                self.assertTrue(valid_payload(payload))

    def test_handler_health_unknown_routes_and_authenticated_completion(self):
        gateway = _GatewayStub((201, {'result': 'synthetic'}))
        with serve_handler(gateway) as (host, port):
            conn = http.client.HTTPConnection(host, port, timeout=2)
            conn.request('GET', '/health')
            response = conn.getresponse()
            self.assertEqual(response.status, 200)
            self.assertEqual(json.loads(response.read()), {'status': 'ok'})
            conn.request('GET', '/elsewhere')
            response = conn.getresponse()
            self.assertEqual(response.status, 404)
            self.assertEqual(json.loads(response.read()), {'status': 'not_found'})

            body = json.dumps(self.payload)
            conn.request('POST', '/wrong', body, {'Authorization': 'Bearer caller'})
            self.assertEqual(conn.getresponse().status, 404)
            conn.request('POST', '/v1/chat/completions', body, {'Authorization': 'Bearer caller'})
            response = conn.getresponse()
            self.assertEqual(response.status, 201)
            self.assertEqual(json.loads(response.read()), {'result': 'synthetic'})
            self.assertEqual(gateway.calls, [('caller', self.payload)])
            conn.close()

    def test_handler_rejects_auth_size_json_and_payload_errors(self):
        gateway = _GatewayStub()
        with serve_handler(gateway) as (host, port):
            def post(body, headers=None):
                conn = http.client.HTTPConnection(host, port, timeout=2)
                conn.request('POST', '/v1/chat/completions', body, headers or {})
                response = conn.getresponse()
                status = response.status
                response.read()
                conn.close()
                return status

            self.assertEqual(post(b'{}'), 401)
            self.assertEqual(post(b'{}', {'Authorization': 'Bearer   '}), 401)
            self.assertEqual(post(b'{}', {'Authorization': 'Bearer ' + 'x' * 9000}), 401)
            self.assertEqual(post(b'{}', {'Authorization': 'Bearer token', 'Transfer-Encoding': 'chunked'}), 413)
            self.assertEqual(post(b'{', {'Authorization': 'Bearer token'}), 400)
            self.assertEqual(post(b'{"messages":[]}', {'Authorization': 'Bearer token'}), 400)
            self.assertEqual(gateway.calls, [])


if __name__ == '__main__':
    unittest.main()
