class DexQuoteModel {
  final String orderId;
  final String tokenInSymbol;
  final String tokenOutSymbol;
  final String amountIn;
  final String amountOut;

  /// Human-readable minimum output after slippage (e.g. "99.5 USDC").
  /// Computed locally when not returned by the server.
  final String minAmountOut;

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
    required this.minAmountOut,
    required this.priceImpact,
    required this.gasEstimate,
    required this.source,
    required this.calldata,
    required this.routerAddr,
    required this.chain,
  });

  factory DexQuoteModel.fromJson(Map<String, dynamic> json,
      {int slippageBps = 50}) {
    final amountOut = json['amount_out'] as String? ?? '';
    final minOut =
        json['min_amount_out'] as String? ?? _calcMinOut(amountOut, slippageBps);
    return DexQuoteModel(
      orderId: json['order_id'] as String? ?? '',
      tokenInSymbol: json['token_in_symbol'] as String? ?? '',
      tokenOutSymbol: json['token_out_symbol'] as String? ?? '',
      amountIn: json['amount_in'] as String? ?? '',
      amountOut: amountOut,
      minAmountOut: minOut,
      priceImpact: json['price_impact'] as String? ?? '',
      gasEstimate: json['gas_estimate'] as String? ?? '',
      source: json['source'] as String? ?? '',
      calldata: json['calldata'] as String? ?? '',
      routerAddr: json['router_addr'] as String? ?? '',
      chain: json['chain'] as String? ?? '',
    );
  }

  /// Parse [priceImpact] string to a number for threshold comparisons.
  /// Returns 0 if the string is not parseable.
  double get priceImpactNum {
    final clean = priceImpact.replaceAll('%', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  static final RegExp _trailingZeros = RegExp(r'0+$');

  static String _calcMinOut(String amountOut, int slippageBps) {
    try {
      // Split into integer and fractional parts
      final parts = amountOut.split('.');
      final intStr = parts[0].isEmpty ? '0' : parts[0];
      final fracStr = parts.length > 1 ? parts[1] : '';

      // Work in units of 1e-{fracLen} to stay integer
      final fracLen = fracStr.length;
      final intPart = BigInt.parse(intStr);
      final fracPart = fracStr.isEmpty ? BigInt.zero : BigInt.parse(fracStr);

      final scale = BigInt.from(10).pow(fracLen);
      final total = intPart * scale + fracPart; // amount × 10^fracLen

      final numerator = total * BigInt.from(10000 - slippageBps);
      final result = numerator ~/ BigInt.from(10000); // floor division

      final resultInt = result ~/ scale;
      final resultFrac = (result % scale).toString().padLeft(fracLen, '0');

      if (fracLen == 0) return resultInt.toString();
      return '$resultInt.${resultFrac.replaceAll(_trailingZeros, '')}';
    } catch (_) {
      return amountOut;
    }
  }
}
