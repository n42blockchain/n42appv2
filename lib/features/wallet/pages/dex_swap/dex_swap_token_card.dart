import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_token_model.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// A card that shows a token selector and an amount input / read-only display.
///
/// Used for both the "pay" (tokenIn) and "receive" (tokenOut) rows in the
/// DEX swap form.  When [controller] is non-null the amount is editable;
/// when [amountReadOnly] is provided the amount is shown as plain text.
class DexTokenCard extends StatelessWidget {
  const DexTokenCard({
    super.key,
    required this.label,
    required this.token,
    required this.onTokenTap,
    this.controller,
    this.amountReadOnly,
  });

  final String label;
  final DexTokenModel? token;
  final VoidCallback onTokenTap;

  /// Non-null → editable amount field.
  final TextEditingController? controller;

  /// Non-null → read-only amount text (used for tokenOut).
  final String? amountReadOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemBgColor4.name,
        ),
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Row(
            children: [
              Expanded(child: _amountWidget(context)),
              _tokenButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountWidget(BuildContext context) {
    if (controller != null) {
      return TextField(
        controller: controller,
        style: TextStyle(
          color: AppColorTokens.of(context).textItem,
          fontSize: ScreenUtil().setSp(44),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: '0.00',
          hintStyle: TextStyle(
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.textFieldHintColor.name,
            ),
            fontSize: ScreenUtil().setSp(44),
          ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
        ),
      );
    }
    return Text(
      amountReadOnly ?? '—',
      style: TextStyle(
        color: AppColorTokens.of(context).textItem,
        fontSize: ScreenUtil().setSp(44),
      ),
    );
  }

  Widget _tokenButton(BuildContext context) {
    return GestureDetector(
      onTap: onTokenTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(16),
          vertical: ScreenUtil().setWidth(12),
        ),
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgSurface,
          borderRadius: AppRadius.brSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (token != null) ...[
              SizedBox(
                width: ScreenUtil().setWidth(36),
                height: ScreenUtil().setWidth(36),
                child: ImageNetWork(
                  imageUrl: token!.logoUri,
                  placeholder: 'assets/img/list_default.png',
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
            ],
            Flexible(
              child: Text(
                token?.symbol ?? S.of(context).g_key_dex_select_token,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body.copyWith(
                  color: AppColorTokens.of(context).brand,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(4)),
            Icon(
              Icons.arrow_drop_down,
              color: AppColorTokens.of(context).brand,
              size: ScreenUtil().setWidth(36),
            ),
          ],
        ),
      ),
    );
  }
}
