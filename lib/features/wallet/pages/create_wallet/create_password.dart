import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/widgets/login_title.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_finish.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class CreatePassword extends ConsumerStatefulWidget {
  final WalletInfo wInfo;
  final String createMetod; // Create, Import, PrivateKey
  const CreatePassword(this.wInfo, {this.createMetod = "Create", super.key});

  @override
  ConsumerState<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends ConsumerState<CreatePassword> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _uPasswordController = TextEditingController();
  final TextEditingController _uPasswordConfirmController =
      TextEditingController();
  final FocusNode _uPasswordFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _uPasswordConfirmFocusNode = FocusNode();
  String titleErrorMessage = "";
  String uPasswordErrorMessage = "";
  String uPasswordConfirmErrorMessage = "";
  bool showPwd1 = true;
  bool showPwd2 = true;

  @override
  void initState() {
    widget.wInfo.walletName =
        "Account${ref.read(wapBridgeProvider).walletInfoLsit.length + 1}";
    _titleController.text = widget.wInfo.walletName ?? "";
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _uPasswordController.dispose();
    _uPasswordConfirmController.dispose();
    _titleFocusNode.dispose();
    _uPasswordFocusNode.dispose();
    _uPasswordConfirmFocusNode.dispose();
    super.dispose();
  }

  Widget _stepIndicator() {
    return Container(
      height: ScreenUtil().setWidth(10.0),
      width: ScreenUtil().setWidth(88.0),
      decoration: BoxDecoration(
        borderRadius: AppRadius.brSm,
        color: AppColorTokens.of(context).brand,
      ),
    );
  }

  Widget _stepGap() => SizedBox(width: ScreenUtil().setWidth(20.0));

  TextStyle _hintStyle() => TextStyle(
    color: AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.hintTextColor.name,
    ),
    fontSize: ScreenUtil().setSp(30.0),
  );

  Widget _buildPasswordToggle(bool obscure) {
    return Container(
      width: ScreenUtil().setWidth(50.0),
      height: ScreenUtil().setWidth(50.0),
      alignment: Alignment.center,
      child: Image.asset(
        'assets/login/${obscure ? "icon_denglu_yincang" : "icon_denglu_xianshi"}.png',
        width: ScreenUtil().setWidth(34.0),
        color: AppColorTokens.of(context).brand,
      ),
    );
  }

  Widget _buildFieldContainer({
    required Widget child,
    double bottomMargin = 20,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: ScreenUtil().setWidth(108.0)),
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(10),
        bottom: ScreenUtil().setWidth(bottomMargin),
      ),
      width: double.infinity,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int stepCount = widget.createMetod == "Create" ? 4 : 2;
    final List<Widget> titleChild = [];
    for (int i = 0; i < stepCount; i++) {
      if (i > 0) titleChild.add(_stepGap());
      titleChild.add(_stepIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColorTokens.of(context).bgBase,
        title: Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: titleChild,
          ),
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
                        S.of(context).g_key_wallet_c47,
                        style: AppTypography.titleLg.copyWith(
                          color: AppColorTokens.of(context).textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    LoginTitle(
                      title: S.of(context).g_key_wallet_c48,
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor10.name,
                      ),
                      must: true,
                    ),
                    _buildFieldContainer(
                      child: textFieldStyle3(
                        context,
                        onEditingComplete: () {
                          FocusScope.of(
                            context,
                          ).requestFocus(_uPasswordFocusNode);
                        },
                        height: ScreenUtil().setWidth(108.0),
                        maxLengths: AppConfig.walletNameMaxLength,
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        hintText: S.of(context).g_key_wallet_c34,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        errorMessage: titleErrorMessage,
                        hintStyle: _hintStyle(),
                      ),
                    ),
                    LoginTitle(
                      title: S.of(context).login_password,
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor10.name,
                      ),
                      must: true,
                    ),
                    _buildFieldContainer(
                      child: textFieldStyle3(
                        context,
                        onEditingComplete: () {
                          FocusScope.of(
                            context,
                          ).requestFocus(_uPasswordConfirmFocusNode);
                        },
                        height: ScreenUtil().setWidth(108.0),
                        controller: _uPasswordController,
                        focusNode: _uPasswordFocusNode,
                        hintText: S.of(context).rest_Choose_password,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.next,
                        errorMessage: uPasswordErrorMessage,
                        hintStyle: _hintStyle(),
                        obscure: showPwd1,
                        rightWidget1: _buildPasswordToggle(showPwd1),
                        rightOnTap1: () {
                          setState(() {
                            showPwd1 = !showPwd1;
                          });
                        },
                      ),
                    ),
                    LoginTitle(
                      title: S.of(context).rest_Confirm_password,
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor10.name,
                      ),
                      must: true,
                    ),
                    _buildFieldContainer(
                      bottomMargin: 0,
                      child: textFieldStyle3(
                        context,
                        onEditingComplete: () {
                          FocusScope.of(context).unfocus();
                        },
                        height: ScreenUtil().setWidth(108.0),
                        controller: _uPasswordConfirmController,
                        focusNode: _uPasswordConfirmFocusNode,
                        hintText: S.of(context).repeatPassword,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        errorMessage: uPasswordConfirmErrorMessage,
                        hintStyle: _hintStyle(),
                        obscure: showPwd2,
                        rightWidget1: _buildPasswordToggle(showPwd2),
                        rightOnTap1: () {
                          setState(() {
                            showPwd2 = !showPwd2;
                          });
                        },
                      ),
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
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                    width: double.infinity,
                    color: AppColorTokens.of(context).bgBase,
                    child: AppButton(
                      label: S.of(context).g_key_115,
                      onPressed: () async {
                        final wName = _titleController.text.trim();
                        final password = _uPasswordController.text.trim();
                        final rPassword = _uPasswordConfirmController.text
                            .trim();

                        String titleErr = "", pwdErr = "", confirmErr = "";
                        if (wName.isEmpty) {
                          titleErr = S.of(context).g_key_wallet_c34;
                        } else if (password.isEmpty) {
                          pwdErr = S.of(context).g_key_21;
                        } else if (!Regular().isPassword(password)) {
                          pwdErr = S.of(context).rest_Choose_password;
                        } else if (rPassword.isEmpty) {
                          confirmErr = S.of(context).g_key_21;
                        } else if (password != rPassword) {
                          confirmErr = S.of(context).g_key_25;
                        }

                        titleErrorMessage = titleErr;
                        uPasswordErrorMessage = pwdErr;
                        uPasswordConfirmErrorMessage = confirmErr;

                        final firstError = [
                          titleErr,
                          pwdErr,
                          confirmErr,
                        ].firstWhere((e) => e.isNotEmpty, orElse: () => "");
                        if (firstError.isNotEmpty) {
                          ToastUtils.show(firstError);
                          setState(() {});
                          return;
                        }

                        widget.wInfo.password = password;
                        widget.wInfo.walletName = wName;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateFinish(
                              wInfo: widget.wInfo,
                              createMetod: widget.createMetod,
                            ),
                          ),
                        );
                      },
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
