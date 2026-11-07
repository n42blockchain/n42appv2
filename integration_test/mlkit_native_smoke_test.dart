// Synthetic inputs only. Run on a disposable simulator/device; no account login.
// ignore_for_file: depend_on_referenced_packages
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image/image.dart' as image;
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late InputImage input;

  setUpAll(() async {
    directory = await (await getTemporaryDirectory()).createTemp(
      'mlkit-smoke-',
    );
    final canvas = image.Image(width: 640, height: 256);
    image.fill(canvas, color: image.ColorRgb8(255, 255, 255));
    image.drawString(
      canvas,
      'HELLO N42',
      font: image.arial48,
      x: 50,
      y: 80,
      color: image.ColorRgb8(0, 0, 0),
    );
    final file = File('${directory.path}/synthetic.png');
    await file.writeAsBytes(image.encodePng(canvas));
    input = InputImage.fromFilePath(file.path);
  });
  tearDownAll(() => directory.delete(recursive: true));

  for (final script in TextRecognitionScript.values) {
    testWidgets('native OCR ${script.name} model loads and processes text', (
      tester,
    ) async {
      final recognizer = TextRecognizer(script: script);
      try {
        final result = await recognizer.processImage(input);
        expect(result.text.toUpperCase(), contains('HELLO'));
      } finally {
        await recognizer.close();
      }
    });
  }

  testWidgets('native face model processes a synthetic non-face image', (
    tester,
  ) async {
    final detector = FaceDetector(options: FaceDetectorOptions());
    try {
      expect(await detector.processImage(input), isEmpty);
    } finally {
      await detector.close();
    }
  });

  testWidgets('native segmentation produces a finite complete mask', (
    tester,
  ) async {
    final segmenter = SelfieSegmenter(
      mode: SegmenterMode.single,
      enableRawSizeMask: true,
    );
    try {
      final mask = await segmenter.processImage(input);
      expect(mask, isNotNull);
      expect(mask!.width, greaterThan(0));
      expect(mask.height, greaterThan(0));
      expect(mask.confidences.length, mask.width * mask.height);
      expect(
        mask.confidences.every((x) => x.isFinite && x >= 0 && x <= 1),
        isTrue,
      );
    } finally {
      await segmenter.close();
    }
  });

  testWidgets(
    'native translation downloads a model and translates synthetic text',
    (tester) async {
      final manager = OnDeviceTranslatorModelManager();
      final existed = await manager
          .isModelDownloaded('es')
          .timeout(const Duration(seconds: 15));
      debugPrint('MLKIT smoke: initial model check completed');
      final translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: TranslateLanguage.spanish,
      );
      try {
        expect(
          await manager
              .downloadModel('es', isWifiRequired: false)
              .timeout(const Duration(seconds: 90)),
          isTrue,
        );
        debugPrint('MLKIT smoke: model download completed');
        final result = await translator
            .translateText('Hello world')
            .timeout(const Duration(seconds: 30));
        debugPrint('MLKIT smoke: translation completed');
        expect(result.toLowerCase(), contains('hola'));
      } finally {
        await translator.close().timeout(const Duration(seconds: 10));
        if (!existed) {
          await manager.deleteModel('es').timeout(const Duration(seconds: 10));
        }
      }
    },
    skip: !const bool.fromEnvironment('N42_MLKIT_DOWNLOAD_MODEL'),
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
