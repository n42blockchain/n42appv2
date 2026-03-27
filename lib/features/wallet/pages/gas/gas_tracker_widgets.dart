// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'gas_tracker_page.dart';

// ══════════════════════════════════════════════════════════
// 提醒概览底部弹窗 — 展示所有网络提醒状态
// ══════════════════════════════════════════════════════════

class _AlertsOverviewSheet extends StatelessWidget {
  final List<NetworkConfig> networks;
  final Map<String, GasAlertConfig> alertConfigs;
  final void Function(NetworkConfig) onNetworkTap;

  const _AlertsOverviewSheet({
    required this.networks,
    required this.alertConfigs,
    required this.onNetworkTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.backGroundColor.name,
    );
    final mainText = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.mainTextColor.name,
    );
    final subtitleText = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.itemSubtitleTextColor.name,
    );

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ScreenUtil().setWidth(24)),
        ),
      ),
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
        top: ScreenUtil().setWidth(24),
        bottom:
            ScreenUtil().setWidth(40) +
            MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetDragHandle(subtitleText: subtitleText),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            S.of(context).g_key_gas_alert,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
              color: mainText,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          ...networks.map(
            (n) => _buildNetworkTile(context, n, mainText, subtitleText),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkTile(
    BuildContext context,
    NetworkConfig n,
    Color mainText,
    Color subtitleText,
  ) {
    final config = alertConfigs[n.symbol];
    final hasAlert = config != null && config.enabled;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _NetworkIcon(network: n, size: 40, iconSize: 22),
      title: Text(
        n.name,
        style: TextStyle(fontSize: ScreenUtil().setSp(28), color: mainText),
      ),
      subtitle: hasAlert
          ? Text(
              '${config.alertBelow ? S.of(context).g_key_gas_alert_below : S.of(context).g_key_gas_alert_above} ${config.threshold.toStringAsFixed(0)} Gwei',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: n.color,
              ),
            )
          : Text(
              '—',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: subtitleText,
              ),
            ),
      trailing: Icon(
        hasAlert ? Icons.notifications_active : Icons.notifications_none,
        color: hasAlert ? n.color : subtitleText,
        size: ScreenUtil().setWidth(36),
      ),
      onTap: () => onNetworkTap(n),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 单网络提醒配置底部弹窗
// ══════════════════════════════════════════════════════════

class _AlertConfigSheet extends StatefulWidget {
  final NetworkConfig network;
  final GasAlertConfig? existing;
  final Future<void> Function(GasAlertConfig) onSaved;
  final Future<void> Function() onRemoved;

  const _AlertConfigSheet({
    required this.network,
    required this.existing,
    required this.onSaved,
    required this.onRemoved,
  });

  @override
  State<_AlertConfigSheet> createState() => _AlertConfigSheetState();
}

class _AlertConfigSheetState extends State<_AlertConfigSheet> {
  late bool _alertBelow;
  late bool _enabled;
  late TextEditingController _thresholdCtrl;
  String _error = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _alertBelow = existing?.alertBelow ?? true;
    _enabled = existing?.enabled ?? true;
    _thresholdCtrl = TextEditingController(
      text: existing?.threshold != null
          ? existing!.threshold.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _thresholdCtrl.dispose();
    super.dispose();
  }

  void _validate(String v) {
    final d = double.tryParse(v);
    setState(() {
      _error = (v.isEmpty || d == null || d <= 0)
          ? S.of(context).g_key_t_43
          : '';
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    _validate(_thresholdCtrl.text);
    final threshold = double.tryParse(_thresholdCtrl.text);
    if (_error.isNotEmpty || threshold == null || threshold <= 0) return;
    setState(() => _saving = true);
    final config = GasAlertConfig(
      symbol: widget.network.symbol,
      threshold: threshold,
      alertBelow: _alertBelow,
      enabled: _enabled,
      lastNotifiedMs: widget.existing?.lastNotifiedMs,
    );
    try {
      await widget.onSaved(config);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (err) {
      if (mounted) {
        setState(() => _saving = false);
      }
      _showError(err.toString());
    }
  }

  Future<void> _remove() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.onRemoved();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (err) {
      if (mounted) {
        setState(() => _saving = false);
      }
      _showError(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.backGroundColor.name,
    );
    final itemBg = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.itemBgColor.name,
    );
    final mainText = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.mainTextColor.name,
    );
    final subtitleText = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.itemSubtitleTextColor.name,
    );
    final blueColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.mainBlueColor.name,
    );

    return PopScope(
      canPop: canDismissGasAlertSheet(_saving),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ScreenUtil().setWidth(24)),
          ),
        ),
        padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(30),
          right: ScreenUtil().setWidth(30),
          top: ScreenUtil().setWidth(24),
          bottom:
              ScreenUtil().setWidth(40) +
              MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetDragHandle(subtitleText: subtitleText),
              SizedBox(height: ScreenUtil().setWidth(20)),
              _buildTitleRow(context, mainText),
              SizedBox(height: ScreenUtil().setWidth(24)),
              _buildEnabledToggle(context, itemBg, mainText, blueColor),
              SizedBox(height: ScreenUtil().setWidth(16)),
              _buildThresholdSection(
                context,
                itemBg,
                subtitleText,
                mainText,
                bgColor,
              ),
              SizedBox(height: ScreenUtil().setWidth(24)),
              _buildSaveButton(context, blueColor),
              if (widget.existing != null) ...[
                SizedBox(height: ScreenUtil().setWidth(12)),
                _buildRemoveButton(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context, Color mainText) {
    return Row(
      children: [
        _NetworkIcon(network: widget.network, size: 44, iconSize: 24),
        SizedBox(width: ScreenUtil().setWidth(12)),
        Expanded(
          child: Text(
            '${widget.network.name} — ${S.of(context).g_key_gas_alert}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              fontWeight: FontWeight.bold,
              color: mainText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnabledToggle(
    BuildContext context,
    Color itemBg,
    Color mainText,
    Color blueColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(20),
        vertical: ScreenUtil().setWidth(12),
      ),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              S.of(context).g_key_gas_alert,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: ScreenUtil().setSp(28), color: mainText),
            ),
          ),
          Switch(
            value: _enabled,
            onChanged: _saving ? null : (v) => setState(() => _enabled = v),
            activeThumbColor: blueColor,
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdSection(
    BuildContext context,
    Color itemBg,
    Color subtitleText,
    Color mainText,
    Color bgColor,
  ) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_gas_alert_threshold,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: subtitleText,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Row(
            children: [
              Expanded(
                child: _DirectionButton(
                  label: S.of(context).g_key_gas_alert_below,
                  icon: Icons.arrow_downward,
                  selected: _alertBelow,
                  color: Colors.green,
                  onTap: () {
                    if (_saving) return;
                    setState(() => _alertBelow = true);
                  },
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Expanded(
                child: _DirectionButton(
                  label: S.of(context).g_key_gas_alert_above,
                  icon: Icons.arrow_upward,
                  selected: !_alertBelow,
                  color: Colors.red,
                  onTap: () {
                    if (_saving) return;
                    setState(() => _alertBelow = false);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          _buildThresholdInput(context, subtitleText, mainText, bgColor),
          if (_error.isNotEmpty) ...[
            SizedBox(height: ScreenUtil().setWidth(6)),
            Text(
              _error,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.errorTextColor.name,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThresholdInput(
    BuildContext context,
    Color subtitleText,
    Color mainText,
    Color bgColor,
  ) {
    final borderColor = _error.isNotEmpty
        ? AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name)
        : AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(16),
        vertical: ScreenUtil().setWidth(10),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              enabled: !_saving,
              controller: _thresholdCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: mainText,
              ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  color: subtitleText,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: _validate,
            ),
          ),
          Text(
            'Gwei',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: subtitleText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, Color blueColor) {
    return SizedBox(
      width: double.infinity,
      height: ScreenUtil().setWidth(88),
      child: ElevatedButton(
        onPressed: _saving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: blueColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          ),
          disabledBackgroundColor: blueColor.withAlpha(120),
        ),
        child: _saving
            ? SizedBox(
                width: ScreenUtil().setWidth(36),
                height: ScreenUtil().setWidth(36),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                S.of(context).g_key_gas_alert_save,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30),
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: ScreenUtil().setWidth(76),
      child: TextButton(
        onPressed: _saving ? null : _remove,
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          ),
        ),
        child: Text(
          S.of(context).g_key_113, // "Delete"
          style: TextStyle(fontSize: ScreenUtil().setSp(28)),
        ),
      ),
    );
  }
}

// ── 方向选择按钮 ─────────────────────────────────────────────

class _DirectionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _DirectionButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final idleColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.itemSubtitleTextColor.name,
    );
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(14)),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(30) : Colors.transparent,
          border: Border.all(
            color: selected
                ? color
                : AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.dividerColor.name,
                  ),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: ScreenUtil().setWidth(28),
              color: selected ? color : idleColor,
            ),
            SizedBox(width: ScreenUtil().setWidth(6)),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? color : idleColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 通用子组件 ──────────────────────────────────────────────

/// 底部弹窗顶部拖拽指示条
class _SheetDragHandle extends StatelessWidget {
  final Color subtitleText;
  const _SheetDragHandle({required this.subtitleText});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: ScreenUtil().setWidth(80),
        height: ScreenUtil().setWidth(6),
        decoration: BoxDecoration(
          color: subtitleText.withAlpha(60),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(3)),
        ),
      ),
    );
  }
}

/// 网络图标容器（圆角色块 + 居中文字图标）
class _NetworkIcon extends StatelessWidget {
  final NetworkConfig network;
  final double size;
  final double iconSize;
  const _NetworkIcon({
    required this.network,
    required this.size,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(size),
      height: ScreenUtil().setWidth(size),
      decoration: BoxDecoration(
        color: network.color.withAlpha(30),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(size * 0.25)),
      ),
      child: Center(
        child: Text(
          network.icon,
          style: TextStyle(fontSize: ScreenUtil().setSp(iconSize)),
        ),
      ),
    );
  }
}
