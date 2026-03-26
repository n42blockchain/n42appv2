import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:rate_us_on_store/rate_us_on_store.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckVersionAlert extends StatelessWidget {
  final String newVersion;

  /// 更新日志标题（来自 VersionInfoModel.updateTitle）
  final String updateTitle;

  /// 更新日志正文（来自 VersionInfoModel.updateContent）
  final String introduction;

  /// 1 = 强制更新（不可跳过），其他值 = 可选
  final int isForce;

  /// 自定义下载地址（TestFlight 链接 / 直接 APK）。
  /// 为空时回退至 App Store / Play Store。
  final String? downloadUrl;

  const CheckVersionAlert({
    super.key,
    required this.newVersion,
    required this.introduction,
    required this.isForce,
    this.updateTitle = '',
    this.downloadUrl,
  });

  bool get _forced => isForce == 1;

  Future<void> _openUpdate(BuildContext context) async {
    final url = downloadUrl;
    if (url != null && url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    // 回退：App Store / Play Store
    RateUsOnStore(
      androidPackageName: "com.walletamaze.nftwallet",
      appstoreAppId: "1622941204",
    ).launch();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    final textColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final subtitleColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    final dialogBg =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name);

    return PopScope(
      canPop: !_forced,
      onPopInvokedWithResult: (didPop, _) {
        // 强制更新时阻止返回键关闭弹窗
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(28)),
        ),
        backgroundColor: dialogBg,
        contentPadding: EdgeInsets.fromLTRB(
          ScreenUtil().setWidth(36),
          ScreenUtil().setWidth(36),
          ScreenUtil().setWidth(36),
          ScreenUtil().setWidth(24),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 图标 ──────────────────────────────────────────────────
              Image.asset(
                "assets/img/huojian.png",
                width: ScreenUtil().setWidth(88),
                fit: BoxFit.cover,
              ),
              SizedBox(height: ScreenUtil().setWidth(20)),

              // ── 标题 & 版本号 ─────────────────────────────────────────
              Text(
                S.of(context).g_key_v_k1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: ScreenUtil().setSp(28),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(6)),
              Text(
                'V$newVersion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: accentColor,
                  fontSize: ScreenUtil().setSp(40),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(20)),

              // ── 更新日志 ──────────────────────────────────────────────
              if (updateTitle.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    updateTitle,
                    style: TextStyle(
                      color: textColor,
                      fontSize: ScreenUtil().setSp(26),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(6)),
              ],
              if (introduction.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    introduction,
                    style: TextStyle(
                      height: 1.6,
                      fontSize: ScreenUtil().setSp(24),
                      color: subtitleColor,
                    ),
                  ),
                ),
              SizedBox(height: ScreenUtil().setWidth(28)),

              // ── 立即更新按钮 ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: ScreenUtil().setWidth(80),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(40)),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    await _openUpdate(context);
                    if (!_forced && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    S.of(context).g_key_v_k2,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // ── 稍后提醒（非强制更新时显示） ──────────────────────────
              if (!_forced) ...[
                SizedBox(height: ScreenUtil().setWidth(4)),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    S.of(context).g_version_later,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: subtitleColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
