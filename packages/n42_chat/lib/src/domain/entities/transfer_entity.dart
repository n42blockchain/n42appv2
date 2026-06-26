import 'package:equatable/equatable.dart';

/// 转账状态
enum TransferStatus {
  /// 等待中
  pending,

  /// 处理中
  processing,

  /// 已完成
  completed,

  /// 失败
  failed,

  /// 已取消
  cancelled,
}

/// 转账方向
enum TransferDirection {
  /// 发送
  sent,

  /// 接收
  received,
}

/// 转账消息实体
class TransferEntity extends Equatable {
  /// 转账ID
  final String id;

  /// 关联的消息事件ID
  final String? eventId;

  /// 关联的房间ID
  final String? roomId;

  /// 发送方地址
  final String senderAddress;

  /// 接收方地址
  final String receiverAddress;

  /// 发送方Matrix用户ID
  final String? senderUserId;

  /// 接收方Matrix用户ID
  final String? receiverUserId;

  /// 转账金额
  final String amount;

  /// 代币符号
  final String token;

  /// 代币名称
  final String? tokenName;

  /// 代币图标
  final String? tokenIcon;

  /// 交易哈希
  final String? transactionHash;

  /// 转账状态
  final TransferStatus status;

  /// 备注
  final String? memo;

  /// 创建时间
  final DateTime createdAt;

  /// 完成时间
  final DateTime? completedAt;

  /// 失败原因
  final String? failureReason;

  /// 区块确认数
  final int? confirmations;

  /// 交易费用
  final String? fee;

  /// 费用代币
  final String? feeToken;

  const TransferEntity({
    required this.id,
    this.eventId,
    this.roomId,
    required this.senderAddress,
    required this.receiverAddress,
    this.senderUserId,
    this.receiverUserId,
    required this.amount,
    required this.token,
    this.tokenName,
    this.tokenIcon,
    this.transactionHash,
    required this.status,
    this.memo,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
    this.confirmations,
    this.fee,
    this.feeToken,
  });

  /// 格式化显示金额
  String get formattedAmount => '$amount $token';

  /// 格式化显示费用
  String? get formattedFee {
    if (fee == null) return null;
    return '$fee ${feeToken ?? token}';
  }

  /// 获取缩短的交易哈希
  String? get shortTxHash {
    if (transactionHash == null) return null;
    if (transactionHash!.length <= 16) return transactionHash;
    return '${transactionHash!.substring(0, 8)}...${transactionHash!.substring(transactionHash!.length - 6)}';
  }

  /// 获取缩短的地址
  static String shortenAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  /// 是否是发送的转账
  bool isSentBy(String? address) {
    if (address == null) return false;
    return senderAddress.toLowerCase() == address.toLowerCase();
  }

  /// 获取转账方向
  TransferDirection getDirection(String? myAddress) {
    if (isSentBy(myAddress)) return TransferDirection.sent;
    return TransferDirection.received;
  }

  /// 是否成功
  bool get isSuccess => status == TransferStatus.completed;

  /// 是否失败
  bool get isFailed => status == TransferStatus.failed;

  /// 是否等待中
  bool get isPending =>
      status == TransferStatus.pending || status == TransferStatus.processing;

  @override
  List<Object?> get props => [
    id,
    eventId,
    roomId,
    senderAddress,
    receiverAddress,
    senderUserId,
    receiverUserId,
    amount,
    token,
    tokenName,
    tokenIcon,
    transactionHash,
    status,
    memo,
    createdAt,
    completedAt,
    failureReason,
    confirmations,
    fee,
    feeToken,
  ];

  TransferEntity copyWith({
    String? id,
    String? eventId,
    String? roomId,
    String? senderAddress,
    String? receiverAddress,
    String? senderUserId,
    String? receiverUserId,
    String? amount,
    String? token,
    String? tokenName,
    String? tokenIcon,
    String? transactionHash,
    TransferStatus? status,
    String? memo,
    DateTime? createdAt,
    DateTime? completedAt,
    String? failureReason,
    int? confirmations,
    String? fee,
    String? feeToken,
  }) {
    return TransferEntity(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      roomId: roomId ?? this.roomId,
      senderAddress: senderAddress ?? this.senderAddress,
      receiverAddress: receiverAddress ?? this.receiverAddress,
      senderUserId: senderUserId ?? this.senderUserId,
      receiverUserId: receiverUserId ?? this.receiverUserId,
      amount: amount ?? this.amount,
      token: token ?? this.token,
      tokenName: tokenName ?? this.tokenName,
      tokenIcon: tokenIcon ?? this.tokenIcon,
      transactionHash: transactionHash ?? this.transactionHash,
      status: status ?? this.status,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
      confirmations: confirmations ?? this.confirmations,
      fee: fee ?? this.fee,
      feeToken: feeToken ?? this.feeToken,
    );
  }

  /// 从JSON创建
  factory TransferEntity.fromJson(Map<String, dynamic> json) {
    return TransferEntity(
      id: json['id'] as String,
      eventId: json['event_id'] as String?,
      roomId: json['room_id'] as String?,
      senderAddress: json['sender_address'] as String,
      receiverAddress: json['receiver_address'] as String,
      senderUserId: json['sender_user_id'] as String?,
      receiverUserId: json['receiver_user_id'] as String?,
      amount: json['amount'] as String,
      token: json['token'] as String,
      tokenName: json['token_name'] as String?,
      tokenIcon: json['token_icon'] as String?,
      transactionHash: json['tx_hash'] as String?,
      status: TransferStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransferStatus.pending,
      ),
      memo: json['memo'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      completedAt: json['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completed_at'] as int)
          : null,
      failureReason: json['failure_reason'] as String?,
      confirmations: json['confirmations'] as int?,
      fee: json['fee'] as String?,
      feeToken: json['fee_token'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'room_id': roomId,
      'sender_address': senderAddress,
      'receiver_address': receiverAddress,
      'sender_user_id': senderUserId,
      'receiver_user_id': receiverUserId,
      'amount': amount,
      'token': token,
      'token_name': tokenName,
      'token_icon': tokenIcon,
      'tx_hash': transactionHash,
      'status': status.name,
      'memo': memo,
      'created_at': createdAt.millisecondsSinceEpoch,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'failure_reason': failureReason,
      'confirmations': confirmations,
      'fee': fee,
      'fee_token': feeToken,
    };
  }
}

/// 转账消息内容（用于Matrix消息）
class TransferMessageContent {
  /// 消息类型标识
  static const String msgType = 'n42.transfer';

  /// 转账ID
  final String transferId;

  /// 发送方地址
  final String senderAddress;

  /// 接收方地址
  final String receiverAddress;

  /// 金额
  final String amount;

  /// 代币符号
  final String token;

  /// 交易哈希
  final String? transactionHash;

  /// 状态
  final TransferStatus status;

  /// 备注
  final String? memo;

  const TransferMessageContent({
    required this.transferId,
    required this.senderAddress,
    required this.receiverAddress,
    required this.amount,
    required this.token,
    this.transactionHash,
    required this.status,
    this.memo,
  });

  /// 从消息内容创建
  factory TransferMessageContent.fromMessageContent(
    Map<String, dynamic> content,
  ) {
    return TransferMessageContent(
      transferId: content['transfer_id'] as String? ?? '',
      senderAddress: content['sender_address'] as String? ?? '',
      receiverAddress: content['receiver_address'] as String? ?? '',
      amount: content['amount'] as String? ?? '0',
      token: content['token'] as String? ?? '',
      transactionHash: content['tx_hash'] as String?,
      status: TransferStatus.values.firstWhere(
        (e) => e.name == content['status'],
        orElse: () => TransferStatus.pending,
      ),
      memo: content['memo'] as String?,
    );
  }

  /// 转换为消息内容
  Map<String, dynamic> toMessageContent() {
    return {
      'msgtype': msgType,
      'body': '转账 $amount $token',
      'transfer_id': transferId,
      'sender_address': senderAddress,
      'receiver_address': receiverAddress,
      'amount': amount,
      'token': token,
      'tx_hash': transactionHash,
      'status': status.name,
      'memo': memo,
    };
  }
}

/// 收款请求消息内容
class PaymentRequestContent {
  /// 消息类型标识
  static const String msgType = 'n42.payment_request';

  /// 请求ID
  final String requestId;

  /// 收款地址
  final String receiverAddress;

  /// 金额
  final String amount;

  /// 代币符号
  final String token;

  /// 备注
  final String? memo;

  /// 过期时间
  final DateTime? expiresAt;

  const PaymentRequestContent({
    required this.requestId,
    required this.receiverAddress,
    required this.amount,
    required this.token,
    this.memo,
    this.expiresAt,
  });

  /// 是否已过期
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 从消息内容创建
  factory PaymentRequestContent.fromMessageContent(
    Map<String, dynamic> content,
  ) {
    return PaymentRequestContent(
      requestId: content['request_id'] as String? ?? '',
      receiverAddress: content['receiver_address'] as String? ?? '',
      amount: content['amount'] as String? ?? '0',
      token: content['token'] as String? ?? '',
      memo: content['memo'] as String?,
      expiresAt: content['expires_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(content['expires_at'] as int)
          : null,
    );
  }

  /// 转换为消息内容
  Map<String, dynamic> toMessageContent() {
    return {
      'msgtype': msgType,
      'body': '收款请求 $amount $token',
      'request_id': requestId,
      'receiver_address': receiverAddress,
      'amount': amount,
      'token': token,
      'memo': memo,
      'expires_at': expiresAt?.millisecondsSinceEpoch,
    };
  }
}

/// 收款请求完成确认事件内容
class PaymentRequestFulfillmentContent {
  /// 自定义事件类型，不直接展示为聊天消息
  static const String eventType = 'n42.payment_request.fulfillment';

  /// 收款请求 ID
  final String requestId;

  /// 对应的转账 ID
  final String transferId;

  /// 对应的转账消息事件 ID
  final String? transferEventId;

  /// 支付方地址
  final String payerAddress;

  /// 收款方地址
  final String receiverAddress;

  /// 金额
  final String amount;

  /// 代币符号
  final String token;

  /// 交易哈希
  final String? transactionHash;

  /// 完成时间
  final DateTime fulfilledAt;

  const PaymentRequestFulfillmentContent({
    required this.requestId,
    required this.transferId,
    this.transferEventId,
    required this.payerAddress,
    required this.receiverAddress,
    required this.amount,
    required this.token,
    this.transactionHash,
    required this.fulfilledAt,
  });

  factory PaymentRequestFulfillmentContent.fromEventContent(
    Map<String, dynamic> content,
  ) {
    return PaymentRequestFulfillmentContent(
      requestId: content['request_id'] as String? ?? '',
      transferId: content['transfer_id'] as String? ?? '',
      transferEventId: content['transfer_event_id'] as String?,
      payerAddress: content['payer_address'] as String? ?? '',
      receiverAddress: content['receiver_address'] as String? ?? '',
      amount: content['amount'] as String? ?? '0',
      token: content['token'] as String? ?? '',
      transactionHash: content['tx_hash'] as String?,
      fulfilledAt: content['fulfilled_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (content['fulfilled_at'] as num).toInt(),
            )
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toEventContent() {
    return {
      'request_id': requestId,
      'transfer_id': transferId,
      'transfer_event_id': transferEventId,
      'payer_address': payerAddress,
      'receiver_address': receiverAddress,
      'amount': amount,
      'token': token,
      'tx_hash': transactionHash,
      'fulfilled_at': fulfilledAt.millisecondsSinceEpoch,
    };
  }
}
