// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class SUk extends S {
  SUk([String locale = 'uk']) : super(locale);

  @override
  String get commonRetry => 'Повторіть спробу';

  @override
  String get commonUnknownUser => 'Невідомий користувач';

  @override
  String get transferWalletNotConnected => 'Гаманець не підключений';

  @override
  String get chatCallServiceNotInitialized =>
      'Служба виклику не ініціалізована';

  @override
  String authLoginFailed(String error) {
    return 'Помилка входу: $error';
  }

  @override
  String get chatCallBack => 'Передзвоніть';

  @override
  String get chatMissedVideoCall => 'Пропущений відеодзвінок';

  @override
  String get chatMissedVoiceCall => 'Пропущений голосовий виклик';

  @override
  String get chatCallNotAnswered => 'Без відповіді';

  @override
  String get chatCallDurationLabel => 'Тривалість дзвінка';

  @override
  String get chatVoiceCallCancelled => 'Голосовий виклик скасовано';

  @override
  String get chatVideoCallCancelled => 'Відеодзвінок скасовано';

  @override
  String get commonImage => '[Зображення]';

  @override
  String get chatVideo => '[Відео]';

  @override
  String get chatVoice => '[Голос]';

  @override
  String get commonFile => '[Файл]';

  @override
  String get chatLocation => '[Розташування]';

  @override
  String get chatUnknownMessage => '[Невідоме повідомлення]';

  @override
  String get commonDelete => 'Видалити';

  @override
  String get chatDeleteThisMessage => 'Видалити це повідомлення?';

  @override
  String get chatMessageDeleted => 'Повідомлення видалено';

  @override
  String get profileNotLoggedIn => 'Не ввійшли в систему';

  @override
  String get chatMyLocation => 'Моє місцезнаходження';

  @override
  String get commonGroupChat => 'Груповий чат';

  @override
  String get commonSearch => 'Пошук';

  @override
  String get commonCancel => 'Скасувати';

  @override
  String get commonLoadFailed => 'Не вдалося завантажити';

  @override
  String get commonMessages => 'Повідомлення';

  @override
  String get commonContacts => 'Контакти';

  @override
  String get commonMe => 'я';

  @override
  String get commonVoiceLoading => 'Голосове завантаження, спробуйте пізніше';

  @override
  String get commonVoiceToTextFailed => 'Помилка перетворення голосу в текст';

  @override
  String get commonConvertToText => 'До тексту';

  @override
  String get chatCopy => 'Копія';

  @override
  String get commonForward => 'вперед';

  @override
  String get commonUnfavorite => 'Нелюб';

  @override
  String get commonFavorite => 'улюблений';

  @override
  String get settingsResend => 'Надіслати повторно';

  @override
  String get chatRecall => 'Відкликати';

  @override
  String get commonQuote => 'Цитата';

  @override
  String get commonRemind => 'Нагадати';

  @override
  String get chatCopied => 'Скопійовано';

  @override
  String get storySendMessageHint => 'Надіслати повідомлення';

  @override
  String get commonMicrophonePermissionRequired =>
      'Дозвольте дозвіл на використання мікрофона';

  @override
  String get chatMicrophonePermissionDeniedPermanent =>
      'У дозволі на мікрофон відмовлено. Будь ласка, увімкніть це в налаштуваннях системи, щоб використовувати голосові повідомлення.';

  @override
  String commonStartRecordingFailed(String error) {
    return 'Не вдалося почати запис: $error';
  }

  @override
  String get commonRecordingTooShort => 'Запис занадто короткий';

  @override
  String commonStopRecordingFailed(String error) {
    return 'Не вдалося зупинити запис: $error';
  }

  @override
  String get chatReleaseToCancel => 'Відпустіть, щоб скасувати';

  @override
  String get chatReleaseToSend =>
      'Відпустіть, щоб надіслати, проведіть пальцем угору, щоб скасувати';

  @override
  String get commonHoldToTalk => 'Тримайте, щоб говорити';

  @override
  String get commonSend => 'Надіслати';

  @override
  String get commonAddFriend => 'Додати друга';

  @override
  String get commonChatServiceNotConnected => 'Служба чату не підключена';

  @override
  String contactUserNotFoundHint(String query) {
    return 'Користувача \"$query\" не знайдено\n\nПоради:\n• Спробуйте ввести повний ідентифікатор користувача, напр. @username:server.com\n• Перевірте написання імені користувача';
  }

  @override
  String contactCreateChatFailed(String error) {
    return 'Не вдалося створити чат: $error';
  }

  @override
  String contactSearchFailed(String error) {
    return 'Помилка пошуку: $error';
  }

  @override
  String get contactEnterUserIdOrUsername =>
      'Введіть ідентифікатор користувача або ім’я користувача для пошуку';

  @override
  String get contactSearching => 'Пошук...';

  @override
  String get contactSearchUserToChat =>
      'Знайдіть користувача, щоб розпочати спілкування';

  @override
  String get contactMatrixIdExample =>
      'Ви можете ввести повний ідентифікатор матриці\nнапр. @user:matrix.n42.network';

  @override
  String contactUserNotFound(String username) {
    return 'Користувача \"$username\" не знайдено';
  }

  @override
  String get commonChat => 'Чат';

  @override
  String get commonSettings => 'Налаштування';

  @override
  String get profileEditProfile => 'Редагувати профіль';

  @override
  String get authLogin => 'Увійти';

  @override
  String get commonCreateGroup => 'Створити групу';

  @override
  String get chatError => 'Помилка';

  @override
  String get commonTransfer => 'Трансфер';

  @override
  String get commonReceived => 'Отримано';

  @override
  String get commonRefunded => 'Повернено';

  @override
  String get commonExpired => 'Термін дії минув';

  @override
  String get chatRedPacketGreeting => 'найкращі побажання';

  @override
  String get commonN42RedPacket => 'N42 Червоний пакет';

  @override
  String get commonClaimed => 'Заявлено';

  @override
  String get commonAllClaimed => 'Все заявлено';

  @override
  String get chatReadAloud => 'Читайте вголос';

  @override
  String get chatReply => 'Відповісти';

  @override
  String get commonEdit => 'Редагувати';

  @override
  String get chatSelectForwardTarget => 'Виберіть Переслати ціль';

  @override
  String commonSendCount(int count) {
    return 'Надіслати ($count)';
  }

  @override
  String contactN42Id(String id) {
    return 'N42 ID: $id';
  }

  @override
  String get profileN42IdTitle => 'N42 ID';

  @override
  String get profileN42Bean => 'N42 Бін';

  @override
  String get contactFriendInfo => 'Інформація про друга';

  @override
  String get contactFriendInfoDesc =>
      'Додайте зауваження друга, телефон, теги, нотатки, фотографії та встановіть дозволи.';

  @override
  String get commonMoments => 'Моменти';

  @override
  String get commonSendMessage => 'повідомлення';

  @override
  String get contactAudioVideoCall => 'Аудіо/відеодзвінок';

  @override
  String get contactVideoChannel => 'Відеоканал';

  @override
  String get contactRemark => 'Зауваження';

  @override
  String get contactRemarkName => 'Примітка Назва';

  @override
  String get contactPhone => 'Телефон';

  @override
  String get contactTags => 'Теги';

  @override
  String get contactNotes => 'Примітки';

  @override
  String get contactPhotos => 'Фотографії';

  @override
  String get contactPermissions => 'Дозволи';

  @override
  String get contactChatMomentsEtc => 'Чат, моменти, спорт тощо.';

  @override
  String get contactMoreInfo => 'Більше інформації';

  @override
  String get contactCommonGroups => 'Спільні групи';

  @override
  String get contactSource => 'Джерело';

  @override
  String get settingsNotificationSettings => 'Сповіщення';

  @override
  String get settingsPrivacy => 'Конфіденційність';

  @override
  String get settingsAppearance => 'Зовнішній вигляд';

  @override
  String get settingsAbout => 'про';

  @override
  String get commonLogout => 'Вийти';

  @override
  String get commonLogoutConfirm => 'Ви впевнені, що бажаєте вийти?';

  @override
  String get commonSave => 'зберегти';

  @override
  String get profileNickname => 'псевдонім';

  @override
  String get profileEnterNickname => 'Введіть псевдонім';

  @override
  String get profileSignature => 'Підпис';

  @override
  String get profileAddSignature => 'Додайте підпис';

  @override
  String get commonTakePhoto => 'Зробити фото';

  @override
  String get profileChooseFromGallery => 'Виберіть із галереї';

  @override
  String profileSaveFailed(String error) {
    return 'Не вдалося зберегти: $error';
  }

  @override
  String get authSecureDecentralizedChat =>
      'Безпечний децентралізований обмін повідомленнями';

  @override
  String get commonEndToEndEncryption => 'Наскрізне шифрування';

  @override
  String get authMessagesOnlyYouCanSee =>
      'Повідомлення, видимі лише вам і одержувачу';

  @override
  String get authDecentralized => 'Децентралізована';

  @override
  String get authBasedOnMatrix =>
      'Побудований на основі відкритого протоколу Matrix';

  @override
  String get authWalletIntegration => 'Інтеграція гаманця';

  @override
  String get authEasyCryptoTransfer => 'Прості перекази криптовалюти';

  @override
  String get authRegister => 'Зареєструватися';

  @override
  String get authAgreeTerms => 'Увійшовши в систему, ви погоджуєтесь';

  @override
  String get authTermsOfService => 'Умови обслуговування';

  @override
  String get authAnd => 'і';

  @override
  String get authPrivacyPolicy => 'Політика конфіденційності';

  @override
  String get authServerAddress => 'Адреса сервера';

  @override
  String get authEnterServerAddress => 'Введіть адресу сервера';

  @override
  String authConnectedTo(String serverName) {
    return 'Підключено до $serverName';
  }

  @override
  String get authUsername => 'Ім\'я користувача';

  @override
  String get authEnterUsername => 'Введіть ім\'я користувача';

  @override
  String get authUsernameOrEmail => 'Ім\'я користувача або електронна пошта';

  @override
  String get authEnterUsernameOrEmail =>
      'Введіть ім\'я користувача або електронну адресу';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authEnterPassword => 'Введіть пароль';

  @override
  String get authRegisterAccount => 'Зареєструватися';

  @override
  String get authForgotPassword => 'Забули пароль';

  @override
  String get authOtherLoginMethods => 'Інші методи входу';

  @override
  String get authCreateAccount => 'Створити акаунт';

  @override
  String get authJoinN42Chat =>
      'Приєднайтеся до чату N42, щоб розпочати спілкування';

  @override
  String get authUsernameHint => '3-20 символів, літери/цифри/_';

  @override
  String get authUsernameMinLength =>
      'Ім\'я користувача має містити не менше 3 символів';

  @override
  String get authUsernameMaxLength =>
      'Ім\'я користувача має містити не більше 20 символів';

  @override
  String get authUsernameFormat =>
      'Ім\'я користувача може містити лише літери, цифри та підкреслення';

  @override
  String get authPasswordHint => 'Мінімум 8 символів';

  @override
  String get commonPasswordMinLength => 'Пароль має бути не менше 8 символів';

  @override
  String get authConfirmPassword => 'Підтвердьте пароль';

  @override
  String get authFilled => 'Заповнений';

  @override
  String get authEnterInviteCode => 'Введіть код запрошення';

  @override
  String get authAlreadyHaveAccount => 'Вже маєте акаунт?';

  @override
  String get authLoginNow => 'Увійдіть зараз';

  @override
  String get profileAvatar => 'Аватар';

  @override
  String get profileStatus => 'Статус';

  @override
  String get commonLoading => 'Завантаження...';

  @override
  String get conversationNoConversations => 'Жодних розмов';

  @override
  String get conversationTapToChat =>
      'Торкніться вгорі праворуч, щоб розпочати спілкування';

  @override
  String get conversationStartGroup => 'Запустіть груповий чат';

  @override
  String get commonScan => 'Сканувати';

  @override
  String get commonPayment => 'Оплата';

  @override
  String commonFeatureComingSoon(String feature) {
    return '$feature незабаром';
  }

  @override
  String get conversationMarkAsRead => 'Позначити як прочитане';

  @override
  String get commonUnmute => 'Увімкнути звук';

  @override
  String get commonMute => 'Вимкнути звук';

  @override
  String get conversationUnpin => 'Відкріпити';

  @override
  String get conversationPin => 'Pin';

  @override
  String get conversationDeleteConversation => 'Видалити розмову';

  @override
  String conversationDeleteConversationConfirm(String name) {
    return 'Видалити розмову з \"$name\"?';
  }

  @override
  String get commonNoContacts => 'Немає контактів';

  @override
  String get contactAddFriendsToChat =>
      'Додайте друзів, щоб почати спілкуватися';

  @override
  String get contactNotFound => 'Контакт не знайдено';

  @override
  String get contactTryOtherKeywords =>
      'Спробуйте інші ключові слова або глобальний пошук';

  @override
  String get contactSearchResults => 'Результати пошуку';

  @override
  String get contactNewFriends => 'Нові друзі';

  @override
  String get contactChatOnlyFriends => 'Друзі лише в чаті';

  @override
  String get contactOfficialAccounts => 'Офіційні облікові записи';

  @override
  String get contactServiceAccounts => 'Сервісні облікові записи';

  @override
  String get contactEnterpriseContacts => 'Контакти підприємства';

  @override
  String get contactRecommendToFriend => 'Поділіться контактом';

  @override
  String get commonSetRemark => 'Встановити зауваження';

  @override
  String get contactSendingCard => 'Надсилання картки контакту...';

  @override
  String get commonFileLabel => 'Файл';

  @override
  String get commonLocationLabel => 'Розташування';

  @override
  String contactRecommendFailed(String error) {
    return 'Не вдалося рекомендувати: $error';
  }

  @override
  String get profileEnterRemark => 'Введіть зауваження';

  @override
  String get contactOpeningChat => 'Відкриття чату...';

  @override
  String contactOpenChatFailed(String error) {
    return 'Не вдалося відкрити чат: $error';
  }

  @override
  String get contactAddContact => 'Додати контакт';

  @override
  String get contactEnterUserId => 'Введіть ідентифікатор користувача';

  @override
  String get contactNoFriendRequests => 'Без запитів друзів';

  @override
  String get commonAccept => 'прийняти';

  @override
  String get commonReject => 'Відхиляти';

  @override
  String get commonNoGroups => 'Немає груп';

  @override
  String get contactSelectFriendToRecommend =>
      'Виберіть друга, якому потрібно порекомендувати';

  @override
  String get commonSearchContacts => 'Пошук контактів';

  @override
  String get contactNoContactsFound => 'Контакти не знайдено';

  @override
  String get favoriteYesterday => 'вчора';

  @override
  String get chatJustNow => 'Просто зараз';

  @override
  String get profileOnline => 'Онлайн';

  @override
  String get profileOffline => 'Офлайн';

  @override
  String get searchContactsGroupsMessages =>
      'Пошук контактів, груп і повідомлень';

  @override
  String get searchError => 'Помилка пошуку';

  @override
  String get chatSearchHint => 'Пошук';

  @override
  String get searchHistory => 'Історія пошуку';

  @override
  String get commonClear => 'ясно';

  @override
  String get commonAll => 'всі';

  @override
  String get searchGroups => 'Групи';

  @override
  String get searchNoResults => 'Немає результатів';

  @override
  String commonGroupMembers(int count) {
    return 'Учасники ($count)';
  }

  @override
  String get groupMembersTitle => 'Члени групи';

  @override
  String get groupViewAll => 'Переглянути всі';

  @override
  String get groupOwner => 'Власник';

  @override
  String get groupAdmin => 'адмін';

  @override
  String get groupInvite => 'Запросити';

  @override
  String get commonGroupAnnouncement => 'Групове оголошення';

  @override
  String get commonNotSet => 'Не встановлено';

  @override
  String get groupDescription => 'Опис групи';

  @override
  String get groupPublicGroup => 'Громадська група';

  @override
  String get commonClearChatHistory => 'Очистити історію чату';

  @override
  String get commonDissolveGroup => 'Розпустити групу';

  @override
  String get commonLeaveGroup => 'Вийти з групи';

  @override
  String get groupChangeGroupName => 'Змінити назву групи';

  @override
  String get commonEnterGroupName => 'Введіть назву групи';

  @override
  String get commonConfirm => 'Підтвердити';

  @override
  String get groupEnterGroupDescription => 'Введіть опис групи';

  @override
  String get groupPublish => 'Опублікувати';

  @override
  String get chatClearHistoryConfirm =>
      'Очистити всю історію чату? Це неможливо скасувати.';

  @override
  String get chatClearAction => 'ясно';

  @override
  String get commonChatHistoryCleared => 'Історію чату очищено';

  @override
  String get commonDissolve => 'Розчинити';

  @override
  String get groupQrCode => 'QR-код групи';

  @override
  String get commonSearchChatHistory => 'Пошук в історії чату';

  @override
  String get groupIdCopied => 'Ідентифікатор групи скопійовано';

  @override
  String get transferEnterOrPasteAddress =>
      'Введіть або вставте адресу гаманця';

  @override
  String get transferSelectToken => 'Виберіть Токен';

  @override
  String get commonTransferAmount => 'Сума переказу';

  @override
  String get transferAvailable => 'в наявності';

  @override
  String get transferMemoOptional => 'Пам\'ятка (необов\'язково)';

  @override
  String get transferConfirmTransfer => 'Підтвердити передачу';

  @override
  String get transferAddressVerified => 'Адреса підтверджена';

  @override
  String transferAvailableBalance(String balance, String symbol) {
    return 'В наявності: $balance $symbol';
  }

  @override
  String get commonEnterAmount => 'Введіть суму';

  @override
  String get commonRedPacketCountMin => 'Потрібен принаймні 1 червоний пакет';

  @override
  String get commonViewRedPacketDetails =>
      'Переглянути інформацію про червоний пакет';

  @override
  String get commonEnterTransferAmount => 'Будь ласка, введіть суму переказу';

  @override
  String get commonTransferTo => 'Передача в';

  @override
  String commonFromSender(String name, Object senderName) {
    return 'Від $name';
  }

  @override
  String get commonConfirmReceive => 'Підтвердити отримання';

  @override
  String get groupProfile => 'Інформація про групу';

  @override
  String get groupRemoveMember => 'Видалити з групи';

  @override
  String get commonRemove => 'видалити';

  @override
  String get profileClearStatus => 'Очистити статус';

  @override
  String get profileClearStatusConfirm => 'Очистити поточний статус?';

  @override
  String get profileStatusCleared => 'Статус очищено';

  @override
  String get profileUserNotExist => 'Користувач не існує';

  @override
  String get profileUserIdCopied => 'ID користувача скопійовано';

  @override
  String get commonReport => 'звіт';

  @override
  String get profileQrCode => 'QR-код';

  @override
  String get profileAvatarUpdated => 'Аватар оновлено';

  @override
  String commonSelectImageFailed(String error) {
    return 'Не вдалося вибрати зображення: $error';
  }

  @override
  String get profileChangeName => 'Змінити ім\'я';

  @override
  String get profileMale => 'Чоловік';

  @override
  String get profileFemale => 'Жінка';

  @override
  String chatFeatureInDev(String feature) {
    return 'Функція $feature у розробці...';
  }

  @override
  String profileSaveAddressFailed(String error) {
    return 'Не вдалося зберегти адресу: $error';
  }

  @override
  String get profileAddNew => 'додати';

  @override
  String get profileAddAddress => 'Додати адресу';

  @override
  String get profileAddressAdded => 'Адресу додано';

  @override
  String get profileAddressUpdated => 'Адреса оновлена';

  @override
  String get profileDeleteAddress => 'Видалити адресу';

  @override
  String get profileAddressDeleted => 'Адреса видалена';

  @override
  String profileSaveInvoiceFailed(String error) {
    return 'Не вдалося зберегти рахунок-фактуру: $error';
  }

  @override
  String get profileMyInvoices => 'Мої рахунки-фактури';

  @override
  String get profileAddInvoice => 'Додати рахунок-фактуру';

  @override
  String get profileInvoiceAdded => 'Рахунок додано';

  @override
  String get profileInvoiceUpdated => 'Рахунок оновлено';

  @override
  String get profileDeleteInvoice => 'Видалити рахунок-фактуру';

  @override
  String get profileInvoiceDeleted => 'Рахунок видалено';

  @override
  String get profilePersonal => 'Особисті';

  @override
  String get groupSelectAtLeastOne => 'Виберіть хоча б одного учасника';

  @override
  String get chatFileNotExist => 'Файл не існує';

  @override
  String chatSendFailed(String error) {
    return 'Не вдалося надіслати: $error';
  }

  @override
  String get chatCannotOpenBrowser => 'Не вдається відкрити браузер';

  @override
  String chatSelectFileFailed(String error) {
    return 'Не вдалося вибрати файл: $error';
  }

  @override
  String settingsSetupFailed(String error) {
    return 'Помилка налаштування: $error';
  }

  @override
  String get transferEnterValidAmount => 'Введіть дійсну суму';

  @override
  String get commonAddressCopied => 'Адресу скопійовано';

  @override
  String favoriteOpenItem(String content) {
    return 'Відкрити: $content';
  }

  @override
  String get favoriteDeleted => 'Видалено';

  @override
  String get profileWallet => 'Гаманець';

  @override
  String get chatRecording => 'Запис';

  @override
  String get chatInvalidVideoUrl => 'Недійсна URL-адреса відео';

  @override
  String get chatDownloadFile => 'Завантажити файл';

  @override
  String get chatClearChatHistoryTitle => 'Очистити історію чату';

  @override
  String get chatVideoCall => 'Відеодзвінок';

  @override
  String get commonVoiceCall => 'Голосовий виклик';

  @override
  String get callLeaveMeeting => 'Залишити зустріч';

  @override
  String get chatDetails => 'Деталі чату';

  @override
  String get chatViewAllGroupMembers => 'Переглянути всіх учасників';

  @override
  String get chatGroupName => 'Назва групи';

  @override
  String get chatGroupNameUpdated => 'Назва групи оновлена';

  @override
  String get chatUpdateFailed => 'Помилка оновлення';

  @override
  String get chatNoPermissionToModify => 'Ви не маєте дозволу на зміну';

  @override
  String get chatGroupManagement => 'Управління групою';

  @override
  String get chatMyNicknameInGroup => 'Мій нік у групі';

  @override
  String get chatPinChat => 'Закріпити чат';

  @override
  String get chatStrongReminder => 'Сильне нагадування';

  @override
  String get chatSetChatBackground => 'Встановити фон чату';

  @override
  String get chatUnknownFile => 'Невідомий файл';

  @override
  String get chatDownload => 'Завантажити';

  @override
  String get chatInvalidLocation => 'Недійсне розташування';

  @override
  String get chatTapToCancel => 'Торкніться, щоб скасувати';

  @override
  String chatCaptureFailed(Object error) {
    return 'Помилка захоплення: $error';
  }

  @override
  String get chatProcessingVideo => 'Обробка відео...';

  @override
  String get chatVideoFileNotExist => 'Відеофайл не існує';

  @override
  String get chatVideoDataEmpty => 'Дані відео порожні';

  @override
  String get chatVideoTooLarge => 'Розмір відео не може перевищувати 100 МБ';

  @override
  String get chatSendingVideo => 'Надсилання відео...';

  @override
  String chatSendVideoFailed(Object error) {
    return 'Не вдалося надіслати відео: $error';
  }

  @override
  String get chatImageFileNotExist => 'Файл зображення не існує';

  @override
  String get commonImageDataEmpty => 'Дані зображення порожні';

  @override
  String get chatSendingImage => 'Надсилання зображення...';

  @override
  String chatSendImageFailed(Object error) {
    return 'Не вдалося надіслати зображення: $error';
  }

  @override
  String get chatSendLocation => 'Надіслати місцезнаходження';

  @override
  String get chatSelectLocationAndSend => 'Виберіть місце та надішліть';

  @override
  String get chatShareRealTimeLocation =>
      'Поділіться місцезнаходженням у реальному часі';

  @override
  String get chatShareLocationForOneHour =>
      'Поділіться з друзями місцезнаходженням у реальному часі протягом 1 години';

  @override
  String get chatLocationSent => 'Розташування надіслано';

  @override
  String get chatSelectMessages => 'Виберіть повідомлення';

  @override
  String chatSelectedCount(int count) {
    return 'Вибрано $count';
  }

  @override
  String get chatSelectAll => 'Виберіть усі';

  @override
  String chatGroupChatCount(int count) {
    return 'Груповий чат ($count)';
  }

  @override
  String get chatPrivateChat => 'Приватний чат';

  @override
  String get chatNoMessages => 'Немає повідомлень';

  @override
  String get chatSendFirstMessage =>
      'Надішліть перше повідомлення, щоб розпочати спілкування';

  @override
  String get chatEncryptionNotice =>
      'Цей чат має наскрізне шифрування. Лише ви та одержувач можете читати повідомлення.';

  @override
  String get chatMultiForward => 'вперед';

  @override
  String get chatCollect => 'Збирати';

  @override
  String get chatNoMembers => 'Немає учасників';

  @override
  String get chatMemberNotFound => 'Учасника не знайдено';

  @override
  String get chatVoiceFileNotExist => 'Голосовий файл не існує';

  @override
  String get chatVoiceFileEmpty => 'Голосовий файл порожній';

  @override
  String get chatSendingVoice => 'Надсилання голосу...';

  @override
  String chatSendVoiceFailed(Object error) {
    return 'Не вдалося надіслати голос: $error';
  }

  @override
  String get chatMessageForwarded => 'Повідомлення переслано';

  @override
  String chatForwardFailed(Object error) {
    return 'Не вдалося переслати: $error';
  }

  @override
  String get chatUnfavorited => 'Не додано до вибраного';

  @override
  String get chatFavorited => 'Вибране';

  @override
  String get chatReactionAdded => 'Реакція додана';

  @override
  String get chatReactionRemoved => 'Реакцію видалено';

  @override
  String get chatFailedMessageDeleted => 'Невдале повідомлення видалено';

  @override
  String get chatDeleteMessages => 'Видалити повідомлення';

  @override
  String chatDeleteMessagesConfirm(Object count) {
    return 'Ви впевнені, що хочете видалити повідомлення $count?';
  }

  @override
  String chatNoteOtherMessages(Object count) {
    return 'Примітка: повідомлення $count надходять від інших і будуть видалені лише для вас.';
  }

  @override
  String chatMyMessagesWillBeRecalled(Object count) {
    return '$count повідомлення від вас будуть відкликані для всіх.';
  }

  @override
  String chatRecalledCount(Object count, Object localCount) {
    return 'Відкликані повідомлення $count, $localCount видалено лише для вас';
  }

  @override
  String chatRecalledMessages(Object count) {
    return 'Відкликані повідомлення $count';
  }

  @override
  String chatDeletedLocally(Object count) {
    return '$count повідомлення видалено лише для вас';
  }

  @override
  String chatForwardedCount(Object count) {
    return 'Переслані повідомлення $count';
  }

  @override
  String chatForwardComplete(Object failed, Object success) {
    return 'Пересилання завершено: $success вдалося, $failed не вдалося';
  }

  @override
  String get chatRemindOnlyInGroup =>
      'Функція нагадування доступна лише в груповому чаті';

  @override
  String get chatOnlyTextSearchable =>
      'Можна шукати лише текстові повідомлення';

  @override
  String chatSearchFor(Object text) {
    return 'Пошук \"$text\"';
  }

  @override
  String get chatBaiduSearch => 'Пошук Baidu';

  @override
  String get chatGoogleSearch => 'Пошук Google';

  @override
  String get chatBingSearch => 'Пошук Bing';

  @override
  String get chatCalling => 'Телефоную...';

  @override
  String get chatRinging => 'Дзвінок...';

  @override
  String get chatInCall => 'У дзвінку';

  @override
  String commonFeatureInDevelopment(String feature) {
    return 'Функція $feature у розробці...';
  }

  @override
  String chatCollectMessages(Object count) {
    return 'Зібрані повідомлення $count';
  }

  @override
  String commonMemberCount(int count) {
    return 'Учасники $count';
  }

  @override
  String groupDone(int count) {
    return 'Готово ($count)';
  }

  @override
  String get profileServices => 'Послуги';

  @override
  String get commonFavorites => 'Вибране';

  @override
  String get profileOrdersAndCards => 'Замовлення та картки';

  @override
  String get profileStickers => 'наклейки';

  @override
  String profileStatusSetTo(String status) {
    return 'Встановлено статус: $status';
  }

  @override
  String get profileAvatarUploadFailed => 'Не вдалося завантажити аватар';

  @override
  String get profilePersonalProfile => 'Особистий профіль';

  @override
  String get profileName => 'Ім\'я';

  @override
  String get profileGender => 'Стать';

  @override
  String get profileRegion => 'Регіон';

  @override
  String get commonMyQrCode => 'Мій QR-код';

  @override
  String get profilePoke => 'Тикати';

  @override
  String get profileRingtone => 'Рінгтон';

  @override
  String get profileDefaultRingtone => 'Мелодія за замовчуванням';

  @override
  String get profileMyAddresses => 'Мої адреси';

  @override
  String profileGenderSetTo(String gender) {
    return 'Встановлено стать: $gender';
  }

  @override
  String get profileSelectRegion => 'Виберіть регіон';

  @override
  String get profileSelectCity => 'Виберіть місто';

  @override
  String profileRegionSetTo(String region) {
    return 'Для регіону встановлено: $region';
  }

  @override
  String get profileSetPoke => 'Встановити Poke';

  @override
  String get profileFriendPokedMe => 'Друг тицьнув мене';

  @override
  String get profileExample => 'приклад';

  @override
  String get profileOnTheShoulder => ' на плечі';

  @override
  String get profilePokeCleared => 'Пок очищено';

  @override
  String profilePokeSetTo(String suffix) {
    return 'Poke встановлено на: poked me$suffix';
  }

  @override
  String get profileEditSignature => 'Редагувати підпис';

  @override
  String get profileIntroduceYourself => 'Речення для представлення';

  @override
  String get profileSignatureCleared => 'Підпис очищено';

  @override
  String get profileSignatureUpdated => 'Підпис оновлено';

  @override
  String get profileScanToAddFriend =>
      'Відскануйте QR-код вище, щоб додати мене до друзів';

  @override
  String profileRingtoneSetTo(String ringtone) {
    return 'Встановлено сигнал дзвінка: $ringtone';
  }

  @override
  String commonConfirmDissolveGroup(String name) {
    return 'Ви впевнені, що хочете розпустити \"$name\"? Цю дію не можна скасувати.';
  }

  @override
  String get authEnterValidServerAddress => 'Введіть дійсну адресу сервера';

  @override
  String get authEnterServerAddressFirst => 'Спочатку введіть адресу сервера';

  @override
  String get authPasskeyRequiresServer =>
      'Пароль для входу вимагає підтримки сервера';

  @override
  String get authLoginAgreement => 'Увійшовши в систему, ви погоджуєтесь ';

  @override
  String get authPleaseAgreeToTerms =>
      'Прочитайте та погодьтеся з Умовами надання послуг і Політикою конфіденційності';

  @override
  String get authRegisterFailed => 'Помилка реєстрації';

  @override
  String get commonReenterPassword => 'Повторно введіть пароль';

  @override
  String get commonPasswordsDoNotMatch => 'Паролі не збігаються';

  @override
  String get authInviteCodeBuiltIn => 'Код запрошення (вбудований)';

  @override
  String get authInviteCodeBuiltInNote =>
      'Код запрошення вбудований, зазвичай не потрібно змінювати';

  @override
  String get authIHaveReadAndAgree => 'Я прочитав і згоден ';

  @override
  String get mainStartGroupChat => 'Запустіть груповий чат';

  @override
  String get mainAddFriends => 'Додати друзів';

  @override
  String get mainPaymentAndCollection => 'Оплата';

  @override
  String contactCount(int count) {
    return '$count контакти';
  }

  @override
  String get contactAddToHomeScreen => 'Додати на головний екран';

  @override
  String contactRecommendedCardTo(String contact, String recipient) {
    return 'Рекомендована картка $contact для $recipient';
  }

  @override
  String get contactEnterRemarkName => 'Введіть назву зауваження';

  @override
  String contactRemarkSetTo(String remark) {
    return 'Примітка встановлена на: $remark';
  }

  @override
  String contactAcceptedFriendRequest(String name) {
    return 'Прийняв запит $name про друзі';
  }

  @override
  String contactRejectedFriendRequest(String name) {
    return 'Відхилено запит $name про дружбу';
  }

  @override
  String get commonGroupInvites => 'Групові запрошення';

  @override
  String commonMyGroups(int count) {
    return 'Мої групи ($count)';
  }

  @override
  String get commonInvitedToJoinGroup => 'Запрошено приєднатися до групи';

  @override
  String commonConfirmLeaveGroup(String name) {
    return 'Ви впевнені, що бажаєте залишити \"$name\"?';
  }

  @override
  String get commonLeave => 'Залиште';

  @override
  String get commonRecallThisMessage => 'Відкликати це повідомлення?';

  @override
  String get commonSavedToGallery => 'Збережено в галерею';

  @override
  String get commonFailedToSave => 'Не вдалося зберегти';

  @override
  String get chatSaving => 'Збереження...';

  @override
  String get commonShare => 'Поділіться';

  @override
  String get chatSaveToGallery => 'Зберегти в галерею';

  @override
  String chatDownloadFailed(String code) {
    return 'Помилка завантаження: $code';
  }

  @override
  String commonShareFailed(String error) {
    return 'Не вдалося поділитися: $error';
  }

  @override
  String get chatFailedToLoadImage => 'Не вдалося завантажити зображення';

  @override
  String get chatVideoRecordingFailed => 'Помилка запису відео';

  @override
  String get profileRedPacket => 'Червоний пакет';

  @override
  String get commonMusic => 'музика';

  @override
  String get commonCoupon => 'Купон';

  @override
  String get commonGift => 'Подарунок';

  @override
  String get commonPoll => 'Опитування';

  @override
  String get favoriteText => 'текст';

  @override
  String get favoriteLinkLabel => 'Посилання';

  @override
  String get favoriteNote => 'Примітка';

  @override
  String get favoriteMyNotes => 'Мої нотатки';

  @override
  String get favoriteToday => 'Сьогодні';

  @override
  String favoriteDaysAgoText(int count) {
    return '$count днів тому';
  }

  @override
  String favoriteDateFormat(int month, int day) {
    return '$month/$day';
  }

  @override
  String get favoriteNoFavorites => 'Вибраних ще немає';

  @override
  String get favoriteLongPressToFavorite =>
      'Тривале натискання повідомлення до вибраного';

  @override
  String get favoriteNewNote => 'Нова примітка';

  @override
  String get favoriteLink => 'Улюблене посилання';

  @override
  String get favoriteEditTags => 'Редагувати теги';

  @override
  String get favoriteDeleteFavorite => 'Видалити улюблене';

  @override
  String get favoriteDeleteFavoriteConfirm =>
      'Ви впевнені, що хочете видалити це улюблене?';

  @override
  String get favoriteNoSearchResultsFound => 'Результатів не знайдено';

  @override
  String get commonSendRedPacket => 'Надіслати червоний пакет';

  @override
  String get transferAmount => 'Сума';

  @override
  String get commonRedPacketCover => 'Червона обкладинка пакета';

  @override
  String get commonRedPacketType => 'Червоний тип пакета';

  @override
  String get commonNormalRedPacket => 'нормальний';

  @override
  String get commonLuckyRedPacket => 'Щасливчик';

  @override
  String get commonRedPacketCount => 'Кількість червоних пакетів';

  @override
  String get commonPieces => 'штук';

  @override
  String get commonPutMoneyInRedPacket => 'Покладіть гроші в червоний пакет';

  @override
  String get commonRedPacketRefundNotice =>
      'Незатребувані червоні пакети буде повернено через 24 години';

  @override
  String get commonOpenRedPacket => 'відкритий';

  @override
  String get commonRedPacketAllClaimed => 'Червоний пакет весь затребуваний';

  @override
  String get commonRedPacketExpired => 'Термін дії червоного пакета закінчився';

  @override
  String get commonAddTransferNote => 'Додати переказну записку';

  @override
  String get commonYuan => 'CNY';

  @override
  String get commonReplyWithEmoji => 'Відповісти цим смайлом';

  @override
  String get contactEditRemark => 'Редагувати зауваження';

  @override
  String get contactSetPermissions => 'Встановити дозволи';

  @override
  String get profileAddToBlacklist => 'Додати в чорний список';

  @override
  String get contactDeleteContact => 'Видалити контакт';

  @override
  String contactDeleteContactConfirm(String name) {
    return 'Ви впевнені, що хочете видалити $name?';
  }

  @override
  String get transferTitle => 'Трансфер';

  @override
  String get transferReceiverAddressLabel => 'Адреса отримувача';

  @override
  String get transferSelectTokenLabel => 'Виберіть Токен';

  @override
  String get transferAmountLabel => 'Сума переказу';

  @override
  String get transferMemoLabel => 'Пам\'ятка (необов\'язково)';

  @override
  String get transferAddMemoHint => 'Додайте пам\'ятку';

  @override
  String get transferSendPaymentRequest => 'Надіслати запит на оплату';

  @override
  String get transferQrCodeGenerateFailed => 'Не вдалося створити QR-код';

  @override
  String get transferScanQrToPayMe => 'Відскануйте QR-код, щоб заплатити мені';

  @override
  String get transferMyWalletAddress => 'Адреса мого гаманця';

  @override
  String get transferCreatePaymentRequest => 'Створення платіжного запиту';

  @override
  String profileN42IdLabel(String id) {
    return 'N42 ID: $id';
  }

  @override
  String get commonRedPacketDefaultGreeting => 'найкращі побажання';

  @override
  String commonSenderRedPacket(String name) {
    return 'Червоний пакет $name';
  }

  @override
  String get transferEnterValidAddress => 'Введіть дійсну адресу';

  @override
  String get transferPleaseSelectToken => 'Будь ласка, виберіть маркер';

  @override
  String get commonReceivedTransfer => 'Отримано передачу';

  @override
  String commonSenderSentRedPacket(String name) {
    return '$name надіслав червоний пакет';
  }

  @override
  String get commonSavedToBalance =>
      'Збережено на балансі, можна передавати напряму';

  @override
  String get commonRedPacketExpiredOrEmpty =>
      'Термін дії червоного пакета минув/усі заявлені';

  @override
  String get transferScanFeatureComingSoon =>
      'Незабаром буде доступна функція сканування...';

  @override
  String get contactSetAsStarred => 'Установити як із зірочкою';

  @override
  String get contactAddToBlocklist => 'Додати до чорного списку';

  @override
  String get commonClaimedYour => ' вимагав ваш ';

  @override
  String get commonClaimedText => ' стверджував ';

  @override
  String commonUserTyping(String name) {
    return '$name друкує...';
  }

  @override
  String get commonTyping => 'Введення...';

  @override
  String get commonWaitingToReceive => 'Очікування отримання';

  @override
  String get commonTapToClaim => 'Торкніться, щоб вимагати';

  @override
  String get commonHasBeenReceived => 'Отримано';

  @override
  String get commonGetLucky => 'Пощастить';

  @override
  String get qrcodeCameraStartFailed => 'Не вдалося запустити камеру';

  @override
  String get qrcodeUnknownError => 'Невідома помилка';

  @override
  String get qrcodePlaceQrCodeInFrame =>
      'Помістіть QR-код у рамку для сканування';

  @override
  String get qrcodeCloseManualInput => 'Закрити ручне введення';

  @override
  String get qrcodeManualInputUserId =>
      'Ручне введення ідентифікатора користувача';

  @override
  String get commonAdd => 'додати';

  @override
  String get profileSetStatus => 'Встановити статус';

  @override
  String get profileVisibleToFriends24h => 'Видно для друзів протягом 24 годин';

  @override
  String get profileWriteStatus => 'Напишіть статус';

  @override
  String get profileEnterYourStatus => 'Введіть свій статус...';

  @override
  String get profileOk => 'добре';

  @override
  String get qrcodeCameraPermissionRequired =>
      'Для сканування QR-коду потрібен дозвіл камери';

  @override
  String get qrcodeCameraPermissionDenied =>
      'Назавжди заборонено доступ до камери. Увімкніть його в налаштуваннях системи.';

  @override
  String qrcodePermissionCheckError(String error) {
    return 'Помилка перевірки дозволу: $error';
  }

  @override
  String get qrcodeInvalidQrCode => 'Недійсний QR-код';

  @override
  String qrcodeCannotAddFriend(String error) {
    return 'Неможливо додати друга: $error';
  }

  @override
  String get qrcodeScanQrCode => 'Відскануйте QR-код';

  @override
  String get qrcodeCheckingCameraPermission => 'Перевірка дозволу камери...';

  @override
  String get qrcodeNeedCameraPermission => 'Потрібен дозвіл камери';

  @override
  String get qrcodeRetryPermission => 'Повторіть спробу';

  @override
  String get qrcodeOpenSettings => 'Відкрийте налаштування';

  @override
  String get groupInviteMembers => 'Запросити учасників';

  @override
  String groupInviteCount(int count) {
    return 'Запросити ($count)';
  }

  @override
  String get profileNoShippingAddress => 'Немає адреси доставки';

  @override
  String get profileDefaultLabel => 'За замовчуванням';

  @override
  String get profileNoInvoice => 'Без рахунку-фактури';

  @override
  String get profileCompany => 'Компанія';

  @override
  String get profileTaxNumber => 'Податковий номер';

  @override
  String get profileConfirmDeleteAddress =>
      'Ви впевнені, що хочете видалити цю адресу?';

  @override
  String get profileConfirmDeleteInvoice =>
      'Ви впевнені, що бажаєте видалити цей рахунок?';

  @override
  String get commonGroupOwner => 'Власник';

  @override
  String get commonGroupAdmin => 'адмін';

  @override
  String get groupSearchMembers => 'Пошук учасників';

  @override
  String groupTotalMembers(int count) {
    return 'Учасники $count';
  }

  @override
  String get chatRemoveFromGroup => 'Видалити з групи';

  @override
  String groupConfirmRemoveMember(String name) {
    return 'Ви впевнені, що хочете видалити \"$name\" із групи?';
  }

  @override
  String get chatUnknownSong => 'Невідома пісня';

  @override
  String get chatUnknownArtist => 'Невідомий художник';

  @override
  String get chatUnknownContact => 'Невідомий контакт';

  @override
  String get chatPersonalCard => 'Картка контакту';

  @override
  String get chatSingleChoice => 'неодружений';

  @override
  String get chatMultiChoice => 'Мульти';

  @override
  String get chatEnded => 'Завершено';

  @override
  String get chatEndPollButton => 'Завершити опитування';

  @override
  String get chatPollHint =>
      'Опитування буде відображено в чаті. Члени групи можуть голосувати.';

  @override
  String get chatSearchSongOrArtist => 'Пошук пісні чи виконавця';

  @override
  String get chatNoSongsFound => 'Пісень не знайдено';

  @override
  String get chatSongNameOptional => 'Назва пісні (необов\'язково)';

  @override
  String get chatEnterSongName => 'Введіть назву пісні';

  @override
  String get chatArtistNameOptional => 'Ім\'я виконавця (необов\'язково)';

  @override
  String get chatEnterArtistName => 'Введіть ім\'я виконавця';

  @override
  String get chatRealTimeLocationSharing =>
      'Передача геоданих у реальному часі в розробці...';

  @override
  String get profileVoiceCallFeatureInDev =>
      'Функція голосового виклику в розробці...';

  @override
  String get profileReportFeatureInDev => 'Функція звіту в розробці...';

  @override
  String get profileShareFeatureInDev => 'Поділитися функцією в розробці...';

  @override
  String get profileQrCodeFeatureInDev => 'Функція QR-коду в розробці...';

  @override
  String get qrcodeScanQrToAddMe =>
      'Відскануйте QR-код вище, щоб додати мене до друзів';

  @override
  String get qrcodeSaveToAlbum => 'Зберегти в альбом';

  @override
  String get qrcodeChangeStyle => 'Змінити стиль';

  @override
  String get qrcodeCopyId => 'Копіювати ідентифікатор';

  @override
  String get qrcodeIdCopied => 'ID скопійовано';

  @override
  String get qrcodeMoreStylesFeatureComingSoon => 'Більше стилів незабаром';

  @override
  String get profileBio => 'біографія';

  @override
  String get profileHomeServer => 'Сервер';

  @override
  String get profileShareContactCard => 'Поділитися карткою контакту';

  @override
  String get profileRemoveFromBlacklist => 'Видалити з чорного списку';

  @override
  String get profileConfirmAddBlacklist =>
      'Ви впевнені, що хочете додати цього користувача до чорного списку? Ви не отримаєте від них повідомлень.';

  @override
  String get profileConfirmRemoveBlacklist =>
      'Ви впевнені, що хочете видалити цього користувача з чорного списку?';

  @override
  String get profileRemarkSaved => 'Зауваження збережено';

  @override
  String get profileRemarkCleared => 'Зауваження видалено';

  @override
  String get transferReceive => 'Отримати';

  @override
  String get transferPleaseConnectWallet => 'Спочатку підключіть свій гаманець';

  @override
  String get transferSendRequest => 'Надіслати запит';

  @override
  String get transferPleaseEnterValidAmount => 'Введіть дійсну суму';

  @override
  String get searchPlaceholder => 'Пошук контактів, груп, повідомлень';

  @override
  String get searchEnterKeywordToSearch =>
      'Введіть ключове слово, щоб почати пошук';

  @override
  String get searchClearHistory => 'ясно';

  @override
  String searchNoResultsForQuery(String query) {
    return 'Немає результатів для \"$query\"';
  }

  @override
  String get searchAllResults => 'всі';

  @override
  String get searchInChat => 'Пошук в чаті';

  @override
  String get searchContactLabel => 'контакт';

  @override
  String get searchGroupLabel => 'Група';

  @override
  String get searchConversationLabel => 'Розмова';

  @override
  String get searchMessageLabel => 'повідомлення';

  @override
  String get settingsSecurityTitle => 'Безпека';

  @override
  String get settingsKeyBackup => 'Резервне копіювання ключів';

  @override
  String get settingsBackupEncryptionKeys => 'Резервні ключі шифрування';

  @override
  String settingsKeysBackedUp(int count) {
    return 'Збережено резервні копії ключів $count';
  }

  @override
  String get settingsBackupNotSet => 'Резервне копіювання не встановлено';

  @override
  String get settingsRestoreKeys => 'Відновити ключі';

  @override
  String get settingsRestoreKeysFromBackup =>
      'Відновити ключі шифрування з резервної копії';

  @override
  String get settingsExportKeys => 'Ключі експорту';

  @override
  String get settingsExportKeysToFile => 'Експортувати ключі у файл';

  @override
  String get settingsLoggedInDevices => 'Пристрої, на яких виконано вхід';

  @override
  String get settingsNoOtherDevices => 'Немає інших пристроїв';

  @override
  String get settingsVerified => 'Перевірено';

  @override
  String get settingsUnverified => 'Неперевірений';

  @override
  String get settingsAdvanced => 'Просунутий';

  @override
  String get settingsCrossSigning => 'Перехресне підписання';

  @override
  String get settingsEnabled => 'Увімкнено';

  @override
  String get settingsNotEnabled => 'Не включено';

  @override
  String get settingsResetEncryption => 'Скинути шифрування';

  @override
  String get settingsDeleteAllEncryptionKeys => 'Видалити всі ключі шифрування';

  @override
  String get settingsEncryptionNotSupported => 'Шифрування не підтримується';

  @override
  String get settingsNotInitialized => 'Не ініціалізовано';

  @override
  String get settingsBackupKeyTitle => 'Резервні ключі';

  @override
  String get settingsBackupKeyMessage =>
      'Створити нову резервну копію ключа? Це допоможе вам відновити зашифровані повідомлення на новому пристрої.';

  @override
  String get settingsBackup => 'Резервне копіювання';

  @override
  String get settingsRestoreKeyTitle => 'Відновити ключі';

  @override
  String get settingsRestoreKeyMessage =>
      'Введіть свій пароль відновлення або ключ відновлення, щоб відновити зашифровані повідомлення.';

  @override
  String get settingsRestore => 'Відновити';

  @override
  String get settingsExportKeyTitle => 'Ключі експорту';

  @override
  String get settingsExportKeyMessage =>
      'Експортований файл ключа містить усі ваші ключі шифрування. Будь ласка, бережіть його в безпеці.';

  @override
  String get settingsExport => 'Експорт';

  @override
  String settingsDeviceIdLabel(String deviceId) {
    return 'ID пристрою: $deviceId';
  }

  @override
  String get settingsDeviceStatusVerified => 'Статус: перевірено';

  @override
  String get settingsDeviceStatusUnverified => 'Статус: не перевірено';

  @override
  String settingsLastActiveLabel(String lastSeen) {
    return 'Остання активність: $lastSeen';
  }

  @override
  String get settingsVerifyThisDevice => 'Підтвердьте цей пристрій';

  @override
  String get settingsCrossSigningAlreadyEnabled =>
      'Перехресне підписання вже ввімкнено';

  @override
  String get settingsCrossSigningSetupSuccess =>
      'Перехресне підписання налаштовано успішно';

  @override
  String get settingsResetEncryptionTitle => 'Скинути шифрування';

  @override
  String get settingsResetEncryptionWarning =>
      'Попередження: це призведе до видалення всіх ваших ключів шифрування. Ви не зможете розшифрувати попередні зашифровані повідомлення. Цю дію не можна скасувати.';

  @override
  String get settingsReset => 'Скинути';

  @override
  String get settingsBackupSuccess => 'Резервну копію ключів успішно створено';

  @override
  String get settingsBackupFailed => 'Помилка резервного копіювання';

  @override
  String get settingsRecoveryKey => 'Ключ відновлення';

  @override
  String get settingsRecoveryKeySaveWarning =>
      'Збережіть цей ключ відновлення в безпечному місці. Він знадобиться вам, щоб відновити зашифровані повідомлення на новому пристрої.';

  @override
  String get settingsRecoveryKeySaved => 'Я зберіг його';

  @override
  String get settingsRestoreSuccess => 'Ключі успішно відновлені';

  @override
  String get settingsRestoreFailed => 'Не вдалося відновити';

  @override
  String get settingsPassword => 'Пароль';

  @override
  String get settingsEnterRecoveryKey => 'Введіть ключ відновлення';

  @override
  String get settingsEnterPassword => 'Введіть пароль';

  @override
  String get settingsExportSuccess =>
      'Ключі успішно експортовано в резервну копію сервера';

  @override
  String get settingsExportNeedBackupFirst =>
      'Спершу створіть резервну копію ключа';

  @override
  String get settingsExportFailed => 'Помилка експорту';

  @override
  String get settingsResetSuccess => 'Скидання шифрування успішне';

  @override
  String get settingsResetFailed => 'Помилка скидання';

  @override
  String get callLeaveMeetingConfirm =>
      'Ви впевнені, що бажаєте залишити зустріч?';

  @override
  String chatPokedSomeone(String name, String suffix) {
    return 'тицьнув $name$suffix';
  }

  @override
  String get chatNoContactsToAdd => 'Немає доступних контактів для додавання';

  @override
  String get chatAddMembers => 'Додати учасників';

  @override
  String chatInvitedMembers(int count) {
    return 'Запрошені члени $count';
  }

  @override
  String chatInviteFailed(String error) {
    return 'Помилка запрошення: $error';
  }

  @override
  String get chatMemberRemoved => 'Учасника видалено';

  @override
  String chatRemoveFailed(String error) {
    return 'Не вдалося видалити: $error';
  }

  @override
  String get chatRealTimeLocationShareMessage =>
      'Після надсилання інша сторона може бачити ваше місцезнаходження в реальному часі протягом 1 години.';

  @override
  String get chatStartSharing => 'Почніть ділитися';

  @override
  String get chatLocationServiceNotEnabled => 'Службу локації не ввімкнено';

  @override
  String get chatEnableLocationService =>
      'Увімкніть службу визначення місцезнаходження, щоб використовувати цю функцію';

  @override
  String get chatGoToSettings => 'Перейдіть до Налаштувань';

  @override
  String get chatLocationPermissionRequired =>
      'Для цієї функції потрібен дозвіл на місцезнаходження';

  @override
  String get chatLocationPermissionDeniedPermanent =>
      'Дозвіл на визначення місцезнаходження назавжди відмовлено. Увімкніть його в налаштуваннях.';

  @override
  String get chatLocationPermissionDenied =>
      'Дозвіл на місцезнаходження відмовлено';

  @override
  String get chatGettingLocation => 'Отримання місцезнаходження...';

  @override
  String chatGetLocationFailed(String error) {
    return 'Не вдалося отримати місцезнаходження: $error';
  }

  @override
  String get chatMapPreview => 'Попередній перегляд карти';

  @override
  String get chatSearchLocation => 'Місце пошуку';

  @override
  String chatRedPacketSent(String amount, String token) {
    return 'Надіслано червоний пакет $amount $token';
  }

  @override
  String get chatTransferDefault => 'Трансфер';

  @override
  String chatTransferSent(String amount, String token) {
    return 'Надіслано переказ $amount $token';
  }

  @override
  String chatPickFileFailed(String error) {
    return 'Не вдалося вибрати файл: $error';
  }

  @override
  String get chatFileSizeLimit => 'Розмір файлу не може перевищувати 50 МБ';

  @override
  String chatFileSending(String filename) {
    return 'Надсилання файлу: $filename';
  }

  @override
  String chatSendFileFailed(String error) {
    return 'Не вдалося надіслати файл: $error';
  }

  @override
  String chatContactCardSent(String name) {
    return 'Надіслано контактну картку $name';
  }

  @override
  String get chatFavoritesFeature => 'Вибране';

  @override
  String get chatCouponsFeature => 'Купони';

  @override
  String get chatGiftFeature => 'Подарунок';

  @override
  String chatSharedMusic(String name) {
    return 'Поділився $name';
  }

  @override
  String get chatEndPollTitle => 'Завершити опитування';

  @override
  String get chatEndPollConfirmMessage =>
      'Ви впевнені, що бажаєте завершити це опитування? Після закінчення голосування буде закрито.';

  @override
  String get chatPollEndedMessage => 'Опитування завершено';

  @override
  String get chatConnectingCall => 'Підключення...';

  @override
  String get chatMuteCall => 'Вимкнути звук';

  @override
  String get chatSpeakerOff => 'Динамік вимкнено';

  @override
  String get chatSpeakerOn => 'Спікер';

  @override
  String get chatCameraOn => 'Камера включена';

  @override
  String get chatCameraOff => 'Камера вимкнена';

  @override
  String get chatHangUp => 'Повісити трубку';

  @override
  String get chatSelectForwardTargetTitle => 'Виберіть Переслати ціль';

  @override
  String get chatNoForwardableChat => 'Немає чатів, доступних для пересилання';

  @override
  String get chatNoMatchingChat => 'Відповідних чатів не знайдено';

  @override
  String get chatLocationTitle => 'Розташування';

  @override
  String get chatSendButton => 'Надіслати';

  @override
  String get chatRetryButton => 'Повторіть спробу';

  @override
  String get chatSearchContactHint => 'Пошук контактів';

  @override
  String get chatShareMusic => 'Поділіться музикою';

  @override
  String get chatRecentPlayed => 'Останні';

  @override
  String get chatMyFavorites => 'Вибране';

  @override
  String get chatNetworkLink => 'Посилання';

  @override
  String get chatLocalFile => 'Місцевий';

  @override
  String get chatPasteMusicLink => 'Вставте посилання на музику';

  @override
  String get chatShareMusicButton => 'Поділіться музикою';

  @override
  String get chatSelectLocalAudio => 'Виберіть Локальний аудіофайл';

  @override
  String get chatSupportedAudioFormats => 'Підтримує MP3, M4A, WAV, FLAC тощо.';

  @override
  String get chatSelectFileButton => 'Виберіть Файл';

  @override
  String get chatPleaseEnterMusicLink => 'Введіть посилання на музику';

  @override
  String get chatPleaseEnterValidLink => 'Введіть дійсну URL-адресу';

  @override
  String get chatSharedSong => 'Спільна пісня';

  @override
  String get chatSelectMember => 'Виберіть Член';

  @override
  String get chatSearchMemberHint => 'Пошук учасників';

  @override
  String get chatNoMatchingMembers => 'Відповідних учасників не знайдено';

  @override
  String get commonUnknownMember => 'Невідомий';

  @override
  String chatSelectedMessagesCount(int count) {
    return 'Вибрані повідомлення $count';
  }

  @override
  String get chatSearchContactsOrGroups => 'Пошук контактів або груп';

  @override
  String get chatVideoTitle => 'відео';

  @override
  String get chatLoadingText => 'Завантаження...';

  @override
  String get chatVideoLoadFailed => 'Помилка завантаження відео';

  @override
  String get chatPlayerInitFailed => 'Помилка ініціалізації програвача';

  @override
  String get chatCreatePollTitle => 'Створити опитування';

  @override
  String get chatSubmitPoll => 'Надіслати';

  @override
  String get chatPollQuestionLabel => 'Опитування';

  @override
  String get chatEnterPollQuestionHint => 'Введіть запитання опитування';

  @override
  String get chatPollOptionsLabel => 'Опції опитування';

  @override
  String chatOptionHintWithIndex(int index) {
    return 'Варіант $index';
  }

  @override
  String get chatAddOptionButton => 'Додати варіант';

  @override
  String get chatPollSettingsLabel => 'Налаштування опитування';

  @override
  String get chatSelectionType => 'Тип вибору';

  @override
  String get chatSingleChoiceLabel => 'неодружений';

  @override
  String get chatMultiChoiceLabel => 'Мульти';

  @override
  String get chatAnonymousPollSwitch => 'Анонімне опитування';

  @override
  String get chatPleaseEnterQuestion => 'Введіть запитання опитування';

  @override
  String get chatAtLeastTwoOptions => 'Потрібно принаймні 2 варіанти';

  @override
  String chatConfirmWithCount(int count) {
    return 'Підтвердити ($count)';
  }

  @override
  String get authEmailVerificationTitle => 'Підтвердження електронної пошти';

  @override
  String get authEnterValidEmailAddress => 'Введіть дійсну електронну адресу';

  @override
  String authVerificationCodeSentTo(String email) {
    return 'Код підтвердження надіслано на $email';
  }

  @override
  String authSendCodeFailed(String error) {
    return 'Не вдалося надіслати код: $error';
  }

  @override
  String get authVerificationSuccess => 'Перевірка успішна';

  @override
  String get authVerificationFailed => 'Не вдалося перевірити';

  @override
  String authVerificationCodeError(String error) {
    return 'Помилка коду підтвердження: $error';
  }

  @override
  String get commonEnterVerificationCode => 'Введіть код підтвердження';

  @override
  String get authEnterYourEmail => 'Введіть адресу електронної пошти';

  @override
  String authWeSentCodeTo(String email) {
    return 'Ми надіслали 6-значний код на адресу\n$email';
  }

  @override
  String get authEnterEmailForCode =>
      'Введіть адресу електронної пошти, ми надішлемо код підтвердження';

  @override
  String get commonSendVerificationCode => 'Надіслати код підтвердження';

  @override
  String get authResendVerificationCode =>
      'Повторно надіслати код підтвердження';

  @override
  String authCanResendAfter(int seconds) {
    return 'Можна повторно надіслати через $seconds секунд';
  }

  @override
  String get commonChangeEmail => 'Змінити електронну адресу';

  @override
  String get contactAddToContacts => 'Додати до контактів';

  @override
  String get contactAddingToContacts => 'Додавання...';

  @override
  String get contactAddedToContacts => 'Додано до контактів';

  @override
  String contactAddFailedWithError(String error) {
    return 'Не вдалося додати: $error';
  }

  @override
  String get contactAddPhone => 'Додати телефон';

  @override
  String get contactAddTag => 'Додайте теги';

  @override
  String get contactAddText => 'Додайте текст';

  @override
  String get contactAddPhoto => 'Додайте фото';

  @override
  String contactGroupCountLabel(int count) {
    return 'Групи $count';
  }

  @override
  String get contactAddedViaSearch => 'Додано через пошук';

  @override
  String get contactAddTime => 'Додайте час';

  @override
  String get contactDoneButton => 'Готово';

  @override
  String get callWaitingForParticipants => 'Чекаємо на приєднання учасників...';

  @override
  String callParticipantMe(String name) {
    return '$name (Я)';
  }

  @override
  String get callSharingLabel => 'Обмін';

  @override
  String callScreenSharingBy(String name) {
    return '$name ділиться екраном';
  }

  @override
  String callParticipantCount(int count) {
    return '$count учасників';
  }

  @override
  String get callMuteLabel => 'Вимкнути звук';

  @override
  String get callUnmuteLabel => 'Увімкнути звук';

  @override
  String get callTurnOffVideo => 'Вимкніть відео';

  @override
  String get callTurnOnVideo => 'Увімкніть відео';

  @override
  String get callShareScreen => 'Поділитися екраном';

  @override
  String get callStopSharing => 'Припинити ділитися';

  @override
  String get callSwitchCameraLabel => 'Перемикач';

  @override
  String get callLeaveLabel => 'Залиште';

  @override
  String get callParticipantsLabel => 'Учасники';

  @override
  String get callJoiningMeeting => 'Приєднання до зустрічі...';

  @override
  String chatPollVotesFormat(int count, String percentage) {
    return '$count голосів ($percentage%)';
  }

  @override
  String chatPollParticipantsFormat(int count) {
    return '$count учасників';
  }

  @override
  String get commonTapToRetry => 'Торкніться, щоб повторити спробу';

  @override
  String get chatDefaultRedPacketGreeting => 'Найкращі побажання процвітання';

  @override
  String get groupAllowOthersToSearchAndJoin =>
      'Дозвольте іншим шукати та приєднуватися';

  @override
  String get groupConfirmClearChatHistory =>
      'Ви впевнені, що бажаєте очистити історію чату?';

  @override
  String get groupCreateGroupToChat =>
      'Створіть групу, щоб розпочати спілкування';

  @override
  String get groupEditGroupAnnouncement => 'Редагувати оголошення групи';

  @override
  String get groupEditGroupDescription => 'Редагувати опис групи';

  @override
  String get groupEnterGroupAnnouncement => 'Введіть групове оголошення';

  @override
  String chatErrorWithMessage(String message) {
    return 'Помилка: $message';
  }

  @override
  String groupMemberCountClickToCopy(int count) {
    return 'Учасники $count, натисніть, щоб скопіювати ідентифікатор групи';
  }

  @override
  String get chatMusicLinkLabel => 'Посилання на музику';

  @override
  String get chatNoMediaUrlAvailable => 'Немає доступної URL-адреси медіа';

  @override
  String get groupNoPermissionToEditGroupName =>
      'Ви не маєте дозволу редагувати назву групи';

  @override
  String get chatRedPacketTransferCannotForward =>
      'Червоні пакети та перекази не пересилаються';

  @override
  String get authEmailAddress => 'Адреса електронної пошти';

  @override
  String get commonEnterEmailAddress => 'Введіть електронну адресу';

  @override
  String get authEmailRecoveryHint => 'Використовується для відновлення пароля';

  @override
  String get commonInvalidEmailFormat => 'Введіть дійсну електронну адресу';

  @override
  String get authOptional => 'Додатково';

  @override
  String get authResetPassword => 'Скинути пароль';

  @override
  String get authEnterRegisteredEmail =>
      'Введіть адресу електронної пошти, яку ви зареєстрували';

  @override
  String get authSendResetCode => 'Надіслати код скидання';

  @override
  String authResetCodeSent(String email) {
    return 'Код скидання, надісланий на $email';
  }

  @override
  String get authEnterResetCode => 'Введіть код скидання';

  @override
  String get authSetNewPassword => 'Встановити новий пароль';

  @override
  String get commonConfirmNewPassword => 'Підтвердьте новий пароль';

  @override
  String get commonNewPassword => 'Новий пароль';

  @override
  String get authPasswordResetSuccess =>
      'Скидання пароля успішне. Будь ласка, увійдіть з новим паролем.';

  @override
  String get authResetPasswordFailed => 'Не вдалося скинути пароль';

  @override
  String get settingsChangePassword => 'Змінити пароль';

  @override
  String get settingsCurrentPassword => 'Поточний пароль';

  @override
  String get settingsEnterCurrentPassword => 'Введіть поточний пароль';

  @override
  String get settingsEnterNewPassword => 'Введіть новий пароль';

  @override
  String get settingsPasswordChanged =>
      'Пароль успішно змінено. Будь ласка, увійдіть з новим паролем.';

  @override
  String get settingsChangePasswordFailed => 'Не вдалося змінити пароль';

  @override
  String get settingsNewPasswordMustBeDifferent =>
      'Новий пароль має відрізнятися від поточного';

  @override
  String get settingsChangePasswordInfo =>
      'Після зміни пароля ви вийдете з системи, і вам потрібно буде увійти з новим паролем.';

  @override
  String get settingsPasswordRequirements => 'Вимоги до пароля:';

  @override
  String get settingsSecurityNote =>
      'З міркувань безпеки вам потрібно буде повторно ввійти на всіх пристроях після зміни пароля.';

  @override
  String get settingsSecurity => 'Безпека';

  @override
  String get settingsCurrentBoundEmail =>
      'Поточний прив\'язаний електронний лист';

  @override
  String get settingsNewEmailAddress => 'Нова електронна адреса';

  @override
  String get settingsEnterNewEmail => 'Введіть нову електронну адресу';

  @override
  String get settingsVerificationCode => 'Код підтвердження';

  @override
  String get settingsVerificationCodeSent => 'Код підтвердження надіслано';

  @override
  String get settingsCodeSentTo => 'Код підтвердження надіслано';

  @override
  String get settingsDidNotReceiveCode => 'Не отримали код?';

  @override
  String get settingsEmailChangedSuccess => 'Електронну адресу змінено успішно';

  @override
  String get settingsChangeEmailFailed =>
      'Не вдалося змінити електронну адресу';

  @override
  String get settingsEmailSecurityNote =>
      'Ваша електронна пошта використовується для відновлення пароля. Будь ласка, тримайте його в безпеці.';

  @override
  String get commonGoogleLogin => 'Увійдіть за допомогою Google';

  @override
  String get commonAppleLogin => 'Увійдіть за допомогою Apple';

  @override
  String get commonWechat => 'WeChat';

  @override
  String get settingsLanguage => 'Мова';

  @override
  String get settingsLanguageChanged => 'Мова змінена';

  @override
  String get settingsTranslation => 'Переклад';

  @override
  String get settingsTranslateTextTo => 'Перекласти текст на';

  @override
  String get settingsTranslateDescription =>
      'Виберіть мову, на яку потрібно перекладати повідомлення.';

  @override
  String get settingsAutoTranslate =>
      'Автоматичний переклад отриманих повідомлень';

  @override
  String get settingsAutoTranslateDescription =>
      'Автоматично перекладайте повідомлення, отримані в чаті, на вибрану мову.';

  @override
  String get settingsBiometricLogin => 'Біометричний логін';

  @override
  String authLoginWithBiometric(Object type) {
    return 'Увійдіть за допомогою $type';
  }

  @override
  String get settingsBiometricLoginEnabled => 'Біометричний вхід увімкнено';

  @override
  String get settingsBiometricLoginDisabled => 'Біометричний вхід вимкнено';

  @override
  String get settingsEnableBiometricLogin => 'Увімкнути біометричний вхід';

  @override
  String get settingsBiometricEnabled =>
      'Увімкнено – використовувати біометричні дані для входу';

  @override
  String get settingsBiometricDisabled =>
      'Вимкнено – торкніться, щоб увімкнути';

  @override
  String get settingsBiometricNeedRelogin =>
      'Будь ласка, вийдіть із системи та увійдіть знову, щоб увімкнути біометричний вхід';

  @override
  String get authOr => 'АБО';

  @override
  String get qrcodeCameraPermissionRestricted =>
      'Доступ до камери на цьому пристрої обмежено';

  @override
  String get authPasskeyLabel => 'Ключ доступу';

  @override
  String get authGoogleLabel => 'Google';

  @override
  String get authAppleLabel => 'Яблуко';

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
      'Введіть суфікс тицьнути, наприклад: на плечі';

  @override
  String get groupAlbum => 'Альбом групи';

  @override
  String get groupFiles => 'Файли групи';

  @override
  String get groupImages => 'Зображення';

  @override
  String get groupVideos => 'Відео';

  @override
  String get groupTotal => 'Всього';

  @override
  String get groupSize => 'Розмір';

  @override
  String get groupNoMedia => 'Без медіа';

  @override
  String get groupNoMediaDescription => 'У цій групі ще немає фото чи відео';

  @override
  String get groupDocuments => 'документи';

  @override
  String get groupNoFiles => 'Немає файлів';

  @override
  String get groupNoFilesDescription => 'У цій групі ще немає файлів';

  @override
  String groupDownloadStarted(String filename) {
    return 'Завантаження $filename...';
  }

  @override
  String get contactNoCommonGroups => 'Немає спільних груп';

  @override
  String get contactNoCommonGroupsDescription => 'У вас немає спільних груп';

  @override
  String get chatVoiceMessage => 'Голос';

  @override
  String get chatMessage => 'повідомлення';

  @override
  String get conversationHideChat => 'Сховати';

  @override
  String get settingsQuickReply => 'Швидка відповідь';

  @override
  String get commonTranslate => 'Перекласти';

  @override
  String get contactCreateTag => 'Створити тег';

  @override
  String get contactEnterTagName => 'Введіть назву тегу';

  @override
  String get contactEditTag => 'Редагувати тег';

  @override
  String get contactDeleteTag => 'Видалити тег';

  @override
  String contactDeleteTagConfirm(String tagName) {
    return 'Ви впевнені, що хочете видалити тег \"$tagName\"?';
  }

  @override
  String get contactNoTags => 'Тегів ще немає';

  @override
  String get contactFriendPermissions => 'Дозволи друзів';

  @override
  String get contactSetChatOnly => 'Установити лише для чату';

  @override
  String get contactChatOnlyDesc =>
      'Можна спілкуватися лише з вами, інший вміст буде приховано';

  @override
  String get contactHideMyMoments => 'Приховати мої моменти';

  @override
  String get contactHideMyMomentsDesc => 'Цей друг не може бачити мої моменти';

  @override
  String get contactHideTheirMoments => 'Приховати їхні моменти';

  @override
  String get contactHideTheirMomentsDesc => 'Не бачити моменти цього друга';

  @override
  String get contactHideMyStatus => 'Приховати мій статус';

  @override
  String get contactHideMyStatusDesc =>
      'Цей друг не може бачити оновлення мого статусу';

  @override
  String get contactNoChatOnlyFriends =>
      'Без друзів, які спілкуються лише в чаті';

  @override
  String get contactNoOfficialAccounts => 'Немає офіційних облікових записів';

  @override
  String get contactFollowOfficialAccountsDesc =>
      'Слідкуйте за офіційними акаунтами, щоб отримувати останні оновлення';

  @override
  String get contactNoServiceAccounts => 'Немає сервісних облікових записів';

  @override
  String get contactSubscribeServiceAccountsDesc =>
      'Підпишіться на сервісні акаунти, щоб отримати зручні послуги';

  @override
  String get contactNoEnterpriseContacts => 'Немає контактів підприємства';

  @override
  String get contactEnterpriseContactsDesc =>
      'Тут відображатимуться контакти підприємства';

  @override
  String get profileCardPack => 'Пакет карток';

  @override
  String get profileOrders => 'Замовлення';

  @override
  String get profileNoOrders => 'Без замовлень';

  @override
  String get profileOrdersDesc => 'Тут відображатимуться ваші замовлення';

  @override
  String get profileNoCards => 'Без карток';

  @override
  String get profileCardsDesc => 'Тут відображатимуться ваші картки';

  @override
  String get favoriteEnterTagsHint => 'Введіть теги, розділені комами';

  @override
  String get favoriteTagsUpdated => 'Теги оновлено';

  @override
  String get favoriteForwardedContent => 'Вміст переслано';

  @override
  String get favoriteEnterNoteContent => 'Введіть вміст нотатки';

  @override
  String get favoriteNoteAdded => 'Примітка додана';

  @override
  String get favoriteLinkTitle => 'Назва посилання';

  @override
  String get favoriteLinkUrl => 'https://';

  @override
  String get favoriteLinkAdded => 'Посилання додано';

  @override
  String get contactPhotoAdded => 'Фото додано';

  @override
  String get contactEnterPhone => 'Введіть номер телефону';

  @override
  String commonConversationWithId(String roomId) {
    return 'Розмова: $roomId';
  }

  @override
  String commonContactWithId(String userId) {
    return 'Контакт: $userId';
  }

  @override
  String get commonDiscover => 'Відкрийте для себе';

  @override
  String commonDeveloping(String title) {
    return '$title\n(Незабаром)';
  }

  @override
  String get commonPageNotFound => 'Сторінка не знайдена';

  @override
  String get commonBackToHome => 'Назад додому';

  @override
  String get settingsMessageNotifications => 'Сповіщення про повідомлення';

  @override
  String get settingsReceiveNewMessageNotifications =>
      'Отримувати сповіщення про нові повідомлення';

  @override
  String get settingsShowMessagePreview =>
      'Показати попередній перегляд повідомлення';

  @override
  String get settingsShowMessageContentInNotification =>
      'Показати вміст повідомлення в сповіщенні';

  @override
  String get settingsNotificationSound => 'Звук сповіщення';

  @override
  String get settingsPlaySoundOnMessage =>
      'Відтворення звуку під час отримання повідомлень';

  @override
  String get commonVibration => 'Вібрація';

  @override
  String get settingsVibrateOnMessage =>
      'Вібрувати під час отримання повідомлень';

  @override
  String get settingsDoNotDisturbMode => 'Не турбувати';

  @override
  String get settingsDoNotDisturbDescription =>
      'Не отримувати сповіщення протягом зазначеного часу';

  @override
  String get settingsStartTime => 'Час початку';

  @override
  String get settingsEndTime => 'Час закінчення';

  @override
  String get settingsDeleteQuickReply => 'Видалити швидку відповідь';

  @override
  String get settingsEditQuickReply => 'Редагувати швидку відповідь';

  @override
  String get settingsAddQuickReply => 'Додати швидку відповідь';

  @override
  String get settingsManageQuickReplies => 'Керуйте швидкими відповідями';

  @override
  String get settingsNoQuickReplies => 'Немає швидких відповідей';

  @override
  String get settingsDefaultQuickReplies =>
      'Відображатимуться стандартні швидкі відповіді';

  @override
  String get settingsWhoCanSee => 'Хто бачить';

  @override
  String get settingsLastSeen => 'Останній раз';

  @override
  String get settingsHiddenChats => 'Приховані чати';

  @override
  String get settingsMessagesLabel => 'Повідомлення';

  @override
  String get settingsAllowStrangerMessages =>
      'Дозволити незнайомі повідомлення';

  @override
  String get settingsReceiveMessagesFromNonContacts =>
      'Отримувати повідомлення від неконтактних осіб';

  @override
  String get settingsReadReceipts => 'Прочитати квитанції';

  @override
  String get settingsLetOthersKnowYouRead => 'Нехай інші знають, що ви читаєте';

  @override
  String get settingsTypingIndicator => 'Індикатор набору тексту';

  @override
  String get settingsLetOthersKnowYouTyping =>
      'Нехай інші знають, що ви друкуєте';

  @override
  String get settingsEveryone => 'Всі';

  @override
  String get settingsContactsOnly => 'Лише контакти';

  @override
  String get settingsNobody => 'ніхто';

  @override
  String settingsWhoCanSeeTitle(String title) {
    return 'Хто може бачити $title';
  }

  @override
  String settingsVersionInfo(String version) {
    return 'Версія $version';
  }

  @override
  String get settingsCheckForUpdates => 'Перевірте наявність оновлень';

  @override
  String get settingsOpenSourceLicenses => 'Ліцензії з відкритим кодом';

  @override
  String get settingsFeedbackAndSuggestions => 'Відгуки та пропозиції';

  @override
  String get settingsBuiltOnMatrix => 'Побудований на основі протоколу Matrix';

  @override
  String get settingsNoHiddenChats => 'Жодних прихованих чатів';

  @override
  String get settingsNoHiddenChatsDescription =>
      'Чати, які ви приховуєте, відображатимуться тут';

  @override
  String get settingsUnhideChat => 'Показати';

  @override
  String get settingsDarkMode => 'Темний режим';

  @override
  String get settingsFontSize => 'Розмір шрифту';

  @override
  String get settingsBubbleStyle => 'Стиль бульбашки';

  @override
  String get settingsFollowSystem => 'Слідкуйте за системою';

  @override
  String get settingsAutoSwitchBySystem => 'Автоматичне перемикання системою';

  @override
  String get settingsLightMode => 'Світловий режим';

  @override
  String get settingsAlwaysUseLightTheme => 'Завжди використовуйте світлу тему';

  @override
  String get settingsDarkModeOption => 'Опція темного режиму';

  @override
  String get settingsAlwaysUseDarkTheme => 'Завжди використовуйте темну тему';

  @override
  String get settingsFontSizeSmall => 'Маленький';

  @override
  String get settingsFontSizeStandard => 'Стандартний';

  @override
  String get settingsFontSizeLarge => 'Великий';

  @override
  String get settingsFontSizeExtraLarge => 'Дуже великий';

  @override
  String get settingsBubbleStyleWechat => 'Стиль WeChat';

  @override
  String get settingsBubbleStyleWechatDesc =>
      'Класичний стиль бульбашки WeChat';

  @override
  String get settingsBubbleStyleModern => 'Сучасний стиль';

  @override
  String get settingsBubbleStyleModernDesc => 'Чистий сучасний стиль міхура';

  @override
  String get settingsBubbleStyleClassic => 'Класичний стиль';

  @override
  String get settingsBubbleStyleClassicDesc => 'Традиційний стиль бульбашок';

  @override
  String get discoverVideoChannels => 'Канали';

  @override
  String get discoverLive => 'Жити';

  @override
  String get discoverListen => 'Слухай';

  @override
  String get discoverWatch => 'Дивитися';

  @override
  String get discoverSearchDiscover => 'Пошук';

  @override
  String get discoverNearbyPeople => 'Поруч';

  @override
  String get discoverGames => 'Ігри';

  @override
  String get discoverMiniPrograms => 'Міні програми';

  @override
  String get chatAlreadyInCall => 'Уже в дзвінку';

  @override
  String get commonConnectionFailed => 'Помилка підключення';

  @override
  String get chatCallRejected => 'Дзвінок відхилено';

  @override
  String get chatNoAnswer => 'Відповіді немає';

  @override
  String get commonClose => 'Закрити';

  @override
  String get chatSelectContact => 'Виберіть Контакт';

  @override
  String get chatVoteRemoved => 'Голос видалено';

  @override
  String get chatVoteChanged => 'Голосування змінено';

  @override
  String get chatVoted => 'Проголосував';

  @override
  String chatReplyTo(String name) {
    return 'Відповісти $name';
  }

  @override
  String get chatCurrentLocation => 'Поточне місцезнаходження';

  @override
  String chatNearbyPlace(int index) {
    return 'Місце поблизу $index';
  }

  @override
  String chatApproximateDistance(String distance) {
    return 'Про $distance';
  }

  @override
  String get chatAddress => 'Адреса';

  @override
  String get chatLatitude => 'Широта';

  @override
  String get chatLongitude => 'Довгота';

  @override
  String get groupDescriptionUpdated => 'Оновлено опис групи';

  @override
  String get groupAvatarUpdated => 'Аватар групи оновлено';

  @override
  String get groupVisibilityUpdated => 'Видимість групи оновлено';

  @override
  String get groupChannelCreated => 'Канал створено';

  @override
  String get groupChannelUpdated => 'Канал оновлено';

  @override
  String get groupChannelDeleted => 'Канал видалено';

  @override
  String get callDecline => 'відхилити';

  @override
  String get callAnswer => 'Відповідь';

  @override
  String get callIncomingVideoCall => 'Вхідний відеодзвінок';

  @override
  String get callIncomingVoiceCall => 'Вхідний голосовий виклик';

  @override
  String get callVideoCallInProgress => 'Триває відеодзвінок';

  @override
  String get callVoiceCallInProgress => 'Виконується голосовий виклик';

  @override
  String get callReconnectingCall => 'Повторне підключення...';

  @override
  String get callEnded => 'Дзвінок завершено';

  @override
  String get callFailed => 'Помилка виклику';

  @override
  String get callLivekitNotConfigured => 'LiveKit не налаштовано';

  @override
  String callJoinMeetingFailed(String error) {
    return 'Не вдалося приєднатися до зустрічі: $error';
  }

  @override
  String callScreenShareFailed(String error) {
    return 'Не вдалося поділитися екраном: $error';
  }

  @override
  String get profileN42BeanTitle => 'N42 Бін';

  @override
  String get profileNoN42Bean => 'Ні N42 Bean';

  @override
  String get profileN42BeanDetails => 'N42 Bean Деталі';

  @override
  String get profileN42BeanDescription =>
      'N42 Bean — це маркер, який використовується для викупу віртуальних предметів і послуг у N42. На даний момент доступний для:';

  @override
  String get profileN42BeanFeature1 =>
      'Ексклюзивні наклейки та теми для учасників';

  @override
  String get profileN42BeanFeature2 => 'Налаштування спливаючої підказки чату';

  @override
  String get profileN42BeanFeature3 =>
      'Налаштування червоної обкладинки пакета';

  @override
  String get profileN42BeanFeature4 => 'Ексклюзивний значок з псевдонімом';

  @override
  String get profileN42BeanFeature5 => 'Привілеї групового чату';

  @override
  String get profileN42BeanFeature6 => 'Розширення хмарного сховища';

  @override
  String get profileN42BeanFeature7 => 'Фільтри краси для відеодзвінків';

  @override
  String get profileN42BeanFeature8 => 'Налаштування фону моментів';

  @override
  String get profileN42BeanFeature9 => 'Пріоритет обслуговування клієнтів VIP';

  @override
  String get profileGotIt => 'зрозумів';

  @override
  String get profileNoN42BeanRecords => 'Немає записів N42 Bean';

  @override
  String get profileMoodAndThoughts => 'Настрій і думки';

  @override
  String get profileStatusHappy => 'Щаслива';

  @override
  String get profileStatusCracked => 'Розбитий';

  @override
  String get profileStatusLucky => 'Щасливчик';

  @override
  String get profileStatusSunny => 'Сонячно';

  @override
  String get profileStatusTired => 'Втомилася';

  @override
  String get profileStatusDaydream => 'мрія';

  @override
  String get profileStatusRushing => 'Поспіх';

  @override
  String get profileStatusOverthinking => 'Надмірне мислення';

  @override
  String get profileStatusEnergized => 'Під напругою';

  @override
  String get profileWorkAndStudy => 'Робота та навчання';

  @override
  String get profileStatusWorking => 'Працює';

  @override
  String get profileStatusStudying => 'навчання';

  @override
  String get profileStatusBusy => 'зайнятий';

  @override
  String get profileStatusSlacking => 'розхитування';

  @override
  String get profileStatusTraveling => 'Подорожі';

  @override
  String get profileStatusGoingHome => 'Йду додому';

  @override
  String get profileStatusDnd => 'Не турбувати';

  @override
  String get profileActivities => 'Діяльність';

  @override
  String get profileStatusHanging => 'Тусовка';

  @override
  String get profileStatusCheckIn => 'Заїзд';

  @override
  String get profileStatusExercising => 'Заняття спортом';

  @override
  String get profileStatusCoffee => 'кава';

  @override
  String get profileStatusBubbleTea => 'Bubble Tea';

  @override
  String get profileStatusEating => 'прийом їжі';

  @override
  String get profileStatusParenting => 'Виховання дітей';

  @override
  String get profileStatusSavingWorld => 'Порятунок світу';

  @override
  String get profileStatusSelfie => 'Селфі';

  @override
  String get profileRest => 'Відпочинок';

  @override
  String get profileStatusRetreat => 'Відступ';

  @override
  String get profileStatusHome => 'додому';

  @override
  String get profileStatusSleeping => 'спить';

  @override
  String get profileStatusCatLover => 'Любитель кішок';

  @override
  String get profileStatusDogWalking => 'Вигул собаки';

  @override
  String get profileStatusGaming => 'Ігри';

  @override
  String get profileStatusListening => 'Слухання';

  @override
  String get profileEditAddress => 'Редагувати адресу';

  @override
  String get profileRecipient => 'одержувач';

  @override
  String get profileEnterRecipientName => 'Введіть ім\'я одержувача';

  @override
  String get profilePhoneNumber => 'Номер телефону';

  @override
  String get profileEnterPhoneNumber => 'Введіть номер телефону';

  @override
  String get profileRegionHint => 'Провінція/місто/район';

  @override
  String get profileDetailedAddress => 'Детальна адреса';

  @override
  String get profileDetailedAddressHint => 'Вулиця, номер будинку тощо.';

  @override
  String get profileSetAsDefaultAddress => 'Встановити як адресу за умовчанням';

  @override
  String get profilePleaseCompleteInfo => 'Будь ласка, заповніть усі поля';

  @override
  String get profileEditInvoice => 'Редагувати рахунок-фактуру';

  @override
  String get profileInvoiceType => 'Тип рахунку-фактури';

  @override
  String get profileCompanyName => 'Назва компанії';

  @override
  String get profilePersonalName => 'Особисте ім\'я';

  @override
  String get profileEnterCompanyName => 'Введіть назву компанії';

  @override
  String get profileEnterName => 'Введіть ім\'я';

  @override
  String get profileTaxIdNumber => 'Ідентифікаційний податковий номер';

  @override
  String get profileEnterTaxIdNumber => 'Введіть податковий номер';

  @override
  String get profileBankNameOptional => 'Назва банку (необов\'язково)';

  @override
  String get profileEnterBankName => 'Введіть назву банку';

  @override
  String get profileBankAccountOptional =>
      'Банківський рахунок (необов\'язково)';

  @override
  String get profileEnterBankAccount => 'Введіть банківський рахунок';

  @override
  String get profileCompanyAddressOptional =>
      'Адреса компанії (необов\'язково)';

  @override
  String get profileEnterCompanyAddress => 'Введіть адресу компанії';

  @override
  String get profileCompanyPhoneOptional => 'Телефон компанії (необов\'язково)';

  @override
  String get profileEnterCompanyPhone => 'Введіть телефон компанії';

  @override
  String get profileSetAsDefaultInvoice =>
      'Встановити як рахунок-фактуру за умовчанням';

  @override
  String get profileRingtoneVibrate => 'Вібрувати';

  @override
  String get profileRingtoneSilent => 'Мовчазний';

  @override
  String get profileVibrateMode => 'Режим вібрації';

  @override
  String get profileSilentMode => 'Безшумний режим';

  @override
  String profilePlayFailed(String ringtoneName) {
    return 'Не вдалося відтворити: $ringtoneName';
  }

  @override
  String profilePlaying(String ringtoneName) {
    return 'Грає: $ringtoneName';
  }

  @override
  String get profileStop => 'Стоп';

  @override
  String get profileSelectRingtone => 'Виберіть Мелодія';

  @override
  String get profileLoadingRingtones => 'Завантаження мелодій...';

  @override
  String get profileNoRingtonesFound => 'Мелодії дзвінка не знайдено';

  @override
  String mainMessagesWithCount(int count) {
    return 'Повідомлення ($count)';
  }

  @override
  String get storyViewers => 'Глядачі';

  @override
  String get storyNoViewers => 'Глядачів ще немає';

  @override
  String get storyReplyToStory => 'Відповісти на історію...';

  @override
  String get commonCopiedToClipboard => 'Скопійовано в буфер обміну';

  @override
  String get commonMore => 'більше';

  @override
  String get commonTranslating => 'Переклад...';

  @override
  String commonTranslatedFrom(String language) {
    return 'Переклад з $language';
  }

  @override
  String get commonTranslation => 'Переклад';

  @override
  String get commonTranslationFailed => 'Помилка перекладу';

  @override
  String get commonAllRead => 'Всі читали';

  @override
  String commonReadCount(int count) {
    return '$count читати';
  }

  @override
  String get commonYouRecalledMessage => 'Ви відкликали повідомлення';

  @override
  String get commonMessageRecalled => 'Повідомлення відкликано';

  @override
  String get commonReEdit => 'Перередагувати';

  @override
  String get commonWalletArea => 'Зона гаманця';

  @override
  String get callIncomingCall => 'Вхідний дзвінок';

  @override
  String get callMissedCall => 'Пропущений дзвінок';

  @override
  String get groupRemoveAdmin => 'Видалити адміністратора';

  @override
  String get chatSelectCurrency => 'Виберіть валюту';

  @override
  String get chatSelectEmoji => 'Виберіть Emoji';

  @override
  String get chatSelectRedPacketCover => 'Виберіть Обкладинка';

  @override
  String get groupSetAsAdmin => 'Встановити як адміністратора';

  @override
  String get chatVideoPlaybackFailed => 'Помилка відтворення відео';

  @override
  String get groupViewProfile => 'Переглянути профіль';

  @override
  String get favoriteAddLinkComingSoon => 'Незабаром додайте функцію посилання';

  @override
  String get favoriteNewNoteComingSoon =>
      'Незабаром з’явиться нова функція нотаток';

  @override
  String get qrcodeSaveFeatureComingSoon =>
      'Незабаром з’явиться функція збереження';

  @override
  String get qrcodeShareFeatureComingSoon =>
      'Незабаром буде доступна функція спільного доступу';

  @override
  String qrcodeProcessFailed(String error) {
    return 'Не вдалося обробити QR-код: $error';
  }

  @override
  String get securityDeviceIdRequired =>
      'Потрібно ввести ідентифікатор пристрою';

  @override
  String securityVerificationStartFailed(String error) {
    return 'Не вдалося розпочати перевірку: $error';
  }

  @override
  String get securityVerificationFailed => 'Не вдалося перевірити';

  @override
  String securityVerificationFailedWithReason(String reason) {
    return 'Не вдалося перевірити: $reason';
  }

  @override
  String get securityEmojiMismatchRejected =>
      'Перевірку відхилено – смайли не збігаються';

  @override
  String get securityWaitingForDeviceAccept =>
      'Очікування на прийняття іншим пристроєм...';

  @override
  String get securityVerifyDevice => 'Підтвердьте цей пристрій';

  @override
  String get securityConfirmEmojiMatch =>
      'Переконайтеся, що наведені нижче смайли відображаються на обох пристроях в однаковому порядку';

  @override
  String get securityEmojiDontMatch => 'Вони не збігаються';

  @override
  String get securityEmojiMatch => 'Вони збігаються';

  @override
  String get securityWaitingForDeviceConfirm =>
      'Очікування підтвердження від іншого пристрою...';

  @override
  String get securityVerificationSuccess => 'Перевірка успішна!';

  @override
  String get securityDeviceVerifiedTrusted =>
      'Цей пристрій тепер перевірено та надійно.';

  @override
  String get securityCompareEmoji => 'Порівняйте емодзі на обох пристроях';

  @override
  String get securityCompareNumbers => 'Порівняйте цифри на обох пристроях';

  @override
  String get commonTryAgain => 'Спробуйте знову';

  @override
  String get commonDone => 'Готово';

  @override
  String get chatExportTitle => 'Експорт чату';

  @override
  String get chatExportSuccess => 'Експорт успішно';

  @override
  String chatExportFailed(String error) {
    return 'Помилка експорту: $error';
  }

  @override
  String get chatExportFormat => 'Формат експорту';

  @override
  String get chatExportHtmlDesc =>
      'Можна читати в будь-якому браузері зі стилізованим макетом';

  @override
  String get chatExportJsonDesc => 'Машиночитаний формат структурованих даних';

  @override
  String get chatExportDateRange => 'Діапазон дат';

  @override
  String get chatExportAll => 'Усі повідомлення';

  @override
  String get chatExportLastWeek => 'Останні 7 днів';

  @override
  String get chatExportLastMonth => 'Останній місяць';

  @override
  String get chatExportLast3Months => 'Останні 3 місяці';

  @override
  String get chatExportMessageCount => 'Повідомлення для експорту';

  @override
  String get chatExportButton => 'Експортуйте та діліться';

  @override
  String get chatMediaGallery => 'Медіа галерея';

  @override
  String get chatExportHistory => 'Експорт історії чату';

  @override
  String get pdfLoadFailed => 'Не вдалося завантажити PDF';

  @override
  String pdfPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get mediaAll => 'всі';

  @override
  String get mediaImages => 'Зображення';

  @override
  String get mediaVideos => 'Відео';

  @override
  String get mediaFiles => 'Файли';

  @override
  String get mediaAudio => 'Аудіо';

  @override
  String mediaItemsCount(int count) {
    return '$count елементів';
  }

  @override
  String get mediaNoMediaFound => 'Медіа не знайдено';

  @override
  String get spacesTitle => 'Спільноти';

  @override
  String get spacesCreate => 'Створити спільноту';

  @override
  String get spacesJoined => 'Приєднався';

  @override
  String get spacesDiscover => 'Відкрийте для себе';

  @override
  String get spacesNoJoined => 'Жодна спільнота ще не приєдналася';

  @override
  String get spacesExplore => 'Дослідіть спільноти';

  @override
  String get spacesNoPublic => 'Публічні спільноти не знайдено';

  @override
  String get spacesJoin => 'Приєднуйтесь';

  @override
  String get spacesSubSpaces => 'Підспільноти';

  @override
  String get spacesChannels => 'Канали';

  @override
  String spacesMembersCount(int count) {
    return 'Учасники $count';
  }

  @override
  String get spacesPublic => 'Громадський';

  @override
  String get spacesPrivate => 'Приватний';

  @override
  String get spacesSuggested => 'Запропоновано';

  @override
  String spacesChannelsCount(int count) {
    return 'канали $count';
  }

  @override
  String get callInCallChat => 'Чат під час виклику';

  @override
  String callMessagesCount(int count) {
    return '$count повідомлення';
  }

  @override
  String get callNoMessagesYet =>
      'Поки немає повідомлень.\nНадішліть повідомлення, щоб почати.';

  @override
  String get callTypeMessage => 'Введіть повідомлення...';

  @override
  String get callYouSender => 'Ви';

  @override
  String get callChatLabel => 'Чат';

  @override
  String get chatEdited => 'Відредаговано';

  @override
  String get chatEditHistory => 'Історія редагування';

  @override
  String get chatOriginalMessage => 'Оригінал';

  @override
  String chatEditedAt(String time) {
    return 'Відредаговано в $time';
  }

  @override
  String get chatViewOnce => 'Переглянути один раз';

  @override
  String get chatViewOncePhoto => 'Переглянути один раз фото';

  @override
  String get chatViewOnceVideo => 'Переглянути один раз відео';

  @override
  String get chatViewOnceViewed => 'Переглянуто';

  @override
  String get chatViewOnceExpired => 'Термін дії минув';

  @override
  String get chatViewOnceTap => 'Торкніться, щоб переглянути';

  @override
  String get chatAutoFaceBlur => 'Автоматичне розмиття обличчя';

  @override
  String get chatAutoFaceBlurDesc =>
      'Автоматично розмивати обличчя під час надсилання фотографій';

  @override
  String get threadReplyInThread => 'Відповісти в ланцюжку';

  @override
  String threadReplies(int count) {
    return '$count відповідає';
  }

  @override
  String get threadReply => '1 відповідь';

  @override
  String threadLatestReply(String preview) {
    return 'Останні: $preview';
  }

  @override
  String get threadTitle => 'Нитка';

  @override
  String get threadReplyPlaceholder => 'Відповісти в ланцюжку...';

  @override
  String threadParticipants(int count) {
    return '$count учасників';
  }

  @override
  String get voiceRoomTitle => 'Голосова кімната';

  @override
  String get voiceRoomCreate => 'Створіть голосову кімнату';

  @override
  String get voiceRoomJoin => 'Приєднуйтесь';

  @override
  String get voiceRoomLeave => 'Залиште';

  @override
  String get voiceRoomEnd => 'Кінцева кімната';

  @override
  String get voiceRoomRaiseHand => 'Підняти руку';

  @override
  String get voiceRoomLowerHand => 'Нижня рука';

  @override
  String get voiceRoomMute => 'Вимкнути звук';

  @override
  String get voiceRoomUnmute => 'Увімкнути звук';

  @override
  String get voiceRoomHost => 'Хост';

  @override
  String get voiceRoomSpeakers => 'Доповідачі';

  @override
  String get voiceRoomListeners => 'Слухачі';

  @override
  String get voiceRoomLive => 'НАЖИВО';

  @override
  String get voiceRoomEnded => 'Завершено';

  @override
  String get voiceRoomScheduled => 'За розкладом';

  @override
  String get voiceRoomApprove => 'Затвердити';

  @override
  String get voiceRoomDemote => 'Перейти до Слухача';

  @override
  String voiceRoomHandRaised(String name) {
    return '$name підняли руку';
  }

  @override
  String get voiceRoomName => 'Назва кімнати';

  @override
  String get voiceRoomTopic => 'Тема (необов\'язково)';

  @override
  String get voiceRoomNoActive => 'Немає активних голосових кімнат';

  @override
  String get voiceRoomConnecting => 'Підключення...';

  @override
  String get usernameTitle => 'Ім\'я користувача';

  @override
  String get usernameSet => 'Встановити ім\'я користувача';

  @override
  String get usernameChange => 'Змінити ім\'я користувача';

  @override
  String get usernamePlaceholder => 'Введіть ім\'я користувача';

  @override
  String get usernameAvailable => 'Доступне ім\'я користувача';

  @override
  String get usernameUnavailable => 'Ім\'я користувача вже зайнято';

  @override
  String get usernameInvalid =>
      '3-30 символів, малі літери, цифри, підкреслення. Має починатися з букви.';

  @override
  String get usernameReserved => 'Це ім\'я користувача зарезервовано';

  @override
  String get usernameSaved => 'Ім\'я користувача збережено';

  @override
  String get usernameSearchHint => 'Пошук за @username';

  @override
  String get ensName => 'Назва ENS';

  @override
  String get ensLinked => 'Пов’язано з ENS';

  @override
  String get ensResolving => 'Вирішення ENS...';

  @override
  String get ensNotFound => 'Ім\'я ENS не знайдено';

  @override
  String get tokenGateTitle => 'Токен Гейт';

  @override
  String get tokenGateEnable => 'Увімкнути Token Gate';

  @override
  String get tokenGateDisable => 'Вимкнути Token Gate';

  @override
  String get tokenGateAddRule => 'Додати правило';

  @override
  String get tokenGateRemoveRule => 'Видалити правило';

  @override
  String get tokenGateContractAddress => 'Адреса договору';

  @override
  String get tokenGateMinBalance => 'Мінімальний баланс';

  @override
  String get tokenGateTokenId => 'Ідентифікатор токена (ERC-1155)';

  @override
  String get tokenGateChainId => 'ID ланцюга';

  @override
  String get tokenGateVerifying => 'Перевірка токенів...';

  @override
  String get tokenGateVerified => 'Перевірку пройдено';

  @override
  String get tokenGateDenied => 'Ви не відповідаєте вимогам до маркера';

  @override
  String get tokenGateOperatorAnd => 'Має відповідати ВСІМ правилам';

  @override
  String get tokenGateOperatorOr => 'Має відповідати БУДЬ-ЯКОМУ правилу';

  @override
  String get tokenGateRuleErc20 => 'Токен ERC-20';

  @override
  String get tokenGateRuleErc721 => 'NFT (ERC-721)';

  @override
  String get tokenGateRuleErc1155 => 'Multi-Token (ERC-1155)';

  @override
  String get tokenGateRuleNative => 'Рідний токен';

  @override
  String get tokenGateSaved => 'Токен ворота збережено';

  @override
  String get tokenGateEnableDescription =>
      'Щоб приєднатися, учасники повинні мати маркери';

  @override
  String get tokenGateOperator => 'Логічне правило';

  @override
  String get tokenGateRules => 'правила';

  @override
  String get tokenGateSymbol => 'Символ (необов\'язково)';

  @override
  String get tokenGateChain => 'ланцюг';

  @override
  String get tokenGateTokenStandard => 'Токен Стандарт';

  @override
  String get tokenGateDenialMessage => 'Повідомлення про відмову';

  @override
  String get tokenGateDenialMessageHint =>
      'Повідомлення відображається, коли перевірка не вдається';

  @override
  String get tokenGateVerifyTitle => 'Перевірка маркера';

  @override
  String get tokenGateVerifyPassed => 'Перевірка пройдена';

  @override
  String get tokenGateVerifyFailed => 'Не вдалося перевірити';

  @override
  String get tokenGateRetryVerify => 'Повторіть спробу';

  @override
  String get tokenGateRequired => 'Обов\'язковий';

  @override
  String get tokenGateYourBalance => 'Ваш баланс';

  @override
  String get tokenGateRulesActive => 'правила активні';

  @override
  String get tokenGateDisabled => 'Вимкнено';

  @override
  String get ensNotBound => 'Не переплетений';

  @override
  String get liveLocation => 'Живе розташування';

  @override
  String get stopLiveLocation => 'Зупинити спільний доступ';

  @override
  String get startLiveLocation => 'Почніть ділитися';

  @override
  String get selectDuration => 'Виберіть Тривалість';

  @override
  String get groupChatFiles => 'Файли чату';

  @override
  String get groupLinks => 'Посилання';

  @override
  String get groupNoLinks => 'Поки немає посилань';

  @override
  String get chatBackground => 'Фон чату';

  @override
  String get solidColors => 'Суцільні кольори';

  @override
  String get gradients => 'градієнти';

  @override
  String get defaultBackground => 'За замовчуванням';

  @override
  String get settingsFontSizeSlider => 'Розмір шрифту';

  @override
  String get autoDownload => 'Автоматичне завантаження';

  @override
  String get images => 'Зображення';

  @override
  String get voice => 'Голос';

  @override
  String get video => 'відео';

  @override
  String get files => 'Файли';

  @override
  String get mobileData => 'Мобільні дані';

  @override
  String get roaming => 'Роумінг';

  @override
  String get storageManagement => 'Зберігання';

  @override
  String get totalUsage => 'Загальне використання';

  @override
  String get cache => 'Кеш';

  @override
  String get other => 'інше';

  @override
  String get clearCache => 'Очистити кеш';

  @override
  String get cacheCleared => 'Кеш очищено';

  @override
  String get clearCacheFailed => 'Не вдалося очистити кеш';

  @override
  String get confirmClearCache => 'Очистити всі дані кешу?';

  @override
  String get mapView => 'Перегляд карти';

  @override
  String liveLocationSharingCount(int count) {
    return '$count люди діляться геоданими';
  }

  @override
  String get minutes15 => '15 хвилин';

  @override
  String get minutes30 => '30 хвилин';

  @override
  String get hour1 => '1 година';

  @override
  String get hours8 => '8 годин';

  @override
  String get personalCard => 'Особиста картка';

  @override
  String get downloadFailed => 'Помилка завантаження';

  @override
  String get locationExpired => 'Термін дії минув';

  @override
  String secondsRemaining(int count) {
    return '$count секунд';
  }

  @override
  String minutesRemaining(int count) {
    return '$countхв';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '${hours}h $minutesмін';
  }

  @override
  String get favoriteMessages => 'Вибране';

  @override
  String get linksCopied => 'Посилання скопійовано';

  @override
  String get noLinksFound => 'Посилання не знайдено';

  @override
  String get roomStorageRanking => 'Рейтинг зберігання номерів';

  @override
  String get downloadComplete => 'Завантаження завершено';

  @override
  String get downloading => 'Завантаження...';

  @override
  String get draftSaved => 'Чернетку збережено';

  @override
  String get voiceRecording => 'Запис голосу';

  @override
  String get searchLocation => 'Місце пошуку';

  @override
  String get tapToSearch => 'Торкніться для пошуку';

  @override
  String get settingsThisDevice => 'Цей пристрій';

  @override
  String get settingsJustNow => 'Просто зараз';

  @override
  String get settingsDeviceId => 'ID пристрою';

  @override
  String get settingsStatus => 'Статус';

  @override
  String get settingsLastActive => 'Останній активний';

  @override
  String get settingsIpAddress => 'IP адреса';

  @override
  String get settingsRenameDevice => 'Перейменувати пристрій';

  @override
  String get settingsDeviceNameHint => 'Введіть назву пристрою';

  @override
  String get settingsDeviceRenamed => 'Пристрій перейменовано';

  @override
  String get settingsRenameFailed => 'Не вдалося перейменувати';

  @override
  String get settingsRemoteLogout => 'Віддалений вихід із системи';

  @override
  String settingsRemoteLogoutConfirm(String deviceName) {
    return 'Ви впевнені, що бажаєте вийти з системи \"$deviceName\"? Цю дію не можна скасувати.';
  }

  @override
  String get settingsDeviceLoggedOut => 'Пристрій вийшов із системи';

  @override
  String get settingsLogoutFailed => 'Помилка виходу';

  @override
  String get settingsLogout => 'Вийти';

  @override
  String get settingsVerifyIdentity => 'Підтвердити особу';

  @override
  String get settingsEnterPasswordToConfirm =>
      'Введіть свій пароль, щоб підтвердити цю дію.';

  @override
  String get scheduledSendTitle => 'Розклад повідомлення';

  @override
  String get scheduledSendInOneHour => 'Через 1 годину';

  @override
  String get scheduledSendTonight => 'Сьогодні ввечері (20:00)';

  @override
  String get scheduledSendTomorrowMorning => 'Завтра вранці (9:00)';

  @override
  String get scheduledSendCustom => 'Виберіть дату й час';

  @override
  String get scheduledMessageLabel => 'За розкладом';

  @override
  String get scheduledMessageCancel => 'Скасувати заплановане повідомлення';

  @override
  String get chatLockTitle => 'Блокування чату';

  @override
  String get chatLockEnable => 'Заблокуйте цей чат';

  @override
  String get chatLockDisable => 'Розблокуйте цей чат';

  @override
  String get chatLockDescription =>
      'Для відкриття заблокованих чатів потрібна біометрична перевірка або підтвердження PIN-кодом';

  @override
  String get chatLockVerifyTitle => 'Чат заблоковано';

  @override
  String get chatLockVerifySubtitle =>
      'Підтвердьте, щоб отримати доступ до цього чату';

  @override
  String get chatLockVerifyFailed => 'Не вдалося перевірити';

  @override
  String get chatLockEnabled => 'Чат заблоковано';

  @override
  String get chatLockDisabled => 'Чат розблоковано';

  @override
  String get chatLockPinTitle => 'Введіть PIN-код';

  @override
  String get chatLockPinSetTitle => 'Встановити PIN-код';

  @override
  String get chatLockPinConfirmTitle => 'Підтвердьте PIN-код';

  @override
  String get chatLockPinMismatch => 'PIN-код не збігається';

  @override
  String get chatLockUseBiometric => 'Використовуйте біометрію';

  @override
  String get chatLockUsePin => 'Використовуйте PIN-код';

  @override
  String get mediaEditorUndo => 'Скасувати';

  @override
  String get mediaEditorRedo => 'Повторити';

  @override
  String get mediaEditorCrop => 'кадрування';

  @override
  String get mediaEditorFilter => 'фільтр';

  @override
  String get mediaEditorDraw => 'малювати';

  @override
  String get mediaEditorText => 'текст';

  @override
  String get aiAssistant => 'ШІ помічник';

  @override
  String get aiAssistantWelcome =>
      'Привіт! Я помічник N42 AI. Чим я можу вам допомогти?';

  @override
  String get aiAssistantNotConfigured => 'Службу AI не налаштовано';

  @override
  String get aiAssistantSettings => 'Налаштування AI';

  @override
  String get aiAssistantClearHistory => 'Очистити історію чату';

  @override
  String get aiAssistantClearHistoryConfirm =>
      'Ви впевнені, що бажаєте очистити всю історію чатів AI?';

  @override
  String get aiAssistantStopGenerating => 'Припинити генерацію';

  @override
  String get aiAssistantModel => 'Модель';

  @override
  String get aiAssistantTemperature => 'Температура';

  @override
  String get aiAssistantMaxTokens => 'Макс жетонів';

  @override
  String get aiAssistantContextWindow => 'Контекстне вікно';

  @override
  String get aiAssistantServiceStatus => 'Статус служби';

  @override
  String get aiAssistantAvailable => 'в наявності';

  @override
  String get aiAssistantUnavailable => 'Недоступний';

  @override
  String get aiSummarize => 'AI Резюме';

  @override
  String aiSummarizeUnread(int count) {
    return 'Узагальніть $count непрочитані повідомлення';
  }

  @override
  String get aiSummarizeLoading => 'Підведення підсумків...';

  @override
  String get aiSummarizeError => 'Не вдалося підсумувати';

  @override
  String get aiRewrite => 'AI Rewrite';

  @override
  String get aiRewriteFormal => 'Формальний';

  @override
  String get aiRewriteCasual => 'Повсякденний';

  @override
  String get aiRewritePlayful => 'Грайливий';

  @override
  String get aiRewriteProfessional => 'професійний';

  @override
  String get aiRewriteAccept => 'використання';

  @override
  String get aiRewriteCancel => 'Скасувати';

  @override
  String get aiRewriteLoading => 'Переписування...';

  @override
  String get aiLinkSummary => 'AI Резюме';

  @override
  String get aiLinkSummaryAnalyzing => 'Аналіз...';

  @override
  String get chatFolderManagement => 'Керування папками';

  @override
  String get chatFolderSystem => 'Системні папки';

  @override
  String get chatFolderCustom => 'Спеціальні папки';

  @override
  String get chatFolderEmpty => 'Ще немає спеціальних папок';

  @override
  String get chatFolderCreate => 'Створити папку';

  @override
  String get chatFolderEdit => 'Редагувати папку';

  @override
  String get chatFolderNameHint => 'Назва папки';

  @override
  String get chatFolderAll => 'всі';

  @override
  String get chatFolderUnread => 'Непрочитаний';

  @override
  String get chatFolderPersonal => 'Особисті';

  @override
  String get chatFolderGroups => 'Групи';

  @override
  String get chatFolderChannels => 'Канали';

  @override
  String get chatFolderMuted => 'Вимкнено';

  @override
  String get storyAddMusic => 'Додати музику';

  @override
  String get storyChangeMusic => 'Змінити музику';

  @override
  String get storyBackgroundMusic => 'Фонова музика';

  @override
  String get storyMusicPreview => 'Попередній перегляд (макс. 15 с)';

  @override
  String get storyChooseFromDevice => 'Виберіть із пристрою';

  @override
  String get storyUseThisMusic => 'Використовуйте цю музику';

  @override
  String get authPasskeyNotSupported =>
      'Ключ доступу не підтримується на цьому пристрої';

  @override
  String get authPasskeyRegister => 'Зареєструвати пароль';

  @override
  String get authPasskeyNoRegistered => 'Ключі доступу не зареєстровані';

  @override
  String get authPasskeyRegisterHint =>
      'Зареєструйте пароль для цього облікового запису. Окремий вхід за допомогою ключа доступу буде ввімкнено пізніше.';

  @override
  String get authPasskeyNameYours => 'Назвіть свій пароль';

  @override
  String get authPasskeyRegistered =>
      'Ключ доступу збережено в цьому обліковому записі';

  @override
  String get authPasskeyDeleted =>
      'Ключ доступу видалено з цього облікового запису';

  @override
  String authPasskeyDeleteConfirm(String name) {
    return 'Видалити ключ доступу \"$name\"? Вам потрібно буде зареєструвати його знову, перш ніж використовувати пароль для входу пізніше.';
  }

  @override
  String get momentVisibilityPublic => 'Громадський';

  @override
  String get momentVisibilityPrivate => 'Приватний';

  @override
  String get momentVisibilityPartial => 'Вибрані друзі';

  @override
  String get momentVisibilityExcluded => 'Виключити деяких друзів';

  @override
  String momentUserMoments(String userName) {
    return 'Моменти $userName';
  }

  @override
  String get momentForwardTo => 'Переслати до';

  @override
  String get momentForwardSuccess => 'Переслано успішно';

  @override
  String get momentSelectFriends => 'Виберіть Друзі';

  @override
  String get momentSelectTags => 'Виберіть за тегами';

  @override
  String momentSelectedCount(int count) {
    return 'Вибране ($count)';
  }

  @override
  String get momentNoMomentsYet => 'Ще немає моментів';

  @override
  String get momentForwardMoment => 'Момент вперед';

  @override
  String get momentAddComment => 'Додати коментар...';

  @override
  String momentForwardContent(String content) {
    return '[Момент] $content';
  }

  @override
  String get momentDeleteMoment => 'Видалити момент';

  @override
  String get momentDeleteConfirm =>
      'Ви впевнені, що хочете видалити цей момент?';

  @override
  String get momentComment => 'коментар';

  @override
  String get momentWriteComment => 'Напишіть коментар...';

  @override
  String get momentLike => 'Подобається';

  @override
  String get momentUnlike => 'На відміну від';

  @override
  String get momentForward => 'вперед';

  @override
  String get momentDelete => 'Видалити';

  @override
  String get momentReply => 'відповісти';

  @override
  String get momentMoment => 'Момент';

  @override
  String momentLikesCount(int count) {
    return 'Подобається $count';
  }

  @override
  String momentCommentsCount(int count) {
    return 'Коментарі $count';
  }

  @override
  String get momentNoComments => 'Поки немає коментарів';

  @override
  String get momentFailedToLoad => 'Не вдалося завантажити зображення';

  @override
  String momentReplyTo(String userName) {
    return 'Відповісти $userName...';
  }

  @override
  String get momentNoConversations => 'Жодних розмов';

  @override
  String get momentJustNow => 'тільки зараз';

  @override
  String momentMinutesAgo(int count) {
    return '$countм тому';
  }

  @override
  String momentHoursAgo(int count) {
    return '${count}h тому';
  }

  @override
  String momentDaysAgo(int count) {
    return '$countд тому';
  }

  @override
  String get chatGroupAnnouncementHint => 'Введіть групове оголошення';

  @override
  String get chatGroupAnnouncementEmpty => 'Без оголошення';

  @override
  String get chatEditNickname => 'Редагувати псевдонім';

  @override
  String get chatNicknameHint => 'Введіть свій нік у цій групі';

  @override
  String get contactAddPhoneHint => 'Введіть номер телефону';

  @override
  String get contactNotesHint => 'Додайте примітки про цей контакт';

  @override
  String get reportTitle => 'звіт';

  @override
  String get reportReasonSpam => 'Спам';

  @override
  String get reportReasonHarassment => 'Переслідування';

  @override
  String get reportReasonFraud => 'Шахрайство';

  @override
  String get reportReasonOther => 'інше';

  @override
  String get reportSubmitted => 'Звіт подано';

  @override
  String get reportDescription => 'Додатковий опис (необов\'язково)';

  @override
  String get qrcodeSaved => 'QR-код збережено в альбомі';

  @override
  String get chatSendRedPacketInChat =>
      'Будь ласка, надішліть червоний пакет у чаті';

  @override
  String get commonSaveFailed => 'Не вдалося зберегти';

  @override
  String get reportSelectReason => 'Виберіть причину';

  @override
  String get gameCenter => 'Ігри';

  @override
  String get gameHighScore => 'Найкращий';

  @override
  String get gameScore => 'Оцінка';

  @override
  String get gameOver => 'Гра закінчена';

  @override
  String get gamePlayAgain => 'Грати знову';

  @override
  String get gameLeaderboard => 'Таблиця лідерів';

  @override
  String get gamePause => 'Призупинено';

  @override
  String get gameResume => 'Торкніться, щоб відновити';

  @override
  String get gameConfirmExit => 'Вийти з цієї гри?';

  @override
  String get gameNoScores => 'Ще немає балів';

  @override
  String get game2048 => '2048';

  @override
  String get game2048Desc => 'Об’єднайте плитки, щоб досягти 2048';

  @override
  String get gameBlockDrop => 'Випадання блоку';

  @override
  String get gameBlockDropDesc => 'Краплі та чіткі лінії';

  @override
  String get gameMinesweeper => 'Тральщик';

  @override
  String get gameMinesweeperDesc => 'Знайти всі безпечні клітини';

  @override
  String get gameMatch3 => 'Матч 3';

  @override
  String get gameMatch3Desc => 'Зіставте 3 або більше дорогоцінних каменів';

  @override
  String get gameMinesweeperEasy => 'легко';

  @override
  String get gameMinesweeperMedium => 'Середній';

  @override
  String get gameMinesLeft => 'Залишені міни';

  @override
  String get gameTimeLeft => 'час';

  @override
  String get gameLevel => 'Рівень';

  @override
  String get gameNext => 'Далі';

  @override
  String get gameBestTime => 'Кращий час';

  @override
  String get gameNewRecord => 'Новий рекорд!';

  @override
  String get gameLines => 'Лінії';

  @override
  String get storyMyStory => 'Моя історія';

  @override
  String get storageSmartCleanup => 'Розумне очищення';

  @override
  String get storageOldMediaFiles => 'Старі мультимедійні файли';

  @override
  String get storageLargeFiles => 'Великі файли';

  @override
  String get storageAppCache => 'Кеш програми';

  @override
  String get storageSettings => 'Налаштування зберігання';

  @override
  String get storageAutoCleanup => 'Автоматичне очищення';

  @override
  String storageAutoCleanupDesc(int days) {
    return 'Автоматично очищати файли старше $days днів';
  }

  @override
  String get storageCleanupPeriod => 'Період очищення';

  @override
  String get storagePreserveThumbnails => 'Зберегти мініатюри';

  @override
  String get storagePreserveThumbnailsDesc =>
      'Зберігайте мініатюри зображень під час очищення';

  @override
  String get storageWarningHigh =>
      'Високе використання пам’яті. Подумайте про очищення старих файлів.';

  @override
  String get storageWarningCritical =>
      'Пам\'яті критично мало. Очистіть, будь ласка, вільне місце.';

  @override
  String storageFreed(String size, int count) {
    return 'Звільнено $size (файли $count)';
  }

  @override
  String storageDays(int days) {
    return '$days днів';
  }

  @override
  String storageViewAllRooms(int count) {
    return 'Переглянути всі номери $count';
  }

  @override
  String get storageNoFiles => 'Файли не знайдено';

  @override
  String get storageFilePinned => 'Закріплено';

  @override
  String storageDeleteSelected(int count) {
    return 'Видалити вибрані файли $count? Їх можна повторно завантажити з сервера.';
  }

  @override
  String get backupRestore => 'Резервне копіювання та відновлення';

  @override
  String get backupCreate => 'Створити резервну копію';

  @override
  String get backupCreateDesc =>
      'Резервне копіювання налаштувань і ключів шифрування. Повідомлення будуть відновлені з сервера після повторного входу.';

  @override
  String get backupIncludeKeys => 'Додайте ключі шифрування';

  @override
  String get backupIncludeKeysDesc =>
      'Необхідний для читання зашифрованих повідомлень';

  @override
  String get backupPasswordProtect => 'Захист паролем';

  @override
  String get backupEnterPassword => 'Введіть резервний пароль';

  @override
  String get backupHistory => 'Історія резервного копіювання';

  @override
  String get backupNoBackups => 'Резервних копій ще немає';

  @override
  String get backupRestore2 => 'Відновити';

  @override
  String get backupDelete => 'Видалити';

  @override
  String get backupDeleteConfirm =>
      'Ви впевнені, що хочете видалити цю резервну копію? Це неможливо скасувати.';

  @override
  String get backupRestoreFromFile => 'Відновити з файлу';

  @override
  String get backupRestoreFromFileDesc =>
      'Імпортуйте файл резервної копії .n42 з іншого пристрою або попередньої резервної копії.';

  @override
  String get backupChooseFile => 'Виберіть файл резервної копії';

  @override
  String get backupRestoring => 'Відновлення...';

  @override
  String backupCreated(int rooms, int messages) {
    return 'Створено резервну копію: $rooms кімнат, $messages повідомлень';
  }

  @override
  String backupRestored(int settings, int rooms) {
    return 'Відновлено налаштування $settings з кімнат $rooms';
  }

  @override
  String backupFailed(String error) {
    return 'Помилка резервного копіювання: $error';
  }

  @override
  String get backupPasswordRequired => 'Ця резервна копія захищена паролем';

  @override
  String get blocGroupNotFound => 'Групу не знайдено';

  @override
  String blocGroupMembersInvited(int count) {
    return 'Запрошений член(и) $count';
  }

  @override
  String get blocGroupMemberRemoved => 'Учасника видалено';

  @override
  String get blocGroupAdminRemoved => 'Адміністратора видалено';

  @override
  String get blocGroupLeft => 'Вийшов із групи';

  @override
  String get blocGroupDisbanded => 'Група розпущена';

  @override
  String get blocGroupJoined => 'Приєднався до групи';

  @override
  String get blocGroupInviteDeclined => 'Запрошення відхилено';

  @override
  String get blocGroupTokenGateUpdated => 'Токен-шлюз оновлено';

  @override
  String get blocTransferProcessing => 'Обробка передачі...';

  @override
  String get blocTransferCancelled => 'Переказ скасовано';

  @override
  String get blocTransferFailed => 'Помилка передачі';

  @override
  String get blocPaymentProcessing => 'Обробка платежу...';

  @override
  String get blocPaymentFailed => 'Платіж не вдалося';

  @override
  String get groupMaxMembers => 'Ліміт учасників';

  @override
  String get groupMaxMembersUnlimited => 'Необмежений';

  @override
  String get groupMaxMembersHint =>
      'Введіть ліміт (залиште порожнім для необмеженого)';

  @override
  String get groupMaxMembersUpdated => 'Ліміт учасників оновлено';

  @override
  String get groupFull => 'Група завантажена';

  @override
  String get groupChannels => 'Тематичні канали';

  @override
  String get groupChannelsEmpty => 'Ще немає каналів';

  @override
  String get groupChannelsCount => 'канали';

  @override
  String get groupChannelCreate => 'Новий канал';

  @override
  String get groupChannelName => 'Назва каналу';

  @override
  String get groupChannelTopic => 'Тема каналу (необов\'язково)';

  @override
  String get groupChannelDelete => 'Видалити канал';

  @override
  String get groupChannelDeleteConfirm =>
      'Видалити цей канал? Усі повідомлення буде втрачено.';

  @override
  String get groupBotSettings => 'Налаштування бота';

  @override
  String get groupBotEnabled => 'Увімкнути бота';

  @override
  String get groupBotWelcomeMessage => 'Шаблон привітального повідомлення';

  @override
  String get groupBotWelcomeHint =>
      'Використовуйте «name» як заповнювач для імені нового учасника';

  @override
  String get groupBotConfigUpdated => 'Налаштування бота оновлено';

  @override
  String get groupContentFilter => 'Фільтр вмісту';

  @override
  String get groupContentFilterEnabled => 'Увімкнути фільтр ключових слів';

  @override
  String get groupContentFilterReplace => 'Замінити на ***';

  @override
  String get groupContentFilterHide => 'Приховати повідомлення';

  @override
  String get groupContentFilterAddWord => 'Додати ключове слово';

  @override
  String get groupContentFilterUpdated => 'Оновлено фільтр вмісту';

  @override
  String get chatSlashCommands => 'Команди';

  @override
  String get chatCommandPoll => '/poll — створити опитування';

  @override
  String get chatCommandAnnounce => '/announce — Надіслати оголошення';

  @override
  String get chatCommandWelcome =>
      '/welcome — встановити вітальне повідомлення';

  @override
  String get chatReportMessage => 'звіт';

  @override
  String get chatReportReason => 'Повідомити про причину';

  @override
  String get chatReportSpam => 'Спам';

  @override
  String get chatReportHarassment => 'Переслідування';

  @override
  String get chatReportInappropriate => 'Невідповідний вміст';

  @override
  String get chatReportOther => 'інше';

  @override
  String get chatReportSuccess => 'Звіт подано';

  @override
  String get spacesName => 'Назва спільноти';

  @override
  String get spacesNameHint => 'напр. Криптотрейдери';

  @override
  String get spacesNameRequired => 'Необхідно вказати ім\'я';

  @override
  String get spacesDescription => 'опис';

  @override
  String get spacesDescriptionHint => 'Про що ця спільнота?';

  @override
  String get spacesType => 'Тип спільноти';

  @override
  String get spacesPublicDesc => 'Будь-хто може знайти та приєднатися';

  @override
  String get spacesPrivateDesc =>
      'Тільки запрошені учасники можуть приєднатися';

  @override
  String get spacesNotFound => 'Спільнота не знайдена';

  @override
  String get spacesSearch => 'Пошук спільнот...';

  @override
  String get spacesMembers => 'Члени';

  @override
  String get spacesNoChannels => 'Ще немає каналів';

  @override
  String get spacesLeave => 'Вийти зі спільноти';

  @override
  String spacesLeaveConfirm(String name) {
    return 'Ви впевнені, що бажаєте залишити \"$name\"?';
  }

  @override
  String get spacesDelete => 'Видалити спільноту';

  @override
  String spacesDeleteConfirm(String name) {
    return 'Це призведе до остаточного видалення \"$name\" і всіх його каналів. Цю дію не можна скасувати.';
  }

  @override
  String get spacesCreateChannel => 'Додати канал';

  @override
  String get spacesChannelName => 'Назва каналу';

  @override
  String get spacesChannelTopic => 'Тема (необов\'язково)';

  @override
  String get spacesDeleteChannel => 'Видалити канал';

  @override
  String spacesDeleteChannelConfirm(String name) {
    return 'Ви впевнені, що хочете видалити \"#$name\"?';
  }

  @override
  String get spacesEditName => 'Редагувати назву';

  @override
  String get spacesEditDescription => 'Редагувати опис';

  @override
  String spacesViewAllMembers(int count) {
    return 'Переглянути всіх учасників $count';
  }

  @override
  String spacesKickMemberTitle(String name) {
    return 'Удар $name';
  }

  @override
  String spacesBanMemberTitle(String name) {
    return 'Забанити $name';
  }

  @override
  String get spacesPromoteAdmin => 'Підвищити до адміністратора';

  @override
  String get spacesDemoteAdmin => 'Видалити адміністратора';

  @override
  String get spacesInviteMember => 'Запросити учасника';

  @override
  String get spacesInviteMemberUserId =>
      'Ідентифікатор користувача (наприклад, @user:server.com)';

  @override
  String get spacesSave => 'зберегти';

  @override
  String get settingsScreenshotProtection => 'Захист скріншотів';

  @override
  String get settingsScreenshotProtectionDesc =>
      'Запобігайте знімкам екрана та запису екрана';

  @override
  String get chatSelfDestructTimer => 'Самознищення';

  @override
  String get chatTimerPickerTitle => 'Таймер самознищення';

  @override
  String get chatTimerOff => 'Вимкнено';

  @override
  String get onChainNotificationsTitle => 'Події в мережі';

  @override
  String get onChainMarkAllRead => 'Позначити все прочитане';

  @override
  String get onChainNoNotifications => 'Подій у мережі ще немає';

  @override
  String get onChainNoNotificationsDesc =>
      'Тут відображатимуться події з каналів, на які ви підписалися';

  @override
  String get onChainViewDetails => 'Переглянути деталі';

  @override
  String get chatCommandHelp => '/help — Показати всі команди';

  @override
  String get chatCommandPrice => '/price — отримати ціну токена';

  @override
  String get chatCommandBalance => '/balance — Показати баланс гаманця';

  @override
  String get chatCommandChains => '/chains — список 236+ підтримуваних мереж';

  @override
  String get chatMiniApps => 'програми';

  @override
  String get miniAppMarketTitle => 'Міні-додатки';

  @override
  String get miniAppCategoryAll => 'всі';

  @override
  String get miniAppSearch => 'Пошук програм...';

  @override
  String get miniAppFeatured => 'Рекомендовані';

  @override
  String get miniAppAllApps => 'Усі додатки';

  @override
  String get miniAppNoResults => 'Програм не знайдено';

  @override
  String get slideToPayLabel => '→→→ Проведіть пальцем для підтвердження';

  @override
  String get slideToPayConfirming => 'Підтвердження...';

  @override
  String get redPacketBestLuck => 'Краща удача';

  @override
  String get redPacketBestLuckCongrats => 'Удачі! Ви отримали найбільше!';

  @override
  String redPacketStats(int claimed, int total) {
    return 'Заявлено $claimed / $total';
  }

  @override
  String get redPacketStatsTotal => 'всього';

  @override
  String redPacketGrabbedViral(String amount, String token) {
    return '🧧 схопив червоний пакунок • $amount $token';
  }

  @override
  String get web3SearchHint => '@matrix:id • 0x адреса гаманця • name.eth';

  @override
  String get web3SearchPlaceholder => 'Пошук за ID, гаманцем або ENS...';

  @override
  String get web3WalletAddress => 'Адреса гаманця';

  @override
  String get web3AddressCopied => 'Адресу скопійовано';

  @override
  String get web3Copy => 'Копія';

  @override
  String get web3SendMessage => 'Надіслати повідомлення';

  @override
  String get web3SendToWallet => 'Гаманець для повідомлень';

  @override
  String get web3WalletOnlyHint =>
      'Ця адреса ще не має облікового запису N42. Повідомлення буде доставлено, коли вони приєднаються.';

  @override
  String get web3NftAvatar => 'Аватар NFT';

  @override
  String get web3ResolveFailed => 'Не вдалося визначити особу';

  @override
  String web3EnsNotFound(String name) {
    return 'Назва ENS \"$name\" не знайдено';
  }

  @override
  String get web3NoN42AccountTitle => 'Немає облікового запису N42';

  @override
  String get web3NoN42AccountDesc =>
      'Ця адреса гаманця ще не має облікового запису N42. Ви можете поділитися з ними посиланням на запрошення N42, щоб почати.';

  @override
  String get web3ShareInvite => 'Поділитися запрошенням';

  @override
  String get nftPickerTitle => 'Виберіть NFT Avatar';

  @override
  String get nftPickerTabPopular => 'Популярний';

  @override
  String get nftPickerTabCustom => 'Custom';

  @override
  String get nftPickerChain => 'ланцюг';

  @override
  String get nftPickerContract => 'Адреса договору';

  @override
  String get nftPickerTokenId => 'Ідентифікатор маркера';

  @override
  String get nftPickerVerifyOwnership =>
      'Перевірити право власності та переглянути';

  @override
  String get nftPickerUseAsAvatar => 'Використовувати як аватар';

  @override
  String get nftPickerPreview => 'Попередній перегляд';

  @override
  String get nftPickerNotOwned => 'Ви не є власником цього NFT';

  @override
  String get nftPickerInvalidTokenId => 'Недійсний ідентифікатор маркера';

  @override
  String get nftPickerEnterBoth =>
      'Введіть адресу контракту та ідентифікатор токена';

  @override
  String get nftPickerInfoTitle => 'NFT Avatar — Verified On-Chain';

  @override
  String get nftPickerInfoDesc =>
      'Прив’яжіть свій аватар до NFT, яким ви володієте. Будь-хто може підтвердити право власності в мережі. Показано із золотим кільцем на N42.';

  @override
  String get nftPickerPopularCollections => 'Популярні колекції';

  @override
  String get nftPickerWalletHint =>
      'Підключіть свій гаманець N42, щоб автоматично знаходити свої NFT у понад 236 мережах.';

  @override
  String get profileBindNftAvatar => 'Прив’язати аватар NFT';

  @override
  String get profileChangeAvatar => 'Змінити аватар';

  @override
  String get groupTopics => 'Теми';

  @override
  String get groupTopicsEmpty => 'Ще немає тем';

  @override
  String get syncInProgress => 'Синхронізація історії повідомлень...';

  @override
  String get recoveryKeyReminderTitle => 'Захистіть свої повідомлення';

  @override
  String get recoveryKeyReminderDesc =>
      'Створіть ключ відновлення для безпечної синхронізації зашифрованих повідомлень між пристроями';

  @override
  String get recoveryKeySetupNow => 'Налаштувати зараз';

  @override
  String get recoveryKeyRemindLater => 'Нагадай мені пізніше';

  @override
  String get channelReadOnly =>
      'Лише адміністратори можуть публікувати дописи на цьому каналі';

  @override
  String get channelSubscribers => 'підписників';

  @override
  String get channelVerified => 'Перевірений канал';

  @override
  String get redPacketHistory => 'Історія червоних пакетів';

  @override
  String get redPacketSent => 'Надіслано';

  @override
  String get redPacketReceived => 'Отримано';

  @override
  String get redPacketExpired => 'Термін дії минув';

  @override
  String get redPacketClaimed => 'Заявлено';

  @override
  String get redPacketInsufficientBalance => 'Недостатній баланс';

  @override
  String selfDestructCountdown(String time) {
    return 'Самознищення в $time';
  }

  @override
  String get messageDestroyed => 'Повідомлення знищено';

  @override
  String miniAppPermissionDenied(String permission) {
    return 'У дозволі відмовлено: $permission';
  }

  @override
  String get aiSuggestionGasFee => 'Що таке плата за газ?';

  @override
  String get aiSuggestionDefi => 'Посібник для початківців DeFi';

  @override
  String get aiSuggestionSecurity => 'Як перевірити безпеку договору';

  @override
  String get aiSuggestionBridge => 'Перехресне ланцюгове перемикання';

  @override
  String get channelDiscoverTitle => 'Відкрийте канали';

  @override
  String get channelDiscoverSearch => 'Пошук каналів...';

  @override
  String get channelJoin => 'Приєднуйтесь';

  @override
  String get channelJoined => 'Приєднався';

  @override
  String get channelCategory => 'Категорія';

  @override
  String slowModeCooldown(int seconds) {
    return 'Повільний режим: зачекайте ${seconds}s';
  }

  @override
  String get addressCopyAction => 'Копіювати адресу';

  @override
  String get addressSendMessage => 'Надіслати повідомлення';

  @override
  String get addressViewProfile => 'Переглянути профіль';

  @override
  String get sendToAddress => 'Надіслати на адресу гаманця';

  @override
  String get blocAuthSendVerificationCodeFailed =>
      'Не вдалося надіслати код підтвердження';

  @override
  String get blocAuthServerNoEmailPasswordReset =>
      'Цей сервер не підтримує скидання пароля електронної пошти';

  @override
  String get blocAuthResetPasswordFailed => 'Не вдалося скинути пароль';

  @override
  String get blocAuthChangePasswordFailed => 'Не вдалося змінити пароль';

  @override
  String get blocAuthOldPasswordWrong => 'Неправильний поточний пароль';

  @override
  String get blocAuthLoginCancelled => 'Вхід скасовано';

  @override
  String get blocAuthGoogleLoginFailed => 'Помилка входу в Google';

  @override
  String get blocAuthAppleLoginFailed => 'Помилка входу в систему Apple';

  @override
  String get blocAuthSsoLoginFailed => 'Помилка входу в систему єдиного входу';

  @override
  String get blocAuthFacebookLoginFailed => 'Помилка входу в Facebook';

  @override
  String get blocAuthTwitterLoginFailed => 'Помилка входу в Twitter';

  @override
  String get blocAuthWeChatLoginFailed => 'Помилка входу в WeChat';

  @override
  String get blocAuthWeChatNotConfigured => 'Вхід у WeChat не налаштовано';

  @override
  String get blocAuthWeChatNotInstalled => 'Спочатку встановіть WeChat';

  @override
  String get blocAuthPasswordWrong => 'Невірний пароль';

  @override
  String get blocAuthEmailAlreadyBound =>
      'Ця електронна адреса вже прив’язана до іншого облікового запису';

  @override
  String get blocAuthChangeEmailFailed =>
      'Не вдалося змінити електронну адресу';

  @override
  String get blocAuthVerificationCodeInvalid =>
      'Код підтвердження неправильний або термін дії минув';

  @override
  String get blocAuthSessionExpired => 'Сеанс закінчився, увійдіть знову';

  @override
  String get blocAuthSessionIncomplete => 'Дані сеансу неповні, увійдіть знову';
}
