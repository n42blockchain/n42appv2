from concurrent.futures import ThreadPoolExecutor
from unittest.mock import patch
from test_support import Fixture, ASSET, OTHER, MODE, SandboxError
from sandbox import Sandbox
from merchant import MerchantPayments


class MerchantTests(Fixture):
    def setUp(self):
        super().setUp()
        self.buyer = MerchantPayments(self.s, 'a')
        self.shop = MerchantPayments(self.s, 'b')
        self.sponsor = MerchantPayments(self.s, 'sponsor')
        self.s.seed_test_funds('sponsor', OTHER, 10000, key='gas')

    def order(self, key='a'):
        return self.buyer.authorize('b', ASSET, 10, expires=100, now=1, key=key)['id']

    def test_lifecycle_sponsorship_restart_and_outbox(self):
        order = self.order()
        self.sponsor.sponsor(order, OTHER, 2, key='fee')
        self.conserved()
        result = self.shop.transition(order, 'capture', now=2, key='capture')
        self.assertEqual(result, self.shop.transition(order, 'capture', now=200, key='capture'))
        restarted = MerchantPayments(Sandbox(self.path, mode=MODE, assets=[ASSET, OTHER]), 'b')
        self.assertEqual(restarted.query(order)['status'], 'captured')
        restarted.transition(order, 'refund', now=3, key='refund')
        events = restarted.pending_events()
        self.assertEqual(len(events), 3)
        for event in reversed(events):
            restarted.ack(event['id']); restarted.ack(event['id'])
        self.assertEqual(restarted.pending_events(), [])
        self.conserved()
        self.assertTrue(self.s.audit_test_asset(OTHER)['conserved'])

    def test_roles_expiry_and_parameter_collision(self):
        order = self.order()
        with self.assertRaises(SandboxError): self.buyer.transition(order, 'capture', now=2, key='bad')
        with self.assertRaises(SandboxError): self.sponsor.query('missing')
        with self.assertRaises(SandboxError): self.shop.transition(order, 'capture', now=100, key='late')
        with self.assertRaises(SandboxError): self.buyer.authorize('b', ASSET, 11, expires=100, now=1, key='a')
        self.buyer.transition(order, 'expire', now=100, key='expiry')
        with self.assertRaises(SandboxError): self.shop.transition(order, 'capture', now=2, key='rewind')
        self.conserved()

    def test_concurrent_capture_void_exactly_one_transition(self):
        order = self.order()
        def execute(action):
            try:
                self.shop.transition(order, action, now=2, key=action)
                return True
            except SandboxError: return False
        with ThreadPoolExecutor(2) as pool:
            self.assertEqual(sum(pool.map(execute, ['capture', 'void'])), 1)
        self.conserved()

    def test_1000_fault_injected_orders(self):
        # A local SQLite fault campaign, not a chain or payment-provider benchmark.
        self.s.seed_test_funds('a', ASSET, 10000, key='campaign')
        for i in range(1000):
            order = self.order(str(i))
            action = ['capture', 'void', 'expire'][i % 3]
            now = 100 if action == 'expire' else 2
            if i % 5 == 0:
                # Failure after ledger mutation, before commit: all effects roll back.
                with patch.object(self.shop, '_event', side_effect=RuntimeError('crash')):
                    with self.assertRaises(RuntimeError):
                        self.shop.transition(order, action, now=now, key=str(i))
                self.assertEqual(self.shop.query(order)['status'], 'authorized')
            result = self.shop.transition(order, action, now=now, key=str(i))
            # Lost response after commit, process restart, exact retry.
            restarted = MerchantPayments(Sandbox(self.path, mode=MODE, assets=[ASSET, OTHER]), 'b')
            self.assertEqual(result, restarted.transition(order, action, now=now, key=str(i)))
            if action == 'capture':
                r = restarted.transition(order, 'refund', now=3, key='refund-' + str(i))
                self.assertEqual(r, restarted.transition(order, 'refund', now=3, key='refund-' + str(i)))
            self.conserved()
        events = self.shop.pending_events()
        self.assertEqual(len({e['id'] for e in events}), len(events))
