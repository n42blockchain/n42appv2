import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/services/egld_transaction_hash.dart';

void main() {
  final fixture = jsonDecode(
    File('test/fixtures/multiversx/transaction_hashes.json').readAsStringSync(),
  ) as Map;
  final vectors = fixture['vectors'] as List;
  for (final row in vectors) {
    test('official SDK hash: ${row['name']}', () {
      expect(
        EgldTransactionHash.compute(jsonEncode(row['transaction'])),
        row['hash'],
      );
    });
  }
  Map<String, dynamic> ordinary() =>
      Map<String, dynamic>.from(vectors.first['transaction'] as Map);
  test('JSON ordering and whitespace do not change the on-chain hash', () {
    final tx = ordinary();
    final reversed = {
      for (final key in tx.keys.toList().reversed) key: tx[key],
    };
    expect(
      EgldTransactionHash.compute(
        const JsonEncoder.withIndent('  ').convert(reversed),
      ),
      vectors.first['hash'],
    );
  });
  test('absent and empty data and zero options have the same encoding', () {
    final tx = ordinary()
      ..['data'] = ''
      ..['options'] = 0;
    expect(EgldTransactionHash.compute(jsonEncode(tx)), vectors.first['hash']);
  });
  final invalid = <String, Map<String, dynamic>>{
    'negative nonce': {'nonce': -1},
    'string nonce': {'nonce': '7'},
    'fraction nonce': {'nonce': 1.5},
    'unsafe JSON number': {'nonce': 9007199254740992},
    'negative amount': {'value': '-1'},
    'leading zero amount': {'value': '01'},
    'numeric amount': {'value': 1},
    'empty amount': {'value': ''},
    'zero gas price': {'gasPrice': 0},
    'zero gas limit': {'gasLimit': 0},
    'missing chain': {'chainID': null},
    'zero version': {'version': 0},
    'overflow version': {'version': 4294967296},
    'invalid signature': {'signature': 'zz' * 64},
    'short signature': {'signature': '00'},
    'numeric data': {'data': 1},
    'bad base64': {'data': '??'},
    'base64url': {'data': '-w=='},
    'unsupported guardian': {'guardian': 'erd1guard'},
    'unsupported relayer': {'relayer': 'erd1relay'},
    'unsupported username': {'senderUsername': 'name'},
    'guarded option': {'options': 2},
    'version one options': {'options': 1},
    'invalid address': {'receiver': 'erd1invalid'},
  };
  for (final entry in invalid.entries) {
    test('reject ${entry.key} without guessing a hash', () {
      final tx = ordinary()..addAll(entry.value);
      expect(
        () => EgldTransactionHash.compute(jsonEncode(tx)),
        throwsA(anything),
      );
    });
  }
  for (final field in [
    'nonce',
    'value',
    'sender',
    'receiver',
    'gasPrice',
    'gasLimit',
    'chainID',
    'version',
    'signature',
  ]) {
    test('reject absent $field', () {
      expect(
        () =>
            EgldTransactionHash.compute(jsonEncode(ordinary()..remove(field))),
        throwsA(anything),
      );
    });
  }
}
