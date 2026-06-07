import 'package:n42_wallet/features/widgets/login_title.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

class BackupThree extends ConsumerStatefulWidget {
  final WalletInfo walletInfo;
  final int walletIndex;
  const BackupThree(this.walletInfo, this.walletIndex, {super.key});

  @override
  ConsumerState<BackupThree> createState() => _BackupThreeState();
}

class _BackupThreeState extends ConsumerState<BackupThree> {
  final TextEditingController _uPasswordController = TextEditingController();
  final TextEditingController _uPasswordConfirmController =
      TextEditingController();
  final FocusNode _uPasswordFocusNode = FocusNode();
  final FocusNode _uPasswordConfirmFocusNode = FocusNode();
  bool _submitting = false;
  String uPasswordErrorMessage = "";
  String uPasswordConfirmErrorMessage = "";
  bool showPwd1 = true;
  bool showPwd2 = true;

  @override
  void dispose() {
    _uPasswordController.dispose();
    _uPasswordConfirmController.dispose();
    _uPasswordFocusNode.dispose();
    _uPasswordConfirmFocusNode.dispose();
    super.dispose();
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required String errorMessage,
    required bool obscure,
    required VoidCallback onToggleObscure,
    required VoidCallback onEditingComplete,
    TextInputAction textInputAction = TextInputAction.next,
    EdgeInsetsGeometry? margin,
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
        keyboardType: TextInputType.visiblePassword,
        textInputAction: textInputAction,
        errorMessage: errorMessage,
        hintStyle: AppTypography.body.copyWith(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.hintTextColor.name,
          ),
        ),
        obscure: obscure,
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

  Future<void> _onSubmit() async {
    if (_submitting) return;
    final password = _uPasswordController.text.trim();
    final rPassword = _uPasswordConfirmController.text.trim();
    if (password.isEmpty) {
      uPasswordErrorMessage = S.of(context).g_key_21;
      ToastUtils.show(uPasswordErrorMessage);
      return;
    }
    if (!Regular().isPassword(password)) {
      uPasswordErrorMessage = S.of(context).rest_Choose_password;
      ToastUtils.show(uPasswordErrorMessage);
      return;
    }
    setState(() => uPasswordErrorMessage = "");
    if (rPassword.isEmpty) {
      uPasswordConfirmErrorMessage = S.of(context).g_key_21;
      ToastUtils.show(uPasswordConfirmErrorMessage);
      return;
    }
    if (password != rPassword) {
      uPasswordConfirmErrorMessage = S.of(context).g_key_25;
      ToastUtils.show(uPasswordConfirmErrorMessage);
      return;
    }
    setState(() => uPasswordConfirmErrorMessage = "");
    widget.walletInfo.password = password;
    setState(() => _submitting = true);
    var completedWithExit = false;
    try {
      final wap = ref.read(wapBridgeProvider);
      await wap.saveWalletInfo(widget.walletInfo, widget.walletIndex);
      if (!mounted) return;
      if (widget.walletIndex == wap.walletIndex) {
        ref.read(wapBridgeProvider).initWallet();
      }
      ToastUtils.show(S.of(context).g_key_185);
      eventBus.fire(
        EventPublic(EventPublicType.backup, param: widget.walletInfo),
      );
      completedWithExit = true;
      Navigator.pop(context);
    } catch (e) {
      ToastUtils.show(e.toString());
    } finally {
      if (mounted && !completedWithExit) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_wallet_c37),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.space8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      errorMessage: uPasswordErrorMessage,
                      obscure: showPwd1,
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
                      errorMessage: uPasswordConfirmErrorMessage,
                      obscure: showPwd2,
                      textInputAction: TextInputAction.done,
                      onToggleObscure: () =>
                          setState(() => showPwd2 = !showPwd2),
                      onEditingComplete: () => FocusScope.of(context).unfocus(),
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
                  const Divider(height: 1, indent: 0, endIndent: 0),
                  Container(
                    height: ScreenUtil().setWidth(148.0),
                    padding: EdgeInsets.all(AppSpacing.space8),
                    width: double.infinity,
                    child: AppButton(
                      label: S.of(context).g_key_115,
                      onPressed: _onSubmit,
                      loading: _submitting,
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
