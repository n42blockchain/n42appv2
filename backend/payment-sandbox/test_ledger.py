from test_support import *

class LedgerTests(Fixture):
    def test_mode_and_asset_fail_closed(self):
        with self.assertRaises(SandboxError):
            Sandbox(self.path, mode='production', assets=[ASSET])
        with self.assertRaises(SandboxError):
            self.a.balance('USD')

    def test_account_and_asset_isolation(self):
        self.assertEqual(self.a.balance(ASSET)['available'], 100)
        self.assertEqual(self.b.balance(ASSET)['available'], 0)
        self.assertEqual(self.a.balance(OTHER)['available'], 0)
        self.conserved()

    def test_seed_idempotency(self):
        self.s.seed_test_funds('a', ASSET, 100, key='seed')
        with self.assertRaises(SandboxError):
            self.s.seed_test_funds('a', ASSET, 101, key='seed')
        self.assertEqual(self.a.balance(ASSET)['available'], 100)

    def test_integer_bounds(self):
        for amount in [True, False, 1.0, '1', 0, -1, MAX_UNITS + 1, 2**63]:
            with self.subTest(amount=amount), self.assertRaises(SandboxError):
                self.s.seed_test_funds('a', ASSET, amount, key='invalid')
        self.s.seed_test_funds('a', ASSET, MAX_UNITS - 100, key='max')
        with self.assertRaises(SandboxError):
            self.s.seed_test_funds('b', ASSET, 1, key='overflow')
        self.conserved()

    def test_restart_preserves_state(self):
        restored = Sandbox(self.path, mode=MODE, assets=[ASSET, OTHER])
        self.assertEqual(restored.account('a').balance(ASSET)['available'], 100)
