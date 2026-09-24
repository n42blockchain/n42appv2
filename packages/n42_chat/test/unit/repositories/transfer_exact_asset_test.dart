import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_message_datasource.dart';
import 'package:n42_chat/src/data/repositories/transfer_repository_impl.dart';
import 'package:n42_chat/src/domain/entities/transfer_entity.dart';
import 'package:n42_chat/src/integration/wallet_bridge.dart';

class _Wallet extends NoOpWalletBridge {
  int legacyCalls = 0;
  String? chain;
  String? network;
  String? assetType;
  String? assetId;

  @override
  bool get isWalletConnected => true;

  @override
  String? get walletAddress => '0xsender';

  @override
  Future<TransferResult> requestTransfer({
    required String toAddress,
    required String amount,
    required String token,
    String? memo,
  }) async {
    legacyCalls++;
    return TransferResult.failure('legacy route used');
  }

  @override
  Future<TransferResult> requestTransferExact({
    required String toAddress,
    required String amount,
    required String token,
    String? memo,
    required String chain,
    required String network,
    required String assetType,
    String? assetId,
  }) async {
    this.chain = chain;
    this.network = network;
    this.assetType = assetType;
    this.assetId = assetId;
    return TransferResult.failure('captured exact request');
  }
}

void main() {
  test(
    'exact payment identity reaches the exact wallet bridge method',
    () async {
      final wallet = _Wallet();
      final clientManager = MatrixClientManager.instance;
      final repository = TransferRepositoryImpl(
        wallet,
        MatrixMessageDataSource(clientManager),
        clientManager,
      );

      final transfer = await repository.initiateTransferExact(
        roomId: '!room:example.org',
        receiverAddress: '0xreceiver',
        amount: '1.25',
        token: 'USDC',
        chain: 'ethereum',
        network: 'testnet',
        assetType: 'token',
        assetId: '0xabc123',
      );

      expect(transfer.status, TransferStatus.failed);
      expect(wallet.legacyCalls, 0);
      expect(wallet.chain, 'ethereum');
      expect(wallet.network, 'testnet');
      expect(wallet.assetType, 'token');
      expect(wallet.assetId, '0xabc123');
    },
  );
}
