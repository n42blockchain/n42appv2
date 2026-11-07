import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/transfer_handler.dart';
import 'package:n42_wallet/features/wallet/mpc/mpc_provider.dart';
import 'package:n42_wallet/features/wallet/mpc/mpc_transfer_handler.dart';

class _Provider extends Mock implements MpcProvider {}

class _Sender implements ChainSender {
  SendParams? received;
  SendResult result = const SendResult.ok('0xaccepted', actualAmount: 1);
  @override
  Future<SendResult> send(SendParams params) async {
    received = params;
    return result;
  }
}

void main() {
  late _Provider provider;
  late _Sender sender;
  late MpcTransferHandler handler;
  var current = true;
  setUp(() {
    current = true;
    provider = _Provider();
    when(() => provider.isLoggedIn).thenReturn(true);
    sender = _Sender();
    handler = MpcTransferHandler(
      'ETH',
      senderFactory: (signer) {
        expect(signer.provider, same(provider));
        return sender;
      },
    );
  });
  SendParams transaction({
    String coin = 'ETH',
    bool persist = true,
    String? privateKey,
  }) => SendParams(
    coinType: coin,
    fromAddress: '0x${'11' * 20}',
    toAddress: '0x${'22' * 20}',
    amount: 1,
    decimals: 18,
    path: '',
    valueWeiOverride: BigInt.from(10).pow(18),
    chainConfig: const {'chainId': 1},
    beforeBroadcast: persist ? (_) async {} : null,
    privateKey: privateKey,
  );
  MpcTransferParams prepared(SendParams tx) => MpcTransferParams.prepared(
    transaction: tx,
    provider: provider,
    isCurrent: () => current,
  );
  test(
    'legacy intent-only params never produce a success or signature',
    () async {
      final result = await handler.transfer(
        MpcTransferParams(
          chainSymbol: 'ETH',
          fromAddress: 'from',
          toAddress: 'to',
          value: 1,
          mpcProvider: provider,
        ),
      );
      expect(result.error, isTrue);
      expect(sender.received, isNull);
      verifyZeroInteractions(provider);
    },
  );
  test(
    'delegates the identical reviewed request and returns the RPC hash',
    () async {
      final tx = transaction();
      final result = await handler.transfer(prepared(tx));
      expect(sender.received, same(tx));
      expect(result.error, isFalse);
      expect(result.data, {'txHash': '0xaccepted', 'value': 1});
    },
  );
  test(
    'uncertain broadcast preserves original hash and never becomes success',
    () async {
      sender.result = const SendResult.uncertain('0xlocal', 'timeout');
      final result = await handler.transfer(prepared(transaction()));
      expect(result.error, isTrue);
      expect(result.data['txHash'], '0xlocal');
      expect(result.data['uncertain'], isTrue);
      expect(result.data['definitelyNotSubmitted'], isFalse);
    },
  );
  test('known non-submission retains its distinct outcome', () async {
    sender.result = const SendResult.notSubmitted('0xlocal', 'stopped');
    final result = await handler.transfer(prepared(transaction()));
    expect(result.error, isTrue);
    expect(result.data['uncertain'], isFalse);
    expect(result.data['definitelyNotSubmitted'], isTrue);
  });
  test('refuses missing durable persistence', () async {
    expect(
      (await handler.transfer(prepared(transaction(persist: false)))).error,
      isTrue,
    );
    expect(sender.received, isNull);
  });
  test('refuses local-key fallback', () async {
    expect(
      (await handler.transfer(prepared(transaction(privateKey: 'fixture'))))
          .error,
      isTrue,
    );
    expect(sender.received, isNull);
  });
  test('refuses a changed account session', () async {
    current = false;
    expect((await handler.transfer(prepared(transaction()))).error, isTrue);
    expect(sender.received, isNull);
  });
  test('refuses a request for a different chain', () async {
    expect(
      (await handler.transfer(prepared(transaction(coin: 'BASE')))).error,
      isTrue,
    );
    expect(sender.received, isNull);
  });
  test('refuses contradictory legacy and reviewed metadata', () async {
    final tx = transaction();
    final result = await handler.transfer(
      MpcTransferParams(
        chainSymbol: 'ETH',
        fromAddress: tx.fromAddress,
        toAddress: 'different',
        value: 1,
        mpcProvider: provider,
        transaction: tx,
        isCurrent: () => true,
      ),
    );
    expect(result.error, isTrue);
    expect(sender.received, isNull);
  });
  test('refuses non-MPC transfer params', () async {
    final result = await handler.transfer(
      const TransferParams(
        chainSymbol: 'ETH',
        fromAddress: 'from',
        toAddress: 'to',
        value: 1,
      ),
    );
    expect(result.error, isTrue);
    expect(sender.received, isNull);
  });
}
