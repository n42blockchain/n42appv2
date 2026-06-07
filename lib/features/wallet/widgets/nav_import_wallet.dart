import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavImportWallet extends StatelessWidget {
  final void Function(int)? onTap;
  const NavImportWallet({this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_ex_keystore_16,
          style: TextStyle(
            color: AppColorTokens.of(context).textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: ScreenUtil().setSp(36.0),
          ),
        ),
        SizedBox(height: AppSpacing.space4),
        InkWell(
          onTap: () {
            onTap?.call(1);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space8,
            ),
            margin: EdgeInsets.symmetric(vertical: AppSpacing.space4),
            decoration: BoxDecoration(
              borderRadius: AppRadius.brMd,
              color: Colors.transparent,
              border: Border.fromBorderSide(
                BorderSide(
                  color: AppColorTokens.of(context).border,
                  width: ScreenUtil().setWidth(1.0),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: ScreenUtil().setWidth(20.0)),
                  height: ScreenUtil().setWidth(50.0),
                  width: ScreenUtil().setWidth(50.0),
                  child: Image.asset(
                    "assets/wallet/mnemonic.png",
                    color: AppColorTokens.of(context).textPrimary,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).g_key_12,
                        style: AppTypography.body.copyWith(color: AppColorTokens.of(context).textPrimary),
                      ),
                      SizedBox(height: AppSpacing.space4),
                      Text(
                        S.of(context).w_key_8,
                        style: AppTypography.bodySm.copyWith(color: AppColorTokens.of(context).textSubtitle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            onTap?.call(0);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space8,
            ),
            margin: EdgeInsets.symmetric(vertical: AppSpacing.space4),
            decoration: BoxDecoration(
              borderRadius: AppRadius.brMd,
              color: Colors.transparent,
              border: Border.fromBorderSide(
                BorderSide(
                  color: AppColorTokens.of(context).border,
                  width: ScreenUtil().setWidth(1.0),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: ScreenUtil().setWidth(20.0)),
                  height: ScreenUtil().setWidth(50.0),
                  width: ScreenUtil().setWidth(50.0),
                  child: Image.asset(
                    "assets/wallet/keystore.png",
                    color: AppColorTokens.of(context).textPrimary,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Keystore",
                        style: AppTypography.body.copyWith(color: AppColorTokens.of(context).textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        S.of(context).g_key_ex_keystore_15,
                        style: AppTypography.bodySm.copyWith(color: AppColorTokens.of(context).textSubtitle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
