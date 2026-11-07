import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fast_base58/fast_base58.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/near_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/near_transaction_hash.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/near_sender.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

final signedFixture =
    (jsonDecode(File('test/native/near_reference.json').readAsStringSync())
            as Map)['signedTransaction']
        as String;
final fixtureHash = nearSignedTransactionHash(signedFixture);

MessageModel ok(dynamic value) => MessageModel()..data = value;

class Api extends NearApi {
  int sends = 0;
  BigInt reserve = BigInt.zero;
  bool balanceError = false;
  Object nonce = 3;
  Object permission = 'FullAccess';
  String block = Base58Encode(List.filled(32, 2));
  bool keyError = false;
  String? queriedKey;
  String? hash = fixtureHash;
  bool sendError = false;
  bool sendThrows = false;
  VoidCallback? onSend;
  VoidCallback? onBalance;
  VoidCallback? onKey;
  Completer<void>? gate;
  @override
  Future<MessageModel> getTransferBalance(String accountId) async {
    onBalance?.call();
    if (gate != null) await gate!.future;
    return balanceError
        ? MessageModel.error()
        : ok({'balance': BigInt.from(10).pow(26), 'storageReserve': reserve});
  }

  @override
  Future<MessageModel> getGasPrice() async => ok(BigInt.one);
  @override
  Future<MessageModel> getLatestBlockHash() async => ok({'hash': block});
  @override
  Future<MessageModel> getAccessKey(String accountId, String publicKey) async {
    queriedKey = publicKey;
    onKey?.call();
    return keyError
        ? MessageModel.error()
        : ok({'nonce': nonce, 'permission': permission});
  }

  @override
  Future<MessageModel> sendTransaction(String signedTxBase64) async {
    sends++;
    onSend?.call();
    if (sendThrows) throw StateError('lost response');
    return sendError ? MessageModel.error() : ok(hash);
  }
}

class Signer extends Trustdart {
  int signs = 0;
  Map? payload;
  String address = List.filled(32, '01').join();
  VoidCallback? onSign;
  String signed = signedFixture;
  final credentials = <(String, String)>[];
  @override
  Future<Map> generateAddress(
    String coin,
    String path,
    String addressType, {
    String mnemonic = '',
    String passphrase = '',
    String pk = '',
    bool isImport = false,
    bool isTest = false,
  }) async {
    credentials.add((mnemonic, pk));
    return {'legacy': address};
  }

  @override
  Future<String> signTransaction(
    String coin,
    String path,
    Map txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) async {
    signs++;
    credentials.add((mnemonic, pk));
    payload = Map.of(txData);
    onSign?.call();
    return signed;
  }
}

SendParams params({
  String? key = 'fixture-key',
  BigInt? exact,
  bool max = false,
  Future<void> Function(String)? beforeBroadcast,
  Future<void> Function(String)? onBroadcastStarting,
}) => SendParams(
  sendMax: max,
  beforeBroadcast: beforeBroadcast,
  onBroadcastStarting: onBroadcastStarting,
  coinType: 'NEAR',
  fromAddress: 'alice.near',
  toAddress: 'bob.near',
  amount: 1,
  decimals: 24,
  path: "m/44'/397'/0'",
  privateKey: key,
  isTest: true,
  valueWeiOverride: exact,
);
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => S.load(const Locale('en')));
  test('preparation and dispatch are awaited before the only send', () async {
    final api = Api();
    final events = <String>[];
    final gate = Completer<void>();
    api.onSend = () => events.add('send');
    final result = NearSender(trustdart: Signer(), apiFactory: (_) => api).send(
      params(
        beforeBroadcast: (hash) async {
          expect(hash, fixtureHash);
          events.add('prepare');
          await gate.future;
        },
        onBroadcastStarting: (hash) async {
          expect(hash, fixtureHash);
          events.add('dispatch');
        },
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(events, ['prepare']);
    expect(api.sends, 0);
    gate.complete();
    expect((await result).success, isTrue);
    expect(events, ['prepare', 'dispatch', 'send']);
  });
  for (final stage in ['prepare', 'dispatch']) {
    for (final changeOwner in [false, true]) {
      test(
        '$stage failure or account change $changeOwner never broadcasts',
        () async {
          final api = Api();
          var owner = 'original';
          Future<void> stop(String hash) async {
            if (changeOwner) {
              owner = 'other';
            } else {
              throw StateError('storage failed');
            }
          }

          final result =
              await NearSender(
                trustdart: Signer(),
                apiFactory: (_) => api,
                ownerIdentity: () => owner,
              ).send(
                params(
                  beforeBroadcast: stage == 'prepare' ? stop : null,
                  onBroadcastStarting: stage == 'dispatch' ? stop : null,
                ),
              );
          expect(result.definitelyNotSubmitted, isTrue);
          expect(result.txHash, fixtureHash);
          expect(api.sends, 0);
        },
      );
    }
  }
  for (final mode in ['throw', 'error', 'missing', 'different']) {
    test('$mode receipt preserves local hash and unknown outcome', () async {
      final api = Api()
        ..sendThrows = mode == 'throw'
        ..sendError = mode == 'error';
      if (mode == 'missing') api.hash = null;
      if (mode == 'different') api.hash = Base58Encode(List.filled(32, 9));
      final result = await NearSender(
        trustdart: Signer(),
        apiFactory: (_) => api,
      ).send(params());
      expect(result.success, isFalse);
      expect(result.definitelyNotSubmitted, isFalse);
      expect(result.txHash, fixtureHash);
      expect(result.actualAmount, 1);
      expect(api.sends, 1);
    });
  }
  test('malformed native output never prepares or broadcasts', () async {
    final api = Api();
    var prepared = false;
    final result =
        await NearSender(
          trustdart: Signer()..signed = 'AQID',
          apiFactory: (_) => api,
        ).send(
          params(
            beforeBroadcast: (_) async {
              prepared = true;
            },
          ),
        );
    expect(result.success, isFalse);
    expect(result.txHash, isNull);
    expect(prepared, isFalse);
    expect(api.sends, 0);
  });
  test('native payload uses signer fields and binary encodings', () async {
    final api = Api();
    final signer = Signer();
    final sender = NearSender(
      trustdart: signer,
      apiFactory: (test) {
        expect(test, isTrue);
        return api;
      },
    );
    await sender.send(params());
    expect(signer.payload?['signerId'], 'alice.near');
    expect(signer.payload?['receiverId'], 'bob.near');
    expect(signer.payload?['nonce'], '4');
    expect(signer.payload?['amount'], '000000a1edccce1bc2d3000000000000');
    expect(signer.payload?['blockHash'], List.filled(32, '02').join());
    expect(api.queriedKey, 'ed25519:${Base58Encode(List.filled(32, 1))}');
    expect(api.sends, 1);
  });
  test('failed access key lookup never signs or broadcasts', () async {
    final api = Api()..keyError = true;
    final signer = Signer();
    await NearSender(trustdart: signer, apiFactory: (_) => api).send(params());
    expect(signer.signs, 0);
    expect(api.sends, 0);
  });
  for (final stage in ['balance', 'access', 'sign']) {
    test('account switch during $stage blocks submission', () async {
      final api = Api();
      final signer = Signer();
      var owner = 'alice';
      void change() {
        owner = 'other';
      }

      if (stage == 'balance') api.onBalance = change;
      if (stage == 'access') api.onKey = change;
      if (stage == 'sign') signer.onSign = change;
      final sender = NearSender(
        trustdart: signer,
        apiFactory: (_) => api,
        ownerIdentity: () => owner,
        readCredentials: () => ('seed', ''),
      );
      await sender.send(params(key: null));
      expect(signer.signs, stage == 'sign' ? 1 : 0);
      expect(api.sends, 0);
      expect(signer.credentials.every((c) => c == ('seed', '')), isTrue);
    });
  }
  test('changed credentials with same owner block submission', () async {
    final api = Api();
    final signer = Signer();
    var seed = 'original';
    api.onBalance = () {
      seed = 'replacement';
    };
    await NearSender(
      trustdart: signer,
      apiFactory: (_) => api,
      ownerIdentity: () => 'owner',
      readCredentials: () => (seed, ''),
    ).send(params(key: null));
    expect(signer.signs, 0);
    expect(api.sends, 0);
  });
  test(
    'captured private-key wallet uses same key for derivation and signing',
    () async {
      final api = Api();
      final signer = Signer();
      await NearSender(
        trustdart: signer,
        apiFactory: (_) => api,
        ownerIdentity: () => 'owner',
        readCredentials: () => ('', 'stored-key'),
      ).send(params(key: null));
      expect(signer.credentials, [('', 'stored-key'), ('', 'stored-key')]);
      expect(api.sends, 1);
    },
  );
  for (final nonce in [-1, 1.5, '1.0', '9223372036854775807', 'invalid']) {
    test('invalid native nonce $nonce never signs', () async {
      final api = Api()..nonce = nonce;
      final signer = Signer();
      await NearSender(
        trustdart: signer,
        apiFactory: (_) => api,
      ).send(params());
      expect(signer.signs, 0);
      expect(api.sends, 0);
    });
  }
  test('function-call key cannot authorize native transfer', () async {
    final api = Api()..permission = {'FunctionCall': {}};
    final signer = Signer();
    await NearSender(trustdart: signer, apiFactory: (_) => api).send(params());
    expect(signer.signs, 0);
    expect(api.sends, 0);
  });
  test('exact base units survive native hex encoding', () async {
    final api = Api();
    final signer = Signer();
    final value = BigInt.parse('1000000000000000000000001');
    await NearSender(
      trustdart: signer,
      apiFactory: (_) => api,
    ).send(params(exact: value));
    expect(
      BigInt.parse(
        RegExp(r'..')
            .allMatches(signer.payload!['amount'] as String)
            .map((m) => m.group(0)!)
            .toList()
            .reversed
            .join(),
        radix: 16,
      ),
      value,
    );
    expect(api.sends, 1);
  });
  test('invalid block hash never reaches native signing', () async {
    final api = Api()..block = 'bad';
    final signer = Signer();
    await NearSender(trustdart: signer, apiFactory: (_) => api).send(params());
    expect(signer.signs, 0);
    expect(api.sends, 0);
  });
  test('invalid derived key never signs', () async {
    final api = Api();
    final signer = Signer()..address = 'alice.near';
    await NearSender(trustdart: signer, apiFactory: (_) => api).send(params());
    expect(signer.signs, 0);
    expect(api.sends, 0);
  });
  test('overlapping sends do not broadcast twice', () async {
    final api = Api()..gate = Completer<void>();
    final signer = Signer();
    final sender = NearSender(trustdart: signer, apiFactory: (_) => api);
    final first = sender.send(params());
    await Future<void>.delayed(Duration.zero);
    await sender.send(params());
    api.gate!.complete();
    await first;
    expect(signer.signs, 1);
    expect(api.sends, 1);
  });
  test('Max keeps both storage reserve and the fee reserve', () async {
    final api = Api()..reserve = BigInt.from(10).pow(24);
    final signer = Signer();
    await NearSender(
      trustdart: signer,
      apiFactory: (_) => api,
    ).send(params(exact: BigInt.from(10).pow(26), max: true));
    final encoded = RegExp(r'..')
        .allMatches(signer.payload!['amount'] as String)
        .map((m) => m.group(0)!)
        .toList()
        .reversed
        .join();
    expect(
      BigInt.parse(encoded, radix: 16),
      BigInt.from(10).pow(26) - api.reserve - BigInt.from(300000000000000),
    );
    expect(api.sends, 1);
  });
  test('ordinary transfer cannot consume storage reserve', () async {
    final api = Api()..reserve = BigInt.from(10).pow(26);
    final signer = Signer();
    await NearSender(trustdart: signer, apiFactory: (_) => api).send(params());
    expect(signer.signs, 0);
    expect(api.sends, 0);
  });
  test('missing spendable balance blocks signing', () async {
    final api = Api()..balanceError = true;
    final signer = Signer();
    await NearSender(trustdart: signer, apiFactory: (_) => api).send(params());
    expect(signer.signs, 0);
    expect(api.sends, 0);
  });
}
