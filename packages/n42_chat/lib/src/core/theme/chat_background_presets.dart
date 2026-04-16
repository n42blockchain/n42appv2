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
    }

    return null;
  }
}
