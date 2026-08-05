// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/component/widgets/share_list.dart';
import 'package:n42_wallet/features/widgets/prompt_widget.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

Future<Map<String, dynamic>?> safeShareStatsRequest(
  Future<dynamic> Function() action,
) async {
  try {
    final result = await action();
    if (result is Map<String, dynamic>) {
      return result;
    }
    return null;
  } catch (_) {
    return null;
  }
}

int parseShareStatCount(dynamic value) {
  return int.tryParse('${value ?? ''}') ?? 0;
}

double parseShareStatReward(dynamic value) {
  return double.tryParse('${value ?? ''}') ?? 0;
}

class SettingShare extends StatefulWidget {
  const SettingShare({super.key});

  @override
  State<SettingShare> createState() => _SettingShareState();
}

class _SettingShareState extends State<SettingShare> {
  final GlobalKey previewContainer = GlobalKey();

  String linkStr = "";
  int inviteeTotalDown = 0;
  int inviteeTotal = 0;
  int miningTotal = 0;
  double rewardTotal = 0;
  String? get _uuid => AppGlobals.userInfo?.uuid;

  Color _color(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  @override
  void initState() {
    super.initState();
    linkStr =
        '${AppConfig.apiUrl['n42Browser']!}/download?uuid=${_uuid ?? ""}&code=${AppGlobals.userInfo?.inviteCode ?? ""}';
  }

  /// 截图并分享（内存直接分享）
  Future<void> _shareScreenshot() async {
    try {
      final previewContext = previewContainer.currentContext;
      if (previewContext == null) return;
      final renderObject = previewContext.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) return;
      final image = await renderObject.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      if (box == null) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(pngBytes, name: "invite.png", mimeType: "image/png"),
          ],
          text:
              "${S.of(context).g_share_v3_key_3} ${S.of(context).g_share_v3_key_4} 25 ${S.of(context).g_share_v3_key_5}",
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      AppLogger.w('SettingShare', 'share screenshot failed: $e');
    }
  }

  void _share() {
    sheetBottom(
      context,
      "",
      ShareList(
        callBack: (int shareType) {
          if (shareType == 0) {
            _shareScreenshot();
          } else {
            SharePlus.instance.share(
              ShareParams(
                text:
                    "${S.of(context).g_share_v3_key_3} ${S.of(context).g_share_v3_key_4} 25 ${S.of(context).g_share_v3_key_5} ${S.of(context).g_share_v3_key_7}: $linkStr",
                subject: AppConfig.apiUrl['n42Browser'],
              ),
            );
          }
        },
      ),
    );
  }

  void _copyToClipboard(String text) {
    ToastUtils.init(context);
    Clipboard.setData(ClipboardData(text: text));
    ToastUtils.showFtToast(
      child: successViewV1(S.of(context).copy),
      duration: 3,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: ScreenUtil().setWidth(100.0),
                      alignment: Alignment.center,
                      child: Text(
                        S.of(context).g_share_v3_key_2,
                        style: AppTypography.headline.copyWith(
                          color: _color(AppThemeKeys.mainTextColor),
                        ),
                      ),
                    ),
                    _buildStatsRow(context),
                    _buildShareContent(),
                    SizedBox(height: ScreenUtil().setWidth(148.0)),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 0,
              height: ScreenUtil().setWidth(100.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                color: _color(AppThemeKeys.mainTextColor),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Divider(height: ScreenUtil().setWidth(1)),
                  Container(
                    padding: EdgeInsets.all(AppSpacing.space8),
                    height: ScreenUtil().setWidth(148.0),
                    child: AppButton(
                      label: S.of(context).g_share_v2_key_5,
                      onPressed: _share,
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

  Widget _buildStatsRow(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space6,
      ),
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.space6,
        horizontal: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.brMd,
        color: _color(AppThemeKeys.itemBgColor),
      ),
      child: Row(
        children: [
          _buildStatsCell(
            context,
            S.of(context).g_referral_invited,
            inviteeTotal.toString(),
          ),
          _buildStatsCell(
            context,
            S.of(context).g_referral_downloaded,
            inviteeTotalDown.toString(),
          ),
          _buildStatsCell(
            context,
            S.of(context).g_referral_mining,
            miningTotal.toString(),
          ),
          _buildStatsCell(
            context,
            S.of(context).g_referral_reward,
            rewardTotal.toStringAsFixed(2),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCell(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.headline.copyWith(
              color: _color(AppThemeKeys.mainTextColor),
            ),
          ),
          SizedBox(height: AppSpacing.space2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.captionSm.copyWith(
              color: _color(AppThemeKeys.itemSubtitleTextColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableRow(String label, String value) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
      padding: EdgeInsets.all(AppSpacing.space8),
      decoration: BoxDecoration(
        borderRadius: AppRadius.brMd,
        color: _color(AppThemeKeys.itemBgColor),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: AppColorTokens.of(context).textItem,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.bodySm.copyWith(
                color: _color(AppThemeKeys.itemTextColor),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.space4),
          InkWell(
            onTap: () => _copyToClipboard(value),
            child: Icon(
              Icons.copy,
              color: _color(AppThemeKeys.mainBlueColor),
              size: ScreenUtil().setWidth(32.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareContent() {
    return RepaintBoundary(
      key: previewContainer,
      child: Container(
        color: _color(AppThemeKeys.backGroundColor),
        child: Column(
          children: [
            SizedBox(height: AppSpacing.space8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/img/ast.png",
                  width: ScreenUtil().setWidth(60),
                  height: ScreenUtil().setWidth(60),
                ),
                SizedBox(width: AppSpacing.space6),
                Text(
                  AppConfig.apiUrl['n42Browser'],
                  style: AppTypography.body.copyWith(
                    color: _color(AppThemeKeys.mainTextColor),
                  ),
                ),
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(
                horizontal: AppSpacing.space8,
                vertical: AppSpacing.space8,
              ),
              child: Text(
                S.of(context).g_share_v3_key_6,
                style: AppTypography.headline.copyWith(
                  color: _color(AppThemeKeys.mainTextColor),
                ),
              ),
            ),
            _buildCopyableRow(S.of(context).g_share_v3_key_7, linkStr),
            SizedBox(height: AppSpacing.space8),
            _buildCopyableRow(
              S.of(context).g_share_v3_key_8,
              AppGlobals.userInfo?.inviteCode ?? "",
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.space16),
              alignment: Alignment.center,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(color: _color(AppThemeKeys.itemLineColor)),
                  borderRadius: BorderRadius.circular(AppRadius.sheet),
                  color: _color(AppThemeKeys.mainWhiteColor),
                ),
                clipBehavior: Clip.hardEdge,
                child: QrImageView(
                  padding: const EdgeInsets.all(20.0),
                  backgroundColor: Colors.white,
                  data: linkStr,
                  version: QrVersions.min + 7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
