// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'dart:io';
import 'package:n42_wallet/features/component/pages/image_crop_page.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/face_api.dart';
import 'package:n42_wallet/features/wallet/models/image_upload_model.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart' as i_picker;
import 'package:permission_handler/permission_handler.dart';

/// 人脸匹配页（图片来源：相册 matchType=1 / 相机 matchType=2）
///
/// 成功时通过 Navigator.pop(context, address) 返回匹配到的钱包地址（String）。
/// 失败或取消时 Navigator.pop(context) 返回 null，调用方检测 null 即为失败。
class FaceMatch extends StatefulWidget {
  final int matchType; // 1=相册  2=相机
  const FaceMatch(this.matchType, {super.key});

  @override
  State<FaceMatch> createState() => _FaceMatchState();
}

class _FaceMatchState extends State<FaceMatch> with WidgetsBindingObserver {
  Load load = Load.finish;
  var img2 = Image.asset('assets/face/portrait.png');
  ImageUploadModel createModel = ImageUploadModel();
  bool photoOK = false;
  bool cameraOK = false;
  bool _openedSystemSettings = false;

  // 是否有可提交的图片（裁剪完毕）
  bool get _hasImage => createModel.imgMini != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _openedSystemSettings) {
      _openedSystemSettings = false;
      _initPermissions();
    }
  }

  void _initPermissions() {
    final bool isPhoto = widget.matchType == 1;
    _checkPermission(
      isPhoto ? 'Photo' : 'Camera',
      isPhoto ? Permission.photos : Permission.camera,
      (ok) {
        if (isPhoto) {
          photoOK = ok;
        } else {
          cameraOK = ok;
        }
      },
    );
  }

  Future<void> _checkPermission(
    String iosKey,
    Permission androidPerm,
    void Function(bool) setter,
  ) async {
    if (Platform.isIOS) {
      final rData = await Trustdart().getPermissions(iosKey);
      setter(rData == 'notDetermined' || rData == 'authorized');
    } else {
      final status = await androidPerm.status;
      setter(!(status.isPermanentlyDenied ||
          status.isLimited ||
          status.isDenied));
    }
    if (!mounted) return;
    setState(() {});
    final bool ok = widget.matchType == 1 ? photoOK : cameraOK;
    if (ok) _selectImage();
  }

  void _selectImage() {
    final source = widget.matchType == 1
        ? i_picker.ImageSource.gallery
        : i_picker.ImageSource.camera;
    _pickImage(source);
  }

  Future<void> _pickImage(i_picker.ImageSource source) async {
    try {
      final img = await i_picker.ImagePicker().pickImage(source: source);
      if (img == null) return;

      if (source == i_picker.ImageSource.gallery) {
        if (createModel.imageFile?.path == img.path) return;
        final imgType = _getImageType(img.path);
        if (imgType?.toLowerCase() == 'gif') return;
        createModel
          ..imgCount = 0
          ..imgMini = null;
      }

      createModel
        ..imgType = _getImageType(img.path)
        ..imageFile = img
        ..imgFile = File(img.path)
        ..imgTotal = await img.length() * 1.0;
      if (!mounted) return;
      setState(() {});
      _imageCrop();
    } on PlatformException {
      // Permission denied on some Android devices
    } catch (e) {
      if (!mounted) return;
      ToastUtils.show(S.of(context).g_face_match_key3);
    }
  }

  Future<void> _imageCrop() async {
    final imageData = createModel.imgFile!.readAsBytesSync();
    final Uint8List? cropped = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(builder: (_) => ImageCropPage(imageData)),
    );
    if (!mounted) return;
    if (cropped != null) {
      setState(() {
        createModel.imgMini = cropped;
        img2 = Image.memory(cropped);
      });
    }
  }

  String? _getImageType(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1) return null;
    return path.substring(dotIndex + 1);
  }

  Future<void> _match() async {
    if (load == Load.loading) return;
    if (!_hasImage) return;

    setState(() => load = Load.loading);
    final MessageModel rmm =
        await FaceApi().match(createModel.imgMini!, 'face2.jpg', type: 1);
    if (!mounted) return;
    setState(() => load = Load.finish);

    if (rmm.error) {
      ToastUtils.show(S.of(context).g_face_network_error);
      Navigator.pop(context); // null → 失败
      return;
    }

    final data = rmm.data;
    if (data is! Map) {
      ToastUtils.show(S.of(context).g_face_match_key3);
      Navigator.pop(context); // null
      return;
    }

    if (data['match'] == true) {
      final String address = (data['address'] ?? '').toString();
      Navigator.pop(context, address); // 成功：返回地址字符串
    } else {
      ToastUtils.show(S.of(context).g_face_match_key3);
      Navigator.pop(context); // null → 未匹配
    }
  }

  @override
  Widget build(BuildContext context) {
    // 相册权限未授权
    if (widget.matchType == 1 && !photoOK) {
      return _permissionWidget(
        title: S.of(context).g_face_match_key7,
        message: S.of(context).g_key_205,
      );
    }
    // 相机权限未授权
    if (widget.matchType == 2 && !cameraOK) {
      return _permissionWidget(
        title: S.of(context).g_face_match_key6,
        message: S.of(context).g_key_195,
      );
    }
    return _mainWidget();
  }

  Widget _mainWidget() {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_face_match_key7),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 预览图
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(40)),
                  child: Image(
                    height: ScreenUtil().setWidth(300),
                    width: ScreenUtil().setWidth(300),
                    image: img2.image,
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(40)),
                // 重新选择
                SizedBox(
                  width: ScreenUtil().setWidth(300),
                  height: ScreenUtil().setWidth(88),
                  child: buttonStyle2(
                    context,
                    () {
                      if (load == Load.loading) return;
                      _selectImage();
                    },
                    S.of(context).g_face_match_key8,
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(20)),
                // 匹配按钮：无图片时置灰禁用（onTap=null → Flutter 自动禁用）
                SizedBox(
                  width: ScreenUtil().setWidth(300),
                  height: ScreenUtil().setWidth(88),
                  child: buttonStyle2(
                    context,
                    _hasImage ? _match : null,
                    S.of(context).g_face_match_key9,
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Visibility(
              visible: load == Load.loading,
              child: LoadingPage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionWidget({
    required String title,
    required String message,
  }) {
    return Scaffold(
      appBar: AppBarWidget(text: title),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(36)),
            TextButton(
              onPressed: () async {
                if (!_openedSystemSettings) {
                  _openedSystemSettings = true;
                  await openAppSettings();
                }
              },
              child: Text(
                S.of(context).g_face_5,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
