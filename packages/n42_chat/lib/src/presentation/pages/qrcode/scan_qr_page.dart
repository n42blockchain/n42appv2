import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
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
  final bool returnRawValue;
  const ScanQRPage({super.key, this.returnRawValue = false});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> with WidgetsBindingObserver {
  MobileScannerController? _scannerController;
  final TextEditingController _inputController = TextEditingController();
  bool _isProcessing = false;
  bool _isPickingImage = false;
  bool _showManualInput = false;
  bool _hasPermission = false;
  bool _isCheckingPermission = true;
  bool _torchEnabled = false;
  String? _permissionError;
  String? _scanError;
  bool _permissionCheckInFlight = false;
  Timer? _resumeTimer;
  Future<void> _cameraLifecycle = Future<void>.value();

  static final RegExp _positiveAmountRegExp = RegExp(r'^\d+(?:\.\d+)?$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCameraPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumeTimer?.cancel();
    if (state == AppLifecycleState.resumed) {
      // A permission dialog also resumes the app. Never request permission
      // again in response to that event, or replace the screen with a spinner.
      _resumeTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) _checkCameraPermission(requestIfDenied: false);
      });
    } else {
      unawaited(_setCameraRunning(false));
    }
  }

  Future<void> _setCameraRunning(bool running) {
    _cameraLifecycle = _cameraLifecycle.then((_) async {
      final controller = _scannerController;
      if (!mounted || controller == null || !controller.value.isInitialized) {
        return;
      }
      try {
        if (running) {
          if (!_hasPermission ||
              _isProcessing ||
              _isPickingImage ||
              WidgetsBinding.instance.lifecycleState !=
                  AppLifecycleState.resumed ||
              ModalRoute.of(context)?.isCurrent == false) {
            return;
          }
          await controller.start();
        } else {
          await controller.stop();
        }
      } catch (e) {
        debugLog('Camera lifecycle update failed: $e');
      }
    });
    return _cameraLifecycle;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resumeTimer?.cancel();
    _scannerController?.dispose();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission({bool requestIfDenied = true}) async {
    if (!mounted || _permissionCheckInFlight) return;
    _permissionCheckInFlight = true;
    if (requestIfDenied) {
      setState(() {
        _isCheckingPermission = true;
        _permissionError = null;
      });
    }

    try {
      var status = await Permission.camera.status;
      if (!mounted) return;
      if (status.isDenied && requestIfDenied) {
        status = await Permission.camera.request();
        if (!mounted) return;
      }

      final granted = status.isGranted || status.isLimited;
      if (granted) {
        // MobileScanner retains its original controller for its entire life.
        // Replacing it on resume leaves the preview attached to a disposed one.
        _scannerController ??= MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
          torchEnabled: false,
        );
      } else {
        await _setCameraRunning(false);
        if (!mounted) return;
      }
      setState(() {
        _hasPermission = granted;
        _isCheckingPermission = false;
        _permissionError = granted
            ? null
            : status.isPermanentlyDenied
            ? (S.of(context)?.qrcodeCameraPermissionDenied ??
                  'Camera permission was permanently denied. Please enable it in system settings.')
            : status.isRestricted
            ? (S.of(context)?.qrcodeCameraPermissionRestricted ??
                  'Camera access is restricted on this device.')
            : (S.of(context)?.qrcodeCameraPermissionRequired ??
                  'Camera permission is required to scan QR code');
      });
      if (granted) await _setCameraRunning(true);
    } catch (e) {
      if (!mounted) return;
      debugLog('Camera permission check error: $e');
      setState(() {
        _isCheckingPermission = false;
        _permissionError =
            S.of(context)?.qrcodePermissionCheckError(e.toString()) ??
            'Error checking permission: $e';
      });
    } finally {
      _permissionCheckInFlight = false;
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || _isPickingImage) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        _processQRCode(rawValue);
        break;
      }
    }
  }

  Future<void> _pickQrImage() async {
    if (_isProcessing || _isPickingImage) return;
    setState(() => _isPickingImage = true);
    await _setCameraRunning(false);
    try {
      if (!mounted) return;
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (!mounted || image == null) return;
      // Image analysis does not require camera permission or a running preview.
      final capture = await MobileScannerPlatform.instance.analyzeImage(
        image.path,
        formats: const [BarcodeFormat.qrCode],
      );
      if (!mounted) return;
      final values = capture?.barcodes
          .map((barcode) => barcode.rawValue)
          .whereType<String>()
          .where((value) => value.trim().isNotEmpty);
      if (values == null || values.isEmpty) {
        _showError(S.of(context)?.qrcodeInvalidQrCode ?? 'Invalid QR code');
        return;
      }
      await _processQRCode(values.first, fromGallery: true);
    } catch (e) {
      if (!mounted) return;
      _showError(
        S.of(context)?.commonSelectImageFailed(e.toString()) ??
            'Failed to select image: $e',
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
        await _setCameraRunning(true);
      }
    }
  }

  Future<void> _processQRCode(String data, {bool fromGallery = false}) async {
    if (_isProcessing || (_isPickingImage && !fromGallery)) return;
    var completedWithExit = false;
    setState(() {
      _isProcessing = true;
      _scanError = null;
    });

    await _setCameraRunning(false);

    try {
      if (!mounted) return;
      if (widget.returnRawValue) {
        completedWithExit = true;
        Navigator.of(context).pop(data.trim());
        return;
      }
      // 收款二维码（商户收款码）：识别后展示金额确认并发起付款
      final payment = PaymentRequestUri.tryParse(data);
      if (payment != null) {
        completedWithExit = await _handlePaymentUri(payment);
        return;
      }

      final payload = parseSocialScanPayload(data);
      if (payload == null) {
        _showError(S.of(context)?.qrcodeInvalidQrCode ?? 'Invalid QR code');
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
          break;
      }
    } catch (e) {
      if (!mounted) return;
      _showError(
        S.of(context)?.qrcodeProcessFailed(e.toString()) ??
            'Failed to process QR code: $e',
      );
    } finally {
      if (mounted && !completedWithExit) {
        setState(() => _isProcessing = false);
        await _setCameraRunning(true);
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
    }
    return false;
  }

  void _showError(String message) {
    if (mounted) {
      setState(() => _scanError = message);
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
          TextButton(
            key: const ValueKey('scan_gallery_button'),
            onPressed: _isCheckingPermission || _isProcessing || _isPickingImage
                ? null
                : _pickQrImage,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white38,
            ),
            child: Text(S.of(context)?.qrcodeAlbum ?? 'Album'),
          ),
          if (_hasPermission)
            IconButton(
              icon: Icon(
                _torchEnabled ? Icons.flash_on : Icons.flash_off,
                color: _torchEnabled ? Colors.yellow : Colors.white,
              ),
              onPressed: _isProcessing || _isPickingImage ? null : _toggleTorch,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_scanError != null)
            Semantics(
              liveRegion: true,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.black,
                child: Text(
                  _scanError!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          Expanded(child: _buildBody(screenSize, scanSize)),
        ],
      ),
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
        child: SingleChildScrollView(
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
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 12,
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
        if (_isProcessing || _isPickingImage)
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
            onPressed: _isProcessing || _isPickingImage
                ? null
                : _submitManualInput,
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
