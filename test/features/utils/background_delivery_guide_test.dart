// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/utils/background_delivery_guide.dart';

void main() {
  group('isAggressiveBackgroundRom', () {
    test('matches major Chinese OEM brands (case-insensitive)', () {
      for (final b in [
        'Xiaomi', 'redmi', 'POCO',
        'OPPO', 'OnePlus', 'realme',
        'vivo', 'iQOO',
        'HUAWEI', 'honor',
        'Meizu',
      ]) {
        expect(isAggressiveBackgroundRom(b), isTrue, reason: b);
      }
    });

    test('does not match Pixel / Samsung / Apple / empty', () {
      for (final b in ['google', 'samsung', 'Apple', 'motorola', '']) {
        expect(isAggressiveBackgroundRom(b), isFalse, reason: b);
      }
    });

    test('trims surrounding whitespace', () {
      expect(isAggressiveBackgroundRom('  xiaomi '), isTrue);
    });
  });
}
