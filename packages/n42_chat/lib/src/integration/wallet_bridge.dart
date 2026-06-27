/// 钱包集成桥接接口
///
/// 在主应用中实现此接口以启用聊天中的加密货币转账功能
///
/// ## 使用示例
///
/// ```dart
/// class MyWalletBridge implements IWalletBridge {
///   @override
///   bool get isWalletConnected => _wallet.isConnected;
///
///   @override
///   Future<TransferResult> requestTransfer({...}) async {
///     // 实现转账逻辑
///   }
/// }
///
/// // 配置时传入
/// N42Chat.initialize(N42ChatConfig(
///   walletBridge: MyWalletBridge(),
/// ));
/// ```
abstract class IWalletBridge {
  /// 钱包是否已连接
  bool get isWalletConnected;

  /// 当前钱包地址
  String? get walletAddress;

  /// 获取支持的代币列表
  Future<List<TokenInfo>> getSupportedTokens();

  /// 获取代币余额
  ///
  /// [token] 代币符号或合约地址
  Future<String> getBalance(String token);

  /// 发起转账
  ///
  /// [toAddress] 接收方地址
  /// [amount] 转账金额
  /// [token] 代币符号或合约地址
  /// [memo] 备注
  Future<TransferResult> requestTransfer({
    required String toAddress,
    required String amount,
    required String token,
    String? memo,
  });

  /// 生成收款请求
  ///
  /// [amount] 请求金额
  /// [token] 代币符号
  /// [memo] 备注
  Future<PaymentRequest> generatePaymentRequest({
    required String amount,
    required String token,
    String? memo,
  });

  /// 显示收款二维码
  Future<void> showReceiveQRCode();

  /// 验证地址是否有效
  bool isValidAddress(String address);

  /// 获取地址对应的用户信息（如果有）
  Future<WalletUserInfo?> getUserInfoByAddress(String address);

  // ============================================
  // ENS 集成
  // ============================================

  /// 正向解析 ENS 域名 → 地址
  Future<String?> resolveEnsName(String ensName) async => null;

  /// 反向解析 地址 → ENS 域名
  Future<String?> lookupEnsName(String address) async => null;

  /// 获取 ENS 头像
  Future<String?> getEnsAvatar(String ensName) async => null;

  /// 批量反向解析 ENS 域名
  Future<Map<String, String?>> batchLookupEnsNames(List<String> addresses) async {
    final futures = addresses.map((addr) async {
      return MapEntry(addr, await lookupEnsName(addr));
    });
    final entries = await Future.wait(futures);
    return Map.fromEntries(entries);
  }

  // ============================================
  // 代币门控
  // ============================================

  /// 查询 ERC-20 余额
  Future<BigInt> getErc20Balance({
    required String contractAddress,
    required int chainId,
    String? ownerAddress,
  }) async => BigInt.zero;

  /// 查询 ERC-721 余额（NFT 数量）
  Future<int> getErc721Balance({
    required String contractAddress,
    required int chainId,
    String? ownerAddress,
  }) async => 0;

  /// 查询 ERC-1155 余额
  Future<BigInt> getErc1155Balance({
    required String contractAddress,
    required BigInt tokenId,
    required int chainId,
    String? ownerAddress,
  }) async => BigInt.zero;

  /// 查询 ERC-721 tokenURI（用于 NFT 元数据解析）
  Future<String?> getErc721TokenUri({
    required String contractAddress,
    required int tokenId,
    required int chainId,
  }) async => null;

  /// 赠送 / 转移一枚 NFT（ERC-721 / ERC-1155）。
  ///
  /// 默认返回「不支持」失败，由宿主 App 覆写接入真实链上转移。
  /// [standard] 区分 721/1155；1155 用 [amount]（默认 1 枚）。
  Future<TransferResult> requestNftTransfer({
    required String contractAddress,
    required String tokenId,
    required String toAddress,
    required int chainId,
    NftStandard standard = NftStandard.erc721,
    int amount = 1,
  }) async =>
      TransferResult.failure('NFT transfer not supported', code: 'unsupported');

  // ============================================
  // 消息签名（治理投票等）
  // ============================================

  /// 签名普通消息（personal_sign）
  ///
  /// 返回签名的十六进制字符串，如果钱包不支持或用户拒绝则返回 null。
  Future<String?> signMessage(String message) async => null;

  /// 签名 EIP-712 类型化数据（signTypedData_v4）
  ///
  /// [typedDataJson] 完整的 EIP-712 JSON 字符串
  /// 返回签名的十六进制字符串。
  Future<String?> signTypedData(String typedDataJson) async => null;
}

/// NFT 标准
enum NftStandard { erc721, erc1155 }

/// 转账结果
class TransferResult {
  /// 是否成功
  final bool success;

  /// 交易哈希
  final String? transactionHash;

  /// 错误消息
  final String? errorMessage;

  /// 错误代码
  final String? errorCode;

  const TransferResult({
    required this.success,
    this.transactionHash,
    this.errorMessage,
    this.errorCode,
  });

  /// 创建成功结果
  factory TransferResult.success(String txHash) => TransferResult(
        success: true,
        transactionHash: txHash,
      );

  /// 创建失败结果
  factory TransferResult.failure(String error, {String? code}) => TransferResult(
        success: false,
        errorMessage: error,
        errorCode: code,
      );

  /// 创建取消结果
  factory TransferResult.cancelled() => const TransferResult(
        success: false,
        errorMessage: 'User cancelled',
        errorCode: 'CANCELLED',
      );
}

/// 收款请求
class PaymentRequest {
  /// 请求ID
  final String requestId;

  /// 请求金额
  final String amount;

  /// 代币符号
  final String token;

  /// 收款地址
  final String receiverAddress;

  /// 备注
  final String? memo;

  /// 二维码数据
  final String qrCodeData;

  /// 创建时间
  final DateTime createdAt;

  /// 过期时间
  final DateTime? expiresAt;

  const PaymentRequest({
    required this.requestId,
    required this.amount,
    required this.token,
    required this.receiverAddress,
    this.memo,
    required this.qrCodeData,
    required this.createdAt,
    this.expiresAt,
  });

  /// 是否已过期
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 格式化显示金额
  String get formattedAmount => '$amount $token';
}

/// 代币信息
class TokenInfo {
  /// 代币符号
  final String symbol;

  /// 代币名称
  final String name;

  /// 小数位数
  final int decimals;

  /// 合约地址（原生代币为空）
  final String? contractAddress;

  /// 图标URL
  final String? iconUrl;

  /// 是否是原生代币
  final bool isNative;

  const TokenInfo({
    required this.symbol,
    required this.name,
    required this.decimals,
    this.contractAddress,
    this.iconUrl,
    this.isNative = false,
  });
}

/// 钱包用户信息
class WalletUserInfo {
  /// 钱包地址
  final String address;

  /// 用户名/昵称
  final String? username;

  /// 头像URL
  final String? avatarUrl;

  /// Matrix用户ID（如果已关联）
  final String? matrixUserId;

  const WalletUserInfo({
    required this.address,
    this.username,
    this.avatarUrl,
    this.matrixUserId,
  });

  /// 获取显示名称
  String get displayName {
    if (username != null && username!.isNotEmpty) {
      return username!;
    }
    // 缩短地址显示
    if (address.length > 10) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
    }
    return address;
  }
}

/// 无操作钱包桥接（未集成钱包时的安全降级）
///
/// 所有操作返回 null/空值/失败，不含任何硬编码测试数据。
/// 生产环境中宿主 App 必须通过 [N42ChatConfig.walletBridge] 注入真实实现。
class NoOpWalletBridge extends IWalletBridge {
  @override
  bool get isWalletConnected => false;

  @override
  String? get walletAddress => null;

  @override
  Future<List<TokenInfo>> getSupportedTokens() async => const [];

  @override
  Future<String> getBalance(String token) async => '0';

  @override
  Future<TransferResult> requestTransfer({
    required String toAddress,
    required String amount,
    required String token,
    String? memo,
  }) async {
    return TransferResult.failure('Wallet not connected');
  }

  @override
  Future<PaymentRequest> generatePaymentRequest({
    required String amount,
    required String token,
    String? memo,
  }) async {
    throw StateError('Wallet not connected');
  }

  @override
  Future<void> showReceiveQRCode() async {}

  @override
  bool isValidAddress(String address) {
    return address.startsWith('0x') && address.length == 42;
  }

  @override
  Future<WalletUserInfo?> getUserInfoByAddress(String address) async => null;
}

