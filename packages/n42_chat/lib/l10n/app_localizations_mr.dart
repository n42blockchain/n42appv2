// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class SMr extends S {
  SMr([String locale = 'mr']) : super(locale);

  @override
  String get commonRetry => 'पुन्हा प्रयत्न करा';

  @override
  String get commonUnknownUser => 'अज्ञात वापरकर्ता';

  @override
  String get transferWalletNotConnected => 'वॉलेट कनेक्ट केलेले नाही';

  @override
  String get chatCallServiceNotInitialized => 'कॉल सेवा सुरू केली नाही';

  @override
  String authLoginFailed(String error) {
    return 'लॉगिन अयशस्वी: $error';
  }

  @override
  String get chatCallBack => 'परत कॉल करा';

  @override
  String get chatMissedVideoCall => 'मिस्ड व्हिडिओ कॉल';

  @override
  String get chatMissedVoiceCall => 'मिस्ड व्हॉईस कॉल';

  @override
  String get chatCallNotAnswered => 'उत्तर दिले नाही';

  @override
  String get chatCallDurationLabel => 'कॉल कालावधी';

  @override
  String get chatVoiceCallCancelled => 'व्हॉइस कॉल रद्द केला';

  @override
  String get chatVideoCallCancelled => 'व्हिडिओ कॉल रद्द केला';

  @override
  String get commonImage => '[प्रतिमा]';

  @override
  String get chatVideo => '[व्हिडिओ]';

  @override
  String get chatVoice => '[आवाज]';

  @override
  String get commonFile => '[फाइल]';

  @override
  String get chatLocation => '[स्थान]';

  @override
  String get chatUnknownMessage => '[अज्ञात संदेश]';

  @override
  String get commonDelete => 'हटवा';

  @override
  String get chatDeleteThisMessage => 'हा संदेश हटवायचा?';

  @override
  String get chatMessageDeleted => 'मेसेज हटवला';

  @override
  String get profileNotLoggedIn => 'लॉग इन नाही';

  @override
  String get chatMyLocation => 'माझे स्थान';

  @override
  String get commonGroupChat => 'गट गप्पा';

  @override
  String get commonSearch => 'शोधा';

  @override
  String get commonCancel => 'रद्द करा';

  @override
  String get commonLoadFailed => 'लोड करण्यात अयशस्वी';

  @override
  String get commonMessages => 'संदेश';

  @override
  String get commonContacts => 'संपर्क';

  @override
  String get commonMe => 'मी';

  @override
  String get commonVoiceLoading =>
      'व्हॉइस लोड होत आहे, कृपया नंतर पुन्हा प्रयत्न करा';

  @override
  String get commonVoiceToTextFailed => 'व्हॉइस टू टेक्स्ट अयशस्वी';

  @override
  String get commonConvertToText => 'मजकूर करण्यासाठी';

  @override
  String get chatCopy => 'कॉपी करा';

  @override
  String get commonForward => 'पुढे';

  @override
  String get commonUnfavorite => 'अनफॅव्ह';

  @override
  String get commonFavorite => 'आवडते';

  @override
  String get settingsResend => 'पुन्हा पाठवा';

  @override
  String get chatRecall => 'आठवते';

  @override
  String get commonQuote => 'कोट';

  @override
  String get commonRemind => 'आठवण करून द्या';

  @override
  String get chatCopied => 'कॉपी केले';

  @override
  String get storySendMessageHint => 'एक संदेश पाठवा';

  @override
  String get commonMicrophonePermissionRequired =>
      'कृपया मायक्रोफोनला परवानगी द्या';

  @override
  String get chatMicrophonePermissionDeniedPermanent =>
      'मायक्रोफोन परवानगी नाकारली गेली आहे. कृपया व्हॉइस संदेश वापरण्यासाठी सिस्टम सेटिंग्जमध्ये ते सक्षम करा.';

  @override
  String commonStartRecordingFailed(String error) {
    return 'रेकॉर्डिंग सुरू करण्यात अयशस्वी: $error';
  }

  @override
  String get commonRecordingTooShort => 'रेकॉर्डिंग खूप लहान आहे';

  @override
  String commonStopRecordingFailed(String error) {
    return 'रेकॉर्डिंग थांबवण्यात अयशस्वी: $error';
  }

  @override
  String get chatReleaseToCancel => 'रद्द करण्यासाठी सोडा';

  @override
  String get chatReleaseToSend =>
      'पाठवण्यासाठी सोडा, रद्द करण्यासाठी वर स्वाइप करा';

  @override
  String get commonHoldToTalk => 'बोलण्यासाठी धरा';

  @override
  String get commonSend => 'पाठवा';

  @override
  String get commonAddFriend => 'मित्र जोडा';

  @override
  String get commonChatServiceNotConnected => 'चॅट सेवा कनेक्ट केलेली नाही';

  @override
  String contactUserNotFoundHint(String query) {
    return 'वापरकर्ता \"$query\" आढळला नाही\n\nटिपा:\n• पूर्ण वापरकर्ता आयडी प्रविष्ट करण्याचा प्रयत्न करा, उदा. @username:server.com\n• वापरकर्ता नावाचे स्पेलिंग तपासा';
  }

  @override
  String contactCreateChatFailed(String error) {
    return 'चॅट तयार करण्यात अयशस्वी: $error';
  }

  @override
  String contactSearchFailed(String error) {
    return 'शोध अयशस्वी: $error';
  }

  @override
  String get contactEnterUserIdOrUsername =>
      'शोधण्यासाठी वापरकर्ता आयडी किंवा वापरकर्तानाव प्रविष्ट करा';

  @override
  String get contactSearching => 'शोधत आहे...';

  @override
  String get contactSearchUserToChat => 'चॅटिंग सुरू करण्यासाठी वापरकर्ता शोधा';

  @override
  String get contactMatrixIdExample =>
      'तुम्ही पूर्ण मॅट्रिक्स आयडी टाकू शकता\nउदा. @user:matrix.n42.network';

  @override
  String contactUserNotFound(String username) {
    return 'वापरकर्ता \"$username\" आढळला नाही';
  }

  @override
  String get commonChat => 'गप्पा';

  @override
  String get commonSettings => 'सेटिंग्ज';

  @override
  String get profileEditProfile => 'प्रोफाइल संपादित करा';

  @override
  String get authLogin => 'लॉग इन करा';

  @override
  String get commonCreateGroup => 'गट तयार करा';

  @override
  String get chatError => 'त्रुटी';

  @override
  String get commonTransfer => 'हस्तांतरण';

  @override
  String get commonReceived => 'प्राप्त झाले';

  @override
  String get commonRefunded => 'परतावा दिला';

  @override
  String get commonExpired => 'कालबाह्य';

  @override
  String get chatRedPacketGreeting => 'हार्दिक शुभेच्छा';

  @override
  String get commonN42RedPacket => 'N42 लाल पॅकेट';

  @override
  String get commonClaimed => 'दावा केला';

  @override
  String get commonAllClaimed => 'सर्वांनी दावा केला';

  @override
  String get chatReadAloud => 'मोठ्याने वाचा';

  @override
  String get chatReply => 'उत्तर द्या';

  @override
  String get commonEdit => 'संपादित करा';

  @override
  String get chatSelectForwardTarget => 'फॉरवर्ड टार्गेट निवडा';

  @override
  String commonSendCount(int count) {
    return 'पाठवा($count)';
  }

  @override
  String contactN42Id(String id) {
    return 'N42 आयडी: $id';
  }

  @override
  String get profileN42IdTitle => 'N42 आयडी';

  @override
  String get profileN42Bean => 'N42 बीन';

  @override
  String get contactFriendInfo => 'मित्र माहिती';

  @override
  String get contactFriendInfoDesc =>
      'मित्राची टिप्पणी, फोन, टॅग, नोट्स, फोटो आणि सेट परवानग्या जोडा.';

  @override
  String get commonMoments => 'क्षण';

  @override
  String get commonSendMessage => 'संदेश';

  @override
  String get contactAudioVideoCall => 'ऑडिओ/व्हिडिओ कॉल';

  @override
  String get contactVideoChannel => 'व्हिडिओ चॅनेल';

  @override
  String get contactRemark => 'शेरा';

  @override
  String get contactRemarkName => 'रिमार्क नाव';

  @override
  String get contactPhone => 'फोन';

  @override
  String get contactTags => 'टॅग्ज';

  @override
  String get contactNotes => 'नोट्स';

  @override
  String get contactPhotos => 'फोटो';

  @override
  String get contactPermissions => 'परवानग्या';

  @override
  String get contactChatMomentsEtc => 'गप्पा, क्षण, खेळ इ.';

  @override
  String get contactMoreInfo => 'अधिक माहिती';

  @override
  String get contactCommonGroups => 'सामाईक गट';

  @override
  String get contactSource => 'स्त्रोत';

  @override
  String get settingsNotificationSettings => 'सूचना';

  @override
  String get settingsPrivacy => 'गोपनीयता';

  @override
  String get settingsAppearance => 'देखावा';

  @override
  String get settingsAbout => 'बद्दल';

  @override
  String get commonLogout => 'लॉग आउट करा';

  @override
  String get commonLogoutConfirm =>
      'तुमची खात्री आहे की तुम्ही लॉग आउट करू इच्छिता?';

  @override
  String get commonSave => 'जतन करा';

  @override
  String get profileNickname => 'टोपणनाव';

  @override
  String get profileEnterNickname => 'टोपणनाव प्रविष्ट करा';

  @override
  String get profileSignature => 'स्वाक्षरी';

  @override
  String get profileAddSignature => 'स्वाक्षरी जोडा';

  @override
  String get commonTakePhoto => 'फोटो घ्या';

  @override
  String get profileChooseFromGallery => 'गॅलरीमधून निवडा';

  @override
  String profileSaveFailed(String error) {
    return 'जतन अयशस्वी: $error';
  }

  @override
  String get authSecureDecentralizedChat => 'सुरक्षित, विकेंद्रित संदेशन';

  @override
  String get commonEndToEndEncryption => 'एंड-टू-एंड एन्क्रिप्शन';

  @override
  String get authMessagesOnlyYouCanSee =>
      'संदेश केवळ तुम्हाला आणि प्राप्तकर्त्यासाठी दृश्यमान आहेत';

  @override
  String get authDecentralized => 'विकेंद्रित';

  @override
  String get authBasedOnMatrix => 'मॅट्रिक्स ओपन प्रोटोकॉलवर बिल्ट';

  @override
  String get authWalletIntegration => 'वॉलेट एकत्रीकरण';

  @override
  String get authEasyCryptoTransfer => 'सुलभ क्रिप्टोकरन्सी हस्तांतरण';

  @override
  String get authRegister => 'साइन अप करा';

  @override
  String get authAgreeTerms => 'लॉग इन करून, तुम्ही सहमत आहात';

  @override
  String get authTermsOfService => 'सेवा अटी';

  @override
  String get authAnd => ' आणि ';

  @override
  String get authPrivacyPolicy => 'गोपनीयता धोरण';

  @override
  String get authServerAddress => 'सर्व्हर पत्ता';

  @override
  String get authEnterServerAddress => 'सर्व्हर पत्ता प्रविष्ट करा';

  @override
  String authConnectedTo(String serverName) {
    return '$serverName शी कनेक्ट केले';
  }

  @override
  String get authUsername => 'वापरकर्तानाव';

  @override
  String get authEnterUsername => 'वापरकर्तानाव प्रविष्ट करा';

  @override
  String get authUsernameOrEmail => 'वापरकर्तानाव किंवा ईमेल';

  @override
  String get authEnterUsernameOrEmail => 'वापरकर्तानाव किंवा ईमेल प्रविष्ट करा';

  @override
  String get authPassword => 'पासवर्ड';

  @override
  String get authEnterPassword => 'पासवर्ड टाका';

  @override
  String get authRegisterAccount => 'साइन अप करा';

  @override
  String get authForgotPassword => 'पासवर्ड विसरलात';

  @override
  String get authOtherLoginMethods => 'इतर लॉगिन पद्धती';

  @override
  String get authCreateAccount => 'खाते तयार करा';

  @override
  String get authJoinN42Chat =>
      'चॅटिंग सुरू करण्यासाठी N42 चॅटमध्ये सामील व्हा';

  @override
  String get authUsernameHint => '3-20 वर्ण, अक्षरे/संख्या/_';

  @override
  String get authUsernameMinLength =>
      'वापरकर्तानाव किमान 3 वर्णांचे असणे आवश्यक आहे';

  @override
  String get authUsernameMaxLength =>
      'वापरकर्तानाव जास्तीत जास्त 20 वर्णांचे असणे आवश्यक आहे';

  @override
  String get authUsernameFormat =>
      'वापरकर्तानावामध्ये फक्त अक्षरे, संख्या आणि अंडरस्कोअर असू शकतात';

  @override
  String get authPasswordHint => 'किमान ८ वर्ण';

  @override
  String get commonPasswordMinLength =>
      'पासवर्ड किमान 8 वर्णांचा असणे आवश्यक आहे';

  @override
  String get authConfirmPassword => 'पासवर्डची पुष्टी करा';

  @override
  String get authFilled => 'भरले';

  @override
  String get authEnterInviteCode => 'आमंत्रण कोड प्रविष्ट करा';

  @override
  String get authAlreadyHaveAccount => 'आधीच खाते आहे?';

  @override
  String get authLoginNow => 'आता लॉग इन करा';

  @override
  String get profileAvatar => 'अवतार';

  @override
  String get profileStatus => 'स्थिती';

  @override
  String get commonLoading => 'लोड करत आहे...';

  @override
  String get conversationNoConversations => 'कोणतीही संभाषणे नाहीत';

  @override
  String get conversationTapToChat =>
      'चॅटिंग सुरू करण्यासाठी वरच्या उजवीकडे टॅप करा';

  @override
  String get conversationStartGroup => 'ग्रुप चॅट सुरू करा';

  @override
  String get commonScan => 'स्कॅन करा';

  @override
  String get commonPayment => 'पेमेंट';

  @override
  String commonFeatureComingSoon(String feature) {
    return '$feature लवकरच येत आहे';
  }

  @override
  String get conversationMarkAsRead => 'वाचलेले म्हणून चिन्हांकित करा';

  @override
  String get commonUnmute => 'अनम्यूट करा';

  @override
  String get commonMute => 'नि:शब्द करा';

  @override
  String get conversationUnpin => 'अनपिन करा';

  @override
  String get conversationPin => 'पिन';

  @override
  String get conversationDeleteConversation => 'संभाषण हटवा';

  @override
  String conversationDeleteConversationConfirm(String name) {
    return '\"$name\" सह संभाषण हटवायचे?';
  }

  @override
  String get commonNoContacts => 'कोणतेही संपर्क नाहीत';

  @override
  String get contactAddFriendsToChat => 'चॅटिंग सुरू करण्यासाठी मित्रांना जोडा';

  @override
  String get contactNotFound => 'संपर्क सापडला नाही';

  @override
  String get contactTryOtherKeywords =>
      'इतर कीवर्ड किंवा जागतिक शोध वापरून पहा';

  @override
  String get contactSearchResults => 'शोध परिणाम';

  @override
  String get contactNewFriends => 'नवीन मित्र';

  @override
  String get contactChatOnlyFriends => 'चॅट-फक्त मित्र';

  @override
  String get contactOfficialAccounts => 'अधिकृत खाती';

  @override
  String get contactServiceAccounts => 'सेवा खाती';

  @override
  String get contactEnterpriseContacts => 'एंटरप्राइझ संपर्क';

  @override
  String get contactRecommendToFriend => 'संपर्क सामायिक करा';

  @override
  String get commonSetRemark => 'टिप्पणी सेट करा';

  @override
  String get contactSendingCard => 'संपर्क कार्ड पाठवत आहे...';

  @override
  String get commonFileLabel => 'फाईल';

  @override
  String get commonLocationLabel => 'स्थान';

  @override
  String contactRecommendFailed(String error) {
    return 'शिफारस अयशस्वी: $error';
  }

  @override
  String get profileEnterRemark => 'टिप्पणी प्रविष्ट करा';

  @override
  String get contactOpeningChat => 'गप्पा उघडत आहे...';

  @override
  String contactOpenChatFailed(String error) {
    return 'चॅट उघडण्यात अयशस्वी: $error';
  }

  @override
  String get contactAddContact => 'संपर्क जोडा';

  @override
  String get contactEnterUserId => 'वापरकर्ता आयडी प्रविष्ट करा';

  @override
  String get contactNoFriendRequests => 'फ्रेंड रिक्वेस्ट नाहीत';

  @override
  String get commonAccept => 'स्वीकारा';

  @override
  String get commonReject => 'नकार द्या';

  @override
  String get commonNoGroups => 'गट नाहीत';

  @override
  String get contactSelectFriendToRecommend => 'शिफारस करण्यासाठी मित्र निवडा';

  @override
  String get commonSearchContacts => 'संपर्क शोधा';

  @override
  String get contactNoContactsFound => 'कोणतेही संपर्क आढळले नाहीत';

  @override
  String get favoriteYesterday => 'काल';

  @override
  String get chatJustNow => 'आत्ताच';

  @override
  String get profileOnline => 'ऑनलाइन';

  @override
  String get profileOffline => 'ऑफलाइन';

  @override
  String get searchContactsGroupsMessages => 'संपर्क, गट आणि संदेश शोधा';

  @override
  String get searchError => 'शोध त्रुटी';

  @override
  String get chatSearchHint => 'शोधा';

  @override
  String get searchHistory => 'शोध इतिहास';

  @override
  String get commonClear => 'साफ';

  @override
  String get commonAll => 'सर्व';

  @override
  String get searchGroups => 'गट';

  @override
  String get searchNoResults => 'कोणतेही परिणाम नाहीत';

  @override
  String commonGroupMembers(int count) {
    return 'सदस्य ($count)';
  }

  @override
  String get groupMembersTitle => 'गट सदस्य';

  @override
  String get groupViewAll => 'सर्व पहा';

  @override
  String get groupOwner => 'मालक';

  @override
  String get groupAdmin => 'ॲडमिन';

  @override
  String get groupInvite => 'आमंत्रित करा';

  @override
  String get commonGroupAnnouncement => 'गट घोषणा';

  @override
  String get commonNotSet => 'सेट नाही';

  @override
  String get groupDescription => 'गट वर्णन';

  @override
  String get groupPublicGroup => 'सार्वजनिक गट';

  @override
  String get commonClearChatHistory => 'चॅट इतिहास साफ करा';

  @override
  String get commonDissolveGroup => 'गट विसर्जित करा';

  @override
  String get commonLeaveGroup => 'गट सोडा';

  @override
  String get groupChangeGroupName => 'गटाचे नाव बदला';

  @override
  String get commonEnterGroupName => 'गटाचे नाव प्रविष्ट करा';

  @override
  String get commonConfirm => 'पुष्टी करा';

  @override
  String get groupEnterGroupDescription => 'गट वर्णन प्रविष्ट करा';

  @override
  String get groupPublish => 'प्रकाशित करा';

  @override
  String get chatClearHistoryConfirm =>
      'सर्व चॅट इतिहास साफ करायचा? हे पूर्ववत केले जाऊ शकत नाही.';

  @override
  String get chatClearAction => 'साफ';

  @override
  String get commonChatHistoryCleared => 'चॅट इतिहास साफ केला';

  @override
  String get commonDissolve => 'विरघळणे';

  @override
  String get groupQrCode => 'गट QR कोड';

  @override
  String get commonSearchChatHistory => 'चॅट इतिहास शोधा';

  @override
  String get groupIdCopied => 'ग्रुप आयडी कॉपी केला';

  @override
  String get transferEnterOrPasteAddress =>
      'वॉलेट पत्ता प्रविष्ट करा किंवा पेस्ट करा';

  @override
  String get transferSelectToken => 'टोकन निवडा';

  @override
  String get commonTransferAmount => 'हस्तांतरण रक्कम';

  @override
  String get transferAvailable => 'उपलब्ध';

  @override
  String get transferMemoOptional => 'मेमो (पर्यायी)';

  @override
  String get transferConfirmTransfer => 'हस्तांतरणाची पुष्टी करा';

  @override
  String get transferAddressVerified => 'पत्ता सत्यापित केला';

  @override
  String transferAvailableBalance(String balance, String symbol) {
    return 'उपलब्ध: $balance $symbol';
  }

  @override
  String get commonEnterAmount => 'रक्कम प्रविष्ट करा';

  @override
  String get commonRedPacketCountMin => 'किमान 1 लाल पॅकेट आवश्यक आहे';

  @override
  String get commonViewRedPacketDetails => 'लाल पॅकेट तपशील पहा';

  @override
  String get commonEnterTransferAmount => 'कृपया हस्तांतरण रक्कम प्रविष्ट करा';

  @override
  String get commonTransferTo => 'कडे हस्तांतरित करा';

  @override
  String commonFromSender(String name, Object senderName) {
    return '$name वरून';
  }

  @override
  String get commonConfirmReceive => 'पावतीची पुष्टी करा';

  @override
  String get groupProfile => 'गट माहिती';

  @override
  String get groupRemoveMember => 'गटातून काढून टाका';

  @override
  String get commonRemove => 'काढा';

  @override
  String get profileClearStatus => 'स्थिती साफ करा';

  @override
  String get profileClearStatusConfirm => 'सद्य स्थिती साफ करायची?';

  @override
  String get profileStatusCleared => 'स्थिती साफ केली';

  @override
  String get profileUserNotExist => 'वापरकर्ता अस्तित्वात नाही';

  @override
  String get profileUserIdCopied => 'वापरकर्ता आयडी कॉपी केला';

  @override
  String get commonReport => 'अहवाल द्या';

  @override
  String get profileQrCode => 'QR कोड';

  @override
  String get profileAvatarUpdated => 'अवतार अपडेट केला';

  @override
  String commonSelectImageFailed(String error) {
    return 'प्रतिमा निवडण्यात अयशस्वी: $error';
  }

  @override
  String get profileChangeName => 'नाव बदला';

  @override
  String get profileMale => 'पुरुष';

  @override
  String get profileFemale => 'स्त्री';

  @override
  String chatFeatureInDev(String feature) {
    return '$feature वैशिष्ट्य विकसित होत आहे...';
  }

  @override
  String profileSaveAddressFailed(String error) {
    return 'पत्ता जतन करण्यात अयशस्वी: $error';
  }

  @override
  String get profileAddNew => 'ॲड';

  @override
  String get profileAddAddress => 'पत्ता जोडा';

  @override
  String get profileAddressAdded => 'पत्ता जोडला';

  @override
  String get profileAddressUpdated => 'पत्ता अपडेट केला';

  @override
  String get profileDeleteAddress => 'पत्ता हटवा';

  @override
  String get profileAddressDeleted => 'पत्ता हटवला';

  @override
  String profileSaveInvoiceFailed(String error) {
    return 'बीजक सेव्ह करण्यात अयशस्वी: $error';
  }

  @override
  String get profileMyInvoices => 'माझे पावत्या';

  @override
  String get profileAddInvoice => 'बीजक जोडा';

  @override
  String get profileInvoiceAdded => 'बीजक जोडले';

  @override
  String get profileInvoiceUpdated => 'बीजक अपडेट केले';

  @override
  String get profileDeleteInvoice => 'बीजक हटवा';

  @override
  String get profileInvoiceDeleted => 'बीजक हटवले';

  @override
  String get profilePersonal => 'वैयक्तिक';

  @override
  String get groupSelectAtLeastOne => 'कृपया किमान एक सदस्य निवडा';

  @override
  String get chatFileNotExist => 'फाइल अस्तित्वात नाही';

  @override
  String chatSendFailed(String error) {
    return 'पाठवणे अयशस्वी: $error';
  }

  @override
  String get chatCannotOpenBrowser => 'ब्राउझर उघडू शकत नाही';

  @override
  String chatSelectFileFailed(String error) {
    return 'फाइल निवडण्यात अयशस्वी: $error';
  }

  @override
  String settingsSetupFailed(String error) {
    return 'सेटअप अयशस्वी: $error';
  }

  @override
  String get transferEnterValidAmount => 'कृपया वैध रक्कम प्रविष्ट करा';

  @override
  String get commonAddressCopied => 'पत्ता कॉपी केला';

  @override
  String favoriteOpenItem(String content) {
    return 'उघडा: $content';
  }

  @override
  String get favoriteDeleted => 'हटवले';

  @override
  String get profileWallet => 'पाकीट';

  @override
  String get chatRecording => 'रेकॉर्डिंग';

  @override
  String get chatInvalidVideoUrl => 'अवैध व्हिडिओ URL';

  @override
  String get chatDownloadFile => 'फाइल डाउनलोड करा';

  @override
  String get chatClearChatHistoryTitle => 'चॅट इतिहास साफ करा';

  @override
  String get chatVideoCall => 'व्हिडिओ कॉल';

  @override
  String get commonVoiceCall => 'व्हॉईस कॉल';

  @override
  String get callLeaveMeeting => 'मीटिंग सोडा';

  @override
  String get chatDetails => 'गप्पा तपशील';

  @override
  String get chatViewAllGroupMembers => 'सर्व सदस्य पहा';

  @override
  String get chatGroupName => 'गटाचे नाव';

  @override
  String get chatGroupNameUpdated => 'गटाचे नाव अपडेट केले';

  @override
  String get chatUpdateFailed => 'अपडेट अयशस्वी झाले';

  @override
  String get chatNoPermissionToModify =>
      'तुम्हाला सुधारणा करण्याची परवानगी नाही';

  @override
  String get chatGroupManagement => 'गट व्यवस्थापन';

  @override
  String get chatMyNicknameInGroup => 'गटातील माझे टोपणनाव';

  @override
  String get chatPinChat => 'चॅट पिन करा';

  @override
  String get chatStrongReminder => 'मजबूत स्मरणपत्र';

  @override
  String get chatSetChatBackground => 'चॅट पार्श्वभूमी सेट करा';

  @override
  String get chatUnknownFile => 'अज्ञात फाइल';

  @override
  String get chatDownload => 'डाउनलोड करा';

  @override
  String get chatInvalidLocation => 'अवैध स्थान';

  @override
  String get chatTapToCancel => 'रद्द करण्यासाठी टॅप करा';

  @override
  String chatCaptureFailed(Object error) {
    return 'कॅप्चर अयशस्वी: $error';
  }

  @override
  String get chatProcessingVideo => 'व्हिडिओवर प्रक्रिया करत आहे...';

  @override
  String get chatVideoFileNotExist => 'व्हिडिओ फाइल अस्तित्वात नाही';

  @override
  String get chatVideoDataEmpty => 'व्हिडिओ डेटा रिक्त आहे';

  @override
  String get chatVideoTooLarge =>
      'व्हिडिओचा आकार 100MB पेक्षा जास्त असू शकत नाही';

  @override
  String get chatSendingVideo => 'व्हिडिओ पाठवत आहे...';

  @override
  String chatSendVideoFailed(Object error) {
    return 'व्हिडिओ पाठवण्यात अयशस्वी: $error';
  }

  @override
  String get chatImageFileNotExist => 'प्रतिमा फाइल अस्तित्वात नाही';

  @override
  String get commonImageDataEmpty => 'प्रतिमा डेटा रिक्त आहे';

  @override
  String get chatSendingImage => 'इमेज पाठवत आहे...';

  @override
  String chatSendImageFailed(Object error) {
    return 'प्रतिमा पाठविण्यात अयशस्वी: $error';
  }

  @override
  String get chatSendLocation => 'स्थान पाठवा';

  @override
  String get chatSelectLocationAndSend => 'स्थान निवडा आणि पाठवा';

  @override
  String get chatShareRealTimeLocation => 'रिअल-टाइम स्थान शेअर करा';

  @override
  String get chatShareLocationForOneHour =>
      'मित्रासोबत 1 तासासाठी रिअल-टाइम स्थान शेअर करा';

  @override
  String get chatLocationSent => 'स्थान पाठवले';

  @override
  String get chatSelectMessages => 'संदेश निवडा';

  @override
  String chatSelectedCount(int count) {
    return '$count निवडले';
  }

  @override
  String get chatSelectAll => 'सर्व निवडा';

  @override
  String chatGroupChatCount(int count) {
    return 'गट चॅट($count)';
  }

  @override
  String get chatPrivateChat => 'खाजगी गप्पा';

  @override
  String get chatNoMessages => 'कोणतेही संदेश नाहीत';

  @override
  String get chatSendFirstMessage => 'चॅटिंग सुरू करण्यासाठी पहिला संदेश पाठवा';

  @override
  String get chatEncryptionNotice =>
      'ही चॅट एंड-टू-एंड एनक्रिप्टेड आहे. केवळ तुम्ही आणि प्राप्तकर्ता संदेश वाचू शकता.';

  @override
  String get chatMultiForward => 'पुढे';

  @override
  String get chatCollect => 'गोळा करा';

  @override
  String get chatNoMembers => 'सदस्य नाहीत';

  @override
  String get chatMemberNotFound => 'सदस्य सापडला नाही';

  @override
  String get chatVoiceFileNotExist => 'व्हॉइस फाइल अस्तित्वात नाही';

  @override
  String get chatVoiceFileEmpty => 'व्हॉइस फाइल रिकामी आहे';

  @override
  String get chatSendingVoice => 'आवाज पाठवत आहे...';

  @override
  String chatSendVoiceFailed(Object error) {
    return 'आवाज पाठवण्यात अयशस्वी: $error';
  }

  @override
  String get chatMessageForwarded => 'मेसेज फॉरवर्ड केला';

  @override
  String chatForwardFailed(Object error) {
    return 'फॉरवर्ड अयशस्वी: $error';
  }

  @override
  String get chatUnfavorited => 'आवडत नाही';

  @override
  String get chatFavorited => 'आवडले';

  @override
  String get chatReactionAdded => 'प्रतिक्रिया जोडली';

  @override
  String get chatReactionRemoved => 'प्रतिक्रिया काढली';

  @override
  String get chatFailedMessageDeleted => 'अयशस्वी संदेश हटवला';

  @override
  String get chatDeleteMessages => 'संदेश हटवा';

  @override
  String chatDeleteMessagesConfirm(Object count) {
    return 'तुम्हाला खात्री आहे की तुम्ही $count संदेश हटवू इच्छिता?';
  }

  @override
  String chatNoteOtherMessages(Object count) {
    return 'टीप: $count संदेश इतरांकडून आहेत आणि फक्त तुमच्यासाठी हटवले जातील.';
  }

  @override
  String chatMyMessagesWillBeRecalled(Object count) {
    return 'तुमच्याकडील $count संदेश प्रत्येकासाठी परत बोलावले जातील.';
  }

  @override
  String chatRecalledCount(Object count, Object localCount) {
    return 'आठवले $count संदेश, $localCount फक्त तुमच्यासाठी हटवले';
  }

  @override
  String chatRecalledMessages(Object count) {
    return '$count संदेश आठवले';
  }

  @override
  String chatDeletedLocally(Object count) {
    return '$count संदेश फक्त तुमच्यासाठी हटवले आहेत';
  }

  @override
  String chatForwardedCount(Object count) {
    return '$count संदेश फॉरवर्ड केले';
  }

  @override
  String chatForwardComplete(Object failed, Object success) {
    return 'फॉरवर्ड पूर्ण झाले: $success यशस्वी झाले, $failed अयशस्वी झाले';
  }

  @override
  String get chatRemindOnlyInGroup =>
      'रिमाइंड फीचर फक्त ग्रुप चॅटमध्ये उपलब्ध आहे';

  @override
  String get chatOnlyTextSearchable => 'फक्त मजकूर संदेश शोधले जाऊ शकतात';

  @override
  String chatSearchFor(Object text) {
    return '\"$text\" शोधा';
  }

  @override
  String get chatBaiduSearch => 'Baidu शोध';

  @override
  String get chatGoogleSearch => 'Google शोध';

  @override
  String get chatBingSearch => 'Bing शोध';

  @override
  String get chatCalling => 'कॉल करत आहे...';

  @override
  String get chatRinging => 'वाजत आहे...';

  @override
  String get chatInCall => 'कॉल मध्ये';

  @override
  String commonFeatureInDevelopment(String feature) {
    return '$feature वैशिष्ट्य विकसित होत आहे...';
  }

  @override
  String chatCollectMessages(Object count) {
    return 'गोळा केलेले $count संदेश';
  }

  @override
  String commonMemberCount(int count) {
    return '$count सदस्य';
  }

  @override
  String groupDone(int count) {
    return 'पूर्ण झाले($count)';
  }

  @override
  String get profileServices => 'सेवा';

  @override
  String get commonFavorites => 'आवडते';

  @override
  String get profileOrdersAndCards => 'ऑर्डर आणि कार्ड्स';

  @override
  String get profileStickers => 'स्टिकर्स';

  @override
  String profileStatusSetTo(String status) {
    return 'स्थिती यावर सेट केली आहे: $status';
  }

  @override
  String get profileAvatarUploadFailed => 'अवतार अपलोड अयशस्वी';

  @override
  String get profilePersonalProfile => 'वैयक्तिक प्रोफाइल';

  @override
  String get profileName => 'नाव';

  @override
  String get profileGender => 'लिंग';

  @override
  String get profileRegion => 'प्रदेश';

  @override
  String get commonMyQrCode => 'माझा QR कोड';

  @override
  String get profilePoke => 'पोक';

  @override
  String get profileRingtone => 'रिंगटोन';

  @override
  String get profileDefaultRingtone => 'डीफॉल्ट रिंगटोन';

  @override
  String get profileMyAddresses => 'माझे पत्ते';

  @override
  String profileGenderSetTo(String gender) {
    return 'लिंग यावर सेट केले: $gender';
  }

  @override
  String get profileSelectRegion => 'प्रदेश निवडा';

  @override
  String get profileSelectCity => 'शहर निवडा';

  @override
  String profileRegionSetTo(String region) {
    return 'प्रदेश यावर सेट केले: $region';
  }

  @override
  String get profileSetPoke => 'पोक सेट करा';

  @override
  String get profileFriendPokedMe => 'मित्राने मला धक्काबुक्की केली';

  @override
  String get profileExample => 'उदाहरण';

  @override
  String get profileOnTheShoulder => ' खांद्यावर';

  @override
  String get profilePokeCleared => 'पोक साफ केला';

  @override
  String profilePokeSetTo(String suffix) {
    return 'पोक यावर सेट करा: poked me$suffix';
  }

  @override
  String get profileEditSignature => 'स्वाक्षरी संपादित करा';

  @override
  String get profileIntroduceYourself => 'स्वतःची ओळख करून देणारे वाक्य';

  @override
  String get profileSignatureCleared => 'स्वाक्षरी साफ केली';

  @override
  String get profileSignatureUpdated => 'स्वाक्षरी अद्यतनित केली';

  @override
  String get profileScanToAddFriend =>
      'मला मित्र म्हणून जोडण्यासाठी वरील QR कोड स्कॅन करा';

  @override
  String profileRingtoneSetTo(String ringtone) {
    return 'रिंगटोन यावर सेट: $ringtone';
  }

  @override
  String commonConfirmDissolveGroup(String name) {
    return 'तुम्हाला खात्री आहे की तुम्ही \"$name\" विसर्जित करू इच्छिता? ही क्रिया पूर्ववत केली जाऊ शकत नाही.';
  }

  @override
  String get authEnterValidServerAddress =>
      'कृपया वैध सर्व्हर पत्ता प्रविष्ट करा';

  @override
  String get authEnterServerAddressFirst =>
      'कृपया प्रथम सर्व्हर पत्ता प्रविष्ट करा';

  @override
  String get authPasskeyRequiresServer =>
      'पासकी लॉगिनसाठी सर्व्हर समर्थन आवश्यक आहे';

  @override
  String get authLoginAgreement => 'लॉग इन करून, तुम्ही सहमत आहात ';

  @override
  String get authPleaseAgreeToTerms =>
      'कृपया सेवा अटी आणि गोपनीयता धोरण वाचा आणि त्यांना सहमती द्या';

  @override
  String get authRegisterFailed => 'नोंदणी अयशस्वी';

  @override
  String get commonReenterPassword => 'पासवर्ड पुन्हा एंटर करा';

  @override
  String get commonPasswordsDoNotMatch => 'पासवर्ड जुळत नाहीत';

  @override
  String get authInviteCodeBuiltIn => 'आमंत्रण कोड (अंगभूत)';

  @override
  String get authInviteCodeBuiltInNote =>
      'आमंत्रण कोड अंगभूत आहे, सहसा बदल करण्याची आवश्यकता नसते';

  @override
  String get authIHaveReadAndAgree => 'मी वाचले आहे आणि सहमत आहे ';

  @override
  String get mainStartGroupChat => 'ग्रुप चॅट सुरू करा';

  @override
  String get mainAddFriends => 'मित्र जोडा';

  @override
  String get mainPaymentAndCollection => 'पेमेंट';

  @override
  String contactCount(int count) {
    return '$count संपर्क';
  }

  @override
  String get contactAddToHomeScreen => 'होम स्क्रीनवर जोडा';

  @override
  String contactRecommendedCardTo(String contact, String recipient) {
    return '$contact चे कार्ड $recipient ला शिफारस केलेले';
  }

  @override
  String get contactEnterRemarkName => 'टिप्पणीचे नाव प्रविष्ट करा';

  @override
  String contactRemarkSetTo(String remark) {
    return 'टिप्पणी यावर सेट केली आहे: $remark';
  }

  @override
  String contactAcceptedFriendRequest(String name) {
    return '$name ची मित्र विनंती स्वीकारली';
  }

  @override
  String contactRejectedFriendRequest(String name) {
    return '$name ची मित्र विनंती नाकारली';
  }

  @override
  String get commonGroupInvites => 'गट आमंत्रणे';

  @override
  String commonMyGroups(int count) {
    return 'माझे गट ($count)';
  }

  @override
  String get commonInvitedToJoinGroup =>
      'गटात सामील होण्यासाठी आमंत्रित केले आहे';

  @override
  String commonConfirmLeaveGroup(String name) {
    return 'तुम्हाला खात्री आहे की तुम्ही \"$name\" सोडू इच्छिता?';
  }

  @override
  String get commonLeave => 'सोडा';

  @override
  String get commonRecallThisMessage => 'हा संदेश आठवला?';

  @override
  String get commonSavedToGallery => 'गॅलरीत जतन केले';

  @override
  String get commonFailedToSave => 'जतन करण्यात अयशस्वी';

  @override
  String get chatSaving => 'सेव्ह करत आहे...';

  @override
  String get commonShare => 'शेअर करा';

  @override
  String get chatSaveToGallery => 'गॅलरीमध्ये जतन करा';

  @override
  String chatDownloadFailed(String code) {
    return 'डाउनलोड अयशस्वी: $code';
  }

  @override
  String commonShareFailed(String error) {
    return 'शेअर अयशस्वी: $error';
  }

  @override
  String get chatFailedToLoadImage => 'प्रतिमा लोड करण्यात अयशस्वी';

  @override
  String get chatVideoRecordingFailed => 'व्हिडिओ रेकॉर्डिंग अयशस्वी';

  @override
  String get profileRedPacket => 'लाल पॅकेट';

  @override
  String get commonMusic => 'संगीत';

  @override
  String get commonCoupon => 'कूपन';

  @override
  String get commonGift => 'भेट';

  @override
  String get commonPoll => 'मतदान';

  @override
  String get favoriteText => 'मजकूर';

  @override
  String get favoriteLinkLabel => 'दुवा';

  @override
  String get favoriteNote => 'नोंद';

  @override
  String get favoriteMyNotes => 'माझ्या नोट्स';

  @override
  String get favoriteToday => 'आज';

  @override
  String favoriteDaysAgoText(int count) {
    return '$count दिवसांपूर्वी';
  }

  @override
  String favoriteDateFormat(int month, int day) {
    return '$month/$day';
  }

  @override
  String get favoriteNoFavorites => 'अद्याप कोणतेही आवडते नाहीत';

  @override
  String get favoriteLongPressToFavorite => 'पसंतीचा संदेश दीर्घकाळ दाबा';

  @override
  String get favoriteNewNote => 'नवीन नोट';

  @override
  String get favoriteLink => 'आवडती लिंक';

  @override
  String get favoriteEditTags => 'टॅग संपादित करा';

  @override
  String get favoriteDeleteFavorite => 'आवडते हटवा';

  @override
  String get favoriteDeleteFavoriteConfirm =>
      'तुमची खात्री आहे की तुम्ही हे आवडते हटवू इच्छिता?';

  @override
  String get favoriteNoSearchResultsFound => 'कोणतेही परिणाम आढळले नाहीत';

  @override
  String get commonSendRedPacket => 'लाल पॅकेट पाठवा';

  @override
  String get transferAmount => 'रक्कम';

  @override
  String get commonRedPacketCover => 'लाल पॅकेट कव्हर';

  @override
  String get commonRedPacketType => 'लाल पॅकेट प्रकार';

  @override
  String get commonNormalRedPacket => 'सामान्य';

  @override
  String get commonLuckyRedPacket => 'भाग्यवान';

  @override
  String get commonRedPacketCount => 'लाल पॅकेट संख्या';

  @override
  String get commonPieces => 'तुकडे';

  @override
  String get commonPutMoneyInRedPacket => 'लाल पॅकेटमध्ये पैसे ठेवा';

  @override
  String get commonRedPacketRefundNotice =>
      'दावा न केलेले लाल पॅकेट 24 तासांनंतर परत केले जातील';

  @override
  String get commonOpenRedPacket => 'उघडा';

  @override
  String get commonRedPacketAllClaimed => 'लाल पॅकेट सर्व दावा';

  @override
  String get commonRedPacketExpired => 'लाल पॅकेट कालबाह्य झाले';

  @override
  String get commonAddTransferNote => 'हस्तांतरण नोट जोडा';

  @override
  String get commonYuan => 'CNY';

  @override
  String get commonReplyWithEmoji => 'या इमोजीसह उत्तर द्या';

  @override
  String get contactEditRemark => 'टिप्पणी संपादित करा';

  @override
  String get contactSetPermissions => 'परवानग्या सेट करा';

  @override
  String get profileAddToBlacklist => 'ब्लॅकलिस्टमध्ये जोडा';

  @override
  String get contactDeleteContact => 'संपर्क हटवा';

  @override
  String contactDeleteContactConfirm(String name) {
    return 'तुम्हाला खात्री आहे की तुम्ही $name हटवू इच्छिता?';
  }

  @override
  String get transferTitle => 'हस्तांतरण';

  @override
  String get transferReceiverAddressLabel => 'प्राप्तकर्त्याचा पत्ता';

  @override
  String get transferSelectTokenLabel => 'टोकन निवडा';

  @override
  String get transferAmountLabel => 'हस्तांतरण रक्कम';

  @override
  String get transferMemoLabel => 'मेमो (पर्यायी)';

  @override
  String get transferAddMemoHint => 'एक मेमो जोडा';

  @override
  String get transferSendPaymentRequest => 'पेमेंट विनंती पाठवा';

  @override
  String get transferQrCodeGenerateFailed => 'QR कोड निर्मिती अयशस्वी';

  @override
  String get transferScanQrToPayMe => 'मला पैसे देण्यासाठी QR कोड स्कॅन करा';

  @override
  String get transferMyWalletAddress => 'माझा वॉलेट पत्ता';

  @override
  String get transferCreatePaymentRequest => 'पेमेंट विनंती तयार करा';

  @override
  String profileN42IdLabel(String id) {
    return 'N42 आयडी: $id';
  }

  @override
  String get commonRedPacketDefaultGreeting => 'हार्दिक शुभेच्छा';

  @override
  String commonSenderRedPacket(String name) {
    return '$name चे लाल पॅकेट';
  }

  @override
  String get transferEnterValidAddress => 'कृपया वैध पत्ता प्रविष्ट करा';

  @override
  String get transferPleaseSelectToken => 'कृपया टोकन निवडा';

  @override
  String get commonReceivedTransfer => 'हस्तांतरण प्राप्त झाले';

  @override
  String commonSenderSentRedPacket(String name) {
    return '$name ने लाल पॅकेट पाठवले';
  }

  @override
  String get commonSavedToBalance => 'शिल्लक मध्ये जतन, थेट हस्तांतरण करू शकता';

  @override
  String get commonRedPacketExpiredOrEmpty =>
      'लाल पॅकेट कालबाह्य झाले/सर्व दावा केला';

  @override
  String get transferScanFeatureComingSoon =>
      'स्कॅन वैशिष्ट्य लवकरच येत आहे...';

  @override
  String get contactSetAsStarred => 'तारांकित म्हणून सेट करा';

  @override
  String get contactAddToBlocklist => 'ब्लॉकलिस्टमध्ये जोडा';

  @override
  String get commonClaimedYour => ' आपला दावा केला ';

  @override
  String get commonClaimedText => ' दावा केला ';

  @override
  String commonUserTyping(String name) {
    return '$name टाइप करत आहे...';
  }

  @override
  String get commonTyping => 'टायपिंग...';

  @override
  String get commonWaitingToReceive => 'प्राप्त होण्याची प्रतीक्षा करत आहे';

  @override
  String get commonTapToClaim => 'दावा करण्यासाठी टॅप करा';

  @override
  String get commonHasBeenReceived => 'प्राप्त झाले आहे';

  @override
  String get commonGetLucky => 'भाग्यवान व्हा';

  @override
  String get qrcodeCameraStartFailed => 'कॅमेरा सुरू करता आला नाही';

  @override
  String get qrcodeUnknownError => 'अज्ञात त्रुटी';

  @override
  String get qrcodePlaceQrCodeInFrame =>
      'स्कॅन करण्यासाठी फ्रेममध्ये QR कोड ठेवा';

  @override
  String get qrcodeCloseManualInput => 'मॅन्युअल इनपुट बंद करा';

  @override
  String get qrcodeManualInputUserId => 'मॅन्युअल इनपुट वापरकर्ता आयडी';

  @override
  String get commonAdd => 'ॲड';

  @override
  String get profileSetStatus => 'स्थिती सेट करा';

  @override
  String get profileVisibleToFriends24h => 'मित्रांना 24 तासांसाठी दृश्यमान';

  @override
  String get profileWriteStatus => 'स्टेटस लिहा';

  @override
  String get profileEnterYourStatus => 'तुमची स्थिती प्रविष्ट करा...';

  @override
  String get profileOk => 'ठीक आहे';

  @override
  String get qrcodeCameraPermissionRequired =>
      'QR कोड स्कॅन करण्यासाठी कॅमेरा परवानगी आवश्यक आहे';

  @override
  String get qrcodeCameraPermissionDenied =>
      'कॅमेरा परवानगी कायमची नाकारली गेली. कृपया सिस्टम सेटिंग्जमध्ये ते सक्षम करा.';

  @override
  String qrcodePermissionCheckError(String error) {
    return 'परवानगी तपासताना त्रुटी: $error';
  }

  @override
  String get qrcodeInvalidQrCode => 'अवैध QR कोड';

  @override
  String qrcodeCannotAddFriend(String error) {
    return 'मित्र जोडू शकत नाही: $error';
  }

  @override
  String get qrcodeScanQrCode => 'QR कोड स्कॅन करा';

  @override
  String get qrcodeCheckingCameraPermission => 'कॅमेरा परवानगी तपासत आहे...';

  @override
  String get qrcodeNeedCameraPermission => 'कॅमेरा परवानगी आवश्यक';

  @override
  String get qrcodeRetryPermission => 'पुन्हा प्रयत्न करा';

  @override
  String get qrcodeOpenSettings => 'सेटिंग्ज उघडा';

  @override
  String get groupInviteMembers => 'सदस्यांना आमंत्रित करा';

  @override
  String groupInviteCount(int count) {
    return 'आमंत्रित करा($count)';
  }

  @override
  String get profileNoShippingAddress => 'शिपिंग पत्ता नाही';

  @override
  String get profileDefaultLabel => 'डीफॉल्ट';

  @override
  String get profileNoInvoice => 'बीजक नाही';

  @override
  String get profileCompany => 'कंपनी';

  @override
  String get profileTaxNumber => 'कर क्रमांक';

  @override
  String get profileConfirmDeleteAddress =>
      'तुमची खात्री आहे की तुम्ही हा पत्ता हटवू इच्छिता?';

  @override
  String get profileConfirmDeleteInvoice =>
      'तुम्हाला खात्री आहे की तुम्ही हे बीजक हटवू इच्छिता?';

  @override
  String get commonGroupOwner => 'मालक';

  @override
  String get commonGroupAdmin => 'ॲडमिन';

  @override
  String get groupSearchMembers => 'सदस्य शोधा';

  @override
  String groupTotalMembers(int count) {
    return '$count सदस्य';
  }

  @override
  String get chatRemoveFromGroup => 'गटातून काढून टाका';

  @override
  String groupConfirmRemoveMember(String name) {
    return 'तुम्हाला खात्री आहे की तुम्ही गटातून \"$name\" काढून टाकू इच्छिता?';
  }

  @override
  String get chatUnknownSong => 'अज्ञात गाणे';

  @override
  String get chatUnknownArtist => 'अज्ञात कलाकार';

  @override
  String get chatUnknownContact => 'अज्ञात संपर्क';

  @override
  String get chatPersonalCard => 'संपर्क कार्ड';

  @override
  String get chatSingleChoice => 'अविवाहित';

  @override
  String get chatMultiChoice => 'बहु';

  @override
  String get chatEnded => 'संपले';

  @override
  String get chatEndPollButton => 'मतदान समाप्त करा';

  @override
  String get chatPollHint =>
      'चॅटमध्ये मतदान प्रदर्शित केले जाईल. गट सदस्य मतदान करू शकतात.';

  @override
  String get chatSearchSongOrArtist => 'गाणे किंवा कलाकार शोधा';

  @override
  String get chatNoSongsFound => 'कोणतीही गाणी आढळली नाहीत';

  @override
  String get chatSongNameOptional => 'गाण्याचे नाव (पर्यायी)';

  @override
  String get chatEnterSongName => 'गाण्याचे नाव प्रविष्ट करा';

  @override
  String get chatArtistNameOptional => 'कलाकाराचे नाव (पर्यायी)';

  @override
  String get chatEnterArtistName => 'कलाकाराचे नाव एंटर करा';

  @override
  String get chatRealTimeLocationSharing =>
      'विकासामध्ये रिअल-टाइम स्थान शेअरिंग...';

  @override
  String get profileVoiceCallFeatureInDev =>
      'व्हॉईस कॉल वैशिष्ट्य विकसित होत आहे...';

  @override
  String get profileReportFeatureInDev =>
      'विकासातील वैशिष्ट्याचा अहवाल द्या...';

  @override
  String get profileShareFeatureInDev => 'विकासातील वैशिष्ट्य सामायिक करा...';

  @override
  String get profileQrCodeFeatureInDev =>
      'क्यूआर कोड वैशिष्ट्य विकसित होत आहे...';

  @override
  String get qrcodeScanQrToAddMe =>
      'मला मित्र म्हणून जोडण्यासाठी वरील QR कोड स्कॅन करा';

  @override
  String get qrcodeSaveToAlbum => 'अल्बममध्ये सेव्ह करा';

  @override
  String get qrcodeChangeStyle => 'शैली बदला';

  @override
  String get qrcodeCopyId => 'आयडी कॉपी करा';

  @override
  String get qrcodeIdCopied => 'आयडी कॉपी केला';

  @override
  String get qrcodeMoreStylesFeatureComingSoon => 'अधिक शैली लवकरच येत आहेत';

  @override
  String get profileBio => 'जैव';

  @override
  String get profileHomeServer => 'सर्व्हर';

  @override
  String get profileShareContactCard => 'संपर्क कार्ड सामायिक करा';

  @override
  String get profileRemoveFromBlacklist => 'ब्लॅकलिस्टमधून काढा';

  @override
  String get profileConfirmAddBlacklist =>
      'तुमची खात्री आहे की तुम्ही या वापरकर्त्याला काळ्या यादीत जोडू इच्छिता? तुम्हाला त्यांच्याकडून संदेश मिळणार नाहीत.';

  @override
  String get profileConfirmRemoveBlacklist =>
      'तुमची खात्री आहे की तुम्ही या वापरकर्त्याला काळ्या यादीतून काढून टाकू इच्छिता?';

  @override
  String get profileRemarkSaved => 'टिप्पणी जतन केली';

  @override
  String get profileRemarkCleared => 'टिप्पणी साफ केली';

  @override
  String get transferReceive => 'प्राप्त करा';

  @override
  String get transferPleaseConnectWallet =>
      'कृपया प्रथम तुमचे वॉलेट कनेक्ट करा';

  @override
  String get transferSendRequest => 'विनंती पाठवा';

  @override
  String get transferPleaseEnterValidAmount => 'कृपया वैध रक्कम प्रविष्ट करा';

  @override
  String get searchPlaceholder => 'संपर्क, गट, संदेश शोधा';

  @override
  String get searchEnterKeywordToSearch =>
      'शोध सुरू करण्यासाठी कीवर्ड प्रविष्ट करा';

  @override
  String get searchClearHistory => 'साफ';

  @override
  String searchNoResultsForQuery(String query) {
    return '\"$query\" साठी आम्हाला कोणतेही परिणाम आढळले नाहीत';
  }

  @override
  String get searchAllResults => 'सर्व';

  @override
  String get searchInChat => 'चॅटमध्ये शोधा';

  @override
  String get searchContactLabel => 'संपर्क करा';

  @override
  String get searchGroupLabel => 'गट';

  @override
  String get searchConversationLabel => 'संभाषण';

  @override
  String get searchMessageLabel => 'संदेश';

  @override
  String get settingsSecurityTitle => 'सुरक्षा';

  @override
  String get settingsKeyBackup => 'की बॅकअप';

  @override
  String get settingsBackupEncryptionKeys => 'बॅकअप एनक्रिप्शन की';

  @override
  String settingsKeysBackedUp(int count) {
    return '$count की बॅकअप घेतल्या';
  }

  @override
  String get settingsBackupNotSet => 'बॅकअप सेट नाही';

  @override
  String get settingsRestoreKeys => 'की पुनर्संचयित करा';

  @override
  String get settingsRestoreKeysFromBackup =>
      'बॅकअपमधून एन्क्रिप्शन की पुनर्संचयित करा';

  @override
  String get settingsExportKeys => 'एक्सपोर्ट की';

  @override
  String get settingsExportKeysToFile => 'फाइलमध्ये की निर्यात करा';

  @override
  String get settingsLoggedInDevices => 'डिव्हाइसेसमध्ये लॉग इन केले';

  @override
  String get settingsNoOtherDevices => 'इतर कोणतीही साधने नाहीत';

  @override
  String get settingsVerified => 'सत्यापित';

  @override
  String get settingsUnverified => 'असत्यापित';

  @override
  String get settingsAdvanced => 'प्रगत';

  @override
  String get settingsCrossSigning => 'क्रॉस-साइनिंग';

  @override
  String get settingsEnabled => 'सक्षम केले';

  @override
  String get settingsNotEnabled => 'सक्षम नाही';

  @override
  String get settingsResetEncryption => 'एन्क्रिप्शन रीसेट करा';

  @override
  String get settingsDeleteAllEncryptionKeys => 'सर्व एन्क्रिप्शन की हटवा';

  @override
  String get settingsEncryptionNotSupported => 'कूटबद्धीकरण समर्थित नाही';

  @override
  String get settingsNotInitialized => 'आरंभ केला नाही';

  @override
  String get settingsBackupKeyTitle => 'बॅकअप की';

  @override
  String get settingsBackupKeyMessage =>
      'नवीन की बॅकअप तयार करायचा? हे तुम्हाला नवीन डिव्हाइसवर एनक्रिप्टेड संदेश पुनर्संचयित करण्यात मदत करेल.';

  @override
  String get settingsBackup => 'बॅकअप';

  @override
  String get settingsRestoreKeyTitle => 'की पुनर्संचयित करा';

  @override
  String get settingsRestoreKeyMessage =>
      'एन्क्रिप्ट केलेले संदेश पुनर्संचयित करण्यासाठी तुमचा पुनर्प्राप्ती संकेतशब्द किंवा पुनर्प्राप्ती की प्रविष्ट करा.';

  @override
  String get settingsRestore => 'पुनर्संचयित करा';

  @override
  String get settingsExportKeyTitle => 'एक्सपोर्ट की';

  @override
  String get settingsExportKeyMessage =>
      'निर्यात केलेल्या की फाइलमध्ये तुमच्या सर्व एन्क्रिप्शन की असतात. कृपया सुरक्षित ठेवा.';

  @override
  String get settingsExport => 'निर्यात करा';

  @override
  String settingsDeviceIdLabel(String deviceId) {
    return 'डिव्हाइस आयडी: $deviceId';
  }

  @override
  String get settingsDeviceStatusVerified => 'स्थिती: सत्यापित';

  @override
  String get settingsDeviceStatusUnverified => 'स्थिती: असत्यापित';

  @override
  String settingsLastActiveLabel(String lastSeen) {
    return 'शेवटचे सक्रिय: $lastSeen';
  }

  @override
  String get settingsVerifyThisDevice => 'हे डिव्हाइस सत्यापित करा';

  @override
  String get settingsCrossSigningAlreadyEnabled =>
      'क्रॉस-साइनिंग आधीच सक्षम आहे';

  @override
  String get settingsCrossSigningSetupSuccess => 'क्रॉस-साइनिंग सेटअप यशस्वी';

  @override
  String get settingsResetEncryptionTitle => 'एन्क्रिप्शन रीसेट करा';

  @override
  String get settingsResetEncryptionWarning =>
      'चेतावणी: हे तुमच्या सर्व एन्क्रिप्शन की हटवेल. तुम्ही पूर्वीचे एनक्रिप्ट केलेले संदेश डिक्रिप्ट करू शकणार नाही. ही क्रिया पूर्ववत केली जाऊ शकत नाही.';

  @override
  String get settingsReset => 'रीसेट करा';

  @override
  String get settingsBackupSuccess => 'कीचा यशस्वीपणे बॅकअप घेतला';

  @override
  String get settingsBackupFailed => 'बॅकअप अयशस्वी';

  @override
  String get settingsRecoveryKey => 'पुनर्प्राप्ती की';

  @override
  String get settingsRecoveryKeySaveWarning =>
      'कृपया ही पुनर्प्राप्ती की सुरक्षित ठिकाणी जतन करा. तुमचे एनक्रिप्ट केलेले संदेश नवीन डिव्हाइसवर पुनर्संचयित करण्यासाठी तुम्हाला याची आवश्यकता असेल.';

  @override
  String get settingsRecoveryKeySaved => 'मी ते जतन केले आहे';

  @override
  String get settingsRestoreSuccess => 'की यशस्वीरित्या पुनर्संचयित केल्या';

  @override
  String get settingsRestoreFailed => 'पुनर्संचयित करता आले नाही';

  @override
  String get settingsPassword => 'पासवर्ड';

  @override
  String get settingsEnterRecoveryKey => 'पुनर्प्राप्ती की प्रविष्ट करा';

  @override
  String get settingsEnterPassword => 'पासवर्ड टाका';

  @override
  String get settingsExportSuccess =>
      'सर्व्हर बॅकअपवर की यशस्वीरित्या निर्यात केल्या';

  @override
  String get settingsExportNeedBackupFirst => 'कृपया प्रथम की बॅकअप तयार करा';

  @override
  String get settingsExportFailed => 'निर्यात अयशस्वी';

  @override
  String get settingsResetSuccess => 'एन्क्रिप्शन रीसेट यशस्वी';

  @override
  String get settingsResetFailed => 'रीसेट अयशस्वी';

  @override
  String get callLeaveMeetingConfirm =>
      'तुमची खात्री आहे की तुम्ही मीटिंग सोडू इच्छिता?';

  @override
  String chatPokedSomeone(String name, String suffix) {
    return 'poked $name$suffix';
  }

  @override
  String get chatNoContactsToAdd => 'जोडण्यासाठी कोणतेही संपर्क उपलब्ध नाहीत';

  @override
  String get chatAddMembers => 'सदस्य जोडा';

  @override
  String chatInvitedMembers(int count) {
    return '$count सदस्यांना आमंत्रित केले';
  }

  @override
  String chatInviteFailed(String error) {
    return 'आमंत्रण अयशस्वी: $error';
  }

  @override
  String get chatMemberRemoved => 'सदस्य काढून टाकले';

  @override
  String chatRemoveFailed(String error) {
    return 'काढणे अयशस्वी: $error';
  }

  @override
  String get chatRealTimeLocationShareMessage =>
      'शेअर केल्यानंतर, दुसरा पक्ष तुमचे रिअल-टाइम स्थान 1 तास पाहू शकतो.';

  @override
  String get chatStartSharing => 'शेअरिंग सुरू करा';

  @override
  String get chatLocationServiceNotEnabled => 'स्थान सेवा सक्षम नाही';

  @override
  String get chatEnableLocationService =>
      'हे वैशिष्ट्य वापरण्यासाठी कृपया स्थान सेवा सक्षम करा';

  @override
  String get chatGoToSettings => 'सेटिंग्ज वर जा';

  @override
  String get chatLocationPermissionRequired =>
      'या वैशिष्ट्यासाठी स्थान परवानगी आवश्यक आहे';

  @override
  String get chatLocationPermissionDeniedPermanent =>
      'स्थान परवानगी कायमची नाकारली गेली आहे. कृपया ते सेटिंग्जमध्ये सक्षम करा.';

  @override
  String get chatLocationPermissionDenied => 'स्थान परवानगी नाकारली';

  @override
  String get chatGettingLocation => 'स्थान मिळवत आहे...';

  @override
  String chatGetLocationFailed(String error) {
    return 'स्थान मिळवण्यात अयशस्वी: $error';
  }

  @override
  String get chatMapPreview => 'नकाशा पूर्वावलोकन';

  @override
  String get chatSearchLocation => 'स्थान शोधा';

  @override
  String chatRedPacketSent(String amount, String token) {
    return '$amount $token लाल पॅकेट पाठवले';
  }

  @override
  String get chatTransferDefault => 'हस्तांतरण';

  @override
  String chatTransferSent(String amount, String token) {
    return '$amount $token हस्तांतरण पाठवले';
  }

  @override
  String chatPickFileFailed(String error) {
    return 'फाइल निवडण्यात अयशस्वी: $error';
  }

  @override
  String get chatFileSizeLimit => 'फाइल आकार 50MB पेक्षा जास्त असू शकत नाही';

  @override
  String chatFileSending(String filename) {
    return 'फाइल पाठवत आहे: $filename';
  }

  @override
  String chatSendFileFailed(String error) {
    return 'फाइल पाठवण्यात अयशस्वी: $error';
  }

  @override
  String chatContactCardSent(String name) {
    return '$name चे संपर्क कार्ड पाठवले';
  }

  @override
  String get chatFavoritesFeature => 'आवडते';

  @override
  String get chatCouponsFeature => 'कूपन';

  @override
  String get chatGiftFeature => 'भेट';

  @override
  String chatSharedMusic(String name) {
    return 'शेअर केलेले $name';
  }

  @override
  String get chatEndPollTitle => 'मतदान समाप्त करा';

  @override
  String get chatEndPollConfirmMessage =>
      'तुमची खात्री आहे की तुम्ही हे मतदान समाप्त करू इच्छिता? मतदान संपल्यानंतर बंद होईल.';

  @override
  String get chatPollEndedMessage => 'मतदान संपले';

  @override
  String get chatConnectingCall => 'कनेक्ट करत आहे...';

  @override
  String get chatMuteCall => 'नि:शब्द करा';

  @override
  String get chatSpeakerOff => 'स्पीकर बंद';

  @override
  String get chatSpeakerOn => 'वक्ता';

  @override
  String get chatCameraOn => 'कॅमेरा चालू';

  @override
  String get chatCameraOff => 'कॅमेरा बंद';

  @override
  String get chatHangUp => 'हँग अप';

  @override
  String get chatSelectForwardTargetTitle => 'फॉरवर्ड टार्गेट निवडा';

  @override
  String get chatNoForwardableChat => 'फॉरवर्ड करण्यासाठी चॅट्स उपलब्ध नाहीत';

  @override
  String get chatNoMatchingChat => 'कोणत्याही जुळणाऱ्या गप्पा आढळल्या नाहीत';

  @override
  String get chatLocationTitle => 'स्थान';

  @override
  String get chatSendButton => 'पाठवा';

  @override
  String get chatRetryButton => 'पुन्हा प्रयत्न करा';

  @override
  String get chatSearchContactHint => 'संपर्क शोधा';

  @override
  String get chatShareMusic => 'संगीत सामायिक करा';

  @override
  String get chatRecentPlayed => 'अलीकडील';

  @override
  String get chatMyFavorites => 'आवडते';

  @override
  String get chatNetworkLink => 'दुवा';

  @override
  String get chatLocalFile => 'स्थानिक';

  @override
  String get chatPasteMusicLink => 'संगीत लिंक पेस्ट करा';

  @override
  String get chatShareMusicButton => 'संगीत सामायिक करा';

  @override
  String get chatSelectLocalAudio => 'स्थानिक ऑडिओ फाइल निवडा';

  @override
  String get chatSupportedAudioFormats =>
      'MP3, M4A, WAV, FLAC, इत्यादींना सपोर्ट करते.';

  @override
  String get chatSelectFileButton => 'फाइल निवडा';

  @override
  String get chatPleaseEnterMusicLink => 'कृपया संगीत लिंक प्रविष्ट करा';

  @override
  String get chatPleaseEnterValidLink => 'कृपया एक वैध URL प्रविष्ट करा';

  @override
  String get chatSharedSong => 'शेअर केलेले गाणे';

  @override
  String get chatSelectMember => 'सदस्य निवडा';

  @override
  String get chatSearchMemberHint => 'सदस्य शोधा';

  @override
  String get chatNoMatchingMembers => 'कोणतेही जुळणारे सदस्य आढळले नाहीत';

  @override
  String get commonUnknownMember => 'अज्ञात';

  @override
  String chatSelectedMessagesCount(int count) {
    return 'निवडलेले $count संदेश';
  }

  @override
  String get chatSearchContactsOrGroups => 'संपर्क किंवा गट शोधा';

  @override
  String get chatVideoTitle => 'व्हिडिओ';

  @override
  String get chatLoadingText => 'लोड करत आहे...';

  @override
  String get chatVideoLoadFailed => 'व्हिडिओ लोड अयशस्वी';

  @override
  String get chatPlayerInitFailed => 'प्लेअर आरंभ करणे अयशस्वी झाले';

  @override
  String get chatCreatePollTitle => 'मतदान तयार करा';

  @override
  String get chatSubmitPoll => 'सबमिट करा';

  @override
  String get chatPollQuestionLabel => 'मतदान प्रश्न';

  @override
  String get chatEnterPollQuestionHint => 'कृपया मतदान प्रश्न प्रविष्ट करा';

  @override
  String get chatPollOptionsLabel => 'मतदान पर्याय';

  @override
  String chatOptionHintWithIndex(int index) {
    return 'पर्याय $index';
  }

  @override
  String get chatAddOptionButton => 'पर्याय जोडा';

  @override
  String get chatPollSettingsLabel => 'मतदान सेटिंग्ज';

  @override
  String get chatSelectionType => 'निवड प्रकार';

  @override
  String get chatSingleChoiceLabel => 'अविवाहित';

  @override
  String get chatMultiChoiceLabel => 'बहु';

  @override
  String get chatAnonymousPollSwitch => 'निनावी मतदान';

  @override
  String get chatPleaseEnterQuestion => 'कृपया मतदान प्रश्न प्रविष्ट करा';

  @override
  String get chatAtLeastTwoOptions => 'किमान 2 पर्याय आवश्यक आहेत';

  @override
  String chatConfirmWithCount(int count) {
    return 'पुष्टी करा ($count)';
  }

  @override
  String get authEmailVerificationTitle => 'ईमेल सत्यापन';

  @override
  String get authEnterValidEmailAddress => 'कृपया वैध ईमेल पत्ता प्रविष्ट करा';

  @override
  String authVerificationCodeSentTo(String email) {
    return 'पडताळणी कोड $email वर पाठवला';
  }

  @override
  String authSendCodeFailed(String error) {
    return 'कोड पाठवण्यात अयशस्वी: $error';
  }

  @override
  String get authVerificationSuccess => 'पडताळणी यशस्वी';

  @override
  String get authVerificationFailed => 'पडताळणी अयशस्वी';

  @override
  String authVerificationCodeError(String error) {
    return 'सत्यापन कोड त्रुटी: $error';
  }

  @override
  String get commonEnterVerificationCode => 'सत्यापन कोड प्रविष्ट करा';

  @override
  String get authEnterYourEmail => 'ईमेल प्रविष्ट करा';

  @override
  String authWeSentCodeTo(String email) {
    return 'आम्ही एक 6-अंकी कोड पाठवला आहे\n$email';
  }

  @override
  String get authEnterEmailForCode =>
      'तुमचा ईमेल पत्ता प्रविष्ट करा, आम्ही सत्यापन कोड पाठवू';

  @override
  String get commonSendVerificationCode => 'सत्यापन कोड पाठवा';

  @override
  String get authResendVerificationCode => 'सत्यापन कोड पुन्हा पाठवा';

  @override
  String authCanResendAfter(int seconds) {
    return '$seconds सेकंदांनंतर पुन्हा पाठवू शकतो';
  }

  @override
  String get commonChangeEmail => 'ईमेल बदला';

  @override
  String get contactAddToContacts => 'संपर्कांमध्ये जोडा';

  @override
  String get contactAddingToContacts => 'जोडत आहे...';

  @override
  String get contactAddedToContacts => 'संपर्कांमध्ये जोडले';

  @override
  String contactAddFailedWithError(String error) {
    return 'जोडा अयशस्वी: $error';
  }

  @override
  String get contactAddPhone => 'फोन जोडा';

  @override
  String get contactAddTag => 'टॅग जोडा';

  @override
  String get contactAddText => 'मजकूर जोडा';

  @override
  String get contactAddPhoto => 'फोटो जोडा';

  @override
  String contactGroupCountLabel(int count) {
    return '$count गट';
  }

  @override
  String get contactAddedViaSearch => 'शोध द्वारे जोडले';

  @override
  String get contactAddTime => 'वेळ जोडा';

  @override
  String get contactDoneButton => 'झाले';

  @override
  String get callWaitingForParticipants =>
      'सहभागी सामील होण्याची प्रतीक्षा करत आहे...';

  @override
  String callParticipantMe(String name) {
    return '$name (मी)';
  }

  @override
  String get callSharingLabel => 'शेअरिंग';

  @override
  String callScreenSharingBy(String name) {
    return '$name स्क्रीन शेअर करत आहे';
  }

  @override
  String callParticipantCount(int count) {
    return '$count सहभागी';
  }

  @override
  String get callMuteLabel => 'नि:शब्द करा';

  @override
  String get callUnmuteLabel => 'अनम्यूट करा';

  @override
  String get callTurnOffVideo => 'व्हिडिओ बंद करा';

  @override
  String get callTurnOnVideo => 'व्हिडिओ चालू करा';

  @override
  String get callShareScreen => 'स्क्रीन शेअर करा';

  @override
  String get callStopSharing => 'शेअर करणे थांबवा';

  @override
  String get callSwitchCameraLabel => 'स्विच करा';

  @override
  String get callLeaveLabel => 'सोडा';

  @override
  String get callParticipantsLabel => 'सहभागी';

  @override
  String get callJoiningMeeting => 'मीटिंगमध्ये सामील होत आहे...';

  @override
  String chatPollVotesFormat(int count, String percentage) {
    return '$count मते ($percentage%)';
  }

  @override
  String chatPollParticipantsFormat(int count) {
    return '$count सहभागी';
  }

  @override
  String get commonTapToRetry => 'पुन्हा प्रयत्न करण्यासाठी टॅप करा';

  @override
  String get chatDefaultRedPacketGreeting => 'समृद्धीसाठी हार्दिक शुभेच्छा';

  @override
  String get groupAllowOthersToSearchAndJoin =>
      'इतरांना शोधण्याची आणि सामील होण्याची अनुमती द्या';

  @override
  String get groupConfirmClearChatHistory =>
      'तुम्हाला खात्री आहे की तुम्ही चॅट इतिहास साफ करू इच्छिता?';

  @override
  String get groupCreateGroupToChat => 'चॅटिंग सुरू करण्यासाठी एक गट तयार करा';

  @override
  String get groupEditGroupAnnouncement => 'गट घोषणा संपादित करा';

  @override
  String get groupEditGroupDescription => 'गट वर्णन संपादित करा';

  @override
  String get groupEnterGroupAnnouncement => 'गट घोषणा प्रविष्ट करा';

  @override
  String chatErrorWithMessage(String message) {
    return 'त्रुटी: $message';
  }

  @override
  String groupMemberCountClickToCopy(int count) {
    return '$count सदस्य, ग्रुप आयडी कॉपी करण्यासाठी क्लिक करा';
  }

  @override
  String get chatMusicLinkLabel => 'संगीत लिंक';

  @override
  String get chatNoMediaUrlAvailable => 'कोणतीही मीडिया URL उपलब्ध नाही';

  @override
  String get groupNoPermissionToEditGroupName =>
      'तुम्हाला गटाचे नाव संपादित करण्याची परवानगी नाही';

  @override
  String get chatRedPacketTransferCannotForward =>
      'लाल पॅकेट आणि ट्रान्सफर फॉरवर्ड करता येत नाहीत';

  @override
  String get authEmailAddress => 'ईमेल पत्ता';

  @override
  String get commonEnterEmailAddress => 'ईमेल पत्ता प्रविष्ट करा';

  @override
  String get authEmailRecoveryHint => 'पासवर्ड पुनर्प्राप्तीसाठी वापरला जातो';

  @override
  String get commonInvalidEmailFormat => 'कृपया वैध ईमेल पत्ता प्रविष्ट करा';

  @override
  String get authOptional => 'ऐच्छिक';

  @override
  String get authResetPassword => 'पासवर्ड रीसेट करा';

  @override
  String get authEnterRegisteredEmail =>
      'आपण नोंदणीकृत ईमेल पत्ता प्रविष्ट करा';

  @override
  String get authSendResetCode => 'रीसेट कोड पाठवा';

  @override
  String authResetCodeSent(String email) {
    return '$email वर पाठवलेला कोड रीसेट करा';
  }

  @override
  String get authEnterResetCode => 'रीसेट कोड प्रविष्ट करा';

  @override
  String get authSetNewPassword => 'नवीन पासवर्ड सेट करा';

  @override
  String get commonConfirmNewPassword => 'नवीन पासवर्डची पुष्टी करा';

  @override
  String get commonNewPassword => 'नवीन पासवर्ड';

  @override
  String get authPasswordResetSuccess =>
      'पासवर्ड रीसेट यशस्वी. कृपया तुमच्या नवीन पासवर्डने लॉग इन करा.';

  @override
  String get authResetPasswordFailed => 'पासवर्ड रीसेट करणे अयशस्वी झाले';

  @override
  String get settingsChangePassword => 'पासवर्ड बदला';

  @override
  String get settingsCurrentPassword => 'वर्तमान पासवर्ड';

  @override
  String get settingsEnterCurrentPassword => 'वर्तमान पासवर्ड प्रविष्ट करा';

  @override
  String get settingsEnterNewPassword => 'नवीन पासवर्ड टाका';

  @override
  String get settingsPasswordChanged =>
      'पासवर्ड यशस्वीरित्या बदलला. कृपया तुमच्या नवीन पासवर्डने लॉग इन करा.';

  @override
  String get settingsChangePasswordFailed => 'पासवर्ड बदलणे अयशस्वी';

  @override
  String get settingsNewPasswordMustBeDifferent =>
      'नवीन पासवर्ड सध्याच्या पासवर्डपेक्षा वेगळा असणे आवश्यक आहे';

  @override
  String get settingsChangePasswordInfo =>
      'पासवर्ड बदलल्यानंतर, तुम्हाला लॉग आउट केले जाईल आणि नवीन पासवर्डसह लॉग इन करावे लागेल.';

  @override
  String get settingsPasswordRequirements => 'पासवर्ड आवश्यकता:';

  @override
  String get settingsSecurityNote =>
      'सुरक्षिततेसाठी, पासवर्ड बदलल्यानंतर तुम्हाला सर्व उपकरणांवर पुन्हा लॉगिन करावे लागेल.';

  @override
  String get settingsSecurity => 'सुरक्षा';

  @override
  String get settingsCurrentBoundEmail => 'वर्तमान बंधनकारक ईमेल';

  @override
  String get settingsNewEmailAddress => 'नवीन ईमेल पत्ता';

  @override
  String get settingsEnterNewEmail => 'नवीन ईमेल पत्ता प्रविष्ट करा';

  @override
  String get settingsVerificationCode => 'सत्यापन कोड';

  @override
  String get settingsVerificationCodeSent => 'पडताळणी कोड पाठवला';

  @override
  String get settingsCodeSentTo => 'वर पडताळणी कोड पाठवला';

  @override
  String get settingsDidNotReceiveCode => 'कोड प्राप्त झाला नाही?';

  @override
  String get settingsEmailChangedSuccess => 'ईमेल यशस्वीरित्या बदलला';

  @override
  String get settingsChangeEmailFailed => 'ईमेल बदलणे अयशस्वी';

  @override
  String get settingsEmailSecurityNote =>
      'तुमचा ईमेल पासवर्ड पुनर्प्राप्तीसाठी वापरला जातो. कृपया ते सुरक्षित ठेवा.';

  @override
  String get commonGoogleLogin => 'Google सह साइन इन करा';

  @override
  String get commonAppleLogin => 'Apple सह साइन इन करा';

  @override
  String get commonWechat => 'WeChat';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsLanguageChanged => 'भाषा बदलली';

  @override
  String get settingsTranslation => 'भाषांतर';

  @override
  String get settingsTranslateTextTo => 'मध्ये मजकूर अनुवादित करा';

  @override
  String get settingsTranslateDescription =>
      'तुम्हाला ज्या भाषेत संदेशांचे भाषांतर करायचे आहे ती भाषा निवडा.';

  @override
  String get settingsAutoTranslate => 'प्राप्त संदेशांचे स्वयं-अनुवाद';

  @override
  String get settingsAutoTranslateDescription =>
      'चॅटमध्ये प्राप्त झालेल्या संदेशांचे तुमच्या निवडलेल्या भाषेत स्वयंचलितपणे भाषांतर करा.';

  @override
  String get settingsBiometricLogin => 'बायोमेट्रिक लॉगिन';

  @override
  String authLoginWithBiometric(Object type) {
    return '$type सह लॉग इन करा';
  }

  @override
  String get settingsBiometricLoginEnabled => 'बायोमेट्रिक लॉगिन सक्षम केले';

  @override
  String get settingsBiometricLoginDisabled => 'बायोमेट्रिक लॉगिन अक्षम केले';

  @override
  String get settingsEnableBiometricLogin => 'बायोमेट्रिक लॉगिन सक्षम करा';

  @override
  String get settingsBiometricEnabled =>
      'सक्षम - लॉग इन करण्यासाठी बायोमेट्रिक वापरा';

  @override
  String get settingsBiometricDisabled => 'अक्षम - सक्षम करण्यासाठी टॅप करा';

  @override
  String get settingsBiometricNeedRelogin =>
      'बायोमेट्रिक लॉगिन सक्षम करण्यासाठी कृपया लॉग आउट करा आणि पुन्हा लॉग इन करा';

  @override
  String get authOr => 'किंवा';

  @override
  String get qrcodeCameraPermissionRestricted =>
      'या डिव्हाइसवर कॅमेरा प्रवेश प्रतिबंधित आहे';

  @override
  String get authPasskeyLabel => 'पासकी';

  @override
  String get authGoogleLabel => 'Google';

  @override
  String get authAppleLabel => 'सफरचंद';


  @override
  String get authSsoNotConfigured => 'या सर्व्हरने SSO लॉगिन प्रदाते कॉन्फिगर केलेले नाहीत';
  @override
  String get authSsoLabel => 'SSO';

  @override
  String get transferAmountHintZero => '०.००';

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
      'पोक प्रत्यय प्रविष्ट करा, उदा.: खांद्यावर';

  @override
  String get groupAlbum => 'गट अल्बम';

  @override
  String get groupFiles => 'गट फायली';

  @override
  String get groupImages => 'प्रतिमा';

  @override
  String get groupVideos => 'व्हिडिओ';

  @override
  String get groupTotal => 'एकूण';

  @override
  String get groupSize => 'आकार';

  @override
  String get groupNoMedia => 'मीडिया नाही';

  @override
  String get groupNoMediaDescription =>
      'या ग्रुपमध्ये अद्याप कोणतेही फोटो किंवा व्हिडिओ नाहीत';

  @override
  String get groupDocuments => 'डॉक्स';

  @override
  String get groupNoFiles => 'फाईल्स नाहीत';

  @override
  String get groupNoFilesDescription => 'या गटात अद्याप कोणत्याही फाइल नाहीत';

  @override
  String groupDownloadStarted(String filename) {
    return '$filename डाउनलोड करत आहे...';
  }

  @override
  String get contactNoCommonGroups => 'कोणतेही सामान्य गट नाहीत';

  @override
  String get contactNoCommonGroupsDescription =>
      'तुमच्यामध्ये कोणतेही गट सामाईक नाहीत';

  @override
  String get chatVoiceMessage => 'आवाज';

  @override
  String get chatMessage => 'संदेश';

  @override
  String get conversationHideChat => 'लपवा';

  @override
  String get settingsQuickReply => 'द्रुत उत्तर';

  @override
  String get commonTranslate => 'भाषांतर करा';

  @override
  String get contactCreateTag => 'टॅग तयार करा';

  @override
  String get contactEnterTagName => 'टॅग नाव प्रविष्ट करा';

  @override
  String get contactEditTag => 'टॅग संपादित करा';

  @override
  String get contactDeleteTag => 'टॅग हटवा';

  @override
  String contactDeleteTagConfirm(String tagName) {
    return 'तुमची खात्री आहे की तुम्ही \"$tagName\" टॅग हटवू इच्छिता?';
  }

  @override
  String get contactNoTags => 'अद्याप कोणतेही टॅग नाहीत';

  @override
  String get contactFriendPermissions => 'मित्र परवानग्या';

  @override
  String get contactSetChatOnly => 'फक्त-चॅट म्हणून सेट करा';

  @override
  String get contactChatOnlyDesc =>
      'फक्त तुमच्याशी गप्पा मारू शकतात, इतर सामग्री लपवली जाईल';

  @override
  String get contactHideMyMoments => 'माझे क्षण लपवा';

  @override
  String get contactHideMyMomentsDesc => 'हा मित्र माझे क्षण पाहू शकत नाही';

  @override
  String get contactHideTheirMoments => 'त्यांचे क्षण लपवा';

  @override
  String get contactHideTheirMomentsDesc => 'या मित्राचे क्षण पाहू नका';

  @override
  String get contactHideMyStatus => 'माझी स्थिती लपवा';

  @override
  String get contactHideMyStatusDesc =>
      'हा मित्र माझे स्टेटस अपडेट पाहू शकत नाही';

  @override
  String get contactNoChatOnlyFriends => 'चॅट-फक्त मित्र नाहीत';

  @override
  String get contactNoOfficialAccounts => 'अधिकृत खाती नाहीत';

  @override
  String get contactFollowOfficialAccountsDesc =>
      'नवीनतम अद्यतने मिळविण्यासाठी अधिकृत खात्यांचे अनुसरण करा';

  @override
  String get contactNoServiceAccounts => 'सेवा खाती नाहीत';

  @override
  String get contactSubscribeServiceAccountsDesc =>
      'सोयीस्कर सेवांसाठी सेवा खात्यांची सदस्यता घ्या';

  @override
  String get contactNoEnterpriseContacts => 'कोणतेही एंटरप्राइझ संपर्क नाहीत';

  @override
  String get contactEnterpriseContactsDesc =>
      'एंटरप्राइझ संपर्क येथे प्रदर्शित केले जातील';

  @override
  String get profileCardPack => 'कार्ड पॅक';

  @override
  String get profileOrders => 'ऑर्डर';

  @override
  String get profileNoOrders => 'ऑर्डर नाहीत';

  @override
  String get profileOrdersDesc => 'तुमच्या ऑर्डर येथे प्रदर्शित केल्या जातील';

  @override
  String get profileNoCards => 'कार्ड नाहीत';

  @override
  String get profileCardsDesc => 'तुमची कार्डे येथे प्रदर्शित केली जातील';

  @override
  String get favoriteEnterTagsHint =>
      'स्वल्पविरामाने विभक्त केलेले टॅग प्रविष्ट करा';

  @override
  String get favoriteTagsUpdated => 'टॅग अपडेट केले';

  @override
  String get favoriteForwardedContent => 'सामग्री फॉरवर्ड केली';

  @override
  String get favoriteEnterNoteContent => 'टीप सामग्री प्रविष्ट करा';

  @override
  String get favoriteNoteAdded => 'टीप जोडली';

  @override
  String get favoriteLinkTitle => 'लिंक शीर्षक';

  @override
  String get favoriteLinkUrl => 'https://';

  @override
  String get favoriteLinkAdded => 'लिंक जोडली';

  @override
  String get contactPhotoAdded => 'फोटो जोडला';

  @override
  String get contactEnterPhone => 'फोन नंबर प्रविष्ट करा';

  @override
  String commonConversationWithId(String roomId) {
    return 'संभाषण: $roomId';
  }

  @override
  String commonContactWithId(String userId) {
    return 'संपर्क: $userId';
  }

  @override
  String get commonDiscover => 'शोधा';

  @override
  String commonDeveloping(String title) {
    return '$title\n(लवकरच येत आहे)';
  }

  @override
  String get commonPageNotFound => 'पृष्ठ आढळले नाही';

  @override
  String get commonBackToHome => 'घरी परत';

  @override
  String get settingsMessageNotifications => 'संदेश सूचना';

  @override
  String get settingsReceiveNewMessageNotifications =>
      'नवीन संदेश सूचना प्राप्त करा';

  @override
  String get settingsShowMessagePreview => 'संदेश पूर्वावलोकन दर्शवा';

  @override
  String get settingsShowMessageContentInNotification =>
      'सूचना मध्ये संदेश सामग्री दर्शवा';

  @override
  String get settingsNotificationSound => 'सूचना आवाज';

  @override
  String get settingsPlaySoundOnMessage => 'संदेश प्राप्त करताना आवाज वाजवा';

  @override
  String get commonVibration => 'कंपन';

  @override
  String get settingsVibrateOnMessage => 'संदेश प्राप्त करताना कंपन करा';

  @override
  String get settingsDoNotDisturbMode => 'त्रास देऊ नका';

  @override
  String get settingsDoNotDisturbDescription =>
      'निर्दिष्ट वेळेत सूचना प्राप्त करू नका';

  @override
  String get settingsStartTime => 'प्रारंभ वेळ';

  @override
  String get settingsEndTime => 'समाप्ती वेळ';

  @override
  String get settingsDeleteQuickReply => 'द्रुत उत्तर हटवा';

  @override
  String get settingsEditQuickReply => 'द्रुत उत्तर संपादित करा';

  @override
  String get settingsAddQuickReply => 'द्रुत उत्तर जोडा';

  @override
  String get settingsManageQuickReplies => 'द्रुत प्रत्युत्तरे व्यवस्थापित करा';

  @override
  String get settingsNoQuickReplies => 'द्रुत उत्तरे नाहीत';

  @override
  String get settingsDefaultQuickReplies =>
      'डीफॉल्ट द्रुत उत्तरे दर्शविली जातील';

  @override
  String get settingsWhoCanSee => 'कोण पाहू शकतो';

  @override
  String get settingsLastSeen => 'शेवटचे पाहिले';

  @override
  String get settingsHiddenChats => 'लपलेल्या गप्पा';

  @override
  String get settingsMessagesLabel => 'संदेश';

  @override
  String get settingsAllowStrangerMessages => 'अनोळखी संदेशांना अनुमती द्या';

  @override
  String get settingsReceiveMessagesFromNonContacts =>
      'संपर्क नसलेल्यांकडून संदेश प्राप्त करा';

  @override
  String get settingsReadReceipts => 'पावत्या वाचा';

  @override
  String get settingsLetOthersKnowYouRead => 'तुम्ही वाचता हे इतरांना कळू द्या';

  @override
  String get settingsTypingIndicator => 'टायपिंग इंडिकेटर';

  @override
  String get settingsLetOthersKnowYouTyping =>
      'तुम्ही टाइप करत आहात हे इतरांना कळू द्या';

  @override
  String get settingsEveryone => 'प्रत्येकजण';

  @override
  String get settingsContactsOnly => 'फक्त संपर्क';

  @override
  String get settingsNobody => 'कोणीही नाही';

  @override
  String settingsWhoCanSeeTitle(String title) {
    return '$title कोण पाहू शकतो';
  }

  @override
  String settingsVersionInfo(String version) {
    return 'आवृत्ती $version';
  }

  @override
  String get settingsCheckForUpdates => 'अद्यतनांसाठी तपासा';

  @override
  String get settingsOpenSourceLicenses => 'मुक्त स्रोत परवाने';

  @override
  String get settingsFeedbackAndSuggestions => 'अभिप्राय आणि सूचना';

  @override
  String get settingsBuiltOnMatrix => 'मॅट्रिक्स प्रोटोकॉलवर बिल्ट';

  @override
  String get settingsNoHiddenChats => 'कोणत्याही छुप्या गप्पा नाहीत';

  @override
  String get settingsNoHiddenChatsDescription =>
      'तुम्ही लपवलेल्या चॅट्स येथे दिसतील';

  @override
  String get settingsUnhideChat => 'लपवा';

  @override
  String get settingsDarkMode => 'गडद मोड';

  @override
  String get settingsFontSize => 'फॉन्ट आकार';

  @override
  String get settingsBubbleStyle => 'बबल शैली';

  @override
  String get settingsFollowSystem => 'प्रणालीचे अनुसरण करा';

  @override
  String get settingsAutoSwitchBySystem => 'सिस्टमद्वारे ऑटो स्विच';

  @override
  String get settingsLightMode => 'प्रकाश मोड';

  @override
  String get settingsAlwaysUseLightTheme => 'नेहमी हलकी थीम वापरा';

  @override
  String get settingsDarkModeOption => 'गडद मोड पर्याय';

  @override
  String get settingsAlwaysUseDarkTheme => 'नेहमी गडद थीम वापरा';

  @override
  String get settingsFontSizeSmall => 'लहान';

  @override
  String get settingsFontSizeStandard => 'मानक';

  @override
  String get settingsFontSizeLarge => 'मोठा';

  @override
  String get settingsFontSizeExtraLarge => 'अतिरिक्त मोठे';

  @override
  String get settingsBubbleStyleWechat => 'WeChat शैली';

  @override
  String get settingsBubbleStyleWechatDesc => 'क्लासिक WeChat बबल शैली';

  @override
  String get settingsBubbleStyleModern => 'आधुनिक शैली';

  @override
  String get settingsBubbleStyleModernDesc => 'स्वच्छ आधुनिक बबल शैली';

  @override
  String get settingsBubbleStyleClassic => 'क्लासिक शैली';

  @override
  String get settingsBubbleStyleClassicDesc => 'पारंपारिक बबल शैली';

  @override
  String get discoverVideoChannels => 'चॅनेल';

  @override
  String get discoverLive => 'लाइव्ह';

  @override
  String get discoverListen => 'ऐका';

  @override
  String get discoverWatch => 'पहा';

  @override
  String get discoverSearchDiscover => 'शोधा';

  @override
  String get discoverNearbyPeople => 'जवळपास';

  @override
  String get discoverGames => 'खेळ';

  @override
  String get discoverMiniPrograms => 'मिनी कार्यक्रम';

  @override
  String get chatAlreadyInCall => 'आधीच कॉलमध्ये आहे';

  @override
  String get commonConnectionFailed => 'कनेक्शन अयशस्वी';

  @override
  String get chatCallRejected => 'कॉल नाकारला';

  @override
  String get chatNoAnswer => 'उत्तर नाही';

  @override
  String get commonClose => 'बंद करा';

  @override
  String get chatSelectContact => 'संपर्क निवडा';

  @override
  String get chatVoteRemoved => 'मत काढले';

  @override
  String get chatVoteChanged => 'मत बदलले';

  @override
  String get chatVoted => 'मतदान केले';

  @override
  String chatReplyTo(String name) {
    return '$name ला उत्तर द्या';
  }

  @override
  String get chatCurrentLocation => 'वर्तमान स्थान';

  @override
  String chatNearbyPlace(int index) {
    return 'जवळपासचे ठिकाण $index';
  }

  @override
  String chatApproximateDistance(String distance) {
    return '$distance बद्दल';
  }

  @override
  String get chatAddress => 'पत्ता';

  @override
  String get chatLatitude => 'अक्षांश';

  @override
  String get chatLongitude => 'रेखांश';

  @override
  String get groupDescriptionUpdated => 'गट वर्णन अद्यतनित केले';

  @override
  String get groupAvatarUpdated => 'गट अवतार अपडेट केला';

  @override
  String get groupVisibilityUpdated => 'गट दृश्यमानता अद्यतनित केली';

  @override
  String get groupChannelCreated => 'चॅनल तयार केले';

  @override
  String get groupChannelUpdated => 'चॅनल अपडेट केले';

  @override
  String get groupChannelDeleted => 'चॅनल हटवले';

  @override
  String get callDecline => 'नकार';

  @override
  String get callAnswer => 'उत्तर द्या';

  @override
  String get callIncomingVideoCall => 'येणारा व्हिडिओ कॉल';

  @override
  String get callIncomingVoiceCall => 'इनकमिंग व्हॉइस कॉल';

  @override
  String get callVideoCallInProgress => 'व्हिडिओ कॉल प्रगतीपथावर आहे';

  @override
  String get callVoiceCallInProgress => 'व्हॉइस कॉल प्रगतीपथावर आहे';

  @override
  String get callReconnectingCall => 'पुन्हा कनेक्ट करत आहे...';

  @override
  String get callEnded => 'कॉल संपला';

  @override
  String get callFailed => 'कॉल अयशस्वी';

  @override
  String get callLivekitNotConfigured => 'LiveKit कॉन्फिगर केलेले नाही';

  @override
  String callJoinMeetingFailed(String error) {
    return 'मीटिंगमध्ये सामील होण्यात अयशस्वी: $error';
  }

  @override
  String callScreenShareFailed(String error) {
    return 'स्क्रीन शेअर अयशस्वी: $error';
  }

  @override
  String get profileN42BeanTitle => 'N42 बीन';

  @override
  String get profileNoN42Bean => 'N42 बीन नाही';

  @override
  String get profileN42BeanDetails => 'N42 बीन तपशील';

  @override
  String get profileN42BeanDescription =>
      'N42 Bean हे N42 मधील आभासी वस्तू आणि सेवा रिडीम करण्यासाठी वापरलेले टोकन आहे. सध्या यासाठी उपलब्ध आहे:';

  @override
  String get profileN42BeanFeature1 => 'विशेष सदस्य स्टिकर्स आणि थीम';

  @override
  String get profileN42BeanFeature2 => 'चॅट बबल सानुकूलन';

  @override
  String get profileN42BeanFeature3 => 'लाल पॅकेट कव्हर कस्टमायझेशन';

  @override
  String get profileN42BeanFeature4 => 'अनन्य टोपणनाव बॅज';

  @override
  String get profileN42BeanFeature5 => 'गट चॅट विशेषाधिकार';

  @override
  String get profileN42BeanFeature6 => 'क्लाउड स्टोरेज विस्तार';

  @override
  String get profileN42BeanFeature7 => 'व्हिडिओ कॉल सौंदर्य फिल्टर';

  @override
  String get profileN42BeanFeature8 => 'क्षणांचे पार्श्वभूमी सानुकूलन';

  @override
  String get profileN42BeanFeature9 => 'व्हीआयपी ग्राहक सेवेला प्राधान्य';

  @override
  String get profileGotIt => 'समजले';

  @override
  String get profileNoN42BeanRecords => 'N42 बीन रेकॉर्ड नाहीत';

  @override
  String get profileMoodAndThoughts => 'मूड आणि विचार';

  @override
  String get profileStatusHappy => 'आनंदी';

  @override
  String get profileStatusCracked => 'छिन्नविछिन्न';

  @override
  String get profileStatusLucky => 'भाग्यवान';

  @override
  String get profileStatusSunny => 'सनी';

  @override
  String get profileStatusTired => 'थकले';

  @override
  String get profileStatusDaydream => 'दिवास्वप्न';

  @override
  String get profileStatusRushing => 'घाईघाईने';

  @override
  String get profileStatusOverthinking => 'अतिविचार';

  @override
  String get profileStatusEnergized => 'उत्साही';

  @override
  String get profileWorkAndStudy => 'काम आणि अभ्यास';

  @override
  String get profileStatusWorking => 'कार्यरत';

  @override
  String get profileStatusStudying => 'अभ्यास करत आहे';

  @override
  String get profileStatusBusy => 'व्यस्त';

  @override
  String get profileStatusSlacking => 'स्लॅकिंग';

  @override
  String get profileStatusTraveling => 'प्रवास';

  @override
  String get profileStatusGoingHome => 'घरी जात आहे';

  @override
  String get profileStatusDnd => 'डू नॉट डिस्टर्ब';

  @override
  String get profileActivities => 'उपक्रम';

  @override
  String get profileStatusHanging => 'हँग आउट';

  @override
  String get profileStatusCheckIn => 'चेक इन करा';

  @override
  String get profileStatusExercising => 'व्यायाम करत आहे';

  @override
  String get profileStatusCoffee => 'कॉफी';

  @override
  String get profileStatusBubbleTea => 'बबल चहा';

  @override
  String get profileStatusEating => 'खाणे';

  @override
  String get profileStatusParenting => 'पालकत्व';

  @override
  String get profileStatusSavingWorld => 'सेव्हिंग वर्ल्ड';

  @override
  String get profileStatusSelfie => 'सेल्फी';

  @override
  String get profileRest => 'विश्रांती';

  @override
  String get profileStatusRetreat => 'माघार';

  @override
  String get profileStatusHome => 'घर';

  @override
  String get profileStatusSleeping => 'झोपलेला';

  @override
  String get profileStatusCatLover => 'मांजर प्रेमी';

  @override
  String get profileStatusDogWalking => 'चालणारा कुत्रा';

  @override
  String get profileStatusGaming => 'गेमिंग';

  @override
  String get profileStatusListening => 'ऐकत आहे';

  @override
  String get profileEditAddress => 'पत्ता संपादित करा';

  @override
  String get profileRecipient => 'प्राप्तकर्ता';

  @override
  String get profileEnterRecipientName => 'प्राप्तकर्त्याचे नाव प्रविष्ट करा';

  @override
  String get profilePhoneNumber => 'फोन नंबर';

  @override
  String get profileEnterPhoneNumber => 'फोन नंबर प्रविष्ट करा';

  @override
  String get profileRegionHint => 'प्रांत/शहर/जिल्हा';

  @override
  String get profileDetailedAddress => 'तपशीलवार पत्ता';

  @override
  String get profileDetailedAddressHint => 'रस्ता, इमारत क्रमांक इ.';

  @override
  String get profileSetAsDefaultAddress => 'डीफॉल्ट पत्ता म्हणून सेट करा';

  @override
  String get profilePleaseCompleteInfo => 'कृपया सर्व फील्ड पूर्ण करा';

  @override
  String get profileEditInvoice => 'बीजक संपादित करा';

  @override
  String get profileInvoiceType => 'बीजक प्रकार';

  @override
  String get profileCompanyName => 'कंपनीचे नाव';

  @override
  String get profilePersonalName => 'वैयक्तिक नाव';

  @override
  String get profileEnterCompanyName => 'कंपनीचे नाव एंटर करा';

  @override
  String get profileEnterName => 'नाव प्रविष्ट करा';

  @override
  String get profileTaxIdNumber => 'कर आयडी क्रमांक';

  @override
  String get profileEnterTaxIdNumber => 'कर आयडी क्रमांक प्रविष्ट करा';

  @override
  String get profileBankNameOptional => 'बँकेचे नाव (पर्यायी)';

  @override
  String get profileEnterBankName => 'बँकेचे नाव प्रविष्ट करा';

  @override
  String get profileBankAccountOptional => 'बँक खाते (पर्यायी)';

  @override
  String get profileEnterBankAccount => 'बँक खाते प्रविष्ट करा';

  @override
  String get profileCompanyAddressOptional => 'कंपनीचा पत्ता (पर्यायी)';

  @override
  String get profileEnterCompanyAddress => 'कंपनी पत्ता प्रविष्ट करा';

  @override
  String get profileCompanyPhoneOptional => 'कंपनी फोन (पर्यायी)';

  @override
  String get profileEnterCompanyPhone => 'कंपनी फोन प्रविष्ट करा';

  @override
  String get profileSetAsDefaultInvoice => 'डीफॉल्ट बीजक म्हणून सेट करा';

  @override
  String get profileRingtoneVibrate => 'कंपन';

  @override
  String get profileRingtoneSilent => 'मूक';

  @override
  String get profileVibrateMode => 'कंपन मोड';

  @override
  String get profileSilentMode => 'मूक मोड';

  @override
  String profilePlayFailed(String ringtoneName) {
    return 'प्ले करण्यात अयशस्वी: $ringtoneName';
  }

  @override
  String profilePlaying(String ringtoneName) {
    return 'खेळत आहे: $ringtoneName';
  }

  @override
  String get profileStop => 'थांबा';

  @override
  String get profileSelectRingtone => 'रिंगटोन निवडा';

  @override
  String get profileLoadingRingtones => 'रिंगटोन लोड करत आहे...';

  @override
  String get profileNoRingtonesFound => 'कोणतेही रिंगटोन आढळले नाहीत';

  @override
  String mainMessagesWithCount(int count) {
    return 'संदेश($count)';
  }

  @override
  String get storyViewers => 'दर्शक';

  @override
  String get storyNoViewers => 'अजून दर्शक नाहीत';

  @override
  String get storyReplyToStory => 'कथेला उत्तर द्या...';

  @override
  String get commonCopiedToClipboard => 'क्लिपबोर्डवर कॉपी केले';

  @override
  String get commonMore => 'अधिक';

  @override
  String get commonTranslating => 'भाषांतर करत आहे...';

  @override
  String commonTranslatedFrom(String language) {
    return '$language वरून अनुवादित';
  }

  @override
  String get commonTranslation => 'भाषांतर';

  @override
  String get commonTranslationFailed => 'भाषांतर अयशस्वी';

  @override
  String get commonAllRead => 'सर्व वाचले';

  @override
  String commonReadCount(int count) {
    return '$count वाचले';
  }

  @override
  String get commonYouRecalledMessage => 'तुला एक मेसेज आठवला';

  @override
  String get commonMessageRecalled => 'मेसेज आठवला';

  @override
  String get commonReEdit => 'पुन्हा संपादित करा';

  @override
  String get commonWalletArea => 'वॉलेट क्षेत्र';

  @override
  String get callIncomingCall => 'येणारा कॉल';

  @override
  String get callMissedCall => 'मिस्ड कॉल';

  @override
  String get groupRemoveAdmin => 'प्रशासक काढा';

  @override
  String get chatSelectCurrency => 'चलन निवडा';

  @override
  String get chatSelectEmoji => 'इमोजी निवडा';

  @override
  String get chatSelectRedPacketCover => 'कव्हर निवडा';

  @override
  String get groupSetAsAdmin => 'प्रशासक म्हणून सेट करा';

  @override
  String get chatVideoPlaybackFailed => 'व्हिडिओ प्लेबॅक अयशस्वी';

  @override
  String get groupViewProfile => 'प्रोफाइल पहा';

  @override
  String get favoriteAddLinkComingSoon => 'लिंक वैशिष्ट्य जोडा लवकरच येत आहे';

  @override
  String get favoriteNewNoteComingSoon => 'नवीन नोट वैशिष्ट्य लवकरच येत आहे';

  @override
  String get qrcodeSaveFeatureComingSoon => 'जतन करा वैशिष्ट्य लवकरच येत आहे';

  @override
  String get qrcodeShareFeatureComingSoon => 'शेअर वैशिष्ट्य लवकरच येत आहे';

  @override
  String qrcodeProcessFailed(String error) {
    return 'QR कोडवर प्रक्रिया करण्यात अयशस्वी: $error';
  }

  @override
  String get securityDeviceIdRequired => 'डिव्हाइस आयडी आवश्यक आहे';

  @override
  String securityVerificationStartFailed(String error) {
    return 'पडताळणी सुरू करण्यात अयशस्वी: $error';
  }

  @override
  String get securityVerificationFailed => 'पडताळणी अयशस्वी';

  @override
  String securityVerificationFailedWithReason(String reason) {
    return 'पडताळणी अयशस्वी: $reason';
  }

  @override
  String get securityEmojiMismatchRejected =>
      'पडताळणी नाकारली - इमोजी जुळत नाही';

  @override
  String get securityWaitingForDeviceAccept =>
      'इतर डिव्हाइस स्वीकारण्याची प्रतीक्षा करत आहे...';

  @override
  String get securityVerifyDevice => 'हे डिव्हाइस सत्यापित करा';

  @override
  String get securityConfirmEmojiMatch =>
      'खालील इमोजी दोन्ही उपकरणांवर एकाच क्रमाने प्रदर्शित झाल्याची पुष्टी करा';

  @override
  String get securityEmojiDontMatch => 'ते जुळत नाहीत';

  @override
  String get securityEmojiMatch => 'ते जुळतात';

  @override
  String get securityWaitingForDeviceConfirm =>
      'पुष्टी करण्यासाठी इतर डिव्हाइसची प्रतीक्षा करत आहे...';

  @override
  String get securityVerificationSuccess => 'पडताळणी यशस्वी!';

  @override
  String get securityDeviceVerifiedTrusted =>
      'हे डिव्हाइस आता सत्यापित आणि विश्वसनीय आहे.';

  @override
  String get securityCompareEmoji => 'दोन्ही उपकरणांवरील इमोजींची तुलना करा';

  @override
  String get securityCompareNumbers => 'दोन्ही उपकरणांवरील संख्यांची तुलना करा';

  @override
  String get commonTryAgain => 'पुन्हा प्रयत्न करा';

  @override
  String get commonDone => 'झाले';

  @override
  String get chatExportTitle => 'गप्पा निर्यात करा';

  @override
  String get chatExportSuccess => 'निर्यात यशस्वी';

  @override
  String chatExportFailed(String error) {
    return 'निर्यात अयशस्वी: $error';
  }

  @override
  String get chatExportFormat => 'निर्यात स्वरूप';

  @override
  String get chatExportHtmlDesc =>
      'शैलीबद्ध लेआउटसह कोणत्याही ब्राउझरमध्ये वाचनीय';

  @override
  String get chatExportJsonDesc => 'मशीन-वाचनीय संरचित डेटा स्वरूप';

  @override
  String get chatExportDateRange => 'तारीख श्रेणी';

  @override
  String get chatExportAll => 'सर्व संदेश';

  @override
  String get chatExportLastWeek => 'शेवटचे ७ दिवस';

  @override
  String get chatExportLastMonth => 'गेल्या महिन्यात';

  @override
  String get chatExportLast3Months => 'मागील ३ महिने';

  @override
  String get chatExportMessageCount => 'निर्यात करण्यासाठी संदेश';

  @override
  String get chatExportButton => 'निर्यात आणि सामायिक करा';

  @override
  String get chatMediaGallery => 'मीडिया गॅलरी';

  @override
  String get chatExportHistory => 'चॅट इतिहास निर्यात करा';

  @override
  String get pdfLoadFailed => 'PDF लोड करण्यात अयशस्वी';

  @override
  String pdfPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get mediaAll => 'सर्व';

  @override
  String get mediaImages => 'प्रतिमा';

  @override
  String get mediaVideos => 'व्हिडिओ';

  @override
  String get mediaFiles => 'फाईल्स';

  @override
  String get mediaAudio => 'ऑडिओ';

  @override
  String mediaItemsCount(int count) {
    return '$count आयटम';
  }

  @override
  String get mediaNoMediaFound => 'कोणतेही माध्यम आढळले नाही';

  @override
  String get spacesTitle => 'समुदाय';

  @override
  String get spacesCreate => 'समुदाय तयार करा';

  @override
  String get spacesJoined => 'सामील झाले';

  @override
  String get spacesDiscover => 'शोधा';

  @override
  String get spacesNoJoined => 'अद्याप कोणतेही समुदाय सामील झाले नाहीत';

  @override
  String get spacesExplore => 'समुदाय एक्सप्लोर करा';

  @override
  String get spacesNoPublic => 'कोणतेही सार्वजनिक समुदाय आढळले नाहीत';

  @override
  String get spacesJoin => 'सामील व्हा';

  @override
  String get spacesSubSpaces => 'उप-समुदाय';

  @override
  String get spacesChannels => 'चॅनेल';

  @override
  String spacesMembersCount(int count) {
    return '$count सदस्य';
  }

  @override
  String get spacesPublic => 'सार्वजनिक';

  @override
  String get spacesPrivate => 'खाजगी';

  @override
  String get spacesSuggested => 'सुचवले';

  @override
  String spacesChannelsCount(int count) {
    return '$count चॅनेल';
  }

  @override
  String get callInCallChat => 'इन-कॉल चॅट';

  @override
  String callMessagesCount(int count) {
    return '$count संदेश';
  }

  @override
  String get callNoMessagesYet =>
      'अद्याप कोणतेही संदेश नाहीत.\nप्रारंभ करण्यासाठी एक संदेश पाठवा.';

  @override
  String get callTypeMessage => 'संदेश टाइप करा...';

  @override
  String get callYouSender => 'आपण';

  @override
  String get callChatLabel => 'गप्पा';

  @override
  String get chatEdited => 'संपादित';

  @override
  String get chatEditHistory => 'इतिहास संपादित करा';

  @override
  String get chatOriginalMessage => 'मूळ';

  @override
  String chatEditedAt(String time) {
    return '$time येथे संपादित';
  }

  @override
  String get chatViewOnce => 'एकदा पहा';

  @override
  String get chatViewOncePhoto => 'एकदा फोटो पहा';

  @override
  String get chatViewOnceVideo => 'एकदा व्हिडिओ पहा';

  @override
  String get chatViewOnceViewed => 'पाहिले';

  @override
  String get chatViewOnceExpired => 'कालबाह्य';

  @override
  String get chatViewOnceTap => 'पाहण्यासाठी टॅप करा';

  @override
  String get chatAutoFaceBlur => 'स्वयं चेहरा अस्पष्ट';

  @override
  String get chatAutoFaceBlurDesc => 'फोटो पाठवताना चेहरे आपोआप अस्पष्ट करा';

  @override
  String get threadReplyInThread => 'धाग्यात उत्तर द्या';

  @override
  String threadReplies(int count) {
    return '$count उत्तरे';
  }

  @override
  String get threadReply => '1 उत्तर';

  @override
  String threadLatestReply(String preview) {
    return 'नवीनतम: $preview';
  }

  @override
  String get threadTitle => 'धागा';

  @override
  String get threadReplyPlaceholder => 'धाग्यात उत्तर द्या...';

  @override
  String threadParticipants(int count) {
    return '$count सहभागी';
  }

  @override
  String get voiceRoomTitle => 'व्हॉइस रूम';

  @override
  String get voiceRoomCreate => 'व्हॉइस रूम तयार करा';

  @override
  String get voiceRoomJoin => 'सामील व्हा';

  @override
  String get voiceRoomLeave => 'सोडा';

  @override
  String get voiceRoomEnd => 'शेवटची खोली';

  @override
  String get voiceRoomRaiseHand => 'हात वर करा';

  @override
  String get voiceRoomLowerHand => 'खालचा हात';

  @override
  String get voiceRoomMute => 'नि:शब्द करा';

  @override
  String get voiceRoomUnmute => 'अनम्यूट करा';

  @override
  String get voiceRoomHost => 'यजमान';

  @override
  String get voiceRoomSpeakers => 'वक्ते';

  @override
  String get voiceRoomListeners => 'श्रोते';

  @override
  String get voiceRoomLive => 'लाइव्ह';

  @override
  String get voiceRoomEnded => 'संपले';

  @override
  String get voiceRoomScheduled => 'अनुसूचित';

  @override
  String get voiceRoomApprove => 'मंजूर करा';

  @override
  String get voiceRoomDemote => 'श्रोत्याकडे जा';

  @override
  String voiceRoomHandRaised(String name) {
    return '$name यांनी हात वर केला';
  }

  @override
  String get voiceRoomName => 'खोलीचे नाव';

  @override
  String get voiceRoomTopic => 'विषय (पर्यायी)';

  @override
  String get voiceRoomNoActive => 'सक्रिय व्हॉइस रूम नाहीत';

  @override
  String get voiceRoomConnecting => 'कनेक्ट करत आहे...';

  @override
  String get usernameTitle => 'वापरकर्तानाव';

  @override
  String get usernameSet => 'वापरकर्तानाव सेट करा';

  @override
  String get usernameChange => 'वापरकर्तानाव बदला';

  @override
  String get usernamePlaceholder => 'वापरकर्तानाव प्रविष्ट करा';

  @override
  String get usernameAvailable => 'वापरकर्तानाव उपलब्ध';

  @override
  String get usernameUnavailable => 'वापरकर्तानाव आधीच घेतले आहे';

  @override
  String get usernameInvalid =>
      '3-30 वर्ण, लोअरकेस अक्षरे, संख्या, अंडरस्कोर. अक्षराने सुरुवात करावी.';

  @override
  String get usernameReserved => 'हे वापरकर्तानाव राखीव आहे';

  @override
  String get usernameSaved => 'वापरकर्तानाव जतन केले';

  @override
  String get usernameSearchHint => '@username द्वारे शोधा';

  @override
  String get ensName => 'ENS नाव';

  @override
  String get ensLinked => 'ENS शी जोडलेले';

  @override
  String get ensResolving => 'ENS निराकरण करत आहे...';

  @override
  String get ensNotFound => 'ENS नाव सापडले नाही';

  @override
  String get tokenGateTitle => 'टोकन गेट';

  @override
  String get tokenGateEnable => 'टोकन गेट सक्षम करा';

  @override
  String get tokenGateDisable => 'टोकन गेट अक्षम करा';

  @override
  String get tokenGateAddRule => 'नियम जोडा';

  @override
  String get tokenGateRemoveRule => 'नियम काढा';

  @override
  String get tokenGateContractAddress => 'कराराचा पत्ता';

  @override
  String get tokenGateMinBalance => 'किमान शिल्लक';

  @override
  String get tokenGateTokenId => 'टोकन आयडी (ERC-1155)';

  @override
  String get tokenGateChainId => 'साखळी आयडी';

  @override
  String get tokenGateVerifying => 'टोकन होल्डिंगची पडताळणी करत आहे...';

  @override
  String get tokenGateVerified => 'पडताळणी पास झाली';

  @override
  String get tokenGateDenied => 'तुम्ही टोकन आवश्यकता पूर्ण करत नाही';

  @override
  String get tokenGateOperatorAnd => 'सर्व नियमांचे पालन करणे आवश्यक आहे';

  @override
  String get tokenGateOperatorOr => 'कोणताही नियम पूर्ण करणे आवश्यक आहे';

  @override
  String get tokenGateRuleErc20 => 'ERC-20 टोकन';

  @override
  String get tokenGateRuleErc721 => 'NFT (ERC-721)';

  @override
  String get tokenGateRuleErc1155 => 'मल्टी-टोकन (ERC-1155)';

  @override
  String get tokenGateRuleNative => 'मूळ टोकन';

  @override
  String get tokenGateSaved => 'टोकन गेट जतन केले';

  @override
  String get tokenGateEnableDescription =>
      'सामील होण्यासाठी सदस्यांना टोकन धारण करणे आवश्यक आहे';

  @override
  String get tokenGateOperator => 'नियम तर्कशास्त्र';

  @override
  String get tokenGateRules => 'नियम';

  @override
  String get tokenGateSymbol => 'चिन्ह (पर्यायी)';

  @override
  String get tokenGateChain => 'साखळी';

  @override
  String get tokenGateTokenStandard => 'टोकन मानक';

  @override
  String get tokenGateDenialMessage => 'नकार संदेश';

  @override
  String get tokenGateDenialMessageHint =>
      'सत्यापन अयशस्वी झाल्यावर संदेश दर्शविला जातो';

  @override
  String get tokenGateVerifyTitle => 'टोकन सत्यापन';

  @override
  String get tokenGateVerifyPassed => 'पडताळणी उत्तीर्ण';

  @override
  String get tokenGateVerifyFailed => 'पडताळणी अयशस्वी';

  @override
  String get tokenGateRetryVerify => 'पुन्हा प्रयत्न करा';

  @override
  String get tokenGateRequired => 'आवश्यक आहे';

  @override
  String get tokenGateYourBalance => 'तुमची शिल्लक';

  @override
  String get tokenGateRulesActive => 'नियम सक्रिय';

  @override
  String get tokenGateDisabled => 'अक्षम';

  @override
  String get ensNotBound => 'बंधन नाही';

  @override
  String get liveLocation => 'थेट स्थान';

  @override
  String get stopLiveLocation => 'शेअरिंग थांबवा';

  @override
  String get startLiveLocation => 'शेअरिंग सुरू करा';

  @override
  String get selectDuration => 'कालावधी निवडा';

  @override
  String get groupChatFiles => 'चॅट फाइल्स';

  @override
  String get groupLinks => 'दुवे';

  @override
  String get groupNoLinks => 'अजून लिंक नाहीत';

  @override
  String get chatBackground => 'गप्पा पार्श्वभूमी';

  @override
  String get solidColors => 'घन रंग';

  @override
  String get gradients => 'ग्रेडियंट';

  @override
  String get defaultBackground => 'डीफॉल्ट';

  @override
  String get settingsFontSizeSlider => 'फॉन्ट आकार';

  @override
  String get autoDownload => 'स्वयं-डाउनलोड';

  @override
  String get images => 'प्रतिमा';

  @override
  String get voice => 'आवाज';

  @override
  String get video => 'व्हिडिओ';

  @override
  String get files => 'फाईल्स';

  @override
  String get mobileData => 'मोबाइल डेटा';

  @override
  String get roaming => 'रोमिंग';

  @override
  String get storageManagement => 'स्टोरेज';

  @override
  String get totalUsage => 'एकूण वापर';

  @override
  String get cache => 'कॅशे';

  @override
  String get other => 'इतर';

  @override
  String get clearCache => 'कॅशे साफ करा';

  @override
  String get cacheCleared => 'कॅशे साफ केले';

  @override
  String get clearCacheFailed => 'कॅशे साफ करण्यात अयशस्वी';

  @override
  String get confirmClearCache => 'सर्व कॅशे डेटा साफ करायचा?';

  @override
  String get mapView => 'नकाशा दृश्य';

  @override
  String liveLocationSharingCount(int count) {
    return '$count लोक स्थान शेअर करत आहेत';
  }

  @override
  String get minutes15 => '15 मिनिटे';

  @override
  String get minutes30 => '30 मिनिटे';

  @override
  String get hour1 => '1 तास';

  @override
  String get hours8 => '8 तास';

  @override
  String get personalCard => 'वैयक्तिक कार्ड';

  @override
  String get downloadFailed => 'डाउनलोड अयशस्वी';

  @override
  String get locationExpired => 'कालबाह्य';

  @override
  String secondsRemaining(int count) {
    return '$count सेकंद';
  }

  @override
  String minutesRemaining(int count) {
    return '$count मिनिटे';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '$hours तास $minutes मिनिटे';
  }

  @override
  String get favoriteMessages => 'आवडते';

  @override
  String get linksCopied => 'लिंक कॉपी केली';

  @override
  String get noLinksFound => 'कोणतेही दुवे सापडले नाहीत';

  @override
  String get roomStorageRanking => 'रूम स्टोरेज रँकिंग';

  @override
  String get downloadComplete => 'डाउनलोड पूर्ण झाले';

  @override
  String get downloading => 'डाउनलोड करत आहे...';

  @override
  String get draftSaved => 'मसुदा जतन केला';

  @override
  String get voiceRecording => 'व्हॉइस रेकॉर्डिंग';

  @override
  String get searchLocation => 'स्थान शोधा';

  @override
  String get tapToSearch => 'शोधण्यासाठी टॅप करा';

  @override
  String get settingsThisDevice => 'हे उपकरण';

  @override
  String get settingsJustNow => 'आत्ताच';

  @override
  String get settingsDeviceId => 'डिव्हाइस आयडी';

  @override
  String get settingsStatus => 'स्थिती';

  @override
  String get settingsLastActive => 'शेवटचे सक्रिय';

  @override
  String get settingsIpAddress => 'IP पत्ता';

  @override
  String get settingsRenameDevice => 'डिव्हाइसचे नाव बदला';

  @override
  String get settingsDeviceNameHint => 'डिव्हाइसचे नाव प्रविष्ट करा';

  @override
  String get settingsDeviceRenamed => 'डिव्हाइसचे नाव बदलले';

  @override
  String get settingsRenameFailed => 'पुनर्नामित अयशस्वी';

  @override
  String get settingsRemoteLogout => 'दूरस्थ लॉगआउट';

  @override
  String settingsRemoteLogoutConfirm(String deviceName) {
    return 'तुमची खात्री आहे की तुम्ही \"$deviceName\" ला लॉग आउट करू इच्छिता? ही क्रिया पूर्ववत केली जाऊ शकत नाही.';
  }

  @override
  String get settingsDeviceLoggedOut => 'डिव्हाइस लॉग आउट झाले';

  @override
  String get settingsLogoutFailed => 'लॉगआउट अयशस्वी';

  @override
  String get settingsLogout => 'लॉगआउट करा';

  @override
  String get settingsVerifyIdentity => 'ओळख सत्यापित करा';

  @override
  String get settingsEnterPasswordToConfirm =>
      'या क्रियेची पुष्टी करण्यासाठी तुमचा पासवर्ड एंटर करा.';

  @override
  String get scheduledSendTitle => 'संदेश शेड्यूल करा';

  @override
  String get scheduledSendInOneHour => '1 तासात';

  @override
  String get scheduledSendTonight => 'आज रात्री (8:00 PM)';

  @override
  String get scheduledSendTomorrowMorning => 'उद्या सकाळी (9:00 AM)';

  @override
  String get scheduledSendCustom => 'तारीख आणि वेळ निवडा';

  @override
  String get scheduledMessageLabel => 'अनुसूचित';

  @override
  String get scheduledMessageCancel => 'शेड्यूल केलेला संदेश रद्द करा';

  @override
  String get chatLockTitle => 'चॅट लॉक';

  @override
  String get chatLockEnable => 'या गप्पा लॉक करा';

  @override
  String get chatLockDisable => 'या गप्पा अनलॉक करा';

  @override
  String get chatLockDescription =>
      'लॉक केलेल्या चॅट उघडण्यासाठी बायोमेट्रिक किंवा पिन पडताळणी आवश्यक आहे';

  @override
  String get chatLockVerifyTitle => 'चॅट लॉक केले';

  @override
  String get chatLockVerifySubtitle =>
      'या चॅटमध्ये प्रवेश करण्यासाठी सत्यापित करा';

  @override
  String get chatLockVerifyFailed => 'पडताळणी अयशस्वी';

  @override
  String get chatLockEnabled => 'चॅट लॉक केले';

  @override
  String get chatLockDisabled => 'चॅट अनलॉक केले';

  @override
  String get chatLockPinTitle => 'पिन एंटर करा';

  @override
  String get chatLockPinSetTitle => 'पिन सेट करा';

  @override
  String get chatLockPinConfirmTitle => 'पिनची पुष्टी करा';

  @override
  String get chatLockPinMismatch => 'पिन जुळत नाही';

  @override
  String get chatLockUseBiometric => 'बायोमेट्रिक वापरा';

  @override
  String get chatLockUsePin => 'पिन वापरा';

  @override
  String get mediaEditorUndo => 'पूर्ववत करा';

  @override
  String get mediaEditorRedo => 'पुन्हा करा';

  @override
  String get mediaEditorCrop => 'पीक';

  @override
  String get mediaEditorFilter => 'फिल्टर करा';

  @override
  String get mediaEditorDraw => 'काढा';

  @override
  String get mediaEditorText => 'मजकूर';

  @override
  String get aiAssistant => 'एआय सहाय्यक';

  @override
  String get aiAssistantWelcome =>
      'नमस्कार! मी N42 AI असिस्टंट आहे. मी तुम्हाला कशी मदत करू शकतो?';

  @override
  String get aiAssistantNotConfigured => 'AI सेवा कॉन्फिगर केलेली नाही';

  @override
  String get aiAssistantSettings => 'AI सेटिंग्ज';

  @override
  String get aiAssistantClearHistory => 'चॅट इतिहास साफ करा';

  @override
  String get aiAssistantClearHistoryConfirm =>
      'तुमची खात्री आहे की तुम्ही सर्व AI चॅट इतिहास साफ करू इच्छिता?';

  @override
  String get aiAssistantStopGenerating => 'निर्माण करणे थांबवा';

  @override
  String get aiAssistantModel => 'मॉडेल';

  @override
  String get aiAssistantTemperature => 'तापमान';

  @override
  String get aiAssistantMaxTokens => 'कमाल टोकन';

  @override
  String get aiAssistantContextWindow => 'संदर्भ विंडो';

  @override
  String get aiAssistantServiceStatus => 'सेवा स्थिती';

  @override
  String get aiAssistantAvailable => 'उपलब्ध';

  @override
  String get aiAssistantUnavailable => 'अनुपलब्ध';

  @override
  String get aiSummarize => 'AI सारांश';

  @override
  String aiSummarizeUnread(int count) {
    return '$count न वाचलेले संदेश सारांशित करा';
  }

  @override
  String get aiSummarizeLoading => 'सारांश देत आहे...';

  @override
  String get aiSummarizeError => 'सारांश देण्यात अयशस्वी';

  @override
  String get aiRewrite => 'AI पुनर्लेखन';

  @override
  String get aiRewriteFormal => 'औपचारिक';

  @override
  String get aiRewriteCasual => 'प्रासंगिक';

  @override
  String get aiRewritePlayful => 'खेळकर';

  @override
  String get aiRewriteProfessional => 'व्यावसायिक';

  @override
  String get aiRewriteAccept => 'वापरा';

  @override
  String get aiRewriteCancel => 'रद्द करा';

  @override
  String get aiRewriteLoading => 'पुन्हा लिहित आहे...';

  @override
  String get aiLinkSummary => 'AI सारांश';

  @override
  String get aiLinkSummaryAnalyzing => 'विश्लेषण करत आहे...';

  @override
  String get chatFolderManagement => 'फोल्डर व्यवस्थापित करा';

  @override
  String get chatFolderSystem => 'सिस्टम फोल्डर्स';

  @override
  String get chatFolderCustom => 'सानुकूल फोल्डर';

  @override
  String get chatFolderEmpty => 'अद्याप कोणतेही सानुकूल फोल्डर नाहीत';

  @override
  String get chatFolderCreate => 'फोल्डर तयार करा';

  @override
  String get chatFolderEdit => 'फोल्डर संपादित करा';

  @override
  String get chatFolderNameHint => 'फोल्डरचे नाव';

  @override
  String get chatFolderAll => 'सर्व';

  @override
  String get chatFolderUnread => 'न वाचलेले';

  @override
  String get chatFolderPersonal => 'वैयक्तिक';

  @override
  String get chatFolderGroups => 'गट';

  @override
  String get chatFolderChannels => 'चॅनेल';

  @override
  String get chatFolderMuted => 'निःशब्द';

  @override
  String get storyAddMusic => 'संगीत जोडा';

  @override
  String get storyChangeMusic => 'संगीत बदला';

  @override
  String get storyBackgroundMusic => 'पार्श्वसंगीत';

  @override
  String get storyMusicPreview => 'पूर्वावलोकन (कमाल 15 से)';

  @override
  String get storyChooseFromDevice => 'डिव्हाइसमधून निवडा';

  @override
  String get storyUseThisMusic => 'हे संगीत वापरा';

  @override
  String get authPasskeyNotSupported => 'या डिव्हाइसवर पासकी समर्थित नाही';

  @override
  String get authPasskeyRegister => 'पासकी नोंदणी करा';

  @override
  String get authPasskeyNoRegistered => 'कोणत्याही पासकी नोंदणीकृत नाहीत';

  @override
  String get authPasskeyRegisterHint =>
      'या खात्यासाठी पासकी नोंदवा. स्टँडअलोन पासकी साइन-इन नंतर सक्षम केले जाईल.';

  @override
  String get authPasskeyNameYours => 'तुमच्या पासकीला नाव द्या';

  @override
  String get authPasskeyRegistered => 'पासकी या खात्यात सेव्ह केली आहे';

  @override
  String get authPasskeyDeleted => 'या खात्यातून पासकी काढली';

  @override
  String authPasskeyDeleteConfirm(String name) {
    return 'पासकी \"$name\" हटवायची? पासकी साइन-इन नंतर वापरण्यापूर्वी तुम्हाला त्याची पुन्हा नोंदणी करावी लागेल.';
  }

  @override
  String get momentVisibilityPublic => 'सार्वजनिक';

  @override
  String get momentVisibilityPrivate => 'खाजगी';

  @override
  String get momentVisibilityPartial => 'निवडलेले मित्र';

  @override
  String get momentVisibilityExcluded => 'काही मित्रांना वगळा';

  @override
  String momentUserMoments(String userName) {
    return '$userName चे क्षण';
  }

  @override
  String get momentForwardTo => 'कडे फॉरवर्ड करा';

  @override
  String get momentForwardSuccess => 'यशस्वीरित्या फॉरवर्ड केले';

  @override
  String get momentSelectFriends => 'मित्र निवडा';

  @override
  String get momentSelectTags => 'टॅगनुसार निवडा';

  @override
  String momentSelectedCount(int count) {
    return 'निवडले ($count)';
  }

  @override
  String get momentNoMomentsYet => 'अजून काही क्षण नाहीत';

  @override
  String get momentForwardMoment => 'फॉरवर्ड मोमेंट';

  @override
  String get momentAddComment => 'एक टिप्पणी जोडा...';

  @override
  String momentForwardContent(String content) {
    return '[क्षण] $content';
  }

  @override
  String get momentDeleteMoment => 'क्षण हटवा';

  @override
  String get momentDeleteConfirm =>
      'तुमची खात्री आहे की तुम्ही हा क्षण हटवू इच्छिता?';

  @override
  String get momentComment => 'टिप्पणी द्या';

  @override
  String get momentWriteComment => 'टिप्पणी लिहा...';

  @override
  String get momentLike => 'आवडले';

  @override
  String get momentUnlike => 'विपरीत';

  @override
  String get momentForward => 'पुढे';

  @override
  String get momentDelete => 'हटवा';

  @override
  String get momentReply => 'उत्तर';

  @override
  String get momentMoment => 'क्षण';

  @override
  String momentLikesCount(int count) {
    return '$count आवडी';
  }

  @override
  String momentCommentsCount(int count) {
    return '$count टिप्पण्या';
  }

  @override
  String get momentNoComments => 'अद्याप कोणत्याही टिप्पण्या नाहीत';

  @override
  String get momentFailedToLoad => 'प्रतिमा लोड करण्यात अयशस्वी';

  @override
  String momentReplyTo(String userName) {
    return '$userName ला उत्तर द्या...';
  }

  @override
  String get momentNoConversations => 'कोणतीही संभाषणे नाहीत';

  @override
  String get momentJustNow => 'आत्ताच';

  @override
  String momentMinutesAgo(int count) {
    return '${count}m पूर्वी';
  }

  @override
  String momentHoursAgo(int count) {
    return '${count}h पूर्वी';
  }

  @override
  String momentDaysAgo(int count) {
    return '${count}d पूर्वी';
  }

  @override
  String get chatGroupAnnouncementHint => 'गट घोषणा प्रविष्ट करा';

  @override
  String get chatGroupAnnouncementEmpty => 'कोणतीही घोषणा नाही';

  @override
  String get chatEditNickname => 'टोपणनाव संपादित करा';

  @override
  String get chatNicknameHint => 'या गटात आपले टोपणनाव प्रविष्ट करा';

  @override
  String get contactAddPhoneHint => 'फोन नंबर प्रविष्ट करा';

  @override
  String get contactNotesHint => 'या संपर्काबद्दल टिपा जोडा';

  @override
  String get reportTitle => 'अहवाल द्या';

  @override
  String get reportReasonSpam => 'स्पॅम';

  @override
  String get reportReasonHarassment => 'छळ';

  @override
  String get reportReasonFraud => 'फसवणूक';

  @override
  String get reportReasonOther => 'इतर';

  @override
  String get reportSubmitted => 'अहवाल सादर केला';

  @override
  String get reportDescription => 'अतिरिक्त वर्णन (पर्यायी)';

  @override
  String get qrcodeSaved => 'QR कोड अल्बममध्ये सेव्ह केला';

  @override
  String get chatSendRedPacketInChat => 'कृपया चॅटमध्ये लाल पॅकेट पाठवा';

  @override
  String get commonSaveFailed => 'जतन करणे अयशस्वी झाले';

  @override
  String get reportSelectReason => 'कृपया कारण निवडा';

  @override
  String get gameCenter => 'खेळ';

  @override
  String get gameHighScore => 'सर्वोत्तम';

  @override
  String get gameScore => 'स्कोअर';

  @override
  String get gameOver => 'खेळ संपला';

  @override
  String get gamePlayAgain => 'पुन्हा खेळा';

  @override
  String get gameLeaderboard => 'लीडरबोर्ड';

  @override
  String get gamePause => 'विराम दिला';

  @override
  String get gameResume => 'पुन्हा सुरू करण्यासाठी टॅप करा';

  @override
  String get gameConfirmExit => 'हा खेळ सोडायचा?';

  @override
  String get gameNoScores => 'अद्याप कोणतेही स्कोअर नाहीत';

  @override
  String get game2048 => '2048';

  @override
  String get game2048Desc => '2048 पर्यंत पोहोचण्यासाठी टाइल्स मर्ज करा';

  @override
  String get gameBlockDrop => 'ब्लॉक ड्रॉप';

  @override
  String get gameBlockDropDesc => 'ड्रॉप आणि स्पष्ट रेषा';

  @override
  String get gameMinesweeper => 'माइनस्वीपर';

  @override
  String get gameMinesweeperDesc => 'सर्व सुरक्षित पेशी शोधा';

  @override
  String get gameMatch3 => 'सामना 3';

  @override
  String get gameMatch3Desc => '3 किंवा अधिक रत्ने जुळवा';

  @override
  String get gameMinesweeperEasy => 'सोपे';

  @override
  String get gameMinesweeperMedium => 'मध्यम';

  @override
  String get gameMinesLeft => 'खाणी बाकी';

  @override
  String get gameTimeLeft => 'वेळ';

  @override
  String get gameLevel => 'पातळी';

  @override
  String get gameNext => 'पुढे';

  @override
  String get gameBestTime => 'सर्वोत्तम वेळ';

  @override
  String get gameNewRecord => 'नवीन रेकॉर्ड!';

  @override
  String get gameLines => 'ओळी';

  @override
  String get storyMyStory => 'माझी कथा';

  @override
  String get storageSmartCleanup => 'स्मार्ट क्लीनअप';

  @override
  String get storageOldMediaFiles => 'जुन्या मीडिया फायली';

  @override
  String get storageLargeFiles => 'मोठ्या फायली';

  @override
  String get storageAppCache => 'ॲप कॅशे';

  @override
  String get storageSettings => 'स्टोरेज सेटिंग्ज';

  @override
  String get storageAutoCleanup => 'ऑटो क्लीनअप';

  @override
  String storageAutoCleanupDesc(int days) {
    return '$days दिवसांपेक्षा जुन्या फायली स्वयंचलितपणे साफ करा';
  }

  @override
  String get storageCleanupPeriod => 'साफसफाईचा कालावधी';

  @override
  String get storagePreserveThumbnails => 'लघुप्रतिमा जतन करा';

  @override
  String get storagePreserveThumbnailsDesc =>
      'साफसफाई दरम्यान प्रतिमा लघुप्रतिमा ठेवा';

  @override
  String get storageWarningHigh =>
      'स्टोरेजचा वापर जास्त आहे. जुन्या फाइल्स साफ करण्याचा विचार करा.';

  @override
  String get storageWarningCritical =>
      'स्टोरेज गंभीरपणे कमी आहे. कृपया मोकळी जागा साफ करा.';

  @override
  String storageFreed(String size, int count) {
    return 'मुक्त $size ($count फाइल्स)';
  }

  @override
  String storageDays(int days) {
    return '$days दिवस';
  }

  @override
  String storageViewAllRooms(int count) {
    return 'सर्व $count खोल्या पहा';
  }

  @override
  String get storageNoFiles => 'कोणत्याही फाइल आढळल्या नाहीत';

  @override
  String get storageFilePinned => 'पिन केलेला';

  @override
  String storageDeleteSelected(int count) {
    return '$count निवडलेल्या फाइल्स हटवायच्या? ते सर्व्हरवरून पुन्हा डाउनलोड केले जाऊ शकतात.';
  }

  @override
  String get backupRestore => 'बॅकअप आणि पुनर्संचयित करा';

  @override
  String get backupCreate => 'बॅकअप तयार करा';

  @override
  String get backupCreateDesc =>
      'तुमच्या सेटिंग्ज आणि कूटबद्धीकरण की बॅकअप घ्या. री-लॉग इन केल्यानंतर सर्व्हरवरून मेसेज रिस्टोअर केले जातील.';

  @override
  String get backupIncludeKeys => 'एनक्रिप्शन की समाविष्ट करा';

  @override
  String get backupIncludeKeysDesc => 'एनक्रिप्टेड संदेश वाचण्यासाठी आवश्यक';

  @override
  String get backupPasswordProtect => 'पासवर्ड संरक्षित करा';

  @override
  String get backupEnterPassword => 'बॅकअप पासवर्ड एंटर करा';

  @override
  String get backupHistory => 'बॅकअप इतिहास';

  @override
  String get backupNoBackups => 'अद्याप कोणतेही बॅकअप नाहीत';

  @override
  String get backupRestore2 => 'पुनर्संचयित करा';

  @override
  String get backupDelete => 'हटवा';

  @override
  String get backupDeleteConfirm =>
      'तुमची खात्री आहे की तुम्ही हा बॅकअप हटवू इच्छिता? हे पूर्ववत केले जाऊ शकत नाही.';

  @override
  String get backupRestoreFromFile => 'फाइलमधून पुनर्संचयित करा';

  @override
  String get backupRestoreFromFileDesc =>
      'दुसऱ्या डिव्हाइसवरून किंवा मागील बॅकअपवरून .n42 बॅकअप फाइल आयात करा.';

  @override
  String get backupChooseFile => 'बॅकअप फाइल निवडा';

  @override
  String get backupRestoring => 'पुनर्संचयित करत आहे...';

  @override
  String backupCreated(int rooms, int messages) {
    return 'बॅकअप तयार केला: $rooms खोल्या, $messages संदेश';
  }

  @override
  String backupRestored(int settings, int rooms) {
    return '$rooms खोल्यांमधून $settings सेटिंग्ज पुनर्संचयित केल्या';
  }

  @override
  String backupFailed(String error) {
    return 'बॅकअप अयशस्वी: $error';
  }

  @override
  String get backupPasswordRequired => 'हा बॅकअप पासवर्ड-संरक्षित आहे';

  @override
  String get blocGroupNotFound => 'गट सापडला नाही';

  @override
  String blocGroupMembersInvited(int count) {
    return 'आमंत्रित $count सदस्य(चे)';
  }

  @override
  String get blocGroupMemberRemoved => 'सदस्य काढून टाकले';

  @override
  String get blocGroupAdminRemoved => 'ॲडमिन काढला';

  @override
  String get blocGroupLeft => 'गट सोडला';

  @override
  String get blocGroupDisbanded => 'गट विसर्जित';

  @override
  String get blocGroupJoined => 'गटात सामील झाले';

  @override
  String get blocGroupInviteDeclined => 'आमंत्रण नाकारले';

  @override
  String get blocGroupTokenGateUpdated => 'टोकन गेट अपडेट केले';

  @override
  String get blocTransferProcessing => 'हस्तांतरणावर प्रक्रिया करत आहे...';

  @override
  String get blocTransferCancelled => 'हस्तांतरण रद्द केले';

  @override
  String get blocTransferFailed => 'हस्तांतरण अयशस्वी';

  @override
  String get blocPaymentProcessing => 'पेमेंटवर प्रक्रिया करत आहे...';

  @override
  String get blocPaymentFailed => 'पेमेंट अयशस्वी';

  @override
  String get groupMaxMembers => 'सदस्य मर्यादा';

  @override
  String get groupMaxMembersUnlimited => 'अमर्यादित';

  @override
  String get groupMaxMembersHint =>
      'मर्यादा प्रविष्ट करा (अमर्यादित साठी रिक्त सोडा)';

  @override
  String get groupMaxMembersUpdated => 'सदस्य मर्यादा अपडेट केली';

  @override
  String get groupFull => 'गट क्षमतेवर आहे';

  @override
  String get groupChannels => 'विषय चॅनेल';

  @override
  String get groupChannelsEmpty => 'अद्याप कोणतेही चॅनेल नाहीत';

  @override
  String get groupChannelsCount => 'चॅनेल';

  @override
  String get groupChannelCreate => 'नवीन चॅनल';

  @override
  String get groupChannelName => 'चॅनेलचे नाव';

  @override
  String get groupChannelTopic => 'चॅनल विषय (पर्यायी)';

  @override
  String get groupChannelDelete => 'चॅनल हटवा';

  @override
  String get groupChannelDeleteConfirm =>
      'हे चॅनल हटवायचे? सर्व संदेश गमावले जातील.';

  @override
  String get groupBotSettings => 'बॉट सेटिंग्ज';

  @override
  String get groupBotEnabled => 'बॉट सक्षम करा';

  @override
  String get groupBotWelcomeMessage => 'स्वागत संदेश टेम्पलेट';

  @override
  String get groupBotWelcomeHint =>
      'नवीन सदस्याच्या नावासाठी प्लेसहोल्डर म्हणून \'नाव\' वापरा';

  @override
  String get groupBotConfigUpdated => 'बॉट सेटिंग्ज अपडेट केल्या';

  @override
  String get groupContentFilter => 'सामग्री फिल्टर';

  @override
  String get groupContentFilterEnabled => 'कीवर्ड फिल्टर सक्षम करा';

  @override
  String get groupContentFilterReplace => '*** सह बदला';

  @override
  String get groupContentFilterHide => 'संदेश लपवा';

  @override
  String get groupContentFilterAddWord => 'कीवर्ड जोडा';

  @override
  String get groupContentFilterUpdated => 'सामग्री फिल्टर अद्यतनित केले';

  @override
  String get chatSlashCommands => 'आज्ञा';

  @override
  String get chatCommandPoll => '/poll — एक मतदान तयार करा';

  @override
  String get chatCommandAnnounce => '/घोषणा - घोषणा पाठवा';

  @override
  String get chatCommandWelcome => '/welcome — स्वागत संदेश सेट करा';

  @override
  String get chatReportMessage => 'अहवाल द्या';

  @override
  String get chatReportReason => 'कारण कळवा';

  @override
  String get chatReportSpam => 'स्पॅम';

  @override
  String get chatReportHarassment => 'छळ';

  @override
  String get chatReportInappropriate => 'अनुचित सामग्री';

  @override
  String get chatReportOther => 'इतर';

  @override
  String get chatReportSuccess => 'अहवाल सादर केला';

  @override
  String get spacesName => 'समुदायाचे नाव';

  @override
  String get spacesNameHint => 'उदा. क्रिप्टो व्यापारी';

  @override
  String get spacesNameRequired => 'नाव आवश्यक आहे';

  @override
  String get spacesDescription => 'वर्णन';

  @override
  String get spacesDescriptionHint => 'हा समुदाय कशाबद्दल आहे?';

  @override
  String get spacesType => 'समुदाय प्रकार';

  @override
  String get spacesPublicDesc => 'कोणीही शोधू शकतो आणि सामील होऊ शकतो';

  @override
  String get spacesPrivateDesc => 'केवळ आमंत्रित सदस्य सामील होऊ शकतात';

  @override
  String get spacesNotFound => 'समुदाय सापडला नाही';

  @override
  String get spacesSearch => 'समुदाय शोधा...';

  @override
  String get spacesMembers => 'सदस्य';

  @override
  String get spacesNoChannels => 'अद्याप कोणतेही चॅनेल नाहीत';

  @override
  String get spacesLeave => 'समुदाय सोडा';

  @override
  String spacesLeaveConfirm(String name) {
    return 'तुम्हाला खात्री आहे की तुम्ही \"$name\" सोडू इच्छिता?';
  }

  @override
  String get spacesDelete => 'समुदाय हटवा';

  @override
  String spacesDeleteConfirm(String name) {
    return 'हे \"$name\" आणि त्याचे सर्व चॅनेल कायमचे हटवेल. ही क्रिया पूर्ववत केली जाऊ शकत नाही.';
  }

  @override
  String get spacesCreateChannel => 'चॅनल जोडा';

  @override
  String get spacesChannelName => 'चॅनेलचे नाव';

  @override
  String get spacesChannelTopic => 'विषय (पर्यायी)';

  @override
  String get spacesDeleteChannel => 'चॅनल हटवा';

  @override
  String spacesDeleteChannelConfirm(String name) {
    return 'तुम्हाला खात्री आहे की तुम्ही \"#$name\" हटवू इच्छिता?';
  }

  @override
  String get spacesEditName => 'नाव संपादित करा';

  @override
  String get spacesEditDescription => 'वर्णन संपादित करा';

  @override
  String spacesViewAllMembers(int count) {
    return 'सर्व $count सदस्य पहा';
  }

  @override
  String spacesKickMemberTitle(String name) {
    return '$name ला किक करा';
  }

  @override
  String spacesBanMemberTitle(String name) {
    return '$name वर बंदी घाला';
  }

  @override
  String get spacesPromoteAdmin => 'Admin ला बढती द्या';

  @override
  String get spacesDemoteAdmin => 'प्रशासक काढा';

  @override
  String get spacesInviteMember => 'सदस्याला आमंत्रित करा';

  @override
  String get spacesInviteMemberUserId =>
      'वापरकर्ता आयडी (उदा. @user:server.com)';

  @override
  String get spacesSave => 'जतन करा';

  @override
  String get settingsScreenshotProtection => 'स्क्रीनशॉट संरक्षण';

  @override
  String get settingsScreenshotProtectionDesc =>
      'स्क्रीनशॉट आणि स्क्रीन रेकॉर्डिंग प्रतिबंधित करा';

  @override
  String get chatSelfDestructTimer => 'स्वत:चा नाश';

  @override
  String get chatTimerPickerTitle => 'सेल्फ-डिस्ट्रक्ट टाइमर';

  @override
  String get chatTimerOff => 'बंद';

  @override
  String get onChainNotificationsTitle => 'ऑन-चेन कार्यक्रम';

  @override
  String get onChainMarkAllRead => 'सर्व वाचलेले चिन्हांकित करा';

  @override
  String get onChainNoNotifications => 'अद्याप कोणतेही ऑन-चेन इव्हेंट नाहीत';

  @override
  String get onChainNoNotificationsDesc =>
      'सदस्यता घेतलेल्या चॅनेलवरील इव्हेंट्स येथे दिसतील';

  @override
  String get onChainViewDetails => 'तपशील पहा';

  @override
  String get chatCommandHelp => '/help — सर्व आज्ञा दाखवा';

  @override
  String get chatCommandPrice => '/किंमत — टोकन किंमत मिळवा';

  @override
  String get chatCommandBalance => '/balance — वॉलेट शिल्लक दाखवा';

  @override
  String get chatCommandChains => '/चेन्स — 236+ समर्थित साखळ्यांची यादी करा';

  @override
  String get chatMiniApps => 'ॲप्स';

  @override
  String get miniAppMarketTitle => 'मिनी ॲप्स';

  @override
  String get miniAppCategoryAll => 'सर्व';

  @override
  String get miniAppSearch => 'ॲप्स शोधा...';

  @override
  String get miniAppFeatured => 'वैशिष्ट्यीकृत';

  @override
  String get miniAppAllApps => 'सर्व ॲप्स';

  @override
  String get miniAppNoResults => 'कोणतेही ॲप्स आढळले नाहीत';

  @override
  String get slideToPayLabel => '→→→ पुष्टी करण्यासाठी स्लाइड करा';

  @override
  String get slideToPayConfirming => 'पुष्टी करत आहे...';

  @override
  String get redPacketBestLuck => 'शुभेच्छा';

  @override
  String get redPacketBestLuckCongrats => 'शुभेच्छा! तुम्हाला सर्वाधिक मिळाले!';

  @override
  String redPacketStats(int claimed, int total) {
    return '$claimed / $total दावा केला आहे';
  }

  @override
  String get redPacketStatsTotal => 'एकूण';

  @override
  String redPacketGrabbedViral(String amount, String token) {
    return '🧧 लाल पॅकेट पकडले • $amount $token';
  }

  @override
  String get web3SearchHint => '@matrix:id • 0x वॉलेट पत्ता • name.eth';

  @override
  String get web3SearchPlaceholder => 'आयडी, वॉलेट किंवा ईएनएस द्वारे शोधा...';

  @override
  String get web3WalletAddress => 'वॉलेट पत्ता';

  @override
  String get web3AddressCopied => 'पत्ता कॉपी केला';

  @override
  String get web3Copy => 'कॉपी करा';

  @override
  String get web3SendMessage => 'संदेश पाठवा';

  @override
  String get web3SendToWallet => 'संदेश वॉलेट';

  @override
  String get web3WalletOnlyHint =>
      'या पत्त्यावर अद्याप कोणतेही N42 खाते नाही. ते सामील झाल्यावर संदेश दिला जाईल.';

  @override
  String get web3NftAvatar => 'NFT अवतार';

  @override
  String get web3ResolveFailed => 'ओळख निराकरण करण्यात अयशस्वी';

  @override
  String web3EnsNotFound(String name) {
    return 'ENS नाव \"$name\" आढळले नाही';
  }

  @override
  String get web3NoN42AccountTitle => 'N42 खाते नाही';

  @override
  String get web3NoN42AccountDesc =>
      'या वॉलेट पत्त्यावर अद्याप कोणतेही N42 खाते नाही. सुरुवात करण्यासाठी तुम्ही तुमची N42 आमंत्रण लिंक त्यांच्यासोबत शेअर करू शकता.';

  @override
  String get web3ShareInvite => 'आमंत्रण सामायिक करा';

  @override
  String get nftPickerTitle => 'NFT अवतार निवडा';

  @override
  String get nftPickerTabPopular => 'लोकप्रिय';

  @override
  String get nftPickerTabCustom => 'सानुकूल';

  @override
  String get nftPickerChain => 'साखळी';

  @override
  String get nftPickerContract => 'कराराचा पत्ता';

  @override
  String get nftPickerTokenId => 'टोकन आयडी';

  @override
  String get nftPickerVerifyOwnership =>
      'मालकी सत्यापित करा आणि पूर्वावलोकन करा';

  @override
  String get nftPickerUseAsAvatar => 'अवतार म्हणून वापरा';

  @override
  String get nftPickerPreview => 'पूर्वावलोकन';

  @override
  String get nftPickerNotOwned => 'तुम्ही या NFT च्या मालकीचे नाही';

  @override
  String get nftPickerInvalidTokenId => 'अवैध टोकन आयडी';

  @override
  String get nftPickerEnterBoth => 'करार पत्ता आणि टोकन आयडी प्रविष्ट करा';

  @override
  String get nftPickerInfoTitle => 'NFT अवतार — सत्यापित ऑन-चेन';

  @override
  String get nftPickerInfoDesc =>
      'तुमचा अवतार म्हणून तुमच्या मालकीचा NFT बांधा. कोणीही ऑन-चेन मालकीची पडताळणी करू शकतो. N42 वर सोन्याच्या अंगठीसह प्रदर्शित.';

  @override
  String get nftPickerPopularCollections => 'लोकप्रिय संग्रह';

  @override
  String get nftPickerWalletHint =>
      '236+ चेनमध्ये तुमचे NFT स्वयंचलितपणे शोधण्यासाठी तुमचे N42 वॉलेट कनेक्ट करा.';

  @override
  String get profileBindNftAvatar => 'NFT अवतार बांधा';

  @override
  String get profileChangeAvatar => 'अवतार बदला';

  @override
  String get groupTopics => 'विषय';

  @override
  String get groupTopicsEmpty => 'अद्याप कोणतेही विषय नाहीत';

  @override
  String get syncInProgress => 'संदेश इतिहास समक्रमित करत आहे...';

  @override
  String get recoveryKeyReminderTitle => 'तुमचे संदेश सुरक्षित करा';

  @override
  String get recoveryKeyReminderDesc =>
      'सर्व डिव्हाइसेसवर कूटबद्ध संदेश सुरक्षितपणे समक्रमित करण्यासाठी पुनर्प्राप्ती की तयार करा';

  @override
  String get recoveryKeySetupNow => 'आता सेट करा';

  @override
  String get recoveryKeyRemindLater => 'मला नंतर आठवण करून द्या';

  @override
  String get channelReadOnly => 'या चॅनेलवर फक्त प्रशासक पोस्ट करू शकतात';

  @override
  String get channelSubscribers => 'सदस्य';

  @override
  String get channelVerified => 'सत्यापित चॅनेल';

  @override
  String get redPacketHistory => 'लाल पॅकेट इतिहास';

  @override
  String get redPacketSent => 'पाठवले';

  @override
  String get redPacketReceived => 'प्राप्त झाले';

  @override
  String get redPacketExpired => 'कालबाह्य';

  @override
  String get redPacketClaimed => 'दावा केला';

  @override
  String get redPacketInsufficientBalance => 'अपुरा शिल्लक';

  @override
  String selfDestructCountdown(String time) {
    return '$time मध्ये आत्म-नाश';
  }

  @override
  String get messageDestroyed => 'संदेश नष्ट केला';

  @override
  String miniAppPermissionDenied(String permission) {
    return 'परवानगी नाकारली: $permission';
  }

  @override
  String get aiSuggestionGasFee => 'गॅस फी म्हणजे काय?';

  @override
  String get aiSuggestionDefi => 'DeFi नवशिक्या मार्गदर्शक';

  @override
  String get aiSuggestionSecurity => 'कराराची सुरक्षा कशी तपासायची';

  @override
  String get aiSuggestionBridge => 'क्रॉस-चेन ब्रिजिंग';

  @override
  String get channelDiscoverTitle => 'चॅनेल शोधा';

  @override
  String get channelDiscoverSearch => 'चॅनेल शोधा...';

  @override
  String get channelJoin => 'सामील व्हा';

  @override
  String get channelJoined => 'सामील झाले';

  @override
  String get channelCategory => 'श्रेणी';

  @override
  String slowModeCooldown(int seconds) {
    return 'स्लो मोड: ${seconds}s प्रतीक्षा करा';
  }

  @override
  String get addressCopyAction => 'पत्ता कॉपी करा';

  @override
  String get addressSendMessage => 'संदेश पाठवा';

  @override
  String get addressViewProfile => 'प्रोफाइल पहा';

  @override
  String get sendToAddress => 'वॉलेट पत्त्यावर पाठवा';

  @override
  String get blocAuthSendVerificationCodeFailed =>
      'पडताळणी कोड पाठवण्यात अयशस्वी';

  @override
  String get blocAuthServerNoEmailPasswordReset =>
      'हा सर्व्हर ईमेल पासवर्ड रीसेट करण्यास समर्थन देत नाही';

  @override
  String get blocAuthResetPasswordFailed => 'पासवर्ड रीसेट करण्यात अयशस्वी';

  @override
  String get blocAuthChangePasswordFailed => 'पासवर्ड बदलण्यात अयशस्वी';

  @override
  String get blocAuthOldPasswordWrong => 'चुकीचा वर्तमान पासवर्ड';

  @override
  String get blocAuthLoginCancelled => 'लॉगिन रद्द केले';

  @override
  String get blocAuthGoogleLoginFailed => 'Google लॉगिन अयशस्वी';

  @override
  String get blocAuthAppleLoginFailed => 'ऍपल लॉगिन अयशस्वी';

  @override
  String get blocAuthSsoLoginFailed => 'SSO लॉगिन अयशस्वी';

  @override
  String get blocAuthFacebookLoginFailed => 'फेसबुक लॉगिन अयशस्वी';

  @override
  String get blocAuthTwitterLoginFailed => 'Twitter लॉगिन अयशस्वी';

  @override
  String get blocAuthWeChatLoginFailed => 'WeChat लॉगिन अयशस्वी';

  @override
  String get blocAuthWeChatNotConfigured => 'WeChat लॉगिन कॉन्फिगर केलेले नाही';

  @override
  String get blocAuthWeChatNotInstalled => 'कृपया प्रथम WeChat इंस्टॉल करा';

  @override
  String get blocAuthPasswordWrong => 'चुकीचा पासवर्ड';

  @override
  String get blocAuthEmailAlreadyBound =>
      'हा ईमेल आधीपासूनच दुसऱ्या खात्याशी बांधील आहे';

  @override
  String get blocAuthChangeEmailFailed => 'ईमेल बदलण्यात अयशस्वी';

  @override
  String get blocAuthVerificationCodeInvalid =>
      'सत्यापन कोड चुकीचा आहे किंवा कालबाह्य झाला आहे';

  @override
  String get blocAuthSessionExpired =>
      'सत्र कालबाह्य झाले, कृपया पुन्हा लॉग इन करा';

  @override
  String get blocAuthSessionIncomplete =>
      'सत्र डेटा अपूर्ण आहे, कृपया पुन्हा लॉग इन करा';
}
