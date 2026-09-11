import 'package:reown_walletkit/reown_walletkit.dart' as wc;

wc.SessionData session(
  String topic, {
  bool expired = false,
  List<String> accounts = const ['eip155:1:0xalice'],
}) => wc.SessionData.fromJson({
  'topic': topic,
  'pairingTopic': 'pair-$topic',
  'relay': {'protocol': 'irn'},
  'expiry':
      (expired ? DateTime(2020) : DateTime(2040)).millisecondsSinceEpoch ~/
      1000,
  'acknowledged': true,
  'controller': 'controller',
  'namespaces': {
    'eip155': {
      'accounts': accounts,
      'methods': ['personal_sign'],
      'events': [],
    },
  },
  'self': {
    'publicKey': 'wallet',
    'metadata': {
      'name': 'Wallet',
      'description': '',
      'url': 'https://wallet.example.test',
      'icons': [],
    },
  },
  'peer': {
    'publicKey': 'dapp',
    'metadata': {
      'name': topic,
      'description': '',
      'url': 'https://example.test',
      'icons': [],
    },
  },
});
