// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'keystone_sign_page.dart';

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
  KeystoneScanSession _scanSession = KeystoneScanSession();

  void _onDetected(BarcodeCapture capture) {
    if (_isProcessing) return;

    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    // 明文 xpub 等非 UR 格式：单帧直接解析（会话只认 ur: 前缀）
    final isUr = raw.toLowerCase().trim().startsWith('ur:');
    if (isUr) {
      final accepted = _scanSession.receive(raw);
      if (!_scanSession.isComplete) {
        // 多帧进行中（crypto-account 动画 QR）：刷新进度继续扫
        if (accepted) setState(() => _error = null);
        return;
      }
    }

    setState(() => _isProcessing = true);
    _controller.stop();

    try {
      final source = isUr ? _scanSession.completedUr : raw;
      if (source == null) {
        throw Exception(_scanSession.error ?? 'Failed to decode multi-part QR');
      }
      final info = _keystoneService.parseSyncQr(source);
      if (mounted) {
        widget.onPaired(info.xpub, info.masterFingerprint);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to parse Keystone QR: $e';
        _isProcessing = false;
        _scanSession = KeystoneScanSession();
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
              padding: EdgeInsets.all(AppSpacing.space4),
              child: _KeystoneInfoCard(
                icon: Icons.qr_code_scanner,
                message: s.g_key_hw_keystone_scan_xpub_hint,
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  MobileScanner(controller: _controller, onDetect: _onDetected),
                  // 多帧动画 QR 接收进度
                  if (_scanSession.expectedPartCount != null && !_isProcessing)
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
                  if (_error != null)
                    Positioned(
                      bottom: ScreenUtil().setWidth(40),
                      left: ScreenUtil().setWidth(30),
                      right: ScreenUtil().setWidth(30),
                      child: Container(
                        padding: EdgeInsets.all(AppSpacing.space4),
                        decoration: BoxDecoration(
                          color: AppColorTokens.of(
                            context,
                          ).danger.withAlpha(220),
                          borderRadius: AppRadius.brMd,
                        ),
                        child: Text(
                          _error!,
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  if (_isProcessing)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
