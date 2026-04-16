import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('mr'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('sw'),
    Locale('ta'),
    Locale('te'),
    Locale('tr'),
    Locale('uk'),
    Locale('ur'),
    Locale('vi'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @commonRetry.
  ///
  /// In zh, this message translates to:
  /// **'重試'**
  String get commonRetry;

  /// No description provided for @commonUnknownUser.
  ///
  /// In zh, this message translates to:
  /// **'未知用戶'**
  String get commonUnknownUser;

  /// No description provided for @transferWalletNotConnected.
  ///
  /// In zh, this message translates to:
  /// **'錢包未連接'**
  String get transferWalletNotConnected;

  /// No description provided for @chatCallServiceNotInitialized.
  ///
  /// In zh, this message translates to:
  /// **'通話服務未初始化'**
  String get chatCallServiceNotInitialized;

  /// No description provided for @authLoginFailed.
  ///
  /// In zh, this message translates to:
  /// **'登錄失敗: {error}'**
  String authLoginFailed(String error);

  /// No description provided for @chatCallBack.
  ///
  /// In zh, this message translates to:
  /// **'回撥'**
  String get chatCallBack;

  /// No description provided for @chatMissedVideoCall.
  ///
  /// In zh, this message translates to:
  /// **'未接視頻通話'**
  String get chatMissedVideoCall;

  /// No description provided for @chatMissedVoiceCall.
  ///
  /// In zh, this message translates to:
  /// **'未接語音通話'**
  String get chatMissedVoiceCall;

  /// No description provided for @chatCallNotAnswered.
  ///
  /// In zh, this message translates to:
  /// **'對方未接聽'**
  String get chatCallNotAnswered;

  /// No description provided for @chatCallDurationLabel.
  ///
  /// In zh, this message translates to:
  /// **'通話時長'**
  String get chatCallDurationLabel;

  /// No description provided for @chatVoiceCallCancelled.
  ///
  /// In zh, this message translates to:
  /// **'語音通話已取消'**
  String get chatVoiceCallCancelled;

  /// No description provided for @chatVideoCallCancelled.
  ///
  /// In zh, this message translates to:
  /// **'視頻通話已取消'**
  String get chatVideoCallCancelled;

  /// No description provided for @commonImage.
  ///
  /// In zh, this message translates to:
  /// **'[圖片]'**
  String get commonImage;

  /// No description provided for @chatVideo.
  ///
  /// In zh, this message translates to:
  /// **'[視頻]'**
  String get chatVideo;

  /// No description provided for @chatVoice.
  ///
  /// In zh, this message translates to:
  /// **'[語音]'**
  String get chatVoice;

  /// No description provided for @commonFile.
  ///
  /// In zh, this message translates to:
  /// **'[文件]'**
  String get commonFile;

  /// No description provided for @chatLocation.
  ///
  /// In zh, this message translates to:
  /// **'[位置]'**
  String get chatLocation;

  /// No description provided for @chatUnknownMessage.
  ///
  /// In zh, this message translates to:
  /// **'[未知消息]'**
  String get chatUnknownMessage;

  /// No description provided for @commonDelete.
  ///
  /// In zh, this message translates to:
  /// **'刪除'**
  String get commonDelete;

  /// No description provided for @chatDeleteThisMessage.
  ///
  /// In zh, this message translates to:
  /// **'刪除這條消息？'**
  String get chatDeleteThisMessage;

  /// No description provided for @chatMessageDeleted.
  ///
  /// In zh, this message translates to:
  /// **'消息已刪除'**
  String get chatMessageDeleted;

  /// No description provided for @profileNotLoggedIn.
  ///
  /// In zh, this message translates to:
  /// **'未登錄'**
  String get profileNotLoggedIn;

  /// No description provided for @chatMyLocation.
  ///
  /// In zh, this message translates to:
  /// **'我的位置'**
  String get chatMyLocation;

  /// No description provided for @commonGroupChat.
  ///
  /// In zh, this message translates to:
  /// **'羣聊'**
  String get commonGroupChat;

  /// No description provided for @commonSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get commonSearch;

  /// No description provided for @commonCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get commonCancel;

  /// No description provided for @commonLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加載失敗'**
  String get commonLoadFailed;

  /// No description provided for @commonMessages.
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get commonMessages;

  /// No description provided for @commonContacts.
  ///
  /// In zh, this message translates to:
  /// **'聯繫人'**
  String get commonContacts;

  /// No description provided for @commonMe.
  ///
  /// In zh, this message translates to:
  /// **'我'**
  String get commonMe;

  /// No description provided for @commonVoiceLoading.
  ///
  /// In zh, this message translates to:
  /// **'語音加載中，請稍後再試'**
  String get commonVoiceLoading;

  /// No description provided for @commonVoiceToTextFailed.
  ///
  /// In zh, this message translates to:
  /// **'語音轉文字失敗'**
  String get commonVoiceToTextFailed;

  /// No description provided for @commonConvertToText.
  ///
  /// In zh, this message translates to:
  /// **'轉文字'**
  String get commonConvertToText;

  /// No description provided for @chatCopy.
  ///
  /// In zh, this message translates to:
  /// **'複製'**
  String get chatCopy;

  /// No description provided for @commonForward.
  ///
  /// In zh, this message translates to:
  /// **'轉發'**
  String get commonForward;

  /// No description provided for @commonUnfavorite.
  ///
  /// In zh, this message translates to:
  /// **'取消收藏'**
  String get commonUnfavorite;

  /// No description provided for @commonFavorite.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get commonFavorite;

  /// No description provided for @settingsResend.
  ///
  /// In zh, this message translates to:
  /// **'重新發送'**
  String get settingsResend;

  /// No description provided for @chatRecall.
  ///
  /// In zh, this message translates to:
  /// **'撤回'**
  String get chatRecall;

  /// No description provided for @commonQuote.
  ///
  /// In zh, this message translates to:
  /// **'引用'**
  String get commonQuote;

  /// No description provided for @commonRemind.
  ///
  /// In zh, this message translates to:
  /// **'提醒'**
  String get commonRemind;

  /// No description provided for @chatCopied.
  ///
  /// In zh, this message translates to:
  /// **'已複製'**
  String get chatCopied;

  /// No description provided for @storySendMessageHint.
  ///
  /// In zh, this message translates to:
  /// **'發送消息'**
  String get storySendMessageHint;

  /// No description provided for @commonMicrophonePermissionRequired.
  ///
  /// In zh, this message translates to:
  /// **'請允許使用麥克風權限'**
  String get commonMicrophonePermissionRequired;

  /// No description provided for @chatMicrophonePermissionDeniedPermanent.
  ///
  /// In zh, this message translates to:
  /// **'麥克風權限已被拒絕，請在系統設置中開啓以使用語音消息功能。'**
  String get chatMicrophonePermissionDeniedPermanent;

  /// No description provided for @commonStartRecordingFailed.
  ///
  /// In zh, this message translates to:
  /// **'開始錄音失敗: {error}'**
  String commonStartRecordingFailed(String error);

  /// No description provided for @commonRecordingTooShort.
  ///
  /// In zh, this message translates to:
  /// **'錄音時間太短'**
  String get commonRecordingTooShort;

  /// No description provided for @commonStopRecordingFailed.
  ///
  /// In zh, this message translates to:
  /// **'停止錄音失敗: {error}'**
  String commonStopRecordingFailed(String error);

  /// No description provided for @chatReleaseToCancel.
  ///
  /// In zh, this message translates to:
  /// **'鬆開取消'**
  String get chatReleaseToCancel;

  /// No description provided for @chatReleaseToSend.
  ///
  /// In zh, this message translates to:
  /// **'鬆開發送，上滑取消'**
  String get chatReleaseToSend;

  /// No description provided for @commonHoldToTalk.
  ///
  /// In zh, this message translates to:
  /// **'按住 說話'**
  String get commonHoldToTalk;

  /// No description provided for @commonSend.
  ///
  /// In zh, this message translates to:
  /// **'發送'**
  String get commonSend;

  /// No description provided for @commonAddFriend.
  ///
  /// In zh, this message translates to:
  /// **'添加好友'**
  String get commonAddFriend;

  /// No description provided for @commonChatServiceNotConnected.
  ///
  /// In zh, this message translates to:
  /// **'聊天服務未連接'**
  String get commonChatServiceNotConnected;

  /// No description provided for @contactUserNotFoundHint.
  ///
  /// In zh, this message translates to:
  /// **'未找到用戶 \"{query}\"\n\n提示：\n• 嘗試輸入完整用戶ID，如 @username:server.com\n• 確認用戶名拼寫正確'**
  String contactUserNotFoundHint(String query);

  /// No description provided for @contactCreateChatFailed.
  ///
  /// In zh, this message translates to:
  /// **'創建會話失敗: {error}'**
  String contactCreateChatFailed(String error);

  /// No description provided for @contactSearchFailed.
  ///
  /// In zh, this message translates to:
  /// **'搜索失敗: {error}'**
  String contactSearchFailed(String error);

  /// No description provided for @contactEnterUserIdOrUsername.
  ///
  /// In zh, this message translates to:
  /// **'輸入用戶 ID 或用戶名搜索'**
  String get contactEnterUserIdOrUsername;

  /// No description provided for @contactSearching.
  ///
  /// In zh, this message translates to:
  /// **'搜索中...'**
  String get contactSearching;

  /// No description provided for @contactSearchUserToChat.
  ///
  /// In zh, this message translates to:
  /// **'搜索用戶開始聊天'**
  String get contactSearchUserToChat;

  /// No description provided for @contactMatrixIdExample.
  ///
  /// In zh, this message translates to:
  /// **'可以輸入完整的 Matrix ID\n例如: @user:matrix.n42.network'**
  String get contactMatrixIdExample;

  /// No description provided for @contactUserNotFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到用戶 \"{username}\"'**
  String contactUserNotFound(String username);

  /// No description provided for @commonChat.
  ///
  /// In zh, this message translates to:
  /// **'聊天'**
  String get commonChat;

  /// No description provided for @commonSettings.
  ///
  /// In zh, this message translates to:
  /// **'設置'**
  String get commonSettings;

  /// No description provided for @profileEditProfile.
  ///
  /// In zh, this message translates to:
  /// **'編輯資料'**
  String get profileEditProfile;

  /// No description provided for @authLogin.
  ///
  /// In zh, this message translates to:
  /// **'登錄'**
  String get authLogin;

  /// No description provided for @commonCreateGroup.
  ///
  /// In zh, this message translates to:
  /// **'創建羣聊'**
  String get commonCreateGroup;

  /// No description provided for @chatError.
  ///
  /// In zh, this message translates to:
  /// **'錯誤'**
  String get chatError;

  /// No description provided for @commonTransfer.
  ///
  /// In zh, this message translates to:
  /// **'轉賬'**
  String get commonTransfer;

  /// No description provided for @commonReceived.
  ///
  /// In zh, this message translates to:
  /// **'已被接收'**
  String get commonReceived;

  /// No description provided for @commonRefunded.
  ///
  /// In zh, this message translates to:
  /// **'已退還'**
  String get commonRefunded;

  /// No description provided for @commonExpired.
  ///
  /// In zh, this message translates to:
  /// **'已過期'**
  String get commonExpired;

  /// No description provided for @chatRedPacketGreeting.
  ///
  /// In zh, this message translates to:
  /// **'恭喜發財，大吉大利'**
  String get chatRedPacketGreeting;

  /// No description provided for @commonN42RedPacket.
  ///
  /// In zh, this message translates to:
  /// **'N42紅包'**
  String get commonN42RedPacket;

  /// No description provided for @commonClaimed.
  ///
  /// In zh, this message translates to:
  /// **'已領取'**
  String get commonClaimed;

  /// No description provided for @commonAllClaimed.
  ///
  /// In zh, this message translates to:
  /// **'已被領完'**
  String get commonAllClaimed;

  /// No description provided for @chatReadAloud.
  ///
  /// In zh, this message translates to:
  /// **'朗讀'**
  String get chatReadAloud;

  /// No description provided for @chatReply.
  ///
  /// In zh, this message translates to:
  /// **'回覆'**
  String get chatReply;

  /// No description provided for @commonEdit.
  ///
  /// In zh, this message translates to:
  /// **'編輯'**
  String get commonEdit;

  /// No description provided for @chatSelectForwardTarget.
  ///
  /// In zh, this message translates to:
  /// **'選擇轉發對象'**
  String get chatSelectForwardTarget;

  /// No description provided for @commonSendCount.
  ///
  /// In zh, this message translates to:
  /// **'發送({count})'**
  String commonSendCount(int count);

  /// No description provided for @contactN42Id.
  ///
  /// In zh, this message translates to:
  /// **'N42號：{id}'**
  String contactN42Id(String id);

  /// No description provided for @profileN42IdTitle.
  ///
  /// In zh, this message translates to:
  /// **'N42號'**
  String get profileN42IdTitle;

  /// No description provided for @profileN42Bean.
  ///
  /// In zh, this message translates to:
  /// **'N42豆'**
  String get profileN42Bean;

  /// No description provided for @contactFriendInfo.
  ///
  /// In zh, this message translates to:
  /// **'朋友資料'**
  String get contactFriendInfo;

  /// No description provided for @contactFriendInfoDesc.
  ///
  /// In zh, this message translates to:
  /// **'添加朋友的備註名、電話、標籤、備忘、照片等，並設置朋友權限。'**
  String get contactFriendInfoDesc;

  /// No description provided for @commonMoments.
  ///
  /// In zh, this message translates to:
  /// **'朋友圈'**
  String get commonMoments;

  /// No description provided for @commonSendMessage.
  ///
  /// In zh, this message translates to:
  /// **'發消息'**
  String get commonSendMessage;

  /// No description provided for @contactAudioVideoCall.
  ///
  /// In zh, this message translates to:
  /// **'音視頻通話'**
  String get contactAudioVideoCall;

  /// No description provided for @contactVideoChannel.
  ///
  /// In zh, this message translates to:
  /// **'視頻號'**
  String get contactVideoChannel;

  /// No description provided for @contactRemark.
  ///
  /// In zh, this message translates to:
  /// **'備註'**
  String get contactRemark;

  /// No description provided for @contactRemarkName.
  ///
  /// In zh, this message translates to:
  /// **'備註名'**
  String get contactRemarkName;

  /// No description provided for @contactPhone.
  ///
  /// In zh, this message translates to:
  /// **'電話'**
  String get contactPhone;

  /// No description provided for @contactTags.
  ///
  /// In zh, this message translates to:
  /// **'標籤'**
  String get contactTags;

  /// No description provided for @contactNotes.
  ///
  /// In zh, this message translates to:
  /// **'備忘'**
  String get contactNotes;

  /// No description provided for @contactPhotos.
  ///
  /// In zh, this message translates to:
  /// **'照片'**
  String get contactPhotos;

  /// No description provided for @contactPermissions.
  ///
  /// In zh, this message translates to:
  /// **'權限'**
  String get contactPermissions;

  /// No description provided for @contactChatMomentsEtc.
  ///
  /// In zh, this message translates to:
  /// **'聊天、朋友圈、運動等'**
  String get contactChatMomentsEtc;

  /// No description provided for @contactMoreInfo.
  ///
  /// In zh, this message translates to:
  /// **'更多信息'**
  String get contactMoreInfo;

  /// No description provided for @contactCommonGroups.
  ///
  /// In zh, this message translates to:
  /// **'我和他 (她) 的共同羣聊'**
  String get contactCommonGroups;

  /// No description provided for @contactSource.
  ///
  /// In zh, this message translates to:
  /// **'來源'**
  String get contactSource;

  /// No description provided for @settingsNotificationSettings.
  ///
  /// In zh, this message translates to:
  /// **'消息通知'**
  String get settingsNotificationSettings;

  /// No description provided for @settingsPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'隱私'**
  String get settingsPrivacy;

  /// No description provided for @settingsAppearance.
  ///
  /// In zh, this message translates to:
  /// **'外觀'**
  String get settingsAppearance;

  /// No description provided for @settingsAbout.
  ///
  /// In zh, this message translates to:
  /// **'關於'**
  String get settingsAbout;

  /// No description provided for @commonLogout.
  ///
  /// In zh, this message translates to:
  /// **'退出登錄'**
  String get commonLogout;

  /// No description provided for @commonLogoutConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定要退出登錄嗎？'**
  String get commonLogoutConfirm;

  /// No description provided for @commonSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get commonSave;

  /// No description provided for @profileNickname.
  ///
  /// In zh, this message translates to:
  /// **'暱稱'**
  String get profileNickname;

  /// No description provided for @profileEnterNickname.
  ///
  /// In zh, this message translates to:
  /// **'請輸入暱稱'**
  String get profileEnterNickname;

  /// No description provided for @profileSignature.
  ///
  /// In zh, this message translates to:
  /// **'簽名'**
  String get profileSignature;

  /// No description provided for @profileAddSignature.
  ///
  /// In zh, this message translates to:
  /// **'添加個性簽名'**
  String get profileAddSignature;

  /// No description provided for @commonTakePhoto.
  ///
  /// In zh, this message translates to:
  /// **'拍照'**
  String get commonTakePhoto;

  /// No description provided for @profileChooseFromGallery.
  ///
  /// In zh, this message translates to:
  /// **'從相冊選擇'**
  String get profileChooseFromGallery;

  /// No description provided for @profileSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失敗: {error}'**
  String profileSaveFailed(String error);

  /// No description provided for @authSecureDecentralizedChat.
  ///
  /// In zh, this message translates to:
  /// **'安全、去中心化的即時通訊'**
  String get authSecureDecentralizedChat;

  /// No description provided for @commonEndToEndEncryption.
  ///
  /// In zh, this message translates to:
  /// **'端到端加密'**
  String get commonEndToEndEncryption;

  /// No description provided for @authMessagesOnlyYouCanSee.
  ///
  /// In zh, this message translates to:
  /// **'消息僅你和對方可見'**
  String get authMessagesOnlyYouCanSee;

  /// No description provided for @authDecentralized.
  ///
  /// In zh, this message translates to:
  /// **'去中心化'**
  String get authDecentralized;

  /// No description provided for @authBasedOnMatrix.
  ///
  /// In zh, this message translates to:
  /// **'基於Matrix開放協議'**
  String get authBasedOnMatrix;

  /// No description provided for @authWalletIntegration.
  ///
  /// In zh, this message translates to:
  /// **'錢包集成'**
  String get authWalletIntegration;

  /// No description provided for @authEasyCryptoTransfer.
  ///
  /// In zh, this message translates to:
  /// **'輕鬆進行加密貨幣轉賬'**
  String get authEasyCryptoTransfer;

  /// No description provided for @authRegister.
  ///
  /// In zh, this message translates to:
  /// **'註冊'**
  String get authRegister;

  /// No description provided for @authAgreeTerms.
  ///
  /// In zh, this message translates to:
  /// **'登錄即表示同意'**
  String get authAgreeTerms;

  /// No description provided for @authTermsOfService.
  ///
  /// In zh, this message translates to:
  /// **'《服務協議》'**
  String get authTermsOfService;

  /// No description provided for @authAnd.
  ///
  /// In zh, this message translates to:
  /// **'和'**
  String get authAnd;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'《隱私政策》'**
  String get authPrivacyPolicy;

  /// No description provided for @authServerAddress.
  ///
  /// In zh, this message translates to:
  /// **'服務器地址'**
  String get authServerAddress;

  /// No description provided for @authEnterServerAddress.
  ///
  /// In zh, this message translates to:
  /// **'請輸入服務器地址'**
  String get authEnterServerAddress;

  /// No description provided for @authConnectedTo.
  ///
  /// In zh, this message translates to:
  /// **'已連接到 {serverName}'**
  String authConnectedTo(String serverName);

  /// No description provided for @authUsername.
  ///
  /// In zh, this message translates to:
  /// **'用戶名'**
  String get authUsername;

  /// No description provided for @authEnterUsername.
  ///
  /// In zh, this message translates to:
  /// **'請輸入用戶名'**
  String get authEnterUsername;

  /// No description provided for @authUsernameOrEmail.
  ///
  /// In zh, this message translates to:
  /// **'用戶名或郵箱'**
  String get authUsernameOrEmail;

  /// No description provided for @authEnterUsernameOrEmail.
  ///
  /// In zh, this message translates to:
  /// **'請輸入用戶名或郵箱'**
  String get authEnterUsernameOrEmail;

  /// No description provided for @authPassword.
  ///
  /// In zh, this message translates to:
  /// **'密碼'**
  String get authPassword;

  /// No description provided for @authEnterPassword.
  ///
  /// In zh, this message translates to:
  /// **'請輸入密碼'**
  String get authEnterPassword;

  /// No description provided for @authRegisterAccount.
  ///
  /// In zh, this message translates to:
  /// **'註冊賬號'**
  String get authRegisterAccount;

  /// No description provided for @authForgotPassword.
  ///
  /// In zh, this message translates to:
  /// **'忘記密碼'**
  String get authForgotPassword;

  /// No description provided for @authOtherLoginMethods.
  ///
  /// In zh, this message translates to:
  /// **'其他登錄方式'**
  String get authOtherLoginMethods;

  /// No description provided for @authCreateAccount.
  ///
  /// In zh, this message translates to:
  /// **'創建賬號'**
  String get authCreateAccount;

  /// No description provided for @authJoinN42Chat.
  ///
  /// In zh, this message translates to:
  /// **'加入 N42 Chat 開始聊天'**
  String get authJoinN42Chat;

  /// No description provided for @authUsernameHint.
  ///
  /// In zh, this message translates to:
  /// **'3-20字符，字母/數字/_'**
  String get authUsernameHint;

  /// No description provided for @authUsernameMinLength.
  ///
  /// In zh, this message translates to:
  /// **'用戶名至少3個字符'**
  String get authUsernameMinLength;

  /// No description provided for @authUsernameMaxLength.
  ///
  /// In zh, this message translates to:
  /// **'用戶名最多20個字符'**
  String get authUsernameMaxLength;

  /// No description provided for @authUsernameFormat.
  ///
  /// In zh, this message translates to:
  /// **'用戶名只能包含字母、數字和下劃線'**
  String get authUsernameFormat;

  /// No description provided for @authPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'至少8位'**
  String get authPasswordHint;

  /// No description provided for @commonPasswordMinLength.
  ///
  /// In zh, this message translates to:
  /// **'密碼至少8位'**
  String get commonPasswordMinLength;

  /// No description provided for @authConfirmPassword.
  ///
  /// In zh, this message translates to:
  /// **'確認密碼'**
  String get authConfirmPassword;

  /// No description provided for @authFilled.
  ///
  /// In zh, this message translates to:
  /// **'已填寫'**
  String get authFilled;

  /// No description provided for @authEnterInviteCode.
  ///
  /// In zh, this message translates to:
  /// **'請輸入邀請碼'**
  String get authEnterInviteCode;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In zh, this message translates to:
  /// **'已有賬號？'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authLoginNow.
  ///
  /// In zh, this message translates to:
  /// **'立即登錄'**
  String get authLoginNow;

  /// No description provided for @profileAvatar.
  ///
  /// In zh, this message translates to:
  /// **'頭像'**
  String get profileAvatar;

  /// No description provided for @profileStatus.
  ///
  /// In zh, this message translates to:
  /// **'狀態'**
  String get profileStatus;

  /// No description provided for @commonLoading.
  ///
  /// In zh, this message translates to:
  /// **'加載中...'**
  String get commonLoading;

  /// No description provided for @conversationNoConversations.
  ///
  /// In zh, this message translates to:
  /// **'暫無會話'**
  String get conversationNoConversations;

  /// No description provided for @conversationTapToChat.
  ///
  /// In zh, this message translates to:
  /// **'點擊右上角開始聊天'**
  String get conversationTapToChat;

  /// No description provided for @conversationStartGroup.
  ///
  /// In zh, this message translates to:
  /// **'發起羣聊'**
  String get conversationStartGroup;

  /// No description provided for @commonScan.
  ///
  /// In zh, this message translates to:
  /// **'掃一掃'**
  String get commonScan;

  /// No description provided for @commonPayment.
  ///
  /// In zh, this message translates to:
  /// **'收付款'**
  String get commonPayment;

  /// No description provided for @commonFeatureComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'{feature} 功能即將推出'**
  String commonFeatureComingSoon(String feature);

  /// No description provided for @conversationMarkAsRead.
  ///
  /// In zh, this message translates to:
  /// **'標記已讀'**
  String get conversationMarkAsRead;

  /// No description provided for @commonUnmute.
  ///
  /// In zh, this message translates to:
  /// **'取消靜音'**
  String get commonUnmute;

  /// No description provided for @commonMute.
  ///
  /// In zh, this message translates to:
  /// **'消息免打擾'**
  String get commonMute;

  /// No description provided for @conversationUnpin.
  ///
  /// In zh, this message translates to:
  /// **'取消置頂'**
  String get conversationUnpin;

  /// No description provided for @conversationPin.
  ///
  /// In zh, this message translates to:
  /// **'置頂'**
  String get conversationPin;

  /// No description provided for @conversationDeleteConversation.
  ///
  /// In zh, this message translates to:
  /// **'刪除會話'**
  String get conversationDeleteConversation;

  /// No description provided for @conversationDeleteConversationConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定要刪除與 {name} 的會話嗎？'**
  String conversationDeleteConversationConfirm(String name);

  /// No description provided for @commonNoContacts.
  ///
  /// In zh, this message translates to:
  /// **'暫無聯繫人'**
  String get commonNoContacts;

  /// No description provided for @contactAddFriendsToChat.
  ///
  /// In zh, this message translates to:
  /// **'添加好友開始聊天'**
  String get contactAddFriendsToChat;

  /// No description provided for @contactNotFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到聯繫人'**
  String get contactNotFound;

  /// No description provided for @contactTryOtherKeywords.
  ///
  /// In zh, this message translates to:
  /// **'嘗試搜索其他關鍵詞或全局搜索'**
  String get contactTryOtherKeywords;

  /// No description provided for @contactSearchResults.
  ///
  /// In zh, this message translates to:
  /// **'搜索結果'**
  String get contactSearchResults;

  /// No description provided for @contactNewFriends.
  ///
  /// In zh, this message translates to:
  /// **'新的朋友'**
  String get contactNewFriends;

  /// No description provided for @contactChatOnlyFriends.
  ///
  /// In zh, this message translates to:
  /// **'僅聊天的朋友'**
  String get contactChatOnlyFriends;

  /// No description provided for @contactOfficialAccounts.
  ///
  /// In zh, this message translates to:
  /// **'公衆號'**
  String get contactOfficialAccounts;

  /// No description provided for @contactServiceAccounts.
  ///
  /// In zh, this message translates to:
  /// **'服務號'**
  String get contactServiceAccounts;

  /// No description provided for @contactEnterpriseContacts.
  ///
  /// In zh, this message translates to:
  /// **'企業聯繫人'**
  String get contactEnterpriseContacts;

  /// No description provided for @contactRecommendToFriend.
  ///
  /// In zh, this message translates to:
  /// **'推薦給朋友'**
  String get contactRecommendToFriend;

  /// No description provided for @commonSetRemark.
  ///
  /// In zh, this message translates to:
  /// **'設置備註'**
  String get commonSetRemark;

  /// No description provided for @contactSendingCard.
  ///
  /// In zh, this message translates to:
  /// **'正在發送名片...'**
  String get contactSendingCard;

  /// No description provided for @commonFileLabel.
  ///
  /// In zh, this message translates to:
  /// **'文件'**
  String get commonFileLabel;

  /// No description provided for @commonLocationLabel.
  ///
  /// In zh, this message translates to:
  /// **'位置'**
  String get commonLocationLabel;

  /// No description provided for @contactRecommendFailed.
  ///
  /// In zh, this message translates to:
  /// **'推薦失敗: {error}'**
  String contactRecommendFailed(String error);

  /// No description provided for @profileEnterRemark.
  ///
  /// In zh, this message translates to:
  /// **'請輸入備註名'**
  String get profileEnterRemark;

  /// No description provided for @contactOpeningChat.
  ///
  /// In zh, this message translates to:
  /// **'正在打開聊天...'**
  String get contactOpeningChat;

  /// No description provided for @contactOpenChatFailed.
  ///
  /// In zh, this message translates to:
  /// **'打開聊天失敗: {error}'**
  String contactOpenChatFailed(String error);

  /// No description provided for @contactAddContact.
  ///
  /// In zh, this message translates to:
  /// **'添加聯繫人'**
  String get contactAddContact;

  /// No description provided for @contactEnterUserId.
  ///
  /// In zh, this message translates to:
  /// **'輸入用戶ID'**
  String get contactEnterUserId;

  /// No description provided for @contactNoFriendRequests.
  ///
  /// In zh, this message translates to:
  /// **'暫無好友請求'**
  String get contactNoFriendRequests;

  /// No description provided for @commonAccept.
  ///
  /// In zh, this message translates to:
  /// **'接受'**
  String get commonAccept;

  /// No description provided for @commonReject.
  ///
  /// In zh, this message translates to:
  /// **'拒絕'**
  String get commonReject;

  /// No description provided for @commonNoGroups.
  ///
  /// In zh, this message translates to:
  /// **'暫無羣聊'**
  String get commonNoGroups;

  /// No description provided for @contactSelectFriendToRecommend.
  ///
  /// In zh, this message translates to:
  /// **'選擇要推薦給的朋友'**
  String get contactSelectFriendToRecommend;

  /// No description provided for @commonSearchContacts.
  ///
  /// In zh, this message translates to:
  /// **'搜索聯繫人'**
  String get commonSearchContacts;

  /// No description provided for @contactNoContactsFound.
  ///
  /// In zh, this message translates to:
  /// **'沒有找到聯繫人'**
  String get contactNoContactsFound;

  /// No description provided for @favoriteYesterday.
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get favoriteYesterday;

  /// No description provided for @chatJustNow.
  ///
  /// In zh, this message translates to:
  /// **'剛剛'**
  String get chatJustNow;

  /// No description provided for @profileOnline.
  ///
  /// In zh, this message translates to:
  /// **'在線'**
  String get profileOnline;

  /// No description provided for @profileOffline.
  ///
  /// In zh, this message translates to:
  /// **'離線'**
  String get profileOffline;

  /// No description provided for @searchContactsGroupsMessages.
  ///
  /// In zh, this message translates to:
  /// **'搜索聯繫人、羣聊和消息'**
  String get searchContactsGroupsMessages;

  /// No description provided for @searchError.
  ///
  /// In zh, this message translates to:
  /// **'搜索出錯'**
  String get searchError;

  /// No description provided for @chatSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get chatSearchHint;

  /// No description provided for @searchHistory.
  ///
  /// In zh, this message translates to:
  /// **'搜索歷史'**
  String get searchHistory;

  /// No description provided for @commonClear.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get commonClear;

  /// No description provided for @commonAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get commonAll;

  /// No description provided for @searchGroups.
  ///
  /// In zh, this message translates to:
  /// **'羣聊'**
  String get searchGroups;

  /// No description provided for @searchNoResults.
  ///
  /// In zh, this message translates to:
  /// **'無結果'**
  String get searchNoResults;

  /// No description provided for @commonGroupMembers.
  ///
  /// In zh, this message translates to:
  /// **'羣成員 ({count})'**
  String commonGroupMembers(int count);

  /// No description provided for @groupMembersTitle.
  ///
  /// In zh, this message translates to:
  /// **'羣成員'**
  String get groupMembersTitle;

  /// No description provided for @groupViewAll.
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get groupViewAll;

  /// No description provided for @groupOwner.
  ///
  /// In zh, this message translates to:
  /// **'羣主'**
  String get groupOwner;

  /// No description provided for @groupAdmin.
  ///
  /// In zh, this message translates to:
  /// **'管理'**
  String get groupAdmin;

  /// No description provided for @groupInvite.
  ///
  /// In zh, this message translates to:
  /// **'邀請'**
  String get groupInvite;

  /// No description provided for @commonGroupAnnouncement.
  ///
  /// In zh, this message translates to:
  /// **'羣公告'**
  String get commonGroupAnnouncement;

  /// No description provided for @commonNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未設置'**
  String get commonNotSet;

  /// No description provided for @groupDescription.
  ///
  /// In zh, this message translates to:
  /// **'羣簡介'**
  String get groupDescription;

  /// No description provided for @groupPublicGroup.
  ///
  /// In zh, this message translates to:
  /// **'公開羣聊'**
  String get groupPublicGroup;

  /// No description provided for @commonClearChatHistory.
  ///
  /// In zh, this message translates to:
  /// **'清空聊天記錄'**
  String get commonClearChatHistory;

  /// No description provided for @commonDissolveGroup.
  ///
  /// In zh, this message translates to:
  /// **'解散羣聊'**
  String get commonDissolveGroup;

  /// No description provided for @commonLeaveGroup.
  ///
  /// In zh, this message translates to:
  /// **'退出羣聊'**
  String get commonLeaveGroup;

  /// No description provided for @groupChangeGroupName.
  ///
  /// In zh, this message translates to:
  /// **'修改羣名稱'**
  String get groupChangeGroupName;

  /// No description provided for @commonEnterGroupName.
  ///
  /// In zh, this message translates to:
  /// **'請輸入羣名稱'**
  String get commonEnterGroupName;

  /// No description provided for @commonConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確認'**
  String get commonConfirm;

  /// No description provided for @groupEnterGroupDescription.
  ///
  /// In zh, this message translates to:
  /// **'請輸入羣簡介'**
  String get groupEnterGroupDescription;

  /// No description provided for @groupPublish.
  ///
  /// In zh, this message translates to:
  /// **'發佈'**
  String get groupPublish;

  /// No description provided for @chatClearHistoryConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定要清空聊天記錄嗎？此操作不可恢復。'**
  String get chatClearHistoryConfirm;

  /// No description provided for @chatClearAction.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get chatClearAction;

  /// No description provided for @commonChatHistoryCleared.
  ///
  /// In zh, this message translates to:
  /// **'聊天記錄已清空'**
  String get commonChatHistoryCleared;

  /// No description provided for @commonDissolve.
  ///
  /// In zh, this message translates to:
  /// **'解散'**
  String get commonDissolve;

  /// No description provided for @groupQrCode.
  ///
  /// In zh, this message translates to:
  /// **'羣二維碼'**
  String get groupQrCode;

  /// No description provided for @commonSearchChatHistory.
  ///
  /// In zh, this message translates to:
  /// **'查找聊天記錄'**
  String get commonSearchChatHistory;

  /// No description provided for @groupIdCopied.
  ///
  /// In zh, this message translates to:
  /// **'羣ID已複製'**
  String get groupIdCopied;

  /// No description provided for @transferEnterOrPasteAddress.
  ///
  /// In zh, this message translates to:
  /// **'輸入或粘貼錢包地址'**
  String get transferEnterOrPasteAddress;

  /// No description provided for @transferSelectToken.
  ///
  /// In zh, this message translates to:
  /// **'選擇代幣'**
  String get transferSelectToken;

  /// No description provided for @commonTransferAmount.
  ///
  /// In zh, this message translates to:
  /// **'轉賬金額'**
  String get commonTransferAmount;

  /// No description provided for @transferAvailable.
  ///
  /// In zh, this message translates to:
  /// **'可用'**
  String get transferAvailable;

  /// No description provided for @transferMemoOptional.
  ///
  /// In zh, this message translates to:
  /// **'備註（可選）'**
  String get transferMemoOptional;

  /// No description provided for @transferConfirmTransfer.
  ///
  /// In zh, this message translates to:
  /// **'確認轉賬'**
  String get transferConfirmTransfer;

  /// No description provided for @transferAddressVerified.
  ///
  /// In zh, this message translates to:
  /// **'地址已驗證'**
  String get transferAddressVerified;

  /// No description provided for @transferAvailableBalance.
  ///
  /// In zh, this message translates to:
  /// **'可用餘額: {balance} {symbol}'**
  String transferAvailableBalance(String balance, String symbol);

  /// No description provided for @commonEnterAmount.
  ///
  /// In zh, this message translates to:
  /// **'請輸入金額'**
  String get commonEnterAmount;

  /// No description provided for @commonRedPacketCountMin.
  ///
  /// In zh, this message translates to:
  /// **'紅包個數至少爲1'**
  String get commonRedPacketCountMin;

  /// No description provided for @commonViewRedPacketDetails.
  ///
  /// In zh, this message translates to:
  /// **'查看紅包詳情'**
  String get commonViewRedPacketDetails;

  /// No description provided for @commonEnterTransferAmount.
  ///
  /// In zh, this message translates to:
  /// **'請輸入轉賬金額'**
  String get commonEnterTransferAmount;

  /// No description provided for @commonTransferTo.
  ///
  /// In zh, this message translates to:
  /// **'轉賬給'**
  String get commonTransferTo;

  /// No description provided for @commonFromSender.
  ///
  /// In zh, this message translates to:
  /// **'來自 {name}'**
  String commonFromSender(String name, Object senderName);

  /// No description provided for @commonConfirmReceive.
  ///
  /// In zh, this message translates to:
  /// **'確認收款'**
  String get commonConfirmReceive;

  /// No description provided for @groupProfile.
  ///
  /// In zh, this message translates to:
  /// **'羣資料'**
  String get groupProfile;

  /// No description provided for @groupRemoveMember.
  ///
  /// In zh, this message translates to:
  /// **'移出羣聊'**
  String get groupRemoveMember;

  /// No description provided for @commonRemove.
  ///
  /// In zh, this message translates to:
  /// **'移出'**
  String get commonRemove;

  /// No description provided for @profileClearStatus.
  ///
  /// In zh, this message translates to:
  /// **'清除狀態'**
  String get profileClearStatus;

  /// No description provided for @profileClearStatusConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定要清除當前狀態嗎？'**
  String get profileClearStatusConfirm;

  /// No description provided for @profileStatusCleared.
  ///
  /// In zh, this message translates to:
  /// **'狀態已清除'**
  String get profileStatusCleared;

  /// No description provided for @profileUserNotExist.
  ///
  /// In zh, this message translates to:
  /// **'用戶不存在'**
  String get profileUserNotExist;

  /// No description provided for @profileUserIdCopied.
  ///
  /// In zh, this message translates to:
  /// **'用戶ID已複製'**
  String get profileUserIdCopied;

  /// No description provided for @commonReport.
  ///
  /// In zh, this message translates to:
  /// **'舉報'**
  String get commonReport;

  /// No description provided for @profileQrCode.
  ///
  /// In zh, this message translates to:
  /// **'二維碼'**
  String get profileQrCode;

  /// No description provided for @profileAvatarUpdated.
  ///
  /// In zh, this message translates to:
  /// **'頭像更新成功'**
  String get profileAvatarUpdated;

  /// No description provided for @commonSelectImageFailed.
  ///
  /// In zh, this message translates to:
  /// **'選擇圖片失敗: {error}'**
  String commonSelectImageFailed(String error);

  /// No description provided for @profileChangeName.
  ///
  /// In zh, this message translates to:
  /// **'修改名字'**
  String get profileChangeName;

  /// No description provided for @profileMale.
  ///
  /// In zh, this message translates to:
  /// **'男'**
  String get profileMale;

  /// No description provided for @profileFemale.
  ///
  /// In zh, this message translates to:
  /// **'女'**
  String get profileFemale;

  /// No description provided for @chatFeatureInDev.
  ///
  /// In zh, this message translates to:
  /// **'{feature}功能開發中...'**
  String chatFeatureInDev(String feature);

  /// No description provided for @profileSaveAddressFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存地址失敗: {error}'**
  String profileSaveAddressFailed(String error);

  /// No description provided for @profileAddNew.
  ///
  /// In zh, this message translates to:
  /// **'新增'**
  String get profileAddNew;

  /// No description provided for @profileAddAddress.
  ///
  /// In zh, this message translates to:
  /// **'添加地址'**
  String get profileAddAddress;

  /// No description provided for @profileAddressAdded.
  ///
  /// In zh, this message translates to:
  /// **'地址添加成功'**
  String get profileAddressAdded;

  /// No description provided for @profileAddressUpdated.
  ///
  /// In zh, this message translates to:
  /// **'地址更新成功'**
  String get profileAddressUpdated;

  /// No description provided for @profileDeleteAddress.
  ///
  /// In zh, this message translates to:
  /// **'刪除地址'**
  String get profileDeleteAddress;

  /// No description provided for @profileAddressDeleted.
  ///
  /// In zh, this message translates to:
  /// **'地址已刪除'**
  String get profileAddressDeleted;

  /// No description provided for @profileSaveInvoiceFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存發票抬頭失敗: {error}'**
  String profileSaveInvoiceFailed(String error);

  /// No description provided for @profileMyInvoices.
  ///
  /// In zh, this message translates to:
  /// **'我的發票抬頭'**
  String get profileMyInvoices;

  /// No description provided for @profileAddInvoice.
  ///
  /// In zh, this message translates to:
  /// **'添加發票抬頭'**
  String get profileAddInvoice;

  /// No description provided for @profileInvoiceAdded.
  ///
  /// In zh, this message translates to:
  /// **'發票抬頭添加成功'**
  String get profileInvoiceAdded;

  /// No description provided for @profileInvoiceUpdated.
  ///
  /// In zh, this message translates to:
  /// **'發票抬頭更新成功'**
  String get profileInvoiceUpdated;

  /// No description provided for @profileDeleteInvoice.
  ///
  /// In zh, this message translates to:
  /// **'刪除發票抬頭'**
  String get profileDeleteInvoice;

  /// No description provided for @profileInvoiceDeleted.
  ///
  /// In zh, this message translates to:
  /// **'發票抬頭已刪除'**
  String get profileInvoiceDeleted;

  /// No description provided for @profilePersonal.
  ///
  /// In zh, this message translates to:
  /// **'個人'**
  String get profilePersonal;

  /// No description provided for @groupSelectAtLeastOne.
  ///
  /// In zh, this message translates to:
  /// **'請至少選擇一位成員'**
  String get groupSelectAtLeastOne;

  /// No description provided for @chatFileNotExist.
  ///
  /// In zh, this message translates to:
  /// **'文件不存在'**
  String get chatFileNotExist;

  /// No description provided for @chatSendFailed.
  ///
  /// In zh, this message translates to:
  /// **'發送失敗: {error}'**
  String chatSendFailed(String error);

  /// No description provided for @chatCannotOpenBrowser.
  ///
  /// In zh, this message translates to:
  /// **'無法打開瀏覽器'**
  String get chatCannotOpenBrowser;

  /// No description provided for @chatSelectFileFailed.
  ///
  /// In zh, this message translates to:
  /// **'選擇文件失敗: {error}'**
  String chatSelectFileFailed(String error);

  /// No description provided for @settingsSetupFailed.
  ///
  /// In zh, this message translates to:
  /// **'設置失敗: {error}'**
  String settingsSetupFailed(String error);

  /// No description provided for @transferEnterValidAmount.
  ///
  /// In zh, this message translates to:
  /// **'請輸入有效的轉賬金額'**
  String get transferEnterValidAmount;

  /// No description provided for @commonAddressCopied.
  ///
  /// In zh, this message translates to:
  /// **'地址已複製'**
  String get commonAddressCopied;

  /// No description provided for @favoriteOpenItem.
  ///
  /// In zh, this message translates to:
  /// **'打開: {content}'**
  String favoriteOpenItem(String content);

  /// No description provided for @favoriteDeleted.
  ///
  /// In zh, this message translates to:
  /// **'已刪除'**
  String get favoriteDeleted;

  /// No description provided for @profileWallet.
  ///
  /// In zh, this message translates to:
  /// **'錢包'**
  String get profileWallet;

  /// No description provided for @chatRecording.
  ///
  /// In zh, this message translates to:
  /// **'錄像'**
  String get chatRecording;

  /// No description provided for @chatInvalidVideoUrl.
  ///
  /// In zh, this message translates to:
  /// **'無效的視頻鏈接'**
  String get chatInvalidVideoUrl;

  /// No description provided for @chatDownloadFile.
  ///
  /// In zh, this message translates to:
  /// **'下載文件'**
  String get chatDownloadFile;

  /// No description provided for @chatClearChatHistoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空聊天記錄'**
  String get chatClearChatHistoryTitle;

  /// No description provided for @chatVideoCall.
  ///
  /// In zh, this message translates to:
  /// **'視頻通話'**
  String get chatVideoCall;

  /// No description provided for @commonVoiceCall.
  ///
  /// In zh, this message translates to:
  /// **'語音通話'**
  String get commonVoiceCall;

  /// No description provided for @callLeaveMeeting.
  ///
  /// In zh, this message translates to:
  /// **'離開會議'**
  String get callLeaveMeeting;

  /// No description provided for @chatDetails.
  ///
  /// In zh, this message translates to:
  /// **'聊天詳情'**
  String get chatDetails;

  /// No description provided for @chatViewAllGroupMembers.
  ///
  /// In zh, this message translates to:
  /// **'查看全部羣成員'**
  String get chatViewAllGroupMembers;

  /// No description provided for @chatGroupName.
  ///
  /// In zh, this message translates to:
  /// **'羣聊名稱'**
  String get chatGroupName;

  /// No description provided for @chatGroupNameUpdated.
  ///
  /// In zh, this message translates to:
  /// **'羣名稱已更新'**
  String get chatGroupNameUpdated;

  /// No description provided for @chatUpdateFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新失敗'**
  String get chatUpdateFailed;

  /// No description provided for @chatNoPermissionToModify.
  ///
  /// In zh, this message translates to:
  /// **'您沒有修改權限'**
  String get chatNoPermissionToModify;

  /// No description provided for @chatGroupManagement.
  ///
  /// In zh, this message translates to:
  /// **'羣管理'**
  String get chatGroupManagement;

  /// No description provided for @chatMyNicknameInGroup.
  ///
  /// In zh, this message translates to:
  /// **'我在本羣的暱稱'**
  String get chatMyNicknameInGroup;

  /// No description provided for @chatPinChat.
  ///
  /// In zh, this message translates to:
  /// **'置頂聊天'**
  String get chatPinChat;

  /// No description provided for @chatStrongReminder.
  ///
  /// In zh, this message translates to:
  /// **'強提醒'**
  String get chatStrongReminder;

  /// No description provided for @chatSetChatBackground.
  ///
  /// In zh, this message translates to:
  /// **'設置當前聊天背景'**
  String get chatSetChatBackground;

  /// No description provided for @chatUnknownFile.
  ///
  /// In zh, this message translates to:
  /// **'未知文件'**
  String get chatUnknownFile;

  /// No description provided for @chatDownload.
  ///
  /// In zh, this message translates to:
  /// **'下載'**
  String get chatDownload;

  /// No description provided for @chatInvalidLocation.
  ///
  /// In zh, this message translates to:
  /// **'無效的位置'**
  String get chatInvalidLocation;

  /// No description provided for @chatTapToCancel.
  ///
  /// In zh, this message translates to:
  /// **'點擊取消'**
  String get chatTapToCancel;

  /// No description provided for @chatCaptureFailed.
  ///
  /// In zh, this message translates to:
  /// **'拍攝失敗: {error}'**
  String chatCaptureFailed(Object error);

  /// No description provided for @chatProcessingVideo.
  ///
  /// In zh, this message translates to:
  /// **'正在處理視頻...'**
  String get chatProcessingVideo;

  /// No description provided for @chatVideoFileNotExist.
  ///
  /// In zh, this message translates to:
  /// **'視頻文件不存在'**
  String get chatVideoFileNotExist;

  /// No description provided for @chatVideoDataEmpty.
  ///
  /// In zh, this message translates to:
  /// **'視頻數據爲空'**
  String get chatVideoDataEmpty;

  /// No description provided for @chatVideoTooLarge.
  ///
  /// In zh, this message translates to:
  /// **'視頻大小不能超過 100MB'**
  String get chatVideoTooLarge;

  /// No description provided for @chatSendingVideo.
  ///
  /// In zh, this message translates to:
  /// **'視頻發送中...'**
  String get chatSendingVideo;

  /// No description provided for @chatSendVideoFailed.
  ///
  /// In zh, this message translates to:
  /// **'發送視頻失敗: {error}'**
  String chatSendVideoFailed(Object error);

  /// No description provided for @chatImageFileNotExist.
  ///
  /// In zh, this message translates to:
  /// **'圖片文件不存在'**
  String get chatImageFileNotExist;

  /// No description provided for @commonImageDataEmpty.
  ///
  /// In zh, this message translates to:
  /// **'圖片數據爲空'**
  String get commonImageDataEmpty;

  /// No description provided for @chatSendingImage.
  ///
  /// In zh, this message translates to:
  /// **'圖片發送中...'**
  String get chatSendingImage;

  /// No description provided for @chatSendImageFailed.
  ///
  /// In zh, this message translates to:
  /// **'發送圖片失敗: {error}'**
  String chatSendImageFailed(Object error);

  /// No description provided for @chatSendLocation.
  ///
  /// In zh, this message translates to:
  /// **'發送位置'**
  String get chatSendLocation;

  /// No description provided for @chatSelectLocationAndSend.
  ///
  /// In zh, this message translates to:
  /// **'選擇地點併發送給對方'**
  String get chatSelectLocationAndSend;

  /// No description provided for @chatShareRealTimeLocation.
  ///
  /// In zh, this message translates to:
  /// **'共享實時位置'**
  String get chatShareRealTimeLocation;

  /// No description provided for @chatShareLocationForOneHour.
  ///
  /// In zh, this message translates to:
  /// **'與好友共享1小時實時位置'**
  String get chatShareLocationForOneHour;

  /// No description provided for @chatLocationSent.
  ///
  /// In zh, this message translates to:
  /// **'位置已發送'**
  String get chatLocationSent;

  /// No description provided for @chatSelectMessages.
  ///
  /// In zh, this message translates to:
  /// **'選擇消息'**
  String get chatSelectMessages;

  /// No description provided for @chatSelectedCount.
  ///
  /// In zh, this message translates to:
  /// **'已選擇 {count}'**
  String chatSelectedCount(int count);

  /// No description provided for @chatSelectAll.
  ///
  /// In zh, this message translates to:
  /// **'全選'**
  String get chatSelectAll;

  /// No description provided for @chatGroupChatCount.
  ///
  /// In zh, this message translates to:
  /// **'羣聊({count})'**
  String chatGroupChatCount(int count);

  /// No description provided for @chatPrivateChat.
  ///
  /// In zh, this message translates to:
  /// **'私聊'**
  String get chatPrivateChat;

  /// No description provided for @chatNoMessages.
  ///
  /// In zh, this message translates to:
  /// **'暫無消息'**
  String get chatNoMessages;

  /// No description provided for @chatSendFirstMessage.
  ///
  /// In zh, this message translates to:
  /// **'發送第一條消息開始聊天'**
  String get chatSendFirstMessage;

  /// No description provided for @chatEncryptionNotice.
  ///
  /// In zh, this message translates to:
  /// **'此聊天已啓用端到端加密。只有您和對方可以閱讀消息。'**
  String get chatEncryptionNotice;

  /// No description provided for @chatMultiForward.
  ///
  /// In zh, this message translates to:
  /// **'轉發'**
  String get chatMultiForward;

  /// No description provided for @chatCollect.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get chatCollect;

  /// No description provided for @chatNoMembers.
  ///
  /// In zh, this message translates to:
  /// **'沒有成員'**
  String get chatNoMembers;

  /// No description provided for @chatMemberNotFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到成員'**
  String get chatMemberNotFound;

  /// No description provided for @chatVoiceFileNotExist.
  ///
  /// In zh, this message translates to:
  /// **'語音文件不存在'**
  String get chatVoiceFileNotExist;

  /// No description provided for @chatVoiceFileEmpty.
  ///
  /// In zh, this message translates to:
  /// **'語音文件爲空'**
  String get chatVoiceFileEmpty;

  /// No description provided for @chatSendingVoice.
  ///
  /// In zh, this message translates to:
  /// **'語音發送中...'**
  String get chatSendingVoice;

  /// No description provided for @chatSendVoiceFailed.
  ///
  /// In zh, this message translates to:
  /// **'發送語音失敗: {error}'**
  String chatSendVoiceFailed(Object error);

  /// No description provided for @chatMessageForwarded.
  ///
  /// In zh, this message translates to:
  /// **'消息已轉發'**
  String get chatMessageForwarded;

  /// No description provided for @chatForwardFailed.
  ///
  /// In zh, this message translates to:
  /// **'轉發失敗: {error}'**
  String chatForwardFailed(Object error);

  /// No description provided for @chatUnfavorited.
  ///
  /// In zh, this message translates to:
  /// **'已取消收藏'**
  String get chatUnfavorited;

  /// No description provided for @chatFavorited.
  ///
  /// In zh, this message translates to:
  /// **'已收藏'**
  String get chatFavorited;

  /// No description provided for @chatReactionAdded.
  ///
  /// In zh, this message translates to:
  /// **'已添加表情回應'**
  String get chatReactionAdded;

  /// No description provided for @chatReactionRemoved.
  ///
  /// In zh, this message translates to:
  /// **'已移除表情回應'**
  String get chatReactionRemoved;

  /// No description provided for @chatFailedMessageDeleted.
  ///
  /// In zh, this message translates to:
  /// **'已刪除失敗消息'**
  String get chatFailedMessageDeleted;

  /// No description provided for @chatDeleteMessages.
  ///
  /// In zh, this message translates to:
  /// **'刪除消息'**
  String get chatDeleteMessages;

  /// No description provided for @chatDeleteMessagesConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定要刪除 {count} 條消息嗎？'**
  String chatDeleteMessagesConfirm(Object count);

  /// No description provided for @chatNoteOtherMessages.
  ///
  /// In zh, this message translates to:
  /// **'注意：{count} 條消息來自他人，僅對你刪除。'**
  String chatNoteOtherMessages(Object count);

  /// No description provided for @chatMyMessagesWillBeRecalled.
  ///
  /// In zh, this message translates to:
  /// **'{count} 條你發送的消息將對所有人撤回。'**
  String chatMyMessagesWillBeRecalled(Object count);

  /// No description provided for @chatRecalledCount.
  ///
  /// In zh, this message translates to:
  /// **'已撤回 {count} 條消息，{localCount} 條僅對你刪除'**
  String chatRecalledCount(Object count, Object localCount);

  /// No description provided for @chatRecalledMessages.
  ///
  /// In zh, this message translates to:
  /// **'已撤回 {count} 條消息'**
  String chatRecalledMessages(Object count);

  /// No description provided for @chatDeletedLocally.
  ///
  /// In zh, this message translates to:
  /// **'{count} 條消息僅對你刪除'**
  String chatDeletedLocally(Object count);

  /// No description provided for @chatForwardedCount.
  ///
  /// In zh, this message translates to:
  /// **'已轉發 {count} 條消息'**
  String chatForwardedCount(Object count);

  /// No description provided for @chatForwardComplete.
  ///
  /// In zh, this message translates to:
  /// **'轉發完成：成功 {success} 條，失敗 {failed} 條'**
  String chatForwardComplete(Object failed, Object success);

  /// No description provided for @chatRemindOnlyInGroup.
  ///
  /// In zh, this message translates to:
  /// **'提醒功能僅在羣聊中可用'**
  String get chatRemindOnlyInGroup;

  /// No description provided for @chatOnlyTextSearchable.
  ///
  /// In zh, this message translates to:
  /// **'僅支持搜索文本消息'**
  String get chatOnlyTextSearchable;

  /// No description provided for @chatSearchFor.
  ///
  /// In zh, this message translates to:
  /// **'搜索 \"{text}\"'**
  String chatSearchFor(Object text);

  /// No description provided for @chatBaiduSearch.
  ///
  /// In zh, this message translates to:
  /// **'百度搜索'**
  String get chatBaiduSearch;

  /// No description provided for @chatGoogleSearch.
  ///
  /// In zh, this message translates to:
  /// **'Google 搜索'**
  String get chatGoogleSearch;

  /// No description provided for @chatBingSearch.
  ///
  /// In zh, this message translates to:
  /// **'必應搜索'**
  String get chatBingSearch;

  /// No description provided for @chatCalling.
  ///
  /// In zh, this message translates to:
  /// **'呼叫中...'**
  String get chatCalling;

  /// No description provided for @chatRinging.
  ///
  /// In zh, this message translates to:
  /// **'響鈴中...'**
  String get chatRinging;

  /// No description provided for @chatInCall.
  ///
  /// In zh, this message translates to:
  /// **'通話中'**
  String get chatInCall;

  /// No description provided for @commonFeatureInDevelopment.
  ///
  /// In zh, this message translates to:
  /// **'{feature}功能開發中...'**
  String commonFeatureInDevelopment(String feature);

  /// No description provided for @chatCollectMessages.
  ///
  /// In zh, this message translates to:
  /// **'已收藏 {count} 條消息'**
  String chatCollectMessages(Object count);

  /// No description provided for @commonMemberCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人'**
  String commonMemberCount(int count);

  /// No description provided for @groupDone.
  ///
  /// In zh, this message translates to:
  /// **'完成({count})'**
  String groupDone(int count);

  /// No description provided for @profileServices.
  ///
  /// In zh, this message translates to:
  /// **'服務'**
  String get profileServices;

  /// No description provided for @commonFavorites.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get commonFavorites;

  /// No description provided for @profileOrdersAndCards.
  ///
  /// In zh, this message translates to:
  /// **'訂單與卡包'**
  String get profileOrdersAndCards;

  /// No description provided for @profileStickers.
  ///
  /// In zh, this message translates to:
  /// **'表情'**
  String get profileStickers;

  /// No description provided for @profileStatusSetTo.
  ///
  /// In zh, this message translates to:
  /// **'狀態已設置爲：{status}'**
  String profileStatusSetTo(String status);

  /// No description provided for @profileAvatarUploadFailed.
  ///
  /// In zh, this message translates to:
  /// **'頭像上傳失敗'**
  String get profileAvatarUploadFailed;

  /// No description provided for @profilePersonalProfile.
  ///
  /// In zh, this message translates to:
  /// **'個人信息'**
  String get profilePersonalProfile;

  /// No description provided for @profileName.
  ///
  /// In zh, this message translates to:
  /// **'名字'**
  String get profileName;

  /// No description provided for @profileGender.
  ///
  /// In zh, this message translates to:
  /// **'性別'**
  String get profileGender;

  /// No description provided for @profileRegion.
  ///
  /// In zh, this message translates to:
  /// **'地區'**
  String get profileRegion;

  /// No description provided for @commonMyQrCode.
  ///
  /// In zh, this message translates to:
  /// **'我的二維碼'**
  String get commonMyQrCode;

  /// No description provided for @profilePoke.
  ///
  /// In zh, this message translates to:
  /// **'拍一拍'**
  String get profilePoke;

  /// No description provided for @profileRingtone.
  ///
  /// In zh, this message translates to:
  /// **'來電鈴聲'**
  String get profileRingtone;

  /// No description provided for @profileDefaultRingtone.
  ///
  /// In zh, this message translates to:
  /// **'默認鈴聲'**
  String get profileDefaultRingtone;

  /// No description provided for @profileMyAddresses.
  ///
  /// In zh, this message translates to:
  /// **'我的地址'**
  String get profileMyAddresses;

  /// No description provided for @profileGenderSetTo.
  ///
  /// In zh, this message translates to:
  /// **'性別已設置爲：{gender}'**
  String profileGenderSetTo(String gender);

  /// No description provided for @profileSelectRegion.
  ///
  /// In zh, this message translates to:
  /// **'選擇地區'**
  String get profileSelectRegion;

  /// No description provided for @profileSelectCity.
  ///
  /// In zh, this message translates to:
  /// **'選擇城市'**
  String get profileSelectCity;

  /// No description provided for @profileRegionSetTo.
  ///
  /// In zh, this message translates to:
  /// **'地區已設置爲：{region}'**
  String profileRegionSetTo(String region);

  /// No description provided for @profileSetPoke.
  ///
  /// In zh, this message translates to:
  /// **'設置拍一拍'**
  String get profileSetPoke;

  /// No description provided for @profileFriendPokedMe.
  ///
  /// In zh, this message translates to:
  /// **'朋友拍了拍我'**
  String get profileFriendPokedMe;

  /// No description provided for @profileExample.
  ///
  /// In zh, this message translates to:
  /// **'示例'**
  String get profileExample;

  /// No description provided for @profileOnTheShoulder.
  ///
  /// In zh, this message translates to:
  /// **'的肩膀'**
  String get profileOnTheShoulder;

  /// No description provided for @profilePokeCleared.
  ///
  /// In zh, this message translates to:
  /// **'拍一拍已清除'**
  String get profilePokeCleared;

  /// No description provided for @profilePokeSetTo.
  ///
  /// In zh, this message translates to:
  /// **'拍一拍已設置爲：拍了拍我{suffix}'**
  String profilePokeSetTo(String suffix);

  /// No description provided for @profileEditSignature.
  ///
  /// In zh, this message translates to:
  /// **'編輯個性簽名'**
  String get profileEditSignature;

  /// No description provided for @profileIntroduceYourself.
  ///
  /// In zh, this message translates to:
  /// **'一句話介紹自己'**
  String get profileIntroduceYourself;

  /// No description provided for @profileSignatureCleared.
  ///
  /// In zh, this message translates to:
  /// **'個性簽名已清除'**
  String get profileSignatureCleared;

  /// No description provided for @profileSignatureUpdated.
  ///
  /// In zh, this message translates to:
  /// **'個性簽名已更新'**
  String get profileSignatureUpdated;

  /// No description provided for @profileScanToAddFriend.
  ///
  /// In zh, this message translates to:
  /// **'掃一掃上面的二維碼圖案，加我爲好友'**
  String get profileScanToAddFriend;

  /// No description provided for @profileRingtoneSetTo.
  ///
  /// In zh, this message translates to:
  /// **'來電鈴聲已設置爲：{ringtone}'**
  String profileRingtoneSetTo(String ringtone);

  /// No description provided for @commonConfirmDissolveGroup.
  ///
  /// In zh, this message translates to:
  /// **'確定要解散羣聊「{name}」嗎？此操作無法撤銷。'**
  String commonConfirmDissolveGroup(String name);

  /// No description provided for @authEnterValidServerAddress.
  ///
  /// In zh, this message translates to:
  /// **'請輸入有效的服務器地址'**
  String get authEnterValidServerAddress;

  /// No description provided for @authEnterServerAddressFirst.
  ///
  /// In zh, this message translates to:
  /// **'請先輸入服務器地址'**
  String get authEnterServerAddressFirst;

  /// No description provided for @authPasskeyRequiresServer.
  ///
  /// In zh, this message translates to:
  /// **'Passkey登錄需要服務器支持'**
  String get authPasskeyRequiresServer;

  /// No description provided for @authLoginAgreement.
  ///
  /// In zh, this message translates to:
  /// **'登錄即表示同意'**
  String get authLoginAgreement;

  /// No description provided for @authPleaseAgreeToTerms.
  ///
  /// In zh, this message translates to:
  /// **'請先閱讀並同意服務協議和隱私政策'**
  String get authPleaseAgreeToTerms;

  /// No description provided for @authRegisterFailed.
  ///
  /// In zh, this message translates to:
  /// **'註冊失敗'**
  String get authRegisterFailed;

  /// No description provided for @commonReenterPassword.
  ///
  /// In zh, this message translates to:
  /// **'請再次輸入密碼'**
  String get commonReenterPassword;

  /// No description provided for @commonPasswordsDoNotMatch.
  ///
  /// In zh, this message translates to:
  /// **'兩次輸入的密碼不一致'**
  String get commonPasswordsDoNotMatch;

  /// No description provided for @authInviteCodeBuiltIn.
  ///
  /// In zh, this message translates to:
  /// **'邀請碼（已內置）'**
  String get authInviteCodeBuiltIn;

  /// No description provided for @authInviteCodeBuiltInNote.
  ///
  /// In zh, this message translates to:
  /// **'邀請碼已內置，通常無需修改'**
  String get authInviteCodeBuiltInNote;

  /// No description provided for @authIHaveReadAndAgree.
  ///
  /// In zh, this message translates to:
  /// **'我已閱讀並同意'**
  String get authIHaveReadAndAgree;

  /// No description provided for @mainStartGroupChat.
  ///
  /// In zh, this message translates to:
  /// **'發起羣聊'**
  String get mainStartGroupChat;

  /// No description provided for @mainAddFriends.
  ///
  /// In zh, this message translates to:
  /// **'添加朋友'**
  String get mainAddFriends;

  /// No description provided for @mainPaymentAndCollection.
  ///
  /// In zh, this message translates to:
  /// **'收付款'**
  String get mainPaymentAndCollection;

  /// No description provided for @contactCount.
  ///
  /// In zh, this message translates to:
  /// **'{count}位聯繫人'**
  String contactCount(int count);

  /// No description provided for @contactAddToHomeScreen.
  ///
  /// In zh, this message translates to:
  /// **'添加到桌面'**
  String get contactAddToHomeScreen;

  /// No description provided for @contactRecommendedCardTo.
  ///
  /// In zh, this message translates to:
  /// **'已將{contact}的名片推薦給{recipient}'**
  String contactRecommendedCardTo(String contact, String recipient);

  /// No description provided for @contactEnterRemarkName.
  ///
  /// In zh, this message translates to:
  /// **'請輸入備註名'**
  String get contactEnterRemarkName;

  /// No description provided for @contactRemarkSetTo.
  ///
  /// In zh, this message translates to:
  /// **'備註已設置爲：{remark}'**
  String contactRemarkSetTo(String remark);

  /// No description provided for @contactAcceptedFriendRequest.
  ///
  /// In zh, this message translates to:
  /// **'已接受{name}的好友請求'**
  String contactAcceptedFriendRequest(String name);

  /// No description provided for @contactRejectedFriendRequest.
  ///
  /// In zh, this message translates to:
  /// **'已拒絕{name}的好友請求'**
  String contactRejectedFriendRequest(String name);

  /// No description provided for @commonGroupInvites.
  ///
  /// In zh, this message translates to:
  /// **'羣邀請'**
  String get commonGroupInvites;

  /// No description provided for @commonMyGroups.
  ///
  /// In zh, this message translates to:
  /// **'我的羣聊 ({count})'**
  String commonMyGroups(int count);

  /// No description provided for @commonInvitedToJoinGroup.
  ///
  /// In zh, this message translates to:
  /// **'邀請加入羣聊'**
  String get commonInvitedToJoinGroup;

  /// No description provided for @commonConfirmLeaveGroup.
  ///
  /// In zh, this message translates to:
  /// **'確定要退出羣聊「{name}」嗎？'**
  String commonConfirmLeaveGroup(String name);

  /// No description provided for @commonLeave.
  ///
  /// In zh, this message translates to:
  /// **'離開'**
  String get commonLeave;

  /// No description provided for @commonRecallThisMessage.
  ///
  /// In zh, this message translates to:
  /// **'撤回該條消息？'**
  String get commonRecallThisMessage;

  /// No description provided for @commonSavedToGallery.
  ///
  /// In zh, this message translates to:
  /// **'已保存到相冊'**
  String get commonSavedToGallery;

  /// No description provided for @commonFailedToSave.
  ///
  /// In zh, this message translates to:
  /// **'保存失敗'**
  String get commonFailedToSave;

  /// No description provided for @chatSaving.
  ///
  /// In zh, this message translates to:
  /// **'保存中...'**
  String get chatSaving;

  /// No description provided for @commonShare.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get commonShare;

  /// No description provided for @chatSaveToGallery.
  ///
  /// In zh, this message translates to:
  /// **'保存到相冊'**
  String get chatSaveToGallery;

  /// No description provided for @chatDownloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'下載失敗: {code}'**
  String chatDownloadFailed(String code);

  /// No description provided for @commonShareFailed.
  ///
  /// In zh, this message translates to:
  /// **'分享失敗: {error}'**
  String commonShareFailed(String error);

  /// No description provided for @chatFailedToLoadImage.
  ///
  /// In zh, this message translates to:
  /// **'圖片加載失敗'**
  String get chatFailedToLoadImage;

  /// No description provided for @chatVideoRecordingFailed.
  ///
  /// In zh, this message translates to:
  /// **'視頻錄製失敗，請重試'**
  String get chatVideoRecordingFailed;

  /// No description provided for @profileRedPacket.
  ///
  /// In zh, this message translates to:
  /// **'紅包'**
  String get profileRedPacket;

  /// No description provided for @commonMusic.
  ///
  /// In zh, this message translates to:
  /// **'音樂'**
  String get commonMusic;

  /// No description provided for @commonCoupon.
  ///
  /// In zh, this message translates to:
  /// **'卡券'**
  String get commonCoupon;

  /// No description provided for @commonGift.
  ///
  /// In zh, this message translates to:
  /// **'禮物'**
  String get commonGift;

  /// No description provided for @commonPoll.
  ///
  /// In zh, this message translates to:
  /// **'投票'**
  String get commonPoll;

  /// No description provided for @favoriteText.
  ///
  /// In zh, this message translates to:
  /// **'文本'**
  String get favoriteText;

  /// No description provided for @favoriteLinkLabel.
  ///
  /// In zh, this message translates to:
  /// **'鏈接'**
  String get favoriteLinkLabel;

  /// No description provided for @favoriteNote.
  ///
  /// In zh, this message translates to:
  /// **'筆記'**
  String get favoriteNote;

  /// No description provided for @favoriteMyNotes.
  ///
  /// In zh, this message translates to:
  /// **'我的筆記'**
  String get favoriteMyNotes;

  /// No description provided for @favoriteToday.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get favoriteToday;

  /// No description provided for @favoriteDaysAgoText.
  ///
  /// In zh, this message translates to:
  /// **'{count}天前'**
  String favoriteDaysAgoText(int count);

  /// No description provided for @favoriteDateFormat.
  ///
  /// In zh, this message translates to:
  /// **'{month}月{day}日'**
  String favoriteDateFormat(int month, int day);

  /// No description provided for @favoriteNoFavorites.
  ///
  /// In zh, this message translates to:
  /// **'暫無收藏'**
  String get favoriteNoFavorites;

  /// No description provided for @favoriteLongPressToFavorite.
  ///
  /// In zh, this message translates to:
  /// **'長按消息進行收藏'**
  String get favoriteLongPressToFavorite;

  /// No description provided for @favoriteNewNote.
  ///
  /// In zh, this message translates to:
  /// **'新建筆記'**
  String get favoriteNewNote;

  /// No description provided for @favoriteLink.
  ///
  /// In zh, this message translates to:
  /// **'收藏鏈接'**
  String get favoriteLink;

  /// No description provided for @favoriteEditTags.
  ///
  /// In zh, this message translates to:
  /// **'編輯標籤'**
  String get favoriteEditTags;

  /// No description provided for @favoriteDeleteFavorite.
  ///
  /// In zh, this message translates to:
  /// **'刪除收藏'**
  String get favoriteDeleteFavorite;

  /// No description provided for @favoriteDeleteFavoriteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定要刪除這條收藏嗎？'**
  String get favoriteDeleteFavoriteConfirm;

  /// No description provided for @favoriteNoSearchResultsFound.
  ///
  /// In zh, this message translates to:
  /// **'沒有找到結果'**
  String get favoriteNoSearchResultsFound;

  /// No description provided for @commonSendRedPacket.
  ///
  /// In zh, this message translates to:
  /// **'發紅包'**
  String get commonSendRedPacket;

  /// No description provided for @transferAmount.
  ///
  /// In zh, this message translates to:
  /// **'金額'**
  String get transferAmount;

  /// No description provided for @commonRedPacketCover.
  ///
  /// In zh, this message translates to:
  /// **'紅包封面'**
  String get commonRedPacketCover;

  /// No description provided for @commonRedPacketType.
  ///
  /// In zh, this message translates to:
  /// **'紅包類型'**
  String get commonRedPacketType;

  /// No description provided for @commonNormalRedPacket.
  ///
  /// In zh, this message translates to:
  /// **'普通紅包'**
  String get commonNormalRedPacket;

  /// No description provided for @commonLuckyRedPacket.
  ///
  /// In zh, this message translates to:
  /// **'拼手氣'**
  String get commonLuckyRedPacket;

  /// No description provided for @commonRedPacketCount.
  ///
  /// In zh, this message translates to:
  /// **'紅包個數'**
  String get commonRedPacketCount;

  /// No description provided for @commonPieces.
  ///
  /// In zh, this message translates to:
  /// **'個'**
  String get commonPieces;

  /// No description provided for @commonPutMoneyInRedPacket.
  ///
  /// In zh, this message translates to:
  /// **'塞錢進紅包'**
  String get commonPutMoneyInRedPacket;

  /// No description provided for @commonRedPacketRefundNotice.
  ///
  /// In zh, this message translates to:
  /// **'未領取的紅包，將於24小時後發起退款'**
  String get commonRedPacketRefundNotice;

  /// No description provided for @commonOpenRedPacket.
  ///
  /// In zh, this message translates to:
  /// **'開'**
  String get commonOpenRedPacket;

  /// No description provided for @commonRedPacketAllClaimed.
  ///
  /// In zh, this message translates to:
  /// **'紅包已被領完'**
  String get commonRedPacketAllClaimed;

  /// No description provided for @commonRedPacketExpired.
  ///
  /// In zh, this message translates to:
  /// **'紅包已過期'**
  String get commonRedPacketExpired;

  /// No description provided for @commonAddTransferNote.
  ///
  /// In zh, this message translates to:
  /// **'添加轉賬說明'**
  String get commonAddTransferNote;

  /// No description provided for @commonYuan.
  ///
  /// In zh, this message translates to:
  /// **'元'**
  String get commonYuan;

  /// No description provided for @commonReplyWithEmoji.
  ///
  /// In zh, this message translates to:
  /// **'用此表情回覆'**
  String get commonReplyWithEmoji;

  /// No description provided for @contactEditRemark.
  ///
  /// In zh, this message translates to:
  /// **'編輯備註'**
  String get contactEditRemark;

  /// No description provided for @contactSetPermissions.
  ///
  /// In zh, this message translates to:
  /// **'設置權限'**
  String get contactSetPermissions;

  /// No description provided for @profileAddToBlacklist.
  ///
  /// In zh, this message translates to:
  /// **'加入黑名單'**
  String get profileAddToBlacklist;

  /// No description provided for @contactDeleteContact.
  ///
  /// In zh, this message translates to:
  /// **'刪除聯繫人'**
  String get contactDeleteContact;

  /// No description provided for @contactDeleteContactConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定要刪除 {name} 嗎？'**
  String contactDeleteContactConfirm(String name);

  /// No description provided for @transferTitle.
  ///
  /// In zh, this message translates to:
  /// **'轉賬'**
  String get transferTitle;

  /// No description provided for @transferReceiverAddressLabel.
  ///
  /// In zh, this message translates to:
  /// **'收款地址'**
  String get transferReceiverAddressLabel;

  /// No description provided for @transferSelectTokenLabel.
  ///
  /// In zh, this message translates to:
  /// **'選擇代幣'**
  String get transferSelectTokenLabel;

  /// No description provided for @transferAmountLabel.
  ///
  /// In zh, this message translates to:
  /// **'轉賬金額'**
  String get transferAmountLabel;

  /// No description provided for @transferMemoLabel.
  ///
  /// In zh, this message translates to:
  /// **'備註（可選）'**
  String get transferMemoLabel;

  /// No description provided for @transferAddMemoHint.
  ///
  /// In zh, this message translates to:
  /// **'添加備註信息'**
  String get transferAddMemoHint;

  /// No description provided for @transferSendPaymentRequest.
  ///
  /// In zh, this message translates to:
  /// **'發送收款請求'**
  String get transferSendPaymentRequest;

  /// No description provided for @transferQrCodeGenerateFailed.
  ///
  /// In zh, this message translates to:
  /// **'二維碼生成失敗'**
  String get transferQrCodeGenerateFailed;

  /// No description provided for @transferScanQrToPayMe.
  ///
  /// In zh, this message translates to:
  /// **'掃描二維碼向我付款'**
  String get transferScanQrToPayMe;

  /// No description provided for @transferMyWalletAddress.
  ///
  /// In zh, this message translates to:
  /// **'我的錢包地址'**
  String get transferMyWalletAddress;

  /// No description provided for @transferCreatePaymentRequest.
  ///
  /// In zh, this message translates to:
  /// **'創建收款請求'**
  String get transferCreatePaymentRequest;

  /// No description provided for @profileN42IdLabel.
  ///
  /// In zh, this message translates to:
  /// **'N42號：{id}'**
  String profileN42IdLabel(String id);

  /// No description provided for @commonRedPacketDefaultGreeting.
  ///
  /// In zh, this message translates to:
  /// **'恭喜發財，大吉大利'**
  String get commonRedPacketDefaultGreeting;

  /// No description provided for @commonSenderRedPacket.
  ///
  /// In zh, this message translates to:
  /// **'{name}的紅包'**
  String commonSenderRedPacket(String name);

  /// No description provided for @transferEnterValidAddress.
  ///
  /// In zh, this message translates to:
  /// **'請輸入有效的收款地址'**
  String get transferEnterValidAddress;

  /// No description provided for @transferPleaseSelectToken.
  ///
  /// In zh, this message translates to:
  /// **'請選擇代幣'**
  String get transferPleaseSelectToken;

  /// No description provided for @commonReceivedTransfer.
  ///
  /// In zh, this message translates to:
  /// **'收到轉賬'**
  String get commonReceivedTransfer;

  /// No description provided for @commonSenderSentRedPacket.
  ///
  /// In zh, this message translates to:
  /// **'{name}發出的紅包'**
  String commonSenderSentRedPacket(String name);

  /// No description provided for @commonSavedToBalance.
  ///
  /// In zh, this message translates to:
  /// **'已存入零錢，可直接轉賬'**
  String get commonSavedToBalance;

  /// No description provided for @commonRedPacketExpiredOrEmpty.
  ///
  /// In zh, this message translates to:
  /// **'紅包已過期/已領完'**
  String get commonRedPacketExpiredOrEmpty;

  /// No description provided for @transferScanFeatureComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'掃描功能開發中...'**
  String get transferScanFeatureComingSoon;

  /// No description provided for @contactSetAsStarred.
  ///
  /// In zh, this message translates to:
  /// **'設爲星標朋友'**
  String get contactSetAsStarred;

  /// No description provided for @contactAddToBlocklist.
  ///
  /// In zh, this message translates to:
  /// **'加入黑名單'**
  String get contactAddToBlocklist;

  /// No description provided for @commonClaimedYour.
  ///
  /// In zh, this message translates to:
  /// **'領取了你的'**
  String get commonClaimedYour;

  /// No description provided for @commonClaimedText.
  ///
  /// In zh, this message translates to:
  /// **'領取了'**
  String get commonClaimedText;

  /// No description provided for @commonUserTyping.
  ///
  /// In zh, this message translates to:
  /// **'{name}正在輸入...'**
  String commonUserTyping(String name);

  /// No description provided for @commonTyping.
  ///
  /// In zh, this message translates to:
  /// **'對方正在輸入...'**
  String get commonTyping;

  /// No description provided for @commonWaitingToReceive.
  ///
  /// In zh, this message translates to:
  /// **'待對方接收'**
  String get commonWaitingToReceive;

  /// No description provided for @commonTapToClaim.
  ///
  /// In zh, this message translates to:
  /// **'點擊領取'**
  String get commonTapToClaim;

  /// No description provided for @commonHasBeenReceived.
  ///
  /// In zh, this message translates to:
  /// **'已被接收'**
  String get commonHasBeenReceived;

  /// No description provided for @commonGetLucky.
  ///
  /// In zh, this message translates to:
  /// **'領個好彩頭'**
  String get commonGetLucky;

  /// No description provided for @qrcodeCameraStartFailed.
  ///
  /// In zh, this message translates to:
  /// **'相機啓動失敗'**
  String get qrcodeCameraStartFailed;

  /// No description provided for @qrcodeUnknownError.
  ///
  /// In zh, this message translates to:
  /// **'未知錯誤'**
  String get qrcodeUnknownError;

  /// No description provided for @qrcodePlaceQrCodeInFrame.
  ///
  /// In zh, this message translates to:
  /// **'將二維碼放入框內掃描'**
  String get qrcodePlaceQrCodeInFrame;

  /// No description provided for @qrcodeCloseManualInput.
  ///
  /// In zh, this message translates to:
  /// **'關閉手動輸入'**
  String get qrcodeCloseManualInput;

  /// No description provided for @qrcodeManualInputUserId.
  ///
  /// In zh, this message translates to:
  /// **'手動輸入用戶ID'**
  String get qrcodeManualInputUserId;

  /// No description provided for @commonAdd.
  ///
  /// In zh, this message translates to:
  /// **'加入'**
  String get commonAdd;

  /// No description provided for @profileSetStatus.
  ///
  /// In zh, this message translates to:
  /// **'設置狀態'**
  String get profileSetStatus;

  /// No description provided for @profileVisibleToFriends24h.
  ///
  /// In zh, this message translates to:
  /// **'可被好友看到，24小時後自動清除'**
  String get profileVisibleToFriends24h;

  /// No description provided for @profileWriteStatus.
  ///
  /// In zh, this message translates to:
  /// **'寫狀態'**
  String get profileWriteStatus;

  /// No description provided for @profileEnterYourStatus.
  ///
  /// In zh, this message translates to:
  /// **'輸入你的狀態...'**
  String get profileEnterYourStatus;

  /// No description provided for @profileOk.
  ///
  /// In zh, this message translates to:
  /// **'確定'**
  String get profileOk;

  /// No description provided for @qrcodeCameraPermissionRequired.
  ///
  /// In zh, this message translates to:
  /// **'掃描二維碼需要相機權限'**
  String get qrcodeCameraPermissionRequired;

  /// No description provided for @qrcodeCameraPermissionDenied.
  ///
  /// In zh, this message translates to:
  /// **'相機權限已被永久拒絕，請在系統設置中開啓。'**
  String get qrcodeCameraPermissionDenied;

  /// No description provided for @qrcodePermissionCheckError.
  ///
  /// In zh, this message translates to:
  /// **'檢查權限時出錯: {error}'**
  String qrcodePermissionCheckError(String error);

  /// No description provided for @qrcodeInvalidQrCode.
  ///
  /// In zh, this message translates to:
  /// **'無效的二維碼'**
  String get qrcodeInvalidQrCode;

  /// No description provided for @qrcodeCannotAddFriend.
  ///
  /// In zh, this message translates to:
  /// **'無法添加好友: {error}'**
  String qrcodeCannotAddFriend(String error);

  /// No description provided for @qrcodeScanQrCode.
  ///
  /// In zh, this message translates to:
  /// **'掃描二維碼'**
  String get qrcodeScanQrCode;

  /// No description provided for @qrcodeCheckingCameraPermission.
  ///
  /// In zh, this message translates to:
  /// **'正在檢查相機權限...'**
  String get qrcodeCheckingCameraPermission;

  /// No description provided for @qrcodeNeedCameraPermission.
  ///
  /// In zh, this message translates to:
  /// **'需要相機權限'**
  String get qrcodeNeedCameraPermission;

  /// No description provided for @qrcodeRetryPermission.
  ///
  /// In zh, this message translates to:
  /// **'重試'**
  String get qrcodeRetryPermission;

  /// No description provided for @qrcodeOpenSettings.
  ///
  /// In zh, this message translates to:
  /// **'打開設置'**
  String get qrcodeOpenSettings;

  /// No description provided for @groupInviteMembers.
  ///
  /// In zh, this message translates to:
  /// **'邀請成員'**
  String get groupInviteMembers;

  /// No description provided for @groupInviteCount.
  ///
  /// In zh, this message translates to:
  /// **'邀請({count})'**
  String groupInviteCount(int count);

  /// No description provided for @profileNoShippingAddress.
  ///
  /// In zh, this message translates to:
  /// **'暫無收貨地址'**
  String get profileNoShippingAddress;

  /// No description provided for @profileDefaultLabel.
  ///
  /// In zh, this message translates to:
  /// **'默認'**
  String get profileDefaultLabel;

  /// No description provided for @profileNoInvoice.
  ///
  /// In zh, this message translates to:
  /// **'暫無發票抬頭'**
  String get profileNoInvoice;

  /// No description provided for @profileCompany.
  ///
  /// In zh, this message translates to:
  /// **'企業'**
  String get profileCompany;

  /// No description provided for @profileTaxNumber.
  ///
  /// In zh, this message translates to:
  /// **'稅號'**
  String get profileTaxNumber;

  /// No description provided for @profileConfirmDeleteAddress.
  ///
  /// In zh, this message translates to:
  /// **'確定要刪除這個地址嗎？'**
  String get profileConfirmDeleteAddress;

  /// No description provided for @profileConfirmDeleteInvoice.
  ///
  /// In zh, this message translates to:
  /// **'確定要刪除這個發票抬頭嗎？'**
  String get profileConfirmDeleteInvoice;

  /// No description provided for @commonGroupOwner.
  ///
  /// In zh, this message translates to:
  /// **'羣主'**
  String get commonGroupOwner;

  /// No description provided for @commonGroupAdmin.
  ///
  /// In zh, this message translates to:
  /// **'管理員'**
  String get commonGroupAdmin;

  /// No description provided for @groupSearchMembers.
  ///
  /// In zh, this message translates to:
  /// **'搜索成員'**
  String get groupSearchMembers;

  /// No description provided for @groupTotalMembers.
  ///
  /// In zh, this message translates to:
  /// **'{count}位成員'**
  String groupTotalMembers(int count);

  /// No description provided for @chatRemoveFromGroup.
  ///
  /// In zh, this message translates to:
  /// **'移出羣聊'**
  String get chatRemoveFromGroup;

  /// No description provided for @groupConfirmRemoveMember.
  ///
  /// In zh, this message translates to:
  /// **'確定要將\"{name}\"移出羣聊嗎？'**
  String groupConfirmRemoveMember(String name);

  /// No description provided for @chatUnknownSong.
  ///
  /// In zh, this message translates to:
  /// **'未知歌曲'**
  String get chatUnknownSong;

  /// No description provided for @chatUnknownArtist.
  ///
  /// In zh, this message translates to:
  /// **'未知藝術家'**
  String get chatUnknownArtist;

  /// No description provided for @chatUnknownContact.
  ///
  /// In zh, this message translates to:
  /// **'未知聯繫人'**
  String get chatUnknownContact;

  /// No description provided for @chatPersonalCard.
  ///
  /// In zh, this message translates to:
  /// **'個人名片'**
  String get chatPersonalCard;

  /// No description provided for @chatSingleChoice.
  ///
  /// In zh, this message translates to:
  /// **'單選'**
  String get chatSingleChoice;

  /// No description provided for @chatMultiChoice.
  ///
  /// In zh, this message translates to:
  /// **'多選'**
  String get chatMultiChoice;

  /// No description provided for @chatEnded.
  ///
  /// In zh, this message translates to:
  /// **'已結束'**
  String get chatEnded;

  /// No description provided for @chatEndPollButton.
  ///
  /// In zh, this message translates to:
  /// **'結束投票'**
  String get chatEndPollButton;

  /// No description provided for @chatPollHint.
  ///
  /// In zh, this message translates to:
  /// **'投票發起後將顯示在聊天中，羣成員可以參與投票'**
  String get chatPollHint;

  /// No description provided for @chatSearchSongOrArtist.
  ///
  /// In zh, this message translates to:
  /// **'搜索歌曲或歌手'**
  String get chatSearchSongOrArtist;

  /// No description provided for @chatNoSongsFound.
  ///
  /// In zh, this message translates to:
  /// **'沒有找到歌曲'**
  String get chatNoSongsFound;

  /// No description provided for @chatSongNameOptional.
  ///
  /// In zh, this message translates to:
  /// **'歌曲名稱（可選）'**
  String get chatSongNameOptional;

  /// No description provided for @chatEnterSongName.
  ///
  /// In zh, this message translates to:
  /// **'輸入歌曲名稱'**
  String get chatEnterSongName;

  /// No description provided for @chatArtistNameOptional.
  ///
  /// In zh, this message translates to:
  /// **'歌手名稱（可選）'**
  String get chatArtistNameOptional;

  /// No description provided for @chatEnterArtistName.
  ///
  /// In zh, this message translates to:
  /// **'輸入歌手名稱'**
  String get chatEnterArtistName;

  /// No description provided for @chatRealTimeLocationSharing.
  ///
  /// In zh, this message translates to:
  /// **'實時位置共享功能開發中...'**
  String get chatRealTimeLocationSharing;

  /// No description provided for @profileVoiceCallFeatureInDev.
  ///
  /// In zh, this message translates to:
  /// **'語音通話功能開發中...'**
  String get profileVoiceCallFeatureInDev;

  /// No description provided for @profileReportFeatureInDev.
  ///
  /// In zh, this message translates to:
  /// **'舉報功能開發中...'**
  String get profileReportFeatureInDev;

  /// No description provided for @profileShareFeatureInDev.
  ///
  /// In zh, this message translates to:
  /// **'分享功能開發中...'**
  String get profileShareFeatureInDev;

  /// No description provided for @profileQrCodeFeatureInDev.
  ///
  /// In zh, this message translates to:
  /// **'二維碼功能開發中...'**
  String get profileQrCodeFeatureInDev;

  /// No description provided for @qrcodeScanQrToAddMe.
  ///
  /// In zh, this message translates to:
  /// **'掃一掃上面的二維碼，加我爲好友'**
  String get qrcodeScanQrToAddMe;

  /// No description provided for @qrcodeSaveToAlbum.
  ///
  /// In zh, this message translates to:
  /// **'保存到相冊'**
  String get qrcodeSaveToAlbum;

  /// No description provided for @qrcodeChangeStyle.
  ///
  /// In zh, this message translates to:
  /// **'換個樣式'**
  String get qrcodeChangeStyle;

  /// No description provided for @qrcodeCopyId.
  ///
  /// In zh, this message translates to:
  /// **'複製 ID'**
  String get qrcodeCopyId;

  /// No description provided for @qrcodeIdCopied.
  ///
  /// In zh, this message translates to:
  /// **'已複製用戶 ID'**
  String get qrcodeIdCopied;

  /// No description provided for @qrcodeMoreStylesFeatureComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'更多樣式即將推出'**
  String get qrcodeMoreStylesFeatureComingSoon;

  /// No description provided for @profileBio.
  ///
  /// In zh, this message translates to:
  /// **'個性簽名'**
  String get profileBio;

  /// No description provided for @profileHomeServer.
  ///
  /// In zh, this message translates to:
  /// **'服務器'**
  String get profileHomeServer;

  /// No description provided for @profileShareContactCard.
  ///
  /// In zh, this message translates to:
  /// **'分享名片'**
  String get profileShareContactCard;

  /// No description provided for @profileRemoveFromBlacklist.
  ///
  /// In zh, this message translates to:
  /// **'移出黑名單'**
  String get profileRemoveFromBlacklist;

  /// No description provided for @profileConfirmAddBlacklist.
  ///
  /// In zh, this message translates to:
  /// **'確定將該用戶加入黑名單嗎？你將不再收到對方的消息'**
  String get profileConfirmAddBlacklist;

  /// No description provided for @profileConfirmRemoveBlacklist.
  ///
  /// In zh, this message translates to:
  /// **'確定將該用戶移出黑名單嗎？'**
  String get profileConfirmRemoveBlacklist;

  /// No description provided for @profileRemarkSaved.
  ///
  /// In zh, this message translates to:
  /// **'備註已保存'**
  String get profileRemarkSaved;

  /// No description provided for @profileRemarkCleared.
  ///
  /// In zh, this message translates to:
  /// **'已清除備註'**
  String get profileRemarkCleared;

  /// No description provided for @transferReceive.
  ///
  /// In zh, this message translates to:
  /// **'收款'**
  String get transferReceive;

  /// No description provided for @transferPleaseConnectWallet.
  ///
  /// In zh, this message translates to:
  /// **'請先連接錢包'**
  String get transferPleaseConnectWallet;

  /// No description provided for @transferSendRequest.
  ///
  /// In zh, this message translates to:
  /// **'發送請求'**
  String get transferSendRequest;

  /// No description provided for @transferPleaseEnterValidAmount.
  ///
  /// In zh, this message translates to:
  /// **'請輸入有效的金額'**
  String get transferPleaseEnterValidAmount;

  /// No description provided for @searchPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'搜索聯繫人、羣聊、消息'**
  String get searchPlaceholder;

  /// No description provided for @searchEnterKeywordToSearch.
  ///
  /// In zh, this message translates to:
  /// **'輸入關鍵詞開始搜索'**
  String get searchEnterKeywordToSearch;

  /// No description provided for @searchClearHistory.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get searchClearHistory;

  /// No description provided for @searchNoResultsForQuery.
  ///
  /// In zh, this message translates to:
  /// **'沒有找到\"{query}\"相關的結果'**
  String searchNoResultsForQuery(String query);

  /// No description provided for @searchAllResults.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get searchAllResults;

  /// No description provided for @searchInChat.
  ///
  /// In zh, this message translates to:
  /// **'在聊天中搜索'**
  String get searchInChat;

  /// No description provided for @searchContactLabel.
  ///
  /// In zh, this message translates to:
  /// **'聯繫人'**
  String get searchContactLabel;

  /// No description provided for @searchGroupLabel.
  ///
  /// In zh, this message translates to:
  /// **'羣聊'**
  String get searchGroupLabel;

  /// No description provided for @searchConversationLabel.
  ///
  /// In zh, this message translates to:
  /// **'會話'**
  String get searchConversationLabel;

  /// No description provided for @searchMessageLabel.
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get searchMessageLabel;

  /// No description provided for @settingsSecurityTitle.
  ///
  /// In zh, this message translates to:
  /// **'安全'**
  String get settingsSecurityTitle;

  /// No description provided for @settingsKeyBackup.
  ///
  /// In zh, this message translates to:
  /// **'密鑰備份'**
  String get settingsKeyBackup;

  /// No description provided for @settingsBackupEncryptionKeys.
  ///
  /// In zh, this message translates to:
  /// **'備份加密密鑰'**
  String get settingsBackupEncryptionKeys;

  /// No description provided for @settingsKeysBackedUp.
  ///
  /// In zh, this message translates to:
  /// **'已備份 {count} 個密鑰'**
  String settingsKeysBackedUp(int count);

  /// No description provided for @settingsBackupNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未設置備份'**
  String get settingsBackupNotSet;

  /// No description provided for @settingsRestoreKeys.
  ///
  /// In zh, this message translates to:
  /// **'恢復密鑰'**
  String get settingsRestoreKeys;

  /// No description provided for @settingsRestoreKeysFromBackup.
  ///
  /// In zh, this message translates to:
  /// **'從備份恢復加密密鑰'**
  String get settingsRestoreKeysFromBackup;

  /// No description provided for @settingsExportKeys.
  ///
  /// In zh, this message translates to:
  /// **'導出密鑰'**
  String get settingsExportKeys;

  /// No description provided for @settingsExportKeysToFile.
  ///
  /// In zh, this message translates to:
  /// **'導出密鑰到文件'**
  String get settingsExportKeysToFile;

  /// No description provided for @settingsLoggedInDevices.
  ///
  /// In zh, this message translates to:
  /// **'已登錄設備'**
  String get settingsLoggedInDevices;

  /// No description provided for @settingsNoOtherDevices.
  ///
  /// In zh, this message translates to:
  /// **'暫無其他設備'**
  String get settingsNoOtherDevices;

  /// No description provided for @settingsVerified.
  ///
  /// In zh, this message translates to:
  /// **'已驗證'**
  String get settingsVerified;

  /// No description provided for @settingsUnverified.
  ///
  /// In zh, this message translates to:
  /// **'未驗證'**
  String get settingsUnverified;

  /// No description provided for @settingsAdvanced.
  ///
  /// In zh, this message translates to:
  /// **'高級'**
  String get settingsAdvanced;

  /// No description provided for @settingsCrossSigning.
  ///
  /// In zh, this message translates to:
  /// **'跨設備簽名'**
  String get settingsCrossSigning;

  /// No description provided for @settingsEnabled.
  ///
  /// In zh, this message translates to:
  /// **'已啓用'**
  String get settingsEnabled;

  /// No description provided for @settingsNotEnabled.
  ///
  /// In zh, this message translates to:
  /// **'未啓用'**
  String get settingsNotEnabled;

  /// No description provided for @settingsResetEncryption.
  ///
  /// In zh, this message translates to:
  /// **'重置加密'**
  String get settingsResetEncryption;

  /// No description provided for @settingsDeleteAllEncryptionKeys.
  ///
  /// In zh, this message translates to:
  /// **'刪除所有加密密鑰'**
  String get settingsDeleteAllEncryptionKeys;

  /// No description provided for @settingsEncryptionNotSupported.
  ///
  /// In zh, this message translates to:
  /// **'不支持加密'**
  String get settingsEncryptionNotSupported;

  /// No description provided for @settingsNotInitialized.
  ///
  /// In zh, this message translates to:
  /// **'未初始化'**
  String get settingsNotInitialized;

  /// No description provided for @settingsBackupKeyTitle.
  ///
  /// In zh, this message translates to:
  /// **'備份密鑰'**
  String get settingsBackupKeyTitle;

  /// No description provided for @settingsBackupKeyMessage.
  ///
  /// In zh, this message translates to:
  /// **'是否創建新的密鑰備份？這將幫助您在新設備上恢復加密消息。'**
  String get settingsBackupKeyMessage;

  /// No description provided for @settingsBackup.
  ///
  /// In zh, this message translates to:
  /// **'備份'**
  String get settingsBackup;

  /// No description provided for @settingsRestoreKeyTitle.
  ///
  /// In zh, this message translates to:
  /// **'恢復密鑰'**
  String get settingsRestoreKeyTitle;

  /// No description provided for @settingsRestoreKeyMessage.
  ///
  /// In zh, this message translates to:
  /// **'輸入您的恢復密碼或恢復密鑰來恢復加密消息。'**
  String get settingsRestoreKeyMessage;

  /// No description provided for @settingsRestore.
  ///
  /// In zh, this message translates to:
  /// **'恢復'**
  String get settingsRestore;

  /// No description provided for @settingsExportKeyTitle.
  ///
  /// In zh, this message translates to:
  /// **'導出密鑰'**
  String get settingsExportKeyTitle;

  /// No description provided for @settingsExportKeyMessage.
  ///
  /// In zh, this message translates to:
  /// **'導出的密鑰文件包含您的所有加密密鑰，請妥善保管。'**
  String get settingsExportKeyMessage;

  /// No description provided for @settingsExport.
  ///
  /// In zh, this message translates to:
  /// **'導出'**
  String get settingsExport;

  /// No description provided for @settingsDeviceIdLabel.
  ///
  /// In zh, this message translates to:
  /// **'設備ID: {deviceId}'**
  String settingsDeviceIdLabel(String deviceId);

  /// No description provided for @settingsDeviceStatusVerified.
  ///
  /// In zh, this message translates to:
  /// **'狀態: 已驗證'**
  String get settingsDeviceStatusVerified;

  /// No description provided for @settingsDeviceStatusUnverified.
  ///
  /// In zh, this message translates to:
  /// **'狀態: 未驗證'**
  String get settingsDeviceStatusUnverified;

  /// No description provided for @settingsLastActiveLabel.
  ///
  /// In zh, this message translates to:
  /// **'最後活躍: {lastSeen}'**
  String settingsLastActiveLabel(String lastSeen);

  /// No description provided for @settingsVerifyThisDevice.
  ///
  /// In zh, this message translates to:
  /// **'驗證此設備'**
  String get settingsVerifyThisDevice;

  /// No description provided for @settingsCrossSigningAlreadyEnabled.
  ///
  /// In zh, this message translates to:
  /// **'跨設備簽名已啓用'**
  String get settingsCrossSigningAlreadyEnabled;

  /// No description provided for @settingsCrossSigningSetupSuccess.
  ///
  /// In zh, this message translates to:
  /// **'跨設備簽名設置成功'**
  String get settingsCrossSigningSetupSuccess;

  /// No description provided for @settingsResetEncryptionTitle.
  ///
  /// In zh, this message translates to:
  /// **'重置加密'**
  String get settingsResetEncryptionTitle;

  /// No description provided for @settingsResetEncryptionWarning.
  ///
  /// In zh, this message translates to:
  /// **'警告：這將刪除您所有的加密密鑰。您將無法解密之前的加密消息。此操作不可撤銷。'**
  String get settingsResetEncryptionWarning;

  /// No description provided for @settingsReset.
  ///
  /// In zh, this message translates to:
  /// **'重置'**
  String get settingsReset;

  /// No description provided for @settingsBackupSuccess.
  ///
  /// In zh, this message translates to:
  /// **'密鑰備份成功'**
  String get settingsBackupSuccess;

  /// No description provided for @settingsBackupFailed.
  ///
  /// In zh, this message translates to:
  /// **'備份失敗'**
  String get settingsBackupFailed;

  /// No description provided for @settingsRecoveryKey.
  ///
  /// In zh, this message translates to:
  /// **'恢復密鑰'**
  String get settingsRecoveryKey;

  /// No description provided for @settingsRecoveryKeySaveWarning.
  ///
  /// In zh, this message translates to:
  /// **'請將此恢復密鑰保存在安全的地方。您需要它在新設備上恢復加密消息。'**
  String get settingsRecoveryKeySaveWarning;

  /// No description provided for @settingsRecoveryKeySaved.
  ///
  /// In zh, this message translates to:
  /// **'我已保存'**
  String get settingsRecoveryKeySaved;

  /// No description provided for @settingsRestoreSuccess.
  ///
  /// In zh, this message translates to:
  /// **'密鑰恢復成功'**
  String get settingsRestoreSuccess;

  /// No description provided for @settingsRestoreFailed.
  ///
  /// In zh, this message translates to:
  /// **'恢復失敗'**
  String get settingsRestoreFailed;

  /// No description provided for @settingsPassword.
  ///
  /// In zh, this message translates to:
  /// **'密碼'**
  String get settingsPassword;

  /// No description provided for @settingsEnterRecoveryKey.
  ///
  /// In zh, this message translates to:
  /// **'輸入恢復密鑰'**
  String get settingsEnterRecoveryKey;

  /// No description provided for @settingsEnterPassword.
  ///
  /// In zh, this message translates to:
  /// **'輸入密碼'**
  String get settingsEnterPassword;

  /// No description provided for @settingsExportSuccess.
  ///
  /// In zh, this message translates to:
  /// **'密鑰已成功導出到服務端備份'**
  String get settingsExportSuccess;

  /// No description provided for @settingsExportNeedBackupFirst.
  ///
  /// In zh, this message translates to:
  /// **'請先創建密鑰備份'**
  String get settingsExportNeedBackupFirst;

  /// No description provided for @settingsExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'導出失敗'**
  String get settingsExportFailed;

  /// No description provided for @settingsResetSuccess.
  ///
  /// In zh, this message translates to:
  /// **'加密重置成功'**
  String get settingsResetSuccess;

  /// No description provided for @settingsResetFailed.
  ///
  /// In zh, this message translates to:
  /// **'重置失敗'**
  String get settingsResetFailed;

  /// No description provided for @callLeaveMeetingConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定要離開會議嗎？'**
  String get callLeaveMeetingConfirm;

  /// No description provided for @chatPokedSomeone.
  ///
  /// In zh, this message translates to:
  /// **'拍了拍「{name}」{suffix}'**
  String chatPokedSomeone(String name, String suffix);

  /// No description provided for @chatNoContactsToAdd.
  ///
  /// In zh, this message translates to:
  /// **'沒有可添加的聯繫人'**
  String get chatNoContactsToAdd;

  /// No description provided for @chatAddMembers.
  ///
  /// In zh, this message translates to:
  /// **'添加成員'**
  String get chatAddMembers;

  /// No description provided for @chatInvitedMembers.
  ///
  /// In zh, this message translates to:
  /// **'已邀請 {count} 位成員'**
  String chatInvitedMembers(int count);

  /// No description provided for @chatInviteFailed.
  ///
  /// In zh, this message translates to:
  /// **'邀請失敗: {error}'**
  String chatInviteFailed(String error);

  /// No description provided for @chatMemberRemoved.
  ///
  /// In zh, this message translates to:
  /// **'已移除成員'**
  String get chatMemberRemoved;

  /// No description provided for @chatRemoveFailed.
  ///
  /// In zh, this message translates to:
  /// **'移除失敗: {error}'**
  String chatRemoveFailed(String error);

  /// No description provided for @chatRealTimeLocationShareMessage.
  ///
  /// In zh, this message translates to:
  /// **'開始共享後，對方將能看到你的實時位置，共享時長爲1小時。'**
  String get chatRealTimeLocationShareMessage;

  /// No description provided for @chatStartSharing.
  ///
  /// In zh, this message translates to:
  /// **'開始共享'**
  String get chatStartSharing;

  /// No description provided for @chatLocationServiceNotEnabled.
  ///
  /// In zh, this message translates to:
  /// **'位置服務未開啓'**
  String get chatLocationServiceNotEnabled;

  /// No description provided for @chatEnableLocationService.
  ///
  /// In zh, this message translates to:
  /// **'請開啓位置服務以使用位置功能'**
  String get chatEnableLocationService;

  /// No description provided for @chatGoToSettings.
  ///
  /// In zh, this message translates to:
  /// **'去設置'**
  String get chatGoToSettings;

  /// No description provided for @chatLocationPermissionRequired.
  ///
  /// In zh, this message translates to:
  /// **'需要位置權限才能使用此功能'**
  String get chatLocationPermissionRequired;

  /// No description provided for @chatLocationPermissionDeniedPermanent.
  ///
  /// In zh, this message translates to:
  /// **'位置權限已被永久拒絕，請在設置中開啓'**
  String get chatLocationPermissionDeniedPermanent;

  /// No description provided for @chatLocationPermissionDenied.
  ///
  /// In zh, this message translates to:
  /// **'位置權限被拒絕'**
  String get chatLocationPermissionDenied;

  /// No description provided for @chatGettingLocation.
  ///
  /// In zh, this message translates to:
  /// **'正在獲取位置...'**
  String get chatGettingLocation;

  /// No description provided for @chatGetLocationFailed.
  ///
  /// In zh, this message translates to:
  /// **'獲取位置失敗: {error}'**
  String chatGetLocationFailed(String error);

  /// No description provided for @chatMapPreview.
  ///
  /// In zh, this message translates to:
  /// **'地圖預覽'**
  String get chatMapPreview;

  /// No description provided for @chatSearchLocation.
  ///
  /// In zh, this message translates to:
  /// **'搜索地點'**
  String get chatSearchLocation;

  /// No description provided for @chatRedPacketSent.
  ///
  /// In zh, this message translates to:
  /// **'已發送 {amount} {token} 紅包'**
  String chatRedPacketSent(String amount, String token);

  /// No description provided for @chatTransferDefault.
  ///
  /// In zh, this message translates to:
  /// **'轉賬'**
  String get chatTransferDefault;

  /// No description provided for @chatTransferSent.
  ///
  /// In zh, this message translates to:
  /// **'已發送 {amount} {token} 轉賬'**
  String chatTransferSent(String amount, String token);

  /// No description provided for @chatPickFileFailed.
  ///
  /// In zh, this message translates to:
  /// **'選擇文件失敗: {error}'**
  String chatPickFileFailed(String error);

  /// No description provided for @chatFileSizeLimit.
  ///
  /// In zh, this message translates to:
  /// **'文件大小不能超過 50MB'**
  String get chatFileSizeLimit;

  /// No description provided for @chatFileSending.
  ///
  /// In zh, this message translates to:
  /// **'文件發送中: {filename}'**
  String chatFileSending(String filename);

  /// No description provided for @chatSendFileFailed.
  ///
  /// In zh, this message translates to:
  /// **'發送文件失敗: {error}'**
  String chatSendFileFailed(String error);

  /// No description provided for @chatContactCardSent.
  ///
  /// In zh, this message translates to:
  /// **'已發送 {name} 的名片'**
  String chatContactCardSent(String name);

  /// No description provided for @chatFavoritesFeature.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get chatFavoritesFeature;

  /// No description provided for @chatCouponsFeature.
  ///
  /// In zh, this message translates to:
  /// **'卡券'**
  String get chatCouponsFeature;

  /// No description provided for @chatGiftFeature.
  ///
  /// In zh, this message translates to:
  /// **'禮物'**
  String get chatGiftFeature;

  /// No description provided for @chatSharedMusic.
  ///
  /// In zh, this message translates to:
  /// **'已分享 {name}'**
  String chatSharedMusic(String name);

  /// No description provided for @chatEndPollTitle.
  ///
  /// In zh, this message translates to:
  /// **'結束投票'**
  String get chatEndPollTitle;

  /// No description provided for @chatEndPollConfirmMessage.
  ///
  /// In zh, this message translates to:
  /// **'確定要結束這個投票嗎？結束後將無法繼續投票。'**
  String get chatEndPollConfirmMessage;

  /// No description provided for @chatPollEndedMessage.
  ///
  /// In zh, this message translates to:
  /// **'投票已結束'**
  String get chatPollEndedMessage;

  /// No description provided for @chatConnectingCall.
  ///
  /// In zh, this message translates to:
  /// **'正在連接...'**
  String get chatConnectingCall;

  /// No description provided for @chatMuteCall.
  ///
  /// In zh, this message translates to:
  /// **'靜音'**
  String get chatMuteCall;

  /// No description provided for @chatSpeakerOff.
  ///
  /// In zh, this message translates to:
  /// **'關閉免提'**
  String get chatSpeakerOff;

  /// No description provided for @chatSpeakerOn.
  ///
  /// In zh, this message translates to:
  /// **'免提'**
  String get chatSpeakerOn;

  /// No description provided for @chatCameraOn.
  ///
  /// In zh, this message translates to:
  /// **'開啓攝像頭'**
  String get chatCameraOn;

  /// No description provided for @chatCameraOff.
  ///
  /// In zh, this message translates to:
  /// **'關閉攝像頭'**
  String get chatCameraOff;

  /// No description provided for @chatHangUp.
  ///
  /// In zh, this message translates to:
  /// **'掛斷'**
  String get chatHangUp;

  /// No description provided for @chatSelectForwardTargetTitle.
  ///
  /// In zh, this message translates to:
  /// **'選擇轉發對象'**
  String get chatSelectForwardTargetTitle;

  /// No description provided for @chatNoForwardableChat.
  ///
  /// In zh, this message translates to:
  /// **'沒有可轉發的會話'**
  String get chatNoForwardableChat;

  /// No description provided for @chatNoMatchingChat.
  ///
  /// In zh, this message translates to:
  /// **'沒有找到相關會話'**
  String get chatNoMatchingChat;

  /// No description provided for @chatLocationTitle.
  ///
  /// In zh, this message translates to:
  /// **'位置'**
  String get chatLocationTitle;

  /// No description provided for @chatSendButton.
  ///
  /// In zh, this message translates to:
  /// **'發送'**
  String get chatSendButton;

  /// No description provided for @chatRetryButton.
  ///
  /// In zh, this message translates to:
  /// **'重試'**
  String get chatRetryButton;

  /// No description provided for @chatSearchContactHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索聯繫人'**
  String get chatSearchContactHint;

  /// No description provided for @chatShareMusic.
  ///
  /// In zh, this message translates to:
  /// **'分享音樂'**
  String get chatShareMusic;

  /// No description provided for @chatRecentPlayed.
  ///
  /// In zh, this message translates to:
  /// **'最近播放'**
  String get chatRecentPlayed;

  /// No description provided for @chatMyFavorites.
  ///
  /// In zh, this message translates to:
  /// **'我喜歡'**
  String get chatMyFavorites;

  /// No description provided for @chatNetworkLink.
  ///
  /// In zh, this message translates to:
  /// **'網絡鏈接'**
  String get chatNetworkLink;

  /// No description provided for @chatLocalFile.
  ///
  /// In zh, this message translates to:
  /// **'本地文件'**
  String get chatLocalFile;

  /// No description provided for @chatPasteMusicLink.
  ///
  /// In zh, this message translates to:
  /// **'粘貼音樂鏈接'**
  String get chatPasteMusicLink;

  /// No description provided for @chatShareMusicButton.
  ///
  /// In zh, this message translates to:
  /// **'分享音樂'**
  String get chatShareMusicButton;

  /// No description provided for @chatSelectLocalAudio.
  ///
  /// In zh, this message translates to:
  /// **'選擇本地音頻文件'**
  String get chatSelectLocalAudio;

  /// No description provided for @chatSupportedAudioFormats.
  ///
  /// In zh, this message translates to:
  /// **'支持 MP3、M4A、WAV、FLAC 等格式'**
  String get chatSupportedAudioFormats;

  /// No description provided for @chatSelectFileButton.
  ///
  /// In zh, this message translates to:
  /// **'選擇文件'**
  String get chatSelectFileButton;

  /// No description provided for @chatPleaseEnterMusicLink.
  ///
  /// In zh, this message translates to:
  /// **'請輸入音樂鏈接'**
  String get chatPleaseEnterMusicLink;

  /// No description provided for @chatPleaseEnterValidLink.
  ///
  /// In zh, this message translates to:
  /// **'請輸入有效的網絡鏈接'**
  String get chatPleaseEnterValidLink;

  /// No description provided for @chatSharedSong.
  ///
  /// In zh, this message translates to:
  /// **'分享歌曲'**
  String get chatSharedSong;

  /// No description provided for @chatSelectMember.
  ///
  /// In zh, this message translates to:
  /// **'選擇成員'**
  String get chatSelectMember;

  /// No description provided for @chatSearchMemberHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索成員'**
  String get chatSearchMemberHint;

  /// No description provided for @chatNoMatchingMembers.
  ///
  /// In zh, this message translates to:
  /// **'未找到匹配的成員'**
  String get chatNoMatchingMembers;

  /// No description provided for @commonUnknownMember.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get commonUnknownMember;

  /// No description provided for @chatSelectedMessagesCount.
  ///
  /// In zh, this message translates to:
  /// **'已選擇 {count} 條消息'**
  String chatSelectedMessagesCount(int count);

  /// No description provided for @chatSearchContactsOrGroups.
  ///
  /// In zh, this message translates to:
  /// **'搜索聯繫人或羣聊'**
  String get chatSearchContactsOrGroups;

  /// No description provided for @chatVideoTitle.
  ///
  /// In zh, this message translates to:
  /// **'視頻'**
  String get chatVideoTitle;

  /// No description provided for @chatLoadingText.
  ///
  /// In zh, this message translates to:
  /// **'加載中...'**
  String get chatLoadingText;

  /// No description provided for @chatVideoLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'視頻加載失敗'**
  String get chatVideoLoadFailed;

  /// No description provided for @chatPlayerInitFailed.
  ///
  /// In zh, this message translates to:
  /// **'播放器初始化失敗'**
  String get chatPlayerInitFailed;

  /// No description provided for @chatCreatePollTitle.
  ///
  /// In zh, this message translates to:
  /// **'創建投票'**
  String get chatCreatePollTitle;

  /// No description provided for @chatSubmitPoll.
  ///
  /// In zh, this message translates to:
  /// **'發起'**
  String get chatSubmitPoll;

  /// No description provided for @chatPollQuestionLabel.
  ///
  /// In zh, this message translates to:
  /// **'投票問題'**
  String get chatPollQuestionLabel;

  /// No description provided for @chatEnterPollQuestionHint.
  ///
  /// In zh, this message translates to:
  /// **'請輸入投票問題'**
  String get chatEnterPollQuestionHint;

  /// No description provided for @chatPollOptionsLabel.
  ///
  /// In zh, this message translates to:
  /// **'投票選項'**
  String get chatPollOptionsLabel;

  /// No description provided for @chatOptionHintWithIndex.
  ///
  /// In zh, this message translates to:
  /// **'選項 {index}'**
  String chatOptionHintWithIndex(int index);

  /// No description provided for @chatAddOptionButton.
  ///
  /// In zh, this message translates to:
  /// **'添加選項'**
  String get chatAddOptionButton;

  /// No description provided for @chatPollSettingsLabel.
  ///
  /// In zh, this message translates to:
  /// **'投票設置'**
  String get chatPollSettingsLabel;

  /// No description provided for @chatSelectionType.
  ///
  /// In zh, this message translates to:
  /// **'選擇類型'**
  String get chatSelectionType;

  /// No description provided for @chatSingleChoiceLabel.
  ///
  /// In zh, this message translates to:
  /// **'單選'**
  String get chatSingleChoiceLabel;

  /// No description provided for @chatMultiChoiceLabel.
  ///
  /// In zh, this message translates to:
  /// **'多選'**
  String get chatMultiChoiceLabel;

  /// No description provided for @chatAnonymousPollSwitch.
  ///
  /// In zh, this message translates to:
  /// **'匿名投票'**
  String get chatAnonymousPollSwitch;

  /// No description provided for @chatPleaseEnterQuestion.
  ///
  /// In zh, this message translates to:
  /// **'請輸入投票問題'**
  String get chatPleaseEnterQuestion;

  /// No description provided for @chatAtLeastTwoOptions.
  ///
  /// In zh, this message translates to:
  /// **'至少需要2個選項'**
  String get chatAtLeastTwoOptions;

  /// No description provided for @chatConfirmWithCount.
  ///
  /// In zh, this message translates to:
  /// **'確定 ({count})'**
  String chatConfirmWithCount(int count);

  /// No description provided for @authEmailVerificationTitle.
  ///
  /// In zh, this message translates to:
  /// **'郵箱驗證'**
  String get authEmailVerificationTitle;

  /// No description provided for @authEnterValidEmailAddress.
  ///
  /// In zh, this message translates to:
  /// **'請輸入有效的郵箱地址'**
  String get authEnterValidEmailAddress;

  /// No description provided for @authVerificationCodeSentTo.
  ///
  /// In zh, this message translates to:
  /// **'驗證碼已發送到 {email}'**
  String authVerificationCodeSentTo(String email);

  /// No description provided for @authSendCodeFailed.
  ///
  /// In zh, this message translates to:
  /// **'發送驗證碼失敗: {error}'**
  String authSendCodeFailed(String error);

  /// No description provided for @authVerificationSuccess.
  ///
  /// In zh, this message translates to:
  /// **'驗證成功'**
  String get authVerificationSuccess;

  /// No description provided for @authVerificationFailed.
  ///
  /// In zh, this message translates to:
  /// **'驗證失敗'**
  String get authVerificationFailed;

  /// No description provided for @authVerificationCodeError.
  ///
  /// In zh, this message translates to:
  /// **'驗證碼錯誤: {error}'**
  String authVerificationCodeError(String error);

  /// No description provided for @commonEnterVerificationCode.
  ///
  /// In zh, this message translates to:
  /// **'輸入驗證碼'**
  String get commonEnterVerificationCode;

  /// No description provided for @authEnterYourEmail.
  ///
  /// In zh, this message translates to:
  /// **'輸入郵箱'**
  String get authEnterYourEmail;

  /// No description provided for @authWeSentCodeTo.
  ///
  /// In zh, this message translates to:
  /// **'我們已向 {email} 發送了\n6位驗證碼'**
  String authWeSentCodeTo(String email);

  /// No description provided for @authEnterEmailForCode.
  ///
  /// In zh, this message translates to:
  /// **'輸入您的郵箱地址，我們將發送驗證碼'**
  String get authEnterEmailForCode;

  /// No description provided for @commonSendVerificationCode.
  ///
  /// In zh, this message translates to:
  /// **'發送驗證碼'**
  String get commonSendVerificationCode;

  /// No description provided for @authResendVerificationCode.
  ///
  /// In zh, this message translates to:
  /// **'重新發送驗證碼'**
  String get authResendVerificationCode;

  /// No description provided for @authCanResendAfter.
  ///
  /// In zh, this message translates to:
  /// **'{seconds}秒後可重新發送'**
  String authCanResendAfter(int seconds);

  /// No description provided for @commonChangeEmail.
  ///
  /// In zh, this message translates to:
  /// **'更換郵箱'**
  String get commonChangeEmail;

  /// No description provided for @contactAddToContacts.
  ///
  /// In zh, this message translates to:
  /// **'添加到通訊錄'**
  String get contactAddToContacts;

  /// No description provided for @contactAddingToContacts.
  ///
  /// In zh, this message translates to:
  /// **'添加中...'**
  String get contactAddingToContacts;

  /// No description provided for @contactAddedToContacts.
  ///
  /// In zh, this message translates to:
  /// **'已添加到通訊錄'**
  String get contactAddedToContacts;

  /// No description provided for @contactAddFailedWithError.
  ///
  /// In zh, this message translates to:
  /// **'添加失敗: {error}'**
  String contactAddFailedWithError(String error);

  /// No description provided for @contactAddPhone.
  ///
  /// In zh, this message translates to:
  /// **'添加電話'**
  String get contactAddPhone;

  /// No description provided for @contactAddTag.
  ///
  /// In zh, this message translates to:
  /// **'添加標籤'**
  String get contactAddTag;

  /// No description provided for @contactAddText.
  ///
  /// In zh, this message translates to:
  /// **'添加文字'**
  String get contactAddText;

  /// No description provided for @contactAddPhoto.
  ///
  /// In zh, this message translates to:
  /// **'添加照片'**
  String get contactAddPhoto;

  /// No description provided for @contactGroupCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'{count}個'**
  String contactGroupCountLabel(int count);

  /// No description provided for @contactAddedViaSearch.
  ///
  /// In zh, this message translates to:
  /// **'通過搜索添加'**
  String get contactAddedViaSearch;

  /// No description provided for @contactAddTime.
  ///
  /// In zh, this message translates to:
  /// **'添加時間'**
  String get contactAddTime;

  /// No description provided for @contactDoneButton.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get contactDoneButton;

  /// No description provided for @callWaitingForParticipants.
  ///
  /// In zh, this message translates to:
  /// **'等待參與者加入...'**
  String get callWaitingForParticipants;

  /// No description provided for @callParticipantMe.
  ///
  /// In zh, this message translates to:
  /// **'{name}（我）'**
  String callParticipantMe(String name);

  /// No description provided for @callSharingLabel.
  ///
  /// In zh, this message translates to:
  /// **'共享中'**
  String get callSharingLabel;

  /// No description provided for @callScreenSharingBy.
  ///
  /// In zh, this message translates to:
  /// **'{name} 正在共享屏幕'**
  String callScreenSharingBy(String name);

  /// No description provided for @callParticipantCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人'**
  String callParticipantCount(int count);

  /// No description provided for @callMuteLabel.
  ///
  /// In zh, this message translates to:
  /// **'靜音'**
  String get callMuteLabel;

  /// No description provided for @callUnmuteLabel.
  ///
  /// In zh, this message translates to:
  /// **'解除靜音'**
  String get callUnmuteLabel;

  /// No description provided for @callTurnOffVideo.
  ///
  /// In zh, this message translates to:
  /// **'關閉視頻'**
  String get callTurnOffVideo;

  /// No description provided for @callTurnOnVideo.
  ///
  /// In zh, this message translates to:
  /// **'開啓視頻'**
  String get callTurnOnVideo;

  /// No description provided for @callShareScreen.
  ///
  /// In zh, this message translates to:
  /// **'共享屏幕'**
  String get callShareScreen;

  /// No description provided for @callStopSharing.
  ///
  /// In zh, this message translates to:
  /// **'停止共享'**
  String get callStopSharing;

  /// No description provided for @callSwitchCameraLabel.
  ///
  /// In zh, this message translates to:
  /// **'切換'**
  String get callSwitchCameraLabel;

  /// No description provided for @callLeaveLabel.
  ///
  /// In zh, this message translates to:
  /// **'離開'**
  String get callLeaveLabel;

  /// No description provided for @callParticipantsLabel.
  ///
  /// In zh, this message translates to:
  /// **'參與者'**
  String get callParticipantsLabel;

  /// No description provided for @callJoiningMeeting.
  ///
  /// In zh, this message translates to:
  /// **'正在加入會議...'**
  String get callJoiningMeeting;

  /// No description provided for @chatPollVotesFormat.
  ///
  /// In zh, this message translates to:
  /// **'{count} 票 ({percentage}%)'**
  String chatPollVotesFormat(int count, String percentage);

  /// No description provided for @chatPollParticipantsFormat.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人蔘與'**
  String chatPollParticipantsFormat(int count);

  /// No description provided for @commonTapToRetry.
  ///
  /// In zh, this message translates to:
  /// **'點擊重試'**
  String get commonTapToRetry;

  /// No description provided for @chatDefaultRedPacketGreeting.
  ///
  /// In zh, this message translates to:
  /// **'恭喜發財，大吉大利'**
  String get chatDefaultRedPacketGreeting;

  /// No description provided for @groupAllowOthersToSearchAndJoin.
  ///
  /// In zh, this message translates to:
  /// **'允許他人搜索並加入'**
  String get groupAllowOthersToSearchAndJoin;

  /// No description provided for @groupConfirmClearChatHistory.
  ///
  /// In zh, this message translates to:
  /// **'確定要清空聊天記錄嗎？'**
  String get groupConfirmClearChatHistory;

  /// No description provided for @groupCreateGroupToChat.
  ///
  /// In zh, this message translates to:
  /// **'創建羣聊以開始聊天'**
  String get groupCreateGroupToChat;

  /// No description provided for @groupEditGroupAnnouncement.
  ///
  /// In zh, this message translates to:
  /// **'編輯羣公告'**
  String get groupEditGroupAnnouncement;

  /// No description provided for @groupEditGroupDescription.
  ///
  /// In zh, this message translates to:
  /// **'編輯羣描述'**
  String get groupEditGroupDescription;

  /// No description provided for @groupEnterGroupAnnouncement.
  ///
  /// In zh, this message translates to:
  /// **'請輸入羣公告'**
  String get groupEnterGroupAnnouncement;

  /// No description provided for @chatErrorWithMessage.
  ///
  /// In zh, this message translates to:
  /// **'錯誤: {message}'**
  String chatErrorWithMessage(String message);

  /// No description provided for @groupMemberCountClickToCopy.
  ///
  /// In zh, this message translates to:
  /// **'{count}人，點擊複製羣ID'**
  String groupMemberCountClickToCopy(int count);

  /// No description provided for @chatMusicLinkLabel.
  ///
  /// In zh, this message translates to:
  /// **'音樂鏈接'**
  String get chatMusicLinkLabel;

  /// No description provided for @chatNoMediaUrlAvailable.
  ///
  /// In zh, this message translates to:
  /// **'沒有可用的媒體鏈接'**
  String get chatNoMediaUrlAvailable;

  /// No description provided for @groupNoPermissionToEditGroupName.
  ///
  /// In zh, this message translates to:
  /// **'你沒有權限修改羣名稱'**
  String get groupNoPermissionToEditGroupName;

  /// No description provided for @chatRedPacketTransferCannotForward.
  ///
  /// In zh, this message translates to:
  /// **'紅包和轉賬消息無法轉發'**
  String get chatRedPacketTransferCannotForward;

  /// No description provided for @authEmailAddress.
  ///
  /// In zh, this message translates to:
  /// **'郵箱地址'**
  String get authEmailAddress;

  /// No description provided for @commonEnterEmailAddress.
  ///
  /// In zh, this message translates to:
  /// **'請輸入郵箱地址'**
  String get commonEnterEmailAddress;

  /// No description provided for @authEmailRecoveryHint.
  ///
  /// In zh, this message translates to:
  /// **'用於找回密碼'**
  String get authEmailRecoveryHint;

  /// No description provided for @commonInvalidEmailFormat.
  ///
  /// In zh, this message translates to:
  /// **'請輸入有效的郵箱地址'**
  String get commonInvalidEmailFormat;

  /// No description provided for @authOptional.
  ///
  /// In zh, this message translates to:
  /// **'選填'**
  String get authOptional;

  /// No description provided for @authResetPassword.
  ///
  /// In zh, this message translates to:
  /// **'重置密碼'**
  String get authResetPassword;

  /// No description provided for @authEnterRegisteredEmail.
  ///
  /// In zh, this message translates to:
  /// **'請輸入註冊時綁定的郵箱地址'**
  String get authEnterRegisteredEmail;

  /// No description provided for @authSendResetCode.
  ///
  /// In zh, this message translates to:
  /// **'發送重置驗證碼'**
  String get authSendResetCode;

  /// No description provided for @authResetCodeSent.
  ///
  /// In zh, this message translates to:
  /// **'重置驗證碼已發送至 {email}'**
  String authResetCodeSent(String email);

  /// No description provided for @authEnterResetCode.
  ///
  /// In zh, this message translates to:
  /// **'輸入重置驗證碼'**
  String get authEnterResetCode;

  /// No description provided for @authSetNewPassword.
  ///
  /// In zh, this message translates to:
  /// **'設置新密碼'**
  String get authSetNewPassword;

  /// No description provided for @commonConfirmNewPassword.
  ///
  /// In zh, this message translates to:
  /// **'確認新密碼'**
  String get commonConfirmNewPassword;

  /// No description provided for @commonNewPassword.
  ///
  /// In zh, this message translates to:
  /// **'新密碼'**
  String get commonNewPassword;

  /// No description provided for @authPasswordResetSuccess.
  ///
  /// In zh, this message translates to:
  /// **'密碼重置成功，請使用新密碼登錄'**
  String get authPasswordResetSuccess;

  /// No description provided for @authResetPasswordFailed.
  ///
  /// In zh, this message translates to:
  /// **'重置密碼失敗'**
  String get authResetPasswordFailed;

  /// No description provided for @settingsChangePassword.
  ///
  /// In zh, this message translates to:
  /// **'修改密碼'**
  String get settingsChangePassword;

  /// No description provided for @settingsCurrentPassword.
  ///
  /// In zh, this message translates to:
  /// **'當前密碼'**
  String get settingsCurrentPassword;

  /// No description provided for @settingsEnterCurrentPassword.
  ///
  /// In zh, this message translates to:
  /// **'請輸入當前密碼'**
  String get settingsEnterCurrentPassword;

  /// No description provided for @settingsEnterNewPassword.
  ///
  /// In zh, this message translates to:
  /// **'請輸入新密碼'**
  String get settingsEnterNewPassword;

  /// No description provided for @settingsPasswordChanged.
  ///
  /// In zh, this message translates to:
  /// **'密碼修改成功，請使用新密碼重新登錄'**
  String get settingsPasswordChanged;

  /// No description provided for @settingsChangePasswordFailed.
  ///
  /// In zh, this message translates to:
  /// **'修改密碼失敗'**
  String get settingsChangePasswordFailed;

  /// No description provided for @settingsNewPasswordMustBeDifferent.
  ///
  /// In zh, this message translates to:
  /// **'新密碼不能與當前密碼相同'**
  String get settingsNewPasswordMustBeDifferent;

  /// No description provided for @settingsChangePasswordInfo.
  ///
  /// In zh, this message translates to:
  /// **'修改密碼後，您將被登出，需要使用新密碼重新登錄。'**
  String get settingsChangePasswordInfo;

  /// No description provided for @settingsPasswordRequirements.
  ///
  /// In zh, this message translates to:
  /// **'密碼要求：'**
  String get settingsPasswordRequirements;

  /// No description provided for @settingsSecurityNote.
  ///
  /// In zh, this message translates to:
  /// **'爲了安全，修改密碼後需要在所有設備上重新登錄。'**
  String get settingsSecurityNote;

  /// No description provided for @settingsSecurity.
  ///
  /// In zh, this message translates to:
  /// **'安全'**
  String get settingsSecurity;

  /// No description provided for @settingsCurrentBoundEmail.
  ///
  /// In zh, this message translates to:
  /// **'當前綁定郵箱'**
  String get settingsCurrentBoundEmail;

  /// No description provided for @settingsNewEmailAddress.
  ///
  /// In zh, this message translates to:
  /// **'新郵箱地址'**
  String get settingsNewEmailAddress;

  /// No description provided for @settingsEnterNewEmail.
  ///
  /// In zh, this message translates to:
  /// **'請輸入新郵箱地址'**
  String get settingsEnterNewEmail;

  /// No description provided for @settingsVerificationCode.
  ///
  /// In zh, this message translates to:
  /// **'驗證碼'**
  String get settingsVerificationCode;

  /// No description provided for @settingsVerificationCodeSent.
  ///
  /// In zh, this message translates to:
  /// **'驗證碼已發送'**
  String get settingsVerificationCodeSent;

  /// No description provided for @settingsCodeSentTo.
  ///
  /// In zh, this message translates to:
  /// **'驗證碼已發送至'**
  String get settingsCodeSentTo;

  /// No description provided for @settingsDidNotReceiveCode.
  ///
  /// In zh, this message translates to:
  /// **'沒有收到驗證碼？'**
  String get settingsDidNotReceiveCode;

  /// No description provided for @settingsEmailChangedSuccess.
  ///
  /// In zh, this message translates to:
  /// **'郵箱修改成功'**
  String get settingsEmailChangedSuccess;

  /// No description provided for @settingsChangeEmailFailed.
  ///
  /// In zh, this message translates to:
  /// **'修改郵箱失敗'**
  String get settingsChangeEmailFailed;

  /// No description provided for @settingsEmailSecurityNote.
  ///
  /// In zh, this message translates to:
  /// **'郵箱用於密碼找回，請確保安全。'**
  String get settingsEmailSecurityNote;

  /// No description provided for @commonGoogleLogin.
  ///
  /// In zh, this message translates to:
  /// **'使用 Google 登錄'**
  String get commonGoogleLogin;

  /// No description provided for @commonAppleLogin.
  ///
  /// In zh, this message translates to:
  /// **'使用 Apple 登錄'**
  String get commonAppleLogin;

  /// No description provided for @commonWechat.
  ///
  /// In zh, this message translates to:
  /// **'微信'**
  String get commonWechat;

  /// No description provided for @settingsLanguage.
  ///
  /// In zh, this message translates to:
  /// **'語言'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageChanged.
  ///
  /// In zh, this message translates to:
  /// **'語言已更改'**
  String get settingsLanguageChanged;

  /// No description provided for @settingsTranslation.
  ///
  /// In zh, this message translates to:
  /// **'翻譯'**
  String get settingsTranslation;

  /// No description provided for @settingsTranslateTextTo.
  ///
  /// In zh, this message translates to:
  /// **'將文字翻譯爲'**
  String get settingsTranslateTextTo;

  /// No description provided for @settingsTranslateDescription.
  ///
  /// In zh, this message translates to:
  /// **'選擇你希望將消息翻譯成的語言。'**
  String get settingsTranslateDescription;

  /// No description provided for @settingsAutoTranslate.
  ///
  /// In zh, this message translates to:
  /// **'自動翻譯聊天中收到的消息'**
  String get settingsAutoTranslate;

  /// No description provided for @settingsAutoTranslateDescription.
  ///
  /// In zh, this message translates to:
  /// **'自動將聊天中收到的消息翻譯爲你選擇的語言。'**
  String get settingsAutoTranslateDescription;

  /// No description provided for @settingsBiometricLogin.
  ///
  /// In zh, this message translates to:
  /// **'生物識別登錄'**
  String get settingsBiometricLogin;

  /// No description provided for @authLoginWithBiometric.
  ///
  /// In zh, this message translates to:
  /// **'使用{type}登錄'**
  String authLoginWithBiometric(Object type);

  /// No description provided for @settingsBiometricLoginEnabled.
  ///
  /// In zh, this message translates to:
  /// **'生物識別登錄已啓用'**
  String get settingsBiometricLoginEnabled;

  /// No description provided for @settingsBiometricLoginDisabled.
  ///
  /// In zh, this message translates to:
  /// **'生物識別登錄已禁用'**
  String get settingsBiometricLoginDisabled;

  /// No description provided for @settingsEnableBiometricLogin.
  ///
  /// In zh, this message translates to:
  /// **'啓用生物識別登錄'**
  String get settingsEnableBiometricLogin;

  /// No description provided for @settingsBiometricEnabled.
  ///
  /// In zh, this message translates to:
  /// **'已啓用 - 使用生物識別登錄'**
  String get settingsBiometricEnabled;

  /// No description provided for @settingsBiometricDisabled.
  ///
  /// In zh, this message translates to:
  /// **'已禁用 - 點擊啓用'**
  String get settingsBiometricDisabled;

  /// No description provided for @settingsBiometricNeedRelogin.
  ///
  /// In zh, this message translates to:
  /// **'請退出後重新登錄以啓用生物識別'**
  String get settingsBiometricNeedRelogin;

  /// No description provided for @authOr.
  ///
  /// In zh, this message translates to:
  /// **'或'**
  String get authOr;

  /// No description provided for @qrcodeCameraPermissionRestricted.
  ///
  /// In zh, this message translates to:
  /// **'此設備上的相機訪問受限'**
  String get qrcodeCameraPermissionRestricted;

  /// No description provided for @authPasskeyLabel.
  ///
  /// In zh, this message translates to:
  /// **'Passkey'**
  String get authPasskeyLabel;

  /// No description provided for @authGoogleLabel.
  ///
  /// In zh, this message translates to:
  /// **'Google'**
  String get authGoogleLabel;

  /// No description provided for @authAppleLabel.
  ///
  /// In zh, this message translates to:
  /// **'Apple'**
  String get authAppleLabel;

  /// No description provided for @authSsoLabel.
  ///
  /// In zh, this message translates to:
  /// **'SSO'**
  String get authSsoLabel;

  /// No description provided for @transferAmountHintZero.
  ///
  /// In zh, this message translates to:
  /// **'0.00'**
  String get transferAmountHintZero;

  /// No description provided for @commonMatrixIdHint.
  ///
  /// In zh, this message translates to:
  /// **'@username:server.com'**
  String get commonMatrixIdHint;

  /// No description provided for @authServerAddressHint.
  ///
  /// In zh, this message translates to:
  /// **'https://m.si46.world'**
  String get authServerAddressHint;

  /// No description provided for @authEmailExampleHint.
  ///
  /// In zh, this message translates to:
  /// **'example@email.com'**
  String get authEmailExampleHint;

  /// No description provided for @authVerificationCodePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'------'**
  String get authVerificationCodePlaceholder;

  /// No description provided for @profileEnterPokeSuffixHint.
  ///
  /// In zh, this message translates to:
  /// **'輸入戳一戳後綴，例如：的肩膀'**
  String get profileEnterPokeSuffixHint;

  /// No description provided for @groupAlbum.
  ///
  /// In zh, this message translates to:
  /// **'羣相冊'**
  String get groupAlbum;

  /// No description provided for @groupFiles.
  ///
  /// In zh, this message translates to:
  /// **'羣文件'**
  String get groupFiles;

  /// No description provided for @groupImages.
  ///
  /// In zh, this message translates to:
  /// **'圖片'**
  String get groupImages;

  /// No description provided for @groupVideos.
  ///
  /// In zh, this message translates to:
  /// **'視頻'**
  String get groupVideos;

  /// No description provided for @groupTotal.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get groupTotal;

  /// No description provided for @groupSize.
  ///
  /// In zh, this message translates to:
  /// **'大小'**
  String get groupSize;

  /// No description provided for @groupNoMedia.
  ///
  /// In zh, this message translates to:
  /// **'暫無媒體'**
  String get groupNoMedia;

  /// No description provided for @groupNoMediaDescription.
  ///
  /// In zh, this message translates to:
  /// **'此羣還沒有圖片或視頻'**
  String get groupNoMediaDescription;

  /// No description provided for @groupDocuments.
  ///
  /// In zh, this message translates to:
  /// **'文檔'**
  String get groupDocuments;

  /// No description provided for @groupNoFiles.
  ///
  /// In zh, this message translates to:
  /// **'暫無文件'**
  String get groupNoFiles;

  /// No description provided for @groupNoFilesDescription.
  ///
  /// In zh, this message translates to:
  /// **'此羣還沒有文件'**
  String get groupNoFilesDescription;

  /// No description provided for @groupDownloadStarted.
  ///
  /// In zh, this message translates to:
  /// **'正在下載 {filename}...'**
  String groupDownloadStarted(String filename);

  /// No description provided for @contactNoCommonGroups.
  ///
  /// In zh, this message translates to:
  /// **'暫無共同羣組'**
  String get contactNoCommonGroups;

  /// No description provided for @contactNoCommonGroupsDescription.
  ///
  /// In zh, this message translates to:
  /// **'你們沒有共同加入的羣組'**
  String get contactNoCommonGroupsDescription;

  /// No description provided for @chatVoiceMessage.
  ///
  /// In zh, this message translates to:
  /// **'語音'**
  String get chatVoiceMessage;

  /// No description provided for @chatMessage.
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get chatMessage;

  /// No description provided for @conversationHideChat.
  ///
  /// In zh, this message translates to:
  /// **'隱藏'**
  String get conversationHideChat;

  /// No description provided for @settingsQuickReply.
  ///
  /// In zh, this message translates to:
  /// **'快捷回覆'**
  String get settingsQuickReply;

  /// No description provided for @commonTranslate.
  ///
  /// In zh, this message translates to:
  /// **'翻譯'**
  String get commonTranslate;

  /// No description provided for @contactCreateTag.
  ///
  /// In zh, this message translates to:
  /// **'新建標籤'**
  String get contactCreateTag;

  /// No description provided for @contactEnterTagName.
  ///
  /// In zh, this message translates to:
  /// **'輸入標籤名稱'**
  String get contactEnterTagName;

  /// No description provided for @contactEditTag.
  ///
  /// In zh, this message translates to:
  /// **'編輯標籤'**
  String get contactEditTag;

  /// No description provided for @contactDeleteTag.
  ///
  /// In zh, this message translates to:
  /// **'刪除標籤'**
  String get contactDeleteTag;

  /// No description provided for @contactDeleteTagConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定要刪除標籤 \"{tagName}\" 嗎？'**
  String contactDeleteTagConfirm(String tagName);

  /// No description provided for @contactNoTags.
  ///
  /// In zh, this message translates to:
  /// **'暫無標籤'**
  String get contactNoTags;

  /// No description provided for @contactFriendPermissions.
  ///
  /// In zh, this message translates to:
  /// **'朋友權限'**
  String get contactFriendPermissions;

  /// No description provided for @contactSetChatOnly.
  ///
  /// In zh, this message translates to:
  /// **'設爲僅聊天'**
  String get contactSetChatOnly;

  /// No description provided for @contactChatOnlyDesc.
  ///
  /// In zh, this message translates to:
  /// **'只能聊天，其他內容將被隱藏'**
  String get contactChatOnlyDesc;

  /// No description provided for @contactHideMyMoments.
  ///
  /// In zh, this message translates to:
  /// **'不讓他（她）看我的朋友圈'**
  String get contactHideMyMoments;

  /// No description provided for @contactHideMyMomentsDesc.
  ///
  /// In zh, this message translates to:
  /// **'該好友無法查看你的朋友圈動態'**
  String get contactHideMyMomentsDesc;

  /// No description provided for @contactHideTheirMoments.
  ///
  /// In zh, this message translates to:
  /// **'不看他（她）的朋友圈'**
  String get contactHideTheirMoments;

  /// No description provided for @contactHideTheirMomentsDesc.
  ///
  /// In zh, this message translates to:
  /// **'不會看到該好友的朋友圈動態'**
  String get contactHideTheirMomentsDesc;

  /// No description provided for @contactHideMyStatus.
  ///
  /// In zh, this message translates to:
  /// **'不讓他（她）看我的狀態'**
  String get contactHideMyStatus;

  /// No description provided for @contactHideMyStatusDesc.
  ///
  /// In zh, this message translates to:
  /// **'該好友無法查看你的狀態更新'**
  String get contactHideMyStatusDesc;

  /// No description provided for @contactNoChatOnlyFriends.
  ///
  /// In zh, this message translates to:
  /// **'暫無僅聊天的朋友'**
  String get contactNoChatOnlyFriends;

  /// No description provided for @contactNoOfficialAccounts.
  ///
  /// In zh, this message translates to:
  /// **'暫無公衆號'**
  String get contactNoOfficialAccounts;

  /// No description provided for @contactFollowOfficialAccountsDesc.
  ///
  /// In zh, this message translates to:
  /// **'關注公衆號，獲取最新資訊'**
  String get contactFollowOfficialAccountsDesc;

  /// No description provided for @contactNoServiceAccounts.
  ///
  /// In zh, this message translates to:
  /// **'暫無服務號'**
  String get contactNoServiceAccounts;

  /// No description provided for @contactSubscribeServiceAccountsDesc.
  ///
  /// In zh, this message translates to:
  /// **'訂閱服務號，享受便捷服務'**
  String get contactSubscribeServiceAccountsDesc;

  /// No description provided for @contactNoEnterpriseContacts.
  ///
  /// In zh, this message translates to:
  /// **'暫無企業聯繫人'**
  String get contactNoEnterpriseContacts;

  /// No description provided for @contactEnterpriseContactsDesc.
  ///
  /// In zh, this message translates to:
  /// **'企業通訊錄聯繫人將顯示在這裏'**
  String get contactEnterpriseContactsDesc;

  /// No description provided for @profileCardPack.
  ///
  /// In zh, this message translates to:
  /// **'卡包'**
  String get profileCardPack;

  /// No description provided for @profileOrders.
  ///
  /// In zh, this message translates to:
  /// **'訂單'**
  String get profileOrders;

  /// No description provided for @profileNoOrders.
  ///
  /// In zh, this message translates to:
  /// **'暫無訂單'**
  String get profileNoOrders;

  /// No description provided for @profileOrdersDesc.
  ///
  /// In zh, this message translates to:
  /// **'你的訂單將顯示在這裏'**
  String get profileOrdersDesc;

  /// No description provided for @profileNoCards.
  ///
  /// In zh, this message translates to:
  /// **'暫無卡券'**
  String get profileNoCards;

  /// No description provided for @profileCardsDesc.
  ///
  /// In zh, this message translates to:
  /// **'你的卡券將顯示在這裏'**
  String get profileCardsDesc;

  /// No description provided for @favoriteEnterTagsHint.
  ///
  /// In zh, this message translates to:
  /// **'輸入標籤，用逗號分隔'**
  String get favoriteEnterTagsHint;

  /// No description provided for @favoriteTagsUpdated.
  ///
  /// In zh, this message translates to:
  /// **'標籤已更新'**
  String get favoriteTagsUpdated;

  /// No description provided for @favoriteForwardedContent.
  ///
  /// In zh, this message translates to:
  /// **'內容已轉發'**
  String get favoriteForwardedContent;

  /// No description provided for @favoriteEnterNoteContent.
  ///
  /// In zh, this message translates to:
  /// **'輸入筆記內容'**
  String get favoriteEnterNoteContent;

  /// No description provided for @favoriteNoteAdded.
  ///
  /// In zh, this message translates to:
  /// **'筆記已添加'**
  String get favoriteNoteAdded;

  /// No description provided for @favoriteLinkTitle.
  ///
  /// In zh, this message translates to:
  /// **'鏈接標題'**
  String get favoriteLinkTitle;

  /// No description provided for @favoriteLinkUrl.
  ///
  /// In zh, this message translates to:
  /// **'https://'**
  String get favoriteLinkUrl;

  /// No description provided for @favoriteLinkAdded.
  ///
  /// In zh, this message translates to:
  /// **'鏈接已添加'**
  String get favoriteLinkAdded;

  /// No description provided for @contactPhotoAdded.
  ///
  /// In zh, this message translates to:
  /// **'照片已添加'**
  String get contactPhotoAdded;

  /// No description provided for @contactEnterPhone.
  ///
  /// In zh, this message translates to:
  /// **'輸入手機號碼'**
  String get contactEnterPhone;

  /// No description provided for @commonConversationWithId.
  ///
  /// In zh, this message translates to:
  /// **'會話: {roomId}'**
  String commonConversationWithId(String roomId);

  /// No description provided for @commonContactWithId.
  ///
  /// In zh, this message translates to:
  /// **'聯繫人: {userId}'**
  String commonContactWithId(String userId);

  /// No description provided for @commonDiscover.
  ///
  /// In zh, this message translates to:
  /// **'發現'**
  String get commonDiscover;

  /// No description provided for @commonDeveloping.
  ///
  /// In zh, this message translates to:
  /// **'{title}\n(開發中)'**
  String commonDeveloping(String title);

  /// No description provided for @commonPageNotFound.
  ///
  /// In zh, this message translates to:
  /// **'頁面不存在'**
  String get commonPageNotFound;

  /// No description provided for @commonBackToHome.
  ///
  /// In zh, this message translates to:
  /// **'返回首頁'**
  String get commonBackToHome;

  /// No description provided for @settingsMessageNotifications.
  ///
  /// In zh, this message translates to:
  /// **'消息通知'**
  String get settingsMessageNotifications;

  /// No description provided for @settingsReceiveNewMessageNotifications.
  ///
  /// In zh, this message translates to:
  /// **'接收新消息通知'**
  String get settingsReceiveNewMessageNotifications;

  /// No description provided for @settingsShowMessagePreview.
  ///
  /// In zh, this message translates to:
  /// **'顯示消息預覽'**
  String get settingsShowMessagePreview;

  /// No description provided for @settingsShowMessageContentInNotification.
  ///
  /// In zh, this message translates to:
  /// **'在通知中顯示消息內容'**
  String get settingsShowMessageContentInNotification;

  /// No description provided for @settingsNotificationSound.
  ///
  /// In zh, this message translates to:
  /// **'通知聲音'**
  String get settingsNotificationSound;

  /// No description provided for @settingsPlaySoundOnMessage.
  ///
  /// In zh, this message translates to:
  /// **'收到消息時播放聲音'**
  String get settingsPlaySoundOnMessage;

  /// No description provided for @commonVibration.
  ///
  /// In zh, this message translates to:
  /// **'振動'**
  String get commonVibration;

  /// No description provided for @settingsVibrateOnMessage.
  ///
  /// In zh, this message translates to:
  /// **'收到消息時震動'**
  String get settingsVibrateOnMessage;

  /// No description provided for @settingsDoNotDisturbMode.
  ///
  /// In zh, this message translates to:
  /// **'勿擾模式'**
  String get settingsDoNotDisturbMode;

  /// No description provided for @settingsDoNotDisturbDescription.
  ///
  /// In zh, this message translates to:
  /// **'在指定時間內不接收通知'**
  String get settingsDoNotDisturbDescription;

  /// No description provided for @settingsStartTime.
  ///
  /// In zh, this message translates to:
  /// **'開始時間'**
  String get settingsStartTime;

  /// No description provided for @settingsEndTime.
  ///
  /// In zh, this message translates to:
  /// **'結束時間'**
  String get settingsEndTime;

  /// No description provided for @settingsDeleteQuickReply.
  ///
  /// In zh, this message translates to:
  /// **'刪除快捷回覆'**
  String get settingsDeleteQuickReply;

  /// No description provided for @settingsEditQuickReply.
  ///
  /// In zh, this message translates to:
  /// **'編輯快捷回覆'**
  String get settingsEditQuickReply;

  /// No description provided for @settingsAddQuickReply.
  ///
  /// In zh, this message translates to:
  /// **'添加快捷回覆'**
  String get settingsAddQuickReply;

  /// No description provided for @settingsManageQuickReplies.
  ///
  /// In zh, this message translates to:
  /// **'管理快捷回覆'**
  String get settingsManageQuickReplies;

  /// No description provided for @settingsNoQuickReplies.
  ///
  /// In zh, this message translates to:
  /// **'暫無快捷回覆'**
  String get settingsNoQuickReplies;

  /// No description provided for @settingsDefaultQuickReplies.
  ///
  /// In zh, this message translates to:
  /// **'將顯示默認快捷回覆'**
  String get settingsDefaultQuickReplies;

  /// No description provided for @settingsWhoCanSee.
  ///
  /// In zh, this message translates to:
  /// **'誰可以查看'**
  String get settingsWhoCanSee;

  /// No description provided for @settingsLastSeen.
  ///
  /// In zh, this message translates to:
  /// **'最後上線時間'**
  String get settingsLastSeen;

  /// No description provided for @settingsHiddenChats.
  ///
  /// In zh, this message translates to:
  /// **'隱藏的聊天'**
  String get settingsHiddenChats;

  /// No description provided for @settingsMessagesLabel.
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get settingsMessagesLabel;

  /// No description provided for @settingsAllowStrangerMessages.
  ///
  /// In zh, this message translates to:
  /// **'允許陌生人消息'**
  String get settingsAllowStrangerMessages;

  /// No description provided for @settingsReceiveMessagesFromNonContacts.
  ///
  /// In zh, this message translates to:
  /// **'接收非聯繫人的消息'**
  String get settingsReceiveMessagesFromNonContacts;

  /// No description provided for @settingsReadReceipts.
  ///
  /// In zh, this message translates to:
  /// **'已讀回執'**
  String get settingsReadReceipts;

  /// No description provided for @settingsLetOthersKnowYouRead.
  ///
  /// In zh, this message translates to:
  /// **'讓對方知道你已讀'**
  String get settingsLetOthersKnowYouRead;

  /// No description provided for @settingsTypingIndicator.
  ///
  /// In zh, this message translates to:
  /// **'輸入狀態指示'**
  String get settingsTypingIndicator;

  /// No description provided for @settingsLetOthersKnowYouTyping.
  ///
  /// In zh, this message translates to:
  /// **'讓對方知道你正在輸入'**
  String get settingsLetOthersKnowYouTyping;

  /// No description provided for @settingsEveryone.
  ///
  /// In zh, this message translates to:
  /// **'所有人'**
  String get settingsEveryone;

  /// No description provided for @settingsContactsOnly.
  ///
  /// In zh, this message translates to:
  /// **'僅聯繫人'**
  String get settingsContactsOnly;

  /// No description provided for @settingsNobody.
  ///
  /// In zh, this message translates to:
  /// **'無人'**
  String get settingsNobody;

  /// No description provided for @settingsWhoCanSeeTitle.
  ///
  /// In zh, this message translates to:
  /// **'誰可以看到 {title}'**
  String settingsWhoCanSeeTitle(String title);

  /// No description provided for @settingsVersionInfo.
  ///
  /// In zh, this message translates to:
  /// **'版本 {version}'**
  String settingsVersionInfo(String version);

  /// No description provided for @settingsCheckForUpdates.
  ///
  /// In zh, this message translates to:
  /// **'檢查更新'**
  String get settingsCheckForUpdates;

  /// No description provided for @settingsOpenSourceLicenses.
  ///
  /// In zh, this message translates to:
  /// **'開源許可'**
  String get settingsOpenSourceLicenses;

  /// No description provided for @settingsFeedbackAndSuggestions.
  ///
  /// In zh, this message translates to:
  /// **'反饋與建議'**
  String get settingsFeedbackAndSuggestions;

  /// No description provided for @settingsBuiltOnMatrix.
  ///
  /// In zh, this message translates to:
  /// **'基於 Matrix 協議構建'**
  String get settingsBuiltOnMatrix;

  /// No description provided for @settingsNoHiddenChats.
  ///
  /// In zh, this message translates to:
  /// **'沒有隱藏的聊天'**
  String get settingsNoHiddenChats;

  /// No description provided for @settingsNoHiddenChatsDescription.
  ///
  /// In zh, this message translates to:
  /// **'你隱藏的聊天會顯示在這裏'**
  String get settingsNoHiddenChatsDescription;

  /// No description provided for @settingsUnhideChat.
  ///
  /// In zh, this message translates to:
  /// **'取消隱藏'**
  String get settingsUnhideChat;

  /// No description provided for @settingsDarkMode.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get settingsDarkMode;

  /// No description provided for @settingsFontSize.
  ///
  /// In zh, this message translates to:
  /// **'字體大小'**
  String get settingsFontSize;

  /// No description provided for @settingsBubbleStyle.
  ///
  /// In zh, this message translates to:
  /// **'氣泡樣式'**
  String get settingsBubbleStyle;

  /// No description provided for @settingsFollowSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟隨系統'**
  String get settingsFollowSystem;

  /// No description provided for @settingsAutoSwitchBySystem.
  ///
  /// In zh, this message translates to:
  /// **'跟隨系統自動切換'**
  String get settingsAutoSwitchBySystem;

  /// No description provided for @settingsLightMode.
  ///
  /// In zh, this message translates to:
  /// **'淺色模式'**
  String get settingsLightMode;

  /// No description provided for @settingsAlwaysUseLightTheme.
  ///
  /// In zh, this message translates to:
  /// **'始終使用淺色主題'**
  String get settingsAlwaysUseLightTheme;

  /// No description provided for @settingsDarkModeOption.
  ///
  /// In zh, this message translates to:
  /// **'深色模式選項'**
  String get settingsDarkModeOption;

  /// No description provided for @settingsAlwaysUseDarkTheme.
  ///
  /// In zh, this message translates to:
  /// **'始終使用深色主題'**
  String get settingsAlwaysUseDarkTheme;

  /// No description provided for @settingsFontSizeSmall.
  ///
  /// In zh, this message translates to:
  /// **'小'**
  String get settingsFontSizeSmall;

  /// No description provided for @settingsFontSizeStandard.
  ///
  /// In zh, this message translates to:
  /// **'標準'**
  String get settingsFontSizeStandard;

  /// No description provided for @settingsFontSizeLarge.
  ///
  /// In zh, this message translates to:
  /// **'大'**
  String get settingsFontSizeLarge;

  /// No description provided for @settingsFontSizeExtraLarge.
  ///
  /// In zh, this message translates to:
  /// **'特大'**
  String get settingsFontSizeExtraLarge;

  /// No description provided for @settingsBubbleStyleWechat.
  ///
  /// In zh, this message translates to:
  /// **'微信樣式'**
  String get settingsBubbleStyleWechat;

  /// No description provided for @settingsBubbleStyleWechatDesc.
  ///
  /// In zh, this message translates to:
  /// **'經典微信氣泡樣式'**
  String get settingsBubbleStyleWechatDesc;

  /// No description provided for @settingsBubbleStyleModern.
  ///
  /// In zh, this message translates to:
  /// **'現代樣式'**
  String get settingsBubbleStyleModern;

  /// No description provided for @settingsBubbleStyleModernDesc.
  ///
  /// In zh, this message translates to:
  /// **'簡潔的現代氣泡樣式'**
  String get settingsBubbleStyleModernDesc;

  /// No description provided for @settingsBubbleStyleClassic.
  ///
  /// In zh, this message translates to:
  /// **'經典樣式'**
  String get settingsBubbleStyleClassic;

  /// No description provided for @settingsBubbleStyleClassicDesc.
  ///
  /// In zh, this message translates to:
  /// **'傳統的氣泡樣式'**
  String get settingsBubbleStyleClassicDesc;

  /// No description provided for @discoverVideoChannels.
  ///
  /// In zh, this message translates to:
  /// **'視頻號'**
  String get discoverVideoChannels;

  /// No description provided for @discoverLive.
  ///
  /// In zh, this message translates to:
  /// **'直播'**
  String get discoverLive;

  /// No description provided for @discoverListen.
  ///
  /// In zh, this message translates to:
  /// **'聽一聽'**
  String get discoverListen;

  /// No description provided for @discoverWatch.
  ///
  /// In zh, this message translates to:
  /// **'看一看'**
  String get discoverWatch;

  /// No description provided for @discoverSearchDiscover.
  ///
  /// In zh, this message translates to:
  /// **'搜一搜'**
  String get discoverSearchDiscover;

  /// No description provided for @discoverNearbyPeople.
  ///
  /// In zh, this message translates to:
  /// **'附近的人'**
  String get discoverNearbyPeople;

  /// No description provided for @discoverGames.
  ///
  /// In zh, this message translates to:
  /// **'遊戲'**
  String get discoverGames;

  /// No description provided for @discoverMiniPrograms.
  ///
  /// In zh, this message translates to:
  /// **'小程序'**
  String get discoverMiniPrograms;

  /// No description provided for @chatAlreadyInCall.
  ///
  /// In zh, this message translates to:
  /// **'當前正在通話中'**
  String get chatAlreadyInCall;

  /// No description provided for @commonConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'連接失敗'**
  String get commonConnectionFailed;

  /// No description provided for @chatCallRejected.
  ///
  /// In zh, this message translates to:
  /// **'對方已拒絕'**
  String get chatCallRejected;

  /// No description provided for @chatNoAnswer.
  ///
  /// In zh, this message translates to:
  /// **'對方無應答'**
  String get chatNoAnswer;

  /// No description provided for @commonClose.
  ///
  /// In zh, this message translates to:
  /// **'關閉'**
  String get commonClose;

  /// No description provided for @chatSelectContact.
  ///
  /// In zh, this message translates to:
  /// **'選擇聯繫人'**
  String get chatSelectContact;

  /// No description provided for @chatVoteRemoved.
  ///
  /// In zh, this message translates to:
  /// **'已取消投票'**
  String get chatVoteRemoved;

  /// No description provided for @chatVoteChanged.
  ///
  /// In zh, this message translates to:
  /// **'投票已更改'**
  String get chatVoteChanged;

  /// No description provided for @chatVoted.
  ///
  /// In zh, this message translates to:
  /// **'已投票'**
  String get chatVoted;

  /// No description provided for @chatReplyTo.
  ///
  /// In zh, this message translates to:
  /// **'回覆 {name}'**
  String chatReplyTo(String name);

  /// No description provided for @chatCurrentLocation.
  ///
  /// In zh, this message translates to:
  /// **'當前位置'**
  String get chatCurrentLocation;

  /// No description provided for @chatNearbyPlace.
  ///
  /// In zh, this message translates to:
  /// **'附近地點 {index}'**
  String chatNearbyPlace(int index);

  /// No description provided for @chatApproximateDistance.
  ///
  /// In zh, this message translates to:
  /// **'約 {distance}'**
  String chatApproximateDistance(String distance);

  /// No description provided for @chatAddress.
  ///
  /// In zh, this message translates to:
  /// **'地址'**
  String get chatAddress;

  /// No description provided for @chatLatitude.
  ///
  /// In zh, this message translates to:
  /// **'緯度'**
  String get chatLatitude;

  /// No description provided for @chatLongitude.
  ///
  /// In zh, this message translates to:
  /// **'經度'**
  String get chatLongitude;

  /// No description provided for @groupDescriptionUpdated.
  ///
  /// In zh, this message translates to:
  /// **'羣簡介已更新'**
  String get groupDescriptionUpdated;

  /// No description provided for @groupAvatarUpdated.
  ///
  /// In zh, this message translates to:
  /// **'羣頭像已更新'**
  String get groupAvatarUpdated;

  /// No description provided for @groupVisibilityUpdated.
  ///
  /// In zh, this message translates to:
  /// **'羣可見性已更新'**
  String get groupVisibilityUpdated;

  /// No description provided for @groupChannelCreated.
  ///
  /// In zh, this message translates to:
  /// **'頻道已創建'**
  String get groupChannelCreated;

  /// No description provided for @groupChannelUpdated.
  ///
  /// In zh, this message translates to:
  /// **'頻道已更新'**
  String get groupChannelUpdated;

  /// No description provided for @groupChannelDeleted.
  ///
  /// In zh, this message translates to:
  /// **'頻道已刪除'**
  String get groupChannelDeleted;

  /// No description provided for @callDecline.
  ///
  /// In zh, this message translates to:
  /// **'拒絕'**
  String get callDecline;

  /// No description provided for @callAnswer.
  ///
  /// In zh, this message translates to:
  /// **'接聽'**
  String get callAnswer;

  /// No description provided for @callIncomingVideoCall.
  ///
  /// In zh, this message translates to:
  /// **'視頻來電'**
  String get callIncomingVideoCall;

  /// No description provided for @callIncomingVoiceCall.
  ///
  /// In zh, this message translates to:
  /// **'語音來電'**
  String get callIncomingVoiceCall;

  /// No description provided for @callVideoCallInProgress.
  ///
  /// In zh, this message translates to:
  /// **'視頻通話中'**
  String get callVideoCallInProgress;

  /// No description provided for @callVoiceCallInProgress.
  ///
  /// In zh, this message translates to:
  /// **'語音通話中'**
  String get callVoiceCallInProgress;

  /// No description provided for @callReconnectingCall.
  ///
  /// In zh, this message translates to:
  /// **'正在重連...'**
  String get callReconnectingCall;

  /// No description provided for @callEnded.
  ///
  /// In zh, this message translates to:
  /// **'通話已結束'**
  String get callEnded;

  /// No description provided for @callFailed.
  ///
  /// In zh, this message translates to:
  /// **'通話失敗'**
  String get callFailed;

  /// No description provided for @callLivekitNotConfigured.
  ///
  /// In zh, this message translates to:
  /// **'LiveKit 未配置'**
  String get callLivekitNotConfigured;

  /// No description provided for @callJoinMeetingFailed.
  ///
  /// In zh, this message translates to:
  /// **'加入會議失敗: {error}'**
  String callJoinMeetingFailed(String error);

  /// No description provided for @callScreenShareFailed.
  ///
  /// In zh, this message translates to:
  /// **'屏幕共享失敗: {error}'**
  String callScreenShareFailed(String error);

  /// No description provided for @profileN42BeanTitle.
  ///
  /// In zh, this message translates to:
  /// **'N42豆'**
  String get profileN42BeanTitle;

  /// No description provided for @profileNoN42Bean.
  ///
  /// In zh, this message translates to:
  /// **'暫無N42豆'**
  String get profileNoN42Bean;

  /// No description provided for @profileN42BeanDetails.
  ///
  /// In zh, this message translates to:
  /// **'N42豆明細'**
  String get profileN42BeanDetails;

  /// No description provided for @profileN42BeanDescription.
  ///
  /// In zh, this message translates to:
  /// **'N42豆是用於兌換N42內虛擬物品和服務的道具，目前可用於兌換：'**
  String get profileN42BeanDescription;

  /// No description provided for @profileN42BeanFeature1.
  ///
  /// In zh, this message translates to:
  /// **'會員專屬表情和主題'**
  String get profileN42BeanFeature1;

  /// No description provided for @profileN42BeanFeature2.
  ///
  /// In zh, this message translates to:
  /// **'聊天氣泡個性化'**
  String get profileN42BeanFeature2;

  /// No description provided for @profileN42BeanFeature3.
  ///
  /// In zh, this message translates to:
  /// **'紅包封面定製'**
  String get profileN42BeanFeature3;

  /// No description provided for @profileN42BeanFeature4.
  ///
  /// In zh, this message translates to:
  /// **'專屬暱稱標識'**
  String get profileN42BeanFeature4;

  /// No description provided for @profileN42BeanFeature5.
  ///
  /// In zh, this message translates to:
  /// **'羣聊特權功能'**
  String get profileN42BeanFeature5;

  /// No description provided for @profileN42BeanFeature6.
  ///
  /// In zh, this message translates to:
  /// **'雲存儲空間擴展'**
  String get profileN42BeanFeature6;

  /// No description provided for @profileN42BeanFeature7.
  ///
  /// In zh, this message translates to:
  /// **'視頻通話美顏濾鏡'**
  String get profileN42BeanFeature7;

  /// No description provided for @profileN42BeanFeature8.
  ///
  /// In zh, this message translates to:
  /// **'朋友圈背景更換'**
  String get profileN42BeanFeature8;

  /// No description provided for @profileN42BeanFeature9.
  ///
  /// In zh, this message translates to:
  /// **'VIP客服優先服務'**
  String get profileN42BeanFeature9;

  /// No description provided for @profileGotIt.
  ///
  /// In zh, this message translates to:
  /// **'我知道了'**
  String get profileGotIt;

  /// No description provided for @profileNoN42BeanRecords.
  ///
  /// In zh, this message translates to:
  /// **'暫無N42豆明細記錄'**
  String get profileNoN42BeanRecords;

  /// No description provided for @profileMoodAndThoughts.
  ///
  /// In zh, this message translates to:
  /// **'心情想法'**
  String get profileMoodAndThoughts;

  /// No description provided for @profileStatusHappy.
  ///
  /// In zh, this message translates to:
  /// **'開心'**
  String get profileStatusHappy;

  /// No description provided for @profileStatusCracked.
  ///
  /// In zh, this message translates to:
  /// **'裂開'**
  String get profileStatusCracked;

  /// No description provided for @profileStatusLucky.
  ///
  /// In zh, this message translates to:
  /// **'發呆'**
  String get profileStatusLucky;

  /// No description provided for @profileStatusSunny.
  ///
  /// In zh, this message translates to:
  /// **'天氣晴'**
  String get profileStatusSunny;

  /// No description provided for @profileStatusTired.
  ///
  /// In zh, this message translates to:
  /// **'累了'**
  String get profileStatusTired;

  /// No description provided for @profileStatusDaydream.
  ///
  /// In zh, this message translates to:
  /// **'發呆中'**
  String get profileStatusDaydream;

  /// No description provided for @profileStatusRushing.
  ///
  /// In zh, this message translates to:
  /// **'忙碌'**
  String get profileStatusRushing;

  /// No description provided for @profileStatusOverthinking.
  ///
  /// In zh, this message translates to:
  /// **'想太多'**
  String get profileStatusOverthinking;

  /// No description provided for @profileStatusEnergized.
  ///
  /// In zh, this message translates to:
  /// **'元氣滿滿'**
  String get profileStatusEnergized;

  /// No description provided for @profileWorkAndStudy.
  ///
  /// In zh, this message translates to:
  /// **'工作學習'**
  String get profileWorkAndStudy;

  /// No description provided for @profileStatusWorking.
  ///
  /// In zh, this message translates to:
  /// **'搬磚中'**
  String get profileStatusWorking;

  /// No description provided for @profileStatusStudying.
  ///
  /// In zh, this message translates to:
  /// **'學習中'**
  String get profileStatusStudying;

  /// No description provided for @profileStatusBusy.
  ///
  /// In zh, this message translates to:
  /// **'忙'**
  String get profileStatusBusy;

  /// No description provided for @profileStatusSlacking.
  ///
  /// In zh, this message translates to:
  /// **'摸魚中'**
  String get profileStatusSlacking;

  /// No description provided for @profileStatusTraveling.
  ///
  /// In zh, this message translates to:
  /// **'旅行中'**
  String get profileStatusTraveling;

  /// No description provided for @profileStatusGoingHome.
  ///
  /// In zh, this message translates to:
  /// **'回家中'**
  String get profileStatusGoingHome;

  /// No description provided for @profileStatusDnd.
  ///
  /// In zh, this message translates to:
  /// **'請勿打擾'**
  String get profileStatusDnd;

  /// No description provided for @profileActivities.
  ///
  /// In zh, this message translates to:
  /// **'活動'**
  String get profileActivities;

  /// No description provided for @profileStatusHanging.
  ///
  /// In zh, this message translates to:
  /// **'出去浪'**
  String get profileStatusHanging;

  /// No description provided for @profileStatusCheckIn.
  ///
  /// In zh, this message translates to:
  /// **'打卡'**
  String get profileStatusCheckIn;

  /// No description provided for @profileStatusExercising.
  ///
  /// In zh, this message translates to:
  /// **'運動中'**
  String get profileStatusExercising;

  /// No description provided for @profileStatusCoffee.
  ///
  /// In zh, this message translates to:
  /// **'喝咖啡'**
  String get profileStatusCoffee;

  /// No description provided for @profileStatusBubbleTea.
  ///
  /// In zh, this message translates to:
  /// **'奶茶'**
  String get profileStatusBubbleTea;

  /// No description provided for @profileStatusEating.
  ///
  /// In zh, this message translates to:
  /// **'乾飯中'**
  String get profileStatusEating;

  /// No description provided for @profileStatusParenting.
  ///
  /// In zh, this message translates to:
  /// **'帶娃中'**
  String get profileStatusParenting;

  /// No description provided for @profileStatusSavingWorld.
  ///
  /// In zh, this message translates to:
  /// **'拯救世界'**
  String get profileStatusSavingWorld;

  /// No description provided for @profileStatusSelfie.
  ///
  /// In zh, this message translates to:
  /// **'自拍'**
  String get profileStatusSelfie;

  /// No description provided for @profileRest.
  ///
  /// In zh, this message translates to:
  /// **'休息'**
  String get profileRest;

  /// No description provided for @profileStatusRetreat.
  ///
  /// In zh, this message translates to:
  /// **'閉關'**
  String get profileStatusRetreat;

  /// No description provided for @profileStatusHome.
  ///
  /// In zh, this message translates to:
  /// **'宅家'**
  String get profileStatusHome;

  /// No description provided for @profileStatusSleeping.
  ///
  /// In zh, this message translates to:
  /// **'睡覺中'**
  String get profileStatusSleeping;

  /// No description provided for @profileStatusCatLover.
  ///
  /// In zh, this message translates to:
  /// **'吸貓中'**
  String get profileStatusCatLover;

  /// No description provided for @profileStatusDogWalking.
  ///
  /// In zh, this message translates to:
  /// **'遛狗中'**
  String get profileStatusDogWalking;

  /// No description provided for @profileStatusGaming.
  ///
  /// In zh, this message translates to:
  /// **'遊戲中'**
  String get profileStatusGaming;

  /// No description provided for @profileStatusListening.
  ///
  /// In zh, this message translates to:
  /// **'聽歌中'**
  String get profileStatusListening;

  /// No description provided for @profileEditAddress.
  ///
  /// In zh, this message translates to:
  /// **'編輯地址'**
  String get profileEditAddress;

  /// No description provided for @profileRecipient.
  ///
  /// In zh, this message translates to:
  /// **'收貨人'**
  String get profileRecipient;

  /// No description provided for @profileEnterRecipientName.
  ///
  /// In zh, this message translates to:
  /// **'請輸入收貨人姓名'**
  String get profileEnterRecipientName;

  /// No description provided for @profilePhoneNumber.
  ///
  /// In zh, this message translates to:
  /// **'手機號碼'**
  String get profilePhoneNumber;

  /// No description provided for @profileEnterPhoneNumber.
  ///
  /// In zh, this message translates to:
  /// **'請輸入手機號碼'**
  String get profileEnterPhoneNumber;

  /// No description provided for @profileRegionHint.
  ///
  /// In zh, this message translates to:
  /// **'省/市/區'**
  String get profileRegionHint;

  /// No description provided for @profileDetailedAddress.
  ///
  /// In zh, this message translates to:
  /// **'詳細地址'**
  String get profileDetailedAddress;

  /// No description provided for @profileDetailedAddressHint.
  ///
  /// In zh, this message translates to:
  /// **'街道、門牌號等'**
  String get profileDetailedAddressHint;

  /// No description provided for @profileSetAsDefaultAddress.
  ///
  /// In zh, this message translates to:
  /// **'設爲默認地址'**
  String get profileSetAsDefaultAddress;

  /// No description provided for @profilePleaseCompleteInfo.
  ///
  /// In zh, this message translates to:
  /// **'請填寫完整信息'**
  String get profilePleaseCompleteInfo;

  /// No description provided for @profileEditInvoice.
  ///
  /// In zh, this message translates to:
  /// **'編輯發票抬頭'**
  String get profileEditInvoice;

  /// No description provided for @profileInvoiceType.
  ///
  /// In zh, this message translates to:
  /// **'抬頭類型'**
  String get profileInvoiceType;

  /// No description provided for @profileCompanyName.
  ///
  /// In zh, this message translates to:
  /// **'企業名稱'**
  String get profileCompanyName;

  /// No description provided for @profilePersonalName.
  ///
  /// In zh, this message translates to:
  /// **'個人姓名'**
  String get profilePersonalName;

  /// No description provided for @profileEnterCompanyName.
  ///
  /// In zh, this message translates to:
  /// **'請輸入企業名稱'**
  String get profileEnterCompanyName;

  /// No description provided for @profileEnterName.
  ///
  /// In zh, this message translates to:
  /// **'請輸入姓名'**
  String get profileEnterName;

  /// No description provided for @profileTaxIdNumber.
  ///
  /// In zh, this message translates to:
  /// **'納稅人識別號'**
  String get profileTaxIdNumber;

  /// No description provided for @profileEnterTaxIdNumber.
  ///
  /// In zh, this message translates to:
  /// **'請輸入納稅人識別號'**
  String get profileEnterTaxIdNumber;

  /// No description provided for @profileBankNameOptional.
  ///
  /// In zh, this message translates to:
  /// **'開戶銀行（選填）'**
  String get profileBankNameOptional;

  /// No description provided for @profileEnterBankName.
  ///
  /// In zh, this message translates to:
  /// **'請輸入開戶銀行'**
  String get profileEnterBankName;

  /// No description provided for @profileBankAccountOptional.
  ///
  /// In zh, this message translates to:
  /// **'銀行賬號（選填）'**
  String get profileBankAccountOptional;

  /// No description provided for @profileEnterBankAccount.
  ///
  /// In zh, this message translates to:
  /// **'請輸入銀行賬號'**
  String get profileEnterBankAccount;

  /// No description provided for @profileCompanyAddressOptional.
  ///
  /// In zh, this message translates to:
  /// **'企業地址（選填）'**
  String get profileCompanyAddressOptional;

  /// No description provided for @profileEnterCompanyAddress.
  ///
  /// In zh, this message translates to:
  /// **'請輸入企業地址'**
  String get profileEnterCompanyAddress;

  /// No description provided for @profileCompanyPhoneOptional.
  ///
  /// In zh, this message translates to:
  /// **'企業電話（選填）'**
  String get profileCompanyPhoneOptional;

  /// No description provided for @profileEnterCompanyPhone.
  ///
  /// In zh, this message translates to:
  /// **'請輸入企業電話'**
  String get profileEnterCompanyPhone;

  /// No description provided for @profileSetAsDefaultInvoice.
  ///
  /// In zh, this message translates to:
  /// **'設爲默認抬頭'**
  String get profileSetAsDefaultInvoice;

  /// No description provided for @profileRingtoneVibrate.
  ///
  /// In zh, this message translates to:
  /// **'震動'**
  String get profileRingtoneVibrate;

  /// No description provided for @profileRingtoneSilent.
  ///
  /// In zh, this message translates to:
  /// **'靜音'**
  String get profileRingtoneSilent;

  /// No description provided for @profileVibrateMode.
  ///
  /// In zh, this message translates to:
  /// **'振動模式'**
  String get profileVibrateMode;

  /// No description provided for @profileSilentMode.
  ///
  /// In zh, this message translates to:
  /// **'靜音模式'**
  String get profileSilentMode;

  /// No description provided for @profilePlayFailed.
  ///
  /// In zh, this message translates to:
  /// **'播放失敗: {ringtoneName}'**
  String profilePlayFailed(String ringtoneName);

  /// No description provided for @profilePlaying.
  ///
  /// In zh, this message translates to:
  /// **'正在播放: {ringtoneName}'**
  String profilePlaying(String ringtoneName);

  /// No description provided for @profileStop.
  ///
  /// In zh, this message translates to:
  /// **'停止'**
  String get profileStop;

  /// No description provided for @profileSelectRingtone.
  ///
  /// In zh, this message translates to:
  /// **'選擇鈴聲'**
  String get profileSelectRingtone;

  /// No description provided for @profileLoadingRingtones.
  ///
  /// In zh, this message translates to:
  /// **'加載鈴聲中...'**
  String get profileLoadingRingtones;

  /// No description provided for @profileNoRingtonesFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到鈴聲'**
  String get profileNoRingtonesFound;

  /// No description provided for @mainMessagesWithCount.
  ///
  /// In zh, this message translates to:
  /// **'消息({count})'**
  String mainMessagesWithCount(int count);

  /// No description provided for @storyViewers.
  ///
  /// In zh, this message translates to:
  /// **'瀏覽者'**
  String get storyViewers;

  /// No description provided for @storyNoViewers.
  ///
  /// In zh, this message translates to:
  /// **'暫無瀏覽'**
  String get storyNoViewers;

  /// No description provided for @storyReplyToStory.
  ///
  /// In zh, this message translates to:
  /// **'回覆狀態...'**
  String get storyReplyToStory;

  /// No description provided for @commonCopiedToClipboard.
  ///
  /// In zh, this message translates to:
  /// **'已複製到剪貼板'**
  String get commonCopiedToClipboard;

  /// No description provided for @commonMore.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get commonMore;

  /// No description provided for @commonTranslating.
  ///
  /// In zh, this message translates to:
  /// **'翻譯中...'**
  String get commonTranslating;

  /// No description provided for @commonTranslatedFrom.
  ///
  /// In zh, this message translates to:
  /// **'翻譯自{language}'**
  String commonTranslatedFrom(String language);

  /// No description provided for @commonTranslation.
  ///
  /// In zh, this message translates to:
  /// **'翻譯'**
  String get commonTranslation;

  /// No description provided for @commonTranslationFailed.
  ///
  /// In zh, this message translates to:
  /// **'翻譯失敗'**
  String get commonTranslationFailed;

  /// No description provided for @commonAllRead.
  ///
  /// In zh, this message translates to:
  /// **'全部已讀'**
  String get commonAllRead;

  /// No description provided for @commonReadCount.
  ///
  /// In zh, this message translates to:
  /// **'{count}人已讀'**
  String commonReadCount(int count);

  /// No description provided for @commonYouRecalledMessage.
  ///
  /// In zh, this message translates to:
  /// **'你撤回了一條消息'**
  String get commonYouRecalledMessage;

  /// No description provided for @commonMessageRecalled.
  ///
  /// In zh, this message translates to:
  /// **'對方撤回了一條消息'**
  String get commonMessageRecalled;

  /// No description provided for @commonReEdit.
  ///
  /// In zh, this message translates to:
  /// **'重新編輯'**
  String get commonReEdit;

  /// No description provided for @commonWalletArea.
  ///
  /// In zh, this message translates to:
  /// **'錢包功能區域'**
  String get commonWalletArea;

  /// No description provided for @callIncomingCall.
  ///
  /// In zh, this message translates to:
  /// **'來電'**
  String get callIncomingCall;

  /// No description provided for @callMissedCall.
  ///
  /// In zh, this message translates to:
  /// **'未接來電'**
  String get callMissedCall;

  /// No description provided for @groupRemoveAdmin.
  ///
  /// In zh, this message translates to:
  /// **'取消管理員'**
  String get groupRemoveAdmin;

  /// No description provided for @chatSelectCurrency.
  ///
  /// In zh, this message translates to:
  /// **'選擇幣種'**
  String get chatSelectCurrency;

  /// No description provided for @chatSelectEmoji.
  ///
  /// In zh, this message translates to:
  /// **'選擇表情'**
  String get chatSelectEmoji;

  /// No description provided for @chatSelectRedPacketCover.
  ///
  /// In zh, this message translates to:
  /// **'選擇封面'**
  String get chatSelectRedPacketCover;

  /// No description provided for @groupSetAsAdmin.
  ///
  /// In zh, this message translates to:
  /// **'設爲管理員'**
  String get groupSetAsAdmin;

  /// No description provided for @chatVideoPlaybackFailed.
  ///
  /// In zh, this message translates to:
  /// **'視頻播放失敗'**
  String get chatVideoPlaybackFailed;

  /// No description provided for @groupViewProfile.
  ///
  /// In zh, this message translates to:
  /// **'查看資料'**
  String get groupViewProfile;

  /// No description provided for @favoriteAddLinkComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'添加鏈接功能即將推出'**
  String get favoriteAddLinkComingSoon;

  /// No description provided for @favoriteNewNoteComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'新建筆記功能即將推出'**
  String get favoriteNewNoteComingSoon;

  /// No description provided for @qrcodeSaveFeatureComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'保存功能即將推出'**
  String get qrcodeSaveFeatureComingSoon;

  /// No description provided for @qrcodeShareFeatureComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'分享功能即將推出'**
  String get qrcodeShareFeatureComingSoon;

  /// No description provided for @qrcodeProcessFailed.
  ///
  /// In zh, this message translates to:
  /// **'處理二維碼失敗: {error}'**
  String qrcodeProcessFailed(String error);

  /// No description provided for @securityDeviceIdRequired.
  ///
  /// In zh, this message translates to:
  /// **'需要設備 ID'**
  String get securityDeviceIdRequired;

  /// No description provided for @securityVerificationStartFailed.
  ///
  /// In zh, this message translates to:
  /// **'啓動驗證失敗: {error}'**
  String securityVerificationStartFailed(String error);

  /// No description provided for @securityVerificationFailed.
  ///
  /// In zh, this message translates to:
  /// **'驗證失敗'**
  String get securityVerificationFailed;

  /// No description provided for @securityVerificationFailedWithReason.
  ///
  /// In zh, this message translates to:
  /// **'驗證失敗: {reason}'**
  String securityVerificationFailedWithReason(String reason);

  /// No description provided for @securityEmojiMismatchRejected.
  ///
  /// In zh, this message translates to:
  /// **'驗證被拒絕 - 表情不匹配'**
  String get securityEmojiMismatchRejected;

  /// No description provided for @securityWaitingForDeviceAccept.
  ///
  /// In zh, this message translates to:
  /// **'等待另一臺設備接受...'**
  String get securityWaitingForDeviceAccept;

  /// No description provided for @securityVerifyDevice.
  ///
  /// In zh, this message translates to:
  /// **'驗證此設備'**
  String get securityVerifyDevice;

  /// No description provided for @securityConfirmEmojiMatch.
  ///
  /// In zh, this message translates to:
  /// **'確認以下表情符號在兩臺設備上以相同順序顯示'**
  String get securityConfirmEmojiMatch;

  /// No description provided for @securityEmojiDontMatch.
  ///
  /// In zh, this message translates to:
  /// **'不匹配'**
  String get securityEmojiDontMatch;

  /// No description provided for @securityEmojiMatch.
  ///
  /// In zh, this message translates to:
  /// **'匹配'**
  String get securityEmojiMatch;

  /// No description provided for @securityWaitingForDeviceConfirm.
  ///
  /// In zh, this message translates to:
  /// **'等待另一臺設備確認...'**
  String get securityWaitingForDeviceConfirm;

  /// No description provided for @securityVerificationSuccess.
  ///
  /// In zh, this message translates to:
  /// **'驗證成功！'**
  String get securityVerificationSuccess;

  /// No description provided for @securityDeviceVerifiedTrusted.
  ///
  /// In zh, this message translates to:
  /// **'此設備已驗證並可信任。'**
  String get securityDeviceVerifiedTrusted;

  /// No description provided for @securityCompareEmoji.
  ///
  /// In zh, this message translates to:
  /// **'比較兩臺設備上的表情符號'**
  String get securityCompareEmoji;

  /// No description provided for @securityCompareNumbers.
  ///
  /// In zh, this message translates to:
  /// **'比較兩臺設備上的數字'**
  String get securityCompareNumbers;

  /// No description provided for @commonTryAgain.
  ///
  /// In zh, this message translates to:
  /// **'重試'**
  String get commonTryAgain;

  /// No description provided for @commonDone.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get commonDone;

  /// No description provided for @chatExportTitle.
  ///
  /// In zh, this message translates to:
  /// **'導出聊天記錄'**
  String get chatExportTitle;

  /// No description provided for @chatExportSuccess.
  ///
  /// In zh, this message translates to:
  /// **'導出成功'**
  String get chatExportSuccess;

  /// No description provided for @chatExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'導出失敗: {error}'**
  String chatExportFailed(String error);

  /// No description provided for @chatExportFormat.
  ///
  /// In zh, this message translates to:
  /// **'導出格式'**
  String get chatExportFormat;

  /// No description provided for @chatExportHtmlDesc.
  ///
  /// In zh, this message translates to:
  /// **'可在任何瀏覽器中打開的精美排版'**
  String get chatExportHtmlDesc;

  /// No description provided for @chatExportJsonDesc.
  ///
  /// In zh, this message translates to:
  /// **'機器可讀的結構化數據格式'**
  String get chatExportJsonDesc;

  /// No description provided for @chatExportDateRange.
  ///
  /// In zh, this message translates to:
  /// **'日期範圍'**
  String get chatExportDateRange;

  /// No description provided for @chatExportAll.
  ///
  /// In zh, this message translates to:
  /// **'全部消息'**
  String get chatExportAll;

  /// No description provided for @chatExportLastWeek.
  ///
  /// In zh, this message translates to:
  /// **'最近7天'**
  String get chatExportLastWeek;

  /// No description provided for @chatExportLastMonth.
  ///
  /// In zh, this message translates to:
  /// **'最近一個月'**
  String get chatExportLastMonth;

  /// No description provided for @chatExportLast3Months.
  ///
  /// In zh, this message translates to:
  /// **'最近三個月'**
  String get chatExportLast3Months;

  /// No description provided for @chatExportMessageCount.
  ///
  /// In zh, this message translates to:
  /// **'待導出消息'**
  String get chatExportMessageCount;

  /// No description provided for @chatExportButton.
  ///
  /// In zh, this message translates to:
  /// **'導出並分享'**
  String get chatExportButton;

  /// No description provided for @chatMediaGallery.
  ///
  /// In zh, this message translates to:
  /// **'媒體文件'**
  String get chatMediaGallery;

  /// No description provided for @chatExportHistory.
  ///
  /// In zh, this message translates to:
  /// **'導出聊天記錄'**
  String get chatExportHistory;

  /// No description provided for @pdfLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加載 PDF 失敗'**
  String get pdfLoadFailed;

  /// No description provided for @pdfPageIndicator.
  ///
  /// In zh, this message translates to:
  /// **'{current} / {total}'**
  String pdfPageIndicator(int current, int total);

  /// No description provided for @mediaAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get mediaAll;

  /// No description provided for @mediaImages.
  ///
  /// In zh, this message translates to:
  /// **'圖片'**
  String get mediaImages;

  /// No description provided for @mediaVideos.
  ///
  /// In zh, this message translates to:
  /// **'視頻'**
  String get mediaVideos;

  /// No description provided for @mediaFiles.
  ///
  /// In zh, this message translates to:
  /// **'文件'**
  String get mediaFiles;

  /// No description provided for @mediaAudio.
  ///
  /// In zh, this message translates to:
  /// **'音頻'**
  String get mediaAudio;

  /// No description provided for @mediaItemsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 項'**
  String mediaItemsCount(int count);

  /// No description provided for @mediaNoMediaFound.
  ///
  /// In zh, this message translates to:
  /// **'暫無媒體文件'**
  String get mediaNoMediaFound;

  /// No description provided for @spacesTitle.
  ///
  /// In zh, this message translates to:
  /// **'社區'**
  String get spacesTitle;

  /// No description provided for @spacesCreate.
  ///
  /// In zh, this message translates to:
  /// **'創建社區'**
  String get spacesCreate;

  /// No description provided for @spacesJoined.
  ///
  /// In zh, this message translates to:
  /// **'已加入'**
  String get spacesJoined;

  /// No description provided for @spacesDiscover.
  ///
  /// In zh, this message translates to:
  /// **'發現'**
  String get spacesDiscover;

  /// No description provided for @spacesNoJoined.
  ///
  /// In zh, this message translates to:
  /// **'還沒有加入任何社區'**
  String get spacesNoJoined;

  /// No description provided for @spacesExplore.
  ///
  /// In zh, this message translates to:
  /// **'探索社區'**
  String get spacesExplore;

  /// No description provided for @spacesNoPublic.
  ///
  /// In zh, this message translates to:
  /// **'沒有找到公共社區'**
  String get spacesNoPublic;

  /// No description provided for @spacesJoin.
  ///
  /// In zh, this message translates to:
  /// **'加入'**
  String get spacesJoin;

  /// No description provided for @spacesSubSpaces.
  ///
  /// In zh, this message translates to:
  /// **'子社區'**
  String get spacesSubSpaces;

  /// No description provided for @spacesChannels.
  ///
  /// In zh, this message translates to:
  /// **'頻道'**
  String get spacesChannels;

  /// No description provided for @spacesMembersCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 位成員'**
  String spacesMembersCount(int count);

  /// No description provided for @spacesPublic.
  ///
  /// In zh, this message translates to:
  /// **'公開'**
  String get spacesPublic;

  /// No description provided for @spacesPrivate.
  ///
  /// In zh, this message translates to:
  /// **'私密'**
  String get spacesPrivate;

  /// No description provided for @spacesSuggested.
  ///
  /// In zh, this message translates to:
  /// **'推薦'**
  String get spacesSuggested;

  /// No description provided for @spacesChannelsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 個頻道'**
  String spacesChannelsCount(int count);

  /// No description provided for @callInCallChat.
  ///
  /// In zh, this message translates to:
  /// **'通話中聊天'**
  String get callInCallChat;

  /// No description provided for @callMessagesCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 條消息'**
  String callMessagesCount(int count);

  /// No description provided for @callNoMessagesYet.
  ///
  /// In zh, this message translates to:
  /// **'暫無消息\n發送一條消息開始聊天'**
  String get callNoMessagesYet;

  /// No description provided for @callTypeMessage.
  ///
  /// In zh, this message translates to:
  /// **'輸入消息...'**
  String get callTypeMessage;

  /// No description provided for @callYouSender.
  ///
  /// In zh, this message translates to:
  /// **'我'**
  String get callYouSender;

  /// No description provided for @callChatLabel.
  ///
  /// In zh, this message translates to:
  /// **'聊天'**
  String get callChatLabel;

  /// No description provided for @chatEdited.
  ///
  /// In zh, this message translates to:
  /// **'已編輯'**
  String get chatEdited;

  /// No description provided for @chatEditHistory.
  ///
  /// In zh, this message translates to:
  /// **'編輯歷史'**
  String get chatEditHistory;

  /// No description provided for @chatOriginalMessage.
  ///
  /// In zh, this message translates to:
  /// **'原始消息'**
  String get chatOriginalMessage;

  /// No description provided for @chatEditedAt.
  ///
  /// In zh, this message translates to:
  /// **'編輯於 {time}'**
  String chatEditedAt(String time);

  /// No description provided for @chatViewOnce.
  ///
  /// In zh, this message translates to:
  /// **'閱後即焚'**
  String get chatViewOnce;

  /// No description provided for @chatViewOncePhoto.
  ///
  /// In zh, this message translates to:
  /// **'閱後即焚照片'**
  String get chatViewOncePhoto;

  /// No description provided for @chatViewOnceVideo.
  ///
  /// In zh, this message translates to:
  /// **'閱後即焚視頻'**
  String get chatViewOnceVideo;

  /// No description provided for @chatViewOnceViewed.
  ///
  /// In zh, this message translates to:
  /// **'已查看'**
  String get chatViewOnceViewed;

  /// No description provided for @chatViewOnceExpired.
  ///
  /// In zh, this message translates to:
  /// **'已過期'**
  String get chatViewOnceExpired;

  /// No description provided for @chatViewOnceTap.
  ///
  /// In zh, this message translates to:
  /// **'點擊查看'**
  String get chatViewOnceTap;

  /// No description provided for @chatAutoFaceBlur.
  ///
  /// In zh, this message translates to:
  /// **'自動模糊人臉'**
  String get chatAutoFaceBlur;

  /// No description provided for @chatAutoFaceBlurDesc.
  ///
  /// In zh, this message translates to:
  /// **'發送照片時自動模糊人臉'**
  String get chatAutoFaceBlurDesc;

  /// No description provided for @threadReplyInThread.
  ///
  /// In zh, this message translates to:
  /// **'在線程中回覆'**
  String get threadReplyInThread;

  /// No description provided for @threadReplies.
  ///
  /// In zh, this message translates to:
  /// **'{count} 條回覆'**
  String threadReplies(int count);

  /// No description provided for @threadReply.
  ///
  /// In zh, this message translates to:
  /// **'1 條回覆'**
  String get threadReply;

  /// No description provided for @threadLatestReply.
  ///
  /// In zh, this message translates to:
  /// **'最新: {preview}'**
  String threadLatestReply(String preview);

  /// No description provided for @threadTitle.
  ///
  /// In zh, this message translates to:
  /// **'消息線程'**
  String get threadTitle;

  /// No description provided for @threadReplyPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'在線程中回覆...'**
  String get threadReplyPlaceholder;

  /// No description provided for @threadParticipants.
  ///
  /// In zh, this message translates to:
  /// **'{count} 位參與者'**
  String threadParticipants(int count);

  /// No description provided for @voiceRoomTitle.
  ///
  /// In zh, this message translates to:
  /// **'語音聊天室'**
  String get voiceRoomTitle;

  /// No description provided for @voiceRoomCreate.
  ///
  /// In zh, this message translates to:
  /// **'創建語音房間'**
  String get voiceRoomCreate;

  /// No description provided for @voiceRoomJoin.
  ///
  /// In zh, this message translates to:
  /// **'加入'**
  String get voiceRoomJoin;

  /// No description provided for @voiceRoomLeave.
  ///
  /// In zh, this message translates to:
  /// **'離開'**
  String get voiceRoomLeave;

  /// No description provided for @voiceRoomEnd.
  ///
  /// In zh, this message translates to:
  /// **'結束房間'**
  String get voiceRoomEnd;

  /// No description provided for @voiceRoomRaiseHand.
  ///
  /// In zh, this message translates to:
  /// **'舉手'**
  String get voiceRoomRaiseHand;

  /// No description provided for @voiceRoomLowerHand.
  ///
  /// In zh, this message translates to:
  /// **'放下手'**
  String get voiceRoomLowerHand;

  /// No description provided for @voiceRoomMute.
  ///
  /// In zh, this message translates to:
  /// **'靜音'**
  String get voiceRoomMute;

  /// No description provided for @voiceRoomUnmute.
  ///
  /// In zh, this message translates to:
  /// **'取消靜音'**
  String get voiceRoomUnmute;

  /// No description provided for @voiceRoomHost.
  ///
  /// In zh, this message translates to:
  /// **'主持人'**
  String get voiceRoomHost;

  /// No description provided for @voiceRoomSpeakers.
  ///
  /// In zh, this message translates to:
  /// **'發言者'**
  String get voiceRoomSpeakers;

  /// No description provided for @voiceRoomListeners.
  ///
  /// In zh, this message translates to:
  /// **'聽衆'**
  String get voiceRoomListeners;

  /// No description provided for @voiceRoomLive.
  ///
  /// In zh, this message translates to:
  /// **'直播中'**
  String get voiceRoomLive;

  /// No description provided for @voiceRoomEnded.
  ///
  /// In zh, this message translates to:
  /// **'已結束'**
  String get voiceRoomEnded;

  /// No description provided for @voiceRoomScheduled.
  ///
  /// In zh, this message translates to:
  /// **'已預約'**
  String get voiceRoomScheduled;

  /// No description provided for @voiceRoomApprove.
  ///
  /// In zh, this message translates to:
  /// **'批准發言'**
  String get voiceRoomApprove;

  /// No description provided for @voiceRoomDemote.
  ///
  /// In zh, this message translates to:
  /// **'移至聽衆'**
  String get voiceRoomDemote;

  /// No description provided for @voiceRoomHandRaised.
  ///
  /// In zh, this message translates to:
  /// **'{name} 舉手了'**
  String voiceRoomHandRaised(String name);

  /// No description provided for @voiceRoomName.
  ///
  /// In zh, this message translates to:
  /// **'房間名稱'**
  String get voiceRoomName;

  /// No description provided for @voiceRoomTopic.
  ///
  /// In zh, this message translates to:
  /// **'話題（可選）'**
  String get voiceRoomTopic;

  /// No description provided for @voiceRoomNoActive.
  ///
  /// In zh, this message translates to:
  /// **'暫無活躍的語音房間'**
  String get voiceRoomNoActive;

  /// No description provided for @voiceRoomConnecting.
  ///
  /// In zh, this message translates to:
  /// **'連接中...'**
  String get voiceRoomConnecting;

  /// No description provided for @usernameTitle.
  ///
  /// In zh, this message translates to:
  /// **'用戶名'**
  String get usernameTitle;

  /// No description provided for @usernameSet.
  ///
  /// In zh, this message translates to:
  /// **'設置用戶名'**
  String get usernameSet;

  /// No description provided for @usernameChange.
  ///
  /// In zh, this message translates to:
  /// **'修改用戶名'**
  String get usernameChange;

  /// No description provided for @usernamePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'輸入用戶名'**
  String get usernamePlaceholder;

  /// No description provided for @usernameAvailable.
  ///
  /// In zh, this message translates to:
  /// **'用戶名可用'**
  String get usernameAvailable;

  /// No description provided for @usernameUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'用戶名已被佔用'**
  String get usernameUnavailable;

  /// No description provided for @usernameInvalid.
  ///
  /// In zh, this message translates to:
  /// **'3-30個字符，小寫字母、數字、下劃線，必須以字母開頭'**
  String get usernameInvalid;

  /// No description provided for @usernameReserved.
  ///
  /// In zh, this message translates to:
  /// **'此用戶名爲保留名稱'**
  String get usernameReserved;

  /// No description provided for @usernameSaved.
  ///
  /// In zh, this message translates to:
  /// **'用戶名已保存'**
  String get usernameSaved;

  /// No description provided for @usernameSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'通過 @用戶名 搜索'**
  String get usernameSearchHint;

  /// No description provided for @ensName.
  ///
  /// In zh, this message translates to:
  /// **'ENS 域名'**
  String get ensName;

  /// No description provided for @ensLinked.
  ///
  /// In zh, this message translates to:
  /// **'已關聯 ENS'**
  String get ensLinked;

  /// No description provided for @ensResolving.
  ///
  /// In zh, this message translates to:
  /// **'正在解析 ENS...'**
  String get ensResolving;

  /// No description provided for @ensNotFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到 ENS 域名'**
  String get ensNotFound;

  /// No description provided for @tokenGateTitle.
  ///
  /// In zh, this message translates to:
  /// **'代幣門控'**
  String get tokenGateTitle;

  /// No description provided for @tokenGateEnable.
  ///
  /// In zh, this message translates to:
  /// **'啓用代幣門控'**
  String get tokenGateEnable;

  /// No description provided for @tokenGateDisable.
  ///
  /// In zh, this message translates to:
  /// **'禁用代幣門控'**
  String get tokenGateDisable;

  /// No description provided for @tokenGateAddRule.
  ///
  /// In zh, this message translates to:
  /// **'添加規則'**
  String get tokenGateAddRule;

  /// No description provided for @tokenGateRemoveRule.
  ///
  /// In zh, this message translates to:
  /// **'刪除規則'**
  String get tokenGateRemoveRule;

  /// No description provided for @tokenGateContractAddress.
  ///
  /// In zh, this message translates to:
  /// **'合約地址'**
  String get tokenGateContractAddress;

  /// No description provided for @tokenGateMinBalance.
  ///
  /// In zh, this message translates to:
  /// **'最低餘額'**
  String get tokenGateMinBalance;

  /// No description provided for @tokenGateTokenId.
  ///
  /// In zh, this message translates to:
  /// **'Token ID (ERC-1155)'**
  String get tokenGateTokenId;

  /// No description provided for @tokenGateChainId.
  ///
  /// In zh, this message translates to:
  /// **'鏈 ID'**
  String get tokenGateChainId;

  /// No description provided for @tokenGateVerifying.
  ///
  /// In zh, this message translates to:
  /// **'正在驗證代幣持有...'**
  String get tokenGateVerifying;

  /// No description provided for @tokenGateVerified.
  ///
  /// In zh, this message translates to:
  /// **'驗證通過'**
  String get tokenGateVerified;

  /// No description provided for @tokenGateDenied.
  ///
  /// In zh, this message translates to:
  /// **'您未滿足代幣要求'**
  String get tokenGateDenied;

  /// No description provided for @tokenGateOperatorAnd.
  ///
  /// In zh, this message translates to:
  /// **'需滿足所有規則'**
  String get tokenGateOperatorAnd;

  /// No description provided for @tokenGateOperatorOr.
  ///
  /// In zh, this message translates to:
  /// **'滿足任一規則即可'**
  String get tokenGateOperatorOr;

  /// No description provided for @tokenGateRuleErc20.
  ///
  /// In zh, this message translates to:
  /// **'ERC-20 代幣'**
  String get tokenGateRuleErc20;

  /// No description provided for @tokenGateRuleErc721.
  ///
  /// In zh, this message translates to:
  /// **'NFT (ERC-721)'**
  String get tokenGateRuleErc721;

  /// No description provided for @tokenGateRuleErc1155.
  ///
  /// In zh, this message translates to:
  /// **'多代幣 (ERC-1155)'**
  String get tokenGateRuleErc1155;

  /// No description provided for @tokenGateRuleNative.
  ///
  /// In zh, this message translates to:
  /// **'原生代幣'**
  String get tokenGateRuleNative;

  /// No description provided for @tokenGateSaved.
  ///
  /// In zh, this message translates to:
  /// **'代幣門控已保存'**
  String get tokenGateSaved;

  /// No description provided for @tokenGateEnableDescription.
  ///
  /// In zh, this message translates to:
  /// **'要求成員持有指定代幣才能加入'**
  String get tokenGateEnableDescription;

  /// No description provided for @tokenGateOperator.
  ///
  /// In zh, this message translates to:
  /// **'規則邏輯'**
  String get tokenGateOperator;

  /// No description provided for @tokenGateRules.
  ///
  /// In zh, this message translates to:
  /// **'規則列表'**
  String get tokenGateRules;

  /// No description provided for @tokenGateSymbol.
  ///
  /// In zh, this message translates to:
  /// **'代幣符號（可選）'**
  String get tokenGateSymbol;

  /// No description provided for @tokenGateChain.
  ///
  /// In zh, this message translates to:
  /// **'區塊鏈'**
  String get tokenGateChain;

  /// No description provided for @tokenGateTokenStandard.
  ///
  /// In zh, this message translates to:
  /// **'代幣標準'**
  String get tokenGateTokenStandard;

  /// No description provided for @tokenGateDenialMessage.
  ///
  /// In zh, this message translates to:
  /// **'拒絕消息'**
  String get tokenGateDenialMessage;

  /// No description provided for @tokenGateDenialMessageHint.
  ///
  /// In zh, this message translates to:
  /// **'驗證失敗時顯示的消息'**
  String get tokenGateDenialMessageHint;

  /// No description provided for @tokenGateVerifyTitle.
  ///
  /// In zh, this message translates to:
  /// **'代幣驗證'**
  String get tokenGateVerifyTitle;

  /// No description provided for @tokenGateVerifyPassed.
  ///
  /// In zh, this message translates to:
  /// **'驗證通過'**
  String get tokenGateVerifyPassed;

  /// No description provided for @tokenGateVerifyFailed.
  ///
  /// In zh, this message translates to:
  /// **'驗證未通過'**
  String get tokenGateVerifyFailed;

  /// No description provided for @tokenGateRetryVerify.
  ///
  /// In zh, this message translates to:
  /// **'重新驗證'**
  String get tokenGateRetryVerify;

  /// No description provided for @tokenGateRequired.
  ///
  /// In zh, this message translates to:
  /// **'要求'**
  String get tokenGateRequired;

  /// No description provided for @tokenGateYourBalance.
  ///
  /// In zh, this message translates to:
  /// **'你的餘額'**
  String get tokenGateYourBalance;

  /// No description provided for @tokenGateRulesActive.
  ///
  /// In zh, this message translates to:
  /// **'條規則生效'**
  String get tokenGateRulesActive;

  /// No description provided for @tokenGateDisabled.
  ///
  /// In zh, this message translates to:
  /// **'未啓用'**
  String get tokenGateDisabled;

  /// No description provided for @ensNotBound.
  ///
  /// In zh, this message translates to:
  /// **'未綁定'**
  String get ensNotBound;

  /// No description provided for @liveLocation.
  ///
  /// In zh, this message translates to:
  /// **'實時位置'**
  String get liveLocation;

  /// No description provided for @stopLiveLocation.
  ///
  /// In zh, this message translates to:
  /// **'停止共享'**
  String get stopLiveLocation;

  /// No description provided for @startLiveLocation.
  ///
  /// In zh, this message translates to:
  /// **'開始共享'**
  String get startLiveLocation;

  /// No description provided for @selectDuration.
  ///
  /// In zh, this message translates to:
  /// **'選擇共享時長'**
  String get selectDuration;

  /// No description provided for @groupChatFiles.
  ///
  /// In zh, this message translates to:
  /// **'聊天文件'**
  String get groupChatFiles;

  /// No description provided for @groupLinks.
  ///
  /// In zh, this message translates to:
  /// **'鏈接'**
  String get groupLinks;

  /// No description provided for @groupNoLinks.
  ///
  /// In zh, this message translates to:
  /// **'暫無鏈接'**
  String get groupNoLinks;

  /// No description provided for @chatBackground.
  ///
  /// In zh, this message translates to:
  /// **'聊天背景'**
  String get chatBackground;

  /// No description provided for @solidColors.
  ///
  /// In zh, this message translates to:
  /// **'純色'**
  String get solidColors;

  /// No description provided for @gradients.
  ///
  /// In zh, this message translates to:
  /// **'漸變'**
  String get gradients;

  /// No description provided for @defaultBackground.
  ///
  /// In zh, this message translates to:
  /// **'默認'**
  String get defaultBackground;

  /// No description provided for @settingsFontSizeSlider.
  ///
  /// In zh, this message translates to:
  /// **'字體大小'**
  String get settingsFontSizeSlider;

  /// No description provided for @autoDownload.
  ///
  /// In zh, this message translates to:
  /// **'自動下載'**
  String get autoDownload;

  /// No description provided for @images.
  ///
  /// In zh, this message translates to:
  /// **'圖片'**
  String get images;

  /// No description provided for @voice.
  ///
  /// In zh, this message translates to:
  /// **'語音'**
  String get voice;

  /// No description provided for @video.
  ///
  /// In zh, this message translates to:
  /// **'視頻'**
  String get video;

  /// No description provided for @files.
  ///
  /// In zh, this message translates to:
  /// **'文件'**
  String get files;

  /// No description provided for @mobileData.
  ///
  /// In zh, this message translates to:
  /// **'移動數據'**
  String get mobileData;

  /// No description provided for @roaming.
  ///
  /// In zh, this message translates to:
  /// **'漫遊'**
  String get roaming;

  /// No description provided for @storageManagement.
  ///
  /// In zh, this message translates to:
  /// **'存儲管理'**
  String get storageManagement;

  /// No description provided for @totalUsage.
  ///
  /// In zh, this message translates to:
  /// **'總用量'**
  String get totalUsage;

  /// No description provided for @cache.
  ///
  /// In zh, this message translates to:
  /// **'緩存'**
  String get cache;

  /// No description provided for @other.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get other;

  /// No description provided for @clearCache.
  ///
  /// In zh, this message translates to:
  /// **'清理緩存'**
  String get clearCache;

  /// No description provided for @cacheCleared.
  ///
  /// In zh, this message translates to:
  /// **'緩存已清除'**
  String get cacheCleared;

  /// No description provided for @clearCacheFailed.
  ///
  /// In zh, this message translates to:
  /// **'清理緩存失敗'**
  String get clearCacheFailed;

  /// No description provided for @confirmClearCache.
  ///
  /// In zh, this message translates to:
  /// **'確認清理所有緩存數據？'**
  String get confirmClearCache;

  /// No description provided for @mapView.
  ///
  /// In zh, this message translates to:
  /// **'地圖視圖'**
  String get mapView;

  /// No description provided for @liveLocationSharingCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人正在共享位置'**
  String liveLocationSharingCount(int count);

  /// No description provided for @minutes15.
  ///
  /// In zh, this message translates to:
  /// **'15 分鐘'**
  String get minutes15;

  /// No description provided for @minutes30.
  ///
  /// In zh, this message translates to:
  /// **'30 分鐘'**
  String get minutes30;

  /// No description provided for @hour1.
  ///
  /// In zh, this message translates to:
  /// **'1 小時'**
  String get hour1;

  /// No description provided for @hours8.
  ///
  /// In zh, this message translates to:
  /// **'8 小時'**
  String get hours8;

  /// No description provided for @personalCard.
  ///
  /// In zh, this message translates to:
  /// **'個人名片'**
  String get personalCard;

  /// No description provided for @downloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'下載失敗'**
  String get downloadFailed;

  /// No description provided for @locationExpired.
  ///
  /// In zh, this message translates to:
  /// **'已過期'**
  String get locationExpired;

  /// No description provided for @secondsRemaining.
  ///
  /// In zh, this message translates to:
  /// **'{count}秒'**
  String secondsRemaining(int count);

  /// No description provided for @minutesRemaining.
  ///
  /// In zh, this message translates to:
  /// **'{count}分鐘'**
  String minutesRemaining(int count);

  /// No description provided for @hoursMinutesRemaining.
  ///
  /// In zh, this message translates to:
  /// **'{hours}小時{minutes}分鐘'**
  String hoursMinutesRemaining(int hours, int minutes);

  /// No description provided for @favoriteMessages.
  ///
  /// In zh, this message translates to:
  /// **'收藏消息'**
  String get favoriteMessages;

  /// No description provided for @linksCopied.
  ///
  /// In zh, this message translates to:
  /// **'鏈接已複製'**
  String get linksCopied;

  /// No description provided for @noLinksFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到鏈接'**
  String get noLinksFound;

  /// No description provided for @roomStorageRanking.
  ///
  /// In zh, this message translates to:
  /// **'房間存儲排行'**
  String get roomStorageRanking;

  /// No description provided for @downloadComplete.
  ///
  /// In zh, this message translates to:
  /// **'下載完成'**
  String get downloadComplete;

  /// No description provided for @downloading.
  ///
  /// In zh, this message translates to:
  /// **'下載中...'**
  String get downloading;

  /// No description provided for @draftSaved.
  ///
  /// In zh, this message translates to:
  /// **'草稿已保存'**
  String get draftSaved;

  /// No description provided for @voiceRecording.
  ///
  /// In zh, this message translates to:
  /// **'語音錄製'**
  String get voiceRecording;

  /// No description provided for @searchLocation.
  ///
  /// In zh, this message translates to:
  /// **'搜索地點'**
  String get searchLocation;

  /// No description provided for @tapToSearch.
  ///
  /// In zh, this message translates to:
  /// **'點擊搜索'**
  String get tapToSearch;

  /// No description provided for @settingsThisDevice.
  ///
  /// In zh, this message translates to:
  /// **'本設備'**
  String get settingsThisDevice;

  /// No description provided for @settingsJustNow.
  ///
  /// In zh, this message translates to:
  /// **'剛剛'**
  String get settingsJustNow;

  /// No description provided for @settingsDeviceId.
  ///
  /// In zh, this message translates to:
  /// **'設備 ID'**
  String get settingsDeviceId;

  /// No description provided for @settingsStatus.
  ///
  /// In zh, this message translates to:
  /// **'狀態'**
  String get settingsStatus;

  /// No description provided for @settingsLastActive.
  ///
  /// In zh, this message translates to:
  /// **'最後活躍'**
  String get settingsLastActive;

  /// No description provided for @settingsIpAddress.
  ///
  /// In zh, this message translates to:
  /// **'IP 地址'**
  String get settingsIpAddress;

  /// No description provided for @settingsRenameDevice.
  ///
  /// In zh, this message translates to:
  /// **'重命名設備'**
  String get settingsRenameDevice;

  /// No description provided for @settingsDeviceNameHint.
  ///
  /// In zh, this message translates to:
  /// **'輸入設備名稱'**
  String get settingsDeviceNameHint;

  /// No description provided for @settingsDeviceRenamed.
  ///
  /// In zh, this message translates to:
  /// **'設備已重命名'**
  String get settingsDeviceRenamed;

  /// No description provided for @settingsRenameFailed.
  ///
  /// In zh, this message translates to:
  /// **'重命名失敗'**
  String get settingsRenameFailed;

  /// No description provided for @settingsRemoteLogout.
  ///
  /// In zh, this message translates to:
  /// **'遠程登出'**
  String get settingsRemoteLogout;

  /// No description provided for @settingsRemoteLogoutConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定要登出「{deviceName}」嗎？此操作無法撤銷。'**
  String settingsRemoteLogoutConfirm(String deviceName);

  /// No description provided for @settingsDeviceLoggedOut.
  ///
  /// In zh, this message translates to:
  /// **'設備已登出'**
  String get settingsDeviceLoggedOut;

  /// No description provided for @settingsLogoutFailed.
  ///
  /// In zh, this message translates to:
  /// **'登出失敗'**
  String get settingsLogoutFailed;

  /// No description provided for @settingsLogout.
  ///
  /// In zh, this message translates to:
  /// **'登出'**
  String get settingsLogout;

  /// No description provided for @settingsVerifyIdentity.
  ///
  /// In zh, this message translates to:
  /// **'驗證身份'**
  String get settingsVerifyIdentity;

  /// No description provided for @settingsEnterPasswordToConfirm.
  ///
  /// In zh, this message translates to:
  /// **'請輸入密碼以確認此操作。'**
  String get settingsEnterPasswordToConfirm;

  /// No description provided for @scheduledSendTitle.
  ///
  /// In zh, this message translates to:
  /// **'定時發送'**
  String get scheduledSendTitle;

  /// No description provided for @scheduledSendInOneHour.
  ///
  /// In zh, this message translates to:
  /// **'1小時後'**
  String get scheduledSendInOneHour;

  /// No description provided for @scheduledSendTonight.
  ///
  /// In zh, this message translates to:
  /// **'今晚 (20:00)'**
  String get scheduledSendTonight;

  /// No description provided for @scheduledSendTomorrowMorning.
  ///
  /// In zh, this message translates to:
  /// **'明早 (9:00)'**
  String get scheduledSendTomorrowMorning;

  /// No description provided for @scheduledSendCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定義時間'**
  String get scheduledSendCustom;

  /// No description provided for @scheduledMessageLabel.
  ///
  /// In zh, this message translates to:
  /// **'定時發送'**
  String get scheduledMessageLabel;

  /// No description provided for @scheduledMessageCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消定時發送'**
  String get scheduledMessageCancel;

  /// No description provided for @chatLockTitle.
  ///
  /// In zh, this message translates to:
  /// **'聊天鎖'**
  String get chatLockTitle;

  /// No description provided for @chatLockEnable.
  ///
  /// In zh, this message translates to:
  /// **'鎖定此聊天'**
  String get chatLockEnable;

  /// No description provided for @chatLockDisable.
  ///
  /// In zh, this message translates to:
  /// **'解鎖此聊天'**
  String get chatLockDisable;

  /// No description provided for @chatLockDescription.
  ///
  /// In zh, this message translates to:
  /// **'鎖定的聊天需要通過生物識別或 PIN 碼驗證才能打開'**
  String get chatLockDescription;

  /// No description provided for @chatLockVerifyTitle.
  ///
  /// In zh, this message translates to:
  /// **'聊天已鎖定'**
  String get chatLockVerifyTitle;

  /// No description provided for @chatLockVerifySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'驗證後訪問此聊天'**
  String get chatLockVerifySubtitle;

  /// No description provided for @chatLockVerifyFailed.
  ///
  /// In zh, this message translates to:
  /// **'驗證失敗'**
  String get chatLockVerifyFailed;

  /// No description provided for @chatLockEnabled.
  ///
  /// In zh, this message translates to:
  /// **'聊天已鎖定'**
  String get chatLockEnabled;

  /// No description provided for @chatLockDisabled.
  ///
  /// In zh, this message translates to:
  /// **'聊天已解鎖'**
  String get chatLockDisabled;

  /// No description provided for @chatLockPinTitle.
  ///
  /// In zh, this message translates to:
  /// **'輸入 PIN 碼'**
  String get chatLockPinTitle;

  /// No description provided for @chatLockPinSetTitle.
  ///
  /// In zh, this message translates to:
  /// **'設置 PIN 碼'**
  String get chatLockPinSetTitle;

  /// No description provided for @chatLockPinConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'確認 PIN 碼'**
  String get chatLockPinConfirmTitle;

  /// No description provided for @chatLockPinMismatch.
  ///
  /// In zh, this message translates to:
  /// **'PIN 碼不一致'**
  String get chatLockPinMismatch;

  /// No description provided for @chatLockUseBiometric.
  ///
  /// In zh, this message translates to:
  /// **'使用生物識別'**
  String get chatLockUseBiometric;

  /// No description provided for @chatLockUsePin.
  ///
  /// In zh, this message translates to:
  /// **'使用 PIN 碼'**
  String get chatLockUsePin;

  /// No description provided for @mediaEditorUndo.
  ///
  /// In zh, this message translates to:
  /// **'撤銷'**
  String get mediaEditorUndo;

  /// No description provided for @mediaEditorRedo.
  ///
  /// In zh, this message translates to:
  /// **'重做'**
  String get mediaEditorRedo;

  /// No description provided for @mediaEditorCrop.
  ///
  /// In zh, this message translates to:
  /// **'裁剪'**
  String get mediaEditorCrop;

  /// No description provided for @mediaEditorFilter.
  ///
  /// In zh, this message translates to:
  /// **'濾鏡'**
  String get mediaEditorFilter;

  /// No description provided for @mediaEditorDraw.
  ///
  /// In zh, this message translates to:
  /// **'塗鴉'**
  String get mediaEditorDraw;

  /// No description provided for @mediaEditorText.
  ///
  /// In zh, this message translates to:
  /// **'文字'**
  String get mediaEditorText;

  /// No description provided for @aiAssistant.
  ///
  /// In zh, this message translates to:
  /// **'AI 助手'**
  String get aiAssistant;

  /// No description provided for @aiAssistantWelcome.
  ///
  /// In zh, this message translates to:
  /// **'你好！我是 N42 AI 助手，有什麼可以幫你的嗎？'**
  String get aiAssistantWelcome;

  /// No description provided for @aiAssistantNotConfigured.
  ///
  /// In zh, this message translates to:
  /// **'AI 服務未配置'**
  String get aiAssistantNotConfigured;

  /// No description provided for @aiAssistantSettings.
  ///
  /// In zh, this message translates to:
  /// **'AI 設置'**
  String get aiAssistantSettings;

  /// No description provided for @aiAssistantClearHistory.
  ///
  /// In zh, this message translates to:
  /// **'清空對話歷史'**
  String get aiAssistantClearHistory;

  /// No description provided for @aiAssistantClearHistoryConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定清空所有 AI 對話歷史？'**
  String get aiAssistantClearHistoryConfirm;

  /// No description provided for @aiAssistantStopGenerating.
  ///
  /// In zh, this message translates to:
  /// **'停止生成'**
  String get aiAssistantStopGenerating;

  /// No description provided for @aiAssistantModel.
  ///
  /// In zh, this message translates to:
  /// **'模型'**
  String get aiAssistantModel;

  /// No description provided for @aiAssistantTemperature.
  ///
  /// In zh, this message translates to:
  /// **'溫度'**
  String get aiAssistantTemperature;

  /// No description provided for @aiAssistantMaxTokens.
  ///
  /// In zh, this message translates to:
  /// **'最大令牌數'**
  String get aiAssistantMaxTokens;

  /// No description provided for @aiAssistantContextWindow.
  ///
  /// In zh, this message translates to:
  /// **'上下文窗口'**
  String get aiAssistantContextWindow;

  /// No description provided for @aiAssistantServiceStatus.
  ///
  /// In zh, this message translates to:
  /// **'服務狀態'**
  String get aiAssistantServiceStatus;

  /// No description provided for @aiAssistantAvailable.
  ///
  /// In zh, this message translates to:
  /// **'可用'**
  String get aiAssistantAvailable;

  /// No description provided for @aiAssistantUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'不可用'**
  String get aiAssistantUnavailable;

  /// No description provided for @aiSummarize.
  ///
  /// In zh, this message translates to:
  /// **'AI 總結'**
  String get aiSummarize;

  /// No description provided for @aiSummarizeUnread.
  ///
  /// In zh, this message translates to:
  /// **'AI 總結 {count} 條未讀消息'**
  String aiSummarizeUnread(int count);

  /// No description provided for @aiSummarizeLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在總結...'**
  String get aiSummarizeLoading;

  /// No description provided for @aiSummarizeError.
  ///
  /// In zh, this message translates to:
  /// **'總結失敗'**
  String get aiSummarizeError;

  /// No description provided for @aiRewrite.
  ///
  /// In zh, this message translates to:
  /// **'AI 改寫'**
  String get aiRewrite;

  /// No description provided for @aiRewriteFormal.
  ///
  /// In zh, this message translates to:
  /// **'正式'**
  String get aiRewriteFormal;

  /// No description provided for @aiRewriteCasual.
  ///
  /// In zh, this message translates to:
  /// **'輕鬆'**
  String get aiRewriteCasual;

  /// No description provided for @aiRewritePlayful.
  ///
  /// In zh, this message translates to:
  /// **'俏皮'**
  String get aiRewritePlayful;

  /// No description provided for @aiRewriteProfessional.
  ///
  /// In zh, this message translates to:
  /// **'專業'**
  String get aiRewriteProfessional;

  /// No description provided for @aiRewriteAccept.
  ///
  /// In zh, this message translates to:
  /// **'使用'**
  String get aiRewriteAccept;

  /// No description provided for @aiRewriteCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get aiRewriteCancel;

  /// No description provided for @aiRewriteLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在改寫...'**
  String get aiRewriteLoading;

  /// No description provided for @aiLinkSummary.
  ///
  /// In zh, this message translates to:
  /// **'AI 摘要'**
  String get aiLinkSummary;

  /// No description provided for @aiLinkSummaryAnalyzing.
  ///
  /// In zh, this message translates to:
  /// **'正在分析...'**
  String get aiLinkSummaryAnalyzing;

  /// No description provided for @chatFolderManagement.
  ///
  /// In zh, this message translates to:
  /// **'管理文件夾'**
  String get chatFolderManagement;

  /// No description provided for @chatFolderSystem.
  ///
  /// In zh, this message translates to:
  /// **'系統文件夾'**
  String get chatFolderSystem;

  /// No description provided for @chatFolderCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定義文件夾'**
  String get chatFolderCustom;

  /// No description provided for @chatFolderEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暫無自定義文件夾'**
  String get chatFolderEmpty;

  /// No description provided for @chatFolderCreate.
  ///
  /// In zh, this message translates to:
  /// **'創建文件夾'**
  String get chatFolderCreate;

  /// No description provided for @chatFolderEdit.
  ///
  /// In zh, this message translates to:
  /// **'編輯文件夾'**
  String get chatFolderEdit;

  /// No description provided for @chatFolderNameHint.
  ///
  /// In zh, this message translates to:
  /// **'文件夾名稱'**
  String get chatFolderNameHint;

  /// No description provided for @chatFolderAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get chatFolderAll;

  /// No description provided for @chatFolderUnread.
  ///
  /// In zh, this message translates to:
  /// **'未讀'**
  String get chatFolderUnread;

  /// No description provided for @chatFolderPersonal.
  ///
  /// In zh, this message translates to:
  /// **'私聊'**
  String get chatFolderPersonal;

  /// No description provided for @chatFolderGroups.
  ///
  /// In zh, this message translates to:
  /// **'羣組'**
  String get chatFolderGroups;

  /// No description provided for @chatFolderChannels.
  ///
  /// In zh, this message translates to:
  /// **'頻道'**
  String get chatFolderChannels;

  /// No description provided for @chatFolderMuted.
  ///
  /// In zh, this message translates to:
  /// **'已靜音'**
  String get chatFolderMuted;

  /// No description provided for @storyAddMusic.
  ///
  /// In zh, this message translates to:
  /// **'添加音樂'**
  String get storyAddMusic;

  /// No description provided for @storyChangeMusic.
  ///
  /// In zh, this message translates to:
  /// **'更換音樂'**
  String get storyChangeMusic;

  /// No description provided for @storyBackgroundMusic.
  ///
  /// In zh, this message translates to:
  /// **'背景音樂'**
  String get storyBackgroundMusic;

  /// No description provided for @storyMusicPreview.
  ///
  /// In zh, this message translates to:
  /// **'預覽 (最長15秒)'**
  String get storyMusicPreview;

  /// No description provided for @storyChooseFromDevice.
  ///
  /// In zh, this message translates to:
  /// **'從設備選擇'**
  String get storyChooseFromDevice;

  /// No description provided for @storyUseThisMusic.
  ///
  /// In zh, this message translates to:
  /// **'使用此音樂'**
  String get storyUseThisMusic;

  /// No description provided for @authPasskeyNotSupported.
  ///
  /// In zh, this message translates to:
  /// **'此設備不支持 Passkey'**
  String get authPasskeyNotSupported;

  /// No description provided for @authPasskeyRegister.
  ///
  /// In zh, this message translates to:
  /// **'註冊 Passkey'**
  String get authPasskeyRegister;

  /// No description provided for @authPasskeyNoRegistered.
  ///
  /// In zh, this message translates to:
  /// **'未註冊 Passkey'**
  String get authPasskeyNoRegistered;

  /// No description provided for @authPasskeyRegisterHint.
  ///
  /// In zh, this message translates to:
  /// **'爲當前賬號註冊 Passkey，獨立 Passkey 登錄入口後續開放。'**
  String get authPasskeyRegisterHint;

  /// No description provided for @authPasskeyNameYours.
  ///
  /// In zh, this message translates to:
  /// **'爲 Passkey 命名'**
  String get authPasskeyNameYours;

  /// No description provided for @authPasskeyRegistered.
  ///
  /// In zh, this message translates to:
  /// **'Passkey 已保存到當前賬號'**
  String get authPasskeyRegistered;

  /// No description provided for @authPasskeyDeleted.
  ///
  /// In zh, this message translates to:
  /// **'Passkey 已從當前賬號移除'**
  String get authPasskeyDeleted;

  /// No description provided for @authPasskeyDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'刪除 Passkey \"{name}\"？如需後續使用 Passkey 登錄，需要重新註冊。'**
  String authPasskeyDeleteConfirm(String name);

  /// No description provided for @momentVisibilityPublic.
  ///
  /// In zh, this message translates to:
  /// **'公開'**
  String get momentVisibilityPublic;

  /// No description provided for @momentVisibilityPrivate.
  ///
  /// In zh, this message translates to:
  /// **'私密'**
  String get momentVisibilityPrivate;

  /// No description provided for @momentVisibilityPartial.
  ///
  /// In zh, this message translates to:
  /// **'部分可見'**
  String get momentVisibilityPartial;

  /// No description provided for @momentVisibilityExcluded.
  ///
  /// In zh, this message translates to:
  /// **'不給誰看'**
  String get momentVisibilityExcluded;

  /// No description provided for @momentUserMoments.
  ///
  /// In zh, this message translates to:
  /// **'{userName}的朋友圈'**
  String momentUserMoments(String userName);

  /// No description provided for @momentForwardTo.
  ///
  /// In zh, this message translates to:
  /// **'轉發給'**
  String get momentForwardTo;

  /// No description provided for @momentForwardSuccess.
  ///
  /// In zh, this message translates to:
  /// **'轉發成功'**
  String get momentForwardSuccess;

  /// No description provided for @momentSelectFriends.
  ///
  /// In zh, this message translates to:
  /// **'選擇好友'**
  String get momentSelectFriends;

  /// No description provided for @momentSelectTags.
  ///
  /// In zh, this message translates to:
  /// **'按標籤選擇'**
  String get momentSelectTags;

  /// No description provided for @momentSelectedCount.
  ///
  /// In zh, this message translates to:
  /// **'已選擇 ({count})'**
  String momentSelectedCount(int count);

  /// No description provided for @momentNoMomentsYet.
  ///
  /// In zh, this message translates to:
  /// **'暫無動態'**
  String get momentNoMomentsYet;

  /// No description provided for @momentForwardMoment.
  ///
  /// In zh, this message translates to:
  /// **'轉發動態'**
  String get momentForwardMoment;

  /// No description provided for @momentAddComment.
  ///
  /// In zh, this message translates to:
  /// **'寫評論...'**
  String get momentAddComment;

  /// No description provided for @momentForwardContent.
  ///
  /// In zh, this message translates to:
  /// **'[朋友圈] {content}'**
  String momentForwardContent(String content);

  /// No description provided for @momentDeleteMoment.
  ///
  /// In zh, this message translates to:
  /// **'刪除動態'**
  String get momentDeleteMoment;

  /// No description provided for @momentDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定要刪除這條動態嗎？'**
  String get momentDeleteConfirm;

  /// No description provided for @momentComment.
  ///
  /// In zh, this message translates to:
  /// **'評論'**
  String get momentComment;

  /// No description provided for @momentWriteComment.
  ///
  /// In zh, this message translates to:
  /// **'寫評論...'**
  String get momentWriteComment;

  /// No description provided for @momentLike.
  ///
  /// In zh, this message translates to:
  /// **'贊'**
  String get momentLike;

  /// No description provided for @momentUnlike.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get momentUnlike;

  /// No description provided for @momentForward.
  ///
  /// In zh, this message translates to:
  /// **'轉發'**
  String get momentForward;

  /// No description provided for @momentDelete.
  ///
  /// In zh, this message translates to:
  /// **'刪除'**
  String get momentDelete;

  /// No description provided for @momentReply.
  ///
  /// In zh, this message translates to:
  /// **'回覆'**
  String get momentReply;

  /// No description provided for @momentMoment.
  ///
  /// In zh, this message translates to:
  /// **'動態'**
  String get momentMoment;

  /// No description provided for @momentLikesCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 個贊'**
  String momentLikesCount(int count);

  /// No description provided for @momentCommentsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 條評論'**
  String momentCommentsCount(int count);

  /// No description provided for @momentNoComments.
  ///
  /// In zh, this message translates to:
  /// **'暫無評論'**
  String get momentNoComments;

  /// No description provided for @momentFailedToLoad.
  ///
  /// In zh, this message translates to:
  /// **'圖片加載失敗'**
  String get momentFailedToLoad;

  /// No description provided for @momentReplyTo.
  ///
  /// In zh, this message translates to:
  /// **'回覆 {userName}...'**
  String momentReplyTo(String userName);

  /// No description provided for @momentNoConversations.
  ///
  /// In zh, this message translates to:
  /// **'暫無會話'**
  String get momentNoConversations;

  /// No description provided for @momentJustNow.
  ///
  /// In zh, this message translates to:
  /// **'剛剛'**
  String get momentJustNow;

  /// No description provided for @momentMinutesAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}分鐘前'**
  String momentMinutesAgo(int count);

  /// No description provided for @momentHoursAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}小時前'**
  String momentHoursAgo(int count);

  /// No description provided for @momentDaysAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}天前'**
  String momentDaysAgo(int count);

  /// No description provided for @chatGroupAnnouncementHint.
  ///
  /// In zh, this message translates to:
  /// **'輸入羣公告'**
  String get chatGroupAnnouncementHint;

  /// No description provided for @chatGroupAnnouncementEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暫無羣公告'**
  String get chatGroupAnnouncementEmpty;

  /// No description provided for @chatEditNickname.
  ///
  /// In zh, this message translates to:
  /// **'編輯羣暱稱'**
  String get chatEditNickname;

  /// No description provided for @chatNicknameHint.
  ///
  /// In zh, this message translates to:
  /// **'輸入你在羣裏的暱稱'**
  String get chatNicknameHint;

  /// No description provided for @contactAddPhoneHint.
  ///
  /// In zh, this message translates to:
  /// **'輸入電話號碼'**
  String get contactAddPhoneHint;

  /// No description provided for @contactNotesHint.
  ///
  /// In zh, this message translates to:
  /// **'添加聯繫人備忘'**
  String get contactNotesHint;

  /// No description provided for @reportTitle.
  ///
  /// In zh, this message translates to:
  /// **'投訴'**
  String get reportTitle;

  /// No description provided for @reportReasonSpam.
  ///
  /// In zh, this message translates to:
  /// **'垃圾信息'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In zh, this message translates to:
  /// **'騷擾'**
  String get reportReasonHarassment;

  /// No description provided for @reportReasonFraud.
  ///
  /// In zh, this message translates to:
  /// **'欺詐'**
  String get reportReasonFraud;

  /// No description provided for @reportReasonOther.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get reportReasonOther;

  /// No description provided for @reportSubmitted.
  ///
  /// In zh, this message translates to:
  /// **'投訴已提交'**
  String get reportSubmitted;

  /// No description provided for @reportDescription.
  ///
  /// In zh, this message translates to:
  /// **'補充說明（選填）'**
  String get reportDescription;

  /// No description provided for @qrcodeSaved.
  ///
  /// In zh, this message translates to:
  /// **'二維碼已保存到相冊'**
  String get qrcodeSaved;

  /// No description provided for @chatSendRedPacketInChat.
  ///
  /// In zh, this message translates to:
  /// **'請在聊天中發送紅包'**
  String get chatSendRedPacketInChat;

  /// No description provided for @commonSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失敗'**
  String get commonSaveFailed;

  /// No description provided for @reportSelectReason.
  ///
  /// In zh, this message translates to:
  /// **'請選擇投訴原因'**
  String get reportSelectReason;

  /// No description provided for @gameCenter.
  ///
  /// In zh, this message translates to:
  /// **'遊戲中心'**
  String get gameCenter;

  /// No description provided for @gameHighScore.
  ///
  /// In zh, this message translates to:
  /// **'最高分'**
  String get gameHighScore;

  /// No description provided for @gameScore.
  ///
  /// In zh, this message translates to:
  /// **'分數'**
  String get gameScore;

  /// No description provided for @gameOver.
  ///
  /// In zh, this message translates to:
  /// **'遊戲結束'**
  String get gameOver;

  /// No description provided for @gamePlayAgain.
  ///
  /// In zh, this message translates to:
  /// **'再來一局'**
  String get gamePlayAgain;

  /// No description provided for @gameLeaderboard.
  ///
  /// In zh, this message translates to:
  /// **'排行榜'**
  String get gameLeaderboard;

  /// No description provided for @gamePause.
  ///
  /// In zh, this message translates to:
  /// **'暫停'**
  String get gamePause;

  /// No description provided for @gameResume.
  ///
  /// In zh, this message translates to:
  /// **'點擊繼續'**
  String get gameResume;

  /// No description provided for @gameConfirmExit.
  ///
  /// In zh, this message translates to:
  /// **'確定退出遊戲？'**
  String get gameConfirmExit;

  /// No description provided for @gameNoScores.
  ///
  /// In zh, this message translates to:
  /// **'暫無記錄'**
  String get gameNoScores;

  /// No description provided for @game2048.
  ///
  /// In zh, this message translates to:
  /// **'2048'**
  String get game2048;

  /// No description provided for @game2048Desc.
  ///
  /// In zh, this message translates to:
  /// **'合併數字到 2048'**
  String get game2048Desc;

  /// No description provided for @gameBlockDrop.
  ///
  /// In zh, this message translates to:
  /// **'方塊消除'**
  String get gameBlockDrop;

  /// No description provided for @gameBlockDropDesc.
  ///
  /// In zh, this message translates to:
  /// **'消除方塊行'**
  String get gameBlockDropDesc;

  /// No description provided for @gameMinesweeper.
  ///
  /// In zh, this message translates to:
  /// **'掃雷'**
  String get gameMinesweeper;

  /// No description provided for @gameMinesweeperDesc.
  ///
  /// In zh, this message translates to:
  /// **'找出所有安全格'**
  String get gameMinesweeperDesc;

  /// No description provided for @gameMatch3.
  ///
  /// In zh, this message translates to:
  /// **'消消樂'**
  String get gameMatch3;

  /// No description provided for @gameMatch3Desc.
  ///
  /// In zh, this message translates to:
  /// **'連接3個以上寶石'**
  String get gameMatch3Desc;

  /// No description provided for @gameMinesweeperEasy.
  ///
  /// In zh, this message translates to:
  /// **'初級'**
  String get gameMinesweeperEasy;

  /// No description provided for @gameMinesweeperMedium.
  ///
  /// In zh, this message translates to:
  /// **'中級'**
  String get gameMinesweeperMedium;

  /// No description provided for @gameMinesLeft.
  ///
  /// In zh, this message translates to:
  /// **'剩餘雷數'**
  String get gameMinesLeft;

  /// No description provided for @gameTimeLeft.
  ///
  /// In zh, this message translates to:
  /// **'時間'**
  String get gameTimeLeft;

  /// No description provided for @gameLevel.
  ///
  /// In zh, this message translates to:
  /// **'等級'**
  String get gameLevel;

  /// No description provided for @gameNext.
  ///
  /// In zh, this message translates to:
  /// **'下一個'**
  String get gameNext;

  /// No description provided for @gameBestTime.
  ///
  /// In zh, this message translates to:
  /// **'最佳用時'**
  String get gameBestTime;

  /// No description provided for @gameNewRecord.
  ///
  /// In zh, this message translates to:
  /// **'新紀錄！'**
  String get gameNewRecord;

  /// No description provided for @gameLines.
  ///
  /// In zh, this message translates to:
  /// **'行數'**
  String get gameLines;

  /// No description provided for @storyMyStory.
  ///
  /// In zh, this message translates to:
  /// **'我的動態'**
  String get storyMyStory;

  /// No description provided for @storageSmartCleanup.
  ///
  /// In zh, this message translates to:
  /// **'智能清理'**
  String get storageSmartCleanup;

  /// No description provided for @storageOldMediaFiles.
  ///
  /// In zh, this message translates to:
  /// **'舊媒體文件'**
  String get storageOldMediaFiles;

  /// No description provided for @storageLargeFiles.
  ///
  /// In zh, this message translates to:
  /// **'大文件'**
  String get storageLargeFiles;

  /// No description provided for @storageAppCache.
  ///
  /// In zh, this message translates to:
  /// **'應用緩存'**
  String get storageAppCache;

  /// No description provided for @storageSettings.
  ///
  /// In zh, this message translates to:
  /// **'存儲設置'**
  String get storageSettings;

  /// No description provided for @storageAutoCleanup.
  ///
  /// In zh, this message translates to:
  /// **'自動清理'**
  String get storageAutoCleanup;

  /// No description provided for @storageAutoCleanupDesc.
  ///
  /// In zh, this message translates to:
  /// **'自動清理 {days} 天以上未訪問的文件'**
  String storageAutoCleanupDesc(int days);

  /// No description provided for @storageCleanupPeriod.
  ///
  /// In zh, this message translates to:
  /// **'清理週期'**
  String get storageCleanupPeriod;

  /// No description provided for @storagePreserveThumbnails.
  ///
  /// In zh, this message translates to:
  /// **'保留縮略圖'**
  String get storagePreserveThumbnails;

  /// No description provided for @storagePreserveThumbnailsDesc.
  ///
  /// In zh, this message translates to:
  /// **'清理時保留圖片縮略圖'**
  String get storagePreserveThumbnailsDesc;

  /// No description provided for @storageWarningHigh.
  ///
  /// In zh, this message translates to:
  /// **'存儲空間較高，建議清理舊文件。'**
  String get storageWarningHigh;

  /// No description provided for @storageWarningCritical.
  ///
  /// In zh, this message translates to:
  /// **'存儲空間嚴重不足，請立即清理。'**
  String get storageWarningCritical;

  /// No description provided for @storageFreed.
  ///
  /// In zh, this message translates to:
  /// **'已釋放 {size}（{count} 個文件）'**
  String storageFreed(String size, int count);

  /// No description provided for @storageDays.
  ///
  /// In zh, this message translates to:
  /// **'{days} 天'**
  String storageDays(int days);

  /// No description provided for @storageViewAllRooms.
  ///
  /// In zh, this message translates to:
  /// **'查看全部 {count} 個房間'**
  String storageViewAllRooms(int count);

  /// No description provided for @storageNoFiles.
  ///
  /// In zh, this message translates to:
  /// **'暫無文件'**
  String get storageNoFiles;

  /// No description provided for @storageFilePinned.
  ///
  /// In zh, this message translates to:
  /// **'已保留'**
  String get storageFilePinned;

  /// No description provided for @storageDeleteSelected.
  ///
  /// In zh, this message translates to:
  /// **'刪除 {count} 個選中文件？文件可從服務器重新下載。'**
  String storageDeleteSelected(int count);

  /// No description provided for @backupRestore.
  ///
  /// In zh, this message translates to:
  /// **'備份與恢復'**
  String get backupRestore;

  /// No description provided for @backupCreate.
  ///
  /// In zh, this message translates to:
  /// **'創建備份'**
  String get backupCreate;

  /// No description provided for @backupCreateDesc.
  ///
  /// In zh, this message translates to:
  /// **'備份設置和加密密鑰。消息將在重新登錄後從服務器恢復。'**
  String get backupCreateDesc;

  /// No description provided for @backupIncludeKeys.
  ///
  /// In zh, this message translates to:
  /// **'包含加密密鑰'**
  String get backupIncludeKeys;

  /// No description provided for @backupIncludeKeysDesc.
  ///
  /// In zh, this message translates to:
  /// **'讀取加密消息所必需'**
  String get backupIncludeKeysDesc;

  /// No description provided for @backupPasswordProtect.
  ///
  /// In zh, this message translates to:
  /// **'密碼保護'**
  String get backupPasswordProtect;

  /// No description provided for @backupEnterPassword.
  ///
  /// In zh, this message translates to:
  /// **'輸入備份密碼'**
  String get backupEnterPassword;

  /// No description provided for @backupHistory.
  ///
  /// In zh, this message translates to:
  /// **'備份歷史'**
  String get backupHistory;

  /// No description provided for @backupNoBackups.
  ///
  /// In zh, this message translates to:
  /// **'暫無備份'**
  String get backupNoBackups;

  /// No description provided for @backupRestore2.
  ///
  /// In zh, this message translates to:
  /// **'恢復'**
  String get backupRestore2;

  /// No description provided for @backupDelete.
  ///
  /// In zh, this message translates to:
  /// **'刪除'**
  String get backupDelete;

  /// No description provided for @backupDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定刪除此備份？此操作不可撤銷。'**
  String get backupDeleteConfirm;

  /// No description provided for @backupRestoreFromFile.
  ///
  /// In zh, this message translates to:
  /// **'從文件恢復'**
  String get backupRestoreFromFile;

  /// No description provided for @backupRestoreFromFileDesc.
  ///
  /// In zh, this message translates to:
  /// **'導入來自其他設備或之前備份的 .n42backup 文件。'**
  String get backupRestoreFromFileDesc;

  /// No description provided for @backupChooseFile.
  ///
  /// In zh, this message translates to:
  /// **'選擇備份文件'**
  String get backupChooseFile;

  /// No description provided for @backupRestoring.
  ///
  /// In zh, this message translates to:
  /// **'恢復中...'**
  String get backupRestoring;

  /// No description provided for @backupCreated.
  ///
  /// In zh, this message translates to:
  /// **'備份已創建：{rooms} 個房間，{messages} 條消息'**
  String backupCreated(int rooms, int messages);

  /// No description provided for @backupRestored.
  ///
  /// In zh, this message translates to:
  /// **'已恢復 {settings} 項設置（來自 {rooms} 個房間）'**
  String backupRestored(int settings, int rooms);

  /// No description provided for @backupFailed.
  ///
  /// In zh, this message translates to:
  /// **'備份失敗：{error}'**
  String backupFailed(String error);

  /// No description provided for @backupPasswordRequired.
  ///
  /// In zh, this message translates to:
  /// **'此備份需要密碼'**
  String get backupPasswordRequired;

  /// No description provided for @blocGroupNotFound.
  ///
  /// In zh, this message translates to:
  /// **'羣組未找到'**
  String get blocGroupNotFound;

  /// No description provided for @blocGroupMembersInvited.
  ///
  /// In zh, this message translates to:
  /// **'已邀請{count}位成員'**
  String blocGroupMembersInvited(int count);

  /// No description provided for @blocGroupMemberRemoved.
  ///
  /// In zh, this message translates to:
  /// **'成員已移除'**
  String get blocGroupMemberRemoved;

  /// No description provided for @blocGroupAdminRemoved.
  ///
  /// In zh, this message translates to:
  /// **'已取消管理員'**
  String get blocGroupAdminRemoved;

  /// No description provided for @blocGroupLeft.
  ///
  /// In zh, this message translates to:
  /// **'已退出羣聊'**
  String get blocGroupLeft;

  /// No description provided for @blocGroupDisbanded.
  ///
  /// In zh, this message translates to:
  /// **'羣聊已解散'**
  String get blocGroupDisbanded;

  /// No description provided for @blocGroupJoined.
  ///
  /// In zh, this message translates to:
  /// **'已加入羣聊'**
  String get blocGroupJoined;

  /// No description provided for @blocGroupInviteDeclined.
  ///
  /// In zh, this message translates to:
  /// **'已拒絕邀請'**
  String get blocGroupInviteDeclined;

  /// No description provided for @blocGroupTokenGateUpdated.
  ///
  /// In zh, this message translates to:
  /// **'Token 門檻已更新'**
  String get blocGroupTokenGateUpdated;

  /// No description provided for @blocTransferProcessing.
  ///
  /// In zh, this message translates to:
  /// **'轉賬處理中...'**
  String get blocTransferProcessing;

  /// No description provided for @blocTransferCancelled.
  ///
  /// In zh, this message translates to:
  /// **'轉賬已取消'**
  String get blocTransferCancelled;

  /// No description provided for @blocTransferFailed.
  ///
  /// In zh, this message translates to:
  /// **'轉賬失敗'**
  String get blocTransferFailed;

  /// No description provided for @blocPaymentProcessing.
  ///
  /// In zh, this message translates to:
  /// **'支付處理中...'**
  String get blocPaymentProcessing;

  /// No description provided for @blocPaymentFailed.
  ///
  /// In zh, this message translates to:
  /// **'支付失敗'**
  String get blocPaymentFailed;

  /// No description provided for @groupMaxMembers.
  ///
  /// In zh, this message translates to:
  /// **'羣人數上限'**
  String get groupMaxMembers;

  /// No description provided for @groupMaxMembersUnlimited.
  ///
  /// In zh, this message translates to:
  /// **'不限'**
  String get groupMaxMembersUnlimited;

  /// No description provided for @groupMaxMembersHint.
  ///
  /// In zh, this message translates to:
  /// **'輸入上限（留空表示不限）'**
  String get groupMaxMembersHint;

  /// No description provided for @groupMaxMembersUpdated.
  ///
  /// In zh, this message translates to:
  /// **'羣人數上限已更新'**
  String get groupMaxMembersUpdated;

  /// No description provided for @groupFull.
  ///
  /// In zh, this message translates to:
  /// **'羣已滿員'**
  String get groupFull;

  /// No description provided for @groupChannels.
  ///
  /// In zh, this message translates to:
  /// **'話題頻道'**
  String get groupChannels;

  /// No description provided for @groupChannelsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暫無話題頻道'**
  String get groupChannelsEmpty;

  /// No description provided for @groupChannelsCount.
  ///
  /// In zh, this message translates to:
  /// **'個頻道'**
  String get groupChannelsCount;

  /// No description provided for @groupChannelCreate.
  ///
  /// In zh, this message translates to:
  /// **'新建頻道'**
  String get groupChannelCreate;

  /// No description provided for @groupChannelName.
  ///
  /// In zh, this message translates to:
  /// **'頻道名稱'**
  String get groupChannelName;

  /// No description provided for @groupChannelTopic.
  ///
  /// In zh, this message translates to:
  /// **'頻道話題（可選）'**
  String get groupChannelTopic;

  /// No description provided for @groupChannelDelete.
  ///
  /// In zh, this message translates to:
  /// **'刪除頻道'**
  String get groupChannelDelete;

  /// No description provided for @groupChannelDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確認刪除此頻道？消息不可恢復。'**
  String get groupChannelDeleteConfirm;

  /// No description provided for @groupBotSettings.
  ///
  /// In zh, this message translates to:
  /// **'Bot 設置'**
  String get groupBotSettings;

  /// No description provided for @groupBotEnabled.
  ///
  /// In zh, this message translates to:
  /// **'啓用 Bot'**
  String get groupBotEnabled;

  /// No description provided for @groupBotWelcomeMessage.
  ///
  /// In zh, this message translates to:
  /// **'歡迎語模板'**
  String get groupBotWelcomeMessage;

  /// No description provided for @groupBotWelcomeHint.
  ///
  /// In zh, this message translates to:
  /// **'用 \'name\' 作爲新成員名字佔位符'**
  String get groupBotWelcomeHint;

  /// No description provided for @groupBotConfigUpdated.
  ///
  /// In zh, this message translates to:
  /// **'Bot 設置已更新'**
  String get groupBotConfigUpdated;

  /// No description provided for @groupContentFilter.
  ///
  /// In zh, this message translates to:
  /// **'關鍵詞過濾'**
  String get groupContentFilter;

  /// No description provided for @groupContentFilterEnabled.
  ///
  /// In zh, this message translates to:
  /// **'啓用關鍵詞過濾'**
  String get groupContentFilterEnabled;

  /// No description provided for @groupContentFilterReplace.
  ///
  /// In zh, this message translates to:
  /// **'替換爲 ***'**
  String get groupContentFilterReplace;

  /// No description provided for @groupContentFilterHide.
  ///
  /// In zh, this message translates to:
  /// **'隱藏消息'**
  String get groupContentFilterHide;

  /// No description provided for @groupContentFilterAddWord.
  ///
  /// In zh, this message translates to:
  /// **'添加關鍵詞'**
  String get groupContentFilterAddWord;

  /// No description provided for @groupContentFilterUpdated.
  ///
  /// In zh, this message translates to:
  /// **'內容過濾設置已更新'**
  String get groupContentFilterUpdated;

  /// No description provided for @chatSlashCommands.
  ///
  /// In zh, this message translates to:
  /// **'指令'**
  String get chatSlashCommands;

  /// No description provided for @chatCommandPoll.
  ///
  /// In zh, this message translates to:
  /// **'/poll — 創建投票'**
  String get chatCommandPoll;

  /// No description provided for @chatCommandAnnounce.
  ///
  /// In zh, this message translates to:
  /// **'/announce — 發佈公告'**
  String get chatCommandAnnounce;

  /// No description provided for @chatCommandWelcome.
  ///
  /// In zh, this message translates to:
  /// **'/welcome — 設置歡迎語'**
  String get chatCommandWelcome;

  /// No description provided for @chatReportMessage.
  ///
  /// In zh, this message translates to:
  /// **'舉報'**
  String get chatReportMessage;

  /// No description provided for @chatReportReason.
  ///
  /// In zh, this message translates to:
  /// **'舉報原因'**
  String get chatReportReason;

  /// No description provided for @chatReportSpam.
  ///
  /// In zh, this message translates to:
  /// **'垃圾信息'**
  String get chatReportSpam;

  /// No description provided for @chatReportHarassment.
  ///
  /// In zh, this message translates to:
  /// **'騷擾'**
  String get chatReportHarassment;

  /// No description provided for @chatReportInappropriate.
  ///
  /// In zh, this message translates to:
  /// **'違規內容'**
  String get chatReportInappropriate;

  /// No description provided for @chatReportOther.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get chatReportOther;

  /// No description provided for @chatReportSuccess.
  ///
  /// In zh, this message translates to:
  /// **'舉報已提交'**
  String get chatReportSuccess;

  /// No description provided for @spacesName.
  ///
  /// In zh, this message translates to:
  /// **'社區名稱'**
  String get spacesName;

  /// No description provided for @spacesNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：加密交易者'**
  String get spacesNameHint;

  /// No description provided for @spacesNameRequired.
  ///
  /// In zh, this message translates to:
  /// **'請輸入社區名稱'**
  String get spacesNameRequired;

  /// No description provided for @spacesDescription.
  ///
  /// In zh, this message translates to:
  /// **'簡介'**
  String get spacesDescription;

  /// No description provided for @spacesDescriptionHint.
  ///
  /// In zh, this message translates to:
  /// **'介紹一下這個社區'**
  String get spacesDescriptionHint;

  /// No description provided for @spacesType.
  ///
  /// In zh, this message translates to:
  /// **'社區類型'**
  String get spacesType;

  /// No description provided for @spacesPublicDesc.
  ///
  /// In zh, this message translates to:
  /// **'任何人均可發現並加入'**
  String get spacesPublicDesc;

  /// No description provided for @spacesPrivateDesc.
  ///
  /// In zh, this message translates to:
  /// **'僅受邀成員可加入'**
  String get spacesPrivateDesc;

  /// No description provided for @spacesNotFound.
  ///
  /// In zh, this message translates to:
  /// **'社區不存在'**
  String get spacesNotFound;

  /// No description provided for @spacesSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索社區...'**
  String get spacesSearch;

  /// No description provided for @spacesMembers.
  ///
  /// In zh, this message translates to:
  /// **'成員'**
  String get spacesMembers;

  /// No description provided for @spacesNoChannels.
  ///
  /// In zh, this message translates to:
  /// **'暫無頻道'**
  String get spacesNoChannels;

  /// No description provided for @spacesLeave.
  ///
  /// In zh, this message translates to:
  /// **'退出社區'**
  String get spacesLeave;

  /// No description provided for @spacesLeaveConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定要退出「{name}」嗎？'**
  String spacesLeaveConfirm(String name);

  /// No description provided for @spacesDelete.
  ///
  /// In zh, this message translates to:
  /// **'解散社區'**
  String get spacesDelete;

  /// No description provided for @spacesDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'此操作將永久刪除「{name}」及其所有頻道，且不可撤銷。'**
  String spacesDeleteConfirm(String name);

  /// No description provided for @spacesCreateChannel.
  ///
  /// In zh, this message translates to:
  /// **'創建頻道'**
  String get spacesCreateChannel;

  /// No description provided for @spacesChannelName.
  ///
  /// In zh, this message translates to:
  /// **'頻道名稱'**
  String get spacesChannelName;

  /// No description provided for @spacesChannelTopic.
  ///
  /// In zh, this message translates to:
  /// **'話題（可選）'**
  String get spacesChannelTopic;

  /// No description provided for @spacesDeleteChannel.
  ///
  /// In zh, this message translates to:
  /// **'刪除頻道'**
  String get spacesDeleteChannel;

  /// No description provided for @spacesDeleteChannelConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定要刪除頻道「#{name}」嗎？'**
  String spacesDeleteChannelConfirm(String name);

  /// No description provided for @spacesEditName.
  ///
  /// In zh, this message translates to:
  /// **'修改名稱'**
  String get spacesEditName;

  /// No description provided for @spacesEditDescription.
  ///
  /// In zh, this message translates to:
  /// **'修改簡介'**
  String get spacesEditDescription;

  /// No description provided for @spacesViewAllMembers.
  ///
  /// In zh, this message translates to:
  /// **'查看全部 {count} 位成員'**
  String spacesViewAllMembers(int count);

  /// No description provided for @spacesKickMemberTitle.
  ///
  /// In zh, this message translates to:
  /// **'踢出 {name}'**
  String spacesKickMemberTitle(String name);

  /// No description provided for @spacesBanMemberTitle.
  ///
  /// In zh, this message translates to:
  /// **'封禁 {name}'**
  String spacesBanMemberTitle(String name);

  /// No description provided for @spacesPromoteAdmin.
  ///
  /// In zh, this message translates to:
  /// **'設爲管理員'**
  String get spacesPromoteAdmin;

  /// No description provided for @spacesDemoteAdmin.
  ///
  /// In zh, this message translates to:
  /// **'撤銷管理員'**
  String get spacesDemoteAdmin;

  /// No description provided for @spacesInviteMember.
  ///
  /// In zh, this message translates to:
  /// **'邀請成員'**
  String get spacesInviteMember;

  /// No description provided for @spacesInviteMemberUserId.
  ///
  /// In zh, this message translates to:
  /// **'用戶 ID（如 @user:server.com）'**
  String get spacesInviteMemberUserId;

  /// No description provided for @spacesSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get spacesSave;

  /// No description provided for @settingsScreenshotProtection.
  ///
  /// In zh, this message translates to:
  /// **'截圖防護'**
  String get settingsScreenshotProtection;

  /// No description provided for @settingsScreenshotProtectionDesc.
  ///
  /// In zh, this message translates to:
  /// **'防止截圖和屏幕錄製'**
  String get settingsScreenshotProtectionDesc;

  /// No description provided for @chatSelfDestructTimer.
  ///
  /// In zh, this message translates to:
  /// **'閱後即焚'**
  String get chatSelfDestructTimer;

  /// No description provided for @chatTimerPickerTitle.
  ///
  /// In zh, this message translates to:
  /// **'設置閱後即焚時間'**
  String get chatTimerPickerTitle;

  /// No description provided for @chatTimerOff.
  ///
  /// In zh, this message translates to:
  /// **'關閉'**
  String get chatTimerOff;

  /// No description provided for @onChainNotificationsTitle.
  ///
  /// In zh, this message translates to:
  /// **'鏈上事件'**
  String get onChainNotificationsTitle;

  /// No description provided for @onChainMarkAllRead.
  ///
  /// In zh, this message translates to:
  /// **'全部已讀'**
  String get onChainMarkAllRead;

  /// No description provided for @onChainNoNotifications.
  ///
  /// In zh, this message translates to:
  /// **'暫無鏈上事件'**
  String get onChainNoNotifications;

  /// No description provided for @onChainNoNotificationsDesc.
  ///
  /// In zh, this message translates to:
  /// **'來自訂閱頻道的事件通知將在此顯示'**
  String get onChainNoNotificationsDesc;

  /// No description provided for @onChainViewDetails.
  ///
  /// In zh, this message translates to:
  /// **'查看詳情'**
  String get onChainViewDetails;

  /// No description provided for @chatCommandHelp.
  ///
  /// In zh, this message translates to:
  /// **'/help — 查看所有命令'**
  String get chatCommandHelp;

  /// No description provided for @chatCommandPrice.
  ///
  /// In zh, this message translates to:
  /// **'/price — 查詢代幣價格'**
  String get chatCommandPrice;

  /// No description provided for @chatCommandBalance.
  ///
  /// In zh, this message translates to:
  /// **'/balance — 查看錢包餘額'**
  String get chatCommandBalance;

  /// No description provided for @chatCommandChains.
  ///
  /// In zh, this message translates to:
  /// **'/chains — 查看 236+ 條支持鏈'**
  String get chatCommandChains;

  /// No description provided for @chatMiniApps.
  ///
  /// In zh, this message translates to:
  /// **'應用'**
  String get chatMiniApps;

  /// No description provided for @miniAppMarketTitle.
  ///
  /// In zh, this message translates to:
  /// **'小程序'**
  String get miniAppMarketTitle;

  /// No description provided for @miniAppCategoryAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get miniAppCategoryAll;

  /// No description provided for @miniAppSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索應用...'**
  String get miniAppSearch;

  /// No description provided for @miniAppFeatured.
  ///
  /// In zh, this message translates to:
  /// **'精選'**
  String get miniAppFeatured;

  /// No description provided for @miniAppAllApps.
  ///
  /// In zh, this message translates to:
  /// **'全部應用'**
  String get miniAppAllApps;

  /// No description provided for @miniAppNoResults.
  ///
  /// In zh, this message translates to:
  /// **'未找到應用'**
  String get miniAppNoResults;

  /// No description provided for @slideToPayLabel.
  ///
  /// In zh, this message translates to:
  /// **'→→→  滑動確認'**
  String get slideToPayLabel;

  /// No description provided for @slideToPayConfirming.
  ///
  /// In zh, this message translates to:
  /// **'確認中...'**
  String get slideToPayConfirming;

  /// No description provided for @redPacketBestLuck.
  ///
  /// In zh, this message translates to:
  /// **'最佳手氣'**
  String get redPacketBestLuck;

  /// No description provided for @redPacketBestLuckCongrats.
  ///
  /// In zh, this message translates to:
  /// **'最佳手氣！你搶到了最多！'**
  String get redPacketBestLuckCongrats;

  /// No description provided for @redPacketStats.
  ///
  /// In zh, this message translates to:
  /// **'{claimed} / {total} 個已領取'**
  String redPacketStats(int claimed, int total);

  /// No description provided for @redPacketStatsTotal.
  ///
  /// In zh, this message translates to:
  /// **'共計'**
  String get redPacketStatsTotal;

  /// No description provided for @redPacketGrabbedViral.
  ///
  /// In zh, this message translates to:
  /// **'🧧 搶到了紅包 • {amount} {token}'**
  String redPacketGrabbedViral(String amount, String token);

  /// No description provided for @web3SearchHint.
  ///
  /// In zh, this message translates to:
  /// **'@matrix:id  •  0x 錢包地址  •  name.eth'**
  String get web3SearchHint;

  /// No description provided for @web3SearchPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'搜索 ID、錢包地址或 ENS...'**
  String get web3SearchPlaceholder;

  /// No description provided for @web3WalletAddress.
  ///
  /// In zh, this message translates to:
  /// **'錢包地址'**
  String get web3WalletAddress;

  /// No description provided for @web3AddressCopied.
  ///
  /// In zh, this message translates to:
  /// **'地址已複製'**
  String get web3AddressCopied;

  /// No description provided for @web3Copy.
  ///
  /// In zh, this message translates to:
  /// **'複製'**
  String get web3Copy;

  /// No description provided for @web3SendMessage.
  ///
  /// In zh, this message translates to:
  /// **'發消息'**
  String get web3SendMessage;

  /// No description provided for @web3SendToWallet.
  ///
  /// In zh, this message translates to:
  /// **'發送到錢包'**
  String get web3SendToWallet;

  /// No description provided for @web3WalletOnlyHint.
  ///
  /// In zh, this message translates to:
  /// **'該地址尚無 N42 賬號。對方加入後消息將自動送達。'**
  String get web3WalletOnlyHint;

  /// No description provided for @web3NftAvatar.
  ///
  /// In zh, this message translates to:
  /// **'NFT 頭像'**
  String get web3NftAvatar;

  /// No description provided for @web3ResolveFailed.
  ///
  /// In zh, this message translates to:
  /// **'身份解析失敗'**
  String get web3ResolveFailed;

  /// No description provided for @web3EnsNotFound.
  ///
  /// In zh, this message translates to:
  /// **'ENS 名稱“{name}”未找到'**
  String web3EnsNotFound(String name);

  /// No description provided for @web3NoN42AccountTitle.
  ///
  /// In zh, this message translates to:
  /// **'無 N42 賬號'**
  String get web3NoN42AccountTitle;

  /// No description provided for @web3NoN42AccountDesc.
  ///
  /// In zh, this message translates to:
  /// **'該錢包地址尚無 N42 賬號。您可以分享 N42 邀請鏈接邀請對方加入。'**
  String get web3NoN42AccountDesc;

  /// No description provided for @web3ShareInvite.
  ///
  /// In zh, this message translates to:
  /// **'分享邀請'**
  String get web3ShareInvite;

  /// No description provided for @nftPickerTitle.
  ///
  /// In zh, this message translates to:
  /// **'選擇 NFT 頭像'**
  String get nftPickerTitle;

  /// No description provided for @nftPickerTabPopular.
  ///
  /// In zh, this message translates to:
  /// **'熱門'**
  String get nftPickerTabPopular;

  /// No description provided for @nftPickerTabCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定義'**
  String get nftPickerTabCustom;

  /// No description provided for @nftPickerChain.
  ///
  /// In zh, this message translates to:
  /// **'鏈'**
  String get nftPickerChain;

  /// No description provided for @nftPickerContract.
  ///
  /// In zh, this message translates to:
  /// **'合約地址'**
  String get nftPickerContract;

  /// No description provided for @nftPickerTokenId.
  ///
  /// In zh, this message translates to:
  /// **'Token ID'**
  String get nftPickerTokenId;

  /// No description provided for @nftPickerVerifyOwnership.
  ///
  /// In zh, this message translates to:
  /// **'驗證所有權並預覽'**
  String get nftPickerVerifyOwnership;

  /// No description provided for @nftPickerUseAsAvatar.
  ///
  /// In zh, this message translates to:
  /// **'用作頭像'**
  String get nftPickerUseAsAvatar;

  /// No description provided for @nftPickerPreview.
  ///
  /// In zh, this message translates to:
  /// **'預覽'**
  String get nftPickerPreview;

  /// No description provided for @nftPickerNotOwned.
  ///
  /// In zh, this message translates to:
  /// **'您不擁有這個 NFT'**
  String get nftPickerNotOwned;

  /// No description provided for @nftPickerInvalidTokenId.
  ///
  /// In zh, this message translates to:
  /// **'無效的 Token ID'**
  String get nftPickerInvalidTokenId;

  /// No description provided for @nftPickerEnterBoth.
  ///
  /// In zh, this message translates to:
  /// **'請輸入合約地址和 Token ID'**
  String get nftPickerEnterBoth;

  /// No description provided for @nftPickerInfoTitle.
  ///
  /// In zh, this message translates to:
  /// **'NFT 頭像 — 鏈上身份驗證'**
  String get nftPickerInfoTitle;

  /// No description provided for @nftPickerInfoDesc.
  ///
  /// In zh, this message translates to:
  /// **'綁定您持有的 NFT 作爲頭像。任何人均可在鏈上驗證歸屬權。在 N42 全應用中以金色邊框標識。'**
  String get nftPickerInfoDesc;

  /// No description provided for @nftPickerPopularCollections.
  ///
  /// In zh, this message translates to:
  /// **'熱門 NFT 項目'**
  String get nftPickerPopularCollections;

  /// No description provided for @nftPickerWalletHint.
  ///
  /// In zh, this message translates to:
  /// **'連接 N42 錢包，自動發現您在 236+ 條鏈上持有的 NFT。'**
  String get nftPickerWalletHint;

  /// No description provided for @profileBindNftAvatar.
  ///
  /// In zh, this message translates to:
  /// **'綁定 NFT 頭像'**
  String get profileBindNftAvatar;

  /// No description provided for @profileChangeAvatar.
  ///
  /// In zh, this message translates to:
  /// **'更換頭像'**
  String get profileChangeAvatar;

  /// No description provided for @groupTopics.
  ///
  /// In zh, this message translates to:
  /// **'羣話題'**
  String get groupTopics;

  /// No description provided for @groupTopicsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暫無話題'**
  String get groupTopicsEmpty;

  /// No description provided for @syncInProgress.
  ///
  /// In zh, this message translates to:
  /// **'正在同步歷史消息...'**
  String get syncInProgress;

  /// No description provided for @recoveryKeyReminderTitle.
  ///
  /// In zh, this message translates to:
  /// **'保護您的消息'**
  String get recoveryKeyReminderTitle;

  /// No description provided for @recoveryKeyReminderDesc.
  ///
  /// In zh, this message translates to:
  /// **'創建恢復密鑰以在多設備上安全同步加密消息'**
  String get recoveryKeyReminderDesc;

  /// No description provided for @recoveryKeySetupNow.
  ///
  /// In zh, this message translates to:
  /// **'立即設置'**
  String get recoveryKeySetupNow;

  /// No description provided for @recoveryKeyRemindLater.
  ///
  /// In zh, this message translates to:
  /// **'稍後提醒'**
  String get recoveryKeyRemindLater;

  /// No description provided for @channelReadOnly.
  ///
  /// In zh, this message translates to:
  /// **'僅管理員可在此頻道發言'**
  String get channelReadOnly;

  /// No description provided for @channelSubscribers.
  ///
  /// In zh, this message translates to:
  /// **'訂閱者'**
  String get channelSubscribers;

  /// No description provided for @channelVerified.
  ///
  /// In zh, this message translates to:
  /// **'已認證頻道'**
  String get channelVerified;

  /// No description provided for @redPacketHistory.
  ///
  /// In zh, this message translates to:
  /// **'紅包記錄'**
  String get redPacketHistory;

  /// No description provided for @redPacketSent.
  ///
  /// In zh, this message translates to:
  /// **'已發出'**
  String get redPacketSent;

  /// No description provided for @redPacketReceived.
  ///
  /// In zh, this message translates to:
  /// **'已收到'**
  String get redPacketReceived;

  /// No description provided for @redPacketExpired.
  ///
  /// In zh, this message translates to:
  /// **'已過期'**
  String get redPacketExpired;

  /// No description provided for @redPacketClaimed.
  ///
  /// In zh, this message translates to:
  /// **'已領取'**
  String get redPacketClaimed;

  /// No description provided for @redPacketInsufficientBalance.
  ///
  /// In zh, this message translates to:
  /// **'餘額不足'**
  String get redPacketInsufficientBalance;

  /// No description provided for @selfDestructCountdown.
  ///
  /// In zh, this message translates to:
  /// **'{time} 後銷燬'**
  String selfDestructCountdown(String time);

  /// No description provided for @messageDestroyed.
  ///
  /// In zh, this message translates to:
  /// **'消息已銷燬'**
  String get messageDestroyed;

  /// No description provided for @miniAppPermissionDenied.
  ///
  /// In zh, this message translates to:
  /// **'權限不足：{permission}'**
  String miniAppPermissionDenied(String permission);

  /// No description provided for @aiSuggestionGasFee.
  ///
  /// In zh, this message translates to:
  /// **'什麼是 Gas 費？'**
  String get aiSuggestionGasFee;

  /// No description provided for @aiSuggestionDefi.
  ///
  /// In zh, this message translates to:
  /// **'DeFi 入門'**
  String get aiSuggestionDefi;

  /// No description provided for @aiSuggestionSecurity.
  ///
  /// In zh, this message translates to:
  /// **'如何檢查合約安全'**
  String get aiSuggestionSecurity;

  /// No description provided for @aiSuggestionBridge.
  ///
  /// In zh, this message translates to:
  /// **'跨鏈橋接'**
  String get aiSuggestionBridge;

  /// No description provided for @channelDiscoverTitle.
  ///
  /// In zh, this message translates to:
  /// **'發現頻道'**
  String get channelDiscoverTitle;

  /// No description provided for @channelDiscoverSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索頻道...'**
  String get channelDiscoverSearch;

  /// No description provided for @channelJoin.
  ///
  /// In zh, this message translates to:
  /// **'加入'**
  String get channelJoin;

  /// No description provided for @channelJoined.
  ///
  /// In zh, this message translates to:
  /// **'已加入'**
  String get channelJoined;

  /// No description provided for @channelCategory.
  ///
  /// In zh, this message translates to:
  /// **'分類'**
  String get channelCategory;

  /// No description provided for @slowModeCooldown.
  ///
  /// In zh, this message translates to:
  /// **'慢速模式：請等待 {seconds} 秒'**
  String slowModeCooldown(int seconds);

  /// No description provided for @addressCopyAction.
  ///
  /// In zh, this message translates to:
  /// **'複製地址'**
  String get addressCopyAction;

  /// No description provided for @addressSendMessage.
  ///
  /// In zh, this message translates to:
  /// **'發消息'**
  String get addressSendMessage;

  /// No description provided for @addressViewProfile.
  ///
  /// In zh, this message translates to:
  /// **'查看資料'**
  String get addressViewProfile;

  /// No description provided for @sendToAddress.
  ///
  /// In zh, this message translates to:
  /// **'通過錢包地址發消息'**
  String get sendToAddress;

  /// No description provided for @blocAuthSendVerificationCodeFailed.
  ///
  /// In zh, this message translates to:
  /// **'發送驗證碼失敗'**
  String get blocAuthSendVerificationCodeFailed;

  /// No description provided for @blocAuthServerNoEmailPasswordReset.
  ///
  /// In zh, this message translates to:
  /// **'該服務器不支持通過郵箱重置密碼'**
  String get blocAuthServerNoEmailPasswordReset;

  /// No description provided for @blocAuthResetPasswordFailed.
  ///
  /// In zh, this message translates to:
  /// **'重置密碼失敗'**
  String get blocAuthResetPasswordFailed;

  /// No description provided for @blocAuthChangePasswordFailed.
  ///
  /// In zh, this message translates to:
  /// **'修改密碼失敗'**
  String get blocAuthChangePasswordFailed;

  /// No description provided for @blocAuthOldPasswordWrong.
  ///
  /// In zh, this message translates to:
  /// **'原密碼錯誤'**
  String get blocAuthOldPasswordWrong;

  /// No description provided for @blocAuthLoginCancelled.
  ///
  /// In zh, this message translates to:
  /// **'登錄已取消'**
  String get blocAuthLoginCancelled;

  /// No description provided for @blocAuthGoogleLoginFailed.
  ///
  /// In zh, this message translates to:
  /// **'Google 登錄失敗'**
  String get blocAuthGoogleLoginFailed;

  /// No description provided for @blocAuthAppleLoginFailed.
  ///
  /// In zh, this message translates to:
  /// **'Apple 登錄失敗'**
  String get blocAuthAppleLoginFailed;

  /// No description provided for @blocAuthSsoLoginFailed.
  ///
  /// In zh, this message translates to:
  /// **'SSO 登錄失敗'**
  String get blocAuthSsoLoginFailed;

  /// No description provided for @blocAuthFacebookLoginFailed.
  ///
  /// In zh, this message translates to:
  /// **'Facebook 登錄失敗'**
  String get blocAuthFacebookLoginFailed;

  /// No description provided for @blocAuthTwitterLoginFailed.
  ///
  /// In zh, this message translates to:
  /// **'Twitter 登錄失敗'**
  String get blocAuthTwitterLoginFailed;

  /// No description provided for @blocAuthWeChatLoginFailed.
  ///
  /// In zh, this message translates to:
  /// **'微信登錄失敗'**
  String get blocAuthWeChatLoginFailed;

  /// No description provided for @blocAuthWeChatNotConfigured.
  ///
  /// In zh, this message translates to:
  /// **'微信登錄未配置'**
  String get blocAuthWeChatNotConfigured;

  /// No description provided for @blocAuthWeChatNotInstalled.
  ///
  /// In zh, this message translates to:
  /// **'請先安裝微信'**
  String get blocAuthWeChatNotInstalled;

  /// No description provided for @blocAuthPasswordWrong.
  ///
  /// In zh, this message translates to:
  /// **'密碼錯誤'**
  String get blocAuthPasswordWrong;

  /// No description provided for @blocAuthEmailAlreadyBound.
  ///
  /// In zh, this message translates to:
  /// **'該郵箱已被其他賬號綁定'**
  String get blocAuthEmailAlreadyBound;

  /// No description provided for @blocAuthChangeEmailFailed.
  ///
  /// In zh, this message translates to:
  /// **'修改郵箱失敗'**
  String get blocAuthChangeEmailFailed;

  /// No description provided for @blocAuthVerificationCodeInvalid.
  ///
  /// In zh, this message translates to:
  /// **'驗證碼錯誤或已過期'**
  String get blocAuthVerificationCodeInvalid;

  /// No description provided for @blocAuthSessionExpired.
  ///
  /// In zh, this message translates to:
  /// **'會話已失效，請重新登錄'**
  String get blocAuthSessionExpired;

  /// No description provided for @blocAuthSessionIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'會話數據不完整，請重新登錄'**
  String get blocAuthSessionIncomplete;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'cs',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'it',
    'ja',
    'ko',
    'mr',
    'pl',
    'pt',
    'ru',
    'sw',
    'ta',
    'te',
    'tr',
    'uk',
    'ur',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return SPtBr();
        }
        break;
      }
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return SZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SAr();
    case 'bn':
      return SBn();
    case 'cs':
      return SCs();
    case 'de':
      return SDe();
    case 'en':
      return SEn();
    case 'es':
      return SEs();
    case 'fr':
      return SFr();
    case 'hi':
      return SHi();
    case 'id':
      return SId();
    case 'it':
      return SIt();
    case 'ja':
      return SJa();
    case 'ko':
      return SKo();
    case 'mr':
      return SMr();
    case 'pl':
      return SPl();
    case 'pt':
      return SPt();
    case 'ru':
      return SRu();
    case 'sw':
      return SSw();
    case 'ta':
      return STa();
    case 'te':
      return STe();
    case 'tr':
      return STr();
    case 'uk':
      return SUk();
    case 'ur':
      return SUr();
    case 'vi':
      return SVi();
    case 'zh':
      return SZhTw();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
