import 'package:equatable/equatable.dart';

/// Bot 命令定义
class BotCommandDefinition extends Equatable {
  /// 命令名（不含 /）
  final String command;

  /// 用法说明
  final String usage;

  /// 描述
  final String description;

  /// 参数提示（例如 `<token>`）
  final String? argHint;

  /// 是否仅限管理员
  final bool adminOnly;

  const BotCommandDefinition({
    required this.command,
    required this.usage,
    required this.description,
    this.argHint,
    this.adminOnly = false,
  });

  @override
  List<Object?> get props => [command];
}

/// Bot 命令执行结果类型
enum BotCommandResultType {
  /// 显示弹窗/底部面板
  showPanel,

  /// 直接发送消息到 Matrix 聊天室
  sendMessage,

  /// 静默处理（dismiss 输入框即可）
  dismiss,

  /// 命令执行出错
  error,

  /// 命令未知
  unknown,
}

/// Bot 命令执行结果
class BotCommandResult extends Equatable {
  final BotCommandResultType type;

  /// 若 type == sendMessage，这是要发送的文本
  final String? messageText;

  /// 若 type == showPanel，这是面板标题
  final String? panelTitle;

  /// 若 type == showPanel，这是要展示的文本内容（富文本）
  final String? panelContent;

  /// 错误描述（type == error 时使用）
  final String? errorMessage;

  const BotCommandResult.showPanel({
    required String title,
    required String content,
  })  : type = BotCommandResultType.showPanel,
        panelTitle = title,
        panelContent = content,
        messageText = null,
        errorMessage = null;

  const BotCommandResult.sendMessage(String text)
      : type = BotCommandResultType.sendMessage,
        messageText = text,
        panelTitle = null,
        panelContent = null,
        errorMessage = null;

  const BotCommandResult.dismiss()
      : type = BotCommandResultType.dismiss,
        messageText = null,
        panelTitle = null,
        panelContent = null,
        errorMessage = null;

  const BotCommandResult.error(String message)
      : type = BotCommandResultType.error,
        errorMessage = message,
        messageText = null,
        panelTitle = null,
        panelContent = null;

  const BotCommandResult.unknown()
      : type = BotCommandResultType.unknown,
        messageText = null,
        panelTitle = null,
        panelContent = null,
        errorMessage = null;

  @override
  List<Object?> get props => [type, messageText, panelTitle, errorMessage];
}

/// 所有内置命令的静态定义列表
class BuiltInBotCommands {
  static const List<BotCommandDefinition> all = [
    BotCommandDefinition(
      command: 'help',
      usage: '/help',
      description: 'Show all available commands',
    ),
    BotCommandDefinition(
      command: 'price',
      usage: '/price <token>',
      description: 'Get real-time token price',
      argHint: '<token>',
    ),
    BotCommandDefinition(
      command: 'balance',
      usage: '/balance',
      description: 'Show your wallet balance',
    ),
    BotCommandDefinition(
      command: 'chains',
      usage: '/chains',
      description: 'List all 236+ supported chains',
    ),
    BotCommandDefinition(
      command: 'poll',
      usage: '/poll',
      description: 'Create a poll',
    ),
    BotCommandDefinition(
      command: 'announce',
      usage: '/announce <message>',
      description: 'Send an announcement',
      argHint: '<message>',
      adminOnly: true,
    ),
    BotCommandDefinition(
      command: 'welcome',
      usage: '/welcome',
      description: 'Configure welcome message',
      adminOnly: true,
    ),
  ];

  static BotCommandDefinition? find(String command) {
    final lowerCommand = command.toLowerCase();
    for (final c in all) {
      if (c.command == lowerCommand) return c;
    }
    return null;
  }
}
