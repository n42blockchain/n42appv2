import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:n42_wallet/features/payments/data/local_payment_client.dart';

/// Requires Python 3, also used by this repository's CI quality gate.
/// Uses a temporary SQLite database, ephemeral port, and synthetic accounts.
void main() {
  test(
    'Dart client and Python ledger complete a local payment lifecycle',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'n42-payment-protocol-',
      );
      final server = await Process.start('python3', [
        '-u',
        '-c',
        '''
import sys, threading
sys.path.insert(0, 'backend/payment-sandbox')
from sandbox import Sandbox
from server import LocalPaymentServer
s = Sandbox(sys.argv[1], mode='localSimulation', assets=['test-usdc'])
s.seed_test_funds('a', 'test-usdc', 100, key='seed')
s.set_test_members('room', ['a','b','c'])
clock = [1]
server = LocalPaymentServer(s, mode='localSimulation', tokens={
 'synthetic-test-accounta':'a', 'synthetic-test-accountb':'b', 'synthetic-test-accountc':'c'}, clock=lambda:clock[0])
threading.Thread(target=server.serve_forever, daemon=True).start()
print(server.server_port, flush=True)
for line in sys.stdin:
 if line.strip() == 'expire':
  clock[0] = 100
  print('expired', flush=True)
 else:
  break
server.shutdown()
server.server_close()
''',
        '${directory.path}/ledger.sqlite',
      ]);
      final output = StreamIterator(
        server.stdout.transform(utf8.decoder).transform(const LineSplitter()),
      );
      // Drain stderr without retaining request content or credentials.
      final errors = server.stderr.drain<void>();
      final transport = http.Client();
      addTearDown(() async {
        transport.close();
        await output.cancel();
        server.kill();
        await server.exitCode.timeout(const Duration(seconds: 5));
        await errors;
        await directory.delete(recursive: true);
      });
      expect(
        await output.moveNext().timeout(const Duration(seconds: 5)),
        isTrue,
      );
      final port = int.parse(output.current);
      final client = LocalPaymentClient(
        endpoint: Uri.parse('http://127.0.0.1:$port'),
        transport: transport,
        enabled: true,
      )..activateTestAccount('synthetic-test-accounta');
      expect(await client.balance('test-usdc'), BigInt.from(100));
      final first = await client.transfer(
        recipient: 'b',
        asset: 'test-usdc',
        amount: BigInt.from(10),
        key: '..',
      );
      final replay = await client.transfer(
        recipient: 'b',
        asset: 'test-usdc',
        amount: BigInt.from(10),
        key: '..',
      );
      expect(replay, first);
      expect((await client.recoverRequest('..')).receipt, first);
      expect(await client.operation(first['id'] as String), first);
      final packet = await client.createPacket(
        room: 'room',
        asset: 'test-usdc',
        total: BigInt.from(60),
        slots: 3,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(100000),
        key: 'packet-one',
      );
      expect(await client.balance('test-usdc'), BigInt.from(30));
      client.activateTestAccount('synthetic-test-accountb');
      await expectLater(
        client.operation(first['id'] as String),
        throwsA(
          isA<LocalPaymentException>().having(
            (e) => e.code,
            'code',
            'not_found',
          ),
        ),
      );
      final claim = await client.claim(
        packet['id'] as String,
        key: 'claim-one',
      );
      expect(claim['amount'], '20');
      expect(await client.balance('test-usdc'), BigInt.from(30));
      expect(
        await client.claim(packet['id'] as String, key: 'claim-one'),
        claim,
      );
      server.stdin.writeln('expire');
      await server.stdin.flush();
      expect(
        await output.moveNext().timeout(const Duration(seconds: 5)),
        isTrue,
      );
      expect(output.current, 'expired');
      client.activateTestAccount('synthetic-test-accounta');
      final refund = await client.refund(
        packet['id'] as String,
        key: 'refund-one',
      );
      expect(refund['amount'], '40');
      expect(await client.balance('test-usdc'), BigInt.from(70));
      expect(
        await client.refund(packet['id'] as String, key: 'refund-one'),
        refund,
      );
      final designated = await client.createPacket(
        room: 'room',
        asset: 'test-usdc',
        total: BigInt.from(15),
        slots: 1,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(200000),
        key: 'designated',
        recipient: 'b',
      );
      expect(designated['recipient'], 'b');
      expect((await client.recoverRequest('designated')).receipt, designated);
      await expectLater(
        client.createPacket(
          room: 'room',
          asset: 'test-usdc',
          total: BigInt.from(15),
          slots: 1,
          expiresAt: DateTime.fromMillisecondsSinceEpoch(200000),
          key: 'designated',
          recipient: 'c',
        ),
        throwsA(
          isA<LocalPaymentException>().having(
            (e) => e.code,
            'code',
            'conflict',
          ),
        ),
      );
      for (final token in [
        'synthetic-test-accounta',
        'synthetic-test-accountc',
      ]) {
        client.activateTestAccount(token);
        await expectLater(
          client.claim(designated['id'] as String, key: 'designated-claim'),
          throwsA(
            isA<LocalPaymentException>().having(
              (e) => e.code,
              'code',
              'conflict',
            ),
          ),
        );
      }
      client.activateTestAccount('synthetic-test-accountb');
      final designatedClaim = await client.claim(
        designated['id'] as String,
        key: 'designated-claim',
      );
      expect(designatedClaim['amount'], '15');
      expect(
        await client.claim(designated['id'] as String, key: 'designated-claim'),
        designatedClaim,
      );
      expect(await client.balance('test-usdc'), BigInt.from(45));
      client.activateTestAccount('synthetic-test-accounta');
      expect(await client.balance('test-usdc'), BigInt.from(55));
      client.close();
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
