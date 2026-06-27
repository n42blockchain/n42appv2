import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/wallet_login_credentials.dart';

void main() {
  const addr = '0xAbC123DEF456';
  const sig = '0xsignaturedeadbeef';

  group('canonicalLoginMessage', () {
    test('lowercases address and includes version', () {
      final msg = WalletLoginCredentials.canonicalLoginMessage(addr);
      expect(msg, contains('0xabc123def456'));
      expect(msg, contains('version: ${WalletLoginCredentials.version}'));
    });

    test('stable for same address', () {
      expect(
        WalletLoginCredentials.canonicalLoginMessage(addr),
        WalletLoginCredentials.canonicalLoginMessage('  $addr  '),
      );
    });
  });

  group('deriveUsername', () {
    test('is deterministic and case-insensitive on address', () {
      expect(
        WalletLoginCredentials.deriveUsername(addr),
        WalletLoginCredentials.deriveUsername(addr.toLowerCase()),
      );
    });

    test('is a valid matrix localpart (n42w_ + 16 hex)', () {
      final u = WalletLoginCredentials.deriveUsername(addr);
      expect(u, matches(RegExp(r'^n42w_[0-9a-f]{16}$')));
    });

    test('differs for different addresses', () {
      expect(
        WalletLoginCredentials.deriveUsername('0xaaa'),
        isNot(WalletLoginCredentials.deriveUsername('0xbbb')),
      );
    });
  });

  group('derivePassword', () {
    test('is deterministic for same signature', () {
      expect(
        WalletLoginCredentials.derivePassword(sig),
        WalletLoginCredentials.derivePassword(sig),
      );
    });

    test('has no base64 padding and is non-trivial length', () {
      final p = WalletLoginCredentials.derivePassword(sig);
      expect(p.contains('='), isFalse);
      expect(p.length, greaterThanOrEqualTo(40));
    });

    test('differs for different signatures', () {
      expect(
        WalletLoginCredentials.derivePassword('0xaaa'),
        isNot(WalletLoginCredentials.derivePassword('0xbbb')),
      );
    });
  });

  test('derive bundles username + password', () {
    final creds = WalletLoginCredentials.derive(address: addr, signature: sig);
    expect(creds.username, WalletLoginCredentials.deriveUsername(addr));
    expect(creds.password, WalletLoginCredentials.derivePassword(sig));
  });
}
