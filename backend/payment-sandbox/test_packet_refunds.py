from concurrent.futures import ThreadPoolExecutor
from test_support import *

class RefundTests(Fixture):
    def test_expiry_exact_remaining_and_replay(self):
        packet = self.packet()
        self.b.claim(packet, now=99)
        with self.assertRaises(SandboxError):
            self.a.refund_expired(packet, now=99)
        with self.assertRaises(SandboxError):
            self.b.refund_expired(packet, now=100)
        result = self.a.refund_expired(packet, now=100)
        self.assertEqual(result['amount'], 40)
        self.assertEqual(self.a.refund_expired(packet, now=200), result)
        with self.assertRaises(SandboxError):
            self.s.account('c').claim(packet, now=100)
        self.assertEqual(self.a.balance(ASSET)['available'], 80)
        self.conserved()

    def test_concurrent_refunds_and_expired_claims(self):
        packet = self.packet()
        def action(i):
            try:
                return self.a.refund_expired(packet, now=100) if i % 2 else self.b.claim(packet, now=100)
            except SandboxError:
                return None
        with ThreadPoolExecutor(max_workers=8) as pool:
            list(pool.map(action, range(20)))
        self.assertEqual(self.a.balance(ASSET)['available'], 100)
        self.assertEqual(self.b.balance(ASSET)['available'], 0)
        self.conserved()
