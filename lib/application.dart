import 'package:n42appv2/src/state/public_provider.dart';
import 'package:n42appv2/src/utils/sp_util.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet_connect/provider/wallet_connect_provider.dart';
//import 'package:n42appv2/src/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/src/models/user_info.dart';
import 'package:provider/provider.dart';

class Application{
  static late BuildContext AppContext;
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  static UserInfo? userInfo;
  static int currentId=0;
  static Future login(UserInfo info)async{
    userInfo=info;
    Provider.of<WalletActionProvider>(AppContext,listen: false).init_wallet(initCoinInfo: true);
    Provider.of<WalletConnectProvider>(AppContext,listen: false).cleannData_loginout();
  }
  /// 退出应用
  static Future logout() async{
    try{
      await SPUtil().saveUserInfo(null);
      Application.userInfo = null;
      Provider.of<PublicProvider>(AppContext,listen: false).setUserInfo(null);
      Provider.of<WalletActionProvider>(AppContext,listen: false).init_wallet();
      Provider.of<WalletConnectProvider>(AppContext,listen: false).cleannData_loginout();
    }catch(err) {
      //err
    }
  }
}