// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

part 'csv_validation.dart';
part 'csv_format_section.dart';

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

/// State 直接 with 两个 mixin（validation 在前，format 在后，因为 format on validation）。
/// 所有共享字段（_textController、_docExpanded、_validLineCount）由 _CsvValidationMixin 持有。
class _CsvImportPageState extends State<CsvImportPage>
    with _CsvValidationMixin, _CsvFormatSectionMixin {
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
              S.of(context).g_key_batch_done,
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

}
