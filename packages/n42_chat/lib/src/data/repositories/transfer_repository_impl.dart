import 'package:uuid/uuid.dart';

import '../../core/utils/debug_log.dart';
import '../../domain/entities/transfer_entity.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../../integration/wallet_bridge.dart';
import '../datasources/matrix/matrix_message_datasource.dart';
import '../datasources/matrix/matrix_client_manager.dart';

/// 转账仓库实现
class TransferRepositoryImpl implements ITransferRepository {
  final IWalletBridge _walletBridge;
  final MatrixMessageDataSource _messageDataSource;
  final MatrixClientManager _clientManager;

  // 本地转账记录缓存
  final Map<String, TransferEntity> _transfersCache = {};

  TransferRepositoryImpl(
    this._walletBridge,
    this._messageDataSource,
    this._clientManager,
  );

  @override
  Future<TransferEntity> initiateTransfer({
    required String roomId,
    required String receiverAddress,
    required String amount,
    required String token,
    String? memo,
  }) async {
    if (!_walletBridge.isWalletConnected) {
      throw Exception('钱包未连接');
    }

    final senderAddress = _walletBridge.walletAddress;
    if (senderAddress == null) {
      throw Exception('无法获取钱包地址');
    }

    // 创建转账实体
    final transferId = const Uuid().v4();
    final transfer = TransferEntity(
      id: transferId,
      roomId: roomId,
      senderAddress: senderAddress,
      receiverAddress: receiverAddress,
      senderUserId: _clientManager.client?.userID,
      amount: amount,
      token: token,
      status: TransferStatus.pending,
      memo: memo,
      createdAt: DateTime.now(),
    );

    // 缓存转账记录
    _transfersCache[transferId] = transfer;

    // 发起转账
    final result = await _walletBridge.requestTransfer(
      toAddress: receiverAddress,
      amount: amount,
      token: token,
      memo: memo,
    );

    // 更新转账状态
    TransferEntity updatedTransfer;
    if (result.success) {
      updatedTransfer = transfer.copyWith(
        status: TransferStatus.completed,
        transactionHash: result.transactionHash,
        completedAt: DateTime.now(),
      );
    } else {
      updatedTransfer = transfer.copyWith(
        status: result.errorCode == 'CANCELLED'
            ? TransferStatus.cancelled
            : TransferStatus.failed,
        failureReason: result.errorMessage,
      );
    }

    _transfersCache[transferId] = updatedTransfer;

    // 发送转账消息到聊天室
    if (result.success) {
      try {
        final eventId = await sendTransferMessage(
          roomId: roomId,
          transfer: updatedTransfer,
        );
        updatedTransfer = updatedTransfer.copyWith(eventId: eventId);
        _transfersCache[transferId] = updatedTransfer;
      } catch (e) {
        debugLog(
          'TransferRepository: transfer succeeded but chat message failed: $e',
        );
      }
    }

    return updatedTransfer;
  }

  @override
  Future<String> sendTransferMessage({
    required String roomId,
    required TransferEntity transfer,
  }) async {
    final content = TransferMessageContent(
      transferId: transfer.id,
      senderAddress: transfer.senderAddress,
      receiverAddress: transfer.receiverAddress,
      amount: transfer.amount,
      token: transfer.token,
      transactionHash: transfer.transactionHash,
      status: transfer.status,
      memo: transfer.memo,
    );

    // 发送自定义消息
    return await _messageDataSource.sendCustomMessage(
      roomId: roomId,
      msgType: TransferMessageContent.msgType,
      content: content.toMessageContent(),
    );
  }

  @override
  Future<void> updateTransferStatus({
    required String transferId,
    required TransferStatus status,
    String? transactionHash,
    String? failureReason,
  }) async {
    final transfer = _transfersCache[transferId];
    if (transfer == null) return;

    _transfersCache[transferId] = transfer.copyWith(
      status: status,
      transactionHash: transactionHash ?? transfer.transactionHash,
      failureReason: failureReason,
      completedAt: status == TransferStatus.completed ? DateTime.now() : null,
    );
  }

  @override
  Future<PaymentRequest> createPaymentRequest({
    required String amount,
    required String token,
    String? memo,
  }) async {
    return await _walletBridge.generatePaymentRequest(
      amount: amount,
      token: token,
      memo: memo,
    );
  }

  @override
  Future<String> sendPaymentRequestMessage({
    required String roomId,
    required PaymentRequest request,
  }) async {
    final content = PaymentRequestContent(
      requestId: request.requestId,
      receiverAddress: request.receiverAddress,
      amount: request.amount,
      token: request.token,
      memo: request.memo,
      expiresAt: request.expiresAt,
    );

    return await _messageDataSource.sendCustomMessage(
      roomId: roomId,
      msgType: PaymentRequestContent.msgType,
      content: content.toMessageContent(),
    );
  }

  @override
  Future<TransferEntity> fulfillPaymentRequest({
    required String roomId,
    required String requestId,
    required String receiverAddress,
    required String amount,
    required String token,
  }) async {
    final transfer = await initiateTransfer(
      roomId: roomId,
      receiverAddress: receiverAddress,
      amount: amount,
      token: token,
      memo: '支付请求: $requestId',
    );

    if (transfer.isSuccess) {
      try {
        await _messageDataSource.sendRoomEvent(
          roomId: roomId,
          type: PaymentRequestFulfillmentContent.eventType,
          content: PaymentRequestFulfillmentContent(
            requestId: requestId,
            transferId: transfer.id,
            transferEventId: transfer.eventId,
            payerAddress: transfer.senderAddress,
            receiverAddress: transfer.receiverAddress,
            amount: transfer.amount,
            token: transfer.token,
            transactionHash: transfer.transactionHash,
            fulfilledAt: transfer.completedAt ?? DateTime.now(),
          ).toEventContent(),
        );
      } catch (e) {
        debugLog(
          'TransferRepository: transfer succeeded but payment ack send failed: $e',
        );
      }
    }

    return transfer;
  }

  @override
  Future<List<TransferEntity>> getTransfersByRoom(String roomId) async {
    return _transfersCache.values.where((t) => t.roomId == roomId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<TransferEntity?> getTransfer(String transferId) async {
    return _transfersCache[transferId];
  }

  @override
  Future<List<TransferEntity>> getAllTransfers({
    int? limit,
    int? offset,
  }) async {
    var transfers = _transfersCache.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (offset != null && offset > 0) {
      transfers = transfers.skip(offset).toList();
    }

    if (limit != null && limit > 0) {
      transfers = transfers.take(limit).toList();
    }

    return transfers;
  }

  @override
  Future<List<TokenInfo>> getSupportedTokens() async {
    return await _walletBridge.getSupportedTokens();
  }

  @override
  Future<String> getTokenBalance(String token) async {
    return await _walletBridge.getBalance(token);
  }

  @override
  bool isValidAddress(String address) {
    return _walletBridge.isValidAddress(address);
  }

  @override
  String? get currentWalletAddress => _walletBridge.walletAddress;

  @override
  bool get isWalletConnected => _walletBridge.isWalletConnected;
}
