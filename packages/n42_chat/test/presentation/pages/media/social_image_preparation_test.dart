import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:n42_chat/src/presentation/pages/media/social_image_preparation.dart';

void main() {
  group('prepareSocialImage', () {
    late BuildContext context;

    Future<void> pumpHarness(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (capturedContext) {
              context = capturedContext;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    }

    testWidgets('returns original bytes when editor is disabled', (
      tester,
    ) async {
      await pumpHarness(tester);

      final image = XFile.fromData(
        Uint8List.fromList(const [0xFF, 0xD8, 0xFF, 0xE0]),
        name: 'photo.jpg',
        mimeType: 'image/jpeg',
      );

      final prepared = await prepareSocialImage(
        context,
        image: image,
        openEditor: false,
      );

      expect(prepared, isNotNull);
      expect(prepared!.filename, 'image.jpg');
      expect(prepared.mimeType, 'image/jpeg');
      expect(prepared.bytes, orderedEquals(const [0xFF, 0xD8, 0xFF, 0xE0]));
    });

    testWidgets('normalizes mime type and filename after editing', (
      tester,
    ) async {
      await pumpHarness(tester);

      final image = XFile.fromData(
        Uint8List.fromList(const [0xFF, 0xD8, 0xFF, 0xE0]),
        name: 'photo.jpg',
        mimeType: 'image/jpeg',
      );
      final pngBytes = Uint8List.fromList(const [
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
      ]);

      final prepared = await prepareSocialImage(
        context,
        image: image,
        editorLauncher:
            (_, {required Uint8List imageBytes, String? filename}) async =>
                pngBytes,
      );

      expect(prepared, isNotNull);
      expect(prepared!.filename, 'image.png');
      expect(prepared.mimeType, 'image/png');
      expect(prepared.bytes, orderedEquals(pngBytes));
    });

    testWidgets('returns null when user cancels the editor', (tester) async {
      await pumpHarness(tester);

      final image = XFile.fromData(
        Uint8List.fromList(const [0xFF, 0xD8, 0xFF, 0xE0]),
        name: 'photo.jpg',
        mimeType: 'image/jpeg',
      );

      final prepared = await prepareSocialImage(
        context,
        image: image,
        editorLauncher:
            (_, {required Uint8List imageBytes, String? filename}) async =>
                null,
      );

      expect(prepared, isNull);
    });
  });
}
