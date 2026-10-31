import 'package:flutter_mining/mobileverify.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:n42_wallet/core/enums/mining_engine_kind.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/secure_preferences.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_engine.dart';

/// The v3 engine. It keeps running while the app lives and v3 stays the
/// selected engine; selecting v1 or v2 stops it, so only one engine runs.
final miningV3EngineProvider = ChangeNotifierProvider<MiningV3Engine>((ref) {
  final engine = MiningV3Engine(
    api: MethodChannelMobileVerify(),
    store: FlutterSecureStore(),
  );
  ref.listen<MiningEngineKind>(miningEngineKindProvider, (_, next) {
    if (next != MiningEngineKind.v3) engine.stop();
  });
  return engine;
});
