import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('CocoaPods Firebase12.19.0 initializes with collection disabled', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final app = await Firebase.initializeApp(
        options: const FirebaseOptions(
          // Valid format only; this all-zero value is not a Firebase credential.
          apiKey: 'A00000000000000000000000000000000000000',
          appId: '1:123456789:ios:1234567890abcdef',
          messagingSenderId: '123456789',
          projectId: 'n42-isolated-native-fixture',
        ),
      );
      expect(app.options.projectId, 'n42-isolated-native-fixture');
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
      await FirebaseAnalytics.instance.logEvent(name: 'isolated_probe');
      await FirebaseAnalytics.instance.resetAnalyticsData();
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      expect(
        FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled,
        false,
      );
      expect(
        await FirebaseCrashlytics.instance.didCrashOnPreviousExecution(),
        false,
      );
      await FirebaseMessaging.instance.setAutoInitEnabled(false);
      expect(FirebaseMessaging.instance.isAutoInitEnabled, false);
      // FlutterFire forbids deleting the default app. The isolated fixture
      // container is removed after acceptance; it contains no production data.
    });
  });
}
