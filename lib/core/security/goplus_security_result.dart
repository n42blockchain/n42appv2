// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// GoPlus Security API 结果数据模型
///
/// 解析 https://api.gopluslabs.io/api/v1/token_security/{chain_id} 响应
enum GoplusRiskLevel { safe, caution, danger }

class GoplusRisk {
  final String label;
  final GoplusRiskLevel level;
  const GoplusRisk(this.label, this.level);
}

class GoplusSecurityResult {
  final List<GoplusRisk> risks;

  const GoplusSecurityResult({required this.risks});

  GoplusRiskLevel get overallLevel {
    if (risks.any((r) => r.level == GoplusRiskLevel.danger)) {
      return GoplusRiskLevel.danger;
    }
    if (risks.any((r) => r.level == GoplusRiskLevel.caution)) {
      return GoplusRiskLevel.caution;
    }
    return GoplusRiskLevel.safe;
  }

  static bool _isFlagged(dynamic val) => val == '1' || val == 1 || val == true;

  static double _parseTax(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  factory GoplusSecurityResult.fromTokenJson(Map<String, dynamic> data) {
    final risks = <GoplusRisk>[];

    // ── Critical: 直接资金损失或 rug pull ─────────────────────────────────
    if (_isFlagged(data['is_honeypot'])) {
      risks.add(
        const GoplusRisk('Honeypot (cannot sell)', GoplusRiskLevel.danger),
      );
    }
    if (_isFlagged(data['hidden_owner'])) {
      risks.add(const GoplusRisk('Hidden Owner', GoplusRiskLevel.danger));
    }
    if (_isFlagged(data['can_take_back_ownership'])) {
      risks.add(const GoplusRisk('Owner Can Reclaim', GoplusRiskLevel.danger));
    }
    if (_isFlagged(data['owner_change_balance'])) {
      risks.add(
        const GoplusRisk('Owner Can Change Balances', GoplusRiskLevel.danger),
      );
    }
    if (_isFlagged(data['transfer_pausable'])) {
      risks.add(
        const GoplusRisk('Transfers Can Be Paused', GoplusRiskLevel.danger),
      );
    }
    if (_isFlagged(data['cannot_buy'])) {
      risks.add(const GoplusRisk('Cannot Buy', GoplusRiskLevel.danger));
    }
    if (_isFlagged(data['is_airdrop_scam'])) {
      risks.add(
        const GoplusRisk('Suspected Airdrop Scam', GoplusRiskLevel.danger),
      );
    }

    // ── Warning: 可疑但非确定性风险 ───────────────────────────────────────
    if (_isFlagged(data['is_blacklisted'])) {
      risks.add(
        const GoplusRisk('Blacklist Function Exists', GoplusRiskLevel.caution),
      );
    }
    if (_isFlagged(data['selfdestruct'])) {
      risks.add(const GoplusRisk('Can Self-Destruct', GoplusRiskLevel.caution));
    }
    if (_isFlagged(data['is_mintable'])) {
      risks.add(
        const GoplusRisk(
          'Mintable (supply can increase)',
          GoplusRiskLevel.caution,
        ),
      );
    }
    if (_isFlagged(data['anti_whale_modifiable'])) {
      risks.add(
        const GoplusRisk(
          'Anti-Whale Limits Modifiable',
          GoplusRiskLevel.caution,
        ),
      );
    }
    if (_isFlagged(data['personal_slippage_modifiable'])) {
      risks.add(
        const GoplusRisk(
          'Slippage Modifiable by Owner',
          GoplusRiskLevel.caution,
        ),
      );
    }

    final buyTax = _parseTax(data['buy_tax']);
    if (buyTax > 0.1) {
      risks.add(
        GoplusRisk(
          'High Buy Tax (${(buyTax * 100).toStringAsFixed(0)}%)',
          GoplusRiskLevel.caution,
        ),
      );
    }
    final sellTax = _parseTax(data['sell_tax']);
    if (sellTax > 0.1) {
      risks.add(
        GoplusRisk(
          'High Sell Tax (${(sellTax * 100).toStringAsFixed(0)}%)',
          GoplusRiskLevel.caution,
        ),
      );
    }

    if (data['is_open_source'] == '0') {
      risks.add(const GoplusRisk('Not Open Source', GoplusRiskLevel.caution));
    }
    if (_isFlagged(data['is_proxy'])) {
      risks.add(const GoplusRisk('Proxy Contract', GoplusRiskLevel.caution));
    }

    return GoplusSecurityResult(risks: risks);
  }
}
