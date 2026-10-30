import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_url_registry.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/api/sender/sender_factory.dart';

void main() {
  test('export configured networks separately from production support claims', () {
    final rows =
        allChainUrlMap.entries.map((e) {
            final config = e.value as Map;
            final base = config['baseInfo'] as Map? ?? config;
            return {
              'key': e.key,
              'name': base['name'],
              'family': base['blockchainType'],
              'defaultWalletEntry': chainUrlMap.containsKey(e.key),
              'senderExists': SenderFactory.instance.supportsTransfers(e.key),
              'classification': SenderFactory.instance.supportsTransfers(e.key)
                  ? 'send_receive_code_only'
                  : 'catalog_only_unverified',
              'iosProductionVersion': null,
              'androidProductionVersion': null,
              'mainnetAcceptance': null,
            };
          }).toList()
          ..sort((a, b) => (a['key'] as String).compareTo(b['key'] as String));
    expect(rows, isNotEmpty);
    expect(rows.map((r) => r['key']).toSet().length, rows.length);
    final output = Platform.environment['N42_CHAIN_EVIDENCE_OUTPUT'];
    if (output != null) {
      File(output).writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert({'scope': 'static configuration and sender dispatch; not supported-chain acceptance', 'configuredCount': rows.length, 'senderCount': rows.where((r) => r['senderExists'] == true).length, 'defaultWalletCount': chainUrlMap.length, 'networks': rows})}\n',
      );
    }
  });
}
