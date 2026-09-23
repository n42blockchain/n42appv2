import base64
import concurrent.futures
import http.server
import json
import sqlite3
import tempfile
import threading
import unittest
from unittest.mock import Mock
import urllib.error
import urllib.request
from server import Gateway, Handler, valid_payload


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

    def test_authentication_transport_failure_fails_closed_without_quota(self):
        self.gateway.request = Mock(side_effect=TimeoutError('Matrix timed out'))
        status, response = self.gateway.complete('token', self.payload)
        self.assertEqual(status, 503)
        self.assertEqual(response, {'error': {'message': 'Authentication unavailable'}})
        with sqlite3.connect(self.gateway.database) as db:
            self.assertEqual(db.execute('SELECT count(*) FROM usage').fetchone()[0], 0)

    def test_upstream_rate_limit_is_retryable_and_does_not_leak_body(self):
        self.gateway.request = Mock(side_effect=[{'user_id': '@a:example'},
            urllib.error.HTTPError('https://ai.example', 429, 'private quota detail', {}, None)])
        status, response = self.gateway.complete('token', self.payload)
        self.assertEqual(status, 429)
        self.assertEqual(response, {'error': {'message': 'AI temporarily unavailable'}})
        self.assertNotIn('private quota detail', str(response))

    def test_malformed_upstream_completion_returns_unavailable_and_releases_slot(self):
        self.gateway.request = Mock(side_effect=[
            {'user_id': '@a:example'}, {},
            {'user_id': '@a:example'}, {'choices': [{'message': {'content': 'Recovered'}}]},
        ])
        first = self.gateway.complete('token', self.payload)
        second = self.gateway.complete('token', self.payload)
        self.assertEqual(first[0], 503)
        self.assertEqual(second[0], 200)
        self.assertEqual(second[1]['choices'][0]['message']['content'], 'Recovered')

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

class HandlerTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.gateway = Gateway('server-secret', self.tmp.name + '/quota.db',
                               'https://matrix.example', 'https://ai.example')
        self.gateway.complete = Mock(return_value=(200, {'choices': []}))
        self.server = http.server.ThreadingHTTPServer(('127.0.0.1', 0), Handler)
        self.server.gateway = self.gateway
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.addCleanup(self._stop_server)

    def _stop_server(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=2)

    def post(self, path, body, authorization=None):
        request = urllib.request.Request(
            'http://127.0.0.1:%d%s' % (self.server.server_port, path),
            data=body,
            method='POST',
        )
        if authorization is not None:
            request.add_header('Authorization', authorization)
        try:
            with urllib.request.urlopen(request, timeout=2) as response:
                return response.status, json.load(response)
        except urllib.error.HTTPError as error:
            return error.code, json.load(error)

    def test_missing_or_malformed_bearer_is_rejected_before_gateway(self):
        for authorization in (None, 'Basic token', 'Bearer    '):
            with self.subTest(authorization=authorization):
                status, response = self.post('/v1/chat/completions', b'{}', authorization)
                self.assertEqual(status, 401)
                self.assertEqual(response['error']['message'], 'Authentication required')
        self.gateway.complete.assert_not_called()

    def test_malformed_json_and_invalid_payload_are_rejected_before_gateway(self):
        malformed = self.post('/v1/chat/completions', b'{', 'Bearer user-token')
        invalid = self.post('/v1/chat/completions', b'{"messages":[],"stream":true}',
                            'Bearer user-token')
        self.assertEqual(malformed[0], 400)
        self.assertEqual(invalid[0], 400)
        self.gateway.complete.assert_not_called()

    def test_unknown_completion_route_is_not_forwarded(self):
        status, response = self.post('/v1/other', b'{}', 'Bearer user-token')
        self.assertEqual(status, 404)
        self.assertEqual(response['error']['message'], 'Not found')
        self.gateway.complete.assert_not_called()

if __name__ == '__main__':
    unittest.main()
