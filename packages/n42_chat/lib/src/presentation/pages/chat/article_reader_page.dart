import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/article_reader_utils.dart';
import '../../../core/utils/message_markdown_utils.dart';
import '../../widgets/common/common_widgets.dart';

/// 长文阅读模式
///
/// 把频道长文/长消息以「阅读器」排版呈现：限定阅读宽度、放大行距、可调字号
/// （持久化）、Markdown 富排版、估算阅读时长。提升公众号/订阅号文章阅读体验。
class ArticleReaderPage extends StatefulWidget {
  final String content;
  final String? title;

  const ArticleReaderPage({
    super.key,
    required this.content,
    this.title,
  });

  @override
  State<ArticleReaderPage> createState() => _ArticleReaderPageState();
}

class _ArticleReaderPageState extends State<ArticleReaderPage> {
  static const String _fontScaleKey = 'n42.chat.article_font_scale';
  static const double _minScale = 0.8;
  static const double _maxScale = 1.6;

  double _fontScale = 1.0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadScale();
  }

  Future<void> _loadScale() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _fontScale = (prefs.getDouble(_fontScaleKey) ?? 1.0)
          .clamp(_minScale, _maxScale);
      _loaded = true;
    });
  }

  Future<void> _setScale(double scale) async {
    final clamped = scale.clamp(_minScale, _maxScale);
    setState(() => _fontScale = clamped);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, clamped);
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.title?.trim().isNotEmpty ?? false)
        ? widget.title!.trim()
        : ArticleReaderUtils.extractTitle(widget.content);
    final minutes = ArticleReaderUtils.estimateReadingMinutes(widget.content);
    final display = sanitizeMarkdownDisplayText(widget.content);

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: 'Reading',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            tooltip: 'A-',
            onPressed: _fontScale <= _minScale
                ? null
                : () => _setScale(_fontScale - 0.1),
            icon: const Text('A', style: TextStyle(fontSize: 14)),
          ),
          IconButton(
            tooltip: 'A+',
            onPressed: _fontScale >= _maxScale
                ? null
                : () => _setScale(_fontScale + 0.1),
            icon: const Text('A', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
      body: !_loaded
          ? const SizedBox.shrink()
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 26 * _fontScale,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule,
                            size: 14, color: context.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          '$minutes min read',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    MarkdownBody(
                      data: display,
                      selectable: true,
                      softLineBreak: true,
                      onTapLink: (text, href, title) async {
                        if (href == null) return;
                        final uri = Uri.tryParse(href);
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      styleSheet: _readerStyle(context, _fontScale),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  MarkdownStyleSheet _readerStyle(BuildContext context, double scale) {
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    final body = TextStyle(
      fontSize: 17 * scale,
      height: 1.7,
      color: context.textPrimary,
    );
    return base.copyWith(
      p: body,
      listBullet: body,
      h1: TextStyle(
          fontSize: 24 * scale, height: 1.4, fontWeight: FontWeight.w700),
      h2: TextStyle(
          fontSize: 21 * scale, height: 1.4, fontWeight: FontWeight.w700),
      h3: TextStyle(
          fontSize: 19 * scale, height: 1.4, fontWeight: FontWeight.w600),
      blockquoteDecoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
    );
  }
}
