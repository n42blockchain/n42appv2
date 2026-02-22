// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/pages/face_matching/select_wallet.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

/// 人脸绑定使用须知页。
///
/// key19 / key22 / key24 / key26 / key28 是各节标题（粗体 + 较大字号）。
/// key20/21、key23、key25、key27、key29 是对应的正文说明。
class FaceUserNotice extends StatefulWidget {
  const FaceUserNotice({super.key});

  @override
  State<FaceUserNotice> createState() => _FaceUserNoticeState();
}

class _FaceUserNoticeState extends State<FaceUserNotice> {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBarWidget(
        text: s.g_face_match_key18,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemBgColor.name),
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(16.0)),
                  ),
                  padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                  margin:
                      EdgeInsets.only(bottom: ScreenUtil().setWidth(178)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 页面大标题
                      Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        margin: EdgeInsets.only(
                            bottom: ScreenUtil().setWidth(40.0)),
                        child: _headerText(s.g_face_match_key18,
                            fontSize: ScreenUtil().setSp(36)),
                      ),
                      // 第一节：key19（标题）+ key20 / key21（正文）
                      _sectionHeader(s.g_face_match_key19),
                      SizedBox(height: ScreenUtil().setWidth(12)),
                      _bodyText(s.g_face_match_key20),
                      _bodyText(s.g_face_match_key21),
                      SizedBox(height: ScreenUtil().setWidth(30)),
                      // 第二节：key22（标题）+ key23（正文）
                      _sectionHeader(s.g_face_match_key22),
                      SizedBox(height: ScreenUtil().setWidth(12)),
                      _bodyText(s.g_face_match_key23),
                      SizedBox(height: ScreenUtil().setWidth(30)),
                      // 第三节：key24（标题）+ key25（正文）
                      _sectionHeader(s.g_face_match_key24),
                      SizedBox(height: ScreenUtil().setWidth(12)),
                      _bodyText(s.g_face_match_key25),
                      SizedBox(height: ScreenUtil().setWidth(30)),
                      // 第四节：key26（标题）+ key27（正文）
                      _sectionHeader(s.g_face_match_key26),
                      SizedBox(height: ScreenUtil().setWidth(12)),
                      _bodyText(s.g_face_match_key27),
                      SizedBox(height: ScreenUtil().setWidth(30)),
                      // 第五节：key28（标题）+ key29（正文）
                      _sectionHeader(s.g_face_match_key28),
                      SizedBox(height: ScreenUtil().setWidth(12)),
                      _bodyText(s.g_face_match_key29),
                      SizedBox(height: ScreenUtil().setWidth(30)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: ScreenUtil().setWidth(148),
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                width: double.infinity,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.backGroundColor.name),
                child: buttonStyle2(
                  context,
                  () async {
                    final rData = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SelectWallet()),
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context, rData);
                  },
                  s.g_face_match_key30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 文字样式辅助 ─────────────────────────────────────────────────────────

  /// 章节标题：粗体 + 稍大字号
  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: ScreenUtil().setSp(32),
        fontWeight: FontWeight.bold,
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemTextColor.name),
      ),
    );
  }

  /// 正文：常规字号
  Widget _bodyText(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(8)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemTextColor.name),
        ),
      ),
    );
  }

  /// 页面大标题（仅顶部使用）
  Widget _headerText(String text, {required double fontSize}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemTextColor.name),
      ),
    );
  }
}
