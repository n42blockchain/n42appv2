import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/loyalty/api/loyalty_api.dart';
import 'package:n42_wallet/features/loyalty/models/loyalty_model.dart';
import 'package:n42_wallet/features/loyalty/provider/loyalty_provider.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

void main() {
  group('LoyaltyProvider.refresh', () {
    test('enters error state when all initial loads fail', () async {
      final provider = LoyaltyProvider(
        api: _FakeLoyaltyApi(),
      );

      await provider.initialize('0xabcdef123456');

      expect(provider.loadState, LoyaltyLoadState.error);
      expect(provider.errorMessage, 'Failed to load loyalty data');
      expect(provider.hasContent, isFalse);
    });

    test('stays loaded when at least one endpoint succeeds', () async {
      final provider = LoyaltyProvider(
        api: _FakeLoyaltyApi(
          account: LoyaltyAccount.empty(),
        ),
      );

      await provider.initialize('0xabcdef123456');

      expect(provider.loadState, LoyaltyLoadState.loaded);
      expect(provider.errorMessage, isNull);
    });
  });
}

class _FakeLoyaltyApi extends LoyaltyApi {
  _FakeLoyaltyApi({
    this.account,
  });

  final LoyaltyAccount? account;

  @override
  Future<MessageModel> getAccount(String walletAddress) async {
    if (account == null) {
      return MessageModel.error()..data = 'offline';
    }
    return MessageModel()
      ..error = false
      ..data = account;
  }

  @override
  Future<MessageModel> getTasks(String walletAddress) async {
    return MessageModel.error()..data = 'offline';
  }

  @override
  Future<MessageModel> getPointsHistory({
    required String walletAddress,
    int page = 1,
    int pageSize = 20,
  }) async {
    return MessageModel.error()..data = 'offline';
  }

  @override
  Future<MessageModel> fetchRewards() async {
    return MessageModel.error()..data = 'offline';
  }

  @override
  Future<MessageModel> fetchReferralCode(String walletAddress) async {
    return MessageModel.error()..data = 'offline';
  }

  @override
  Future<MessageModel> fetchReferrals(String walletAddress) async {
    return MessageModel.error()..data = 'offline';
  }
}
