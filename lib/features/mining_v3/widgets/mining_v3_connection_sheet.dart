import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_engine.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_nodes.dart';
import 'package:n42_wallet/generated/l10n.dart';

String? normalizeMiningV3Endpoint(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null ||
      !['http', 'https'].contains(uri.scheme) ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment) {
    return null;
  }
  return uri.toString().replaceFirst(RegExp(r'/+$'), '');
}

class MiningV3ConnectionSheet extends StatefulWidget {
  const MiningV3ConnectionSheet({
    super.key,
    required this.engine,
    required this.selection,
    required this.autoNode,
    required this.onSave,
  });

  final MiningV3Engine engine;

  /// [miningV3AutoNodeId] or the id of the chosen node.
  final String selection;

  /// The node "automatic" resolves to on this device.
  final MiningV3Node autoNode;
  final Future<void> Function(String selection) onSave;

  @override
  State<MiningV3ConnectionSheet> createState() =>
      _MiningV3ConnectionSheetState();
}

class _MiningV3ConnectionSheetState extends State<MiningV3ConnectionSheet> {
  late String _selected = widget.selection;
  bool _saving = false;
  bool _saveFailed = false;

  Future<void> _save() async {
    if (widget.engine.running ||
        widget.engine.pausedForBackground ||
        widget.engine.busy ||
        _saving) {
      return;
    }
    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    try {
      await widget.onSave(_selected);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _saveFailed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _option(
    BuildContext context, {
    required String id,
    required String title,
    String? subtitle,
    required bool enabled,
  }) {
    final c = AppColorTokens.of(context);
    final selected = _selected == id;
    return ListTile(
      key: ValueKey('mining_v3_node_$id'),
      enabled: enabled,
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.dns_outlined, color: c.brand),
      title: Text(
        title,
        style: AppTypography.bodySm.copyWith(color: c.textPrimary),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: AppTypography.caption.copyWith(color: c.textSecondary),
            ),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: c.brand)
          : null,
      selected: selected,
      onTap: () => setState(() {
        _selected = id;
        _saveFailed = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.engine,
    builder: (context, _) {
      final s = S.of(context);
      final c = AppColorTokens.of(context);
      final running =
          widget.engine.running ||
          widget.engine.pausedForBackground ||
          widget.engine.busy;
      final enabled = !running && !_saving;
      return SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.space8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              s.miningV3Settings,
              style: AppTypography.title.copyWith(color: c.textPrimary),
            ),
            SizedBox(height: AppSpacing.space4),
            Text(
              s.miningV3NodeHint,
              style: AppTypography.footnote.copyWith(color: c.textSecondary),
            ),
            SizedBox(height: AppSpacing.space4),
            _option(
              context,
              id: miningV3AutoNodeId,
              title: s.miningV3AutoNode,
              subtitle: widget.autoNode.name,
              enabled: enabled,
            ),
            for (final node in miningV3Nodes)
              _option(context, id: node.id, title: node.name, enabled: enabled),
            if (running) ...[
              SizedBox(height: AppSpacing.space4),
              Text(
                s.miningV3PauseForSettings,
                style: AppTypography.footnote.copyWith(color: c.textSecondary),
              ),
            ],
            if (_saveFailed) ...[
              SizedBox(height: AppSpacing.space4),
              Text(
                s.miningV3SaveFailed,
                style: AppTypography.footnote.copyWith(color: c.danger),
              ),
            ],
            SizedBox(height: AppSpacing.space8),
            AppButton(
              label: s.miningV3Save,
              loading: _saving,
              onPressed: running ? null : _save,
            ),
            if (widget.engine.lastError case final String error) ...[
              SizedBox(height: AppSpacing.space8),
              ExpansionTile(
                title: Text(
                  s.miningV3ErrorDetails,
                  style: AppTypography.bodySm.copyWith(color: c.textPrimary),
                ),
                children: [
                  SelectableText(
                    miningV3HideNodeAddresses(error),
                    style: AppTypography.caption.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    },
  );
}
