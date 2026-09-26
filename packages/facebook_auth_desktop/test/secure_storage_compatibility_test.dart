import 'package:facebook_auth_desktop/facebook_auth_desktop.dart';
import 'package:facebook_auth_desktop/src/custom_http_client.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth_platform_interface/flutter_facebook_auth_platform_interface.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

class _ProfileClient extends CustomHttpClient {
  @override
  Future<Response> get(Uri url) async =>
      Response('{"id":"public-test-user"}', 200);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('app.meedu/facebook_auth_desktop');

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(
        {'unrelated-chat-key': 'preserve'});
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
      'login stores a token readable by a fresh instance; logout deletes only that token',
      () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            channel,
            (_) async => 'https://www.facebook.com/connect/login_success.html'
                '#access_token=PUBLIC_FAKE_FACEBOOK_TOKEN&expires_in=3600'
                '&granted_scopes=email&denied_scopes=');
    final plugin = FacebookAuthDesktopPlugin(httpClient: _ProfileClient());
    await plugin.webAndDesktopInitialize(
      appId: 'public-test-app',
      cookie: false,
      xfbml: false,
      version: 'v19.0',
    );
    final result = await plugin.login();
    expect(result.status, LoginStatus.success);
    final reopened = FacebookAuthDesktopPlugin(httpClient: _ProfileClient());
    expect((await reopened.accessToken)?.tokenString,
        'PUBLIC_FAKE_FACEBOOK_TOKEN');
    expect(((await reopened.accessToken) as ClassicToken).userId,
        'public-test-user');
    await reopened.logOut();
    expect(await plugin.accessToken, isNull);
    expect(await const FlutterSecureStorage().read(key: 'unrelated-chat-key'),
        'preserve');
  });

  test('cancelled login does not create a token', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => null);
    final plugin = FacebookAuthDesktopPlugin(httpClient: _ProfileClient());
    await plugin.webAndDesktopInitialize(
      appId: 'public-test-app',
      cookie: false,
      xfbml: false,
      version: 'v19.0',
    );
    expect((await plugin.login()).status, LoginStatus.cancelled);
    expect(await plugin.accessToken, isNull);
    expect(await const FlutterSecureStorage().read(key: 'unrelated-chat-key'),
        'preserve');
  });
}
