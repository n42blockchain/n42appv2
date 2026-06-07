import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create/create_two.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_finish.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

class CreateOne extends ConsumerStatefulWidget {
  const CreateOne({super.key});

  @override
  ConsumerState<CreateOne> createState() => _CreateOneState();
}

class _CreateOneState extends ConsumerState<CreateOne> {
  bool checkOne = false;
  bool checkTow = false;
  bool checkThree = false;
  late WalletInfo wInfo;

  bool get allChecked => checkOne && checkTow && checkThree;

  Widget _stepIndicator(Color color) {
    return Container(
      height: ScreenUtil().setWidth(10.0),
      width: ScreenUtil().setWidth(88.0),
      decoration: BoxDecoration(borderRadius: AppRadius.brSm, color: color),
    );
  }

  Future<void> _onCreateTap() async {
    if (!allChecked) return;
    wInfo = WalletInfo(
      walletName: "",
      password: "",
      walletUuid: ref.read(wapBridgeProvider).userUUID,
    );
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTwo(wInfo)),
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _onWatchOnlyTap() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateFinish()),
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColorTokens.of(context).brand;
    final inactiveColor = AppColorTokens.of(context).border;
    final spacing = SizedBox(width: ScreenUtil().setWidth(20.0));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColorTokens.of(context).bgBase,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _stepIndicator(activeColor),
            spacing,
            _stepIndicator(inactiveColor),
            spacing,
            _stepIndicator(inactiveColor),
            spacing,
            _stepIndicator(inactiveColor),
          ],
        ),
        actions: [SizedBox(width: ScreenUtil().setWidth(130.0))],
        leadingWidth: ScreenUtil().setWidth(130.0),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(30.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                      alignment: Alignment.center,
                      child: Text(
                        S.of(context).g_key_wallet_c8,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(40.0),
                          color: AppColorTokens.of(context).textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: ScreenUtil().setWidth(450),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/home/splash_2.png",
                        width: ScreenUtil().setWidth(350),
                        height: ScreenUtil().setWidth(350),
                        fit: BoxFit.contain,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(60.0),
                      ),
                      child: Text(
                        S.of(context).g_key_wallet_c9,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32.0),
                          color: AppColorTokens.of(context).textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(100)),
                    _checkWidget(
                      S.of(context).w_item_1,
                      checkOne,
                      (selected) => setState(() => checkOne = selected!),
                    ),
                    _checkWidget(
                      S.of(context).w_item_2,
                      checkTow,
                      (selected) => setState(() => checkTow = selected!),
                    ),
                    _checkWidget(
                      S.of(context).w_item_3,
                      checkThree,
                      (selected) => setState(() => checkThree = selected!),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(180.0)),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Divider(height: 1),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: ScreenUtil().setWidth(148.0),
                          padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(30.0),
                            top: ScreenUtil().setWidth(30.0),
                            bottom: ScreenUtil().setWidth(30.0),
                          ),
                          color: AppColorTokens.of(context).bgBase,
                          child: AppButton(
                            label: S.of(context).g_key_wallet_c10,
                            onPressed: allChecked ? _onCreateTap : null,
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(30.0)),
                      Expanded(
                        child: Container(
                          height: ScreenUtil().setWidth(148.0),
                          padding: EdgeInsets.only(
                            right: ScreenUtil().setWidth(30.0),
                            top: ScreenUtil().setWidth(30.0),
                            bottom: ScreenUtil().setWidth(30.0),
                          ),
                          child: AppButton(
                            label: S.of(context).g_key_wallet_c21,
                            variant: AppButtonVariant.secondary,
                            onPressed: _onWatchOnlyTap,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkWidget(String value, bool check, void Function(bool?) onTap) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
      child: Row(
        children: [
          RoundCheckBox(
            isChecked: check,
            size: ScreenUtil().setWidth(50),
            onTap: onTap,
            checkedWidget: Center(
              child: Icon(
                Icons.check,
                size: ScreenUtil().setWidth(32),
                color: Colors.white,
              ),
            ),
            checkedColor: AppColorTokens.of(context).brand,
            animationDuration: const Duration(milliseconds: 50),
          ),
          SizedBox(width: ScreenUtil().setWidth(20.0)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24.0),
                color: AppColorTokens.of(context).textSubtitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
