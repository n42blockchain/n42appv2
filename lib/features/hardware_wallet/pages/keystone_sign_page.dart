// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/hardware_wallet/service/keystone_service.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

part 'keystone_pair_page.dart';
part 'keystone_scan_overlay.dart';

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
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColorTokens.of(context).textPrimary,
          ),
        ),
        backgroundColor: AppColorTokens.of(context).bgBase,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: AppColorTokens.of(context).textPrimary,
        ),
        elevation: 0,
      ),
      backgroundColor: AppColorTokens.of(context).bgBase,
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
          _KeystoneInfoCard(
            icon: Icons.qr_code_scanner,
            message: s.g_key_hw_keystone_scan_request_hint,
          ),
          SizedBox(height: ScreenUtil().setWidth(24)),
          Expanded(child: Center(child: _buildQrCode())),
          SizedBox(height: ScreenUtil().setWidth(24)),
          ElevatedButton(
            onPressed: _proceedToScan,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorTokens.of(context).brand,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setWidth(20),
              ),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
            ),
            child: Text(
              s.g_key_hw_keystone_tap_to_scan,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
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
        borderRadius: AppRadius.brMd,
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
        Padding(
          padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
          child: _KeystoneInfoCard(
            icon: Icons.camera_alt,
            message: s.g_key_hw_keystone_scan_response_hint,
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              if (_scannerController != null)
                MobileScanner(
                  controller: _scannerController!,
                  onDetect: _onQrDetected,
                )
              else
                const Center(child: CircularProgressIndicator()),
              _ScanOverlayPainter.buildOverlay(context),
              if (_scanError != null)
                Positioned(
                  bottom: ScreenUtil().setWidth(120),
                  left: ScreenUtil().setWidth(30),
                  right: ScreenUtil().setWidth(30),
                  child: _KeystoneScanErrorCard(
                    error: _scanError!,
                    onRetry: _retryScanning,
                  ),
                ),
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
}
