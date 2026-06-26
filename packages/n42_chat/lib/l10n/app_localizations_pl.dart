// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class SPl extends S {
  SPl([String locale = 'pl']) : super(locale);

  @override
  String get commonRetry => 'Ponow';

  @override
  String get commonUnknownUser => 'Nieznany uzytkownik';

  @override
  String get transferWalletNotConnected => 'Portfel nie jest polaczony';

  @override
  String get chatCallServiceNotInitialized =>
      'Usluga polaczen nie zostala zainicjowana';

  @override
  String authLoginFailed(String error) {
    return 'Logowanie nie powiodlo sie: $error';
  }

  @override
  String get chatCallBack => 'Oddzwon';

  @override
  String get chatMissedVideoCall => 'Nieodebrane polaczenie wideo';

  @override
  String get chatMissedVoiceCall => 'Nieodebrane polaczenie glosowe';

  @override
  String get chatCallNotAnswered => 'Brak odpowiedzi';

  @override
  String get chatCallDurationLabel => 'Czas rozmowy';

  @override
  String get chatVoiceCallCancelled => 'Rozmowa głosowa anulowana';

  @override
  String get chatVideoCallCancelled => 'Rozmowa wideo anulowana';

  @override
  String get commonImage => '[Obraz]';

  @override
  String get chatVideo => '[Wideo]';

  @override
  String get chatVoice => '[Glos]';

  @override
  String get commonFile => '[Plik]';

  @override
  String get chatLocation => '[Lokalizacja]';

  @override
  String get chatUnknownMessage => '[Nieznana wiadomosc]';

  @override
  String get commonDelete => 'Usun';

  @override
  String get chatDeleteThisMessage => 'Usunąć tę wiadomość?';

  @override
  String get chatMessageDeleted => 'Wiadomość usunięta';

  @override
  String get profileNotLoggedIn => 'Nie zalogowano';

  @override
  String get chatMyLocation => 'Moja lokalizacja';

  @override
  String get commonGroupChat => 'Czat grupowy';

  @override
  String get commonSearch => 'Szukaj';

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get commonLoadFailed => 'Nie udalo sie zaladowac';

  @override
  String get commonMessages => 'Wiadomosci';

  @override
  String get commonContacts => 'Kontakty';

  @override
  String get commonMe => 'Ja';

  @override
  String get commonVoiceLoading => 'Ladowanie glosu, sprobuj pozniej';

  @override
  String get commonVoiceToTextFailed =>
      'Konwersja glosu na tekst nie powiodla sie';

  @override
  String get commonConvertToText => 'Na tekst';

  @override
  String get chatCopy => 'Kopiuj';

  @override
  String get commonForward => 'Przekaz dalej';

  @override
  String get commonUnfavorite => 'Usun z ulubionych';

  @override
  String get commonFavorite => 'Ulubione';

  @override
  String get settingsResend => 'Wyslij ponownie';

  @override
  String get chatRecall => 'Wycofaj';

  @override
  String get commonQuote => 'Cytuj';

  @override
  String get commonRemind => 'Przypomnij';

  @override
  String get chatCopied => 'Skopiowano';

  @override
  String get storySendMessageHint => 'Wyslij wiadomosc';

  @override
  String get commonMicrophonePermissionRequired =>
      'Prosze zezwolic na dostep do mikrofonu';

  @override
  String get chatMicrophonePermissionDeniedPermanent =>
      'Odmówiono pozwolenia na korzystanie z mikrofonu. Aby korzystać z wiadomości głosowych, włącz tę opcję w ustawieniach systemu.';

  @override
  String commonStartRecordingFailed(String error) {
    return 'Nie udalo sie rozpoczac nagrywania: $error';
  }

  @override
  String get commonRecordingTooShort => 'Nagranie zbyt krotkie';

  @override
  String commonStopRecordingFailed(String error) {
    return 'Nie udalo sie zatrzymac nagrywania: $error';
  }

  @override
  String get chatReleaseToCancel => 'Zwolnij, aby anulowac';

  @override
  String get chatReleaseToSend =>
      'Zwolnij, aby wyslac, przesun w gore, aby anulowac';

  @override
  String get commonHoldToTalk => 'Przytrzymaj, aby mowic';

  @override
  String get commonSend => 'Wyslij';

  @override
  String get commonAddFriend => 'Dodaj znajomego';

  @override
  String get commonChatServiceNotConnected => 'Usluga czatu nie jest polaczona';

  @override
  String contactUserNotFoundHint(String query) {
    return 'Uzytkownik \"$query\" nie zostal znaleziony\n\nWskazowki:\n• Sprobuj wprowadzic pelny identyfikator uzytkownika, np. @nazwa:serwer.com\n• Sprawdz pisownie nazwy uzytkownika';
  }

  @override
  String contactCreateChatFailed(String error) {
    return 'Nie udalo sie utworzyc czatu: $error';
  }

  @override
  String contactSearchFailed(String error) {
    return 'Wyszukiwanie nie powiodlo sie: $error';
  }

  @override
  String get contactEnterUserIdOrUsername =>
      'Wprowadz ID uzytkownika lub nazwe, aby wyszukac';

  @override
  String get contactSearching => 'Wyszukiwanie...';

  @override
  String get contactSearchUserToChat =>
      'Wyszukaj uzytkownika, aby rozpoczac czat';

  @override
  String get contactMatrixIdExample =>
      'Mozesz wprowadzic pelny identyfikator Matrix\nnp. @uzytkownik:matrix.n42.network';

  @override
  String contactUserNotFound(String username) {
    return 'Uzytkownik \"$username\" nie zostal znaleziony';
  }

  @override
  String get commonChat => 'Czat';

  @override
  String get commonSettings => 'Ustawienia';

  @override
  String get profileEditProfile => 'Edytuj profil';

  @override
  String get authLogin => 'Zaloguj sie';

  @override
  String get commonCreateGroup => 'Utworz grupe';

  @override
  String get chatError => 'Blad';

  @override
  String get commonTransfer => 'Przelew';

  @override
  String get commonReceived => 'Odebrano';

  @override
  String get commonRefunded => 'Zwrocono';

  @override
  String get commonExpired => 'Wygaslo';

  @override
  String get chatRedPacketGreeting => 'Najlepsze zyczenia';

  @override
  String get commonN42RedPacket => 'Czerwona koperta N42';

  @override
  String get commonClaimed => 'Odebrano';

  @override
  String get commonAllClaimed => 'Wszystko odebrane';

  @override
  String get chatReadAloud => 'Czytaj na głos';

  @override
  String get chatReply => 'Odpowiedz';

  @override
  String get commonEdit => 'Edytuj';

  @override
  String get chatSelectForwardTarget => 'Wybierz odbiorce';

  @override
  String commonSendCount(int count) {
    return 'Wyslij ($count)';
  }

  @override
  String contactN42Id(String id) {
    return 'ID N42: $id';
  }

  @override
  String get profileN42IdTitle => 'ID N42';

  @override
  String get profileN42Bean => 'Fasola N42';

  @override
  String get contactFriendInfo => 'Informacje o znajomym';

  @override
  String get contactFriendInfoDesc =>
      'Dodaj uwage, telefon, tagi, notatki, zdjecia i ustaw uprawnienia znajomego.';

  @override
  String get commonMoments => 'Chwile';

  @override
  String get commonSendMessage => 'Wiadomosc';

  @override
  String get contactAudioVideoCall => 'Polaczenie audio/wideo';

  @override
  String get contactVideoChannel => 'Kanal wideo';

  @override
  String get contactRemark => 'Uwaga';

  @override
  String get contactRemarkName => 'Nazwa uwagi';

  @override
  String get contactPhone => 'Telefon';

  @override
  String get contactTags => 'Tagi';

  @override
  String get contactNotes => 'Notatki';

  @override
  String get contactPhotos => 'Zdjecia';

  @override
  String get contactPermissions => 'Uprawnienia';

  @override
  String get contactChatMomentsEtc => 'Czat, Chwile, Sport itp.';

  @override
  String get contactMoreInfo => 'Wiecej informacji';

  @override
  String get contactCommonGroups => 'Wspolne grupy';

  @override
  String get contactSource => 'Zrodlo';

  @override
  String get settingsNotificationSettings => 'Powiadomienia';

  @override
  String get settingsPrivacy => 'Prywatnosc';

  @override
  String get settingsAppearance => 'Wyglad';

  @override
  String get settingsAbout => 'O aplikacji';

  @override
  String get commonLogout => 'Wyloguj';

  @override
  String get commonLogoutConfirm => 'Czy na pewno chcesz sie wylogowac?';

  @override
  String get commonSave => 'Zapisz';

  @override
  String get profileNickname => 'Pseudonim';

  @override
  String get profileEnterNickname => 'Wprowadz pseudonim';

  @override
  String get profileSignature => 'Podpis';

  @override
  String get profileAddSignature => 'Dodaj podpis';

  @override
  String get commonTakePhoto => 'Zrob zdjecie';

  @override
  String get profileChooseFromGallery => 'Wybierz z galerii';

  @override
  String profileSaveFailed(String error) {
    return 'Nie udalo sie zapisac: $error';
  }

  @override
  String get authSecureDecentralizedChat =>
      'Bezpieczna, zdecentralizowana komunikacja';

  @override
  String get commonEndToEndEncryption => 'Szyfrowanie od konca do konca';

  @override
  String get authMessagesOnlyYouCanSee =>
      'Wiadomosci widoczne tylko dla Ciebie i odbiorcy';

  @override
  String get authDecentralized => 'Zdecentralizowany';

  @override
  String get authBasedOnMatrix => 'Oparty na otwartym protokole Matrix';

  @override
  String get authWalletIntegration => 'Integracja portfela';

  @override
  String get authEasyCryptoTransfer => 'Latwe przelewy kryptowalut';

  @override
  String get authRegister => 'Zarejestruj sie';

  @override
  String get authAgreeTerms => 'Logujac sie, akceptujesz';

  @override
  String get authTermsOfService => 'Regulamin';

  @override
  String get authAnd => ' i ';

  @override
  String get authPrivacyPolicy => 'Polityke prywatnosci';

  @override
  String get authServerAddress => 'Adres serwera';

  @override
  String get authEnterServerAddress => 'Wprowadz adres serwera';

  @override
  String authConnectedTo(String serverName) {
    return 'Polaczono z $serverName';
  }

  @override
  String get authUsername => 'Nazwa uzytkownika';

  @override
  String get authEnterUsername => 'Wprowadz nazwe uzytkownika';

  @override
  String get authUsernameOrEmail => 'Nazwa użytkownika lub Email';

  @override
  String get authEnterUsernameOrEmail => 'Wprowadź nazwę użytkownika lub email';

  @override
  String get authPassword => 'Haslo';

  @override
  String get authEnterPassword => 'Wprowadz haslo';

  @override
  String get authRegisterAccount => 'Zarejestruj sie';

  @override
  String get authForgotPassword => 'Zapomniales hasla';

  @override
  String get authOtherLoginMethods => 'Inne metody logowania';

  @override
  String get authCreateAccount => 'Utworz konto';

  @override
  String get authJoinN42Chat => 'Dolacz do N42 Chat, aby rozpoczac rozmowe';

  @override
  String get authUsernameHint => '3-20 znakow, litery/cyfry/_';

  @override
  String get authUsernameMinLength =>
      'Nazwa uzytkownika musi miec co najmniej 3 znaki';

  @override
  String get authUsernameMaxLength =>
      'Nazwa uzytkownika moze miec maksymalnie 20 znakow';

  @override
  String get authUsernameFormat =>
      'Nazwa uzytkownika moze zawierac tylko litery, cyfry i podkreslenia';

  @override
  String get authPasswordHint => 'Min. 8 znakow';

  @override
  String get commonPasswordMinLength => 'Haslo musi miec co najmniej 8 znakow';

  @override
  String get authConfirmPassword => 'Potwierdz haslo';

  @override
  String get authFilled => 'Wypelniono';

  @override
  String get authEnterInviteCode => 'Wprowadz kod zaproszenia';

  @override
  String get authAlreadyHaveAccount => 'Masz juz konto?';

  @override
  String get authLoginNow => 'Zaloguj sie teraz';

  @override
  String get profileAvatar => 'Awatar';

  @override
  String get profileStatus => 'Stan';

  @override
  String get commonLoading => 'Ladowanie...';

  @override
  String get conversationNoConversations => 'Brak rozmow';

  @override
  String get conversationTapToChat =>
      'Dotknij prawego gornego rogu, aby rozpoczac rozmowe';

  @override
  String get conversationStartGroup => 'Rozpocznij czat grupowy';

  @override
  String get commonScan => 'Skanuj';

  @override
  String get commonPayment => 'Platnosc';

  @override
  String commonFeatureComingSoon(String feature) {
    return '$feature wkrotce dostepne';
  }

  @override
  String get conversationMarkAsRead => 'Oznacz jako przeczytane';

  @override
  String get commonUnmute => 'Wlacz dzwiek';

  @override
  String get commonMute => 'Wycisz';

  @override
  String get conversationUnpin => 'Odepnij';

  @override
  String get conversationPin => 'Przypnij';

  @override
  String get conversationDeleteConversation => 'Usun rozmowe';

  @override
  String conversationDeleteConversationConfirm(String name) {
    return 'Usunac rozmowe z \"$name\"?';
  }

  @override
  String get commonNoContacts => 'Brak kontaktow';

  @override
  String get contactAddFriendsToChat =>
      'Dodaj znajomych, aby rozpoczac rozmowe';

  @override
  String get contactNotFound => 'Kontakt nie zostal znaleziony';

  @override
  String get contactTryOtherKeywords =>
      'Sprobuj innych slow kluczowych lub wyszukiwania globalnego';

  @override
  String get contactSearchResults => 'Wyniki wyszukiwania';

  @override
  String get contactNewFriends => 'Nowi znajomi';

  @override
  String get contactChatOnlyFriends => 'Znajomi tylko na czacie';

  @override
  String get contactOfficialAccounts => 'Konta oficjalne';

  @override
  String get contactServiceAccounts => 'Konta uslugowe';

  @override
  String get contactEnterpriseContacts => 'Kontakty firmowe';

  @override
  String get contactRecommendToFriend => 'Udostepnij kontakt';

  @override
  String get commonSetRemark => 'Ustaw uwage';

  @override
  String get contactSendingCard => 'Wysylanie wizytowki...';

  @override
  String get commonFileLabel => 'Plik';

  @override
  String get commonLocationLabel => 'Lokalizacja';

  @override
  String contactRecommendFailed(String error) {
    return 'Polecenie nie powiodlo sie: $error';
  }

  @override
  String get profileEnterRemark => 'Wprowadz uwage';

  @override
  String get contactOpeningChat => 'Otwieranie czatu...';

  @override
  String contactOpenChatFailed(String error) {
    return 'Nie udalo sie otworzyc czatu: $error';
  }

  @override
  String get contactAddContact => 'Dodaj kontakt';

  @override
  String get contactEnterUserId => 'Wprowadz ID uzytkownika';

  @override
  String get contactNoFriendRequests => 'Brak zaproszen do znajomych';

  @override
  String get commonAccept => 'Akceptuj';

  @override
  String get commonReject => 'Odrzuc';

  @override
  String get commonNoGroups => 'Brak grup';

  @override
  String get contactSelectFriendToRecommend => 'Wybierz znajomego do polecenia';

  @override
  String get commonSearchContacts => 'Szukaj kontaktow';

  @override
  String get contactNoContactsFound => 'Nie znaleziono kontaktow';

  @override
  String get favoriteYesterday => 'Wczoraj';

  @override
  String get chatJustNow => 'Przed chwila';

  @override
  String get profileOnline => 'W Internecie';

  @override
  String get profileOffline => 'Nieaktywny';

  @override
  String get searchContactsGroupsMessages =>
      'Szukaj kontaktow, grup, wiadomosci';

  @override
  String get searchError => 'Blad wyszukiwania';

  @override
  String get chatSearchHint => 'Szukaj kontaktow, grup i wiadomosci';

  @override
  String get searchHistory => 'Historia wyszukiwania';

  @override
  String get commonClear => 'Wyczysc';

  @override
  String get commonAll => 'Wszystko';

  @override
  String get searchGroups => 'Grupy';

  @override
  String get searchNoResults => 'Brak wynikow';

  @override
  String commonGroupMembers(int count) {
    return 'Czlonkowie ($count)';
  }

  @override
  String get groupMembersTitle => 'Członkowie grupy';

  @override
  String get groupViewAll => 'Zobacz wszystko';

  @override
  String get groupOwner => 'Wlasciciel';

  @override
  String get groupAdmin => 'Administrator';

  @override
  String get groupInvite => 'Zapros';

  @override
  String get commonGroupAnnouncement => 'Ogloszenie grupy';

  @override
  String get commonNotSet => 'Nie ustawiono';

  @override
  String get groupDescription => 'Opis grupy';

  @override
  String get groupPublicGroup => 'Grupa publiczna';

  @override
  String get commonClearChatHistory => 'Wyczysc historie czatu';

  @override
  String get commonDissolveGroup => 'Rozwiaz grupe';

  @override
  String get commonLeaveGroup => 'Opusc grupe';

  @override
  String get groupChangeGroupName => 'Zmien nazwe grupy';

  @override
  String get commonEnterGroupName => 'Wprowadz nazwe grupy';

  @override
  String get commonConfirm => 'Potwierdz';

  @override
  String get groupEnterGroupDescription => 'Wprowadz opis grupy';

  @override
  String get groupPublish => 'Opublikuj';

  @override
  String get chatClearHistoryConfirm =>
      'Wyczyścic cala historie czatu? Tej operacji nie mozna cofnac.';

  @override
  String get chatClearAction => 'Wyczysc';

  @override
  String get commonChatHistoryCleared => 'Historia czatu wyczyszczona';

  @override
  String get commonDissolve => 'Rozwiaz';

  @override
  String get groupQrCode => 'Kod QR grupy';

  @override
  String get commonSearchChatHistory => 'Szukaj w historii czatu';

  @override
  String get groupIdCopied => 'ID grupy skopiowano';

  @override
  String get transferEnterOrPasteAddress => 'Wprowadz lub wklej adres portfela';

  @override
  String get transferSelectToken => 'Wybierz token';

  @override
  String get commonTransferAmount => 'Kwota przelewu';

  @override
  String get transferAvailable => 'Dostepne';

  @override
  String get transferMemoOptional => 'Notatka (opcjonalna)';

  @override
  String get transferConfirmTransfer => 'Potwierdz przelew';

  @override
  String get transferAddressVerified => 'Adres zweryfikowany';

  @override
  String transferAvailableBalance(String balance, String symbol) {
    return 'Dostepne: $balance $symbol';
  }

  @override
  String get commonEnterAmount => 'Wprowadz kwote';

  @override
  String get commonRedPacketCountMin =>
      'Wymagana co najmniej 1 czerwona koperta';

  @override
  String get commonViewRedPacketDetails => 'Zobacz szczegoly czerwonej koperty';

  @override
  String get commonEnterTransferAmount => 'Wprowadz kwote przelewu';

  @override
  String get commonTransferTo => 'Przelew do';

  @override
  String commonFromSender(String name, Object senderName) {
    return 'Od $senderName';
  }

  @override
  String get commonConfirmReceive => 'Potwierdz odbiór';

  @override
  String get groupProfile => 'Informacje o grupie';

  @override
  String get groupRemoveMember => 'Usun z grupy';

  @override
  String get commonRemove => 'Usun';

  @override
  String get profileClearStatus => 'Wyczysc status';

  @override
  String get profileClearStatusConfirm => 'Wyczyścic biezacy status?';

  @override
  String get profileStatusCleared => 'Status wyczyszczony';

  @override
  String get profileUserNotExist => 'Uzytkownik nie istnieje';

  @override
  String get profileUserIdCopied => 'ID uzytkownika skopiowano';

  @override
  String get commonReport => 'Zglos';

  @override
  String get profileQrCode => 'Kod QR';

  @override
  String get profileAvatarUpdated => 'Awatar zaktualizowany';

  @override
  String commonSelectImageFailed(String error) {
    return 'Nie udalo sie wybrac obrazu: $error';
  }

  @override
  String get profileChangeName => 'Zmien nazwe';

  @override
  String get profileMale => 'Mezczyzna';

  @override
  String get profileFemale => 'Kobieta';

  @override
  String chatFeatureInDev(String feature) {
    return '$feature w trakcie rozwoju...';
  }

  @override
  String profileSaveAddressFailed(String error) {
    return 'Nie udalo sie zapisac adresu: $error';
  }

  @override
  String get profileAddNew => 'Dodaj';

  @override
  String get profileAddAddress => 'Dodaj adres';

  @override
  String get profileAddressAdded => 'Adres dodany';

  @override
  String get profileAddressUpdated => 'Adres zaktualizowany';

  @override
  String get profileDeleteAddress => 'Usun adres';

  @override
  String get profileAddressDeleted => 'Adres usuniety';

  @override
  String profileSaveInvoiceFailed(String error) {
    return 'Nie udalo sie zapisac faktury: $error';
  }

  @override
  String get profileMyInvoices => 'Moje faktury';

  @override
  String get profileAddInvoice => 'Dodaj fakture';

  @override
  String get profileInvoiceAdded => 'Faktura dodana';

  @override
  String get profileInvoiceUpdated => 'Faktura zaktualizowana';

  @override
  String get profileDeleteInvoice => 'Usun fakture';

  @override
  String get profileInvoiceDeleted => 'Faktura usunieta';

  @override
  String get profilePersonal => 'Osobista';

  @override
  String get groupSelectAtLeastOne => 'Wybierz co najmniej jednego czlonka';

  @override
  String get chatFileNotExist => 'Plik nie istnieje';

  @override
  String chatSendFailed(String error) {
    return 'Wyslanie nie powiodlo sie: $error';
  }

  @override
  String get chatCannotOpenBrowser => 'Nie mozna otworzyc przegladarki';

  @override
  String chatSelectFileFailed(String error) {
    return 'Nie udalo sie wybrac pliku: $error';
  }

  @override
  String settingsSetupFailed(String error) {
    return 'Konfiguracja nie powiodla sie: $error';
  }

  @override
  String get transferEnterValidAmount => 'Wprowadz prawidlowa kwote';

  @override
  String get commonAddressCopied => 'Adres skopiowany';

  @override
  String favoriteOpenItem(String content) {
    return 'Otworz: $content';
  }

  @override
  String get favoriteDeleted => 'Usunieto';

  @override
  String get profileWallet => 'Portfel';

  @override
  String get chatRecording => 'Nagrywanie';

  @override
  String get chatInvalidVideoUrl => 'Nieprawidlowy adres URL wideo';

  @override
  String get chatDownloadFile => 'Pobierz plik';

  @override
  String get chatClearChatHistoryTitle => 'Wyczysc historie czatu';

  @override
  String get chatVideoCall => 'Polaczenie wideo';

  @override
  String get commonVoiceCall => 'Polaczenie glosowe';

  @override
  String get callLeaveMeeting => 'Opusc spotkanie';

  @override
  String get chatDetails => 'Szczegoly czatu';

  @override
  String get chatViewAllGroupMembers => 'Zobacz wszystkich czlonkow';

  @override
  String get chatGroupName => 'Nazwa grupy';

  @override
  String get chatGroupNameUpdated => 'Nazwa grupy zaktualizowana';

  @override
  String get chatUpdateFailed => 'Aktualizacja nie powiodla sie';

  @override
  String get chatNoPermissionToModify => 'Nie masz uprawnien do modyfikacji';

  @override
  String get chatGroupManagement => 'Zarzadzanie grupa';

  @override
  String get chatMyNicknameInGroup => 'Moj pseudonim w grupie';

  @override
  String get chatPinChat => 'Przypnij czat';

  @override
  String get chatStrongReminder => 'Silne przypomnienie';

  @override
  String get chatSetChatBackground => 'Ustaw tlo czatu';

  @override
  String get chatUnknownFile => 'Nieznany plik';

  @override
  String get chatDownload => 'Pobierz';

  @override
  String get chatInvalidLocation => 'Nieprawidlowa lokalizacja';

  @override
  String get chatTapToCancel => 'Dotknij, aby anulowac';

  @override
  String chatCaptureFailed(Object error) {
    return 'Przechwytywanie nie powiodlo sie: $error';
  }

  @override
  String get chatProcessingVideo => 'Przetwarzanie wideo...';

  @override
  String get chatVideoFileNotExist => 'Plik wideo nie istnieje';

  @override
  String get chatVideoDataEmpty => 'Dane wideo sa puste';

  @override
  String get chatVideoTooLarge => 'Rozmiar wideo nie moze przekraczac 100MB';

  @override
  String get chatSendingVideo => 'Wysylanie wideo...';

  @override
  String chatSendVideoFailed(Object error) {
    return 'Nie udalo sie wyslac wideo: $error';
  }

  @override
  String get chatImageFileNotExist => 'Plik obrazu nie istnieje';

  @override
  String get commonImageDataEmpty => 'Dane obrazu sa puste';

  @override
  String get chatSendingImage => 'Wysylanie obrazu...';

  @override
  String chatSendImageFailed(Object error) {
    return 'Nie udalo sie wyslac obrazu: $error';
  }

  @override
  String get chatSendLocation => 'Wyslij lokalizacje';

  @override
  String get chatSelectLocationAndSend => 'Wybierz lokalizacje i wyslij';

  @override
  String get chatShareRealTimeLocation =>
      'Udostepnij lokalizacje w czasie rzeczywistym';

  @override
  String get chatShareLocationForOneHour =>
      'Udostepnij lokalizacje znajomemu przez 1 godzine';

  @override
  String get chatLocationSent => 'Lokalizacja wyslana';

  @override
  String get chatSelectMessages => 'Wybierz wiadomosci';

  @override
  String chatSelectedCount(int count) {
    return 'Wybrano $count';
  }

  @override
  String get chatSelectAll => 'Wybierz wszystko';

  @override
  String chatGroupChatCount(int count) {
    return 'Czat grupowy ($count)';
  }

  @override
  String get chatPrivateChat => 'Czat prywatny';

  @override
  String get chatNoMessages => 'Brak wiadomosci';

  @override
  String get chatSendFirstMessage =>
      'Wyslij pierwsza wiadomosc, aby rozpoczac rozmowe';

  @override
  String get chatEncryptionNotice =>
      'Ten czat jest szyfrowany od konca do konca. Tylko Ty i odbiorca mozecie czytac wiadomosci.';

  @override
  String get chatMultiForward => 'Przekaz dalej';

  @override
  String get chatCollect => 'Zbierz';

  @override
  String get chatNoMembers => 'Brak czlonkow';

  @override
  String get chatMemberNotFound => 'Czlonek nie zostal znaleziony';

  @override
  String get chatVoiceFileNotExist => 'Plik glosowy nie istnieje';

  @override
  String get chatVoiceFileEmpty => 'Plik glosowy jest pusty';

  @override
  String get chatSendingVoice => 'Wysylanie glosu...';

  @override
  String chatSendVoiceFailed(Object error) {
    return 'Nie udalo sie wyslac glosu: $error';
  }

  @override
  String get chatMessageForwarded => 'Wiadomosc przekazana';

  @override
  String chatForwardFailed(Object error) {
    return 'Przekazanie nie powiodlo sie: $error';
  }

  @override
  String get chatUnfavorited => 'Usunieto z ulubionych';

  @override
  String get chatFavorited => 'Dodano do ulubionych';

  @override
  String get chatReactionAdded => 'Reakcja dodana';

  @override
  String get chatReactionRemoved => 'Reakcja usunieta';

  @override
  String get chatFailedMessageDeleted => 'Nieudana wiadomosc usunieta';

  @override
  String get chatDeleteMessages => 'Usun wiadomosci';

  @override
  String chatDeleteMessagesConfirm(Object count) {
    return 'Czy na pewno chcesz usunac $count wiadomosci?';
  }

  @override
  String chatNoteOtherMessages(Object count) {
    return 'Uwaga: $count wiadomosci jest od innych i zostana usuniete tylko dla Ciebie.';
  }

  @override
  String chatMyMessagesWillBeRecalled(Object count) {
    return '$count wiadomosci od Ciebie zostanie wycofanych dla wszystkich.';
  }

  @override
  String chatRecalledCount(Object count, Object localCount) {
    return 'Wycofano $count wiadomosci, $localCount usunieto tylko dla Ciebie';
  }

  @override
  String chatRecalledMessages(Object count) {
    return 'Wycofano $count wiadomosci';
  }

  @override
  String chatDeletedLocally(Object count) {
    return '$count wiadomosci usunieto tylko dla Ciebie';
  }

  @override
  String chatForwardedCount(Object count) {
    return 'Przekazano $count wiadomosci';
  }

  @override
  String chatForwardComplete(Object failed, Object success) {
    return 'Przekazanie zakonczone: $success udanych, $failed nieudanych';
  }

  @override
  String get chatRemindOnlyInGroup =>
      'Funkcja przypomnienia jest dostepna tylko w czacie grupowym';

  @override
  String get chatOnlyTextSearchable =>
      'Mozna wyszukiwac tylko wiadomosci tekstowe';

  @override
  String chatSearchFor(Object text) {
    return 'Szukaj \"$text\"';
  }

  @override
  String get chatBaiduSearch => 'Wyszukiwanie Baidu';

  @override
  String get chatGoogleSearch => 'Wyszukiwanie Google';

  @override
  String get chatBingSearch => 'Wyszukiwanie Bing';

  @override
  String get chatCalling => 'Dzwonie...';

  @override
  String get chatRinging => 'Dzwoni...';

  @override
  String get chatInCall => 'W trakcie polaczenia';

  @override
  String commonFeatureInDevelopment(String feature) {
    return 'Funkcja w trakcie rozwoju...';
  }

  @override
  String chatCollectMessages(Object count) {
    return 'Zebrano $count wiadomosci';
  }

  @override
  String commonMemberCount(int count) {
    return '$count czlonkow';
  }

  @override
  String groupDone(int count) {
    return 'Gotowe($count)';
  }

  @override
  String get profileServices => 'Uslugi';

  @override
  String get commonFavorites => 'Ulubione';

  @override
  String get profileOrdersAndCards => 'Zamowienia i karty';

  @override
  String get profileStickers => 'Naklejki';

  @override
  String profileStatusSetTo(String status) {
    return 'Status ustawiony na: $status';
  }

  @override
  String get profileAvatarUploadFailed =>
      'Przesylanie awatara nie powiodlo sie';

  @override
  String get profilePersonalProfile => 'Profil osobisty';

  @override
  String get profileName => 'Imie';

  @override
  String get profileGender => 'Plec';

  @override
  String get profileRegion => 'Region';

  @override
  String get commonMyQrCode => 'Moj kod QR';

  @override
  String get profilePoke => 'Szturchnij';

  @override
  String get profileRingtone => 'Dzwonek';

  @override
  String get profileDefaultRingtone => 'Domyslny dzwonek';

  @override
  String get profileMyAddresses => 'Moje adresy';

  @override
  String profileGenderSetTo(String gender) {
    return 'Plec ustawiona na: $gender';
  }

  @override
  String get profileSelectRegion => 'Wybierz region';

  @override
  String get profileSelectCity => 'Wybierz miasto';

  @override
  String profileRegionSetTo(String region) {
    return 'Region ustawiony na: $region';
  }

  @override
  String get profileSetPoke => 'Ustaw szturchniecie';

  @override
  String get profileFriendPokedMe => 'Znajomy mnie szturchnal';

  @override
  String get profileExample => 'Przyklad';

  @override
  String get profileOnTheShoulder => ' w ramie';

  @override
  String get profilePokeCleared => 'Szturchniecie wyczyszczone';

  @override
  String profilePokeSetTo(String suffix) {
    return 'Szturchniecie ustawione na: szturchnal mnie$suffix';
  }

  @override
  String get profileEditSignature => 'Edytuj podpis';

  @override
  String get profileIntroduceYourself => 'Zdanie, ktore Cie opisuje';

  @override
  String get profileSignatureCleared => 'Podpis wyczyszczony';

  @override
  String get profileSignatureUpdated => 'Podpis zaktualizowany';

  @override
  String get profileScanToAddFriend =>
      'Zeskanuj powyzszy kod QR, aby dodac mnie jako znajomego';

  @override
  String profileRingtoneSetTo(String ringtone) {
    return 'Dzwonek ustawiony na: $ringtone';
  }

  @override
  String commonConfirmDissolveGroup(String name) {
    return 'Czy na pewno chcesz rozwiązać \"$name\"? Tej operacji nie można cofnąć.';
  }

  @override
  String get authEnterValidServerAddress => 'Wprowadz prawidlowy adres serwera';

  @override
  String get authEnterServerAddressFirst => 'Najpierw wprowadz adres serwera';

  @override
  String get authPasskeyRequiresServer =>
      'Logowanie kluczem dostepu wymaga wsparcia serwera';

  @override
  String get authLoginAgreement => 'Logujac sie, akceptujesz ';

  @override
  String get authPleaseAgreeToTerms =>
      'Przeczytaj i zaakceptuj Regulamin i Polityke prywatnosci';

  @override
  String get authRegisterFailed => 'Rejestracja nie powiodla sie';

  @override
  String get commonReenterPassword => 'Wprowadz haslo ponownie';

  @override
  String get commonPasswordsDoNotMatch => 'Hasla nie pasuja do siebie';

  @override
  String get authInviteCodeBuiltIn => 'Kod zaproszenia (wbudowany)';

  @override
  String get authInviteCodeBuiltInNote =>
      'Kod zaproszenia jest wbudowany, zwykle nie trzeba go zmieniac';

  @override
  String get authIHaveReadAndAgree => 'Przeczytałem i akceptuje ';

  @override
  String get mainStartGroupChat => 'Rozpocznij czat grupowy';

  @override
  String get mainAddFriends => 'Dodaj znajomych';

  @override
  String get mainPaymentAndCollection => 'Platnosc';

  @override
  String contactCount(int count) {
    return '$count kontaktow';
  }

  @override
  String get contactAddToHomeScreen => 'Dodaj do ekranu glownego';

  @override
  String contactRecommendedCardTo(String contact, String recipient) {
    return 'Polecono wizytowke $contact do $recipient';
  }

  @override
  String get contactEnterRemarkName => 'Wprowadz nazwe uwagi';

  @override
  String contactRemarkSetTo(String remark) {
    return 'Uwaga ustawiona na: $remark';
  }

  @override
  String contactAcceptedFriendRequest(String name) {
    return 'Zaakceptowano zaproszenie od $name';
  }

  @override
  String contactRejectedFriendRequest(String name) {
    return 'Odrzucono zaproszenie od $name';
  }

  @override
  String get commonGroupInvites => 'Zaproszenia do grupy';

  @override
  String commonMyGroups(int count) {
    return 'Moje grupy ($count)';
  }

  @override
  String get commonInvitedToJoinGroup => 'Zaproszono do dolaczenia do grupy';

  @override
  String commonConfirmLeaveGroup(String name) {
    return 'Czy na pewno chcesz opuścić \"$name\"?';
  }

  @override
  String get commonLeave => 'Opusc';

  @override
  String get commonRecallThisMessage => 'Wycofac te wiadomosc?';

  @override
  String get commonSavedToGallery => 'Zapisano w galerii';

  @override
  String get commonFailedToSave => 'Nie udalo sie zapisac';

  @override
  String get chatSaving => 'Zapisywanie...';

  @override
  String get commonShare => 'Udostepnij';

  @override
  String get chatSaveToGallery => 'Zapisz w galerii';

  @override
  String chatDownloadFailed(String code) {
    return 'Pobieranie nie powiodło się: $code';
  }

  @override
  String commonShareFailed(String error) {
    return 'Udostępnianie nie powiodło się: $error';
  }

  @override
  String get chatFailedToLoadImage => 'Nie udalo sie zaladowac obrazu';

  @override
  String get chatVideoRecordingFailed =>
      'Nagrywanie wideo nie powiodlo sie. Sprobuj ponownie.';

  @override
  String get profileRedPacket => 'Czerwona koperta';

  @override
  String get commonMusic => 'Muzyka';

  @override
  String get commonCoupon => 'Kupon';

  @override
  String get commonGift => 'Prezent';

  @override
  String get commonPoll => 'Ankieta';

  @override
  String get favoriteText => 'Tekst';

  @override
  String get favoriteLinkLabel => 'Połączyć';

  @override
  String get favoriteNote => 'Notatka';

  @override
  String get favoriteMyNotes => 'Moje notatki';

  @override
  String get favoriteToday => 'Dzisiaj';

  @override
  String favoriteDaysAgoText(int count) {
    return '$count dni temu';
  }

  @override
  String favoriteDateFormat(int month, int day) {
    return '$day/$month';
  }

  @override
  String get favoriteNoFavorites => 'Brak ulubionych';

  @override
  String get favoriteLongPressToFavorite =>
      'Przytrzymaj wiadomosc, aby dodac do ulubionych';

  @override
  String get favoriteNewNote => 'Nowa notatka';

  @override
  String get favoriteLink => 'Ulubiony link';

  @override
  String get favoriteEditTags => 'Edytuj tagi';

  @override
  String get favoriteDeleteFavorite => 'Usun z ulubionych';

  @override
  String get favoriteDeleteFavoriteConfirm =>
      'Czy na pewno chcesz usunac ten ulubiony element?';

  @override
  String get favoriteNoSearchResultsFound => 'Nie znaleziono wynikow';

  @override
  String get commonSendRedPacket => 'Wyslij czerwona koperte';

  @override
  String get transferAmount => 'Kwota';

  @override
  String get commonRedPacketCover => 'Okladka czerwonej koperty';

  @override
  String get commonRedPacketType => 'Typ czerwonej koperty';

  @override
  String get commonNormalRedPacket => 'Zwykla';

  @override
  String get commonLuckyRedPacket => 'Szczesliwa';

  @override
  String get commonRedPacketCount => 'Liczba czerwonych kopert';

  @override
  String get commonPieces => 'sztuk';

  @override
  String get commonPutMoneyInRedPacket => 'Wloz pieniadze do czerwonej koperty';

  @override
  String get commonRedPacketRefundNotice =>
      'Nieodebrane czerwone koperty zostana zwrocone po 24 godzinach';

  @override
  String get commonOpenRedPacket => 'Otworz';

  @override
  String get commonRedPacketAllClaimed => 'Wszystkie czerwone koperty odebrane';

  @override
  String get commonRedPacketExpired => 'Czerwona koperta wygasla';

  @override
  String get commonAddTransferNote => 'Dodaj notatke do przelewu';

  @override
  String get commonYuan => 'PLN';

  @override
  String get commonReplyWithEmoji => 'Odpowiedz tym emotikonem';

  @override
  String get contactEditRemark => 'Edytuj uwage';

  @override
  String get contactSetPermissions => 'Ustaw uprawnienia';

  @override
  String get profileAddToBlacklist => 'Dodaj do czarnej listy';

  @override
  String get contactDeleteContact => 'Usun kontakt';

  @override
  String contactDeleteContactConfirm(String name) {
    return 'Czy na pewno chcesz usunac $name?';
  }

  @override
  String get transferTitle => 'Przelew';

  @override
  String get transferReceiverAddressLabel => 'Adres odbiorcy';

  @override
  String get transferSelectTokenLabel => 'Wybierz token';

  @override
  String get transferAmountLabel => 'Kwota przelewu';

  @override
  String get transferMemoLabel => 'Notatka (opcjonalna)';

  @override
  String get transferAddMemoHint => 'Dodaj notatke';

  @override
  String get transferSendPaymentRequest => 'Wyslij zadanie platnosci';

  @override
  String get transferQrCodeGenerateFailed =>
      'Generowanie kodu QR nie powiodlo sie';

  @override
  String get transferScanQrToPayMe => 'Zeskanuj kod QR, aby mi zaplacic';

  @override
  String get transferMyWalletAddress => 'Moj adres portfela';

  @override
  String get transferCreatePaymentRequest => 'Utworz zadanie platnosci';

  @override
  String profileN42IdLabel(String id) {
    return 'ID N42: $id';
  }

  @override
  String get commonRedPacketDefaultGreeting => 'Najlepsze zyczenia';

  @override
  String commonSenderRedPacket(String name) {
    return 'Czerwona koperta od $name';
  }

  @override
  String get transferEnterValidAddress => 'Wprowadz prawidlowy adres';

  @override
  String get transferPleaseSelectToken => 'Wybierz token';

  @override
  String get commonReceivedTransfer => 'Odebrany przelew';

  @override
  String commonSenderSentRedPacket(String name) {
    return '$name wyslal(a) czerwona koperte';
  }

  @override
  String get commonSavedToBalance =>
      'Zapisano na saldo, mozna przelewac bezposrednio';

  @override
  String get commonRedPacketExpiredOrEmpty =>
      'Czerwona koperta wygasla/wszystkie odebrane';

  @override
  String get transferScanFeatureComingSoon =>
      'Funkcja skanowania wkrotce dostepna...';

  @override
  String get contactSetAsStarred => 'Ustaw jako ulubione';

  @override
  String get contactAddToBlocklist => 'Dodaj do listy zablokowanych';

  @override
  String get commonClaimedYour => ' odebral(a) Twoja ';

  @override
  String get commonClaimedText => ' odebral(a) ';

  @override
  String commonUserTyping(String name) {
    return '$name pisze...';
  }

  @override
  String get commonTyping => 'Pisze...';

  @override
  String get commonWaitingToReceive => 'Oczekiwanie na odbiór';

  @override
  String get commonTapToClaim => 'Dotknij, aby odebrac';

  @override
  String get commonHasBeenReceived => 'Zostalo odebrane';

  @override
  String get commonGetLucky => 'Niech Ci sie szczesci';

  @override
  String get qrcodeCameraStartFailed => 'Kamera nie uruchomila sie';

  @override
  String get qrcodeUnknownError => 'Nieznany blad';

  @override
  String get qrcodePlaceQrCodeInFrame =>
      'Umiesc kod QR w ramce, aby zeskanowac';

  @override
  String get qrcodeCloseManualInput => 'Zamknij reczne wprowadzanie';

  @override
  String get qrcodeManualInputUserId => 'Reczne wprowadzanie ID uzytkownika';

  @override
  String get commonAdd => 'Dodaj';

  @override
  String get profileSetStatus => 'Ustaw status';

  @override
  String get profileVisibleToFriends24h =>
      'Widoczne dla znajomych przez 24 godziny';

  @override
  String get profileWriteStatus => 'Napisz status';

  @override
  String get profileEnterYourStatus => 'Wprowadz swoj status...';

  @override
  String get profileOk => 'OK';

  @override
  String get qrcodeCameraPermissionRequired =>
      'Wymagane uprawnienie do kamery, aby skanowac kod QR';

  @override
  String get qrcodeCameraPermissionDenied =>
      'Uprawnienie do kamery zostalo trwale odrzucone. Wlacz je w ustawieniach systemu.';

  @override
  String qrcodePermissionCheckError(String error) {
    return 'Blad sprawdzania uprawnienia: $error';
  }

  @override
  String get qrcodeInvalidQrCode => 'Nieprawidlowy kod QR';

  @override
  String qrcodeCannotAddFriend(String error) {
    return 'Nie mozna dodac znajomego: $error';
  }

  @override
  String get qrcodeScanQrCode => 'Skanuj kod QR';

  @override
  String get qrcodeCheckingCameraPermission =>
      'Sprawdzanie uprawnienia do kamery...';

  @override
  String get qrcodeNeedCameraPermission => 'Wymagane uprawnienie do kamery';

  @override
  String get qrcodeRetryPermission => 'Ponow';

  @override
  String get qrcodeOpenSettings => 'Otworz ustawienia';

  @override
  String get groupInviteMembers => 'Zapros czlonkow';

  @override
  String groupInviteCount(int count) {
    return 'Zapros($count)';
  }

  @override
  String get profileNoShippingAddress => 'Brak adresu dostawy';

  @override
  String get profileDefaultLabel => 'Domyslny';

  @override
  String get profileNoInvoice => 'Brak faktury';

  @override
  String get profileCompany => 'Firma';

  @override
  String get profileTaxNumber => 'NIP';

  @override
  String get profileConfirmDeleteAddress =>
      'Czy na pewno chcesz usunac ten adres?';

  @override
  String get profileConfirmDeleteInvoice =>
      'Czy na pewno chcesz usunac te fakture?';

  @override
  String get commonGroupOwner => 'Wlasciciel';

  @override
  String get commonGroupAdmin => 'Administrator';

  @override
  String get groupSearchMembers => 'Szukaj czlonkow';

  @override
  String groupTotalMembers(int count) {
    return '$count czlonkow';
  }

  @override
  String get chatRemoveFromGroup => 'Usun z grupy';

  @override
  String groupConfirmRemoveMember(String name) {
    return 'Czy na pewno chcesz usunac \"$name\" z grupy?';
  }

  @override
  String get chatUnknownSong => 'Nieznany utwor';

  @override
  String get chatUnknownArtist => 'Nieznany artysta';

  @override
  String get chatUnknownContact => 'Nieznany kontakt';

  @override
  String get chatPersonalCard => 'Wizytowka';

  @override
  String get chatSingleChoice => 'Pojedynczy wybor';

  @override
  String get chatMultiChoice => 'Wielokrotny wybor';

  @override
  String get chatEnded => 'Zakonczone';

  @override
  String get chatEndPollButton => 'Zakoncz ankiete';

  @override
  String get chatPollHint =>
      'Ankieta bedzie wyswietlana na czacie. Czlonkowie grupy moga glosowac.';

  @override
  String get chatSearchSongOrArtist => 'Szukaj utworu lub artysty';

  @override
  String get chatNoSongsFound => 'Nie znaleziono utworow';

  @override
  String get chatSongNameOptional => 'Nazwa utworu (opcjonalna)';

  @override
  String get chatEnterSongName => 'Wprowadz nazwe utworu';

  @override
  String get chatArtistNameOptional => 'Nazwa artysty (opcjonalna)';

  @override
  String get chatEnterArtistName => 'Wprowadz nazwe artysty';

  @override
  String get chatRealTimeLocationSharing =>
      'Udostepnianie lokalizacji w czasie rzeczywistym w trakcie rozwoju...';

  @override
  String get profileVoiceCallFeatureInDev =>
      'Funkcja polaczenia glosowego w trakcie rozwoju...';

  @override
  String get profileReportFeatureInDev =>
      'Funkcja zglaszania w trakcie rozwoju...';

  @override
  String get profileShareFeatureInDev =>
      'Funkcja udostepniania w trakcie rozwoju...';

  @override
  String get profileQrCodeFeatureInDev =>
      'Funkcja kodu QR w trakcie rozwoju...';

  @override
  String get qrcodeScanQrToAddMe =>
      'Zeskanuj powyzszy kod QR, aby dodac mnie jako znajomego';

  @override
  String get qrcodeSaveToAlbum => 'Zapisz w albumie';

  @override
  String get qrcodeChangeStyle => 'Zmien styl';

  @override
  String get qrcodeCopyId => 'Kopiuj ID';

  @override
  String get qrcodeIdCopied => 'ID skopiowane';

  @override
  String get qrcodeMoreStylesFeatureComingSoon =>
      'Wiecej stylow wkrotce dostepnych';

  @override
  String get profileBio => 'Bio';

  @override
  String get profileHomeServer => 'Serwer';

  @override
  String get profileShareContactCard => 'Udostepnij wizytowke';

  @override
  String get profileRemoveFromBlacklist => 'Usun z czarnej listy';

  @override
  String get profileConfirmAddBlacklist =>
      'Czy na pewno chcesz dodac tego uzytkownika do czarnej listy? Nie bedziesz otrzymywac od niego wiadomosci.';

  @override
  String get profileConfirmRemoveBlacklist =>
      'Czy na pewno chcesz usunac tego uzytkownika z czarnej listy?';

  @override
  String get profileRemarkSaved => 'Uwaga zapisana';

  @override
  String get profileRemarkCleared => 'Uwaga wyczyszczona';

  @override
  String get transferReceive => 'Odbierz';

  @override
  String get transferPleaseConnectWallet => 'Najpierw polacz portfel';

  @override
  String get transferSendRequest => 'Wyslij zadanie';

  @override
  String get transferPleaseEnterValidAmount => 'Wprowadz prawidlowa kwote';

  @override
  String get searchPlaceholder => 'Szukaj kontaktow, grup, wiadomosci';

  @override
  String get searchEnterKeywordToSearch =>
      'Wprowadz slowo kluczowe, aby wyszukac';

  @override
  String get searchClearHistory => 'Wyczysc';

  @override
  String searchNoResultsForQuery(String query) {
    return 'Brak wynikow dla \"$query\"';
  }

  @override
  String get searchAllResults => 'Wszystko';

  @override
  String get searchInChat => 'Szukaj na czacie';

  @override
  String get searchContactLabel => 'Kontakt';

  @override
  String get searchGroupLabel => 'Grupa';

  @override
  String get searchConversationLabel => 'Rozmowa';

  @override
  String get searchMessageLabel => 'Wiadomosc';

  @override
  String get settingsSecurityTitle => 'Bezpieczenstwo';

  @override
  String get settingsKeyBackup => 'Kopia zapasowa kluczy';

  @override
  String get settingsBackupEncryptionKeys =>
      'Kopia zapasowa kluczy szyfrowania';

  @override
  String settingsKeysBackedUp(int count) {
    return '$count kluczy skopiowanych';
  }

  @override
  String get settingsBackupNotSet => 'Kopia zapasowa nie ustawiona';

  @override
  String get settingsRestoreKeys => 'Przywroc klucze';

  @override
  String get settingsRestoreKeysFromBackup =>
      'Przywroc klucze szyfrowania z kopii zapasowej';

  @override
  String get settingsExportKeys => 'Eksportuj klucze';

  @override
  String get settingsExportKeysToFile => 'Eksportuj klucze do pliku';

  @override
  String get settingsLoggedInDevices => 'Zalogowane urzadzenia';

  @override
  String get settingsNoOtherDevices => 'Brak innych urzadzen';

  @override
  String get settingsVerified => 'Zweryfikowane';

  @override
  String get settingsUnverified => 'Niezweryfikowane';

  @override
  String get settingsAdvanced => 'Zaawansowane';

  @override
  String get settingsCrossSigning => 'Podpisywanie krzyzowe';

  @override
  String get settingsEnabled => 'Wlaczone';

  @override
  String get settingsNotEnabled => 'Nie wlaczone';

  @override
  String get settingsResetEncryption => 'Zresetuj szyfrowanie';

  @override
  String get settingsDeleteAllEncryptionKeys =>
      'Usun wszystkie klucze szyfrowania';

  @override
  String get settingsEncryptionNotSupported =>
      'Szyfrowanie nie jest obslugiwane';

  @override
  String get settingsNotInitialized => 'Nie zainicjowano';

  @override
  String get settingsBackupKeyTitle => 'Kopia zapasowa kluczy';

  @override
  String get settingsBackupKeyMessage =>
      'Utworzyc nowa kopie zapasowa kluczy? Pomoze to przywrocic zaszyfrowane wiadomosci na nowym urzadzeniu.';

  @override
  String get settingsBackup => 'Kopia zapasowa';

  @override
  String get settingsRestoreKeyTitle => 'Przywroc klucze';

  @override
  String get settingsRestoreKeyMessage =>
      'Wprowadz haslo odzyskiwania lub klucz odzyskiwania, aby przywrocic zaszyfrowane wiadomosci.';

  @override
  String get settingsRestore => 'Przywroc';

  @override
  String get settingsExportKeyTitle => 'Eksportuj klucze';

  @override
  String get settingsExportKeyMessage =>
      'Wyeksportowany plik kluczy zawiera wszystkie Twoje klucze szyfrowania. Przechowuj go w bezpiecznym miejscu.';

  @override
  String get settingsExport => 'Eksportuj';

  @override
  String settingsDeviceIdLabel(String deviceId) {
    return 'ID urzadzenia: $deviceId';
  }

  @override
  String get settingsDeviceStatusVerified => 'Status: Zweryfikowane';

  @override
  String get settingsDeviceStatusUnverified => 'Status: Niezweryfikowane';

  @override
  String settingsLastActiveLabel(String lastSeen) {
    return 'Ostatnia aktywnosc: $lastSeen';
  }

  @override
  String get settingsVerifyThisDevice => 'Zweryfikuj to urzadzenie';

  @override
  String get settingsCrossSigningAlreadyEnabled =>
      'Podpisywanie krzyzowe jest juz wlaczone';

  @override
  String get settingsCrossSigningSetupSuccess =>
      'Konfiguracja podpisywania krzyzowego powiodla sie';

  @override
  String get settingsResetEncryptionTitle => 'Zresetuj szyfrowanie';

  @override
  String get settingsResetEncryptionWarning =>
      'Ostrzezenie: Spowoduje to usuniecie wszystkich kluczy szyfrowania. Nie bedziesz moc odszyfrowac poprzednich zaszyfrowanych wiadomosci. Tej operacji nie mozna cofnac.';

  @override
  String get settingsReset => 'Zresetuj';

  @override
  String get settingsBackupSuccess =>
      'Pomyślnie utworzono kopię zapasową kluczy';

  @override
  String get settingsBackupFailed =>
      'Tworzenie kopii zapasowej nie powiodło się';

  @override
  String get settingsRecoveryKey => 'Klucz odzyskiwania';

  @override
  String get settingsRecoveryKeySaveWarning =>
      'Zapisz ten klucz odzyskiwania w bezpiecznym miejscu. Będziesz go potrzebować, aby przywrócić zaszyfrowane wiadomości na nowym urządzeniu.';

  @override
  String get settingsRecoveryKeySaved => 'Zachowałem to';

  @override
  String get settingsRestoreSuccess => 'Klucze zostały przywrócone pomyślnie';

  @override
  String get settingsRestoreFailed => 'Przywracanie nie powiodło się';

  @override
  String get settingsPassword => 'Hasło';

  @override
  String get settingsEnterRecoveryKey => 'Wprowadź klucz odzyskiwania';

  @override
  String get settingsEnterPassword => 'Wprowadź hasło';

  @override
  String get settingsExportSuccess =>
      'Klucze wyeksportowane do kopii zapasowej serwera pomyślnie';

  @override
  String get settingsExportNeedBackupFirst =>
      'Najpierw utwórz kopię zapasową klucza';

  @override
  String get settingsExportFailed => 'Eksport nie powiódł się';

  @override
  String get settingsResetSuccess => 'Resetowanie szyfrowania powiodło się';

  @override
  String get settingsResetFailed => 'Resetowanie nie powiodło się';

  @override
  String get callLeaveMeetingConfirm =>
      'Czy na pewno chcesz opuscic spotkanie?';

  @override
  String chatPokedSomeone(String name, String suffix) {
    return 'szturchnal(a) $name$suffix';
  }

  @override
  String get chatNoContactsToAdd => 'Brak dostepnych kontaktow do dodania';

  @override
  String get chatAddMembers => 'Dodaj czlonkow';

  @override
  String chatInvitedMembers(int count) {
    return 'Zaproszono $count czlonkow';
  }

  @override
  String chatInviteFailed(String error) {
    return 'Zaproszenie nie powiodlo sie: $error';
  }

  @override
  String get chatMemberRemoved => 'Czlonek usuniety';

  @override
  String chatRemoveFailed(String error) {
    return 'Usuniecie nie powiodlo sie: $error';
  }

  @override
  String get chatRealTimeLocationShareMessage =>
      'Po udostepnieniu druga strona bedzie widziec Twoja lokalizacje w czasie rzeczywistym przez 1 godzine.';

  @override
  String get chatStartSharing => 'Rozpocznij udostepnianie';

  @override
  String get chatLocationServiceNotEnabled =>
      'Usluga lokalizacji nie jest wlaczona';

  @override
  String get chatEnableLocationService =>
      'Wlacz usluge lokalizacji, aby korzystac z tej funkcji';

  @override
  String get chatGoToSettings => 'Przejdz do ustawien';

  @override
  String get chatLocationPermissionRequired =>
      'Wymagane uprawnienie do lokalizacji dla tej funkcji';

  @override
  String get chatLocationPermissionDeniedPermanent =>
      'Uprawnienie do lokalizacji zostalo trwale odrzucone. Wlacz je w ustawieniach.';

  @override
  String get chatLocationPermissionDenied =>
      'Uprawnienie do lokalizacji odrzucone';

  @override
  String get chatGettingLocation => 'Pobieranie lokalizacji...';

  @override
  String chatGetLocationFailed(String error) {
    return 'Nie udalo sie uzyskac lokalizacji: $error';
  }

  @override
  String get chatMapPreview => 'Podglad mapy';

  @override
  String get chatSearchLocation => 'Szukaj lokalizacji';

  @override
  String chatRedPacketSent(String amount, String token) {
    return 'Wyslano $amount $token czerwona koperte';
  }

  @override
  String get chatTransferDefault => 'Przelew';

  @override
  String chatTransferSent(String amount, String token) {
    return 'Wyslano $amount $token przelew';
  }

  @override
  String chatPickFileFailed(String error) {
    return 'Nie udalo sie wybrac pliku: $error';
  }

  @override
  String get chatFileSizeLimit => 'Rozmiar pliku nie moze przekraczac 50MB';

  @override
  String chatFileSending(String filename) {
    return 'Wysylanie pliku: $filename';
  }

  @override
  String chatSendFileFailed(String error) {
    return 'Nie udalo sie wyslac pliku: $error';
  }

  @override
  String chatContactCardSent(String name) {
    return 'Wyslano wizytowke $name';
  }

  @override
  String get chatFavoritesFeature => 'Ulubione';

  @override
  String get chatCouponsFeature => 'Kupony';

  @override
  String get chatGiftFeature => 'Prezent';

  @override
  String chatSharedMusic(String name) {
    return 'Udostepniono $name';
  }

  @override
  String get chatEndPollTitle => 'Zakoncz ankiete';

  @override
  String get chatEndPollConfirmMessage =>
      'Czy na pewno chcesz zakonczyc te ankiete? Glosowanie zostanie zamkniete po zakonczeniu.';

  @override
  String get chatPollEndedMessage => 'Ankieta zakonczona';

  @override
  String get chatConnectingCall => 'Łączenie...';

  @override
  String get chatMuteCall => 'Wycisz';

  @override
  String get chatSpeakerOff => 'Glosnik wylaczony';

  @override
  String get chatSpeakerOn => 'Glosnik';

  @override
  String get chatCameraOn => 'Kamera wlaczona';

  @override
  String get chatCameraOff => 'Kamera wylaczona';

  @override
  String get chatHangUp => 'Rozlacz';

  @override
  String get chatSelectForwardTargetTitle => 'Wybierz cel przekazania';

  @override
  String get chatNoForwardableChat => 'Brak czatow dostepnych do przekazania';

  @override
  String get chatNoMatchingChat => 'Nie znaleziono pasujacych czatow';

  @override
  String get chatLocationTitle => 'Lokalizacja';

  @override
  String get chatSendButton => 'Wyslij';

  @override
  String get chatRetryButton => 'Ponow';

  @override
  String get chatSearchContactHint => 'Szukaj kontaktow';

  @override
  String get chatShareMusic => 'Udostepnij muzyke';

  @override
  String get chatRecentPlayed => 'Ostatnie';

  @override
  String get chatMyFavorites => 'Ulubione';

  @override
  String get chatNetworkLink => 'Połączyć';

  @override
  String get chatLocalFile => 'Lokalne';

  @override
  String get chatPasteMusicLink => 'Wklej link do muzyki';

  @override
  String get chatShareMusicButton => 'Udostepnij muzyke';

  @override
  String get chatSelectLocalAudio => 'Wybierz lokalny plik audio';

  @override
  String get chatSupportedAudioFormats => 'Obsluguje MP3, M4A, WAV, FLAC itp.';

  @override
  String get chatSelectFileButton => 'Wybierz plik';

  @override
  String get chatPleaseEnterMusicLink => 'Wprowadz link do muzyki';

  @override
  String get chatPleaseEnterValidLink => 'Wprowadz prawidlowy adres URL';

  @override
  String get chatSharedSong => 'Udostepniony utwor';

  @override
  String get chatSelectMember => 'Wybierz czlonka';

  @override
  String get chatSearchMemberHint => 'Szukaj czlonkow';

  @override
  String get chatNoMatchingMembers => 'Nie znaleziono pasujacych czlonkow';

  @override
  String get commonUnknownMember => 'Nieznany';

  @override
  String chatSelectedMessagesCount(int count) {
    return 'Wybrano $count wiadomosci';
  }

  @override
  String get chatSearchContactsOrGroups => 'Szukaj kontaktow lub grup';

  @override
  String get chatVideoTitle => 'Wideo';

  @override
  String get chatLoadingText => 'Ladowanie...';

  @override
  String get chatVideoLoadFailed => 'Ladowanie wideo nie powiodlo sie';

  @override
  String get chatPlayerInitFailed =>
      'Inicjalizacja odtwarzacza nie powiodla sie';

  @override
  String get chatCreatePollTitle => 'Utworz ankiete';

  @override
  String get chatSubmitPoll => 'Zatwierdz';

  @override
  String get chatPollQuestionLabel => 'Pytanie ankiety';

  @override
  String get chatEnterPollQuestionHint => 'Wprowadz pytanie ankiety';

  @override
  String get chatPollOptionsLabel => 'Opcje ankiety';

  @override
  String chatOptionHintWithIndex(int index) {
    return 'Opcja $index';
  }

  @override
  String get chatAddOptionButton => 'Dodaj opcje';

  @override
  String get chatPollSettingsLabel => 'Ustawienia ankiety';

  @override
  String get chatSelectionType => 'Typ wyboru';

  @override
  String get chatSingleChoiceLabel => 'Pojedynczy';

  @override
  String get chatMultiChoiceLabel => 'Wielokrotny';

  @override
  String get chatAnonymousPollSwitch => 'Anonimowa ankieta';

  @override
  String get chatPleaseEnterQuestion => 'Wprowadz pytanie ankiety';

  @override
  String get chatAtLeastTwoOptions => 'Wymagane co najmniej 2 opcje';

  @override
  String chatConfirmWithCount(int count) {
    return 'Potwierdz ($count)';
  }

  @override
  String get authEmailVerificationTitle => 'Weryfikacja e-mail';

  @override
  String get authEnterValidEmailAddress => 'Wprowadz prawidlowy adres e-mail';

  @override
  String authVerificationCodeSentTo(String email) {
    return 'Kod weryfikacyjny wyslany na $email';
  }

  @override
  String authSendCodeFailed(String error) {
    return 'Nie udalo sie wyslac kodu: $error';
  }

  @override
  String get authVerificationSuccess => 'Weryfikacja powiodla sie';

  @override
  String get authVerificationFailed => 'Weryfikacja nie powiodla sie';

  @override
  String authVerificationCodeError(String error) {
    return 'Blad kodu weryfikacyjnego: $error';
  }

  @override
  String get commonEnterVerificationCode => 'Wprowadz kod weryfikacyjny';

  @override
  String get authEnterYourEmail => 'Wprowadz e-mail';

  @override
  String authWeSentCodeTo(String email) {
    return 'Wyslalismy 6-cyfrowy kod na\n$email';
  }

  @override
  String get authEnterEmailForCode =>
      'Wprowadz adres e-mail, wyslimy kod weryfikacyjny';

  @override
  String get commonSendVerificationCode => 'Wyslij kod weryfikacyjny';

  @override
  String get authResendVerificationCode => 'Wyslij ponownie kod weryfikacyjny';

  @override
  String authCanResendAfter(int seconds) {
    return 'Mozna wyslac ponownie za $seconds sekund';
  }

  @override
  String get commonChangeEmail => 'Zmien e-mail';

  @override
  String get contactAddToContacts => 'Dodaj do kontaktow';

  @override
  String get contactAddingToContacts => 'Dodawanie...';

  @override
  String get contactAddedToContacts => 'Dodano do kontaktow';

  @override
  String contactAddFailedWithError(String error) {
    return 'Dodawanie nie powiodlo sie: $error';
  }

  @override
  String get contactAddPhone => 'Dodaj telefon';

  @override
  String get contactAddTag => 'Dodaj tagi';

  @override
  String get contactAddText => 'Dodaj tekst';

  @override
  String get contactAddPhoto => 'Dodaj zdjecie';

  @override
  String contactGroupCountLabel(int count) {
    return '$count grup';
  }

  @override
  String get contactAddedViaSearch => 'Dodano przez wyszukiwanie';

  @override
  String get contactAddTime => 'Dodaj czas';

  @override
  String get contactDoneButton => 'Gotowe';

  @override
  String get callWaitingForParticipants =>
      'Oczekiwanie na dolaczenie uczestnikow...';

  @override
  String callParticipantMe(String name) {
    return '$name (Ja)';
  }

  @override
  String get callSharingLabel => 'Udostepnianie';

  @override
  String callScreenSharingBy(String name) {
    return '$name udostepnia ekran';
  }

  @override
  String callParticipantCount(int count) {
    return '$count uczestnikow';
  }

  @override
  String get callMuteLabel => 'Wycisz';

  @override
  String get callUnmuteLabel => 'Wlacz dzwiek';

  @override
  String get callTurnOffVideo => 'Wylacz wideo';

  @override
  String get callTurnOnVideo => 'Wlacz wideo';

  @override
  String get callShareScreen => 'Udostepnij ekran';

  @override
  String get callStopSharing => 'Zatrzymaj udostepnianie';

  @override
  String get callSwitchCameraLabel => 'Przelacz';

  @override
  String get callLeaveLabel => 'Opusc';

  @override
  String get callParticipantsLabel => 'Uczestnicy';

  @override
  String get callJoiningMeeting => 'Dolaczanie do spotkania...';

  @override
  String chatPollVotesFormat(int count, String percentage) {
    return '$count głosów ($percentage%)';
  }

  @override
  String chatPollParticipantsFormat(int count) {
    return '$count uczestników';
  }

  @override
  String get commonTapToRetry => 'Dotknij, aby ponowić';

  @override
  String get chatDefaultRedPacketGreeting => 'Powodzenia i dobrobytu';

  @override
  String get groupAllowOthersToSearchAndJoin =>
      'Zezwól innym na wyszukiwanie i dołączanie';

  @override
  String get groupConfirmClearChatHistory =>
      'Czy na pewno chcesz usunąć historię czatu?';

  @override
  String get groupCreateGroupToChat => 'Utwórz grupę, aby rozpocząć czat';

  @override
  String get groupEditGroupAnnouncement => 'Edytuj ogłoszenie grupy';

  @override
  String get groupEditGroupDescription => 'Edytuj opis grupy';

  @override
  String get groupEnterGroupAnnouncement => 'Wpisz ogłoszenie grupy';

  @override
  String chatErrorWithMessage(String message) {
    return 'Błąd: $message';
  }

  @override
  String groupMemberCountClickToCopy(int count) {
    return '$count członków, kliknij aby skopiować ID grupy';
  }

  @override
  String get chatMusicLinkLabel => 'Link do muzyki';

  @override
  String get chatNoMediaUrlAvailable => 'URL multimediów niedostępny';

  @override
  String get groupNoPermissionToEditGroupName =>
      'Nie masz uprawnień do edycji nazwy grupy';

  @override
  String get chatRedPacketTransferCannotForward =>
      'Czerwone koperty i przelewy nie mogą być przekazywane';

  @override
  String get authEmailAddress => 'Adres e-mail';

  @override
  String get commonEnterEmailAddress => 'Wprowadź adres e-mail';

  @override
  String get authEmailRecoveryHint => 'Używany do odzyskiwania hasła';

  @override
  String get commonInvalidEmailFormat => 'Wprowadź prawidłowy adres e-mail';

  @override
  String get authOptional => 'Opcjonalnie';

  @override
  String get authResetPassword => 'Resetuj hasło';

  @override
  String get authEnterRegisteredEmail =>
      'Wprowadź adres e-mail, z którym się zarejestrowałeś';

  @override
  String get authSendResetCode => 'Wyślij kod resetowania';

  @override
  String authResetCodeSent(String email) {
    return 'Kod resetowania wysłany na $email';
  }

  @override
  String get authEnterResetCode => 'Wprowadź kod resetowania';

  @override
  String get authSetNewPassword => 'Ustaw nowe hasło';

  @override
  String get commonConfirmNewPassword => 'Potwierdź nowe hasło';

  @override
  String get commonNewPassword => 'Nowe hasło';

  @override
  String get authPasswordResetSuccess =>
      'Hasło zostało pomyślnie zresetowane. Zaloguj się nowym hasłem.';

  @override
  String get authResetPasswordFailed => 'Nie udało się zresetować hasła';

  @override
  String get settingsChangePassword => 'Zmień hasło';

  @override
  String get settingsCurrentPassword => 'Aktualne hasło';

  @override
  String get settingsEnterCurrentPassword => 'Wprowadź aktualne hasło';

  @override
  String get settingsEnterNewPassword => 'Wprowadź nowe hasło';

  @override
  String get settingsPasswordChanged =>
      'Hasło zostało pomyślnie zmienione. Zaloguj się nowym hasłem.';

  @override
  String get settingsChangePasswordFailed => 'Nie udało się zmienić hasła';

  @override
  String get settingsNewPasswordMustBeDifferent =>
      'Nowe hasło musi się różnić od aktualnego';

  @override
  String get settingsChangePasswordInfo =>
      'Po zmianie hasła zostaniesz wylogowany i musisz zalogować się nowym hasłem.';

  @override
  String get settingsPasswordRequirements => 'Wymagania dotyczące hasła:';

  @override
  String get settingsSecurityNote =>
      'Ze względów bezpieczeństwa po zmianie hasła musisz zalogować się ponownie na wszystkich urządzeniach.';

  @override
  String get settingsSecurity => 'Bezpieczeństwo';

  @override
  String get settingsCurrentBoundEmail => 'Aktualnie powiązany e-mail';

  @override
  String get settingsNewEmailAddress => 'Nowy adres e-mail';

  @override
  String get settingsEnterNewEmail => 'Wprowadź nowy adres e-mail';

  @override
  String get settingsVerificationCode => 'Kod weryfikacyjny';

  @override
  String get settingsVerificationCodeSent => 'Kod weryfikacyjny wysłany';

  @override
  String get settingsCodeSentTo => 'Kod weryfikacyjny wysłany na';

  @override
  String get settingsDidNotReceiveCode => 'Nie otrzymałeś kodu?';

  @override
  String get settingsEmailChangedSuccess => 'E-mail został pomyślnie zmieniony';

  @override
  String get settingsChangeEmailFailed => 'Nie udało się zmienić adresu e-mail';

  @override
  String get settingsEmailSecurityNote =>
      'Twój e-mail jest używany do odzyskiwania hasła. Chroń go.';

  @override
  String get commonGoogleLogin => 'Zaloguj przez Google';

  @override
  String get commonAppleLogin => 'Zaloguj przez Apple';

  @override
  String get commonWechat => 'WeChat';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsLanguageChanged => 'Język zmieniony';

  @override
  String get settingsTranslation => 'Tłumaczenie';

  @override
  String get settingsTranslateTextTo => 'Przetłumacz tekst na';

  @override
  String get settingsTranslateDescription =>
      'Wybierz język, na który chcesz przetłumaczyć wiadomości.';

  @override
  String get settingsAutoTranslate =>
      'Automatyczne tłumaczenie otrzymanych wiadomości';

  @override
  String get settingsAutoTranslateDescription =>
      'Automatycznie tłumacz wiadomości otrzymane na czacie na wybrany język.';

  @override
  String get settingsBiometricLogin => 'Logowanie biometryczne';

  @override
  String authLoginWithBiometric(Object type) {
    return 'Zaloguj się za pomocą $type';
  }

  @override
  String get settingsBiometricLoginEnabled => 'Logowanie biometryczne włączone';

  @override
  String get settingsBiometricLoginDisabled =>
      'Logowanie biometryczne wyłączone';

  @override
  String get settingsEnableBiometricLogin => 'Włącz logowanie biometryczne';

  @override
  String get settingsBiometricEnabled =>
      'Włączono - Użyj biometrii do logowania';

  @override
  String get settingsBiometricDisabled => 'Wyłączono - Dotknij, aby włączyć';

  @override
  String get settingsBiometricNeedRelogin =>
      'Wyloguj się i zaloguj ponownie, aby włączyć logowanie biometryczne';

  @override
  String get authOr => 'LUB';

  @override
  String get qrcodeCameraPermissionRestricted =>
      'Dostęp do kamery jest ograniczony na tym urządzeniu';

  @override
  String get authPasskeyLabel => 'Klucz';

  @override
  String get authGoogleLabel => 'Google';

  @override
  String get authAppleLabel => 'Jabłko';


  @override
  String get authSsoNotConfigured => 'Ten serwer nie skonfigurował dostawców logowania SSO';
  @override
  String get authSsoLabel => 'Jednokrotne logowanie';

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
      'Wprowadź sufiks szturchnięcia, np.: w ramię';

  @override
  String get groupAlbum => 'Album grupy';

  @override
  String get groupFiles => 'Pliki grupy';

  @override
  String get groupImages => 'Obrazy';

  @override
  String get groupVideos => 'Filmy';

  @override
  String get groupTotal => 'Łącznie';

  @override
  String get groupSize => 'Rozmiar';

  @override
  String get groupNoMedia => 'Brak mediów';

  @override
  String get groupNoMediaDescription => 'Brak zdjęć i filmów w tej grupie';

  @override
  String get groupDocuments => 'Dokumenty';

  @override
  String get groupNoFiles => 'Brak plików';

  @override
  String get groupNoFilesDescription => 'Brak plików w tej grupie';

  @override
  String groupDownloadStarted(String filename) {
    return 'Pobieranie $filename...';
  }

  @override
  String get contactNoCommonGroups => 'Brak wspólnych grup';

  @override
  String get contactNoCommonGroupsDescription => 'Nie macie wspólnych grup';

  @override
  String get chatVoiceMessage => 'Głos';

  @override
  String get chatMessage => 'Wiadomość';

  @override
  String get conversationHideChat => 'Ukryj';

  @override
  String get settingsQuickReply => 'Szybka odpowiedź';

  @override
  String get commonTranslate => 'Przetłumacz';

  @override
  String get contactCreateTag => 'Utwórz tag';

  @override
  String get contactEnterTagName => 'Wpisz nazwę tagu';

  @override
  String get contactEditTag => 'Edytuj tag';

  @override
  String get contactDeleteTag => 'Usuń znacznik';

  @override
  String contactDeleteTagConfirm(String tagName) {
    return 'Czy na pewno chcesz usunąć tag „$tagName”?';
  }

  @override
  String get contactNoTags => 'Nie ma jeszcze tagów';

  @override
  String get contactFriendPermissions => 'Uprawnienia znajomych';

  @override
  String get contactSetChatOnly => 'Ustaw jako Tylko czat';

  @override
  String get contactChatOnlyDesc =>
      'Mogę rozmawiać tylko z Tobą, inne treści będą ukryte';

  @override
  String get contactHideMyMoments => 'Ukryj moje chwile';

  @override
  String get contactHideMyMomentsDesc =>
      'Ten znajomy nie może zobaczyć moich chwil';

  @override
  String get contactHideTheirMoments => 'Ukryj ich chwile';

  @override
  String get contactHideTheirMomentsDesc =>
      'Nie wyświetlaj chwil tego znajomego';

  @override
  String get contactHideMyStatus => 'Ukryj mój status';

  @override
  String get contactHideMyStatusDesc =>
      'Ten znajomy nie może zobaczyć moich aktualizacji statusu';

  @override
  String get contactNoChatOnlyFriends =>
      'Żadnych znajomych korzystających wyłącznie z czatu';

  @override
  String get contactNoOfficialAccounts => 'Brak oficjalnych kont';

  @override
  String get contactFollowOfficialAccountsDesc =>
      'Śledź oficjalne konta, aby otrzymywać najnowsze aktualizacje';

  @override
  String get contactNoServiceAccounts => 'Brak kont usług';

  @override
  String get contactSubscribeServiceAccountsDesc =>
      'Subskrybuj konta usług, aby uzyskać wygodne usługi';

  @override
  String get contactNoEnterpriseContacts => 'Brak kontaktów korporacyjnych';

  @override
  String get contactEnterpriseContactsDesc =>
      'Tutaj zostaną wyświetlone kontakty korporacyjne';

  @override
  String get profileCardPack => 'Pakiet kart';

  @override
  String get profileOrders => 'Zamówienia';

  @override
  String get profileNoOrders => 'Żadnych zamówień';

  @override
  String get profileOrdersDesc => 'Twoje zamówienia będą wyświetlane tutaj';

  @override
  String get profileNoCards => 'Żadnych kart';

  @override
  String get profileCardsDesc => 'Tutaj będą wyświetlane Twoje karty';

  @override
  String get favoriteEnterTagsHint => 'Wprowadź tagi oddzielone przecinkami';

  @override
  String get favoriteTagsUpdated => 'Tagi zaktualizowane';

  @override
  String get favoriteForwardedContent => 'Treść przekazana';

  @override
  String get favoriteEnterNoteContent => 'Wprowadź treść notatki';

  @override
  String get favoriteNoteAdded => 'Uwaga dodana';

  @override
  String get favoriteLinkTitle => 'Tytuł linku';

  @override
  String get favoriteLinkUrl => 'https://';

  @override
  String get favoriteLinkAdded => 'Dodano łącze';

  @override
  String get contactPhotoAdded => 'Dodano zdjęcie';

  @override
  String get contactEnterPhone => 'Wpisz numer telefonu';

  @override
  String commonConversationWithId(String roomId) {
    return 'Rozmowa: $roomId';
  }

  @override
  String commonContactWithId(String userId) {
    return 'Kontakt: $userId';
  }

  @override
  String get commonDiscover => 'Odkrywaj';

  @override
  String commonDeveloping(String title) {
    return '$title\n(Wkrotce)';
  }

  @override
  String get commonPageNotFound => 'Strona nie zostala znaleziona';

  @override
  String get commonBackToHome => 'Wroc do strony glownej';

  @override
  String get settingsMessageNotifications => 'Powiadomienia o wiadomościach';

  @override
  String get settingsReceiveNewMessageNotifications =>
      'Otrzymuj powiadomienia o nowych wiadomościach';

  @override
  String get settingsShowMessagePreview => 'Pokaż podgląd wiadomości';

  @override
  String get settingsShowMessageContentInNotification =>
      'Pokaż treść wiadomości w powiadomieniach';

  @override
  String get settingsNotificationSound => 'Dzwiek powiadomienia';

  @override
  String get settingsPlaySoundOnMessage =>
      'Odtwarzaj dzwiek przy odbiorze wiadomosci';

  @override
  String get commonVibration => 'Wibracje';

  @override
  String get settingsVibrateOnMessage => 'Wibruj przy odbiorze wiadomosci';

  @override
  String get settingsDoNotDisturbMode => 'Nie przeszkadzać';

  @override
  String get settingsDoNotDisturbDescription =>
      'Nie otrzymuj powiadomień w określonym czasie';

  @override
  String get settingsStartTime => 'Czas rozpoczecia';

  @override
  String get settingsEndTime => 'Czas zakonczenia';

  @override
  String get settingsDeleteQuickReply => 'Usuń szybką odpowiedź';

  @override
  String get settingsEditQuickReply => 'Edytuj szybką odpowiedź';

  @override
  String get settingsAddQuickReply => 'Dodaj szybką odpowiedź';

  @override
  String get settingsManageQuickReplies => 'Zarządzaj szybkimi odpowiedziami';

  @override
  String get settingsNoQuickReplies => 'Brak szybkich odpowiedzi';

  @override
  String get settingsDefaultQuickReplies =>
      'Zostaną wyświetlone domyślne szybkie odpowiedzi';

  @override
  String get settingsWhoCanSee => 'Kto moze zobaczyc';

  @override
  String get settingsLastSeen => 'Ostatnio widziany';

  @override
  String get settingsHiddenChats => 'Ukryte czaty';

  @override
  String get settingsMessagesLabel => 'Wiadomości';

  @override
  String get settingsAllowStrangerMessages =>
      'Zezwalaj na wiadomości od nieznajomych';

  @override
  String get settingsReceiveMessagesFromNonContacts =>
      'Otrzymuj wiadomości od osób spoza kontaktów';

  @override
  String get settingsReadReceipts => 'Potwierdzenia odczytu';

  @override
  String get settingsLetOthersKnowYouRead =>
      'Pozwól innym wiedzieć, że przeczytałeś ich wiadomości';

  @override
  String get settingsTypingIndicator => 'Wskaźnik pisania';

  @override
  String get settingsLetOthersKnowYouTyping =>
      'Pozwól innym wiedzieć, że piszesz';

  @override
  String get settingsEveryone => 'Wszyscy';

  @override
  String get settingsContactsOnly => 'Tylko kontakty';

  @override
  String get settingsNobody => 'Nikt';

  @override
  String settingsWhoCanSeeTitle(String title) {
    return 'Kto może zobaczyć $title';
  }

  @override
  String settingsVersionInfo(String version) {
    return 'Wersja $version';
  }

  @override
  String get settingsCheckForUpdates => 'Sprawdź aktualizacje';

  @override
  String get settingsOpenSourceLicenses => 'Licencje open source';

  @override
  String get settingsFeedbackAndSuggestions => 'Opinie i sugestie';

  @override
  String get settingsBuiltOnMatrix => 'Oparty na protokole Matrix';

  @override
  String get settingsNoHiddenChats => 'Brak ukrytych czatów';

  @override
  String get settingsNoHiddenChatsDescription =>
      'Ukryte czaty pojawią się tutaj';

  @override
  String get settingsUnhideChat => 'Pokaż';

  @override
  String get settingsDarkMode => 'Tryb ciemny';

  @override
  String get settingsFontSize => 'Rozmiar czcionki';

  @override
  String get settingsBubbleStyle => 'Styl dymków';

  @override
  String get settingsFollowSystem => 'Podążaj za systemem';

  @override
  String get settingsAutoSwitchBySystem =>
      'Automatycznie przełączaj według ustawień systemowych';

  @override
  String get settingsLightMode => 'Tryb jasny';

  @override
  String get settingsAlwaysUseLightTheme => 'Zawsze używaj jasnego motywu';

  @override
  String get settingsDarkModeOption => 'Tryb ciemny';

  @override
  String get settingsAlwaysUseDarkTheme => 'Zawsze używaj ciemnego motywu';

  @override
  String get settingsFontSizeSmall => 'Mały';

  @override
  String get settingsFontSizeStandard => 'Standardowy';

  @override
  String get settingsFontSizeLarge => 'Duży';

  @override
  String get settingsFontSizeExtraLarge => 'Bardzo duży';

  @override
  String get settingsBubbleStyleWechat => 'Styl WeChat';

  @override
  String get settingsBubbleStyleWechatDesc => 'Klasyczny styl dymków WeChat';

  @override
  String get settingsBubbleStyleModern => 'Styl nowoczesny';

  @override
  String get settingsBubbleStyleModernDesc => 'Czysty nowoczesny styl dymków';

  @override
  String get settingsBubbleStyleClassic => 'Styl klasyczny';

  @override
  String get settingsBubbleStyleClassicDesc => 'Tradycyjny styl dymków';

  @override
  String get discoverVideoChannels => 'Kanaly';

  @override
  String get discoverLive => 'Na zywo';

  @override
  String get discoverListen => 'Sluchaj';

  @override
  String get discoverWatch => 'Ogladaj';

  @override
  String get discoverSearchDiscover => 'Szukaj';

  @override
  String get discoverNearbyPeople => 'W poblizu';

  @override
  String get discoverGames => 'Gry';

  @override
  String get discoverMiniPrograms => 'Miniprogramy';

  @override
  String get chatAlreadyInCall => 'Juz trwa polaczenie';

  @override
  String get commonConnectionFailed => 'Polaczenie nie powiodlo sie';

  @override
  String get chatCallRejected => 'Polaczenie odrzucone';

  @override
  String get chatNoAnswer => 'Brak odpowiedzi';

  @override
  String get commonClose => 'Zamknij';

  @override
  String get chatSelectContact => 'Wybierz kontakt';

  @override
  String get chatVoteRemoved => 'Glos usuniety';

  @override
  String get chatVoteChanged => 'Glos zmieniony';

  @override
  String get chatVoted => 'Zaglosowano';

  @override
  String chatReplyTo(String name) {
    return 'Odpowiedz do $name';
  }

  @override
  String get chatCurrentLocation => 'Biezaca lokalizacja';

  @override
  String chatNearbyPlace(int index) {
    return 'Miejsce w poblizu $index';
  }

  @override
  String chatApproximateDistance(String distance) {
    return 'Okolo $distance';
  }

  @override
  String get chatAddress => 'Adres';

  @override
  String get chatLatitude => 'Szerokosc geograficzna';

  @override
  String get chatLongitude => 'Dlugosc geograficzna';

  @override
  String get groupDescriptionUpdated => 'Opis grupy zaktualizowany';

  @override
  String get groupAvatarUpdated => 'Awatar grupy zaktualizowany';

  @override
  String get groupVisibilityUpdated => 'Zaktualizowano widoczność grupy';

  @override
  String get groupChannelCreated => 'Kanał utworzony';

  @override
  String get groupChannelUpdated => 'Kanał zaktualizowany';

  @override
  String get groupChannelDeleted => 'Kanał usunięty';

  @override
  String get callDecline => 'Odrzuc';

  @override
  String get callAnswer => 'Odbierz';

  @override
  String get callIncomingVideoCall => 'Przychodzące połączenie wideo';

  @override
  String get callIncomingVoiceCall => 'Przychodzące połączenie głosowe';

  @override
  String get callVideoCallInProgress => 'Połączenie wideo';

  @override
  String get callVoiceCallInProgress => 'Połączenie głosowe';

  @override
  String get callReconnectingCall => 'Ponowne łączenie...';

  @override
  String get callEnded => 'Połączenie zakończone';

  @override
  String get callFailed => 'Połączenie nieudane';

  @override
  String get callLivekitNotConfigured => 'LiveKit nie jest skonfigurowany';

  @override
  String callJoinMeetingFailed(String error) {
    return 'Nie udalo sie dolaczyc do spotkania: $error';
  }

  @override
  String callScreenShareFailed(String error) {
    return 'Udostepnianie ekranu nie powiodlo sie: $error';
  }

  @override
  String get profileN42BeanTitle => 'Fasola N42';

  @override
  String get profileNoN42Bean => 'Brak N42 Bean';

  @override
  String get profileN42BeanDetails => 'Szczegóły N42 Bean';

  @override
  String get profileN42BeanDescription =>
      'N42 Bean to token do wymiany na wirtualne przedmioty i usługi w N42. Obecnie dostępne:';

  @override
  String get profileN42BeanFeature1 =>
      'Ekskluzywne naklejki i motywy dla członków';

  @override
  String get profileN42BeanFeature2 => 'Personalizacja dymków czatu';

  @override
  String get profileN42BeanFeature3 =>
      'Personalizacja okładek czerwonych kopert';

  @override
  String get profileN42BeanFeature4 => 'Ekskluzywna odznaka pseudonimu';

  @override
  String get profileN42BeanFeature5 => 'Przywileje czatu grupowego';

  @override
  String get profileN42BeanFeature6 => 'Rozszerzenie pamięci w chmurze';

  @override
  String get profileN42BeanFeature7 => 'Filtry upiększające do rozmów wideo';

  @override
  String get profileN42BeanFeature8 => 'Personalizacja tła Moments';

  @override
  String get profileN42BeanFeature9 => 'Priorytetowa obsługa klienta VIP';

  @override
  String get profileGotIt => 'Rozumiem';

  @override
  String get profileNoN42BeanRecords => 'Brak rekordów N42 Bean';

  @override
  String get profileMoodAndThoughts => 'Nastroj i mysli';

  @override
  String get profileStatusHappy => 'Szczesliwy';

  @override
  String get profileStatusCracked => 'Rozbity';

  @override
  String get profileStatusLucky => 'Szczęsliwy';

  @override
  String get profileStatusSunny => 'Sloneczny';

  @override
  String get profileStatusTired => 'Zmęczony';

  @override
  String get profileStatusDaydream => 'Marzenia na jawie';

  @override
  String get profileStatusRushing => 'W pospichu';

  @override
  String get profileStatusOverthinking => 'Zamyslony';

  @override
  String get profileStatusEnergized => 'Pelen energii';

  @override
  String get profileWorkAndStudy => 'Praca i nauka';

  @override
  String get profileStatusWorking => 'Pracuje';

  @override
  String get profileStatusStudying => 'Ucze sie';

  @override
  String get profileStatusBusy => 'Zajety';

  @override
  String get profileStatusSlacking => 'Obijam sie';

  @override
  String get profileStatusTraveling => 'Podrozuje';

  @override
  String get profileStatusGoingHome => 'Wracam do domu';

  @override
  String get profileStatusDnd => 'Nie przeszkadzac';

  @override
  String get profileActivities => 'Aktywnosci';

  @override
  String get profileStatusHanging => 'Spotykam sie';

  @override
  String get profileStatusCheckIn => 'Meldunek';

  @override
  String get profileStatusExercising => 'Cwicze';

  @override
  String get profileStatusCoffee => 'Kawa';

  @override
  String get profileStatusBubbleTea => 'Bubble tea';

  @override
  String get profileStatusEating => 'Jem';

  @override
  String get profileStatusParenting => 'Opieka nad dziecmi';

  @override
  String get profileStatusSavingWorld => 'Ratuje swiat';

  @override
  String get profileStatusSelfie => 'Selfie';

  @override
  String get profileRest => 'Odpoczynek';

  @override
  String get profileStatusRetreat => 'Odwrot';

  @override
  String get profileStatusHome => 'W domu';

  @override
  String get profileStatusSleeping => 'Spie';

  @override
  String get profileStatusCatLover => 'Kociarz';

  @override
  String get profileStatusDogWalking => 'Spacer z psem';

  @override
  String get profileStatusGaming => 'Gram';

  @override
  String get profileStatusListening => 'Slucham';

  @override
  String get profileEditAddress => 'Edytuj adres';

  @override
  String get profileRecipient => 'Odbiorca';

  @override
  String get profileEnterRecipientName => 'Wprowadz nazwe odbiorcy';

  @override
  String get profilePhoneNumber => 'Numer telefonu';

  @override
  String get profileEnterPhoneNumber => 'Wprowadz numer telefonu';

  @override
  String get profileRegionHint => 'Wojewodztwo/Miasto/Dzielnica';

  @override
  String get profileDetailedAddress => 'Szczegolowy adres';

  @override
  String get profileDetailedAddressHint => 'Ulica, numer budynku itp.';

  @override
  String get profileSetAsDefaultAddress => 'Ustaw jako domyslny adres';

  @override
  String get profilePleaseCompleteInfo => 'Wypelnij wszystkie pola';

  @override
  String get profileEditInvoice => 'Edytuj fakture';

  @override
  String get profileInvoiceType => 'Typ faktury: ';

  @override
  String get profileCompanyName => 'Nazwa firmy';

  @override
  String get profilePersonalName => 'Imie i nazwisko';

  @override
  String get profileEnterCompanyName => 'Wprowadz nazwe firmy';

  @override
  String get profileEnterName => 'Wprowadz imie i nazwisko';

  @override
  String get profileTaxIdNumber => 'Numer NIP';

  @override
  String get profileEnterTaxIdNumber => 'Wprowadz numer NIP';

  @override
  String get profileBankNameOptional => 'Nazwa banku (opcjonalna)';

  @override
  String get profileEnterBankName => 'Wprowadz nazwe banku';

  @override
  String get profileBankAccountOptional => 'Numer konta bankowego (opcjonalny)';

  @override
  String get profileEnterBankAccount => 'Wprowadz numer konta bankowego';

  @override
  String get profileCompanyAddressOptional => 'Adres firmy (opcjonalny)';

  @override
  String get profileEnterCompanyAddress => 'Wprowadz adres firmy';

  @override
  String get profileCompanyPhoneOptional => 'Telefon firmy (opcjonalny)';

  @override
  String get profileEnterCompanyPhone => 'Wprowadz telefon firmy';

  @override
  String get profileSetAsDefaultInvoice => 'Ustaw jako domyslna fakture';

  @override
  String get profileRingtoneVibrate => 'Wibracja';

  @override
  String get profileRingtoneSilent => 'Cichy';

  @override
  String get profileVibrateMode => 'Tryb wibracji';

  @override
  String get profileSilentMode => 'Tryb cichy';

  @override
  String profilePlayFailed(String ringtoneName) {
    return 'Nie udalo sie odtworzyc: $ringtoneName';
  }

  @override
  String profilePlaying(String ringtoneName) {
    return 'Odtwarzanie: $ringtoneName';
  }

  @override
  String get profileStop => 'Zatrzymaj';

  @override
  String get profileSelectRingtone => 'Wybierz dzwonek';

  @override
  String get profileLoadingRingtones => 'Ladowanie dzwonkow...';

  @override
  String get profileNoRingtonesFound => 'Nie znaleziono dzwonkow';

  @override
  String mainMessagesWithCount(int count) {
    return 'Wiadomosci($count)';
  }

  @override
  String get storyViewers => 'Widzowie';

  @override
  String get storyNoViewers => 'Brak widzów';

  @override
  String get storyReplyToStory => 'Odpowiedz na relację...';

  @override
  String get commonCopiedToClipboard => 'Skopiowano do schowka';

  @override
  String get commonMore => 'Wiecej';

  @override
  String get commonTranslating => 'Tłumaczenie...';

  @override
  String commonTranslatedFrom(String language) {
    return 'Przetłumaczono z $language';
  }

  @override
  String get commonTranslation => 'Tłumaczenie';

  @override
  String get commonTranslationFailed => 'Tłumaczenie nie powiodło się';

  @override
  String get commonAllRead => 'Wszystko przeczytane';

  @override
  String commonReadCount(int count) {
    return '$count przeczytane';
  }

  @override
  String get commonYouRecalledMessage => 'Wycofales wiadomosc';

  @override
  String get commonMessageRecalled => 'Wiadomosc wycofana';

  @override
  String get commonReEdit => 'Edytuj ponownie';

  @override
  String get commonWalletArea => 'Strefa portfela';

  @override
  String get callIncomingCall => 'Polaczenie przychodzace';

  @override
  String get callMissedCall => 'Nieodebrane polaczenie';

  @override
  String get groupRemoveAdmin => 'Usun administratora';

  @override
  String get chatSelectCurrency => 'Wybierz walute';

  @override
  String get chatSelectEmoji => 'Wybierz emotikon';

  @override
  String get chatSelectRedPacketCover => 'Wybierz okładkę';

  @override
  String get groupSetAsAdmin => 'Ustaw jako administratora';

  @override
  String get chatVideoPlaybackFailed => 'Odtwarzanie wideo nie powiodlo sie';

  @override
  String get groupViewProfile => 'Zobacz profil';

  @override
  String get favoriteAddLinkComingSoon => 'Dodawanie linkow wkrotce dostepne';

  @override
  String get favoriteNewNoteComingSoon => 'Nowa notatka wkrotce dostepna';

  @override
  String get qrcodeSaveFeatureComingSoon =>
      'Funkcja zapisywania wkrotce dostepna';

  @override
  String get qrcodeShareFeatureComingSoon =>
      'Funkcja udostepniania wkrotce dostepna';

  @override
  String qrcodeProcessFailed(String error) {
    return 'Nie udalo sie przetworzyc kodu QR: $error';
  }

  @override
  String get securityDeviceIdRequired =>
      'Wymagany jest identyfikator urządzenia';

  @override
  String securityVerificationStartFailed(String error) {
    return 'Nie udało się rozpocząć weryfikacji: $error';
  }

  @override
  String get securityVerificationFailed => 'Weryfikacja nie powiodła się';

  @override
  String securityVerificationFailedWithReason(String reason) {
    return 'Weryfikacja nie powiodła się: $reason';
  }

  @override
  String get securityEmojiMismatchRejected =>
      'Weryfikacja odrzucona – emoji nie pasują';

  @override
  String get securityWaitingForDeviceAccept =>
      'Czekam, aż drugie urządzenie zaakceptuje...';

  @override
  String get securityVerifyDevice => 'Sprawdź to urządzenie';

  @override
  String get securityConfirmEmojiMatch =>
      'Upewnij się, że poniższe emoji są wyświetlane na obu urządzeniach w tej samej kolejności';

  @override
  String get securityEmojiDontMatch => 'Nie pasują';

  @override
  String get securityEmojiMatch => 'Pasują';

  @override
  String get securityWaitingForDeviceConfirm =>
      'Czekam, aż drugie urządzenie potwierdzi...';

  @override
  String get securityVerificationSuccess => 'Weryfikacja przebiegła pomyślnie!';

  @override
  String get securityDeviceVerifiedTrusted =>
      'To urządzenie jest teraz zweryfikowane i zaufane.';

  @override
  String get securityCompareEmoji => 'Porównaj emoji na obu urządzeniach';

  @override
  String get securityCompareNumbers => 'Porównaj liczby na obu urządzeniach';

  @override
  String get commonTryAgain => 'Spróbuj ponownie';

  @override
  String get commonDone => 'Gotowe';

  @override
  String get chatExportTitle => 'Eksportuj czat';

  @override
  String get chatExportSuccess => 'Eksport udany';

  @override
  String chatExportFailed(String error) {
    return 'Eksport nie powiódł się: $error';
  }

  @override
  String get chatExportFormat => 'Format eksportu';

  @override
  String get chatExportHtmlDesc =>
      'Czytelny w dowolnej przeglądarce ze stylizowanym układem';

  @override
  String get chatExportJsonDesc =>
      'Ustrukturyzowany format danych nadający się do odczytu maszynowego';

  @override
  String get chatExportDateRange => 'Zakres dat';

  @override
  String get chatExportAll => 'Wszystkie wiadomości';

  @override
  String get chatExportLastWeek => 'Ostatnie 7 dni';

  @override
  String get chatExportLastMonth => 'Ostatni miesiąc';

  @override
  String get chatExportLast3Months => 'Ostatnie 3 miesiące';

  @override
  String get chatExportMessageCount => 'Wiadomości do wyeksportowania';

  @override
  String get chatExportButton => 'Eksportuj i udostępniaj';

  @override
  String get chatMediaGallery => 'Galeria multimediów';

  @override
  String get chatExportHistory => 'Eksportuj historię czatów';

  @override
  String get pdfLoadFailed => 'Nie udało się załadować pliku PDF';

  @override
  String pdfPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get mediaAll => 'Wszystko';

  @override
  String get mediaImages => 'Obrazy';

  @override
  String get mediaVideos => 'Filmy';

  @override
  String get mediaFiles => 'Pliki';

  @override
  String get mediaAudio => 'Dźwięk';

  @override
  String mediaItemsCount(int count) {
    return 'Elementy $count';
  }

  @override
  String get mediaNoMediaFound => 'Nie znaleziono multimediów';

  @override
  String get spacesTitle => 'Społeczności';

  @override
  String get spacesCreate => 'Utwórz społeczność';

  @override
  String get spacesJoined => 'Dołączył';

  @override
  String get spacesDiscover => 'Odkryj';

  @override
  String get spacesNoJoined => 'Nie dołączyła jeszcze żadna społeczność';

  @override
  String get spacesExplore => 'Przeglądaj społeczności';

  @override
  String get spacesNoPublic => 'Nie znaleziono społeczności publicznych';

  @override
  String get spacesJoin => 'Dołącz';

  @override
  String get spacesSubSpaces => 'Podspołeczności';

  @override
  String get spacesChannels => 'Kanały';

  @override
  String spacesMembersCount(int count) {
    return 'Członkowie $count';
  }

  @override
  String get spacesPublic => 'Publiczne';

  @override
  String get spacesPrivate => 'Prywatny';

  @override
  String get spacesSuggested => 'Sugerowane';

  @override
  String spacesChannelsCount(int count) {
    return 'Kanały $count';
  }

  @override
  String get callInCallChat => 'Czat podczas rozmowy';

  @override
  String callMessagesCount(int count) {
    return 'Komunikaty $count';
  }

  @override
  String get callNoMessagesYet =>
      'Nie ma jeszcze żadnych wiadomości.\nWyślij wiadomość, aby rozpocząć.';

  @override
  String get callTypeMessage => 'Wpisz wiadomość...';

  @override
  String get callYouSender => 'Ty';

  @override
  String get callChatLabel => 'Czat';

  @override
  String get chatEdited => 'Edytowane';

  @override
  String get chatEditHistory => 'Edytuj historię';

  @override
  String get chatOriginalMessage => 'Oryginał';

  @override
  String chatEditedAt(String time) {
    return 'Edytowano w $time';
  }

  @override
  String get chatViewOnce => 'Obejrzyj raz';

  @override
  String get chatViewOncePhoto => 'Zobacz jedno zdjęcie';

  @override
  String get chatViewOnceVideo => 'Obejrzyj raz wideo';

  @override
  String get chatViewOnceViewed => 'Oglądane';

  @override
  String get chatViewOnceExpired => 'Wygasło';

  @override
  String get chatViewOnceTap => 'Kliknij, aby wyświetlić';

  @override
  String get chatAutoFaceBlur => 'Automatyczne rozmycie twarzy';

  @override
  String get chatAutoFaceBlurDesc =>
      'Automatycznie rozmywaj twarze podczas wysyłania zdjęć';

  @override
  String get threadReplyInThread => 'Odpowiedz w wątku';

  @override
  String threadReplies(int count) {
    return 'Odpowiedzi $count';
  }

  @override
  String get threadReply => '1 odpowiedź';

  @override
  String threadLatestReply(String preview) {
    return 'Najnowsze: $preview';
  }

  @override
  String get threadTitle => 'Wątek';

  @override
  String get threadReplyPlaceholder => 'Odpowiedz w wątku...';

  @override
  String threadParticipants(int count) {
    return 'Uczestnicy $count';
  }

  @override
  String get voiceRoomTitle => 'Pokój głosowy';

  @override
  String get voiceRoomCreate => 'Utwórz pokój głosowy';

  @override
  String get voiceRoomJoin => 'Dołącz';

  @override
  String get voiceRoomLeave => 'Wyjdź';

  @override
  String get voiceRoomEnd => 'Pokój końcowy';

  @override
  String get voiceRoomRaiseHand => 'Podnieś rękę';

  @override
  String get voiceRoomLowerHand => 'Dolna ręka';

  @override
  String get voiceRoomMute => 'Wycisz';

  @override
  String get voiceRoomUnmute => 'Wyłącz wyciszenie';

  @override
  String get voiceRoomHost => 'Gospodarz';

  @override
  String get voiceRoomSpeakers => 'Głośniki';

  @override
  String get voiceRoomListeners => 'Słuchacze';

  @override
  String get voiceRoomLive => 'NA ŻYWO';

  @override
  String get voiceRoomEnded => 'Zakończone';

  @override
  String get voiceRoomScheduled => 'Zaplanowane';

  @override
  String get voiceRoomApprove => 'Zatwierdź';

  @override
  String get voiceRoomDemote => 'Przejdź do Słuchacza';

  @override
  String voiceRoomHandRaised(String name) {
    return '$name podniósł rękę';
  }

  @override
  String get voiceRoomName => 'Nazwa pokoju';

  @override
  String get voiceRoomTopic => 'Temat (opcjonalnie)';

  @override
  String get voiceRoomNoActive => 'Brak aktywnych pokoi głosowych';

  @override
  String get voiceRoomConnecting => 'Łączenie...';

  @override
  String get usernameTitle => 'Nazwa użytkownika';

  @override
  String get usernameSet => 'Ustaw nazwę użytkownika';

  @override
  String get usernameChange => 'Zmień nazwę użytkownika';

  @override
  String get usernamePlaceholder => 'Wpisz nazwę użytkownika';

  @override
  String get usernameAvailable => 'Dostępna nazwa użytkownika';

  @override
  String get usernameUnavailable => 'Nazwa użytkownika jest już zajęta';

  @override
  String get usernameInvalid =>
      '3-30 znaków, małe litery, cyfry, podkreślenie. Trzeba zaczynać od litery.';

  @override
  String get usernameReserved => 'Ta nazwa użytkownika jest zastrzeżona';

  @override
  String get usernameSaved => 'Nazwa użytkownika została zapisana';

  @override
  String get usernameSearchHint => 'Szukaj według @nazwy użytkownika';

  @override
  String get ensName => 'Nazwa EN';

  @override
  String get ensLinked => 'Związany z ENS';

  @override
  String get ensResolving => 'Rozwiązanie problemu ENS...';

  @override
  String get ensNotFound => 'Nie znaleziono nazwy ENS';

  @override
  String get tokenGateTitle => 'Brama Żetonowa';

  @override
  String get tokenGateEnable => 'Włącz bramę tokenów';

  @override
  String get tokenGateDisable => 'Wyłącz bramę tokenów';

  @override
  String get tokenGateAddRule => 'Dodaj regułę';

  @override
  String get tokenGateRemoveRule => 'Usuń regułę';

  @override
  String get tokenGateContractAddress => 'Adres umowy';

  @override
  String get tokenGateMinBalance => 'Minimalne saldo';

  @override
  String get tokenGateTokenId => 'Identyfikator tokena (ERC-1155)';

  @override
  String get tokenGateChainId => 'Identyfikator łańcucha';

  @override
  String get tokenGateVerifying => 'Weryfikacja zasobów tokenów...';

  @override
  String get tokenGateVerified => 'Weryfikacja przebiegła pomyślnie';

  @override
  String get tokenGateDenied => 'Nie spełniasz wymagań dotyczących tokena';

  @override
  String get tokenGateOperatorAnd => 'Musi spełniać WSZYSTKIE zasady';

  @override
  String get tokenGateOperatorOr => 'Musi spełniać KAŻDĄ zasadę';

  @override
  String get tokenGateRuleErc20 => 'Token ERC-20';

  @override
  String get tokenGateRuleErc721 => 'NFT (ERC-721)';

  @override
  String get tokenGateRuleErc1155 => 'Wiele tokenów (ERC-1155)';

  @override
  String get tokenGateRuleNative => 'Token natywny';

  @override
  String get tokenGateSaved => 'Brama żetonowa zapisana';

  @override
  String get tokenGateEnableDescription =>
      'Wymagaj od członków posiadania tokenów, aby dołączyć';

  @override
  String get tokenGateOperator => 'Logika reguł';

  @override
  String get tokenGateRules => 'Zasady';

  @override
  String get tokenGateSymbol => 'Symbol (opcjonalnie)';

  @override
  String get tokenGateChain => 'Łańcuch';

  @override
  String get tokenGateTokenStandard => 'Standard tokena';

  @override
  String get tokenGateDenialMessage => 'Komunikat odmowy';

  @override
  String get tokenGateDenialMessageHint =>
      'Komunikat wyświetlany w przypadku niepowodzenia weryfikacji';

  @override
  String get tokenGateVerifyTitle => 'Weryfikacja tokena';

  @override
  String get tokenGateVerifyPassed => 'Weryfikacja pomyślna';

  @override
  String get tokenGateVerifyFailed => 'Weryfikacja nie powiodła się';

  @override
  String get tokenGateRetryVerify => 'Spróbuj ponownie';

  @override
  String get tokenGateRequired => 'Wymagane';

  @override
  String get tokenGateYourBalance => 'Twoje saldo';

  @override
  String get tokenGateRulesActive => 'reguły aktywne';

  @override
  String get tokenGateDisabled => 'Niepełnosprawny';

  @override
  String get ensNotBound => 'Nie związany';

  @override
  String get liveLocation => 'Lokalizacja na żywo';

  @override
  String get stopLiveLocation => 'Przestań udostępniać';

  @override
  String get startLiveLocation => 'Rozpocznij udostępnianie';

  @override
  String get selectDuration => 'Wybierz Czas trwania';

  @override
  String get groupChatFiles => 'Pliki czatu';

  @override
  String get groupLinks => 'Linki';

  @override
  String get groupNoLinks => 'Nie ma jeszcze żadnych linków';

  @override
  String get chatBackground => 'Tło czatu';

  @override
  String get solidColors => 'Jednolite kolory';

  @override
  String get gradients => 'Gradienty';

  @override
  String get defaultBackground => 'Domyślne';

  @override
  String get settingsFontSizeSlider => 'Rozmiar czcionki';

  @override
  String get autoDownload => 'Automatyczne pobieranie';

  @override
  String get images => 'Obrazy';

  @override
  String get voice => 'Głos';

  @override
  String get video => 'Wideo';

  @override
  String get files => 'Pliki';

  @override
  String get mobileData => 'Dane mobilne';

  @override
  String get roaming => 'Roaming';

  @override
  String get storageManagement => 'Przechowywanie';

  @override
  String get totalUsage => 'Całkowite wykorzystanie';

  @override
  String get cache => 'Pamięć podręczna';

  @override
  String get other => 'Inne';

  @override
  String get clearCache => 'Wyczyść pamięć podręczną';

  @override
  String get cacheCleared => 'Pamięć podręczna wyczyszczona';

  @override
  String get clearCacheFailed => 'Nie udało się wyczyścić pamięci podręcznej';

  @override
  String get confirmClearCache =>
      'Wyczyścić wszystkie dane z pamięci podręcznej?';

  @override
  String get mapView => 'Widok mapy';

  @override
  String liveLocationSharingCount(int count) {
    return 'Osoby $count udostępniają lokalizację';
  }

  @override
  String get minutes15 => '15 minut';

  @override
  String get minutes30 => '30 minut';

  @override
  String get hour1 => '1 godzina';

  @override
  String get hours8 => '8 godzin';

  @override
  String get personalCard => 'Karta osobista';

  @override
  String get downloadFailed => 'Pobieranie nie powiodło się';

  @override
  String get locationExpired => 'Wygasło';

  @override
  String secondsRemaining(int count) {
    return '$count';
  }

  @override
  String minutesRemaining(int count) {
    return '$count minut';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '$hours godziny $minutes minuty';
  }

  @override
  String get favoriteMessages => 'Ulubione';

  @override
  String get linksCopied => 'Link skopiowany';

  @override
  String get noLinksFound => 'Nie znaleziono żadnych linków';

  @override
  String get roomStorageRanking => 'Ranking przechowywania pomieszczeń';

  @override
  String get downloadComplete => 'Pobieranie zakończone';

  @override
  String get downloading => 'Pobieram...';

  @override
  String get draftSaved => 'Wersja robocza zapisana';

  @override
  String get voiceRecording => 'Nagrywanie głosu';

  @override
  String get searchLocation => 'Wyszukaj lokalizację';

  @override
  String get tapToSearch => 'Kliknij, aby wyszukać';

  @override
  String get settingsThisDevice => 'To urządzenie';

  @override
  String get settingsJustNow => 'Właśnie teraz';

  @override
  String get settingsDeviceId => 'Identyfikator urządzenia';

  @override
  String get settingsStatus => 'Stan';

  @override
  String get settingsLastActive => 'Ostatni aktywny';

  @override
  String get settingsIpAddress => 'Adres IP';

  @override
  String get settingsRenameDevice => 'Zmień nazwę urządzenia';

  @override
  String get settingsDeviceNameHint => 'Wprowadź nazwę urządzenia';

  @override
  String get settingsDeviceRenamed => 'Zmieniono nazwę urządzenia';

  @override
  String get settingsRenameFailed => 'Zmiana nazwy nie powiodła się';

  @override
  String get settingsRemoteLogout => 'Zdalne wylogowanie';

  @override
  String settingsRemoteLogoutConfirm(String deviceName) {
    return 'Czy na pewno chcesz się wylogować \"$deviceName\"? Tej akcji nie można cofnąć.';
  }

  @override
  String get settingsDeviceLoggedOut => 'Urządzenie zostało wylogowane';

  @override
  String get settingsLogoutFailed => 'Wylogowanie nie powiodło się';

  @override
  String get settingsLogout => 'Wyloguj się';

  @override
  String get settingsVerifyIdentity => 'Zweryfikuj tożsamość';

  @override
  String get settingsEnterPasswordToConfirm =>
      'Wprowadź swoje hasło, aby potwierdzić tę czynność.';

  @override
  String get scheduledSendTitle => 'Zaplanuj wiadomość';

  @override
  String get scheduledSendInOneHour => 'Za 1 godzinę';

  @override
  String get scheduledSendTonight => 'Dziś wieczorem (20:00)';

  @override
  String get scheduledSendTomorrowMorning => 'Jutro rano (9:00)';

  @override
  String get scheduledSendCustom => 'Wybierz datę i godzinę';

  @override
  String get scheduledMessageLabel => 'Zaplanowane';

  @override
  String get scheduledMessageCancel => 'Anuluj zaplanowaną wiadomość';

  @override
  String get chatLockTitle => 'Blokada czatu';

  @override
  String get chatLockEnable => 'Zablokuj ten czat';

  @override
  String get chatLockDisable => 'Odblokuj ten czat';

  @override
  String get chatLockDescription =>
      'Aby otworzyć zablokowane czaty, wymagana jest weryfikacja biometryczna lub PIN';

  @override
  String get chatLockVerifyTitle => 'Czat zablokowany';

  @override
  String get chatLockVerifySubtitle =>
      'Zweryfikuj, aby uzyskać dostęp do tego czatu';

  @override
  String get chatLockVerifyFailed => 'Weryfikacja nie powiodła się';

  @override
  String get chatLockEnabled => 'Czat zablokowany';

  @override
  String get chatLockDisabled => 'Czat odblokowany';

  @override
  String get chatLockPinTitle => 'Wprowadź PIN';

  @override
  String get chatLockPinSetTitle => 'Ustaw PIN';

  @override
  String get chatLockPinConfirmTitle => 'Potwierdź PIN';

  @override
  String get chatLockPinMismatch => 'PIN nie pasuje';

  @override
  String get chatLockUseBiometric => 'Użyj biometrii';

  @override
  String get chatLockUsePin => 'Użyj PIN-u';

  @override
  String get mediaEditorUndo => 'Cofnij';

  @override
  String get mediaEditorRedo => 'Powtórz';

  @override
  String get mediaEditorCrop => 'Przytnij';

  @override
  String get mediaEditorFilter => 'Filtruj';

  @override
  String get mediaEditorDraw => 'Narysuj';

  @override
  String get mediaEditorText => 'Tekst';

  @override
  String get aiAssistant => 'Asystent AI';

  @override
  String get aiAssistantWelcome =>
      'Witam! Jestem asystentem AI N42. Czy mogę Panu pomóc?';

  @override
  String get aiAssistantNotConfigured => 'Usługa AI nie została skonfigurowana';

  @override
  String get aiAssistantSettings => 'Ustawienia AI';

  @override
  String get aiAssistantClearHistory => 'Wyczyść historię czatów';

  @override
  String get aiAssistantClearHistoryConfirm =>
      'Czy na pewno chcesz wyczyścić całą historię czatów AI?';

  @override
  String get aiAssistantStopGenerating => 'Przestań generować';

  @override
  String get aiAssistantModel => 'Modelka';

  @override
  String get aiAssistantTemperature => 'Temperatura';

  @override
  String get aiAssistantMaxTokens => 'Maksymalna liczba tokenów';

  @override
  String get aiAssistantContextWindow => 'Okno kontekstowe';

  @override
  String get aiAssistantServiceStatus => 'Stan usługi';

  @override
  String get aiAssistantAvailable => 'Dostępne';

  @override
  String get aiAssistantUnavailable => 'Niedostępne';

  @override
  String get aiSummarize => 'Podsumowanie sztucznej inteligencji';

  @override
  String aiSummarizeUnread(int count) {
    return 'Podsumuj nieprzeczytane wiadomości $count';
  }

  @override
  String get aiSummarizeLoading => 'Podsumowując...';

  @override
  String get aiSummarizeError => 'Nie udało się podsumować';

  @override
  String get aiRewrite => 'Przepisz AI';

  @override
  String get aiRewriteFormal => 'Formalne';

  @override
  String get aiRewriteCasual => 'Swobodny';

  @override
  String get aiRewritePlayful => 'Zabawny';

  @override
  String get aiRewriteProfessional => 'Profesjonalny';

  @override
  String get aiRewriteAccept => 'Użyj';

  @override
  String get aiRewriteCancel => 'Anuluj';

  @override
  String get aiRewriteLoading => 'Przepisywanie...';

  @override
  String get aiLinkSummary => 'Podsumowanie sztucznej inteligencji';

  @override
  String get aiLinkSummaryAnalyzing => 'Analizuję...';

  @override
  String get chatFolderManagement => 'Zarządzaj folderami';

  @override
  String get chatFolderSystem => 'Foldery systemowe';

  @override
  String get chatFolderCustom => 'Foldery niestandardowe';

  @override
  String get chatFolderEmpty => 'Nie ma jeszcze folderów niestandardowych';

  @override
  String get chatFolderCreate => 'Utwórz folder';

  @override
  String get chatFolderEdit => 'Edytuj folder';

  @override
  String get chatFolderNameHint => 'Nazwa folderu';

  @override
  String get chatFolderAll => 'Wszystko';

  @override
  String get chatFolderUnread => 'Nieprzeczytane';

  @override
  String get chatFolderPersonal => 'Osobiste';

  @override
  String get chatFolderGroups => 'Grupy';

  @override
  String get chatFolderChannels => 'Kanały';

  @override
  String get chatFolderMuted => 'Wyciszony';

  @override
  String get storyAddMusic => 'Dodaj muzykę';

  @override
  String get storyChangeMusic => 'Zmień muzykę';

  @override
  String get storyBackgroundMusic => 'Muzyka w tle';

  @override
  String get storyMusicPreview => 'Podgląd (maks. 15 s)';

  @override
  String get storyChooseFromDevice => 'Wybierz z urządzenia';

  @override
  String get storyUseThisMusic => 'Użyj tej muzyki';

  @override
  String get authPasskeyNotSupported =>
      'Klucz dostępu nie jest obsługiwany na tym urządzeniu';

  @override
  String get authPasskeyRegister => 'Zarejestruj klucz';

  @override
  String get authPasskeyNoRegistered => 'Nie zarejestrowano żadnych kluczy';

  @override
  String get authPasskeyRegisterHint =>
      'Zarejestruj klucz do tego konta. Samodzielne logowanie za pomocą hasła zostanie włączone później.';

  @override
  String get authPasskeyNameYours => 'Nazwij swój klucz dostępu';

  @override
  String get authPasskeyRegistered => 'Klucz dostępu zapisany na tym koncie';

  @override
  String get authPasskeyDeleted => 'Klucz dostępu został usunięty z tego konta';

  @override
  String authPasskeyDeleteConfirm(String name) {
    return 'Usunąć klucz „$name”? Przed użyciem późniejszego logowania za pomocą hasła konieczne będzie ponowne zarejestrowanie konta.';
  }

  @override
  String get momentVisibilityPublic => 'Publiczne';

  @override
  String get momentVisibilityPrivate => 'Prywatny';

  @override
  String get momentVisibilityPartial => 'Wybrani przyjaciele';

  @override
  String get momentVisibilityExcluded => 'Wyklucz niektórych znajomych';

  @override
  String momentUserMoments(String userName) {
    return 'Chwile $userName';
  }

  @override
  String get momentForwardTo => 'Przekaż do';

  @override
  String get momentForwardSuccess => 'Przekazano pomyślnie';

  @override
  String get momentSelectFriends => 'Wybierz Przyjaciele';

  @override
  String get momentSelectTags => 'Wybierz według tagów';

  @override
  String momentSelectedCount(int count) {
    return 'Wybrano ($count)';
  }

  @override
  String get momentNoMomentsYet => 'Nie ma jeszcze żadnych momentów';

  @override
  String get momentForwardMoment => 'Moment do przodu';

  @override
  String get momentAddComment => 'Dodaj komentarz...';

  @override
  String momentForwardContent(String content) {
    return '[Moment] $content';
  }

  @override
  String get momentDeleteMoment => 'Usuń chwilę';

  @override
  String get momentDeleteConfirm => 'Czy na pewno chcesz usunąć ten moment?';

  @override
  String get momentComment => 'Komentarz';

  @override
  String get momentWriteComment => 'Napisz komentarz...';

  @override
  String get momentLike => 'Jak';

  @override
  String get momentUnlike => 'Inaczej';

  @override
  String get momentForward => 'Naprzód';

  @override
  String get momentDelete => 'Usuń';

  @override
  String get momentReply => 'odpowiedz';

  @override
  String get momentMoment => 'Chwila';

  @override
  String momentLikesCount(int count) {
    return '$count lubi';
  }

  @override
  String momentCommentsCount(int count) {
    return 'Komentarze $count';
  }

  @override
  String get momentNoComments => 'Nie ma jeszcze żadnych komentarzy';

  @override
  String get momentFailedToLoad => 'Nie udało się załadować obrazu';

  @override
  String momentReplyTo(String userName) {
    return 'Odpowiedz na $userName...';
  }

  @override
  String get momentNoConversations => 'Żadnych rozmów';

  @override
  String get momentJustNow => 'właśnie teraz';

  @override
  String momentMinutesAgo(int count) {
    return '${count}m temu';
  }

  @override
  String momentHoursAgo(int count) {
    return '${count}h temu';
  }

  @override
  String momentDaysAgo(int count) {
    return '${count}d temu';
  }

  @override
  String get chatGroupAnnouncementHint => 'Wprowadź ogłoszenie grupowe';

  @override
  String get chatGroupAnnouncementEmpty => 'Brak ogłoszenia';

  @override
  String get chatEditNickname => 'Edytuj pseudonim';

  @override
  String get chatNicknameHint => 'Wpisz swój pseudonim w tej grupie';

  @override
  String get contactAddPhoneHint => 'Wpisz numer telefonu';

  @override
  String get contactNotesHint => 'Dodaj notatki na temat tego kontaktu';

  @override
  String get reportTitle => 'Raport';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonHarassment => 'Nękanie';

  @override
  String get reportReasonFraud => 'Oszustwo';

  @override
  String get reportReasonOther => 'Inne';

  @override
  String get reportSubmitted => 'Raport przesłany';

  @override
  String get reportDescription => 'Dodatkowy opis (opcjonalnie)';

  @override
  String get qrcodeSaved => 'Kod QR zapisany w albumie';

  @override
  String get chatSendRedPacketInChat =>
      'Proszę o przesłanie czerwonej paczki na czacie';

  @override
  String get commonSaveFailed => 'Zapisywanie nie powiodło się';

  @override
  String get reportSelectReason => 'Wybierz powód';

  @override
  String get gameCenter => 'Gry';

  @override
  String get gameHighScore => 'Najlepszy';

  @override
  String get gameScore => 'Wynik';

  @override
  String get gameOver => 'Koniec gry';

  @override
  String get gamePlayAgain => 'Zagraj ponownie';

  @override
  String get gameLeaderboard => 'Ranking';

  @override
  String get gamePause => 'Pauza';

  @override
  String get gameResume => 'Dotknij, aby wznowić';

  @override
  String get gameConfirmExit => 'Wyjść z gry?';

  @override
  String get gameNoScores => 'Brak wyników';

  @override
  String get game2048 => '2048';

  @override
  String get game2048Desc => 'Łącz kafelki, aby osiągnąć 2048';

  @override
  String get gameBlockDrop => 'Zablokuj spadek';

  @override
  String get gameBlockDropDesc => 'Upuszczaj i usuwaj linie';

  @override
  String get gameMinesweeper => 'Saper';

  @override
  String get gameMinesweeperDesc => 'Znajdź wszystkie bezpieczne pola';

  @override
  String get gameMatch3 => 'Mecz 3';

  @override
  String get gameMatch3Desc => 'Połącz 3 lub więcej klejnotów';

  @override
  String get gameMinesweeperEasy => 'Łatwy';

  @override
  String get gameMinesweeperMedium => 'Średni';

  @override
  String get gameMinesLeft => 'Pozostałe miny';

  @override
  String get gameTimeLeft => 'Czas';

  @override
  String get gameLevel => 'Poziom';

  @override
  String get gameNext => 'Następny';

  @override
  String get gameBestTime => 'Najlepszy czas';

  @override
  String get gameNewRecord => 'Nowy rekord!';

  @override
  String get gameLines => 'Linie';

  @override
  String get storyMyStory => 'Moja historia';

  @override
  String get storageSmartCleanup => 'Inteligentne sprzątanie';

  @override
  String get storageOldMediaFiles => 'Stare pliki multimedialne';

  @override
  String get storageLargeFiles => 'Duże pliki';

  @override
  String get storageAppCache => 'Pamięć podręczna aplikacji';

  @override
  String get storageSettings => 'Ustawienia przechowywania';

  @override
  String get storageAutoCleanup => 'Automatyczne czyszczenie';

  @override
  String storageAutoCleanupDesc(int days) {
    return 'Automatycznie czyść pliki starsze niż $days dni';
  }

  @override
  String get storageCleanupPeriod => 'Okres sprzątania';

  @override
  String get storagePreserveThumbnails => 'Zachowaj miniatury';

  @override
  String get storagePreserveThumbnailsDesc =>
      'Zachowaj miniatury obrazów podczas czyszczenia';

  @override
  String get storageWarningHigh =>
      'Użycie miejsca na dysku jest wysokie. Rozważ wyczyszczenie starych plików.';

  @override
  String get storageWarningCritical =>
      'Ilość miejsca na dysku jest krytycznie mała. Proszę oczyścić, aby uzyskać wolne miejsce.';

  @override
  String storageFreed(String size, int count) {
    return 'Uwolniono $size (pliki $count)';
  }

  @override
  String storageDays(int days) {
    return '$days dni';
  }

  @override
  String storageViewAllRooms(int count) {
    return 'Zobacz wszystkie pokoje $count';
  }

  @override
  String get storageNoFiles => 'Nie znaleziono plików';

  @override
  String get storageFilePinned => 'Przypięty';

  @override
  String storageDeleteSelected(int count) {
    return 'Usunąć wybrane pliki $count? Można je ponownie pobrać z serwera.';
  }

  @override
  String get backupRestore => 'Kopia zapasowa i przywracanie';

  @override
  String get backupCreate => 'Utwórz kopię zapasową';

  @override
  String get backupCreateDesc =>
      'Wykonaj kopię zapasową ustawień i kluczy szyfrowania. Wiadomości zostaną przywrócone z serwera po ponownym zalogowaniu.';

  @override
  String get backupIncludeKeys => 'Dołącz klucze szyfrujące';

  @override
  String get backupIncludeKeysDesc =>
      'Wymagane do odczytywania zaszyfrowanych wiadomości';

  @override
  String get backupPasswordProtect => 'Ochrona hasłem';

  @override
  String get backupEnterPassword => 'Wprowadź hasło zapasowe';

  @override
  String get backupHistory => 'Historia kopii zapasowych';

  @override
  String get backupNoBackups => 'Nie ma jeszcze kopii zapasowych';

  @override
  String get backupRestore2 => 'Przywróć';

  @override
  String get backupDelete => 'Usuń';

  @override
  String get backupDeleteConfirm =>
      'Czy na pewno chcesz usunąć tę kopię zapasową? Tego nie można cofnąć.';

  @override
  String get backupRestoreFromFile => 'Przywróć z pliku';

  @override
  String get backupRestoreFromFileDesc =>
      'Zaimportuj plik .n42backup z innego urządzenia lub poprzedniej kopii zapasowej.';

  @override
  String get backupChooseFile => 'Wybierz plik kopii zapasowej';

  @override
  String get backupRestoring => 'Przywracam...';

  @override
  String backupCreated(int rooms, int messages) {
    return 'Utworzono kopię zapasową: pokoje $rooms, wiadomości $messages';
  }

  @override
  String backupRestored(int settings, int rooms) {
    return 'Przywrócono ustawienia $settings z pokoi $rooms';
  }

  @override
  String backupFailed(String error) {
    return 'Tworzenie kopii zapasowej nie powiodło się: $error';
  }

  @override
  String get backupPasswordRequired =>
      'Ta kopia zapasowa jest chroniona hasłem';

  @override
  String get blocGroupNotFound => 'Nie znaleziono grupy';

  @override
  String blocGroupMembersInvited(int count) {
    return 'Zaproszeni członkowie $count';
  }

  @override
  String get blocGroupMemberRemoved => 'Członek usunięty';

  @override
  String get blocGroupAdminRemoved => 'Administrator usunięty';

  @override
  String get blocGroupLeft => 'Opuścił grupę';

  @override
  String get blocGroupDisbanded => 'Grupa rozwiązana';

  @override
  String get blocGroupJoined => 'Dołączyłem do grupy';

  @override
  String get blocGroupInviteDeclined => 'Zaproszenie odrzucone';

  @override
  String get blocGroupTokenGateUpdated => 'Brama tokenów zaktualizowana';

  @override
  String get blocTransferProcessing => 'Przetwarzam przelew...';

  @override
  String get blocTransferCancelled => 'Transfer anulowany';

  @override
  String get blocTransferFailed => 'Transfer nie powiódł się';

  @override
  String get blocPaymentProcessing => 'Przetwarzanie płatności...';

  @override
  String get blocPaymentFailed => 'Płatność nie powiodła się';

  @override
  String get groupMaxMembers => 'Limit członków';

  @override
  String get groupMaxMembersUnlimited => 'Nieograniczony';

  @override
  String get groupMaxMembersHint =>
      'Wprowadź limit (pozostaw puste dla nieograniczonego)';

  @override
  String get groupMaxMembersUpdated => 'Zaktualizowano limit członków';

  @override
  String get groupFull => 'Grupa ma pełną pojemność';

  @override
  String get groupChannels => 'Kanały tematyczne';

  @override
  String get groupChannelsEmpty => 'Nie ma jeszcze kanałów';

  @override
  String get groupChannelsCount => 'kanały';

  @override
  String get groupChannelCreate => 'Nowy kanał';

  @override
  String get groupChannelName => 'Nazwa kanału';

  @override
  String get groupChannelTopic => 'Temat kanału (opcjonalnie)';

  @override
  String get groupChannelDelete => 'Usuń kanał';

  @override
  String get groupChannelDeleteConfirm =>
      'Usunąć ten kanał? Wszystkie wiadomości zostaną utracone.';

  @override
  String get groupBotSettings => 'Ustawienia bota';

  @override
  String get groupBotEnabled => 'Włącz bota';

  @override
  String get groupBotWelcomeMessage => 'Szablon wiadomości powitalnej';

  @override
  String get groupBotWelcomeHint =>
      'Użyj „imienia” jako symbolu zastępczego nazwy nowego członka';

  @override
  String get groupBotConfigUpdated => 'Ustawienia bota zostały zaktualizowane';

  @override
  String get groupContentFilter => 'Filtr treści';

  @override
  String get groupContentFilterEnabled => 'Włącz filtr słów kluczowych';

  @override
  String get groupContentFilterReplace => 'Zamień na ***';

  @override
  String get groupContentFilterHide => 'Ukryj wiadomość';

  @override
  String get groupContentFilterAddWord => 'Dodaj słowo kluczowe';

  @override
  String get groupContentFilterUpdated => 'Zaktualizowano filtr treści';

  @override
  String get chatSlashCommands => 'Polecenia';

  @override
  String get chatCommandPoll => '/poll — Utwórz ankietę';

  @override
  String get chatCommandAnnounce => '/announce — Wyślij ogłoszenie';

  @override
  String get chatCommandWelcome => '/welcome — Ustaw wiadomość powitalną';

  @override
  String get chatReportMessage => 'Raport';

  @override
  String get chatReportReason => 'Zgłoś powód';

  @override
  String get chatReportSpam => 'Spam';

  @override
  String get chatReportHarassment => 'Nękanie';

  @override
  String get chatReportInappropriate => 'Niewłaściwa treść';

  @override
  String get chatReportOther => 'Inne';

  @override
  String get chatReportSuccess => 'Raport przesłany';

  @override
  String get spacesName => 'Nazwa społeczności';

  @override
  String get spacesNameHint => 'np. Traderzy kryptowalut';

  @override
  String get spacesNameRequired => 'Imię i nazwisko jest wymagane';

  @override
  String get spacesDescription => 'Opis';

  @override
  String get spacesDescriptionHint => 'O co chodzi w tej społeczności?';

  @override
  String get spacesType => 'Typ społeczności';

  @override
  String get spacesPublicDesc => 'Każdy może odkryć i dołączyć';

  @override
  String get spacesPrivateDesc => 'Tylko zaproszeni członkowie mogą dołączyć';

  @override
  String get spacesNotFound => 'Nie znaleziono społeczności';

  @override
  String get spacesSearch => 'Przeszukaj społeczności...';

  @override
  String get spacesMembers => 'Członkowie';

  @override
  String get spacesNoChannels => 'Nie ma jeszcze kanałów';

  @override
  String get spacesLeave => 'Opuść społeczność';

  @override
  String spacesLeaveConfirm(String name) {
    return 'Czy na pewno chcesz opuścić „$name”?';
  }

  @override
  String get spacesDelete => 'Usuń społeczność';

  @override
  String spacesDeleteConfirm(String name) {
    return 'Spowoduje to trwałe usunięcie „$name” i wszystkich jego kanałów. Tej akcji nie można cofnąć.';
  }

  @override
  String get spacesCreateChannel => 'Dodaj kanał';

  @override
  String get spacesChannelName => 'Nazwa kanału';

  @override
  String get spacesChannelTopic => 'Temat (opcjonalnie)';

  @override
  String get spacesDeleteChannel => 'Usuń kanał';

  @override
  String spacesDeleteChannelConfirm(String name) {
    return 'Czy na pewno chcesz usunąć „#$name”?';
  }

  @override
  String get spacesEditName => 'Edytuj nazwę';

  @override
  String get spacesEditDescription => 'Edytuj opis';

  @override
  String spacesViewAllMembers(int count) {
    return 'Wyświetl wszystkich członków $count';
  }

  @override
  String spacesKickMemberTitle(String name) {
    return 'Kopnij $name';
  }

  @override
  String spacesBanMemberTitle(String name) {
    return 'Zablokuj $name';
  }

  @override
  String get spacesPromoteAdmin => 'Awansuj na administratora';

  @override
  String get spacesDemoteAdmin => 'Usuń administratora';

  @override
  String get spacesInviteMember => 'Zaproś członka';

  @override
  String get spacesInviteMemberUserId =>
      'Identyfikator użytkownika (np. @user:server.com)';

  @override
  String get spacesSave => 'Zapisz';

  @override
  String get settingsScreenshotProtection => 'Ochrona zrzutów ekranu';

  @override
  String get settingsScreenshotProtectionDesc =>
      'Zapobiegaj robieniu zrzutów ekranu i nagrywaniu ekranu';

  @override
  String get chatSelfDestructTimer => 'Samozniszczenie';

  @override
  String get chatTimerPickerTitle => 'Zegar samozniszczenia';

  @override
  String get chatTimerOff => 'Wyłączone';

  @override
  String get onChainNotificationsTitle => 'Zdarzenia on-chain';

  @override
  String get onChainMarkAllRead => 'Oznacz wszystkie jako przeczytane';

  @override
  String get onChainNoNotifications => 'Brak zdarzeń on-chain';

  @override
  String get onChainNoNotificationsDesc =>
      'Zdarzenia z subskrybowanych kanałów pojawią się tutaj';

  @override
  String get onChainViewDetails => 'Wyświetl szczegóły';

  @override
  String get chatCommandHelp => '/help — Pokaż wszystkie polecenia';

  @override
  String get chatCommandPrice => '/price — Pobierz cenę tokena';

  @override
  String get chatCommandBalance => '/balance — Pokaż saldo portfela';

  @override
  String get chatCommandChains => '/chains — Lista 236+ wspieranych sieci';

  @override
  String get chatMiniApps => 'Aplikacje';

  @override
  String get miniAppMarketTitle => 'Mini Aplikacje';

  @override
  String get miniAppCategoryAll => 'Wszystkie';

  @override
  String get miniAppSearch => 'Szukaj aplikacji...';

  @override
  String get miniAppFeatured => 'Polecane';

  @override
  String get miniAppAllApps => 'Wszystkie Aplikacje';

  @override
  String get miniAppNoResults => 'Nie znaleziono aplikacji';

  @override
  String get slideToPayLabel => '→→→  Przesuń, aby potwierdzić';

  @override
  String get slideToPayConfirming => 'Potwierdzanie...';

  @override
  String get redPacketBestLuck => 'Najlepsze szczęście';

  @override
  String get redPacketBestLuckCongrats =>
      'Najlepsze szczęście! Dostałeś najwięcej!';

  @override
  String redPacketStats(int claimed, int total) {
    return '$claimed / $total odebrano';
  }

  @override
  String get redPacketStatsTotal => 'łącznie';

  @override
  String redPacketGrabbedViral(String amount, String token) {
    return '🧧 Otrzymał czerwoną kopertę • $amount $token';
  }

  @override
  String get web3SearchHint => '@matrix:id  •  adres 0x  •  name.eth';

  @override
  String get web3SearchPlaceholder => 'Szukaj według ID, portfela lub ENS...';

  @override
  String get web3WalletAddress => 'Adres portfela';

  @override
  String get web3AddressCopied => 'Adres skopiowany';

  @override
  String get web3Copy => 'Kopiuj';

  @override
  String get web3SendMessage => 'Wyślij wiadomość';

  @override
  String get web3SendToWallet => 'Wiadomość do portfela';

  @override
  String get web3WalletOnlyHint =>
      'Ten adres nie ma jeszcze konta N42. Wiadomość zostanie dostarczona po rejestracji.';

  @override
  String get web3NftAvatar => 'Awatar NFT';

  @override
  String get web3ResolveFailed => 'Nie udało się rozwiązać tożsamości';

  @override
  String web3EnsNotFound(String name) {
    return 'Nie znaleziono nazwy ENS \"$name\"';
  }

  @override
  String get web3NoN42AccountTitle => 'Brak konta N42';

  @override
  String get web3NoN42AccountDesc =>
      'Ten adres portfela nie ma jeszcze konta N42. Na początek możesz udostępnić im link z zaproszeniem N42.';

  @override
  String get web3ShareInvite => 'Udostępnij zaproszenie';

  @override
  String get nftPickerTitle => 'Wybierz awatar NFT';

  @override
  String get nftPickerTabPopular => 'Popularne';

  @override
  String get nftPickerTabCustom => 'Niestandardowy';

  @override
  String get nftPickerChain => 'Łańcuch';

  @override
  String get nftPickerContract => 'Adres umowy';

  @override
  String get nftPickerTokenId => 'Identyfikator tokena';

  @override
  String get nftPickerVerifyOwnership => 'Zweryfikuj własność i podgląd';

  @override
  String get nftPickerUseAsAvatar => 'Użyj jako awatar';

  @override
  String get nftPickerPreview => 'Podgląd';

  @override
  String get nftPickerNotOwned => 'Nie posiadasz tego NFT';

  @override
  String get nftPickerInvalidTokenId => 'Nieprawidłowy identyfikator tokena';

  @override
  String get nftPickerEnterBoth =>
      'Wprowadź adres umowy i identyfikator tokena';

  @override
  String get nftPickerInfoTitle => 'Awatar NFT — zweryfikowany on-chain';

  @override
  String get nftPickerInfoDesc =>
      'Połącz NFT, którego posiadasz, jako swój awatar. Każdy może zweryfikować własność w łańcuchu. Wyświetlany ze złotym pierścieniem na N42.';

  @override
  String get nftPickerPopularCollections => 'Popularne kolekcje';

  @override
  String get nftPickerWalletHint =>
      'Połącz portfel N42, aby automatycznie odkrywać swoje NFT na ponad 236 sieciach.';

  @override
  String get profileBindNftAvatar => 'Powiąż awatar NFT';

  @override
  String get profileChangeAvatar => 'Zmień awatara';

  @override
  String get groupTopics => 'Tematy';

  @override
  String get groupTopicsEmpty => 'Nie ma jeszcze tematów';

  @override
  String get syncInProgress => 'Synchronizowanie historii wiadomości...';

  @override
  String get recoveryKeyReminderTitle => 'Chroń swoje wiadomości';

  @override
  String get recoveryKeyReminderDesc =>
      'Utwórz klucz odzyskiwania, aby bezpiecznie synchronizować zaszyfrowane wiadomości między urządzeniami';

  @override
  String get recoveryKeySetupNow => 'Skonfiguruj teraz';

  @override
  String get recoveryKeyRemindLater => 'Przypomnij mi później';

  @override
  String get channelReadOnly =>
      'Tylko administratorzy mogą publikować posty na tym kanale';

  @override
  String get channelSubscribers => 'abonentów';

  @override
  String get channelVerified => 'Zweryfikowany kanał';

  @override
  String get redPacketHistory => 'Historia czerwonej paczki';

  @override
  String get redPacketSent => 'Wysłane';

  @override
  String get redPacketReceived => 'Otrzymano';

  @override
  String get redPacketExpired => 'Wygasło';

  @override
  String get redPacketClaimed => 'Zgłoszono';

  @override
  String get redPacketInsufficientBalance => 'Niewystarczająca równowaga';

  @override
  String selfDestructCountdown(String time) {
    return 'Samozniszczenie w $time';
  }

  @override
  String get messageDestroyed => 'Wiadomość zniszczona';

  @override
  String miniAppPermissionDenied(String permission) {
    return 'Odmowa pozwolenia: $permission';
  }

  @override
  String get aiSuggestionGasFee => 'Co to jest opłata za gaz?';

  @override
  String get aiSuggestionDefi => 'Przewodnik dla początkujących DeFi';

  @override
  String get aiSuggestionSecurity => 'Jak sprawdzić bezpieczeństwo umowy';

  @override
  String get aiSuggestionBridge => 'Mostkowanie międzyłańcuchowe';

  @override
  String get channelDiscoverTitle => 'Odkryj kanały';

  @override
  String get channelDiscoverSearch => 'Wyszukaj kanały...';

  @override
  String get channelJoin => 'Dołącz';

  @override
  String get channelJoined => 'Dołączył';

  @override
  String get channelCategory => 'Kategoria';

  @override
  String slowModeCooldown(int seconds) {
    return 'Tryb wolny: poczekaj ${seconds}s';
  }

  @override
  String get addressCopyAction => 'Skopiuj adres';

  @override
  String get addressSendMessage => 'Wyślij wiadomość';

  @override
  String get addressViewProfile => 'Zobacz profil';

  @override
  String get sendToAddress => 'Wyślij na adres portfela';

  @override
  String get blocAuthSendVerificationCodeFailed =>
      'Nie udało się wysłać kodu weryfikacyjnego';

  @override
  String get blocAuthServerNoEmailPasswordReset =>
      'Ten serwer nie obsługuje resetowania hasła e-mail';

  @override
  String get blocAuthResetPasswordFailed => 'Nie udało się zresetować hasła';

  @override
  String get blocAuthChangePasswordFailed => 'Nie udało się zmienić hasła';

  @override
  String get blocAuthOldPasswordWrong => 'Nieprawidłowe aktualne hasło';

  @override
  String get blocAuthLoginCancelled => 'Logowanie anulowane';

  @override
  String get blocAuthGoogleLoginFailed =>
      'Logowanie do Google nie powiodło się';

  @override
  String get blocAuthAppleLoginFailed => 'Logowanie Apple nie powiodło się';

  @override
  String get blocAuthSsoLoginFailed => 'Logowanie jednokrotne nie powiodło się';

  @override
  String get blocAuthFacebookLoginFailed =>
      'Logowanie do Facebooka nie powiodło się';

  @override
  String get blocAuthTwitterLoginFailed =>
      'Logowanie do Twittera nie powiodło się';

  @override
  String get blocAuthWeChatLoginFailed =>
      'Logowanie do WeChat nie powiodło się';

  @override
  String get blocAuthWeChatNotConfigured =>
      'Logowanie do WeChat nie zostało skonfigurowane';

  @override
  String get blocAuthWeChatNotInstalled => 'Najpierw zainstaluj WeChat';

  @override
  String get blocAuthPasswordWrong => 'Nieprawidłowe hasło';

  @override
  String get blocAuthEmailAlreadyBound =>
      'Ten adres e-mail jest już powiązany z innym kontem';

  @override
  String get blocAuthChangeEmailFailed => 'Nie udało się zmienić adresu e-mail';

  @override
  String get blocAuthVerificationCodeInvalid =>
      'Kod weryfikacyjny jest nieprawidłowy lub wygasł';

  @override
  String get blocAuthSessionExpired => 'Sesja wygasła. Zaloguj się ponownie';

  @override
  String get blocAuthSessionIncomplete =>
      'Dane sesji są niekompletne. Proszę zalogować się ponownie';
}
