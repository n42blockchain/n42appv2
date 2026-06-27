import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/mini_app_agent_planner.dart';
import 'package:n42_chat/src/domain/entities/mini_app_entity.dart';

void main() {
  const apps = [
    MiniAppEntity(
      id: 'n42_swap',
      name: 'N42 Swap',
      description: 'Swap tokens across chains with best rates',
      iconUrl: '',
      url: '',
      category: MiniAppCategory.defi,
    ),
    MiniAppEntity(
      id: 'n42_nft',
      name: 'NFT Market',
      description: 'View and trade NFTs',
      iconUrl: '',
      url: '',
      category: MiniAppCategory.nft,
    ),
  ];

  group('buildSystemPrompt', () {
    test('lists every app id and asks for JSON', () {
      final p = MiniAppAgentPlanner.buildSystemPrompt(apps);
      expect(p, contains('n42_swap'));
      expect(p, contains('n42_nft'));
      expect(p, contains('JSON'));
    });
  });

  group('parsePlan', () {
    test('parses a clean JSON plan and validates app id', () {
      const raw =
          '{"appId":"n42_swap","confidence":0.9,"reason":"swap intent",'
          '"params":{"from":"ETH","to":"USDC"}}';
      final plan = MiniAppAgentPlanner.parsePlan(raw, apps);
      expect(plan, isNotNull);
      expect(plan!.appId, 'n42_swap');
      expect(plan.appName, 'N42 Swap');
      expect(plan.confidence, closeTo(0.9, 1e-9));
      expect(plan.params['from'], 'ETH');
      expect(plan.params['to'], 'USDC');
    });

    test('tolerates code fences / surrounding prose', () {
      const raw = 'Sure!\n```json\n{"appId":"n42_nft","confidence":0.7}\n```';
      final plan = MiniAppAgentPlanner.parsePlan(raw, apps);
      expect(plan?.appId, 'n42_nft');
    });

    test('rejects unknown / hallucinated app id', () {
      const raw = '{"appId":"ghost_app","confidence":1}';
      expect(MiniAppAgentPlanner.parsePlan(raw, apps), isNull);
    });

    test('rejects empty appId and non-JSON', () {
      expect(MiniAppAgentPlanner.parsePlan('{"appId":""}', apps), isNull);
      expect(MiniAppAgentPlanner.parsePlan('no json here', apps), isNull);
    });

    test('clamps confidence into 0..1', () {
      const raw = '{"appId":"n42_swap","confidence":5}';
      expect(MiniAppAgentPlanner.parsePlan(raw, apps)!.confidence, 1.0);
    });
  });

  group('ruleBasedMatch', () {
    test('matches swap intent by keyword', () {
      final plan = MiniAppAgentPlanner.ruleBasedMatch('please swap tokens', apps);
      expect(plan?.appId, 'n42_swap');
      expect(plan!.confidence, greaterThan(0));
    });

    test('matches nft intent', () {
      final plan = MiniAppAgentPlanner.ruleBasedMatch('trade my nfts', apps);
      expect(plan?.appId, 'n42_nft');
    });

    test('returns null for empty or unrelated query', () {
      expect(MiniAppAgentPlanner.ruleBasedMatch('', apps), isNull);
      expect(
        MiniAppAgentPlanner.ruleBasedMatch('zzzz qqqq', apps),
        isNull,
      );
    });
  });
}
