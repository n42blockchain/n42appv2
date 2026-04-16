// Tests for ChatBackgroundPresets in chat_background_presets.dart.
// Uses flutter/material.dart for Color/BoxDecoration — no widget tree needed.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/theme/chat_background_presets.dart';

void main() {
  // ─────────────────────────────────────────────────
  // solidColors list
  // ─────────────────────────────────────────────────

  group('ChatBackgroundPresets.solidColors', () {
    test('has 8 colors', () {
      expect(ChatBackgroundPresets.solidColors, hasLength(8));
    });

    test('first color is light grey', () {
      expect(ChatBackgroundPresets.solidColors[0], const Color(0xFFEDEDED));
    });

    test('last color is dark (dark mode)', () {
      expect(ChatBackgroundPresets.solidColors[7], const Color(0xFF343A40));
    });
  });

  // ─────────────────────────────────────────────────
  // gradients list
  // ─────────────────────────────────────────────────

  group('ChatBackgroundPresets.gradients', () {
    test('has 4 gradients', () {
      expect(ChatBackgroundPresets.gradients, hasLength(4));
    });

    test('each gradient has exactly 2 colors', () {
      for (final g in ChatBackgroundPresets.gradients) {
        expect(g, hasLength(2));
      }
    });

    test('first gradient starts with purple-blue', () {
      expect(ChatBackgroundPresets.gradients[0][0], const Color(0xFF667EEA));
    });
  });

  // ─────────────────────────────────────────────────
  // resolveDecoration — null / default
  // ─────────────────────────────────────────────────

  group('ChatBackgroundPresets.resolveDecoration — null/default', () {
    test('null key returns null', () {
      expect(ChatBackgroundPresets.resolveDecoration(null), isNull);
    });

    test('default key returns null', () {
      expect(ChatBackgroundPresets.resolveDecoration('default'), isNull);
    });

    test('unknown key returns null', () {
      expect(ChatBackgroundPresets.resolveDecoration('unknown_key'), isNull);
    });

    test('empty string returns null', () {
      expect(ChatBackgroundPresets.resolveDecoration(''), isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // resolveDecoration — solid colors
  // ─────────────────────────────────────────────────

  group('ChatBackgroundPresets.resolveDecoration — solid', () {
    test('solid_0 returns BoxDecoration with first color', () {
      final dec = ChatBackgroundPresets.resolveDecoration('solid_0');
      expect(dec, isNotNull);
      expect(dec!.color, ChatBackgroundPresets.solidColors[0]);
    });

    test('solid_7 returns BoxDecoration with last color', () {
      final dec = ChatBackgroundPresets.resolveDecoration('solid_7');
      expect(dec, isNotNull);
      expect(dec!.color, ChatBackgroundPresets.solidColors[7]);
    });

    test('solid_8 returns null (out of bounds)', () {
      expect(ChatBackgroundPresets.resolveDecoration('solid_8'), isNull);
    });

    test('solid_-1 returns null (negative index)', () {
      expect(ChatBackgroundPresets.resolveDecoration('solid_-1'), isNull);
    });

    test('solid_abc returns null (non-numeric index)', () {
      expect(ChatBackgroundPresets.resolveDecoration('solid_abc'), isNull);
    });

    test('solid_ (empty index) returns null', () {
      expect(ChatBackgroundPresets.resolveDecoration('solid_'), isNull);
    });

    test('solid decoration has no gradient', () {
      final dec = ChatBackgroundPresets.resolveDecoration('solid_0');
      expect(dec!.gradient, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // resolveDecoration — gradients
  // ─────────────────────────────────────────────────

  group('ChatBackgroundPresets.resolveDecoration — gradient', () {
    test('gradient_0 returns BoxDecoration with LinearGradient', () {
      final dec = ChatBackgroundPresets.resolveDecoration('gradient_0');
      expect(dec, isNotNull);
      expect(dec!.gradient, isA<LinearGradient>());
    });

    test('gradient_0 uses correct colors', () {
      final dec = ChatBackgroundPresets.resolveDecoration('gradient_0');
      final grad = dec!.gradient as LinearGradient;
      expect(grad.colors, ChatBackgroundPresets.gradients[0]);
    });

    test('gradient_3 returns valid BoxDecoration (last valid)', () {
      final dec = ChatBackgroundPresets.resolveDecoration('gradient_3');
      expect(dec, isNotNull);
      expect(dec!.gradient, isA<LinearGradient>());
    });

    test('gradient_4 returns null (out of bounds)', () {
      expect(ChatBackgroundPresets.resolveDecoration('gradient_4'), isNull);
    });

    test('gradient_abc returns null (non-numeric)', () {
      expect(ChatBackgroundPresets.resolveDecoration('gradient_abc'), isNull);
    });

    test('gradient decoration has no solid color', () {
      final dec = ChatBackgroundPresets.resolveDecoration('gradient_0');
      expect(dec!.color, isNull);
    });

    test('gradient uses topLeft to bottomRight direction', () {
      final dec = ChatBackgroundPresets.resolveDecoration('gradient_1');
      final grad = dec!.gradient as LinearGradient;
      expect(grad.begin, Alignment.topLeft);
      expect(grad.end, Alignment.bottomRight);
    });
  });
}
