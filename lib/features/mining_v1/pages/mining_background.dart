import 'dart:io';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/utils/notfication_utils.dart';

class MiningBackground {
  void backgroundStart() {
    // LiveActivity not available in n42appv2 - skipped
    if (Platform.isAndroid) {
      notification.sendAndroid(
        S.current.g_mining_key_73,
        '',
        notificationId: 10086,
      );
    }
  }

  void backgroundEnd() {
    // LiveActivity not available in n42appv2 - skipped
    if (Platform.isAndroid) {
      notification.cancelNotification(10086);
    }
  }
}
