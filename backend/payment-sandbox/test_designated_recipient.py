"""Synthetic designated-recipient packets; no provider or real funds."""
from concurrent.futures import ThreadPoolExecutor
import json
import sqlite3
from urllib.parse import urlencode

from sandbox import Sandbox
from test_support import Fixture, ASSET, OTHER, MODE, SandboxError
import test_server as http_support


class DesignatedRecipientTests(Fixture):
    def create(self, recipient='b', *, slots=1, key='designated'):
        return self.a.create_packet('room', ASSET, 30, slots,
                                    expires_at=100, now=1, key=key, recipient=recipient)

    def test_only_designated_current_member_can_claim(self):
        packet = self.create()
        self.assertEqual(packet['recipient'], 'b')
        for actor in ['a', 'c', 'outsider']:
            with self.subTest(actor=actor), self.assertRaises(SandboxError):
                self.s.account(actor).claim(packet['id'], now=2)
        self.assertEqual(self.b.claim(packet['id'], now=2)['amount'], 30)
        self.assertEqual(self.b.balance(ASSET)['available'], 30)
        self.conserved()

    def test_invalid_recipient_or_slots_has_no_debit(self):
        for recipient, slots in [('a', 1), ('outsider', 1), ('b', 2), ('', 1), (True, 1), (['b'], 1)]:
            with self.subTest(recipient=recipient, slots=slots), self.assertRaises(SandboxError):
                self.create(recipient, slots=slots)
        self.assertEqual(self.a.balance(ASSET)['available'], 100)
        self.conserved()

    def test_departed_recipient_cannot_first_claim_and_later_members_cannot_substitute(self):
        packet = self.create()['id']
        self.s.set_test_members('room', ['a', 'c', 'new'])
        for actor in ['b', 'c', 'new']:
            with self.subTest(actor=actor), self.assertRaises(SandboxError):
                self.s.account(actor).claim(packet, now=2)
        self.assertEqual(self.a.refund_expired(packet, now=100)['amount'], 30)
        self.assertEqual(self.a.balance(ASSET)['available'], 100)
        self.conserved()

    def test_same_key_recipient_changes_and_group_conversion_are_rejected(self):
        original = self.create()
        self.assertEqual(self.create(), original)
        for recipient in ['c', None]:
            with self.subTest(recipient=recipient), self.assertRaises(SandboxError):
                self.create(recipient)
        self.assertEqual(self.a.balance(ASSET)['available'], 70)
        self.conserved()

    def test_duplicate_concurrent_claims_credit_once_and_historical_replay_does_not_credit(self):
        packet = self.create()['id']
        with ThreadPoolExecutor(max_workers=8) as pool:
            results = list(pool.map(lambda _: self.b.claim(packet, now=2), range(20)))
        self.assertTrue(all(item == results[0] for item in results))
        self.assertEqual(self.b.balance(ASSET)['available'], 30)
        self.s.set_test_members('room', ['a'])
        self.assertEqual(self.b.claim(packet, now=200), results[0])
        self.assertEqual(self.b.balance(ASSET)['available'], 30)
        self.assertEqual(self.a.refund_expired(packet, now=200)['amount'], 0)
        self.conserved()

    def test_concurrent_create_and_expiry_race_conserve_funds(self):
        with ThreadPoolExecutor(max_workers=8) as pool:
            receipts = list(pool.map(lambda _: self.create(), range(20)))
        self.assertTrue(all(item == receipts[0] for item in receipts))
        packet = receipts[0]['id']
        def claim():
            try:
                return self.b.claim(packet, now=99)['amount']
            except SandboxError:
                return 0
        with ThreadPoolExecutor(max_workers=2) as pool:
            claim_result = pool.submit(claim)
            refund_result = pool.submit(lambda: self.a.refund_expired(packet, now=100)['amount'])
            self.assertEqual(claim_result.result() + refund_result.result(), 30)
        self.conserved()

    def test_legacy_database_migrates_without_changing_group_packet_or_replay(self):
        original = self.a.create_packet('room', ASSET, 60, 3, expires_at=100, now=1, key='legacy')
        with sqlite3.connect(self.path) as db:
            db.execute('ALTER TABLE packets DROP COLUMN recipient')
        with ThreadPoolExecutor(max_workers=4) as pool:
            instances = list(pool.map(lambda _: Sandbox(self.path, mode=MODE, assets=[ASSET, OTHER]), range(4)))
        reopened = instances[0]
        self.assertEqual(reopened.account('a').create_packet('room', ASSET, 60, 3, expires_at=100,
                                                            now=200, key='legacy'), original)
        for actor in ['a', 'b', 'c']:
            self.assertEqual(reopened.account(actor).claim(original['id'], now=2)['amount'], 20)
        self.assertTrue(reopened.audit_test_asset(ASSET)['conserved'])
        with reopened._transaction() as db:
            self.assertIsNone(db.execute('SELECT recipient FROM packets WHERE id=?', (original['id'],)).fetchone()[0])
        packet = reopened.account('a').create_packet('room', ASSET, 30, 1, expires_at=100,
                                                     now=1, key='new-designated', recipient='b')
        self.assertEqual(reopened.account('b').claim(packet['id'], now=2)['amount'], 30)
        self.assertTrue(reopened.audit_test_asset(ASSET)['conserved'])


class DesignatedRecipientHttpTests(Fixture):
    start_server = http_support.HttpTests.start_server
    stop_server = http_support.HttpTests.stop_server
    request = http_support.HttpTests.request

    def setUp(self):
        super().setUp()
        self.now = 1
        self.start_server()
        self.server.tokens['synthetic-test-carol000'] = 'c'
        self.addCleanup(self.stop_server)

    def body(self, **overrides):
        return dict(room='room', asset=ASSET, total='30', slots='1', expiresAt='100', recipient='b', **overrides)

    def test_http_designated_eligibility_lookup_and_changed_recipient_conflict(self):
        body = self.body()
        status, created = self.request('POST', '/packets', body, key='designated')
        self.assertEqual(status, 200)
        self.assertEqual(created['recipient'], 'b')
        self.assertEqual(self.request('GET', '/requests?' + urlencode({'key': 'designated'}))[1]['receipt'], created)
        for recipient in ['c', None]:
            changed = dict(body)
            if recipient is None:
                changed.pop('recipient')
            else:
                changed['recipient'] = recipient
            self.assertEqual(self.request('POST', '/packets', changed, key='designated')[0], 409)
        route = '/packets/' + created['id'] + '/claims'
        for token in ['synthetic-test-alice000', 'synthetic-test-carol000']:
            self.assertEqual(self.request('POST', route, {}, token=token, key='claim')[0], 409)
        status, receipt = self.request('POST', route, {}, token='synthetic-test-bob00000', key='claim')
        self.assertEqual((status, receipt['amount']), (200, '30'))
        self.assertEqual(self.request('POST', route, {}, token='synthetic-test-bob00000', key='claim'), (status, receipt))
        self.conserved()

    def test_http_recipient_field_is_strict_and_no_sender_override(self):
        for value in [None, '', 1, True, ['b'], {'id': 'b'}]:
            body = self.body()
            body['recipient'] = value
            with self.subTest(value=value):
                self.assertEqual(self.request('POST', '/packets', body)[0], 400)
        for field in ['sender', 'recipientId', 'account']:
            body = self.body()
            body[field] = 'a'
            self.assertEqual(self.request('POST', '/packets', body)[0], 400)
        for recipient, slots in [('a', '1'), ('outsider', '1'), ('b', '2')]:
            body = self.body()
            body.update(recipient=recipient, slots=slots)
            self.assertEqual(self.request('POST', '/packets', body, key=recipient + slots)[0], 409)
        self.assertEqual(self.a.balance(ASSET)['available'], 100)
        self.conserved()

    def test_legacy_request_lookup_and_replay_survive_database_migration(self):
        body = self.body()
        body.pop('recipient')
        body['slots'] = '3'
        status, original = self.request('POST', '/packets', body, key='legacy')
        self.assertEqual(status, 200)
        self.stop_server()
        with sqlite3.connect(self.path) as db:
            db.execute('ALTER TABLE packets DROP COLUMN recipient')
        self.s = Sandbox(self.path, mode=MODE, assets=[ASSET, OTHER])
        self.start_server()
        self.assertEqual(self.request('GET', '/requests?' + urlencode({'key': 'legacy'}))[1]['receipt'], original)
        self.assertEqual(self.request('POST', '/packets', body, key='legacy'), (200, original))
        self.conserved()

    def test_designated_receipt_lookup_does_not_match_direct_core_different_recipient(self):
        self.a.create_packet('room', ASSET, 30, 1, expires_at=100, now=1, key='collision', recipient='c')
        self.assertEqual(self.request('POST', '/packets', self.body(), key='collision')[0], 409)
        self.assertEqual(self.request('GET', '/requests?' + urlencode({'key': 'collision'}))[1]['status'], 'unresolved')
        self.conserved()

    def test_http_departure_then_owner_refund_and_restart_persists_recipient(self):
        _, created = self.request('POST', '/packets', self.body(), key='designated')
        self.stop_server()
        self.s = Sandbox(self.path, mode=MODE, assets=[ASSET, OTHER])
        self.start_server()
        self.s.set_test_members('room', ['a', 'c'])
        self.assertEqual(self.request('POST', '/packets/' + created['id'] + '/claims', {},
                                      token='synthetic-test-bob00000', key='claim')[0], 409)
        self.now = 100
        status, refund = self.request('POST', '/packets/' + created['id'] + '/refunds', {}, key='refund')
        self.assertEqual((status, refund['amount']), (200, '30'))
        self.assertEqual(self.a.balance(ASSET)['available'], 100)
        self.conserved()
