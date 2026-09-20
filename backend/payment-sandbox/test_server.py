from concurrent.futures import ThreadPoolExecutor
import http.client
import json
import threading
from urllib.parse import urlencode

from test_support import Fixture, ASSET, MODE
from server import LocalPaymentServer, MAX_BODY

TOKENS = {'synthetic-test-alice000': 'a', 'synthetic-test-bob00000': 'b', 'synthetic-test-outsider': 'outsider'}


class HttpTests(Fixture):
    def setUp(self):
        super().setUp()
        self.now = 1
        self.start_server()
        self.addCleanup(self.stop_server)

    def start_server(self):
        self.server = LocalPaymentServer(self.s, mode=MODE, tokens=TOKENS, clock=lambda: self.now)
        self.thread = threading.Thread(target=self.server.serve_forever, kwargs={'poll_interval': 0.01}, daemon=True)
        self.thread.start()

    def stop_server(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=2)

    def request(self, method, path, body=None, *, token='synthetic-test-alice000', key='key', extra=None, raw=None):
        headers = {}
        if token is not None:
            headers['Authorization'] = 'Bearer ' + token
        if method == 'POST':
            headers['Content-Type'] = 'application/json'
            if key is not None:
                headers['Idempotency-Key'] = key
            raw = json.dumps(body).encode() if raw is None else raw
        headers.update(extra or {})
        conn = http.client.HTTPConnection('127.0.0.1', self.server.server_port, timeout=5)
        try:
            conn.request(method, path, body=raw, headers=headers)
            response = conn.getresponse()
            data = json.loads(response.read())
            self.assertEqual(data['mode'], MODE)
            self.assertEqual(response.getheader('Cache-Control'), 'no-store')
            return response.status, data
        finally:
            conn.close()

    def transfer(self, amount='10', **kwargs):
        return self.request('POST', '/transfers', {'recipient': 'b', 'asset': ASSET, 'amount': amount}, **kwargs)

    def create(self):
        status, result = self.request('POST', '/packets', {'room': 'room', 'asset': ASSET, 'total': '60', 'slots': '3', 'expiresAt': '100'}, key='create')
        self.assertEqual(status, 200)
        return result['id']

    def test_config_fail_closed(self):
        for kwargs in [{'mode': 'production'}, {'host': '0.0.0.0'}, {'host': 'localhost'}, {'tokens': {'live-token': 'a'}}]:
            config = {'mode': MODE, 'tokens': TOKENS}
            config.update(kwargs)
            with self.assertRaises(ValueError):
                LocalPaymentServer(self.s, **config)

    def test_auth_isolation_and_no_admin_route(self):
        path = '/balances?' + urlencode({'asset': ASSET})
        self.assertEqual(self.request('GET', path)[1]['available'], '100')
        self.assertEqual(self.request('GET', path, token='synthetic-test-bob00000')[1]['available'], '0')
        for token in [None, 'incorrect']:
            self.assertEqual(self.request('GET', path, token=token)[0], 401)
        self.assertEqual(self.request('GET', path + '&account=a', token='synthetic-test-bob00000')[0], 400)
        self.assertEqual(self.request('POST', '/seed', {})[0], 404)
        self.assertEqual(self.request('POST', '/members', {})[0], 404)
        self.assertEqual(self.transfer(extra={'Origin': 'https://example.com'})[0], 400)
        self.assertEqual(self.transfer(extra={'Host': 'example.com'})[0], 400)

    def test_integer_protocol_and_unknown_fields(self):
        for amount in [10, True, 10.0, '01', '-1', '1e1', '9000000000000001', '']:
            with self.subTest(amount=amount):
                self.assertEqual(self.transfer(amount)[0], 400)
        for forbidden in ['sender', 'now', 'account']:
            body = {'recipient': 'b', 'asset': ASSET, 'amount': '10', forbidden: 'a'}
            self.assertEqual(self.request('POST', '/transfers', body)[0], 400)
        self.assertEqual(self.transfer(key=None)[0], 400)
        self.assertEqual(self.transfer()[1]['amount'], '10')

    def test_replay_conflict_and_restart(self):
        initial = self.transfer()
        self.assertEqual(initial[0], 200)
        self.assertEqual(self.transfer(), initial)
        self.assertEqual(self.transfer('11')[0], 409)
        self.stop_server()
        self.start_server()
        self.assertEqual(self.transfer(), initial)
        self.assertEqual(self.transfer('11')[0], 409)
        self.assertEqual(self.a.balance(ASSET)['available'], 90)
        self.conserved()

    def test_packet_clock_membership_and_refund(self):
        packet = self.create()
        claim_path = '/packets/' + packet + '/claims'
        refund_path = '/packets/' + packet + '/refunds'
        denied = self.request('POST', claim_path, {}, key='claim', token='synthetic-test-outsider')
        self.assertEqual(denied[0], 409)
        status, claim = self.request('POST', claim_path, {}, key='claim', token='synthetic-test-bob00000')
        self.assertEqual((status, claim['amount']), (200, '20'))
        self.assertEqual(self.request('POST', refund_path, {}, key='refund')[0], 409)
        self.now = 100
        refunded = self.request('POST', refund_path, {}, key='refund')
        self.assertEqual((refunded[0], refunded[1]['amount']), (200, '40'))
        self.assertEqual(self.request('POST', refund_path, {}, key='refund'), refunded)
        self.assertEqual(self.request('POST', claim_path, {}, key='claim', token='synthetic-test-bob00000')[1], claim)
        self.assertEqual(self.request('POST', claim_path, {}, key='refund')[0], 409)
        self.assertEqual(self.a.balance(ASSET)['available'], 80)
        self.conserved()

    def test_size_json_and_sanitized_errors(self):
        self.assertEqual(self.request('POST', '/transfers', raw=b'x' * (MAX_BODY + 1))[0], 413)
        for raw in [b'{', b'[]', b'{"amount":"1","amount":"2"}', b'{"x":NaN}', b'\xff']:
            self.assertEqual(self.request('POST', '/transfers', raw=raw)[0], 400)
        status, error = self.transfer('101')
        self.assertEqual(status, 409)
        self.assertEqual(error['error'], {'code': 'conflict', 'message': 'conflict'})
        self.server.clock = lambda: (_ for _ in ()).throw(RuntimeError('SENSITIVE fixture detail'))
        status, error = self.transfer(key='internal')
        self.assertEqual(status, 500)
        self.assertNotIn('SENSITIVE', json.dumps(error))

    def test_concurrent_http_replay(self):
        with ThreadPoolExecutor(max_workers=4) as pool:
            results = list(pool.map(lambda _: self.transfer('30'), range(12)))
        self.assertTrue(all(result == results[0] and result[0] == 200 for result in results))
        self.assertEqual(self.a.balance(ASSET)['available'], 70)
        self.conserved()

    def test_operation_query_returns_original_receipts_without_mutation(self):
        transfer = self.transfer()[1]
        status, packet = self.request('POST', '/packets', {
            'room': 'room', 'asset': ASSET, 'total': '60', 'slots': '3', 'expiresAt': '100'}, key='create')
        self.assertEqual(status, 200)
        packet_id = packet['id']
        self.assertEqual(packet['total'], '60')
        self.assertEqual(packet['slots'], '3')
        self.now = 100
        refund = self.request('POST', '/packets/' + packet_id + '/refunds', {}, key='refund')[1]
        before = self.s.audit_test_asset(ASSET)
        for receipt in [transfer, packet, refund]:
            with self.subTest(operation=receipt['id']):
                self.assertEqual(self.request('GET', '/operations/' + receipt['id']), (200, receipt))
                self.assertNotIn('status', receipt)
        self.assertEqual(before, self.s.audit_test_asset(ASSET))
        self.conserved()

    def test_operation_query_hides_other_accounts_and_unsupported_operations(self):
        from common import stable_id
        receipt = self.transfer()[1]
        missing = self.request('GET', '/operations/transfer_' + '0' * 64)
        self.assertEqual(missing[0], 404)
        self.assertEqual(self.request('GET', '/operations/' + receipt['id'], token='synthetic-test-bob00000'), missing)
        self.assertEqual(self.request('GET', '/operations/' + receipt['id'], token='synthetic-test-outsider'), missing)
        for operation in [stable_id('seed', 'a', 'seed'), 'claim_' + '0' * 64, 'transfer_short', 'packet_' + 'A' * 64]:
            self.assertEqual(self.request('GET', '/operations/' + operation), missing)
        self.assertEqual(self.request('GET', '/operations/' + receipt['id'], token=None)[0], 401)
        self.assertEqual(self.request('GET', '/operations/' + receipt['id'] + '?sender=a')[0], 400)
        self.assertEqual(self.request('GET', '/operations/' + receipt['id'], raw=b'{}')[0], 400)

    def test_operation_query_survives_restart(self):
        receipt = self.transfer()[1]
        self.stop_server()
        self.start_server()
        self.assertEqual(self.request('GET', '/operations/' + receipt['id']), (200, receipt))
        self.assertEqual(self.transfer(), (200, receipt))
        self.assertEqual(self.a.balance(ASSET)['available'], 90)
        self.conserved()

    def test_request_lookup_completed_receipts_and_isolation(self):
        from urllib.parse import quote
        key = '/a?b%+#'
        transfer = self.transfer(key=key)[1]
        path = '/requests/' + quote(key, safe='')
        result = self.request('GET', path)
        self.assertEqual(result, (200, {'mode': MODE, 'status': 'completed', 'receipt': transfer}))
        missing = self.request('GET', '/requests/missing')
        self.assertEqual(missing[0], 404)
        self.assertEqual(self.request('GET', path, token='synthetic-test-bob00000'), missing)
        self.assertEqual(self.request('GET', path, token=None)[0], 401)
        packet_id = self.create()
        packet = self.request('GET', '/operations/' + packet_id)[1]
        self.assertEqual(self.request('GET', '/requests/create')[1]['receipt'], packet)
        self.server.bind_key('b', 'claim', '/packets/' + packet_id + '/claims', {})
        self.assertEqual(self.request('GET', '/requests/claim', token='synthetic-test-bob00000')[1]['status'], 'unresolved')
        self.assertEqual(self.request('POST', '/packets/' + packet_id + '/refunds', {}, key='refund')[0], 409)
        self.assertEqual(self.request('GET', '/requests/refund')[1]['status'], 'unresolved')
        claim = self.request('POST', '/packets/' + packet_id + '/claims', {},
                             key='claim', token='synthetic-test-bob00000')[1]
        self.assertEqual(self.request('GET', '/requests/claim', token='synthetic-test-bob00000')[1]['receipt'], claim)
        self.now = 100
        refund = self.request('POST', '/packets/' + packet_id + '/refunds', {}, key='refund')[1]
        self.assertEqual(self.request('GET', '/requests/refund')[1]['receipt'], refund)
        self.conserved()

    def test_request_lookup_unresolved_then_completed_and_restart(self):
        self.assertEqual(self.transfer('101', key='insufficient')[0], 409)
        self.assertEqual(self.request('GET', '/requests/insufficient'),
                         (200, {'mode': MODE, 'status': 'unresolved'}))
        body = {'recipient': 'b', 'asset': ASSET, 'amount': '10'}
        self.server.bind_key('a', 'interrupted', '/transfers', body)
        before = self.s.audit_test_asset(ASSET)
        self.assertEqual(self.request('GET', '/requests/interrupted')[1]['status'], 'unresolved')
        self.assertEqual(self.s.audit_test_asset(ASSET), before)
        self.stop_server()
        self.start_server()
        self.assertEqual(self.request('GET', '/requests/interrupted')[1]['status'], 'unresolved')
        receipt = self.transfer(key='interrupted')[1]
        self.stop_server()
        self.start_server()
        self.assertEqual(self.request('GET', '/requests/interrupted')[1]['receipt'], receipt)
        self.assertEqual(self.a.balance(ASSET)['available'], 90)
        self.conserved()

    def test_request_lookup_rejects_bad_encoding_and_overrides(self):
        for encoded in ['', '%', '%0', '%GG', '%FF', '%C3%A9', '%20', '%00', 'a' * 129, 'raw/slash']:
            with self.subTest(encoded=encoded):
                self.assertEqual(self.request('GET', '/requests/' + encoded)[0], 400)
        self.transfer(key='%2F')
        self.assertEqual(self.request('GET', '/requests/%252F')[1]['status'], 'completed')
        self.assertEqual(self.request('GET', '/requests/%2F')[0], 404)
        self.assertEqual(self.request('GET', '/requests/key?sender=a')[0], 400)
        self.assertEqual(self.request('GET', '/requests/key', raw=b'{}')[0], 400)

    def test_request_lookup_does_not_confuse_direct_core_collision(self):
        self.a.transfer('b', ASSET, 1, key='collision')
        self.assertEqual(self.transfer('2', key='collision')[0], 409)
        self.assertEqual(self.request('GET', '/requests/collision')[1]['status'], 'unresolved')
        self.assertEqual(self.a.balance(ASSET)['available'], 99)
        self.conserved()
