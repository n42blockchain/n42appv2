// ── DEX Swap shared constants ──────────────────────────────────────────────
//
// Extracted from dex_swap_home.dart to keep each file ≤500 lines.
// All values are package-private (library-visible) — no public export needed.

/// DEX chain label → backend chain value → app-internal coinType for RPC calls.
const List<Map<String, String>> kDexSupportedChains = [
  {'label': 'ETH', 'value': 'ETH', 'coinType': 'ETH'},
  {'label': 'BSC', 'value': 'BSC', 'coinType': 'BNB'},
  {'label': 'Polygon', 'value': 'POLYGON', 'coinType': 'MATIC'},
  {'label': 'ARB', 'value': 'ARB', 'coinType': 'ARB'},
  {'label': 'OP', 'value': 'OP', 'coinType': 'OP'},
  {'label': 'BASE', 'value': 'BASE', 'coinType': 'BASE'},
];

/// Lookup coinType for a given DEX chain value.
String dexCoinTypeForChain(String dexChain) {
  return kDexSupportedChains.firstWhere(
    (c) => c['value'] == dexChain,
    orElse: () => {'coinType': dexChain},
  )['coinType']!;
}

/// Seconds before a fetched quote is considered stale and auto-refreshed.
const int kDexQuoteTtlSeconds = 30;

/// Convert a human-readable decimal amount string to wei (smallest unit).
///
/// Uses pure integer arithmetic to avoid double precision issues.
/// e.g. "1.23456789012345678" with 18 decimals → correct BigInt
BigInt dexToWei(String amount, int decimals) {
  try {
    final trimmed = amount.trim();
    if (trimmed.isEmpty) return BigInt.zero;

    final dotIdx = trimmed.indexOf('.');
    final String intStr;
    String fracStr;

    if (dotIdx == -1) {
      intStr = trimmed;
      fracStr = '';
    } else {
      intStr = trimmed.substring(0, dotIdx);
      fracStr = trimmed.substring(dotIdx + 1);
    }

    // Trim or pad fractional part to exactly [decimals] digits
    if (fracStr.length > decimals) {
      fracStr = fracStr.substring(0, decimals);
    } else {
      fracStr = fracStr.padRight(decimals, '0');
    }

    final intPart = BigInt.parse(intStr.isEmpty ? '0' : intStr);
    final fracPart = BigInt.parse(fracStr.isEmpty ? '0' : fracStr);
    final multiplier = BigInt.from(10).pow(decimals);

    final result = intPart * multiplier + fracPart;
    return result > BigInt.zero ? result : BigInt.zero;
  } catch (_) {
    return BigInt.zero;
  }
}

/// Symbol → CoinGecko ID mapping for common DeFi tokens.
/// Used to fetch price chart data. Unmapped tokens show no chart.
const Map<String, String> kDexSymbolToGeckoId = {
  'ETH': 'ethereum',
  'WETH': 'weth',
  'BTC': 'bitcoin',
  'WBTC': 'wrapped-bitcoin',
  'BNB': 'binancecoin',
  'MATIC': 'matic-network',
  'SOL': 'solana',
  'USDC': 'usd-coin',
  'USDT': 'tether',
  'DAI': 'dai',
  'ARB': 'arbitrum',
  'OP': 'optimism',
  'LINK': 'chainlink',
  'UNI': 'uniswap',
  'AAVE': 'aave',
  'CRV': 'curve-dao-token',
  'MKR': 'maker',
  'SNX': 'synthetix-network-token',
  'PEPE': 'pepe',
  'SHIB': 'shiba-inu',
  'DOGE': 'dogecoin',
};
