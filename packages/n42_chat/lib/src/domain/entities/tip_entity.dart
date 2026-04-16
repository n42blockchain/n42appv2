import 'package:equatable/equatable.dart';

/// 打赏消息实体
///
/// Matrix 自定义 msgtype: `n42.tip`。
/// 打赏 ≠ 转账：金额更小、不需要确认、附带被打赏的消息引用。
class TipEntity extends Equatable {
  const TipEntity({
    required this.tipId,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.token,
    this.txHash,
    this.targetMessageId,
    this.targetMessagePreview,
    this.memo,
    required this.createdAt,
    this.status = TipStatus.pending,
  });

  final String tipId;
  final String senderId;
  final String receiverId;
  final String amount;
  final String token;
  final String? txHash;
  final String? targetMessageId;
  final String? targetMessagePreview;
  final String? memo;
  final DateTime createdAt;
  final TipStatus status;

  static const String msgType = 'n42.tip';

  bool get isConfirmed => status == TipStatus.confirmed;

  Map<String, dynamic> toContent() => {
        'msgtype': msgType,
        'body': '${memo ?? "Tip"}: $amount $token',
        'tip_id': tipId,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'amount': amount,
        'token': token,
        if (txHash != null) 'tx_hash': txHash,
        if (targetMessageId != null) 'target_message_id': targetMessageId,
        if (targetMessagePreview != null)
          'target_message_preview': targetMessagePreview,
        if (memo != null) 'memo': memo,
        'status': status.name,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory TipEntity.fromContent(Map<String, dynamic> content) {
    return TipEntity(
      tipId: content['tip_id'] as String? ?? '',
      senderId: content['sender_id'] as String? ?? '',
      receiverId: content['receiver_id'] as String? ?? '',
      amount: content['amount'] as String? ?? '0',
      token: content['token'] as String? ?? 'ETH',
      txHash: content['tx_hash'] as String?,
      targetMessageId: content['target_message_id'] as String?,
      targetMessagePreview: content['target_message_preview'] as String?,
      memo: content['memo'] as String?,
      status: TipStatus.values.firstWhere(
        (e) => e.name == content['status'],
        orElse: () => TipStatus.pending,
      ),
      createdAt: content['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(content['created_at'] as int)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        tipId,
        senderId,
        receiverId,
        amount,
        token,
        txHash,
        targetMessageId,
        memo,
        createdAt,
        status,
      ];
}

enum TipStatus {
  pending,
  confirmed,
  failed,
}
