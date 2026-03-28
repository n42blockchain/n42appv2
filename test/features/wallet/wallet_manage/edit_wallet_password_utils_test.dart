import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/edit_wallet_password_utils.dart';

void main() {
  test(
    'canDismissEditWalletPassword only allows pop outside loading state',
    () {
      expect(canDismissEditWalletPassword(Load.loading), isFalse);
      expect(canDismissEditWalletPassword(Load.finish), isTrue);
      expect(canDismissEditWalletPassword(Load.error), isTrue);
    },
  );
}
