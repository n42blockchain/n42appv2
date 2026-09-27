import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as flutter_vodozemac;
import 'package:integration_test/integration_test.dart';
import 'package:vodozemac/vodozemac.dart' as vodozemac;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android native Vodo preserves synthetic crypto records', (
    tester,
  ) async {
    await tester.runAsync(() async {
      const releaseProbe = bool.fromEnvironment('N42_VODO_RELEASE_PROBE');
      final stem = releaseProbe
          ? 'vodozemac_release_probe'
          : 'vodozemac_bindings_dart';
      if (releaseProbe) {
        await vodozemac.init(stem: stem);
      } else {
        await flutter_vodozemac.init();
      }
      expect(vodozemac.isInitialized(), isTrue);

      // Resolve a real FRB entry point and locate its executable mapping.
      // This binds the following crypto calls to this process's native image.
      final entry = DynamicLibrary.open('lib$stem.so')
          .lookup<NativeFunction<Void Function()>>(
            'frbgen_vodozemac_wire__crate__bindings__vodozemac_account_ed25519_key',
          )
          .address;
      final mapped = File('/proc/self/maps')
          .readAsLinesSync()
          .singleWhere((line) {
            final fields = line.split(RegExp(r'\s+'));
            if (fields.length < 6 || !fields[1].contains('x')) return false;
            final range = fields[0].split('-');
            final start = int.parse(range[0], radix: 16);
            final end = int.parse(range[1], radix: 16);
            return start <= entry && entry < end;
          });
      expect(mapped, anyOf(contains('lib$stem.so'), contains('base.apk')));
      final installedApk = mapped.split(RegExp(r'\s+')).last;
      final installedHash = await sha256
          .bind(File(installedApk).openRead())
          .first;
      print(
        'VODO_INSTALLED_APK variant=${releaseProbe ? 'release' : 'debug'} '
        'pid=$pid sha256=$installedHash path=$installedApk',
      );
      print(
        'VODO_NATIVE_MAP variant=${releaseProbe ? 'release' : 'debug'} '
        'pid=$pid symbol=account_ed25519_key map=$mapped',
      );

      final legacy = jsonDecode(
        await rootBundle.loadString('fixtures/vodozemac-0.5-pickles.json'),
      ) as Map<String, dynamic>;
      final key = base64Decode(legacy['public_pickle_key_base64'] as String);
      expect(key.length, 32);
      final account = vodozemac.Account.fromPickleEncrypted(
        pickle: legacy['account_pickle'] as String,
        pickleKey: key,
      );
      expect(account.ed25519Key.toBase64(), legacy['account_ed25519']);
      expect(account.curve25519Key.toBase64(), legacy['account_curve25519']);
      account.ed25519Key.verify(
        message: legacy['plaintext'] as String,
        signature: vodozemac.Ed25519Signature.fromBase64(
          legacy['signature'] as String,
        ),
      );
      expect(
        account.sign(legacy['plaintext'] as String).toBase64(),
        legacy['signature'],
      );

      final inbound = vodozemac.InboundGroupSession.fromPickleEncrypted(
        pickle: legacy['inbound_pickle'] as String,
        pickleKey: key,
      );
      final outbound = vodozemac.GroupSession.fromPickleEncrypted(
        pickle: legacy['outbound_pickle'] as String,
        pickleKey: key,
      );
      expect(inbound.sessionId, legacy['session_id']);
      expect(outbound.sessionId, legacy['session_id']);
      expect(
        inbound.decrypt(legacy['ciphertext'] as String).plaintext,
        legacy['plaintext'],
      );
      expect(
        inbound.decrypt(outbound.encrypt('continued after upgrade')).plaintext,
        'continued after upgrade',
      );

      expect(
        () => vodozemac.Account.fromPickleEncrypted(
          pickle: legacy['account_pickle'] as String,
          pickleKey: Uint8List(32),
        ),
        throwsA(anything),
      );
      expect(
        () => vodozemac.InboundGroupSession.fromPickleEncrypted(
          pickle: legacy['inbound_pickle'] as String,
          pickleKey: Uint8List(32),
        ),
        throwsA(anything),
      );

      final freshSender = vodozemac.GroupSession();
      final freshReceiver = freshSender.toInbound();
      final ciphertext = freshSender.encrypt('fresh native message');
      expect(
        freshReceiver.decrypt(ciphertext).plaintext,
        'fresh native message',
      );
      final freshKey = Uint8List.fromList(List.filled(32, 7));
      final restored = vodozemac.InboundGroupSession.fromPickleEncrypted(
        pickle: freshReceiver.toPickleEncrypted(freshKey),
        pickleKey: freshKey,
      );
      expect(restored.decrypt(ciphertext).plaintext, 'fresh native message');
      expect(
        () => vodozemac.InboundGroupSession.fromPickleEncrypted(
          pickle: freshReceiver.toPickleEncrypted(freshKey),
          pickleKey: Uint8List(32),
        ),
        throwsA(anything),
      );
      print(
        'VODO_CRYPTO_PASS legacy_account=true legacy_sessions=true fresh=true',
      );
    });
  });
}
