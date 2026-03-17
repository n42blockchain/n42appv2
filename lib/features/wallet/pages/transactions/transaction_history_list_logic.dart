part of 'transaction_history_list.dart';

/// Data loading, filter logic, and CSV export mixin for
/// [_TransactionHistoryListState].
///
/// Holds all mutable state fields and provides data manipulation methods.
/// Applied before [_TransactionHistoryWidgetsMixin] in the with-clause.
mixin _TransactionHistoryLogicMixin on State<TransactionHistoryList> {
  AppDatabase? _db;
  AppDatabase get db => _db ??= AppDatabase();

  late final String addr;
  late final bool isBtcChain;

  List<dynamic> allRecords = [];
  _TxFilter filter = const _TxFilter();
  bool isLoading = true;
  bool isExporting = false;

  List<dynamic> get filtered => _applyFilter(allRecords);

  void initLogic() {
    addr = widget.coinModel.address.toString();
    isBtcChain =
        widget.coinModel.coin['blockchainType'] == BlockchainType.Bitcoin.name;
  }

  Future<void> loadAll() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final coinKey = widget.coinModel.coin['coinType'] as String;
      final contract = resolveCoinContractForNetwork(
        coin: widget.coinModel.coin,
        isTest: widget.coinModel.isTest,
      );

      List<dynamic> list;
      if (isBtcChain) {
        list = await db.selectBtcTransationRecord(
          AppGlobals.userInfo?.uuid ?? '',
          addr,
          coinKey,
          0,
          pageSize: 5000,
          pageNum: 1,
        );
      } else {
        list = await db.selectTransationRecordMiniName(
          addr,
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
          allRecords = list;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[TxHistory] _loadAll error: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  List<dynamic> _applyFilter(List<dynamic> records) {
    if (!filter.isActive) return records;

    return records.where((tx) {
      // --- Direction filter ---
      if (filter.direction != null) {
        final bool isSent;
        if (tx is BtcTransactionRecodeModel) {
          isSent = tx.inputsAddressList.any(
            (a) => a.toUpperCase() == addr.toUpperCase(),
          );
        } else if (tx is TransationRecordModel) {
          isSent = tx.from1.toLowerCase() == addr.toLowerCase();
        } else {
          isSent = false;
        }
        if (filter.direction == 'out' && !isSent) return false;
        if (filter.direction == 'in' && isSent) return false;
      }

      // --- Status filter ---
      if (filter.status != null) {
        // Both models have a `state` field accessible via dynamic dispatch
        final int txState = (tx as dynamic).state as int;
        if (txState != filter.status) return false;
      }

      // --- Date filter ---
      if (filter.dateFrom != null || filter.dateTo != null) {
        final tsMs = txTimestampMs(tx);
        final dt = DateTime.fromMillisecondsSinceEpoch(tsMs);
        if (filter.dateFrom != null && dt.isBefore(filter.dateFrom!)) {
          return false;
        }
        if (filter.dateTo != null &&
            dt.isAfter(filter.dateTo!.add(const Duration(days: 1)))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// BTC stores seconds-precision timestamps; EVM stores milliseconds.
  /// Detect by magnitude: < 10^12 = seconds.
  int txTimestampMs(dynamic tx) {
    final String raw;
    if (tx is BtcTransactionRecodeModel) {
      raw = tx.txTime;
    } else {
      raw = (tx as TransationRecordModel).txTime;
    }
    final int ts = int.tryParse(raw) ?? 0;
    return ts < 1000000000000 ? ts * 1000 : ts;
  }

  Future<void> exportCsv() async {
    setState(() => isExporting = true);
    try {
      final rows = filtered;
      final buf = StringBuffer('\uFEFF'); // UTF-8 BOM for Excel compatibility
      buf.writeln('No,Time,Direction,Status,Amount,Token,From,To,TxHash');

      final dtFmt = DateFormat('yyyy-MM-dd HH:mm:ss');

      for (var i = 0; i < rows.length; i++) {
        final tx = rows[i];

        final tsMs = txTimestampMs(tx);
        final time = dtFmt.format(DateTime.fromMillisecondsSinceEpoch(tsMs));

        final bool isSent;
        final String fromAddr;
        final String toAddr;

        if (tx is BtcTransactionRecodeModel) {
          isSent = tx.inputsAddressList.any(
            (a) => a.toUpperCase() == addr.toUpperCase(),
          );
          fromAddr = addr;
          toAddr = tx.to1;
        } else if (tx is TransationRecordModel) {
          isSent = tx.from1.toLowerCase() == addr.toLowerCase();
          fromAddr = tx.from1;
          toAddr = tx.to1;
        } else {
          continue;
        }

        final amount = (tx as dynamic).priceDouble() as double;
        final coin = (tx as dynamic).coin as Map<String, dynamic>;
        final token =
            (coin['unit'] as String? ?? (tx as dynamic).coinMiniName as String)
                .toUpperCase();
        final int state = (tx as dynamic).state as int;
        final String txHash = (tx as dynamic).txHash as String;

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
      if (mounted) setState(() => isExporting = false);
    }
  }

  String _csvField(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  String _statusStr(int state) => switch (state) {
    0 => 'Pending',
    1 => 'Success',
    2 => 'Failed',
    _ => 'Unknown',
  };
}
