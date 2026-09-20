from common import MODE, SandboxError, identifier, units, timestamp, stable_id


def create_packet(self, room, asset, total, slots, *, expires_at, now, key):
    identifier(room), self._sandbox._asset(asset), identifier(key), units(total), units(slots)
    timestamp(now), timestamp(expires_at)
    s = self._sandbox
    op = stable_id('packet', self._actor, key)
    request = [room, asset, total, slots, expires_at]
    with s._transaction() as db:
        prior = s._replay(db, op, request)
        if prior is not None:
            return prior
        if total % slots or expires_at <= now:
            raise SandboxError('equal shares must divide exactly and expire in the future')
        members = [r[0] for r in db.execute('SELECT account FROM members WHERE room=? ORDER BY account', (room,))]
        if self._actor not in members or len(members) < slots:
            raise SandboxError('sender must be a member and slots must fit snapshot')
        s._credit(db, self._actor, asset, -total)
        db.execute('INSERT INTO packets VALUES (?,?,?,?,?,?,?, ?,0)',
                   (op, self._actor, room, asset, total // slots, slots, total, expires_at))
        db.executemany('INSERT INTO eligible VALUES (?,?)', [(op, a) for a in members])
        s._move(db, op, asset, 'account:' + self._actor, 'packet:' + op, total)
        return s._save(db, op, 'packet', self._actor, request,
                       {'asset': asset, 'total': total, 'slots': slots, 'expiresAt': expires_at})

