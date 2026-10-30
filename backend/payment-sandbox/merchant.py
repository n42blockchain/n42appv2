"""Local merchant lifecycle PoC. No chain, operator credentials or real funds.

Construct capabilities only in the trusted fixture host. Webhooks are an
at-least-once outbox; consumers must deduplicate event IDs. Reorgs require an
external finality adapter and cannot be inferred from an unauthenticated callback.
"""
import json
from common import MODE, SandboxError, identifier, units, timestamp, stable_id


class MerchantPayments:
    def __init__(self, sandbox, actor):
        self.s = sandbox
        self.actor = identifier(actor)
        with sandbox._transaction() as db:
            db.execute('''CREATE TABLE IF NOT EXISTS merchant_orders (
                id TEXT PRIMARY KEY, buyer TEXT, merchant TEXT, asset TEXT,
                amount INTEGER, expires INTEGER, status TEXT, sponsor TEXT,
                fee_asset TEXT, fee INTEGER, revision INTEGER)''')
            db.execute('CREATE TABLE IF NOT EXISTS merchant_reconciliation (order_id TEXT PRIMARY KEY, reason TEXT)')
            db.execute('''CREATE TABLE IF NOT EXISTS merchant_outbox (
                id TEXT PRIMARY KEY, merchant TEXT, body TEXT, ack INTEGER DEFAULT 0)''')

    def _event(self, db, row):
        event = {'order': row['id'], 'revision': row['revision'],
                 'status': row['status'], 'mode': MODE}
        event_id = stable_id('merchant-event', row['id'], str(row['revision']))
        db.execute('INSERT INTO merchant_outbox(id,merchant,body) VALUES (?,?,?)',
                   (event_id, row['merchant'], json.dumps(event)))

    def authorize(self, merchant, asset, amount, *, expires, now, key):
        identifier(merchant), self.s._asset(asset), units(amount)
        timestamp(expires), timestamp(now), identifier(key)
        if expires <= now or merchant == self.actor:
            raise SandboxError('invalid authorization')
        order = stable_id('merchant-order', self.actor, key)
        request = [merchant, asset, amount, expires]
        with self.s._transaction() as db:
            prior = self.s._replay(db, order, request)
            if prior is not None:
                return prior
            self.s._credit(db, self.actor, asset, -amount)
            # Escrow uses a separate ledger bucket, never an account capability.
            self.s._move(db, order, asset, 'account:' + self.actor, 'merchant-escrow:' + order, amount)
            db.execute('INSERT INTO merchant_orders VALUES (?,?,?,?,?,?,?,?,?,?,?)',
                       (order, self.actor, merchant, asset, amount, expires,
                        'authorized', None, None, 0, 0))
            row = dict(db.execute('SELECT * FROM merchant_orders WHERE id=?', (order,)).fetchone())
            self._event(db, row)
            return self.s._save(db, order, 'merchant-authorize', self.actor, request, row)

    def sponsor(self, order, fee_asset, fee, *, key):
        """Sponsor itself funds the immutable fee reservation, not the buyer."""
        identifier(order), self.s._asset(fee_asset), units(fee), identifier(key)
        op = stable_id('merchant-sponsor', self.actor, key)
        request = [order, fee_asset, fee]
        with self.s._transaction() as db:
            prior = self.s._replay(db, op, request)
            if prior is not None:
                return prior
            row = db.execute('SELECT * FROM merchant_orders WHERE id=?', (order,)).fetchone()
            if row is None or row['status'] != 'authorized' or row['sponsor'] is not None:
                raise SandboxError('order cannot be sponsored')
            self.s._credit(db, self.actor, fee_asset, -fee)
            self.s._move(db, op, fee_asset, 'account:' + self.actor, 'merchant-fee:' + order, fee)
            db.execute('UPDATE merchant_orders SET sponsor=?,fee_asset=?,fee=? WHERE id=?',
                       (self.actor, fee_asset, fee, order))
            return self.s._save(db, op, 'merchant-sponsor', self.actor, request, {'order': order})

    def transition(self, order, action, *, now, key):
        identifier(order), identifier(key), timestamp(now)
        if action not in ('capture', 'void', 'refund', 'expire'):
            raise SandboxError('unknown action')
        op = stable_id('merchant-action', self.actor, key)
        request = [order, action]
        with self.s._transaction() as db:
            return self._transition(db, order, action, now, op, request)

    def _transition(self, db, order, action, now, op, request):
        prior = self.s._replay(db, op, request)
        if prior is not None:
            return prior
        if db.execute('SELECT 1 FROM merchant_reconciliation WHERE order_id=?', (order,)).fetchone():
            raise SandboxError('order requires reconciliation after deep reorg')
        raw = db.execute('SELECT * FROM merchant_orders WHERE id=?', (order,)).fetchone()
        if raw is None or self.actor not in (raw['buyer'], raw['merchant']):
            raise SandboxError('order unavailable')
        row = dict(raw)
        if action in ('capture', 'refund') and self.actor != row['merchant']:
            raise SandboxError('merchant authorization required')
        expected = 'captured' if action == 'refund' else 'authorized'
        if row['status'] != expected:
            raise SandboxError('invalid transition')
        if action == 'capture' and now >= row['expires']:
            raise SandboxError('authorization expired')
        if action == 'expire' and now < row['expires']:
            raise SandboxError('not expired')
        destination = row['merchant'] if action == 'capture' else row['buyer']
        source = 'merchant-escrow:' + order
        if action == 'refund':
            self.s._credit(db, row['merchant'], row['asset'], -row['amount'])
            source = 'account:' + row['merchant']
        self.s._credit(db, destination, row['asset'], row['amount'])
        self.s._move(db, op, row['asset'], source, 'account:' + destination, row['amount'])
        if row['sponsor'] and action != 'refund':
            # Synthetic network fee collector; no claim of gas sponsorship on-chain.
            fee_to = 'simulation-network-fees' if action == 'capture' else row['sponsor']
            self.s._credit(db, fee_to, row['fee_asset'], row['fee'])
            self.s._move(db, op, row['fee_asset'], 'merchant-fee:' + order,
                         'account:' + fee_to, row['fee'])
        row['status'] = {'capture': 'captured', 'void': 'voided',
                         'refund': 'refunded', 'expire': 'expired'}[action]
        row['revision'] += 1
        db.execute('UPDATE merchant_orders SET status=?,revision=? WHERE id=?',
                   (row['status'], row['revision'], order))
        self._event(db, row)
        return self.s._save(db, op, 'merchant-' + action, self.actor, request,
                            {'order': order, 'status': row['status'], 'revision': row['revision']})

    def query(self, order):
        identifier(order)
        with self.s._transaction() as db:
            row = db.execute('SELECT * FROM merchant_orders WHERE id=?', (order,)).fetchone()
            if row is None or self.actor not in (row['buyer'], row['merchant'], row['sponsor']):
                raise SandboxError('order unavailable')
            pending = db.execute('SELECT 1 FROM merchant_reconciliation WHERE order_id=?', (order,)).fetchone()
            return dict(row, mode=MODE, reconciliationRequired=pending is not None)

    def pending_events(self):
        with self.s._transaction() as db:
            return [dict(r) for r in db.execute(
                'SELECT * FROM merchant_outbox WHERE merchant=? AND ack=0 ORDER BY rowid', (self.actor,))]

    def ack(self, event_id):
        identifier(event_id)
        with self.s._transaction() as db:
            result = db.execute('UPDATE merchant_outbox SET ack=1 WHERE id=? AND merchant=?',
                                (event_id, self.actor))
            if result.rowcount != 1:
                raise SandboxError('event unavailable')
