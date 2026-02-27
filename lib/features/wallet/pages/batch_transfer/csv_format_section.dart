part of 'csv_import_page.dart';

/// Format documentation section mixin for [_CsvImportPageState].
///
/// Depends on [_CsvValidationMixin] for the shared text controller,
/// expanded state, and action callbacks (copy/paste/pick file).
/// Provides the collapsible format guide widget, including column docs,
/// rules, example, and action buttons.
mixin _CsvFormatSectionMixin on _CsvValidationMixin {
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
                    _docExpanded ? Icons.expand_less : Icons.expand_more,
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
                  _docRow('address', 'Required — EVM address (0x + 40 hex)',
                      subText, mainText),
                  _docRow('amount', 'Required — Decimal number (e.g. 1.5)',
                      subText, mainText),
                  _docRow('memo', 'Optional — Label or note', subText, mainText),
                  SizedBox(height: ScreenUtil().setWidth(12)),

                  // 规则
                  _docSectionTitle('Rules', mainText),
                  SizedBox(height: ScreenUtil().setWidth(6)),
                  _docBullet(
                      'Header row (address,amount,memo) is optional — auto-detected',
                      subText),
                  _docBullet(
                      'Lines starting with # are comments and will be ignored',
                      subText),
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

  Widget _docRow(
      String field, String desc, Color fieldColor, Color textColor) {
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
              style:
                  TextStyle(color: color, fontSize: ScreenUtil().setSp(22))),
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
      label: Text(label, style: TextStyle(fontSize: ScreenUtil().setSp(20))),
      style: OutlinedButton.styleFrom(
        foregroundColor: blue,
        side: BorderSide(color: blue.withValues(alpha: 0.4)),
        padding:
            EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8)),
      ),
    );
  }
}
