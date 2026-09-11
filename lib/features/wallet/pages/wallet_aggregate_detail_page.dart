import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/wallet/models/aggregated_coin_model.dart';
import 'package:n42_wallet/features/wallet/models/aggregated_token.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_chain_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_receive_qr.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/utils/decimal_amount.dart';
import 'package:n42_wallet/generated/l10n.dart';

class WalletAggregateDetailPage extends ConsumerStatefulWidget {
  const WalletAggregateDetailPage({super.key, required this.coin});
  final CoinModel coin;

  @override
  ConsumerState<WalletAggregateDetailPage> createState() =>
      _WalletAggregateDetailPageState();
}

class _WalletAggregateDetailPageState
    extends ConsumerState<WalletAggregateDetailPage> {
  CoinModel get coin => widget.coin;
  late final AggregatedCoinModel? aggregate;
  @override
  void initState() {
    super.initState();
    final preset = aggregatedTokenForCoin(coin);
    aggregate = coin is AggregatedCoinModel
        ? coin as AggregatedCoinModel
        : preset == null
        ? null
        : AggregatedCoinModel(tokenConfig: preset);
    if (aggregate != null && coin is! AggregatedCoinModel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(wapBridgeProvider)
              .refreshAggregatedBalances(only: aggregate, source: coin);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final aggregate = this.aggregate;
    final wallet = ref.watch(wapBridgeProvider);
    final s = S.of(context);
    final active =
        aggregate != null &&
        wallet.isWalletReady &&
        wallet.coinList.contains(coin);
    final currentAddresses = <String, String>{
      if (aggregate != null)
        for (final config in aggregate.tokenConfig.chains)
          if (wallet.aggregateMainChain(aggregate, config.chainSymbol)
              case final chain?)
            config.chainSymbol: chain.address.toString(),
    };
    final hasKnownBalance =
        aggregate?.chainBalances.entries.any(
          (entry) => currentAddresses[entry.key] == entry.value.address,
        ) ??
        false;
    final complete =
        aggregate != null &&
        !aggregate.hasIncompleteBalance &&
        currentAddresses.length == aggregate.tokenConfig.chains.length;
    return Scaffold(
      key: const ValueKey('wallet_aggregate_detail'),
      appBar: AppBar(
        title: Text(coin.config.miniName),
        actions: [
          if (active)
            IconButton(
              key: const ValueKey('aggregate_refresh'),
              tooltip: s.g_key_bridge_refresh,
              onPressed: aggregate.isRefresh
                  ? null
                  : () => wallet.refreshAggregatedBalances(
                      only: aggregate,
                      source: coin,
                    ),
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: !active
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(s.g_aggregate_unavailable),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => wallet.refreshAggregatedBalances(
                only: aggregate,
                source: coin,
              ),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    s.g_aggregate_network_balances,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    !complete
                        ? s.g_aggregate_known_balance
                        : s.g_key_nft_balance,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    !hasKnownBalance
                        ? '—'
                        : '${aggregate.balanceStringForAddresses(currentAddresses)} ${aggregate.tokenConfig.symbol}',
                    key: const ValueKey('aggregate_total'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.g_aggregate_mainnet_note,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  for (final config in aggregate.tokenConfig.chains)
                    _NetworkBalance(
                      aggregate: aggregate,
                      source: coin,
                      config: config,
                      wallet: wallet,
                    ),
                ],
              ),
            ),
    );
  }
}

class _NetworkBalance extends StatelessWidget {
  const _NetworkBalance({
    required this.aggregate,
    required this.source,
    required this.config,
    required this.wallet,
  });
  final AggregatedCoinModel aggregate;
  final CoinModel source;
  final ChainTokenConfig config;
  final WalletActionProvider wallet;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final status = aggregate.statusFor(config.chainSymbol);
    final chain = wallet.aggregateMainChain(aggregate, config.chainSymbol);
    final stored = aggregate.getChainBalance(config.chainSymbol);
    // Network/address changes invalidate old details even before the next refresh.
    final balance = chain != null && stored?.address == chain.address.toString()
        ? stored
        : null;
    final label = chain == null
        ? s.g_aggregate_no_mainnet
        : switch (status) {
            AggregateBalanceStatus.loading => s.g_key_106.trim(),
            AggregateBalanceStatus.ready => '',
            AggregateBalanceStatus.stale => s.g_aggregate_cached_balance,
            AggregateBalanceStatus.error => s.g_wallet_balance_warning,
            AggregateBalanceStatus.unavailable => s.g_aggregate_not_loaded,
          };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              config.chainSymbol,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            SelectableText(
              balance == null
                  ? '—'
                  : '${bigIntToDecimalString(balance.balance, balance.decimals)} ${aggregate.tokenConfig.symbol}',
              key: ValueKey('aggregate_balance_${config.chainSymbol}'),
            ),
            if (label.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  label,
                  key: ValueKey('aggregate_status_${config.chainSymbol}'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              s.g_key_nft_contract,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            SelectableText(
              config.contract,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (chain != null) ...[
              const SizedBox(height: 8),
              Text(
                s.g_key_address,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              SelectableText(
                chain.address.toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    key: ValueKey('aggregate_copy_${config.chainSymbol}'),
                    onPressed: () async {
                      if (!wallet.coinList.contains(source)) return;
                      final current = wallet.aggregateMainChain(
                        aggregate,
                        config.chainSymbol,
                      );
                      if (current == null) return;
                      await Clipboard.setData(
                        ClipboardData(text: current.address.toString()),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(s.g_key_hw_address_copied)),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: Text(s.copyAddress),
                  ),
                  TextButton.icon(
                    key: ValueKey('aggregate_receive_${config.chainSymbol}'),
                    onPressed: () {
                      final current = wallet.aggregateMainChain(
                        aggregate,
                        config.chainSymbol,
                      );
                      final token = wallet.aggregateReceiveToken(
                        aggregate,
                        config.chainSymbol,
                        source: source,
                      );
                      if (current == null || token == null) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              WalletReceiveQr(current, tokenCoinModel: token),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code, size: 18),
                    label: Text(s.g_key_33),
                  ),
                  TextButton(
                    key: ValueKey('aggregate_network_${config.chainSymbol}'),
                    onPressed: () {
                      if (!wallet.coinList.contains(source)) return;
                      final current = wallet.aggregateMainChain(
                        aggregate,
                        config.chainSymbol,
                      );
                      if (current == null) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WalletChainInfo(current),
                        ),
                      );
                    },
                    child: Text(s.g_aggregate_open_network),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
