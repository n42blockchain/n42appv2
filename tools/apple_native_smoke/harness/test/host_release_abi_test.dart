import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:vodozemac/src/generated/frb_generated.dart';
import 'package:matrix/encryption/utils/pickle_key.dart';
import 'package:vodozemac/vodozemac.dart' as crypto;

void main() {
  test('actual host release framework restores legacy native crypto', () async {
    final path = Platform.environment['N42_APPLE_FRAMEWORKS'];
    expect(
      path,
      isNotNull,
      reason: 'Set the final app Contents/Frameworks path',
    );
    expect(
      File('$path/flutter_vodozemac.framework/flutter_vodozemac').existsSync(),
      isTrue,
    );
    await RustLib.init(
      externalLibrary: ExternalLibrary.open(
        '$path/flutter_vodozemac.framework/flutter_vodozemac',
      ),
    );
    final legacy = jsonDecode(
      File('fixtures/vodozemac-0.5-pickles.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final key = (legacy['user_id'] as String).toPickleKey();
    final account = crypto.Account.fromPickleEncrypted(
      pickle: legacy['account_pickle'] as String,
      pickleKey: key,
    );
    expect(account.ed25519Key.toBase64(), legacy['account_ed25519']);
    final inbound = crypto.InboundGroupSession.fromPickleEncrypted(
      pickle: legacy['inbound_pickle'] as String,
      pickleKey: key,
    );
    expect(
      inbound.decrypt(legacy['ciphertext'] as String).plaintext,
      legacy['plaintext'],
    );
    final outbound = crypto.GroupSession.fromPickleEncrypted(
      pickle: legacy['outbound_pickle'] as String,
      pickleKey: key,
    );
    expect(
      inbound.decrypt(outbound.encrypt('host release binary')).plaintext,
      'host release binary',
    );
  });
}
