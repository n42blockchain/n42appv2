import 'package:flutter/foundation.dart';

import '../../domain/entities/bot_command_entity.dart';

/// 扩展 Bot 命令请求
class BotCommandRequest {
  final String command;
  final List<String> args;
  final String rawText;

  const BotCommandRequest({
    required this.command,
    required this.args,
    required this.rawText,
  });
}

/// 自定义 Bot 命令处理器
abstract class BotCommandHandler {
  List<BotCommandDefinition> get commands;

  Future<BotCommandResult?> handle(BotCommandRequest request);
}

/// 全局 Bot 命令注册表
class BotCommandRegistry {
  BotCommandRegistry._();

  static final BotCommandRegistry instance = BotCommandRegistry._();

  final Map<String, BotCommandHandler> _handlers = {};
  final Map<String, BotCommandDefinition> _definitions = {};

  void registerHandler(BotCommandHandler handler) {
    for (final definition in handler.commands) {
      final command = definition.command.toLowerCase();
      _handlers[command] = handler;
      _definitions[command] = definition;
    }
  }

  void unregisterHandler(BotCommandHandler handler) {
    final commandsToRemove = _handlers.entries
        .where((entry) => identical(entry.value, handler))
        .map((entry) => entry.key)
        .toList();
    for (final command in commandsToRemove) {
      _handlers.remove(command);
      _definitions.remove(command);
    }
  }

  BotCommandHandler? findHandler(String command) =>
      _handlers[command.toLowerCase()];

  BotCommandDefinition? findDefinition(String command) =>
      _definitions[command.toLowerCase()];

  List<BotCommandDefinition> get definitions => _definitions.values.toList()
    ..sort((a, b) => a.command.compareTo(b.command));

  @visibleForTesting
  void clear() {
    _handlers.clear();
    _definitions.clear();
  }
}
