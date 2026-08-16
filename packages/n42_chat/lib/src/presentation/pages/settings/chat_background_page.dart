import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/a11y_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/chat_background_presets.dart';
import '../../../core/utils/debug_log.dart';
import '../../../data/datasources/local/preferences_datasource.dart';

/// 聊天背景设置页
class ChatBackgroundPage extends StatefulWidget {
  final String? roomId;

  const ChatBackgroundPage({super.key, this.roomId});

  @override
  State<ChatBackgroundPage> createState() => _ChatBackgroundPageState();
}

class _ChatBackgroundPageState extends State<ChatBackgroundPage> {
  final PreferencesDataSource _storage =
      GetIt.instance<PreferencesDataSource>();
  String? _selectedBackground;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentBackground();
  }

  Future<void> _loadCurrentBackground() async {
    final bg = widget.roomId != null
        ? await _storage.getChatBackground(widget.roomId!)
        : await _storage.getDefaultChatBackground();
    if (mounted) {
      setState(() => _selectedBackground = bg);
    }
  }

  Future<void> _selectBackground(String value) async {
    final isDefaultSelection =
        value == 'default' &&
        (_selectedBackground == null || _selectedBackground == 'default');
    if (_isSaving || isDefaultSelection || value == _selectedBackground) {
      return;
    }

    final previousBackground = _selectedBackground;
    final messenger = ScaffoldMessenger.of(context);
    final saveFailedMessage = S.of(context)?.commonSaveFailed ?? 'Save failed';

    setState(() {
      _isSaving = true;
      _selectedBackground = value;
    });

    try {
      if (widget.roomId != null) {
        await _storage.setChatBackground(widget.roomId!, value);
      } else {
        await _storage.setDefaultChatBackground(value);
      }
    } catch (e) {
      debugLog('ChatBackgroundPage: Failed to save background: $e');
      if (!mounted) {
        return;
      }
      setState(() => _selectedBackground = previousBackground);
      messenger.showSnackBar(
        SnackBar(
          content: Text(saveFailedMessage),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          S.of(context)?.chatBackground ?? 'Chat Background',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            AppIcons.back,
            color: context.textPrimary,
            size: 20,
          ),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isSaving,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 默认（无背景）
                _buildDefaultOption(),

                const SizedBox(height: 24),

                // 纯色背景
                Text(
                  S.of(context)?.solidColors ?? 'Solid Colors',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildColorGrid(),

                const SizedBox(height: 24),

                // 渐变背景
                Text(
                  S.of(context)?.gradients ?? 'Gradients',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildGradientGrid(),

                const SizedBox(height: 24),

                // 自定义照片背景（对标 iMessage iOS 26）
                Text(
                  'From Photos',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPhotoOption(),
              ],
            ),
          ),
          if (_isSaving)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }

  /// 从相册选一张照片作为聊天背景（对标 iMessage iOS 26 的会话背景）。
  ///
  /// 相册返回的是临时/沙箱路径，直接存 key 会在系统清理后失效——先复制进
  /// 应用文档目录的稳定路径再落库；替换/取消图片背景时顺手清理旧文件。
  Future<void> _pickImageBackground() async {
    if (_isSaving) return;
    final messenger = ScaffoldMessenger.of(context);
    final saveFailedMessage = S.of(context)?.commonSaveFailed ?? 'Save failed';
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 2160,
        imageQuality: 90,
      );
      if (picked == null || !mounted) return;

      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}/chat_backgrounds');
      await dir.create(recursive: true);
      final scope = widget.roomId ?? 'default';
      final ext = picked.path.contains('.')
          ? picked.path.substring(picked.path.lastIndexOf('.'))
          : '.jpg';
      // 文件名只用 basename，key 存相对名（见 ChatBackgroundPresets 说明）。
      final fileName =
          'bg_${scope.hashCode.toRadixString(16)}'
          '_${DateTime.now().millisecondsSinceEpoch}$ext';
      final dest = File('${dir.path}/$fileName');
      await File(picked.path).copy(dest.path);

      final previous = _selectedBackground;
      if (!mounted) {
        // 页面已销毁，无法落库——删掉刚拷贝的文件避免孤儿。
        try {
          await dest.delete();
        } catch (_) {}
        return;
      }
      final saved = _selectedBackground; // 记录落库前值，用于判断是否真成功
      await _selectBackground('${ChatBackgroundPresets.imageKeyPrefix}$fileName');
      // 仅当确实切换成功（当前值 == 新 key）才清理旧图；失败回滚时不动旧图，
      // 且要把这次拷贝的新文件删掉。
      final newKey = '${ChatBackgroundPresets.imageKeyPrefix}$fileName';
      if (_selectedBackground == newKey) {
        if (ChatBackgroundPresets.isImageKey(previous) && previous != newKey) {
          final oldPath = ChatBackgroundPresets.resolveImagePath(previous);
          if (oldPath != null) {
            try {
              final old = File(oldPath);
              if (await old.exists()) await old.delete();
            } catch (_) {}
          }
        }
      } else {
        // 保存失败（已回滚到 saved）：删除本次孤儿拷贝。
        if (_selectedBackground == saved) {
          try {
            await dest.delete();
          } catch (_) {}
        }
      }
    } catch (e) {
      debugLog('ChatBackgroundPage: pick image background failed: $e');
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(saveFailedMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildPhotoOption() {
    final isImage = ChatBackgroundPresets.isImageKey(_selectedBackground);
    final decoration = isImage
        ? ChatBackgroundPresets.resolveDecoration(_selectedBackground)
        : null;

    return Semantics(
      button: true,
      label: 'Choose photo background',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: _isSaving ? null : _pickImageBackground,
        child: Container(
          height: 80,
          decoration:
              (decoration ??
                      BoxDecoration(color: context.surfaceColor))
                  .copyWith(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isImage ? AppColors.primary : context.dividerColor,
                      width: isImage ? 2 : 1,
                    ),
                  ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: isImage
                  ? BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 18,
                    color: isImage ? Colors.white : context.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isImage ? 'Change photo' : 'Choose from gallery',
                    style: TextStyle(
                      color: isImage ? Colors.white : context.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultOption() {
    final isSelected =
        _selectedBackground == null || _selectedBackground == 'default';

    return GestureDetector(
      onTap: _isSaving ? null : () => _selectBackground('default'),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : context.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            S.of(context)?.defaultBackground ?? 'Default',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ChatBackgroundPresets.solidColors.asMap().entries.map((entry) {
        final colorKey = 'solid_${entry.key}';
        final isSelected = _selectedBackground == colorKey;

        return Semantics(
          button: true,
          selected: isSelected,
          label: A11yL10n.of(context).solidColor,
          excludeSemantics: true,
          child: GestureDetector(
          onTap: _isSaving ? null : () => _selectBackground(colorKey),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: entry.value,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: isSelected ? 2 : 0,
              ),
            ),
            child: isSelected
                ? const Center(
                    child: Icon(Icons.check_rounded, color: Colors.white, size: 24),
                  )
                : null,
          ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGradientGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ChatBackgroundPresets.gradients.asMap().entries.map((entry) {
        final gradientKey = 'gradient_${entry.key}';
        final isSelected = _selectedBackground == gradientKey;

        return Semantics(
          button: true,
          selected: isSelected,
          label: A11yL10n.of(context).gradient,
          excludeSemantics: true,
          child: GestureDetector(
          onTap: _isSaving ? null : () => _selectBackground(gradientKey),
          child: Container(
            width: 80,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: entry.value,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: isSelected ? 2 : 0,
              ),
            ),
            child: isSelected
                ? const Center(
                    child: Icon(Icons.check_rounded, color: Colors.white, size: 24),
                  )
                : null,
          ),
          ),
        );
      }).toList(),
    );
  }
}
