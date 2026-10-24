import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/generated/l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('RPC never follows a redirect to another provider', () async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = null;
    addTearDown(() => HttpOverrides.global = previous);
    await S.load(const Locale('en'));
    final target = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final source = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => target.close(force: true));
    addTearDown(() => source.close(force: true));
    var received = 0;
    target.listen((request) async {
      received++;
      request.response.write('{}');
      await request.response.close();
    });
    source.listen((request) async {
      await request.drain<void>();
      request.response.statusCode = 307;
      request.response.headers.set(
        'location',
        'http://127.0.0.1:${target.port}',
      );
      await request.response.close();
    });
    final response = await EthAPI.init(
      null,
      'http://127.0.0.1:${source.port}',
      null,
    ).baseRPCEth('eth_chainId', [], enableRetry: false);
    expect(response.isFailure, isTrue);
    expect(received, 0);
  });
}
