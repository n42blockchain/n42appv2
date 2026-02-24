// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/goplus_security_result.dart';
import 'package:n42_wallet/core/security/goplus_security_service.dart';

void main() {
  // ── GoplusSecurityResult.fromTokenJson ───────────────────────────────────

  group('GoplusSecurityResult.fromTokenJson', () {
    group('empty / all-safe data', () {
      test('empty map produces zero risks (safe)', () {
        final r = GoplusSecurityResult.fromTokenJson({});
        expect(r.risks, isEmpty);
        expect(r.overallLevel, GoplusRiskLevel.safe);
      });

      test('all flags explicitly "0" → safe', () {
        final r = GoplusSecurityResult.fromTokenJson({
          'is_honeypot': '0',
          'hidden_owner': '0',
          'can_take_back_ownership': '0',
          'owner_change_balance': '0',
          'transfer_pausable': '0',
          'cannot_buy': '0',
          'is_blacklisted': '0',
          'selfdestruct': '0',
          'is_mintable': '0',
          'is_open_source': '1',
          'is_proxy': '0',
          'is_airdrop_scam': '0',
          'buy_tax': '0',
          'sell_tax': '0',
        });
        expect(r.risks, isEmpty);
        expect(r.overallLevel, GoplusRiskLevel.safe);
      });
    });

    group('critical (danger) flags', () {
      test('is_honeypot "1" → danger risk labelled Honeypot', () {
        final r = GoplusSecurityResult.fromTokenJson({'is_honeypot': '1'});
        expect(r.overallLevel, GoplusRiskLevel.danger);
        expect(r.risks.any((x) => x.label.contains('Honeypot')), isTrue);
        expect(r.risks.first.level, GoplusRiskLevel.danger);
      });

      test('is_honeypot "0" → no Honeypot risk', () {
        final r = GoplusSecurityResult.fromTokenJson({'is_honeypot': '0'});
        expect(r.risks.where((x) => x.label.contains('Honeypot')), isEmpty);
      });

      test('is_honeypot integer 1 → danger (_isFlagged handles int)', () {
        final r = GoplusSecurityResult.fromTokenJson({'is_honeypot': 1});
        expect(r.overallLevel, GoplusRiskLevel.danger);
      });

      test('is_honeypot bool true → danger (_isFlagged handles bool)', () {
        final r = GoplusSecurityResult.fromTokenJson({'is_honeypot': true});
        expect(r.overallLevel, GoplusRiskLevel.danger);
      });

      test('hidden_owner "1" → danger', () {
        final r = GoplusSecurityResult.fromTokenJson({'hidden_owner': '1'});
        expect(r.overallLevel, GoplusRiskLevel.danger);
        expect(r.risks.any((x) => x.label.contains('Hidden Owner')), isTrue);
      });

      test('can_take_back_ownership "1" → danger', () {
        final r = GoplusSecurityResult.fromTokenJson({'can_take_back_ownership': '1'});
        expect(r.overallLevel, GoplusRiskLevel.danger);
      });

      test('owner_change_balance "1" → danger', () {
        final r = GoplusSecurityResult.fromTokenJson({'owner_change_balance': '1'});
        expect(r.overallLevel, GoplusRiskLevel.danger);
      });

      test('transfer_pausable "1" → danger', () {
        final r = GoplusSecurityResult.fromTokenJson({'transfer_pausable': '1'});
        expect(r.overallLevel, GoplusRiskLevel.danger);
      });

      test('cannot_buy "1" → danger', () {
        final r = GoplusSecurityResult.fromTokenJson({'cannot_buy': '1'});
        expect(r.overallLevel, GoplusRiskLevel.danger);
      });

      test('is_airdrop_scam "1" → danger', () {
        final r = GoplusSecurityResult.fromTokenJson({'is_airdrop_scam': '1'});
        expect(r.overallLevel, GoplusRiskLevel.danger);
      });
    });

    group('caution flags', () {
      test('is_blacklisted "1" → caution', () {
        final r = GoplusSecurityResult.fromTokenJson({'is_blacklisted': '1'});
        expect(r.overallLevel, GoplusRiskLevel.caution);
        expect(r.risks.first.level, GoplusRiskLevel.caution);
      });

      test('selfdestruct "1" → caution', () {
        final r = GoplusSecurityResult.fromTokenJson({'selfdestruct': '1'});
        expect(r.overallLevel, GoplusRiskLevel.caution);
      });

      test('is_mintable "1" → caution', () {
        final r = GoplusSecurityResult.fromTokenJson({'is_mintable': '1'});
        expect(r.overallLevel, GoplusRiskLevel.caution);
      });

      test('anti_whale_modifiable "1" → caution', () {
        final r = GoplusSecurityResult.fromTokenJson({'anti_whale_modifiable': '1'});
        expect(r.overallLevel, GoplusRiskLevel.caution);
      });

      test('personal_slippage_modifiable "1" → caution', () {
        final r = GoplusSecurityResult.fromTokenJson({'personal_slippage_modifiable': '1'});
        expect(r.overallLevel, GoplusRiskLevel.caution);
      });

      test('is_open_source "0" → caution (Not Open Source)', () {
        final r = GoplusSecurityResult.fromTokenJson({'is_open_source': '0'});
        expect(r.overallLevel, GoplusRiskLevel.caution);
        expect(r.risks.any((x) => x.label.contains('Not Open Source')), isTrue);
      });

      test('is_open_source "1" → no risk', () {
        final r = GoplusSecurityResult.fromTokenJson({'is_open_source': '1'});
        expect(r.risks.where((x) => x.label.contains('Open Source')), isEmpty);
      });

      test('is_proxy "1" → caution', () {
        final r = GoplusSecurityResult.fromTokenJson({'is_proxy': '1'});
        expect(r.overallLevel, GoplusRiskLevel.caution);
      });
    });

    group('tax thresholds', () {
      test('buy_tax "0.15" (15%) → caution with Buy Tax label', () {
        final r = GoplusSecurityResult.fromTokenJson({'buy_tax': '0.15'});
        expect(r.overallLevel, GoplusRiskLevel.caution);
        final taxRisk = r.risks.firstWhere((x) => x.label.contains('Buy Tax'),
            orElse: () => throw StateError('missing'));
        expect(taxRisk.label, contains('15%'));
      });

      test('sell_tax "0.20" (20%) → caution with Sell Tax label', () {
        final r = GoplusSecurityResult.fromTokenJson({'sell_tax': '0.20'});
        expect(r.overallLevel, GoplusRiskLevel.caution);
        expect(r.risks.any((x) => x.label.contains('Sell Tax')), isTrue);
      });

      test('buy_tax "0.05" (5%) → no tax risk', () {
        final r = GoplusSecurityResult.fromTokenJson({'buy_tax': '0.05'});
        expect(r.risks.where((x) => x.label.contains('Buy Tax')), isEmpty);
      });

      test('buy_tax "0" → no tax risk', () {
        final r = GoplusSecurityResult.fromTokenJson({'buy_tax': '0'});
        expect(r.risks.where((x) => x.label.contains('Buy Tax')), isEmpty);
      });

      test('buy_tax exactly "0.1" (10%) → no risk (threshold is > 0.1)', () {
        final r = GoplusSecurityResult.fromTokenJson({'buy_tax': '0.1'});
        expect(r.risks.where((x) => x.label.contains('Buy Tax')), isEmpty);
      });

      test('buy_tax as numeric double 0.15 → caution', () {
        final r = GoplusSecurityResult.fromTokenJson({'buy_tax': 0.15});
        expect(r.overallLevel, GoplusRiskLevel.caution);
      });

      test('null buy_tax → no risk', () {
        final r = GoplusSecurityResult.fromTokenJson({'buy_tax': null});
        expect(r.risks.where((x) => x.label.contains('Buy Tax')), isEmpty);
      });
    });

    group('overallLevel priority', () {
      test('danger overrides caution when both present', () {
        final r = GoplusSecurityResult.fromTokenJson({
          'is_mintable': '1',    // caution
          'is_honeypot': '1',    // danger
        });
        expect(r.overallLevel, GoplusRiskLevel.danger);
      });

      test('caution overrides safe', () {
        final r = GoplusSecurityResult.fromTokenJson({'is_open_source': '0'});
        expect(r.overallLevel, GoplusRiskLevel.caution);
      });

      test('multiple risks all appear in list', () {
        final r = GoplusSecurityResult.fromTokenJson({
          'is_honeypot': '1',
          'is_blacklisted': '1',
          'is_mintable': '1',
          'is_open_source': '0',
        });
        expect(r.risks.length, greaterThanOrEqualTo(4));
      });
    });

    group('null / missing field handling', () {
      test('missing is_open_source key → NOT flagged as closed-source', () {
        final r = GoplusSecurityResult.fromTokenJson({});
        expect(r.risks.where((x) => x.label.contains('Open Source')), isEmpty);
      });

      test('null field values → no flag', () {
        final r = GoplusSecurityResult.fromTokenJson({
          'is_honeypot': null,
          'buy_tax': null,
          'sell_tax': null,
        });
        expect(r.risks, isEmpty);
      });
    });
  });

  // ── GoplusSecurityService chain support ──────────────────────────────────

  group('GoplusSecurityService.supportsChain', () {
    test('ETH is supported', () {
      expect(GoplusSecurityService.supportsChain('ETH'), isTrue);
    });

    test('BSC is supported', () {
      expect(GoplusSecurityService.supportsChain('BSC'), isTrue);
    });

    test('MATIC is supported', () {
      expect(GoplusSecurityService.supportsChain('MATIC'), isTrue);
    });

    test('BASE is supported', () {
      expect(GoplusSecurityService.supportsChain('BASE'), isTrue);
    });

    test('ARBITRUM is supported', () {
      expect(GoplusSecurityService.supportsChain('ARBITRUM'), isTrue);
    });

    test('lowercase "eth" is supported (case-insensitive)', () {
      expect(GoplusSecurityService.supportsChain('eth'), isTrue);
    });

    test('mixed case "Eth" is supported (case-insensitive)', () {
      expect(GoplusSecurityService.supportsChain('Eth'), isTrue);
    });

    test('BTC is NOT supported (no GoPlus token security for Bitcoin)', () {
      expect(GoplusSecurityService.supportsChain('BTC'), isFalse);
    });

    test('SOL is NOT supported', () {
      expect(GoplusSecurityService.supportsChain('SOL'), isFalse);
    });

    test('empty string is NOT supported', () {
      expect(GoplusSecurityService.supportsChain(''), isFalse);
    });

    test('unknown chain is NOT supported', () {
      expect(GoplusSecurityService.supportsChain('UNKNOWN'), isFalse);
    });
  });
}
