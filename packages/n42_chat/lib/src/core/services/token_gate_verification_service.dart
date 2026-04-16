import 'dart:async';

import '../../domain/entities/token_gate_entity.dart';
import '../../domain/protocols/token_gate_bridge_protocol.dart';
import '../utils/debug_log.dart';

/// Token-Gate 验证服务
///
/// 负责根据 [TokenGateConfig] 检查用户持仓是否满足进群门槛。
/// 链上查询委托给 [TokenGateBridge]（由宿主注入）。
class TokenGateVerificationService {
  TokenGateVerificationService({required this.bridge});

  final TokenGateBridge bridge;

  /// 验证指定地址是否满足所有（或任一）规则。
  Future<TokenGateVerificationResult> verify({
    required String walletAddress,
    required TokenGateConfig config,
  }) async {
    if (!config.enabled || config.rules.isEmpty) {
      return const TokenGateVerificationResult(
        passed: true,
        ruleResults: [],
      );
    }

    final results = <TokenGateRuleResult>[];
    for (final rule in config.rules) {
      try {
        final balance = await bridge.queryBalance(
          walletAddress: walletAddress,
          rule: rule,
        );
        final passed = balance >= rule.minBalance;
        results.add(TokenGateRuleResult(
          rule: rule,
          passed: passed,
          actualBalance: balance,
        ));
      } catch (e) {
        debugLog('TokenGate: Failed to verify rule ${rule.id}: $e');
        results.add(TokenGateRuleResult(
          rule: rule,
          passed: false,
          actualBalance: BigInt.zero,
          errorMessage: e.toString(),
        ));
      }
    }

    final overallPassed = config.operator == GateOperator.and
        ? results.every((r) => r.passed)
        : results.any((r) => r.passed);

    return TokenGateVerificationResult(
      passed: overallPassed,
      ruleResults: results,
    );
  }

  /// 定时复核：返回不再满足条件的 room IDs。
  ///
  /// [gatedRooms] 当前生效的 gate 配置映射 {roomId: config}。
  /// [walletAddress] 用户钱包地址。
  Future<List<String>> auditAll({
    required Map<String, TokenGateConfig> gatedRooms,
    required String walletAddress,
  }) async {
    final failed = <String>[];
    for (final entry in gatedRooms.entries) {
      final result = await verify(
        walletAddress: walletAddress,
        config: entry.value,
      );
      if (!result.passed) {
        failed.add(entry.key);
      }
    }
    return failed;
  }

  /// 请求签名绑定地址：用户进群时需要证明钱包归属。
  ///
  /// [matrixUserId] Matrix user ID。
  /// [roomId] 要加入的群 ID。
  /// 返回 (address, signature)。
  Future<TokenGateSignatureResult> requestBindingSignature({
    required String matrixUserId,
    required String roomId,
  }) async {
    final nonce = DateTime.now().millisecondsSinceEpoch.toString();
    final message = 'N42 Token Gate Binding\n'
        'Matrix User: $matrixUserId\n'
        'Room: $roomId\n'
        'Nonce: $nonce';
    return bridge.requestSignature(message: message);
  }
}
