import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/on_device_translation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('google_mlkit_on_device_translator');
  final calls = <MethodCall>[];
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'nlp#manageLanguageModelModels') {
            final args = call.arguments as Map;
            if (args['model'] == 'en') {
              throw PlatformException(code: 'built_in_model');
            }
            return true;
          }
          if (call.method == 'nlp#startLanguageTranslator') return 'translated';
          return null;
        });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  for (final pair in [('en', 'zh'), ('zh', 'en')]) {
    test('does not manage built-in English for $pair', () async {
      final result = await OnDeviceTranslationService().translate(
        text: 'sample',
        sourceLanguage: pair.$1,
        targetLanguage: pair.$2,
      );
      expect(result, 'translated');
      final modelCalls = calls.where(
        (c) => c.method == 'nlp#manageLanguageModelModels',
      );
      expect(modelCalls, isNotEmpty);
      expect(
        modelCalls.every((c) => (c.arguments as Map)['model'] == 'zh'),
        isTrue,
      );
      expect(calls.last.method, 'nlp#closeLanguageTranslator');
    });
  }
}
