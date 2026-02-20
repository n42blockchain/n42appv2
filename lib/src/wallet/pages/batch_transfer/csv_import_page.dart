// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';

/// CSV 导入页面
///
/// 返回值：用户确认后的 CSV 原始文本（含注释行/空行），由
/// [BatchTransferProvider.parseCsv] 做最终解析。
class CsvImportPage extends StatefulWidget {
  final String tokenSymbol;
  final int decimals;

  const CsvImportPage({
    super.key,
    required this.tokenSymbol,
    required this.decimals,
  });

  @override
  State<CsvImportPage> createState() => _CsvImportPageState();
}

class _CsvImportPageState extends State<CsvImportPage> {
  final _textController = TextEditingController();

  // 有效数据行数（去掉注释、空行、header）
  int _validLineCount = 0;
  // 格式文档是否展开
  bool _docExpanded = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateStats);
  }

  @override
  void dispose() {
    _textController
      ..removeListener(_updateStats)
      ..dispose();
    super.dispose();
  }

  // ─── 统计有效数据行 ───────────────────────────────────────────────────────────

  void _updateStats() {
    final lines = _textController.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toList();

    // 跳过可能的 header 行
    final dataLines = lines.isNotEmpty &&
            (lines[0].toLowerCase().startsWith('address') ||
                !lines[0].startsWith('0x'))
        ? lines.skip(1).toList()
        : lines;

    setState(() => _validLineCount = dataLines.length);
  }

  bool get _hasContent => _textController.text.trim().isNotEmpty;

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final blue = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).g_key_batch_import_csv),
        actions: [
          TextButton(
            onPressed: _hasContent ? _importData : null,
            child: Text(
              S.of(context).g_key_batch_done, // "Done"
              style: TextStyle(
                color: _hasContent ? blue : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 格式文档区（可折叠）
          _buildFormatSection(),

          // CSV 文本输入区
          Expanded(child: _buildInputSection()),

          // 底部操作栏
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ─── 格式文档区 ──────────────────────────────────────────────────────────────

  Widget _buildFormatSection() {
    final blue = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    final itemBg = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemBgColor.name);
    final subText = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    final mainText = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainTextColor.name);

    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: blue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: Border.all(color: blue.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 折叠标题行
          InkWell(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            onTap: () => setState(() => _docExpanded = !_docExpanded),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16),
                vertical: ScreenUtil().setWidth(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.description_outlined,
                      color: blue, size: ScreenUtil().setWidth(28)),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Expanded(
                    child: Text(
                      S.of(context).g_key_batch_csv_format,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        fontWeight: FontWeight.w600,
                        color: blue,
                      ),
                    ),
                  ),
                  Icon(
                    _docExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: blue,
                  ),
                ],
              ),
            ),
          ),

          // 展开内容
          if (_docExpanded) ...[
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(16)),
              child: Divider(height: 1, color: blue.withValues(alpha: 0.2)),
            ),
            Padding(
              padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 列说明
                  _docSectionTitle('Columns', mainText),
                  SizedBox(height: ScreenUtil().setWidth(6)),
                  _docRow('address', 'Required — EVM address (0x + 40 hex)', subText, mainText),
                  _docRow('amount', 'Required — Decimal number (e.g. 1.5)', subText, mainText),
                  _docRow('memo', 'Optional — Label or note', subText, mainText),
                  SizedBox(height: ScreenUtil().setWidth(12)),

                  // 规则
                  _docSectionTitle('Rules', mainText),
                  SizedBox(height: ScreenUtil().setWidth(6)),
                  _docBullet('Header row (address,amount,memo) is optional — auto-detected', subText),
                  _docBullet('Lines starting with # are comments and will be ignored', subText),
                  _docBullet('Blank lines are ignored', subText),
                  _docBullet('Duplicate addresses will be flagged', subText),
                  _docBullet('Maximum 200 recipients per batch', subText),
                  SizedBox(height: ScreenUtil().setWidth(12)),

                  // 示例
                  _docSectionTitle('Example', mainText),
                  SizedBox(height: ScreenUtil().setWidth(6)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
                    decoration: BoxDecoration(
                      color: itemBg,
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(8)),
                    ),
                    child: Text(
                      '# Batch payment 2026-02-20\n'
                      'address,amount,memo\n'
                      '0x1234567890123456789012345678901234567890,1.5,Alice\n'
                      '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd,2.0,Bob\n'
                      '0x9876543210987654321098765432109876543210,0.5,',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(20),
                        fontFamily: 'monospace',
                        color: subText,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 操作按钮行（始终显示）
          Padding(
            padding: EdgeInsets.fromLTRB(
              ScreenUtil().setWidth(16),
              0,
              ScreenUtil().setWidth(16),
              ScreenUtil().setWidth(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    icon: Icons.copy,
                    label: 'Copy Template',
                    onTap: _copyTemplate,
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(8)),
                Expanded(
                  child: _actionBtn(
                    icon: Icons.paste,
                    label: 'Paste',
                    onTap: _pasteFromClipboard,
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(8)),
                Expanded(
                  child: _actionBtn(
                    icon: Icons.folder_open,
                    label: 'Pick File',
                    onTap: _pickFile,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _docSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ScreenUtil().setSp(24),
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _docRow(String field, String desc, Color fieldColor, Color textColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ScreenUtil().setWidth(130),
            child: Text(
              field,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                fontFamily: 'monospace',
                color: fieldColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              desc,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: fieldColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _docBullet(String text, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ',
              style: TextStyle(color: color, fontSize: ScreenUtil().setSp(22))),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: color, fontSize: ScreenUtil().setSp(22))),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final blue = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: ScreenUtil().setWidth(20)),
      label: Text(label,
          style: TextStyle(fontSize: ScreenUtil().setSp(20))),
      style: OutlinedButton.styleFrom(
        foregroundColor: blue,
        side: BorderSide(color: blue.withValues(alpha: 0.4)),
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8)),
      ),
    );
  }

  // ─── 文本输入区 ──────────────────────────────────────────────────────────────

  Widget _buildInputSection() {
    final itemBg = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemBgColor.name);
    final subText = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    final mainText = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainTextColor.name);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: Border.all(color: subText.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: _textController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(24),
          fontFamily: 'monospace',
          color: mainText,
          height: 1.6,
        ),
        decoration: InputDecoration(
          hintText: '# Comments start with #\n'
              'address,amount,memo\n'
              '0x1234...5678,1.0,Alice\n'
              '0xabcd...efgh,2.5,Bob',
          hintStyle: TextStyle(
            fontSize: ScreenUtil().setSp(22),
            color: subText.withValues(alpha: 0.6),
            height: 1.6,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        ),
      ),
    );
  }

  // ─── 底部操作栏 ──────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final itemBg = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemBgColor.name);
    final subText = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    final blue = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: itemBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 统计行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recipients: $_validLineCount',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: subText,
                  ),
                ),
                Text(
                  'Token: ${widget.tokenSymbol}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: subText,
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),

            // 按钮行
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _hasContent ? _clearInput : null,
                    child: Text(S.of(context).g_key_batch_clear_all),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _hasContent && _validLineCount > 0
                        ? _importData
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setWidth(16)),
                    ),
                    child: Text(
                      'Import $_validLineCount ${S.of(context).g_key_batch_recipients}',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Actions ─────────────────────────────────────────────────────────────────

  void _copyTemplate() {
    const template = '# Batch transfer template\n'
        '# Columns: address, amount, memo(optional)\n'
        'address,amount,memo\n'
        '0x1234567890123456789012345678901234567890,1.5,Payment 1\n'
        '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd,2.0,Payment 2\n'
        '0x9876543210987654321098765432109876543210,0.5,';

    Clipboard.setData(const ClipboardData(text: template));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${S.of(context).g_key_119} — Template'), // "Copy — Template"
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    if (data?.text != null && data!.text!.isNotEmpty) {
      _textController.text = data.text!;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clipboard is empty'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 从文件系统选择 .csv / .txt 文件并读取内容
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to read file: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearInput() => _textController.clear();

  // ─── 验证 + 导入 ─────────────────────────────────────────────────────────────

  void _importData() {
    final rawContent = _textController.text.trim();
    if (rawContent.isEmpty) return;

    // 过滤掉注释行和空行
    final allLines = rawContent.split('\n');
    final dataLines = allLines
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toList();

    if (dataLines.isEmpty) {
      _showSnack('No data found after removing comments.');
      return;
    }

    // 检测并跳过 header
    final hasHeader = dataLines[0].toLowerCase().startsWith('address') ||
        (!dataLines[0].startsWith('0x') && !_looksLikeDataRow(dataLines[0]));
    final rows = hasHeader ? dataLines.skip(1).toList() : dataLines;

    if (rows.isEmpty) {
      _showSnack('No data rows found (only header detected).');
      return;
    }

    // Max 200 recipients check
    if (rows.length > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              S.of(context).g_key_batch_max_recipients(200)),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 逐行验证
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

      if (!_isValidEvmAddress(address)) {
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
        // 仍然计为有效（允许重复，警告即可）
      }
      seenAddresses.add(normalizedAddr);
      validCount++;
    }

    if (errors.isEmpty) {
      // 全部有效，直接返回
      Navigator.pop(context, rawContent);
    } else {
      _showValidationDialog(validCount, errors, rawContent);
    }
  }

  bool _looksLikeDataRow(String line) {
    final parts = line.split(',');
    return parts.length >= 2 && parts[0].trim().startsWith('0x');
  }

  bool _isValidEvmAddress(String address) {
    return address.length == 42 &&
        RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address);
  }

  bool _isValidAmount(String amount) {
    try {
      final value =
          double.parse(amount.replaceAll(',', '').replaceAll(' ', ''));
      return value > 0;
    } catch (_) {
      return false;
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showValidationDialog(
      int validCount, List<String> errors, String rawContent) {
    final blue = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Validation Issues'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Found $validCount valid, ${errors.length} issue(s).',
              ),
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
            child: Text(S.of(context).g_key_79), // Cancel
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
