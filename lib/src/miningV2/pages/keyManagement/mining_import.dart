import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/miningV2/api/mining_api.dart';
import 'package:n42appv2/src/miningV2/pages/keyManagement/data_encryption.dart';
import 'package:n42appv2/src/miningV2/pages/keyManagement/file_import.dart';
import 'package:n42appv2/src/miningV2/provider/mining_v2_provider.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/utils/toast_utils.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/textField_widget.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class MiningImport extends StatefulWidget {
  const MiningImport({super.key});

  @override
  State<MiningImport> createState() => _MiningImportState();
}

class _MiningImportState extends State<MiningImport> {
  // 控制器和焦点节点
  final TextEditingController _encryptedDataController = TextEditingController();
  final FocusNode _encryptedDataFocusNode = FocusNode();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  // 状态变量
  String _encryptedDataErrorMessage = "";
  String _passwordErrorMessage = "";
  String _errorMessage = "";
  Load _load = Load.finish;
  bool obscure=true;

  // 常量
  static const int _passwordLength = 8;
  static const double _fieldSpacing = 10.0;

  @override
  void dispose() {
    _encryptedDataController.dispose();
    _encryptedDataFocusNode.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// 导入验证者私钥
  Future<void> _importPrivateKey() async {
    if (!mounted) return;

    // 获取输入值
    final encryptedData = _encryptedDataController.text.trim();
    final password = _passwordController.text.trim();

    // 验证输入
    if (!_validateEncryptedData(encryptedData)) return;
    if (!_validatePassword(password)) return;

    try {
      setState(() {
        _load = Load.loading;
        _errorMessage = "";
      });

      // 解密数据
      final secretMap = await decryptSecret(
        encryptedData: encryptedData,
        password: password,
      );

      // 解密成功，可以在这里处理解密后的数据
      debugPrint("解密成功: ${jsonEncode(secretMap)}");
      bool isMining=true;
      MessageModel bvRmm= await MiningApi.init().getBeaconValidator(secretMap['validator']['publicKey']);
      if(bvRmm.error==false){
        int eTimestamp=bvRmm.data?['exit_timestamp']??0;
        if(eTimestamp!=0){
          isMining=false;
        }
      }
      secretMap['isMining']=isMining;
      MessageModel rmm=await Provider.of<MiningV2Provider>(context,listen: false).setMiningData_import(secretMap);
      String messageStr=S.of(context).g_mining_key_104;
      if(rmm.error){
        messageStr=rmm.data as String;
      }
      // TODO: 处理解密后的数据，例如保存到本地或跳转到下一个页面
      ToastUtils.show(messageStr);
      if(rmm.error==false){
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _load = Load.finish;
        });
      }
    }
  }

  /// 验证加密数据
  bool _validateEncryptedData(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      setState(() {
        _encryptedDataErrorMessage = S.of(context).g_mining_key_105;
      });
      return false;
    }
    setState(() {
      _encryptedDataErrorMessage = "";
    });
    return true;
  }

  /// 验证密码
  bool _validatePassword(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      setState(() {
        _passwordErrorMessage = S.of(context).g_mining_key_106;
      });
      return false;
    }
    if (trimmedValue.length != _passwordLength) {
      setState(() {
        _passwordErrorMessage = S.of(context).g_mining_key_98(_passwordLength);//"请输入$_passwordLength位密码！";
      });
      return false;
    }
    setState(() {
      _passwordErrorMessage = "";
    });
    return true;
  }

  /// 获取友好的错误信息
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString();
    if (errorStr.contains('解密失败')) {
      return S.of(context).g_mining_key_107;//"解密失败，请检查密码是否正确!";
    }
    if (errorStr.contains('不支持的加密版本')) {
      return S.of(context).g_mining_key_108;//"不支持的加密数据格式!";
    }
    if (errorStr.contains('ArgumentError')) {
      return errorStr.replaceAll('ArgumentError: ', '');
    }
    return S.of(context).g_mining_key_109(errorStr);//"导入失败: $errorStr";
  }

  /// 从剪贴板粘贴
  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
        _encryptedDataController.text = clipboardData.text!;
        _validateEncryptedData(clipboardData.text!);
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint("粘贴失败: $e");
    }
  }

  /// 从文件导入
  Future<void> _importFromFile() async {
    try {
      final value = await FileImport().fileImport();
      if (value.isNotEmpty) {
        _encryptedDataController.text = value;
        _validateEncryptedData(value);
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.show(S.of(context).g_mining_key_109(e));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_mining_key_82,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget(
              S.of(context).g_mining_key_110,
              rightWidget: _buildActionButtons(),
            ),
            SizedBox(height: ScreenUtil().setWidth(_fieldSpacing)),
            _buildEncryptedDataField(),
            SizedBox(height: ScreenUtil().setWidth(_fieldSpacing)),
            _buildTitleWidget(S.of(context).login_password),
            SizedBox(height: ScreenUtil().setWidth(_fieldSpacing)),
            _buildPasswordField(),
            if (_errorMessage.isNotEmpty) _buildErrorMessage(),
            SizedBox(height: ScreenUtil().setWidth(_fieldSpacing)),
            //_buildImportButton(),
          ],
        ),
      ),
      bottomNavigationBar: _buildImportButton(),
    );
  }

  /// 构建标题组件
  Widget _buildTitleWidget(String title, {Widget? rightWidget}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
          ),
          if (rightWidget != null) rightWidget,
        ],
      ),
    );
  }

  /// 构建操作按钮（粘贴、导入文件）
  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionButton(
          text: S.of(context).g_key_166,
          onTap: _pasteFromClipboard,
        ),
        SizedBox(width: ScreenUtil().setWidth(20)),
        _buildActionButton(
          text: S.of(context).g_mining_key_111,
          onTap: _importFromFile,
        ),
      ],
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
        child: Text(
          text,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(32),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainBlueColor.name,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建加密数据输入框
  Widget _buildEncryptedDataField() {
    return TextFieldStyle2(
      context,
      controller: _encryptedDataController,
      focusNode: _encryptedDataFocusNode,
      textInputAction: TextInputAction.next,
      onChanged: (value) => _validateEncryptedData(value),
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
      maxLines: 20,
      height: ScreenUtil().setWidth(500),
      errorMessage: _encryptedDataErrorMessage,
      hintText: S.of(context).g_mining_key_112,
    );
  }

  /// 构建密码输入框
  Widget _buildPasswordField() {
    return TextFieldStyle3(
      context,
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      textInputAction: TextInputAction.done,
      onChanged: (value) => _validatePassword(value),
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      height: ScreenUtil().setWidth(88),
      errorMessage: _passwordErrorMessage,
      hintText: S.of(context).g_mining_key_98(_passwordLength),//"请输入$_passwordLength位密码",
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
    );
  }

  /// 构建错误信息显示
  Widget _buildErrorMessage() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(_fieldSpacing)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.errorBgColor2.name,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Text(
        _errorMessage,
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.errorTextColor.name,
          ),
          fontSize: ScreenUtil().setSp(28),
        ),
      ),
    );
  }

  /// 构建导入按钮
  Widget _buildImportButton() {
    final isLoading = _load == Load.loading;
    return SafeArea(child: Container(
      height: ScreenUtil().setWidth(88),
      width: double.infinity,
      margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
      child: ButtonStyle6(
        context,
        _importPrivateKey,
        isLoading ? S.of(context).g_mining_key_113 : S.of(context).g_token_m_key_9,
        AppThemeUtils.getColorByKey(
          context,
          isLoading
              ? AppThemeKeys.mainButtonBgColor3.name
              : AppThemeKeys.mainButtonBgColor.name,
        ),
        AppThemeUtils.getColorByKey(
          context,
          isLoading
              ? AppThemeKeys.mainButtonTextColor3.name
              : AppThemeKeys.mainButtonTextColor.name,
        ),
        isLoading,
      ),
    ));
  }
}
