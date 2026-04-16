import 'dart:async';

import '../../domain/protocols/fiat_ramp_bridge.dart';
import '../utils/debug_log.dart';

/// 法币出入金服务。
///
/// 管理 MoonPay / Transak 的买入/卖出流程，提供统一 API。
/// 实际 URL 生成和 API 调用委托给 [FiatRampBridge]（由宿主注入）。
class FiatRampService {
  FiatRampService({this.bridge});

  FiatRampBridge? bridge;

  bool get isAvailable => bridge != null;

  /// 获取买入 URL 并返回，调用方负责打开 WebView。
  Future<FiatRampUrl?> startBuy({
    required String walletAddress,
    required String cryptoCurrency,
    String fiatCurrency = 'USD',
    double? fiatAmount,
    FiatRampProvider? provider,
  }) async {
    if (bridge == null) {
      debugLog('FiatRamp: bridge not configured');
      return null;
    }
    try {
      return await bridge!.getBuyUrl(
        walletAddress: walletAddress,
        cryptoCurrency: cryptoCurrency,
        fiatCurrency: fiatCurrency,
        fiatAmount: fiatAmount,
        provider: provider,
      );
    } catch (e) {
      debugLog('FiatRamp: startBuy failed - $e');
      return null;
    }
  }

  /// 获取卖出 URL。
  Future<FiatRampUrl?> startSell({
    required String walletAddress,
    required String cryptoCurrency,
    double? cryptoAmount,
    String fiatCurrency = 'USD',
    FiatRampProvider? provider,
  }) async {
    if (bridge == null) return null;
    try {
      return await bridge!.getSellUrl(
        walletAddress: walletAddress,
        cryptoCurrency: cryptoCurrency,
        cryptoAmount: cryptoAmount,
        fiatCurrency: fiatCurrency,
        provider: provider,
      );
    } catch (e) {
      debugLog('FiatRamp: startSell failed - $e');
      return null;
    }
  }

  /// 获取报价。
  Future<FiatRampQuote?> getQuote({
    required String cryptoCurrency,
    required String fiatCurrency,
    required double fiatAmount,
    required FiatRampType type,
    FiatRampProvider? provider,
  }) async {
    if (bridge == null) return null;
    try {
      return await bridge!.getQuote(
        cryptoCurrency: cryptoCurrency,
        fiatCurrency: fiatCurrency,
        fiatAmount: fiatAmount,
        type: type,
        provider: provider,
      );
    } catch (e) {
      debugLog('FiatRamp: getQuote failed - $e');
      return null;
    }
  }

  /// 获取支持的法币（缓存）。
  final Map<FiatRampProvider, List<String>> _fiatCache = {};

  Future<List<String>> getSupportedFiat(FiatRampProvider provider) async {
    if (_fiatCache.containsKey(provider)) return _fiatCache[provider]!;
    if (bridge == null) return const [];
    try {
      final list = await bridge!.getSupportedFiatCurrencies(provider);
      _fiatCache[provider] = list;
      return list;
    } catch (_) {
      return const [];
    }
  }
}
