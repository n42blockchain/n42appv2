class DexQuoteModel {
  final String accountAddress;
  final String txValue;
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
    this.txValue = '0',
    this.accountAddress = '',
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

  factory DexQuoteModel.fromJson(
    Map<String, dynamic> json, {
    int slippageBps = 50,
    int? outputDecimals,
  }) {
    final raw = json['amount_out_raw']?.toString();
    final rawAmount = raw == null ? null : BigInt.tryParse(raw);
    if (raw != null && (rawAmount == null || rawAmount <= BigInt.zero)) {
      throw const FormatException('Invalid raw quote output');
    }
    if (slippageBps < 0 || slippageBps > 10000) {
      throw const FormatException('Invalid slippage');
    }
    final hasRaw = rawAmount != null && outputDecimals != null;
    final amountOut = hasRaw
        ? dexBaseUnitsToDecimal(rawAmount, outputDecimals)
        : json['amount_out'] as String? ?? '';
    final minOut = hasRaw
        ? dexBaseUnitsToDecimal(
            rawAmount * BigInt.from(10000 - slippageBps) ~/ BigInt.from(10000),
            outputDecimals,
          )
        : json['min_amount_out'] as String? ??
              _calcMinOut(amountOut, slippageBps);
    return DexQuoteModel(
      accountAddress: json['user_addr']?.toString() ?? '',
      txValue: json['tx_value']?.toString() ?? '0',
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

      return dexBaseUnitsToDecimal(
        total * BigInt.from(10000 - slippageBps),
        fracLen + 4,
      );
    } catch (_) {
      return amountOut;
    }
  }
}

/// Exact base-unit formatting for all token precisions; never passes via double.
String dexBaseUnitsToDecimal(BigInt amount, int decimals) {
  if (decimals < 0 || decimals > 255 || amount < BigInt.zero) {
    throw const FormatException('Invalid token amount or decimals');
  }
  if (decimals == 0) return amount.toString();
  final digits = amount.toString().padLeft(decimals + 1, '0');
  final split = digits.length - decimals;
  final fraction = digits.substring(split).replaceFirst(RegExp(r'0+$'), '');
  return fraction.isEmpty
      ? digits.substring(0, split)
      : '${digits.substring(0, split)}.$fraction';
}
