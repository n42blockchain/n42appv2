import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/wallet_connect_uri.dart';

void main() {
  group('parseWalletConnectUri', () {
    test('accepts a valid wc URI', () {
      final uri = parseWalletConnectUri(
        'wc:topic@2?relay-protocol=irn&symKey=abc123',
      );

      expect(uri, isNotNull);
      expect(uri!.scheme, 'wc');
    });

    test('rejects non-wc URIs even if they contain relay params', () {
      final uri = parseWalletConnectUri(
        'https://example.com/connect?relay-protocol=irn&symKey=abc123',
      );

      expect(uri, isNull);
    });

    test('rejects wc URIs missing WalletConnect query parameters', () {
      final uri = parseWalletConnectUri('wc:topic@2');

      expect(uri, isNull);
    });
  });

  group('isWalletConnectUriString', () {
    test('returns true only for parseable wc URIs', () {
      expect(
        isWalletConnectUriString('wc:topic@2?relay-protocol=irn&symKey=abc123'),
        isTrue,
      );
      expect(
        isWalletConnectUriString(
          'n42app://connect?relay-protocol=irn&symKey=abc123',
        ),
        isFalse,
      );
    });
  });
}
