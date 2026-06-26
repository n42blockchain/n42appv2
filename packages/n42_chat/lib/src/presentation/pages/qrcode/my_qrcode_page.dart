import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../domain/entities/avatar_decoration_preset.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../widgets/common/common_widgets.dart';
import '../../../core/utils/debug_log.dart';

enum _QRCodeStyle { n42, classic, ocean, berry }

/// 我的二维码页面
class MyQRCodePage extends StatefulWidget {
  const MyQRCodePage({super.key});

  @override
  State<MyQRCodePage> createState() => _MyQRCodePageState();
}

class _MyQRCodePageState extends State<MyQRCodePage> {
  final GlobalKey _qrKey = GlobalKey();
  String? _userId;
  String? _displayName;
  String? _avatarUrl;
  AvatarDecorationPreset _avatarDecorationPreset = AvatarDecorationPreset.none;
  _QRCodeStyle _qrStyle = _QRCodeStyle.n42;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final authRepository = getIt<IAuthRepository>();
      final currentUser = await authRepository.getCurrentUserProfile();
      if (currentUser != null) {
        if (!mounted) return;
        setState(() {
          _userId = currentUser.userId;
          _displayName = currentUser.displayName;
          _avatarUrl = currentUser.avatarUrl;
          _avatarDecorationPreset = currentUser.avatarDecorationPreset;
        });
        return;
      }

      final clientManager = getIt<MatrixClientManager>();
      final client = clientManager.client;

      if (client != null && client.isLogged()) {
        if (!mounted) return;
        setState(() {
          _userId = client.userID;
          _displayName =
              client.userID?.split(':').first.replaceFirst('@', '') ?? 'User';
        });
      }
    } catch (e) {
      debugLog('Failed to load user info: $e');
    }
  }

  String get _qrData {
    if (_userId == null) return '';
    return 'n42chat://user/$_userId';
  }

  void _copyUserId() {
    if (_userId != null) {
      Clipboard.setData(ClipboardData(text: _userId!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context)?.qrcodeIdCopied ?? 'ID copied'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareQRCode() async {
    try {
      final bytes = await _captureQRImage();
      if (bytes == null) return;

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(bytes, mimeType: 'image/png', name: 'qrcode.png'),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.commonShareFailed('') ?? 'Share failed',
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveQRCode() async {
    try {
      final bytes = await _captureQRImage();
      if (bytes == null) return;

      // 使用 share_plus 保存（跨平台兼容方式，触发系统分享面板）
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(bytes, mimeType: 'image/png', name: 'qrcode.png'),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context)?.commonSaveFailed ?? 'Save failed'),
          ),
        );
      }
    }
  }

  Future<Uint8List?> _captureQRImage() async {
    final boundary =
        _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;

    return byteData.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.background;
    final cardColor = _qrCardColor(isDark);
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.back, color: textColor, size: 20),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          S.of(context)?.commonMyQrCode ?? 'My QR Code',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(AppIcons.more, color: textColor),
            tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Center(
        child: RepaintBoundary(
          key: _qrKey,
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 用户信息
                Row(
                  children: [
                    // 头像
                    N42Avatar(
                      imageUrl: _avatarUrl,
                      name: _displayName ?? 'U',
                      size: 56,
                      decorationPreset: _avatarDecorationPreset,
                    ),
                    const SizedBox(width: 16),
                    // 名字和ID
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayName ??
                                (S.of(context)?.commonLoading ?? 'Loading...'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userId ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.3,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 二维码
                if (_userId != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: _qrData,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: _qrBackgroundColor,
                      eyeStyle: QrEyeStyle(
                        eyeShape: _qrEyeShape,
                        color: _qrEyeColor,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: _qrDataModuleShape,
                        color: _qrDataColor,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 232,
                    height: 232,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),

                const SizedBox(height: 24),

                // 提示文字
                Text(
                  S.of(context)?.qrcodeScanQrToAddMe ??
                      'Scan the QR code above to add me as a friend',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, height: 1.4, color: subtitleColor),
                ),

                const SizedBox(height: 24),

                // 操作按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      icon: Icons.copy,
                      label: S.of(context)?.qrcodeCopyId ?? 'Copy ID',
                      onTap: _copyUserId,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 32),
                    _buildActionButton(
                      icon: Icons.share,
                      label: S.of(context)?.commonShare ?? 'Share',
                      onTap: _shareQRCode,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.3,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: sheetContext.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.save_alt),
                  title: Text(
                    S.of(sheetContext)?.qrcodeSaveToAlbum ?? 'Save to Album',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _saveQRCode();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: Text(
                    S.of(sheetContext)?.qrcodeChangeStyle ?? 'Change Style',
                  ),
                  subtitle: Text(_qrStyleLabel(_qrStyle)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showStylePicker();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _qrCardColor(bool isDark) {
    switch (_qrStyle) {
      case _QRCodeStyle.n42:
        return isDark ? const Color(0xFF2C2C2C) : Colors.white;
      case _QRCodeStyle.classic:
        return isDark ? const Color(0xFF1E1E1E) : Colors.white;
      case _QRCodeStyle.ocean:
        return isDark ? const Color(0xFF112A3A) : const Color(0xFFEAF8FF);
      case _QRCodeStyle.berry:
        return isDark ? const Color(0xFF2A1727) : const Color(0xFFFFF1F7);
    }
  }

  Color get _qrBackgroundColor {
    switch (_qrStyle) {
      case _QRCodeStyle.ocean:
        return const Color(0xFFF4FCFF);
      case _QRCodeStyle.berry:
        return const Color(0xFFFFF8FB);
      case _QRCodeStyle.n42:
      case _QRCodeStyle.classic:
        return Colors.white;
    }
  }

  Color get _qrEyeColor {
    return _qrEyeColorFor(_qrStyle);
  }

  Color _qrEyeColorFor(_QRCodeStyle style) {
    switch (style) {
      case _QRCodeStyle.n42:
        return AppColors.primary;
      case _QRCodeStyle.classic:
        return Colors.black;
      case _QRCodeStyle.ocean:
        return const Color(0xFF0077B6);
      case _QRCodeStyle.berry:
        return const Color(0xFFB5179E);
    }
  }

  Color get _qrDataColor {
    return _qrDataColorFor(_qrStyle);
  }

  Color _qrDataColorFor(_QRCodeStyle style) {
    switch (style) {
      case _QRCodeStyle.n42:
      case _QRCodeStyle.classic:
        return Colors.black;
      case _QRCodeStyle.ocean:
        return const Color(0xFF023047);
      case _QRCodeStyle.berry:
        return const Color(0xFF3C096C);
    }
  }

  QrEyeShape get _qrEyeShape {
    switch (_qrStyle) {
      case _QRCodeStyle.classic:
        return QrEyeShape.square;
      case _QRCodeStyle.n42:
      case _QRCodeStyle.ocean:
      case _QRCodeStyle.berry:
        return QrEyeShape.circle;
    }
  }

  QrDataModuleShape get _qrDataModuleShape {
    switch (_qrStyle) {
      case _QRCodeStyle.classic:
      case _QRCodeStyle.n42:
        return QrDataModuleShape.square;
      case _QRCodeStyle.ocean:
      case _QRCodeStyle.berry:
        return QrDataModuleShape.circle;
    }
  }

  String _qrStyleLabel(_QRCodeStyle style) {
    switch (style) {
      case _QRCodeStyle.n42:
        return 'N42';
      case _QRCodeStyle.classic:
        return 'Classic';
      case _QRCodeStyle.ocean:
        return 'Ocean';
      case _QRCodeStyle.berry:
        return 'Berry';
    }
  }

  void _showStylePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: sheetContext.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                for (final style in _QRCodeStyle.values)
                  ListTile(
                    leading: _QrStylePreview(
                      eyeColor: _qrEyeColorFor(style),
                      dataColor: _qrDataColorFor(style),
                      rounded:
                          style == _QRCodeStyle.ocean ||
                          style == _QRCodeStyle.berry,
                    ),
                    title: Text(_qrStyleLabel(style)),
                    trailing: _qrStyle == style
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      setState(() => _qrStyle = style);
                    },
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QrStylePreview extends StatelessWidget {
  final Color eyeColor;
  final Color dataColor;
  final bool rounded;

  const _QrStylePreview({
    required this.eyeColor,
    required this.dataColor,
    required this.rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: CustomPaint(
        painter: _QrStylePreviewPainter(
          eyeColor: eyeColor,
          dataColor: dataColor,
          rounded: rounded,
        ),
      ),
    );
  }
}

class _QrStylePreviewPainter extends CustomPainter {
  final Color eyeColor;
  final Color dataColor;
  final bool rounded;

  const _QrStylePreviewPainter({
    required this.eyeColor,
    required this.dataColor,
    required this.rounded,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final eyePaint = Paint()..color = eyeColor;
    final dataPaint = Paint()..color = dataColor;
    final radius = rounded ? const Radius.circular(2) : Radius.zero;
    final cell = size.width / 7;

    void drawCell(int x, int y, Paint paint) {
      final rect = Rect.fromLTWH(x * cell, y * cell, cell * 0.82, cell * 0.82);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);
    }

    for (final point in const [
      (0, 0),
      (1, 0),
      (0, 1),
      (1, 1),
      (5, 0),
      (6, 0),
      (5, 1),
      (6, 1),
      (0, 5),
      (1, 5),
      (0, 6),
      (1, 6),
    ]) {
      drawCell(point.$1, point.$2, eyePaint);
    }

    for (final point in const [
      (3, 0),
      (2, 2),
      (4, 2),
      (6, 3),
      (1, 3),
      (3, 3),
      (4, 4),
      (2, 5),
      (5, 5),
      (3, 6),
      (6, 6),
    ]) {
      drawCell(point.$1, point.$2, dataPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _QrStylePreviewPainter oldDelegate) {
    return oldDelegate.eyeColor != eyeColor ||
        oldDelegate.dataColor != dataColor ||
        oldDelegate.rounded != rounded;
  }
}
