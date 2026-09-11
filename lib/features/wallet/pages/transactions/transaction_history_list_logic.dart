part of 'transaction_history_list.dart';

mixin _TransactionHistoryLogicMixin on State<_TransactionHistoryView> {
  late final _repository = widget.repository ?? TransactionHistoryRepository();
  final List<Object> allRecords = [];
  TransactionHistoryFilter filter = const TransactionHistoryFilter();
  bool isLoading = true;
  bool isExporting = false;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _loadFailed = false;
  int _generation = 0;

  Future<void> loadAll() => _load(reset: true);
  Future<void> loadMore() => _load();

  Future<void> _load({bool reset = false}) async {
    if (!mounted || (!reset && (isLoading || _isLoadingMore || !_hasMore))) {
      return;
    }
    final generation = ++_generation;
    setState(() {
      _loadFailed = false;
      if (reset) {
        allRecords.clear();
        isLoading = true;
        _isLoadingMore = false;
        _hasMore = true;
      } else {
        _isLoadingMore = true;
      }
    });
    try {
      final page = await _repository.load(
        scope: widget.scope,
        filter: filter,
        offset: allRecords.length,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        allRecords.addAll(page.records);
        _hasMore = page.hasMore;
      });
    } catch (e) {
      AppLogger.w('TxHistory', 'load error: $e');
      if (mounted && generation == _generation) {
        setState(() => _loadFailed = true);
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() {
          isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> exportCsv(BuildContext anchor) async {
    if (isExporting || !widget.scope.isValid) return;
    final exportFilter = filter;
    final box = anchor.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    setState(() => isExporting = true);
    File? file;
    IOSink? sink;
    bool readyToShare = false;
    try {
      final tempDir = await getTemporaryDirectory();
      if (!mounted) return;
      final fileName = 'txhistory_${DateTime.now().microsecondsSinceEpoch}.csv';
      file = File('${tempDir.path}/$fileName');
      final output = file.openWrite();
      sink = output;
      await _repository.exportCsv(
        scope: widget.scope,
        filter: exportFilter,
        writeChunk: (chunk) async {
          if (!mounted) throw StateError('History account changed');
          output.write(chunk);
          await output.flush();
        },
      );
      await output.close();
      sink = null;
      if (!mounted) return;
      readyToShare = true;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv', name: fileName)],
          subject: S.of(context).g_history_export_all,
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      AppLogger.w('TxHistory', 'export error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).g_history_export_error)),
        );
      }
    } finally {
      try {
        await sink?.close();
        if (!readyToShare && file != null && await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Best-effort cleanup of an interrupted temporary export.
      }
      if (mounted) setState(() => isExporting = false);
    }
  }
}
