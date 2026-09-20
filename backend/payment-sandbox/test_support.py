from pathlib import Path
from tempfile import TemporaryDirectory
import unittest
from sandbox import Sandbox
from common import MODE, SandboxError, MAX_UNITS

ASSET = 'test-fiat:USD:minor-2'
OTHER = 'test-chain:base:usdc:minor-6'

class Fixture(unittest.TestCase):
    def setUp(self):
        self.tmp = TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.path = Path(self.tmp.name) / 'test.sqlite'
        self.s = Sandbox(self.path, mode=MODE, assets=[ASSET, OTHER])
        self.a, self.b = self.s.account('a'), self.s.account('b')
        self.s.seed_test_funds('a', ASSET, 100, key='seed')
        self.s.set_test_members('room', ['a', 'b', 'c'])

    def packet(self, total=60, slots=3):
        return self.a.create_packet('room', ASSET, total, slots, expires_at=100, now=1, key='packet')['id']

    def conserved(self):
        self.assertTrue(self.s.audit_test_asset(ASSET)['conserved'])
