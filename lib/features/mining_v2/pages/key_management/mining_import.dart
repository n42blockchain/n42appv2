import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/mining_v2/api/mining_api.dart';
import 'package:n42_wallet/features/mining_v2/pages/key_management/data_encryption.dart';
import 'package:n42_wallet/features/mining_v2/pages/key_management/file_import.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/mining/presentation/providers/mining_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

class MiningImport extends ConsumerStatefulWidget {
  const MiningImport({super.key});

  @override
  ConsumerState<MiningImport> createState() => _MiningImportState();
}

class _MiningImportState extends ConsumerState<MiningImport> {
  final TextEditingController _encryptedDataController = TextEditingController();
  final FocusNode _encryptedDataFocusNode = FocusNode();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  String _encryptedDataErrorMessage = "";
  String _passwordErrorMessage = "";
  String _errorMessage = "";
  Load _load = Load.finish;
  bool obscure = true;

  static const int _passwordLength = 8;
  static const double _fieldSpacing = 10.0;

  @override
  void initState() {
    super.initState();
    //_encryptedDataController.text='{"version":"1","timestamp":"2026-01-06T06:17:27.242127Z","kdf":{"name":"pbkdf2","params":{"iterations":150000,"dklen":32},"salt":"tsYiFXiXMvEYZooGWPgttA=="},"cipher":{"name":"aes-256-gcm","iv":"bS/oYySmQN06y8V6"},"ciphertext":"QTdTjLDB50YcTW+rBObQoKDBlvTYBIv6lNR4TgdHdSI4Mq4yvsrcgBgyIDCsTkMMthpz3QHO21yplLBtZQcz6K60arMrTWV0AkREiDxw3bH6/dsa5l+qTV7ridijom8dwSUGKSMYLEYzRAwSdx2L7HPoG8ImvQZZiwhm+sTzmLQ/TH47zpS7UzeMVrKLCmh2tTxuPzR0DO7LmQvLRz8JlaX29mvLmeIEKpLTTne9pC8QAySjc7LutjsBPSEekxRYUFTGNhykkn4ahAMZjbiFGVJTyvnly4VDPDA4BfILW+444HmQrVuy+BJX6z4g69r62HsFGic5TmwhVo66/Eh6PFLqR+OXsae7WfKezozrmCJsWrsVeyozu53kRK9rWFUMaZgDKX60ymzx4TyM1O4zCDCv1sN/luS3xinOtkm3wqMR79C4Xx5tMo3I46ODrUArrb8RRAOBHZbEewX3RynDfnqgnMY++q7NA0is","tag":"4UX62Xy5HPal1AtekQFQIQ=="}';
  }
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

    final encryptedData = _encryptedDataController.text.trim();
    final password = _passwordController.text.trim();
    if (!_validateEncryptedData(encryptedData)) return;
    if (!_validatePassword(password)) return;

    try {
      setState(() {
        _load = Load.loading;
        _errorMessage = "";
      });

      final secretMap = await decryptSecret(
        encryptedData: encryptedData,
        password: password,
      );

      bool isMining = true;
      final bvRmm = await MiningApi.init().getBeaconValidator(
          secretMap['validator']['publicKey']);
      if (bvRmm.error == false) {
        final eTimestamp = bvRmm.data?['exit_timestamp'] ?? 0;
        if (eTimestamp != 0) isMining = false;
      }
      secretMap['isMining'] = isMining;

      if (!mounted) return;
      final rmm = await ref.read(miningBridgeProvider)
          .setMiningDataImport(secretMap, password);
      if (!mounted) return;

      final messageStr = rmm.error
          ? rmm.data as String
          : S.of(context).g_mining_key_104;
      ToastUtils.show(messageStr);
      if (!rmm.error) Navigator.pop(context);
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
        _passwordErrorMessage = S.of(context).g_mining_key_98(_passwordLength);
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
      return S.of(context).g_mining_key_107;
    }
    if (errorStr.contains('不支持的加密版本')) {
      return S.of(context).g_mining_key_108;
    }
    if (errorStr.contains('ArgumentError')) {
      return errorStr.replaceAll('ArgumentError: ', '');
    }
    return S.of(context).g_mining_key_109(errorStr);
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
          ?rightWidget,
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
    return textFieldStyle2(
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
    return textFieldStyle3(
      context,
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      textInputAction: TextInputAction.done,
      onChanged: (value) => _validatePassword(value),
      onEditingComplete: () {
        FocusScope.of(context).unfocus();
      },
      height: ScreenUtil().setWidth(88),
      errorMessage: _passwordErrorMessage,
      hintText: S.of(context).g_mining_key_98(_passwordLength),
      obscure: obscure,
      rightWidget1: Container(
        width: ScreenUtil().setWidth(50.0),
        height: ScreenUtil().setWidth(50.0),
        alignment: Alignment.center,
        child: Image.asset(
          'assets/login/${obscure ? "icon_denglu_yincang" : "icon_denglu_xianshi"}.png',
          width: ScreenUtil().setWidth(34.0),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        ),
      ),
      rightOnTap1: () => setState(() => obscure = !obscure),
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
      child: buttonStyle6(
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
