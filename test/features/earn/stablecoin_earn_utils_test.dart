import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/earn/utils/stablecoin_earn_utils.dart';
import 'package:n42_wallet/features/wallet/pages/lending/aave_service.dart';

/// Wallet Roadmap S1 —— 稳定币活期收益纯逻辑测试。
AaveReserve _reserve(String symbol, double apy, {double liquidity = 1000000}) {
  return AaveReserve(
    symbol: symbol,
    name: symbol,
    underlyingAsset: '0x0',
    supplyApy: apy,
    borrowApy: apy + 1,
    totalLiquidityUsd: liquidity,
    availableLiquidityUsd: liquidity,
    totalBorrowedUsd: 0,
    decimals: 6,
  );
}

void main() {
  group('isStablecoin', () {
    test('recognizes mainstream stablecoins, case-insensitive', () {
      expect(StablecoinEarnUtils.isStablecoin('USDC'), isTrue);
      expect(StablecoinEarnUtils.isStablecoin('usdt'), isTrue);
      expect(StablecoinEarnUtils.isStablecoin(' DAI '), isTrue);
      expect(StablecoinEarnUtils.isStablecoin('GHO'), isTrue);
    });

    test('rejects non-stablecoins and empty', () {
      expect(StablecoinEarnUtils.isStablecoin('WETH'), isFalse);
      expect(StablecoinEarnUtils.isStablecoin('WBTC'), isFalse);
      expect(StablecoinEarnUtils.isStablecoin(''), isFalse);
    });
  });

  group('filterSortStablecoins', () {
    test('keeps only liquid stablecoins, sorted by APY desc', () {
      final reserves = [
        _reserve('WETH', 2.0),
        _reserve('USDC', 4.5),
        _reserve('DAI', 6.1),
        _reserve('USDT', 3.2),
        _reserve('GHO', 9.9, liquidity: 0), // no liquidity -> dropped
      ];
      final out = StablecoinEarnUtils.filterSortStablecoins(reserves);
      expect(out.map((r) => r.symbol).toList(), ['DAI', 'USDC', 'USDT']);
    });

    test('bestStablecoin returns highest APY or null', () {
      expect(
        StablecoinEarnUtils.bestStablecoin([
          _reserve('USDC', 4.0),
          _reserve('DAI', 7.0),
        ])?.symbol,
        'DAI',
      );
      expect(StablecoinEarnUtils.bestStablecoin([_reserve('WETH', 5)]), isNull);
      expect(StablecoinEarnUtils.bestStablecoin([]), isNull);
    });
  });
}
