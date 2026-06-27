import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/social_scan_payload_parser.dart';
import '../../../core/utils/payment_request_uri.dart';
import '../../../domain/repositories/contact_repository.dart';
import '../../../integration/wallet_bridge.dart';
import '../../helpers/mini_app_launcher_helper.dart';
import 'my_qrcode_page.dart';
import '../../../core/utils/debug_log.dart';

/// Scan QR page
class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> with WidgetsBindingObserver {
  MobileScannerController? _scannerController;
  final TextEditingController _inputController = TextEditingController();
  bool _isProcessing = false;
  bool _showManualInput = false;
  bool _hasPermission = false;
  bool _isCheckingPermission = true;
  bool _torchEnabled = false;
  String? _permissionError;

  static final RegExp _positiveAmountRegExp = RegExp(r'^\d+(?:\.\d+)?$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCameraPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Add a small delay to ensure system permission status is updated
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _checkCameraPermission();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController?.dispose();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    if (!mounted) return;
    setState(() {
      _isCheckingPermission = true;
      _permissionError = null;
    });

    try {
      var status = await Permission.camera.status;
      if (!mounted) return;
      debugLog('Camera permission initial status: $status');

      // Handle granted or limited (iOS 14+ limited access is still usable for camera)
      if (status.isGranted || status.isLimited) {
        _initScanner();
        setState(() {
          _hasPermission = true;
          _isCheckingPermission = false;
        });
        return;
      }

      // If denied, try to request permission
      if (status.isDenied) {
        status = await Permission.camera.request();
        if (!mounted) return;
        debugLog('Camera permission after request: $status');

        if (status.isGranted || status.isLimited) {
          _initScanner();
          setState(() {
            _hasPermission = true;
            _isCheckingPermission = false;
          });
          return;
        }
      }

      // Handle permanently denied
      if (status.isPermanentlyDenied) {
        setState(() {
          _hasPermission = false;
          _isCheckingPermission = false;
          _permissionError =
              S.of(context)?.qrcodeCameraPermissionDenied ??
              'Camera permission was permanently denied. Please enable it in system settings.';
        });
        return;
      }

      // Handle restricted (iOS parental controls, etc.)
      if (status.isRestricted) {
        setState(() {
          _hasPermission = false;
          _isCheckingPermission = false;
          _permissionError =
              S.of(context)?.qrcodeCameraPermissionRestricted ??
              'Camera access is restricted on this device.';
        });
        return;
      }

      // Fallback for any other status
      setState(() {
        _hasPermission = false;
        _isCheckingPermission = false;
        _permissionError =
            S.of(context)?.qrcodeCameraPermissionRequired ??
            'Camera permission is required to scan QR code';
      });
    } catch (e) {
      if (!mounted) return;
      debugLog('Camera permission check error: $e');
      setState(() {
        _hasPermission = false;
        _isCheckingPermission = false;
        _permissionError =
            S.of(context)?.qrcodePermissionCheckError(e.toString()) ??
            'Error checking permission: $e';
      });
    }
  }

  void _initScanner() {
    _scannerController?.dispose();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _torchEnabled = false;
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        _processQRCode(rawValue);
        break;
      }
    }
  }

  Future<void> _processQRCode(String data) async {
    if (_isProcessing) return;
    var completedWithExit = false;
    setState(() => _isProcessing = true);

    unawaited(_scannerController?.stop());

    try {
      // 收款二维码（商户收款码）：识别后展示金额确认并发起付款
      final payment = PaymentRequestUri.tryParse(data);
      if (payment != null) {
        completedWithExit = await _handlePaymentUri(payment);
        if (!completedWithExit && mounted) {
          unawaited(_scannerController?.start());
        }
        return;
      }

      final payload = parseSocialScanPayload(data);
      if (payload == null) {
        _showError(S.of(context)?.qrcodeInvalidQrCode ?? 'Invalid QR code');
        unawaited(_scannerController?.start());
        return;
      }

      switch (payload.type) {
        case SocialScanPayloadType.matrixUser:
          completedWithExit = await _startChatWithUser(payload.userId!);
          break;
        case SocialScanPayloadType.miniApp:
          await MiniAppLauncherHelper.openApp<void>(
            context,
            app: payload.miniApp!,
            roomId: '',
            initialUrl: payload.miniAppLaunchUrl,
          );
          if (mounted) {
            unawaited(_scannerController?.start());
          }
          break;
      }
    } catch (e) {
      if (!mounted) return;
      _showError(
        S.of(context)?.qrcodeProcessFailed(e.toString()) ??
            'Failed to process QR code: $e',
      );
      unawaited(_scannerController?.start());
    } finally {
      if (mounted && !completedWithExit) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// 处理扫到的收款二维码：确认金额后通过钱包桥发起付款。
  /// 返回 true 表示已离开扫码页（无需重启扫描）。
  Future<bool> _handlePaymentUri(PaymentRequestData payment) async {
    final amountController = TextEditingController(
      text: payment.hasAmount ? payment.amount.trim() : '',
    );
    String? amountToPay;

    try {
      amountToPay = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: context.surfaceColor,
        builder: (ctx) {
          String? amountError;
          return StatefulBuilder(
            builder: (ctx, setSheetState) {
              final amountLine = payment.hasAmount
                  ? '${payment.amount} ${payment.token}'.trim()
                  : (S.of(ctx)?.transferReceive ?? 'Payment request');
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    top: 20,
                    right: 20,
                    bottom: 20 + MediaQuery.viewInsetsOf(ctx).bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        amountLine,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        payment.receiverAddress,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'monospace',
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (payment.memo != null && payment.memo!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(payment.memo!),
                      ],
                      if (!payment.hasAmount) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: S.of(ctx)?.transferAmount ?? 'Amount',
                            suffixText: payment.token.isNotEmpty
                                ? payment.token
                                : null,
                            errorText: amountError,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(S.of(ctx)?.commonCancel ?? 'Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final amount = payment.hasAmount
                                    ? payment.amount.trim()
                                    : amountController.text.trim();
                                if (!_isPositiveAmount(amount)) {
                                  setSheetState(() {
                                    amountError =
                                        S
                                            .of(ctx)
                                            ?.transferPleaseEnterValidAmount ??
                                        'Please enter a valid amount';
                                  });
                                  return;
                                }
                                Navigator.pop(ctx, amount);
                              },
                              child: Text(S.of(ctx)?.commonConfirm ?? 'Pay'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      amountController.dispose();
    }

    if (amountToPay == null) return false;

    try {
      final result = await getIt<IWalletBridge>().requestTransfer(
        toAddress: payment.receiverAddress,
        amount: amountToPay,
        token: payment.token,
        memo: payment.memo,
      );
      if (!mounted) return true;
      if (result.success) {
        Navigator.of(context).pop();
        return true;
      }
      _showError(result.errorMessage ?? 'Payment failed');
    } catch (e) {
      if (!mounted) return false;
      _showError('Payment failed: $e');
    }
    return false;
  }

  static bool _isPositiveAmount(String amount) {
    final normalized = amount.trim();
    if (!_positiveAmountRegExp.hasMatch(normalized)) return false;
    return normalized.replaceAll('.', '').contains(RegExp(r'[1-9]'));
  }

  Future<bool> _startChatWithUser(String userId) async {
    try {
      final roomId = await getIt<IContactRepository>().startDirectChat(userId);

      if (mounted) {
        Navigator.of(context).pop({'roomId': roomId, 'userId': userId});
        return true;
      }
    } catch (e) {
      if (!mounted) return false;
      _showError(
        S.of(context)?.qrcodeCannotAddFriend(e.toString()) ??
            'Cannot add friend: $e',
      );
      unawaited(_scannerController?.start());
    }
    return false;
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    }
  }

  void _showMyQRCode() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const MyQRCodePage()));
  }

  void _toggleManualInput() {
    setState(() {
      _showManualInput = !_showManualInput;
    });
  }

  void _submitManualInput() {
    final input = _inputController.text.trim();
    if (input.isNotEmpty) {
      _processQRCode(input);
    }
  }

  void _toggleTorch() {
    _scannerController?.toggleTorch();
    setState(() {
      _torchEnabled = !_torchEnabled;
    });
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scanSize = screenSize.width * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          S.of(context)?.qrcodeScanQrCode ?? 'Scan QR Code',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          if (_hasPermission)
            IconButton(
              icon: Icon(
                _torchEnabled ? Icons.flash_on : Icons.flash_off,
                color: _torchEnabled ? Colors.yellow : Colors.white,
              ),
              onPressed: _toggleTorch,
            ),
        ],
      ),
      body: _buildBody(screenSize, scanSize),
    );
  }

  Widget _buildBody(Size screenSize, double scanSize) {
    if (_isCheckingPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context)?.qrcodeCheckingCameraPermission ??
                  'Checking camera permission...',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (!_hasPermission) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white54,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                S.of(context)?.qrcodeNeedCameraPermission ??
                    'Camera Permission Required',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _permissionError ??
                    (S.of(context)?.qrcodeCameraPermissionRequired ??
                        'Camera permission is required to scan QR code'),
                style: const TextStyle(color: Colors.white54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _checkCameraPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      S.of(context)?.qrcodeRetryPermission ?? 'Retry',
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: _openSettings,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      S.of(context)?.qrcodeOpenSettings ?? 'Open Settings',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _toggleManualInput,
                child: Text(
                  _showManualInput
                      ? (S.of(context)?.qrcodeCloseManualInput ??
                            'Close Manual Input')
                      : (S.of(context)?.qrcodeManualInputUserId ??
                            'Manual Input User ID'),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
              if (_showManualInput) _buildManualInputSection(scanSize),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _onDetect,
          errorBuilder: (context, error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context)?.qrcodeCameraStartFailed ??
                        'Camera failed to start',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.errorDetails?.message ??
                        (S.of(context)?.qrcodeUnknownError ?? 'Unknown error'),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
        _buildScanOverlay(screenSize, scanSize),
        Positioned(
          top: (screenSize.height - scanSize) / 2 + scanSize + 16,
          left: 0,
          right: 0,
          bottom: 0,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  S.of(context)?.qrcodePlaceQrCodeInFrame ??
                      'Place QR code within the frame to scan',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _toggleManualInput,
                  child: Text(
                    _showManualInput
                        ? (S.of(context)?.qrcodeCloseManualInput ??
                              'Close Manual Input')
                        : (S.of(context)?.qrcodeManualInputUserId ??
                              'Manual Input User ID'),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (_showManualInput) _buildManualInputSection(scanSize),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBottomButton(
                      icon: Icons.qr_code,
                      label: S.of(context)?.commonMyQrCode ?? 'My QR Code',
                      onTap: _showMyQRCode,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScanOverlay(Size screenSize, double scanSize) {
    final scanRect = Rect.fromCenter(
      center: Offset(screenSize.width / 2, (screenSize.height - 150) / 2),
      width: scanSize,
      height: scanSize,
    );

    return CustomPaint(
      size: screenSize,
      painter: _ScanOverlayPainter(scanRect: scanRect),
      child: Stack(
        children: [
          Positioned(
            left: scanRect.left,
            top: scanRect.top,
            child: _buildCorner(isTop: true, isLeft: true),
          ),
          Positioned(
            right: screenSize.width - scanRect.right,
            top: scanRect.top,
            child: _buildCorner(isTop: true, isLeft: false),
          ),
          Positioned(
            left: scanRect.left,
            top: scanRect.bottom - 24,
            child: _buildCorner(isTop: false, isLeft: true),
          ),
          Positioned(
            right: screenSize.width - scanRect.right,
            top: scanRect.bottom - 24,
            child: _buildCorner(isTop: false, isLeft: false),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: AppColors.primary, width: 3)
              : BorderSide.none,
          bottom: isTop
              ? BorderSide.none
              : const BorderSide(color: AppColors.primary, width: 3),
          left: isLeft
              ? const BorderSide(color: AppColors.primary, width: 3)
              : BorderSide.none,
          right: isLeft
              ? BorderSide.none
              : const BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
    );
  }

  Widget _buildManualInputSection(double scanSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText:
                    S.of(context)?.commonMatrixIdHint ?? '@username:server.com',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isProcessing ? null : _submitManualInput,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(S.of(context)?.commonAdd ?? 'Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Scan overlay painter
class _ScanOverlayPainter extends CustomPainter {
  final Rect scanRect;

  _ScanOverlayPainter({required this.scanRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(12)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
