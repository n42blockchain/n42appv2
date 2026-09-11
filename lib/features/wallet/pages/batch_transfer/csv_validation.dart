part of 'csv_import_page.dart';

/// CSV validation, import logic and shared state for [_CsvImportPageState].
mixin _CsvValidationMixin on State<CsvImportPage> {
  final TextEditingController _textController = TextEditingController();
  int _validLineCount = 0;
  bool _docExpanded = false;

  bool get _hasContent => _textController.text.trim().isNotEmpty;

  void _showSnack(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
      ),
    );
  }

  void _importData() {
    final rawContent = _textController.text.trim();
    if (rawContent.isEmpty) return;

    final dataLines = _filterDataLines(rawContent);
    if (dataLines.isEmpty) {
      _showSnack(S.of(context).g_ui_csv_no_data);
      return;
    }

    final hasHeader = _isHeaderLine(dataLines[0]);
    final rows = hasHeader ? dataLines.skip(1).toList() : dataLines;

    if (rows.isEmpty) {
      _showSnack(S.of(context).g_ui_csv_header_only);
      return;
    }
    if (rows.length > 200) {
      _showSnack(
        S.of(context).g_key_batch_max_recipients(200),
        color: AppColorTokens.of(context).warning,
      );
      return;
    }

    final errors = <String>[];
    final seenAddresses = <String>{};
    int validCount = 0;

    for (var i = 0; i < rows.length; i++) {
      final lineNum = i + (hasHeader ? 2 : 1);
      final parts = rows[i].split(',');

      if (parts.length < 2) {
        errors.add(S.of(context).g_ui_csv_missing_fields(lineNum));
        continue;
      }

      final address = parts[0].trim();
      final amount = parts[1].trim();

      if (!_evmAddressRegex.hasMatch(address)) {
        errors.add(S.of(context).g_key_batch_invalid_address(lineNum));
        continue;
      }
      if (!_isValidAmount(amount)) {
        errors.add(S.of(context).g_key_batch_invalid_amount(lineNum));
        continue;
      }

      final normalizedAddr = address.toLowerCase();
      if (seenAddresses.contains(normalizedAddr)) {
        errors.add(S.of(context).g_key_batch_duplicate_address(lineNum));
      }
      seenAddresses.add(normalizedAddr);
      validCount++;
    }

    if (errors.isEmpty) {
      Navigator.pop(context, rawContent);
      return;
    }
    _showValidationDialog(validCount, errors, rawContent);
  }

  List<String> _filterDataLines(String rawContent) {
    return rawContent
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toList();
  }

  bool _isHeaderLine(String line) {
    return line.toLowerCase().startsWith('address') ||
        (!line.startsWith('0x') && !_looksLikeDataRow(line));
  }

  bool _looksLikeDataRow(String line) {
    final parts = line.split(',');
    return parts.length >= 2 && parts[0].trim().startsWith('0x');
  }

  static final _evmAddressRegex = RegExp(r'^0x[a-fA-F0-9]{40}$');

  bool _isValidAmount(String amount) {
    final value = double.tryParse(
      amount.replaceAll(',', '').replaceAll(' ', ''),
    );
    return value != null && value > 0;
  }

  void _clearInput() => _textController.clear();

  void _copyTemplate() {
    const template =
        '# Batch transfer template\n'
        '# Columns: address, amount, memo(optional)\n'
        'address,amount,memo\n'
        '0x1234567890123456789012345678901234567890,1.5,Payment 1\n'
        '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd,2.0,Payment 2\n'
        '0x9876543210987654321098765432109876543210,0.5,';

    Clipboard.setData(const ClipboardData(text: template));
    _showSnack(S.of(context).g_ui_template_copied);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    if (data?.text != null && data!.text!.isNotEmpty) {
      _textController.text = data.text!;
    } else {
      _showSnack(S.of(context).g_ui_clipboard_empty);
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
        withReadStream: false,
      );
      if (!mounted) return;
      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        if (path != null) {
          final content = await File(path).readAsString();
          if (!mounted) return;
          _textController.text = content;
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack(
        S.of(context).g_ui_file_read_failed,
        color: AppColorTokens.of(context).danger,
      );
    }
  }

  void _showValidationDialog(
    int validCount,
    List<String> errors,
    String rawContent,
  ) {
    final c = AppColorTokens.of(context);
    final blue = c.brand;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: c.warning),
            const SizedBox(width: 8),
            Expanded(child: Text(S.of(context).g_ui_validation_issues)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S
                      .of(context)
                      .g_ui_validation_counts(validCount, errors.length),
                ),
                const SizedBox(height: 12),
                Text(
                  S.of(context).g_ui_issues_label,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: errors.length > 5 ? 5 : errors.length,
                    itemBuilder: (_, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        errors[index],
                        style: AppTypography.caption.copyWith(color: c.danger),
                      ),
                    ),
                  ),
                ),
                if (errors.length > 5)
                  Text(
                    S.of(context).g_ui_validation_more(errors.length - 5),
                    style: AppTypography.caption.copyWith(
                      color: c.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).g_key_79),
          ),
          if (validCount > 0)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, rawContent);
              },
              style: ElevatedButton.styleFrom(backgroundColor: blue),
              child: Text(
                S.of(context).g_ui_import_valid(validCount),
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
