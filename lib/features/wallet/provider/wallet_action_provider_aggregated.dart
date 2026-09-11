part of 'wallet_action_provider.dart';

extension WalletActionProviderAggregated on WalletActionProvider {
  /// Aggregated presets are mainnet-only. Never reuse a test/custom-chain address.
  CoinModel? aggregateMainChain(AggregatedCoinModel aggregate, String symbol) {
    if (!isWalletReady) return null;
    final config = aggregate.tokenConfig.chains
        .where((c) => c.chainSymbol == symbol.toUpperCase())
        .firstOrNull;
    if (config == null) return null;
    return _coinModels
        .where(
          (coin) =>
              coin.config.coinType == config.chainSymbol &&
              !coin.isTest &&
              !coin.custom &&
              coin.coin['custom'] != true &&
              coin.address != null &&
              coin.address.toString().trim().isNotEmpty &&
              (config.chainId == 0 ||
                  config.rules == 'SPL' ||
                  coin.config.chainId == config.chainId),
        )
        .firstOrNull;
  }

  Map<String, String> _aggregateAddresses(AggregatedCoinModel aggregate) => {
    for (final config in aggregate.tokenConfig.chains)
      if (aggregateMainChain(aggregate, config.chainSymbol) case final chain?)
        config.chainSymbol: chain.address.toString(),
  };

  /// Refresh only objects still owned by this wallet/list. Late completions of
  /// a replaced wallet can update their own model, never the active total or UI.
  Future<void> refreshAggregatedBalances({
    AggregatedCoinModel? only,
    CoinModel? source,
  }) async {
    if (isDisposed || !isWalletReady) return;
    final owner = walletInfo;
    final detached =
        only != null &&
        source != null &&
        coinList.contains(source) &&
        identical(aggregatedTokenForCoin(source), only.tokenConfig);
    final aggregates = detached
        ? [only]
        : coinList
              .whereType<AggregatedCoinModel>()
              .where((coin) => only == null || identical(coin, only))
              .toList();
    await Future.wait(
      aggregates.map(
        (coin) => coin.fetchAllBalances(
          _aggregateAddresses(coin),
          onChanged: () {
            if (isDisposed ||
                !isWalletReady ||
                !identical(owner, walletInfo) ||
                !coinList.contains(source ?? coin)) {
              return;
            }
            if (coinList.contains(coin)) {
              calculateBalanceWidthCoinModel();
            }
            refresh();
          },
        ),
      ),
    );
  }

  /// A read-only token descriptor for the existing QR page; contains no key.
  CoinModel? aggregateReceiveToken(
    AggregatedCoinModel aggregate,
    String symbol, {
    CoinModel? source,
  }) {
    if (!coinList.contains(source ?? aggregate) ||
        (source != null &&
            !identical(aggregatedTokenForCoin(source), aggregate.tokenConfig)))
      return null;
    final chain = aggregateMainChain(aggregate, symbol);
    if (chain == null) return null;
    final config = aggregate.tokenConfig.chains.firstWhere(
      (c) => c.chainSymbol == symbol.toUpperCase(),
    );
    return CoinModel()
      ..coin = {
        ...chain.coin,
        'name': aggregate.tokenConfig.name,
        'miniName': aggregate.tokenConfig.symbol,
        'unit': aggregate.tokenConfig.symbol,
        'icon': aggregate.tokenConfig.icon,
        'isContract': true,
        'contract': config.contract,
        'contract_test': '',
        'decimals': config.decimals,
        'isAggregated': false,
      }
      ..address = chain.address
      ..isTest = false;
  }
}
