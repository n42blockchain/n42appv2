import 'package:equatable/equatable.dart';

/// AI 助手实体
///
/// 定义 AI 助手的角色、模型、系统提示等配置
class AiAssistantEntity extends Equatable {
  /// 助手唯一标识
  final String id;

  /// 助手名称
  final String name;

  /// 助手头像（emoji 或 URL）
  final String? avatar;

  /// 系统提示词
  final String systemPrompt;

  /// 使用的模型名称（null 表示使用 AI 服务配置的默认模型）
  final String? model;

  /// 上下文窗口大小（保留多少轮历史对话）
  final int contextWindow;

  /// 温度参数（0.0-2.0）
  final double temperature;

  /// 最大输出 token 数
  final int maxTokens;

  /// 是否为系统预设助手
  final bool isSystem;

  /// 创建时间
  final DateTime createdAt;

  const AiAssistantEntity({
    required this.id,
    required this.name,
    this.avatar,
    this.systemPrompt = 'You are a helpful AI assistant.',
    this.model,
    this.contextWindow = 20,
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.isSystem = false,
    required this.createdAt,
  });

  /// 默认 AI 助手
  static final AiAssistantEntity defaultAssistant = AiAssistantEntity(
    id: 'default',
    name: 'N42 AI',
    avatar: '🤖',
    systemPrompt:
        'You are N42 AI, a Web3-native assistant integrated into N42 Chat — '
        'a multi-chain crypto wallet supporting 236+ blockchains. '
        'You have deep knowledge of blockchain technology, DeFi protocols (Uniswap, Aave, Compound, etc.), '
        'NFTs, cross-chain bridges, gas optimization, and smart contract security. '
        'When users ask about transactions, token swaps, or DeFi strategies, provide clear, '
        'step-by-step guidance with safety warnings where appropriate. '
        'Always warn about common scams, phishing, and rug-pull risks. '
        'Never ask for private keys or seed phrases. '
        'Be concise, helpful, and friendly. Respond in the same language as the user.',
    contextWindow: 20,
    temperature: 0.7,
    maxTokens: 2048,
    isSystem: true,
    createdAt: DateTime(2025, 1, 1),
  );

  AiAssistantEntity copyWith({
    String? id,
    String? name,
    String? avatar,
    String? systemPrompt,
    String? model,
    int? contextWindow,
    double? temperature,
    int? maxTokens,
    bool? isSystem,
    DateTime? createdAt,
  }) {
    return AiAssistantEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      model: model ?? this.model,
      contextWindow: contextWindow ?? this.contextWindow,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'systemPrompt': systemPrompt,
    'model': model,
    'contextWindow': contextWindow,
    'temperature': temperature,
    'maxTokens': maxTokens,
    'isSystem': isSystem,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AiAssistantEntity.fromJson(Map<String, dynamic> json) {
    return AiAssistantEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      systemPrompt: json['systemPrompt'] as String? ?? 'You are a helpful AI assistant.',
      model: json['model'] as String?,
      contextWindow: json['contextWindow'] as int? ?? 20,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: json['maxTokens'] as int? ?? 2048,
      isSystem: json['isSystem'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id, name, avatar, systemPrompt, model,
    contextWindow, temperature, maxTokens, isSystem, createdAt,
  ];
}

/// AI 会话历史消息
class AiChatMessage extends Equatable {
  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime timestamp;
  final bool isStreaming;

  const AiChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  AiChatMessage copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
    bool? isStreaming,
  }) {
    return AiChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  static const _validRoles = {'user', 'assistant'};

  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as String;
    if (!_validRoles.contains(role)) {
      throw FormatException('Invalid AiChatMessage role: $role');
    }
    return AiChatMessage(
      id: json['id'] as String,
      role: role,
      content: json['content'] as String,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, role, content, timestamp, isStreaming];
}
