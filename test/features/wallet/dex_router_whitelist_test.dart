import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_router_whitelist.dart';

void main() {
  group('DexRouterWhitelist', () {
    test('信任 Uniswap SwapRouter02', () {
      expect(
        DexRouterWhitelist.isTrusted(
          '0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45',
        ),
        isTrue,
      );
    });

    test('信任 1inch AggregationRouterV6', () {
      expect(
        DexRouterWhitelist.isTrusted(
          '0x111111125421cA6dc452d289314280a0f8842A65',
        ),
        isTrue,
      );
    });

    test('大小写与 0x 前缀不敏感', () {
      expect(
        DexRouterWhitelist.isTrusted(
          '68B3465833FB72A70ECDF485E0E4C7BD8665FC45',
        ),
        isTrue,
      );
    });

    test('拒绝攻击者合约地址', () {
      expect(
        DexRouterWhitelist.isTrusted(
          '0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef',
        ),
        isFalse,
      );
    });

    test('拒绝 null / 空 / 畸形地址', () {
      expect(DexRouterWhitelist.isTrusted(null), isFalse);
      expect(DexRouterWhitelist.isTrusted(''), isFalse);
      expect(DexRouterWhitelist.isTrusted('0x123'), isFalse);
    });
  });

  group('DexSwapCalldataGuard.checkRecipient', () {
    const owner = '0x1111111111111111111111111111111111111111';
    const attacker = '2222222222222222222222222222222222222222';

    String word(String hex40) => '0' * 24 + hex40;
    String pad(String hex) => hex.padRight(64, '0');

    // exactInputSingle(0x04e45aaf): recipient at word index 3.
    String exactInputSingle(String recipient40) {
      return '0x04e45aaf'
          '${pad('aaaa')}' // tokenIn
          '${pad('bbbb')}' // tokenOut
          '${pad('0bb8')}' // fee
          '${word(recipient40)}' // recipient
          '${pad('0de0b6b3a7640000')}' // amountIn
          '${pad('00')}' // amountOutMinimum
          '${pad('00')}'; // sqrtPriceLimitX96
    }

    // exactInput(0xb858183f): recipient at word index 2.
    String exactInput(String recipient40) {
      return '0xb858183f'
          '${pad('20')}' // outer offset
          '${pad('80')}' // path offset within tuple
          '${word(recipient40)}' // recipient
          '${pad('0de0b6b3a7640000')}' // amountIn
          '${pad('00')}'; // amountOutMinimum
    }

    test('recipient 为本人 → ok', () {
      expect(
        DexSwapCalldataGuard.checkRecipient(
          exactInputSingle('1111111111111111111111111111111111111111'),
          owner,
        ),
        SwapRecipientCheck.ok,
      );
      expect(
        DexSwapCalldataGuard.checkRecipient(
          exactInput('1111111111111111111111111111111111111111'),
          owner,
        ),
        SwapRecipientCheck.ok,
      );
    });

    test('recipient 为攻击者 → mismatch（拦截）', () {
      expect(
        DexSwapCalldataGuard.checkRecipient(exactInputSingle(attacker), owner),
        SwapRecipientCheck.mismatch,
      );
      expect(
        DexSwapCalldataGuard.checkRecipient(exactInput(attacker), owner),
        SwapRecipientCheck.mismatch,
      );
    });

    test('MSG_SENDER / ADDRESS_THIS / zero 自引用 → ok', () {
      for (final self in [
        '0000000000000000000000000000000000000000',
        '0000000000000000000000000000000000000001',
        '0000000000000000000000000000000000000002',
      ]) {
        expect(
          DexSwapCalldataGuard.checkRecipient(exactInputSingle(self), owner),
          SwapRecipientCheck.ok,
        );
      }
    });

    test('未知 selector → unknown（放行，不误伤）', () {
      expect(
        DexSwapCalldataGuard.checkRecipient('0xdeadbeef${pad('00')}', owner),
        SwapRecipientCheck.unknown,
      );
      expect(
        DexSwapCalldataGuard.checkRecipient('0x', owner),
        SwapRecipientCheck.unknown,
      );
    });

    test('calldata 被截断到 recipient 之前 → unknown', () {
      expect(
        DexSwapCalldataGuard.checkRecipient('0x04e45aaf${pad('aaaa')}', owner),
        SwapRecipientCheck.unknown,
      );
    });
  });
}
