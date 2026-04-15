// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// Off-ramp (crypto → fiat) service supporting multiple providers.
///
/// Provider priority:
/// 1. MoonPay Sell — widest coverage (100+ countries)
/// 2. Transak — additional payment methods
/// 3. Ramp Network — EU/UK focused
///
/// Each provider is accessed via WebView with server-side URL signing.
class OfframpService {
  OfframpService._();

  /// Available off-ramp providers.
  static const List<OfframpProvider> providers = [
    OfframpProvider(
      id: 'moonpay',
      name: 'MoonPay',
      baseUrl: 'https://n42.world/sell',
      supportedCurrencies: ['BTC', 'ETH', 'USDT', 'USDC', 'BNB', 'MATIC', 'SOL', 'AVAX'],
      supportedFiat: ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY', 'KRW', 'SGD', 'HKD', 'CHF'],
      minAmount: 20.0,
      maxAmount: 50000.0,
      payoutMethods: [PayoutMethod.bankTransfer, PayoutMethod.creditCard],
    ),
    OfframpProvider(
      id: 'transak',
      name: 'Transak',
      baseUrl: 'https://global.transak.com',
      supportedCurrencies: ['ETH', 'USDT', 'USDC', 'BTC', 'DAI'],
      supportedFiat: ['USD', 'EUR', 'GBP', 'INR'],
      minAmount: 30.0,
      maxAmount: 25000.0,
      payoutMethods: [PayoutMethod.bankTransfer],
    ),
  ];

  /// Get the best provider for a given crypto/fiat pair.
  static OfframpProvider? getBestProvider({
    required String cryptoCurrency,
    required String fiatCurrency,
  }) {
    final crypto = cryptoCurrency.toUpperCase();
    final fiat = fiatCurrency.toUpperCase();

    for (final provider in providers) {
      if (provider.supportedCurrencies.contains(crypto) &&
          provider.supportedFiat.contains(fiat)) {
        return provider;
      }
    }
    return null;
  }

  /// Build the sell/off-ramp URL for MoonPay.
  ///
  /// [cryptoCurrency] — the token to sell (e.g., 'ETH').
  /// [walletAddress] — user's wallet address for refund.
  /// [fiatCurrency] — desired fiat output (e.g., 'USD').
  /// [amount] — amount of crypto to sell (optional).
  static String buildMoonPaySellUrl({
    required String cryptoCurrency,
    required String walletAddress,
    String fiatCurrency = 'USD',
    double? amount,
  }) {
    final params = <String, String>{
      'defaultCurrencyCode': cryptoCurrency,
      'refundWalletAddress': walletAddress,
      'quoteCurrencyCode': fiatCurrency,
    };

    if (amount != null) {
      params['baseCurrencyAmount'] = amount.toString();
    }

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'https://n42.world/sell?$query';
  }

  /// Build the off-ramp URL for Transak.
  static String buildTransakSellUrl({
    required String cryptoCurrency,
    required String walletAddress,
    String fiatCurrency = 'USD',
    String network = 'ethereum',
  }) {
    final params = <String, String>{
      'apiKey': const String.fromEnvironment('TRANSAK_API_KEY'),
      'environment': 'PRODUCTION',
      'cryptoCurrencyCode': cryptoCurrency,
      'defaultFiatCurrency': fiatCurrency,
      'walletAddress': walletAddress,
      'network': network,
      'productsAvailed': 'SELL',
      'themeColor': '3b82f6',
    };

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'https://global.transak.com?$query';
  }

  /// Check if off-ramp is available for a given token.
  static bool isAvailable(String cryptoCurrency) {
    final crypto = cryptoCurrency.toUpperCase();
    return providers.any((p) => p.supportedCurrencies.contains(crypto));
  }

  /// Get all supported fiat currencies across all providers.
  static List<String> getAllSupportedFiat() {
    final fiat = <String>{};
    for (final provider in providers) {
      fiat.addAll(provider.supportedFiat);
    }
    return fiat.toList()..sort();
  }

  /// Get all supported crypto currencies for off-ramp.
  static List<String> getAllSupportedCrypto() {
    final crypto = <String>{};
    for (final provider in providers) {
      crypto.addAll(provider.supportedCurrencies);
    }
    return crypto.toList()..sort();
  }
}

/// Off-ramp provider configuration.
class OfframpProvider {
  final String id;
  final String name;
  final String baseUrl;
  final List<String> supportedCurrencies;
  final List<String> supportedFiat;
  final double minAmount;
  final double maxAmount;
  final List<PayoutMethod> payoutMethods;

  const OfframpProvider({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.supportedCurrencies,
    required this.supportedFiat,
    required this.minAmount,
    required this.maxAmount,
    required this.payoutMethods,
  });
}

/// Payout method for off-ramp.
enum PayoutMethod {
  /// Bank transfer (ACH, SEPA, Wire).
  bankTransfer,

  /// Credit/debit card refund.
  creditCard,

  /// PayPal.
  paypal,

  /// Mobile money (Africa/Asia).
  mobileMoney,
}
