import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/widget_test_helpers.dart';
import 'package:n42_wallet/features/live/presentation/pages/go_live_page.dart';
import 'package:n42_wallet/features/live/presentation/widgets/gift_economy.dart';
import 'package:n42_wallet/features/live/presentation/widgets/gift_providers.dart';
import 'package:n42_wallet/features/live/prediction/providers/prediction_providers.dart';
import 'package:n42_wallet/features/live/services/live_chat_service.dart';
import 'package:n42_wallet/features/live/services/live_video_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// The service method exposes n42_chat's LiveKit type, which is not public API.
// ignore_for_file: implementation_imports
import 'package:n42_chat/src/services/voip/livekit_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'keeps Matrix live when LiveKit join and best-effort cleanup fail',
    (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const roomId = '!host:m.example';
      final chat = _RecordingLiveChatService();
      final video = _FailingLiveVideoService();
      final economy = LiveGiftEconomy(chat);

      await tester.pumpWidget(
        wrapForTest(
          GoLivePage(
            chatServiceForTesting: chat,
            videoServiceForTesting: video,
            permissionRequestForTesting: () async => {
              Permission.camera: PermissionStatus.granted,
              Permission.microphone: PermissionStatus.granted,
            },
          ),
          overrides: [
            giftEconomyProvider.overrideWith((ref) => economy),
            giftEarningsProvider.overrideWith(
              (ref, room) => Stream<int>.value(0),
            ),
            roomMarketsProvider.overrideWith(
              (ref, room) => Stream.value(const []),
            ),
          ],
        ),
      );

      await tester.tap(find.text('开始直播'));
      await tester.pumpAndSettle();

      expect(chat.calls, [
        'create:$roomId',
        'join:$roomId',
        'watchDanmu:$roomId',
        'markLive:$roomId',
      ]);
      expect(video.calls, ['join:$roomId', 'leave']);
      expect(find.text('视频暂不可用，其他直播功能可继续使用'), findsOneWidget);
      expect(find.text('Bad state: LiveKit unavailable'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(chat.calls, [
        'create:$roomId',
        'join:$roomId',
        'watchDanmu:$roomId',
        'markLive:$roomId',
        'markEnded:$roomId',
        'leave:$roomId',
      ]);
      expect(video.calls, ['join:$roomId', 'leave', 'dispose']);
      economy.dispose();
    },
  );

  testWidgets('does not create a room until both permissions are granted', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final chat = _RecordingLiveChatService();
    final video = _FailingLiveVideoService();

    await tester.pumpWidget(
      wrapForTest(
        GoLivePage(
          chatServiceForTesting: chat,
          videoServiceForTesting: video,
          permissionRequestForTesting: () async => {
            Permission.camera: PermissionStatus.granted,
            Permission.microphone: PermissionStatus.denied,
          },
        ),
      ),
    );

    await tester.tap(find.text('开始直播'));
    await tester.pumpAndSettle();

    expect(find.text('Bad state: 需要摄像头与麦克风权限才能开播'), findsOneWidget);
    expect(chat.calls, isEmpty);
    expect(video.calls, isEmpty);
  });

  testWidgets('rolls back a created room when Matrix join fails', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final chat = _RecordingLiveChatService(failJoin: true);
    final video = _FailingLiveVideoService();
    final economy = LiveGiftEconomy(chat);

    await tester.pumpWidget(
      wrapForTest(
        GoLivePage(
          chatServiceForTesting: chat,
          videoServiceForTesting: video,
          permissionRequestForTesting: () async => {
            Permission.camera: PermissionStatus.granted,
            Permission.microphone: PermissionStatus.granted,
          },
        ),
        overrides: [
          giftEconomyProvider.overrideWith((ref) => economy),
          giftEarningsProvider.overrideWith(
            (ref, room) => Stream<int>.value(0),
          ),
          roomMarketsProvider.overrideWith(
            (ref, room) => Stream.value(const []),
          ),
        ],
      ),
    );

    await tester.tap(find.text('开始直播'));
    await tester.pumpAndSettle();

    expect(find.text('Bad state: Matrix join failed'), findsOneWidget);
    expect(chat.calls, [
      'create:!host:m.example',
      'join:!host:m.example',
      'leave:!host:m.example',
    ]);
    expect(video.calls, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    economy.dispose();
  });
}

class _RecordingLiveChatService extends LiveChatService {
  _RecordingLiveChatService({this.failJoin = false});

  final bool failJoin;
  final calls = <String>[];

  @override
  Future<String> createLiveRoom({required String name}) async {
    calls.add('create:!host:m.example');
    return '!host:m.example';
  }

  @override
  Future<void> join(String roomId) async {
    calls.add('join:$roomId');
    if (failJoin) throw StateError('Matrix join failed');
  }

  @override
  Stream<List<LiveDanmu>> watchDanmu(String roomId) {
    calls.add('watchDanmu:$roomId');
    return Stream.value(const []);
  }

  @override
  Stream<List<LiveEvent>> watchEvents(String roomId) => const Stream.empty();

  @override
  Future<void> leave(String roomId) async => calls.add('leave:$roomId');

  @override
  Future<void> markLive(String roomId) async => calls.add('markLive:$roomId');

  @override
  Future<void> markEnded(String roomId) async => calls.add('markEnded:$roomId');
}

class _FailingLiveVideoService extends LiveVideoService {
  final calls = <String>[];

  @override
  Future<void> leave() async {
    calls.add('leave');
    throw StateError('cleanup unavailable');
  }

  @override
  Future<void> dispose() async => calls.add('dispose');

  @override
  Future<LiveKitService> joinAsBroadcaster(String matrixRoomId) async {
    calls.add('join:$matrixRoomId');
    throw StateError('LiveKit unavailable');
  }
}
