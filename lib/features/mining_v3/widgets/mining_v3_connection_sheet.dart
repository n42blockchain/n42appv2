import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_engine.dart';
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
    required this.endpoint,
    required this.onSave,
  });

  final MiningV3Engine engine;
  final String endpoint;
  final Future<void> Function(String endpoint) onSave;

  @override
  State<MiningV3ConnectionSheet> createState() =>
      _MiningV3ConnectionSheetState();
}

class _MiningV3ConnectionSheetState extends State<MiningV3ConnectionSheet> {
  final _form = GlobalKey<FormState>();
  late final _endpoint = TextEditingController(text: widget.endpoint);
  bool _saving = false;
  bool _saveFailed = false;

  @override
  void dispose() {
    _endpoint.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (widget.engine.running ||
        widget.engine.pausedForBackground ||
        widget.engine.busy ||
        _saving ||
        !_form.currentState!.validate()) {
      return;
    }
    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    try {
      await widget.onSave(normalizeMiningV3Endpoint(_endpoint.text)!);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _saveFailed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
      return SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.space8),
        child: Form(
          key: _form,
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
                miningV3DefaultEndpoint == miningV3LocalTestnetEndpoint
                    ? s.miningV3LocalTestnetHint
                    : s.miningV3NodeHint,
                style: AppTypography.footnote.copyWith(color: c.textSecondary),
              ),
              SizedBox(height: AppSpacing.space8),
              TextFormField(
                key: const ValueKey('mining_v3_node_address'),
                controller: _endpoint,
                enabled: !running && !_saving,
                keyboardType: TextInputType.url,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: s.miningV3NodeAddress,
                  hintText: 'https://node.example.com',
                ),
                validator: (value) =>
                    normalizeMiningV3Endpoint(value ?? '') == null
                    ? s.miningV3NodeInvalid
                    : null,
                onFieldSubmitted: (_) => _save(),
              ),
              if (miningV3DefaultEndpoint == miningV3LocalTestnetEndpoint) ...[
                SizedBox(height: AppSpacing.space4),
                AppButton(
                  label: s.miningV3UseLocalTestnet,
                  variant: AppButtonVariant.text,
                  onPressed: running || _saving
                      ? null
                      : () {
                          _endpoint.text = miningV3LocalTestnetEndpoint;
                          _form.currentState?.validate();
                          setState(() => _saveFailed = false);
                        },
                ),
              ],
              if (running) ...[
                SizedBox(height: AppSpacing.space4),
                Text(
                  s.miningV3PauseForSettings,
                  style: AppTypography.footnote.copyWith(
                    color: c.textSecondary,
                  ),
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
                      error,
                      style: AppTypography.caption.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
