import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.n42.android_native_smoke/vectors');

  testWidgets('Android TLS verifier accepts and rejects fixture chains', (
    tester,
  ) async {
    final result = await channel.invokeMapMethod<String, String>(
      'mobileSdkTlsCerts',
    );
    expect(result, isNotNull);
    expect(result!['untrusted'], 'success');
    expect(result['mockChain'], 'success');
  });
}
