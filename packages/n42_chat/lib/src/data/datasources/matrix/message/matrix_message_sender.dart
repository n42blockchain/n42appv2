import 'dart:typed_data';
import 'package:matrix/matrix.dart' as matrix;

import '../../../../domain/entities/message_entity.dart';
import '../matrix_client_manager.dart';
import 'matrix_media_sender.dart';
import 'matrix_media_uploader.dart';
import 'matrix_text_message_content.dart';
import '../../../../core/utils/debug_log.dart';

/// Matrix 消息发送器
///
/// 封装各类消息的发送逻辑：文本、位置、GIF、贴纸、自定义、系统通知、联系人名片等。
/// 媒体消息（图片、语音、视频、文件）委托给 [MatrixMediaSender]。
class MatrixMessageSender {
  final MatrixClientManager _clientManager;
  late final MatrixMediaSender _mediaSender;

  MatrixMessageSender(this._clientManager, MatrixMediaUploader uploader) {
    _mediaSender = MatrixMediaSender(_clientManager, uploader);
  }

  matrix.Client? get _client => _clientManager.client;

  // ============================================
  // 媒体消息发送（委托给 MatrixMediaSender）
  // ============================================

  /// 发送图片消息
  Future<String?> sendImageMessage(
    String roomId, {
    required Uint8List imageBytes,
    required String filename,
    String? mimeType,
    int? selfDestructAfter,
  }) => _mediaSender.sendImageMessage(
    roomId,
    imageBytes: imageBytes,
    filename: filename,
    mimeType: mimeType,
    selfDestructAfter: selfDestructAfter,
  );

  /// 发送语音消息
  Future<String?> sendVoiceMessage(
    String roomId, {
    required Uint8List audioBytes,
    required String filename,
    required int duration,
    String? mimeType,
    int? selfDestructAfter,
  }) => _mediaSender.sendVoiceMessage(
    roomId,
    audioBytes: audioBytes,
    filename: filename,
    duration: duration,
    mimeType: mimeType,
    selfDestructAfter: selfDestructAfter,
  );

  /// 发送视频消息
  Future<String?> sendVideoMessage(
    String roomId, {
    required Uint8List videoBytes,
    required String filename,
    String? mimeType,
    Uint8List? thumbnailBytes,
    int? selfDestructAfter,
  }) => _mediaSender.sendVideoMessage(
    roomId,
    videoBytes: videoBytes,
    filename: filename,
    mimeType: mimeType,
    thumbnailBytes: thumbnailBytes,
    selfDestructAfter: selfDestructAfter,
  );

  /// 发送文件消息
  Future<String?> sendFileMessage(
    String roomId, {
    Uint8List? fileBytes,
    required String filename,
    String? mimeType,
    int? selfDestructAfter,
    String? filePath,
    Stream<List<int>>? fileStream,
    int? fileSize,
  }) => _mediaSender.sendFileMessage(
    roomId,
    fileBytes: fileBytes,
    filename: filename,
    mimeType: mimeType,
    selfDestructAfter: selfDestructAfter,
    filePath: filePath,
    fileStream: fileStream,
    fileSize: fileSize,
  );

  // ============================================
  // 文本及其他消息发送
  // ============================================

  /// 发送文本消息
  ///
  /// [selfDestructAfter] 阅后即焚秒数，null 表示不自毁
  /// [mentionedUserIds] 提及的用户ID列表
  /// [mentionsRoom] 是否 @全体成员
  Future<String?> sendTextMessage(
    String roomId,
    String text, {
    int? selfDestructAfter,
    List<String>? mentionedUserIds,
    bool mentionsRoom = false,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return null;

    final content = buildTextMessageContent(
      text,
      selfDestructAfter: selfDestructAfter,
      mentionedUserIds: mentionedUserIds,
      mentionsRoom: mentionsRoom,
      currentUserId: _client?.userID,
    );

    // 如果有特殊字段，使用 sendEvent；否则使用 sendTextEvent
    if (hasExtendedTextMetadata(content)) {
      return await room.sendEvent(content);
    }

    return await room.sendTextEvent(text);
  }

  /// 发送位置消息
  ///
  /// Matrix 位置消息格式参考:
  /// https://spec.matrix.org/latest/client-server-api/#mlocation
  Future<String?> sendLocationMessage(
    String roomId, {
    required double latitude,
    required double longitude,
    String? description,
  }) async {
    debugLog('=== MatrixMessageDataSource.sendLocationMessage start ===');
    debugLog('roomId: $roomId');
    debugLog('latitude: $latitude');
    debugLog('longitude: $longitude');
    debugLog('description: $description');

    try {
      // 检查客户端
      if (_client == null) {
        debugLog('ERROR: Matrix client is null');
        throw Exception('Matrix 客户端未初始化');
      }

      // 检查登录状态
      if (!_client!.isLogged()) {
        debugLog('ERROR: Not logged in');
        throw Exception('未登录');
      }

      // 获取房间
      final room = _client!.getRoomById(roomId);
      if (room == null) {
        debugLog('ERROR: Room not found: $roomId');
        throw Exception('房间不存在: $roomId');
      }
      debugLog('Room found: ${room.getLocalizedDisplayname()}');

      // 构建 geo URI (标准格式) - 使用固定小数位避免精度问题
      final latStr = latitude.toStringAsFixed(6);
      final lonStr = longitude.toStringAsFixed(6);
      final geoUri = 'geo:$latStr,$lonStr';

      // 构建位置消息内容 (遵循 Matrix 规范)
      // 注意：不在 info 中包含浮点数，某些服务器不支持
      final content = {
        'msgtype': matrix.MessageTypes.Location,
        'body': description ?? 'Location: $latStr, $lonStr',
        'geo_uri': geoUri,
        // Matrix 规范的 m.location 扩展 (可选)
        'org.matrix.msc3488.location': {
          'uri': geoUri,
          'description': description ?? 'My location',
        },
        // 资产类型
        'org.matrix.msc3488.asset': {
          'type': 'm.self', // 表示这是用户自己的位置
        },
      };

      debugLog('Location content: $content');
      debugLog('Calling room.sendEvent...');

      final result = await room.sendEvent(content);
      debugLog('sendEvent result: $result');

      if (result == null || result.isEmpty) {
        debugLog('WARNING: sendEvent returned null or empty result');
      }

      debugLog('=== sendLocationMessage completed successfully ===');
      return result;
    } catch (e, stackTrace) {
      debugLog('=== sendLocationMessage ERROR ===');
      debugLog('Error: $e');
      debugLog('Error type: ${e.runtimeType}');
      debugLog('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 发送 GIF 消息
  ///
  /// GIF 作为图片消息发送，带有特殊标记
  Future<String?> sendGifMessage(
    String roomId, {
    required String gifUrl,
    String? previewUrl,
    int? width,
    int? height,
    String? title,
  }) async {
    debugLog('=== MatrixMessageDataSource.sendGifMessage start ===');
    debugLog('roomId: $roomId');
    debugLog('gifUrl: $gifUrl');

    try {
      if (_client == null) {
        debugLog('ERROR: Matrix client is null');
        throw Exception('Matrix 客户端未初始化');
      }

      if (!_client!.isLogged()) {
        debugLog('ERROR: Not logged in');
        throw Exception('未登录');
      }

      final room = _client!.getRoomById(roomId);
      if (room == null) {
        debugLog('ERROR: Room not found: $roomId');
        throw Exception('房间不存在: $roomId');
      }

      // 构建 GIF 消息内容
      // 使用 m.image 类型但添加 GIF 相关元数据
      final info = <String, dynamic>{'mimetype': 'image/gif'};
      if (width != null) info['w'] = width;
      if (height != null) info['h'] = height;

      final content = <String, dynamic>{
        'msgtype': matrix.MessageTypes.Image,
        'body': title ?? 'GIF',
        'url': gifUrl,
        'info': info,
        // 添加自定义字段标识 GIF 来源
        'org.n42.gif': {'source': 'giphy', 'preview_url': previewUrl},
      };

      debugLog('GIF content: $content');
      debugLog('Calling room.sendEvent...');

      final result = await room.sendEvent(content);
      debugLog('sendEvent result: $result');

      debugLog('=== sendGifMessage completed successfully ===');
      return result;
    } catch (e, stackTrace) {
      debugLog('=== sendGifMessage ERROR ===');
      debugLog('Error: $e');
      debugLog('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 发送贴纸消息
  ///
  /// 使用 Matrix m.sticker 消息类型
  Future<String?> sendStickerMessage(
    String roomId, {
    required String stickerId,
    required String packId,
    required String url,
    String? httpUrl,
    String? name,
    String? emoji,
    int? width,
    int? height,
    String? mimeType,
    int? size,
  }) async {
    debugLog('=== MatrixMessageDataSource.sendStickerMessage start ===');
    debugLog('roomId: $roomId');
    debugLog('stickerId: $stickerId');
    debugLog('packId: $packId');
    debugLog('url: $url');

    try {
      if (_client == null) {
        debugLog('ERROR: Matrix client is null');
        throw Exception('Matrix 客户端未初始化');
      }

      if (!_client!.isLogged()) {
        debugLog('ERROR: Not logged in');
        throw Exception('未登录');
      }

      final room = _client!.getRoomById(roomId);
      if (room == null) {
        debugLog('ERROR: Room not found: $roomId');
        throw Exception('房间不存在: $roomId');
      }

      // 如果是 emoji 贴纸，发送为文本消息
      if (url.startsWith('emoji:')) {
        final emojiChar = url.substring(6);
        debugLog('Sending emoji sticker as text: $emojiChar');
        return await room.sendTextEvent(emojiChar);
      }

      // 构建贴纸消息内容 (使用 m.sticker 事件类型)
      final info = <String, dynamic>{'mimetype': mimeType ?? 'image/png'};
      if (width != null) info['w'] = width;
      if (height != null) info['h'] = height;
      if (size != null) info['size'] = size;

      final content = <String, dynamic>{
        'body': name ?? emoji ?? 'sticker',
        'url': url,
        'info': info,
        // 添加自定义字段标识贴纸来源
        'org.n42.sticker': {
          'pack_id': packId,
          'sticker_id': stickerId,
          'emoji': emoji,
        },
      };

      debugLog('Sticker content: $content');
      debugLog('Calling room.sendEvent with type m.sticker...');

      final result = await room.sendEvent(
        content,
        type: matrix.EventTypes.Sticker,
      );
      debugLog('sendEvent result: $result');

      debugLog('=== sendStickerMessage completed successfully ===');
      return result;
    } catch (e, stackTrace) {
      debugLog('=== sendStickerMessage ERROR ===');
      debugLog('Error: $e');
      debugLog('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 发送自定义消息
  Future<String> sendCustomMessage({
    required String roomId,
    required String msgType,
    required Map<String, dynamic> content,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) {
      throw Exception('房间不存在');
    }

    final eventId = await room.sendEvent(content);
    return eventId ?? '';
  }

  /// 发送自定义房间事件（不展示在消息列表中）
  Future<String> sendRoomEvent({
    required String roomId,
    required String type,
    required Map<String, dynamic> content,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) {
      throw Exception('房间不存在');
    }

    final eventId = await room.sendEvent(content, type: type);
    return eventId ?? '';
  }

  /// 重发消息
  Future<bool> resendMessage(String roomId, String eventId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return false;

    final event = await room.getEventById(eventId);
    if (event == null) return false;

    // 获取原始内容并重新发送
    try {
      await room.sendEvent(event.content);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 发送系统通知/拍一拍消息
  Future<MessageEntity?> sendNoticeMessage({
    required String roomId,
    required String notice,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) {
      debugLog('MatrixMessageDataSource: Room not found: $roomId');
      return null;
    }

    try {
      // 发送 m.notice 类型的消息（系统通知）
      final eventId = await room.sendEvent({
        'msgtype': 'm.notice',
        'body': notice,
        'format': 'org.matrix.custom.html',
        'formatted_body': '<em>$notice</em>',
      });

      debugLog('MatrixMessageDataSource: Notice sent with eventId: $eventId');

      // 返回临时消息实体
      return MessageEntity(
        id: eventId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: roomId,
        senderId: _client?.userID ?? '',
        senderName: _client?.userID?.localpart ?? '',
        senderAvatarUrl: null,
        content: notice,
        type: MessageType.notice,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to send notice: $e');
      rethrow;
    }
  }

  /// 发送联系人名片消息
  Future<String?> sendContactCard(
    String roomId, {
    required String userId,
    required String displayName,
    String? avatarUrl,
    String? matrixId,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return null;

    try {
      final eventId = await room.sendEvent({
        'msgtype': 'n42.contact_card',
        'body': '[Contact Card] $displayName',
        'user_id': userId,
        'display_name': displayName,
        'avatar_url': ?avatarUrl,
        'matrix_id': ?matrixId,
      });
      return eventId;
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to send contact card: $e');
      return null;
    }
  }
}
