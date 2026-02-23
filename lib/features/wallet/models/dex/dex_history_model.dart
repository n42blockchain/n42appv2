class DexHistoryModel {
  final String orderId;
  final String chain;
  final String tokenInSymbol;
  final String tokenOutSymbol;
  final String amountIn;
  final String amountOut;
  final String source;
  final String txHash;
  final int status; // 0=quoted 1=committed 2=confirmed 3=failed
  final int createdAt;

  const DexHistoryModel({
    required this.orderId,
    required this.chain,
    required this.tokenInSymbol,
    required this.tokenOutSymbol,
    required this.amountIn,
    required this.amountOut,
    required this.source,
    required this.txHash,
    required this.status,
    required this.createdAt,
  });

  factory DexHistoryModel.fromJson(Map<String, dynamic> json) =>
      DexHistoryModel(
        orderId: json['order_id'] as String? ?? '',
        chain: json['chain'] as String? ?? '',
        tokenInSymbol: json['token_in_symbol'] as String? ?? '',
        tokenOutSymbol: json['token_out_symbol'] as String? ?? '',
        amountIn: json['amount_in'] as String? ?? '',
        amountOut: json['amount_out'] as String? ?? '',
        source: json['source'] as String? ?? '',
        txHash: json['tx_hash'] as String? ?? '',
        status: json['status'] as int? ?? 0,
        createdAt: json['created_at'] as int? ?? 0,
      );

  String get statusText {
    switch (status) {
      case 1:
        return 'Pending';
      case 2:
        return 'Confirmed';
      case 3:
        return 'Failed';
      default:
        return 'Quoted';
    }
  }
}
