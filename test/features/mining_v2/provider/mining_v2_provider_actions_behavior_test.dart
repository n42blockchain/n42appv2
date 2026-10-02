import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/features/mining_v2/api/mining_api.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';

class _FakeMiningApi extends MiningApi {
  _FakeMiningApi({this.runClientResult}) : super.init();

  final String? runClientResult;
  String? runClientPrivateKey;
  String? depositPrivateKey;
  String? depositAddress;
  String? depositValue;

  @override
  Future<String?> runClient(String validatorPrivateKey) async {
    runClientPrivateKey = validatorPrivateKey;
    return runClientResult;
  }

  @override
  Future<String?> createDepositUnsignedTx(
    String validatorPrivateKey,
    String withdrawalAddress,
    String depositValueWeiInHex,
  ) async {
    depositPrivateKey = validatorPrivateKey;
    depositAddress = withdrawalAddress;
    depositValue = depositValueWeiInHex;
    return null;
  }

  @override
  Future<String?> miningCreateGetExitFeeUnsignedTx() async => null;
}

void main() {
  test(
    'setMiningWalletByIndex emits the selected index and notifies',
    () async {
      final provider = MiningV2Provider();
      addTearDown(provider.dispose);
      var notifications = 0;
      provider.addListener(() => notifications++);
      final events = <EventPublic>[];
      final subscription = eventBus.on<EventPublic>().listen(events.add);
      addTearDown(subscription.cancel);

      await provider.setMiningWalletByIndex(3);
      await Future<void>.delayed(Duration.zero);

      expect(notifications, 1);
      expect(events, hasLength(1));
      expect(events.single.type, EventPublicType.selectMiningWallet);
      expect(events.single.intValue, 3);
    },
  );

  test('runMining marks the provider active when the client starts', () async {
    final provider = MiningV2Provider()
      ..miningKeypart = {'privateKey': 'synthetic-validator-key'};
    addTearDown(provider.dispose);
    final miningApi = _FakeMiningApi(runClientResult: 'Client started');
    provider.debugMiningApi = miningApi;

    await provider.runMining();

    expect(miningApi.runClientPrivateKey, 'synthetic-validator-key');
    expect(provider.miningStatus, isTrue);
    expect(provider.errorMessage, isEmpty);
  });

  test('runMining exposes client errors and remains inactive', () async {
    final provider = MiningV2Provider()
      ..miningKeypart = {'privateKey': 'synthetic-validator-key'};
    addTearDown(provider.dispose);
    provider.debugMiningApi = _FakeMiningApi(
      runClientResult: 'validator rejected',
    );

    await provider.runMining();

    expect(provider.miningStatus, isFalse);
    expect(provider.errorMessage, 'validator rejected');
  });

  test('runMining reports a missing native result as a failure', () async {
    final provider = MiningV2Provider();
    addTearDown(provider.dispose);
    provider.debugMiningApi = _FakeMiningApi();

    await provider.runMining();

    expect(provider.miningStatus, isFalse);
    expect(provider.errorMessage, 'Running the "runClient" method failed!');
  });

  test(
    'missing deposit transaction updates loading state and notifies again',
    () async {
      final provider = MiningV2Provider()..address = '0xwallet';
      addTearDown(provider.dispose);
      final miningApi = _FakeMiningApi();
      provider.debugMiningApi = miningApi;
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.createDepositUnsignedTx(1, {
        'validator': {'privateKey': 'synthetic-validator-key'},
      });

      expect(miningApi.depositPrivateKey, 'synthetic-validator-key');
      expect(miningApi.depositAddress, '0xwallet');
      expect(miningApi.depositValue, isNotEmpty);
      expect(provider.depositLoad, Load.finish);
      expect(provider.errorMessage, 'Error!');
      expect(notifications, 2);
    },
  );

  test(
    'missing exit fee leaves the exit flow finished with an error',
    () async {
      final provider = MiningV2Provider();
      addTearDown(provider.dispose);
      provider.debugMiningApi = _FakeMiningApi();
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.createExitDepositUnsignedTx();

      expect(provider.exitDepositLoad, Load.finish);
      expect(
        provider.errorMessage,
        "'miningCreateGetExitFeeUnsignedTx' method error!",
      );
      expect(notifications, 2);
    },
  );

  test(
    'setting exit transaction hash replaces and can stop the poll timer',
    () async {
      final provider = MiningV2Provider();
      addTearDown(provider.dispose);

      provider.setDepositTxHash('deposit-hash');
      final depositTimer = provider.txCheckTimer;
      provider.setExitDepositTxHash('exit-hash');
      final exitTimer = provider.txCheckTimer;

      expect(provider.depositTxHash, 'deposit-hash');
      expect(provider.exitDepositTxHash, 'exit-hash');
      expect(depositTimer?.isActive, isFalse);
      expect(exitTimer, isNotNull);
      expect(exitTimer?.isActive, isTrue);

      provider.endCheckTxHash();
      expect(provider.txCheckTimer, isNull);
      expect(exitTimer?.isActive, isFalse);
    },
  );
}
