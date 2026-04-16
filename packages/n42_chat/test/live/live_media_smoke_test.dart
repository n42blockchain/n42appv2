import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/live_media_smoke.dart' as smoke;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final hasInviteCode =
      Platform.environment['N42_TEST_INVITE_CODE']?.trim().isNotEmpty == true;
  final hasReusableAccount =
      Platform.environment['N42_TEST_USERNAME']?.trim().isNotEmpty == true &&
      Platform.environment['N42_TEST_PASSWORD']?.trim().isNotEmpty == true;

  test(
    'live homeserver media smoke',
    () async {
      await HttpOverrides.runWithHttpOverrides(
        () => smoke.runLiveMediaSmoke(),
        _PassthroughHttpOverrides(),
      );
    },
    timeout: const Timeout(Duration(minutes: 3)),
    skip: hasInviteCode || hasReusableAccount
        ? false
        : 'Requires N42_TEST_INVITE_CODE or N42_TEST_USERNAME/N42_TEST_PASSWORD',
  );
}

class _PassthroughHttpOverrides extends HttpOverrides {
  @override
  // ignore: unnecessary_overrides
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context);
  }
}
