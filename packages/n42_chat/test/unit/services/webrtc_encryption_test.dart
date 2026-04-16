import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/services/voip/webrtc_service.dart';

void main() {
  // ============================================
  // CallSession 测试
  // ============================================
  group('CallSession', () {
    late CallSession session;
    late DateTime startTime;

    setUp(() {
      startTime = DateTime(2025, 6, 1, 10, 0, 0);
      session = CallSession(
        callId: 'call_12345',
        roomId: '!room:example.com',
        peerId: '@alice:example.com',
        peerName: 'Alice',
        peerAvatarUrl: 'mxc://example.com/avatar.png',
        type: CallType.video,
        direction: CallDirection.outgoing,
        startTime: startTime,
      );
    });

    test('should create with all fields', () {
      expect(session.callId, equals('call_12345'));
      expect(session.roomId, equals('!room:example.com'));
      expect(session.peerId, equals('@alice:example.com'));
      expect(session.peerName, equals('Alice'));
      expect(session.peerAvatarUrl, equals('mxc://example.com/avatar.png'));
      expect(session.type, equals(CallType.video));
      expect(session.direction, equals(CallDirection.outgoing));
      expect(session.startTime, equals(startTime));
      expect(session.connectedTime, isNull);
      expect(session.endTime, isNull);
    });

    test('should create with null peerAvatarUrl', () {
      final noAvatarSession = CallSession(
        callId: 'call_99',
        roomId: '!room:example.com',
        peerId: '@bob:example.com',
        peerName: 'Bob',
        type: CallType.voice,
        direction: CallDirection.incoming,
        startTime: startTime,
      );

      expect(noAvatarSession.peerAvatarUrl, isNull);
      expect(noAvatarSession.type, equals(CallType.voice));
      expect(noAvatarSession.direction, equals(CallDirection.incoming));
    });

    group('duration', () {
      test('should return Duration.zero when connectedTime is null', () {
        expect(session.connectedTime, isNull);
        expect(session.duration, equals(Duration.zero));
      });

      test('should return correct duration when connected and ended', () {
        final connectedTime = DateTime(2025, 6, 1, 10, 0, 10);
        final endTime = DateTime(2025, 6, 1, 10, 5, 30);

        session.connectedTime = connectedTime;
        session.endTime = endTime;

        // 5 分 20 秒 = 320 秒
        expect(session.duration, equals(const Duration(minutes: 5, seconds: 20)));
      });

      test('should use DateTime.now when endTime is null (ongoing call)', () {
        session.connectedTime = DateTime.now().subtract(const Duration(seconds: 5));

        // 通话正在进行中，duration 应该大于 0
        expect(session.duration.inSeconds, greaterThanOrEqualTo(4));
        expect(session.duration.inSeconds, lessThanOrEqualTo(10));
      });

      test('should return Duration.zero even when endTime is set but connectedTime is null', () {
        session.endTime = DateTime.now();
        expect(session.duration, equals(Duration.zero));
      });
    });

    group('copyWith', () {
      test('should preserve all original fields when no arguments given', () {
        final copied = session.copyWith();

        expect(copied.callId, equals(session.callId));
        expect(copied.roomId, equals(session.roomId));
        expect(copied.peerId, equals(session.peerId));
        expect(copied.peerName, equals(session.peerName));
        expect(copied.peerAvatarUrl, equals(session.peerAvatarUrl));
        expect(copied.type, equals(session.type));
        expect(copied.direction, equals(session.direction));
        expect(copied.startTime, equals(session.startTime));
      });

      test('should update connectedTime via copyWith', () {
        final connectedTime = DateTime(2025, 6, 1, 10, 0, 5);
        final copied = session.copyWith(connectedTime: connectedTime);

        expect(copied.connectedTime, equals(connectedTime));
        expect(copied.callId, equals(session.callId));
      });

      test('should update endTime via copyWith', () {
        final endTime = DateTime(2025, 6, 1, 10, 10, 0);
        final copied = session.copyWith(endTime: endTime);

        expect(copied.endTime, equals(endTime));
        expect(copied.callId, equals(session.callId));
      });

      test('should preserve existing connectedTime when copyWith provides only endTime', () {
        session.connectedTime = DateTime(2025, 6, 1, 10, 0, 5);

        final endTime = DateTime(2025, 6, 1, 10, 10, 0);
        final copied = session.copyWith(endTime: endTime);

        expect(copied.connectedTime, equals(session.connectedTime));
        expect(copied.endTime, equals(endTime));
      });

      test('should create a distinct instance', () {
        final copied = session.copyWith();

        // Mutating original should not affect copy
        session.connectedTime = DateTime.now();
        expect(copied.connectedTime, isNull);
      });
    });
  });

  // ============================================
  // 枚举值测试
  // ============================================
  group('CallState enum', () {
    test('should have all expected values', () {
      expect(CallState.values, contains(CallState.idle));
      expect(CallState.values, contains(CallState.ringing));
      expect(CallState.values, contains(CallState.incoming));
      expect(CallState.values, contains(CallState.connecting));
      expect(CallState.values, contains(CallState.connected));
      expect(CallState.values, contains(CallState.reconnecting));
      expect(CallState.values, contains(CallState.ended));
      expect(CallState.values, contains(CallState.failed));
    });

    test('should have exactly 8 values', () {
      expect(CallState.values.length, equals(8));
    });
  });

  group('CallType enum', () {
    test('should have all expected values', () {
      expect(CallType.values, contains(CallType.voice));
      expect(CallType.values, contains(CallType.video));
    });

    test('should have exactly 2 values', () {
      expect(CallType.values.length, equals(2));
    });
  });

  group('CallDirection enum', () {
    test('should have all expected values', () {
      expect(CallDirection.values, contains(CallDirection.outgoing));
      expect(CallDirection.values, contains(CallDirection.incoming));
    });

    test('should have exactly 2 values', () {
      expect(CallDirection.values.length, equals(2));
    });
  });

  // ============================================
  // isInCall 逻辑测试
  // ============================================
  group('isInCall logic', () {
    // 从 WebRTCService 中提取的逻辑：
    // bool get isInCall => _state != CallState.idle
    //     && _state != CallState.ended
    //     && _state != CallState.failed;
    bool isInCallForState(CallState state) {
      return state != CallState.idle &&
          state != CallState.ended &&
          state != CallState.failed;
    }

    test('should return false for idle state', () {
      expect(isInCallForState(CallState.idle), isFalse);
    });

    test('should return false for ended state', () {
      expect(isInCallForState(CallState.ended), isFalse);
    });

    test('should return false for failed state', () {
      expect(isInCallForState(CallState.failed), isFalse);
    });

    test('should return true for ringing state', () {
      expect(isInCallForState(CallState.ringing), isTrue);
    });

    test('should return true for incoming state', () {
      expect(isInCallForState(CallState.incoming), isTrue);
    });

    test('should return true for connecting state', () {
      expect(isInCallForState(CallState.connecting), isTrue);
    });

    test('should return true for connected state', () {
      expect(isInCallForState(CallState.connected), isTrue);
    });

    test('should return true for reconnecting state', () {
      expect(isInCallForState(CallState.reconnecting), isTrue);
    });

    test('should be false for exactly 3 states and true for the remaining 5', () {
      final falseStates = CallState.values.where((s) => !isInCallForState(s));
      final trueStates = CallState.values.where((s) => isInCallForState(s));

      expect(falseStates.length, equals(3));
      expect(trueStates.length, equals(5));
    });
  });

  // ============================================
  // 通话过期逻辑测试
  // ============================================
  group('Call invite expiry logic', () {
    // 从 WebRTCService._handleCallInviteFromRoom 中提取的逻辑：
    //   final lifetime = content['lifetime'] as int? ?? 60000;
    //   if (event.originServerTs != null) {
    //     final age = DateTime.now().difference(event.originServerTs!).inMilliseconds;
    //     if (age > lifetime) {
    //       // expired, should ignore
    //     }
    //   }
    bool isCallExpired({DateTime? originServerTs, int lifetime = 60000}) {
      if (originServerTs == null) return false;
      final age = DateTime.now().difference(originServerTs).inMilliseconds;
      return age > lifetime;
    }

    test('should consider call expired when age exceeds lifetime', () {
      // 通话邀请发送于 120 秒前，lifetime 为 60 秒（60000ms）
      final oldTimestamp = DateTime.now().subtract(const Duration(seconds: 120));

      expect(isCallExpired(originServerTs: oldTimestamp, lifetime: 60000), isTrue);
    });

    test('should not consider call expired when age is within lifetime', () {
      // 通话邀请发送于 5 秒前，lifetime 为 60 秒
      final recentTimestamp = DateTime.now().subtract(const Duration(seconds: 5));

      expect(isCallExpired(originServerTs: recentTimestamp, lifetime: 60000), isFalse);
    });

    test('should not consider call expired when originServerTs is null', () {
      // 没有服务器时间戳的情况，不应判定为过期
      expect(isCallExpired(originServerTs: null, lifetime: 60000), isFalse);
    });

    test('should consider call expired when age barely exceeds lifetime', () {
      // 邀请在 lifetime + 1 秒之前
      final borderTimestamp = DateTime.now().subtract(const Duration(milliseconds: 60001));

      // 由于测试执行可能有微小时间偏移，使用 >= 61s 以确保可靠
      expect(isCallExpired(originServerTs: borderTimestamp, lifetime: 60000), isTrue);
    });

    test('should not consider call expired with a very large lifetime', () {
      // 即使邀请是 10 分钟前，如果 lifetime 是 1 小时，也不应该过期
      final oldTimestamp = DateTime.now().subtract(const Duration(minutes: 10));

      expect(
        isCallExpired(originServerTs: oldTimestamp, lifetime: 3600000),
        isFalse,
      );
    });

    test('should use default lifetime of 60000ms when not specified', () {
      // 30 秒前的邀请，使用默认 lifetime
      final recentTimestamp = DateTime.now().subtract(const Duration(seconds: 30));
      expect(isCallExpired(originServerTs: recentTimestamp), isFalse);

      // 90 秒前的邀请，使用默认 lifetime
      final oldTimestamp = DateTime.now().subtract(const Duration(seconds: 90));
      expect(isCallExpired(originServerTs: oldTimestamp), isTrue);
    });
  });

  // ============================================
  // processedCallIds 去重集合逻辑测试
  // ============================================
  group('Processed callIds dedup set logic', () {
    // 从 WebRTCService._handleCallInviteFromRoom 中提取的逻辑：
    //   if (_processedCallIds.contains(callId)) { return; }
    //   _processedCallIds.add(callId);
    //   if (_processedCallIds.length > 50) {
    //     _processedCallIds.remove(_processedCallIds.first);
    //   }
    late Set<String> processedCallIds;

    void addCallId(String callId) {
      processedCallIds.add(callId);
      if (processedCallIds.length > 50) {
        processedCallIds.remove(processedCallIds.first);
      }
    }

    setUp(() {
      processedCallIds = <String>{};
    });

    test('should add and check contains correctly', () {
      addCallId('call_001');

      expect(processedCallIds.contains('call_001'), isTrue);
      expect(processedCallIds.contains('call_002'), isFalse);
    });

    test('should detect duplicate callId', () {
      addCallId('call_abc');
      addCallId('call_def');

      // 模拟去重检查
      final isDuplicate = processedCallIds.contains('call_abc');
      expect(isDuplicate, isTrue);

      // 新的 callId 不是重复
      expect(processedCallIds.contains('call_ghi'), isFalse);
    });

    test('should cap at 50 entries by removing the oldest', () {
      // 添加 50 个 callId
      for (int i = 0; i < 50; i++) {
        addCallId('call_$i');
      }
      expect(processedCallIds.length, equals(50));
      expect(processedCallIds.contains('call_0'), isTrue);

      // 添加第 51 个，应该移除最早的 call_0
      addCallId('call_50');
      expect(processedCallIds.length, equals(50));
      expect(processedCallIds.contains('call_0'), isFalse);
      expect(processedCallIds.contains('call_50'), isTrue);
    });

    test('should continue to remove oldest when adding beyond 50', () {
      // 添加 55 个 callId
      for (int i = 0; i < 55; i++) {
        addCallId('call_$i');
      }

      expect(processedCallIds.length, equals(50));

      // call_0 到 call_4 应该被移除
      expect(processedCallIds.contains('call_0'), isFalse);
      expect(processedCallIds.contains('call_1'), isFalse);
      expect(processedCallIds.contains('call_2'), isFalse);
      expect(processedCallIds.contains('call_3'), isFalse);
      expect(processedCallIds.contains('call_4'), isFalse);

      // call_5 到 call_54 应该保留
      expect(processedCallIds.contains('call_5'), isTrue);
      expect(processedCallIds.contains('call_54'), isTrue);
    });

    test('should not remove entries when adding duplicates (set ignores them)', () {
      addCallId('call_dup');
      addCallId('call_dup'); // duplicate, set ignores it

      expect(processedCallIds.length, equals(1));
      expect(processedCallIds.contains('call_dup'), isTrue);
    });

    test('empty set should not contain any callId', () {
      expect(processedCallIds.contains('call_nonexistent'), isFalse);
      expect(processedCallIds.length, equals(0));
    });
  });
}
