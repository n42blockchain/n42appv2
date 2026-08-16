import 'package:matrix/matrix.dart' as matrix;

import '../../../../core/utils/matrix_utils.dart';
import '../../../../domain/entities/message_entity.dart';
import 'matrix_metadata_extractor.dart';
import '../../../../core/utils/debug_log.dart';

/// 解析后的消息内容
class ParsedContent {
  final String content;
  final String? replyToContent;
  final String? replyToSender;

  ParsedContent({
    required this.content,
    this.replyToContent,
    this.replyToSender,
  });
}

/// 线程信息
class ThreadInfo {
  final String? threadRootId;
  final int? replyCount;
  final String? latestReply;
  final String? latestReplySender;
  final DateTime? latestReplyTimestamp;
  final int? unreadCount;

  ThreadInfo({
    this.threadRootId,
    this.replyCount,
    this.latestReply,
    this.latestReplySender,
    this.latestReplyTimestamp,
    this.unreadCount,
  });
}

/// Matrix 事件到消息实体的映射器
///
/// 负责将 Matrix SDK 的 Event 对象转换为应用层的 MessageEntity
class MatrixEventMapper {
  final matrix.Client? Function() _clientGetter;
  late final MatrixMetadataExtractor _metadataExtractor;

  static final _replyUserRegExp = RegExp(r'> \*? ?<(@[^>]+)>(.*)');

  MatrixEventMapper(this._clientGetter) {
    _metadataExtractor = MatrixMetadataExtractor(
      _clientGetter,
      convertMxcToHttp,
    );
  }

  matrix.Client? get _client => _clientGetter();

  /// 将Matrix事件转换为消息实体
  MessageEntity mapEventToMessage(matrix.Event event, matrix.Room room) {
    final sender = room.unsafeGetUserFromMemoryOrFallback(event.senderId);
    final resolvedDisplay = _resolveDisplayText(event);
    final replyTargetId = event.inReplyToEventId(includingFallback: false);
    final messageType = mapMessageType(event);

    // 解析消息内容，处理回复格式
    final parsedContent = _parseMessageContent(
      event,
      room,
      fallbackBody: resolvedDisplay.body,
    );

    // 转换头像 mxc:// URL 为 HTTP URL（使用手动构建方式）
    final avatarHttpUrl = buildHttpUrl(
      sender.avatarUrl?.toString(),
      width: 80,
      height: 80,
      method: 'crop',
    );

    // 解析阅后即焚字段
    final selfDestructData =
        event.content['n42.self_destruct'] as Map<String, dynamic>?;
    final selfDestructAfter = selfDestructData?['after'] as int?;

    // 解析 m.mentions 字段
    final mentionsData = event.content['m.mentions'] as Map<String, dynamic>?;
    final mentionsRoom = mentionsData?['room'] as bool? ?? false;
    final mentionedUserIds =
        (mentionsData?['user_ids'] as List<dynamic>?)
            ?.cast<String>()
            .toList() ??
        <String>[];

    // 解析线程信息 (MSC3440)
    final threadInfo = extractThreadInfo(event);

    // 检测 Bot 消息：n42.bot 标记 或 msgtype 为 m.notice
    final isBotMessage =
        event.content['n42.bot'] == true ||
        event.messageType == matrix.MessageTypes.Notice;

    // 对 n42.contact_card 消息，从 event.content 提取完整名片信息构建多行格式 body
    // 使得 message_item.dart 中 _parseContactCard 可以正确解析 userId/displayName/avatarUrl
    String messageContent = messageType == MessageType.encrypted
        ? ''
        : parsedContent.content;
    if (event.content['msgtype'] == 'n42.contact_card') {
      final contactUserId = event.content['user_id'] as String? ?? '';
      final contactDisplayName = event.content['display_name'] as String? ?? '';
      final contactAvatarUrl = event.content['avatar_url'] as String? ?? '';
      final buffer = StringBuffer('[Contact Card]\n');
      buffer.writeln('Name:$contactDisplayName');
      buffer.writeln('ID:$contactUserId');
      if (contactAvatarUrl.isNotEmpty) {
        buffer.writeln('Avatar:$contactAvatarUrl');
      }
      messageContent = buffer.toString().trimRight();
    }

    if (event.content['msgtype'] == 'n42.transfer' ||
        event.content['msgtype'] == 'n42.payment_request') {
      final memo = event.content['memo'] as String?;
      if (memo?.isNotEmpty == true) {
        messageContent = memo!;
      }
    }

    return MessageEntity(
      id: event.eventId,
      roomId: room.id,
      senderId: event.senderId,
      senderName: sender.calcDisplayname(),
      senderAvatarUrl: avatarHttpUrl,
      content: messageContent,
      formattedContent: resolvedDisplay.formattedBody,
      type: messageType,
      timestamp: event.originServerTs,
      status: mapMessageStatus(event),
      isFromMe: event.senderId == _client?.userID,
      replyToId: replyTargetId,
      replyToContent: parsedContent.replyToContent,
      replyToSender: parsedContent.replyToSender,
      isEdited: _checkIsEdited(event),
      editedAt: _getEditedAt(event),
      reactions: _extractReactions(event),
      metadata: extractMetadataWithHttpUrl(event),
      mentionedUserIds: mentionedUserIds,
      mentionsRoom: mentionsRoom,
      selfDestructAfter: selfDestructAfter,
      threadRootId: threadInfo.threadRootId,
      threadReplyCount: threadInfo.replyCount,
      threadLatestReply: threadInfo.latestReply,
      threadLatestReplySender: threadInfo.latestReplySender,
      threadLatestReplyTimestamp: threadInfo.latestReplyTimestamp,
      isBotMessage: isBotMessage,
      threadUnreadCount: threadInfo.unreadCount,
    );
  }

  /// 解析消息内容，处理回复格式
  /// Matrix 回复格式: "> <@user:server> 原消息内容\n\n实际回复内容"
  ParsedContent _parseMessageContent(
    matrix.Event event,
    matrix.Room room, {
    required String fallbackBody,
  }) {
    String body = fallbackBody;
    String? replyToContent;
    String? replyToSender;
    final replyTargetId = event.inReplyToEventId(includingFallback: false);
    final sourceBody = event.body;

    // 检查是否是回复消息（有 m.relates_to 或以 > 开头）
    if (replyTargetId != null || sourceBody.startsWith('> ')) {
      // 尝试从 body 解析回复格式
      final lines = sourceBody.split('\n');
      final List<String> quotedLines = [];
      int contentStartIndex = 0;

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.startsWith('> ')) {
          quotedLines.add(line);
          contentStartIndex = i + 1;
        } else if (line.isEmpty && quotedLines.isNotEmpty) {
          // 空行分隔引用和实际内容
          contentStartIndex = i + 1;
          break;
        } else if (quotedLines.isNotEmpty) {
          // 遇到非引用行，停止
          break;
        }
      }

      // 如果找到了引用内容
      if (quotedLines.isNotEmpty) {
        // 解析引用的发送者和内容
        final firstQuoteLine = quotedLines.first;
        // 格式: "> <@user:server> 内容" 或 "> * <@user:server> 内容"
        final userMatch = _replyUserRegExp.firstMatch(firstQuoteLine);
        if (userMatch != null) {
          final userId = userMatch.group(1);
          replyToContent = userMatch.group(2)?.trim();

          // 如果有多行引用，合并
          if (quotedLines.length > 1) {
            final restQuotes = quotedLines
                .skip(1)
                .map((l) => l.replaceFirst('> ', ''))
                .join('\n');
            replyToContent = '${replyToContent ?? ''}\n$restQuotes'.trim();
          }

          // 获取发送者名称
          if (userId != null) {
            try {
              final replyUser = room.unsafeGetUserFromMemoryOrFallback(userId);
              replyToSender = replyUser.calcDisplayname();
            } catch (e) {
              // 如果获取用户失败，使用 userId 的用户名部分
              replyToSender = userId.split(':').first.replaceFirst('@', '');
              debugLog('Error: $e');
            }
          }
        }

        // 提取实际回复内容
        if (fallbackBody.startsWith('> ') && contentStartIndex < lines.length) {
          body = lines.sublist(contentStartIndex).join('\n').trim();
        }
      }
    }

    return ParsedContent(
      content: body,
      replyToContent: replyToContent,
      replyToSender: replyToSender,
    );
  }

  _ResolvedDisplayText _resolveDisplayText(matrix.Event event) {
    final replace = _extractLatestEditReplacement(event);
    if (replace == null) {
      return _ResolvedDisplayText(
        body: event.body,
        formattedBody: event.formattedText.isNotEmpty
            ? event.formattedText
            : null,
      );
    }

    final replacementContent = replace['content'] as Map<String, dynamic>?;
    final newContent =
        replacementContent?['m.new_content'] as Map<String, dynamic>? ??
        replacementContent;

    final body = newContent?['body'] as String?;
    final formattedBody = newContent?['formatted_body'] as String?;

    return _ResolvedDisplayText(
      body: body?.isNotEmpty == true ? body! : event.body,
      formattedBody: formattedBody?.isNotEmpty == true
          ? formattedBody
          : (event.formattedText.isNotEmpty ? event.formattedText : null),
    );
  }

  Map<String, dynamic>? _extractLatestEditReplacement(matrix.Event event) {
    final unsigned = event.unsigned;
    if (unsigned == null) {
      return null;
    }

    final relations = unsigned['m.relations'] as Map<String, dynamic>?;
    if (relations == null) {
      return null;
    }

    final replace = relations['m.replace'] as Map<String, dynamic>?;
    if (replace == null) {
      return null;
    }

    final replacementContent = replace['content'] as Map<String, dynamic>?;
    if (replacementContent == null) {
      return null;
    }

    return replace;
  }

  /// 映射消息类型
  MessageType mapMessageType(matrix.Event event) {
    // 首先检查消息是否被撤回
    if (event.redactedBecause != null) {
      return MessageType.redacted;
    }

    // 检查是否是投票消息
    if (event.type == 'org.matrix.msc3381.poll.start') {
      return MessageType.poll;
    }

    // 贴纸事件（m.sticker 是独立 event type，无 msgtype）
    if (event.type == matrix.EventTypes.Sticker) {
      return MessageType.sticker;
    }

    // 检查是否是通话结束事件
    if (event.type == 'm.call.hangup') {
      final callType = event.content['call_type'] as String?;
      final callId = event.content['call_id'] as String?;
      debugLog(
        '_mapMessageType: m.call.hangup - callId=$callId, call_type=$callType',
      );
      return callType == 'video'
          ? MessageType.videoCall
          : MessageType.voiceCall;
    }

    // 获取消息类型
    final msgType = event.messageType;

    // 检查是否是通话记录消息
    if (msgType == 'n42.call.record') {
      final callType = event.content['call_type'] as String?;
      debugLog('_mapMessageType: n42.call.record - call_type=$callType');
      return callType == 'video'
          ? MessageType.videoCall
          : MessageType.voiceCall;
    }

    // 处理加密消息
    if (event.type == matrix.EventTypes.Encrypted) {
      // The SDK exposes the decryption exception through body/plaintextBody.
      // It is not user-authored text and must never be rendered as a normal
      // outgoing bubble (which previously made this error appear green).
      if (event.messageType == matrix.MessageTypes.BadEncrypted) {
        return MessageType.encrypted;
      }

      final contentMsgType = event.content['msgtype'] as String?;
      final body = event.body;
      final plaintextBody = event.plaintextBody;
      debugLog(
        '_mapMessageType: Encrypted event - msgType=$msgType, contentMsgType=$contentMsgType, body=$body, plaintextBody=$plaintextBody',
      );

      String? effectiveMsgType;
      if (msgType.isNotEmpty && msgType != 'm.bad.encrypted') {
        effectiveMsgType = msgType;
      } else if (contentMsgType != null && contentMsgType.isNotEmpty) {
        effectiveMsgType = contentMsgType;
      }

      debugLog('_mapMessageType: effectiveMsgType=$effectiveMsgType');

      if (effectiveMsgType == matrix.MessageTypes.Audio) {
        return MessageType.audio;
      } else if (effectiveMsgType == matrix.MessageTypes.Video) {
        return MessageType.video;
      } else if (effectiveMsgType == matrix.MessageTypes.Image) {
        return MessageType.image;
      } else if (effectiveMsgType == matrix.MessageTypes.File) {
        return MessageType.file;
      } else if (effectiveMsgType == matrix.MessageTypes.Text) {
        return MessageType.text;
      } else if (effectiveMsgType == matrix.MessageTypes.Location) {
        return MessageType.location;
      } else if (effectiveMsgType == matrix.MessageTypes.Notice) {
        return MessageType.notice;
      }

      if ((body.isNotEmpty && body != 'Encrypted event') ||
          (plaintextBody.isNotEmpty && plaintextBody != body)) {
        debugLog(
          '_mapMessageType: Encrypted message with valid body, treating as text',
        );
        return MessageType.text;
      }

      debugLog('_mapMessageType: Encrypted message not decrypted');
      return MessageType.encrypted;
    }

    debugLog(
      '_mapMessageType: msgType=$msgType, eventType=${event.type}, senderId=${event.senderId}',
    );
    if (event.content['url'] != null) {
      debugLog(
        '_mapMessageType: has url=${event.content['url']}, info=${event.content['info']}',
      );
    }

    switch (msgType) {
      case matrix.MessageTypes.Text:
        return MessageType.text;
      case matrix.MessageTypes.Image:
        return MessageType.image;
      case matrix.MessageTypes.Video:
        return MessageType.video;
      case matrix.MessageTypes.Audio:
        return MessageType.audio;
      case matrix.MessageTypes.File:
        return _detectFileType(event);
      case matrix.MessageTypes.Location:
        return MessageType.location;
      case matrix.MessageTypes.Notice:
        return MessageType.notice;
      case matrix.MessageTypes.Emote:
        return MessageType.text;
      default:
        // 自定义 msgtype 直接查表，避免 5 次串行字符串 ==。
        final custom = _customMsgTypes[msgType];
        if (custom != null) return custom;
        return _detectMediaTypeFromContent(event) ?? MessageType.text;
    }
  }

  static const Map<String, MessageType> _customMsgTypes = {
    'n42.red_packet': MessageType.redPacket,
    'n42.transfer': MessageType.transfer,
    'n42.payment_request': MessageType.paymentRequest,
    'n42.music': MessageType.music,
    'n42.contact_card': MessageType.contactCard,
    'n42.code_block': MessageType.codeBlock,
    'n42.tip': MessageType.tip,
    'n42.event': MessageType.event,
  };

  /// 检测文件类型（用于 m.file 消息，可能是 bridge 发送的图片/视频/音频）
  MessageType _detectFileType(matrix.Event event) {
    final info = event.content['info'] as Map<String, dynamic>?;
    final mimeType = info?['mimetype'] as String? ?? '';
    final filename = (event.content['filename'] as String?) ?? event.body;

    debugLog('_detectFileType: mimeType=$mimeType, filename=$filename');

    if (mimeType.startsWith('image/')) return MessageType.image;
    if (mimeType.startsWith('video/')) return MessageType.video;
    if (mimeType.startsWith('audio/')) return MessageType.audio;

    final lowerFilename = filename.toLowerCase();
    if (lowerFilename.endsWith('.jpg') ||
        lowerFilename.endsWith('.jpeg') ||
        lowerFilename.endsWith('.png') ||
        lowerFilename.endsWith('.gif') ||
        lowerFilename.endsWith('.webp') ||
        lowerFilename.endsWith('.bmp')) {
      return MessageType.image;
    }
    if (lowerFilename.endsWith('.mp4') ||
        lowerFilename.endsWith('.mov') ||
        lowerFilename.endsWith('.avi') ||
        lowerFilename.endsWith('.webm')) {
      return MessageType.video;
    }
    if (lowerFilename.endsWith('.mp3') ||
        lowerFilename.endsWith('.m4a') ||
        lowerFilename.endsWith('.ogg') ||
        lowerFilename.endsWith('.wav')) {
      return MessageType.audio;
    }

    return MessageType.file;
  }

  /// 从消息内容中检测媒体类型（处理 bridge 发送的特殊格式）
  MessageType? _detectMediaTypeFromContent(matrix.Event event) {
    final url = event.content['url'] as String?;
    if (url == null || url.isEmpty) return null;

    final info = event.content['info'] as Map<String, dynamic>?;
    final mimeType = info?['mimetype'] as String? ?? '';

    debugLog('_detectMediaTypeFromContent: url=$url, mimeType=$mimeType');

    if (mimeType.startsWith('image/')) {
      debugLog('_detectMediaTypeFromContent: detected as image');
      return MessageType.image;
    }
    if (mimeType.startsWith('video/')) {
      debugLog('_detectMediaTypeFromContent: detected as video');
      return MessageType.video;
    }
    if (mimeType.startsWith('audio/')) {
      debugLog('_detectMediaTypeFromContent: detected as audio');
      return MessageType.audio;
    }

    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('image') ||
        lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.gif')) {
      debugLog('_detectMediaTypeFromContent: detected as image from URL');
      return MessageType.image;
    }

    debugLog(
      '_detectMediaTypeFromContent: has url but unknown type, treating as file',
    );
    return MessageType.file;
  }

  /// 映射消息状态
  MessageStatus mapMessageStatus(matrix.Event event) {
    if (event.status == matrix.EventStatus.error) {
      return MessageStatus.failed;
    }
    if (event.status == matrix.EventStatus.sending) {
      return MessageStatus.sending;
    }
    if (event.status == matrix.EventStatus.sent) {
      return MessageStatus.sent;
    }
    return MessageStatus.sent;
  }

  /// 检查消息是否被编辑过
  bool _checkIsEdited(matrix.Event event) {
    try {
      final unsigned = event.unsigned;
      if (unsigned == null) return false;

      final relations = unsigned['m.relations'] as Map<String, dynamic>?;
      if (relations == null) return false;

      return relations.containsKey('m.replace');
    } catch (e) {
      debugLog('Error: $e');
      return false;
    }
  }

  /// 获取消息的最后编辑时间
  DateTime? _getEditedAt(matrix.Event event) {
    try {
      final unsigned = event.unsigned;
      if (unsigned == null) return null;

      final relations = unsigned['m.relations'] as Map<String, dynamic>?;
      if (relations == null) return null;

      final replace = relations['m.replace'] as Map<String, dynamic>?;
      if (replace == null) return null;

      final ts = replace['origin_server_ts'] as int?;
      if (ts != null) {
        return DateTime.fromMillisecondsSinceEpoch(ts);
      }
      return null;
    } catch (e) {
      debugLog('Error: $e');
      return null;
    }
  }

  /// 提取表情回应
  List<MessageReaction> _extractReactions(matrix.Event event) {
    final reactions = <MessageReaction>[];

    try {
      final unsigned = event.unsigned;
      if (unsigned == null) return reactions;

      final relations = unsigned['m.relations'] as Map<String, dynamic>?;
      if (relations == null) return reactions;

      final annotations = relations['m.annotation'] as Map<String, dynamic>?;
      if (annotations == null) return reactions;

      final chunk = annotations['chunk'] as List<dynamic>?;
      if (chunk == null || chunk.isEmpty) return reactions;

      for (final item in chunk) {
        if (item is Map<String, dynamic>) {
          final emoji = item['key'] as String?;
          final count = item['count'] as int? ?? 0;

          if (emoji != null && emoji.isNotEmpty && count > 0) {
            // Matrix 聚合事件只给 count，不给具体 userIds——以前用
            // List.generate(count, (i) => 'user_$i') 合成假 ID 仅为了 .length 正确，
            // 一个 1000 reaction 的房间会浪费上千次字符串 alloc。
            reactions.add(
              MessageReaction(
                key: emoji,
                userIds: const [],
                aggregateCount: count,
                isMe: false,
              ),
            );
          }
        }
      }

      if (reactions.isNotEmpty) {
        debugLog(
          'Extracted ${reactions.length} reactions for event ${event.eventId}',
        );
      }
    } catch (e) {
      debugLog('Error extracting reactions: $e');
    }

    return reactions;
  }

  /// 构建认证媒体 HTTP URL
  String? buildHttpUrl(
    String? mxcUrl, {
    int? width,
    int? height,
    String method = 'scale',
  }) {
    final thumbnailMethod = method == 'crop'
        ? matrix.ThumbnailMethod.crop
        : matrix.ThumbnailMethod.scale;
    final url = MatrixUtils.mxcToHttp(
      mxcUrl,
      client: _client,
      width: width,
      height: height,
      method: thumbnailMethod,
    );
    if (url != null) {
      debugLog('Built media URL: $url (mxcUrl: $mxcUrl)');
    }
    return url;
  }

  /// 转换 mxc:// URL 为 HTTP URL（兼容旧接口）
  String? convertMxcToHttp(String? mxcUrl, {int? width, int? height}) {
    return buildHttpUrl(mxcUrl, width: width, height: height, method: 'scale');
  }

  /// 提取消息元数据（委托给 MetadataExtractor）
  MessageMetadata? extractMetadataWithHttpUrl(matrix.Event event) =>
      _metadataExtractor.extractMetadataWithHttpUrl(event);

  /// 提取投票消息元数据（委托给 MetadataExtractor）
  MessageMetadata? extractPollMetadata(matrix.Event event) =>
      _metadataExtractor.extractPollMetadata(event);

  /// 判断是否是消息事件
  bool isMessageEvent(dynamic event) {
    if (event is matrix.Event) {
      return event.type == matrix.EventTypes.Message ||
          event.type == matrix.EventTypes.Encrypted ||
          event.type == matrix.EventTypes.Sticker ||
          event.type == 'org.matrix.msc3381.poll.start';
    }
    if (event is Map<String, dynamic>) {
      final type = event['type'] as String?;
      return type == matrix.EventTypes.Message ||
          type == matrix.EventTypes.Encrypted ||
          type == matrix.EventTypes.Sticker ||
          type == 'org.matrix.msc3381.poll.start';
    }
    return false;
  }

  /// 获取媒体下载URL
  Uri? getMediaUrl(String? mxcUrl, {int? width, int? height}) {
    try {
      final url = buildHttpUrl(
        mxcUrl,
        width: width,
        height: height,
        method: 'scale',
      );
      return url == null ? null : Uri.parse(url);
    } catch (e) {
      return null;
    }
  }

  /// 从事件中提取线程信息
  ThreadInfo extractThreadInfo(matrix.Event event) {
    String? threadRootId;
    int? replyCount;
    String? latestReply;
    String? latestReplySender;
    DateTime? latestReplyTimestamp;
    int? unreadCount;

    final relatesTo = event.content['m.relates_to'] as Map<String, dynamic>?;
    if (relatesTo != null) {
      final relType = relatesTo['rel_type'] as String?;
      if (relType == 'm.thread') {
        threadRootId = relatesTo['event_id'] as String?;
      }
    }

    final unsigned = event.unsigned;
    if (unsigned != null) {
      final relations = unsigned['m.relations'] as Map<String, dynamic>?;
      if (relations != null) {
        final threadSummary = relations['m.thread'] as Map<String, dynamic>?;
        if (threadSummary != null) {
          replyCount = threadSummary['count'] as int?;

          // 提取线程未读数（MSC3440 扩展）
          final unreadNotifications =
              threadSummary['unread_notifications'] as Map<String, dynamic>?;
          if (unreadNotifications != null) {
            unreadCount = unreadNotifications['notification_count'] as int?;
          }

          final latestEvent =
              threadSummary['latest_event'] as Map<String, dynamic>?;
          if (latestEvent != null) {
            latestReplySender = latestEvent['sender'] as String?;
            final content = latestEvent['content'] as Map<String, dynamic>?;
            latestReply = content?['body'] as String?;
            final originServerTs = latestEvent['origin_server_ts'] as int?;
            if (originServerTs != null) {
              latestReplyTimestamp = DateTime.fromMillisecondsSinceEpoch(
                originServerTs,
              );
            }
          }
        }
      }
    }

    return ThreadInfo(
      threadRootId: threadRootId,
      replyCount: replyCount,
      latestReply: latestReply,
      latestReplySender: latestReplySender,
      latestReplyTimestamp: latestReplyTimestamp,
      unreadCount: unreadCount,
    );
  }
}

class _ResolvedDisplayText {
  final String body;
  final String? formattedBody;

  const _ResolvedDisplayText({required this.body, this.formattedBody});
}
