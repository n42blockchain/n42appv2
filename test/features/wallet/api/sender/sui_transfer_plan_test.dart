import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sui_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/sui_transfer_plan.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

BigInt b(int value) => BigInt.from(value);

const chain = '4btiuiMPvEENsttpZC7CZ53DruC3MAgfznDbASZ7DR6S';

class PlanApi extends SuiApi {
  List<dynamic> objects;
  BigInt addressBalance;
  bool balanceFails = false;
  bool networkFails = false;
  int balanceReads = 0;
  int networkReads = 0;
  PlanApi(this.objects, {BigInt? addressBalance})
    : addressBalance = addressBalance ?? BigInt.zero;

  @override
  Future<List<dynamic>> getOwnedObjects(String address) async => objects;

  @override
  Future<MessageModel> getBalancesSui(String address) async {
    balanceReads++;
    if (balanceFails) return MessageModel.error()..data = 'down';
    var coins = BigInt.zero;
    for (final o in objects) {
      coins += BigInt.parse(
        o['data']['content']['fields']['balance'] as String,
      );
    }
    return MessageModel()
      ..data = SuiBalances(
        total: coins + addressBalance,
        coins: coins,
        address: addressBalance,
      );
  }

  @override
  Future<MessageModel> getNetworkSui() async {
    networkReads++;
    if (networkFails) return MessageModel.error()..data = 'down';
    return MessageModel()
      ..data = SuiNetworkState(
        epoch: b(1312),
        referenceGasPrice: b(100),
        chainIdentifier: chain,
      );
  }
}

Map<String, dynamic> coin(String id, int balance) => {
  'data': {
    'objectId': id,
    'version': '7',
    'digest': 'digest-$id',
    'content': {
      'fields': {'balance': '$balance'},
    },
  },
};

Future<SuiTransferRequest> prepare(
  PlanApi api, {
  int amount = 1000,
  int budget = 300,
  int Function()? nonce,
}) => prepareSuiTransfer(
  api: api,
  fromAddress: '0xfrom',
  toAddress: '0xto',
  amount: b(amount),
  gasBudget: b(budget),
  referenceGasPrice: b(750),
  nonce: nonce ?? () => 42,
);

void main() {
  group('planSuiFunding', () {
    SuiFundingPlan? plan(
      int amount,
      int budget,
      int coins,
      int funds, {
      bool? hasCoins,
      int recipients = 1,
    }) => planSuiFunding(
      amount: b(amount),
      gasBudget: b(budget),
      coinBalance: b(coins),
      hasCoins: hasCoins ?? coins > 0,
      addressBalance: b(funds),
      recipients: recipients,
    );

    test('coins covering amount and budget are coin-only', () {
      final p = plan(1000, 300, 1300, 0)!;
      expect(p.coinsOnly, isTrue);
      expect(p.addressBalanceAmount, BigInt.zero);
      expect(p.reservations, 0);
    });

    test(
      'coins covering the budget keep paying gas; the rest is withdrawn',
      () {
        final p = plan(1000, 300, 500, 800)!;
        expect(p.gasFromAddressBalance, isFalse);
        expect(p.addressBalanceAmount, b(800));
        expect(p.reservations, 1);
        expect(plan(1000, 300, 500, 799), isNull);
      },
    );

    test('coins below the budget: gas from the address balance', () {
      final p = plan(1000, 300, 200, 1100)!;
      expect(p.gasFromAddressBalance, isTrue);
      expect(p.addressBalanceAmount, b(800));
      expect(p.reservations, 2);
      // The address balance must cover the withdrawal and the whole budget.
      expect(plan(1000, 300, 200, 1099), isNull);
    });

    test(
      'small coins that cover the amount only fund it; gas from balance',
      () {
        final p = plan(100, 300, 200, 300)!;
        expect(p.gasFromAddressBalance, isTrue);
        expect(p.addressBalanceAmount, BigInt.zero);
        expect(p.reservations, 1);
      },
    );

    test('no coins: withdraw exactly the amount, gas from the balance', () {
      final p = plan(1000, 300, 0, 1300)!;
      expect(p.gasFromAddressBalance, isTrue);
      expect(p.addressBalanceAmount, b(1000));
      expect(p.reservations, 2);
      expect(plan(1000, 300, 0, 1299), isNull);
    });

    test('at most 10 withdraw reservations besides gas', () {
      expect(plan(10, 1, 0, 100, recipients: 10)!.reservations, 11);
      expect(plan(11, 1, 0, 100, recipients: 11), isNull);
      expect(suiMaxWithdrawReservations, 10);
    });

    test('invalid input is refused', () {
      expect(plan(0, 300, 5000, 5000), isNull);
      expect(plan(1000, 0, 5000, 5000), isNull);
      expect(plan(1000, 300, -1, 5000, hasCoins: true), isNull);
      expect(plan(1000, 300, 0, -1), isNull);
      expect(plan(1000, 300, 5, 5000, hasCoins: false), isNull);
      expect(plan(1, 1, 0, 100, recipients: 0), isNull);
    });

    test('nothing to spend is refused', () {
      expect(plan(1000, 300, 0, 0), isNull);
      expect(plan(1000, 300, 1299, 0), isNull);
    });
  });

  group('prepareSuiTransfer', () {
    test('sufficient coins: the pre-SIP-58 map and no extra reads', () async {
      final api = PlanApi([coin('a', 900), coin('b', 400)]);
      final request = await prepare(api);
      expect(request.error, isNull);
      expect(request.plan!.coinsOnly, isTrue);
      expect(request.signMap, {
        'type': 'SUI_TRANSFER',
        'amount': '1000',
        'toAddress': '0xto',
        'fromAddress': '0xfrom',
        'gasBudget': '300',
        'referenceGasPrice': '750',
        'utxo': [
          {'objectId': 'a', 'version': '7', 'objectDigest': 'digest-a'},
          {'objectId': 'b', 'version': '7', 'objectDigest': 'digest-b'},
        ],
      });
      expect(api.balanceReads, 0);
      expect(api.networkReads, 0);
    });

    test(
      'coins pay gas, the shortfall comes from the address balance',
      () async {
        final api = PlanApi([coin('a', 500)], addressBalance: b(5000));
        final request = await prepare(api);
        final map = request.signMap!;
        expect(map['addressBalanceAmount'], '800');
        expect(map.containsKey('validDuring'), isFalse);
        expect(map['referenceGasPrice'], '750');
        expect(map['utxo'], hasLength(1));
        expect(api.networkReads, 0);
      },
    );

    test('no coins: address balance pays amount and gas in a window', () async {
      final api = PlanApi([], addressBalance: b(5000));
      final request = await prepare(api, nonce: () => 4294967295);
      final map = request.signMap!;
      expect(map['utxo'], isEmpty);
      expect(map['addressBalanceAmount'], '1000');
      // Price and window both come from the network read.
      expect(map['referenceGasPrice'], '100');
      expect(map['validDuring'], {
        'minEpoch': '1312',
        'maxEpoch': '1313',
        'chain': chain,
        'nonce': '4294967295',
      });
      expect(request.plan!.reservations, 2);
    });

    test('each signing request draws a fresh nonce', () async {
      final api = PlanApi([], addressBalance: b(5000));
      var next = 0;
      final first = await prepare(api, nonce: () => ++next);
      final second = await prepare(api, nonce: () => ++next);
      expect(first.signMap!['validDuring']['nonce'], '1');
      expect(second.signMap!['validDuring']['nonce'], '2');
    });

    test('the default nonce is a uint32', () {
      for (var i = 0; i < 100; i++) {
        final n = randomSuiNonce();
        expect(n, inInclusiveRange(0, 4294967295));
      }
    });

    test('an out-of-range nonce is refused', () async {
      final api = PlanApi([], addressBalance: b(5000));
      expect((await prepare(api, nonce: () => 1 << 32)).signMap, isNull);
      expect((await prepare(api, nonce: () => -1)).signMap, isNull);
    });

    test('insufficient funds sign nothing', () async {
      final api = PlanApi([coin('a', 100)], addressBalance: b(100));
      final request = await prepare(api);
      expect(request.signMap, isNull);
      expect(request.error, 'Insufficient Sui balance');
    });

    test('read failures sign nothing', () async {
      final balanceDown = PlanApi([], addressBalance: b(5000))
        ..balanceFails = true;
      expect((await prepare(balanceDown)).signMap, isNull);
      final networkDown = PlanApi([], addressBalance: b(5000))
        ..networkFails = true;
      expect((await prepare(networkDown)).signMap, isNull);
    });

    test('a coin without a balance is refused', () async {
      final api = PlanApi([
        {
          'data': {'objectId': 'a', 'version': '7', 'digest': 'd'},
        },
      ], addressBalance: b(5000));
      final request = await prepare(api);
      expect(request.signMap, isNull);
      expect(request.error, 'Invalid Sui coin data');
      expect(api.balanceReads, 0);
    });
  });
}
