import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/local_llm_service.dart';
import '../../../core/theme/app_colors.dart';

/// 端侧 AI 设置页（设备能力 / 模型下载 / 启用开关）
class LocalLlmSettingsPage extends StatefulWidget {
  const LocalLlmSettingsPage({super.key});

  @override
  State<LocalLlmSettingsPage> createState() => _LocalLlmSettingsPageState();
}

class _LocalLlmSettingsPageState extends State<LocalLlmSettingsPage> {
  final LocalLlmService _service = getIt<LocalLlmService>();

  @override
  void initState() {
    super.initState();
    _service.init();
  }

  String _statusLabel(LocalLlmState s) {
    switch (s) {
      case LocalLlmState.unavailable:
        return 'Not supported on this device';
      case LocalLlmState.notDownloaded:
        return 'Model not downloaded';
      case LocalLlmState.downloading:
        return 'Downloading…';
      case LocalLlmState.ready:
        return 'Ready (on-device)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(title: const Text('On-device AI')),
      body: ValueListenableBuilder<LocalLlmState>(
        valueListenable: _service.stateNotifier,
        builder: (ctx, state, _) {
          final available = state != LocalLlmState.unavailable;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: context.surfaceColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.memory,
                              color: available
                                  ? AppColors.success
                                  : context.textTertiary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _statusLabel(state),
                              style: TextStyle(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'When enabled and ready, AI features (summarize, rewrite, '
                        'translate, replies) run fully on-device — data never '
                        'leaves your phone. Otherwise they use the cloud provider.',
                        style: TextStyle(
                            color: context.textSecondary, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Use on-device AI'),
                subtitle: const Text('Prefer local inference when ready'),
                value: _service.enabled,
                activeThumbColor: AppColors.primary,
                onChanged: available
                    ? (v) => setState(() => _service.enabled = v)
                    : null,
              ),
              if (state == LocalLlmState.notDownloaded)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FilledButton.icon(
                    style:
                        FilledButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () => _service.download(),
                    icon: const Icon(Icons.download),
                    label: const Text('Download model'),
                  ),
                ),
              if (state == LocalLlmState.downloading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!available)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'On-device inference requires the native runtime '
                    '(Android MediaPipe / iOS Core ML). It will activate '
                    'automatically once the platform handler is available.',
                    style:
                        TextStyle(color: context.textTertiary, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
