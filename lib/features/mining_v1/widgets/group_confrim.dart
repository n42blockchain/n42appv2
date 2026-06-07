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
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      //这是宽度沾满宽度
      insetPadding: EdgeInsets.all(ScreenUtil().setWidth(28)),
      //设置圆角
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
              color: AppColorTokens.of(context).textPrimary,
            ),
            SizedBox(height: ScreenUtil().setWidth(80)),
            Text(
              "Confirmation",
              style: TextStyle(
                color: AppColorTokens.of(context).textPrimary,
                fontSize: ScreenUtil().setSp(44),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(54)),
            Text(
              // "Are you sure you want to lock $num AsT until $lockDate to run a node?",
              S.of(context).g_mining_key76(num.toString(), lockDate),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColorTokens.of(context).textPrimary,
                fontSize: ScreenUtil().setSp(28),
              ),
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
                              fontWeight: FontWeight.bold,
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
                      onTap: () {
                        sureCall?.call();
                        Navigator.of(context).pop(true);
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
                              fontWeight: FontWeight.bold,
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
