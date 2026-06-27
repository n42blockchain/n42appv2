import 'dart:convert';

import '../../domain/entities/mini_app_entity.dart';

/// Agentic 编排结果：把用户意图映射到某个 Mini App + 抽取的参数。
class MiniAppPlan {
  final String appId;
  final String appName;

  /// 置信度 0–1
  final double confidence;

  /// 选择理由（给用户看的简短说明）
  final String reason;

  /// 从用户消息抽取的参数（如 {from: ETH, to: USDC}）
  final Map<String, String> params;

  const MiniAppPlan({
    required this.appId,
    required this.appName,
    required this.confidence,
    this.reason = '',
    this.params = const {},
  });
}

/// 超级应用 Agentic 编排器（纯逻辑，便于单测）
///
/// 把「用户一句话」解析为「调用哪个 Mini App + 参数」。两条路径：
/// - LLM：[buildSystemPrompt] 喂应用目录，模型返回 JSON，[parsePlan] 校验落到目录内的 app；
/// - 规则兜底：[ruleBasedMatch] 按名称/描述/分类做词重叠打分，无 LLM 也能用。
class MiniAppAgentPlanner {
  MiniAppAgentPlanner._();

  /// 规则兜底命中阈值（归一化词重叠分）
  static const double ruleMatchThreshold = 0.18;

  /// 构造系统提示：列出可用应用目录，要求模型只返回 JSON。
  static String buildSystemPrompt(List<MiniAppEntity> apps) {
    final catalog = apps
        .map((a) =>
            '- id: ${a.id} | name: ${a.name} | ${a.description} (category: ${a.category.name})')
        .join('\n');
    return '''
You are an in-app assistant that routes a user request to ONE mini app.
Available mini apps:
$catalog

Reply with ONLY a JSON object, no prose:
{"appId": "<one id from the list, or empty if none fits>",
 "confidence": <0..1>,
 "reason": "<short reason>",
 "params": {"<key>": "<value>"}}
''';
  }

  /// 解析 LLM 返回（容忍前后多余文本，取第一个 JSON 对象），校验 appId 在目录内。
  static MiniAppPlan? parsePlan(String raw, List<MiniAppEntity> apps) {
    final json = _extractJsonObject(raw);
    if (json == null) return null;

    Map<String, dynamic> map;
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map<String, dynamic>) return null;
      map = decoded;
    } catch (_) {
      return null;
    }

    final appId = (map['appId'] as String?)?.trim() ?? '';
    if (appId.isEmpty) return null;
    final app = _findById(apps, appId);
    if (app == null) return null; // 幻觉/未知 id → 丢弃

    final params = <String, String>{};
    final rawParams = map['params'];
    if (rawParams is Map) {
      rawParams.forEach((k, v) {
        if (v != null) params[k.toString()] = v.toString();
      });
    }

    return MiniAppPlan(
      appId: app.id,
      appName: app.name,
      confidence: _clamp01(map['confidence']),
      reason: (map['reason'] as String?)?.trim() ?? '',
      params: params,
    );
  }

  /// 规则兜底：按用户词与 app 名称/描述/分类的重叠打分，返回最佳（低于阈值返回 null）。
  static MiniAppPlan? ruleBasedMatch(String query, List<MiniAppEntity> apps) {
    final qTokens = _tokenize(query);
    if (qTokens.isEmpty) return null;

    MiniAppEntity? best;
    var bestScore = 0.0;
    for (final app in apps) {
      final hay = _tokenize('${app.name} ${app.description} ${app.category.name}')
          .toSet();
      if (hay.isEmpty) continue;
      var hits = 0;
      for (final t in qTokens) {
        if (hay.contains(t)) hits++;
      }
      final score = hits / qTokens.length;
      if (score > bestScore) {
        bestScore = score;
        best = app;
      }
    }

    if (best == null || bestScore < ruleMatchThreshold) return null;
    return MiniAppPlan(
      appId: best.id,
      appName: best.name,
      confidence: bestScore.clamp(0.0, 1.0),
      reason: 'Matched by keywords',
    );
  }

  // ── helpers ────────────────────────────────────────────────────────

  static final RegExp _tokenSplit = RegExp(r'[^a-z0-9一-鿿]+');

  static List<String> _tokenize(String s) => s
      .toLowerCase()
      .split(_tokenSplit)
      .where((t) => t.length > 1)
      .toList();

  static MiniAppEntity? _findById(List<MiniAppEntity> apps, String id) {
    for (final a in apps) {
      if (a.id == id) return a;
    }
    return null;
  }

  static double _clamp01(Object? v) {
    final d = v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    return d.clamp(0.0, 1.0);
  }

  /// 从文本中截取第一个平衡的 JSON 对象（容忍代码围栏/前后说明）。
  static String? _extractJsonObject(String raw) {
    final start = raw.indexOf('{');
    if (start < 0) return null;
    var depth = 0;
    var inStr = false;
    var escaped = false;
    for (var i = start; i < raw.length; i++) {
      final ch = raw[i];
      if (inStr) {
        if (escaped) {
          escaped = false;
        } else if (ch == r'\') {
          escaped = true;
        } else if (ch == '"') {
          inStr = false;
        }
        continue;
      }
      if (ch == '"') {
        inStr = true;
      } else if (ch == '{') {
        depth++;
      } else if (ch == '}') {
        depth--;
        if (depth == 0) return raw.substring(start, i + 1);
      }
    }
    return null;
  }
}
