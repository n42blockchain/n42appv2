import 'dart:io';

import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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
      cameraOK =
          rData.isNotEmpty &&
          (rData == "notDetermined" || rData == "authorized");
    } else {
      final status = await Permission.camera.status;
      cameraOK = !status.isPermanentlyDenied && !status.isLimited;
    }
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('scan_page'),
      appBar: AppBarWidget(
        text: S.of(context).g_key_4,
        actions: [
          IconButton(
            onPressed: () async {
              await controller?.toggleFlash();
              if (!mounted) return;
              flash = await controller?.getFlashStatus() ?? false;
              if (!mounted) return;
              setState(() {});
            },
            icon: Icon(
              flash ? Icons.flash_on : Icons.flash_off,
              color: AppColorTokens.of(context).brand,
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
            style: AppTypography.body.copyWith(
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(36.0)),
          TextButton(
            onPressed: () async {
              await openAppSettings();
              if (!mounted) return;
              _initCameraPermission();
            },
            child: Text(
              S.of(context).g_face_5,
              style: AppTypography.headline.copyWith(
                color: AppColorTokens.of(context).brand,
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
        borderColor: AppColorTokens.of(context).brand,
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
        SnackBar(content: Text(S.of(context).g_ui_camera_permission)),
      );
    }
  }
}
