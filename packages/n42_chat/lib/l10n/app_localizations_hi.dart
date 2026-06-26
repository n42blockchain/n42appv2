// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class SHi extends S {
  SHi([String locale = 'hi']) : super(locale);

  @override
  String get commonRetry => 'पुनः प्रयास करें';

  @override
  String get commonUnknownUser => 'अज्ञात उपयोगकर्ता';

  @override
  String get transferWalletNotConnected => 'वॉलेट कनेक्ट नहीं है';

  @override
  String get chatCallServiceNotInitialized => 'कॉल सेवा प्रारंभ नहीं की गई';

  @override
  String authLoginFailed(String error) {
    return 'लॉगिन विफल: $error';
  }

  @override
  String get chatCallBack => 'वापस कॉल करें';

  @override
  String get chatMissedVideoCall => 'वीडियो कॉल छूट गई';

  @override
  String get chatMissedVoiceCall => 'मिस्ड वॉयस कॉल';

  @override
  String get chatCallNotAnswered => 'उत्तर नहीं दिया गया';

  @override
  String get chatCallDurationLabel => 'कॉल अवधि';

  @override
  String get chatVoiceCallCancelled => 'वॉइस कॉल रद्द कर दी गई';

  @override
  String get chatVideoCallCancelled => 'वीडियो कॉल रद्द कर दी गई';

  @override
  String get commonImage => '[छवि]';

  @override
  String get chatVideo => '[वीडियो]';

  @override
  String get chatVoice => '[आवाज़]';

  @override
  String get commonFile => '[फ़ाइल]';

  @override
  String get chatLocation => '[स्थान]';

  @override
  String get chatUnknownMessage => '[अज्ञात संदेश]';

  @override
  String get commonDelete => 'हटाएँ';

  @override
  String get chatDeleteThisMessage => 'यह संदेश हटाएं?';

  @override
  String get chatMessageDeleted => 'संदेश हटा दिया गया';

  @override
  String get profileNotLoggedIn => 'लॉग इन नहीं है';

  @override
  String get chatMyLocation => 'मेरा स्थान';

  @override
  String get commonGroupChat => 'समूह चैट';

  @override
  String get commonSearch => 'खोजें';

  @override
  String get commonCancel => 'रद्द करें';

  @override
  String get commonLoadFailed => 'लोड करने में विफल';

  @override
  String get commonMessages => 'संदेश';

  @override
  String get commonContacts => 'संपर्क';

  @override
  String get commonMe => 'मैं';

  @override
  String get commonVoiceLoading =>
      'ध्वनि लोड हो रही है, कृपया बाद में पुनः प्रयास करें';

  @override
  String get commonVoiceToTextFailed => 'वॉयस टू टेक्स्ट विफल रहा';

  @override
  String get commonConvertToText => 'पाठ करने के लिए';

  @override
  String get chatCopy => 'प्रतिलिपि';

  @override
  String get commonForward => 'आगे';

  @override
  String get commonUnfavorite => 'अनफेव';

  @override
  String get commonFavorite => 'पसंदीदा';

  @override
  String get settingsResend => 'पुनः भेजें';

  @override
  String get chatRecall => 'स्मरण करो';

  @override
  String get commonQuote => 'उद्धरण';

  @override
  String get commonRemind => 'याद दिलाना';

  @override
  String get chatCopied => 'नकल की गई';

  @override
  String get storySendMessageHint => 'एक संदेश भेजें';

  @override
  String get commonMicrophonePermissionRequired =>
      'कृपया माइक्रोफ़ोन की अनुमति दें';

  @override
  String get chatMicrophonePermissionDeniedPermanent =>
      'माइक्रोफ़ोन की अनुमति अस्वीकार कर दी गई है. ध्वनि संदेशों का उपयोग करने के लिए कृपया इसे सिस्टम सेटिंग्स में सक्षम करें।';

  @override
  String commonStartRecordingFailed(String error) {
    return 'रिकॉर्डिंग प्रारंभ करने में विफल: $error';
  }

  @override
  String get commonRecordingTooShort => 'रिकॉर्डिंग बहुत छोटी है';

  @override
  String commonStopRecordingFailed(String error) {
    return 'रिकॉर्डिंग रोकने में विफल: $error';
  }

  @override
  String get chatReleaseToCancel => 'रद्द करने के लिए जारी करें';

  @override
  String get chatReleaseToSend =>
      'भेजने के लिए रिलीज़ करें, रद्द करने के लिए ऊपर की ओर स्वाइप करें';

  @override
  String get commonHoldToTalk => 'बात करने के लिए रुकें';

  @override
  String get commonSend => 'भेजें';

  @override
  String get commonAddFriend => 'मित्र जोड़ें';

  @override
  String get commonChatServiceNotConnected => 'चैट सेवा कनेक्ट नहीं है';

  @override
  String contactUserNotFoundHint(String query) {
    return 'उपयोगकर्ता \"$query\" नहीं मिला\n\nयुक्तियाँ:\n• पूर्ण उपयोगकर्ता आईडी दर्ज करने का प्रयास करें, उदा. @username:server.com\n• उपयोगकर्ता नाम की वर्तनी जांचें';
  }

  @override
  String contactCreateChatFailed(String error) {
    return 'चैट बनाने में विफल: $error';
  }

  @override
  String contactSearchFailed(String error) {
    return 'खोज विफल: $error';
  }

  @override
  String get contactEnterUserIdOrUsername =>
      'खोजने के लिए उपयोगकर्ता आईडी या उपयोगकर्ता नाम दर्ज करें';

  @override
  String get contactSearching => 'खोज रहे हैं...';

  @override
  String get contactSearchUserToChat =>
      'चैटिंग शुरू करने के लिए उपयोगकर्ता खोजें';

  @override
  String get contactMatrixIdExample =>
      'आप पूर्ण मैट्रिक्स आईडी दर्ज कर सकते हैं\nजैसे @user:matrix.n42.network';

  @override
  String contactUserNotFound(String username) {
    return 'उपयोगकर्ता \"$username\" नहीं मिला';
  }

  @override
  String get commonChat => 'बातचीत';

  @override
  String get commonSettings => 'सेटिंग्स';

  @override
  String get profileEditProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get authLogin => 'लॉग इन करें';

  @override
  String get commonCreateGroup => 'समूह बनाएं';

  @override
  String get chatError => 'त्रुटि';

  @override
  String get commonTransfer => 'स्थानांतरण';

  @override
  String get commonReceived => 'प्राप्त हुआ';

  @override
  String get commonRefunded => 'वापस कर दिया गया';

  @override
  String get commonExpired => 'समाप्त हो गया';

  @override
  String get chatRedPacketGreeting => 'शुभकामनाएँ';

  @override
  String get commonN42RedPacket => 'N42 लाल पैकेट';

  @override
  String get commonClaimed => 'दावा किया';

  @override
  String get commonAllClaimed => 'सभी ने दावा किया';

  @override
  String get chatReadAloud => 'ज़ोर से पढ़ें';

  @override
  String get chatReply => 'उत्तर';

  @override
  String get commonEdit => 'संपादित करें';

  @override
  String get chatSelectForwardTarget => 'अग्रेषित लक्ष्य का चयन करें';

  @override
  String commonSendCount(int count) {
    return 'भेजें($count)';
  }

  @override
  String contactN42Id(String id) {
    return 'N42 आईडी: $id';
  }

  @override
  String get profileN42IdTitle => 'एन42 आईडी';

  @override
  String get profileN42Bean => 'N42 बीन';

  @override
  String get contactFriendInfo => 'मित्र जानकारी';

  @override
  String get contactFriendInfoDesc =>
      'मित्र की टिप्पणी, फ़ोन, टैग, नोट्स, फ़ोटो जोड़ें और अनुमतियाँ सेट करें।';

  @override
  String get commonMoments => 'क्षण';

  @override
  String get commonSendMessage => 'संदेश';

  @override
  String get contactAudioVideoCall => 'ऑडियो/वीडियो कॉल';

  @override
  String get contactVideoChannel => 'वीडियो चैनल';

  @override
  String get contactRemark => 'टिप्पणी';

  @override
  String get contactRemarkName => 'टिप्पणी नाम';

  @override
  String get contactPhone => 'फ़ोन';

  @override
  String get contactTags => 'टैग';

  @override
  String get contactNotes => 'टिप्पणियाँ';

  @override
  String get contactPhotos => 'तस्वीरें';

  @override
  String get contactPermissions => 'अनुमतियाँ';

  @override
  String get contactChatMomentsEtc => 'चैट, क्षण, खेल आदि।';

  @override
  String get contactMoreInfo => 'अधिक जानकारी';

  @override
  String get contactCommonGroups => 'समान समूह';

  @override
  String get contactSource => 'स्रोत';

  @override
  String get settingsNotificationSettings => 'सूचनाएं';

  @override
  String get settingsPrivacy => 'गोपनीयता';

  @override
  String get settingsAppearance => 'दिखावट';

  @override
  String get settingsAbout => 'के बारे में';

  @override
  String get commonLogout => 'लॉग आउट करें';

  @override
  String get commonLogoutConfirm => 'क्या आप वाकई लॉग आउट करना चाहते हैं?';

  @override
  String get commonSave => 'सहेजें';

  @override
  String get profileNickname => 'उपनाम';

  @override
  String get profileEnterNickname => 'उपनाम दर्ज करें';

  @override
  String get profileSignature => 'हस्ताक्षर';

  @override
  String get profileAddSignature => 'एक हस्ताक्षर जोड़ें';

  @override
  String get commonTakePhoto => 'फ़ोटो लें';

  @override
  String get profileChooseFromGallery => 'गैलरी से चुनें';

  @override
  String profileSaveFailed(String error) {
    return 'सहेजना विफल: $error';
  }

  @override
  String get authSecureDecentralizedChat =>
      'सुरक्षित, विकेन्द्रीकृत संदेश सेवा';

  @override
  String get commonEndToEndEncryption => 'एंड-टू-एंड एन्क्रिप्शन';

  @override
  String get authMessagesOnlyYouCanSee =>
      'संदेश केवल आपको और प्राप्तकर्ता को दिखाई देते हैं';

  @override
  String get authDecentralized => 'विकेन्द्रीकृत';

  @override
  String get authBasedOnMatrix => 'मैट्रिक्स ओपन प्रोटोकॉल पर निर्मित';

  @override
  String get authWalletIntegration => 'वॉलेट एकीकरण';

  @override
  String get authEasyCryptoTransfer => 'आसान क्रिप्टोकरेंसी ट्रांसफर';

  @override
  String get authRegister => 'साइन अप करें';

  @override
  String get authAgreeTerms => 'लॉग इन करके, आप सहमत हैं';

  @override
  String get authTermsOfService => 'सेवा की शर्तें';

  @override
  String get authAnd => ' और ';

  @override
  String get authPrivacyPolicy => 'गोपनीयता नीति';

  @override
  String get authServerAddress => 'सर्वर पता';

  @override
  String get authEnterServerAddress => 'सर्वर पता दर्ज करें';

  @override
  String authConnectedTo(String serverName) {
    return '$serverName से जुड़ा';
  }

  @override
  String get authUsername => 'उपयोगकर्ता नाम';

  @override
  String get authEnterUsername => 'उपयोक्तानाम दर्ज करें';

  @override
  String get authUsernameOrEmail => 'उपयोगकर्ता नाम या ईमेल';

  @override
  String get authEnterUsernameOrEmail => 'उपयोगकर्ता नाम या ईमेल दर्ज करें';

  @override
  String get authPassword => 'पासवर्ड';

  @override
  String get authEnterPassword => 'पासवर्ड दर्ज करें';

  @override
  String get authRegisterAccount => 'साइन अप करें';

  @override
  String get authForgotPassword => 'पासवर्ड भूल गए';

  @override
  String get authOtherLoginMethods => 'अन्य लॉगिन विधियाँ';

  @override
  String get authCreateAccount => 'खाता बनाएँ';

  @override
  String get authJoinN42Chat => 'चैटिंग शुरू करने के लिए N42 चैट से जुड़ें';

  @override
  String get authUsernameHint => '3-20 वर्ण, अक्षर/संख्या/_';

  @override
  String get authUsernameMinLength =>
      'उपयोगकर्ता नाम कम से कम 3 अक्षर का होना चाहिए';

  @override
  String get authUsernameMaxLength =>
      'उपयोगकर्ता नाम अधिकतम 20 अक्षर का होना चाहिए';

  @override
  String get authUsernameFormat =>
      'उपयोगकर्ता नाम में केवल अक्षर, संख्याएँ और अंडरस्कोर हो सकते हैं';

  @override
  String get authPasswordHint => 'न्यूनतम 8 अक्षर';

  @override
  String get commonPasswordMinLength =>
      'पासवर्ड कम से कम 8 अक्षर का होना चाहिए';

  @override
  String get authConfirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get authFilled => 'भरा हुआ';

  @override
  String get authEnterInviteCode => 'आमंत्रण कोड दर्ज करें';

  @override
  String get authAlreadyHaveAccount => 'क्या आपके पास पहले से ही एक खाता है?';

  @override
  String get authLoginNow => 'अभी लॉग इन करें';

  @override
  String get profileAvatar => 'अवतार';

  @override
  String get profileStatus => 'स्थिति';

  @override
  String get commonLoading => 'लोड हो रहा है...';

  @override
  String get conversationNoConversations => 'कोई बातचीत नहीं';

  @override
  String get conversationTapToChat =>
      'चैटिंग शुरू करने के लिए ऊपर दाईं ओर टैप करें';

  @override
  String get conversationStartGroup => 'समूह चैट प्रारंभ करें';

  @override
  String get commonScan => 'स्कैन करें';

  @override
  String get commonPayment => 'भुगतान';

  @override
  String commonFeatureComingSoon(String feature) {
    return '$feature जल्द ही आ रहा है';
  }

  @override
  String get conversationMarkAsRead => 'पढ़ा गया के रूप में चिह्नित करें';

  @override
  String get commonUnmute => 'अनम्यूट करें';

  @override
  String get commonMute => 'मूक';

  @override
  String get conversationUnpin => 'अनपिन करें';

  @override
  String get conversationPin => 'पिन';

  @override
  String get conversationDeleteConversation => 'वार्तालाप हटाएँ';

  @override
  String conversationDeleteConversationConfirm(String name) {
    return '\"$name\" से वार्तालाप हटाएं?';
  }

  @override
  String get commonNoContacts => 'कोई संपर्क नहीं';

  @override
  String get contactAddFriendsToChat =>
      'चैटिंग शुरू करने के लिए मित्रों को जोड़ें';

  @override
  String get contactNotFound => 'संपर्क नहीं मिला';

  @override
  String get contactTryOtherKeywords => 'अन्य कीवर्ड या वैश्विक खोज आज़माएँ';

  @override
  String get contactSearchResults => 'खोज परिणाम';

  @override
  String get contactNewFriends => 'नए दोस्त';

  @override
  String get contactChatOnlyFriends => 'केवल चैट मित्र';

  @override
  String get contactOfficialAccounts => 'आधिकारिक खाते';

  @override
  String get contactServiceAccounts => 'सेवा खाते';

  @override
  String get contactEnterpriseContacts => 'उद्यम संपर्क';

  @override
  String get contactRecommendToFriend => 'संपर्क साझा करें';

  @override
  String get commonSetRemark => 'टिप्पणी सेट करें';

  @override
  String get contactSendingCard => 'संपर्क कार्ड भेजा जा रहा है...';

  @override
  String get commonFileLabel => 'फ़ाइल';

  @override
  String get commonLocationLabel => 'स्थान';

  @override
  String contactRecommendFailed(String error) {
    return 'अनुशंसा विफल: $error';
  }

  @override
  String get profileEnterRemark => 'टिप्पणी दर्ज करें';

  @override
  String get contactOpeningChat => 'चैट खुल रही है...';

  @override
  String contactOpenChatFailed(String error) {
    return 'चैट खोलने में विफल: $error';
  }

  @override
  String get contactAddContact => 'संपर्क जोड़ें';

  @override
  String get contactEnterUserId => 'उपयोगकर्ता आईडी दर्ज करें';

  @override
  String get contactNoFriendRequests => 'कोई मित्र अनुरोध नहीं';

  @override
  String get commonAccept => 'स्वीकार करो';

  @override
  String get commonReject => 'अस्वीकार करें';

  @override
  String get commonNoGroups => 'कोई समूह नहीं';

  @override
  String get contactSelectFriendToRecommend =>
      'अनुशंसा करने के लिए किसी मित्र का चयन करें';

  @override
  String get commonSearchContacts => 'संपर्क खोजें';

  @override
  String get contactNoContactsFound => 'कोई संपर्क नहीं मिला';

  @override
  String get favoriteYesterday => 'कल';

  @override
  String get chatJustNow => 'अभी अभी';

  @override
  String get profileOnline => 'ऑनलाइन';

  @override
  String get profileOffline => 'ऑफ़लाइन';

  @override
  String get searchContactsGroupsMessages => 'संपर्क, समूह और संदेश खोजें';

  @override
  String get searchError => 'खोज त्रुटि';

  @override
  String get chatSearchHint => 'खोजें';

  @override
  String get searchHistory => 'खोज इतिहास';

  @override
  String get commonClear => 'स्पष्ट';

  @override
  String get commonAll => 'सब';

  @override
  String get searchGroups => 'समूह';

  @override
  String get searchNoResults => 'कोई परिणाम नहीं';

  @override
  String commonGroupMembers(int count) {
    return 'सदस्य ($count)';
  }

  @override
  String get groupMembersTitle => 'समूह के सदस्य';

  @override
  String get groupViewAll => 'सभी देखें';

  @override
  String get groupOwner => 'मालिक';

  @override
  String get groupAdmin => 'व्यवस्थापक';

  @override
  String get groupInvite => 'आमंत्रित करें';

  @override
  String get commonGroupAnnouncement => 'समूह घोषणा';

  @override
  String get commonNotSet => 'सेट नहीं';

  @override
  String get groupDescription => 'समूह विवरण';

  @override
  String get groupPublicGroup => 'सार्वजनिक समूह';

  @override
  String get commonClearChatHistory => 'चैट इतिहास साफ़ करें';

  @override
  String get commonDissolveGroup => 'समूह को विघटित करें';

  @override
  String get commonLeaveGroup => 'समूह छोड़ें';

  @override
  String get groupChangeGroupName => 'समूह का नाम बदलें';

  @override
  String get commonEnterGroupName => 'समूह का नाम दर्ज करें';

  @override
  String get commonConfirm => 'पुष्टि करें';

  @override
  String get groupEnterGroupDescription => 'समूह विवरण दर्ज करें';

  @override
  String get groupPublish => 'प्रकाशित करें';

  @override
  String get chatClearHistoryConfirm =>
      'संपूर्ण चैट इतिहास साफ़ करें? इसे असंपादित नहीं किया जा सकता है।';

  @override
  String get chatClearAction => 'स्पष्ट';

  @override
  String get commonChatHistoryCleared => 'चैट इतिहास साफ़ किया गया';

  @override
  String get commonDissolve => 'घोलना';

  @override
  String get groupQrCode => 'समूह क्यूआर कोड';

  @override
  String get commonSearchChatHistory => 'चैट इतिहास खोजें';

  @override
  String get groupIdCopied => 'ग्रुप आईडी कॉपी की गई';

  @override
  String get transferEnterOrPasteAddress => 'वॉलेट पता दर्ज करें या पेस्ट करें';

  @override
  String get transferSelectToken => 'टोकन चुनें';

  @override
  String get commonTransferAmount => 'स्थानांतरण राशि';

  @override
  String get transferAvailable => 'उपलब्ध';

  @override
  String get transferMemoOptional => 'मेमो (वैकल्पिक)';

  @override
  String get transferConfirmTransfer => 'स्थानांतरण की पुष्टि करें';

  @override
  String get transferAddressVerified => 'पता सत्यापित';

  @override
  String transferAvailableBalance(String balance, String symbol) {
    return 'उपलब्ध: $balance $symbol';
  }

  @override
  String get commonEnterAmount => 'राशि दर्ज करें';

  @override
  String get commonRedPacketCountMin => 'कम से कम 1 लाल पैकेट आवश्यक है';

  @override
  String get commonViewRedPacketDetails => 'लाल पैकेट विवरण देखें';

  @override
  String get commonEnterTransferAmount => 'कृपया स्थानांतरण राशि दर्ज करें';

  @override
  String get commonTransferTo => 'में स्थानांतरित करें';

  @override
  String commonFromSender(String name, Object senderName) {
    return '$name से';
  }

  @override
  String get commonConfirmReceive => 'प्राप्ति की पुष्टि करें';

  @override
  String get groupProfile => 'समूह जानकारी';

  @override
  String get groupRemoveMember => 'समूह से हटाएँ';

  @override
  String get commonRemove => 'हटाओ';

  @override
  String get profileClearStatus => 'स्पष्ट स्थिति';

  @override
  String get profileClearStatusConfirm => 'वर्तमान स्थिति साफ़ करें?';

  @override
  String get profileStatusCleared => 'स्थिति साफ़ हो गई';

  @override
  String get profileUserNotExist => 'उपयोगकर्ता मौजूद नहीं है';

  @override
  String get profileUserIdCopied => 'उपयोगकर्ता आईडी की प्रतिलिपि बनाई गई';

  @override
  String get commonReport => 'रिपोर्ट करें';

  @override
  String get profileQrCode => 'क्यूआर कोड';

  @override
  String get profileAvatarUpdated => 'अवतार अपडेट किया गया';

  @override
  String commonSelectImageFailed(String error) {
    return 'छवि का चयन करने में विफल: $error';
  }

  @override
  String get profileChangeName => 'नाम बदलें';

  @override
  String get profileMale => 'पुरुष';

  @override
  String get profileFemale => 'स्त्री';

  @override
  String chatFeatureInDev(String feature) {
    return '$feature सुविधा विकास में है...';
  }

  @override
  String profileSaveAddressFailed(String error) {
    return 'पता सहेजने में विफल: $error';
  }

  @override
  String get profileAddNew => 'जोड़ें';

  @override
  String get profileAddAddress => 'पता जोड़ें';

  @override
  String get profileAddressAdded => 'पता जोड़ा गया';

  @override
  String get profileAddressUpdated => 'पता अपडेट किया गया';

  @override
  String get profileDeleteAddress => 'पता हटाएँ';

  @override
  String get profileAddressDeleted => 'पता हटा दिया गया';

  @override
  String profileSaveInvoiceFailed(String error) {
    return 'चालान सहेजने में विफल: $error';
  }

  @override
  String get profileMyInvoices => 'मेरे चालान';

  @override
  String get profileAddInvoice => 'चालान जोड़ें';

  @override
  String get profileInvoiceAdded => 'चालान जोड़ा गया';

  @override
  String get profileInvoiceUpdated => 'चालान अद्यतन किया गया';

  @override
  String get profileDeleteInvoice => 'चालान हटाएँ';

  @override
  String get profileInvoiceDeleted => 'चालान हटा दिया गया';

  @override
  String get profilePersonal => 'निजी';

  @override
  String get groupSelectAtLeastOne => 'कृपया कम से कम एक सदस्य का चयन करें';

  @override
  String get chatFileNotExist => 'फ़ाइल मौजूद नहीं है';

  @override
  String chatSendFailed(String error) {
    return 'भेजना विफल: $error';
  }

  @override
  String get chatCannotOpenBrowser => 'ब्राउज़र नहीं खुल सकता';

  @override
  String chatSelectFileFailed(String error) {
    return 'फ़ाइल का चयन करने में विफल: $error';
  }

  @override
  String settingsSetupFailed(String error) {
    return 'सेटअप विफल: $error';
  }

  @override
  String get transferEnterValidAmount => 'कृपया एक वैध राशि दर्ज करें';

  @override
  String get commonAddressCopied => 'पता कॉपी किया गया';

  @override
  String favoriteOpenItem(String content) {
    return 'खुला: $content';
  }

  @override
  String get favoriteDeleted => 'हटा दिया गया';

  @override
  String get profileWallet => 'बटुआ';

  @override
  String get chatRecording => 'रिकॉर्डिंग';

  @override
  String get chatInvalidVideoUrl => 'अमान्य वीडियो यूआरएल';

  @override
  String get chatDownloadFile => 'फ़ाइल डाउनलोड करें';

  @override
  String get chatClearChatHistoryTitle => 'चैट इतिहास साफ़ करें';

  @override
  String get chatVideoCall => 'वीडियो कॉल';

  @override
  String get commonVoiceCall => 'वॉयस कॉल';

  @override
  String get callLeaveMeeting => 'मीटिंग छोड़ें';

  @override
  String get chatDetails => 'चैट विवरण';

  @override
  String get chatViewAllGroupMembers => 'सभी सदस्यों को देखें';

  @override
  String get chatGroupName => 'समूह का नाम';

  @override
  String get chatGroupNameUpdated => 'समूह का नाम अपडेट किया गया';

  @override
  String get chatUpdateFailed => 'अद्यतन विफल रहा';

  @override
  String get chatNoPermissionToModify => 'आपको संशोधित करने की अनुमति नहीं है';

  @override
  String get chatGroupManagement => 'समूह प्रबंधन';

  @override
  String get chatMyNicknameInGroup => 'समूह में मेरा उपनाम';

  @override
  String get chatPinChat => 'चैट पिन करें';

  @override
  String get chatStrongReminder => 'सशक्त अनुस्मारक';

  @override
  String get chatSetChatBackground => 'चैट पृष्ठभूमि सेट करें';

  @override
  String get chatUnknownFile => 'अज्ञात फ़ाइल';

  @override
  String get chatDownload => 'डाउनलोड करें';

  @override
  String get chatInvalidLocation => 'अमान्य स्थान';

  @override
  String get chatTapToCancel => 'रद्द करने के लिए टैप करें';

  @override
  String chatCaptureFailed(Object error) {
    return 'कैप्चर विफल: $error';
  }

  @override
  String get chatProcessingVideo => 'वीडियो संसाधित हो रहा है...';

  @override
  String get chatVideoFileNotExist => 'वीडियो फ़ाइल मौजूद नहीं है';

  @override
  String get chatVideoDataEmpty => 'वीडियो डेटा खाली है';

  @override
  String get chatVideoTooLarge =>
      'वीडियो का आकार 100 एमबी से अधिक नहीं हो सकता';

  @override
  String get chatSendingVideo => 'वीडियो भेजा जा रहा है...';

  @override
  String chatSendVideoFailed(Object error) {
    return 'वीडियो भेजने में विफल: $error';
  }

  @override
  String get chatImageFileNotExist => 'छवि फ़ाइल मौजूद नहीं है';

  @override
  String get commonImageDataEmpty => 'छवि डेटा खाली है';

  @override
  String get chatSendingImage => 'छवि भेजी जा रही है...';

  @override
  String chatSendImageFailed(Object error) {
    return 'छवि भेजने में विफल: $error';
  }

  @override
  String get chatSendLocation => 'स्थान भेजें';

  @override
  String get chatSelectLocationAndSend => 'स्थान चुनें और भेजें';

  @override
  String get chatShareRealTimeLocation => 'वास्तविक समय स्थान साझा करें';

  @override
  String get chatShareLocationForOneHour =>
      '1 घंटे के लिए मित्र के साथ वास्तविक समय का स्थान साझा करें';

  @override
  String get chatLocationSent => 'स्थान भेजा गया';

  @override
  String get chatSelectMessages => 'संदेश चुनें';

  @override
  String chatSelectedCount(int count) {
    return 'चयनित $count';
  }

  @override
  String get chatSelectAll => 'सभी का चयन करें';

  @override
  String chatGroupChatCount(int count) {
    return 'समूह चैट($count)';
  }

  @override
  String get chatPrivateChat => 'निजी चैट';

  @override
  String get chatNoMessages => 'कोई संदेश नहीं';

  @override
  String get chatSendFirstMessage => 'चैटिंग शुरू करने के लिए पहला संदेश भेजें';

  @override
  String get chatEncryptionNotice =>
      'यह चैट एंड-टू-एंड एन्क्रिप्टेड है. केवल आप और प्राप्तकर्ता ही संदेशों को पढ़ सकते हैं।';

  @override
  String get chatMultiForward => 'आगे';

  @override
  String get chatCollect => 'इकट्ठा करो';

  @override
  String get chatNoMembers => 'कोई सदस्य नहीं';

  @override
  String get chatMemberNotFound => 'सदस्य नहीं मिला';

  @override
  String get chatVoiceFileNotExist => 'ध्वनि फ़ाइल मौजूद नहीं है';

  @override
  String get chatVoiceFileEmpty => 'वॉइस फ़ाइल खाली है';

  @override
  String get chatSendingVoice => 'आवाज भेजी जा रही है...';

  @override
  String chatSendVoiceFailed(Object error) {
    return 'आवाज भेजने में विफल: $error';
  }

  @override
  String get chatMessageForwarded => 'संदेश अग्रेषित किया गया';

  @override
  String chatForwardFailed(Object error) {
    return 'अग्रेषित विफल: $error';
  }

  @override
  String get chatUnfavorited => 'पसंदीदा नहीं';

  @override
  String get chatFavorited => 'पसंदीदा';

  @override
  String get chatReactionAdded => 'प्रतिक्रिया जोड़ी गई';

  @override
  String get chatReactionRemoved => 'प्रतिक्रिया हटा दी गई';

  @override
  String get chatFailedMessageDeleted => 'विफल संदेश हटा दिया गया';

  @override
  String get chatDeleteMessages => 'संदेश हटाएँ';

  @override
  String chatDeleteMessagesConfirm(Object count) {
    return 'क्या आप वाकई $count संदेशों को हटाना चाहते हैं?';
  }

  @override
  String chatNoteOtherMessages(Object count) {
    return 'ध्यान दें: $count संदेश दूसरों के हैं और केवल आपके लिए हटाए जाएंगे।';
  }

  @override
  String chatMyMessagesWillBeRecalled(Object count) {
    return 'आपके द्वारा भेजे गए $count संदेश सभी के लिए याद रखे जाएंगे।';
  }

  @override
  String chatRecalledCount(Object count, Object localCount) {
    return '$count संदेशों को याद किया गया, $localCount केवल आपके लिए हटाया गया';
  }

  @override
  String chatRecalledMessages(Object count) {
    return '$count संदेशों को याद किया गया';
  }

  @override
  String chatDeletedLocally(Object count) {
    return '$count संदेश केवल आपके लिए हटाए गए';
  }

  @override
  String chatForwardedCount(Object count) {
    return 'अग्रेषित $count संदेश';
  }

  @override
  String chatForwardComplete(Object failed, Object success) {
    return 'अग्रेषित पूर्ण: $success सफल हुआ, $failed विफल रहा';
  }

  @override
  String get chatRemindOnlyInGroup =>
      'रिमाइंड सुविधा केवल समूह चैट में उपलब्ध है';

  @override
  String get chatOnlyTextSearchable => 'केवल टेक्स्ट संदेश ही खोजे जा सकते हैं';

  @override
  String chatSearchFor(Object text) {
    return '\"$text\" खोजें';
  }

  @override
  String get chatBaiduSearch => 'Baidu खोज';

  @override
  String get chatGoogleSearch => 'गूगल खोज';

  @override
  String get chatBingSearch => 'बिंग खोज';

  @override
  String get chatCalling => 'कॉल कर रहा हूँ...';

  @override
  String get chatRinging => 'बज रहा है...';

  @override
  String get chatInCall => 'कॉल में';

  @override
  String commonFeatureInDevelopment(String feature) {
    return '$feature सुविधा विकास में है...';
  }

  @override
  String chatCollectMessages(Object count) {
    return 'एकत्रित $count संदेश';
  }

  @override
  String commonMemberCount(int count) {
    return '$count सदस्य';
  }

  @override
  String groupDone(int count) {
    return 'हो गया($count)';
  }

  @override
  String get profileServices => 'सेवाएँ';

  @override
  String get commonFavorites => 'पसंदीदा';

  @override
  String get profileOrdersAndCards => 'आदेश और कार्ड';

  @override
  String get profileStickers => 'स्टिकर';

  @override
  String profileStatusSetTo(String status) {
    return 'स्थिति इस पर सेट है: $status';
  }

  @override
  String get profileAvatarUploadFailed => 'अवतार अपलोड विफल रहा';

  @override
  String get profilePersonalProfile => 'व्यक्तिगत प्रोफ़ाइल';

  @override
  String get profileName => 'नाम';

  @override
  String get profileGender => 'लिंग';

  @override
  String get profileRegion => 'क्षेत्र';

  @override
  String get commonMyQrCode => 'मेरा क्यूआर कोड';

  @override
  String get profilePoke => 'प्रहार';

  @override
  String get profileRingtone => 'रिंगटोन';

  @override
  String get profileDefaultRingtone => 'डिफ़ॉल्ट रिंगटोन';

  @override
  String get profileMyAddresses => 'मेरे पते';

  @override
  String profileGenderSetTo(String gender) {
    return 'लिंग इस पर सेट है: $gender';
  }

  @override
  String get profileSelectRegion => 'क्षेत्र चुनें';

  @override
  String get profileSelectCity => 'शहर चुनें';

  @override
  String profileRegionSetTo(String region) {
    return 'क्षेत्र इस पर सेट है: $region';
  }

  @override
  String get profileSetPoke => 'पोक सेट करें';

  @override
  String get profileFriendPokedMe => 'दोस्त ने मुझे पोक किया';

  @override
  String get profileExample => 'उदाहरण';

  @override
  String get profileOnTheShoulder => ' कंधे पर';

  @override
  String get profilePokeCleared => 'पोक साफ़ हो गया';

  @override
  String profilePokeSetTo(String suffix) {
    return 'पोक को इस पर सेट करें: पोक्ड मी$suffix';
  }

  @override
  String get profileEditSignature => 'हस्ताक्षर संपादित करें';

  @override
  String get profileIntroduceYourself => 'अपना परिचय देने के लिए एक वाक्य';

  @override
  String get profileSignatureCleared => 'हस्ताक्षर साफ़ हो गए';

  @override
  String get profileSignatureUpdated => 'हस्ताक्षर अद्यतन किया गया';

  @override
  String get profileScanToAddFriend =>
      'मुझे मित्र के रूप में जोड़ने के लिए ऊपर दिए गए QR कोड को स्कैन करें';

  @override
  String profileRingtoneSetTo(String ringtone) {
    return 'रिंगटोन इस पर सेट है: $ringtone';
  }

  @override
  String commonConfirmDissolveGroup(String name) {
    return 'क्या आप वाकई \"$name\" को भंग करना चाहते हैं? इस एक्शन को वापस नहीं किया जा सकता।';
  }

  @override
  String get authEnterValidServerAddress => 'कृपया एक वैध सर्वर पता दर्ज करें';

  @override
  String get authEnterServerAddressFirst => 'कृपया पहले सर्वर पता दर्ज करें';

  @override
  String get authPasskeyRequiresServer =>
      'पासकी लॉगिन के लिए सर्वर समर्थन की आवश्यकता होती है';

  @override
  String get authLoginAgreement => 'लॉग इन करके, आप सहमत हैं ';

  @override
  String get authPleaseAgreeToTerms =>
      'कृपया सेवा की शर्तें और गोपनीयता नीति पढ़ें और उनसे सहमत हों';

  @override
  String get authRegisterFailed => 'पंजीकरण विफल रहा';

  @override
  String get commonReenterPassword => 'पासवर्ड पुनः दर्ज करें';

  @override
  String get commonPasswordsDoNotMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get authInviteCodeBuiltIn => 'आमंत्रण कोड (अंतर्निहित)';

  @override
  String get authInviteCodeBuiltInNote =>
      'आमंत्रण कोड अंतर्निहित है, आमतौर पर संशोधित करने की कोई आवश्यकता नहीं है';

  @override
  String get authIHaveReadAndAgree => 'मैंने पढ़ा है और इससे सहमत हूं ';

  @override
  String get mainStartGroupChat => 'समूह चैट प्रारंभ करें';

  @override
  String get mainAddFriends => 'मित्र जोड़ें';

  @override
  String get mainPaymentAndCollection => 'भुगतान';

  @override
  String contactCount(int count) {
    return '$count संपर्क';
  }

  @override
  String get contactAddToHomeScreen => 'होम स्क्रीन पर जोड़ें';

  @override
  String contactRecommendedCardTo(String contact, String recipient) {
    return '$recipient को $contact का कार्ड अनुशंसित';
  }

  @override
  String get contactEnterRemarkName => 'टिप्पणी नाम दर्ज करें';

  @override
  String contactRemarkSetTo(String remark) {
    return 'टिप्पणी इस पर सेट है: $remark';
  }

  @override
  String contactAcceptedFriendRequest(String name) {
    return '$name का मित्र अनुरोध स्वीकार कर लिया';
  }

  @override
  String contactRejectedFriendRequest(String name) {
    return '$name का मित्र अनुरोध अस्वीकार कर दिया गया';
  }

  @override
  String get commonGroupInvites => 'समूह आमंत्रण';

  @override
  String commonMyGroups(int count) {
    return 'मेरे समूह ($count)';
  }

  @override
  String get commonInvitedToJoinGroup =>
      'समूह में शामिल होने के लिए आमंत्रित किया गया';

  @override
  String commonConfirmLeaveGroup(String name) {
    return 'क्या आप वाकई \"$name\" छोड़ना चाहते हैं?';
  }

  @override
  String get commonLeave => 'छोड़ो';

  @override
  String get commonRecallThisMessage => 'यह संदेश याद है?';

  @override
  String get commonSavedToGallery => 'गैलरी में सहेजा गया';

  @override
  String get commonFailedToSave => 'सहेजने में विफल';

  @override
  String get chatSaving => 'सहेजा जा रहा है...';

  @override
  String get commonShare => 'साझा करें';

  @override
  String get chatSaveToGallery => 'गैलरी में सहेजें';

  @override
  String chatDownloadFailed(String code) {
    return 'डाउनलोड विफल: $code';
  }

  @override
  String commonShareFailed(String error) {
    return 'शेयर विफल: $error';
  }

  @override
  String get chatFailedToLoadImage => 'छवि लोड करने में विफल';

  @override
  String get chatVideoRecordingFailed => 'वीडियो रिकॉर्डिंग विफल रही';

  @override
  String get profileRedPacket => 'लाल पैकेट';

  @override
  String get commonMusic => 'संगीत';

  @override
  String get commonCoupon => 'कूपन';

  @override
  String get commonGift => 'उपहार';

  @override
  String get commonPoll => 'मतदान';

  @override
  String get favoriteText => 'पाठ';

  @override
  String get favoriteLinkLabel => 'लिंक';

  @override
  String get favoriteNote => 'नोट';

  @override
  String get favoriteMyNotes => 'मेरे नोट्स';

  @override
  String get favoriteToday => 'आज';

  @override
  String favoriteDaysAgoText(int count) {
    return '$count दिन पहले';
  }

  @override
  String favoriteDateFormat(int month, int day) {
    return '$month/$day';
  }

  @override
  String get favoriteNoFavorites => 'अभी तक कोई पसंदीदा नहीं';

  @override
  String get favoriteLongPressToFavorite =>
      'पसंदीदा के लिए संदेश को देर तक दबाएँ';

  @override
  String get favoriteNewNote => 'नया नोट';

  @override
  String get favoriteLink => 'पसंदीदा लिंक';

  @override
  String get favoriteEditTags => 'टैग संपादित करें';

  @override
  String get favoriteDeleteFavorite => 'पसंदीदा हटाएँ';

  @override
  String get favoriteDeleteFavoriteConfirm =>
      'क्या आप वाकई इस पसंदीदा को हटाना चाहते हैं?';

  @override
  String get favoriteNoSearchResultsFound => 'कोई परिणाम नहीं मिला';

  @override
  String get commonSendRedPacket => 'लाल पैकेट भेजें';

  @override
  String get transferAmount => 'रकम';

  @override
  String get commonRedPacketCover => 'लाल पैकेट कवर';

  @override
  String get commonRedPacketType => 'लाल पैकेट प्रकार';

  @override
  String get commonNormalRedPacket => 'सामान्य';

  @override
  String get commonLuckyRedPacket => 'भाग्यशाली';

  @override
  String get commonRedPacketCount => 'लाल पैकेट गिनती';

  @override
  String get commonPieces => 'टुकड़े';

  @override
  String get commonPutMoneyInRedPacket => 'लाल पैकेट में पैसे रखें';

  @override
  String get commonRedPacketRefundNotice =>
      'लावारिस लाल पैकेट 24 घंटे के बाद वापस कर दिए जाएंगे';

  @override
  String get commonOpenRedPacket => 'खुला';

  @override
  String get commonRedPacketAllClaimed => 'लाल पैकेट सभी पर दावा किया गया';

  @override
  String get commonRedPacketExpired => 'लाल पैकेट समाप्त हो गया';

  @override
  String get commonAddTransferNote => 'स्थानांतरण नोट जोड़ें';

  @override
  String get commonYuan => 'सीएनवाई';

  @override
  String get commonReplyWithEmoji => 'इस इमोजी के साथ जवाब दें';

  @override
  String get contactEditRemark => 'टिप्पणी संपादित करें';

  @override
  String get contactSetPermissions => 'अनुमतियाँ सेट करें';

  @override
  String get profileAddToBlacklist => 'काली सूची में जोड़ें';

  @override
  String get contactDeleteContact => 'संपर्क हटाएँ';

  @override
  String contactDeleteContactConfirm(String name) {
    return 'क्या आप वाकई $name को हटाना चाहते हैं?';
  }

  @override
  String get transferTitle => 'स्थानांतरण';

  @override
  String get transferReceiverAddressLabel => 'प्राप्तकर्ता का पता';

  @override
  String get transferSelectTokenLabel => 'टोकन चुनें';

  @override
  String get transferAmountLabel => 'स्थानांतरण राशि';

  @override
  String get transferMemoLabel => 'मेमो (वैकल्पिक)';

  @override
  String get transferAddMemoHint => 'एक मेमो जोड़ें';

  @override
  String get transferSendPaymentRequest => 'भुगतान अनुरोध भेजें';

  @override
  String get transferQrCodeGenerateFailed => 'QR कोड जनरेशन विफल';

  @override
  String get transferScanQrToPayMe =>
      'मुझे भुगतान करने के लिए QR कोड स्कैन करें';

  @override
  String get transferMyWalletAddress => 'मेरा बटुआ पता';

  @override
  String get transferCreatePaymentRequest => 'भुगतान अनुरोध बनाएँ';

  @override
  String profileN42IdLabel(String id) {
    return 'N42 आईडी: $id';
  }

  @override
  String get commonRedPacketDefaultGreeting => 'शुभकामनाएँ';

  @override
  String commonSenderRedPacket(String name) {
    return '$name का लाल पैकेट';
  }

  @override
  String get transferEnterValidAddress => 'कृपया एक वैध पता दर्ज करें';

  @override
  String get transferPleaseSelectToken => 'कृपया एक टोकन चुनें';

  @override
  String get commonReceivedTransfer => 'स्थानांतरण प्राप्त हुआ';

  @override
  String commonSenderSentRedPacket(String name) {
    return '$name ने एक लाल पैकेट भेजा';
  }

  @override
  String get commonSavedToBalance =>
      'शेष राशि में सहेजा गया, सीधे स्थानांतरित किया जा सकता है';

  @override
  String get commonRedPacketExpiredOrEmpty =>
      'लाल पैकेट की समय सीमा समाप्त/सभी पर दावा किया गया';

  @override
  String get transferScanFeatureComingSoon =>
      'स्कैन सुविधा जल्द ही आ रही है...';

  @override
  String get contactSetAsStarred => 'तारांकित के रूप में सेट करें';

  @override
  String get contactAddToBlocklist => 'ब्लॉकलिस्ट में जोड़ें';

  @override
  String get commonClaimedYour => ' आपका दावा किया ';

  @override
  String get commonClaimedText => ' दावा किया ';

  @override
  String commonUserTyping(String name) {
    return '$name टाइप कर रहा है...';
  }

  @override
  String get commonTyping => 'टाइपिंग...';

  @override
  String get commonWaitingToReceive => 'प्राप्त करने की प्रतीक्षा कर रहा हूँ';

  @override
  String get commonTapToClaim => 'दावा करने के लिए टैप करें';

  @override
  String get commonHasBeenReceived => 'प्राप्त हो गया है';

  @override
  String get commonGetLucky => 'भाग्यशाली बनो';

  @override
  String get qrcodeCameraStartFailed => 'कैमरा प्रारंभ होने में विफल रहा';

  @override
  String get qrcodeUnknownError => 'अज्ञात त्रुटि';

  @override
  String get qrcodePlaceQrCodeInFrame =>
      'स्कैन करने के लिए QR कोड को फ्रेम के भीतर रखें';

  @override
  String get qrcodeCloseManualInput => 'मैन्युअल इनपुट बंद करें';

  @override
  String get qrcodeManualInputUserId => 'मैनुअल इनपुट यूजर आईडी';

  @override
  String get commonAdd => 'जोड़ें';

  @override
  String get profileSetStatus => 'स्थिति निर्धारित करें';

  @override
  String get profileVisibleToFriends24h => 'मित्रों के लिए 24 घंटे दृश्यमान';

  @override
  String get profileWriteStatus => 'स्थिति लिखें';

  @override
  String get profileEnterYourStatus => 'अपनी स्थिति दर्ज करें...';

  @override
  String get profileOk => 'ठीक है';

  @override
  String get qrcodeCameraPermissionRequired =>
      'क्यूआर कोड को स्कैन करने के लिए कैमरे की अनुमति आवश्यक है';

  @override
  String get qrcodeCameraPermissionDenied =>
      'कैमरे की अनुमति स्थायी रूप से अस्वीकार कर दी गई थी. कृपया इसे सिस्टम सेटिंग्स में सक्षम करें।';

  @override
  String qrcodePermissionCheckError(String error) {
    return 'अनुमति जाँचने में त्रुटि: $error';
  }

  @override
  String get qrcodeInvalidQrCode => 'अमान्य क्यूआर कोड';

  @override
  String qrcodeCannotAddFriend(String error) {
    return 'मित्र नहीं जोड़ा जा सकता: $error';
  }

  @override
  String get qrcodeScanQrCode => 'QR कोड स्कैन करें';

  @override
  String get qrcodeCheckingCameraPermission =>
      'कैमरे की अनुमति जाँची जा रही है...';

  @override
  String get qrcodeNeedCameraPermission => 'कैमरे की अनुमति आवश्यक है';

  @override
  String get qrcodeRetryPermission => 'पुनः प्रयास करें';

  @override
  String get qrcodeOpenSettings => 'सेटिंग्स खोलें';

  @override
  String get groupInviteMembers => 'सदस्यों को आमंत्रित करें';

  @override
  String groupInviteCount(int count) {
    return 'आमंत्रित करें($count)';
  }

  @override
  String get profileNoShippingAddress => 'कोई शिपिंग पता नहीं';

  @override
  String get profileDefaultLabel => 'डिफ़ॉल्ट';

  @override
  String get profileNoInvoice => 'कोई चालान नहीं';

  @override
  String get profileCompany => 'कंपनी';

  @override
  String get profileTaxNumber => 'कर क्रमांक';

  @override
  String get profileConfirmDeleteAddress =>
      'क्या आप वाकई यह पता हटाना चाहते हैं?';

  @override
  String get profileConfirmDeleteInvoice =>
      'क्या आप वाकई इस चालान को हटाना चाहते हैं?';

  @override
  String get commonGroupOwner => 'मालिक';

  @override
  String get commonGroupAdmin => 'व्यवस्थापक';

  @override
  String get groupSearchMembers => 'सदस्यों को खोजें';

  @override
  String groupTotalMembers(int count) {
    return '$count सदस्य';
  }

  @override
  String get chatRemoveFromGroup => 'समूह से हटाएँ';

  @override
  String groupConfirmRemoveMember(String name) {
    return 'क्या आप वाकई \"$name\" को समूह से हटाना चाहते हैं?';
  }

  @override
  String get chatUnknownSong => 'अज्ञात गीत';

  @override
  String get chatUnknownArtist => 'अज्ञात कलाकार';

  @override
  String get chatUnknownContact => 'अज्ञात संपर्क';

  @override
  String get chatPersonalCard => 'संपर्क कार्ड';

  @override
  String get chatSingleChoice => 'एकल';

  @override
  String get chatMultiChoice => 'बहु';

  @override
  String get chatEnded => 'समाप्त';

  @override
  String get chatEndPollButton => 'मतदान समाप्त करें';

  @override
  String get chatPollHint =>
      'पोल चैट में प्रदर्शित किया जाएगा. समूह के सदस्य मतदान कर सकते हैं.';

  @override
  String get chatSearchSongOrArtist => 'गीत या कलाकार खोजें';

  @override
  String get chatNoSongsFound => 'कोई गाना नहीं मिला';

  @override
  String get chatSongNameOptional => 'गाने का नाम (वैकल्पिक)';

  @override
  String get chatEnterSongName => 'गीत का नाम दर्ज करें';

  @override
  String get chatArtistNameOptional => 'कलाकार का नाम (वैकल्पिक)';

  @override
  String get chatEnterArtistName => 'कलाकार का नाम दर्ज करें';

  @override
  String get chatRealTimeLocationSharing =>
      'विकास में वास्तविक समय स्थान साझाकरण...';

  @override
  String get profileVoiceCallFeatureInDev => 'वॉयस कॉल सुविधा विकास में...';

  @override
  String get profileReportFeatureInDev => 'विकास में रिपोर्ट सुविधा...';

  @override
  String get profileShareFeatureInDev => 'विकास में सुविधा साझा करें...';

  @override
  String get profileQrCodeFeatureInDev => 'विकास में क्यूआर कोड सुविधा...';

  @override
  String get qrcodeScanQrToAddMe =>
      'मुझे मित्र के रूप में जोड़ने के लिए ऊपर दिए गए QR कोड को स्कैन करें';

  @override
  String get qrcodeSaveToAlbum => 'एल्बम में सहेजें';

  @override
  String get qrcodeChangeStyle => 'शैली बदलें';

  @override
  String get qrcodeCopyId => 'आईडी कॉपी करें';

  @override
  String get qrcodeIdCopied => 'आईडी कॉपी की गई';

  @override
  String get qrcodeMoreStylesFeatureComingSoon =>
      'अधिक शैलियाँ जल्द ही आ रही हैं';

  @override
  String get profileBio => 'बायो';

  @override
  String get profileHomeServer => 'सर्वर';

  @override
  String get profileShareContactCard => 'संपर्क कार्ड साझा करें';

  @override
  String get profileRemoveFromBlacklist => 'काली सूची से हटाएँ';

  @override
  String get profileConfirmAddBlacklist =>
      'क्या आप वाकई इस उपयोगकर्ता को काली सूची में जोड़ना चाहते हैं? आपको उनसे संदेश प्राप्त नहीं होंगे.';

  @override
  String get profileConfirmRemoveBlacklist =>
      'क्या आप वाकई इस उपयोगकर्ता को काली सूची से हटाना चाहते हैं?';

  @override
  String get profileRemarkSaved => 'टिप्पणी सहेजी गई';

  @override
  String get profileRemarkCleared => 'टिप्पणी साफ़ कर दी गई';

  @override
  String get transferReceive => 'प्राप्त करें';

  @override
  String get transferPleaseConnectWallet => 'कृपया पहले अपना वॉलेट कनेक्ट करें';

  @override
  String get transferSendRequest => 'अनुरोध भेजें';

  @override
  String get transferPleaseEnterValidAmount => 'कृपया एक वैध राशि दर्ज करें';

  @override
  String get searchPlaceholder => 'संपर्क, समूह, संदेश खोजें';

  @override
  String get searchEnterKeywordToSearch =>
      'खोज शुरू करने के लिए कीवर्ड दर्ज करें';

  @override
  String get searchClearHistory => 'स्पष्ट';

  @override
  String searchNoResultsForQuery(String query) {
    return '\"$query\" के लिए कोई परिणाम नहीं मिला';
  }

  @override
  String get searchAllResults => 'सब';

  @override
  String get searchInChat => 'चैट में खोजें';

  @override
  String get searchContactLabel => 'संपर्क करें';

  @override
  String get searchGroupLabel => 'समूह';

  @override
  String get searchConversationLabel => 'बातचीत';

  @override
  String get searchMessageLabel => 'संदेश';

  @override
  String get settingsSecurityTitle => 'सुरक्षा';

  @override
  String get settingsKeyBackup => 'कुंजी बैकअप';

  @override
  String get settingsBackupEncryptionKeys => 'बैकअप एन्क्रिप्शन कुंजी';

  @override
  String settingsKeysBackedUp(int count) {
    return '$count कुंजियों का बैकअप लिया गया';
  }

  @override
  String get settingsBackupNotSet => 'बैकअप सेट नहीं है';

  @override
  String get settingsRestoreKeys => 'कुंजियाँ पुनर्स्थापित करें';

  @override
  String get settingsRestoreKeysFromBackup =>
      'बैकअप से एन्क्रिप्शन कुंजियाँ पुनर्स्थापित करें';

  @override
  String get settingsExportKeys => 'कुंजी निर्यात करें';

  @override
  String get settingsExportKeysToFile => 'फ़ाइल में कुंजी निर्यात करें';

  @override
  String get settingsLoggedInDevices => 'लॉग इन डिवाइस';

  @override
  String get settingsNoOtherDevices => 'कोई अन्य उपकरण नहीं';

  @override
  String get settingsVerified => 'सत्यापित';

  @override
  String get settingsUnverified => 'असत्यापित';

  @override
  String get settingsAdvanced => 'उन्नत';

  @override
  String get settingsCrossSigning => 'क्रॉस-साइनिंग';

  @override
  String get settingsEnabled => 'सक्षम';

  @override
  String get settingsNotEnabled => 'सक्षम नहीं';

  @override
  String get settingsResetEncryption => 'एन्क्रिप्शन रीसेट करें';

  @override
  String get settingsDeleteAllEncryptionKeys =>
      'सभी एन्क्रिप्शन कुंजियाँ हटाएँ';

  @override
  String get settingsEncryptionNotSupported => 'एन्क्रिप्शन समर्थित नहीं है';

  @override
  String get settingsNotInitialized => 'प्रारंभ नहीं किया गया';

  @override
  String get settingsBackupKeyTitle => 'बैकअप कुंजियाँ';

  @override
  String get settingsBackupKeyMessage =>
      'एक नई कुंजी बैकअप बनाएँ? यह आपको नए डिवाइस पर एन्क्रिप्टेड संदेशों को पुनर्स्थापित करने में मदद करेगा।';

  @override
  String get settingsBackup => 'बैकअप';

  @override
  String get settingsRestoreKeyTitle => 'कुंजियाँ पुनर्स्थापित करें';

  @override
  String get settingsRestoreKeyMessage =>
      'एन्क्रिप्टेड संदेशों को पुनर्स्थापित करने के लिए अपना पुनर्प्राप्ति पासवर्ड या पुनर्प्राप्ति कुंजी दर्ज करें।';

  @override
  String get settingsRestore => 'पुनर्स्थापित करें';

  @override
  String get settingsExportKeyTitle => 'कुंजी निर्यात करें';

  @override
  String get settingsExportKeyMessage =>
      'निर्यात की गई कुंजी फ़ाइल में आपकी सभी एन्क्रिप्शन कुंजियाँ शामिल हैं। कृपया इसे सुरक्षित रखें.';

  @override
  String get settingsExport => 'निर्यात करें';

  @override
  String settingsDeviceIdLabel(String deviceId) {
    return 'डिवाइस आईडी: $deviceId';
  }

  @override
  String get settingsDeviceStatusVerified => 'स्थिति: सत्यापित';

  @override
  String get settingsDeviceStatusUnverified => 'स्थिति: असत्यापित';

  @override
  String settingsLastActiveLabel(String lastSeen) {
    return 'अंतिम सक्रिय: $lastSeen';
  }

  @override
  String get settingsVerifyThisDevice => 'इस डिवाइस को सत्यापित करें';

  @override
  String get settingsCrossSigningAlreadyEnabled =>
      'क्रॉस-साइनिंग पहले से ही सक्षम है';

  @override
  String get settingsCrossSigningSetupSuccess => 'क्रॉस-साइनिंग सेटअप सफल';

  @override
  String get settingsResetEncryptionTitle => 'एन्क्रिप्शन रीसेट करें';

  @override
  String get settingsResetEncryptionWarning =>
      'चेतावनी: यह आपकी सभी एन्क्रिप्शन कुंजियाँ हटा देगा. आप पिछले एन्क्रिप्टेड संदेशों को डिक्रिप्ट नहीं कर पाएंगे. इस एक्शन को वापस नहीं किया जा सकता।';

  @override
  String get settingsReset => 'रीसेट करें';

  @override
  String get settingsBackupSuccess => 'कुंजियों का सफलतापूर्वक बैकअप लिया गया';

  @override
  String get settingsBackupFailed => 'बैकअप विफल रहा';

  @override
  String get settingsRecoveryKey => 'पुनर्प्राप्ति कुंजी';

  @override
  String get settingsRecoveryKeySaveWarning =>
      'कृपया इस पुनर्प्राप्ति कुंजी को सुरक्षित स्थान पर सहेजें। आपको किसी नए डिवाइस पर अपने एन्क्रिप्टेड संदेशों को पुनर्स्थापित करने के लिए इसकी आवश्यकता होगी।';

  @override
  String get settingsRecoveryKeySaved => 'मैंने इसे सेव कर लिया है';

  @override
  String get settingsRestoreSuccess =>
      'कुंजियाँ सफलतापूर्वक पुनर्स्थापित की गईं';

  @override
  String get settingsRestoreFailed => 'पुनर्स्थापना विफल';

  @override
  String get settingsPassword => 'पासवर्ड';

  @override
  String get settingsEnterRecoveryKey => 'पुनर्प्राप्ति कुंजी दर्ज करें';

  @override
  String get settingsEnterPassword => 'पासवर्ड दर्ज करें';

  @override
  String get settingsExportSuccess =>
      'सर्वर बैकअप में कुंजियाँ सफलतापूर्वक निर्यात की गईं';

  @override
  String get settingsExportNeedBackupFirst => 'कृपया पहले एक कुंजी बैकअप बनाएं';

  @override
  String get settingsExportFailed => 'निर्यात विफल';

  @override
  String get settingsResetSuccess => 'एन्क्रिप्शन रीसेट सफल';

  @override
  String get settingsResetFailed => 'रीसेट विफल रहा';

  @override
  String get callLeaveMeetingConfirm => 'क्या आप वाकई मीटिंग छोड़ना चाहते हैं?';

  @override
  String chatPokedSomeone(String name, String suffix) {
    return 'पोक्ड $name$suffix';
  }

  @override
  String get chatNoContactsToAdd => 'जोड़ने के लिए कोई संपर्क उपलब्ध नहीं है';

  @override
  String get chatAddMembers => 'सदस्य जोड़ें';

  @override
  String chatInvitedMembers(int count) {
    return '$count सदस्यों को आमंत्रित किया गया';
  }

  @override
  String chatInviteFailed(String error) {
    return 'आमंत्रण विफल: $error';
  }

  @override
  String get chatMemberRemoved => 'सदस्य हटा दिया गया';

  @override
  String chatRemoveFailed(String error) {
    return 'हटाना विफल: $error';
  }

  @override
  String get chatRealTimeLocationShareMessage =>
      'शेयर करने के बाद दूसरा पक्ष 1 घंटे तक आपकी रियल टाइम लोकेशन देख सकता है.';

  @override
  String get chatStartSharing => 'साझा करना प्रारंभ करें';

  @override
  String get chatLocationServiceNotEnabled => 'स्थान सेवा सक्षम नहीं है';

  @override
  String get chatEnableLocationService =>
      'कृपया इस सुविधा का उपयोग करने के लिए स्थान सेवा सक्षम करें';

  @override
  String get chatGoToSettings => 'सेटिंग्स पर जाएं';

  @override
  String get chatLocationPermissionRequired =>
      'इस सुविधा के लिए स्थान की अनुमति आवश्यक है';

  @override
  String get chatLocationPermissionDeniedPermanent =>
      'स्थान की अनुमति स्थायी रूप से अस्वीकार कर दी गई है. कृपया इसे सेटिंग्स में सक्षम करें।';

  @override
  String get chatLocationPermissionDenied => 'स्थान की अनुमति अस्वीकृत';

  @override
  String get chatGettingLocation => 'स्थान प्राप्त हो रहा है...';

  @override
  String chatGetLocationFailed(String error) {
    return 'स्थान प्राप्त करने में विफल: $error';
  }

  @override
  String get chatMapPreview => 'मानचित्र पूर्वावलोकन';

  @override
  String get chatSearchLocation => 'स्थान खोजें';

  @override
  String chatRedPacketSent(String amount, String token) {
    return '$amount $token लाल पैकेट भेजा गया';
  }

  @override
  String get chatTransferDefault => 'स्थानांतरण';

  @override
  String chatTransferSent(String amount, String token) {
    return '$amount $token स्थानांतरण भेजा गया';
  }

  @override
  String chatPickFileFailed(String error) {
    return 'फ़ाइल चुनने में विफल: $error';
  }

  @override
  String get chatFileSizeLimit => 'फ़ाइल का आकार 50MB से अधिक नहीं हो सकता';

  @override
  String chatFileSending(String filename) {
    return 'फ़ाइल भेजी जा रही है: $filename';
  }

  @override
  String chatSendFileFailed(String error) {
    return 'फ़ाइल भेजने में विफल: $error';
  }

  @override
  String chatContactCardSent(String name) {
    return '$name का संपर्क कार्ड भेजा गया';
  }

  @override
  String get chatFavoritesFeature => 'पसंदीदा';

  @override
  String get chatCouponsFeature => 'कूपन';

  @override
  String get chatGiftFeature => 'उपहार';

  @override
  String chatSharedMusic(String name) {
    return 'साझा किया गया $name';
  }

  @override
  String get chatEndPollTitle => 'मतदान समाप्त करें';

  @override
  String get chatEndPollConfirmMessage =>
      'क्या आप वाकई इस मतदान को समाप्त करना चाहते हैं? मतदान समाप्त होने के बाद बंद कर दिया जाएगा.';

  @override
  String get chatPollEndedMessage => 'मतदान समाप्त हुआ';

  @override
  String get chatConnectingCall => 'कनेक्ट हो रहा है...';

  @override
  String get chatMuteCall => 'मूक';

  @override
  String get chatSpeakerOff => 'स्पीकर बंद';

  @override
  String get chatSpeakerOn => 'वक्ता';

  @override
  String get chatCameraOn => 'कैमरा चालू';

  @override
  String get chatCameraOff => 'कैमरा बंद';

  @override
  String get chatHangUp => 'रुको';

  @override
  String get chatSelectForwardTargetTitle => 'अग्रेषित लक्ष्य का चयन करें';

  @override
  String get chatNoForwardableChat =>
      'अग्रेषित करने के लिए कोई चैट उपलब्ध नहीं है';

  @override
  String get chatNoMatchingChat => 'कोई मेल खाती चैट नहीं मिली';

  @override
  String get chatLocationTitle => 'स्थान';

  @override
  String get chatSendButton => 'भेजें';

  @override
  String get chatRetryButton => 'पुनः प्रयास करें';

  @override
  String get chatSearchContactHint => 'संपर्क खोजें';

  @override
  String get chatShareMusic => 'संगीत साझा करें';

  @override
  String get chatRecentPlayed => 'हाल का';

  @override
  String get chatMyFavorites => 'पसंदीदा';

  @override
  String get chatNetworkLink => 'लिंक';

  @override
  String get chatLocalFile => 'स्थानीय';

  @override
  String get chatPasteMusicLink => 'संगीत लिंक चिपकाएँ';

  @override
  String get chatShareMusicButton => 'संगीत साझा करें';

  @override
  String get chatSelectLocalAudio => 'स्थानीय ऑडियो फ़ाइल का चयन करें';

  @override
  String get chatSupportedAudioFormats =>
      'MP3, M4A, WAV, FLAC आदि को सपोर्ट करता है।';

  @override
  String get chatSelectFileButton => 'फ़ाइल चुनें';

  @override
  String get chatPleaseEnterMusicLink => 'कृपया संगीत लिंक दर्ज करें';

  @override
  String get chatPleaseEnterValidLink => 'कृपया एक मान्य यूआरएल दर्ज करें';

  @override
  String get chatSharedSong => 'साझा किया गया गाना';

  @override
  String get chatSelectMember => 'सदस्य का चयन करें';

  @override
  String get chatSearchMemberHint => 'सदस्यों को खोजें';

  @override
  String get chatNoMatchingMembers => 'कोई मेल खाने वाला सदस्य नहीं मिला';

  @override
  String get commonUnknownMember => 'अज्ञात';

  @override
  String chatSelectedMessagesCount(int count) {
    return 'चयनित $count संदेश';
  }

  @override
  String get chatSearchContactsOrGroups => 'संपर्क या समूह खोजें';

  @override
  String get chatVideoTitle => 'वीडियो';

  @override
  String get chatLoadingText => 'लोड हो रहा है...';

  @override
  String get chatVideoLoadFailed => 'वीडियो लोड विफल रहा';

  @override
  String get chatPlayerInitFailed => 'प्लेयर आरंभीकरण विफल रहा';

  @override
  String get chatCreatePollTitle => 'पोल बनाएं';

  @override
  String get chatSubmitPoll => 'सबमिट करें';

  @override
  String get chatPollQuestionLabel => 'मतदान प्रश्न';

  @override
  String get chatEnterPollQuestionHint => 'कृपया जनमत प्रश्न दर्ज करें';

  @override
  String get chatPollOptionsLabel => 'मतदान विकल्प';

  @override
  String chatOptionHintWithIndex(int index) {
    return 'विकल्प $index';
  }

  @override
  String get chatAddOptionButton => 'विकल्प जोड़ें';

  @override
  String get chatPollSettingsLabel => 'पोल सेटिंग्स';

  @override
  String get chatSelectionType => 'चयन प्रकार';

  @override
  String get chatSingleChoiceLabel => 'एकल';

  @override
  String get chatMultiChoiceLabel => 'बहु';

  @override
  String get chatAnonymousPollSwitch => 'अनाम पोल';

  @override
  String get chatPleaseEnterQuestion => 'कृपया जनमत प्रश्न दर्ज करें';

  @override
  String get chatAtLeastTwoOptions => 'कम से कम 2 विकल्प आवश्यक हैं';

  @override
  String chatConfirmWithCount(int count) {
    return 'पुष्टि करें ($count)';
  }

  @override
  String get authEmailVerificationTitle => 'ईमेल सत्यापन';

  @override
  String get authEnterValidEmailAddress => 'कृपया एक वैध ईमेल पता दर्ज करें';

  @override
  String authVerificationCodeSentTo(String email) {
    return 'सत्यापन कोड $email पर भेजा गया';
  }

  @override
  String authSendCodeFailed(String error) {
    return 'कोड भेजने में विफल: $error';
  }

  @override
  String get authVerificationSuccess => 'सत्यापन सफल';

  @override
  String get authVerificationFailed => 'सत्यापन विफल रहा';

  @override
  String authVerificationCodeError(String error) {
    return 'सत्यापन कोड त्रुटि: $error';
  }

  @override
  String get commonEnterVerificationCode => 'सत्यापन कोड दर्ज करें';

  @override
  String get authEnterYourEmail => 'ईमेल दर्ज करें';

  @override
  String authWeSentCodeTo(String email) {
    return 'हमने 6 अंकों का कोड भेजा\n$email';
  }

  @override
  String get authEnterEmailForCode =>
      'अपना ईमेल पता दर्ज करें, हम सत्यापन कोड भेजेंगे';

  @override
  String get commonSendVerificationCode => 'सत्यापन कोड भेजें';

  @override
  String get authResendVerificationCode => 'सत्यापन कोड पुनः भेजें';

  @override
  String authCanResendAfter(int seconds) {
    return '$seconds सेकंड के बाद पुनः भेज सकते हैं';
  }

  @override
  String get commonChangeEmail => 'ईमेल बदलें';

  @override
  String get contactAddToContacts => 'संपर्कों में जोड़ें';

  @override
  String get contactAddingToContacts => 'जोड़ा जा रहा है...';

  @override
  String get contactAddedToContacts => 'संपर्कों में जोड़ा गया';

  @override
  String contactAddFailedWithError(String error) {
    return 'जोड़ें विफल: $error';
  }

  @override
  String get contactAddPhone => 'फ़ोन जोड़ें';

  @override
  String get contactAddTag => 'टैग जोड़ें';

  @override
  String get contactAddText => 'पाठ जोड़ें';

  @override
  String get contactAddPhoto => 'फ़ोटो जोड़ें';

  @override
  String contactGroupCountLabel(int count) {
    return '$count समूह';
  }

  @override
  String get contactAddedViaSearch => 'खोज के माध्यम से जोड़ा गया';

  @override
  String get contactAddTime => 'समय जोड़ें';

  @override
  String get contactDoneButton => 'हो गया';

  @override
  String get callWaitingForParticipants =>
      'प्रतिभागियों के शामिल होने की प्रतीक्षा की जा रही है...';

  @override
  String callParticipantMe(String name) {
    return '$name (मैं)';
  }

  @override
  String get callSharingLabel => 'साझा करना';

  @override
  String callScreenSharingBy(String name) {
    return '$name स्क्रीन साझा कर रहा है';
  }

  @override
  String callParticipantCount(int count) {
    return '$count प्रतिभागी';
  }

  @override
  String get callMuteLabel => 'मूक';

  @override
  String get callUnmuteLabel => 'अनम्यूट करें';

  @override
  String get callTurnOffVideo => 'वीडियो बंद करें';

  @override
  String get callTurnOnVideo => 'वीडियो चालू करें';

  @override
  String get callShareScreen => 'स्क्रीन साझा करें';

  @override
  String get callStopSharing => 'साझा करना बंद करो';

  @override
  String get callSwitchCameraLabel => 'स्विच करें';

  @override
  String get callLeaveLabel => 'छोड़ो';

  @override
  String get callParticipantsLabel => 'प्रतिभागियों';

  @override
  String get callJoiningMeeting => 'मीटिंग में शामिल हो रहे हैं...';

  @override
  String chatPollVotesFormat(int count, String percentage) {
    return '$count वोट ($percentage%)';
  }

  @override
  String chatPollParticipantsFormat(int count) {
    return '$count प्रतिभागी';
  }

  @override
  String get commonTapToRetry => 'पुनः प्रयास करने के लिए टैप करें';

  @override
  String get chatDefaultRedPacketGreeting => 'समृद्धि के लिए शुभकामनाएँ';

  @override
  String get groupAllowOthersToSearchAndJoin =>
      'दूसरों को खोजने और शामिल होने की अनुमति दें';

  @override
  String get groupConfirmClearChatHistory =>
      'क्या आप वाकई चैट इतिहास साफ़ करना चाहते हैं?';

  @override
  String get groupCreateGroupToChat => 'चैटिंग शुरू करने के लिए एक समूह बनाएं';

  @override
  String get groupEditGroupAnnouncement => 'समूह घोषणा संपादित करें';

  @override
  String get groupEditGroupDescription => 'समूह विवरण संपादित करें';

  @override
  String get groupEnterGroupAnnouncement => 'समूह घोषणा दर्ज करें';

  @override
  String chatErrorWithMessage(String message) {
    return 'त्रुटि: $message';
  }

  @override
  String groupMemberCountClickToCopy(int count) {
    return '$count सदस्य, समूह आईडी कॉपी करने के लिए क्लिक करें';
  }

  @override
  String get chatMusicLinkLabel => 'संगीत लिंक';

  @override
  String get chatNoMediaUrlAvailable => 'कोई मीडिया यूआरएल उपलब्ध नहीं है';

  @override
  String get groupNoPermissionToEditGroupName =>
      'आपके पास समूह का नाम संपादित करने की अनुमति नहीं है';

  @override
  String get chatRedPacketTransferCannotForward =>
      'लाल पैकेट और स्थानांतरण अग्रेषित नहीं किए जा सकते';

  @override
  String get authEmailAddress => 'ईमेल पता';

  @override
  String get commonEnterEmailAddress => 'ईमेल पता दर्ज करें';

  @override
  String get authEmailRecoveryHint =>
      'पासवर्ड पुनर्प्राप्ति के लिए उपयोग किया जाता है';

  @override
  String get commonInvalidEmailFormat => 'कृपया एक वैध ईमेल पता दर्ज करें';

  @override
  String get authOptional => 'वैकल्पिक';

  @override
  String get authResetPassword => 'पासवर्ड रीसेट करें';

  @override
  String get authEnterRegisteredEmail =>
      'वह ईमेल पता दर्ज करें जिससे आपने पंजीकरण कराया था';

  @override
  String get authSendResetCode => 'रीसेट कोड भेजें';

  @override
  String authResetCodeSent(String email) {
    return 'रीसेट कोड $email पर भेजा गया';
  }

  @override
  String get authEnterResetCode => 'रीसेट कोड दर्ज करें';

  @override
  String get authSetNewPassword => 'नया पासवर्ड सेट करें';

  @override
  String get commonConfirmNewPassword => 'नये पासवर्ड की पुष्टि करें';

  @override
  String get commonNewPassword => 'नया पासवर्ड';

  @override
  String get authPasswordResetSuccess =>
      'पासवर्ड रीसेट सफल. कृपया अपने नए पासवर्ड से लॉगिन करें.';

  @override
  String get authResetPasswordFailed => 'पासवर्ड रीसेट विफल रहा';

  @override
  String get settingsChangePassword => 'पासवर्ड बदलें';

  @override
  String get settingsCurrentPassword => 'वर्तमान पासवर्ड';

  @override
  String get settingsEnterCurrentPassword => 'वर्तमान पासवर्ड दर्ज करें';

  @override
  String get settingsEnterNewPassword => 'नया पासवर्ड दर्ज करें';

  @override
  String get settingsPasswordChanged =>
      'पासवर्ड सफलतापूर्वक बदला गया. कृपया अपने नए पासवर्ड से लॉगिन करें.';

  @override
  String get settingsChangePasswordFailed => 'पासवर्ड बदलना विफल रहा';

  @override
  String get settingsNewPasswordMustBeDifferent =>
      'नया पासवर्ड मौजूदा पासवर्ड से अलग होना चाहिए';

  @override
  String get settingsChangePasswordInfo =>
      'पासवर्ड बदलने के बाद आप लॉग आउट हो जाएंगे और नए पासवर्ड से लॉग इन करना होगा।';

  @override
  String get settingsPasswordRequirements => 'पासवर्ड आवश्यकताएँ:';

  @override
  String get settingsSecurityNote =>
      'सुरक्षा के लिए आपको पासवर्ड बदलने के बाद सभी डिवाइस पर दोबारा लॉग इन करना होगा।';

  @override
  String get settingsSecurity => 'सुरक्षा';

  @override
  String get settingsCurrentBoundEmail => 'वर्तमान बाध्य ईमेल';

  @override
  String get settingsNewEmailAddress => 'नया ईमेल पता';

  @override
  String get settingsEnterNewEmail => 'नया ईमेल पता दर्ज करें';

  @override
  String get settingsVerificationCode => 'सत्यापन कोड';

  @override
  String get settingsVerificationCodeSent => 'सत्यापन कोड भेजा गया';

  @override
  String get settingsCodeSentTo => 'सत्यापन कोड भेजा गया';

  @override
  String get settingsDidNotReceiveCode => 'कोड प्राप्त नहीं हुआ?';

  @override
  String get settingsEmailChangedSuccess => 'ईमेल सफलतापूर्वक बदला गया';

  @override
  String get settingsChangeEmailFailed => 'ईमेल परिवर्तन विफल';

  @override
  String get settingsEmailSecurityNote =>
      'आपके ईमेल का उपयोग पासवर्ड पुनर्प्राप्ति के लिए किया जाता है. कृपया इसे सुरक्षित रखें.';

  @override
  String get commonGoogleLogin => 'Google से साइन इन करें';

  @override
  String get commonAppleLogin => 'Apple के साथ साइन इन करें';

  @override
  String get commonWechat => 'WeChat';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsLanguageChanged => 'भाषा बदल गई';

  @override
  String get settingsTranslation => 'अनुवाद';

  @override
  String get settingsTranslateTextTo => 'पाठ का अनुवाद करें';

  @override
  String get settingsTranslateDescription =>
      'वह भाषा चुनें जिसमें आप संदेशों का अनुवाद कराना चाहते हैं।';

  @override
  String get settingsAutoTranslate => 'प्राप्त संदेशों का स्वतः अनुवाद करें';

  @override
  String get settingsAutoTranslateDescription =>
      'चैट में प्राप्त संदेशों का स्वचालित रूप से आपकी चयनित भाषा में अनुवाद करें।';

  @override
  String get settingsBiometricLogin => 'बायोमेट्रिक लॉगिन';

  @override
  String authLoginWithBiometric(Object type) {
    return '$type से लॉगिन करें';
  }

  @override
  String get settingsBiometricLoginEnabled => 'बायोमेट्रिक लॉगिन सक्षम';

  @override
  String get settingsBiometricLoginDisabled => 'बायोमेट्रिक लॉगिन अक्षम';

  @override
  String get settingsEnableBiometricLogin => 'बायोमेट्रिक लॉगिन सक्षम करें';

  @override
  String get settingsBiometricEnabled =>
      'सक्षम - लॉगिन करने के लिए बायोमेट्रिक का उपयोग करें';

  @override
  String get settingsBiometricDisabled => 'अक्षम - सक्षम करने के लिए टैप करें';

  @override
  String get settingsBiometricNeedRelogin =>
      'बायोमेट्रिक लॉगिन सक्षम करने के लिए कृपया लॉग आउट करें और दोबारा लॉग इन करें';

  @override
  String get authOr => 'या';

  @override
  String get qrcodeCameraPermissionRestricted =>
      'इस डिवाइस पर कैमरे का उपयोग प्रतिबंधित है';

  @override
  String get authPasskeyLabel => 'पासकी';

  @override
  String get authGoogleLabel => 'गूगल';

  @override
  String get authAppleLabel => 'सेब';


  @override
  String get authSsoNotConfigured => 'इस सर्वर ने SSO लॉगिन प्रदाता कॉन्फ़िगर नहीं किए हैं';
  @override
  String get authSsoLabel => 'एसएसओ';

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
      'पोक प्रत्यय दर्ज करें, जैसे: कंधे पर';

  @override
  String get groupAlbum => 'समूह एलबम';

  @override
  String get groupFiles => 'समूह फ़ाइलें';

  @override
  String get groupImages => 'छवियाँ';

  @override
  String get groupVideos => 'वीडियो';

  @override
  String get groupTotal => 'कुल';

  @override
  String get groupSize => 'आकार';

  @override
  String get groupNoMedia => 'कोई मीडिया नहीं';

  @override
  String get groupNoMediaDescription =>
      'इस समूह में अभी तक कोई फ़ोटो या वीडियो नहीं है';

  @override
  String get groupDocuments => 'दस्तावेज़';

  @override
  String get groupNoFiles => 'कोई फ़ाइलें नहीं';

  @override
  String get groupNoFilesDescription => 'इस समूह में अभी तक कोई फ़ाइल नहीं है';

  @override
  String groupDownloadStarted(String filename) {
    return 'डाउनलोड हो रहा है $filename...';
  }

  @override
  String get contactNoCommonGroups => 'कोई सामान्य समूह नहीं';

  @override
  String get contactNoCommonGroupsDescription =>
      'आपके पास कोई समान समूह नहीं है';

  @override
  String get chatVoiceMessage => 'आवाज';

  @override
  String get chatMessage => 'संदेश';

  @override
  String get conversationHideChat => 'छिपाओ';

  @override
  String get settingsQuickReply => 'त्वरित उत्तर';

  @override
  String get commonTranslate => 'अनुवाद करें';

  @override
  String get contactCreateTag => 'टैग बनाएं';

  @override
  String get contactEnterTagName => 'टैग नाम दर्ज करें';

  @override
  String get contactEditTag => 'टैग संपादित करें';

  @override
  String get contactDeleteTag => 'टैग हटाएँ';

  @override
  String contactDeleteTagConfirm(String tagName) {
    return 'क्या आप वाकई \"$tagName\" टैग हटाना चाहते हैं?';
  }

  @override
  String get contactNoTags => 'अभी तक कोई टैग नहीं';

  @override
  String get contactFriendPermissions => 'मित्र अनुमतियाँ';

  @override
  String get contactSetChatOnly => 'केवल चैट के रूप में सेट करें';

  @override
  String get contactChatOnlyDesc =>
      'केवल आपसे चैट कर सकते हैं, अन्य सामग्री छिपी रहेगी';

  @override
  String get contactHideMyMoments => 'मेरे क्षण छिपाएँ';

  @override
  String get contactHideMyMomentsDesc => 'यह मित्र मेरे क्षण नहीं देख सकता';

  @override
  String get contactHideTheirMoments => 'उनके पल छुपाएं';

  @override
  String get contactHideTheirMomentsDesc => 'इस मित्र के क्षण न देखें';

  @override
  String get contactHideMyStatus => 'मेरी स्थिति छिपाएँ';

  @override
  String get contactHideMyStatusDesc =>
      'यह मित्र मेरा स्टेटस अपडेट नहीं देख सकता';

  @override
  String get contactNoChatOnlyFriends => 'केवल चैट करने वाले मित्र नहीं';

  @override
  String get contactNoOfficialAccounts => 'कोई आधिकारिक खाता नहीं';

  @override
  String get contactFollowOfficialAccountsDesc =>
      'नवीनतम अपडेट प्राप्त करने के लिए आधिकारिक खातों का अनुसरण करें';

  @override
  String get contactNoServiceAccounts => 'कोई सेवा खाता नहीं';

  @override
  String get contactSubscribeServiceAccountsDesc =>
      'सुविधाजनक सेवाओं के लिए सेवा खातों की सदस्यता लें';

  @override
  String get contactNoEnterpriseContacts => 'कोई उद्यम संपर्क नहीं';

  @override
  String get contactEnterpriseContactsDesc =>
      'एंटरप्राइज़ संपर्क यहां प्रदर्शित किए जाएंगे';

  @override
  String get profileCardPack => 'कार्ड पैक';

  @override
  String get profileOrders => 'आदेश';

  @override
  String get profileNoOrders => 'कोई आदेश नहीं';

  @override
  String get profileOrdersDesc => 'आपके ऑर्डर यहां प्रदर्शित किए जाएंगे';

  @override
  String get profileNoCards => 'कोई कार्ड नहीं';

  @override
  String get profileCardsDesc => 'आपके कार्ड यहां प्रदर्शित होंगे';

  @override
  String get favoriteEnterTagsHint => 'अल्पविराम से अलग किए गए टैग दर्ज करें';

  @override
  String get favoriteTagsUpdated => 'टैग अपडेट किए गए';

  @override
  String get favoriteForwardedContent => 'सामग्री अग्रेषित की गई';

  @override
  String get favoriteEnterNoteContent => 'नोट सामग्री दर्ज करें';

  @override
  String get favoriteNoteAdded => 'नोट जोड़ा गया';

  @override
  String get favoriteLinkTitle => 'लिंक शीर्षक';

  @override
  String get favoriteLinkUrl => 'https://';

  @override
  String get favoriteLinkAdded => 'लिंक जोड़ा गया';

  @override
  String get contactPhotoAdded => 'फोटो जोड़ा गया';

  @override
  String get contactEnterPhone => 'फ़ोन नंबर दर्ज करें';

  @override
  String commonConversationWithId(String roomId) {
    return 'बातचीत: $roomId';
  }

  @override
  String commonContactWithId(String userId) {
    return 'संपर्क करें: $userId';
  }

  @override
  String get commonDiscover => 'खोजें';

  @override
  String commonDeveloping(String title) {
    return '$title\n(जल्द ही आ रहा है)';
  }

  @override
  String get commonPageNotFound => 'पेज नहीं मिला';

  @override
  String get commonBackToHome => 'घर वापस';

  @override
  String get settingsMessageNotifications => 'संदेश सूचनाएं';

  @override
  String get settingsReceiveNewMessageNotifications =>
      'नए संदेश सूचनाएं प्राप्त करें';

  @override
  String get settingsShowMessagePreview => 'संदेश पूर्वावलोकन दिखाएँ';

  @override
  String get settingsShowMessageContentInNotification =>
      'अधिसूचना में संदेश सामग्री दिखाएँ';

  @override
  String get settingsNotificationSound => 'अधिसूचना ध्वनि';

  @override
  String get settingsPlaySoundOnMessage => 'संदेश प्राप्त करते समय ध्वनि बजाएं';

  @override
  String get commonVibration => 'कंपन';

  @override
  String get settingsVibrateOnMessage => 'संदेश प्राप्त करते समय कंपन करें';

  @override
  String get settingsDoNotDisturbMode => 'परेशान मत करो';

  @override
  String get settingsDoNotDisturbDescription =>
      'निर्दिष्ट समय के दौरान सूचनाएं प्राप्त न करें';

  @override
  String get settingsStartTime => 'प्रारंभ समय';

  @override
  String get settingsEndTime => 'समाप्ति समय';

  @override
  String get settingsDeleteQuickReply => 'त्वरित उत्तर हटाएँ';

  @override
  String get settingsEditQuickReply => 'त्वरित उत्तर संपादित करें';

  @override
  String get settingsAddQuickReply => 'त्वरित उत्तर जोड़ें';

  @override
  String get settingsManageQuickReplies => 'त्वरित उत्तर प्रबंधित करें';

  @override
  String get settingsNoQuickReplies => 'कोई त्वरित उत्तर नहीं';

  @override
  String get settingsDefaultQuickReplies =>
      'डिफ़ॉल्ट त्वरित उत्तर दिखाए जाएंगे';

  @override
  String get settingsWhoCanSee => 'कौन देख सकता है';

  @override
  String get settingsLastSeen => 'अंतिम बार देखा गया';

  @override
  String get settingsHiddenChats => 'छुपी हुई चैट';

  @override
  String get settingsMessagesLabel => 'संदेश';

  @override
  String get settingsAllowStrangerMessages => 'अजनबी संदेशों को अनुमति दें';

  @override
  String get settingsReceiveMessagesFromNonContacts =>
      'गैर-संपर्कों से संदेश प्राप्त करें';

  @override
  String get settingsReadReceipts => 'रसीदें पढ़ें';

  @override
  String get settingsLetOthersKnowYouRead => 'दूसरों को बताएं कि आप पढ़ते हैं';

  @override
  String get settingsTypingIndicator => 'टाइपिंग सूचक';

  @override
  String get settingsLetOthersKnowYouTyping =>
      'दूसरों को बताएं कि आप टाइप कर रहे हैं';

  @override
  String get settingsEveryone => 'हर कोई';

  @override
  String get settingsContactsOnly => 'केवल संपर्क';

  @override
  String get settingsNobody => 'कोई नहीं';

  @override
  String settingsWhoCanSeeTitle(String title) {
    return '$title को कौन देख सकता है';
  }

  @override
  String settingsVersionInfo(String version) {
    return 'संस्करण $version';
  }

  @override
  String get settingsCheckForUpdates => 'अपडेट के लिए जांचें';

  @override
  String get settingsOpenSourceLicenses => 'ओपन सोर्स लाइसेंस';

  @override
  String get settingsFeedbackAndSuggestions => 'प्रतिक्रिया और सुझाव';

  @override
  String get settingsBuiltOnMatrix => 'मैट्रिक्स प्रोटोकॉल पर निर्मित';

  @override
  String get settingsNoHiddenChats => 'कोई छिपी हुई चैट नहीं';

  @override
  String get settingsNoHiddenChatsDescription =>
      'आपके द्वारा छिपाई गई चैट यहां दिखाई देंगी';

  @override
  String get settingsUnhideChat => 'उजागर करें';

  @override
  String get settingsDarkMode => 'डार्क मोड';

  @override
  String get settingsFontSize => 'फ़ॉन्ट आकार';

  @override
  String get settingsBubbleStyle => 'बुलबुला शैली';

  @override
  String get settingsFollowSystem => 'सिस्टम का पालन करें';

  @override
  String get settingsAutoSwitchBySystem => 'सिस्टम द्वारा ऑटो स्विच';

  @override
  String get settingsLightMode => 'लाइट मोड';

  @override
  String get settingsAlwaysUseLightTheme => 'हमेशा लाइट थीम का प्रयोग करें';

  @override
  String get settingsDarkModeOption => 'डार्क मोड विकल्प';

  @override
  String get settingsAlwaysUseDarkTheme => 'हमेशा डार्क थीम का इस्तेमाल करें';

  @override
  String get settingsFontSizeSmall => 'छोटा';

  @override
  String get settingsFontSizeStandard => 'मानक';

  @override
  String get settingsFontSizeLarge => 'बड़ा';

  @override
  String get settingsFontSizeExtraLarge => 'अतिरिक्त बड़ा';

  @override
  String get settingsBubbleStyleWechat => 'WeChat शैली';

  @override
  String get settingsBubbleStyleWechatDesc => 'क्लासिक WeChat बुलबुला शैली';

  @override
  String get settingsBubbleStyleModern => 'आधुनिक शैली';

  @override
  String get settingsBubbleStyleModernDesc => 'स्वच्छ आधुनिक बुलबुला शैली';

  @override
  String get settingsBubbleStyleClassic => 'क्लासिक शैली';

  @override
  String get settingsBubbleStyleClassicDesc => 'पारंपरिक बुलबुला शैली';

  @override
  String get discoverVideoChannels => 'चैनल';

  @override
  String get discoverLive => 'जियो';

  @override
  String get discoverListen => 'सुनो';

  @override
  String get discoverWatch => 'देखो';

  @override
  String get discoverSearchDiscover => 'खोजें';

  @override
  String get discoverNearbyPeople => 'पास में';

  @override
  String get discoverGames => 'खेल';

  @override
  String get discoverMiniPrograms => 'लघु कार्यक्रम';

  @override
  String get chatAlreadyInCall => 'पहले से ही एक कॉल में';

  @override
  String get commonConnectionFailed => 'कनेक्शन विफल';

  @override
  String get chatCallRejected => 'कॉल अस्वीकृत';

  @override
  String get chatNoAnswer => 'कोई जवाब नहीं';

  @override
  String get commonClose => 'बंद करें';

  @override
  String get chatSelectContact => 'संपर्क चुनें';

  @override
  String get chatVoteRemoved => 'वोट हटा दिया गया';

  @override
  String get chatVoteChanged => 'वोट बदल गया';

  @override
  String get chatVoted => 'मतदान किया';

  @override
  String chatReplyTo(String name) {
    return '$name का उत्तर दें';
  }

  @override
  String get chatCurrentLocation => 'वर्तमान स्थान';

  @override
  String chatNearbyPlace(int index) {
    return 'निकटवर्ती स्थान $index';
  }

  @override
  String chatApproximateDistance(String distance) {
    return '$distance के बारे में';
  }

  @override
  String get chatAddress => 'पता';

  @override
  String get chatLatitude => 'अक्षांश';

  @override
  String get chatLongitude => 'देशांतर';

  @override
  String get groupDescriptionUpdated => 'समूह विवरण अपडेट किया गया';

  @override
  String get groupAvatarUpdated => 'समूह अवतार अद्यतन किया गया';

  @override
  String get groupVisibilityUpdated => 'समूह दृश्यता अद्यतन की गई';

  @override
  String get groupChannelCreated => 'चैनल बनाया गया';

  @override
  String get groupChannelUpdated => 'चैनल अपडेट किया गया';

  @override
  String get groupChannelDeleted => 'चैनल हटा दिया गया';

  @override
  String get callDecline => 'अस्वीकार';

  @override
  String get callAnswer => 'उत्तर';

  @override
  String get callIncomingVideoCall => 'इनकमिंग वीडियो कॉल';

  @override
  String get callIncomingVoiceCall => 'इनकमिंग वॉयस कॉल';

  @override
  String get callVideoCallInProgress => 'वीडियो कॉल चल रही है';

  @override
  String get callVoiceCallInProgress => 'वॉइस कॉल प्रगति पर है';

  @override
  String get callReconnectingCall => 'पुनः कनेक्ट हो रहा है...';

  @override
  String get callEnded => 'कॉल समाप्त हो गई';

  @override
  String get callFailed => 'कॉल विफल';

  @override
  String get callLivekitNotConfigured => 'LiveKit कॉन्फ़िगर नहीं किया गया';

  @override
  String callJoinMeetingFailed(String error) {
    return 'मीटिंग में शामिल होने में विफल: $error';
  }

  @override
  String callScreenShareFailed(String error) {
    return 'स्क्रीन शेयर विफल: $error';
  }

  @override
  String get profileN42BeanTitle => 'N42 बीन';

  @override
  String get profileNoN42Bean => 'कोई N42 बीन नहीं';

  @override
  String get profileN42BeanDetails => 'N42 बीन विवरण';

  @override
  String get profileN42BeanDescription =>
      'N42 बीन एक टोकन है जिसका उपयोग N42 में आभासी वस्तुओं और सेवाओं को भुनाने के लिए किया जाता है। वर्तमान में इसके लिए उपलब्ध है:';

  @override
  String get profileN42BeanFeature1 => 'विशिष्ट सदस्य स्टिकर और थीम';

  @override
  String get profileN42BeanFeature2 => 'चैट बबल अनुकूलन';

  @override
  String get profileN42BeanFeature3 => 'लाल पैकेट कवर अनुकूलन';

  @override
  String get profileN42BeanFeature4 => 'विशिष्ट उपनाम बैज';

  @override
  String get profileN42BeanFeature5 => 'समूह चैट विशेषाधिकार';

  @override
  String get profileN42BeanFeature6 => 'क्लाउड स्टोरेज का विस्तार';

  @override
  String get profileN42BeanFeature7 => 'वीडियो कॉल सौंदर्य फिल्टर';

  @override
  String get profileN42BeanFeature8 => 'क्षण पृष्ठभूमि अनुकूलन';

  @override
  String get profileN42BeanFeature9 => 'वीआईपी ग्राहक सेवा प्राथमिकता';

  @override
  String get profileGotIt => 'समझ गया';

  @override
  String get profileNoN42BeanRecords => 'कोई N42 बीन रिकॉर्ड नहीं';

  @override
  String get profileMoodAndThoughts => 'मनोदशा एवं विचार';

  @override
  String get profileStatusHappy => 'खुश';

  @override
  String get profileStatusCracked => 'बिखरा हुआ';

  @override
  String get profileStatusLucky => 'भाग्यशाली';

  @override
  String get profileStatusSunny => 'सनी';

  @override
  String get profileStatusTired => 'थका हुआ';

  @override
  String get profileStatusDaydream => 'दिवास्वप्न';

  @override
  String get profileStatusRushing => 'दौड़ना';

  @override
  String get profileStatusOverthinking => 'ज़्यादा सोचना';

  @override
  String get profileStatusEnergized => 'ऊर्जावान';

  @override
  String get profileWorkAndStudy => 'काम और अध्ययन';

  @override
  String get profileStatusWorking => 'कार्य करना';

  @override
  String get profileStatusStudying => 'पढ़ाई';

  @override
  String get profileStatusBusy => 'व्यस्त';

  @override
  String get profileStatusSlacking => 'ढिलाई करना';

  @override
  String get profileStatusTraveling => 'यात्रा';

  @override
  String get profileStatusGoingHome => 'घर जा रहे हैं';

  @override
  String get profileStatusDnd => 'परेशान मत करो';

  @override
  String get profileActivities => 'गतिविधियाँ';

  @override
  String get profileStatusHanging => 'बाहर घूमना';

  @override
  String get profileStatusCheckIn => 'चेक इन करें';

  @override
  String get profileStatusExercising => 'व्यायाम करना';

  @override
  String get profileStatusCoffee => 'कॉफ़ी';

  @override
  String get profileStatusBubbleTea => 'बुलबुला चाय';

  @override
  String get profileStatusEating => 'खाना';

  @override
  String get profileStatusParenting => 'पालन-पोषण';

  @override
  String get profileStatusSavingWorld => 'विश्व को बचाना';

  @override
  String get profileStatusSelfie => 'सेल्फी';

  @override
  String get profileRest => 'आराम करो';

  @override
  String get profileStatusRetreat => 'पीछे हटना';

  @override
  String get profileStatusHome => 'घर';

  @override
  String get profileStatusSleeping => 'सो रहा है';

  @override
  String get profileStatusCatLover => 'बिल्ली प्रेमी';

  @override
  String get profileStatusDogWalking => 'चलने वाला कुत्ता';

  @override
  String get profileStatusGaming => 'गेमिंग';

  @override
  String get profileStatusListening => 'सुनना';

  @override
  String get profileEditAddress => 'पता संपादित करें';

  @override
  String get profileRecipient => 'प्राप्तकर्ता';

  @override
  String get profileEnterRecipientName => 'प्राप्तकर्ता का नाम दर्ज करें';

  @override
  String get profilePhoneNumber => 'फ़ोन नंबर';

  @override
  String get profileEnterPhoneNumber => 'फ़ोन नंबर दर्ज करें';

  @override
  String get profileRegionHint => 'प्रांत/शहर/जिला';

  @override
  String get profileDetailedAddress => 'विस्तृत पता';

  @override
  String get profileDetailedAddressHint => 'सड़क, भवन संख्या, आदि।';

  @override
  String get profileSetAsDefaultAddress => 'डिफ़ॉल्ट पते के रूप में सेट करें';

  @override
  String get profilePleaseCompleteInfo => 'कृपया सभी फ़ील्ड पूर्ण करें';

  @override
  String get profileEditInvoice => 'चालान संपादित करें';

  @override
  String get profileInvoiceType => 'चालान प्रकार';

  @override
  String get profileCompanyName => 'कंपनी का नाम';

  @override
  String get profilePersonalName => 'व्यक्तिगत नाम';

  @override
  String get profileEnterCompanyName => 'कंपनी का नाम दर्ज करें';

  @override
  String get profileEnterName => 'नाम दर्ज करें';

  @override
  String get profileTaxIdNumber => 'टैक्स आईडी नंबर';

  @override
  String get profileEnterTaxIdNumber => 'टैक्स आईडी नंबर दर्ज करें';

  @override
  String get profileBankNameOptional => 'बैंक का नाम (वैकल्पिक)';

  @override
  String get profileEnterBankName => 'बैंक का नाम दर्ज करें';

  @override
  String get profileBankAccountOptional => 'बैंक खाता (वैकल्पिक)';

  @override
  String get profileEnterBankAccount => 'बैंक खाता दर्ज करें';

  @override
  String get profileCompanyAddressOptional => 'कंपनी का पता (वैकल्पिक)';

  @override
  String get profileEnterCompanyAddress => 'कंपनी का पता दर्ज करें';

  @override
  String get profileCompanyPhoneOptional => 'कंपनी फ़ोन (वैकल्पिक)';

  @override
  String get profileEnterCompanyPhone => 'कंपनी का फ़ोन दर्ज करें';

  @override
  String get profileSetAsDefaultInvoice => 'डिफ़ॉल्ट चालान के रूप में सेट करें';

  @override
  String get profileRingtoneVibrate => 'कंपन';

  @override
  String get profileRingtoneSilent => 'चुप';

  @override
  String get profileVibrateMode => 'कंपन मोड';

  @override
  String get profileSilentMode => 'मौन मोड';

  @override
  String profilePlayFailed(String ringtoneName) {
    return 'चलाने में विफल: $ringtoneName';
  }

  @override
  String profilePlaying(String ringtoneName) {
    return 'बजाना: $ringtoneName';
  }

  @override
  String get profileStop => 'रुकें';

  @override
  String get profileSelectRingtone => 'रिंगटोन चुनें';

  @override
  String get profileLoadingRingtones => 'रिंगटोन लोड हो रहा है...';

  @override
  String get profileNoRingtonesFound => 'कोई रिंगटोन नहीं मिला';

  @override
  String mainMessagesWithCount(int count) {
    return 'संदेश($count)';
  }

  @override
  String get storyViewers => 'दर्शक';

  @override
  String get storyNoViewers => 'अभी तक कोई दर्शक नहीं';

  @override
  String get storyReplyToStory => 'कहानी का उत्तर दें...';

  @override
  String get commonCopiedToClipboard => 'क्लिपबोर्ड पर कॉपी किया गया';

  @override
  String get commonMore => 'अधिक';

  @override
  String get commonTranslating => 'अनुवाद हो रहा है...';

  @override
  String commonTranslatedFrom(String language) {
    return '$language से अनुवादित';
  }

  @override
  String get commonTranslation => 'अनुवाद';

  @override
  String get commonTranslationFailed => 'अनुवाद विफल';

  @override
  String get commonAllRead => 'सभी पढ़ें';

  @override
  String commonReadCount(int count) {
    return '$count पढ़ें';
  }

  @override
  String get commonYouRecalledMessage => 'आपको एक संदेश याद आया';

  @override
  String get commonMessageRecalled => 'संदेश याद किया गया';

  @override
  String get commonReEdit => 'पुनः संपादित करें';

  @override
  String get commonWalletArea => 'बटुआ क्षेत्र';

  @override
  String get callIncomingCall => 'इनकमिंग कॉल';

  @override
  String get callMissedCall => 'मिस्ड कॉल';

  @override
  String get groupRemoveAdmin => 'व्यवस्थापक हटाएँ';

  @override
  String get chatSelectCurrency => 'मुद्रा चुनें';

  @override
  String get chatSelectEmoji => 'इमोजी चुनें';

  @override
  String get chatSelectRedPacketCover => 'कवर का चयन करें';

  @override
  String get groupSetAsAdmin => 'व्यवस्थापक के रूप में सेट करें';

  @override
  String get chatVideoPlaybackFailed => 'वीडियो प्लेबैक विफल रहा';

  @override
  String get groupViewProfile => 'प्रोफ़ाइल देखें';

  @override
  String get favoriteAddLinkComingSoon => 'लिंक जोड़ें सुविधा जल्द ही आ रही है';

  @override
  String get favoriteNewNoteComingSoon => 'नया नोट फीचर जल्द ही आ रहा है';

  @override
  String get qrcodeSaveFeatureComingSoon => 'सेव सुविधा जल्द ही आ रही है';

  @override
  String get qrcodeShareFeatureComingSoon => 'शेयर सुविधा जल्द ही आ रही है';

  @override
  String qrcodeProcessFailed(String error) {
    return 'QR कोड संसाधित करने में विफल: $error';
  }

  @override
  String get securityDeviceIdRequired => 'डिवाइस आईडी आवश्यक है';

  @override
  String securityVerificationStartFailed(String error) {
    return 'सत्यापन प्रारंभ करने में विफल: $error';
  }

  @override
  String get securityVerificationFailed => 'सत्यापन विफल रहा';

  @override
  String securityVerificationFailedWithReason(String reason) {
    return 'सत्यापन विफल: $reason';
  }

  @override
  String get securityEmojiMismatchRejected =>
      'सत्यापन अस्वीकृत - इमोजी मेल नहीं खाता';

  @override
  String get securityWaitingForDeviceAccept =>
      'अन्य डिवाइस के स्वीकार करने की प्रतीक्षा की जा रही है...';

  @override
  String get securityVerifyDevice => 'इस डिवाइस को सत्यापित करें';

  @override
  String get securityConfirmEmojiMatch =>
      'पुष्टि करें कि नीचे दिए गए इमोजी दोनों डिवाइसों पर एक ही क्रम में प्रदर्शित होते हैं';

  @override
  String get securityEmojiDontMatch => 'वे मेल नहीं खाते';

  @override
  String get securityEmojiMatch => 'वे मेल खाते हैं';

  @override
  String get securityWaitingForDeviceConfirm =>
      'अन्य डिवाइस की पुष्टि की प्रतीक्षा की जा रही है...';

  @override
  String get securityVerificationSuccess => 'सत्यापन सफल!';

  @override
  String get securityDeviceVerifiedTrusted =>
      'यह डिवाइस अब सत्यापित और विश्वसनीय है.';

  @override
  String get securityCompareEmoji => 'दोनों डिवाइस पर इमोजी की तुलना करें';

  @override
  String get securityCompareNumbers =>
      'दोनों डिवाइसों पर संख्याओं की तुलना करें';

  @override
  String get commonTryAgain => 'पुनः प्रयास करें';

  @override
  String get commonDone => 'हो गया';

  @override
  String get chatExportTitle => 'चैट निर्यात करें';

  @override
  String get chatExportSuccess => 'निर्यात सफल';

  @override
  String chatExportFailed(String error) {
    return 'निर्यात विफल: $error';
  }

  @override
  String get chatExportFormat => 'निर्यात प्रारूप';

  @override
  String get chatExportHtmlDesc =>
      'स्टाइल लेआउट वाले किसी भी ब्राउज़र में पढ़ने योग्य';

  @override
  String get chatExportJsonDesc => 'मशीन-पठनीय संरचित डेटा प्रारूप';

  @override
  String get chatExportDateRange => 'दिनांक सीमा';

  @override
  String get chatExportAll => 'सभी संदेश';

  @override
  String get chatExportLastWeek => 'पिछले 7 दिन';

  @override
  String get chatExportLastMonth => 'पिछले महीने';

  @override
  String get chatExportLast3Months => 'पिछले 3 महीने';

  @override
  String get chatExportMessageCount => 'निर्यात करने के लिए संदेश';

  @override
  String get chatExportButton => 'निर्यात एवं साझा करें';

  @override
  String get chatMediaGallery => 'मीडिया गैलरी';

  @override
  String get chatExportHistory => 'चैट इतिहास निर्यात करें';

  @override
  String get pdfLoadFailed => 'पीडीएफ लोड करने में विफल';

  @override
  String pdfPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get mediaAll => 'सब';

  @override
  String get mediaImages => 'छवियाँ';

  @override
  String get mediaVideos => 'वीडियो';

  @override
  String get mediaFiles => 'फ़ाइलें';

  @override
  String get mediaAudio => 'ऑडियो';

  @override
  String mediaItemsCount(int count) {
    return '$count आइटम';
  }

  @override
  String get mediaNoMediaFound => 'कोई मीडिया नहीं मिला';

  @override
  String get spacesTitle => 'समुदाय';

  @override
  String get spacesCreate => 'समुदाय बनाएं';

  @override
  String get spacesJoined => 'सम्मिलित हुए';

  @override
  String get spacesDiscover => 'खोजें';

  @override
  String get spacesNoJoined => 'अभी तक कोई समुदाय शामिल नहीं हुआ';

  @override
  String get spacesExplore => 'समुदायों का अन्वेषण करें';

  @override
  String get spacesNoPublic => 'कोई सार्वजनिक समुदाय नहीं मिला';

  @override
  String get spacesJoin => 'सम्मिलित हों';

  @override
  String get spacesSubSpaces => 'उप-समुदाय';

  @override
  String get spacesChannels => 'चैनल';

  @override
  String spacesMembersCount(int count) {
    return '$count सदस्य';
  }

  @override
  String get spacesPublic => 'सार्वजनिक';

  @override
  String get spacesPrivate => 'निजी';

  @override
  String get spacesSuggested => 'सुझाव दिया';

  @override
  String spacesChannelsCount(int count) {
    return '$count चैनल';
  }

  @override
  String get callInCallChat => 'इन-कॉल चैट';

  @override
  String callMessagesCount(int count) {
    return '$count संदेश';
  }

  @override
  String get callNoMessagesYet =>
      'अभी तक कोई संदेश नहीं.\nआरंभ करने के लिए एक संदेश भेजें.';

  @override
  String get callTypeMessage => 'एक संदेश टाइप करें...';

  @override
  String get callYouSender => 'आप';

  @override
  String get callChatLabel => 'बातचीत';

  @override
  String get chatEdited => 'संपादित';

  @override
  String get chatEditHistory => 'इतिहास संपादित करें';

  @override
  String get chatOriginalMessage => 'मौलिक';

  @override
  String chatEditedAt(String time) {
    return '$time पर संपादित';
  }

  @override
  String get chatViewOnce => 'एक बार देखें';

  @override
  String get chatViewOncePhoto => 'एक बार फोटो देखें';

  @override
  String get chatViewOnceVideo => 'एक बार वीडियो देखें';

  @override
  String get chatViewOnceViewed => 'देखा';

  @override
  String get chatViewOnceExpired => 'समाप्त हो गया';

  @override
  String get chatViewOnceTap => 'देखने के लिए टैप करें';

  @override
  String get chatAutoFaceBlur => 'ऑटो फेस ब्लर';

  @override
  String get chatAutoFaceBlurDesc =>
      'फ़ोटो भेजते समय चेहरे स्वचालित रूप से धुंधले हो जाते हैं';

  @override
  String get threadReplyInThread => 'थ्रेड में उत्तर दें';

  @override
  String threadReplies(int count) {
    return '$count उत्तर देता है';
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
  String get threadReplyPlaceholder => 'थ्रेड में उत्तर दें...';

  @override
  String threadParticipants(int count) {
    return '$count प्रतिभागी';
  }

  @override
  String get voiceRoomTitle => 'आवाज कक्ष';

  @override
  String get voiceRoomCreate => 'वॉइस रूम बनाएं';

  @override
  String get voiceRoomJoin => 'सम्मिलित हों';

  @override
  String get voiceRoomLeave => 'छोड़ो';

  @override
  String get voiceRoomEnd => 'अंत कक्ष';

  @override
  String get voiceRoomRaiseHand => 'हाथ उठाओ';

  @override
  String get voiceRoomLowerHand => 'निचला हाथ';

  @override
  String get voiceRoomMute => 'मूक';

  @override
  String get voiceRoomUnmute => 'अनम्यूट करें';

  @override
  String get voiceRoomHost => 'मेज़बान';

  @override
  String get voiceRoomSpeakers => 'वक्ता';

  @override
  String get voiceRoomListeners => 'श्रोता';

  @override
  String get voiceRoomLive => 'लाइव';

  @override
  String get voiceRoomEnded => 'समाप्त';

  @override
  String get voiceRoomScheduled => 'अनुसूचित';

  @override
  String get voiceRoomApprove => 'स्वीकृत करें';

  @override
  String get voiceRoomDemote => 'श्रोता की ओर बढ़ें';

  @override
  String voiceRoomHandRaised(String name) {
    return '$name ने अपना हाथ उठाया';
  }

  @override
  String get voiceRoomName => 'कमरे का नाम';

  @override
  String get voiceRoomTopic => 'विषय (वैकल्पिक)';

  @override
  String get voiceRoomNoActive => 'कोई सक्रिय वॉयस रूम नहीं';

  @override
  String get voiceRoomConnecting => 'कनेक्ट हो रहा है...';

  @override
  String get usernameTitle => 'उपयोगकर्ता नाम';

  @override
  String get usernameSet => 'उपयोगकर्ता नाम सेट करें';

  @override
  String get usernameChange => 'उपयोगकर्ता नाम बदलें';

  @override
  String get usernamePlaceholder => 'उपयोक्तानाम दर्ज करें';

  @override
  String get usernameAvailable => 'उपयोगकर्ता नाम उपलब्ध है';

  @override
  String get usernameUnavailable => 'उपयोगकर्ता नाम पहले ही लिया जा चुका है';

  @override
  String get usernameInvalid =>
      '3-30 अक्षर, छोटे अक्षर, संख्याएँ, अंडरस्कोर। एक अक्षर से शुरू करना चाहिए.';

  @override
  String get usernameReserved => 'यह उपयोक्तानाम आरक्षित है';

  @override
  String get usernameSaved => 'उपयोक्तानाम सहेजा गया';

  @override
  String get usernameSearchHint => '@उपयोगकर्ता नाम से खोजें';

  @override
  String get ensName => 'ईएनएस नाम';

  @override
  String get ensLinked => 'ईएनएस से जुड़ा हुआ';

  @override
  String get ensResolving => 'ईएनएस का समाधान किया जा रहा है...';

  @override
  String get ensNotFound => 'ईएनएस नाम नहीं मिला';

  @override
  String get tokenGateTitle => 'टोकन गेट';

  @override
  String get tokenGateEnable => 'टोकन गेट सक्षम करें';

  @override
  String get tokenGateDisable => 'टोकन गेट अक्षम करें';

  @override
  String get tokenGateAddRule => 'नियम जोड़ें';

  @override
  String get tokenGateRemoveRule => 'नियम हटाएँ';

  @override
  String get tokenGateContractAddress => 'अनुबंध का पता';

  @override
  String get tokenGateMinBalance => 'न्यूनतम शेष';

  @override
  String get tokenGateTokenId => 'टोकन आईडी (ईआरसी-1155)';

  @override
  String get tokenGateChainId => 'चेन आईडी';

  @override
  String get tokenGateVerifying =>
      'टोकन होल्डिंग्स का सत्यापन किया जा रहा है...';

  @override
  String get tokenGateVerified => 'सत्यापन पारित हो गया';

  @override
  String get tokenGateDenied => 'आप टोकन आवश्यकताओं को पूरा नहीं करते हैं';

  @override
  String get tokenGateOperatorAnd => 'सभी नियमों को पूरा करना होगा';

  @override
  String get tokenGateOperatorOr => 'किसी भी नियम को पूरा करना होगा';

  @override
  String get tokenGateRuleErc20 => 'ईआरसी-20 टोकन';

  @override
  String get tokenGateRuleErc721 => 'एनएफटी (ईआरसी-721)';

  @override
  String get tokenGateRuleErc1155 => 'मल्टी-टोकन (ईआरसी-1155)';

  @override
  String get tokenGateRuleNative => 'मूल टोकन';

  @override
  String get tokenGateSaved => 'टोकन गेट सहेजा गया';

  @override
  String get tokenGateEnableDescription =>
      'सदस्यों को शामिल होने के लिए टोकन रखना आवश्यक है';

  @override
  String get tokenGateOperator => 'नियम तर्क';

  @override
  String get tokenGateRules => 'नियम';

  @override
  String get tokenGateSymbol => 'प्रतीक (वैकल्पिक)';

  @override
  String get tokenGateChain => 'जंजीर';

  @override
  String get tokenGateTokenStandard => 'टोकन मानक';

  @override
  String get tokenGateDenialMessage => 'इनकार संदेश';

  @override
  String get tokenGateDenialMessageHint =>
      'सत्यापन विफल होने पर संदेश दिखाया जाता है';

  @override
  String get tokenGateVerifyTitle => 'टोकन सत्यापन';

  @override
  String get tokenGateVerifyPassed => 'सत्यापन उत्तीर्ण';

  @override
  String get tokenGateVerifyFailed => 'सत्यापन विफल';

  @override
  String get tokenGateRetryVerify => 'पुनः प्रयास करें';

  @override
  String get tokenGateRequired => 'आवश्यक';

  @override
  String get tokenGateYourBalance => 'आपका संतुलन';

  @override
  String get tokenGateRulesActive => 'नियम सक्रिय';

  @override
  String get tokenGateDisabled => 'विकलांग';

  @override
  String get ensNotBound => 'बाध्य नहीं';

  @override
  String get liveLocation => 'लाइव लोकेशन';

  @override
  String get stopLiveLocation => 'साझा करना बंद करें';

  @override
  String get startLiveLocation => 'साझा करना प्रारंभ करें';

  @override
  String get selectDuration => 'अवधि चुनें';

  @override
  String get groupChatFiles => 'चैट फ़ाइलें';

  @override
  String get groupLinks => 'कड़ियाँ';

  @override
  String get groupNoLinks => 'अभी तक कोई लिंक नहीं';

  @override
  String get chatBackground => 'चैट पृष्ठभूमि';

  @override
  String get solidColors => 'ठोस रंग';

  @override
  String get gradients => 'स्नातक';

  @override
  String get defaultBackground => 'डिफ़ॉल्ट';

  @override
  String get settingsFontSizeSlider => 'फ़ॉन्ट आकार';

  @override
  String get autoDownload => 'स्वतः डाउनलोड';

  @override
  String get images => 'छवियाँ';

  @override
  String get voice => 'आवाज';

  @override
  String get video => 'वीडियो';

  @override
  String get files => 'फ़ाइलें';

  @override
  String get mobileData => 'मोबाइल डेटा';

  @override
  String get roaming => 'घूमना';

  @override
  String get storageManagement => 'भंडारण';

  @override
  String get totalUsage => 'कुल उपयोग';

  @override
  String get cache => 'कैश';

  @override
  String get other => 'अन्य';

  @override
  String get clearCache => 'कैश साफ़ करें';

  @override
  String get cacheCleared => 'कैश साफ़ किया गया';

  @override
  String get clearCacheFailed => 'कैश साफ़ करने में विफल';

  @override
  String get confirmClearCache => 'सभी कैश डेटा साफ़ करें?';

  @override
  String get mapView => 'मानचित्र दृश्य';

  @override
  String liveLocationSharingCount(int count) {
    return '$count लोग स्थान साझा कर रहे हैं';
  }

  @override
  String get minutes15 => '15 मिनट';

  @override
  String get minutes30 => '30 मिनट';

  @override
  String get hour1 => '1 घंटा';

  @override
  String get hours8 => '8 घंटे';

  @override
  String get personalCard => 'व्यक्तिगत कार्ड';

  @override
  String get downloadFailed => 'डाउनलोड विफल रहा';

  @override
  String get locationExpired => 'समाप्त हो गया';

  @override
  String secondsRemaining(int count) {
    return '$count सेकंड';
  }

  @override
  String minutesRemaining(int count) {
    return '$count मिनट';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '$hours घंटे $minutes मिनट';
  }

  @override
  String get favoriteMessages => 'पसंदीदा';

  @override
  String get linksCopied => 'लिंक कॉपी किया गया';

  @override
  String get noLinksFound => 'कोई लिंक नहीं मिला';

  @override
  String get roomStorageRanking => 'कक्ष भंडारण रैंकिंग';

  @override
  String get downloadComplete => 'पूरा डाउनलोड करें';

  @override
  String get downloading => 'डाउनलोड हो रहा है...';

  @override
  String get draftSaved => 'ड्राफ्ट सहेजा गया';

  @override
  String get voiceRecording => 'आवाज रिकार्डिंग';

  @override
  String get searchLocation => 'स्थान खोजें';

  @override
  String get tapToSearch => 'खोजने के लिए टैप करें';

  @override
  String get settingsThisDevice => 'यह उपकरण';

  @override
  String get settingsJustNow => 'अभी अभी';

  @override
  String get settingsDeviceId => 'डिवाइस आईडी';

  @override
  String get settingsStatus => 'स्थिति';

  @override
  String get settingsLastActive => 'अंतिम सक्रिय';

  @override
  String get settingsIpAddress => 'आईपी पता';

  @override
  String get settingsRenameDevice => 'डिवाइस का नाम बदलें';

  @override
  String get settingsDeviceNameHint => 'डिवाइस का नाम दर्ज करें';

  @override
  String get settingsDeviceRenamed => 'डिवाइस का नाम बदला गया';

  @override
  String get settingsRenameFailed => 'नाम बदलें विफल';

  @override
  String get settingsRemoteLogout => 'रिमोट लॉगआउट';

  @override
  String settingsRemoteLogoutConfirm(String deviceName) {
    return 'क्या आप वाकई \"$deviceName\" लॉग आउट करना चाहते हैं? इस एक्शन को वापस नहीं किया जा सकता।';
  }

  @override
  String get settingsDeviceLoggedOut => 'डिवाइस लॉग आउट हो गया';

  @override
  String get settingsLogoutFailed => 'लॉगआउट विफल';

  @override
  String get settingsLogout => 'लॉगआउट करें';

  @override
  String get settingsVerifyIdentity => 'पहचान सत्यापित करें';

  @override
  String get settingsEnterPasswordToConfirm =>
      'इस कार्रवाई की पुष्टि करने के लिए अपना पासवर्ड दर्ज करें।';

  @override
  String get scheduledSendTitle => 'संदेश शेड्यूल करें';

  @override
  String get scheduledSendInOneHour => '1 घंटे में';

  @override
  String get scheduledSendTonight => 'आज रात (8:00 बजे)';

  @override
  String get scheduledSendTomorrowMorning => 'कल सुबह (9:00 पूर्वाह्न)';

  @override
  String get scheduledSendCustom => 'कोई दिनांक और समय चुनें';

  @override
  String get scheduledMessageLabel => 'अनुसूचित';

  @override
  String get scheduledMessageCancel => 'निर्धारित संदेश रद्द करें';

  @override
  String get chatLockTitle => 'चैट लॉक';

  @override
  String get chatLockEnable => 'इस चैट को लॉक करें';

  @override
  String get chatLockDisable => 'इस चैट को अनलॉक करें';

  @override
  String get chatLockDescription =>
      'लॉक की गई चैट को खोलने के लिए बायोमेट्रिक या पिन सत्यापन की आवश्यकता होती है';

  @override
  String get chatLockVerifyTitle => 'चैट लॉक हो गई';

  @override
  String get chatLockVerifySubtitle => 'इस चैट तक पहुंचने के लिए सत्यापित करें';

  @override
  String get chatLockVerifyFailed => 'सत्यापन विफल रहा';

  @override
  String get chatLockEnabled => 'चैट लॉक हो गई';

  @override
  String get chatLockDisabled => 'चैट अनलॉक हो गई';

  @override
  String get chatLockPinTitle => 'पिन दर्ज करें';

  @override
  String get chatLockPinSetTitle => 'पिन सेट करें';

  @override
  String get chatLockPinConfirmTitle => 'पिन की पुष्टि करें';

  @override
  String get chatLockPinMismatch => 'पिन मेल नहीं खाता';

  @override
  String get chatLockUseBiometric => 'बायोमेट्रिक का प्रयोग करें';

  @override
  String get chatLockUsePin => 'पिन का प्रयोग करें';

  @override
  String get mediaEditorUndo => 'पूर्ववत करें';

  @override
  String get mediaEditorRedo => 'पुनः करें';

  @override
  String get mediaEditorCrop => 'फसल';

  @override
  String get mediaEditorFilter => 'फ़िल्टर करें';

  @override
  String get mediaEditorDraw => 'ड्रा';

  @override
  String get mediaEditorText => 'पाठ';

  @override
  String get aiAssistant => 'एआई सहायक';

  @override
  String get aiAssistantWelcome =>
      'नमस्ते! मैं N42 AI असिस्टेंट हूं। मैं आपकी कैसे मदद कर सकता हूँ?';

  @override
  String get aiAssistantNotConfigured => 'AI सेवा कॉन्फ़िगर नहीं की गई';

  @override
  String get aiAssistantSettings => 'एआई सेटिंग्स';

  @override
  String get aiAssistantClearHistory => 'चैट इतिहास साफ़ करें';

  @override
  String get aiAssistantClearHistoryConfirm =>
      'क्या आप वाकई सभी AI चैट इतिहास साफ़ करना चाहते हैं?';

  @override
  String get aiAssistantStopGenerating => 'उत्पादन बंद करो';

  @override
  String get aiAssistantModel => 'मॉडल';

  @override
  String get aiAssistantTemperature => 'तापमान';

  @override
  String get aiAssistantMaxTokens => 'अधिकतम टोकन';

  @override
  String get aiAssistantContextWindow => 'प्रसंग विंडो';

  @override
  String get aiAssistantServiceStatus => 'सेवा की स्थिति';

  @override
  String get aiAssistantAvailable => 'उपलब्ध';

  @override
  String get aiAssistantUnavailable => 'अनुपलब्ध';

  @override
  String get aiSummarize => 'एआई सारांश';

  @override
  String aiSummarizeUnread(int count) {
    return '$count अपठित संदेशों को सारांशित करें';
  }

  @override
  String get aiSummarizeLoading => 'संक्षेप में...';

  @override
  String get aiSummarizeError => 'सारांशित करने में विफल';

  @override
  String get aiRewrite => 'ऐ पुनर्लेखन';

  @override
  String get aiRewriteFormal => 'औपचारिक';

  @override
  String get aiRewriteCasual => 'आकस्मिक';

  @override
  String get aiRewritePlayful => 'चंचल';

  @override
  String get aiRewriteProfessional => 'पेशेवर';

  @override
  String get aiRewriteAccept => 'उपयोग करें';

  @override
  String get aiRewriteCancel => 'रद्द करें';

  @override
  String get aiRewriteLoading => 'पुनर्लेखन...';

  @override
  String get aiLinkSummary => 'एआई सारांश';

  @override
  String get aiLinkSummaryAnalyzing => 'विश्लेषण कर रहा हूँ...';

  @override
  String get chatFolderManagement => 'फ़ोल्डर प्रबंधित करें';

  @override
  String get chatFolderSystem => 'सिस्टम फ़ोल्डर';

  @override
  String get chatFolderCustom => 'कस्टम फ़ोल्डर';

  @override
  String get chatFolderEmpty => 'अभी तक कोई कस्टम फ़ोल्डर नहीं';

  @override
  String get chatFolderCreate => 'फ़ोल्डर बनाएँ';

  @override
  String get chatFolderEdit => 'फ़ोल्डर संपादित करें';

  @override
  String get chatFolderNameHint => 'फ़ोल्डर का नाम';

  @override
  String get chatFolderAll => 'सब';

  @override
  String get chatFolderUnread => 'अपठित';

  @override
  String get chatFolderPersonal => 'निजी';

  @override
  String get chatFolderGroups => 'समूह';

  @override
  String get chatFolderChannels => 'चैनल';

  @override
  String get chatFolderMuted => 'मौन';

  @override
  String get storyAddMusic => 'संगीत जोड़ें';

  @override
  String get storyChangeMusic => 'संगीत बदलें';

  @override
  String get storyBackgroundMusic => 'पृष्ठभूमि संगीत';

  @override
  String get storyMusicPreview => 'पूर्वावलोकन (अधिकतम 15 सेकंड)';

  @override
  String get storyChooseFromDevice => 'डिवाइस से चुनें';

  @override
  String get storyUseThisMusic => 'इस संगीत का प्रयोग करें';

  @override
  String get authPasskeyNotSupported => 'इस डिवाइस पर पासकी समर्थित नहीं है';

  @override
  String get authPasskeyRegister => 'पासकी पंजीकृत करें';

  @override
  String get authPasskeyNoRegistered => 'कोई पासकी पंजीकृत नहीं';

  @override
  String get authPasskeyRegisterHint =>
      'इस खाते के लिए एक पासकी पंजीकृत करें. स्टैंडअलोन पासकी साइन-इन बाद में सक्षम किया जाएगा।';

  @override
  String get authPasskeyNameYours => 'अपने पासकी को नाम दें';

  @override
  String get authPasskeyRegistered => 'पासकी इस खाते में सहेजी गई';

  @override
  String get authPasskeyDeleted => 'इस खाते से पासकी हटा दी गई';

  @override
  String authPasskeyDeleteConfirm(String name) {
    return 'पासकी \"$name\" हटाएं? बाद में पासकी साइन-इन का उपयोग करने से पहले आपको इसे फिर से पंजीकृत करना होगा।';
  }

  @override
  String get momentVisibilityPublic => 'सार्वजनिक';

  @override
  String get momentVisibilityPrivate => 'निजी';

  @override
  String get momentVisibilityPartial => 'चयनित मित्र';

  @override
  String get momentVisibilityExcluded => 'कुछ मित्रों को बाहर करें';

  @override
  String momentUserMoments(String userName) {
    return '$userName के क्षण';
  }

  @override
  String get momentForwardTo => 'को अग्रेषित करें';

  @override
  String get momentForwardSuccess => 'सफलतापूर्वक अग्रेषित किया गया';

  @override
  String get momentSelectFriends => 'मित्र चुनें';

  @override
  String get momentSelectTags => 'टैग द्वारा चयन करें';

  @override
  String momentSelectedCount(int count) {
    return 'चयनित ($count)';
  }

  @override
  String get momentNoMomentsYet => 'अभी तक कोई क्षण नहीं';

  @override
  String get momentForwardMoment => 'आगे का क्षण';

  @override
  String get momentAddComment => 'एक टिप्पणी जोड़ें...';

  @override
  String momentForwardContent(String content) {
    return '[क्षण] $content';
  }

  @override
  String get momentDeleteMoment => 'क्षण हटाएँ';

  @override
  String get momentDeleteConfirm => 'क्या आप वाकई इस क्षण को हटाना चाहते हैं?';

  @override
  String get momentComment => 'टिप्पणी करें';

  @override
  String get momentWriteComment => 'एक टिप्पणी लिखें...';

  @override
  String get momentLike => 'जैसे';

  @override
  String get momentUnlike => 'भिन्न';

  @override
  String get momentForward => 'आगे';

  @override
  String get momentDelete => 'हटाएँ';

  @override
  String get momentReply => 'उत्तर';

  @override
  String get momentMoment => 'पल';

  @override
  String momentLikesCount(int count) {
    return '$count को पसंद है';
  }

  @override
  String momentCommentsCount(int count) {
    return '$count टिप्पणियाँ';
  }

  @override
  String get momentNoComments => 'अभी तक कोई टिप्पणी नहीं';

  @override
  String get momentFailedToLoad => 'छवि लोड करने में विफल';

  @override
  String momentReplyTo(String userName) {
    return '$userName का उत्तर दें...';
  }

  @override
  String get momentNoConversations => 'कोई बातचीत नहीं';

  @override
  String get momentJustNow => 'अभी अभी';

  @override
  String momentMinutesAgo(int count) {
    return '${count}m पहले';
  }

  @override
  String momentHoursAgo(int count) {
    return '${count}h पहले';
  }

  @override
  String momentDaysAgo(int count) {
    return '${count}d पहले';
  }

  @override
  String get chatGroupAnnouncementHint => 'समूह घोषणा दर्ज करें';

  @override
  String get chatGroupAnnouncementEmpty => 'कोई घोषणा नहीं';

  @override
  String get chatEditNickname => 'उपनाम संपादित करें';

  @override
  String get chatNicknameHint => 'इस समूह में अपना उपनाम दर्ज करें';

  @override
  String get contactAddPhoneHint => 'फ़ोन नंबर दर्ज करें';

  @override
  String get contactNotesHint => 'इस संपर्क के बारे में नोट्स जोड़ें';

  @override
  String get reportTitle => 'रिपोर्ट करें';

  @override
  String get reportReasonSpam => 'स्पैम';

  @override
  String get reportReasonHarassment => 'उत्पीड़न';

  @override
  String get reportReasonFraud => 'धोखाधड़ी';

  @override
  String get reportReasonOther => 'अन्य';

  @override
  String get reportSubmitted => 'रिपोर्ट सौंपी गई';

  @override
  String get reportDescription => 'अतिरिक्त विवरण (वैकल्पिक)';

  @override
  String get qrcodeSaved => 'क्यूआर कोड एल्बम में सहेजा गया';

  @override
  String get chatSendRedPacketInChat => 'कृपया चैट में लाल पैकेट भेजें';

  @override
  String get commonSaveFailed => 'सहेजना विफल';

  @override
  String get reportSelectReason => 'कृपया कोई कारण चुनें';

  @override
  String get gameCenter => 'खेल';

  @override
  String get gameHighScore => 'सर्वोत्तम';

  @override
  String get gameScore => 'स्कोर';

  @override
  String get gameOver => 'खेल ख़त्म';

  @override
  String get gamePlayAgain => 'फिर से खेलें';

  @override
  String get gameLeaderboard => 'लीडरबोर्ड';

  @override
  String get gamePause => 'रुका हुआ';

  @override
  String get gameResume => 'फिर से शुरू करने के लिए टैप करें';

  @override
  String get gameConfirmExit => 'यह खेल छोड़ें?';

  @override
  String get gameNoScores => 'अभी तक कोई अंक नहीं';

  @override
  String get game2048 => '2048';

  @override
  String get game2048Desc => '2048 तक पहुंचने के लिए टाइल्स को मर्ज करें';

  @override
  String get gameBlockDrop => 'ब्लॉक ड्रॉप';

  @override
  String get gameBlockDropDesc => 'रेखाएं गिराएं और साफ़ करें';

  @override
  String get gameMinesweeper => 'माइनस्वीपर';

  @override
  String get gameMinesweeperDesc => 'सभी सुरक्षित सेल ढूंढें';

  @override
  String get gameMatch3 => 'मैच 3';

  @override
  String get gameMatch3Desc => '3 या अधिक रत्नों का मिलान करें';

  @override
  String get gameMinesweeperEasy => 'आसान';

  @override
  String get gameMinesweeperMedium => 'मध्यम';

  @override
  String get gameMinesLeft => 'माइन्स लेफ्ट';

  @override
  String get gameTimeLeft => 'समय';

  @override
  String get gameLevel => 'स्तर';

  @override
  String get gameNext => 'अगला';

  @override
  String get gameBestTime => 'सर्वोत्तम समय';

  @override
  String get gameNewRecord => 'नया रिकॉर्ड!';

  @override
  String get gameLines => 'पंक्तियाँ';

  @override
  String get storyMyStory => 'मेरी कहानी';

  @override
  String get storageSmartCleanup => 'स्मार्ट सफाई';

  @override
  String get storageOldMediaFiles => 'पुरानी मीडिया फ़ाइलें';

  @override
  String get storageLargeFiles => 'बड़ी फ़ाइलें';

  @override
  String get storageAppCache => 'ऐप कैश';

  @override
  String get storageSettings => 'भंडारण सेटिंग्स';

  @override
  String get storageAutoCleanup => 'ऑटो सफाई';

  @override
  String storageAutoCleanupDesc(int days) {
    return '$days दिनों से अधिक पुरानी फ़ाइलों को स्वचालित रूप से साफ़ करें';
  }

  @override
  String get storageCleanupPeriod => 'सफ़ाई अवधि';

  @override
  String get storagePreserveThumbnails => 'थंबनेल सुरक्षित रखें';

  @override
  String get storagePreserveThumbnailsDesc => 'सफ़ाई के दौरान छवि थंबनेल रखें';

  @override
  String get storageWarningHigh =>
      'भंडारण का उपयोग अधिक है. पुरानी फ़ाइलों को साफ़ करने पर विचार करें.';

  @override
  String get storageWarningCritical =>
      'भंडारण अत्यंत कम है. कृपया खाली स्थान तक सफाई करें।';

  @override
  String storageFreed(String size, int count) {
    return 'मुक्त $size ($count फ़ाइलें)';
  }

  @override
  String storageDays(int days) {
    return '$days दिन';
  }

  @override
  String storageViewAllRooms(int count) {
    return 'सभी $count कमरे देखें';
  }

  @override
  String get storageNoFiles => 'कोई फ़ाइल नहीं मिली';

  @override
  String get storageFilePinned => 'पिन किया गया';

  @override
  String storageDeleteSelected(int count) {
    return '$count चयनित फ़ाइलें हटाएं? इन्हें सर्वर से पुनः डाउनलोड किया जा सकता है।';
  }

  @override
  String get backupRestore => 'बैकअप और पुनर्स्थापना';

  @override
  String get backupCreate => 'बैकअप बनाएं';

  @override
  String get backupCreateDesc =>
      'अपनी सेटिंग्स और एन्क्रिप्शन कुंजियों का बैकअप लें। दोबारा लॉगिन करने के बाद सर्वर से संदेश बहाल हो जाएंगे।';

  @override
  String get backupIncludeKeys => 'एन्क्रिप्शन कुंजी शामिल करें';

  @override
  String get backupIncludeKeysDesc =>
      'एन्क्रिप्टेड संदेशों को पढ़ने के लिए आवश्यक';

  @override
  String get backupPasswordProtect => 'पासवर्ड सुरक्षित रखें';

  @override
  String get backupEnterPassword => 'बैकअप पासवर्ड दर्ज करें';

  @override
  String get backupHistory => 'बैकअप इतिहास';

  @override
  String get backupNoBackups => 'अभी तक कोई बैकअप नहीं है';

  @override
  String get backupRestore2 => 'पुनर्स्थापित करें';

  @override
  String get backupDelete => 'हटाएँ';

  @override
  String get backupDeleteConfirm =>
      'क्या आप वाकई इस बैकअप को हटाना चाहते हैं? इसे असंपादित नहीं किया जा सकता है।';

  @override
  String get backupRestoreFromFile => 'फ़ाइल से पुनर्स्थापित करें';

  @override
  String get backupRestoreFromFileDesc =>
      'किसी अन्य डिवाइस या पिछले बैकअप से .n42backup फ़ाइल आयात करें।';

  @override
  String get backupChooseFile => 'बैकअप फ़ाइल चुनें';

  @override
  String get backupRestoring => 'पुनर्स्थापित किया जा रहा है...';

  @override
  String backupCreated(int rooms, int messages) {
    return 'बैकअप बनाया गया: $rooms कमरे, $messages संदेश';
  }

  @override
  String backupRestored(int settings, int rooms) {
    return '$rooms कमरों से $settings सेटिंग्स पुनर्स्थापित की गईं';
  }

  @override
  String backupFailed(String error) {
    return 'बैकअप विफल: $error';
  }

  @override
  String get backupPasswordRequired => 'यह बैकअप पासवर्ड से सुरक्षित है';

  @override
  String get blocGroupNotFound => 'समूह नहीं मिला';

  @override
  String blocGroupMembersInvited(int count) {
    return 'आमंत्रित $count सदस्य';
  }

  @override
  String get blocGroupMemberRemoved => 'सदस्य हटा दिया गया';

  @override
  String get blocGroupAdminRemoved => 'व्यवस्थापक हटा दिया गया';

  @override
  String get blocGroupLeft => 'समूह छोड़ दिया';

  @override
  String get blocGroupDisbanded => 'समूह भंग';

  @override
  String get blocGroupJoined => 'समूह में शामिल हो गए';

  @override
  String get blocGroupInviteDeclined => 'निमंत्रण अस्वीकार कर दिया गया';

  @override
  String get blocGroupTokenGateUpdated => 'टोकन गेट अपडेट किया गया';

  @override
  String get blocTransferProcessing => 'स्थानांतरण संसाधित किया जा रहा है...';

  @override
  String get blocTransferCancelled => 'स्थानांतरण रद्द कर दिया गया';

  @override
  String get blocTransferFailed => 'स्थानांतरण विफल रहा';

  @override
  String get blocPaymentProcessing => 'भुगतान संसाधित हो रहा है...';

  @override
  String get blocPaymentFailed => 'भुगतान विफल';

  @override
  String get groupMaxMembers => 'सदस्य सीमा';

  @override
  String get groupMaxMembersUnlimited => 'असीमित';

  @override
  String get groupMaxMembersHint =>
      'सीमा दर्ज करें (असीमित के लिए खाली छोड़ें)';

  @override
  String get groupMaxMembersUpdated => 'सदस्य सीमा अद्यतन की गई';

  @override
  String get groupFull => 'समूह क्षमता पर है';

  @override
  String get groupChannels => 'विषय चैनल';

  @override
  String get groupChannelsEmpty => 'अभी तक कोई चैनल नहीं';

  @override
  String get groupChannelsCount => 'चैनल';

  @override
  String get groupChannelCreate => 'नया चैनल';

  @override
  String get groupChannelName => 'चैनल का नाम';

  @override
  String get groupChannelTopic => 'चैनल विषय (वैकल्पिक)';

  @override
  String get groupChannelDelete => 'चैनल हटाएं';

  @override
  String get groupChannelDeleteConfirm =>
      'यह चैनल हटाएं? सभी संदेश खो जायेंगे.';

  @override
  String get groupBotSettings => 'बॉट सेटिंग्स';

  @override
  String get groupBotEnabled => 'बॉट सक्षम करें';

  @override
  String get groupBotWelcomeMessage => 'स्वागत संदेश टेम्पलेट';

  @override
  String get groupBotWelcomeHint =>
      'नए सदस्य के नाम के लिए प्लेसहोल्डर के रूप में \'नाम\' का उपयोग करें';

  @override
  String get groupBotConfigUpdated => 'बॉट सेटिंग्स अपडेट की गईं';

  @override
  String get groupContentFilter => 'सामग्री फ़िल्टर';

  @override
  String get groupContentFilterEnabled => 'कीवर्ड फ़िल्टर सक्षम करें';

  @override
  String get groupContentFilterReplace => '*** से बदलें';

  @override
  String get groupContentFilterHide => 'संदेश छिपाएँ';

  @override
  String get groupContentFilterAddWord => 'कीवर्ड जोड़ें';

  @override
  String get groupContentFilterUpdated => 'सामग्री फ़िल्टर अपडेट किया गया';

  @override
  String get chatSlashCommands => 'आदेश';

  @override
  String get chatCommandPoll => '/पोल - एक पोल बनाएं';

  @override
  String get chatCommandAnnounce => '/घोषणा - घोषणा भेजें';

  @override
  String get chatCommandWelcome => '/स्वागत - स्वागत संदेश सेट करें';

  @override
  String get chatReportMessage => 'रिपोर्ट करें';

  @override
  String get chatReportReason => 'कारण रिपोर्ट करें';

  @override
  String get chatReportSpam => 'स्पैम';

  @override
  String get chatReportHarassment => 'उत्पीड़न';

  @override
  String get chatReportInappropriate => 'अनुपयुक्त सामग्री';

  @override
  String get chatReportOther => 'अन्य';

  @override
  String get chatReportSuccess => 'रिपोर्ट सौंपी गई';

  @override
  String get spacesName => 'समुदाय का नाम';

  @override
  String get spacesNameHint => 'जैसे क्रिप्टो ट्रेडर्स';

  @override
  String get spacesNameRequired => 'नाम आवश्यक है';

  @override
  String get spacesDescription => 'विवरण';

  @override
  String get spacesDescriptionHint => 'यह समुदाय किस बारे में है?';

  @override
  String get spacesType => 'सामुदायिक प्रकार';

  @override
  String get spacesPublicDesc => 'कोई भी खोज सकता है और शामिल हो सकता है';

  @override
  String get spacesPrivateDesc => 'केवल आमंत्रित सदस्य ही शामिल हो सकते हैं';

  @override
  String get spacesNotFound => 'समुदाय नहीं मिला';

  @override
  String get spacesSearch => 'समुदाय खोजें...';

  @override
  String get spacesMembers => 'सदस्य';

  @override
  String get spacesNoChannels => 'अभी तक कोई चैनल नहीं';

  @override
  String get spacesLeave => 'समुदाय छोड़ें';

  @override
  String spacesLeaveConfirm(String name) {
    return 'क्या आप वाकई \"$name\" छोड़ना चाहते हैं?';
  }

  @override
  String get spacesDelete => 'समुदाय हटाएँ';

  @override
  String spacesDeleteConfirm(String name) {
    return 'यह \"$name\" और उसके सभी चैनलों को स्थायी रूप से हटा देगा। इस एक्शन को वापस नहीं किया जा सकता।';
  }

  @override
  String get spacesCreateChannel => 'चैनल जोड़ें';

  @override
  String get spacesChannelName => 'चैनल का नाम';

  @override
  String get spacesChannelTopic => 'विषय (वैकल्पिक)';

  @override
  String get spacesDeleteChannel => 'चैनल हटाएं';

  @override
  String spacesDeleteChannelConfirm(String name) {
    return 'क्या आप वाकई \"#$name\" को हटाना चाहते हैं?';
  }

  @override
  String get spacesEditName => 'नाम संपादित करें';

  @override
  String get spacesEditDescription => 'विवरण संपादित करें';

  @override
  String spacesViewAllMembers(int count) {
    return 'सभी $count सदस्यों को देखें';
  }

  @override
  String spacesKickMemberTitle(String name) {
    return '$name को किक करें';
  }

  @override
  String spacesBanMemberTitle(String name) {
    return '$name पर प्रतिबंध लगाएं';
  }

  @override
  String get spacesPromoteAdmin => 'व्यवस्थापक के लिए प्रचार करें';

  @override
  String get spacesDemoteAdmin => 'व्यवस्थापक हटाएँ';

  @override
  String get spacesInviteMember => 'सदस्य को आमंत्रित करें';

  @override
  String get spacesInviteMemberUserId =>
      'उपयोगकर्ता आईडी (जैसे @user:server.com)';

  @override
  String get spacesSave => 'सहेजें';

  @override
  String get settingsScreenshotProtection => 'स्क्रीनशॉट सुरक्षा';

  @override
  String get settingsScreenshotProtectionDesc =>
      'स्क्रीनशॉट और स्क्रीन रिकॉर्डिंग रोकें';

  @override
  String get chatSelfDestructTimer => 'आत्म-विनाश';

  @override
  String get chatTimerPickerTitle => 'स्व-विनाशकारी टाइमर';

  @override
  String get chatTimerOff => 'बंद';

  @override
  String get onChainNotificationsTitle => 'ऑन-चेन इवेंट';

  @override
  String get onChainMarkAllRead => 'सभी पढ़े गए को चिह्नित करें';

  @override
  String get onChainNoNotifications => 'अभी तक कोई ऑन-चेन इवेंट नहीं';

  @override
  String get onChainNoNotificationsDesc =>
      'सब्स्क्राइब्ड चैनलों के इवेंट यहां दिखाई देंगे';

  @override
  String get onChainViewDetails => 'विवरण देखें';

  @override
  String get chatCommandHelp => '/सहायता - सभी आदेश दिखाएँ';

  @override
  String get chatCommandPrice => '/ कीमत - टोकन मूल्य प्राप्त करें';

  @override
  String get chatCommandBalance => '/बैलेंस - वॉलेट बैलेंस दिखाएं';

  @override
  String get chatCommandChains =>
      '/चेन - 236+ समर्थित श्रृंखलाओं की सूची बनाएं';

  @override
  String get chatMiniApps => 'ऐप्स';

  @override
  String get miniAppMarketTitle => 'मिनी ऐप्स';

  @override
  String get miniAppCategoryAll => 'सब';

  @override
  String get miniAppSearch => 'ऐप्स खोजें...';

  @override
  String get miniAppFeatured => 'विशेष रुप से प्रदर्शित';

  @override
  String get miniAppAllApps => 'सभी ऐप्स';

  @override
  String get miniAppNoResults => 'कोई ऐप्स नहीं मिला';

  @override
  String get slideToPayLabel => '→→→ पुष्टि करने के लिए स्लाइड करें';

  @override
  String get slideToPayConfirming => 'पुष्टि की जा रही है...';

  @override
  String get redPacketBestLuck => 'शुभकामनाएँ';

  @override
  String get redPacketBestLuckCongrats => 'शुभकामनाएँ! आपको सबसे ज्यादा मिला!';

  @override
  String redPacketStats(int claimed, int total) {
    return '$claimed / $total दावा किया गया';
  }

  @override
  String get redPacketStatsTotal => 'कुल';

  @override
  String redPacketGrabbedViral(String amount, String token) {
    return '🧧 ने एक लाल पैकेट उठाया • $amount $token';
  }

  @override
  String get web3SearchHint => '@मैट्रिक्स:आईडी • 0x वॉलेट पता • name.eth';

  @override
  String get web3SearchPlaceholder => 'आईडी, वॉलेट या ईएनएस द्वारा खोजें...';

  @override
  String get web3WalletAddress => 'बटुआ पता';

  @override
  String get web3AddressCopied => 'पता कॉपी किया गया';

  @override
  String get web3Copy => 'प्रतिलिपि';

  @override
  String get web3SendMessage => 'संदेश भेजें';

  @override
  String get web3SendToWallet => 'संदेश बटुआ';

  @override
  String get web3WalletOnlyHint =>
      'इस पते पर अभी तक कोई N42 खाता नहीं है. उनके शामिल होने पर संदेश भेजा जाएगा.';

  @override
  String get web3NftAvatar => 'एनएफटी अवतार';

  @override
  String get web3ResolveFailed => 'पहचान का समाधान करने में विफल';

  @override
  String web3EnsNotFound(String name) {
    return 'ENS नाम \"$name\" नहीं मिला';
  }

  @override
  String get web3NoN42AccountTitle => 'कोई N42 खाता नहीं';

  @override
  String get web3NoN42AccountDesc =>
      'इस वॉलेट पते पर अभी तक कोई N42 खाता नहीं है। आरंभ करने के लिए आप अपना N42 आमंत्रण लिंक उनके साथ साझा कर सकते हैं।';

  @override
  String get web3ShareInvite => 'आमंत्रण साझा करें';

  @override
  String get nftPickerTitle => 'एनएफटी अवतार चुनें';

  @override
  String get nftPickerTabPopular => 'लोकप्रिय';

  @override
  String get nftPickerTabCustom => 'कस्टम';

  @override
  String get nftPickerChain => 'जंजीर';

  @override
  String get nftPickerContract => 'अनुबंध का पता';

  @override
  String get nftPickerTokenId => 'टोकन आईडी';

  @override
  String get nftPickerVerifyOwnership =>
      'स्वामित्व सत्यापित करें और पूर्वावलोकन करें';

  @override
  String get nftPickerUseAsAvatar => 'अवतार के रूप में प्रयोग करें';

  @override
  String get nftPickerPreview => 'पूर्वावलोकन';

  @override
  String get nftPickerNotOwned => 'आपके पास यह एनएफटी नहीं है';

  @override
  String get nftPickerInvalidTokenId => 'अमान्य टोकन आईडी';

  @override
  String get nftPickerEnterBoth => 'अनुबंध का पता और टोकन आईडी दर्ज करें';

  @override
  String get nftPickerInfoTitle => 'एनएफटी अवतार - सत्यापित ऑन-चेन';

  @override
  String get nftPickerInfoDesc =>
      'अपने पास मौजूद एनएफटी को अपने अवतार के रूप में बांधें। कोई भी ऑन-चेन स्वामित्व सत्यापित कर सकता है। N42 पर एक सोने की अंगूठी के साथ प्रदर्शित।';

  @override
  String get nftPickerPopularCollections => 'लोकप्रिय संग्रह';

  @override
  String get nftPickerWalletHint =>
      '236+ श्रृंखलाओं में अपने एनएफटी को स्वचालित रूप से खोजने के लिए अपने एन42 वॉलेट को कनेक्ट करें।';

  @override
  String get profileBindNftAvatar => 'बाइंड एनएफटी अवतार';

  @override
  String get profileChangeAvatar => 'अवतार बदलें';

  @override
  String get groupTopics => 'विषय';

  @override
  String get groupTopicsEmpty => 'अभी तक कोई विषय नहीं';

  @override
  String get syncInProgress => 'संदेश इतिहास समन्वयित किया जा रहा है...';

  @override
  String get recoveryKeyReminderTitle => 'अपने संदेशों को सुरक्षित रखें';

  @override
  String get recoveryKeyReminderDesc =>
      'एन्क्रिप्टेड संदेशों को सभी डिवाइसों में सुरक्षित रूप से सिंक करने के लिए एक पुनर्प्राप्ति कुंजी बनाएं';

  @override
  String get recoveryKeySetupNow => 'अभी सेट करें';

  @override
  String get recoveryKeyRemindLater => 'मुझे बाद में याद दिलाना';

  @override
  String get channelReadOnly => 'इस चैनल में केवल एडमिन ही पोस्ट कर सकते हैं';

  @override
  String get channelSubscribers => 'ग्राहक';

  @override
  String get channelVerified => 'सत्यापित चैनल';

  @override
  String get redPacketHistory => 'लाल पैकेट का इतिहास';

  @override
  String get redPacketSent => 'भेजा गया';

  @override
  String get redPacketReceived => 'प्राप्त हुआ';

  @override
  String get redPacketExpired => 'समाप्त हो गया';

  @override
  String get redPacketClaimed => 'दावा किया';

  @override
  String get redPacketInsufficientBalance => 'अपर्याप्त संतुलन';

  @override
  String selfDestructCountdown(String time) {
    return '$time में आत्म-विनाश';
  }

  @override
  String get messageDestroyed => 'संदेश नष्ट हो गया';

  @override
  String miniAppPermissionDenied(String permission) {
    return 'अनुमति अस्वीकृत: $permission';
  }

  @override
  String get aiSuggestionGasFee => 'गैस शुल्क क्या है?';

  @override
  String get aiSuggestionDefi => 'डेफी शुरुआती गाइड';

  @override
  String get aiSuggestionSecurity => 'अनुबंध सुरक्षा की जांच कैसे करें';

  @override
  String get aiSuggestionBridge => 'क्रॉस-चेन ब्रिजिंग';

  @override
  String get channelDiscoverTitle => 'चैनल खोजें';

  @override
  String get channelDiscoverSearch => 'चैनल खोजें...';

  @override
  String get channelJoin => 'सम्मिलित हों';

  @override
  String get channelJoined => 'सम्मिलित हुए';

  @override
  String get channelCategory => 'श्रेणी';

  @override
  String slowModeCooldown(int seconds) {
    return 'धीमा मोड: ${seconds}s प्रतीक्षा करें';
  }

  @override
  String get addressCopyAction => 'पता कॉपी करें';

  @override
  String get addressSendMessage => 'संदेश भेजें';

  @override
  String get addressViewProfile => 'प्रोफ़ाइल देखें';

  @override
  String get sendToAddress => 'वॉलेट पते पर भेजें';

  @override
  String get blocAuthSendVerificationCodeFailed => 'सत्यापन कोड भेजने में विफल';

  @override
  String get blocAuthServerNoEmailPasswordReset =>
      'यह सर्वर ईमेल पासवर्ड रीसेट का समर्थन नहीं करता है';

  @override
  String get blocAuthResetPasswordFailed => 'पासवर्ड रीसेट करने में विफल';

  @override
  String get blocAuthChangePasswordFailed => 'पासवर्ड बदलने में विफल';

  @override
  String get blocAuthOldPasswordWrong => 'ग़लत वर्तमान पासवर्ड';

  @override
  String get blocAuthLoginCancelled => 'लॉगिन रद्द कर दिया गया';

  @override
  String get blocAuthGoogleLoginFailed => 'Google लॉगिन विफल रहा';

  @override
  String get blocAuthAppleLoginFailed => 'Apple लॉगिन विफल रहा';

  @override
  String get blocAuthSsoLoginFailed => 'SSO लॉगिन विफल रहा';

  @override
  String get blocAuthFacebookLoginFailed => 'फेसबुक लॉगिन विफल रहा';

  @override
  String get blocAuthTwitterLoginFailed => 'ट्विटर लॉगिन विफल रहा';

  @override
  String get blocAuthWeChatLoginFailed => 'WeChat लॉगिन विफल रहा';

  @override
  String get blocAuthWeChatNotConfigured =>
      'WeChat लॉगिन कॉन्फ़िगर नहीं किया गया';

  @override
  String get blocAuthWeChatNotInstalled => 'कृपया पहले WeChat इंस्टॉल करें';

  @override
  String get blocAuthPasswordWrong => 'ग़लत पासवर्ड';

  @override
  String get blocAuthEmailAlreadyBound =>
      'यह ईमेल पहले से ही दूसरे खाते से जुड़ा हुआ है';

  @override
  String get blocAuthChangeEmailFailed => 'ईमेल बदलने में विफल';

  @override
  String get blocAuthVerificationCodeInvalid =>
      'सत्यापन कोड ग़लत है या समाप्त हो गया है';

  @override
  String get blocAuthSessionExpired =>
      'सत्र समाप्त हो गया, कृपया पुनः लॉगिन करें';

  @override
  String get blocAuthSessionIncomplete =>
      'सत्र डेटा अधूरा, कृपया पुनः लॉगिन करें';
}
