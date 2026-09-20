from common import MODE, SandboxError, identifier, units, timestamp, stable_id


def refund_expired(self, packet_id, *, now):
    identifier(packet_id), timestamp(now)
    s = self._sandbox
    op = stable_id('refund', self._actor, packet_id)
    with s._transaction() as db:
        packet = db.execute('SELECT * FROM packets WHERE id=? AND owner=?', (packet_id, self._actor)).fetchone()
        if packet is None:
            raise SandboxError('packet unavailable')
        prior = s._replay(db, op, [packet_id])
        if prior is not None:
            return prior
        if now < packet['expires']:
            raise SandboxError('packet has not expired')
        amount = packet['remaining']
        s._credit(db, self._actor, packet['asset'], amount)
        db.execute('UPDATE packets SET remaining=0,refunded=1 WHERE id=?', (packet_id,))
        s._move(db, op, packet['asset'], 'packet:' + packet_id, 'account:' + self._actor, amount)
        return s._save(db, op, 'refund', self._actor, [packet_id], {'asset': packet['asset'], 'amount': amount})
