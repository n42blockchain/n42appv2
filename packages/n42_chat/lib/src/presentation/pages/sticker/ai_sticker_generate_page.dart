import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/ai_sticker_service.dart';
import '../../../core/theme/app_colors.dart';

/// AI 生成贴纸页
///
/// 输入文字 prompt → 云端文生图 → 预览 → 加入「AI Stickers」包。
/// 对标 iMessage Genmoji / WhatsApp Meta imagine sticker。
class AiStickerGeneratePage extends StatefulWidget {
  const AiStickerGeneratePage({super.key});

  @override
  State<AiStickerGeneratePage> createState() => _AiStickerGeneratePageState();
}

class _AiStickerGeneratePageState extends State<AiStickerGeneratePage> {
  final TextEditingController _promptController = TextEditingController();
  late final AiStickerService _service = getIt<AiStickerService>();

  bool _generating = false;
  bool _adding = false;
  Uint8List? _preview;
  String? _error;
  String _lastPrompt = '';

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty || _generating) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _generating = true;
      _error = null;
      _preview = null;
      _lastPrompt = prompt;
    });
    try {
      final result = await _service.generate(prompt);
      if (!mounted) return;
      setState(() => _preview = result.bytes);
    } on AiServiceException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _addToPack() async {
    final bytes = _preview;
    if (bytes == null || _adding) return;
    setState(() => _adding = true);
    try {
      final ok = await _service.addToPack(bytes, label: _lastPrompt);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? 'Added to "AI Stickers"' : 'Failed to add sticker',
          ),
        ),
      );
      if (ok) Navigator.of(context).pop(true);
    } on AiServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Sticker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _promptController,
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Describe your sticker',
                hintText: 'e.g. a happy orange cat with sunglasses',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _generate(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _generating ? null : _generate,
              icon: _generating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_generating ? 'Generating…' : 'Generate'),
            ),
            const SizedBox(height: 20),
            Expanded(child: Center(child: _buildPreview())),
            if (_preview != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _adding ? null : _addToPack,
                icon: _adding
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_reaction_outlined),
                label: Text(_adding ? 'Adding…' : 'Add to stickers'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_error != null) {
      return Text(
        _error!,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.error),
      );
    }
    if (_generating) {
      return const Text('Generating your sticker…');
    }
    final preview = _preview;
    if (preview != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          preview,
          width: 220,
          height: 220,
          fit: BoxFit.contain,
        ),
      );
    }
    return const Opacity(
      opacity: 0.6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 48),
          SizedBox(height: 8),
          Text('Describe a sticker and tap Generate'),
        ],
      ),
    );
  }
}
