import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_quote_model.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_confirm.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

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
  final VoidCallback onSwapConfirmed;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final bool hasQuote = quote != null;
    final bool loading =
        swapLoad == Load.loading || approveLoad == Load.loading;

    if (needsApproval && hasQuote) {
      return _sizedButton(
        context,
        onTap: approveLoad == Load.finish ? onApprove : () {},
        label: approveLoad == Load.loading
            ? s.g_key_dex_approving
            : s.g_key_dex_approve_required(tokenInSymbol),
        bgColor: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.textColorOrange.name),
        textColor: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainButtonTextColor.name),
        isLoading: approveLoad == Load.loading,
      );
    }

    return _sizedButton(
      context,
      onTap: hasQuote && !loading
          ? () async {
              FocusScope.of(context).unfocus();
              final bool? confirmed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (_) => DexSwapConfirm(quote: quote!)),
              );
              if (confirmed == true) onSwapConfirmed();
            }
          : () {},
      label: s.g_key_dex_swap_btn,
      bgColor: hasQuote && !loading
          ? AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainButtonBgColor.name)
          : AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainButtonBgColor3.name),
      textColor: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.mainButtonTextColor.name),
      isLoading: loading,
    );
  }

  Widget _sizedButton(
    BuildContext context, {
    required VoidCallback onTap,
    required String label,
    required Color bgColor,
    required Color textColor,
    required bool isLoading,
  }) {
    return SizedBox(
      height: ScreenUtil().setWidth(88),
      width: double.infinity,
      child: buttonStyle6(context, onTap, label, bgColor, textColor, isLoading),
    );
  }
}
