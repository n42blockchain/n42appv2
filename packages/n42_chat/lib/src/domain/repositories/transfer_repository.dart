import '../entities/transfer_entity.dart';
import '../../integration/wallet_bridge.dart';

/// 转账仓库接口
abstract class ITransferRepository {
  // ============================================
  // 转账操作
  // ============================================

  /// 发起转账
  Future<TransferEntity> initiateTransfer({
    required String roomId,
    required String receiverAddress,
    required String amount,
    required String token,
    String? memo,
  });

  /// 发送转账消息到聊天
  Future<String> sendTransferMessage({
    required String roomId,
    required TransferEntity transfer,
  });

  /// 更新转账状态
  Future<void> updateTransferStatus({
    required String transferId,
    required TransferStatus status,
    String? transactionHash,
    String? failureReason,
  });

  // ============================================
  // 收款请求
  // ============================================

  /// 创建收款请求
  Future<PaymentRequest> createPaymentRequest({
    required String amount,
    required String token,
    String? memo,
  });

  /// 发送收款请求消息
  Future<String> sendPaymentRequestMessage({
    required String roomId,
    required PaymentRequest request,
  });

  /// 处理收款请求（支付）
  Future<TransferEntity> fulfillPaymentRequest({
    required String roomId,
    required String requestId,
    required String receiverAddress,
    required String amount,
    required String token,
  });

  // ============================================
  // 转账记录查询
  // ============================================

  /// 获取聊天室的转账记录
  Future<List<TransferEntity>> getTransfersByRoom(String roomId);

  /// 获取转账详情
  Future<TransferEntity?> getTransfer(String transferId);

  /// 获取所有转账记录
  Future<List<TransferEntity>> getAllTransfers({
    int? limit,
    int? offset,
  });

  // ============================================
  // 钱包信息
  // ============================================

  /// 获取支持的代币列表
  Future<List<TokenInfo>> getSupportedTokens();

  /// 获取代币余额
  Future<String> getTokenBalance(String token);

  /// 验证地址
  bool isValidAddress(String address);

  /// 获取当前钱包地址
  String? get currentWalletAddress;

  /// 钱包是否已连接
  bool get isWalletConnected;
}

