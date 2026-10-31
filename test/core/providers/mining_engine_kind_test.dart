import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/mining_engine_kind.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('stored mining engine', () {
    test('defaults to v2 when nothing was ever stored', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await SPUtil().getMiningEngine(), MiningEngineKind.v2);
    });

    test('migrates the pre-v3 bool: true is v2, false is v1', () async {
      SharedPreferences.setMockInitialValues({
        SPkey.miningUiVersion.name: false,
      });
      expect(await SPUtil().getMiningEngine(), MiningEngineKind.v1);
      SharedPreferences.setMockInitialValues({
        SPkey.miningUiVersion.name: true,
      });
      expect(await SPUtil().getMiningEngine(), MiningEngineKind.v2);
    });

    test(
      'the stored kind wins over the bool, and the bool follows it',
      () async {
        SharedPreferences.setMockInitialValues({
          SPkey.miningUiVersion.name: true,
        });
        final sp = SPUtil();
        await sp.setMiningEngine(MiningEngineKind.v1);
        expect(await SPUtil().getMiningEngine(), MiningEngineKind.v1);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(SPkey.miningUiVersion.name), isFalse);

        await sp.setMiningEngine(MiningEngineKind.v3);
        expect(await SPUtil().getMiningEngine(), MiningEngineKind.v3);
        // A downgraded app that only knows the bool opens v2.
        expect(prefs.getBool(SPkey.miningUiVersion.name), isTrue);
      },
    );

    test('an unknown stored name falls back to the bool', () async {
      SharedPreferences.setMockInitialValues({
        SPkey.miningEngine.name: 'v9',
        SPkey.miningUiVersion.name: false,
      });
      expect(await SPUtil().getMiningEngine(), MiningEngineKind.v1);
    });
  });

  group('MiningEngineKindNotifier', () {
    Future<MiningEngineKind> loaded(MiningEngineKindNotifier n) async {
      await pumpEventQueue();
      return n.state;
    }

    test('loads the stored kind', () async {
      SharedPreferences.setMockInitialValues({SPkey.miningEngine.name: 'v1'});
      expect(
        await loaded(MiningEngineKindNotifier(SPUtil(), v3Available: true)),
        MiningEngineKind.v1,
      );
    });

    test('without v3 a stored or selected v3 reads as v2', () async {
      SharedPreferences.setMockInitialValues({SPkey.miningEngine.name: 'v3'});
      final n = MiningEngineKindNotifier(SPUtil(), v3Available: false);
      expect(await loaded(n), MiningEngineKind.v2);
      await n.select(MiningEngineKind.v3);
      expect(n.state, MiningEngineKind.v2);
    });

    test('with v3 available, select persists v3', () async {
      SharedPreferences.setMockInitialValues({});
      final n = MiningEngineKindNotifier(SPUtil(), v3Available: true);
      await loaded(n);
      await n.select(MiningEngineKind.v3);
      expect(n.state, MiningEngineKind.v3);
      expect(await SPUtil().getMiningEngine(), MiningEngineKind.v3);
    });
  });
}
