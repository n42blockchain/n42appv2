import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/config/proxy_config.dart';

void main() {
  group('ProxyConfig.isProxyUrl', () {
    test('matches routes under the configured proxy base URL', () {
      expect(ProxyConfig.isProxyUrl('${ProxyConfig.baseUrl}/v1/market/chart'), isTrue);
    });

    test('rejects non-proxy URLs', () {
      expect(ProxyConfig.isProxyUrl('https://example.com/api'), isFalse);
    });
  });

  group('ProxyConfig.mergeAuthHeaders', () {
    test('adds bearer token for proxy requests when token is provided', () {
      final headers = ProxyConfig.mergeAuthHeaders(
        ProxyConfig.moonpaySign,
        {'Content-Type': 'application/json'},
        'proxy-token',
      );

      expect(headers['Authorization'], 'Bearer proxy-token');
      expect(headers['Content-Type'], 'application/json');
    });

    test('does not add bearer token for non-proxy requests', () {
      final headers = ProxyConfig.mergeAuthHeaders(
        'https://example.com/api',
        {'Content-Type': 'application/json'},
        'proxy-token',
      );

      expect(headers.containsKey('Authorization'), isFalse);
    });

    test('preserves an existing authorization header', () {
      final headers = ProxyConfig.mergeAuthHeaders(
        ProxyConfig.bundler('1'),
        {'authorization': 'Bearer existing-token'},
        'proxy-token',
      );

      expect(headers['authorization'], 'Bearer existing-token');
      expect(headers.containsKey('Authorization'), isFalse);
    });
  });
}
