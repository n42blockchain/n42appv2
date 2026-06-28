// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// 解析后的 EIP-681 支付请求。
class Eip681Request {
  /// URI 的 target 地址（原生转账=收款人；ERC-20 transfer=代币合约）。
  final String targetAddress;
  final int? chainId;

  /// 函数名（如 `transfer`）；原生转账为 null。
  final String? functionName;

  /// 查询参数（如 value / address / uint256）。
  final Map<String, String> parameters;

  const Eip681Request({
    required this.targetAddress,
    this.chainId,
    this.functionName,
    this.parameters = const {},
  });

  /// 是否 ERC-20 transfer 请求。
  bool get isErc20Transfer => functionName == 'transfer';

  /// 代币合约地址（仅 ERC-20）。
  String? get tokenAddress => isErc20Transfer ? targetAddress : null;

  /// 收款人地址（ERC-20 取参数 address，否则取 target）。
  String? get recipient =>
      isErc20Transfer ? parameters['address'] : targetAddress;

  /// 金额（最小单位字符串）：ERC-20 取 uint256，原生取 value。
  String? get amount => parameters['uint256'] ?? parameters['value'];
}

/// EIP-681「ethereum:」支付请求 URI 的构建与解析 —— Wallet Roadmap M2（稳定币 Pay）。
///
/// 用于「请求指定金额（含稳定币）」收款码与「扫码即付」。纯字符串逻辑，便于单测。
/// 格式：`ethereum:[pay-]<target>[@<chainId>][/<function>][?k=v&...]`
class Eip681 {
  Eip681._();

  static const String scheme = 'ethereum:';

  /// 构建原生币（ETH/BNB…）支付请求。[amountWei] 为最小单位字符串（可空）。
  static String buildNative({
    required String recipient,
    int? chainId,
    String? amountWei,
  }) {
    final buf = StringBuffer(scheme)..write(recipient);
    if (chainId != null) buf.write('@$chainId');
    if (amountWei != null && amountWei.isNotEmpty) buf.write('?value=$amountWei');
    return buf.toString();
  }

  /// 构建 ERC-20（稳定币）transfer 支付请求。[amount] 为最小单位字符串。
  static String buildErc20Transfer({
    required String token,
    required String recipient,
    required String amount,
    int? chainId,
  }) {
    final buf = StringBuffer(scheme)..write(token);
    if (chainId != null) buf.write('@$chainId');
    buf.write('/transfer?address=$recipient&uint256=$amount');
    return buf.toString();
  }

  /// 解析 EIP-681 URI；非法返回 null。
  static Eip681Request? parse(String uri) {
    var s = uri.trim();
    if (!s.toLowerCase().startsWith(scheme)) return null;
    s = s.substring(scheme.length);
    // 可选 "pay-" 前缀。
    if (s.toLowerCase().startsWith('pay-')) s = s.substring(4);
    if (s.isEmpty) return null;

    // 切出查询参数。
    String head = s;
    Map<String, String> params = const {};
    final qIdx = s.indexOf('?');
    if (qIdx >= 0) {
      head = s.substring(0, qIdx);
      params = _parseParams(s.substring(qIdx + 1));
    }

    // head = <target>[@chainId][/function]
    String? function;
    final slashIdx = head.indexOf('/');
    if (slashIdx >= 0) {
      function = head.substring(slashIdx + 1);
      head = head.substring(0, slashIdx);
    }

    int? chainId;
    final atIdx = head.indexOf('@');
    if (atIdx >= 0) {
      chainId = int.tryParse(head.substring(atIdx + 1));
      head = head.substring(0, atIdx);
    }

    final target = head.trim();
    if (target.isEmpty) return null;

    return Eip681Request(
      targetAddress: target,
      chainId: chainId,
      functionName: (function != null && function.isEmpty) ? null : function,
      parameters: params,
    );
  }

  /// 从扫码原文解析出收款地址：若为 EIP-681 支付请求则取其 recipient，
  /// 否则原样返回（兼容直接扫地址的旧行为）。用于「扫码即付」地址栏填充。
  static String resolveRecipient(String scanned) {
    final req = parse(scanned);
    final r = req?.recipient;
    return (r != null && r.isNotEmpty) ? r : scanned;
  }

  static Map<String, String> _parseParams(String query) {
    final map = <String, String>{};
    for (final pair in query.split('&')) {
      if (pair.isEmpty) continue;
      final eq = pair.indexOf('=');
      if (eq < 0) {
        map[_safeDecode(pair)] = '';
      } else {
        map[_safeDecode(pair.substring(0, eq))] =
            _safeDecode(pair.substring(eq + 1));
      }
    }
    return map;
  }

  /// 安全 URL 解码：扫码等不可信输入遇畸形 `%` 序列时回退原文，绝不抛。
  static String _safeDecode(String s) {
    try {
      return Uri.decodeComponent(s);
    } catch (_) {
      return s;
    }
  }
}
