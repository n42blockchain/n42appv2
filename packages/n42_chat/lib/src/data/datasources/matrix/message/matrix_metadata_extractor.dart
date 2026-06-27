import 'package:matrix/matrix.dart' as matrix;

import '../../../../domain/entities/message_entity.dart';
import '../../../../core/utils/debug_log.dart';

/// Matrix 消息元数据提取器
///
/// 负责从 Matrix Event 中提取各类消息的元数据：
/// 图片/视频/音频/文件/位置/投票/红包/转账/通话等
class MatrixMetadataExtractor {
  final matrix.Client? Function() _clientGetter;
  final String? Function(String?, {int? width, int? height}) _convertMxcToHttp;

  MatrixMetadataExtractor(this._clientGetter, this._convertMxcToHttp);

  matrix.Client? get _client => _clientGetter();

  /// 提取消息元数据（带 HTTP URL 转换）
  MessageMetadata? extractMetadataWithHttpUrl(matrix.Event event) {
    final info = event.content['info'] as Map<String, dynamic>?;
    // 加密房间中媒体 URL 存在 file.url 而非顶层 url 字段
    final fileContent = event.content['file'] as Map<String, dynamic>?;
    final mxcUrl = event.content['url'] as String? ?? fileContent?['url'] as String?;
    final thumbnailMxc = info?['thumbnail_url'] as String?;

    // 贴纸信息（m.sticker 是独立 event type，无 msgtype；字段结构同图片）
    if (event.type == matrix.EventTypes.Sticker) {
      return MessageMetadata(
        mediaUrl: mxcUrl,
        httpUrl: _convertMxcToHttp(mxcUrl),
        width: info?['w'] as int?,
        height: info?['h'] as int?,
        size: info?['size'] as int?,
        mimeType: info?['mimetype'] as String?,
      );
    }

    // 图片信息
    if (event.messageType == matrix.MessageTypes.Image) {
      return MessageMetadata(
        mediaUrl: mxcUrl,
        httpUrl: _convertMxcToHttp(mxcUrl),
        width: info?['w'] as int?,
        height: info?['h'] as int?,
        size: info?['size'] as int?,
        mimeType: info?['mimetype'] as String?,
        thumbnailUrl: _convertMxcToHttp(thumbnailMxc, width: 400, height: 400),
      );
    }

    // 音频信息
    if (event.messageType == matrix.MessageTypes.Audio) {
      final httpUrl = _convertMxcToHttp(mxcUrl);
      // 提取 E2EE key 材料（加密房间中媒体存于 file 字段）
      final keyMap = (fileContent?['key'] as Map<String, dynamic>?);
      final hashMap = (fileContent?['hashes'] as Map<String, dynamic>?);
      final encryptKey = keyMap?['k'] as String?;
      final encryptIv = fileContent?['iv'] as String?;
      final encryptSha256 = hashMap?['sha256'] as String?;
      debugLog(
        'Audio message metadata: mxcUrl=$mxcUrl, httpUrl=$httpUrl, encrypted=${encryptKey != null}, senderId=${event.senderId}, status=${event.status}',
      );
      return MessageMetadata(
        mediaUrl: mxcUrl,
        httpUrl: httpUrl,
        duration: info?['duration'] as int?,
        size: info?['size'] as int?,
        mimeType: info?['mimetype'] as String?,
        encryptKey: encryptKey,
        encryptIv: encryptIv,
        encryptSha256: encryptSha256,
      );
    }

    // 视频信息
    if (event.messageType == matrix.MessageTypes.Video) {
      final httpUrl = _convertMxcToHttp(mxcUrl);
      final thumbnailHttpUrl = _convertMxcToHttp(
        thumbnailMxc,
        width: 400,
        height: 400,
      );
      debugLog(
        'Video metadata: mxcUrl=$mxcUrl, httpUrl=$httpUrl, thumbnailMxc=$thumbnailMxc, thumbnailHttpUrl=$thumbnailHttpUrl',
      );
      return MessageMetadata(
        mediaUrl: mxcUrl,
        httpUrl: httpUrl,
        width: info?['w'] as int?,
        height: info?['h'] as int?,
        duration: info?['duration'] as int?,
        size: info?['size'] as int?,
        mimeType: info?['mimetype'] as String?,
        thumbnailUrl: thumbnailHttpUrl,
      );
    }

    // 文件信息
    if (event.messageType == matrix.MessageTypes.File) {
      return MessageMetadata(
        mediaUrl: mxcUrl,
        httpUrl: _convertMxcToHttp(mxcUrl),
        fileName: (event.content['filename'] as String?) ?? event.body,
        size: info?['size'] as int?,
        mimeType: info?['mimetype'] as String?,
      );
    }

    // 位置信息
    if (event.messageType == matrix.MessageTypes.Location) {
      // 解析 geo URI
      final geoUri = event.content['geo_uri'] as String?;
      double? latitude;
      double? longitude;

      if (geoUri != null && geoUri.startsWith('geo:')) {
        final coords = geoUri.replaceFirst('geo:', '').split(',');
        if (coords.length >= 2) {
          latitude = double.tryParse(coords[0]);
          longitude = double.tryParse(coords[1].split(';').first);
        }
      }

      // 如果 geo URI 没有坐标，尝试从 info 获取
      latitude ??= info?['latitude'] as double?;
      longitude ??= info?['longitude'] as double?;

      return MessageMetadata(
        latitude: latitude,
        longitude: longitude,
        locationName: event.body,
      );
    }

    // 投票信息 (MSC3381)
    if (event.type == 'org.matrix.msc3381.poll.start') {
      return extractPollMetadata(event);
    }

    // 红包信息
    if (event.content['msgtype'] == 'n42.red_packet') {
      return MessageMetadata(
        amount: event.content['amount'] as String?,
        token: event.content['token'] as String?,
        transferStatus: event.content['status'] as String?,
        redPacketId: event.content['red_packet_id'] as String?,
      );
    }

    // 转账信息
    if (event.content['msgtype'] == 'n42.transfer') {
      return MessageMetadata(
        amount: event.content['amount'] as String?,
        token: event.content['token'] as String?,
        transferStatus: event.content['status'] as String?,
        txHash: event.content['tx_hash'] as String?,
      );
    }

    // 打赏信息
    if (event.content['msgtype'] == 'n42.tip') {
      return MessageMetadata(
        amount: event.content['amount'] as String?,
        token: event.content['token'] as String?,
        txHash: event.content['tx_hash'] as String?,
      );
    }

    // 收款请求信息
    if (event.content['msgtype'] == 'n42.payment_request') {
      final expiresAtMillis = event.content['expires_at'] as num?;
      return MessageMetadata(
        amount: event.content['amount'] as String?,
        token: event.content['token'] as String?,
        paymentRequestId: event.content['request_id'] as String?,
        paymentReceiverAddress: event.content['receiver_address'] as String?,
        paymentRequestExpiresAt: expiresAtMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(expiresAtMillis.toInt())
            : null,
      );
    }

    // 音乐分享信息
    if (event.content['msgtype'] == 'n42.music') {
      return MessageMetadata(
        musicTitle: event.content['title'] as String?,
        musicArtist: event.content['artist'] as String?,
        musicUrl: event.content['url'] as String?,
        musicCover: event.content['cover'] as String?,
      );
    }

    // 通话记录消息
    if (event.content['msgtype'] == 'n42.call.record') {
      final duration = event.content['duration'] as int? ?? 0;
      final isMissed = event.content['missed'] as bool? ?? false;

      debugLog(
        '_extractMetadataWithHttpUrl: n42.call.record - duration=$duration, missed=$isMissed',
      );

      return MessageMetadata(
        callDuration: duration,
        callEnded: true,
        isMissedCall: isMissed,
        callRoomId: event.room.id,
        callPeerId: event.senderId != _client?.userID ? event.senderId : null,
      );
    }

    // 通话结束事件
    if (event.type == 'm.call.hangup') {
      final reason = event.content['reason'] as String?;
      final duration = event.content['duration'] as int? ?? 0;

      // 判断是否是未接来电
      // 常见的未接来电原因：invite_timeout, user_busy, no_answer
      // 如果有通话时长，则不是未接来电
      final isMissed =
          duration == 0 &&
          (reason == 'invite_timeout' ||
              reason == 'no_answer' ||
              reason == 'user_hangup' && event.senderId != _client?.userID);

      debugLog(
        '_extractMetadataWithHttpUrl: m.call.hangup - reason=$reason, duration=$duration, isMissed=$isMissed',
      );

      return MessageMetadata(
        callDuration: duration,
        callEnded: true,
        isMissedCall: isMissed,
        callEndReason: reason,
        callRoomId: event.room.id,
        callPeerId: event.senderId != _client?.userID ? event.senderId : null,
      );
    }

    // Fallback: 根据 MIME 类型检测媒体类型（处理 bridge 发送的特殊格式）
    // 这对于 mautrix-wechat 等 bridge 发送的消息很重要
    if (mxcUrl != null && mxcUrl.isNotEmpty) {
      final mimeType = info?['mimetype'] as String? ?? '';
      debugLog(
        '_extractMetadataWithHttpUrl fallback: mxcUrl=$mxcUrl, mimeType=$mimeType',
      );

      // 根据 MIME 类型返回适当的元数据
      if (mimeType.startsWith('image/')) {
        debugLog('_extractMetadataWithHttpUrl: detected image from MIME type');
        return MessageMetadata(
          mediaUrl: mxcUrl,
          httpUrl: _convertMxcToHttp(mxcUrl),
          width: info?['w'] as int?,
          height: info?['h'] as int?,
          size: info?['size'] as int?,
          mimeType: mimeType,
          thumbnailUrl: _convertMxcToHttp(
            thumbnailMxc,
            width: 400,
            height: 400,
          ),
        );
      }

      if (mimeType.startsWith('video/')) {
        debugLog('_extractMetadataWithHttpUrl: detected video from MIME type');
        return MessageMetadata(
          mediaUrl: mxcUrl,
          httpUrl: _convertMxcToHttp(mxcUrl),
          width: info?['w'] as int?,
          height: info?['h'] as int?,
          duration: info?['duration'] as int?,
          size: info?['size'] as int?,
          mimeType: mimeType,
          thumbnailUrl: _convertMxcToHttp(
            thumbnailMxc,
            width: 400,
            height: 400,
          ),
        );
      }

      if (mimeType.startsWith('audio/')) {
        debugLog('_extractMetadataWithHttpUrl: detected audio from MIME type');
        return MessageMetadata(
          mediaUrl: mxcUrl,
          httpUrl: _convertMxcToHttp(mxcUrl),
          duration: info?['duration'] as int?,
          size: info?['size'] as int?,
          mimeType: mimeType,
        );
      }

      // 如果有 URL 但无法确定类型，作为文件处理
      debugLog(
        '_extractMetadataWithHttpUrl: has url but unknown type, treating as file',
      );
      return MessageMetadata(
        mediaUrl: mxcUrl,
        httpUrl: _convertMxcToHttp(mxcUrl),
        fileName: (event.content['filename'] as String?) ?? event.body,
        size: info?['size'] as int?,
        mimeType: mimeType.isNotEmpty ? mimeType : null,
      );
    }

    return null;
  }

  /// 提取投票消息元数据
  MessageMetadata? extractPollMetadata(matrix.Event event) {
    try {
      final pollStart =
          event.content['org.matrix.msc3381.poll.start']
              as Map<String, dynamic>?;
      if (pollStart == null) return null;

      // 提取问题
      final questionData = pollStart['question'] as Map<String, dynamic>?;
      final question =
          questionData?['org.matrix.msc1767.text'] as String? ??
          questionData?['body'] as String? ??
          event.body;

      // 提取选项
      final answers = pollStart['answers'] as List<dynamic>?;
      final options = <String>[];
      final optionIds = <String>[];

      if (answers != null) {
        for (final answer in answers) {
          if (answer is Map<String, dynamic>) {
            final id = answer['id'] as String? ?? '';
            final text = answer['org.matrix.msc1767.text'] as String? ?? '';
            optionIds.add(id);
            options.add(text);
          }
        }
      }

      // 提取投票设置
      final kind = pollStart['kind'] as String?;
      final maxSelections = pollStart['max_selections'] as int? ?? 1;
      final isAnonymousPoll = kind == 'org.matrix.msc3381.poll.undisclosed';

      // 从聚合事件中获取投票统计
      final voteCounts = <String, int>{};
      final voters = <String>{};
      final myVotes = <String>[];
      bool pollEnded = false;

      // 初始化所有选项的票数为0
      for (final optionId in optionIds) {
        voteCounts[optionId] = 0;
      }

      // 尝试从 unsigned.m.relations 获取聚合的投票数据
      // Matrix 服务器会在 poll.start 事件的 unsigned 中聚合投票响应
      // 注意：每个用户只能有一票，使用最新的投票响应
      try {
        final unsigned = event.unsigned;
        if (unsigned != null) {
          final relations = unsigned['m.relations'] as Map<String, dynamic>?;
          if (relations != null) {
            // 查找 m.reference 关系（投票响应使用 m.reference）
            final references =
                relations['m.reference'] as Map<String, dynamic>?;
            if (references != null) {
              final chunk = references['chunk'] as List<dynamic>?;
              if (chunk != null) {
                // 存储每个用户的最新投票
                final userVotes = <String, Map<String, dynamic>>{};

                for (final item in chunk) {
                  if (item is Map<String, dynamic>) {
                    final itemType = item['type'] as String?;
                    if (itemType == 'org.matrix.msc3381.poll.response') {
                      final senderId = item['sender'] as String?;
                      final originServerTs =
                          item['origin_server_ts'] as int? ?? 0;

                      if (senderId != null) {
                        // 只保留每个用户的最新投票
                        final existingVote = userVotes[senderId];
                        final existingTs =
                            existingVote?['origin_server_ts'] as int? ?? 0;

                        if (existingVote == null ||
                            originServerTs > existingTs) {
                          userVotes[senderId] = item;
                        }
                      }
                    } else if (itemType == 'org.matrix.msc3381.poll.end') {
                      pollEnded = true;
                    }
                  }
                }

                // 根据最新投票计算票数
                for (final entry in userVotes.entries) {
                  final senderId = entry.key;
                  final item = entry.value;
                  final content = item['content'] as Map<String, dynamic>?;
                  final response =
                      content?['org.matrix.msc3381.poll.response']
                          as Map<String, dynamic>?;

                  if (response != null) {
                    final selectedAnswers =
                        response['answers'] as List<dynamic>?;

                    if (selectedAnswers != null && selectedAnswers.isNotEmpty) {
                      voters.add(senderId);

                      for (final answerId in selectedAnswers) {
                        if (answerId is String &&
                            voteCounts.containsKey(answerId)) {
                          voteCounts[answerId] =
                              (voteCounts[answerId] ?? 0) + 1;
                        }
                      }

                      // 检查是否是当前用户的投票
                      if (senderId == _client?.userID) {
                        myVotes.clear();
                        for (final answerId in selectedAnswers) {
                          if (answerId is String) {
                            myVotes.add(answerId);
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        debugLog('MatrixMessageDataSource: Error parsing poll aggregation: $e');
      }

      // 检查是否是转发的投票快照
      final forwardedPoll =
          event.content['n42.forwarded_poll'] as Map<String, dynamic>?;
      if (forwardedPoll != null) {
        // 使用转发投票中的投票结果
        final forwardedVoteCounts =
            forwardedPoll['vote_counts'] as Map<String, dynamic>?;
        final forwardedTotalVoters = forwardedPoll['total_voters'] as int? ?? 0;
        final forwardedEnded = forwardedPoll['ended'] as bool? ?? true;

        if (forwardedVoteCounts != null) {
          voteCounts.clear();
          forwardedVoteCounts.forEach((key, value) {
            if (value is int) {
              voteCounts[key] = value;
            }
          });
        }

        return MessageMetadata(
          pollQuestion: question,
          pollOptions: options,
          pollOptionIds: optionIds,
          maxSelections: maxSelections,
          pollEnded: forwardedEnded, // 转发的投票始终标记为已结束
          isAnonymousPoll: isAnonymousPoll,
          voteCounts: voteCounts,
          totalVoters: forwardedTotalVoters,
          myVotes: myVotes, // 转发的投票不包含用户的投票记录
        );
      }

      return MessageMetadata(
        pollQuestion: question,
        pollOptions: options,
        pollOptionIds: optionIds,
        maxSelections: maxSelections,
        pollEnded: pollEnded,
        isAnonymousPoll: isAnonymousPoll,
        voteCounts: voteCounts,
        totalVoters: voters.length,
        myVotes: myVotes,
      );
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to extract poll metadata: $e');
      return null;
    }
  }
}
