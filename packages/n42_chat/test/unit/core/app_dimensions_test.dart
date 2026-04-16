// Tests for AppDimensions in app_dimensions.dart.
// Pure Dart constants — no Flutter widget deps.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/theme/app_dimensions.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Spacing constants
  // ─────────────────────────────────────────────────

  group('AppDimensions spacing constants', () {
    test('spacingXS is 4.0', () {
      expect(AppDimensions.spacingXS, 4.0);
    });

    test('spacingS is 8.0', () {
      expect(AppDimensions.spacingS, 8.0);
    });

    test('spacingM is 12.0', () {
      expect(AppDimensions.spacingM, 12.0);
    });

    test('spacing (standard) is 16.0', () {
      expect(AppDimensions.spacing, 16.0);
    });

    test('spacingL is 20.0', () {
      expect(AppDimensions.spacingL, 20.0);
    });

    test('spacingXL is 24.0', () {
      expect(AppDimensions.spacingXL, 24.0);
    });

    test('spacingXXL is 32.0', () {
      expect(AppDimensions.spacingXXL, 32.0);
    });

    test('spacing increases: XS < S < M < standard < L < XL < XXL', () {
      expect(AppDimensions.spacingXS, lessThan(AppDimensions.spacingS));
      expect(AppDimensions.spacingS, lessThan(AppDimensions.spacingM));
      expect(AppDimensions.spacingM, lessThan(AppDimensions.spacing));
      expect(AppDimensions.spacing, lessThan(AppDimensions.spacingL));
      expect(AppDimensions.spacingL, lessThan(AppDimensions.spacingXL));
      expect(AppDimensions.spacingXL, lessThan(AppDimensions.spacingXXL));
    });
  });

  // ─────────────────────────────────────────────────
  // Radius constants
  // ─────────────────────────────────────────────────

  group('AppDimensions radius constants', () {
    test('radiusXS is 2.0', () {
      expect(AppDimensions.radiusXS, 2.0);
    });

    test('radiusS is 4.0', () {
      expect(AppDimensions.radiusS, 4.0);
    });

    test('radiusM is 8.0', () {
      expect(AppDimensions.radiusM, 8.0);
    });

    test('radiusL is 12.0', () {
      expect(AppDimensions.radiusL, 12.0);
    });

    test('radiusXL is 16.0', () {
      expect(AppDimensions.radiusXL, 16.0);
    });

    test('radiusFull is 999.0', () {
      expect(AppDimensions.radiusFull, 999.0);
    });

    test('radius increases: XS < S < M < L < XL < Full', () {
      expect(AppDimensions.radiusXS, lessThan(AppDimensions.radiusS));
      expect(AppDimensions.radiusS, lessThan(AppDimensions.radiusM));
      expect(AppDimensions.radiusM, lessThan(AppDimensions.radiusL));
      expect(AppDimensions.radiusL, lessThan(AppDimensions.radiusXL));
      expect(AppDimensions.radiusXL, lessThan(AppDimensions.radiusFull));
    });
  });

  // ─────────────────────────────────────────────────
  // Avatar constants
  // ─────────────────────────────────────────────────

  group('AppDimensions avatar constants', () {
    test('avatarSizeConversation is 48.0', () {
      expect(AppDimensions.avatarSizeConversation, 48.0);
    });

    test('avatarSizeChat is 40.0', () {
      expect(AppDimensions.avatarSizeChat, 40.0);
    });

    test('avatarSizeSmall is 32.0', () {
      expect(AppDimensions.avatarSizeSmall, 32.0);
    });

    test('avatarSizeXSmall is 24.0', () {
      expect(AppDimensions.avatarSizeXSmall, 24.0);
    });

    test('avatarSizeProfile is 72.0', () {
      expect(AppDimensions.avatarSizeProfile, 72.0);
    });

    test('avatar size decreases: Profile > Conversation > Chat > Small > XSmall', () {
      expect(AppDimensions.avatarSizeProfile, greaterThan(AppDimensions.avatarSizeConversation));
      expect(AppDimensions.avatarSizeConversation, greaterThan(AppDimensions.avatarSizeChat));
      expect(AppDimensions.avatarSizeChat, greaterThan(AppDimensions.avatarSizeSmall));
      expect(AppDimensions.avatarSizeSmall, greaterThan(AppDimensions.avatarSizeXSmall));
    });
  });

  // ─────────────────────────────────────────────────
  // Navigation constants
  // ─────────────────────────────────────────────────

  group('AppDimensions navigation constants', () {
    test('appBarHeight is 44.0', () {
      expect(AppDimensions.appBarHeight, 44.0);
    });

    test('bottomNavBarHeight is 56.0', () {
      expect(AppDimensions.bottomNavBarHeight, 56.0);
    });

    test('searchBarHeight is 36.0', () {
      expect(AppDimensions.searchBarHeight, 36.0);
    });
  });

  // ─────────────────────────────────────────────────
  // Message constants
  // ─────────────────────────────────────────────────

  group('AppDimensions message constants', () {
    test('messageBubbleMaxWidthRatio is 0.7', () {
      expect(AppDimensions.messageBubbleMaxWidthRatio, 0.7);
    });

    test('messageBubbleRadius is 4.0', () {
      expect(AppDimensions.messageBubbleRadius, 4.0);
    });

    test('messageBubblePadding is 10.0', () {
      expect(AppDimensions.messageBubblePadding, 10.0);
    });

    test('messageSpacing is 8.0', () {
      expect(AppDimensions.messageSpacing, 8.0);
    });
  });

  // ─────────────────────────────────────────────────
  // Input constants
  // ─────────────────────────────────────────────────

  group('AppDimensions input constants', () {
    test('inputMinHeight is less than inputMaxHeight', () {
      expect(AppDimensions.inputMinHeight, lessThan(AppDimensions.inputMaxHeight));
    });

    test('inputMinHeight is 36.0', () {
      expect(AppDimensions.inputMinHeight, 36.0);
    });

    test('inputMaxHeight is 120.0', () {
      expect(AppDimensions.inputMaxHeight, 120.0);
    });
  });

  // ─────────────────────────────────────────────────
  // Animation durations
  // ─────────────────────────────────────────────────

  group('AppDimensions animation durations', () {
    test('animationFast is 150ms', () {
      expect(AppDimensions.animationFast, const Duration(milliseconds: 150));
    });

    test('animationNormal is 300ms', () {
      expect(AppDimensions.animationNormal, const Duration(milliseconds: 300));
    });

    test('animationSlow is 450ms', () {
      expect(AppDimensions.animationSlow, const Duration(milliseconds: 450));
    });

    test('animationFast < animationNormal < animationSlow', () {
      expect(AppDimensions.animationFast, lessThan(AppDimensions.animationNormal));
      expect(AppDimensions.animationNormal, lessThan(AppDimensions.animationSlow));
    });
  });

  // ─────────────────────────────────────────────────
  // Badge constants
  // ─────────────────────────────────────────────────

  group('AppDimensions badge constants', () {
    test('badgeDotSize is 8.0', () {
      expect(AppDimensions.badgeDotSize, 8.0);
    });

    test('badgeMinWidth is 18.0', () {
      expect(AppDimensions.badgeMinWidth, 18.0);
    });

    test('badgeHeight is 18.0', () {
      expect(AppDimensions.badgeHeight, 18.0);
    });
  });
}
