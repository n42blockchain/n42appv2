part of 'csv_import_page.dart';

/// Format documentation section mixin for [_CsvImportPageState].
///
/// Depends on [_CsvValidationMixin] for the shared text controller,
/// expanded state, and action callbacks (copy/paste/pick file).
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
    final scr = ScreenUtil();
    final pad16 = scr.setWidth(16);

    return Container(
      margin: EdgeInsets.all(pad16),
      decoration: BoxDecoration(
        color: blue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(scr.setWidth(12)),
        border: Border.all(color: blue.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToggleHeader(blue, scr, pad16),
          if (_docExpanded) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad16),
              child: Divider(height: 1, color: blue.withValues(alpha: 0.2)),
            ),
            _buildExpandedContent(mainText, subText, itemBg, scr, pad16),
          ],
          _buildActionRow(blue, scr, pad16),
        ],
      ),
    );
  }

  Widget _buildToggleHeader(Color blue, ScreenUtil scr, double pad16) {
    return InkWell(
      borderRadius: BorderRadius.circular(scr.setWidth(12)),
      onTap: () => setState(() => _docExpanded = !_docExpanded),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: pad16,
          vertical: scr.setWidth(12),
        ),
        child: Row(
          children: [
            Icon(Icons.description_outlined,
                color: blue, size: scr.setWidth(28)),
            SizedBox(width: scr.setWidth(8)),
            Expanded(
              child: Text(
                S.of(context).g_key_batch_csv_format,
                style: TextStyle(
                  fontSize: scr.setSp(26),
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
    );
  }

  Widget _buildExpandedContent(
      Color mainText, Color subText, Color itemBg, ScreenUtil scr, double pad16) {
    final gap6 = SizedBox(height: scr.setWidth(6));
    final gap12 = SizedBox(height: scr.setWidth(12));
    final bodyStyle = TextStyle(fontSize: scr.setSp(22), color: subText);
    final fieldStyle = bodyStyle.copyWith(
        fontFamily: 'monospace', fontWeight: FontWeight.w600);

    return Padding(
      padding: EdgeInsets.all(pad16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _docSectionTitle('Columns', mainText, scr),
          gap6,
          _docRow('address', 'Required — EVM address (0x + 40 hex)',
              fieldStyle, bodyStyle, scr),
          _docRow('amount', 'Required — Decimal number (e.g. 1.5)',
              fieldStyle, bodyStyle, scr),
          _docRow('memo', 'Optional — Label or note', fieldStyle, bodyStyle, scr),
          gap12,
          _docSectionTitle('Rules', mainText, scr),
          gap6,
          _docBullet('Header row (address,amount,memo) is optional — auto-detected',
              bodyStyle, scr),
          _docBullet('Lines starting with # are comments and will be ignored',
              bodyStyle, scr),
          _docBullet('Blank lines are ignored', bodyStyle, scr),
          _docBullet('Duplicate addresses will be flagged', bodyStyle, scr),
          _docBullet('Maximum 200 recipients per batch', bodyStyle, scr),
          gap12,
          _docSectionTitle('Example', mainText, scr),
          gap6,
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(scr.setWidth(12)),
            decoration: BoxDecoration(
              color: itemBg,
              borderRadius: BorderRadius.circular(scr.setWidth(8)),
            ),
            child: Text(
              '# Batch payment 2026-02-20\n'
              'address,amount,memo\n'
              '0x1234567890123456789012345678901234567890,1.5,Alice\n'
              '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd,2.0,Bob\n'
              '0x9876543210987654321098765432109876543210,0.5,',
              style: TextStyle(
                fontSize: scr.setSp(20),
                fontFamily: 'monospace',
                color: subText,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(Color blue, ScreenUtil scr, double pad16) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pad16, 0, pad16, scr.setWidth(12)),
      child: Row(
        children: [
          Expanded(child: _actionBtn(Icons.copy, 'Copy Template', _copyTemplate, blue, scr)),
          SizedBox(width: scr.setWidth(8)),
          Expanded(child: _actionBtn(Icons.paste, 'Paste', _pasteFromClipboard, blue, scr)),
          SizedBox(width: scr.setWidth(8)),
          Expanded(child: _actionBtn(Icons.folder_open, 'Pick File', _pickFile, blue, scr)),
        ],
      ),
    );
  }

  Widget _docSectionTitle(String title, Color color, ScreenUtil scr) {
    return Text(
      title,
      style: TextStyle(
        fontSize: scr.setSp(24),
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _docRow(String field, String desc, TextStyle fieldStyle,
      TextStyle descStyle, ScreenUtil scr) {
    return Padding(
      padding: EdgeInsets.only(bottom: scr.setWidth(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: scr.setWidth(130),
            child: Text(field, style: fieldStyle),
          ),
          Expanded(child: Text(desc, style: descStyle)),
        ],
      ),
    );
  }

  Widget _docBullet(String text, TextStyle style, ScreenUtil scr) {
    return Padding(
      padding: EdgeInsets.only(bottom: scr.setWidth(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: style),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap,
      Color blue, ScreenUtil scr) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: scr.setWidth(20)),
      label: Text(label, style: TextStyle(fontSize: scr.setSp(20))),
      style: OutlinedButton.styleFrom(
        foregroundColor: blue,
        side: BorderSide(color: blue.withValues(alpha: 0.4)),
        padding: EdgeInsets.symmetric(vertical: scr.setWidth(8)),
      ),
    );
  }
}
