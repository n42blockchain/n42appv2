from concurrent.futures import ThreadPoolExecutor
from test_support import *

class ClaimTests(Fixture):
    def test_snapshot_and_current_membership(self):
        packet = self.packet()
        self.s.set_test_members('room', ['a', 'c', 'new'])
        for name in ['b', 'new', 'outsider']:
            with self.subTest(name=name), self.assertRaises(SandboxError):
                self.s.account(name).claim(packet, now=2)
        self.s.set_test_members('room', ['a', 'b', 'c'])
        self.assertEqual(self.b.claim(packet, now=2)['amount'], 20)
        self.conserved()

    def test_duplicate_claim_concurrent(self):
        packet = self.packet()
        with ThreadPoolExecutor(max_workers=8) as pool:
            results = list(pool.map(lambda _: self.b.claim(packet, now=2), range(20)))
        self.assertTrue(all(r == results[0] for r in results))
        self.assertEqual(self.b.balance(ASSET)['available'], 20)
        self.s.set_test_members('room', ['a'])
        self.assertEqual(self.b.claim(packet, now=1000), results[0])
        self.conserved()

    def test_concurrent_exhaustion(self):
        people = ['a'] + ['member' + str(i) for i in range(20)]
        self.s.set_test_members('room', people)
        packet = self.packet(total=60, slots=3)
        def claim(name):
            try:
                return self.s.account(name).claim(packet, now=2)['amount']
            except SandboxError:
                return 0
        with ThreadPoolExecutor(max_workers=8) as pool:
            self.assertEqual(sum(pool.map(claim, people)), 60)
        self.conserved()
