import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';

import '../../../helpers/wallet_connect_client_fake.dart';

class _DeferredPreview extends SessionPreviewProvider {
  final pending = Completer<bool>();
  @override
  Future<bool> web3clientInitFromChainId(String chain) => pending.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'old chain initialization cannot overwrite a newer request preview',
    () async {
      final provider = _DeferredPreview()
        ..coinModels = [sessionCoin()]
        ..coinModelsIndex = 0;
      addTearDown(provider.dispose);
      final old = sessionRequest('personal_sign', [
        'old',
        '0x1111111111111111111111111111111111111111',
      ]);
      final waiting = provider.setActionDataMap(old);
      final next = sessionRequest('personal_sign', [
        'new',
        '0x1111111111111111111111111111111111111111',
      ], id: 43);
      provider.actionData = next;
      provider.actionDataMap = {'keep': 'new'};
      provider.walletConnectState = WalletConnectState.messageSignOK;
      provider.pending.complete(true);
      await waiting;
      expect(provider.actionData, same(next));
      expect(provider.actionDataMap, {'keep': 'new'});
      expect(provider.walletConnectState, WalletConnectState.messageSignOK);
    },
  );
}
