import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/scan_to_pay_utils.dart';
import 'package:n42_wallet/features/wallet/utils/eip681.dart';

void main() {
  CoinModel native({
    required String coinType,
    required int chainId,
    String address = '0xSender',
  }) {
    final coin = CoinModel.fromMap({
      'coinType': coinType,
      'blockchainType': BlockchainType.Ethereum.name,
      'miniName': coinType,
      'decimals': 18,
      'isContract': false,
      'chainId': chainId,
      'contract': '',
    });
    coin.address = address;
    return coin;
  }

  CoinModel erc20({
    required String coinType,
    required int chainId,
    required String contract,
    required int decimals,
    String miniName = 'USDC',
    String address = '0xSender',
  }) {
    final coin = CoinModel.fromMap({
      'coinType': coinType,
      'blockchainType': BlockchainType.Ethereum.name,
      'miniName': miniName,
      'decimals': decimals,
      'isContract': true,
      'chainId': chainId,
      'contract': contract,
    });
    coin.address = address;
    return coin;
  }

  test('formatMinUnits keeps integer precision without double', () {
    expect(ScanToPayResolver.formatMinUnits('1234567', 6), '1.234567');
    expect(ScanToPayResolver.formatMinUnits('1000000', 6), '1');
    expect(
      ScanToPayResolver.formatMinUnits('123456789012345678901234', 18),
      '123456.789012345678901234',
    );
    expect(ScanToPayResolver.formatMinUnits('42', 0), '42');
    expect(ScanToPayResolver.formatMinUnits('-1', 6), isNull);
  });

  test('resolves ERC-20 request by chain id and contract', () {
    final eth = native(coinType: 'ETH', chainId: 1);
    final usdc = erc20(
      coinType: 'ETH',
      chainId: 1,
      contract: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
      decimals: 6,
    );
    final request = Eip681.parse(
      'ethereum:0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48@1'
      '/transfer?address=0xRecipient&uint256=2500000',
    )!;

    final resolution = ScanToPayResolver.resolve(
      request: request,
      coinModels: [eth, usdc],
      currentCoin: eth,
    );

    expect(resolution?.coinModel, same(usdc));
    expect(resolution?.recipient, '0xRecipient');
    expect(resolution?.amount, '2.5');
  });

  test('resolves native request by requested chain id', () {
    final eth = native(coinType: 'ETH', chainId: 1);
    final polygon = native(coinType: 'MATIC', chainId: 137);
    final request = Eip681.parse(
      'ethereum:0xRecipient@137?value=1230000000000000000',
    )!;

    final resolution = ScanToPayResolver.resolve(
      request: request,
      coinModels: [eth, polygon],
      currentCoin: eth,
    );

    expect(resolution?.coinModel, same(polygon));
    expect(resolution?.recipient, '0xRecipient');
    expect(resolution?.amount, '1.23');
  });

  test('does not resolve missing token instead of guessing', () {
    final eth = native(coinType: 'ETH', chainId: 1);
    final request = Eip681.parse(
      'ethereum:0xMissingToken@1'
      '/transfer?address=0xRecipient&uint256=1',
    )!;

    final resolution = ScanToPayResolver.resolve(
      request: request,
      coinModels: [eth],
      currentCoin: eth,
    );

    expect(resolution, isNull);
  });

  test('absent chain id resolves native to the current network', () {
    final eth = native(coinType: 'ETH', chainId: 1);
    final polygon = native(coinType: 'MATIC', chainId: 137);
    // 无 @chainId 的原生请求：按 EIP-681「当前所选网络」，应落到 currentCoin 所在链。
    final request = Eip681.parse('ethereum:0xRecipient?value=1000000000000000000')!;

    final resolution = ScanToPayResolver.resolve(
      request: request,
      coinModels: [eth, polygon],
      currentCoin: polygon,
    );

    expect(resolution?.coinModel, same(polygon));
    expect(resolution?.amount, '1');
  });

  test('absent chain id resolves ERC-20 on the current chain, not a same-address token on another chain', () {
    const shared = '0x0000000000000000000000000000000000000abc';
    final usdcEth = erc20(
      coinType: 'ETH',
      chainId: 1,
      contract: shared,
      decimals: 6,
    );
    final usdcPolygon = erc20(
      coinType: 'MATIC',
      chainId: 137,
      contract: shared,
      decimals: 6,
    );
    final polygonNative = native(coinType: 'MATIC', chainId: 137);
    // 同一合约地址在两条链都持有；无 @chainId → 按当前链(137)选，不能误选到链 1。
    final request = Eip681.parse(
      'ethereum:$shared/transfer?address=0xRecipient&uint256=2500000',
    )!;

    final resolution = ScanToPayResolver.resolve(
      request: request,
      coinModels: [usdcEth, usdcPolygon],
      currentCoin: polygonNative,
    );

    expect(resolution?.coinModel, same(usdcPolygon));
    expect(resolution?.amount, '2.5');
  });

  test('sameAsset separates native coins across chains', () {
    final eth = native(coinType: 'ETH', chainId: 1);
    final polygon = native(coinType: 'MATIC', chainId: 137);
    expect(ScanToPayResolver.sameAsset(eth, polygon), isFalse);
    expect(ScanToPayResolver.sameAsset(eth, eth), isTrue);
  });

  test('sameAsset separates contracts on the same chain', () {
    final usdc = erc20(
      coinType: 'ETH',
      chainId: 1,
      contract: '0x0000000000000000000000000000000000000001',
      decimals: 6,
    );
    final usdt = erc20(
      coinType: 'ETH',
      chainId: 1,
      contract: '0x0000000000000000000000000000000000000002',
      decimals: 6,
      miniName: 'USDT',
    );

    expect(ScanToPayResolver.sameAsset(usdc, usdt), isFalse);
    expect(ScanToPayResolver.sameAsset(usdc, usdc), isTrue);
  });
}
