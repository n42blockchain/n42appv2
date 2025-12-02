import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/prompt_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class WalletReceiveQr extends StatefulWidget {
  CoinModel chainCoinModel;
  CoinModel? tokenCoinModel;
  WalletReceiveQr(this.chainCoinModel, {this.tokenCoinModel, super.key});

  @override
  State<WalletReceiveQr> createState() => _WalletReceiveQrState();
}

class _WalletReceiveQrState extends State<WalletReceiveQr> {
  String symbol = "";
  String logoUrl = "";
  String network = "";
  String address = "";
  GlobalKey previewContainer = GlobalKey();

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() {
    network = widget.chainCoinModel.coin['name'];
    logoUrl = widget.chainCoinModel.coin['icon'];
    if (widget.tokenCoinModel == null) {
      symbol = widget.chainCoinModel.coin['miniName'];
      address = widget.chainCoinModel.address;
    } else {
      symbol = widget.tokenCoinModel!.coin['miniName'];
      address = widget.tokenCoinModel!.address;
    }
  }

  /// 截图并分享
  Future<void> _shareScreenshot() async {
    try {
      RenderRepaintBoundary boundary =
      previewContainer.currentContext!.findRenderObject()
      as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file =
      await File('${tempDir.path}/NFTShare.png').create(recursive: true);
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: "image/png")],
        subject: S.of(context).g_key_156,
        text: S.of(context).g_key_179,
      );
    } catch (e) {
      debugPrint("分享失败: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: "${S.of(context).g_key_33}($symbol)",
        actions: [
          InkWell(
            onTap: _shareScreenshot,
            child: Container(
              width: ScreenUtil().setWidth(40.0),
              height: ScreenUtil().setWidth(40.0),
              margin: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(30.0)),
              child: Icon(
                Icons.share,
                size: ScreenUtil().setWidth(40.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RepaintBoundary(
          key: previewContainer,
          child: Container(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.backGroundColor.name),
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ImageNetWork(
                      imageUrl: logoUrl,
                      width: ScreenUtil().setWidth(60.0),
                      height: ScreenUtil().setWidth(60.0),
                      placeholder: "assets/img/list_default.png",
                    ),
                    SizedBox(
                      width: ScreenUtil().setWidth(20),
                    ),
                    Text(
                      network,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(40.0),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: ScreenUtil().setWidth(40.0),
                    right: ScreenUtil().setWidth(40.0),
                    top: ScreenUtil().setWidth(80.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    S.of(context).g_app_share_key_1,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(30.0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setWidth(100.0)),
                  alignment: Alignment.center,
                  child: Text(
                    S.of(context).g_app_share_key_2,
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainBlueColor.name),
                        fontSize: ScreenUtil().setSp(30.0),
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(350.0),
                  height: ScreenUtil().setWidth(350.0),
                  decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainWhiteColor.name),
                      border: Border.all(
                        width: ScreenUtil().setWidth(1.0),
                        color: const Color(0xffe4e4e4),
                      ),
                      borderRadius: BorderRadius.all(
                          Radius.circular(ScreenUtil().setWidth(30.0)))),
                  child: QrImageView(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
                    data: address,
                    version: QrVersions.min + 7,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(100.0),
                    vertical: ScreenUtil().setWidth(30.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    address,
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainBlueColor.name),
                        fontSize: ScreenUtil().setSp(26.0),
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                InkWell(
                  onTap: () {
                    ToastUtils.init(context);
                    Clipboard.setData(ClipboardData(text: address));
                    ToastUtils.showFtToast(
                        child: SuccessViewV1(S.of(context).g_key_119),
                        duration: 3);
                  },
                  child: Container(
                    margin:
                    EdgeInsets.only(left: ScreenUtil().setWidth(10.0)),
                    width: ScreenUtil().setWidth(60.0),
                    height: ScreenUtil().setWidth(60.0),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(10.0)),
                    child: Icon(
                      Icons.copy,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
