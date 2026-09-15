// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// Tests for the 13-language splash screen randomization. Splash text is
// chosen on every cold start, so the function must:
//   - Never return a malformed [SplashVariant] (mainText always required)
//   - Stay within the documented variant pools
//   - Honor the 50/50 weight split between the cn/en pool (6 variants)
//   - and the other-11-languages pool (33 variants)
//
// The weights compensate for the variant count: each of the 6 cn/en
// variants gets weight 11; each of the 33 other-language variants gets
// weight 2; total 66 + 66 = 132. So both pools have equal aggregate
// probability, but inside each pool each variant has the same chance.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/splash/splash_variants.dart';

void main() {
  group('SplashVariant', () {
    test('constructor accepts mainText only (no labels)', () {
      const v = SplashVariant(mainText: '耕者有其田');
      expect(v.mainText, '耕者有其田');
      expect(v.topLabel, isNull);
      expect(v.midLabel, isNull);
    });

    test('constructor accepts topLabel + mainText', () {
      const v = SplashVariant(topLabel: 'Who Creates', mainText: 'OWNS');
      expect(v.topLabel, 'Who Creates');
      expect(v.mainText, 'OWNS');
      expect(v.midLabel, isNull);
    });

    test('constructor accepts all three slots', () {
      const v = SplashVariant(
        topLabel: 'Private',
        mainText: 'Sovereignty',
        midLabel: 'Matters',
      );
      expect(v.topLabel, 'Private');
      expect(v.mainText, 'Sovereignty');
      expect(v.midLabel, 'Matters');
    });
  });

  group('pickRandomVariant', () {
    test('returns a SplashVariant with non-empty mainText', () {
      // mainText is `required` in the constructor — guard against
      // any future variant accidentally bypassing that.
      for (var i = 0; i < 50; i++) {
        final v = pickRandomVariant();
        expect(
          v.mainText,
          isNotEmpty,
          reason: 'iter $i returned empty mainText',
        );
      }
    });

    test('hits both cn/en and other-language pools over many samples', () {
      // English / Chinese marker strings — should be hit by Pool 1.
      const cnEnMarkers = {
        'OWNS',
        'Sovereignty',
        'Blockchain',
        '耕者有其田',
        '自己的事，最好自己说了算',
        '上链得永生',
      };

      var cnEnHits = 0;
      var otherHits = 0;
      // 300 draws is enough to catch a wholly-skewed implementation
      // while keeping the bands loose enough to absorb RNG variance.
      const draws = 300;
      for (var i = 0; i < draws; i++) {
        final v = pickRandomVariant();
        if (cnEnMarkers.contains(v.mainText)) {
          cnEnHits++;
        } else {
          // Non-cn/en variants all belong to the other-language pool.
          otherHits++;
        }
      }

      // With 50/50 split we expect ~150 each in 300 draws. A lower
      // bound of 75 catches a wholly-skewed implementation while
      // accepting normal RNG variance.
      expect(
        cnEnHits,
        greaterThan(75),
        reason: 'cn/en pool seems under-weighted: $cnEnHits / $draws',
      );
      expect(
        otherHits,
        greaterThan(75),
        reason: 'other-language pool seems under-weighted: $otherHits / $draws',
      );
    });

    test('returned variants have plausible string shapes (no junk)', () {
      // Stays away from a hardcoded whitelist (the pools have 39 entries
      // across 13 languages; maintaining a parallel set in tests is more
      // bug-prone than the function being tested). Instead, sanity-check
      // each variant's strings are non-empty when present and have
      // reasonable length bounds — catches truncation, accidental null
      // string interpolation, or huge data corruption.
      for (var i = 0; i < 200; i++) {
        final v = pickRandomVariant();
        expect(v.mainText.length, greaterThanOrEqualTo(2));
        expect(v.mainText.length, lessThan(50));
        if (v.topLabel != null) {
          expect(v.topLabel!.length, greaterThan(0));
          expect(v.topLabel!.length, lessThan(50));
        }
        if (v.midLabel != null) {
          expect(v.midLabel!.length, greaterThan(0));
          expect(v.midLabel!.length, lessThan(50));
        }
      }
    });

    test(
      'returns a fresh-enough sample of distinct variants over 200 draws',
      () {
        // 39 unique variants × 200 draws → birthday paradox says we should
        // observe a substantial fraction of the pool. A lower bound of 15
        // distinct mainTexts catches a stuck-on-one-variant bug while
        // tolerating RNG variance.
        final seen = <String>{};
        for (var i = 0; i < 200; i++) {
          seen.add(pickRandomVariant().mainText);
        }
        expect(
          seen.length,
          greaterThan(15),
          reason: 'only saw ${seen.length} distinct mainTexts in 200 draws',
        );
      },
    );
  });
}
