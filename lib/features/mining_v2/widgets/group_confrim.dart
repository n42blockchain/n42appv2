import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

Future<bool?> showGroupConfirmDialog(
  BuildContext context,
  int num,
  String lockDate,
  GestureTapCallback? sureCall,
) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      insetPadding: EdgeInsets.all(AppSpacing.space8),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
      content: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.brLg,
          color: AppColorTokens.of(context).bgBase,
        ),
        child: GroupConfirm(num: num, lockDate: lockDate, sureCall: sureCall),
      ),
    ),
  );
}

class GroupConfirm extends StatelessWidget {
  final int num;
  final String lockDate;
  final GestureTapCallback? sureCall;

  const GroupConfirm({
    super.key,
    required this.num,
    required this.lockDate,
    this.sureCall,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.space12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: ScreenUtil().setWidth(80)),
            Image.asset(
              'assets/img/ast_nft.png',
              width: ScreenUtil().setWidth(160),
              fit: BoxFit.cover,
            ),
            SizedBox(height: ScreenUtil().setWidth(80)),
            Text(
              S.of(context).g_mining_key_114,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleLg.copyWith(
                color: AppColorTokens.of(context).textPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(54)),
            ...[
              S.of(context).g_mining_key76(num.toString(), lockDate),
              S.of(context).g_mining_key86,
              S.of(context).g_mining_key87,
            ].expand(
              (text) => [
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColorTokens.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.space2),
              ],
            ),
            SizedBox(height: ScreenUtil().setWidth(90)),
            SizedBox(
              height: ScreenUtil().setWidth(88),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColorTokens.of(context).bgSurface,
                          borderRadius: AppRadius.brSm,
                        ),
                        child: Center(
                          child: Text(
                            S.of(context).g_key_79,
                            style: AppTypography.headline.copyWith(
                              color: AppColorTokens.of(context).brand,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.space8),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        if (sureCall != null) {
                          await Future.sync(sureCall!);
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColorTokens.of(context).brand,
                          borderRadius: AppRadius.brSm,
                        ),
                        child: Center(
                          child: Text(
                            S.of(context).g_key_78,
                            style: AppTypography.headline.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(54)),
          ],
        ),
      ),
    );
  }
}
