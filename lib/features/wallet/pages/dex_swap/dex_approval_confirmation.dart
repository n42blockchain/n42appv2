import 'package:flutter/material.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_security_verification.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// Show the spending permission before opening the existing authentication flow.
Future<bool> confirmDexApproval(
  BuildContext context, {
  required String tokenSymbol,
  required String tokenAddress,
  required String spender,
  required String chain,
  required String amountLabel,
}) async {
  final s = S.of(context);
  final consent = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(s.g_key_dex_approve_required(tokenSymbol)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$amountLabel $tokenSymbol · $chain'),
            const SizedBox(height: 16),
            Text(s.g_audit_approval_token),
            SelectableText(tokenAddress),
            const SizedBox(height: 16),
            Text(s.g_audit_approval_spender),
            SelectableText(spender),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(s.g_key_79),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(s.g_key_78),
        ),
      ],
    ),
  );
  if (!context.mounted || consent != true) return false;
  return await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => WalletSecurityVerification()),
      ) ==
      true;
}
