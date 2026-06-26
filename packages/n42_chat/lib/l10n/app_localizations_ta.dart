// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class STa extends S {
  STa([String locale = 'ta']) : super(locale);

  @override
  String get commonRetry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get commonUnknownUser => 'தெரியாத பயனர்';

  @override
  String get transferWalletNotConnected => 'பணப்பை இணைக்கப்படவில்லை';

  @override
  String get chatCallServiceNotInitialized => 'அழைப்பு சேவை தொடங்கப்படவில்லை';

  @override
  String authLoginFailed(String error) {
    return 'உள்நுழைவு தோல்வி: $error';
  }

  @override
  String get chatCallBack => 'திரும்ப அழைக்கவும்';

  @override
  String get chatMissedVideoCall => 'தவறவிட்ட வீடியோ அழைப்பு';

  @override
  String get chatMissedVoiceCall => 'தவறிய குரல் அழைப்பு';

  @override
  String get chatCallNotAnswered => 'பதில் சொல்லவில்லை';

  @override
  String get chatCallDurationLabel => 'அழைப்பு காலம்';

  @override
  String get chatVoiceCallCancelled => 'குரல் அழைப்பு ரத்து செய்யப்பட்டது';

  @override
  String get chatVideoCallCancelled => 'வீடியோ அழைப்பு ரத்து செய்யப்பட்டது';

  @override
  String get commonImage => '[படம்]';

  @override
  String get chatVideo => '[வீடியோ]';

  @override
  String get chatVoice => '[குரல்]';

  @override
  String get commonFile => '[கோப்பு]';

  @override
  String get chatLocation => '[இடம்]';

  @override
  String get chatUnknownMessage => '[தெரியாத செய்தி]';

  @override
  String get commonDelete => 'நீக்கு';

  @override
  String get chatDeleteThisMessage => 'இந்த செய்தியை நீக்கவா?';

  @override
  String get chatMessageDeleted => 'செய்தி நீக்கப்பட்டது';

  @override
  String get profileNotLoggedIn => 'உள்நுழையவில்லை';

  @override
  String get chatMyLocation => 'எனது இருப்பிடம்';

  @override
  String get commonGroupChat => 'குழு அரட்டை';

  @override
  String get commonSearch => 'தேடு';

  @override
  String get commonCancel => 'ரத்து செய்';

  @override
  String get commonLoadFailed => 'ஏற்றுவதில் தோல்வி';

  @override
  String get commonMessages => 'செய்திகள்';

  @override
  String get commonContacts => 'தொடர்புகள்';

  @override
  String get commonMe => 'நான்';

  @override
  String get commonVoiceLoading => 'குரல் ஏற்றப்படுகிறது, பிறகு முயற்சிக்கவும்';

  @override
  String get commonVoiceToTextFailed => 'உரைக்கு குரல் கொடுக்க முடியவில்லை';

  @override
  String get commonConvertToText => 'உரைக்கு';

  @override
  String get chatCopy => 'நகலெடுக்கவும்';

  @override
  String get commonForward => 'முன்னோக்கி';

  @override
  String get commonUnfavorite => 'அன்ஃபாவ்';

  @override
  String get commonFavorite => 'பிடித்தது';

  @override
  String get settingsResend => 'மீண்டும் அனுப்பு';

  @override
  String get chatRecall => 'நினைவு கூருங்கள்';

  @override
  String get commonQuote => 'மேற்கோள்';

  @override
  String get commonRemind => 'நினைவூட்டு';

  @override
  String get chatCopied => 'நகலெடுக்கப்பட்டது';

  @override
  String get storySendMessageHint => 'செய்தி அனுப்பு';

  @override
  String get commonMicrophonePermissionRequired =>
      'மைக்ரோஃபோன் அனுமதியை அனுமதிக்கவும்';

  @override
  String get chatMicrophonePermissionDeniedPermanent =>
      'மைக்ரோஃபோன் அனுமதி மறுக்கப்பட்டது. குரல் செய்திகளைப் பயன்படுத்த, கணினி அமைப்புகளில் அதை இயக்கவும்.';

  @override
  String commonStartRecordingFailed(String error) {
    return 'பதிவைத் தொடங்குவதில் தோல்வி: $error';
  }

  @override
  String get commonRecordingTooShort => 'மிகக் குறுகிய பதிவு';

  @override
  String commonStopRecordingFailed(String error) {
    return 'பதிவு செய்வதை நிறுத்த முடியவில்லை: $error';
  }

  @override
  String get chatReleaseToCancel => 'ரத்து செய்ய விடுவிக்கவும்';

  @override
  String get chatReleaseToSend =>
      'அனுப்புவதற்கு விடுவிக்கவும், ரத்துசெய்ய மேலே ஸ்வைப் செய்யவும்';

  @override
  String get commonHoldToTalk => 'பேச பிடி';

  @override
  String get commonSend => 'அனுப்பு';

  @override
  String get commonAddFriend => 'நண்பரைச் சேர்க்கவும்';

  @override
  String get commonChatServiceNotConnected => 'அரட்டை சேவை இணைக்கப்படவில்லை';

  @override
  String contactUserNotFoundHint(String query) {
    return '\"$query\" பயனர் கிடைக்கவில்லை\n\nகுறிப்புகள்:\n• முழு பயனர் ஐடியை உள்ளிட முயற்சிக்கவும், எ.கா. @username:server.com\n• பயனர்பெயர் எழுத்துப்பிழையைச் சரிபார்க்கவும்';
  }

  @override
  String contactCreateChatFailed(String error) {
    return 'அரட்டையை உருவாக்க முடியவில்லை: $error';
  }

  @override
  String contactSearchFailed(String error) {
    return 'தேடல் தோல்வி: $error';
  }

  @override
  String get contactEnterUserIdOrUsername =>
      'தேடுவதற்கு பயனர் ஐடி அல்லது பயனர் பெயரை உள்ளிடவும்';

  @override
  String get contactSearching => 'தேடுகிறது...';

  @override
  String get contactSearchUserToChat => 'அரட்டையைத் தொடங்க பயனரைத் தேடுங்கள்';

  @override
  String get contactMatrixIdExample =>
      'நீங்கள் முழு மேட்ரிக்ஸ் ஐடியை உள்ளிடலாம்\nஎ.கா. @user:matrix.n42.network';

  @override
  String contactUserNotFound(String username) {
    return '\"$username\" பயனர் கிடைக்கவில்லை';
  }

  @override
  String get commonChat => 'அரட்டை';

  @override
  String get commonSettings => 'அமைப்புகள்';

  @override
  String get profileEditProfile => 'சுயவிவரத்தைத் திருத்து';

  @override
  String get authLogin => 'உள்நுழைக';

  @override
  String get commonCreateGroup => 'குழுவை உருவாக்கவும்';

  @override
  String get chatError => 'பிழை';

  @override
  String get commonTransfer => 'இடமாற்றம்';

  @override
  String get commonReceived => 'பெற்றது';

  @override
  String get commonRefunded => 'திருப்பி கொடுக்கப்பட்டது';

  @override
  String get commonExpired => 'காலாவதியானது';

  @override
  String get chatRedPacketGreeting => 'மனமார்ந்த வாழ்த்துக்கள்';

  @override
  String get commonN42RedPacket => 'N42 சிவப்பு பாக்கெட்';

  @override
  String get commonClaimed => 'உரிமை கோரப்பட்டது';

  @override
  String get commonAllClaimed => 'அனைவரும் உரிமை கோரினர்';

  @override
  String get chatReadAloud => 'உரக்கப் படியுங்கள்';

  @override
  String get chatReply => 'பதில்';

  @override
  String get commonEdit => 'திருத்தவும்';

  @override
  String get chatSelectForwardTarget => 'முன்னோக்கி இலக்கைத் தேர்ந்தெடுக்கவும்';

  @override
  String commonSendCount(int count) {
    return 'அனுப்பு($count)';
  }

  @override
  String contactN42Id(String id) {
    return 'N42 ஐடி: $id';
  }

  @override
  String get profileN42IdTitle => 'N42 ஐடி';

  @override
  String get profileN42Bean => 'N42 பீன்';

  @override
  String get contactFriendInfo => 'நண்பர் தகவல்';

  @override
  String get contactFriendInfoDesc =>
      'நண்பரின் கருத்து, தொலைபேசி, குறிச்சொற்கள், குறிப்புகள், புகைப்படங்கள் மற்றும் செட் அனுமதிகளைச் சேர்க்கவும்.';

  @override
  String get commonMoments => 'தருணங்கள்';

  @override
  String get commonSendMessage => 'செய்தி';

  @override
  String get contactAudioVideoCall => 'ஆடியோ/வீடியோ அழைப்பு';

  @override
  String get contactVideoChannel => 'வீடியோ சேனல்';

  @override
  String get contactRemark => 'குறிப்பு';

  @override
  String get contactRemarkName => 'குறிப்பு பெயர்';

  @override
  String get contactPhone => 'தொலைபேசி';

  @override
  String get contactTags => 'குறிச்சொற்கள்';

  @override
  String get contactNotes => 'குறிப்புகள்';

  @override
  String get contactPhotos => 'புகைப்படங்கள்';

  @override
  String get contactPermissions => 'அனுமதிகள்';

  @override
  String get contactChatMomentsEtc => 'அரட்டை, தருணங்கள், விளையாட்டு போன்றவை.';

  @override
  String get contactMoreInfo => 'மேலும் தகவல்';

  @override
  String get contactCommonGroups => 'பொதுவான குழுக்கள்';

  @override
  String get contactSource => 'ஆதாரம்';

  @override
  String get settingsNotificationSettings => 'அறிவிப்புகள்';

  @override
  String get settingsPrivacy => 'தனியுரிமை';

  @override
  String get settingsAppearance => 'தோற்றம்';

  @override
  String get settingsAbout => 'பற்றி';

  @override
  String get commonLogout => 'வெளியேறு';

  @override
  String get commonLogoutConfirm => 'நிச்சயமாக வெளியேற விரும்புகிறீர்களா?';

  @override
  String get commonSave => 'சேமிக்கவும்';

  @override
  String get profileNickname => 'புனைப்பெயர்';

  @override
  String get profileEnterNickname => 'புனைப்பெயரை உள்ளிடவும்';

  @override
  String get profileSignature => 'கையெழுத்து';

  @override
  String get profileAddSignature => 'கையொப்பத்தைச் சேர்க்கவும்';

  @override
  String get commonTakePhoto => 'புகைப்படம் எடு';

  @override
  String get profileChooseFromGallery => 'கேலரியில் இருந்து தேர்வு செய்யவும்';

  @override
  String profileSaveFailed(String error) {
    return 'சேமிக்க முடியவில்லை: $error';
  }

  @override
  String get authSecureDecentralizedChat =>
      'பாதுகாப்பான, பரவலாக்கப்பட்ட செய்தியிடல்';

  @override
  String get commonEndToEndEncryption => 'எண்ட்-டு-எண்ட் என்க்ரிப்ஷன்';

  @override
  String get authMessagesOnlyYouCanSee =>
      'உங்களுக்கும் பெறுநருக்கும் மட்டுமே தெரியும் செய்திகள்';

  @override
  String get authDecentralized => 'பரவலாக்கப்பட்டது';

  @override
  String get authBasedOnMatrix => 'மேட்ரிக்ஸ் திறந்த நெறிமுறையில் கட்டப்பட்டது';

  @override
  String get authWalletIntegration => 'வாலட் ஒருங்கிணைப்பு';

  @override
  String get authEasyCryptoTransfer => 'எளிதான கிரிப்டோகரன்சி பரிமாற்றங்கள்';

  @override
  String get authRegister => 'பதிவு செய்யவும்';

  @override
  String get authAgreeTerms =>
      'உள்நுழைவதன் மூலம், நீங்கள் ஒப்புக்கொள்கிறீர்கள்';

  @override
  String get authTermsOfService => 'சேவை விதிமுறைகள்';

  @override
  String get authAnd => ' மற்றும் ';

  @override
  String get authPrivacyPolicy => 'தனியுரிமைக் கொள்கை';

  @override
  String get authServerAddress => 'சேவையக முகவரி';

  @override
  String get authEnterServerAddress => 'சேவையக முகவரியை உள்ளிடவும்';

  @override
  String authConnectedTo(String serverName) {
    return '$serverName உடன் இணைக்கப்பட்டது';
  }

  @override
  String get authUsername => 'பயனர் பெயர்';

  @override
  String get authEnterUsername => 'பயனர் பெயரை உள்ளிடவும்';

  @override
  String get authUsernameOrEmail => 'பயனர்பெயர் அல்லது மின்னஞ்சல்';

  @override
  String get authEnterUsernameOrEmail =>
      'பயனர்பெயர் அல்லது மின்னஞ்சலை உள்ளிடவும்';

  @override
  String get authPassword => 'கடவுச்சொல்';

  @override
  String get authEnterPassword => 'கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get authRegisterAccount => 'பதிவு செய்யவும்';

  @override
  String get authForgotPassword => 'கடவுச்சொல் மறந்துவிட்டது';

  @override
  String get authOtherLoginMethods => 'பிற உள்நுழைவு முறைகள்';

  @override
  String get authCreateAccount => 'கணக்கை உருவாக்கவும்';

  @override
  String get authJoinN42Chat => 'அரட்டையைத் தொடங்க N42 அரட்டையில் சேரவும்';

  @override
  String get authUsernameHint => '3-20 எழுத்துகள், எழுத்துக்கள்/எண்கள்/_';

  @override
  String get authUsernameMinLength =>
      'பயனர்பெயரில் குறைந்தது 3 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get authUsernameMaxLength =>
      'பயனர்பெயரில் அதிகபட்சம் 20 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get authUsernameFormat =>
      'பயனர்பெயரில் எழுத்துக்கள், எண்கள் மற்றும் அடிக்கோடுகள் மட்டுமே இருக்க வேண்டும்';

  @override
  String get authPasswordHint => 'குறைந்தபட்சம் 8 எழுத்துகள்';

  @override
  String get commonPasswordMinLength =>
      'கடவுச்சொல் குறைந்தது 8 எழுத்துகளாக இருக்க வேண்டும்';

  @override
  String get authConfirmPassword => 'கடவுச்சொல்லை உறுதிப்படுத்தவும்';

  @override
  String get authFilled => 'நிரப்பப்பட்டது';

  @override
  String get authEnterInviteCode => 'அழைப்புக் குறியீட்டை உள்ளிடவும்';

  @override
  String get authAlreadyHaveAccount => 'ஏற்கனவே கணக்கு உள்ளதா?';

  @override
  String get authLoginNow => 'இப்போது உள்நுழைக';

  @override
  String get profileAvatar => 'அவதாரம்';

  @override
  String get profileStatus => 'நிலை';

  @override
  String get commonLoading => 'ஏற்றுகிறது...';

  @override
  String get conversationNoConversations => 'உரையாடல்கள் இல்லை';

  @override
  String get conversationTapToChat =>
      'அரட்டையைத் தொடங்க மேல் வலதுபுறத்தைத் தட்டவும்';

  @override
  String get conversationStartGroup => 'குழு அரட்டையைத் தொடங்கவும்';

  @override
  String get commonScan => 'ஸ்கேன் செய்யவும்';

  @override
  String get commonPayment => 'பணம் செலுத்துதல்';

  @override
  String commonFeatureComingSoon(String feature) {
    return '$feature விரைவில்';
  }

  @override
  String get conversationMarkAsRead => 'படித்ததாகக் குறி';

  @override
  String get commonUnmute => 'ஒலியடக்கவும்';

  @override
  String get commonMute => 'முடக்கு';

  @override
  String get conversationUnpin => 'அன்பின்';

  @override
  String get conversationPin => 'பின்';

  @override
  String get conversationDeleteConversation => 'உரையாடலை நீக்கு';

  @override
  String conversationDeleteConversationConfirm(String name) {
    return '\"$name\" உடனான உரையாடலை நீக்கவா?';
  }

  @override
  String get commonNoContacts => 'தொடர்புகள் இல்லை';

  @override
  String get contactAddFriendsToChat => 'அரட்டையடிக்க நண்பர்களைச் சேர்க்கவும்';

  @override
  String get contactNotFound => 'தொடர்பு கிடைக்கவில்லை';

  @override
  String get contactTryOtherKeywords =>
      'மற்ற முக்கிய வார்த்தைகள் அல்லது உலகளாவிய தேடலை முயற்சிக்கவும்';

  @override
  String get contactSearchResults => 'தேடல் முடிவுகள்';

  @override
  String get contactNewFriends => 'புதிய நண்பர்கள்';

  @override
  String get contactChatOnlyFriends => 'அரட்டை மட்டும் நண்பர்கள்';

  @override
  String get contactOfficialAccounts => 'அதிகாரப்பூர்வ கணக்குகள்';

  @override
  String get contactServiceAccounts => 'சேவை கணக்குகள்';

  @override
  String get contactEnterpriseContacts => 'நிறுவன தொடர்புகள்';

  @override
  String get contactRecommendToFriend => 'தொடர்பைப் பகிரவும்';

  @override
  String get commonSetRemark => 'குறிப்பை அமைக்கவும்';

  @override
  String get contactSendingCard => 'தொடர்பு அட்டையை அனுப்புகிறது...';

  @override
  String get commonFileLabel => 'கோப்பு';

  @override
  String get commonLocationLabel => 'இடம்';

  @override
  String contactRecommendFailed(String error) {
    return 'பரிந்துரைக்கப்படவில்லை: $error';
  }

  @override
  String get profileEnterRemark => 'குறிப்பை உள்ளிடவும்';

  @override
  String get contactOpeningChat => 'அரட்டையைத் திறக்கிறது...';

  @override
  String contactOpenChatFailed(String error) {
    return 'அரட்டையைத் திறக்க முடியவில்லை: $error';
  }

  @override
  String get contactAddContact => 'தொடர்பைச் சேர்க்கவும்';

  @override
  String get contactEnterUserId => 'பயனர் ஐடியை உள்ளிடவும்';

  @override
  String get contactNoFriendRequests => 'நண்பர் கோரிக்கைகள் இல்லை';

  @override
  String get commonAccept => 'ஏற்றுக்கொள்';

  @override
  String get commonReject => 'நிராகரிக்கவும்';

  @override
  String get commonNoGroups => 'குழுக்கள் இல்லை';

  @override
  String get contactSelectFriendToRecommend =>
      'பரிந்துரைக்க ஒரு நண்பரைத் தேர்ந்தெடுக்கவும்';

  @override
  String get commonSearchContacts => 'தொடர்புகளைத் தேடுங்கள்';

  @override
  String get contactNoContactsFound => 'தொடர்புகள் எதுவும் இல்லை';

  @override
  String get favoriteYesterday => 'நேற்று';

  @override
  String get chatJustNow => 'இப்போதுதான்';

  @override
  String get profileOnline => 'ஆன்லைன்';

  @override
  String get profileOffline => 'ஆஃப்லைன்';

  @override
  String get searchContactsGroupsMessages =>
      'தொடர்புகள், குழுக்கள் மற்றும் செய்திகளைத் தேடுங்கள்';

  @override
  String get searchError => 'தேடல் பிழை';

  @override
  String get chatSearchHint => 'தேடு';

  @override
  String get searchHistory => 'தேடல் வரலாறு';

  @override
  String get commonClear => 'தெளிவு';

  @override
  String get commonAll => 'அனைத்து';

  @override
  String get searchGroups => 'குழுக்கள்';

  @override
  String get searchNoResults => 'முடிவுகள் இல்லை';

  @override
  String commonGroupMembers(int count) {
    return 'உறுப்பினர்கள் ($count)';
  }

  @override
  String get groupMembersTitle => 'குழு உறுப்பினர்கள்';

  @override
  String get groupViewAll => 'அனைத்தையும் பார்க்கவும்';

  @override
  String get groupOwner => 'உரிமையாளர்';

  @override
  String get groupAdmin => 'நிர்வாகி';

  @override
  String get groupInvite => 'அழைக்கவும்';

  @override
  String get commonGroupAnnouncement => 'குழு அறிவிப்பு';

  @override
  String get commonNotSet => 'அமைக்கப்படவில்லை';

  @override
  String get groupDescription => 'குழு விளக்கம்';

  @override
  String get groupPublicGroup => 'பொது குழு';

  @override
  String get commonClearChatHistory => 'அரட்டை வரலாற்றை அழிக்கவும்';

  @override
  String get commonDissolveGroup => 'குழுவை கலைக்கவும்';

  @override
  String get commonLeaveGroup => 'குழுவிலிருந்து வெளியேறு';

  @override
  String get groupChangeGroupName => 'குழுவின் பெயரை மாற்றவும்';

  @override
  String get commonEnterGroupName => 'குழுவின் பெயரை உள்ளிடவும்';

  @override
  String get commonConfirm => 'உறுதிப்படுத்தவும்';

  @override
  String get groupEnterGroupDescription => 'குழு விளக்கத்தை உள்ளிடவும்';

  @override
  String get groupPublish => 'வெளியிடு';

  @override
  String get chatClearHistoryConfirm =>
      'அனைத்து அரட்டை வரலாற்றையும் அழிக்கவா? இதை செயல்தவிர்க்க முடியாது.';

  @override
  String get chatClearAction => 'தெளிவு';

  @override
  String get commonChatHistoryCleared => 'அரட்டை வரலாறு அழிக்கப்பட்டது';

  @override
  String get commonDissolve => 'கரைக்கவும்';

  @override
  String get groupQrCode => 'குழு QR குறியீடு';

  @override
  String get commonSearchChatHistory => 'அரட்டை வரலாற்றைத் தேடுங்கள்';

  @override
  String get groupIdCopied => 'குழு ஐடி நகலெடுக்கப்பட்டது';

  @override
  String get transferEnterOrPasteAddress =>
      'வாலட் முகவரியை உள்ளிடவும் அல்லது ஒட்டவும்';

  @override
  String get transferSelectToken => 'டோக்கனைத் தேர்ந்தெடுக்கவும்';

  @override
  String get commonTransferAmount => 'பரிமாற்ற தொகை';

  @override
  String get transferAvailable => 'கிடைக்கும்';

  @override
  String get transferMemoOptional => 'மெமோ (விரும்பினால்)';

  @override
  String get transferConfirmTransfer => 'பரிமாற்றத்தை உறுதிப்படுத்தவும்';

  @override
  String get transferAddressVerified => 'முகவரி சரிபார்க்கப்பட்டது';

  @override
  String transferAvailableBalance(String balance, String symbol) {
    return 'கிடைக்கும்: $balance $symbol';
  }

  @override
  String get commonEnterAmount => 'தொகையை உள்ளிடவும்';

  @override
  String get commonRedPacketCountMin => 'குறைந்தது 1 சிவப்பு பாக்கெட் தேவை';

  @override
  String get commonViewRedPacketDetails => 'சிவப்பு பாக்கெட் விவரங்களைக் காண்க';

  @override
  String get commonEnterTransferAmount => 'பரிமாற்றத் தொகையை உள்ளிடவும்';

  @override
  String get commonTransferTo => 'இடமாற்றம்';

  @override
  String commonFromSender(String name, Object senderName) {
    return '$name இலிருந்து';
  }

  @override
  String get commonConfirmReceive => 'ரசீதை உறுதிப்படுத்தவும்';

  @override
  String get groupProfile => 'குழு தகவல்';

  @override
  String get groupRemoveMember => 'குழுவிலிருந்து நீக்கு';

  @override
  String get commonRemove => 'அகற்று';

  @override
  String get profileClearStatus => 'தெளிவான நிலை';

  @override
  String get profileClearStatusConfirm => 'தற்போதைய நிலையை அழிக்கவா?';

  @override
  String get profileStatusCleared => 'நிலை அழிக்கப்பட்டது';

  @override
  String get profileUserNotExist => 'பயனர் இல்லை';

  @override
  String get profileUserIdCopied => 'பயனர் ஐடி நகலெடுக்கப்பட்டது';

  @override
  String get commonReport => 'அறிக்கை';

  @override
  String get profileQrCode => 'QR குறியீடு';

  @override
  String get profileAvatarUpdated => 'அவதார் புதுப்பிக்கப்பட்டது';

  @override
  String commonSelectImageFailed(String error) {
    return 'படத்தைத் தேர்ந்தெடுக்க முடியவில்லை: $error';
  }

  @override
  String get profileChangeName => 'பெயரை மாற்றவும்';

  @override
  String get profileMale => 'ஆண்';

  @override
  String get profileFemale => 'பெண்';

  @override
  String chatFeatureInDev(String feature) {
    return '$feature அம்சம் வளர்ச்சியில் உள்ளது...';
  }

  @override
  String profileSaveAddressFailed(String error) {
    return 'முகவரியைச் சேமிப்பதில் தோல்வி: $error';
  }

  @override
  String get profileAddNew => 'சேர்';

  @override
  String get profileAddAddress => 'முகவரியைச் சேர்க்கவும்';

  @override
  String get profileAddressAdded => 'முகவரி சேர்க்கப்பட்டது';

  @override
  String get profileAddressUpdated => 'முகவரி புதுப்பிக்கப்பட்டது';

  @override
  String get profileDeleteAddress => 'முகவரியை நீக்கு';

  @override
  String get profileAddressDeleted => 'முகவரி நீக்கப்பட்டது';

  @override
  String profileSaveInvoiceFailed(String error) {
    return 'விலைப்பட்டியல் சேமிப்பதில் தோல்வி: $error';
  }

  @override
  String get profileMyInvoices => 'எனது இன்வாய்ஸ்கள்';

  @override
  String get profileAddInvoice => 'விலைப்பட்டியல் சேர்க்கவும்';

  @override
  String get profileInvoiceAdded => 'விலைப்பட்டியல் சேர்க்கப்பட்டது';

  @override
  String get profileInvoiceUpdated => 'இன்வாய்ஸ் புதுப்பிக்கப்பட்டது';

  @override
  String get profileDeleteInvoice => 'விலைப்பட்டியலை நீக்கு';

  @override
  String get profileInvoiceDeleted => 'விலைப்பட்டியல் நீக்கப்பட்டது';

  @override
  String get profilePersonal => 'தனிப்பட்ட';

  @override
  String get groupSelectAtLeastOne =>
      'குறைந்தபட்சம் ஒரு உறுப்பினரையாவது தேர்ந்தெடுக்கவும்';

  @override
  String get chatFileNotExist => 'கோப்பு இல்லை';

  @override
  String chatSendFailed(String error) {
    return 'அனுப்ப முடியவில்லை: $error';
  }

  @override
  String get chatCannotOpenBrowser => 'உலாவியைத் திறக்க முடியவில்லை';

  @override
  String chatSelectFileFailed(String error) {
    return 'கோப்பைத் தேர்ந்தெடுக்க முடியவில்லை: $error';
  }

  @override
  String settingsSetupFailed(String error) {
    return 'அமைவு தோல்வி: $error';
  }

  @override
  String get transferEnterValidAmount => 'சரியான தொகையை உள்ளிடவும்';

  @override
  String get commonAddressCopied => 'முகவரி நகலெடுக்கப்பட்டது';

  @override
  String favoriteOpenItem(String content) {
    return 'திற: $content';
  }

  @override
  String get favoriteDeleted => 'நீக்கப்பட்டது';

  @override
  String get profileWallet => 'பணப்பை';

  @override
  String get chatRecording => 'பதிவு செய்தல்';

  @override
  String get chatInvalidVideoUrl => 'தவறான வீடியோ URL';

  @override
  String get chatDownloadFile => 'கோப்பைப் பதிவிறக்கவும்';

  @override
  String get chatClearChatHistoryTitle => 'அரட்டை வரலாற்றை அழிக்கவும்';

  @override
  String get chatVideoCall => 'வீடியோ அழைப்பு';

  @override
  String get commonVoiceCall => 'குரல் அழைப்பு';

  @override
  String get callLeaveMeeting => 'மீட்டிங் லீவ்';

  @override
  String get chatDetails => 'அரட்டை விவரங்கள்';

  @override
  String get chatViewAllGroupMembers => 'அனைத்து உறுப்பினர்களையும் பார்க்கவும்';

  @override
  String get chatGroupName => 'குழுவின் பெயர்';

  @override
  String get chatGroupNameUpdated => 'குழுவின் பெயர் புதுப்பிக்கப்பட்டது';

  @override
  String get chatUpdateFailed => 'புதுப்பிப்பு தோல்வியடைந்தது';

  @override
  String get chatNoPermissionToModify => 'மாற்ற உங்களுக்கு அனுமதி இல்லை';

  @override
  String get chatGroupManagement => 'குழு மேலாண்மை';

  @override
  String get chatMyNicknameInGroup => 'குழுவில் எனது புனைப்பெயர்';

  @override
  String get chatPinChat => 'பின் அரட்டை';

  @override
  String get chatStrongReminder => 'வலுவான நினைவூட்டல்';

  @override
  String get chatSetChatBackground => 'அரட்டை பின்னணியை அமைக்கவும்';

  @override
  String get chatUnknownFile => 'தெரியாத கோப்பு';

  @override
  String get chatDownload => 'பதிவிறக்கவும்';

  @override
  String get chatInvalidLocation => 'தவறான இடம்';

  @override
  String get chatTapToCancel => 'ரத்துசெய்ய தட்டவும்';

  @override
  String chatCaptureFailed(Object error) {
    return 'பிடிப்பதில் தோல்வி: $error';
  }

  @override
  String get chatProcessingVideo => 'வீடியோவைச் செயலாக்குகிறது...';

  @override
  String get chatVideoFileNotExist => 'வீடியோ கோப்பு இல்லை';

  @override
  String get chatVideoDataEmpty => 'வீடியோ தரவு காலியாக உள்ளது';

  @override
  String get chatVideoTooLarge =>
      'வீடியோ அளவு 100MB ஐ விட அதிகமாக இருக்கக்கூடாது';

  @override
  String get chatSendingVideo => 'வீடியோவை அனுப்புகிறது...';

  @override
  String chatSendVideoFailed(Object error) {
    return 'வீடியோவை அனுப்புவதில் தோல்வி: $error';
  }

  @override
  String get chatImageFileNotExist => 'படக் கோப்பு இல்லை';

  @override
  String get commonImageDataEmpty => 'படத்தின் தரவு காலியாக உள்ளது';

  @override
  String get chatSendingImage => 'படத்தை அனுப்புகிறது...';

  @override
  String chatSendImageFailed(Object error) {
    return 'படத்தை அனுப்புவதில் தோல்வி: $error';
  }

  @override
  String get chatSendLocation => 'இருப்பிடத்தை அனுப்பு';

  @override
  String get chatSelectLocationAndSend => 'இடத்தைத் தேர்ந்தெடுத்து அனுப்பவும்';

  @override
  String get chatShareRealTimeLocation => 'நிகழ்நேர இருப்பிடத்தைப் பகிரவும்';

  @override
  String get chatShareLocationForOneHour =>
      'நிகழ்நேர இருப்பிடத்தை நண்பருடன் 1 மணிநேரம் பகிரவும்';

  @override
  String get chatLocationSent => 'இடம் அனுப்பப்பட்டது';

  @override
  String get chatSelectMessages => 'செய்திகளைத் தேர்ந்தெடுக்கவும்';

  @override
  String chatSelectedCount(int count) {
    return 'தேர்ந்தெடுக்கப்பட்ட $count';
  }

  @override
  String get chatSelectAll => 'அனைத்தையும் தேர்ந்தெடுக்கவும்';

  @override
  String chatGroupChatCount(int count) {
    return 'குழு அரட்டை($count)';
  }

  @override
  String get chatPrivateChat => 'தனிப்பட்ட அரட்டை';

  @override
  String get chatNoMessages => 'செய்திகள் இல்லை';

  @override
  String get chatSendFirstMessage =>
      'அரட்டையைத் தொடங்க முதல் செய்தியை அனுப்பவும்';

  @override
  String get chatEncryptionNotice =>
      'இந்த அரட்டை எண்ட்-டு-எண்ட் என்க்ரிப்ட் செய்யப்பட்டுள்ளது. நீங்களும் பெறுநரும் மட்டுமே செய்திகளைப் படிக்க முடியும்.';

  @override
  String get chatMultiForward => 'முன்னோக்கி';

  @override
  String get chatCollect => 'சேகரிக்கவும்';

  @override
  String get chatNoMembers => 'உறுப்பினர்கள் இல்லை';

  @override
  String get chatMemberNotFound => 'உறுப்பினர் கிடைக்கவில்லை';

  @override
  String get chatVoiceFileNotExist => 'குரல் கோப்பு இல்லை';

  @override
  String get chatVoiceFileEmpty => 'குரல் கோப்பு காலியாக உள்ளது';

  @override
  String get chatSendingVoice => 'குரல் அனுப்புகிறது...';

  @override
  String chatSendVoiceFailed(Object error) {
    return 'குரலை அனுப்புவதில் தோல்வி: $error';
  }

  @override
  String get chatMessageForwarded => 'செய்தி அனுப்பப்பட்டது';

  @override
  String chatForwardFailed(Object error) {
    return 'முன்னனுப்ப முடியவில்லை: $error';
  }

  @override
  String get chatUnfavorited => 'விருப்பமில்லாதது';

  @override
  String get chatFavorited => 'பிடித்தது';

  @override
  String get chatReactionAdded => 'எதிர்வினை சேர்க்கப்பட்டது';

  @override
  String get chatReactionRemoved => 'எதிர்வினை அகற்றப்பட்டது';

  @override
  String get chatFailedMessageDeleted => 'தோல்வியுற்ற செய்தி நீக்கப்பட்டது';

  @override
  String get chatDeleteMessages => 'செய்திகளை நீக்கு';

  @override
  String chatDeleteMessagesConfirm(Object count) {
    return '$count செய்திகளை நிச்சயமாக நீக்க விரும்புகிறீர்களா?';
  }

  @override
  String chatNoteOtherMessages(Object count) {
    return 'குறிப்பு: $count செய்திகள் பிறரிடமிருந்து வந்தவை, உங்களுக்காக மட்டுமே நீக்கப்படும்.';
  }

  @override
  String chatMyMessagesWillBeRecalled(Object count) {
    return 'உங்களிடமிருந்து வரும் $count செய்திகள் அனைவருக்கும் திரும்ப அழைக்கப்படும்.';
  }

  @override
  String chatRecalledCount(Object count, Object localCount) {
    return 'நினைவுபடுத்தப்பட்ட $count செய்திகள், $localCount உங்களுக்காக மட்டுமே நீக்கப்பட்டது';
  }

  @override
  String chatRecalledMessages(Object count) {
    return 'நினைவுபடுத்தப்பட்ட $count செய்திகள்';
  }

  @override
  String chatDeletedLocally(Object count) {
    return '$count செய்திகள் உங்களுக்காக மட்டுமே நீக்கப்பட்டன';
  }

  @override
  String chatForwardedCount(Object count) {
    return 'அனுப்பப்பட்ட $count செய்திகள்';
  }

  @override
  String chatForwardComplete(Object failed, Object success) {
    return 'முன்னோக்கி முடிந்தது: $success வெற்றி பெற்றது, $failed தோல்வியடைந்தது';
  }

  @override
  String get chatRemindOnlyInGroup =>
      'நினைவூட்டல் அம்சம் குழு அரட்டையில் மட்டுமே கிடைக்கும்';

  @override
  String get chatOnlyTextSearchable => 'குறுஞ்செய்திகளை மட்டுமே தேட முடியும்';

  @override
  String chatSearchFor(Object text) {
    return '\"$text\" தேடு';
  }

  @override
  String get chatBaiduSearch => 'பைடு தேடல்';

  @override
  String get chatGoogleSearch => 'கூகுள் தேடல்';

  @override
  String get chatBingSearch => 'பிங் தேடல்';

  @override
  String get chatCalling => 'அழைக்கிறது...';

  @override
  String get chatRinging => 'ஒலிக்கிறது...';

  @override
  String get chatInCall => 'அழைப்பில்';

  @override
  String commonFeatureInDevelopment(String feature) {
    return '$feature அம்சம் வளர்ச்சியில் உள்ளது...';
  }

  @override
  String chatCollectMessages(Object count) {
    return 'சேகரிக்கப்பட்ட $count செய்திகள்';
  }

  @override
  String commonMemberCount(int count) {
    return '$count உறுப்பினர்கள்';
  }

  @override
  String groupDone(int count) {
    return 'முடிந்தது($count)';
  }

  @override
  String get profileServices => 'சேவைகள்';

  @override
  String get commonFavorites => 'பிடித்தவை';

  @override
  String get profileOrdersAndCards => 'ஆர்டர்கள் & கார்டுகள்';

  @override
  String get profileStickers => 'ஸ்டிக்கர்கள்';

  @override
  String profileStatusSetTo(String status) {
    return 'நிலை அமைக்கப்பட்டுள்ளது: $status';
  }

  @override
  String get profileAvatarUploadFailed => 'அவதார் பதிவேற்றம் தோல்வியடைந்தது';

  @override
  String get profilePersonalProfile => 'தனிப்பட்ட சுயவிவரம்';

  @override
  String get profileName => 'பெயர்';

  @override
  String get profileGender => 'பாலினம்';

  @override
  String get profileRegion => 'பிராந்தியம்';

  @override
  String get commonMyQrCode => 'எனது QR குறியீடு';

  @override
  String get profilePoke => 'குத்து';

  @override
  String get profileRingtone => 'ரிங்டோன்';

  @override
  String get profileDefaultRingtone => 'இயல்புநிலை ரிங்டோன்';

  @override
  String get profileMyAddresses => 'எனது முகவரிகள்';

  @override
  String profileGenderSetTo(String gender) {
    return 'பாலினம் இதற்கு அமைக்கப்பட்டுள்ளது: $gender';
  }

  @override
  String get profileSelectRegion => 'பிராந்தியத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get profileSelectCity => 'நகரத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String profileRegionSetTo(String region) {
    return 'மண்டலம் அமைக்கப்பட்டுள்ளது: $region';
  }

  @override
  String get profileSetPoke => 'போக் அமைக்கவும்';

  @override
  String get profileFriendPokedMe => 'நண்பர் என்னைக் குத்தினார்';

  @override
  String get profileExample => 'உதாரணம்';

  @override
  String get profileOnTheShoulder => ' தோளில்';

  @override
  String get profilePokeCleared => 'போக் அழிக்கப்பட்டது';

  @override
  String profilePokeSetTo(String suffix) {
    return 'போக் அமைக்கப்பட்டது: poked me$suffix';
  }

  @override
  String get profileEditSignature => 'கையொப்பத்தைத் திருத்தவும்';

  @override
  String get profileIntroduceYourself => 'உங்களை அறிமுகப்படுத்த ஒரு வாக்கியம்';

  @override
  String get profileSignatureCleared => 'கையெழுத்து அழிக்கப்பட்டது';

  @override
  String get profileSignatureUpdated => 'கையொப்பம் புதுப்பிக்கப்பட்டது';

  @override
  String get profileScanToAddFriend =>
      'என்னை நண்பராகச் சேர்க்க மேலே உள்ள QR குறியீட்டை ஸ்கேன் செய்யவும்';

  @override
  String profileRingtoneSetTo(String ringtone) {
    return 'ரிங்டோன் அமைக்கப்பட்டுள்ளது: $ringtone';
  }

  @override
  String commonConfirmDissolveGroup(String name) {
    return '\"$name\" ஐ நிச்சயமாக கலைக்க விரும்புகிறீர்களா? இந்தச் செயலைச் செயல்தவிர்க்க முடியாது.';
  }

  @override
  String get authEnterValidServerAddress => 'சரியான சர்வர் முகவரியை உள்ளிடவும்';

  @override
  String get authEnterServerAddressFirst =>
      'முதலில் சர்வர் முகவரியை உள்ளிடவும்';

  @override
  String get authPasskeyRequiresServer =>
      'கடவுச்சொல் உள்நுழைவுக்கு சேவையக ஆதரவு தேவை';

  @override
  String get authLoginAgreement =>
      'உள்நுழைவதன் மூலம், நீங்கள் ஒப்புக்கொள்கிறீர்கள் ';

  @override
  String get authPleaseAgreeToTerms =>
      'சேவை விதிமுறைகள் மற்றும் தனியுரிமைக் கொள்கையைப் படித்து ஒப்புக்கொள்ளவும்';

  @override
  String get authRegisterFailed => 'பதிவு தோல்வியடைந்தது';

  @override
  String get commonReenterPassword => 'கடவுச்சொல்லை மீண்டும் உள்ளிடவும்';

  @override
  String get commonPasswordsDoNotMatch => 'கடவுச்சொற்கள் பொருந்தவில்லை';

  @override
  String get authInviteCodeBuiltIn => 'அழைப்புக் குறியீடு (உள்ளமைக்கப்பட்ட)';

  @override
  String get authInviteCodeBuiltInNote =>
      'அழைப்புக் குறியீடு உள்ளமைந்துள்ளது, பொதுவாக மாற்ற வேண்டிய அவசியமில்லை';

  @override
  String get authIHaveReadAndAgree => 'படித்துவிட்டு ஒப்புக்கொண்டேன் ';

  @override
  String get mainStartGroupChat => 'குழு அரட்டையைத் தொடங்கவும்';

  @override
  String get mainAddFriends => 'நண்பர்களைச் சேர்க்கவும்';

  @override
  String get mainPaymentAndCollection => 'பணம் செலுத்துதல்';

  @override
  String contactCount(int count) {
    return '$count தொடர்புகள்';
  }

  @override
  String get contactAddToHomeScreen => 'முகப்புத் திரையில் சேர்க்கவும்';

  @override
  String contactRecommendedCardTo(String contact, String recipient) {
    return '$contact கார்டு $recipient க்கு பரிந்துரைக்கப்படுகிறது';
  }

  @override
  String get contactEnterRemarkName => 'குறிப்பு பெயரை உள்ளிடவும்';

  @override
  String contactRemarkSetTo(String remark) {
    return 'கருத்து இவ்வாறு அமைக்கப்பட்டது: $remark';
  }

  @override
  String contactAcceptedFriendRequest(String name) {
    return '$name இன் நண்பர் கோரிக்கை ஏற்கப்பட்டது';
  }

  @override
  String contactRejectedFriendRequest(String name) {
    return '$name இன் நண்பர் கோரிக்கை நிராகரிக்கப்பட்டது';
  }

  @override
  String get commonGroupInvites => 'குழு அழைப்புகள்';

  @override
  String commonMyGroups(int count) {
    return 'எனது குழுக்கள் ($count)';
  }

  @override
  String get commonInvitedToJoinGroup => 'குழுவில் சேர அழைக்கப்பட்டுள்ளார்';

  @override
  String commonConfirmLeaveGroup(String name) {
    return 'நிச்சயமாக \"$name\" ஐ விட்டு வெளியேற விரும்புகிறீர்களா?';
  }

  @override
  String get commonLeave => 'கிளம்பு';

  @override
  String get commonRecallThisMessage => 'இந்த செய்தியை நினைவுபடுத்தவா?';

  @override
  String get commonSavedToGallery => 'கேலரியில் சேமிக்கப்பட்டது';

  @override
  String get commonFailedToSave => 'சேமிக்க முடியவில்லை';

  @override
  String get chatSaving => 'சேமிக்கிறது...';

  @override
  String get commonShare => 'பகிரவும்';

  @override
  String get chatSaveToGallery => 'கேலரியில் சேமிக்கவும்';

  @override
  String chatDownloadFailed(String code) {
    return 'பதிவிறக்கம் தோல்வி: $code';
  }

  @override
  String commonShareFailed(String error) {
    return 'பகிர்வு தோல்வி: $error';
  }

  @override
  String get chatFailedToLoadImage => 'படத்தை ஏற்ற முடியவில்லை';

  @override
  String get chatVideoRecordingFailed => 'வீடியோ பதிவு தோல்வி';

  @override
  String get profileRedPacket => 'சிவப்பு பாக்கெட்';

  @override
  String get commonMusic => 'இசை';

  @override
  String get commonCoupon => 'கூப்பன்';

  @override
  String get commonGift => 'பரிசு';

  @override
  String get commonPoll => 'கருத்துக்கணிப்பு';

  @override
  String get favoriteText => 'உரை';

  @override
  String get favoriteLinkLabel => 'இணைப்பு';

  @override
  String get favoriteNote => 'குறிப்பு';

  @override
  String get favoriteMyNotes => 'எனது குறிப்புகள்';

  @override
  String get favoriteToday => 'இன்று';

  @override
  String favoriteDaysAgoText(int count) {
    return '$count நாட்களுக்கு முன்பு';
  }

  @override
  String favoriteDateFormat(int month, int day) {
    return '$month/$day';
  }

  @override
  String get favoriteNoFavorites => 'இன்னும் பிடித்தவை இல்லை';

  @override
  String get favoriteLongPressToFavorite =>
      'பிடித்த செய்தியை நீண்ட நேரம் அழுத்தவும்';

  @override
  String get favoriteNewNote => 'புதிய குறிப்பு';

  @override
  String get favoriteLink => 'பிடித்த இணைப்பு';

  @override
  String get favoriteEditTags => 'குறிச்சொற்களைத் திருத்து';

  @override
  String get favoriteDeleteFavorite => 'பிடித்ததை நீக்கு';

  @override
  String get favoriteDeleteFavoriteConfirm =>
      'பிடித்தமானதை நிச்சயமாக நீக்க விரும்புகிறீர்களா?';

  @override
  String get favoriteNoSearchResultsFound => 'முடிவுகள் எதுவும் கிடைக்கவில்லை';

  @override
  String get commonSendRedPacket => 'சிவப்பு பாக்கெட் அனுப்பவும்';

  @override
  String get transferAmount => 'தொகை';

  @override
  String get commonRedPacketCover => 'சிவப்பு பாக்கெட் கவர்';

  @override
  String get commonRedPacketType => 'சிவப்பு பாக்கெட் வகை';

  @override
  String get commonNormalRedPacket => 'இயல்பானது';

  @override
  String get commonLuckyRedPacket => 'அதிர்ஷ்டசாலி';

  @override
  String get commonRedPacketCount => 'சிவப்பு பாக்கெட் எண்ணிக்கை';

  @override
  String get commonPieces => 'துண்டுகள்';

  @override
  String get commonPutMoneyInRedPacket =>
      'சிவப்பு பாக்கெட்டில் பணத்தை வைக்கவும்';

  @override
  String get commonRedPacketRefundNotice =>
      'உரிமை கோரப்படாத சிவப்பு பாக்கெட்டுகள் 24 மணிநேரத்திற்குப் பிறகு திருப்பித் தரப்படும்';

  @override
  String get commonOpenRedPacket => 'திற';

  @override
  String get commonRedPacketAllClaimed =>
      'சிவப்பு பாக்கெட் அனைத்தும் கோரப்பட்டது';

  @override
  String get commonRedPacketExpired => 'சிவப்பு பாக்கெட் காலாவதியானது';

  @override
  String get commonAddTransferNote => 'பரிமாற்ற குறிப்பைச் சேர்க்கவும்';

  @override
  String get commonYuan => 'CNY';

  @override
  String get commonReplyWithEmoji => 'இந்த ஈமோஜியுடன் பதிலளிக்கவும்';

  @override
  String get contactEditRemark => 'குறிப்பு திருத்தவும்';

  @override
  String get contactSetPermissions => 'அனுமதிகளை அமைக்கவும்';

  @override
  String get profileAddToBlacklist => 'தடுப்புப்பட்டியலில் சேர்க்கவும்';

  @override
  String get contactDeleteContact => 'தொடர்பை நீக்கு';

  @override
  String contactDeleteContactConfirm(String name) {
    return '$name ஐ நிச்சயமாக நீக்க விரும்புகிறீர்களா?';
  }

  @override
  String get transferTitle => 'இடமாற்றம்';

  @override
  String get transferReceiverAddressLabel => 'பெறுநரின் முகவரி';

  @override
  String get transferSelectTokenLabel => 'டோக்கனைத் தேர்ந்தெடுக்கவும்';

  @override
  String get transferAmountLabel => 'பரிமாற்ற தொகை';

  @override
  String get transferMemoLabel => 'மெமோ (விரும்பினால்)';

  @override
  String get transferAddMemoHint => 'மெமோவைச் சேர்க்கவும்';

  @override
  String get transferSendPaymentRequest => 'கட்டண கோரிக்கையை அனுப்பவும்';

  @override
  String get transferQrCodeGenerateFailed =>
      'QR குறியீடு உருவாக்கம் தோல்வியடைந்தது';

  @override
  String get transferScanQrToPayMe =>
      'எனக்கு பணம் செலுத்த QR குறியீட்டை ஸ்கேன் செய்யவும்';

  @override
  String get transferMyWalletAddress => 'எனது பணப்பையின் முகவரி';

  @override
  String get transferCreatePaymentRequest => 'கட்டண கோரிக்கையை உருவாக்கவும்';

  @override
  String profileN42IdLabel(String id) {
    return 'N42 ஐடி: $id';
  }

  @override
  String get commonRedPacketDefaultGreeting => 'மனமார்ந்த வாழ்த்துக்கள்';

  @override
  String commonSenderRedPacket(String name) {
    return '$name சிவப்பு பாக்கெட்';
  }

  @override
  String get transferEnterValidAddress => 'சரியான முகவரியை உள்ளிடவும்';

  @override
  String get transferPleaseSelectToken => 'டோக்கனைத் தேர்ந்தெடுக்கவும்';

  @override
  String get commonReceivedTransfer => 'பரிமாற்றம் கிடைத்தது';

  @override
  String commonSenderSentRedPacket(String name) {
    return '$name சிவப்பு நிற பாக்கெட்டை அனுப்பியது';
  }

  @override
  String get commonSavedToBalance =>
      'சமநிலையில் சேமிக்கப்பட்டது, நேரடியாகப் பரிமாற்றம் செய்யலாம்';

  @override
  String get commonRedPacketExpiredOrEmpty =>
      'சிவப்பு பாக்கெட் காலாவதியானது/அனைத்தும் கோரப்பட்டது';

  @override
  String get transferScanFeatureComingSoon => 'ஸ்கேன் அம்சம் விரைவில்...';

  @override
  String get contactSetAsStarred => 'நட்சத்திரமிட்டதாக அமைக்கவும்';

  @override
  String get contactAddToBlocklist => 'தடுப்புப்பட்டியலில் சேர்க்கவும்';

  @override
  String get commonClaimedYour => ' உங்கள் உரிமை கோரினார் ';

  @override
  String get commonClaimedText => ' கோரினார் ';

  @override
  String commonUserTyping(String name) {
    return '$name தட்டச்சு செய்கிறது...';
  }

  @override
  String get commonTyping => 'தட்டச்சு செய்கிறது...';

  @override
  String get commonWaitingToReceive => 'பெற காத்திருக்கிறது';

  @override
  String get commonTapToClaim => 'உரிமைகோர, தட்டவும்';

  @override
  String get commonHasBeenReceived => 'பெறப்பட்டுள்ளது';

  @override
  String get commonGetLucky => 'அதிர்ஷ்டம் கிடைக்கும்';

  @override
  String get qrcodeCameraStartFailed => 'கேமராவைத் தொடங்க முடியவில்லை';

  @override
  String get qrcodeUnknownError => 'அறியப்படாத பிழை';

  @override
  String get qrcodePlaceQrCodeInFrame =>
      'ஸ்கேன் செய்ய ஃப்ரேமிற்குள் QR குறியீட்டை வைக்கவும்';

  @override
  String get qrcodeCloseManualInput => 'கைமுறை உள்ளீட்டை மூடு';

  @override
  String get qrcodeManualInputUserId => 'கைமுறை உள்ளீடு பயனர் ஐடி';

  @override
  String get commonAdd => 'சேர்';

  @override
  String get profileSetStatus => 'நிலையை அமைக்கவும்';

  @override
  String get profileVisibleToFriends24h =>
      '24 மணிநேரமும் நண்பர்களுக்குத் தெரியும்';

  @override
  String get profileWriteStatus => 'நிலையை எழுதுங்கள்';

  @override
  String get profileEnterYourStatus => 'உங்கள் நிலையை உள்ளிடவும்...';

  @override
  String get profileOk => 'சரி';

  @override
  String get qrcodeCameraPermissionRequired =>
      'QR குறியீட்டை ஸ்கேன் செய்ய கேமரா அனுமதி தேவை';

  @override
  String get qrcodeCameraPermissionDenied =>
      'கேமரா அனுமதி நிரந்தரமாக மறுக்கப்பட்டது. கணினி அமைப்புகளில் அதை இயக்கவும்.';

  @override
  String qrcodePermissionCheckError(String error) {
    return 'அனுமதியைச் சரிபார்ப்பதில் பிழை: $error';
  }

  @override
  String get qrcodeInvalidQrCode => 'தவறான QR குறியீடு';

  @override
  String qrcodeCannotAddFriend(String error) {
    return 'நண்பரைச் சேர்க்க முடியாது: $error';
  }

  @override
  String get qrcodeScanQrCode => 'QR குறியீட்டை ஸ்கேன் செய்யவும்';

  @override
  String get qrcodeCheckingCameraPermission =>
      'கேமரா அனுமதியைச் சரிபார்க்கிறது...';

  @override
  String get qrcodeNeedCameraPermission => 'கேமரா அனுமதி தேவை';

  @override
  String get qrcodeRetryPermission => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get qrcodeOpenSettings => 'அமைப்புகளைத் திறக்கவும்';

  @override
  String get groupInviteMembers => 'உறுப்பினர்களை அழைக்கவும்';

  @override
  String groupInviteCount(int count) {
    return 'அழை($count)';
  }

  @override
  String get profileNoShippingAddress => 'ஷிப்பிங் முகவரி இல்லை';

  @override
  String get profileDefaultLabel => 'இயல்புநிலை';

  @override
  String get profileNoInvoice => 'விலைப்பட்டியல் இல்லை';

  @override
  String get profileCompany => 'நிறுவனம்';

  @override
  String get profileTaxNumber => 'வரி எண்';

  @override
  String get profileConfirmDeleteAddress =>
      'இந்த முகவரியை நிச்சயமாக நீக்க விரும்புகிறீர்களா?';

  @override
  String get profileConfirmDeleteInvoice =>
      'இந்த இன்வாய்ஸை நிச்சயமாக நீக்க விரும்புகிறீர்களா?';

  @override
  String get commonGroupOwner => 'உரிமையாளர்';

  @override
  String get commonGroupAdmin => 'நிர்வாகி';

  @override
  String get groupSearchMembers => 'உறுப்பினர்களைத் தேடுங்கள்';

  @override
  String groupTotalMembers(int count) {
    return '$count உறுப்பினர்கள்';
  }

  @override
  String get chatRemoveFromGroup => 'குழுவிலிருந்து நீக்கு';

  @override
  String groupConfirmRemoveMember(String name) {
    return 'குழுவிலிருந்து \"$name\" ஐ நிச்சயமாக அகற்ற விரும்புகிறீர்களா?';
  }

  @override
  String get chatUnknownSong => 'தெரியாத பாடல்';

  @override
  String get chatUnknownArtist => 'தெரியாத கலைஞர்';

  @override
  String get chatUnknownContact => 'தெரியாத தொடர்பு';

  @override
  String get chatPersonalCard => 'தொடர்பு அட்டை';

  @override
  String get chatSingleChoice => 'ஒற்றை';

  @override
  String get chatMultiChoice => 'பல';

  @override
  String get chatEnded => 'முடிந்தது';

  @override
  String get chatEndPollButton => 'முடிவு வாக்கெடுப்பு';

  @override
  String get chatPollHint =>
      'வாக்கெடுப்பு அரட்டையில் காட்டப்படும். குழு உறுப்பினர்கள் வாக்களிக்கலாம்.';

  @override
  String get chatSearchSongOrArtist => 'பாடல் அல்லது கலைஞரைத் தேடுங்கள்';

  @override
  String get chatNoSongsFound => 'பாடல்கள் எதுவும் கிடைக்கவில்லை';

  @override
  String get chatSongNameOptional => 'பாடலின் பெயர் (விரும்பினால்)';

  @override
  String get chatEnterSongName => 'பாடலின் பெயரை உள்ளிடவும்';

  @override
  String get chatArtistNameOptional => 'கலைஞரின் பெயர் (விரும்பினால்)';

  @override
  String get chatEnterArtistName => 'கலைஞரின் பெயரை உள்ளிடவும்';

  @override
  String get chatRealTimeLocationSharing =>
      'நிகழ்நேர இருப்பிடப் பகிர்வு மேம்பாட்டில் உள்ளது...';

  @override
  String get profileVoiceCallFeatureInDev =>
      'குரல் அழைப்பு அம்சம் வளர்ச்சியில் உள்ளது...';

  @override
  String get profileReportFeatureInDev =>
      'வளர்ச்சியில் உள்ள அம்சத்தைப் புகாரளி...';

  @override
  String get profileShareFeatureInDev => 'வளர்ச்சியில் அம்சத்தைப் பகிரவும்...';

  @override
  String get profileQrCodeFeatureInDev =>
      'QR குறியீடு அம்சம் வளர்ச்சியில் உள்ளது...';

  @override
  String get qrcodeScanQrToAddMe =>
      'என்னை நண்பராகச் சேர்க்க மேலே உள்ள QR குறியீட்டை ஸ்கேன் செய்யவும்';

  @override
  String get qrcodeSaveToAlbum => 'ஆல்பத்தில் சேமிக்கவும்';

  @override
  String get qrcodeChangeStyle => 'உடையை மாற்றவும்';

  @override
  String get qrcodeCopyId => 'நகல் ஐடி';

  @override
  String get qrcodeIdCopied => 'ஐடி நகலெடுக்கப்பட்டது';

  @override
  String get qrcodeMoreStylesFeatureComingSoon =>
      'மேலும் ஸ்டைல்கள் விரைவில் வரும்';

  @override
  String get profileBio => 'உயிர்';

  @override
  String get profileHomeServer => 'சேவையகம்';

  @override
  String get profileShareContactCard => 'தொடர்பு அட்டையைப் பகிரவும்';

  @override
  String get profileRemoveFromBlacklist => 'தடுப்புப்பட்டியலில் இருந்து நீக்கு';

  @override
  String get profileConfirmAddBlacklist =>
      'இந்த பயனரை தடுப்புப்பட்டியலில் நிச்சயமாக சேர்க்க விரும்புகிறீர்களா? அவர்களிடமிருந்து நீங்கள் செய்திகளைப் பெற மாட்டீர்கள்.';

  @override
  String get profileConfirmRemoveBlacklist =>
      'தடுப்புப்பட்டியலில் இருந்து இந்தப் பயனரை நிச்சயமாக நீக்க விரும்புகிறீர்களா?';

  @override
  String get profileRemarkSaved => 'கருத்து சேமிக்கப்பட்டது';

  @override
  String get profileRemarkCleared => 'கருத்து அழிக்கப்பட்டது';

  @override
  String get transferReceive => 'பெறு';

  @override
  String get transferPleaseConnectWallet =>
      'முதலில் உங்கள் பணப்பையை இணைக்கவும்';

  @override
  String get transferSendRequest => 'கோரிக்கையை அனுப்பவும்';

  @override
  String get transferPleaseEnterValidAmount => 'சரியான தொகையை உள்ளிடவும்';

  @override
  String get searchPlaceholder =>
      'தொடர்புகள், குழுக்கள், செய்திகளைத் தேடுங்கள்';

  @override
  String get searchEnterKeywordToSearch =>
      'தேடலைத் தொடங்க முக்கிய சொல்லை உள்ளிடவும்';

  @override
  String get searchClearHistory => 'தெளிவு';

  @override
  String searchNoResultsForQuery(String query) {
    return '\"$query\" க்கான முடிவுகள் எதுவும் இல்லை';
  }

  @override
  String get searchAllResults => 'அனைத்து';

  @override
  String get searchInChat => 'அரட்டையில் தேடவும்';

  @override
  String get searchContactLabel => 'தொடர்பு கொள்ளவும்';

  @override
  String get searchGroupLabel => 'குழு';

  @override
  String get searchConversationLabel => 'உரையாடல்';

  @override
  String get searchMessageLabel => 'செய்தி';

  @override
  String get settingsSecurityTitle => 'பாதுகாப்பு';

  @override
  String get settingsKeyBackup => 'முக்கிய காப்புப்பிரதி';

  @override
  String get settingsBackupEncryptionKeys => 'காப்பு குறியாக்க விசைகள்';

  @override
  String settingsKeysBackedUp(int count) {
    return '$count விசைகள் காப்புப் பிரதி எடுக்கப்பட்டன';
  }

  @override
  String get settingsBackupNotSet => 'காப்புப்பிரதி அமைக்கப்படவில்லை';

  @override
  String get settingsRestoreKeys => 'விசைகளை மீட்டமை';

  @override
  String get settingsRestoreKeysFromBackup =>
      'காப்புப்பிரதியிலிருந்து குறியாக்க விசைகளை மீட்டெடுக்கவும்';

  @override
  String get settingsExportKeys => 'ஏற்றுமதி விசைகள்';

  @override
  String get settingsExportKeysToFile =>
      'கோப்பிற்கு விசைகளை ஏற்றுமதி செய்யவும்';

  @override
  String get settingsLoggedInDevices => 'உள்நுழைந்த சாதனங்கள்';

  @override
  String get settingsNoOtherDevices => 'வேறு சாதனங்கள் இல்லை';

  @override
  String get settingsVerified => 'சரிபார்க்கப்பட்டது';

  @override
  String get settingsUnverified => 'சரிபார்க்கப்படவில்லை';

  @override
  String get settingsAdvanced => 'மேம்பட்டது';

  @override
  String get settingsCrossSigning => 'குறுக்கு-கையொப்பமிடுதல்';

  @override
  String get settingsEnabled => 'இயக்கப்பட்டது';

  @override
  String get settingsNotEnabled => 'இயக்கப்படவில்லை';

  @override
  String get settingsResetEncryption => 'குறியாக்கத்தை மீட்டமைக்கவும்';

  @override
  String get settingsDeleteAllEncryptionKeys =>
      'அனைத்து குறியாக்க விசைகளையும் நீக்கு';

  @override
  String get settingsEncryptionNotSupported => 'என்க்ரிப்ஷன் ஆதரிக்கப்படவில்லை';

  @override
  String get settingsNotInitialized => 'துவக்கப்படவில்லை';

  @override
  String get settingsBackupKeyTitle => 'காப்பு விசைகள்';

  @override
  String get settingsBackupKeyMessage =>
      'புதிய விசை காப்புப்பிரதியை உருவாக்கவா? இது புதிய சாதனத்தில் மறைகுறியாக்கப்பட்ட செய்திகளை மீட்டெடுக்க உதவும்.';

  @override
  String get settingsBackup => 'காப்புப்பிரதி';

  @override
  String get settingsRestoreKeyTitle => 'விசைகளை மீட்டமை';

  @override
  String get settingsRestoreKeyMessage =>
      'மறைகுறியாக்கப்பட்ட செய்திகளை மீட்டெடுக்க உங்கள் மீட்பு கடவுச்சொல் அல்லது மீட்பு விசையை உள்ளிடவும்.';

  @override
  String get settingsRestore => 'மீட்டமை';

  @override
  String get settingsExportKeyTitle => 'ஏற்றுமதி விசைகள்';

  @override
  String get settingsExportKeyMessage =>
      'ஏற்றுமதி செய்யப்பட்ட விசை கோப்பில் உங்களின் அனைத்து குறியாக்க விசைகளும் உள்ளன. தயவு செய்து பத்திரமாக வைத்துக் கொள்ளவும்.';

  @override
  String get settingsExport => 'ஏற்றுமதி';

  @override
  String settingsDeviceIdLabel(String deviceId) {
    return 'சாதன ஐடி: $deviceId';
  }

  @override
  String get settingsDeviceStatusVerified => 'நிலை: சரிபார்க்கப்பட்டது';

  @override
  String get settingsDeviceStatusUnverified => 'நிலை: சரிபார்க்கப்படவில்லை';

  @override
  String settingsLastActiveLabel(String lastSeen) {
    return 'கடைசியாக செயல்பட்டது: $lastSeen';
  }

  @override
  String get settingsVerifyThisDevice => 'இந்தச் சாதனத்தைச் சரிபார்க்கவும்';

  @override
  String get settingsCrossSigningAlreadyEnabled =>
      'குறுக்கு கையொப்பம் ஏற்கனவே இயக்கப்பட்டுள்ளது';

  @override
  String get settingsCrossSigningSetupSuccess =>
      'குறுக்கு-கையொப்பமிடும் அமைப்பு வெற்றிகரமாக உள்ளது';

  @override
  String get settingsResetEncryptionTitle => 'குறியாக்கத்தை மீட்டமைக்கவும்';

  @override
  String get settingsResetEncryptionWarning =>
      'எச்சரிக்கை: இது உங்களின் அனைத்து குறியாக்க விசைகளையும் நீக்கும். முந்தைய மறைகுறியாக்கப்பட்ட செய்திகளை உங்களால் டிக்ரிப்ட் செய்ய முடியாது. இந்தச் செயலைச் செயல்தவிர்க்க முடியாது.';

  @override
  String get settingsReset => 'மீட்டமை';

  @override
  String get settingsBackupSuccess =>
      'விசைகள் வெற்றிகரமாக காப்புப் பிரதி எடுக்கப்பட்டன';

  @override
  String get settingsBackupFailed => 'காப்புப்பிரதி தோல்வியடைந்தது';

  @override
  String get settingsRecoveryKey => 'மீட்பு விசை';

  @override
  String get settingsRecoveryKeySaveWarning =>
      'இந்த மீட்பு விசையை பாதுகாப்பான இடத்தில் சேமிக்கவும். உங்கள் மறைகுறியாக்கப்பட்ட செய்திகளை புதிய சாதனத்தில் மீட்டமைக்க இது தேவைப்படும்.';

  @override
  String get settingsRecoveryKeySaved => 'நான் சேமித்து விட்டேன்';

  @override
  String get settingsRestoreSuccess => 'விசைகள் வெற்றிகரமாக மீட்டெடுக்கப்பட்டன';

  @override
  String get settingsRestoreFailed => 'மீட்டமைக்க முடியவில்லை';

  @override
  String get settingsPassword => 'கடவுச்சொல்';

  @override
  String get settingsEnterRecoveryKey => 'மீட்பு விசையை உள்ளிடவும்';

  @override
  String get settingsEnterPassword => 'கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get settingsExportSuccess =>
      'விசைகள் சர்வர் காப்புப்பிரதிக்கு வெற்றிகரமாக ஏற்றுமதி செய்யப்பட்டன';

  @override
  String get settingsExportNeedBackupFirst =>
      'முதலில் ஒரு முக்கிய காப்புப்பிரதியை உருவாக்கவும்';

  @override
  String get settingsExportFailed => 'ஏற்றுமதி தோல்வியடைந்தது';

  @override
  String get settingsResetSuccess =>
      'என்க்ரிப்ஷன் மீட்டமைப்பு வெற்றிகரமாக உள்ளது';

  @override
  String get settingsResetFailed => 'மீட்டமைக்க முடியவில்லை';

  @override
  String get callLeaveMeetingConfirm =>
      'மீட்டிங்கில் இருந்து நிச்சயமாக வெளியேற விரும்புகிறீர்களா?';

  @override
  String chatPokedSomeone(String name, String suffix) {
    return '$name$suffix குத்தப்பட்டது';
  }

  @override
  String get chatNoContactsToAdd => 'சேர்க்க தொடர்புகள் எதுவும் இல்லை';

  @override
  String get chatAddMembers => 'உறுப்பினர்களைச் சேர்க்கவும்';

  @override
  String chatInvitedMembers(int count) {
    return '$count உறுப்பினர்கள் அழைக்கப்பட்டுள்ளனர்';
  }

  @override
  String chatInviteFailed(String error) {
    return 'அழைப்பு தோல்வி: $error';
  }

  @override
  String get chatMemberRemoved => 'உறுப்பினர் நீக்கப்பட்டார்';

  @override
  String chatRemoveFailed(String error) {
    return 'அகற்ற முடியவில்லை: $error';
  }

  @override
  String get chatRealTimeLocationShareMessage =>
      'பகிர்ந்த பிறகு, மற்ற தரப்பினர் உங்கள் நிகழ்நேர இருப்பிடத்தை 1 மணிநேரம் பார்க்க முடியும்.';

  @override
  String get chatStartSharing => 'பகிரத் தொடங்கு';

  @override
  String get chatLocationServiceNotEnabled => 'இருப்பிடச் சேவை இயக்கப்படவில்லை';

  @override
  String get chatEnableLocationService =>
      'இந்த அம்சத்தைப் பயன்படுத்த, இருப்பிடச் சேவையை இயக்கவும்';

  @override
  String get chatGoToSettings => 'அமைப்புகளுக்குச் செல்லவும்';

  @override
  String get chatLocationPermissionRequired =>
      'இந்த அம்சத்திற்கு இருப்பிட அனுமதி தேவை';

  @override
  String get chatLocationPermissionDeniedPermanent =>
      'இருப்பிட அனுமதி நிரந்தரமாக மறுக்கப்பட்டது. அமைப்புகளில் அதை இயக்கவும்.';

  @override
  String get chatLocationPermissionDenied => 'இருப்பிட அனுமதி மறுக்கப்பட்டது';

  @override
  String get chatGettingLocation => 'இருப்பிடத்தைப் பெறுகிறது...';

  @override
  String chatGetLocationFailed(String error) {
    return 'இருப்பிடத்தைப் பெறுவதில் தோல்வி: $error';
  }

  @override
  String get chatMapPreview => 'வரைபட முன்னோட்டம்';

  @override
  String get chatSearchLocation => 'இடம் தேடு';

  @override
  String chatRedPacketSent(String amount, String token) {
    return '$amount $token சிவப்பு பாக்கெட் அனுப்பப்பட்டது';
  }

  @override
  String get chatTransferDefault => 'இடமாற்றம்';

  @override
  String chatTransferSent(String amount, String token) {
    return 'அனுப்பப்பட்டது $amount $token பரிமாற்றம்';
  }

  @override
  String chatPickFileFailed(String error) {
    return 'கோப்பைத் தேர்ந்தெடுப்பதில் தோல்வி: $error';
  }

  @override
  String get chatFileSizeLimit =>
      'கோப்பு அளவு 50MB ஐ விட அதிகமாக இருக்கக்கூடாது';

  @override
  String chatFileSending(String filename) {
    return 'கோப்பு அனுப்புகிறது: $filename';
  }

  @override
  String chatSendFileFailed(String error) {
    return 'கோப்பை அனுப்புவதில் தோல்வி: $error';
  }

  @override
  String chatContactCardSent(String name) {
    return '$name இன் தொடர்பு அட்டை அனுப்பப்பட்டது';
  }

  @override
  String get chatFavoritesFeature => 'பிடித்தவை';

  @override
  String get chatCouponsFeature => 'கூப்பன்கள்';

  @override
  String get chatGiftFeature => 'பரிசு';

  @override
  String chatSharedMusic(String name) {
    return 'பகிரப்பட்டது $name';
  }

  @override
  String get chatEndPollTitle => 'முடிவு வாக்கெடுப்பு';

  @override
  String get chatEndPollConfirmMessage =>
      'இந்த வாக்கெடுப்பை நிச்சயமாக முடிக்க விரும்புகிறீர்களா? வாக்குப்பதிவு முடிந்ததும் மூடப்படும்.';

  @override
  String get chatPollEndedMessage => 'கருத்துக்கணிப்பு முடிந்தது';

  @override
  String get chatConnectingCall => 'இணைக்கிறது...';

  @override
  String get chatMuteCall => 'முடக்கு';

  @override
  String get chatSpeakerOff => 'ஸ்பீக்கர் ஆஃப்';

  @override
  String get chatSpeakerOn => 'பேச்சாளர்';

  @override
  String get chatCameraOn => 'கேமரா ஆன்';

  @override
  String get chatCameraOff => 'கேமரா ஆஃப்';

  @override
  String get chatHangUp => 'நிறுத்து';

  @override
  String get chatSelectForwardTargetTitle =>
      'முன்னோக்கி இலக்கைத் தேர்ந்தெடுக்கவும்';

  @override
  String get chatNoForwardableChat =>
      'முன்னனுப்புவதற்கு அரட்டைகள் எதுவும் இல்லை';

  @override
  String get chatNoMatchingChat => 'பொருத்தமான அரட்டைகள் எதுவும் இல்லை';

  @override
  String get chatLocationTitle => 'இடம்';

  @override
  String get chatSendButton => 'அனுப்பு';

  @override
  String get chatRetryButton => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get chatSearchContactHint => 'தொடர்புகளைத் தேடுங்கள்';

  @override
  String get chatShareMusic => 'இசையைப் பகிரவும்';

  @override
  String get chatRecentPlayed => 'சமீபத்திய';

  @override
  String get chatMyFavorites => 'பிடித்தவை';

  @override
  String get chatNetworkLink => 'இணைப்பு';

  @override
  String get chatLocalFile => 'உள்ளூர்';

  @override
  String get chatPasteMusicLink => 'இசை இணைப்பை ஒட்டவும்';

  @override
  String get chatShareMusicButton => 'இசையைப் பகிரவும்';

  @override
  String get chatSelectLocalAudio => 'உள்ளூர் ஆடியோ கோப்பைத் தேர்ந்தெடுக்கவும்';

  @override
  String get chatSupportedAudioFormats =>
      'MP3, M4A, WAV, FLAC போன்றவற்றை ஆதரிக்கிறது.';

  @override
  String get chatSelectFileButton => 'கோப்பைத் தேர்ந்தெடுக்கவும்';

  @override
  String get chatPleaseEnterMusicLink => 'இசை இணைப்பை உள்ளிடவும்';

  @override
  String get chatPleaseEnterValidLink => 'சரியான URL ஐ உள்ளிடவும்';

  @override
  String get chatSharedSong => 'பகிரப்பட்ட பாடல்';

  @override
  String get chatSelectMember => 'உறுப்பினரைத் தேர்ந்தெடுக்கவும்';

  @override
  String get chatSearchMemberHint => 'உறுப்பினர்களைத் தேடுங்கள்';

  @override
  String get chatNoMatchingMembers => 'பொருந்தக்கூடிய உறுப்பினர்கள் இல்லை';

  @override
  String get commonUnknownMember => 'தெரியவில்லை';

  @override
  String chatSelectedMessagesCount(int count) {
    return 'தேர்ந்தெடுக்கப்பட்ட $count செய்திகள்';
  }

  @override
  String get chatSearchContactsOrGroups =>
      'தொடர்புகள் அல்லது குழுக்களைத் தேடுங்கள்';

  @override
  String get chatVideoTitle => 'வீடியோ';

  @override
  String get chatLoadingText => 'ஏற்றுகிறது...';

  @override
  String get chatVideoLoadFailed => 'வீடியோ ஏற்ற முடியவில்லை';

  @override
  String get chatPlayerInitFailed => 'பிளேயர் துவக்கம் தோல்வியடைந்தது';

  @override
  String get chatCreatePollTitle => 'வாக்கெடுப்பை உருவாக்கவும்';

  @override
  String get chatSubmitPoll => 'சமர்ப்பிக்கவும்';

  @override
  String get chatPollQuestionLabel => 'கருத்துக்கணிப்பு கேள்வி';

  @override
  String get chatEnterPollQuestionHint => 'வாக்கெடுப்பு கேள்வியை உள்ளிடவும்';

  @override
  String get chatPollOptionsLabel => 'வாக்கெடுப்பு விருப்பங்கள்';

  @override
  String chatOptionHintWithIndex(int index) {
    return 'விருப்பம் $index';
  }

  @override
  String get chatAddOptionButton => 'விருப்பத்தைச் சேர்க்கவும்';

  @override
  String get chatPollSettingsLabel => 'வாக்கெடுப்பு அமைப்புகள்';

  @override
  String get chatSelectionType => 'தேர்வு வகை';

  @override
  String get chatSingleChoiceLabel => 'ஒற்றை';

  @override
  String get chatMultiChoiceLabel => 'பல';

  @override
  String get chatAnonymousPollSwitch => 'அநாமதேய கருத்துக்கணிப்பு';

  @override
  String get chatPleaseEnterQuestion => 'வாக்கெடுப்பு கேள்வியை உள்ளிடவும்';

  @override
  String get chatAtLeastTwoOptions => 'குறைந்தது 2 விருப்பங்கள் தேவை';

  @override
  String chatConfirmWithCount(int count) {
    return 'உறுதிப்படுத்தவும் ($count)';
  }

  @override
  String get authEmailVerificationTitle => 'மின்னஞ்சல் சரிபார்ப்பு';

  @override
  String get authEnterValidEmailAddress =>
      'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்';

  @override
  String authVerificationCodeSentTo(String email) {
    return 'சரிபார்ப்புக் குறியீடு $email க்கு அனுப்பப்பட்டது';
  }

  @override
  String authSendCodeFailed(String error) {
    return 'குறியீட்டை அனுப்புவதில் தோல்வி: $error';
  }

  @override
  String get authVerificationSuccess => 'சரிபார்ப்பு வெற்றி பெற்றது';

  @override
  String get authVerificationFailed => 'சரிபார்ப்பு தோல்வியடைந்தது';

  @override
  String authVerificationCodeError(String error) {
    return 'சரிபார்ப்புக் குறியீடு பிழை: $error';
  }

  @override
  String get commonEnterVerificationCode =>
      'சரிபார்ப்புக் குறியீட்டை உள்ளிடவும்';

  @override
  String get authEnterYourEmail => 'மின்னஞ்சலை உள்ளிடவும்';

  @override
  String authWeSentCodeTo(String email) {
    return '6 இலக்கக் குறியீட்டை அனுப்பினோம்\n$email';
  }

  @override
  String get authEnterEmailForCode =>
      'உங்கள் மின்னஞ்சல் முகவரியை உள்ளிடவும், நாங்கள் சரிபார்ப்புக் குறியீட்டை அனுப்புவோம்';

  @override
  String get commonSendVerificationCode =>
      'சரிபார்ப்புக் குறியீட்டை அனுப்பவும்';

  @override
  String get authResendVerificationCode =>
      'சரிபார்ப்புக் குறியீட்டை மீண்டும் அனுப்பவும்';

  @override
  String authCanResendAfter(int seconds) {
    return '$seconds வினாடிகளுக்குப் பிறகு மீண்டும் அனுப்பலாம்';
  }

  @override
  String get commonChangeEmail => 'மின்னஞ்சலை மாற்றவும்';

  @override
  String get contactAddToContacts => 'தொடர்புகளில் சேர்க்கவும்';

  @override
  String get contactAddingToContacts => 'சேர்க்கிறது...';

  @override
  String get contactAddedToContacts => 'தொடர்புகளில் சேர்க்கப்பட்டது';

  @override
  String contactAddFailedWithError(String error) {
    return 'சேர்க்க முடியவில்லை: $error';
  }

  @override
  String get contactAddPhone => 'தொலைபேசியைச் சேர்க்கவும்';

  @override
  String get contactAddTag => 'குறிச்சொற்களைச் சேர்க்கவும்';

  @override
  String get contactAddText => 'உரையைச் சேர்க்கவும்';

  @override
  String get contactAddPhoto => 'புகைப்படத்தைச் சேர்க்கவும்';

  @override
  String contactGroupCountLabel(int count) {
    return '$count குழுக்கள்';
  }

  @override
  String get contactAddedViaSearch => 'தேடல் மூலம் சேர்க்கப்பட்டது';

  @override
  String get contactAddTime => 'நேரத்தைச் சேர்க்கவும்';

  @override
  String get contactDoneButton => 'முடிந்தது';

  @override
  String get callWaitingForParticipants =>
      'பங்கேற்பாளர்கள் சேர்வதற்குக் காத்திருக்கிறது...';

  @override
  String callParticipantMe(String name) {
    return '$name (நான்)';
  }

  @override
  String get callSharingLabel => 'பகிர்தல்';

  @override
  String callScreenSharingBy(String name) {
    return '$name திரையைப் பகிர்கிறது';
  }

  @override
  String callParticipantCount(int count) {
    return '$count பங்கேற்பாளர்கள்';
  }

  @override
  String get callMuteLabel => 'முடக்கு';

  @override
  String get callUnmuteLabel => 'ஒலியடக்கவும்';

  @override
  String get callTurnOffVideo => 'வீடியோவை முடக்கு';

  @override
  String get callTurnOnVideo => 'வீடியோவை இயக்கவும்';

  @override
  String get callShareScreen => 'திரையைப் பகிரவும்';

  @override
  String get callStopSharing => 'பகிர்வதை நிறுத்து';

  @override
  String get callSwitchCameraLabel => 'மாறவும்';

  @override
  String get callLeaveLabel => 'கிளம்பு';

  @override
  String get callParticipantsLabel => 'பங்கேற்பாளர்கள்';

  @override
  String get callJoiningMeeting => 'மீட்டிங்கில் இணைகிறது...';

  @override
  String chatPollVotesFormat(int count, String percentage) {
    return '$count வாக்குகள் ($percentage%)';
  }

  @override
  String chatPollParticipantsFormat(int count) {
    return '$count பங்கேற்பாளர்கள்';
  }

  @override
  String get commonTapToRetry => 'மீண்டும் முயற்சிக்க தட்டவும்';

  @override
  String get chatDefaultRedPacketGreeting => 'வளம் பெற வாழ்த்துக்கள்';

  @override
  String get groupAllowOthersToSearchAndJoin =>
      'தேட மற்றும் சேர மற்றவர்களை அனுமதிக்கவும்';

  @override
  String get groupConfirmClearChatHistory =>
      'அரட்டை வரலாற்றை நிச்சயமாக அழிக்க விரும்புகிறீர்களா?';

  @override
  String get groupCreateGroupToChat => 'அரட்டையடிக்க ஒரு குழுவை உருவாக்கவும்';

  @override
  String get groupEditGroupAnnouncement => 'குழு அறிவிப்பைத் திருத்தவும்';

  @override
  String get groupEditGroupDescription => 'குழு விளக்கத்தைத் திருத்தவும்';

  @override
  String get groupEnterGroupAnnouncement => 'குழு அறிவிப்பை உள்ளிடவும்';

  @override
  String chatErrorWithMessage(String message) {
    return 'பிழை: $message';
  }

  @override
  String groupMemberCountClickToCopy(int count) {
    return '$count உறுப்பினர்கள், குழு ஐடியை நகலெடுக்க கிளிக் செய்யவும்';
  }

  @override
  String get chatMusicLinkLabel => 'இசை இணைப்பு';

  @override
  String get chatNoMediaUrlAvailable => 'மீடியா URL இல்லை';

  @override
  String get groupNoPermissionToEditGroupName =>
      'குழுவின் பெயரைத் திருத்த உங்களுக்கு அனுமதி இல்லை';

  @override
  String get chatRedPacketTransferCannotForward =>
      'சிவப்பு பாக்கெட்டுகள் மற்றும் இடமாற்றங்களை அனுப்ப முடியாது';

  @override
  String get authEmailAddress => 'மின்னஞ்சல் முகவரி';

  @override
  String get commonEnterEmailAddress => 'மின்னஞ்சல் முகவரியை உள்ளிடவும்';

  @override
  String get authEmailRecoveryHint => 'கடவுச்சொல்லை மீட்டெடுக்கப் பயன்படுகிறது';

  @override
  String get commonInvalidEmailFormat =>
      'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்';

  @override
  String get authOptional => 'விருப்பமானது';

  @override
  String get authResetPassword => 'கடவுச்சொல்லை மீட்டமைக்கவும்';

  @override
  String get authEnterRegisteredEmail =>
      'நீங்கள் பதிவுசெய்த மின்னஞ்சல் முகவரியை உள்ளிடவும்';

  @override
  String get authSendResetCode => 'மீட்டமை குறியீட்டை அனுப்பவும்';

  @override
  String authResetCodeSent(String email) {
    return '$emailக்கு அனுப்பப்பட்ட குறியீட்டை மீட்டமைக்கவும்';
  }

  @override
  String get authEnterResetCode => 'மீட்டமைக் குறியீட்டை உள்ளிடவும்';

  @override
  String get authSetNewPassword => 'புதிய கடவுச்சொல்லை அமைக்கவும்';

  @override
  String get commonConfirmNewPassword => 'புதிய கடவுச்சொல்லை உறுதிப்படுத்தவும்';

  @override
  String get commonNewPassword => 'புதிய கடவுச்சொல்';

  @override
  String get authPasswordResetSuccess =>
      'கடவுச்சொல் மீட்டமைப்பு வெற்றிகரமாக உள்ளது. உங்கள் புதிய கடவுச்சொல் மூலம் உள்நுழையவும்.';

  @override
  String get authResetPasswordFailed => 'கடவுச்சொல்லை மீட்டமைக்க முடியவில்லை';

  @override
  String get settingsChangePassword => 'கடவுச்சொல்லை மாற்றவும்';

  @override
  String get settingsCurrentPassword => 'தற்போதைய கடவுச்சொல்';

  @override
  String get settingsEnterCurrentPassword => 'தற்போதைய கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get settingsEnterNewPassword => 'புதிய கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get settingsPasswordChanged =>
      'கடவுச்சொல் வெற்றிகரமாக மாற்றப்பட்டது. உங்கள் புதிய கடவுச்சொல் மூலம் உள்நுழையவும்.';

  @override
  String get settingsChangePasswordFailed => 'கடவுச்சொல்லை மாற்ற முடியவில்லை';

  @override
  String get settingsNewPasswordMustBeDifferent =>
      'புதிய கடவுச்சொல் தற்போதைய கடவுச்சொல்லிலிருந்து வேறுபட்டதாக இருக்க வேண்டும்';

  @override
  String get settingsChangePasswordInfo =>
      'கடவுச்சொல்லை மாற்றிய பிறகு, நீங்கள் வெளியேற்றப்படுவீர்கள், மேலும் புதிய கடவுச்சொல்லைப் பயன்படுத்தி உள்நுழைய வேண்டும்.';

  @override
  String get settingsPasswordRequirements => 'கடவுச்சொல் தேவைகள்:';

  @override
  String get settingsSecurityNote =>
      'பாதுகாப்பிற்காக, கடவுச்சொல்லை மாற்றிய பிறகு எல்லா சாதனங்களிலும் மீண்டும் உள்நுழைய வேண்டும்.';

  @override
  String get settingsSecurity => 'பாதுகாப்பு';

  @override
  String get settingsCurrentBoundEmail => 'தற்போதைய பிணைப்பு மின்னஞ்சல்';

  @override
  String get settingsNewEmailAddress => 'புதிய மின்னஞ்சல் முகவரி';

  @override
  String get settingsEnterNewEmail => 'புதிய மின்னஞ்சல் முகவரியை உள்ளிடவும்';

  @override
  String get settingsVerificationCode => 'சரிபார்ப்பு குறியீடு';

  @override
  String get settingsVerificationCodeSent =>
      'சரிபார்ப்புக் குறியீடு அனுப்பப்பட்டது';

  @override
  String get settingsCodeSentTo => 'சரிபார்ப்புக் குறியீடு அனுப்பப்பட்டது';

  @override
  String get settingsDidNotReceiveCode => 'குறியீட்டைப் பெறவில்லையா?';

  @override
  String get settingsEmailChangedSuccess =>
      'மின்னஞ்சல் வெற்றிகரமாக மாற்றப்பட்டது';

  @override
  String get settingsChangeEmailFailed => 'மின்னஞ்சலை மாற்ற முடியவில்லை';

  @override
  String get settingsEmailSecurityNote =>
      'கடவுச்சொல் மீட்டெடுப்பிற்கு உங்கள் மின்னஞ்சல் பயன்படுத்தப்படுகிறது. தயவு செய்து பத்திரமாக வைக்கவும்.';

  @override
  String get commonGoogleLogin => 'Google மூலம் உள்நுழையவும்';

  @override
  String get commonAppleLogin => 'ஆப்பிள் மூலம் உள்நுழையவும்';

  @override
  String get commonWechat => 'WeChat';

  @override
  String get settingsLanguage => 'மொழி';

  @override
  String get settingsLanguageChanged => 'மொழி மாறியது';

  @override
  String get settingsTranslation => 'மொழிபெயர்ப்பு';

  @override
  String get settingsTranslateTextTo => 'உரையை மொழிபெயர்';

  @override
  String get settingsTranslateDescription =>
      'செய்திகளை மொழிபெயர்க்க விரும்பும் மொழியைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get settingsAutoTranslate =>
      'பெறப்பட்ட செய்திகளை தானாக மொழிபெயர்க்கவும்';

  @override
  String get settingsAutoTranslateDescription =>
      'அரட்டையில் பெறப்பட்ட செய்திகளை நீங்கள் தேர்ந்தெடுத்த மொழியில் தானாக மொழிபெயர்க்கவும்.';

  @override
  String get settingsBiometricLogin => 'பயோமெட்ரிக் உள்நுழைவு';

  @override
  String authLoginWithBiometric(Object type) {
    return '$type உடன் உள்நுழைக';
  }

  @override
  String get settingsBiometricLoginEnabled =>
      'பயோமெட்ரிக் உள்நுழைவு இயக்கப்பட்டது';

  @override
  String get settingsBiometricLoginDisabled =>
      'பயோமெட்ரிக் உள்நுழைவு முடக்கப்பட்டது';

  @override
  String get settingsEnableBiometricLogin => 'பயோமெட்ரிக் உள்நுழைவை இயக்கு';

  @override
  String get settingsBiometricEnabled =>
      'இயக்கப்பட்டது - உள்நுழைய பயோமெட்ரிக் பயன்படுத்தவும்';

  @override
  String get settingsBiometricDisabled => 'முடக்கப்பட்டது - இயக்க தட்டவும்';

  @override
  String get settingsBiometricNeedRelogin =>
      'பயோமெட்ரிக் உள்நுழைவை இயக்க, வெளியேறி மீண்டும் உள்நுழையவும்';

  @override
  String get authOr => 'அல்லது';

  @override
  String get qrcodeCameraPermissionRestricted =>
      'இந்தச் சாதனத்தில் கேமரா அணுகல் தடைசெய்யப்பட்டுள்ளது';

  @override
  String get authPasskeyLabel => 'பாஸ்கீ';

  @override
  String get authGoogleLabel => 'கூகுள்';

  @override
  String get authAppleLabel => 'ஆப்பிள்';


  @override
  String get authSsoNotConfigured => 'இந்த சேவையகம் SSO உள்நுழைவு வழங்குநர்களை உள்ளமைக்கவில்லை';
  @override
  String get authSsoLabel => 'SSO';

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
  String get profileEnterPokeSuffixHint =>
      'குத்து பின்னொட்டை உள்ளிடவும், எ.கா: தோளில்';

  @override
  String get groupAlbum => 'குழு ஆல்பம்';

  @override
  String get groupFiles => 'குழு கோப்புகள்';

  @override
  String get groupImages => 'படங்கள்';

  @override
  String get groupVideos => 'வீடியோக்கள்';

  @override
  String get groupTotal => 'மொத்தம்';

  @override
  String get groupSize => 'அளவு';

  @override
  String get groupNoMedia => 'மீடியா இல்லை';

  @override
  String get groupNoMediaDescription =>
      'இந்தக் குழுவில் இதுவரை புகைப்படங்கள் அல்லது வீடியோக்கள் இல்லை';

  @override
  String get groupDocuments => 'ஆவணங்கள்';

  @override
  String get groupNoFiles => 'கோப்புகள் இல்லை';

  @override
  String get groupNoFilesDescription =>
      'இந்தக் குழுவில் இதுவரை கோப்புகள் எதுவும் இல்லை';

  @override
  String groupDownloadStarted(String filename) {
    return '$filename ஐப் பதிவிறக்குகிறது...';
  }

  @override
  String get contactNoCommonGroups => 'பொதுவான குழுக்கள் இல்லை';

  @override
  String get contactNoCommonGroupsDescription =>
      'உங்களுக்கு பொதுவான குழுக்கள் எதுவும் இல்லை';

  @override
  String get chatVoiceMessage => 'குரல்';

  @override
  String get chatMessage => 'செய்தி';

  @override
  String get conversationHideChat => 'மறை';

  @override
  String get settingsQuickReply => 'விரைவான பதில்';

  @override
  String get commonTranslate => 'மொழிபெயர்';

  @override
  String get contactCreateTag => 'குறிச்சொல்லை உருவாக்கவும்';

  @override
  String get contactEnterTagName => 'குறிச்சொல் பெயரை உள்ளிடவும்';

  @override
  String get contactEditTag => 'குறியைத் திருத்து';

  @override
  String get contactDeleteTag => 'குறிச்சொல்லை நீக்கு';

  @override
  String contactDeleteTagConfirm(String tagName) {
    return '\"$tagName\" குறிச்சொல்லை நிச்சயமாக நீக்க விரும்புகிறீர்களா?';
  }

  @override
  String get contactNoTags => 'இன்னும் குறிச்சொற்கள் இல்லை';

  @override
  String get contactFriendPermissions => 'நண்பர் அனுமதிகள்';

  @override
  String get contactSetChatOnly => 'அரட்டை மட்டும் என அமைக்கவும்';

  @override
  String get contactChatOnlyDesc =>
      'உங்களுடன் மட்டுமே அரட்டையடிக்க முடியும், மற்ற உள்ளடக்கம் மறைக்கப்படும்';

  @override
  String get contactHideMyMoments => 'எனது தருணங்களை மறை';

  @override
  String get contactHideMyMomentsDesc =>
      'இந்த நண்பரால் எனது தருணங்களைப் பார்க்க முடியாது';

  @override
  String get contactHideTheirMoments => 'அவர்களின் தருணங்களை மறைக்கவும்';

  @override
  String get contactHideTheirMomentsDesc =>
      'இந்த நண்பரின் தருணங்களைப் பார்க்க வேண்டாம்';

  @override
  String get contactHideMyStatus => 'எனது நிலையை மறை';

  @override
  String get contactHideMyStatusDesc =>
      'எனது நிலை புதுப்பிப்புகளை இந்த நண்பரால் பார்க்க முடியவில்லை';

  @override
  String get contactNoChatOnlyFriends => 'அரட்டை மட்டுமே நண்பர்கள் இல்லை';

  @override
  String get contactNoOfficialAccounts => 'அதிகாரப்பூர்வ கணக்குகள் இல்லை';

  @override
  String get contactFollowOfficialAccountsDesc =>
      'சமீபத்திய புதுப்பிப்புகளைப் பெற அதிகாரப்பூர்வ கணக்குகளைப் பின்தொடரவும்';

  @override
  String get contactNoServiceAccounts => 'சேவை கணக்குகள் இல்லை';

  @override
  String get contactSubscribeServiceAccountsDesc =>
      'வசதியான சேவைகளுக்கு சேவை கணக்குகளுக்கு குழுசேரவும்';

  @override
  String get contactNoEnterpriseContacts => 'நிறுவன தொடர்புகள் இல்லை';

  @override
  String get contactEnterpriseContactsDesc =>
      'நிறுவன தொடர்புகள் இங்கே காட்டப்படும்';

  @override
  String get profileCardPack => 'கார்டு பேக்';

  @override
  String get profileOrders => 'ஆர்டர்கள்';

  @override
  String get profileNoOrders => 'ஆர்டர்கள் இல்லை';

  @override
  String get profileOrdersDesc => 'உங்கள் ஆர்டர்கள் இங்கே காட்டப்படும்';

  @override
  String get profileNoCards => 'அட்டைகள் இல்லை';

  @override
  String get profileCardsDesc => 'உங்கள் கார்டுகள் இங்கே காட்டப்படும்';

  @override
  String get favoriteEnterTagsHint =>
      'காற்புள்ளிகளால் பிரிக்கப்பட்ட குறிச்சொற்களை உள்ளிடவும்';

  @override
  String get favoriteTagsUpdated => 'குறிச்சொற்கள் புதுப்பிக்கப்பட்டன';

  @override
  String get favoriteForwardedContent => 'உள்ளடக்கம் அனுப்பப்பட்டது';

  @override
  String get favoriteEnterNoteContent => 'குறிப்பு உள்ளடக்கத்தை உள்ளிடவும்';

  @override
  String get favoriteNoteAdded => 'குறிப்பு சேர்க்கப்பட்டது';

  @override
  String get favoriteLinkTitle => 'இணைப்பு தலைப்பு';

  @override
  String get favoriteLinkUrl => 'https://';

  @override
  String get favoriteLinkAdded => 'இணைப்பு சேர்க்கப்பட்டது';

  @override
  String get contactPhotoAdded => 'புகைப்படம் சேர்க்கப்பட்டது';

  @override
  String get contactEnterPhone => 'தொலைபேசி எண்ணை உள்ளிடவும்';

  @override
  String commonConversationWithId(String roomId) {
    return 'உரையாடல்: $roomId';
  }

  @override
  String commonContactWithId(String userId) {
    return 'தொடர்புக்கு: $userId';
  }

  @override
  String get commonDiscover => 'கண்டறியவும்';

  @override
  String commonDeveloping(String title) {
    return '$title\n(விரைவில்)';
  }

  @override
  String get commonPageNotFound => 'பக்கம் கிடைக்கவில்லை';

  @override
  String get commonBackToHome => 'முகப்புக்குத் திரும்பு';

  @override
  String get settingsMessageNotifications => 'செய்தி அறிவிப்புகள்';

  @override
  String get settingsReceiveNewMessageNotifications =>
      'புதிய செய்தி அறிவிப்புகளைப் பெறவும்';

  @override
  String get settingsShowMessagePreview => 'செய்தி முன்னோட்டத்தைக் காட்டு';

  @override
  String get settingsShowMessageContentInNotification =>
      'அறிவிப்பில் செய்தி உள்ளடக்கத்தைக் காட்டு';

  @override
  String get settingsNotificationSound => 'அறிவிப்பு ஒலி';

  @override
  String get settingsPlaySoundOnMessage =>
      'செய்திகளைப் பெறும்போது ஒலியை இயக்கவும்';

  @override
  String get commonVibration => 'அதிர்வு';

  @override
  String get settingsVibrateOnMessage => 'செய்திகளைப் பெறும்போது அதிர்வுறும்';

  @override
  String get settingsDoNotDisturbMode => 'தொந்தரவு செய்யாதே';

  @override
  String get settingsDoNotDisturbDescription =>
      'குறிப்பிட்ட நேரத்தில் அறிவிப்புகளைப் பெற வேண்டாம்';

  @override
  String get settingsStartTime => 'தொடக்க நேரம்';

  @override
  String get settingsEndTime => 'முடிவு நேரம்';

  @override
  String get settingsDeleteQuickReply => 'விரைவான பதிலை நீக்கு';

  @override
  String get settingsEditQuickReply => 'விரைவான பதிலைத் திருத்தவும்';

  @override
  String get settingsAddQuickReply => 'விரைவான பதிலைச் சேர்க்கவும்';

  @override
  String get settingsManageQuickReplies => 'விரைவான பதில்களை நிர்வகிக்கவும்';

  @override
  String get settingsNoQuickReplies => 'விரைவான பதில்கள் இல்லை';

  @override
  String get settingsDefaultQuickReplies =>
      'இயல்புநிலை விரைவான பதில்கள் காண்பிக்கப்படும்';

  @override
  String get settingsWhoCanSee => 'யாரால் பார்க்க முடியும்';

  @override
  String get settingsLastSeen => 'கடைசியாக பார்த்தது';

  @override
  String get settingsHiddenChats => 'மறைக்கப்பட்ட அரட்டைகள்';

  @override
  String get settingsMessagesLabel => 'செய்திகள்';

  @override
  String get settingsAllowStrangerMessages =>
      'அந்நியர் செய்திகளை அனுமதிக்கவும்';

  @override
  String get settingsReceiveMessagesFromNonContacts =>
      'தொடர்பு இல்லாதவர்களிடமிருந்து செய்திகளைப் பெறுங்கள்';

  @override
  String get settingsReadReceipts => 'ரசீதுகளைப் படிக்கவும்';

  @override
  String get settingsLetOthersKnowYouRead =>
      'நீங்கள் படித்ததை மற்றவர்களுக்கு தெரியப்படுத்துங்கள்';

  @override
  String get settingsTypingIndicator => 'தட்டச்சு காட்டி';

  @override
  String get settingsLetOthersKnowYouTyping =>
      'நீங்கள் தட்டச்சு செய்கிறீர்கள் என்பதை மற்றவர்களுக்குத் தெரியப்படுத்துங்கள்';

  @override
  String get settingsEveryone => 'அனைவரும்';

  @override
  String get settingsContactsOnly => 'தொடர்புகள் மட்டும்';

  @override
  String get settingsNobody => 'யாரும் இல்லை';

  @override
  String settingsWhoCanSeeTitle(String title) {
    return '$title யார் பார்க்கலாம்';
  }

  @override
  String settingsVersionInfo(String version) {
    return 'பதிப்பு $version';
  }

  @override
  String get settingsCheckForUpdates => 'புதுப்பிப்புகளைச் சரிபார்க்கவும்';

  @override
  String get settingsOpenSourceLicenses => 'திறந்த மூல உரிமங்கள்';

  @override
  String get settingsFeedbackAndSuggestions => 'கருத்து மற்றும் பரிந்துரைகள்';

  @override
  String get settingsBuiltOnMatrix => 'மேட்ரிக்ஸ் நெறிமுறையில் கட்டப்பட்டது';

  @override
  String get settingsNoHiddenChats => 'மறைக்கப்பட்ட அரட்டைகள் இல்லை';

  @override
  String get settingsNoHiddenChatsDescription =>
      'நீங்கள் மறைக்கும் அரட்டைகள் இங்கே தோன்றும்';

  @override
  String get settingsUnhideChat => 'மறை';

  @override
  String get settingsDarkMode => 'இருண்ட பயன்முறை';

  @override
  String get settingsFontSize => 'எழுத்துரு அளவு';

  @override
  String get settingsBubbleStyle => 'குமிழி நடை';

  @override
  String get settingsFollowSystem => 'முறையைப் பின்பற்றவும்';

  @override
  String get settingsAutoSwitchBySystem => 'கணினி மூலம் தானாக மாறவும்';

  @override
  String get settingsLightMode => 'ஒளி முறை';

  @override
  String get settingsAlwaysUseLightTheme => 'எப்போதும் ஒளி தீம் பயன்படுத்தவும்';

  @override
  String get settingsDarkModeOption => 'இருண்ட பயன்முறை விருப்பம்';

  @override
  String get settingsAlwaysUseDarkTheme =>
      'எப்போதும் இருண்ட தீம் பயன்படுத்தவும்';

  @override
  String get settingsFontSizeSmall => 'சிறியது';

  @override
  String get settingsFontSizeStandard => 'தரநிலை';

  @override
  String get settingsFontSizeLarge => 'பெரியது';

  @override
  String get settingsFontSizeExtraLarge => 'கூடுதல் பெரியது';

  @override
  String get settingsBubbleStyleWechat => 'WeChat பாணி';

  @override
  String get settingsBubbleStyleWechatDesc => 'கிளாசிக் WeChat குமிழி பாணி';

  @override
  String get settingsBubbleStyleModern => 'நவீன பாணி';

  @override
  String get settingsBubbleStyleModernDesc => 'சுத்தமான நவீன குமிழி பாணி';

  @override
  String get settingsBubbleStyleClassic => 'கிளாசிக் பாணி';

  @override
  String get settingsBubbleStyleClassicDesc => 'பாரம்பரிய குமிழி பாணி';

  @override
  String get discoverVideoChannels => 'சேனல்கள்';

  @override
  String get discoverLive => 'வாழ்க';

  @override
  String get discoverListen => 'கேள்';

  @override
  String get discoverWatch => 'பார்க்கவும்';

  @override
  String get discoverSearchDiscover => 'தேடு';

  @override
  String get discoverNearbyPeople => 'அருகில்';

  @override
  String get discoverGames => 'விளையாட்டுகள்';

  @override
  String get discoverMiniPrograms => 'மினி நிகழ்ச்சிகள்';

  @override
  String get chatAlreadyInCall => 'ஏற்கனவே அழைப்பில் உள்ளது';

  @override
  String get commonConnectionFailed => 'இணைப்பு தோல்வியடைந்தது';

  @override
  String get chatCallRejected => 'அழைப்பு நிராகரிக்கப்பட்டது';

  @override
  String get chatNoAnswer => 'பதில் இல்லை';

  @override
  String get commonClose => 'மூடு';

  @override
  String get chatSelectContact => 'தொடர்பைத் தேர்ந்தெடுக்கவும்';

  @override
  String get chatVoteRemoved => 'வாக்கு நீக்கப்பட்டது';

  @override
  String get chatVoteChanged => 'வாக்கு மாறியது';

  @override
  String get chatVoted => 'வாக்களித்தார்';

  @override
  String chatReplyTo(String name) {
    return '$name க்கு பதிலளிக்கவும்';
  }

  @override
  String get chatCurrentLocation => 'தற்போதைய இடம்';

  @override
  String chatNearbyPlace(int index) {
    return 'அருகிலுள்ள இடம் $index';
  }

  @override
  String chatApproximateDistance(String distance) {
    return '$distance பற்றி';
  }

  @override
  String get chatAddress => 'முகவரி';

  @override
  String get chatLatitude => 'அட்சரேகை';

  @override
  String get chatLongitude => 'தீர்க்கரேகை';

  @override
  String get groupDescriptionUpdated => 'குழு விளக்கம் புதுப்பிக்கப்பட்டது';

  @override
  String get groupAvatarUpdated => 'குழு அவதார் புதுப்பிக்கப்பட்டது';

  @override
  String get groupVisibilityUpdated => 'குழு தெரிவுநிலை புதுப்பிக்கப்பட்டது';

  @override
  String get groupChannelCreated => 'சேனல் உருவாக்கப்பட்டது';

  @override
  String get groupChannelUpdated => 'சேனல் புதுப்பிக்கப்பட்டது';

  @override
  String get groupChannelDeleted => 'சேனல் நீக்கப்பட்டது';

  @override
  String get callDecline => 'நிராகரி';

  @override
  String get callAnswer => 'பதில்';

  @override
  String get callIncomingVideoCall => 'உள்வரும் வீடியோ அழைப்பு';

  @override
  String get callIncomingVoiceCall => 'உள்வரும் குரல் அழைப்பு';

  @override
  String get callVideoCallInProgress => 'வீடியோ அழைப்பு செயலில் உள்ளது';

  @override
  String get callVoiceCallInProgress => 'குரல் அழைப்பு செயலில் உள்ளது';

  @override
  String get callReconnectingCall => 'மீண்டும் இணைக்கிறது...';

  @override
  String get callEnded => 'அழைப்பு முடிந்தது';

  @override
  String get callFailed => 'அழைப்பு தோல்வியடைந்தது';

  @override
  String get callLivekitNotConfigured => 'LiveKit உள்ளமைக்கப்படவில்லை';

  @override
  String callJoinMeetingFailed(String error) {
    return 'சந்திப்பில் சேர முடியவில்லை: $error';
  }

  @override
  String callScreenShareFailed(String error) {
    return 'திரைப் பகிர்வு தோல்வி: $error';
  }

  @override
  String get profileN42BeanTitle => 'N42 பீன்';

  @override
  String get profileNoN42Bean => 'N42 பீன் இல்லை';

  @override
  String get profileN42BeanDetails => 'N42 பீன் விவரங்கள்';

  @override
  String get profileN42BeanDescription =>
      'N42 பீன் என்பது N42 இல் மெய்நிகர் பொருட்கள் மற்றும் சேவைகளை மீட்டெடுக்கப் பயன்படும் டோக்கன் ஆகும். தற்போது கிடைக்கும்:';

  @override
  String get profileN42BeanFeature1 =>
      'பிரத்தியேக உறுப்பினர் ஸ்டிக்கர்கள் மற்றும் தீம்கள்';

  @override
  String get profileN42BeanFeature2 => 'அரட்டை குமிழி தனிப்பயனாக்கம்';

  @override
  String get profileN42BeanFeature3 => 'சிவப்பு பாக்கெட் கவர் தனிப்பயனாக்கம்';

  @override
  String get profileN42BeanFeature4 => 'பிரத்தியேக புனைப்பெயர் பேட்ஜ்';

  @override
  String get profileN42BeanFeature5 => 'குழு அரட்டை சலுகைகள்';

  @override
  String get profileN42BeanFeature6 => 'கிளவுட் சேமிப்பக விரிவாக்கம்';

  @override
  String get profileN42BeanFeature7 => 'வீடியோ அழைப்பு அழகு வடிப்பான்கள்';

  @override
  String get profileN42BeanFeature8 => 'தருணங்களின் பின்னணி தனிப்பயனாக்கம்';

  @override
  String get profileN42BeanFeature9 => 'விஐபி வாடிக்கையாளர் சேவை முன்னுரிமை';

  @override
  String get profileGotIt => 'கிடைத்தது';

  @override
  String get profileNoN42BeanRecords => 'N42 பீன் பதிவுகள் இல்லை';

  @override
  String get profileMoodAndThoughts => 'மனநிலை மற்றும் எண்ணங்கள்';

  @override
  String get profileStatusHappy => 'மகிழ்ச்சி';

  @override
  String get profileStatusCracked => 'நொறுங்கியது';

  @override
  String get profileStatusLucky => 'அதிர்ஷ்டசாலி';

  @override
  String get profileStatusSunny => 'சன்னி';

  @override
  String get profileStatusTired => 'சோர்வாக';

  @override
  String get profileStatusDaydream => 'பகல் கனவு';

  @override
  String get profileStatusRushing => 'விரைகிறது';

  @override
  String get profileStatusOverthinking => 'அதிகமாகச் சிந்திப்பது';

  @override
  String get profileStatusEnergized => 'உற்சாகமூட்டியது';

  @override
  String get profileWorkAndStudy => 'வேலை & படிப்பு';

  @override
  String get profileStatusWorking => 'வேலை';

  @override
  String get profileStatusStudying => 'படிக்கிறது';

  @override
  String get profileStatusBusy => 'பிஸி';

  @override
  String get profileStatusSlacking => 'தளர்ச்சி';

  @override
  String get profileStatusTraveling => 'பயணம்';

  @override
  String get profileStatusGoingHome => 'வீட்டிற்கு செல்கிறேன்';

  @override
  String get profileStatusDnd => 'தொந்தரவு செய்யாதே';

  @override
  String get profileActivities => 'செயல்பாடுகள்';

  @override
  String get profileStatusHanging => 'ஹேங் அவுட்';

  @override
  String get profileStatusCheckIn => 'செக் இன்';

  @override
  String get profileStatusExercising => 'உடற்பயிற்சி';

  @override
  String get profileStatusCoffee => 'காபி';

  @override
  String get profileStatusBubbleTea => 'குமிழி தேநீர்';

  @override
  String get profileStatusEating => 'சாப்பிடுவது';

  @override
  String get profileStatusParenting => 'குழந்தை வளர்ப்பு';

  @override
  String get profileStatusSavingWorld => 'உலகைக் காப்பாற்றுதல்';

  @override
  String get profileStatusSelfie => 'செல்ஃபி';

  @override
  String get profileRest => 'ஓய்வு';

  @override
  String get profileStatusRetreat => 'பின்வாங்கவும்';

  @override
  String get profileStatusHome => 'வீடு';

  @override
  String get profileStatusSleeping => 'தூங்குகிறது';

  @override
  String get profileStatusCatLover => 'பூனை காதலன்';

  @override
  String get profileStatusDogWalking => 'நடைபயிற்சி நாய்';

  @override
  String get profileStatusGaming => 'கேமிங்';

  @override
  String get profileStatusListening => 'கேட்பது';

  @override
  String get profileEditAddress => 'முகவரியைத் திருத்தவும்';

  @override
  String get profileRecipient => 'பெறுபவர்';

  @override
  String get profileEnterRecipientName => 'பெறுநரின் பெயரை உள்ளிடவும்';

  @override
  String get profilePhoneNumber => 'தொலைபேசி எண்';

  @override
  String get profileEnterPhoneNumber => 'தொலைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get profileRegionHint => 'மாகாணம்/நகரம்/மாவட்டம்';

  @override
  String get profileDetailedAddress => 'விரிவான முகவரி';

  @override
  String get profileDetailedAddressHint => 'தெரு, கட்டிட எண் போன்றவை.';

  @override
  String get profileSetAsDefaultAddress => 'இயல்புநிலை முகவரியாக அமைக்கவும்';

  @override
  String get profilePleaseCompleteInfo =>
      'அனைத்து புலங்களையும் பூர்த்தி செய்யவும்';

  @override
  String get profileEditInvoice => 'விலைப்பட்டியல் திருத்தவும்';

  @override
  String get profileInvoiceType => 'விலைப்பட்டியல் வகை';

  @override
  String get profileCompanyName => 'நிறுவனத்தின் பெயர்';

  @override
  String get profilePersonalName => 'தனிப்பட்ட பெயர்';

  @override
  String get profileEnterCompanyName => 'நிறுவனத்தின் பெயரை உள்ளிடவும்';

  @override
  String get profileEnterName => 'பெயரை உள்ளிடவும்';

  @override
  String get profileTaxIdNumber => 'வரி ஐடி எண்';

  @override
  String get profileEnterTaxIdNumber => 'வரி அடையாள எண்ணை உள்ளிடவும்';

  @override
  String get profileBankNameOptional => 'வங்கியின் பெயர் (விரும்பினால்)';

  @override
  String get profileEnterBankName => 'வங்கி பெயரை உள்ளிடவும்';

  @override
  String get profileBankAccountOptional => 'வங்கி கணக்கு (விரும்பினால்)';

  @override
  String get profileEnterBankAccount => 'வங்கிக் கணக்கை உள்ளிடவும்';

  @override
  String get profileCompanyAddressOptional =>
      'நிறுவனத்தின் முகவரி (விரும்பினால்)';

  @override
  String get profileEnterCompanyAddress => 'நிறுவனத்தின் முகவரியை உள்ளிடவும்';

  @override
  String get profileCompanyPhoneOptional =>
      'நிறுவனத்தின் தொலைபேசி (விரும்பினால்)';

  @override
  String get profileEnterCompanyPhone => 'நிறுவனத்தின் தொலைபேசியை உள்ளிடவும்';

  @override
  String get profileSetAsDefaultInvoice =>
      'இயல்புநிலை விலைப்பட்டியலாக அமைக்கவும்';

  @override
  String get profileRingtoneVibrate => 'அதிர்வு';

  @override
  String get profileRingtoneSilent => 'மௌனம்';

  @override
  String get profileVibrateMode => 'அதிர்வு முறை';

  @override
  String get profileSilentMode => 'அமைதியான முறை';

  @override
  String profilePlayFailed(String ringtoneName) {
    return 'விளையாடுவதில் தோல்வி: $ringtoneName';
  }

  @override
  String profilePlaying(String ringtoneName) {
    return 'விளையாடுவது: $ringtoneName';
  }

  @override
  String get profileStop => 'நிறுத்து';

  @override
  String get profileSelectRingtone => 'ரிங்டோனைத் தேர்ந்தெடுக்கவும்';

  @override
  String get profileLoadingRingtones => 'ரிங்டோன்களை ஏற்றுகிறது...';

  @override
  String get profileNoRingtonesFound => 'ரிங்டோன்கள் எதுவும் இல்லை';

  @override
  String mainMessagesWithCount(int count) {
    return 'செய்திகள்($count)';
  }

  @override
  String get storyViewers => 'பார்வையாளர்கள்';

  @override
  String get storyNoViewers => 'இன்னும் பார்வையாளர்கள் இல்லை';

  @override
  String get storyReplyToStory => 'கதைக்கு பதில்...';

  @override
  String get commonCopiedToClipboard => 'கிளிப்போர்டுக்கு நகலெடுக்கப்பட்டது';

  @override
  String get commonMore => 'மேலும்';

  @override
  String get commonTranslating => 'மொழிபெயர்க்கிறது...';

  @override
  String commonTranslatedFrom(String language) {
    return '$language இலிருந்து மொழிபெயர்க்கப்பட்டது';
  }

  @override
  String get commonTranslation => 'மொழிபெயர்ப்பு';

  @override
  String get commonTranslationFailed => 'மொழிபெயர்ப்பு தோல்வியடைந்தது';

  @override
  String get commonAllRead => 'அனைத்தும் படித்தது';

  @override
  String commonReadCount(int count) {
    return '$count படித்தேன்';
  }

  @override
  String get commonYouRecalledMessage =>
      'நீங்கள் ஒரு செய்தியை நினைவு கூர்ந்தீர்கள்';

  @override
  String get commonMessageRecalled => 'செய்தி நினைவுக்கு வந்தது';

  @override
  String get commonReEdit => 'மீண்டும் திருத்தவும்';

  @override
  String get commonWalletArea => 'பணப்பை பகுதி';

  @override
  String get callIncomingCall => 'உள்வரும் அழைப்பு';

  @override
  String get callMissedCall => 'தவறவிட்ட அழைப்பு';

  @override
  String get groupRemoveAdmin => 'நிர்வாகியை அகற்று';

  @override
  String get chatSelectCurrency => 'நாணயத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get chatSelectEmoji => 'ஈமோஜியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get chatSelectRedPacketCover => 'கவர் என்பதைத் தேர்ந்தெடுக்கவும்';

  @override
  String get groupSetAsAdmin => 'நிர்வாகியாக அமைக்கவும்';

  @override
  String get chatVideoPlaybackFailed => 'வீடியோ பிளேபேக் தோல்வியடைந்தது';

  @override
  String get groupViewProfile => 'சுயவிவரத்தைக் காண்க';

  @override
  String get favoriteAddLinkComingSoon => 'இணைப்பு அம்சத்தைச் சேர் விரைவில்';

  @override
  String get favoriteNewNoteComingSoon => 'புதிய குறிப்பு அம்சம் விரைவில்';

  @override
  String get qrcodeSaveFeatureComingSoon => 'சேவ் அம்சம் விரைவில் வரும்';

  @override
  String get qrcodeShareFeatureComingSoon => 'பகிர்வு அம்சம் விரைவில்';

  @override
  String qrcodeProcessFailed(String error) {
    return 'QR குறியீட்டைச் செயலாக்க முடியவில்லை: $error';
  }

  @override
  String get securityDeviceIdRequired => 'சாதன ஐடி தேவை';

  @override
  String securityVerificationStartFailed(String error) {
    return 'சரிபார்ப்பைத் தொடங்குவதில் தோல்வி: $error';
  }

  @override
  String get securityVerificationFailed => 'சரிபார்ப்பு தோல்வியடைந்தது';

  @override
  String securityVerificationFailedWithReason(String reason) {
    return 'சரிபார்ப்பு தோல்வியடைந்தது: $reason';
  }

  @override
  String get securityEmojiMismatchRejected =>
      'சரிபார்ப்பு நிராகரிக்கப்பட்டது - ஈமோஜி பொருந்தவில்லை';

  @override
  String get securityWaitingForDeviceAccept =>
      'மற்ற சாதனம் ஏற்கும் வரை காத்திருக்கிறது...';

  @override
  String get securityVerifyDevice => 'இந்தச் சாதனத்தைச் சரிபார்க்கவும்';

  @override
  String get securityConfirmEmojiMatch =>
      'கீழே உள்ள ஈமோஜிகள் இரண்டு சாதனங்களிலும் ஒரே வரிசையில் காட்டப்படுவதை உறுதிப்படுத்தவும்';

  @override
  String get securityEmojiDontMatch => 'அவை பொருந்தவில்லை';

  @override
  String get securityEmojiMatch => 'அவை பொருந்துகின்றன';

  @override
  String get securityWaitingForDeviceConfirm =>
      'மற்ற சாதனம் உறுதிசெய்ய காத்திருக்கிறது...';

  @override
  String get securityVerificationSuccess => 'சரிபார்ப்பு வெற்றி!';

  @override
  String get securityDeviceVerifiedTrusted =>
      'இந்தச் சாதனம் இப்போது சரிபார்க்கப்பட்டு நம்பகமானதாக உள்ளது.';

  @override
  String get securityCompareEmoji =>
      'இரண்டு சாதனங்களிலும் உள்ள ஈமோஜியை ஒப்பிடுக';

  @override
  String get securityCompareNumbers =>
      'இரண்டு சாதனங்களிலும் உள்ள எண்களை ஒப்பிடுக';

  @override
  String get commonTryAgain => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get commonDone => 'முடிந்தது';

  @override
  String get chatExportTitle => 'ஏற்றுமதி அரட்டை';

  @override
  String get chatExportSuccess => 'ஏற்றுமதி வெற்றி';

  @override
  String chatExportFailed(String error) {
    return 'ஏற்றுமதி தோல்வி: $error';
  }

  @override
  String get chatExportFormat => 'ஏற்றுமதி வடிவம்';

  @override
  String get chatExportHtmlDesc =>
      'பாணியிலான தளவமைப்புடன் எந்த உலாவியிலும் படிக்கக்கூடியது';

  @override
  String get chatExportJsonDesc =>
      'இயந்திரம் படிக்கக்கூடிய கட்டமைக்கப்பட்ட தரவு வடிவம்';

  @override
  String get chatExportDateRange => 'தேதி வரம்பு';

  @override
  String get chatExportAll => 'அனைத்து செய்திகளும்';

  @override
  String get chatExportLastWeek => 'கடந்த 7 நாட்கள்';

  @override
  String get chatExportLastMonth => 'கடந்த மாதம்';

  @override
  String get chatExportLast3Months => 'கடந்த 3 மாதங்கள்';

  @override
  String get chatExportMessageCount => 'ஏற்றுமதி செய்ய வேண்டிய செய்திகள்';

  @override
  String get chatExportButton => 'ஏற்றுமதி & பகிர்';

  @override
  String get chatMediaGallery => 'மீடியா கேலரி';

  @override
  String get chatExportHistory => 'அரட்டை வரலாற்றை ஏற்றுமதி செய்யவும்';

  @override
  String get pdfLoadFailed => 'PDFஐ ஏற்ற முடியவில்லை';

  @override
  String pdfPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get mediaAll => 'அனைத்து';

  @override
  String get mediaImages => 'படங்கள்';

  @override
  String get mediaVideos => 'வீடியோக்கள்';

  @override
  String get mediaFiles => 'கோப்புகள்';

  @override
  String get mediaAudio => 'ஆடியோ';

  @override
  String mediaItemsCount(int count) {
    return '$count உருப்படிகள்';
  }

  @override
  String get mediaNoMediaFound => 'மீடியா எதுவும் இல்லை';

  @override
  String get spacesTitle => 'சமூகங்கள்';

  @override
  String get spacesCreate => 'சமூகத்தை உருவாக்குங்கள்';

  @override
  String get spacesJoined => 'சேர்ந்தார்';

  @override
  String get spacesDiscover => 'கண்டறியவும்';

  @override
  String get spacesNoJoined => 'இதுவரை எந்த சமூகமும் சேரவில்லை';

  @override
  String get spacesExplore => 'சமூகங்களை ஆராயுங்கள்';

  @override
  String get spacesNoPublic => 'பொது சமூகங்கள் எதுவும் இல்லை';

  @override
  String get spacesJoin => 'சேருங்கள்';

  @override
  String get spacesSubSpaces => 'துணை சமூகங்கள்';

  @override
  String get spacesChannels => 'சேனல்கள்';

  @override
  String spacesMembersCount(int count) {
    return '$count உறுப்பினர்கள்';
  }

  @override
  String get spacesPublic => 'பொது';

  @override
  String get spacesPrivate => 'தனியார்';

  @override
  String get spacesSuggested => 'பரிந்துரைக்கப்பட்டது';

  @override
  String spacesChannelsCount(int count) {
    return '$count சேனல்கள்';
  }

  @override
  String get callInCallChat => 'அழைப்பு அரட்டை';

  @override
  String callMessagesCount(int count) {
    return '$count செய்திகள்';
  }

  @override
  String get callNoMessagesYet =>
      'இதுவரை செய்திகள் இல்லை.\nதொடங்குவதற்கு ஒரு செய்தியை அனுப்பவும்.';

  @override
  String get callTypeMessage => 'செய்தியை உள்ளிடவும்...';

  @override
  String get callYouSender => 'நீங்கள்';

  @override
  String get callChatLabel => 'அரட்டை';

  @override
  String get chatEdited => 'திருத்தப்பட்டது';

  @override
  String get chatEditHistory => 'வரலாற்றைத் திருத்தவும்';

  @override
  String get chatOriginalMessage => 'அசல்';

  @override
  String chatEditedAt(String time) {
    return '$time இல் திருத்தப்பட்டது';
  }

  @override
  String get chatViewOnce => 'ஒருமுறை பார்க்கவும்';

  @override
  String get chatViewOncePhoto => 'புகைப்படத்தை ஒருமுறை பார்க்கவும்';

  @override
  String get chatViewOnceVideo => 'வீடியோவை ஒருமுறை பார்க்கவும்';

  @override
  String get chatViewOnceViewed => 'பார்க்கப்பட்டது';

  @override
  String get chatViewOnceExpired => 'காலாவதியானது';

  @override
  String get chatViewOnceTap => 'பார்க்க தட்டவும்';

  @override
  String get chatAutoFaceBlur => 'ஆட்டோ முகம் மங்கலாகிறது';

  @override
  String get chatAutoFaceBlurDesc =>
      'புகைப்படங்களை அனுப்பும் போது தானாகவே முகங்களை மங்கலாக்கும்';

  @override
  String get threadReplyInThread => 'இழையில் பதிலளிக்கவும்';

  @override
  String threadReplies(int count) {
    return '$count பதில்கள்';
  }

  @override
  String get threadReply => '1 பதில்';

  @override
  String threadLatestReply(String preview) {
    return 'சமீபத்தியது: $preview';
  }

  @override
  String get threadTitle => 'நூல்';

  @override
  String get threadReplyPlaceholder => 'இழையில் பதிலளிக்கவும்...';

  @override
  String threadParticipants(int count) {
    return '$count பங்கேற்பாளர்கள்';
  }

  @override
  String get voiceRoomTitle => 'குரல் அறை';

  @override
  String get voiceRoomCreate => 'குரல் அறையை உருவாக்கவும்';

  @override
  String get voiceRoomJoin => 'சேருங்கள்';

  @override
  String get voiceRoomLeave => 'கிளம்பு';

  @override
  String get voiceRoomEnd => 'இறுதி அறை';

  @override
  String get voiceRoomRaiseHand => 'கையை உயர்த்துங்கள்';

  @override
  String get voiceRoomLowerHand => 'கீழ் கை';

  @override
  String get voiceRoomMute => 'முடக்கு';

  @override
  String get voiceRoomUnmute => 'ஒலியடக்கவும்';

  @override
  String get voiceRoomHost => 'புரவலன்';

  @override
  String get voiceRoomSpeakers => 'பேச்சாளர்கள்';

  @override
  String get voiceRoomListeners => 'கேட்போர்';

  @override
  String get voiceRoomLive => 'நேரலை';

  @override
  String get voiceRoomEnded => 'முடிந்தது';

  @override
  String get voiceRoomScheduled => 'திட்டமிடப்பட்டது';

  @override
  String get voiceRoomApprove => 'ஒப்புதல்';

  @override
  String get voiceRoomDemote => 'கேட்பவருக்கு நகர்த்தவும்';

  @override
  String voiceRoomHandRaised(String name) {
    return '$name கையை உயர்த்தியது';
  }

  @override
  String get voiceRoomName => 'அறையின் பெயர்';

  @override
  String get voiceRoomTopic => 'தலைப்பு (விரும்பினால்)';

  @override
  String get voiceRoomNoActive => 'செயலில் குரல் அறைகள் இல்லை';

  @override
  String get voiceRoomConnecting => 'இணைக்கிறது...';

  @override
  String get usernameTitle => 'பயனர் பெயர்';

  @override
  String get usernameSet => 'பயனர்பெயரை அமைக்கவும்';

  @override
  String get usernameChange => 'பயனர் பெயரை மாற்றவும்';

  @override
  String get usernamePlaceholder => 'பயனர் பெயரை உள்ளிடவும்';

  @override
  String get usernameAvailable => 'பயனர் பெயர் உள்ளது';

  @override
  String get usernameUnavailable => 'பயனர் பெயர் ஏற்கனவே எடுக்கப்பட்டது';

  @override
  String get usernameInvalid =>
      '3-30 எழுத்துகள், சிறிய எழுத்துக்கள், எண்கள், அடிக்கோடிட்டு. கடிதத்துடன் தொடங்க வேண்டும்.';

  @override
  String get usernameReserved => 'இந்த பயனர்பெயர் ஒதுக்கப்பட்டுள்ளது';

  @override
  String get usernameSaved => 'பயனர் பெயர் சேமிக்கப்பட்டது';

  @override
  String get usernameSearchHint => '@username மூலம் தேடவும்';

  @override
  String get ensName => 'ENS பெயர்';

  @override
  String get ensLinked => 'ENS உடன் இணைக்கப்பட்டுள்ளது';

  @override
  String get ensResolving => 'ENS ஐ தீர்க்கிறது...';

  @override
  String get ensNotFound => 'ENS பெயர் கிடைக்கவில்லை';

  @override
  String get tokenGateTitle => 'டோக்கன் கேட்';

  @override
  String get tokenGateEnable => 'டோக்கன் கேட்டை இயக்கவும்';

  @override
  String get tokenGateDisable => 'டோக்கன் கேட்டை முடக்கு';

  @override
  String get tokenGateAddRule => 'விதியைச் சேர்க்கவும்';

  @override
  String get tokenGateRemoveRule => 'விதியை அகற்று';

  @override
  String get tokenGateContractAddress => 'ஒப்பந்த முகவரி';

  @override
  String get tokenGateMinBalance => 'குறைந்தபட்ச இருப்பு';

  @override
  String get tokenGateTokenId => 'டோக்கன் ஐடி (ERC-1155)';

  @override
  String get tokenGateChainId => 'சங்கிலி ஐடி';

  @override
  String get tokenGateVerifying => 'டோக்கன் வைத்திருப்பதைச் சரிபார்க்கிறது...';

  @override
  String get tokenGateVerified => 'சரிபார்ப்பு நிறைவேற்றப்பட்டது';

  @override
  String get tokenGateDenied => 'டோக்கன் தேவைகளை நீங்கள் பூர்த்தி செய்யவில்லை';

  @override
  String get tokenGateOperatorAnd =>
      'அனைத்து விதிகளையும் பூர்த்தி செய்ய வேண்டும்';

  @override
  String get tokenGateOperatorOr => 'எந்த விதியையும் சந்திக்க வேண்டும்';

  @override
  String get tokenGateRuleErc20 => 'ERC-20 டோக்கன்';

  @override
  String get tokenGateRuleErc721 => 'NFT (ERC-721)';

  @override
  String get tokenGateRuleErc1155 => 'மல்டி-டோக்கன் (ERC-1155)';

  @override
  String get tokenGateRuleNative => 'பூர்வீக டோக்கன்';

  @override
  String get tokenGateSaved => 'டோக்கன் கேட் சேமிக்கப்பட்டது';

  @override
  String get tokenGateEnableDescription =>
      'உறுப்பினர்கள் சேர டோக்கன்களை வைத்திருக்க வேண்டும்';

  @override
  String get tokenGateOperator => 'விதி தர்க்கம்';

  @override
  String get tokenGateRules => 'விதிகள்';

  @override
  String get tokenGateSymbol => 'சின்னம் (விரும்பினால்)';

  @override
  String get tokenGateChain => 'சங்கிலி';

  @override
  String get tokenGateTokenStandard => 'டோக்கன் தரநிலை';

  @override
  String get tokenGateDenialMessage => 'மறுப்புச் செய்தி';

  @override
  String get tokenGateDenialMessageHint =>
      'சரிபார்ப்பு தோல்வியுற்றால் செய்தி காட்டப்படும்';

  @override
  String get tokenGateVerifyTitle => 'டோக்கன் சரிபார்ப்பு';

  @override
  String get tokenGateVerifyPassed => 'சரிபார்ப்பு நிறைவேற்றப்பட்டது';

  @override
  String get tokenGateVerifyFailed => 'சரிபார்ப்பு தோல்வியடைந்தது';

  @override
  String get tokenGateRetryVerify => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get tokenGateRequired => 'தேவை';

  @override
  String get tokenGateYourBalance => 'உங்கள் இருப்பு';

  @override
  String get tokenGateRulesActive => 'செயலில் உள்ள விதிகள்';

  @override
  String get tokenGateDisabled => 'முடக்கப்பட்டது';

  @override
  String get ensNotBound => 'கட்டுப்படவில்லை';

  @override
  String get liveLocation => 'நேரடி இடம்';

  @override
  String get stopLiveLocation => 'பகிர்வதை நிறுத்து';

  @override
  String get startLiveLocation => 'பகிரத் தொடங்கு';

  @override
  String get selectDuration => 'கால அளவைத் தேர்ந்தெடுக்கவும்';

  @override
  String get groupChatFiles => 'அரட்டை கோப்புகள்';

  @override
  String get groupLinks => 'இணைப்புகள்';

  @override
  String get groupNoLinks => 'இன்னும் இணைப்புகள் இல்லை';

  @override
  String get chatBackground => 'அரட்டை பின்னணி';

  @override
  String get solidColors => 'திட நிறங்கள்';

  @override
  String get gradients => 'சாய்வுகள்';

  @override
  String get defaultBackground => 'இயல்புநிலை';

  @override
  String get settingsFontSizeSlider => 'எழுத்துரு அளவு';

  @override
  String get autoDownload => 'தானியங்கு-பதிவிறக்கம்';

  @override
  String get images => 'படங்கள்';

  @override
  String get voice => 'குரல்';

  @override
  String get video => 'வீடியோ';

  @override
  String get files => 'கோப்புகள்';

  @override
  String get mobileData => 'மொபைல் டேட்டா';

  @override
  String get roaming => 'ரோமிங்';

  @override
  String get storageManagement => 'சேமிப்பு';

  @override
  String get totalUsage => 'மொத்த பயன்பாடு';

  @override
  String get cache => 'தற்காலிக சேமிப்பு';

  @override
  String get other => 'மற்றவை';

  @override
  String get clearCache => 'தற்காலிக சேமிப்பை அழிக்கவும்';

  @override
  String get cacheCleared => 'தற்காலிக சேமிப்பு அழிக்கப்பட்டது';

  @override
  String get clearCacheFailed => 'தற்காலிக சேமிப்பை அழிக்க முடியவில்லை';

  @override
  String get confirmClearCache => 'அனைத்து கேச் தரவையும் அழிக்கவா?';

  @override
  String get mapView => 'வரைபடக் காட்சி';

  @override
  String liveLocationSharingCount(int count) {
    return '$count நபர்கள் இருப்பிடத்தைப் பகிர்கின்றனர்';
  }

  @override
  String get minutes15 => '15 நிமிடங்கள்';

  @override
  String get minutes30 => '30 நிமிடங்கள்';

  @override
  String get hour1 => '1 மணிநேரம்';

  @override
  String get hours8 => '8 மணி நேரம்';

  @override
  String get personalCard => 'தனிப்பட்ட அட்டை';

  @override
  String get downloadFailed => 'பதிவிறக்கம் தோல்வியடைந்தது';

  @override
  String get locationExpired => 'காலாவதியானது';

  @override
  String secondsRemaining(int count) {
    return '$countகள்';
  }

  @override
  String minutesRemaining(int count) {
    return '$count நிமிடங்கள்';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '$hours மணிநேரம் $minutes நிமிடங்கள்';
  }

  @override
  String get favoriteMessages => 'பிடித்தவை';

  @override
  String get linksCopied => 'இணைப்பு நகலெடுக்கப்பட்டது';

  @override
  String get noLinksFound => 'இணைப்புகள் எதுவும் இல்லை';

  @override
  String get roomStorageRanking => 'அறை சேமிப்பு தரவரிசை';

  @override
  String get downloadComplete => 'பதிவிறக்கம் முடிந்தது';

  @override
  String get downloading => 'பதிவிறக்குகிறது...';

  @override
  String get draftSaved => 'வரைவு சேமிக்கப்பட்டது';

  @override
  String get voiceRecording => 'குரல் பதிவு';

  @override
  String get searchLocation => 'இருப்பிடத்தைத் தேடுங்கள்';

  @override
  String get tapToSearch => 'தேட தட்டவும்';

  @override
  String get settingsThisDevice => 'இந்த சாதனம்';

  @override
  String get settingsJustNow => 'இப்போதுதான்';

  @override
  String get settingsDeviceId => 'சாதன ஐடி';

  @override
  String get settingsStatus => 'நிலை';

  @override
  String get settingsLastActive => 'கடைசியாக செயல்பட்டது';

  @override
  String get settingsIpAddress => 'ஐபி முகவரி';

  @override
  String get settingsRenameDevice => 'சாதனத்தை மறுபெயரிடவும்';

  @override
  String get settingsDeviceNameHint => 'சாதனத்தின் பெயரை உள்ளிடவும்';

  @override
  String get settingsDeviceRenamed => 'சாதனம் பெயர் மாற்றப்பட்டது';

  @override
  String get settingsRenameFailed => 'மறுபெயரிட முடியவில்லை';

  @override
  String get settingsRemoteLogout => 'ரிமோட் லாக்அவுட்';

  @override
  String settingsRemoteLogoutConfirm(String deviceName) {
    return '\"$deviceName\" இலிருந்து நிச்சயமாக வெளியேற விரும்புகிறீர்களா? இந்தச் செயலைச் செயல்தவிர்க்க முடியாது.';
  }

  @override
  String get settingsDeviceLoggedOut => 'சாதனம் வெளியேறியது';

  @override
  String get settingsLogoutFailed => 'வெளியேற முடியவில்லை';

  @override
  String get settingsLogout => 'வெளியேறு';

  @override
  String get settingsVerifyIdentity => 'அடையாளத்தைச் சரிபார்க்கவும்';

  @override
  String get settingsEnterPasswordToConfirm =>
      'இந்த செயலை உறுதிப்படுத்த உங்கள் கடவுச்சொல்லை உள்ளிடவும்.';

  @override
  String get scheduledSendTitle => 'அட்டவணை செய்தி';

  @override
  String get scheduledSendInOneHour => '1 மணி நேரத்தில்';

  @override
  String get scheduledSendTonight => 'இன்று இரவு (8:00 PM)';

  @override
  String get scheduledSendTomorrowMorning => 'நாளை காலை (9:00 AM)';

  @override
  String get scheduledSendCustom => 'தேதி & நேரத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get scheduledMessageLabel => 'திட்டமிடப்பட்டது';

  @override
  String get scheduledMessageCancel => 'திட்டமிடப்பட்ட செய்தியை ரத்துசெய்';

  @override
  String get chatLockTitle => 'அரட்டை பூட்டு';

  @override
  String get chatLockEnable => 'இந்த அரட்டையைப் பூட்டவும்';

  @override
  String get chatLockDisable => 'இந்த அரட்டையைத் திறக்கவும்';

  @override
  String get chatLockDescription =>
      'பூட்டப்பட்ட அரட்டைகளைத் திறக்க பயோமெட்ரிக் அல்லது பின் சரிபார்ப்பு தேவை';

  @override
  String get chatLockVerifyTitle => 'அரட்டை பூட்டப்பட்டது';

  @override
  String get chatLockVerifySubtitle => 'இந்த அரட்டையை அணுக சரிபார்க்கவும்';

  @override
  String get chatLockVerifyFailed => 'சரிபார்ப்பு தோல்வியடைந்தது';

  @override
  String get chatLockEnabled => 'அரட்டை பூட்டப்பட்டது';

  @override
  String get chatLockDisabled => 'அரட்டை திறக்கப்பட்டது';

  @override
  String get chatLockPinTitle => 'பின்னை உள்ளிடவும்';

  @override
  String get chatLockPinSetTitle => 'பின்னை அமைக்கவும்';

  @override
  String get chatLockPinConfirmTitle => 'பின்னை உறுதிப்படுத்தவும்';

  @override
  String get chatLockPinMismatch => 'பின் பொருந்தவில்லை';

  @override
  String get chatLockUseBiometric => 'பயோமெட்ரிக் பயன்படுத்தவும்';

  @override
  String get chatLockUsePin => 'பின்னைப் பயன்படுத்தவும்';

  @override
  String get mediaEditorUndo => 'செயல்தவிர்';

  @override
  String get mediaEditorRedo => 'மீண்டும் செய்';

  @override
  String get mediaEditorCrop => 'பயிர்';

  @override
  String get mediaEditorFilter => 'வடிகட்டி';

  @override
  String get mediaEditorDraw => 'வரையவும்';

  @override
  String get mediaEditorText => 'உரை';

  @override
  String get aiAssistant => 'AI உதவியாளர்';

  @override
  String get aiAssistantWelcome =>
      'வணக்கம்! நான் N42 AI உதவியாளர். நான் உங்களுக்கு எப்படி உதவ முடியும்?';

  @override
  String get aiAssistantNotConfigured => 'AI சேவை உள்ளமைக்கப்படவில்லை';

  @override
  String get aiAssistantSettings => 'AI அமைப்புகள்';

  @override
  String get aiAssistantClearHistory => 'அரட்டை வரலாற்றை அழிக்கவும்';

  @override
  String get aiAssistantClearHistoryConfirm =>
      'அனைத்து AI அரட்டை வரலாற்றையும் அழிக்க விரும்புகிறீர்களா?';

  @override
  String get aiAssistantStopGenerating => 'உருவாக்குவதை நிறுத்துங்கள்';

  @override
  String get aiAssistantModel => 'மாதிரி';

  @override
  String get aiAssistantTemperature => 'வெப்பநிலை';

  @override
  String get aiAssistantMaxTokens => 'அதிகபட்ச டோக்கன்கள்';

  @override
  String get aiAssistantContextWindow => 'சூழல் சாளரம்';

  @override
  String get aiAssistantServiceStatus => 'சேவை நிலை';

  @override
  String get aiAssistantAvailable => 'கிடைக்கும்';

  @override
  String get aiAssistantUnavailable => 'கிடைக்கவில்லை';

  @override
  String get aiSummarize => 'AI சுருக்கம்';

  @override
  String aiSummarizeUnread(int count) {
    return '$count படிக்காத செய்திகளை சுருக்கவும்';
  }

  @override
  String get aiSummarizeLoading => 'சுருக்கமாக...';

  @override
  String get aiSummarizeError => 'சுருக்கமாக கூற முடியவில்லை';

  @override
  String get aiRewrite => 'AI மீண்டும் எழுதுதல்';

  @override
  String get aiRewriteFormal => 'முறையான';

  @override
  String get aiRewriteCasual => 'சாதாரண';

  @override
  String get aiRewritePlayful => 'விளையாட்டுத்தனமான';

  @override
  String get aiRewriteProfessional => 'தொழில்முறை';

  @override
  String get aiRewriteAccept => 'பயன்படுத்தவும்';

  @override
  String get aiRewriteCancel => 'ரத்து செய்';

  @override
  String get aiRewriteLoading => 'மீண்டும் எழுதுகிறது...';

  @override
  String get aiLinkSummary => 'AI சுருக்கம்';

  @override
  String get aiLinkSummaryAnalyzing => 'பகுப்பாய்வு செய்கிறது...';

  @override
  String get chatFolderManagement => 'கோப்புறைகளை நிர்வகிக்கவும்';

  @override
  String get chatFolderSystem => 'கணினி கோப்புறைகள்';

  @override
  String get chatFolderCustom => 'தனிப்பயன் கோப்புறைகள்';

  @override
  String get chatFolderEmpty => 'இதுவரை தனிப்பயன் கோப்புறைகள் இல்லை';

  @override
  String get chatFolderCreate => 'கோப்புறையை உருவாக்கவும்';

  @override
  String get chatFolderEdit => 'கோப்புறையைத் திருத்து';

  @override
  String get chatFolderNameHint => 'கோப்புறை பெயர்';

  @override
  String get chatFolderAll => 'அனைத்து';

  @override
  String get chatFolderUnread => 'படிக்காதது';

  @override
  String get chatFolderPersonal => 'தனிப்பட்ட';

  @override
  String get chatFolderGroups => 'குழுக்கள்';

  @override
  String get chatFolderChannels => 'சேனல்கள்';

  @override
  String get chatFolderMuted => 'முடக்கப்பட்டது';

  @override
  String get storyAddMusic => 'இசையைச் சேர்க்கவும்';

  @override
  String get storyChangeMusic => 'இசையை மாற்றவும்';

  @override
  String get storyBackgroundMusic => 'பின்னணி இசை';

  @override
  String get storyMusicPreview => 'முன்னோட்டம் (அதிகபட்சம் 15வி)';

  @override
  String get storyChooseFromDevice => 'சாதனத்திலிருந்து தேர்வு செய்யவும்';

  @override
  String get storyUseThisMusic => 'இந்த இசையைப் பயன்படுத்தவும்';

  @override
  String get authPasskeyNotSupported =>
      'இந்தச் சாதனத்தில் Passkey ஆதரிக்கப்படவில்லை';

  @override
  String get authPasskeyRegister => 'பதிவு பாஸ்கி';

  @override
  String get authPasskeyNoRegistered =>
      'எந்த கடவுச்சீட்டுகளும் பதிவு செய்யப்படவில்லை';

  @override
  String get authPasskeyRegisterHint =>
      'இந்தக் கணக்கிற்கான கடவுச் சாவியைப் பதிவு செய்யவும். தனித்த கடவுச்சொல் உள்நுழைவு பின்னர் இயக்கப்படும்.';

  @override
  String get authPasskeyNameYours => 'உங்கள் பாஸ்கிக்கு பெயரிடவும்';

  @override
  String get authPasskeyRegistered =>
      'கடவுச்சொல் இந்தக் கணக்கில் சேமிக்கப்பட்டது';

  @override
  String get authPasskeyDeleted =>
      'இந்தக் கணக்கிலிருந்து கடவுச்சொல் அகற்றப்பட்டது';

  @override
  String authPasskeyDeleteConfirm(String name) {
    return '\"$name\" கடவுவிசையை நீக்கவா? கடவுச்சொல் உள்நுழைவைப் பயன்படுத்துவதற்கு முன்பு அதை மீண்டும் பதிவு செய்ய வேண்டும்.';
  }

  @override
  String get momentVisibilityPublic => 'பொது';

  @override
  String get momentVisibilityPrivate => 'தனியார்';

  @override
  String get momentVisibilityPartial => 'தேர்ந்தெடுக்கப்பட்ட நண்பர்கள்';

  @override
  String get momentVisibilityExcluded => 'சில நண்பர்களை தவிர்த்து விடுங்கள்';

  @override
  String momentUserMoments(String userName) {
    return '$userName இன் தருணங்கள்';
  }

  @override
  String get momentForwardTo => 'முன்னோக்கி';

  @override
  String get momentForwardSuccess => 'வெற்றிகரமாக அனுப்பப்பட்டது';

  @override
  String get momentSelectFriends => 'நண்பர்களைத் தேர்ந்தெடுக்கவும்';

  @override
  String get momentSelectTags => 'குறிச்சொற்கள் மூலம் தேர்ந்தெடுக்கவும்';

  @override
  String momentSelectedCount(int count) {
    return 'தேர்ந்தெடுக்கப்பட்டது ($count)';
  }

  @override
  String get momentNoMomentsYet => 'இன்னும் தருணங்கள் இல்லை';

  @override
  String get momentForwardMoment => 'முன்னோக்கி தருணம்';

  @override
  String get momentAddComment => 'கருத்தைச் சேர்...';

  @override
  String momentForwardContent(String content) {
    return '[தருணம்] $content';
  }

  @override
  String get momentDeleteMoment => 'தருணத்தை நீக்கு';

  @override
  String get momentDeleteConfirm =>
      'இந்த தருணத்தை நிச்சயமாக நீக்க விரும்புகிறீர்களா?';

  @override
  String get momentComment => 'கருத்து';

  @override
  String get momentWriteComment => 'கருத்து எழுது...';

  @override
  String get momentLike => 'பிடிக்கும்';

  @override
  String get momentUnlike => 'போலல்லாமல்';

  @override
  String get momentForward => 'முன்னோக்கி';

  @override
  String get momentDelete => 'நீக்கு';

  @override
  String get momentReply => 'பதில்';

  @override
  String get momentMoment => 'கணம்';

  @override
  String momentLikesCount(int count) {
    return '$count விரும்புகிறது';
  }

  @override
  String momentCommentsCount(int count) {
    return '$count கருத்துகள்';
  }

  @override
  String get momentNoComments => 'இதுவரை கருத்துகள் இல்லை';

  @override
  String get momentFailedToLoad => 'படத்தை ஏற்ற முடியவில்லை';

  @override
  String momentReplyTo(String userName) {
    return '$userName க்கு பதிலளிக்கவும்...';
  }

  @override
  String get momentNoConversations => 'உரையாடல்கள் இல்லை';

  @override
  String get momentJustNow => 'இப்போது தான்';

  @override
  String momentMinutesAgo(int count) {
    return '${count}m முன்பு';
  }

  @override
  String momentHoursAgo(int count) {
    return '${count}h முன்பு';
  }

  @override
  String momentDaysAgo(int count) {
    return '${count}d முன்பு';
  }

  @override
  String get chatGroupAnnouncementHint => 'குழு அறிவிப்பை உள்ளிடவும்';

  @override
  String get chatGroupAnnouncementEmpty => 'அறிவிப்பு இல்லை';

  @override
  String get chatEditNickname => 'புனைப்பெயரை திருத்து';

  @override
  String get chatNicknameHint => 'இந்த குழுவில் உங்கள் புனைப்பெயரை உள்ளிடவும்';

  @override
  String get contactAddPhoneHint => 'தொலைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get contactNotesHint =>
      'இந்தத் தொடர்பைப் பற்றிய குறிப்புகளைச் சேர்க்கவும்';

  @override
  String get reportTitle => 'அறிக்கை';

  @override
  String get reportReasonSpam => 'ஸ்பேம்';

  @override
  String get reportReasonHarassment => 'துன்புறுத்தல்';

  @override
  String get reportReasonFraud => 'மோசடி';

  @override
  String get reportReasonOther => 'மற்றவை';

  @override
  String get reportSubmitted => 'அறிக்கை சமர்ப்பிக்கப்பட்டது';

  @override
  String get reportDescription => 'கூடுதல் விளக்கம் (விரும்பினால்)';

  @override
  String get qrcodeSaved => 'QR குறியீடு ஆல்பத்தில் சேமிக்கப்பட்டது';

  @override
  String get chatSendRedPacketInChat =>
      'அரட்டையில் சிவப்பு பொட்டலத்தை அனுப்பவும்';

  @override
  String get commonSaveFailed => 'சேமிக்க முடியவில்லை';

  @override
  String get reportSelectReason => 'தயவுசெய்து காரணத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get gameCenter => 'விளையாட்டுகள்';

  @override
  String get gameHighScore => 'சிறந்த';

  @override
  String get gameScore => 'மதிப்பெண்';

  @override
  String get gameOver => 'விளையாட்டு முடிந்தது';

  @override
  String get gamePlayAgain => 'மீண்டும் விளையாடு';

  @override
  String get gameLeaderboard => 'லீடர்போர்டு';

  @override
  String get gamePause => 'இடைநிறுத்தப்பட்டது';

  @override
  String get gameResume => 'மீண்டும் தொடங்க தட்டவும்';

  @override
  String get gameConfirmExit => 'இந்த விளையாட்டிலிருந்து வெளியேறவா?';

  @override
  String get gameNoScores => 'இன்னும் மதிப்பெண்கள் இல்லை';

  @override
  String get game2048 => '2048';

  @override
  String get game2048Desc => '2048 ஐ அடைய ஓடுகளை ஒன்றிணைக்கவும்';

  @override
  String get gameBlockDrop => 'பிளாக் டிராப்';

  @override
  String get gameBlockDropDesc => 'துளி மற்றும் தெளிவான வரிகளை';

  @override
  String get gameMinesweeper => 'மைன்ஸ்வீப்பர்';

  @override
  String get gameMinesweeperDesc => 'அனைத்து பாதுகாப்பான செல்களைக் கண்டறியவும்';

  @override
  String get gameMatch3 => 'போட்டி 3';

  @override
  String get gameMatch3Desc => '3 அல்லது அதற்கு மேற்பட்ட கற்களை பொருத்தவும்';

  @override
  String get gameMinesweeperEasy => 'எளிதானது';

  @override
  String get gameMinesweeperMedium => 'நடுத்தர';

  @override
  String get gameMinesLeft => 'சுரங்கங்கள் விட்டு';

  @override
  String get gameTimeLeft => 'நேரம்';

  @override
  String get gameLevel => 'நிலை';

  @override
  String get gameNext => 'அடுத்து';

  @override
  String get gameBestTime => 'சிறந்த நேரம்';

  @override
  String get gameNewRecord => 'புதிய சாதனை!';

  @override
  String get gameLines => 'கோடுகள்';

  @override
  String get storyMyStory => 'என் கதை';

  @override
  String get storageSmartCleanup => 'ஸ்மார்ட் துப்புரவு';

  @override
  String get storageOldMediaFiles => 'பழைய மீடியா கோப்புகள்';

  @override
  String get storageLargeFiles => 'பெரிய கோப்புகள்';

  @override
  String get storageAppCache => 'ஆப் கேச்';

  @override
  String get storageSettings => 'சேமிப்பக அமைப்புகள்';

  @override
  String get storageAutoCleanup => 'தானாக சுத்தம் செய்தல்';

  @override
  String storageAutoCleanupDesc(int days) {
    return '$days நாட்களை விட பழைய கோப்புகளை தானாக சுத்தம் செய்யவும்';
  }

  @override
  String get storageCleanupPeriod => 'சுத்தம் செய்யும் காலம்';

  @override
  String get storagePreserveThumbnails => 'சிறுபடங்களைப் பாதுகாக்கவும்';

  @override
  String get storagePreserveThumbnailsDesc =>
      'சுத்தம் செய்யும் போது படத்தின் சிறுபடங்களை வைத்திருங்கள்';

  @override
  String get storageWarningHigh =>
      'சேமிப்பக பயன்பாடு அதிகம். பழைய கோப்புகளை சுத்தம் செய்வதைக் கவனியுங்கள்.';

  @override
  String get storageWarningCritical =>
      'சேமிப்பு மிகவும் குறைவாக உள்ளது. தயவு செய்து இலவச இடத்தை சுத்தம் செய்யவும்.';

  @override
  String storageFreed(String size, int count) {
    return 'விடுவிக்கப்பட்ட $size ($count கோப்புகள்)';
  }

  @override
  String storageDays(int days) {
    return '$days நாட்கள்';
  }

  @override
  String storageViewAllRooms(int count) {
    return 'அனைத்து $count அறைகளையும் காண்க';
  }

  @override
  String get storageNoFiles => 'கோப்புகள் எதுவும் இல்லை';

  @override
  String get storageFilePinned => 'பின் செய்யப்பட்டது';

  @override
  String storageDeleteSelected(int count) {
    return '$count தேர்ந்தெடுத்த கோப்புகளை நீக்கவா? அவை சேவையகத்திலிருந்து மீண்டும் பதிவிறக்கம் செய்யப்படலாம்.';
  }

  @override
  String get backupRestore => 'காப்புப்பிரதி & மீட்டமை';

  @override
  String get backupCreate => 'காப்புப்பிரதியை உருவாக்கவும்';

  @override
  String get backupCreateDesc =>
      'உங்கள் அமைப்புகள் மற்றும் குறியாக்க விசைகளை காப்புப் பிரதி எடுக்கவும். மீண்டும் உள்நுழைந்த பிறகு, சேவையகத்திலிருந்து செய்திகள் மீட்டமைக்கப்படும்.';

  @override
  String get backupIncludeKeys => 'குறியாக்க விசைகளைச் சேர்க்கவும்';

  @override
  String get backupIncludeKeysDesc =>
      'மறைகுறியாக்கப்பட்ட செய்திகளைப் படிக்கத் தேவை';

  @override
  String get backupPasswordProtect => 'கடவுச்சொல் பாதுகாப்பு';

  @override
  String get backupEnterPassword => 'காப்பு கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get backupHistory => 'காப்பு வரலாறு';

  @override
  String get backupNoBackups => 'இதுவரை காப்புப்பிரதிகள் இல்லை';

  @override
  String get backupRestore2 => 'மீட்டமை';

  @override
  String get backupDelete => 'நீக்கு';

  @override
  String get backupDeleteConfirm =>
      'இந்தக் காப்புப் பிரதியை நிச்சயமாக நீக்க விரும்புகிறீர்களா? இதை செயல்தவிர்க்க முடியாது.';

  @override
  String get backupRestoreFromFile => 'கோப்பிலிருந்து மீட்டமைக்கவும்';

  @override
  String get backupRestoreFromFileDesc =>
      'மற்றொரு சாதனம் அல்லது முந்தைய காப்புப்பிரதியிலிருந்து .n42backup கோப்பை இறக்குமதி செய்யவும்.';

  @override
  String get backupChooseFile => 'காப்பு கோப்பைத் தேர்ந்தெடுக்கவும்';

  @override
  String get backupRestoring => 'மீட்டெடுக்கிறது...';

  @override
  String backupCreated(int rooms, int messages) {
    return 'காப்புப்பிரதி உருவாக்கப்பட்டது: $rooms அறைகள், $messages செய்திகள்';
  }

  @override
  String backupRestored(int settings, int rooms) {
    return '$rooms அறைகளிலிருந்து $settings அமைப்புகள் மீட்டமைக்கப்பட்டது';
  }

  @override
  String backupFailed(String error) {
    return 'காப்புப்பிரதி தோல்வியடைந்தது: $error';
  }

  @override
  String get backupPasswordRequired =>
      'இந்த காப்புப்பிரதி கடவுச்சொல் பாதுகாக்கப்பட்டதாகும்';

  @override
  String get blocGroupNotFound => 'குழு காணப்படவில்லை';

  @override
  String blocGroupMembersInvited(int count) {
    return 'அழைக்கப்பட்ட $count உறுப்பினர்(கள்)';
  }

  @override
  String get blocGroupMemberRemoved => 'உறுப்பினர் நீக்கப்பட்டார்';

  @override
  String get blocGroupAdminRemoved => 'நிர்வாகி நீக்கப்பட்டார்';

  @override
  String get blocGroupLeft => 'குழுவை விட்டு வெளியேறினார்';

  @override
  String get blocGroupDisbanded => 'குழு கலைக்கப்பட்டது';

  @override
  String get blocGroupJoined => 'குழுவில் சேர்ந்தார்';

  @override
  String get blocGroupInviteDeclined => 'அழைப்பு நிராகரிக்கப்பட்டது';

  @override
  String get blocGroupTokenGateUpdated => 'டோக்கன் கேட் புதுப்பிக்கப்பட்டது';

  @override
  String get blocTransferProcessing => 'பரிமாற்றத்தைச் செயலாக்குகிறது...';

  @override
  String get blocTransferCancelled => 'இடமாற்றம் ரத்து செய்யப்பட்டது';

  @override
  String get blocTransferFailed => 'பரிமாற்றம் தோல்வியடைந்தது';

  @override
  String get blocPaymentProcessing => 'கட்டணத்தைச் செயலாக்குகிறது...';

  @override
  String get blocPaymentFailed => 'பணம் செலுத்த முடியவில்லை';

  @override
  String get groupMaxMembers => 'உறுப்பினர் வரம்பு';

  @override
  String get groupMaxMembersUnlimited => 'வரம்பற்ற';

  @override
  String get groupMaxMembersHint =>
      'வரம்பை உள்ளிடவும் (வரம்பற்றதாக காலியாக விடவும்)';

  @override
  String get groupMaxMembersUpdated => 'உறுப்பினர் வரம்பு புதுப்பிக்கப்பட்டது';

  @override
  String get groupFull => 'குழு திறன் உள்ளது';

  @override
  String get groupChannels => 'தலைப்பு சேனல்கள்';

  @override
  String get groupChannelsEmpty => 'இதுவரை சேனல்கள் இல்லை';

  @override
  String get groupChannelsCount => 'சேனல்கள்';

  @override
  String get groupChannelCreate => 'புதிய சேனல்';

  @override
  String get groupChannelName => 'சேனல் பெயர்';

  @override
  String get groupChannelTopic => 'சேனல் தலைப்பு (விரும்பினால்)';

  @override
  String get groupChannelDelete => 'சேனலை நீக்கு';

  @override
  String get groupChannelDeleteConfirm =>
      'இந்த சேனலை நீக்கவா? அனைத்து செய்திகளும் இழக்கப்படும்.';

  @override
  String get groupBotSettings => 'பாட் அமைப்புகள்';

  @override
  String get groupBotEnabled => 'Bot ஐ இயக்கு';

  @override
  String get groupBotWelcomeMessage => 'வரவேற்பு செய்தி டெம்ப்ளேட்';

  @override
  String get groupBotWelcomeHint =>
      'புதிய உறுப்பினர் பெயருக்கு \'பெயரை\' ஒதுக்கிடமாகப் பயன்படுத்தவும்';

  @override
  String get groupBotConfigUpdated => 'பாட் அமைப்புகள் புதுப்பிக்கப்பட்டன';

  @override
  String get groupContentFilter => 'உள்ளடக்க வடிகட்டி';

  @override
  String get groupContentFilterEnabled => 'முக்கிய வடிப்பானைச் செயல்படுத்தவும்';

  @override
  String get groupContentFilterReplace => '*** உடன் மாற்றவும்';

  @override
  String get groupContentFilterHide => 'செய்தியை மறை';

  @override
  String get groupContentFilterAddWord => 'முக்கிய சொல்லைச் சேர்க்கவும்';

  @override
  String get groupContentFilterUpdated =>
      'உள்ளடக்க வடிப்பான் புதுப்பிக்கப்பட்டது';

  @override
  String get chatSlashCommands => 'கட்டளைகள்';

  @override
  String get chatCommandPoll => '/வாக்கெடுப்பு - வாக்கெடுப்பை உருவாக்கவும்';

  @override
  String get chatCommandAnnounce => '/அறிவிக்கவும் - அறிவிப்பை அனுப்பவும்';

  @override
  String get chatCommandWelcome =>
      '/ வரவேற்கிறோம் - வரவேற்பு செய்தியை அமைக்கவும்';

  @override
  String get chatReportMessage => 'அறிக்கை';

  @override
  String get chatReportReason => 'காரணம் தெரிவிக்கவும்';

  @override
  String get chatReportSpam => 'ஸ்பேம்';

  @override
  String get chatReportHarassment => 'துன்புறுத்தல்';

  @override
  String get chatReportInappropriate => 'பொருத்தமற்ற உள்ளடக்கம்';

  @override
  String get chatReportOther => 'மற்றவை';

  @override
  String get chatReportSuccess => 'அறிக்கை சமர்ப்பிக்கப்பட்டது';

  @override
  String get spacesName => 'சமூகத்தின் பெயர்';

  @override
  String get spacesNameHint => 'எ.கா. கிரிப்டோ வர்த்தகர்கள்';

  @override
  String get spacesNameRequired => 'பெயர் தேவை';

  @override
  String get spacesDescription => 'விளக்கம்';

  @override
  String get spacesDescriptionHint => 'இந்த சமூகம் எதைப் பற்றியது?';

  @override
  String get spacesType => 'சமூக வகை';

  @override
  String get spacesPublicDesc => 'யார் வேண்டுமானாலும் கண்டுபிடித்து சேரலாம்';

  @override
  String get spacesPrivateDesc =>
      'அழைக்கப்பட்ட உறுப்பினர்கள் மட்டுமே சேர முடியும்';

  @override
  String get spacesNotFound => 'சமூகம் கிடைக்கவில்லை';

  @override
  String get spacesSearch => 'சமூகங்களைத் தேடு...';

  @override
  String get spacesMembers => 'உறுப்பினர்கள்';

  @override
  String get spacesNoChannels => 'இதுவரை சேனல்கள் இல்லை';

  @override
  String get spacesLeave => 'சமூகத்தை விட்டு வெளியேறு';

  @override
  String spacesLeaveConfirm(String name) {
    return 'நிச்சயமாக \"$name\" ஐ விட்டு வெளியேற விரும்புகிறீர்களா?';
  }

  @override
  String get spacesDelete => 'சமூகத்தை நீக்கு';

  @override
  String spacesDeleteConfirm(String name) {
    return 'இது \"$name\" மற்றும் அதன் அனைத்து சேனல்களையும் நிரந்தரமாக நீக்கும். இந்தச் செயலைச் செயல்தவிர்க்க முடியாது.';
  }

  @override
  String get spacesCreateChannel => 'சேனலைச் சேர்க்கவும்';

  @override
  String get spacesChannelName => 'சேனல் பெயர்';

  @override
  String get spacesChannelTopic => 'தலைப்பு (விரும்பினால்)';

  @override
  String get spacesDeleteChannel => 'சேனலை நீக்கு';

  @override
  String spacesDeleteChannelConfirm(String name) {
    return '\"#$name\" ஐ நிச்சயமாக நீக்க விரும்புகிறீர்களா?';
  }

  @override
  String get spacesEditName => 'பெயரைத் திருத்தவும்';

  @override
  String get spacesEditDescription => 'விளக்கத்தைத் திருத்து';

  @override
  String spacesViewAllMembers(int count) {
    return 'அனைத்து $count உறுப்பினர்களையும் காண்க';
  }

  @override
  String spacesKickMemberTitle(String name) {
    return '$name உதை';
  }

  @override
  String spacesBanMemberTitle(String name) {
    return 'தடை $name';
  }

  @override
  String get spacesPromoteAdmin => 'நிர்வாகியாக பதவி உயர்வு';

  @override
  String get spacesDemoteAdmin => 'நிர்வாகியை அகற்று';

  @override
  String get spacesInviteMember => 'உறுப்பினரை அழைக்கவும்';

  @override
  String get spacesInviteMemberUserId => 'பயனர் ஐடி (எ.கா. @user:server.com)';

  @override
  String get spacesSave => 'சேமிக்கவும்';

  @override
  String get settingsScreenshotProtection => 'ஸ்கிரீன்ஷாட் பாதுகாப்பு';

  @override
  String get settingsScreenshotProtectionDesc =>
      'ஸ்கிரீன் ஷாட்கள் மற்றும் ஸ்கிரீன் ரெக்கார்டிங்கைத் தடுக்கவும்';

  @override
  String get chatSelfDestructTimer => 'சுய அழிவு';

  @override
  String get chatTimerPickerTitle => 'சுய அழிவு டைமர்';

  @override
  String get chatTimerOff => 'ஆஃப்';

  @override
  String get onChainNotificationsTitle => 'தொடர் நிகழ்வுகள்';

  @override
  String get onChainMarkAllRead => 'அனைத்தையும் படித்ததாகக் குறிக்கவும்';

  @override
  String get onChainNoNotifications => 'இதுவரை தொடர் நிகழ்வுகள் எதுவும் இல்லை';

  @override
  String get onChainNoNotificationsDesc =>
      'குழுசேர்ந்த சேனல்களின் நிகழ்வுகள் இங்கே தோன்றும்';

  @override
  String get onChainViewDetails => 'விவரங்களைக் காண்க';

  @override
  String get chatCommandHelp => '/help — எல்லா கட்டளைகளையும் காட்டு';

  @override
  String get chatCommandPrice => '/ விலை - டோக்கன் விலை கிடைக்கும்';

  @override
  String get chatCommandBalance => '/ இருப்பு - பணப்பை இருப்பைக் காட்டு';

  @override
  String get chatCommandChains =>
      '/ சங்கிலிகள் - 236+ ஆதரிக்கப்படும் சங்கிலிகளின் பட்டியல்';

  @override
  String get chatMiniApps => 'பயன்பாடுகள்';

  @override
  String get miniAppMarketTitle => 'மினி ஆப்ஸ்';

  @override
  String get miniAppCategoryAll => 'அனைத்து';

  @override
  String get miniAppSearch => 'பயன்பாடுகளைத் தேடு...';

  @override
  String get miniAppFeatured => 'இடம்பெற்றது';

  @override
  String get miniAppAllApps => 'அனைத்து பயன்பாடுகள்';

  @override
  String get miniAppNoResults => 'பயன்பாடுகள் எதுவும் இல்லை';

  @override
  String get slideToPayLabel => '→→→ உறுதிப்படுத்த ஸ்லைடு';

  @override
  String get slideToPayConfirming => 'உறுதிப்படுத்துகிறது...';

  @override
  String get redPacketBestLuck => 'சிறந்த அதிர்ஷ்டம்';

  @override
  String get redPacketBestLuckCongrats =>
      'நல்ல அதிர்ஷ்டம்! நீங்கள் அதிகம் பெற்றீர்கள்!';

  @override
  String redPacketStats(int claimed, int total) {
    return '$claimed / $total உரிமை கோரப்பட்டது';
  }

  @override
  String get redPacketStatsTotal => 'மொத்தம்';

  @override
  String redPacketGrabbedViral(String amount, String token) {
    return '🧧 ஒரு சிவப்பு பாக்கெட்டைப் பிடித்தார் • $amount $token';
  }

  @override
  String get web3SearchHint => '@matrix:id • 0x வாலட் முகவரி • name.eth';

  @override
  String get web3SearchPlaceholder => 'ஐடி, பணப்பை அல்லது ENS மூலம் தேடவும்...';

  @override
  String get web3WalletAddress => 'பணப்பையின் முகவரி';

  @override
  String get web3AddressCopied => 'முகவரி நகலெடுக்கப்பட்டது';

  @override
  String get web3Copy => 'நகலெடுக்கவும்';

  @override
  String get web3SendMessage => 'செய்தி அனுப்பு';

  @override
  String get web3SendToWallet => 'செய்தி பணப்பை';

  @override
  String get web3WalletOnlyHint =>
      'இந்த முகவரிக்கு இதுவரை N42 கணக்கு இல்லை. அவர்கள் இணைந்ததும் செய்தி வழங்கப்படும்.';

  @override
  String get web3NftAvatar => 'NFT அவதார்';

  @override
  String get web3ResolveFailed => 'அடையாளத்தைத் தீர்க்க முடியவில்லை';

  @override
  String web3EnsNotFound(String name) {
    return 'ENS பெயர் \"$name\" இல்லை';
  }

  @override
  String get web3NoN42AccountTitle => 'N42 கணக்கு இல்லை';

  @override
  String get web3NoN42AccountDesc =>
      'இந்த வாலட் முகவரிக்கு இதுவரை N42 கணக்கு இல்லை. தொடங்குவதற்கு உங்கள் N42 அழைப்பிதழ் இணைப்பை அவர்களுடன் பகிர்ந்து கொள்ளலாம்.';

  @override
  String get web3ShareInvite => 'அழைப்பைப் பகிரவும்';

  @override
  String get nftPickerTitle => 'NFT அவதாரத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get nftPickerTabPopular => 'பிரபலமானது';

  @override
  String get nftPickerTabCustom => 'தனிப்பயன்';

  @override
  String get nftPickerChain => 'சங்கிலி';

  @override
  String get nftPickerContract => 'ஒப்பந்த முகவரி';

  @override
  String get nftPickerTokenId => 'டோக்கன் ஐடி';

  @override
  String get nftPickerVerifyOwnership =>
      'உரிமை மற்றும் முன்னோட்டத்தை சரிபார்க்கவும்';

  @override
  String get nftPickerUseAsAvatar => 'அவதாரமாக பயன்படுத்தவும்';

  @override
  String get nftPickerPreview => 'முன்னோட்டம்';

  @override
  String get nftPickerNotOwned => 'இந்த NFT உங்களுக்குச் சொந்தமில்லை';

  @override
  String get nftPickerInvalidTokenId => 'தவறான டோக்கன் ஐடி';

  @override
  String get nftPickerEnterBoth =>
      'ஒப்பந்த முகவரி மற்றும் டோக்கன் ஐடியை உள்ளிடவும்';

  @override
  String get nftPickerInfoTitle => 'NFT அவதார் — சரிபார்க்கப்பட்ட ஆன்-செயின்';

  @override
  String get nftPickerInfoDesc =>
      'உங்களுக்குச் சொந்தமான NFTயை உங்கள் அவதாரமாக இணைக்கவும். சங்கிலியின் உரிமையை யார் வேண்டுமானாலும் சரிபார்க்கலாம். N42 முழுவதும் தங்க மோதிரத்துடன் காட்டப்பட்டது.';

  @override
  String get nftPickerPopularCollections => 'பிரபலமான தொகுப்புகள்';

  @override
  String get nftPickerWalletHint =>
      '236+ சங்கிலிகளில் உங்கள் NFTகளை தானாக கண்டறிய உங்கள் N42 வாலட்டை இணைக்கவும்.';

  @override
  String get profileBindNftAvatar => 'NFT அவதாரத்தை பிணைக்கவும்';

  @override
  String get profileChangeAvatar => 'அவதாரத்தை மாற்றவும்';

  @override
  String get groupTopics => 'தலைப்புகள்';

  @override
  String get groupTopicsEmpty => 'இதுவரை தலைப்புகள் இல்லை';

  @override
  String get syncInProgress => 'செய்தி வரலாற்றை ஒத்திசைக்கிறது...';

  @override
  String get recoveryKeyReminderTitle => 'உங்கள் செய்திகளைப் பாதுகாக்கவும்';

  @override
  String get recoveryKeyReminderDesc =>
      'சாதனங்கள் முழுவதும் மறைகுறியாக்கப்பட்ட செய்திகளைப் பாதுகாப்பாக ஒத்திசைக்க மீட்பு விசையை உருவாக்கவும்';

  @override
  String get recoveryKeySetupNow => 'இப்போது அமைக்கவும்';

  @override
  String get recoveryKeyRemindLater => 'பிறகு நினைவூட்டு';

  @override
  String get channelReadOnly =>
      'இந்த சேனலில் நிர்வாகிகள் மட்டுமே இடுகையிட முடியும்';

  @override
  String get channelSubscribers => 'சந்தாதாரர்கள்';

  @override
  String get channelVerified => 'சரிபார்க்கப்பட்ட சேனல்';

  @override
  String get redPacketHistory => 'சிவப்பு பாக்கெட் வரலாறு';

  @override
  String get redPacketSent => 'அனுப்பப்பட்டது';

  @override
  String get redPacketReceived => 'பெற்றது';

  @override
  String get redPacketExpired => 'காலாவதியானது';

  @override
  String get redPacketClaimed => 'உரிமை கோரப்பட்டது';

  @override
  String get redPacketInsufficientBalance => 'போதுமான இருப்பு இல்லை';

  @override
  String selfDestructCountdown(String time) {
    return '$time இல் சுய அழிவு';
  }

  @override
  String get messageDestroyed => 'செய்தி அழிக்கப்பட்டது';

  @override
  String miniAppPermissionDenied(String permission) {
    return 'அனுமதி மறுக்கப்பட்டது: $permission';
  }

  @override
  String get aiSuggestionGasFee => 'எரிவாயு கட்டணம் என்றால் என்ன?';

  @override
  String get aiSuggestionDefi => 'DeFi தொடக்க வழிகாட்டி';

  @override
  String get aiSuggestionSecurity =>
      'ஒப்பந்தத்தின் பாதுகாப்பை எவ்வாறு சரிபார்க்கலாம்';

  @override
  String get aiSuggestionBridge => 'குறுக்கு சங்கிலி பாலம்';

  @override
  String get channelDiscoverTitle => 'சேனல்களைக் கண்டறியவும்';

  @override
  String get channelDiscoverSearch => 'சேனல்களைத் தேடு...';

  @override
  String get channelJoin => 'சேருங்கள்';

  @override
  String get channelJoined => 'சேர்ந்தார்';

  @override
  String get channelCategory => 'வகை';

  @override
  String slowModeCooldown(int seconds) {
    return 'மெதுவான பயன்முறை: $secondsகள் காத்திருக்கவும்';
  }

  @override
  String get addressCopyAction => 'முகவரியை நகலெடுக்கவும்';

  @override
  String get addressSendMessage => 'செய்தி அனுப்பு';

  @override
  String get addressViewProfile => 'சுயவிவரத்தைக் காண்க';

  @override
  String get sendToAddress => 'பணப்பை முகவரிக்கு அனுப்பவும்';

  @override
  String get blocAuthSendVerificationCodeFailed =>
      'சரிபார்ப்புக் குறியீட்டை அனுப்ப முடியவில்லை';

  @override
  String get blocAuthServerNoEmailPasswordReset =>
      'இந்த சேவையகம் மின்னஞ்சல் கடவுச்சொல் மீட்டமைப்பை ஆதரிக்காது';

  @override
  String get blocAuthResetPasswordFailed =>
      'கடவுச்சொல்லை மீட்டமைக்க முடியவில்லை';

  @override
  String get blocAuthChangePasswordFailed => 'கடவுச்சொல்லை மாற்ற முடியவில்லை';

  @override
  String get blocAuthOldPasswordWrong => 'தவறான தற்போதைய கடவுச்சொல்';

  @override
  String get blocAuthLoginCancelled => 'உள்நுழைவு ரத்து செய்யப்பட்டது';

  @override
  String get blocAuthGoogleLoginFailed => 'Google உள்நுழைவு தோல்வியடைந்தது';

  @override
  String get blocAuthAppleLoginFailed => 'ஆப்பிள் உள்நுழைவு தோல்வியடைந்தது';

  @override
  String get blocAuthSsoLoginFailed => 'SSO உள்நுழைவு தோல்வியடைந்தது';

  @override
  String get blocAuthFacebookLoginFailed => 'பேஸ்புக் உள்நுழைவு தோல்வியடைந்தது';

  @override
  String get blocAuthTwitterLoginFailed => 'ட்விட்டர் உள்நுழைவு தோல்வியடைந்தது';

  @override
  String get blocAuthWeChatLoginFailed => 'WeChat உள்நுழைவு தோல்வியடைந்தது';

  @override
  String get blocAuthWeChatNotConfigured =>
      'WeChat உள்நுழைவு கட்டமைக்கப்படவில்லை';

  @override
  String get blocAuthWeChatNotInstalled => 'முதலில் WeChat ஐ நிறுவவும்';

  @override
  String get blocAuthPasswordWrong => 'தவறான கடவுச்சொல்';

  @override
  String get blocAuthEmailAlreadyBound =>
      'இந்த மின்னஞ்சல் ஏற்கனவே மற்றொரு கணக்குடன் இணைக்கப்பட்டுள்ளது';

  @override
  String get blocAuthChangeEmailFailed => 'மின்னஞ்சலை மாற்ற முடியவில்லை';

  @override
  String get blocAuthVerificationCodeInvalid =>
      'சரிபார்ப்புக் குறியீடு தவறானது அல்லது காலாவதியானது';

  @override
  String get blocAuthSessionExpired =>
      'அமர்வு காலாவதியானது, மீண்டும் உள்நுழையவும்';

  @override
  String get blocAuthSessionIncomplete =>
      'அமர்வு தரவு முழுமையடையவில்லை, மீண்டும் உள்நுழையவும்';
}
