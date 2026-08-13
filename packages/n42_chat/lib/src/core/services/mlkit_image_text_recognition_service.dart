import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as image_lib;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/ocr_document.dart';
import 'chat_media_bytes_resolver.dart';
import 'image_text_recognition_service.dart';

class MlKitImageTextRecognitionService implements ImageTextRecognitionService {
  final Map<OcrScript, TextRecognizer> _recognizers = {};

  @override
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  TextRecognizer _recognizer(OcrScript script) => _recognizers.putIfAbsent(
    script,
    () => TextRecognizer(script: _toMlKitScript(script)),
  );

  @override
  Future<OcrDocument> recognize(
    ChatMediaData media, {
    Set<OcrScript> scripts = const {OcrScript.latin, OcrScript.chinese},
  }) async {
    if (!isSupported) {
      throw const ImageTextRecognitionException(
        'Text recognition is unavailable on this platform',
      );
    }
    final decoded = image_lib.decodeImage(media.bytes);
    if (decoded == null || decoded.width <= 0 || decoded.height <= 0) {
      throw const ImageTextRecognitionException('Unsupported image format');
    }
    final pixelSize = Size(decoded.width.toDouble(), decoded.height.toDouble());
    final tempDir = await getTemporaryDirectory();
    final extension = switch (media.mimeType.toLowerCase()) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      'image/heic' || 'image/heif' => 'heic',
      'image/gif' => 'gif',
      'image/bmp' => 'bmp',
      _ => 'jpg',
    };
    final file = File(
      '${tempDir.path}/n42_ocr_${DateTime.now().microsecondsSinceEpoch}.$extension',
    );
    await file.writeAsBytes(media.bytes, flush: true);

    try {
      final candidates = <_LineCandidate>[];
      for (final script in scripts) {
        final result = await _recognizer(
          script,
        ).processImage(InputImage.fromFilePath(file.path));
        for (final block in result.blocks) {
          for (final line in block.lines) {
            final text = line.text.trim();
            if (text.isEmpty) continue;
            candidates.add(
              _LineCandidate(
                text: text,
                rect: _normalizeRect(line.boundingBox, pixelSize),
                confidence: line.confidence,
                languageCode: line.recognizedLanguages.isEmpty
                    ? null
                    : line.recognizedLanguages.first,
              ),
            );
          }
        }
      }
      final lines = _deduplicateAndSort(candidates);
      final blocks = <OcrBlock>[];
      for (var index = 0; index < lines.length; index++) {
        final candidate = lines[index];
        final blockId = 'block_$index';
        final line = OcrLine(
          id: 'line_$index',
          blockId: blockId,
          text: candidate.text,
          normalizedRect: candidate.rect,
          readingOrder: index,
          confidence: candidate.confidence,
          languageCode: candidate.languageCode,
        );
        blocks.add(
          OcrBlock(
            id: blockId,
            text: candidate.text,
            normalizedRect: candidate.rect,
            lines: [line],
            readingOrder: index,
            confidence: candidate.confidence,
            languageCode: candidate.languageCode,
          ),
        );
      }
      return OcrDocument(
        fullText: lines.map((line) => line.text).join('\n'),
        pixelSize: pixelSize,
        blocks: blocks,
        detectedLanguages: lines
            .map((line) => line.languageCode)
            .whereType<String>()
            .toSet(),
      );
    } catch (error) {
      if (error is ImageTextRecognitionException) rethrow;
      throw ImageTextRecognitionException('Text recognition failed: $error');
    } finally {
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  List<_LineCandidate> _deduplicateAndSort(List<_LineCandidate> candidates) {
    final kept = <_LineCandidate>[];
    candidates.sort((a, b) {
      final rowDelta = a.rect.top.compareTo(b.rect.top);
      return rowDelta != 0 ? rowDelta : a.rect.left.compareTo(b.rect.left);
    });
    for (final candidate in candidates) {
      final duplicate = kept.any(
        (existing) =>
            _intersectionOverUnion(existing.rect, candidate.rect) > 0.65 &&
            (_normalizedText(existing.text) ==
                    _normalizedText(candidate.text) ||
                existing.text.contains(candidate.text) ||
                candidate.text.contains(existing.text)),
      );
      if (!duplicate) kept.add(candidate);
    }
    return kept;
  }

  String _normalizedText(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'\s+'), '');

  double _intersectionOverUnion(Rect a, Rect b) {
    final intersection = a.intersect(b);
    if (intersection.isEmpty) return 0;
    final intersectionArea = intersection.width * intersection.height;
    final unionArea =
        a.width * a.height + b.width * b.height - intersectionArea;
    return unionArea <= 0 ? 0 : intersectionArea / unionArea;
  }

  Rect _normalizeRect(Rect rect, Size size) => Rect.fromLTRB(
    (rect.left / size.width).clamp(0.0, 1.0),
    (rect.top / size.height).clamp(0.0, 1.0),
    (rect.right / size.width).clamp(0.0, 1.0),
    (rect.bottom / size.height).clamp(0.0, 1.0),
  );

  TextRecognitionScript _toMlKitScript(OcrScript script) => switch (script) {
    OcrScript.latin => TextRecognitionScript.latin,
    OcrScript.chinese => TextRecognitionScript.chinese,
    OcrScript.japanese => TextRecognitionScript.japanese,
    OcrScript.korean => TextRecognitionScript.korean,
    OcrScript.devanagari => TextRecognitionScript.devanagiri,
  };

  @override
  void dispose() {
    for (final recognizer in _recognizers.values) {
      recognizer.close();
    }
    _recognizers.clear();
  }
}

class _LineCandidate {
  const _LineCandidate({
    required this.text,
    required this.rect,
    this.confidence,
    this.languageCode,
  });

  final String text;
  final Rect rect;
  final double? confidence;
  final String? languageCode;
}
