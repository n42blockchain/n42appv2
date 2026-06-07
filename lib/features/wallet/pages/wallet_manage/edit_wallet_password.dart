import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/widgets/login_title.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/features/wallet/pages/wallet_manage/edit_wallet_password_utils.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditWalletPassword extends ConsumerStatefulWidget {
  final WalletInfo walletInfo;
  final int walletIndex;
  const EditWalletPassword(this.walletInfo, this.walletIndex, {super.key});

  @override
  ConsumerState<EditWalletPassword> createState() => _EditWalletPasswordState();
}

class _EditWalletPasswordState extends ConsumerState<EditWalletPassword> {
  final TextEditingController _uPasswordController = TextEditingController();
  final TextEditingController _uPasswordConfirmController =
      TextEditingController();
  final TextEditingController _lPasswordController = TextEditingController();
  final FocusNode _uPasswordFocusNode = FocusNode();
  final FocusNode _uPasswordConfirmFocusNode = FocusNode();
  final FocusNode _lPasswordFocusNode = FocusNode();
  String uPasswordErrorMessage = "";
  String uPasswordConfirmErrorMessage = "";
  String lPasswordErrorMessage = "";
  bool showPwd1 = true;
  bool showPwd2 = true;
  bool showPwd = true;
  Load load = Load.finish;

  @override
  void dispose() {
    _uPasswordController.dispose();
    _uPasswordConfirmController.dispose();
    _lPasswordController.dispose();
    _uPasswordFocusNode.dispose();
    _uPasswordConfirmFocusNode.dispose();
    _lPasswordFocusNode.dispose();
    super.dispose();
  }

  /// 构建统一的密码输入字段
  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required bool obscure,
    required String errorMessage,
    required VoidCallback onToggleObscure,
    required VoidCallback onEditingComplete,
    TextInputType keyboardType = TextInputType.visiblePassword,
    EdgeInsets? margin,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: ScreenUtil().setWidth(108.0)),
      margin:
          margin ??
          EdgeInsets.only(
            top: ScreenUtil().setWidth(10),
            bottom: ScreenUtil().setWidth(20),
          ),
      width: double.infinity,
      child: textFieldStyle3(
        context,
        onEditingComplete: onEditingComplete,
        height: ScreenUtil().setWidth(108.0),
        controller: controller,
        focusNode: focusNode,
        hintText: hintText,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.done,
        hintStyle: AppTypography.body.copyWith(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.hintTextColor.name,
          ),
        ),
        obscure: obscure,
        errorMessage: errorMessage,
        rightWidget1: Container(
          width: ScreenUtil().setWidth(50.0),
          height: ScreenUtil().setWidth(50.0),
          alignment: Alignment.center,
          child: Image.asset(
            'assets/login/${obscure ? "icon_denglu_yincang" : "icon_denglu_xianshi"}.png',
            width: ScreenUtil().setWidth(34.0),
            color: AppColorTokens.of(context).brand,
          ),
        ),
        rightOnTap1: onToggleObscure,
      ),
    );
  }

  void _setErrorAndToast(String field, String message) {
    setState(() {
      if (field == 'new') {
        uPasswordErrorMessage = message;
      } else if (field == 'confirm') {
        uPasswordConfirmErrorMessage = message;
      } else {
        lPasswordErrorMessage = message;
      }
    });
    ToastUtils.show(message);
  }

  Future<void> _onSubmit() async {
    final s = S.of(context);
    final password = _uPasswordController.text.trim();
    final rPassword = _uPasswordConfirmController.text.trim();
    final lPassword = _lPasswordController.text.trim();

    if (password.isEmpty) {
      _setErrorAndToast('new', s.g_key_21);
      return;
    }
    if (!Regular().isPassword(password)) {
      _setErrorAndToast('new', s.rest_Choose_password);
      return;
    }
    setState(() => uPasswordErrorMessage = "");

    if (rPassword.isEmpty) {
      _setErrorAndToast('confirm', s.g_key_21);
      return;
    }
    if (password != rPassword) {
      _setErrorAndToast('confirm', s.g_key_25);
      return;
    }
    setState(() => uPasswordConfirmErrorMessage = "");

    if (lPassword.isEmpty) {
      _setErrorAndToast('old', s.g_key_21);
      return;
    }
    if (widget.walletInfo.password != lPassword) {
      _setErrorAndToast('old', s.g_key_146);
      return;
    }
    setState(() => lPasswordErrorMessage = "");

    try {
      setState(() => load = Load.loading);
      widget.walletInfo.password = password;
      final wap = ref.read(wapBridgeProvider);
      final successMessage = s.g_key_185;
      await wap.saveWalletInfo(widget.walletInfo, widget.walletIndex);
      if (!mounted) return;
      setState(() => load = Load.finish);
      ToastUtils.show(successMessage);
      Navigator.pop(context, widget.walletInfo);
    } catch (err) {
      if (mounted) {
        setState(() => load = Load.finish);
      }
      ToastUtils.show(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canDismissEditWalletPassword(load),
      child: Scaffold(
        appBar: AppBarWidget(text: S.of(context).g_key_206),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.space8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LoginTitle(
                        title: S.of(context).g_key_207,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor10.name,
                        ),
                        must: true,
                      ),
                      _buildPasswordField(
                        controller: _lPasswordController,
                        focusNode: _lPasswordFocusNode,
                        hintText: S.of(context).rest_Choose_password,
                        keyboardType: TextInputType.text,
                        obscure: showPwd,
                        errorMessage: lPasswordErrorMessage,
                        onToggleObscure: () =>
                            setState(() => showPwd = !showPwd),
                        onEditingComplete: () => FocusScope.of(
                          context,
                        ).requestFocus(_uPasswordFocusNode),
                      ),
                      LoginTitle(
                        title: S.of(context).login_password,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor10.name,
                        ),
                        must: true,
                      ),
                      _buildPasswordField(
                        controller: _uPasswordController,
                        focusNode: _uPasswordFocusNode,
                        hintText: S.of(context).rest_Choose_password,
                        obscure: showPwd1,
                        errorMessage: uPasswordErrorMessage,
                        onToggleObscure: () =>
                            setState(() => showPwd1 = !showPwd1),
                        onEditingComplete: () => FocusScope.of(
                          context,
                        ).requestFocus(_uPasswordConfirmFocusNode),
                      ),
                      LoginTitle(
                        title: S.of(context).rest_Confirm_password,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor10.name,
                        ),
                        must: true,
                      ),
                      _buildPasswordField(
                        controller: _uPasswordConfirmController,
                        focusNode: _uPasswordConfirmFocusNode,
                        hintText: S.of(context).repeatPassword,
                        obscure: showPwd2,
                        errorMessage: uPasswordConfirmErrorMessage,
                        onToggleObscure: () =>
                            setState(() => showPwd2 = !showPwd2),
                        onEditingComplete: () =>
                            FocusScope.of(context).unfocus(),
                        margin: EdgeInsets.only(top: ScreenUtil().setWidth(10)),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(148.0)),
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
                    Divider(height: 1),
                    Container(
                      height: ScreenUtil().setWidth(148.0),
                      padding: EdgeInsets.all(AppSpacing.space8),
                      width: double.infinity,
                      child: AppButton(
                        label: S.of(context).g_key_115,
                        onPressed: _onSubmit,
                        loading: load == Load.loading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
