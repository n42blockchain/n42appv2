import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/data/transaction_record_dao.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_record_helpers.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_chain_info_transactions_item.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

part 'transaction_history_list_logic.dart';
part 'transaction_history_list_widgets.dart';

class _TxFilter {
  final String? direction; // null=all, 'out'=sent, 'in'=received
  final int? status; // null=all, 0=pending, 1=success, 2=failed
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const _TxFilter({this.direction, this.status, this.dateFrom, this.dateTo});

  bool get isActive =>
      direction != null || status != null || dateFrom != null || dateTo != null;

  int get activeCount =>
      [direction, status, dateFrom, dateTo].where((e) => e != null).length;

  _TxFilter copyWith({
    Object? direction = _sentinel,
    Object? status = _sentinel,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
  }) {
    return _TxFilter(
      direction: direction == _sentinel ? this.direction : direction as String?,
      status: status == _sentinel ? this.status : status as int?,
      dateFrom: dateFrom == _sentinel ? this.dateFrom : dateFrom as DateTime?,
      dateTo: dateTo == _sentinel ? this.dateTo : dateTo as DateTime?,
    );
  }

  _TxFilter clear() => const _TxFilter();
}

const Object _sentinel = Object();

class TransactionHistoryList extends StatefulWidget {
  final CoinModel coinModel;

  const TransactionHistoryList(this.coinModel, {super.key});

  @override
  State<TransactionHistoryList> createState() => _TransactionHistoryListState();
}

class _TransactionHistoryListState extends State<TransactionHistoryList>
    with _TransactionHistoryLogicMixin, _TransactionHistoryWidgetsMixin {
  @override
  void initState() {
    super.initState();
    initLogic();
    loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final items = filtered;
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_coin_key_1,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: showFilterSheet,
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
                    onPressed: exportCsv,
                    tooltip: S.of(context).g_key_batch_export_csv,
                  ),
        ],
      ),
      body: SafeArea(child: _buildBody(items)),
    );
  }

  Widget _buildBody(List<dynamic> items) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return Center(
        child: Text(
          filter.isActive
              ? S.of(context).g_key_tx_no_results
              : S.of(context).g_key_132,
        ),
      );
    }
    final itemCount = items.length + (_isLoadingMore ? 1 : 0);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
          loadMore();
        }
        return false;
      },
      child: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.space8),
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.space8),
        itemBuilder: (ctx, i) {
          if (i >= items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final tx = items[i];
          final isBtcTx = tx is BtcTransactionRecodeModel;
          return WalletChainInfoTransactionsItem(
            coinModel: widget.coinModel,
            type: isBtcTx ? 0 : 1,
            transactionModel: tx,
            onBack: loadAll,
          );
        },
      ),
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
