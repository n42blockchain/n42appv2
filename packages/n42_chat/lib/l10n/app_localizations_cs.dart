// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class SCs extends S {
  SCs([String locale = 'cs']) : super(locale);

  @override
  String get commonRetry => 'Zkuste to znovu';

  @override
  String get commonUnknownUser => 'Neznámý uživatel';

  @override
  String get transferWalletNotConnected => 'Peněženka není připojena';

  @override
  String get chatCallServiceNotInitialized =>
      'Služba volání není inicializována';

  @override
  String authLoginFailed(String error) {
    return 'Přihlášení se nezdařilo: $error';
  }

  @override
  String get chatCallBack => 'Zavolejte zpět';

  @override
  String get chatMissedVideoCall => 'Zmeškaný videohovor';

  @override
  String get chatMissedVoiceCall => 'Zmeškaný hlasový hovor';

  @override
  String get chatCallNotAnswered => 'Nezodpovězeno';

  @override
  String get chatCallDurationLabel => 'Délka hovoru';

  @override
  String get chatVoiceCallCancelled => 'Hlasový hovor byl zrušen';

  @override
  String get chatVideoCallCancelled => 'Videohovor zrušen';

  @override
  String get commonImage => '[obrázek]';

  @override
  String get chatVideo => '[video]';

  @override
  String get chatVoice => '[Hlas]';

  @override
  String get commonFile => '[Soubor]';

  @override
  String get chatLocation => '[místo]';

  @override
  String get chatUnknownMessage => '[Neznámá zpráva]';

  @override
  String get commonDelete => 'Smazat';

  @override
  String get chatDeleteThisMessage => 'Smazat tuto zprávu?';

  @override
  String get chatMessageDeleted => 'Zpráva smazána';

  @override
  String get profileNotLoggedIn => 'Nejste přihlášeni';

  @override
  String get chatMyLocation => 'Moje poloha';

  @override
  String get commonGroupChat => 'Skupinový chat';

  @override
  String get commonSearch => 'Hledat';

  @override
  String get commonCancel => 'Zrušit';

  @override
  String get commonLoadFailed => 'Načtení se nezdařilo';

  @override
  String get commonMessages => 'Zprávy';

  @override
  String get commonContacts => 'Kontakty';

  @override
  String get commonMe => 'já';

  @override
  String get commonVoiceLoading => 'Hlasové načítání, zkuste to znovu později';

  @override
  String get commonVoiceToTextFailed => 'Hlas na text se nezdařil';

  @override
  String get commonConvertToText => 'Na text';

  @override
  String get chatCopy => 'Kopírovat';

  @override
  String get commonForward => 'Vpřed';

  @override
  String get commonUnfavorite => 'Neoblíbené';

  @override
  String get commonFavorite => 'Oblíbené';

  @override
  String get settingsResend => 'Odeslat znovu';

  @override
  String get chatRecall => 'Odvolání';

  @override
  String get commonQuote => 'Citace';

  @override
  String get commonRemind => 'Připomeňte';

  @override
  String get chatCopied => 'Zkopírováno';

  @override
  String get storySendMessageHint => 'Pošlete zprávu';

  @override
  String get commonMicrophonePermissionRequired =>
      'Povolte prosím přístup k mikrofonu';

  @override
  String get chatMicrophonePermissionDeniedPermanent =>
      'Povolení mikrofonu bylo odepřeno. Chcete-li používat hlasové zprávy, povolte jej v nastavení systému.';

  @override
  String commonStartRecordingFailed(String error) {
    return 'Nepodařilo se spustit nahrávání: $error';
  }

  @override
  String get commonRecordingTooShort => 'Nahrávání je příliš krátké';

  @override
  String commonStopRecordingFailed(String error) {
    return 'Nepodařilo se zastavit nahrávání: $error';
  }

  @override
  String get chatReleaseToCancel => 'Uvolněním zrušíte';

  @override
  String get chatReleaseToSend => 'Uvolněním odešlete, přejetím nahoru zrušíte';

  @override
  String get commonHoldToTalk => 'Vydržte, abyste mohli mluvit';

  @override
  String get commonSend => 'Odeslat';

  @override
  String get commonAddFriend => 'Přidat přítele';

  @override
  String get commonChatServiceNotConnected => 'Chatová služba není připojena';

  @override
  String contactUserNotFoundHint(String query) {
    return 'Uživatel \"$query\" nebyl nalezen\n\nTipy:\n• Zkuste zadat celé ID uživatele, např. @username:server.com\n• Zkontrolujte pravopis uživatelského jména';
  }

  @override
  String contactCreateChatFailed(String error) {
    return 'Nepodařilo se vytvořit chat: $error';
  }

  @override
  String contactSearchFailed(String error) {
    return 'Vyhledávání se nezdařilo: $error';
  }

  @override
  String get contactEnterUserIdOrUsername =>
      'Pro vyhledávání zadejte ID uživatele nebo uživatelské jméno';

  @override
  String get contactSearching => 'Hledání...';

  @override
  String get contactSearchUserToChat =>
      'Vyhledejte uživatele a začněte chatovat';

  @override
  String get contactMatrixIdExample =>
      'Můžete zadat úplné ID matice\nnapř. @user:matrix.n42.network';

  @override
  String contactUserNotFound(String username) {
    return 'Uživatel \"$username\" nebyl nalezen';
  }

  @override
  String get commonChat => 'Povídání';

  @override
  String get commonSettings => 'Nastavení';

  @override
  String get profileEditProfile => 'Upravit profil';

  @override
  String get authLogin => 'Přihlaste se';

  @override
  String get commonCreateGroup => 'Vytvořit skupinu';

  @override
  String get chatError => 'Chyba';

  @override
  String get commonTransfer => 'Přenést';

  @override
  String get commonReceived => 'Přijato';

  @override
  String get commonRefunded => 'Vráceno';

  @override
  String get commonExpired => 'Platnost vypršela';

  @override
  String get chatRedPacketGreeting => 'S pozdravem';

  @override
  String get commonN42RedPacket => 'N42 červený balíček';

  @override
  String get commonClaimed => 'Nárokováno';

  @override
  String get commonAllClaimed => 'Vše nárokováno';

  @override
  String get chatReadAloud => 'Čtěte nahlas';

  @override
  String get chatReply => 'Odpovědět';

  @override
  String get commonEdit => 'Upravit';

  @override
  String get chatSelectForwardTarget => 'Vyberte Dopředný cíl';

  @override
  String commonSendCount(int count) {
    return 'Odeslat ($count)';
  }

  @override
  String contactN42Id(String id) {
    return 'N42 ID: $id';
  }

  @override
  String get profileN42IdTitle => 'ID N42';

  @override
  String get profileN42Bean => 'N42 Fazole';

  @override
  String get contactFriendInfo => 'Informace o příteli';

  @override
  String get contactFriendInfoDesc =>
      'Přidejte poznámku přítele, telefon, štítky, poznámky, fotografie a nastavte oprávnění.';

  @override
  String get commonMoments => 'Okamžiky';

  @override
  String get commonSendMessage => 'Zpráva';

  @override
  String get contactAudioVideoCall => 'Audio/Video hovor';

  @override
  String get contactVideoChannel => 'Video kanál';

  @override
  String get contactRemark => 'Poznámka';

  @override
  String get contactRemarkName => 'Poznámka Jméno';

  @override
  String get contactPhone => 'Telefon';

  @override
  String get contactTags => 'Tagy';

  @override
  String get contactNotes => 'Poznámky';

  @override
  String get contactPhotos => 'Fotografie';

  @override
  String get contactPermissions => 'Oprávnění';

  @override
  String get contactChatMomentsEtc => 'Chat, Momenty, Sport atd.';

  @override
  String get contactMoreInfo => 'Více informací';

  @override
  String get contactCommonGroups => 'Společné skupiny';

  @override
  String get contactSource => 'Zdroj';

  @override
  String get settingsNotificationSettings => 'Oznámení';

  @override
  String get settingsPrivacy => 'soukromí';

  @override
  String get settingsAppearance => 'Vzhled';

  @override
  String get settingsAbout => 'O';

  @override
  String get commonLogout => 'Odhlásit se';

  @override
  String get commonLogoutConfirm => 'Opravdu se chcete odhlásit?';

  @override
  String get commonSave => 'Uložit';

  @override
  String get profileNickname => 'přezdívka';

  @override
  String get profileEnterNickname => 'Zadejte přezdívku';

  @override
  String get profileSignature => 'Podpis';

  @override
  String get profileAddSignature => 'Přidejte podpis';

  @override
  String get commonTakePhoto => 'Vyfotit';

  @override
  String get profileChooseFromGallery => 'Vyberte si z Galerie';

  @override
  String profileSaveFailed(String error) {
    return 'Uložení se nezdařilo: $error';
  }

  @override
  String get authSecureDecentralizedChat =>
      'Bezpečné, decentralizované zasílání zpráv';

  @override
  String get commonEndToEndEncryption => 'End-to-End šifrování';

  @override
  String get authMessagesOnlyYouCanSee =>
      'Zprávy viditelné pouze vám a příjemci';

  @override
  String get authDecentralized => 'Decentralizované';

  @override
  String get authBasedOnMatrix => 'Postaveno na otevřeném protokolu Matrix';

  @override
  String get authWalletIntegration => 'Integrace peněženky';

  @override
  String get authEasyCryptoTransfer => 'Snadné převody kryptoměn';

  @override
  String get authRegister => 'Zaregistrujte se';

  @override
  String get authAgreeTerms => 'Přihlášením souhlasíte';

  @override
  String get authTermsOfService => 'Podmínky služby';

  @override
  String get authAnd => ' a ';

  @override
  String get authPrivacyPolicy => 'Zásady ochrany osobních údajů';

  @override
  String get authServerAddress => 'Adresa serveru';

  @override
  String get authEnterServerAddress => 'Zadejte adresu serveru';

  @override
  String authConnectedTo(String serverName) {
    return 'Připojeno k $serverName';
  }

  @override
  String get authUsername => 'Uživatelské jméno';

  @override
  String get authEnterUsername => 'Zadejte uživatelské jméno';

  @override
  String get authUsernameOrEmail => 'Uživatelské jméno nebo e-mail';

  @override
  String get authEnterUsernameOrEmail =>
      'Zadejte uživatelské jméno nebo e-mail';

  @override
  String get authPassword => 'Heslo';

  @override
  String get authEnterPassword => 'Zadejte heslo';

  @override
  String get authRegisterAccount => 'Zaregistrujte se';

  @override
  String get authForgotPassword => 'Zapomenuté heslo';

  @override
  String get authOtherLoginMethods => 'Další způsoby přihlášení';

  @override
  String get authCreateAccount => 'Vytvořit účet';

  @override
  String get authJoinN42Chat => 'Připojte se k chatu N42 a začněte chatovat';

  @override
  String get authUsernameHint => '3–20 znaků, písmen/číslic/_';

  @override
  String get authUsernameMinLength =>
      'Uživatelské jméno musí mít alespoň 3 znaky';

  @override
  String get authUsernameMaxLength =>
      'Uživatelské jméno musí mít maximálně 20 znaků';

  @override
  String get authUsernameFormat =>
      'Uživatelské jméno může obsahovat pouze písmena, čísla a podtržítka';

  @override
  String get authPasswordHint => 'Minimálně 8 znaků';

  @override
  String get commonPasswordMinLength => 'Heslo musí mít alespoň 8 znaků';

  @override
  String get authConfirmPassword => 'Potvrďte heslo';

  @override
  String get authFilled => 'Naplněno';

  @override
  String get authEnterInviteCode => 'Zadejte kód pozvánky';

  @override
  String get authAlreadyHaveAccount => 'Už máte účet?';

  @override
  String get authLoginNow => 'Přihlaste se nyní';

  @override
  String get profileAvatar => 'Avatar';

  @override
  String get profileStatus => 'Stav';

  @override
  String get commonLoading => 'Načítání...';

  @override
  String get conversationNoConversations => 'Žádné konverzace';

  @override
  String get conversationTapToChat =>
      'Klepnutím vpravo nahoře začněte chatovat';

  @override
  String get conversationStartGroup => 'Spusťte skupinový chat';

  @override
  String get commonScan => 'Skenujte';

  @override
  String get commonPayment => 'Platba';

  @override
  String commonFeatureComingSoon(String feature) {
    return '$feature již brzy';
  }

  @override
  String get conversationMarkAsRead => 'Označit jako přečtené';

  @override
  String get commonUnmute => 'Zapnout zvuk';

  @override
  String get commonMute => 'Ztlumit';

  @override
  String get conversationUnpin => 'Odepnout';

  @override
  String get conversationPin => 'Kolík';

  @override
  String get conversationDeleteConversation => 'Smazat konverzaci';

  @override
  String conversationDeleteConversationConfirm(String name) {
    return 'Smazat konverzaci s \"$name\"?';
  }

  @override
  String get commonNoContacts => 'Žádné kontakty';

  @override
  String get contactAddFriendsToChat => 'Přidejte přátele a začněte chatovat';

  @override
  String get contactNotFound => 'Kontakt nenalezen';

  @override
  String get contactTryOtherKeywords =>
      'Zkuste jiná klíčová slova nebo globální vyhledávání';

  @override
  String get contactSearchResults => 'Výsledky vyhledávání';

  @override
  String get contactNewFriends => 'Noví přátelé';

  @override
  String get contactChatOnlyFriends => 'Přátelé pouze pro chat';

  @override
  String get contactOfficialAccounts => 'Oficiální účty';

  @override
  String get contactServiceAccounts => 'Servisní účty';

  @override
  String get contactEnterpriseContacts => 'Podnikové kontakty';

  @override
  String get contactRecommendToFriend => 'Sdílejte kontakt';

  @override
  String get commonSetRemark => 'Nastavit poznámku';

  @override
  String get contactSendingCard => 'Odesílání kontaktní karty...';

  @override
  String get commonFileLabel => 'Soubor';

  @override
  String get commonLocationLabel => 'Umístění';

  @override
  String contactRecommendFailed(String error) {
    return 'Doporučení selhalo: $error';
  }

  @override
  String get profileEnterRemark => 'Zadejte poznámku';

  @override
  String get contactOpeningChat => 'Otevírání chatu...';

  @override
  String contactOpenChatFailed(String error) {
    return 'Chat se nepodařilo otevřít: $error';
  }

  @override
  String get contactAddContact => 'Přidat kontakt';

  @override
  String get contactEnterUserId => 'Zadejte ID uživatele';

  @override
  String get contactNoFriendRequests => 'Žádné žádosti o přátelství';

  @override
  String get commonAccept => 'Přijmout';

  @override
  String get commonReject => 'Odmítnout';

  @override
  String get commonNoGroups => 'Žádné skupiny';

  @override
  String get contactSelectFriendToRecommend =>
      'Vyberte přítele, kterému chcete doporučit';

  @override
  String get commonSearchContacts => 'Hledat kontakty';

  @override
  String get contactNoContactsFound => 'Nebyly nalezeny žádné kontakty';

  @override
  String get favoriteYesterday => 'včera';

  @override
  String get chatJustNow => 'Právě teď';

  @override
  String get profileOnline => 'Online';

  @override
  String get profileOffline => 'Offline';

  @override
  String get searchContactsGroupsMessages =>
      'Vyhledávejte kontakty, skupiny a zprávy';

  @override
  String get searchError => 'Chyba vyhledávání';

  @override
  String get chatSearchHint => 'Hledat';

  @override
  String get searchHistory => 'Historie vyhledávání';

  @override
  String get commonClear => 'Jasný';

  @override
  String get commonAll => 'všechny';

  @override
  String get searchGroups => 'Skupiny';

  @override
  String get searchNoResults => 'Žádné výsledky';

  @override
  String commonGroupMembers(int count) {
    return 'Členové ($count)';
  }

  @override
  String get groupMembersTitle => 'Členové skupiny';

  @override
  String get groupViewAll => 'Zobrazit vše';

  @override
  String get groupOwner => 'vlastník';

  @override
  String get groupAdmin => 'Admin';

  @override
  String get groupInvite => 'Pozvat';

  @override
  String get commonGroupAnnouncement => 'Skupinové oznámení';

  @override
  String get commonNotSet => 'Nenastaveno';

  @override
  String get groupDescription => 'Popis skupiny';

  @override
  String get groupPublicGroup => 'Veřejná skupina';

  @override
  String get commonClearChatHistory => 'Vymazat historii chatu';

  @override
  String get commonDissolveGroup => 'Rozpustit skupinu';

  @override
  String get commonLeaveGroup => 'Opustit skupinu';

  @override
  String get groupChangeGroupName => 'Změňte název skupiny';

  @override
  String get commonEnterGroupName => 'Zadejte název skupiny';

  @override
  String get commonConfirm => 'Potvrďte';

  @override
  String get groupEnterGroupDescription => 'Zadejte popis skupiny';

  @override
  String get groupPublish => 'Publikovat';

  @override
  String get chatClearHistoryConfirm =>
      'Vymazat celou historii chatu? Toto nelze vrátit zpět.';

  @override
  String get chatClearAction => 'Jasný';

  @override
  String get commonChatHistoryCleared => 'Historie chatu byla vymazána';

  @override
  String get commonDissolve => 'Rozpustit';

  @override
  String get groupQrCode => 'Skupinový QR kód';

  @override
  String get commonSearchChatHistory => 'Hledat historii chatu';

  @override
  String get groupIdCopied => 'ID skupiny zkopírováno';

  @override
  String get transferEnterOrPasteAddress =>
      'Zadejte nebo vložte adresu peněženky';

  @override
  String get transferSelectToken => 'Vyberte Token';

  @override
  String get commonTransferAmount => 'Částka převodu';

  @override
  String get transferAvailable => 'K dispozici';

  @override
  String get transferMemoOptional => 'Poznámka (volitelné)';

  @override
  String get transferConfirmTransfer => 'Potvrďte přenos';

  @override
  String get transferAddressVerified => 'Adresa ověřena';

  @override
  String transferAvailableBalance(String balance, String symbol) {
    return 'Dostupné: $balance $symbol';
  }

  @override
  String get commonEnterAmount => 'Zadejte částku';

  @override
  String get commonRedPacketCountMin => 'Vyžaduje se alespoň 1 červený balíček';

  @override
  String get commonViewRedPacketDetails =>
      'Zobrazit podrobnosti o červeném paketu';

  @override
  String get commonEnterTransferAmount => 'Zadejte částku převodu';

  @override
  String get commonTransferTo => 'Přenést do';

  @override
  String commonFromSender(String name, Object senderName) {
    return 'Od $name';
  }

  @override
  String get commonConfirmReceive => 'Potvrďte příjem';

  @override
  String get groupProfile => 'Informace o skupině';

  @override
  String get groupRemoveMember => 'Odebrat ze skupiny';

  @override
  String get commonRemove => 'Odebrat';

  @override
  String get profileClearStatus => 'Vymazat stav';

  @override
  String get profileClearStatusConfirm => 'Vymazat aktuální stav?';

  @override
  String get profileStatusCleared => 'Stav vymazán';

  @override
  String get profileUserNotExist => 'Uživatel neexistuje';

  @override
  String get profileUserIdCopied => 'ID uživatele zkopírováno';

  @override
  String get commonReport => 'Zpráva';

  @override
  String get profileQrCode => 'QR kód';

  @override
  String get profileAvatarUpdated => 'Avatar aktualizován';

  @override
  String commonSelectImageFailed(String error) {
    return 'Nepodařilo se vybrat obrázek: $error';
  }

  @override
  String get profileChangeName => 'Změnit jméno';

  @override
  String get profileMale => 'Mužské';

  @override
  String get profileFemale => 'Žena';

  @override
  String chatFeatureInDev(String feature) {
    return 'Funkce $feature ve vývoji...';
  }

  @override
  String profileSaveAddressFailed(String error) {
    return 'Nepodařilo se uložit adresu: $error';
  }

  @override
  String get profileAddNew => 'Přidat';

  @override
  String get profileAddAddress => 'Přidat adresu';

  @override
  String get profileAddressAdded => 'Adresa přidána';

  @override
  String get profileAddressUpdated => 'Adresa aktualizována';

  @override
  String get profileDeleteAddress => 'Smazat adresu';

  @override
  String get profileAddressDeleted => 'Adresa smazána';

  @override
  String profileSaveInvoiceFailed(String error) {
    return 'Fakturu se nepodařilo uložit: $error';
  }

  @override
  String get profileMyInvoices => 'Moje faktury';

  @override
  String get profileAddInvoice => 'Přidat fakturu';

  @override
  String get profileInvoiceAdded => 'Faktura přidána';

  @override
  String get profileInvoiceUpdated => 'Faktura aktualizována';

  @override
  String get profileDeleteInvoice => 'Smazat fakturu';

  @override
  String get profileInvoiceDeleted => 'Faktura smazána';

  @override
  String get profilePersonal => 'Osobní';

  @override
  String get groupSelectAtLeastOne => 'Vyberte prosím alespoň jednoho člena';

  @override
  String get chatFileNotExist => 'Soubor neexistuje';

  @override
  String chatSendFailed(String error) {
    return 'Odeslání se nezdařilo: $error';
  }

  @override
  String get chatCannotOpenBrowser => 'Nelze otevřít prohlížeč';

  @override
  String chatSelectFileFailed(String error) {
    return 'Nepodařilo se vybrat soubor: $error';
  }

  @override
  String settingsSetupFailed(String error) {
    return 'Nastavení se nezdařilo: $error';
  }

  @override
  String get transferEnterValidAmount => 'Zadejte platnou částku';

  @override
  String get commonAddressCopied => 'Adresa zkopírována';

  @override
  String favoriteOpenItem(String content) {
    return 'Otevřeno: $content';
  }

  @override
  String get favoriteDeleted => 'Smazáno';

  @override
  String get profileWallet => 'Peněženka';

  @override
  String get chatRecording => 'Nahrávání';

  @override
  String get chatInvalidVideoUrl => 'Neplatná adresa URL videa';

  @override
  String get chatDownloadFile => 'Stáhnout soubor';

  @override
  String get chatClearChatHistoryTitle => 'Vymazat historii chatu';

  @override
  String get chatVideoCall => 'Videohovor';

  @override
  String get commonVoiceCall => 'Hlasový hovor';

  @override
  String get callLeaveMeeting => 'Opustit schůzku';

  @override
  String get chatDetails => 'Podrobnosti chatu';

  @override
  String get chatViewAllGroupMembers => 'Zobrazit všechny členy';

  @override
  String get chatGroupName => 'Název skupiny';

  @override
  String get chatGroupNameUpdated => 'Název skupiny byl aktualizován';

  @override
  String get chatUpdateFailed => 'Aktualizace se nezdařila';

  @override
  String get chatNoPermissionToModify => 'Nemáte oprávnění k úpravám';

  @override
  String get chatGroupManagement => 'Správa skupiny';

  @override
  String get chatMyNicknameInGroup => 'Moje přezdívka ve skupině';

  @override
  String get chatPinChat => 'Připnout chat';

  @override
  String get chatStrongReminder => 'Silné připomenutí';

  @override
  String get chatSetChatBackground => 'Nastavit pozadí chatu';

  @override
  String get chatUnknownFile => 'Neznámý soubor';

  @override
  String get chatDownload => 'Stáhnout';

  @override
  String get chatInvalidLocation => 'Neplatné umístění';

  @override
  String get chatTapToCancel => 'Klepnutím zrušte';

  @override
  String chatCaptureFailed(Object error) {
    return 'Zachycení se nezdařilo: $error';
  }

  @override
  String get chatProcessingVideo => 'Zpracování videa...';

  @override
  String get chatVideoFileNotExist => 'Video soubor neexistuje';

  @override
  String get chatVideoDataEmpty => 'Data videa jsou prázdná';

  @override
  String get chatVideoTooLarge => 'Velikost videa nesmí přesáhnout 100 MB';

  @override
  String get chatSendingVideo => 'Odesílání videa...';

  @override
  String chatSendVideoFailed(Object error) {
    return 'Video se nepodařilo odeslat: $error';
  }

  @override
  String get chatImageFileNotExist => 'Soubor obrázku neexistuje';

  @override
  String get commonImageDataEmpty => 'Obrazová data jsou prázdná';

  @override
  String get chatSendingImage => 'Odesílání obrázku...';

  @override
  String chatSendImageFailed(Object error) {
    return 'Nepodařilo se odeslat obrázek: $error';
  }

  @override
  String get chatSendLocation => 'Odeslat polohu';

  @override
  String get chatSelectLocationAndSend => 'Vyberte umístění a odešlete';

  @override
  String get chatShareRealTimeLocation => 'Sdílejte polohu v reálném čase';

  @override
  String get chatShareLocationForOneHour =>
      'Sdílejte polohu v reálném čase s přítelem po dobu 1 hodiny';

  @override
  String get chatLocationSent => 'Poloha odeslána';

  @override
  String get chatSelectMessages => 'Vyberte zprávy';

  @override
  String chatSelectedCount(int count) {
    return 'Vybrané $count';
  }

  @override
  String get chatSelectAll => 'Vyberte Vše';

  @override
  String chatGroupChatCount(int count) {
    return 'Skupinový chat ($count)';
  }

  @override
  String get chatPrivateChat => 'Soukromý chat';

  @override
  String get chatNoMessages => 'Žádné zprávy';

  @override
  String get chatSendFirstMessage =>
      'Chcete-li začít chatovat, odešlete první zprávu';

  @override
  String get chatEncryptionNotice =>
      'Tento chat je šifrován end-to-end. Zprávy můžete číst pouze vy a příjemce.';

  @override
  String get chatMultiForward => 'Vpřed';

  @override
  String get chatCollect => 'Sbírejte';

  @override
  String get chatNoMembers => 'Žádní členové';

  @override
  String get chatMemberNotFound => 'Člen nenalezen';

  @override
  String get chatVoiceFileNotExist => 'Hlasový soubor neexistuje';

  @override
  String get chatVoiceFileEmpty => 'Hlasový soubor je prázdný';

  @override
  String get chatSendingVoice => 'Odesílání hlasu...';

  @override
  String chatSendVoiceFailed(Object error) {
    return 'Nepodařilo se odeslat hlas: $error';
  }

  @override
  String get chatMessageForwarded => 'Zpráva přeposlána';

  @override
  String chatForwardFailed(Object error) {
    return 'Přesměrování se nezdařilo: $error';
  }

  @override
  String get chatUnfavorited => 'Neoblíbený';

  @override
  String get chatFavorited => 'Oblíbené';

  @override
  String get chatReactionAdded => 'Přidána reakce';

  @override
  String get chatReactionRemoved => 'Reakce odstraněna';

  @override
  String get chatFailedMessageDeleted => 'Neúspěšná zpráva byla smazána';

  @override
  String get chatDeleteMessages => 'Odstraňte zprávy';

  @override
  String chatDeleteMessagesConfirm(Object count) {
    return 'Opravdu chcete smazat zprávy $count?';
  }

  @override
  String chatNoteOtherMessages(Object count) {
    return 'Poznámka: Zprávy $count jsou od ostatních a budou smazány pouze pro vás.';
  }

  @override
  String chatMyMessagesWillBeRecalled(Object count) {
    return 'Zprávy $count od vás budou vyvolány pro všechny.';
  }

  @override
  String chatRecalledCount(Object count, Object localCount) {
    return 'Připomenuté zprávy $count, $localCount odstraněny pouze pro vás';
  }

  @override
  String chatRecalledMessages(Object count) {
    return 'Vyvolání zpráv $count';
  }

  @override
  String chatDeletedLocally(Object count) {
    return 'Zprávy $count smazané pouze pro vás';
  }

  @override
  String chatForwardedCount(Object count) {
    return 'Přeposlané zprávy $count';
  }

  @override
  String chatForwardComplete(Object failed, Object success) {
    return 'Předání dokončeno: $success bylo úspěšné, $failed se nezdařilo';
  }

  @override
  String get chatRemindOnlyInGroup =>
      'Funkce připomenutí je dostupná pouze ve skupinovém chatu';

  @override
  String get chatOnlyTextSearchable => 'Lze vyhledávat pouze textové zprávy';

  @override
  String chatSearchFor(Object text) {
    return 'Hledat \"$text\"';
  }

  @override
  String get chatBaiduSearch => 'Vyhledávání Baidu';

  @override
  String get chatGoogleSearch => 'Vyhledávání Google';

  @override
  String get chatBingSearch => 'Bing Search';

  @override
  String get chatCalling => 'Volání...';

  @override
  String get chatRinging => 'Vyzvánění...';

  @override
  String get chatInCall => 'V hovoru';

  @override
  String commonFeatureInDevelopment(String feature) {
    return 'Funkce $feature ve vývoji...';
  }

  @override
  String chatCollectMessages(Object count) {
    return 'Shromážděné zprávy $count';
  }

  @override
  String commonMemberCount(int count) {
    return 'Členové $count';
  }

  @override
  String groupDone(int count) {
    return 'Hotovo ($count)';
  }

  @override
  String get profileServices => 'Služby';

  @override
  String get commonFavorites => 'Oblíbené';

  @override
  String get profileOrdersAndCards => 'Objednávky a karty';

  @override
  String get profileStickers => 'Samolepky';

  @override
  String profileStatusSetTo(String status) {
    return 'Stav nastaven na: $status';
  }

  @override
  String get profileAvatarUploadFailed => 'Nahrání avatara se nezdařilo';

  @override
  String get profilePersonalProfile => 'Osobní profil';

  @override
  String get profileName => 'Jméno';

  @override
  String get profileGender => 'Pohlaví';

  @override
  String get profileRegion => 'Kraj';

  @override
  String get commonMyQrCode => 'Můj QR kód';

  @override
  String get profilePoke => 'Strčit';

  @override
  String get profileRingtone => 'Vyzváněcí tón';

  @override
  String get profileDefaultRingtone => 'Výchozí vyzváněcí tón';

  @override
  String get profileMyAddresses => 'Moje adresy';

  @override
  String profileGenderSetTo(String gender) {
    return 'Pohlaví nastaveno na: $gender';
  }

  @override
  String get profileSelectRegion => 'Vyberte Region';

  @override
  String get profileSelectCity => 'Vyberte Město';

  @override
  String profileRegionSetTo(String region) {
    return 'Oblast nastavena na: $region';
  }

  @override
  String get profileSetPoke => 'Nastavte Poke';

  @override
  String get profileFriendPokedMe => 'Přítel mě šťouchl';

  @override
  String get profileExample => 'Příklad';

  @override
  String get profileOnTheShoulder => ' na rameni';

  @override
  String get profilePokeCleared => 'Poke vymazán';

  @override
  String profilePokeSetTo(String suffix) {
    return 'Poke nastaven na: poked me$suffix';
  }

  @override
  String get profileEditSignature => 'Upravit podpis';

  @override
  String get profileIntroduceYourself => 'Věta na představení';

  @override
  String get profileSignatureCleared => 'Podpis vymazán';

  @override
  String get profileSignatureUpdated => 'Podpis aktualizován';

  @override
  String get profileScanToAddFriend =>
      'Naskenujte QR kód výše a přidejte si mě jako přítele';

  @override
  String profileRingtoneSetTo(String ringtone) {
    return 'Vyzváněcí tón nastaven na: $ringtone';
  }

  @override
  String commonConfirmDissolveGroup(String name) {
    return 'Opravdu chcete rozpustit \"$name\"? Tuto akci nelze vrátit zpět.';
  }

  @override
  String get authEnterValidServerAddress => 'Zadejte platnou adresu serveru';

  @override
  String get authEnterServerAddressFirst => 'Nejprve zadejte adresu serveru';

  @override
  String get authPasskeyRequiresServer =>
      'Přihlášení pomocí hesla vyžaduje podporu serveru';

  @override
  String get authLoginAgreement => 'Přihlášením souhlasíte ';

  @override
  String get authPleaseAgreeToTerms =>
      'Přečtěte si prosím Podmínky služby a Zásady ochrany osobních údajů a odsouhlaste je';

  @override
  String get authRegisterFailed => 'Registrace se nezdařila';

  @override
  String get commonReenterPassword => 'Znovu zadejte heslo';

  @override
  String get commonPasswordsDoNotMatch => 'Hesla se neshodují';

  @override
  String get authInviteCodeBuiltIn => 'Zvací kód (vestavěný)';

  @override
  String get authInviteCodeBuiltInNote =>
      'Zvací kód je vestavěný, obvykle jej není třeba upravovat';

  @override
  String get authIHaveReadAndAgree => 'Přečetl jsem a souhlasím ';

  @override
  String get mainStartGroupChat => 'Spusťte skupinový chat';

  @override
  String get mainAddFriends => 'Přidat přátele';

  @override
  String get mainPaymentAndCollection => 'Platba';

  @override
  String contactCount(int count) {
    return 'Kontakty $count';
  }

  @override
  String get contactAddToHomeScreen => 'Přidat na domovskou obrazovku';

  @override
  String contactRecommendedCardTo(String contact, String recipient) {
    return 'Doporučená karta $contact na $recipient';
  }

  @override
  String get contactEnterRemarkName => 'Zadejte název poznámky';

  @override
  String contactRemarkSetTo(String remark) {
    return 'Poznámka nastavena na: $remark';
  }

  @override
  String contactAcceptedFriendRequest(String name) {
    return 'Přijal jsem žádost o přátelství $name';
  }

  @override
  String contactRejectedFriendRequest(String name) {
    return 'Žádost o přátelství $name byla zamítnuta';
  }

  @override
  String get commonGroupInvites => 'Skupinové pozvánky';

  @override
  String commonMyGroups(int count) {
    return 'Moje skupiny ($count)';
  }

  @override
  String get commonInvitedToJoinGroup => 'Pozván do skupiny';

  @override
  String commonConfirmLeaveGroup(String name) {
    return 'Opravdu chcete opustit \"$name\"?';
  }

  @override
  String get commonLeave => 'Odejděte';

  @override
  String get commonRecallThisMessage => 'Pamatujete si tuto zprávu?';

  @override
  String get commonSavedToGallery => 'Uloženo do galerie';

  @override
  String get commonFailedToSave => 'Uložení se nezdařilo';

  @override
  String get chatSaving => 'Ukládání...';

  @override
  String get commonShare => 'Sdílejte';

  @override
  String get chatSaveToGallery => 'Uložit do Galerie';

  @override
  String chatDownloadFailed(String code) {
    return 'Stahování se nezdařilo: $code';
  }

  @override
  String commonShareFailed(String error) {
    return 'Sdílení se nezdařilo: $error';
  }

  @override
  String get chatFailedToLoadImage => 'Načtení obrázku se nezdařilo';

  @override
  String get chatVideoRecordingFailed => 'Záznam videa se nezdařil';

  @override
  String get profileRedPacket => 'Červený balíček';

  @override
  String get commonMusic => 'Hudba';

  @override
  String get commonCoupon => 'kupon';

  @override
  String get commonGift => 'Dárek';

  @override
  String get commonPoll => 'Anketa';

  @override
  String get favoriteText => 'Text';

  @override
  String get favoriteLinkLabel => 'Odkaz';

  @override
  String get favoriteNote => 'Poznámka';

  @override
  String get favoriteMyNotes => 'Moje poznámky';

  @override
  String get favoriteToday => 'dnes';

  @override
  String favoriteDaysAgoText(int count) {
    return 'Před $count dny';
  }

  @override
  String favoriteDateFormat(int month, int day) {
    return '$month/$day';
  }

  @override
  String get favoriteNoFavorites => 'Zatím žádné oblíbené';

  @override
  String get favoriteLongPressToFavorite =>
      'Dlouhým stisknutím zprávy přejdete do oblíbené položky';

  @override
  String get favoriteNewNote => 'Nová poznámka';

  @override
  String get favoriteLink => 'Oblíbený odkaz';

  @override
  String get favoriteEditTags => 'Upravit značky';

  @override
  String get favoriteDeleteFavorite => 'Smazat oblíbené';

  @override
  String get favoriteDeleteFavoriteConfirm =>
      'Opravdu chcete tuto oblíbenou položku smazat?';

  @override
  String get favoriteNoSearchResultsFound => 'Nebyly nalezeny žádné výsledky';

  @override
  String get commonSendRedPacket => 'Pošlete červený balíček';

  @override
  String get transferAmount => 'Částka';

  @override
  String get commonRedPacketCover => 'Červený obal na balíček';

  @override
  String get commonRedPacketType => 'Červený typ paketu';

  @override
  String get commonNormalRedPacket => 'Normální';

  @override
  String get commonLuckyRedPacket => 'Štěstí';

  @override
  String get commonRedPacketCount => 'Počet červených paketů';

  @override
  String get commonPieces => 'kusy';

  @override
  String get commonPutMoneyInRedPacket => 'Vložte peníze do červeného balíčku';

  @override
  String get commonRedPacketRefundNotice =>
      'Nevyzvednuté červené balíčky budou vráceny po 24 hodinách';

  @override
  String get commonOpenRedPacket => 'Otevřít';

  @override
  String get commonRedPacketAllClaimed => 'Červený balíček vše nárokováno';

  @override
  String get commonRedPacketExpired => 'Platnost červeného balíčku vypršela';

  @override
  String get commonAddTransferNote => 'Přidejte poznámku o převodu';

  @override
  String get commonYuan => 'CNY';

  @override
  String get commonReplyWithEmoji => 'Odpovězte tímto emotikonem';

  @override
  String get contactEditRemark => 'Upravit poznámku';

  @override
  String get contactSetPermissions => 'Nastavte oprávnění';

  @override
  String get profileAddToBlacklist => 'Přidat na černou listinu';

  @override
  String get contactDeleteContact => 'Smazat kontakt';

  @override
  String contactDeleteContactConfirm(String name) {
    return 'Opravdu chcete smazat $name?';
  }

  @override
  String get transferTitle => 'Přenést';

  @override
  String get transferReceiverAddressLabel => 'Adresa příjemce';

  @override
  String get transferSelectTokenLabel => 'Vyberte Token';

  @override
  String get transferAmountLabel => 'Částka převodu';

  @override
  String get transferMemoLabel => 'Poznámka (volitelné)';

  @override
  String get transferAddMemoHint => 'Přidejte poznámku';

  @override
  String get transferSendPaymentRequest => 'Odeslat žádost o platbu';

  @override
  String get transferQrCodeGenerateFailed => 'Generování QR kódu se nezdařilo';

  @override
  String get transferScanQrToPayMe => 'Zaplaťte mi naskenováním QR kódu';

  @override
  String get transferMyWalletAddress => 'Adresa mé peněženky';

  @override
  String get transferCreatePaymentRequest => 'Vytvořit žádost o platbu';

  @override
  String profileN42IdLabel(String id) {
    return 'N42 ID: $id';
  }

  @override
  String get commonRedPacketDefaultGreeting => 'S pozdravem';

  @override
  String commonSenderRedPacket(String name) {
    return 'Červený paket $name';
  }

  @override
  String get transferEnterValidAddress => 'Zadejte prosím platnou adresu';

  @override
  String get transferPleaseSelectToken => 'Vyberte token';

  @override
  String get commonReceivedTransfer => 'Přijatý převod';

  @override
  String commonSenderSentRedPacket(String name) {
    return '$name odeslal červený paket';
  }

  @override
  String get commonSavedToBalance => 'Uloženo do zůstatku, lze převést přímo';

  @override
  String get commonRedPacketExpiredOrEmpty =>
      'Platnost červeného balíčku vypršela/všechno nárokováno';

  @override
  String get transferScanFeatureComingSoon => 'Funkce skenování již brzy...';

  @override
  String get contactSetAsStarred => 'Nastavit jako S hvězdičkou';

  @override
  String get contactAddToBlocklist => 'Přidat do seznamu blokovaných';

  @override
  String get commonClaimedYour => ' nárokoval váš ';

  @override
  String get commonClaimedText => ' tvrdil ';

  @override
  String commonUserTyping(String name) {
    return '$name píše...';
  }

  @override
  String get commonTyping => 'Psaní...';

  @override
  String get commonWaitingToReceive => 'Čekání na přijetí';

  @override
  String get commonTapToClaim => 'Klepnutím nárokujte';

  @override
  String get commonHasBeenReceived => 'Bylo přijato';

  @override
  String get commonGetLucky => 'Mít štěstí';

  @override
  String get qrcodeCameraStartFailed => 'Fotoaparát se nepodařilo spustit';

  @override
  String get qrcodeUnknownError => 'Neznámá chyba';

  @override
  String get qrcodePlaceQrCodeInFrame =>
      'Umístěte QR kód do rámečku, který chcete naskenovat';

  @override
  String get qrcodeCloseManualInput => 'Zavřete ruční vstup';

  @override
  String get qrcodeManualInputUserId => 'Ruční zadání ID uživatele';

  @override
  String get commonAdd => 'Přidat';

  @override
  String get profileSetStatus => 'Nastavit stav';

  @override
  String get profileVisibleToFriends24h =>
      'Viditelné pro přátele po dobu 24 hodin';

  @override
  String get profileWriteStatus => 'Zapsat stav';

  @override
  String get profileEnterYourStatus => 'Zadejte svůj stav...';

  @override
  String get profileOk => 'OK';

  @override
  String get qrcodeCameraPermissionRequired =>
      'Ke skenování QR kódu je vyžadováno povolení fotoaparátu';

  @override
  String get qrcodeCameraPermissionDenied =>
      'Povolení fotoaparátu bylo trvale odepřeno. Povolte jej prosím v nastavení systému.';

  @override
  String qrcodePermissionCheckError(String error) {
    return 'Chyba při kontrole oprávnění: $error';
  }

  @override
  String get qrcodeInvalidQrCode => 'Neplatný QR kód';

  @override
  String qrcodeCannotAddFriend(String error) {
    return 'Nelze přidat přítele: $error';
  }

  @override
  String get qrcodeScanQrCode => 'Naskenujte QR kód';

  @override
  String get qrcodeCheckingCameraPermission =>
      'Kontrola oprávnění fotoaparátu...';

  @override
  String get qrcodeNeedCameraPermission =>
      'Je vyžadováno oprávnění k fotoaparátu';

  @override
  String get qrcodeRetryPermission => 'Zkuste to znovu';

  @override
  String get qrcodeOpenSettings => 'Otevřete Nastavení';

  @override
  String get groupInviteMembers => 'Pozvat členy';

  @override
  String groupInviteCount(int count) {
    return 'Pozvat ($count)';
  }

  @override
  String get profileNoShippingAddress => 'Žádná dodací adresa';

  @override
  String get profileDefaultLabel => 'Výchozí';

  @override
  String get profileNoInvoice => 'Žádná faktura';

  @override
  String get profileCompany => 'Společnost';

  @override
  String get profileTaxNumber => 'Daňové číslo';

  @override
  String get profileConfirmDeleteAddress =>
      'Opravdu chcete smazat tuto adresu?';

  @override
  String get profileConfirmDeleteInvoice =>
      'Opravdu chcete smazat tuto fakturu?';

  @override
  String get commonGroupOwner => 'vlastník';

  @override
  String get commonGroupAdmin => 'Admin';

  @override
  String get groupSearchMembers => 'Hledat členy';

  @override
  String groupTotalMembers(int count) {
    return 'Členové $count';
  }

  @override
  String get chatRemoveFromGroup => 'Odebrat ze skupiny';

  @override
  String groupConfirmRemoveMember(String name) {
    return 'Opravdu chcete odebrat \"$name\" ze skupiny?';
  }

  @override
  String get chatUnknownSong => 'Neznámá píseň';

  @override
  String get chatUnknownArtist => 'Neznámý umělec';

  @override
  String get chatUnknownContact => 'Neznámý kontakt';

  @override
  String get chatPersonalCard => 'Kontaktní karta';

  @override
  String get chatSingleChoice => 'Svobodný';

  @override
  String get chatMultiChoice => 'Multi';

  @override
  String get chatEnded => 'Skončilo';

  @override
  String get chatEndPollButton => 'Ukončit hlasování';

  @override
  String get chatPollHint =>
      'Anketa se zobrazí v chatu. Členové skupiny mohou hlasovat.';

  @override
  String get chatSearchSongOrArtist => 'Vyhledejte skladbu nebo interpreta';

  @override
  String get chatNoSongsFound => 'Nebyly nalezeny žádné skladby';

  @override
  String get chatSongNameOptional => 'Název skladby (volitelné)';

  @override
  String get chatEnterSongName => 'Zadejte název skladby';

  @override
  String get chatArtistNameOptional => 'Jméno interpreta (volitelné)';

  @override
  String get chatEnterArtistName => 'Zadejte jméno interpreta';

  @override
  String get chatRealTimeLocationSharing =>
      'Sdílení polohy v reálném čase ve vývoji...';

  @override
  String get profileVoiceCallFeatureInDev =>
      'Funkce hlasového volání ve vývoji...';

  @override
  String get profileReportFeatureInDev => 'Funkce hlášení ve vývoji...';

  @override
  String get profileShareFeatureInDev => 'Sdílejte funkci ve vývoji...';

  @override
  String get profileQrCodeFeatureInDev => 'Funkce QR kódu ve vývoji...';

  @override
  String get qrcodeScanQrToAddMe =>
      'Naskenujte QR kód výše a přidejte si mě jako přítele';

  @override
  String get qrcodeSaveToAlbum => 'Uložit do alba';

  @override
  String get qrcodeChangeStyle => 'Změnit styl';

  @override
  String get qrcodeCopyId => 'Zkopírovat ID';

  @override
  String get qrcodeIdCopied => 'ID zkopírováno';

  @override
  String get qrcodeMoreStylesFeatureComingSoon => 'Další styly již brzy';

  @override
  String get profileBio => 'Bio';

  @override
  String get profileHomeServer => 'Server';

  @override
  String get profileShareContactCard => 'Sdílet kartu kontaktu';

  @override
  String get profileRemoveFromBlacklist => 'Odebrat z černé listiny';

  @override
  String get profileConfirmAddBlacklist =>
      'Opravdu chcete tohoto uživatele přidat na černou listinu? Nebudete od nich dostávat zprávy.';

  @override
  String get profileConfirmRemoveBlacklist =>
      'Opravdu chcete tohoto uživatele odebrat z černé listiny?';

  @override
  String get profileRemarkSaved => 'Poznámka uložena';

  @override
  String get profileRemarkCleared => 'Poznámka vymazána';

  @override
  String get transferReceive => 'Příjem';

  @override
  String get transferPleaseConnectWallet => 'Nejprve připojte peněženku';

  @override
  String get transferSendRequest => 'Odeslat žádost';

  @override
  String get transferPleaseEnterValidAmount => 'Zadejte platnou částku';

  @override
  String get searchPlaceholder => 'Vyhledávání kontaktů, skupin, zpráv';

  @override
  String get searchEnterKeywordToSearch =>
      'Zadejte klíčové slovo pro zahájení vyhledávání';

  @override
  String get searchClearHistory => 'Jasný';

  @override
  String searchNoResultsForQuery(String query) {
    return 'Pro výraz \"$query\" nebyly nalezeny žádné výsledky';
  }

  @override
  String get searchAllResults => 'všechny';

  @override
  String get searchInChat => 'Hledat v chatu';

  @override
  String get searchContactLabel => 'Kontakt';

  @override
  String get searchGroupLabel => 'Skupina';

  @override
  String get searchConversationLabel => 'Konverzace';

  @override
  String get searchMessageLabel => 'Zpráva';

  @override
  String get settingsSecurityTitle => 'Bezpečnost';

  @override
  String get settingsKeyBackup => 'Záloha klíčů';

  @override
  String get settingsBackupEncryptionKeys => 'Záložní šifrovací klíče';

  @override
  String settingsKeysBackedUp(int count) {
    return 'Zálohované klíče $count';
  }

  @override
  String get settingsBackupNotSet => 'Záloha není nastavena';

  @override
  String get settingsRestoreKeys => 'Obnovit klíče';

  @override
  String get settingsRestoreKeysFromBackup =>
      'Obnovte šifrovací klíče ze zálohy';

  @override
  String get settingsExportKeys => 'Exportovat klíče';

  @override
  String get settingsExportKeysToFile => 'Export klíčů do souboru';

  @override
  String get settingsLoggedInDevices => 'Přihlášená zařízení';

  @override
  String get settingsNoOtherDevices => 'Žádná další zařízení';

  @override
  String get settingsVerified => 'Ověřeno';

  @override
  String get settingsUnverified => 'Neověřeno';

  @override
  String get settingsAdvanced => 'Pokročilé';

  @override
  String get settingsCrossSigning => 'Křížové podepisování';

  @override
  String get settingsEnabled => 'Povoleno';

  @override
  String get settingsNotEnabled => 'Není povoleno';

  @override
  String get settingsResetEncryption => 'Obnovit šifrování';

  @override
  String get settingsDeleteAllEncryptionKeys =>
      'Odstraňte všechny šifrovací klíče';

  @override
  String get settingsEncryptionNotSupported => 'Šifrování není podporováno';

  @override
  String get settingsNotInitialized => 'Neinicializováno';

  @override
  String get settingsBackupKeyTitle => 'Záložní klíče';

  @override
  String get settingsBackupKeyMessage =>
      'Vytvořit novou zálohu klíče? To vám pomůže obnovit šifrované zprávy na novém zařízení.';

  @override
  String get settingsBackup => 'Zálohování';

  @override
  String get settingsRestoreKeyTitle => 'Obnovit klíče';

  @override
  String get settingsRestoreKeyMessage =>
      'Chcete-li obnovit šifrované zprávy, zadejte heslo pro obnovení nebo klíč pro obnovení.';

  @override
  String get settingsRestore => 'Obnovit';

  @override
  String get settingsExportKeyTitle => 'Exportovat klíče';

  @override
  String get settingsExportKeyMessage =>
      'Exportovaný soubor klíče obsahuje všechny vaše šifrovací klíče. Prosím, uschovejte to.';

  @override
  String get settingsExport => 'Exportovat';

  @override
  String settingsDeviceIdLabel(String deviceId) {
    return 'ID zařízení: $deviceId';
  }

  @override
  String get settingsDeviceStatusVerified => 'Stav: Ověřeno';

  @override
  String get settingsDeviceStatusUnverified => 'Stav: Neověřeno';

  @override
  String settingsLastActiveLabel(String lastSeen) {
    return 'Naposledy aktivní: $lastSeen';
  }

  @override
  String get settingsVerifyThisDevice => 'Ověřte toto zařízení';

  @override
  String get settingsCrossSigningAlreadyEnabled =>
      'Křížové podepisování je již povoleno';

  @override
  String get settingsCrossSigningSetupSuccess =>
      'Nastavení křížového podepisování bylo úspěšné';

  @override
  String get settingsResetEncryptionTitle => 'Obnovit šifrování';

  @override
  String get settingsResetEncryptionWarning =>
      'Upozornění: Tímto smažete všechny vaše šifrovací klíče. Předchozí zašifrované zprávy nebudete moci dešifrovat. Tuto akci nelze vrátit zpět.';

  @override
  String get settingsReset => 'Resetovat';

  @override
  String get settingsBackupSuccess => 'Klíče byly úspěšně zálohovány';

  @override
  String get settingsBackupFailed => 'Zálohování se nezdařilo';

  @override
  String get settingsRecoveryKey => 'Obnovovací klíč';

  @override
  String get settingsRecoveryKeySaveWarning =>
      'Uložte si prosím tento obnovovací klíč na bezpečném místě. Budete jej potřebovat k obnovení šifrovaných zpráv na novém zařízení.';

  @override
  String get settingsRecoveryKeySaved => 'Uložil jsem to';

  @override
  String get settingsRestoreSuccess => 'Klíče byly úspěšně obnoveny';

  @override
  String get settingsRestoreFailed => 'Obnovení se nezdařilo';

  @override
  String get settingsPassword => 'Heslo';

  @override
  String get settingsEnterRecoveryKey => 'Zadejte klíč pro obnovení';

  @override
  String get settingsEnterPassword => 'Zadejte heslo';

  @override
  String get settingsExportSuccess =>
      'Klíče byly úspěšně exportovány do zálohy serveru';

  @override
  String get settingsExportNeedBackupFirst =>
      'Nejprve prosím vytvořte zálohu klíče';

  @override
  String get settingsExportFailed => 'Export se nezdařil';

  @override
  String get settingsResetSuccess => 'Resetování šifrování bylo úspěšné';

  @override
  String get settingsResetFailed => 'Resetování se nezdařilo';

  @override
  String get callLeaveMeetingConfirm => 'Opravdu chcete schůzku opustit?';

  @override
  String chatPokedSomeone(String name, String suffix) {
    return 'šťouchaný $name$suffix';
  }

  @override
  String get chatNoContactsToAdd =>
      'Nejsou k dispozici žádné kontakty k přidání';

  @override
  String get chatAddMembers => 'Přidat členy';

  @override
  String chatInvitedMembers(int count) {
    return 'Pozvaní členové $count';
  }

  @override
  String chatInviteFailed(String error) {
    return 'Pozvání se nezdařilo: $error';
  }

  @override
  String get chatMemberRemoved => 'Člen odebrán';

  @override
  String chatRemoveFailed(String error) {
    return 'Odebrání se nezdařilo: $error';
  }

  @override
  String get chatRealTimeLocationShareMessage =>
      'Po sdílení uvidí druhá strana vaši polohu v reálném čase po dobu 1 hodiny.';

  @override
  String get chatStartSharing => 'Začněte sdílet';

  @override
  String get chatLocationServiceNotEnabled =>
      'Služba určování polohy není povolena';

  @override
  String get chatEnableLocationService =>
      'Chcete-li používat tuto funkci, povolte službu určování polohy';

  @override
  String get chatGoToSettings => 'Přejděte do Nastavení';

  @override
  String get chatLocationPermissionRequired =>
      'Tato funkce vyžaduje oprávnění k poloze';

  @override
  String get chatLocationPermissionDeniedPermanent =>
      'Povolení k poloze bylo trvale odepřeno. Povolte jej prosím v nastavení.';

  @override
  String get chatLocationPermissionDenied => 'Povolení k poloze odepřeno';

  @override
  String get chatGettingLocation => 'Získávání polohy...';

  @override
  String chatGetLocationFailed(String error) {
    return 'Nepodařilo se získat polohu: $error';
  }

  @override
  String get chatMapPreview => 'Náhled mapy';

  @override
  String get chatSearchLocation => 'Vyhledat místo';

  @override
  String chatRedPacketSent(String amount, String token) {
    return 'Odeslán červený paket $amount $token';
  }

  @override
  String get chatTransferDefault => 'Přenést';

  @override
  String chatTransferSent(String amount, String token) {
    return 'Odeslán převod $amount $token';
  }

  @override
  String chatPickFileFailed(String error) {
    return 'Nepodařilo se vybrat soubor: $error';
  }

  @override
  String get chatFileSizeLimit => 'Velikost souboru nesmí přesáhnout 50 MB';

  @override
  String chatFileSending(String filename) {
    return 'Odesílám soubor: $filename';
  }

  @override
  String chatSendFileFailed(String error) {
    return 'Odeslání souboru se nezdařilo: $error';
  }

  @override
  String chatContactCardSent(String name) {
    return 'Odeslána kontaktní karta $name';
  }

  @override
  String get chatFavoritesFeature => 'Oblíbené';

  @override
  String get chatCouponsFeature => 'kupony';

  @override
  String get chatGiftFeature => 'Dárek';

  @override
  String chatSharedMusic(String name) {
    return 'Sdílené $name';
  }

  @override
  String get chatEndPollTitle => 'Ukončit hlasování';

  @override
  String get chatEndPollConfirmMessage =>
      'Opravdu chcete ukončit toto hlasování? Po ukončení bude hlasování uzavřeno.';

  @override
  String get chatPollEndedMessage => 'Anketa skončila';

  @override
  String get chatConnectingCall => 'Připojování...';

  @override
  String get chatMuteCall => 'Ztlumit';

  @override
  String get chatSpeakerOff => 'Vypnutý reproduktor';

  @override
  String get chatSpeakerOn => 'Mluvčí';

  @override
  String get chatCameraOn => 'Kamera zapnutá';

  @override
  String get chatCameraOff => 'Kamera je vypnutá';

  @override
  String get chatHangUp => 'Zavěste';

  @override
  String get chatSelectForwardTargetTitle => 'Vyberte Dopředný cíl';

  @override
  String get chatNoForwardableChat =>
      'Nejsou k dispozici žádné chaty pro přeposílání';

  @override
  String get chatNoMatchingChat => 'Nebyly nalezeny žádné odpovídající chaty';

  @override
  String get chatLocationTitle => 'Umístění';

  @override
  String get chatSendButton => 'Odeslat';

  @override
  String get chatRetryButton => 'Zkuste to znovu';

  @override
  String get chatSearchContactHint => 'Hledat kontakty';

  @override
  String get chatShareMusic => 'Sdílejte hudbu';

  @override
  String get chatRecentPlayed => 'Nedávné';

  @override
  String get chatMyFavorites => 'Oblíbené';

  @override
  String get chatNetworkLink => 'Odkaz';

  @override
  String get chatLocalFile => 'Místní';

  @override
  String get chatPasteMusicLink => 'Vložte odkaz na hudbu';

  @override
  String get chatShareMusicButton => 'Sdílejte hudbu';

  @override
  String get chatSelectLocalAudio => 'Vyberte Místní zvukový soubor';

  @override
  String get chatSupportedAudioFormats => 'Podporuje MP3, M4A, WAV, FLAC atd.';

  @override
  String get chatSelectFileButton => 'Vyberte Soubor';

  @override
  String get chatPleaseEnterMusicLink => 'Zadejte odkaz na hudbu';

  @override
  String get chatPleaseEnterValidLink => 'Zadejte prosím platnou adresu URL';

  @override
  String get chatSharedSong => 'Sdílená píseň';

  @override
  String get chatSelectMember => 'Vyberte Člen';

  @override
  String get chatSearchMemberHint => 'Hledat členy';

  @override
  String get chatNoMatchingMembers =>
      'Nebyli nalezeni žádní odpovídající členové';

  @override
  String get commonUnknownMember => 'Neznámý';

  @override
  String chatSelectedMessagesCount(int count) {
    return 'Vybrané zprávy $count';
  }

  @override
  String get chatSearchContactsOrGroups => 'Hledat kontakty nebo skupiny';

  @override
  String get chatVideoTitle => 'Video';

  @override
  String get chatLoadingText => 'Načítání...';

  @override
  String get chatVideoLoadFailed => 'Načtení videa se nezdařilo';

  @override
  String get chatPlayerInitFailed => 'Inicializace přehrávače se nezdařila';

  @override
  String get chatCreatePollTitle => 'Vytvořit anketu';

  @override
  String get chatSubmitPoll => 'Odeslat';

  @override
  String get chatPollQuestionLabel => 'Anketní otázka';

  @override
  String get chatEnterPollQuestionHint => 'Zadejte dotaz do ankety';

  @override
  String get chatPollOptionsLabel => 'Možnosti hlasování';

  @override
  String chatOptionHintWithIndex(int index) {
    return 'Možnost $index';
  }

  @override
  String get chatAddOptionButton => 'Přidat možnost';

  @override
  String get chatPollSettingsLabel => 'Nastavení ankety';

  @override
  String get chatSelectionType => 'Typ výběru';

  @override
  String get chatSingleChoiceLabel => 'Svobodný';

  @override
  String get chatMultiChoiceLabel => 'Multi';

  @override
  String get chatAnonymousPollSwitch => 'Anonymní hlasování';

  @override
  String get chatPleaseEnterQuestion => 'Zadejte dotaz do ankety';

  @override
  String get chatAtLeastTwoOptions => 'Jsou vyžadovány alespoň 2 možnosti';

  @override
  String chatConfirmWithCount(int count) {
    return 'Potvrdit ($count)';
  }

  @override
  String get authEmailVerificationTitle => 'Ověření e-mailem';

  @override
  String get authEnterValidEmailAddress =>
      'Zadejte prosím platnou e-mailovou adresu';

  @override
  String authVerificationCodeSentTo(String email) {
    return 'Ověřovací kód byl odeslán na $email';
  }

  @override
  String authSendCodeFailed(String error) {
    return 'Kód se nepodařilo odeslat: $error';
  }

  @override
  String get authVerificationSuccess => 'Ověření proběhlo úspěšně';

  @override
  String get authVerificationFailed => 'Ověření se nezdařilo';

  @override
  String authVerificationCodeError(String error) {
    return 'Chyba ověřovacího kódu: $error';
  }

  @override
  String get commonEnterVerificationCode => 'Zadejte ověřovací kód';

  @override
  String get authEnterYourEmail => 'Zadejte email';

  @override
  String authWeSentCodeTo(String email) {
    return 'Poslali jsme 6místný kód na\n$email';
  }

  @override
  String get authEnterEmailForCode =>
      'Zadejte svou e-mailovou adresu, zašleme vám ověřovací kód';

  @override
  String get commonSendVerificationCode => 'Odeslat ověřovací kód';

  @override
  String get authResendVerificationCode => 'Znovu odeslat ověřovací kód';

  @override
  String authCanResendAfter(int seconds) {
    return 'Lze znovu odeslat po $seconds sekundách';
  }

  @override
  String get commonChangeEmail => 'Změnit e-mail';

  @override
  String get contactAddToContacts => 'Přidat do Kontaktů';

  @override
  String get contactAddingToContacts => 'Přidávání...';

  @override
  String get contactAddedToContacts => 'Přidáno do kontaktů';

  @override
  String contactAddFailedWithError(String error) {
    return 'Přidání se nezdařilo: $error';
  }

  @override
  String get contactAddPhone => 'Přidat telefon';

  @override
  String get contactAddTag => 'Přidejte značky';

  @override
  String get contactAddText => 'Přidejte text';

  @override
  String get contactAddPhoto => 'Přidat fotku';

  @override
  String contactGroupCountLabel(int count) {
    return 'Skupiny $count';
  }

  @override
  String get contactAddedViaSearch => 'Přidáno pomocí vyhledávání';

  @override
  String get contactAddTime => 'Přidejte čas';

  @override
  String get contactDoneButton => 'Hotovo';

  @override
  String get callWaitingForParticipants => 'Čekání na připojení účastníků...';

  @override
  String callParticipantMe(String name) {
    return '$name (já)';
  }

  @override
  String get callSharingLabel => 'Sdílení';

  @override
  String callScreenSharingBy(String name) {
    return '$name sdílí obrazovku';
  }

  @override
  String callParticipantCount(int count) {
    return 'Účastníci $count';
  }

  @override
  String get callMuteLabel => 'Ztlumit';

  @override
  String get callUnmuteLabel => 'Zapnout zvuk';

  @override
  String get callTurnOffVideo => 'Vypněte video';

  @override
  String get callTurnOnVideo => 'Zapněte video';

  @override
  String get callShareScreen => 'Sdílet obrazovku';

  @override
  String get callStopSharing => 'Přestat sdílet';

  @override
  String get callSwitchCameraLabel => 'Přepnout';

  @override
  String get callLeaveLabel => 'Odejděte';

  @override
  String get callParticipantsLabel => 'Účastníci';

  @override
  String get callJoiningMeeting => 'Připojování ke schůzce...';

  @override
  String chatPollVotesFormat(int count, String percentage) {
    return '$count hlasy ($percentage %)';
  }

  @override
  String chatPollParticipantsFormat(int count) {
    return 'Účastníci $count';
  }

  @override
  String get commonTapToRetry => 'Klepnutím to zkuste znovu';

  @override
  String get chatDefaultRedPacketGreeting => 'Všechno nejlepší k prosperitě';

  @override
  String get groupAllowOthersToSearchAndJoin =>
      'Umožněte ostatním hledat a připojit se';

  @override
  String get groupConfirmClearChatHistory =>
      'Opravdu chcete vymazat historii chatu?';

  @override
  String get groupCreateGroupToChat => 'Vytvořte skupinu a začněte chatovat';

  @override
  String get groupEditGroupAnnouncement => 'Upravit oznámení skupiny';

  @override
  String get groupEditGroupDescription => 'Upravit popis skupiny';

  @override
  String get groupEnterGroupAnnouncement => 'Zadejte oznámení skupiny';

  @override
  String chatErrorWithMessage(String message) {
    return 'Chyba: $message';
  }

  @override
  String groupMemberCountClickToCopy(int count) {
    return 'Členové $count, kliknutím zkopírujte ID skupiny';
  }

  @override
  String get chatMusicLinkLabel => 'Odkaz na hudbu';

  @override
  String get chatNoMediaUrlAvailable =>
      'Není k dispozici žádná adresa URL média';

  @override
  String get groupNoPermissionToEditGroupName =>
      'Nemáte oprávnění upravovat název skupiny';

  @override
  String get chatRedPacketTransferCannotForward =>
      'Červené pakety a přenosy nelze přeposílat';

  @override
  String get authEmailAddress => 'E-mailová adresa';

  @override
  String get commonEnterEmailAddress => 'Zadejte e-mailovou adresu';

  @override
  String get authEmailRecoveryHint => 'Slouží k obnovení hesla';

  @override
  String get commonInvalidEmailFormat =>
      'Zadejte prosím platnou e-mailovou adresu';

  @override
  String get authOptional => 'Volitelné';

  @override
  String get authResetPassword => 'Obnovit heslo';

  @override
  String get authEnterRegisteredEmail =>
      'Zadejte e-mailovou adresu, se kterou jste se registrovali';

  @override
  String get authSendResetCode => 'Odeslat resetovací kód';

  @override
  String authResetCodeSent(String email) {
    return 'Resetovací kód byl odeslán na $email';
  }

  @override
  String get authEnterResetCode => 'Zadejte resetovací kód';

  @override
  String get authSetNewPassword => 'Nastavit nové heslo';

  @override
  String get commonConfirmNewPassword => 'Potvrďte nové heslo';

  @override
  String get commonNewPassword => 'Nové heslo';

  @override
  String get authPasswordResetSuccess =>
      'Resetování hesla bylo úspěšné. Přihlaste se prosím pomocí svého nového hesla.';

  @override
  String get authResetPasswordFailed => 'Resetování hesla se nezdařilo';

  @override
  String get settingsChangePassword => 'Změnit heslo';

  @override
  String get settingsCurrentPassword => 'Aktuální heslo';

  @override
  String get settingsEnterCurrentPassword => 'Zadejte aktuální heslo';

  @override
  String get settingsEnterNewPassword => 'Zadejte nové heslo';

  @override
  String get settingsPasswordChanged =>
      'Heslo bylo úspěšně změněno. Přihlaste se prosím pomocí svého nového hesla.';

  @override
  String get settingsChangePasswordFailed => 'Změna hesla se nezdařila';

  @override
  String get settingsNewPasswordMustBeDifferent =>
      'Nové heslo se musí lišit od aktuálního hesla';

  @override
  String get settingsChangePasswordInfo =>
      'Po změně hesla budete odhlášeni a musíte se přihlásit pomocí nového hesla.';

  @override
  String get settingsPasswordRequirements => 'Požadavky na heslo:';

  @override
  String get settingsSecurityNote =>
      'Z bezpečnostních důvodů se po změně hesla budete muset na všech zařízeních znovu přihlásit.';

  @override
  String get settingsSecurity => 'Bezpečnost';

  @override
  String get settingsCurrentBoundEmail => 'Aktuální vázaný email';

  @override
  String get settingsNewEmailAddress => 'Nová emailová adresa';

  @override
  String get settingsEnterNewEmail => 'Zadejte novou e-mailovou adresu';

  @override
  String get settingsVerificationCode => 'Ověřovací kód';

  @override
  String get settingsVerificationCodeSent => 'Ověřovací kód odeslán';

  @override
  String get settingsCodeSentTo => 'Ověřovací kód byl odeslán na adresu';

  @override
  String get settingsDidNotReceiveCode => 'Neobdrželi jste kód?';

  @override
  String get settingsEmailChangedSuccess => 'E-mail byl úspěšně změněn';

  @override
  String get settingsChangeEmailFailed => 'Změna e-mailu se nezdařila';

  @override
  String get settingsEmailSecurityNote =>
      'Váš e-mail slouží k obnovení hesla. Prosím, uchovejte jej v bezpečí.';

  @override
  String get commonGoogleLogin => 'Přihlaste se pomocí Google';

  @override
  String get commonAppleLogin => 'Přihlaste se pomocí Apple';

  @override
  String get commonWechat => 'WeChat';

  @override
  String get settingsLanguage => 'Jazyk';

  @override
  String get settingsLanguageChanged => 'Jazyk se změnil';

  @override
  String get settingsTranslation => 'Překlad';

  @override
  String get settingsTranslateTextTo => 'Přeložit text do';

  @override
  String get settingsTranslateDescription =>
      'Vyberte jazyk, do kterého chcete zprávy překládat.';

  @override
  String get settingsAutoTranslate => 'Automaticky překládat přijaté zprávy';

  @override
  String get settingsAutoTranslateDescription =>
      'Automaticky překládat zprávy přijaté v chatu do vámi zvoleného jazyka.';

  @override
  String get settingsBiometricLogin => 'Biometrické přihlášení';

  @override
  String authLoginWithBiometric(Object type) {
    return 'Přihlaste se pomocí $type';
  }

  @override
  String get settingsBiometricLoginEnabled => 'Biometrické přihlášení povoleno';

  @override
  String get settingsBiometricLoginDisabled =>
      'Biometrické přihlášení zakázáno';

  @override
  String get settingsEnableBiometricLogin => 'Povolit biometrické přihlášení';

  @override
  String get settingsBiometricEnabled =>
      'Povoleno – k přihlášení použijte biometrické údaje';

  @override
  String get settingsBiometricDisabled => 'Vypnuto – klepnutím povolíte';

  @override
  String get settingsBiometricNeedRelogin =>
      'Pro aktivaci biometrického přihlášení se prosím odhlaste a znovu přihlaste';

  @override
  String get authOr => 'NEBO';

  @override
  String get qrcodeCameraPermissionRestricted =>
      'Přístup k fotoaparátu je na tomto zařízení omezen';

  @override
  String get authPasskeyLabel => 'Přístupový klíč';

  @override
  String get authGoogleLabel => 'Google';

  @override
  String get authAppleLabel => 'Jablko';


  @override
  String get authSsoNotConfigured => 'Tento server nenakonfiguroval poskytovatele přihlášení SSO';
  @override
  String get authSsoLabel => 'SSO';

  @override
  String get transferAmountHintZero => '0,00';

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
      'Zadejte příponu poke, např.: na rameni';

  @override
  String get groupAlbum => 'Skupinové album';

  @override
  String get groupFiles => 'Skupinové soubory';

  @override
  String get groupImages => 'Obrázky';

  @override
  String get groupVideos => 'videa';

  @override
  String get groupTotal => 'Celkem';

  @override
  String get groupSize => 'Velikost';

  @override
  String get groupNoMedia => 'Žádná média';

  @override
  String get groupNoMediaDescription =>
      'V této skupině zatím nejsou žádné fotky ani videa';

  @override
  String get groupDocuments => 'Docs';

  @override
  String get groupNoFiles => 'Žádné soubory';

  @override
  String get groupNoFilesDescription =>
      'V této skupině zatím nejsou žádné soubory';

  @override
  String groupDownloadStarted(String filename) {
    return 'Stahování $filename...';
  }

  @override
  String get contactNoCommonGroups => 'Žádné společné skupiny';

  @override
  String get contactNoCommonGroupsDescription =>
      'Nemáte žádné společné skupiny';

  @override
  String get chatVoiceMessage => 'Hlas';

  @override
  String get chatMessage => 'Zpráva';

  @override
  String get conversationHideChat => 'Skrýt';

  @override
  String get settingsQuickReply => 'Rychlá odpověď';

  @override
  String get commonTranslate => 'Přeložit';

  @override
  String get contactCreateTag => 'Vytvořit značku';

  @override
  String get contactEnterTagName => 'Zadejte název značky';

  @override
  String get contactEditTag => 'Upravit značku';

  @override
  String get contactDeleteTag => 'Smazat značku';

  @override
  String contactDeleteTagConfirm(String tagName) {
    return 'Opravdu chcete smazat značku \"$tagName\"?';
  }

  @override
  String get contactNoTags => 'Zatím žádné značky';

  @override
  String get contactFriendPermissions => 'Oprávnění přátel';

  @override
  String get contactSetChatOnly => 'Nastavit jako pouze chat';

  @override
  String get contactChatOnlyDesc =>
      'Může chatovat pouze s vámi, ostatní obsah bude skrytý';

  @override
  String get contactHideMyMoments => 'Skrýt mé okamžiky';

  @override
  String get contactHideMyMomentsDesc => 'Tento přítel nevidí mé okamžiky';

  @override
  String get contactHideTheirMoments => 'Skryjte jejich okamžiky';

  @override
  String get contactHideTheirMomentsDesc =>
      'Nezobrazovat momentky tohoto přítele';

  @override
  String get contactHideMyStatus => 'Skrýt můj stav';

  @override
  String get contactHideMyStatusDesc =>
      'Tento přítel nevidí aktualizace mého stavu';

  @override
  String get contactNoChatOnlyFriends => 'Žádní přátelé pouze pro chat';

  @override
  String get contactNoOfficialAccounts => 'Žádné oficiální účty';

  @override
  String get contactFollowOfficialAccountsDesc =>
      'Sledujte oficiální účty a získejte nejnovější aktualizace';

  @override
  String get contactNoServiceAccounts => 'Žádné servisní účty';

  @override
  String get contactSubscribeServiceAccountsDesc =>
      'Přihlaste se k odběru servisních účtů pro pohodlné služby';

  @override
  String get contactNoEnterpriseContacts => 'Žádné podnikové kontakty';

  @override
  String get contactEnterpriseContactsDesc =>
      'Zde se zobrazí podnikové kontakty';

  @override
  String get profileCardPack => 'Balíček karet';

  @override
  String get profileOrders => 'Objednávky';

  @override
  String get profileNoOrders => 'Žádné rozkazy';

  @override
  String get profileOrdersDesc => 'Zde se zobrazí vaše objednávky';

  @override
  String get profileNoCards => 'Žádné karty';

  @override
  String get profileCardsDesc => 'Zde se zobrazí vaše karty';

  @override
  String get favoriteEnterTagsHint => 'Zadejte značky oddělené čárkami';

  @override
  String get favoriteTagsUpdated => 'Tagy byly aktualizovány';

  @override
  String get favoriteForwardedContent => 'Obsah přeposlán';

  @override
  String get favoriteEnterNoteContent => 'Zadejte obsah poznámky';

  @override
  String get favoriteNoteAdded => 'Poznámka přidána';

  @override
  String get favoriteLinkTitle => 'Název odkazu';

  @override
  String get favoriteLinkUrl => 'https://';

  @override
  String get favoriteLinkAdded => 'Odkaz přidán';

  @override
  String get contactPhotoAdded => 'Foto přidáno';

  @override
  String get contactEnterPhone => 'Zadejte telefonní číslo';

  @override
  String commonConversationWithId(String roomId) {
    return 'Konverzace: $roomId';
  }

  @override
  String commonContactWithId(String userId) {
    return 'Kontakt: $userId';
  }

  @override
  String get commonDiscover => 'Objevte';

  @override
  String commonDeveloping(String title) {
    return '$title\n(již brzy)';
  }

  @override
  String get commonPageNotFound => 'Stránka nenalezena';

  @override
  String get commonBackToHome => 'Zpět na domovskou stránku';

  @override
  String get settingsMessageNotifications => 'Upozornění na zprávy';

  @override
  String get settingsReceiveNewMessageNotifications =>
      'Přijímat upozornění na nové zprávy';

  @override
  String get settingsShowMessagePreview => 'Zobrazit náhled zprávy';

  @override
  String get settingsShowMessageContentInNotification =>
      'Zobrazit obsah zprávy v oznámení';

  @override
  String get settingsNotificationSound => 'Zvuk upozornění';

  @override
  String get settingsPlaySoundOnMessage => 'Přehrát zvuk při příjmu zpráv';

  @override
  String get commonVibration => 'Vibrace';

  @override
  String get settingsVibrateOnMessage => 'Při příjmu zpráv vibrovat';

  @override
  String get settingsDoNotDisturbMode => 'Nerušit';

  @override
  String get settingsDoNotDisturbDescription =>
      'Nedostávejte upozornění během stanovené doby';

  @override
  String get settingsStartTime => 'Čas zahájení';

  @override
  String get settingsEndTime => 'Čas ukončení';

  @override
  String get settingsDeleteQuickReply => 'Smazat rychlou odpověď';

  @override
  String get settingsEditQuickReply => 'Upravit rychlou odpověď';

  @override
  String get settingsAddQuickReply => 'Přidat rychlou odpověď';

  @override
  String get settingsManageQuickReplies => 'Správa rychlých odpovědí';

  @override
  String get settingsNoQuickReplies => 'Žádné rychlé odpovědi';

  @override
  String get settingsDefaultQuickReplies =>
      'Zobrazí se výchozí rychlé odpovědi';

  @override
  String get settingsWhoCanSee => 'Kdo může vidět';

  @override
  String get settingsLastSeen => 'Naposledy viděno';

  @override
  String get settingsHiddenChats => 'Skryté chaty';

  @override
  String get settingsMessagesLabel => 'Zprávy';

  @override
  String get settingsAllowStrangerMessages => 'Povolit cizí zprávy';

  @override
  String get settingsReceiveMessagesFromNonContacts =>
      'Přijímat zprávy od lidí, kteří nejsou v kontaktu';

  @override
  String get settingsReadReceipts => 'Přečtěte si účtenky';

  @override
  String get settingsLetOthersKnowYouRead => 'Dejte ostatním vědět, že čtete';

  @override
  String get settingsTypingIndicator => 'Indikátor psaní';

  @override
  String get settingsLetOthersKnowYouTyping =>
      'Dejte ostatním vědět, že píšete';

  @override
  String get settingsEveryone => 'Všichni';

  @override
  String get settingsContactsOnly => 'Pouze kontakty';

  @override
  String get settingsNobody => 'Nikdo';

  @override
  String settingsWhoCanSeeTitle(String title) {
    return 'Kdo může vidět $title';
  }

  @override
  String settingsVersionInfo(String version) {
    return 'Verze $version';
  }

  @override
  String get settingsCheckForUpdates => 'Zkontrolujte aktualizace';

  @override
  String get settingsOpenSourceLicenses => 'Open Source licence';

  @override
  String get settingsFeedbackAndSuggestions => 'Zpětná vazba a návrhy';

  @override
  String get settingsBuiltOnMatrix => 'Postaveno na protokolu Matrix';

  @override
  String get settingsNoHiddenChats => 'Žádné skryté chaty';

  @override
  String get settingsNoHiddenChatsDescription =>
      'Zde se zobrazí chaty, které skryjete';

  @override
  String get settingsUnhideChat => 'Odkrýt';

  @override
  String get settingsDarkMode => 'Tmavý režim';

  @override
  String get settingsFontSize => 'Velikost písma';

  @override
  String get settingsBubbleStyle => 'Bublinový styl';

  @override
  String get settingsFollowSystem => 'Sledujte systém';

  @override
  String get settingsAutoSwitchBySystem => 'Automatické přepínání systémem';

  @override
  String get settingsLightMode => 'Světelný režim';

  @override
  String get settingsAlwaysUseLightTheme => 'Vždy používejte světlé téma';

  @override
  String get settingsDarkModeOption => 'Možnost tmavého režimu';

  @override
  String get settingsAlwaysUseDarkTheme => 'Vždy používejte tmavé téma';

  @override
  String get settingsFontSizeSmall => 'Malý';

  @override
  String get settingsFontSizeStandard => 'Standardní';

  @override
  String get settingsFontSizeLarge => 'Velký';

  @override
  String get settingsFontSizeExtraLarge => 'Extra velký';

  @override
  String get settingsBubbleStyleWechat => 'styl WeChat';

  @override
  String get settingsBubbleStyleWechatDesc => 'Klasický styl bublin WeChat';

  @override
  String get settingsBubbleStyleModern => 'Moderní styl';

  @override
  String get settingsBubbleStyleModernDesc => 'Čistý moderní bublinkový styl';

  @override
  String get settingsBubbleStyleClassic => 'Klasický styl';

  @override
  String get settingsBubbleStyleClassicDesc => 'Tradiční bublinkový styl';

  @override
  String get discoverVideoChannels => 'Kanály';

  @override
  String get discoverLive => 'Živě';

  @override
  String get discoverListen => 'Poslouchejte';

  @override
  String get discoverWatch => 'Sledujte';

  @override
  String get discoverSearchDiscover => 'Hledat';

  @override
  String get discoverNearbyPeople => 'Nedaleko';

  @override
  String get discoverGames => 'Hry';

  @override
  String get discoverMiniPrograms => 'Mini programy';

  @override
  String get chatAlreadyInCall => 'Již probíhá hovor';

  @override
  String get commonConnectionFailed => 'Připojení se nezdařilo';

  @override
  String get chatCallRejected => 'Hovor byl odmítnut';

  @override
  String get chatNoAnswer => 'Žádná odpověď';

  @override
  String get commonClose => 'Zavřít';

  @override
  String get chatSelectContact => 'Vyberte možnost Kontakt';

  @override
  String get chatVoteRemoved => 'Hlas odstraněn';

  @override
  String get chatVoteChanged => 'Hlasování změněno';

  @override
  String get chatVoted => 'Hlasováno';

  @override
  String chatReplyTo(String name) {
    return 'Odpověď na $name';
  }

  @override
  String get chatCurrentLocation => 'Aktuální poloha';

  @override
  String chatNearbyPlace(int index) {
    return 'Blízké místo $index';
  }

  @override
  String chatApproximateDistance(String distance) {
    return 'O $distance';
  }

  @override
  String get chatAddress => 'Adresa';

  @override
  String get chatLatitude => 'Zeměpisná šířka';

  @override
  String get chatLongitude => 'Zeměpisná délka';

  @override
  String get groupDescriptionUpdated => 'Popis skupiny aktualizován';

  @override
  String get groupAvatarUpdated => 'Avatar skupiny byl aktualizován';

  @override
  String get groupVisibilityUpdated => 'Viditelnost skupiny aktualizována';

  @override
  String get groupChannelCreated => 'Kanál vytvořen';

  @override
  String get groupChannelUpdated => 'Kanál aktualizován';

  @override
  String get groupChannelDeleted => 'Kanál byl smazán';

  @override
  String get callDecline => 'Odmítnout';

  @override
  String get callAnswer => 'Odpověď';

  @override
  String get callIncomingVideoCall => 'Příchozí videohovor';

  @override
  String get callIncomingVoiceCall => 'Příchozí hlasový hovor';

  @override
  String get callVideoCallInProgress => 'Probíhá videohovor';

  @override
  String get callVoiceCallInProgress => 'Probíhá hlasový hovor';

  @override
  String get callReconnectingCall => 'Opětovné připojení...';

  @override
  String get callEnded => 'Hovor ukončen';

  @override
  String get callFailed => 'Hovor se nezdařil';

  @override
  String get callLivekitNotConfigured => 'LiveKit není nakonfigurován';

  @override
  String callJoinMeetingFailed(String error) {
    return 'Připojení ke schůzce se nezdařilo: $error';
  }

  @override
  String callScreenShareFailed(String error) {
    return 'Sdílení obrazovky se nezdařilo: $error';
  }

  @override
  String get profileN42BeanTitle => 'N42 Fazole';

  @override
  String get profileNoN42Bean => 'Žádná fazole N42';

  @override
  String get profileN42BeanDetails => 'Podrobnosti o fazolích N42';

  @override
  String get profileN42BeanDescription =>
      'N42 Bean je token používaný k uplatnění virtuálních položek a služeb v N42. Aktuálně dostupné pro:';

  @override
  String get profileN42BeanFeature1 => 'Exkluzivní členské nálepky a motivy';

  @override
  String get profileN42BeanFeature2 => 'Přizpůsobení chatovací bubliny';

  @override
  String get profileN42BeanFeature3 => 'Přizpůsobení červeného obalu paketu';

  @override
  String get profileN42BeanFeature4 => 'Exkluzivní přezdívka';

  @override
  String get profileN42BeanFeature5 => 'Oprávnění skupinového chatu';

  @override
  String get profileN42BeanFeature6 => 'Rozšíření cloudového úložiště';

  @override
  String get profileN42BeanFeature7 => 'Filtry krásy pro videohovory';

  @override
  String get profileN42BeanFeature8 => 'Přizpůsobení pozadí momentů';

  @override
  String get profileN42BeanFeature9 => 'Priorita VIP zákaznických služeb';

  @override
  String get profileGotIt => 'Rozumím';

  @override
  String get profileNoN42BeanRecords => 'Žádné záznamy N42 Bean';

  @override
  String get profileMoodAndThoughts => 'Nálada a myšlenky';

  @override
  String get profileStatusHappy => 'Šťastný';

  @override
  String get profileStatusCracked => 'Rozbité';

  @override
  String get profileStatusLucky => 'Štěstí';

  @override
  String get profileStatusSunny => 'Slunečno';

  @override
  String get profileStatusTired => 'Unavený';

  @override
  String get profileStatusDaydream => 'Denní snění';

  @override
  String get profileStatusRushing => 'Spěchání';

  @override
  String get profileStatusOverthinking => 'Přemýšlení';

  @override
  String get profileStatusEnergized => 'Nabitý energií';

  @override
  String get profileWorkAndStudy => 'Práce a studium';

  @override
  String get profileStatusWorking => 'Práce';

  @override
  String get profileStatusStudying => 'Studium';

  @override
  String get profileStatusBusy => 'Zaneprázdněný';

  @override
  String get profileStatusSlacking => 'Flákání';

  @override
  String get profileStatusTraveling => 'Cestování';

  @override
  String get profileStatusGoingHome => 'Jít domů';

  @override
  String get profileStatusDnd => 'Nerušit';

  @override
  String get profileActivities => 'Činnosti';

  @override
  String get profileStatusHanging => 'Setkání venku';

  @override
  String get profileStatusCheckIn => 'Přihlásit se';

  @override
  String get profileStatusExercising => 'Cvičení';

  @override
  String get profileStatusCoffee => 'Káva';

  @override
  String get profileStatusBubbleTea => 'Bubble Tea';

  @override
  String get profileStatusEating => 'Stravování';

  @override
  String get profileStatusParenting => 'Rodičovství';

  @override
  String get profileStatusSavingWorld => 'Záchrana světa';

  @override
  String get profileStatusSelfie => 'Selfie';

  @override
  String get profileRest => 'Odpočívej';

  @override
  String get profileStatusRetreat => 'Ustoupit';

  @override
  String get profileStatusHome => 'Domů';

  @override
  String get profileStatusSleeping => 'Spaní';

  @override
  String get profileStatusCatLover => 'Milovník koček';

  @override
  String get profileStatusDogWalking => 'Venčící pes';

  @override
  String get profileStatusGaming => 'Hraní';

  @override
  String get profileStatusListening => 'Poslouchání';

  @override
  String get profileEditAddress => 'Upravit adresu';

  @override
  String get profileRecipient => 'Příjemce';

  @override
  String get profileEnterRecipientName => 'Zadejte jméno příjemce';

  @override
  String get profilePhoneNumber => 'Telefonní číslo';

  @override
  String get profileEnterPhoneNumber => 'Zadejte telefonní číslo';

  @override
  String get profileRegionHint => 'Provincie/město/okres';

  @override
  String get profileDetailedAddress => 'Podrobná adresa';

  @override
  String get profileDetailedAddressHint => 'Ulice, číslo budovy atd.';

  @override
  String get profileSetAsDefaultAddress => 'Nastavit jako výchozí adresu';

  @override
  String get profilePleaseCompleteInfo => 'Vyplňte prosím všechna pole';

  @override
  String get profileEditInvoice => 'Upravit fakturu';

  @override
  String get profileInvoiceType => 'Typ faktury';

  @override
  String get profileCompanyName => 'Název společnosti';

  @override
  String get profilePersonalName => 'Osobní jméno';

  @override
  String get profileEnterCompanyName => 'Zadejte název společnosti';

  @override
  String get profileEnterName => 'Zadejte jméno';

  @override
  String get profileTaxIdNumber => 'DIČ';

  @override
  String get profileEnterTaxIdNumber => 'Zadejte daňové identifikační číslo';

  @override
  String get profileBankNameOptional => 'Název banky (volitelné)';

  @override
  String get profileEnterBankName => 'Zadejte název banky';

  @override
  String get profileBankAccountOptional => 'Bankovní účet (volitelné)';

  @override
  String get profileEnterBankAccount => 'Zadejte bankovní účet';

  @override
  String get profileCompanyAddressOptional => 'Adresa společnosti (volitelné)';

  @override
  String get profileEnterCompanyAddress => 'Zadejte adresu společnosti';

  @override
  String get profileCompanyPhoneOptional => 'Firemní telefon (volitelné)';

  @override
  String get profileEnterCompanyPhone => 'Zadejte firemní telefon';

  @override
  String get profileSetAsDefaultInvoice => 'Nastavit jako výchozí fakturu';

  @override
  String get profileRingtoneVibrate => 'Vibrovat';

  @override
  String get profileRingtoneSilent => 'Tichý';

  @override
  String get profileVibrateMode => 'Vibrační režim';

  @override
  String get profileSilentMode => 'Tichý režim';

  @override
  String profilePlayFailed(String ringtoneName) {
    return 'Nepodařilo se přehrát: $ringtoneName';
  }

  @override
  String profilePlaying(String ringtoneName) {
    return 'Hraje: $ringtoneName';
  }

  @override
  String get profileStop => 'Přestaň';

  @override
  String get profileSelectRingtone => 'Vyberte Vyzváněcí tón';

  @override
  String get profileLoadingRingtones => 'Načítání vyzváněcích tónů...';

  @override
  String get profileNoRingtonesFound => 'Nebyly nalezeny žádné vyzváněcí tóny';

  @override
  String mainMessagesWithCount(int count) {
    return 'Zprávy ($count)';
  }

  @override
  String get storyViewers => 'Diváci';

  @override
  String get storyNoViewers => 'Zatím žádní diváci';

  @override
  String get storyReplyToStory => 'Odpovědět na příběh...';

  @override
  String get commonCopiedToClipboard => 'Zkopírováno do schránky';

  @override
  String get commonMore => 'více';

  @override
  String get commonTranslating => 'Překlad...';

  @override
  String commonTranslatedFrom(String language) {
    return 'Přeloženo z $language';
  }

  @override
  String get commonTranslation => 'Překlad';

  @override
  String get commonTranslationFailed => 'Překlad se nezdařil';

  @override
  String get commonAllRead => 'Vše přečteno';

  @override
  String commonReadCount(int count) {
    return 'Čtení $count';
  }

  @override
  String get commonYouRecalledMessage => 'Vzpomněl sis na zprávu';

  @override
  String get commonMessageRecalled => 'Zpráva odvolána';

  @override
  String get commonReEdit => 'Znovu upravit';

  @override
  String get commonWalletArea => 'Oblast peněženky';

  @override
  String get callIncomingCall => 'Příchozí hovor';

  @override
  String get callMissedCall => 'Zmeškaný hovor';

  @override
  String get groupRemoveAdmin => 'Odebrat správce';

  @override
  String get chatSelectCurrency => 'Vyberte měnu';

  @override
  String get chatSelectEmoji => 'Vyberte Emoji';

  @override
  String get chatSelectRedPacketCover => 'Vyberte Cover';

  @override
  String get groupSetAsAdmin => 'Nastavit jako správce';

  @override
  String get chatVideoPlaybackFailed => 'Přehrávání videa se nezdařilo';

  @override
  String get groupViewProfile => 'Zobrazit profil';

  @override
  String get favoriteAddLinkComingSoon => 'Přidání funkce odkazu již brzy';

  @override
  String get favoriteNewNoteComingSoon => 'Nová funkce poznámek již brzy';

  @override
  String get qrcodeSaveFeatureComingSoon => 'Funkce ukládání již brzy';

  @override
  String get qrcodeShareFeatureComingSoon => 'Funkce sdílení již brzy';

  @override
  String qrcodeProcessFailed(String error) {
    return 'Nepodařilo se zpracovat QR kód: $error';
  }

  @override
  String get securityDeviceIdRequired => 'ID zařízení je povinné';

  @override
  String securityVerificationStartFailed(String error) {
    return 'Nepodařilo se spustit ověření: $error';
  }

  @override
  String get securityVerificationFailed => 'Ověření se nezdařilo';

  @override
  String securityVerificationFailedWithReason(String reason) {
    return 'Ověření se nezdařilo: $reason';
  }

  @override
  String get securityEmojiMismatchRejected =>
      'Ověření zamítnuto – emotikony se neshodují';

  @override
  String get securityWaitingForDeviceAccept =>
      'Čekání na přijetí druhým zařízením...';

  @override
  String get securityVerifyDevice => 'Ověřte toto zařízení';

  @override
  String get securityConfirmEmojiMatch =>
      'Potvrďte, že se níže uvedené emotikony zobrazují na obou zařízeních ve stejném pořadí';

  @override
  String get securityEmojiDontMatch => 'Neshodují se';

  @override
  String get securityEmojiMatch => 'Shodují se';

  @override
  String get securityWaitingForDeviceConfirm =>
      'Čekání na potvrzení druhým zařízením...';

  @override
  String get securityVerificationSuccess => 'Ověření proběhlo úspěšně!';

  @override
  String get securityDeviceVerifiedTrusted =>
      'Toto zařízení je nyní ověřeno a důvěryhodné.';

  @override
  String get securityCompareEmoji => 'Porovnejte emotikony na obou zařízeních';

  @override
  String get securityCompareNumbers => 'Porovnejte čísla na obou zařízeních';

  @override
  String get commonTryAgain => 'Zkuste to znovu';

  @override
  String get commonDone => 'Hotovo';

  @override
  String get chatExportTitle => 'Exportovat chat';

  @override
  String get chatExportSuccess => 'Export byl úspěšný';

  @override
  String chatExportFailed(String error) {
    return 'Export se nezdařil: $error';
  }

  @override
  String get chatExportFormat => 'Formát exportu';

  @override
  String get chatExportHtmlDesc =>
      'Čitelné v jakémkoli prohlížeči se stylizovaným rozložením';

  @override
  String get chatExportJsonDesc =>
      'Strojově čitelný formát strukturovaných dat';

  @override
  String get chatExportDateRange => 'Časové období';

  @override
  String get chatExportAll => 'Všechny zprávy';

  @override
  String get chatExportLastWeek => 'Posledních 7 dní';

  @override
  String get chatExportLastMonth => 'Minulý měsíc';

  @override
  String get chatExportLast3Months => 'Poslední 3 měsíce';

  @override
  String get chatExportMessageCount => 'Zprávy k exportu';

  @override
  String get chatExportButton => 'Exportovat a sdílet';

  @override
  String get chatMediaGallery => 'Galerie médií';

  @override
  String get chatExportHistory => 'Exportovat historii chatu';

  @override
  String get pdfLoadFailed => 'Načtení PDF se nezdařilo';

  @override
  String pdfPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get mediaAll => 'všechny';

  @override
  String get mediaImages => 'Obrázky';

  @override
  String get mediaVideos => 'videa';

  @override
  String get mediaFiles => 'Soubory';

  @override
  String get mediaAudio => 'Zvuk';

  @override
  String mediaItemsCount(int count) {
    return '$count položky';
  }

  @override
  String get mediaNoMediaFound => 'Nebyla nalezena žádná média';

  @override
  String get spacesTitle => 'společenství';

  @override
  String get spacesCreate => 'Vytvořit komunitu';

  @override
  String get spacesJoined => 'Připojeno';

  @override
  String get spacesDiscover => 'Objevte';

  @override
  String get spacesNoJoined => 'Dosud se nepřipojily žádné komunity';

  @override
  String get spacesExplore => 'Prozkoumejte komunity';

  @override
  String get spacesNoPublic => 'Nebyly nalezeny žádné veřejné komunity';

  @override
  String get spacesJoin => 'Připojte se';

  @override
  String get spacesSubSpaces => 'Dílčí komunity';

  @override
  String get spacesChannels => 'Kanály';

  @override
  String spacesMembersCount(int count) {
    return 'Členové $count';
  }

  @override
  String get spacesPublic => 'Veřejné';

  @override
  String get spacesPrivate => 'Soukromé';

  @override
  String get spacesSuggested => 'Doporučeno';

  @override
  String spacesChannelsCount(int count) {
    return 'Kanály $count';
  }

  @override
  String get callInCallChat => 'In-Call Chat';

  @override
  String callMessagesCount(int count) {
    return 'Zprávy $count';
  }

  @override
  String get callNoMessagesYet =>
      'Zatím žádné zprávy.\nZačněte odesláním zprávy.';

  @override
  String get callTypeMessage => 'Napište zprávu...';

  @override
  String get callYouSender => 'vy';

  @override
  String get callChatLabel => 'Povídání';

  @override
  String get chatEdited => 'Upraveno';

  @override
  String get chatEditHistory => 'Upravit historii';

  @override
  String get chatOriginalMessage => 'Původní';

  @override
  String chatEditedAt(String time) {
    return 'Upraveno v $time';
  }

  @override
  String get chatViewOnce => 'Zobrazit jednou';

  @override
  String get chatViewOncePhoto => 'Zobrazit jednou fotografii';

  @override
  String get chatViewOnceVideo => 'Zobrazit jednou video';

  @override
  String get chatViewOnceViewed => 'Zobrazeno';

  @override
  String get chatViewOnceExpired => 'Platnost vypršela';

  @override
  String get chatViewOnceTap => 'Klepnutím zobrazíte';

  @override
  String get chatAutoFaceBlur => 'Automatické rozostření obličeje';

  @override
  String get chatAutoFaceBlurDesc =>
      'Automatické rozmazání obličejů při odesílání fotografií';

  @override
  String get threadReplyInThread => 'Odpověď ve vláknu';

  @override
  String threadReplies(int count) {
    return '$count odpovídá';
  }

  @override
  String get threadReply => '1 odpověď';

  @override
  String threadLatestReply(String preview) {
    return 'Nejnovější: $preview';
  }

  @override
  String get threadTitle => 'Závit';

  @override
  String get threadReplyPlaceholder => 'Odpověď ve vláknu...';

  @override
  String threadParticipants(int count) {
    return 'Účastníci $count';
  }

  @override
  String get voiceRoomTitle => 'Hlasová místnost';

  @override
  String get voiceRoomCreate => 'Vytvořit hlasovou místnost';

  @override
  String get voiceRoomJoin => 'Připojte se';

  @override
  String get voiceRoomLeave => 'Odejděte';

  @override
  String get voiceRoomEnd => 'Koncová místnost';

  @override
  String get voiceRoomRaiseHand => 'Zvedněte ruku';

  @override
  String get voiceRoomLowerHand => 'Dolní ruka';

  @override
  String get voiceRoomMute => 'Ztlumit';

  @override
  String get voiceRoomUnmute => 'Zapnout zvuk';

  @override
  String get voiceRoomHost => 'Hostitel';

  @override
  String get voiceRoomSpeakers => 'Reproduktory';

  @override
  String get voiceRoomListeners => 'Posluchači';

  @override
  String get voiceRoomLive => 'ŽIVĚ';

  @override
  String get voiceRoomEnded => 'Skončilo';

  @override
  String get voiceRoomScheduled => 'Naplánováno';

  @override
  String get voiceRoomApprove => 'Schválit';

  @override
  String get voiceRoomDemote => 'Přesunout do Posluchače';

  @override
  String voiceRoomHandRaised(String name) {
    return '$name zvedl ruku';
  }

  @override
  String get voiceRoomName => 'Název místnosti';

  @override
  String get voiceRoomTopic => 'Téma (volitelné)';

  @override
  String get voiceRoomNoActive => 'Žádné aktivní hlasové místnosti';

  @override
  String get voiceRoomConnecting => 'Připojování...';

  @override
  String get usernameTitle => 'Uživatelské jméno';

  @override
  String get usernameSet => 'Nastavit uživatelské jméno';

  @override
  String get usernameChange => 'Změnit uživatelské jméno';

  @override
  String get usernamePlaceholder => 'Zadejte uživatelské jméno';

  @override
  String get usernameAvailable => 'Uživatelské jméno je k dispozici';

  @override
  String get usernameUnavailable => 'Uživatelské jméno je již obsazeno';

  @override
  String get usernameInvalid =>
      '3-30 znaků, malá písmena, čísla, podtržítko. Musí začínat písmenem.';

  @override
  String get usernameReserved => 'Toto uživatelské jméno je rezervováno';

  @override
  String get usernameSaved => 'Uživatelské jméno bylo uloženo';

  @override
  String get usernameSearchHint => 'Hledejte podle @username';

  @override
  String get ensName => 'Název ENS';

  @override
  String get ensLinked => 'Propojeno s ENS';

  @override
  String get ensResolving => 'Řešení ENS...';

  @override
  String get ensNotFound => 'Název ENS nebyl nalezen';

  @override
  String get tokenGateTitle => 'Token Gate';

  @override
  String get tokenGateEnable => 'Povolit Token Gate';

  @override
  String get tokenGateDisable => 'Deaktivovat Token Gate';

  @override
  String get tokenGateAddRule => 'Přidat pravidlo';

  @override
  String get tokenGateRemoveRule => 'Odebrat pravidlo';

  @override
  String get tokenGateContractAddress => 'Adresa smlouvy';

  @override
  String get tokenGateMinBalance => 'Minimální zůstatek';

  @override
  String get tokenGateTokenId => 'ID tokenu (ERC-1155)';

  @override
  String get tokenGateChainId => 'ID řetězce';

  @override
  String get tokenGateVerifying => 'Ověřování držení tokenů...';

  @override
  String get tokenGateVerified => 'Ověření proběhlo úspěšně';

  @override
  String get tokenGateDenied => 'Nesplňujete požadavky na token';

  @override
  String get tokenGateOperatorAnd => 'Musí splňovat VŠECHNA pravidla';

  @override
  String get tokenGateOperatorOr => 'Musí splňovat JAKÉKOLI pravidlo';

  @override
  String get tokenGateRuleErc20 => 'Token ERC-20';

  @override
  String get tokenGateRuleErc721 => 'NFT (ERC-721)';

  @override
  String get tokenGateRuleErc1155 => 'Multi-Token (ERC-1155)';

  @override
  String get tokenGateRuleNative => 'Nativní token';

  @override
  String get tokenGateSaved => 'Tokenová brána uložena';

  @override
  String get tokenGateEnableDescription =>
      'Chcete-li se připojit, vyžadovat, aby členové drželi tokeny';

  @override
  String get tokenGateOperator => 'Logika pravidel';

  @override
  String get tokenGateRules => 'Pravidla';

  @override
  String get tokenGateSymbol => 'Symbol (volitelné)';

  @override
  String get tokenGateChain => 'řetěz';

  @override
  String get tokenGateTokenStandard => 'Token Standard';

  @override
  String get tokenGateDenialMessage => 'Zpráva o odmítnutí';

  @override
  String get tokenGateDenialMessageHint =>
      'Zpráva se zobrazí, když se ověření nezdaří';

  @override
  String get tokenGateVerifyTitle => 'Ověření tokenu';

  @override
  String get tokenGateVerifyPassed => 'Ověření proběhlo úspěšně';

  @override
  String get tokenGateVerifyFailed => 'Ověření se nezdařilo';

  @override
  String get tokenGateRetryVerify => 'Zkuste to znovu';

  @override
  String get tokenGateRequired => 'Povinné';

  @override
  String get tokenGateYourBalance => 'Vaše bilance';

  @override
  String get tokenGateRulesActive => 'pravidla aktivní';

  @override
  String get tokenGateDisabled => 'Zakázáno';

  @override
  String get ensNotBound => 'Není vázán';

  @override
  String get liveLocation => 'Živá poloha';

  @override
  String get stopLiveLocation => 'Přestat sdílet';

  @override
  String get startLiveLocation => 'Začněte sdílet';

  @override
  String get selectDuration => 'Vyberte možnost Trvání';

  @override
  String get groupChatFiles => 'Soubory chatu';

  @override
  String get groupLinks => 'Odkazy';

  @override
  String get groupNoLinks => 'Zatím žádné odkazy';

  @override
  String get chatBackground => 'Pozadí chatu';

  @override
  String get solidColors => 'Pevné barvy';

  @override
  String get gradients => 'Přechody';

  @override
  String get defaultBackground => 'Výchozí';

  @override
  String get settingsFontSizeSlider => 'Velikost písma';

  @override
  String get autoDownload => 'Automatické stahování';

  @override
  String get images => 'Obrázky';

  @override
  String get voice => 'Hlas';

  @override
  String get video => 'Video';

  @override
  String get files => 'Soubory';

  @override
  String get mobileData => 'Mobilní data';

  @override
  String get roaming => 'Roaming';

  @override
  String get storageManagement => 'Skladování';

  @override
  String get totalUsage => 'Celkové využití';

  @override
  String get cache => 'Cache';

  @override
  String get other => 'Jiné';

  @override
  String get clearCache => 'Vymazat mezipaměť';

  @override
  String get cacheCleared => 'Cache vymazána';

  @override
  String get clearCacheFailed => 'Vymazání mezipaměti se nezdařilo';

  @override
  String get confirmClearCache => 'Vymazat všechna data mezipaměti?';

  @override
  String get mapView => 'Zobrazení mapy';

  @override
  String liveLocationSharingCount(int count) {
    return '$count lidí sdílejících polohu';
  }

  @override
  String get minutes15 => '15 minut';

  @override
  String get minutes30 => '30 minut';

  @override
  String get hour1 => '1 hodina';

  @override
  String get hours8 => '8 hodin';

  @override
  String get personalCard => 'Osobní karta';

  @override
  String get downloadFailed => 'Stahování se nezdařilo';

  @override
  String get locationExpired => 'Platnost vypršela';

  @override
  String secondsRemaining(int count) {
    return '$count sekund';
  }

  @override
  String minutesRemaining(int count) {
    return '$count minut';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '$hours hodin $minutes minut';
  }

  @override
  String get favoriteMessages => 'Oblíbené';

  @override
  String get linksCopied => 'Odkaz zkopírován';

  @override
  String get noLinksFound => 'Nebyly nalezeny žádné odkazy';

  @override
  String get roomStorageRanking => 'Hodnocení místností';

  @override
  String get downloadComplete => 'Stahování dokončeno';

  @override
  String get downloading => 'Stahování...';

  @override
  String get draftSaved => 'Koncept byl uložen';

  @override
  String get voiceRecording => 'Hlasový záznam';

  @override
  String get searchLocation => 'Vyhledat místo';

  @override
  String get tapToSearch => 'Klepnutím vyhledáte';

  @override
  String get settingsThisDevice => 'Toto zařízení';

  @override
  String get settingsJustNow => 'Právě teď';

  @override
  String get settingsDeviceId => 'ID zařízení';

  @override
  String get settingsStatus => 'Stav';

  @override
  String get settingsLastActive => 'Poslední aktivní';

  @override
  String get settingsIpAddress => 'IP adresa';

  @override
  String get settingsRenameDevice => 'Přejmenujte zařízení';

  @override
  String get settingsDeviceNameHint => 'Zadejte název zařízení';

  @override
  String get settingsDeviceRenamed => 'Zařízení přejmenováno';

  @override
  String get settingsRenameFailed => 'Přejmenování se nezdařilo';

  @override
  String get settingsRemoteLogout => 'Vzdálené odhlášení';

  @override
  String settingsRemoteLogoutConfirm(String deviceName) {
    return 'Opravdu se chcete odhlásit \"$deviceName\"? Tuto akci nelze vrátit zpět.';
  }

  @override
  String get settingsDeviceLoggedOut => 'Zařízení se odhlásilo';

  @override
  String get settingsLogoutFailed => 'Odhlášení se nezdařilo';

  @override
  String get settingsLogout => 'Odhlášení';

  @override
  String get settingsVerifyIdentity => 'Ověřte identitu';

  @override
  String get settingsEnterPasswordToConfirm =>
      'Pro potvrzení této akce zadejte své heslo.';

  @override
  String get scheduledSendTitle => 'Naplánovat zprávu';

  @override
  String get scheduledSendInOneHour => 'Za 1 hodinu';

  @override
  String get scheduledSendTonight => 'Dnes večer (20:00)';

  @override
  String get scheduledSendTomorrowMorning => 'Zítra ráno (9:00)';

  @override
  String get scheduledSendCustom => 'Vyberte datum a čas';

  @override
  String get scheduledMessageLabel => 'Naplánováno';

  @override
  String get scheduledMessageCancel => 'Zrušit naplánovanou zprávu';

  @override
  String get chatLockTitle => 'Zámek chatu';

  @override
  String get chatLockEnable => 'Uzamknout tento chat';

  @override
  String get chatLockDisable => 'Odemkněte tento chat';

  @override
  String get chatLockDescription =>
      'Zamčené chaty vyžadují k otevření biometrické nebo PIN ověření';

  @override
  String get chatLockVerifyTitle => 'Chat uzamčen';

  @override
  String get chatLockVerifySubtitle => 'Ověřte pro přístup k tomuto chatu';

  @override
  String get chatLockVerifyFailed => 'Ověření se nezdařilo';

  @override
  String get chatLockEnabled => 'Chat uzamčen';

  @override
  String get chatLockDisabled => 'Chat odemčen';

  @override
  String get chatLockPinTitle => 'Zadejte PIN';

  @override
  String get chatLockPinSetTitle => 'Nastavte PIN';

  @override
  String get chatLockPinConfirmTitle => 'Potvrďte PIN';

  @override
  String get chatLockPinMismatch => 'PIN se neshoduje';

  @override
  String get chatLockUseBiometric => 'Použijte biometrické údaje';

  @override
  String get chatLockUsePin => 'Použijte PIN';

  @override
  String get mediaEditorUndo => 'Vrátit zpět';

  @override
  String get mediaEditorRedo => 'Znovu';

  @override
  String get mediaEditorCrop => 'Oříznout';

  @override
  String get mediaEditorFilter => 'Filtr';

  @override
  String get mediaEditorDraw => 'Kreslit';

  @override
  String get mediaEditorText => 'Text';

  @override
  String get aiAssistant => 'Asistent AI';

  @override
  String get aiAssistantWelcome =>
      'Dobrý den! Jsem asistent umělé inteligence N42. Jak vám mohu pomoci?';

  @override
  String get aiAssistantNotConfigured => 'Služba AI není nakonfigurována';

  @override
  String get aiAssistantSettings => 'Nastavení AI';

  @override
  String get aiAssistantClearHistory => 'Vymazat historii chatu';

  @override
  String get aiAssistantClearHistoryConfirm =>
      'Opravdu chcete vymazat celou historii chatů AI?';

  @override
  String get aiAssistantStopGenerating => 'Přestaňte generovat';

  @override
  String get aiAssistantModel => 'Model';

  @override
  String get aiAssistantTemperature => 'Teplota';

  @override
  String get aiAssistantMaxTokens => 'Maximální počet žetonů';

  @override
  String get aiAssistantContextWindow => 'Kontextové okno';

  @override
  String get aiAssistantServiceStatus => 'Stav služby';

  @override
  String get aiAssistantAvailable => 'K dispozici';

  @override
  String get aiAssistantUnavailable => 'Není k dispozici';

  @override
  String get aiSummarize => 'Shrnutí AI';

  @override
  String aiSummarizeUnread(int count) {
    return 'Shrňte nepřečtené zprávy $count';
  }

  @override
  String get aiSummarizeLoading => 'Shrnutí...';

  @override
  String get aiSummarizeError => 'Nepodařilo se shrnout';

  @override
  String get aiRewrite => 'Přepis AI';

  @override
  String get aiRewriteFormal => 'Formální';

  @override
  String get aiRewriteCasual => 'Neformální';

  @override
  String get aiRewritePlayful => 'Hravý';

  @override
  String get aiRewriteProfessional => 'Profesionální';

  @override
  String get aiRewriteAccept => 'Použijte';

  @override
  String get aiRewriteCancel => 'Zrušit';

  @override
  String get aiRewriteLoading => 'Přepisování...';

  @override
  String get aiLinkSummary => 'Shrnutí AI';

  @override
  String get aiLinkSummaryAnalyzing => 'Probíhá analýza...';

  @override
  String get chatFolderManagement => 'Správa složek';

  @override
  String get chatFolderSystem => 'Systémové složky';

  @override
  String get chatFolderCustom => 'Vlastní složky';

  @override
  String get chatFolderEmpty => 'Zatím žádné vlastní složky';

  @override
  String get chatFolderCreate => 'Vytvořit složku';

  @override
  String get chatFolderEdit => 'Upravit složku';

  @override
  String get chatFolderNameHint => 'Název složky';

  @override
  String get chatFolderAll => 'všechny';

  @override
  String get chatFolderUnread => 'Nepřečteno';

  @override
  String get chatFolderPersonal => 'Osobní';

  @override
  String get chatFolderGroups => 'Skupiny';

  @override
  String get chatFolderChannels => 'Kanály';

  @override
  String get chatFolderMuted => 'Ztlumeno';

  @override
  String get storyAddMusic => 'Přidat hudbu';

  @override
  String get storyChangeMusic => 'Změnit hudbu';

  @override
  String get storyBackgroundMusic => 'Hudba na pozadí';

  @override
  String get storyMusicPreview => 'Náhled (max 15 s)';

  @override
  String get storyChooseFromDevice => 'Vyberte z nabídky Zařízení';

  @override
  String get storyUseThisMusic => 'Použijte tuto hudbu';

  @override
  String get authPasskeyNotSupported =>
      'Přístupový klíč není na tomto zařízení podporován';

  @override
  String get authPasskeyRegister => 'Zaregistrujte přístupový klíč';

  @override
  String get authPasskeyNoRegistered =>
      'Nejsou zaregistrovány žádné přístupové klíče';

  @override
  String get authPasskeyRegisterHint =>
      'Zaregistrujte přístupový klíč pro tento účet. Samostatné přihlášení pomocí přístupového klíče bude povoleno později.';

  @override
  String get authPasskeyNameYours => 'Pojmenujte svůj přístupový klíč';

  @override
  String get authPasskeyRegistered =>
      'Přístupový klíč byl uložen do tohoto účtu';

  @override
  String get authPasskeyDeleted =>
      'Přístupový klíč byl z tohoto účtu odstraněn';

  @override
  String authPasskeyDeleteConfirm(String name) {
    return 'Smazat přístupový klíč \"$name\"? Než později použijete přihlášení pomocí hesla, budete jej muset znovu zaregistrovat.';
  }

  @override
  String get momentVisibilityPublic => 'Veřejné';

  @override
  String get momentVisibilityPrivate => 'Soukromé';

  @override
  String get momentVisibilityPartial => 'Vybraní přátelé';

  @override
  String get momentVisibilityExcluded => 'Vyloučit některé přátele';

  @override
  String momentUserMoments(String userName) {
    return 'Okamžiky $userName';
  }

  @override
  String get momentForwardTo => 'Předat dál';

  @override
  String get momentForwardSuccess => 'Úspěšně předáno';

  @override
  String get momentSelectFriends => 'Vyberte Přátelé';

  @override
  String get momentSelectTags => 'Vyberte podle značek';

  @override
  String momentSelectedCount(int count) {
    return 'Vybráno ($count)';
  }

  @override
  String get momentNoMomentsYet => 'Zatím žádné momenty';

  @override
  String get momentForwardMoment => 'Okamžik vpřed';

  @override
  String get momentAddComment => 'Přidat komentář...';

  @override
  String momentForwardContent(String content) {
    return '[Moment] $content';
  }

  @override
  String get momentDeleteMoment => 'Smazat okamžik';

  @override
  String get momentDeleteConfirm => 'Opravdu chcete tento okamžik smazat?';

  @override
  String get momentComment => 'Komentář';

  @override
  String get momentWriteComment => 'Napište komentář...';

  @override
  String get momentLike => 'Jako';

  @override
  String get momentUnlike => 'Na rozdíl od';

  @override
  String get momentForward => 'Vpřed';

  @override
  String get momentDelete => 'Smazat';

  @override
  String get momentReply => 'odpovědět';

  @override
  String get momentMoment => 'Okamžik';

  @override
  String momentLikesCount(int count) {
    return '$count se líbí';
  }

  @override
  String momentCommentsCount(int count) {
    return 'Komentáře $count';
  }

  @override
  String get momentNoComments => 'Zatím žádné komentáře';

  @override
  String get momentFailedToLoad => 'Načtení obrázku se nezdařilo';

  @override
  String momentReplyTo(String userName) {
    return 'Odpovědět uživateli $userName...';
  }

  @override
  String get momentNoConversations => 'Žádné konverzace';

  @override
  String get momentJustNow => 'právě teď';

  @override
  String momentMinutesAgo(int count) {
    return 'Před ${count}m';
  }

  @override
  String momentHoursAgo(int count) {
    return 'Před ${count}h';
  }

  @override
  String momentDaysAgo(int count) {
    return 'Před ${count}d';
  }

  @override
  String get chatGroupAnnouncementHint => 'Zadejte oznámení skupiny';

  @override
  String get chatGroupAnnouncementEmpty => 'Žádné oznámení';

  @override
  String get chatEditNickname => 'Upravit přezdívku';

  @override
  String get chatNicknameHint => 'Zadejte svou přezdívku do této skupiny';

  @override
  String get contactAddPhoneHint => 'Zadejte telefonní číslo';

  @override
  String get contactNotesHint => 'Přidejte poznámky k tomuto kontaktu';

  @override
  String get reportTitle => 'Zpráva';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonHarassment => 'Obtěžování';

  @override
  String get reportReasonFraud => 'Podvod';

  @override
  String get reportReasonOther => 'Jiné';

  @override
  String get reportSubmitted => 'Zpráva předložena';

  @override
  String get reportDescription => 'Další popis (volitelné)';

  @override
  String get qrcodeSaved => 'QR kód byl uložen do alba';

  @override
  String get chatSendRedPacketInChat =>
      'Pošlete prosím červený balíček do chatu';

  @override
  String get commonSaveFailed => 'Uložení se nezdařilo';

  @override
  String get reportSelectReason => 'Vyberte prosím důvod';

  @override
  String get gameCenter => 'Hry';

  @override
  String get gameHighScore => 'Nejlepší';

  @override
  String get gameScore => 'skóre';

  @override
  String get gameOver => 'Konec hry';

  @override
  String get gamePlayAgain => 'Hrát znovu';

  @override
  String get gameLeaderboard => 'Žebříček';

  @override
  String get gamePause => 'Pozastaveno';

  @override
  String get gameResume => 'Klepnutím obnovíte';

  @override
  String get gameConfirmExit => 'Ukončit tuto hru?';

  @override
  String get gameNoScores => 'Zatím žádné skóre';

  @override
  String get game2048 => '2048';

  @override
  String get game2048Desc => 'Sloučením dlaždic dosáhnete roku 2048';

  @override
  String get gameBlockDrop => 'Block Drop';

  @override
  String get gameBlockDropDesc => 'Pokles a jasné linie';

  @override
  String get gameMinesweeper => 'Hledání min';

  @override
  String get gameMinesweeperDesc => 'Najděte všechny bezpečné buňky';

  @override
  String get gameMatch3 => 'zápas 3';

  @override
  String get gameMatch3Desc => 'Spojte 3 nebo více drahokamů';

  @override
  String get gameMinesweeperEasy => 'Snadno';

  @override
  String get gameMinesweeperMedium => 'Střední';

  @override
  String get gameMinesLeft => 'Miny vlevo';

  @override
  String get gameTimeLeft => 'Čas';

  @override
  String get gameLevel => 'úroveň';

  @override
  String get gameNext => 'Další';

  @override
  String get gameBestTime => 'Nejlepší čas';

  @override
  String get gameNewRecord => 'Nový rekord!';

  @override
  String get gameLines => 'Čáry';

  @override
  String get storyMyStory => 'Můj příběh';

  @override
  String get storageSmartCleanup => 'Chytré čištění';

  @override
  String get storageOldMediaFiles => 'Staré mediální soubory';

  @override
  String get storageLargeFiles => 'Velké soubory';

  @override
  String get storageAppCache => 'Mezipaměť aplikace';

  @override
  String get storageSettings => 'Nastavení úložiště';

  @override
  String get storageAutoCleanup => 'Automatické čištění';

  @override
  String storageAutoCleanupDesc(int days) {
    return 'Automaticky čistit soubory starší než $days dnů';
  }

  @override
  String get storageCleanupPeriod => 'Období čištění';

  @override
  String get storagePreserveThumbnails => 'Zachovat miniatury';

  @override
  String get storagePreserveThumbnailsDesc =>
      'Během čištění ponechejte miniatury obrázků';

  @override
  String get storageWarningHigh =>
      'Využití úložiště je vysoké. Zvažte vyčištění starých souborů.';

  @override
  String get storageWarningCritical =>
      'Úložiště je kriticky málo. Ukliďte prosím do volného místa.';

  @override
  String storageFreed(String size, int count) {
    return 'Uvolněné $size (soubory $count)';
  }

  @override
  String storageDays(int days) {
    return '$days dní';
  }

  @override
  String storageViewAllRooms(int count) {
    return 'Zobrazit všechny pokoje $count';
  }

  @override
  String get storageNoFiles => 'Nebyly nalezeny žádné soubory';

  @override
  String get storageFilePinned => 'Připnuto';

  @override
  String storageDeleteSelected(int count) {
    return 'Smazat vybrané soubory $count? Lze je znovu stáhnout ze serveru.';
  }

  @override
  String get backupRestore => 'Zálohování a obnovení';

  @override
  String get backupCreate => 'Vytvořit zálohu';

  @override
  String get backupCreateDesc =>
      'Zálohujte svá nastavení a šifrovací klíče. Zprávy budou obnoveny ze serveru po opětovném přihlášení.';

  @override
  String get backupIncludeKeys => 'Zahrnout šifrovací klíče';

  @override
  String get backupIncludeKeysDesc => 'Vyžaduje se pro čtení šifrovaných zpráv';

  @override
  String get backupPasswordProtect => 'Ochrana heslem';

  @override
  String get backupEnterPassword => 'Zadejte záložní heslo';

  @override
  String get backupHistory => 'Historie zálohování';

  @override
  String get backupNoBackups => 'Zatím žádné zálohy';

  @override
  String get backupRestore2 => 'Obnovit';

  @override
  String get backupDelete => 'Smazat';

  @override
  String get backupDeleteConfirm =>
      'Opravdu chcete tuto zálohu smazat? Toto nelze vrátit zpět.';

  @override
  String get backupRestoreFromFile => 'Obnovit ze souboru';

  @override
  String get backupRestoreFromFileDesc =>
      'Importujte soubor .n42backup z jiného zařízení nebo předchozí zálohy.';

  @override
  String get backupChooseFile => 'Vyberte Záložní soubor';

  @override
  String get backupRestoring => 'Obnovování...';

  @override
  String backupCreated(int rooms, int messages) {
    return 'Vytvořená záloha: místnosti $rooms, zprávy $messages';
  }

  @override
  String backupRestored(int settings, int rooms) {
    return 'Obnoveno nastavení $settings z místností $rooms';
  }

  @override
  String backupFailed(String error) {
    return 'Zálohování se nezdařilo: $error';
  }

  @override
  String get backupPasswordRequired => 'Tato záloha je chráněna heslem';

  @override
  String get blocGroupNotFound => 'Skupina nenalezena';

  @override
  String blocGroupMembersInvited(int count) {
    return 'Pozvaní členové $count';
  }

  @override
  String get blocGroupMemberRemoved => 'Člen odebrán';

  @override
  String get blocGroupAdminRemoved => 'Správce odstraněn';

  @override
  String get blocGroupLeft => 'Opustil skupinu';

  @override
  String get blocGroupDisbanded => 'Skupina se rozpadla';

  @override
  String get blocGroupJoined => 'Připojil se ke skupině';

  @override
  String get blocGroupInviteDeclined => 'Pozvánka odmítnuta';

  @override
  String get blocGroupTokenGateUpdated => 'Tokenová brána aktualizována';

  @override
  String get blocTransferProcessing => 'Zpracovává se přenos...';

  @override
  String get blocTransferCancelled => 'Převod zrušen';

  @override
  String get blocTransferFailed => 'Přenos se nezdařil';

  @override
  String get blocPaymentProcessing => 'Zpracování platby...';

  @override
  String get blocPaymentFailed => 'Platba se nezdařila';

  @override
  String get groupMaxMembers => 'Limit členů';

  @override
  String get groupMaxMembersUnlimited => 'Neomezené';

  @override
  String get groupMaxMembersHint =>
      'Zadejte limit (nechejte prázdné pro neomezené)';

  @override
  String get groupMaxMembersUpdated => 'Limit členů aktualizován';

  @override
  String get groupFull => 'Skupina je naplněna';

  @override
  String get groupChannels => 'Tématické kanály';

  @override
  String get groupChannelsEmpty => 'Zatím žádné kanály';

  @override
  String get groupChannelsCount => 'kanály';

  @override
  String get groupChannelCreate => 'Nový kanál';

  @override
  String get groupChannelName => 'Název kanálu';

  @override
  String get groupChannelTopic => 'Téma kanálu (volitelné)';

  @override
  String get groupChannelDelete => 'Smazat kanál';

  @override
  String get groupChannelDeleteConfirm =>
      'Smazat tento kanál? Všechny zprávy budou ztraceny.';

  @override
  String get groupBotSettings => 'Nastavení robota';

  @override
  String get groupBotEnabled => 'Povolit robota';

  @override
  String get groupBotWelcomeMessage => 'Šablona uvítací zprávy';

  @override
  String get groupBotWelcomeHint =>
      'Použijte \'name\' jako zástupný symbol pro jméno nového člena';

  @override
  String get groupBotConfigUpdated => 'Nastavení robota aktualizováno';

  @override
  String get groupContentFilter => 'Filtr obsahu';

  @override
  String get groupContentFilterEnabled => 'Povolit filtr klíčových slov';

  @override
  String get groupContentFilterReplace => 'Nahradit ***';

  @override
  String get groupContentFilterHide => 'Skrýt zprávu';

  @override
  String get groupContentFilterAddWord => 'Přidat klíčové slovo';

  @override
  String get groupContentFilterUpdated => 'Filtr obsahu byl aktualizován';

  @override
  String get chatSlashCommands => 'Příkazy';

  @override
  String get chatCommandPoll => '/poll — Vytvořte anketu';

  @override
  String get chatCommandAnnounce => '/announce — Odeslat oznámení';

  @override
  String get chatCommandWelcome => '/welcome — Nastavení uvítací zprávy';

  @override
  String get chatReportMessage => 'Zpráva';

  @override
  String get chatReportReason => 'Důvod zprávy';

  @override
  String get chatReportSpam => 'Spam';

  @override
  String get chatReportHarassment => 'Obtěžování';

  @override
  String get chatReportInappropriate => 'Nevhodný obsah';

  @override
  String get chatReportOther => 'Jiné';

  @override
  String get chatReportSuccess => 'Zpráva předložena';

  @override
  String get spacesName => 'Název komunity';

  @override
  String get spacesNameHint => 'např. Obchodníci s kryptoměnami';

  @override
  String get spacesNameRequired => 'Jméno je povinné';

  @override
  String get spacesDescription => 'Popis';

  @override
  String get spacesDescriptionHint => 'O čem tato komunita je?';

  @override
  String get spacesType => 'Typ komunity';

  @override
  String get spacesPublicDesc => 'Kdokoli může objevit a připojit se';

  @override
  String get spacesPrivateDesc => 'Připojit se mohou pouze pozvaní členové';

  @override
  String get spacesNotFound => 'Komunita nenalezena';

  @override
  String get spacesSearch => 'Hledat komunity...';

  @override
  String get spacesMembers => 'členové';

  @override
  String get spacesNoChannels => 'Zatím žádné kanály';

  @override
  String get spacesLeave => 'Opustit komunitu';

  @override
  String spacesLeaveConfirm(String name) {
    return 'Opravdu chcete opustit \"$name\"?';
  }

  @override
  String get spacesDelete => 'Smazat komunitu';

  @override
  String spacesDeleteConfirm(String name) {
    return 'Tím trvale smažete „$name“ a všechny jeho kanály. Tuto akci nelze vrátit zpět.';
  }

  @override
  String get spacesCreateChannel => 'Přidat kanál';

  @override
  String get spacesChannelName => 'Název kanálu';

  @override
  String get spacesChannelTopic => 'Téma (volitelné)';

  @override
  String get spacesDeleteChannel => 'Smazat kanál';

  @override
  String spacesDeleteChannelConfirm(String name) {
    return 'Opravdu chcete smazat \"#$name\"?';
  }

  @override
  String get spacesEditName => 'Upravit jméno';

  @override
  String get spacesEditDescription => 'Upravit popis';

  @override
  String spacesViewAllMembers(int count) {
    return 'Zobrazit všechny členy $count';
  }

  @override
  String spacesKickMemberTitle(String name) {
    return 'Kick $name';
  }

  @override
  String spacesBanMemberTitle(String name) {
    return 'Zákaz $name';
  }

  @override
  String get spacesPromoteAdmin => 'Povýšit na správce';

  @override
  String get spacesDemoteAdmin => 'Odebrat správce';

  @override
  String get spacesInviteMember => 'Pozvat člena';

  @override
  String get spacesInviteMemberUserId =>
      'ID uživatele (např. @user:server.com)';

  @override
  String get spacesSave => 'Uložit';

  @override
  String get settingsScreenshotProtection => 'Ochrana snímku obrazovky';

  @override
  String get settingsScreenshotProtectionDesc =>
      'Zabránit vytváření snímků obrazovky a nahrávání obrazovky';

  @override
  String get chatSelfDestructTimer => 'Sebedestrukce';

  @override
  String get chatTimerPickerTitle => 'Autodestrukční časovač';

  @override
  String get chatTimerOff => 'Vypnuto';

  @override
  String get onChainNotificationsTitle => 'On-chain Events';

  @override
  String get onChainMarkAllRead => 'Označte vše jako přečtené';

  @override
  String get onChainNoNotifications => 'Zatím žádné on-chain akce';

  @override
  String get onChainNoNotificationsDesc =>
      'Zde se zobrazí události z odebíraných kanálů';

  @override
  String get onChainViewDetails => 'Zobrazit podrobnosti';

  @override
  String get chatCommandHelp => '/help — Zobrazí všechny příkazy';

  @override
  String get chatCommandPrice => '/price — Získat cenu tokenu';

  @override
  String get chatCommandBalance => '/balance — Zobrazí zůstatek v peněžence';

  @override
  String get chatCommandChains => '/chains — Seznam 236+ podporovaných řetězců';

  @override
  String get chatMiniApps => 'Aplikace';

  @override
  String get miniAppMarketTitle => 'Mini aplikace';

  @override
  String get miniAppCategoryAll => 'všechny';

  @override
  String get miniAppSearch => 'Hledat aplikace...';

  @override
  String get miniAppFeatured => 'Nejlepší';

  @override
  String get miniAppAllApps => 'Všechny aplikace';

  @override
  String get miniAppNoResults => 'Nebyly nalezeny žádné aplikace';

  @override
  String get slideToPayLabel => '→→→ Posunutím potvrďte';

  @override
  String get slideToPayConfirming => 'Potvrzuje se...';

  @override
  String get redPacketBestLuck => 'Hodně štěstí';

  @override
  String get redPacketBestLuckCongrats => 'Hodně štěstí! Máš nejvíc!';

  @override
  String redPacketStats(int claimed, int total) {
    return 'Nárokováno na $claimed / $total';
  }

  @override
  String get redPacketStatsTotal => 'celkem';

  @override
  String redPacketGrabbedViral(String amount, String token) {
    return '🧧 popadl červený balíček • $amount $token';
  }

  @override
  String get web3SearchHint => '@matrix:id • 0x adresa peněženky • jméno.eth';

  @override
  String get web3SearchPlaceholder => 'Hledat podle ID, peněženky nebo ENS...';

  @override
  String get web3WalletAddress => 'Adresa peněženky';

  @override
  String get web3AddressCopied => 'Adresa zkopírována';

  @override
  String get web3Copy => 'Kopírovat';

  @override
  String get web3SendMessage => 'Odeslat zprávu';

  @override
  String get web3SendToWallet => 'Peněženka zpráv';

  @override
  String get web3WalletOnlyHint =>
      'Tato adresa zatím nemá účet N42. Zpráva bude doručena, když se připojí.';

  @override
  String get web3NftAvatar => 'Avatar NFT';

  @override
  String get web3ResolveFailed => 'Nepodařilo se vyřešit identitu';

  @override
  String web3EnsNotFound(String name) {
    return 'Název ENS \"$name\" nebyl nalezen';
  }

  @override
  String get web3NoN42AccountTitle => 'Žádný účet N42';

  @override
  String get web3NoN42AccountDesc =>
      'Tato adresa peněženky zatím nemá účet N42. Chcete-li začít, můžete s nimi sdílet svůj odkaz na pozvánku N42.';

  @override
  String get web3ShareInvite => 'Sdílejte pozvánku';

  @override
  String get nftPickerTitle => 'Vyberte NFT Avatar';

  @override
  String get nftPickerTabPopular => 'Populární';

  @override
  String get nftPickerTabCustom => 'Vlastní';

  @override
  String get nftPickerChain => 'řetěz';

  @override
  String get nftPickerContract => 'Adresa smlouvy';

  @override
  String get nftPickerTokenId => 'ID tokenu';

  @override
  String get nftPickerVerifyOwnership => 'Ověřte vlastnictví a náhled';

  @override
  String get nftPickerUseAsAvatar => 'Použít jako Avatar';

  @override
  String get nftPickerPreview => 'Náhled';

  @override
  String get nftPickerNotOwned => 'Toto NFT nevlastníte';

  @override
  String get nftPickerInvalidTokenId => 'Neplatné ID tokenu';

  @override
  String get nftPickerEnterBoth => 'Zadejte adresu smlouvy a ID tokenu';

  @override
  String get nftPickerInfoTitle => 'NFT Avatar — Ověřeno na řetězci';

  @override
  String get nftPickerInfoDesc =>
      'Svažte NFT, který vlastníte, jako svého avatara. Kdokoli může ověřit vlastnictví v řetězci. Zobrazeno se zlatým prstenem přes N42.';

  @override
  String get nftPickerPopularCollections => 'Populární kolekce';

  @override
  String get nftPickerWalletHint =>
      'Připojte svou peněženku N42 a automaticky zjistěte své NFT ve více než 236 řetězcích.';

  @override
  String get profileBindNftAvatar => 'Bind NFT Avatar';

  @override
  String get profileChangeAvatar => 'Změňte avatara';

  @override
  String get groupTopics => 'Témata';

  @override
  String get groupTopicsEmpty => 'Zatím žádná témata';

  @override
  String get syncInProgress => 'Synchronizace historie zpráv...';

  @override
  String get recoveryKeyReminderTitle => 'Chraňte své zprávy';

  @override
  String get recoveryKeyReminderDesc =>
      'Vytvořte obnovovací klíč pro bezpečnou synchronizaci šifrovaných zpráv mezi zařízeními';

  @override
  String get recoveryKeySetupNow => 'Nastavit nyní';

  @override
  String get recoveryKeyRemindLater => 'Připomeňte mi později';

  @override
  String get channelReadOnly =>
      'Do tohoto kanálu mohou přispívat pouze administrátoři';

  @override
  String get channelSubscribers => 'předplatitelů';

  @override
  String get channelVerified => 'Ověřený kanál';

  @override
  String get redPacketHistory => 'Historie červených paketů';

  @override
  String get redPacketSent => 'Odesláno';

  @override
  String get redPacketReceived => 'Přijato';

  @override
  String get redPacketExpired => 'Platnost vypršela';

  @override
  String get redPacketClaimed => 'Nárokováno';

  @override
  String get redPacketInsufficientBalance => 'Nedostatečná rovnováha';

  @override
  String selfDestructCountdown(String time) {
    return 'Sebedestrukce v $time';
  }

  @override
  String get messageDestroyed => 'Zpráva zničena';

  @override
  String miniAppPermissionDenied(String permission) {
    return 'Povolení odepřeno: $permission';
  }

  @override
  String get aiSuggestionGasFee => 'Co je poplatek za plyn?';

  @override
  String get aiSuggestionDefi => 'Průvodce pro začátečníky DeFi';

  @override
  String get aiSuggestionSecurity => 'Jak zkontrolovat zabezpečení smlouvy';

  @override
  String get aiSuggestionBridge => 'Křížové přemostění';

  @override
  String get channelDiscoverTitle => 'Objevte kanály';

  @override
  String get channelDiscoverSearch => 'Hledat kanály...';

  @override
  String get channelJoin => 'Připojte se';

  @override
  String get channelJoined => 'Připojeno';

  @override
  String get channelCategory => 'Kategorie';

  @override
  String slowModeCooldown(int seconds) {
    return 'Pomalý režim: čekejte ${seconds}s';
  }

  @override
  String get addressCopyAction => 'Kopírovat adresu';

  @override
  String get addressSendMessage => 'Odeslat zprávu';

  @override
  String get addressViewProfile => 'Zobrazit profil';

  @override
  String get sendToAddress => 'Odeslat na adresu peněženky';

  @override
  String get blocAuthSendVerificationCodeFailed =>
      'Odeslání ověřovacího kódu se nezdařilo';

  @override
  String get blocAuthServerNoEmailPasswordReset =>
      'Tento server nepodporuje obnovení hesla e-mailu';

  @override
  String get blocAuthResetPasswordFailed => 'Obnovení hesla se nezdařilo';

  @override
  String get blocAuthChangePasswordFailed => 'Změna hesla se nezdařila';

  @override
  String get blocAuthOldPasswordWrong => 'Nesprávné aktuální heslo';

  @override
  String get blocAuthLoginCancelled => 'Přihlášení zrušeno';

  @override
  String get blocAuthGoogleLoginFailed => 'Přihlášení Google se nezdařilo';

  @override
  String get blocAuthAppleLoginFailed => 'Přihlášení Apple se nezdařilo';

  @override
  String get blocAuthSsoLoginFailed => 'Přihlášení SSO se nezdařilo';

  @override
  String get blocAuthFacebookLoginFailed =>
      'Přihlášení na Facebook se nezdařilo';

  @override
  String get blocAuthTwitterLoginFailed => 'Přihlášení na Twitter se nezdařilo';

  @override
  String get blocAuthWeChatLoginFailed => 'Přihlášení na WeChat se nezdařilo';

  @override
  String get blocAuthWeChatNotConfigured =>
      'Přihlášení WeChat není nakonfigurováno';

  @override
  String get blocAuthWeChatNotInstalled =>
      'Nejprve si prosím nainstalujte WeChat';

  @override
  String get blocAuthPasswordWrong => 'Nesprávné heslo';

  @override
  String get blocAuthEmailAlreadyBound =>
      'Tento e-mail je již spojen s jiným účtem';

  @override
  String get blocAuthChangeEmailFailed => 'Změna e-mailu se nezdařila';

  @override
  String get blocAuthVerificationCodeInvalid =>
      'Ověřovací kód je nesprávný nebo jeho platnost vypršela';

  @override
  String get blocAuthSessionExpired =>
      'Platnost relace vypršela, přihlaste se prosím znovu';

  @override
  String get blocAuthSessionIncomplete =>
      'Údaje o relaci nejsou úplné, přihlaste se prosím znovu';
}
