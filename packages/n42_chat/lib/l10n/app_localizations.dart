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
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonUnknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get commonUnknownUser;

  /// No description provided for @transferWalletNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Wallet Not Connected'**
  String get transferWalletNotConnected;

  /// No description provided for @chatCallServiceNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'Call service not initialized'**
  String get chatCallServiceNotInitialized;

  /// No description provided for @authLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String authLoginFailed(Object error);

  /// No description provided for @chatCallBack.
  ///
  /// In en, this message translates to:
  /// **'Call back'**
  String get chatCallBack;

  /// No description provided for @chatMissedVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Missed video call'**
  String get chatMissedVideoCall;

  /// No description provided for @chatMissedVoiceCall.
  ///
  /// In en, this message translates to:
  /// **'Missed voice call'**
  String get chatMissedVoiceCall;

  /// No description provided for @chatCallNotAnswered.
  ///
  /// In en, this message translates to:
  /// **'Not answered'**
  String get chatCallNotAnswered;

  /// No description provided for @chatCallDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Call duration'**
  String get chatCallDurationLabel;

  /// No description provided for @chatVoiceCallCancelled.
  ///
  /// In en, this message translates to:
  /// **'Voice call cancelled'**
  String get chatVoiceCallCancelled;

  /// No description provided for @chatVideoCallCancelled.
  ///
  /// In en, this message translates to:
  /// **'Video call cancelled'**
  String get chatVideoCallCancelled;

  /// No description provided for @commonImage.
  ///
  /// In en, this message translates to:
  /// **'[Image]'**
  String get commonImage;

  /// No description provided for @chatVideo.
  ///
  /// In en, this message translates to:
  /// **'[Video]'**
  String get chatVideo;

  /// No description provided for @chatVoice.
  ///
  /// In en, this message translates to:
  /// **'[Voice]'**
  String get chatVoice;

  /// No description provided for @commonFile.
  ///
  /// In en, this message translates to:
  /// **'[File]'**
  String get commonFile;

  /// No description provided for @chatLocation.
  ///
  /// In en, this message translates to:
  /// **'[Location]'**
  String get chatLocation;

  /// No description provided for @chatUnknownMessage.
  ///
  /// In en, this message translates to:
  /// **'[Unknown message]'**
  String get chatUnknownMessage;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @chatDeleteThisMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this message?'**
  String get chatDeleteThisMessage;

  /// No description provided for @chatMessageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get chatMessageDeleted;

  /// No description provided for @profileNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get profileNotLoggedIn;

  /// No description provided for @chatMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get chatMyLocation;

  /// No description provided for @commonGroupChat.
  ///
  /// In en, this message translates to:
  /// **'Group Chat'**
  String get commonGroupChat;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get commonLoadFailed;

  /// No description provided for @commonMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get commonMessages;

  /// No description provided for @commonContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get commonContacts;

  /// No description provided for @commonMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get commonMe;

  /// No description provided for @commonVoiceLoading.
  ///
  /// In en, this message translates to:
  /// **'Voice loading, please try again later'**
  String get commonVoiceLoading;

  /// No description provided for @commonVoiceToTextFailed.
  ///
  /// In en, this message translates to:
  /// **'Voice to text failed'**
  String get commonVoiceToTextFailed;

  /// No description provided for @commonConvertToText.
  ///
  /// In en, this message translates to:
  /// **'To text'**
  String get commonConvertToText;

  /// No description provided for @chatCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get chatCopy;

  /// No description provided for @commonForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get commonForward;

  /// No description provided for @commonUnfavorite.
  ///
  /// In en, this message translates to:
  /// **'Unfav'**
  String get commonUnfavorite;

  /// No description provided for @commonFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get commonFavorite;

  /// No description provided for @settingsResend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get settingsResend;

  /// No description provided for @chatRecall.
  ///
  /// In en, this message translates to:
  /// **'Recall'**
  String get chatRecall;

  /// No description provided for @commonQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get commonQuote;

  /// No description provided for @commonRemind.
  ///
  /// In en, this message translates to:
  /// **'Remind'**
  String get commonRemind;

  /// No description provided for @chatCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get chatCopied;

  /// No description provided for @storySendMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Send a message'**
  String get storySendMessageHint;

  /// No description provided for @commonMicrophonePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please allow microphone permission'**
  String get commonMicrophonePermissionRequired;

  /// No description provided for @chatMicrophonePermissionDeniedPermanent.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission has been denied. Please enable it in system settings to use voice messages.'**
  String get chatMicrophonePermissionDeniedPermanent;

  /// No description provided for @commonStartRecordingFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to start recording: {error}'**
  String commonStartRecordingFailed(Object error);

  /// No description provided for @commonRecordingTooShort.
  ///
  /// In en, this message translates to:
  /// **'Recording too short'**
  String get commonRecordingTooShort;

  /// No description provided for @commonStopRecordingFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to stop recording: {error}'**
  String commonStopRecordingFailed(Object error);

  /// No description provided for @chatReleaseToCancel.
  ///
  /// In en, this message translates to:
  /// **'Release to cancel'**
  String get chatReleaseToCancel;

  /// No description provided for @chatReleaseToSend.
  ///
  /// In en, this message translates to:
  /// **'Release to send, swipe up to cancel'**
  String get chatReleaseToSend;

  /// No description provided for @commonHoldToTalk.
  ///
  /// In en, this message translates to:
  /// **'Hold to talk'**
  String get commonHoldToTalk;

  /// No description provided for @commonSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get commonSend;

  /// No description provided for @commonAddFriend.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get commonAddFriend;

  /// No description provided for @commonChatServiceNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Chat service not connected'**
  String get commonChatServiceNotConnected;

  /// No description provided for @contactUserNotFoundHint.
  ///
  /// In en, this message translates to:
  /// **'User \"{query}\" not found\n\nTips:\n• Try entering full user ID, e.g. @username:server.com\n• Check the username spelling'**
  String contactUserNotFoundHint(String query);

  /// No description provided for @contactCreateChatFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create chat: {error}'**
  String contactCreateChatFailed(String error);

  /// No description provided for @contactSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed: {error}'**
  String contactSearchFailed(String error);

  /// No description provided for @contactEnterUserIdOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter user ID or username to search'**
  String get contactEnterUserIdOrUsername;

  /// No description provided for @contactSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get contactSearching;

  /// No description provided for @contactSearchUserToChat.
  ///
  /// In en, this message translates to:
  /// **'Search user to start chatting'**
  String get contactSearchUserToChat;

  /// No description provided for @contactMatrixIdExample.
  ///
  /// In en, this message translates to:
  /// **'You can enter a full Matrix ID\ne.g. @user:matrix.n42.network'**
  String get contactMatrixIdExample;

  /// No description provided for @contactUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User \"{username}\" not found'**
  String contactUserNotFound(String username);

  /// No description provided for @commonChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get commonChat;

  /// No description provided for @commonSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get commonSettings;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get authLogin;

  /// No description provided for @commonCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get commonCreateGroup;

  /// No description provided for @chatError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get chatError;

  /// No description provided for @commonTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get commonTransfer;

  /// No description provided for @commonReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get commonReceived;

  /// No description provided for @commonRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get commonRefunded;

  /// No description provided for @commonExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get commonExpired;

  /// No description provided for @chatRedPacketGreeting.
  ///
  /// In en, this message translates to:
  /// **'Best wishes'**
  String get chatRedPacketGreeting;

  /// No description provided for @commonN42RedPacket.
  ///
  /// In en, this message translates to:
  /// **'N42 Red Packet'**
  String get commonN42RedPacket;

  /// No description provided for @commonClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get commonClaimed;

  /// No description provided for @commonAllClaimed.
  ///
  /// In en, this message translates to:
  /// **'All claimed'**
  String get commonAllClaimed;

  /// No description provided for @chatReadAloud.
  ///
  /// In en, this message translates to:
  /// **'Read Aloud'**
  String get chatReadAloud;

  /// No description provided for @chatReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get chatReply;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @chatSelectForwardTarget.
  ///
  /// In en, this message translates to:
  /// **'Select Forward Target'**
  String get chatSelectForwardTarget;

  /// No description provided for @commonSendCount.
  ///
  /// In en, this message translates to:
  /// **'Send({count})'**
  String commonSendCount(int count);

  /// No description provided for @contactN42Id.
  ///
  /// In en, this message translates to:
  /// **'N42 ID: {id}'**
  String contactN42Id(Object id);

  /// No description provided for @profileN42IdTitle.
  ///
  /// In en, this message translates to:
  /// **'N42 ID'**
  String get profileN42IdTitle;

  /// No description provided for @profileN42Bean.
  ///
  /// In en, this message translates to:
  /// **'N42 Bean'**
  String get profileN42Bean;

  /// No description provided for @contactFriendInfo.
  ///
  /// In en, this message translates to:
  /// **'Friend Info'**
  String get contactFriendInfo;

  /// No description provided for @contactFriendInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Add friend\'s remark, phone, tags, notes, photos and set permissions.'**
  String get contactFriendInfoDesc;

  /// No description provided for @commonMoments.
  ///
  /// In en, this message translates to:
  /// **'Moments'**
  String get commonMoments;

  /// No description provided for @commonSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get commonSendMessage;

  /// No description provided for @contactAudioVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Audio/Video Call'**
  String get contactAudioVideoCall;

  /// No description provided for @contactVideoChannel.
  ///
  /// In en, this message translates to:
  /// **'Video Channel'**
  String get contactVideoChannel;

  /// No description provided for @contactRemark.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get contactRemark;

  /// No description provided for @contactRemarkName.
  ///
  /// In en, this message translates to:
  /// **'Remark Name'**
  String get contactRemarkName;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get contactPhone;

  /// No description provided for @contactTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get contactTags;

  /// No description provided for @contactNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get contactNotes;

  /// No description provided for @contactPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get contactPhotos;

  /// No description provided for @contactPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get contactPermissions;

  /// No description provided for @contactChatMomentsEtc.
  ///
  /// In en, this message translates to:
  /// **'Chat, Moments, Sports, etc.'**
  String get contactChatMomentsEtc;

  /// No description provided for @contactMoreInfo.
  ///
  /// In en, this message translates to:
  /// **'More Info'**
  String get contactMoreInfo;

  /// No description provided for @contactCommonGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups in common'**
  String get contactCommonGroups;

  /// No description provided for @contactSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get contactSource;

  /// No description provided for @settingsNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationSettings;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @commonLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get commonLogout;

  /// No description provided for @commonLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get commonLogoutConfirm;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @profileNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get profileNickname;

  /// No description provided for @profileEnterNickname.
  ///
  /// In en, this message translates to:
  /// **'Enter nickname'**
  String get profileEnterNickname;

  /// No description provided for @profileSignature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get profileSignature;

  /// No description provided for @profileAddSignature.
  ///
  /// In en, this message translates to:
  /// **'Add a signature'**
  String get profileAddSignature;

  /// No description provided for @commonTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get commonTakePhoto;

  /// No description provided for @profileChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get profileChooseFromGallery;

  /// No description provided for @profileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String profileSaveFailed(Object error);

  /// No description provided for @authSecureDecentralizedChat.
  ///
  /// In en, this message translates to:
  /// **'Secure, decentralized messaging'**
  String get authSecureDecentralizedChat;

  /// No description provided for @commonEndToEndEncryption.
  ///
  /// In en, this message translates to:
  /// **'End-to-End Encryption'**
  String get commonEndToEndEncryption;

  /// No description provided for @authMessagesOnlyYouCanSee.
  ///
  /// In en, this message translates to:
  /// **'Messages visible only to you and the recipient'**
  String get authMessagesOnlyYouCanSee;

  /// No description provided for @authDecentralized.
  ///
  /// In en, this message translates to:
  /// **'Decentralized'**
  String get authDecentralized;

  /// No description provided for @authBasedOnMatrix.
  ///
  /// In en, this message translates to:
  /// **'Built on the Matrix open protocol'**
  String get authBasedOnMatrix;

  /// No description provided for @authWalletIntegration.
  ///
  /// In en, this message translates to:
  /// **'Wallet Integration'**
  String get authWalletIntegration;

  /// No description provided for @authEasyCryptoTransfer.
  ///
  /// In en, this message translates to:
  /// **'Easy cryptocurrency transfers'**
  String get authEasyCryptoTransfer;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authRegister;

  /// No description provided for @authAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'By logging in, you agree to'**
  String get authAgreeTerms;

  /// No description provided for @authTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get authTermsOfService;

  /// No description provided for @authAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get authAnd;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authPrivacyPolicy;

  /// No description provided for @authServerAddress.
  ///
  /// In en, this message translates to:
  /// **'Server Address'**
  String get authServerAddress;

  /// No description provided for @authEnterServerAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter server address'**
  String get authEnterServerAddress;

  /// No description provided for @authConnectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected to {serverName}'**
  String authConnectedTo(Object serverName);

  /// No description provided for @authUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsername;

  /// No description provided for @authEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get authEnterUsername;

  /// No description provided for @authUsernameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Username or Email'**
  String get authUsernameOrEmail;

  /// No description provided for @authEnterUsernameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter username or email'**
  String get authEnterUsernameOrEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get authEnterPassword;

  /// No description provided for @authRegisterAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authRegisterAccount;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get authForgotPassword;

  /// No description provided for @authOtherLoginMethods.
  ///
  /// In en, this message translates to:
  /// **'Other login methods'**
  String get authOtherLoginMethods;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// No description provided for @authJoinN42Chat.
  ///
  /// In en, this message translates to:
  /// **'Join N42 Chat to start chatting'**
  String get authJoinN42Chat;

  /// No description provided for @authUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'3-20 chars, letters/numbers/_'**
  String get authUsernameHint;

  /// No description provided for @authUsernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get authUsernameMinLength;

  /// No description provided for @authUsernameMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at most 20 characters'**
  String get authUsernameMaxLength;

  /// No description provided for @authUsernameFormat.
  ///
  /// In en, this message translates to:
  /// **'Username can only contain letters, numbers, and underscores'**
  String get authUsernameFormat;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Min 8 characters'**
  String get authPasswordHint;

  /// No description provided for @commonPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get commonPasswordMinLength;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPassword;

  /// No description provided for @authFilled.
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get authFilled;

  /// No description provided for @authEnterInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Enter invite code'**
  String get authEnterInviteCode;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authLoginNow.
  ///
  /// In en, this message translates to:
  /// **'Log in now'**
  String get authLoginNow;

  /// No description provided for @profileAvatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get profileAvatar;

  /// No description provided for @profileStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get profileStatus;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @conversationNoConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations'**
  String get conversationNoConversations;

  /// No description provided for @conversationTapToChat.
  ///
  /// In en, this message translates to:
  /// **'Tap the top right to start chatting'**
  String get conversationTapToChat;

  /// No description provided for @conversationStartGroup.
  ///
  /// In en, this message translates to:
  /// **'Start Group Chat'**
  String get conversationStartGroup;

  /// No description provided for @commonScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get commonScan;

  /// No description provided for @commonPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get commonPayment;

  /// No description provided for @commonFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} coming soon'**
  String commonFeatureComingSoon(Object feature);

  /// No description provided for @conversationMarkAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get conversationMarkAsRead;

  /// No description provided for @commonUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get commonUnmute;

  /// No description provided for @commonMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get commonMute;

  /// No description provided for @conversationUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get conversationUnpin;

  /// No description provided for @conversationPin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get conversationPin;

  /// No description provided for @conversationDeleteConversation.
  ///
  /// In en, this message translates to:
  /// **'Delete Conversation'**
  String get conversationDeleteConversation;

  /// No description provided for @conversationDeleteConversationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation with \"{name}\"?'**
  String conversationDeleteConversationConfirm(Object name);

  /// No description provided for @commonNoContacts.
  ///
  /// In en, this message translates to:
  /// **'No contacts'**
  String get commonNoContacts;

  /// No description provided for @contactAddFriendsToChat.
  ///
  /// In en, this message translates to:
  /// **'Add friends to start chatting'**
  String get contactAddFriendsToChat;

  /// No description provided for @contactNotFound.
  ///
  /// In en, this message translates to:
  /// **'Contact not found'**
  String get contactNotFound;

  /// No description provided for @contactTryOtherKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try other keywords or global search'**
  String get contactTryOtherKeywords;

  /// No description provided for @contactSearchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get contactSearchResults;

  /// No description provided for @contactNewFriends.
  ///
  /// In en, this message translates to:
  /// **'New Friends'**
  String get contactNewFriends;

  /// No description provided for @contactChatOnlyFriends.
  ///
  /// In en, this message translates to:
  /// **'Chat-only Friends'**
  String get contactChatOnlyFriends;

  /// No description provided for @contactOfficialAccounts.
  ///
  /// In en, this message translates to:
  /// **'Official Accounts'**
  String get contactOfficialAccounts;

  /// No description provided for @contactServiceAccounts.
  ///
  /// In en, this message translates to:
  /// **'Service Accounts'**
  String get contactServiceAccounts;

  /// No description provided for @contactEnterpriseContacts.
  ///
  /// In en, this message translates to:
  /// **'Enterprise Contacts'**
  String get contactEnterpriseContacts;

  /// No description provided for @contactRecommendToFriend.
  ///
  /// In en, this message translates to:
  /// **'Share contact'**
  String get contactRecommendToFriend;

  /// No description provided for @commonSetRemark.
  ///
  /// In en, this message translates to:
  /// **'Set remark'**
  String get commonSetRemark;

  /// No description provided for @contactSendingCard.
  ///
  /// In en, this message translates to:
  /// **'Sending contact card...'**
  String get contactSendingCard;

  /// No description provided for @commonFileLabel.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get commonFileLabel;

  /// No description provided for @commonLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get commonLocationLabel;

  /// No description provided for @contactRecommendFailed.
  ///
  /// In en, this message translates to:
  /// **'Recommend failed: {error}'**
  String contactRecommendFailed(Object error);

  /// No description provided for @profileEnterRemark.
  ///
  /// In en, this message translates to:
  /// **'Enter remark'**
  String get profileEnterRemark;

  /// No description provided for @contactOpeningChat.
  ///
  /// In en, this message translates to:
  /// **'Opening chat...'**
  String get contactOpeningChat;

  /// No description provided for @contactOpenChatFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open chat: {error}'**
  String contactOpenChatFailed(Object error);

  /// No description provided for @contactAddContact.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get contactAddContact;

  /// No description provided for @contactEnterUserId.
  ///
  /// In en, this message translates to:
  /// **'Enter user ID'**
  String get contactEnterUserId;

  /// No description provided for @contactNoFriendRequests.
  ///
  /// In en, this message translates to:
  /// **'No friend requests'**
  String get contactNoFriendRequests;

  /// No description provided for @commonAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get commonAccept;

  /// No description provided for @commonReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get commonReject;

  /// No description provided for @commonNoGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups'**
  String get commonNoGroups;

  /// No description provided for @contactSelectFriendToRecommend.
  ///
  /// In en, this message translates to:
  /// **'Select a friend to recommend to'**
  String get contactSelectFriendToRecommend;

  /// No description provided for @commonSearchContacts.
  ///
  /// In en, this message translates to:
  /// **'Search contacts'**
  String get commonSearchContacts;

  /// No description provided for @contactNoContactsFound.
  ///
  /// In en, this message translates to:
  /// **'No contacts found'**
  String get contactNoContactsFound;

  /// No description provided for @favoriteYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get favoriteYesterday;

  /// No description provided for @chatJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get chatJustNow;

  /// No description provided for @profileOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get profileOnline;

  /// No description provided for @profileOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get profileOffline;

  /// No description provided for @searchContactsGroupsMessages.
  ///
  /// In en, this message translates to:
  /// **'Search contacts, groups and messages'**
  String get searchContactsGroupsMessages;

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Search Error'**
  String get searchError;

  /// No description provided for @chatSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get chatSearchHint;

  /// No description provided for @searchHistory.
  ///
  /// In en, this message translates to:
  /// **'Search History'**
  String get searchHistory;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @searchGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get searchGroups;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No Results'**
  String get searchNoResults;

  /// No description provided for @commonGroupMembers.
  ///
  /// In en, this message translates to:
  /// **'Members ({count})'**
  String commonGroupMembers(Object count);

  /// No description provided for @groupMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Members'**
  String get groupMembersTitle;

  /// No description provided for @groupViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get groupViewAll;

  /// No description provided for @groupOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get groupOwner;

  /// No description provided for @groupAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get groupAdmin;

  /// No description provided for @groupInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get groupInvite;

  /// No description provided for @commonGroupAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Group Announcement'**
  String get commonGroupAnnouncement;

  /// No description provided for @commonNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get commonNotSet;

  /// No description provided for @groupDescription.
  ///
  /// In en, this message translates to:
  /// **'Group Description'**
  String get groupDescription;

  /// No description provided for @groupPublicGroup.
  ///
  /// In en, this message translates to:
  /// **'Public Group'**
  String get groupPublicGroup;

  /// No description provided for @commonClearChatHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat History'**
  String get commonClearChatHistory;

  /// No description provided for @commonDissolveGroup.
  ///
  /// In en, this message translates to:
  /// **'Dissolve Group'**
  String get commonDissolveGroup;

  /// No description provided for @commonLeaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get commonLeaveGroup;

  /// No description provided for @groupChangeGroupName.
  ///
  /// In en, this message translates to:
  /// **'Change Group Name'**
  String get groupChangeGroupName;

  /// No description provided for @commonEnterGroupName.
  ///
  /// In en, this message translates to:
  /// **'Enter group name'**
  String get commonEnterGroupName;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @groupEnterGroupDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter group description'**
  String get groupEnterGroupDescription;

  /// No description provided for @groupPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get groupPublish;

  /// No description provided for @chatClearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear all chat history? This cannot be undone.'**
  String get chatClearHistoryConfirm;

  /// No description provided for @chatClearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get chatClearAction;

  /// No description provided for @commonChatHistoryCleared.
  ///
  /// In en, this message translates to:
  /// **'Chat history cleared'**
  String get commonChatHistoryCleared;

  /// No description provided for @commonDissolve.
  ///
  /// In en, this message translates to:
  /// **'Dissolve'**
  String get commonDissolve;

  /// No description provided for @groupQrCode.
  ///
  /// In en, this message translates to:
  /// **'Group QR Code'**
  String get groupQrCode;

  /// No description provided for @commonSearchChatHistory.
  ///
  /// In en, this message translates to:
  /// **'Search Chat History'**
  String get commonSearchChatHistory;

  /// No description provided for @groupIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Group ID copied'**
  String get groupIdCopied;

  /// No description provided for @transferEnterOrPasteAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter or paste wallet address'**
  String get transferEnterOrPasteAddress;

  /// No description provided for @transferSelectToken.
  ///
  /// In en, this message translates to:
  /// **'Select Token'**
  String get transferSelectToken;

  /// No description provided for @commonTransferAmount.
  ///
  /// In en, this message translates to:
  /// **'Transfer Amount'**
  String get commonTransferAmount;

  /// No description provided for @transferAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get transferAvailable;

  /// No description provided for @transferMemoOptional.
  ///
  /// In en, this message translates to:
  /// **'Memo (optional)'**
  String get transferMemoOptional;

  /// No description provided for @transferConfirmTransfer.
  ///
  /// In en, this message translates to:
  /// **'Confirm Transfer'**
  String get transferConfirmTransfer;

  /// No description provided for @transferAddressVerified.
  ///
  /// In en, this message translates to:
  /// **'Address verified'**
  String get transferAddressVerified;

  /// No description provided for @transferAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available: {balance} {symbol}'**
  String transferAvailableBalance(Object balance, Object symbol);

  /// No description provided for @commonEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get commonEnterAmount;

  /// No description provided for @commonRedPacketCountMin.
  ///
  /// In en, this message translates to:
  /// **'At least 1 red packet required'**
  String get commonRedPacketCountMin;

  /// No description provided for @commonViewRedPacketDetails.
  ///
  /// In en, this message translates to:
  /// **'View Red Packet Details'**
  String get commonViewRedPacketDetails;

  /// No description provided for @commonEnterTransferAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter transfer amount'**
  String get commonEnterTransferAmount;

  /// No description provided for @commonTransferTo.
  ///
  /// In en, this message translates to:
  /// **'Transfer to'**
  String get commonTransferTo;

  /// No description provided for @commonFromSender.
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String commonFromSender(String name, Object senderName);

  /// No description provided for @commonConfirmReceive.
  ///
  /// In en, this message translates to:
  /// **'Confirm Receipt'**
  String get commonConfirmReceive;

  /// No description provided for @groupProfile.
  ///
  /// In en, this message translates to:
  /// **'Group Info'**
  String get groupProfile;

  /// No description provided for @groupRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Remove from Group'**
  String get groupRemoveMember;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @profileClearStatus.
  ///
  /// In en, this message translates to:
  /// **'Clear Status'**
  String get profileClearStatus;

  /// No description provided for @profileClearStatusConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear current status?'**
  String get profileClearStatusConfirm;

  /// No description provided for @profileStatusCleared.
  ///
  /// In en, this message translates to:
  /// **'Status cleared'**
  String get profileStatusCleared;

  /// No description provided for @profileUserNotExist.
  ///
  /// In en, this message translates to:
  /// **'User does not exist'**
  String get profileUserNotExist;

  /// No description provided for @profileUserIdCopied.
  ///
  /// In en, this message translates to:
  /// **'User ID copied'**
  String get profileUserIdCopied;

  /// No description provided for @commonReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get commonReport;

  /// No description provided for @profileQrCode.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get profileQrCode;

  /// No description provided for @profileAvatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated'**
  String get profileAvatarUpdated;

  /// No description provided for @commonSelectImageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to select image: {error}'**
  String commonSelectImageFailed(Object error);

  /// No description provided for @profileChangeName.
  ///
  /// In en, this message translates to:
  /// **'Change Name'**
  String get profileChangeName;

  /// No description provided for @profileMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get profileMale;

  /// No description provided for @profileFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get profileFemale;

  /// No description provided for @chatFeatureInDev.
  ///
  /// In en, this message translates to:
  /// **'{feature} feature in development...'**
  String chatFeatureInDev(String feature);

  /// No description provided for @profileSaveAddressFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save address: {error}'**
  String profileSaveAddressFailed(Object error);

  /// No description provided for @profileAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get profileAddNew;

  /// No description provided for @profileAddAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get profileAddAddress;

  /// No description provided for @profileAddressAdded.
  ///
  /// In en, this message translates to:
  /// **'Address added'**
  String get profileAddressAdded;

  /// No description provided for @profileAddressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Address updated'**
  String get profileAddressUpdated;

  /// No description provided for @profileDeleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Delete Address'**
  String get profileDeleteAddress;

  /// No description provided for @profileAddressDeleted.
  ///
  /// In en, this message translates to:
  /// **'Address deleted'**
  String get profileAddressDeleted;

  /// No description provided for @profileSaveInvoiceFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save invoice: {error}'**
  String profileSaveInvoiceFailed(Object error);

  /// No description provided for @profileMyInvoices.
  ///
  /// In en, this message translates to:
  /// **'My Invoices'**
  String get profileMyInvoices;

  /// No description provided for @profileAddInvoice.
  ///
  /// In en, this message translates to:
  /// **'Add Invoice'**
  String get profileAddInvoice;

  /// No description provided for @profileInvoiceAdded.
  ///
  /// In en, this message translates to:
  /// **'Invoice added'**
  String get profileInvoiceAdded;

  /// No description provided for @profileInvoiceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Invoice updated'**
  String get profileInvoiceUpdated;

  /// No description provided for @profileDeleteInvoice.
  ///
  /// In en, this message translates to:
  /// **'Delete Invoice'**
  String get profileDeleteInvoice;

  /// No description provided for @profileInvoiceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Invoice deleted'**
  String get profileInvoiceDeleted;

  /// No description provided for @profilePersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get profilePersonal;

  /// No description provided for @groupSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one member'**
  String get groupSelectAtLeastOne;

  /// No description provided for @chatFileNotExist.
  ///
  /// In en, this message translates to:
  /// **'File does not exist'**
  String get chatFileNotExist;

  /// No description provided for @chatSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Send failed: {error}'**
  String chatSendFailed(String error);

  /// No description provided for @chatCannotOpenBrowser.
  ///
  /// In en, this message translates to:
  /// **'Cannot open browser'**
  String get chatCannotOpenBrowser;

  /// No description provided for @chatSelectFileFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to select file: {error}'**
  String chatSelectFileFailed(String error);

  /// No description provided for @settingsSetupFailed.
  ///
  /// In en, this message translates to:
  /// **'Setup failed: {error}'**
  String settingsSetupFailed(String error);

  /// No description provided for @transferEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get transferEnterValidAmount;

  /// No description provided for @commonAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get commonAddressCopied;

  /// No description provided for @favoriteOpenItem.
  ///
  /// In en, this message translates to:
  /// **'Open: {content}'**
  String favoriteOpenItem(Object content);

  /// No description provided for @favoriteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get favoriteDeleted;

  /// No description provided for @profileWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get profileWallet;

  /// No description provided for @chatRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get chatRecording;

  /// No description provided for @chatInvalidVideoUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid video URL'**
  String get chatInvalidVideoUrl;

  /// No description provided for @chatDownloadFile.
  ///
  /// In en, this message translates to:
  /// **'Download file'**
  String get chatDownloadFile;

  /// No description provided for @chatClearChatHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat History'**
  String get chatClearChatHistoryTitle;

  /// No description provided for @chatVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Video Call'**
  String get chatVideoCall;

  /// No description provided for @commonVoiceCall.
  ///
  /// In en, this message translates to:
  /// **'Voice Call'**
  String get commonVoiceCall;

  /// No description provided for @callLeaveMeeting.
  ///
  /// In en, this message translates to:
  /// **'Leave Meeting'**
  String get callLeaveMeeting;

  /// No description provided for @chatDetails.
  ///
  /// In en, this message translates to:
  /// **'Chat Details'**
  String get chatDetails;

  /// No description provided for @chatViewAllGroupMembers.
  ///
  /// In en, this message translates to:
  /// **'View all members'**
  String get chatViewAllGroupMembers;

  /// No description provided for @chatGroupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get chatGroupName;

  /// No description provided for @chatGroupNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Group name updated'**
  String get chatGroupNameUpdated;

  /// No description provided for @chatUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get chatUpdateFailed;

  /// No description provided for @chatNoPermissionToModify.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to modify'**
  String get chatNoPermissionToModify;

  /// No description provided for @chatGroupManagement.
  ///
  /// In en, this message translates to:
  /// **'Group Management'**
  String get chatGroupManagement;

  /// No description provided for @chatMyNicknameInGroup.
  ///
  /// In en, this message translates to:
  /// **'My Nickname in Group'**
  String get chatMyNicknameInGroup;

  /// No description provided for @chatPinChat.
  ///
  /// In en, this message translates to:
  /// **'Pin Chat'**
  String get chatPinChat;

  /// No description provided for @chatStrongReminder.
  ///
  /// In en, this message translates to:
  /// **'Strong Reminder'**
  String get chatStrongReminder;

  /// No description provided for @chatSetChatBackground.
  ///
  /// In en, this message translates to:
  /// **'Set Chat Background'**
  String get chatSetChatBackground;

  /// No description provided for @chatUnknownFile.
  ///
  /// In en, this message translates to:
  /// **'Unknown file'**
  String get chatUnknownFile;

  /// No description provided for @chatDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get chatDownload;

  /// No description provided for @chatInvalidLocation.
  ///
  /// In en, this message translates to:
  /// **'Invalid location'**
  String get chatInvalidLocation;

  /// No description provided for @chatTapToCancel.
  ///
  /// In en, this message translates to:
  /// **'Tap to cancel'**
  String get chatTapToCancel;

  /// No description provided for @chatCaptureFailed.
  ///
  /// In en, this message translates to:
  /// **'Capture failed: {error}'**
  String chatCaptureFailed(Object error);

  /// No description provided for @chatProcessingVideo.
  ///
  /// In en, this message translates to:
  /// **'Processing video...'**
  String get chatProcessingVideo;

  /// No description provided for @chatVideoFileNotExist.
  ///
  /// In en, this message translates to:
  /// **'Video file does not exist'**
  String get chatVideoFileNotExist;

  /// No description provided for @chatVideoDataEmpty.
  ///
  /// In en, this message translates to:
  /// **'Video data is empty'**
  String get chatVideoDataEmpty;

  /// No description provided for @chatVideoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Video size cannot exceed 100MB'**
  String get chatVideoTooLarge;

  /// No description provided for @chatSendingVideo.
  ///
  /// In en, this message translates to:
  /// **'Sending video...'**
  String get chatSendingVideo;

  /// No description provided for @chatSendVideoFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send video: {error}'**
  String chatSendVideoFailed(Object error);

  /// No description provided for @chatImageFileNotExist.
  ///
  /// In en, this message translates to:
  /// **'Image file does not exist'**
  String get chatImageFileNotExist;

  /// No description provided for @commonImageDataEmpty.
  ///
  /// In en, this message translates to:
  /// **'Image data is empty'**
  String get commonImageDataEmpty;

  /// No description provided for @chatSendingImage.
  ///
  /// In en, this message translates to:
  /// **'Sending image...'**
  String get chatSendingImage;

  /// No description provided for @chatSendImageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send image: {error}'**
  String chatSendImageFailed(Object error);

  /// No description provided for @chatSendLocation.
  ///
  /// In en, this message translates to:
  /// **'Send Location'**
  String get chatSendLocation;

  /// No description provided for @chatSelectLocationAndSend.
  ///
  /// In en, this message translates to:
  /// **'Select location and send'**
  String get chatSelectLocationAndSend;

  /// No description provided for @chatShareRealTimeLocation.
  ///
  /// In en, this message translates to:
  /// **'Share Real-time Location'**
  String get chatShareRealTimeLocation;

  /// No description provided for @chatShareLocationForOneHour.
  ///
  /// In en, this message translates to:
  /// **'Share real-time location with friend for 1 hour'**
  String get chatShareLocationForOneHour;

  /// No description provided for @chatLocationSent.
  ///
  /// In en, this message translates to:
  /// **'Location sent'**
  String get chatLocationSent;

  /// No description provided for @chatSelectMessages.
  ///
  /// In en, this message translates to:
  /// **'Select messages'**
  String get chatSelectMessages;

  /// No description provided for @chatSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'Selected {count}'**
  String chatSelectedCount(int count);

  /// No description provided for @chatSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get chatSelectAll;

  /// No description provided for @chatGroupChatCount.
  ///
  /// In en, this message translates to:
  /// **'Group Chat({count})'**
  String chatGroupChatCount(int count);

  /// No description provided for @chatPrivateChat.
  ///
  /// In en, this message translates to:
  /// **'Private Chat'**
  String get chatPrivateChat;

  /// No description provided for @chatNoMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get chatNoMessages;

  /// No description provided for @chatSendFirstMessage.
  ///
  /// In en, this message translates to:
  /// **'Send the first message to start chatting'**
  String get chatSendFirstMessage;

  /// No description provided for @chatEncryptionNotice.
  ///
  /// In en, this message translates to:
  /// **'This chat is end-to-end encrypted. Only you and the recipient can read the messages.'**
  String get chatEncryptionNotice;

  /// No description provided for @chatMultiForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get chatMultiForward;

  /// No description provided for @chatCollect.
  ///
  /// In en, this message translates to:
  /// **'Collect'**
  String get chatCollect;

  /// No description provided for @chatNoMembers.
  ///
  /// In en, this message translates to:
  /// **'No members'**
  String get chatNoMembers;

  /// No description provided for @chatMemberNotFound.
  ///
  /// In en, this message translates to:
  /// **'Member not found'**
  String get chatMemberNotFound;

  /// No description provided for @chatVoiceFileNotExist.
  ///
  /// In en, this message translates to:
  /// **'Voice file does not exist'**
  String get chatVoiceFileNotExist;

  /// No description provided for @chatVoiceFileEmpty.
  ///
  /// In en, this message translates to:
  /// **'Voice file is empty'**
  String get chatVoiceFileEmpty;

  /// No description provided for @chatSendingVoice.
  ///
  /// In en, this message translates to:
  /// **'Sending voice...'**
  String get chatSendingVoice;

  /// No description provided for @chatSendVoiceFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send voice: {error}'**
  String chatSendVoiceFailed(Object error);

  /// No description provided for @chatMessageForwarded.
  ///
  /// In en, this message translates to:
  /// **'Message forwarded'**
  String get chatMessageForwarded;

  /// No description provided for @chatForwardFailed.
  ///
  /// In en, this message translates to:
  /// **'Forward failed: {error}'**
  String chatForwardFailed(Object error);

  /// No description provided for @chatUnfavorited.
  ///
  /// In en, this message translates to:
  /// **'Unfavorited'**
  String get chatUnfavorited;

  /// No description provided for @chatFavorited.
  ///
  /// In en, this message translates to:
  /// **'Favorited'**
  String get chatFavorited;

  /// No description provided for @chatReactionAdded.
  ///
  /// In en, this message translates to:
  /// **'Reaction added'**
  String get chatReactionAdded;

  /// No description provided for @chatReactionRemoved.
  ///
  /// In en, this message translates to:
  /// **'Reaction removed'**
  String get chatReactionRemoved;

  /// No description provided for @chatFailedMessageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Failed message deleted'**
  String get chatFailedMessageDeleted;

  /// No description provided for @chatDeleteMessages.
  ///
  /// In en, this message translates to:
  /// **'Delete messages'**
  String get chatDeleteMessages;

  /// No description provided for @chatDeleteMessagesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} messages?'**
  String chatDeleteMessagesConfirm(Object count);

  /// No description provided for @chatNoteOtherMessages.
  ///
  /// In en, this message translates to:
  /// **'Note: {count} messages are from others and will only be deleted for you.'**
  String chatNoteOtherMessages(Object count);

  /// No description provided for @chatMyMessagesWillBeRecalled.
  ///
  /// In en, this message translates to:
  /// **'{count} messages from you will be recalled for everyone.'**
  String chatMyMessagesWillBeRecalled(Object count);

  /// No description provided for @chatRecalledCount.
  ///
  /// In en, this message translates to:
  /// **'Recalled {count} messages, {localCount} deleted only for you'**
  String chatRecalledCount(Object count, Object localCount);

  /// No description provided for @chatRecalledMessages.
  ///
  /// In en, this message translates to:
  /// **'Recalled {count} messages'**
  String chatRecalledMessages(Object count);

  /// No description provided for @chatDeletedLocally.
  ///
  /// In en, this message translates to:
  /// **'{count} messages deleted only for you'**
  String chatDeletedLocally(Object count);

  /// No description provided for @chatForwardedCount.
  ///
  /// In en, this message translates to:
  /// **'Forwarded {count} messages'**
  String chatForwardedCount(Object count);

  /// No description provided for @chatForwardComplete.
  ///
  /// In en, this message translates to:
  /// **'Forward complete: {success} succeeded, {failed} failed'**
  String chatForwardComplete(Object failed, Object success);

  /// No description provided for @chatRemindOnlyInGroup.
  ///
  /// In en, this message translates to:
  /// **'Remind feature is only available in group chat'**
  String get chatRemindOnlyInGroup;

  /// No description provided for @chatOnlyTextSearchable.
  ///
  /// In en, this message translates to:
  /// **'Only text messages can be searched'**
  String get chatOnlyTextSearchable;

  /// No description provided for @chatSearchFor.
  ///
  /// In en, this message translates to:
  /// **'Search \"{text}\"'**
  String chatSearchFor(Object text);

  /// No description provided for @chatBaiduSearch.
  ///
  /// In en, this message translates to:
  /// **'Baidu Search'**
  String get chatBaiduSearch;

  /// No description provided for @chatGoogleSearch.
  ///
  /// In en, this message translates to:
  /// **'Google Search'**
  String get chatGoogleSearch;

  /// No description provided for @chatBingSearch.
  ///
  /// In en, this message translates to:
  /// **'Bing Search'**
  String get chatBingSearch;

  /// No description provided for @chatCalling.
  ///
  /// In en, this message translates to:
  /// **'Calling...'**
  String get chatCalling;

  /// No description provided for @chatRinging.
  ///
  /// In en, this message translates to:
  /// **'Ringing...'**
  String get chatRinging;

  /// No description provided for @chatInCall.
  ///
  /// In en, this message translates to:
  /// **'In call'**
  String get chatInCall;

  /// No description provided for @commonFeatureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'{feature} feature in development...'**
  String commonFeatureInDevelopment(Object feature);

  /// No description provided for @chatCollectMessages.
  ///
  /// In en, this message translates to:
  /// **'Collected {count} messages'**
  String chatCollectMessages(Object count);

  /// No description provided for @commonMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String commonMemberCount(int count);

  /// No description provided for @groupDone.
  ///
  /// In en, this message translates to:
  /// **'Done({count})'**
  String groupDone(int count);

  /// No description provided for @profileServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get profileServices;

  /// No description provided for @commonFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get commonFavorites;

  /// No description provided for @profileOrdersAndCards.
  ///
  /// In en, this message translates to:
  /// **'Orders & Cards'**
  String get profileOrdersAndCards;

  /// No description provided for @profileStickers.
  ///
  /// In en, this message translates to:
  /// **'Stickers'**
  String get profileStickers;

  /// No description provided for @profileStatusSetTo.
  ///
  /// In en, this message translates to:
  /// **'Status set to: {status}'**
  String profileStatusSetTo(String status);

  /// No description provided for @profileAvatarUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Avatar upload failed'**
  String get profileAvatarUploadFailed;

  /// No description provided for @profilePersonalProfile.
  ///
  /// In en, this message translates to:
  /// **'Personal Profile'**
  String get profilePersonalProfile;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// No description provided for @profileGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileGender;

  /// No description provided for @profileRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get profileRegion;

  /// No description provided for @commonMyQrCode.
  ///
  /// In en, this message translates to:
  /// **'My QR Code'**
  String get commonMyQrCode;

  /// No description provided for @profilePoke.
  ///
  /// In en, this message translates to:
  /// **'Poke'**
  String get profilePoke;

  /// No description provided for @profileRingtone.
  ///
  /// In en, this message translates to:
  /// **'Ringtone'**
  String get profileRingtone;

  /// No description provided for @profileDefaultRingtone.
  ///
  /// In en, this message translates to:
  /// **'Default Ringtone'**
  String get profileDefaultRingtone;

  /// No description provided for @profileMyAddresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get profileMyAddresses;

  /// No description provided for @profileGenderSetTo.
  ///
  /// In en, this message translates to:
  /// **'Gender set to: {gender}'**
  String profileGenderSetTo(String gender);

  /// No description provided for @profileSelectRegion.
  ///
  /// In en, this message translates to:
  /// **'Select Region'**
  String get profileSelectRegion;

  /// No description provided for @profileSelectCity.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get profileSelectCity;

  /// No description provided for @profileRegionSetTo.
  ///
  /// In en, this message translates to:
  /// **'Region set to: {region}'**
  String profileRegionSetTo(String region);

  /// No description provided for @profileSetPoke.
  ///
  /// In en, this message translates to:
  /// **'Set Poke'**
  String get profileSetPoke;

  /// No description provided for @profileFriendPokedMe.
  ///
  /// In en, this message translates to:
  /// **'Friend poked me'**
  String get profileFriendPokedMe;

  /// No description provided for @profileExample.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get profileExample;

  /// No description provided for @profileOnTheShoulder.
  ///
  /// In en, this message translates to:
  /// **' on the shoulder'**
  String get profileOnTheShoulder;

  /// No description provided for @profilePokeCleared.
  ///
  /// In en, this message translates to:
  /// **'Poke cleared'**
  String get profilePokeCleared;

  /// No description provided for @profilePokeSetTo.
  ///
  /// In en, this message translates to:
  /// **'Poke set to: poked me{suffix}'**
  String profilePokeSetTo(String suffix);

  /// No description provided for @profileEditSignature.
  ///
  /// In en, this message translates to:
  /// **'Edit Signature'**
  String get profileEditSignature;

  /// No description provided for @profileIntroduceYourself.
  ///
  /// In en, this message translates to:
  /// **'A sentence to introduce yourself'**
  String get profileIntroduceYourself;

  /// No description provided for @profileSignatureCleared.
  ///
  /// In en, this message translates to:
  /// **'Signature cleared'**
  String get profileSignatureCleared;

  /// No description provided for @profileSignatureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Signature updated'**
  String get profileSignatureUpdated;

  /// No description provided for @profileScanToAddFriend.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code above to add me as a friend'**
  String get profileScanToAddFriend;

  /// No description provided for @profileRingtoneSetTo.
  ///
  /// In en, this message translates to:
  /// **'Ringtone set to: {ringtone}'**
  String profileRingtoneSetTo(String ringtone);

  /// No description provided for @commonConfirmDissolveGroup.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to dissolve \"{name}\"? This action cannot be undone.'**
  String commonConfirmDissolveGroup(String name);

  /// No description provided for @authEnterValidServerAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid server address'**
  String get authEnterValidServerAddress;

  /// No description provided for @authEnterServerAddressFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter server address first'**
  String get authEnterServerAddressFirst;

  /// No description provided for @authPasskeyRequiresServer.
  ///
  /// In en, this message translates to:
  /// **'Passkey login requires server support'**
  String get authPasskeyRequiresServer;

  /// No description provided for @authLoginAgreement.
  ///
  /// In en, this message translates to:
  /// **'By logging in, you agree to '**
  String get authLoginAgreement;

  /// No description provided for @authPleaseAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'Please read and agree to the Terms of Service and Privacy Policy'**
  String get authPleaseAgreeToTerms;

  /// No description provided for @authRegisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get authRegisterFailed;

  /// No description provided for @commonReenterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get commonReenterPassword;

  /// No description provided for @commonPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get commonPasswordsDoNotMatch;

  /// No description provided for @authInviteCodeBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'Invite Code (Built-in)'**
  String get authInviteCodeBuiltIn;

  /// No description provided for @authInviteCodeBuiltInNote.
  ///
  /// In en, this message translates to:
  /// **'Invite code is built-in, usually no need to modify'**
  String get authInviteCodeBuiltInNote;

  /// No description provided for @authIHaveReadAndAgree.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to '**
  String get authIHaveReadAndAgree;

  /// No description provided for @mainStartGroupChat.
  ///
  /// In en, this message translates to:
  /// **'Start Group Chat'**
  String get mainStartGroupChat;

  /// No description provided for @mainAddFriends.
  ///
  /// In en, this message translates to:
  /// **'Add Friends'**
  String get mainAddFriends;

  /// No description provided for @mainPaymentAndCollection.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get mainPaymentAndCollection;

  /// No description provided for @contactCount.
  ///
  /// In en, this message translates to:
  /// **'{count} contacts'**
  String contactCount(int count);

  /// No description provided for @contactAddToHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Add to home screen'**
  String get contactAddToHomeScreen;

  /// No description provided for @contactRecommendedCardTo.
  ///
  /// In en, this message translates to:
  /// **'Recommended {contact}\'s card to {recipient}'**
  String contactRecommendedCardTo(String contact, String recipient);

  /// No description provided for @contactEnterRemarkName.
  ///
  /// In en, this message translates to:
  /// **'Enter remark name'**
  String get contactEnterRemarkName;

  /// No description provided for @contactRemarkSetTo.
  ///
  /// In en, this message translates to:
  /// **'Remark set to: {remark}'**
  String contactRemarkSetTo(String remark);

  /// No description provided for @contactAcceptedFriendRequest.
  ///
  /// In en, this message translates to:
  /// **'Accepted {name}\'s friend request'**
  String contactAcceptedFriendRequest(String name);

  /// No description provided for @contactRejectedFriendRequest.
  ///
  /// In en, this message translates to:
  /// **'Rejected {name}\'s friend request'**
  String contactRejectedFriendRequest(String name);

  /// No description provided for @commonGroupInvites.
  ///
  /// In en, this message translates to:
  /// **'Group Invites'**
  String get commonGroupInvites;

  /// No description provided for @commonMyGroups.
  ///
  /// In en, this message translates to:
  /// **'My Groups ({count})'**
  String commonMyGroups(int count);

  /// No description provided for @commonInvitedToJoinGroup.
  ///
  /// In en, this message translates to:
  /// **'Invited to join group'**
  String get commonInvitedToJoinGroup;

  /// No description provided for @commonConfirmLeaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave \"{name}\"?'**
  String commonConfirmLeaveGroup(String name);

  /// No description provided for @commonLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get commonLeave;

  /// No description provided for @commonRecallThisMessage.
  ///
  /// In en, this message translates to:
  /// **'Recall this message?'**
  String get commonRecallThisMessage;

  /// No description provided for @commonSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Saved to gallery'**
  String get commonSavedToGallery;

  /// No description provided for @commonFailedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get commonFailedToSave;

  /// No description provided for @chatSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get chatSaving;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @chatSaveToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save to Gallery'**
  String get chatSaveToGallery;

  /// No description provided for @chatFailedToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get chatFailedToLoadImage;

  /// No description provided for @chatVideoRecordingFailed.
  ///
  /// In en, this message translates to:
  /// **'Video recording failed'**
  String get chatVideoRecordingFailed;

  /// No description provided for @profileRedPacket.
  ///
  /// In en, this message translates to:
  /// **'Red Packet'**
  String get profileRedPacket;

  /// No description provided for @commonMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get commonMusic;

  /// No description provided for @commonCoupon.
  ///
  /// In en, this message translates to:
  /// **'Coupon'**
  String get commonCoupon;

  /// No description provided for @commonGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get commonGift;

  /// No description provided for @commonPoll.
  ///
  /// In en, this message translates to:
  /// **'Poll'**
  String get commonPoll;

  /// No description provided for @favoriteText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get favoriteText;

  /// No description provided for @favoriteLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get favoriteLinkLabel;

  /// No description provided for @favoriteNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get favoriteNote;

  /// No description provided for @favoriteMyNotes.
  ///
  /// In en, this message translates to:
  /// **'My Notes'**
  String get favoriteMyNotes;

  /// No description provided for @favoriteToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get favoriteToday;

  /// No description provided for @favoriteDaysAgoText.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String favoriteDaysAgoText(int count);

  /// No description provided for @favoriteDateFormat.
  ///
  /// In en, this message translates to:
  /// **'{month}/{day}'**
  String favoriteDateFormat(int month, int day);

  /// No description provided for @favoriteNoFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoriteNoFavorites;

  /// No description provided for @favoriteLongPressToFavorite.
  ///
  /// In en, this message translates to:
  /// **'Long press message to favorite'**
  String get favoriteLongPressToFavorite;

  /// No description provided for @favoriteNewNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get favoriteNewNote;

  /// No description provided for @favoriteLink.
  ///
  /// In en, this message translates to:
  /// **'Favorite Link'**
  String get favoriteLink;

  /// No description provided for @favoriteEditTags.
  ///
  /// In en, this message translates to:
  /// **'Edit Tags'**
  String get favoriteEditTags;

  /// No description provided for @favoriteDeleteFavorite.
  ///
  /// In en, this message translates to:
  /// **'Delete Favorite'**
  String get favoriteDeleteFavorite;

  /// No description provided for @favoriteDeleteFavoriteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this favorite?'**
  String get favoriteDeleteFavoriteConfirm;

  /// No description provided for @favoriteNoSearchResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get favoriteNoSearchResultsFound;

  /// No description provided for @commonSendRedPacket.
  ///
  /// In en, this message translates to:
  /// **'Send Red Packet'**
  String get commonSendRedPacket;

  /// No description provided for @transferAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get transferAmount;

  /// No description provided for @commonRedPacketCover.
  ///
  /// In en, this message translates to:
  /// **'Red Packet Cover'**
  String get commonRedPacketCover;

  /// No description provided for @commonRedPacketType.
  ///
  /// In en, this message translates to:
  /// **'Red Packet Type'**
  String get commonRedPacketType;

  /// No description provided for @commonNormalRedPacket.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get commonNormalRedPacket;

  /// No description provided for @commonLuckyRedPacket.
  ///
  /// In en, this message translates to:
  /// **'Lucky'**
  String get commonLuckyRedPacket;

  /// No description provided for @commonRedPacketCount.
  ///
  /// In en, this message translates to:
  /// **'Red Packet Count'**
  String get commonRedPacketCount;

  /// No description provided for @commonPieces.
  ///
  /// In en, this message translates to:
  /// **'pieces'**
  String get commonPieces;

  /// No description provided for @commonPutMoneyInRedPacket.
  ///
  /// In en, this message translates to:
  /// **'Put money in red packet'**
  String get commonPutMoneyInRedPacket;

  /// No description provided for @commonRedPacketRefundNotice.
  ///
  /// In en, this message translates to:
  /// **'Unclaimed red packets will be refunded after 24 hours'**
  String get commonRedPacketRefundNotice;

  /// No description provided for @commonOpenRedPacket.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get commonOpenRedPacket;

  /// No description provided for @commonRedPacketAllClaimed.
  ///
  /// In en, this message translates to:
  /// **'Red packet all claimed'**
  String get commonRedPacketAllClaimed;

  /// No description provided for @commonRedPacketExpired.
  ///
  /// In en, this message translates to:
  /// **'Red packet expired'**
  String get commonRedPacketExpired;

  /// No description provided for @commonAddTransferNote.
  ///
  /// In en, this message translates to:
  /// **'Add transfer note'**
  String get commonAddTransferNote;

  /// No description provided for @commonYuan.
  ///
  /// In en, this message translates to:
  /// **'CNY'**
  String get commonYuan;

  /// No description provided for @commonReplyWithEmoji.
  ///
  /// In en, this message translates to:
  /// **'Reply with this emoji'**
  String get commonReplyWithEmoji;

  /// No description provided for @contactEditRemark.
  ///
  /// In en, this message translates to:
  /// **'Edit Remark'**
  String get contactEditRemark;

  /// No description provided for @contactSetPermissions.
  ///
  /// In en, this message translates to:
  /// **'Set Permissions'**
  String get contactSetPermissions;

  /// No description provided for @profileAddToBlacklist.
  ///
  /// In en, this message translates to:
  /// **'Add to Blacklist'**
  String get profileAddToBlacklist;

  /// No description provided for @contactDeleteContact.
  ///
  /// In en, this message translates to:
  /// **'Delete Contact'**
  String get contactDeleteContact;

  /// No description provided for @contactDeleteContactConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String contactDeleteContactConfirm(String name);

  /// No description provided for @transferTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferTitle;

  /// No description provided for @transferReceiverAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient Address'**
  String get transferReceiverAddressLabel;

  /// No description provided for @transferSelectTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Token'**
  String get transferSelectTokenLabel;

  /// No description provided for @transferAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Transfer Amount'**
  String get transferAmountLabel;

  /// No description provided for @transferMemoLabel.
  ///
  /// In en, this message translates to:
  /// **'Memo (optional)'**
  String get transferMemoLabel;

  /// No description provided for @transferAddMemoHint.
  ///
  /// In en, this message translates to:
  /// **'Add a memo'**
  String get transferAddMemoHint;

  /// No description provided for @transferSendPaymentRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Payment Request'**
  String get transferSendPaymentRequest;

  /// No description provided for @transferQrCodeGenerateFailed.
  ///
  /// In en, this message translates to:
  /// **'QR code generation failed'**
  String get transferQrCodeGenerateFailed;

  /// No description provided for @transferScanQrToPayMe.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code to pay me'**
  String get transferScanQrToPayMe;

  /// No description provided for @transferMyWalletAddress.
  ///
  /// In en, this message translates to:
  /// **'My Wallet Address'**
  String get transferMyWalletAddress;

  /// No description provided for @transferCreatePaymentRequest.
  ///
  /// In en, this message translates to:
  /// **'Create Payment Request'**
  String get transferCreatePaymentRequest;

  /// No description provided for @profileN42IdLabel.
  ///
  /// In en, this message translates to:
  /// **'N42 ID: {id}'**
  String profileN42IdLabel(String id);

  /// No description provided for @commonRedPacketDefaultGreeting.
  ///
  /// In en, this message translates to:
  /// **'Best wishes'**
  String get commonRedPacketDefaultGreeting;

  /// No description provided for @commonSenderRedPacket.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Red Packet'**
  String commonSenderRedPacket(String name);

  /// No description provided for @transferEnterValidAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid address'**
  String get transferEnterValidAddress;

  /// No description provided for @transferPleaseSelectToken.
  ///
  /// In en, this message translates to:
  /// **'Please select a token'**
  String get transferPleaseSelectToken;

  /// No description provided for @commonReceivedTransfer.
  ///
  /// In en, this message translates to:
  /// **'Received Transfer'**
  String get commonReceivedTransfer;

  /// No description provided for @commonSenderSentRedPacket.
  ///
  /// In en, this message translates to:
  /// **'{name} sent a red packet'**
  String commonSenderSentRedPacket(String name);

  /// No description provided for @commonSavedToBalance.
  ///
  /// In en, this message translates to:
  /// **'Saved to balance, can transfer directly'**
  String get commonSavedToBalance;

  /// No description provided for @commonRedPacketExpiredOrEmpty.
  ///
  /// In en, this message translates to:
  /// **'Red packet expired/all claimed'**
  String get commonRedPacketExpiredOrEmpty;

  /// No description provided for @transferScanFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Scan feature coming soon...'**
  String get transferScanFeatureComingSoon;

  /// No description provided for @contactSetAsStarred.
  ///
  /// In en, this message translates to:
  /// **'Set as Starred'**
  String get contactSetAsStarred;

  /// No description provided for @contactAddToBlocklist.
  ///
  /// In en, this message translates to:
  /// **'Add to Blocklist'**
  String get contactAddToBlocklist;

  /// No description provided for @commonClaimedYour.
  ///
  /// In en, this message translates to:
  /// **' claimed your '**
  String get commonClaimedYour;

  /// No description provided for @commonClaimedText.
  ///
  /// In en, this message translates to:
  /// **' claimed '**
  String get commonClaimedText;

  /// No description provided for @commonUserTyping.
  ///
  /// In en, this message translates to:
  /// **'{name} is typing...'**
  String commonUserTyping(String name);

  /// No description provided for @commonTyping.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get commonTyping;

  /// No description provided for @commonWaitingToReceive.
  ///
  /// In en, this message translates to:
  /// **'Waiting to receive'**
  String get commonWaitingToReceive;

  /// No description provided for @commonTapToClaim.
  ///
  /// In en, this message translates to:
  /// **'Tap to claim'**
  String get commonTapToClaim;

  /// No description provided for @commonHasBeenReceived.
  ///
  /// In en, this message translates to:
  /// **'Has been received'**
  String get commonHasBeenReceived;

  /// No description provided for @commonGetLucky.
  ///
  /// In en, this message translates to:
  /// **'Get lucky'**
  String get commonGetLucky;

  /// No description provided for @qrcodeCameraStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Camera failed to start'**
  String get qrcodeCameraStartFailed;

  /// No description provided for @qrcodeUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get qrcodeUnknownError;

  /// No description provided for @qrcodePlaceQrCodeInFrame.
  ///
  /// In en, this message translates to:
  /// **'Place QR code within the frame to scan'**
  String get qrcodePlaceQrCodeInFrame;

  /// No description provided for @qrcodeCloseManualInput.
  ///
  /// In en, this message translates to:
  /// **'Close Manual Input'**
  String get qrcodeCloseManualInput;

  /// No description provided for @qrcodeManualInputUserId.
  ///
  /// In en, this message translates to:
  /// **'Manual Input User ID'**
  String get qrcodeManualInputUserId;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @profileSetStatus.
  ///
  /// In en, this message translates to:
  /// **'Set Status'**
  String get profileSetStatus;

  /// No description provided for @profileVisibleToFriends24h.
  ///
  /// In en, this message translates to:
  /// **'Visible to friends for 24 hours'**
  String get profileVisibleToFriends24h;

  /// No description provided for @profileWriteStatus.
  ///
  /// In en, this message translates to:
  /// **'Write Status'**
  String get profileWriteStatus;

  /// No description provided for @profileEnterYourStatus.
  ///
  /// In en, this message translates to:
  /// **'Enter your status...'**
  String get profileEnterYourStatus;

  /// No description provided for @profileOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get profileOk;

  /// No description provided for @qrcodeCameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan QR code'**
  String get qrcodeCameraPermissionRequired;

  /// No description provided for @qrcodeCameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission was permanently denied. Please enable it in system settings.'**
  String get qrcodeCameraPermissionDenied;

  /// No description provided for @qrcodePermissionCheckError.
  ///
  /// In en, this message translates to:
  /// **'Error checking permission: {error}'**
  String qrcodePermissionCheckError(String error);

  /// No description provided for @qrcodeInvalidQrCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code'**
  String get qrcodeInvalidQrCode;

  /// No description provided for @qrcodeCannotAddFriend.
  ///
  /// In en, this message translates to:
  /// **'Cannot add friend: {error}'**
  String qrcodeCannotAddFriend(String error);

  /// No description provided for @qrcodeScanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get qrcodeScanQrCode;

  /// No description provided for @qrcodeCheckingCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Checking camera permission...'**
  String get qrcodeCheckingCameraPermission;

  /// No description provided for @qrcodeNeedCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission Required'**
  String get qrcodeNeedCameraPermission;

  /// No description provided for @qrcodeRetryPermission.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get qrcodeRetryPermission;

  /// No description provided for @qrcodeOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get qrcodeOpenSettings;

  /// No description provided for @groupInviteMembers.
  ///
  /// In en, this message translates to:
  /// **'Invite Members'**
  String get groupInviteMembers;

  /// No description provided for @groupInviteCount.
  ///
  /// In en, this message translates to:
  /// **'Invite({count})'**
  String groupInviteCount(int count);

  /// No description provided for @profileNoShippingAddress.
  ///
  /// In en, this message translates to:
  /// **'No shipping address'**
  String get profileNoShippingAddress;

  /// No description provided for @profileDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get profileDefaultLabel;

  /// No description provided for @profileNoInvoice.
  ///
  /// In en, this message translates to:
  /// **'No invoice'**
  String get profileNoInvoice;

  /// No description provided for @profileCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get profileCompany;

  /// No description provided for @profileTaxNumber.
  ///
  /// In en, this message translates to:
  /// **'Tax Number'**
  String get profileTaxNumber;

  /// No description provided for @profileConfirmDeleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this address?'**
  String get profileConfirmDeleteAddress;

  /// No description provided for @profileConfirmDeleteInvoice.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this invoice?'**
  String get profileConfirmDeleteInvoice;

  /// No description provided for @commonGroupOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get commonGroupOwner;

  /// No description provided for @commonGroupAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get commonGroupAdmin;

  /// No description provided for @groupSearchMembers.
  ///
  /// In en, this message translates to:
  /// **'Search members'**
  String get groupSearchMembers;

  /// No description provided for @groupTotalMembers.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String groupTotalMembers(int count);

  /// No description provided for @chatRemoveFromGroup.
  ///
  /// In en, this message translates to:
  /// **'Remove from Group'**
  String get chatRemoveFromGroup;

  /// No description provided for @groupConfirmRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"{name}\" from the group?'**
  String groupConfirmRemoveMember(String name);

  /// No description provided for @chatUnknownSong.
  ///
  /// In en, this message translates to:
  /// **'Unknown Song'**
  String get chatUnknownSong;

  /// No description provided for @chatUnknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown Artist'**
  String get chatUnknownArtist;

  /// No description provided for @chatUnknownContact.
  ///
  /// In en, this message translates to:
  /// **'Unknown Contact'**
  String get chatUnknownContact;

  /// No description provided for @chatPersonalCard.
  ///
  /// In en, this message translates to:
  /// **'Contact Card'**
  String get chatPersonalCard;

  /// No description provided for @chatSingleChoice.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get chatSingleChoice;

  /// No description provided for @chatMultiChoice.
  ///
  /// In en, this message translates to:
  /// **'Multi'**
  String get chatMultiChoice;

  /// No description provided for @chatEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get chatEnded;

  /// No description provided for @chatEndPollButton.
  ///
  /// In en, this message translates to:
  /// **'End Poll'**
  String get chatEndPollButton;

  /// No description provided for @chatPollHint.
  ///
  /// In en, this message translates to:
  /// **'Poll will be displayed in chat. Group members can vote.'**
  String get chatPollHint;

  /// No description provided for @chatSearchSongOrArtist.
  ///
  /// In en, this message translates to:
  /// **'Search song or artist'**
  String get chatSearchSongOrArtist;

  /// No description provided for @chatNoSongsFound.
  ///
  /// In en, this message translates to:
  /// **'No songs found'**
  String get chatNoSongsFound;

  /// No description provided for @chatSongNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Song Name (Optional)'**
  String get chatSongNameOptional;

  /// No description provided for @chatEnterSongName.
  ///
  /// In en, this message translates to:
  /// **'Enter song name'**
  String get chatEnterSongName;

  /// No description provided for @chatArtistNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Artist Name (Optional)'**
  String get chatArtistNameOptional;

  /// No description provided for @chatEnterArtistName.
  ///
  /// In en, this message translates to:
  /// **'Enter artist name'**
  String get chatEnterArtistName;

  /// No description provided for @chatRealTimeLocationSharing.
  ///
  /// In en, this message translates to:
  /// **'Real-time location sharing in development...'**
  String get chatRealTimeLocationSharing;

  /// No description provided for @profileVoiceCallFeatureInDev.
  ///
  /// In en, this message translates to:
  /// **'Voice call feature in development...'**
  String get profileVoiceCallFeatureInDev;

  /// No description provided for @profileReportFeatureInDev.
  ///
  /// In en, this message translates to:
  /// **'Report feature in development...'**
  String get profileReportFeatureInDev;

  /// No description provided for @profileShareFeatureInDev.
  ///
  /// In en, this message translates to:
  /// **'Share feature in development...'**
  String get profileShareFeatureInDev;

  /// No description provided for @profileQrCodeFeatureInDev.
  ///
  /// In en, this message translates to:
  /// **'QR code feature in development...'**
  String get profileQrCodeFeatureInDev;

  /// No description provided for @qrcodeScanQrToAddMe.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code above to add me as a friend'**
  String get qrcodeScanQrToAddMe;

  /// No description provided for @qrcodeSaveToAlbum.
  ///
  /// In en, this message translates to:
  /// **'Save to Album'**
  String get qrcodeSaveToAlbum;

  /// No description provided for @qrcodeChangeStyle.
  ///
  /// In en, this message translates to:
  /// **'Change Style'**
  String get qrcodeChangeStyle;

  /// No description provided for @qrcodeCopyId.
  ///
  /// In en, this message translates to:
  /// **'Copy ID'**
  String get qrcodeCopyId;

  /// No description provided for @qrcodeIdCopied.
  ///
  /// In en, this message translates to:
  /// **'ID copied'**
  String get qrcodeIdCopied;

  /// No description provided for @qrcodeMoreStylesFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'More styles coming soon'**
  String get qrcodeMoreStylesFeatureComingSoon;

  /// No description provided for @profileBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get profileBio;

  /// No description provided for @profileHomeServer.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get profileHomeServer;

  /// No description provided for @profileShareContactCard.
  ///
  /// In en, this message translates to:
  /// **'Share Contact Card'**
  String get profileShareContactCard;

  /// No description provided for @profileRemoveFromBlacklist.
  ///
  /// In en, this message translates to:
  /// **'Remove from Blacklist'**
  String get profileRemoveFromBlacklist;

  /// No description provided for @profileConfirmAddBlacklist.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to add this user to blacklist? You will not receive messages from them.'**
  String get profileConfirmAddBlacklist;

  /// No description provided for @profileConfirmRemoveBlacklist.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this user from blacklist?'**
  String get profileConfirmRemoveBlacklist;

  /// No description provided for @profileRemarkSaved.
  ///
  /// In en, this message translates to:
  /// **'Remark saved'**
  String get profileRemarkSaved;

  /// No description provided for @profileRemarkCleared.
  ///
  /// In en, this message translates to:
  /// **'Remark cleared'**
  String get profileRemarkCleared;

  /// No description provided for @transferReceive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get transferReceive;

  /// No description provided for @transferPleaseConnectWallet.
  ///
  /// In en, this message translates to:
  /// **'Please connect your wallet first'**
  String get transferPleaseConnectWallet;

  /// No description provided for @transferSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get transferSendRequest;

  /// No description provided for @transferPleaseEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get transferPleaseEnterValidAmount;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search contacts, groups, messages'**
  String get searchPlaceholder;

  /// No description provided for @searchEnterKeywordToSearch.
  ///
  /// In en, this message translates to:
  /// **'Enter keyword to start searching'**
  String get searchEnterKeywordToSearch;

  /// No description provided for @searchClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClearHistory;

  /// No description provided for @searchNoResultsForQuery.
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\"'**
  String searchNoResultsForQuery(String query);

  /// No description provided for @searchAllResults.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchAllResults;

  /// No description provided for @searchInChat.
  ///
  /// In en, this message translates to:
  /// **'Search in chat'**
  String get searchInChat;

  /// No description provided for @searchContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get searchContactLabel;

  /// No description provided for @searchGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get searchGroupLabel;

  /// No description provided for @searchConversationLabel.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get searchConversationLabel;

  /// No description provided for @searchMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get searchMessageLabel;

  /// No description provided for @settingsSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurityTitle;

  /// No description provided for @settingsKeyBackup.
  ///
  /// In en, this message translates to:
  /// **'Key Backup'**
  String get settingsKeyBackup;

  /// No description provided for @settingsBackupEncryptionKeys.
  ///
  /// In en, this message translates to:
  /// **'Backup Encryption Keys'**
  String get settingsBackupEncryptionKeys;

  /// No description provided for @settingsKeysBackedUp.
  ///
  /// In en, this message translates to:
  /// **'{count} keys backed up'**
  String settingsKeysBackedUp(int count);

  /// No description provided for @settingsBackupNotSet.
  ///
  /// In en, this message translates to:
  /// **'Backup not set'**
  String get settingsBackupNotSet;

  /// No description provided for @settingsRestoreKeys.
  ///
  /// In en, this message translates to:
  /// **'Restore Keys'**
  String get settingsRestoreKeys;

  /// No description provided for @settingsRestoreKeysFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore encryption keys from backup'**
  String get settingsRestoreKeysFromBackup;

  /// No description provided for @settingsExportKeys.
  ///
  /// In en, this message translates to:
  /// **'Export Keys'**
  String get settingsExportKeys;

  /// No description provided for @settingsExportKeysToFile.
  ///
  /// In en, this message translates to:
  /// **'Export keys to file'**
  String get settingsExportKeysToFile;

  /// No description provided for @settingsLoggedInDevices.
  ///
  /// In en, this message translates to:
  /// **'Logged In Devices'**
  String get settingsLoggedInDevices;

  /// No description provided for @settingsNoOtherDevices.
  ///
  /// In en, this message translates to:
  /// **'No other devices'**
  String get settingsNoOtherDevices;

  /// No description provided for @settingsVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get settingsVerified;

  /// No description provided for @settingsUnverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get settingsUnverified;

  /// No description provided for @settingsAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get settingsAdvanced;

  /// No description provided for @settingsCrossSigning.
  ///
  /// In en, this message translates to:
  /// **'Cross-Signing'**
  String get settingsCrossSigning;

  /// No description provided for @settingsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get settingsEnabled;

  /// No description provided for @settingsNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Not enabled'**
  String get settingsNotEnabled;

  /// No description provided for @settingsResetEncryption.
  ///
  /// In en, this message translates to:
  /// **'Reset Encryption'**
  String get settingsResetEncryption;

  /// No description provided for @settingsDeleteAllEncryptionKeys.
  ///
  /// In en, this message translates to:
  /// **'Delete all encryption keys'**
  String get settingsDeleteAllEncryptionKeys;

  /// No description provided for @settingsEncryptionNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Encryption not supported'**
  String get settingsEncryptionNotSupported;

  /// No description provided for @settingsNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'Not initialized'**
  String get settingsNotInitialized;

  /// No description provided for @settingsBackupKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup Keys'**
  String get settingsBackupKeyTitle;

  /// No description provided for @settingsBackupKeyMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a new key backup? This will help you restore encrypted messages on a new device.'**
  String get settingsBackupKeyMessage;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingsBackup;

  /// No description provided for @settingsRestoreKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Keys'**
  String get settingsRestoreKeyTitle;

  /// No description provided for @settingsRestoreKeyMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your recovery password or recovery key to restore encrypted messages.'**
  String get settingsRestoreKeyMessage;

  /// No description provided for @settingsRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get settingsRestore;

  /// No description provided for @settingsExportKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Keys'**
  String get settingsExportKeyTitle;

  /// No description provided for @settingsExportKeyMessage.
  ///
  /// In en, this message translates to:
  /// **'The exported key file contains all your encryption keys. Please keep it safe.'**
  String get settingsExportKeyMessage;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get settingsExport;

  /// No description provided for @settingsDeviceIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Device ID: {deviceId}'**
  String settingsDeviceIdLabel(String deviceId);

  /// No description provided for @settingsDeviceStatusVerified.
  ///
  /// In en, this message translates to:
  /// **'Status: Verified'**
  String get settingsDeviceStatusVerified;

  /// No description provided for @settingsDeviceStatusUnverified.
  ///
  /// In en, this message translates to:
  /// **'Status: Unverified'**
  String get settingsDeviceStatusUnverified;

  /// No description provided for @settingsLastActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Last active: {lastSeen}'**
  String settingsLastActiveLabel(String lastSeen);

  /// No description provided for @settingsVerifyThisDevice.
  ///
  /// In en, this message translates to:
  /// **'Verify this device'**
  String get settingsVerifyThisDevice;

  /// No description provided for @settingsCrossSigningAlreadyEnabled.
  ///
  /// In en, this message translates to:
  /// **'Cross-signing is already enabled'**
  String get settingsCrossSigningAlreadyEnabled;

  /// No description provided for @settingsCrossSigningSetupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cross-signing setup successful'**
  String get settingsCrossSigningSetupSuccess;

  /// No description provided for @settingsResetEncryptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Encryption'**
  String get settingsResetEncryptionTitle;

  /// No description provided for @settingsResetEncryptionWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: This will delete all your encryption keys. You will not be able to decrypt previous encrypted messages. This action cannot be undone.'**
  String get settingsResetEncryptionWarning;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsReset;

  /// No description provided for @settingsBackupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Keys backed up successfully'**
  String get settingsBackupSuccess;

  /// No description provided for @settingsBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get settingsBackupFailed;

  /// No description provided for @settingsRecoveryKey.
  ///
  /// In en, this message translates to:
  /// **'Recovery Key'**
  String get settingsRecoveryKey;

  /// No description provided for @settingsRecoveryKeySaveWarning.
  ///
  /// In en, this message translates to:
  /// **'Please save this recovery key in a safe place. You will need it to restore your encrypted messages on a new device.'**
  String get settingsRecoveryKeySaveWarning;

  /// No description provided for @settingsRecoveryKeySaved.
  ///
  /// In en, this message translates to:
  /// **'I have saved it'**
  String get settingsRecoveryKeySaved;

  /// No description provided for @settingsRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Keys restored successfully'**
  String get settingsRestoreSuccess;

  /// No description provided for @settingsRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get settingsRestoreFailed;

  /// No description provided for @settingsPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get settingsPassword;

  /// No description provided for @settingsEnterRecoveryKey.
  ///
  /// In en, this message translates to:
  /// **'Enter recovery key'**
  String get settingsEnterRecoveryKey;

  /// No description provided for @settingsEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get settingsEnterPassword;

  /// No description provided for @settingsExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Keys exported to server backup successfully'**
  String get settingsExportSuccess;

  /// No description provided for @settingsExportNeedBackupFirst.
  ///
  /// In en, this message translates to:
  /// **'Please create a key backup first'**
  String get settingsExportNeedBackupFirst;

  /// No description provided for @settingsExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get settingsExportFailed;

  /// No description provided for @settingsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Encryption reset successful'**
  String get settingsResetSuccess;

  /// No description provided for @settingsResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Reset failed'**
  String get settingsResetFailed;

  /// No description provided for @callLeaveMeetingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave the meeting?'**
  String get callLeaveMeetingConfirm;

  /// No description provided for @chatPokedSomeone.
  ///
  /// In en, this message translates to:
  /// **'poked {name}{suffix}'**
  String chatPokedSomeone(String name, String suffix);

  /// No description provided for @chatNoContactsToAdd.
  ///
  /// In en, this message translates to:
  /// **'No contacts available to add'**
  String get chatNoContactsToAdd;

  /// No description provided for @chatAddMembers.
  ///
  /// In en, this message translates to:
  /// **'Add Members'**
  String get chatAddMembers;

  /// No description provided for @chatInvitedMembers.
  ///
  /// In en, this message translates to:
  /// **'Invited {count} members'**
  String chatInvitedMembers(int count);

  /// No description provided for @chatInviteFailed.
  ///
  /// In en, this message translates to:
  /// **'Invite failed: {error}'**
  String chatInviteFailed(String error);

  /// No description provided for @chatMemberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Member removed'**
  String get chatMemberRemoved;

  /// No description provided for @chatRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Remove failed: {error}'**
  String chatRemoveFailed(String error);

  /// No description provided for @chatRealTimeLocationShareMessage.
  ///
  /// In en, this message translates to:
  /// **'After sharing, the other party can see your real-time location for 1 hour.'**
  String get chatRealTimeLocationShareMessage;

  /// No description provided for @chatStartSharing.
  ///
  /// In en, this message translates to:
  /// **'Start Sharing'**
  String get chatStartSharing;

  /// No description provided for @chatLocationServiceNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Location service is not enabled'**
  String get chatLocationServiceNotEnabled;

  /// No description provided for @chatEnableLocationService.
  ///
  /// In en, this message translates to:
  /// **'Please enable location service to use this feature'**
  String get chatEnableLocationService;

  /// No description provided for @chatGoToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get chatGoToSettings;

  /// No description provided for @chatLocationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required for this feature'**
  String get chatLocationPermissionRequired;

  /// No description provided for @chatLocationPermissionDeniedPermanent.
  ///
  /// In en, this message translates to:
  /// **'Location permission has been permanently denied. Please enable it in settings.'**
  String get chatLocationPermissionDeniedPermanent;

  /// No description provided for @chatLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get chatLocationPermissionDenied;

  /// No description provided for @chatGettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting location...'**
  String get chatGettingLocation;

  /// No description provided for @chatGetLocationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get location: {error}'**
  String chatGetLocationFailed(String error);

  /// No description provided for @chatMapPreview.
  ///
  /// In en, this message translates to:
  /// **'Map Preview'**
  String get chatMapPreview;

  /// No description provided for @chatSearchLocation.
  ///
  /// In en, this message translates to:
  /// **'Search location'**
  String get chatSearchLocation;

  /// No description provided for @chatRedPacketSent.
  ///
  /// In en, this message translates to:
  /// **'Sent {amount} {token} red packet'**
  String chatRedPacketSent(String amount, String token);

  /// No description provided for @chatTransferDefault.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get chatTransferDefault;

  /// No description provided for @chatTransferSent.
  ///
  /// In en, this message translates to:
  /// **'Sent {amount} {token} transfer'**
  String chatTransferSent(String amount, String token);

  /// No description provided for @chatPickFileFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick file: {error}'**
  String chatPickFileFailed(String error);

  /// No description provided for @chatFileSizeLimit.
  ///
  /// In en, this message translates to:
  /// **'File size cannot exceed 50MB'**
  String get chatFileSizeLimit;

  /// No description provided for @chatFileSending.
  ///
  /// In en, this message translates to:
  /// **'Sending file: {filename}'**
  String chatFileSending(String filename);

  /// No description provided for @chatSendFileFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send file: {error}'**
  String chatSendFileFailed(String error);

  /// No description provided for @chatContactCardSent.
  ///
  /// In en, this message translates to:
  /// **'Sent {name}\'s contact card'**
  String chatContactCardSent(String name);

  /// No description provided for @chatFavoritesFeature.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get chatFavoritesFeature;

  /// No description provided for @chatCouponsFeature.
  ///
  /// In en, this message translates to:
  /// **'Coupons'**
  String get chatCouponsFeature;

  /// No description provided for @chatGiftFeature.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get chatGiftFeature;

  /// No description provided for @chatSharedMusic.
  ///
  /// In en, this message translates to:
  /// **'Shared {name}'**
  String chatSharedMusic(String name);

  /// No description provided for @chatEndPollTitle.
  ///
  /// In en, this message translates to:
  /// **'End Poll'**
  String get chatEndPollTitle;

  /// No description provided for @chatEndPollConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to end this poll? Voting will be closed after ending.'**
  String get chatEndPollConfirmMessage;

  /// No description provided for @chatPollEndedMessage.
  ///
  /// In en, this message translates to:
  /// **'Poll ended'**
  String get chatPollEndedMessage;

  /// No description provided for @chatConnectingCall.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get chatConnectingCall;

  /// No description provided for @chatMuteCall.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get chatMuteCall;

  /// No description provided for @chatSpeakerOff.
  ///
  /// In en, this message translates to:
  /// **'Speaker Off'**
  String get chatSpeakerOff;

  /// No description provided for @chatSpeakerOn.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get chatSpeakerOn;

  /// No description provided for @chatCameraOn.
  ///
  /// In en, this message translates to:
  /// **'Camera On'**
  String get chatCameraOn;

  /// No description provided for @chatCameraOff.
  ///
  /// In en, this message translates to:
  /// **'Camera Off'**
  String get chatCameraOff;

  /// No description provided for @chatHangUp.
  ///
  /// In en, this message translates to:
  /// **'Hang Up'**
  String get chatHangUp;

  /// No description provided for @chatSelectForwardTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Forward Target'**
  String get chatSelectForwardTargetTitle;

  /// No description provided for @chatNoForwardableChat.
  ///
  /// In en, this message translates to:
  /// **'No chats available for forwarding'**
  String get chatNoForwardableChat;

  /// No description provided for @chatNoMatchingChat.
  ///
  /// In en, this message translates to:
  /// **'No matching chats found'**
  String get chatNoMatchingChat;

  /// No description provided for @chatLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get chatLocationTitle;

  /// No description provided for @chatSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSendButton;

  /// No description provided for @chatRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get chatRetryButton;

  /// No description provided for @chatSearchContactHint.
  ///
  /// In en, this message translates to:
  /// **'Search contacts'**
  String get chatSearchContactHint;

  /// No description provided for @chatShareMusic.
  ///
  /// In en, this message translates to:
  /// **'Share Music'**
  String get chatShareMusic;

  /// No description provided for @chatRecentPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get chatRecentPlayed;

  /// No description provided for @chatMyFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get chatMyFavorites;

  /// No description provided for @chatNetworkLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get chatNetworkLink;

  /// No description provided for @chatLocalFile.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get chatLocalFile;

  /// No description provided for @chatPasteMusicLink.
  ///
  /// In en, this message translates to:
  /// **'Paste music link'**
  String get chatPasteMusicLink;

  /// No description provided for @chatShareMusicButton.
  ///
  /// In en, this message translates to:
  /// **'Share Music'**
  String get chatShareMusicButton;

  /// No description provided for @chatSelectLocalAudio.
  ///
  /// In en, this message translates to:
  /// **'Select Local Audio File'**
  String get chatSelectLocalAudio;

  /// No description provided for @chatSupportedAudioFormats.
  ///
  /// In en, this message translates to:
  /// **'Supports MP3, M4A, WAV, FLAC, etc.'**
  String get chatSupportedAudioFormats;

  /// No description provided for @chatSelectFileButton.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get chatSelectFileButton;

  /// No description provided for @chatPleaseEnterMusicLink.
  ///
  /// In en, this message translates to:
  /// **'Please enter music link'**
  String get chatPleaseEnterMusicLink;

  /// No description provided for @chatPleaseEnterValidLink.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL'**
  String get chatPleaseEnterValidLink;

  /// No description provided for @chatSharedSong.
  ///
  /// In en, this message translates to:
  /// **'Shared Song'**
  String get chatSharedSong;

  /// No description provided for @chatSelectMember.
  ///
  /// In en, this message translates to:
  /// **'Select Member'**
  String get chatSelectMember;

  /// No description provided for @chatSearchMemberHint.
  ///
  /// In en, this message translates to:
  /// **'Search members'**
  String get chatSearchMemberHint;

  /// No description provided for @chatNoMatchingMembers.
  ///
  /// In en, this message translates to:
  /// **'No matching members found'**
  String get chatNoMatchingMembers;

  /// No description provided for @commonUnknownMember.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get commonUnknownMember;

  /// No description provided for @chatSelectedMessagesCount.
  ///
  /// In en, this message translates to:
  /// **'Selected {count} messages'**
  String chatSelectedMessagesCount(int count);

  /// No description provided for @chatSearchContactsOrGroups.
  ///
  /// In en, this message translates to:
  /// **'Search contacts or groups'**
  String get chatSearchContactsOrGroups;

  /// No description provided for @chatVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get chatVideoTitle;

  /// No description provided for @chatLoadingText.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get chatLoadingText;

  /// No description provided for @chatVideoLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Video load failed'**
  String get chatVideoLoadFailed;

  /// No description provided for @chatPlayerInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Player initialization failed'**
  String get chatPlayerInitFailed;

  /// No description provided for @chatCreatePollTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Poll'**
  String get chatCreatePollTitle;

  /// No description provided for @chatSubmitPoll.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get chatSubmitPoll;

  /// No description provided for @chatPollQuestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Poll Question'**
  String get chatPollQuestionLabel;

  /// No description provided for @chatEnterPollQuestionHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter poll question'**
  String get chatEnterPollQuestionHint;

  /// No description provided for @chatPollOptionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Poll Options'**
  String get chatPollOptionsLabel;

  /// No description provided for @chatOptionHintWithIndex.
  ///
  /// In en, this message translates to:
  /// **'Option {index}'**
  String chatOptionHintWithIndex(int index);

  /// No description provided for @chatAddOptionButton.
  ///
  /// In en, this message translates to:
  /// **'Add Option'**
  String get chatAddOptionButton;

  /// No description provided for @chatPollSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Poll Settings'**
  String get chatPollSettingsLabel;

  /// No description provided for @chatSelectionType.
  ///
  /// In en, this message translates to:
  /// **'Selection Type'**
  String get chatSelectionType;

  /// No description provided for @chatSingleChoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get chatSingleChoiceLabel;

  /// No description provided for @chatMultiChoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Multi'**
  String get chatMultiChoiceLabel;

  /// No description provided for @chatAnonymousPollSwitch.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Poll'**
  String get chatAnonymousPollSwitch;

  /// No description provided for @chatPleaseEnterQuestion.
  ///
  /// In en, this message translates to:
  /// **'Please enter poll question'**
  String get chatPleaseEnterQuestion;

  /// No description provided for @chatAtLeastTwoOptions.
  ///
  /// In en, this message translates to:
  /// **'At least 2 options required'**
  String get chatAtLeastTwoOptions;

  /// No description provided for @chatConfirmWithCount.
  ///
  /// In en, this message translates to:
  /// **'Confirm ({count})'**
  String chatConfirmWithCount(int count);

  /// No description provided for @authEmailVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get authEmailVerificationTitle;

  /// No description provided for @authEnterValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get authEnterValidEmailAddress;

  /// No description provided for @authVerificationCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to {email}'**
  String authVerificationCodeSentTo(String email);

  /// No description provided for @authSendCodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send code: {error}'**
  String authSendCodeFailed(String error);

  /// No description provided for @authVerificationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification successful'**
  String get authVerificationSuccess;

  /// No description provided for @authVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get authVerificationFailed;

  /// No description provided for @authVerificationCodeError.
  ///
  /// In en, this message translates to:
  /// **'Verification code error: {error}'**
  String authVerificationCodeError(String error);

  /// No description provided for @commonEnterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get commonEnterVerificationCode;

  /// No description provided for @authEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get authEnterYourEmail;

  /// No description provided for @authWeSentCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to\n{email}'**
  String authWeSentCodeTo(String email);

  /// No description provided for @authEnterEmailForCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address, we will send verification code'**
  String get authEnterEmailForCode;

  /// No description provided for @commonSendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get commonSendVerificationCode;

  /// No description provided for @authResendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Resend verification code'**
  String get authResendVerificationCode;

  /// No description provided for @authCanResendAfter.
  ///
  /// In en, this message translates to:
  /// **'Can resend after {seconds} seconds'**
  String authCanResendAfter(int seconds);

  /// No description provided for @commonChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get commonChangeEmail;

  /// No description provided for @contactAddToContacts.
  ///
  /// In en, this message translates to:
  /// **'Add to Contacts'**
  String get contactAddToContacts;

  /// No description provided for @contactAddingToContacts.
  ///
  /// In en, this message translates to:
  /// **'Adding...'**
  String get contactAddingToContacts;

  /// No description provided for @contactAddedToContacts.
  ///
  /// In en, this message translates to:
  /// **'Added to contacts'**
  String get contactAddedToContacts;

  /// No description provided for @contactAddFailedWithError.
  ///
  /// In en, this message translates to:
  /// **'Add failed: {error}'**
  String contactAddFailedWithError(String error);

  /// No description provided for @contactAddPhone.
  ///
  /// In en, this message translates to:
  /// **'Add phone'**
  String get contactAddPhone;

  /// No description provided for @contactAddTag.
  ///
  /// In en, this message translates to:
  /// **'Add tags'**
  String get contactAddTag;

  /// No description provided for @contactAddText.
  ///
  /// In en, this message translates to:
  /// **'Add text'**
  String get contactAddText;

  /// No description provided for @contactAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get contactAddPhoto;

  /// No description provided for @contactGroupCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} groups'**
  String contactGroupCountLabel(int count);

  /// No description provided for @contactAddedViaSearch.
  ///
  /// In en, this message translates to:
  /// **'Added via search'**
  String get contactAddedViaSearch;

  /// No description provided for @contactAddTime.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get contactAddTime;

  /// No description provided for @contactDoneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get contactDoneButton;

  /// No description provided for @callWaitingForParticipants.
  ///
  /// In en, this message translates to:
  /// **'Waiting for participants to join...'**
  String get callWaitingForParticipants;

  /// No description provided for @callParticipantMe.
  ///
  /// In en, this message translates to:
  /// **'{name} (Me)'**
  String callParticipantMe(String name);

  /// No description provided for @callSharingLabel.
  ///
  /// In en, this message translates to:
  /// **'Sharing'**
  String get callSharingLabel;

  /// No description provided for @callScreenSharingBy.
  ///
  /// In en, this message translates to:
  /// **'{name} is sharing screen'**
  String callScreenSharingBy(String name);

  /// No description provided for @callParticipantCount.
  ///
  /// In en, this message translates to:
  /// **'{count} participants'**
  String callParticipantCount(int count);

  /// No description provided for @callMuteLabel.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get callMuteLabel;

  /// No description provided for @callUnmuteLabel.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get callUnmuteLabel;

  /// No description provided for @callTurnOffVideo.
  ///
  /// In en, this message translates to:
  /// **'Turn off video'**
  String get callTurnOffVideo;

  /// No description provided for @callTurnOnVideo.
  ///
  /// In en, this message translates to:
  /// **'Turn on video'**
  String get callTurnOnVideo;

  /// No description provided for @callShareScreen.
  ///
  /// In en, this message translates to:
  /// **'Share screen'**
  String get callShareScreen;

  /// No description provided for @callStopSharing.
  ///
  /// In en, this message translates to:
  /// **'Stop sharing'**
  String get callStopSharing;

  /// No description provided for @callSwitchCameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get callSwitchCameraLabel;

  /// No description provided for @callLeaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get callLeaveLabel;

  /// No description provided for @callParticipantsLabel.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get callParticipantsLabel;

  /// No description provided for @callJoiningMeeting.
  ///
  /// In en, this message translates to:
  /// **'Joining meeting...'**
  String get callJoiningMeeting;

  /// No description provided for @chatPollVotesFormat.
  ///
  /// In en, this message translates to:
  /// **'{count} votes ({percentage}%)'**
  String chatPollVotesFormat(int count, String percentage);

  /// No description provided for @chatPollParticipantsFormat.
  ///
  /// In en, this message translates to:
  /// **'{count} participants'**
  String chatPollParticipantsFormat(int count);

  /// No description provided for @chatNoMediaUrlAvailable.
  ///
  /// In en, this message translates to:
  /// **'No media URL available'**
  String get chatNoMediaUrlAvailable;

  /// No description provided for @chatDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {code}'**
  String chatDownloadFailed(String code);

  /// No description provided for @chatErrorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String chatErrorWithMessage(String message);

  /// No description provided for @chatMusicLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Music link'**
  String get chatMusicLinkLabel;

  /// No description provided for @chatRedPacketTransferCannotForward.
  ///
  /// In en, this message translates to:
  /// **'Red packets and transfers cannot be forwarded'**
  String get chatRedPacketTransferCannotForward;

  /// No description provided for @commonShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Share failed: {error}'**
  String commonShareFailed(String error);

  /// No description provided for @commonTapToRetry.
  ///
  /// In en, this message translates to:
  /// **'Tap to retry'**
  String get commonTapToRetry;

  /// No description provided for @chatDefaultRedPacketGreeting.
  ///
  /// In en, this message translates to:
  /// **'Best wishes for prosperity'**
  String get chatDefaultRedPacketGreeting;

  /// No description provided for @groupAllowOthersToSearchAndJoin.
  ///
  /// In en, this message translates to:
  /// **'Allow others to search and join'**
  String get groupAllowOthersToSearchAndJoin;

  /// No description provided for @groupConfirmClearChatHistory.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear chat history?'**
  String get groupConfirmClearChatHistory;

  /// No description provided for @groupCreateGroupToChat.
  ///
  /// In en, this message translates to:
  /// **'Create a group to start chatting'**
  String get groupCreateGroupToChat;

  /// No description provided for @groupEditGroupAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Edit group announcement'**
  String get groupEditGroupAnnouncement;

  /// No description provided for @groupEditGroupDescription.
  ///
  /// In en, this message translates to:
  /// **'Edit group description'**
  String get groupEditGroupDescription;

  /// No description provided for @groupEnterGroupAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Enter group announcement'**
  String get groupEnterGroupAnnouncement;

  /// No description provided for @groupMemberCountClickToCopy.
  ///
  /// In en, this message translates to:
  /// **'{count} members, click to copy group ID'**
  String groupMemberCountClickToCopy(Object count);

  /// No description provided for @groupNoPermissionToEditGroupName.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to edit group name'**
  String get groupNoPermissionToEditGroupName;

  /// No description provided for @authEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authEmailAddress;

  /// No description provided for @commonEnterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get commonEnterEmailAddress;

  /// No description provided for @authEmailRecoveryHint.
  ///
  /// In en, this message translates to:
  /// **'Used for password recovery'**
  String get authEmailRecoveryHint;

  /// No description provided for @commonInvalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get commonInvalidEmailFormat;

  /// No description provided for @authOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get authOptional;

  /// No description provided for @authResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetPassword;

  /// No description provided for @authEnterRegisteredEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the email address you registered with'**
  String get authEnterRegisteredEmail;

  /// No description provided for @authSendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Code'**
  String get authSendResetCode;

  /// No description provided for @authResetCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Reset code sent to {email}'**
  String authResetCodeSent(String email);

  /// No description provided for @authEnterResetCode.
  ///
  /// In en, this message translates to:
  /// **'Enter reset code'**
  String get authEnterResetCode;

  /// No description provided for @authSetNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get authSetNewPassword;

  /// No description provided for @commonConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get commonConfirmNewPassword;

  /// No description provided for @commonNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get commonNewPassword;

  /// No description provided for @authPasswordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successful. Please login with your new password.'**
  String get authPasswordResetSuccess;

  /// No description provided for @authResetPasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Reset password failed'**
  String get authResetPasswordFailed;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePassword;

  /// No description provided for @settingsCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get settingsCurrentPassword;

  /// No description provided for @settingsEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get settingsEnterCurrentPassword;

  /// No description provided for @settingsEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get settingsEnterNewPassword;

  /// No description provided for @settingsPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully. Please login with your new password.'**
  String get settingsPasswordChanged;

  /// No description provided for @settingsChangePasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Change password failed'**
  String get settingsChangePasswordFailed;

  /// No description provided for @settingsNewPasswordMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from current password'**
  String get settingsNewPasswordMustBeDifferent;

  /// No description provided for @settingsChangePasswordInfo.
  ///
  /// In en, this message translates to:
  /// **'After changing password, you will be logged out and need to login with the new password.'**
  String get settingsChangePasswordInfo;

  /// No description provided for @settingsPasswordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password requirements:'**
  String get settingsPasswordRequirements;

  /// No description provided for @settingsSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'For security, you will need to re-login on all devices after changing password.'**
  String get settingsSecurityNote;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsCurrentBoundEmail.
  ///
  /// In en, this message translates to:
  /// **'Current bound email'**
  String get settingsCurrentBoundEmail;

  /// No description provided for @settingsNewEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'New Email Address'**
  String get settingsNewEmailAddress;

  /// No description provided for @settingsEnterNewEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter new email address'**
  String get settingsEnterNewEmail;

  /// No description provided for @settingsVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get settingsVerificationCode;

  /// No description provided for @settingsVerificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent'**
  String get settingsVerificationCodeSent;

  /// No description provided for @settingsCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to'**
  String get settingsCodeSentTo;

  /// No description provided for @settingsDidNotReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get settingsDidNotReceiveCode;

  /// No description provided for @settingsEmailChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email changed successfully'**
  String get settingsEmailChangedSuccess;

  /// No description provided for @settingsChangeEmailFailed.
  ///
  /// In en, this message translates to:
  /// **'Change email failed'**
  String get settingsChangeEmailFailed;

  /// No description provided for @settingsEmailSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'Your email is used for password recovery. Please keep it secure.'**
  String get settingsEmailSecurityNote;

  /// No description provided for @commonGoogleLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get commonGoogleLogin;

  /// No description provided for @commonAppleLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get commonAppleLogin;

  /// No description provided for @commonWechat.
  ///
  /// In en, this message translates to:
  /// **'WeChat'**
  String get commonWechat;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get settingsLanguageChanged;

  /// No description provided for @settingsTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get settingsTranslation;

  /// No description provided for @settingsTranslateTextTo.
  ///
  /// In en, this message translates to:
  /// **'Translate text to'**
  String get settingsTranslateTextTo;

  /// No description provided for @settingsTranslateDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the language you want messages to be translated into.'**
  String get settingsTranslateDescription;

  /// No description provided for @settingsAutoTranslate.
  ///
  /// In en, this message translates to:
  /// **'Auto-translate received messages'**
  String get settingsAutoTranslate;

  /// No description provided for @settingsAutoTranslateDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically translate messages received in chat to your selected language.'**
  String get settingsAutoTranslateDescription;

  /// No description provided for @settingsBiometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get settingsBiometricLogin;

  /// No description provided for @authLoginWithBiometric.
  ///
  /// In en, this message translates to:
  /// **'Login with {type}'**
  String authLoginWithBiometric(Object type);

  /// No description provided for @settingsBiometricLoginEnabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric login enabled'**
  String get settingsBiometricLoginEnabled;

  /// No description provided for @settingsBiometricLoginDisabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric login disabled'**
  String get settingsBiometricLoginDisabled;

  /// No description provided for @settingsEnableBiometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Enable biometric login'**
  String get settingsEnableBiometricLogin;

  /// No description provided for @settingsBiometricEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled - Use biometric to login'**
  String get settingsBiometricEnabled;

  /// No description provided for @settingsBiometricDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled - Tap to enable'**
  String get settingsBiometricDisabled;

  /// No description provided for @settingsBiometricNeedRelogin.
  ///
  /// In en, this message translates to:
  /// **'Please log out and log in again to enable biometric login'**
  String get settingsBiometricNeedRelogin;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get authOr;

  /// No description provided for @qrcodeCameraPermissionRestricted.
  ///
  /// In en, this message translates to:
  /// **'Camera access is restricted on this device'**
  String get qrcodeCameraPermissionRestricted;

  /// No description provided for @authPasskeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Passkey'**
  String get authPasskeyLabel;

  /// No description provided for @authGoogleLabel.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get authGoogleLabel;

  /// No description provided for @authAppleLabel.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get authAppleLabel;

  /// No description provided for @authSsoLabel.
  ///
  /// In en, this message translates to:
  /// **'SSO'**
  String get authSsoLabel;

  /// No description provided for @authSsoNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'This server has not configured SSO login providers'**
  String get authSsoNotConfigured;

  /// No description provided for @transferAmountHintZero.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get transferAmountHintZero;

  /// No description provided for @commonMatrixIdHint.
  ///
  /// In en, this message translates to:
  /// **'@username:server.com'**
  String get commonMatrixIdHint;

  /// No description provided for @authServerAddressHint.
  ///
  /// In en, this message translates to:
  /// **'https://m.si46.world'**
  String get authServerAddressHint;

  /// No description provided for @authEmailExampleHint.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get authEmailExampleHint;

  /// No description provided for @authVerificationCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'------'**
  String get authVerificationCodePlaceholder;

  /// No description provided for @profileEnterPokeSuffixHint.
  ///
  /// In en, this message translates to:
  /// **'Enter poke suffix, e.g.: on the shoulder'**
  String get profileEnterPokeSuffixHint;

  /// No description provided for @groupAlbum.
  ///
  /// In en, this message translates to:
  /// **'Group Album'**
  String get groupAlbum;

  /// No description provided for @groupFiles.
  ///
  /// In en, this message translates to:
  /// **'Group Files'**
  String get groupFiles;

  /// No description provided for @groupImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get groupImages;

  /// No description provided for @groupVideos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get groupVideos;

  /// No description provided for @groupTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get groupTotal;

  /// No description provided for @groupSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get groupSize;

  /// No description provided for @groupNoMedia.
  ///
  /// In en, this message translates to:
  /// **'No Media'**
  String get groupNoMedia;

  /// No description provided for @groupNoMediaDescription.
  ///
  /// In en, this message translates to:
  /// **'No photos or videos in this group yet'**
  String get groupNoMediaDescription;

  /// No description provided for @groupDocuments.
  ///
  /// In en, this message translates to:
  /// **'Docs'**
  String get groupDocuments;

  /// No description provided for @groupNoFiles.
  ///
  /// In en, this message translates to:
  /// **'No Files'**
  String get groupNoFiles;

  /// No description provided for @groupNoFilesDescription.
  ///
  /// In en, this message translates to:
  /// **'No files in this group yet'**
  String get groupNoFilesDescription;

  /// No description provided for @groupDownloadStarted.
  ///
  /// In en, this message translates to:
  /// **'Downloading {filename}...'**
  String groupDownloadStarted(String filename);

  /// No description provided for @contactNoCommonGroups.
  ///
  /// In en, this message translates to:
  /// **'No common groups'**
  String get contactNoCommonGroups;

  /// No description provided for @contactNoCommonGroupsDescription.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any groups in common'**
  String get contactNoCommonGroupsDescription;

  /// No description provided for @chatVoiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get chatVoiceMessage;

  /// No description provided for @chatMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatMessage;

  /// No description provided for @conversationHideChat.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get conversationHideChat;

  /// No description provided for @settingsQuickReply.
  ///
  /// In en, this message translates to:
  /// **'Quick Reply'**
  String get settingsQuickReply;

  /// No description provided for @commonTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get commonTranslate;

  /// No description provided for @contactCreateTag.
  ///
  /// In en, this message translates to:
  /// **'Create Tag'**
  String get contactCreateTag;

  /// No description provided for @contactEnterTagName.
  ///
  /// In en, this message translates to:
  /// **'Enter tag name'**
  String get contactEnterTagName;

  /// No description provided for @contactEditTag.
  ///
  /// In en, this message translates to:
  /// **'Edit Tag'**
  String get contactEditTag;

  /// No description provided for @contactDeleteTag.
  ///
  /// In en, this message translates to:
  /// **'Delete Tag'**
  String get contactDeleteTag;

  /// No description provided for @contactDeleteTagConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the tag \"{tagName}\"?'**
  String contactDeleteTagConfirm(String tagName);

  /// No description provided for @contactNoTags.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get contactNoTags;

  /// No description provided for @contactFriendPermissions.
  ///
  /// In en, this message translates to:
  /// **'Friend Permissions'**
  String get contactFriendPermissions;

  /// No description provided for @contactSetChatOnly.
  ///
  /// In en, this message translates to:
  /// **'Set as Chat-only'**
  String get contactSetChatOnly;

  /// No description provided for @contactChatOnlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Can only chat with you, other content will be hidden'**
  String get contactChatOnlyDesc;

  /// No description provided for @contactHideMyMoments.
  ///
  /// In en, this message translates to:
  /// **'Hide My Moments'**
  String get contactHideMyMoments;

  /// No description provided for @contactHideMyMomentsDesc.
  ///
  /// In en, this message translates to:
  /// **'This friend cannot see my Moments'**
  String get contactHideMyMomentsDesc;

  /// No description provided for @contactHideTheirMoments.
  ///
  /// In en, this message translates to:
  /// **'Hide Their Moments'**
  String get contactHideTheirMoments;

  /// No description provided for @contactHideTheirMomentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Don\'t see this friend\'s Moments'**
  String get contactHideTheirMomentsDesc;

  /// No description provided for @contactHideMyStatus.
  ///
  /// In en, this message translates to:
  /// **'Hide My Status'**
  String get contactHideMyStatus;

  /// No description provided for @contactHideMyStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'This friend cannot see my status updates'**
  String get contactHideMyStatusDesc;

  /// No description provided for @contactNoChatOnlyFriends.
  ///
  /// In en, this message translates to:
  /// **'No chat-only friends'**
  String get contactNoChatOnlyFriends;

  /// No description provided for @contactNoOfficialAccounts.
  ///
  /// In en, this message translates to:
  /// **'No official accounts'**
  String get contactNoOfficialAccounts;

  /// No description provided for @contactFollowOfficialAccountsDesc.
  ///
  /// In en, this message translates to:
  /// **'Follow official accounts to get the latest updates'**
  String get contactFollowOfficialAccountsDesc;

  /// No description provided for @contactNoServiceAccounts.
  ///
  /// In en, this message translates to:
  /// **'No service accounts'**
  String get contactNoServiceAccounts;

  /// No description provided for @contactSubscribeServiceAccountsDesc.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to service accounts for convenient services'**
  String get contactSubscribeServiceAccountsDesc;

  /// No description provided for @contactNoEnterpriseContacts.
  ///
  /// In en, this message translates to:
  /// **'No enterprise contacts'**
  String get contactNoEnterpriseContacts;

  /// No description provided for @contactEnterpriseContactsDesc.
  ///
  /// In en, this message translates to:
  /// **'Enterprise contacts will be displayed here'**
  String get contactEnterpriseContactsDesc;

  /// No description provided for @profileCardPack.
  ///
  /// In en, this message translates to:
  /// **'Card Pack'**
  String get profileCardPack;

  /// No description provided for @profileOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get profileOrders;

  /// No description provided for @profileNoOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders'**
  String get profileNoOrders;

  /// No description provided for @profileOrdersDesc.
  ///
  /// In en, this message translates to:
  /// **'Your orders will be displayed here'**
  String get profileOrdersDesc;

  /// No description provided for @profileNoCards.
  ///
  /// In en, this message translates to:
  /// **'No cards'**
  String get profileNoCards;

  /// No description provided for @profileCardsDesc.
  ///
  /// In en, this message translates to:
  /// **'Your cards will be displayed here'**
  String get profileCardsDesc;

  /// No description provided for @favoriteEnterTagsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter tags separated by commas'**
  String get favoriteEnterTagsHint;

  /// No description provided for @favoriteTagsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Tags updated'**
  String get favoriteTagsUpdated;

  /// No description provided for @favoriteForwardedContent.
  ///
  /// In en, this message translates to:
  /// **'Content forwarded'**
  String get favoriteForwardedContent;

  /// No description provided for @favoriteEnterNoteContent.
  ///
  /// In en, this message translates to:
  /// **'Enter note content'**
  String get favoriteEnterNoteContent;

  /// No description provided for @favoriteNoteAdded.
  ///
  /// In en, this message translates to:
  /// **'Note added'**
  String get favoriteNoteAdded;

  /// No description provided for @favoriteLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Link title'**
  String get favoriteLinkTitle;

  /// No description provided for @favoriteLinkUrl.
  ///
  /// In en, this message translates to:
  /// **'https://'**
  String get favoriteLinkUrl;

  /// No description provided for @favoriteLinkAdded.
  ///
  /// In en, this message translates to:
  /// **'Link added'**
  String get favoriteLinkAdded;

  /// No description provided for @contactPhotoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added'**
  String get contactPhotoAdded;

  /// No description provided for @contactEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get contactEnterPhone;

  /// No description provided for @commonConversationWithId.
  ///
  /// In en, this message translates to:
  /// **'Conversation: {roomId}'**
  String commonConversationWithId(Object roomId);

  /// No description provided for @commonContactWithId.
  ///
  /// In en, this message translates to:
  /// **'Contact: {userId}'**
  String commonContactWithId(Object userId);

  /// No description provided for @commonDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get commonDiscover;

  /// No description provided for @commonDeveloping.
  ///
  /// In en, this message translates to:
  /// **'{title}\n(Coming soon)'**
  String commonDeveloping(Object title);

  /// No description provided for @commonPageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get commonPageNotFound;

  /// No description provided for @commonBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get commonBackToHome;

  /// No description provided for @settingsMessageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Message notifications'**
  String get settingsMessageNotifications;

  /// No description provided for @settingsReceiveNewMessageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive new message notifications'**
  String get settingsReceiveNewMessageNotifications;

  /// No description provided for @settingsShowMessagePreview.
  ///
  /// In en, this message translates to:
  /// **'Show message preview'**
  String get settingsShowMessagePreview;

  /// No description provided for @settingsShowMessageContentInNotification.
  ///
  /// In en, this message translates to:
  /// **'Show message content in notification'**
  String get settingsShowMessageContentInNotification;

  /// No description provided for @settingsNotificationSound.
  ///
  /// In en, this message translates to:
  /// **'Notification Sound'**
  String get settingsNotificationSound;

  /// No description provided for @settingsPlaySoundOnMessage.
  ///
  /// In en, this message translates to:
  /// **'Play sound when receiving messages'**
  String get settingsPlaySoundOnMessage;

  /// No description provided for @commonVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get commonVibration;

  /// No description provided for @settingsVibrateOnMessage.
  ///
  /// In en, this message translates to:
  /// **'Vibrate when receiving messages'**
  String get settingsVibrateOnMessage;

  /// No description provided for @settingsDoNotDisturbMode.
  ///
  /// In en, this message translates to:
  /// **'Do not disturb'**
  String get settingsDoNotDisturbMode;

  /// No description provided for @settingsDoNotDisturbDescription.
  ///
  /// In en, this message translates to:
  /// **'Do not receive notifications during specified time'**
  String get settingsDoNotDisturbDescription;

  /// No description provided for @settingsStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get settingsStartTime;

  /// No description provided for @settingsEndTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get settingsEndTime;

  /// No description provided for @settingsDeleteQuickReply.
  ///
  /// In en, this message translates to:
  /// **'Delete Quick Reply'**
  String get settingsDeleteQuickReply;

  /// No description provided for @settingsEditQuickReply.
  ///
  /// In en, this message translates to:
  /// **'Edit Quick Reply'**
  String get settingsEditQuickReply;

  /// No description provided for @settingsAddQuickReply.
  ///
  /// In en, this message translates to:
  /// **'Add Quick Reply'**
  String get settingsAddQuickReply;

  /// No description provided for @settingsManageQuickReplies.
  ///
  /// In en, this message translates to:
  /// **'Manage Quick Replies'**
  String get settingsManageQuickReplies;

  /// No description provided for @settingsNoQuickReplies.
  ///
  /// In en, this message translates to:
  /// **'No quick replies'**
  String get settingsNoQuickReplies;

  /// No description provided for @settingsDefaultQuickReplies.
  ///
  /// In en, this message translates to:
  /// **'Default quick replies will be shown'**
  String get settingsDefaultQuickReplies;

  /// No description provided for @settingsWhoCanSee.
  ///
  /// In en, this message translates to:
  /// **'Who can see'**
  String get settingsWhoCanSee;

  /// No description provided for @settingsLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last Seen'**
  String get settingsLastSeen;

  /// No description provided for @settingsHiddenChats.
  ///
  /// In en, this message translates to:
  /// **'Hidden Chats'**
  String get settingsHiddenChats;

  /// No description provided for @settingsMessagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get settingsMessagesLabel;

  /// No description provided for @settingsAllowStrangerMessages.
  ///
  /// In en, this message translates to:
  /// **'Allow stranger messages'**
  String get settingsAllowStrangerMessages;

  /// No description provided for @settingsReceiveMessagesFromNonContacts.
  ///
  /// In en, this message translates to:
  /// **'Receive messages from non-contacts'**
  String get settingsReceiveMessagesFromNonContacts;

  /// No description provided for @settingsReadReceipts.
  ///
  /// In en, this message translates to:
  /// **'Read Receipts'**
  String get settingsReadReceipts;

  /// No description provided for @settingsLetOthersKnowYouRead.
  ///
  /// In en, this message translates to:
  /// **'Let others know you read'**
  String get settingsLetOthersKnowYouRead;

  /// No description provided for @settingsTypingIndicator.
  ///
  /// In en, this message translates to:
  /// **'Typing indicator'**
  String get settingsTypingIndicator;

  /// No description provided for @settingsLetOthersKnowYouTyping.
  ///
  /// In en, this message translates to:
  /// **'Let others know you are typing'**
  String get settingsLetOthersKnowYouTyping;

  /// No description provided for @settingsEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get settingsEveryone;

  /// No description provided for @settingsContactsOnly.
  ///
  /// In en, this message translates to:
  /// **'Contacts Only'**
  String get settingsContactsOnly;

  /// No description provided for @settingsNobody.
  ///
  /// In en, this message translates to:
  /// **'Nobody'**
  String get settingsNobody;

  /// No description provided for @settingsWhoCanSeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Who can see {title}'**
  String settingsWhoCanSeeTitle(String title);

  /// No description provided for @settingsVersionInfo.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersionInfo(String version);

  /// No description provided for @settingsCheckForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get settingsCheckForUpdates;

  /// No description provided for @settingsOpenSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get settingsOpenSourceLicenses;

  /// No description provided for @settingsFeedbackAndSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Feedback and suggestions'**
  String get settingsFeedbackAndSuggestions;

  /// No description provided for @settingsBuiltOnMatrix.
  ///
  /// In en, this message translates to:
  /// **'Built on Matrix Protocol'**
  String get settingsBuiltOnMatrix;

  /// No description provided for @settingsNoHiddenChats.
  ///
  /// In en, this message translates to:
  /// **'No hidden chats'**
  String get settingsNoHiddenChats;

  /// No description provided for @settingsNoHiddenChatsDescription.
  ///
  /// In en, this message translates to:
  /// **'Chats you hide will appear here'**
  String get settingsNoHiddenChatsDescription;

  /// No description provided for @settingsUnhideChat.
  ///
  /// In en, this message translates to:
  /// **'Unhide'**
  String get settingsUnhideChat;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsFontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get settingsFontSize;

  /// No description provided for @settingsBubbleStyle.
  ///
  /// In en, this message translates to:
  /// **'Bubble style'**
  String get settingsBubbleStyle;

  /// No description provided for @settingsFollowSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get settingsFollowSystem;

  /// No description provided for @settingsAutoSwitchBySystem.
  ///
  /// In en, this message translates to:
  /// **'Auto switch by system'**
  String get settingsAutoSwitchBySystem;

  /// No description provided for @settingsLightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get settingsLightMode;

  /// No description provided for @settingsAlwaysUseLightTheme.
  ///
  /// In en, this message translates to:
  /// **'Always use light theme'**
  String get settingsAlwaysUseLightTheme;

  /// No description provided for @settingsDarkModeOption.
  ///
  /// In en, this message translates to:
  /// **'Dark mode option'**
  String get settingsDarkModeOption;

  /// No description provided for @settingsAlwaysUseDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Always use dark theme'**
  String get settingsAlwaysUseDarkTheme;

  /// No description provided for @settingsFontSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get settingsFontSizeSmall;

  /// No description provided for @settingsFontSizeStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get settingsFontSizeStandard;

  /// No description provided for @settingsFontSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get settingsFontSizeLarge;

  /// No description provided for @settingsFontSizeExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra large'**
  String get settingsFontSizeExtraLarge;

  /// No description provided for @settingsBubbleStyleWechat.
  ///
  /// In en, this message translates to:
  /// **'WeChat style'**
  String get settingsBubbleStyleWechat;

  /// No description provided for @settingsBubbleStyleWechatDesc.
  ///
  /// In en, this message translates to:
  /// **'Classic WeChat bubble style'**
  String get settingsBubbleStyleWechatDesc;

  /// No description provided for @settingsBubbleStyleModern.
  ///
  /// In en, this message translates to:
  /// **'Modern style'**
  String get settingsBubbleStyleModern;

  /// No description provided for @settingsBubbleStyleModernDesc.
  ///
  /// In en, this message translates to:
  /// **'Clean modern bubble style'**
  String get settingsBubbleStyleModernDesc;

  /// No description provided for @settingsBubbleStyleClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic style'**
  String get settingsBubbleStyleClassic;

  /// No description provided for @settingsBubbleStyleClassicDesc.
  ///
  /// In en, this message translates to:
  /// **'Traditional bubble style'**
  String get settingsBubbleStyleClassicDesc;

  /// No description provided for @discoverVideoChannels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get discoverVideoChannels;

  /// No description provided for @discoverLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get discoverLive;

  /// No description provided for @discoverListen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get discoverListen;

  /// No description provided for @discoverWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get discoverWatch;

  /// No description provided for @discoverSearchDiscover.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get discoverSearchDiscover;

  /// No description provided for @discoverNearbyPeople.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get discoverNearbyPeople;

  /// No description provided for @discoverGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get discoverGames;

  /// No description provided for @discoverMiniPrograms.
  ///
  /// In en, this message translates to:
  /// **'Mini Programs'**
  String get discoverMiniPrograms;

  /// No description provided for @chatAlreadyInCall.
  ///
  /// In en, this message translates to:
  /// **'Already in a call'**
  String get chatAlreadyInCall;

  /// No description provided for @commonConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get commonConnectionFailed;

  /// No description provided for @chatCallRejected.
  ///
  /// In en, this message translates to:
  /// **'Call declined'**
  String get chatCallRejected;

  /// No description provided for @chatNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get chatNoAnswer;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @chatSelectContact.
  ///
  /// In en, this message translates to:
  /// **'Select Contact'**
  String get chatSelectContact;

  /// No description provided for @chatVoteRemoved.
  ///
  /// In en, this message translates to:
  /// **'Vote removed'**
  String get chatVoteRemoved;

  /// No description provided for @chatVoteChanged.
  ///
  /// In en, this message translates to:
  /// **'Vote changed'**
  String get chatVoteChanged;

  /// No description provided for @chatVoted.
  ///
  /// In en, this message translates to:
  /// **'Voted'**
  String get chatVoted;

  /// No description provided for @chatReplyTo.
  ///
  /// In en, this message translates to:
  /// **'Reply to {name}'**
  String chatReplyTo(String name);

  /// No description provided for @chatCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get chatCurrentLocation;

  /// No description provided for @chatNearbyPlace.
  ///
  /// In en, this message translates to:
  /// **'Nearby Place {index}'**
  String chatNearbyPlace(int index);

  /// No description provided for @chatApproximateDistance.
  ///
  /// In en, this message translates to:
  /// **'About {distance}'**
  String chatApproximateDistance(String distance);

  /// No description provided for @chatAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get chatAddress;

  /// No description provided for @chatLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get chatLatitude;

  /// No description provided for @chatLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get chatLongitude;

  /// No description provided for @groupDescriptionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Group description updated'**
  String get groupDescriptionUpdated;

  /// No description provided for @groupAvatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Group avatar updated'**
  String get groupAvatarUpdated;

  /// No description provided for @groupVisibilityUpdated.
  ///
  /// In en, this message translates to:
  /// **'Group visibility updated'**
  String get groupVisibilityUpdated;

  /// No description provided for @groupChannelCreated.
  ///
  /// In en, this message translates to:
  /// **'Channel created'**
  String get groupChannelCreated;

  /// No description provided for @groupChannelUpdated.
  ///
  /// In en, this message translates to:
  /// **'Channel updated'**
  String get groupChannelUpdated;

  /// No description provided for @groupChannelDeleted.
  ///
  /// In en, this message translates to:
  /// **'Channel deleted'**
  String get groupChannelDeleted;

  /// No description provided for @callDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get callDecline;

  /// No description provided for @callAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get callAnswer;

  /// No description provided for @callIncomingVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Incoming video call'**
  String get callIncomingVideoCall;

  /// No description provided for @callIncomingVoiceCall.
  ///
  /// In en, this message translates to:
  /// **'Incoming voice call'**
  String get callIncomingVoiceCall;

  /// No description provided for @callVideoCallInProgress.
  ///
  /// In en, this message translates to:
  /// **'Video call in progress'**
  String get callVideoCallInProgress;

  /// No description provided for @callVoiceCallInProgress.
  ///
  /// In en, this message translates to:
  /// **'Voice call in progress'**
  String get callVoiceCallInProgress;

  /// No description provided for @callReconnectingCall.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting...'**
  String get callReconnectingCall;

  /// No description provided for @callEnded.
  ///
  /// In en, this message translates to:
  /// **'Call ended'**
  String get callEnded;

  /// No description provided for @callFailed.
  ///
  /// In en, this message translates to:
  /// **'Call failed'**
  String get callFailed;

  /// No description provided for @callLivekitNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'LiveKit not configured'**
  String get callLivekitNotConfigured;

  /// No description provided for @callJoinMeetingFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to join meeting: {error}'**
  String callJoinMeetingFailed(Object error);

  /// No description provided for @callScreenShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Screen share failed: {error}'**
  String callScreenShareFailed(Object error);

  /// No description provided for @profileN42BeanTitle.
  ///
  /// In en, this message translates to:
  /// **'N42 Bean'**
  String get profileN42BeanTitle;

  /// No description provided for @profileNoN42Bean.
  ///
  /// In en, this message translates to:
  /// **'No N42 Bean'**
  String get profileNoN42Bean;

  /// No description provided for @profileN42BeanDetails.
  ///
  /// In en, this message translates to:
  /// **'N42 Bean Details'**
  String get profileN42BeanDetails;

  /// No description provided for @profileN42BeanDescription.
  ///
  /// In en, this message translates to:
  /// **'N42 Bean is a token used to redeem virtual items and services in N42. Currently available for:'**
  String get profileN42BeanDescription;

  /// No description provided for @profileN42BeanFeature1.
  ///
  /// In en, this message translates to:
  /// **'Exclusive member stickers and themes'**
  String get profileN42BeanFeature1;

  /// No description provided for @profileN42BeanFeature2.
  ///
  /// In en, this message translates to:
  /// **'Chat bubble customization'**
  String get profileN42BeanFeature2;

  /// No description provided for @profileN42BeanFeature3.
  ///
  /// In en, this message translates to:
  /// **'Red packet cover customization'**
  String get profileN42BeanFeature3;

  /// No description provided for @profileN42BeanFeature4.
  ///
  /// In en, this message translates to:
  /// **'Exclusive nickname badge'**
  String get profileN42BeanFeature4;

  /// No description provided for @profileN42BeanFeature5.
  ///
  /// In en, this message translates to:
  /// **'Group chat privileges'**
  String get profileN42BeanFeature5;

  /// No description provided for @profileN42BeanFeature6.
  ///
  /// In en, this message translates to:
  /// **'Cloud storage expansion'**
  String get profileN42BeanFeature6;

  /// No description provided for @profileN42BeanFeature7.
  ///
  /// In en, this message translates to:
  /// **'Video call beauty filters'**
  String get profileN42BeanFeature7;

  /// No description provided for @profileN42BeanFeature8.
  ///
  /// In en, this message translates to:
  /// **'Moments background customization'**
  String get profileN42BeanFeature8;

  /// No description provided for @profileN42BeanFeature9.
  ///
  /// In en, this message translates to:
  /// **'VIP customer service priority'**
  String get profileN42BeanFeature9;

  /// No description provided for @profileGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get profileGotIt;

  /// No description provided for @profileNoN42BeanRecords.
  ///
  /// In en, this message translates to:
  /// **'No N42 Bean records'**
  String get profileNoN42BeanRecords;

  /// No description provided for @profileMoodAndThoughts.
  ///
  /// In en, this message translates to:
  /// **'Mood & Thoughts'**
  String get profileMoodAndThoughts;

  /// No description provided for @profileStatusHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get profileStatusHappy;

  /// No description provided for @profileStatusCracked.
  ///
  /// In en, this message translates to:
  /// **'Shattered'**
  String get profileStatusCracked;

  /// No description provided for @profileStatusLucky.
  ///
  /// In en, this message translates to:
  /// **'Lucky'**
  String get profileStatusLucky;

  /// No description provided for @profileStatusSunny.
  ///
  /// In en, this message translates to:
  /// **'Sunny'**
  String get profileStatusSunny;

  /// No description provided for @profileStatusTired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get profileStatusTired;

  /// No description provided for @profileStatusDaydream.
  ///
  /// In en, this message translates to:
  /// **'Daydream'**
  String get profileStatusDaydream;

  /// No description provided for @profileStatusRushing.
  ///
  /// In en, this message translates to:
  /// **'Rushing'**
  String get profileStatusRushing;

  /// No description provided for @profileStatusOverthinking.
  ///
  /// In en, this message translates to:
  /// **'Overthinking'**
  String get profileStatusOverthinking;

  /// No description provided for @profileStatusEnergized.
  ///
  /// In en, this message translates to:
  /// **'Energized'**
  String get profileStatusEnergized;

  /// No description provided for @profileWorkAndStudy.
  ///
  /// In en, this message translates to:
  /// **'Work & Study'**
  String get profileWorkAndStudy;

  /// No description provided for @profileStatusWorking.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get profileStatusWorking;

  /// No description provided for @profileStatusStudying.
  ///
  /// In en, this message translates to:
  /// **'Studying'**
  String get profileStatusStudying;

  /// No description provided for @profileStatusBusy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get profileStatusBusy;

  /// No description provided for @profileStatusSlacking.
  ///
  /// In en, this message translates to:
  /// **'Slacking'**
  String get profileStatusSlacking;

  /// No description provided for @profileStatusTraveling.
  ///
  /// In en, this message translates to:
  /// **'Traveling'**
  String get profileStatusTraveling;

  /// No description provided for @profileStatusGoingHome.
  ///
  /// In en, this message translates to:
  /// **'Going Home'**
  String get profileStatusGoingHome;

  /// No description provided for @profileStatusDnd.
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb'**
  String get profileStatusDnd;

  /// No description provided for @profileActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get profileActivities;

  /// No description provided for @profileStatusHanging.
  ///
  /// In en, this message translates to:
  /// **'Hanging Out'**
  String get profileStatusHanging;

  /// No description provided for @profileStatusCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get profileStatusCheckIn;

  /// No description provided for @profileStatusExercising.
  ///
  /// In en, this message translates to:
  /// **'Exercising'**
  String get profileStatusExercising;

  /// No description provided for @profileStatusCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get profileStatusCoffee;

  /// No description provided for @profileStatusBubbleTea.
  ///
  /// In en, this message translates to:
  /// **'Bubble Tea'**
  String get profileStatusBubbleTea;

  /// No description provided for @profileStatusEating.
  ///
  /// In en, this message translates to:
  /// **'Eating'**
  String get profileStatusEating;

  /// No description provided for @profileStatusParenting.
  ///
  /// In en, this message translates to:
  /// **'Parenting'**
  String get profileStatusParenting;

  /// No description provided for @profileStatusSavingWorld.
  ///
  /// In en, this message translates to:
  /// **'Saving World'**
  String get profileStatusSavingWorld;

  /// No description provided for @profileStatusSelfie.
  ///
  /// In en, this message translates to:
  /// **'Selfie'**
  String get profileStatusSelfie;

  /// No description provided for @profileRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get profileRest;

  /// No description provided for @profileStatusRetreat.
  ///
  /// In en, this message translates to:
  /// **'Retreat'**
  String get profileStatusRetreat;

  /// No description provided for @profileStatusHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get profileStatusHome;

  /// No description provided for @profileStatusSleeping.
  ///
  /// In en, this message translates to:
  /// **'Sleeping'**
  String get profileStatusSleeping;

  /// No description provided for @profileStatusCatLover.
  ///
  /// In en, this message translates to:
  /// **'Cat Lover'**
  String get profileStatusCatLover;

  /// No description provided for @profileStatusDogWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking Dog'**
  String get profileStatusDogWalking;

  /// No description provided for @profileStatusGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get profileStatusGaming;

  /// No description provided for @profileStatusListening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get profileStatusListening;

  /// No description provided for @profileEditAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get profileEditAddress;

  /// No description provided for @profileRecipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get profileRecipient;

  /// No description provided for @profileEnterRecipientName.
  ///
  /// In en, this message translates to:
  /// **'Enter recipient name'**
  String get profileEnterRecipientName;

  /// No description provided for @profilePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profilePhoneNumber;

  /// No description provided for @profileEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get profileEnterPhoneNumber;

  /// No description provided for @profileRegionHint.
  ///
  /// In en, this message translates to:
  /// **'Province/City/District'**
  String get profileRegionHint;

  /// No description provided for @profileDetailedAddress.
  ///
  /// In en, this message translates to:
  /// **'Detailed Address'**
  String get profileDetailedAddress;

  /// No description provided for @profileDetailedAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, building number, etc.'**
  String get profileDetailedAddressHint;

  /// No description provided for @profileSetAsDefaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Set as default address'**
  String get profileSetAsDefaultAddress;

  /// No description provided for @profilePleaseCompleteInfo.
  ///
  /// In en, this message translates to:
  /// **'Please complete all fields'**
  String get profilePleaseCompleteInfo;

  /// No description provided for @profileEditInvoice.
  ///
  /// In en, this message translates to:
  /// **'Edit Invoice'**
  String get profileEditInvoice;

  /// No description provided for @profileInvoiceType.
  ///
  /// In en, this message translates to:
  /// **'Invoice Type'**
  String get profileInvoiceType;

  /// No description provided for @profileCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get profileCompanyName;

  /// No description provided for @profilePersonalName.
  ///
  /// In en, this message translates to:
  /// **'Personal Name'**
  String get profilePersonalName;

  /// No description provided for @profileEnterCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Enter company name'**
  String get profileEnterCompanyName;

  /// No description provided for @profileEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get profileEnterName;

  /// No description provided for @profileTaxIdNumber.
  ///
  /// In en, this message translates to:
  /// **'Tax ID Number'**
  String get profileTaxIdNumber;

  /// No description provided for @profileEnterTaxIdNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter tax ID number'**
  String get profileEnterTaxIdNumber;

  /// No description provided for @profileBankNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Bank Name (Optional)'**
  String get profileBankNameOptional;

  /// No description provided for @profileEnterBankName.
  ///
  /// In en, this message translates to:
  /// **'Enter bank name'**
  String get profileEnterBankName;

  /// No description provided for @profileBankAccountOptional.
  ///
  /// In en, this message translates to:
  /// **'Bank Account (Optional)'**
  String get profileBankAccountOptional;

  /// No description provided for @profileEnterBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Enter bank account'**
  String get profileEnterBankAccount;

  /// No description provided for @profileCompanyAddressOptional.
  ///
  /// In en, this message translates to:
  /// **'Company Address (Optional)'**
  String get profileCompanyAddressOptional;

  /// No description provided for @profileEnterCompanyAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter company address'**
  String get profileEnterCompanyAddress;

  /// No description provided for @profileCompanyPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Company Phone (Optional)'**
  String get profileCompanyPhoneOptional;

  /// No description provided for @profileEnterCompanyPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter company phone'**
  String get profileEnterCompanyPhone;

  /// No description provided for @profileSetAsDefaultInvoice.
  ///
  /// In en, this message translates to:
  /// **'Set as default invoice'**
  String get profileSetAsDefaultInvoice;

  /// No description provided for @profileRingtoneVibrate.
  ///
  /// In en, this message translates to:
  /// **'Vibrate'**
  String get profileRingtoneVibrate;

  /// No description provided for @profileRingtoneSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get profileRingtoneSilent;

  /// No description provided for @profileVibrateMode.
  ///
  /// In en, this message translates to:
  /// **'Vibrate mode'**
  String get profileVibrateMode;

  /// No description provided for @profileSilentMode.
  ///
  /// In en, this message translates to:
  /// **'Silent mode'**
  String get profileSilentMode;

  /// No description provided for @profilePlayFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to play: {ringtoneName}'**
  String profilePlayFailed(Object ringtoneName);

  /// No description provided for @profilePlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing: {ringtoneName}'**
  String profilePlaying(Object ringtoneName);

  /// No description provided for @profileStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get profileStop;

  /// No description provided for @profileSelectRingtone.
  ///
  /// In en, this message translates to:
  /// **'Select Ringtone'**
  String get profileSelectRingtone;

  /// No description provided for @profileLoadingRingtones.
  ///
  /// In en, this message translates to:
  /// **'Loading ringtones...'**
  String get profileLoadingRingtones;

  /// No description provided for @profileNoRingtonesFound.
  ///
  /// In en, this message translates to:
  /// **'No ringtones found'**
  String get profileNoRingtonesFound;

  /// No description provided for @mainMessagesWithCount.
  ///
  /// In en, this message translates to:
  /// **'Messages({count})'**
  String mainMessagesWithCount(int count);

  /// No description provided for @storyViewers.
  ///
  /// In en, this message translates to:
  /// **'Viewers'**
  String get storyViewers;

  /// No description provided for @storyNoViewers.
  ///
  /// In en, this message translates to:
  /// **'No viewers yet'**
  String get storyNoViewers;

  /// No description provided for @storyReplyToStory.
  ///
  /// In en, this message translates to:
  /// **'Reply to story...'**
  String get storyReplyToStory;

  /// No description provided for @commonCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get commonCopiedToClipboard;

  /// No description provided for @commonMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get commonMore;

  /// No description provided for @commonTranslating.
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get commonTranslating;

  /// No description provided for @commonTranslatedFrom.
  ///
  /// In en, this message translates to:
  /// **'Translated from {language}'**
  String commonTranslatedFrom(String language);

  /// No description provided for @commonTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get commonTranslation;

  /// No description provided for @commonTranslationFailed.
  ///
  /// In en, this message translates to:
  /// **'Translation failed'**
  String get commonTranslationFailed;

  /// No description provided for @commonAllRead.
  ///
  /// In en, this message translates to:
  /// **'All read'**
  String get commonAllRead;

  /// No description provided for @commonReadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} read'**
  String commonReadCount(Object count);

  /// No description provided for @commonYouRecalledMessage.
  ///
  /// In en, this message translates to:
  /// **'You recalled a message'**
  String get commonYouRecalledMessage;

  /// No description provided for @commonMessageRecalled.
  ///
  /// In en, this message translates to:
  /// **'Message recalled'**
  String get commonMessageRecalled;

  /// No description provided for @commonReEdit.
  ///
  /// In en, this message translates to:
  /// **'Re-edit'**
  String get commonReEdit;

  /// No description provided for @commonWalletArea.
  ///
  /// In en, this message translates to:
  /// **'Wallet area'**
  String get commonWalletArea;

  /// No description provided for @callIncomingCall.
  ///
  /// In en, this message translates to:
  /// **'Incoming call'**
  String get callIncomingCall;

  /// No description provided for @callMissedCall.
  ///
  /// In en, this message translates to:
  /// **'Missed call'**
  String get callMissedCall;

  /// No description provided for @groupRemoveAdmin.
  ///
  /// In en, this message translates to:
  /// **'Remove Admin'**
  String get groupRemoveAdmin;

  /// No description provided for @chatSelectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select currency'**
  String get chatSelectCurrency;

  /// No description provided for @chatSelectEmoji.
  ///
  /// In en, this message translates to:
  /// **'Select Emoji'**
  String get chatSelectEmoji;

  /// No description provided for @chatSelectRedPacketCover.
  ///
  /// In en, this message translates to:
  /// **'Select Cover'**
  String get chatSelectRedPacketCover;

  /// No description provided for @groupSetAsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Set as Admin'**
  String get groupSetAsAdmin;

  /// Used with error message
  ///
  /// In en, this message translates to:
  /// **'Video playback failed'**
  String get chatVideoPlaybackFailed;

  /// No description provided for @groupViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get groupViewProfile;

  /// No description provided for @favoriteAddLinkComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Add link feature coming soon'**
  String get favoriteAddLinkComingSoon;

  /// No description provided for @favoriteNewNoteComingSoon.
  ///
  /// In en, this message translates to:
  /// **'New note feature coming soon'**
  String get favoriteNewNoteComingSoon;

  /// No description provided for @qrcodeSaveFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Save feature coming soon'**
  String get qrcodeSaveFeatureComingSoon;

  /// No description provided for @qrcodeShareFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share feature coming soon'**
  String get qrcodeShareFeatureComingSoon;

  /// No description provided for @qrcodeProcessFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to process QR code: {error}'**
  String qrcodeProcessFailed(String error);

  /// No description provided for @securityDeviceIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Device ID is required'**
  String get securityDeviceIdRequired;

  /// No description provided for @securityVerificationStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to start verification: {error}'**
  String securityVerificationStartFailed(String error);

  /// No description provided for @securityVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get securityVerificationFailed;

  /// No description provided for @securityVerificationFailedWithReason.
  ///
  /// In en, this message translates to:
  /// **'Verification failed: {reason}'**
  String securityVerificationFailedWithReason(String reason);

  /// No description provided for @securityEmojiMismatchRejected.
  ///
  /// In en, this message translates to:
  /// **'Verification rejected - emoji did not match'**
  String get securityEmojiMismatchRejected;

  /// No description provided for @securityWaitingForDeviceAccept.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the other device to accept...'**
  String get securityWaitingForDeviceAccept;

  /// No description provided for @securityVerifyDevice.
  ///
  /// In en, this message translates to:
  /// **'Verify this device'**
  String get securityVerifyDevice;

  /// No description provided for @securityConfirmEmojiMatch.
  ///
  /// In en, this message translates to:
  /// **'Confirm the emoji below are displayed on both devices, in the same order'**
  String get securityConfirmEmojiMatch;

  /// No description provided for @securityEmojiDontMatch.
  ///
  /// In en, this message translates to:
  /// **'They don\'t match'**
  String get securityEmojiDontMatch;

  /// No description provided for @securityEmojiMatch.
  ///
  /// In en, this message translates to:
  /// **'They match'**
  String get securityEmojiMatch;

  /// No description provided for @securityWaitingForDeviceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the other device to confirm...'**
  String get securityWaitingForDeviceConfirm;

  /// No description provided for @securityVerificationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification successful!'**
  String get securityVerificationSuccess;

  /// No description provided for @securityDeviceVerifiedTrusted.
  ///
  /// In en, this message translates to:
  /// **'This device is now verified and trusted.'**
  String get securityDeviceVerifiedTrusted;

  /// No description provided for @securityCompareEmoji.
  ///
  /// In en, this message translates to:
  /// **'Compare the emoji on both devices'**
  String get securityCompareEmoji;

  /// No description provided for @securityCompareNumbers.
  ///
  /// In en, this message translates to:
  /// **'Compare the numbers on both devices'**
  String get securityCompareNumbers;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get commonTryAgain;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @chatExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Chat'**
  String get chatExportTitle;

  /// No description provided for @chatExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export successful'**
  String get chatExportSuccess;

  /// No description provided for @chatExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String chatExportFailed(String error);

  /// No description provided for @chatExportFormat.
  ///
  /// In en, this message translates to:
  /// **'Export Format'**
  String get chatExportFormat;

  /// No description provided for @chatExportHtmlDesc.
  ///
  /// In en, this message translates to:
  /// **'Readable in any browser with styled layout'**
  String get chatExportHtmlDesc;

  /// No description provided for @chatExportJsonDesc.
  ///
  /// In en, this message translates to:
  /// **'Machine-readable structured data format'**
  String get chatExportJsonDesc;

  /// No description provided for @chatExportDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get chatExportDateRange;

  /// No description provided for @chatExportAll.
  ///
  /// In en, this message translates to:
  /// **'All Messages'**
  String get chatExportAll;

  /// No description provided for @chatExportLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get chatExportLastWeek;

  /// No description provided for @chatExportLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get chatExportLastMonth;

  /// No description provided for @chatExportLast3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get chatExportLast3Months;

  /// No description provided for @chatExportMessageCount.
  ///
  /// In en, this message translates to:
  /// **'Messages to export'**
  String get chatExportMessageCount;

  /// No description provided for @chatExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export & Share'**
  String get chatExportButton;

  /// No description provided for @chatMediaGallery.
  ///
  /// In en, this message translates to:
  /// **'Media Gallery'**
  String get chatMediaGallery;

  /// No description provided for @chatExportHistory.
  ///
  /// In en, this message translates to:
  /// **'Export Chat History'**
  String get chatExportHistory;

  /// No description provided for @pdfLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load PDF'**
  String get pdfLoadFailed;

  /// No description provided for @pdfPageIndicator.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String pdfPageIndicator(int current, int total);

  /// No description provided for @mediaAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mediaAll;

  /// No description provided for @mediaImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get mediaImages;

  /// No description provided for @mediaVideos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get mediaVideos;

  /// No description provided for @mediaFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get mediaFiles;

  /// No description provided for @mediaAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get mediaAudio;

  /// No description provided for @mediaItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String mediaItemsCount(int count);

  /// No description provided for @mediaNoMediaFound.
  ///
  /// In en, this message translates to:
  /// **'No media found'**
  String get mediaNoMediaFound;

  /// No description provided for @spacesTitle.
  ///
  /// In en, this message translates to:
  /// **'Communities'**
  String get spacesTitle;

  /// No description provided for @spacesCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Community'**
  String get spacesCreate;

  /// No description provided for @spacesJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get spacesJoined;

  /// No description provided for @spacesDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get spacesDiscover;

  /// No description provided for @spacesNoJoined.
  ///
  /// In en, this message translates to:
  /// **'No communities joined yet'**
  String get spacesNoJoined;

  /// No description provided for @spacesExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore Communities'**
  String get spacesExplore;

  /// No description provided for @spacesNoPublic.
  ///
  /// In en, this message translates to:
  /// **'No public communities found'**
  String get spacesNoPublic;

  /// No description provided for @spacesJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get spacesJoin;

  /// No description provided for @spacesSubSpaces.
  ///
  /// In en, this message translates to:
  /// **'Sub-Communities'**
  String get spacesSubSpaces;

  /// No description provided for @spacesChannels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get spacesChannels;

  /// No description provided for @spacesMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String spacesMembersCount(int count);

  /// No description provided for @spacesPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get spacesPublic;

  /// No description provided for @spacesPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get spacesPrivate;

  /// No description provided for @spacesSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get spacesSuggested;

  /// No description provided for @spacesChannelsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} channels'**
  String spacesChannelsCount(int count);

  /// No description provided for @callInCallChat.
  ///
  /// In en, this message translates to:
  /// **'In-Call Chat'**
  String get callInCallChat;

  /// No description provided for @callMessagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} messages'**
  String callMessagesCount(int count);

  /// No description provided for @callNoMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.\nSend a message to get started.'**
  String get callNoMessagesYet;

  /// No description provided for @callTypeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get callTypeMessage;

  /// No description provided for @callYouSender.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get callYouSender;

  /// No description provided for @callChatLabel.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get callChatLabel;

  /// No description provided for @chatEdited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get chatEdited;

  /// No description provided for @chatEditHistory.
  ///
  /// In en, this message translates to:
  /// **'Edit History'**
  String get chatEditHistory;

  /// No description provided for @chatOriginalMessage.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get chatOriginalMessage;

  /// No description provided for @chatEditedAt.
  ///
  /// In en, this message translates to:
  /// **'Edited at {time}'**
  String chatEditedAt(String time);

  /// No description provided for @chatViewOnce.
  ///
  /// In en, this message translates to:
  /// **'View Once'**
  String get chatViewOnce;

  /// No description provided for @chatViewOncePhoto.
  ///
  /// In en, this message translates to:
  /// **'View Once Photo'**
  String get chatViewOncePhoto;

  /// No description provided for @chatViewOnceVideo.
  ///
  /// In en, this message translates to:
  /// **'View Once Video'**
  String get chatViewOnceVideo;

  /// No description provided for @chatViewOnceViewed.
  ///
  /// In en, this message translates to:
  /// **'Viewed'**
  String get chatViewOnceViewed;

  /// No description provided for @chatViewOnceExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get chatViewOnceExpired;

  /// No description provided for @chatViewOnceTap.
  ///
  /// In en, this message translates to:
  /// **'Tap to view'**
  String get chatViewOnceTap;

  /// No description provided for @chatAutoFaceBlur.
  ///
  /// In en, this message translates to:
  /// **'Auto face blur'**
  String get chatAutoFaceBlur;

  /// No description provided for @chatAutoFaceBlurDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically blur faces when sending photos'**
  String get chatAutoFaceBlurDesc;

  /// No description provided for @threadReplyInThread.
  ///
  /// In en, this message translates to:
  /// **'Reply in thread'**
  String get threadReplyInThread;

  /// No description provided for @threadReplies.
  ///
  /// In en, this message translates to:
  /// **'{count} replies'**
  String threadReplies(int count);

  /// No description provided for @threadReply.
  ///
  /// In en, this message translates to:
  /// **'1 reply'**
  String get threadReply;

  /// No description provided for @threadLatestReply.
  ///
  /// In en, this message translates to:
  /// **'Latest: {preview}'**
  String threadLatestReply(String preview);

  /// No description provided for @threadTitle.
  ///
  /// In en, this message translates to:
  /// **'Thread'**
  String get threadTitle;

  /// No description provided for @threadReplyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Reply in thread...'**
  String get threadReplyPlaceholder;

  /// No description provided for @threadParticipants.
  ///
  /// In en, this message translates to:
  /// **'{count} participants'**
  String threadParticipants(int count);

  /// No description provided for @voiceRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Room'**
  String get voiceRoomTitle;

  /// No description provided for @voiceRoomCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Voice Room'**
  String get voiceRoomCreate;

  /// No description provided for @voiceRoomJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get voiceRoomJoin;

  /// No description provided for @voiceRoomLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get voiceRoomLeave;

  /// No description provided for @voiceRoomEnd.
  ///
  /// In en, this message translates to:
  /// **'End Room'**
  String get voiceRoomEnd;

  /// No description provided for @voiceRoomRaiseHand.
  ///
  /// In en, this message translates to:
  /// **'Raise Hand'**
  String get voiceRoomRaiseHand;

  /// No description provided for @voiceRoomLowerHand.
  ///
  /// In en, this message translates to:
  /// **'Lower Hand'**
  String get voiceRoomLowerHand;

  /// No description provided for @voiceRoomMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get voiceRoomMute;

  /// No description provided for @voiceRoomUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get voiceRoomUnmute;

  /// No description provided for @voiceRoomHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get voiceRoomHost;

  /// No description provided for @voiceRoomSpeakers.
  ///
  /// In en, this message translates to:
  /// **'Speakers'**
  String get voiceRoomSpeakers;

  /// No description provided for @voiceRoomListeners.
  ///
  /// In en, this message translates to:
  /// **'Listeners'**
  String get voiceRoomListeners;

  /// No description provided for @voiceRoomLive.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get voiceRoomLive;

  /// No description provided for @voiceRoomEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get voiceRoomEnded;

  /// No description provided for @voiceRoomScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get voiceRoomScheduled;

  /// No description provided for @voiceRoomApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get voiceRoomApprove;

  /// No description provided for @voiceRoomDemote.
  ///
  /// In en, this message translates to:
  /// **'Move to Listener'**
  String get voiceRoomDemote;

  /// No description provided for @voiceRoomHandRaised.
  ///
  /// In en, this message translates to:
  /// **'{name} raised their hand'**
  String voiceRoomHandRaised(String name);

  /// No description provided for @voiceRoomName.
  ///
  /// In en, this message translates to:
  /// **'Room name'**
  String get voiceRoomName;

  /// No description provided for @voiceRoomTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic (optional)'**
  String get voiceRoomTopic;

  /// No description provided for @voiceRoomNoActive.
  ///
  /// In en, this message translates to:
  /// **'No active voice rooms'**
  String get voiceRoomNoActive;

  /// No description provided for @voiceRoomConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get voiceRoomConnecting;

  /// No description provided for @usernameTitle.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameTitle;

  /// No description provided for @usernameSet.
  ///
  /// In en, this message translates to:
  /// **'Set Username'**
  String get usernameSet;

  /// No description provided for @usernameChange.
  ///
  /// In en, this message translates to:
  /// **'Change Username'**
  String get usernameChange;

  /// No description provided for @usernamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get usernamePlaceholder;

  /// No description provided for @usernameAvailable.
  ///
  /// In en, this message translates to:
  /// **'Username available'**
  String get usernameAvailable;

  /// No description provided for @usernameUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Username already taken'**
  String get usernameUnavailable;

  /// No description provided for @usernameInvalid.
  ///
  /// In en, this message translates to:
  /// **'3-30 characters, lowercase letters, numbers, underscore. Must start with a letter.'**
  String get usernameInvalid;

  /// No description provided for @usernameReserved.
  ///
  /// In en, this message translates to:
  /// **'This username is reserved'**
  String get usernameReserved;

  /// No description provided for @usernameSaved.
  ///
  /// In en, this message translates to:
  /// **'Username saved'**
  String get usernameSaved;

  /// No description provided for @usernameSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by @username'**
  String get usernameSearchHint;

  /// No description provided for @ensName.
  ///
  /// In en, this message translates to:
  /// **'ENS Name'**
  String get ensName;

  /// No description provided for @ensLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked to ENS'**
  String get ensLinked;

  /// No description provided for @ensResolving.
  ///
  /// In en, this message translates to:
  /// **'Resolving ENS...'**
  String get ensResolving;

  /// No description provided for @ensNotFound.
  ///
  /// In en, this message translates to:
  /// **'ENS name not found'**
  String get ensNotFound;

  /// No description provided for @tokenGateTitle.
  ///
  /// In en, this message translates to:
  /// **'Token Gate'**
  String get tokenGateTitle;

  /// No description provided for @tokenGateEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable Token Gate'**
  String get tokenGateEnable;

  /// No description provided for @tokenGateDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable Token Gate'**
  String get tokenGateDisable;

  /// No description provided for @tokenGateAddRule.
  ///
  /// In en, this message translates to:
  /// **'Add Rule'**
  String get tokenGateAddRule;

  /// No description provided for @tokenGateRemoveRule.
  ///
  /// In en, this message translates to:
  /// **'Remove Rule'**
  String get tokenGateRemoveRule;

  /// No description provided for @tokenGateContractAddress.
  ///
  /// In en, this message translates to:
  /// **'Contract Address'**
  String get tokenGateContractAddress;

  /// No description provided for @tokenGateMinBalance.
  ///
  /// In en, this message translates to:
  /// **'Minimum Balance'**
  String get tokenGateMinBalance;

  /// No description provided for @tokenGateTokenId.
  ///
  /// In en, this message translates to:
  /// **'Token ID (ERC-1155)'**
  String get tokenGateTokenId;

  /// No description provided for @tokenGateChainId.
  ///
  /// In en, this message translates to:
  /// **'Chain ID'**
  String get tokenGateChainId;

  /// No description provided for @tokenGateVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying token holdings...'**
  String get tokenGateVerifying;

  /// No description provided for @tokenGateVerified.
  ///
  /// In en, this message translates to:
  /// **'Verification passed'**
  String get tokenGateVerified;

  /// No description provided for @tokenGateDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not meet the token requirements'**
  String get tokenGateDenied;

  /// No description provided for @tokenGateOperatorAnd.
  ///
  /// In en, this message translates to:
  /// **'Must meet ALL rules'**
  String get tokenGateOperatorAnd;

  /// No description provided for @tokenGateOperatorOr.
  ///
  /// In en, this message translates to:
  /// **'Must meet ANY rule'**
  String get tokenGateOperatorOr;

  /// No description provided for @tokenGateRuleErc20.
  ///
  /// In en, this message translates to:
  /// **'ERC-20 Token'**
  String get tokenGateRuleErc20;

  /// No description provided for @tokenGateRuleErc721.
  ///
  /// In en, this message translates to:
  /// **'NFT (ERC-721)'**
  String get tokenGateRuleErc721;

  /// No description provided for @tokenGateRuleErc1155.
  ///
  /// In en, this message translates to:
  /// **'Multi-Token (ERC-1155)'**
  String get tokenGateRuleErc1155;

  /// No description provided for @tokenGateRuleNative.
  ///
  /// In en, this message translates to:
  /// **'Native Token'**
  String get tokenGateRuleNative;

  /// No description provided for @tokenGateSaved.
  ///
  /// In en, this message translates to:
  /// **'Token gate saved'**
  String get tokenGateSaved;

  /// No description provided for @tokenGateEnableDescription.
  ///
  /// In en, this message translates to:
  /// **'Require members to hold tokens to join'**
  String get tokenGateEnableDescription;

  /// No description provided for @tokenGateOperator.
  ///
  /// In en, this message translates to:
  /// **'Rule Logic'**
  String get tokenGateOperator;

  /// No description provided for @tokenGateRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get tokenGateRules;

  /// No description provided for @tokenGateSymbol.
  ///
  /// In en, this message translates to:
  /// **'Symbol (optional)'**
  String get tokenGateSymbol;

  /// No description provided for @tokenGateChain.
  ///
  /// In en, this message translates to:
  /// **'Chain'**
  String get tokenGateChain;

  /// No description provided for @tokenGateTokenStandard.
  ///
  /// In en, this message translates to:
  /// **'Token Standard'**
  String get tokenGateTokenStandard;

  /// No description provided for @tokenGateDenialMessage.
  ///
  /// In en, this message translates to:
  /// **'Denial Message'**
  String get tokenGateDenialMessage;

  /// No description provided for @tokenGateDenialMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Message shown when verification fails'**
  String get tokenGateDenialMessageHint;

  /// No description provided for @tokenGateVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Token Verification'**
  String get tokenGateVerifyTitle;

  /// No description provided for @tokenGateVerifyPassed.
  ///
  /// In en, this message translates to:
  /// **'Verification Passed'**
  String get tokenGateVerifyPassed;

  /// No description provided for @tokenGateVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification Failed'**
  String get tokenGateVerifyFailed;

  /// No description provided for @tokenGateRetryVerify.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get tokenGateRetryVerify;

  /// No description provided for @tokenGateRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get tokenGateRequired;

  /// No description provided for @tokenGateYourBalance.
  ///
  /// In en, this message translates to:
  /// **'Your balance'**
  String get tokenGateYourBalance;

  /// No description provided for @tokenGateRulesActive.
  ///
  /// In en, this message translates to:
  /// **'rules active'**
  String get tokenGateRulesActive;

  /// No description provided for @tokenGateDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get tokenGateDisabled;

  /// No description provided for @ensNotBound.
  ///
  /// In en, this message translates to:
  /// **'Not bound'**
  String get ensNotBound;

  /// No description provided for @liveLocation.
  ///
  /// In en, this message translates to:
  /// **'Live Location'**
  String get liveLocation;

  /// No description provided for @stopLiveLocation.
  ///
  /// In en, this message translates to:
  /// **'Stop Sharing'**
  String get stopLiveLocation;

  /// No description provided for @startLiveLocation.
  ///
  /// In en, this message translates to:
  /// **'Start Sharing'**
  String get startLiveLocation;

  /// No description provided for @selectDuration.
  ///
  /// In en, this message translates to:
  /// **'Select Duration'**
  String get selectDuration;

  /// No description provided for @groupChatFiles.
  ///
  /// In en, this message translates to:
  /// **'Chat Files'**
  String get groupChatFiles;

  /// No description provided for @groupLinks.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get groupLinks;

  /// No description provided for @groupNoLinks.
  ///
  /// In en, this message translates to:
  /// **'No links yet'**
  String get groupNoLinks;

  /// No description provided for @chatBackground.
  ///
  /// In en, this message translates to:
  /// **'Chat Background'**
  String get chatBackground;

  /// No description provided for @solidColors.
  ///
  /// In en, this message translates to:
  /// **'Solid Colors'**
  String get solidColors;

  /// No description provided for @gradients.
  ///
  /// In en, this message translates to:
  /// **'Gradients'**
  String get gradients;

  /// No description provided for @defaultBackground.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultBackground;

  /// No description provided for @settingsFontSizeSlider.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get settingsFontSizeSlider;

  /// No description provided for @autoDownload.
  ///
  /// In en, this message translates to:
  /// **'Auto-Download'**
  String get autoDownload;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @mobileData.
  ///
  /// In en, this message translates to:
  /// **'Mobile Data'**
  String get mobileData;

  /// No description provided for @roaming.
  ///
  /// In en, this message translates to:
  /// **'Roaming'**
  String get roaming;

  /// No description provided for @storageManagement.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storageManagement;

  /// No description provided for @totalUsage.
  ///
  /// In en, this message translates to:
  /// **'Total Usage'**
  String get totalUsage;

  /// No description provided for @cache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get cache;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get cacheCleared;

  /// No description provided for @clearCacheFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear cache'**
  String get clearCacheFailed;

  /// No description provided for @confirmClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear all cache data?'**
  String get confirmClearCache;

  /// No description provided for @mapView.
  ///
  /// In en, this message translates to:
  /// **'Map View'**
  String get mapView;

  /// No description provided for @liveLocationSharingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} people sharing location'**
  String liveLocationSharingCount(int count);

  /// No description provided for @minutes15.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get minutes15;

  /// No description provided for @minutes30.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get minutes30;

  /// No description provided for @hour1.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get hour1;

  /// No description provided for @hours8.
  ///
  /// In en, this message translates to:
  /// **'8 hours'**
  String get hours8;

  /// No description provided for @personalCard.
  ///
  /// In en, this message translates to:
  /// **'Personal Card'**
  String get personalCard;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadFailed;

  /// No description provided for @locationExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get locationExpired;

  /// No description provided for @secondsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count}s'**
  String secondsRemaining(int count);

  /// No description provided for @minutesRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count}min'**
  String minutesRemaining(int count);

  /// No description provided for @hoursMinutesRemaining.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}min'**
  String hoursMinutesRemaining(int hours, int minutes);

  /// No description provided for @favoriteMessages.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoriteMessages;

  /// No description provided for @linksCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linksCopied;

  /// No description provided for @noLinksFound.
  ///
  /// In en, this message translates to:
  /// **'No links found'**
  String get noLinksFound;

  /// No description provided for @roomStorageRanking.
  ///
  /// In en, this message translates to:
  /// **'Room Storage Ranking'**
  String get roomStorageRanking;

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Download complete'**
  String get downloadComplete;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get draftSaved;

  /// No description provided for @voiceRecording.
  ///
  /// In en, this message translates to:
  /// **'Voice Recording'**
  String get voiceRecording;

  /// No description provided for @searchLocation.
  ///
  /// In en, this message translates to:
  /// **'Search Location'**
  String get searchLocation;

  /// No description provided for @tapToSearch.
  ///
  /// In en, this message translates to:
  /// **'Tap to search'**
  String get tapToSearch;

  /// No description provided for @settingsThisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get settingsThisDevice;

  /// No description provided for @settingsJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get settingsJustNow;

  /// No description provided for @settingsDeviceId.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get settingsDeviceId;

  /// No description provided for @settingsStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get settingsStatus;

  /// No description provided for @settingsLastActive.
  ///
  /// In en, this message translates to:
  /// **'Last active'**
  String get settingsLastActive;

  /// No description provided for @settingsIpAddress.
  ///
  /// In en, this message translates to:
  /// **'IP address'**
  String get settingsIpAddress;

  /// No description provided for @settingsRenameDevice.
  ///
  /// In en, this message translates to:
  /// **'Rename device'**
  String get settingsRenameDevice;

  /// No description provided for @settingsDeviceNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter device name'**
  String get settingsDeviceNameHint;

  /// No description provided for @settingsDeviceRenamed.
  ///
  /// In en, this message translates to:
  /// **'Device renamed'**
  String get settingsDeviceRenamed;

  /// No description provided for @settingsRenameFailed.
  ///
  /// In en, this message translates to:
  /// **'Rename failed'**
  String get settingsRenameFailed;

  /// No description provided for @settingsRemoteLogout.
  ///
  /// In en, this message translates to:
  /// **'Remote logout'**
  String get settingsRemoteLogout;

  /// No description provided for @settingsRemoteLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out \"{deviceName}\"? This action cannot be undone.'**
  String settingsRemoteLogoutConfirm(String deviceName);

  /// No description provided for @settingsDeviceLoggedOut.
  ///
  /// In en, this message translates to:
  /// **'Device logged out'**
  String get settingsDeviceLoggedOut;

  /// No description provided for @settingsLogoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed'**
  String get settingsLogoutFailed;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @settingsVerifyIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify identity'**
  String get settingsVerifyIdentity;

  /// No description provided for @settingsEnterPasswordToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm this action.'**
  String get settingsEnterPasswordToConfirm;

  /// No description provided for @scheduledSendTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule message'**
  String get scheduledSendTitle;

  /// No description provided for @scheduledSendInOneHour.
  ///
  /// In en, this message translates to:
  /// **'In 1 hour'**
  String get scheduledSendInOneHour;

  /// No description provided for @scheduledSendTonight.
  ///
  /// In en, this message translates to:
  /// **'Tonight (8:00 PM)'**
  String get scheduledSendTonight;

  /// No description provided for @scheduledSendTomorrowMorning.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow morning (9:00 AM)'**
  String get scheduledSendTomorrowMorning;

  /// No description provided for @scheduledSendCustom.
  ///
  /// In en, this message translates to:
  /// **'Pick a date & time'**
  String get scheduledSendCustom;

  /// No description provided for @scheduledMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduledMessageLabel;

  /// No description provided for @scheduledMessageCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel scheduled message'**
  String get scheduledMessageCancel;

  /// No description provided for @chatLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat lock'**
  String get chatLockTitle;

  /// No description provided for @chatLockEnable.
  ///
  /// In en, this message translates to:
  /// **'Lock this chat'**
  String get chatLockEnable;

  /// No description provided for @chatLockDisable.
  ///
  /// In en, this message translates to:
  /// **'Unlock this chat'**
  String get chatLockDisable;

  /// No description provided for @chatLockDescription.
  ///
  /// In en, this message translates to:
  /// **'Locked chats require biometric or PIN verification to open'**
  String get chatLockDescription;

  /// No description provided for @chatLockVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat locked'**
  String get chatLockVerifyTitle;

  /// No description provided for @chatLockVerifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify to access this chat'**
  String get chatLockVerifySubtitle;

  /// No description provided for @chatLockVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get chatLockVerifyFailed;

  /// No description provided for @chatLockEnabled.
  ///
  /// In en, this message translates to:
  /// **'Chat locked'**
  String get chatLockEnabled;

  /// No description provided for @chatLockDisabled.
  ///
  /// In en, this message translates to:
  /// **'Chat unlocked'**
  String get chatLockDisabled;

  /// No description provided for @chatLockPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get chatLockPinTitle;

  /// No description provided for @chatLockPinSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get chatLockPinSetTitle;

  /// No description provided for @chatLockPinConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get chatLockPinConfirmTitle;

  /// No description provided for @chatLockPinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PIN does not match'**
  String get chatLockPinMismatch;

  /// No description provided for @chatLockUseBiometric.
  ///
  /// In en, this message translates to:
  /// **'Use biometric'**
  String get chatLockUseBiometric;

  /// No description provided for @chatLockUsePin.
  ///
  /// In en, this message translates to:
  /// **'Use PIN'**
  String get chatLockUsePin;

  /// No description provided for @mediaEditorUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get mediaEditorUndo;

  /// No description provided for @mediaEditorRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get mediaEditorRedo;

  /// No description provided for @mediaEditorCrop.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get mediaEditorCrop;

  /// No description provided for @mediaEditorFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get mediaEditorFilter;

  /// No description provided for @mediaEditorDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get mediaEditorDraw;

  /// No description provided for @mediaEditorText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get mediaEditorText;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @aiAssistantWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m the N42 AI Assistant. How can I help you?'**
  String get aiAssistantWelcome;

  /// No description provided for @aiAssistantNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'AI service not configured'**
  String get aiAssistantNotConfigured;

  /// No description provided for @aiAssistantSettings.
  ///
  /// In en, this message translates to:
  /// **'AI Settings'**
  String get aiAssistantSettings;

  /// No description provided for @aiAssistantClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear chat history'**
  String get aiAssistantClearHistory;

  /// No description provided for @aiAssistantClearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all AI chat history?'**
  String get aiAssistantClearHistoryConfirm;

  /// No description provided for @aiAssistantStopGenerating.
  ///
  /// In en, this message translates to:
  /// **'Stop generating'**
  String get aiAssistantStopGenerating;

  /// No description provided for @aiAssistantModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get aiAssistantModel;

  /// No description provided for @aiAssistantTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get aiAssistantTemperature;

  /// No description provided for @aiAssistantMaxTokens.
  ///
  /// In en, this message translates to:
  /// **'Max tokens'**
  String get aiAssistantMaxTokens;

  /// No description provided for @aiAssistantContextWindow.
  ///
  /// In en, this message translates to:
  /// **'Context window'**
  String get aiAssistantContextWindow;

  /// No description provided for @aiAssistantServiceStatus.
  ///
  /// In en, this message translates to:
  /// **'Service status'**
  String get aiAssistantServiceStatus;

  /// No description provided for @aiAssistantAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get aiAssistantAvailable;

  /// No description provided for @aiAssistantUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get aiAssistantUnavailable;

  /// No description provided for @aiSummarize.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get aiSummarize;

  /// No description provided for @aiSummarizeUnread.
  ///
  /// In en, this message translates to:
  /// **'Summarize {count} unread messages'**
  String aiSummarizeUnread(int count);

  /// No description provided for @aiSummarizeLoading.
  ///
  /// In en, this message translates to:
  /// **'Summarizing...'**
  String get aiSummarizeLoading;

  /// No description provided for @aiSummarizeError.
  ///
  /// In en, this message translates to:
  /// **'Failed to summarize'**
  String get aiSummarizeError;

  /// No description provided for @aiRewrite.
  ///
  /// In en, this message translates to:
  /// **'AI Rewrite'**
  String get aiRewrite;

  /// No description provided for @aiRewriteFormal.
  ///
  /// In en, this message translates to:
  /// **'Formal'**
  String get aiRewriteFormal;

  /// No description provided for @aiRewriteCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get aiRewriteCasual;

  /// No description provided for @aiRewritePlayful.
  ///
  /// In en, this message translates to:
  /// **'Playful'**
  String get aiRewritePlayful;

  /// No description provided for @aiRewriteProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get aiRewriteProfessional;

  /// No description provided for @aiRewriteAccept.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get aiRewriteAccept;

  /// No description provided for @aiRewriteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get aiRewriteCancel;

  /// No description provided for @aiRewriteLoading.
  ///
  /// In en, this message translates to:
  /// **'Rewriting...'**
  String get aiRewriteLoading;

  /// No description provided for @aiLinkSummary.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get aiLinkSummary;

  /// No description provided for @aiLinkSummaryAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get aiLinkSummaryAnalyzing;

  /// No description provided for @chatFolderManagement.
  ///
  /// In en, this message translates to:
  /// **'Manage Folders'**
  String get chatFolderManagement;

  /// No description provided for @chatFolderSystem.
  ///
  /// In en, this message translates to:
  /// **'System Folders'**
  String get chatFolderSystem;

  /// No description provided for @chatFolderCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom Folders'**
  String get chatFolderCustom;

  /// No description provided for @chatFolderEmpty.
  ///
  /// In en, this message translates to:
  /// **'No custom folders yet'**
  String get chatFolderEmpty;

  /// No description provided for @chatFolderCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Folder'**
  String get chatFolderCreate;

  /// No description provided for @chatFolderEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Folder'**
  String get chatFolderEdit;

  /// No description provided for @chatFolderNameHint.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get chatFolderNameHint;

  /// No description provided for @chatFolderAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get chatFolderAll;

  /// No description provided for @chatFolderUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get chatFolderUnread;

  /// No description provided for @chatFolderPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get chatFolderPersonal;

  /// No description provided for @chatFolderGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get chatFolderGroups;

  /// No description provided for @chatFolderChannels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get chatFolderChannels;

  /// No description provided for @chatFolderMuted.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get chatFolderMuted;

  /// No description provided for @storyAddMusic.
  ///
  /// In en, this message translates to:
  /// **'Add Music'**
  String get storyAddMusic;

  /// No description provided for @storyChangeMusic.
  ///
  /// In en, this message translates to:
  /// **'Change Music'**
  String get storyChangeMusic;

  /// No description provided for @storyBackgroundMusic.
  ///
  /// In en, this message translates to:
  /// **'Background Music'**
  String get storyBackgroundMusic;

  /// No description provided for @storyMusicPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview (max 15s)'**
  String get storyMusicPreview;

  /// No description provided for @storyChooseFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Choose from Device'**
  String get storyChooseFromDevice;

  /// No description provided for @storyUseThisMusic.
  ///
  /// In en, this message translates to:
  /// **'Use This Music'**
  String get storyUseThisMusic;

  /// No description provided for @authPasskeyNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Passkey is not supported on this device'**
  String get authPasskeyNotSupported;

  /// No description provided for @authPasskeyRegister.
  ///
  /// In en, this message translates to:
  /// **'Register Passkey'**
  String get authPasskeyRegister;

  /// No description provided for @authPasskeyNoRegistered.
  ///
  /// In en, this message translates to:
  /// **'No passkeys registered'**
  String get authPasskeyNoRegistered;

  /// No description provided for @authPasskeyRegisterHint.
  ///
  /// In en, this message translates to:
  /// **'Register a passkey for this account. Standalone passkey sign-in will be enabled later.'**
  String get authPasskeyRegisterHint;

  /// No description provided for @authPasskeyNameYours.
  ///
  /// In en, this message translates to:
  /// **'Name your Passkey'**
  String get authPasskeyNameYours;

  /// No description provided for @authPasskeyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Passkey saved to this account'**
  String get authPasskeyRegistered;

  /// No description provided for @authPasskeyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Passkey removed from this account'**
  String get authPasskeyDeleted;

  /// No description provided for @authPasskeyDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete passkey \"{name}\"? You will need to register it again before using passkey sign-in later.'**
  String authPasskeyDeleteConfirm(String name);

  /// No description provided for @momentVisibilityPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get momentVisibilityPublic;

  /// No description provided for @momentVisibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get momentVisibilityPrivate;

  /// No description provided for @momentVisibilityPartial.
  ///
  /// In en, this message translates to:
  /// **'Selected Friends'**
  String get momentVisibilityPartial;

  /// No description provided for @momentVisibilityExcluded.
  ///
  /// In en, this message translates to:
  /// **'Exclude Some Friends'**
  String get momentVisibilityExcluded;

  /// No description provided for @momentUserMoments.
  ///
  /// In en, this message translates to:
  /// **'{userName}\'s Moments'**
  String momentUserMoments(String userName);

  /// No description provided for @momentForwardTo.
  ///
  /// In en, this message translates to:
  /// **'Forward to'**
  String get momentForwardTo;

  /// No description provided for @momentForwardSuccess.
  ///
  /// In en, this message translates to:
  /// **'Forwarded successfully'**
  String get momentForwardSuccess;

  /// No description provided for @momentSelectFriends.
  ///
  /// In en, this message translates to:
  /// **'Select Friends'**
  String get momentSelectFriends;

  /// No description provided for @momentSelectTags.
  ///
  /// In en, this message translates to:
  /// **'Select by Tags'**
  String get momentSelectTags;

  /// No description provided for @momentSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'Selected ({count})'**
  String momentSelectedCount(int count);

  /// No description provided for @momentNoMomentsYet.
  ///
  /// In en, this message translates to:
  /// **'No moments yet'**
  String get momentNoMomentsYet;

  /// No description provided for @momentForwardMoment.
  ///
  /// In en, this message translates to:
  /// **'Forward Moment'**
  String get momentForwardMoment;

  /// No description provided for @momentAddComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get momentAddComment;

  /// No description provided for @momentForwardContent.
  ///
  /// In en, this message translates to:
  /// **'[Moment] {content}'**
  String momentForwardContent(String content);

  /// No description provided for @momentDeleteMoment.
  ///
  /// In en, this message translates to:
  /// **'Delete Moment'**
  String get momentDeleteMoment;

  /// No description provided for @momentDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this moment?'**
  String get momentDeleteConfirm;

  /// No description provided for @momentComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get momentComment;

  /// No description provided for @momentWriteComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get momentWriteComment;

  /// No description provided for @momentLike.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get momentLike;

  /// No description provided for @momentUnlike.
  ///
  /// In en, this message translates to:
  /// **'Unlike'**
  String get momentUnlike;

  /// No description provided for @momentForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get momentForward;

  /// No description provided for @momentDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get momentDelete;

  /// No description provided for @momentReply.
  ///
  /// In en, this message translates to:
  /// **'reply'**
  String get momentReply;

  /// No description provided for @momentMoment.
  ///
  /// In en, this message translates to:
  /// **'Moment'**
  String get momentMoment;

  /// No description provided for @momentLikesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} likes'**
  String momentLikesCount(int count);

  /// No description provided for @momentCommentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} comments'**
  String momentCommentsCount(int count);

  /// No description provided for @momentNoComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get momentNoComments;

  /// No description provided for @momentFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get momentFailedToLoad;

  /// No description provided for @momentReplyTo.
  ///
  /// In en, this message translates to:
  /// **'Reply to {userName}...'**
  String momentReplyTo(String userName);

  /// No description provided for @momentNoConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations'**
  String get momentNoConversations;

  /// No description provided for @momentJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get momentJustNow;

  /// No description provided for @momentMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String momentMinutesAgo(int count);

  /// No description provided for @momentHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String momentHoursAgo(int count);

  /// No description provided for @momentDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String momentDaysAgo(int count);

  /// No description provided for @chatGroupAnnouncementHint.
  ///
  /// In en, this message translates to:
  /// **'Enter group announcement'**
  String get chatGroupAnnouncementHint;

  /// No description provided for @chatGroupAnnouncementEmpty.
  ///
  /// In en, this message translates to:
  /// **'No announcement'**
  String get chatGroupAnnouncementEmpty;

  /// No description provided for @chatEditNickname.
  ///
  /// In en, this message translates to:
  /// **'Edit Nickname'**
  String get chatEditNickname;

  /// No description provided for @chatNicknameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your nickname in this group'**
  String get chatNicknameHint;

  /// No description provided for @contactAddPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get contactAddPhoneHint;

  /// No description provided for @contactNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add notes about this contact'**
  String get contactNotesHint;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportTitle;

  /// No description provided for @reportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get reportReasonHarassment;

  /// No description provided for @reportReasonFraud.
  ///
  /// In en, this message translates to:
  /// **'Fraud'**
  String get reportReasonFraud;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportReasonOther;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted'**
  String get reportSubmitted;

  /// No description provided for @reportDescription.
  ///
  /// In en, this message translates to:
  /// **'Additional description (optional)'**
  String get reportDescription;

  /// No description provided for @qrcodeSaved.
  ///
  /// In en, this message translates to:
  /// **'QR code saved to album'**
  String get qrcodeSaved;

  /// No description provided for @chatSendRedPacketInChat.
  ///
  /// In en, this message translates to:
  /// **'Please send red packet in chat'**
  String get chatSendRedPacketInChat;

  /// No description provided for @commonSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get commonSaveFailed;

  /// No description provided for @reportSelectReason.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason'**
  String get reportSelectReason;

  /// No description provided for @gameCenter.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get gameCenter;

  /// No description provided for @gameHighScore.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get gameHighScore;

  /// No description provided for @gameScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get gameScore;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @gamePlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get gamePlayAgain;

  /// No description provided for @gameLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get gameLeaderboard;

  /// No description provided for @gamePause.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get gamePause;

  /// No description provided for @gameResume.
  ///
  /// In en, this message translates to:
  /// **'Tap to resume'**
  String get gameResume;

  /// No description provided for @gameConfirmExit.
  ///
  /// In en, this message translates to:
  /// **'Quit this game?'**
  String get gameConfirmExit;

  /// No description provided for @gameNoScores.
  ///
  /// In en, this message translates to:
  /// **'No scores yet'**
  String get gameNoScores;

  /// No description provided for @game2048.
  ///
  /// In en, this message translates to:
  /// **'2048'**
  String get game2048;

  /// No description provided for @game2048Desc.
  ///
  /// In en, this message translates to:
  /// **'Merge tiles to reach 2048'**
  String get game2048Desc;

  /// No description provided for @gameBlockDrop.
  ///
  /// In en, this message translates to:
  /// **'Block Drop'**
  String get gameBlockDrop;

  /// No description provided for @gameBlockDropDesc.
  ///
  /// In en, this message translates to:
  /// **'Drop and clear lines'**
  String get gameBlockDropDesc;

  /// No description provided for @gameMinesweeper.
  ///
  /// In en, this message translates to:
  /// **'Minesweeper'**
  String get gameMinesweeper;

  /// No description provided for @gameMinesweeperDesc.
  ///
  /// In en, this message translates to:
  /// **'Find all safe cells'**
  String get gameMinesweeperDesc;

  /// No description provided for @gameMatch3.
  ///
  /// In en, this message translates to:
  /// **'Match 3'**
  String get gameMatch3;

  /// No description provided for @gameMatch3Desc.
  ///
  /// In en, this message translates to:
  /// **'Match 3 or more gems'**
  String get gameMatch3Desc;

  /// No description provided for @gameMinesweeperEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get gameMinesweeperEasy;

  /// No description provided for @gameMinesweeperMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get gameMinesweeperMedium;

  /// No description provided for @gameMinesLeft.
  ///
  /// In en, this message translates to:
  /// **'Mines Left'**
  String get gameMinesLeft;

  /// No description provided for @gameTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get gameTimeLeft;

  /// No description provided for @gameLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get gameLevel;

  /// No description provided for @gameNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get gameNext;

  /// No description provided for @gameBestTime.
  ///
  /// In en, this message translates to:
  /// **'Best Time'**
  String get gameBestTime;

  /// No description provided for @gameNewRecord.
  ///
  /// In en, this message translates to:
  /// **'New Record!'**
  String get gameNewRecord;

  /// No description provided for @gameLines.
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get gameLines;

  /// No description provided for @storyMyStory.
  ///
  /// In en, this message translates to:
  /// **'My Story'**
  String get storyMyStory;

  /// No description provided for @storageSmartCleanup.
  ///
  /// In en, this message translates to:
  /// **'Smart Cleanup'**
  String get storageSmartCleanup;

  /// No description provided for @storageOldMediaFiles.
  ///
  /// In en, this message translates to:
  /// **'Old Media Files'**
  String get storageOldMediaFiles;

  /// No description provided for @storageLargeFiles.
  ///
  /// In en, this message translates to:
  /// **'Large Files'**
  String get storageLargeFiles;

  /// No description provided for @storageAppCache.
  ///
  /// In en, this message translates to:
  /// **'App Cache'**
  String get storageAppCache;

  /// No description provided for @storageSettings.
  ///
  /// In en, this message translates to:
  /// **'Storage Settings'**
  String get storageSettings;

  /// No description provided for @storageAutoCleanup.
  ///
  /// In en, this message translates to:
  /// **'Auto Cleanup'**
  String get storageAutoCleanup;

  /// No description provided for @storageAutoCleanupDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically clean files older than {days} days'**
  String storageAutoCleanupDesc(int days);

  /// No description provided for @storageCleanupPeriod.
  ///
  /// In en, this message translates to:
  /// **'Cleanup Period'**
  String get storageCleanupPeriod;

  /// No description provided for @storagePreserveThumbnails.
  ///
  /// In en, this message translates to:
  /// **'Preserve Thumbnails'**
  String get storagePreserveThumbnails;

  /// No description provided for @storagePreserveThumbnailsDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep image thumbnails during cleanup'**
  String get storagePreserveThumbnailsDesc;

  /// No description provided for @storageWarningHigh.
  ///
  /// In en, this message translates to:
  /// **'Storage usage is high. Consider cleaning up old files.'**
  String get storageWarningHigh;

  /// No description provided for @storageWarningCritical.
  ///
  /// In en, this message translates to:
  /// **'Storage is critically low. Please clean up to free space.'**
  String get storageWarningCritical;

  /// No description provided for @storageFreed.
  ///
  /// In en, this message translates to:
  /// **'Freed {size} ({count} files)'**
  String storageFreed(String size, int count);

  /// No description provided for @storageDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String storageDays(int days);

  /// No description provided for @storageViewAllRooms.
  ///
  /// In en, this message translates to:
  /// **'View all {count} rooms'**
  String storageViewAllRooms(int count);

  /// No description provided for @storageNoFiles.
  ///
  /// In en, this message translates to:
  /// **'No files found'**
  String get storageNoFiles;

  /// No description provided for @storageFilePinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get storageFilePinned;

  /// No description provided for @storageDeleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} selected files? They can be re-downloaded from the server.'**
  String storageDeleteSelected(int count);

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// No description provided for @backupCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get backupCreate;

  /// No description provided for @backupCreateDesc.
  ///
  /// In en, this message translates to:
  /// **'Backup your settings and encryption keys. Messages will be restored from server after re-login.'**
  String get backupCreateDesc;

  /// No description provided for @backupIncludeKeys.
  ///
  /// In en, this message translates to:
  /// **'Include encryption keys'**
  String get backupIncludeKeys;

  /// No description provided for @backupIncludeKeysDesc.
  ///
  /// In en, this message translates to:
  /// **'Required for reading encrypted messages'**
  String get backupIncludeKeysDesc;

  /// No description provided for @backupPasswordProtect.
  ///
  /// In en, this message translates to:
  /// **'Password protect'**
  String get backupPasswordProtect;

  /// No description provided for @backupEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter backup password'**
  String get backupEnterPassword;

  /// No description provided for @backupHistory.
  ///
  /// In en, this message translates to:
  /// **'Backup History'**
  String get backupHistory;

  /// No description provided for @backupNoBackups.
  ///
  /// In en, this message translates to:
  /// **'No backups yet'**
  String get backupNoBackups;

  /// No description provided for @backupRestore2.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupRestore2;

  /// No description provided for @backupDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get backupDelete;

  /// No description provided for @backupDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this backup? This cannot be undone.'**
  String get backupDeleteConfirm;

  /// No description provided for @backupRestoreFromFile.
  ///
  /// In en, this message translates to:
  /// **'Restore from File'**
  String get backupRestoreFromFile;

  /// No description provided for @backupRestoreFromFileDesc.
  ///
  /// In en, this message translates to:
  /// **'Import a .n42backup file from another device or previous backup.'**
  String get backupRestoreFromFileDesc;

  /// No description provided for @backupChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose Backup File'**
  String get backupChooseFile;

  /// No description provided for @backupRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring...'**
  String get backupRestoring;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Backup created: {rooms} rooms, {messages} messages'**
  String backupCreated(int rooms, int messages);

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored {settings} settings from {rooms} rooms'**
  String backupRestored(int settings, int rooms);

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(String error);

  /// No description provided for @backupPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'This backup is password-protected'**
  String get backupPasswordRequired;

  /// No description provided for @blocGroupNotFound.
  ///
  /// In en, this message translates to:
  /// **'Group not found'**
  String get blocGroupNotFound;

  /// No description provided for @blocGroupMembersInvited.
  ///
  /// In en, this message translates to:
  /// **'Invited {count} member(s)'**
  String blocGroupMembersInvited(int count);

  /// No description provided for @blocGroupMemberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Member removed'**
  String get blocGroupMemberRemoved;

  /// No description provided for @blocGroupAdminRemoved.
  ///
  /// In en, this message translates to:
  /// **'Admin removed'**
  String get blocGroupAdminRemoved;

  /// No description provided for @blocGroupLeft.
  ///
  /// In en, this message translates to:
  /// **'Left the group'**
  String get blocGroupLeft;

  /// No description provided for @blocGroupDisbanded.
  ///
  /// In en, this message translates to:
  /// **'Group disbanded'**
  String get blocGroupDisbanded;

  /// No description provided for @blocGroupJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined the group'**
  String get blocGroupJoined;

  /// No description provided for @blocGroupInviteDeclined.
  ///
  /// In en, this message translates to:
  /// **'Invitation declined'**
  String get blocGroupInviteDeclined;

  /// No description provided for @blocGroupTokenGateUpdated.
  ///
  /// In en, this message translates to:
  /// **'Token gate updated'**
  String get blocGroupTokenGateUpdated;

  /// No description provided for @blocTransferProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing transfer...'**
  String get blocTransferProcessing;

  /// No description provided for @blocTransferCancelled.
  ///
  /// In en, this message translates to:
  /// **'Transfer cancelled'**
  String get blocTransferCancelled;

  /// No description provided for @blocTransferFailed.
  ///
  /// In en, this message translates to:
  /// **'Transfer failed'**
  String get blocTransferFailed;

  /// No description provided for @blocPaymentProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get blocPaymentProcessing;

  /// No description provided for @blocPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get blocPaymentFailed;

  /// No description provided for @groupMaxMembers.
  ///
  /// In en, this message translates to:
  /// **'Member Limit'**
  String get groupMaxMembers;

  /// No description provided for @groupMaxMembersUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get groupMaxMembersUnlimited;

  /// No description provided for @groupMaxMembersHint.
  ///
  /// In en, this message translates to:
  /// **'Enter limit (leave empty for unlimited)'**
  String get groupMaxMembersHint;

  /// No description provided for @groupMaxMembersUpdated.
  ///
  /// In en, this message translates to:
  /// **'Member limit updated'**
  String get groupMaxMembersUpdated;

  /// No description provided for @groupFull.
  ///
  /// In en, this message translates to:
  /// **'Group is at capacity'**
  String get groupFull;

  /// No description provided for @groupChannels.
  ///
  /// In en, this message translates to:
  /// **'Topic Channels'**
  String get groupChannels;

  /// No description provided for @groupChannelsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No channels yet'**
  String get groupChannelsEmpty;

  /// No description provided for @groupChannelsCount.
  ///
  /// In en, this message translates to:
  /// **'channels'**
  String get groupChannelsCount;

  /// No description provided for @groupChannelCreate.
  ///
  /// In en, this message translates to:
  /// **'New Channel'**
  String get groupChannelCreate;

  /// No description provided for @groupChannelName.
  ///
  /// In en, this message translates to:
  /// **'Channel Name'**
  String get groupChannelName;

  /// No description provided for @groupChannelTopic.
  ///
  /// In en, this message translates to:
  /// **'Channel Topic (optional)'**
  String get groupChannelTopic;

  /// No description provided for @groupChannelDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Channel'**
  String get groupChannelDelete;

  /// No description provided for @groupChannelDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this channel? All messages will be lost.'**
  String get groupChannelDeleteConfirm;

  /// No description provided for @groupBotSettings.
  ///
  /// In en, this message translates to:
  /// **'Bot Settings'**
  String get groupBotSettings;

  /// No description provided for @groupBotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable Bot'**
  String get groupBotEnabled;

  /// No description provided for @groupBotWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome Message Template'**
  String get groupBotWelcomeMessage;

  /// No description provided for @groupBotWelcomeHint.
  ///
  /// In en, this message translates to:
  /// **'Use \'name\' as placeholder for new member name'**
  String get groupBotWelcomeHint;

  /// No description provided for @groupBotConfigUpdated.
  ///
  /// In en, this message translates to:
  /// **'Bot settings updated'**
  String get groupBotConfigUpdated;

  /// No description provided for @groupContentFilter.
  ///
  /// In en, this message translates to:
  /// **'Content Filter'**
  String get groupContentFilter;

  /// No description provided for @groupContentFilterEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable Keyword Filter'**
  String get groupContentFilterEnabled;

  /// No description provided for @groupContentFilterReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace with ***'**
  String get groupContentFilterReplace;

  /// No description provided for @groupContentFilterHide.
  ///
  /// In en, this message translates to:
  /// **'Hide Message'**
  String get groupContentFilterHide;

  /// No description provided for @groupContentFilterAddWord.
  ///
  /// In en, this message translates to:
  /// **'Add Keyword'**
  String get groupContentFilterAddWord;

  /// No description provided for @groupContentFilterUpdated.
  ///
  /// In en, this message translates to:
  /// **'Content filter updated'**
  String get groupContentFilterUpdated;

  /// No description provided for @chatSlashCommands.
  ///
  /// In en, this message translates to:
  /// **'Commands'**
  String get chatSlashCommands;

  /// No description provided for @chatCommandPoll.
  ///
  /// In en, this message translates to:
  /// **'/poll — Create a poll'**
  String get chatCommandPoll;

  /// No description provided for @chatCommandAnnounce.
  ///
  /// In en, this message translates to:
  /// **'/announce — Send announcement'**
  String get chatCommandAnnounce;

  /// No description provided for @chatCommandWelcome.
  ///
  /// In en, this message translates to:
  /// **'/welcome — Set welcome message'**
  String get chatCommandWelcome;

  /// No description provided for @chatReportMessage.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get chatReportMessage;

  /// No description provided for @chatReportReason.
  ///
  /// In en, this message translates to:
  /// **'Report Reason'**
  String get chatReportReason;

  /// No description provided for @chatReportSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get chatReportSpam;

  /// No description provided for @chatReportHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get chatReportHarassment;

  /// No description provided for @chatReportInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate Content'**
  String get chatReportInappropriate;

  /// No description provided for @chatReportOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get chatReportOther;

  /// No description provided for @chatReportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report submitted'**
  String get chatReportSuccess;

  /// No description provided for @spacesName.
  ///
  /// In en, this message translates to:
  /// **'Community Name'**
  String get spacesName;

  /// No description provided for @spacesNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Crypto Traders'**
  String get spacesNameHint;

  /// No description provided for @spacesNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get spacesNameRequired;

  /// No description provided for @spacesDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get spacesDescription;

  /// No description provided for @spacesDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What is this community about?'**
  String get spacesDescriptionHint;

  /// No description provided for @spacesType.
  ///
  /// In en, this message translates to:
  /// **'Community Type'**
  String get spacesType;

  /// No description provided for @spacesPublicDesc.
  ///
  /// In en, this message translates to:
  /// **'Anyone can discover and join'**
  String get spacesPublicDesc;

  /// No description provided for @spacesPrivateDesc.
  ///
  /// In en, this message translates to:
  /// **'Only invited members can join'**
  String get spacesPrivateDesc;

  /// No description provided for @spacesNotFound.
  ///
  /// In en, this message translates to:
  /// **'Community not found'**
  String get spacesNotFound;

  /// No description provided for @spacesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search communities...'**
  String get spacesSearch;

  /// No description provided for @spacesMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get spacesMembers;

  /// No description provided for @spacesNoChannels.
  ///
  /// In en, this message translates to:
  /// **'No channels yet'**
  String get spacesNoChannels;

  /// No description provided for @spacesLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave Community'**
  String get spacesLeave;

  /// No description provided for @spacesLeaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave \"{name}\"?'**
  String spacesLeaveConfirm(String name);

  /// No description provided for @spacesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Community'**
  String get spacesDelete;

  /// No description provided for @spacesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\" and all its channels. This action cannot be undone.'**
  String spacesDeleteConfirm(String name);

  /// No description provided for @spacesCreateChannel.
  ///
  /// In en, this message translates to:
  /// **'Add Channel'**
  String get spacesCreateChannel;

  /// No description provided for @spacesChannelName.
  ///
  /// In en, this message translates to:
  /// **'Channel Name'**
  String get spacesChannelName;

  /// No description provided for @spacesChannelTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic (optional)'**
  String get spacesChannelTopic;

  /// No description provided for @spacesDeleteChannel.
  ///
  /// In en, this message translates to:
  /// **'Delete Channel'**
  String get spacesDeleteChannel;

  /// No description provided for @spacesDeleteChannelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"#{name}\"?'**
  String spacesDeleteChannelConfirm(String name);

  /// No description provided for @spacesEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get spacesEditName;

  /// No description provided for @spacesEditDescription.
  ///
  /// In en, this message translates to:
  /// **'Edit Description'**
  String get spacesEditDescription;

  /// No description provided for @spacesViewAllMembers.
  ///
  /// In en, this message translates to:
  /// **'View all {count} members'**
  String spacesViewAllMembers(int count);

  /// No description provided for @spacesKickMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Kick {name}'**
  String spacesKickMemberTitle(String name);

  /// No description provided for @spacesBanMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Ban {name}'**
  String spacesBanMemberTitle(String name);

  /// No description provided for @spacesPromoteAdmin.
  ///
  /// In en, this message translates to:
  /// **'Promote to Admin'**
  String get spacesPromoteAdmin;

  /// No description provided for @spacesDemoteAdmin.
  ///
  /// In en, this message translates to:
  /// **'Remove Admin'**
  String get spacesDemoteAdmin;

  /// No description provided for @spacesInviteMember.
  ///
  /// In en, this message translates to:
  /// **'Invite Member'**
  String get spacesInviteMember;

  /// No description provided for @spacesInviteMemberUserId.
  ///
  /// In en, this message translates to:
  /// **'User ID (e.g. @user:server.com)'**
  String get spacesInviteMemberUserId;

  /// No description provided for @spacesSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get spacesSave;

  /// No description provided for @settingsScreenshotProtection.
  ///
  /// In en, this message translates to:
  /// **'Screenshot Protection'**
  String get settingsScreenshotProtection;

  /// No description provided for @settingsScreenshotProtectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Prevent screenshots and screen recording'**
  String get settingsScreenshotProtectionDesc;

  /// No description provided for @chatSelfDestructTimer.
  ///
  /// In en, this message translates to:
  /// **'Self-destruct'**
  String get chatSelfDestructTimer;

  /// No description provided for @chatTimerPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Self-destruct Timer'**
  String get chatTimerPickerTitle;

  /// No description provided for @chatTimerOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get chatTimerOff;

  /// No description provided for @onChainNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'On-chain Events'**
  String get onChainNotificationsTitle;

  /// No description provided for @onChainMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get onChainMarkAllRead;

  /// No description provided for @onChainNoNotifications.
  ///
  /// In en, this message translates to:
  /// **'No on-chain events yet'**
  String get onChainNoNotifications;

  /// No description provided for @onChainNoNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Events from subscribed channels will appear here'**
  String get onChainNoNotificationsDesc;

  /// No description provided for @onChainViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get onChainViewDetails;

  /// No description provided for @chatCommandHelp.
  ///
  /// In en, this message translates to:
  /// **'/help — Show all commands'**
  String get chatCommandHelp;

  /// No description provided for @chatCommandPrice.
  ///
  /// In en, this message translates to:
  /// **'/price — Get token price'**
  String get chatCommandPrice;

  /// No description provided for @chatCommandBalance.
  ///
  /// In en, this message translates to:
  /// **'/balance — Show wallet balance'**
  String get chatCommandBalance;

  /// No description provided for @chatCommandChains.
  ///
  /// In en, this message translates to:
  /// **'/chains — List 236+ supported chains'**
  String get chatCommandChains;

  /// No description provided for @chatMiniApps.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get chatMiniApps;

  /// No description provided for @miniAppMarketTitle.
  ///
  /// In en, this message translates to:
  /// **'Mini Apps'**
  String get miniAppMarketTitle;

  /// No description provided for @miniAppCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get miniAppCategoryAll;

  /// No description provided for @miniAppSearch.
  ///
  /// In en, this message translates to:
  /// **'Search apps...'**
  String get miniAppSearch;

  /// No description provided for @miniAppFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get miniAppFeatured;

  /// No description provided for @miniAppAllApps.
  ///
  /// In en, this message translates to:
  /// **'All Apps'**
  String get miniAppAllApps;

  /// No description provided for @miniAppNoResults.
  ///
  /// In en, this message translates to:
  /// **'No apps found'**
  String get miniAppNoResults;

  /// No description provided for @slideToPayLabel.
  ///
  /// In en, this message translates to:
  /// **'→→→  Slide to confirm'**
  String get slideToPayLabel;

  /// No description provided for @slideToPayConfirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming...'**
  String get slideToPayConfirming;

  /// No description provided for @redPacketBestLuck.
  ///
  /// In en, this message translates to:
  /// **'Best Luck'**
  String get redPacketBestLuck;

  /// No description provided for @redPacketBestLuckCongrats.
  ///
  /// In en, this message translates to:
  /// **'Best Luck! You got the most!'**
  String get redPacketBestLuckCongrats;

  /// No description provided for @redPacketStats.
  ///
  /// In en, this message translates to:
  /// **'{claimed} / {total} claimed'**
  String redPacketStats(int claimed, int total);

  /// No description provided for @redPacketStatsTotal.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get redPacketStatsTotal;

  /// No description provided for @redPacketGrabbedViral.
  ///
  /// In en, this message translates to:
  /// **'🧧 grabbed a red packet • {amount} {token}'**
  String redPacketGrabbedViral(String amount, String token);

  /// No description provided for @web3SearchHint.
  ///
  /// In en, this message translates to:
  /// **'@matrix:id  •  0x wallet address  •  name.eth'**
  String get web3SearchHint;

  /// No description provided for @web3SearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by ID, wallet, or ENS...'**
  String get web3SearchPlaceholder;

  /// No description provided for @web3WalletAddress.
  ///
  /// In en, this message translates to:
  /// **'Wallet Address'**
  String get web3WalletAddress;

  /// No description provided for @web3AddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get web3AddressCopied;

  /// No description provided for @web3Copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get web3Copy;

  /// No description provided for @web3SendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get web3SendMessage;

  /// No description provided for @web3SendToWallet.
  ///
  /// In en, this message translates to:
  /// **'Message Wallet'**
  String get web3SendToWallet;

  /// No description provided for @web3WalletOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'This address has no N42 account yet. Message will be delivered when they join.'**
  String get web3WalletOnlyHint;

  /// No description provided for @web3NftAvatar.
  ///
  /// In en, this message translates to:
  /// **'NFT Avatar'**
  String get web3NftAvatar;

  /// No description provided for @web3ResolveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to resolve identity'**
  String get web3ResolveFailed;

  /// No description provided for @web3EnsNotFound.
  ///
  /// In en, this message translates to:
  /// **'ENS name \"{name}\" not found'**
  String web3EnsNotFound(String name);

  /// No description provided for @web3NoN42AccountTitle.
  ///
  /// In en, this message translates to:
  /// **'No N42 Account'**
  String get web3NoN42AccountTitle;

  /// No description provided for @web3NoN42AccountDesc.
  ///
  /// In en, this message translates to:
  /// **'This wallet address has no N42 account yet. You can share your N42 invite link with them to get started.'**
  String get web3NoN42AccountDesc;

  /// No description provided for @web3ShareInvite.
  ///
  /// In en, this message translates to:
  /// **'Share Invite'**
  String get web3ShareInvite;

  /// No description provided for @nftPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select NFT Avatar'**
  String get nftPickerTitle;

  /// No description provided for @nftPickerTabPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get nftPickerTabPopular;

  /// No description provided for @nftPickerTabCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get nftPickerTabCustom;

  /// No description provided for @nftPickerChain.
  ///
  /// In en, this message translates to:
  /// **'Chain'**
  String get nftPickerChain;

  /// No description provided for @nftPickerContract.
  ///
  /// In en, this message translates to:
  /// **'Contract Address'**
  String get nftPickerContract;

  /// No description provided for @nftPickerTokenId.
  ///
  /// In en, this message translates to:
  /// **'Token ID'**
  String get nftPickerTokenId;

  /// No description provided for @nftPickerVerifyOwnership.
  ///
  /// In en, this message translates to:
  /// **'Verify Ownership & Preview'**
  String get nftPickerVerifyOwnership;

  /// No description provided for @nftPickerUseAsAvatar.
  ///
  /// In en, this message translates to:
  /// **'Use as Avatar'**
  String get nftPickerUseAsAvatar;

  /// No description provided for @nftPickerPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get nftPickerPreview;

  /// No description provided for @nftPickerNotOwned.
  ///
  /// In en, this message translates to:
  /// **'You do not own this NFT'**
  String get nftPickerNotOwned;

  /// No description provided for @nftPickerInvalidTokenId.
  ///
  /// In en, this message translates to:
  /// **'Invalid token ID'**
  String get nftPickerInvalidTokenId;

  /// No description provided for @nftPickerEnterBoth.
  ///
  /// In en, this message translates to:
  /// **'Enter contract address and token ID'**
  String get nftPickerEnterBoth;

  /// No description provided for @nftPickerInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'NFT Avatar — Verified On-Chain'**
  String get nftPickerInfoTitle;

  /// No description provided for @nftPickerInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Bind an NFT you own as your avatar. Anyone can verify ownership on-chain. Displayed with a gold ring across N42.'**
  String get nftPickerInfoDesc;

  /// No description provided for @nftPickerPopularCollections.
  ///
  /// In en, this message translates to:
  /// **'Popular Collections'**
  String get nftPickerPopularCollections;

  /// No description provided for @nftPickerWalletHint.
  ///
  /// In en, this message translates to:
  /// **'Connect your N42 wallet to automatically discover your NFTs across 236+ chains.'**
  String get nftPickerWalletHint;

  /// No description provided for @profileBindNftAvatar.
  ///
  /// In en, this message translates to:
  /// **'Bind NFT Avatar'**
  String get profileBindNftAvatar;

  /// No description provided for @profileChangeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change Avatar'**
  String get profileChangeAvatar;

  /// No description provided for @groupTopics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get groupTopics;

  /// No description provided for @groupTopicsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No topics yet'**
  String get groupTopicsEmpty;

  /// No description provided for @syncInProgress.
  ///
  /// In en, this message translates to:
  /// **'Syncing message history...'**
  String get syncInProgress;

  /// No description provided for @recoveryKeyReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Protect your messages'**
  String get recoveryKeyReminderTitle;

  /// No description provided for @recoveryKeyReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a recovery key to securely sync encrypted messages across devices'**
  String get recoveryKeyReminderDesc;

  /// No description provided for @recoveryKeySetupNow.
  ///
  /// In en, this message translates to:
  /// **'Set up now'**
  String get recoveryKeySetupNow;

  /// No description provided for @recoveryKeyRemindLater.
  ///
  /// In en, this message translates to:
  /// **'Remind me later'**
  String get recoveryKeyRemindLater;

  /// No description provided for @channelReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Only admins can post in this channel'**
  String get channelReadOnly;

  /// No description provided for @channelSubscribers.
  ///
  /// In en, this message translates to:
  /// **'subscribers'**
  String get channelSubscribers;

  /// No description provided for @channelVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified channel'**
  String get channelVerified;

  /// No description provided for @redPacketHistory.
  ///
  /// In en, this message translates to:
  /// **'Red Packet History'**
  String get redPacketHistory;

  /// No description provided for @redPacketSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get redPacketSent;

  /// No description provided for @redPacketReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get redPacketReceived;

  /// No description provided for @redPacketExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get redPacketExpired;

  /// No description provided for @redPacketClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get redPacketClaimed;

  /// No description provided for @redPacketInsufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get redPacketInsufficientBalance;

  /// No description provided for @selfDestructCountdown.
  ///
  /// In en, this message translates to:
  /// **'Self-destruct in {time}'**
  String selfDestructCountdown(String time);

  /// No description provided for @messageDestroyed.
  ///
  /// In en, this message translates to:
  /// **'Message destroyed'**
  String get messageDestroyed;

  /// No description provided for @miniAppPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied: {permission}'**
  String miniAppPermissionDenied(String permission);

  /// No description provided for @aiSuggestionGasFee.
  ///
  /// In en, this message translates to:
  /// **'What is Gas fee?'**
  String get aiSuggestionGasFee;

  /// No description provided for @aiSuggestionDefi.
  ///
  /// In en, this message translates to:
  /// **'DeFi Beginner Guide'**
  String get aiSuggestionDefi;

  /// No description provided for @aiSuggestionSecurity.
  ///
  /// In en, this message translates to:
  /// **'How to check contract security'**
  String get aiSuggestionSecurity;

  /// No description provided for @aiSuggestionBridge.
  ///
  /// In en, this message translates to:
  /// **'Cross-chain bridging'**
  String get aiSuggestionBridge;

  /// No description provided for @channelDiscoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Channels'**
  String get channelDiscoverTitle;

  /// No description provided for @channelDiscoverSearch.
  ///
  /// In en, this message translates to:
  /// **'Search channels...'**
  String get channelDiscoverSearch;

  /// No description provided for @channelJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get channelJoin;

  /// No description provided for @channelJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get channelJoined;

  /// No description provided for @channelCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get channelCategory;

  /// No description provided for @slowModeCooldown.
  ///
  /// In en, this message translates to:
  /// **'Slow mode: wait {seconds}s'**
  String slowModeCooldown(int seconds);

  /// No description provided for @addressCopyAction.
  ///
  /// In en, this message translates to:
  /// **'Copy Address'**
  String get addressCopyAction;

  /// No description provided for @addressSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get addressSendMessage;

  /// No description provided for @addressViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get addressViewProfile;

  /// No description provided for @sendToAddress.
  ///
  /// In en, this message translates to:
  /// **'Send to wallet address'**
  String get sendToAddress;

  /// No description provided for @blocAuthSendVerificationCodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification code'**
  String get blocAuthSendVerificationCodeFailed;

  /// No description provided for @blocAuthServerNoEmailPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'This server does not support email password reset'**
  String get blocAuthServerNoEmailPasswordReset;

  /// No description provided for @blocAuthResetPasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password'**
  String get blocAuthResetPasswordFailed;

  /// No description provided for @blocAuthChangePasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get blocAuthChangePasswordFailed;

  /// No description provided for @blocAuthOldPasswordWrong.
  ///
  /// In en, this message translates to:
  /// **'Incorrect current password'**
  String get blocAuthOldPasswordWrong;

  /// No description provided for @blocAuthLoginCancelled.
  ///
  /// In en, this message translates to:
  /// **'Login cancelled'**
  String get blocAuthLoginCancelled;

  /// No description provided for @blocAuthGoogleLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Google login failed'**
  String get blocAuthGoogleLoginFailed;

  /// No description provided for @blocAuthAppleLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Apple login failed'**
  String get blocAuthAppleLoginFailed;

  /// No description provided for @blocAuthSsoLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'SSO login failed'**
  String get blocAuthSsoLoginFailed;

  /// No description provided for @blocAuthFacebookLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Facebook login failed'**
  String get blocAuthFacebookLoginFailed;

  /// No description provided for @blocAuthTwitterLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Twitter login failed'**
  String get blocAuthTwitterLoginFailed;

  /// No description provided for @blocAuthWeChatLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'WeChat login failed'**
  String get blocAuthWeChatLoginFailed;

  /// No description provided for @blocAuthWeChatNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'WeChat login not configured'**
  String get blocAuthWeChatNotConfigured;

  /// No description provided for @blocAuthWeChatNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Please install WeChat first'**
  String get blocAuthWeChatNotInstalled;

  /// No description provided for @blocAuthPasswordWrong.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get blocAuthPasswordWrong;

  /// No description provided for @blocAuthEmailAlreadyBound.
  ///
  /// In en, this message translates to:
  /// **'This email is already bound to another account'**
  String get blocAuthEmailAlreadyBound;

  /// No description provided for @blocAuthChangeEmailFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to change email'**
  String get blocAuthChangeEmailFailed;

  /// No description provided for @blocAuthVerificationCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Verification code is incorrect or expired'**
  String get blocAuthVerificationCodeInvalid;

  /// No description provided for @blocAuthSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired, please login again'**
  String get blocAuthSessionExpired;

  /// No description provided for @blocAuthSessionIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Session data incomplete, please login again'**
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
      return SZh();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
