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
      insetPadding: EdgeInsets.all(ScreenUtil().setWidth(28)),
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
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(44)),
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
              style: TextStyle(
                color: AppColorTokens.of(context).textPrimary,
                fontSize: ScreenUtil().setSp(44),
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
                  style: AppTypography.body.copyWith(color: AppColorTokens.of(context).textPrimary),
                ),
                SizedBox(height: ScreenUtil().setWidth(10)),
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
                            style: TextStyle(
                              color: AppColorTokens.of(context).brand,
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil().setSp(30),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(30)),
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
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil().setSp(30),
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
