import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

const _white = Color(0xFFFFFFFF);
const _systemBlue = Color(0xFF007AFF);
const _systemBlueDark = Color(0xFF0A84FF);

double _hue(Color c) => HSLColor.fromColor(c).hue;

void main() {
  group('AppContrast.fillForWhiteText', () {
    test('system blue alone is below 4.5:1 with white', () {
      expect(AppContrast.ratio(_systemBlue, _white), lessThan(4.5));
      expect(AppContrast.ratio(_systemBlueDark, _white), lessThan(4.5));
    });

    for (final brand in [
      _systemBlue,
      _systemBlueDark,
      const Color(0xFF5B6CFF),
      const Color(0xFFFF9500),
      const Color(0xFF34C759),
    ]) {
      test('reaches 4.5:1 and keeps the hue for $brand', () {
        final fill = AppContrast.fillForWhiteText(brand);
        expect(AppContrast.ratio(fill, _white), greaterThanOrEqualTo(4.5));
        expect(_hue(fill), closeTo(_hue(brand), 1.0));
        // Darkened only as far as needed (bounded lightness shift).
        expect(
          HSLColor.fromColor(brand).lightness -
              HSLColor.fromColor(fill).lightness,
          inInclusiveRange(0, 0.3),
        );
      });
    }

    test('accounts for a translucent white layer over the fill', () {
      final fill = AppContrast.fillForWhiteText(
        _systemBlue,
        whiteOverlay: 0.09,
      );
      final pill = Color.alphaBlend(_white.withValues(alpha: 0.09), fill);
      expect(AppContrast.ratio(pill, _white), greaterThanOrEqualTo(4.5));
      expect(AppContrast.ratio(fill, _white), greaterThanOrEqualTo(4.5));
    });

    test('leaves an already dark brand unchanged', () {
      const navy = Color(0xFF1A237E);
      expect(AppContrast.fillForWhiteText(navy), navy);
    });
  });

  group('AppContrast.textOnTint', () {
    test('light: brand text on a 15% tint over white and grouped bg', () {
      const surfaces = [Color(0xFFFFFFFF), Color(0xFFF2F2F7)];
      final text = AppContrast.textOnTint(_systemBlue, surfaces, dark: false);
      for (final s in surfaces) {
        final bg = Color.alphaBlend(_systemBlue.withValues(alpha: 0.15), s);
        expect(AppContrast.ratio(_systemBlue, bg), lessThan(4.5));
        expect(AppContrast.ratio(text, bg), greaterThanOrEqualTo(4.5));
        // Lower tint alphas only make the background lighter.
        final bg08 = Color.alphaBlend(_systemBlue.withValues(alpha: 0.08), s);
        expect(AppContrast.ratio(text, bg08), greaterThanOrEqualTo(4.5));
      }
    });

    test('dark: lightens brand text over dark surfaces', () {
      const surfaces = [
        Color(0xFF000000),
        Color(0xFF1C1C1E),
        Color(0xFF2C2C2E),
      ];
      final text = AppContrast.textOnTint(
        _systemBlueDark,
        surfaces,
        dark: true,
      );
      expect(
        HSLColor.fromColor(text).lightness,
        greaterThan(HSLColor.fromColor(_systemBlueDark).lightness),
      );
      for (final s in surfaces) {
        final bg = Color.alphaBlend(_systemBlueDark.withValues(alpha: 0.15), s);
        expect(AppContrast.ratio(text, bg), greaterThanOrEqualTo(4.5));
      }
    });
  });

  group('theme filled buttons', () {
    for (final dark in [false, true]) {
      testWidgets('use the white-text-safe fill (dark: $dark)', (tester) async {
        final theme = dark
            ? ThemeAdapter.buildDark(ThemeAdapter.defaultAccent)
            : ThemeAdapter.buildLight(ThemeAdapter.defaultAccent);
        late Color fill;
        late Color tokenFill;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) {
                fill = Theme.of(context)
                    .filledButtonTheme
                    .style!
                    .backgroundColor!
                    .resolve(<WidgetState>{})!;
                tokenFill = AppColorTokens.of(context).brandFill;
                return const SizedBox();
              },
            ),
          ),
        );
        final brand = dark
            ? CupertinoColors.systemBlue.darkColor
            : CupertinoColors.systemBlue.color;
        expect(AppContrast.ratio(brand, _white), lessThan(4.5));
        expect(AppContrast.ratio(fill, _white), greaterThanOrEqualTo(4.5));
        expect(tokenFill, fill);
      });
    }
  });
}
