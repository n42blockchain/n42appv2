// The mining tab when v3 (mobileverify) is the selected engine: start or
// stop the verification loop, see what it does. Strings are English
// until v3 ships to users (it is gated by miningV3Available).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_engine.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_providers.dart';

class MiningV3Page extends ConsumerStatefulWidget {
  const MiningV3Page({super.key});

  @override
  ConsumerState<MiningV3Page> createState() => _MiningV3PageState();
}

class _MiningV3PageState extends ConsumerState<MiningV3Page> {
  final _endpoint = TextEditingController(text: miningV3DefaultEndpoint);

  @override
  void initState() {
    super.initState();
    _loadEndpoint();
  }

  Future<void> _loadEndpoint() async {
    final stored = await ref.read(spUtilProvider).getMiningV3Endpoint();
    final running = ref.read(miningV3EngineProvider).endpoint;
    if (!mounted) return;
    _endpoint.text = running ?? stored ?? miningV3DefaultEndpoint;
  }

  @override
  void dispose() {
    _endpoint.dispose();
    super.dispose();
  }

  Future<void> _toggle(MiningV3Engine engine) async {
    if (engine.running) {
      await engine.stop();
      return;
    }
    final url = _endpoint.text.trim();
    await ref.read(spUtilProvider).setMiningV3Endpoint(url);
    engine.start(url);
  }

  static String _phaseLabel(MiningV3Phase phase) => switch (phase) {
    MiningV3Phase.idle => 'Stopped',
    MiningV3Phase.connecting => 'Connecting',
    MiningV3Phase.registering => 'Waiting for registration',
    MiningV3Phase.mining => 'Verifying blocks',
    MiningV3Phase.retrying => 'Retrying',
  };

  @override
  Widget build(BuildContext context) {
    final engine = ref.watch(miningV3EngineProvider);
    final colors = AppColorTokens.of(context);
    final phaseColor = switch (engine.phase) {
      MiningV3Phase.mining => colors.success,
      MiningV3Phase.retrying => colors.warning,
      MiningV3Phase.idle => colors.textTertiary,
      _ => colors.info,
    };
    final last = engine.lastVerified;
    return Scaffold(
      backgroundColor: colors.bgBase,
      appBar: AppBar(
        title: Text('Mining v3', style: AppTypography.title),
        backgroundColor: colors.bgBase,
      ),
      body: ListView(
        padding: AppSpacing.pageHorizontal,
        children: [
          _card(
            context,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: AppSpacing.space4,
                      color: phaseColor,
                    ),
                    SizedBox(width: AppSpacing.space2),
                    Text(
                      _phaseLabel(engine.phase),
                      style: AppTypography.bodyStrong.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (engine.deviceIndex != null) ...[
                  SizedBox(height: AppSpacing.space2),
                  Text(
                    'Device #${engine.deviceIndex}',
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
                if (engine.lastError != null &&
                    engine.phase == MiningV3Phase.retrying) ...[
                  SizedBox(height: AppSpacing.space2),
                  Text(
                    engine.lastError!,
                    style: AppTypography.caption.copyWith(color: colors.danger),
                  ),
                ],
              ],
            ),
          ),
          _card(
            context,
            Wrap(
              spacing: AppSpacing.space8,
              runSpacing: AppSpacing.space4,
              children: [
                _stat(context, 'Verified', '${engine.verified}'),
                _stat(context, 'Certified', '${engine.certified}'),
                _stat(context, 'Failed', '${engine.failed}'),
                _stat(context, 'Uncertified', '${engine.uncertified}'),
                if (last != null)
                  _stat(context, 'Last block', '${last.blockNumber}'),
                if (last != null)
                  _stat(context, 'Last time', '${last.elapsedMs} ms'),
                if (engine.lastSigners > 0)
                  _stat(context, 'Signers', '${engine.lastSigners}'),
              ],
            ),
          ),
          _card(
            context,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _endpoint,
                  enabled: !engine.running,
                  decoration: const InputDecoration(
                    labelText: 'Node (mobileverify URL)',
                  ),
                ),
                SizedBox(height: AppSpacing.space4),
                FilledButton(
                  onPressed: () => _toggle(engine),
                  child: Text(engine.running ? 'Stop' : 'Start'),
                ),
              ],
            ),
          ),
          for (final line in engine.log.reversed.take(30))
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.space2 / 2),
              child: Text(
                line,
                style: AppTypography.captionSm.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, Widget child) => Container(
    margin: EdgeInsets.only(top: AppSpacing.space4),
    padding: AppSpacing.cardInset,
    decoration: BoxDecoration(
      color: AppColorTokens.of(context).bgSurface,
      borderRadius: AppRadius.brXl,
    ),
    child: child,
  );

  Widget _stat(BuildContext context, String label, String value) {
    final colors = AppColorTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.headline.copyWith(color: colors.textPrimary),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
