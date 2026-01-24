import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class QCodeChat extends StatefulWidget {
  final String content;
  const QCodeChat({required this.content, super.key});

  @override
  State<QCodeChat> createState() => _QCodeChatState();
}

class _QCodeChatState extends State<QCodeChat> {
  final GlobalKey previewContainer = GlobalKey();

  Future<void> _shareScreenshot() async {
    try {
      RenderRepaintBoundary boundary =
      previewContainer.currentContext!.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 写入临时文件
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qrcode.png').create();
      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: AppConfig.apiUrl['walletName'],
        ),
      );
    } catch (e) {
      debugPrint("Error sharing screenshot: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                child: Text(
                  S.of(context).g_key_79,
                  style: TextStyle(
                      color: Colors.blueAccent, fontSize: ScreenUtil().setSp(32)),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Text(
              S.of(context).g_chat_key_36,
              style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: 16),
            ),
            const Spacer()
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(30)),
        Divider(
          height: 1,
          indent: 1,
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemLineColor.name),
        ),
        SizedBox(height: ScreenUtil().setWidth(160)),

        /// 截图区域
        RepaintBoundary(
          key: previewContainer,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                      width: 2),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24)),
                ),
                child: SizedBox(
                  width: ScreenUtil().setWidth(400),
                  height: ScreenUtil().setWidth(400),
                  child: QrImageView(
                    backgroundColor: Colors.transparent,
                    data: widget.content,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xff1976F9),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xff1976F9),
                    ),
                  ),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(44)),
              Text(
                AppGlobals.userInfo?.name ?? AppGlobals.userInfo?.email ?? '',
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: ScreenUtil().setWidth(240)),

        /// 按钮：分享图片
        GestureDetector(
          onTap: _shareScreenshot,
          child: Container(
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
            ),
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24)),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.of(context).g_key_share_code,
                    style: TextStyle(
                        color: Colors.white, fontSize: ScreenUtil().setSp(32)),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(20)),
                  Image.asset(
                    "assets/img/qr_code.png",
                    width: ScreenUtil().setWidth(32),
                    fit: BoxFit.cover,
                    color: Colors.white,
                  )
                ],
              ),
            ),
          ),
        ),

        SizedBox(height: ScreenUtil().setWidth(30)),

        /// 按钮：分享链接
        GestureDetector(
          onTap: () {
            SharePlus.instance.share(
              ShareParams(
                text: "${S.of(context).g_chat_key_64} ${AppGlobals.userInfo?.email} \n${AppConfig.apiUrl['walletamazeBrowser']}?type=friendCard&email=${AppGlobals.userInfo?.email}",
                subject: AppConfig.apiUrl['walletName'],
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              border: Border.all(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24)),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.of(context).g_chat_key_11,
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainBlueColor.name),
                        fontSize: ScreenUtil().setSp(32)),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(20)),
                  Image.asset(
                    "assets/img/share_windows.png",
                    width: ScreenUtil().setWidth(32),
                    fit: BoxFit.cover,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
