#!/usr/bin/env python3
"""Exercise both SQLCipher images in a built macOS app using synthetic files."""
import ctypes
import hashlib
import json
from pathlib import Path
import shutil
import sys
import tempfile


class Database:
    def __init__(self, library, path):
        self.lib = library
        self.handle = ctypes.c_void_p()
        assert library.sqlite3_open_v2(str(path).encode(), ctypes.byref(self.handle), 6, None) == 0

    def query(self, sql):
        rows = []
        callback_type = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_void_p, ctypes.c_int,
                                        ctypes.POINTER(ctypes.c_char_p), ctypes.POINTER(ctypes.c_char_p))
        @callback_type
        def callback(_, count, values, names):
            rows.append([values[i].decode() if values[i] is not None else None for i in range(count)])
            return 0
        result = self.lib.sqlite3_exec(self.handle, sql.encode(), callback, None, None)
        if result:
            raise RuntimeError(self.lib.sqlite3_errmsg(self.handle).decode())
        return rows

    def close(self):
        assert self.lib.sqlite3_close_v2(self.handle) == 0


def load(path):
    lib = ctypes.CDLL(str(path.resolve()))
    lib.sqlite3_open_v2.argtypes = [ctypes.c_char_p, ctypes.POINTER(ctypes.c_void_p), ctypes.c_int, ctypes.c_char_p]
    lib.sqlite3_exec.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p]
    lib.sqlite3_errmsg.argtypes = [ctypes.c_void_p]
    lib.sqlite3_errmsg.restype = ctypes.c_char_p
    lib.sqlite3_close_v2.argtypes = [ctypes.c_void_p]
    return lib


def main():
    app = Path(sys.argv[1])
    frameworks = app / 'Contents/Frameworks'
    images = [frameworks / 'N42SQLCipher.framework/N42SQLCipher',
              frameworks / 'sqlcipher.framework/sqlcipher']
    assert all(p.is_file() for p in images), images
    assert images[0].resolve() != images[1].resolve(), 'Providers must not collide by case'
    fixture = Path(__file__).parent / 'harness/fixtures/sqlcipher-4.10-archive.db'
    assert hashlib.sha256(fixture.read_bytes()).hexdigest() == 'cf488c02d1c00c519f5d20e57ae68b4122165b2e0d57b797bd5029242e9a5821'
    result = []
    with tempfile.TemporaryDirectory(prefix='n42-apple-sqlcipher-') as temporary:
        for index, image in enumerate(images):
            lib = load(image)
            legacy = Path(temporary) / f'legacy-{index}.db'
            shutil.copy2(fixture, legacy)
            db = Database(lib, legacy)
            version = db.query('PRAGMA cipher_version')[0][0]
            assert version.startswith('4.19.'), version
            db.query('PRAGMA key = "x\'' + 'a' * 64 + '\'"')
            assert db.query('PRAGMA integrity_check') == [['ok']]
            assert int(db.query('SELECT count(*) FROM sqlite_master')[0][0]) > 0
            db.close()
            for key in [None, 'wrong-key']:
                db = Database(lib, legacy)
                try:
                    if key:
                        db.query(f"PRAGMA key = '{key}'")
                    try:
                        db.query('SELECT * FROM sqlite_master')
                    except RuntimeError:
                        pass
                    else:
                        raise AssertionError('Incorrect/missing key accepted')
                finally:
                    db.close()
            plain = Path(temporary) / f'plain-{index}.db'
            encrypted = Path(temporary) / f'exported-{index}.db'
            db = Database(lib, plain)
            db.query("CREATE TABLE fixture (value TEXT); INSERT INTO fixture VALUES ('synthetic')")
            db.query(f"ATTACH DATABASE '{encrypted}' AS encrypted KEY 'fixture-key'")
            db.query("SELECT sqlcipher_export('encrypted')")
            db.query('DETACH DATABASE encrypted')
            db.close()
            other = load(images[1 - index])
            db = Database(other, encrypted)
            db.query("PRAGMA key = 'fixture-key'")
            assert db.query('SELECT value FROM fixture') == [['synthetic']]
            db.close()
            result.append({'path': str(image), 'sha256': hashlib.sha256(image.read_bytes()).hexdigest(),
                           'cipher_version': version, 'historical_wrong_missing_export_cross_provider': 'passed'})
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
