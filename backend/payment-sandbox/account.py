from common import MODE


class Account:
    """Trusted local test principal. Caller supplies no sender override per action.

    This is a Python fixture boundary, NOT authentication against malicious Python
    callers. A future HTTP layer must derive the principal from verified auth.
    """

    def __init__(self, sandbox, account_id):
        self._sandbox, self._actor = sandbox, account_id

    def balance(self, asset):
        self._sandbox._asset(asset)
        with self._sandbox._transaction() as db:
            row = db.execute('SELECT amount FROM balances WHERE account=? AND asset=?', (self._actor, asset)).fetchone()
            return {'mode': MODE, 'asset': asset, 'available': row[0] if row else 0}

    def transfer(self, *args, **kwargs):
        from transfers import transfer
        return transfer(self, *args, **kwargs)

    def create_packet(self, *args, **kwargs):
        from packet_reservations import create_packet
        return create_packet(self, *args, **kwargs)

    def claim(self, *args, **kwargs):
        from packet_claims import claim
        return claim(self, *args, **kwargs)

    def refund_expired(self, *args, **kwargs):
        from packet_refunds import refund_expired
        return refund_expired(self, *args, **kwargs)

