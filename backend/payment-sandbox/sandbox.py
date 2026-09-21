"""Local-only deterministic test ledger. No HTTP, providers, or real funds."""
from contextlib import contextmanager
import json
from common import MODE, MAX_UNITS, SandboxError, identifier, units, stable_id
import sqlite3

class Sandbox:
    """Privileged local fixture owner. Never expose this object to clients."""

    def __init__(self, path, *, mode, assets):
        if mode != MODE:
            raise SandboxError('only explicit localSimulation mode is supported')
        if str(path) == ':memory:':
            raise SandboxError('use a local SQLite file for cross-connection transactions')
        self.assets = frozenset(identifier(a) for a in assets)
        if not self.assets:
            raise SandboxError('explicit test asset registry required')
        self.path = str(path)
        with self._transaction() as db:
            db.executescript('''
                CREATE TABLE IF NOT EXISTS balances (
                    account TEXT, asset TEXT, amount INTEGER NOT NULL CHECK(amount >= 0),
                    PRIMARY KEY(account, asset));
                CREATE TABLE IF NOT EXISTS operations (
                    id TEXT PRIMARY KEY, kind TEXT, actor TEXT, request TEXT, result TEXT);
                CREATE TABLE IF NOT EXISTS members (
                    room TEXT, account TEXT, PRIMARY KEY(room, account));
                CREATE TABLE IF NOT EXISTS packets (
                    id TEXT PRIMARY KEY, owner TEXT, room TEXT, asset TEXT,
                    share INTEGER NOT NULL, slots INTEGER NOT NULL,
                    remaining INTEGER NOT NULL CHECK(remaining >= 0),
                    expires INTEGER NOT NULL, refunded INTEGER NOT NULL DEFAULT 0,
                    recipient TEXT);
                CREATE TABLE IF NOT EXISTS eligible (
                    packet TEXT, account TEXT, PRIMARY KEY(packet, account));
                CREATE TABLE IF NOT EXISTS claims (
                    packet TEXT, account TEXT, amount INTEGER NOT NULL,
                    PRIMARY KEY(packet, account));
                CREATE TABLE IF NOT EXISTS ledger (
                    operation TEXT, bucket TEXT, asset TEXT, delta INTEGER NOT NULL);
            ''')
            # executescript ends the initial transaction. Acquire a fresh write
            # lock before inspecting/migrating, including concurrent restarts.
            db.execute('BEGIN IMMEDIATE')
            columns = {row['name'] for row in db.execute('PRAGMA table_info(packets)')}
            if 'recipient' not in columns:
                db.execute('ALTER TABLE packets ADD COLUMN recipient TEXT')

    @contextmanager
    def _transaction(self):
        db = sqlite3.connect(self.path, timeout=30, isolation_level=None)
        db.row_factory = sqlite3.Row
        try:
            db.execute('BEGIN IMMEDIATE')
            yield db
            db.commit()
        except BaseException:
            db.rollback()
            raise
        finally:
            db.close()

    def _asset(self, asset):
        identifier(asset)
        if asset not in self.assets:
            raise SandboxError('asset is not in the local test registry')
        return asset

    def account(self, account_id):
        from account import Account
        return Account(self, identifier(account_id))

    def set_test_members(self, room, accounts):
        identifier(room)
        accounts = sorted({identifier(a) for a in accounts})
        with self._transaction() as db:
            db.execute('DELETE FROM members WHERE room=?', (room,))
            db.executemany('INSERT INTO members VALUES (?,?)', [(room, a) for a in accounts])

    def seed_test_funds(self, account, asset, amount, *, key):
        """Explicit synthetic issuance; repeated seed keys never mint twice."""
        identifier(account), self._asset(asset), identifier(key), units(amount)
        request = [account, asset, amount]
        op = stable_id('seed', account, key)
        with self._transaction() as db:
            prior = self._replay(db, op, request)
            if prior is not None:
                return prior
            issued = -db.execute(
                'SELECT COALESCE(SUM(delta),0) FROM ledger WHERE bucket=? AND asset=?',
                ('test-issuance', asset)).fetchone()[0]
            if issued + amount > MAX_UNITS:
                raise SandboxError('test asset supply limit exceeded')
            self._move(db, op, asset, 'test-issuance', 'account:' + account, amount)
            self._credit(db, account, asset, amount)
            return self._save(db, op, 'seed', account, request, {'amount': amount, 'asset': asset})

    @staticmethod
    def _credit(db, account, asset, delta):
        db.execute('INSERT INTO balances VALUES (?,?,0) ON CONFLICT DO NOTHING', (account, asset))
        row = db.execute('SELECT amount FROM balances WHERE account=? AND asset=?', (account, asset)).fetchone()
        if not 0 <= row[0] + delta <= MAX_UNITS:
            raise SandboxError('insufficient balance or amount limit')
        db.execute('UPDATE balances SET amount=amount+? WHERE account=? AND asset=?', (delta, account, asset))

    @staticmethod
    def _move(db, operation, asset, source, destination, amount):
        db.executemany('INSERT INTO ledger VALUES (?,?,?,?)', [
            (operation, source, asset, -amount), (operation, destination, asset, amount)])

    @staticmethod
    def _replay(db, op, request):
        row = db.execute('SELECT request,result FROM operations WHERE id=?', (op,)).fetchone()
        if row is None:
            return None
        if json.loads(row['request']) != request:
            raise SandboxError('idempotency key reused with different parameters')
        return json.loads(row['result'])

    @staticmethod
    def _save(db, op, kind, actor, request, result):
        result = dict(result, id=op, mode=MODE)
        db.execute('INSERT INTO operations VALUES (?,?,?,?,?)',
                   (op, kind, actor, json.dumps(request), json.dumps(result)))
        return result

    def audit_test_asset(self, asset):
        """Privileged fixture assertion; not an account-facing API."""
        self._asset(asset)
        with self._transaction() as db:
            available = db.execute('SELECT COALESCE(SUM(amount),0) FROM balances WHERE asset=?', (asset,)).fetchone()[0]
            reserved = db.execute('SELECT COALESCE(SUM(remaining),0) FROM packets WHERE asset=?', (asset,)).fetchone()[0]
            issued = -db.execute('SELECT COALESCE(SUM(delta),0) FROM ledger WHERE bucket=? AND asset=?', ('test-issuance', asset)).fetchone()[0]
            net = db.execute('SELECT COALESCE(SUM(delta),0) FROM ledger WHERE asset=?', (asset,)).fetchone()[0]
            return {'mode': MODE, 'available': available, 'reserved': reserved, 'issued': issued,
                    'conserved': available + reserved == issued and net == 0}


