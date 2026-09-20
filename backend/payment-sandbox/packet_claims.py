from common import MODE, SandboxError, identifier, units, timestamp, stable_id


def claim(self, packet_id, *, now):
    identifier(packet_id), timestamp(now)
    s = self._sandbox
    with s._transaction() as db:
        packet = db.execute('SELECT * FROM packets WHERE id=?', (packet_id,)).fetchone()
        if packet is None:
            raise SandboxError('packet unavailable')
        claim = db.execute('SELECT amount FROM claims WHERE packet=? AND account=?', (packet_id, self._actor)).fetchone()
        # A replay returns the original receipt even after departure/expiry.
        if claim:
            return {'mode': MODE, 'packet': packet_id, 'asset': packet['asset'], 'amount': claim[0]}
        eligible = db.execute('SELECT 1 FROM eligible WHERE packet=? AND account=?', (packet_id, self._actor)).fetchone()
        current = db.execute('SELECT 1 FROM members WHERE room=? AND account=?', (packet['room'], self._actor)).fetchone()
        if not eligible or not current or now >= packet['expires'] or packet['refunded'] or packet['remaining'] < packet['share']:
            raise SandboxError('packet unavailable')
        amount = packet['share']
        db.execute('INSERT INTO claims VALUES (?,?,?)', (packet_id, self._actor, amount))
        db.execute('UPDATE packets SET remaining=remaining-? WHERE id=?', (amount, packet_id))
        s._credit(db, self._actor, packet['asset'], amount)
        s._move(db, stable_id('claim', packet_id, self._actor), packet['asset'],
                'packet:' + packet_id, 'account:' + self._actor, amount)
        return {'mode': MODE, 'packet': packet_id, 'asset': packet['asset'], 'amount': amount}

