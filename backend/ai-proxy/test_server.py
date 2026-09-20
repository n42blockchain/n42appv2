import concurrent.futures
import tempfile
import unittest
from unittest.mock import Mock
import urllib.error
from server import Gateway, valid_payload


class GatewayTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.gateway = Gateway('server-secret', self.tmp.name + '/quota.db',
                               'https://matrix.example', 'https://ai.example')
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
        again = Gateway('secret', self.gateway.database, '', '')
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

    def test_rejects_streaming_images_and_oversize_text(self):
        self.assertTrue(valid_payload(self.payload))
        self.assertFalse(valid_payload(dict(self.payload, stream=True)))
        self.assertFalse(valid_payload({'messages': [{'role': 'user', 'content': []}]}))
        self.assertFalse(valid_payload({'messages': [{'role': 'user', 'content': 'a' * 128001}]}))
        self.assertFalse(valid_payload(dict(self.payload, max_tokens=True)))


if __name__ == '__main__':
    unittest.main()
