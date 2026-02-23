import 'dart:io';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/src/utils/notfication_utils.dart';

class MiningBackground {
  background_start() {
    // LiveActivity not available in n42appv2 - skipped
    if (Platform.isAndroid) {
      notification.sendAndroid(
        S.current.g_mining_key_73,
        '',
        notificationId: 10086,
      );
    }
  }

  background_end() {
    // LiveActivity not available in n42appv2 - skipped
    if (Platform.isAndroid) {
      notification.cancelNotification(10086);
    }
  }
}
