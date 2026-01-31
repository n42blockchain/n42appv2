// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';

/// CSV 导入页面
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
  bool _hasContent = false;
  int _lineCount = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateStats);
  }

  @override
  void dispose() {
    _textController.removeListener(_updateStats);
    _textController.dispose();
    super.dispose();
  }

  void _updateStats() {
    final text = _textController.text.trim();
    final lines = text.isEmpty
        ? 0
        : text.split('\n').where((l) => l.trim().isNotEmpty).length;

    setState(() {
      _hasContent = text.isNotEmpty;
      _lineCount = lines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import CSV'),
        actions: [
          TextButton(
            onPressed: _hasContent ? _importData : null,
            child: Text(
              'Import',
              style: TextStyle(
                color: _hasContent
                    ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 模板说明
          _buildTemplateSection(),

          // 输入区域
          Expanded(
            child: _buildInputSection(),
          ),

          // 底部操作栏
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTemplateSection() {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(16)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withAlpha(15),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: Border.all(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withAlpha(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                size: ScreenUtil().setWidth(24),
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Text(
                'CSV Format',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w600,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'address,amount,memo(optional)',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(20),
                    fontFamily: 'monospace',
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  '0x123...abc,1.5,Payment 1',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    fontFamily: 'monospace',
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
                Text(
                  '0xdef...789,2.0,Payment 2',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    fontFamily: 'monospace',
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyTemplate,
                  icon: Icon(Icons.copy, size: ScreenUtil().setWidth(20)),
                  label: Text('Copy Template'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8)),
                  ),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: Icon(Icons.paste, size: ScreenUtil().setWidth(20)),
                  label: Text('Paste'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: Border.all(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name).withAlpha(30),
        ),
      ),
      child: TextField(
        controller: _textController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(24),
          fontFamily: 'monospace',
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
        ),
        decoration: InputDecoration(
          hintText: 'Paste your CSV data here...\n\nExample:\n0x1234...5678,1.0\n0xabcd...efgh,2.5,Note',
          hintStyle: TextStyle(
            fontSize: ScreenUtil().setSp(24),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 统计信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lines: $_lineCount',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
                Text(
                  'Token: ${widget.tokenSymbol}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _hasContent ? _clearInput : null,
                    child: Text('Clear'),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _hasContent ? _importData : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
                    ),
                    child: Text('Import $_lineCount Recipients'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyTemplate() {
    final template = '''address,amount,memo
0x1234567890123456789012345678901234567890,1.5,Payment 1
0xabcdefabcdefabcdefabcdefabcdefabcdefabcd,2.0,Payment 2
0x9876543210987654321098765432109876543210,0.5,''';

    Clipboard.setData(ClipboardData(text: template));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Template copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    if (data?.text != null && data!.text!.isNotEmpty) {
      _textController.text = data.text!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pasted from clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Clipboard is empty'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _clearInput() {
    _textController.clear();
  }

  void _importData() {
    final content = _textController.text.trim();
    if (content.isEmpty) return;

    // 验证基本格式
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No valid data found')),
      );
      return;
    }

    // 检查是否有表头
    bool hasHeader = false;
    final firstLine = lines[0].toLowerCase();
    if (firstLine.contains('address') || !firstLine.startsWith('0x')) {
      hasHeader = true;
    }

    final dataLines = hasHeader ? lines.skip(1) : lines;

    // 验证每行格式
    int validCount = 0;
    int errorCount = 0;
    final errors = <String>[];

    int lineNum = hasHeader ? 2 : 1;
    for (final line in dataLines) {
      final parts = line.split(',');
      if (parts.length < 2) {
        errors.add('Line $lineNum: Invalid format (need at least address,amount)');
        errorCount++;
      } else {
        final address = parts[0].trim();
        final amount = parts[1].trim();

        if (!address.startsWith('0x') || address.length != 42) {
          errors.add('Line $lineNum: Invalid address');
          errorCount++;
        } else if (!_isValidAmount(amount)) {
          errors.add('Line $lineNum: Invalid amount');
          errorCount++;
        } else {
          validCount++;
        }
      }
      lineNum++;
    }

    // 如果有错误，显示警告
    if (errorCount > 0) {
      _showValidationDialog(validCount, errors);
    } else {
      // 直接返回数据
      Navigator.pop(context, content);
    }
  }

  bool _isValidAmount(String amount) {
    try {
      final value = double.parse(amount.replaceAll(',', ''));
      return value > 0;
    } catch (e) {
      return false;
    }
  }

  void _showValidationDialog(int validCount, List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
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
              Text('Found $validCount valid and ${errors.length} invalid entries.'),
              SizedBox(height: 16),
              Text(
                'Errors:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: errors.length > 5 ? 5 : errors.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        errors[index],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (errors.length > 5)
                Text(
                  '... and ${errors.length - 5} more',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          if (validCount > 0)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 关闭对话框
                Navigator.pop(this.context, _textController.text); // 返回数据
              },
              child: Text('Import $validCount Valid'),
            ),
        ],
      ),
    );
  }
}
