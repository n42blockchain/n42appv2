import 'dart:ui';

import 'package:equatable/equatable.dart';

class OcrDocument extends Equatable {
  const OcrDocument({
    required this.fullText,
    required this.pixelSize,
    required this.blocks,
    this.detectedLanguages = const <String>{},
    this.engineVersion = 'mlkit-v2',
  });

  final String fullText;
  final Size pixelSize;
  final List<OcrBlock> blocks;
  final Set<String> detectedLanguages;
  final String engineVersion;

  bool get isEmpty => blocks.isEmpty || fullText.trim().isEmpty;

  List<OcrLine> get orderedLines {
    final lines = blocks.expand((block) => block.lines).toList();
    lines.sort((a, b) => a.readingOrder.compareTo(b.readingOrder));
    return lines;
  }

  @override
  List<Object?> get props => [
    fullText,
    pixelSize,
    blocks,
    detectedLanguages,
    engineVersion,
  ];
}

class OcrBlock extends Equatable {
  const OcrBlock({
    required this.id,
    required this.text,
    required this.normalizedRect,
    required this.lines,
    required this.readingOrder,
    this.confidence,
    this.languageCode,
  });

  final String id;
  final String text;
  final Rect normalizedRect;
  final List<OcrLine> lines;
  final int readingOrder;
  final double? confidence;
  final String? languageCode;

  @override
  List<Object?> get props => [
    id,
    text,
    normalizedRect,
    lines,
    readingOrder,
    confidence,
    languageCode,
  ];
}

class OcrLine extends Equatable {
  const OcrLine({
    required this.id,
    required this.blockId,
    required this.text,
    required this.normalizedRect,
    required this.readingOrder,
    this.confidence,
    this.languageCode,
  });

  final String id;
  final String blockId;
  final String text;
  final Rect normalizedRect;
  final int readingOrder;
  final double? confidence;
  final String? languageCode;

  @override
  List<Object?> get props => [
    id,
    blockId,
    text,
    normalizedRect,
    readingOrder,
    confidence,
    languageCode,
  ];
}

class ImageTranslationBlock extends Equatable {
  const ImageTranslationBlock({
    required this.sourceBlockId,
    required this.sourceText,
    required this.translatedText,
    required this.normalizedRect,
  });

  final String sourceBlockId;
  final String sourceText;
  final String translatedText;
  final Rect normalizedRect;

  @override
  List<Object?> get props => [
    sourceBlockId,
    sourceText,
    translatedText,
    normalizedRect,
  ];
}

class ImageTranslationResult extends Equatable {
  const ImageTranslationResult({
    required this.blocks,
    required this.targetLanguage,
    required this.isOnDevice,
    this.sourceLanguage,
    this.provider,
  });

  final List<ImageTranslationBlock> blocks;
  final String? sourceLanguage;
  final String targetLanguage;
  final bool isOnDevice;
  final String? provider;

  String get fullText => blocks.map((block) => block.translatedText).join('\n');

  @override
  List<Object?> get props => [
    blocks,
    sourceLanguage,
    targetLanguage,
    isOnDevice,
    provider,
  ];
}
