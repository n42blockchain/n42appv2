import 'dart:io';

import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:n42_wallet/generated/l10n.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool cameraOK = false;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool flash = false;
  bool _hasPopped = false;

  @override
  void initState() {
    super.initState();
    _initCameraPermission();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  Future<void> _initCameraPermission() async {
    if (Platform.isIOS) {
      final rData = await Trustdart().getPermissions("Camera");
      cameraOK = rData.isNotEmpty &&
          (rData == "notDetermined" || rData == "authorized");
    } else {
      final status = await Permission.camera.status;
      cameraOK = !status.isPermanentlyDenied && !status.isLimited;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_4,
        actions: [
          IconButton(
            onPressed: () async {
              await controller?.toggleFlash();
              flash = await controller?.getFlashStatus() ?? false;
              setState(() {});
            },
            icon: Icon(
              flash ? Icons.flash_on : Icons.flash_off,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: cameraOK ? _buildQrView(context) : _buildPermissionDenied(),
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.of(context).g_key_195,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30.0),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(36.0)),
          TextButton(
            onPressed: () async {
              await openAppSettings();
              _initCameraPermission();
            },
            child: Text(
              S.of(context).g_face_5,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: ScreenUtil().setWidth(16),
        borderLength: ScreenUtil().setWidth(30),
        borderWidth: ScreenUtil().setWidth(1),
        cutOutSize: ScreenUtil().setWidth(600),
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);
    controller.scannedDataStream.listen((scanData) {
      if (!_hasPopped) {
        _pop(scanData.code ?? "");
      }
    });
  }

  void _pop(String code) {
    _hasPopped = true;
    controller?.stopCamera();
    Navigator.pop(context, code);
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }
}
