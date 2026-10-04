import 'dart:async';
import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a delayed seek completion after dispose is ignored', () async {
    final previousPlatform = VideoPlayerPlatform.instance;
    final platform = _DelayedSeekPlatform();
    VideoPlayerPlatform.instance = platform;
    addTearDown(() {
      VideoPlayerPlatform.instance = previousPlatform;
    });

    final controller = VideoPlayerController.networkUrl(
      Uri.parse('https://example.test/video.mp4'),
      videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
    );
    await controller.initialize();

    final pendingSeek = controller.seekTo(const Duration(seconds: 12));
    await controller.dispose();
    platform.seekCompletion.complete();

    await expectLater(pendingSeek, completes);
  });
}

class _DelayedSeekPlatform extends VideoPlayerPlatform {
  final Completer<void> seekCompletion = Completer<void>();

  @override
  Future<void> init() async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async => 1;

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => Stream.value(
    VideoEvent(
      eventType: VideoEventType.initialized,
      duration: const Duration(minutes: 1),
      size: const Size(1920, 1080),
    ),
  );

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}

  @override
  Future<void> play(int playerId) async {}

  @override
  Future<void> pause(int playerId) async {}

  @override
  Future<void> seekTo(int playerId, Duration position) => seekCompletion.future;

  @override
  Future<void> dispose(int playerId) async {}
}
