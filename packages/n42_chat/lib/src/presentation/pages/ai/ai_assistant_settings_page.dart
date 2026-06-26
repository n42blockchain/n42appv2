import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/ai_assistant_entity.dart';
import '../../blocs/ai_assistant/ai_assistant_bloc.dart';
import '../../blocs/ai_assistant/ai_assistant_state.dart';
import '../../widgets/common/common_widgets.dart';

/// AI 助手设置页面
class AiAssistantSettingsPage extends StatelessWidget {
  const AiAssistantSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);

    return BlocBuilder<AiAssistantBloc, AiAssistantState>(
      builder: (context, state) {
        final assistant = state.assistant ?? AiAssistantEntity.defaultAssistant;

        return Scaffold(
          backgroundColor: context.pageBackground,
          appBar: N42AppBar(
            title: l10n?.aiAssistantSettings ?? 'AI Settings',
          ),
          body: ListView(
            children: [
              const SizedBox(height: 8),

              // 助手信息
              _buildSection(
                context,
                isDark,
                title: l10n?.aiAssistant ?? 'Assistant',
                children: [
                  _buildInfoTile(
                    context, isDark,
                    icon: Icons.smart_toy_outlined,
                    title: l10n?.aiAssistant ?? 'Name',
                    subtitle: assistant.name,
                  ),
                  _buildInfoTile(
                    context, isDark,
                    icon: Icons.memory_outlined,
                    title: l10n?.aiAssistantModel ?? 'Model',
                    subtitle: assistant.model ?? 'Default',
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 参数设置
              _buildSection(
                context,
                isDark,
                title: l10n?.aiAssistantSettings ?? 'Parameters',
                children: [
                  _buildInfoTile(
                    context, isDark,
                    icon: Icons.thermostat_outlined,
                    title: l10n?.aiAssistantTemperature ?? 'Temperature',
                    subtitle: assistant.temperature.toStringAsFixed(1),
                  ),
                  _buildInfoTile(
                    context, isDark,
                    icon: Icons.token_outlined,
                    title: l10n?.aiAssistantMaxTokens ?? 'Max Tokens',
                    subtitle: assistant.maxTokens.toString(),
                  ),
                  _buildInfoTile(
                    context, isDark,
                    icon: Icons.history_outlined,
                    title: l10n?.aiAssistantContextWindow ?? 'Context Window',
                    subtitle: '${assistant.contextWindow} messages',
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 服务状态
              _buildSection(
                context,
                isDark,
                title: l10n?.aiAssistantServiceStatus ?? 'Service Status',
                children: [
                  _buildInfoTile(
                    context, isDark,
                    icon: state.isAvailable ? Icons.check_circle_outline : Icons.error_outline,
                    title: l10n?.aiAssistantServiceStatus ?? 'Availability',
                    subtitle: state.isAvailable
                        ? (l10n?.aiAssistantAvailable ?? 'Available')
                        : (l10n?.aiAssistantUnavailable ?? 'Not configured'),
                    subtitleColor: state.isAvailable ? AppColors.success : AppColors.warning,
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    bool isDark, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? subtitleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: context.textPrimary,
        ),
      ),
      trailing: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: subtitleColor ?? context.textSecondary,
        ),
      ),
    );
  }
}
