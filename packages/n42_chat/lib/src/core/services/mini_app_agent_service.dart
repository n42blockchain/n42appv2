import '../../domain/entities/mini_app_entity.dart';
import 'ai_service.dart';
import 'mini_app_agent_planner.dart';
import '../di/injection.dart';
import '../utils/debug_log.dart';

/// 超级应用 Agentic 编排服务
///
/// 把用户一句话编排为「调用哪个 Mini App + 参数」。优先用 LLM（[AiService]）
/// 规划，失败/未注册/低置信时回退规则匹配（[MiniAppAgentPlanner.ruleBasedMatch]）。
class MiniAppAgentService {
  final List<MiniAppEntity> _apps;

  MiniAppAgentService({List<MiniAppEntity>? apps})
      : _apps = apps ?? BuiltInMiniApps.all;

  /// LLM 置信度低于此值时回退规则匹配
  static const double _minLlmConfidence = 0.35;

  /// 规划用户意图；无可用 app 返回 null。
  Future<MiniAppPlan?> plan(String userMessage) async {
    final query = userMessage.trim();
    if (query.isEmpty) return null;

    final ai = getIt.isRegistered<AiService>() ? getIt<AiService>() : null;
    if (ai != null) {
      try {
        final result = await ai.completion(
          [AiMessage(role: AiRole.user, content: query)],
          systemPrompt: MiniAppAgentPlanner.buildSystemPrompt(_apps),
          temperature: 0,
          maxTokens: 256,
        );
        final plan = MiniAppAgentPlanner.parsePlan(result.text, _apps);
        if (plan != null && plan.confidence >= _minLlmConfidence) {
          return plan;
        }
      } catch (e) {
        debugLog('MiniAppAgentService: LLM plan failed: $e');
      }
    }

    // 回退：规则匹配
    return MiniAppAgentPlanner.ruleBasedMatch(query, _apps);
  }
}
