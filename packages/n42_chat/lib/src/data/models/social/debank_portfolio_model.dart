/// DeBank portfolio data model.
///
/// Maps the `/user/total_balance` API response into a typed Dart object.
class DeBankPortfolioModel {
  /// Total portfolio value in USD across all chains.
  final double totalUsdValue;

  /// Per-chain USD balances keyed by DeBank chain ID (e.g. "eth", "bsc").
  final Map<String, double> chainBalances;

  const DeBankPortfolioModel({
    this.totalUsdValue = 0,
    this.chainBalances = const {},
  });

  /// Construct from the DeBank `/user/total_balance` JSON response.
  factory DeBankPortfolioModel.fromJson(Map<String, dynamic> json) {
    final chainList = json['chain_list'] as List<dynamic>? ?? [];
    final chainBalances = <String, double>{};

    for (final chain in chainList) {
      if (chain is Map<String, dynamic>) {
        final id = chain['id'] as String? ?? '';
        final usdValue = (chain['usd_value'] as num?)?.toDouble() ?? 0;
        if (id.isNotEmpty) chainBalances[id] = usdValue;
      }
    }

    return DeBankPortfolioModel(
      totalUsdValue: (json['total_usd_value'] as num?)?.toDouble() ?? 0,
      chainBalances: chainBalances,
    );
  }

  /// Serialize to JSON for caching.
  Map<String, dynamic> toJson() => {
        'total_usd_value': totalUsdValue,
        'chain_list': chainBalances.entries
            .map((e) => {'id': e.key, 'usd_value': e.value})
            .toList(),
      };
}
