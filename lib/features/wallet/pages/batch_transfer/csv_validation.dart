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
      _showSnack('No data found after removing comments.');
      return;
    }

    final hasHeader = _isHeaderLine(dataLines[0]);
    final rows = hasHeader ? dataLines.skip(1).toList() : dataLines;

    if (rows.isEmpty) {
      _showSnack('No data rows found (only header detected).');
      return;
    }
    if (rows.length > 200) {
      _showSnack(S.of(context).g_key_batch_max_recipients(200),
          color: Colors.orange);
      return;
    }

    final errors = <String>[];
    final seenAddresses = <String>{};
    int validCount = 0;

    for (var i = 0; i < rows.length; i++) {
      final lineNum = i + (hasHeader ? 2 : 1);
      final parts = rows[i].split(',');

      if (parts.length < 2) {
        errors.add(
            '${S.of(context).g_key_batch_invalid_address(lineNum)}: missing fields');
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
    final value = double.tryParse(amount.replaceAll(',', '').replaceAll(' ', ''));
    return value != null && value > 0;
  }

  void _clearInput() => _textController.clear();

  void _copyTemplate() {
    const template = '# Batch transfer template\n'
        '# Columns: address, amount, memo(optional)\n'
        'address,amount,memo\n'
        '0x1234567890123456789012345678901234567890,1.5,Payment 1\n'
        '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd,2.0,Payment 2\n'
        '0x9876543210987654321098765432109876543210,0.5,';

    Clipboard.setData(const ClipboardData(text: template));
    _showSnack('${S.of(context).g_key_119} — Template');
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    if (data?.text != null && data!.text!.isNotEmpty) {
      _textController.text = data.text!;
    } else {
      _showSnack('Clipboard is empty');
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
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
      _showSnack('Failed to read file: $e', color: Colors.red);
    }
  }

  void _showValidationDialog(
      int validCount, List<String> errors, String rawContent) {
    final blue = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text('Validation Issues'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Found $validCount valid, ${errors.length} issue(s).'),
              const SizedBox(height: 12),
              const Text('Issues:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
                      style: const TextStyle(
                          fontSize: 12, color: Colors.red),
                    ),
                  ),
                ),
              ),
              if (errors.length > 5)
                Text(
                  '… and ${errors.length - 5} more issues',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
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
                'Import $validCount Valid',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
