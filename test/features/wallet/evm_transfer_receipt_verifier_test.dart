import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:n42_wallet/features/wallet/services/evm_transfer_receipt_verifier.dart';

void main() {
  final hash = '0x${'a' * 64}';
  const sender = '0x1111111111111111111111111111111111111111';
  const receiver = '0x2222222222222222222222222222222222222222';
  const token = '0x3333333333333333333333333333333333333333';
  const transferTopic =
      '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';

  WalletTransferReceiptRequest request({
    String assetType = 'native',
    String? assetId,
    String amount = '1.25',
  }) => WalletTransferReceiptRequest(
    transactionHash: hash,
    senderAddress: sender,
    receiverAddress: receiver,
    amount: amount,
    chain: 'ETH',
    network: 'mainnet',
    assetType: assetType,
    assetId: assetId,
  );

  Map<String, Object?> nativeTx({
    String? from,
    String? to,
    String? value,
    String input = '0x',
  }) => {
    'hash': hash,
    'from': from ?? sender,
    'to': to ?? receiver,
    'value': value ?? '0x1158e460913d0000', // 1.25 ETH
    'input': input,
  };

  Map<String, Object?> nativeReceipt({
    String status = '0x1',
    String blockNumber = '0x10',
  }) => {
    'transactionHash': hash,
    'status': status,
    'blockNumber': blockNumber,
    'logs': const <Object?>[],
  };

  Future<WalletTransferReceiptResult> verify(
    WalletTransferReceiptRequest request, {
    required Map<String, Object?> transaction,
    required Map<String, Object?>? receipt,
    String chainId = '0x1',
    String latestBlock = '0x1b',
    int decimals = 18,
  }) => EvmTransferReceiptVerifier.verify(
    request: request,
    expectedChainId: 1,
    requiredConfirmations: 12,
    decimals: decimals,
    rpcCall: (method, _) async => switch (method) {
      'eth_chainId' => chainId,
      'eth_getTransactionByHash' => transaction,
      'eth_getTransactionReceipt' => receipt,
      'eth_blockNumber' => latestBlock,
      _ => throw StateError('Unexpected RPC method $method'),
    },
  );

  test(
    'confirms only a receipt with enough blocks and exact native fields',
    () async {
      final result = await verify(
        request(),
        transaction: nativeTx(),
        receipt: nativeReceipt(),
      );

      expect(result.state, WalletTransferReceiptState.confirmed);
      expect(result.confirmations, 12);
      expect(result.requiredConfirmations, 12);
    },
  );

  test(
    'keeps an exact native transfer pending below finality threshold',
    () async {
      final result = await verify(
        request(),
        transaction: nativeTx(),
        receipt: nativeReceipt(),
        latestBlock: '0x15',
      );

      expect(result.state, WalletTransferReceiptState.pending);
      expect(result.confirmations, 6);
    },
  );

  test('rejects a different RPC chain and mismatched payment fields', () async {
    final wrongChain = await verify(
      request(),
      transaction: nativeTx(),
      receipt: nativeReceipt(),
      chainId: '0x5',
    );
    final wrongReceiver = await verify(
      request(),
      transaction: nativeTx(to: sender),
      receipt: nativeReceipt(),
    );
    final wrongAmount = await verify(
      request(),
      transaction: nativeTx(value: '0xde0b6b3a7640000'),
      receipt: nativeReceipt(),
    );

    expect(wrongChain.state, WalletTransferReceiptState.mismatch);
    expect(wrongReceiver.state, WalletTransferReceiptState.mismatch);
    expect(wrongAmount.state, WalletTransferReceiptState.mismatch);
  });

  test('reports an on-chain reverted transaction as failed', () async {
    final result = await verify(
      request(),
      transaction: nativeTx(),
      receipt: nativeReceipt(status: '0x0'),
    );

    expect(result.state, WalletTransferReceiptState.failed);
  });

  test('keeps a transaction without a receipt pending', () async {
    final result = await verify(
      request(),
      transaction: nativeTx(),
      receipt: null,
    );

    expect(result.state, WalletTransferReceiptState.pending);
  });

  test('confirms ERC-20 only when calldata and Transfer log match', () async {
    final amount = BigInt.from(125).toRadixString(16).padLeft(64, '0');
    final addressWord = receiver.substring(2).padLeft(64, '0');
    final result = await verify(
      request(assetType: 'token', assetId: token, amount: '1.25'),
      transaction: {
        'hash': hash,
        'from': sender,
        'to': token,
        'value': '0x0',
        'input': '0xa9059cbb$addressWord$amount',
      },
      receipt: {
        ...nativeReceipt(),
        'logs': [
          {
            'address': token,
            'topics': [
              transferTopic,
              '0x${sender.substring(2).padLeft(64, '0')}',
              '0x${receiver.substring(2).padLeft(64, '0')}',
            ],
            'data': '0x${'7d'}',
          },
        ],
      },
      decimals: 2,
    );

    expect(result.state, WalletTransferReceiptState.confirmed);
  });

  test(
    'rejects ERC-20 receipt when transfer log does not match exact amount',
    () async {
      final amount = BigInt.from(125).toRadixString(16).padLeft(64, '0');
      final addressWord = receiver.substring(2).padLeft(64, '0');
      final result = await verify(
        request(assetType: 'token', assetId: token, amount: '1.25'),
        transaction: {
          'hash': hash,
          'from': sender,
          'to': token,
          'value': '0x0',
          'input': '0xa9059cbb$addressWord$amount',
        },
        receipt: {
          ...nativeReceipt(),
          'logs': [
            {
              'address': token,
              'topics': [
                transferTopic,
                '0x${sender.substring(2).padLeft(64, '0')}',
                '0x${receiver.substring(2).padLeft(64, '0')}',
              ],
              'data': '0x7c',
            },
          ],
        },
        decimals: 2,
      );

      expect(result.state, WalletTransferReceiptState.mismatch);
    },
  );
}
