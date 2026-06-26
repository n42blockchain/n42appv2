import 'package:matrix/matrix.dart' as matrix;

import '../matrix_client_manager.dart';
import '../../../../core/utils/debug_log.dart';

/// Matrix 投票操作处理器
///
/// 封装 MSC3381 投票相关的操作：创建投票、投票响应、结束投票、获取投票聚合结果
class MatrixPollHandler {
  final MatrixClientManager _clientManager;

  MatrixPollHandler(this._clientManager);

  matrix.Client? get _client => _clientManager.client;

  /// 发送投票消息
  ///
  /// 使用 Matrix MSC3381 投票规范
  Future<String?> sendPollMessage(
    String roomId, {
    required String question,
    required List<String> options,
    int maxSelections = 1,
    bool isAnonymous = false,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) {
      debugLog('MatrixMessageDataSource: Room not found: $roomId');
      return null;
    }

    try {
      // 生成选项ID
      final pollOptions = options.asMap().entries.map((entry) {
        final index = entry.key;
        final text = entry.value;
        // 使用时间戳+索引生成唯一ID
        final optionId = '${DateTime.now().millisecondsSinceEpoch}_$index';
        return {
          'id': optionId,
          'org.matrix.msc1767.text': text,
        };
      }).toList();

      // MSC3381 投票开始事件
      final content = {
        'org.matrix.msc3381.poll.start': {
          'question': {
            'org.matrix.msc1767.text': question,
          },
          'kind': isAnonymous
              ? 'org.matrix.msc3381.poll.undisclosed'
              : 'org.matrix.msc3381.poll.disclosed',
          'max_selections': maxSelections == 0 ? options.length : maxSelections,
          'answers': pollOptions,
        },
        'org.matrix.msc1767.text': '$question\n${options.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}',
      };

      final eventId = await room.sendEvent(
        content,
        type: 'org.matrix.msc3381.poll.start',
      );

      debugLog('MatrixMessageDataSource: Poll sent successfully: $eventId');
      return eventId;
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to send poll: $e');
      rethrow;
    }
  }

  /// 发送转发的投票快照（包含投票结果，已结束状态）
  ///
  /// 转发投票时，发送一个包含投票结果的快照，标记为已结束，不可再投票
  Future<String?> sendForwardedPollSnapshot(
    String roomId, {
    required String question,
    required List<String> options,
    required List<String> optionIds,
    required Map<String, int> voteCounts,
    required int totalVoters,
    int maxSelections = 1,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) {
      debugLog('MatrixMessageDataSource: Room not found: $roomId');
      return null;
    }

    try {
      // 使用原有的选项ID或生成新的
      final pollOptions = <Map<String, dynamic>>[];
      for (var i = 0; i < options.length; i++) {
        final optionId = i < optionIds.length ? optionIds[i] : '${DateTime.now().millisecondsSinceEpoch}_$i';
        pollOptions.add({
          'id': optionId,
          'org.matrix.msc1767.text': options[i],
        });
      }

      // 构建投票结果文本显示
      final resultLines = <String>[];
      resultLines.add('\u{1F4CA} $question');
      resultLines.add('');
      for (var i = 0; i < options.length; i++) {
        final optionId = i < optionIds.length ? optionIds[i] : '';
        final count = voteCounts[optionId] ?? 0;
        final percentage = totalVoters > 0 ? (count * 100 / totalVoters).round() : 0;
        resultLines.add('${options[i]}: $count votes ($percentage%)');
      }
      resultLines.add('');
      resultLines.add('$totalVoters participants');
      resultLines.add('(Forwarded poll snapshot)');

      // 使用自定义的转发投票格式
      // 包含 n42.forwarded_poll 标记，表示这是转发的投票快照
      final content = {
        'org.matrix.msc3381.poll.start': {
          'question': {
            'org.matrix.msc1767.text': question,
          },
          'kind': 'org.matrix.msc3381.poll.disclosed',
          'max_selections': maxSelections == 0 ? options.length : maxSelections,
          'answers': pollOptions,
        },
        // 标记为转发的投票快照，包含结果
        'n42.forwarded_poll': {
          'vote_counts': voteCounts.map((k, v) => MapEntry(k, v)),
          'total_voters': totalVoters,
          'ended': true,
        },
        'org.matrix.msc1767.text': resultLines.join('\n'),
      };

      final eventId = await room.sendEvent(
        content,
        type: 'org.matrix.msc3381.poll.start',
      );

      debugLog('MatrixMessageDataSource: Forwarded poll snapshot sent: $eventId');
      return eventId;
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to send forwarded poll: $e');
      rethrow;
    }
  }

  /// 投票响应
  ///
  /// 发送 MSC3381 投票响应事件
  Future<bool> voteOnPoll(
    String roomId, {
    required String pollEventId,
    required List<String> selectedOptionIds,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) {
      debugLog('MatrixMessageDataSource: Room not found: $roomId');
      return false;
    }

    try {
      // MSC3381 投票响应事件
      final content = {
        'm.relates_to': {
          'rel_type': 'm.reference',
          'event_id': pollEventId,
        },
        'org.matrix.msc3381.poll.response': {
          'answers': selectedOptionIds,
        },
      };

      await room.sendEvent(
        content,
        type: 'org.matrix.msc3381.poll.response',
      );

      debugLog('MatrixMessageDataSource: Vote submitted successfully');
      return true;
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to vote: $e');
      return false;
    }
  }

  /// 结束投票
  Future<bool> endPoll(String roomId, String pollEventId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return false;

    try {
      final content = {
        'm.relates_to': {
          'rel_type': 'm.reference',
          'event_id': pollEventId,
        },
        'org.matrix.msc3381.poll.end': <String, dynamic>{},
        'org.matrix.msc1767.text': 'Poll ended',
      };

      await room.sendEvent(
        content,
        type: 'org.matrix.msc3381.poll.end',
      );

      return true;
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to end poll: $e');
      return false;
    }
  }

  /// 获取消息的反应聚合结果
  ///
  /// 从服务器获取消息的所有 emoji 反应
  Future<Map<String, dynamic>?> getReactionAggregations(String roomId, String eventId) async {
    try {
      final room = _client?.getRoomById(roomId);
      if (room == null) return null;

      // 使用 Matrix API 获取事件关系（反应使用 m.annotation 类型）
      final response = await _client!.request(
        matrix.RequestType.GET,
        '/client/v1/rooms/${Uri.encodeComponent(roomId)}/relations/${Uri.encodeComponent(eventId)}/m.annotation',
      );

      final reactions = <String, Map<String, dynamic>>{};
      final currentUserId = _client?.userID ?? '';

      final chunk = response['chunk'] as List<dynamic>?;
      if (chunk != null) {
        for (final item in chunk) {
          if (item is Map<String, dynamic>) {
            final itemType = item['type'] as String?;
            if (itemType == 'm.reaction') {
              final content = item['content'] as Map<String, dynamic>?;
              final relatesTo = content?['m.relates_to'] as Map<String, dynamic>?;
              final emoji = relatesTo?['key'] as String?;
              final senderId = item['sender'] as String?;

              if (emoji != null && senderId != null) {
                if (!reactions.containsKey(emoji)) {
                  reactions[emoji] = {
                    'count': 0,
                    'userIds': <String>[],
                    'isMe': false,
                  };
                }
                reactions[emoji]!['count'] = (reactions[emoji]!['count'] as int) + 1;
                (reactions[emoji]!['userIds'] as List<String>).add(senderId);
                if (senderId == currentUserId) {
                  reactions[emoji]!['isMe'] = true;
                }
              }
            }
          }
        }
      }

      return {
        'eventId': eventId,
        'reactions': reactions,
      };
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to get reaction aggregations: $e');
      return null;
    }
  }

  /// 获取投票的聚合结果
  ///
  /// 根据 MSC3381 规范，每个用户只能有一票（使用最新的投票响应）
  Future<Map<String, dynamic>?> getPollAggregations(String roomId, String pollEventId) async {
    try {
      final room = _client?.getRoomById(roomId);
      if (room == null) return null;

      // 使用 Matrix API 获取事件关系
      final response = await _client!.request(
        matrix.RequestType.GET,
        '/client/v1/rooms/${Uri.encodeComponent(roomId)}/relations/${Uri.encodeComponent(pollEventId)}/m.reference',
      );

      // 存储每个用户的最新投票（按 origin_server_ts 排序）
      final userVotes = <String, Map<String, dynamic>>{};
      bool pollEnded = false;

      final chunk = response['chunk'] as List<dynamic>?;
      if (chunk != null) {
        for (final item in chunk) {
          if (item is Map<String, dynamic>) {
            final itemType = item['type'] as String?;
            if (itemType == 'org.matrix.msc3381.poll.response') {
              final senderId = item['sender'] as String?;
              final originServerTs = item['origin_server_ts'] as int? ?? 0;

              if (senderId != null) {
                // 只保留每个用户的最新投票
                final existingVote = userVotes[senderId];
                final existingTs = existingVote?['origin_server_ts'] as int? ?? 0;

                if (existingVote == null || originServerTs > existingTs) {
                  userVotes[senderId] = item;
                }
              }
            } else if (itemType == 'org.matrix.msc3381.poll.end') {
              pollEnded = true;
            }
          }
        }
      }

      // 根据最新投票计算票数
      final voteCounts = <String, int>{};
      final myVotes = <String>[];

      for (final entry in userVotes.entries) {
        final senderId = entry.key;
        final item = entry.value;
        final content = item['content'] as Map<String, dynamic>?;
        final pollResponse = content?['org.matrix.msc3381.poll.response'] as Map<String, dynamic>?;

        if (pollResponse != null) {
          final selectedAnswers = pollResponse['answers'] as List<dynamic>?;

          if (selectedAnswers != null && selectedAnswers.isNotEmpty) {
            for (final answerId in selectedAnswers) {
              if (answerId is String) {
                voteCounts[answerId] = (voteCounts[answerId] ?? 0) + 1;
              }
            }

            // 记录当前用户的投票
            if (senderId == _client?.userID) {
              for (final answerId in selectedAnswers) {
                if (answerId is String) {
                  myVotes.add(answerId);
                }
              }
            }
          }
        }
      }

      // 计算实际投票人数（只计算有有效投票的用户）
      final totalVoters = userVotes.entries.where((entry) {
        final content = entry.value['content'] as Map<String, dynamic>?;
        final pollResponse = content?['org.matrix.msc3381.poll.response'] as Map<String, dynamic>?;
        final answers = pollResponse?['answers'] as List<dynamic>?;
        return answers != null && answers.isNotEmpty;
      }).length;

      debugLog('MatrixMessageDataSource: Poll $pollEventId - voteCounts: $voteCounts, totalVoters: $totalVoters, myVotes: $myVotes');

      return {
        'voteCounts': voteCounts,
        'totalVoters': totalVoters,
        'myVotes': myVotes,
        'pollEnded': pollEnded,
      };
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to get poll aggregations: $e');
      return null;
    }
  }
}
