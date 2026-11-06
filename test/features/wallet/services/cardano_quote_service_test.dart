import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ada_api.dart';
import 'package:n42_wallet/features/wallet/services/cardano_quote_service.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class _Api extends AdaApi {
  _Api() : super(projectId: 'fixture');
  void Function()? afterInputs;
  bool? network;
  @override
  Future<MessageModel> getAddressUtxos(
    String address, {
    bool isTest = false,
  }) async {
    network = isTest;
    afterInputs?.call();
    return MessageModel()
      ..data = [
        for (final token in [false, true])
          {
            'address': address,
            'tx_hash': (token ? 'bb' : 'aa') * 32,
            'output_index': 0,
            'amount': [
              {'unit': 'lovelace', 'quantity': '10000000'},
              if (token) {'unit': 'ab' * 28, 'quantity': '1'},
            ],
          },
      ];
  }

  int blocks = 0;
  @override
  Future<MessageModel> getLatestBlock({bool isTest = false}) async {
    blocks++;
    return MessageModel()..data = {'slot': 100000};
  }
}

class _Bridge extends Trustdart {
  Map<String, dynamic>? input;
  @override
  Future<Map<String, dynamic>> planCardanoTransaction(
    Map<String, dynamic> txData,
  ) async {
    input = txData;
    return {
      'amount': '9800000',
      'fee': '200000',
      'change': '0',
      'available': '10000000',
    };
  }

  @override
  Future<String> signTransaction(
    String coin,
    String path,
    Map txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) async => throw StateError('Quote must never sign');
}

void main() {
  test(
    'quote excludes token inputs and forwards exact public testnet data',
    () async {
      final api = _Api();
      final bridge = _Bridge();
      final result = await CardanoQuoteService(api: api, bridge: bridge).quote(
        sender: 'addr_sender',
        recipient: 'addr_recipient',
        amount: BigInt.zero,
        isTest: true,
        maximum: true,
        isCurrent: () => true,
      );
      expect(result.amount, BigInt.from(9800000));
      expect(api.network, true);
      expect(bridge.input!['amount'], '10000000');
      expect(bridge.input!['utxos'], hasLength(1));
      expect(bridge.input!.keys.toSet(), {
        'utxos',
        'ttl',
        'toAddress',
        'changeAddress',
        'amount',
        'useMaxAmount',
      });
      expect(bridge.input!['toAddress'], 'addr_recipient');
      expect(bridge.input!['changeAddress'], 'addr_sender');
    },
  );
  test('stale input response cannot proceed to native planning', () async {
    var current = true;
    final api = _Api()..afterInputs = () => current = false;
    final bridge = _Bridge();
    await expectLater(
      CardanoQuoteService(api: api, bridge: bridge).quote(
        sender: 'addr_sender',
        recipient: 'addr_recipient',
        amount: BigInt.one,
        isTest: false,
        maximum: false,
        isCurrent: () => current,
      ),
      throwsStateError,
    );
    expect(api.blocks, 0);
    expect(bridge.input, isNull);
  });
}
