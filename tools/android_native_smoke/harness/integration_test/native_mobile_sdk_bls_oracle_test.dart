import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.n42.android_native_smoke/vectors');

  testWidgets('MobileSdk BLS keypair signs and verifies offline', (
    tester,
  ) async {
    expect(await channel.invokeMethod<bool>('mobileSdkBlsPair'), isTrue);
  });
}
