import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/encryption/e2ee_manager.dart';
import '../../../core/encryption/key_backup_service.dart';
import '../../pages/settings/security_settings_page.dart';
import '../../../core/utils/debug_log.dart';

/// 恢复密钥提醒 Banner
///
/// 登录后检测是否已创建恢复密钥（密钥备份）。
/// 若未备份，在首页底部显示提醒 Banner，引导用户立即创建。
///
/// 用法（在页面 body 底部叠加）：
/// ```dart
/// const RecoveryKeyReminderBanner()
/// ```
class RecoveryKeyReminderBanner extends StatefulWidget {
  const RecoveryKeyReminderBanner({
    super.key,
    this.keyBackupService,
    this.initialShouldShow,
  });

  /// 可选依赖注入，为 null 时从 getIt 获取（测试时传入 mock）。
  final KeyBackupService? keyBackupService;

  /// 仅供测试使用：直接指定 banner 显示状态，跳过异步检查。
  @visibleForTesting
  final bool? initialShouldShow;

  @override
  State<RecoveryKeyReminderBanner> createState() =>
      _RecoveryKeyReminderBannerState();
}

class _RecoveryKeyReminderBannerState
    extends State<RecoveryKeyReminderBanner> {
  static const _dismissedKey = 'recovery_key_reminder_dismissed_until';

  bool _shouldShow = false;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialShouldShow != null) {
      // 测试专用：直接使用指定状态，跳过异步检查
      _shouldShow = widget.initialShouldShow!;
      _checked = true;
    } else {
      _checkBackupStatus();
    }
  }

  Future<void> _checkBackupStatus() async {
    // 检查是否在提醒静默期内
    final prefs = await SharedPreferences.getInstance();
    final dismissedUntil = prefs.getInt(_dismissedKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (dismissedUntil > now) {
      if (mounted) setState(() => _checked = true);
      return;
    }

    // 检查密钥备份状态
    try {
      final keyBackupService =
          widget.keyBackupService ?? getIt<KeyBackupService>();
      final backupInfo = await keyBackupService.getBackupInfo();
      if (mounted) {
        setState(() {
          _shouldShow = backupInfo == null;
          _checked = true;
        });
      }
    } catch (e) {
      debugLog('RecoveryKeyReminderBanner: Failed to check backup: $e');
      if (mounted) setState(() => _checked = true);
    }
  }

  Future<void> _dismissFor7Days() async {
    final prefs = await SharedPreferences.getInstance();
    final until = DateTime.now()
        .add(const Duration(days: 7))
        .millisecondsSinceEpoch;
    await prefs.setInt(_dismissedKey, until);
    if (mounted) setState(() => _shouldShow = false);
  }

  void _openSecuritySettings(BuildContext context) {
    final e2eeManager = getIt<E2EEManager>();
    final keyBackupService = getIt<KeyBackupService>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SecuritySettingsPage(
          e2eeManager: e2eeManager,
          keyBackupService: keyBackupService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked || !_shouldShow) return const SizedBox.shrink();

    final l10n = S.of(context);

    return Material(
      elevation: 4,
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n?.recoveryKeyReminderTitle ?? 'Protect your messages',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n?.recoveryKeyReminderDesc ??
                        'Create a recovery key to sync encrypted messages across devices',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _openSecuritySettings(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n?.recoveryKeySetupNow ?? 'Set up',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _dismissFor7Days,
                  child: Text(
                    l10n?.recoveryKeyRemindLater ?? 'Later',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
