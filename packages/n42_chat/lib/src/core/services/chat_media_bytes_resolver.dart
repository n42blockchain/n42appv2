import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart'
    show EncryptedFile, decryptFileImplementation;
import 'package:mime/mime.dart';

import '../../data/datasources/matrix/matrix_client_manager.dart';
import '../../domain/entities/message_entity.dart';
import '../utils/debug_log.dart';
import '../utils/matrix_utils.dart' as mx_utils;

class ChatMediaData {
  const ChatMediaData({required this.bytes, required this.mimeType});

  final Uint8List bytes;
  final String mimeType;
}

class ChatMediaResolveException implements Exception {
  const ChatMediaResolveException(this.message);

  final String message;

  @override
  String toString() => 'ChatMediaResolveException: $message';
}

/// Resolves Matrix media into plaintext bytes for all image consumers.
///
/// The resolver deliberately accepts message metadata instead of a bare URL so
/// encrypted media is never accidentally passed to OCR, sharing, or cloud AI.
class ChatMediaBytesResolver {
  ChatMediaBytesResolver({
    MatrixClientManager? clientManager,
    http.Client? httpClient,
  }) : _clientManager = clientManager ?? MatrixClientManager.instance,
       _httpClient = httpClient ?? http.Client();

  final MatrixClientManager _clientManager;
  final http.Client _httpClient;

  Future<ChatMediaData> resolveMessage(
    MessageEntity message, {
    bool allowSelfDestructing = false,
  }) {
    if (message.type != MessageType.image) {
      throw const ChatMediaResolveException('Message is not an image');
    }
    if (message.isExpired ||
        message.isSelfDestructing && !allowSelfDestructing) {
      throw const ChatMediaResolveException(
        'Protected image cannot be extracted',
      );
    }
    final metadata = message.metadata;
    if (metadata == null) {
      throw const ChatMediaResolveException('Image metadata is missing');
    }
    return resolve(
      mediaUrl: metadata.mediaUrl,
      httpUrl: metadata.httpUrl,
      declaredMimeType: metadata.mimeType,
      encryptKey: metadata.encryptKey,
      encryptIv: metadata.encryptIv,
      encryptSha256: metadata.encryptSha256,
    );
  }

  Future<ChatMediaData> resolve({
    String? mediaUrl,
    String? httpUrl,
    String? declaredMimeType,
    String? encryptKey,
    String? encryptIv,
    String? encryptSha256,
  }) async {
    final client = _clientManager.client;
    final resolvedUrl = mediaUrl?.startsWith('mxc://') == true
        ? mx_utils.MatrixUtils.getMediaDownloadUrl(mediaUrl, client: client)
        : httpUrl ?? mediaUrl;
    if (resolvedUrl == null || resolvedUrl.isEmpty) {
      throw const ChatMediaResolveException('Image URL is missing');
    }

    try {
      final headers = mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(
        resolvedUrl,
        client: client,
      );
      final response = await _httpClient
          .get(Uri.parse(resolvedUrl), headers: headers)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        throw ChatMediaResolveException(
          'Image download failed (${response.statusCode})',
        );
      }

      Uint8List bytes = response.bodyBytes;
      final hasAnyEncryption =
          encryptKey != null || encryptIv != null || encryptSha256 != null;
      final hasAllEncryption =
          encryptKey != null && encryptIv != null && encryptSha256 != null;
      if (hasAnyEncryption && !hasAllEncryption) {
        throw const ChatMediaResolveException(
          'Encrypted image metadata is incomplete',
        );
      }
      if (hasAllEncryption) {
        final decrypted = await decryptFileImplementation(
          EncryptedFile(
            data: bytes,
            k: encryptKey,
            iv: encryptIv,
            sha256: encryptSha256,
          ),
        );
        if (decrypted == null || decrypted.isEmpty) {
          throw const ChatMediaResolveException(
            'Encrypted image validation or decryption failed',
          );
        }
        bytes = decrypted;
      }

      final detectedMime = lookupMimeType('', headerBytes: bytes);
      final mimeType = detectedMime ?? declaredMimeType ?? 'image/jpeg';
      if (!mimeType.startsWith('image/')) {
        throw const ChatMediaResolveException(
          'Downloaded media is not an image',
        );
      }
      return ChatMediaData(bytes: bytes, mimeType: mimeType);
    } on ChatMediaResolveException {
      rethrow;
    } catch (error) {
      debugLog('ChatMediaBytesResolver failed: ${error.runtimeType}');
      throw const ChatMediaResolveException('Unable to load image');
    }
  }

  void dispose() => _httpClient.close();
}
