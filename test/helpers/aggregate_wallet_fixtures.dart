import 'package:n42_wallet/features/wallet/models/coin_model.dart';

CoinModel aggregateMainFixture({bool test = false}) => CoinModel()
  ..coin = {
    'coinType': 'ETH',
    'name': 'Ethereum',
    'blockchainType': 'Ethereum',
    'chainId': 1,
    'miniName': 'ETH',
    'unit': 'ETH',
    'decimals': 18,
  }
  ..isTest = test
  ..address = '0x0000000000000000000000000000000000000001';

CoinModel aggregateSourceFixture() => aggregateMainFixture()
  ..coin.addAll({
    'miniName': 'USDT',
    'unit': 'USDT',
    'name': 'Tether USD',
    'isContract': true,
    'decimals': 6,
    'contract': '0xdAC17F958D2ee523a2206206994597C13D831ec7',
  });
