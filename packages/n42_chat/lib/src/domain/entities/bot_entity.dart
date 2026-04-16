import 'package:equatable/equatable.dart';
import 'bot_command_entity.dart';

/// Bot 注册实体
class BotEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? avatarUrl;
  final String? webhookUrl;
  final List<BotCommandDefinition> commands;
  final String createdBy; // userId of creator
  final bool isVerified;
  final bool isBuiltIn;
  final String category; // 'defi', 'utility', 'social', 'game', 'moderation'
  final int installCount;

  const BotEntity({
    required this.id,
    required this.name,
    required this.description,
    this.avatarUrl,
    this.webhookUrl,
    this.commands = const [],
    this.createdBy = '',
    this.isVerified = false,
    this.isBuiltIn = false,
    this.category = 'utility',
    this.installCount = 0,
  });

  factory BotEntity.fromJson(Map<String, dynamic> json) {
    return BotEntity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      webhookUrl: json['webhook_url'] as String?,
      commands: (json['commands'] as List<dynamic>?)
              ?.map((e) => BotCommandDefinition(
                    command: e['command'] as String? ?? '',
                    usage: e['usage'] as String? ?? '',
                    description: e['description'] as String? ?? '',
                  ))
              .toList() ??
          const [],
      createdBy: json['created_by'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
      isBuiltIn: json['is_built_in'] as bool? ?? false,
      category: json['category'] as String? ?? 'utility',
      installCount: json['install_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    if (webhookUrl != null) 'webhook_url': webhookUrl,
    'commands': commands
        .map((c) => {
              'command': c.command,
              'usage': c.usage,
              'description': c.description,
            })
        .toList(),
    'created_by': createdBy,
    'is_verified': isVerified,
    'is_built_in': isBuiltIn,
    'category': category,
    'install_count': installCount,
  };

  /// Built-in bots that come with N42
  static List<BotEntity> get builtInBots => const [
    BotEntity(
      id: 'n42-price-bot',
      name: 'Price Bot',
      description: 'Real-time crypto prices, alerts, and market data',
      category: 'defi',
      isBuiltIn: true,
      isVerified: true,
      installCount: 10000,
      commands: [
        BotCommandDefinition(command: 'price', usage: '/price ETH', description: 'Get token price'),
        BotCommandDefinition(command: 'chart', usage: '/chart BTC 7d', description: 'Price chart'),
      ],
    ),
    BotEntity(
      id: 'n42-wallet-bot',
      name: 'Wallet Bot',
      description: 'Check balances, send tokens, and manage your wallet',
      category: 'defi',
      isBuiltIn: true,
      isVerified: true,
      installCount: 8000,
      commands: [
        BotCommandDefinition(command: 'balance', usage: '/balance', description: 'Show wallet balance'),
        BotCommandDefinition(command: 'chains', usage: '/chains', description: 'List supported chains'),
      ],
    ),
    BotEntity(
      id: 'n42-moderation-bot',
      name: 'Mod Bot',
      description: 'Auto-moderation, welcome messages, and group management',
      category: 'moderation',
      isBuiltIn: true,
      isVerified: true,
      installCount: 5000,
      commands: [
        BotCommandDefinition(command: 'announce', usage: '/announce <msg>', description: 'Send announcement'),
        BotCommandDefinition(command: 'welcome', usage: '/welcome <msg>', description: 'Set welcome message'),
        BotCommandDefinition(command: 'poll', usage: '/poll <question>', description: 'Create a poll'),
      ],
    ),
    BotEntity(
      id: 'n42-defi-alert-bot',
      name: 'DeFi Alert Bot',
      description: 'Monitor DeFi positions, liquidation alerts, and yield tracking',
      category: 'defi',
      isBuiltIn: true,
      isVerified: true,
      installCount: 3000,
    ),
    BotEntity(
      id: 'n42-nft-bot',
      name: 'NFT Bot',
      description: 'NFT floor price tracking, mint alerts, and collection stats',
      category: 'utility',
      isBuiltIn: true,
      isVerified: true,
      installCount: 2500,
    ),
  ];

  @override
  List<Object?> get props => [id, name, isVerified, installCount];
}
