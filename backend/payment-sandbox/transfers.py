from common import MODE, SandboxError, identifier, units, timestamp, stable_id


def transfer(self, recipient, asset, amount, *, key):
    identifier(recipient), self._sandbox._asset(asset), identifier(key), units(amount)
    if recipient == self._actor:
        raise SandboxError('self transfer is not supported')
    s = self._sandbox
    op = stable_id('transfer', self._actor, key)
    request = [recipient, asset, amount]
    with s._transaction() as db:
        prior = s._replay(db, op, request)
        if prior is not None:
            return prior
        s._credit(db, self._actor, asset, -amount)
        s._credit(db, recipient, asset, amount)
        s._move(db, op, asset, 'account:' + self._actor, 'account:' + recipient, amount)
        return s._save(db, op, 'transfer', self._actor, request,
                       {'recipient': recipient, 'asset': asset, 'amount': amount})

