import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/miningV2/api/mining_api.dart';
import 'package:n42appv2/src/miningV2/pages/keyManagement/data_encryption.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/textField_widget.dart';
import 'package:provider/provider.dart';

class MiningOutputPk extends StatefulWidget {
  const MiningOutputPk({super.key});

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
  Map<String,dynamic>? encrypteData=null;

  // 模拟加密函数：你可以替换成真实加密逻辑
  encryptData(String password) async{
    Map<String,String>? rdata=await MiningApi.init().generateBls12381Keypair();
    if (!mounted) return "";
    WalletActionProvider wap=Provider.of<WalletActionProvider>(context,listen: false);
    wap.walletInfoLsit[wap.walletMiningIndex].mnemonic;
    encrypteData={'validator':rdata,"privateKey": wap.walletInfoLsit[wap.walletMiningIndex].privateKey??"", "mnemonicWords": wap.walletInfoLsit[wap.walletMiningIndex].mnemonic??"",};
    return await encryptSecret(data: encrypteData!, password: password);
  }

  void _onConfirm() async{
    final pwd = _pwdController.text;
    final confirm = _confirmController.text;

    if (pwd.length != 8) {
      setState(() {
        pwdErrorMessage="密码必须是 8 位";
      });
      return;
    }

    if (pwd != confirm) {
      setState(() {
        confirmErrorMessage="两次输入的密码不一致";
      });
      return;
    }
    pwdErrorMessage="";
    confirmErrorMessage="";
    _encryptedData = await encryptData(pwd);
    // 执行加密
    setState(() {
      _showEncryptResult = true; // 切换状态
    });
  }

  void _copyEncryptedData() {
    Clipboard.setData(ClipboardData(text: _encryptedData));
    print(_encryptedData);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("已复制到剪贴板")),
    );
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
      appBar: AppBar(title: const Text("设置密码并加密")),
      body: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_showEncryptResult) ...[
              Text(
                "请输入加密密码",
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(32),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              TextFieldStyle3(
                  context,
                controller: _pwdController,
                focusNode: _pwdFocus,
                hintText: '请输入8位密码',
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
                "请再次输入密码",
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              TextFieldStyle3(
                context,
                controller: _confirmController,
                focusNode: _confirmFocus,
                hintText: '确认密码',
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
                "加密后的数据：",
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
          child: ButtonStyle6(
            context,
            _showEncryptResult ? _copyEncryptedData : _onConfirm,
            _showEncryptResult ? "复制加密数据" : "确认密码",
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
