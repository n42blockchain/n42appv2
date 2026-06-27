import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';

/// 斜杠命令条目
class SlashCommandItem {
  final String command;    // 命令名（不含 /）
  final String usage;      // 完整用法
  final String description;
  final IconData icon;

  const SlashCommandItem({
    required this.command,
    required this.usage,
    required this.description,
    required this.icon,
  });
}

/// 斜杠命令选择器（显示在输入框上方）
class SlashCommandPicker extends StatelessWidget {
  final String query; // 用户已输入的命令前缀（不含 /）
  final void Function(SlashCommandItem) onSelect;

  const SlashCommandPicker({
    super.key,
    required this.query,
    required this.onSelect,
  });

  List<SlashCommandItem> _buildCommands(BuildContext context) {
    final l10n = S.of(context);
    return [
      SlashCommandItem(
        command: 'help',
        usage: '/help',
        description: l10n?.chatCommandHelp ?? '/help — Show all commands',
        icon: Icons.help_outline,
      ),
      SlashCommandItem(
        command: 'price',
        usage: '/price <token>',
        description: l10n?.chatCommandPrice ?? '/price — Get token price',
        icon: Icons.show_chart,
      ),
      SlashCommandItem(
        command: 'balance',
        usage: '/balance',
        description: l10n?.chatCommandBalance ?? '/balance — Show wallet balance',
        icon: Icons.account_balance_wallet_outlined,
      ),
      SlashCommandItem(
        command: 'chains',
        usage: '/chains',
        description: l10n?.chatCommandChains ?? '/chains — List 236+ supported chains',
        icon: Icons.hub_outlined,
      ),
      SlashCommandItem(
        command: 'poll',
        usage: '/poll',
        description: l10n?.chatCommandPoll ?? '/poll — Create a poll',
        icon: Icons.how_to_vote_outlined,
      ),
      SlashCommandItem(
        command: 'announce',
        usage: '/announce <message>',
        description: l10n?.chatCommandAnnounce ?? '/announce — Send announcement',
        icon: Icons.campaign_outlined,
      ),
      SlashCommandItem(
        command: 'welcome',
        usage: '/welcome',
        description: l10n?.chatCommandWelcome ?? '/welcome — Set welcome message',
        icon: Icons.waving_hand_outlined,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final commands = _buildCommands(context)
        .where((c) => c.command.startsWith(query.toLowerCase()))
        .toList();

    if (commands.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          top: BorderSide(
            color: context.dividerColor,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: commands.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: 56,
          color: context.dividerColor,
        ),
        itemBuilder: (context, index) {
          final item = commands[index];
          return ListTile(
            dense: true,
            leading: Icon(
              item.icon,
              color: AppColors.primary,
              size: 20,
            ),
            title: Text(
              '/${item.command}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryOf(isDark),
              ),
            ),
            subtitle: Text(
              item.description,
              style: TextStyle(
                fontSize: 12,
                color: context.textSecondary,
              ),
            ),
            onTap: () => onSelect(item),
          );
        },
      ),
    );
  }
}
