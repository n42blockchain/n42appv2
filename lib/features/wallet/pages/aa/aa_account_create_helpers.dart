part of 'aa_account_create_page.dart';

/// Helper functions mixin for [_AAAccountCreatePageState].
///
/// Provides per-type color, icon, and localised description lookups.
/// Applied before [_AAAccountCreateFormMixin] in the with-clause so that
/// form widgets can access these helpers directly.
mixin _AAAccountCreateHelpersMixin on State<AAAccountCreatePage> {
  Color _getTypeColor(SmartAccountType type) {
    switch (type) {
      case SmartAccountType.simpleAccount:
        return const Color(0xFF5E97F6);
      case SmartAccountType.simple7702Account:
        return const Color(0xFF9333EA);
      case SmartAccountType.safe:
        return const Color(0xFF12A87B);
      case SmartAccountType.kernel:
        return const Color(0xFF8B5CF6);
      case SmartAccountType.biconomy:
        return const Color(0xFFFF6B4A);
      case SmartAccountType.custom:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getTypeIcon(SmartAccountType type) {
    switch (type) {
      case SmartAccountType.simpleAccount:
        return Icons.account_balance_wallet;
      case SmartAccountType.simple7702Account:
        return Icons.flash_on;
      case SmartAccountType.safe:
        return Icons.security;
      case SmartAccountType.kernel:
        return Icons.memory;
      case SmartAccountType.biconomy:
        return Icons.auto_awesome;
      case SmartAccountType.custom:
        return Icons.code;
    }
  }

  String _getTypeDescription(SmartAccountType type) {
    switch (type) {
      case SmartAccountType.simpleAccount:
        return S.of(context).g_key_aa_simple_desc;
      case SmartAccountType.simple7702Account:
        return S.of(context).g_key_aa_eip7702_desc;
      case SmartAccountType.safe:
        return S.of(context).g_key_aa_safe_desc;
      case SmartAccountType.kernel:
        return S.of(context).g_key_aa_kernel_desc;
      // Bug 5 fix: was returning '' for biconomy, now returns proper description
      case SmartAccountType.biconomy:
        return S.of(context).g_key_aa_biconomy_desc;
      case SmartAccountType.custom:
        return '';
    }
  }
}
