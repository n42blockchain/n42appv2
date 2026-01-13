import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/constants/language_constants.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/core/utils/theme_mode_utils.dart';
import 'package:n42appv2/data/models/user_info.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/https/ipfs_api.dart';
import 'package:n42appv2/src/login/api/user_info_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/utils/app_push_utils.dart';


class PublicProvider extends ChangeNotifier with DiagnosticableTreeMixin{
  bool unlockIsPush = false; //是否已经锁屏
  bool checkWalletPassword = false; //是否验证了钱包密码
  setCheckWalletPassword(bool value) {
    checkWalletPassword = value;
    notifyListeners();
  }
  //初始化
  PublicProvider() {
    _getSysLangType();
    _getThemeModeType();
  }
  //验证数据、初始化数据
  checkData() async {
    await _getUserInfo();
    await getLockScreenData();
    load = Load.finish;
    notifyListeners();
  }
  //获取用户信息
  _getUserInfo() async {
    try {
      SPUtil sPUtils=SPUtil();
      var userInfo = await sPUtils.getUserInfo();
      if (userInfo != null) {
        UserInfo info = UserInfo.fromJson(userInfo);
        //AppGlobals.login(info);
        setUserInfo(info);
        //AppGlobals.userInfo!.createWallet = await checkWallet();
        UserInfo? ruInfo = await getUserInfoFromServer(info);
        if (ruInfo != null) {
          //ruInfo.createWallet = info.createWallet;
          AppGlobals.userInfo = ruInfo;
          setUserInfo(info);
          await sPUtils.saveUserInfo(ruInfo);
          //ProviderUtil.walletActionProvider().init();
        }
      }
    } catch (e) {
    }
  }

  //页面加载状态
  Load load = Load.loading;
  ///共享用户信息
  UserInfo? _userInfo;
  UserInfo? get userInfo => _userInfo;
  setUserInfo(UserInfo? info) {
    _userInfo = info;
    notifyListeners();
  }

  //未读消息数量
  int messageNotReadCount = 0;

  setMessageNotReadCount({int? value}) {
    if (value == null) {
      messageNotReadCount++;
    } else {
      messageNotReadCount = value;
      AppPushUtils.removeBadgeCount();
    }
    notifyListeners();
  }

  // 系统语言
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  /// 切换系统语言 - 使用共享语言常量
  void switchLocale(String code) {
    _locale = _codeToLocale(code);
    SPUtil().setSysLang(code);
    notifyListeners();
  }

  /// 获取当前语言信息 - 使用共享语言常量
  Map<String, dynamic> get getLocaleInfo {
    final lang = getLanguageByCode(_locale.languageCode);
    return {"icon": lang.icon, "title": lang.name};
  }

  /// 语言代码转 Locale
  Locale _codeToLocale(String code) {
    if (code.contains('_')) {
      final parts = code.split('_');
      return Locale(parts[0], parts[1]);
    }
    return Locale(code);
  }

  /// 获取系统语言
  Future<void> _getSysLangType() async {
    final sysLangType = await SPUtil().getSysLang();
    _locale = _codeToLocale(sysLangType ?? 'en');
    notifyListeners();
  }

  // 主题模式
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  /// 切换主题 - 使用共享工具类
  void switchTheme(int type) {
    _themeMode = ThemeModeUtils.fromInt(type);
    SPUtil().setThemeMode(type);
    notifyListeners();
  }

  /// 获取系统主题模式
  Future<void> _getThemeModeType() async {
    final type = await SPUtil().getThemeMode() ?? 0;
    _themeMode = ThemeModeUtils.fromInt(type);
    notifyListeners();
  }

  //主页面 tabbar 索引
  int homeCurrentIndex=0;
  //设置 homeCurrentIndex
  setHomeCurrentIndex(int value){
    homeCurrentIndex=value;
    notifyListeners();
  }

  getUserInfoFromServer(UserInfo uInfo) async {
    UserInfoApi loginApi=UserInfoApi();
    UserInfo? uData = await loginApi.getUserInfo(
        uInfo.uuid??"", uInfo.token!, uInfo.hashCode.toString());
    if (uData != null) {
      //uInfo=uData;
      return uData;
    } else {
      return null;
    }
  }

  //修改用户信息
  editUserInfo(UserInfo uInfo, {Uint8List? imageData}) async {
    MessageModel mm = MessageModel();
    if (imageData != null) {
      //上传图片
      Map<String, dynamic> rData = await IpfsApi().uploadIPFSImage(
        imageData,
        "aImage.png",
            (int count, int total) {},
        type: 1,
      );
      if (rData["error"]) {
        mm.error = true;
        mm.data = S.current.g_key_u_23;
        return mm;
      } else {
        uInfo.image ="${AppConfig.apiUrl['ipfsAddress']}${rData['data']['Hash']}";
        //"https://${rData['data']}${AppConfig.apiUrl['ipfsAddress']}aImage.png"; //ipfsAddress+rData['data']['Hash'];
      }
    }
    Map<String, dynamic> uMap = {
      //"art_json":artStr,
      "desc": uInfo.desc ?? "",
      //"idx_email_hash":uInfo.idx_email_hash==null?"":uInfo.idx_email_hash,
      "image": uInfo.image ?? "",
      "name": uInfo.name ?? "",
    };
    UserInfoApi userInfoAPI=UserInfoApi();
    mm = await userInfoAPI.updateUserInfo(uMap);
    if (mm.error == false) {
      await SPUtil().saveUserInfo(uInfo);
      AppGlobals.userInfo = uInfo;
      setUserInfo(uInfo);
      notifyListeners();
    }
    return mm;
  }
  ///////////////////////////////////
  //解决引导页问题， 主页的tabbar 切换时调用此方法展示引导页
  //main tabbar
  int selectIndex = 0;
  setSelectIndex(int value) {
    selectIndex = value;
    notifyListeners();
  }

  ///////后台切到前台 弹出锁屏属性
  Map<String, dynamic> lockScreenMap = {
    "lock": false, //是否锁屏
    "lockPW": "", //锁屏密码
    "face": false, //面部识别
    "fingerprint": false, //指纹识别
    //"walletPassword":true,//钱包密码
    "lockTime": 30,
    "gesture": false, //是否开启手势密码
    "gesturePW": "", //手势密码
    "PWLock":0,//密码输入错误时间
  };

  //获取锁屏缓存
  getLockScreenData() async {
    Map<String, dynamic>? rData = await SPUtil().getLockScreen();
    if (rData != null) {
      lockScreenMap = rData;
      if (lockScreenMap['lockPW'] == null) {
        lockScreenMap['lock'] = false;
        lockScreenMap['lockPW'] = "";
        setLockScreenData();
      }
      if (lockScreenMap['gesture'] == null) {
        lockScreenMap['gesture'] = false;
        lockScreenMap['gesturePW'] = [];
        setLockScreenData();
      }
      if(lockScreenMap['PWLock']==null){
        lockScreenMap['PWLock']=0;
      }
    }
  }

  setLockScreenData() async {
    await SPUtil().setLockScreen(lockScreenMap);
  }
/////////

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<UserInfo?>("userInfo", userInfo));
  }
}
