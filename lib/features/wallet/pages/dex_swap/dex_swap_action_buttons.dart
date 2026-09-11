import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_quote_model.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_confirm.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// The bottom action area of the DEX swap form.
///
/// Shows either:
/// - An **Approve** button (orange) when ERC-20 approval is required, or
/// - A **Swap** button (primary) that navigates to the confirm screen first.
///
/// All async actions are delegated to [onApprove] / [onSwapConfirmed]; this
/// widget is stateless and driven entirely by the parent state.
class DexActionButtons extends StatelessWidget {
  const DexActionButtons({
    super.key,
    required this.quote,
    required this.needsApproval,
    required this.approveLoad,
    required this.swapLoad,
    required this.tokenInSymbol,
    required this.onApprove,
    required this.onSwapConfirmed,
  });

  final DexQuoteModel? quote;
  final bool needsApproval;
  final Load approveLoad;
  final Load swapLoad;
  final String tokenInSymbol;

  /// Called when the user taps Approve.
  final VoidCallback onApprove;

  /// Called after the confirm screen returns `true`.
  final ValueChanged<DexQuoteModel> onSwapConfirmed;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final bool hasQuote = quote != null;
    final bool loading =
        swapLoad == Load.loading || approveLoad == Load.loading;

    if (needsApproval && hasQuote) {
      return _sizedButton(
        onTap: !loading ? onApprove : null,
        label: approveLoad == Load.loading
            ? s.g_key_dex_approving
            : s.g_key_dex_approve_required(tokenInSymbol),
        variant: AppButtonVariant.warning,
        isLoading: approveLoad == Load.loading,
      );
    }

    return _sizedButton(
      onTap: hasQuote && !loading
          ? () async {
              final displayedQuote = quote!;
              FocusScope.of(context).unfocus();
              final bool? confirmed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => DexSwapConfirm(quote: displayedQuote),
                ),
              );
              if (context.mounted && confirmed == true) {
                onSwapConfirmed(displayedQuote);
              }
            }
          : null,
      label: s.g_key_dex_swap_btn,
      variant: AppButtonVariant.primary,
      isLoading: loading,
    );
  }

  Widget _sizedButton({
    required VoidCallback? onTap,
    required String label,
    required AppButtonVariant variant,
    required bool isLoading,
  }) {
    return SizedBox(
      height: ScreenUtil().setWidth(88),
      width: double.infinity,
      child: AppButton(
        label: label,
        onPressed: onTap,
        variant: variant,
        loading: isLoading,
      ),
    );
  }
}
