import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/shared/utils/wallet_connect_uri.dart';

void main() {
  const wc = 'wc:topic@2?relay-protocol=irn&symKey=abc123';
  final encoded = Uri.encodeComponent(wc);
  for (final prefix in [
    'https://evil.walletconnect.com/wc',
    'https://walletconnect.com.evil/wc',
    'http://walletconnect.com/wc',
    'https://user@walletconnect.com/wc',
    'https://walletconnect.com:443/wc',
    'https://walletconnect.com/other',
    'https://walletconnect.com./wc',
    'n42app://evil',
    'javascript:alert(1)',
    'https://example.com',
    'https://%77alletconnect.com/wc',
  ]) {
    test('reject wrapper $prefix', () {
      expect(parseWalletConnectUri('$prefix?uri=$encoded'), isNull);
    });
  }
  test('reject duplicate or conflicting capabilities', () {
    expect(
      parseWalletConnectUri(
        'https://walletconnect.com/wc?uri=$encoded&wcUri=$encoded',
      ),
      isNull,
    );
    expect(
      parseWalletConnectUri(
        'https://walletconnect.com/wc?uri=$encoded&uri=$encoded',
      ),
      isNull,
    );
    expect(parseWalletConnectUri('$wc&symKey=other'), isNull);
  });
}
