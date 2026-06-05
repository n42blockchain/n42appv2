import 'dart:async' show unawaited;
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_password.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class ImportOne extends ConsumerStatefulWidget {
  const ImportOne({super.key});

  @override
  ConsumerState<ImportOne> createState() => _ImportOneState();
}

class _ImportOneState extends ConsumerState<ImportOne>
    with WidgetsBindingObserver {
  TextEditingController inputEditingController = TextEditingController();
  String inputMW = "";
  String errorMessage = "";

  void checkInput(String value) {
    final words = value.trim().split(" ").where((w) => w.trim().isNotEmpty);
    setState(() {
      inputMW = words.join(" ").toLowerCase();
    });
  }

  Future<void> handlerCopyText() async {
    ClipboardData? clipboardData = await Clipboard.getData(
      Clipboard.kTextPlain,
    );
    final text = clipboardData?.text;
    unawaited(Clipboard.setData(const ClipboardData(text: "")));
    if (!mounted || text == null || text == "null" || text.isEmpty) return;
    try {
      checkInput(text);
      bool checkMnemonic = await Trustdart().checkMnemonic(inputMW);
      if (!mounted) return;
      if (checkMnemonic) {
        inputEditingController.text = inputMW;
      } else {
        inputMW = "";
      }
      setState(() {});
    } catch (e) {
      assert(() {
        AppLogger.w('ImportOne', 'checkMnemonic failed: $e');
        return true;
      }());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    handlerCopyText();
  }

  @override
  void dispose() {
    // Clear mnemonic data from memory before disposing
    inputEditingController.clear();
    inputEditingController.dispose();
    inputMW = "";
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _buildStepIndicator(Color color) {
    return Container(
      height: ScreenUtil().setWidth(10.0),
      width: ScreenUtil().setWidth(144.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
        color: color,
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (inputMW.isEmpty) return;
    bool checkMnemonic = await Trustdart().checkMnemonic(inputMW);
    if (!mounted) return;
    if (!checkMnemonic) {
      errorMessage = S.of(context).w_key_12;
      setState(() {});
      ToastUtils.show(errorMessage);
      return;
    }
    WalletInfo? fWalletInfo = ref
        .read(wapBridgeProvider)
        .findWallet(mnemonic: inputMW);
    if (fWalletInfo != null) {
      errorMessage = S.of(context).g_key_214(fWalletInfo.walletName ?? "");
      setState(() {});
      ToastUtils.show(errorMessage);
      return;
    }
    errorMessage = "";
    setState(() {});
    WalletInfo wInfo = WalletInfo(
      walletName: "",
      password: "",
      walletUuid: ref.read(wapBridgeProvider).userUUID,
      mnemonic: inputMW,
    );
    final beforeWalletCount = ref.read(wapBridgeProvider).walletInfoLsit.length;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePassword(wInfo, createMetod: "Import"),
      ),
    );
    if (!mounted) return;
    final afterWalletCount = ref.read(wapBridgeProvider).walletInfoLsit.length;
    if (afterWalletCount > beforeWalletCount) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.mainBlueColor.name,
    );
    final inactiveColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.dividerColor.name,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.backGroundColor.name,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepIndicator(activeColor),
            SizedBox(width: ScreenUtil().setWidth(20.0)),
            _buildStepIndicator(inactiveColor),
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
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                      alignment: Alignment.center,
                      child: Text(
                        S.of(context).g_key_wallet_c6,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(40.0),
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor.name,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(60.0),
                        vertical: ScreenUtil().setWidth(60.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        S.of(context).g_key_wallet_c7,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32.0),
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor.name,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(20),
                        horizontal: ScreenUtil().setWidth(20),
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(30.0),
                      ),
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemBgColor.name,
                        ),
                        borderRadius: BorderRadius.circular(
                          ScreenUtil().setWidth(8),
                        ),
                      ),
                      child: TextField(
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainBlueColor.name,
                          ),
                          fontSize: ScreenUtil().setSp(32.0),
                        ),
                        controller: inputEditingController,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: S.of(context).g_key_wallet_m21,
                          border: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: ScreenUtil().setWidth(10.0),
                          ),
                        ),
                        maxLines: 8,
                        onChanged: checkInput,
                        onEditingComplete: () =>
                            FocusScope.of(context).unfocus(),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                      child: Text(
                        inputMW,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainBlueColor.name,
                          ),
                          fontSize: ScreenUtil().setSp(32),
                        ),
                      ),
                    ),
                    if (errorMessage.isNotEmpty)
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                        margin: EdgeInsets.only(top: ScreenUtil().setWidth(30)),
                        decoration: BoxDecoration(
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.errorBgColor.name,
                          ),
                          borderRadius: BorderRadius.circular(
                            ScreenUtil().setWidth(8),
                          ),
                        ),
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.errorTextColor.name,
                            ),
                            fontSize: ScreenUtil().setSp(26),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
                  Container(
                    height: ScreenUtil().setWidth(148.0),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                    width: double.infinity,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.backGroundColor.name,
                    ),
                    child: AppButton(
                      label: S.of(context).g_key_11,
                      onPressed: _onSubmit,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
