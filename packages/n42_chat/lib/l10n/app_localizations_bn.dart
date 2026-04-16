// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class SBn extends S {
  SBn([String locale = 'bn']) : super(locale);

  @override
  String get commonRetry => 'আবার চেষ্টা করুন';

  @override
  String get commonUnknownUser => 'অজানা ব্যবহারকারী';

  @override
  String get transferWalletNotConnected => 'ওয়ালেট সংযুক্ত নয়৷';

  @override
  String get chatCallServiceNotInitialized => 'কল পরিষেবা আরম্ভ করা হয়নি';

  @override
  String authLoginFailed(String error) {
    return 'লগইন ব্যর্থ হয়েছে: $error';
  }

  @override
  String get chatCallBack => 'কল ব্যাক';

  @override
  String get chatMissedVideoCall => 'মিসড ভিডিও কল';

  @override
  String get chatMissedVoiceCall => 'মিসড ভয়েস কল';

  @override
  String get chatCallNotAnswered => 'উত্তর দেওয়া হয়নি';

  @override
  String get chatCallDurationLabel => 'কলের সময়কাল';

  @override
  String get chatVoiceCallCancelled => 'ভয়েস কল বাতিল করা হয়েছে৷';

  @override
  String get chatVideoCallCancelled => 'ভিডিও কল বাতিল করা হয়েছে৷';

  @override
  String get commonImage => '[ছবি]';

  @override
  String get chatVideo => '[ভিডিও]';

  @override
  String get chatVoice => '[কণ্ঠ]';

  @override
  String get commonFile => '[ফাইল]';

  @override
  String get chatLocation => '[অবস্থান]';

  @override
  String get chatUnknownMessage => '[অজানা বার্তা]';

  @override
  String get commonDelete => 'মুছুন';

  @override
  String get chatDeleteThisMessage => 'এই বার্তাটি মুছবেন?';

  @override
  String get chatMessageDeleted => 'বার্তা মুছে ফেলা হয়েছে';

  @override
  String get profileNotLoggedIn => 'লগ ইন করা হয়নি';

  @override
  String get chatMyLocation => 'আমার অবস্থান';

  @override
  String get commonGroupChat => 'গ্রুপ চ্যাট';

  @override
  String get commonSearch => 'অনুসন্ধান করুন';

  @override
  String get commonCancel => 'বাতিল করুন';

  @override
  String get commonLoadFailed => 'লোড করতে ব্যর্থ হয়েছে';

  @override
  String get commonMessages => 'বার্তা';

  @override
  String get commonContacts => 'পরিচিতি';

  @override
  String get commonMe => 'আমি';

  @override
  String get commonVoiceLoading =>
      'ভয়েস লোড হচ্ছে, অনুগ্রহ করে পরে আবার চেষ্টা করুন';

  @override
  String get commonVoiceToTextFailed => 'ভয়েস টু টেক্সট ব্যর্থ হয়েছে';

  @override
  String get commonConvertToText => 'টেক্সট করতে';

  @override
  String get chatCopy => 'কপি';

  @override
  String get commonForward => 'ফরোয়ার্ড';

  @override
  String get commonUnfavorite => 'আনফাভ';

  @override
  String get commonFavorite => 'প্রিয়';

  @override
  String get settingsResend => 'আবার পাঠান';

  @override
  String get chatRecall => 'স্মরণ করুন';

  @override
  String get commonQuote => 'উদ্ধৃতি';

  @override
  String get commonRemind => 'মনে করিয়ে দিন';

  @override
  String get chatCopied => 'কপি করা হয়েছে';

  @override
  String get storySendMessageHint => 'একটি বার্তা পাঠান';

  @override
  String get commonMicrophonePermissionRequired =>
      'অনুগ্রহ করে মাইক্রোফোনের অনুমতি দিন';

  @override
  String get chatMicrophonePermissionDeniedPermanent =>
      'মাইক্রোফোন অনুমতি অস্বীকার করা হয়েছে. ভয়েস বার্তাগুলি ব্যবহার করতে দয়া করে সিস্টেম সেটিংসে এটি সক্ষম করুন৷';

  @override
  String commonStartRecordingFailed(String error) {
    return 'রেকর্ডিং শুরু করতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String get commonRecordingTooShort => 'রেকর্ডিং খুব ছোট';

  @override
  String commonStopRecordingFailed(String error) {
    return 'রেকর্ডিং বন্ধ করতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String get chatReleaseToCancel => 'বাতিল করতে রিলিজ করুন';

  @override
  String get chatReleaseToSend =>
      'পাঠাতে ছেড়ে দিন, বাতিল করতে উপরে সোয়াইপ করুন';

  @override
  String get commonHoldToTalk => 'কথা বলতে থাকুন';

  @override
  String get commonSend => 'পাঠান';

  @override
  String get commonAddFriend => 'বন্ধু যোগ করুন';

  @override
  String get commonChatServiceNotConnected => 'চ্যাট পরিষেবা সংযুক্ত নয়৷';

  @override
  String contactUserNotFoundHint(String query) {
    return 'ব্যবহারকারী \"$query\" পাওয়া যায়নি\n\nটিপস:\n• সম্পূর্ণ ইউজার আইডি লেখার চেষ্টা করুন, যেমন @username:server.com\n• ব্যবহারকারীর নামের বানান পরীক্ষা করুন';
  }

  @override
  String contactCreateChatFailed(String error) {
    return 'চ্যাট তৈরি করতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String contactSearchFailed(String error) {
    return 'অনুসন্ধান ব্যর্থ হয়েছে: $error';
  }

  @override
  String get contactEnterUserIdOrUsername =>
      'অনুসন্ধান করতে ব্যবহারকারীর আইডি বা ব্যবহারকারীর নাম লিখুন';

  @override
  String get contactSearching => 'অনুসন্ধান করা হচ্ছে...';

  @override
  String get contactSearchUserToChat => 'চ্যাটিং শুরু করতে ব্যবহারকারী খুঁজুন';

  @override
  String get contactMatrixIdExample =>
      'আপনি একটি সম্পূর্ণ ম্যাট্রিক্স আইডি লিখতে পারেন\nযেমন @user:matrix.n42.network';

  @override
  String contactUserNotFound(String username) {
    return 'ব্যবহারকারী \"$username\" পাওয়া যায়নি';
  }

  @override
  String get commonChat => 'চ্যাট';

  @override
  String get commonSettings => 'সেটিংস';

  @override
  String get profileEditProfile => 'প্রোফাইল সম্পাদনা করুন';

  @override
  String get authLogin => 'লগ ইন করুন';

  @override
  String get commonCreateGroup => 'গ্রুপ তৈরি করুন';

  @override
  String get chatError => 'ত্রুটি';

  @override
  String get commonTransfer => 'স্থানান্তর';

  @override
  String get commonReceived => 'গৃহীত';

  @override
  String get commonRefunded => 'ফেরত দেওয়া হয়েছে';

  @override
  String get commonExpired => 'মেয়াদ শেষ';

  @override
  String get chatRedPacketGreeting => 'শুভকামনা';

  @override
  String get commonN42RedPacket => 'N42 লাল প্যাকেট';

  @override
  String get commonClaimed => 'দাবি করেছে';

  @override
  String get commonAllClaimed => 'সব দাবি';

  @override
  String get chatReadAloud => 'জোরে পড়ুন';

  @override
  String get chatReply => 'উত্তর দিন';

  @override
  String get commonEdit => 'সম্পাদনা করুন';

  @override
  String get chatSelectForwardTarget => 'ফরোয়ার্ড টার্গেট নির্বাচন করুন';

  @override
  String commonSendCount(int count) {
    return 'পাঠান($count)';
  }

  @override
  String contactN42Id(String id) {
    return 'N42 আইডি: $id';
  }

  @override
  String get profileN42IdTitle => 'N42 আইডি';

  @override
  String get profileN42Bean => 'N42 বিন';

  @override
  String get contactFriendInfo => 'বন্ধু তথ্য';

  @override
  String get contactFriendInfoDesc =>
      'বন্ধুর মন্তব্য, ফোন, ট্যাগ, নোট, ফটো এবং সেট অনুমতি যোগ করুন.';

  @override
  String get commonMoments => 'মুহূর্ত';

  @override
  String get commonSendMessage => 'বার্তা';

  @override
  String get contactAudioVideoCall => 'অডিও/ভিডিও কল';

  @override
  String get contactVideoChannel => 'ভিডিও চ্যানেল';

  @override
  String get contactRemark => 'মন্তব্য';

  @override
  String get contactRemarkName => 'মন্তব্যের নাম';

  @override
  String get contactPhone => 'ফোন';

  @override
  String get contactTags => 'ট্যাগ';

  @override
  String get contactNotes => 'নোট';

  @override
  String get contactPhotos => 'ফটো';

  @override
  String get contactPermissions => 'অনুমতি';

  @override
  String get contactChatMomentsEtc => 'চ্যাট, মুহূর্ত, খেলাধুলা ইত্যাদি।';

  @override
  String get contactMoreInfo => 'আরো তথ্য';

  @override
  String get contactCommonGroups => 'সাধারণ গ্রুপ';

  @override
  String get contactSource => 'উৎস';

  @override
  String get settingsNotificationSettings => 'বিজ্ঞপ্তি';

  @override
  String get settingsPrivacy => 'গোপনীয়তা';

  @override
  String get settingsAppearance => 'চেহারা';

  @override
  String get settingsAbout => 'সম্পর্কে';

  @override
  String get commonLogout => 'লগ আউট করুন';

  @override
  String get commonLogoutConfirm => 'আপনি কি নিশ্চিত আপনি লগ আউট করতে চান?';

  @override
  String get commonSave => 'সংরক্ষণ করুন';

  @override
  String get profileNickname => 'ডাকনাম';

  @override
  String get profileEnterNickname => 'ডাকনাম লিখুন';

  @override
  String get profileSignature => 'স্বাক্ষর';

  @override
  String get profileAddSignature => 'একটি স্বাক্ষর যোগ করুন';

  @override
  String get commonTakePhoto => 'ছবি তুলুন';

  @override
  String get profileChooseFromGallery => 'গ্যালারি থেকে চয়ন করুন';

  @override
  String profileSaveFailed(String error) {
    return 'সংরক্ষণ ব্যর্থ হয়েছে: $error৷';
  }

  @override
  String get authSecureDecentralizedChat =>
      'নিরাপদ, বিকেন্দ্রীভূত বার্তাপ্রেরণ';

  @override
  String get commonEndToEndEncryption => 'এন্ড-টু-এন্ড এনক্রিপশন';

  @override
  String get authMessagesOnlyYouCanSee =>
      'বার্তাগুলি শুধুমাত্র আপনার এবং প্রাপকের কাছে দৃশ্যমান৷';

  @override
  String get authDecentralized => 'বিকেন্দ্রীকৃত';

  @override
  String get authBasedOnMatrix => 'ম্যাট্রিক্স ওপেন প্রোটোকলের উপর নির্মিত';

  @override
  String get authWalletIntegration => 'ওয়ালেট ইন্টিগ্রেশন';

  @override
  String get authEasyCryptoTransfer => 'সহজ ক্রিপ্টোকারেন্সি স্থানান্তর';

  @override
  String get authRegister => 'সাইন আপ করুন';

  @override
  String get authAgreeTerms => 'লগ ইন করে, আপনি সম্মত হন';

  @override
  String get authTermsOfService => 'পরিষেবার শর্তাবলী';

  @override
  String get authAnd => 'এবং';

  @override
  String get authPrivacyPolicy => 'গোপনীয়তা নীতি';

  @override
  String get authServerAddress => 'সার্ভার ঠিকানা';

  @override
  String get authEnterServerAddress => 'সার্ভার ঠিকানা লিখুন';

  @override
  String authConnectedTo(String serverName) {
    return '$serverName এর সাথে সংযুক্ত';
  }

  @override
  String get authUsername => 'ব্যবহারকারীর নাম';

  @override
  String get authEnterUsername => 'ব্যবহারকারীর নাম লিখুন';

  @override
  String get authUsernameOrEmail => 'ব্যবহারকারীর নাম বা ইমেল';

  @override
  String get authEnterUsernameOrEmail => 'ব্যবহারকারীর নাম বা ইমেল লিখুন';

  @override
  String get authPassword => 'পাসওয়ার্ড';

  @override
  String get authEnterPassword => 'পাসওয়ার্ড লিখুন';

  @override
  String get authRegisterAccount => 'সাইন আপ করুন';

  @override
  String get authForgotPassword => 'পাসওয়ার্ড ভুলে গেছি';

  @override
  String get authOtherLoginMethods => 'অন্যান্য লগইন পদ্ধতি';

  @override
  String get authCreateAccount => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get authJoinN42Chat => 'চ্যাটিং শুরু করতে N42 চ্যাটে যোগ দিন';

  @override
  String get authUsernameHint => '3-20 অক্ষর, অক্ষর/সংখ্যা/_';

  @override
  String get authUsernameMinLength =>
      'ব্যবহারকারীর নাম কমপক্ষে 3 অক্ষরের হতে হবে';

  @override
  String get authUsernameMaxLength =>
      'ব্যবহারকারীর নাম অবশ্যই 20টি অক্ষরের হতে হবে';

  @override
  String get authUsernameFormat =>
      'ব্যবহারকারীর নামে শুধুমাত্র অক্ষর, সংখ্যা এবং আন্ডারস্কোর থাকতে পারে';

  @override
  String get authPasswordHint => 'ন্যূনতম ৮ অক্ষর';

  @override
  String get commonPasswordMinLength => 'পাসওয়ার্ড কমপক্ষে 8 অক্ষরের হতে হবে';

  @override
  String get authConfirmPassword => 'পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get authFilled => 'ভরা';

  @override
  String get authEnterInviteCode => 'আমন্ত্রণ কোড লিখুন';

  @override
  String get authAlreadyHaveAccount => 'ইতিমধ্যে একটি অ্যাকাউন্ট আছে?';

  @override
  String get authLoginNow => 'এখন লগ ইন করুন';

  @override
  String get profileAvatar => 'অবতার';

  @override
  String get profileStatus => 'স্ট্যাটাস';

  @override
  String get commonLoading => 'লোড হচ্ছে...';

  @override
  String get conversationNoConversations => 'কোনো কথোপকথন নেই';

  @override
  String get conversationTapToChat =>
      'চ্যাটিং শুরু করতে উপরের ডানদিকে আলতো চাপুন';

  @override
  String get conversationStartGroup => 'গ্রুপ চ্যাট শুরু করুন';

  @override
  String get commonScan => 'স্ক্যান করুন';

  @override
  String get commonPayment => 'পেমেন্ট';

  @override
  String commonFeatureComingSoon(String feature) {
    return '$feature শীঘ্রই আসছে';
  }

  @override
  String get conversationMarkAsRead => 'পঠিত হিসাবে চিহ্নিত করুন';

  @override
  String get commonUnmute => 'আনমিউট করুন';

  @override
  String get commonMute => 'নিঃশব্দ';

  @override
  String get conversationUnpin => 'আনপিন করুন';

  @override
  String get conversationPin => 'পিন';

  @override
  String get conversationDeleteConversation => 'কথোপকথন মুছুন';

  @override
  String conversationDeleteConversationConfirm(String name) {
    return '\"$name\" এর সাথে কথোপকথন মুছবেন?';
  }

  @override
  String get commonNoContacts => 'কোনো পরিচিতি নেই';

  @override
  String get contactAddFriendsToChat => 'চ্যাটিং শুরু করতে বন্ধুদের যোগ করুন';

  @override
  String get contactNotFound => 'যোগাযোগ পাওয়া যায়নি';

  @override
  String get contactTryOtherKeywords =>
      'অন্যান্য কীওয়ার্ড বা বিশ্বব্যাপী অনুসন্ধান চেষ্টা করুন';

  @override
  String get contactSearchResults => 'অনুসন্ধান ফলাফল';

  @override
  String get contactNewFriends => 'নতুন বন্ধু';

  @override
  String get contactChatOnlyFriends => 'চ্যাট শুধুমাত্র বন্ধু';

  @override
  String get contactOfficialAccounts => 'অফিসিয়াল অ্যাকাউন্টস';

  @override
  String get contactServiceAccounts => 'পরিষেবা অ্যাকাউন্ট';

  @override
  String get contactEnterpriseContacts => 'এন্টারপ্রাইজ পরিচিতি';

  @override
  String get contactRecommendToFriend => 'যোগাযোগ শেয়ার করুন';

  @override
  String get commonSetRemark => 'মন্তব্য সেট করুন';

  @override
  String get contactSendingCard => 'পরিচিতি কার্ড পাঠানো হচ্ছে...';

  @override
  String get commonFileLabel => 'ফাইল';

  @override
  String get commonLocationLabel => 'অবস্থান';

  @override
  String contactRecommendFailed(String error) {
    return 'সুপারিশ ব্যর্থ হয়েছে: $error';
  }

  @override
  String get profileEnterRemark => 'মন্তব্য লিখুন';

  @override
  String get contactOpeningChat => 'চ্যাট খোলা হচ্ছে...';

  @override
  String contactOpenChatFailed(String error) {
    return 'চ্যাট খুলতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String get contactAddContact => 'যোগাযোগ যোগ করুন';

  @override
  String get contactEnterUserId => 'ইউজার আইডি লিখুন';

  @override
  String get contactNoFriendRequests => 'কোন বন্ধুর অনুরোধ নেই';

  @override
  String get commonAccept => 'গ্রহণ করুন';

  @override
  String get commonReject => 'প্রত্যাখ্যান করুন';

  @override
  String get commonNoGroups => 'কোন দল নেই';

  @override
  String get contactSelectFriendToRecommend =>
      'সুপারিশ করার জন্য একটি বন্ধু নির্বাচন করুন';

  @override
  String get commonSearchContacts => 'পরিচিতি অনুসন্ধান করুন';

  @override
  String get contactNoContactsFound => 'কোন পরিচিতি পাওয়া যায়নি';

  @override
  String get favoriteYesterday => 'গতকাল';

  @override
  String get chatJustNow => 'এইমাত্র';

  @override
  String get profileOnline => 'অনলাইন';

  @override
  String get profileOffline => 'অফলাইন';

  @override
  String get searchContactsGroupsMessages =>
      'পরিচিতি, গোষ্ঠী এবং বার্তা অনুসন্ধান করুন';

  @override
  String get searchError => 'অনুসন্ধান ত্রুটি';

  @override
  String get chatSearchHint => 'অনুসন্ধান করুন';

  @override
  String get searchHistory => 'অনুসন্ধান ইতিহাস';

  @override
  String get commonClear => 'পরিষ্কার';

  @override
  String get commonAll => 'সব';

  @override
  String get searchGroups => 'গোষ্ঠী';

  @override
  String get searchNoResults => 'কোন ফলাফল নেই';

  @override
  String commonGroupMembers(int count) {
    return 'সদস্য ($count)';
  }

  @override
  String get groupMembersTitle => 'গ্রুপের সদস্যরা';

  @override
  String get groupViewAll => 'সব দেখুন';

  @override
  String get groupOwner => 'মালিক';

  @override
  String get groupAdmin => 'অ্যাডমিন';

  @override
  String get groupInvite => 'আমন্ত্রণ';

  @override
  String get commonGroupAnnouncement => 'গ্রুপ ঘোষণা';

  @override
  String get commonNotSet => 'সেট করা হয়নি';

  @override
  String get groupDescription => 'গ্রুপ বিবরণ';

  @override
  String get groupPublicGroup => 'পাবলিক গ্রুপ';

  @override
  String get commonClearChatHistory => 'চ্যাটের ইতিহাস সাফ করুন';

  @override
  String get commonDissolveGroup => 'গ্রুপ দ্রবীভূত করুন';

  @override
  String get commonLeaveGroup => 'গ্রুপ ত্যাগ করুন';

  @override
  String get groupChangeGroupName => 'গ্রুপের নাম পরিবর্তন করুন';

  @override
  String get commonEnterGroupName => 'গ্রুপের নাম লিখুন';

  @override
  String get commonConfirm => 'নিশ্চিত করুন';

  @override
  String get groupEnterGroupDescription => 'গ্রুপের বিবরণ লিখুন';

  @override
  String get groupPublish => 'প্রকাশ করুন';

  @override
  String get chatClearHistoryConfirm =>
      'সমস্ত চ্যাট ইতিহাস সাফ করবেন? এটি পূর্বাবস্থায় ফেরানো যাবে না।';

  @override
  String get chatClearAction => 'পরিষ্কার';

  @override
  String get commonChatHistoryCleared => 'চ্যাটের ইতিহাস সাফ করা হয়েছে';

  @override
  String get commonDissolve => 'দ্রবীভূত করা';

  @override
  String get groupQrCode => 'গ্রুপ QR কোড';

  @override
  String get commonSearchChatHistory => 'চ্যাট ইতিহাস অনুসন্ধান করুন';

  @override
  String get groupIdCopied => 'গ্রুপ আইডি কপি করা হয়েছে';

  @override
  String get transferEnterOrPasteAddress =>
      'মানিব্যাগের ঠিকানা লিখুন বা পেস্ট করুন';

  @override
  String get transferSelectToken => 'টোকেন নির্বাচন করুন';

  @override
  String get commonTransferAmount => 'স্থানান্তর পরিমাণ';

  @override
  String get transferAvailable => 'পাওয়া যায়';

  @override
  String get transferMemoOptional => 'মেমো (ঐচ্ছিক)';

  @override
  String get transferConfirmTransfer => 'স্থানান্তর নিশ্চিত করুন';

  @override
  String get transferAddressVerified => 'ঠিকানা যাচাই করা হয়েছে';

  @override
  String transferAvailableBalance(String balance, String symbol) {
    return 'উপলব্ধ: $balance $symbol';
  }

  @override
  String get commonEnterAmount => 'পরিমাণ লিখুন';

  @override
  String get commonRedPacketCountMin => 'কমপক্ষে 1টি লাল প্যাকেট প্রয়োজন';

  @override
  String get commonViewRedPacketDetails => 'লাল প্যাকেটের বিবরণ দেখুন';

  @override
  String get commonEnterTransferAmount =>
      'অনুগ্রহ করে স্থানান্তরের পরিমাণ লিখুন';

  @override
  String get commonTransferTo => 'ট্রান্সফার করুন';

  @override
  String commonFromSender(String name, Object senderName) {
    return '$name থেকে';
  }

  @override
  String get commonConfirmReceive => 'প্রাপ্তি নিশ্চিত করুন';

  @override
  String get groupProfile => 'গ্রুপ তথ্য';

  @override
  String get groupRemoveMember => 'গ্রুপ থেকে সরান';

  @override
  String get commonRemove => 'সরান';

  @override
  String get profileClearStatus => 'স্থিতি পরিষ্কার করুন';

  @override
  String get profileClearStatusConfirm => 'বর্তমান অবস্থা সাফ করবেন?';

  @override
  String get profileStatusCleared => 'স্ট্যাটাস সাফ করা হয়েছে';

  @override
  String get profileUserNotExist => 'ব্যবহারকারীর অস্তিত্ব নেই';

  @override
  String get profileUserIdCopied => 'ইউজার আইডি কপি করা হয়েছে';

  @override
  String get commonReport => 'রিপোর্ট';

  @override
  String get profileQrCode => 'QR কোড';

  @override
  String get profileAvatarUpdated => 'অবতার আপডেট করা হয়েছে';

  @override
  String commonSelectImageFailed(String error) {
    return 'ছবি নির্বাচন করতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String get profileChangeName => 'নাম পরিবর্তন করুন';

  @override
  String get profileMale => 'পুরুষ';

  @override
  String get profileFemale => 'মহিলা';

  @override
  String chatFeatureInDev(String feature) {
    return '$feature বৈশিষ্ট্য বিকাশে...';
  }

  @override
  String profileSaveAddressFailed(String error) {
    return 'ঠিকানা সংরক্ষণ করতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String get profileAddNew => 'যোগ করুন';

  @override
  String get profileAddAddress => 'ঠিকানা যোগ করুন';

  @override
  String get profileAddressAdded => 'ঠিকানা যোগ করা হয়েছে';

  @override
  String get profileAddressUpdated => 'ঠিকানা আপডেট করা হয়েছে';

  @override
  String get profileDeleteAddress => 'ঠিকানা মুছুন';

  @override
  String get profileAddressDeleted => 'ঠিকানা মুছে ফেলা হয়েছে';

  @override
  String profileSaveInvoiceFailed(String error) {
    return 'চালান সংরক্ষণ করতে ব্যর্থ হয়েছে: $error৷';
  }

  @override
  String get profileMyInvoices => 'আমার চালান';

  @override
  String get profileAddInvoice => 'চালান যোগ করুন';

  @override
  String get profileInvoiceAdded => 'চালান যোগ করা হয়েছে';

  @override
  String get profileInvoiceUpdated => 'চালান আপডেট করা হয়েছে';

  @override
  String get profileDeleteInvoice => 'চালান মুছুন';

  @override
  String get profileInvoiceDeleted => 'চালান মুছে ফেলা হয়েছে';

  @override
  String get profilePersonal => 'ব্যক্তিগত';

  @override
  String get groupSelectAtLeastOne => 'অন্তত একজন সদস্য নির্বাচন করুন';

  @override
  String get chatFileNotExist => 'ফাইল বিদ্যমান নেই';

  @override
  String chatSendFailed(String error) {
    return 'পাঠাতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String get chatCannotOpenBrowser => 'ব্রাউজার খুলতে পারে না';

  @override
  String chatSelectFileFailed(String error) {
    return 'ফাইল নির্বাচন করতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String settingsSetupFailed(String error) {
    return 'সেটআপ ব্যর্থ হয়েছে: $error৷';
  }

  @override
  String get transferEnterValidAmount => 'একটি বৈধ পরিমাণ লিখুন';

  @override
  String get commonAddressCopied => 'ঠিকানা কপি করা হয়েছে';

  @override
  String favoriteOpenItem(String content) {
    return 'খুলুন: $content';
  }

  @override
  String get favoriteDeleted => 'মুছে ফেলা হয়েছে';

  @override
  String get profileWallet => 'ওয়ালেট';

  @override
  String get chatRecording => 'রেকর্ডিং';

  @override
  String get chatInvalidVideoUrl => 'অবৈধ ভিডিও URL';

  @override
  String get chatDownloadFile => 'ফাইল ডাউনলোড করুন';

  @override
  String get chatClearChatHistoryTitle => 'চ্যাটের ইতিহাস সাফ করুন';

  @override
  String get chatVideoCall => 'ভিডিও কল';

  @override
  String get commonVoiceCall => 'ভয়েস কল';

  @override
  String get callLeaveMeeting => 'মিটিং ত্যাগ করুন';

  @override
  String get chatDetails => 'চ্যাট বিবরণ';

  @override
  String get chatViewAllGroupMembers => 'সব সদস্য দেখুন';

  @override
  String get chatGroupName => 'গ্রুপের নাম';

  @override
  String get chatGroupNameUpdated => 'গ্রুপের নাম আপডেট করা হয়েছে';

  @override
  String get chatUpdateFailed => 'আপডেট ব্যর্থ হয়েছে';

  @override
  String get chatNoPermissionToModify => 'আপনার সংশোধন করার অনুমতি নেই';

  @override
  String get chatGroupManagement => 'গ্রুপ ম্যানেজমেন্ট';

  @override
  String get chatMyNicknameInGroup => 'গ্রুপে আমার ডাকনাম';

  @override
  String get chatPinChat => 'পিন চ্যাট';

  @override
  String get chatStrongReminder => 'শক্তিশালী অনুস্মারক';

  @override
  String get chatSetChatBackground => 'চ্যাট ব্যাকগ্রাউন্ড সেট করুন';

  @override
  String get chatUnknownFile => 'অজানা ফাইল';

  @override
  String get chatDownload => 'ডাউনলোড করুন';

  @override
  String get chatInvalidLocation => 'অবৈধ অবস্থান';

  @override
  String get chatTapToCancel => 'বাতিল করতে আলতো চাপুন';

  @override
  String chatCaptureFailed(Object error) {
    return 'ক্যাপচার ব্যর্থ হয়েছে: $error';
  }

  @override
  String get chatProcessingVideo => 'ভিডিও প্রক্রিয়া করা হচ্ছে...';

  @override
  String get chatVideoFileNotExist => 'ভিডিও ফাইল বিদ্যমান নেই';

  @override
  String get chatVideoDataEmpty => 'ভিডিও ডেটা খালি';

  @override
  String get chatVideoTooLarge => 'ভিডিও আকার 100MB অতিক্রম করা যাবে না';

  @override
  String get chatSendingVideo => 'ভিডিও পাঠানো হচ্ছে...';

  @override
  String chatSendVideoFailed(Object error) {
    return 'ভিডিও পাঠাতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String get chatImageFileNotExist => 'ইমেজ ফাইল বিদ্যমান নেই';

  @override
  String get commonImageDataEmpty => 'ছবির ডেটা খালি';

  @override
  String get chatSendingImage => 'ছবি পাঠানো হচ্ছে...';

  @override
  String chatSendImageFailed(Object error) {
    return 'ছবি পাঠাতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String get chatSendLocation => 'অবস্থান পাঠান';

  @override
  String get chatSelectLocationAndSend => 'অবস্থান নির্বাচন করুন এবং পাঠান';

  @override
  String get chatShareRealTimeLocation => 'রিয়েল-টাইম লোকেশন শেয়ার করুন';

  @override
  String get chatShareLocationForOneHour =>
      'বন্ধুর সাথে 1 ঘন্টার জন্য রিয়েল-টাইম লোকেশন শেয়ার করুন';

  @override
  String get chatLocationSent => 'অবস্থান পাঠানো হয়েছে';

  @override
  String get chatSelectMessages => 'বার্তা নির্বাচন করুন';

  @override
  String chatSelectedCount(int count) {
    return 'নির্বাচিত $count';
  }

  @override
  String get chatSelectAll => 'সব নির্বাচন করুন';

  @override
  String chatGroupChatCount(int count) {
    return 'গ্রুপ চ্যাট($count)';
  }

  @override
  String get chatPrivateChat => 'ব্যক্তিগত চ্যাট';

  @override
  String get chatNoMessages => 'কোনো বার্তা নেই';

  @override
  String get chatSendFirstMessage => 'চ্যাটিং শুরু করতে প্রথম বার্তা পাঠান';

  @override
  String get chatEncryptionNotice =>
      'এই চ্যাট এন্ড-টু-এন্ড এনক্রিপ্টেড। শুধুমাত্র আপনি এবং প্রাপক বার্তা পড়তে পারেন.';

  @override
  String get chatMultiForward => 'ফরোয়ার্ড';

  @override
  String get chatCollect => 'সংগ্রহ করুন';

  @override
  String get chatNoMembers => 'কোনো সদস্য নেই';

  @override
  String get chatMemberNotFound => 'সদস্য পাওয়া যায়নি';

  @override
  String get chatVoiceFileNotExist => 'ভয়েস ফাইল বিদ্যমান নেই';

  @override
  String get chatVoiceFileEmpty => 'ভয়েস ফাইল খালি';

  @override
  String get chatSendingVoice => 'ভয়েস পাঠানো হচ্ছে...';

  @override
  String chatSendVoiceFailed(Object error) {
    return 'ভয়েস পাঠাতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String get chatMessageForwarded => 'বার্তা ফরোয়ার্ড করা হয়েছে';

  @override
  String chatForwardFailed(Object error) {
    return 'ফরোয়ার্ড ব্যর্থ হয়েছে: $error';
  }

  @override
  String get chatUnfavorited => 'অপছন্দনীয়';

  @override
  String get chatFavorited => 'পছন্দের';

  @override
  String get chatReactionAdded => 'প্রতিক্রিয়া যোগ করা হয়েছে';

  @override
  String get chatReactionRemoved => 'প্রতিক্রিয়া সরানো হয়েছে';

  @override
  String get chatFailedMessageDeleted => 'ব্যর্থ বার্তা মুছে ফেলা হয়েছে';

  @override
  String get chatDeleteMessages => 'বার্তা মুছুন';

  @override
  String chatDeleteMessagesConfirm(Object count) {
    return 'আপনি কি $count বার্তাগুলি মুছতে চান?';
  }

  @override
  String chatNoteOtherMessages(Object count) {
    return 'দ্রষ্টব্য: $count বার্তাগুলি অন্যদের থেকে এসেছে এবং শুধুমাত্র আপনার জন্য মুছে ফেলা হবে৷';
  }

  @override
  String chatMyMessagesWillBeRecalled(Object count) {
    return 'আপনার থেকে আসা $count বার্তা সকলের জন্য প্রত্যাহার করা হবে।';
  }

  @override
  String chatRecalledCount(Object count, Object localCount) {
    return 'প্রত্যাহার করা $count বার্তাগুলি, $localCount শুধুমাত্র আপনার জন্য মুছে ফেলা হয়েছে৷';
  }

  @override
  String chatRecalledMessages(Object count) {
    return '$count বার্তাগুলি প্রত্যাহার করা হয়েছে৷';
  }

  @override
  String chatDeletedLocally(Object count) {
    return '$count বার্তাগুলি শুধুমাত্র আপনার জন্য মুছে ফেলা হয়েছে৷';
  }

  @override
  String chatForwardedCount(Object count) {
    return 'ফরওয়ার্ড করা $count বার্তা';
  }

  @override
  String chatForwardComplete(Object failed, Object success) {
    return 'ফরওয়ার্ড সম্পূর্ণ: $success সফল হয়েছে, $failed ব্যর্থ হয়েছে৷';
  }

  @override
  String get chatRemindOnlyInGroup =>
      'রিমাইন্ড ফিচার শুধুমাত্র গ্রুপ চ্যাটে পাওয়া যায়';

  @override
  String get chatOnlyTextSearchable =>
      'শুধুমাত্র টেক্সট বার্তা অনুসন্ধান করা যাবে';

  @override
  String chatSearchFor(Object text) {
    return '\"$text\" অনুসন্ধান করুন';
  }

  @override
  String get chatBaiduSearch => 'Baidu অনুসন্ধান';

  @override
  String get chatGoogleSearch => 'Google অনুসন্ধান';

  @override
  String get chatBingSearch => 'বিং অনুসন্ধান';

  @override
  String get chatCalling => 'কল করা হচ্ছে...';

  @override
  String get chatRinging => 'রিং হচ্ছে...';

  @override
  String get chatInCall => 'কলে';

  @override
  String commonFeatureInDevelopment(String feature) {
    return '$feature বৈশিষ্ট্য বিকাশে...';
  }

  @override
  String chatCollectMessages(Object count) {
    return '$count বার্তা সংগ্রহ করা হয়েছে';
  }

  @override
  String commonMemberCount(int count) {
    return '$count সদস্য';
  }

  @override
  String groupDone(int count) {
    return 'সম্পন্ন($count)';
  }

  @override
  String get profileServices => 'সেবা';

  @override
  String get commonFavorites => 'প্রিয়';

  @override
  String get profileOrdersAndCards => 'অর্ডার এবং কার্ড';

  @override
  String get profileStickers => 'স্টিকার';

  @override
  String profileStatusSetTo(String status) {
    return 'স্থিতি সেট করা হয়েছে: $status';
  }

  @override
  String get profileAvatarUploadFailed => 'অবতার আপলোড ব্যর্থ হয়েছে৷';

  @override
  String get profilePersonalProfile => 'ব্যক্তিগত প্রোফাইল';

  @override
  String get profileName => 'নাম';

  @override
  String get profileGender => 'লিঙ্গ';

  @override
  String get profileRegion => 'অঞ্চল';

  @override
  String get commonMyQrCode => 'আমার QR কোড';

  @override
  String get profilePoke => 'খোঁচা';

  @override
  String get profileRingtone => 'রিংটোন';

  @override
  String get profileDefaultRingtone => 'ডিফল্ট রিংটোন';

  @override
  String get profileMyAddresses => 'আমার ঠিকানা';

  @override
  String profileGenderSetTo(String gender) {
    return 'লিঙ্গ এতে সেট করা হয়েছে: $gender';
  }

  @override
  String get profileSelectRegion => 'অঞ্চল নির্বাচন করুন';

  @override
  String get profileSelectCity => 'শহর নির্বাচন করুন';

  @override
  String profileRegionSetTo(String region) {
    return 'অঞ্চল এতে সেট করা হয়েছে: $region';
  }

  @override
  String get profileSetPoke => 'পোক সেট করুন';

  @override
  String get profileFriendPokedMe => 'বন্ধু আমাকে ধাক্কা দিল';

  @override
  String get profileExample => 'উদাহরণ';

  @override
  String get profileOnTheShoulder => ' কাঁধে';

  @override
  String get profilePokeCleared => 'খোঁচা সাফ করা হয়েছে';

  @override
  String profilePokeSetTo(String suffix) {
    return 'পোক এতে সেট করুন: poked me$suffix';
  }

  @override
  String get profileEditSignature => 'স্বাক্ষর সম্পাদনা করুন';

  @override
  String get profileIntroduceYourself =>
      'নিজেকে পরিচয় করিয়ে দেওয়ার জন্য একটি বাক্য';

  @override
  String get profileSignatureCleared => 'স্বাক্ষর সাফ করা হয়েছে';

  @override
  String get profileSignatureUpdated => 'স্বাক্ষর আপডেট করা হয়েছে';

  @override
  String get profileScanToAddFriend =>
      'আমাকে বন্ধু হিসেবে যুক্ত করতে উপরের QR কোডটি স্ক্যান করুন';

  @override
  String profileRingtoneSetTo(String ringtone) {
    return 'রিংটোন এতে সেট করা হয়েছে: $ringtone';
  }

  @override
  String commonConfirmDissolveGroup(String name) {
    return 'আপনি কি \"$name\" দ্রবীভূত করার বিষয়ে নিশ্চিত? এই ক্রিয়াটি পূর্বাবস্থায় ফেরানো যাবে না৷';
  }

  @override
  String get authEnterValidServerAddress => 'একটি বৈধ সার্ভার ঠিকানা লিখুন';

  @override
  String get authEnterServerAddressFirst => 'প্রথমে সার্ভার ঠিকানা লিখুন';

  @override
  String get authPasskeyRequiresServer => 'পাসকি লগইন সার্ভার সমর্থন প্রয়োজন';

  @override
  String get authLoginAgreement => 'লগ ইন করে, আপনি সম্মত হন ';

  @override
  String get authPleaseAgreeToTerms =>
      'অনুগ্রহ করে পড়ুন এবং পরিষেবার শর্তাবলী এবং গোপনীয়তা নীতিতে সম্মত হন৷';

  @override
  String get authRegisterFailed => 'নিবন্ধন ব্যর্থ হয়েছে';

  @override
  String get commonReenterPassword => 'পাসওয়ার্ড পুনরায় লিখুন';

  @override
  String get commonPasswordsDoNotMatch => 'পাসওয়ার্ড মেলে না';

  @override
  String get authInviteCodeBuiltIn => 'আমন্ত্রণ কোড (বিল্ট-ইন)';

  @override
  String get authInviteCodeBuiltInNote =>
      'আমন্ত্রণ কোড অন্তর্নির্মিত, সাধারণত পরিবর্তন করার প্রয়োজন হয় না';

  @override
  String get authIHaveReadAndAgree => 'আমি পড়েছি এবং একমত ';

  @override
  String get mainStartGroupChat => 'গ্রুপ চ্যাট শুরু করুন';

  @override
  String get mainAddFriends => 'বন্ধুদের যোগ করুন';

  @override
  String get mainPaymentAndCollection => 'পেমেন্ট';

  @override
  String contactCount(int count) {
    return '$count পরিচিতি';
  }

  @override
  String get contactAddToHomeScreen => 'হোম স্ক্রিনে যোগ করুন';

  @override
  String contactRecommendedCardTo(String contact, String recipient) {
    return 'প্রস্তাবিত $contact এর কার্ড $recipient';
  }

  @override
  String get contactEnterRemarkName => 'মন্তব্যের নাম লিখুন';

  @override
  String contactRemarkSetTo(String remark) {
    return 'মন্তব্য সেট করা হয়েছে: $remark';
  }

  @override
  String contactAcceptedFriendRequest(String name) {
    return '$name এর বন্ধুত্বের অনুরোধ গৃহীত হয়েছে';
  }

  @override
  String contactRejectedFriendRequest(String name) {
    return '$name এর বন্ধুত্বের অনুরোধ প্রত্যাখ্যান করা হয়েছে৷';
  }

  @override
  String get commonGroupInvites => 'গ্রুপ আমন্ত্রণ';

  @override
  String commonMyGroups(int count) {
    return 'আমার গ্রুপ ($count)';
  }

  @override
  String get commonInvitedToJoinGroup => 'গ্রুপে যোগদানের আমন্ত্রণ রইল';

  @override
  String commonConfirmLeaveGroup(String name) {
    return 'আপনি কি \"$name\" ছেড়ে যাওয়ার বিষয়ে নিশ্চিত?';
  }

  @override
  String get commonLeave => 'ছেড়ে দিন';

  @override
  String get commonRecallThisMessage => 'এই বার্তাটি মনে আছে?';

  @override
  String get commonSavedToGallery => 'গ্যালারিতে সংরক্ষিত';

  @override
  String get commonFailedToSave => 'সংরক্ষণ করতে ব্যর্থ হয়েছে';

  @override
  String get chatSaving => 'সংরক্ষণ করা হচ্ছে...';

  @override
  String get commonShare => 'শেয়ার করুন';

  @override
  String get chatSaveToGallery => 'গ্যালারিতে সংরক্ষণ করুন';

  @override
  String chatDownloadFailed(String code) {
    return 'ডাউনলোড ব্যর্থ হয়েছে: $code';
  }

  @override
  String commonShareFailed(String error) {
    return 'শেয়ার করা ব্যর্থ হয়েছে: $error';
  }

  @override
  String get chatFailedToLoadImage => 'ছবি লোড করতে ব্যর্থ হয়েছে৷';

  @override
  String get chatVideoRecordingFailed => 'ভিডিও রেকর্ডিং ব্যর্থ হয়েছে';

  @override
  String get profileRedPacket => 'লাল প্যাকেট';

  @override
  String get commonMusic => 'সঙ্গীত';

  @override
  String get commonCoupon => 'কুপন';

  @override
  String get commonGift => 'উপহার';

  @override
  String get commonPoll => 'পোল';

  @override
  String get favoriteText => 'পাঠ্য';

  @override
  String get favoriteLinkLabel => 'লিঙ্ক';

  @override
  String get favoriteNote => 'দ্রষ্টব্য';

  @override
  String get favoriteMyNotes => 'আমার নোট';

  @override
  String get favoriteToday => 'আজ';

  @override
  String favoriteDaysAgoText(int count) {
    return '$count দিন আগে';
  }

  @override
  String favoriteDateFormat(int month, int day) {
    return '$month/$day';
  }

  @override
  String get favoriteNoFavorites => 'এখনও কোন প্রিয়';

  @override
  String get favoriteLongPressToFavorite => 'প্রিয়তে দীর্ঘ প্রেস বার্তা';

  @override
  String get favoriteNewNote => 'নতুন নোট';

  @override
  String get favoriteLink => 'প্রিয় লিঙ্ক';

  @override
  String get favoriteEditTags => 'ট্যাগ সম্পাদনা করুন';

  @override
  String get favoriteDeleteFavorite => 'প্রিয় মুছুন';

  @override
  String get favoriteDeleteFavoriteConfirm =>
      'আপনি কি নিশ্চিত আপনি এই প্রিয় মুছে ফেলতে চান?';

  @override
  String get favoriteNoSearchResultsFound => 'কোন ফলাফল পাওয়া যায়নি';

  @override
  String get commonSendRedPacket => 'লাল প্যাকেট পাঠান';

  @override
  String get transferAmount => 'পরিমাণ';

  @override
  String get commonRedPacketCover => 'লাল প্যাকেট কভার';

  @override
  String get commonRedPacketType => 'লাল প্যাকেটের ধরন';

  @override
  String get commonNormalRedPacket => 'স্বাভাবিক';

  @override
  String get commonLuckyRedPacket => 'ভাগ্যবান';

  @override
  String get commonRedPacketCount => 'লাল প্যাকেট কাউন্ট';

  @override
  String get commonPieces => 'টুকরা';

  @override
  String get commonPutMoneyInRedPacket => 'লাল প্যাকেটে টাকা রাখুন';

  @override
  String get commonRedPacketRefundNotice =>
      'দাবি না করা লাল প্যাকেট 24 ঘন্টা পরে ফেরত দেওয়া হবে';

  @override
  String get commonOpenRedPacket => 'খোলা';

  @override
  String get commonRedPacketAllClaimed => 'লাল প্যাকেট সব দাবি';

  @override
  String get commonRedPacketExpired => 'লাল প্যাকেটের মেয়াদ শেষ';

  @override
  String get commonAddTransferNote => 'স্থানান্তর নোট যোগ করুন';

  @override
  String get commonYuan => 'সিএনওয়াই';

  @override
  String get commonReplyWithEmoji => 'এই ইমোজি দিয়ে উত্তর দিন';

  @override
  String get contactEditRemark => 'মন্তব্য সম্পাদনা করুন';

  @override
  String get contactSetPermissions => 'অনুমতি সেট করুন';

  @override
  String get profileAddToBlacklist => 'কালো তালিকায় যোগ করুন';

  @override
  String get contactDeleteContact => 'পরিচিতি মুছুন';

  @override
  String contactDeleteContactConfirm(String name) {
    return 'আপনি কি $name মুছতে চান?';
  }

  @override
  String get transferTitle => 'স্থানান্তর';

  @override
  String get transferReceiverAddressLabel => 'প্রাপকের ঠিকানা';

  @override
  String get transferSelectTokenLabel => 'টোকেন নির্বাচন করুন';

  @override
  String get transferAmountLabel => 'স্থানান্তর পরিমাণ';

  @override
  String get transferMemoLabel => 'মেমো (ঐচ্ছিক)';

  @override
  String get transferAddMemoHint => 'একটি মেমো যোগ করুন';

  @override
  String get transferSendPaymentRequest => 'পেমেন্ট অনুরোধ পাঠান';

  @override
  String get transferQrCodeGenerateFailed => 'QR কোড তৈরি করা যায়নি';

  @override
  String get transferScanQrToPayMe => 'আমাকে পেমেন্ট করতে QR কোড স্ক্যান করুন';

  @override
  String get transferMyWalletAddress => 'আমার ওয়ালেট ঠিকানা';

  @override
  String get transferCreatePaymentRequest => 'পেমেন্ট অনুরোধ তৈরি করুন';

  @override
  String profileN42IdLabel(String id) {
    return 'N42 আইডি: $id';
  }

  @override
  String get commonRedPacketDefaultGreeting => 'শুভকামনা';

  @override
  String commonSenderRedPacket(String name) {
    return '$name এর লাল প্যাকেট';
  }

  @override
  String get transferEnterValidAddress => 'একটি বৈধ ঠিকানা লিখুন';

  @override
  String get transferPleaseSelectToken => 'একটি টোকেন নির্বাচন করুন';

  @override
  String get commonReceivedTransfer => 'স্থানান্তর প্রাপ্ত';

  @override
  String commonSenderSentRedPacket(String name) {
    return '$name একটি লাল প্যাকেট পাঠিয়েছে';
  }

  @override
  String get commonSavedToBalance =>
      'ব্যালেন্সে সংরক্ষিত, সরাসরি স্থানান্তর করতে পারে';

  @override
  String get commonRedPacketExpiredOrEmpty =>
      'লাল প্যাকেটের মেয়াদ শেষ/সব দাবি করা হয়েছে';

  @override
  String get transferScanFeatureComingSoon =>
      'স্ক্যান বৈশিষ্ট্য শীঘ্রই আসছে...';

  @override
  String get contactSetAsStarred => 'তারকাচিহ্নিত হিসাবে সেট করুন';

  @override
  String get contactAddToBlocklist => 'ব্লকলিস্টে যোগ করুন';

  @override
  String get commonClaimedYour => ' আপনার দাবি ';

  @override
  String get commonClaimedText => ' দাবি করেছে ';

  @override
  String commonUserTyping(String name) {
    return '$name টাইপ করছে...';
  }

  @override
  String get commonTyping => 'টাইপ করা হচ্ছে...';

  @override
  String get commonWaitingToReceive => 'পাওয়ার অপেক্ষায়';

  @override
  String get commonTapToClaim => 'দাবি করতে আলতো চাপুন';

  @override
  String get commonHasBeenReceived => 'গৃহীত হয়েছে';

  @override
  String get commonGetLucky => 'ভাগ্যবান হন';

  @override
  String get qrcodeCameraStartFailed => 'ক্যামেরা চালু করতে ব্যর্থ হয়েছে';

  @override
  String get qrcodeUnknownError => 'অজানা ত্রুটি';

  @override
  String get qrcodePlaceQrCodeInFrame =>
      'স্ক্যান করতে ফ্রেমের মধ্যে QR কোড রাখুন';

  @override
  String get qrcodeCloseManualInput => 'ম্যানুয়াল ইনপুট বন্ধ করুন';

  @override
  String get qrcodeManualInputUserId => 'ম্যানুয়াল ইনপুট ইউজার আইডি';

  @override
  String get commonAdd => 'যোগ করুন';

  @override
  String get profileSetStatus => 'স্থিতি সেট করুন';

  @override
  String get profileVisibleToFriends24h =>
      '24 ঘন্টার জন্য বন্ধুদের কাছে দৃশ্যমান৷';

  @override
  String get profileWriteStatus => 'স্ট্যাটাস লিখুন';

  @override
  String get profileEnterYourStatus => 'আপনার স্ট্যাটাস লিখুন...';

  @override
  String get profileOk => 'ঠিক আছে';

  @override
  String get qrcodeCameraPermissionRequired =>
      'QR কোড স্ক্যান করতে ক্যামেরার অনুমতি প্রয়োজন';

  @override
  String get qrcodeCameraPermissionDenied =>
      'ক্যামেরার অনুমতি স্থায়ীভাবে অস্বীকার করা হয়েছে৷ সিস্টেম সেটিংসে এটি সক্রিয় করুন.';

  @override
  String qrcodePermissionCheckError(String error) {
    return 'অনুমতি পরীক্ষা করার সময় ত্রুটি: $error';
  }

  @override
  String get qrcodeInvalidQrCode => 'অবৈধ QR কোড';

  @override
  String qrcodeCannotAddFriend(String error) {
    return 'বন্ধু যোগ করা যাবে না: $error';
  }

  @override
  String get qrcodeScanQrCode => 'QR কোড স্ক্যান করুন';

  @override
  String get qrcodeCheckingCameraPermission =>
      'ক্যামেরার অনুমতি পরীক্ষা করা হচ্ছে...';

  @override
  String get qrcodeNeedCameraPermission => 'ক্যামেরা অনুমতি প্রয়োজন';

  @override
  String get qrcodeRetryPermission => 'আবার চেষ্টা করুন';

  @override
  String get qrcodeOpenSettings => 'সেটিংস খুলুন';

  @override
  String get groupInviteMembers => 'সদস্যদের আমন্ত্রণ';

  @override
  String groupInviteCount(int count) {
    return 'আমন্ত্রণ ($count)';
  }

  @override
  String get profileNoShippingAddress => 'কোন শিপিং ঠিকানা';

  @override
  String get profileDefaultLabel => 'ডিফল্ট';

  @override
  String get profileNoInvoice => 'চালান নেই';

  @override
  String get profileCompany => 'কোম্পানি';

  @override
  String get profileTaxNumber => 'ট্যাক্স নম্বর';

  @override
  String get profileConfirmDeleteAddress =>
      'আপনি কি এই ঠিকানাটি মুছে ফেলার বিষয়ে নিশ্চিত?';

  @override
  String get profileConfirmDeleteInvoice =>
      'আপনি কি এই চালানটি মুছে ফেলার বিষয়ে নিশ্চিত?';

  @override
  String get commonGroupOwner => 'মালিক';

  @override
  String get commonGroupAdmin => 'অ্যাডমিন';

  @override
  String get groupSearchMembers => 'সদস্যদের অনুসন্ধান করুন';

  @override
  String groupTotalMembers(int count) {
    return '$count সদস্য';
  }

  @override
  String get chatRemoveFromGroup => 'গ্রুপ থেকে সরান';

  @override
  String groupConfirmRemoveMember(String name) {
    return 'আপনি কি গ্রুপ থেকে \"$name\" সরানোর বিষয়ে নিশ্চিত?';
  }

  @override
  String get chatUnknownSong => 'অজানা গান';

  @override
  String get chatUnknownArtist => 'অচেনা শিল্পী';

  @override
  String get chatUnknownContact => 'অজানা পরিচিতি';

  @override
  String get chatPersonalCard => 'যোগাযোগ কার্ড';

  @override
  String get chatSingleChoice => 'একক';

  @override
  String get chatMultiChoice => 'মাল্টি';

  @override
  String get chatEnded => 'শেষ হয়েছে';

  @override
  String get chatEndPollButton => 'পোল শেষ করুন';

  @override
  String get chatPollHint =>
      'পোল চ্যাটে প্রদর্শিত হবে। গ্রুপের সদস্যরা ভোট দিতে পারবেন।';

  @override
  String get chatSearchSongOrArtist => 'গান বা শিল্পী খুঁজুন';

  @override
  String get chatNoSongsFound => 'কোনো গান পাওয়া যায়নি';

  @override
  String get chatSongNameOptional => 'গানের নাম (ঐচ্ছিক)';

  @override
  String get chatEnterSongName => 'গানের নাম লিখুন';

  @override
  String get chatArtistNameOptional => 'শিল্পীর নাম (ঐচ্ছিক)';

  @override
  String get chatEnterArtistName => 'শিল্পীর নাম লিখুন';

  @override
  String get chatRealTimeLocationSharing =>
      'উন্নয়নে রিয়েল-টাইম লোকেশন শেয়ারিং...';

  @override
  String get profileVoiceCallFeatureInDev => 'ডেভেলপমেন্টে ভয়েস কল ফিচার...';

  @override
  String get profileReportFeatureInDev =>
      'উন্নয়নে বৈশিষ্ট্য প্রতিবেদন করুন...';

  @override
  String get profileShareFeatureInDev => 'উন্নয়নে বৈশিষ্ট্য শেয়ার করুন...';

  @override
  String get profileQrCodeFeatureInDev => 'QR কোড বৈশিষ্ট্য বিকাশে...';

  @override
  String get qrcodeScanQrToAddMe =>
      'আমাকে বন্ধু হিসেবে যুক্ত করতে উপরের QR কোডটি স্ক্যান করুন';

  @override
  String get qrcodeSaveToAlbum => 'অ্যালবামে সংরক্ষণ করুন';

  @override
  String get qrcodeChangeStyle => 'স্টাইল পরিবর্তন করুন';

  @override
  String get qrcodeCopyId => 'আইডি কপি করুন';

  @override
  String get qrcodeIdCopied => 'আইডি কপি করা হয়েছে';

  @override
  String get qrcodeMoreStylesFeatureComingSoon => 'আরো শৈলী শীঘ্রই আসছে';

  @override
  String get profileBio => 'বায়ো';

  @override
  String get profileHomeServer => 'সার্ভার';

  @override
  String get profileShareContactCard => 'যোগাযোগ কার্ড শেয়ার করুন';

  @override
  String get profileRemoveFromBlacklist => 'কালো তালিকা থেকে সরান';

  @override
  String get profileConfirmAddBlacklist =>
      'আপনি কি এই ব্যবহারকারীকে কালো তালিকায় যুক্ত করার বিষয়ে নিশ্চিত? আপনি তাদের কাছ থেকে বার্তা পাবেন না.';

  @override
  String get profileConfirmRemoveBlacklist =>
      'আপনি কি এই ব্যবহারকারীকে কালো তালিকা থেকে সরানোর বিষয়ে নিশ্চিত?';

  @override
  String get profileRemarkSaved => 'মন্তব্য সংরক্ষিত';

  @override
  String get profileRemarkCleared => 'মন্তব্য সাফ করা হয়েছে';

  @override
  String get transferReceive => 'গ্রহণ করুন';

  @override
  String get transferPleaseConnectWallet => 'প্রথমে আপনার ওয়ালেট সংযোগ করুন';

  @override
  String get transferSendRequest => 'অনুরোধ পাঠান';

  @override
  String get transferPleaseEnterValidAmount => 'একটি বৈধ পরিমাণ লিখুন';

  @override
  String get searchPlaceholder => 'পরিচিতি, গোষ্ঠী, বার্তা অনুসন্ধান করুন';

  @override
  String get searchEnterKeywordToSearch =>
      'অনুসন্ধান শুরু করতে কীওয়ার্ড লিখুন';

  @override
  String get searchClearHistory => 'পরিষ্কার';

  @override
  String searchNoResultsForQuery(String query) {
    return '\"$query\" এর জন্য কোন ফলাফল পাওয়া যায়নি';
  }

  @override
  String get searchAllResults => 'সব';

  @override
  String get searchInChat => 'চ্যাটে অনুসন্ধান করুন';

  @override
  String get searchContactLabel => 'যোগাযোগ';

  @override
  String get searchGroupLabel => 'গ্রুপ';

  @override
  String get searchConversationLabel => 'কথোপকথন';

  @override
  String get searchMessageLabel => 'বার্তা';

  @override
  String get settingsSecurityTitle => 'নিরাপত্তা';

  @override
  String get settingsKeyBackup => 'কী ব্যাকআপ';

  @override
  String get settingsBackupEncryptionKeys => 'ব্যাকআপ এনক্রিপশন কী';

  @override
  String settingsKeysBackedUp(int count) {
    return '$count কী ব্যাক আপ করা হয়েছে৷';
  }

  @override
  String get settingsBackupNotSet => 'ব্যাকআপ সেট করা হয়নি';

  @override
  String get settingsRestoreKeys => 'কী পুনরুদ্ধার করুন';

  @override
  String get settingsRestoreKeysFromBackup =>
      'ব্যাকআপ থেকে এনক্রিপশন কী পুনরুদ্ধার করুন';

  @override
  String get settingsExportKeys => 'রপ্তানি কী';

  @override
  String get settingsExportKeysToFile => 'ফাইলে কী রপ্তানি করুন';

  @override
  String get settingsLoggedInDevices => 'লগ ইন ডিভাইস';

  @override
  String get settingsNoOtherDevices => 'অন্য কোনো ডিভাইস নেই';

  @override
  String get settingsVerified => 'যাচাই করা হয়েছে';

  @override
  String get settingsUnverified => 'যাচাই করা হয়নি';

  @override
  String get settingsAdvanced => 'উন্নত';

  @override
  String get settingsCrossSigning => 'ক্রস সাইনিং';

  @override
  String get settingsEnabled => 'সক্রিয়';

  @override
  String get settingsNotEnabled => 'সক্রিয় করা হয়নি';

  @override
  String get settingsResetEncryption => 'এনক্রিপশন রিসেট করুন';

  @override
  String get settingsDeleteAllEncryptionKeys => 'সমস্ত এনক্রিপশন কী মুছুন';

  @override
  String get settingsEncryptionNotSupported => 'এনক্রিপশন সমর্থিত নয়';

  @override
  String get settingsNotInitialized => 'আরম্ভ করা হয়নি';

  @override
  String get settingsBackupKeyTitle => 'ব্যাকআপ কী';

  @override
  String get settingsBackupKeyMessage =>
      'একটি নতুন কী ব্যাকআপ তৈরি করবেন? এটি আপনাকে একটি নতুন ডিভাইসে এনক্রিপ্ট করা বার্তাগুলি পুনরুদ্ধার করতে সহায়তা করবে৷';

  @override
  String get settingsBackup => 'ব্যাকআপ';

  @override
  String get settingsRestoreKeyTitle => 'কী পুনরুদ্ধার করুন';

  @override
  String get settingsRestoreKeyMessage =>
      'এনক্রিপ্ট করা বার্তাগুলি পুনরুদ্ধার করতে আপনার পুনরুদ্ধারের পাসওয়ার্ড বা পুনরুদ্ধার কী লিখুন৷';

  @override
  String get settingsRestore => 'পুনরুদ্ধার করুন';

  @override
  String get settingsExportKeyTitle => 'রপ্তানি কী';

  @override
  String get settingsExportKeyMessage =>
      'এক্সপোর্ট করা কী ফাইলটিতে আপনার সমস্ত এনক্রিপশন কী রয়েছে৷ দয়া করে নিরাপদে রাখুন।';

  @override
  String get settingsExport => 'রপ্তানি';

  @override
  String settingsDeviceIdLabel(String deviceId) {
    return 'ডিভাইস আইডি: $deviceId';
  }

  @override
  String get settingsDeviceStatusVerified => 'স্থিতি: যাচাই করা হয়েছে';

  @override
  String get settingsDeviceStatusUnverified => 'স্থিতি: যাচাই করা হয়নি';

  @override
  String settingsLastActiveLabel(String lastSeen) {
    return 'সর্বশেষ সক্রিয়: $lastSeen';
  }

  @override
  String get settingsVerifyThisDevice => 'এই ডিভাইসটি যাচাই করুন';

  @override
  String get settingsCrossSigningAlreadyEnabled =>
      'ক্রস সাইনিং ইতিমধ্যেই সক্ষম হয়েছে৷';

  @override
  String get settingsCrossSigningSetupSuccess =>
      'ক্রস-সাইনিং সেটআপ সফল হয়েছে৷';

  @override
  String get settingsResetEncryptionTitle => 'এনক্রিপশন রিসেট করুন';

  @override
  String get settingsResetEncryptionWarning =>
      'সতর্কতা: এটি আপনার সমস্ত এনক্রিপশন কী মুছে ফেলবে৷ আপনি আগের এনক্রিপ্ট করা বার্তাগুলিকে ডিক্রিপ্ট করতে পারবেন না৷ এই ক্রিয়াটি পূর্বাবস্থায় ফেরানো যাবে না৷';

  @override
  String get settingsReset => 'রিসেট করুন';

  @override
  String get settingsBackupSuccess => 'কী সফলভাবে ব্যাক আপ করা হয়েছে৷';

  @override
  String get settingsBackupFailed => 'ব্যাকআপ ব্যর্থ হয়েছে৷';

  @override
  String get settingsRecoveryKey => 'পুনরুদ্ধার কী';

  @override
  String get settingsRecoveryKeySaveWarning =>
      'অনুগ্রহ করে এই পুনরুদ্ধার কীটি নিরাপদ স্থানে সংরক্ষণ করুন। একটি নতুন ডিভাইসে আপনার এনক্রিপ্ট করা বার্তাগুলি পুনরুদ্ধার করতে আপনার এটির প্রয়োজন হবে৷';

  @override
  String get settingsRecoveryKeySaved => 'আমি এটা সংরক্ষণ করেছি';

  @override
  String get settingsRestoreSuccess => 'কী সফলভাবে পুনরুদ্ধার করা হয়েছে৷';

  @override
  String get settingsRestoreFailed => 'পুনরুদ্ধার ব্যর্থ হয়েছে';

  @override
  String get settingsPassword => 'পাসওয়ার্ড';

  @override
  String get settingsEnterRecoveryKey => 'পুনরুদ্ধার কী লিখুন';

  @override
  String get settingsEnterPassword => 'পাসওয়ার্ড লিখুন';

  @override
  String get settingsExportSuccess =>
      'সার্ভার ব্যাকআপে কী সফলভাবে রপ্তানি করা হয়েছে৷';

  @override
  String get settingsExportNeedBackupFirst =>
      'অনুগ্রহ করে প্রথমে একটি কী ব্যাকআপ তৈরি করুন৷';

  @override
  String get settingsExportFailed => 'রপ্তানি ব্যর্থ হয়েছে৷';

  @override
  String get settingsResetSuccess => 'এনক্রিপশন রিসেট সফল হয়েছে';

  @override
  String get settingsResetFailed => 'রিসেট ব্যর্থ হয়েছে';

  @override
  String get callLeaveMeetingConfirm =>
      'আপনি কি মিটিং ছেড়ে যাওয়ার বিষয়ে নিশ্চিত?';

  @override
  String chatPokedSomeone(String name, String suffix) {
    return 'poked $name$suffix';
  }

  @override
  String get chatNoContactsToAdd => 'যোগ করার জন্য কোনো পরিচিতি উপলব্ধ নেই৷';

  @override
  String get chatAddMembers => 'সদস্য যোগ করুন';

  @override
  String chatInvitedMembers(int count) {
    return 'আমন্ত্রিত $count সদস্য';
  }

  @override
  String chatInviteFailed(String error) {
    return 'আমন্ত্রণ ব্যর্থ হয়েছে: $error';
  }

  @override
  String get chatMemberRemoved => 'সদস্য সরানো হয়েছে';

  @override
  String chatRemoveFailed(String error) {
    return 'সরানো ব্যর্থ হয়েছে: $error';
  }

  @override
  String get chatRealTimeLocationShareMessage =>
      'শেয়ার করার পরে, অন্য পক্ষ 1 ঘন্টার জন্য আপনার রিয়েল-টাইম অবস্থান দেখতে পাবে।';

  @override
  String get chatStartSharing => 'শেয়ার করা শুরু করুন';

  @override
  String get chatLocationServiceNotEnabled => 'অবস্থান পরিষেবা সক্ষম করা নেই৷';

  @override
  String get chatEnableLocationService =>
      'এই বৈশিষ্ট্যটি ব্যবহার করতে অনুগ্রহ করে অবস্থান পরিষেবা সক্ষম করুন৷';

  @override
  String get chatGoToSettings => 'সেটিংসে যান';

  @override
  String get chatLocationPermissionRequired =>
      'এই বৈশিষ্ট্যটির জন্য অবস্থানের অনুমতি প্রয়োজন৷';

  @override
  String get chatLocationPermissionDeniedPermanent =>
      'অবস্থানের অনুমতি স্থায়ীভাবে অস্বীকার করা হয়েছে৷ সেটিংসে এটি সক্রিয় করুন.';

  @override
  String get chatLocationPermissionDenied =>
      'অবস্থানের অনুমতি অস্বীকার করা হয়েছে৷';

  @override
  String get chatGettingLocation => 'অবস্থান পাওয়া যাচ্ছে...';

  @override
  String chatGetLocationFailed(String error) {
    return 'অবস্থান পেতে ব্যর্থ: $error';
  }

  @override
  String get chatMapPreview => 'মানচিত্রের পূর্বরূপ';

  @override
  String get chatSearchLocation => 'অবস্থান অনুসন্ধান করুন';

  @override
  String chatRedPacketSent(String amount, String token) {
    return '$amount $token লাল প্যাকেট পাঠানো হয়েছে';
  }

  @override
  String get chatTransferDefault => 'স্থানান্তর';

  @override
  String chatTransferSent(String amount, String token) {
    return '$amount $token স্থানান্তর পাঠানো হয়েছে৷';
  }

  @override
  String chatPickFileFailed(String error) {
    return 'ফাইল বাছাই করতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String get chatFileSizeLimit => 'ফাইলের আকার 50MB এর বেশি হতে পারে না';

  @override
  String chatFileSending(String filename) {
    return 'ফাইল পাঠানো হচ্ছে: $filename';
  }

  @override
  String chatSendFileFailed(String error) {
    return 'ফাইল পাঠাতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String chatContactCardSent(String name) {
    return '$name এর পরিচিতি কার্ড পাঠানো হয়েছে৷';
  }

  @override
  String get chatFavoritesFeature => 'প্রিয়';

  @override
  String get chatCouponsFeature => 'কুপন';

  @override
  String get chatGiftFeature => 'উপহার';

  @override
  String chatSharedMusic(String name) {
    return 'শেয়ার করা $name';
  }

  @override
  String get chatEndPollTitle => 'পোল শেষ করুন';

  @override
  String get chatEndPollConfirmMessage =>
      'আপনি কি এই পোলটি শেষ করতে চান? ভোট শেষ হওয়ার পর বন্ধ হয়ে যাবে।';

  @override
  String get chatPollEndedMessage => 'পোল শেষ হয়েছে';

  @override
  String get chatConnectingCall => 'সংযোগ করা হচ্ছে...';

  @override
  String get chatMuteCall => 'নিঃশব্দ';

  @override
  String get chatSpeakerOff => 'স্পিকার বন্ধ';

  @override
  String get chatSpeakerOn => 'স্পিকার';

  @override
  String get chatCameraOn => 'ক্যামেরা চালু';

  @override
  String get chatCameraOff => 'ক্যামেরা বন্ধ';

  @override
  String get chatHangUp => 'হ্যাং আপ';

  @override
  String get chatSelectForwardTargetTitle => 'ফরোয়ার্ড টার্গেট নির্বাচন করুন';

  @override
  String get chatNoForwardableChat => 'ফরওয়ার্ড করার জন্য কোন চ্যাট উপলব্ধ';

  @override
  String get chatNoMatchingChat => 'কোন মিল চ্যাট পাওয়া যায়নি';

  @override
  String get chatLocationTitle => 'অবস্থান';

  @override
  String get chatSendButton => 'পাঠান';

  @override
  String get chatRetryButton => 'আবার চেষ্টা করুন';

  @override
  String get chatSearchContactHint => 'পরিচিতি অনুসন্ধান করুন';

  @override
  String get chatShareMusic => 'সঙ্গীত শেয়ার করুন';

  @override
  String get chatRecentPlayed => 'সাম্প্রতিক';

  @override
  String get chatMyFavorites => 'প্রিয়';

  @override
  String get chatNetworkLink => 'লিঙ্ক';

  @override
  String get chatLocalFile => 'স্থানীয়';

  @override
  String get chatPasteMusicLink => 'সঙ্গীত লিঙ্ক আটকান';

  @override
  String get chatShareMusicButton => 'সঙ্গীত শেয়ার করুন';

  @override
  String get chatSelectLocalAudio => 'স্থানীয় অডিও ফাইল নির্বাচন করুন';

  @override
  String get chatSupportedAudioFormats =>
      'MP3, M4A, WAV, FLAC, ইত্যাদি সমর্থন করে।';

  @override
  String get chatSelectFileButton => 'ফাইল নির্বাচন করুন';

  @override
  String get chatPleaseEnterMusicLink => 'সঙ্গীত লিঙ্ক লিখুন দয়া করে';

  @override
  String get chatPleaseEnterValidLink => 'একটি বৈধ URL লিখুন';

  @override
  String get chatSharedSong => 'শেয়ার করা গান';

  @override
  String get chatSelectMember => 'সদস্য নির্বাচন করুন';

  @override
  String get chatSearchMemberHint => 'সদস্যদের অনুসন্ধান করুন';

  @override
  String get chatNoMatchingMembers => 'কোন মিলিত সদস্য পাওয়া যায়নি';

  @override
  String get commonUnknownMember => 'অজানা';

  @override
  String chatSelectedMessagesCount(int count) {
    return 'নির্বাচিত $count বার্তা';
  }

  @override
  String get chatSearchContactsOrGroups => 'পরিচিতি বা গোষ্ঠী অনুসন্ধান করুন';

  @override
  String get chatVideoTitle => 'ভিডিও';

  @override
  String get chatLoadingText => 'লোড হচ্ছে...';

  @override
  String get chatVideoLoadFailed => 'ভিডিও লোড ব্যর্থ হয়েছে';

  @override
  String get chatPlayerInitFailed => 'প্লেয়ার সূচনা ব্যর্থ হয়েছে';

  @override
  String get chatCreatePollTitle => 'পোল তৈরি করুন';

  @override
  String get chatSubmitPoll => 'জমা দিন';

  @override
  String get chatPollQuestionLabel => 'পোল প্রশ্ন';

  @override
  String get chatEnterPollQuestionHint => 'ভোট প্রশ্ন লিখুন দয়া করে';

  @override
  String get chatPollOptionsLabel => 'পোল বিকল্প';

  @override
  String chatOptionHintWithIndex(int index) {
    return 'বিকল্প $index';
  }

  @override
  String get chatAddOptionButton => 'বিকল্প যোগ করুন';

  @override
  String get chatPollSettingsLabel => 'পোল সেটিংস';

  @override
  String get chatSelectionType => 'নির্বাচনের ধরন';

  @override
  String get chatSingleChoiceLabel => 'একক';

  @override
  String get chatMultiChoiceLabel => 'মাল্টি';

  @override
  String get chatAnonymousPollSwitch => 'বেনামী পোল';

  @override
  String get chatPleaseEnterQuestion => 'ভোট প্রশ্ন লিখুন দয়া করে';

  @override
  String get chatAtLeastTwoOptions => 'কমপক্ষে 2টি বিকল্প প্রয়োজন';

  @override
  String chatConfirmWithCount(int count) {
    return 'নিশ্চিত করুন ($count)';
  }

  @override
  String get authEmailVerificationTitle => 'ইমেল যাচাইকরণ';

  @override
  String get authEnterValidEmailAddress => 'একটি বৈধ ইমেল ঠিকানা লিখুন';

  @override
  String authVerificationCodeSentTo(String email) {
    return 'যাচাইকরণ কোড $email এ পাঠানো হয়েছে';
  }

  @override
  String authSendCodeFailed(String error) {
    return 'কোড পাঠাতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String get authVerificationSuccess => 'যাচাইকরণ সফল হয়েছে';

  @override
  String get authVerificationFailed => 'যাচাইকরণ ব্যর্থ হয়েছে৷';

  @override
  String authVerificationCodeError(String error) {
    return 'যাচাইকরণ কোড ত্রুটি: $error';
  }

  @override
  String get commonEnterVerificationCode => 'যাচাইকরণ কোড লিখুন';

  @override
  String get authEnterYourEmail => 'ইমেইল লিখুন';

  @override
  String authWeSentCodeTo(String email) {
    return 'আমরা একটি 6-সংখ্যার কোড পাঠিয়েছি\n$email';
  }

  @override
  String get authEnterEmailForCode =>
      'আপনার ইমেল ঠিকানা লিখুন, আমরা যাচাইকরণ কোড পাঠাব';

  @override
  String get commonSendVerificationCode => 'যাচাইকরণ কোড পাঠান';

  @override
  String get authResendVerificationCode => 'যাচাইকরণ কোড পুনরায় পাঠান';

  @override
  String authCanResendAfter(int seconds) {
    return '$seconds সেকেন্ড পরে আবার পাঠাতে পারেন';
  }

  @override
  String get commonChangeEmail => 'ইমেইল পরিবর্তন করুন';

  @override
  String get contactAddToContacts => 'পরিচিতিতে যোগ করুন';

  @override
  String get contactAddingToContacts => 'যোগ করা হচ্ছে...';

  @override
  String get contactAddedToContacts => 'পরিচিতি যোগ করা হয়েছে';

  @override
  String contactAddFailedWithError(String error) {
    return 'যোগ করা ব্যর্থ হয়েছে: $error';
  }

  @override
  String get contactAddPhone => 'ফোন যোগ করুন';

  @override
  String get contactAddTag => 'ট্যাগ যোগ করুন';

  @override
  String get contactAddText => 'পাঠ্য যোগ করুন';

  @override
  String get contactAddPhoto => 'ফটো যোগ করুন';

  @override
  String contactGroupCountLabel(int count) {
    return '$count গ্রুপ';
  }

  @override
  String get contactAddedViaSearch => 'অনুসন্ধানের মাধ্যমে যোগ করা হয়েছে';

  @override
  String get contactAddTime => 'সময় যোগ করুন';

  @override
  String get contactDoneButton => 'সম্পন্ন';

  @override
  String get callWaitingForParticipants =>
      'অংশগ্রহণকারীদের যোগদানের জন্য অপেক্ষা করা হচ্ছে...';

  @override
  String callParticipantMe(String name) {
    return '$name (আমি)';
  }

  @override
  String get callSharingLabel => 'শেয়ারিং';

  @override
  String callScreenSharingBy(String name) {
    return '$name স্ক্রিন শেয়ার করছে';
  }

  @override
  String callParticipantCount(int count) {
    return '$count অংশগ্রহণকারীরা';
  }

  @override
  String get callMuteLabel => 'নিঃশব্দ';

  @override
  String get callUnmuteLabel => 'আনমিউট করুন';

  @override
  String get callTurnOffVideo => 'ভিডিও বন্ধ করুন';

  @override
  String get callTurnOnVideo => 'ভিডিও চালু করুন';

  @override
  String get callShareScreen => 'স্ক্রিন শেয়ার করুন';

  @override
  String get callStopSharing => 'শেয়ার করা বন্ধ করুন';

  @override
  String get callSwitchCameraLabel => 'সুইচ';

  @override
  String get callLeaveLabel => 'ছেড়ে দিন';

  @override
  String get callParticipantsLabel => 'অংশগ্রহণকারীরা';

  @override
  String get callJoiningMeeting => 'মিটিংয়ে যোগদান করা হচ্ছে...';

  @override
  String chatPollVotesFormat(int count, String percentage) {
    return '$count ভোট ($percentage%)';
  }

  @override
  String chatPollParticipantsFormat(int count) {
    return '$count অংশগ্রহণকারীরা';
  }

  @override
  String get commonTapToRetry => 'আবার চেষ্টা করতে আলতো চাপুন';

  @override
  String get chatDefaultRedPacketGreeting => 'সমৃদ্ধির জন্য শুভ কামনা';

  @override
  String get groupAllowOthersToSearchAndJoin =>
      'অন্যদের অনুসন্ধান এবং যোগদান করার অনুমতি দিন';

  @override
  String get groupConfirmClearChatHistory =>
      'আপনি কি চ্যাটের ইতিহাস মুছে ফেলার বিষয়ে নিশ্চিত?';

  @override
  String get groupCreateGroupToChat => 'চ্যাটিং শুরু করতে একটি গ্রুপ তৈরি করুন';

  @override
  String get groupEditGroupAnnouncement => 'গ্রুপ ঘোষণা সম্পাদনা করুন';

  @override
  String get groupEditGroupDescription => 'গ্রুপের বিবরণ সম্পাদনা করুন';

  @override
  String get groupEnterGroupAnnouncement => 'গ্রুপ ঘোষণা লিখুন';

  @override
  String chatErrorWithMessage(String message) {
    return 'ত্রুটি: $message';
  }

  @override
  String groupMemberCountClickToCopy(int count) {
    return '$count সদস্য, গ্রুপ আইডি কপি করতে ক্লিক করুন';
  }

  @override
  String get chatMusicLinkLabel => 'সঙ্গীত লিঙ্ক';

  @override
  String get chatNoMediaUrlAvailable => 'কোনো মিডিয়া URL উপলব্ধ নেই৷';

  @override
  String get groupNoPermissionToEditGroupName =>
      'আপনার গ্রুপের নাম সম্পাদনা করার অনুমতি নেই';

  @override
  String get chatRedPacketTransferCannotForward =>
      'লাল প্যাকেট এবং স্থানান্তর ফরোয়ার্ড করা যাবে না';

  @override
  String get authEmailAddress => 'ইমেইল ঠিকানা';

  @override
  String get commonEnterEmailAddress => 'ইমেল ঠিকানা লিখুন';

  @override
  String get authEmailRecoveryHint => 'পাসওয়ার্ড পুনরুদ্ধারের জন্য ব্যবহৃত';

  @override
  String get commonInvalidEmailFormat => 'একটি বৈধ ইমেল ঠিকানা লিখুন';

  @override
  String get authOptional => 'ঐচ্ছিক';

  @override
  String get authResetPassword => 'পাসওয়ার্ড রিসেট করুন';

  @override
  String get authEnterRegisteredEmail => 'আপনি নিবন্ধিত ইমেল ঠিকানা লিখুন';

  @override
  String get authSendResetCode => 'রিসেট কোড পাঠান';

  @override
  String authResetCodeSent(String email) {
    return '$email এ পাঠানো কোড রিসেট করুন';
  }

  @override
  String get authEnterResetCode => 'রিসেট কোড লিখুন';

  @override
  String get authSetNewPassword => 'নতুন পাসওয়ার্ড সেট করুন';

  @override
  String get commonConfirmNewPassword => 'নতুন পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get commonNewPassword => 'নতুন পাসওয়ার্ড';

  @override
  String get authPasswordResetSuccess =>
      'পাসওয়ার্ড রিসেট সফল হয়েছে। আপনার নতুন পাসওয়ার্ড দিয়ে লগইন করুন.';

  @override
  String get authResetPasswordFailed => 'পাসওয়ার্ড রিসেট ব্যর্থ হয়েছে';

  @override
  String get settingsChangePassword => 'পাসওয়ার্ড পরিবর্তন করুন';

  @override
  String get settingsCurrentPassword => 'বর্তমান পাসওয়ার্ড';

  @override
  String get settingsEnterCurrentPassword => 'বর্তমান পাসওয়ার্ড লিখুন';

  @override
  String get settingsEnterNewPassword => 'নতুন পাসওয়ার্ড দিন';

  @override
  String get settingsPasswordChanged =>
      'পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে। আপনার নতুন পাসওয়ার্ড দিয়ে লগইন করুন.';

  @override
  String get settingsChangePasswordFailed =>
      'পাসওয়ার্ড পরিবর্তন ব্যর্থ হয়েছে';

  @override
  String get settingsNewPasswordMustBeDifferent =>
      'নতুন পাসওয়ার্ড বর্তমান পাসওয়ার্ড থেকে আলাদা হতে হবে';

  @override
  String get settingsChangePasswordInfo =>
      'পাসওয়ার্ড পরিবর্তন করার পরে, আপনি লগ আউট হবেন এবং নতুন পাসওয়ার্ড দিয়ে লগইন করতে হবে।';

  @override
  String get settingsPasswordRequirements => 'পাসওয়ার্ডের প্রয়োজনীয়তা:';

  @override
  String get settingsSecurityNote =>
      'নিরাপত্তার জন্য, পাসওয়ার্ড পরিবর্তন করার পরে আপনাকে সমস্ত ডিভাইসে পুনরায় লগইন করতে হবে।';

  @override
  String get settingsSecurity => 'নিরাপত্তা';

  @override
  String get settingsCurrentBoundEmail => 'বর্তমান আবদ্ধ ইমেল';

  @override
  String get settingsNewEmailAddress => 'নতুন ইমেইল ঠিকানা';

  @override
  String get settingsEnterNewEmail => 'নতুন ইমেল ঠিকানা লিখুন';

  @override
  String get settingsVerificationCode => 'যাচাইকরণ কোড';

  @override
  String get settingsVerificationCodeSent => 'যাচাইকরণ কোড পাঠানো হয়েছে';

  @override
  String get settingsCodeSentTo => 'যাচাইকরণ কোড পাঠানো হয়েছে';

  @override
  String get settingsDidNotReceiveCode => 'কোডটি পাননি?';

  @override
  String get settingsEmailChangedSuccess => 'ইমেল সফলভাবে পরিবর্তিত হয়েছে';

  @override
  String get settingsChangeEmailFailed => 'ইমেল পরিবর্তন ব্যর্থ হয়েছে';

  @override
  String get settingsEmailSecurityNote =>
      'আপনার ইমেল পাসওয়ার্ড পুনরুদ্ধারের জন্য ব্যবহার করা হয়. এটা সুরক্ষিত রাখুন.';

  @override
  String get commonGoogleLogin => 'Google দিয়ে সাইন ইন করুন';

  @override
  String get commonAppleLogin => 'অ্যাপল দিয়ে সাইন ইন করুন';

  @override
  String get commonWechat => 'WeChat';

  @override
  String get settingsLanguage => 'ভাষা';

  @override
  String get settingsLanguageChanged => 'ভাষা পরিবর্তন হয়েছে';

  @override
  String get settingsTranslation => 'অনুবাদ';

  @override
  String get settingsTranslateTextTo => 'এতে পাঠ্য অনুবাদ করুন';

  @override
  String get settingsTranslateDescription =>
      'আপনি যে ভাষায় বার্তাগুলি অনুবাদ করতে চান তা নির্বাচন করুন৷';

  @override
  String get settingsAutoTranslate => 'প্রাপ্ত বার্তা স্বতঃ অনুবাদ করুন';

  @override
  String get settingsAutoTranslateDescription =>
      'আপনার নির্বাচিত ভাষায় চ্যাটে প্রাপ্ত বার্তাগুলি স্বয়ংক্রিয়ভাবে অনুবাদ করুন।';

  @override
  String get settingsBiometricLogin => 'বায়োমেট্রিক লগইন';

  @override
  String authLoginWithBiometric(Object type) {
    return '$type দিয়ে লগইন করুন';
  }

  @override
  String get settingsBiometricLoginEnabled => 'বায়োমেট্রিক লগইন সক্ষম';

  @override
  String get settingsBiometricLoginDisabled => 'বায়োমেট্রিক লগইন নিষ্ক্রিয়';

  @override
  String get settingsEnableBiometricLogin => 'বায়োমেট্রিক লগইন সক্ষম করুন';

  @override
  String get settingsBiometricEnabled =>
      'সক্রিয় - লগইন করতে বায়োমেট্রিক ব্যবহার করুন৷';

  @override
  String get settingsBiometricDisabled => 'অক্ষম - সক্ষম করতে আলতো চাপুন৷';

  @override
  String get settingsBiometricNeedRelogin =>
      'বায়োমেট্রিক লগইন সক্ষম করতে অনুগ্রহ করে লগ আউট করুন এবং আবার লগ ইন করুন৷';

  @override
  String get authOr => 'বা';

  @override
  String get qrcodeCameraPermissionRestricted =>
      'এই ডিভাইসে ক্যামেরা অ্যাক্সেস সীমাবদ্ধ';

  @override
  String get authPasskeyLabel => 'পাসকি';

  @override
  String get authGoogleLabel => 'গুগল';

  @override
  String get authAppleLabel => 'আপেল';

  @override
  String get authSsoLabel => 'এসএসও';

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
  String get profileEnterPokeSuffixHint => 'পোক প্রত্যয় লিখুন, যেমন: কাঁধে';

  @override
  String get groupAlbum => 'গ্রুপ অ্যালবাম';

  @override
  String get groupFiles => 'গ্রুপ ফাইল';

  @override
  String get groupImages => 'ছবি';

  @override
  String get groupVideos => 'ভিডিও';

  @override
  String get groupTotal => 'মোট';

  @override
  String get groupSize => 'আকার';

  @override
  String get groupNoMedia => 'মিডিয়া নেই';

  @override
  String get groupNoMediaDescription => 'এই গ্রুপে এখনো কোন ছবি বা ভিডিও নেই';

  @override
  String get groupDocuments => 'ডক্স';

  @override
  String get groupNoFiles => 'কোনো ফাইল নেই';

  @override
  String get groupNoFilesDescription => 'এই গ্রুপে এখনও কোন ফাইল নেই';

  @override
  String groupDownloadStarted(String filename) {
    return '$filename ডাউনলোড হচ্ছে...';
  }

  @override
  String get contactNoCommonGroups => 'কোন সাধারণ দল নেই';

  @override
  String get contactNoCommonGroupsDescription => 'আপনার মধ্যে কোন দল মিল নেই';

  @override
  String get chatVoiceMessage => 'ভয়েস';

  @override
  String get chatMessage => 'বার্তা';

  @override
  String get conversationHideChat => 'লুকান';

  @override
  String get settingsQuickReply => 'দ্রুত উত্তর';

  @override
  String get commonTranslate => 'অনুবাদ করুন';

  @override
  String get contactCreateTag => 'ট্যাগ তৈরি করুন';

  @override
  String get contactEnterTagName => 'ট্যাগের নাম লিখুন';

  @override
  String get contactEditTag => 'ট্যাগ সম্পাদনা করুন';

  @override
  String get contactDeleteTag => 'ট্যাগ মুছুন';

  @override
  String contactDeleteTagConfirm(String tagName) {
    return 'আপনি কি \"$tagName\" ট্যাগটি মুছতে চান?';
  }

  @override
  String get contactNoTags => 'এখনো কোন ট্যাগ নেই';

  @override
  String get contactFriendPermissions => 'বন্ধু অনুমতি';

  @override
  String get contactSetChatOnly => 'শুধুমাত্র চ্যাট হিসেবে সেট করুন';

  @override
  String get contactChatOnlyDesc =>
      'শুধুমাত্র আপনার সাথে চ্যাট করতে পারেন, অন্যান্য বিষয়বস্তু লুকানো হবে';

  @override
  String get contactHideMyMoments => 'আমার মুহূর্ত লুকান';

  @override
  String get contactHideMyMomentsDesc => 'এই বন্ধু আমার মুহূর্ত দেখতে পারে না';

  @override
  String get contactHideTheirMoments => 'তাদের মুহূর্ত লুকান';

  @override
  String get contactHideTheirMomentsDesc => 'এই বন্ধুর মুহূর্ত দেখুন না';

  @override
  String get contactHideMyStatus => 'আমার স্থিতি লুকান';

  @override
  String get contactHideMyStatusDesc =>
      'এই বন্ধু আমার স্ট্যাটাস আপডেট দেখতে পারে না';

  @override
  String get contactNoChatOnlyFriends => 'কোন চ্যাট শুধুমাত্র বন্ধু';

  @override
  String get contactNoOfficialAccounts => 'কোন অফিসিয়াল অ্যাকাউন্ট নেই';

  @override
  String get contactFollowOfficialAccountsDesc =>
      'সর্বশেষ আপডেট পেতে অফিসিয়াল অ্যাকাউন্ট অনুসরণ করুন';

  @override
  String get contactNoServiceAccounts => 'কোনো পরিষেবা অ্যাকাউন্ট নেই';

  @override
  String get contactSubscribeServiceAccountsDesc =>
      'সুবিধাজনক পরিষেবার জন্য পরিষেবা অ্যাকাউন্টগুলিতে সদস্যতা নিন';

  @override
  String get contactNoEnterpriseContacts => 'কোনো এন্টারপ্রাইজ পরিচিতি নেই';

  @override
  String get contactEnterpriseContactsDesc =>
      'এন্টারপ্রাইজ পরিচিতি এখানে প্রদর্শিত হবে';

  @override
  String get profileCardPack => 'কার্ড প্যাক';

  @override
  String get profileOrders => 'আদেশ';

  @override
  String get profileNoOrders => 'কোন আদেশ নেই';

  @override
  String get profileOrdersDesc => 'আপনার অর্ডার এখানে প্রদর্শিত হবে';

  @override
  String get profileNoCards => 'কোনো কার্ড নেই';

  @override
  String get profileCardsDesc => 'আপনার কার্ড এখানে প্রদর্শিত হবে';

  @override
  String get favoriteEnterTagsHint => 'কমা দ্বারা পৃথক ট্যাগ লিখুন';

  @override
  String get favoriteTagsUpdated => 'ট্যাগ আপডেট করা হয়েছে';

  @override
  String get favoriteForwardedContent => 'বিষয়বস্তু ফরোয়ার্ড';

  @override
  String get favoriteEnterNoteContent => 'নোট বিষয়বস্তু লিখুন';

  @override
  String get favoriteNoteAdded => 'নোট যোগ করা হয়েছে';

  @override
  String get favoriteLinkTitle => 'লিঙ্ক শিরোনাম';

  @override
  String get favoriteLinkUrl => 'https://';

  @override
  String get favoriteLinkAdded => 'লিঙ্ক যোগ করা হয়েছে';

  @override
  String get contactPhotoAdded => 'ছবি যোগ করা হয়েছে';

  @override
  String get contactEnterPhone => 'ফোন নম্বর লিখুন';

  @override
  String commonConversationWithId(String roomId) {
    return 'কথোপকথন: $roomId';
  }

  @override
  String commonContactWithId(String userId) {
    return 'যোগাযোগ: $userId';
  }

  @override
  String get commonDiscover => 'আবিষ্কার করুন';

  @override
  String commonDeveloping(String title) {
    return '$title\n(শীঘ্রই আসছে)';
  }

  @override
  String get commonPageNotFound => 'পেজ পাওয়া যায়নি';

  @override
  String get commonBackToHome => 'হোমে ফিরে যান';

  @override
  String get settingsMessageNotifications => 'বার্তা বিজ্ঞপ্তি';

  @override
  String get settingsReceiveNewMessageNotifications =>
      'নতুন বার্তা বিজ্ঞপ্তি পান';

  @override
  String get settingsShowMessagePreview => 'বার্তার পূর্বরূপ দেখান';

  @override
  String get settingsShowMessageContentInNotification =>
      'বিজ্ঞপ্তিতে বার্তা সামগ্রী দেখান';

  @override
  String get settingsNotificationSound => 'বিজ্ঞপ্তির শব্দ';

  @override
  String get settingsPlaySoundOnMessage => 'বার্তা গ্রহণ করার সময় শব্দ বাজান';

  @override
  String get commonVibration => 'কম্পন';

  @override
  String get settingsVibrateOnMessage => 'বার্তা পাওয়ার সময় ভাইব্রেট করুন';

  @override
  String get settingsDoNotDisturbMode => 'বিরক্ত করবেন না';

  @override
  String get settingsDoNotDisturbDescription =>
      'নির্দিষ্ট সময়ের মধ্যে বিজ্ঞপ্তি পাবেন না';

  @override
  String get settingsStartTime => 'শুরুর সময়';

  @override
  String get settingsEndTime => 'শেষ সময়';

  @override
  String get settingsDeleteQuickReply => 'দ্রুত উত্তর মুছুন';

  @override
  String get settingsEditQuickReply => 'দ্রুত উত্তর সম্পাদনা করুন';

  @override
  String get settingsAddQuickReply => 'দ্রুত উত্তর যোগ করুন';

  @override
  String get settingsManageQuickReplies => 'দ্রুত উত্তর পরিচালনা করুন';

  @override
  String get settingsNoQuickReplies => 'কোন দ্রুত উত্তর';

  @override
  String get settingsDefaultQuickReplies => 'ডিফল্ট দ্রুত উত্তর দেখানো হবে';

  @override
  String get settingsWhoCanSee => 'কে দেখতে পারে';

  @override
  String get settingsLastSeen => 'শেষ দেখা';

  @override
  String get settingsHiddenChats => 'লুকানো চ্যাট';

  @override
  String get settingsMessagesLabel => 'বার্তা';

  @override
  String get settingsAllowStrangerMessages => 'অপরিচিত বার্তার অনুমতি দিন';

  @override
  String get settingsReceiveMessagesFromNonContacts =>
      'অ-পরিচিতি থেকে বার্তা গ্রহণ';

  @override
  String get settingsReadReceipts => 'রসিদ পড়ুন';

  @override
  String get settingsLetOthersKnowYouRead =>
      'আপনি পড়েছেন তা অন্যদের জানাতে দিন';

  @override
  String get settingsTypingIndicator => 'টাইপিং সূচক';

  @override
  String get settingsLetOthersKnowYouTyping =>
      'আপনি টাইপ করছেন তা অন্যদের জানতে দিন';

  @override
  String get settingsEveryone => 'সবাই';

  @override
  String get settingsContactsOnly => 'শুধুমাত্র পরিচিতি';

  @override
  String get settingsNobody => 'কেউ না';

  @override
  String settingsWhoCanSeeTitle(String title) {
    return 'যারা $title দেখতে পারেন';
  }

  @override
  String settingsVersionInfo(String version) {
    return 'সংস্করণ $version';
  }

  @override
  String get settingsCheckForUpdates => 'আপডেটের জন্য চেক করুন';

  @override
  String get settingsOpenSourceLicenses => 'ওপেন সোর্স লাইসেন্স';

  @override
  String get settingsFeedbackAndSuggestions => 'প্রতিক্রিয়া এবং পরামর্শ';

  @override
  String get settingsBuiltOnMatrix => 'ম্যাট্রিক্স প্রোটোকলের উপর নির্মিত';

  @override
  String get settingsNoHiddenChats => 'কোন লুকানো চ্যাট';

  @override
  String get settingsNoHiddenChatsDescription =>
      'আপনার লুকানো চ্যাট এখানে প্রদর্শিত হবে';

  @override
  String get settingsUnhideChat => 'আড়াল করুন';

  @override
  String get settingsDarkMode => 'ডার্ক মোড';

  @override
  String get settingsFontSize => 'ফন্ট সাইজ';

  @override
  String get settingsBubbleStyle => 'বুদবুদ শৈলী';

  @override
  String get settingsFollowSystem => 'সিস্টেম অনুসরণ করুন';

  @override
  String get settingsAutoSwitchBySystem => 'সিস্টেম দ্বারা স্বয়ংক্রিয় সুইচ';

  @override
  String get settingsLightMode => 'হালকা মোড';

  @override
  String get settingsAlwaysUseLightTheme => 'সর্বদা হালকা থিম ব্যবহার করুন';

  @override
  String get settingsDarkModeOption => 'ডার্ক মোড বিকল্প';

  @override
  String get settingsAlwaysUseDarkTheme => 'সবসময় ডার্ক থিম ব্যবহার করুন';

  @override
  String get settingsFontSizeSmall => 'ছোট';

  @override
  String get settingsFontSizeStandard => 'স্ট্যান্ডার্ড';

  @override
  String get settingsFontSizeLarge => 'বড়';

  @override
  String get settingsFontSizeExtraLarge => 'অতিরিক্ত বড়';

  @override
  String get settingsBubbleStyleWechat => 'WeChat শৈলী';

  @override
  String get settingsBubbleStyleWechatDesc => 'ক্লাসিক WeChat বাবল শৈলী';

  @override
  String get settingsBubbleStyleModern => 'আধুনিক শৈলী';

  @override
  String get settingsBubbleStyleModernDesc => 'পরিষ্কার আধুনিক বুদবুদ শৈলী';

  @override
  String get settingsBubbleStyleClassic => 'ক্লাসিক শৈলী';

  @override
  String get settingsBubbleStyleClassicDesc => 'ঐতিহ্যগত বুদবুদ শৈলী';

  @override
  String get discoverVideoChannels => 'চ্যানেল';

  @override
  String get discoverLive => 'লাইভ';

  @override
  String get discoverListen => 'শুনুন';

  @override
  String get discoverWatch => 'ঘড়ি';

  @override
  String get discoverSearchDiscover => 'অনুসন্ধান করুন';

  @override
  String get discoverNearbyPeople => 'কাছাকাছি';

  @override
  String get discoverGames => 'গেমস';

  @override
  String get discoverMiniPrograms => 'মিনি প্রোগ্রাম';

  @override
  String get chatAlreadyInCall => 'ইতিমধ্যে একটি কল';

  @override
  String get commonConnectionFailed => 'সংযোগ ব্যর্থ হয়েছে৷';

  @override
  String get chatCallRejected => 'কল প্রত্যাখ্যান করা হয়েছে';

  @override
  String get chatNoAnswer => 'কোন উত্তর নেই';

  @override
  String get commonClose => 'বন্ধ';

  @override
  String get chatSelectContact => 'যোগাযোগ নির্বাচন করুন';

  @override
  String get chatVoteRemoved => 'ভোট সরানো হয়েছে';

  @override
  String get chatVoteChanged => 'ভোট পরিবর্তন হয়েছে';

  @override
  String get chatVoted => 'ভোট দিয়েছেন';

  @override
  String chatReplyTo(String name) {
    return '$name এর উত্তর দিন';
  }

  @override
  String get chatCurrentLocation => 'বর্তমান অবস্থান';

  @override
  String chatNearbyPlace(int index) {
    return 'কাছাকাছি জায়গা $index';
  }

  @override
  String chatApproximateDistance(String distance) {
    return '$distance সম্পর্কে';
  }

  @override
  String get chatAddress => 'ঠিকানা';

  @override
  String get chatLatitude => 'অক্ষাংশ';

  @override
  String get chatLongitude => 'দ্রাঘিমাংশ';

  @override
  String get groupDescriptionUpdated => 'গ্রুপের বিবরণ আপডেট করা হয়েছে';

  @override
  String get groupAvatarUpdated => 'গ্রুপ অবতার আপডেট করা হয়েছে';

  @override
  String get groupVisibilityUpdated => 'গ্রুপ দৃশ্যমানতা আপডেট করা হয়েছে';

  @override
  String get groupChannelCreated => 'চ্যানেল তৈরি হয়েছে';

  @override
  String get groupChannelUpdated => 'চ্যানেল আপডেট করা হয়েছে';

  @override
  String get groupChannelDeleted => 'চ্যানেল মুছে ফেলা হয়েছে';

  @override
  String get callDecline => 'প্রত্যাখ্যান';

  @override
  String get callAnswer => 'উত্তর';

  @override
  String get callIncomingVideoCall => 'ইনকামিং ভিডিও কল';

  @override
  String get callIncomingVoiceCall => 'ইনকামিং ভয়েস কল';

  @override
  String get callVideoCallInProgress => 'ভিডিও কল চলছে';

  @override
  String get callVoiceCallInProgress => 'ভয়েস কল চলছে';

  @override
  String get callReconnectingCall => 'পুনরায় সংযোগ করা হচ্ছে...';

  @override
  String get callEnded => 'কল শেষ';

  @override
  String get callFailed => 'কল ব্যর্থ হয়েছে৷';

  @override
  String get callLivekitNotConfigured => 'LiveKit কনফিগার করা হয়নি';

  @override
  String callJoinMeetingFailed(String error) {
    return 'মিটিংয়ে যোগ দিতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String callScreenShareFailed(String error) {
    return 'স্ক্রীন শেয়ার করা ব্যর্থ হয়েছে: $error';
  }

  @override
  String get profileN42BeanTitle => 'N42 বিন';

  @override
  String get profileNoN42Bean => 'N42 বিন নেই';

  @override
  String get profileN42BeanDetails => 'N42 শিমের বিবরণ';

  @override
  String get profileN42BeanDescription =>
      'N42 Bean হল একটি টোকেন যা N42-এ ভার্চুয়াল আইটেম এবং পরিষেবাগুলি রিডিম করতে ব্যবহৃত হয়। বর্তমানে এর জন্য উপলব্ধ:';

  @override
  String get profileN42BeanFeature1 => 'একচেটিয়া সদস্য স্টিকার এবং থিম';

  @override
  String get profileN42BeanFeature2 => 'চ্যাট বুদ্বুদ কাস্টমাইজেশন';

  @override
  String get profileN42BeanFeature3 => 'লাল প্যাকেট কভার কাস্টমাইজেশন';

  @override
  String get profileN42BeanFeature4 => 'এক্সক্লুসিভ ডাকনাম ব্যাজ';

  @override
  String get profileN42BeanFeature5 => 'গ্রুপ চ্যাট বিশেষাধিকার';

  @override
  String get profileN42BeanFeature6 => 'ক্লাউড স্টোরেজ সম্প্রসারণ';

  @override
  String get profileN42BeanFeature7 => 'ভিডিও কল বিউটি ফিল্টার';

  @override
  String get profileN42BeanFeature8 => 'মুহূর্তের পটভূমি কাস্টমাইজেশন';

  @override
  String get profileN42BeanFeature9 => 'ভিআইপি গ্রাহক সেবা অগ্রাধিকার';

  @override
  String get profileGotIt => 'বুঝেছি';

  @override
  String get profileNoN42BeanRecords => 'N42 বিন রেকর্ড নেই';

  @override
  String get profileMoodAndThoughts => 'মেজাজ এবং চিন্তা';

  @override
  String get profileStatusHappy => 'খুশি';

  @override
  String get profileStatusCracked => 'ছিন্নভিন্ন';

  @override
  String get profileStatusLucky => 'ভাগ্যবান';

  @override
  String get profileStatusSunny => 'সানি';

  @override
  String get profileStatusTired => 'ক্লান্ত';

  @override
  String get profileStatusDaydream => 'দিবাস্বপ্ন';

  @override
  String get profileStatusRushing => 'রাশিং';

  @override
  String get profileStatusOverthinking => 'অতিরিক্ত চিন্তা';

  @override
  String get profileStatusEnergized => 'উজ্জীবিত';

  @override
  String get profileWorkAndStudy => 'কাজ এবং অধ্যয়ন';

  @override
  String get profileStatusWorking => 'কাজ করছে';

  @override
  String get profileStatusStudying => 'অধ্যয়নরত';

  @override
  String get profileStatusBusy => 'ব্যস্ত';

  @override
  String get profileStatusSlacking => 'স্ল্যাকিং';

  @override
  String get profileStatusTraveling => 'ভ্রমণ';

  @override
  String get profileStatusGoingHome => 'বাড়ি যাচ্ছি';

  @override
  String get profileStatusDnd => 'বিরক্ত করবেন না';

  @override
  String get profileActivities => 'কার্যক্রম';

  @override
  String get profileStatusHanging => 'হ্যাঙ্গিং আউট';

  @override
  String get profileStatusCheckIn => 'চেক ইন';

  @override
  String get profileStatusExercising => 'ব্যায়াম';

  @override
  String get profileStatusCoffee => 'কফি';

  @override
  String get profileStatusBubbleTea => 'বাবল চা';

  @override
  String get profileStatusEating => 'খাওয়া';

  @override
  String get profileStatusParenting => 'প্যারেন্টিং';

  @override
  String get profileStatusSavingWorld => 'সেভিং ওয়ার্ল্ড';

  @override
  String get profileStatusSelfie => 'সেলফি';

  @override
  String get profileRest => 'বিশ্রাম';

  @override
  String get profileStatusRetreat => 'পশ্চাদপসরণ';

  @override
  String get profileStatusHome => 'বাড়ি';

  @override
  String get profileStatusSleeping => 'ঘুমন্ত';

  @override
  String get profileStatusCatLover => 'বিড়াল প্রেমিক';

  @override
  String get profileStatusDogWalking => 'হাঁটা কুকুর';

  @override
  String get profileStatusGaming => 'গেমিং';

  @override
  String get profileStatusListening => 'শুনছেন';

  @override
  String get profileEditAddress => 'ঠিকানা সম্পাদনা করুন';

  @override
  String get profileRecipient => 'প্রাপক';

  @override
  String get profileEnterRecipientName => 'প্রাপকের নাম লিখুন';

  @override
  String get profilePhoneNumber => 'ফোন নম্বর';

  @override
  String get profileEnterPhoneNumber => 'ফোন নম্বর লিখুন';

  @override
  String get profileRegionHint => 'প্রদেশ/শহর/জেলা';

  @override
  String get profileDetailedAddress => 'বিস্তারিত ঠিকানা';

  @override
  String get profileDetailedAddressHint => 'রাস্তা, বিল্ডিং নম্বর, ইত্যাদি';

  @override
  String get profileSetAsDefaultAddress => 'ডিফল্ট ঠিকানা হিসেবে সেট করুন';

  @override
  String get profilePleaseCompleteInfo => 'সব ক্ষেত্র সম্পূর্ণ করুন';

  @override
  String get profileEditInvoice => 'চালান সম্পাদনা করুন';

  @override
  String get profileInvoiceType => 'চালানের ধরন';

  @override
  String get profileCompanyName => 'কোম্পানির নাম';

  @override
  String get profilePersonalName => 'ব্যক্তিগত নাম';

  @override
  String get profileEnterCompanyName => 'কোম্পানির নাম লিখুন';

  @override
  String get profileEnterName => 'নাম লিখুন';

  @override
  String get profileTaxIdNumber => 'ট্যাক্স আইডি নম্বর';

  @override
  String get profileEnterTaxIdNumber => 'ট্যাক্স আইডি নম্বর লিখুন';

  @override
  String get profileBankNameOptional => 'ব্যাঙ্কের নাম (ঐচ্ছিক)';

  @override
  String get profileEnterBankName => 'ব্যাঙ্কের নাম লিখুন';

  @override
  String get profileBankAccountOptional => 'ব্যাঙ্ক অ্যাকাউন্ট (ঐচ্ছিক)';

  @override
  String get profileEnterBankAccount => 'ব্যাঙ্ক অ্যাকাউন্ট লিখুন';

  @override
  String get profileCompanyAddressOptional => 'কোম্পানির ঠিকানা (ঐচ্ছিক)';

  @override
  String get profileEnterCompanyAddress => 'কোম্পানির ঠিকানা লিখুন';

  @override
  String get profileCompanyPhoneOptional => 'কোম্পানির ফোন (ঐচ্ছিক)';

  @override
  String get profileEnterCompanyPhone => 'কোম্পানির ফোন লিখুন';

  @override
  String get profileSetAsDefaultInvoice => 'ডিফল্ট চালান হিসাবে সেট করুন';

  @override
  String get profileRingtoneVibrate => 'কম্পন';

  @override
  String get profileRingtoneSilent => 'নীরব';

  @override
  String get profileVibrateMode => 'ভাইব্রেট মোড';

  @override
  String get profileSilentMode => 'নীরব মোড';

  @override
  String profilePlayFailed(String ringtoneName) {
    return 'খেলতে ব্যর্থ হয়েছে: $ringtoneName';
  }

  @override
  String profilePlaying(String ringtoneName) {
    return 'বাজানো: $ringtoneName';
  }

  @override
  String get profileStop => 'থামো';

  @override
  String get profileSelectRingtone => 'রিংটোন নির্বাচন করুন';

  @override
  String get profileLoadingRingtones => 'রিংটোন লোড হচ্ছে...';

  @override
  String get profileNoRingtonesFound => 'কোন রিংটোন পাওয়া যায়নি';

  @override
  String mainMessagesWithCount(int count) {
    return 'বার্তা($count)';
  }

  @override
  String get storyViewers => 'দর্শক';

  @override
  String get storyNoViewers => 'এখনো কোনো দর্শক নেই';

  @override
  String get storyReplyToStory => 'গল্পের উত্তর দিন...';

  @override
  String get commonCopiedToClipboard => 'ক্লিপবোর্ডে কপি করা হয়েছে';

  @override
  String get commonMore => 'আরও';

  @override
  String get commonTranslating => 'অনুবাদ করা হচ্ছে...';

  @override
  String commonTranslatedFrom(String language) {
    return '$language থেকে অনুবাদ করা হয়েছে';
  }

  @override
  String get commonTranslation => 'অনুবাদ';

  @override
  String get commonTranslationFailed => 'অনুবাদ ব্যর্থ হয়েছে';

  @override
  String get commonAllRead => 'সবাই পড়ে';

  @override
  String commonReadCount(int count) {
    return '$count পড়া';
  }

  @override
  String get commonYouRecalledMessage => 'আপনি একটি বার্তা স্মরণ';

  @override
  String get commonMessageRecalled => 'বার্তা প্রত্যাহার';

  @override
  String get commonReEdit => 'পুনরায় সম্পাদনা করুন';

  @override
  String get commonWalletArea => 'ওয়ালেট এলাকা';

  @override
  String get callIncomingCall => 'ইনকামিং কল';

  @override
  String get callMissedCall => 'মিসড কল';

  @override
  String get groupRemoveAdmin => 'অ্যাডমিন সরান';

  @override
  String get chatSelectCurrency => 'মুদ্রা নির্বাচন করুন';

  @override
  String get chatSelectEmoji => 'ইমোজি নির্বাচন করুন';

  @override
  String get chatSelectRedPacketCover => 'কভার নির্বাচন করুন';

  @override
  String get groupSetAsAdmin => 'অ্যাডমিন হিসেবে সেট করুন';

  @override
  String get chatVideoPlaybackFailed => 'ভিডিও প্লেব্যাক ব্যর্থ হয়েছে';

  @override
  String get groupViewProfile => 'প্রোফাইল দেখুন';

  @override
  String get favoriteAddLinkComingSoon =>
      'শীঘ্রই আসছে লিঙ্ক বৈশিষ্ট্য যোগ করুন';

  @override
  String get favoriteNewNoteComingSoon => 'নতুন নোট বৈশিষ্ট্য শীঘ্রই আসছে';

  @override
  String get qrcodeSaveFeatureComingSoon =>
      'শীঘ্রই আসছে বৈশিষ্ট্য সংরক্ষণ করুন';

  @override
  String get qrcodeShareFeatureComingSoon => 'শেয়ার বৈশিষ্ট্য শীঘ্রই আসছে';

  @override
  String qrcodeProcessFailed(String error) {
    return 'QR কোড প্রক্রিয়া করতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String get securityDeviceIdRequired => 'ডিভাইস আইডি প্রয়োজন';

  @override
  String securityVerificationStartFailed(String error) {
    return 'যাচাইকরণ শুরু করতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String get securityVerificationFailed => 'যাচাইকরণ ব্যর্থ হয়েছে৷';

  @override
  String securityVerificationFailedWithReason(String reason) {
    return 'যাচাইকরণ ব্যর্থ হয়েছে: $reason';
  }

  @override
  String get securityEmojiMismatchRejected =>
      'যাচাইকরণ বাতিল হয়েছে - ইমোজি মেলেনি';

  @override
  String get securityWaitingForDeviceAccept =>
      'অন্য ডিভাইসটি গ্রহণ করার জন্য অপেক্ষা করা হচ্ছে...';

  @override
  String get securityVerifyDevice => 'এই ডিভাইসটি যাচাই করুন';

  @override
  String get securityConfirmEmojiMatch =>
      'নিশ্চিত করুন যে নীচের ইমোজি একই ক্রমে উভয় ডিভাইসে প্রদর্শিত হয়েছে';

  @override
  String get securityEmojiDontMatch => 'তারা মেলে না';

  @override
  String get securityEmojiMatch => 'তারা মেলে';

  @override
  String get securityWaitingForDeviceConfirm =>
      'অন্য ডিভাইস নিশ্চিত করার জন্য অপেক্ষা করা হচ্ছে...';

  @override
  String get securityVerificationSuccess => 'যাচাইকরণ সফল!';

  @override
  String get securityDeviceVerifiedTrusted =>
      'এই ডিভাইসটি এখন যাচাই করা হয়েছে এবং বিশ্বস্ত।';

  @override
  String get securityCompareEmoji => 'উভয় ডিভাইসের ইমোজি তুলনা করুন';

  @override
  String get securityCompareNumbers => 'উভয় ডিভাইসের সংখ্যা তুলনা করুন';

  @override
  String get commonTryAgain => 'আবার চেষ্টা করুন';

  @override
  String get commonDone => 'সম্পন্ন';

  @override
  String get chatExportTitle => 'রপ্তানি চ্যাট';

  @override
  String get chatExportSuccess => 'রপ্তানি সফল';

  @override
  String chatExportFailed(String error) {
    return 'রপ্তানি ব্যর্থ হয়েছে: $error৷';
  }

  @override
  String get chatExportFormat => 'রপ্তানি বিন্যাস';

  @override
  String get chatExportHtmlDesc =>
      'শৈলীযুক্ত বিন্যাস সহ যেকোনো ব্রাউজারে পঠনযোগ্য';

  @override
  String get chatExportJsonDesc => 'মেশিন রিডেবল স্ট্রাকচার্ড ডেটা ফরম্যাট';

  @override
  String get chatExportDateRange => 'তারিখ পরিসীমা';

  @override
  String get chatExportAll => 'সমস্ত বার্তা';

  @override
  String get chatExportLastWeek => 'গত ৭ দিন';

  @override
  String get chatExportLastMonth => 'গত মাসে';

  @override
  String get chatExportLast3Months => 'গত ৩ মাস';

  @override
  String get chatExportMessageCount => 'রপ্তানি করার জন্য বার্তা';

  @override
  String get chatExportButton => 'রপ্তানি এবং ভাগ করুন';

  @override
  String get chatMediaGallery => 'মিডিয়া গ্যালারি';

  @override
  String get chatExportHistory => 'চ্যাটের ইতিহাস রপ্তানি করুন';

  @override
  String get pdfLoadFailed => 'PDF লোড করতে ব্যর্থ হয়েছে৷';

  @override
  String pdfPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get mediaAll => 'সব';

  @override
  String get mediaImages => 'ছবি';

  @override
  String get mediaVideos => 'ভিডিও';

  @override
  String get mediaFiles => 'ফাইল';

  @override
  String get mediaAudio => 'অডিও';

  @override
  String mediaItemsCount(int count) {
    return '$count আইটেম';
  }

  @override
  String get mediaNoMediaFound => 'কোনো মিডিয়া পাওয়া যায়নি';

  @override
  String get spacesTitle => 'সম্প্রদায়গুলি';

  @override
  String get spacesCreate => 'সম্প্রদায় তৈরি করুন';

  @override
  String get spacesJoined => 'যোগদান করেছেন';

  @override
  String get spacesDiscover => 'আবিষ্কার করুন';

  @override
  String get spacesNoJoined => 'কোন সম্প্রদায় এখনও যোগদান';

  @override
  String get spacesExplore => 'সম্প্রদায়গুলি অন্বেষণ করুন৷';

  @override
  String get spacesNoPublic => 'কোনো পাবলিক সম্প্রদায় খুঁজে পাওয়া যায়নি';

  @override
  String get spacesJoin => 'যোগদান করুন';

  @override
  String get spacesSubSpaces => 'উপ-সম্প্রদায়';

  @override
  String get spacesChannels => 'চ্যানেল';

  @override
  String spacesMembersCount(int count) {
    return '$count সদস্য';
  }

  @override
  String get spacesPublic => 'পাবলিক';

  @override
  String get spacesPrivate => 'ব্যক্তিগত';

  @override
  String get spacesSuggested => 'প্রস্তাবিত';

  @override
  String spacesChannelsCount(int count) {
    return '$count চ্যানেল';
  }

  @override
  String get callInCallChat => 'ইন-কল চ্যাট';

  @override
  String callMessagesCount(int count) {
    return '$count বার্তা';
  }

  @override
  String get callNoMessagesYet =>
      'এখনও কোন বার্তা নেই.\nশুরু করতে একটি বার্তা পাঠান.';

  @override
  String get callTypeMessage => 'একটি বার্তা টাইপ করুন...';

  @override
  String get callYouSender => 'আপনি';

  @override
  String get callChatLabel => 'চ্যাট';

  @override
  String get chatEdited => 'সম্পাদিত';

  @override
  String get chatEditHistory => 'ইতিহাস সম্পাদনা করুন';

  @override
  String get chatOriginalMessage => 'আসল';

  @override
  String chatEditedAt(String time) {
    return '$time এ সম্পাদিত';
  }

  @override
  String get chatViewOnce => 'একবার দেখুন';

  @override
  String get chatViewOncePhoto => 'একবার ছবি দেখুন';

  @override
  String get chatViewOnceVideo => 'ভিডিওটি একবার দেখুন';

  @override
  String get chatViewOnceViewed => 'দেখা হয়েছে';

  @override
  String get chatViewOnceExpired => 'মেয়াদ শেষ';

  @override
  String get chatViewOnceTap => 'দেখতে ট্যাপ করুন';

  @override
  String get chatAutoFaceBlur => 'অটো ফেস ব্লার';

  @override
  String get chatAutoFaceBlurDesc =>
      'ফটো পাঠানোর সময় স্বয়ংক্রিয়ভাবে মুখ ঝাপসা করে';

  @override
  String get threadReplyInThread => 'থ্রেডে উত্তর দিন';

  @override
  String threadReplies(int count) {
    return '$count উত্তর';
  }

  @override
  String get threadReply => '1টি উত্তর';

  @override
  String threadLatestReply(String preview) {
    return 'সর্বশেষ: $preview';
  }

  @override
  String get threadTitle => 'থ্রেড';

  @override
  String get threadReplyPlaceholder => 'থ্রেডে উত্তর দিন...';

  @override
  String threadParticipants(int count) {
    return '$count অংশগ্রহণকারীরা';
  }

  @override
  String get voiceRoomTitle => 'ভয়েস রুম';

  @override
  String get voiceRoomCreate => 'ভয়েস রুম তৈরি করুন';

  @override
  String get voiceRoomJoin => 'যোগদান করুন';

  @override
  String get voiceRoomLeave => 'ছেড়ে দিন';

  @override
  String get voiceRoomEnd => 'শেষ কক্ষ';

  @override
  String get voiceRoomRaiseHand => 'হাত বাড়ান';

  @override
  String get voiceRoomLowerHand => 'নিচের হাত';

  @override
  String get voiceRoomMute => 'নিঃশব্দ';

  @override
  String get voiceRoomUnmute => 'আনমিউট করুন';

  @override
  String get voiceRoomHost => 'হোস্ট';

  @override
  String get voiceRoomSpeakers => 'বক্তারা';

  @override
  String get voiceRoomListeners => 'শ্রোতারা';

  @override
  String get voiceRoomLive => 'লাইভ';

  @override
  String get voiceRoomEnded => 'শেষ হয়েছে';

  @override
  String get voiceRoomScheduled => 'নির্ধারিত';

  @override
  String get voiceRoomApprove => 'অনুমোদন করুন';

  @override
  String get voiceRoomDemote => 'লিসেনারে সরান';

  @override
  String voiceRoomHandRaised(String name) {
    return '$name তাদের হাত তুলেছে';
  }

  @override
  String get voiceRoomName => 'রুমের নাম';

  @override
  String get voiceRoomTopic => 'বিষয় (ঐচ্ছিক)';

  @override
  String get voiceRoomNoActive => 'কোনো সক্রিয় ভয়েস রুম নেই';

  @override
  String get voiceRoomConnecting => 'সংযোগ করা হচ্ছে...';

  @override
  String get usernameTitle => 'ব্যবহারকারীর নাম';

  @override
  String get usernameSet => 'ব্যবহারকারীর নাম সেট করুন';

  @override
  String get usernameChange => 'ব্যবহারকারীর নাম পরিবর্তন করুন';

  @override
  String get usernamePlaceholder => 'ব্যবহারকারীর নাম লিখুন';

  @override
  String get usernameAvailable => 'ব্যবহারকারীর নাম উপলব্ধ';

  @override
  String get usernameUnavailable => 'ব্যবহারকারীর নাম ইতিমধ্যে নেওয়া হয়েছে';

  @override
  String get usernameInvalid =>
      '3-30 অক্ষর, ছোট হাতের অক্ষর, সংখ্যা, আন্ডারস্কোর। একটি চিঠি দিয়ে শুরু করতে হবে।';

  @override
  String get usernameReserved => 'এই ব্যবহারকারীর নাম সংরক্ষিত';

  @override
  String get usernameSaved => 'ব্যবহারকারীর নাম সংরক্ষিত';

  @override
  String get usernameSearchHint => '@username দ্বারা অনুসন্ধান করুন';

  @override
  String get ensName => 'ENS নাম';

  @override
  String get ensLinked => 'ENS এর সাথে সংযুক্ত';

  @override
  String get ensResolving => 'ENS সমাধান করা হচ্ছে...';

  @override
  String get ensNotFound => 'ENS নাম পাওয়া যায়নি';

  @override
  String get tokenGateTitle => 'টোকেন গেট';

  @override
  String get tokenGateEnable => 'টোকেন গেট সক্ষম করুন';

  @override
  String get tokenGateDisable => 'টোকেন গেট নিষ্ক্রিয় করুন';

  @override
  String get tokenGateAddRule => 'নিয়ম যোগ করুন';

  @override
  String get tokenGateRemoveRule => 'নিয়ম সরান';

  @override
  String get tokenGateContractAddress => 'চুক্তির ঠিকানা';

  @override
  String get tokenGateMinBalance => 'ন্যূনতম ব্যালেন্স';

  @override
  String get tokenGateTokenId => 'টোকেন আইডি (ERC-1155)';

  @override
  String get tokenGateChainId => 'চেইন আইডি';

  @override
  String get tokenGateVerifying => 'টোকেন হোল্ডিং যাচাই করা হচ্ছে...';

  @override
  String get tokenGateVerified => 'যাচাইকরণ পাস';

  @override
  String get tokenGateDenied => 'আপনি টোকেন প্রয়োজনীয়তা পূরণ করেন না';

  @override
  String get tokenGateOperatorAnd => 'সব নিয়ম মেনে চলতে হবে';

  @override
  String get tokenGateOperatorOr => 'যেকোনো নিয়ম মেনে চলতে হবে';

  @override
  String get tokenGateRuleErc20 => 'ERC-20 টোকেন';

  @override
  String get tokenGateRuleErc721 => 'NFT (ERC-721)';

  @override
  String get tokenGateRuleErc1155 => 'মাল্টি-টোকেন (ERC-1155)';

  @override
  String get tokenGateRuleNative => 'নেটিভ টোকেন';

  @override
  String get tokenGateSaved => 'টোকেন গেট সংরক্ষিত';

  @override
  String get tokenGateEnableDescription =>
      'সদস্যদের যোগদানের জন্য টোকেন ধরে রাখতে হবে';

  @override
  String get tokenGateOperator => 'নিয়ম লজিক';

  @override
  String get tokenGateRules => 'নিয়ম';

  @override
  String get tokenGateSymbol => 'প্রতীক (ঐচ্ছিক)';

  @override
  String get tokenGateChain => 'চেইন';

  @override
  String get tokenGateTokenStandard => 'টোকেন স্ট্যান্ডার্ড';

  @override
  String get tokenGateDenialMessage => 'অস্বীকার বার্তা';

  @override
  String get tokenGateDenialMessageHint =>
      'যাচাইকরণ ব্যর্থ হলে বার্তা দেখানো হয়';

  @override
  String get tokenGateVerifyTitle => 'টোকেন যাচাইকরণ';

  @override
  String get tokenGateVerifyPassed => 'যাচাইকরণ পাস';

  @override
  String get tokenGateVerifyFailed => 'যাচাইকরণ ব্যর্থ হয়েছে৷';

  @override
  String get tokenGateRetryVerify => 'আবার চেষ্টা করুন';

  @override
  String get tokenGateRequired => 'প্রয়োজন';

  @override
  String get tokenGateYourBalance => 'আপনার ব্যালেন্স';

  @override
  String get tokenGateRulesActive => 'নিয়ম সক্রিয়';

  @override
  String get tokenGateDisabled => 'অক্ষম';

  @override
  String get ensNotBound => 'আবদ্ধ নয়';

  @override
  String get liveLocation => 'লাইভ অবস্থান';

  @override
  String get stopLiveLocation => 'শেয়ার করা বন্ধ করুন';

  @override
  String get startLiveLocation => 'শেয়ার করা শুরু করুন';

  @override
  String get selectDuration => 'সময়কাল নির্বাচন করুন';

  @override
  String get groupChatFiles => 'চ্যাট ফাইল';

  @override
  String get groupLinks => 'লিঙ্ক';

  @override
  String get groupNoLinks => 'এখনও কোন লিঙ্ক';

  @override
  String get chatBackground => 'চ্যাট পটভূমি';

  @override
  String get solidColors => 'কঠিন রং';

  @override
  String get gradients => 'গ্রেডিয়েন্ট';

  @override
  String get defaultBackground => 'ডিফল্ট';

  @override
  String get settingsFontSizeSlider => 'ফন্ট সাইজ';

  @override
  String get autoDownload => 'অটো-ডাউনলোড';

  @override
  String get images => 'ছবি';

  @override
  String get voice => 'ভয়েস';

  @override
  String get video => 'ভিডিও';

  @override
  String get files => 'ফাইল';

  @override
  String get mobileData => 'মোবাইল ডেটা';

  @override
  String get roaming => 'রোমিং';

  @override
  String get storageManagement => 'স্টোরেজ';

  @override
  String get totalUsage => 'মোট ব্যবহার';

  @override
  String get cache => 'ক্যাশে';

  @override
  String get other => 'অন্যান্য';

  @override
  String get clearCache => 'ক্যাশে সাফ করুন';

  @override
  String get cacheCleared => 'ক্যাশে সাফ করা হয়েছে';

  @override
  String get clearCacheFailed => 'ক্যাশে সাফ করতে ব্যর্থ হয়েছে৷';

  @override
  String get confirmClearCache => 'সমস্ত ক্যাশে ডেটা সাফ করবেন?';

  @override
  String get mapView => 'ম্যাপ ভিউ';

  @override
  String liveLocationSharingCount(int count) {
    return '$count লোকেরা অবস্থান ভাগ করছে৷';
  }

  @override
  String get minutes15 => '15 মিনিট';

  @override
  String get minutes30 => '30 মিনিট';

  @override
  String get hour1 => '1 ঘন্টা';

  @override
  String get hours8 => '8 ঘন্টা';

  @override
  String get personalCard => 'ব্যক্তিগত কার্ড';

  @override
  String get downloadFailed => 'ডাউনলোড ব্যর্থ হয়েছে৷';

  @override
  String get locationExpired => 'মেয়াদ শেষ';

  @override
  String secondsRemaining(int count) {
    return '$count সেকেন্ড';
  }

  @override
  String minutesRemaining(int count) {
    return '$count মিনিট';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '$hours ঘন্টা $minutes মিনিট';
  }

  @override
  String get favoriteMessages => 'প্রিয়';

  @override
  String get linksCopied => 'লিঙ্ক কপি করা হয়েছে';

  @override
  String get noLinksFound => 'কোন লিঙ্ক পাওয়া যায়নি';

  @override
  String get roomStorageRanking => 'রুম স্টোরেজ র‌্যাঙ্কিং';

  @override
  String get downloadComplete => 'ডাউনলোড সম্পূর্ণ';

  @override
  String get downloading => 'ডাউনলোড হচ্ছে...';

  @override
  String get draftSaved => 'খসড়া সংরক্ষিত';

  @override
  String get voiceRecording => 'ভয়েস রেকর্ডিং';

  @override
  String get searchLocation => 'অবস্থান অনুসন্ধান করুন';

  @override
  String get tapToSearch => 'অনুসন্ধান করতে আলতো চাপুন';

  @override
  String get settingsThisDevice => 'এই ডিভাইস';

  @override
  String get settingsJustNow => 'এইমাত্র';

  @override
  String get settingsDeviceId => 'ডিভাইস আইডি';

  @override
  String get settingsStatus => 'স্ট্যাটাস';

  @override
  String get settingsLastActive => 'সর্বশেষ সক্রিয়';

  @override
  String get settingsIpAddress => 'আইপি ঠিকানা';

  @override
  String get settingsRenameDevice => 'ডিভাইসের নাম পরিবর্তন করুন';

  @override
  String get settingsDeviceNameHint => 'ডিভাইসের নাম লিখুন';

  @override
  String get settingsDeviceRenamed => 'ডিভাইসের নাম পরিবর্তন করা হয়েছে';

  @override
  String get settingsRenameFailed => 'পুনঃনামকরণ ব্যর্থ হয়েছে৷';

  @override
  String get settingsRemoteLogout => 'দূরবর্তী লগআউট';

  @override
  String settingsRemoteLogoutConfirm(String deviceName) {
    return 'আপনি কি \"$deviceName\" লগ আউট করার বিষয়ে নিশ্চিত? এই ক্রিয়াটি পূর্বাবস্থায় ফেরানো যাবে না৷';
  }

  @override
  String get settingsDeviceLoggedOut => 'ডিভাইস লগ আউট হয়েছে';

  @override
  String get settingsLogoutFailed => 'লগআউট ব্যর্থ হয়েছে৷';

  @override
  String get settingsLogout => 'লগআউট';

  @override
  String get settingsVerifyIdentity => 'পরিচয় যাচাই করুন';

  @override
  String get settingsEnterPasswordToConfirm =>
      'এই কর্ম নিশ্চিত করতে আপনার পাসওয়ার্ড লিখুন.';

  @override
  String get scheduledSendTitle => 'সময়সূচী বার্তা';

  @override
  String get scheduledSendInOneHour => '১ ঘণ্টার মধ্যে';

  @override
  String get scheduledSendTonight => 'আজ রাত (8:00 PM)';

  @override
  String get scheduledSendTomorrowMorning => 'আগামীকাল সকাল (9:00 AM)';

  @override
  String get scheduledSendCustom => 'একটি তারিখ এবং সময় চয়ন করুন';

  @override
  String get scheduledMessageLabel => 'নির্ধারিত';

  @override
  String get scheduledMessageCancel => 'নির্ধারিত বার্তা বাতিল করুন';

  @override
  String get chatLockTitle => 'চ্যাট লক';

  @override
  String get chatLockEnable => 'এই চ্যাট লক';

  @override
  String get chatLockDisable => 'এই চ্যাট আনলক করুন';

  @override
  String get chatLockDescription =>
      'লক করা চ্যাট খোলার জন্য বায়োমেট্রিক বা পিন যাচাইকরণ প্রয়োজন';

  @override
  String get chatLockVerifyTitle => 'চ্যাট লক করা হয়েছে';

  @override
  String get chatLockVerifySubtitle => 'এই চ্যাট অ্যাক্সেস করতে যাচাই করুন';

  @override
  String get chatLockVerifyFailed => 'যাচাইকরণ ব্যর্থ হয়েছে৷';

  @override
  String get chatLockEnabled => 'চ্যাট লক করা হয়েছে';

  @override
  String get chatLockDisabled => 'চ্যাট আনলক করা হয়েছে';

  @override
  String get chatLockPinTitle => 'পিন লিখুন';

  @override
  String get chatLockPinSetTitle => 'পিন সেট করুন';

  @override
  String get chatLockPinConfirmTitle => 'পিন নিশ্চিত করুন';

  @override
  String get chatLockPinMismatch => 'পিন মেলে না';

  @override
  String get chatLockUseBiometric => 'বায়োমেট্রিক ব্যবহার করুন';

  @override
  String get chatLockUsePin => 'পিন ব্যবহার করুন';

  @override
  String get mediaEditorUndo => 'পূর্বাবস্থায় ফেরান';

  @override
  String get mediaEditorRedo => 'আবার করুন';

  @override
  String get mediaEditorCrop => 'ফসল';

  @override
  String get mediaEditorFilter => 'ফিল্টার';

  @override
  String get mediaEditorDraw => 'আঁকা';

  @override
  String get mediaEditorText => 'পাঠ্য';

  @override
  String get aiAssistant => 'এআই সহকারী';

  @override
  String get aiAssistantWelcome =>
      'নমস্কার! আমি N42 AI সহকারী। আমি কিভাবে আপনাকে সাহায্য করতে পারি?';

  @override
  String get aiAssistantNotConfigured => 'AI পরিষেবা কনফিগার করা হয়নি';

  @override
  String get aiAssistantSettings => 'এআই সেটিংস';

  @override
  String get aiAssistantClearHistory => 'চ্যাটের ইতিহাস সাফ করুন';

  @override
  String get aiAssistantClearHistoryConfirm =>
      'আপনি কি নিশ্চিত যে আপনি সমস্ত AI চ্যাট ইতিহাস সাফ করতে চান?';

  @override
  String get aiAssistantStopGenerating => 'জেনারেট করা বন্ধ করুন';

  @override
  String get aiAssistantModel => 'মডেল';

  @override
  String get aiAssistantTemperature => 'তাপমাত্রা';

  @override
  String get aiAssistantMaxTokens => 'সর্বোচ্চ টোকেন';

  @override
  String get aiAssistantContextWindow => 'প্রসঙ্গ উইন্ডো';

  @override
  String get aiAssistantServiceStatus => 'পরিষেবার অবস্থা';

  @override
  String get aiAssistantAvailable => 'পাওয়া যায়';

  @override
  String get aiAssistantUnavailable => 'অনুপলব্ধ';

  @override
  String get aiSummarize => 'এআই সারাংশ';

  @override
  String aiSummarizeUnread(int count) {
    return '$count অপঠিত বার্তাগুলিকে সংক্ষিপ্ত করুন৷';
  }

  @override
  String get aiSummarizeLoading => 'সারসংক্ষেপ...';

  @override
  String get aiSummarizeError => 'সারসংক্ষেপ করতে ব্যর্থ হয়েছে';

  @override
  String get aiRewrite => 'এআই পুনর্লিখন';

  @override
  String get aiRewriteFormal => 'আনুষ্ঠানিক';

  @override
  String get aiRewriteCasual => 'নৈমিত্তিক';

  @override
  String get aiRewritePlayful => 'কৌতুকপূর্ণ';

  @override
  String get aiRewriteProfessional => 'প্রফেশনাল';

  @override
  String get aiRewriteAccept => 'ব্যবহার করুন';

  @override
  String get aiRewriteCancel => 'বাতিল করুন';

  @override
  String get aiRewriteLoading => 'পুনরায় লেখা হচ্ছে...';

  @override
  String get aiLinkSummary => 'এআই সারাংশ';

  @override
  String get aiLinkSummaryAnalyzing => 'বিশ্লেষণ করা হচ্ছে...';

  @override
  String get chatFolderManagement => 'ফোল্ডার পরিচালনা করুন';

  @override
  String get chatFolderSystem => 'সিস্টেম ফোল্ডার';

  @override
  String get chatFolderCustom => 'কাস্টম ফোল্ডার';

  @override
  String get chatFolderEmpty => 'এখনও কোনো কাস্টম ফোল্ডার নেই৷';

  @override
  String get chatFolderCreate => 'ফোল্ডার তৈরি করুন';

  @override
  String get chatFolderEdit => 'ফোল্ডার সম্পাদনা করুন';

  @override
  String get chatFolderNameHint => 'ফোল্ডারের নাম';

  @override
  String get chatFolderAll => 'সব';

  @override
  String get chatFolderUnread => 'অপঠিত';

  @override
  String get chatFolderPersonal => 'ব্যক্তিগত';

  @override
  String get chatFolderGroups => 'গোষ্ঠী';

  @override
  String get chatFolderChannels => 'চ্যানেল';

  @override
  String get chatFolderMuted => 'নিঃশব্দ';

  @override
  String get storyAddMusic => 'সঙ্গীত যোগ করুন';

  @override
  String get storyChangeMusic => 'সঙ্গীত পরিবর্তন করুন';

  @override
  String get storyBackgroundMusic => 'ব্যাকগ্রাউন্ড মিউজিক';

  @override
  String get storyMusicPreview => 'পূর্বরূপ (সর্বোচ্চ 15 সেকেন্ড)';

  @override
  String get storyChooseFromDevice => 'ডিভাইস থেকে চয়ন করুন';

  @override
  String get storyUseThisMusic => 'এই সঙ্গীত ব্যবহার করুন';

  @override
  String get authPasskeyNotSupported => 'এই ডিভাইসে পাসকি সমর্থিত নয়';

  @override
  String get authPasskeyRegister => 'পাসকি নিবন্ধন করুন';

  @override
  String get authPasskeyNoRegistered => 'কোন পাসকি নিবন্ধিত';

  @override
  String get authPasskeyRegisterHint =>
      'এই অ্যাকাউন্টের জন্য একটি পাসকি নিবন্ধন করুন। স্বতন্ত্র পাসকি সাইন-ইন পরে সক্ষম করা হবে।';

  @override
  String get authPasskeyNameYours => 'আপনার পাসকির নাম দিন';

  @override
  String get authPasskeyRegistered => 'পাসকি এই অ্যাকাউন্টে সংরক্ষিত';

  @override
  String get authPasskeyDeleted => 'এই অ্যাকাউন্ট থেকে পাসকি সরানো হয়েছে';

  @override
  String authPasskeyDeleteConfirm(String name) {
    return '\"$name\" পাসকি মুছবেন? পাসকি সাইন-ইন পরে ব্যবহার করার আগে আপনাকে এটি আবার নিবন্ধন করতে হবে।';
  }

  @override
  String get momentVisibilityPublic => 'পাবলিক';

  @override
  String get momentVisibilityPrivate => 'ব্যক্তিগত';

  @override
  String get momentVisibilityPartial => 'নির্বাচিত বন্ধুরা';

  @override
  String get momentVisibilityExcluded => 'কিছু বন্ধু বাদ';

  @override
  String momentUserMoments(String userName) {
    return '$userName এর মুহূর্ত';
  }

  @override
  String get momentForwardTo => 'ফরোয়ার্ড করুন';

  @override
  String get momentForwardSuccess => 'সফলভাবে ফরোয়ার্ড করা হয়েছে';

  @override
  String get momentSelectFriends => 'বন্ধু নির্বাচন করুন';

  @override
  String get momentSelectTags => 'ট্যাগ দ্বারা নির্বাচন করুন';

  @override
  String momentSelectedCount(int count) {
    return 'নির্বাচিত ($count)';
  }

  @override
  String get momentNoMomentsYet => 'এখনও কোন মুহূর্ত';

  @override
  String get momentForwardMoment => 'ফরোয়ার্ড মোমেন্ট';

  @override
  String get momentAddComment => 'একটি মন্তব্য যোগ করুন...';

  @override
  String momentForwardContent(String content) {
    return '[মুহূর্ত] $content';
  }

  @override
  String get momentDeleteMoment => 'মুহূর্ত মুছুন';

  @override
  String get momentDeleteConfirm =>
      'আপনি কি নিশ্চিত আপনি এই মুহূর্ত মুছে ফেলতে চান?';

  @override
  String get momentComment => 'মন্তব্য করুন';

  @override
  String get momentWriteComment => 'একটি মন্তব্য লিখুন...';

  @override
  String get momentLike => 'লাইক';

  @override
  String get momentUnlike => 'অপছন্দ';

  @override
  String get momentForward => 'ফরোয়ার্ড';

  @override
  String get momentDelete => 'মুছুন';

  @override
  String get momentReply => 'উত্তর';

  @override
  String get momentMoment => 'মুহূর্ত';

  @override
  String momentLikesCount(int count) {
    return '$count পছন্দ করে';
  }

  @override
  String momentCommentsCount(int count) {
    return '$count মন্তব্য';
  }

  @override
  String get momentNoComments => 'এখনো কোন মন্তব্য নেই';

  @override
  String get momentFailedToLoad => 'ছবি লোড করতে ব্যর্থ হয়েছে৷';

  @override
  String momentReplyTo(String userName) {
    return '$userName এর উত্তর দিন...';
  }

  @override
  String get momentNoConversations => 'কোনো কথোপকথন নেই';

  @override
  String get momentJustNow => 'এইমাত্র';

  @override
  String momentMinutesAgo(int count) {
    return '${count}m আগে';
  }

  @override
  String momentHoursAgo(int count) {
    return '${count}h আগে';
  }

  @override
  String momentDaysAgo(int count) {
    return '${count}d আগে';
  }

  @override
  String get chatGroupAnnouncementHint => 'গ্রুপ ঘোষণা লিখুন';

  @override
  String get chatGroupAnnouncementEmpty => 'কোনো ঘোষণা নেই';

  @override
  String get chatEditNickname => 'ডাকনাম সম্পাদনা করুন';

  @override
  String get chatNicknameHint => 'এই গ্রুপে আপনার ডাকনাম লিখুন';

  @override
  String get contactAddPhoneHint => 'ফোন নম্বর লিখুন';

  @override
  String get contactNotesHint => 'এই পরিচিতি সম্পর্কে নোট যোগ করুন';

  @override
  String get reportTitle => 'রিপোর্ট';

  @override
  String get reportReasonSpam => 'স্প্যাম';

  @override
  String get reportReasonHarassment => 'হয়রানি';

  @override
  String get reportReasonFraud => 'প্রতারণা';

  @override
  String get reportReasonOther => 'অন্যান্য';

  @override
  String get reportSubmitted => 'প্রতিবেদন জমা দেওয়া হয়েছে';

  @override
  String get reportDescription => 'অতিরিক্ত বিবরণ (ঐচ্ছিক)';

  @override
  String get qrcodeSaved => 'QR কোড অ্যালবামে সংরক্ষিত';

  @override
  String get chatSendRedPacketInChat => 'অনুগ্রহ করে চ্যাটে লাল প্যাকেট পাঠান';

  @override
  String get commonSaveFailed => 'সংরক্ষণ ব্যর্থ হয়েছে';

  @override
  String get reportSelectReason => 'একটি কারণ নির্বাচন করুন';

  @override
  String get gameCenter => 'গেমস';

  @override
  String get gameHighScore => 'সেরা';

  @override
  String get gameScore => 'স্কোর';

  @override
  String get gameOver => 'খেলা শেষ';

  @override
  String get gamePlayAgain => 'আবার খেলুন';

  @override
  String get gameLeaderboard => 'লিডারবোর্ড';

  @override
  String get gamePause => 'বিরতি দেওয়া হয়েছে';

  @override
  String get gameResume => 'পুনরায় শুরু করতে আলতো চাপুন';

  @override
  String get gameConfirmExit => 'এই খেলা ছেড়ে দিন?';

  @override
  String get gameNoScores => 'এখনো কোনো স্কোর নেই';

  @override
  String get game2048 => '2048';

  @override
  String get game2048Desc => '2048 এ পৌঁছানোর জন্য টাইলস একত্রিত করুন';

  @override
  String get gameBlockDrop => 'ব্লক ড্রপ';

  @override
  String get gameBlockDropDesc => 'ড্রপ এবং পরিষ্কার লাইন';

  @override
  String get gameMinesweeper => 'মাইনসুইপার';

  @override
  String get gameMinesweeperDesc => 'সব নিরাপদ কোষ খুঁজুন';

  @override
  String get gameMatch3 => 'ম্যাচ 3';

  @override
  String get gameMatch3Desc => '3 বা তার বেশি রত্ন মেলে';

  @override
  String get gameMinesweeperEasy => 'সহজ';

  @override
  String get gameMinesweeperMedium => 'মাঝারি';

  @override
  String get gameMinesLeft => 'খনি বাম';

  @override
  String get gameTimeLeft => 'সময়';

  @override
  String get gameLevel => 'স্তর';

  @override
  String get gameNext => 'পরবর্তী';

  @override
  String get gameBestTime => 'সেরা সময়';

  @override
  String get gameNewRecord => 'নতুন রেকর্ড!';

  @override
  String get gameLines => 'লাইন';

  @override
  String get storyMyStory => 'আমার গল্প';

  @override
  String get storageSmartCleanup => 'স্মার্ট ক্লিনআপ';

  @override
  String get storageOldMediaFiles => 'পুরানো মিডিয়া ফাইল';

  @override
  String get storageLargeFiles => 'বড় ফাইল';

  @override
  String get storageAppCache => 'অ্যাপ ক্যাশে';

  @override
  String get storageSettings => 'স্টোরেজ সেটিংস';

  @override
  String get storageAutoCleanup => 'অটো ক্লিনআপ';

  @override
  String storageAutoCleanupDesc(int days) {
    return '$days দিনের চেয়ে পুরানো ফাইলগুলি স্বয়ংক্রিয়ভাবে পরিষ্কার করুন';
  }

  @override
  String get storageCleanupPeriod => 'পরিচ্ছন্নতার সময়কাল';

  @override
  String get storagePreserveThumbnails => 'থাম্বনেইল সংরক্ষণ করুন';

  @override
  String get storagePreserveThumbnailsDesc =>
      'পরিষ্কার করার সময় ছবির থাম্বনেল রাখুন';

  @override
  String get storageWarningHigh =>
      'স্টোরেজ ব্যবহার বেশি। পুরানো ফাইলগুলি পরিষ্কার করার কথা বিবেচনা করুন।';

  @override
  String get storageWarningCritical =>
      'সঞ্চয়স্থান সমালোচনামূলকভাবে কম। বিনামূল্যে স্থান পরিষ্কার করুন.';

  @override
  String storageFreed(String size, int count) {
    return 'ফ্রিড $size ($count ফাইল)';
  }

  @override
  String storageDays(int days) {
    return '$days দিন';
  }

  @override
  String storageViewAllRooms(int count) {
    return 'সমস্ত $count রুম দেখুন';
  }

  @override
  String get storageNoFiles => 'কোন ফাইল পাওয়া যায়নি';

  @override
  String get storageFilePinned => 'পিন করা হয়েছে';

  @override
  String storageDeleteSelected(int count) {
    return '$count নির্বাচিত ফাইলগুলি মুছবেন? এগুলি সার্ভার থেকে পুনরায় ডাউনলোড করা যেতে পারে।';
  }

  @override
  String get backupRestore => 'ব্যাকআপ এবং পুনরুদ্ধার করুন';

  @override
  String get backupCreate => 'ব্যাকআপ তৈরি করুন';

  @override
  String get backupCreateDesc =>
      'আপনার সেটিংস এবং এনক্রিপশন কী ব্যাকআপ করুন। পুনরায় লগইন করার পরে সার্ভার থেকে বার্তাগুলি পুনরুদ্ধার করা হবে।';

  @override
  String get backupIncludeKeys => 'এনক্রিপশন কী অন্তর্ভুক্ত করুন';

  @override
  String get backupIncludeKeysDesc =>
      'এনক্রিপ্ট করা বার্তা পড়ার জন্য প্রয়োজন';

  @override
  String get backupPasswordProtect => 'পাসওয়ার্ড রক্ষা করুন';

  @override
  String get backupEnterPassword => 'ব্যাকআপ পাসওয়ার্ড লিখুন';

  @override
  String get backupHistory => 'ব্যাকআপ ইতিহাস';

  @override
  String get backupNoBackups => 'এখনো কোনো ব্যাকআপ নেই';

  @override
  String get backupRestore2 => 'পুনরুদ্ধার করুন';

  @override
  String get backupDelete => 'মুছুন';

  @override
  String get backupDeleteConfirm =>
      'আপনি কি এই ব্যাকআপ মুছে ফেলার বিষয়ে নিশ্চিত? এটি পূর্বাবস্থায় ফেরানো যাবে না।';

  @override
  String get backupRestoreFromFile => 'ফাইল থেকে পুনরুদ্ধার করুন';

  @override
  String get backupRestoreFromFileDesc =>
      'অন্য ডিভাইস বা পূর্ববর্তী ব্যাকআপ থেকে একটি .n42 ব্যাকআপ ফাইল আমদানি করুন৷';

  @override
  String get backupChooseFile => 'ব্যাকআপ ফাইল নির্বাচন করুন';

  @override
  String get backupRestoring => 'পুনরুদ্ধার করা হচ্ছে...';

  @override
  String backupCreated(int rooms, int messages) {
    return 'ব্যাকআপ তৈরি করা হয়েছে: $rooms রুম, $messages বার্তা';
  }

  @override
  String backupRestored(int settings, int rooms) {
    return '$rooms রুম থেকে $settings সেটিংস পুনরুদ্ধার করা হয়েছে';
  }

  @override
  String backupFailed(String error) {
    return 'ব্যাকআপ ব্যর্থ হয়েছে: $error';
  }

  @override
  String get backupPasswordRequired => 'এই ব্যাকআপ পাসওয়ার্ড-সুরক্ষিত';

  @override
  String get blocGroupNotFound => 'গ্রুপ খুঁজে পাওয়া যায়নি';

  @override
  String blocGroupMembersInvited(int count) {
    return 'আমন্ত্রিত $count সদস্য(রা)';
  }

  @override
  String get blocGroupMemberRemoved => 'সদস্য সরানো হয়েছে';

  @override
  String get blocGroupAdminRemoved => 'প্রশাসক সরানো হয়েছে';

  @override
  String get blocGroupLeft => 'দল ছেড়েছে';

  @override
  String get blocGroupDisbanded => 'গ্রুপ ভেঙে দেওয়া হয়েছে';

  @override
  String get blocGroupJoined => 'দলে যোগ দিল';

  @override
  String get blocGroupInviteDeclined => 'আমন্ত্রণ প্রত্যাখ্যান করা হয়েছে৷';

  @override
  String get blocGroupTokenGateUpdated => 'টোকেন গেট আপডেট করা হয়েছে';

  @override
  String get blocTransferProcessing => 'স্থানান্তর প্রক্রিয়া করা হচ্ছে...';

  @override
  String get blocTransferCancelled => 'স্থানান্তর বাতিল করা হয়েছে৷';

  @override
  String get blocTransferFailed => 'স্থানান্তর ব্যর্থ হয়েছে৷';

  @override
  String get blocPaymentProcessing => 'পেমেন্ট প্রক্রিয়া করা হচ্ছে...';

  @override
  String get blocPaymentFailed => 'পেমেন্ট ব্যর্থ হয়েছে';

  @override
  String get groupMaxMembers => 'সদস্য সীমা';

  @override
  String get groupMaxMembersUnlimited => 'আনলিমিটেড';

  @override
  String get groupMaxMembersHint =>
      'সীমা লিখুন (সীমাহীনের জন্য খালি ছেড়ে দিন)';

  @override
  String get groupMaxMembersUpdated => 'সদস্য সীমা আপডেট করা হয়েছে';

  @override
  String get groupFull => 'গ্রুপ সক্ষমতা আছে';

  @override
  String get groupChannels => 'বিষয় চ্যানেল';

  @override
  String get groupChannelsEmpty => 'এখনো কোনো চ্যানেল নেই';

  @override
  String get groupChannelsCount => 'চ্যানেল';

  @override
  String get groupChannelCreate => 'নতুন চ্যানেল';

  @override
  String get groupChannelName => 'চ্যানেলের নাম';

  @override
  String get groupChannelTopic => 'চ্যানেলের বিষয় (ঐচ্ছিক)';

  @override
  String get groupChannelDelete => 'চ্যানেল মুছুন';

  @override
  String get groupChannelDeleteConfirm =>
      'এই চ্যানেলটি মুছবেন? সব বার্তা হারিয়ে যাবে.';

  @override
  String get groupBotSettings => 'বট সেটিংস';

  @override
  String get groupBotEnabled => 'বট সক্ষম করুন';

  @override
  String get groupBotWelcomeMessage => 'স্বাগতম বার্তা টেমপ্লেট';

  @override
  String get groupBotWelcomeHint =>
      'নতুন সদস্য নামের জন্য স্থানধারক হিসাবে \'নাম\' ব্যবহার করুন';

  @override
  String get groupBotConfigUpdated => 'বট সেটিংস আপডেট করা হয়েছে';

  @override
  String get groupContentFilter => 'বিষয়বস্তু ফিল্টার';

  @override
  String get groupContentFilterEnabled => 'কীওয়ার্ড ফিল্টার সক্ষম করুন';

  @override
  String get groupContentFilterReplace => '*** দিয়ে প্রতিস্থাপন করুন';

  @override
  String get groupContentFilterHide => 'বার্তা লুকান';

  @override
  String get groupContentFilterAddWord => 'কীওয়ার্ড যোগ করুন';

  @override
  String get groupContentFilterUpdated => 'কন্টেন্ট ফিল্টার আপডেট করা হয়েছে';

  @override
  String get chatSlashCommands => 'কমান্ড';

  @override
  String get chatCommandPoll => '/পোল - একটি পোল তৈরি করুন';

  @override
  String get chatCommandAnnounce => '/ ঘোষণা করুন - ঘোষণা পাঠান';

  @override
  String get chatCommandWelcome => '/welcome — স্বাগত বার্তা সেট করুন';

  @override
  String get chatReportMessage => 'রিপোর্ট';

  @override
  String get chatReportReason => 'রিপোর্ট কারণ';

  @override
  String get chatReportSpam => 'স্প্যাম';

  @override
  String get chatReportHarassment => 'হয়রানি';

  @override
  String get chatReportInappropriate => 'অনুপযুক্ত বিষয়বস্তু';

  @override
  String get chatReportOther => 'অন্যান্য';

  @override
  String get chatReportSuccess => 'প্রতিবেদন জমা দেওয়া হয়েছে';

  @override
  String get spacesName => 'সম্প্রদায়ের নাম';

  @override
  String get spacesNameHint => 'যেমন ক্রিপ্টো ট্রেডার্স';

  @override
  String get spacesNameRequired => 'নাম আবশ্যক';

  @override
  String get spacesDescription => 'বর্ণনা';

  @override
  String get spacesDescriptionHint => 'এই সম্প্রদায় সম্পর্কে কি?';

  @override
  String get spacesType => 'সম্প্রদায়ের ধরন';

  @override
  String get spacesPublicDesc => 'যে কেউ আবিষ্কার এবং যোগ দিতে পারেন';

  @override
  String get spacesPrivateDesc => 'শুধুমাত্র আমন্ত্রিত সদস্যরা যোগ দিতে পারবেন';

  @override
  String get spacesNotFound => 'সম্প্রদায় খুঁজে পাওয়া যায়নি';

  @override
  String get spacesSearch => 'সম্প্রদায়গুলি অনুসন্ধান করুন...';

  @override
  String get spacesMembers => 'সদস্যরা';

  @override
  String get spacesNoChannels => 'এখনো কোনো চ্যানেল নেই';

  @override
  String get spacesLeave => 'সম্প্রদায় ত্যাগ করুন';

  @override
  String spacesLeaveConfirm(String name) {
    return 'আপনি কি \"$name\" ছেড়ে যাওয়ার বিষয়ে নিশ্চিত?';
  }

  @override
  String get spacesDelete => 'সম্প্রদায় মুছুন';

  @override
  String spacesDeleteConfirm(String name) {
    return 'এটি স্থায়ীভাবে \"$name\" এবং এর সমস্ত চ্যানেল মুছে ফেলবে৷ এই ক্রিয়াটি পূর্বাবস্থায় ফেরানো যাবে না৷';
  }

  @override
  String get spacesCreateChannel => 'চ্যানেল যোগ করুন';

  @override
  String get spacesChannelName => 'চ্যানেলের নাম';

  @override
  String get spacesChannelTopic => 'বিষয় (ঐচ্ছিক)';

  @override
  String get spacesDeleteChannel => 'চ্যানেল মুছুন';

  @override
  String spacesDeleteChannelConfirm(String name) {
    return 'আপনি কি \"#$name\" মুছতে চান?';
  }

  @override
  String get spacesEditName => 'নাম সম্পাদনা করুন';

  @override
  String get spacesEditDescription => 'বর্ণনা সম্পাদনা করুন';

  @override
  String spacesViewAllMembers(int count) {
    return 'সমস্ত $count সদস্যদের দেখুন';
  }

  @override
  String spacesKickMemberTitle(String name) {
    return '$name কিক করুন';
  }

  @override
  String spacesBanMemberTitle(String name) {
    return 'নিষিদ্ধ $name';
  }

  @override
  String get spacesPromoteAdmin => 'অ্যাডমিনে প্রমোট করুন';

  @override
  String get spacesDemoteAdmin => 'অ্যাডমিন সরান';

  @override
  String get spacesInviteMember => 'সদস্যকে আমন্ত্রণ জানান';

  @override
  String get spacesInviteMemberUserId =>
      'ব্যবহারকারীর আইডি (যেমন @user:server.com)';

  @override
  String get spacesSave => 'সংরক্ষণ করুন';

  @override
  String get settingsScreenshotProtection => 'স্ক্রিনশট সুরক্ষা';

  @override
  String get settingsScreenshotProtectionDesc =>
      'স্ক্রিনশট এবং স্ক্রিন রেকর্ডিং প্রতিরোধ করুন';

  @override
  String get chatSelfDestructTimer => 'আত্ম-ধ্বংস';

  @override
  String get chatTimerPickerTitle => 'স্ব-ধ্বংস টাইমার';

  @override
  String get chatTimerOff => 'বন্ধ';

  @override
  String get onChainNotificationsTitle => 'অন-চেইন ইভেন্ট';

  @override
  String get onChainMarkAllRead => 'সব পড়া চিহ্নিত করুন';

  @override
  String get onChainNoNotifications => 'এখনো কোনো অন-চেইন ইভেন্ট';

  @override
  String get onChainNoNotificationsDesc =>
      'সদস্যতা নেওয়া চ্যানেলের ইভেন্টগুলি এখানে প্রদর্শিত হবে৷';

  @override
  String get onChainViewDetails => 'বিস্তারিত দেখুন';

  @override
  String get chatCommandHelp => '/help — সমস্ত কমান্ড দেখান';

  @override
  String get chatCommandPrice => '/মূল্য - টোকেন মূল্য পান';

  @override
  String get chatCommandBalance => '/ব্যালেন্স — ওয়ালেট ব্যালেন্স দেখান';

  @override
  String get chatCommandChains => '/চেইনস — 236+ সমর্থিত চেইন তালিকাভুক্ত করুন';

  @override
  String get chatMiniApps => 'অ্যাপস';

  @override
  String get miniAppMarketTitle => 'মিনি অ্যাপস';

  @override
  String get miniAppCategoryAll => 'সব';

  @override
  String get miniAppSearch => 'অ্যাপগুলি অনুসন্ধান করুন...';

  @override
  String get miniAppFeatured => 'বৈশিষ্ট্যযুক্ত';

  @override
  String get miniAppAllApps => 'সব অ্যাপ';

  @override
  String get miniAppNoResults => 'কোনো অ্যাপ পাওয়া যায়নি';

  @override
  String get slideToPayLabel => '→→→ নিশ্চিত করতে স্লাইড করুন';

  @override
  String get slideToPayConfirming => 'নিশ্চিত করা হচ্ছে...';

  @override
  String get redPacketBestLuck => 'বেস্ট লাক';

  @override
  String get redPacketBestLuckCongrats => 'বেস্ট লাক! আপনি সবচেয়ে পেয়েছেন!';

  @override
  String redPacketStats(int claimed, int total) {
    return '$claimed / $total দাবি করা হয়েছে';
  }

  @override
  String get redPacketStatsTotal => 'মোট';

  @override
  String redPacketGrabbedViral(String amount, String token) {
    return '🧧 একটি লাল প্যাকেট ধরল • $amount $token';
  }

  @override
  String get web3SearchHint => '@matrix:id • 0x ওয়ালেট ঠিকানা • name.eth';

  @override
  String get web3SearchPlaceholder =>
      'আইডি, ওয়ালেট বা ইএনএস দ্বারা অনুসন্ধান করুন...';

  @override
  String get web3WalletAddress => 'ওয়ালেট ঠিকানা';

  @override
  String get web3AddressCopied => 'ঠিকানা কপি করা হয়েছে';

  @override
  String get web3Copy => 'কপি';

  @override
  String get web3SendMessage => 'বার্তা পাঠান';

  @override
  String get web3SendToWallet => 'বার্তা ওয়ালেট';

  @override
  String get web3WalletOnlyHint =>
      'এই ঠিকানায় এখনও কোন N42 অ্যাকাউন্ট নেই। তারা যোগদান করলে বার্তা পৌঁছে দেওয়া হবে।';

  @override
  String get web3NftAvatar => 'এনএফটি অবতার';

  @override
  String get web3ResolveFailed => 'পরিচয় সমাধান করতে ব্যর্থ হয়েছে';

  @override
  String web3EnsNotFound(String name) {
    return 'ENS নাম \"$name\" পাওয়া যায়নি';
  }

  @override
  String get web3NoN42AccountTitle => 'N42 অ্যাকাউন্ট নেই';

  @override
  String get web3NoN42AccountDesc =>
      'এই মানিব্যাগ ঠিকানা এখনও কোন N42 অ্যাকাউন্ট নেই. আপনি শুরু করতে তাদের সাথে আপনার N42 আমন্ত্রণ লিঙ্ক শেয়ার করতে পারেন।';

  @override
  String get web3ShareInvite => 'শেয়ার আমন্ত্রণ';

  @override
  String get nftPickerTitle => 'NFT অবতার নির্বাচন করুন';

  @override
  String get nftPickerTabPopular => 'জনপ্রিয়';

  @override
  String get nftPickerTabCustom => 'কাস্টম';

  @override
  String get nftPickerChain => 'চেইন';

  @override
  String get nftPickerContract => 'চুক্তির ঠিকানা';

  @override
  String get nftPickerTokenId => 'টোকেন আইডি';

  @override
  String get nftPickerVerifyOwnership => 'মালিকানা এবং পূর্বরূপ যাচাই করুন';

  @override
  String get nftPickerUseAsAvatar => 'অবতার হিসাবে ব্যবহার করুন';

  @override
  String get nftPickerPreview => 'পূর্বরূপ';

  @override
  String get nftPickerNotOwned => 'আপনি এই NFT এর মালিক নন';

  @override
  String get nftPickerInvalidTokenId => 'অবৈধ টোকেন আইডি';

  @override
  String get nftPickerEnterBoth => 'চুক্তির ঠিকানা এবং টোকেন আইডি লিখুন';

  @override
  String get nftPickerInfoTitle => 'NFT অবতার — যাচাইকৃত অন-চেইন';

  @override
  String get nftPickerInfoDesc =>
      'আপনার অবতার হিসাবে আপনার মালিকানাধীন একটি NFT আবদ্ধ করুন। যে কেউ অন-চেইন মালিকানা যাচাই করতে পারেন। N42 জুড়ে একটি সোনার রিং সহ প্রদর্শিত।';

  @override
  String get nftPickerPopularCollections => 'জনপ্রিয় সংগ্রহ';

  @override
  String get nftPickerWalletHint =>
      '236+ চেইন জুড়ে স্বয়ংক্রিয়ভাবে আপনার NFT আবিষ্কার করতে আপনার N42 ওয়ালেট সংযুক্ত করুন।';

  @override
  String get profileBindNftAvatar => 'NFT অবতার বাঁধুন';

  @override
  String get profileChangeAvatar => 'অবতার পরিবর্তন করুন';

  @override
  String get groupTopics => 'বিষয়';

  @override
  String get groupTopicsEmpty => 'এখনও কোন বিষয়';

  @override
  String get syncInProgress => 'বার্তা ইতিহাস সিঙ্ক হচ্ছে...';

  @override
  String get recoveryKeyReminderTitle => 'আপনার বার্তা রক্ষা করুন';

  @override
  String get recoveryKeyReminderDesc =>
      'ডিভাইস জুড়ে এনক্রিপ্ট করা বার্তা নিরাপদে সিঙ্ক করতে একটি পুনরুদ্ধার কী তৈরি করুন';

  @override
  String get recoveryKeySetupNow => 'এখন সেট আপ';

  @override
  String get recoveryKeyRemindLater => 'পরে মনে করিয়ে দিও';

  @override
  String get channelReadOnly =>
      'শুধুমাত্র অ্যাডমিনরাই এই চ্যানেলে পোস্ট করতে পারবেন';

  @override
  String get channelSubscribers => 'গ্রাহকদের';

  @override
  String get channelVerified => 'যাচাইকৃত চ্যানেল';

  @override
  String get redPacketHistory => 'লাল প্যাকেট ইতিহাস';

  @override
  String get redPacketSent => 'পাঠানো হয়েছে';

  @override
  String get redPacketReceived => 'গৃহীত';

  @override
  String get redPacketExpired => 'মেয়াদ শেষ';

  @override
  String get redPacketClaimed => 'দাবি করেছে';

  @override
  String get redPacketInsufficientBalance => 'অপর্যাপ্ত ভারসাম্য';

  @override
  String selfDestructCountdown(String time) {
    return '$time-এ আত্ম-ধ্বংস';
  }

  @override
  String get messageDestroyed => 'বার্তা ধ্বংস করা হয়েছে';

  @override
  String miniAppPermissionDenied(String permission) {
    return 'অনুমতি অস্বীকার করা হয়েছে: $permission';
  }

  @override
  String get aiSuggestionGasFee => 'গ্যাস ফি কি?';

  @override
  String get aiSuggestionDefi => 'DeFi শিক্ষানবিস গাইড';

  @override
  String get aiSuggestionSecurity => 'চুক্তির নিরাপত্তা কিভাবে চেক করবেন';

  @override
  String get aiSuggestionBridge => 'ক্রস-চেইন ব্রিজিং';

  @override
  String get channelDiscoverTitle => 'চ্যানেল আবিষ্কার করুন';

  @override
  String get channelDiscoverSearch => 'চ্যানেল অনুসন্ধান করুন...';

  @override
  String get channelJoin => 'যোগদান করুন';

  @override
  String get channelJoined => 'যোগদান করেছেন';

  @override
  String get channelCategory => 'শ্রেণী';

  @override
  String slowModeCooldown(int seconds) {
    return 'ধীর মোড: ${seconds}s অপেক্ষা করুন';
  }

  @override
  String get addressCopyAction => 'কপি ঠিকানা';

  @override
  String get addressSendMessage => 'বার্তা পাঠান';

  @override
  String get addressViewProfile => 'প্রোফাইল দেখুন';

  @override
  String get sendToAddress => 'ওয়ালেট ঠিকানায় পাঠান';

  @override
  String get blocAuthSendVerificationCodeFailed =>
      'যাচাইকরণ কোড পাঠাতে ব্যর্থ হয়েছে৷';

  @override
  String get blocAuthServerNoEmailPasswordReset =>
      'এই সার্ভার ইমেল পাসওয়ার্ড রিসেট সমর্থন করে না';

  @override
  String get blocAuthResetPasswordFailed =>
      'পাসওয়ার্ড রিসেট করতে ব্যর্থ হয়েছে৷';

  @override
  String get blocAuthChangePasswordFailed =>
      'পাসওয়ার্ড পরিবর্তন করতে ব্যর্থ হয়েছে';

  @override
  String get blocAuthOldPasswordWrong => 'ভুল বর্তমান পাসওয়ার্ড';

  @override
  String get blocAuthLoginCancelled => 'লগইন বাতিল করা হয়েছে৷';

  @override
  String get blocAuthGoogleLoginFailed => 'Google লগইন ব্যর্থ হয়েছে';

  @override
  String get blocAuthAppleLoginFailed => 'অ্যাপল লগইন ব্যর্থ হয়েছে';

  @override
  String get blocAuthSsoLoginFailed => 'SSO লগইন ব্যর্থ হয়েছে৷';

  @override
  String get blocAuthFacebookLoginFailed => 'ফেসবুক লগইন ব্যর্থ হয়েছে';

  @override
  String get blocAuthTwitterLoginFailed => 'টুইটার লগইন ব্যর্থ হয়েছে';

  @override
  String get blocAuthWeChatLoginFailed => 'WeChat লগইন ব্যর্থ হয়েছে';

  @override
  String get blocAuthWeChatNotConfigured => 'WeChat লগইন কনফিগার করা হয়নি';

  @override
  String get blocAuthWeChatNotInstalled =>
      'অনুগ্রহ করে প্রথমে WeChat ইনস্টল করুন';

  @override
  String get blocAuthPasswordWrong => 'ভুল পাসওয়ার্ড';

  @override
  String get blocAuthEmailAlreadyBound =>
      'এই ইমেলটি ইতিমধ্যেই অন্য অ্যাকাউন্টে আবদ্ধ৷';

  @override
  String get blocAuthChangeEmailFailed => 'ইমেল পরিবর্তন করতে ব্যর্থ হয়েছে';

  @override
  String get blocAuthVerificationCodeInvalid =>
      'যাচাইকরণ কোডটি ভুল বা মেয়াদ উত্তীর্ণ';

  @override
  String get blocAuthSessionExpired =>
      'সেশনের মেয়াদ শেষ হয়েছে, অনুগ্রহ করে আবার লগইন করুন';

  @override
  String get blocAuthSessionIncomplete =>
      'সেশন ডেটা অসম্পূর্ণ, অনুগ্রহ করে আবার লগইন করুন';
}
