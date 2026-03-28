import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/shared/utils/wallet_connect_uri.dart';

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

    test('accepts percent-encoded wc URIs', () {
      final uri = parseWalletConnectUri(
        'wc%3Atopic%402%3Frelay-protocol%3Dirn%26symKey%3Dabc123',
      );

      expect(uri, isNotNull);
      expect(uri.toString(), 'wc:topic@2?relay-protocol=irn&symKey=abc123');
    });

    test('extracts wc uri from universal link query', () {
      final uri = parseWalletConnectUri(
        'https://walletconnect.com/wc?uri=wc%3Atopic%402%3Frelay-protocol%3Dirn%26symKey%3Dabc123',
      );

      expect(uri, isNotNull);
      expect(uri!.scheme, 'wc');
      expect(uri.queryParameters['symKey'], 'abc123');
    });

    test('rejects malformed universal links missing wc parameters', () {
      final uri = parseWalletConnectUri(
        'https://walletconnect.com/wc?uri=wc%3Atopic%402',
      );

      expect(uri, isNull);
    });

    test('extracts wc uri from wcUri query parameter', () {
      final uri = parseWalletConnectUri(
        'n42app://connect?wcUri=wc%3Atopic%402%3Frelay-protocol%3Dirn%26symKey%3Dabc123',
      );

      expect(uri, isNotNull);
      expect(uri!.scheme, 'wc');
      expect(uri.queryParameters['relay-protocol'], 'irn');
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
      expect(
        isWalletConnectUriString(
          'https://walletconnect.com/wc?uri=wc%3Atopic%402%3Frelay-protocol%3Dirn%26symKey%3Dabc123',
        ),
        isTrue,
      );
    });
  });
}
