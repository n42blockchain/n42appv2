import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart' show SyncStatus, SyncStatusUpdate;

import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../../l10n/app_localizations.dart';

/// 首次同步进度覆盖层
///
/// 在用户首次登录后、Matrix 客户端完成初始同步前，显示加载动画与进度提示。
/// 同步完成后自动消失（淡出动画）。
class SyncProgressOverlay extends StatefulWidget {
  const SyncProgressOverlay({super.key});

  @override
  State<SyncProgressOverlay> createState() => _SyncProgressOverlayState();
}

class _SyncProgressOverlayState extends State<SyncProgressOverlay>
    with SingleTickerProviderStateMixin {
  bool _isSyncing = false;
  bool _visible = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  StreamSubscription<SyncStatusUpdate>? _syncSub;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _checkSyncState();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _syncSub?.cancel();
    super.dispose();
  }

  void _checkSyncState() {
    final clientManager = MatrixClientManager.instance;
    final onSyncStatus = clientManager.onSyncStatus;
    if (onSyncStatus == null) return;

    // 若 prevBatch 为 null，说明尚未完成首次同步
    final client = clientManager.client;
    if (client != null && client.prevBatch == null) {
      setState(() {
        _isSyncing = true;
        _visible = true;
      });
      _fadeController.value = 1.0;

      _syncSub = onSyncStatus.listen((status) {
        if (!mounted) return;
        if (status.status == SyncStatus.finished && _isSyncing) {
          _hideSyncOverlay();
        }
      });
    }
  }

  void _hideSyncOverlay() {
    setState(() => _isSyncing = false);
    _fadeController.reverse().then((_) {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = S.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: (isDark ? AppColors.backgroundDark : AppColors.background)
            .withValues(alpha: 0.92),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n?.syncInProgress ?? 'Syncing message history...',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
