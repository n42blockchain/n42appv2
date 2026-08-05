import 'dart:math';

final RegExp _trailingZeros = RegExp(r'0+$');

/// A token found on-chain but not yet in the user's wallet.
class DiscoveredToken {
  final String coinType;        // internal chain key: ETH, BSC, SOL …
  final String blockchainType;  // Ethereum, Solana, …
  final String contractAddress; // EVM contract or Solana mint
  final String symbol;
  final String name;
  final int decimals;
  final BigInt rawBalance;

  /// Whether the user has selected this token in the review UI.
  bool isSelected;

  DiscoveredToken({
    required this.coinType,
    required this.blockchainType,
    required this.contractAddress,
    required this.symbol,
    required this.name,
    required this.decimals,
    required this.rawBalance,
    this.isSelected = true,
  });

  /// Human-readable balance string.
  String get humanBalance {
    if (rawBalance == BigInt.zero) return '0';
    if (decimals <= 0) return rawBalance.toString();
    final scale = BigInt.from(10).pow(decimals);
    final intPart = rawBalance ~/ scale;
    final fracPart = rawBalance % scale;
    if (fracPart == BigInt.zero) return intPart.toString();
    final fracStr = fracPart.toString().padLeft(decimals, '0');
    // Trim trailing zeros, keep at most 6 decimal places.
    final meaningful = fracStr
        .substring(0, min(6, fracStr.length))
        .replaceAll(_trailingZeros, '');
    if (meaningful.isEmpty) return intPart.toString();
    return '$intPart.$meaningful';
  }

  /// Display name: symbol if available, otherwise truncated contract address.
  String get displaySymbol =>
      symbol.isNotEmpty ? symbol : _truncateAddr(contractAddress);

  /// Display token name, fallback to contract address.
  String get displayName =>
      name.isNotEmpty ? name : contractAddress;

  /// Build the token map expected by [WalletActionProvider.addWalletChainToken].
  ///
  /// [chainBaseInfo] must be `walletMap[coinType]['baseInfo']`.
  Map<String, dynamic> toTokenMap(Map<String, dynamic> chainBaseInfo) {
    final base = Map<String, dynamic>.from(chainBaseInfo);
    base['isContract'] = true;
    base['contract'] = contractAddress;
    base['contract_test'] = '';
    base['balance'] = '0';
    base['balance_test'] = '0';
    base['coinPrice'] = 0.0;
    base['percentage'] = 0.0;
    base['name'] = displayName;
    base['miniName'] = displaySymbol;
    base['mKey'] = contractAddress.toUpperCase();
    base['unit'] = displaySymbol;
    base['decimals'] = decimals;
    base['decimals_verified'] = false;
    base['icon'] = '';
    base['customer'] = true;
    base['canEdit'] = true;
    return base;
  }

  static String _truncateAddr(String addr) {
    if (addr.length <= 12) return addr;
    return '${addr.substring(0, 6)}…${addr.substring(addr.length - 4)}';
  }
}
