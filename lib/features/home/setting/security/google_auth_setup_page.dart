import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/security/totp_util.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Google Authenticator 绑定页面
///
/// 返回值：绑定成功时 pop(secret 字符串)，取消时 pop(null)。
class GoogleAuthSetupPage extends StatefulWidget {
  const GoogleAuthSetupPage({super.key});

  @override
  State<GoogleAuthSetupPage> createState() => _GoogleAuthSetupPageState();
}

class _GoogleAuthSetupPageState extends State<GoogleAuthSetupPage> {
  late final String _secret;
  late final String _otpAuthUri;
  final TextEditingController _codeController = TextEditingController();
  String _errorMessage = '';
  bool _showManualKey = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _secret = TotpUtil.generateSecret();
    final account =
        AppGlobals.currentUserEmail ?? AppGlobals.userInfo?.uuid ?? 'user';
    _otpAuthUri = TotpUtil.buildOtpAuthUri(secret: _secret, account: account);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _verify() {
    if (_completed) return;
    final code = _codeController.text.trim();
    if (TotpUtil.verify(_secret, code)) {
      _completed = true;
      Navigator.pop(context, _secret);
    } else {
      setState(() => _errorMessage = S.of(context).g_google_auth_key6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainText = AppColorTokens.of(context).textPrimary;
    final Color subtitleColor = AppColorTokens.of(context).textSubtitle;
    final Color itemBg = AppColorTokens.of(context).bgSurface;
    final Color mainBlue = AppColorTokens.of(context).brand;
    // Brand / danger text shades that reach 4.5:1 on the page background.
    final Color linkColor = AppColorTokens.of(context).brandOnTint;
    final Color errorColor = AppContrast.ensure(
      AppColorTokens.of(context).danger,
      [AppColorTokens.of(context).bgBase],
      darken: Theme.of(context).brightness != Brightness.dark,
    );

    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_google_auth_key1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.space8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.space4),
              // 说明文字
              Text(
                S.of(context).g_google_auth_key2,
                style: AppTypography.body.copyWith(color: mainText),
              ),
              SizedBox(height: AppSpacing.space8),
              // QR 码
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.brMd,
                  ),
                  padding: EdgeInsets.all(AppSpacing.space4),
                  child: QrImageView(
                    data: _otpAuthUri,
                    version: QrVersions.auto,
                    size: ScreenUtil().setWidth(400.0),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.space4),
              // 手动输入密钥折叠区
              // 44pt row with visible ink (was a 20pt GestureDetector).
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => setState(() => _showManualKey = !_showManualKey),
                  borderRadius: AppRadius.brSm,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: AppTouch.target),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            S.of(context).g_google_auth_key3,
                            style: AppTypography.bodySm.copyWith(
                              color: linkColor,
                            ),
                          ),
                        ),
                        Icon(
                          _showManualKey
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: mainBlue,
                          size: ScreenUtil().setWidth(32.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_showManualKey) ...[
                SizedBox(height: AppSpacing.space4),
                // Ink on the fill's own Material so the press stays visible;
                // the row is at least 44pt tall (was 36pt).
                Material(
                  color: itemBg,
                  borderRadius: AppRadius.brSm,
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: _secret));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(S.of(context).copy),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: AppRadius.brSm,
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(minHeight: AppTouch.target),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.space6,
                        vertical: AppSpacing.space4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _secret,
                              style: AppTypography.bodySm.copyWith(
                                color: mainText,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          Icon(
                            Icons.copy,
                            color: subtitleColor,
                            size: ScreenUtil().setWidth(36.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.space12),
              // 验证码输入
              Text(
                S.of(context).g_google_auth_key4,
                style: AppTypography.bodySm.copyWith(color: subtitleColor),
              ),
              SizedBox(height: AppSpacing.space4),
              Container(
                decoration: BoxDecoration(
                  color: itemBg,
                  borderRadius: AppRadius.brSm,
                ),
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.space6),
                child: TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: AppTypography.headline.copyWith(
                    color: mainText,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    hintText: '000000',
                    hintStyle: AppTypography.headline.copyWith(
                      color: subtitleColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) {
                    if (_errorMessage.isNotEmpty) {
                      setState(() => _errorMessage = '');
                    }
                  },
                  onSubmitted: (_) => _verify(),
                ),
              ),
              if (_errorMessage.isNotEmpty) ...[
                SizedBox(height: AppSpacing.space2),
                Text(
                  _errorMessage,
                  style: AppTypography.caption.copyWith(color: errorColor),
                ),
              ],
              SizedBox(height: AppSpacing.space16),
              // 确认按钮
              // minHeight (not a fixed height) so 130% text is not clipped.
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: double.infinity,
                  minHeight: AppTouch.target,
                ),
                child: ElevatedButton(
                  onPressed: _verify,
                  style: ElevatedButton.styleFrom(
                    // White label needs the 4.5:1 brand fill shade.
                    backgroundColor: AppColorTokens.of(context).brandFill,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ScreenUtil().setWidth(44.0),
                      ),
                    ),
                  ),
                  child: Text(
                    S.of(context).g_key_78,
                    style: AppTypography.body.copyWith(
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainButtonTextColor.name,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.space12),
            ],
          ),
        ),
      ),
    );
  }
}
