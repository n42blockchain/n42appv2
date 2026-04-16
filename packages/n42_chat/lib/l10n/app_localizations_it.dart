// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class SIt extends S {
  SIt([String locale = 'it']) : super(locale);

  @override
  String get commonRetry => 'Riprova';

  @override
  String get commonUnknownUser => 'Utente sconosciuto';

  @override
  String get transferWalletNotConnected => 'Wallet non connesso';

  @override
  String get chatCallServiceNotInitialized =>
      'Servizio chiamate non inizializzato';

  @override
  String authLoginFailed(String error) {
    return 'Login fallito: $error';
  }

  @override
  String get chatCallBack => 'Richiama';

  @override
  String get chatMissedVideoCall => 'Videochiamata persa';

  @override
  String get chatMissedVoiceCall => 'Chiamata vocale persa';

  @override
  String get chatCallNotAnswered => 'Senza risposta';

  @override
  String get chatCallDurationLabel => 'Durata della chiamata';

  @override
  String get chatVoiceCallCancelled => 'Chiamata vocale annullata';

  @override
  String get chatVideoCallCancelled => 'Videochiamata annullata';

  @override
  String get commonImage => '[Immagine]';

  @override
  String get chatVideo => '[Video]';

  @override
  String get chatVoice => '[Vocale]';

  @override
  String get commonFile => '[File]';

  @override
  String get chatLocation => '[Posizione]';

  @override
  String get chatUnknownMessage => '[Messaggio sconosciuto]';

  @override
  String get commonDelete => 'Elimina';

  @override
  String get chatDeleteThisMessage => 'Eliminare questo messaggio?';

  @override
  String get chatMessageDeleted => 'Messaggio eliminato';

  @override
  String get profileNotLoggedIn => 'Non connesso';

  @override
  String get chatMyLocation => 'La mia posizione';

  @override
  String get commonGroupChat => 'Chat di gruppo';

  @override
  String get commonSearch => 'Cerca';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonLoadFailed => 'Caricamento fallito';

  @override
  String get commonMessages => 'Messaggi';

  @override
  String get commonContacts => 'Contatti';

  @override
  String get commonMe => 'Io';

  @override
  String get commonVoiceLoading => 'Caricamento vocale, riprova più tardi';

  @override
  String get commonVoiceToTextFailed => 'Conversione vocale fallita';

  @override
  String get commonConvertToText => 'In testo';

  @override
  String get chatCopy => 'Copia';

  @override
  String get commonForward => 'Inoltra';

  @override
  String get commonUnfavorite => 'Rimuovi preferito';

  @override
  String get commonFavorite => 'Preferito';

  @override
  String get settingsResend => 'Rinvia';

  @override
  String get chatRecall => 'Ritira';

  @override
  String get commonQuote => 'Cita';

  @override
  String get commonRemind => 'Menziona';

  @override
  String get chatCopied => 'Copiato';

  @override
  String get storySendMessageHint => 'Scrivi un messaggio';

  @override
  String get commonMicrophonePermissionRequired =>
      'Consenti l\'accesso al microfono';

  @override
  String get chatMicrophonePermissionDeniedPermanent =>
      'L\'autorizzazione al microfono è stata negata. Abilitalo nelle impostazioni di sistema per utilizzare i messaggi vocali.';

  @override
  String commonStartRecordingFailed(String error) {
    return 'Impossibile avviare la registrazione: $error';
  }

  @override
  String get commonRecordingTooShort => 'Registrazione troppo breve';

  @override
  String commonStopRecordingFailed(String error) {
    return 'Impossibile interrompere la registrazione: $error';
  }

  @override
  String get chatReleaseToCancel => 'Rilascia per annullare';

  @override
  String get chatReleaseToSend =>
      'Rilascia per inviare, scorri in alto per annullare';

  @override
  String get commonHoldToTalk => 'Tieni premuto per parlare';

  @override
  String get commonSend => 'Invia';

  @override
  String get commonAddFriend => 'Aggiungi amico';

  @override
  String get commonChatServiceNotConnected => 'Servizio chat non connesso';

  @override
  String contactUserNotFoundHint(String query) {
    return 'Utente \"$query\" non trovato\n\nSuggerimenti:\n• Prova a inserire l\'ID utente completo, es. @nomeutente:server.com\n• Controlla l\'ortografia del nome utente';
  }

  @override
  String contactCreateChatFailed(String error) {
    return 'Impossibile creare la chat: $error';
  }

  @override
  String contactSearchFailed(String error) {
    return 'Ricerca fallita: $error';
  }

  @override
  String get contactEnterUserIdOrUsername =>
      'Inserisci ID utente o nome utente per cercare';

  @override
  String get contactSearching => 'Ricerca in corso...';

  @override
  String get contactSearchUserToChat => 'Cerca utente per iniziare a chattare';

  @override
  String get contactMatrixIdExample =>
      'Puoi inserire un ID Matrix completo\nes. @utente:matrix.n42.network';

  @override
  String contactUserNotFound(String username) {
    return 'Utente \"$username\" non trovato';
  }

  @override
  String get commonChat => 'Chatta';

  @override
  String get commonSettings => 'Impostazioni';

  @override
  String get profileEditProfile => 'Modifica profilo';

  @override
  String get authLogin => 'Accedi';

  @override
  String get commonCreateGroup => 'Crea gruppo';

  @override
  String get chatError => 'Errore';

  @override
  String get commonTransfer => 'Trasferimento';

  @override
  String get commonReceived => 'Ricevuto';

  @override
  String get commonRefunded => 'Rimborsato';

  @override
  String get commonExpired => 'Scaduto';

  @override
  String get chatRedPacketGreeting => 'Auguri';

  @override
  String get commonN42RedPacket => 'Busta rossa N42';

  @override
  String get commonClaimed => 'Riscosso';

  @override
  String get commonAllClaimed => 'Tutto riscosso';

  @override
  String get chatReadAloud => 'Leggi ad alta voce';

  @override
  String get chatReply => 'Rispondi';

  @override
  String get commonEdit => 'Modifica';

  @override
  String get chatSelectForwardTarget => 'Seleziona destinatario';

  @override
  String commonSendCount(int count) {
    return 'Invia ($count)';
  }

  @override
  String contactN42Id(String id) {
    return 'ID N42: $id';
  }

  @override
  String get profileN42IdTitle => 'ID N42';

  @override
  String get profileN42Bean => 'Fagiolo N42';

  @override
  String get contactFriendInfo => 'Info amico';

  @override
  String get contactFriendInfoDesc =>
      'Aggiungi note, telefono, tag, appunti, foto e imposta permessi.';

  @override
  String get commonMoments => 'Momenti';

  @override
  String get commonSendMessage => 'Messaggio';

  @override
  String get contactAudioVideoCall => 'Chiamata audio/video';

  @override
  String get contactVideoChannel => 'Canale video';

  @override
  String get contactRemark => 'Nota';

  @override
  String get contactRemarkName => 'Nome nota';

  @override
  String get contactPhone => 'Telefono';

  @override
  String get contactTags => 'Tag';

  @override
  String get contactNotes => 'Note';

  @override
  String get contactPhotos => 'Foto';

  @override
  String get contactPermissions => 'Permessi';

  @override
  String get contactChatMomentsEtc => 'Chat, Momenti, Sport, ecc.';

  @override
  String get contactMoreInfo => 'Altre info';

  @override
  String get contactCommonGroups => 'Gruppi in comune';

  @override
  String get contactSource => 'Origine';

  @override
  String get settingsNotificationSettings => 'Notifiche';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsAppearance => 'Aspetto';

  @override
  String get settingsAbout => 'Informazioni';

  @override
  String get commonLogout => 'Esci';

  @override
  String get commonLogoutConfirm => 'Sei sicuro di voler uscire?';

  @override
  String get commonSave => 'Salva';

  @override
  String get profileNickname => 'Soprannome';

  @override
  String get profileEnterNickname => 'Inserisci nickname';

  @override
  String get profileSignature => 'Firma';

  @override
  String get profileAddSignature => 'Aggiungi una firma';

  @override
  String get commonTakePhoto => 'Scatta foto';

  @override
  String get profileChooseFromGallery => 'Scegli dalla galleria';

  @override
  String profileSaveFailed(String error) {
    return 'Salvataggio fallito: $error';
  }

  @override
  String get authSecureDecentralizedChat =>
      'Messaggistica sicura e decentralizzata';

  @override
  String get commonEndToEndEncryption => 'Crittografia end-to-end';

  @override
  String get authMessagesOnlyYouCanSee =>
      'Messaggi visibili solo a te e al destinatario';

  @override
  String get authDecentralized => 'Decentralizzato';

  @override
  String get authBasedOnMatrix => 'Basato sul protocollo aperto Matrix';

  @override
  String get authWalletIntegration => 'Integrazione wallet';

  @override
  String get authEasyCryptoTransfer => 'Trasferimenti crypto facili';

  @override
  String get authRegister => 'Registrati';

  @override
  String get authAgreeTerms => 'Accedendo, accetti';

  @override
  String get authTermsOfService => 'Termini di servizio';

  @override
  String get authAnd => 'e';

  @override
  String get authPrivacyPolicy => 'Informativa sulla privacy';

  @override
  String get authServerAddress => 'Indirizzo server';

  @override
  String get authEnterServerAddress => 'Inserisci indirizzo server';

  @override
  String authConnectedTo(String serverName) {
    return 'Connesso a $serverName';
  }

  @override
  String get authUsername => 'Nome utente';

  @override
  String get authEnterUsername => 'Inserisci nome utente';

  @override
  String get authUsernameOrEmail => 'Nome utente o Email';

  @override
  String get authEnterUsernameOrEmail => 'Inserisci nome utente o email';

  @override
  String get authPassword => 'Parola d\'ordine';

  @override
  String get authEnterPassword => 'Inserisci password';

  @override
  String get authRegisterAccount => 'Registrati';

  @override
  String get authForgotPassword => 'Password dimenticata';

  @override
  String get authOtherLoginMethods => 'Altri metodi di accesso';

  @override
  String get authCreateAccount => 'Crea account';

  @override
  String get authJoinN42Chat => 'Unisciti a N42 Chat per iniziare a chattare';

  @override
  String get authUsernameHint => '3-20 caratteri, lettere/numeri/_';

  @override
  String get authUsernameMinLength =>
      'Il nome utente deve avere almeno 3 caratteri';

  @override
  String get authUsernameMaxLength =>
      'Il nome utente deve avere massimo 20 caratteri';

  @override
  String get authUsernameFormat =>
      'Il nome utente può contenere solo lettere, numeri e underscore';

  @override
  String get authPasswordHint => 'Minimo 8 caratteri';

  @override
  String get commonPasswordMinLength =>
      'La password deve avere almeno 8 caratteri';

  @override
  String get authConfirmPassword => 'Conferma password';

  @override
  String get authFilled => 'Compilato';

  @override
  String get authEnterInviteCode => 'Inserisci codice invito';

  @override
  String get authAlreadyHaveAccount => 'Hai già un account?';

  @override
  String get authLoginNow => 'Accedi ora';

  @override
  String get profileAvatar => 'Avatar';

  @override
  String get profileStatus => 'Stato';

  @override
  String get commonLoading => 'Caricamento...';

  @override
  String get conversationNoConversations => 'Nessuna conversazione';

  @override
  String get conversationTapToChat =>
      'Tocca in alto a destra per iniziare a chattare';

  @override
  String get conversationStartGroup => 'Inizia chat di gruppo';

  @override
  String get commonScan => 'Scansiona';

  @override
  String get commonPayment => 'Pagamento';

  @override
  String commonFeatureComingSoon(String feature) {
    return '$feature prossimamente';
  }

  @override
  String get conversationMarkAsRead => 'Segna come letto';

  @override
  String get commonUnmute => 'Riattiva';

  @override
  String get commonMute => 'Silenzia';

  @override
  String get conversationUnpin => 'Rimuovi fissato';

  @override
  String get conversationPin => 'Fissa';

  @override
  String get conversationDeleteConversation => 'Elimina conversazione';

  @override
  String conversationDeleteConversationConfirm(String name) {
    return 'Eliminare la conversazione con \"$name\"?';
  }

  @override
  String get commonNoContacts => 'Nessun contatto';

  @override
  String get contactAddFriendsToChat =>
      'Aggiungi amici per iniziare a chattare';

  @override
  String get contactNotFound => 'Contatto non trovato';

  @override
  String get contactTryOtherKeywords =>
      'Prova altre parole chiave o cerca globalmente';

  @override
  String get contactSearchResults => 'Risultati ricerca';

  @override
  String get contactNewFriends => 'Nuovi amici';

  @override
  String get contactChatOnlyFriends => 'Amici solo chat';

  @override
  String get contactOfficialAccounts => 'Account ufficiali';

  @override
  String get contactServiceAccounts => 'Account di servizio';

  @override
  String get contactEnterpriseContacts => 'Contatti aziendali';

  @override
  String get contactRecommendToFriend => 'Condividi contatto';

  @override
  String get commonSetRemark => 'Imposta nota';

  @override
  String get contactSendingCard => 'Invio scheda contatto...';

  @override
  String get commonFileLabel => 'Archivio';

  @override
  String get commonLocationLabel => 'Posizione';

  @override
  String contactRecommendFailed(String error) {
    return 'Raccomandazione fallita: $error';
  }

  @override
  String get profileEnterRemark => 'Inserisci nota';

  @override
  String get contactOpeningChat => 'Apertura chat...';

  @override
  String contactOpenChatFailed(String error) {
    return 'Impossibile aprire la chat: $error';
  }

  @override
  String get contactAddContact => 'Aggiungi contatto';

  @override
  String get contactEnterUserId => 'Inserisci ID utente';

  @override
  String get contactNoFriendRequests => 'Nessuna richiesta di amicizia';

  @override
  String get commonAccept => 'Accetta';

  @override
  String get commonReject => 'Rifiuta';

  @override
  String get commonNoGroups => 'Nessun gruppo';

  @override
  String get contactSelectFriendToRecommend =>
      'Seleziona un amico a cui raccomandare';

  @override
  String get commonSearchContacts => 'Cerca contatti';

  @override
  String get contactNoContactsFound => 'Nessun contatto trovato';

  @override
  String get favoriteYesterday => 'Ieri';

  @override
  String get chatJustNow => 'Adesso';

  @override
  String get profileOnline => 'In linea';

  @override
  String get profileOffline => 'Non in linea';

  @override
  String get searchContactsGroupsMessages => 'Cerca contatti, gruppi, messaggi';

  @override
  String get searchError => 'Errore ricerca';

  @override
  String get chatSearchHint => 'Cerca contatti, gruppi e messaggi';

  @override
  String get searchHistory => 'Cronologia ricerche';

  @override
  String get commonClear => 'Cancella';

  @override
  String get commonAll => 'Tutto';

  @override
  String get searchGroups => 'Gruppi';

  @override
  String get searchNoResults => 'Nessun risultato';

  @override
  String commonGroupMembers(int count) {
    return 'Membri ($count)';
  }

  @override
  String get groupMembersTitle => 'Membri del gruppo';

  @override
  String get groupViewAll => 'Vedi tutti';

  @override
  String get groupOwner => 'Proprietario';

  @override
  String get groupAdmin => 'Ammin';

  @override
  String get groupInvite => 'Invita';

  @override
  String get commonGroupAnnouncement => 'Annuncio gruppo';

  @override
  String get commonNotSet => 'Non impostato';

  @override
  String get groupDescription => 'Descrizione gruppo';

  @override
  String get groupPublicGroup => 'Gruppo pubblico';

  @override
  String get commonClearChatHistory => 'Cancella cronologia chat';

  @override
  String get commonDissolveGroup => 'Sciogli gruppo';

  @override
  String get commonLeaveGroup => 'Lascia gruppo';

  @override
  String get groupChangeGroupName => 'Cambia nome gruppo';

  @override
  String get commonEnterGroupName => 'Inserisci nome gruppo';

  @override
  String get commonConfirm => 'Conferma';

  @override
  String get groupEnterGroupDescription => 'Inserisci descrizione gruppo';

  @override
  String get groupPublish => 'Pubblica';

  @override
  String get chatClearHistoryConfirm =>
      'Cancellare tutta la cronologia chat? Questa azione non può essere annullata.';

  @override
  String get chatClearAction => 'Cancella';

  @override
  String get commonChatHistoryCleared => 'Cronologia chat cancellata';

  @override
  String get commonDissolve => 'Sciogli';

  @override
  String get groupQrCode => 'QR Code gruppo';

  @override
  String get commonSearchChatHistory => 'Cerca nella cronologia chat';

  @override
  String get groupIdCopied => 'ID gruppo copiato';

  @override
  String get transferEnterOrPasteAddress =>
      'Inserisci o incolla indirizzo wallet';

  @override
  String get transferSelectToken => 'Seleziona token';

  @override
  String get commonTransferAmount => 'Importo trasferimento';

  @override
  String get transferAvailable => 'Disponibile';

  @override
  String get transferMemoOptional => 'Nota (opzionale)';

  @override
  String get transferConfirmTransfer => 'Conferma trasferimento';

  @override
  String get transferAddressVerified => 'Indirizzo verificato';

  @override
  String transferAvailableBalance(String balance, String symbol) {
    return 'Disponibile: $balance $symbol';
  }

  @override
  String get commonEnterAmount => 'Inserisci importo';

  @override
  String get commonRedPacketCountMin => 'Almeno 1 busta rossa richiesta';

  @override
  String get commonViewRedPacketDetails => 'Visualizza dettagli busta rossa';

  @override
  String get commonEnterTransferAmount => 'Inserisci importo trasferimento';

  @override
  String get commonTransferTo => 'Trasferisci a';

  @override
  String commonFromSender(String name, Object senderName) {
    return 'Da $senderName';
  }

  @override
  String get commonConfirmReceive => 'Conferma ricezione';

  @override
  String get groupProfile => 'Info gruppo';

  @override
  String get groupRemoveMember => 'Rimuovi dal gruppo';

  @override
  String get commonRemove => 'Rimuovi';

  @override
  String get profileClearStatus => 'Cancella stato';

  @override
  String get profileClearStatusConfirm => 'Cancellare lo stato attuale?';

  @override
  String get profileStatusCleared => 'Stato cancellato';

  @override
  String get profileUserNotExist => 'L\'utente non esiste';

  @override
  String get profileUserIdCopied => 'ID utente copiato';

  @override
  String get commonReport => 'Segnala';

  @override
  String get profileQrCode => 'Codice QR';

  @override
  String get profileAvatarUpdated => 'Avatar aggiornato';

  @override
  String commonSelectImageFailed(String error) {
    return 'Selezione immagine fallita: $error';
  }

  @override
  String get profileChangeName => 'Cambia nome';

  @override
  String get profileMale => 'Maschio';

  @override
  String get profileFemale => 'Femmina';

  @override
  String chatFeatureInDev(String feature) {
    return '$feature in sviluppo...';
  }

  @override
  String profileSaveAddressFailed(String error) {
    return 'Salvataggio indirizzo fallito: $error';
  }

  @override
  String get profileAddNew => 'Aggiungi';

  @override
  String get profileAddAddress => 'Aggiungi indirizzo';

  @override
  String get profileAddressAdded => 'Indirizzo aggiunto';

  @override
  String get profileAddressUpdated => 'Indirizzo aggiornato';

  @override
  String get profileDeleteAddress => 'Elimina indirizzo';

  @override
  String get profileAddressDeleted => 'Indirizzo eliminato';

  @override
  String profileSaveInvoiceFailed(String error) {
    return 'Salvataggio fattura fallito: $error';
  }

  @override
  String get profileMyInvoices => 'Le mie fatture';

  @override
  String get profileAddInvoice => 'Aggiungi fattura';

  @override
  String get profileInvoiceAdded => 'Fattura aggiunta';

  @override
  String get profileInvoiceUpdated => 'Fattura aggiornata';

  @override
  String get profileDeleteInvoice => 'Elimina fattura';

  @override
  String get profileInvoiceDeleted => 'Fattura eliminata';

  @override
  String get profilePersonal => 'Personale';

  @override
  String get groupSelectAtLeastOne => 'Seleziona almeno un membro';

  @override
  String get chatFileNotExist => 'Il file non esiste';

  @override
  String chatSendFailed(String error) {
    return 'Invio fallito: $error';
  }

  @override
  String get chatCannotOpenBrowser => 'Impossibile aprire il browser';

  @override
  String chatSelectFileFailed(String error) {
    return 'Selezione file fallita: $error';
  }

  @override
  String settingsSetupFailed(String error) {
    return 'Configurazione fallita: $error';
  }

  @override
  String get transferEnterValidAmount => 'Inserisci un importo valido';

  @override
  String get commonAddressCopied => 'Indirizzo copiato';

  @override
  String favoriteOpenItem(String content) {
    return 'Apri: $content';
  }

  @override
  String get favoriteDeleted => 'Eliminato';

  @override
  String get profileWallet => 'Portafoglio';

  @override
  String get chatRecording => 'Registrazione';

  @override
  String get chatInvalidVideoUrl => 'URL video non valido';

  @override
  String get chatDownloadFile => 'Scarica file';

  @override
  String get chatClearChatHistoryTitle => 'Cancella cronologia chat';

  @override
  String get chatVideoCall => 'Videochiamata';

  @override
  String get commonVoiceCall => 'Chiamata vocale';

  @override
  String get callLeaveMeeting => 'Lascia riunione';

  @override
  String get chatDetails => 'Dettagli chat';

  @override
  String get chatViewAllGroupMembers => 'Vedi tutti i membri';

  @override
  String get chatGroupName => 'Nome gruppo';

  @override
  String get chatGroupNameUpdated => 'Nome gruppo aggiornato';

  @override
  String get chatUpdateFailed => 'Aggiornamento fallito';

  @override
  String get chatNoPermissionToModify => 'Non hai i permessi per modificare';

  @override
  String get chatGroupManagement => 'Gestione gruppo';

  @override
  String get chatMyNicknameInGroup => 'Il mio nickname nel gruppo';

  @override
  String get chatPinChat => 'Fissa chat';

  @override
  String get chatStrongReminder => 'Promemoria importante';

  @override
  String get chatSetChatBackground => 'Imposta sfondo chat';

  @override
  String get chatUnknownFile => 'File sconosciuto';

  @override
  String get chatDownload => 'Scarica';

  @override
  String get chatInvalidLocation => 'Posizione non valida';

  @override
  String get chatTapToCancel => 'Tocca per annullare';

  @override
  String chatCaptureFailed(Object error) {
    return 'Cattura fallita: $error';
  }

  @override
  String get chatProcessingVideo => 'Elaborazione video...';

  @override
  String get chatVideoFileNotExist => 'Il file video non esiste';

  @override
  String get chatVideoDataEmpty => 'I dati video sono vuoti';

  @override
  String get chatVideoTooLarge => 'Il video non può superare 100MB';

  @override
  String get chatSendingVideo => 'Invio video...';

  @override
  String chatSendVideoFailed(Object error) {
    return 'Invio video fallito: $error';
  }

  @override
  String get chatImageFileNotExist => 'Il file immagine non esiste';

  @override
  String get commonImageDataEmpty => 'I dati immagine sono vuoti';

  @override
  String get chatSendingImage => 'Invio immagine...';

  @override
  String chatSendImageFailed(Object error) {
    return 'Invio immagine fallito: $error';
  }

  @override
  String get chatSendLocation => 'Invia posizione';

  @override
  String get chatSelectLocationAndSend => 'Seleziona posizione e invia';

  @override
  String get chatShareRealTimeLocation => 'Condividi posizione in tempo reale';

  @override
  String get chatShareLocationForOneHour =>
      'Condividi posizione in tempo reale con l\'amico per 1 ora';

  @override
  String get chatLocationSent => 'Posizione inviata';

  @override
  String get chatSelectMessages => 'Seleziona messaggi';

  @override
  String chatSelectedCount(int count) {
    return 'Selezionati $count';
  }

  @override
  String get chatSelectAll => 'Seleziona tutto';

  @override
  String chatGroupChatCount(int count) {
    return 'Chat di gruppo ($count)';
  }

  @override
  String get chatPrivateChat => 'Chat privata';

  @override
  String get chatNoMessages => 'Nessun messaggio';

  @override
  String get chatSendFirstMessage =>
      'Invia il primo messaggio per iniziare a chattare';

  @override
  String get chatEncryptionNotice =>
      'Questa chat è crittografata end-to-end. Solo tu e il destinatario potete leggere i messaggi.';

  @override
  String get chatMultiForward => 'Inoltra';

  @override
  String get chatCollect => 'Salva';

  @override
  String get chatNoMembers => 'Nessun membro';

  @override
  String get chatMemberNotFound => 'Membro non trovato';

  @override
  String get chatVoiceFileNotExist => 'Il file vocale non esiste';

  @override
  String get chatVoiceFileEmpty => 'Il file vocale è vuoto';

  @override
  String get chatSendingVoice => 'Invio vocale...';

  @override
  String chatSendVoiceFailed(Object error) {
    return 'Invio vocale fallito: $error';
  }

  @override
  String get chatMessageForwarded => 'Messaggio inoltrato';

  @override
  String chatForwardFailed(Object error) {
    return 'Inoltro fallito: $error';
  }

  @override
  String get chatUnfavorited => 'Rimosso dai preferiti';

  @override
  String get chatFavorited => 'Aggiunto ai preferiti';

  @override
  String get chatReactionAdded => 'Reazione aggiunta';

  @override
  String get chatReactionRemoved => 'Reazione rimossa';

  @override
  String get chatFailedMessageDeleted => 'Messaggio fallito eliminato';

  @override
  String get chatDeleteMessages => 'Elimina messaggi';

  @override
  String chatDeleteMessagesConfirm(Object count) {
    return 'Sei sicuro di voler eliminare $count messaggi?';
  }

  @override
  String chatNoteOtherMessages(Object count) {
    return 'Nota: $count messaggi sono di altri e saranno eliminati solo per te.';
  }

  @override
  String chatMyMessagesWillBeRecalled(Object count) {
    return '$count messaggi tuoi verranno ritirati per tutti.';
  }

  @override
  String chatRecalledCount(Object count, Object localCount) {
    return 'Ritirati $count messaggi, $localCount eliminati solo per te';
  }

  @override
  String chatRecalledMessages(Object count) {
    return 'Ritirati $count messaggi';
  }

  @override
  String chatDeletedLocally(Object count) {
    return '$count messaggi eliminati solo per te';
  }

  @override
  String chatForwardedCount(Object count) {
    return 'Inoltrati $count messaggi';
  }

  @override
  String chatForwardComplete(Object failed, Object success) {
    return 'Inoltro completato: $success riusciti, $failed falliti';
  }

  @override
  String get chatRemindOnlyInGroup =>
      'La funzione menziona è disponibile solo nelle chat di gruppo';

  @override
  String get chatOnlyTextSearchable =>
      'Solo i messaggi di testo possono essere cercati';

  @override
  String chatSearchFor(Object text) {
    return 'Cerca \"$text\"';
  }

  @override
  String get chatBaiduSearch => 'Cerca su Baidu';

  @override
  String get chatGoogleSearch => 'Cerca su Google';

  @override
  String get chatBingSearch => 'Cerca su Bing';

  @override
  String get chatCalling => 'Chiamata in corso...';

  @override
  String get chatRinging => 'Squillando...';

  @override
  String get chatInCall => 'In chiamata';

  @override
  String commonFeatureInDevelopment(String feature) {
    return 'Funzionalità in sviluppo...';
  }

  @override
  String chatCollectMessages(Object count) {
    return 'Salvati $count messaggi';
  }

  @override
  String commonMemberCount(int count) {
    return '$count membri';
  }

  @override
  String groupDone(int count) {
    return 'Fatto($count)';
  }

  @override
  String get profileServices => 'Servizi';

  @override
  String get commonFavorites => 'Preferiti';

  @override
  String get profileOrdersAndCards => 'Ordini e carte';

  @override
  String get profileStickers => 'Sticker';

  @override
  String profileStatusSetTo(String status) {
    return 'Stato impostato: $status';
  }

  @override
  String get profileAvatarUploadFailed => 'Caricamento avatar fallito';

  @override
  String get profilePersonalProfile => 'Profilo personale';

  @override
  String get profileName => 'Nome';

  @override
  String get profileGender => 'Genere';

  @override
  String get profileRegion => 'Regione';

  @override
  String get commonMyQrCode => 'Il mio QR Code';

  @override
  String get profilePoke => 'Tocco';

  @override
  String get profileRingtone => 'Suoneria';

  @override
  String get profileDefaultRingtone => 'Suoneria predefinita';

  @override
  String get profileMyAddresses => 'I miei indirizzi';

  @override
  String profileGenderSetTo(String gender) {
    return 'Genere impostato: $gender';
  }

  @override
  String get profileSelectRegion => 'Seleziona regione';

  @override
  String get profileSelectCity => 'Seleziona città';

  @override
  String profileRegionSetTo(String region) {
    return 'Regione impostata: $region';
  }

  @override
  String get profileSetPoke => 'Imposta tocco';

  @override
  String get profileFriendPokedMe => 'L\'amico mi ha toccato';

  @override
  String get profileExample => 'Esempio';

  @override
  String get profileOnTheShoulder => ' sulla spalla';

  @override
  String get profilePokeCleared => 'Tocco cancellato';

  @override
  String profilePokeSetTo(String suffix) {
    return 'Tocco impostato: mi ha toccato$suffix';
  }

  @override
  String get profileEditSignature => 'Modifica firma';

  @override
  String get profileIntroduceYourself => 'Una frase per presentarti';

  @override
  String get profileSignatureCleared => 'Firma cancellata';

  @override
  String get profileSignatureUpdated => 'Firma aggiornata';

  @override
  String get profileScanToAddFriend =>
      'Scansiona il QR code qui sopra per aggiungermi come amico';

  @override
  String profileRingtoneSetTo(String ringtone) {
    return 'Suoneria impostata: $ringtone';
  }

  @override
  String commonConfirmDissolveGroup(String name) {
    return 'Sei sicuro di voler sciogliere \"$name\"? Questa azione non può essere annullata.';
  }

  @override
  String get authEnterValidServerAddress =>
      'Inserisci un indirizzo server valido';

  @override
  String get authEnterServerAddressFirst =>
      'Inserisci prima l\'indirizzo del server';

  @override
  String get authPasskeyRequiresServer =>
      'L\'accesso con passkey richiede supporto del server';

  @override
  String get authLoginAgreement => 'Accedendo, accetti ';

  @override
  String get authPleaseAgreeToTerms =>
      'Leggi e accetta i Termini di servizio e l\'Informativa sulla privacy';

  @override
  String get authRegisterFailed => 'Registrazione fallita';

  @override
  String get commonReenterPassword => 'Reinserisci password';

  @override
  String get commonPasswordsDoNotMatch => 'Le password non coincidono';

  @override
  String get authInviteCodeBuiltIn => 'Codice invito (integrato)';

  @override
  String get authInviteCodeBuiltInNote =>
      'Il codice invito è integrato, solitamente non serve modificarlo';

  @override
  String get authIHaveReadAndAgree => 'Ho letto e accetto ';

  @override
  String get mainStartGroupChat => 'Inizia chat di gruppo';

  @override
  String get mainAddFriends => 'Aggiungi amici';

  @override
  String get mainPaymentAndCollection => 'Pagamento';

  @override
  String contactCount(int count) {
    return '$count contatti';
  }

  @override
  String get contactAddToHomeScreen => 'Aggiungi alla home';

  @override
  String contactRecommendedCardTo(String contact, String recipient) {
    return 'Scheda di $contact raccomandata a $recipient';
  }

  @override
  String get contactEnterRemarkName => 'Inserisci nome nota';

  @override
  String contactRemarkSetTo(String remark) {
    return 'Nota impostata: $remark';
  }

  @override
  String contactAcceptedFriendRequest(String name) {
    return 'Accettata richiesta di amicizia di $name';
  }

  @override
  String contactRejectedFriendRequest(String name) {
    return 'Rifiutata richiesta di amicizia di $name';
  }

  @override
  String get commonGroupInvites => 'Inviti gruppo';

  @override
  String commonMyGroups(int count) {
    return 'I miei gruppi ($count)';
  }

  @override
  String get commonInvitedToJoinGroup => 'Invitato a unirsi al gruppo';

  @override
  String commonConfirmLeaveGroup(String name) {
    return 'Sei sicuro di voler lasciare \"$name\"?';
  }

  @override
  String get commonLeave => 'Lascia';

  @override
  String get commonRecallThisMessage => 'Ritirare questo messaggio?';

  @override
  String get commonSavedToGallery => 'Salvato nella galleria';

  @override
  String get commonFailedToSave => 'Salvataggio fallito';

  @override
  String get chatSaving => 'Salvataggio...';

  @override
  String get commonShare => 'Condividi';

  @override
  String get chatSaveToGallery => 'Salva nella galleria';

  @override
  String chatDownloadFailed(String code) {
    return 'Download fallito: $code';
  }

  @override
  String commonShareFailed(String error) {
    return 'Condivisione fallita: $error';
  }

  @override
  String get chatFailedToLoadImage => 'Caricamento immagine fallito';

  @override
  String get chatVideoRecordingFailed =>
      'Registrazione video fallita. Riprova.';

  @override
  String get profileRedPacket => 'Busta rossa';

  @override
  String get commonMusic => 'Musica';

  @override
  String get commonCoupon => 'Buono';

  @override
  String get commonGift => 'Regalo';

  @override
  String get commonPoll => 'Sondaggio';

  @override
  String get favoriteText => 'Testo';

  @override
  String get favoriteLinkLabel => 'Collegamento';

  @override
  String get favoriteNote => 'Nota';

  @override
  String get favoriteMyNotes => 'Le mie note';

  @override
  String get favoriteToday => 'Oggi';

  @override
  String favoriteDaysAgoText(int count) {
    return '$count giorni fa';
  }

  @override
  String favoriteDateFormat(int month, int day) {
    return '$day/$month';
  }

  @override
  String get favoriteNoFavorites => 'Nessun preferito';

  @override
  String get favoriteLongPressToFavorite =>
      'Tieni premuto un messaggio per aggiungerlo ai preferiti';

  @override
  String get favoriteNewNote => 'Nuova nota';

  @override
  String get favoriteLink => 'Link preferito';

  @override
  String get favoriteEditTags => 'Modifica tag';

  @override
  String get favoriteDeleteFavorite => 'Elimina preferito';

  @override
  String get favoriteDeleteFavoriteConfirm =>
      'Sei sicuro di voler eliminare questo preferito?';

  @override
  String get favoriteNoSearchResultsFound => 'Nessun risultato trovato';

  @override
  String get commonSendRedPacket => 'Invia busta rossa';

  @override
  String get transferAmount => 'Importo';

  @override
  String get commonRedPacketCover => 'Copertina busta rossa';

  @override
  String get commonRedPacketType => 'Tipo busta rossa';

  @override
  String get commonNormalRedPacket => 'Normale';

  @override
  String get commonLuckyRedPacket => 'Fortunato';

  @override
  String get commonRedPacketCount => 'Numero buste rosse';

  @override
  String get commonPieces => 'pezzi';

  @override
  String get commonPutMoneyInRedPacket => 'Metti soldi nella busta rossa';

  @override
  String get commonRedPacketRefundNotice =>
      'Le buste rosse non riscosse verranno rimborsate dopo 24 ore';

  @override
  String get commonOpenRedPacket => 'Apri';

  @override
  String get commonRedPacketAllClaimed => 'Busta rossa completamente riscossa';

  @override
  String get commonRedPacketExpired => 'Busta rossa scaduta';

  @override
  String get commonAddTransferNote => 'Aggiungi nota trasferimento';

  @override
  String get commonYuan => 'CNY';

  @override
  String get commonReplyWithEmoji => 'Rispondi con questa emoji';

  @override
  String get contactEditRemark => 'Modifica nota';

  @override
  String get contactSetPermissions => 'Imposta permessi';

  @override
  String get profileAddToBlacklist => 'Aggiungi alla lista nera';

  @override
  String get contactDeleteContact => 'Elimina contatto';

  @override
  String contactDeleteContactConfirm(String name) {
    return 'Sei sicuro di voler eliminare $name?';
  }

  @override
  String get transferTitle => 'Trasferimento';

  @override
  String get transferReceiverAddressLabel => 'Indirizzo destinatario';

  @override
  String get transferSelectTokenLabel => 'Seleziona token';

  @override
  String get transferAmountLabel => 'Importo trasferimento';

  @override
  String get transferMemoLabel => 'Nota (opzionale)';

  @override
  String get transferAddMemoHint => 'Aggiungi una nota';

  @override
  String get transferSendPaymentRequest => 'Invia richiesta pagamento';

  @override
  String get transferQrCodeGenerateFailed => 'Generazione QR code fallita';

  @override
  String get transferScanQrToPayMe => 'Scansiona il QR code per pagarmi';

  @override
  String get transferMyWalletAddress => 'Il mio indirizzo wallet';

  @override
  String get transferCreatePaymentRequest => 'Crea richiesta pagamento';

  @override
  String profileN42IdLabel(String id) {
    return 'ID N42: $id';
  }

  @override
  String get commonRedPacketDefaultGreeting => 'Auguri';

  @override
  String commonSenderRedPacket(String name) {
    return 'Busta rossa di $name';
  }

  @override
  String get transferEnterValidAddress => 'Inserisci un indirizzo valido';

  @override
  String get transferPleaseSelectToken => 'Seleziona un token';

  @override
  String get commonReceivedTransfer => 'Trasferimento ricevuto';

  @override
  String commonSenderSentRedPacket(String name) {
    return '$name ha inviato una busta rossa';
  }

  @override
  String get commonSavedToBalance =>
      'Salvato nel saldo, puoi trasferire direttamente';

  @override
  String get commonRedPacketExpiredOrEmpty =>
      'Busta rossa scaduta/completamente riscossa';

  @override
  String get transferScanFeatureComingSoon => 'Funzione scansione in arrivo...';

  @override
  String get contactSetAsStarred => 'Imposta come preferito';

  @override
  String get contactAddToBlocklist => 'Aggiungi alla lista bloccati';

  @override
  String get commonClaimedYour => ' ha riscosso la tua ';

  @override
  String get commonClaimedText => ' ha riscosso ';

  @override
  String commonUserTyping(String name) {
    return '$name sta scrivendo...';
  }

  @override
  String get commonTyping => 'Sta scrivendo...';

  @override
  String get commonWaitingToReceive => 'In attesa di ricevere';

  @override
  String get commonTapToClaim => 'Tocca per riscuotere';

  @override
  String get commonHasBeenReceived => 'È stato ricevuto';

  @override
  String get commonGetLucky => 'Buona fortuna';

  @override
  String get qrcodeCameraStartFailed => 'Avvio fotocamera fallito';

  @override
  String get qrcodeUnknownError => 'Errore sconosciuto';

  @override
  String get qrcodePlaceQrCodeInFrame =>
      'Posiziona il QR code nel riquadro per scansionare';

  @override
  String get qrcodeCloseManualInput => 'Chiudi inserimento manuale';

  @override
  String get qrcodeManualInputUserId => 'Inserimento manuale ID utente';

  @override
  String get commonAdd => 'Aggiungi';

  @override
  String get profileSetStatus => 'Imposta stato';

  @override
  String get profileVisibleToFriends24h => 'Visibile agli amici per 24 ore';

  @override
  String get profileWriteStatus => 'Scrivi stato';

  @override
  String get profileEnterYourStatus => 'Inserisci il tuo stato...';

  @override
  String get profileOk => 'Va bene';

  @override
  String get qrcodeCameraPermissionRequired =>
      'Permesso fotocamera richiesto per scansionare QR code';

  @override
  String get qrcodeCameraPermissionDenied =>
      'Permesso fotocamera negato permanentemente. Abilitalo nelle impostazioni di sistema.';

  @override
  String qrcodePermissionCheckError(String error) {
    return 'Errore verifica permesso: $error';
  }

  @override
  String get qrcodeInvalidQrCode => 'QR code non valido';

  @override
  String qrcodeCannotAddFriend(String error) {
    return 'Impossibile aggiungere amico: $error';
  }

  @override
  String get qrcodeScanQrCode => 'Scansiona QR Code';

  @override
  String get qrcodeCheckingCameraPermission =>
      'Verifica permesso fotocamera...';

  @override
  String get qrcodeNeedCameraPermission => 'Permesso fotocamera richiesto';

  @override
  String get qrcodeRetryPermission => 'Riprova';

  @override
  String get qrcodeOpenSettings => 'Apri impostazioni';

  @override
  String get groupInviteMembers => 'Invita membri';

  @override
  String groupInviteCount(int count) {
    return 'Invita($count)';
  }

  @override
  String get profileNoShippingAddress => 'Nessun indirizzo di spedizione';

  @override
  String get profileDefaultLabel => 'Predefinito';

  @override
  String get profileNoInvoice => 'Nessuna fattura';

  @override
  String get profileCompany => 'Azienda';

  @override
  String get profileTaxNumber => 'Partita IVA';

  @override
  String get profileConfirmDeleteAddress =>
      'Sei sicuro di voler eliminare questo indirizzo?';

  @override
  String get profileConfirmDeleteInvoice =>
      'Sei sicuro di voler eliminare questa fattura?';

  @override
  String get commonGroupOwner => 'Proprietario';

  @override
  String get commonGroupAdmin => 'Ammin';

  @override
  String get groupSearchMembers => 'Cerca membri';

  @override
  String groupTotalMembers(int count) {
    return '$count membri';
  }

  @override
  String get chatRemoveFromGroup => 'Rimuovi dal gruppo';

  @override
  String groupConfirmRemoveMember(String name) {
    return 'Sei sicuro di voler rimuovere \"$name\" dal gruppo?';
  }

  @override
  String get chatUnknownSong => 'Brano sconosciuto';

  @override
  String get chatUnknownArtist => 'Artista sconosciuto';

  @override
  String get chatUnknownContact => 'Contatto sconosciuto';

  @override
  String get chatPersonalCard => 'Scheda contatto';

  @override
  String get chatSingleChoice => 'Singola';

  @override
  String get chatMultiChoice => 'Multipla';

  @override
  String get chatEnded => 'Terminato';

  @override
  String get chatEndPollButton => 'Termina sondaggio';

  @override
  String get chatPollHint =>
      'Il sondaggio verrà visualizzato nella chat. I membri del gruppo possono votare.';

  @override
  String get chatSearchSongOrArtist => 'Cerca brano o artista';

  @override
  String get chatNoSongsFound => 'Nessun brano trovato';

  @override
  String get chatSongNameOptional => 'Nome brano (opzionale)';

  @override
  String get chatEnterSongName => 'Inserisci nome brano';

  @override
  String get chatArtistNameOptional => 'Nome artista (opzionale)';

  @override
  String get chatEnterArtistName => 'Inserisci nome artista';

  @override
  String get chatRealTimeLocationSharing =>
      'Condivisione posizione in tempo reale in sviluppo...';

  @override
  String get profileVoiceCallFeatureInDev =>
      'Funzione chiamata vocale in sviluppo...';

  @override
  String get profileReportFeatureInDev =>
      'Funzione segnalazione in sviluppo...';

  @override
  String get profileShareFeatureInDev => 'Funzione condivisione in sviluppo...';

  @override
  String get profileQrCodeFeatureInDev => 'Funzione QR code in sviluppo...';

  @override
  String get qrcodeScanQrToAddMe =>
      'Scansiona il QR code qui sopra per aggiungermi come amico';

  @override
  String get qrcodeSaveToAlbum => 'Salva nell\'album';

  @override
  String get qrcodeChangeStyle => 'Cambia stile';

  @override
  String get qrcodeCopyId => 'Copia ID';

  @override
  String get qrcodeIdCopied => 'ID copiato';

  @override
  String get qrcodeMoreStylesFeatureComingSoon => 'Altri stili in arrivo';

  @override
  String get profileBio => 'Bio';

  @override
  String get profileHomeServer => 'Server';

  @override
  String get profileShareContactCard => 'Condividi scheda contatto';

  @override
  String get profileRemoveFromBlacklist => 'Rimuovi dalla lista nera';

  @override
  String get profileConfirmAddBlacklist =>
      'Sei sicuro di voler aggiungere questo utente alla lista nera? Non riceverai più messaggi da lui.';

  @override
  String get profileConfirmRemoveBlacklist =>
      'Sei sicuro di voler rimuovere questo utente dalla lista nera?';

  @override
  String get profileRemarkSaved => 'Nota salvata';

  @override
  String get profileRemarkCleared => 'Nota cancellata';

  @override
  String get transferReceive => 'Ricevi';

  @override
  String get transferPleaseConnectWallet => 'Connetti prima il tuo wallet';

  @override
  String get transferSendRequest => 'Invia richiesta';

  @override
  String get transferPleaseEnterValidAmount => 'Inserisci un importo valido';

  @override
  String get searchPlaceholder => 'Cerca contatti, gruppi, messaggi';

  @override
  String get searchEnterKeywordToSearch =>
      'Inserisci parola chiave per cercare';

  @override
  String get searchClearHistory => 'Cancella';

  @override
  String searchNoResultsForQuery(String query) {
    return 'Nessun risultato per \"$query\"';
  }

  @override
  String get searchAllResults => 'Tutto';

  @override
  String get searchInChat => 'Cerca nella chat';

  @override
  String get searchContactLabel => 'Contatto';

  @override
  String get searchGroupLabel => 'Gruppo';

  @override
  String get searchConversationLabel => 'Conversazione';

  @override
  String get searchMessageLabel => 'Messaggio';

  @override
  String get settingsSecurityTitle => 'Sicurezza';

  @override
  String get settingsKeyBackup => 'Backup chiavi';

  @override
  String get settingsBackupEncryptionKeys => 'Backup chiavi di crittografia';

  @override
  String settingsKeysBackedUp(int count) {
    return '$count chiavi salvate';
  }

  @override
  String get settingsBackupNotSet => 'Backup non configurato';

  @override
  String get settingsRestoreKeys => 'Ripristina chiavi';

  @override
  String get settingsRestoreKeysFromBackup =>
      'Ripristina chiavi di crittografia dal backup';

  @override
  String get settingsExportKeys => 'Esporta chiavi';

  @override
  String get settingsExportKeysToFile => 'Esporta chiavi in un file';

  @override
  String get settingsLoggedInDevices => 'Dispositivi connessi';

  @override
  String get settingsNoOtherDevices => 'Nessun altro dispositivo';

  @override
  String get settingsVerified => 'Verificato';

  @override
  String get settingsUnverified => 'Non verificato';

  @override
  String get settingsAdvanced => 'Avanzate';

  @override
  String get settingsCrossSigning => 'Cross-signing';

  @override
  String get settingsEnabled => 'Abilitato';

  @override
  String get settingsNotEnabled => 'Non abilitato';

  @override
  String get settingsResetEncryption => 'Reimposta crittografia';

  @override
  String get settingsDeleteAllEncryptionKeys =>
      'Elimina tutte le chiavi di crittografia';

  @override
  String get settingsEncryptionNotSupported => 'Crittografia non supportata';

  @override
  String get settingsNotInitialized => 'Non inizializzato';

  @override
  String get settingsBackupKeyTitle => 'Backup chiavi';

  @override
  String get settingsBackupKeyMessage =>
      'Creare un nuovo backup chiavi? Questo ti aiuterà a ripristinare i messaggi crittografati su un nuovo dispositivo.';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsRestoreKeyTitle => 'Ripristina chiavi';

  @override
  String get settingsRestoreKeyMessage =>
      'Inserisci la password di recupero o la chiave di recupero per ripristinare i messaggi crittografati.';

  @override
  String get settingsRestore => 'Ripristina';

  @override
  String get settingsExportKeyTitle => 'Esporta chiavi';

  @override
  String get settingsExportKeyMessage =>
      'Il file chiavi esportato contiene tutte le tue chiavi di crittografia. Conservalo al sicuro.';

  @override
  String get settingsExport => 'Esporta';

  @override
  String settingsDeviceIdLabel(String deviceId) {
    return 'ID dispositivo: $deviceId';
  }

  @override
  String get settingsDeviceStatusVerified => 'Stato: Verificato';

  @override
  String get settingsDeviceStatusUnverified => 'Stato: Non verificato';

  @override
  String settingsLastActiveLabel(String lastSeen) {
    return 'Ultimo accesso: $lastSeen';
  }

  @override
  String get settingsVerifyThisDevice => 'Verifica questo dispositivo';

  @override
  String get settingsCrossSigningAlreadyEnabled =>
      'Cross-signing già abilitato';

  @override
  String get settingsCrossSigningSetupSuccess =>
      'Configurazione cross-signing riuscita';

  @override
  String get settingsResetEncryptionTitle => 'Reimposta crittografia';

  @override
  String get settingsResetEncryptionWarning =>
      'Attenzione: Questo eliminerà tutte le tue chiavi di crittografia. Non potrai decifrare i messaggi crittografati precedenti. Questa azione non può essere annullata.';

  @override
  String get settingsReset => 'Reimposta';

  @override
  String get settingsBackupSuccess =>
      'Backup delle chiavi riuscito correttamente';

  @override
  String get settingsBackupFailed => 'Backup non riuscito';

  @override
  String get settingsRecoveryKey => 'Chiave di ripristino';

  @override
  String get settingsRecoveryKeySaveWarning =>
      'Salva questa chiave di ripristino in un luogo sicuro. Ne avrai bisogno per ripristinare i tuoi messaggi crittografati su un nuovo dispositivo.';

  @override
  String get settingsRecoveryKeySaved => 'L\'ho salvato';

  @override
  String get settingsRestoreSuccess => 'Chiavi ripristinate correttamente';

  @override
  String get settingsRestoreFailed => 'Ripristino non riuscito';

  @override
  String get settingsPassword => 'Parola d\'ordine';

  @override
  String get settingsEnterRecoveryKey => 'Inserisci la chiave di ripristino';

  @override
  String get settingsEnterPassword => 'Inserisci la password';

  @override
  String get settingsExportSuccess =>
      'Chiavi esportate correttamente nel backup del server';

  @override
  String get settingsExportNeedBackupFirst =>
      'Crea prima un backup della chiave';

  @override
  String get settingsExportFailed => 'Esportazione non riuscita';

  @override
  String get settingsResetSuccess =>
      'Reimpostazione della crittografia riuscita';

  @override
  String get settingsResetFailed => 'Reimpostazione non riuscita';

  @override
  String get callLeaveMeetingConfirm =>
      'Sei sicuro di voler lasciare la riunione?';

  @override
  String chatPokedSomeone(String name, String suffix) {
    return 'ha toccato $name$suffix';
  }

  @override
  String get chatNoContactsToAdd => 'Nessun contatto disponibile da aggiungere';

  @override
  String get chatAddMembers => 'Aggiungi membri';

  @override
  String chatInvitedMembers(int count) {
    return 'Invitati $count membri';
  }

  @override
  String chatInviteFailed(String error) {
    return 'Invito fallito: $error';
  }

  @override
  String get chatMemberRemoved => 'Membro rimosso';

  @override
  String chatRemoveFailed(String error) {
    return 'Rimozione fallita: $error';
  }

  @override
  String get chatRealTimeLocationShareMessage =>
      'Dopo la condivisione, l\'altra persona potrà vedere la tua posizione in tempo reale per 1 ora.';

  @override
  String get chatStartSharing => 'Inizia condivisione';

  @override
  String get chatLocationServiceNotEnabled =>
      'Servizio di localizzazione non abilitato';

  @override
  String get chatEnableLocationService =>
      'Abilita il servizio di localizzazione per usare questa funzione';

  @override
  String get chatGoToSettings => 'Vai alle impostazioni';

  @override
  String get chatLocationPermissionRequired =>
      'Permesso di localizzazione richiesto per questa funzione';

  @override
  String get chatLocationPermissionDeniedPermanent =>
      'Permesso di localizzazione negato permanentemente. Abilitalo nelle impostazioni.';

  @override
  String get chatLocationPermissionDenied =>
      'Permesso di localizzazione negato';

  @override
  String get chatGettingLocation => 'Ottenimento posizione...';

  @override
  String chatGetLocationFailed(String error) {
    return 'Impossibile ottenere la posizione: $error';
  }

  @override
  String get chatMapPreview => 'Anteprima mappa';

  @override
  String get chatSearchLocation => 'Cerca posizione';

  @override
  String chatRedPacketSent(String amount, String token) {
    return 'Inviata busta rossa di $amount $token';
  }

  @override
  String get chatTransferDefault => 'Trasferimento';

  @override
  String chatTransferSent(String amount, String token) {
    return 'Inviato trasferimento di $amount $token';
  }

  @override
  String chatPickFileFailed(String error) {
    return 'Selezione file fallita: $error';
  }

  @override
  String get chatFileSizeLimit => 'Il file non può superare 50MB';

  @override
  String chatFileSending(String filename) {
    return 'Invio file: $filename';
  }

  @override
  String chatSendFileFailed(String error) {
    return 'Invio file fallito: $error';
  }

  @override
  String chatContactCardSent(String name) {
    return 'Inviata scheda contatto di $name';
  }

  @override
  String get chatFavoritesFeature => 'Preferiti';

  @override
  String get chatCouponsFeature => 'Coupon';

  @override
  String get chatGiftFeature => 'Regalo';

  @override
  String chatSharedMusic(String name) {
    return 'Condiviso $name';
  }

  @override
  String get chatEndPollTitle => 'Termina sondaggio';

  @override
  String get chatEndPollConfirmMessage =>
      'Sei sicuro di voler terminare questo sondaggio? Le votazioni verranno chiuse.';

  @override
  String get chatPollEndedMessage => 'Sondaggio terminato';

  @override
  String get chatConnectingCall => 'Connessione in corso...';

  @override
  String get chatMuteCall => 'Silenzia';

  @override
  String get chatSpeakerOff => 'Altoparlante spento';

  @override
  String get chatSpeakerOn => 'Altoparlante';

  @override
  String get chatCameraOn => 'Fotocamera accesa';

  @override
  String get chatCameraOff => 'Fotocamera spenta';

  @override
  String get chatHangUp => 'Termina';

  @override
  String get chatSelectForwardTargetTitle => 'Seleziona destinatario inoltro';

  @override
  String get chatNoForwardableChat => 'Nessuna chat disponibile per l\'inoltro';

  @override
  String get chatNoMatchingChat => 'Nessuna chat corrispondente trovata';

  @override
  String get chatLocationTitle => 'Posizione';

  @override
  String get chatSendButton => 'Invia';

  @override
  String get chatRetryButton => 'Riprova';

  @override
  String get chatSearchContactHint => 'Cerca contatti';

  @override
  String get chatShareMusic => 'Condividi musica';

  @override
  String get chatRecentPlayed => 'Recenti';

  @override
  String get chatMyFavorites => 'Preferiti';

  @override
  String get chatNetworkLink => 'Collegamento';

  @override
  String get chatLocalFile => 'Locale';

  @override
  String get chatPasteMusicLink => 'Incolla link musicale';

  @override
  String get chatShareMusicButton => 'Condividi musica';

  @override
  String get chatSelectLocalAudio => 'Seleziona file audio locale';

  @override
  String get chatSupportedAudioFormats => 'Supporta MP3, M4A, WAV, FLAC, ecc.';

  @override
  String get chatSelectFileButton => 'Seleziona file';

  @override
  String get chatPleaseEnterMusicLink => 'Inserisci link musicale';

  @override
  String get chatPleaseEnterValidLink => 'Inserisci un URL valido';

  @override
  String get chatSharedSong => 'Brano condiviso';

  @override
  String get chatSelectMember => 'Seleziona membro';

  @override
  String get chatSearchMemberHint => 'Cerca membri';

  @override
  String get chatNoMatchingMembers => 'Nessun membro corrispondente trovato';

  @override
  String get commonUnknownMember => 'Sconosciuto';

  @override
  String chatSelectedMessagesCount(int count) {
    return 'Selezionati $count messaggi';
  }

  @override
  String get chatSearchContactsOrGroups => 'Cerca contatti o gruppi';

  @override
  String get chatVideoTitle => 'Video';

  @override
  String get chatLoadingText => 'Caricamento...';

  @override
  String get chatVideoLoadFailed => 'Caricamento video fallito';

  @override
  String get chatPlayerInitFailed => 'Inizializzazione player fallita';

  @override
  String get chatCreatePollTitle => 'Crea sondaggio';

  @override
  String get chatSubmitPoll => 'Invia';

  @override
  String get chatPollQuestionLabel => 'Domanda sondaggio';

  @override
  String get chatEnterPollQuestionHint => 'Inserisci domanda sondaggio';

  @override
  String get chatPollOptionsLabel => 'Opzioni sondaggio';

  @override
  String chatOptionHintWithIndex(int index) {
    return 'Opzione $index';
  }

  @override
  String get chatAddOptionButton => 'Aggiungi opzione';

  @override
  String get chatPollSettingsLabel => 'Impostazioni sondaggio';

  @override
  String get chatSelectionType => 'Tipo selezione';

  @override
  String get chatSingleChoiceLabel => 'Singola';

  @override
  String get chatMultiChoiceLabel => 'Multipla';

  @override
  String get chatAnonymousPollSwitch => 'Sondaggio anonimo';

  @override
  String get chatPleaseEnterQuestion => 'Inserisci domanda sondaggio';

  @override
  String get chatAtLeastTwoOptions => 'Almeno 2 opzioni richieste';

  @override
  String chatConfirmWithCount(int count) {
    return 'Conferma ($count)';
  }

  @override
  String get authEmailVerificationTitle => 'Verifica email';

  @override
  String get authEnterValidEmailAddress =>
      'Inserisci un indirizzo email valido';

  @override
  String authVerificationCodeSentTo(String email) {
    return 'Codice di verifica inviato a $email';
  }

  @override
  String authSendCodeFailed(String error) {
    return 'Invio codice fallito: $error';
  }

  @override
  String get authVerificationSuccess => 'Verifica riuscita';

  @override
  String get authVerificationFailed => 'Verifica fallita';

  @override
  String authVerificationCodeError(String error) {
    return 'Errore codice di verifica: $error';
  }

  @override
  String get commonEnterVerificationCode => 'Inserisci codice di verifica';

  @override
  String get authEnterYourEmail => 'Inserisci email';

  @override
  String authWeSentCodeTo(String email) {
    return 'Abbiamo inviato un codice a 6 cifre a\n$email';
  }

  @override
  String get authEnterEmailForCode =>
      'Inserisci il tuo indirizzo email, ti invieremo un codice di verifica';

  @override
  String get commonSendVerificationCode => 'Invia codice di verifica';

  @override
  String get authResendVerificationCode => 'Reinvia codice di verifica';

  @override
  String authCanResendAfter(int seconds) {
    return 'Puoi reinviare tra $seconds secondi';
  }

  @override
  String get commonChangeEmail => 'Cambia email';

  @override
  String get contactAddToContacts => 'Aggiungi ai contatti';

  @override
  String get contactAddingToContacts => 'Aggiungendo...';

  @override
  String get contactAddedToContacts => 'Aggiunto ai contatti';

  @override
  String contactAddFailedWithError(String error) {
    return 'Aggiunta fallita: $error';
  }

  @override
  String get contactAddPhone => 'Aggiungi telefono';

  @override
  String get contactAddTag => 'Aggiungi tag';

  @override
  String get contactAddText => 'Aggiungi testo';

  @override
  String get contactAddPhoto => 'Aggiungi foto';

  @override
  String contactGroupCountLabel(int count) {
    return '$count gruppi';
  }

  @override
  String get contactAddedViaSearch => 'Aggiunto tramite ricerca';

  @override
  String get contactAddTime => 'Aggiungi ora';

  @override
  String get contactDoneButton => 'Fatto';

  @override
  String get callWaitingForParticipants => 'In attesa di partecipanti...';

  @override
  String callParticipantMe(String name) {
    return '$name (Io)';
  }

  @override
  String get callSharingLabel => 'Condivisione';

  @override
  String callScreenSharingBy(String name) {
    return '$name sta condividendo lo schermo';
  }

  @override
  String callParticipantCount(int count) {
    return '$count partecipanti';
  }

  @override
  String get callMuteLabel => 'Silenzia';

  @override
  String get callUnmuteLabel => 'Riattiva';

  @override
  String get callTurnOffVideo => 'Disattiva video';

  @override
  String get callTurnOnVideo => 'Attiva video';

  @override
  String get callShareScreen => 'Condividi schermo';

  @override
  String get callStopSharing => 'Interrompi condivisione';

  @override
  String get callSwitchCameraLabel => 'Cambia';

  @override
  String get callLeaveLabel => 'Lascia';

  @override
  String get callParticipantsLabel => 'Partecipanti';

  @override
  String get callJoiningMeeting => 'Entrando nella riunione...';

  @override
  String chatPollVotesFormat(int count, String percentage) {
    return '$count voti ($percentage%)';
  }

  @override
  String chatPollParticipantsFormat(int count) {
    return '$count partecipanti';
  }

  @override
  String get commonTapToRetry => 'Tocca per riprovare';

  @override
  String get chatDefaultRedPacketGreeting => 'Auguri di prosperità e fortuna';

  @override
  String get groupAllowOthersToSearchAndJoin =>
      'Consenti ad altri di cercare e aderire';

  @override
  String get groupConfirmClearChatHistory =>
      'Sei sicuro di voler cancellare la cronologia chat?';

  @override
  String get groupCreateGroupToChat => 'Crea un gruppo per iniziare a chattare';

  @override
  String get groupEditGroupAnnouncement => 'Modifica annuncio del gruppo';

  @override
  String get groupEditGroupDescription => 'Modifica descrizione del gruppo';

  @override
  String get groupEnterGroupAnnouncement => 'Inserisci l\'annuncio del gruppo';

  @override
  String chatErrorWithMessage(String message) {
    return 'Errore: $message';
  }

  @override
  String groupMemberCountClickToCopy(int count) {
    return '$count membri, fai clic per copiare l\'ID del gruppo';
  }

  @override
  String get chatMusicLinkLabel => 'Link musicale';

  @override
  String get chatNoMediaUrlAvailable => 'URL multimediale non disponibile';

  @override
  String get groupNoPermissionToEditGroupName =>
      'Non hai il permesso di modificare il nome del gruppo';

  @override
  String get chatRedPacketTransferCannotForward =>
      'Le buste rosse e i trasferimenti non possono essere inoltrati';

  @override
  String get authEmailAddress => 'Indirizzo email';

  @override
  String get commonEnterEmailAddress => 'Inserisci l\'indirizzo email';

  @override
  String get authEmailRecoveryHint => 'Usato per il recupero della password';

  @override
  String get commonInvalidEmailFormat => 'Inserisci un indirizzo email valido';

  @override
  String get authOptional => 'Opzionale';

  @override
  String get authResetPassword => 'Ripristina password';

  @override
  String get authEnterRegisteredEmail =>
      'Inserisci l\'indirizzo email con cui ti sei registrato';

  @override
  String get authSendResetCode => 'Invia codice di ripristino';

  @override
  String authResetCodeSent(String email) {
    return 'Codice di ripristino inviato a $email';
  }

  @override
  String get authEnterResetCode => 'Inserisci il codice di ripristino';

  @override
  String get authSetNewPassword => 'Imposta nuova password';

  @override
  String get commonConfirmNewPassword => 'Conferma nuova password';

  @override
  String get commonNewPassword => 'Nuova password';

  @override
  String get authPasswordResetSuccess =>
      'Password ripristinata con successo. Accedi con la tua nuova password.';

  @override
  String get authResetPasswordFailed => 'Ripristino password fallito';

  @override
  String get settingsChangePassword => 'Cambia password';

  @override
  String get settingsCurrentPassword => 'Password attuale';

  @override
  String get settingsEnterCurrentPassword => 'Inserisci la password attuale';

  @override
  String get settingsEnterNewPassword => 'Inserisci la nuova password';

  @override
  String get settingsPasswordChanged =>
      'Password cambiata con successo. Accedi con la tua nuova password.';

  @override
  String get settingsChangePasswordFailed => 'Cambio password fallito';

  @override
  String get settingsNewPasswordMustBeDifferent =>
      'La nuova password deve essere diversa dalla password attuale';

  @override
  String get settingsChangePasswordInfo =>
      'Dopo aver cambiato la password, verrai disconnesso e dovrai accedere con la nuova password.';

  @override
  String get settingsPasswordRequirements => 'Requisiti della password:';

  @override
  String get settingsSecurityNote =>
      'Per sicurezza, dovrai riaccedere su tutti i dispositivi dopo aver cambiato la password.';

  @override
  String get settingsSecurity => 'Sicurezza';

  @override
  String get settingsCurrentBoundEmail => 'Email attualmente collegata';

  @override
  String get settingsNewEmailAddress => 'Nuovo indirizzo email';

  @override
  String get settingsEnterNewEmail => 'Inserisci il nuovo indirizzo email';

  @override
  String get settingsVerificationCode => 'Codice di verifica';

  @override
  String get settingsVerificationCodeSent => 'Codice di verifica inviato';

  @override
  String get settingsCodeSentTo => 'Codice di verifica inviato a';

  @override
  String get settingsDidNotReceiveCode => 'Non hai ricevuto il codice?';

  @override
  String get settingsEmailChangedSuccess => 'Email cambiata con successo';

  @override
  String get settingsChangeEmailFailed => 'Cambio email fallito';

  @override
  String get settingsEmailSecurityNote =>
      'La tua email viene usata per il recupero della password. Mantienila al sicuro.';

  @override
  String get commonGoogleLogin => 'Accedi con Google';

  @override
  String get commonAppleLogin => 'Accedi con Apple';

  @override
  String get commonWechat => 'WeChat';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageChanged => 'Lingua cambiata';

  @override
  String get settingsTranslation => 'Traduzione';

  @override
  String get settingsTranslateTextTo => 'Traduci il testo in';

  @override
  String get settingsTranslateDescription =>
      'Seleziona la lingua in cui desideri che i messaggi vengano tradotti.';

  @override
  String get settingsAutoTranslate =>
      'Traduci automaticamente i messaggi ricevuti';

  @override
  String get settingsAutoTranslateDescription =>
      'Traduci automaticamente i messaggi ricevuti in chat nella lingua selezionata.';

  @override
  String get settingsBiometricLogin => 'Accesso biometrico';

  @override
  String authLoginWithBiometric(Object type) {
    return 'Accedi con $type';
  }

  @override
  String get settingsBiometricLoginEnabled => 'Accesso biometrico attivato';

  @override
  String get settingsBiometricLoginDisabled => 'Accesso biometrico disattivato';

  @override
  String get settingsEnableBiometricLogin => 'Attiva accesso biometrico';

  @override
  String get settingsBiometricEnabled =>
      'Attivato - Usa biometria per accedere';

  @override
  String get settingsBiometricDisabled => 'Disattivato - Tocca per attivare';

  @override
  String get settingsBiometricNeedRelogin =>
      'Disconnettiti e accedi di nuovo per attivare l\'accesso biometrico';

  @override
  String get authOr => 'OPPURE';

  @override
  String get qrcodeCameraPermissionRestricted =>
      'L\'accesso alla fotocamera è limitato su questo dispositivo';

  @override
  String get authPasskeyLabel => 'Chiave di accesso';

  @override
  String get authGoogleLabel => 'Google';

  @override
  String get authAppleLabel => 'mela';

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
      'Inserisci il suffisso del tocco, es.: sulla spalla';

  @override
  String get groupAlbum => 'Album del gruppo';

  @override
  String get groupFiles => 'File del gruppo';

  @override
  String get groupImages => 'Immagini';

  @override
  String get groupVideos => 'Video';

  @override
  String get groupTotal => 'Totale';

  @override
  String get groupSize => 'Dimensione';

  @override
  String get groupNoMedia => 'Nessun media';

  @override
  String get groupNoMediaDescription =>
      'Nessuna foto o video in questo gruppo ancora';

  @override
  String get groupDocuments => 'Documenti';

  @override
  String get groupNoFiles => 'Nessun file';

  @override
  String get groupNoFilesDescription => 'Nessun file in questo gruppo ancora';

  @override
  String groupDownloadStarted(String filename) {
    return 'Download di $filename...';
  }

  @override
  String get contactNoCommonGroups => 'Nessun gruppo in comune';

  @override
  String get contactNoCommonGroupsDescription => 'Non avete gruppi in comune';

  @override
  String get chatVoiceMessage => 'Vocale';

  @override
  String get chatMessage => 'Messaggio';

  @override
  String get conversationHideChat => 'Nascondi';

  @override
  String get settingsQuickReply => 'Risposta rapida';

  @override
  String get commonTranslate => 'Traduci';

  @override
  String get contactCreateTag => 'Crea etichetta';

  @override
  String get contactEnterTagName => 'Inserisci il nome dell\'etichetta';

  @override
  String get contactEditTag => 'Modifica etichetta';

  @override
  String get contactDeleteTag => 'Elimina etichetta';

  @override
  String contactDeleteTagConfirm(String tagName) {
    return 'Sei sicuro di voler eliminare il tag \"$tagName\"?';
  }

  @override
  String get contactNoTags => 'Nessun tag ancora';

  @override
  String get contactFriendPermissions => 'Permessi degli amici';

  @override
  String get contactSetChatOnly => 'Imposta come Solo chat';

  @override
  String get contactChatOnlyDesc =>
      'Puoi chattare solo con te, gli altri contenuti saranno nascosti';

  @override
  String get contactHideMyMoments => 'Nascondi i miei momenti';

  @override
  String get contactHideMyMomentsDesc =>
      'Questo amico non può vedere i miei Momenti';

  @override
  String get contactHideTheirMoments => 'Nascondi i loro momenti';

  @override
  String get contactHideTheirMomentsDesc =>
      'Non vedere i Momenti di questo amico';

  @override
  String get contactHideMyStatus => 'Nascondi il mio stato';

  @override
  String get contactHideMyStatusDesc =>
      'Questo amico non può vedere i miei aggiornamenti di stato';

  @override
  String get contactNoChatOnlyFriends => 'Nessun amico solo in chat';

  @override
  String get contactNoOfficialAccounts => 'Nessun account ufficiale';

  @override
  String get contactFollowOfficialAccountsDesc =>
      'Segui gli account ufficiali per ricevere gli ultimi aggiornamenti';

  @override
  String get contactNoServiceAccounts => 'Nessun account di servizio';

  @override
  String get contactSubscribeServiceAccountsDesc =>
      'Iscriviti agli account di servizio per servizi convenienti';

  @override
  String get contactNoEnterpriseContacts => 'Nessun contatto aziendale';

  @override
  String get contactEnterpriseContactsDesc =>
      'I contatti aziendali verranno visualizzati qui';

  @override
  String get profileCardPack => 'Pacchetto di carte';

  @override
  String get profileOrders => 'Ordini';

  @override
  String get profileNoOrders => 'Nessun ordine';

  @override
  String get profileOrdersDesc => 'I tuoi ordini verranno visualizzati qui';

  @override
  String get profileNoCards => 'Nessuna carta';

  @override
  String get profileCardsDesc => 'Le tue carte verranno visualizzate qui';

  @override
  String get favoriteEnterTagsHint => 'Inserisci i tag separati da virgole';

  @override
  String get favoriteTagsUpdated => 'Tag aggiornati';

  @override
  String get favoriteForwardedContent => 'Contenuto inoltrato';

  @override
  String get favoriteEnterNoteContent => 'Inserisci il contenuto della nota';

  @override
  String get favoriteNoteAdded => 'Nota aggiunta';

  @override
  String get favoriteLinkTitle => 'Titolo del collegamento';

  @override
  String get favoriteLinkUrl => 'https://';

  @override
  String get favoriteLinkAdded => 'Collegamento aggiunto';

  @override
  String get contactPhotoAdded => 'Foto aggiunta';

  @override
  String get contactEnterPhone => 'Inserisci il numero di telefono';

  @override
  String commonConversationWithId(String roomId) {
    return 'Conversazione: $roomId';
  }

  @override
  String commonContactWithId(String userId) {
    return 'Contatto: $userId';
  }

  @override
  String get commonDiscover => 'Scopri';

  @override
  String commonDeveloping(String title) {
    return '$title\n(Prossimamente)';
  }

  @override
  String get commonPageNotFound => 'Pagina non trovata';

  @override
  String get commonBackToHome => 'Torna alla home';

  @override
  String get settingsMessageNotifications => 'Notifiche messaggi';

  @override
  String get settingsReceiveNewMessageNotifications =>
      'Ricevi notifiche per nuovi messaggi';

  @override
  String get settingsShowMessagePreview => 'Mostra anteprima messaggio';

  @override
  String get settingsShowMessageContentInNotification =>
      'Mostra contenuto del messaggio nelle notifiche';

  @override
  String get settingsNotificationSound => 'Suono notifica';

  @override
  String get settingsPlaySoundOnMessage =>
      'Riproduci suono alla ricezione messaggi';

  @override
  String get commonVibration => 'Vibrazione';

  @override
  String get settingsVibrateOnMessage => 'Vibra alla ricezione messaggi';

  @override
  String get settingsDoNotDisturbMode => 'Non disturbare';

  @override
  String get settingsDoNotDisturbDescription =>
      'Non ricevere notifiche durante il periodo specificato';

  @override
  String get settingsStartTime => 'Ora inizio';

  @override
  String get settingsEndTime => 'Ora fine';

  @override
  String get settingsDeleteQuickReply => 'Elimina risposta rapida';

  @override
  String get settingsEditQuickReply => 'Modifica risposta rapida';

  @override
  String get settingsAddQuickReply => 'Aggiungi risposta rapida';

  @override
  String get settingsManageQuickReplies => 'Gestisci risposte rapide';

  @override
  String get settingsNoQuickReplies => 'Nessuna risposta rapida';

  @override
  String get settingsDefaultQuickReplies =>
      'Verranno mostrate le risposte rapide predefinite';

  @override
  String get settingsWhoCanSee => 'Chi può vedere';

  @override
  String get settingsLastSeen => 'Ultimo accesso';

  @override
  String get settingsHiddenChats => 'Chat nascosti';

  @override
  String get settingsMessagesLabel => 'Messaggi';

  @override
  String get settingsAllowStrangerMessages =>
      'Consenti messaggi da sconosciuti';

  @override
  String get settingsReceiveMessagesFromNonContacts =>
      'Ricevi messaggi da non-contatti';

  @override
  String get settingsReadReceipts => 'Conferme di lettura';

  @override
  String get settingsLetOthersKnowYouRead =>
      'Fai sapere agli altri che hai letto i loro messaggi';

  @override
  String get settingsTypingIndicator => 'Indicatore di digitazione';

  @override
  String get settingsLetOthersKnowYouTyping =>
      'Fai sapere agli altri che stai scrivendo';

  @override
  String get settingsEveryone => 'Tutti';

  @override
  String get settingsContactsOnly => 'Solo contatti';

  @override
  String get settingsNobody => 'Nessuno';

  @override
  String settingsWhoCanSeeTitle(String title) {
    return 'Chi può vedere $title';
  }

  @override
  String settingsVersionInfo(String version) {
    return 'Versione $version';
  }

  @override
  String get settingsCheckForUpdates => 'Controlla aggiornamenti';

  @override
  String get settingsOpenSourceLicenses => 'Licenze open source';

  @override
  String get settingsFeedbackAndSuggestions => 'Feedback e suggerimenti';

  @override
  String get settingsBuiltOnMatrix => 'Basato sul protocollo Matrix';

  @override
  String get settingsNoHiddenChats => 'Nessun chat nascosto';

  @override
  String get settingsNoHiddenChatsDescription =>
      'Le chat che nascondi appariranno qui';

  @override
  String get settingsUnhideChat => 'Mostra';

  @override
  String get settingsDarkMode => 'Modalità scura';

  @override
  String get settingsFontSize => 'Dimensione carattere';

  @override
  String get settingsBubbleStyle => 'Stile fumetto';

  @override
  String get settingsFollowSystem => 'Segui sistema';

  @override
  String get settingsAutoSwitchBySystem =>
      'Cambia automaticamente in base alle impostazioni di sistema';

  @override
  String get settingsLightMode => 'Modalità chiara';

  @override
  String get settingsAlwaysUseLightTheme => 'Usa sempre tema chiaro';

  @override
  String get settingsDarkModeOption => 'Modalità scura';

  @override
  String get settingsAlwaysUseDarkTheme => 'Usa sempre tema scuro';

  @override
  String get settingsFontSizeSmall => 'Piccolo';

  @override
  String get settingsFontSizeStandard => 'Norma';

  @override
  String get settingsFontSizeLarge => 'Grande';

  @override
  String get settingsFontSizeExtraLarge => 'Extra grande';

  @override
  String get settingsBubbleStyleWechat => 'Stile WeChat';

  @override
  String get settingsBubbleStyleWechatDesc => 'Stile fumetto classico WeChat';

  @override
  String get settingsBubbleStyleModern => 'Stile moderno';

  @override
  String get settingsBubbleStyleModernDesc => 'Stile fumetto moderno e pulito';

  @override
  String get settingsBubbleStyleClassic => 'Stile classico';

  @override
  String get settingsBubbleStyleClassicDesc => 'Stile fumetto tradizionale';

  @override
  String get discoverVideoChannels => 'Canali';

  @override
  String get discoverLive => 'Vivi';

  @override
  String get discoverListen => 'Ascolta';

  @override
  String get discoverWatch => 'Guarda';

  @override
  String get discoverSearchDiscover => 'Cerca';

  @override
  String get discoverNearbyPeople => 'Vicino a te';

  @override
  String get discoverGames => 'Giochi';

  @override
  String get discoverMiniPrograms => 'Mini programmi';

  @override
  String get chatAlreadyInCall => 'Già in chiamata';

  @override
  String get commonConnectionFailed => 'Connessione fallita';

  @override
  String get chatCallRejected => 'Chiamata rifiutata';

  @override
  String get chatNoAnswer => 'Nessuna risposta';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get chatSelectContact => 'Seleziona contatto';

  @override
  String get chatVoteRemoved => 'Voto rimosso';

  @override
  String get chatVoteChanged => 'Voto modificato';

  @override
  String get chatVoted => 'Votato';

  @override
  String chatReplyTo(String name) {
    return 'Rispondi a $name';
  }

  @override
  String get chatCurrentLocation => 'Posizione attuale';

  @override
  String chatNearbyPlace(int index) {
    return 'Luogo vicino $index';
  }

  @override
  String chatApproximateDistance(String distance) {
    return 'Circa $distance';
  }

  @override
  String get chatAddress => 'Indirizzo';

  @override
  String get chatLatitude => 'Latitudine';

  @override
  String get chatLongitude => 'Longitudine';

  @override
  String get groupDescriptionUpdated => 'Descrizione gruppo aggiornata';

  @override
  String get groupAvatarUpdated => 'Avatar gruppo aggiornato';

  @override
  String get groupVisibilityUpdated => 'Visibilità del gruppo aggiornata';

  @override
  String get groupChannelCreated => 'Canale creato';

  @override
  String get groupChannelUpdated => 'Canale aggiornato';

  @override
  String get groupChannelDeleted => 'Canale eliminato';

  @override
  String get callDecline => 'Rifiuta';

  @override
  String get callAnswer => 'Rispondi';

  @override
  String get callIncomingVideoCall => 'Videochiamata in arrivo';

  @override
  String get callIncomingVoiceCall => 'Chiamata vocale in arrivo';

  @override
  String get callVideoCallInProgress => 'Videochiamata';

  @override
  String get callVoiceCallInProgress => 'Chiamata vocale';

  @override
  String get callReconnectingCall => 'Riconnessione in corso...';

  @override
  String get callEnded => 'Chiamata terminata';

  @override
  String get callFailed => 'Chiamata fallita';

  @override
  String get callLivekitNotConfigured => 'LiveKit non configurato';

  @override
  String callJoinMeetingFailed(String error) {
    return 'Impossibile partecipare alla riunione: $error';
  }

  @override
  String callScreenShareFailed(String error) {
    return 'Condivisione schermo fallita: $error';
  }

  @override
  String get profileN42BeanTitle => 'Fagiolo N42';

  @override
  String get profileNoN42Bean => 'Nessun N42 Bean';

  @override
  String get profileN42BeanDetails => 'Dettagli N42 Bean';

  @override
  String get profileN42BeanDescription =>
      'N42 Bean è un token per riscattare oggetti virtuali e servizi in N42. Attualmente disponibile per:';

  @override
  String get profileN42BeanFeature1 => 'Sticker e temi esclusivi per membri';

  @override
  String get profileN42BeanFeature2 => 'Personalizzazione bolle di chat';

  @override
  String get profileN42BeanFeature3 =>
      'Personalizzazione copertine buste rosse';

  @override
  String get profileN42BeanFeature4 => 'Badge nickname esclusivo';

  @override
  String get profileN42BeanFeature5 => 'Privilegi chat di gruppo';

  @override
  String get profileN42BeanFeature6 => 'Espansione archiviazione cloud';

  @override
  String get profileN42BeanFeature7 => 'Filtri bellezza videochiamata';

  @override
  String get profileN42BeanFeature8 => 'Personalizzazione sfondo Moments';

  @override
  String get profileN42BeanFeature9 => 'Priorità servizio clienti VIP';

  @override
  String get profileGotIt => 'Ho capito';

  @override
  String get profileNoN42BeanRecords => 'Nessun registro N42 Bean';

  @override
  String get profileMoodAndThoughts => 'Umore e pensieri';

  @override
  String get profileStatusHappy => 'Felice';

  @override
  String get profileStatusCracked => 'A pezzi';

  @override
  String get profileStatusLucky => 'Fortunato';

  @override
  String get profileStatusSunny => 'Solare';

  @override
  String get profileStatusTired => 'Stanco';

  @override
  String get profileStatusDaydream => 'Sognando';

  @override
  String get profileStatusRushing => 'Di fretta';

  @override
  String get profileStatusOverthinking => 'Pensieroso';

  @override
  String get profileStatusEnergized => 'Carico';

  @override
  String get profileWorkAndStudy => 'Lavoro e studio';

  @override
  String get profileStatusWorking => 'Al lavoro';

  @override
  String get profileStatusStudying => 'Studiando';

  @override
  String get profileStatusBusy => 'Occupato';

  @override
  String get profileStatusSlacking => 'Rilassandosi';

  @override
  String get profileStatusTraveling => 'In viaggio';

  @override
  String get profileStatusGoingHome => 'Tornando a casa';

  @override
  String get profileStatusDnd => 'Non disturbare';

  @override
  String get profileActivities => 'Attività';

  @override
  String get profileStatusHanging => 'In giro';

  @override
  String get profileStatusCheckIn => 'Check in';

  @override
  String get profileStatusExercising => 'Allenamento';

  @override
  String get profileStatusCoffee => 'Caffè';

  @override
  String get profileStatusBubbleTea => 'Bubble tea';

  @override
  String get profileStatusEating => 'Mangiando';

  @override
  String get profileStatusParenting => 'Genitori';

  @override
  String get profileStatusSavingWorld => 'Salvando il mondo';

  @override
  String get profileStatusSelfie => 'Selfie';

  @override
  String get profileRest => 'Riposo';

  @override
  String get profileStatusRetreat => 'Ritirata';

  @override
  String get profileStatusHome => 'A casa';

  @override
  String get profileStatusSleeping => 'Dormendo';

  @override
  String get profileStatusCatLover => 'Amante dei gatti';

  @override
  String get profileStatusDogWalking => 'Passeggiata col cane';

  @override
  String get profileStatusGaming => 'Giocando';

  @override
  String get profileStatusListening => 'Ascoltando';

  @override
  String get profileEditAddress => 'Modifica indirizzo';

  @override
  String get profileRecipient => 'Destinatario';

  @override
  String get profileEnterRecipientName => 'Inserisci nome destinatario';

  @override
  String get profilePhoneNumber => 'Numero di telefono';

  @override
  String get profileEnterPhoneNumber => 'Inserisci numero di telefono';

  @override
  String get profileRegionHint => 'Provincia/Città/Distretto';

  @override
  String get profileDetailedAddress => 'Indirizzo dettagliato';

  @override
  String get profileDetailedAddressHint => 'Via, numero civico, ecc.';

  @override
  String get profileSetAsDefaultAddress => 'Imposta come indirizzo predefinito';

  @override
  String get profilePleaseCompleteInfo => 'Compila tutti i campi';

  @override
  String get profileEditInvoice => 'Modifica fattura';

  @override
  String get profileInvoiceType => 'Tipo fattura: ';

  @override
  String get profileCompanyName => 'Nome azienda';

  @override
  String get profilePersonalName => 'Nome personale';

  @override
  String get profileEnterCompanyName => 'Inserisci nome azienda';

  @override
  String get profileEnterName => 'Inserisci nome';

  @override
  String get profileTaxIdNumber => 'Codice fiscale';

  @override
  String get profileEnterTaxIdNumber => 'Inserisci codice fiscale';

  @override
  String get profileBankNameOptional => 'Nome banca (opzionale)';

  @override
  String get profileEnterBankName => 'Inserisci nome banca';

  @override
  String get profileBankAccountOptional => 'Conto bancario (opzionale)';

  @override
  String get profileEnterBankAccount => 'Inserisci conto bancario';

  @override
  String get profileCompanyAddressOptional => 'Indirizzo azienda (opzionale)';

  @override
  String get profileEnterCompanyAddress => 'Inserisci indirizzo azienda';

  @override
  String get profileCompanyPhoneOptional => 'Telefono azienda (opzionale)';

  @override
  String get profileEnterCompanyPhone => 'Inserisci telefono azienda';

  @override
  String get profileSetAsDefaultInvoice => 'Imposta come fattura predefinita';

  @override
  String get profileRingtoneVibrate => 'Vibrazione';

  @override
  String get profileRingtoneSilent => 'Silenzioso';

  @override
  String get profileVibrateMode => 'Modalità vibrazione';

  @override
  String get profileSilentMode => 'Modalità silenziosa';

  @override
  String profilePlayFailed(String ringtoneName) {
    return 'Riproduzione fallita: $ringtoneName';
  }

  @override
  String profilePlaying(String ringtoneName) {
    return 'In riproduzione: $ringtoneName';
  }

  @override
  String get profileStop => 'Fermati';

  @override
  String get profileSelectRingtone => 'Seleziona suoneria';

  @override
  String get profileLoadingRingtones => 'Caricamento suonerie...';

  @override
  String get profileNoRingtonesFound => 'Nessuna suoneria trovata';

  @override
  String mainMessagesWithCount(int count) {
    return 'Messaggi($count)';
  }

  @override
  String get storyViewers => 'Visualizzatori';

  @override
  String get storyNoViewers => 'Nessun visualizzatore ancora';

  @override
  String get storyReplyToStory => 'Rispondi alla storia...';

  @override
  String get commonCopiedToClipboard => 'Copiato negli appunti';

  @override
  String get commonMore => 'Altro';

  @override
  String get commonTranslating => 'Traduzione in corso...';

  @override
  String commonTranslatedFrom(String language) {
    return 'Tradotto da $language';
  }

  @override
  String get commonTranslation => 'Traduzione';

  @override
  String get commonTranslationFailed => 'Traduzione fallita';

  @override
  String get commonAllRead => 'Tutto letto';

  @override
  String commonReadCount(int count) {
    return '$count letto';
  }

  @override
  String get commonYouRecalledMessage => 'Hai ritirato un messaggio';

  @override
  String get commonMessageRecalled => 'Messaggio ritirato';

  @override
  String get commonReEdit => 'Modifica';

  @override
  String get commonWalletArea => 'Area wallet';

  @override
  String get callIncomingCall => 'Chiamata in arrivo';

  @override
  String get callMissedCall => 'Chiamata persa';

  @override
  String get groupRemoveAdmin => 'Rimuovi admin';

  @override
  String get chatSelectCurrency => 'Seleziona valuta';

  @override
  String get chatSelectEmoji => 'Seleziona emoji';

  @override
  String get chatSelectRedPacketCover => 'Seleziona copertina';

  @override
  String get groupSetAsAdmin => 'Imposta come admin';

  @override
  String get chatVideoPlaybackFailed => 'Riproduzione video fallita';

  @override
  String get groupViewProfile => 'Visualizza profilo';

  @override
  String get favoriteAddLinkComingSoon => 'Funzione aggiungi link in arrivo';

  @override
  String get favoriteNewNoteComingSoon => 'Funzione nuova nota in arrivo';

  @override
  String get qrcodeSaveFeatureComingSoon => 'Funzione salvataggio in arrivo';

  @override
  String get qrcodeShareFeatureComingSoon => 'Funzione condivisione in arrivo';

  @override
  String qrcodeProcessFailed(String error) {
    return 'Elaborazione QR code fallita: $error';
  }

  @override
  String get securityDeviceIdRequired => 'L\'ID del dispositivo è obbligatorio';

  @override
  String securityVerificationStartFailed(String error) {
    return 'Impossibile avviare la verifica: $error';
  }

  @override
  String get securityVerificationFailed => 'Verifica non riuscita';

  @override
  String securityVerificationFailedWithReason(String reason) {
    return 'Verifica non riuscita: $reason';
  }

  @override
  String get securityEmojiMismatchRejected =>
      'Verifica rifiutata: l\'emoji non corrisponde';

  @override
  String get securityWaitingForDeviceAccept =>
      'In attesa che l\'altro dispositivo accetti...';

  @override
  String get securityVerifyDevice => 'Verifica questo dispositivo';

  @override
  String get securityConfirmEmojiMatch =>
      'Conferma che le emoji seguenti siano visualizzate su entrambi i dispositivi, nello stesso ordine';

  @override
  String get securityEmojiDontMatch => 'Non corrispondono';

  @override
  String get securityEmojiMatch => 'Corrispondono';

  @override
  String get securityWaitingForDeviceConfirm =>
      'In attesa della conferma dell\'altro dispositivo...';

  @override
  String get securityVerificationSuccess => 'Verifica riuscita!';

  @override
  String get securityDeviceVerifiedTrusted =>
      'Questo dispositivo è ora verificato e affidabile.';

  @override
  String get securityCompareEmoji =>
      'Confronta le emoji su entrambi i dispositivi';

  @override
  String get securityCompareNumbers =>
      'Confronta i numeri su entrambi i dispositivi';

  @override
  String get commonTryAgain => 'Riprova';

  @override
  String get commonDone => 'Fatto';

  @override
  String get chatExportTitle => 'Esporta chat';

  @override
  String get chatExportSuccess => 'Esportazione riuscita';

  @override
  String chatExportFailed(String error) {
    return 'Esportazione non riuscita: $error';
  }

  @override
  String get chatExportFormat => 'Formato di esportazione';

  @override
  String get chatExportHtmlDesc =>
      'Leggibile in qualsiasi browser con layout in stile';

  @override
  String get chatExportJsonDesc =>
      'Formato dati strutturati leggibile dalla macchina';

  @override
  String get chatExportDateRange => 'Intervallo di date';

  @override
  String get chatExportAll => 'Tutti i messaggi';

  @override
  String get chatExportLastWeek => 'Ultimi 7 giorni';

  @override
  String get chatExportLastMonth => 'Il mese scorso';

  @override
  String get chatExportLast3Months => 'Ultimi 3 mesi';

  @override
  String get chatExportMessageCount => 'Messaggi da esportare';

  @override
  String get chatExportButton => 'Esporta e condividi';

  @override
  String get chatMediaGallery => 'Galleria multimediale';

  @override
  String get chatExportHistory => 'Esporta cronologia chat';

  @override
  String get pdfLoadFailed => 'Impossibile caricare il PDF';

  @override
  String pdfPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get mediaAll => 'Tutto';

  @override
  String get mediaImages => 'Immagini';

  @override
  String get mediaVideos => 'Video';

  @override
  String get mediaFiles => 'File';

  @override
  String get mediaAudio => 'Audio';

  @override
  String mediaItemsCount(int count) {
    return 'Articoli $count';
  }

  @override
  String get mediaNoMediaFound => 'Nessun supporto trovato';

  @override
  String get spacesTitle => 'Comunità';

  @override
  String get spacesCreate => 'Crea comunità';

  @override
  String get spacesJoined => 'Iscritto';

  @override
  String get spacesDiscover => 'Scopri';

  @override
  String get spacesNoJoined => 'Nessuna comunità si è ancora unita';

  @override
  String get spacesExplore => 'Esplora le comunità';

  @override
  String get spacesNoPublic => 'Nessuna comunità pubblica trovata';

  @override
  String get spacesJoin => 'Partecipa';

  @override
  String get spacesSubSpaces => 'Sottocomunità';

  @override
  String get spacesChannels => 'Canali';

  @override
  String spacesMembersCount(int count) {
    return 'Membri $count';
  }

  @override
  String get spacesPublic => 'Pubblico';

  @override
  String get spacesPrivate => 'Privato';

  @override
  String get spacesSuggested => 'Suggerito';

  @override
  String spacesChannelsCount(int count) {
    return 'Canali $count';
  }

  @override
  String get callInCallChat => 'Chat durante la chiamata';

  @override
  String callMessagesCount(int count) {
    return 'Messaggi $count';
  }

  @override
  String get callNoMessagesYet =>
      'Nessun messaggio ancora.\nInvia un messaggio per iniziare.';

  @override
  String get callTypeMessage => 'Digita un messaggio...';

  @override
  String get callYouSender => 'Tu';

  @override
  String get callChatLabel => 'Chatta';

  @override
  String get chatEdited => 'Modificato';

  @override
  String get chatEditHistory => 'Modifica cronologia';

  @override
  String get chatOriginalMessage => 'Originale';

  @override
  String chatEditedAt(String time) {
    return 'Modificato in $time';
  }

  @override
  String get chatViewOnce => 'Visualizza una volta';

  @override
  String get chatViewOncePhoto => 'Visualizza una volta la foto';

  @override
  String get chatViewOnceVideo => 'Guarda una volta il video';

  @override
  String get chatViewOnceViewed => 'Visualizzato';

  @override
  String get chatViewOnceExpired => 'Scaduto';

  @override
  String get chatViewOnceTap => 'Tocca per visualizzare';

  @override
  String get chatAutoFaceBlur => 'Sfocatura automatica del volto';

  @override
  String get chatAutoFaceBlurDesc =>
      'Sfoca automaticamente i volti quando invii foto';

  @override
  String get threadReplyInThread => 'Rispondi nel thread';

  @override
  String threadReplies(int count) {
    return '$count risponde';
  }

  @override
  String get threadReply => '1 risposta';

  @override
  String threadLatestReply(String preview) {
    return 'Ultimo: $preview';
  }

  @override
  String get threadTitle => 'Filo';

  @override
  String get threadReplyPlaceholder => 'Rispondi nel thread...';

  @override
  String threadParticipants(int count) {
    return 'Partecipanti $count';
  }

  @override
  String get voiceRoomTitle => 'Stanza della voce';

  @override
  String get voiceRoomCreate => 'Crea stanza vocale';

  @override
  String get voiceRoomJoin => 'Partecipa';

  @override
  String get voiceRoomLeave => 'Lascia';

  @override
  String get voiceRoomEnd => 'Fine stanza';

  @override
  String get voiceRoomRaiseHand => 'Alza la mano';

  @override
  String get voiceRoomLowerHand => 'Mano inferiore';

  @override
  String get voiceRoomMute => 'Muto';

  @override
  String get voiceRoomUnmute => 'Riattiva';

  @override
  String get voiceRoomHost => 'Ospite';

  @override
  String get voiceRoomSpeakers => 'Altoparlanti';

  @override
  String get voiceRoomListeners => 'Ascoltatori';

  @override
  String get voiceRoomLive => 'VIVI';

  @override
  String get voiceRoomEnded => 'Finito';

  @override
  String get voiceRoomScheduled => 'Programmato';

  @override
  String get voiceRoomApprove => 'Approvare';

  @override
  String get voiceRoomDemote => 'Passa all\'ascoltatore';

  @override
  String voiceRoomHandRaised(String name) {
    return '$name ha alzato la mano';
  }

  @override
  String get voiceRoomName => 'Nome della stanza';

  @override
  String get voiceRoomTopic => 'Argomento (facoltativo)';

  @override
  String get voiceRoomNoActive => 'Nessuna stanza vocale attiva';

  @override
  String get voiceRoomConnecting => 'Connessione...';

  @override
  String get usernameTitle => 'Nome utente';

  @override
  String get usernameSet => 'Imposta il nome utente';

  @override
  String get usernameChange => 'Cambia nome utente';

  @override
  String get usernamePlaceholder => 'Inserisci il nome utente';

  @override
  String get usernameAvailable => 'Nome utente disponibile';

  @override
  String get usernameUnavailable => 'Nome utente già preso';

  @override
  String get usernameInvalid =>
      '3-30 caratteri, lettere minuscole, numeri, trattino basso. Deve iniziare con una lettera.';

  @override
  String get usernameReserved => 'Questo nome utente è riservato';

  @override
  String get usernameSaved => 'Nome utente salvato';

  @override
  String get usernameSearchHint => 'Cerca per @nomeutente';

  @override
  String get ensName => 'Nome dell\'ENS';

  @override
  String get ensLinked => 'Collegato all\'ENS';

  @override
  String get ensResolving => 'Risoluzione dell\'ENS...';

  @override
  String get ensNotFound => 'Nome ENS non trovato';

  @override
  String get tokenGateTitle => 'Porta dei gettoni';

  @override
  String get tokenGateEnable => 'Abilita token gate';

  @override
  String get tokenGateDisable => 'Disabilita token gate';

  @override
  String get tokenGateAddRule => 'Aggiungi regola';

  @override
  String get tokenGateRemoveRule => 'Rimuovi regola';

  @override
  String get tokenGateContractAddress => 'Indirizzo del contratto';

  @override
  String get tokenGateMinBalance => 'Saldo minimo';

  @override
  String get tokenGateTokenId => 'ID token (ERC-1155)';

  @override
  String get tokenGateChainId => 'Identificativo della catena';

  @override
  String get tokenGateVerifying => 'Verifica delle disponibilità di token...';

  @override
  String get tokenGateVerified => 'Verifica superata';

  @override
  String get tokenGateDenied => 'Non soddisfi i requisiti del token';

  @override
  String get tokenGateOperatorAnd => 'Deve soddisfare TUTTE le regole';

  @override
  String get tokenGateOperatorOr => 'Deve soddisfare QUALSIASI regola';

  @override
  String get tokenGateRuleErc20 => 'Gettone ERC-20';

  @override
  String get tokenGateRuleErc721 => 'NFT (ERC-721)';

  @override
  String get tokenGateRuleErc1155 => 'Multi-token (ERC-1155)';

  @override
  String get tokenGateRuleNative => 'Gettone nativo';

  @override
  String get tokenGateSaved => 'Porta token salvata';

  @override
  String get tokenGateEnableDescription =>
      'Richiedi ai membri di conservare i token per aderire';

  @override
  String get tokenGateOperator => 'Logica delle regole';

  @override
  String get tokenGateRules => 'Regole';

  @override
  String get tokenGateSymbol => 'Simbolo (facoltativo)';

  @override
  String get tokenGateChain => 'Catena';

  @override
  String get tokenGateTokenStandard => 'Norma sui gettoni';

  @override
  String get tokenGateDenialMessage => 'Messaggio di rifiuto';

  @override
  String get tokenGateDenialMessageHint =>
      'Messaggio mostrato quando la verifica fallisce';

  @override
  String get tokenGateVerifyTitle => 'Verifica dei token';

  @override
  String get tokenGateVerifyPassed => 'Verifica superata';

  @override
  String get tokenGateVerifyFailed => 'Verifica non riuscita';

  @override
  String get tokenGateRetryVerify => 'Riprova';

  @override
  String get tokenGateRequired => 'Obbligatorio';

  @override
  String get tokenGateYourBalance => 'Il tuo equilibrio';

  @override
  String get tokenGateRulesActive => 'regole attive';

  @override
  String get tokenGateDisabled => 'Disabilitato';

  @override
  String get ensNotBound => 'Non vincolato';

  @override
  String get liveLocation => 'Posizione in tempo reale';

  @override
  String get stopLiveLocation => 'Interrompi la condivisione';

  @override
  String get startLiveLocation => 'Inizia a condividere';

  @override
  String get selectDuration => 'Seleziona Durata';

  @override
  String get groupChatFiles => 'File di chat';

  @override
  String get groupLinks => 'Collegamenti';

  @override
  String get groupNoLinks => 'Nessun collegamento ancora';

  @override
  String get chatBackground => 'Sfondo della chat';

  @override
  String get solidColors => 'Colori solidi';

  @override
  String get gradients => 'Gradienti';

  @override
  String get defaultBackground => 'Predefinito';

  @override
  String get settingsFontSizeSlider => 'Dimensione carattere';

  @override
  String get autoDownload => 'Download automatico';

  @override
  String get images => 'Immagini';

  @override
  String get voice => 'Voce';

  @override
  String get video => 'Video';

  @override
  String get files => 'File';

  @override
  String get mobileData => 'Dati mobili';

  @override
  String get roaming => 'Vagabondaggio';

  @override
  String get storageManagement => 'Stoccaggio';

  @override
  String get totalUsage => 'Utilizzo totale';

  @override
  String get cache => 'Cache';

  @override
  String get other => 'Altro';

  @override
  String get clearCache => 'Cancella cache';

  @override
  String get cacheCleared => 'Cache cancellata';

  @override
  String get clearCacheFailed => 'Impossibile svuotare la cache';

  @override
  String get confirmClearCache => 'Cancellare tutti i dati della cache?';

  @override
  String get mapView => 'Visualizzazione mappa';

  @override
  String liveLocationSharingCount(int count) {
    return '$count persone che condividono la posizione';
  }

  @override
  String get minutes15 => '15 minuti';

  @override
  String get minutes30 => '30 minuti';

  @override
  String get hour1 => '1 ora';

  @override
  String get hours8 => '8 ore';

  @override
  String get personalCard => 'Carta personale';

  @override
  String get downloadFailed => 'Download non riuscito';

  @override
  String get locationExpired => 'Scaduto';

  @override
  String secondsRemaining(int count) {
    return '$count secondi';
  }

  @override
  String minutesRemaining(int count) {
    return '$count minuti';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '$hours ore $minutes minuti';
  }

  @override
  String get favoriteMessages => 'Preferiti';

  @override
  String get linksCopied => 'Collegamento copiato';

  @override
  String get noLinksFound => 'Nessun collegamento trovato';

  @override
  String get roomStorageRanking => 'Classifica dello stoccaggio delle stanze';

  @override
  String get downloadComplete => 'Scaricamento completato';

  @override
  String get downloading => 'Download in corso...';

  @override
  String get draftSaved => 'Bozza salvata';

  @override
  String get voiceRecording => 'Registrazione vocale';

  @override
  String get searchLocation => 'Cerca posizione';

  @override
  String get tapToSearch => 'Tocca per cercare';

  @override
  String get settingsThisDevice => 'Questo dispositivo';

  @override
  String get settingsJustNow => 'Proprio adesso';

  @override
  String get settingsDeviceId => 'ID del dispositivo';

  @override
  String get settingsStatus => 'Stato';

  @override
  String get settingsLastActive => 'Ultimo attivo';

  @override
  String get settingsIpAddress => 'Indirizzo IP';

  @override
  String get settingsRenameDevice => 'Rinominare il dispositivo';

  @override
  String get settingsDeviceNameHint => 'Inserisci il nome del dispositivo';

  @override
  String get settingsDeviceRenamed => 'Dispositivo rinominato';

  @override
  String get settingsRenameFailed => 'Rinomina non riuscita';

  @override
  String get settingsRemoteLogout => 'Disconnessione remota';

  @override
  String settingsRemoteLogoutConfirm(String deviceName) {
    return 'Sei sicuro di voler uscire da \"$deviceName\"? Questa azione non può essere annullata.';
  }

  @override
  String get settingsDeviceLoggedOut => 'Dispositivo disconnesso';

  @override
  String get settingsLogoutFailed => 'Disconnessione non riuscita';

  @override
  String get settingsLogout => 'Esci';

  @override
  String get settingsVerifyIdentity => 'Verificare l\'identità';

  @override
  String get settingsEnterPasswordToConfirm =>
      'Inserisci la tua password per confermare questa azione.';

  @override
  String get scheduledSendTitle => 'Pianifica il messaggio';

  @override
  String get scheduledSendInOneHour => 'Tra 1 ora';

  @override
  String get scheduledSendTonight => 'Stasera (20:00)';

  @override
  String get scheduledSendTomorrowMorning => 'Domani mattina (9:00)';

  @override
  String get scheduledSendCustom => 'Scegli una data e un\'ora';

  @override
  String get scheduledMessageLabel => 'Programmato';

  @override
  String get scheduledMessageCancel => 'Annulla il messaggio programmato';

  @override
  String get chatLockTitle => 'Blocco chat';

  @override
  String get chatLockEnable => 'Blocca questa chat';

  @override
  String get chatLockDisable => 'Sblocca questa chat';

  @override
  String get chatLockDescription =>
      'Le chat bloccate richiedono la verifica biometrica o PIN per essere aperte';

  @override
  String get chatLockVerifyTitle => 'Chat bloccata';

  @override
  String get chatLockVerifySubtitle => 'Verifica per accedere a questa chat';

  @override
  String get chatLockVerifyFailed => 'Verifica non riuscita';

  @override
  String get chatLockEnabled => 'Chat bloccata';

  @override
  String get chatLockDisabled => 'Chat sbloccata';

  @override
  String get chatLockPinTitle => 'Inserisci il PIN';

  @override
  String get chatLockPinSetTitle => 'Imposta il PIN';

  @override
  String get chatLockPinConfirmTitle => 'Conferma il PIN';

  @override
  String get chatLockPinMismatch => 'Il PIN non corrisponde';

  @override
  String get chatLockUseBiometric => 'Usa la biometria';

  @override
  String get chatLockUsePin => 'Utilizza il PIN';

  @override
  String get mediaEditorUndo => 'Annulla';

  @override
  String get mediaEditorRedo => 'Rifare';

  @override
  String get mediaEditorCrop => 'Ritaglia';

  @override
  String get mediaEditorFilter => 'Filtra';

  @override
  String get mediaEditorDraw => 'Disegna';

  @override
  String get mediaEditorText => 'Testo';

  @override
  String get aiAssistant => 'Assistente AI';

  @override
  String get aiAssistantWelcome =>
      'Ciao! Sono l\'Assistente AI N42. Come posso aiutarla?';

  @override
  String get aiAssistantNotConfigured => 'Servizio AI non configurato';

  @override
  String get aiAssistantSettings => 'Impostazioni dell\'IA';

  @override
  String get aiAssistantClearHistory => 'Cancella la cronologia della chat';

  @override
  String get aiAssistantClearHistoryConfirm =>
      'Sei sicuro di voler cancellare tutta la cronologia chat dell\'IA?';

  @override
  String get aiAssistantStopGenerating => 'Smetti di generare';

  @override
  String get aiAssistantModel => 'Modello';

  @override
  String get aiAssistantTemperature => 'Temperatura';

  @override
  String get aiAssistantMaxTokens => 'Token massimi';

  @override
  String get aiAssistantContextWindow => 'Finestra di contesto';

  @override
  String get aiAssistantServiceStatus => 'Stato del servizio';

  @override
  String get aiAssistantAvailable => 'Disponibile';

  @override
  String get aiAssistantUnavailable => 'Non disponibile';

  @override
  String get aiSummarize => 'Riepilogo dell\'IA';

  @override
  String aiSummarizeUnread(int count) {
    return 'Riepiloga i messaggi $count non letti';
  }

  @override
  String get aiSummarizeLoading => 'Riassumendo...';

  @override
  String get aiSummarizeError => 'Impossibile riassumere';

  @override
  String get aiRewrite => 'Riscrittura dell\'intelligenza artificiale';

  @override
  String get aiRewriteFormal => 'Formale';

  @override
  String get aiRewriteCasual => 'Casuale';

  @override
  String get aiRewritePlayful => 'Giocoso';

  @override
  String get aiRewriteProfessional => 'Professionale';

  @override
  String get aiRewriteAccept => 'Utilizzare';

  @override
  String get aiRewriteCancel => 'Annulla';

  @override
  String get aiRewriteLoading => 'Riscrittura...';

  @override
  String get aiLinkSummary => 'Riepilogo dell\'IA';

  @override
  String get aiLinkSummaryAnalyzing => 'Analizzando...';

  @override
  String get chatFolderManagement => 'Gestisci cartelle';

  @override
  String get chatFolderSystem => 'Cartelle di sistema';

  @override
  String get chatFolderCustom => 'Cartelle personalizzate';

  @override
  String get chatFolderEmpty => 'Nessuna cartella personalizzata ancora';

  @override
  String get chatFolderCreate => 'Crea cartella';

  @override
  String get chatFolderEdit => 'Modifica cartella';

  @override
  String get chatFolderNameHint => 'Nome della cartella';

  @override
  String get chatFolderAll => 'Tutto';

  @override
  String get chatFolderUnread => 'Non letto';

  @override
  String get chatFolderPersonal => 'Personale';

  @override
  String get chatFolderGroups => 'Gruppi';

  @override
  String get chatFolderChannels => 'Canali';

  @override
  String get chatFolderMuted => 'Disattivato';

  @override
  String get storyAddMusic => 'Aggiungi musica';

  @override
  String get storyChangeMusic => 'Cambia musica';

  @override
  String get storyBackgroundMusic => 'Musica di sottofondo';

  @override
  String get storyMusicPreview => 'Anteprima (max 15s)';

  @override
  String get storyChooseFromDevice => 'Scegli da Dispositivo';

  @override
  String get storyUseThisMusic => 'Usa questa musica';

  @override
  String get authPasskeyNotSupported =>
      'La passkey non è supportata su questo dispositivo';

  @override
  String get authPasskeyRegister => 'Registra la chiave di accesso';

  @override
  String get authPasskeyNoRegistered => 'Nessuna passkey registrata';

  @override
  String get authPasskeyRegisterHint =>
      'Registra una passkey per questo account. L\'accesso con passkey autonomo verrà abilitato in seguito.';

  @override
  String get authPasskeyNameYours => 'Assegna un nome alla tua passkey';

  @override
  String get authPasskeyRegistered => 'Passkey salvata su questo account';

  @override
  String get authPasskeyDeleted => 'Passkey rimossa da questo account';

  @override
  String authPasskeyDeleteConfirm(String name) {
    return 'Eliminare la chiave di accesso \"$name\"? Sarà necessario registrarlo nuovamente prima di utilizzare l\'accesso tramite passkey in un secondo momento.';
  }

  @override
  String get momentVisibilityPublic => 'Pubblico';

  @override
  String get momentVisibilityPrivate => 'Privato';

  @override
  String get momentVisibilityPartial => 'Amici selezionati';

  @override
  String get momentVisibilityExcluded => 'Escludi alcuni amici';

  @override
  String momentUserMoments(String userName) {
    return 'I momenti di $userName';
  }

  @override
  String get momentForwardTo => 'Inoltra a';

  @override
  String get momentForwardSuccess => 'Inoltrato con successo';

  @override
  String get momentSelectFriends => 'Seleziona Amici';

  @override
  String get momentSelectTags => 'Seleziona per tag';

  @override
  String momentSelectedCount(int count) {
    return 'Selezionato ($count)';
  }

  @override
  String get momentNoMomentsYet => 'Nessun momento ancora';

  @override
  String get momentForwardMoment => 'Momento in avanti';

  @override
  String get momentAddComment => 'Aggiungi un commento...';

  @override
  String momentForwardContent(String content) {
    return '[Momento] $content';
  }

  @override
  String get momentDeleteMoment => 'Elimina momento';

  @override
  String get momentDeleteConfirm =>
      'Sei sicuro di voler eliminare questo momento?';

  @override
  String get momentComment => 'Commento';

  @override
  String get momentWriteComment => 'Scrivi un commento...';

  @override
  String get momentLike => 'Mi piace';

  @override
  String get momentUnlike => 'A differenza';

  @override
  String get momentForward => 'Avanti';

  @override
  String get momentDelete => 'Elimina';

  @override
  String get momentReply => 'risposta';

  @override
  String get momentMoment => 'Momento';

  @override
  String momentLikesCount(int count) {
    return 'A $count piace';
  }

  @override
  String momentCommentsCount(int count) {
    return '$count commenti';
  }

  @override
  String get momentNoComments => 'Nessun commento ancora';

  @override
  String get momentFailedToLoad => 'Impossibile caricare l\'immagine';

  @override
  String momentReplyTo(String userName) {
    return 'Rispondi a $userName...';
  }

  @override
  String get momentNoConversations => 'Nessuna conversazione';

  @override
  String get momentJustNow => 'proprio adesso';

  @override
  String momentMinutesAgo(int count) {
    return '${count}m fa';
  }

  @override
  String momentHoursAgo(int count) {
    return '${count}h fa';
  }

  @override
  String momentDaysAgo(int count) {
    return '${count}d fa';
  }

  @override
  String get chatGroupAnnouncementHint => 'Inserisci l\'annuncio del gruppo';

  @override
  String get chatGroupAnnouncementEmpty => 'Nessun annuncio';

  @override
  String get chatEditNickname => 'Modifica soprannome';

  @override
  String get chatNicknameHint => 'Inserisci il tuo nickname in questo gruppo';

  @override
  String get contactAddPhoneHint => 'Inserisci il numero di telefono';

  @override
  String get contactNotesHint => 'Aggiungi note su questo contatto';

  @override
  String get reportTitle => 'Rapporto';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonHarassment => 'Molestie';

  @override
  String get reportReasonFraud => 'Frode';

  @override
  String get reportReasonOther => 'Altro';

  @override
  String get reportSubmitted => 'Rapporto inviato';

  @override
  String get reportDescription => 'Descrizione aggiuntiva (facoltativa)';

  @override
  String get qrcodeSaved => 'Codice QR salvato nell\'album';

  @override
  String get chatSendRedPacketInChat =>
      'Per favore invia il pacchetto rosso in chat';

  @override
  String get commonSaveFailed => 'Salvataggio non riuscito';

  @override
  String get reportSelectReason => 'Seleziona un motivo';

  @override
  String get gameCenter => 'Giochi';

  @override
  String get gameHighScore => 'Miglior';

  @override
  String get gameScore => 'Punteggio';

  @override
  String get gameOver => 'Partita finita';

  @override
  String get gamePlayAgain => 'Gioca ancora';

  @override
  String get gameLeaderboard => 'Classifica';

  @override
  String get gamePause => 'In pausa';

  @override
  String get gameResume => 'Tocca per riprendere';

  @override
  String get gameConfirmExit => 'Uscire dal gioco?';

  @override
  String get gameNoScores => 'Nessun punteggio';

  @override
  String get game2048 => '2048';

  @override
  String get game2048Desc => 'Unisci le tessere fino a 2048';

  @override
  String get gameBlockDrop => 'Blocca la caduta';

  @override
  String get gameBlockDropDesc => 'Fai cadere e cancella le righe';

  @override
  String get gameMinesweeper => 'Campo minato';

  @override
  String get gameMinesweeperDesc => 'Trova tutte le celle sicure';

  @override
  String get gameMatch3 => 'Partita 3';

  @override
  String get gameMatch3Desc => 'Abbina 3 o più gemme';

  @override
  String get gameMinesweeperEasy => 'Facile';

  @override
  String get gameMinesweeperMedium => 'Medio';

  @override
  String get gameMinesLeft => 'Mine rimaste';

  @override
  String get gameTimeLeft => 'Tempo';

  @override
  String get gameLevel => 'Livello';

  @override
  String get gameNext => 'Prossimo';

  @override
  String get gameBestTime => 'Miglior tempo';

  @override
  String get gameNewRecord => 'Nuovo record!';

  @override
  String get gameLines => 'Righe';

  @override
  String get storyMyStory => 'La mia storia';

  @override
  String get storageSmartCleanup => 'Pulizia intelligente';

  @override
  String get storageOldMediaFiles => 'Vecchi file multimediali';

  @override
  String get storageLargeFiles => 'File di grandi dimensioni';

  @override
  String get storageAppCache => 'Cache dell\'app';

  @override
  String get storageSettings => 'Impostazioni di archiviazione';

  @override
  String get storageAutoCleanup => 'Pulizia automatica';

  @override
  String storageAutoCleanupDesc(int days) {
    return 'Pulisci automaticamente i file più vecchi di $days giorni';
  }

  @override
  String get storageCleanupPeriod => 'Periodo di pulizia';

  @override
  String get storagePreserveThumbnails => 'Conserva le miniature';

  @override
  String get storagePreserveThumbnailsDesc =>
      'Conserva le miniature delle immagini durante la pulizia';

  @override
  String get storageWarningHigh =>
      'L\'utilizzo dello spazio di archiviazione è elevato. Prendi in considerazione la possibilità di ripulire i vecchi file.';

  @override
  String get storageWarningCritical =>
      'Lo spazio di archiviazione è estremamente basso. Pulisci per liberare spazio.';

  @override
  String storageFreed(String size, int count) {
    return '$size liberato (file $count)';
  }

  @override
  String storageDays(int days) {
    return '$days giorni';
  }

  @override
  String storageViewAllRooms(int count) {
    return 'Visualizza tutte le camere $count';
  }

  @override
  String get storageNoFiles => 'Nessun file trovato';

  @override
  String get storageFilePinned => 'Appuntato';

  @override
  String storageDeleteSelected(int count) {
    return 'Eliminare i file $count selezionati? Possono essere scaricati nuovamente dal server.';
  }

  @override
  String get backupRestore => 'Backup e ripristino';

  @override
  String get backupCreate => 'Crea backup';

  @override
  String get backupCreateDesc =>
      'Esegui il backup delle impostazioni e delle chiavi di crittografia. I messaggi verranno ripristinati dal server dopo il nuovo accesso.';

  @override
  String get backupIncludeKeys => 'Includere chiavi di crittografia';

  @override
  String get backupIncludeKeysDesc =>
      'Necessario per leggere i messaggi crittografati';

  @override
  String get backupPasswordProtect => 'Proteggi con password';

  @override
  String get backupEnterPassword => 'Inserisci la password di backup';

  @override
  String get backupHistory => 'Cronologia del backup';

  @override
  String get backupNoBackups => 'Nessun backup ancora';

  @override
  String get backupRestore2 => 'Ripristina';

  @override
  String get backupDelete => 'Elimina';

  @override
  String get backupDeleteConfirm =>
      'Sei sicuro di voler eliminare questo backup? Questa operazione non può essere annullata.';

  @override
  String get backupRestoreFromFile => 'Ripristina da file';

  @override
  String get backupRestoreFromFileDesc =>
      'Importa un file .n42backup da un altro dispositivo o da un backup precedente.';

  @override
  String get backupChooseFile => 'Scegli File di backup';

  @override
  String get backupRestoring => 'Ripristino...';

  @override
  String backupCreated(int rooms, int messages) {
    return 'Backup creato: stanze $rooms, messaggi $messages';
  }

  @override
  String backupRestored(int settings, int rooms) {
    return 'Impostazioni $settings ripristinate dalle stanze $rooms';
  }

  @override
  String backupFailed(String error) {
    return 'Backup non riuscito: $error';
  }

  @override
  String get backupPasswordRequired => 'Questo backup è protetto da password';

  @override
  String get blocGroupNotFound => 'Gruppo non trovato';

  @override
  String blocGroupMembersInvited(int count) {
    return 'Membri $count invitati';
  }

  @override
  String get blocGroupMemberRemoved => 'Membro rimosso';

  @override
  String get blocGroupAdminRemoved => 'Amministratore rimosso';

  @override
  String get blocGroupLeft => 'Lasciato il gruppo';

  @override
  String get blocGroupDisbanded => 'Gruppo sciolto';

  @override
  String get blocGroupJoined => 'Mi sono unito al gruppo';

  @override
  String get blocGroupInviteDeclined => 'Invito rifiutato';

  @override
  String get blocGroupTokenGateUpdated => 'Porta token aggiornata';

  @override
  String get blocTransferProcessing => 'Trasferimento in elaborazione...';

  @override
  String get blocTransferCancelled => 'Trasferimento annullato';

  @override
  String get blocTransferFailed => 'Trasferimento non riuscito';

  @override
  String get blocPaymentProcessing => 'Elaborazione del pagamento...';

  @override
  String get blocPaymentFailed => 'Pagamento non riuscito';

  @override
  String get groupMaxMembers => 'Limite membri';

  @override
  String get groupMaxMembersUnlimited => 'Illimitato';

  @override
  String get groupMaxMembersHint =>
      'Inserisci il limite (lascia vuoto per illimitato)';

  @override
  String get groupMaxMembersUpdated => 'Limite membri aggiornato';

  @override
  String get groupFull => 'Il gruppo è al completo';

  @override
  String get groupChannels => 'Canali tematici';

  @override
  String get groupChannelsEmpty => 'Nessun canale ancora';

  @override
  String get groupChannelsCount => 'canali';

  @override
  String get groupChannelCreate => 'Nuovo canale';

  @override
  String get groupChannelName => 'Nome del canale';

  @override
  String get groupChannelTopic => 'Argomento del canale (facoltativo)';

  @override
  String get groupChannelDelete => 'Elimina canale';

  @override
  String get groupChannelDeleteConfirm =>
      'Eliminare questo canale? Tutti i messaggi andranno persi.';

  @override
  String get groupBotSettings => 'Impostazioni del bot';

  @override
  String get groupBotEnabled => 'Abilita Bot';

  @override
  String get groupBotWelcomeMessage => 'Modello di messaggio di benvenuto';

  @override
  String get groupBotWelcomeHint =>
      'Utilizza \"nome\" come segnaposto per il nome del nuovo membro';

  @override
  String get groupBotConfigUpdated => 'Impostazioni del bot aggiornate';

  @override
  String get groupContentFilter => 'Filtro contenuti';

  @override
  String get groupContentFilterEnabled => 'Abilita filtro parole chiave';

  @override
  String get groupContentFilterReplace => 'Sostituisci con ***';

  @override
  String get groupContentFilterHide => 'Nascondi messaggio';

  @override
  String get groupContentFilterAddWord => 'Aggiungi parola chiave';

  @override
  String get groupContentFilterUpdated => 'Filtro contenuti aggiornato';

  @override
  String get chatSlashCommands => 'Comandi';

  @override
  String get chatCommandPoll => '/poll: crea un sondaggio';

  @override
  String get chatCommandAnnounce => '/announce: invia un annuncio';

  @override
  String get chatCommandWelcome =>
      '/welcome — Imposta il messaggio di benvenuto';

  @override
  String get chatReportMessage => 'Rapporto';

  @override
  String get chatReportReason => 'Motivo della segnalazione';

  @override
  String get chatReportSpam => 'Spam';

  @override
  String get chatReportHarassment => 'Molestie';

  @override
  String get chatReportInappropriate => 'Contenuti inappropriati';

  @override
  String get chatReportOther => 'Altro';

  @override
  String get chatReportSuccess => 'Rapporto inviato';

  @override
  String get spacesName => 'Nome della comunità';

  @override
  String get spacesNameHint => 'ad es. Commercianti di criptovalute';

  @override
  String get spacesNameRequired => 'Il nome è obbligatorio';

  @override
  String get spacesDescription => 'Descrizione';

  @override
  String get spacesDescriptionHint => 'Di cosa tratta questa comunità?';

  @override
  String get spacesType => 'Tipo di comunità';

  @override
  String get spacesPublicDesc => 'Chiunque può scoprire e partecipare';

  @override
  String get spacesPrivateDesc => 'Possono partecipare solo i membri invitati';

  @override
  String get spacesNotFound => 'Comunità non trovata';

  @override
  String get spacesSearch => 'Cerca comunità...';

  @override
  String get spacesMembers => 'Membri';

  @override
  String get spacesNoChannels => 'Nessun canale ancora';

  @override
  String get spacesLeave => 'Lascia la comunità';

  @override
  String spacesLeaveConfirm(String name) {
    return 'Sei sicuro di voler lasciare \"$name\"?';
  }

  @override
  String get spacesDelete => 'Elimina comunità';

  @override
  String spacesDeleteConfirm(String name) {
    return 'Ciò eliminerà permanentemente \"$name\" e tutti i suoi canali. Questa azione non può essere annullata.';
  }

  @override
  String get spacesCreateChannel => 'Aggiungi canale';

  @override
  String get spacesChannelName => 'Nome del canale';

  @override
  String get spacesChannelTopic => 'Argomento (facoltativo)';

  @override
  String get spacesDeleteChannel => 'Elimina canale';

  @override
  String spacesDeleteChannelConfirm(String name) {
    return 'Sei sicuro di voler eliminare \"#$name\"?';
  }

  @override
  String get spacesEditName => 'Modifica nome';

  @override
  String get spacesEditDescription => 'Modifica descrizione';

  @override
  String spacesViewAllMembers(int count) {
    return 'Visualizza tutti i membri $count';
  }

  @override
  String spacesKickMemberTitle(String name) {
    return 'Calcia $name';
  }

  @override
  String spacesBanMemberTitle(String name) {
    return 'Divieto $name';
  }

  @override
  String get spacesPromoteAdmin => 'Promuovi ad amministratore';

  @override
  String get spacesDemoteAdmin => 'Rimuovi amministratore';

  @override
  String get spacesInviteMember => 'Invita membro';

  @override
  String get spacesInviteMemberUserId =>
      'ID utente (ad esempio @user:server.com)';

  @override
  String get spacesSave => 'Salva';

  @override
  String get settingsScreenshotProtection => 'Protezione degli screenshot';

  @override
  String get settingsScreenshotProtectionDesc =>
      'Impedisci screenshot e registrazione dello schermo';

  @override
  String get chatSelfDestructTimer => 'Autodistruzione';

  @override
  String get chatTimerPickerTitle => 'Temporizzatore di autodistruzione';

  @override
  String get chatTimerOff => 'Spento';

  @override
  String get onChainNotificationsTitle => 'Eventi on-chain';

  @override
  String get onChainMarkAllRead => 'Segna tutto come letto';

  @override
  String get onChainNoNotifications => 'Nessun evento on-chain ancora';

  @override
  String get onChainNoNotificationsDesc =>
      'Gli eventi dai canali iscritti appariranno qui';

  @override
  String get onChainViewDetails => 'Visualizza dettagli';

  @override
  String get chatCommandHelp => '/help — Mostra tutti i comandi';

  @override
  String get chatCommandPrice => '/price — Ottieni il prezzo del token';

  @override
  String get chatCommandBalance => '/balance — Mostra il saldo del portafoglio';

  @override
  String get chatCommandChains => '/chains — Elenca 236+ reti supportate';

  @override
  String get chatMiniApps => 'App';

  @override
  String get miniAppMarketTitle => 'Mini App';

  @override
  String get miniAppCategoryAll => 'Tutte';

  @override
  String get miniAppSearch => 'Cerca app...';

  @override
  String get miniAppFeatured => 'In evidenza';

  @override
  String get miniAppAllApps => 'Tutte le App';

  @override
  String get miniAppNoResults => 'Nessuna app trovata';

  @override
  String get slideToPayLabel => '→→→  Scorri per confermare';

  @override
  String get slideToPayConfirming => 'Confermando...';

  @override
  String get redPacketBestLuck => 'Miglior fortuna';

  @override
  String get redPacketBestLuckCongrats =>
      'Miglior fortuna! Hai ottenuto di più!';

  @override
  String redPacketStats(int claimed, int total) {
    return '$claimed / $total riscattati';
  }

  @override
  String get redPacketStatsTotal => 'totale';

  @override
  String redPacketGrabbedViral(String amount, String token) {
    return '🧧 Ha ricevuto una busta rossa • $amount $token';
  }

  @override
  String get web3SearchHint => '@matrix:id  •  indirizzo 0x  •  name.eth';

  @override
  String get web3SearchPlaceholder => 'Cerca per ID, wallet o ENS...';

  @override
  String get web3WalletAddress => 'Indirizzo wallet';

  @override
  String get web3AddressCopied => 'Indirizzo copiato';

  @override
  String get web3Copy => 'Copia';

  @override
  String get web3SendMessage => 'Invia messaggio';

  @override
  String get web3SendToWallet => 'Messaggio al wallet';

  @override
  String get web3WalletOnlyHint =>
      'Questo indirizzo non ha ancora un account N42. Il messaggio verrà consegnato quando si unisce.';

  @override
  String get web3NftAvatar => 'Avatar NFT';

  @override
  String get web3ResolveFailed => 'Risoluzione identità fallita';

  @override
  String web3EnsNotFound(String name) {
    return 'Nome ENS \"$name\" non trovato';
  }

  @override
  String get web3NoN42AccountTitle => 'Nessun account N42';

  @override
  String get web3NoN42AccountDesc =>
      'Questo indirizzo di portafoglio non ha ancora un account N42. Puoi condividere con loro il tuo link di invito N42 per iniziare.';

  @override
  String get web3ShareInvite => 'Condividi invito';

  @override
  String get nftPickerTitle => 'Seleziona avatar NFT';

  @override
  String get nftPickerTabPopular => 'Popolari';

  @override
  String get nftPickerTabCustom => 'Personalizzato';

  @override
  String get nftPickerChain => 'Catena';

  @override
  String get nftPickerContract => 'Indirizzo del contratto';

  @override
  String get nftPickerTokenId => 'Identificativo del gettone';

  @override
  String get nftPickerVerifyOwnership => 'Verifica proprietà e anteprima';

  @override
  String get nftPickerUseAsAvatar => 'Usa come avatar';

  @override
  String get nftPickerPreview => 'Anteprima';

  @override
  String get nftPickerNotOwned => 'Non possiedi questo NFT';

  @override
  String get nftPickerInvalidTokenId => 'ID token non valido';

  @override
  String get nftPickerEnterBoth =>
      'Inserisci l\'indirizzo del contratto e l\'ID del token';

  @override
  String get nftPickerInfoTitle => 'Avatar NFT — Verificato on-chain';

  @override
  String get nftPickerInfoDesc =>
      'Associa un NFT che possiedi come avatar. Chiunque può verificare la proprietà sulla catena. Visualizzato con un anello d\'oro su N42.';

  @override
  String get nftPickerPopularCollections => 'Collezioni popolari';

  @override
  String get nftPickerWalletHint =>
      'Connetti il tuo wallet N42 per scoprire automaticamente i tuoi NFT su 236+ chain.';

  @override
  String get profileBindNftAvatar => 'Associa l\'avatar NFT';

  @override
  String get profileChangeAvatar => 'Cambia avatar';

  @override
  String get groupTopics => 'Argomenti';

  @override
  String get groupTopicsEmpty => 'Nessun argomento ancora';

  @override
  String get syncInProgress =>
      'Sincronizzazione della cronologia dei messaggi...';

  @override
  String get recoveryKeyReminderTitle => 'Proteggi i tuoi messaggi';

  @override
  String get recoveryKeyReminderDesc =>
      'Crea una chiave di ripristino per sincronizzare in modo sicuro i messaggi crittografati su tutti i dispositivi';

  @override
  String get recoveryKeySetupNow => 'Configura ora';

  @override
  String get recoveryKeyRemindLater => 'Ricordamelo più tardi';

  @override
  String get channelReadOnly =>
      'Solo gli amministratori possono pubblicare in questo canale';

  @override
  String get channelSubscribers => 'abbonati';

  @override
  String get channelVerified => 'Canale verificato';

  @override
  String get redPacketHistory => 'Storia del pacchetto rosso';

  @override
  String get redPacketSent => 'Inviato';

  @override
  String get redPacketReceived => 'Ricevuto';

  @override
  String get redPacketExpired => 'Scaduto';

  @override
  String get redPacketClaimed => 'Reclamato';

  @override
  String get redPacketInsufficientBalance => 'Equilibrio insufficiente';

  @override
  String selfDestructCountdown(String time) {
    return 'Autodistruzione in $time';
  }

  @override
  String get messageDestroyed => 'Messaggio distrutto';

  @override
  String miniAppPermissionDenied(String permission) {
    return 'Autorizzazione negata: $permission';
  }

  @override
  String get aiSuggestionGasFee => 'Cos\'è la tassa sul gas?';

  @override
  String get aiSuggestionDefi => 'Guida per principianti alla DeFi';

  @override
  String get aiSuggestionSecurity =>
      'Come verificare la sicurezza del contratto';

  @override
  String get aiSuggestionBridge => 'Collegamento a catena incrociata';

  @override
  String get channelDiscoverTitle => 'Scopri i canali';

  @override
  String get channelDiscoverSearch => 'Cerca canali...';

  @override
  String get channelJoin => 'Partecipa';

  @override
  String get channelJoined => 'Iscritto';

  @override
  String get channelCategory => 'Categoria';

  @override
  String slowModeCooldown(int seconds) {
    return 'Modalità lenta: attendere ${seconds}s';
  }

  @override
  String get addressCopyAction => 'Copia indirizzo';

  @override
  String get addressSendMessage => 'Invia messaggio';

  @override
  String get addressViewProfile => 'Visualizza profilo';

  @override
  String get sendToAddress => 'Invia all\'indirizzo del portafoglio';

  @override
  String get blocAuthSendVerificationCodeFailed =>
      'Impossibile inviare il codice di verifica';

  @override
  String get blocAuthServerNoEmailPasswordReset =>
      'Questo server non supporta la reimpostazione della password e-mail';

  @override
  String get blocAuthResetPasswordFailed =>
      'Impossibile reimpostare la password';

  @override
  String get blocAuthChangePasswordFailed =>
      'Impossibile modificare la password';

  @override
  String get blocAuthOldPasswordWrong => 'Password attuale errata';

  @override
  String get blocAuthLoginCancelled => 'Accesso annullato';

  @override
  String get blocAuthGoogleLoginFailed => 'Accesso a Google non riuscito';

  @override
  String get blocAuthAppleLoginFailed => 'Accesso Apple non riuscito';

  @override
  String get blocAuthSsoLoginFailed => 'Accesso SSO non riuscito';

  @override
  String get blocAuthFacebookLoginFailed => 'Accesso a Facebook non riuscito';

  @override
  String get blocAuthTwitterLoginFailed => 'Accesso a Twitter non riuscito';

  @override
  String get blocAuthWeChatLoginFailed => 'Accesso a WeChat non riuscito';

  @override
  String get blocAuthWeChatNotConfigured => 'Accesso WeChat non configurato';

  @override
  String get blocAuthWeChatNotInstalled => 'Installa prima WeChat';

  @override
  String get blocAuthPasswordWrong => 'Password errata';

  @override
  String get blocAuthEmailAlreadyBound =>
      'Questa email è già associata a un altro account';

  @override
  String get blocAuthChangeEmailFailed => 'Impossibile modificare l\'e-mail';

  @override
  String get blocAuthVerificationCodeInvalid =>
      'Il codice di verifica non è corretto o è scaduto';

  @override
  String get blocAuthSessionExpired =>
      'Sessione scaduta, effettua nuovamente l\'accesso';

  @override
  String get blocAuthSessionIncomplete =>
      'Dati della sessione incompleti, effettua nuovamente l\'accesso';
}
