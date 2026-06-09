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
import 'package:n42_wallet/core/design_system/design_system.dart';

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

  void _updateStats() {
    final lines = _filterDataLines(_textController.text);
    final dataLines = lines.isNotEmpty && _isHeaderLine(lines[0])
        ? lines.skip(1).toList()
        : lines;
    setState(() => _validLineCount = dataLines.length);
  }

  @override
  Widget build(BuildContext context) {
    final blue = AppColorTokens.of(context).brand;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).g_key_batch_import_csv),
        actions: [
          TextButton(
            onPressed: _hasContent ? _importData : null,
            child: Text(
              S.of(context).g_key_batch_done,
              style: TextStyle(
                color: _hasContent
                    ? blue
                    : AppColorTokens.of(context).textTertiary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFormatSection(),
          Expanded(child: _buildInputSection()),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    final itemBg = AppColorTokens.of(context).bgSurface;
    final subText = AppColorTokens.of(context).textSubtitle;
    final mainText = AppColorTokens.of(context).textPrimary;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: subText.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: _textController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: AppTypography.caption.copyWith(
          fontFamily: 'monospace',
          color: mainText,
          height: 1.6,
        ),
        decoration: InputDecoration(
          hintText:
              '# Comments start with #\n'
              'address,amount,memo\n'
              '0x1234...5678,1.0,Alice\n'
              '0xabcd...efgh,2.5,Bob',
          hintStyle: AppTypography.caption.copyWith(
            color: subText.withValues(alpha: 0.6),
            height: 1.6,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.space4),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final itemBg = AppColorTokens.of(context).bgSurface;
    final subText = AppColorTokens.of(context).textSubtitle;
    final blue = AppColorTokens.of(context).brand;

    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recipients: $_validLineCount',
                  style: AppTypography.caption.copyWith(color: subText),
                ),
                Text(
                  'Token: ${widget.tokenSymbol}',
                  style: AppTypography.caption.copyWith(color: subText),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.space4),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _hasContent ? _clearInput : null,
                    child: Text(S.of(context).g_key_batch_clear_all),
                  ),
                ),
                SizedBox(width: AppSpacing.space4),
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
                        vertical: AppSpacing.space4,
                      ),
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
