"""Trusted local chain-observation fixture. Not an RPC/webhook authenticator.

The host supplies canonicality from an independent chain reader. A callback
alone is never proof of payment. Deep reorgs freeze further financial transitions
for reconciliation; they do not trigger a second charge or automatic refund.
"""
from common import SandboxError, identifier, timestamp, stable_id


class MerchantFinality:
    def __init__(self, merchant, *, chain, contract, confirmations=3):
        if type(confirmations) is not int or confirmations < 1:
            raise SandboxError('invalid finality threshold')
        self.m, self.chain, self.contract = merchant, identifier(chain), identifier(contract)
        self.confirmations = confirmations
        with merchant.s._transaction() as db:
            db.execute('''CREATE TABLE IF NOT EXISTS merchant_observations (
                event TEXT PRIMARY KEY, order_id TEXT, block TEXT, height INTEGER,
                status TEXT, chain TEXT, contract TEXT)''')

    def observe(self, event, order, *, chain, contract, block, height, head, canonical, now):
        identifier(event), identifier(order), identifier(block)
        timestamp(height), timestamp(head), timestamp(now)
        if type(canonical) is not bool or chain != self.chain or contract != self.contract or head < height:
            raise SandboxError('untrusted event domain or height')
        with self.m.s._transaction() as db:
            row = db.execute('SELECT * FROM merchant_orders WHERE id=?', (order,)).fetchone()
            if row is None or row['merchant'] != self.m.actor:
                raise SandboxError('merchant authorization required')
            if db.execute('SELECT 1 FROM merchant_reconciliation WHERE order_id=?', (order,)).fetchone():
                return 'reconciliation_required'
            previous = db.execute('SELECT * FROM merchant_observations WHERE event=?', (event,)).fetchone()
            if previous and (previous['order_id'] != order or previous['chain'] != chain or previous['contract'] != contract):
                raise SandboxError('event identity collision')
            if previous and previous['status'] == 'finalized':
                if not canonical or block != previous['block']:
                    db.execute('INSERT OR REPLACE INTO merchant_reconciliation VALUES (?,?)',
                               (order, 'finalized event removed or moved'))
                    return 'reconciliation_required'
                return 'finalized'
            if previous and previous['block'] == block and previous['height'] != height:
                raise SandboxError('inconsistent block height')
            status = 'observed' if canonical else 'removed'
            db.execute('INSERT OR REPLACE INTO merchant_observations VALUES (?,?,?,?,?,?,?)',
                       (event, order, block, height, status, chain, contract))
            if canonical and head - height + 1 >= self.confirmations:
                key = 'chain-capture:' + event
                op = stable_id('merchant-action', self.m.actor, key)
                self.m._transition(db, order, 'capture', now, op, [order, 'capture'])
                db.execute("UPDATE merchant_observations SET status='finalized' WHERE event=?", (event,))
                return 'finalized'
            return status
