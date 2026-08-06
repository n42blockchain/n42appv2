// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
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

  /// 动画 QR 帧间隔（Keystone 扫描以 4-5 帧/秒 较稳）
  static const Duration _frameInterval = Duration(milliseconds: 250);

  _SignStep _step = _SignStep.showRequest;
  late String _requestUr;
  late String _currentQrFrame;
  Timer? _frameTimer;
  KeystoneScanSession _scanSession = KeystoneScanSession();
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
    _currentQrFrame = _requestUr;
    // 大额 payload（长 calldata 等）单帧 QR 放不下：fountain 分帧轮播
    final urEncoder = _keystoneService.createUrEncoder(_requestUr);
    if (!urEncoder.isSinglePart) {
      _currentQrFrame = urEncoder.nextPart().toUpperCase();
      _frameTimer = Timer.periodic(_frameInterval, (_) {
        if (!mounted || _step != _SignStep.showRequest) return;
        setState(() => _currentQrFrame = urEncoder.nextPart().toUpperCase());
      });
    }
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _scannerController?.dispose();
    super.dispose();
  }

  void _proceedToScan() {
    setState(() {
      _step = _SignStep.scanResponse;
      _scanError = null;
      _isScanning = false;
      _scanSession = KeystoneScanSession();
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

    final accepted = _scanSession.receive(raw);

    if (_scanSession.isComplete) {
      setState(() => _isScanning = true);
      _scannerController?.stop();

      final completedUr = _scanSession.completedUr;
      // 多帧解码失败（校验和不匹配）或类型不符：报错并允许重扫
      final validationError = completedUr == null
          ? (_scanSession.error ?? 'Failed to decode multi-part QR')
          : _keystoneService.validateScannedUr(completedUr);
      if (validationError != null) {
        setState(() {
          _scanError = validationError;
          _isScanning = false;
          _scanSession = KeystoneScanSession();
        });
        _scannerController?.start();
        return;
      }

      final response = _keystoneService.parseEthSignature(completedUr!);
      if (!mounted) return;
      Navigator.pop(context, response);
      return;
    }

    if (accepted) {
      // 多帧进行中：刷新进度显示，继续扫描
      setState(() => _scanError = null);
    } else if (_scanSession.expectedPartCount == null) {
      // 尚无任何有效帧且此帧无效：提示但不中断相机
      final err = _keystoneService.validateScannedUr(raw);
      if (err != null && err != _scanError) {
        setState(() => _scanError = err);
      }
    }
  }

  void _retryScanning() {
    setState(() {
      _scanError = null;
      _isScanning = false;
      _scanSession = KeystoneScanSession();
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
      padding: EdgeInsets.all(AppSpacing.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _KeystoneInfoCard(
            icon: Icons.qr_code_scanner,
            message: s.g_key_hw_keystone_scan_request_hint,
          ),
          SizedBox(height: AppSpacing.space6),
          Expanded(child: Center(child: _buildQrCode())),
          SizedBox(height: AppSpacing.space6),
          ElevatedButton(
            onPressed: _proceedToScan,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorTokens.of(context).brand,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.space4,
              ),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
            ),
            child: Text(
              s.g_key_hw_keystone_tap_to_scan,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: AppSpacing.space6),
        ],
      ),
    );
  }

  Widget _buildQrCode() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
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
        data: _currentQrFrame,
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
          padding: EdgeInsets.all(AppSpacing.space4),
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
              // 多帧动画 QR 接收进度
              if (_scanSession.expectedPartCount != null && !_isScanning)
                Positioned(
                  top: AppSpacing.space4,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.space4,
                        vertical: AppSpacing.space2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: AppRadius.brMd,
                      ),
                      child: Text(
                        '${_scanSession.receivedPartCount} / '
                        '${_scanSession.expectedPartCount}',
                        style: AppTypography.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
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
