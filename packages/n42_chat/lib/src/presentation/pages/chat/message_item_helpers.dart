import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/ai_service.dart';
import '../../widgets/chat/ai_link_summary_card.dart';

/// AI 链接摘要包装器
///
/// 自管理 loading/result 状态，内嵌在 UrlPreviewWidget 下方
class AiLinkSummaryWrapper extends StatefulWidget {
  final String url;
  const AiLinkSummaryWrapper({super.key, required this.url});
  @override
  State<AiLinkSummaryWrapper> createState() => _AiLinkSummaryWrapperState();
}

class _AiLinkSummaryWrapperState extends State<AiLinkSummaryWrapper> {
  String? _summary;
  bool _isLoading = false;

  void _generate() async {
    setState(() => _isLoading = true);
    try {
      final result = await getIt<AiService>().summarizeUrl(widget.url, '');
      if (mounted) setState(() { _summary = result; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AiLinkSummaryCard(
      url: widget.url,
      summary: _summary,
      isLoading: _isLoading,
      onGenerate: _generate,
    );
  }
}

