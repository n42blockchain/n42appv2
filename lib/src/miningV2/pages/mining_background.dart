import 'dart:io';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/src/utils/notfication_utils.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';

class MiningBackground{
  backgroundStart(){
    Trustdart().LiveActivity_Start();
    if(Platform.isAndroid){
      notification.send_android(AppConfig.apiUrl['walletamazeBrowser'], S.current.g_mining_key_73,notificationId:10086);
    }
  }
  backgroundEnd(){
    Trustdart().LiveActivity_End(0);
    if(Platform.isAndroid){
      notification.cancelNotification(10086);
    }
  }
}