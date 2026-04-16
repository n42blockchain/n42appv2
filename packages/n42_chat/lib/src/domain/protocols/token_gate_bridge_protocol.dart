import '../entities/token_gate_entity.dart';

/// Token-Gate 链上验证桥接协议。
///
/// 由宿主应用实现，注入后 n42_chat 包可在用户进群时
/// 自动验证持仓门槛、定时复核、不达标则退场。
///
/// 注入方式：`N42Chat.configureTokenGateBridge(MyImpl())`。
abstract class TokenGateBridge {
  /// 查询指定地址在指定规则下的余额。
  ///
  /// [walletAddress] 用户的 EVM 地址。
  /// [rule] 要检查的代币门控规则。
  /// 返回实际余额（最小单位 wei / 原始数量）。
  Future<BigInt> queryBalance({
    required String walletAddress,
    required TokenGateRule rule,
  });

  /// 请求用户签名一条消息以证明地址归属。
  ///
  /// [message] 待签名文本（包含 Matrix user ID + 群 ID + nonce）。
  /// 返回 (address, signature) 二元组。
  Future<TokenGateSignatureResult> requestSignature({
    required String message,
  });

  /// 获取当前用户的默认钱包地址。
  Future<String?> getDefaultAddress();
}

class TokenGateSignatureResult {
  const TokenGateSignatureResult({
    required this.address,
    required this.signature,
  });
  final String address;
  final String signature;
}
