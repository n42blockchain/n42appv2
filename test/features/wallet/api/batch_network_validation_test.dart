import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/batch_transfer_api.dart';

void main() {
  test('compatible custom chain IDs are preserved', () async {
    final api = BatchTransferApi(
      rpcCall: (url, method, params) async => {
        'result': method == 'eth_chainId' ? '0x5e' : '0x6001',
      },
    );
    await api.validateNetwork('https://rpc.invalid', 94, 'ETH');
  });
  for (final scenario in [
    'valid',
    'wrongChain',
    'noCode',
    'zeroCode',
    'codeError',
  ]) {
    test('batch RPC validation: $scenario', () async {
      final calls = <String>[];
      final api = BatchTransferApi(
        rpcCall: (url, method, params) async {
          calls.add(method);
          if (method == 'eth_chainId') {
            return {'result': scenario == 'wrongChain' ? '0x2' : '0x1'};
          }
          expect(params.first, BatchTransferApi.multicall3Address);
          return scenario == 'codeError'
              ? {
                  'error': {'code': -1},
                }
              : {
                  'result': scenario == 'noCode'
                      ? '0x'
                      : scenario == 'zeroCode'
                      ? '0x00'
                      : '0x6001',
                };
        },
      );
      if (scenario == 'valid') {
        await api.validateNetwork('https://rpc.invalid', 1, 'ETH');
      } else {
        await expectLater(
          api.validateNetwork('https://rpc.invalid', 1, 'ETH'),
          throwsStateError,
        );
      }
      expect(
        calls,
        scenario == 'wrongChain'
            ? ['eth_chainId']
            : ['eth_chainId', 'eth_getCode'],
      );
    });
  }
}
