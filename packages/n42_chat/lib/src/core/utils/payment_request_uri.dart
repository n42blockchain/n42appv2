/// 收款请求二维码载荷（商户收款码）。
class PaymentRequestData {
  /// 收款地址。
  final String receiverAddress;

  /// 金额（空字符串表示开放金额，由付款方填写）。
  final String amount;

  /// 仅用于显示的代币符号；不能作为资产选择依据。
  final String token;

  /// 备注 / 订单号。
  final String? memo;

  /// 稳定的链标识（例如内部链 mKey）。
  final String? chain;

  /// `mainnet` 或 `testnet`。
  final String? network;

  /// `native` 或 `token`。
  final String? assetType;

  /// Token 合约或 mint。Native 资产必须为空。
  final String? assetId;

  /// True for recognized legacy formats that lack a complete asset identity.
  final bool isLegacy;

  const PaymentRequestData({
    required this.receiverAddress,
    this.amount = '',
    this.token = '',
    this.memo,
    this.chain,
    this.network,
    this.assetType,
    this.assetId,
    this.isLegacy = false,
  });

  bool get hasAmount => amount.trim().isNotEmpty;

  bool get hasUnambiguousAsset =>
      !isLegacy &&
      chain?.trim().isNotEmpty == true &&
      (network == 'mainnet' || network == 'testnet') &&
      (assetType == 'native' ||
          (assetType == 'token' && assetId?.trim().isNotEmpty == true));

  @override
  bool operator ==(Object other) =>
      other is PaymentRequestData &&
      other.receiverAddress == receiverAddress &&
      other.amount == amount &&
      other.token == token &&
      other.memo == memo &&
      other.chain == chain &&
      other.network == network &&
      other.assetType == assetType &&
      other.assetId == assetId &&
      other.isLegacy == isLegacy;

  @override
  int get hashCode => Object.hash(
    receiverAddress,
    amount,
    token,
    memo,
    chain,
    network,
    assetType,
    assetId,
    isLegacy,
  );
}

/// Versioned payment URI codec; legacy routes remain readable for migration.
///
/// Versioned shape:
/// `n42pay://v1/pay?chain=...&network=...&type=native|token&to=...`.
class PaymentRequestUri {
  PaymentRequestUri._();

  static const String scheme = 'n42pay';
  static final RegExp _positiveAmount = RegExp(r'^\d+(?:\.\d+)?$');
  static final RegExp _malformedEscape = RegExp(r'%(?![0-9a-fA-F]{2})');
  static final RegExp _evmContract = RegExp(r'^0x[0-9a-fA-F]{40}$');

  /// Validates a positive display-unit amount against the selected asset's
  /// precision so sending code cannot silently truncate excess decimals.
  static bool isPositiveAmountForDecimals(String amount, int decimals) {
    final normalized = amount.trim();
    if (decimals < 0 || !_isPositiveAmount(normalized)) return false;
    final point = normalized.indexOf('.');
    return point < 0 || normalized.length - point - 1 <= decimals;
  }

  /// EVM contract addresses are case-insensitive; other chain identifiers
  /// (including Solana mints) remain case-sensitive.
  static bool sameAssetId(String? left, String? right) {
    final normalizedLeft = left?.trim();
    final normalizedRight = right?.trim();
    if (normalizedLeft == null || normalizedRight == null) return false;
    if (_evmContract.hasMatch(normalizedLeft) &&
        _evmContract.hasMatch(normalizedRight)) {
      return normalizedLeft.toLowerCase() == normalizedRight.toLowerCase();
    }
    return normalizedLeft == normalizedRight;
  }

  static String encode(PaymentRequestData data) {
    final receiver = data.receiverAddress.trim();
    if (receiver.isEmpty) {
      throw ArgumentError.value(receiver, 'receiverAddress');
    }
    final amount = data.amount.trim();
    if (amount.isNotEmpty && !_isPositiveAmount(amount)) {
      throw ArgumentError.value(amount, 'amount');
    }

    if (_hasVersionedIdentity(data)) {
      if (data.assetType == 'token' &&
          data.assetId?.trim().isNotEmpty != true) {
        throw ArgumentError.value(data.assetId, 'assetId');
      }
      if (data.assetType == 'native' &&
          data.assetId?.trim().isNotEmpty == true) {
        throw ArgumentError.value(data.assetId, 'assetId');
      }
      final params = <String, String>{
        'to': receiver,
        'chain': data.chain!.trim(),
        'network': data.network!,
        'type': data.assetType!,
      };
      if (data.assetId?.trim().isNotEmpty == true) {
        params['contract'] = data.assetId!.trim();
      }
      if (amount.isNotEmpty) params['amount'] = amount;
      if (data.token.trim().isNotEmpty) params['token'] = data.token.trim();
      final memo = data.memo?.trim();
      if (memo != null && memo.isNotEmpty) params['memo'] = memo;
      return Uri(
        scheme: scheme,
        host: 'v1',
        path: '/pay',
        queryParameters: params,
      ).toString();
    }

    // Legacy output is retained for existing integrations that have no chain
    // identity. The app's merchant QR supplies full metadata and emits v1.
    final params = <String, String>{'to': receiver};
    if (amount.isNotEmpty) params['amount'] = amount;
    if (data.token.trim().isNotEmpty) params['token'] = data.token.trim();
    final memo = data.memo?.trim();
    if (memo != null && memo.isNotEmpty) params['memo'] = memo;
    final chain = data.chain?.trim();
    if (chain != null && chain.isNotEmpty) params['chain'] = chain;
    return Uri(scheme: scheme, host: 'pay', queryParameters: params).toString();
  }

  static PaymentRequestData? tryParse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || _malformedEscape.hasMatch(trimmed)) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        uri.scheme.toLowerCase() != scheme ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort ||
        uri.hasFragment) {
      // `n42://pay` is checked below as a compatible legacy format.
      if (uri == null ||
          uri.scheme.toLowerCase() != 'n42' ||
          uri.host.toLowerCase() != 'pay' ||
          uri.path.isNotEmpty ||
          uri.userInfo.isNotEmpty ||
          uri.hasPort ||
          uri.hasFragment) {
        return null;
      }
      return _parseLegacy(uri, n42Scheme: true);
    }

    if (uri.host.toLowerCase() == 'v1' && uri.path == '/pay') {
      return _parseV1(uri);
    }
    if (uri.host.toLowerCase() == 'pay' && uri.path.isEmpty) {
      return _parseLegacy(uri);
    }
    return null;
  }

  static bool isPaymentUri(String raw) => tryParse(raw) != null;

  static PaymentRequestData? _parseV1(Uri uri) {
    const allowed = {
      'to',
      'chain',
      'network',
      'type',
      'contract',
      'amount',
      'token',
      'memo',
    };
    final params = _uniqueParams(uri, allowed);
    if (params == null) return null;
    final receiver = _nonEmpty(params['to']);
    final chain = _nonEmpty(params['chain']);
    final network = params['network'];
    final type = params['type'];
    final contract = _nonEmpty(params['contract']);
    if (receiver == null ||
        chain == null ||
        chain.contains(RegExp(r'\s')) ||
        receiver.contains(RegExp(r'\s')) ||
        (network != 'mainnet' && network != 'testnet') ||
        (type != 'native' && type != 'token') ||
        (type == 'token' && contract == null) ||
        (type == 'native' && contract != null)) {
      return null;
    }
    final amount = (params['amount'] ?? '').trim();
    if (amount.isNotEmpty && !_isPositiveAmount(amount)) return null;
    return PaymentRequestData(
      receiverAddress: receiver,
      amount: amount,
      token: (params['token'] ?? '').trim(),
      memo: _nullIfEmpty(params['memo']),
      chain: chain,
      network: network,
      assetType: type,
      assetId: contract,
    );
  }

  static PaymentRequestData? _parseLegacy(Uri uri, {bool n42Scheme = false}) {
    const allowed = {'to', 'address', 'amount', 'token', 'memo', 'chain'};
    final params = _uniqueParams(uri, allowed);
    if (params == null) return null;
    if (n42Scheme && params.containsKey('to')) return null;
    if (!n42Scheme && params.containsKey('address')) return null;
    final receiver = _nonEmpty(params[n42Scheme ? 'address' : 'to']);
    if (receiver == null) return null;
    final amount = (params['amount'] ?? '').trim();
    if (amount.isNotEmpty && !_isPositiveAmount(amount)) return null;
    return PaymentRequestData(
      receiverAddress: receiver,
      amount: amount,
      token: (params['token'] ?? '').trim(),
      memo: _nullIfEmpty(params['memo']),
      chain: _nullIfEmpty(params['chain']),
      isLegacy: true,
    );
  }

  static Map<String, String>? _uniqueParams(Uri uri, Set<String> allowed) {
    final all = uri.queryParametersAll;
    if (all.keys.any((key) => !allowed.contains(key)) ||
        all.values.any((values) => values.length != 1)) {
      return null;
    }
    return all.map((key, values) => MapEntry(key, values.single));
  }

  static bool _hasVersionedIdentity(PaymentRequestData data) =>
      data.chain?.trim().isNotEmpty == true &&
      (data.network == 'mainnet' || data.network == 'testnet') &&
      (data.assetType == 'native' || data.assetType == 'token');

  static bool _isPositiveAmount(String value) {
    if (!_positiveAmount.hasMatch(value)) return false;
    return value.replaceAll('.', '').contains(RegExp(r'[1-9]'));
  }

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static String? _nullIfEmpty(String? value) => _nonEmpty(value);
}
