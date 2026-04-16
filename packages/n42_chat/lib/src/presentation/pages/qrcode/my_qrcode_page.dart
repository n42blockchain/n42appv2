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
import '../../../domain/entities/avatar_decoration_preset.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../widgets/common/common_widgets.dart';
import '../../../core/utils/debug_log.dart';

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
    final bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEDEDED);
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF181818);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF888888);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          S.of(context)?.commonMyQrCode ?? 'My QR Code',
          style: TextStyle(color: textColor, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: textColor),
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userId ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: subtitleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF07C160),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
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
                  style: TextStyle(fontSize: 14, color: subtitleColor),
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
              color: const Color(0xFF07C160).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF07C160), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : const Color(0xFF888888),
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
        final isDark = sheetContext.isDarkMode;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
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
                  onTap: () {
                    Navigator.pop(sheetContext);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            S.of(context)?.qrcodeMoreStylesFeatureComingSoon ??
                                'More styles coming soon',
                          ),
                        ),
                      );
                    }
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
