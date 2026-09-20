from concurrent.futures import ThreadPoolExecutor
from test_support import *

class TransferTests(Fixture):
    def test_idempotent_and_actor_scoped(self):
        receipt = self.a.transfer('b', ASSET, 30, key='t')
        self.assertEqual(receipt, self.a.transfer('b', ASSET, 30, key='t'))
        with self.assertRaises(SandboxError):
            self.a.transfer('c', ASSET, 30, key='t')
        self.b.transfer('a', ASSET, 10, key='t')
        self.assertEqual(self.a.balance(ASSET)['available'], 80)
        self.conserved()

    def test_rollback_insufficient_funds(self):
        with self.assertRaises(SandboxError):
            self.a.transfer('b', ASSET, 101, key='t')
        self.assertEqual(self.b.balance(ASSET)['available'], 0)
        self.conserved()

    def test_concurrent_replay_and_no_overspend(self):
        with ThreadPoolExecutor(max_workers=8) as pool:
            receipts = list(pool.map(lambda _: self.a.transfer('b', ASSET, 70, key='same'), range(16)))
        self.assertTrue(all(r == receipts[0] for r in receipts))
        def send(i):
            try:
                self.a.transfer('b', ASSET, 20, key=str(i))
                return 1
            except SandboxError:
                return 0
        with ThreadPoolExecutor(max_workers=8) as pool:
            self.assertEqual(sum(pool.map(send, range(16))), 1)
        self.assertEqual(self.b.balance(ASSET)['available'], 90)
        self.conserved()
