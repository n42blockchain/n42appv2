import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/mining_engine_kind.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_providers.dart';

class _Store extends SPUtil {
  MiningEngineKind kind = MiningEngineKind.v3;
  @override
  Future<MiningEngineKind> getMiningEngine() async => kind;
  @override
  Future<void> setMiningEngine(MiningEngineKind value) async => kind = value;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('switching versions cancels background-paused iOS mining', () async {
    const channel = MethodChannel('n42/mobileverify');
    var paused = true;
    var stops = 0;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'minerStop') {
        stops++;
        paused = false;
        return null;
      }
      if (call.method == 'minerStatus') {
        return '{"running":false,"phase":"idle","pausedForBackground":$paused}';
      }
      throw StateError('Unexpected native call: ${call.method}');
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final container = ProviderContainer(
      overrides: [spUtilProvider.overrideWithValue(_Store())],
    );
    addTearDown(container.dispose);
    final selection = container.read(miningEngineKindProvider.notifier);
    await pumpEventQueue();
    final engine = container.read(miningV3EngineProvider);
    await engine.refresh();
    expect(engine.pausedForBackground, isTrue);
    await selection.select(MiningEngineKind.v2);
    await pumpEventQueue();
    expect(stops, 1);
    expect(engine.pausedForBackground, isFalse);
  });
}
