// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/hardware_wallet/service/keystone_service.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Keystone 气隙 QR 签名页面
///
/// 两步流程：
/// 1. **请求**阶段：将 `ur:eth-sign-request` QR 码展示给用户，
///    提示用户在 Keystone 设备上扫描。
/// 2. **响应**阶段：打开摄像头扫描 Keystone 返回的 `ur:eth-signature` QR 码，
///    解析出 ECDSA 签名并通过 Navigator.pop 返回给调用方。
///
/// 用法：
/// ```dart
/// final result = await Navigator.push<HardwareWalletSignResponse>(
///   context,
///   MaterialPageRoute(
///     builder: (_) => KeystoneSignPage(
///       rawTxRlp: txBytes,
///       chainId: 1,
///       derivationPath: "m/44'/60'/0'/0/0",
///       fromAddress: '0x...',
///     ),
///   ),
/// );
/// ```
class KeystoneSignPage extends StatefulWidget {
  /// RLP-encoded raw transaction bytes
  final Uint8List rawTxRlp;

  /// EVM chain ID
  final int chainId;

  /// BIP-44 derivation path string
  final String derivationPath;

  /// Sender address (display only, optional)
  final String? fromAddress;

  const KeystoneSignPage({
    super.key,
    required this.rawTxRlp,
    required this.chainId,
    required this.derivationPath,
    this.fromAddress,
  });

  @override
  State<KeystoneSignPage> createState() => _KeystoneSignPageState();
}

enum _SignStep { showRequest, scanResponse }

class _KeystoneSignPageState extends State<KeystoneSignPage> {
  final KeystoneService _keystoneService = KeystoneService();

  _SignStep _step = _SignStep.showRequest;
  late String _requestUr;
  bool _isScanning = false;
  String? _scanError;

  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    _requestUr = _keystoneService.buildEthSignRequest(
      rawTxRlp: widget.rawTxRlp,
      chainId: widget.chainId,
      derivationPath: widget.derivationPath,
      fromAddress: widget.fromAddress,
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _proceedToScan() {
    setState(() {
      _step = _SignStep.scanResponse;
      _scanError = null;
      _isScanning = false;
    });
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  void _onQrDetected(BarcodeCapture capture) {
    if (_isScanning) return;

    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() => _isScanning = true);
    _scannerController?.stop();

    final validationError = _keystoneService.validateScannedUr(raw);
    if (validationError != null) {
      setState(() {
        _scanError = validationError;
        _isScanning = false;
      });
      _scannerController?.start();
      return;
    }

    final response = _keystoneService.parseEthSignature(raw);
    if (!mounted) return;
    Navigator.pop(context, response);
  }

  void _retryScanning() {
    setState(() {
      _scanError = null;
      _isScanning = false;
    });
    _scannerController?.start();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _step == _SignStep.showRequest
              ? s.g_key_hw_keystone_connect_title
              : s.g_key_hw_keystone_scan_response_title,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30),
            fontWeight: FontWeight.bold,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name),
          ),
        ),
        backgroundColor: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.backGroundColor.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainTextColor.name),
        ),
        elevation: 0,
      ),
      backgroundColor: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.backGroundColor.name),
      body: SafeArea(
        child: _step == _SignStep.showRequest
            ? _buildRequestStep(context, s)
            : _buildScanStep(context, s),
      ),
    );
  }

  // ==================== Step 1: show request QR ====================

  Widget _buildRequestStep(BuildContext context, S s) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 说明文字
          _buildInfoCard(
            context,
            icon: Icons.qr_code_scanner,
            message: s.g_key_hw_keystone_scan_request_hint,
          ),
          SizedBox(height: ScreenUtil().setWidth(24)),

          // QR 码
          Expanded(
            child: Center(
              child: _buildQrCode(),
            ),
          ),

          SizedBox(height: ScreenUtil().setWidth(24)),

          // 下一步按钮
          ElevatedButton(
            onPressed: _proceedToScan,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
              foregroundColor: Colors.white,
              padding:
                  EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              ),
            ),
            child: Text(
              s.g_key_hw_keystone_tap_to_scan,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(24)),
        ],
      ),
    );
  }

  Widget _buildQrCode() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: QrImageView(
        data: _requestUr,
        version: QrVersions.auto,
        size: ScreenUtil().setWidth(280),
        backgroundColor: Colors.white,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      ),
    );
  }

  // ==================== Step 2: scan response ====================

  Widget _buildScanStep(BuildContext context, S s) {
    return Column(
      children: [
        // 说明文字
        Padding(
          padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
          child: _buildInfoCard(
            context,
            icon: Icons.camera_alt,
            message: s.g_key_hw_keystone_scan_response_hint,
          ),
        ),

        // 扫描区域
        Expanded(
          child: Stack(
            children: [
              // Camera view
              if (_scannerController != null)
                MobileScanner(
                  controller: _scannerController!,
                  onDetect: _onQrDetected,
                )
              else
                const Center(child: CircularProgressIndicator()),

              // 扫描框遮罩
              _buildScanOverlay(context),

              // 错误提示
              if (_scanError != null)
                Positioned(
                  bottom: ScreenUtil().setWidth(120),
                  left: ScreenUtil().setWidth(30),
                  right: ScreenUtil().setWidth(30),
                  child: _buildScanErrorCard(context, s),
                ),

              // 加载中
              if (_isScanning)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScanOverlay(BuildContext context) {
    final scanBoxSize = ScreenUtil().setWidth(260);
    return CustomPaint(
      painter: _ScanOverlayPainter(
        scanBoxSize: scanBoxSize,
        borderColor: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainBlueColor.name),
      ),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildScanErrorCard(BuildContext context, S s) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withAlpha(230),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _scanError ?? s.g_key_hw_keystone_scan_error,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          GestureDetector(
            onTap: _retryScanning,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(24),
                vertical: ScreenUtil().setWidth(10),
              ),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Text(
                s.g_key_hw_load_more, // reuse retry-style label
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Shared helpers ====================

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String message,
  }) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name),
            size: ScreenUtil().setWidth(36),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Keystone pair page ====================

/// Keystone 配对页面：扫描设备的 xpub/sync QR 码以导入账户
class KeystonePairPage extends StatefulWidget {
  final Function(String xpub, String? fingerprint) onPaired;

  const KeystonePairPage({super.key, required this.onPaired});

  @override
  State<KeystonePairPage> createState() => _KeystonePairPageState();
}

class _KeystonePairPageState extends State<KeystonePairPage> {
  final KeystoneService _keystoneService = KeystoneService();
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;
  String? _error;

  void _onDetected(BarcodeCapture capture) {
    if (_isProcessing) return;

    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() => _isProcessing = true);
    _controller.stop();

    try {
      final info = _keystoneService.parseSyncQr(raw);
      if (mounted) {
        widget.onPaired(info.xpub, info.masterFingerprint);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to parse Keystone QR: $e';
        _isProcessing = false;
      });
      _controller.start();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBarWidget(text: s.g_key_hw_keystone_connect_title),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
              child: Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemBgColor.name),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                      size: ScreenUtil().setWidth(36),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(12)),
                    Expanded(
                      child: Text(
                        s.g_key_hw_keystone_scan_xpub_hint,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(24),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: _onDetected,
                  ),
                  if (_error != null)
                    Positioned(
                      bottom: ScreenUtil().setWidth(40),
                      left: ScreenUtil().setWidth(30),
                      right: ScreenUtil().setWidth(30),
                      child: Container(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                        decoration: BoxDecoration(
                          color: Colors.red.shade900.withAlpha(220),
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().setWidth(12)),
                        ),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(24),
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  if (_isProcessing)
                    const Center(
                        child: CircularProgressIndicator(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Custom painter ====================

class _ScanOverlayPainter extends CustomPainter {
  final double scanBoxSize;
  final Color borderColor;

  _ScanOverlayPainter({required this.scanBoxSize, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final half = scanBoxSize / 2;

    final outerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final innerRect = Rect.fromLTRB(
      centerX - half,
      centerY - half,
      centerX + half,
      centerY + half,
    );

    final path = Path()
      ..addRect(outerRect)
      ..addRect(innerRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Corner brackets
    final bracketPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 24.0;
    final r = innerRect;

    // Top-left
    canvas.drawLine(r.topLeft, r.topLeft.translate(cornerLen, 0), bracketPaint);
    canvas.drawLine(r.topLeft, r.topLeft.translate(0, cornerLen), bracketPaint);
    // Top-right
    canvas.drawLine(
        r.topRight, r.topRight.translate(-cornerLen, 0), bracketPaint);
    canvas.drawLine(
        r.topRight, r.topRight.translate(0, cornerLen), bracketPaint);
    // Bottom-left
    canvas.drawLine(
        r.bottomLeft, r.bottomLeft.translate(cornerLen, 0), bracketPaint);
    canvas.drawLine(
        r.bottomLeft, r.bottomLeft.translate(0, -cornerLen), bracketPaint);
    // Bottom-right
    canvas.drawLine(
        r.bottomRight, r.bottomRight.translate(-cornerLen, 0), bracketPaint);
    canvas.drawLine(
        r.bottomRight, r.bottomRight.translate(0, -cornerLen), bracketPaint);
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter old) =>
      old.scanBoxSize != scanBoxSize || old.borderColor != borderColor;
}
