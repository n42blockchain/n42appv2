/// 收款请求二维码载荷（商户收款码）
class PaymentRequestData {
  /// 收款地址
  final String receiverAddress;

  /// 金额（空字符串表示开放金额，由付款方填写）
  final String amount;

  /// 代币符号
  final String token;

  /// 备注 / 订单号
  final String? memo;

  /// 链标识（可选，如 'n42'、'ethereum'）
  final String? chain;

  const PaymentRequestData({
    required this.receiverAddress,
    this.amount = '',
    this.token = '',
    this.memo,
    this.chain,
  });

  bool get hasAmount => amount.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is PaymentRequestData &&
      other.receiverAddress == receiverAddress &&
      other.amount == amount &&
      other.token == token &&
      other.memo == memo &&
      other.chain == chain;

  @override
  int get hashCode =>
      Object.hash(receiverAddress, amount, token, memo, chain);
}

/// 收款请求二维码 URI 编解码（纯逻辑，便于单测）
///
/// 形如 `n42pay://pay?to=<addr>&amount=<a>&token=<t>&memo=<m>&chain=<c>`。
/// 收款方生成、付款方扫码后预填转账表单。
class PaymentRequestUri {
  PaymentRequestUri._();

  static const String scheme = 'n42pay';
  static const String _host = 'pay';

  /// 编码为可放进二维码的 URI 字符串。
  static String encode(PaymentRequestData data) {
    final params = <String, String>{
      'to': data.receiverAddress,
    };
    if (data.amount.trim().isNotEmpty) params['amount'] = data.amount.trim();
    if (data.token.trim().isNotEmpty) params['token'] = data.token.trim();
    final memo = data.memo?.trim();
    if (memo != null && memo.isNotEmpty) params['memo'] = memo;
    final chain = data.chain?.trim();
    if (chain != null && chain.isNotEmpty) params['chain'] = chain;

    final uri = Uri(
      scheme: scheme,
      host: _host,
      queryParameters: params,
    );
    return uri.toString();
  }

  /// 尝试解析收款 URI；非本协议或缺少收款地址返回 null。
  static PaymentRequestData? tryParse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    Uri uri;
    try {
      uri = Uri.parse(trimmed);
    } catch (_) {
      return null;
    }

    if (uri.scheme.toLowerCase() != scheme) return null;

    final params = uri.queryParameters;
    final to = (params['to'] ?? '').trim();
    if (to.isEmpty) return null;

    return PaymentRequestData(
      receiverAddress: to,
      amount: (params['amount'] ?? '').trim(),
      token: (params['token'] ?? '').trim(),
      memo: _nullIfEmpty(params['memo']),
      chain: _nullIfEmpty(params['chain']),
    );
  }

  /// 是否是收款 URI（快速判定，用于扫码分发）
  static bool isPaymentUri(String raw) {
    final t = raw.trim().toLowerCase();
    return t.startsWith('$scheme://');
  }

  static String? _nullIfEmpty(String? value) {
    final v = value?.trim();
    return (v == null || v.isEmpty) ? null : v;
  }
}
