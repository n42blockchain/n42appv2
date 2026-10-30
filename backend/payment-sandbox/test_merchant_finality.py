from test_support import Fixture, ASSET, SandboxError
from merchant import MerchantPayments
from merchant_finality import MerchantFinality

class MerchantFinalityTests(Fixture):
    def setUp(self):
        super().setUp()
        self.buyer, self.shop = MerchantPayments(self.s, 'a'), MerchantPayments(self.s, 'b')
        self.order = self.buyer.authorize('b', ASSET, 10, expires=100, now=1, key='order')['id']
        self.f = MerchantFinality(self.shop, chain='test-31337', contract='fixture-contract')
    def observe(self, **kwargs):
        args = dict(chain='test-31337', contract='fixture-contract', block='block-a',
                    height=10, head=10, canonical=True, now=2)
        args.update(kwargs)
        return self.f.observe('event', self.order, **args)
    def test_pre_finality_reorg_and_new_branch(self):
        self.assertEqual(self.observe(), 'observed')
        self.assertEqual(self.observe(canonical=False), 'removed')
        self.assertEqual(self.shop.query(self.order)['status'], 'authorized')
        self.assertEqual(self.observe(block='block-b', head=12), 'finalized')
        self.assertEqual(self.observe(block='block-b', head=12), 'finalized')
        self.assertEqual(self.shop.query(self.order)['status'], 'captured')
        self.conserved()
    def test_deep_reorg_freezes_instead_of_recharging(self):
        self.observe(head=12)
        self.assertEqual(self.observe(head=12, canonical=False), 'reconciliation_required')
        with self.assertRaises(SandboxError): self.shop.transition(self.order, 'refund', now=3, key='refund')
        self.assertEqual(self.shop.query(self.order)['status'], 'captured')
        self.conserved()
    def test_wrong_chain_cannot_finalize(self):
        with self.assertRaises(SandboxError): self.observe(chain='mainnet', head=12)
        self.assertEqual(self.shop.query(self.order)['status'], 'authorized')
