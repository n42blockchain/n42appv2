import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/services/voip/call_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> callkitCalls = <MethodCall>[];

  setUp(() {
    callkitCalls.clear();
    SharedPreferences.setMockInitialValues({});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_callkit_incoming'),
      (MethodCall methodCall) async {
        callkitCalls.add(methodCall);
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_callkit_incoming'),
      null,
    );
  });

  test('showIncomingCall uses stored ringtone preference for CallKit params', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'n42_chat_incoming_call_ringtone':
          '{"mode":"silent","label":"Silent","sourceKey":"silent"}',
    });

    await CallNotificationService().showIncomingCall(
      callerId: '@alice:matrix.org',
      callerName: 'Alice',
    );

    expect(callkitCalls, isNotEmpty);
    final args = callkitCalls.first.arguments as Map<dynamic, dynamic>;
    final android = args['android'] as Map<dynamic, dynamic>;
    final ios = args['ios'] as Map<dynamic, dynamic>;

    expect(callkitCalls.first.method, 'showCallkitIncoming');
    expect(android['ringtonePath'], 'silent');
    expect(ios['ringtonePath'], 'system_ringtone_default');
  });
}
