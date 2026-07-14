// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/utils/feature_address_utils.dart';

String selectLoyaltyWalletAddress(Iterable<CoinModel> coins) {
  for (final preferredType in const ['N', 'ETH']) {
    for (final coin in coins) {
      final coinType = coin.coin['coinType']?.toString().toUpperCase();
      final address = coin.address?.toString();
      if (coinType == preferredType &&
          FeatureAddressUtils.isValidEvmAddress(address)) {
        return address!.trim();
      }
    }
  }
  for (final coin in coins) {
    final address = coin.address?.toString();
    if (FeatureAddressUtils.isValidEvmAddress(address)) {
      return address!.trim();
    }
  }
  return '';
}
