import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/https/ipfs_api.dart';
import 'package:n42appv2/src/login/api/user_info_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/utils/app_push_utils.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:n42appv2/data/models/user_info.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';


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

  //切换系统语言,start
  //当前系统语言，默认是英语
  Locale _locale = const Locale.fromSubtags(languageCode: 'en');

  Locale get locale => _locale;

  //切换系统语言
  switchLocale(String code) {
    switch (code) {
      case "fr": //法语
        _locale = const Locale('fr');
        break;
      case "en": //英语
        _locale = const Locale('en');
        break;
      case "bn": //孟加拉语
        _locale = const Locale('bn');
        break;
      case "nl": //荷兰语
        _locale = const Locale('nl');
        break;
      case "tl": //菲律宾语
        _locale = const Locale('tl');
        break;
      case "de": //德语
        _locale = const Locale('de');
        break;
      case "el": //希腊语
        _locale = const Locale('el');
        break;
      case "hi": //印地语
        _locale = const Locale('hi');
        break;
      case "id": //印度尼西亚语，印尼
        _locale = const Locale('id');
        break;
      case "ga": //爱尔兰语
        _locale = const Locale('ga');
        break;
      case "it": //意大利语
        _locale = const Locale('it');
        break;
      case "ja": //日语
        _locale = const Locale('ja');
        break;
      case "ko": //韩语
        _locale = const Locale('ko');
        break;
      case "ms": //马来语
        _locale = const Locale('ms');
        break;
      case "no": //挪威语
        _locale = const Locale('no');
        break;
      case "fa": //波斯语
        _locale = const Locale('fa');
        break;
      case "pt": //葡萄牙语
        _locale = const Locale('pt');
        break;
      case "ro": //罗马尼亚语
        _locale = const Locale('ro');
        break;
      case "ru": //俄语
        _locale = const Locale('ru');
        break;
      case "es_ES": //西班牙语
        _locale = const Locale('es',"ES");
        break;
      case "sw": //斯瓦希里语
        _locale = const Locale('sw');
        break;
      case "sv": //瑞典语
        _locale = const Locale('sv');
        break;
      case "th": //泰国语
        _locale = const Locale('th');
        break;
      case "tr": //土耳其语
        _locale = const Locale('tr');
        break;
      case "uk": //乌克兰语
        _locale = const Locale('uk');
        break;
      case "ur": //印度乌尔都语
        _locale = const Locale('ur');
        break;
      case "vi": //越南语
        _locale = const Locale('vi');
        break;
      case "zh_TW": //中文
        _locale = const Locale('zh','TW');
        break;
      case "zh_CN": //中文
        _locale = const Locale('zh','CN');
        break;
      default:
        _locale = const Locale('en');
    }
    SPUtil().setSysLang(code);
    notifyListeners();
  }
  Map<String,dynamic> get getLocaleInfo {
    String code=_locale.languageCode;
    switch (code) {
      case "en": //英语
        return {
          "icon":"assets/setting/english.png",
          "title":"English",
        };
      case "ja": //日语
        return {
          "icon":"assets/setting/japanese.png",
          "title":"日本語",
        };
      case "es": //西班牙语
        return {
          "icon":"assets/setting/spanish.png",
          "title":"España",
        };
      case "zh": //中文
        return {
          "icon":"assets/setting/chinese_tw.png",
          "title":"中文繁體",
        };
      case "zh_CN": //中文
        return {
          "icon":"assets/setting/chinese.png",
          "title":"中文简体",
        };
      default:
        return {
          "icon":"assets/setting/english.png",
          "title":"English",
        };
    }

  }

  //获取系统语言
  _getSysLangType() async {
    var sysLangType = await SPUtil().getSysLang();
    if (sysLangType == null) {
      switchLocale('en');
    } else {
      if(sysLangType=="zh_TW"){
        _locale = Locale("zh","TW");
      }else if(sysLangType=="zh_CN"){
        _locale = Locale("zh","CN");
      }else if(sysLangType=="es_ES"){
        _locale = Locale("es","ES");
      }else{
        _locale = Locale(sysLangType);
      }
    }
    notifyListeners();
  }

  //切换系统主题样式,start
  //当前系统的主题，默认是跟随系统
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  switchTheme(int type) {
    if (type == 0) {
      //系统默认
      _themeMode = ThemeMode.system;
      SPUtil().setThemeMode(0);
    } else if (type == 1) {
      //亮色
      _themeMode = ThemeMode.light;
      SPUtil().setThemeMode(1);
    } else if (type == 2) {
      //暗色
      _themeMode = ThemeMode.dark;
      SPUtil().setThemeMode(2);
    }
    notifyListeners();
  }

  //获取系统主题模式
  _getThemeModeType() async {
    SPUtil sPUtils=SPUtil();
    var themeModeT = await sPUtils.getThemeMode();
    if (themeModeT == null) {
      themeModeT = 0;
      sPUtils.setThemeMode(0);
    }
    switchTheme(themeModeT);
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
