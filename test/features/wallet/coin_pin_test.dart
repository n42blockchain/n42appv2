// Tests for token pin/unpin feature.
//
// Coverage:
//   - WalletInfo.pinnedCoins fromJson / toJson round-trip
//   - WalletInfo.pinnedCoins length cap (200 items)
//   - _coinPinKey logic (main coin vs contract vs empty coinType)
//   - _syncPinnedState with empty / non-empty pinnedCoins
//   - _elevatePinnedToTop stable ordering
//   - togglePinCoin full lifecycle (pin → unpin → cap → invalid key)
//   - pinnedCoinCount getter
//   - _rankScoreCached all 5 tiers + edge cases
//   - _saveToHistory keyword length validation (security fix)
//   - _buildCoinListView pinnedCount computation logic

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Minimal CoinModel stub (avoids platform-channel imports of the real class)
// ──────────────────────────────────────────────────────────────────────────────

class _FakeCoin {
  final Map<String, dynamic> coin;
  bool isPinned = false;
  double value = 0.0;

  _FakeCoin({required this.coin, this.value = 0.0});
}

// ──────────────────────────────────────────────────────────────────────────────
// Minimal fake that mirrors the pin logic in WalletActionProvider
// (lib/src/wallet/provider/wallet_action_provider.dart)
// ──────────────────────────────────────────────────────────────────────────────

class _FakePinProvider {
  final WalletInfo walletInfo;
  List<dynamic> coinList;

  _FakePinProvider({required this.walletInfo, required this.coinList});

  // Mirrors _coinPinKey
  String coinPinKey(_FakeCoin cm) {
    final coinType = cm.coin['coinType'] as String? ?? '';
    final miniName = cm.coin['miniName'] as String? ?? '';
    if (coinType.isEmpty) return '__invalid__';
    if (cm.coin['isContract'] == true) return '${coinType}_$miniName';
    return coinType;
  }

  // Mirrors _syncPinnedState
  void syncPinnedState() {
    if (walletInfo.pinnedCoins.isEmpty) {
      for (final c in coinList) {
        if (c is _FakeCoin) c.isPinned = false;
      }
      return;
    }
    final pinnedSet = Set<String>.from(walletInfo.pinnedCoins);
    for (final c in coinList) {
      if (c is _FakeCoin) {
        c.isPinned = pinnedSet.contains(coinPinKey(c));
      }
    }
  }

  // Mirrors _elevatePinnedToTop
  void elevatePinnedToTop() {
    if (walletInfo.pinnedCoins.isEmpty || coinList.isEmpty) return;
    final pinned = <dynamic>[];
    final others = <dynamic>[];
    for (final c in coinList) {
      if (c is _FakeCoin && c.isPinned) {
        pinned.add(c);
      } else {
        others.add(c);
      }
    }
    if (pinned.isEmpty) return;
    coinList
      ..clear()
      ..addAll(pinned)
      ..addAll(others);
  }

  // Mirrors togglePinCoin
  void togglePinCoin(_FakeCoin cm) {
    if (cm.coin['isAggregated'] == true) return;
    final key = coinPinKey(cm);
    if (key == '__invalid__') return;

    if (cm.isPinned) {
      walletInfo.pinnedCoins.remove(key);
      cm.isPinned = false;
    } else {
      if (walletInfo.pinnedCoins.length >= 200) return;
      walletInfo.pinnedCoins.add(key);
      cm.isPinned = true;
    }
    // simplified: just elevate (tests don't need full sort re-run)
    elevatePinnedToTop();
  }

  // Mirrors pinnedCoinCount getter
  int get pinnedCoinCount => walletInfo.pinnedCoins.length;
}

// ──────────────────────────────────────────────────────────────────────────────
// Mirrors _rankScoreCached in WalletSearchCoinState
// (lib/src/wallet/widgets/wallet_search_coin.dart)
// ──────────────────────────────────────────────────────────────────────────────

int _rankScoreCached(String sym, String name, String input) {
  if (sym == input) return 5;
  if (sym.startsWith(input)) return 4;
  if (name.startsWith(input)) return 3;
  if (sym.contains(input)) return 2;
  return 1;
}

// ──────────────────────────────────────────────────────────────────────────────
// Mirrors _saveToHistory validation in WalletSearchCoinState
// ──────────────────────────────────────────────────────────────────────────────

bool _shouldSaveKeyword(String keyword) {
  final kw = keyword.trim();
  return kw.isNotEmpty && kw.length <= 50;
}

// ──────────────────────────────────────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────────────────────────────────────

WalletInfo _makeWalletInfo({List<String>? pinnedCoins}) {
  final wi = WalletInfo.fromJson({
    'walletName': 'test',
    'mnemonic': null,
    'password': null,
    'privateKey': null,
    'UUID': 'uuid-001',
    'timestamp': '1000',
    'coinInfo': null,
    'coinSort': {'assets': -1, 'name': -1},
    'networkIndex': 0,
    'pinnedCoins': pinnedCoins ?? [],
    'faceBinding': null,
    'mainWallet': true,
  });
  return wi;
}

_FakeCoin _makeCoin(
  String coinType, {
  String miniName = '',
  bool isContract = false,
  bool isAggregated = false,
  double value = 0.0,
}) {
  return _FakeCoin(
    coin: {
      'coinType': coinType,
      'miniName': miniName.isEmpty ? coinType : miniName,
      'isContract': isContract,
      'isAggregated': isAggregated,
    },
    value: value,
  );
}

// ══════════════════════════════════════════════════════════════════════════════

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // WalletInfo.pinnedCoins — model serialisation
  // ──────────────────────────────────────────────────────────────────────────

  group('WalletInfo.pinnedCoins — fromJson / toJson', () {
    test('defaults to empty list when key absent', () {
      final wi = _makeWalletInfo();
      expect(wi.pinnedCoins, isEmpty);
    });

    test('round-trips a non-empty list correctly', () {
      final wi = _makeWalletInfo(pinnedCoins: ['ETH', 'BNB_USDT']);
      expect(wi.pinnedCoins, ['ETH', 'BNB_USDT']);

      final json = wi.toJson();
      final wi2 = WalletInfo.fromJson({
        ...json,
        'coinSort': {'assets': -1, 'name': -1},
        'networkIndex': 0,
        'mainWallet': true,
      });
      expect(wi2.pinnedCoins, ['ETH', 'BNB_USDT']);
    });

    test('caps at 200 items when JSON contains more', () {
      // Build 250-item list
      final oversized = List.generate(250, (i) => 'COIN_$i');
      final wi = WalletInfo.fromJson({
        'walletName': null,
        'mnemonic': null,
        'password': null,
        'privateKey': null,
        'UUID': null,
        'timestamp': null,
        'coinInfo': null,
        'coinSort': {'assets': -1, 'name': -1},
        'networkIndex': 0,
        'pinnedCoins': oversized,
        'faceBinding': null,
        'mainWallet': false,
      });
      expect(wi.pinnedCoins.length, 200,
          reason: 'must be capped to 200 regardless of input size');
    });

    test('null pinnedCoins field treated as empty', () {
      final wi = WalletInfo.fromJson({
        'walletName': null,
        'mnemonic': null,
        'password': null,
        'privateKey': null,
        'UUID': null,
        'timestamp': null,
        'coinInfo': null,
        'coinSort': {'assets': -1, 'name': -1},
        'networkIndex': 0,
        'pinnedCoins': null,
        'faceBinding': null,
        'mainWallet': false,
      });
      expect(wi.pinnedCoins, isEmpty);
    });

    test('toJson includes pinnedCoins key', () {
      final wi = _makeWalletInfo(pinnedCoins: ['SOL']);
      final json = wi.toJson();
      expect(json.containsKey('pinnedCoins'), isTrue);
      expect(json['pinnedCoins'], ['SOL']);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // _coinPinKey
  // ──────────────────────────────────────────────────────────────────────────

  group('_coinPinKey', () {
    late _FakePinProvider provider;

    setUp(() {
      provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(),
        coinList: [],
      );
    });

    test('main coin uses coinType only', () {
      final coin = _makeCoin('ETH', miniName: 'ETH', isContract: false);
      expect(provider.coinPinKey(coin), 'ETH');
    });

    test('contract token uses coinType_miniName', () {
      final coin = _makeCoin('ETH', miniName: 'USDT', isContract: true);
      expect(provider.coinPinKey(coin), 'ETH_USDT');
    });

    test('empty coinType returns __invalid__', () {
      final coin = _FakeCoin(
        coin: {'coinType': '', 'miniName': 'USDT', 'isContract': true},
      );
      expect(provider.coinPinKey(coin), '__invalid__');
    });

    test('missing coinType field returns __invalid__', () {
      final coin = _FakeCoin(
        coin: {'miniName': 'BNB', 'isContract': false},
      );
      expect(provider.coinPinKey(coin), '__invalid__');
    });

    test('contract token with empty miniName produces coinType_ suffix', () {
      // Edge case: isContract=true but miniName not set
      final coin = _FakeCoin(
        coin: {'coinType': 'ETH', 'miniName': '', 'isContract': true},
      );
      expect(provider.coinPinKey(coin), 'ETH_');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // _syncPinnedState
  // ──────────────────────────────────────────────────────────────────────────

  group('_syncPinnedState', () {
    test('clears all isPinned flags when pinnedCoins is empty', () {
      final eth = _makeCoin('ETH')..isPinned = true;
      final bnb = _makeCoin('BNB')..isPinned = true;
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(pinnedCoins: []),
        coinList: [eth, bnb],
      );
      provider.syncPinnedState();
      expect(eth.isPinned, isFalse);
      expect(bnb.isPinned, isFalse);
    });

    test('sets isPinned=true for matching coins', () {
      final eth = _makeCoin('ETH');
      final bnb = _makeCoin('BNB');
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(pinnedCoins: ['ETH']),
        coinList: [eth, bnb],
      );
      provider.syncPinnedState();
      expect(eth.isPinned, isTrue);
      expect(bnb.isPinned, isFalse);
    });

    test('syncs contract token correctly', () {
      final usdt = _makeCoin('ETH', miniName: 'USDT', isContract: true);
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(pinnedCoins: ['ETH_USDT']),
        coinList: [usdt],
      );
      provider.syncPinnedState();
      expect(usdt.isPinned, isTrue);
    });

    test('non-matching coins remain unpinned after sync', () {
      final sol = _makeCoin('SOL');
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(pinnedCoins: ['ETH']),
        coinList: [sol],
      );
      provider.syncPinnedState();
      expect(sol.isPinned, isFalse);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // _elevatePinnedToTop
  // ──────────────────────────────────────────────────────────────────────────

  group('_elevatePinnedToTop', () {
    test('no-op when pinnedCoins list is empty', () {
      final eth = _makeCoin('ETH');
      final bnb = _makeCoin('BNB');
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(pinnedCoins: []),
        coinList: [eth, bnb],
      );
      provider.elevatePinnedToTop();
      expect((provider.coinList[0] as _FakeCoin).coin['coinType'], 'ETH');
      expect((provider.coinList[1] as _FakeCoin).coin['coinType'], 'BNB');
    });

    test('no-op when coinList is empty', () {
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(pinnedCoins: ['ETH']),
        coinList: [],
      );
      // Should not throw
      expect(() => provider.elevatePinnedToTop(), returnsNormally);
      expect(provider.coinList, isEmpty);
    });

    test('elevates single pinned coin to front', () {
      final eth = _makeCoin('ETH')..isPinned = false;
      final bnb = _makeCoin('BNB')..isPinned = true;
      final sol = _makeCoin('SOL')..isPinned = false;
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(pinnedCoins: ['BNB']),
        coinList: [eth, bnb, sol],
      );
      provider.elevatePinnedToTop();
      expect((provider.coinList[0] as _FakeCoin).coin['coinType'], 'BNB');
      expect((provider.coinList[1] as _FakeCoin).coin['coinType'], 'ETH');
      expect((provider.coinList[2] as _FakeCoin).coin['coinType'], 'SOL');
    });

    test('preserves relative order within pinned group (stable)', () {
      final eth = _makeCoin('ETH')..isPinned = true;
      final bnb = _makeCoin('BNB')..isPinned = true;
      final sol = _makeCoin('SOL')..isPinned = false;
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(pinnedCoins: ['ETH', 'BNB']),
        coinList: [eth, bnb, sol],
      );
      provider.elevatePinnedToTop();
      // ETH was before BNB → stays before BNB
      expect((provider.coinList[0] as _FakeCoin).coin['coinType'], 'ETH');
      expect((provider.coinList[1] as _FakeCoin).coin['coinType'], 'BNB');
      expect((provider.coinList[2] as _FakeCoin).coin['coinType'], 'SOL');
    });

    test('no-op when all coins are pinned (no movement needed)', () {
      final eth = _makeCoin('ETH')..isPinned = true;
      final bnb = _makeCoin('BNB')..isPinned = true;
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(pinnedCoins: ['ETH', 'BNB']),
        coinList: [eth, bnb],
      );
      provider.elevatePinnedToTop();
      // pinned is non-empty but others is empty → early return, no change
      expect((provider.coinList[0] as _FakeCoin).coin['coinType'], 'ETH');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // togglePinCoin
  // ──────────────────────────────────────────────────────────────────────────

  group('togglePinCoin', () {
    test('pins an unpinned coin', () {
      final eth = _makeCoin('ETH');
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(),
        coinList: [eth],
      );
      provider.togglePinCoin(eth);
      expect(eth.isPinned, isTrue);
      expect(provider.walletInfo.pinnedCoins, contains('ETH'));
    });

    test('unpins a pinned coin', () {
      final eth = _makeCoin('ETH')..isPinned = true;
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(pinnedCoins: ['ETH']),
        coinList: [eth],
      );
      provider.togglePinCoin(eth);
      expect(eth.isPinned, isFalse);
      expect(provider.walletInfo.pinnedCoins, isNot(contains('ETH')));
    });

    test('pin → unpin → pin cycle works correctly', () {
      final bnb = _makeCoin('BNB');
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(),
        coinList: [bnb],
      );
      provider.togglePinCoin(bnb); // pin
      expect(bnb.isPinned, isTrue);
      provider.togglePinCoin(bnb); // unpin
      expect(bnb.isPinned, isFalse);
      provider.togglePinCoin(bnb); // pin again
      expect(bnb.isPinned, isTrue);
      expect(provider.walletInfo.pinnedCoins.where((k) => k == 'BNB').length, 1,
          reason: 'no duplicate keys should be added');
    });

    test('ignores aggregated coins', () {
      final agg = _makeCoin('ETH', isAggregated: true);
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(),
        coinList: [agg],
      );
      provider.togglePinCoin(agg);
      expect(agg.isPinned, isFalse);
      expect(provider.walletInfo.pinnedCoins, isEmpty);
    });

    test('ignores coins with invalid (empty) coinType', () {
      final bad = _FakeCoin(coin: {'coinType': '', 'miniName': 'X', 'isContract': false});
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(),
        coinList: [bad],
      );
      provider.togglePinCoin(bad);
      expect(bad.isPinned, isFalse);
      expect(provider.walletInfo.pinnedCoins, isEmpty);
    });

    test('enforces 200-coin cap — 201st pin is rejected', () {
      // Pre-fill 200 pins
      final keys = List.generate(200, (i) => 'COIN_$i');
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(pinnedCoins: keys),
        coinList: [],
      );
      final extra = _makeCoin('EXTRA');
      provider.coinList = [extra];
      provider.togglePinCoin(extra); // should be rejected
      expect(extra.isPinned, isFalse,
          reason: '201st coin must not be pinned');
      expect(provider.walletInfo.pinnedCoins.length, 200);
    });

    test('pinned coin elevates to top of list', () {
      final eth = _makeCoin('ETH');
      final bnb = _makeCoin('BNB');
      final sol = _makeCoin('SOL');
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(),
        coinList: [eth, bnb, sol],
      );
      provider.togglePinCoin(sol); // pin SOL (was last)
      expect((provider.coinList[0] as _FakeCoin).coin['coinType'], 'SOL',
          reason: 'pinned coin should move to front');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // pinnedCoinCount getter
  // ──────────────────────────────────────────────────────────────────────────

  group('pinnedCoinCount', () {
    test('returns 0 when no coins are pinned', () {
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(),
        coinList: [],
      );
      expect(provider.pinnedCoinCount, 0);
    });

    test('reflects current pinnedCoins list length', () {
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(pinnedCoins: ['ETH', 'BNB', 'SOL']),
        coinList: [],
      );
      expect(provider.pinnedCoinCount, 3);
    });

    test('updates immediately after pin operation', () {
      final eth = _makeCoin('ETH');
      final provider = _FakePinProvider(
        walletInfo: _makeWalletInfo(),
        coinList: [eth],
      );
      expect(provider.pinnedCoinCount, 0);
      provider.togglePinCoin(eth);
      expect(provider.pinnedCoinCount, 1);
      provider.togglePinCoin(eth);
      expect(provider.pinnedCoinCount, 0);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // _rankScoreCached — search relevance scoring
  // ──────────────────────────────────────────────────────────────────────────

  group('_rankScoreCached', () {
    test('exact symbol match returns 5', () {
      expect(_rankScoreCached('eth', 'ethereum', 'eth'), 5);
    });

    test('symbol prefix match returns 4', () {
      expect(_rankScoreCached('ethereum', 'ethereum', 'eth'), 4);
    });

    test('name prefix match returns 3', () {
      expect(_rankScoreCached('xyz', 'ethereum', 'eth'), 3);
    });

    test('symbol contains match returns 2', () {
      expect(_rankScoreCached('weth', 'wrapped ether', 'eth'), 2);
    });

    test('name contains match only returns 1', () {
      expect(_rankScoreCached('xyz', 'wrapped eth', 'eth'), 1);
    });

    test('exact beats prefix — same input "sol"', () {
      final exact = _rankScoreCached('sol', 'solana', 'sol');
      final prefix = _rankScoreCached('solana', 'solana', 'sol');
      expect(exact, greaterThan(prefix));
    });

    test('symbol prefix beats name prefix', () {
      final symPrefix = _rankScoreCached('eth', 'xxx', 'et');
      final namePrefix = _rankScoreCached('xxx', 'ethereum', 'et');
      expect(symPrefix, greaterThan(namePrefix));
    });

    test('name prefix beats symbol contains', () {
      final namePrefix = _rankScoreCached('xxx', 'usdcoin', 'usd');
      final symContains = _rankScoreCached('ausdc', 'xxx', 'usd');
      expect(namePrefix, greaterThan(symContains));
    });

    test('returns 1 for no match (defensive)', () {
      // Caller guarantees input already matched, but score still defined
      expect(_rankScoreCached('btc', 'bitcoin', 'eth'), 1);
    });

    test('case sensitivity — inputs already lowercased', () {
      // The calling site passes pre-lowercased sym/name/input
      expect(_rankScoreCached('usdt', 'tether usd', 'usdt'), 5);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // _saveToHistory keyword validation (security fix)
  // ──────────────────────────────────────────────────────────────────────────

  group('_saveToHistory keyword validation', () {
    test('empty string is rejected', () {
      expect(_shouldSaveKeyword(''), isFalse);
    });

    test('whitespace-only string is rejected', () {
      expect(_shouldSaveKeyword('   '), isFalse);
    });

    test('exactly 50-char keyword is accepted', () {
      expect(_shouldSaveKeyword('a' * 50), isTrue);
    });

    test('51-char keyword is rejected (security cap)', () {
      expect(_shouldSaveKeyword('a' * 51), isFalse);
    });

    test('normal keyword is accepted', () {
      expect(_shouldSaveKeyword('USDT'), isTrue);
    });

    test('keyword with leading/trailing spaces is valid after trim', () {
      // '  ETH  '.trim() = 'ETH' → valid
      expect(_shouldSaveKeyword('  ETH  '), isTrue);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // _buildCoinListView pinnedCount logic
  // ──────────────────────────────────────────────────────────────────────────

  group('_buildCoinListView pinnedCount computation', () {
    // This mirrors the computation in wallet_page.dart _buildCoinListView:
    //   break at the first non-pinned coin from the front.

    int computePinnedCount(List<_FakeCoin> list) {
      int count = 0;
      for (final c in list) {
        if (c.isPinned) {
          count++;
        } else {
          break;
        }
      }
      return count;
    }

    test('returns 0 when no coins are pinned', () {
      final coins = [_makeCoin('ETH'), _makeCoin('BNB')];
      expect(computePinnedCount(coins), 0);
    });

    test('returns 1 when only first coin is pinned', () {
      final coins = [
        _makeCoin('ETH')..isPinned = true,
        _makeCoin('BNB')..isPinned = false,
      ];
      expect(computePinnedCount(coins), 1);
    });

    test('returns 2 when first two coins are pinned', () {
      final coins = [
        _makeCoin('ETH')..isPinned = true,
        _makeCoin('BNB')..isPinned = true,
        _makeCoin('SOL')..isPinned = false,
      ];
      expect(computePinnedCount(coins), 2);
    });

    test('stops counting at first non-pinned (no gap scanning)', () {
      // Gap case: ETH unpinned, BNB pinned — only ETH is scanned
      final coins = [
        _makeCoin('ETH')..isPinned = false,
        _makeCoin('BNB')..isPinned = true,
      ];
      expect(computePinnedCount(coins), 0,
          reason: 'pinned coins are guaranteed to be at front after elevate');
    });

    test('needsDivider is false when no coins are pinned', () {
      final coins = [_makeCoin('ETH'), _makeCoin('BNB')];
      final pinCount = computePinnedCount(coins);
      final needsDivider = pinCount > 0 && pinCount < coins.length;
      expect(needsDivider, isFalse);
    });

    test('needsDivider is true when some (not all) coins are pinned', () {
      final coins = [
        _makeCoin('ETH')..isPinned = true,
        _makeCoin('BNB'),
      ];
      final pinCount = computePinnedCount(coins);
      final needsDivider = pinCount > 0 && pinCount < coins.length;
      expect(needsDivider, isTrue);
    });

    test('needsDivider is false when all coins are pinned (no separator needed)', () {
      final coins = [
        _makeCoin('ETH')..isPinned = true,
        _makeCoin('BNB')..isPinned = true,
      ];
      final pinCount = computePinnedCount(coins);
      final needsDivider = pinCount > 0 && pinCount < coins.length;
      expect(needsDivider, isFalse);
    });

    test('itemCount = list.length + 1 when divider is needed', () {
      final coins = [
        _makeCoin('ETH')..isPinned = true,
        _makeCoin('BNB'),
      ];
      final pinCount = computePinnedCount(coins);
      final needsDivider = pinCount > 0 && pinCount < coins.length;
      final itemCount = coins.length + (needsDivider ? 1 : 0);
      expect(itemCount, 3,
          reason: '2 coins + 1 divider row');
    });
  });
}
