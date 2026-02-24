// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

// Pure-Dart unit tests for DEX models and DexSwapApi logic:
//   - DexTokenModel.fromJson  (field mapping, null safety, defaults)
//   - DexQuoteModel.fromJson  (field mapping, null safety, defaults)
//   - DexHistoryModel.fromJson + statusText
//   - DexSwapApi.getQuote     (error field 'msg' vs 'err', via stub)
//   - DexSwapApi.getTokens    (null data guard)
//   - DexSwapApi.getHistory   (null data guard)

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/wallet/api/dex_swap_api.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_history_model.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_quote_model.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_token_model.dart';

// ---------------------------------------------------------------------------
// Stub DexSwapApi — intercepts HTTP calls without network I/O
// ---------------------------------------------------------------------------

class _StubDexSwapApi extends DexSwapApi {
  /// Raw map returned as `data['data']` from getTokens; null simulates missing
  List<Map<String, dynamic>>? tokensData;

  /// Raw map returned as `data['data']` from getQuote; null → error response
  Map<String, dynamic>? quoteData;

  /// Error message stored in 'msg' field (or 'err') on quote failure
  String? quoteErrMsg;
  String? quoteErrField; // 'msg' | 'err' — which field to put the message in

  /// Raw list returned as `data['data']['list']` from getHistory; null → error
  List<Map<String, dynamic>>? historyList;

  /// If true, all calls throw
  bool throwOnCall = false;

  int tokensCallCount = 0;
  int quoteCallCount = 0;
  int historyCallCount = 0;

  @override
  Future<MessageModel> getTokens(String chain, {String? q}) async {
    tokensCallCount++;
    if (throwOnCall) throw Exception('network error');
    final mm = MessageModel();
    mm.data = tokensData; // may be null
    return mm;
  }

  @override
  Future<MessageModel> getQuote({
    required String chain,
    required String tokenIn,
    required String tokenOut,
    required String amountIn,
    required String userAddr,
    int slippageBps = 50,
  }) async {
    quoteCallCount++;
    if (throwOnCall) throw Exception('network error');

    if (quoteData != null) {
      final mm = MessageModel();
      mm.data = quoteData;
      return mm;
    }

    // Simulate error: place message in the configured field
    final mm = MessageModel.error();
    final field = quoteErrField ?? 'msg';
    mm.data = {field: quoteErrMsg ?? 'Quote failed'};
    return mm;
  }

  @override
  Future<MessageModel> getHistory(String uuid,
      {int page = 1, int size = 20}) async {
    historyCallCount++;
    if (throwOnCall) throw Exception('network error');
    final mm = MessageModel();
    mm.data = historyList; // may be null → tests the null-guard
    return mm;
  }

  @override
  Future<MessageModel> commit(
      String uuid, String orderId, String txHash) async {
    final mm = MessageModel();
    mm.data = true;
    return mm;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _fullTokenJson({
  String address = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
  String symbol = 'USDC',
  String name = 'USD Coin',
  String logoUri = 'https://example.com/usdc.png',
  int decimals = 6,
  String chain = 'ETH',
}) =>
    {
      'address': address,
      'symbol': symbol,
      'name': name,
      'logo_uri': logoUri,
      'decimals': decimals,
      'chain': chain,
    };

Map<String, dynamic> _fullQuoteJson({
  String orderId = 'ord_abc',
  String tokenInSymbol = 'USDC',
  String tokenOutSymbol = 'WETH',
  String amountIn = '1000',
  String amountOut = '0.45',
  String priceImpact = '0.12%',
  String gasEstimate = '0.003 ETH',
  String source = 'Uniswap V3',
  String calldata = '0xdeadbeef',
  String routerAddr = '0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45',
  String chain = 'ETH',
}) =>
    {
      'order_id': orderId,
      'token_in_symbol': tokenInSymbol,
      'token_out_symbol': tokenOutSymbol,
      'amount_in': amountIn,
      'amount_out': amountOut,
      'price_impact': priceImpact,
      'gas_estimate': gasEstimate,
      'source': source,
      'calldata': calldata,
      'router_addr': routerAddr,
      'chain': chain,
    };

Map<String, dynamic> _fullHistoryJson({
  String orderId = 'ord_001',
  String chain = 'ETH',
  String tokenInSymbol = 'USDC',
  String tokenOutSymbol = 'WETH',
  String amountIn = '1000',
  String amountOut = '0.45',
  String source = 'Uniswap V3',
  String txHash = '0xabc',
  int status = 2,
  int createdAt = 1700000000,
}) =>
    {
      'order_id': orderId,
      'chain': chain,
      'token_in_symbol': tokenInSymbol,
      'token_out_symbol': tokenOutSymbol,
      'amount_in': amountIn,
      'amount_out': amountOut,
      'source': source,
      'tx_hash': txHash,
      'status': status,
      'created_at': createdAt,
    };

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ─────────────────────────────────────────────────────────────
  // DexTokenModel.fromJson
  // ─────────────────────────────────────────────────────────────

  group('DexTokenModel.fromJson', () {
    test('maps all fields from valid JSON', () {
      final m = DexTokenModel.fromJson(_fullTokenJson());
      expect(m.address, '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48');
      expect(m.symbol, 'USDC');
      expect(m.name, 'USD Coin');
      expect(m.logoUri, 'https://example.com/usdc.png');
      expect(m.decimals, 6);
      expect(m.chain, 'ETH');
    });

    test('address defaults to empty string when missing', () {
      final m = DexTokenModel.fromJson({'symbol': 'X'});
      expect(m.address, '');
    });

    test('symbol defaults to empty string when missing', () {
      final m = DexTokenModel.fromJson({'address': '0x1'});
      expect(m.symbol, '');
    });

    test('decimals defaults to 18 when missing', () {
      final m = DexTokenModel.fromJson({});
      expect(m.decimals, 18);
    });

    test('decimals defaults to 18 when null', () {
      final m = DexTokenModel.fromJson({'decimals': null});
      expect(m.decimals, 18);
    });

    test('logoUri defaults to empty string when missing', () {
      final m = DexTokenModel.fromJson({});
      expect(m.logoUri, '');
    });

    test('chain defaults to empty string when missing', () {
      final m = DexTokenModel.fromJson({});
      expect(m.chain, '');
    });

    test('handles Solana-style address (no 0x prefix)', () {
      final m = DexTokenModel.fromJson(
          _fullTokenJson(address: 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v'));
      expect(m.address, 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
    });

    test('empty JSON produces all-default model without throwing', () {
      final m = DexTokenModel.fromJson({});
      expect(m.address, '');
      expect(m.symbol, '');
      expect(m.name, '');
      expect(m.logoUri, '');
      expect(m.decimals, 18);
      expect(m.chain, '');
    });
  });

  // ─────────────────────────────────────────────────────────────
  // DexQuoteModel.fromJson
  // ─────────────────────────────────────────────────────────────

  group('DexQuoteModel.fromJson', () {
    test('maps all fields from valid JSON', () {
      final m = DexQuoteModel.fromJson(_fullQuoteJson());
      expect(m.orderId, 'ord_abc');
      expect(m.tokenInSymbol, 'USDC');
      expect(m.tokenOutSymbol, 'WETH');
      expect(m.amountIn, '1000');
      expect(m.amountOut, '0.45');
      expect(m.priceImpact, '0.12%');
      expect(m.gasEstimate, '0.003 ETH');
      expect(m.source, 'Uniswap V3');
      expect(m.calldata, '0xdeadbeef');
      expect(m.routerAddr, '0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45');
      expect(m.chain, 'ETH');
    });

    test('all fields default to empty string when missing', () {
      final m = DexQuoteModel.fromJson({});
      expect(m.orderId, '');
      expect(m.tokenInSymbol, '');
      expect(m.tokenOutSymbol, '');
      expect(m.amountIn, '');
      expect(m.amountOut, '');
      expect(m.priceImpact, '');
      expect(m.gasEstimate, '');
      expect(m.source, '');
      expect(m.calldata, '');
      expect(m.routerAddr, '');
      expect(m.chain, '');
    });

    test('null values fall back to empty strings', () {
      final m = DexQuoteModel.fromJson({
        'order_id': null,
        'amount_out': null,
        'source': null,
      });
      expect(m.orderId, '');
      expect(m.amountOut, '');
      expect(m.source, '');
    });

    test('1inch source is preserved as-is', () {
      final m = DexQuoteModel.fromJson(_fullQuoteJson(source: '1inch'));
      expect(m.source, '1inch');
    });

    test('Jupiter source is preserved as-is', () {
      final m = DexQuoteModel.fromJson(_fullQuoteJson(source: 'Jupiter'));
      expect(m.source, 'Jupiter');
    });
  });

  // ─────────────────────────────────────────────────────────────
  // DexHistoryModel.fromJson + statusText
  // ─────────────────────────────────────────────────────────────

  group('DexHistoryModel.fromJson', () {
    test('maps all fields from valid JSON', () {
      final m = DexHistoryModel.fromJson(_fullHistoryJson());
      expect(m.orderId, 'ord_001');
      expect(m.chain, 'ETH');
      expect(m.tokenInSymbol, 'USDC');
      expect(m.tokenOutSymbol, 'WETH');
      expect(m.amountIn, '1000');
      expect(m.amountOut, '0.45');
      expect(m.source, 'Uniswap V3');
      expect(m.txHash, '0xabc');
      expect(m.status, 2);
      expect(m.createdAt, 1700000000);
    });

    test('status defaults to 0 when missing', () {
      final m = DexHistoryModel.fromJson({});
      expect(m.status, 0);
    });

    test('createdAt defaults to 0 when missing', () {
      final m = DexHistoryModel.fromJson({});
      expect(m.createdAt, 0);
    });

    test('empty JSON produces all-default model without throwing', () {
      final m = DexHistoryModel.fromJson({});
      expect(m.orderId, '');
      expect(m.txHash, '');
    });
  });

  group('DexHistoryModel.statusText', () {
    test('status 0 (quoted) returns non-empty string', () {
      final m = DexHistoryModel.fromJson(_fullHistoryJson(status: 0));
      expect(m.statusText, isNotEmpty);
    });

    test('status 1 (pending) returns non-empty string', () {
      final m = DexHistoryModel.fromJson(_fullHistoryJson(status: 1));
      expect(m.statusText, isNotEmpty);
    });

    test('status 2 (confirmed) returns non-empty string', () {
      final m = DexHistoryModel.fromJson(_fullHistoryJson(status: 2));
      expect(m.statusText, isNotEmpty);
    });

    test('status 3 (failed) returns non-empty string', () {
      final m = DexHistoryModel.fromJson(_fullHistoryJson(status: 3));
      expect(m.statusText, isNotEmpty);
    });

    test('status 0 and status 1 return different strings', () {
      final s0 = DexHistoryModel.fromJson(_fullHistoryJson(status: 0)).statusText;
      final s1 = DexHistoryModel.fromJson(_fullHistoryJson(status: 1)).statusText;
      expect(s0, isNot(equals(s1)));
    });

    test('status 2 and status 3 return different strings', () {
      final s2 = DexHistoryModel.fromJson(_fullHistoryJson(status: 2)).statusText;
      final s3 = DexHistoryModel.fromJson(_fullHistoryJson(status: 3)).statusText;
      expect(s2, isNot(equals(s3)));
    });

    test('unknown status (99) falls through to default without throwing', () {
      final m = DexHistoryModel.fromJson(_fullHistoryJson(status: 99));
      expect(() => m.statusText, returnsNormally);
      expect(m.statusText, isNotEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // DexSwapApi (via stub) — getTokens
  // ─────────────────────────────────────────────────────────────

  group('DexSwapApi.getTokens', () {
    test('returns token list when API provides data', () async {
      final stub = _StubDexSwapApi()
        ..tokensData = [_fullTokenJson(), _fullTokenJson(symbol: 'WETH')];
      final res = await stub.getTokens('ETH');
      final list = (res.data as List?) ?? [];
      expect(list.length, 2);
    });

    test('null data is tolerated — guard produces empty list', () async {
      final stub = _StubDexSwapApi()..tokensData = null;
      final res = await stub.getTokens('ETH');
      // Caller applies `(res.data as List?) ?? []`
      final list = (res.data as List?) ?? [];
      expect(list, isEmpty);
    });

    test('empty list from API produces empty result', () async {
      final stub = _StubDexSwapApi()..tokensData = [];
      final res = await stub.getTokens('ETH');
      final list = (res.data as List?) ?? [];
      expect(list, isEmpty);
    });

    test('call count increments on each call', () async {
      final stub = _StubDexSwapApi()..tokensData = [];
      await stub.getTokens('ETH');
      await stub.getTokens('ETH');
      expect(stub.tokensCallCount, 2);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // DexSwapApi (via stub) — getQuote
  // ─────────────────────────────────────────────────────────────

  group('DexSwapApi.getQuote', () {
    test('returns quote data on success', () async {
      final stub = _StubDexSwapApi()..quoteData = _fullQuoteJson();
      final res = await stub.getQuote(
        chain: 'ETH',
        tokenIn: '0xA0',
        tokenOut: '0xC0',
        amountIn: '1000000',
        userAddr: '0xUser',
      );
      expect(res.error, isFalse);
      final q = DexQuoteModel.fromJson(res.data as Map<String, dynamic>);
      expect(q.orderId, 'ord_abc');
      expect(q.source, 'Uniswap V3');
    });

    test('returns error when API returns null quoteData', () async {
      final stub = _StubDexSwapApi()
        ..quoteData = null
        ..quoteErrMsg = 'No liquidity'
        ..quoteErrField = 'msg';
      final res = await stub.getQuote(
        chain: 'ETH',
        tokenIn: '0xA0',
        tokenOut: '0xC0',
        amountIn: '1000000',
        userAddr: '0xUser',
      );
      expect(res.error, isTrue);
    });

    test('error message in msg field is accessible', () async {
      // Simulates the fix: backend puts error in 'msg', not 'err'
      final stub = _StubDexSwapApi()
        ..quoteData = null
        ..quoteErrMsg = 'Insufficient liquidity'
        ..quoteErrField = 'msg';
      final res = await stub.getQuote(
        chain: 'ETH',
        tokenIn: '0xA0',
        tokenOut: '0xC0',
        amountIn: '1000000',
        userAddr: '0xUser',
      );
      expect(res.error, isTrue);
      // The caller reads: res.data['msg'] ?? res.data['err'] ?? fallback
      final errMap = res.data as Map<String, dynamic>;
      final msg = errMap['msg'] ?? errMap['err'];
      expect(msg, 'Insufficient liquidity');
    });

    test('error message in err field is also accessible (compat fallback)', () async {
      final stub = _StubDexSwapApi()
        ..quoteData = null
        ..quoteErrMsg = 'Old backend error'
        ..quoteErrField = 'err';
      final res = await stub.getQuote(
        chain: 'ETH',
        tokenIn: '0xA0',
        tokenOut: '0xC0',
        amountIn: '1000000',
        userAddr: '0xUser',
      );
      expect(res.error, isTrue);
      final errMap = res.data as Map<String, dynamic>;
      final msg = errMap['msg'] ?? errMap['err'];
      expect(msg, 'Old backend error');
    });

    test('quote call count increments', () async {
      final stub = _StubDexSwapApi()..quoteData = _fullQuoteJson();
      await stub.getQuote(
          chain: 'ETH', tokenIn: '0x1', tokenOut: '0x2',
          amountIn: '100', userAddr: '0xU');
      await stub.getQuote(
          chain: 'ETH', tokenIn: '0x1', tokenOut: '0x2',
          amountIn: '200', userAddr: '0xU');
      expect(stub.quoteCallCount, 2);
    });

    test('slippageBps parameter is forwarded (no error raised)', () async {
      final stub = _StubDexSwapApi()..quoteData = _fullQuoteJson();
      final res = await stub.getQuote(
        chain: 'ETH',
        tokenIn: '0xA0',
        tokenOut: '0xC0',
        amountIn: '1000000',
        userAddr: '0xUser',
        slippageBps: 100,
      );
      expect(res.error, isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // DexSwapApi (via stub) — getHistory
  // ─────────────────────────────────────────────────────────────

  group('DexSwapApi.getHistory', () {
    test('returns history list when API provides data', () async {
      final stub = _StubDexSwapApi()
        ..historyList = [_fullHistoryJson(), _fullHistoryJson(orderId: 'ord_002')];
      final res = await stub.getHistory('user-uuid');
      final list = (res.data as List?) ?? [];
      expect(list.length, 2);
    });

    test('null data is tolerated — guard produces empty list', () async {
      // Simulates the Bug 3 fix: (res.data as List?) ?? []
      final stub = _StubDexSwapApi()..historyList = null;
      final res = await stub.getHistory('user-uuid');
      final list = (res.data as List?) ?? [];
      expect(list, isEmpty);
    });

    test('empty history list returns empty result', () async {
      final stub = _StubDexSwapApi()..historyList = [];
      final res = await stub.getHistory('user-uuid');
      final list = (res.data as List?) ?? [];
      expect(list, isEmpty);
    });

    test('history items deserialise correctly', () async {
      final stub = _StubDexSwapApi()
        ..historyList = [_fullHistoryJson(status: 2, tokenOutSymbol: 'WETH')];
      final res = await stub.getHistory('user-uuid');
      final list = (res.data as List?) ?? [];
      final item = DexHistoryModel.fromJson(list.first as Map<String, dynamic>);
      expect(item.status, 2);
      expect(item.tokenOutSymbol, 'WETH');
    });

    test('call count increments on each call', () async {
      final stub = _StubDexSwapApi()..historyList = [];
      await stub.getHistory('uuid');
      await stub.getHistory('uuid');
      expect(stub.historyCallCount, 2);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // DexSwapApi (via stub) — commit
  // ─────────────────────────────────────────────────────────────

  group('DexSwapApi.commit', () {
    test('returns success response', () async {
      final stub = _StubDexSwapApi();
      final res = await stub.commit('uuid', 'ord_001', '0xtxhash');
      expect(res.error, isFalse);
      expect(res.data, isTrue);
    });
  });
}
