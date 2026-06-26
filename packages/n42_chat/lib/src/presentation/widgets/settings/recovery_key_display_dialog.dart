import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';

/// 恢复密钥展示对话框
///
/// 以等宽字体显示恢复密钥，提供"复制"和"保存到文件"功能。
/// 顶部显示安全警告横幅。
class RecoveryKeyDisplayDialog extends StatelessWidget {
  final String recoveryKey;

  const RecoveryKeyDisplayDialog({
    super.key,
    required this.recoveryKey,
  });

  /// 展示恢复密钥对话框
  static Future<void> show(BuildContext context, String recoveryKey) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RecoveryKeyDisplayDialog(recoveryKey: recoveryKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.key, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Recovery Key',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 安全警告横幅
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Store this key safely. It is the only way to recover your encrypted messages if you lose access to all devices.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.orange[200] : Colors.orange[800],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 恢复密钥展示区
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.dividerColor,
                ),
              ),
              child: SelectableText(
                recoveryKey,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  height: 1.6,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyToClipboard(context),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _saveToFile(context),
                    icon: const Icon(Icons.save_alt, size: 18),
                    label: const Text('Save'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.commonDone ?? 'Done'),
        ),
      ],
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: recoveryKey));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recovery key copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveToFile(BuildContext context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/n42_recovery_key.txt');
      await file.writeAsString(
        'N42 Chat Recovery Key\n'
        '=====================\n\n'
        '$recoveryKey\n\n'
        'Generated: ${DateTime.now().toIso8601String()}\n'
        'WARNING: Keep this file in a safe place.\n',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved: ${file.path}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
