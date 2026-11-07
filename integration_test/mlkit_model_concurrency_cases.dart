// Run only on a fresh disposable install; downloads synthetic test models.
// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

void registerConcurrentModelTest() {
  testWidgets(
    'native plugin keeps both concurrent model downloads alive',
    (tester) async {
      final manager = OnDeviceTranslatorModelManager();
      const languages = ['es', 'fr'];
      for (final language in languages) {
        expect(
          await manager.isModelDownloaded(language),
          isFalse,
          reason: 'Use a fresh disposable installation for this test.',
        );
      }
      try {
        final pending = Future.wait(
          languages.map(
            (language) =>
                manager.downloadModel(language, isWifiRequired: false),
          ),
        );
        // Status polling must preserve both pending request owners.
        expect(await manager.isModelDownloaded('de'), isFalse);
        final results = await pending.timeout(const Duration(seconds: 90));
        expect(results, [true, true]);
        for (final language in languages) {
          expect(await manager.isModelDownloaded(language), isTrue);
        }
      } finally {
        for (final language in languages) {
          expect(
            await manager
                .deleteModel(language)
                .timeout(const Duration(seconds: 10)),
            isTrue,
          );
        }
      }
    },
    skip: !const bool.fromEnvironment('N42_MLKIT_DOWNLOAD_MODEL'),
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
