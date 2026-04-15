/// 限价单数据模型
class DexLimitOrderModel {
  final String orderId;
  final String chain;
  final String symbolIn;
  final String symbolOut;
  final String amountIn;
  final String limitPrice;
  final int expiresAt;
  final int status; // 0=active, 1=triggered, 2=executed, 3=cancelled, 4=expired
  final String txHash;
  final int createdAt;

  const DexLimitOrderModel({
    required this.orderId,
    required this.chain,
    required this.symbolIn,
    required this.symbolOut,
    required this.amountIn,
    required this.limitPrice,
    required this.expiresAt,
    required this.status,
    this.txHash = '',
    required this.createdAt,
  });

  factory DexLimitOrderModel.fromJson(Map<String, dynamic> json) {
    return DexLimitOrderModel(
      orderId: json['order_id'] as String? ?? '',
      chain: json['chain'] as String? ?? '',
      symbolIn: json['symbol_in'] as String? ?? '',
      symbolOut: json['symbol_out'] as String? ?? '',
      amountIn: json['amount_in'] as String? ?? '0',
      limitPrice: json['limit_price'] as String? ?? '0',
      expiresAt: json['expires_at'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      txHash: json['tx_hash'] as String? ?? '',
      createdAt: json['created_at'] as int? ?? 0,
    );
  }

  bool get isActive => status == 0;
  bool get isTriggered => status == 1;
  bool get isExecuted => status == 2;
  bool get isCancelled => status == 3;
  bool get isExpired => status == 4;

  String get statusLabel => switch (status) {
    0 => 'Active',
    1 => 'Triggered',
    2 => 'Executed',
    3 => 'Cancelled',
    4 => 'Expired',
    _ => 'Unknown',
  };
}
