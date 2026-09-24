/// The network represented by an N42 chain-aware payment request.
enum ChainPaymentNetwork { mainnet, testnet }

/// Whether a request targets the chain's native asset or a token.
enum ChainPaymentAssetType { native, token }

/// A normalized, chain-aware payment request carried by the N42 fallback URI.
class ChainPaymentRequest {
  final String chain;
  final ChainPaymentNetwork network;
  final ChainPaymentAssetType assetType;
  final String recipient;
  final String? contract;
  final String? amount;

  const ChainPaymentRequest({
    required this.chain,
    required this.network,
    required this.assetType,
    required this.recipient,
    this.contract,
    this.amount,
  });

  bool get isToken => assetType == ChainPaymentAssetType.token;

  @override
  bool operator ==(Object other) =>
      other is ChainPaymentRequest &&
      other.chain == chain &&
      other.network == network &&
      other.assetType == assetType &&
      other.recipient == recipient &&
      other.contract == contract &&
      other.amount == amount;

  @override
  int get hashCode =>
      Object.hash(chain, network, assetType, recipient, contract, amount);
}

/// Encoder/parser for the versioned `n42pay://v1/pay` fallback protocol.
///
/// Payment URIs are untrusted input. Unknown parameters and repeated keys are
/// rejected so an older parser cannot silently ignore identity-changing data.
class ChainPaymentUri {
  ChainPaymentUri._();

  static const String scheme = 'n42pay';
  static const String versionHost = 'v1';
  static const String route = '/pay';
  static const Set<String> _allowedKeys = {
    'chain',
    'network',
    'type',
    'to',
    'contract',
    'amount',
  };

  static String encode(ChainPaymentRequest request) {
    if (!isValidRequest(request)) {
      throw ArgumentError.value(request, 'request', 'Invalid payment request');
    }
    final query = <String, String>{
      'chain': request.chain.trim(),
      'network': request.network.name,
      'type': request.assetType.name,
      'to': request.recipient.trim(),
    };
    final contract = request.contract?.trim();
    if (contract != null && contract.isNotEmpty) query['contract'] = contract;
    final amount = request.amount?.trim();
    if (amount != null && amount.isNotEmpty) query['amount'] = amount;
    return Uri(
      scheme: scheme,
      host: versionHost,
      path: route,
      queryParameters: query,
    ).toString();
  }

  static ChainPaymentRequest? tryParse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (_containsMalformedEscape(trimmed)) return null;

    Uri uri;
    try {
      uri = Uri.parse(trimmed);
    } on FormatException {
      return null;
    }
    if (uri.scheme.toLowerCase() != scheme) {
      return _tryParseStandard(trimmed, uri);
    }
    final queryStart = trimmed.indexOf('?');
    if (queryStart < 0) return null;
    // Dart's Uri normalizes malformed '%' characters to '%25' before exposing
    // `query`; preserve the original query so malformed escapes can fail closed.
    final rawQuery = trimmed.substring(queryStart + 1);
    if (uri.scheme.toLowerCase() != scheme ||
        uri.host.toLowerCase() != versionHost ||
        uri.path != route ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort ||
        uri.hasFragment ||
        rawQuery.isEmpty) {
      return null;
    }

    final params = _parseQuery(rawQuery);
    if (params == null ||
        params.keys.any((key) => !_allowedKeys.contains(key))) {
      return null;
    }
    final chain = params['chain'];
    final networkText = params['network'];
    final typeText = params['type'];
    final recipient = params['to'];
    if (chain == null ||
        networkText == null ||
        typeText == null ||
        recipient == null) {
      return null;
    }

    final network = switch (networkText) {
      'mainnet' => ChainPaymentNetwork.mainnet,
      'testnet' => ChainPaymentNetwork.testnet,
      _ => null,
    };
    final assetType = switch (typeText) {
      'native' => ChainPaymentAssetType.native,
      'token' => ChainPaymentAssetType.token,
      _ => null,
    };
    if (network == null || assetType == null) return null;

    final request = ChainPaymentRequest(
      chain: chain,
      network: network,
      assetType: assetType,
      recipient: recipient,
      contract: params['contract'],
      amount: params['amount'],
    );
    return isValidRequest(request) ? request : null;
  }

  /// True when a scan uses a payment-request scheme handled by the wallet,
  /// including unknown versions that must be rejected instead of treated as
  /// ordinary addresses.
  static bool isSupportedPaymentScheme(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null) return false;
    return const {
      'n42pay',
      'n42',
      'ethereum',
      'bitcoin',
      'solana',
      'ton',
      'tron',
      'xrpl',
      'cosmos',
      'near',
    }.contains(uri.scheme.toLowerCase());
  }

  static ChainPaymentRequest? _tryParseStandard(String raw, Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (!isSupportedPaymentScheme(raw) ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort ||
        uri.hasFragment ||
        uri.hasAuthority) {
      return null;
    }

    final queryStart = raw.indexOf('?');
    final rawQuery = queryStart < 0 ? '' : raw.substring(queryStart + 1);
    final params = rawQuery.isEmpty
        ? <String, String>{}
        : _parseQuery(rawQuery);
    if (params == null) return null;
    final amount = params['amount'];
    if (amount != null && !_isPositiveDecimal(amount)) return null;

    String chain;
    String recipient;
    var network = ChainPaymentNetwork.mainnet;
    String? contract;
    final Set<String> allowedKeys;

    switch (scheme) {
      case 'bitcoin':
        chain = 'BTC';
        allowedKeys = const {'amount', 'tb', 'label', 'message'};
        final testnetRecipient = params['tb'];
        if (testnetRecipient != null) {
          if (uri.path.isNotEmpty || testnetRecipient.isEmpty) return null;
          recipient = testnetRecipient;
          network = ChainPaymentNetwork.testnet;
        } else {
          recipient = uri.path;
          // BIP-321 puts testnet SegWit addresses in `tb`, not in the body.
          // Legacy testnet Base58 addresses start with m/n (P2PKH) or 2
          // (P2SH), and regtest SegWit addresses use bcrt1. They must never be
          // silently relabeled as Bitcoin mainnet destinations.
          if (RegExp(
            r'^(?:tb1|bcrt1|[mn2])',
            caseSensitive: false,
          ).hasMatch(recipient)) {
            return null;
          }
        }
      case 'solana':
        chain = 'SOL';
        allowedKeys = const {'amount', 'spl-token'};
        recipient = uri.path;
        contract = params['spl-token'];
      case 'ton':
        chain = 'TON';
        allowedKeys = const {'amount'};
        const prefix = 'transfer/';
        if (!uri.path.startsWith(prefix)) return null;
        recipient = uri.path.substring(prefix.length);
      case 'tron':
        chain = 'TRX';
        allowedKeys = const {'amount'};
        recipient = uri.path;
      case 'xrpl':
        chain = 'XRP';
        allowedKeys = const {'amount'};
        recipient = uri.path;
      case 'cosmos':
        chain = 'ATOM';
        allowedKeys = const {'amount'};
        recipient = uri.path;
      case 'near':
        chain = 'NEAR';
        allowedKeys = const {'amount'};
        recipient = uri.path;
      default:
        return null;
    }

    if (params.keys.any((key) => !allowedKeys.contains(key))) return null;
    final request = ChainPaymentRequest(
      chain: chain,
      network: network,
      assetType: contract == null
          ? ChainPaymentAssetType.native
          : ChainPaymentAssetType.token,
      recipient: recipient,
      contract: contract,
      amount: amount,
    );
    return isValidRequest(request) ? request : null;
  }

  static bool isValidRequest(ChainPaymentRequest request) {
    final chain = request.chain.trim();
    final recipient = request.recipient.trim();
    if (!_isSafeField(chain) || !_isSafeField(recipient)) return false;

    final contract = request.contract?.trim();
    if (request.isToken) {
      if (contract == null || !_isSafeField(contract)) return false;
    } else if (contract != null && contract.isNotEmpty) {
      return false;
    }

    final amount = request.amount?.trim();
    if (amount != null && amount.isNotEmpty && !_isPositiveDecimal(amount)) {
      return false;
    }
    return true;
  }

  static bool _isSafeField(String value) =>
      value.isNotEmpty && !RegExp(r'[\s\u0000-\u001F\u007F]').hasMatch(value);

  static bool _isPositiveDecimal(String amount) {
    if (!RegExp(r'^\d+(?:\.\d+)?$').hasMatch(amount)) return false;
    return amount.replaceAll('.', '').contains(RegExp(r'[1-9]'));
  }

  static Map<String, String>? _parseQuery(String rawQuery) {
    final result = <String, String>{};
    for (final pair in rawQuery.split('&')) {
      if (pair.isEmpty || _containsMalformedEscape(pair)) return null;
      final separator = pair.indexOf('=');
      if (separator <= 0) return null;
      try {
        final key = Uri.decodeQueryComponent(pair.substring(0, separator));
        final value = Uri.decodeQueryComponent(pair.substring(separator + 1));
        if (key.isEmpty || result.containsKey(key)) return null;
        result[key] = value;
      } on FormatException {
        return null;
      }
    }
    return result;
  }

  static bool _containsMalformedEscape(String value) {
    for (var index = 0; index < value.length; index++) {
      if (value.codeUnitAt(index) != 0x25) continue;
      if (index + 2 >= value.length ||
          !_isHex(value.codeUnitAt(index + 1)) ||
          !_isHex(value.codeUnitAt(index + 2))) {
        return true;
      }
      index += 2;
    }
    return false;
  }

  static bool _isHex(int value) =>
      (value >= 0x30 && value <= 0x39) ||
      (value >= 0x41 && value <= 0x46) ||
      (value >= 0x61 && value <= 0x66);
}
