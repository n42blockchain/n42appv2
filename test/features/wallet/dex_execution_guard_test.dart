import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_quote_model.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_execution_guard.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_quote_validity.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_constants.dart';

DexQuoteModel quote(String value, {String chain = 'ETH'}) =>
    DexQuoteModel.fromJson({'chain': chain, 'tx_value': value});
void main() {
  const native = '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee';
  test(
    'native swaps attach exact input including one wei; token swaps attach zero',
    () {
      final amount = BigInt.parse('1000000000000000001');
      expect(
        validatedDexValue(
          quote: quote('$amount'),
          chain: 'ETH',
          tokenAddress: native,
          amountIn: amount,
        ),
        amount,
      );
      expect(
        validatedDexValue(
          quote: quote('0'),
          chain: 'ETH',
          tokenAddress: '0xtoken',
          amountIn: amount,
        ),
        BigInt.zero,
      );
      for (final value in ['0', '1', '-1', '1.5', '1000000000000000002']) {
        expect(
          () => validatedDexValue(
            quote: quote(value),
            chain: 'ETH',
            tokenAddress: native,
            amountIn: amount,
          ),
          throwsFormatException,
        );
      }
      expect(
        () => validatedDexValue(
          quote: quote('1'),
          chain: 'ETH',
          tokenAddress: '0xtoken',
          amountIn: amount,
        ),
        throwsFormatException,
      );
      expect(
        () => validatedDexValue(
          quote: quote('0', chain: 'BSC'),
          chain: 'ETH',
          tokenAddress: '0xtoken',
          amountIn: amount,
        ),
        throwsFormatException,
      );
    },
  );
  test(
    'an account or derivation change invalidates even the same quote instance',
    () {
      final q = quote('0');
      final now = DateTime.now();
      expect(
        isCurrentDexQuote(
          confirmed: q,
          current: q,
          expiresAt: now.add(const Duration(seconds: 30)),
          now: now,
          confirmedAccountKey: ('wallet', 0, 'eoa'),
          currentAccountKey: ('wallet', 1, 'eoa'),
        ),
        isFalse,
      );
      expect(
        isCurrentDexQuote(
          confirmed: q,
          current: q,
          expiresAt: now.add(const Duration(seconds: 30)),
          now: now,
          confirmedAccountKey: ('wallet', 0, 'eoa'),
          currentAccountKey: ('wallet', 0, 'aa'),
        ),
        isFalse,
      );
    },
  );
  test(
    'signing context belongs to the selected native network, with no cross-chain fallback',
    () {
      CoinModel coin(String chain, String contract) => CoinModel()
        ..address = '0x$chain'
        ..coin = {
          'coinType': chain,
          'contract': contract,
          'blockchainType': 'Ethereum',
        };
      final eth = coin('ETH', '');
      final token = coin('BNB', '0xtoken');
      final bnb = coin('BNB', '');
      expect(dexSigningCoin([eth, token, bnb], 'BNB'), same(bnb));
      expect(dexSigningCoin([eth, token], 'BNB'), isNull);
    },
  );
  test(
    'negative and malformed decimal input cannot become a positive swap',
    () {
      for (final value in ['-0.5', '-.5', '+0.5', '1e3', 'NaN', '1..2']) {
        expect(dexToWei(value, 18), BigInt.zero);
      }
      expect(dexToWei('.5', 18), BigInt.parse('500000000000000000'));
      expect(
        dexToWei('1.000000000000000001', 18),
        BigInt.parse('1000000000000000001'),
      );
    },
  );
}
