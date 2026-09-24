import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:n42_wallet/generated/l10n.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _cameraAllowed = false;
  bool _checkingPermission = true;
  bool _hasPopped = false;
  bool _permissionCheckInFlight = false;
  Future<void> _cameraLifecycle = Future<void>.value();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCameraPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_checkCameraPermission(requestIfDenied: false));
    } else {
      unawaited(_setCameraRunning(false));
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    unawaited(_setCameraRunning(false).then((_) => _setCameraRunning(true)));
  }

  Future<void> _checkCameraPermission({bool requestIfDenied = true}) async {
    if (!mounted || _permissionCheckInFlight) return;
    _permissionCheckInFlight = true;
    if (requestIfDenied) {
      setState(() => _checkingPermission = true);
    }

    try {
      var status = await Permission.camera.status;
      if (status.isDenied && requestIfDenied) {
        status = await Permission.camera.request();
      }
      if (!mounted) return;

      final allowed = status.isGranted;
      if (allowed) {
        _controller ??= MobileScannerController(
          autoStart: false,
          detectionSpeed: DetectionSpeed.noDuplicates,
          facing: CameraFacing.back,
          formats: const [BarcodeFormat.qrCode],
          torchEnabled: false,
        );
      }
      setState(() {
        _cameraAllowed = allowed;
        _checkingPermission = false;
      });

      if (allowed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_setCameraRunning(true));
        });
      } else {
        await _setCameraRunning(false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cameraAllowed = false;
        _checkingPermission = false;
      });
      await _setCameraRunning(false);
    } finally {
      _permissionCheckInFlight = false;
    }
  }

  Future<void> _setCameraRunning(bool running) {
    final controller = _controller;
    _cameraLifecycle = _cameraLifecycle.then((_) async {
      if (!mounted || controller == null) return;
      try {
        if (running) {
          if (!_cameraAllowed ||
              _hasPopped ||
              WidgetsBinding.instance.lifecycleState !=
                  AppLifecycleState.resumed ||
              ModalRoute.of(context)?.isCurrent == false) {
            return;
          }
          if (!controller.value.isRunning && !controller.value.isStarting) {
            await controller.start();
          }
        } else if (controller.value.isRunning) {
          await controller.stop();
        }
      } catch (_) {
        // Permission state and camera availability are reported by the view;
        // lifecycle transitions must not leave an unhandled async error.
      }
    });
    return _cameraLifecycle;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      unawaited(
        _cameraLifecycle.then((_) async {
          try {
            if (controller.value.isRunning) await controller.stop();
            await controller.dispose();
          } catch (_) {
            // Disposal should finish even if the platform camera closed first.
          }
        }),
      );
    }
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasPopped) return;
    String? result;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.trim().isNotEmpty) {
        result = value;
        break;
      }
    }
    if (result == null) return;

    _hasPopped = true;
    unawaited(_returnResult(result));
  }

  Future<void> _returnResult(String result) async {
    await _setCameraRunning(false);
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isRunning) return;
    try {
      await controller.toggleTorch();
    } catch (_) {
      // Torch availability varies by device and camera.
    }
  }

  Future<void> _openSettings() async {
    await openAppSettings();
    if (mounted) await _checkCameraPermission(requestIfDenied: false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      key: const ValueKey<String>('scan_page'),
      appBar: AppBarWidget(
        text: S.of(context).g_key_4,
        actions: [
          if (_cameraAllowed && controller != null)
            ValueListenableBuilder<MobileScannerState>(
              valueListenable: controller,
              builder: (context, state, _) {
                final enabled = state.torchState == TorchState.on;
                return IconButton(
                  key: const ValueKey('scan_flash_button'),
                  onPressed:
                      state.isRunning &&
                          state.torchState != TorchState.unavailable
                      ? _toggleFlash
                      : null,
                  icon: Icon(
                    enabled ? Icons.flash_on : Icons.flash_off,
                    color: AppColorTokens.of(context).brand,
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: _checkingPermission
            ? const Center(child: CircularProgressIndicator())
            : _cameraAllowed && controller != null
            ? _buildScanner(controller)
            : _buildPermissionDenied(),
      ),
    );
  }

  Widget _buildScanner(MobileScannerController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * 0.8;
        final height = constraints.maxHeight * 0.55;
        final size = width < height ? width : height;
        return Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: controller,
              onDetect: _onDetect,
              useAppLifecycleState: false,
            ),
            IgnorePointer(
              child: Center(
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColorTokens.of(context).brand,
                      width: ScreenUtil().setWidth(2),
                    ),
                    borderRadius: BorderRadius.circular(
                      ScreenUtil().setWidth(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
          SizedBox(height: ScreenUtil().setWidth(24)),
          TextButton(
            onPressed: _checkCameraPermission,
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: _openSettings,
            child: Text(S.of(context).g_face_5),
          ),
        ],
      ),
    );
  }
}
