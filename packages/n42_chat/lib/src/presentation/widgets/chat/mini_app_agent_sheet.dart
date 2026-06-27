import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/services/mini_app_agent_planner.dart';
import '../../../core/services/mini_app_agent_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../helpers/mini_app_launcher_helper.dart';

/// 超级应用 AI 助手面板（#19 Agentic）
///
/// 用户输入一句话「办点事」，编排器（[MiniAppAgentService]）规划出匹配的
/// Mini App + 参数，确认后直接打开对应应用。
class MiniAppAgentSheet extends StatefulWidget {
  final String roomId;

  const MiniAppAgentSheet({super.key, required this.roomId});

  static Future<void> show(BuildContext context, {required String roomId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MiniAppAgentSheet(roomId: roomId),
    );
  }

  @override
  State<MiniAppAgentSheet> createState() => _MiniAppAgentSheetState();
}

class _MiniAppAgentSheetState extends State<MiniAppAgentSheet> {
  final TextEditingController _controller = TextEditingController();
  final MiniAppAgentService _agent = MiniAppAgentService();

  bool _loading = false;
  bool _ran = false;
  MiniAppPlan? _plan;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _loading = true;
      _ran = false;
      _plan = null;
    });
    final plan = await _agent.plan(text);
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _loading = false;
      _ran = true;
    });
  }

  void _open() {
    final plan = _plan;
    if (plan == null) return;
    final app = MiniAppLauncherHelper.findBuiltInAppById(plan.appId);
    Navigator.pop(context);
    if (app != null) {
      MiniAppLauncherHelper.openApp<void>(
        context,
        app: app,
        roomId: widget.roomId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'AI Assistant',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Describe what you want to do — I\'ll open the right mini app.',
            style: TextStyle(fontSize: 13, color: context.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _run(),
            decoration: InputDecoration(
              hintText: 'e.g. swap ETH to USDC',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _loading ? null : _run,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_ran && _plan == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No matching mini app found. Try rephrasing.',
                style: TextStyle(color: context.textTertiary),
              ),
            )
          else if (_plan != null)
            _buildResult(_plan!),
        ],
      ),
    );
  }

  Widget _buildResult(MiniAppPlan plan) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.pageBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.apps_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  plan.appName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
              ),
              Text(
                '${(plan.confidence * 100).round()}%',
                style: TextStyle(fontSize: 12, color: context.textTertiary),
              ),
            ],
          ),
          if (plan.reason.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(plan.reason,
                style: TextStyle(fontSize: 13, color: context.textSecondary)),
          ],
          if (plan.params.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: plan.params.entries
                  .map((e) => Chip(
                        label: Text('${e.key}: ${e.value}'),
                        backgroundColor: context.surfaceColor,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _open,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text('Open ${plan.appName}'),
            ),
          ),
        ],
      ),
    );
  }
}
