class DexQuoteModel {
  final String orderId;
  final String tokenInSymbol;
  final String tokenOutSymbol;
  final String amountIn;
  final String amountOut;
  final String priceImpact;
  final String gasEstimate;
  final String source;
  final String calldata;
  final String routerAddr;
  final String chain;

  const DexQuoteModel({
    required this.orderId,
    required this.tokenInSymbol,
    required this.tokenOutSymbol,
    required this.amountIn,
    required this.amountOut,
    required this.priceImpact,
    required this.gasEstimate,
    required this.source,
    required this.calldata,
    required this.routerAddr,
    required this.chain,
  });

  factory DexQuoteModel.fromJson(Map<String, dynamic> json) => DexQuoteModel(
        orderId: json['order_id'] as String? ?? '',
        tokenInSymbol: json['token_in_symbol'] as String? ?? '',
        tokenOutSymbol: json['token_out_symbol'] as String? ?? '',
        amountIn: json['amount_in'] as String? ?? '',
        amountOut: json['amount_out'] as String? ?? '',
        priceImpact: json['price_impact'] as String? ?? '',
        gasEstimate: json['gas_estimate'] as String? ?? '',
        source: json['source'] as String? ?? '',
        calldata: json['calldata'] as String? ?? '',
        routerAddr: json['router_addr'] as String? ?? '',
        chain: json['chain'] as String? ?? '',
      );
}
