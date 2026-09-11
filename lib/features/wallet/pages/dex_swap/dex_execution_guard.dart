import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_quote_model.dart';

bool isDexNativeToken(String address) => const {
  '0x0000000000000000000000000000000000000000',
  '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee',
}.contains(address.toLowerCase());

/// Resolve the selected chain's native signing context, never another EVM coin.
CoinModel? dexSigningCoin(Iterable<CoinModel> coins, String coinType) {
  for (final coin in coins) {
    if (coin.config.coinType == coinType &&
        coin.config.contract.isEmpty &&
        coin.config.blockchainType == 'Ethereum') {
      return coin;
    }
  }
  return null;
}

/// Native input attaches exactly the approved amount; ERC-20 input attaches zero.
/// Reject missing/foreign chains and extra backend-requested native transfers.
BigInt validatedDexValue({
  required DexQuoteModel quote,
  required String chain,
  required String tokenAddress,
  required BigInt amountIn,
}) {
  if (quote.chain != chain ||
      amountIn <= BigInt.zero ||
      !RegExp(r'^\d+$').hasMatch(quote.txValue)) {
    throw const FormatException('Invalid swap execution context');
  }
  final value = BigInt.parse(quote.txValue);
  final expected = isDexNativeToken(tokenAddress) ? amountIn : BigInt.zero;
  if (value.bitLength > 256 || value != expected) {
    throw const FormatException('Swap value does not match input');
  }
  return value;
}
