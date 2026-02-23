import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/mining_v2/api/mining_api.dart';
import 'package:n42_wallet/features/mining_v2/pages/key_management/data_encryption.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/shared/di/service_locator.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';

class MiningOutputPk extends StatefulWidget {
  final Map<String,dynamic>? value;
  const MiningOutputPk({this.value,super.key});

  @override
  State<MiningOutputPk> createState() => _MiningOutputPkState();
}

class _MiningOutputPkState extends State<MiningOutputPk> {
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final FocusNode _pwdFocus=FocusNode();
  final FocusNode _confirmFocus=FocusNode();
  String pwdErrorMessage="";
  String confirmErrorMessage="";

  bool _showEncryptResult = false;
  String _encryptedData = "";
  bool obscure=true;
  Load load=Load.finish;
  bool copyEncrypte=false;
  Map<String,dynamic>? encrypteData;
  Map<String,dynamic>? _localValue;

  // 模拟加密函数：你可以替换成真实加密逻辑
  Future<String> encryptData(String password) async {
    _localValue ??= widget.value ?? await MiningApi.init().generateBls12381Keypair();
    if (!mounted) return "";

    // Use IWalletService instead of WalletActionProvider
    final walletService = ServiceLocatorSetup.walletService;
    if (walletService == null) return "";

    final miningIndex = walletService.miningWalletIndex;
    final privateKey = await walletService.getPrivateKeyForWallet(miningIndex);
    final mnemonic = await walletService.getMnemonicForWallet(miningIndex);

    encrypteData = {
      'validator': _localValue,
      "privateKey": privateKey ?? "",
      "mnemonicWords": mnemonic ?? "",
    };
    return await encryptSecret(data: encrypteData!, password: password);
  }

  void _onConfirm() async{
    final pwd = _pwdController.text;
    final confirm = _confirmController.text;

    if (pwd.length != 8) {
      setState(() {
        pwdErrorMessage=S.of(context).g_mining_key_98(8);
      });
      return;
    }

    if (pwd != confirm) {
      setState(() {
        confirmErrorMessage=S.of(context).g_key_passwords_not_match;
      });
      return;
    }
    pwdErrorMessage="";
    confirmErrorMessage="";

    // 显示加载状态
    setState(() {
      load = Load.loading;
    });

    try {
      _encryptedData = await encryptData(pwd);
      // 执行加密
      if (mounted) {
        setState(() {
          load = Load.finish;
          _showEncryptResult = true; // 切换状态
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          load = Load.finish;
        });
        ToastUtils.show('加密失败: $e');
      }
    }
  }

  void _copyEncryptedData() {
    debugPrint(_encryptedData);
    Clipboard.setData(ClipboardData(text: _encryptedData));
    ToastUtils.show(S.of(context).copy);
    setState(() {
      copyEncrypte=true;
    });
  }

  @override
  void dispose() {
    _pwdController.dispose();
    _confirmController.dispose();
    _pwdFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // 返回时传递 copyEncrypte 的值
        if (mounted) {
          Navigator.of(context).pop(copyEncrypte==false?null:encrypteData);
        }
      },
      child: Scaffold(
      appBar: AppBar(title: Text(S.of(context).g_mining_key_96)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_showEncryptResult) ...[
              Text(
                S.of(context).g_mining_key_97,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(32),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(10)),
              textFieldStyle3(
                  context,
                controller: _pwdController,
                focusNode: _pwdFocus,
                hintText: S.of(context).g_mining_key_98(8),
                textInputAction:TextInputAction.next,
                errorMessage: pwdErrorMessage,
                onEditingComplete: (){
                  FocusScope.of(context).requestFocus(_confirmFocus);
                },
                obscure: obscure,
                rightWidget1: Container(
                  width: ScreenUtil().setWidth(50.0),
                  height: ScreenUtil().setWidth(50.0),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/login/${obscure?"icon_denglu_yincang":"icon_denglu_xianshi"}.png',
                    width: ScreenUtil().setWidth(34.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  ),
                ),
                rightOnTap1: (){
                  setState(() {
                    obscure=!obscure;
                  });
                },
              ),
              SizedBox(height: ScreenUtil().setWidth(40)),
              Text(
                S.of(context).g_mining_key_99,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(10)),
              textFieldStyle3(
                context,
                controller: _confirmController,
                focusNode: _confirmFocus,
                hintText: S.of(context).rest_Confirm_password,
                textInputAction:TextInputAction.done,
                errorMessage: confirmErrorMessage,
                onEditingComplete: (){
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                obscure: obscure,
                rightWidget1: Container(
                  width: ScreenUtil().setWidth(50.0),
                  height: ScreenUtil().setWidth(50.0),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/login/${obscure?"icon_denglu_yincang":"icon_denglu_xianshi"}.png',
                    width: ScreenUtil().setWidth(34.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  ),
                ),
                rightOnTap1: (){
                  setState(() {
                    obscure=!obscure;
                  });
                },
              ),
            ],

            if (_showEncryptResult) ...[
              Text(
                S.of(context).g_mining_key_100,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(36),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(40)),
              Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                ),
                width: double.infinity,
                child: Text(
                  _encryptedData,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(32),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child:  Container(
          margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
          width: double.infinity,
          height: ScreenUtil().setWidth(88),
          child: buttonStyle6(
            context,
            _showEncryptResult ? _copyEncryptedData : _onConfirm,
            _showEncryptResult ? S.of(context).g_mining_key_101 : S.of(context).g_key_78,
            AppThemeUtils.getColorByKey(context, load==Load.loading?AppThemeKeys.mainButtonBgColor3.name:AppThemeKeys.mainButtonBgColor.name),
            AppThemeUtils.getColorByKey(context,load==Load.loading?AppThemeKeys.mainButtonTextColor3.name:AppThemeKeys.mainButtonTextColor.name),
            load==Load.loading,
          ),
        ),
      ),
      ),
    );
  }
}
