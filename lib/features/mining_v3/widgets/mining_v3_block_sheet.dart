import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_activity.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_engine.dart';
import 'package:n42_wallet/features/mining_v3/widgets/mining_v3_dashboard.dart';
import 'package:n42_wallet/generated/l10n.dart';

class MiningV3BlockSheet extends StatelessWidget {
  const MiningV3BlockSheet({
    super.key,
    required this.engine,
    required this.block,
  });
  final MiningV3Engine engine;
  final MiningV3Block block;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: engine,
    builder: (context, _) {
      final current =
          engine.blocks.where((b) => b.number == block.number).firstOrNull ??
          block;
      final s = S.of(context);
      final c = AppColorTokens.of(context);
      return SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.space8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.miningV3Block(miningV3Number(context, current.number)),
              style: AppTypography.title.copyWith(color: c.textPrimary),
            ),
            SizedBox(height: AppSpacing.space6),
            Align(
              alignment: Alignment.centerLeft,
              child: AppBadge(
                label: miningV3BlockLabel(s, current.state),
                tone: miningV3BlockTone(current.state),
              ),
            ),
            SizedBox(height: AppSpacing.space8),
            if (current.time != null)
              _field(context, s.miningV3Time, current.time!),
            if (current.transactions != null)
              _field(
                context,
                s.miningV3TransactionsLabel,
                miningV3Number(context, current.transactions!),
              ),
            if (current.elapsedMs != null)
              _field(
                context,
                s.miningV3Latency,
                s.miningV3Milliseconds(
                  miningV3Number(context, current.elapsedMs!),
                ),
              ),
            if (current.signers != null)
              _field(
                context,
                s.miningV3Signers,
                miningV3Number(context, current.signers!),
              ),
            if (current.hash != null)
              _field(context, s.miningV3BlockHash, current.hash!),
            if (current.receiptsRoot != null)
              _field(context, s.miningV3ReceiptsRoot, current.receiptsRoot!),
            if (current.error != null)
              _field(context, s.miningV3ErrorDetails, current.error!),
            if (current.hash != null) ...[
              SizedBox(height: AppSpacing.space8),
              AppButton(
                label: s.miningV3CopyHash,
                variant: AppButtonVariant.secondary,
                icon: Icons.copy_rounded,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: current.hash!));
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(s.miningV3Copied)));
                  }
                },
              ),
            ],
          ],
        ),
      );
    },
  );

  Widget _field(BuildContext context, String label, String value) {
    final c = AppColorTokens.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(color: c.textSecondary),
          ),
          SizedBox(height: AppSpacing.space2),
          SelectableText(
            value,
            style: AppTypography.bodySm.copyWith(color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}
