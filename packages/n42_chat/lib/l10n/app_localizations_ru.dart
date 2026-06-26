// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class SRu extends S {
  SRu([String locale = 'ru']) : super(locale);

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonUnknownUser => 'Неизвестный пользователь';

  @override
  String get transferWalletNotConnected => 'Кошелёк не подключён';

  @override
  String get chatCallServiceNotInitialized =>
      'Служба вызовов не инициализирована';

  @override
  String authLoginFailed(String error) {
    return 'Ошибка входа: $error';
  }

  @override
  String get chatCallBack => 'Перезвонить';

  @override
  String get chatMissedVideoCall => 'Пропущенный видеовызов';

  @override
  String get chatMissedVoiceCall => 'Пропущенный голосовой вызов';

  @override
  String get chatCallNotAnswered => 'Нет ответа';

  @override
  String get chatCallDurationLabel => 'Длительность звонка';

  @override
  String get chatVoiceCallCancelled => 'Голосовой звонок отменён';

  @override
  String get chatVideoCallCancelled => 'Видеозвонок отменён';

  @override
  String get commonImage => '[Изображение]';

  @override
  String get chatVideo => '[Видео]';

  @override
  String get chatVoice => '[Голосовое сообщение]';

  @override
  String get commonFile => '[Файл]';

  @override
  String get chatLocation => '[Местоположение]';

  @override
  String get chatUnknownMessage => '[Неизвестное сообщение]';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get chatDeleteThisMessage => 'Удалить это сообщение?';

  @override
  String get chatMessageDeleted => 'Сообщение удалено';

  @override
  String get profileNotLoggedIn => 'Не выполнен вход';

  @override
  String get chatMyLocation => 'Моё местоположение';

  @override
  String get commonGroupChat => 'Групповой чат';

  @override
  String get commonSearch => 'Поиск';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonLoadFailed => 'Ошибка загрузки';

  @override
  String get commonMessages => 'Сообщения';

  @override
  String get commonContacts => 'Контакты';

  @override
  String get commonMe => 'Я';

  @override
  String get commonVoiceLoading =>
      'Загрузка голосового сообщения, попробуйте позже';

  @override
  String get commonVoiceToTextFailed =>
      'Не удалось преобразовать голос в текст';

  @override
  String get commonConvertToText => 'В текст';

  @override
  String get chatCopy => 'Копировать';

  @override
  String get commonForward => 'Переслать';

  @override
  String get commonUnfavorite => 'Удалить из избранного';

  @override
  String get commonFavorite => 'В избранное';

  @override
  String get settingsResend => 'Отправить повторно';

  @override
  String get chatRecall => 'Отозвать';

  @override
  String get commonQuote => 'Цитировать';

  @override
  String get commonRemind => 'Напомнить';

  @override
  String get chatCopied => 'Скопировано';

  @override
  String get storySendMessageHint => 'Написать сообщение';

  @override
  String get commonMicrophonePermissionRequired =>
      'Пожалуйста, разрешите доступ к микрофону';

  @override
  String get chatMicrophonePermissionDeniedPermanent =>
      'Разрешение на использование микрофона отклонено. Пожалуйста, включите его в настройках системы, чтобы использовать голосовые сообщения.';

  @override
  String commonStartRecordingFailed(String error) {
    return 'Не удалось начать запись: $error';
  }

  @override
  String get commonRecordingTooShort => 'Запись слишком короткая';

  @override
  String commonStopRecordingFailed(String error) {
    return 'Не удалось остановить запись: $error';
  }

  @override
  String get chatReleaseToCancel => 'Отпустите для отмены';

  @override
  String get chatReleaseToSend =>
      'Отпустите для отправки, смахните вверх для отмены';

  @override
  String get commonHoldToTalk => 'Удерживайте для записи';

  @override
  String get commonSend => 'Отправить';

  @override
  String get commonAddFriend => 'Добавить друга';

  @override
  String get commonChatServiceNotConnected => 'Служба чата не подключена';

  @override
  String contactUserNotFoundHint(String query) {
    return 'Пользователь \"$query\" не найден\n\nПодсказки:\n• Попробуйте ввести полный ID пользователя, например @username:server.com\n• Проверьте правильность написания имени';
  }

  @override
  String contactCreateChatFailed(String error) {
    return 'Не удалось создать чат: $error';
  }

  @override
  String contactSearchFailed(String error) {
    return 'Ошибка поиска: $error';
  }

  @override
  String get contactEnterUserIdOrUsername =>
      'Введите ID или имя пользователя для поиска';

  @override
  String get contactSearching => 'Поиск...';

  @override
  String get contactSearchUserToChat =>
      'Найдите пользователя, чтобы начать чат';

  @override
  String get contactMatrixIdExample =>
      'Вы можете ввести полный Matrix ID\nнапример @user:matrix.n42.network';

  @override
  String contactUserNotFound(String username) {
    return 'Пользователь \"$username\" не найден';
  }

  @override
  String get commonChat => 'Чат';

  @override
  String get commonSettings => 'Настройки';

  @override
  String get profileEditProfile => 'Редактировать профиль';

  @override
  String get authLogin => 'Войти';

  @override
  String get commonCreateGroup => 'Создать группу';

  @override
  String get chatError => 'Ошибка';

  @override
  String get commonTransfer => 'Перевод';

  @override
  String get commonReceived => 'Получено';

  @override
  String get commonRefunded => 'Возвращено';

  @override
  String get commonExpired => 'Истёк';

  @override
  String get chatRedPacketGreeting => 'С наилучшими пожеланиями';

  @override
  String get commonN42RedPacket => 'Красный конверт N42';

  @override
  String get commonClaimed => 'Получено';

  @override
  String get commonAllClaimed => 'Все получены';

  @override
  String get chatReadAloud => 'Читать вслух';

  @override
  String get chatReply => 'Ответить';

  @override
  String get commonEdit => 'Редактировать';

  @override
  String get chatSelectForwardTarget => 'Выбрать получателя';

  @override
  String commonSendCount(int count) {
    return 'Отправить ($count)';
  }

  @override
  String contactN42Id(String id) {
    return 'Идентификатор N42: $id';
  }

  @override
  String get profileN42IdTitle => 'Идентификатор N42';

  @override
  String get profileN42Bean => 'N42 Фасоль';

  @override
  String get contactFriendInfo => 'Информация о друге';

  @override
  String get contactFriendInfoDesc =>
      'Добавьте заметку, телефон, теги, примечания, фото и настройте разрешения.';

  @override
  String get commonMoments => 'Моменты';

  @override
  String get commonSendMessage => 'Сообщение';

  @override
  String get contactAudioVideoCall => 'Аудио/видеовызов';

  @override
  String get contactVideoChannel => 'Видеоканал';

  @override
  String get contactRemark => 'Заметка';

  @override
  String get contactRemarkName => 'Имя заметки';

  @override
  String get contactPhone => 'Телефон';

  @override
  String get contactTags => 'Теги';

  @override
  String get contactNotes => 'Заметки';

  @override
  String get contactPhotos => 'Фото';

  @override
  String get contactPermissions => 'Разрешения';

  @override
  String get contactChatMomentsEtc => 'Чат, Моменты, Спорт и т.д.';

  @override
  String get contactMoreInfo => 'Подробнее';

  @override
  String get contactCommonGroups => 'Общие группы';

  @override
  String get contactSource => 'Источник';

  @override
  String get settingsNotificationSettings => 'Уведомления';

  @override
  String get settingsPrivacy => 'Конфиденциальность';

  @override
  String get settingsAppearance => 'Внешний вид';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get commonLogout => 'Выйти';

  @override
  String get commonLogoutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get profileNickname => 'Никнейм';

  @override
  String get profileEnterNickname => 'Введите никнейм';

  @override
  String get profileSignature => 'Подпись';

  @override
  String get profileAddSignature => 'Добавить подпись';

  @override
  String get commonTakePhoto => 'Сделать фото';

  @override
  String get profileChooseFromGallery => 'Выбрать из галереи';

  @override
  String profileSaveFailed(String error) {
    return 'Ошибка сохранения: $error';
  }

  @override
  String get authSecureDecentralizedChat =>
      'Безопасный децентрализованный мессенджер';

  @override
  String get commonEndToEndEncryption => 'Сквозное шифрование';

  @override
  String get authMessagesOnlyYouCanSee =>
      'Сообщения видны только вам и получателю';

  @override
  String get authDecentralized => 'Децентрализованный';

  @override
  String get authBasedOnMatrix => 'На основе открытого протокола Matrix';

  @override
  String get authWalletIntegration => 'Интеграция с кошельком';

  @override
  String get authEasyCryptoTransfer => 'Простые криптовалютные переводы';

  @override
  String get authRegister => 'Зарегистрироваться';

  @override
  String get authAgreeTerms => 'Входя в систему, вы соглашаетесь с';

  @override
  String get authTermsOfService => 'Условиями использования';

  @override
  String get authAnd => ' и ';

  @override
  String get authPrivacyPolicy => 'Политикой конфиденциальности';

  @override
  String get authServerAddress => 'Адрес сервера';

  @override
  String get authEnterServerAddress => 'Введите адрес сервера';

  @override
  String authConnectedTo(String serverName) {
    return 'Подключено к $serverName';
  }

  @override
  String get authUsername => 'Имя пользователя';

  @override
  String get authEnterUsername => 'Введите имя пользователя';

  @override
  String get authUsernameOrEmail => 'Имя пользователя или Email';

  @override
  String get authEnterUsernameOrEmail => 'Введите имя пользователя или email';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authEnterPassword => 'Введите пароль';

  @override
  String get authRegisterAccount => 'Зарегистрироваться';

  @override
  String get authForgotPassword => 'Забыли пароль';

  @override
  String get authOtherLoginMethods => 'Другие способы входа';

  @override
  String get authCreateAccount => 'Создать аккаунт';

  @override
  String get authJoinN42Chat =>
      'Присоединитесь к N42 Chat, чтобы начать общение';

  @override
  String get authUsernameHint => '3-20 символов, буквы/цифры/_';

  @override
  String get authUsernameMinLength =>
      'Имя пользователя должно содержать не менее 3 символов';

  @override
  String get authUsernameMaxLength =>
      'Имя пользователя должно содержать не более 20 символов';

  @override
  String get authUsernameFormat =>
      'Имя пользователя может содержать только буквы, цифры и подчёркивания';

  @override
  String get authPasswordHint => 'Минимум 8 символов';

  @override
  String get commonPasswordMinLength =>
      'Пароль должен содержать не менее 8 символов';

  @override
  String get authConfirmPassword => 'Подтвердите пароль';

  @override
  String get authFilled => 'Заполнено';

  @override
  String get authEnterInviteCode => 'Введите код приглашения';

  @override
  String get authAlreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get authLoginNow => 'Войти';

  @override
  String get profileAvatar => 'Аватар';

  @override
  String get profileStatus => 'Статус';

  @override
  String get commonLoading => 'Загрузка...';

  @override
  String get conversationNoConversations => 'Нет разговоров';

  @override
  String get conversationTapToChat => 'Нажмите справа вверху, чтобы начать чат';

  @override
  String get conversationStartGroup => 'Создать групповой чат';

  @override
  String get commonScan => 'Сканировать';

  @override
  String get commonPayment => 'Оплата';

  @override
  String commonFeatureComingSoon(String feature) {
    return '$feature скоро появится';
  }

  @override
  String get conversationMarkAsRead => 'Отметить как прочитанное';

  @override
  String get commonUnmute => 'Включить звук';

  @override
  String get commonMute => 'Без звука';

  @override
  String get conversationUnpin => 'Открепить';

  @override
  String get conversationPin => 'Закрепить';

  @override
  String get conversationDeleteConversation => 'Удалить разговор';

  @override
  String conversationDeleteConversationConfirm(String name) {
    return 'Удалить разговор с \"$name\"?';
  }

  @override
  String get commonNoContacts => 'Нет контактов';

  @override
  String get contactAddFriendsToChat => 'Добавьте друзей, чтобы начать общение';

  @override
  String get contactNotFound => 'Контакт не найден';

  @override
  String get contactTryOtherKeywords =>
      'Попробуйте другие ключевые слова или глобальный поиск';

  @override
  String get contactSearchResults => 'Результаты поиска';

  @override
  String get contactNewFriends => 'Новые друзья';

  @override
  String get contactChatOnlyFriends => 'Друзья только в чате';

  @override
  String get contactOfficialAccounts => 'Официальные аккаунты';

  @override
  String get contactServiceAccounts => 'Сервисные аккаунты';

  @override
  String get contactEnterpriseContacts => 'Корпоративные контакты';

  @override
  String get contactRecommendToFriend => 'Поделиться контактом';

  @override
  String get commonSetRemark => 'Установить заметку';

  @override
  String get contactSendingCard => 'Отправка контактной карточки...';

  @override
  String get commonFileLabel => 'Файл';

  @override
  String get commonLocationLabel => 'Местоположение';

  @override
  String contactRecommendFailed(String error) {
    return 'Ошибка рекомендации: $error';
  }

  @override
  String get profileEnterRemark => 'Введите заметку';

  @override
  String get contactOpeningChat => 'Открытие чата...';

  @override
  String contactOpenChatFailed(String error) {
    return 'Не удалось открыть чат: $error';
  }

  @override
  String get contactAddContact => 'Добавить контакт';

  @override
  String get contactEnterUserId => 'Введите ID пользователя';

  @override
  String get contactNoFriendRequests => 'Нет запросов в друзья';

  @override
  String get commonAccept => 'Принять';

  @override
  String get commonReject => 'Отклонить';

  @override
  String get commonNoGroups => 'Нет групп';

  @override
  String get contactSelectFriendToRecommend =>
      'Выберите друга для рекомендации';

  @override
  String get commonSearchContacts => 'Поиск контактов';

  @override
  String get contactNoContactsFound => 'Контакты не найдены';

  @override
  String get favoriteYesterday => 'Вчера';

  @override
  String get chatJustNow => 'Только что';

  @override
  String get profileOnline => 'В сети';

  @override
  String get profileOffline => 'Не в сети';

  @override
  String get searchContactsGroupsMessages =>
      'Поиск контактов, групп, сообщений';

  @override
  String get searchError => 'Ошибка поиска';

  @override
  String get chatSearchHint => 'Поиск контактов, групп и сообщений';

  @override
  String get searchHistory => 'История поиска';

  @override
  String get commonClear => 'Очистить';

  @override
  String get commonAll => 'Все';

  @override
  String get searchGroups => 'Группы';

  @override
  String get searchNoResults => 'Нет результатов';

  @override
  String commonGroupMembers(int count) {
    return 'Участники ($count)';
  }

  @override
  String get groupMembersTitle => 'Участники группы';

  @override
  String get groupViewAll => 'Показать все';

  @override
  String get groupOwner => 'Владелец';

  @override
  String get groupAdmin => 'Администратор';

  @override
  String get groupInvite => 'Пригласить';

  @override
  String get commonGroupAnnouncement => 'Объявление группы';

  @override
  String get commonNotSet => 'Не установлено';

  @override
  String get groupDescription => 'Описание группы';

  @override
  String get groupPublicGroup => 'Публичная группа';

  @override
  String get commonClearChatHistory => 'Очистить историю чата';

  @override
  String get commonDissolveGroup => 'Распустить группу';

  @override
  String get commonLeaveGroup => 'Покинуть группу';

  @override
  String get groupChangeGroupName => 'Изменить название группы';

  @override
  String get commonEnterGroupName => 'Введите название группы';

  @override
  String get commonConfirm => 'Подтвердить';

  @override
  String get groupEnterGroupDescription => 'Введите описание группы';

  @override
  String get groupPublish => 'Опубликовать';

  @override
  String get chatClearHistoryConfirm =>
      'Очистить всю историю чата? Это действие нельзя отменить.';

  @override
  String get chatClearAction => 'Очистить';

  @override
  String get commonChatHistoryCleared => 'История чата очищена';

  @override
  String get commonDissolve => 'Распустить';

  @override
  String get groupQrCode => 'QR-код группы';

  @override
  String get commonSearchChatHistory => 'Поиск в истории чата';

  @override
  String get groupIdCopied => 'ID группы скопирован';

  @override
  String get transferEnterOrPasteAddress =>
      'Введите или вставьте адрес кошелька';

  @override
  String get transferSelectToken => 'Выбрать токен';

  @override
  String get commonTransferAmount => 'Сумма перевода';

  @override
  String get transferAvailable => 'Доступно';

  @override
  String get transferMemoOptional => 'Примечание (необязательно)';

  @override
  String get transferConfirmTransfer => 'Подтвердить перевод';

  @override
  String get transferAddressVerified => 'Адрес подтверждён';

  @override
  String transferAvailableBalance(String balance, String symbol) {
    return 'Доступно: $balance $symbol';
  }

  @override
  String get commonEnterAmount => 'Введите сумму';

  @override
  String get commonRedPacketCountMin => 'Требуется минимум 1 красный конверт';

  @override
  String get commonViewRedPacketDetails =>
      'Посмотреть детали красного конверта';

  @override
  String get commonEnterTransferAmount => 'Введите сумму перевода';

  @override
  String get commonTransferTo => 'Перевести';

  @override
  String commonFromSender(String name, Object senderName) {
    return 'От $senderName';
  }

  @override
  String get commonConfirmReceive => 'Подтвердить получение';

  @override
  String get groupProfile => 'Информация о группе';

  @override
  String get groupRemoveMember => 'Удалить из группы';

  @override
  String get commonRemove => 'Удалить';

  @override
  String get profileClearStatus => 'Очистить статус';

  @override
  String get profileClearStatusConfirm => 'Очистить текущий статус?';

  @override
  String get profileStatusCleared => 'Статус очищен';

  @override
  String get profileUserNotExist => 'Пользователь не существует';

  @override
  String get profileUserIdCopied => 'ID пользователя скопирован';

  @override
  String get commonReport => 'Пожаловаться';

  @override
  String get profileQrCode => 'QR-код';

  @override
  String get profileAvatarUpdated => 'Аватар обновлён';

  @override
  String commonSelectImageFailed(String error) {
    return 'Не удалось выбрать изображение: $error';
  }

  @override
  String get profileChangeName => 'Изменить имя';

  @override
  String get profileMale => 'Мужской';

  @override
  String get profileFemale => 'Женский';

  @override
  String chatFeatureInDev(String feature) {
    return '$feature в разработке...';
  }

  @override
  String profileSaveAddressFailed(String error) {
    return 'Не удалось сохранить адрес: $error';
  }

  @override
  String get profileAddNew => 'Добавить';

  @override
  String get profileAddAddress => 'Добавить адрес';

  @override
  String get profileAddressAdded => 'Адрес добавлен';

  @override
  String get profileAddressUpdated => 'Адрес обновлён';

  @override
  String get profileDeleteAddress => 'Удалить адрес';

  @override
  String get profileAddressDeleted => 'Адрес удалён';

  @override
  String profileSaveInvoiceFailed(String error) {
    return 'Не удалось сохранить счёт: $error';
  }

  @override
  String get profileMyInvoices => 'Мои счета';

  @override
  String get profileAddInvoice => 'Добавить счёт';

  @override
  String get profileInvoiceAdded => 'Счёт добавлен';

  @override
  String get profileInvoiceUpdated => 'Счёт обновлён';

  @override
  String get profileDeleteInvoice => 'Удалить счёт';

  @override
  String get profileInvoiceDeleted => 'Счёт удалён';

  @override
  String get profilePersonal => 'Личный';

  @override
  String get groupSelectAtLeastOne =>
      'Пожалуйста, выберите хотя бы одного участника';

  @override
  String get chatFileNotExist => 'Файл не существует';

  @override
  String chatSendFailed(String error) {
    return 'Ошибка отправки: $error';
  }

  @override
  String get chatCannotOpenBrowser => 'Не удаётся открыть браузер';

  @override
  String chatSelectFileFailed(String error) {
    return 'Не удалось выбрать файл: $error';
  }

  @override
  String settingsSetupFailed(String error) {
    return 'Ошибка настройки: $error';
  }

  @override
  String get transferEnterValidAmount =>
      'Пожалуйста, введите действительную сумму';

  @override
  String get commonAddressCopied => 'Адрес скопирован';

  @override
  String favoriteOpenItem(String content) {
    return 'Открыть: $content';
  }

  @override
  String get favoriteDeleted => 'Удалено';

  @override
  String get profileWallet => 'Кошелёк';

  @override
  String get chatRecording => 'Запись';

  @override
  String get chatInvalidVideoUrl => 'Недействительный URL видео';

  @override
  String get chatDownloadFile => 'Скачать файл';

  @override
  String get chatClearChatHistoryTitle => 'Очистить историю чата';

  @override
  String get chatVideoCall => 'Видеовызов';

  @override
  String get commonVoiceCall => 'Голосовой вызов';

  @override
  String get callLeaveMeeting => 'Покинуть конференцию';

  @override
  String get chatDetails => 'Детали чата';

  @override
  String get chatViewAllGroupMembers => 'Просмотреть всех участников';

  @override
  String get chatGroupName => 'Название группы';

  @override
  String get chatGroupNameUpdated => 'Название группы обновлено';

  @override
  String get chatUpdateFailed => 'Ошибка обновления';

  @override
  String get chatNoPermissionToModify => 'У вас нет прав на изменение';

  @override
  String get chatGroupManagement => 'Управление группой';

  @override
  String get chatMyNicknameInGroup => 'Мой никнейм в группе';

  @override
  String get chatPinChat => 'Закрепить чат';

  @override
  String get chatStrongReminder => 'Важное напоминание';

  @override
  String get chatSetChatBackground => 'Установить фон чата';

  @override
  String get chatUnknownFile => 'Неизвестный файл';

  @override
  String get chatDownload => 'Скачать';

  @override
  String get chatInvalidLocation => 'Недействительное местоположение';

  @override
  String get chatTapToCancel => 'Нажмите для отмены';

  @override
  String chatCaptureFailed(Object error) {
    return 'Ошибка захвата: $error';
  }

  @override
  String get chatProcessingVideo => 'Обработка видео...';

  @override
  String get chatVideoFileNotExist => 'Видеофайл не существует';

  @override
  String get chatVideoDataEmpty => 'Данные видео пусты';

  @override
  String get chatVideoTooLarge => 'Размер видео не может превышать 100 МБ';

  @override
  String get chatSendingVideo => 'Отправка видео...';

  @override
  String chatSendVideoFailed(Object error) {
    return 'Не удалось отправить видео: $error';
  }

  @override
  String get chatImageFileNotExist => 'Файл изображения не существует';

  @override
  String get commonImageDataEmpty => 'Данные изображения пусты';

  @override
  String get chatSendingImage => 'Отправка изображения...';

  @override
  String chatSendImageFailed(Object error) {
    return 'Не удалось отправить изображение: $error';
  }

  @override
  String get chatSendLocation => 'Отправить местоположение';

  @override
  String get chatSelectLocationAndSend => 'Выберите местоположение и отправьте';

  @override
  String get chatShareRealTimeLocation =>
      'Поделиться местоположением в реальном времени';

  @override
  String get chatShareLocationForOneHour =>
      'Поделиться местоположением с другом на 1 час';

  @override
  String get chatLocationSent => 'Местоположение отправлено';

  @override
  String get chatSelectMessages => 'Выбрать сообщения';

  @override
  String chatSelectedCount(int count) {
    return 'Выбрано $count';
  }

  @override
  String get chatSelectAll => 'Выбрать все';

  @override
  String chatGroupChatCount(int count) {
    return 'Групповой чат ($count)';
  }

  @override
  String get chatPrivateChat => 'Личный чат';

  @override
  String get chatNoMessages => 'Нет сообщений';

  @override
  String get chatSendFirstMessage =>
      'Отправьте первое сообщение, чтобы начать общение';

  @override
  String get chatEncryptionNotice =>
      'Этот чат защищён сквозным шифрованием. Только вы и получатель можете читать сообщения.';

  @override
  String get chatMultiForward => 'Переслать';

  @override
  String get chatCollect => 'Собрать';

  @override
  String get chatNoMembers => 'Нет участников';

  @override
  String get chatMemberNotFound => 'Участник не найден';

  @override
  String get chatVoiceFileNotExist => 'Голосовой файл не существует';

  @override
  String get chatVoiceFileEmpty => 'Голосовой файл пуст';

  @override
  String get chatSendingVoice => 'Отправка голосового сообщения...';

  @override
  String chatSendVoiceFailed(Object error) {
    return 'Не удалось отправить голосовое сообщение: $error';
  }

  @override
  String get chatMessageForwarded => 'Сообщение переслано';

  @override
  String chatForwardFailed(Object error) {
    return 'Ошибка пересылки: $error';
  }

  @override
  String get chatUnfavorited => 'Удалено из избранного';

  @override
  String get chatFavorited => 'Добавлено в избранное';

  @override
  String get chatReactionAdded => 'Реакция добавлена';

  @override
  String get chatReactionRemoved => 'Реакция удалена';

  @override
  String get chatFailedMessageDeleted => 'Неотправленное сообщение удалено';

  @override
  String get chatDeleteMessages => 'Удалить сообщения';

  @override
  String chatDeleteMessagesConfirm(Object count) {
    return 'Вы уверены, что хотите удалить $count сообщений?';
  }

  @override
  String chatNoteOtherMessages(Object count) {
    return 'Примечание: $count сообщений от других и будут удалены только для вас.';
  }

  @override
  String chatMyMessagesWillBeRecalled(Object count) {
    return '$count ваших сообщений будут отозваны для всех.';
  }

  @override
  String chatRecalledCount(Object count, Object localCount) {
    return 'Отозвано $count сообщений, $localCount удалено только для вас';
  }

  @override
  String chatRecalledMessages(Object count) {
    return 'Отозвано $count сообщений';
  }

  @override
  String chatDeletedLocally(Object count) {
    return '$count сообщений удалено только для вас';
  }

  @override
  String chatForwardedCount(Object count) {
    return 'Переслано $count сообщений';
  }

  @override
  String chatForwardComplete(Object failed, Object success) {
    return 'Пересылка завершена: $success успешно, $failed ошибок';
  }

  @override
  String get chatRemindOnlyInGroup =>
      'Функция напоминания доступна только в групповом чате';

  @override
  String get chatOnlyTextSearchable =>
      'Поиск доступен только для текстовых сообщений';

  @override
  String chatSearchFor(Object text) {
    return 'Искать \"$text\"';
  }

  @override
  String get chatBaiduSearch => 'Поиск Baidu';

  @override
  String get chatGoogleSearch => 'Поиск Google';

  @override
  String get chatBingSearch => 'Поиск Bing';

  @override
  String get chatCalling => 'Вызов...';

  @override
  String get chatRinging => 'Звонок...';

  @override
  String get chatInCall => 'В разговоре';

  @override
  String commonFeatureInDevelopment(String feature) {
    return 'Функция в разработке...';
  }

  @override
  String chatCollectMessages(Object count) {
    return 'Сохранено $count сообщений';
  }

  @override
  String commonMemberCount(int count) {
    return '$count участников';
  }

  @override
  String groupDone(int count) {
    return 'Готово($count)';
  }

  @override
  String get profileServices => 'Сервисы';

  @override
  String get commonFavorites => 'Избранное';

  @override
  String get profileOrdersAndCards => 'Заказы и карты';

  @override
  String get profileStickers => 'Стикеры';

  @override
  String profileStatusSetTo(String status) {
    return 'Статус установлен: $status';
  }

  @override
  String get profileAvatarUploadFailed => 'Не удалось загрузить аватар';

  @override
  String get profilePersonalProfile => 'Личный профиль';

  @override
  String get profileName => 'Имя';

  @override
  String get profileGender => 'Пол';

  @override
  String get profileRegion => 'Регион';

  @override
  String get commonMyQrCode => 'Мой QR-код';

  @override
  String get profilePoke => 'Толкнуть';

  @override
  String get profileRingtone => 'Рингтон';

  @override
  String get profileDefaultRingtone => 'Рингтон по умолчанию';

  @override
  String get profileMyAddresses => 'Мои адреса';

  @override
  String profileGenderSetTo(String gender) {
    return 'Пол установлен: $gender';
  }

  @override
  String get profileSelectRegion => 'Выбрать регион';

  @override
  String get profileSelectCity => 'Выбрать город';

  @override
  String profileRegionSetTo(String region) {
    return 'Регион установлен: $region';
  }

  @override
  String get profileSetPoke => 'Настроить толчок';

  @override
  String get profileFriendPokedMe => 'Друг толкнул меня';

  @override
  String get profileExample => 'Пример';

  @override
  String get profileOnTheShoulder => ' по плечу';

  @override
  String get profilePokeCleared => 'Толчок сброшен';

  @override
  String profilePokeSetTo(String suffix) {
    return 'Толчок установлен: толкнул меня$suffix';
  }

  @override
  String get profileEditSignature => 'Редактировать подпись';

  @override
  String get profileIntroduceYourself => 'Предложение, чтобы представить себя';

  @override
  String get profileSignatureCleared => 'Подпись удалена';

  @override
  String get profileSignatureUpdated => 'Подпись обновлена';

  @override
  String get profileScanToAddFriend =>
      'Отсканируйте QR-код выше, чтобы добавить меня в друзья';

  @override
  String profileRingtoneSetTo(String ringtone) {
    return 'Рингтон установлен: $ringtone';
  }

  @override
  String commonConfirmDissolveGroup(String name) {
    return 'Вы уверены, что хотите расформировать «$name»? Это действие нельзя отменить.';
  }

  @override
  String get authEnterValidServerAddress =>
      'Пожалуйста, введите действительный адрес сервера';

  @override
  String get authEnterServerAddressFirst => 'Сначала введите адрес сервера';

  @override
  String get authPasskeyRequiresServer =>
      'Для входа через Passkey требуется поддержка сервера';

  @override
  String get authLoginAgreement => 'Входя в систему, вы соглашаетесь с ';

  @override
  String get authPleaseAgreeToTerms =>
      'Пожалуйста, прочитайте и согласитесь с Условиями использования и Политикой конфиденциальности';

  @override
  String get authRegisterFailed => 'Ошибка регистрации';

  @override
  String get commonReenterPassword => 'Введите пароль повторно';

  @override
  String get commonPasswordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get authInviteCodeBuiltIn => 'Код приглашения (встроенный)';

  @override
  String get authInviteCodeBuiltInNote =>
      'Код приглашения встроен, обычно изменять не требуется';

  @override
  String get authIHaveReadAndAgree => 'Я прочитал и согласен с ';

  @override
  String get mainStartGroupChat => 'Создать групповой чат';

  @override
  String get mainAddFriends => 'Добавить друзей';

  @override
  String get mainPaymentAndCollection => 'Оплата';

  @override
  String contactCount(int count) {
    return '$count контактов';
  }

  @override
  String get contactAddToHomeScreen => 'Добавить на главный экран';

  @override
  String contactRecommendedCardTo(String contact, String recipient) {
    return 'Рекомендовано карточка $contact для $recipient';
  }

  @override
  String get contactEnterRemarkName => 'Введите имя заметки';

  @override
  String contactRemarkSetTo(String remark) {
    return 'Заметка установлена: $remark';
  }

  @override
  String contactAcceptedFriendRequest(String name) {
    return 'Принят запрос в друзья от $name';
  }

  @override
  String contactRejectedFriendRequest(String name) {
    return 'Отклонён запрос в друзья от $name';
  }

  @override
  String get commonGroupInvites => 'Приглашения в группы';

  @override
  String commonMyGroups(int count) {
    return 'Мои группы ($count)';
  }

  @override
  String get commonInvitedToJoinGroup => 'Приглашён в группу';

  @override
  String commonConfirmLeaveGroup(String name) {
    return 'Вы уверены, что хотите покинуть «$name»?';
  }

  @override
  String get commonLeave => 'Покинуть';

  @override
  String get commonRecallThisMessage => 'Отозвать это сообщение?';

  @override
  String get commonSavedToGallery => 'Сохранено в галерею';

  @override
  String get commonFailedToSave => 'Ошибка сохранения';

  @override
  String get chatSaving => 'Сохранение...';

  @override
  String get commonShare => 'Поделиться';

  @override
  String get chatSaveToGallery => 'Сохранить в галерею';

  @override
  String chatDownloadFailed(String code) {
    return 'Ошибка загрузки: $code';
  }

  @override
  String commonShareFailed(String error) {
    return 'Ошибка при отправке: $error';
  }

  @override
  String get chatFailedToLoadImage => 'Не удалось загрузить изображение';

  @override
  String get chatVideoRecordingFailed =>
      'Ошибка записи видео. Пожалуйста, попробуйте снова.';

  @override
  String get profileRedPacket => 'Красный конверт';

  @override
  String get commonMusic => 'Музыка';

  @override
  String get commonCoupon => 'Купон';

  @override
  String get commonGift => 'Подарок';

  @override
  String get commonPoll => 'Опрос';

  @override
  String get favoriteText => 'Текст';

  @override
  String get favoriteLinkLabel => 'Ссылка';

  @override
  String get favoriteNote => 'Заметка';

  @override
  String get favoriteMyNotes => 'Мои заметки';

  @override
  String get favoriteToday => 'Сегодня';

  @override
  String favoriteDaysAgoText(int count) {
    return '$count дней назад';
  }

  @override
  String favoriteDateFormat(int month, int day) {
    return '$day.$month';
  }

  @override
  String get favoriteNoFavorites => 'Пока нет избранного';

  @override
  String get favoriteLongPressToFavorite =>
      'Нажмите и удерживайте сообщение, чтобы добавить в избранное';

  @override
  String get favoriteNewNote => 'Новая заметка';

  @override
  String get favoriteLink => 'Добавить ссылку в избранное';

  @override
  String get favoriteEditTags => 'Редактировать теги';

  @override
  String get favoriteDeleteFavorite => 'Удалить из избранного';

  @override
  String get favoriteDeleteFavoriteConfirm =>
      'Вы уверены, что хотите удалить это из избранного?';

  @override
  String get favoriteNoSearchResultsFound => 'Результаты не найдены';

  @override
  String get commonSendRedPacket => 'Отправить красный конверт';

  @override
  String get transferAmount => 'Сумма';

  @override
  String get commonRedPacketCover => 'Обложка красного конверта';

  @override
  String get commonRedPacketType => 'Тип красного конверта';

  @override
  String get commonNormalRedPacket => 'Обычный';

  @override
  String get commonLuckyRedPacket => 'Счастливый';

  @override
  String get commonRedPacketCount => 'Количество конвертов';

  @override
  String get commonPieces => 'штук';

  @override
  String get commonPutMoneyInRedPacket => 'Положить деньги в красный конверт';

  @override
  String get commonRedPacketRefundNotice =>
      'Неполученные красные конверты будут возвращены через 24 часа';

  @override
  String get commonOpenRedPacket => 'Открыть';

  @override
  String get commonRedPacketAllClaimed => 'Все красные конверты получены';

  @override
  String get commonRedPacketExpired => 'Красный конверт истёк';

  @override
  String get commonAddTransferNote => 'Добавить примечание к переводу';

  @override
  String get commonYuan => 'руб.';

  @override
  String get commonReplyWithEmoji => 'Ответить этим эмодзи';

  @override
  String get contactEditRemark => 'Редактировать заметку';

  @override
  String get contactSetPermissions => 'Установить разрешения';

  @override
  String get profileAddToBlacklist => 'Добавить в чёрный список';

  @override
  String get contactDeleteContact => 'Удалить контакт';

  @override
  String contactDeleteContactConfirm(String name) {
    return 'Вы уверены, что хотите удалить $name?';
  }

  @override
  String get transferTitle => 'Перевод';

  @override
  String get transferReceiverAddressLabel => 'Адрес получателя';

  @override
  String get transferSelectTokenLabel => 'Выбрать токен';

  @override
  String get transferAmountLabel => 'Сумма перевода';

  @override
  String get transferMemoLabel => 'Примечание (необязательно)';

  @override
  String get transferAddMemoHint => 'Добавить примечание';

  @override
  String get transferSendPaymentRequest => 'Отправить запрос на оплату';

  @override
  String get transferQrCodeGenerateFailed => 'Ошибка генерации QR-кода';

  @override
  String get transferScanQrToPayMe => 'Отсканируйте QR-код, чтобы оплатить мне';

  @override
  String get transferMyWalletAddress => 'Адрес моего кошелька';

  @override
  String get transferCreatePaymentRequest => 'Создать запрос на оплату';

  @override
  String profileN42IdLabel(String id) {
    return 'Идентификатор N42: $id';
  }

  @override
  String get commonRedPacketDefaultGreeting => 'С наилучшими пожеланиями';

  @override
  String commonSenderRedPacket(String name) {
    return 'Красный конверт от $name';
  }

  @override
  String get transferEnterValidAddress =>
      'Пожалуйста, введите действительный адрес';

  @override
  String get transferPleaseSelectToken => 'Пожалуйста, выберите токен';

  @override
  String get commonReceivedTransfer => 'Полученный перевод';

  @override
  String commonSenderSentRedPacket(String name) {
    return '$name отправил(а) красный конверт';
  }

  @override
  String get commonSavedToBalance =>
      'Сохранено на баланс, можно переводить напрямую';

  @override
  String get commonRedPacketExpiredOrEmpty =>
      'Красный конверт истёк/все получены';

  @override
  String get transferScanFeatureComingSoon =>
      'Функция сканирования скоро появится...';

  @override
  String get contactSetAsStarred => 'Отметить как важного';

  @override
  String get contactAddToBlocklist => 'Добавить в чёрный список';

  @override
  String get commonClaimedYour => ' получил(а) ваш ';

  @override
  String get commonClaimedText => ' получил(а) ';

  @override
  String commonUserTyping(String name) {
    return '$name печатает...';
  }

  @override
  String get commonTyping => 'Печатает...';

  @override
  String get commonWaitingToReceive => 'Ожидание получения';

  @override
  String get commonTapToClaim => 'Нажмите, чтобы получить';

  @override
  String get commonHasBeenReceived => 'Получено';

  @override
  String get commonGetLucky => 'Удачи';

  @override
  String get qrcodeCameraStartFailed => 'Не удалось запустить камеру';

  @override
  String get qrcodeUnknownError => 'Неизвестная ошибка';

  @override
  String get qrcodePlaceQrCodeInFrame =>
      'Поместите QR-код в рамку для сканирования';

  @override
  String get qrcodeCloseManualInput => 'Закрыть ручной ввод';

  @override
  String get qrcodeManualInputUserId => 'Ввести ID пользователя вручную';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get profileSetStatus => 'Установить статус';

  @override
  String get profileVisibleToFriends24h => 'Виден друзьям в течение 24 часов';

  @override
  String get profileWriteStatus => 'Написать статус';

  @override
  String get profileEnterYourStatus => 'Введите ваш статус...';

  @override
  String get profileOk => 'ОК';

  @override
  String get qrcodeCameraPermissionRequired =>
      'Для сканирования QR-кода требуется разрешение камеры';

  @override
  String get qrcodeCameraPermissionDenied =>
      'Разрешение камеры отклонено навсегда. Пожалуйста, включите его в настройках системы.';

  @override
  String qrcodePermissionCheckError(String error) {
    return 'Ошибка проверки разрешения: $error';
  }

  @override
  String get qrcodeInvalidQrCode => 'Недействительный QR-код';

  @override
  String qrcodeCannotAddFriend(String error) {
    return 'Не удаётся добавить друга: $error';
  }

  @override
  String get qrcodeScanQrCode => 'Сканировать QR-код';

  @override
  String get qrcodeCheckingCameraPermission => 'Проверка разрешения камеры...';

  @override
  String get qrcodeNeedCameraPermission => 'Требуется разрешение камеры';

  @override
  String get qrcodeRetryPermission => 'Повторить';

  @override
  String get qrcodeOpenSettings => 'Открыть настройки';

  @override
  String get groupInviteMembers => 'Пригласить участников';

  @override
  String groupInviteCount(int count) {
    return 'Пригласить($count)';
  }

  @override
  String get profileNoShippingAddress => 'Нет адреса доставки';

  @override
  String get profileDefaultLabel => 'По умолчанию';

  @override
  String get profileNoInvoice => 'Нет счёта';

  @override
  String get profileCompany => 'Компания';

  @override
  String get profileTaxNumber => 'ИНН';

  @override
  String get profileConfirmDeleteAddress =>
      'Вы уверены, что хотите удалить этот адрес?';

  @override
  String get profileConfirmDeleteInvoice =>
      'Вы уверены, что хотите удалить этот счёт?';

  @override
  String get commonGroupOwner => 'Владелец';

  @override
  String get commonGroupAdmin => 'Администратор';

  @override
  String get groupSearchMembers => 'Поиск участников';

  @override
  String groupTotalMembers(int count) {
    return '$count участников';
  }

  @override
  String get chatRemoveFromGroup => 'Удалить из группы';

  @override
  String groupConfirmRemoveMember(String name) {
    return 'Вы уверены, что хотите удалить \"$name\" из группы?';
  }

  @override
  String get chatUnknownSong => 'Неизвестная песня';

  @override
  String get chatUnknownArtist => 'Неизвестный исполнитель';

  @override
  String get chatUnknownContact => 'Неизвестный контакт';

  @override
  String get chatPersonalCard => 'Контактная карточка';

  @override
  String get chatSingleChoice => 'Один';

  @override
  String get chatMultiChoice => 'Несколько';

  @override
  String get chatEnded => 'Завершён';

  @override
  String get chatEndPollButton => 'Завершить опрос';

  @override
  String get chatPollHint =>
      'Опрос будет отображён в чате. Участники группы смогут голосовать.';

  @override
  String get chatSearchSongOrArtist => 'Поиск песни или исполнителя';

  @override
  String get chatNoSongsFound => 'Песни не найдены';

  @override
  String get chatSongNameOptional => 'Название песни (необязательно)';

  @override
  String get chatEnterSongName => 'Введите название песни';

  @override
  String get chatArtistNameOptional => 'Исполнитель (необязательно)';

  @override
  String get chatEnterArtistName => 'Введите имя исполнителя';

  @override
  String get chatRealTimeLocationSharing =>
      'Отправка местоположения в реальном времени в разработке...';

  @override
  String get profileVoiceCallFeatureInDev => 'Голосовой вызов в разработке...';

  @override
  String get profileReportFeatureInDev => 'Функция жалобы в разработке...';

  @override
  String get profileShareFeatureInDev => 'Функция отправки в разработке...';

  @override
  String get profileQrCodeFeatureInDev => 'Функция QR-кода в разработке...';

  @override
  String get qrcodeScanQrToAddMe =>
      'Отсканируйте QR-код выше, чтобы добавить меня в друзья';

  @override
  String get qrcodeSaveToAlbum => 'Сохранить в альбом';

  @override
  String get qrcodeChangeStyle => 'Изменить стиль';

  @override
  String get qrcodeCopyId => 'Копировать ID';

  @override
  String get qrcodeIdCopied => 'ID скопирован';

  @override
  String get qrcodeMoreStylesFeatureComingSoon =>
      'Больше стилей скоро появится';

  @override
  String get profileBio => 'О себе';

  @override
  String get profileHomeServer => 'Сервер';

  @override
  String get profileShareContactCard => 'Поделиться контактной карточкой';

  @override
  String get profileRemoveFromBlacklist => 'Удалить из чёрного списка';

  @override
  String get profileConfirmAddBlacklist =>
      'Вы уверены, что хотите добавить этого пользователя в чёрный список? Вы не будете получать от него сообщения.';

  @override
  String get profileConfirmRemoveBlacklist =>
      'Вы уверены, что хотите удалить этого пользователя из чёрного списка?';

  @override
  String get profileRemarkSaved => 'Заметка сохранена';

  @override
  String get profileRemarkCleared => 'Заметка удалена';

  @override
  String get transferReceive => 'Получить';

  @override
  String get transferPleaseConnectWallet => 'Сначала подключите ваш кошелёк';

  @override
  String get transferSendRequest => 'Отправить запрос';

  @override
  String get transferPleaseEnterValidAmount =>
      'Пожалуйста, введите действительную сумму';

  @override
  String get searchPlaceholder => 'Поиск контактов, групп, сообщений';

  @override
  String get searchEnterKeywordToSearch => 'Введите ключевое слово для поиска';

  @override
  String get searchClearHistory => 'Очистить';

  @override
  String searchNoResultsForQuery(String query) {
    return 'Результаты не найдены для \"$query\"';
  }

  @override
  String get searchAllResults => 'Все';

  @override
  String get searchInChat => 'Поиск в чате';

  @override
  String get searchContactLabel => 'Контакт';

  @override
  String get searchGroupLabel => 'Группа';

  @override
  String get searchConversationLabel => 'Беседа';

  @override
  String get searchMessageLabel => 'Сообщение';

  @override
  String get settingsSecurityTitle => 'Безопасность';

  @override
  String get settingsKeyBackup => 'Резервное копирование ключей';

  @override
  String get settingsBackupEncryptionKeys =>
      'Резервное копирование ключей шифрования';

  @override
  String settingsKeysBackedUp(int count) {
    return '$count ключей сохранено';
  }

  @override
  String get settingsBackupNotSet => 'Резервная копия не настроена';

  @override
  String get settingsRestoreKeys => 'Восстановить ключи';

  @override
  String get settingsRestoreKeysFromBackup =>
      'Восстановить ключи шифрования из резервной копии';

  @override
  String get settingsExportKeys => 'Экспортировать ключи';

  @override
  String get settingsExportKeysToFile => 'Экспортировать ключи в файл';

  @override
  String get settingsLoggedInDevices => 'Авторизованные устройства';

  @override
  String get settingsNoOtherDevices => 'Нет других устройств';

  @override
  String get settingsVerified => 'Подтверждено';

  @override
  String get settingsUnverified => 'Не подтверждено';

  @override
  String get settingsAdvanced => 'Дополнительно';

  @override
  String get settingsCrossSigning => 'Кросс-подпись';

  @override
  String get settingsEnabled => 'Включено';

  @override
  String get settingsNotEnabled => 'Не включено';

  @override
  String get settingsResetEncryption => 'Сбросить шифрование';

  @override
  String get settingsDeleteAllEncryptionKeys => 'Удалить все ключи шифрования';

  @override
  String get settingsEncryptionNotSupported => 'Шифрование не поддерживается';

  @override
  String get settingsNotInitialized => 'Не инициализировано';

  @override
  String get settingsBackupKeyTitle => 'Резервное копирование ключей';

  @override
  String get settingsBackupKeyMessage =>
      'Создать новую резервную копию ключей? Это поможет восстановить зашифрованные сообщения на новом устройстве.';

  @override
  String get settingsBackup => 'Сохранить';

  @override
  String get settingsRestoreKeyTitle => 'Восстановить ключи';

  @override
  String get settingsRestoreKeyMessage =>
      'Введите пароль восстановления или ключ восстановления для восстановления зашифрованных сообщений.';

  @override
  String get settingsRestore => 'Восстановить';

  @override
  String get settingsExportKeyTitle => 'Экспортировать ключи';

  @override
  String get settingsExportKeyMessage =>
      'Экспортируемый файл ключей содержит все ваши ключи шифрования. Пожалуйста, храните его в безопасном месте.';

  @override
  String get settingsExport => 'Экспорт';

  @override
  String settingsDeviceIdLabel(String deviceId) {
    return 'ID устройства: $deviceId';
  }

  @override
  String get settingsDeviceStatusVerified => 'Статус: Подтверждено';

  @override
  String get settingsDeviceStatusUnverified => 'Статус: Не подтверждено';

  @override
  String settingsLastActiveLabel(String lastSeen) {
    return 'Последняя активность: $lastSeen';
  }

  @override
  String get settingsVerifyThisDevice => 'Подтвердить это устройство';

  @override
  String get settingsCrossSigningAlreadyEnabled => 'Кросс-подпись уже включена';

  @override
  String get settingsCrossSigningSetupSuccess =>
      'Кросс-подпись успешно настроена';

  @override
  String get settingsResetEncryptionTitle => 'Сбросить шифрование';

  @override
  String get settingsResetEncryptionWarning =>
      'Внимание: Это удалит все ваши ключи шифрования. Вы не сможете расшифровать ранее зашифрованные сообщения. Это действие нельзя отменить.';

  @override
  String get settingsReset => 'Сбросить';

  @override
  String get settingsBackupSuccess =>
      'Резервное копирование ключей успешно выполнено';

  @override
  String get settingsBackupFailed => 'Резервное копирование не выполнено';

  @override
  String get settingsRecoveryKey => 'Ключ восстановления';

  @override
  String get settingsRecoveryKeySaveWarning =>
      'Пожалуйста, сохраните этот ключ восстановления в надежном месте. Он понадобится вам для восстановления зашифрованных сообщений на новом устройстве.';

  @override
  String get settingsRecoveryKeySaved => 'Я сохранил это';

  @override
  String get settingsRestoreSuccess => 'Ключи успешно восстановлены';

  @override
  String get settingsRestoreFailed => 'Восстановление не удалось';

  @override
  String get settingsPassword => 'Пароль';

  @override
  String get settingsEnterRecoveryKey => 'Введите ключ восстановления';

  @override
  String get settingsEnterPassword => 'Введите пароль';

  @override
  String get settingsExportSuccess =>
      'Ключи успешно экспортированы в резервную копию сервера';

  @override
  String get settingsExportNeedBackupFirst =>
      'Пожалуйста, сначала создайте резервную копию ключа';

  @override
  String get settingsExportFailed => 'Экспорт не удался';

  @override
  String get settingsResetSuccess => 'Сброс шифрования выполнен успешно';

  @override
  String get settingsResetFailed => 'Сбросить не удалось';

  @override
  String get callLeaveMeetingConfirm =>
      'Вы уверены, что хотите покинуть конференцию?';

  @override
  String chatPokedSomeone(String name, String suffix) {
    return 'толкнул $name$suffix';
  }

  @override
  String get chatNoContactsToAdd => 'Нет доступных контактов для добавления';

  @override
  String get chatAddMembers => 'Добавить участников';

  @override
  String chatInvitedMembers(int count) {
    return 'Приглашено $count участников';
  }

  @override
  String chatInviteFailed(String error) {
    return 'Ошибка приглашения: $error';
  }

  @override
  String get chatMemberRemoved => 'Участник удалён';

  @override
  String chatRemoveFailed(String error) {
    return 'Ошибка удаления: $error';
  }

  @override
  String get chatRealTimeLocationShareMessage =>
      'После отправки другая сторона сможет видеть ваше местоположение в течение 1 часа.';

  @override
  String get chatStartSharing => 'Начать отправку';

  @override
  String get chatLocationServiceNotEnabled => 'Служба геолокации не включена';

  @override
  String get chatEnableLocationService =>
      'Пожалуйста, включите службу геолокации для использования этой функции';

  @override
  String get chatGoToSettings => 'Перейти в настройки';

  @override
  String get chatLocationPermissionRequired =>
      'Для этой функции требуется разрешение на определение местоположения';

  @override
  String get chatLocationPermissionDeniedPermanent =>
      'Разрешение на определение местоположения отклонено навсегда. Пожалуйста, включите его в настройках.';

  @override
  String get chatLocationPermissionDenied =>
      'Разрешение на определение местоположения отклонено';

  @override
  String get chatGettingLocation => 'Получение местоположения...';

  @override
  String chatGetLocationFailed(String error) {
    return 'Не удалось получить местоположение: $error';
  }

  @override
  String get chatMapPreview => 'Предпросмотр карты';

  @override
  String get chatSearchLocation => 'Поиск местоположения';

  @override
  String chatRedPacketSent(String amount, String token) {
    return 'Отправлен красный конверт на $amount $token';
  }

  @override
  String get chatTransferDefault => 'Перевод';

  @override
  String chatTransferSent(String amount, String token) {
    return 'Отправлен перевод на $amount $token';
  }

  @override
  String chatPickFileFailed(String error) {
    return 'Не удалось выбрать файл: $error';
  }

  @override
  String get chatFileSizeLimit => 'Размер файла не может превышать 50 МБ';

  @override
  String chatFileSending(String filename) {
    return 'Отправка файла: $filename';
  }

  @override
  String chatSendFileFailed(String error) {
    return 'Не удалось отправить файл: $error';
  }

  @override
  String chatContactCardSent(String name) {
    return 'Отправлена контактная карточка $name';
  }

  @override
  String get chatFavoritesFeature => 'Избранное';

  @override
  String get chatCouponsFeature => 'Купоны';

  @override
  String get chatGiftFeature => 'Подарок';

  @override
  String chatSharedMusic(String name) {
    return 'Поделился $name';
  }

  @override
  String get chatEndPollTitle => 'Завершить опрос';

  @override
  String get chatEndPollConfirmMessage =>
      'Вы уверены, что хотите завершить этот опрос? После завершения голосование будет закрыто.';

  @override
  String get chatPollEndedMessage => 'Опрос завершён';

  @override
  String get chatConnectingCall => 'Подключение...';

  @override
  String get chatMuteCall => 'Без звука';

  @override
  String get chatSpeakerOff => 'Динамик выкл';

  @override
  String get chatSpeakerOn => 'Динамик';

  @override
  String get chatCameraOn => 'Камера вкл';

  @override
  String get chatCameraOff => 'Камера выкл';

  @override
  String get chatHangUp => 'Завершить';

  @override
  String get chatSelectForwardTargetTitle => 'Выбрать получателя';

  @override
  String get chatNoForwardableChat => 'Нет доступных чатов для пересылки';

  @override
  String get chatNoMatchingChat => 'Подходящие чаты не найдены';

  @override
  String get chatLocationTitle => 'Местоположение';

  @override
  String get chatSendButton => 'Отправить';

  @override
  String get chatRetryButton => 'Повторить';

  @override
  String get chatSearchContactHint => 'Поиск контактов';

  @override
  String get chatShareMusic => 'Поделиться музыкой';

  @override
  String get chatRecentPlayed => 'Недавние';

  @override
  String get chatMyFavorites => 'Избранное';

  @override
  String get chatNetworkLink => 'Ссылка';

  @override
  String get chatLocalFile => 'Локальный';

  @override
  String get chatPasteMusicLink => 'Вставьте ссылку на музыку';

  @override
  String get chatShareMusicButton => 'Поделиться музыкой';

  @override
  String get chatSelectLocalAudio => 'Выбрать локальный аудиофайл';

  @override
  String get chatSupportedAudioFormats =>
      'Поддерживаются MP3, M4A, WAV, FLAC и др.';

  @override
  String get chatSelectFileButton => 'Выбрать файл';

  @override
  String get chatPleaseEnterMusicLink => 'Пожалуйста, введите ссылку на музыку';

  @override
  String get chatPleaseEnterValidLink =>
      'Пожалуйста, введите действительный URL';

  @override
  String get chatSharedSong => 'Поделился песней';

  @override
  String get chatSelectMember => 'Выбрать участника';

  @override
  String get chatSearchMemberHint => 'Поиск участников';

  @override
  String get chatNoMatchingMembers => 'Подходящие участники не найдены';

  @override
  String get commonUnknownMember => 'Неизвестно';

  @override
  String chatSelectedMessagesCount(int count) {
    return 'Выбрано $count сообщений';
  }

  @override
  String get chatSearchContactsOrGroups => 'Поиск контактов или групп';

  @override
  String get chatVideoTitle => 'Видео';

  @override
  String get chatLoadingText => 'Загрузка...';

  @override
  String get chatVideoLoadFailed => 'Ошибка загрузки видео';

  @override
  String get chatPlayerInitFailed => 'Ошибка инициализации плеера';

  @override
  String get chatCreatePollTitle => 'Создать опрос';

  @override
  String get chatSubmitPoll => 'Отправить';

  @override
  String get chatPollQuestionLabel => 'Вопрос опроса';

  @override
  String get chatEnterPollQuestionHint => 'Пожалуйста, введите вопрос опроса';

  @override
  String get chatPollOptionsLabel => 'Варианты ответа';

  @override
  String chatOptionHintWithIndex(int index) {
    return 'Вариант $index';
  }

  @override
  String get chatAddOptionButton => 'Добавить вариант';

  @override
  String get chatPollSettingsLabel => 'Настройки опроса';

  @override
  String get chatSelectionType => 'Тип выбора';

  @override
  String get chatSingleChoiceLabel => 'Один';

  @override
  String get chatMultiChoiceLabel => 'Несколько';

  @override
  String get chatAnonymousPollSwitch => 'Анонимный опрос';

  @override
  String get chatPleaseEnterQuestion => 'Пожалуйста, введите вопрос опроса';

  @override
  String get chatAtLeastTwoOptions => 'Требуется минимум 2 варианта';

  @override
  String chatConfirmWithCount(int count) {
    return 'Подтвердить ($count)';
  }

  @override
  String get authEmailVerificationTitle => 'Подтверждение email';

  @override
  String get authEnterValidEmailAddress =>
      'Пожалуйста, введите действительный email адрес';

  @override
  String authVerificationCodeSentTo(String email) {
    return 'Код подтверждения отправлен на $email';
  }

  @override
  String authSendCodeFailed(String error) {
    return 'Не удалось отправить код: $error';
  }

  @override
  String get authVerificationSuccess => 'Проверка успешна';

  @override
  String get authVerificationFailed => 'Проверка не удалась';

  @override
  String authVerificationCodeError(String error) {
    return 'Ошибка кода подтверждения: $error';
  }

  @override
  String get commonEnterVerificationCode => 'Введите код подтверждения';

  @override
  String get authEnterYourEmail => 'Введите email';

  @override
  String authWeSentCodeTo(String email) {
    return 'Мы отправили 6-значный код на\n$email';
  }

  @override
  String get authEnterEmailForCode =>
      'Введите ваш email адрес, мы отправим код подтверждения';

  @override
  String get commonSendVerificationCode => 'Отправить код подтверждения';

  @override
  String get authResendVerificationCode => 'Отправить код повторно';

  @override
  String authCanResendAfter(int seconds) {
    return 'Повторная отправка через $seconds секунд';
  }

  @override
  String get commonChangeEmail => 'Изменить email';

  @override
  String get contactAddToContacts => 'Добавить в контакты';

  @override
  String get contactAddingToContacts => 'Добавление...';

  @override
  String get contactAddedToContacts => 'Добавлено в контакты';

  @override
  String contactAddFailedWithError(String error) {
    return 'Ошибка добавления: $error';
  }

  @override
  String get contactAddPhone => 'Добавить телефон';

  @override
  String get contactAddTag => 'Добавить теги';

  @override
  String get contactAddText => 'Добавить текст';

  @override
  String get contactAddPhoto => 'Добавить фото';

  @override
  String contactGroupCountLabel(int count) {
    return '$count групп';
  }

  @override
  String get contactAddedViaSearch => 'Добавлен через поиск';

  @override
  String get contactAddTime => 'Добавить время';

  @override
  String get contactDoneButton => 'Готово';

  @override
  String get callWaitingForParticipants =>
      'Ожидание присоединения участников...';

  @override
  String callParticipantMe(String name) {
    return '$name (Я)';
  }

  @override
  String get callSharingLabel => 'Отправка';

  @override
  String callScreenSharingBy(String name) {
    return '$name делится экраном';
  }

  @override
  String callParticipantCount(int count) {
    return '$count участников';
  }

  @override
  String get callMuteLabel => 'Без звука';

  @override
  String get callUnmuteLabel => 'Со звуком';

  @override
  String get callTurnOffVideo => 'Выключить видео';

  @override
  String get callTurnOnVideo => 'Включить видео';

  @override
  String get callShareScreen => 'Поделиться экраном';

  @override
  String get callStopSharing => 'Прекратить отправку';

  @override
  String get callSwitchCameraLabel => 'Переключить';

  @override
  String get callLeaveLabel => 'Покинуть';

  @override
  String get callParticipantsLabel => 'Участники';

  @override
  String get callJoiningMeeting => 'Присоединение к конференции...';

  @override
  String chatPollVotesFormat(int count, String percentage) {
    return '$count голосов ($percentage%)';
  }

  @override
  String chatPollParticipantsFormat(int count) {
    return '$count участников';
  }

  @override
  String get commonTapToRetry => 'Нажмите, чтобы повторить';

  @override
  String get chatDefaultRedPacketGreeting => 'Желаю процветания и удачи';

  @override
  String get groupAllowOthersToSearchAndJoin =>
      'Разрешить другим пользователям искать и присоединяться';

  @override
  String get groupConfirmClearChatHistory =>
      'Вы уверены, что хотите очистить историю чата?';

  @override
  String get groupCreateGroupToChat => 'Создайте группу, чтобы начать общение';

  @override
  String get groupEditGroupAnnouncement => 'Редактировать объявление группы';

  @override
  String get groupEditGroupDescription => 'Редактировать описание группы';

  @override
  String get groupEnterGroupAnnouncement => 'Введите объявление группы';

  @override
  String chatErrorWithMessage(String message) {
    return 'Ошибка: $message';
  }

  @override
  String groupMemberCountClickToCopy(int count) {
    return '$count участников, нажмите для копирования ID группы';
  }

  @override
  String get chatMusicLinkLabel => 'Ссылка на музыку';

  @override
  String get chatNoMediaUrlAvailable => 'URL медиа недоступен';

  @override
  String get groupNoPermissionToEditGroupName =>
      'У вас нет прав для изменения названия группы';

  @override
  String get chatRedPacketTransferCannotForward =>
      'Красные конверты и переводы нельзя пересылать';

  @override
  String get authEmailAddress => 'Адрес электронной почты';

  @override
  String get commonEnterEmailAddress => 'Введите адрес электронной почты';

  @override
  String get authEmailRecoveryHint => 'Используется для восстановления пароля';

  @override
  String get commonInvalidEmailFormat =>
      'Введите действительный адрес электронной почты';

  @override
  String get authOptional => 'Необязательно';

  @override
  String get authResetPassword => 'Сбросить пароль';

  @override
  String get authEnterRegisteredEmail =>
      'Введите адрес электронной почты, с которым вы зарегистрировались';

  @override
  String get authSendResetCode => 'Отправить код сброса';

  @override
  String authResetCodeSent(String email) {
    return 'Код сброса отправлен на $email';
  }

  @override
  String get authEnterResetCode => 'Введите код сброса';

  @override
  String get authSetNewPassword => 'Установить новый пароль';

  @override
  String get commonConfirmNewPassword => 'Подтвердите новый пароль';

  @override
  String get commonNewPassword => 'Новый пароль';

  @override
  String get authPasswordResetSuccess =>
      'Пароль успешно сброшен. Войдите с новым паролем.';

  @override
  String get authResetPasswordFailed => 'Не удалось сбросить пароль';

  @override
  String get settingsChangePassword => 'Изменить пароль';

  @override
  String get settingsCurrentPassword => 'Текущий пароль';

  @override
  String get settingsEnterCurrentPassword => 'Введите текущий пароль';

  @override
  String get settingsEnterNewPassword => 'Введите новый пароль';

  @override
  String get settingsPasswordChanged =>
      'Пароль успешно изменен. Войдите с новым паролем.';

  @override
  String get settingsChangePasswordFailed => 'Не удалось изменить пароль';

  @override
  String get settingsNewPasswordMustBeDifferent =>
      'Новый пароль должен отличаться от текущего';

  @override
  String get settingsChangePasswordInfo =>
      'После изменения пароля вы будете отключены и должны будете войти с новым паролем.';

  @override
  String get settingsPasswordRequirements => 'Требования к паролю:';

  @override
  String get settingsSecurityNote =>
      'В целях безопасности вам нужно будет войти заново на всех устройствах после изменения пароля.';

  @override
  String get settingsSecurity => 'Безопасность';

  @override
  String get settingsCurrentBoundEmail => 'Текущий привязанный email';

  @override
  String get settingsNewEmailAddress => 'Новый адрес электронной почты';

  @override
  String get settingsEnterNewEmail => 'Введите новый адрес электронной почты';

  @override
  String get settingsVerificationCode => 'Код подтверждения';

  @override
  String get settingsVerificationCodeSent => 'Код подтверждения отправлен';

  @override
  String get settingsCodeSentTo => 'Код подтверждения отправлен на';

  @override
  String get settingsDidNotReceiveCode => 'Не получили код?';

  @override
  String get settingsEmailChangedSuccess => 'Email успешно изменен';

  @override
  String get settingsChangeEmailFailed => 'Не удалось изменить email';

  @override
  String get settingsEmailSecurityNote =>
      'Ваш email используется для восстановления пароля. Храните его в безопасности.';

  @override
  String get commonGoogleLogin => 'Войти через Google';

  @override
  String get commonAppleLogin => 'Войти через Apple';

  @override
  String get commonWechat => 'Вичат';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageChanged => 'Язык изменен';

  @override
  String get settingsTranslation => 'Перевод';

  @override
  String get settingsTranslateTextTo => 'Перевести текст на';

  @override
  String get settingsTranslateDescription =>
      'Выберите язык, на который вы хотите переводить сообщения.';

  @override
  String get settingsAutoTranslate =>
      'Автоматический перевод полученных сообщений';

  @override
  String get settingsAutoTranslateDescription =>
      'Автоматически переводите сообщения, полученные в чате, на выбранный вами язык.';

  @override
  String get settingsBiometricLogin => 'Биометрический вход';

  @override
  String authLoginWithBiometric(Object type) {
    return 'Войти с помощью $type';
  }

  @override
  String get settingsBiometricLoginEnabled => 'Биометрический вход включён';

  @override
  String get settingsBiometricLoginDisabled => 'Биометрический вход отключён';

  @override
  String get settingsEnableBiometricLogin => 'Включить биометрический вход';

  @override
  String get settingsBiometricEnabled => 'Включено — вход по биометрии';

  @override
  String get settingsBiometricDisabled => 'Отключено — нажмите для включения';

  @override
  String get settingsBiometricNeedRelogin =>
      'Выйдите и войдите снова, чтобы включить биометрический вход';

  @override
  String get authOr => 'ИЛИ';

  @override
  String get qrcodeCameraPermissionRestricted =>
      'Доступ к камере ограничен на этом устройстве';

  @override
  String get authPasskeyLabel => 'Ключ доступа';

  @override
  String get authGoogleLabel => 'Гугл';

  @override
  String get authAppleLabel => 'Яблоко';


  @override
  String get authSsoNotConfigured => 'Этот сервер не настроил провайдеров входа SSO';
  @override
  String get authSsoLabel => 'система единого входа';

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
      'Введите суффикс тычка, например: в плечо';

  @override
  String get groupAlbum => 'Альбом группы';

  @override
  String get groupFiles => 'Файлы группы';

  @override
  String get groupImages => 'Изображения';

  @override
  String get groupVideos => 'Видео';

  @override
  String get groupTotal => 'Всего';

  @override
  String get groupSize => 'Размер';

  @override
  String get groupNoMedia => 'Нет медиа';

  @override
  String get groupNoMediaDescription => 'В этой группе пока нет фото или видео';

  @override
  String get groupDocuments => 'Документы';

  @override
  String get groupNoFiles => 'Нет файлов';

  @override
  String get groupNoFilesDescription => 'В этой группе пока нет файлов';

  @override
  String groupDownloadStarted(String filename) {
    return 'Загрузка $filename...';
  }

  @override
  String get contactNoCommonGroups => 'Нет общих групп';

  @override
  String get contactNoCommonGroupsDescription => 'У вас нет общих групп';

  @override
  String get chatVoiceMessage => 'Голос';

  @override
  String get chatMessage => 'Сообщение';

  @override
  String get conversationHideChat => 'Скрыть';

  @override
  String get settingsQuickReply => 'Быстрый ответ';

  @override
  String get commonTranslate => 'Перевести';

  @override
  String get contactCreateTag => 'Создать тег';

  @override
  String get contactEnterTagName => 'Введите имя тега';

  @override
  String get contactEditTag => 'Изменить тег';

  @override
  String get contactDeleteTag => 'Удалить тег';

  @override
  String contactDeleteTagConfirm(String tagName) {
    return 'Вы уверены, что хотите удалить тег «$tagName»?';
  }

  @override
  String get contactNoTags => 'Тегов пока нет';

  @override
  String get contactFriendPermissions => 'Разрешения для друзей';

  @override
  String get contactSetChatOnly => 'Установить только для чата';

  @override
  String get contactChatOnlyDesc =>
      'Могу общаться только с вами, остальной контент будет скрыт';

  @override
  String get contactHideMyMoments => 'Скрыть мои моменты';

  @override
  String get contactHideMyMomentsDesc =>
      'Этот друг не может видеть мои моменты';

  @override
  String get contactHideTheirMoments => 'Скрыть их моменты';

  @override
  String get contactHideTheirMomentsDesc => 'Не видеть моменты этого друга';

  @override
  String get contactHideMyStatus => 'Скрыть мой статус';

  @override
  String get contactHideMyStatusDesc =>
      'Этот друг не может видеть обновления моего статуса';

  @override
  String get contactNoChatOnlyFriends => 'Нет друзей, которые только в чате';

  @override
  String get contactNoOfficialAccounts => 'Нет официальных аккаунтов';

  @override
  String get contactFollowOfficialAccountsDesc =>
      'Подписывайтесь на официальные аккаунты, чтобы получать последние обновления.';

  @override
  String get contactNoServiceAccounts => 'Нет сервисных аккаунтов';

  @override
  String get contactSubscribeServiceAccountsDesc =>
      'Подпишитесь на сервисные аккаунты для получения удобных сервисов';

  @override
  String get contactNoEnterpriseContacts => 'Нет контактов предприятия';

  @override
  String get contactEnterpriseContactsDesc =>
      'Здесь будут отображаться корпоративные контакты';

  @override
  String get profileCardPack => 'Пакет карт';

  @override
  String get profileOrders => 'Заказы';

  @override
  String get profileNoOrders => 'Нет заказов';

  @override
  String get profileOrdersDesc => 'Здесь будут отображаться ваши заказы';

  @override
  String get profileNoCards => 'Нет карт';

  @override
  String get profileCardsDesc => 'Здесь будут отображаться ваши карты';

  @override
  String get favoriteEnterTagsHint => 'Введите теги через запятую';

  @override
  String get favoriteTagsUpdated => 'Теги обновлены';

  @override
  String get favoriteForwardedContent => 'Контент переслан';

  @override
  String get favoriteEnterNoteContent => 'Введите содержание заметки';

  @override
  String get favoriteNoteAdded => 'Примечание добавлено';

  @override
  String get favoriteLinkTitle => 'Название ссылки';

  @override
  String get favoriteLinkUrl => 'https://';

  @override
  String get favoriteLinkAdded => 'Ссылка добавлена';

  @override
  String get contactPhotoAdded => 'Фото добавлено';

  @override
  String get contactEnterPhone => 'Введите номер телефона';

  @override
  String commonConversationWithId(String roomId) {
    return 'Разговор: $roomId';
  }

  @override
  String commonContactWithId(String userId) {
    return 'Контакт: $userId';
  }

  @override
  String get commonDiscover => 'Обзор';

  @override
  String commonDeveloping(String title) {
    return '$title\n(Скоро)';
  }

  @override
  String get commonPageNotFound => 'Страница не найдена';

  @override
  String get commonBackToHome => 'На главную';

  @override
  String get settingsMessageNotifications => 'Уведомления о сообщениях';

  @override
  String get settingsReceiveNewMessageNotifications =>
      'Получать уведомления о новых сообщениях';

  @override
  String get settingsShowMessagePreview => 'Показывать предпросмотр сообщения';

  @override
  String get settingsShowMessageContentInNotification =>
      'Показывать содержимое сообщения в уведомлениях';

  @override
  String get settingsNotificationSound => 'Звук уведомления';

  @override
  String get settingsPlaySoundOnMessage =>
      'Воспроизводить звук при получении сообщения';

  @override
  String get commonVibration => 'Вибрация';

  @override
  String get settingsVibrateOnMessage => 'Вибрировать при получении сообщения';

  @override
  String get settingsDoNotDisturbMode => 'Не беспокоить';

  @override
  String get settingsDoNotDisturbDescription =>
      'Не получать уведомления в указанное время';

  @override
  String get settingsStartTime => 'Время начала';

  @override
  String get settingsEndTime => 'Время окончания';

  @override
  String get settingsDeleteQuickReply => 'Удалить быстрый ответ';

  @override
  String get settingsEditQuickReply => 'Редактировать быстрый ответ';

  @override
  String get settingsAddQuickReply => 'Добавить быстрый ответ';

  @override
  String get settingsManageQuickReplies => 'Управление быстрыми ответами';

  @override
  String get settingsNoQuickReplies => 'Нет быстрых ответов';

  @override
  String get settingsDefaultQuickReplies =>
      'Будут показаны быстрые ответы по умолчанию';

  @override
  String get settingsWhoCanSee => 'Кто может видеть';

  @override
  String get settingsLastSeen => 'Последний визит';

  @override
  String get settingsHiddenChats => 'Скрытые чаты';

  @override
  String get settingsMessagesLabel => 'Сообщения';

  @override
  String get settingsAllowStrangerMessages =>
      'Разрешить сообщения от незнакомцев';

  @override
  String get settingsReceiveMessagesFromNonContacts =>
      'Получать сообщения от тех, кого нет в контактах';

  @override
  String get settingsReadReceipts => 'Отчёты о прочтении';

  @override
  String get settingsLetOthersKnowYouRead =>
      'Показывать, что вы прочитали сообщения';

  @override
  String get settingsTypingIndicator => 'Индикатор набора';

  @override
  String get settingsLetOthersKnowYouTyping => 'Показывать, что вы печатаете';

  @override
  String get settingsEveryone => 'Все';

  @override
  String get settingsContactsOnly => 'Только контакты';

  @override
  String get settingsNobody => 'Никто';

  @override
  String settingsWhoCanSeeTitle(String title) {
    return 'Кто может видеть $title';
  }

  @override
  String settingsVersionInfo(String version) {
    return 'Версия $version';
  }

  @override
  String get settingsCheckForUpdates => 'Проверить обновления';

  @override
  String get settingsOpenSourceLicenses => 'Лицензии открытого ПО';

  @override
  String get settingsFeedbackAndSuggestions => 'Отзывы и предложения';

  @override
  String get settingsBuiltOnMatrix => 'На основе протокола Matrix';

  @override
  String get settingsNoHiddenChats => 'Нет скрытых чатов';

  @override
  String get settingsNoHiddenChatsDescription =>
      'Скрытые вами чаты будут отображаться здесь';

  @override
  String get settingsUnhideChat => 'Показать';

  @override
  String get settingsDarkMode => 'Тёмный режим';

  @override
  String get settingsFontSize => 'Размер шрифта';

  @override
  String get settingsBubbleStyle => 'Стиль пузырей';

  @override
  String get settingsFollowSystem => 'Следовать системе';

  @override
  String get settingsAutoSwitchBySystem =>
      'Автоматически переключаться по настройкам системы';

  @override
  String get settingsLightMode => 'Светлый режим';

  @override
  String get settingsAlwaysUseLightTheme => 'Всегда использовать светлую тему';

  @override
  String get settingsDarkModeOption => 'Тёмный режим';

  @override
  String get settingsAlwaysUseDarkTheme => 'Всегда использовать тёмную тему';

  @override
  String get settingsFontSizeSmall => 'Маленький';

  @override
  String get settingsFontSizeStandard => 'Стандартный';

  @override
  String get settingsFontSizeLarge => 'Большой';

  @override
  String get settingsFontSizeExtraLarge => 'Очень большой';

  @override
  String get settingsBubbleStyleWechat => 'Стиль WeChat';

  @override
  String get settingsBubbleStyleWechatDesc =>
      'Классический стиль пузырей WeChat';

  @override
  String get settingsBubbleStyleModern => 'Современный стиль';

  @override
  String get settingsBubbleStyleModernDesc =>
      'Чистый современный стиль пузырей';

  @override
  String get settingsBubbleStyleClassic => 'Классический стиль';

  @override
  String get settingsBubbleStyleClassicDesc => 'Традиционный стиль пузырей';

  @override
  String get discoverVideoChannels => 'Каналы';

  @override
  String get discoverLive => 'Прямой эфир';

  @override
  String get discoverListen => 'Слушать';

  @override
  String get discoverWatch => 'Смотреть';

  @override
  String get discoverSearchDiscover => 'Поиск';

  @override
  String get discoverNearbyPeople => 'Рядом';

  @override
  String get discoverGames => 'Игры';

  @override
  String get discoverMiniPrograms => 'Мини-программы';

  @override
  String get chatAlreadyInCall => 'Уже в вызове';

  @override
  String get commonConnectionFailed => 'Ошибка подключения';

  @override
  String get chatCallRejected => 'Вызов отклонён';

  @override
  String get chatNoAnswer => 'Нет ответа';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get chatSelectContact => 'Выбрать контакт';

  @override
  String get chatVoteRemoved => 'Голос удалён';

  @override
  String get chatVoteChanged => 'Голос изменён';

  @override
  String get chatVoted => 'Проголосовано';

  @override
  String chatReplyTo(String name) {
    return 'Ответ $name';
  }

  @override
  String get chatCurrentLocation => 'Текущее местоположение';

  @override
  String chatNearbyPlace(int index) {
    return 'Место поблизости $index';
  }

  @override
  String chatApproximateDistance(String distance) {
    return 'Примерно $distance';
  }

  @override
  String get chatAddress => 'Адрес';

  @override
  String get chatLatitude => 'Широта';

  @override
  String get chatLongitude => 'Долгота';

  @override
  String get groupDescriptionUpdated => 'Описание группы обновлено';

  @override
  String get groupAvatarUpdated => 'Аватар группы обновлен';

  @override
  String get groupVisibilityUpdated => 'Доступность группы обновлена.';

  @override
  String get groupChannelCreated => 'Канал создан';

  @override
  String get groupChannelUpdated => 'Канал обновлен';

  @override
  String get groupChannelDeleted => 'Канал удален';

  @override
  String get callDecline => 'Отклонить';

  @override
  String get callAnswer => 'Ответить';

  @override
  String get callIncomingVideoCall => 'Входящий видеозвонок';

  @override
  String get callIncomingVoiceCall => 'Входящий голосовой звонок';

  @override
  String get callVideoCallInProgress => 'Видеозвонок';

  @override
  String get callVoiceCallInProgress => 'Голосовой звонок';

  @override
  String get callReconnectingCall => 'Переподключение...';

  @override
  String get callEnded => 'Звонок завершён';

  @override
  String get callFailed => 'Звонок не удался';

  @override
  String get callLivekitNotConfigured => 'LiveKit не настроен';

  @override
  String callJoinMeetingFailed(String error) {
    return 'Не удалось присоединиться к конференции: $error';
  }

  @override
  String callScreenShareFailed(String error) {
    return 'Не удалось поделиться экраном: $error';
  }

  @override
  String get profileN42BeanTitle => 'N42 Фасоль';

  @override
  String get profileNoN42Bean => 'Нет N42 Bean';

  @override
  String get profileN42BeanDetails => 'Детали N42 Bean';

  @override
  String get profileN42BeanDescription =>
      'N42 Bean — токен для обмена на виртуальные предметы и услуги в N42. Сейчас доступно:';

  @override
  String get profileN42BeanFeature1 =>
      'Эксклюзивные стикеры и темы для участников';

  @override
  String get profileN42BeanFeature2 => 'Настройка пузырей чата';

  @override
  String get profileN42BeanFeature3 => 'Настройка обложек красных конвертов';

  @override
  String get profileN42BeanFeature4 => 'Эксклюзивный значок никнейма';

  @override
  String get profileN42BeanFeature5 => 'Привилегии группового чата';

  @override
  String get profileN42BeanFeature6 => 'Расширение облачного хранилища';

  @override
  String get profileN42BeanFeature7 => 'Фильтры красоты для видеозвонков';

  @override
  String get profileN42BeanFeature8 => 'Настройка фона Moments';

  @override
  String get profileN42BeanFeature9 => 'Приоритет VIP-обслуживания';

  @override
  String get profileGotIt => 'Понятно';

  @override
  String get profileNoN42BeanRecords => 'Нет записей N42 Bean';

  @override
  String get profileMoodAndThoughts => 'Настроение и мысли';

  @override
  String get profileStatusHappy => 'Счастлив';

  @override
  String get profileStatusCracked => 'Разбит';

  @override
  String get profileStatusLucky => 'Везучий';

  @override
  String get profileStatusSunny => 'Солнечный';

  @override
  String get profileStatusTired => 'Усталый';

  @override
  String get profileStatusDaydream => 'Мечтаю';

  @override
  String get profileStatusRushing => 'Спешу';

  @override
  String get profileStatusOverthinking => 'Задумался';

  @override
  String get profileStatusEnergized => 'Энергичный';

  @override
  String get profileWorkAndStudy => 'Работа и учёба';

  @override
  String get profileStatusWorking => 'Работаю';

  @override
  String get profileStatusStudying => 'Учусь';

  @override
  String get profileStatusBusy => 'Занят';

  @override
  String get profileStatusSlacking => 'Ленюсь';

  @override
  String get profileStatusTraveling => 'Путешествую';

  @override
  String get profileStatusGoingHome => 'Иду домой';

  @override
  String get profileStatusDnd => 'Не беспокоить';

  @override
  String get profileActivities => 'Активность';

  @override
  String get profileStatusHanging => 'Отдыхаю';

  @override
  String get profileStatusCheckIn => 'Отметка';

  @override
  String get profileStatusExercising => 'Тренируюсь';

  @override
  String get profileStatusCoffee => 'Кофе';

  @override
  String get profileStatusBubbleTea => 'Чай с пузырьками';

  @override
  String get profileStatusEating => 'Ем';

  @override
  String get profileStatusParenting => 'С детьми';

  @override
  String get profileStatusSavingWorld => 'Спасаю мир';

  @override
  String get profileStatusSelfie => 'Селфи';

  @override
  String get profileRest => 'Отдых';

  @override
  String get profileStatusRetreat => 'Уединение';

  @override
  String get profileStatusHome => 'Дома';

  @override
  String get profileStatusSleeping => 'Сплю';

  @override
  String get profileStatusCatLover => 'Люблю кошек';

  @override
  String get profileStatusDogWalking => 'Гуляю с собакой';

  @override
  String get profileStatusGaming => 'Играю';

  @override
  String get profileStatusListening => 'Слушаю музыку';

  @override
  String get profileEditAddress => 'Редактировать адрес';

  @override
  String get profileRecipient => 'Получатель';

  @override
  String get profileEnterRecipientName => 'Введите имя получателя';

  @override
  String get profilePhoneNumber => 'Номер телефона';

  @override
  String get profileEnterPhoneNumber => 'Введите номер телефона';

  @override
  String get profileRegionHint => 'Область/Город/Район';

  @override
  String get profileDetailedAddress => 'Подробный адрес';

  @override
  String get profileDetailedAddressHint => 'Улица, номер дома и т.д.';

  @override
  String get profileSetAsDefaultAddress => 'Установить как адрес по умолчанию';

  @override
  String get profilePleaseCompleteInfo => 'Пожалуйста, заполните все поля';

  @override
  String get profileEditInvoice => 'Редактировать счёт';

  @override
  String get profileInvoiceType => 'Тип счёта: ';

  @override
  String get profileCompanyName => 'Название компании';

  @override
  String get profilePersonalName => 'Имя';

  @override
  String get profileEnterCompanyName => 'Введите название компании';

  @override
  String get profileEnterName => 'Введите имя';

  @override
  String get profileTaxIdNumber => 'ИНН';

  @override
  String get profileEnterTaxIdNumber => 'Введите ИНН';

  @override
  String get profileBankNameOptional => 'Название банка (необязательно)';

  @override
  String get profileEnterBankName => 'Введите название банка';

  @override
  String get profileBankAccountOptional => 'Номер счёта (необязательно)';

  @override
  String get profileEnterBankAccount => 'Введите номер счёта';

  @override
  String get profileCompanyAddressOptional => 'Адрес компании (необязательно)';

  @override
  String get profileEnterCompanyAddress => 'Введите адрес компании';

  @override
  String get profileCompanyPhoneOptional => 'Телефон компании (необязательно)';

  @override
  String get profileEnterCompanyPhone => 'Введите телефон компании';

  @override
  String get profileSetAsDefaultInvoice => 'Установить как счёт по умолчанию';

  @override
  String get profileRingtoneVibrate => 'Вибрация';

  @override
  String get profileRingtoneSilent => 'Беззвучный';

  @override
  String get profileVibrateMode => 'Режим вибрации';

  @override
  String get profileSilentMode => 'Беззвучный режим';

  @override
  String profilePlayFailed(String ringtoneName) {
    return 'Ошибка воспроизведения: $ringtoneName';
  }

  @override
  String profilePlaying(String ringtoneName) {
    return 'Воспроизведение: $ringtoneName';
  }

  @override
  String get profileStop => 'Стоп';

  @override
  String get profileSelectRingtone => 'Выбрать рингтон';

  @override
  String get profileLoadingRingtones => 'Загрузка рингтонов...';

  @override
  String get profileNoRingtonesFound => 'Рингтоны не найдены';

  @override
  String mainMessagesWithCount(int count) {
    return 'Сообщения($count)';
  }

  @override
  String get storyViewers => 'Зрители';

  @override
  String get storyNoViewers => 'Пока нет зрителей';

  @override
  String get storyReplyToStory => 'Ответить на историю...';

  @override
  String get commonCopiedToClipboard => 'Скопировано в буфер обмена';

  @override
  String get commonMore => 'Ещё';

  @override
  String get commonTranslating => 'Перевод...';

  @override
  String commonTranslatedFrom(String language) {
    return 'Переведено с $language';
  }

  @override
  String get commonTranslation => 'Перевод';

  @override
  String get commonTranslationFailed => 'Ошибка перевода';

  @override
  String get commonAllRead => 'Все прочитаны';

  @override
  String commonReadCount(int count) {
    return '$count прочитано';
  }

  @override
  String get commonYouRecalledMessage => 'Вы отозвали сообщение';

  @override
  String get commonMessageRecalled => 'Сообщение отозвано';

  @override
  String get commonReEdit => 'Редактировать';

  @override
  String get commonWalletArea => 'Область кошелька';

  @override
  String get callIncomingCall => 'Входящий вызов';

  @override
  String get callMissedCall => 'Пропущенный вызов';

  @override
  String get groupRemoveAdmin => 'Снять права администратора';

  @override
  String get chatSelectCurrency => 'Выбрать валюту';

  @override
  String get chatSelectEmoji => 'Выбрать эмодзи';

  @override
  String get chatSelectRedPacketCover => 'Выбрать обложку';

  @override
  String get groupSetAsAdmin => 'Назначить администратором';

  @override
  String get chatVideoPlaybackFailed => 'Ошибка воспроизведения видео';

  @override
  String get groupViewProfile => 'Просмотреть профиль';

  @override
  String get favoriteAddLinkComingSoon => 'Добавление ссылок скоро появится';

  @override
  String get favoriteNewNoteComingSoon => 'Новые заметки скоро появятся';

  @override
  String get qrcodeSaveFeatureComingSoon => 'Функция сохранения скоро появится';

  @override
  String get qrcodeShareFeatureComingSoon => 'Функция отправки скоро появится';

  @override
  String qrcodeProcessFailed(String error) {
    return 'Не удалось обработать QR-код: $error';
  }

  @override
  String get securityDeviceIdRequired => 'Требуется идентификатор устройства.';

  @override
  String securityVerificationStartFailed(String error) {
    return 'Не удалось начать проверку: $error.';
  }

  @override
  String get securityVerificationFailed => 'Проверка не удалась';

  @override
  String securityVerificationFailedWithReason(String reason) {
    return 'Проверка не удалась: $reason.';
  }

  @override
  String get securityEmojiMismatchRejected =>
      'Проверка отклонена: смайлы не совпадают.';

  @override
  String get securityWaitingForDeviceAccept =>
      'Ожидание, пока другое устройство примет...';

  @override
  String get securityVerifyDevice => 'Подтвердить это устройство';

  @override
  String get securityConfirmEmojiMatch =>
      'Убедитесь, что приведенные ниже смайлы отображаются на обоих устройствах в одинаковом порядке.';

  @override
  String get securityEmojiDontMatch => 'Они не совпадают';

  @override
  String get securityEmojiMatch => 'Они соответствуют';

  @override
  String get securityWaitingForDeviceConfirm =>
      'Ожидание подтверждения от другого устройства...';

  @override
  String get securityVerificationSuccess => 'Проверка прошла успешно!';

  @override
  String get securityDeviceVerifiedTrusted =>
      'Теперь это устройство проверено и ему доверяют.';

  @override
  String get securityCompareEmoji => 'Сравните смайлы на обоих устройствах';

  @override
  String get securityCompareNumbers => 'Сравните цифры на обоих устройствах';

  @override
  String get commonTryAgain => 'Попробуйте еще раз';

  @override
  String get commonDone => 'Готово';

  @override
  String get chatExportTitle => 'Экспортировать чат';

  @override
  String get chatExportSuccess => 'Экспорт выполнен успешно';

  @override
  String chatExportFailed(String error) {
    return 'Не удалось экспортировать: $error.';
  }

  @override
  String get chatExportFormat => 'Формат экспорта';

  @override
  String get chatExportHtmlDesc =>
      'Читается в любом браузере со стилизованным макетом.';

  @override
  String get chatExportJsonDesc =>
      'Машиночитаемый формат структурированных данных.';

  @override
  String get chatExportDateRange => 'Диапазон дат';

  @override
  String get chatExportAll => 'Все сообщения';

  @override
  String get chatExportLastWeek => 'Последние 7 дней';

  @override
  String get chatExportLastMonth => 'В прошлом месяце';

  @override
  String get chatExportLast3Months => 'Последние 3 месяца';

  @override
  String get chatExportMessageCount => 'Сообщения для экспорта';

  @override
  String get chatExportButton => 'Экспорт и обмен';

  @override
  String get chatMediaGallery => 'Медиа-галерея';

  @override
  String get chatExportHistory => 'Экспорт истории чата';

  @override
  String get pdfLoadFailed => 'Не удалось загрузить PDF-файл.';

  @override
  String pdfPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get mediaAll => 'Все';

  @override
  String get mediaImages => 'Изображения';

  @override
  String get mediaVideos => 'Видео';

  @override
  String get mediaFiles => 'Файлы';

  @override
  String get mediaAudio => 'Аудио';

  @override
  String mediaItemsCount(int count) {
    return '$count элементы';
  }

  @override
  String get mediaNoMediaFound => 'Носители не найдены';

  @override
  String get spacesTitle => 'Сообщества';

  @override
  String get spacesCreate => 'Создать сообщество';

  @override
  String get spacesJoined => 'Присоединился';

  @override
  String get spacesDiscover => 'Откройте для себя';

  @override
  String get spacesNoJoined => 'Ни одно сообщество еще не присоединилось';

  @override
  String get spacesExplore => 'Исследуйте сообщества';

  @override
  String get spacesNoPublic => 'Публичные сообщества не найдены';

  @override
  String get spacesJoin => 'Присоединяйтесь';

  @override
  String get spacesSubSpaces => 'Подсообщества';

  @override
  String get spacesChannels => 'Каналы';

  @override
  String spacesMembersCount(int count) {
    return 'Участники $count';
  }

  @override
  String get spacesPublic => 'Общественный';

  @override
  String get spacesPrivate => 'Частный';

  @override
  String get spacesSuggested => 'Предлагается';

  @override
  String spacesChannelsCount(int count) {
    return 'Каналы $count';
  }

  @override
  String get callInCallChat => 'Чат во время разговора';

  @override
  String callMessagesCount(int count) {
    return 'Сообщения $count';
  }

  @override
  String get callNoMessagesYet =>
      'Сообщений пока нет.\nОтправьте сообщение, чтобы начать.';

  @override
  String get callTypeMessage => 'Введите сообщение...';

  @override
  String get callYouSender => 'ты';

  @override
  String get callChatLabel => 'Чат';

  @override
  String get chatEdited => 'Отредактировано';

  @override
  String get chatEditHistory => 'Редактировать историю';

  @override
  String get chatOriginalMessage => 'Оригинал';

  @override
  String chatEditedAt(String time) {
    return 'Отредактировано $time.';
  }

  @override
  String get chatViewOnce => 'Посмотреть один раз';

  @override
  String get chatViewOncePhoto => 'Посмотреть один раз фото';

  @override
  String get chatViewOnceVideo => 'Посмотреть видео один раз';

  @override
  String get chatViewOnceViewed => 'Просмотрено';

  @override
  String get chatViewOnceExpired => 'Срок действия истек';

  @override
  String get chatViewOnceTap => 'Нажмите, чтобы просмотреть';

  @override
  String get chatAutoFaceBlur => 'Автоматическое размытие лица';

  @override
  String get chatAutoFaceBlurDesc =>
      'Автоматически размывать лица при отправке фотографий';

  @override
  String get threadReplyInThread => 'Ответить в теме';

  @override
  String threadReplies(int count) {
    return '$count ответы';
  }

  @override
  String get threadReply => '1 ответ';

  @override
  String threadLatestReply(String preview) {
    return 'Последний: $preview';
  }

  @override
  String get threadTitle => 'Тема';

  @override
  String get threadReplyPlaceholder => 'Ответ в теме...';

  @override
  String threadParticipants(int count) {
    return '$count участники';
  }

  @override
  String get voiceRoomTitle => 'Голосовая комната';

  @override
  String get voiceRoomCreate => 'Создать голосовую комнату';

  @override
  String get voiceRoomJoin => 'Присоединяйтесь';

  @override
  String get voiceRoomLeave => 'Уйти';

  @override
  String get voiceRoomEnd => 'Конечная комната';

  @override
  String get voiceRoomRaiseHand => 'Поднять руку';

  @override
  String get voiceRoomLowerHand => 'Нижняя рука';

  @override
  String get voiceRoomMute => 'Отключить звук';

  @override
  String get voiceRoomUnmute => 'Включить звук';

  @override
  String get voiceRoomHost => 'Хост';

  @override
  String get voiceRoomSpeakers => 'Спикеры';

  @override
  String get voiceRoomListeners => 'Слушатели';

  @override
  String get voiceRoomLive => 'ЖИТЬ';

  @override
  String get voiceRoomEnded => 'Закончено';

  @override
  String get voiceRoomScheduled => 'Запланировано';

  @override
  String get voiceRoomApprove => 'Утвердить';

  @override
  String get voiceRoomDemote => 'Перейти к прослушивателю';

  @override
  String voiceRoomHandRaised(String name) {
    return '$name подняли руку';
  }

  @override
  String get voiceRoomName => 'Название комнаты';

  @override
  String get voiceRoomTopic => 'Тема (необязательно)';

  @override
  String get voiceRoomNoActive => 'Нет активных голосовых комнат';

  @override
  String get voiceRoomConnecting => 'Подключение...';

  @override
  String get usernameTitle => 'Имя пользователя';

  @override
  String get usernameSet => 'Установить имя пользователя';

  @override
  String get usernameChange => 'Изменить имя пользователя';

  @override
  String get usernamePlaceholder => 'Введите имя пользователя';

  @override
  String get usernameAvailable => 'Имя пользователя доступно';

  @override
  String get usernameUnavailable => 'Имя пользователя уже занято';

  @override
  String get usernameInvalid =>
      '3–30 символов, строчные буквы, цифры, подчеркивание. Должно начинаться с буквы.';

  @override
  String get usernameReserved => 'Это имя пользователя зарезервировано';

  @override
  String get usernameSaved => 'Имя пользователя сохранено';

  @override
  String get usernameSearchHint => 'Поиск по @username';

  @override
  String get ensName => 'Название ЭНС';

  @override
  String get ensLinked => 'Связано с ENS';

  @override
  String get ensResolving => 'Решение ENS...';

  @override
  String get ensNotFound => 'Название ENS не найдено';

  @override
  String get tokenGateTitle => 'Токен Ворота';

  @override
  String get tokenGateEnable => 'Включить токен-шлюз';

  @override
  String get tokenGateDisable => 'Отключить токен-гейт';

  @override
  String get tokenGateAddRule => 'Добавить правило';

  @override
  String get tokenGateRemoveRule => 'Удалить правило';

  @override
  String get tokenGateContractAddress => 'Адрес контракта';

  @override
  String get tokenGateMinBalance => 'Минимальный баланс';

  @override
  String get tokenGateTokenId => 'Идентификатор токена (ERC-1155)';

  @override
  String get tokenGateChainId => 'Идентификатор цепочки';

  @override
  String get tokenGateVerifying => 'Проверка наличия токенов...';

  @override
  String get tokenGateVerified => 'Проверка пройдена';

  @override
  String get tokenGateDenied => 'Вы не соответствуете требованиям токена';

  @override
  String get tokenGateOperatorAnd => 'Должен соответствовать ВСЕМ правилам';

  @override
  String get tokenGateOperatorOr => 'Должно соответствовать ЛЮБЫМ правилам';

  @override
  String get tokenGateRuleErc20 => 'Токен ERC-20';

  @override
  String get tokenGateRuleErc721 => 'НФТ (ERC-721)';

  @override
  String get tokenGateRuleErc1155 => 'Мультитокен (ERC-1155)';

  @override
  String get tokenGateRuleNative => 'Родной токен';

  @override
  String get tokenGateSaved => 'Токен-шлюз сохранен.';

  @override
  String get tokenGateEnableDescription =>
      'Требовать от участников иметь токены для присоединения';

  @override
  String get tokenGateOperator => 'Логика правил';

  @override
  String get tokenGateRules => 'Правила';

  @override
  String get tokenGateSymbol => 'Символ (необязательно)';

  @override
  String get tokenGateChain => 'Цепь';

  @override
  String get tokenGateTokenStandard => 'Стандарт токена';

  @override
  String get tokenGateDenialMessage => 'Сообщение об отказе';

  @override
  String get tokenGateDenialMessageHint =>
      'Сообщение, отображаемое при неудачной проверке';

  @override
  String get tokenGateVerifyTitle => 'Проверка токена';

  @override
  String get tokenGateVerifyPassed => 'Проверка пройдена';

  @override
  String get tokenGateVerifyFailed => 'Проверка не удалась';

  @override
  String get tokenGateRetryVerify => 'Повторить попытку';

  @override
  String get tokenGateRequired => 'Требуется';

  @override
  String get tokenGateYourBalance => 'Ваш баланс';

  @override
  String get tokenGateRulesActive => 'правила активны';

  @override
  String get tokenGateDisabled => 'Отключено';

  @override
  String get ensNotBound => 'Не связан';

  @override
  String get liveLocation => 'Живое местоположение';

  @override
  String get stopLiveLocation => 'Прекратить делиться';

  @override
  String get startLiveLocation => 'Начать делиться';

  @override
  String get selectDuration => 'Выберите продолжительность';

  @override
  String get groupChatFiles => 'Файлы чата';

  @override
  String get groupLinks => 'Ссылки';

  @override
  String get groupNoLinks => 'Ссылок пока нет';

  @override
  String get chatBackground => 'Фон чата';

  @override
  String get solidColors => 'Сплошные цвета';

  @override
  String get gradients => 'Градиенты';

  @override
  String get defaultBackground => 'По умолчанию';

  @override
  String get settingsFontSizeSlider => 'Размер шрифта';

  @override
  String get autoDownload => 'Автоматическая загрузка';

  @override
  String get images => 'Изображения';

  @override
  String get voice => 'Голос';

  @override
  String get video => 'Видео';

  @override
  String get files => 'Файлы';

  @override
  String get mobileData => 'Мобильные данные';

  @override
  String get roaming => 'Роуминг';

  @override
  String get storageManagement => 'Хранение';

  @override
  String get totalUsage => 'Общее использование';

  @override
  String get cache => 'Кэш';

  @override
  String get other => 'Другое';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get cacheCleared => 'Кэш очищен';

  @override
  String get clearCacheFailed => 'Не удалось очистить кэш';

  @override
  String get confirmClearCache => 'Очистить все данные кэша?';

  @override
  String get mapView => 'Просмотр карты';

  @override
  String liveLocationSharingCount(int count) {
    return '$count люди делятся своим местоположением';
  }

  @override
  String get minutes15 => '15 минут';

  @override
  String get minutes30 => '30 минут';

  @override
  String get hour1 => '1 час';

  @override
  String get hours8 => '8 часов';

  @override
  String get personalCard => 'Персональная карта';

  @override
  String get downloadFailed => 'Загрузка не удалась';

  @override
  String get locationExpired => 'Срок действия истек';

  @override
  String secondsRemaining(int count) {
    return '$count секунд';
  }

  @override
  String minutesRemaining(int count) {
    return '$countмин';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '${hours}h $minutesмин';
  }

  @override
  String get favoriteMessages => 'Избранное';

  @override
  String get linksCopied => 'Ссылка скопирована';

  @override
  String get noLinksFound => 'Ссылки не найдены';

  @override
  String get roomStorageRanking => 'Рейтинг мест хранения вещей';

  @override
  String get downloadComplete => 'Загрузка завершена';

  @override
  String get downloading => 'Загрузка...';

  @override
  String get draftSaved => 'Черновик сохранен.';

  @override
  String get voiceRecording => 'Запись голоса';

  @override
  String get searchLocation => 'Поиск местоположения';

  @override
  String get tapToSearch => 'Нажмите, чтобы найти';

  @override
  String get settingsThisDevice => 'Это устройство';

  @override
  String get settingsJustNow => 'только что';

  @override
  String get settingsDeviceId => 'Идентификатор устройства';

  @override
  String get settingsStatus => 'Статус';

  @override
  String get settingsLastActive => 'Последний активный';

  @override
  String get settingsIpAddress => 'IP-адрес';

  @override
  String get settingsRenameDevice => 'Переименовать устройство';

  @override
  String get settingsDeviceNameHint => 'Введите имя устройства';

  @override
  String get settingsDeviceRenamed => 'Устройство переименовано';

  @override
  String get settingsRenameFailed => 'Переименование не удалось';

  @override
  String get settingsRemoteLogout => 'Удаленный выход из системы';

  @override
  String settingsRemoteLogoutConfirm(String deviceName) {
    return 'Вы уверены, что хотите выйти из системы «$deviceName»? Это действие невозможно отменить.';
  }

  @override
  String get settingsDeviceLoggedOut => 'Устройство вышел из системы';

  @override
  String get settingsLogoutFailed => 'Выход из системы не выполнен';

  @override
  String get settingsLogout => 'Выход из системы';

  @override
  String get settingsVerifyIdentity => 'Подтвердить личность';

  @override
  String get settingsEnterPasswordToConfirm =>
      'Введите свой пароль, чтобы подтвердить это действие.';

  @override
  String get scheduledSendTitle => 'Запланировать сообщение';

  @override
  String get scheduledSendInOneHour => 'Через 1 час';

  @override
  String get scheduledSendTonight => 'Сегодня вечером (20:00)';

  @override
  String get scheduledSendTomorrowMorning => 'Завтра утром (9:00 утра)';

  @override
  String get scheduledSendCustom => 'Выберите дату и время';

  @override
  String get scheduledMessageLabel => 'Запланировано';

  @override
  String get scheduledMessageCancel => 'Отменить запланированное сообщение';

  @override
  String get chatLockTitle => 'Блокировка чата';

  @override
  String get chatLockEnable => 'Заблокировать этот чат';

  @override
  String get chatLockDisable => 'Разблокировать этот чат';

  @override
  String get chatLockDescription =>
      'Для открытия заблокированных чатов требуется биометрическая проверка или проверка PIN-кода.';

  @override
  String get chatLockVerifyTitle => 'Чат заблокирован';

  @override
  String get chatLockVerifySubtitle =>
      'Подтвердите, чтобы получить доступ к этому чату';

  @override
  String get chatLockVerifyFailed => 'Проверка не удалась';

  @override
  String get chatLockEnabled => 'Чат заблокирован';

  @override
  String get chatLockDisabled => 'Чат разблокирован';

  @override
  String get chatLockPinTitle => 'Введите PIN-код';

  @override
  String get chatLockPinSetTitle => 'Установить PIN-код';

  @override
  String get chatLockPinConfirmTitle => 'Подтвердить PIN-код';

  @override
  String get chatLockPinMismatch => 'ПИН-код не совпадает';

  @override
  String get chatLockUseBiometric => 'Используйте биометрические';

  @override
  String get chatLockUsePin => 'Использовать PIN-код';

  @override
  String get mediaEditorUndo => 'Отменить';

  @override
  String get mediaEditorRedo => 'Повторить';

  @override
  String get mediaEditorCrop => 'Обрезка';

  @override
  String get mediaEditorFilter => 'Фильтр';

  @override
  String get mediaEditorDraw => 'Ничья';

  @override
  String get mediaEditorText => 'Текст';

  @override
  String get aiAssistant => 'ИИ-помощник';

  @override
  String get aiAssistantWelcome =>
      'Здравствуйте! Я ИИ-помощник N42. Могу я чем-нибудь помочь?';

  @override
  String get aiAssistantNotConfigured => 'Служба AI не настроена';

  @override
  String get aiAssistantSettings => 'Настройки ИИ';

  @override
  String get aiAssistantClearHistory => 'Очистить историю чата';

  @override
  String get aiAssistantClearHistoryConfirm =>
      'Вы уверены, что хотите очистить всю историю чатов AI?';

  @override
  String get aiAssistantStopGenerating => 'Прекратить генерировать';

  @override
  String get aiAssistantModel => 'Модель';

  @override
  String get aiAssistantTemperature => 'Температура';

  @override
  String get aiAssistantMaxTokens => 'Макс. жетонов';

  @override
  String get aiAssistantContextWindow => 'Контекстное окно';

  @override
  String get aiAssistantServiceStatus => 'Статус услуги';

  @override
  String get aiAssistantAvailable => 'Доступно';

  @override
  String get aiAssistantUnavailable => 'Недоступно';

  @override
  String get aiSummarize => 'Обзор ИИ';

  @override
  String aiSummarizeUnread(int count) {
    return 'Суммировать непрочитанные сообщения $count';
  }

  @override
  String get aiSummarizeLoading => 'Подводя итог...';

  @override
  String get aiSummarizeError => 'Не удалось подвести итог';

  @override
  String get aiRewrite => 'Переписывание ИИ';

  @override
  String get aiRewriteFormal => 'Формальный';

  @override
  String get aiRewriteCasual => 'Повседневный';

  @override
  String get aiRewritePlayful => 'Игривый';

  @override
  String get aiRewriteProfessional => 'Профессиональный';

  @override
  String get aiRewriteAccept => 'Использование';

  @override
  String get aiRewriteCancel => 'Отмена';

  @override
  String get aiRewriteLoading => 'Переписывание...';

  @override
  String get aiLinkSummary => 'Обзор ИИ';

  @override
  String get aiLinkSummaryAnalyzing => 'Анализ...';

  @override
  String get chatFolderManagement => 'Управление папками';

  @override
  String get chatFolderSystem => 'Системные папки';

  @override
  String get chatFolderCustom => 'Пользовательские папки';

  @override
  String get chatFolderEmpty => 'Пользовательских папок пока нет';

  @override
  String get chatFolderCreate => 'Создать папку';

  @override
  String get chatFolderEdit => 'Редактировать папку';

  @override
  String get chatFolderNameHint => 'Имя папки';

  @override
  String get chatFolderAll => 'Все';

  @override
  String get chatFolderUnread => 'Непрочитано';

  @override
  String get chatFolderPersonal => 'Персональный';

  @override
  String get chatFolderGroups => 'Группы';

  @override
  String get chatFolderChannels => 'Каналы';

  @override
  String get chatFolderMuted => 'Без звука';

  @override
  String get storyAddMusic => 'Добавить музыку';

  @override
  String get storyChangeMusic => 'Изменить музыку';

  @override
  String get storyBackgroundMusic => 'Фоновая музыка';

  @override
  String get storyMusicPreview => 'Предварительный просмотр (максимум 15 сек.)';

  @override
  String get storyChooseFromDevice => 'Выберите из устройства';

  @override
  String get storyUseThisMusic => 'Используйте эту музыку';

  @override
  String get authPasskeyNotSupported =>
      'Ключ доступа не поддерживается на этом устройстве.';

  @override
  String get authPasskeyRegister => 'Зарегистрировать пароль';

  @override
  String get authPasskeyNoRegistered => 'Коды доступа не зарегистрированы';

  @override
  String get authPasskeyRegisterHint =>
      'Зарегистрируйте пароль для этой учетной записи. Автономный вход с ключом доступа будет включен позже.';

  @override
  String get authPasskeyNameYours => 'Назовите свой пароль';

  @override
  String get authPasskeyRegistered => 'Ключ доступа сохранен в этом аккаунте.';

  @override
  String get authPasskeyDeleted => 'Ключ доступа удален из этого аккаунта.';

  @override
  String authPasskeyDeleteConfirm(String name) {
    return 'Удалить ключ доступа «$name»? Вам нужно будет зарегистрировать его еще раз, прежде чем использовать пароль для входа в систему позже.';
  }

  @override
  String get momentVisibilityPublic => 'Общественный';

  @override
  String get momentVisibilityPrivate => 'Частный';

  @override
  String get momentVisibilityPartial => 'Избранные друзья';

  @override
  String get momentVisibilityExcluded => 'Исключить некоторых друзей';

  @override
  String momentUserMoments(String userName) {
    return 'Моменты $userName';
  }

  @override
  String get momentForwardTo => 'Переслать';

  @override
  String get momentForwardSuccess => 'Перенаправлено успешно';

  @override
  String get momentSelectFriends => 'Выберите друзей';

  @override
  String get momentSelectTags => 'Выбрать по тегам';

  @override
  String momentSelectedCount(int count) {
    return 'Выбрано ($count)';
  }

  @override
  String get momentNoMomentsYet => 'Пока нет моментов';

  @override
  String get momentForwardMoment => 'Момент вперед';

  @override
  String get momentAddComment => 'Добавить комментарий...';

  @override
  String momentForwardContent(String content) {
    return '[Момент] $content';
  }

  @override
  String get momentDeleteMoment => 'Удалить момент';

  @override
  String get momentDeleteConfirm =>
      'Вы уверены, что хотите удалить этот момент?';

  @override
  String get momentComment => 'Комментарий';

  @override
  String get momentWriteComment => 'Напишите комментарий...';

  @override
  String get momentLike => 'Нравится';

  @override
  String get momentUnlike => 'В отличие от';

  @override
  String get momentForward => 'Вперед';

  @override
  String get momentDelete => 'Удалить';

  @override
  String get momentReply => 'ответить';

  @override
  String get momentMoment => 'Момент';

  @override
  String momentLikesCount(int count) {
    return '$count нравится';
  }

  @override
  String momentCommentsCount(int count) {
    return '$count комментарии';
  }

  @override
  String get momentNoComments => 'Комментариев пока нет';

  @override
  String get momentFailedToLoad => 'Не удалось загрузить изображение';

  @override
  String momentReplyTo(String userName) {
    return 'Ответ на $userName...';
  }

  @override
  String get momentNoConversations => 'Никаких разговоров';

  @override
  String get momentJustNow => 'только что';

  @override
  String momentMinutesAgo(int count) {
    return '$countм назад';
  }

  @override
  String momentHoursAgo(int count) {
    return '$countч назад';
  }

  @override
  String momentDaysAgo(int count) {
    return '$countд назад';
  }

  @override
  String get chatGroupAnnouncementHint => 'Введите групповое объявление';

  @override
  String get chatGroupAnnouncementEmpty => 'Нет объявления';

  @override
  String get chatEditNickname => 'Изменить псевдоним';

  @override
  String get chatNicknameHint => 'Введите свой ник в этой группе';

  @override
  String get contactAddPhoneHint => 'Введите номер телефона';

  @override
  String get contactNotesHint => 'Добавить примечания об этом контакте';

  @override
  String get reportTitle => 'Отчет';

  @override
  String get reportReasonSpam => 'Спам';

  @override
  String get reportReasonHarassment => 'Преследование';

  @override
  String get reportReasonFraud => 'Мошенничество';

  @override
  String get reportReasonOther => 'Другое';

  @override
  String get reportSubmitted => 'Отчет отправлен';

  @override
  String get reportDescription => 'Дополнительное описание (необязательно)';

  @override
  String get qrcodeSaved => 'QR-код сохранен в альбоме';

  @override
  String get chatSendRedPacketInChat =>
      'Пожалуйста, отправьте красный пакет в чат';

  @override
  String get commonSaveFailed => 'Сохранить не удалось';

  @override
  String get reportSelectReason => 'Пожалуйста, выберите причину';

  @override
  String get gameCenter => 'Игры';

  @override
  String get gameHighScore => 'Лучший';

  @override
  String get gameScore => 'Очки';

  @override
  String get gameOver => 'Игра окончена';

  @override
  String get gamePlayAgain => 'Играть снова';

  @override
  String get gameLeaderboard => 'Таблица лидеров';

  @override
  String get gamePause => 'Пауза';

  @override
  String get gameResume => 'Нажмите для продолжения';

  @override
  String get gameConfirmExit => 'Выйти из игры?';

  @override
  String get gameNoScores => 'Нет результатов';

  @override
  String get game2048 => '2048';

  @override
  String get game2048Desc => 'Объединяйте плитки до 2048';

  @override
  String get gameBlockDrop => 'Блоки';

  @override
  String get gameBlockDropDesc => 'Сбрасывайте и убирайте линии';

  @override
  String get gameMinesweeper => 'Сапёр';

  @override
  String get gameMinesweeperDesc => 'Найдите все безопасные клетки';

  @override
  String get gameMatch3 => 'Три в ряд';

  @override
  String get gameMatch3Desc => 'Соедините 3 или более камня';

  @override
  String get gameMinesweeperEasy => 'Лёгкий';

  @override
  String get gameMinesweeperMedium => 'Средний';

  @override
  String get gameMinesLeft => 'Осталось мин';

  @override
  String get gameTimeLeft => 'Время';

  @override
  String get gameLevel => 'Уровень';

  @override
  String get gameNext => 'Далее';

  @override
  String get gameBestTime => 'Лучшее время';

  @override
  String get gameNewRecord => 'Новый рекорд!';

  @override
  String get gameLines => 'Линии';

  @override
  String get storyMyStory => 'Моя история';

  @override
  String get storageSmartCleanup => 'Умная очистка';

  @override
  String get storageOldMediaFiles => 'Старые медиа-файлы';

  @override
  String get storageLargeFiles => 'Большие файлы';

  @override
  String get storageAppCache => 'Кэш приложения';

  @override
  String get storageSettings => 'Настройки хранилища';

  @override
  String get storageAutoCleanup => 'Автоматическая очистка';

  @override
  String storageAutoCleanupDesc(int days) {
    return 'Автоматически очищать файлы старше $days дней.';
  }

  @override
  String get storageCleanupPeriod => 'Период очистки';

  @override
  String get storagePreserveThumbnails => 'Сохранить миниатюры';

  @override
  String get storagePreserveThumbnailsDesc =>
      'Сохранять миниатюры изображений во время очистки';

  @override
  String get storageWarningHigh =>
      'Использование хранилища высокое. Рассмотрите возможность очистки старых файлов.';

  @override
  String get storageWarningCritical =>
      'Памяти критически мало. Пожалуйста, очистите, чтобы освободить место.';

  @override
  String storageFreed(String size, int count) {
    return 'Освобожден $size (файлы $count)';
  }

  @override
  String storageDays(int days) {
    return '$days дней';
  }

  @override
  String storageViewAllRooms(int count) {
    return 'Посмотреть все комнаты $count';
  }

  @override
  String get storageNoFiles => 'Файлы не найдены';

  @override
  String get storageFilePinned => 'Закреплено';

  @override
  String storageDeleteSelected(int count) {
    return 'Удалить выбранные файлы $count? Их можно повторно скачать с сервера.';
  }

  @override
  String get backupRestore => 'Резервное копирование и восстановление';

  @override
  String get backupCreate => 'Создать резервную копию';

  @override
  String get backupCreateDesc =>
      'Сделайте резервную копию ваших настроек и ключей шифрования. Сообщения будут восстановлены с сервера после повторного входа в систему.';

  @override
  String get backupIncludeKeys => 'Включить ключи шифрования';

  @override
  String get backupIncludeKeysDesc =>
      'Требуется для чтения зашифрованных сообщений';

  @override
  String get backupPasswordProtect => 'Защита паролем';

  @override
  String get backupEnterPassword => 'Введите резервный пароль';

  @override
  String get backupHistory => 'История резервного копирования';

  @override
  String get backupNoBackups => 'Резервных копий пока нет';

  @override
  String get backupRestore2 => 'Восстановить';

  @override
  String get backupDelete => 'Удалить';

  @override
  String get backupDeleteConfirm =>
      'Вы уверены, что хотите удалить эту резервную копию? Это невозможно отменить.';

  @override
  String get backupRestoreFromFile => 'Восстановить из файла';

  @override
  String get backupRestoreFromFileDesc =>
      'Импортируйте файл резервной копии .n42 с другого устройства или из предыдущей резервной копии.';

  @override
  String get backupChooseFile => 'Выберите файл резервной копии';

  @override
  String get backupRestoring => 'Восстановление...';

  @override
  String backupCreated(int rooms, int messages) {
    return 'Резервная копия создана: комнаты $rooms, сообщения $messages.';
  }

  @override
  String backupRestored(int settings, int rooms) {
    return 'Восстановлены настройки $settings из комнат $rooms.';
  }

  @override
  String backupFailed(String error) {
    return 'Не удалось выполнить резервное копирование: $error.';
  }

  @override
  String get backupPasswordRequired => 'Эта резервная копия защищена паролем';

  @override
  String get blocGroupNotFound => 'Группа не найдена';

  @override
  String blocGroupMembersInvited(int count) {
    return 'Приглашенные участники $count';
  }

  @override
  String get blocGroupMemberRemoved => 'Участник удален';

  @override
  String get blocGroupAdminRemoved => 'Администратор удален';

  @override
  String get blocGroupLeft => 'Покинул группу';

  @override
  String get blocGroupDisbanded => 'Группа расформирована';

  @override
  String get blocGroupJoined => 'Присоединился к группе';

  @override
  String get blocGroupInviteDeclined => 'Приглашение отклонено';

  @override
  String get blocGroupTokenGateUpdated => 'Токен-гейт обновлен.';

  @override
  String get blocTransferProcessing => 'Обработка переноса...';

  @override
  String get blocTransferCancelled => 'Перенос отменен';

  @override
  String get blocTransferFailed => 'Передача не удалась';

  @override
  String get blocPaymentProcessing => 'Обработка платежа...';

  @override
  String get blocPaymentFailed => 'Платеж не выполнен';

  @override
  String get groupMaxMembers => 'Лимит участников';

  @override
  String get groupMaxMembersUnlimited => 'Безлимитный';

  @override
  String get groupMaxMembersHint =>
      'Введите лимит (оставьте пустым для неограниченного количества)';

  @override
  String get groupMaxMembersUpdated => 'Лимит участников обновлен';

  @override
  String get groupFull => 'Группа загружена';

  @override
  String get groupChannels => 'Тематические каналы';

  @override
  String get groupChannelsEmpty => 'Каналов пока нет';

  @override
  String get groupChannelsCount => 'каналы';

  @override
  String get groupChannelCreate => 'Новый канал';

  @override
  String get groupChannelName => 'Название канала';

  @override
  String get groupChannelTopic => 'Тема канала (необязательно)';

  @override
  String get groupChannelDelete => 'Удалить канал';

  @override
  String get groupChannelDeleteConfirm =>
      'Удалить этот канал? Все сообщения будут потеряны.';

  @override
  String get groupBotSettings => 'Настройки бота';

  @override
  String get groupBotEnabled => 'Включить бота';

  @override
  String get groupBotWelcomeMessage => 'Шаблон приветственного сообщения';

  @override
  String get groupBotWelcomeHint =>
      'Используйте «имя» в качестве заполнителя для имени нового участника.';

  @override
  String get groupBotConfigUpdated => 'Настройки бота обновлены.';

  @override
  String get groupContentFilter => 'Контент-фильтр';

  @override
  String get groupContentFilterEnabled => 'Включить фильтр ключевых слов';

  @override
  String get groupContentFilterReplace => 'Заменить на ***';

  @override
  String get groupContentFilterHide => 'Скрыть сообщение';

  @override
  String get groupContentFilterAddWord => 'Добавить ключевое слово';

  @override
  String get groupContentFilterUpdated => 'Фильтр контента обновлен.';

  @override
  String get chatSlashCommands => 'Команды';

  @override
  String get chatCommandPoll => '/poll — Создать опрос';

  @override
  String get chatCommandAnnounce => '/announce — Отправить объявление';

  @override
  String get chatCommandWelcome =>
      '/welcome — Установить приветственное сообщение';

  @override
  String get chatReportMessage => 'Отчет';

  @override
  String get chatReportReason => 'Причина отчета';

  @override
  String get chatReportSpam => 'Спам';

  @override
  String get chatReportHarassment => 'Преследование';

  @override
  String get chatReportInappropriate => 'Неприемлемый контент';

  @override
  String get chatReportOther => 'Другое';

  @override
  String get chatReportSuccess => 'Отчет отправлен';

  @override
  String get spacesName => 'Имя сообщества';

  @override
  String get spacesNameHint => 'например Крипто-трейдеры';

  @override
  String get spacesNameRequired => 'Требуется имя';

  @override
  String get spacesDescription => 'Описание';

  @override
  String get spacesDescriptionHint => 'О чем это сообщество?';

  @override
  String get spacesType => 'Тип сообщества';

  @override
  String get spacesPublicDesc => 'Любой может найти и присоединиться';

  @override
  String get spacesPrivateDesc =>
      'Только приглашенные участники могут присоединиться';

  @override
  String get spacesNotFound => 'Сообщество не найдено';

  @override
  String get spacesSearch => 'Поиск в сообществах...';

  @override
  String get spacesMembers => 'Члены';

  @override
  String get spacesNoChannels => 'Каналов пока нет';

  @override
  String get spacesLeave => 'Покинуть сообщество';

  @override
  String spacesLeaveConfirm(String name) {
    return 'Вы уверены, что хотите покинуть «$name»?';
  }

  @override
  String get spacesDelete => 'Удалить сообщество';

  @override
  String spacesDeleteConfirm(String name) {
    return 'Это приведет к безвозвратному удалению «$name» и всех его каналов. Это действие невозможно отменить.';
  }

  @override
  String get spacesCreateChannel => 'Добавить канал';

  @override
  String get spacesChannelName => 'Название канала';

  @override
  String get spacesChannelTopic => 'Тема (необязательно)';

  @override
  String get spacesDeleteChannel => 'Удалить канал';

  @override
  String spacesDeleteChannelConfirm(String name) {
    return 'Вы уверены, что хотите удалить «#$name»?';
  }

  @override
  String get spacesEditName => 'Изменить имя';

  @override
  String get spacesEditDescription => 'Изменить описание';

  @override
  String spacesViewAllMembers(int count) {
    return 'Просмотреть всех участников $count';
  }

  @override
  String spacesKickMemberTitle(String name) {
    return 'Кик $name';
  }

  @override
  String spacesBanMemberTitle(String name) {
    return 'Забанить $name';
  }

  @override
  String get spacesPromoteAdmin => 'Повышение до администратора';

  @override
  String get spacesDemoteAdmin => 'Удалить администратора';

  @override
  String get spacesInviteMember => 'Пригласить участника';

  @override
  String get spacesInviteMemberUserId =>
      'Идентификатор пользователя (например, @user:server.com)';

  @override
  String get spacesSave => 'Сохранить';

  @override
  String get settingsScreenshotProtection => 'Защита скриншотов';

  @override
  String get settingsScreenshotProtectionDesc =>
      'Запретить создание снимков экрана и запись экрана';

  @override
  String get chatSelfDestructTimer => 'Самоуничтожение';

  @override
  String get chatTimerPickerTitle => 'Таймер самоуничтожения';

  @override
  String get chatTimerOff => 'Выкл.';

  @override
  String get onChainNotificationsTitle => 'События в блокчейне';

  @override
  String get onChainMarkAllRead => 'Отметить все прочитанными';

  @override
  String get onChainNoNotifications => 'Событий в блокчейне пока нет';

  @override
  String get onChainNoNotificationsDesc =>
      'События из подписанных каналов появятся здесь';

  @override
  String get onChainViewDetails => 'Посмотреть детали';

  @override
  String get chatCommandHelp => '/help — Показать все команды';

  @override
  String get chatCommandPrice => '/price — Получить цену токена';

  @override
  String get chatCommandBalance => '/balance — Показать баланс кошелька';

  @override
  String get chatCommandChains => '/chains — Список 236+ поддерживаемых сетей';

  @override
  String get chatMiniApps => 'Приложения';

  @override
  String get miniAppMarketTitle => 'Мини-приложения';

  @override
  String get miniAppCategoryAll => 'Все';

  @override
  String get miniAppSearch => 'Поиск приложений...';

  @override
  String get miniAppFeatured => 'Рекомендуемые';

  @override
  String get miniAppAllApps => 'Все приложения';

  @override
  String get miniAppNoResults => 'Приложения не найдены';

  @override
  String get slideToPayLabel => '→→→  Проведите для подтверждения';

  @override
  String get slideToPayConfirming => 'Подтверждение...';

  @override
  String get redPacketBestLuck => 'Лучшая удача';

  @override
  String get redPacketBestLuckCongrats =>
      'Лучшая удача! Вы получили больше всех!';

  @override
  String redPacketStats(int claimed, int total) {
    return '$claimed / $total получено';
  }

  @override
  String get redPacketStatsTotal => 'итого';

  @override
  String redPacketGrabbedViral(String amount, String token) {
    return '🧧 Получил красный конверт • $amount $token';
  }

  @override
  String get web3SearchHint => '@matrix:id  •  адрес 0x  •  name.eth';

  @override
  String get web3SearchPlaceholder => 'Поиск по ID, кошельку или ENS...';

  @override
  String get web3WalletAddress => 'Адрес кошелька';

  @override
  String get web3AddressCopied => 'Адрес скопирован';

  @override
  String get web3Copy => 'Копировать';

  @override
  String get web3SendMessage => 'Отправить сообщение';

  @override
  String get web3SendToWallet => 'Сообщение на кошелёк';

  @override
  String get web3WalletOnlyHint =>
      'У этого адреса ещё нет аккаунта N42. Сообщение будет доставлено после регистрации.';

  @override
  String get web3NftAvatar => 'NFT-аватар';

  @override
  String get web3ResolveFailed => 'Не удалось определить идентификатор';

  @override
  String web3EnsNotFound(String name) {
    return 'ENS-имя \"$name\" не найдено';
  }

  @override
  String get web3NoN42AccountTitle => 'Нет аккаунта N42';

  @override
  String get web3NoN42AccountDesc =>
      'Для этого адреса кошелька еще нет учетной записи N42. Вы можете поделиться с ними ссылкой для приглашения N42, чтобы начать работу.';

  @override
  String get web3ShareInvite => 'Поделиться приглашением';

  @override
  String get nftPickerTitle => 'Выбрать NFT-аватар';

  @override
  String get nftPickerTabPopular => 'Популярные';

  @override
  String get nftPickerTabCustom => 'Настраиваемый';

  @override
  String get nftPickerChain => 'Цепь';

  @override
  String get nftPickerContract => 'Адрес контракта';

  @override
  String get nftPickerTokenId => 'Идентификатор токена';

  @override
  String get nftPickerVerifyOwnership => 'Подтвердить право собственности';

  @override
  String get nftPickerUseAsAvatar => 'Использовать как аватар';

  @override
  String get nftPickerPreview => 'Предварительный просмотр';

  @override
  String get nftPickerNotOwned => 'Вы не владеете этим NFT';

  @override
  String get nftPickerInvalidTokenId => 'Неверный идентификатор токена';

  @override
  String get nftPickerEnterBoth =>
      'Введите адрес контракта и идентификатор токена';

  @override
  String get nftPickerInfoTitle => 'NFT-аватар — on-chain верификация';

  @override
  String get nftPickerInfoDesc =>
      'Привяжите принадлежащий вам NFT в качестве своего аватара. Любой может подтвердить право собственности в сети. Отображается с золотым кольцом поперек N42.';

  @override
  String get nftPickerPopularCollections => 'Популярные коллекции';

  @override
  String get nftPickerWalletHint =>
      'Подключите кошелёк N42, чтобы автоматически находить NFT в 236+ сетях.';

  @override
  String get profileBindNftAvatar => 'Привязать NFT-аватар';

  @override
  String get profileChangeAvatar => 'Изменить аватар';

  @override
  String get groupTopics => 'Темы';

  @override
  String get groupTopicsEmpty => 'Тем еще нет';

  @override
  String get syncInProgress => 'Синхронизация истории сообщений...';

  @override
  String get recoveryKeyReminderTitle => 'Защитите свои сообщения';

  @override
  String get recoveryKeyReminderDesc =>
      'Создайте ключ восстановления для безопасной синхронизации зашифрованных сообщений между устройствами.';

  @override
  String get recoveryKeySetupNow => 'Настроить сейчас';

  @override
  String get recoveryKeyRemindLater => 'Напомни мне позже';

  @override
  String get channelReadOnly =>
      'Только администраторы могут публиковать сообщения на этом канале';

  @override
  String get channelSubscribers => 'подписчики';

  @override
  String get channelVerified => 'Проверенный канал';

  @override
  String get redPacketHistory => 'История красных пакетов';

  @override
  String get redPacketSent => 'Отправлено';

  @override
  String get redPacketReceived => 'Получено';

  @override
  String get redPacketExpired => 'Срок действия истек';

  @override
  String get redPacketClaimed => 'Заявлено';

  @override
  String get redPacketInsufficientBalance => 'Недостаточный баланс';

  @override
  String selfDestructCountdown(String time) {
    return 'Самоуничтожение в $time';
  }

  @override
  String get messageDestroyed => 'Сообщение уничтожено';

  @override
  String miniAppPermissionDenied(String permission) {
    return 'Разрешение отклонено: $permission';
  }

  @override
  String get aiSuggestionGasFee => 'Что такое плата за газ?';

  @override
  String get aiSuggestionDefi => 'Руководство для начинающих DeFi';

  @override
  String get aiSuggestionSecurity => 'Как проверить безопасность контракта';

  @override
  String get aiSuggestionBridge => 'Перекрестное мостовое соединение';

  @override
  String get channelDiscoverTitle => 'Откройте для себя каналы';

  @override
  String get channelDiscoverSearch => 'Поиск каналов...';

  @override
  String get channelJoin => 'Присоединяйтесь';

  @override
  String get channelJoined => 'Присоединился';

  @override
  String get channelCategory => 'Категория';

  @override
  String slowModeCooldown(int seconds) {
    return 'Медленный режим: подождите ${seconds}s';
  }

  @override
  String get addressCopyAction => 'Копировать адрес';

  @override
  String get addressSendMessage => 'Отправить сообщение';

  @override
  String get addressViewProfile => 'Посмотреть профиль';

  @override
  String get sendToAddress => 'Отправить на адрес кошелька';

  @override
  String get blocAuthSendVerificationCodeFailed =>
      'Не удалось отправить код подтверждения';

  @override
  String get blocAuthServerNoEmailPasswordReset =>
      'Этот сервер не поддерживает сброс пароля электронной почты.';

  @override
  String get blocAuthResetPasswordFailed => 'Не удалось сбросить пароль';

  @override
  String get blocAuthChangePasswordFailed => 'Не удалось изменить пароль';

  @override
  String get blocAuthOldPasswordWrong => 'Неправильный текущий пароль';

  @override
  String get blocAuthLoginCancelled => 'Вход отменен';

  @override
  String get blocAuthGoogleLoginFailed => 'Не удалось войти в Google';

  @override
  String get blocAuthAppleLoginFailed => 'Не удалось войти в Apple';

  @override
  String get blocAuthSsoLoginFailed =>
      'Не удалось войти в систему единого входа';

  @override
  String get blocAuthFacebookLoginFailed => 'Не удалось войти в Facebook';

  @override
  String get blocAuthTwitterLoginFailed => 'Не удалось войти в Твиттер';

  @override
  String get blocAuthWeChatLoginFailed => 'Не удалось войти в WeChat';

  @override
  String get blocAuthWeChatNotConfigured => 'Вход в WeChat не настроен';

  @override
  String get blocAuthWeChatNotInstalled =>
      'Пожалуйста, сначала установите WeChat';

  @override
  String get blocAuthPasswordWrong => 'Неправильный пароль';

  @override
  String get blocAuthEmailAlreadyBound =>
      'Этот адрес электронной почты уже привязан к другой учетной записи';

  @override
  String get blocAuthChangeEmailFailed =>
      'Не удалось изменить адрес электронной почты';

  @override
  String get blocAuthVerificationCodeInvalid =>
      'Код подтверждения неверен или срок его действия истек.';

  @override
  String get blocAuthSessionExpired =>
      'Срок сеанса истек, пожалуйста, войдите снова';

  @override
  String get blocAuthSessionIncomplete =>
      'Данные сеанса неполные, пожалуйста, войдите снова';
}
