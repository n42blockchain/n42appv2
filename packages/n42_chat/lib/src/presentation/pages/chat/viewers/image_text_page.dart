import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/image_text_recognition_service.dart';
import '../../../../core/services/image_text_session_service.dart';
import '../../../../core/services/image_translation_coordinator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_text_l10n.dart';
import '../../../../domain/entities/message_entity.dart';
import '../../../../domain/entities/ocr_document.dart';

enum ImageTextMode { extract, translate }

class ImageTextPage extends StatefulWidget {
  const ImageTextPage({
    super.key,
    required this.message,
    this.initialMode = ImageTextMode.extract,
    this.initialTargetLanguage = 'en',
    this.onForwardText,
    this.onFavoriteText,
    this.onSearchText,
  });

  final MessageEntity message;
  final ImageTextMode initialMode;
  final String initialTargetLanguage;
  final ValueChanged<String>? onForwardText;
  final ValueChanged<String>? onFavoriteText;
  final ValueChanged<String>? onSearchText;

  @override
  State<ImageTextPage> createState() => _ImageTextPageState();
}

class _ImageTextPageState extends State<ImageTextPage> {
  static const _scripts = <OcrScript>{
    OcrScript.latin,
    OcrScript.chinese,
    OcrScript.japanese,
    OcrScript.korean,
    OcrScript.devanagari,
  };

  static const _languages = <String, String>{
    'en': 'English',
    'zh': '中文',
    'zh_TW': '繁體中文',
    'ja': '日本語',
    'ko': '한국어',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'pt': 'Português',
    'ru': 'Русский',
    'hi': 'हिन्दी',
  };

  Uint8List? _bytes;
  OcrDocument? _document;
  ImageTranslationResult? _translation;
  Set<String> _selectedIds = {};
  late ImageTextMode _mode;
  late String _targetLanguage;
  bool _loading = true;
  bool _translating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _targetLanguage = _languages.containsKey(widget.initialTargetLanguage)
        ? widget.initialTargetLanguage
        : 'en';
    _recognize();
  }

  Future<void> _recognize() async {
    setState(() {
      _loading = true;
      _error = null;
      _document = null;
      _translation = null;
      _selectedIds = {};
    });
    try {
      final session = await getIt<ImageTextSessionService>().load(
        widget.message,
        scripts: _scripts,
      );
      if (!mounted) return;
      setState(() {
        _bytes = session.media.bytes;
        _document = session.document;
        _selectedIds = session.document.blocks.map((block) => block.id).toSet();
        _loading = false;
      });
      if (_mode == ImageTextMode.translate && !session.document.isEmpty) {
        await _translate();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  Future<void> _translate({bool allowRemoteFallback = false}) async {
    final document = _document;
    if (document == null || document.isEmpty || _translating) return;
    setState(() {
      _translating = true;
      _error = null;
    });
    try {
      final result = await getIt<ImageTranslationCoordinator>().translate(
        document: document,
        targetLanguage: _targetLanguage,
        allowRemoteFallback: allowRemoteFallback,
      );
      if (!mounted) return;
      setState(() {
        _translation = result;
        _mode = ImageTextMode.translate;
        _translating = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _translating = false);
      if (!allowRemoteFallback) {
        final consent = await _confirmRemoteFallback();
        if (consent && mounted) {
          await _translate(allowRemoteFallback: true);
          return;
        }
      }
      if (mounted) setState(() => _error = '$error');
    }
  }

  Future<bool> _confirmRemoteFallback() async {
    final strings = ImageTextL10n.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.remoteConsentTitle),
            content: Text(strings.remoteConsentBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(strings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(strings.continueLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  String get _selectedText {
    final document = _document;
    if (document == null) return '';
    if (_mode == ImageTextMode.translate && _translation != null) {
      return _translation!.blocks
          .where((block) => _selectedIds.contains(block.sourceBlockId))
          .map((block) => block.translatedText)
          .join('\n');
    }
    return document.blocks
        .where((block) => _selectedIds.contains(block.id))
        .map((block) => block.text)
        .join('\n');
  }

  Future<void> _copy() async {
    final text = _selectedText;
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(ImageTextL10n.of(context).copied)));
  }

  Future<void> _share() async {
    final text = _selectedText;
    if (text.isEmpty) return;
    await SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final strings = ImageTextL10n.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: Text(
          _mode == ImageTextMode.extract
              ? strings.extractText
              : strings.translateImage,
        ),
        actions: [
          if (_document != null && !_document!.isEmpty)
            PopupMenuButton<String>(
              tooltip: strings.targetLanguage,
              icon: const Icon(Icons.language),
              initialValue: _targetLanguage,
              onSelected: (value) {
                setState(() {
                  _targetLanguage = value;
                  _translation = null;
                });
                _translate();
              },
              itemBuilder: (_) => _languages.entries
                  .map(
                    (entry) => PopupMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
      body: _buildBody(strings),
      bottomNavigationBar: _document == null || _document!.isEmpty
          ? null
          : _buildActions(strings),
    );
  }

  Widget _buildBody(ImageTextL10n strings) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              strings.recognizing,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }
    if (_error != null && _document == null) {
      return _ErrorState(message: _error!, onRetry: _recognize);
    }
    final document = _document!;
    if (document.isEmpty) {
      return _ErrorState(message: strings.noText, onRetry: _recognize);
    }
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) => _ImageOverlay(
                bytes: _bytes!,
                imageSize: document.pixelSize,
                document: document,
                translation: _mode == ImageTextMode.translate
                    ? _translation
                    : null,
                selectedIds: _selectedIds,
                onToggle: (id) => setState(() {
                  _selectedIds = {..._selectedIds};
                  _selectedIds.contains(id)
                      ? _selectedIds.remove(id)
                      : _selectedIds.add(id);
                }),
              ),
            ),
          ),
        ),
        if (_translation != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<ImageTextMode>(
                    segments: [
                      ButtonSegment(
                        value: ImageTextMode.extract,
                        label: Text(strings.original),
                      ),
                      ButtonSegment(
                        value: ImageTextMode.translate,
                        label: Text(strings.translation),
                      ),
                    ],
                    selected: {_mode},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) =>
                        setState(() => _mode = selection.first),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: _translation!.isOnDevice
                      ? strings.onDevice
                      : strings.cloudFallback,
                  child: Icon(
                    _translation!.isOnDevice
                        ? Icons.phone_android
                        : Icons.cloud_outlined,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        if (_translating)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(strings.translating),
              ],
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _error!,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        Expanded(
          flex: 2,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            itemCount: document.blocks.length,
            itemBuilder: (context, index) {
              final block = document.blocks[index];
              final translated = _translation?.blocks
                  .where((item) => item.sourceBlockId == block.id)
                  .firstOrNull;
              return CheckboxListTile(
                value: _selectedIds.contains(block.id),
                onChanged: (_) => setState(() {
                  _selectedIds = {..._selectedIds};
                  _selectedIds.contains(block.id)
                      ? _selectedIds.remove(block.id)
                      : _selectedIds.add(block.id);
                }),
                title: Text(
                  _mode == ImageTextMode.translate && translated != null
                      ? translated.translatedText
                      : block.text,
                ),
                subtitle: _mode == ImageTextMode.translate && translated != null
                    ? Text(block.text)
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActions(ImageTextL10n strings) => SafeArea(
    child: Material(
      color: const Color(0xFF1C1C1E),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            TextButton(
              onPressed: () => setState(() {
                final all = _document!.blocks.map((block) => block.id).toSet();
                _selectedIds = _selectedIds.length == all.length ? {} : all;
              }),
              child: Text(
                _selectedIds.length == _document!.blocks.length
                    ? strings.clear
                    : strings.selectAll,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: _selectedText.isEmpty ? null : _copy,
              tooltip: strings.copy,
              icon: const Icon(Icons.copy_outlined),
            ),
            IconButton(
              onPressed: _selectedText.isEmpty ? null : _share,
              tooltip: strings.share,
              icon: const Icon(Icons.share_outlined),
            ),
            if (widget.onForwardText != null ||
                widget.onFavoriteText != null ||
                widget.onSearchText != null)
              PopupMenuButton<String>(
                enabled: _selectedText.isNotEmpty,
                onSelected: (value) {
                  final text = _selectedText;
                  if (text.isEmpty) return;
                  switch (value) {
                    case 'forward':
                      widget.onForwardText?.call(text);
                    case 'favorite':
                      widget.onFavoriteText?.call(text);
                    case 'search':
                      widget.onSearchText?.call(text);
                  }
                },
                itemBuilder: (_) => [
                  if (widget.onForwardText != null)
                    PopupMenuItem(
                      value: 'forward',
                      child: Text(strings.forward),
                    ),
                  if (widget.onFavoriteText != null)
                    PopupMenuItem(
                      value: 'favorite',
                      child: Text(strings.favorite),
                    ),
                  if (widget.onSearchText != null)
                    PopupMenuItem(value: 'search', child: Text(strings.search)),
                ],
              ),
            const SizedBox(width: 4),
            FilledButton.icon(
              onPressed: _translating ? null : _translate,
              icon: const Icon(Icons.translate, size: 18),
              label: Text(strings.translateImage),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ImageOverlay extends StatelessWidget {
  const _ImageOverlay({
    required this.bytes,
    required this.imageSize,
    required this.document,
    required this.translation,
    required this.selectedIds,
    required this.onToggle,
  });

  final Uint8List bytes;
  final Size imageSize;
  final OcrDocument document;
  final ImageTranslationResult? translation;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) => Center(
    child: AspectRatio(
      aspectRatio: imageSize.width / imageSize.height,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(bytes, fit: BoxFit.contain, gaplessPlayback: true),
            ...document.blocks.map((block) {
              final rect = block.normalizedRect;
              final translated = translation?.blocks
                  .where((item) => item.sourceBlockId == block.id)
                  .firstOrNull;
              return Positioned(
                left: rect.left * constraints.maxWidth,
                top: rect.top * constraints.maxHeight,
                width: rect.width * constraints.maxWidth,
                height: rect.height * constraints.maxHeight,
                child: GestureDetector(
                  onTap: () => onToggle(block.id),
                  child: Container(
                    decoration: BoxDecoration(
                      color: translated == null
                          ? Colors.transparent
                          : Colors.black.withValues(alpha: 0.78),
                      border: Border.all(
                        color: selectedIds.contains(block.id)
                            ? const Color(0xFF07C160)
                            : Colors.white70,
                        width: selectedIds.contains(block.id) ? 2 : 1,
                      ),
                    ),
                    child: translated == null
                        ? null
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              translated.translatedText,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = ImageTextL10n.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.text_snippet_outlined, size: 52),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: Text(strings.retry)),
          ],
        ),
      ),
    );
  }
}
