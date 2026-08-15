import 'dart:io';

import 'package:flutter/material.dart';

/// 聊天背景预设常量
///
/// 统一管理纯色和渐变背景预设，避免 chat_background_page.dart
/// 和 chat_page.dart 中的重复定义。
abstract class ChatBackgroundPresets {
  /// 8 种纯色背景
  static const List<Color> solidColors = [
    Color(0xFFEDEDED),
    Color(0xFFD6E4F0),
    Color(0xFFD4EDDA),
    Color(0xFFFFF3CD),
    Color(0xFFF8D7DA),
    Color(0xFFE2D9F3),
    Color(0xFFD1ECF1),
    Color(0xFF343A40),
  ];

  /// 4 种渐变背景
  static const List<List<Color>> gradients = [
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFFF093FB), Color(0xFFF5576C)],
    [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    [Color(0xFF43E97B), Color(0xFF38F9D7)],
  ];

  /// 根据 key 解析为 BoxDecoration
  static BoxDecoration? resolveDecoration(String? key) {
    if (key == null || key == 'default') return null;

    if (key.startsWith('solid_')) {
      final index = int.tryParse(key.substring(6));
      if (index != null && index >= 0 && index < solidColors.length) {
        return BoxDecoration(color: solidColors[index]);
      }
    } else if (key.startsWith('gradient_')) {
      final index = int.tryParse(key.substring(9));
      if (index != null && index >= 0 && index < gradients.length) {
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradients[index],
          ),
        );
      }
    } else if (key.startsWith(imageKeyPrefix)) {
      // 自定义图片背景（对标 iMessage iOS 26 的"照片做会话背景"）。
      // key 携带的是已复制进应用文档目录的稳定路径；文件被系统清理/迁移
      // 丢失时安全回退默认背景，不抛错。
      final path = key.substring(imageKeyPrefix.length);
      final file = File(path);
      if (path.isNotEmpty && file.existsSync()) {
        return BoxDecoration(
          image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
        );
      }
    }

    return null;
  }

  /// 自定义图片背景 key 前缀：`image_<绝对路径>`
  static const String imageKeyPrefix = 'image_';

  /// [key] 是否为自定义图片背景
  static bool isImageKey(String? key) =>
      key != null && key.startsWith(imageKeyPrefix);
}
