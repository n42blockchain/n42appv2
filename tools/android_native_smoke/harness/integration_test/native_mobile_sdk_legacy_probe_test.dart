import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.n42.android_native_smoke/vectors');

  testWidgets('Legacy packaged MobileSdk synthetic transaction fields', (
    tester,
  ) async {
    final raw = await channel.invokeMapMethod<String, String>(
      'mobileSdkVectors',
    );
    expect(raw, isNotNull);
    // These are unsigned transactions using only hard-coded public fixture inputs.
    print('LEGACY_VECTOR_JSON:${jsonEncode(raw)}');
  });
}
