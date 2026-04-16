import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/encryption/key_backup_service.dart';
import '../../../core/theme/app_colors.dart';

/// 恢复密钥导入对话框
///
/// 提供文本输入和粘贴功能，验证格式后调用 KeyBackupService 恢复。
class RecoveryKeyImportDialog extends StatefulWidget {
  final KeyBackupService keyBackupService;

  const RecoveryKeyImportDialog({super.key, required this.keyBackupService});

  /// 展示恢复密钥导入对话框
  static Future<bool?> show(
    BuildContext context,
    KeyBackupService keyBackupService,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          RecoveryKeyImportDialog(keyBackupService: keyBackupService),
    );
  }

  @override
  State<RecoveryKeyImportDialog> createState() =>
      _RecoveryKeyImportDialogState();
}

class _RecoveryKeyImportDialogState extends State<RecoveryKeyImportDialog> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.key, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text('Import Recovery Key', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 说明文字
            Text(
              'Enter or paste your recovery key to restore encrypted messages from backup.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // 输入框
            TextField(
              controller: _controller,
              maxLines: 4,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                hintText: 'EsTX xxxx xxxx ...',
                hintStyle: TextStyle(
                  fontFamily: 'monospace',
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste, size: 20),
                  tooltip: 'Paste',
                  onPressed: _pasteFromClipboard,
                ),
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),

            // 错误消息
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(fontSize: 12, color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _importKey,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Import'),
        ),
      ],
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    if (data?.text != null && data!.text!.isNotEmpty) {
      _controller.text = data.text!.trim();
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  Future<void> _importKey() async {
    final key = _controller.text.trim();
    if (key.isEmpty) {
      setState(() => _error = 'Please enter a recovery key');
      return;
    }

    // 基本格式验证：恢复密钥通常以 "Es" 开头并由空格分隔的 4 字符块组成
    if (key.length < 20 || !key.startsWith('Es')) {
      setState(() => _error = 'Invalid recovery key format');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final restoredCount = await widget.keyBackupService
          .restoreFromRecoveryKey(key);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restored $restoredCount keys successfully'),
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error =
              'Import failed: ${e.toString().replaceFirst('Exception: ', '')}';
        });
      }
    }
  }
}
