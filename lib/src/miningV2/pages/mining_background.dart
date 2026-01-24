import 'dart:io';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/src/utils/notfication_utils.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';

class MiningBackground{
  void backgroundStart() {
    Trustdart().liveActivityStart();
    if(Platform.isAndroid){
      notification.sendAndroid(AppConfig.apiUrl['walletamazeBrowser'], S.current.g_mining_key_73,notificationId:10086);
    }
  }
  void backgroundEnd() {
    Trustdart().liveActivityEnd(0);
    if(Platform.isAndroid){
      notification.cancelNotification(10086);
    }
  }
}