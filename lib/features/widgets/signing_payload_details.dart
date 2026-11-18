import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// Shows the original request separately from its shortened preview.
class SigningPayloadDetails extends StatelessWidget {
  final String payload;

  const SigningPayloadDetails({required this.payload, super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(S.of(context).g_key_aa_details),
      childrenPadding: EdgeInsets.all(AppSpacing.space4),
      expandedAlignment: AlignmentDirectional.centerStart,
      children: [SelectableText(payload)],
    );
  }
}
