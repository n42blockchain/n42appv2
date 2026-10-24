import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/batch_transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/batch_transfer_model.dart';
import 'package:n42_wallet/features/wallet/provider/batch_transfer_provider.dart';

class _Api extends BatchTransferApi {
  final pending = Completer<BatchGasEstimate>();
  @override
  Future<BatchGasEstimate> getGasEstimate({
    required String rpcUrl,
    required String chainSymbol,
    required String fromAddress,
    required String? tokenAddress,
    required List<BatchTransferItem> items,
  }) => pending.future;
}

void main() {
  for (final fail in [false, true]) {
    test(
      'stale ${fail ? 'failure' : 'quote'} cannot mutate a changed batch',
      () async {
        final api = _Api();
        final provider = BatchTransferProvider(api: api);
        addTearDown(provider.dispose);
        provider.initialize(
          chainSymbol: 'ETH',
          rpcUrl: 'https://rpc.invalid',
          chainId: 1,
          fromAddress: '0x${'11' * 20}',
          tokenSymbol: 'ETH',
          decimals: 18,
        );
        provider.addItem('0x${'22' * 20}', BigInt.one);
        final future = provider.estimateGas();
        provider.reset();
        if (fail) {
          api.pending.completeError(StateError('old failure'));
        } else {
          api.pending.complete(
            BatchGasEstimate(
              isEip1559: false,
              gasLimit: BigInt.from(50000),
              gasPrice: BigInt.one,
              totalFee: BigInt.from(50000),
            ),
          );
        }
        await future;
        expect(provider.gasEstimate, isNull);
        expect(provider.state, BatchTransferState.initial);
        expect(provider.errorMessage, isNull);
      },
    );
  }
}
