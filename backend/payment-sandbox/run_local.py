"""Disposable loopback fixture for the explicitly enabled debug payment UI."""
import argparse
from contextlib import contextmanager
from pathlib import Path
import signal
from tempfile import TemporaryDirectory

from common import MODE
from sandbox import Sandbox
from server import LocalPaymentServer

ASSET = 'test-usdc'
TOKENS = {
    'synthetic-test-accounta': 'a',
    'synthetic-test-accountb': 'b',
}


def port_number(value):
    try:
        result = int(value)
    except ValueError:
        raise argparse.ArgumentTypeError('port must be an integer') from None
    if not 0 <= result <= 65535:
        raise argparse.ArgumentTypeError('port must be between 0 and 65535')
    return result


@contextmanager
def local_fixture(port=8765):
    """Own the disposable database and bound listener for one local run."""
    with TemporaryDirectory(prefix='n42-local-payment-') as directory:
        sandbox = Sandbox(Path(directory) / 'ledger.sqlite', mode=MODE, assets=[ASSET])
        for account in ('a', 'b'):
            sandbox.seed_test_funds(account, ASSET, 100_000_000, key='launcher-seed')
        sandbox.set_test_members('test-room', ['a', 'b'])
        server = LocalPaymentServer(sandbox, mode=MODE, tokens=TOKENS, port=port)
        try:
            yield server
        finally:
            # serve_forever has already unwound before this context exits.
            # Calling shutdown from its own serving thread would deadlock.
            server.server_close()


def main(argv=None):
    parser = argparse.ArgumentParser(description='LOCAL SIMULATION: disposable synthetic funds only')
    parser.add_argument('--port', type=port_number, default=8765,
                        help='loopback port, default 8765; 0 selects an ephemeral port')
    args = parser.parse_args(argv)
    with local_fixture(args.port) as server:
        print('LOCAL SIMULATION — synthetic funds only; temporary data is deleted on exit.', flush=True)
        print(f'Endpoint: http://127.0.0.1:{server.server_port}', flush=True)
        print('Asset: test-usdc; seed: 100000000 integer minor units per test account; room: test-room', flush=True)
        print('Test account a: synthetic-test-accounta', flush=True)
        print('Test account b: synthetic-test-accountb', flush=True)
        print('Ctrl+C to stop. These public fixture tokens are not real credentials.', flush=True)
        # Also allow a test harness/process supervisor to terminate cleanly.
        previous = signal.getsignal(signal.SIGTERM)
        def terminate(_signum, _frame):
            raise KeyboardInterrupt
        signal.signal(signal.SIGTERM, terminate)
        try:
            server.serve_forever(poll_interval=0.1)
        except KeyboardInterrupt:
            print('LOCAL SIMULATION stopped; deleting temporary ledger.', flush=True)
        finally:
            signal.signal(signal.SIGTERM, previous)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
