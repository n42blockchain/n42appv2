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
}
