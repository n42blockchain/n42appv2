import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';

class _MemoryUserStore extends SPUtil {
  @override
  Future<Map<String, dynamic>?> getUserInfo() async => null;
}

class TestCurrentUser extends CurrentUserNotifier {
  TestCurrentUser([String id = 'alice']) : super(_MemoryUserStore()) {
    select(id);
  }

  void select(String id) {
    state = id.isEmpty ? null : SharedUserInfo(uuid: id, email: '');
  }
}
