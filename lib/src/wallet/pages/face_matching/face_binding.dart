// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'dart:io' as io;
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/face_api.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:permission_handler/permission_handler.dart';

class FaceBinding extends ConsumerStatefulWidget {
  /// type=1 绑定模式（将人脸绑定到钱包地址）
  /// type=2 验证模式（验证已绑定的人脸）
  final int type;
  final String? address;
  final int? walletIndex;

  const FaceBinding(this.type, {this.address, this.walletIndex, super.key});

  @override
  ConsumerState<FaceBinding> createState() => _FaceBindingState();
}

class _FaceBindingState extends ConsumerState<FaceBinding>
    with WidgetsBindingObserver {
  final _faceSdk = FaceSDK.instance;
  Load load = Load.finish;
  bool cameraOK = false;
  var img1 = Image.asset('assets/face/portrait.png');
  String errorMessage = '';
  bool _openedSystemSettings = false;
  bool _isUsingCamera = false;

  // ── SDK 初始化 ────────────────────────────────────────────────────────────
  //
  // 若 assets/regula.license 存在，使用离线许可证初始化（支持离线匹配）。
  // 否则无证书初始化（需要联网激活）。
  Future<bool> initialize() async {
    final license = await _loadAssetIfExists('assets/regula.license');
    InitConfig? config;
    if (license != null) config = InitConfig(license);
    final result = await _faceSdk.initialize(config: config);
    if (!result.$1) {
      if (mounted) {
        setState(() {
          errorMessage = result.$2?.message ?? S.of(context).g_face_sdk_init_failed;
        });
      }
    }
    return result.$1;
  }

  Future<ByteData?> _loadAssetIfExists(String path) async {
    try {
      return await rootBundle.load(path);
    } catch (_) {
      return null;
    }
  }

  // ── 生命周期 ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // FaceSDK 本身会触发 resumed，此时 _isUsingCamera=true 则忽略
      if (_isUsingCamera) return;
      // 只有从系统设置页面返回时才重新检查权限
      if (_openedSystemSettings) {
        _openedSystemSettings = false;
        _initCamera();
      }
    }
  }

  // ── 相机权限 ──────────────────────────────────────────────────────────────

  Future<void> _initCamera() async {
    if (io.Platform.isIOS) {
      final rData = await Trustdart().getPermissions('Camera');
      // "notDetermined" → iOS 在调用相机时会自动弹出授权对话框
      // "authorized"    → 已授权
      // 其他（denied/restricted）→ 需要引导用户去系统设置
      cameraOK = rData == 'notDetermined' || rData == 'authorized';
    } else {
      final status = await Permission.camera.status;
      cameraOK = !(status.isPermanentlyDenied ||
          status.isLimited ||
          status.isDenied);
    }
    if (!mounted) return;
    setState(() {});
    if (cameraOK) _init();
  }

  // ── 核心流程 ──────────────────────────────────────────────────────────────

  Future<void> _init() async {
    // SDK 初始化失败时显示错误提示和重试按钮
    final ok = await initialize();
    if (!ok) return; // errorMessage 已在 initialize() 内 setState
    _useCamera();
  }

  Future<void> _useCamera() async {
    if (_isUsingCamera) return;
    _isUsingCamera = true;
    final response = await _faceSdk.startLiveness();
    _isUsingCamera = false;

    final image = response.image;
    if (!mounted) return;

    if (image != null) {
      setState(() => errorMessage = '');
      _sendToBackend(image);
    } else {
      // image 为 null：用户取消、活体检测未通过或相机采集失败
      setState(() {
        errorMessage = S.of(context).g_face_liveness_failed;
      });
    }
  }

  // ── 后端通信 ──────────────────────────────────────────────────────────────

  Future<void> _sendToBackend(Uint8List img) async {
    if (widget.type == 1) {
      await _bindingFlow(img);
    } else {
      await _matchFlow(img);
    }
  }

  /// 绑定流程（type=1）：将人脸图像与钱包地址关联
  Future<void> _bindingFlow(Uint8List img) async {
    // 确定钱包地址
    String addr;
    if (widget.address != null) {
      addr = widget.address!;
    } else {
      final CoinModel? cm =
          ref.read(wapBridgeProvider).getCoinModelWithCoinType(CoinType.N.name);
      if (cm == null) {
        if (!mounted) return;
        ToastUtils.show(S.of(context).g_face_match_key5);
        Navigator.pop(context);
        return;
      }
      addr = cm.address;
    }

    if (!mounted) return;
    setState(() {
      load = Load.loading;
      img1 = Image.memory(img);
    });

    final MessageModel rmm =
        await FaceApi().binding(addr, img, 'face2.jpg', type: 1);
    if (!mounted) return;

    if (rmm.error) {
      // 网络或服务器错误 → 弹出错误，返回 null（调用方检测 null 表示失败）
      ToastUtils.show(S.of(context).g_face_network_error);
      Navigator.pop(context);
      return;
    }

    final data = rmm.data;
    if (data is! Map) {
      ToastUtils.show(S.of(context).g_face_match_key3);
      Navigator.pop(context);
      return;
    }

    if (data['match'] == true) {
      // 该人脸已绑定到另一个地址
      final mm = MessageModel.error();
      mm.data = S.of(context).g_face_match_key10(data['address'] ?? '');
      Navigator.pop(context, mm);
    } else {
      // 绑定成功
      ref.read(wapBridgeProvider).setWalletFaceBinding(widget.walletIndex);
      if (!mounted) return;
      final mm = MessageModel();
      mm.data = S.of(context).g_face_match_key11(addr);
      Navigator.pop(context, mm);
    }
  }

  /// 验证流程（type=2）：检测人脸并返回匹配的钱包地址
  Future<void> _matchFlow(Uint8List img) async {
    if (!mounted) return;
    setState(() {
      load = Load.loading;
      img1 = Image.memory(img);
    });

    final MessageModel rmm =
        await FaceApi().match(img, 'face2.jpg', type: 1);
    if (!mounted) return;

    if (rmm.error) {
      ToastUtils.show(S.of(context).g_face_network_error);
      Navigator.pop(context); // null → 调用方视为失败
      return;
    }

    final data = rmm.data;
    if (data is! Map) {
      ToastUtils.show(S.of(context).g_face_match_key3);
      Navigator.pop(context); // null
      return;
    }

    if (data['match'] == true) {
      final mm = MessageModel();
      mm.data = data['address'] ?? '';
      Navigator.pop(context, mm);
    } else {
      ToastUtils.show(S.of(context).g_face_match_key3);
      Navigator.pop(context); // null → 调用方检测 null 表示未匹配
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return cameraOK ? _faceWidget() : _cameraPermissionWidget();
  }

  /// 已授权：显示人脸采集 / 加载状态
  Widget _faceWidget() {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                  child: Image(
                    height: ScreenUtil().setWidth(300),
                    width: ScreenUtil().setWidth(300),
                    image: img1.image,
                  ),
                ),
                if (errorMessage.isNotEmpty) ...[
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setWidth(40),
                      horizontal: ScreenUtil().setWidth(30),
                    ),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(16)),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.errorBgColor.name),
                    ),
                    child: Text(
                      errorMessage,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.errorTextColor.name),
                        fontSize: ScreenUtil().setSp(28),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(30)),
                    height: ScreenUtil().setWidth(88),
                    width: double.infinity,
                    child: buttonStyle2(
                      context,
                      () => _init(),
                      S.of(context).g_face_match_key12, // "Retry"
                    ),
                  ),
                ],
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

  /// 未授权相机：提示用户去系统设置开启
  Widget _cameraPermissionWidget() {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_face_match_key6,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(40)),
              child: Text(
                S.of(context).g_key_195,
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
