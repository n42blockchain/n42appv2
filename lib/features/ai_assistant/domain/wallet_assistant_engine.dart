// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/ai_assistant/domain/wallet_ai_channel.dart';
import 'package:n42_wallet/features/ai_assistant/domain/wallet_snapshot.dart';

/// 识别出的用户意图。
enum WalletIntent { balance, portfolio, gas, help, unknown }

/// 钱包 AI 助手引擎（M1：只读 + 建议）—— Wallet Roadmap L3 第一层。
///
/// 结构化意图（余额/持仓/Gas/帮助）用**确定性规则**回答（零外部依赖、可单测）；
/// 未识别意图回退到 [WalletAiChannel]（如复用 chat 的 `AiService`），通道不可用则给兜底语。
/// **只读**：引擎不签名、不发交易；任何代执行属后续受控阶段（须 Session Key 限额 + 每步授权）。
class WalletAssistantEngine {
  final WalletAiChannel? channel;
  const WalletAssistantEngine({this.channel});

  static const List<String> _gasKw = ['gas', '手续费', '矿工费', 'gwei', '燃料'];
  static const List<String> _balanceKw = ['余额', 'balance', '有多少', '剩多少'];
  static const List<String> _portfolioKw = [
    '持仓',
    '资产',
    'portfolio',
    '总值',
    '总资产',
    '净值',
    'holdings',
    'assets',
  ];
  static const List<String> _helpKw = [
    '帮助',
    'help',
    '能做什么',
    '怎么用',
    '功能',
    'what can you',
  ];

  /// 纯意图分类（小写匹配关键词；先 Gas 后余额，避免「余额」误吞）。
  static WalletIntent classify(String query) {
    final q = query.toLowerCase();
    if (_anyIn(q, _helpKw)) return WalletIntent.help;
    if (_anyIn(q, _gasKw)) return WalletIntent.gas;
    if (_anyIn(q, _portfolioKw)) return WalletIntent.portfolio;
    if (_anyIn(q, _balanceKw)) return WalletIntent.balance;
    return WalletIntent.unknown;
  }

  static bool _anyIn(String q, List<String> kws) => kws.any(q.contains);

  /// 回答用户问题。已知意图确定性返回；未知意图走 LLM 通道，失败给兜底。
  Future<String> answer(String query, WalletSnapshot snapshot) async {
    switch (classify(query)) {
      case WalletIntent.balance:
        return balanceAnswer(snapshot);
      case WalletIntent.portfolio:
        return portfolioAnswer(snapshot);
      case WalletIntent.gas:
        return gasAnswer(snapshot);
      case WalletIntent.help:
        return helpAnswer();
      case WalletIntent.unknown:
        final llm = await channel?.ask(systemPrompt(snapshot), query);
        return (llm != null && llm.trim().isNotEmpty) ? llm : fallbackAnswer();
    }
  }

  // ── 确定性回答（可单测）──

  String balanceAnswer(WalletSnapshot s) {
    if (s.assets.isEmpty) {
      return 'No assets found on ${s.chainName ?? 'this wallet'}.';
    }
    final top = s.assets
        .take(5)
        .map((a) => '${a.balance} ${a.symbol}')
        .join('\n');
    return 'Your balances:\n$top';
  }

  String portfolioAnswer(WalletSnapshot s) {
    final total = '\$${s.totalUsd.toStringAsFixed(2)}';
    if (s.assets.isEmpty) return 'Total value: $total (no assets).';
    final lines = s.assets
        .take(5)
        .map(
          (a) =>
              '${a.symbol}: ${a.balance} (\$${a.usdValue.toStringAsFixed(2)})',
        )
        .join('\n');
    return 'Total value: $total\n$lines';
  }

  String gasAnswer(WalletSnapshot s) {
    if (s.gasGwei == null) return 'Gas price is unavailable right now.';
    final g = s.gasGwei!;
    final hint = g <= 15
        ? 'Low — a good time to transact.'
        : g <= 40
        ? 'Moderate.'
        : 'High — consider waiting.';
    return 'Current gas: ${g.toStringAsFixed(1)} gwei. $hint';
  }

  String helpAnswer() =>
      'I can read your wallet and help you understand it:\n'
      '• "balance" — your token balances\n'
      '• "portfolio" — total value & holdings\n'
      '• "gas" — current gas price & timing\n'
      'I only read and suggest — I never sign or send for you.';

  String fallbackAnswer() =>
      'I can only read your wallet (balance, portfolio, gas). '
      'AI chat is unavailable; try one of those.';

  /// 给 LLM 的系统提示（注入只读上下文 + 安全边界）。
  String systemPrompt(WalletSnapshot s) {
    final assets = s.assets
        .take(10)
        .map(
          (a) => '${a.symbol}=${a.balance}(\$${a.usdValue.toStringAsFixed(2)})',
        )
        .join(', ');
    return 'You are a read-only crypto wallet assistant. '
        'Context: chain=${s.chainName ?? 'unknown'}, totalUsd=${s.totalUsd.toStringAsFixed(2)}, '
        'gasGwei=${s.gasGwei ?? 'n/a'}, assets=[$assets]. '
        'Answer concisely. You CANNOT sign or send transactions; only read and suggest. '
        'Never ask for private keys or seed phrases.';
  }
}
