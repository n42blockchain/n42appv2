import 'package:equatable/equatable.dart';

import '../../../domain/entities/transfer_entity.dart';
import '../../../integration/wallet_bridge.dart';

/// 转账 BLoC 状态枚举
enum TransferBlocStatus {
  /// 初始状态
  initial,

  /// 钱包信息已加载
  walletLoaded,

  /// 转账处理中
  processing,

  /// 转账成功
  success,

  /// 转账失败
  failure,

  /// 收款请求已创建
  paymentCreated,

  /// 地址已验证
  addressValidated,
}

/// 转账状态（单一 State + copyWith 模式）
class TransferState extends Equatable {
  /// 当前状态
  final TransferBlocStatus status;

  /// 钱包是否已连接
  final bool isWalletConnected;

  /// 钱包地址
  final String? walletAddress;

  /// 支持的代币列表
  final List<TokenInfo> tokens;

  /// 代币余额
  final Map<String, String> balances;

  /// 最近一次转账
  final TransferEntity? lastTransfer;

  /// 错误消息
  final String? errorMessage;

  /// 验证的地址
  final String? validatedAddress;

  /// 地址是否有效
  final bool? isAddressValid;

  /// 钱包用户信息
  final WalletUserInfo? userInfo;

  /// 收款请求
  final PaymentRequest? paymentRequest;

  /// 处理中的消息
  final String? processingMessage;

  const TransferState({
    this.status = TransferBlocStatus.initial,
    this.isWalletConnected = false,
    this.walletAddress,
    this.tokens = const [],
    this.balances = const {},
    this.lastTransfer,
    this.errorMessage,
    this.validatedAddress,
    this.isAddressValid,
    this.userInfo,
    this.paymentRequest,
    this.processingMessage,
  });

  const TransferState.initial() : this();

  /// 是否正在处理
  bool get isProcessing => status == TransferBlocStatus.processing;

  /// 是否已加载钱包
  bool get isWalletLoaded => status == TransferBlocStatus.walletLoaded || isWalletConnected;

  TransferState copyWith({
    TransferBlocStatus? status,
    bool? isWalletConnected,
    String? walletAddress,
    List<TokenInfo>? tokens,
    Map<String, String>? balances,
    TransferEntity? lastTransfer,
    String? errorMessage,
    String? validatedAddress,
    bool? isAddressValid,
    WalletUserInfo? userInfo,
    PaymentRequest? paymentRequest,
    String? processingMessage,
  }) {
    return TransferState(
      status: status ?? this.status,
      isWalletConnected: isWalletConnected ?? this.isWalletConnected,
      walletAddress: walletAddress ?? this.walletAddress,
      tokens: tokens ?? this.tokens,
      balances: balances ?? this.balances,
      lastTransfer: lastTransfer,
      errorMessage: errorMessage,
      validatedAddress: validatedAddress,
      isAddressValid: isAddressValid,
      userInfo: userInfo,
      paymentRequest: paymentRequest,
      processingMessage: processingMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isWalletConnected,
        walletAddress,
        tokens,
        balances,
        lastTransfer,
        errorMessage,
        validatedAddress,
        isAddressValid,
        userInfo,
        paymentRequest,
        processingMessage,
      ];

  @override
  String toString() => 'TransferState(status: $status, connected: $isWalletConnected)';
}
