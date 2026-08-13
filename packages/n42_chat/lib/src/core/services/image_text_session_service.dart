import '../../domain/entities/message_entity.dart';
import '../../domain/entities/ocr_document.dart';
import 'chat_media_bytes_resolver.dart';
import 'image_text_recognition_service.dart';

class ImageTextSession {
  const ImageTextSession({required this.media, required this.document});

  final ChatMediaData media;
  final OcrDocument document;
}

/// Small in-memory task cache shared by the long-press and image-viewer entry.
/// Plaintext media is never persisted and protected messages never enter it.
class ImageTextSessionService {
  ImageTextSessionService({
    required this.mediaResolver,
    required this.recognizer,
    this.capacity = 4,
  });

  final ChatMediaBytesResolver mediaResolver;
  final ImageTextRecognitionService recognizer;
  final int capacity;
  final Map<String, Future<ImageTextSession>> _sessions = {};

  Future<ImageTextSession> load(
    MessageEntity message, {
    required Set<OcrScript> scripts,
  }) {
    if (message.isExpired || message.isSelfDestructing) {
      throw const ChatMediaResolveException(
        'Protected image cannot be extracted',
      );
    }
    final scriptKey = scripts.map((script) => script.name).toList()..sort();
    final key = '${message.id}:${scriptKey.join(',')}';
    final existing = _sessions.remove(key);
    if (existing != null) {
      _sessions[key] = existing;
      return existing;
    }

    final task = _recognize(message, scripts);
    _sessions[key] = task;
    while (_sessions.length > capacity) {
      _sessions.remove(_sessions.keys.first);
    }
    task.catchError((Object error) {
      if (identical(_sessions[key], task)) _sessions.remove(key);
      throw error;
    });
    return task;
  }

  Future<ImageTextSession> _recognize(
    MessageEntity message,
    Set<OcrScript> scripts,
  ) async {
    final media = await mediaResolver.resolveMessage(message);
    final document = await recognizer.recognize(media, scripts: scripts);
    return ImageTextSession(media: media, document: document);
  }

  void invalidate(String messageId) {
    _sessions.removeWhere((key, _) => key.startsWith('$messageId:'));
  }

  void clear() => _sessions.clear();
}
