import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/live/services/live_chat_service.dart';

void main() {
  final now = DateTime(2026, 7, 14, 12);

  test('目录心跳只接受有效且未过期的直播标记', () {
    final current = now.millisecondsSinceEpoch;
    expect(
      LiveChatService.isDirectoryLiveTopic(
        'n42.live.directory:v1:$current',
        now: now,
      ),
      isTrue,
    );
    expect(
      LiveChatService.isDirectoryLiveTopic(
        'n42.live.directory:v1:${now.subtract(LiveChatService.liveTtl).millisecondsSinceEpoch}',
        now: now,
      ),
      isFalse,
    );
    expect(
      LiveChatService.isDirectoryLiveTopic('unrelated topic', now: now),
      isFalse,
    );
  });

  test('状态心跳拒绝远未来时间，避免房间永久显示直播中', () {
    expect(
      LiveChatService.isLiveState({
        'live': true,
        'ts': now
            .add(LiveChatService.maxFutureHeartbeatSkew)
            .add(const Duration(seconds: 1))
            .millisecondsSinceEpoch,
      }, now: now),
      isFalse,
    );
    expect(
      LiveChatService.isLiveState({
        'live': true,
        'ts': now.millisecondsSinceEpoch,
      }, now: now),
      isTrue,
    );
  });
}
