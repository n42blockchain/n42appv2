import '../../domain/entities/ocr_document.dart';
import 'chat_media_bytes_resolver.dart';

enum OcrScript { latin, chinese, japanese, korean, devanagari }

abstract class ImageTextRecognitionService {
  bool get isSupported;

  Future<OcrDocument> recognize(
    ChatMediaData media, {
    Set<OcrScript> scripts = const {OcrScript.latin, OcrScript.chinese},
  });

  void dispose();
}

class ImageTextRecognitionException implements Exception {
  const ImageTextRecognitionException(this.message);

  final String message;

  @override
  String toString() => 'ImageTextRecognitionException: $message';
}
