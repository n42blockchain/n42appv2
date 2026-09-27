import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/mining_v2/api/mining_api.dart';
import 'package:n42_wallet/features/mining_v2/api/mining_web3.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class _FailingExitApi extends MiningApi {
  _FailingExitApi() : super.init();

  @override
  Future<String?> miningCreateGetExitFeeUnsignedTx() async => '{}';

  @override
  Future<String?> miningCreateExitUnsignedTx(
    String feeWeiInHex,
    String validatorPublicKey,
  ) async => null;
}

class _FakeWeb3 extends MiningWeb3 {
  _FakeWeb3() : super.init(base64Encode(List<int>.filled(32, 1)));

  int sendCalls = 0;

  @override
  Future<MessageModel> exitDepositRowCall(String feeWeiInHexTx) async =>
      MessageModel()..data = 'invalid-fee';

  @override
  Future<MessageModel> sendExitDepositTransaction(
    Map<String, dynamic> signData,
  ) async {
    sendCalls++;
    return MessageModel.error()..data = 'sent unexpectedly';
  }
}

class _TestMiningProvider extends MiningV2Provider {
  _TestMiningProvider(this.fakeWeb3);

  final _FakeWeb3 fakeWeb3;

  @override
  MiningWeb3 get web3 => fakeWeb3;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'null native exit transaction stops before signing or sending',
    () async {
      final web3 = _FakeWeb3();
      final provider = _TestMiningProvider(web3)
        ..debugMiningApi = _FailingExitApi()
        ..miningKeypart = {'publicKey': 'synthetic-pubkey'};

      await provider.createExitDepositUnsignedTx();

      expect(web3.sendCalls, 0);
      expect(provider.exitDepositLoad, Load.finish);
      expect(provider.errorMessage, contains('miningCreateExitUnsignedTx'));
      provider.dispose();
    },
  );
}
