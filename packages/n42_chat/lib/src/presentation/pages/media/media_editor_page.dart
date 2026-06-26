import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// 媒体编辑器页面
///
/// 在发送图片前提供裁剪、旋转、涂鸦、文字等编辑功能。
/// 基于 pro_image_editor 库实现。
///
/// 返回编辑后的图片字节数据 [Uint8List]，如果用户取消则返回 null。
class MediaEditorPage extends StatefulWidget {
  /// 原始图片字节数据
  final Uint8List imageBytes;

  /// 文件名（用于标题显示）
  final String? filename;

  const MediaEditorPage({
    super.key,
    required this.imageBytes,
    this.filename,
  });

  /// 便捷方法：打开编辑器并返回编辑后的图片
  ///
  /// 返回 null 表示用户取消编辑
  static Future<Uint8List?> open(
    BuildContext context, {
    required Uint8List imageBytes,
    String? filename,
  }) {
    return Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        builder: (_) => MediaEditorPage(
          imageBytes: imageBytes,
          filename: filename,
        ),
      ),
    );
  }

  @override
  State<MediaEditorPage> createState() => _MediaEditorPageState();
}

class _MediaEditorPageState extends State<MediaEditorPage> {
  // pro_image_editor v11+ 先触发 onImageEditingComplete 再触发 onCloseEditor，
  // 必须在此暂存 bytes，统一在 onCloseEditor 里 pop，避免双重 pop 弹出上层页面。
  Uint8List? _editedBytes;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    final editorTheme = ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.black,
    );

    return ProImageEditor.memory(
      widget.imageBytes,
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (bytes) async {
          _editedBytes = bytes;
        },
        onCloseEditor: (_) {
          Navigator.of(context).pop(_editedBytes);
        },
      ),
      configs: ProImageEditorConfigs(
        theme: editorTheme,
        i18n: I18n(
          various: I18nVarious(
            loadingDialogMsg: l10n?.commonLoading ?? 'Loading...',
          ),
          cancel: l10n?.commonCancel ?? 'Cancel',
          undo: l10n?.mediaEditorUndo ?? 'Undo',
          redo: l10n?.mediaEditorRedo ?? 'Redo',
          done: l10n?.commonConfirm ?? 'Done',
          cropRotateEditor: I18nCropRotateEditor(
            bottomNavigationBarText: l10n?.mediaEditorCrop ?? 'Crop',
          ),
          filterEditor: I18nFilterEditor(
            bottomNavigationBarText: l10n?.mediaEditorFilter ?? 'Filter',
          ),
          paintEditor: I18nPaintEditor(
            bottomNavigationBarText: l10n?.mediaEditorDraw ?? 'Draw',
          ),
          textEditor: I18nTextEditor(
            bottomNavigationBarText: l10n?.mediaEditorText ?? 'Text',
          ),
        ),
      ),
    );
  }
}
