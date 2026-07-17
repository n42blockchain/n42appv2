import 'package:equatable/equatable.dart';

/// 代币标准
enum TokenStandard { erc20, erc721, erc1155, native }

/// 返回宿主钱包中该链原生资产的 **coinType**（喂给 walletBridge.getBalance）。
///
/// 注意这不是链原生 gas 币的币种符号：Optimism/Arbitrum 的 gas 币是 ETH，
/// 但宿主钱包把「OP 链上的 ETH」记在 coinType 'OP' 名下（unit 才是 ETH）。
/// 这里若“修正”成 'ETH'，getBalance 会错查以太坊主网余额。
String nativeTokenSymbolForChainId(int chainId) => switch (chainId) {
  1 => 'ETH',
  10 => 'OP',
  56 => 'BNB',
  137 => 'MATIC',
  42161 => 'ARB',
  _ => 'ETH',
};

/// 门控逻辑运算符
enum GateOperator {
  /// 需满足所有规则
  and,

  /// 满足任一规则即可
  or,
}

/// 代币门控规则
class TokenGateRule extends Equatable {
  /// 规则 ID
  final String id;

  /// 代币标准
  final TokenStandard tokenStandard;

  /// 链 ID
  final int chainId;

  /// 合约地址（原生代币时为空）
  final String? contractAddress;

  /// 最低余额
  final BigInt minBalance;

  /// Token ID（ERC-1155 专用）
  final BigInt? tokenId;

  /// 代币符号（用于 UI 显示）
  final String? symbol;

  /// 小数位数
  final int decimals;

  const TokenGateRule({
    required this.id,
    required this.tokenStandard,
    required this.chainId,
    this.contractAddress,
    required this.minBalance,
    this.tokenId,
    this.symbol,
    this.decimals = 18,
  });

  @override
  List<Object?> get props => [
    id,
    tokenStandard,
    chainId,
    contractAddress,
    minBalance,
    tokenId,
    symbol,
    decimals,
  ];

  Map<String, dynamic> toJson() => {
    'id': id,
    'token_standard': tokenStandard.name,
    'chain_id': chainId,
    'contract_address': contractAddress,
    'min_balance': minBalance.toString(),
    'token_id': tokenId?.toString(),
    'symbol': symbol,
    'decimals': decimals,
  };

  factory TokenGateRule.fromJson(Map<String, dynamic> json) => TokenGateRule(
    id: json['id'] as String,
    tokenStandard: TokenStandard.values.firstWhere(
      (s) => s.name == json['token_standard'],
      orElse: () => TokenStandard.erc20,
    ),
    chainId: json['chain_id'] as int,
    contractAddress: json['contract_address'] as String?,
    minBalance:
        BigInt.tryParse(json['min_balance'] as String? ?? '0') ?? BigInt.zero,
    tokenId: json['token_id'] != null
        ? BigInt.tryParse(json['token_id'] as String)
        : null,
    symbol: json['symbol'] as String?,
    decimals: json['decimals'] as int? ?? 18,
  );
}

/// 代币门控配置
class TokenGateConfig extends Equatable {
  /// 是否启用
  final bool enabled;

  /// 门控规则列表
  final List<TokenGateRule> rules;

  /// 规则逻辑运算符
  final GateOperator operator;

  /// 设置者用户 ID
  final String? setBy;

  /// 设置时间
  final DateTime? setAt;

  /// 拒绝时显示的消息
  final String? denialMessage;

  const TokenGateConfig({
    this.enabled = false,
    this.rules = const [],
    this.operator = GateOperator.and,
    this.setBy,
    this.setAt,
    this.denialMessage,
  });

  @override
  List<Object?> get props => [
    enabled,
    rules,
    operator,
    setBy,
    setAt,
    denialMessage,
  ];

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'rules': rules.map((r) => r.toJson()).toList(),
    'operator': operator.name,
    'set_by': setBy,
    'set_at': setAt?.millisecondsSinceEpoch,
    'denial_message': denialMessage,
  };

  factory TokenGateConfig.fromJson(Map<String, dynamic> json) =>
      TokenGateConfig(
        enabled: json['enabled'] as bool? ?? false,
        rules:
            (json['rules'] as List<dynamic>?)
                ?.map((r) => TokenGateRule.fromJson(r as Map<String, dynamic>))
                .toList() ??
            [],
        operator: GateOperator.values.firstWhere(
          (o) => o.name == json['operator'],
          orElse: () => GateOperator.and,
        ),
        setBy: json['set_by'] as String?,
        setAt: json['set_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['set_at'] as int)
            : null,
        denialMessage: json['denial_message'] as String?,
      );

  TokenGateConfig copyWith({
    bool? enabled,
    List<TokenGateRule>? rules,
    GateOperator? operator,
    String? setBy,
    DateTime? setAt,
    String? denialMessage,
  }) {
    return TokenGateConfig(
      enabled: enabled ?? this.enabled,
      rules: rules ?? this.rules,
      operator: operator ?? this.operator,
      setBy: setBy ?? this.setBy,
      setAt: setAt ?? this.setAt,
      denialMessage: denialMessage ?? this.denialMessage,
    );
  }
}

/// 单条规则验证结果
class TokenGateRuleResult extends Equatable {
  final TokenGateRule rule;
  final bool passed;
  final BigInt actualBalance;
  final String? errorMessage;

  const TokenGateRuleResult({
    required this.rule,
    required this.passed,
    required this.actualBalance,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [rule, passed, actualBalance, errorMessage];
}

/// 完整的门控验证结果
class TokenGateVerificationResult extends Equatable {
  /// 整体是否通过
  final bool passed;

  /// 每条规则的验证结果
  final List<TokenGateRuleResult> ruleResults;

  /// 整体错误信息
  final String? errorMessage;

  const TokenGateVerificationResult({
    required this.passed,
    this.ruleResults = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [passed, ruleResults, errorMessage];

  factory TokenGateVerificationResult.error(String message) =>
      TokenGateVerificationResult(passed: false, errorMessage: message);
}
