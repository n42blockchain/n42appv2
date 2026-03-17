import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SPUtil ignored token contracts', () {
    test(
      'preserves exact contract strings while trimming whitespace',
      () async {
        final spUtil = SPUtil();

        await spUtil.addIgnoredTokenContracts([
          '  So1MintAbC  ',
          '0xAbCdEf',
          '',
          '   ',
        ]);

        final contracts = await spUtil.getIgnoredTokenContracts();

        expect(contracts, contains('So1MintAbC'));
        expect(contracts, contains('0xAbCdEf'));
        expect(contracts, isNot(contains('')));
      },
    );
  });

  group('SPUtil market watchlist', () {
    test('normalizes legacy watchlist symbols on load', () async {
      SharedPreferences.setMockInitialValues({
        SPkey.marketWatchlist.name: '["ETH"," eth ","BTC","","btc"]',
      });

      final spUtil = SPUtil();
      final symbols = await spUtil.getMarketWatchlist();

      expect(symbols, ['eth', 'btc']);
    });

    test('persists market watchlist as lowercase unique symbols', () async {
      final spUtil = SPUtil();

      await spUtil.saveMarketWatchlist(['ETH', ' btc ', '', 'eth', 'BTC']);
      final symbols = await spUtil.getMarketWatchlist();

      expect(symbols, ['eth', 'btc']);
    });
  });
}
