import 'package:equatable/equatable.dart';

/// 转账事件基类
abstract class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => [];
}

/// 加载钱包信息
class LoadWalletInfo extends TransferEvent {
  const LoadWalletInfo();
}

/// 加载代币列表
class LoadTokens extends TransferEvent {
  const LoadTokens();
}

/// 加载代币余额
class LoadTokenBalance extends TransferEvent {
  final String token;

  const LoadTokenBalance(this.token);

  @override
  List<Object?> get props => [token];
}

/// 发起转账
class InitiateTransfer extends TransferEvent {
  final String roomId;
  final String receiverAddress;
  final String amount;
  final String token;
  final String? memo;

  const InitiateTransfer({
    required this.roomId,
    required this.receiverAddress,
    required this.amount,
    required this.token,
    this.memo,
  });

  @override
  List<Object?> get props => [roomId, receiverAddress, amount, token, memo];
}

/// 创建收款请求
class CreatePaymentRequest extends TransferEvent {
  final String roomId;
  final String amount;
  final String token;
  final String? memo;

  const CreatePaymentRequest({
    required this.roomId,
    required this.amount,
    required this.token,
    this.memo,
  });

  @override
  List<Object?> get props => [roomId, amount, token, memo];
}

/// 处理收款请求
class FulfillPaymentRequest extends TransferEvent {
  final String roomId;
  final String requestId;
  final String receiverAddress;
  final String amount;
  final String token;

  const FulfillPaymentRequest({
    required this.roomId,
    required this.requestId,
    required this.receiverAddress,
    required this.amount,
    required this.token,
  });

  @override
  List<Object?> get props => [roomId, requestId, receiverAddress, amount, token];
}

/// 验证地址
class ValidateAddress extends TransferEvent {
  final String address;

  const ValidateAddress(this.address);

  @override
  List<Object?> get props => [address];
}

/// 清除转账状态
class ClearTransferState extends TransferEvent {
  const ClearTransferState();
}

