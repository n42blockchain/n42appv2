import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/src/component/enums/coin_type.dart';
import 'package:n42_wallet/src/sqlite/app_database.dart';
import 'package:n42_wallet/src/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/src/wallet/models/coin_model.dart';
import 'package:n42_wallet/src/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/src/wallet/widgets/wallet_chain_info_transactions_item.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ---------------------------------------------------------------------------
// Internal filter model
// ---------------------------------------------------------------------------

class _TxFilter {
  final String? direction; // null=all, 'out'=sent, 'in'=received
  final int? status;       // null=all, 0=pending, 1=success, 2=failed
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const _TxFilter({
    this.direction,
    this.status,
    this.dateFrom,
    this.dateTo,
  });

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

// Sentinel object for copyWith optional params
const Object _sentinel = Object();

// ---------------------------------------------------------------------------
// Page widget
// ---------------------------------------------------------------------------

class TransactionHistoryList extends StatefulWidget {
  final CoinModel coinModel;

  const TransactionHistoryList(this.coinModel, {super.key});

  @override
  State<TransactionHistoryList> createState() => _TransactionHistoryListState();
}

class _TransactionHistoryListState extends State<TransactionHistoryList> {
  AppDatabase? _db;
  AppDatabase get db => _db ??= AppDatabase();

  late final String _addr;
  late final bool _isBtcChain;

  List<dynamic> _allRecords = [];
  _TxFilter _filter = const _TxFilter();
  bool _isLoading = true;
  bool _isExporting = false;

  List<dynamic> get _filtered => _applyFilter(_allRecords);

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _addr = widget.coinModel.address.toString();
    _isBtcChain =
        widget.coinModel.coin['blockchainType'] == BlockchainType.Bitcoin.name;
    _loadAll();
  }

  // -------------------------------------------------------------------------
  // Data loading
  // -------------------------------------------------------------------------

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final coinKey = widget.coinModel.coin['coinType'] as String;
      final contract = widget.coinModel.coin['contract'] as String? ?? '';

      List<dynamic> list;
      if (_isBtcChain) {
        list = await db.selectBtcTransationRecord(
          AppGlobals.userInfo?.uuid ?? '',
          _addr,
          coinKey,
          0,
          pageSize: 5000,
          pageNum: 1,
        );
      } else {
        list = await db.selectTransationRecordMiniName(
          _addr,
          coinKey,
          0,
          contract: contract,
          pageSize: 5000,
          pageNum: 1,
          isTest: widget.coinModel.isTest ? 1 : 0,
        );
      }
      if (mounted) {
        setState(() {
          _allRecords = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[TxHistory] _loadAll error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // -------------------------------------------------------------------------
  // Filter logic
  // -------------------------------------------------------------------------

  List<dynamic> _applyFilter(List<dynamic> records) {
    if (!_filter.isActive) return records;

    return records.where((tx) {
      // --- Direction filter ---
      if (_filter.direction != null) {
        final bool isSent;
        if (tx is BtcTransactionRecodeModel) {
          isSent = tx.inputsAddressList
              .any((a) => a.toUpperCase() == _addr.toUpperCase());
        } else if (tx is TransationRecordModel) {
          isSent = tx.from1.toLowerCase() == _addr.toLowerCase();
        } else {
          isSent = false;
        }
        if (_filter.direction == 'out' && !isSent) return false;
        if (_filter.direction == 'in' && isSent) return false;
      }

      // --- Status filter ---
      if (_filter.status != null) {
        // Both models have a `state` field accessible via dynamic dispatch
        final int txState = (tx as dynamic).state as int;
        if (txState != _filter.status) return false;
      }

      // --- Date filter ---
      if (_filter.dateFrom != null || _filter.dateTo != null) {
        final tsMs = _txTimestampMs(tx);
        final dt = DateTime.fromMillisecondsSinceEpoch(tsMs);
        if (_filter.dateFrom != null && dt.isBefore(_filter.dateFrom!)) {
          return false;
        }
        if (_filter.dateTo != null &&
            dt.isAfter(_filter.dateTo!.add(const Duration(days: 1)))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// BTC stores seconds-precision timestamps; EVM stores milliseconds.
  /// Detect by magnitude: < 10^12 ≈ seconds.
  int _txTimestampMs(dynamic tx) {
    final String raw;
    if (tx is BtcTransactionRecodeModel) {
      raw = tx.txTime;
    } else {
      raw = (tx as TransationRecordModel).txTime;
    }
    final int ts = int.tryParse(raw) ?? 0;
    return ts < 1000000000000 ? ts * 1000 : ts;
  }

  // -------------------------------------------------------------------------
  // Filter bottom sheet
  // -------------------------------------------------------------------------

  void _showFilterSheet() {
    _TxFilter temp = _filter;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSS) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 16.h,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 16.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Header row ----
                    Row(
                      children: [
                        Text(
                          S.of(ctx).g_key_filter,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => setSS(() => temp = temp.clear()),
                          child: Text(S.of(ctx).g_key_reset),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // ---- Direction ----
                    Text(
                      S.of(ctx).g_key_tx_filter_direction,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: temp.direction == null,
                          onSelected: (_) =>
                              setSS(() => temp = temp.copyWith(direction: null)),
                        ),
                        ChoiceChip(
                          label: Text(S.of(ctx).g_key_t_4),
                          selected: temp.direction == 'out',
                          onSelected: (_) => setSS(
                              () => temp = temp.copyWith(direction: 'out')),
                        ),
                        ChoiceChip(
                          label: Text(S.of(ctx).g_key_t_5),
                          selected: temp.direction == 'in',
                          onSelected: (_) =>
                              setSS(() => temp = temp.copyWith(direction: 'in')),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // ---- Status ----
                    Text(
                      S.of(ctx).g_key_wallet_k33,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: temp.status == null,
                          onSelected: (_) =>
                              setSS(() => temp = temp.copyWith(status: null)),
                        ),
                        // state 1 = Complete
                        ChoiceChip(
                          label: Text(S.of(ctx).g_key_t_1),
                          selected: temp.status == 1,
                          onSelected: (_) =>
                              setSS(() => temp = temp.copyWith(status: 1)),
                        ),
                        // state 0 = Pending
                        ChoiceChip(
                          label: Text(S.of(ctx).g_key_t_2),
                          selected: temp.status == 0,
                          onSelected: (_) =>
                              setSS(() => temp = temp.copyWith(status: 0)),
                        ),
                        // state 2 = Failure
                        ChoiceChip(
                          label: Text(S.of(ctx).g_key_t_3),
                          selected: temp.status == 2,
                          onSelected: (_) =>
                              setSS(() => temp = temp.copyWith(status: 2)),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // ---- Date range ----
                    Text(
                      S.of(ctx).g_key_tx_filter_date_range,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        temp.dateFrom == null && temp.dateTo == null
                            ? '${S.of(ctx).g_key_tx_filter_date_from} → ${S.of(ctx).g_key_tx_filter_date_to}'
                            : '${temp.dateFrom != null ? DateFormat('yyyy-MM-dd').format(temp.dateFrom!) : S.of(ctx).g_key_tx_filter_date_from}'
                                ' → '
                                '${temp.dateTo != null ? DateFormat('yyyy-MM-dd').format(temp.dateTo!) : S.of(ctx).g_key_tx_filter_date_to}',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      trailing: Icon(
                        Icons.calendar_today_outlined,
                        size: 20.r,
                      ),
                      onTap: () async {
                        final range = await showDateRangePicker(
                          context: ctx,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange: temp.dateFrom != null
                              ? DateTimeRange(
                                  start: temp.dateFrom!,
                                  end: temp.dateTo ?? DateTime.now(),
                                )
                              : null,
                        );
                        if (range != null) {
                          setSS(() => temp = temp.copyWith(
                                dateFrom: range.start,
                                dateTo: range.end,
                              ));
                        }
                      },
                    ),
                    if (temp.dateFrom != null || temp.dateTo != null)
                      TextButton(
                        onPressed: () => setSS(
                          () => temp = temp.copyWith(
                            dateFrom: null,
                            dateTo: null,
                          ),
                        ),
                        child: const Text('Clear dates'),
                      ),
                    SizedBox(height: 16.h),

                    // ---- Confirm ----
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _filter = temp);
                          Navigator.pop(ctx);
                        },
                        child: Text(S.of(ctx).g_key_78),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // CSV export
  // -------------------------------------------------------------------------

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);
    try {
      final rows = _filtered;
      final buf = StringBuffer('\uFEFF'); // UTF-8 BOM for Excel compatibility
      buf.writeln('No,Time,Direction,Status,Amount,Token,From,To,TxHash');

      final dtFmt = DateFormat('yyyy-MM-dd HH:mm:ss');

      for (var i = 0; i < rows.length; i++) {
        final tx = rows[i];

        final tsMs = _txTimestampMs(tx);
        final time = dtFmt.format(DateTime.fromMillisecondsSinceEpoch(tsMs));

        final bool isSent;
        final String fromAddr;
        final String toAddr;
        final double amount;
        final String token;
        final int state;
        final String txHash;

        if (tx is BtcTransactionRecodeModel) {
          isSent = tx.inputsAddressList
              .any((a) => a.toUpperCase() == _addr.toUpperCase());
          fromAddr = _addr;
          toAddr = tx.to1;
          amount = tx.priceDouble();
          token = (tx.coin['unit'] as String? ?? tx.coinMiniName).toUpperCase();
          state = tx.state;
          txHash = tx.txHash;
        } else if (tx is TransationRecordModel) {
          isSent = tx.from1.toLowerCase() == _addr.toLowerCase();
          fromAddr = tx.from1;
          toAddr = tx.to1;
          amount = tx.priceDouble();
          token = (tx.coin['unit'] as String? ?? tx.coinMiniName).toUpperCase();
          state = tx.state;
          txHash = tx.txHash;
        } else {
          continue;
        }

        final direction = isSent ? 'Send' : 'Receive';
        final status = _statusStr(state);

        buf.writeln(
          '${i + 1},$time,$direction,$status,$amount,$token,'
          '${_csvField(fromAddr)},${_csvField(toAddr)},${_csvField(txHash)}',
        );
      }

      final tempDir = await getTemporaryDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'txhistory_$ts.csv';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(buf.toString());

      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv', name: fileName)],
          subject: S.of(context).g_key_batch_export_csv,
        ),
      );
    } catch (e) {
      debugPrint('[TxHistory] exportCsv error: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  String _csvField(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  String _statusStr(int state) {
    switch (state) {
      case 0:
        return 'Pending';
      case 1:
        return 'Success';
      case 2:
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_coin_key_1,
        actions: [
          // Filter button with active-count badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterSheet,
              ),
              if (_filter.isActive)
                Positioned(
                  right: 6,
                  top: 6,
                  child: _FilterBadge(_filter.activeCount),
                ),
            ],
          ),
          // Export button (only when there are records)
          if (_allRecords.isNotEmpty)
            _isExporting
                ? SizedBox(
                    width: 48,
                    child: Center(
                      child: CupertinoActivityIndicator(radius: 10.r),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.download_outlined),
                    onPressed: _exportCsv,
                    tooltip: S.of(context).g_key_batch_export_csv,
                  ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : filtered.isEmpty
                ? Center(
                    child: Text(
                      _filter.isActive
                          ? S.of(context).g_key_tx_no_results
                          : S.of(context).g_key_132,
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: ScreenUtil().setWidth(30)),
                    itemBuilder: (ctx, i) {
                      final tx = filtered[i];
                      final isBtcTx = tx is BtcTransactionRecodeModel;
                      return WalletChainInfoTransactionsItem(
                        coinModel: widget.coinModel,
                        type: isBtcTx ? 0 : 1,
                        transactionModel: tx,
                        onBack: _loadAll,
                      );
                    },
                  ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Badge widget for filter active count
// ---------------------------------------------------------------------------

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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
