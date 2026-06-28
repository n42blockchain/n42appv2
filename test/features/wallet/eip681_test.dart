import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/utils/eip681.dart';

/// Wallet Roadmap M2 —— EIP-681 支付请求 URI 构建/解析测试。
void main() {
  const recipient = '0x1111111111111111111111111111111111111111';
  const token = '0x2222222222222222222222222222222222222222';

  group('build', () {
    test('native with chainId + value', () {
      expect(
        Eip681.buildNative(
            recipient: recipient, chainId: 1, amountWei: '1000000000000000000'),
        'ethereum:$recipient@1?value=1000000000000000000',
      );
    });

    test('native without amount', () {
      expect(
        Eip681.buildNative(recipient: recipient),
        'ethereum:$recipient',
      );
    });

    test('erc20 transfer', () {
      expect(
        Eip681.buildErc20Transfer(
            token: token, recipient: recipient, amount: '1000000', chainId: 137),
        'ethereum:$token@137/transfer?address=$recipient&uint256=1000000',
      );
    });
  });

  group('parse', () {
    test('round-trips erc20 transfer', () {
      final uri = Eip681.buildErc20Transfer(
          token: token, recipient: recipient, amount: '2500000', chainId: 42161);
      final r = Eip681.parse(uri)!;
      expect(r.isErc20Transfer, isTrue);
      expect(r.tokenAddress, token);
      expect(r.recipient, recipient);
      expect(r.amount, '2500000');
      expect(r.chainId, 42161);
    });

    test('round-trips native', () {
      final r = Eip681.parse(
          Eip681.buildNative(recipient: recipient, chainId: 1, amountWei: '5'))!;
      expect(r.isErc20Transfer, isFalse);
      expect(r.recipient, recipient);
      expect(r.amount, '5');
      expect(r.chainId, 1);
    });

    test('handles pay- prefix and no chainId', () {
      final r = Eip681.parse('ethereum:pay-$recipient')!;
      expect(r.targetAddress, recipient);
      expect(r.chainId, isNull);
      expect(r.functionName, isNull);
    });

    test('rejects non-ethereum uri', () {
      expect(Eip681.parse('bitcoin:abc'), isNull);
      expect(Eip681.parse('ethereum:'), isNull);
      expect(Eip681.parse('random'), isNull);
    });

    test('malformed percent-encoding does not throw (untrusted scan input)', () {
      // 畸形 %zz 序列：必须安全降级，绝不抛（否则扫码崩溃）。
      expect(() => Eip681.parse('ethereum:$recipient?memo=%zz&x=%'),
          returnsNormally);
      expect(() => Eip681.resolveRecipient('ethereum:$recipient?memo=%zz'),
          returnsNormally);
      expect(Eip681.resolveRecipient('ethereum:$recipient?memo=%zz'), recipient);
    });
  });

  group('resolveRecipient', () {
    test('extracts recipient from erc20 payment request', () {
      final uri = Eip681.buildErc20Transfer(
          token: token, recipient: recipient, amount: '1', chainId: 1);
      expect(Eip681.resolveRecipient(uri), recipient);
    });

    test('passes through a plain address', () {
      expect(Eip681.resolveRecipient(recipient), recipient);
    });
  });
}
