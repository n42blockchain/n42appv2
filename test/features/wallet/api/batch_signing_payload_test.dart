import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/provider/batch_transfer_provider.dart';
import 'package:n42_wallet/features/wallet/api/batch_transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/batch_transfer_model.dart';

class _ReadyApi extends BatchTransferApi {
  @override
  Future<void> validateNetwork(
    String rpcUrl,
    int chainId,
    String chainSymbol,
  ) async {}

  @override
  Future<int> getNonce(String rpcUrl, String address) async => 7;
  @override
  Future<BatchGasEstimate> getGasEstimate({
    required String rpcUrl,
    required String chainSymbol,
    required String fromAddress,
    required String? tokenAddress,
    required List<BatchTransferItem> items,
  }) async => BatchGasEstimate(
    gasLimit: BigInt.from(100000),
    gasPrice: BigInt.from(10),
    totalFee: BigInt.from(1000000),
    isEip1559: false,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const from = '0x1111111111111111111111111111111111111111';
  const to = '0x2222222222222222222222222222222222222222';
  test(
    'provider passes flattened fields unchanged through the signer channel',
    () async {
      final provider = BatchTransferProvider(api: _ReadyApi());
      addTearDown(provider.dispose);
      provider.initialize(
        chainSymbol: 'ETH',
        rpcUrl: 'https://rpc.invalid',
        chainId: 1,
        fromAddress: from,
        tokenSymbol: 'ETH',
        decimals: 18,
      );
      provider.addItem(to, BigInt.from(123));
      final payload = await provider.buildTransaction();
      expect(payload, isNotNull);
      expect(payload!.containsKey('txData'), isFalse);
      expect(payload['amount'], '7b');
      expect(payload['msgData'], startsWith('e8917eb5'));
      const channel = MethodChannel('trustdart');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            expect(call.method, 'signTransaction');
            expect(call.arguments['txData'], payload);
            return '0x01';
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      expect(
        await Trustdart().signTransaction(
          'ETH',
          "m/44'/60'/0'/0/0",
          payload,
          pk: 'synthetic',
        ),
        '0x01',
      );
    },
  );
  test('zero gas price remains available on free-gas networks', () async {
    final result = await BatchTransferApi().buildBatchTransaction(
      chainSymbol: 'ETH',
      fromAddress: from,
      tokenAddress: null,
      items: [BatchTransferItem(id: '1', toAddress: to, amount: BigInt.one)],
      gasLimit: BigInt.from(100000),
      nonce: 0,
      chainId: 1,
      gasPrice: BigInt.zero,
    );
    expect(result.error, isFalse);
    expect(result.data['txData']['gasPrice'], '0');
  });
  for (final eip1559 in [false, true]) {
    test(
      'native batch uses the shared signer contract with ${eip1559 ? 'EIP1559' : 'Legacy'} fees',
      () async {
        final result = await BatchTransferApi().buildBatchTransaction(
          chainSymbol: 'ETH',
          fromAddress: from,
          tokenAddress: null,
          items: [
            BatchTransferItem(id: '1', toAddress: to, amount: BigInt.from(123)),
          ],
          gasLimit: BigInt.from(100000),
          nonce: 7,
          chainId: 1,
          gasPrice: eip1559 ? null : BigInt.from(10),
          maxFeePerGas: eip1559 ? BigInt.from(20) : null,
          maxPriorityFeePerGas: eip1559 ? BigInt.two : null,
        );
        expect(result.error, isFalse);
        final payload = result.data['txData'] as Map;
        expect(payload['toAddress'], BatchTransferApi.multicall3Address);
        expect(
          BigInt.parse(payload['amount'] as String, radix: 16),
          BigInt.from(123),
        );
        expect(
          payload['msgData'],
          (result.data['rawData'] as String).substring(2),
        );
        expect(payload['msgData'], startsWith('e8917eb5'));
        expect(payload['msgData'], contains(to.substring(2)));
        expect(payload['nonce'], '7');
        expect(payload['chainId'], '1');
        expect(payload['gasPrice'], eip1559 ? '14' : 'a');
        expect(payload['gasPrice2'], eip1559 ? '2' : '0');
        expect(payload['is1559'], eip1559.toString());
        expect(payload['contract'], '');
        expect(payload['erc721Or1155'], '');
        for (final key in [
          'chainId',
          'nonce',
          'amount',
          'msgData',
          'gasLimit',
          'gasPrice',
          'gasPrice2',
        ]) {
          expect(payload[key], isNot(startsWith('0x')));
        }
      },
    );
  }
}
