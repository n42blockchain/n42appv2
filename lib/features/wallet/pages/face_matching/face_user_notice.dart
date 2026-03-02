// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/pages/face_matching/select_wallet.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

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
    final sections = [
      (title: s.g_face_match_key19, body: [s.g_face_match_key20, s.g_face_match_key21]),
      (title: s.g_face_match_key22, body: [s.g_face_match_key23]),
      (title: s.g_face_match_key24, body: [s.g_face_match_key25]),
      (title: s.g_face_match_key26, body: [s.g_face_match_key27]),
      (title: s.g_face_match_key28, body: [s.g_face_match_key29]),
    ];
    final textColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemTextColor.name);

    return Scaffold(
      appBar: AppBarWidget(text: s.g_face_match_key18),
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
                  margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(178)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(40.0)),
                        child: Text(
                          s.g_face_match_key18,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(36),
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      for (final section in sections) ...[
                        Text(
                          section.title,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(32),
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: ScreenUtil().setWidth(12)),
                        for (final line in section.body)
                          Padding(
                            padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(8)),
                            child: Text(
                              line,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(28),
                                color: textColor,
                              ),
                            ),
                          ),
                        SizedBox(height: ScreenUtil().setWidth(30)),
                      ],
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
                      MaterialPageRoute(builder: (_) => const SelectWallet()),
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
}
