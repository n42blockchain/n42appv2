// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ru';

  static String m0(deviceName, os) =>
      "В ваш аккаунт только что был выполнен вход с ${deviceName} (${os}). Если это были не вы, рекомендуем сменить пароль.";

  static String m1(value) => "Это ${value}";

  static String m2(value) => "Участники чата (${value})";

  static String m3(value) =>
      "Вы уверены, что хотите добавить ${value} в друзья";

  static String m4(value) =>
      "Привязка уже выполнена, повторная привязка невозможна. Адрес привязки: ${value}.";

  static String m5(value) => "Привязка успешна. Адрес привязки: ${value}";

  static String m6(value) => "В кошельке ${value} нет сети N42chain!";

  static String m7(value) => "Сопоставление успешно. Адрес:${value}.";

  static String m8(value) => "Сумма больше ${value}.";

  static String m9(value) =>
      "Кошелёк уже существует, название кошелька \"${value}\"";

  static String m10(value) => "Введите сумму больше ${value}.";

  static String m11(gas) =>
      "Газ выполнения (${gas}) высокий. Вызванный контракт может потреблять больше газа, чем ожидалось.";

  static String m12(gas) =>
      "Первая транзакция включает развёртывание аккаунта (~${gas} газа). Последующие транзакции будут дешевле.";

  static String m13(gas) =>
      "Накладные расходы газа paymaster (${gas}) высоки. Транзакции без газа могут стоить дороже.";

  static String m14(gas) =>
      "Расчётный общий газ (${gas}) необычно высок. Проверьте транзакцию на наличие ошибок.";

  static String m15(gas) =>
      "Газ верификации (${gas}) может быть слишком высоким. Это может происходить при сложной логике аккаунта.";

  static String m16(value) => "Осталось ${value} дней";

  static String m17(value) => "Дубликат адреса в строке ${value}";

  static String m18(value) => "Неверный адрес в строке ${value}";

  static String m19(value) => "Неверная сумма в строке ${value}";

  static String m20(value) => "Максимум ${value} получателей";

  static String m21(value) => "+${value} pts/day";

  static String m22(value) => "Earn up to ${value}% APY";

  static String m23(value) => "Congratulations! You now own ${value}";

  static String m24(value) => "Please wait ${value} seconds";

  static String m25(value) => "Auto-refresh every ${value} seconds";

  static String m26(address) => "Счёт ${address} добавлен";

  static String m27(address, network) =>
      "Хотите отслеживать этот счёт аппаратного кошелька?\n\nАдрес: ${address}\nСеть: ${network}";

  static String m28(app) => "Current app: ${app}";

  static String m29(days) => "${days} days ago";

  static String m30(value) => "Не удалось импортировать счёт: ${value}";

  static String m31(date) => "Last connected: ${date}";

  static String m32(value) =>
      "Пожалуйста, откройте приложение ${value} на устройстве";

  static String m33(app) =>
      "Убедитесь, что приложение ${app} открыто на Ledger";

  static String m34(name) =>
      "Are you sure you want to remove \"${name}\" from saved devices?";

  static String m35(value) => "Earn ${value} points";

  static String m36(value) => "Earn ${value} points for each friend who joins!";

  static String m37(value) => "${value} баллов до след. уровня";

  static String m38(amount, token) => "≈ ${amount}${token}";

  static String m39(amount) => "≈ ${amount} USDT";

  static String m40(value) =>
      "Вы уверены, что хотите удалить контакт ${value}?";

  static String m41(value) => "${value}d unbond";

  static String m42(value) => "Осталось ${value} дней";

  static String m43(value) => "${value} days remaining";

  static String m44(value) => "У вас недостаточно \"${value}\"";

  static String m45(value) => "Не удалось получить аккаунт \"${value}\"";

  static String m46(value) => "Минимум ${value} XRP для первого перевода";

  static String m47(value) => "${value}d ago";

  static String m48(value) => "${value}h ago";

  static String m49(value) => "${value}m ago";

  static String m50(value) => "Verification code sent to ${value}";

  static String m51(value) => "Сеть ${value} не добавлена.";

  static String m52(value) =>
      "У ${value} есть незавершённые транзакции, попробуйте позже.";

  static String m53(value) => "Адрес для ${value} не найден.";

  static String m54(value) => "Недостаточный баланс ${value}.";

  static String m55(value, value1) =>
      "Каждый аккаунт XRP должен резервировать ${value} XRP (${value1} drops) в качестве базового минимума, который нельзя потратить.";

  static String m56(value, value1) =>
      "За каждый объект, принадлежащий аккаунту, к резерву добавляется ${value} XRP (${value1} drops).";

  static String m57(value, value1) =>
      "Этот аккаунт владеет ${value} объектами, что означает дополнительный резерв в ${value1} XRP.";

  static String m58(value) =>
      "Ошибка ввода графического пароля, осталось ${value} попыток";

  static String m59(value) =>
      "Ошибка ввода графического пароля, осталась ${value} попытка";

  static String m60(value) =>
      "Вы успешно настроили ${value} и начнёте верификацию с N42Wallet!";

  static String m61(value) =>
      "Присоединяйтесь к моей группе ${value} в @N42Wallet, чтобы стать ранним майнером Layer 1 сети и получать крипто на свой телефон!";

  static String m62(value) => "Заблокируйте ${value} N для запуска валидатора.";

  static String m63(value) => "Импорт не удался:${value}";

  static String m64(value) =>
      "Для получения вознаграждений требуется баланс стейкинга не менее ${value}.";

  static String m65(value, value1) =>
      "${value} N каждые ${value1} добытых блоков";

  static String m66(value) => "Должно быть ${value} символов";

  static String m67(value) => "Недостаточный баланс ${value}.";

  static String m68(value) => "${value} поступает...";

  static String m69(value) =>
      "${value} обменянные в приложении будут в ближайшее время распределены на ваш кошелёк и не могут быть проданы через этот процесс. Их можно использовать для запуска ноды.";

  static String m70(value) => "Максимум ${value} символов";

  static String m71(value) => "Сеть ${value} уже поддерживается приложением!";

  static String m72(value) =>
      "Сеть ${value} уже поддерживается приложением, хотите её добавить?";

  static String m73(value) =>
      "Тестовое подключение к адресу ${value} не удалось!";

  static String m74(value) =>
      "Приложение разблокируется через ${value} секунд.";

  static String m75(value) =>
      "Ошибка ввода графического пароля, осталось ${value} попыток";

  static String m76(value) => "Ошибка ввода пароля, осталось ${value} попыток";

  static String m77(value) => "Ошибка ввода пароля, осталась ${value} попытка";

  static String m78(value) => "Введите пароль ${value}";

  static String m79(value) => "0~${value} символов";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Create_account": MessageLookupByLibrary.simpleMessage(
      "Зарегистрироваться",
    ),
    "Create_your_account": MessageLookupByLibrary.simpleMessage(
      "Создайте аккаунт",
    ),
    "Edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
    "Verification": MessageLookupByLibrary.simpleMessage("Верификация"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Информация об адресе",
    ),
    "code_403": MessageLookupByLibrary.simpleMessage(
      "Аккаунт временно заблокирован на один день",
    ),
    "code_err_tips": MessageLookupByLibrary.simpleMessage(
      "Неверный код. Попробуйте снова.",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Успешно скопировано"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("Копировать адрес"),
    "descO": MessageLookupByLibrary.simpleMessage("Описание (необязательно)"),
    "device_login_change_password": MessageLookupByLibrary.simpleMessage(
      "Сменить пароль",
    ),
    "device_login_dismiss": MessageLookupByLibrary.simpleMessage("Понятно"),
    "device_login_message": m0,
    "device_login_title": MessageLookupByLibrary.simpleMessage(
      "Вход с нового устройства",
    ),
    "editPhoto": MessageLookupByLibrary.simpleMessage("Редактировать фото"),
    "email_code_error": MessageLookupByLibrary.simpleMessage(
      "Не удалось получить код подтверждения",
    ),
    "email_code_finish": MessageLookupByLibrary.simpleMessage(
      "Код подтверждения успешно отправлен, проверьте почту",
    ),
    "email_code_input_error": MessageLookupByLibrary.simpleMessage(
      "Ошибка кода подтверждения",
    ),
    "email_error": MessageLookupByLibrary.simpleMessage(
      "Неверный адрес электронной почты",
    ),
    "email_verification": MessageLookupByLibrary.simpleMessage(
      "Подтверждение электронной почты",
    ),
    "email_verification_message1": MessageLookupByLibrary.simpleMessage(
      "Подтверждение по электронной почте защищает ваши выводы средств и аккаунт N42Wallet.",
    ),
    "email_verification_message2": MessageLookupByLibrary.simpleMessage(
      "Добавить подтверждение по email?",
    ),
    "file": MessageLookupByLibrary.simpleMessage("Файл"),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "Токены можно отправлять только в пределах одной сети. Отправка из других сетей может привести к потере средств.",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage(
      "Сканируйте для получения",
    ),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите URL",
    ),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage("Введите описание"),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("Браузер"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage(
      "Очистить кэш браузера",
    ),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage(
      "Автоматическое подключение к DApp",
    ),
    "g_browser_key14": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, подтвердите подключение к DApp",
    ),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("Закрыть все"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("Готово"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Закладки"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage(
      "Закладки ещё не добавлены",
    ),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("Закладка"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("Название"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите название",
    ),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("Описание"),
    "g_chat_key_1": MessageLookupByLibrary.simpleMessage(
      "Начать групповой чат",
    ),
    "g_chat_key_10": m1,
    "g_chat_key_11": MessageLookupByLibrary.simpleMessage("Пригласить друзей"),
    "g_chat_key_12": MessageLookupByLibrary.simpleMessage("Выбрать контакт"),
    "g_chat_key_13": MessageLookupByLibrary.simpleMessage("Готово"),
    "g_chat_key_14": MessageLookupByLibrary.simpleMessage(
      "Выберите минимум 2 контакта",
    ),
    "g_chat_key_16": MessageLookupByLibrary.simpleMessage("Данные друга"),
    "g_chat_key_17": MessageLookupByLibrary.simpleMessage("Данные группы"),
    "g_chat_key_18": MessageLookupByLibrary.simpleMessage(
      "Посмотреть больше участников группы",
    ),
    "g_chat_key_19": MessageLookupByLibrary.simpleMessage("Название группы"),
    "g_chat_key_2": MessageLookupByLibrary.simpleMessage("Новый друг"),
    "g_chat_key_20": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите распустить группу?",
    ),
    "g_chat_key_21": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите покинуть группу?",
    ),
    "g_chat_key_22": MessageLookupByLibrary.simpleMessage("Распустить группу"),
    "g_chat_key_23": MessageLookupByLibrary.simpleMessage("Покинуть группу"),
    "g_chat_key_24": MessageLookupByLibrary.simpleMessage(
      "Изменить название группового чата",
    ),
    "g_chat_key_25": MessageLookupByLibrary.simpleMessage(
      "При изменении названия группового чата другие участники будут уведомлены.",
    ),
    "g_chat_key_26": MessageLookupByLibrary.simpleMessage("Готово"),
    "g_chat_key_27": MessageLookupByLibrary.simpleMessage(
      "Запрос на добавление в друзья",
    ),
    "g_chat_key_28": MessageLookupByLibrary.simpleMessage(
      "Запрос на добавление в друзья",
    ),
    "g_chat_key_29": MessageLookupByLibrary.simpleMessage(
      "Запрос в друзья одобрен",
    ),
    "g_chat_key_3": MessageLookupByLibrary.simpleMessage("Добавлен"),
    "g_chat_key_30": MessageLookupByLibrary.simpleMessage(
      "Вы добавлены в друзья",
    ),
    "g_chat_key_31": MessageLookupByLibrary.simpleMessage("принять"),
    "g_chat_key_32": m2,
    "g_chat_key_33": MessageLookupByLibrary.simpleMessage(
      "Пароль не может быть корректно расшифрован, отправка сообщения временно невозможна. Импортируйте кошелёк при входе в группу",
    ),
    "g_chat_key_34": MessageLookupByLibrary.simpleMessage(
      "Удалить историю чата?",
    ),
    "g_chat_key_35": MessageLookupByLibrary.simpleMessage("Удалить участника"),
    "g_chat_key_36": MessageLookupByLibrary.simpleMessage("Мой QR-код"),
    "g_chat_key_4": MessageLookupByLibrary.simpleMessage("Истёк"),
    "g_chat_key_40": MessageLookupByLibrary.simpleMessage("Пожаловаться"),
    "g_chat_key_41": MessageLookupByLibrary.simpleMessage("Новый чат"),
    "g_chat_key_42": MessageLookupByLibrary.simpleMessage("Новая группа"),
    "g_chat_key_43": MessageLookupByLibrary.simpleMessage("QR-код"),
    "g_chat_key_44": MessageLookupByLibrary.simpleMessage(
      "Пожаловаться и заблокировать",
    ),
    "g_chat_key_45": MessageLookupByLibrary.simpleMessage(
      "Это сообщение будет отправлено в N42Wallet. Контакт не будет уведомлён.",
    ),
    "g_chat_key_46": MessageLookupByLibrary.simpleMessage("Видео"),
    "g_chat_key_47": MessageLookupByLibrary.simpleMessage("Фото"),
    "g_chat_key_48": MessageLookupByLibrary.simpleMessage("Удалить сообщение"),
    "g_chat_key_49": MessageLookupByLibrary.simpleMessage(
      "Удалить на моём устройстве",
    ),
    "g_chat_key_5": MessageLookupByLibrary.simpleMessage("Ожидание"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("Принять"),
    "g_chat_key_54": MessageLookupByLibrary.simpleMessage("Причина жалобы"),
    "g_chat_key_55": MessageLookupByLibrary.simpleMessage(
      "Введите причину жалобы",
    ),
    "g_chat_key_56": MessageLookupByLibrary.simpleMessage(
      "Мы проверим вашу жалобу и ответим в течение 24 часов.",
    ),
    "g_chat_key_57": MessageLookupByLibrary.simpleMessage(
      "Вы пожаловались на это - Нажмите для просмотра",
    ),
    "g_chat_key_58": MessageLookupByLibrary.simpleMessage("Чёрный список"),
    "g_chat_key_59": MessageLookupByLibrary.simpleMessage("Удалить"),
    "g_chat_key_6": m3,
    "g_chat_key_60": MessageLookupByLibrary.simpleMessage("Контактов пока нет"),
    "g_chat_key_61": MessageLookupByLibrary.simpleMessage("Сегодня"),
    "g_chat_key_62": MessageLookupByLibrary.simpleMessage("Более 3 дней назад"),
    "g_chat_key_63": MessageLookupByLibrary.simpleMessage("Заблокировать"),
    "g_chat_key_64": MessageLookupByLibrary.simpleMessage(
      "Привет, я использую N42Wallet для общения и отправки денег. Установи кошелёк и напиши мне на",
    ),
    "g_chat_key_66": MessageLookupByLibrary.simpleMessage("Ответить"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage("Сообщение удалено"),
    "g_chat_key_68": MessageLookupByLibrary.simpleMessage(
      "Кто-то упомянул меня",
    ),
    "g_chat_key_69": MessageLookupByLibrary.simpleMessage("Поздороваться"),
    "g_chat_key_8": MessageLookupByLibrary.simpleMessage("Добавить друзей"),
    "g_chat_key_9": MessageLookupByLibrary.simpleMessage("Причина заявки"),
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("Транзакции"),
    "g_connect_key1": MessageLookupByLibrary.simpleMessage("Подключить"),
    "g_connect_key11": MessageLookupByLibrary.simpleMessage("Доступные сети"),
    "g_connect_key12": MessageLookupByLibrary.simpleMessage(
      "Подпись сообщения",
    ),
    "g_connect_key13": MessageLookupByLibrary.simpleMessage("Подключение"),
    "g_connect_key14": MessageLookupByLibrary.simpleMessage(
      "Сопряжение, пожалуйста, подождите.",
    ),
    "g_connect_key2": MessageLookupByLibrary.simpleMessage("Отключить"),
    "g_connect_key3": MessageLookupByLibrary.simpleMessage("Отклонить"),
    "g_face_1": MessageLookupByLibrary.simpleMessage(
      "Подсказки биометрического сканирования",
    ),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Отсканируйте отпечаток пальца или лицо для аутентификации.",
    ),
    "g_face_2": MessageLookupByLibrary.simpleMessage(
      "Биометрическое сканирование не сработало",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("Подсказки"),
    "g_face_4": MessageLookupByLibrary.simpleMessage(
      "Биометрическое сканирование успешно",
    ),
    "g_face_5": MessageLookupByLibrary.simpleMessage("Настроить"),
    "g_face_6": MessageLookupByLibrary.simpleMessage(
      "Биометрический вход не настроен. Перейдите в Настройки системы для настройки.",
    ),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Отсканируйте лицо или отпечаток пальца для продолжения.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Назад"),
    "g_face_9": MessageLookupByLibrary.simpleMessage(
      "Рекомендуется повторно включить биометрию.",
    ),
    "g_face_match_key1": MessageLookupByLibrary.simpleMessage(
      "Метод сопоставления лица",
    ),
    "g_face_match_key10": m4,
    "g_face_match_key11": m5,
    "g_face_match_key12": MessageLookupByLibrary.simpleMessage("Перепривязать"),
    "g_face_match_key13": MessageLookupByLibrary.simpleMessage("Привязать"),
    "g_face_match_key14": MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "g_face_match_key15": MessageLookupByLibrary.simpleMessage(
      "Вы можете привязать биометрические данные лица к адресу кошелька напрямую (при наличии предыдущей привязки старый адрес будет перезаписан), или если вы ранее привязывали адрес кошелька, можете вручную проверить для получения привязанного адреса.",
    ),
    "g_face_match_key16": MessageLookupByLibrary.simpleMessage(
      "Обнаружен адрес кошелька, связанный с вашими биометрическими данными лица, но вы ещё не импортировали этот кошелёк в свой список кошельков.",
    ),
    "g_face_match_key17": MessageLookupByLibrary.simpleMessage(
      "Вы связали биометрические данные лица с этим кошельком.",
    ),
    "g_face_match_key18": MessageLookupByLibrary.simpleMessage(
      "Уведомление для пользователя",
    ),
    "g_face_match_key19": MessageLookupByLibrary.simpleMessage(
      "Что такое привязка лица?",
    ),
    "g_face_match_key20": MessageLookupByLibrary.simpleMessage(
      "Привязка лица использует технологию распознавания лиц для сопоставления ваших биометрических данных с адресом блокчейн-кошелька.",
    ),
    "g_face_match_key21": MessageLookupByLibrary.simpleMessage(
      "Этот процесс не только повышает удобство транзакций, но и усиливает безопасность аккаунта, гарантируя, что каждое действие авторизовано вами.",
    ),
    "g_face_match_key22": MessageLookupByLibrary.simpleMessage(
      "Зачем нужна привязка лица?",
    ),
    "g_face_match_key23": MessageLookupByLibrary.simpleMessage(
      "Привязывая биометрические данные лица, ваша личность напрямую связывается с транзакционной активностью, что упрощает процесс верификации и повышает операционную эффективность. Эта технология обеспечивает быструю и безопасную проверку личности при выполнении чувствительных операций, таких как перевод активов или взаимодействие с контрактами.",
    ),
    "g_face_match_key24": MessageLookupByLibrary.simpleMessage(
      "Как хранятся мои биометрические данные лица и безопасно ли это?",
    ),
    "g_face_match_key25": MessageLookupByLibrary.simpleMessage(
      "Ваши биометрические данные лица хранятся в зашифрованном виде в публичном блокчейне, а не в централизованной базе данных. Это означает, что система может расшифровать и использовать ваши данные для верификации личности только с вашей авторизации, обеспечивая конфиденциальность и безопасность данных.",
    ),
    "g_face_match_key26": MessageLookupByLibrary.simpleMessage(
      "Как привязка лица влияет на безопасность моего аккаунта?",
    ),
    "g_face_match_key27": MessageLookupByLibrary.simpleMessage(
      "Привязка лица повышает безопасность вашего аккаунта, гарантируя, что все чувствительные действия выполняются только с вашей явной авторизацией. Мы используем передовые технологии шифрования для защиты ваших биометрических данных, предотвращая несанкционированный доступ.",
    ),
    "g_face_match_key28": MessageLookupByLibrary.simpleMessage(
      "Безопасны ли мои биометрические данные лица?",
    ),
    "g_face_match_key29": MessageLookupByLibrary.simpleMessage(
      "Абсолютно. Все биометрические данные проходят строгое шифрование, и при передаче и хранении данных соблюдаются высочайшие стандарты безопасности. Система расшифрует эти данные только при необходимости для завершения верификации личности.",
    ),
    "g_face_match_key3": MessageLookupByLibrary.simpleMessage(
      "Сопоставление не удалось!",
    ),
    "g_face_match_key30": MessageLookupByLibrary.simpleMessage("Понятно"),
    "g_face_match_key31": MessageLookupByLibrary.simpleMessage(
      "Выберите адрес кошелька",
    ),
    "g_face_match_key32": m6,
    "g_face_match_key33": MessageLookupByLibrary.simpleMessage("Отвязка"),
    "g_face_match_key34": MessageLookupByLibrary.simpleMessage(
      "Верификация биометрических данных лица не удалась!",
    ),
    "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
      "Отвязка биометрических данных лица не удалась!",
    ),
    "g_face_match_key4": m7,
    "g_face_match_key5": MessageLookupByLibrary.simpleMessage("Ошибка адреса!"),
    "g_face_match_key6": MessageLookupByLibrary.simpleMessage(
      "Привязка биометрических данных лица",
    ),
    "g_face_match_key7": MessageLookupByLibrary.simpleMessage(
      "Сопоставление лица",
    ),
    "g_face_match_key8": MessageLookupByLibrary.simpleMessage("Выбрать заново"),
    "g_face_match_key9": MessageLookupByLibrary.simpleMessage("Сопоставить"),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Профиль"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("Новости"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Верификация"),
    "g_home_key5": MessageLookupByLibrary.simpleMessage("Сообщения"),
    "g_home_key6": MessageLookupByLibrary.simpleMessage("Обучение"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Пригласить друга"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("Не удалось удалить!"),
    "g_key_100": MessageLookupByLibrary.simpleMessage("Отправить"),
    "g_key_101": MessageLookupByLibrary.simpleMessage("Лимит газа"),
    "g_key_105": MessageLookupByLibrary.simpleMessage("Больше нет"),
    "g_key_106": MessageLookupByLibrary.simpleMessage("Загрузка "),
    "g_key_108": MessageLookupByLibrary.simpleMessage("Адресная книга"),
    "g_key_11": MessageLookupByLibrary.simpleMessage("Импортировать кошелёк"),
    "g_key_110": MessageLookupByLibrary.simpleMessage("Управление"),
    "g_key_112": MessageLookupByLibrary.simpleMessage("Новый адрес"),
    "g_key_113": MessageLookupByLibrary.simpleMessage("Удалить"),
    "g_key_115": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "g_key_119": MessageLookupByLibrary.simpleMessage("Копировать"),
    "g_key_12": MessageLookupByLibrary.simpleMessage(
      "Создать/Импортировать кошелёк",
    ),
    "g_key_126": MessageLookupByLibrary.simpleMessage("Тема"),
    "g_key_127": MessageLookupByLibrary.simpleMessage("Системная"),
    "g_key_128": MessageLookupByLibrary.simpleMessage("Светлая"),
    "g_key_129": MessageLookupByLibrary.simpleMessage("Тёмная"),
    "g_key_13": MessageLookupByLibrary.simpleMessage("Список кошельков"),
    "g_key_132": MessageLookupByLibrary.simpleMessage("Нет данных"),
    "g_key_134": MessageLookupByLibrary.simpleMessage("Некорректная сумма"),
    "g_key_135": m8,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Основной кошелёк"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("Транзакция успешна"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Неверный пароль"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("Тестовая сеть"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Основная сеть"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("Системный язык"),
    "g_key_15": MessageLookupByLibrary.simpleMessage(
      "Установить как основной кошелёк",
    ),
    "g_key_154": MessageLookupByLibrary.simpleMessage("Отправить"),
    "g_key_155": MessageLookupByLibrary.simpleMessage("Адрес кошелька"),
    "g_key_156": MessageLookupByLibrary.simpleMessage(
      "Сканируйте для копирования адреса",
    ),
    "g_key_159": MessageLookupByLibrary.simpleMessage("Добавить"),
    "g_key_16": MessageLookupByLibrary.simpleMessage(
      "Выбрать кошелёк для верификации",
    ),
    "g_key_163": MessageLookupByLibrary.simpleMessage("Символ"),
    "g_key_166": MessageLookupByLibrary.simpleMessage("Вставить"),
    "g_key_17": MessageLookupByLibrary.simpleMessage("Выбрать сеть"),
    "g_key_175": MessageLookupByLibrary.simpleMessage("Транзакция не удалась"),
    "g_key_179": MessageLookupByLibrary.simpleMessage("Это мой адрес кошелька"),
    "g_key_181": MessageLookupByLibrary.simpleMessage("Другое"),
    "g_key_185": MessageLookupByLibrary.simpleMessage("Успешно сохранено"),
    "g_key_191": MessageLookupByLibrary.simpleMessage("Успешно"),
    "g_key_192": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите удалить кошелёк?",
    ),
    "g_key_193": MessageLookupByLibrary.simpleMessage("Активен"),
    "g_key_195": MessageLookupByLibrary.simpleMessage("Нет доступа к камере."),
    "g_key_196": MessageLookupByLibrary.simpleMessage("Обозреватель"),
    "g_key_197": MessageLookupByLibrary.simpleMessage("Макс"),
    "g_key_198": MessageLookupByLibrary.simpleMessage("Активы"),
    "g_key_2": MessageLookupByLibrary.simpleMessage("Реестр пуст!"),
    "g_key_202": MessageLookupByLibrary.simpleMessage("Обзор транзакции"),
    "g_key_203": MessageLookupByLibrary.simpleMessage(
      "Ошибка соединения, отсканируйте QR-код повторно.",
    ),
    "g_key_205": MessageLookupByLibrary.simpleMessage(
      "Нет доступа к фотоальбому.",
    ),
    "g_key_206": MessageLookupByLibrary.simpleMessage("Изменение пароля"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("Старый пароль"),
    "g_key_208": MessageLookupByLibrary.simpleMessage(
      "Синхронизация балансов...",
    ),
    "g_key_209": MessageLookupByLibrary.simpleMessage("Приватный ключ"),
    "g_key_21": MessageLookupByLibrary.simpleMessage("Введите пароль кошелька"),
    "g_key_210": MessageLookupByLibrary.simpleMessage(
      "Ошибка приватного ключа",
    ),
    "g_key_211": MessageLookupByLibrary.simpleMessage("Купить"),
    "g_key_212": MessageLookupByLibrary.simpleMessage("Продать"),
    "g_key_213": MessageLookupByLibrary.simpleMessage("Информация о рынке"),
    "g_key_214": m9,
    "g_key_25": MessageLookupByLibrary.simpleMessage("Пароли не совпадают."),
    "g_key_29": MessageLookupByLibrary.simpleMessage("Баланс"),
    "g_key_3": MessageLookupByLibrary.simpleMessage("Не удалось добавить!"),
    "g_key_33": MessageLookupByLibrary.simpleMessage("Получить"),
    "g_key_37": MessageLookupByLibrary.simpleMessage("Перевод"),
    "g_key_38": MessageLookupByLibrary.simpleMessage("Кому"),
    "g_key_4": MessageLookupByLibrary.simpleMessage("Сканировать QR-код"),
    "g_key_41": MessageLookupByLibrary.simpleMessage("Введите адрес кошелька"),
    "g_key_43": MessageLookupByLibrary.simpleMessage("Доступный баланс"),
    "g_key_44": MessageLookupByLibrary.simpleMessage("Сумма"),
    "g_key_46": m10,
    "g_key_47": MessageLookupByLibrary.simpleMessage(
      "Недостаточно средств для проведения транзакции.",
    ),
    "g_key_48": MessageLookupByLibrary.simpleMessage("Отправить"),
    "g_key_5": MessageLookupByLibrary.simpleMessage("Не удалось загрузить!"),
    "g_key_6": MessageLookupByLibrary.simpleMessage("Кошелёк"),
    "g_key_7": MessageLookupByLibrary.simpleMessage("Создать"),
    "g_key_75": MessageLookupByLibrary.simpleMessage("От"),
    "g_key_78": MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "g_key_79": MessageLookupByLibrary.simpleMessage("Отмена"),
    "g_key_8": MessageLookupByLibrary.simpleMessage("Примечание"),
    "g_key_85": MessageLookupByLibrary.simpleMessage("Сид-фраза"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("Все токены"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("Настройки"),
    "g_key_aa_account_created": MessageLookupByLibrary.simpleMessage(
      "Account Created Successfully",
    ),
    "g_key_aa_account_details": MessageLookupByLibrary.simpleMessage(
      "Account Details",
    ),
    "g_key_aa_account_name": MessageLookupByLibrary.simpleMessage(
      "Account Name",
    ),
    "g_key_aa_account_name_hint": MessageLookupByLibrary.simpleMessage(
      "Enter account name",
    ),
    "g_key_aa_account_type": MessageLookupByLibrary.simpleMessage(
      "Account Type",
    ),
    "g_key_aa_active": MessageLookupByLibrary.simpleMessage("Active"),
    "g_key_aa_add_first_operation": MessageLookupByLibrary.simpleMessage(
      "Add your first operation",
    ),
    "g_key_aa_add_operation": MessageLookupByLibrary.simpleMessage(
      "Add Operation",
    ),
    "g_key_aa_address_calculating": MessageLookupByLibrary.simpleMessage(
      "Вычисление адреса...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "Не удалось вычислить адрес. Попробуйте ещё раз.",
    ),
    "g_key_aa_address_preview": MessageLookupByLibrary.simpleMessage(
      "This address is pre-computed and will be deployed when you make your first transaction.",
    ),
    "g_key_aa_approve": MessageLookupByLibrary.simpleMessage("Approve"),
    "g_key_aa_batch": MessageLookupByLibrary.simpleMessage("Batch"),
    "g_key_aa_batch_atomic": MessageLookupByLibrary.simpleMessage(
      "Atomic Execution",
    ),
    "g_key_aa_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Execute multiple operations at once",
    ),
    "g_key_aa_batch_description": MessageLookupByLibrary.simpleMessage(
      "Send multiple transactions in a single operation",
    ),
    "g_key_aa_batch_failed": MessageLookupByLibrary.simpleMessage(
      "Batch execution failed",
    ),
    "g_key_aa_batch_no_templates": MessageLookupByLibrary.simpleMessage(
      "No saved templates",
    ),
    "g_key_aa_batch_operations": MessageLookupByLibrary.simpleMessage(
      "Batch Operations",
    ),
    "g_key_aa_batch_save_gas": MessageLookupByLibrary.simpleMessage("Save Gas"),
    "g_key_aa_batch_save_template": MessageLookupByLibrary.simpleMessage(
      "Save as Template",
    ),
    "g_key_aa_batch_submitting": MessageLookupByLibrary.simpleMessage(
      "Submitting...",
    ),
    "g_key_aa_batch_success": MessageLookupByLibrary.simpleMessage(
      "Batch submitted successfully",
    ),
    "g_key_aa_batch_template_load": MessageLookupByLibrary.simpleMessage(
      "Load Template",
    ),
    "g_key_aa_batch_template_name": MessageLookupByLibrary.simpleMessage(
      "Template Name",
    ),
    "g_key_aa_batch_template_name_hint": MessageLookupByLibrary.simpleMessage(
      "Enter template name",
    ),
    "g_key_aa_batch_template_saved": MessageLookupByLibrary.simpleMessage(
      "Template saved",
    ),
    "g_key_aa_batch_templates": MessageLookupByLibrary.simpleMessage(
      "Templates",
    ),
    "g_key_aa_batch_title": MessageLookupByLibrary.simpleMessage(
      "Batch Transfer",
    ),
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage(
      "Batch Transaction",
    ),
    "g_key_aa_biconomy_account": MessageLookupByLibrary.simpleMessage(
      "Аккаунт Biconomy",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "Модульный смарт-аккаунт ERC-7579 с поддержкой транзакций без газа",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("by"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("Chain"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage("Chain ID"),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("Change"),
    "g_key_aa_clear_all": MessageLookupByLibrary.simpleMessage("Clear All"),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage("Coming Soon"),
    "g_key_aa_continue": MessageLookupByLibrary.simpleMessage("Continue"),
    "g_key_aa_contract": MessageLookupByLibrary.simpleMessage("Contract"),
    "g_key_aa_counterfactual_address": MessageLookupByLibrary.simpleMessage(
      "Counterfactual Address",
    ),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "This is a counterfactual address. It will be deployed on your first transaction.",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "Create Smart Account",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "Create your first smart account",
    ),
    "g_key_aa_create_first_account": MessageLookupByLibrary.simpleMessage(
      "Create a smart account to get started",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "Create Session Key",
    ),
    "g_key_aa_create_session_desc": MessageLookupByLibrary.simpleMessage(
      "Session keys allow DApps to execute transactions on your behalf with limited permissions and time constraints.",
    ),
    "g_key_aa_create_smart_account": MessageLookupByLibrary.simpleMessage(
      "Create Smart Account",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("Created"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "g_key_aa_deploy": MessageLookupByLibrary.simpleMessage("Deploy"),
    "g_key_aa_deploy_failed": MessageLookupByLibrary.simpleMessage(
      "Deploy Failed",
    ),
    "g_key_aa_deploy_failed_desc": MessageLookupByLibrary.simpleMessage(
      "Deployment failed. Please try again.",
    ),
    "g_key_aa_deploy_started": MessageLookupByLibrary.simpleMessage(
      "Deployment started",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("Deployed"),
    "g_key_aa_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "Account is ready to use",
    ),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage("Deploying..."),
    "g_key_aa_deploying_desc": MessageLookupByLibrary.simpleMessage(
      "Deployment transaction is being processed",
    ),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "Deployment will occur automatically with your first transaction.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "Experience the next generation of Ethereum accounts with enhanced features",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("Details"),
    "g_key_aa_eip7702_account": MessageLookupByLibrary.simpleMessage(
      "EIP-7702 Account",
    ),
    "g_key_aa_eip7702_badge": MessageLookupByLibrary.simpleMessage("EIP-7702"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "Hybrid EOA/Smart Account - No deployment needed",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("Error"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "Estimated Gas",
    ),
    "g_key_aa_estimating": MessageLookupByLibrary.simpleMessage(
      "Estimating...",
    ),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage(
      "Execute Batch",
    ),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("Expired"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage("Expires"),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("Factory"),
    "g_key_aa_feature_batch": MessageLookupByLibrary.simpleMessage(
      "Batch multiple transactions",
    ),
    "g_key_aa_feature_gas": MessageLookupByLibrary.simpleMessage(
      "Pay gas in any token",
    ),
    "g_key_aa_feature_security": MessageLookupByLibrary.simpleMessage(
      "Enhanced security",
    ),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("FREE"),
    "g_key_aa_full_access": MessageLookupByLibrary.simpleMessage("Full Access"),
    "g_key_aa_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Gas Estimate",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage("Gas Payment"),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Gas Payment Options",
    ),
    "g_key_aa_gas_savings": MessageLookupByLibrary.simpleMessage("Gas Savings"),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "Gas Sponsored",
    ),
    "g_key_aa_gas_warn_call_high": MessageLookupByLibrary.simpleMessage(
      "Газ выполнения высокий",
    ),
    "g_key_aa_gas_warn_call_high_desc": m11,
    "g_key_aa_gas_warn_deploy": MessageLookupByLibrary.simpleMessage(
      "Накладные расходы газа развёртывания",
    ),
    "g_key_aa_gas_warn_deploy_desc": m12,
    "g_key_aa_gas_warn_paymaster": MessageLookupByLibrary.simpleMessage(
      "Высокие накладные расходы Paymaster",
    ),
    "g_key_aa_gas_warn_paymaster_desc": m13,
    "g_key_aa_gas_warn_total_high": MessageLookupByLibrary.simpleMessage(
      "Лимит газа очень высокий",
    ),
    "g_key_aa_gas_warn_total_high_desc": m14,
    "g_key_aa_gas_warn_under_est": MessageLookupByLibrary.simpleMessage(
      "Возможная недооценка газа",
    ),
    "g_key_aa_gas_warn_under_est_desc": MessageLookupByLibrary.simpleMessage(
      "Фактически использованный газ может превысить оценку. Рассмотрите добавление большего буфера.",
    ),
    "g_key_aa_gas_warn_verify_high": MessageLookupByLibrary.simpleMessage(
      "Газ верификации высокий",
    ),
    "g_key_aa_gas_warn_verify_high_desc": m15,
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("Gasless"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "Gasless transactions & batch operations",
    ),
    "g_key_aa_home_title": MessageLookupByLibrary.simpleMessage(
      "Account Abstraction",
    ),
    "g_key_aa_just_now": MessageLookupByLibrary.simpleMessage("Just now"),
    "g_key_aa_kernel_account": MessageLookupByLibrary.simpleMessage(
      "Kernel Account",
    ),
    "g_key_aa_kernel_desc": MessageLookupByLibrary.simpleMessage(
      "Modular account with plugin support from ZeroDev",
    ),
    "g_key_aa_label": MessageLookupByLibrary.simpleMessage("Label"),
    "g_key_aa_last_activity": MessageLookupByLibrary.simpleMessage(
      "Last Activity",
    ),
    "g_key_aa_my_accounts": MessageLookupByLibrary.simpleMessage(
      "My Smart Accounts",
    ),
    "g_key_aa_never": MessageLookupByLibrary.simpleMessage("Never"),
    "g_key_aa_no_accounts": MessageLookupByLibrary.simpleMessage(
      "No smart accounts yet",
    ),
    "g_key_aa_no_accounts_filter": MessageLookupByLibrary.simpleMessage(
      "No accounts match your filter",
    ),
    "g_key_aa_no_operations": MessageLookupByLibrary.simpleMessage(
      "No operations added",
    ),
    "g_key_aa_no_session_keys": MessageLookupByLibrary.simpleMessage(
      "No session keys",
    ),
    "g_key_aa_not_deployed": MessageLookupByLibrary.simpleMessage(
      "Not Deployed",
    ),
    "g_key_aa_not_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "Account will be deployed on first transaction",
    ),
    "g_key_aa_operations": MessageLookupByLibrary.simpleMessage("Operations"),
    "g_key_aa_owner": MessageLookupByLibrary.simpleMessage("Owner"),
    "g_key_aa_pay_gas_with_token": MessageLookupByLibrary.simpleMessage(
      "Pay gas with token",
    ),
    "g_key_aa_pay_gas_yourself": MessageLookupByLibrary.simpleMessage(
      "Pay gas with your ETH",
    ),
    "g_key_aa_pay_with": MessageLookupByLibrary.simpleMessage("Pay with"),
    "g_key_aa_pay_with_eth": MessageLookupByLibrary.simpleMessage(
      "Pay with ETH",
    ),
    "g_key_aa_paymaster_balance": MessageLookupByLibrary.simpleMessage(
      "Баланс",
    ),
    "g_key_aa_paymaster_chains_supported": MessageLookupByLibrary.simpleMessage(
      "сетей поддерживается",
    ),
    "g_key_aa_paymaster_checking": MessageLookupByLibrary.simpleMessage(
      "Проверка доступности...",
    ),
    "g_key_aa_paymaster_coverage": MessageLookupByLibrary.simpleMessage(
      "Охват сетей",
    ),
    "g_key_aa_paymaster_description": MessageLookupByLibrary.simpleMessage(
      "Choose how you want to pay for transaction gas fees",
    ),
    "g_key_aa_paymaster_est_cost": MessageLookupByLibrary.simpleMessage(
      "Прим. стоимость",
    ),
    "g_key_aa_paymaster_load_failed": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить опции газа",
    ),
    "g_key_aa_paymaster_not_supported": MessageLookupByLibrary.simpleMessage(
      "Недоступно в этой сети",
    ),
    "g_key_aa_paymaster_quote_expired": MessageLookupByLibrary.simpleMessage(
      "Котировка устарела",
    ),
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage(
      "Повторить",
    ),
    "g_key_aa_paymaster_sponsored_unavailable":
        MessageLookupByLibrary.simpleMessage("Спонсорство недоступно"),
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("Pending"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("Permission"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "Preview Address",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("Ready"),
    "g_key_aa_recommended": MessageLookupByLibrary.simpleMessage("Recommended"),
    "g_key_aa_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "g_key_aa_revoke": MessageLookupByLibrary.simpleMessage("Revoke"),
    "g_key_aa_revoke_confirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to revoke this session key? The authorized DApp will no longer be able to execute transactions.",
    ),
    "g_key_aa_revoke_session": MessageLookupByLibrary.simpleMessage(
      "Revoke Session Key",
    ),
    "g_key_aa_revoked": MessageLookupByLibrary.simpleMessage(
      "Session key revoked",
    ),
    "g_key_aa_revoked_status": MessageLookupByLibrary.simpleMessage("Revoked"),
    "g_key_aa_revoking": MessageLookupByLibrary.simpleMessage(
      "Revoking session key...",
    ),
    "g_key_aa_safe_account": MessageLookupByLibrary.simpleMessage(
      "Safe Account",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "Multi-signature account with advanced security features",
    ),
    "g_key_aa_safe_guardians": MessageLookupByLibrary.simpleMessage(
      "Хранители",
    ),
    "g_key_aa_safe_threshold": MessageLookupByLibrary.simpleMessage("Порог"),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("saved"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "Select Chain",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Select Paymaster",
    ),
    "g_key_aa_select_type": MessageLookupByLibrary.simpleMessage(
      "Select Account Type",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "Send tokens using your smart account",
    ),
    "g_key_aa_send_title": MessageLookupByLibrary.simpleMessage("AA Transfer"),
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1 день"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1 час"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30 дней"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7 дней"),
    "g_key_aa_session_allowed": MessageLookupByLibrary.simpleMessage(
      "Разрешено",
    ),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "напр. 100.00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "Макс. сумма",
    ),
    "g_key_aa_session_blocked": MessageLookupByLibrary.simpleMessage(
      "Заблокировано",
    ),
    "g_key_aa_session_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Я понимаю разрешения этого ключа",
    ),
    "g_key_aa_session_contract_can": MessageLookupByLibrary.simpleMessage(
      "Взаимодействовать с одобренными контрактами DApp",
    ),
    "g_key_aa_session_create_failed": MessageLookupByLibrary.simpleMessage(
      "Не удалось создать ключ сессии",
    ),
    "g_key_aa_session_create_success": MessageLookupByLibrary.simpleMessage(
      "Ключ сессии создан",
    ),
    "g_key_aa_session_dapp_hint": MessageLookupByLibrary.simpleMessage(
      "напр. Uniswap, Aave...",
    ),
    "g_key_aa_session_dapp_label": MessageLookupByLibrary.simpleMessage(
      "Метка / Имя DApp",
    ),
    "g_key_aa_session_details": MessageLookupByLibrary.simpleMessage(
      "Session Key Details",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage(
      "Действительно в течение",
    ),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "Высокий риск — только проверенные DApp",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage(
      "Session Keys",
    ),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "Authorize DApps with temporary access to your smart account",
    ),
    "g_key_aa_session_preset_contract": MessageLookupByLibrary.simpleMessage(
      "Доступ DApp",
    ),
    "g_key_aa_session_preset_full": MessageLookupByLibrary.simpleMessage(
      "Полный контроль",
    ),
    "g_key_aa_session_preset_transfer": MessageLookupByLibrary.simpleMessage(
      "Только отправка",
    ),
    "g_key_aa_session_risk_high": MessageLookupByLibrary.simpleMessage(
      "Высокий риск",
    ),
    "g_key_aa_session_risk_low": MessageLookupByLibrary.simpleMessage(
      "Низкий риск",
    ),
    "g_key_aa_session_risk_medium": MessageLookupByLibrary.simpleMessage(
      "Средний риск",
    ),
    "g_key_aa_session_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Проверьте разрешения перед подтверждением",
    ),
    "g_key_aa_session_select_preset": MessageLookupByLibrary.simpleMessage(
      "Выбрать уровень разрешений",
    ),
    "g_key_aa_session_transfer_can": MessageLookupByLibrary.simpleMessage(
      "Переводить токены в пределах лимита",
    ),
    "g_key_aa_simple_account": MessageLookupByLibrary.simpleMessage(
      "Simple Account",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "Basic smart account with single owner - recommended for most users",
    ),
    "g_key_aa_smart_account": MessageLookupByLibrary.simpleMessage(
      "Smart Account",
    ),
    "g_key_aa_smart_accounts": MessageLookupByLibrary.simpleMessage(
      "Smart Accounts",
    ),
    "g_key_aa_smart_wallet": MessageLookupByLibrary.simpleMessage(
      "Smart Wallet",
    ),
    "g_key_aa_spending_limit": MessageLookupByLibrary.simpleMessage(
      "Spending Limit",
    ),
    "g_key_aa_sponsored": MessageLookupByLibrary.simpleMessage(
      "Sponsored (Free)",
    ),
    "g_key_aa_title": MessageLookupByLibrary.simpleMessage("Smart Account"),
    "g_key_aa_total_gas": MessageLookupByLibrary.simpleMessage("Total Gas"),
    "g_key_aa_total_value": MessageLookupByLibrary.simpleMessage("Total Value"),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage(
      "Transactions",
    ),
    "g_key_aa_unavailable": MessageLookupByLibrary.simpleMessage("Unavailable"),
    "g_key_aa_version_v07": MessageLookupByLibrary.simpleMessage("v0.7"),
    "g_key_aa_version_v08": MessageLookupByLibrary.simpleMessage("v0.8"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage("View All"),
    "g_key_account_linked": MessageLookupByLibrary.simpleMessage(
      "Account linked successfully",
    ),
    "g_key_account_unlinked": MessageLookupByLibrary.simpleMessage(
      "Account unlinked successfully",
    ),
    "g_key_address": MessageLookupByLibrary.simpleMessage("Адрес"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage("Введите имя"),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage("Введите адрес"),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage(
      "Выберите тип монеты",
    ),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage(
      "Редактировать адрес",
    ),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage("Успешно удалено"),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage("Выбрать монеты"),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage("Поиск монет"),
    "g_key_advanced_features": MessageLookupByLibrary.simpleMessage(
      "Advanced Features",
    ),
    "g_key_airdrop_active": MessageLookupByLibrary.simpleMessage("Активный"),
    "g_key_airdrop_check_eligibility": MessageLookupByLibrary.simpleMessage(
      "Проверить соответствие",
    ),
    "g_key_airdrop_claim": MessageLookupByLibrary.simpleMessage("Получить"),
    "g_key_airdrop_claimed": MessageLookupByLibrary.simpleMessage("Получено"),
    "g_key_airdrop_days_left": m16,
    "g_key_airdrop_deadline": MessageLookupByLibrary.simpleMessage("Срок"),
    "g_key_airdrop_eligible": MessageLookupByLibrary.simpleMessage("Подходит"),
    "g_key_airdrop_estimated_value": MessageLookupByLibrary.simpleMessage(
      "Оценочная стоимость",
    ),
    "g_key_airdrop_expired": MessageLookupByLibrary.simpleMessage("Истёк"),
    "g_key_airdrop_filter": MessageLookupByLibrary.simpleMessage("Фильтр"),
    "g_key_airdrop_no_airdrops": MessageLookupByLibrary.simpleMessage(
      "Нет доступных airdrop",
    ),
    "g_key_airdrop_not_eligible": MessageLookupByLibrary.simpleMessage(
      "Не подходит",
    ),
    "g_key_airdrop_pending": MessageLookupByLibrary.simpleMessage("Ожидание"),
    "g_key_airdrop_priority_high": MessageLookupByLibrary.simpleMessage(
      "Высокий приоритет",
    ),
    "g_key_airdrop_priority_low": MessageLookupByLibrary.simpleMessage(
      "Низкий приоритет",
    ),
    "g_key_airdrop_priority_medium": MessageLookupByLibrary.simpleMessage(
      "Средний приоритет",
    ),
    "g_key_airdrop_requirement_met": MessageLookupByLibrary.simpleMessage(
      "Требование выполнено",
    ),
    "g_key_airdrop_requirement_not_met": MessageLookupByLibrary.simpleMessage(
      "Не выполнено",
    ),
    "g_key_airdrop_requirements": MessageLookupByLibrary.simpleMessage(
      "Требования",
    ),
    "g_key_airdrop_sort_by": MessageLookupByLibrary.simpleMessage("Сортировка"),
    "g_key_airdrop_title": MessageLookupByLibrary.simpleMessage(
      "Отслеживание Airdrop",
    ),
    "g_key_airdrop_total_claimed": MessageLookupByLibrary.simpleMessage(
      "Всего получено",
    ),
    "g_key_airdrop_upcoming": MessageLookupByLibrary.simpleMessage("Скоро"),
    "g_key_apple_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Apple sign-in cancelled",
    ),
    "g_key_apply": MessageLookupByLibrary.simpleMessage("Apply"),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage(
      "Добавить получателя",
    ),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage(
      "Broadcasting...",
    ),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage(
      "Очистить всё",
    ),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirm Batch Transfer",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("Continue"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "Формат CSV: адрес,сумма,метка",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("Done"),
    "g_key_batch_duplicate_address": m17,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Estimating Gas...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "Batch transfer supports EVM chains only",
    ),
    "g_key_batch_execute": MessageLookupByLibrary.simpleMessage(
      "Выполнить пакет",
    ),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage(
      "Экспорт CSV",
    ),
    "g_key_batch_gas_savings": MessageLookupByLibrary.simpleMessage(
      "Экономия Gas",
    ),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "Batch Transfer Help",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "Импорт CSV",
    ),
    "g_key_batch_invalid_address": m18,
    "g_key_batch_invalid_amount": m19,
    "g_key_batch_max_recipients": m20,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "Memo is optional",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Use Multicall3 for lower gas fees",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "No supported tokens",
    ),
    "g_key_batch_preview": MessageLookupByLibrary.simpleMessage("Предпросмотр"),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage(
      "Получатели",
    ),
    "g_key_batch_select_token": MessageLookupByLibrary.simpleMessage(
      "Select Token",
    ),
    "g_key_batch_send_multiple": MessageLookupByLibrary.simpleMessage(
      "Send tokens to multiple addresses in one transaction",
    ),
    "g_key_batch_signing": MessageLookupByLibrary.simpleMessage("Signing..."),
    "g_key_batch_swipe_remove": MessageLookupByLibrary.simpleMessage(
      "Swipe left to remove a recipient",
    ),
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage(
      "Пакетный перевод",
    ),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage(
      "Общая сумма",
    ),
    "g_key_bridge_amount": MessageLookupByLibrary.simpleMessage("Сумма"),
    "g_key_bridge_cheapest": MessageLookupByLibrary.simpleMessage(
      "Самый дешёвый",
    ),
    "g_key_bridge_estimated_receive": MessageLookupByLibrary.simpleMessage(
      "Вы получите (примерно)",
    ),
    "g_key_bridge_fastest": MessageLookupByLibrary.simpleMessage(
      "Самый быстрый",
    ),
    "g_key_bridge_fee": MessageLookupByLibrary.simpleMessage("Комиссия моста"),
    "g_key_bridge_from_chain": MessageLookupByLibrary.simpleMessage("Из сети"),
    "g_key_bridge_get_quote": MessageLookupByLibrary.simpleMessage(
      "Получить расчёт",
    ),
    "g_key_bridge_history": MessageLookupByLibrary.simpleMessage(
      "История мостов",
    ),
    "g_key_bridge_no_routes": MessageLookupByLibrary.simpleMessage(
      "Маршруты недоступны",
    ),
    "g_key_bridge_recommended": MessageLookupByLibrary.simpleMessage(
      "Рекомендуемый",
    ),
    "g_key_bridge_refresh": MessageLookupByLibrary.simpleMessage("Обновить"),
    "g_key_bridge_route": MessageLookupByLibrary.simpleMessage("Маршрут"),
    "g_key_bridge_search_chain": MessageLookupByLibrary.simpleMessage(
      "Поиск сети...",
    ),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage(
      "Выбрать токен",
    ),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage(
      "Проскальзывание",
    ),
    "g_key_bridge_swap": MessageLookupByLibrary.simpleMessage("Мост"),
    "g_key_bridge_time": MessageLookupByLibrary.simpleMessage(
      "Ожидаемое время",
    ),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("Мост"),
    "g_key_bridge_to_chain": MessageLookupByLibrary.simpleMessage("В сеть"),
    "g_key_bridge_tx_failed": MessageLookupByLibrary.simpleMessage(
      "Мост не удался",
    ),
    "g_key_bridge_tx_pending": MessageLookupByLibrary.simpleMessage(
      "Транзакция в обработке",
    ),
    "g_key_bridge_tx_success": MessageLookupByLibrary.simpleMessage(
      "Мост выполнен",
    ),
    "g_key_burn_got_it": MessageLookupByLibrary.simpleMessage("Got it"),
    "g_key_burn_nft_step1": MessageLookupByLibrary.simpleMessage(
      "1. Select a token with NFT support",
    ),
    "g_key_burn_nft_step2": MessageLookupByLibrary.simpleMessage(
      "2. Go to NFT tab",
    ),
    "g_key_burn_nft_step3": MessageLookupByLibrary.simpleMessage(
      "3. Select the NFT you want to burn",
    ),
    "g_key_burn_nft_step4": MessageLookupByLibrary.simpleMessage(
      "4. Tap \"Burn\" button",
    ),
    "g_key_burn_nft_steps": MessageLookupByLibrary.simpleMessage("Steps:"),
    "g_key_burn_nft_tip": MessageLookupByLibrary.simpleMessage(
      "To burn an NFT, please go to the NFT details page and tap the \"Burn\" button.",
    ),
    "g_key_burn_nft_title": MessageLookupByLibrary.simpleMessage("Burn NFT"),
    "g_key_change_email": MessageLookupByLibrary.simpleMessage("Change Email"),
    "g_key_change_password": MessageLookupByLibrary.simpleMessage(
      "Change Password",
    ),
    "g_key_change_password_desc": MessageLookupByLibrary.simpleMessage(
      "Enter your current password and set a new password",
    ),
    "g_key_code_length": MessageLookupByLibrary.simpleMessage(
      "Please enter 6-digit code",
    ),
    "g_key_code_required": MessageLookupByLibrary.simpleMessage(
      "Verification code is required",
    ),
    "g_key_code_sent": MessageLookupByLibrary.simpleMessage(
      "Verification code sent",
    ),
    "g_key_confirm_new_password": MessageLookupByLibrary.simpleMessage(
      "Confirm New Password",
    ),
    "g_key_continue_with_apple": MessageLookupByLibrary.simpleMessage(
      "Continue with Apple",
    ),
    "g_key_continue_with_google": MessageLookupByLibrary.simpleMessage(
      "Continue with Google",
    ),
    "g_key_deadline_reminders": MessageLookupByLibrary.simpleMessage(
      "Deadline reminders",
    ),
    "g_key_dex_best_route": MessageLookupByLibrary.simpleMessage(
      "Лучший Маршрут",
    ),
    "g_key_dex_best_source": MessageLookupByLibrary.simpleMessage(
      "Лучший Источник",
    ),
    "g_key_dex_chain": MessageLookupByLibrary.simpleMessage("Сеть"),
    "g_key_dex_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Подтвердить Своп",
    ),
    "g_key_dex_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Оценка Газа",
    ),
    "g_key_dex_history_title": MessageLookupByLibrary.simpleMessage(
      "История DEX",
    ),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage(
      "Токены отсутствуют",
    ),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "Токены не найдены",
    ),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage(
      "Влияние на Цену",
    ),
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Ошибка котировки",
    ),
    "g_key_dex_retry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "Поиск по символу / имени / адресу",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage("Выбрать"),
    "g_key_dex_slippage": MessageLookupByLibrary.simpleMessage(
      "Допуск Проскальзывания",
    ),
    "g_key_dex_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Solana DEX своп пока не поддерживается в приложении",
    ),
    "g_key_dex_status_confirmed": MessageLookupByLibrary.simpleMessage(
      "Подтверждено",
    ),
    "g_key_dex_status_failed": MessageLookupByLibrary.simpleMessage(
      "Не удалось",
    ),
    "g_key_dex_status_pending": MessageLookupByLibrary.simpleMessage(
      "В ожидании",
    ),
    "g_key_dex_status_quoted": MessageLookupByLibrary.simpleMessage(
      "Котировка",
    ),
    "g_key_dex_swap_btn": MessageLookupByLibrary.simpleMessage("Обменять"),
    "g_key_dex_swap_success": MessageLookupByLibrary.simpleMessage(
      "Своп успешно отправлен",
    ),
    "g_key_dex_tx_failed": MessageLookupByLibrary.simpleMessage(
      "Транзакция не удалась",
    ),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("Вы Платите"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage(
      "Вы Получаете",
    ),
    "g_key_domain_resolve_hint": MessageLookupByLibrary.simpleMessage(
      "Поддерживает ENS (.eth), Unstoppable Domains (.crypto/.wallet/…) и Solana SNS (.sol)",
    ),
    "g_key_domain_sns_name": MessageLookupByLibrary.simpleMessage(
      "Solana Name Service",
    ),
    "g_key_domain_sns_not_found": MessageLookupByLibrary.simpleMessage(
      "Домен Solana не найден",
    ),
    "g_key_domain_ud_name": MessageLookupByLibrary.simpleMessage(
      "Unstoppable Domains",
    ),
    "g_key_domain_ud_not_found": MessageLookupByLibrary.simpleMessage(
      "Домен Unstoppable не найден или нет адреса для этой сети",
    ),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "Active Products",
    ),
    "g_key_earn_batch": MessageLookupByLibrary.simpleMessage(
      "Пакетный перевод",
    ),
    "g_key_earn_burn": MessageLookupByLibrary.simpleMessage("Сжечь"),
    "g_key_earn_buy_n": MessageLookupByLibrary.simpleMessage("Купить N"),
    "g_key_earn_buy_n_desc": MessageLookupByLibrary.simpleMessage(
      "Купить N с помощью протокола AST",
    ),
    "g_key_earn_claim_free": MessageLookupByLibrary.simpleMessage(
      "Claim free tokens",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "Cross-chain transfer",
    ),
    "g_key_earn_daily_bonus": MessageLookupByLibrary.simpleMessage(
      "Daily check-in bonus",
    ),
    "g_key_earn_dex_desc": MessageLookupByLibrary.simpleMessage(
      "Обменивайте любые токены через Uniswap / 1inch",
    ),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage("DEX обмен"),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("Газ"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage(
      "Начать стейкинг",
    ),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("Леджер"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage(
      "Загрузка APY...",
    ),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage("Майнинг"),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage("Earn More"),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "Native Solana staking",
    ),
    "g_key_earn_no_positions": MessageLookupByLibrary.simpleMessage(
      "Нет активных позиций",
    ),
    "g_key_earn_node_mining": MessageLookupByLibrary.simpleMessage(
      "Майнинг узлов",
    ),
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "Зарабатывайте вознаграждения, участвуя в майнинге узлов",
    ),
    "g_key_earn_points_daily": MessageLookupByLibrary.simpleMessage(
      "Earn points daily",
    ),
    "g_key_earn_pts_day": m21,
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage(
      "Quick Tools",
    ),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage(
      "Recommended",
    ),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage(
      "Выбрать тип обмена",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Stake ETH with Lido",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("Обменять"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("Earn"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage(
      "Total Earnings",
    ),
    "g_key_earn_up_to_apy": m22,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage("View All"),
    "g_key_eligibility_alerts": MessageLookupByLibrary.simpleMessage(
      "Eligibility alerts",
    ),
    "g_key_eligible_only": MessageLookupByLibrary.simpleMessage(
      "Eligible only",
    ),
    "g_key_email": MessageLookupByLibrary.simpleMessage("Email"),
    "g_key_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid email address",
    ),
    "g_key_email_required": MessageLookupByLibrary.simpleMessage(
      "Email is required",
    ),
    "g_key_ens_address_updated": MessageLookupByLibrary.simpleMessage(
      "Resolved address updated",
    ),
    "g_key_ens_advanced": MessageLookupByLibrary.simpleMessage("Advanced"),
    "g_key_ens_annual_fee": MessageLookupByLibrary.simpleMessage("Annual Fee"),
    "g_key_ens_available": MessageLookupByLibrary.simpleMessage("Available"),
    "g_key_ens_base_price": MessageLookupByLibrary.simpleMessage("Base Price"),
    "g_key_ens_checking": MessageLookupByLibrary.simpleMessage(
      "Checking availability...",
    ),
    "g_key_ens_commit": MessageLookupByLibrary.simpleMessage("Commit"),
    "g_key_ens_commit_failed": MessageLookupByLibrary.simpleMessage(
      "Commit failed",
    ),
    "g_key_ens_commit_tx": MessageLookupByLibrary.simpleMessage(
      "Committing transaction...",
    ),
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "Срок действия обязательства о регистрации истёк. Пожалуйста, начните процесс регистрации заново.",
    ),
    "g_key_ens_committing": MessageLookupByLibrary.simpleMessage(
      "Committing...",
    ),
    "g_key_ens_confirm_renew": MessageLookupByLibrary.simpleMessage(
      "Confirm Renewal",
    ),
    "g_key_ens_confirm_send": MessageLookupByLibrary.simpleMessage(
      "Confirm & Send",
    ),
    "g_key_ens_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirm ENS Resolution",
    ),
    "g_key_ens_copy_address": MessageLookupByLibrary.simpleMessage(
      "Адрес скопирован",
    ),
    "g_key_ens_current_expiry": MessageLookupByLibrary.simpleMessage(
      "Current Expiry",
    ),
    "g_key_ens_days_left": MessageLookupByLibrary.simpleMessage("days left"),
    "g_key_ens_description": MessageLookupByLibrary.simpleMessage(
      "Register and manage your .eth domain names",
    ),
    "g_key_ens_detected": MessageLookupByLibrary.simpleMessage(
      "ENS Name Detected",
    ),
    "g_key_ens_duration": MessageLookupByLibrary.simpleMessage(
      "Registration Period",
    ),
    "g_key_ens_edit_records": MessageLookupByLibrary.simpleMessage(
      "Edit Records",
    ),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("Expired"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage("Expires"),
    "g_key_ens_expiring_soon": MessageLookupByLibrary.simpleMessage(
      "Expiring Soon",
    ),
    "g_key_ens_extend_period": MessageLookupByLibrary.simpleMessage(
      "Extend Registration Period",
    ),
    "g_key_ens_failed": MessageLookupByLibrary.simpleMessage("Failed"),
    "g_key_ens_finalizing": MessageLookupByLibrary.simpleMessage(
      "Finalizing registration",
    ),
    "g_key_ens_get_started": MessageLookupByLibrary.simpleMessage(
      "Get started with ENS",
    ),
    "g_key_ens_get_your_name": MessageLookupByLibrary.simpleMessage(
      "Get your .eth name",
    ),
    "g_key_ens_home_title": MessageLookupByLibrary.simpleMessage("ENS Manager"),
    "g_key_ens_invalid_address": MessageLookupByLibrary.simpleMessage(
      "Invalid address (must be 0x + 40 hex chars)",
    ),
    "g_key_ens_invalid_name": MessageLookupByLibrary.simpleMessage(
      "Invalid ENS name",
    ),
    "g_key_ens_is_yours": MessageLookupByLibrary.simpleMessage("is now yours!"),
    "g_key_ens_keep_app_open": MessageLookupByLibrary.simpleMessage(
      "Please keep the app open during registration",
    ),
    "g_key_ens_manage_your_identity": MessageLookupByLibrary.simpleMessage(
      "Manage your Web3 identity",
    ),
    "g_key_ens_management_title": MessageLookupByLibrary.simpleMessage(
      "Manage ENS",
    ),
    "g_key_ens_min_length": MessageLookupByLibrary.simpleMessage(
      "Minimum 3 characters",
    ),
    "g_key_ens_my_domains": MessageLookupByLibrary.simpleMessage("My Domains"),
    "g_key_ens_name": MessageLookupByLibrary.simpleMessage("ENS Name"),
    "g_key_ens_new_expiry": MessageLookupByLibrary.simpleMessage("New Expiry"),
    "g_key_ens_new_owner": MessageLookupByLibrary.simpleMessage(
      "New Owner Address",
    ),
    "g_key_ens_no_domains": MessageLookupByLibrary.simpleMessage(
      "No domains yet",
    ),
    "g_key_ens_no_names": MessageLookupByLibrary.simpleMessage(
      "You don\'t own any ENS names yet",
    ),
    "g_key_ens_owned_names": MessageLookupByLibrary.simpleMessage(
      "My ENS Names",
    ),
    "g_key_ens_owner": MessageLookupByLibrary.simpleMessage("Owner"),
    "g_key_ens_please_wait": MessageLookupByLibrary.simpleMessage(
      "Please wait",
    ),
    "g_key_ens_premium_name": MessageLookupByLibrary.simpleMessage(
      "Premium Name",
    ),
    "g_key_ens_price_breakdown": MessageLookupByLibrary.simpleMessage(
      "Price Breakdown",
    ),
    "g_key_ens_price_per_year": MessageLookupByLibrary.simpleMessage(
      "per year",
    ),
    "g_key_ens_primary": MessageLookupByLibrary.simpleMessage("Primary"),
    "g_key_ens_primary_set": MessageLookupByLibrary.simpleMessage(
      "Primary name set successfully",
    ),
    "g_key_ens_processing": MessageLookupByLibrary.simpleMessage(
      "Processing...",
    ),
    "g_key_ens_purchase_title": MessageLookupByLibrary.simpleMessage(
      "Register ENS",
    ),
    "g_key_ens_records": MessageLookupByLibrary.simpleMessage("Records"),
    "g_key_ens_register": MessageLookupByLibrary.simpleMessage("Register"),
    "g_key_ens_register_description": MessageLookupByLibrary.simpleMessage(
      "Your decentralized identity on Ethereum",
    ),
    "g_key_ens_register_failed": MessageLookupByLibrary.simpleMessage(
      "Registration failed",
    ),
    "g_key_ens_register_now": MessageLookupByLibrary.simpleMessage(
      "Register Now",
    ),
    "g_key_ens_register_tx": MessageLookupByLibrary.simpleMessage(
      "Registering name...",
    ),
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage(
      "Registering...",
    ),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage(
      "Registration Info",
    ),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "Registration Period",
    ),
    "g_key_ens_reminder_disabled": MessageLookupByLibrary.simpleMessage(
      "Напоминание выключено",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage(
      "Включить напоминание об истечении срока",
    ),
    "g_key_ens_reminder_enabled": MessageLookupByLibrary.simpleMessage(
      "Напоминание включено",
    ),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "Уведомить за 30, 7 и 1 день до истечения срока",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("Renew"),
    "g_key_ens_renew_cost": MessageLookupByLibrary.simpleMessage(
      "Renewal Cost",
    ),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "Extend your domain registration",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "Renewal successful",
    ),
    "g_key_ens_renew_title": MessageLookupByLibrary.simpleMessage("Renew ENS"),
    "g_key_ens_resolution_failed": MessageLookupByLibrary.simpleMessage(
      "ENS resolution failed",
    ),
    "g_key_ens_resolved_address": MessageLookupByLibrary.simpleMessage(
      "Resolved Address",
    ),
    "g_key_ens_resolving": MessageLookupByLibrary.simpleMessage(
      "Resolving ENS...",
    ),
    "g_key_ens_search": MessageLookupByLibrary.simpleMessage("Search"),
    "g_key_ens_search_desc": MessageLookupByLibrary.simpleMessage(
      "Find available .eth names",
    ),
    "g_key_ens_search_hint": MessageLookupByLibrary.simpleMessage(
      "Search for a .eth name",
    ),
    "g_key_ens_search_prompt": MessageLookupByLibrary.simpleMessage(
      "Enter an ENS name to search",
    ),
    "g_key_ens_search_register": MessageLookupByLibrary.simpleMessage(
      "Search & Register",
    ),
    "g_key_ens_search_title": MessageLookupByLibrary.simpleMessage(
      "Search ENS",
    ),
    "g_key_ens_self_transfer": MessageLookupByLibrary.simpleMessage(
      "Нельзя отправить на собственный адрес",
    ),
    "g_key_ens_service": MessageLookupByLibrary.simpleMessage(
      "Ethereum Name Service",
    ),
    "g_key_ens_set_primary": MessageLookupByLibrary.simpleMessage(
      "Set as Primary",
    ),
    "g_key_ens_standard_name": MessageLookupByLibrary.simpleMessage(
      "Standard Name",
    ),
    "g_key_ens_start_registration": MessageLookupByLibrary.simpleMessage(
      "Start Registration",
    ),
    "g_key_ens_step_1": MessageLookupByLibrary.simpleMessage("Step 1"),
    "g_key_ens_step_2": MessageLookupByLibrary.simpleMessage("Step 2"),
    "g_key_ens_step_3": MessageLookupByLibrary.simpleMessage("Step 3"),
    "g_key_ens_step_commit": MessageLookupByLibrary.simpleMessage("Commit"),
    "g_key_ens_step_register": MessageLookupByLibrary.simpleMessage("Register"),
    "g_key_ens_step_success": MessageLookupByLibrary.simpleMessage("Success"),
    "g_key_ens_step_wait": MessageLookupByLibrary.simpleMessage("Wait"),
    "g_key_ens_subdomain_create": MessageLookupByLibrary.simpleMessage(
      "Create Subdomain",
    ),
    "g_key_ens_subdomain_created": MessageLookupByLibrary.simpleMessage(
      "Subdomain created",
    ),
    "g_key_ens_subdomain_delete": MessageLookupByLibrary.simpleMessage(
      "Delete Subdomain",
    ),
    "g_key_ens_subdomain_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "This subdomain will be permanently deleted.",
    ),
    "g_key_ens_subdomain_deleted": MessageLookupByLibrary.simpleMessage(
      "Subdomain deleted",
    ),
    "g_key_ens_subdomain_empty": MessageLookupByLibrary.simpleMessage(
      "No subdomains yet",
    ),
    "g_key_ens_subdomain_invalid_label": MessageLookupByLibrary.simpleMessage(
      "Use letters, numbers and hyphens only",
    ),
    "g_key_ens_subdomain_label": MessageLookupByLibrary.simpleMessage(
      "Subdomain label",
    ),
    "g_key_ens_subdomain_label_hint": MessageLookupByLibrary.simpleMessage(
      "e.g. blog, mail, app",
    ),
    "g_key_ens_subdomain_owner": MessageLookupByLibrary.simpleMessage(
      "Owner address",
    ),
    "g_key_ens_subdomain_owner_hint": MessageLookupByLibrary.simpleMessage(
      "Leave empty to use current wallet",
    ),
    "g_key_ens_subdomains": MessageLookupByLibrary.simpleMessage("Subdomains"),
    "g_key_ens_success": MessageLookupByLibrary.simpleMessage("Success!"),
    "g_key_ens_success_message": m23,
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage(
      "Suggestions",
    ),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage(
      "Text Records",
    ),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("ENS Manager"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("Total"),
    "g_key_ens_total_cost": MessageLookupByLibrary.simpleMessage("Total Cost"),
    "g_key_ens_transfer": MessageLookupByLibrary.simpleMessage("Transfer"),
    "g_key_ens_transfer_desc": MessageLookupByLibrary.simpleMessage(
      "Transfer ownership to another address",
    ),
    "g_key_ens_transfer_success": MessageLookupByLibrary.simpleMessage(
      "Transfer successful",
    ),
    "g_key_ens_transfer_warning": MessageLookupByLibrary.simpleMessage(
      "Transfer is irreversible. Make sure the new owner address is correct.",
    ),
    "g_key_ens_try_another": MessageLookupByLibrary.simpleMessage(
      "Try another name",
    ),
    "g_key_ens_two_step_process": MessageLookupByLibrary.simpleMessage(
      "ENS registration is a two-step process",
    ),
    "g_key_ens_unavailable": MessageLookupByLibrary.simpleMessage(
      "Unavailable",
    ),
    "g_key_ens_wait": MessageLookupByLibrary.simpleMessage("Wait"),
    "g_key_ens_wait_explanation": MessageLookupByLibrary.simpleMessage(
      "Waiting period prevents front-running attacks",
    ),
    "g_key_ens_wait_time_info": MessageLookupByLibrary.simpleMessage(
      "A waiting period prevents front-running",
    ),
    "g_key_ens_wait_timer": m24,
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("Waiting..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "Please verify the resolved address before proceeding. ENS names can be transferred or changed by their owner.",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("year"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("years"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "Your Identity",
    ),
    "g_key_enter_confirm_password": MessageLookupByLibrary.simpleMessage(
      "Re-enter new password",
    ),
    "g_key_enter_email": MessageLookupByLibrary.simpleMessage(
      "Enter your email address",
    ),
    "g_key_enter_new_password": MessageLookupByLibrary.simpleMessage(
      "Enter new password",
    ),
    "g_key_enter_old_password": MessageLookupByLibrary.simpleMessage(
      "Enter current password",
    ),
    "g_key_error_1": MessageLookupByLibrary.simpleMessage(
      "Ошибка парсинга данных ответа!",
    ),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("Ошибка Dio"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage(
      "Синтаксическая ошибка запроса",
    ),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage(
      "Не авторизовано, пожалуйста, войдите в систему",
    ),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage("Доступ запрещён"),
    "g_key_error_1301": MessageLookupByLibrary.simpleMessage(
      "Неверный аккаунт или пароль",
    ),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("Ошибка запроса"),
    "g_key_error_1403": MessageLookupByLibrary.simpleMessage(
      "Вы уже вошли на другом устройстве и были принудительно выведены из системы.",
    ),
    "g_key_error_15": MessageLookupByLibrary.simpleMessage(
      "Превышено время ожидания запроса",
    ),
    "g_key_error_16": MessageLookupByLibrary.simpleMessage("Сервер недоступен"),
    "g_key_error_17": MessageLookupByLibrary.simpleMessage(
      "Сервис не реализован",
    ),
    "g_key_error_18": MessageLookupByLibrary.simpleMessage("Ошибка шлюза"),
    "g_key_error_19": MessageLookupByLibrary.simpleMessage("Сервис недоступен"),
    "g_key_error_20": MessageLookupByLibrary.simpleMessage(
      "Превышено время ожидания шлюза",
    ),
    "g_key_error_21": MessageLookupByLibrary.simpleMessage(
      "Версия HTTP не поддерживается",
    ),
    "g_key_error_22": MessageLookupByLibrary.simpleMessage(
      "Запрос не выполнен, код ошибки:",
    ),
    "g_key_error_23": MessageLookupByLibrary.simpleMessage(
      "Система занята, пожалуйста, повторите попытку позже",
    ),
    "g_key_error_24": MessageLookupByLibrary.simpleMessage(
      "Слишком частые запросы",
    ),
    "g_key_error_25": MessageLookupByLibrary.simpleMessage(
      "Ошибка декодирования",
    ),
    "g_key_error_26": MessageLookupByLibrary.simpleMessage(
      "Транзакция уже в блокчейне",
    ),
    "g_key_error_27": MessageLookupByLibrary.simpleMessage(
      "Ошибка конфигурации сертификата!",
    ),
    "g_key_error_28": MessageLookupByLibrary.simpleMessage(
      "Ошибка конфигурации кода состояния!",
    ),
    "g_key_error_3": MessageLookupByLibrary.simpleMessage(
      "Неизвестная ошибка!",
    ),
    "g_key_error_4": MessageLookupByLibrary.simpleMessage(
      "Превышено время ожидания сетевого подключения, проверьте настройки сети!",
    ),
    "g_key_error_5": MessageLookupByLibrary.simpleMessage(
      "Сервер недоступен. Пожалуйста, повторите попытку позже!",
    ),
    "g_key_error_8": MessageLookupByLibrary.simpleMessage(
      "Запрос был отменён, пожалуйста, повторите запрос!",
    ),
    "g_key_ex_keystore": MessageLookupByLibrary.simpleMessage(
      "Экспорт Keystore",
    ),
    "g_key_ex_keystore_1": MessageLookupByLibrary.simpleMessage(
      "Советы по резервному копированию",
    ),
    "g_key_ex_keystore_10": MessageLookupByLibrary.simpleMessage(
      "Используйте менеджер паролей для хранения.",
    ),
    "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("Скопировано"),
    "g_key_ex_keystore_12": MessageLookupByLibrary.simpleMessage(
      "Копирование отменено",
    ),
    "g_key_ex_keystore_13": MessageLookupByLibrary.simpleMessage(
      "Идентификационный кошелёк",
    ),
    "g_key_ex_keystore_15": MessageLookupByLibrary.simpleMessage(
      "Зашифрованный файл приватного ключа.",
    ),
    "g_key_ex_keystore_16": MessageLookupByLibrary.simpleMessage(
      "Метод импорта",
    ),
    "g_key_ex_keystore_17": MessageLookupByLibrary.simpleMessage(
      "Файл Keystore",
    ),
    "g_key_ex_keystore_18": MessageLookupByLibrary.simpleMessage(
      "Введите информацию Keystore.",
    ),
    "g_key_ex_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Экспорт приватного ключа",
    ),
    "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
      "Получение Keystore и пароля даёт владельцу полный контроль над активами кошелька.",
    ),
    "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
      "Запишите внимательно и храните в безопасном месте. Хранение нескольких физических копий — самый безопасный метод.",
    ),
    "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
      "При утере приватного ключа его невозможно восстановить. Сделайте физическую резервную копию и храните её в безопасности.",
    ),
    "g_key_ex_keystore_5": MessageLookupByLibrary.simpleMessage(
      "Сохранить офлайн",
    ),
    "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
      "Не сохраняйте в небезопасных почтовых ящиках, блокнотах, облачных хранилищах или мессенджерах.",
    ),
    "g_key_ex_keystore_7": MessageLookupByLibrary.simpleMessage(
      "Используйте сетевую передачу",
    ),
    "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
      "Обязательно передавайте через сетевые инструменты. При перехвате хакерами это приведёт к невосполнимым финансовым потерям",
    ),
    "g_key_ex_keystore_9": MessageLookupByLibrary.simpleMessage(
      "Используйте инструменты для хранения",
    ),
    "g_key_feedback": MessageLookupByLibrary.simpleMessage("Обратная связь"),
    "g_key_feedback_1": MessageLookupByLibrary.simpleMessage(
      "Заполните информацию обратной связи",
    ),
    "g_key_feedback_2": MessageLookupByLibrary.simpleMessage(
      "Есть незагруженные вложения",
    ),
    "g_key_feedback_3": MessageLookupByLibrary.simpleMessage(
      "Отправка не удалась",
    ),
    "g_key_feedback_4": MessageLookupByLibrary.simpleMessage(
      "Успешно отправлено",
    ),
    "g_key_feedback_5": MessageLookupByLibrary.simpleMessage("Вложения"),
    "g_key_feedback_6": MessageLookupByLibrary.simpleMessage(
      "Загрузите до 5 вложений, каждое не более 100МБ",
    ),
    "g_key_feedback_7": MessageLookupByLibrary.simpleMessage("Неудача"),
    "g_key_feedback_8": MessageLookupByLibrary.simpleMessage(
      "Нажмите для повтора",
    ),
    "g_key_feedback_9": MessageLookupByLibrary.simpleMessage(
      "Войдите в систему",
    ),
    "g_key_filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "g_key_filter_type": MessageLookupByLibrary.simpleMessage("Type"),
    "g_key_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Forgot Password?",
    ),
    "g_key_gas_alert": MessageLookupByLibrary.simpleMessage("Gas Alert"),
    "g_key_gas_alert_above": MessageLookupByLibrary.simpleMessage(
      "Alert when above",
    ),
    "g_key_gas_alert_below": MessageLookupByLibrary.simpleMessage(
      "Alert when below",
    ),
    "g_key_gas_alert_save": MessageLookupByLibrary.simpleMessage("Save"),
    "g_key_gas_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "Threshold (Gwei)",
    ),
    "g_key_gas_auto_refresh": m25,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage(
      "Базовая комиссия",
    ),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage(
      "Пользовательский",
    ),
    "g_key_gas_estimated_time": MessageLookupByLibrary.simpleMessage(
      "Ожид. время",
    ),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("Быстро"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "Gas prices fluctuate based on network demand. Lower gas = slower confirmation, higher gas = faster confirmation.",
    ),
    "g_key_gas_max_fee": MessageLookupByLibrary.simpleMessage("Макс. комиссия"),
    "g_key_gas_network_busy": MessageLookupByLibrary.simpleMessage(
      "Сеть перегружена",
    ),
    "g_key_gas_network_idle": MessageLookupByLibrary.simpleMessage(
      "Сеть свободна",
    ),
    "g_key_gas_network_normal": MessageLookupByLibrary.simpleMessage(
      "Сеть в норме",
    ),
    "g_key_gas_price_trend": MessageLookupByLibrary.simpleMessage(
      "Price Trend",
    ),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage(
      "Приоритетная комиссия",
    ),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "Real-time Gas Prices",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage("Настройки Gas"),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("Медленно"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("Стандарт"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage("Gas Tracker"),
    "g_key_gesture_medium": MessageLookupByLibrary.simpleMessage("Средний"),
    "g_key_gesture_strong": MessageLookupByLibrary.simpleMessage("Сильный"),
    "g_key_gesture_too_simple": MessageLookupByLibrary.simpleMessage(
      "Шаблон слишком простой, добавьте больше узлов",
    ),
    "g_key_gesture_weak": MessageLookupByLibrary.simpleMessage("Слабый"),
    "g_key_google_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Google sign-in cancelled",
    ),
    "g_key_high_value_only": MessageLookupByLibrary.simpleMessage(
      "High value only",
    ),
    "g_key_hw_account_added": m26,
    "g_key_hw_accounts": MessageLookupByLibrary.simpleMessage("Аккаунты"),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("Добавить"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage(
      "Добавить аккаунт",
    ),
    "g_key_hw_add_account_content": m27,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Адрес скопирован",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Make sure your device is unlocked and Bluetooth is enabled before connecting.",
    ),
    "g_key_hw_cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage("Check App"),
    "g_key_hw_confirm_on_device": MessageLookupByLibrary.simpleMessage(
      "Подтвердите на устройстве",
    ),
    "g_key_hw_connect": MessageLookupByLibrary.simpleMessage(
      "Подключить аппаратный кошелёк",
    ),
    "g_key_hw_connect_new_device": MessageLookupByLibrary.simpleMessage(
      "Connect New Device",
    ),
    "g_key_hw_connect_new_keystone": MessageLookupByLibrary.simpleMessage(
      "Air-gap with Keystone (QR)",
    ),
    "g_key_hw_connect_new_ledger": MessageLookupByLibrary.simpleMessage(
      "Connect Ledger (Bluetooth)",
    ),
    "g_key_hw_connect_new_trezor": MessageLookupByLibrary.simpleMessage(
      "Connect Trezor (USB)",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("Connected"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage(
      "Connecting...",
    ),
    "g_key_hw_current_app_label": m28,
    "g_key_hw_days_ago": m29,
    "g_key_hw_derivation_path": MessageLookupByLibrary.simpleMessage(
      "Путь деривации",
    ),
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
    "g_key_hw_disconnected": MessageLookupByLibrary.simpleMessage("Отключено"),
    "g_key_hw_enable_bluetooth": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, включите Bluetooth",
    ),
    "g_key_hw_firmware": MessageLookupByLibrary.simpleMessage(
      "Версия прошивки",
    ),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("Назад"),
    "g_key_hw_import_failed": m30,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "Connect Keystone",
    ),
    "g_key_hw_keystone_invalid_response": MessageLookupByLibrary.simpleMessage(
      "Invalid response from Keystone device",
    ),
    "g_key_hw_keystone_scan_error": MessageLookupByLibrary.simpleMessage(
      "Failed to parse QR code. Please try again.",
    ),
    "g_key_hw_keystone_scan_request_hint": MessageLookupByLibrary.simpleMessage(
      "Scan this QR code with your Keystone device to sign the transaction",
    ),
    "g_key_hw_keystone_scan_response_hint":
        MessageLookupByLibrary.simpleMessage(
          "Point your camera at the QR code displayed on your Keystone device",
        ),
    "g_key_hw_keystone_scan_response_title":
        MessageLookupByLibrary.simpleMessage("Scan Keystone Signature"),
    "g_key_hw_keystone_scan_xpub_hint": MessageLookupByLibrary.simpleMessage(
      "Scan the QR code from your Keystone device to import accounts",
    ),
    "g_key_hw_keystone_signature_received":
        MessageLookupByLibrary.simpleMessage("Signature received successfully"),
    "g_key_hw_keystone_signing": MessageLookupByLibrary.simpleMessage(
      "Waiting for Keystone signature...",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Tap to scan Keystone response",
    ),
    "g_key_hw_last_connected": m31,
    "g_key_hw_ledger": MessageLookupByLibrary.simpleMessage("Ledger"),
    "g_key_hw_load_more": MessageLookupByLibrary.simpleMessage("Загрузить ещё"),
    "g_key_hw_loading_accounts": MessageLookupByLibrary.simpleMessage(
      "Загрузка счетов...",
    ),
    "g_key_hw_loading_hint": MessageLookupByLibrary.simpleMessage(
      "Подтвердите на устройстве, если потребуется",
    ),
    "g_key_hw_no_accounts_found": MessageLookupByLibrary.simpleMessage(
      "Счета не найдены",
    ),
    "g_key_hw_no_app_open": MessageLookupByLibrary.simpleMessage(
      "No app is currently open",
    ),
    "g_key_hw_no_devices": MessageLookupByLibrary.simpleMessage(
      "Устройства не найдены",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Устройство не подключено",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Not Connected",
    ),
    "g_key_hw_open_app": m32,
    "g_key_hw_open_ledger_app_hint": m33,
    "g_key_hw_rejected": MessageLookupByLibrary.simpleMessage(
      "Отклонено на устройстве",
    ),
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "Remove Device",
    ),
    "g_key_hw_remove_device_confirm": m34,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "Saved Devices",
    ),
    "g_key_hw_scanning": MessageLookupByLibrary.simpleMessage(
      "Поиск устройств...",
    ),
    "g_key_hw_select_device": MessageLookupByLibrary.simpleMessage(
      "Выбрать устройство",
    ),
    "g_key_hw_sign_message": MessageLookupByLibrary.simpleMessage(
      "Подписать сообщение",
    ),
    "g_key_hw_sign_tx": MessageLookupByLibrary.simpleMessage(
      "Подписать транзакцию",
    ),
    "g_key_hw_signal_strength": MessageLookupByLibrary.simpleMessage(
      "Уровень сигнала",
    ),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage(
      "Supported Devices",
    ),
    "g_key_hw_timeout": MessageLookupByLibrary.simpleMessage(
      "Тайм-аут подключения",
    ),
    "g_key_hw_title": MessageLookupByLibrary.simpleMessage(
      "Аппаратный кошелёк",
    ),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("Today"),
    "g_key_hw_trezor": MessageLookupByLibrary.simpleMessage("Trezor"),
    "g_key_hw_trezor_connect_failed": MessageLookupByLibrary.simpleMessage(
      "Failed to connect to Trezor. Make sure USB is connected.",
    ),
    "g_key_hw_trezor_connect_title": MessageLookupByLibrary.simpleMessage(
      "Connect Trezor",
    ),
    "g_key_hw_trezor_connected": MessageLookupByLibrary.simpleMessage(
      "Trezor connected successfully",
    ),
    "g_key_hw_trezor_connecting": MessageLookupByLibrary.simpleMessage(
      "Connecting to Trezor...",
    ),
    "g_key_hw_trezor_passphrase_required": MessageLookupByLibrary.simpleMessage(
      "Enter passphrase on your Trezor device",
    ),
    "g_key_hw_trezor_pin_required": MessageLookupByLibrary.simpleMessage(
      "Enter PIN on your Trezor device",
    ),
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "Connect your Trezor device via USB cable and unlock it",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage(
      "View Accounts",
    ),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage(
      "Счета Кошелька",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Кошелёк для данной валюты уже существует.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Не удалось прочитать Keystore",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("Keystore"),
    "g_key_link_account": MessageLookupByLibrary.simpleMessage("Link Account"),
    "g_key_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "Linked Accounts",
    ),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Войти"),
    "g_key_login_success": MessageLookupByLibrary.simpleMessage(
      "Login successful",
    ),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Выйти"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите выйти из приложения?",
    ),
    "g_key_loyalty_available_points": MessageLookupByLibrary.simpleMessage(
      "Доступно баллов",
    ),
    "g_key_loyalty_checked_today": MessageLookupByLibrary.simpleMessage(
      "Checked in today!",
    ),
    "g_key_loyalty_checkin_btn": MessageLookupByLibrary.simpleMessage(
      "Check In",
    ),
    "g_key_loyalty_checkin_done": MessageLookupByLibrary.simpleMessage("Done"),
    "g_key_loyalty_checkin_failed": MessageLookupByLibrary.simpleMessage(
      "Check-in failed, please try again",
    ),
    "g_key_loyalty_checkin_success": MessageLookupByLibrary.simpleMessage(
      "Check-in successful!",
    ),
    "g_key_loyalty_claim_points": MessageLookupByLibrary.simpleMessage(
      "Получить баллы",
    ),
    "g_key_loyalty_complete_failed": MessageLookupByLibrary.simpleMessage(
      "Task failed, please try again",
    ),
    "g_key_loyalty_complete_success": MessageLookupByLibrary.simpleMessage(
      "Task completed!",
    ),
    "g_key_loyalty_copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "g_key_loyalty_daily_checkin": MessageLookupByLibrary.simpleMessage(
      "Ежедневная отметка",
    ),
    "g_key_loyalty_earn_points": m35,
    "g_key_loyalty_earned": MessageLookupByLibrary.simpleMessage("Заработано"),
    "g_key_loyalty_history": MessageLookupByLibrary.simpleMessage(
      "История баллов",
    ),
    "g_key_loyalty_invite": MessageLookupByLibrary.simpleMessage("Invite"),
    "g_key_loyalty_invite_bonus": m36,
    "g_key_loyalty_invite_friends": MessageLookupByLibrary.simpleMessage(
      "Invite Friends",
    ),
    "g_key_loyalty_invited_friends": MessageLookupByLibrary.simpleMessage(
      "Приглашённые друзья",
    ),
    "g_key_loyalty_max_level": MessageLookupByLibrary.simpleMessage(
      "Max Level",
    ),
    "g_key_loyalty_next_prefix": MessageLookupByLibrary.simpleMessage("Next"),
    "g_key_loyalty_next_tier": MessageLookupByLibrary.simpleMessage(
      "След. уровень",
    ),
    "g_key_loyalty_no_rewards": MessageLookupByLibrary.simpleMessage(
      "Нет доступных наград",
    ),
    "g_key_loyalty_no_tasks": MessageLookupByLibrary.simpleMessage(
      "Нет доступных заданий",
    ),
    "g_key_loyalty_points": MessageLookupByLibrary.simpleMessage("Баллы"),
    "g_key_loyalty_points_to_next": m37,
    "g_key_loyalty_redeem": MessageLookupByLibrary.simpleMessage("Обменять"),
    "g_key_loyalty_referral": MessageLookupByLibrary.simpleMessage("Реферал"),
    "g_key_loyalty_referral_bonus": MessageLookupByLibrary.simpleMessage(
      "Реферальный бонус",
    ),
    "g_key_loyalty_referral_code": MessageLookupByLibrary.simpleMessage(
      "Ваш реферальный код",
    ),
    "g_key_loyalty_referral_link": MessageLookupByLibrary.simpleMessage(
      "Реферальная ссылка",
    ),
    "g_key_loyalty_rewards": MessageLookupByLibrary.simpleMessage("Награды"),
    "g_key_loyalty_share": MessageLookupByLibrary.simpleMessage("Share"),
    "g_key_loyalty_spent": MessageLookupByLibrary.simpleMessage("Потрачено"),
    "g_key_loyalty_task_complete": MessageLookupByLibrary.simpleMessage(
      "Задание выполнено",
    ),
    "g_key_loyalty_tasks": MessageLookupByLibrary.simpleMessage("Задания"),
    "g_key_loyalty_tier": MessageLookupByLibrary.simpleMessage("Уровень"),
    "g_key_loyalty_tier_bronze": MessageLookupByLibrary.simpleMessage("Бронза"),
    "g_key_loyalty_tier_diamond": MessageLookupByLibrary.simpleMessage(
      "Бриллиант",
    ),
    "g_key_loyalty_tier_gold": MessageLookupByLibrary.simpleMessage("Золото"),
    "g_key_loyalty_tier_platinum": MessageLookupByLibrary.simpleMessage(
      "Платина",
    ),
    "g_key_loyalty_tier_silver": MessageLookupByLibrary.simpleMessage(
      "Серебро",
    ),
    "g_key_loyalty_title": MessageLookupByLibrary.simpleMessage("Баллы"),
    "g_key_loyalty_total_earned": MessageLookupByLibrary.simpleMessage(
      "Total Earned",
    ),
    "g_key_loyalty_total_points": MessageLookupByLibrary.simpleMessage(
      "Всего баллов",
    ),
    "g_key_loyalty_used": MessageLookupByLibrary.simpleMessage("Used"),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebook"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Twitter"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("Reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("Браузер"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("Telegram"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("Discord"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("Youtube"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("Instagram"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("Рыночная капитализация"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("Объём торгов"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("Общий объём эмиссии"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("В обращении"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("О проекте"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("Ещё"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("Ссылки"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("Веб-сайт"),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage("Available"),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "Requires staking",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage("Введите сид-фразу"),
    "g_key_new_airdrops": MessageLookupByLibrary.simpleMessage("New airdrops"),
    "g_key_new_password": MessageLookupByLibrary.simpleMessage("New Password"),
    "g_key_new_password_same_as_old": MessageLookupByLibrary.simpleMessage(
      "New password must be different from current password",
    ),
    "g_key_next": MessageLookupByLibrary.simpleMessage("Next"),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Всего"),
    "g_key_nft_16": MessageLookupByLibrary.simpleMessage("Камера"),
    "g_key_nft_17": MessageLookupByLibrary.simpleMessage("Выбрать фото"),
    "g_key_nft_18": MessageLookupByLibrary.simpleMessage("Содержимое"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Название"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Назад"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage(
      "Транзакция отправлена",
    ),
    "g_key_nft_47": MessageLookupByLibrary.simpleMessage("Выбрать видео"),
    "g_key_no_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "No linked accounts",
    ),
    "g_key_notification_settings": MessageLookupByLibrary.simpleMessage(
      "Notification Settings",
    ),
    "g_key_oidc_login": MessageLookupByLibrary.simpleMessage(
      "Enterprise Login (SSO)",
    ),
    "g_key_oidc_not_configured": MessageLookupByLibrary.simpleMessage(
      "Enterprise SSO not configured",
    ),
    "g_key_old_password": MessageLookupByLibrary.simpleMessage(
      "Current Password",
    ),
    "g_key_or": MessageLookupByLibrary.simpleMessage("or"),
    "g_key_password_changed_success": MessageLookupByLibrary.simpleMessage(
      "Password changed successfully",
    ),
    "g_key_password_min_length": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters",
    ),
    "g_key_password_req_different": MessageLookupByLibrary.simpleMessage(
      "Different from current password",
    ),
    "g_key_password_req_length": MessageLookupByLibrary.simpleMessage(
      "At least 6 characters",
    ),
    "g_key_password_required": MessageLookupByLibrary.simpleMessage(
      "Password is required",
    ),
    "g_key_password_requirements": MessageLookupByLibrary.simpleMessage(
      "Password Requirements",
    ),
    "g_key_password_reset_success": MessageLookupByLibrary.simpleMessage(
      "Password reset successfully",
    ),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "g_key_payment_amount_invalid": MessageLookupByLibrary.simpleMessage(
      "Неверная сумма",
    ),
    "g_key_payment_approx_token": m38,
    "g_key_payment_approx_usdt": m39,
    "g_key_payment_code_title": MessageLookupByLibrary.simpleMessage(
      "QR-код оплаты",
    ),
    "g_key_payment_confirm": MessageLookupByLibrary.simpleMessage(
      "Подтвердить",
    ),
    "g_key_payment_history": MessageLookupByLibrary.simpleMessage(
      "История платежей",
    ),
    "g_key_payment_history_btn": MessageLookupByLibrary.simpleMessage(
      "История",
    ),
    "g_key_payment_incoming": MessageLookupByLibrary.simpleMessage("Входящий"),
    "g_key_payment_load_failed": MessageLookupByLibrary.simpleMessage(
      "Ошибка загрузки",
    ),
    "g_key_payment_name_not_set": MessageLookupByLibrary.simpleMessage(
      "Не задано",
    ),
    "g_key_payment_native_insufficient": MessageLookupByLibrary.simpleMessage(
      "Недостаточно нативного баланса!",
    ),
    "g_key_payment_native_not_found": MessageLookupByLibrary.simpleMessage(
      "Основная цепочка не найдена!",
    ),
    "g_key_payment_outgoing": MessageLookupByLibrary.simpleMessage("Исходящий"),
    "g_key_payment_set_amount_title": MessageLookupByLibrary.simpleMessage(
      "Установить сумму",
    ),
    "g_key_payment_success": MessageLookupByLibrary.simpleMessage(
      "Оплата прошла успешно!",
    ),
    "g_key_payment_title": MessageLookupByLibrary.simpleMessage("Оплата"),
    "g_key_payment_usdt_insufficient": MessageLookupByLibrary.simpleMessage(
      "Недостаточно USDT!",
    ),
    "g_key_payment_usdt_not_found": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, добавьте токен USDT!",
    ),
    "g_key_payment_wallet": MessageLookupByLibrary.simpleMessage("Кошелёк"),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Выбрать из галереи телефона",
    ),
    "g_key_resend_code": MessageLookupByLibrary.simpleMessage("Resend Code"),
    "g_key_reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "g_key_reset_password": MessageLookupByLibrary.simpleMessage(
      "Reset Password",
    ),
    "g_key_reset_password_email_desc": MessageLookupByLibrary.simpleMessage(
      "Enter your email address to receive a verification code",
    ),
    "g_key_saml_login": MessageLookupByLibrary.simpleMessage("SAML Login"),
    "g_key_saml_not_configured": MessageLookupByLibrary.simpleMessage(
      "SAML not configured",
    ),
    "g_key_send_code": MessageLookupByLibrary.simpleMessage(
      "Send Verification Code",
    ),
    "g_key_set_new_password_desc": MessageLookupByLibrary.simpleMessage(
      "Set your new password",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage(
      "Поделиться QR-кодом",
    ),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage(
      "Поделиться ссылкой",
    ),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage(
      "Способ распространения",
    ),
    "g_key_sign_in_failed": MessageLookupByLibrary.simpleMessage(
      "Sign in failed",
    ),
    "g_key_social_login": MessageLookupByLibrary.simpleMessage("Social Login"),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Чат"),
    "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
      "Файл слишком большой для загрузки",
    ),
    "g_key_squad_k15": m40,
    "g_key_squad_k18": MessageLookupByLibrary.simpleMessage("Добавить контакт"),
    "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("Контакт"),
    "g_key_squad_k25": MessageLookupByLibrary.simpleMessage("Поиск по email"),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("Активный"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "Active Positions",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("APY"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("Avg APY"),
    "g_key_stake_claim": MessageLookupByLibrary.simpleMessage(
      "Получить награды",
    ),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage("Комиссия"),
    "g_key_stake_d_unbond": m41,
    "g_key_stake_days_left": m42,
    "g_key_stake_days_remaining": m43,
    "g_key_stake_delegators": MessageLookupByLibrary.simpleMessage(
      "Делегаторы",
    ),
    "g_key_stake_liquid": MessageLookupByLibrary.simpleMessage(
      "Ликвидный стейкинг",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("Liquid"),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage("Мин. стейк"),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage("No lock"),
    "g_key_stake_no_positions": MessageLookupByLibrary.simpleMessage(
      "Нет позиций стейкинга",
    ),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "No staking positions yet",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "Total Staking Overview",
    ),
    "g_key_stake_pending_rewards": MessageLookupByLibrary.simpleMessage(
      "Ожидающие награды",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "Мои позиции",
    ),
    "g_key_stake_protocol": MessageLookupByLibrary.simpleMessage("Протокол"),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Protocols"),
    "g_key_stake_restake": MessageLookupByLibrary.simpleMessage("Перестейкать"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("Награды"),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "Выбрать валидатора",
    ),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("Застейкать"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("Staked"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "Start Staking",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("Стейкинг"),
    "g_key_stake_total_staked": MessageLookupByLibrary.simpleMessage(
      "Всего застейкано",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage(
      "Разблокировка",
    ),
    "g_key_stake_unbonding_period": MessageLookupByLibrary.simpleMessage(
      "Период разблокировки",
    ),
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage("Снять стейк"),
    "g_key_stake_uptime": MessageLookupByLibrary.simpleMessage("Время работы"),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Валидатор"),
    "g_key_stake_validators": MessageLookupByLibrary.simpleMessage(
      "Валидаторы",
    ),
    "g_key_step_email": MessageLookupByLibrary.simpleMessage("Email"),
    "g_key_step_password": MessageLookupByLibrary.simpleMessage("Password"),
    "g_key_step_verify": MessageLookupByLibrary.simpleMessage("Verify"),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Завершено"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Цена газа"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Макс. комиссия за газ"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage(
      "Макс. плата за единицу газа",
    ),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("В ожидании"),
    "g_key_t_29": m44,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("Неудача"),
    "g_key_t_30": MessageLookupByLibrary.simpleMessage("Комиссия майнера"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Продолжить"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("Пароль кошелька"),
    "g_key_t_33": MessageLookupByLibrary.simpleMessage(
      "Пароль кошелька не может быть пустым",
    ),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage(
      "Неверный пароль кошелька",
    ),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите пароль кошелька",
    ),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage(
      "Ставка комиссии за газ",
    ),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage(
      "Средняя ставка комиссии за газ последнего блока",
    ),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage("Исходящий перевод"),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage(
      "Введите целое число больше 0.",
    ),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage(
      "Не удалось получить данные",
    ),
    "g_key_t_45": m45,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage(
      "Проверка адреса получателя",
    ),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("Найти"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage("Нет аккаунта"),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage("Входящий перевод"),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage(
      "Недействительный адрес",
    ),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage(
      "Верификация аккаунта успешна",
    ),
    "g_key_t_52": m46,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "У адреса получателя нет аккаунта, и первый перевод должен быть минимум 10XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Использовано газа"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Газ"),
    "g_key_time_days_ago": m47,
    "g_key_time_hours_ago": m48,
    "g_key_time_just_now": MessageLookupByLibrary.simpleMessage("Just now"),
    "g_key_time_minutes_ago": m49,
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage("История транзакций"),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage("Детали транзакции"),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage(
      "Просмотрите квитанции транзакций в истории",
    ),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("Сумма расхода"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("Сумма получения"),
    "g_key_tx_filter_date_from": MessageLookupByLibrary.simpleMessage(
      "Start Date",
    ),
    "g_key_tx_filter_date_range": MessageLookupByLibrary.simpleMessage(
      "Date Range",
    ),
    "g_key_tx_filter_date_to": MessageLookupByLibrary.simpleMessage("End Date"),
    "g_key_tx_filter_direction": MessageLookupByLibrary.simpleMessage(
      "Direction",
    ),
    "g_key_tx_no_results": MessageLookupByLibrary.simpleMessage(
      "No transactions match your filter",
    ),
    "g_key_u_10": MessageLookupByLibrary.simpleMessage("Типы NFT"),
    "g_key_u_11": MessageLookupByLibrary.simpleMessage("Подписчики"),
    "g_key_u_12": MessageLookupByLibrary.simpleMessage("Типы пользователей"),
    "g_key_u_13": MessageLookupByLibrary.simpleMessage("Веб-сайт"),
    "g_key_u_14": MessageLookupByLibrary.simpleMessage("Ссылка на продукты"),
    "g_key_u_15": MessageLookupByLibrary.simpleMessage("Медиа-платформы"),
    "g_key_u_16": MessageLookupByLibrary.simpleMessage("Адрес кошелька"),
    "g_key_u_2": MessageLookupByLibrary.simpleMessage("Никнейм"),
    "g_key_u_23": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить аватар",
    ),
    "g_key_u_3": MessageLookupByLibrary.simpleMessage("Описание"),
    "g_key_u_5": MessageLookupByLibrary.simpleMessage("Информация об артисте"),
    "g_key_u_6": MessageLookupByLibrary.simpleMessage(
      "Вы не являетесь артистом",
    ),
    "g_key_u_7": MessageLookupByLibrary.simpleMessage(
      "Нажмите здесь, чтобы подать заявку на статус артиста",
    ),
    "g_key_u_8": MessageLookupByLibrary.simpleMessage("Имя"),
    "g_key_u_9": MessageLookupByLibrary.simpleMessage("Доход"),
    "g_key_unlink_account": MessageLookupByLibrary.simpleMessage(
      "Unlink Account",
    ),
    "g_key_user_p1": MessageLookupByLibrary.simpleMessage(
      "Я прочитал и принимаю ",
    ),
    "g_key_user_p2": MessageLookupByLibrary.simpleMessage(
      "Условия и положения",
    ),
    "g_key_user_p3": MessageLookupByLibrary.simpleMessage(
      "Политику конфиденциальности и Заявление о сборе персональных данных",
    ),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage(
      "Найдена последняя версия",
    ),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("Обновить сейчас"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage("Найдена новая версия"),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage(
      "У вас последняя версия",
    ),
    "g_key_verification_code": MessageLookupByLibrary.simpleMessage(
      "Verification Code",
    ),
    "g_key_verification_code_sent": m50,
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage(
      "Просмотр сид-фразы",
    ),
    "g_key_wallet_c11": MessageLookupByLibrary.simpleMessage(
      "Убедитесь, что вы записали сид-фразу и храните её в безопасности.",
    ),
    "g_key_wallet_c12": MessageLookupByLibrary.simpleMessage(
      "Теперь попробуйте ввести сид-фразу ещё раз.",
    ),
    "g_key_wallet_c13": MessageLookupByLibrary.simpleMessage("Импорт аккаунта"),
    "g_key_wallet_c14": MessageLookupByLibrary.simpleMessage("Создать аккаунт"),
    "g_key_wallet_c15": MessageLookupByLibrary.simpleMessage("Всё готово!"),
    "g_key_wallet_c16": MessageLookupByLibrary.simpleMessage(
      "Теперь вы можете полноценно использовать кошелёк.",
    ),
    "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("Начать"),
    "g_key_wallet_c18": MessageLookupByLibrary.simpleMessage("Пропустить"),
    "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
      "Вы можете пропустить резервное копирование сид-фразы сейчас и сделать это позже в Настройках при необходимости.",
    ),
    "g_key_wallet_c21": MessageLookupByLibrary.simpleMessage(
      "Создать напрямую",
    ),
    "g_key_wallet_c22": MessageLookupByLibrary.simpleMessage("Успешно создано"),
    "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
      "Если хотите проверить детали кошелька или экспортировать keystore, перейдите в Меню > Управление кошельком",
    ),
    "g_key_wallet_c24": MessageLookupByLibrary.simpleMessage(
      "Экспортировать keystore",
    ),
    "g_key_wallet_c25": MessageLookupByLibrary.simpleMessage(
      "Защитите кошелёк резервным копированием",
    ),
    "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
      "Keystore — это хранилище сертификатов безопасности и связанных приватных ключей.",
    ),
    "g_key_wallet_c27": MessageLookupByLibrary.simpleMessage(
      "Шаг 1: Перейдите в Управление кошельком.",
    ),
    "g_key_wallet_c28": MessageLookupByLibrary.simpleMessage(
      "Шаг 2: Выберите адрес кошелька.",
    ),
    "g_key_wallet_c29": MessageLookupByLibrary.simpleMessage(
      "Шаг 3: Нажмите Экспортировать Keystore.",
    ),
    "g_key_wallet_c30": MessageLookupByLibrary.simpleMessage(
      "Перейти в Управление кошельком",
    ),
    "g_key_wallet_c31": MessageLookupByLibrary.simpleMessage(
      "Вернуться на главную",
    ),
    "g_key_wallet_c32": MessageLookupByLibrary.simpleMessage(
      "Добавить кошелёк",
    ),
    "g_key_wallet_c33": MessageLookupByLibrary.simpleMessage(
      "Создать кошелёк с помощью сид-фразы.",
    ),
    "g_key_wallet_c34": MessageLookupByLibrary.simpleMessage(
      "Введите название кошелька",
    ),
    "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage(
      "Вы не сделали резервную копию сид-фразы кошелька!",
    ),
    "g_key_wallet_c36": MessageLookupByLibrary.simpleMessage(
      "Создать резервную копию",
    ),
    "g_key_wallet_c37": MessageLookupByLibrary.simpleMessage(
      "Установить пароль кошелька",
    ),
    "g_key_wallet_c38": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование кошелька",
    ),
    "g_key_wallet_c39": MessageLookupByLibrary.simpleMessage(
      "Запишите следующую сид-фразу",
    ),
    "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("Начать"),
    "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
      "Подключённые к интернету устройства могут раскрыть вашу информацию. Рекомендуем записать сид-фразу и хранить её в безопасности.",
    ),
    "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
      "Внимание: Не раскрывайте сид-фразу никому. N42Wallet никогда не запросит эту информацию. Будьте крайне осторожны и храните её офлайн в безопасности. При раскрытии сид-фразы вы можете потерять все активы без возможности восстановления.",
    ),
    "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
      "Внимание: Сид-фраза — единственный способ восстановить активы кошелька.",
    ),
    "g_key_wallet_c43": MessageLookupByLibrary.simpleMessage("Следующий шаг"),
    "g_key_wallet_c44": MessageLookupByLibrary.simpleMessage(
      "Нажмите для просмотра сид-фразы",
    ),
    "g_key_wallet_c45": MessageLookupByLibrary.simpleMessage(
      "Убедитесь, что рядом нет посторонних людей или камер",
    ),
    "g_key_wallet_c46": MessageLookupByLibrary.simpleMessage(
      "Подтверждение сид-фразы",
    ),
    "g_key_wallet_c47": MessageLookupByLibrary.simpleMessage(
      "Информация о кошельке",
    ),
    "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage(
      "Название кошелька",
    ),
    "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage(
      "Сначала сделайте резервную копию сид-фразы кошелька!",
    ),
    "g_key_wallet_c6": MessageLookupByLibrary.simpleMessage(
      "Проверка сид-фразы",
    ),
    "g_key_wallet_c7": MessageLookupByLibrary.simpleMessage(
      "Теперь введите вашу сид-фразу.",
    ),
    "g_key_wallet_c8": MessageLookupByLibrary.simpleMessage("Установить фразу"),
    "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
      "Убедитесь, что вы записали сид-фразу и храните её в безопасности. Она понадобится для импорта или восстановления криптовалютного кошелька.",
    ),
    "g_key_wallet_edit": MessageLookupByLibrary.simpleMessage(
      "Редактирование кошелька",
    ),
    "g_key_wallet_k25": MessageLookupByLibrary.simpleMessage("Время"),
    "g_key_wallet_k33": MessageLookupByLibrary.simpleMessage("Результат"),
    "g_key_wallet_k37": MessageLookupByLibrary.simpleMessage("Хэш транзакции"),
    "g_key_wallet_k47": MessageLookupByLibrary.simpleMessage("Добавить"),
    "g_key_wallet_k53": MessageLookupByLibrary.simpleMessage("Путь"),
    "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("Блок"),
    "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("Значение"),
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("Nonce"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("Ускорить"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Заметка"),
    "g_key_wallet_m1": m51,
    "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите удалить аккаунт?",
    ),
    "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage(
      "Подтвердите выход",
    ),
    "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
      "Введите код Google Authenticator.",
    ),
    "g_key_wallet_m19": m52,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "Текущий токен не был добавлен.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Введите сид-фразу, разделяя слова пробелами",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage("Импорт кошелька"),
    "g_key_wallet_m3": m53,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "Недостаточный баланс текущего токена.",
    ),
    "g_key_wallet_m5": m54,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("Ошибка подписи"),
    "g_key_wallet_m8": MessageLookupByLibrary.simpleMessage(
      "Удаление аккаунта",
    ),
    "g_key_wallet_m9": MessageLookupByLibrary.simpleMessage(
      "Введите код подтверждения из email.",
    ),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Управление кошельком",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Зарезервировано"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Базовый резерв"),
    "g_key_xml_11": m55,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("Инкрементный резерв"),
    "g_key_xml_22": m56,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Количество принадлежащих объектов",
    ),
    "g_key_xml_33": m57,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "Как рассчитать общую сумму резерва",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "Общий резерв = Базовый резерв + (Количество объектов × Инкрементный резерв)",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID и Face ID"),
    "g_lock_key10": MessageLookupByLibrary.simpleMessage("Текущий пароль"),
    "g_lock_key11": MessageLookupByLibrary.simpleMessage("Новый пароль"),
    "g_lock_key12": MessageLookupByLibrary.simpleMessage(
      "Подтвердите новый пароль",
    ),
    "g_lock_key13": MessageLookupByLibrary.simpleMessage("6-значный код"),
    "g_lock_key15": MessageLookupByLibrary.simpleMessage("Пароли и биометрия"),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("Графический пароль"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage(
      "Установить графический пароль",
    ),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "Для безопасности аккаунта установите графический пароль",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "Повторный ввод графического пароля",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage(
      "Нарисуйте графический пароль",
    ),
    "g_lock_key21": m58,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Сбросить графический пароль",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Слишком много неверных попыток, сбросьте пароль",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Добавить пароль кошелька?",
    ),
    "g_lock_key25": m59,
    "g_lock_key3": MessageLookupByLibrary.simpleMessage("Экран блокировки"),
    "g_lock_key4": MessageLookupByLibrary.simpleMessage("Автоблокировка"),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Успешно"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Неудача"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "Биометрическое распознавание не включено",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "Добавить биометрическую верификацию?",
    ),
    "g_lock_key9": MessageLookupByLibrary.simpleMessage("Сбросить пароль"),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("Разблокировать N?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Активность облачной верификации",
    ),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage(
      "Для настройки требуется небольшая сумма на газ.",
    ),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "Вы успешно присоединились к групповой ноде в N42Wallet. Поделитесь ссылкой, чтобы пригласить друзей, активировать ноду и начать верификацию!",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage(
      "Поделиться с друзьями",
    ),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("Продолжить"),
    "g_mining_key63": m60,
    "g_mining_key73": m61,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Я только что настроил ноду в @N42Wallet и начал верификацию на мобильных устройствах! Присоединяйтесь. Децентрализованное будущее — это мобильность!",
    ),
    "g_mining_key76": m62,
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Выкуп доступен после 768 сек.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Запросы до этого момента не будут обработаны.",
    ),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage(
      "Сегодняшнее вознаграждение",
    ),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, относитесь к данным ниже как к важному ключу. Рекомендуем немедленно скопировать и сохранить их в надёжном месте.",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage(
      "Копировать данные",
    ),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("Неактивен"),
    "g_mining_key_103": MessageLookupByLibrary.simpleMessage(
      "Список валидаторов",
    ),
    "g_mining_key_104": MessageLookupByLibrary.simpleMessage("Импорт успешен"),
    "g_mining_key_105": MessageLookupByLibrary.simpleMessage(
      "Зашифрованные данные не могут быть пустыми!",
    ),
    "g_mining_key_106": MessageLookupByLibrary.simpleMessage(
      "Пароль не может быть пустым!",
    ),
    "g_mining_key_107": MessageLookupByLibrary.simpleMessage(
      "Расшифровка не удалась. Проверьте правильность пароля!",
    ),
    "g_mining_key_108": MessageLookupByLibrary.simpleMessage(
      "Неподдерживаемый формат зашифрованных данных!",
    ),
    "g_mining_key_109": m63,
    "g_mining_key_11": MessageLookupByLibrary.simpleMessage(
      "Вчерашние вознаграждения",
    ),
    "g_mining_key_110": MessageLookupByLibrary.simpleMessage(
      "Зашифрованные данные",
    ),
    "g_mining_key_111": MessageLookupByLibrary.simpleMessage("Импорт файлов"),
    "g_mining_key_112": MessageLookupByLibrary.simpleMessage(
      "Введите зашифрованные данные.",
    ),
    "g_mining_key_113": MessageLookupByLibrary.simpleMessage("Импорт..."),
    "g_mining_key_114": MessageLookupByLibrary.simpleMessage("Подтверждение"),
    "g_mining_key_115": MessageLookupByLibrary.simpleMessage(
      "Выкуп занимает некоторое время, пожалуйста, подождите!",
    ),
    "g_mining_key_116": m64,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "Вознаграждение накапливается ежедневно и отправляется на ваш N кошелёк только при достижении ~0.5 N.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage(
      "Всего вознаграждений",
    ),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage(
      "Добытая стоимость",
    ),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
      "Рассчитывается на основе рыночной цены N * общее количество вознаграждений N.",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage(
      "Количество прибылей",
    ),
    "g_mining_key_31": MessageLookupByLibrary.simpleMessage("Выбор планов"),
    "g_mining_key_32": MessageLookupByLibrary.simpleMessage(
      "Период разблокировки: Разблокировка в любое время",
    ),
    "g_mining_key_33": MessageLookupByLibrary.simpleMessage(
      "Макс. годовое вознаграждение",
    ),
    "g_mining_key_34": MessageLookupByLibrary.simpleMessage(
      "Распределение вознаграждений",
    ),
    "g_mining_key_35": MessageLookupByLibrary.simpleMessage("Дневной лимит"),
    "g_mining_key_36": MessageLookupByLibrary.simpleMessage("Скорость"),
    "g_mining_key_37": MessageLookupByLibrary.simpleMessage(
      "Планы верификации",
    ),
    "g_mining_key_38": MessageLookupByLibrary.simpleMessage(
      "Выберите способ оплаты",
    ),
    "g_mining_key_39": MessageLookupByLibrary.simpleMessage("Способы оплаты"),
    "g_mining_key_40": MessageLookupByLibrary.simpleMessage("Оплата в N"),
    "g_mining_key_42": MessageLookupByLibrary.simpleMessage("Баланс кошелька"),
    "g_mining_key_43": MessageLookupByLibrary.simpleMessage(
      "У вас недостаточно N для этой транзакции",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Отключено"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("Показать ещё"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage(
      "Статус верификации",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Заблокируйте N для начала получения вознаграждений за верификацию.",
    ),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Начальный"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("Продвинутая нода"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Начальная нода"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Про нода"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 блоков/день~70 мин",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage("Выберите план"),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 блоков/день~15 мин",
    ),
    "g_mining_key_71": m65,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "128 секунд на проверку",
    ),
    "g_mining_key_73": MessageLookupByLibrary.simpleMessage(
      "Облачная верификация запущена",
    ),
    "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
      "Тестовая сеть обновляется, временно невозможно верифицировать блоки.",
    ),
    "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
      "Невыполнение заданий в течение четырёх дней подряд приведёт к отсутствию заработка и риску штрафа.",
    ),
    "g_mining_key_76": MessageLookupByLibrary.simpleMessage("Оценка риска"),
    "g_mining_key_77": MessageLookupByLibrary.simpleMessage("Выкупить"),
    "g_mining_key_78": MessageLookupByLibrary.simpleMessage(
      "Сначала сохраните пару публичного и приватного ключей валидатора.",
    ),
    "g_mining_key_79": MessageLookupByLibrary.simpleMessage("Экспорт"),
    "g_mining_key_80": MessageLookupByLibrary.simpleMessage(
      "Недостаточно средств для перевода.",
    ),
    "g_mining_key_81": MessageLookupByLibrary.simpleMessage(
      "Список валидаторов",
    ),
    "g_mining_key_82": MessageLookupByLibrary.simpleMessage(
      "Импорт валидатора",
    ),
    "g_mining_key_83": MessageLookupByLibrary.simpleMessage(
      "Валидатор уже существует",
    ),
    "g_mining_key_84": MessageLookupByLibrary.simpleMessage("Низкий риск"),
    "g_mining_key_85": MessageLookupByLibrary.simpleMessage("Умеренно риск"),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage(
      "Вознаграждения за последние 7 дней",
    ),
    "g_mining_key_87": MessageLookupByLibrary.simpleMessage("Высокий риск"),
    "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
      "Контракт загружается, в данный момент верификация невозможна. Пожалуйста, подождите!",
    ),
    "g_mining_key_89": MessageLookupByLibrary.simpleMessage(
      "Советы по безопасности",
    ),
    "g_mining_key_9": MessageLookupByLibrary.simpleMessage(
      "Фоновая верификация",
    ),
    "g_mining_key_90": MessageLookupByLibrary.simpleMessage(
      "Храните свой приватный ключ или сид-фразу в безопасности.",
    ),
    "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
      "Ваш приватный ключ или сид-фраза являются единственным способом доступа к активам кошелька.",
    ),
    "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
      "Храните их в безопасном месте (бумага, менеджер паролей и т.д.).",
    ),
    "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
      "Не делайте скриншоты, не загружайте в интернет и не передавайте никому.",
    ),
    "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
      "При утере или компрометации активы кошелька невозможно восстановить.",
    ),
    "g_mining_key_95": MessageLookupByLibrary.simpleMessage(
      "Подтвердить и сохранить",
    ),
    "g_mining_key_96": MessageLookupByLibrary.simpleMessage(
      "Установить пароль и зашифровать",
    ),
    "g_mining_key_97": MessageLookupByLibrary.simpleMessage(
      "Введите пароль шифрования",
    ),
    "g_mining_key_98": m66,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Повторите пароль для подтверждения",
    ),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage(
      "Период разблокировки:",
    ),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "Разблокировка в любое время",
    ),
    "g_notification_key_1": MessageLookupByLibrary.simpleMessage("Уведомления"),
    "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("Поделиться"),
    "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("Реферал"),
    "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage(
      "Приглашайте друзей и получайте токены N!",
    ),
    "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage("Получите до "),
    "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage(
      " N, когда ваш реферал начнёт верификацию!",
    ),
    "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage(
      "Пригласить через",
    ),
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("Ссылка"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("код"),
    "g_swap_key_14": m67,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage(
      "Ошибка получения цены монеты.",
    ),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage(
      "Продолжая, вы соглашаетесь со следующими ",
    ),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage(
      "Условиями и положениями.",
    ),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("Завершить"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
      "Ваш обмен будет распределён в ближайшее время. Пожалуйста, подождите.",
    ),
    "g_swap_key_20": m68,
    "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
      "Стоимость запуска ноды: Групповая верификация 1-49 N Базовая нода: 50 N Премиум нода: 100 N Про нода: 500 N.",
    ),
    "g_swap_key_22": MessageLookupByLibrary.simpleMessage("Истёк"),
    "g_swap_key_23": MessageLookupByLibrary.simpleMessage("Не оплачен"),
    "g_swap_key_24": MessageLookupByLibrary.simpleMessage(
      "Подтверждение платежа",
    ),
    "g_swap_key_25": MessageLookupByLibrary.simpleMessage("К распределению"),
    "g_swap_key_28": MessageLookupByLibrary.simpleMessage("Сводка обмена"),
    "g_swap_key_29": MessageLookupByLibrary.simpleMessage("Новый баланс"),
    "g_swap_key_3": MessageLookupByLibrary.simpleMessage("Вы платите"),
    "g_swap_key_30": MessageLookupByLibrary.simpleMessage("Дата"),
    "g_swap_key_31": m69,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Обмены можно просмотреть в соответствующих обозревателях блокчейна (Etherscan, BscScan, TRONSCAN и наш собственный).",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Обменять на N"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Обмен"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Вы получаете"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("Предпросмотр обмена"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Повторить"),
    "g_token_m_key_1": m70,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "Любой может создать токен, включая поддельные версии существующих токенов. Всегда изучайте токен перед импортом.",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("Токены"),
    "g_token_m_key_12": MessageLookupByLibrary.simpleMessage("Поиск токена"),
    "g_token_m_key_13": MessageLookupByLibrary.simpleMessage("Название сети"),
    "g_token_m_key_14": MessageLookupByLibrary.simpleMessage("Символ сети"),
    "g_token_m_key_15": MessageLookupByLibrary.simpleMessage("ID сети"),
    "g_token_m_key_16": MessageLookupByLibrary.simpleMessage(
      "Десятичные знаки",
    ),
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("RPC"),
    "g_token_m_key_18": MessageLookupByLibrary.simpleMessage("API"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Добавить пользовательскую сеть",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 ед."),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("Добавить токены"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage("Ошибка формата!"),
    "g_token_m_key_22": m71,
    "g_token_m_key_23": m72,
    "g_token_m_key_24": m73,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("Импорт токенов"),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("Все сети"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage(
      "Пользовательский токен",
    ),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage("Адрес токена"),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("Символ токена"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage(
      "Десятичные знаки токена",
    ),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("Импортировать"),
    "g_unlock_key10": m74,
    "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
      "Отпечаток пальца или распознавание лица не включено?",
    ),
    "g_unlock_key3": MessageLookupByLibrary.simpleMessage(
      "Нарисуйте графический пароль",
    ),
    "g_unlock_key4": m75,
    "g_unlock_key5": MessageLookupByLibrary.simpleMessage("Введите пароль"),
    "g_unlock_key6": m76,
    "g_unlock_key7": MessageLookupByLibrary.simpleMessage(
      "Аутентификация не удалась",
    ),
    "g_unlock_key8": m77,
    "g_unlock_key9": MessageLookupByLibrary.simpleMessage("Вы также можете "),
    "google_verification": MessageLookupByLibrary.simpleMessage(
      "Google Аутентификация",
    ),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Связать",
    ),
    "google_verification_message11": MessageLookupByLibrary.simpleMessage(
      "Скачать Google Authenticator",
    ),
    "google_verification_message12": MessageLookupByLibrary.simpleMessage(
      "Инструкции",
    ),
    "google_verification_message13": MessageLookupByLibrary.simpleMessage(
      "Откройте Google Authenticator.",
    ),
    "google_verification_message14": MessageLookupByLibrary.simpleMessage(
      "На экране появится 6-значный код подтверждения.",
    ),
    "google_verification_message15": MessageLookupByLibrary.simpleMessage(
      "Скопируйте 6-значный код и вставьте его в N42Wallet.",
    ),
    "google_verification_message16": MessageLookupByLibrary.simpleMessage(
      "После этого ваш Authenticator будет успешно связан.",
    ),
    "google_verification_message17": MessageLookupByLibrary.simpleMessage(
      "Резервный ключ",
    ),
    "google_verification_message18": MessageLookupByLibrary.simpleMessage(
      "Скопируйте ключ в Google Authenticator",
    ),
    "google_verification_message19": MessageLookupByLibrary.simpleMessage(
      "Введите код Google Authenticator",
    ),
    "google_verification_message20": MessageLookupByLibrary.simpleMessage(
      "Введите код подтверждения из E-mail",
    ),
    "google_verification_message21": m78,
    "google_verification_message3": MessageLookupByLibrary.simpleMessage(
      "Не удалось получить ключ Google",
    ),
    "google_verification_message5": MessageLookupByLibrary.simpleMessage(
      "Двухфакторная аутентификация (2FA)",
    ),
    "google_verification_message6": MessageLookupByLibrary.simpleMessage(
      "Для защиты аккаунта рекомендуется включить хотя бы один способ 2FA.",
    ),
    "google_verification_message7": MessageLookupByLibrary.simpleMessage(
      "Приложение Google Authenticator защищает ваши выводы средств и аккаунт N42Wallet.",
    ),
    "google_verification_message8": MessageLookupByLibrary.simpleMessage(
      "Скачать и установить",
    ),
    "google_verification_message9": MessageLookupByLibrary.simpleMessage(
      "Скачайте и установите Google Authenticator. Затем нажмите «Связать», чтобы связать аккаунт N42Wallet.",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage(
      "Важное уведомление",
    ),
    "login_button_text": MessageLookupByLibrary.simpleMessage("Войти"),
    "login_email": MessageLookupByLibrary.simpleMessage("Электронная почта"),
    "login_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Забыли пароль?",
    ),
    "login_invite_code": MessageLookupByLibrary.simpleMessage(
      "Реферальный код",
    ),
    "login_invite_code_title": MessageLookupByLibrary.simpleMessage(
      "Реферальный код",
    ),
    "login_message_1": MessageLookupByLibrary.simpleMessage("Нет аккаунта? "),
    "login_message_10": MessageLookupByLibrary.simpleMessage("Успешно создано"),
    "login_message_11": MessageLookupByLibrary.simpleMessage(
      "Успешно сброшено",
    ),
    "login_message_2": MessageLookupByLibrary.simpleMessage(
      "Уже есть аккаунт? ",
    ),
    "login_message_6": MessageLookupByLibrary.simpleMessage(
      "Отправить код повторно через ",
    ),
    "login_message_7": MessageLookupByLibrary.simpleMessage(
      "Код успешно отправлен",
    ),
    "login_message_8": MessageLookupByLibrary.simpleMessage(
      "E-mail не зарегистрирован",
    ),
    "login_message_9": MessageLookupByLibrary.simpleMessage(
      "Не удалось отправить код",
    ),
    "login_need_login": MessageLookupByLibrary.simpleMessage(
      "пожалуйста, сначала войдите в систему",
    ),
    "login_password": MessageLookupByLibrary.simpleMessage("Пароль"),
    "next": MessageLookupByLibrary.simpleMessage("Далее"),
    "nicknameMessage": m79,
    "password_diff": MessageLookupByLibrary.simpleMessage(
      "Пароли не совпадают",
    ),
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Редактировать профиль",
    ),
    "photograph": MessageLookupByLibrary.simpleMessage("Фотография"),
    "please_enter_code": MessageLookupByLibrary.simpleMessage(
      "Введите код подтверждения",
    ),
    "please_enter_email": MessageLookupByLibrary.simpleMessage("Введите email"),
    "please_enter_password": MessageLookupByLibrary.simpleMessage(
      "Введите пароль",
    ),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Введите адрес",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage("Повторите пароль"),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "Выберите пароль (8~18 символов)",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage(
      "Подтвердите пароль",
    ),
    "rest_Enter_the_password_again": MessageLookupByLibrary.simpleMessage(
      "Введите пароль ещё раз",
    ),
    "rest_Please_enter": MessageLookupByLibrary.simpleMessage("Введите код"),
    "rest_Verification_code": MessageLookupByLibrary.simpleMessage("OTP-код"),
    "rest_your_password": MessageLookupByLibrary.simpleMessage(
      "Сбросить пароль",
    ),
    "s_key_1": MessageLookupByLibrary.simpleMessage("Управление кошельком"),
    "s_key_10": MessageLookupByLibrary.simpleMessage("О приложении"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Безопасность"),
    "s_key_12": MessageLookupByLibrary.simpleMessage("Использовать новый чат"),
    "s_key_13": MessageLookupByLibrary.simpleMessage("Включить улучшенный чат"),
    "s_key_2": MessageLookupByLibrary.simpleMessage("Адреса кошелька"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("Транзакция"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Язык"),
    "s_key_5": MessageLookupByLibrary.simpleMessage("Тема"),
    "search": MessageLookupByLibrary.simpleMessage("Поиск"),
    "selected_user_protocol": MessageLookupByLibrary.simpleMessage(
      "Прочитайте соглашение и подтвердите",
    ),
    "verification": MessageLookupByLibrary.simpleMessage("верификация"),
    "w_item_1": MessageLookupByLibrary.simpleMessage(
      "Если я потеряю сид-фразу, мои средства будут потеряны навсегда.",
    ),
    "w_item_2": MessageLookupByLibrary.simpleMessage(
      "Если я раскрою или передам сид-фразу кому-либо, мои средства могут быть украдены.",
    ),
    "w_item_3": MessageLookupByLibrary.simpleMessage(
      "Я несу ответственность за сохранность своей сид-фразы.",
    ),
    "w_key_12": MessageLookupByLibrary.simpleMessage("Неверная сид-фраза."),
    "w_key_8": MessageLookupByLibrary.simpleMessage(
      "Введите сид-фразу кошелька, который хотите импортировать.",
    ),
  };
}
