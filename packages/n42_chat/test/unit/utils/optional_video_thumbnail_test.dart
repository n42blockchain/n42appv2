import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/optional_video_thumbnail.dart';

void main() {
  test('native gallery failure yields null for file-based fallback', () async {
    final thumbnail = await loadOptionalVideoThumbnail(
      () async => throw PlatformException(code: 'thumbnail_unavailable'),
    );
    expect(thumbnail, isNull);
  });

  test(
    'synchronous plugin failure also leaves video sending available',
    () async {
      final thumbnail = await loadOptionalVideoThumbnail(
        () => throw MissingPluginException('Gallery preview unavailable'),
      );
      expect(thumbnail, isNull);
    },
  );

  test('missing or empty gallery preview enables fallback', () async {
    expect(await loadOptionalVideoThumbnail(() async => null), isNull);
    expect(await loadOptionalVideoThumbnail(() async => Uint8List(0)), isNull);
  });

  test(
    'valid gallery bytes are preserved without copying or conversion',
    () async {
      final bytes = Uint8List.fromList([0xff, 0xd8, 0xff, 0xd9]);
      expect(await loadOptionalVideoThumbnail(() async => bytes), same(bytes));
    },
  );
}
