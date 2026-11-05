import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.justsoft.xyz/video_thumbnail');
  final calls = <MethodCall>[];
  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return call.method == 'file'
              ? 'path/frame.jpg'
              : Uint8List.fromList([1, 2, 3]);
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  test('file thumbnail retains path, dimensions, seek and headers', () async {
    expect(
      await VideoThumbnail.thumbnailFile(
        video: 'https://example.test/video',
        thumbnailPath: 'path/frame.jpg',
        imageFormat: ImageFormat.JPEG,
        maxWidth: 123,
        maxHeight: 456,
        timeMs: 2000,
        quality: 45,
        headers: {'X-Test': 'fixture'},
      ),
      'path/frame.jpg',
    );
    expect(calls.single.method, 'file');
    expect(calls.single.arguments, {
      'video': 'https://example.test/video',
      'path': 'path/frame.jpg',
      'format': 0,
      'maxw': 123,
      'maxh': 456,
      'timeMs': 2000,
      'quality': 45,
      'headers': {'X-Test': 'fixture'},
    });
  });
  test(
    'in-memory thumbnail returns native bytes and retains defaults',
    () async {
      expect(await VideoThumbnail.thumbnailData(video: 'video.mp4'), [1, 2, 3]);
      expect(calls.single.method, 'data');
      expect(calls.single.arguments, {
        'video': 'video.mp4',
        'headers': null,
        'format': ImageFormat.PNG.index,
        'maxh': 0,
        'maxw': 0,
        'timeMs': 0,
        'quality': 10,
      });
    },
  );
}
