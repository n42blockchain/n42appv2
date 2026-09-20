from test_support import *

class ReservationTests(Fixture):
    def test_reserve_and_replay(self):
        self.assertEqual(self.packet(), self.packet())
        audit = self.s.audit_test_asset(ASSET)
        self.assertEqual((audit['available'], audit['reserved']), (40, 60))
        with self.assertRaises(SandboxError):
            self.packet(total=90)
        self.conserved()

    def test_invalid_creation_has_no_debit(self):
        for total, slots in [(100, 3), (120, 3), (60, 4)]:
            with self.subTest(total=total, slots=slots), self.assertRaises(SandboxError):
                self.packet(total, slots)
        with self.assertRaises(SandboxError):
            self.s.account('outsider').create_packet('room', ASSET, 10, 1, now=1, expires_at=2, key='x')
        self.assertEqual(self.a.balance(ASSET)['available'], 100)
        self.conserved()

    def test_expired_creation_replay_returns_original_receipt(self):
        original = self.a.create_packet('room', ASSET, 60, 3, expires_at=100, now=1, key='packet')
        self.s.set_test_members('room', [])
        replay = self.a.create_packet('room', ASSET, 60, 3, expires_at=100, now=200, key='packet')
        self.assertEqual(replay, original)
        with self.assertRaises(SandboxError):
            self.a.create_packet('room', ASSET, 60, 3, expires_at=100, now=200, key='new')
        self.conserved()
