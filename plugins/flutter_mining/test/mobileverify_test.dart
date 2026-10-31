import 'package:flutter/services.dart';
import 'package:flutter_mining/mobileverify.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('n42/mobileverify');
  final api = MethodChannelMobileVerify();
  final calls = <MethodCall>[];

  // Answers as evmsdk.MobileVerifySession does: JSON strings.
  final answers = <String, Object?>{
    'open': 'ab' * 48,
    'register': '{"index":7,"committed":true}',
    'latest': '{"number":42,"hash":"0x42","packet":true}',
    'verifyBlock':
        '{"blockNumber":42,"blockHash":"0x42","receiptsRoot":"0xr","txs":3,"index":7,"elapsedMs":120}',
    'cert':
        '[{"blockNumber":42,"receiptsRoot":"0xr","signers":5,"aggregateSig":"00"}]',
    'health': '{"registry":12}',
    'close': null,
  };

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return answers[call.method];
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('passes the arguments the native handler reads', () async {
    await api.open(
      baseUrl: 'http://10.0.2.2:21012',
      privHex: 'aa',
      chain: 'mainnet_qmdb_staggered',
    );
    await api.verifyBlock('0x42');
    await api.cert('0x42');
    expect(calls[0].arguments, {
      'baseUrl': 'http://10.0.2.2:21012',
      'privHex': 'aa',
      'chain': 'mainnet_qmdb_staggered',
    });
    expect(calls[1].arguments, {'blockHash': '0x42'});
    expect(calls[2].arguments, {'blockHash': '0x42'});
  });

  test('decodes the session JSON', () async {
    final reg = await api.register();
    expect([reg.index, reg.committed], [7, true]);
    final head = await api.latest();
    expect([head.number, head.hash, head.packet], [42, '0x42', true]);
    final v = await api.verifyBlock('0x42');
    expect(
      [v.blockNumber, v.receiptsRoot, v.txs, v.index, v.elapsedMs],
      [42, '0xr', 3, 7, 120],
    );
    final certs = await api.cert('0x42');
    expect(certs.single.signers, 5);
    expect((await api.health())['registry'], 12);
  });

  test('an empty certificate list is no certificate yet', () async {
    answers['cert'] = '[]';
    expect(await api.cert('0x42'), isEmpty);
  });

  test('a native failure surfaces as a PlatformException', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(
            code: 'MobileVerify',
            message: 'server 404: packet not in window',
          );
        });
    expect(api.verifyBlock('0x42'), throwsA(isA<PlatformException>()));
  });
}
