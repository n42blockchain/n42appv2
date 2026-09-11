import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_chain_info_transactions_item.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:n42_wallet/features/wallet/data/transaction_history_query.dart';
import 'package:n42_wallet/features/wallet/data/transaction_history_repository.dart';

part 'transaction_history_list_logic.dart';
part 'transaction_history_list_widgets.dart';

class TransactionHistoryList extends ConsumerWidget {
  final CoinModel coinModel;
  final TransactionHistoryRepository? repository;
  const TransactionHistoryList(this.coinModel, {super.key, this.repository});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)?.uuid ?? '';
    final scope = TransactionHistoryScope.fromCoin(userId, coinModel);
    return _TransactionHistoryView(
      key: ValueKey(scope.key),
      coinModel: coinModel,
      scope: scope,
      repository: repository,
    );
  }
}

class _TransactionHistoryView extends StatefulWidget {
  final CoinModel coinModel;
  final TransactionHistoryScope scope;
  final TransactionHistoryRepository? repository;
  const _TransactionHistoryView({
    super.key,
    required this.coinModel,
    required this.scope,
    this.repository,
  });
  @override
  State<_TransactionHistoryView> createState() =>
      _TransactionHistoryListState();
}

class _TransactionHistoryListState extends State<_TransactionHistoryView>
    with _TransactionHistoryLogicMixin, _TransactionHistoryWidgetsMixin {
  @override
  void initState() {
    super.initState();
    loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final items = allRecords;
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_coin_key_1,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: isExporting ? null : showFilterSheet,
                tooltip: S.of(context).g_key_filter,
              ),
              if (filter.isActive)
                Positioned(
                  right: 6,
                  top: 6,
                  child: _FilterBadge(filter.activeCount),
                ),
            ],
          ),
          if (allRecords.isNotEmpty)
            isExporting
                ? SizedBox(
                    width: 48,
                    child: Center(
                      child: CupertinoActivityIndicator(radius: 10.r),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.download_outlined),
                    onPressed: () => exportCsv(context),
                    tooltip: S.of(context).g_history_export_all,
                  ),
        ],
      ),
      body: SafeArea(child: _buildBody(items)),
    );
  }

  Widget _buildBody(List<Object> items) {
    final s = S.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(s.g_history_local_scope, style: AppTypography.caption),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: loadAll,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(AppSpacing.space8),
              itemCount: items.length + 1,
              separatorBuilder: (_, _) => SizedBox(height: AppSpacing.space8),
              itemBuilder: (ctx, i) {
                if (i == items.length) {
                  if (isLoading || _isLoadingMore) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_loadFailed) {
                    return Column(
                      children: [
                        Text(s.g_audit_activity_error),
                        TextButton(
                          onPressed: items.isEmpty ? loadAll : loadMore,
                          child: Text(s.g_key_retry),
                        ),
                      ],
                    );
                  }
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        filter.isActive ? s.g_key_tx_no_results : s.g_key_132,
                      ),
                    );
                  }
                  if (_hasMore) {
                    return TextButton(
                      onPressed: loadMore,
                      child: Text(s.g_audit_load_more),
                    );
                  }
                  return const SizedBox.shrink();
                }
                final tx = items[i];
                return WalletChainInfoTransactionsItem(
                  coinModel: widget.coinModel,
                  type: tx is BtcTransactionRecodeModel ? 0 : 1,
                  transactionModel: tx,
                  onBack: loadAll,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterBadge extends StatelessWidget {
  final int count;

  const _FilterBadge(this.count);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: AppTypography.captionSm.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
