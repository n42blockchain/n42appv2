// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    // ── Constants ─────────────────────────────────────────────────────────

    test('walletNameMaxLength is 12', () {
      expect(AppConfig.walletNameMaxLength, 12);
    });

    test('walletPasswordLength is 8', () {
      expect(AppConfig.walletPasswordLength, 8);
    });

    // ── Mining URLs ─────────────────────────────────────────────────────

    group('mining URLs', () {
      test('miningWebSocketUrl is not empty', () {
        expect(AppConfig.miningWebSocketUrl.isNotEmpty, true);
      });

      test('miningRpcUrl is not empty', () {
        expect(AppConfig.miningRpcUrl.isNotEmpty, true);
      });

      test('miningRpcUrl default starts with http', () {
        // Default value is http://5.161.252.59:8545
        expect(
          AppConfig.miningRpcUrl.startsWith('http'),
          true,
        );
      });

      test('miningWebSocketUrl default starts with ws', () {
        expect(
          AppConfig.miningWebSocketUrl.startsWith('ws'),
          true,
        );
      });
    });

    // ── API URL helpers ─────────────────────────────────────────────────

    group('getApiUrlOnline', () {
      test('returns main URL when isOnline is true', () {
        // AppConfig.isOnline is const true
        final url = AppConfig.getApiUrlOnline('marketHost');
        expect(url, contains('api.n42.ai'));
      });

      test('returns string for non-map entries', () {
        final url = AppConfig.getApiUrlOnline('ipfsHost');
        expect(url, 'https://api.n42.ai');
      });

      test('returns empty string for unknown key', () {
        final url = AppConfig.getApiUrlOnline('nonExistentKey');
        expect(url, '');
      });
    });

    // ── API URL map ──────────────────────────────────────────────────────

    group('apiUrl entries', () {
      test('marketHost test URL uses HTTPS', () {
        final marketHost = AppConfig.apiUrl['marketHost'] as Map;
        expect(
          (marketHost['test'] as String).startsWith('https://'),
          true,
          reason: 'Test market URL should use HTTPS',
        );
      });

      test('all main URLs use HTTPS', () {
        void checkMainUrls(Map<String, dynamic> map, String path) {
          for (final entry in map.entries) {
            if (entry.value is Map) {
              final main = (entry.value as Map)['main'];
              if (main is String) {
                expect(
                  main.startsWith('https://'),
                  true,
                  reason: '$path.${entry.key}.main should use HTTPS: $main',
                );
              }
            } else if (entry.value is String) {
              final url = entry.value as String;
              if (url.startsWith('http')) {
                expect(
                  url.startsWith('https://'),
                  true,
                  reason: '$path.${entry.key} should use HTTPS: $url',
                );
              }
            }
          }
        }

        checkMainUrls(AppConfig.apiUrl, 'apiUrl');
      });
    });

    // ── validateUrlsInDebug ──────────────────────────────────────────────

    group('validateUrlsInDebug', () {
      test('does not throw', () {
        // validateUrlsInDebug only prints warnings, never throws
        expect(() => AppConfig.validateUrlsInDebug(), returnsNormally);
      });
    });

    // ── Environment helpers ──────────────────────────────────────────────

    group('environment helpers', () {
      test('environmentName matches isOnline', () {
        if (AppConfig.isOnline) {
          expect(AppConfig.environmentName, 'Production');
        } else {
          expect(AppConfig.environmentName, 'Development');
        }
      });
    });
  });

  group('initAppConfig', () {
    test('does not throw', () {
      expect(() => initAppConfig(), returnsNormally);
    });
  });
}
