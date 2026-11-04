import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/batch_transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/batch_transfer_model.dart';

void main() {
  for (final scenario in [
    '1559',
    'legacy',
    'free',
    'malformed',
    'negative',
    'overflow',
  ]) {
    test('batch fee quote preserves $scenario behavior', () async {
      final api = BatchTransferApi(
        rpcCall: (url, method, params) async {
          if (method == 'eth_estimateGas') return {'result': '0x5208'};
          if (method == 'eth_feeHistory') {
            expect(params.first, '0x4');
            return scenario == '1559'
                ? {
                    'result': {
                      'baseFeePerGas': ['0x1', '0xa'],
                    },
                  }
                : {
                    'error': {'code': -32601},
                  };
          }
          expect(method, 'eth_gasPrice');
          return {
            'result': switch (scenario) {
              'free' => '0x0',
              'malformed' => '0x',
              'negative' => '-1',
              'overflow' => '0x${'1' * 65}',
              _ => '0xa',
            },
          };
        },
      );
      final quote = api.getGasEstimate(
        rpcUrl: 'https://rpc.invalid',
        chainSymbol: 'ETH',
        fromAddress: '0x${'11' * 20}',
        tokenAddress: null,
        items: [
          BatchTransferItem(
            id: '1',
            toAddress: '0x${'22' * 20}',
            amount: BigInt.one,
          ),
        ],
      );
      if (['malformed', 'negative', 'overflow'].contains(scenario)) {
        await expectLater(quote, throwsStateError);
      } else {
        final value = await quote;
        expect(value.isEip1559, scenario == '1559');
        expect(
          value.totalFee,
          value.gasLimit * (value.maxFeePerGas ?? value.gasPrice),
        );
        if (scenario == 'free') expect(value.totalFee, BigInt.zero);
      }
    });
  }
}
