// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class SUr extends S {
  SUr([String locale = 'ur']) : super(locale);

  @override
  String get commonRetry => 'دوبارہ کوشش کریں۔';

  @override
  String get commonUnknownUser => 'نامعلوم صارف';

  @override
  String get transferWalletNotConnected => 'والیٹ منسلک نہیں ہے۔';

  @override
  String get chatCallServiceNotInitialized => 'کال سروس شروع نہیں کی گئی۔';

  @override
  String authLoginFailed(String error) {
    return 'لاگ ان ناکام: $error';
  }

  @override
  String get chatCallBack => 'واپس کال کریں۔';

  @override
  String get chatMissedVideoCall => 'مسڈ ویڈیو کال';

  @override
  String get chatMissedVoiceCall => 'مسڈ وائس کال';

  @override
  String get chatCallNotAnswered => 'جواب نہیں دیا۔';

  @override
  String get chatCallDurationLabel => 'کال کا دورانیہ';

  @override
  String get chatVoiceCallCancelled => 'وائس کال منسوخ کر دی گئی۔';

  @override
  String get chatVideoCallCancelled => 'ویڈیو کال منسوخ کر دی گئی۔';

  @override
  String get commonImage => '[تصویر]';

  @override
  String get chatVideo => '[ویڈیو]';

  @override
  String get chatVoice => '[آواز]';

  @override
  String get commonFile => '[فائل]';

  @override
  String get chatLocation => '[مقام]';

  @override
  String get chatUnknownMessage => '[نامعلوم پیغام]';

  @override
  String get commonDelete => 'حذف کریں۔';

  @override
  String get chatDeleteThisMessage => 'اس پیغام کو حذف کریں؟';

  @override
  String get chatMessageDeleted => 'پیغام حذف کر دیا گیا۔';

  @override
  String get profileNotLoggedIn => 'لاگ ان نہیں ہے۔';

  @override
  String get chatMyLocation => 'میرا مقام';

  @override
  String get commonGroupChat => 'گروپ چیٹ';

  @override
  String get commonSearch => 'تلاش کریں۔';

  @override
  String get commonCancel => 'منسوخ کریں۔';

  @override
  String get commonLoadFailed => 'لوڈ کرنے میں ناکام';

  @override
  String get commonMessages => 'پیغامات';

  @override
  String get commonContacts => 'رابطے';

  @override
  String get commonMe => 'مجھے';

  @override
  String get commonVoiceLoading =>
      'صوتی لوڈ ہو رہا ہے، براہ کرم بعد میں دوبارہ کوشش کریں۔';

  @override
  String get commonVoiceToTextFailed => 'وائس ٹو ٹیکسٹ ناکام ہو گیا۔';

  @override
  String get commonConvertToText => 'ٹیکسٹ کرنا';

  @override
  String get chatCopy => 'کاپی';

  @override
  String get commonForward => 'آگے';

  @override
  String get commonUnfavorite => 'ناپسندیدہ';

  @override
  String get commonFavorite => 'پسندیدہ';

  @override
  String get settingsResend => 'دوبارہ بھیجیں۔';

  @override
  String get chatRecall => 'یاد کرنا';

  @override
  String get commonQuote => 'اقتباس';

  @override
  String get commonRemind => 'یاد دلانا';

  @override
  String get chatCopied => 'کاپی';

  @override
  String get storySendMessageHint => 'ایک پیغام بھیجیں۔';

  @override
  String get commonMicrophonePermissionRequired =>
      'براہ کرم مائیکروفون کی اجازت دیں۔';

  @override
  String get chatMicrophonePermissionDeniedPermanent =>
      'مائیکروفون کی اجازت مسترد کر دی گئی ہے۔ صوتی پیغامات استعمال کرنے کے لیے براہ کرم اسے سسٹم کی ترتیبات میں فعال کریں۔';

  @override
  String commonStartRecordingFailed(String error) {
    return 'ریکارڈنگ شروع کرنے میں ناکام: $error';
  }

  @override
  String get commonRecordingTooShort => 'ریکارڈنگ بہت مختصر ہے۔';

  @override
  String commonStopRecordingFailed(String error) {
    return 'ریکارڈنگ روکنے میں ناکام: $error';
  }

  @override
  String get chatReleaseToCancel => 'منسوخ کرنے کے لیے ریلیز کریں۔';

  @override
  String get chatReleaseToSend =>
      'بھیجنے کے لیے ریلیز کریں، منسوخ کرنے کے لیے اوپر سوائپ کریں۔';

  @override
  String get commonHoldToTalk => 'بات کرنے کے لئے پکڑو';

  @override
  String get commonSend => 'بھیجیں۔';

  @override
  String get commonAddFriend => 'دوست شامل کریں۔';

  @override
  String get commonChatServiceNotConnected => 'چیٹ سروس منسلک نہیں ہے۔';

  @override
  String contactUserNotFoundHint(String query) {
    return 'صارف \"$query\" نہیں ملا\n\nتجاویز:\n• مکمل صارف ID درج کرنے کی کوشش کریں، جیسے @username:server.com\nصارف نام کی املا چیک کریں۔';
  }

  @override
  String contactCreateChatFailed(String error) {
    return 'چیٹ بنانے میں ناکام: $error';
  }

  @override
  String contactSearchFailed(String error) {
    return 'تلاش ناکام ہوگئی: $error';
  }

  @override
  String get contactEnterUserIdOrUsername =>
      'تلاش کرنے کے لیے یوزر آئی ڈی یا صارف نام درج کریں۔';

  @override
  String get contactSearching => 'تلاش کر رہا ہے...';

  @override
  String get contactSearchUserToChat =>
      'چیٹنگ شروع کرنے کے لیے صارف کو تلاش کریں۔';

  @override
  String get contactMatrixIdExample =>
      'آپ مکمل میٹرکس ID درج کر سکتے ہیں۔\nجیسے @user:matrix.n42.network';

  @override
  String contactUserNotFound(String username) {
    return 'صارف \"$username\" نہیں ملا';
  }

  @override
  String get commonChat => 'گپ شپ';

  @override
  String get commonSettings => 'ترتیبات';

  @override
  String get profileEditProfile => 'پروفائل میں ترمیم کریں۔';

  @override
  String get authLogin => 'لاگ ان کریں۔';

  @override
  String get commonCreateGroup => 'گروپ بنائیں';

  @override
  String get chatError => 'خرابی';

  @override
  String get commonTransfer => 'منتقلی';

  @override
  String get commonReceived => 'موصول ہوا۔';

  @override
  String get commonRefunded => 'رقم کی واپسی';

  @override
  String get commonExpired => 'میعاد ختم';

  @override
  String get chatRedPacketGreeting => 'نیک خواہشات';

  @override
  String get commonN42RedPacket => 'N42 ریڈ پیکٹ';

  @override
  String get commonClaimed => 'دعویٰ کیا۔';

  @override
  String get commonAllClaimed => 'سب نے دعویٰ کیا۔';

  @override
  String get chatReadAloud => 'بلند آواز سے پڑھیں';

  @override
  String get chatReply => 'جواب دیں۔';

  @override
  String get commonEdit => 'ترمیم کریں۔';

  @override
  String get chatSelectForwardTarget => 'فارورڈ ٹارگٹ کو منتخب کریں۔';

  @override
  String commonSendCount(int count) {
    return 'بھیجیں($count)';
  }

  @override
  String contactN42Id(String id) {
    return 'N42 ID: $id';
  }

  @override
  String get profileN42IdTitle => 'N42 ID';

  @override
  String get profileN42Bean => 'N42 بین';

  @override
  String get contactFriendInfo => 'دوست کی معلومات';

  @override
  String get contactFriendInfoDesc =>
      'دوست کا تبصرہ، فون، ٹیگز، نوٹس، تصاویر اور سیٹ کی اجازتیں شامل کریں۔';

  @override
  String get commonMoments => 'لمحات';

  @override
  String get commonSendMessage => 'پیغام';

  @override
  String get contactAudioVideoCall => 'آڈیو/ویڈیو کال';

  @override
  String get contactVideoChannel => 'ویڈیو چینل';

  @override
  String get contactRemark => 'تبصرہ';

  @override
  String get contactRemarkName => 'تبصرہ نام';

  @override
  String get contactPhone => 'فون';

  @override
  String get contactTags => 'ٹیگز';

  @override
  String get contactNotes => 'نوٹس';

  @override
  String get contactPhotos => 'تصاویر';

  @override
  String get contactPermissions => 'اجازتیں';

  @override
  String get contactChatMomentsEtc => 'چیٹ، لمحات، کھیل، وغیرہ۔';

  @override
  String get contactMoreInfo => 'مزید معلومات';

  @override
  String get contactCommonGroups => 'مشترکہ گروپس';

  @override
  String get contactSource => 'ماخذ';

  @override
  String get settingsNotificationSettings => 'اطلاعات';

  @override
  String get settingsPrivacy => 'رازداری';

  @override
  String get settingsAppearance => 'ظاہری شکل';

  @override
  String get settingsAbout => 'کے بارے میں';

  @override
  String get commonLogout => 'لاگ آؤٹ کریں۔';

  @override
  String get commonLogoutConfirm => 'کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟';

  @override
  String get commonSave => 'محفوظ کریں۔';

  @override
  String get profileNickname => 'عرفی نام';

  @override
  String get profileEnterNickname => 'عرفی نام درج کریں۔';

  @override
  String get profileSignature => 'دستخط';

  @override
  String get profileAddSignature => 'ایک دستخط شامل کریں۔';

  @override
  String get commonTakePhoto => 'تصویر کھینچو';

  @override
  String get profileChooseFromGallery => 'گیلری سے انتخاب کریں۔';

  @override
  String profileSaveFailed(String error) {
    return 'محفوظ کرنا ناکام ہو گیا: $error';
  }

  @override
  String get authSecureDecentralizedChat => 'محفوظ، وکندریقرت پیغام رسانی';

  @override
  String get commonEndToEndEncryption => 'اینڈ ٹو اینڈ انکرپشن';

  @override
  String get authMessagesOnlyYouCanSee =>
      'پیغامات صرف آپ اور وصول کنندہ کو دکھائی دیتے ہیں۔';

  @override
  String get authDecentralized => 'وکندریقرت';

  @override
  String get authBasedOnMatrix => 'میٹرکس اوپن پروٹوکول پر بنایا گیا ہے۔';

  @override
  String get authWalletIntegration => 'والیٹ انٹیگریشن';

  @override
  String get authEasyCryptoTransfer => 'آسان کریپٹو کرنسی کی منتقلی۔';

  @override
  String get authRegister => 'سائن اپ کریں۔';

  @override
  String get authAgreeTerms => 'لاگ ان کرکے، آپ اتفاق کرتے ہیں۔';

  @override
  String get authTermsOfService => 'سروس کی شرائط';

  @override
  String get authAnd => ' اور ';

  @override
  String get authPrivacyPolicy => 'رازداری کی پالیسی';

  @override
  String get authServerAddress => 'سرور کا پتہ';

  @override
  String get authEnterServerAddress => 'سرور کا پتہ درج کریں۔';

  @override
  String authConnectedTo(String serverName) {
    return '$serverName سے منسلک ہے۔';
  }

  @override
  String get authUsername => 'صارف نام';

  @override
  String get authEnterUsername => 'صارف نام درج کریں۔';

  @override
  String get authUsernameOrEmail => 'صارف نام یا ای میل';

  @override
  String get authEnterUsernameOrEmail => 'صارف نام یا ای میل درج کریں۔';

  @override
  String get authPassword => 'پاس ورڈ';

  @override
  String get authEnterPassword => 'پاس ورڈ درج کریں۔';

  @override
  String get authRegisterAccount => 'سائن اپ کریں۔';

  @override
  String get authForgotPassword => 'پاس ورڈ بھول گئے۔';

  @override
  String get authOtherLoginMethods => 'لاگ ان کے دیگر طریقے';

  @override
  String get authCreateAccount => 'اکاؤنٹ بنائیں';

  @override
  String get authJoinN42Chat => 'چیٹنگ شروع کرنے کے لیے N42 چیٹ میں شامل ہوں۔';

  @override
  String get authUsernameHint => '3-20 حروف، حروف/نمبر/_';

  @override
  String get authUsernameMinLength =>
      'صارف کا نام کم از کم 3 حروف کا ہونا چاہیے۔';

  @override
  String get authUsernameMaxLength =>
      'صارف کا نام زیادہ سے زیادہ 20 حروف کا ہونا چاہیے۔';

  @override
  String get authUsernameFormat =>
      'صارف نام میں صرف حروف، اعداد اور انڈر سکور ہو سکتے ہیں۔';

  @override
  String get authPasswordHint => 'کم از کم 8 حروف';

  @override
  String get commonPasswordMinLength =>
      'پاس ورڈ کم از کم 8 حروف کا ہونا چاہیے۔';

  @override
  String get authConfirmPassword => 'پاس ورڈ کی تصدیق کریں۔';

  @override
  String get authFilled => 'بھرا ہوا';

  @override
  String get authEnterInviteCode => 'دعوتی کوڈ درج کریں۔';

  @override
  String get authAlreadyHaveAccount => 'پہلے سے ہی اکاؤنٹ ہے؟';

  @override
  String get authLoginNow => 'ابھی لاگ ان کریں۔';

  @override
  String get profileAvatar => 'اوتار';

  @override
  String get profileStatus => 'حیثیت';

  @override
  String get commonLoading => 'لوڈ ہو رہا ہے...';

  @override
  String get conversationNoConversations => 'کوئی بات چیت نہیں۔';

  @override
  String get conversationTapToChat =>
      'چیٹنگ شروع کرنے کے لیے اوپر دائیں کو تھپتھپائیں۔';

  @override
  String get conversationStartGroup => 'گروپ چیٹ شروع کریں۔';

  @override
  String get commonScan => 'اسکین کریں۔';

  @override
  String get commonPayment => 'ادائیگی';

  @override
  String commonFeatureComingSoon(String feature) {
    return '$feature جلد آرہا ہے۔';
  }

  @override
  String get conversationMarkAsRead => 'پڑھا ہوا نشان زد کریں۔';

  @override
  String get commonUnmute => 'چالو کریں۔';

  @override
  String get commonMute => 'خاموش';

  @override
  String get conversationUnpin => 'پن کھول دیں۔';

  @override
  String get conversationPin => 'پن';

  @override
  String get conversationDeleteConversation => 'گفتگو کو حذف کریں۔';

  @override
  String conversationDeleteConversationConfirm(String name) {
    return '\"$name\" کے ساتھ گفتگو کو حذف کریں؟';
  }

  @override
  String get commonNoContacts => 'کوئی رابطے نہیں۔';

  @override
  String get contactAddFriendsToChat =>
      'چیٹنگ شروع کرنے کے لیے دوستوں کو شامل کریں۔';

  @override
  String get contactNotFound => 'رابطہ نہیں ملا';

  @override
  String get contactTryOtherKeywords =>
      'دوسرے مطلوبہ الفاظ یا عالمی تلاش کی کوشش کریں۔';

  @override
  String get contactSearchResults => 'تلاش کے نتائج';

  @override
  String get contactNewFriends => 'نئے دوست';

  @override
  String get contactChatOnlyFriends => 'صرف چیٹ کے دوست';

  @override
  String get contactOfficialAccounts => 'آفیشل اکاؤنٹس';

  @override
  String get contactServiceAccounts => 'سروس اکاؤنٹس';

  @override
  String get contactEnterpriseContacts => 'انٹرپرائز رابطے';

  @override
  String get contactRecommendToFriend => 'رابطہ شیئر کریں۔';

  @override
  String get commonSetRemark => 'ریمارکس مرتب کریں۔';

  @override
  String get contactSendingCard => 'رابطہ کارڈ بھیج رہا ہے...';

  @override
  String get commonFileLabel => 'فائل';

  @override
  String get commonLocationLabel => 'مقام';

  @override
  String contactRecommendFailed(String error) {
    return 'تجویز ناکام ہوئی: $error';
  }

  @override
  String get profileEnterRemark => 'تبصرہ درج کریں۔';

  @override
  String get contactOpeningChat => 'چیٹ کھول رہا ہے...';

  @override
  String contactOpenChatFailed(String error) {
    return 'چیٹ کھولنے میں ناکام: $error';
  }

  @override
  String get contactAddContact => 'رابطہ شامل کریں۔';

  @override
  String get contactEnterUserId => 'صارف کی شناخت درج کریں۔';

  @override
  String get contactNoFriendRequests => 'کوئی فرینڈ ریکویسٹ نہیں۔';

  @override
  String get commonAccept => 'قبول کریں۔';

  @override
  String get commonReject => 'رد کرنا';

  @override
  String get commonNoGroups => 'کوئی گروپ نہیں۔';

  @override
  String get contactSelectFriendToRecommend =>
      'تجویز کرنے کے لیے ایک دوست کا انتخاب کریں۔';

  @override
  String get commonSearchContacts => 'رابطے تلاش کریں۔';

  @override
  String get contactNoContactsFound => 'کوئی رابطے نہیں ملے';

  @override
  String get favoriteYesterday => 'کل';

  @override
  String get chatJustNow => 'ابھی ابھی';

  @override
  String get profileOnline => 'آن لائن';

  @override
  String get profileOffline => 'آف لائن';

  @override
  String get searchContactsGroupsMessages =>
      'رابطے، گروپس اور پیغامات تلاش کریں۔';

  @override
  String get searchError => 'تلاش کی خرابی۔';

  @override
  String get chatSearchHint => 'تلاش کریں۔';

  @override
  String get searchHistory => 'تلاش کی سرگزشت';

  @override
  String get commonClear => 'صاف';

  @override
  String get commonAll => 'تمام';

  @override
  String get searchGroups => 'گروپس';

  @override
  String get searchNoResults => 'کوئی نتیجہ نہیں';

  @override
  String commonGroupMembers(int count) {
    return 'اراکین ($count)';
  }

  @override
  String get groupMembersTitle => 'گروپ ممبران';

  @override
  String get groupViewAll => 'تمام دیکھیں';

  @override
  String get groupOwner => 'مالک';

  @override
  String get groupAdmin => 'ایڈمن';

  @override
  String get groupInvite => 'دعوت دیں۔';

  @override
  String get commonGroupAnnouncement => 'گروپ کا اعلان';

  @override
  String get commonNotSet => 'سیٹ نہیں ہے۔';

  @override
  String get groupDescription => 'گروپ کی تفصیل';

  @override
  String get groupPublicGroup => 'عوامی گروپ';

  @override
  String get commonClearChatHistory => 'چیٹ کی سرگزشت صاف کریں۔';

  @override
  String get commonDissolveGroup => 'تحلیل گروپ';

  @override
  String get commonLeaveGroup => 'گروپ چھوڑ دیں۔';

  @override
  String get groupChangeGroupName => 'گروپ کا نام تبدیل کریں۔';

  @override
  String get commonEnterGroupName => 'گروپ کا نام درج کریں۔';

  @override
  String get commonConfirm => 'تصدیق کریں۔';

  @override
  String get groupEnterGroupDescription => 'گروپ کی تفصیل درج کریں۔';

  @override
  String get groupPublish => 'شائع کریں۔';

  @override
  String get chatClearHistoryConfirm =>
      'تمام چیٹ کی سرگزشت صاف کریں؟ اسے کالعدم نہیں کیا جا سکتا۔';

  @override
  String get chatClearAction => 'صاف';

  @override
  String get commonChatHistoryCleared => 'چیٹ کی سرگزشت صاف کر دی گئی۔';

  @override
  String get commonDissolve => 'تحلیل کرنا';

  @override
  String get groupQrCode => 'گروپ کیو آر کوڈ';

  @override
  String get commonSearchChatHistory => 'چیٹ کی سرگزشت تلاش کریں۔';

  @override
  String get groupIdCopied => 'گروپ آئی ڈی کاپی ہو گئی۔';

  @override
  String get transferEnterOrPasteAddress =>
      'بٹوے کا پتہ درج کریں یا پیسٹ کریں۔';

  @override
  String get transferSelectToken => 'ٹوکن منتخب کریں۔';

  @override
  String get commonTransferAmount => 'منتقلی کی رقم';

  @override
  String get transferAvailable => 'دستیاب ہے۔';

  @override
  String get transferMemoOptional => 'میمو (اختیاری)';

  @override
  String get transferConfirmTransfer => 'منتقلی کی تصدیق کریں۔';

  @override
  String get transferAddressVerified => 'پتہ کی تصدیق ہو گئی۔';

  @override
  String transferAvailableBalance(String balance, String symbol) {
    return 'دستیاب: $balance $symbol';
  }

  @override
  String get commonEnterAmount => 'رقم درج کریں۔';

  @override
  String get commonRedPacketCountMin => 'کم از کم 1 سرخ پیکٹ درکار ہے۔';

  @override
  String get commonViewRedPacketDetails => 'ریڈ پیکٹ کی تفصیلات دیکھیں';

  @override
  String get commonEnterTransferAmount => 'براہ کرم منتقلی کی رقم درج کریں۔';

  @override
  String get commonTransferTo => 'میں منتقل کریں۔';

  @override
  String commonFromSender(String name, Object senderName) {
    return '$name سے';
  }

  @override
  String get commonConfirmReceive => 'رسید کی تصدیق کریں۔';

  @override
  String get groupProfile => 'گروپ کی معلومات';

  @override
  String get groupRemoveMember => 'گروپ سے ہٹا دیں۔';

  @override
  String get commonRemove => 'ہٹا دیں۔';

  @override
  String get profileClearStatus => 'سٹیٹس کو صاف کریں۔';

  @override
  String get profileClearStatusConfirm => 'موجودہ صورتحال کو صاف کریں؟';

  @override
  String get profileStatusCleared => 'اسٹیٹس کلیئر ہو گیا۔';

  @override
  String get profileUserNotExist => 'صارف موجود نہیں ہے۔';

  @override
  String get profileUserIdCopied => 'یوزر آئی ڈی کاپی ہو گئی۔';

  @override
  String get commonReport => 'رپورٹ';

  @override
  String get profileQrCode => 'کیو آر کوڈ';

  @override
  String get profileAvatarUpdated => 'اوتار اپ ڈیٹ ہو گیا۔';

  @override
  String commonSelectImageFailed(String error) {
    return 'تصویر منتخب کرنے میں ناکام: $error';
  }

  @override
  String get profileChangeName => 'نام تبدیل کریں۔';

  @override
  String get profileMale => 'مرد';

  @override
  String get profileFemale => 'خاتون';

  @override
  String chatFeatureInDev(String feature) {
    return '$feature خصوصیت ترقی میں ہے...';
  }

  @override
  String profileSaveAddressFailed(String error) {
    return 'پتہ محفوظ کرنے میں ناکام: $error';
  }

  @override
  String get profileAddNew => 'شامل کریں۔';

  @override
  String get profileAddAddress => 'ایڈریس شامل کریں۔';

  @override
  String get profileAddressAdded => 'پتہ شامل کیا گیا۔';

  @override
  String get profileAddressUpdated => 'پتہ اپ ڈیٹ ہو گیا۔';

  @override
  String get profileDeleteAddress => 'پتہ حذف کریں۔';

  @override
  String get profileAddressDeleted => 'پتہ حذف کر دیا گیا۔';

  @override
  String profileSaveInvoiceFailed(String error) {
    return 'انوائس محفوظ کرنے میں ناکام: $error';
  }

  @override
  String get profileMyInvoices => 'میری رسیدیں';

  @override
  String get profileAddInvoice => 'انوائس شامل کریں۔';

  @override
  String get profileInvoiceAdded => 'رسید شامل کر دی گئی۔';

  @override
  String get profileInvoiceUpdated => 'انوائس اپ ڈیٹ ہو گئی۔';

  @override
  String get profileDeleteInvoice => 'انوائس کو حذف کریں۔';

  @override
  String get profileInvoiceDeleted => 'رسید حذف کر دی گئی۔';

  @override
  String get profilePersonal => 'ذاتی';

  @override
  String get groupSelectAtLeastOne => 'براہ کرم کم از کم ایک رکن منتخب کریں۔';

  @override
  String get chatFileNotExist => 'فائل موجود نہیں ہے۔';

  @override
  String chatSendFailed(String error) {
    return 'بھیجنا ناکام ہو گیا: $error';
  }

  @override
  String get chatCannotOpenBrowser => 'براؤزر نہیں کھول سکتا';

  @override
  String chatSelectFileFailed(String error) {
    return 'فائل کو منتخب کرنے میں ناکام: $error';
  }

  @override
  String settingsSetupFailed(String error) {
    return 'سیٹ اپ ناکام: $error';
  }

  @override
  String get transferEnterValidAmount => 'براہ کرم ایک درست رقم درج کریں۔';

  @override
  String get commonAddressCopied => 'پتہ کاپی ہو گیا۔';

  @override
  String favoriteOpenItem(String content) {
    return 'کھولیں: $content';
  }

  @override
  String get favoriteDeleted => 'حذف کر دیا گیا۔';

  @override
  String get profileWallet => 'پرس';

  @override
  String get chatRecording => 'ریکارڈنگ';

  @override
  String get chatInvalidVideoUrl => 'غلط ویڈیو URL';

  @override
  String get chatDownloadFile => 'فائل ڈاؤن لوڈ کریں۔';

  @override
  String get chatClearChatHistoryTitle => 'چیٹ کی سرگزشت صاف کریں۔';

  @override
  String get chatVideoCall => 'ویڈیو کال';

  @override
  String get commonVoiceCall => 'وائس کال';

  @override
  String get callLeaveMeeting => 'میٹنگ چھوڑ دیں۔';

  @override
  String get chatDetails => 'چیٹ کی تفصیلات';

  @override
  String get chatViewAllGroupMembers => 'تمام ممبران کو دیکھیں';

  @override
  String get chatGroupName => 'گروپ کا نام';

  @override
  String get chatGroupNameUpdated => 'گروپ کا نام اپ ڈیٹ کر دیا گیا۔';

  @override
  String get chatUpdateFailed => 'اپ ڈیٹ ناکام ہو گیا۔';

  @override
  String get chatNoPermissionToModify => 'آپ کو ترمیم کرنے کی اجازت نہیں ہے۔';

  @override
  String get chatGroupManagement => 'گروپ مینجمنٹ';

  @override
  String get chatMyNicknameInGroup => 'گروپ میں میرا عرفی نام';

  @override
  String get chatPinChat => 'پن چیٹ';

  @override
  String get chatStrongReminder => 'مضبوط یاد دہانی';

  @override
  String get chatSetChatBackground => 'چیٹ کا پس منظر سیٹ کریں۔';

  @override
  String get chatUnknownFile => 'نامعلوم فائل';

  @override
  String get chatDownload => 'ڈاؤن لوڈ کریں۔';

  @override
  String get chatInvalidLocation => 'غلط مقام';

  @override
  String get chatTapToCancel => 'منسوخ کرنے کے لیے تھپتھپائیں۔';

  @override
  String chatCaptureFailed(Object error) {
    return 'کیپچر ناکام: $error';
  }

  @override
  String get chatProcessingVideo => 'ویڈیو پر کارروائی ہو رہی ہے...';

  @override
  String get chatVideoFileNotExist => 'ویڈیو فائل موجود نہیں ہے۔';

  @override
  String get chatVideoDataEmpty => 'ویڈیو ڈیٹا خالی ہے۔';

  @override
  String get chatVideoTooLarge => 'ویڈیو کا سائز 100MB سے زیادہ نہیں ہو سکتا';

  @override
  String get chatSendingVideo => 'ویڈیو بھیج رہا ہے...';

  @override
  String chatSendVideoFailed(Object error) {
    return 'ویڈیو بھیجنے میں ناکام: $error';
  }

  @override
  String get chatImageFileNotExist => 'تصویری فائل موجود نہیں ہے۔';

  @override
  String get commonImageDataEmpty => 'تصویر کا ڈیٹا خالی ہے۔';

  @override
  String get chatSendingImage => 'تصویر بھیجی جا رہی ہے...';

  @override
  String chatSendImageFailed(Object error) {
    return 'تصویر بھیجنے میں ناکام: $error';
  }

  @override
  String get chatSendLocation => 'مقام بھیجیں۔';

  @override
  String get chatSelectLocationAndSend => 'مقام منتخب کریں اور بھیجیں۔';

  @override
  String get chatShareRealTimeLocation => 'ریئل ٹائم لوکیشن شیئر کریں۔';

  @override
  String get chatShareLocationForOneHour =>
      '1 گھنٹے کے لیے دوست کے ساتھ حقیقی وقت کا مقام شیئر کریں۔';

  @override
  String get chatLocationSent => 'مقام بھیجا گیا۔';

  @override
  String get chatSelectMessages => 'پیغامات منتخب کریں۔';

  @override
  String chatSelectedCount(int count) {
    return 'منتخب کردہ $count';
  }

  @override
  String get chatSelectAll => 'سبھی کو منتخب کریں۔';

  @override
  String chatGroupChatCount(int count) {
    return 'گروپ چیٹ($count)';
  }

  @override
  String get chatPrivateChat => 'پرائیویٹ چیٹ';

  @override
  String get chatNoMessages => 'کوئی پیغامات نہیں۔';

  @override
  String get chatSendFirstMessage =>
      'چیٹنگ شروع کرنے کے لیے پہلا پیغام بھیجیں۔';

  @override
  String get chatEncryptionNotice =>
      'یہ چیٹ اینڈ ٹو اینڈ انکرپٹڈ ہے۔ صرف آپ اور وصول کنندہ ہی پیغامات پڑھ سکتے ہیں۔';

  @override
  String get chatMultiForward => 'آگے';

  @override
  String get chatCollect => 'جمع کرنا';

  @override
  String get chatNoMembers => 'کوئی ممبر نہیں۔';

  @override
  String get chatMemberNotFound => 'ممبر نہیں ملا';

  @override
  String get chatVoiceFileNotExist => 'وائس فائل موجود نہیں ہے۔';

  @override
  String get chatVoiceFileEmpty => 'وائس فائل خالی ہے۔';

  @override
  String get chatSendingVoice => 'آواز بھیجی جا رہی ہے...';

  @override
  String chatSendVoiceFailed(Object error) {
    return 'آواز بھیجنے میں ناکام: $error';
  }

  @override
  String get chatMessageForwarded => 'پیغام آگے بھیج دیا گیا۔';

  @override
  String chatForwardFailed(Object error) {
    return 'آگے بڑھانے میں ناکام: $error';
  }

  @override
  String get chatUnfavorited => 'ناپسندیدہ';

  @override
  String get chatFavorited => 'پسندیدہ';

  @override
  String get chatReactionAdded => 'رد عمل شامل کیا گیا۔';

  @override
  String get chatReactionRemoved => 'رد عمل کو ہٹا دیا گیا۔';

  @override
  String get chatFailedMessageDeleted => 'ناکام پیغام حذف کر دیا گیا۔';

  @override
  String get chatDeleteMessages => 'پیغامات کو حذف کریں۔';

  @override
  String chatDeleteMessagesConfirm(Object count) {
    return 'کیا آپ واقعی $count پیغامات کو حذف کرنا چاہتے ہیں؟';
  }

  @override
  String chatNoteOtherMessages(Object count) {
    return 'نوٹ: $count پیغامات دوسروں کے ہیں اور صرف آپ کے لیے حذف کیے جائیں گے۔';
  }

  @override
  String chatMyMessagesWillBeRecalled(Object count) {
    return 'آپ کی طرف سے $count پیغامات سب کے لیے واپس بلائے جائیں گے۔';
  }

  @override
  String chatRecalledCount(Object count, Object localCount) {
    return 'واپس بلائے گئے $count پیغامات، $localCount صرف آپ کے لیے حذف کیے گئے۔';
  }

  @override
  String chatRecalledMessages(Object count) {
    return 'یاد کیے گئے $count پیغامات';
  }

  @override
  String chatDeletedLocally(Object count) {
    return '$count پیغامات صرف آپ کے لیے حذف کیے گئے ہیں۔';
  }

  @override
  String chatForwardedCount(Object count) {
    return 'آگے بھیجے گئے $count پیغامات';
  }

  @override
  String chatForwardComplete(Object failed, Object success) {
    return 'آگے بڑھانا مکمل: $success کامیاب، $failed ناکام';
  }

  @override
  String get chatRemindOnlyInGroup =>
      'یاد دہانی کی خصوصیت صرف گروپ چیٹ میں دستیاب ہے۔';

  @override
  String get chatOnlyTextSearchable =>
      'صرف ٹیکسٹ پیغامات ہی تلاش کیے جا سکتے ہیں۔';

  @override
  String chatSearchFor(Object text) {
    return '\"$text\" تلاش کریں';
  }

  @override
  String get chatBaiduSearch => 'Baidu تلاش';

  @override
  String get chatGoogleSearch => 'گوگل سرچ';

  @override
  String get chatBingSearch => 'بنگ سرچ';

  @override
  String get chatCalling => 'کال کر رہا ہے...';

  @override
  String get chatRinging => 'بج رہا ہے...';

  @override
  String get chatInCall => 'کال میں';

  @override
  String commonFeatureInDevelopment(String feature) {
    return '$feature خصوصیت ترقی میں ہے...';
  }

  @override
  String chatCollectMessages(Object count) {
    return 'جمع کردہ $count پیغامات';
  }

  @override
  String commonMemberCount(int count) {
    return '$count اراکین';
  }

  @override
  String groupDone(int count) {
    return 'ہو گیا($count)';
  }

  @override
  String get profileServices => 'خدمات';

  @override
  String get commonFavorites => 'پسندیدہ';

  @override
  String get profileOrdersAndCards => 'آرڈرز اور کارڈز';

  @override
  String get profileStickers => 'اسٹیکرز';

  @override
  String profileStatusSetTo(String status) {
    return 'اسٹیٹس اس پر سیٹ کیا گیا: $status';
  }

  @override
  String get profileAvatarUploadFailed => 'اوتار اپ لوڈ ناکام ہو گیا۔';

  @override
  String get profilePersonalProfile => 'ذاتی پروفائل';

  @override
  String get profileName => 'نام';

  @override
  String get profileGender => 'جنس';

  @override
  String get profileRegion => 'علاقہ';

  @override
  String get commonMyQrCode => 'میرا QR کوڈ';

  @override
  String get profilePoke => 'پوک';

  @override
  String get profileRingtone => 'رنگ ٹون';

  @override
  String get profileDefaultRingtone => 'ڈیفالٹ رنگ ٹون';

  @override
  String get profileMyAddresses => 'میرے پتے';

  @override
  String profileGenderSetTo(String gender) {
    return 'جنس اس پر سیٹ کی گئی: $gender';
  }

  @override
  String get profileSelectRegion => 'علاقہ منتخب کریں۔';

  @override
  String get profileSelectCity => 'شہر منتخب کریں۔';

  @override
  String profileRegionSetTo(String region) {
    return 'علاقہ اس پر سیٹ کیا گیا: $region';
  }

  @override
  String get profileSetPoke => 'پوک سیٹ کریں۔';

  @override
  String get profileFriendPokedMe => 'دوست نے مجھے تھپڑ مارا۔';

  @override
  String get profileExample => 'مثال';

  @override
  String get profileOnTheShoulder => ' کندھے پر';

  @override
  String get profilePokeCleared => 'پوک صاف ہو گیا۔';

  @override
  String profilePokeSetTo(String suffix) {
    return 'پوک سیٹ پر: پوکڈ me$suffix';
  }

  @override
  String get profileEditSignature => 'دستخط میں ترمیم کریں۔';

  @override
  String get profileIntroduceYourself => 'اپنا تعارف کروانے کے لیے ایک جملہ';

  @override
  String get profileSignatureCleared => 'دستخط صاف ہو گئے۔';

  @override
  String get profileSignatureUpdated => 'دستخط کو اپ ڈیٹ کر دیا گیا۔';

  @override
  String get profileScanToAddFriend =>
      'مجھے بطور دوست شامل کرنے کے لیے اوپر والا QR کوڈ اسکین کریں۔';

  @override
  String profileRingtoneSetTo(String ringtone) {
    return 'رنگ ٹون اس پر سیٹ کیا گیا: $ringtone';
  }

  @override
  String commonConfirmDissolveGroup(String name) {
    return 'کیا آپ واقعی \"$name\" کو تحلیل کرنا چاہتے ہیں؟ اس کارروائی کو کالعدم نہیں کیا جا سکتا۔';
  }

  @override
  String get authEnterValidServerAddress =>
      'براہ کرم ایک درست سرور ایڈریس درج کریں۔';

  @override
  String get authEnterServerAddressFirst =>
      'براہ کرم پہلے سرور کا پتہ درج کریں۔';

  @override
  String get authPasskeyRequiresServer =>
      'پاسکی لاگ ان کے لیے سرور سپورٹ درکار ہے۔';

  @override
  String get authLoginAgreement => 'لاگ ان کرکے، آپ اتفاق کرتے ہیں۔ ';

  @override
  String get authPleaseAgreeToTerms =>
      'براہ کرم سروس کی شرائط اور رازداری کی پالیسی کو پڑھیں اور ان سے اتفاق کریں۔';

  @override
  String get authRegisterFailed => 'رجسٹریشن ناکام ہو گئی۔';

  @override
  String get commonReenterPassword => 'پاس ورڈ دوبارہ درج کریں۔';

  @override
  String get commonPasswordsDoNotMatch => 'پاس ورڈز مماثل نہیں ہیں۔';

  @override
  String get authInviteCodeBuiltIn => 'انوائٹ کوڈ (بلٹ ان)';

  @override
  String get authInviteCodeBuiltInNote =>
      'انوائٹ کوڈ بلٹ ان ہوتا ہے، عام طور پر اس میں ترمیم کرنے کی ضرورت نہیں ہوتی ہے۔';

  @override
  String get authIHaveReadAndAgree =>
      'میں نے پڑھا ہے اور اس سے اتفاق کرتا ہوں۔ ';

  @override
  String get mainStartGroupChat => 'گروپ چیٹ شروع کریں۔';

  @override
  String get mainAddFriends => 'دوستوں کو شامل کریں۔';

  @override
  String get mainPaymentAndCollection => 'ادائیگی';

  @override
  String contactCount(int count) {
    return '$count رابطے';
  }

  @override
  String get contactAddToHomeScreen => 'ہوم اسکرین میں شامل کریں۔';

  @override
  String contactRecommendedCardTo(String contact, String recipient) {
    return 'تجویز کردہ $contact کا کارڈ $recipient کو';
  }

  @override
  String get contactEnterRemarkName => 'تبصرہ نام درج کریں۔';

  @override
  String contactRemarkSetTo(String remark) {
    return 'تبصرہ اس پر سیٹ کیا گیا: $remark';
  }

  @override
  String contactAcceptedFriendRequest(String name) {
    return '$name کی دوستی کی درخواست قبول کر لی گئی۔';
  }

  @override
  String contactRejectedFriendRequest(String name) {
    return '$name کی دوستی کی درخواست مسترد کر دی گئی۔';
  }

  @override
  String get commonGroupInvites => 'گروپ دعوتیں';

  @override
  String commonMyGroups(int count) {
    return 'میرے گروپس ($count)';
  }

  @override
  String get commonInvitedToJoinGroup => 'گروپ میں شامل ہونے کی دعوت دی گئی۔';

  @override
  String commonConfirmLeaveGroup(String name) {
    return 'کیا آپ واقعی \"$name\" چھوڑنا چاہتے ہیں؟';
  }

  @override
  String get commonLeave => 'چھوڑو';

  @override
  String get commonRecallThisMessage => 'یہ پیغام یاد ہے؟';

  @override
  String get commonSavedToGallery => 'گیلری میں محفوظ کیا گیا۔';

  @override
  String get commonFailedToSave => 'محفوظ کرنے میں ناکام';

  @override
  String get chatSaving => 'محفوظ کر رہا ہے...';

  @override
  String get commonShare => 'شیئر کریں۔';

  @override
  String get chatSaveToGallery => 'گیلری میں محفوظ کریں۔';

  @override
  String chatDownloadFailed(String code) {
    return 'ڈاؤن لوڈ ناکام: $code';
  }

  @override
  String commonShareFailed(String error) {
    return 'اشتراک ناکام: $error';
  }

  @override
  String get chatFailedToLoadImage => 'تصویر لوڈ کرنے میں ناکام';

  @override
  String get chatVideoRecordingFailed => 'ویڈیو ریکارڈنگ ناکام ہوگئی';

  @override
  String get profileRedPacket => 'سرخ پیکٹ';

  @override
  String get commonMusic => 'موسیقی';

  @override
  String get commonCoupon => 'کوپن';

  @override
  String get commonGift => 'تحفہ';

  @override
  String get commonPoll => 'رائے شماری';

  @override
  String get favoriteText => 'متن';

  @override
  String get favoriteLinkLabel => 'لنک';

  @override
  String get favoriteNote => 'نوٹ';

  @override
  String get favoriteMyNotes => 'میرے نوٹس';

  @override
  String get favoriteToday => 'آج';

  @override
  String favoriteDaysAgoText(int count) {
    return '$count دن پہلے';
  }

  @override
  String favoriteDateFormat(int month, int day) {
    return '$month/$day';
  }

  @override
  String get favoriteNoFavorites => 'ابھی تک کوئی پسندیدہ نہیں ہے۔';

  @override
  String get favoriteLongPressToFavorite => 'پسندیدہ کو طویل پریس پیغام';

  @override
  String get favoriteNewNote => 'نیا نوٹ';

  @override
  String get favoriteLink => 'پسندیدہ لنک';

  @override
  String get favoriteEditTags => 'ٹیگز میں ترمیم کریں۔';

  @override
  String get favoriteDeleteFavorite => 'پسندیدہ حذف کریں۔';

  @override
  String get favoriteDeleteFavoriteConfirm =>
      'کیا آپ واقعی اس پسندیدہ کو حذف کرنا چاہتے ہیں؟';

  @override
  String get favoriteNoSearchResultsFound => 'کوئی نتیجہ نہیں ملا';

  @override
  String get commonSendRedPacket => 'ریڈ پیکٹ بھیجیں۔';

  @override
  String get transferAmount => 'رقم';

  @override
  String get commonRedPacketCover => 'ریڈ پیکٹ کور';

  @override
  String get commonRedPacketType => 'ریڈ پیکٹ کی قسم';

  @override
  String get commonNormalRedPacket => 'نارمل';

  @override
  String get commonLuckyRedPacket => 'لکی';

  @override
  String get commonRedPacketCount => 'ریڈ پیکٹ کاؤنٹ';

  @override
  String get commonPieces => 'ٹکڑے';

  @override
  String get commonPutMoneyInRedPacket => 'پیسے لال پیکٹ میں رکھیں';

  @override
  String get commonRedPacketRefundNotice =>
      'غیر دعویدار سرخ پیکٹ 24 گھنٹے بعد واپس کر دیے جائیں گے۔';

  @override
  String get commonOpenRedPacket => 'کھولیں۔';

  @override
  String get commonRedPacketAllClaimed => 'سرخ پیکٹ سبھی کا دعویٰ کیا گیا۔';

  @override
  String get commonRedPacketExpired => 'سرخ پیکٹ کی میعاد ختم ہوگئی';

  @override
  String get commonAddTransferNote => 'ٹرانسفر نوٹ شامل کریں۔';

  @override
  String get commonYuan => 'CNY';

  @override
  String get commonReplyWithEmoji => 'اس ایموجی کے ساتھ جواب دیں۔';

  @override
  String get contactEditRemark => 'ریمارکس میں ترمیم کریں۔';

  @override
  String get contactSetPermissions => 'اجازتیں سیٹ کریں۔';

  @override
  String get profileAddToBlacklist => 'بلیک لسٹ میں شامل کریں۔';

  @override
  String get contactDeleteContact => 'رابطہ حذف کریں۔';

  @override
  String contactDeleteContactConfirm(String name) {
    return 'کیا آپ واقعی $name کو حذف کرنا چاہتے ہیں؟';
  }

  @override
  String get transferTitle => 'منتقلی';

  @override
  String get transferReceiverAddressLabel => 'وصول کنندہ کا پتہ';

  @override
  String get transferSelectTokenLabel => 'ٹوکن منتخب کریں۔';

  @override
  String get transferAmountLabel => 'منتقلی کی رقم';

  @override
  String get transferMemoLabel => 'میمو (اختیاری)';

  @override
  String get transferAddMemoHint => 'ایک میمو شامل کریں۔';

  @override
  String get transferSendPaymentRequest => 'ادائیگی کی درخواست بھیجیں۔';

  @override
  String get transferQrCodeGenerateFailed => 'QR کوڈ جنریشن ناکام ہو گیا۔';

  @override
  String get transferScanQrToPayMe =>
      'مجھے ادائیگی کرنے کے لیے QR کوڈ اسکین کریں۔';

  @override
  String get transferMyWalletAddress => 'میرا پرس کا پتہ';

  @override
  String get transferCreatePaymentRequest => 'ادائیگی کی درخواست بنائیں';

  @override
  String profileN42IdLabel(String id) {
    return 'N42 ID: $id';
  }

  @override
  String get commonRedPacketDefaultGreeting => 'نیک خواہشات';

  @override
  String commonSenderRedPacket(String name) {
    return '$name کا سرخ پیکٹ';
  }

  @override
  String get transferEnterValidAddress => 'براہ کرم ایک درست پتہ درج کریں۔';

  @override
  String get transferPleaseSelectToken => 'براہ کرم ایک ٹوکن منتخب کریں۔';

  @override
  String get commonReceivedTransfer => 'ٹرانسفر موصول ہوا۔';

  @override
  String commonSenderSentRedPacket(String name) {
    return '$name نے ایک سرخ پیکٹ بھیجا ہے۔';
  }

  @override
  String get commonSavedToBalance =>
      'بیلنس میں محفوظ، براہ راست منتقل کر سکتے ہیں';

  @override
  String get commonRedPacketExpiredOrEmpty =>
      'سرخ پیکٹ کی میعاد ختم ہوگئی / تمام دعویٰ کیا گیا۔';

  @override
  String get transferScanFeatureComingSoon => 'اسکین فیچر جلد آرہا ہے...';

  @override
  String get contactSetAsStarred => 'ستارے کے طور پر سیٹ کریں۔';

  @override
  String get contactAddToBlocklist => 'بلاک لسٹ میں شامل کریں۔';

  @override
  String get commonClaimedYour => ' آپ کا دعوی کیا ';

  @override
  String get commonClaimedText => ' دعوی کیا ';

  @override
  String commonUserTyping(String name) {
    return '$name ٹائپ کر رہا ہے...';
  }

  @override
  String get commonTyping => 'ٹائپنگ...';

  @override
  String get commonWaitingToReceive => 'موصول ہونے کا انتظار کر رہے ہیں۔';

  @override
  String get commonTapToClaim => 'دعوی کرنے کے لیے تھپتھپائیں۔';

  @override
  String get commonHasBeenReceived => 'موصول ہوا ہے۔';

  @override
  String get commonGetLucky => 'خوش قسمت ہو جاؤ';

  @override
  String get qrcodeCameraStartFailed => 'کیمرہ شروع ہونے میں ناکام';

  @override
  String get qrcodeUnknownError => 'نامعلوم خرابی۔';

  @override
  String get qrcodePlaceQrCodeInFrame =>
      'اسکین کرنے کے لیے فریم کے اندر QR کوڈ رکھیں';

  @override
  String get qrcodeCloseManualInput => 'دستی ان پٹ بند کریں۔';

  @override
  String get qrcodeManualInputUserId => 'دستی ان پٹ یوزر آئی ڈی';

  @override
  String get commonAdd => 'شامل کریں۔';

  @override
  String get profileSetStatus => 'اسٹیٹس سیٹ کریں۔';

  @override
  String get profileVisibleToFriends24h => '24 گھنٹے دوستوں کے لیے مرئی';

  @override
  String get profileWriteStatus => 'اسٹیٹس لکھیں۔';

  @override
  String get profileEnterYourStatus => 'اپنی حیثیت درج کریں...';

  @override
  String get profileOk => 'ٹھیک ہے';

  @override
  String get qrcodeCameraPermissionRequired =>
      'کیو آر کوڈ اسکین کرنے کے لیے کیمرے کی اجازت درکار ہے۔';

  @override
  String get qrcodeCameraPermissionDenied =>
      'کیمرے کی اجازت مستقل طور پر مسترد کر دی گئی۔ براہ کرم اسے سسٹم کی ترتیبات میں فعال کریں۔';

  @override
  String qrcodePermissionCheckError(String error) {
    return 'اجازت چیک کرنے میں خرابی: $error';
  }

  @override
  String get qrcodeInvalidQrCode => 'غلط QR کوڈ';

  @override
  String qrcodeCannotAddFriend(String error) {
    return 'دوست کو شامل نہیں کیا جا سکتا: $error';
  }

  @override
  String get qrcodeScanQrCode => 'کیو آر کوڈ اسکین کریں۔';

  @override
  String get qrcodeCheckingCameraPermission =>
      'کیمرے کی اجازت چیک کی جا رہی ہے...';

  @override
  String get qrcodeNeedCameraPermission => 'کیمرے کی اجازت درکار ہے۔';

  @override
  String get qrcodeRetryPermission => 'دوبارہ کوشش کریں۔';

  @override
  String get qrcodeOpenSettings => 'ترتیبات کھولیں۔';

  @override
  String get groupInviteMembers => 'ممبران کو مدعو کریں۔';

  @override
  String groupInviteCount(int count) {
    return 'مدعو کریں($count)';
  }

  @override
  String get profileNoShippingAddress => 'کوئی شپنگ ایڈریس نہیں۔';

  @override
  String get profileDefaultLabel => 'طے شدہ';

  @override
  String get profileNoInvoice => 'کوئی رسید نہیں۔';

  @override
  String get profileCompany => 'کمپنی';

  @override
  String get profileTaxNumber => 'ٹیکس نمبر';

  @override
  String get profileConfirmDeleteAddress =>
      'کیا آپ واقعی یہ پتہ حذف کرنا چاہتے ہیں؟';

  @override
  String get profileConfirmDeleteInvoice =>
      'کیا آپ واقعی اس رسید کو حذف کرنا چاہتے ہیں؟';

  @override
  String get commonGroupOwner => 'مالک';

  @override
  String get commonGroupAdmin => 'ایڈمن';

  @override
  String get groupSearchMembers => 'اراکین کو تلاش کریں۔';

  @override
  String groupTotalMembers(int count) {
    return '$count اراکین';
  }

  @override
  String get chatRemoveFromGroup => 'گروپ سے ہٹا دیں۔';

  @override
  String groupConfirmRemoveMember(String name) {
    return 'کیا آپ واقعی \"$name\" کو گروپ سے ہٹانا چاہتے ہیں؟';
  }

  @override
  String get chatUnknownSong => 'نامعلوم گانا';

  @override
  String get chatUnknownArtist => 'نامعلوم فنکار';

  @override
  String get chatUnknownContact => 'نامعلوم رابطہ';

  @override
  String get chatPersonalCard => 'رابطہ کارڈ';

  @override
  String get chatSingleChoice => 'سنگل';

  @override
  String get chatMultiChoice => 'کثیر';

  @override
  String get chatEnded => 'ختم ہوا۔';

  @override
  String get chatEndPollButton => 'پول ختم کریں۔';

  @override
  String get chatPollHint =>
      'پول چیٹ میں دکھایا جائے گا۔ گروپ ممبران ووٹ دے سکتے ہیں۔';

  @override
  String get chatSearchSongOrArtist => 'گانا یا فنکار تلاش کریں۔';

  @override
  String get chatNoSongsFound => 'کوئی گانے نہیں ملے';

  @override
  String get chatSongNameOptional => 'گانے کا نام (اختیاری)';

  @override
  String get chatEnterSongName => 'گانے کا نام درج کریں۔';

  @override
  String get chatArtistNameOptional => 'فنکار کا نام (اختیاری)';

  @override
  String get chatEnterArtistName => 'فنکار کا نام درج کریں۔';

  @override
  String get chatRealTimeLocationSharing =>
      'ترقی میں ریئل ٹائم لوکیشن شیئرنگ...';

  @override
  String get profileVoiceCallFeatureInDev => 'ترقی میں وائس کال کی خصوصیت...';

  @override
  String get profileReportFeatureInDev => 'ترقی میں خصوصیت کی اطلاع دیں...';

  @override
  String get profileShareFeatureInDev => 'ترقی میں خصوصیت کا اشتراک کریں...';

  @override
  String get profileQrCodeFeatureInDev => 'ترقی میں QR کوڈ کی خصوصیت...';

  @override
  String get qrcodeScanQrToAddMe =>
      'مجھے بطور دوست شامل کرنے کے لیے اوپر والا QR کوڈ اسکین کریں۔';

  @override
  String get qrcodeSaveToAlbum => 'البم میں محفوظ کریں۔';

  @override
  String get qrcodeChangeStyle => 'انداز تبدیل کریں۔';

  @override
  String get qrcodeCopyId => 'آئی ڈی کاپی کریں۔';

  @override
  String get qrcodeIdCopied => 'آئی ڈی کاپی ہو گئی۔';

  @override
  String get qrcodeMoreStylesFeatureComingSoon => 'مزید طرزیں جلد آرہی ہیں۔';

  @override
  String get profileBio => 'بایو';

  @override
  String get profileHomeServer => 'سرور';

  @override
  String get profileShareContactCard => 'رابطہ کارڈ شیئر کریں۔';

  @override
  String get profileRemoveFromBlacklist => 'بلیک لسٹ سے ہٹا دیں۔';

  @override
  String get profileConfirmAddBlacklist =>
      'کیا آپ واقعی اس صارف کو بلیک لسٹ میں شامل کرنا چاہتے ہیں؟ آپ کو ان کے پیغامات موصول نہیں ہوں گے۔';

  @override
  String get profileConfirmRemoveBlacklist =>
      'کیا آپ واقعی اس صارف کو بلیک لسٹ سے ہٹانا چاہتے ہیں؟';

  @override
  String get profileRemarkSaved => 'تبصرہ محفوظ ہو گیا۔';

  @override
  String get profileRemarkCleared => 'ریمارکس کلیئر ہو گئے۔';

  @override
  String get transferReceive => 'وصول کریں۔';

  @override
  String get transferPleaseConnectWallet => 'براہ کرم پہلے اپنا بٹوہ جوڑیں۔';

  @override
  String get transferSendRequest => 'درخواست بھیجیں۔';

  @override
  String get transferPleaseEnterValidAmount =>
      'براہ کرم ایک درست رقم درج کریں۔';

  @override
  String get searchPlaceholder => 'رابطے، گروپس، پیغامات تلاش کریں۔';

  @override
  String get searchEnterKeywordToSearch =>
      'تلاش شروع کرنے کے لیے کلیدی لفظ درج کریں۔';

  @override
  String get searchClearHistory => 'صاف';

  @override
  String searchNoResultsForQuery(String query) {
    return '\"$query\" کے لیے کوئی نتیجہ نہیں ملا';
  }

  @override
  String get searchAllResults => 'تمام';

  @override
  String get searchInChat => 'چیٹ میں تلاش کریں۔';

  @override
  String get searchContactLabel => 'رابطہ کریں۔';

  @override
  String get searchGroupLabel => 'گروپ';

  @override
  String get searchConversationLabel => 'بات چیت';

  @override
  String get searchMessageLabel => 'پیغام';

  @override
  String get settingsSecurityTitle => 'سیکورٹی';

  @override
  String get settingsKeyBackup => 'کلیدی بیک اپ';

  @override
  String get settingsBackupEncryptionKeys => 'بیک اپ انکرپشن کیز';

  @override
  String settingsKeysBackedUp(int count) {
    return '$count کیز کا بیک اپ لیا گیا۔';
  }

  @override
  String get settingsBackupNotSet => 'بیک اپ سیٹ نہیں ہے۔';

  @override
  String get settingsRestoreKeys => 'چابیاں بحال کریں۔';

  @override
  String get settingsRestoreKeysFromBackup =>
      'بیک اپ سے انکرپشن کیز کو بحال کریں۔';

  @override
  String get settingsExportKeys => 'ایکسپورٹ کیز';

  @override
  String get settingsExportKeysToFile => 'فائل میں چابیاں برآمد کریں۔';

  @override
  String get settingsLoggedInDevices => 'لاگ ان ڈیوائسز';

  @override
  String get settingsNoOtherDevices => 'کوئی اور آلات نہیں۔';

  @override
  String get settingsVerified => 'تصدیق شدہ';

  @override
  String get settingsUnverified => 'غیر تصدیق شدہ';

  @override
  String get settingsAdvanced => 'اعلی درجے کی';

  @override
  String get settingsCrossSigning => 'کراس سائن کرنا';

  @override
  String get settingsEnabled => 'فعال';

  @override
  String get settingsNotEnabled => 'فعال نہیں ہے۔';

  @override
  String get settingsResetEncryption => 'خفیہ کاری کو دوبارہ ترتیب دیں۔';

  @override
  String get settingsDeleteAllEncryptionKeys => 'تمام انکرپشن کیز کو حذف کریں۔';

  @override
  String get settingsEncryptionNotSupported => 'خفیہ کاری تعاون یافتہ نہیں ہے۔';

  @override
  String get settingsNotInitialized => 'شروع نہیں کیا گیا۔';

  @override
  String get settingsBackupKeyTitle => 'بیک اپ کیز';

  @override
  String get settingsBackupKeyMessage =>
      'ایک نیا کلید بیک اپ بنائیں؟ اس سے آپ کو ایک نئے آلے پر خفیہ کردہ پیغامات کو بحال کرنے میں مدد ملے گی۔';

  @override
  String get settingsBackup => 'بیک اپ';

  @override
  String get settingsRestoreKeyTitle => 'چابیاں بحال کریں۔';

  @override
  String get settingsRestoreKeyMessage =>
      'خفیہ کردہ پیغامات کو بحال کرنے کے لیے اپنا ریکوری پاس ورڈ یا ریکوری کلید درج کریں۔';

  @override
  String get settingsRestore => 'بحال کریں۔';

  @override
  String get settingsExportKeyTitle => 'ایکسپورٹ کیز';

  @override
  String get settingsExportKeyMessage =>
      'برآمد شدہ کلید فائل میں آپ کی تمام خفیہ کاری کیز شامل ہیں۔ براہ کرم اسے محفوظ رکھیں۔';

  @override
  String get settingsExport => 'برآمد کریں۔';

  @override
  String settingsDeviceIdLabel(String deviceId) {
    return 'ڈیوائس ID: $deviceId';
  }

  @override
  String get settingsDeviceStatusVerified => 'حیثیت: تصدیق شدہ';

  @override
  String get settingsDeviceStatusUnverified => 'حیثیت: غیر تصدیق شدہ';

  @override
  String settingsLastActiveLabel(String lastSeen) {
    return 'آخری فعال: $lastSeen';
  }

  @override
  String get settingsVerifyThisDevice => 'اس ڈیوائس کی تصدیق کریں۔';

  @override
  String get settingsCrossSigningAlreadyEnabled =>
      'کراس سائننگ پہلے ہی فعال ہے۔';

  @override
  String get settingsCrossSigningSetupSuccess => 'کراس سائننگ سیٹ اپ کامیاب';

  @override
  String get settingsResetEncryptionTitle => 'خفیہ کاری کو دوبارہ ترتیب دیں۔';

  @override
  String get settingsResetEncryptionWarning =>
      'انتباہ: یہ آپ کی تمام انکرپشن کیز کو حذف کر دے گا۔ آپ پچھلے خفیہ کردہ پیغامات کو ڈکرپٹ نہیں کر سکیں گے۔ اس کارروائی کو کالعدم نہیں کیا جا سکتا۔';

  @override
  String get settingsReset => 'دوبارہ ترتیب دیں۔';

  @override
  String get settingsBackupSuccess => 'کلیدوں کا کامیابی سے بیک اپ لیا گیا۔';

  @override
  String get settingsBackupFailed => 'بیک اپ ناکام ہو گیا۔';

  @override
  String get settingsRecoveryKey => 'ریکوری کلید';

  @override
  String get settingsRecoveryKeySaveWarning =>
      'براہ کرم اس ریکوری کلید کو محفوظ جگہ پر محفوظ کریں۔ آپ کو اپنے انکرپٹڈ پیغامات کو نئے آلے پر بحال کرنے کے لیے اس کی ضرورت ہوگی۔';

  @override
  String get settingsRecoveryKeySaved => 'میں نے اسے محفوظ کر لیا ہے۔';

  @override
  String get settingsRestoreSuccess => 'کلیدیں کامیابی کے ساتھ بحال ہو گئیں۔';

  @override
  String get settingsRestoreFailed => 'بحالی ناکام ہوگئی';

  @override
  String get settingsPassword => 'پاس ورڈ';

  @override
  String get settingsEnterRecoveryKey => 'ریکوری کلید درج کریں۔';

  @override
  String get settingsEnterPassword => 'پاس ورڈ درج کریں۔';

  @override
  String get settingsExportSuccess =>
      'سرور بیک اپ میں کلیدیں کامیابی کے ساتھ برآمد ہو گئیں۔';

  @override
  String get settingsExportNeedBackupFirst =>
      'براہ کرم پہلے ایک کلیدی بیک اپ بنائیں';

  @override
  String get settingsExportFailed => 'ایکسپورٹ ناکام ہو گیا۔';

  @override
  String get settingsResetSuccess => 'خفیہ کاری کا دوبارہ ترتیب کامیاب ہو گیا۔';

  @override
  String get settingsResetFailed => 'ری سیٹ ناکام ہو گیا۔';

  @override
  String get callLeaveMeetingConfirm => 'کیا آپ واقعی میٹنگ چھوڑنا چاہتے ہیں؟';

  @override
  String chatPokedSomeone(String name, String suffix) {
    return 'پوکڈ $name$suffix';
  }

  @override
  String get chatNoContactsToAdd =>
      'شامل کرنے کے لیے کوئی رابطے دستیاب نہیں ہیں۔';

  @override
  String get chatAddMembers => 'ممبرز کو شامل کریں۔';

  @override
  String chatInvitedMembers(int count) {
    return '$count اراکین کو مدعو کیا گیا۔';
  }

  @override
  String chatInviteFailed(String error) {
    return 'دعوت ناکام ہوئی: $error';
  }

  @override
  String get chatMemberRemoved => 'ممبر کو ہٹا دیا گیا۔';

  @override
  String chatRemoveFailed(String error) {
    return 'ہٹانے میں ناکام: $error';
  }

  @override
  String get chatRealTimeLocationShareMessage =>
      'اشتراک کرنے کے بعد، دوسرا فریق 1 گھنٹے کے لیے آپ کا حقیقی وقت کا مقام دیکھ سکتا ہے۔';

  @override
  String get chatStartSharing => 'شیئرنگ شروع کریں۔';

  @override
  String get chatLocationServiceNotEnabled => 'مقام کی خدمت فعال نہیں ہے۔';

  @override
  String get chatEnableLocationService =>
      'اس خصوصیت کو استعمال کرنے کے لیے براہ کرم لوکیشن سروس کو فعال کریں۔';

  @override
  String get chatGoToSettings => 'ترتیبات پر جائیں۔';

  @override
  String get chatLocationPermissionRequired =>
      'اس خصوصیت کے لیے مقام کی اجازت درکار ہے۔';

  @override
  String get chatLocationPermissionDeniedPermanent =>
      'مقام کی اجازت مستقل طور پر مسترد کر دی گئی ہے۔ براہ کرم اسے ترتیبات میں فعال کریں۔';

  @override
  String get chatLocationPermissionDenied => 'مقام کی اجازت مسترد کر دی گئی۔';

  @override
  String get chatGettingLocation => 'مقام حاصل کر رہا ہے...';

  @override
  String chatGetLocationFailed(String error) {
    return 'مقام حاصل کرنے میں ناکام: $error';
  }

  @override
  String get chatMapPreview => 'نقشہ کا پیش نظارہ';

  @override
  String get chatSearchLocation => 'مقام تلاش کریں۔';

  @override
  String chatRedPacketSent(String amount, String token) {
    return '$amount $token سرخ پیکٹ بھیجا گیا۔';
  }

  @override
  String get chatTransferDefault => 'منتقلی';

  @override
  String chatTransferSent(String amount, String token) {
    return '$amount $token ٹرانسفر بھیجا گیا۔';
  }

  @override
  String chatPickFileFailed(String error) {
    return 'فائل لینے میں ناکام: $error';
  }

  @override
  String get chatFileSizeLimit => 'فائل کا سائز 50MB سے زیادہ نہیں ہو سکتا';

  @override
  String chatFileSending(String filename) {
    return 'فائل بھیجی جا رہی ہے: $filename';
  }

  @override
  String chatSendFileFailed(String error) {
    return 'فائل بھیجنے میں ناکام: $error';
  }

  @override
  String chatContactCardSent(String name) {
    return '$name کا رابطہ کارڈ بھیجا گیا۔';
  }

  @override
  String get chatFavoritesFeature => 'پسندیدہ';

  @override
  String get chatCouponsFeature => 'کوپن';

  @override
  String get chatGiftFeature => 'تحفہ';

  @override
  String chatSharedMusic(String name) {
    return 'مشترکہ $name';
  }

  @override
  String get chatEndPollTitle => 'پول ختم کریں۔';

  @override
  String get chatEndPollConfirmMessage =>
      'کیا آپ واقعی اس پول کو ختم کرنا چاہتے ہیں؟ ووٹنگ ختم ہونے کے بعد بند کر دی جائے گی۔';

  @override
  String get chatPollEndedMessage => 'پول ختم ہو گیا۔';

  @override
  String get chatConnectingCall => 'منسلک ہو رہا ہے...';

  @override
  String get chatMuteCall => 'خاموش';

  @override
  String get chatSpeakerOff => 'اسپیکر آف';

  @override
  String get chatSpeakerOn => 'سپیکر';

  @override
  String get chatCameraOn => 'کیمرہ آن';

  @override
  String get chatCameraOff => 'کیمرہ آف';

  @override
  String get chatHangUp => 'ہینگ اپ';

  @override
  String get chatSelectForwardTargetTitle => 'فارورڈ ٹارگٹ کو منتخب کریں۔';

  @override
  String get chatNoForwardableChat =>
      'فارورڈنگ کے لیے کوئی چیٹس دستیاب نہیں ہیں۔';

  @override
  String get chatNoMatchingChat => 'کوئی مماثل چیٹس نہیں ملے';

  @override
  String get chatLocationTitle => 'مقام';

  @override
  String get chatSendButton => 'بھیجیں۔';

  @override
  String get chatRetryButton => 'دوبارہ کوشش کریں۔';

  @override
  String get chatSearchContactHint => 'رابطے تلاش کریں۔';

  @override
  String get chatShareMusic => 'موسیقی کا اشتراک کریں۔';

  @override
  String get chatRecentPlayed => 'حالیہ';

  @override
  String get chatMyFavorites => 'پسندیدہ';

  @override
  String get chatNetworkLink => 'لنک';

  @override
  String get chatLocalFile => 'مقامی';

  @override
  String get chatPasteMusicLink => 'میوزک لنک پیسٹ کریں۔';

  @override
  String get chatShareMusicButton => 'موسیقی کا اشتراک کریں۔';

  @override
  String get chatSelectLocalAudio => 'مقامی آڈیو فائل کو منتخب کریں۔';

  @override
  String get chatSupportedAudioFormats =>
      'MP3، M4A، WAV، FLAC، وغیرہ کو سپورٹ کرتا ہے۔';

  @override
  String get chatSelectFileButton => 'فائل کو منتخب کریں۔';

  @override
  String get chatPleaseEnterMusicLink => 'براہ کرم موسیقی کا لنک درج کریں۔';

  @override
  String get chatPleaseEnterValidLink => 'براہ کرم ایک درست URL درج کریں۔';

  @override
  String get chatSharedSong => 'مشترکہ گانا';

  @override
  String get chatSelectMember => 'ممبر منتخب کریں۔';

  @override
  String get chatSearchMemberHint => 'اراکین کو تلاش کریں۔';

  @override
  String get chatNoMatchingMembers => 'کوئی مماثل اراکین نہیں ملے';

  @override
  String get commonUnknownMember => 'نامعلوم';

  @override
  String chatSelectedMessagesCount(int count) {
    return 'منتخب کردہ $count پیغامات';
  }

  @override
  String get chatSearchContactsOrGroups => 'رابطے یا گروپس تلاش کریں۔';

  @override
  String get chatVideoTitle => 'ویڈیو';

  @override
  String get chatLoadingText => 'لوڈ ہو رہا ہے...';

  @override
  String get chatVideoLoadFailed => 'ویڈیو لوڈ کرنا ناکام ہو گیا۔';

  @override
  String get chatPlayerInitFailed => 'پلیئر کی شروعات ناکام ہوگئی';

  @override
  String get chatCreatePollTitle => 'پول بنائیں';

  @override
  String get chatSubmitPoll => 'جمع کروائیں۔';

  @override
  String get chatPollQuestionLabel => 'رائے شماری کا سوال';

  @override
  String get chatEnterPollQuestionHint => 'براہ کرم پول سوال درج کریں۔';

  @override
  String get chatPollOptionsLabel => 'پول کے اختیارات';

  @override
  String chatOptionHintWithIndex(int index) {
    return 'آپشن $index';
  }

  @override
  String get chatAddOptionButton => 'آپشن شامل کریں۔';

  @override
  String get chatPollSettingsLabel => 'پول سیٹنگز';

  @override
  String get chatSelectionType => 'انتخاب کی قسم';

  @override
  String get chatSingleChoiceLabel => 'سنگل';

  @override
  String get chatMultiChoiceLabel => 'کثیر';

  @override
  String get chatAnonymousPollSwitch => 'گمنام پول';

  @override
  String get chatPleaseEnterQuestion => 'براہ کرم پول سوال درج کریں۔';

  @override
  String get chatAtLeastTwoOptions => 'کم از کم 2 اختیارات درکار ہیں۔';

  @override
  String chatConfirmWithCount(int count) {
    return 'تصدیق کریں ($count)';
  }

  @override
  String get authEmailVerificationTitle => 'ای میل کی توثیق';

  @override
  String get authEnterValidEmailAddress =>
      'براہ کرم ایک درست ای میل ایڈریس درج کریں۔';

  @override
  String authVerificationCodeSentTo(String email) {
    return 'توثیقی کوڈ $email پر بھیجا گیا۔';
  }

  @override
  String authSendCodeFailed(String error) {
    return 'کوڈ بھیجنے میں ناکام: $error';
  }

  @override
  String get authVerificationSuccess => 'توثیق کامیاب';

  @override
  String get authVerificationFailed => 'تصدیق ناکام ہوگئی';

  @override
  String authVerificationCodeError(String error) {
    return 'توثیقی کوڈ کی خرابی: $error';
  }

  @override
  String get commonEnterVerificationCode => 'تصدیقی کوڈ درج کریں۔';

  @override
  String get authEnterYourEmail => 'ای میل درج کریں۔';

  @override
  String authWeSentCodeTo(String email) {
    return 'ہم نے 6 ہندسوں کا کوڈ بھیجا ہے۔\n$email';
  }

  @override
  String get authEnterEmailForCode =>
      'اپنا ای میل ایڈریس درج کریں، ہم تصدیقی کوڈ بھیجیں گے۔';

  @override
  String get commonSendVerificationCode => 'تصدیقی کوڈ بھیجیں۔';

  @override
  String get authResendVerificationCode => 'تصدیقی کوڈ دوبارہ بھیجیں۔';

  @override
  String authCanResendAfter(int seconds) {
    return '$seconds سیکنڈ کے بعد دوبارہ بھیجا جا سکتا ہے۔';
  }

  @override
  String get commonChangeEmail => 'ای میل تبدیل کریں۔';

  @override
  String get contactAddToContacts => 'رابطوں میں شامل کریں۔';

  @override
  String get contactAddingToContacts => 'شامل کیا جا رہا ہے...';

  @override
  String get contactAddedToContacts => 'رابطوں میں شامل کر دیا گیا۔';

  @override
  String contactAddFailedWithError(String error) {
    return 'شامل کرنا ناکام ہو گیا: $error';
  }

  @override
  String get contactAddPhone => 'فون شامل کریں۔';

  @override
  String get contactAddTag => 'ٹیگز شامل کریں۔';

  @override
  String get contactAddText => 'متن شامل کریں۔';

  @override
  String get contactAddPhoto => 'تصویر شامل کریں۔';

  @override
  String contactGroupCountLabel(int count) {
    return '$count گروپس';
  }

  @override
  String get contactAddedViaSearch => 'تلاش کے ذریعے شامل کیا گیا۔';

  @override
  String get contactAddTime => 'وقت شامل کریں۔';

  @override
  String get contactDoneButton => 'ہو گیا';

  @override
  String get callWaitingForParticipants =>
      'شرکاء کے شامل ہونے کا انتظار کر رہا ہے...';

  @override
  String callParticipantMe(String name) {
    return '$name (میں)';
  }

  @override
  String get callSharingLabel => 'شیئرنگ';

  @override
  String callScreenSharingBy(String name) {
    return '$name اسکرین کا اشتراک کر رہا ہے۔';
  }

  @override
  String callParticipantCount(int count) {
    return '$count شرکاء';
  }

  @override
  String get callMuteLabel => 'خاموش';

  @override
  String get callUnmuteLabel => 'چالو کریں۔';

  @override
  String get callTurnOffVideo => 'ویڈیو بند کر دیں۔';

  @override
  String get callTurnOnVideo => 'ویڈیو آن کریں۔';

  @override
  String get callShareScreen => 'اسکرین شیئر کریں۔';

  @override
  String get callStopSharing => 'شیئر کرنا بند کرو';

  @override
  String get callSwitchCameraLabel => 'سوئچ کریں۔';

  @override
  String get callLeaveLabel => 'چھوڑو';

  @override
  String get callParticipantsLabel => 'شرکاء';

  @override
  String get callJoiningMeeting => 'میٹنگ میں شامل ہو رہا ہے...';

  @override
  String chatPollVotesFormat(int count, String percentage) {
    return '$count ووٹ ($percentage%)';
  }

  @override
  String chatPollParticipantsFormat(int count) {
    return '$count شرکاء';
  }

  @override
  String get commonTapToRetry => 'دوبارہ کوشش کرنے کے لیے تھپتھپائیں۔';

  @override
  String get chatDefaultRedPacketGreeting => 'خوشحالی کے لیے نیک خواہشات';

  @override
  String get groupAllowOthersToSearchAndJoin =>
      'دوسروں کو تلاش کرنے اور شامل ہونے کی اجازت دیں۔';

  @override
  String get groupConfirmClearChatHistory =>
      'کیا آپ واقعی چیٹ کی سرگزشت صاف کرنا چاہتے ہیں؟';

  @override
  String get groupCreateGroupToChat => 'چیٹنگ شروع کرنے کے لیے ایک گروپ بنائیں';

  @override
  String get groupEditGroupAnnouncement => 'گروپ کے اعلان میں ترمیم کریں۔';

  @override
  String get groupEditGroupDescription => 'گروپ کی تفصیل میں ترمیم کریں۔';

  @override
  String get groupEnterGroupAnnouncement => 'گروپ کا اعلان درج کریں۔';

  @override
  String chatErrorWithMessage(String message) {
    return 'خرابی: $message';
  }

  @override
  String groupMemberCountClickToCopy(int count) {
    return '$count ممبران، گروپ آئی ڈی کاپی کرنے کے لیے کلک کریں۔';
  }

  @override
  String get chatMusicLinkLabel => 'میوزک لنک';

  @override
  String get chatNoMediaUrlAvailable => 'کوئی میڈیا URL دستیاب نہیں ہے۔';

  @override
  String get groupNoPermissionToEditGroupName =>
      'آپ کو گروپ کے نام میں ترمیم کرنے کی اجازت نہیں ہے۔';

  @override
  String get chatRedPacketTransferCannotForward =>
      'ریڈ پیکٹ اور ٹرانسفر فارورڈ نہیں کیے جا سکتے';

  @override
  String get authEmailAddress => 'ای میل ایڈریس';

  @override
  String get commonEnterEmailAddress => 'ای میل ایڈریس درج کریں۔';

  @override
  String get authEmailRecoveryHint =>
      'پاس ورڈ کی بازیابی کے لیے استعمال کیا جاتا ہے۔';

  @override
  String get commonInvalidEmailFormat =>
      'براہ کرم ایک درست ای میل ایڈریس درج کریں۔';

  @override
  String get authOptional => 'اختیاری';

  @override
  String get authResetPassword => 'پاس ورڈ ری سیٹ کریں۔';

  @override
  String get authEnterRegisteredEmail =>
      'ای میل ایڈریس درج کریں جس کے ساتھ آپ رجسٹرڈ ہیں۔';

  @override
  String get authSendResetCode => 'ری سیٹ کوڈ بھیجیں۔';

  @override
  String authResetCodeSent(String email) {
    return '$email پر بھیجے گئے کوڈ کو دوبارہ ترتیب دیں۔';
  }

  @override
  String get authEnterResetCode => 'ری سیٹ کوڈ درج کریں۔';

  @override
  String get authSetNewPassword => 'نیا پاس ورڈ سیٹ کریں۔';

  @override
  String get commonConfirmNewPassword => 'نئے پاس ورڈ کی تصدیق کریں۔';

  @override
  String get commonNewPassword => 'نیا پاس ورڈ';

  @override
  String get authPasswordResetSuccess =>
      'پاس ورڈ ری سیٹ کامیاب ہو گیا۔ براہ کرم اپنے نئے پاس ورڈ کے ساتھ لاگ ان کریں۔';

  @override
  String get authResetPasswordFailed => 'پاس ورڈ دوبارہ ترتیب دینے میں ناکام';

  @override
  String get settingsChangePassword => 'پاس ورڈ تبدیل کریں۔';

  @override
  String get settingsCurrentPassword => 'موجودہ پاس ورڈ';

  @override
  String get settingsEnterCurrentPassword => 'موجودہ پاس ورڈ درج کریں۔';

  @override
  String get settingsEnterNewPassword => 'نیا پاس ورڈ درج کریں۔';

  @override
  String get settingsPasswordChanged =>
      'پاس ورڈ کامیابی سے تبدیل ہو گیا۔ براہ کرم اپنے نئے پاس ورڈ کے ساتھ لاگ ان کریں۔';

  @override
  String get settingsChangePasswordFailed => 'پاس ورڈ تبدیل کرنا ناکام ہو گیا۔';

  @override
  String get settingsNewPasswordMustBeDifferent =>
      'نیا پاس ورڈ موجودہ پاس ورڈ سے مختلف ہونا چاہیے۔';

  @override
  String get settingsChangePasswordInfo =>
      'پاس ورڈ تبدیل کرنے کے بعد، آپ لاگ آؤٹ ہو جائیں گے اور آپ کو نئے پاس ورڈ کے ساتھ لاگ ان کرنے کی ضرورت ہوگی۔';

  @override
  String get settingsPasswordRequirements => 'پاس ورڈ کی ضروریات:';

  @override
  String get settingsSecurityNote =>
      'سیکیورٹی کے لیے، آپ کو پاس ورڈ تبدیل کرنے کے بعد تمام ڈیوائسز پر دوبارہ لاگ ان کرنے کی ضرورت ہوگی۔';

  @override
  String get settingsSecurity => 'سیکورٹی';

  @override
  String get settingsCurrentBoundEmail => 'موجودہ پابند ای میل';

  @override
  String get settingsNewEmailAddress => 'نیا ای میل ایڈریس';

  @override
  String get settingsEnterNewEmail => 'نیا ای میل ایڈریس درج کریں۔';

  @override
  String get settingsVerificationCode => 'تصدیقی کوڈ';

  @override
  String get settingsVerificationCodeSent => 'تصدیقی کوڈ بھیجا گیا۔';

  @override
  String get settingsCodeSentTo => 'تصدیقی کوڈ بھیج دیا گیا۔';

  @override
  String get settingsDidNotReceiveCode => 'کوڈ موصول نہیں ہوا؟';

  @override
  String get settingsEmailChangedSuccess =>
      'ای میل کامیابی کے ساتھ تبدیل ہوگئی';

  @override
  String get settingsChangeEmailFailed => 'ای میل تبدیل کرنا ناکام ہو گیا۔';

  @override
  String get settingsEmailSecurityNote =>
      'آپ کا ای میل پاس ورڈ کی بازیابی کے لیے استعمال کیا جاتا ہے۔ براہ کرم اسے محفوظ رکھیں۔';

  @override
  String get commonGoogleLogin => 'گوگل کے ساتھ سائن ان کریں۔';

  @override
  String get commonAppleLogin => 'ایپل کے ساتھ سائن ان کریں۔';

  @override
  String get commonWechat => 'WeChat';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsLanguageChanged => 'زبان بدل گئی۔';

  @override
  String get settingsTranslation => 'ترجمہ';

  @override
  String get settingsTranslateTextTo => 'متن کا ترجمہ کریں۔';

  @override
  String get settingsTranslateDescription =>
      'وہ زبان منتخب کریں جس میں آپ پیغامات کا ترجمہ کرنا چاہتے ہیں۔';

  @override
  String get settingsAutoTranslate => 'موصولہ پیغامات کا خودکار ترجمہ کریں۔';

  @override
  String get settingsAutoTranslateDescription =>
      'چیٹ میں موصول ہونے والے پیغامات کو اپنی منتخب زبان میں خودکار طور پر ترجمہ کریں۔';

  @override
  String get settingsBiometricLogin => 'بائیو میٹرک لاگ ان';

  @override
  String authLoginWithBiometric(Object type) {
    return '$type کے ساتھ لاگ ان کریں۔';
  }

  @override
  String get settingsBiometricLoginEnabled => 'بایومیٹرک لاگ ان فعال ہے۔';

  @override
  String get settingsBiometricLoginDisabled =>
      'بائیو میٹرک لاگ ان غیر فعال ہے۔';

  @override
  String get settingsEnableBiometricLogin => 'بائیو میٹرک لاگ ان کو فعال کریں۔';

  @override
  String get settingsBiometricEnabled =>
      'فعال - لاگ ان کرنے کے لیے بائیو میٹرک استعمال کریں۔';

  @override
  String get settingsBiometricDisabled =>
      'غیر فعال - فعال کرنے کے لیے تھپتھپائیں۔';

  @override
  String get settingsBiometricNeedRelogin =>
      'براہ کرم لاگ آؤٹ کریں اور بائیو میٹرک لاگ ان کو فعال کرنے کے لیے دوبارہ لاگ ان کریں۔';

  @override
  String get authOr => 'یا';

  @override
  String get qrcodeCameraPermissionRestricted =>
      'اس آلہ پر کیمرے تک رسائی محدود ہے۔';

  @override
  String get authPasskeyLabel => 'پاسکی';

  @override
  String get authGoogleLabel => 'گوگل';

  @override
  String get authAppleLabel => 'ایپل';


  @override
  String get authSsoNotConfigured => 'اس سرور نے SSO لاگ ان فراہم کنندگان کو ترتیب نہیں دیا ہے';
  @override
  String get authSsoLabel => 'ایس ایس او';

  @override
  String get transferAmountHintZero => '0.00';

  @override
  String get commonMatrixIdHint => '@username:server.com';

  @override
  String get authServerAddressHint => 'https://m.si46.world';

  @override
  String get authEmailExampleHint => 'example@email.com';

  @override
  String get authVerificationCodePlaceholder => '------';

  @override
  String get profileEnterPokeSuffixHint => 'پوک لاحقہ درج کریں، جیسے: کندھے پر';

  @override
  String get groupAlbum => 'گروپ البم';

  @override
  String get groupFiles => 'گروپ فائلز';

  @override
  String get groupImages => 'امیجز';

  @override
  String get groupVideos => 'ویڈیوز';

  @override
  String get groupTotal => 'کل';

  @override
  String get groupSize => 'سائز';

  @override
  String get groupNoMedia => 'کوئی میڈیا نہیں۔';

  @override
  String get groupNoMediaDescription =>
      'اس گروپ میں ابھی تک کوئی تصویر یا ویڈیو نہیں ہے۔';

  @override
  String get groupDocuments => 'دستاویزات';

  @override
  String get groupNoFiles => 'کوئی فائل نہیں';

  @override
  String get groupNoFilesDescription =>
      'اس گروپ میں ابھی تک کوئی فائل نہیں ہے۔';

  @override
  String groupDownloadStarted(String filename) {
    return '$filename ڈاؤن لوڈ ہو رہا ہے...';
  }

  @override
  String get contactNoCommonGroups => 'کوئی مشترکہ گروپ نہیں۔';

  @override
  String get contactNoCommonGroupsDescription =>
      'آپ کا کوئی گروپ مشترک نہیں ہے۔';

  @override
  String get chatVoiceMessage => 'آواز';

  @override
  String get chatMessage => 'پیغام';

  @override
  String get conversationHideChat => 'چھپائیں';

  @override
  String get settingsQuickReply => 'فوری جواب';

  @override
  String get commonTranslate => 'ترجمہ کریں۔';

  @override
  String get contactCreateTag => 'ٹیگ بنائیں';

  @override
  String get contactEnterTagName => 'ٹیگ کا نام درج کریں۔';

  @override
  String get contactEditTag => 'ٹیگ میں ترمیم کریں۔';

  @override
  String get contactDeleteTag => 'ٹیگ کو حذف کریں۔';

  @override
  String contactDeleteTagConfirm(String tagName) {
    return 'کیا آپ واقعی ٹیگ \"$tagName\" کو حذف کرنا چاہتے ہیں؟';
  }

  @override
  String get contactNoTags => 'ابھی تک کوئی ٹیگ نہیں ہیں۔';

  @override
  String get contactFriendPermissions => 'دوست کی اجازت';

  @override
  String get contactSetChatOnly => 'صرف چیٹ کے طور پر سیٹ کریں۔';

  @override
  String get contactChatOnlyDesc =>
      'صرف آپ کے ساتھ چیٹ کر سکتے ہیں، دیگر مواد کو چھپایا جائے گا۔';

  @override
  String get contactHideMyMoments => 'میرے لمحات کو چھپائیں۔';

  @override
  String get contactHideMyMomentsDesc => 'یہ دوست میرے لمحات نہیں دیکھ سکتا';

  @override
  String get contactHideTheirMoments => 'ان کے لمحات کو چھپائیں۔';

  @override
  String get contactHideTheirMomentsDesc => 'اس دوست کے لمحات نہ دیکھیں';

  @override
  String get contactHideMyStatus => 'میری حیثیت کو چھپائیں۔';

  @override
  String get contactHideMyStatusDesc =>
      'یہ دوست میری سٹیٹس اپ ڈیٹس نہیں دیکھ سکتا';

  @override
  String get contactNoChatOnlyFriends => 'کوئی چیٹ صرف دوست نہیں۔';

  @override
  String get contactNoOfficialAccounts => 'کوئی سرکاری اکاؤنٹس نہیں۔';

  @override
  String get contactFollowOfficialAccountsDesc =>
      'تازہ ترین اپ ڈیٹس حاصل کرنے کے لیے آفیشل اکاؤنٹس پر عمل کریں۔';

  @override
  String get contactNoServiceAccounts => 'کوئی سروس اکاؤنٹس نہیں۔';

  @override
  String get contactSubscribeServiceAccountsDesc =>
      'آسان خدمات کے لیے سروس اکاؤنٹس کو سبسکرائب کریں۔';

  @override
  String get contactNoEnterpriseContacts => 'کوئی انٹرپرائز رابطے نہیں ہیں۔';

  @override
  String get contactEnterpriseContactsDesc =>
      'انٹرپرائز کے رابطے یہاں دکھائے جائیں گے۔';

  @override
  String get profileCardPack => 'کارڈ پیک';

  @override
  String get profileOrders => 'احکامات';

  @override
  String get profileNoOrders => 'کوئی حکم نہیں۔';

  @override
  String get profileOrdersDesc => 'آپ کے آرڈرز یہاں دکھائے جائیں گے۔';

  @override
  String get profileNoCards => 'کوئی کارڈ نہیں';

  @override
  String get profileCardsDesc => 'آپ کے کارڈ یہاں دکھائے جائیں گے۔';

  @override
  String get favoriteEnterTagsHint => 'کوما سے الگ کیے گئے ٹیگز درج کریں۔';

  @override
  String get favoriteTagsUpdated => 'ٹیگز اپ ڈیٹ ہو گئے۔';

  @override
  String get favoriteForwardedContent => 'مواد آگے بھیج دیا گیا۔';

  @override
  String get favoriteEnterNoteContent => 'نوٹ کا مواد درج کریں۔';

  @override
  String get favoriteNoteAdded => 'نوٹ شامل کیا گیا۔';

  @override
  String get favoriteLinkTitle => 'لنک ٹائٹل';

  @override
  String get favoriteLinkUrl => 'https://';

  @override
  String get favoriteLinkAdded => 'لنک شامل کر دیا گیا۔';

  @override
  String get contactPhotoAdded => 'تصویر شامل کی گئی۔';

  @override
  String get contactEnterPhone => 'فون نمبر درج کریں۔';

  @override
  String commonConversationWithId(String roomId) {
    return 'گفتگو: $roomId';
  }

  @override
  String commonContactWithId(String userId) {
    return 'رابطہ: $userId';
  }

  @override
  String get commonDiscover => 'دریافت کریں۔';

  @override
  String commonDeveloping(String title) {
    return '$title\n(جلد آرہا ہے)';
  }

  @override
  String get commonPageNotFound => 'صفحہ نہیں ملا';

  @override
  String get commonBackToHome => 'واپس گھر پر';

  @override
  String get settingsMessageNotifications => 'پیغامات کی اطلاعات';

  @override
  String get settingsReceiveNewMessageNotifications =>
      'نئے پیغامات کی اطلاعات موصول کریں۔';

  @override
  String get settingsShowMessagePreview => 'پیغام کا پیش نظارہ دکھائیں۔';

  @override
  String get settingsShowMessageContentInNotification =>
      'اطلاع میں پیغام کا مواد دکھائیں۔';

  @override
  String get settingsNotificationSound => 'اطلاع کی آواز';

  @override
  String get settingsPlaySoundOnMessage => 'پیغامات موصول ہونے پر آواز چلائیں۔';

  @override
  String get commonVibration => 'کمپن';

  @override
  String get settingsVibrateOnMessage => 'پیغامات موصول ہونے پر وائبریٹ کریں۔';

  @override
  String get settingsDoNotDisturbMode => 'ڈسٹرب نہ کریں۔';

  @override
  String get settingsDoNotDisturbDescription =>
      'مخصوص وقت کے دوران اطلاعات موصول نہ کریں۔';

  @override
  String get settingsStartTime => 'آغاز کا وقت';

  @override
  String get settingsEndTime => 'اختتامی وقت';

  @override
  String get settingsDeleteQuickReply => 'فوری جواب کو حذف کریں۔';

  @override
  String get settingsEditQuickReply => 'فوری جواب میں ترمیم کریں۔';

  @override
  String get settingsAddQuickReply => 'فوری جواب شامل کریں۔';

  @override
  String get settingsManageQuickReplies => 'فوری جوابات کا نظم کریں۔';

  @override
  String get settingsNoQuickReplies => 'کوئی فوری جواب نہیں۔';

  @override
  String get settingsDefaultQuickReplies =>
      'پہلے سے طے شدہ فوری جوابات دکھائے جائیں گے۔';

  @override
  String get settingsWhoCanSee => 'کون دیکھ سکتا ہے۔';

  @override
  String get settingsLastSeen => 'آخری بار دیکھا';

  @override
  String get settingsHiddenChats => 'پوشیدہ چیٹس';

  @override
  String get settingsMessagesLabel => 'پیغامات';

  @override
  String get settingsAllowStrangerMessages => 'اجنبی پیغامات کی اجازت دیں۔';

  @override
  String get settingsReceiveMessagesFromNonContacts =>
      'غیر رابطوں سے پیغامات وصول کریں۔';

  @override
  String get settingsReadReceipts => 'رسیدیں پڑھیں';

  @override
  String get settingsLetOthersKnowYouRead =>
      'دوسروں کو بتائیں کہ آپ پڑھ رہے ہیں۔';

  @override
  String get settingsTypingIndicator => 'ٹائپنگ اشارے';

  @override
  String get settingsLetOthersKnowYouTyping =>
      'دوسروں کو بتائیں کہ آپ ٹائپ کر رہے ہیں۔';

  @override
  String get settingsEveryone => 'ہر کوئی';

  @override
  String get settingsContactsOnly => 'صرف رابطے';

  @override
  String get settingsNobody => 'کوئی نہیں۔';

  @override
  String settingsWhoCanSeeTitle(String title) {
    return 'کون $title دیکھ سکتا ہے۔';
  }

  @override
  String settingsVersionInfo(String version) {
    return 'ورژن $version';
  }

  @override
  String get settingsCheckForUpdates => 'اپ ڈیٹس کے لیے چیک کریں۔';

  @override
  String get settingsOpenSourceLicenses => 'اوپن سورس لائسنس';

  @override
  String get settingsFeedbackAndSuggestions => 'آراء اور تجاویز';

  @override
  String get settingsBuiltOnMatrix => 'میٹرکس پروٹوکول پر بنایا گیا ہے۔';

  @override
  String get settingsNoHiddenChats => 'کوئی پوشیدہ چیٹس نہیں۔';

  @override
  String get settingsNoHiddenChatsDescription =>
      'آپ کی چھپائی گئی چیٹس یہاں ظاہر ہوں گی۔';

  @override
  String get settingsUnhideChat => 'چھپائیں';

  @override
  String get settingsDarkMode => 'ڈارک موڈ';

  @override
  String get settingsFontSize => 'فونٹ کا سائز';

  @override
  String get settingsBubbleStyle => 'بلبلا انداز';

  @override
  String get settingsFollowSystem => 'سسٹم پر عمل کریں۔';

  @override
  String get settingsAutoSwitchBySystem => 'سسٹم کے ذریعہ آٹو سوئچ';

  @override
  String get settingsLightMode => 'لائٹ موڈ';

  @override
  String get settingsAlwaysUseLightTheme => 'ہمیشہ ہلکی تھیم استعمال کریں۔';

  @override
  String get settingsDarkModeOption => 'ڈارک موڈ آپشن';

  @override
  String get settingsAlwaysUseDarkTheme => 'ہمیشہ ڈارک تھیم استعمال کریں۔';

  @override
  String get settingsFontSizeSmall => 'چھوٹا';

  @override
  String get settingsFontSizeStandard => 'معیاری';

  @override
  String get settingsFontSizeLarge => 'بڑا';

  @override
  String get settingsFontSizeExtraLarge => 'اضافی بڑا';

  @override
  String get settingsBubbleStyleWechat => 'WeChat اسٹائل';

  @override
  String get settingsBubbleStyleWechatDesc => 'کلاسک WeChat ببل اسٹائل';

  @override
  String get settingsBubbleStyleModern => 'جدید انداز';

  @override
  String get settingsBubbleStyleModernDesc => 'صاف جدید بلبلا سٹائل';

  @override
  String get settingsBubbleStyleClassic => 'کلاسیکی انداز';

  @override
  String get settingsBubbleStyleClassicDesc => 'روایتی بلبلا انداز';

  @override
  String get discoverVideoChannels => 'چینلز';

  @override
  String get discoverLive => 'جیو';

  @override
  String get discoverListen => 'سنو';

  @override
  String get discoverWatch => 'دیکھو';

  @override
  String get discoverSearchDiscover => 'تلاش کریں۔';

  @override
  String get discoverNearbyPeople => 'آس پاس';

  @override
  String get discoverGames => 'گیمز';

  @override
  String get discoverMiniPrograms => 'چھوٹے پروگرام';

  @override
  String get chatAlreadyInCall => 'پہلے ہی کال میں ہے۔';

  @override
  String get commonConnectionFailed => 'کنکشن ناکام ہو گیا۔';

  @override
  String get chatCallRejected => 'کال مسترد کر دی گئی۔';

  @override
  String get chatNoAnswer => 'کوئی جواب نہیں۔';

  @override
  String get commonClose => 'بند';

  @override
  String get chatSelectContact => 'رابطہ منتخب کریں۔';

  @override
  String get chatVoteRemoved => 'ووٹ ہٹا دیا گیا۔';

  @override
  String get chatVoteChanged => 'ووٹ بدل گیا۔';

  @override
  String get chatVoted => 'ووٹ دیا۔';

  @override
  String chatReplyTo(String name) {
    return '$name کا جواب دیں۔';
  }

  @override
  String get chatCurrentLocation => 'موجودہ مقام';

  @override
  String chatNearbyPlace(int index) {
    return 'قریبی جگہ $index';
  }

  @override
  String chatApproximateDistance(String distance) {
    return '$distance کے بارے میں';
  }

  @override
  String get chatAddress => 'پتہ';

  @override
  String get chatLatitude => 'عرض بلد';

  @override
  String get chatLongitude => 'طول البلد';

  @override
  String get groupDescriptionUpdated => 'گروپ کی تفصیل اپ ڈیٹ کر دی گئی۔';

  @override
  String get groupAvatarUpdated => 'گروپ اوتار اپ ڈیٹ ہو گیا۔';

  @override
  String get groupVisibilityUpdated => 'گروپ کی مرئیت کو اپ ڈیٹ کر دیا گیا۔';

  @override
  String get groupChannelCreated => 'چینل بنایا';

  @override
  String get groupChannelUpdated => 'چینل اپ ڈیٹ ہو گیا۔';

  @override
  String get groupChannelDeleted => 'چینل حذف کر دیا گیا۔';

  @override
  String get callDecline => 'رد کرنا';

  @override
  String get callAnswer => 'جواب دیں۔';

  @override
  String get callIncomingVideoCall => 'آنے والی ویڈیو کال';

  @override
  String get callIncomingVoiceCall => 'آنے والی صوتی کال';

  @override
  String get callVideoCallInProgress => 'ویڈیو کال جاری ہے۔';

  @override
  String get callVoiceCallInProgress => 'وائس کال جاری ہے۔';

  @override
  String get callReconnectingCall => 'دوبارہ منسلک ہو رہا ہے...';

  @override
  String get callEnded => 'کال ختم ہو گئی۔';

  @override
  String get callFailed => 'کال ناکام ہوگئی';

  @override
  String get callLivekitNotConfigured => 'LiveKit کنفیگر نہیں ہے۔';

  @override
  String callJoinMeetingFailed(String error) {
    return 'میٹنگ میں شامل ہونے میں ناکام: $error';
  }

  @override
  String callScreenShareFailed(String error) {
    return 'اسکرین کا اشتراک ناکام: $error';
  }

  @override
  String get profileN42BeanTitle => 'N42 بین';

  @override
  String get profileNoN42Bean => 'کوئی N42 بین';

  @override
  String get profileN42BeanDetails => 'N42 بین کی تفصیلات';

  @override
  String get profileN42BeanDescription =>
      'N42 Bean ایک ٹوکن ہے جو N42 میں ورچوئل آئٹمز اور خدمات کو چھڑانے کے لیے استعمال ہوتا ہے۔ فی الحال دستیاب ہے:';

  @override
  String get profileN42BeanFeature1 => 'خصوصی ممبر اسٹیکرز اور تھیمز';

  @override
  String get profileN42BeanFeature2 => 'چیٹ ببل حسب ضرورت';

  @override
  String get profileN42BeanFeature3 => 'ریڈ پیکٹ کور حسب ضرورت';

  @override
  String get profileN42BeanFeature4 => 'خصوصی عرفی بیج';

  @override
  String get profileN42BeanFeature5 => 'گروپ چیٹ کی مراعات';

  @override
  String get profileN42BeanFeature6 => 'کلاؤڈ اسٹوریج کی توسیع';

  @override
  String get profileN42BeanFeature7 => 'ویڈیو کال بیوٹی فلٹرز';

  @override
  String get profileN42BeanFeature8 => 'لمحات کے پس منظر کی تخصیص';

  @override
  String get profileN42BeanFeature9 => 'VIP کسٹمر سروس کی ترجیح';

  @override
  String get profileGotIt => 'سمجھ گیا';

  @override
  String get profileNoN42BeanRecords => 'کوئی N42 بین ریکارڈ نہیں ہے۔';

  @override
  String get profileMoodAndThoughts => 'مزاج اور خیالات';

  @override
  String get profileStatusHappy => 'خوش';

  @override
  String get profileStatusCracked => 'بکھر گیا۔';

  @override
  String get profileStatusLucky => 'لکی';

  @override
  String get profileStatusSunny => 'دھوپ';

  @override
  String get profileStatusTired => 'تھکا ہوا';

  @override
  String get profileStatusDaydream => 'دن کا خواب';

  @override
  String get profileStatusRushing => 'جلدی کرنا';

  @override
  String get profileStatusOverthinking => 'زیادہ سوچنا';

  @override
  String get profileStatusEnergized => 'متحرک';

  @override
  String get profileWorkAndStudy => 'کام اور مطالعہ';

  @override
  String get profileStatusWorking => 'کام کرنا';

  @override
  String get profileStatusStudying => 'پڑھائی';

  @override
  String get profileStatusBusy => 'مصروف';

  @override
  String get profileStatusSlacking => 'ڈھیلا ڈھالا';

  @override
  String get profileStatusTraveling => 'سفر کرنا';

  @override
  String get profileStatusGoingHome => 'گھر جا رہے ہیں۔';

  @override
  String get profileStatusDnd => 'ڈسٹرب نہ کریں۔';

  @override
  String get profileActivities => 'سرگرمیاں';

  @override
  String get profileStatusHanging => 'ہینگ آؤٹ';

  @override
  String get profileStatusCheckIn => 'چیک ان';

  @override
  String get profileStatusExercising => 'ورزش کرنا';

  @override
  String get profileStatusCoffee => 'کافی';

  @override
  String get profileStatusBubbleTea => 'ببل ٹی';

  @override
  String get profileStatusEating => 'کھانا';

  @override
  String get profileStatusParenting => 'پرورش';

  @override
  String get profileStatusSavingWorld => 'سیونگ ورلڈ';

  @override
  String get profileStatusSelfie => 'سیلفی';

  @override
  String get profileRest => 'آرام کریں۔';

  @override
  String get profileStatusRetreat => 'پیچھے ہٹنا';

  @override
  String get profileStatusHome => 'گھر';

  @override
  String get profileStatusSleeping => 'سو رہا ہے۔';

  @override
  String get profileStatusCatLover => 'بلی سے محبت کرنے والا';

  @override
  String get profileStatusDogWalking => 'چلنے والا کتا';

  @override
  String get profileStatusGaming => 'گیمنگ';

  @override
  String get profileStatusListening => 'سن رہا ہے۔';

  @override
  String get profileEditAddress => 'ایڈریس میں ترمیم کریں۔';

  @override
  String get profileRecipient => 'وصول کنندہ';

  @override
  String get profileEnterRecipientName => 'وصول کنندہ کا نام درج کریں۔';

  @override
  String get profilePhoneNumber => 'فون نمبر';

  @override
  String get profileEnterPhoneNumber => 'فون نمبر درج کریں۔';

  @override
  String get profileRegionHint => 'صوبہ/شہر/ضلع';

  @override
  String get profileDetailedAddress => 'تفصیلی پتہ';

  @override
  String get profileDetailedAddressHint => 'گلی، عمارت نمبر، وغیرہ';

  @override
  String get profileSetAsDefaultAddress => 'ڈیفالٹ ایڈریس کے طور پر سیٹ کریں۔';

  @override
  String get profilePleaseCompleteInfo => 'براہ کرم تمام فیلڈز کو مکمل کریں۔';

  @override
  String get profileEditInvoice => 'انوائس میں ترمیم کریں۔';

  @override
  String get profileInvoiceType => 'انوائس کی قسم';

  @override
  String get profileCompanyName => 'کمپنی کا نام';

  @override
  String get profilePersonalName => 'ذاتی نام';

  @override
  String get profileEnterCompanyName => 'کمپنی کا نام درج کریں۔';

  @override
  String get profileEnterName => 'نام درج کریں۔';

  @override
  String get profileTaxIdNumber => 'ٹیکس آئی ڈی نمبر';

  @override
  String get profileEnterTaxIdNumber => 'ٹیکس ID نمبر درج کریں۔';

  @override
  String get profileBankNameOptional => 'بینک کا نام (اختیاری)';

  @override
  String get profileEnterBankName => 'بینک کا نام درج کریں۔';

  @override
  String get profileBankAccountOptional => 'بینک اکاؤنٹ (اختیاری)';

  @override
  String get profileEnterBankAccount => 'بینک اکاؤنٹ درج کریں۔';

  @override
  String get profileCompanyAddressOptional => 'کمپنی کا پتہ (اختیاری)';

  @override
  String get profileEnterCompanyAddress => 'کمپنی کا پتہ درج کریں۔';

  @override
  String get profileCompanyPhoneOptional => 'کمپنی کا فون (اختیاری)';

  @override
  String get profileEnterCompanyPhone => 'کمپنی کا فون درج کریں۔';

  @override
  String get profileSetAsDefaultInvoice => 'ڈیفالٹ انوائس کے بطور سیٹ کریں۔';

  @override
  String get profileRingtoneVibrate => 'کمپن';

  @override
  String get profileRingtoneSilent => 'خاموش';

  @override
  String get profileVibrateMode => 'وائبریٹ موڈ';

  @override
  String get profileSilentMode => 'خاموش موڈ';

  @override
  String profilePlayFailed(String ringtoneName) {
    return 'چلانے میں ناکام: $ringtoneName';
  }

  @override
  String profilePlaying(String ringtoneName) {
    return 'چل رہا ہے: $ringtoneName';
  }

  @override
  String get profileStop => 'رک جاؤ';

  @override
  String get profileSelectRingtone => 'رنگ ٹون منتخب کریں۔';

  @override
  String get profileLoadingRingtones => 'رنگ ٹونز لوڈ ہو رہا ہے...';

  @override
  String get profileNoRingtonesFound => 'کوئی رنگ ٹونز نہیں ملا';

  @override
  String mainMessagesWithCount(int count) {
    return 'پیغامات($count)';
  }

  @override
  String get storyViewers => 'ناظرین';

  @override
  String get storyNoViewers => 'ابھی تک کوئی ناظرین نہیں ہیں۔';

  @override
  String get storyReplyToStory => 'کہانی کا جواب دیں...';

  @override
  String get commonCopiedToClipboard => 'کلپ بورڈ پر کاپی ہو گیا۔';

  @override
  String get commonMore => 'مزید';

  @override
  String get commonTranslating => 'ترجمہ ہو رہا ہے...';

  @override
  String commonTranslatedFrom(String language) {
    return '$language سے ترجمہ شدہ';
  }

  @override
  String get commonTranslation => 'ترجمہ';

  @override
  String get commonTranslationFailed => 'ترجمہ ناکام ہو گیا۔';

  @override
  String get commonAllRead => 'سب نے پڑھا۔';

  @override
  String commonReadCount(int count) {
    return '$count پڑھا۔';
  }

  @override
  String get commonYouRecalledMessage => 'آپ کو ایک پیغام یاد آیا';

  @override
  String get commonMessageRecalled => 'پیغام یاد آیا';

  @override
  String get commonReEdit => 'دوبارہ ترمیم کریں۔';

  @override
  String get commonWalletArea => 'والیٹ ایریا';

  @override
  String get callIncomingCall => 'آنے والی کال';

  @override
  String get callMissedCall => 'مسڈ کال';

  @override
  String get groupRemoveAdmin => 'ایڈمن کو ہٹا دیں۔';

  @override
  String get chatSelectCurrency => 'کرنسی منتخب کریں۔';

  @override
  String get chatSelectEmoji => 'ایموجی منتخب کریں۔';

  @override
  String get chatSelectRedPacketCover => 'کور کو منتخب کریں۔';

  @override
  String get groupSetAsAdmin => 'ایڈمن کے طور پر سیٹ کریں۔';

  @override
  String get chatVideoPlaybackFailed => 'ویڈیو پلے بیک ناکام ہو گیا۔';

  @override
  String get groupViewProfile => 'پروفائل دیکھیں';

  @override
  String get favoriteAddLinkComingSoon =>
      'جلد آنے والی لنک کی خصوصیت شامل کریں۔';

  @override
  String get favoriteNewNoteComingSoon => 'نوٹ کی نئی خصوصیت جلد آرہی ہے۔';

  @override
  String get qrcodeSaveFeatureComingSoon => 'محفوظ کریں فیچر جلد آرہا ہے۔';

  @override
  String get qrcodeShareFeatureComingSoon => 'اشتراک کی خصوصیت جلد آرہی ہے۔';

  @override
  String qrcodeProcessFailed(String error) {
    return 'QR کوڈ پر کارروائی کرنے میں ناکام: $error';
  }

  @override
  String get securityDeviceIdRequired => 'ڈیوائس کی شناخت درکار ہے۔';

  @override
  String securityVerificationStartFailed(String error) {
    return 'توثیق شروع کرنے میں ناکام: $error';
  }

  @override
  String get securityVerificationFailed => 'تصدیق ناکام ہوگئی';

  @override
  String securityVerificationFailedWithReason(String reason) {
    return 'توثیق ناکام ہوگئی: $reason';
  }

  @override
  String get securityEmojiMismatchRejected =>
      'توثیق مسترد کر دی گئی - emoji مماثل نہیں ہے۔';

  @override
  String get securityWaitingForDeviceAccept =>
      'دوسرے آلہ کے قبول کرنے کا انتظار کر رہا ہے...';

  @override
  String get securityVerifyDevice => 'اس ڈیوائس کی تصدیق کریں۔';

  @override
  String get securityConfirmEmojiMatch =>
      'تصدیق کریں کہ نیچے دیے گئے ایموجی دونوں ڈیوائسز پر ایک ہی ترتیب میں دکھائے گئے ہیں۔';

  @override
  String get securityEmojiDontMatch => 'وہ میل نہیں کھاتے';

  @override
  String get securityEmojiMatch => 'وہ میچ کرتے ہیں۔';

  @override
  String get securityWaitingForDeviceConfirm =>
      'دوسرے آلے کی تصدیق کا انتظار کر رہا ہے...';

  @override
  String get securityVerificationSuccess => 'توثیق کامیاب!';

  @override
  String get securityDeviceVerifiedTrusted =>
      'یہ آلہ اب تصدیق شدہ اور قابل اعتماد ہے۔';

  @override
  String get securityCompareEmoji => 'دونوں آلات پر ایموجی کا موازنہ کریں۔';

  @override
  String get securityCompareNumbers => 'دونوں آلات پر نمبروں کا موازنہ کریں۔';

  @override
  String get commonTryAgain => 'دوبارہ کوشش کریں۔';

  @override
  String get commonDone => 'ہو گیا';

  @override
  String get chatExportTitle => 'چیٹ برآمد کریں۔';

  @override
  String get chatExportSuccess => 'ایکسپورٹ کامیاب';

  @override
  String chatExportFailed(String error) {
    return 'ایکسپورٹ ناکام ہو گیا: $error';
  }

  @override
  String get chatExportFormat => 'ایکسپورٹ فارمیٹ';

  @override
  String get chatExportHtmlDesc =>
      'اسٹائل شدہ ترتیب کے ساتھ کسی بھی براؤزر میں پڑھنے کے قابل';

  @override
  String get chatExportJsonDesc => 'مشین سے پڑھنے کے قابل ساختی ڈیٹا فارمیٹ';

  @override
  String get chatExportDateRange => 'تاریخ کی حد';

  @override
  String get chatExportAll => 'تمام پیغامات';

  @override
  String get chatExportLastWeek => 'آخری 7 دن';

  @override
  String get chatExportLastMonth => 'پچھلے مہینے';

  @override
  String get chatExportLast3Months => 'پچھلے 3 مہینے';

  @override
  String get chatExportMessageCount => 'برآمد کرنے کے لیے پیغامات';

  @override
  String get chatExportButton => 'ایکسپورٹ اور شیئر کریں۔';

  @override
  String get chatMediaGallery => 'میڈیا گیلری';

  @override
  String get chatExportHistory => 'چیٹ کی سرگزشت برآمد کریں۔';

  @override
  String get pdfLoadFailed => 'PDF لوڈ کرنے میں ناکام';

  @override
  String pdfPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get mediaAll => 'تمام';

  @override
  String get mediaImages => 'امیجز';

  @override
  String get mediaVideos => 'ویڈیوز';

  @override
  String get mediaFiles => 'فائلیں';

  @override
  String get mediaAudio => 'آڈیو';

  @override
  String mediaItemsCount(int count) {
    return '$count آئٹمز';
  }

  @override
  String get mediaNoMediaFound => 'کوئی میڈیا نہیں ملا';

  @override
  String get spacesTitle => 'کمیونٹیز';

  @override
  String get spacesCreate => 'کمیونٹی بنائیں';

  @override
  String get spacesJoined => 'شامل ہو گئے۔';

  @override
  String get spacesDiscover => 'دریافت کریں۔';

  @override
  String get spacesNoJoined => 'ابھی تک کوئی کمیونٹی شامل نہیں ہوئی۔';

  @override
  String get spacesExplore => 'کمیونٹیز کو دریافت کریں۔';

  @override
  String get spacesNoPublic => 'کوئی عوامی کمیونٹی نہیں ملی';

  @override
  String get spacesJoin => 'شمولیت';

  @override
  String get spacesSubSpaces => 'ذیلی برادریاں';

  @override
  String get spacesChannels => 'چینلز';

  @override
  String spacesMembersCount(int count) {
    return '$count اراکین';
  }

  @override
  String get spacesPublic => 'عوامی';

  @override
  String get spacesPrivate => 'نجی';

  @override
  String get spacesSuggested => 'تجویز کردہ';

  @override
  String spacesChannelsCount(int count) {
    return '$count چینلز';
  }

  @override
  String get callInCallChat => 'کال میں چیٹ';

  @override
  String callMessagesCount(int count) {
    return '$count پیغامات';
  }

  @override
  String get callNoMessagesYet =>
      'ابھی تک کوئی پیغامات نہیں ہیں۔\nشروع کرنے کے لیے ایک پیغام بھیجیں۔';

  @override
  String get callTypeMessage => 'ایک پیغام ٹائپ کریں...';

  @override
  String get callYouSender => 'آپ';

  @override
  String get callChatLabel => 'گپ شپ';

  @override
  String get chatEdited => 'ترمیم شدہ';

  @override
  String get chatEditHistory => 'تاریخ میں ترمیم کریں۔';

  @override
  String get chatOriginalMessage => 'اصل';

  @override
  String chatEditedAt(String time) {
    return '$time پر ترمیم کی گئی۔';
  }

  @override
  String get chatViewOnce => 'ایک بار دیکھیں';

  @override
  String get chatViewOncePhoto => 'ایک بار تصویر دیکھیں';

  @override
  String get chatViewOnceVideo => 'ایک بار ویڈیو دیکھیں';

  @override
  String get chatViewOnceViewed => 'دیکھا گیا';

  @override
  String get chatViewOnceExpired => 'میعاد ختم';

  @override
  String get chatViewOnceTap => 'دیکھنے کے لیے تھپتھپائیں۔';

  @override
  String get chatAutoFaceBlur => 'خودکار چہرے کا دھندلا پن';

  @override
  String get chatAutoFaceBlurDesc =>
      'تصاویر بھیجتے وقت چہروں کو خودکار طور پر دھندلا کریں۔';

  @override
  String get threadReplyInThread => 'تھریڈ میں جواب دیں۔';

  @override
  String threadReplies(int count) {
    return '$count جوابات';
  }

  @override
  String get threadReply => '1 جواب';

  @override
  String threadLatestReply(String preview) {
    return 'تازہ ترین: $preview';
  }

  @override
  String get threadTitle => 'تھریڈ';

  @override
  String get threadReplyPlaceholder => 'تھریڈ میں جواب دیں...';

  @override
  String threadParticipants(int count) {
    return '$count شرکاء';
  }

  @override
  String get voiceRoomTitle => 'وائس روم';

  @override
  String get voiceRoomCreate => 'وائس روم بنائیں';

  @override
  String get voiceRoomJoin => 'شمولیت';

  @override
  String get voiceRoomLeave => 'چھوڑو';

  @override
  String get voiceRoomEnd => 'اختتامی کمرہ';

  @override
  String get voiceRoomRaiseHand => 'ہاتھ اٹھائیں۔';

  @override
  String get voiceRoomLowerHand => 'نچلا ہاتھ';

  @override
  String get voiceRoomMute => 'خاموش';

  @override
  String get voiceRoomUnmute => 'چالو کریں۔';

  @override
  String get voiceRoomHost => 'میزبان';

  @override
  String get voiceRoomSpeakers => 'مقررین';

  @override
  String get voiceRoomListeners => 'سننے والے';

  @override
  String get voiceRoomLive => 'لائیو';

  @override
  String get voiceRoomEnded => 'ختم ہوا۔';

  @override
  String get voiceRoomScheduled => 'طے شدہ';

  @override
  String get voiceRoomApprove => 'منظور کرو';

  @override
  String get voiceRoomDemote => 'سننے والے پر منتقل کریں۔';

  @override
  String voiceRoomHandRaised(String name) {
    return '$name نے ہاتھ اٹھایا';
  }

  @override
  String get voiceRoomName => 'کمرے کا نام';

  @override
  String get voiceRoomTopic => 'موضوع (اختیاری)';

  @override
  String get voiceRoomNoActive => 'کوئی فعال آواز والے کمرے نہیں ہیں۔';

  @override
  String get voiceRoomConnecting => 'منسلک ہو رہا ہے...';

  @override
  String get usernameTitle => 'صارف نام';

  @override
  String get usernameSet => 'یوزر نیم سیٹ کریں۔';

  @override
  String get usernameChange => 'صارف نام تبدیل کریں۔';

  @override
  String get usernamePlaceholder => 'صارف نام درج کریں۔';

  @override
  String get usernameAvailable => 'صارف نام دستیاب ہے۔';

  @override
  String get usernameUnavailable => 'صارف نام پہلے ہی لے لیا گیا ہے۔';

  @override
  String get usernameInvalid =>
      '3-30 حروف، چھوٹے حروف، نمبر، انڈر سکور۔ ایک خط سے شروع کرنا چاہیے۔';

  @override
  String get usernameReserved => 'یہ صارف نام محفوظ ہے۔';

  @override
  String get usernameSaved => 'صارف نام محفوظ ہو گیا۔';

  @override
  String get usernameSearchHint => '@username کے ذریعے تلاش کریں۔';

  @override
  String get ensName => 'ENS کا نام';

  @override
  String get ensLinked => 'ENS سے منسلک';

  @override
  String get ensResolving => 'ENS کو حل کیا جا رہا ہے...';

  @override
  String get ensNotFound => 'ENS کا نام نہیں ملا';

  @override
  String get tokenGateTitle => 'ٹوکن گیٹ';

  @override
  String get tokenGateEnable => 'ٹوکن گیٹ کو فعال کریں۔';

  @override
  String get tokenGateDisable => 'ٹوکن گیٹ کو غیر فعال کریں۔';

  @override
  String get tokenGateAddRule => 'قاعدہ شامل کریں۔';

  @override
  String get tokenGateRemoveRule => 'قاعدہ کو ہٹا دیں۔';

  @override
  String get tokenGateContractAddress => 'معاہدہ کا پتہ';

  @override
  String get tokenGateMinBalance => 'کم از کم بیلنس';

  @override
  String get tokenGateTokenId => 'ٹوکن ID (ERC-1155)';

  @override
  String get tokenGateChainId => 'سلسلہ ID';

  @override
  String get tokenGateVerifying => 'ٹوکن ہولڈنگز کی تصدیق ہو رہی ہے...';

  @override
  String get tokenGateVerified => 'تصدیق گزر گئی۔';

  @override
  String get tokenGateDenied => 'آپ ٹوکن کی ضروریات کو پورا نہیں کرتے ہیں۔';

  @override
  String get tokenGateOperatorAnd => 'تمام قوانین کو پورا کرنا ضروری ہے۔';

  @override
  String get tokenGateOperatorOr => 'کسی بھی اصول پر پورا اترنا چاہیے۔';

  @override
  String get tokenGateRuleErc20 => 'ERC-20 ٹوکن';

  @override
  String get tokenGateRuleErc721 => 'NFT (ERC-721)';

  @override
  String get tokenGateRuleErc1155 => 'ملٹی ٹوکن (ERC-1155)';

  @override
  String get tokenGateRuleNative => 'مقامی ٹوکن';

  @override
  String get tokenGateSaved => 'ٹوکن گیٹ محفوظ ہو گیا۔';

  @override
  String get tokenGateEnableDescription =>
      'شامل ہونے کے لیے اراکین کو ٹوکن رکھنے کی ضرورت ہے۔';

  @override
  String get tokenGateOperator => 'اصول منطق';

  @override
  String get tokenGateRules => 'قواعد';

  @override
  String get tokenGateSymbol => 'علامت (اختیاری)';

  @override
  String get tokenGateChain => 'زنجیر';

  @override
  String get tokenGateTokenStandard => 'ٹوکن سٹینڈرڈ';

  @override
  String get tokenGateDenialMessage => 'تردید کا پیغام';

  @override
  String get tokenGateDenialMessageHint =>
      'تصدیق کے ناکام ہونے پر پیغام دکھایا جاتا ہے۔';

  @override
  String get tokenGateVerifyTitle => 'ٹوکن کی تصدیق';

  @override
  String get tokenGateVerifyPassed => 'تصدیق پاس ہو گئی۔';

  @override
  String get tokenGateVerifyFailed => 'توثیق ناکام ہو گئی۔';

  @override
  String get tokenGateRetryVerify => 'دوبارہ کوشش کریں۔';

  @override
  String get tokenGateRequired => 'درکار ہے۔';

  @override
  String get tokenGateYourBalance => 'آپ کا بیلنس';

  @override
  String get tokenGateRulesActive => 'فعال قوانین';

  @override
  String get tokenGateDisabled => 'معذور';

  @override
  String get ensNotBound => 'پابند نہیں۔';

  @override
  String get liveLocation => 'لائیو مقام';

  @override
  String get stopLiveLocation => 'شیئر کرنا بند کریں۔';

  @override
  String get startLiveLocation => 'شیئرنگ شروع کریں۔';

  @override
  String get selectDuration => 'مدت منتخب کریں۔';

  @override
  String get groupChatFiles => 'چیٹ فائلز';

  @override
  String get groupLinks => 'لنکس';

  @override
  String get groupNoLinks => 'ابھی تک کوئی لنکس نہیں ہیں۔';

  @override
  String get chatBackground => 'چیٹ کا پس منظر';

  @override
  String get solidColors => 'ٹھوس رنگ';

  @override
  String get gradients => 'میلان';

  @override
  String get defaultBackground => 'طے شدہ';

  @override
  String get settingsFontSizeSlider => 'فونٹ کا سائز';

  @override
  String get autoDownload => 'خودکار ڈاؤن لوڈ';

  @override
  String get images => 'امیجز';

  @override
  String get voice => 'آواز';

  @override
  String get video => 'ویڈیو';

  @override
  String get files => 'فائلیں';

  @override
  String get mobileData => 'موبائل ڈیٹا';

  @override
  String get roaming => 'رومنگ';

  @override
  String get storageManagement => 'ذخیرہ';

  @override
  String get totalUsage => 'کل استعمال';

  @override
  String get cache => 'کیشے';

  @override
  String get other => 'دیگر';

  @override
  String get clearCache => 'کیشے صاف کریں۔';

  @override
  String get cacheCleared => 'کیش صاف ہو گیا۔';

  @override
  String get clearCacheFailed => 'کیشے صاف کرنے میں ناکام';

  @override
  String get confirmClearCache => 'تمام کیش ڈیٹا کو صاف کریں؟';

  @override
  String get mapView => 'نقشہ دیکھیں';

  @override
  String liveLocationSharingCount(int count) {
    return '$count لوگ مقام کا اشتراک کر رہے ہیں۔';
  }

  @override
  String get minutes15 => '15 منٹ';

  @override
  String get minutes30 => '30 منٹ';

  @override
  String get hour1 => '1 گھنٹہ';

  @override
  String get hours8 => '8 گھنٹے';

  @override
  String get personalCard => 'ذاتی کارڈ';

  @override
  String get downloadFailed => 'ڈاؤن لوڈ ناکام ہو گیا۔';

  @override
  String get locationExpired => 'میعاد ختم';

  @override
  String secondsRemaining(int count) {
    return '$count سیکنڈ';
  }

  @override
  String minutesRemaining(int count) {
    return '$count منٹ';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '$hours گھنٹے $minutes منٹ';
  }

  @override
  String get favoriteMessages => 'پسندیدہ';

  @override
  String get linksCopied => 'لنک کاپی ہو گیا۔';

  @override
  String get noLinksFound => 'کوئی لنکس نہیں ملے';

  @override
  String get roomStorageRanking => 'کمرہ اسٹوریج کی درجہ بندی';

  @override
  String get downloadComplete => 'ڈاؤن لوڈ مکمل';

  @override
  String get downloading => 'ڈاؤن لوڈ ہو رہا ہے...';

  @override
  String get draftSaved => 'مسودہ محفوظ ہو گیا۔';

  @override
  String get voiceRecording => 'وائس ریکارڈنگ';

  @override
  String get searchLocation => 'مقام تلاش کریں۔';

  @override
  String get tapToSearch => 'تلاش کرنے کے لیے تھپتھپائیں۔';

  @override
  String get settingsThisDevice => 'یہ ڈیوائس';

  @override
  String get settingsJustNow => 'ابھی ابھی';

  @override
  String get settingsDeviceId => 'ڈیوائس کی شناخت';

  @override
  String get settingsStatus => 'حیثیت';

  @override
  String get settingsLastActive => 'آخری فعال';

  @override
  String get settingsIpAddress => 'آئی پی ایڈریس';

  @override
  String get settingsRenameDevice => 'ڈیوائس کا نام تبدیل کریں۔';

  @override
  String get settingsDeviceNameHint => 'ڈیوائس کا نام درج کریں۔';

  @override
  String get settingsDeviceRenamed => 'ڈیوائس کا نام تبدیل کر دیا گیا۔';

  @override
  String get settingsRenameFailed => 'نام بدلنا ناکام ہو گیا۔';

  @override
  String get settingsRemoteLogout => 'ریموٹ لاگ آؤٹ';

  @override
  String settingsRemoteLogoutConfirm(String deviceName) {
    return 'کیا آپ واقعی \"$deviceName\" سے لاگ آؤٹ کرنا چاہتے ہیں؟ اس کارروائی کو کالعدم نہیں کیا جا سکتا۔';
  }

  @override
  String get settingsDeviceLoggedOut => 'ڈیوائس لاگ آؤٹ ہو گئی۔';

  @override
  String get settingsLogoutFailed => 'لاگ آؤٹ ناکام ہو گیا۔';

  @override
  String get settingsLogout => 'لاگ آؤٹ';

  @override
  String get settingsVerifyIdentity => 'شناخت کی تصدیق کریں۔';

  @override
  String get settingsEnterPasswordToConfirm =>
      'اس عمل کی تصدیق کے لیے اپنا پاس ورڈ درج کریں۔';

  @override
  String get scheduledSendTitle => 'میسج شیڈول کریں۔';

  @override
  String get scheduledSendInOneHour => '1 گھنٹے میں';

  @override
  String get scheduledSendTonight => 'آج رات (8:00 PM)';

  @override
  String get scheduledSendTomorrowMorning => 'کل صبح (9:00 AM)';

  @override
  String get scheduledSendCustom => 'ایک تاریخ اور وقت چنیں۔';

  @override
  String get scheduledMessageLabel => 'طے شدہ';

  @override
  String get scheduledMessageCancel => 'طے شدہ پیغام منسوخ کریں۔';

  @override
  String get chatLockTitle => 'چیٹ لاک';

  @override
  String get chatLockEnable => 'اس چیٹ کو لاک کریں۔';

  @override
  String get chatLockDisable => 'اس چیٹ کو غیر مقفل کریں۔';

  @override
  String get chatLockDescription =>
      'مقفل چیٹس کو کھولنے کے لیے بائیو میٹرک یا پن کی تصدیق کی ضرورت ہوتی ہے۔';

  @override
  String get chatLockVerifyTitle => 'چیٹ مقفل ہے۔';

  @override
  String get chatLockVerifySubtitle => 'اس چیٹ تک رسائی کے لیے تصدیق کریں۔';

  @override
  String get chatLockVerifyFailed => 'تصدیق ناکام ہوگئی';

  @override
  String get chatLockEnabled => 'چیٹ مقفل ہے۔';

  @override
  String get chatLockDisabled => 'چیٹ غیر مقفل ہو گئی۔';

  @override
  String get chatLockPinTitle => 'PIN درج کریں۔';

  @override
  String get chatLockPinSetTitle => 'PIN سیٹ کریں۔';

  @override
  String get chatLockPinConfirmTitle => 'پن کی تصدیق کریں۔';

  @override
  String get chatLockPinMismatch => 'PIN مماثل نہیں ہے۔';

  @override
  String get chatLockUseBiometric => 'بائیو میٹرک استعمال کریں۔';

  @override
  String get chatLockUsePin => 'PIN استعمال کریں۔';

  @override
  String get mediaEditorUndo => 'کالعدم';

  @override
  String get mediaEditorRedo => 'دوبارہ کریں۔';

  @override
  String get mediaEditorCrop => 'فصل';

  @override
  String get mediaEditorFilter => 'فلٹر';

  @override
  String get mediaEditorDraw => 'ڈرا';

  @override
  String get mediaEditorText => 'متن';

  @override
  String get aiAssistant => 'اے آئی اسسٹنٹ';

  @override
  String get aiAssistantWelcome =>
      'ہیلو! میں N42 AI اسسٹنٹ ہوں۔ میں آپ کی مدد کیسے کر سکتا ہوں؟';

  @override
  String get aiAssistantNotConfigured => 'AI سروس کنفیگر نہیں ہے۔';

  @override
  String get aiAssistantSettings => 'AI ترتیبات';

  @override
  String get aiAssistantClearHistory => 'چیٹ کی سرگزشت صاف کریں۔';

  @override
  String get aiAssistantClearHistoryConfirm =>
      'کیا آپ واقعی AI چیٹ کی تمام سرگزشت صاف کرنا چاہتے ہیں؟';

  @override
  String get aiAssistantStopGenerating => 'پیدا کرنا بند کریں۔';

  @override
  String get aiAssistantModel => 'ماڈل';

  @override
  String get aiAssistantTemperature => 'درجہ حرارت';

  @override
  String get aiAssistantMaxTokens => 'زیادہ سے زیادہ ٹوکن';

  @override
  String get aiAssistantContextWindow => 'سیاق و سباق کی کھڑکی';

  @override
  String get aiAssistantServiceStatus => 'سروس کی حیثیت';

  @override
  String get aiAssistantAvailable => 'دستیاب ہے۔';

  @override
  String get aiAssistantUnavailable => 'دستیاب نہیں۔';

  @override
  String get aiSummarize => 'AI کا خلاصہ';

  @override
  String aiSummarizeUnread(int count) {
    return '$count بغیر پڑھے ہوئے پیغامات کا خلاصہ کریں۔';
  }

  @override
  String get aiSummarizeLoading => 'خلاصہ...';

  @override
  String get aiSummarizeError => 'خلاصہ کرنے میں ناکام';

  @override
  String get aiRewrite => 'AI دوبارہ لکھنا';

  @override
  String get aiRewriteFormal => 'رسمی';

  @override
  String get aiRewriteCasual => 'آرام دہ اور پرسکون';

  @override
  String get aiRewritePlayful => 'زندہ دل';

  @override
  String get aiRewriteProfessional => 'پیشہ ورانہ';

  @override
  String get aiRewriteAccept => 'استعمال کریں۔';

  @override
  String get aiRewriteCancel => 'منسوخ کریں۔';

  @override
  String get aiRewriteLoading => 'دوبارہ لکھنا...';

  @override
  String get aiLinkSummary => 'AI کا خلاصہ';

  @override
  String get aiLinkSummaryAnalyzing => 'تجزیہ کر رہا ہے...';

  @override
  String get chatFolderManagement => 'فولڈرز کا نظم کریں۔';

  @override
  String get chatFolderSystem => 'سسٹم فولڈرز';

  @override
  String get chatFolderCustom => 'حسب ضرورت فولڈرز';

  @override
  String get chatFolderEmpty => 'ابھی تک کوئی حسب ضرورت فولڈرز نہیں ہیں۔';

  @override
  String get chatFolderCreate => 'فولڈر بنائیں';

  @override
  String get chatFolderEdit => 'فولڈر میں ترمیم کریں۔';

  @override
  String get chatFolderNameHint => 'فولڈر کا نام';

  @override
  String get chatFolderAll => 'تمام';

  @override
  String get chatFolderUnread => 'ان پڑھ';

  @override
  String get chatFolderPersonal => 'ذاتی';

  @override
  String get chatFolderGroups => 'گروپس';

  @override
  String get chatFolderChannels => 'چینلز';

  @override
  String get chatFolderMuted => 'خاموش';

  @override
  String get storyAddMusic => 'موسیقی شامل کریں۔';

  @override
  String get storyChangeMusic => 'موسیقی تبدیل کریں۔';

  @override
  String get storyBackgroundMusic => 'بیک گراؤنڈ میوزک';

  @override
  String get storyMusicPreview => 'پیش نظارہ (زیادہ سے زیادہ 15 سیکنڈ)';

  @override
  String get storyChooseFromDevice => 'ڈیوائس سے انتخاب کریں۔';

  @override
  String get storyUseThisMusic => 'یہ موسیقی استعمال کریں۔';

  @override
  String get authPasskeyNotSupported => 'پاسکی اس آلہ پر تعاون یافتہ نہیں ہے۔';

  @override
  String get authPasskeyRegister => 'پاسکی رجسٹر کریں۔';

  @override
  String get authPasskeyNoRegistered => 'کوئی پاسکیز رجسٹرڈ نہیں ہیں۔';

  @override
  String get authPasskeyRegisterHint =>
      'اس اکاؤنٹ کے لیے پاس کی رجسٹر کریں۔ اسٹینڈ ایلون پاسکی سائن ان بعد میں فعال ہو جائے گا۔';

  @override
  String get authPasskeyNameYours => 'اپنی پاسکی کو نام دیں۔';

  @override
  String get authPasskeyRegistered => 'پاسکی اس اکاؤنٹ میں محفوظ ہوگئی';

  @override
  String get authPasskeyDeleted => 'پاسکی اس اکاؤنٹ سے ہٹا دی گئی۔';

  @override
  String authPasskeyDeleteConfirm(String name) {
    return 'پاس کی \"$name\" کو حذف کریں؟ بعد میں پاس کی سائن ان استعمال کرنے سے پہلے آپ کو اسے دوبارہ رجسٹر کرنے کی ضرورت ہوگی۔';
  }

  @override
  String get momentVisibilityPublic => 'عوامی';

  @override
  String get momentVisibilityPrivate => 'نجی';

  @override
  String get momentVisibilityPartial => 'منتخب دوست';

  @override
  String get momentVisibilityExcluded => 'کچھ دوستوں کو چھوڑ دیں۔';

  @override
  String momentUserMoments(String userName) {
    return '$userName کے لمحات';
  }

  @override
  String get momentForwardTo => 'کو آگے بھیجیں۔';

  @override
  String get momentForwardSuccess => 'کامیابی سے آگے بھیج دیا گیا۔';

  @override
  String get momentSelectFriends => 'دوست منتخب کریں۔';

  @override
  String get momentSelectTags => 'ٹیگز کے ذریعہ منتخب کریں۔';

  @override
  String momentSelectedCount(int count) {
    return 'منتخب ($count)';
  }

  @override
  String get momentNoMomentsYet => 'ابھی کوئی لمحات نہیں ہیں۔';

  @override
  String get momentForwardMoment => 'آگے کا لمحہ';

  @override
  String get momentAddComment => 'ایک تبصرہ شامل کریں...';

  @override
  String momentForwardContent(String content) {
    return '[لمحہ] $content';
  }

  @override
  String get momentDeleteMoment => 'لمحے کو حذف کریں۔';

  @override
  String get momentDeleteConfirm =>
      'کیا آپ واقعی اس لمحے کو حذف کرنا چاہتے ہیں؟';

  @override
  String get momentComment => 'تبصرہ';

  @override
  String get momentWriteComment => 'ایک تبصرہ لکھیں...';

  @override
  String get momentLike => 'پسند';

  @override
  String get momentUnlike => 'کے برعکس';

  @override
  String get momentForward => 'آگے';

  @override
  String get momentDelete => 'حذف کریں۔';

  @override
  String get momentReply => 'جواب';

  @override
  String get momentMoment => 'لمحہ';

  @override
  String momentLikesCount(int count) {
    return '$count پسند کرتا ہے۔';
  }

  @override
  String momentCommentsCount(int count) {
    return '$count تبصرے';
  }

  @override
  String get momentNoComments => 'ابھی تک کوئی تبصرہ نہیں';

  @override
  String get momentFailedToLoad => 'تصویر لوڈ کرنے میں ناکام';

  @override
  String momentReplyTo(String userName) {
    return '$userName کا جواب دیں...';
  }

  @override
  String get momentNoConversations => 'کوئی بات چیت نہیں۔';

  @override
  String get momentJustNow => 'ابھی';

  @override
  String momentMinutesAgo(int count) {
    return '${count}m پہلے';
  }

  @override
  String momentHoursAgo(int count) {
    return '${count}h پہلے';
  }

  @override
  String momentDaysAgo(int count) {
    return '${count}d پہلے';
  }

  @override
  String get chatGroupAnnouncementHint => 'گروپ کا اعلان درج کریں۔';

  @override
  String get chatGroupAnnouncementEmpty => 'کوئی اعلان نہیں۔';

  @override
  String get chatEditNickname => 'عرفی نام میں ترمیم کریں۔';

  @override
  String get chatNicknameHint => 'اس گروپ میں اپنا عرفی نام درج کریں۔';

  @override
  String get contactAddPhoneHint => 'فون نمبر درج کریں۔';

  @override
  String get contactNotesHint => 'اس رابطے کے بارے میں نوٹس شامل کریں۔';

  @override
  String get reportTitle => 'رپورٹ';

  @override
  String get reportReasonSpam => 'سپیم';

  @override
  String get reportReasonHarassment => 'ہراساں کرنا';

  @override
  String get reportReasonFraud => 'فراڈ';

  @override
  String get reportReasonOther => 'دیگر';

  @override
  String get reportSubmitted => 'رپورٹ جمع کرائی';

  @override
  String get reportDescription => 'اضافی تفصیل (اختیاری)';

  @override
  String get qrcodeSaved => 'QR کوڈ البم میں محفوظ ہو گیا۔';

  @override
  String get chatSendRedPacketInChat => 'براہ کرم چیٹ میں سرخ پیکٹ بھیجیں۔';

  @override
  String get commonSaveFailed => 'محفوظ کرنا ناکام ہو گیا۔';

  @override
  String get reportSelectReason => 'براہ کرم ایک وجہ منتخب کریں۔';

  @override
  String get gameCenter => 'گیمز';

  @override
  String get gameHighScore => 'بہترین';

  @override
  String get gameScore => 'سکور';

  @override
  String get gameOver => 'کھیل ختم';

  @override
  String get gamePlayAgain => 'دوبارہ کھیلیں';

  @override
  String get gameLeaderboard => 'لیڈر بورڈ';

  @override
  String get gamePause => 'روک دیا گیا';

  @override
  String get gameResume => 'دوبارہ شروع کرنے کے لیے تھپتھپائیں۔';

  @override
  String get gameConfirmExit => 'اس کھیل کو چھوڑ دیں؟';

  @override
  String get gameNoScores => 'ابھی تک کوئی سکور نہیں۔';

  @override
  String get game2048 => '2048';

  @override
  String get game2048Desc => '2048 تک پہنچنے کے لیے ٹائلوں کو ضم کریں۔';

  @override
  String get gameBlockDrop => 'بلاک ڈراپ';

  @override
  String get gameBlockDropDesc => 'ڈراپ اور صاف لائنیں';

  @override
  String get gameMinesweeper => 'مائن سویپر';

  @override
  String get gameMinesweeperDesc => 'تمام محفوظ خلیات تلاش کریں۔';

  @override
  String get gameMatch3 => 'میچ 3';

  @override
  String get gameMatch3Desc => '3 یا اس سے زیادہ جواہرات سے میچ کریں۔';

  @override
  String get gameMinesweeperEasy => 'آسان';

  @override
  String get gameMinesweeperMedium => 'درمیانہ';

  @override
  String get gameMinesLeft => 'مائنز بائیں';

  @override
  String get gameTimeLeft => 'وقت';

  @override
  String get gameLevel => 'سطح';

  @override
  String get gameNext => 'اگلا';

  @override
  String get gameBestTime => 'بہترین وقت';

  @override
  String get gameNewRecord => 'نیا ریکارڈ!';

  @override
  String get gameLines => 'لکیریں';

  @override
  String get storyMyStory => 'میری کہانی';

  @override
  String get storageSmartCleanup => 'اسمارٹ کلین اپ';

  @override
  String get storageOldMediaFiles => 'پرانی میڈیا فائلیں۔';

  @override
  String get storageLargeFiles => 'بڑی فائلیں۔';

  @override
  String get storageAppCache => 'ایپ کیشے';

  @override
  String get storageSettings => 'اسٹوریج کی ترتیبات';

  @override
  String get storageAutoCleanup => 'آٹو کلین اپ';

  @override
  String storageAutoCleanupDesc(int days) {
    return '$days دنوں سے زیادہ پرانی فائلوں کو خودکار طور پر صاف کریں۔';
  }

  @override
  String get storageCleanupPeriod => 'صفائی کی مدت';

  @override
  String get storagePreserveThumbnails => 'تھمب نیلز کو محفوظ کریں۔';

  @override
  String get storagePreserveThumbnailsDesc =>
      'صفائی کے دوران تصویری تھمب نیلز رکھیں';

  @override
  String get storageWarningHigh =>
      'اسٹوریج کا استعمال زیادہ ہے۔ پرانی فائلوں کو صاف کرنے پر غور کریں۔';

  @override
  String get storageWarningCritical =>
      'اسٹوریج انتہائی کم ہے۔ براہ کرم خالی جگہ تک صاف کریں۔';

  @override
  String storageFreed(String size, int count) {
    return 'آزاد شدہ $size ($count فائلیں)';
  }

  @override
  String storageDays(int days) {
    return '$days دن';
  }

  @override
  String storageViewAllRooms(int count) {
    return 'تمام $count کمرے دیکھیں';
  }

  @override
  String get storageNoFiles => 'کوئی فائل نہیں ملی';

  @override
  String get storageFilePinned => 'پن لگا ہوا';

  @override
  String storageDeleteSelected(int count) {
    return '$count منتخب فائلوں کو حذف کریں؟ انہیں سرور سے دوبارہ ڈاؤن لوڈ کیا جا سکتا ہے۔';
  }

  @override
  String get backupRestore => 'بیک اپ اور بحال کریں۔';

  @override
  String get backupCreate => 'بیک اپ بنائیں';

  @override
  String get backupCreateDesc =>
      'اپنی ترتیبات اور انکرپشن کیز کا بیک اپ لیں۔ دوبارہ لاگ ان ہونے کے بعد سرور سے پیغامات بحال ہو جائیں گے۔';

  @override
  String get backupIncludeKeys => 'انکرپشن کیز شامل کریں۔';

  @override
  String get backupIncludeKeysDesc =>
      'خفیہ کردہ پیغامات کو پڑھنے کے لیے درکار ہے۔';

  @override
  String get backupPasswordProtect => 'پاس ورڈ کی حفاظت';

  @override
  String get backupEnterPassword => 'بیک اپ پاس ورڈ درج کریں۔';

  @override
  String get backupHistory => 'بیک اپ ہسٹری';

  @override
  String get backupNoBackups => 'ابھی تک کوئی بیک اپ نہیں ہے۔';

  @override
  String get backupRestore2 => 'بحال کریں۔';

  @override
  String get backupDelete => 'حذف کریں۔';

  @override
  String get backupDeleteConfirm =>
      'کیا آپ واقعی اس بیک اپ کو حذف کرنا چاہتے ہیں؟ اسے کالعدم نہیں کیا جا سکتا۔';

  @override
  String get backupRestoreFromFile => 'فائل سے بحال کریں۔';

  @override
  String get backupRestoreFromFileDesc =>
      'کسی دوسرے ڈیوائس یا پچھلے بیک اپ سے .n42 بیک اپ فائل درآمد کریں۔';

  @override
  String get backupChooseFile => 'بیک اپ فائل کا انتخاب کریں۔';

  @override
  String get backupRestoring => 'بحال ہو رہا ہے...';

  @override
  String backupCreated(int rooms, int messages) {
    return 'بیک اپ بنایا گیا: $rooms کمرے، $messages پیغامات';
  }

  @override
  String backupRestored(int settings, int rooms) {
    return '$rooms کمروں سے $settings ترتیبات کو بحال کیا گیا۔';
  }

  @override
  String backupFailed(String error) {
    return 'بیک اپ ناکام ہو گیا: $error';
  }

  @override
  String get backupPasswordRequired => 'یہ بیک اپ پاس ورڈ سے محفوظ ہے۔';

  @override
  String get blocGroupNotFound => 'گروپ نہیں ملا';

  @override
  String blocGroupMembersInvited(int count) {
    return 'مدعو کردہ $count ممبران';
  }

  @override
  String get blocGroupMemberRemoved => 'ممبر کو ہٹا دیا گیا۔';

  @override
  String get blocGroupAdminRemoved => 'ایڈمن کو ہٹا دیا گیا۔';

  @override
  String get blocGroupLeft => 'گروپ چھوڑ دیا۔';

  @override
  String get blocGroupDisbanded => 'گروپ منقطع';

  @override
  String get blocGroupJoined => 'گروپ میں شامل ہوا۔';

  @override
  String get blocGroupInviteDeclined => 'دعوت مسترد کر دی گئی۔';

  @override
  String get blocGroupTokenGateUpdated => 'ٹوکن گیٹ اپ ڈیٹ ہو گیا۔';

  @override
  String get blocTransferProcessing => 'منتقلی پر کارروائی ہو رہی ہے...';

  @override
  String get blocTransferCancelled => 'منتقلی منسوخ کر دی گئی۔';

  @override
  String get blocTransferFailed => 'منتقلی ناکام ہو گئی۔';

  @override
  String get blocPaymentProcessing => 'ادائیگی پر کارروائی ہو رہی ہے...';

  @override
  String get blocPaymentFailed => 'ادائیگی ناکام ہو گئی۔';

  @override
  String get groupMaxMembers => 'رکن کی حد';

  @override
  String get groupMaxMembersUnlimited => 'لا محدود';

  @override
  String get groupMaxMembersHint =>
      'حد درج کریں (لامحدود کے لیے خالی چھوڑ دیں)';

  @override
  String get groupMaxMembersUpdated => 'ممبر کی حد کو اپ ڈیٹ کر دیا گیا۔';

  @override
  String get groupFull => 'گروپ صلاحیت پر ہے۔';

  @override
  String get groupChannels => 'موضوع کے چینلز';

  @override
  String get groupChannelsEmpty => 'ابھی تک کوئی چینل نہیں ہے۔';

  @override
  String get groupChannelsCount => 'چینلز';

  @override
  String get groupChannelCreate => 'نیا چینل';

  @override
  String get groupChannelName => 'چینل کا نام';

  @override
  String get groupChannelTopic => 'چینل کا موضوع (اختیاری)';

  @override
  String get groupChannelDelete => 'چینل کو حذف کریں۔';

  @override
  String get groupChannelDeleteConfirm =>
      'اس چینل کو حذف کریں؟ تمام پیغامات ضائع ہو جائیں گے۔';

  @override
  String get groupBotSettings => 'بوٹ کی ترتیبات';

  @override
  String get groupBotEnabled => 'بوٹ کو فعال کریں۔';

  @override
  String get groupBotWelcomeMessage => 'خوش آمدید پیغام کا سانچہ';

  @override
  String get groupBotWelcomeHint =>
      'نئے رکن کے نام کے لیے \'نام\' بطور پلیس ہولڈر استعمال کریں۔';

  @override
  String get groupBotConfigUpdated => 'بوٹ کی ترتیبات کو اپ ڈیٹ کر دیا گیا۔';

  @override
  String get groupContentFilter => 'مواد کا فلٹر';

  @override
  String get groupContentFilterEnabled => 'مطلوبہ الفاظ کے فلٹر کو فعال کریں۔';

  @override
  String get groupContentFilterReplace => '*** سے بدلیں';

  @override
  String get groupContentFilterHide => 'پیغام چھپائیں۔';

  @override
  String get groupContentFilterAddWord => 'مطلوبہ الفاظ شامل کریں۔';

  @override
  String get groupContentFilterUpdated => 'مواد کا فلٹر اپ ڈیٹ ہو گیا۔';

  @override
  String get chatSlashCommands => 'احکام';

  @override
  String get chatCommandPoll => '/پول - ایک پول بنائیں';

  @override
  String get chatCommandAnnounce => '/ اعلان کریں - اعلان بھیجیں۔';

  @override
  String get chatCommandWelcome => '/welcome — خوش آمدید کا پیغام سیٹ کریں۔';

  @override
  String get chatReportMessage => 'رپورٹ';

  @override
  String get chatReportReason => 'رپورٹ کی وجہ';

  @override
  String get chatReportSpam => 'سپیم';

  @override
  String get chatReportHarassment => 'ہراساں کرنا';

  @override
  String get chatReportInappropriate => 'نامناسب مواد';

  @override
  String get chatReportOther => 'دیگر';

  @override
  String get chatReportSuccess => 'رپورٹ جمع کرائی';

  @override
  String get spacesName => 'کمیونٹی کا نام';

  @override
  String get spacesNameHint => 'جیسے کرپٹو ٹریڈرز';

  @override
  String get spacesNameRequired => 'نام درکار ہے۔';

  @override
  String get spacesDescription => 'تفصیل';

  @override
  String get spacesDescriptionHint => 'اس کمیونٹی کے بارے میں کیا ہے؟';

  @override
  String get spacesType => 'کمیونٹی کی قسم';

  @override
  String get spacesPublicDesc =>
      'کوئی بھی دریافت کر سکتا ہے اور شامل ہو سکتا ہے۔';

  @override
  String get spacesPrivateDesc => 'صرف مدعو ممبران ہی شامل ہو سکتے ہیں۔';

  @override
  String get spacesNotFound => 'کمیونٹی نہیں ملی';

  @override
  String get spacesSearch => 'کمیونٹیز تلاش کریں...';

  @override
  String get spacesMembers => 'ممبران';

  @override
  String get spacesNoChannels => 'ابھی تک کوئی چینل نہیں ہے۔';

  @override
  String get spacesLeave => 'کمیونٹی چھوڑ دیں۔';

  @override
  String spacesLeaveConfirm(String name) {
    return 'کیا آپ واقعی \"$name\" چھوڑنا چاہتے ہیں؟';
  }

  @override
  String get spacesDelete => 'کمیونٹی کو حذف کریں۔';

  @override
  String spacesDeleteConfirm(String name) {
    return 'یہ \"$name\" اور اس کے تمام چینلز کو مستقل طور پر حذف کر دے گا۔ اس کارروائی کو کالعدم نہیں کیا جا سکتا۔';
  }

  @override
  String get spacesCreateChannel => 'چینل شامل کریں۔';

  @override
  String get spacesChannelName => 'چینل کا نام';

  @override
  String get spacesChannelTopic => 'موضوع (اختیاری)';

  @override
  String get spacesDeleteChannel => 'چینل کو حذف کریں۔';

  @override
  String spacesDeleteChannelConfirm(String name) {
    return 'کیا آپ واقعی \"#$name\" کو حذف کرنا چاہتے ہیں؟';
  }

  @override
  String get spacesEditName => 'نام میں ترمیم کریں۔';

  @override
  String get spacesEditDescription => 'تفصیل میں ترمیم کریں۔';

  @override
  String spacesViewAllMembers(int count) {
    return 'تمام $count ممبران کو دیکھیں';
  }

  @override
  String spacesKickMemberTitle(String name) {
    return '$name کو لات ماریں۔';
  }

  @override
  String spacesBanMemberTitle(String name) {
    return '$name پر پابندی لگائیں۔';
  }

  @override
  String get spacesPromoteAdmin => 'ایڈمن کو ترقی دیں۔';

  @override
  String get spacesDemoteAdmin => 'ایڈمن کو ہٹا دیں۔';

  @override
  String get spacesInviteMember => 'ممبر کو مدعو کریں۔';

  @override
  String get spacesInviteMemberUserId =>
      'صارف کی شناخت (جیسے @user:server.com)';

  @override
  String get spacesSave => 'محفوظ کریں۔';

  @override
  String get settingsScreenshotProtection => 'اسکرین شاٹ پروٹیکشن';

  @override
  String get settingsScreenshotProtectionDesc =>
      'اسکرین شاٹس اور اسکرین ریکارڈنگ کو روکیں۔';

  @override
  String get chatSelfDestructTimer => 'خود کو تباہ کرنا';

  @override
  String get chatTimerPickerTitle => 'خود کو تباہ کرنے والا ٹائمر';

  @override
  String get chatTimerOff => 'آف';

  @override
  String get onChainNotificationsTitle => 'آن چین ایونٹس';

  @override
  String get onChainMarkAllRead => 'سب کو پڑھا ہوا نشان زد کریں۔';

  @override
  String get onChainNoNotifications => 'ابھی تک کوئی آن چین ایونٹس نہیں ہیں۔';

  @override
  String get onChainNoNotificationsDesc =>
      'سبسکرائب کردہ چینلز کے ایونٹس یہاں ظاہر ہوں گے۔';

  @override
  String get onChainViewDetails => 'تفصیلات دیکھیں';

  @override
  String get chatCommandHelp => '/help - تمام کمانڈز دکھائیں۔';

  @override
  String get chatCommandPrice => '/قیمت - ٹوکن کی قیمت حاصل کریں۔';

  @override
  String get chatCommandBalance => '/balance — والیٹ بیلنس دکھائیں۔';

  @override
  String get chatCommandChains =>
      '/chains — 236+ تعاون یافتہ زنجیروں کی فہرست بنائیں';

  @override
  String get chatMiniApps => 'ایپس';

  @override
  String get miniAppMarketTitle => 'منی ایپس';

  @override
  String get miniAppCategoryAll => 'تمام';

  @override
  String get miniAppSearch => 'ایپس تلاش کریں...';

  @override
  String get miniAppFeatured => 'نمایاں';

  @override
  String get miniAppAllApps => 'تمام ایپس';

  @override
  String get miniAppNoResults => 'کوئی ایپس نہیں ملی';

  @override
  String get slideToPayLabel => '→→→ تصدیق کے لیے سلائیڈ کریں۔';

  @override
  String get slideToPayConfirming => 'تصدیق کر رہا ہے...';

  @override
  String get redPacketBestLuck => 'بیسٹ لک';

  @override
  String get redPacketBestLuckCongrats => 'بیسٹ لک! آپ کو سب سے زیادہ مل گیا!';

  @override
  String redPacketStats(int claimed, int total) {
    return '$claimed / $total نے دعوی کیا۔';
  }

  @override
  String get redPacketStatsTotal => 'کل';

  @override
  String redPacketGrabbedViral(String amount, String token) {
    return '🧧 نے ایک سرخ پیکٹ پکڑا • $amount $token';
  }

  @override
  String get web3SearchHint => '@matrix:id • 0x والیٹ ایڈریس • name.eth';

  @override
  String get web3SearchPlaceholder => 'ID، بٹوے، یا ENS کے ذریعے تلاش کریں...';

  @override
  String get web3WalletAddress => 'بٹوے کا پتہ';

  @override
  String get web3AddressCopied => 'پتہ کاپی ہو گیا۔';

  @override
  String get web3Copy => 'کاپی';

  @override
  String get web3SendMessage => 'پیغام بھیجیں۔';

  @override
  String get web3SendToWallet => 'میسج والیٹ';

  @override
  String get web3WalletOnlyHint =>
      'اس ایڈریس کا ابھی تک کوئی N42 اکاؤنٹ نہیں ہے۔ ان کے شامل ہونے پر پیغام دیا جائے گا۔';

  @override
  String get web3NftAvatar => 'NFT اوتار';

  @override
  String get web3ResolveFailed => 'شناخت حل کرنے میں ناکام';

  @override
  String web3EnsNotFound(String name) {
    return 'ENS نام \"$name\" نہیں ملا';
  }

  @override
  String get web3NoN42AccountTitle => 'کوئی N42 اکاؤنٹ نہیں۔';

  @override
  String get web3NoN42AccountDesc =>
      'اس بٹوے کے پتہ کا ابھی تک کوئی N42 اکاؤنٹ نہیں ہے۔ شروع کرنے کے لیے آپ اپنا N42 دعوتی لنک ان کے ساتھ شیئر کر سکتے ہیں۔';

  @override
  String get web3ShareInvite => 'دعوت کا اشتراک کریں۔';

  @override
  String get nftPickerTitle => 'NFT اوتار منتخب کریں۔';

  @override
  String get nftPickerTabPopular => 'مقبول';

  @override
  String get nftPickerTabCustom => 'حسب ضرورت';

  @override
  String get nftPickerChain => 'زنجیر';

  @override
  String get nftPickerContract => 'معاہدہ کا پتہ';

  @override
  String get nftPickerTokenId => 'ٹوکن آئی ڈی';

  @override
  String get nftPickerVerifyOwnership =>
      'ملکیت کی تصدیق کریں اور پیش نظارہ کریں۔';

  @override
  String get nftPickerUseAsAvatar => 'اوتار کے طور پر استعمال کریں۔';

  @override
  String get nftPickerPreview => 'پیش نظارہ';

  @override
  String get nftPickerNotOwned => 'آپ اس NFT کے مالک نہیں ہیں۔';

  @override
  String get nftPickerInvalidTokenId => 'غلط ٹوکن ID';

  @override
  String get nftPickerEnterBoth => 'معاہدہ کا پتہ اور ٹوکن ID درج کریں۔';

  @override
  String get nftPickerInfoTitle => 'NFT اوتار - تصدیق شدہ آن چین';

  @override
  String get nftPickerInfoDesc =>
      'اپنے اوتار کے طور پر ایک NFT باندھیں۔ کوئی بھی آن چین ملکیت کی تصدیق کر سکتا ہے۔ N42 پر سونے کی انگوٹھی کے ساتھ ڈسپلے کیا گیا۔';

  @override
  String get nftPickerPopularCollections => 'مقبول مجموعے۔';

  @override
  String get nftPickerWalletHint =>
      '236+ زنجیروں میں اپنے NFTs کو خود بخود دریافت کرنے کے لیے اپنے N42 والیٹ کو جوڑیں۔';

  @override
  String get profileBindNftAvatar => 'NFT اوتار کو باندھیں۔';

  @override
  String get profileChangeAvatar => 'اوتار تبدیل کریں۔';

  @override
  String get groupTopics => 'موضوعات';

  @override
  String get groupTopicsEmpty => 'ابھی تک کوئی عنوان نہیں ہے۔';

  @override
  String get syncInProgress =>
      'پیغام کی سرگزشت کو مطابقت پذیر بنایا جا رہا ہے...';

  @override
  String get recoveryKeyReminderTitle => 'اپنے پیغامات کی حفاظت کریں۔';

  @override
  String get recoveryKeyReminderDesc =>
      'تمام آلات پر خفیہ کردہ پیغامات کو محفوظ طریقے سے مطابقت پذیر بنانے کے لیے ایک ریکوری کلید بنائیں';

  @override
  String get recoveryKeySetupNow => 'ابھی سیٹ اپ کریں۔';

  @override
  String get recoveryKeyRemindLater => 'مجھے بعد میں یاد دلائیں۔';

  @override
  String get channelReadOnly => 'اس چینل میں صرف ایڈمن ہی پوسٹ کر سکتے ہیں۔';

  @override
  String get channelSubscribers => 'سبسکرائبرز';

  @override
  String get channelVerified => 'تصدیق شدہ چینل';

  @override
  String get redPacketHistory => 'ریڈ پیکٹ کی تاریخ';

  @override
  String get redPacketSent => 'بھیجا';

  @override
  String get redPacketReceived => 'موصول ہوا۔';

  @override
  String get redPacketExpired => 'میعاد ختم';

  @override
  String get redPacketClaimed => 'دعویٰ کیا۔';

  @override
  String get redPacketInsufficientBalance => 'ناکافی توازن';

  @override
  String selfDestructCountdown(String time) {
    return '$time میں خود کو تباہ کرنا';
  }

  @override
  String get messageDestroyed => 'پیغام تباہ ہو گیا۔';

  @override
  String miniAppPermissionDenied(String permission) {
    return 'اجازت نامنظور: $permission';
  }

  @override
  String get aiSuggestionGasFee => 'گیس کی فیس کیا ہے؟';

  @override
  String get aiSuggestionDefi => 'ڈی فائی ابتدائی رہنما';

  @override
  String get aiSuggestionSecurity => 'معاہدے کی حفاظت کو کیسے چیک کریں۔';

  @override
  String get aiSuggestionBridge => 'کراس چین برجنگ';

  @override
  String get channelDiscoverTitle => 'چینلز دریافت کریں۔';

  @override
  String get channelDiscoverSearch => 'چینلز تلاش کریں...';

  @override
  String get channelJoin => 'شمولیت';

  @override
  String get channelJoined => 'شامل ہو گئے۔';

  @override
  String get channelCategory => 'زمرہ';

  @override
  String slowModeCooldown(int seconds) {
    return 'سست موڈ: ${seconds}s انتظار کریں۔';
  }

  @override
  String get addressCopyAction => 'ایڈریس کاپی کریں۔';

  @override
  String get addressSendMessage => 'پیغام بھیجیں۔';

  @override
  String get addressViewProfile => 'پروفائل دیکھیں';

  @override
  String get sendToAddress => 'بٹوے کے پتے پر بھیجیں۔';

  @override
  String get blocAuthSendVerificationCodeFailed =>
      'توثیقی کوڈ بھیجنے میں ناکام';

  @override
  String get blocAuthServerNoEmailPasswordReset =>
      'یہ سرور ای میل پاس ورڈ دوبارہ ترتیب دینے کی حمایت نہیں کرتا ہے۔';

  @override
  String get blocAuthResetPasswordFailed =>
      'پاس ورڈ دوبارہ ترتیب دینے میں ناکام';

  @override
  String get blocAuthChangePasswordFailed => 'پاس ورڈ تبدیل کرنے میں ناکام';

  @override
  String get blocAuthOldPasswordWrong => 'غلط موجودہ پاس ورڈ';

  @override
  String get blocAuthLoginCancelled => 'لاگ ان منسوخ ہو گیا۔';

  @override
  String get blocAuthGoogleLoginFailed => 'گوگل لاگ ان ناکام ہوگیا۔';

  @override
  String get blocAuthAppleLoginFailed => 'ایپل لاگ ان ناکام ہوگیا۔';

  @override
  String get blocAuthSsoLoginFailed => 'SSO لاگ ان ناکام ہو گیا۔';

  @override
  String get blocAuthFacebookLoginFailed => 'فیس بک لاگ ان ناکام ہوگیا۔';

  @override
  String get blocAuthTwitterLoginFailed => 'ٹویٹر لاگ ان ناکام ہو گیا۔';

  @override
  String get blocAuthWeChatLoginFailed => 'WeChat لاگ ان ناکام ہو گیا۔';

  @override
  String get blocAuthWeChatNotConfigured => 'WeChat لاگ ان کنفیگر نہیں ہے۔';

  @override
  String get blocAuthWeChatNotInstalled => 'براہ کرم پہلے WeChat انسٹال کریں۔';

  @override
  String get blocAuthPasswordWrong => 'غلط پاس ورڈ';

  @override
  String get blocAuthEmailAlreadyBound =>
      'یہ ای میل پہلے ہی کسی دوسرے اکاؤنٹ سے منسلک ہے۔';

  @override
  String get blocAuthChangeEmailFailed => 'ای میل تبدیل کرنے میں ناکام';

  @override
  String get blocAuthVerificationCodeInvalid =>
      'توثیقی کوڈ غلط ہے یا ختم ہو گیا ہے۔';

  @override
  String get blocAuthSessionExpired =>
      'سیشن ختم ہو گیا، براہ کرم دوبارہ لاگ ان کریں۔';

  @override
  String get blocAuthSessionIncomplete =>
      'سیشن کا ڈیٹا نامکمل ہے، براہ کرم دوبارہ لاگ ان کریں۔';
}
