import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/theme/chat_background_presets.dart';

void main() {
  group('ChatBackgroundPresets.resolveDecoration', () {
    test('default/null 返回 null', () {
      expect(ChatBackgroundPresets.resolveDecoration(null), isNull);
      expect(ChatBackgroundPresets.resolveDecoration('default'), isNull);
    });

    test('solid/gradient 预设仍解析（回归保护）', () {
      final solid = ChatBackgroundPresets.resolveDecoration('solid_0');
      expect(solid?.color, ChatBackgroundPresets.solidColors[0]);
      final gradient = ChatBackgroundPresets.resolveDecoration('gradient_1');
      expect(gradient?.gradient, isA<LinearGradient>());
    });

    test('image_ 指向存在的文件时返回 cover 图片背景', () async {
      final dir = await Directory.systemTemp.createTemp('bg_test');
      final file = File('${dir.path}/bg.png');
      await file.writeAsBytes(const [0, 1, 2, 3]);

      final deco = ChatBackgroundPresets.resolveDecoration(
        '${ChatBackgroundPresets.imageKeyPrefix}${file.path}',
      );
      expect(deco?.image, isNotNull);
      expect(deco!.image!.fit, BoxFit.cover);
      expect((deco.image!.image as FileImage).file.path, file.path);

      await dir.delete(recursive: true);
    });

    test('image_ 文件丢失时安全回退 null（不抛错）', () {
      final deco = ChatBackgroundPresets.resolveDecoration(
        '${ChatBackgroundPresets.imageKeyPrefix}/no/such/file.png',
      );
      expect(deco, isNull);
    });

    test('isImageKey 判定', () {
      expect(ChatBackgroundPresets.isImageKey('image_/a/b.png'), isTrue);
      expect(ChatBackgroundPresets.isImageKey('solid_0'), isFalse);
      expect(ChatBackgroundPresets.isImageKey(null), isFalse);
    });
  });
}
