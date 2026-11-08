import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/browser/js/ethereum_provider.dart';

// Execute the shipped JavaScript rather than inspecting its source spelling.
Future<Map<String, dynamic>> _discover(String source) async {
  final runner =
      '''
const vm = require('node:vm');
const events = [];
const listeners = {};
const window = {
  dispatchEvent(event) {
    if (event.type === 'eip6963:announceProvider') events.push(event.detail);
    for (const listener of listeners[event.type] || []) listener(event);
  },
  addEventListener(type, listener) {
    (listeners[type] || (listeners[type] = [])).push(listener);
  }
};
class Event { constructor(type, options = {}) { this.type = type; Object.assign(this, options); } }
const context = vm.createContext({window, Event, CustomEvent: Event, setTimeout: fn => fn()});
const source = ${jsonEncode(source)};
vm.runInContext(source, context);
vm.runInContext(source, context);
window.dispatchEvent(new Event('eip6963:requestProvider'));
console.log(JSON.stringify({
  infos: events.map(event => event.info),
  frozen: events.every(event => Object.isFrozen(event) && Object.isFrozen(event.info)),
  sameProvider: events.every(event => event.provider === window.ethereum),
  legacyProvider: window.web3.currentProvider === window.ethereum
}));
''';
  final result = await Process.run('node', ['-e', runner]);
  expect(result.exitCode, 0, reason: '${result.stderr}');
  return jsonDecode(result.stdout as String) as Map<String, dynamic>;
}

void main() {
  test(
    'wallet_watchAsset forwards object and array requests before recognition',
    () async {
      final source = EthereumProviderJs.buildProviderScript('0x1', []);
      final runner =
          '''
const vm = require('node:vm');
const messages = [];
const window = {
  dispatchEvent() {}, addEventListener() {},
  N42Wallet: {postMessage(raw) { messages.push(JSON.parse(raw)); }}
};
class Event { constructor(type, options = {}) { this.type = type; Object.assign(this, options); } }
const context = vm.createContext({window, N42Wallet: window.N42Wallet, Event, CustomEvent: Event, setTimeout: fn => fn()});
vm.runInContext(${jsonEncode(source)}, context);
(async () => {
  const asset = {type:'ERC20',options:{address:'0x52908400098527886E0F7030069857D2E4169EE7'}};
  let resolved = false;
  const objectRequest = window.ethereum.request({method:'wallet_watchAsset',params:asset}).then(value => {resolved = true; return value;});
  await Promise.resolve();
  const resolvedBeforeNative = resolved;
  window.ethereum._n42Cb(messages[0].id, 'true', null);
  const first = await objectRequest;
  const arrayRequest = window.ethereum.request({method:'wallet_watchAsset',params:[asset]});
  window.ethereum._n42Cb(messages[1].id, null, JSON.stringify({code:-32602,message:'invalid'}));
  let error;
  try {await arrayRequest;} catch (e) {error=e.code;}
  console.log(JSON.stringify({messages,resolvedBeforeNative,first,error}));
})().catch(error => {console.error(error);process.exitCode=1;});
''';
      final result = await Process.run('node', ['-e', runner]);
      expect(result.exitCode, 0, reason: '${result.stderr}');
      final decoded = jsonDecode(result.stdout as String) as Map;
      expect(decoded['resolvedBeforeNative'], isFalse);
      expect(decoded['first'], isTrue);
      expect(decoded['error'], -32602);
      final messages = decoded['messages'] as List;
      expect(messages, hasLength(2));
      expect(messages[0]['params'], messages[1]['params']);
      expect(messages[0]['params'], isA<List>());
    },
  );

  final uuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  test('EIP-6963 discovery has a valid stable session identity', () async {
    final result = await _discover(
      EthereumProviderJs.buildProviderScript('0x1', []),
    );
    final infos = (result['infos'] as List).cast<Map<String, dynamic>>();
    expect(infos, hasLength(2));
    expect(infos.first['uuid'], matches(uuidV4));
    expect(infos.last, infos.first);
    expect(infos.first['name'], 'N42 Wallet');
    expect(infos.first['rdns'], 'ai.n42.wallet');
    expect(infos.first['icon'], startsWith('data:image/'));
    expect(result['frozen'], isTrue);
    expect(result['sameProvider'], isTrue);
    expect(result['legacyProvider'], isTrue);
  });

  test(
    'independent provider generations have distinct discovery identities',
    () async {
      final first = await _discover(
        EthereumProviderJs.buildProviderScript('0x1', []),
      );
      final second = await _discover(
        EthereumProviderJs.buildProviderScript('0x1', []),
      );
      final firstId = ((first['infos'] as List).first as Map)['uuid'];
      final secondId = ((second['infos'] as List).first as Map)['uuid'];
      expect(firstId, isNot(secondId));
    },
  );
}
