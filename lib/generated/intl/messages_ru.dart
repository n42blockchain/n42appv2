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

  static String m1(price) => "Текущая цена: \$${price}.";

  static String m2(symbol) => "Оповещение о цене · ${symbol}";

  static String m3(value) => "Это ${value}";

  static String m4(value) => "Участники чата (${value})";

  static String m5(value) =>
      "Вы уверены, что хотите добавить ${value} в друзья";

  static String m6(email) => "Код подтверждения отправлен на ${email}.";

  static String m7(s) => "Отправить повторно через ${s}s";

  static String m8(value) =>
      "Привязка уже выполнена, повторная привязка невозможна. Адрес привязки: ${value}.";

  static String m9(value) => "Привязка успешна. Адрес привязки: ${value}";

  static String m10(value) => "В кошельке ${value} нет сети N42chain!";

  static String m11(value) => "Сопоставление успешно. Адрес:${value}.";

  static String m12(value) => "Сумма больше ${value}.";

  static String m13(value) =>
      "Кошелёк уже существует, название кошелька \"${value}\"";

  static String m14(value) => "Введите сумму больше ${value}.";

  static String m15(gas) =>
      "Газ выполнения (${gas}) высокий. Вызванный контракт может потреблять больше газа, чем ожидалось.";

  static String m16(gas) =>
      "Первая транзакция включает развёртывание аккаунта (~${gas} газа). Последующие транзакции будут дешевле.";

  static String m17(gas) =>
      "Накладные расходы газа paymaster (${gas}) высоки. Транзакции без газа могут стоить дороже.";

  static String m18(gas) =>
      "Расчётный общий газ (${gas}) необычно высок. Проверьте транзакцию на наличие ошибок.";

  static String m19(gas) =>
      "Газ верификации (${gas}) может быть слишком высоким. Это может происходить при сложной логике аккаунта.";

  static String m20(value) => "Осталось ${value} дней";

  static String m21(value) => "Дубликат адреса в строке ${value}";

  static String m22(value) =>
      "Недостаточный баланс: общая сумма превысит доступный ${value}";

  static String m23(value) => "Неверный адрес в строке ${value}";

  static String m24(value) => "Неверная сумма в строке ${value}";

  static String m25(value) => "Максимум ${value} получателей";

  static String m26(token) => "Подтвердите ${token}, чтобы продолжить.";

  static String m27(impact) =>
      "Влияние высокой цены (${impact})! Действуйте осторожно.";

  static String m28(secs) => "Срок действия котировки истекает через ${secs}s";

  static String m29(value) => "+${value} баллов/день";

  static String m30(value) => "Зарабатывайте до ${value}% APY";

  static String m31(value) => "Поздравляем! Теперь у вас есть ${value}.";

  static String m32(value) => "Пожалуйста, подождите ${value} секунд.";

  static String m33(value) =>
      "Автоматическое обновление каждые ${value} секунд.";

  static String m34(address) => "Счёт ${address} добавлен";

  static String m35(address, network) =>
      "Хотите отслеживать этот счёт аппаратного кошелька?\n\nАдрес: ${address}\nСеть: ${network}";

  static String m36(app) => "Текущее приложение: ${app}.";

  static String m37(days) => "${days} дней назад";

  static String m38(value) => "Не удалось импортировать счёт: ${value}";

  static String m39(date) => "Последнее подключение: ${date}";

  static String m40(value) =>
      "Пожалуйста, откройте приложение ${value} на устройстве";

  static String m41(app) =>
      "Убедитесь, что приложение ${app} открыто на Ledger";

  static String m42(name) =>
      "Вы уверены, что хотите удалить «${name}» из сохраненных устройств?";

  static String m43(value) => "Заработайте очки ${value}";

  static String m44(value) =>
      "Зарабатывайте баллы ${value} за каждого присоединившегося друга!";

  static String m45(value) => "${value} баллов до след. уровня";

  static String m46(amount, token) => "≈ ${amount}${token}";

  static String m47(amount) => "≈ ${amount} USDT";

  static String m48(value) => "Оценка. газ: ~${value} единиц";

  static String m49(reason) => "Причина: ${reason}";

  static String m50(value) =>
      "Вы уверены, что хотите удалить контакт ${value}?";

  static String m51(value) => "${value}d разрыв связи";

  static String m52(value) => "Осталось ${value} дней";

  static String m53(value) => "${value} осталось дней";

  static String m54(value) =>
      "Анстейкинг занимает ${value} дней. В течение этого периода ваши токены будут заблокированы.";

  static String m55(value) => "У вас недостаточно \"${value}\"";

  static String m56(value) => "Не удалось получить аккаунт \"${value}\"";

  static String m57(value) => "Минимум ${value} XRP для первого перевода";

  static String m58(value) => "${value}д назад";

  static String m59(value) => "${value}ч назад";

  static String m60(value) => "${value}м назад";

  static String m61(count) => "Добавить (${count})";

  static String m62(count) =>
      "${Intl.plural(count, one: 'Обнаружен 1 новый токен', other: '${count} обнаружены новые токены')} — нажмите, чтобы просмотреть";

  static String m63(value) => "Код подтверждения отправлен на ${value}.";

  static String m64(value) => "Сеть ${value} не добавлена.";

  static String m65(value) =>
      "У ${value} есть незавершённые транзакции, попробуйте позже.";

  static String m66(value) => "Адрес для ${value} не найден.";

  static String m67(value) => "Недостаточный баланс ${value}.";

  static String m68(value, value1) =>
      "Каждый аккаунт XRP должен резервировать ${value} XRP (${value1} drops) в качестве базового минимума, который нельзя потратить.";

  static String m69(value, value1) =>
      "За каждый объект, принадлежащий аккаунту, к резерву добавляется ${value} XRP (${value1} drops).";

  static String m70(value, value1) =>
      "Этот аккаунт владеет ${value} объектами, что означает дополнительный резерв в ${value1} XRP.";

  static String m71(value) =>
      "Ошибка ввода графического пароля, осталось ${value} попыток";

  static String m72(value) =>
      "Ошибка ввода графического пароля, осталась ${value} попытка";

  static String m73(value) =>
      "Вы успешно настроили ${value} и начнёте верификацию с N42Wallet!";

  static String m74(value) =>
      "Присоединяйтесь к моей группе ${value} в @N42Wallet, чтобы стать ранним майнером Layer 1 сети и получать крипто на свой телефон!";

  static String m75(value, value1) =>
      "Вы уверены, что хотите заблокировать ${value} N до ${value1} для запуска узла?";

  static String m76(value) => "Импорт не удался:${value}";

  static String m77(value) =>
      "Для получения вознаграждений требуется баланс стейкинга не менее ${value}.";

  static String m78(value, value1) =>
      "${value} N каждые ${value1} добытых блоков";

  static String m79(value) => "Должно быть ${value} символов";

  static String m80(value) => "Недостаточный баланс ${value}.";

  static String m81(value) => "${value} поступает...";

  static String m82(value) =>
      "${value} обменянные в приложении будут в ближайшее время распределены на ваш кошелёк и не могут быть проданы через этот процесс. Их можно использовать для запуска ноды.";

  static String m83(value) => "Максимум ${value} символов";

  static String m84(value) => "Сеть ${value} уже поддерживается приложением!";

  static String m85(value) =>
      "Сеть ${value} уже поддерживается приложением, хотите её добавить?";

  static String m86(value) =>
      "Тестовое подключение к адресу ${value} не удалось!";

  static String m87(value) =>
      "Приложение разблокируется через ${value} секунд.";

  static String m88(value) =>
      "Ошибка ввода графического пароля, осталось ${value} попыток";

  static String m89(value) => "Ошибка ввода пароля, осталось ${value} попыток";

  static String m90(value) => "Ошибка ввода пароля, осталась ${value} попытка";

  static String m91(value) => "Введите пароль ${value}";

  static String m92(value) => "0~${value} символов";

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
    "g_2fa_backup_hint": MessageLookupByLibrary.simpleMessage(
      "Сохраните этот ключ — он понадобится, если вы потеряете телефон.",
    ),
    "g_2fa_backup_share": MessageLookupByLibrary.simpleMessage("Поделиться"),
    "g_2fa_backup_share_text": MessageLookupByLibrary.simpleMessage(
      "Резервный ключ Google Authenticator N42Wallet",
    ),
    "g_2fa_disable_confirm_hint": MessageLookupByLibrary.simpleMessage(
      "Введите 6-значный код Google Authenticator для отключения 2FA.",
    ),
    "g_2fa_disable_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Отключить Google 2FA",
    ),
    "g_2fa_disable_error": MessageLookupByLibrary.simpleMessage(
      "Не удалось отключить Google 2FA. Проверьте код и попробуйте снова.",
    ),
    "g_2fa_disable_success": MessageLookupByLibrary.simpleMessage(
      "Google 2FA отключён",
    ),
    "g_2fa_invalid_format": MessageLookupByLibrary.simpleMessage(
      "Введите корректный 6-значный код",
    ),
    "g_alert_above": MessageLookupByLibrary.simpleMessage("Идет выше ↑"),
    "g_alert_below": MessageLookupByLibrary.simpleMessage("Капли ниже ↓"),
    "g_alert_current_price": m1,
    "g_alert_direction": MessageLookupByLibrary.simpleMessage(
      "Сообщите мне, когда цена",
    ),
    "g_alert_enable": MessageLookupByLibrary.simpleMessage(
      "Включить это оповещение",
    ),
    "g_alert_invalid_price": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите действительную цену больше 0",
    ),
    "g_alert_remove": MessageLookupByLibrary.simpleMessage("Удалить"),
    "g_alert_set": MessageLookupByLibrary.simpleMessage(
      "Установить оповещение",
    ),
    "g_alert_target_price": MessageLookupByLibrary.simpleMessage(
      "Целевая цена (долл. США)",
    ),
    "g_alert_title": m2,
    "g_alert_update": MessageLookupByLibrary.simpleMessage(
      "Обновление оповещения",
    ),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "Токены можно отправлять только в пределах одной сети. Отправка из других сетей может привести к потере средств.",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage(
      "Сканируйте для получения",
    ),
    "g_biometric_locked_out": MessageLookupByLibrary.simpleMessage(
      "Слишком много попыток. Биометрия заблокирована — используйте пароль.",
    ),
    "g_biometric_not_enrolled": MessageLookupByLibrary.simpleMessage(
      "Биометрия не настроена. Включите в Настройках.",
    ),
    "g_biometric_retry": MessageLookupByLibrary.simpleMessage(
      "Использовать Face ID / Touch ID",
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
    "g_browser_key18": MessageLookupByLibrary.simpleMessage("История"),
    "g_browser_key19": MessageLookupByLibrary.simpleMessage(
      "Очистить всю историю",
    ),
    "g_browser_key20": MessageLookupByLibrary.simpleMessage(
      "Очистить всю историю просмотра?",
    ),
    "g_browser_key21": MessageLookupByLibrary.simpleMessage("История очищена"),
    "g_browser_key22": MessageLookupByLibrary.simpleMessage("Сегодня"),
    "g_browser_key23": MessageLookupByLibrary.simpleMessage("Вчера"),
    "g_browser_key24": MessageLookupByLibrary.simpleMessage("Каталог DApps"),
    "g_browser_key25": MessageLookupByLibrary.simpleMessage("Популярные"),
    "g_browser_key26": MessageLookupByLibrary.simpleMessage("DEX"),
    "g_browser_key27": MessageLookupByLibrary.simpleMessage("DeFi"),
    "g_browser_key28": MessageLookupByLibrary.simpleMessage("НФТ"),
    "g_browser_key29": MessageLookupByLibrary.simpleMessage("Мост"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Закладки"),
    "g_browser_key30": MessageLookupByLibrary.simpleMessage("Инструменты"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage(
      "Закладки ещё не добавлены",
    ),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("Закладка"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("Название"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите название",
    ),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL-адрес"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("Описание"),
    "g_chat_key_1": MessageLookupByLibrary.simpleMessage(
      "Начать групповой чат",
    ),
    "g_chat_key_10": m3,
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
    "g_chat_key_32": m4,
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
    "g_chat_key_6": m5,
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
    "g_dapp_security_blocked": MessageLookupByLibrary.simpleMessage(
      "Заблокировано",
    ),
    "g_dapp_security_caution": MessageLookupByLibrary.simpleMessage("Внимание"),
    "g_dapp_security_safe": MessageLookupByLibrary.simpleMessage("Сейф"),
    "g_dapp_security_title": MessageLookupByLibrary.simpleMessage(
      "Безопасность децентрализованных приложений",
    ),
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage(
      "Проверено",
    ),
    "g_email_also_sync": MessageLookupByLibrary.simpleMessage(
      "Также синхронизируйте электронную почту учетной записи чата",
    ),
    "g_email_back_to_email": MessageLookupByLibrary.simpleMessage(
      "← Изменить адрес электронной почты",
    ),
    "g_email_both_success": MessageLookupByLibrary.simpleMessage(
      "Оба аккаунта успешно обновлены!",
    ),
    "g_email_change_title": MessageLookupByLibrary.simpleMessage(
      "Изменить адрес электронной почты",
    ),
    "g_email_chat_code_hint": MessageLookupByLibrary.simpleMessage(
      "Введите 6-значный код чата",
    ),
    "g_email_chat_code_sent_to": MessageLookupByLibrary.simpleMessage(
      "Код чата отправлен на",
    ),
    "g_email_chat_confirm": MessageLookupByLibrary.simpleMessage(
      "Подтвердить синхронизацию чата",
    ),
    "g_email_chat_send_fail": MessageLookupByLibrary.simpleMessage(
      "Не удалось отправить код чата",
    ),
    "g_email_chat_sending": MessageLookupByLibrary.simpleMessage(
      "Отправка кода подтверждения чата...",
    ),
    "g_email_chat_sync_title": MessageLookupByLibrary.simpleMessage(
      "Синхронизировать электронную почту учетной записи чата",
    ),
    "g_email_code_invalid": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите 6-значный код",
    ),
    "g_email_code_resent": MessageLookupByLibrary.simpleMessage(
      "Код повторно отправлен",
    ),
    "g_email_code_sent_to": m6,
    "g_email_code_wrong": MessageLookupByLibrary.simpleMessage(
      "Неправильный код, попробуйте еще раз",
    ),
    "g_email_confirm_change": MessageLookupByLibrary.simpleMessage(
      "Подтвердить изменение",
    ),
    "g_email_confirm_continue": MessageLookupByLibrary.simpleMessage(
      "Подтвердите и продолжите синхронизацию чата",
    ),
    "g_email_current_label": MessageLookupByLibrary.simpleMessage(
      "Текущий адрес электронной почты",
    ),
    "g_email_enter_code": MessageLookupByLibrary.simpleMessage(
      "Введите 6-значный код",
    ),
    "g_email_error_empty": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите новый адрес электронной почты",
    ),
    "g_email_error_invalid": MessageLookupByLibrary.simpleMessage(
      "Неверный адрес электронной почты",
    ),
    "g_email_error_same": MessageLookupByLibrary.simpleMessage(
      "Новый адрес электронной почты должен отличаться от текущего адреса электронной почты.",
    ),
    "g_email_n42_only": MessageLookupByLibrary.simpleMessage(
      "Электронная почта N42 обновлена. Электронную почту чата можно обновить в разделе «Чат» > «Настройки».",
    ),
    "g_email_n42_updated": MessageLookupByLibrary.simpleMessage(
      "Адрес электронной почты аккаунта N42 обновлен.",
    ),
    "g_email_new_hint": MessageLookupByLibrary.simpleMessage(
      "Введите новый адрес электронной почты",
    ),
    "g_email_new_label": MessageLookupByLibrary.simpleMessage(
      "Новый адрес электронной почты",
    ),
    "g_email_pwd_hint": MessageLookupByLibrary.simpleMessage("Введите пароль"),
    "g_email_pwd_label": MessageLookupByLibrary.simpleMessage(
      "Текущий пароль (для чата)",
    ),
    "g_email_pwd_required": MessageLookupByLibrary.simpleMessage(
      "Требуется пароль для синхронизации чата",
    ),
    "g_email_resend": MessageLookupByLibrary.simpleMessage(
      "Отправить код повторно",
    ),
    "g_email_resend_countdown": m7,
    "g_email_send_code": MessageLookupByLibrary.simpleMessage(
      "Отправить код подтверждения",
    ),
    "g_email_skip": MessageLookupByLibrary.simpleMessage("Пропустить"),
    "g_email_skip_full": MessageLookupByLibrary.simpleMessage(
      "Пропустить – адрес электронной почты N42 уже обновлен.",
    ),
    "g_email_success": MessageLookupByLibrary.simpleMessage(
      "Электронная почта успешно обновлена",
    ),
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
    "g_face_liveness_failed": MessageLookupByLibrary.simpleMessage(
      "Лицо не обнаружено. Посмотрите прямо в камеру и повторите попытку.",
    ),
    "g_face_match_key1": MessageLookupByLibrary.simpleMessage(
      "Метод сопоставления лица",
    ),
    "g_face_match_key10": m8,
    "g_face_match_key11": m9,
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
    "g_face_match_key32": m10,
    "g_face_match_key33": MessageLookupByLibrary.simpleMessage("Отвязка"),
    "g_face_match_key34": MessageLookupByLibrary.simpleMessage(
      "Верификация биометрических данных лица не удалась!",
    ),
    "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
      "Отвязка биометрических данных лица не удалась!",
    ),
    "g_face_match_key4": m11,
    "g_face_match_key5": MessageLookupByLibrary.simpleMessage("Ошибка адреса!"),
    "g_face_match_key6": MessageLookupByLibrary.simpleMessage(
      "Привязка биометрических данных лица",
    ),
    "g_face_match_key7": MessageLookupByLibrary.simpleMessage(
      "Сопоставление лица",
    ),
    "g_face_match_key8": MessageLookupByLibrary.simpleMessage("Выбрать заново"),
    "g_face_match_key9": MessageLookupByLibrary.simpleMessage("Сопоставить"),
    "g_face_network_error": MessageLookupByLibrary.simpleMessage(
      "Ошибка сети. Проверьте подключение и повторите попытку.",
    ),
    "g_face_sdk_init_failed": MessageLookupByLibrary.simpleMessage(
      "Не удалось запустить распознавание лиц. Повторите попытку.",
    ),
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
    "g_key_135": m12,
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
    "g_key_214": m13,
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
    "g_key_46": m14,
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
      "Аккаунт успешно создан",
    ),
    "g_key_aa_account_details": MessageLookupByLibrary.simpleMessage(
      "Детали учетной записи",
    ),
    "g_key_aa_account_name": MessageLookupByLibrary.simpleMessage(
      "Имя учетной записи",
    ),
    "g_key_aa_account_name_hint": MessageLookupByLibrary.simpleMessage(
      "Введите имя учетной записи",
    ),
    "g_key_aa_account_type": MessageLookupByLibrary.simpleMessage(
      "Тип учетной записи",
    ),
    "g_key_aa_active": MessageLookupByLibrary.simpleMessage("Активный"),
    "g_key_aa_add_first_operation": MessageLookupByLibrary.simpleMessage(
      "Добавьте свою первую операцию",
    ),
    "g_key_aa_add_operation": MessageLookupByLibrary.simpleMessage(
      "Добавить операцию",
    ),
    "g_key_aa_address_calculating": MessageLookupByLibrary.simpleMessage(
      "Вычисление адреса...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "Не удалось вычислить адрес. Попробуйте ещё раз.",
    ),
    "g_key_aa_address_preview": MessageLookupByLibrary.simpleMessage(
      "Этот адрес заранее вычисляется и будет использован при совершении первой транзакции.",
    ),
    "g_key_aa_approve": MessageLookupByLibrary.simpleMessage("Утвердить"),
    "g_key_aa_batch": MessageLookupByLibrary.simpleMessage("Пакетный"),
    "g_key_aa_batch_atomic": MessageLookupByLibrary.simpleMessage(
      "Атомное исполнение",
    ),
    "g_key_aa_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Выполнять несколько операций одновременно",
    ),
    "g_key_aa_batch_description": MessageLookupByLibrary.simpleMessage(
      "Отправка нескольких транзакций за одну операцию",
    ),
    "g_key_aa_batch_failed": MessageLookupByLibrary.simpleMessage(
      "Пакетное выполнение не удалось",
    ),
    "g_key_aa_batch_no_templates": MessageLookupByLibrary.simpleMessage(
      "Нет сохраненных шаблонов",
    ),
    "g_key_aa_batch_operations": MessageLookupByLibrary.simpleMessage(
      "Пакетные операции",
    ),
    "g_key_aa_batch_save_gas": MessageLookupByLibrary.simpleMessage(
      "Экономьте газ",
    ),
    "g_key_aa_batch_save_template": MessageLookupByLibrary.simpleMessage(
      "Сохранить как шаблон",
    ),
    "g_key_aa_batch_submitting": MessageLookupByLibrary.simpleMessage(
      "Отправка...",
    ),
    "g_key_aa_batch_success": MessageLookupByLibrary.simpleMessage(
      "Пакет успешно отправлен",
    ),
    "g_key_aa_batch_template_load": MessageLookupByLibrary.simpleMessage(
      "Загрузить шаблон",
    ),
    "g_key_aa_batch_template_name": MessageLookupByLibrary.simpleMessage(
      "Имя шаблона",
    ),
    "g_key_aa_batch_template_name_hint": MessageLookupByLibrary.simpleMessage(
      "Введите название шаблона",
    ),
    "g_key_aa_batch_template_saved": MessageLookupByLibrary.simpleMessage(
      "Шаблон сохранен.",
    ),
    "g_key_aa_batch_templates": MessageLookupByLibrary.simpleMessage("Шаблоны"),
    "g_key_aa_batch_title": MessageLookupByLibrary.simpleMessage(
      "Пакетная передача",
    ),
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage(
      "Пакетная транзакция",
    ),
    "g_key_aa_benefit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Одобрение и обмен за одну транзакцию — больше никаких двухэтапных подтверждений",
    ),
    "g_key_aa_benefit_batch_title": MessageLookupByLibrary.simpleMessage(
      "Пакетные действия в один клик",
    ),
    "g_key_aa_benefit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "Спонсируйте транзакции или платите комиссии токенами ERC-20 вместо ETH.",
    ),
    "g_key_aa_benefit_gas_title": MessageLookupByLibrary.simpleMessage(
      "Оплатите газ любым токеном",
    ),
    "g_key_aa_benefit_recovery_desc": MessageLookupByLibrary.simpleMessage(
      "Восстановите доступ через доверенные контакты, если вы потеряете закрытый ключ",
    ),
    "g_key_aa_benefit_recovery_title": MessageLookupByLibrary.simpleMessage(
      "Социальное восстановление",
    ),
    "g_key_aa_biconomy_account": MessageLookupByLibrary.simpleMessage(
      "Аккаунт Biconomy",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "Модульный смарт-аккаунт ERC-7579 с поддержкой транзакций без газа",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("по"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("Цепь"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage(
      "Идентификатор цепочки",
    ),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("Изменить"),
    "g_key_aa_check_status": MessageLookupByLibrary.simpleMessage(
      "Проверить статус",
    ),
    "g_key_aa_clear_all": MessageLookupByLibrary.simpleMessage("Очистить все"),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage("Скоро"),
    "g_key_aa_continue": MessageLookupByLibrary.simpleMessage("Продолжить"),
    "g_key_aa_contract": MessageLookupByLibrary.simpleMessage("Контракт"),
    "g_key_aa_counterfactual_address": MessageLookupByLibrary.simpleMessage(
      "Контрфактическое обращение",
    ),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "Это контрфактическое обращение. Он будет развернут при вашей первой транзакции.",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "Создать смарт-аккаунт",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "Создайте свой первый смарт-аккаунт",
    ),
    "g_key_aa_create_first_account": MessageLookupByLibrary.simpleMessage(
      "Создайте смарт-аккаунт, чтобы начать",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "Создать сеансовый ключ",
    ),
    "g_key_aa_create_session_desc": MessageLookupByLibrary.simpleMessage(
      "Ключи сеанса позволяют DApps выполнять транзакции от вашего имени с ограниченными разрешениями и ограничениями по времени.",
    ),
    "g_key_aa_create_smart_account": MessageLookupByLibrary.simpleMessage(
      "Создать смарт-аккаунт",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("Создано"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("Пользовательский"),
    "g_key_aa_deploy": MessageLookupByLibrary.simpleMessage("Развертывание"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "Учетная запись будет развернута автоматически при вашей первой транзакции.",
    ),
    "g_key_aa_deploy_failed": MessageLookupByLibrary.simpleMessage(
      "Развертывание не удалось",
    ),
    "g_key_aa_deploy_failed_desc": MessageLookupByLibrary.simpleMessage(
      "Развертывание не удалось. Пожалуйста, попробуйте еще раз.",
    ),
    "g_key_aa_deploy_started": MessageLookupByLibrary.simpleMessage(
      "Развертывание началось",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("Развернуто"),
    "g_key_aa_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "Аккаунт готов к использованию",
    ),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage(
      "Развертывание...",
    ),
    "g_key_aa_deploying_desc": MessageLookupByLibrary.simpleMessage(
      "Транзакция развертывания обрабатывается",
    ),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "Развертывание произойдет автоматически при первой транзакции.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "Испытайте новое поколение учетных записей Ethereum с расширенными функциями.",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("Подробности"),
    "g_key_aa_eip7702_account": MessageLookupByLibrary.simpleMessage(
      "Учетная запись EIP-7702",
    ),
    "g_key_aa_eip7702_badge": MessageLookupByLibrary.simpleMessage("ЭИП-7702"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "Гибридная учетная запись EOA/Smart Account — развертывание не требуется",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("Ошибка"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "Расчетный газ",
    ),
    "g_key_aa_estimating": MessageLookupByLibrary.simpleMessage("Оценка..."),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage(
      "Выполнить пакетно",
    ),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage(
      "Срок действия истек",
    ),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage(
      "Срок действия истекает",
    ),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("Фабрика"),
    "g_key_aa_feature_batch": MessageLookupByLibrary.simpleMessage(
      "Пакетная обработка нескольких транзакций",
    ),
    "g_key_aa_feature_gas": MessageLookupByLibrary.simpleMessage(
      "Оплатить газ любым токеном",
    ),
    "g_key_aa_feature_security": MessageLookupByLibrary.simpleMessage(
      "Повышенная безопасность",
    ),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("БЕСПЛАТНО"),
    "g_key_aa_full_access": MessageLookupByLibrary.simpleMessage(
      "Полный доступ",
    ),
    "g_key_aa_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Оценка газа",
    ),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "Оценка газа не удалась, используется значение по умолчанию",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage("Оплата газа"),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Варианты оплаты газа",
    ),
    "g_key_aa_gas_savings": MessageLookupByLibrary.simpleMessage(
      "Экономия газа",
    ),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "Спонсор газа",
    ),
    "g_key_aa_gas_warn_call_high": MessageLookupByLibrary.simpleMessage(
      "Газ выполнения высокий",
    ),
    "g_key_aa_gas_warn_call_high_desc": m15,
    "g_key_aa_gas_warn_deploy": MessageLookupByLibrary.simpleMessage(
      "Накладные расходы газа развёртывания",
    ),
    "g_key_aa_gas_warn_deploy_desc": m16,
    "g_key_aa_gas_warn_paymaster": MessageLookupByLibrary.simpleMessage(
      "Высокие накладные расходы Paymaster",
    ),
    "g_key_aa_gas_warn_paymaster_desc": m17,
    "g_key_aa_gas_warn_total_high": MessageLookupByLibrary.simpleMessage(
      "Лимит газа очень высокий",
    ),
    "g_key_aa_gas_warn_total_high_desc": m18,
    "g_key_aa_gas_warn_under_est": MessageLookupByLibrary.simpleMessage(
      "Возможная недооценка газа",
    ),
    "g_key_aa_gas_warn_under_est_desc": MessageLookupByLibrary.simpleMessage(
      "Фактически использованный газ может превысить оценку. Рассмотрите добавление большего буфера.",
    ),
    "g_key_aa_gas_warn_verify_high": MessageLookupByLibrary.simpleMessage(
      "Газ верификации высокий",
    ),
    "g_key_aa_gas_warn_verify_high_desc": m19,
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("Безгазовый"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "Безгазовые транзакции и пакетные операции",
    ),
    "g_key_aa_home_title": MessageLookupByLibrary.simpleMessage(
      "Абстракция аккаунта",
    ),
    "g_key_aa_just_now": MessageLookupByLibrary.simpleMessage("только что"),
    "g_key_aa_kernel_account": MessageLookupByLibrary.simpleMessage(
      "Учетная запись ядра",
    ),
    "g_key_aa_kernel_desc": MessageLookupByLibrary.simpleMessage(
      "Модульная учетная запись с поддержкой плагинов от ZeroDev.",
    ),
    "g_key_aa_label": MessageLookupByLibrary.simpleMessage("Этикетка"),
    "g_key_aa_last_activity": MessageLookupByLibrary.simpleMessage(
      "Последняя активность",
    ),
    "g_key_aa_my_accounts": MessageLookupByLibrary.simpleMessage(
      "Мои смарт-аккаунты",
    ),
    "g_key_aa_never": MessageLookupByLibrary.simpleMessage("Никогда"),
    "g_key_aa_no_accounts": MessageLookupByLibrary.simpleMessage(
      "Смарт-аккаунтов пока нет",
    ),
    "g_key_aa_no_accounts_filter": MessageLookupByLibrary.simpleMessage(
      "Нет аккаунтов, соответствующих вашему фильтру.",
    ),
    "g_key_aa_no_operations": MessageLookupByLibrary.simpleMessage(
      "Операции не добавлены",
    ),
    "g_key_aa_no_session_keys": MessageLookupByLibrary.simpleMessage(
      "Нет сеансовых ключей",
    ),
    "g_key_aa_not_deployed": MessageLookupByLibrary.simpleMessage(
      "Не развернуто",
    ),
    "g_key_aa_not_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "Аккаунт будет развернут при первой транзакции",
    ),
    "g_key_aa_onboard_step1": MessageLookupByLibrary.simpleMessage(
      "Создайте смарт-аккаунт (бесплатно, ETH не требуется)",
    ),
    "g_key_aa_onboard_step2": MessageLookupByLibrary.simpleMessage(
      "Пополните счет — получите любой токен EVM",
    ),
    "g_key_aa_onboard_step3": MessageLookupByLibrary.simpleMessage(
      "Совершайте безгазовые транзакции с Paymaster",
    ),
    "g_key_aa_operations": MessageLookupByLibrary.simpleMessage("Операции"),
    "g_key_aa_owner": MessageLookupByLibrary.simpleMessage("Владелец"),
    "g_key_aa_pay_gas_with_token": MessageLookupByLibrary.simpleMessage(
      "Оплатить бензин жетоном",
    ),
    "g_key_aa_pay_gas_yourself": MessageLookupByLibrary.simpleMessage(
      "Оплачивайте газ с помощью ETH",
    ),
    "g_key_aa_pay_with": MessageLookupByLibrary.simpleMessage(
      "Оплатить с помощью",
    ),
    "g_key_aa_pay_with_eth": MessageLookupByLibrary.simpleMessage(
      "Оплатить ETH",
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
      "Выберите способ оплаты комиссий за газ за транзакцию.",
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
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("Ожидается"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("Разрешение"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "Предварительный адрес",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("Готово"),
    "g_key_aa_receive_address": MessageLookupByLibrary.simpleMessage(
      "Получить адрес",
    ),
    "g_key_aa_recommended": MessageLookupByLibrary.simpleMessage(
      "Рекомендуется",
    ),
    "g_key_aa_retry": MessageLookupByLibrary.simpleMessage("Повторить попытку"),
    "g_key_aa_revoke": MessageLookupByLibrary.simpleMessage("Отозвать"),
    "g_key_aa_revoke_confirm": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите отозвать этот сеансовый ключ? Авторизованное DApp больше не сможет выполнять транзакции.",
    ),
    "g_key_aa_revoke_session": MessageLookupByLibrary.simpleMessage(
      "Отозвать сеансовый ключ",
    ),
    "g_key_aa_revoked": MessageLookupByLibrary.simpleMessage(
      "Ключ сеанса отозван",
    ),
    "g_key_aa_revoked_status": MessageLookupByLibrary.simpleMessage("Отозван"),
    "g_key_aa_revoking": MessageLookupByLibrary.simpleMessage(
      "Отзыв сеансового ключа...",
    ),
    "g_key_aa_safe_account": MessageLookupByLibrary.simpleMessage(
      "Безопасный аккаунт",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "Учетная запись с несколькими подписями и расширенными функциями безопасности",
    ),
    "g_key_aa_safe_guardians": MessageLookupByLibrary.simpleMessage(
      "Хранители",
    ),
    "g_key_aa_safe_threshold": MessageLookupByLibrary.simpleMessage("Порог"),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("сохранено"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "Выберите цепочку",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Выберите Paymaster",
    ),
    "g_key_aa_select_type": MessageLookupByLibrary.simpleMessage(
      "Выберите тип учетной записи",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("Выбрано"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "Отправляйте токены, используя свой смарт-аккаунт",
    ),
    "g_key_aa_send_title": MessageLookupByLibrary.simpleMessage("АА Трансфер"),
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
      "Детали сеансового ключа",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage(
      "Действительно в течение",
    ),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "Высокий риск — только проверенные DApp",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage(
      "Сессионные ключи",
    ),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "Авторизуйте DApps с временным доступом к вашей смарт-учетной записи",
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
      "Простой аккаунт",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "Базовая смарт-учетная запись с одним владельцем — рекомендуется для большинства пользователей.",
    ),
    "g_key_aa_smart_account": MessageLookupByLibrary.simpleMessage(
      "Смарт-аккаунт",
    ),
    "g_key_aa_smart_accounts": MessageLookupByLibrary.simpleMessage(
      "Смарт-аккаунты",
    ),
    "g_key_aa_smart_wallet": MessageLookupByLibrary.simpleMessage(
      "Умный кошелек",
    ),
    "g_key_aa_spending_limit": MessageLookupByLibrary.simpleMessage(
      "Лимит расходов",
    ),
    "g_key_aa_sponsored": MessageLookupByLibrary.simpleMessage(
      "Спонсорский (бесплатно)",
    ),
    "g_key_aa_title": MessageLookupByLibrary.simpleMessage("Смарт-аккаунт"),
    "g_key_aa_total_gas": MessageLookupByLibrary.simpleMessage("Всего газа"),
    "g_key_aa_total_value": MessageLookupByLibrary.simpleMessage(
      "Общая стоимость",
    ),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage("Транзакции"),
    "g_key_aa_unavailable": MessageLookupByLibrary.simpleMessage("Недоступно"),
    "g_key_aa_version_v07": MessageLookupByLibrary.simpleMessage("v0.7"),
    "g_key_aa_version_v08": MessageLookupByLibrary.simpleMessage("v0.8"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage("Посмотреть все"),
    "g_key_account_linked": MessageLookupByLibrary.simpleMessage(
      "Аккаунт успешно связан",
    ),
    "g_key_account_unlinked": MessageLookupByLibrary.simpleMessage(
      "Аккаунт успешно отключен",
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
      "Расширенные функции",
    ),
    "g_key_airdrop_active": MessageLookupByLibrary.simpleMessage("Активный"),
    "g_key_airdrop_check_eligibility": MessageLookupByLibrary.simpleMessage(
      "Проверить соответствие",
    ),
    "g_key_airdrop_claim": MessageLookupByLibrary.simpleMessage("Получить"),
    "g_key_airdrop_claimed": MessageLookupByLibrary.simpleMessage("Получено"),
    "g_key_airdrop_days_left": m20,
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
      "Вход в Apple отменен",
    ),
    "g_key_apply": MessageLookupByLibrary.simpleMessage("Применить"),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage(
      "Добавить получателя",
    ),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage(
      "Трансляция...",
    ),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage(
      "Очистить всё",
    ),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Подтвердить пакетную передачу",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("Продолжить"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "Формат CSV: адрес,сумма,метка",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("Готово"),
    "g_key_batch_duplicate_address": m21,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Оценка газа...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "Пакетная передача поддерживает только цепочки EVM.",
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
      "Справка по пакетному переносу",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "Импорт CSV",
    ),
    "g_key_batch_insufficient_balance": m22,
    "g_key_batch_invalid_address": m23,
    "g_key_batch_invalid_amount": m24,
    "g_key_batch_max_recipients": m25,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "Памятка не является обязательной",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Используйте Multicall3 для снижения платы за газ",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "Нет поддерживаемых токенов",
    ),
    "g_key_batch_preview": MessageLookupByLibrary.simpleMessage("Предпросмотр"),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage(
      "Получатели",
    ),
    "g_key_batch_select_token": MessageLookupByLibrary.simpleMessage(
      "Выберите токен",
    ),
    "g_key_batch_send_multiple": MessageLookupByLibrary.simpleMessage(
      "Отправляйте токены на несколько адресов за одну транзакцию",
    ),
    "g_key_batch_signing": MessageLookupByLibrary.simpleMessage(
      "Подписание...",
    ),
    "g_key_batch_swipe_remove": MessageLookupByLibrary.simpleMessage(
      "Проведите пальцем влево, чтобы удалить получателя",
    ),
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage(
      "Пакетный перевод",
    ),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage(
      "Общая сумма",
    ),
    "g_key_bridge_amount": MessageLookupByLibrary.simpleMessage("Сумма"),
    "g_key_bridge_chain_not_supported": MessageLookupByLibrary.simpleMessage(
      "Цепочка не поддерживается",
    ),
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
    "g_key_bridge_select": MessageLookupByLibrary.simpleMessage("Выбрать"),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage(
      "Выбрать токен",
    ),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage(
      "Проскальзывание",
    ),
    "g_key_bridge_status_completed": MessageLookupByLibrary.simpleMessage(
      "Завершено",
    ),
    "g_key_bridge_status_failed": MessageLookupByLibrary.simpleMessage(
      "Не удалось",
    ),
    "g_key_bridge_status_in_progress": MessageLookupByLibrary.simpleMessage(
      "В процессе",
    ),
    "g_key_bridge_status_pending": MessageLookupByLibrary.simpleMessage(
      "Ожидается",
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
    "g_key_btc_redeem_locked_until": MessageLookupByLibrary.simpleMessage(
      "Заблокировано до",
    ),
    "g_key_btc_redeem_reminder": MessageLookupByLibrary.simpleMessage(
      "Прежде чем отправлять погашение, убедитесь, что период блокировки истек.",
    ),
    "g_key_btc_redeem_still_locked": MessageLookupByLibrary.simpleMessage(
      "BTC все еще заблокирован",
    ),
    "g_key_btc_redeem_title": MessageLookupByLibrary.simpleMessage(
      "Погасить vBTC",
    ),
    "g_key_btc_redeem_unlocked": MessageLookupByLibrary.simpleMessage(
      "Разблокировано — готово к выкупу",
    ),
    "g_key_btc_stake_acknowledge": MessageLookupByLibrary.simpleMessage(
      "Я понимаю риски и хочу продолжить",
    ),
    "g_key_btc_stake_continue": MessageLookupByLibrary.simpleMessage(
      "Продолжить ставку",
    ),
    "g_key_btc_stake_how_it_works": MessageLookupByLibrary.simpleMessage(
      "Как это работает",
    ),
    "g_key_btc_stake_reminder": MessageLookupByLibrary.simpleMessage(
      "BTC будет заблокирован до истечения срока блокировки. Завершите процесс ставок в интерфейсе ниже.",
    ),
    "g_key_btc_stake_risk1": MessageLookupByLibrary.simpleMessage(
      "Ваш BTC будет заблокирован на весь период ставок. Досрочный вывод средств невозможен.",
    ),
    "g_key_btc_stake_risk2": MessageLookupByLibrary.simpleMessage(
      "Блокировка обеспечивается Bitcoin OP_CHECKLOCKTIMEVERIFY (CLTV), и ее нельзя обойти.",
    ),
    "g_key_btc_stake_risk3": MessageLookupByLibrary.simpleMessage(
      "Риск смарт-контракта: хотя он и проверяется, ни один протокол не является полностью безопасным от риска.",
    ),
    "g_key_btc_stake_risk4": MessageLookupByLibrary.simpleMessage(
      "Минимальная ставка: 0,001 BTC. Минимальный период блокировки: 0,125 дня (~3 часа).",
    ),
    "g_key_btc_stake_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Предупреждение о риске",
    ),
    "g_key_btc_stake_step1_desc": MessageLookupByLibrary.simpleMessage(
      "Ваш BTC заблокирован по мультиподписному адресу 2 из 2 с временной блокировкой (CLTV), защищенным вашим ключом и ключом контейнера N42.",
    ),
    "g_key_btc_stake_step1_title": MessageLookupByLibrary.simpleMessage(
      "Заблокируйте свой BTC",
    ),
    "g_key_btc_stake_step2_desc": MessageLookupByLibrary.simpleMessage(
      "После подтверждения в цепочке vBTC зачисляется в ваш кошелек в соотношении 1:1.",
    ),
    "g_key_btc_stake_step2_title": MessageLookupByLibrary.simpleMessage(
      "Монетный двор vBTC",
    ),
    "g_key_btc_stake_step3_desc": MessageLookupByLibrary.simpleMessage(
      "Удерживайте vBTC, чтобы получать вознаграждения за ставки. vBTC также можно использовать в протоколах DeFi.",
    ),
    "g_key_btc_stake_step3_title": MessageLookupByLibrary.simpleMessage(
      "Зарабатывайте награды",
    ),
    "g_key_btc_stake_step4_desc": MessageLookupByLibrary.simpleMessage(
      "Когда период блокировки истечет, сожгите свой vBTC, чтобы получить обратно исходный BTC.",
    ),
    "g_key_btc_stake_step4_title": MessageLookupByLibrary.simpleMessage(
      "Активировать после разблокировки",
    ),
    "g_key_btc_stake_subtitle": MessageLookupByLibrary.simpleMessage(
      "Блокируйте BTC, чтобы чеканить vBTC и получать награды",
    ),
    "g_key_btc_stake_title": MessageLookupByLibrary.simpleMessage(
      "Ставка на самостоятельное хранение BTC",
    ),
    "g_key_burn_got_it": MessageLookupByLibrary.simpleMessage("понял"),
    "g_key_burn_nft_step1": MessageLookupByLibrary.simpleMessage(
      "1. Выберите токен с поддержкой NFT.",
    ),
    "g_key_burn_nft_step2": MessageLookupByLibrary.simpleMessage(
      "2. Перейдите на вкладку NFT.",
    ),
    "g_key_burn_nft_step3": MessageLookupByLibrary.simpleMessage(
      "3. Выберите NFT, который хотите записать.",
    ),
    "g_key_burn_nft_step4": MessageLookupByLibrary.simpleMessage(
      "4. Нажмите кнопку «Записать».",
    ),
    "g_key_burn_nft_steps": MessageLookupByLibrary.simpleMessage("Шаги:"),
    "g_key_burn_nft_tip": MessageLookupByLibrary.simpleMessage(
      "Чтобы записать NFT, перейдите на страницу сведений о NFT и нажмите кнопку «Записать».",
    ),
    "g_key_burn_nft_title": MessageLookupByLibrary.simpleMessage("Запись NFT"),
    "g_key_chain_transfer_not_supported": MessageLookupByLibrary.simpleMessage(
      "Эта цепочка пока не поддерживает переводы, следите за обновлениями",
    ),
    "g_key_change_email": MessageLookupByLibrary.simpleMessage(
      "Изменить адрес электронной почты",
    ),
    "g_key_change_password": MessageLookupByLibrary.simpleMessage(
      "Изменить пароль",
    ),
    "g_key_change_password_desc": MessageLookupByLibrary.simpleMessage(
      "Введите текущий пароль и установите новый пароль",
    ),
    "g_key_code_length": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите 6-значный код",
    ),
    "g_key_code_required": MessageLookupByLibrary.simpleMessage(
      "Требуется код подтверждения",
    ),
    "g_key_code_sent": MessageLookupByLibrary.simpleMessage(
      "Код подтверждения отправлен",
    ),
    "g_key_coin_list_all_hidden": MessageLookupByLibrary.simpleMessage(
      "Все активы ниже \$1",
    ),
    "g_key_coin_list_separator": MessageLookupByLibrary.simpleMessage(
      "Другие активы",
    ),
    "g_key_coin_list_show_all": MessageLookupByLibrary.simpleMessage(
      "Нажмите, чтобы показать все",
    ),
    "g_key_coin_search_recent": MessageLookupByLibrary.simpleMessage(
      "Недавние",
    ),
    "g_key_confirm_new_password": MessageLookupByLibrary.simpleMessage(
      "Подтвердите новый пароль",
    ),
    "g_key_continue_with_apple": MessageLookupByLibrary.simpleMessage(
      "Продолжить с Apple",
    ),
    "g_key_continue_with_google": MessageLookupByLibrary.simpleMessage(
      "Продолжить с Google",
    ),
    "g_key_deadline_reminders": MessageLookupByLibrary.simpleMessage(
      "Напоминания о сроках",
    ),
    "g_key_dex_approval_success": MessageLookupByLibrary.simpleMessage(
      "Одобрено! Нажмите «Обменять», чтобы продолжить.",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage(
      "Точная сумма",
    ),
    "g_key_dex_approve_required": m26,
    "g_key_dex_approve_unlimited": MessageLookupByLibrary.simpleMessage(
      "Без ограничений",
    ),
    "g_key_dex_approve_unlimited_info": MessageLookupByLibrary.simpleMessage(
      "Неограниченное одобрение: маршрутизатор может тратить этот токен в любое время. Стандартная практика, но опасна при компрометации контракта.",
    ),
    "g_key_dex_approving": MessageLookupByLibrary.simpleMessage("Одобрение…"),
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
    "g_key_dex_min_received": MessageLookupByLibrary.simpleMessage(
      "Мин. Получено",
    ),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage(
      "Токены отсутствуют",
    ),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "Токены не найдены",
    ),
    "g_key_dex_price_chart": MessageLookupByLibrary.simpleMessage(
      "График цены",
    ),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage(
      "Влияние на Цену",
    ),
    "g_key_dex_price_impact_high": m27,
    "g_key_dex_quote_expires": m28,
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Ошибка котировки",
    ),
    "g_key_dex_quote_refreshed": MessageLookupByLibrary.simpleMessage(
      "Котировка обновлена",
    ),
    "g_key_dex_retry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "Поиск по символу / имени / адресу",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage("Выбрать"),
    "g_key_dex_slippage": MessageLookupByLibrary.simpleMessage(
      "Допуск Проскальзывания",
    ),
    "g_key_dex_slippage_label": MessageLookupByLibrary.simpleMessage(
      "Макс. проскальзывание",
    ),
    "g_key_dex_sol_note": MessageLookupByLibrary.simpleMessage(
      "Своп Solana: подпишите транзакцию в своем кошельке Solana.",
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
      "Служба имен Солана",
    ),
    "g_key_domain_sns_not_found": MessageLookupByLibrary.simpleMessage(
      "Домен Solana не найден",
    ),
    "g_key_domain_ud_name": MessageLookupByLibrary.simpleMessage(
      "Неудержимые домены",
    ),
    "g_key_domain_ud_not_found": MessageLookupByLibrary.simpleMessage(
      "Домен Unstoppable не найден или нет адреса для этой сети",
    ),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "Активные продукты",
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
      "Получите бесплатные токены",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "Межсетевой перевод",
    ),
    "g_key_earn_daily_bonus": MessageLookupByLibrary.simpleMessage(
      "Бонус за ежедневную регистрацию",
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
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage(
      "Зарабатывайте больше",
    ),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "Нативная ставка Solana",
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
      "Зарабатывайте баллы ежедневно",
    ),
    "g_key_earn_pts_day": m29,
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage(
      "Быстрые инструменты",
    ),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage(
      "Рекомендуется",
    ),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage(
      "Выбрать тип обмена",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Ставьте ETH с помощью Lido",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("Обменять"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("Заработать"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage(
      "Общий доход",
    ),
    "g_key_earn_up_to_apy": m30,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage(
      "Посмотреть все",
    ),
    "g_key_eligibility_alerts": MessageLookupByLibrary.simpleMessage(
      "Оповещения о приемлемости",
    ),
    "g_key_eligible_only": MessageLookupByLibrary.simpleMessage(
      "Доступно только",
    ),
    "g_key_email": MessageLookupByLibrary.simpleMessage("электронная почта"),
    "g_key_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите действительный адрес электронной почты",
    ),
    "g_key_email_required": MessageLookupByLibrary.simpleMessage(
      "Требуется электронная почта",
    ),
    "g_key_ens_address_updated": MessageLookupByLibrary.simpleMessage(
      "Разрешенный адрес обновлен.",
    ),
    "g_key_ens_advanced": MessageLookupByLibrary.simpleMessage("Расширенный"),
    "g_key_ens_annual_fee": MessageLookupByLibrary.simpleMessage(
      "Ежегодная плата",
    ),
    "g_key_ens_available": MessageLookupByLibrary.simpleMessage("Доступно"),
    "g_key_ens_base_price": MessageLookupByLibrary.simpleMessage(
      "Базовая цена",
    ),
    "g_key_ens_checking": MessageLookupByLibrary.simpleMessage(
      "Проверяем наличие...",
    ),
    "g_key_ens_commit": MessageLookupByLibrary.simpleMessage("Зафиксировать"),
    "g_key_ens_commit_failed": MessageLookupByLibrary.simpleMessage(
      "Зафиксировать не удалось",
    ),
    "g_key_ens_commit_tx": MessageLookupByLibrary.simpleMessage(
      "Совершение транзакции...",
    ),
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "Срок действия обязательства о регистрации истёк. Пожалуйста, начните процесс регистрации заново.",
    ),
    "g_key_ens_committing": MessageLookupByLibrary.simpleMessage(
      "Совершение...",
    ),
    "g_key_ens_confirm_renew": MessageLookupByLibrary.simpleMessage(
      "Подтвердить продление",
    ),
    "g_key_ens_confirm_send": MessageLookupByLibrary.simpleMessage(
      "Подтвердить и отправить",
    ),
    "g_key_ens_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Подтвердите разрешение ENS",
    ),
    "g_key_ens_copy_address": MessageLookupByLibrary.simpleMessage(
      "Адрес скопирован",
    ),
    "g_key_ens_current_expiry": MessageLookupByLibrary.simpleMessage(
      "Текущий срок действия",
    ),
    "g_key_ens_days_left": MessageLookupByLibrary.simpleMessage(
      "осталось дней",
    ),
    "g_key_ens_description": MessageLookupByLibrary.simpleMessage(
      "Зарегистрируйте и управляйте своими доменными именами .eth",
    ),
    "g_key_ens_detected": MessageLookupByLibrary.simpleMessage(
      "Обнаружено имя ENS",
    ),
    "g_key_ens_duration": MessageLookupByLibrary.simpleMessage(
      "Период регистрации",
    ),
    "g_key_ens_edit_records": MessageLookupByLibrary.simpleMessage(
      "Редактировать записи",
    ),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage(
      "Срок действия истек",
    ),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage(
      "Срок действия истекает",
    ),
    "g_key_ens_expiring_soon": MessageLookupByLibrary.simpleMessage(
      "Срок действия скоро истекает",
    ),
    "g_key_ens_extend_period": MessageLookupByLibrary.simpleMessage(
      "Продлить период регистрации",
    ),
    "g_key_ens_failed": MessageLookupByLibrary.simpleMessage("Не удалось"),
    "g_key_ens_finalizing": MessageLookupByLibrary.simpleMessage(
      "Завершение регистрации",
    ),
    "g_key_ens_get_started": MessageLookupByLibrary.simpleMessage(
      "Начните работу с ENS",
    ),
    "g_key_ens_get_your_name": MessageLookupByLibrary.simpleMessage(
      "Получите свое .eth-имя",
    ),
    "g_key_ens_home_title": MessageLookupByLibrary.simpleMessage(
      "Менеджер ЭНС",
    ),
    "g_key_ens_invalid_address": MessageLookupByLibrary.simpleMessage(
      "Неверный адрес (должен быть 0x + 40 шестнадцатеричных символов)",
    ),
    "g_key_ens_invalid_name": MessageLookupByLibrary.simpleMessage(
      "Неверное имя ENS",
    ),
    "g_key_ens_is_yours": MessageLookupByLibrary.simpleMessage("теперь твой!"),
    "g_key_ens_keep_app_open": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, держите приложение открытым во время регистрации",
    ),
    "g_key_ens_manage_your_identity": MessageLookupByLibrary.simpleMessage(
      "Управляйте своей личностью Web3",
    ),
    "g_key_ens_management_title": MessageLookupByLibrary.simpleMessage(
      "Управление ЭНС",
    ),
    "g_key_ens_min_length": MessageLookupByLibrary.simpleMessage(
      "Минимум 3 символа",
    ),
    "g_key_ens_my_domains": MessageLookupByLibrary.simpleMessage("Мои домены"),
    "g_key_ens_name": MessageLookupByLibrary.simpleMessage("Название ЭНС"),
    "g_key_ens_new_expiry": MessageLookupByLibrary.simpleMessage(
      "Новый срок действия",
    ),
    "g_key_ens_new_owner": MessageLookupByLibrary.simpleMessage(
      "Новый адрес владельца",
    ),
    "g_key_ens_no_domains": MessageLookupByLibrary.simpleMessage(
      "Доменов пока нет",
    ),
    "g_key_ens_no_names": MessageLookupByLibrary.simpleMessage(
      "У вас пока нет имен ENS.",
    ),
    "g_key_ens_owned_names": MessageLookupByLibrary.simpleMessage(
      "Мои имена в ENS",
    ),
    "g_key_ens_owner": MessageLookupByLibrary.simpleMessage("Владелец"),
    "g_key_ens_please_wait": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, подождите",
    ),
    "g_key_ens_premium_name": MessageLookupByLibrary.simpleMessage(
      "Премиум-имя",
    ),
    "g_key_ens_price_breakdown": MessageLookupByLibrary.simpleMessage(
      "Распределение цен",
    ),
    "g_key_ens_price_per_year": MessageLookupByLibrary.simpleMessage("в год"),
    "g_key_ens_primary": MessageLookupByLibrary.simpleMessage("Первичный"),
    "g_key_ens_primary_set": MessageLookupByLibrary.simpleMessage(
      "Основное имя успешно установлено",
    ),
    "g_key_ens_processing": MessageLookupByLibrary.simpleMessage(
      "Обработка...",
    ),
    "g_key_ens_purchase_title": MessageLookupByLibrary.simpleMessage(
      "Зарегистрировать ЭНС",
    ),
    "g_key_ens_records": MessageLookupByLibrary.simpleMessage("Рекорды"),
    "g_key_ens_register": MessageLookupByLibrary.simpleMessage(
      "Зарегистрироваться",
    ),
    "g_key_ens_register_description": MessageLookupByLibrary.simpleMessage(
      "Ваша децентрализованная личность на Ethereum",
    ),
    "g_key_ens_register_failed": MessageLookupByLibrary.simpleMessage(
      "Регистрация не удалась",
    ),
    "g_key_ens_register_now": MessageLookupByLibrary.simpleMessage(
      "Зарегистрируйтесь сейчас",
    ),
    "g_key_ens_register_tx": MessageLookupByLibrary.simpleMessage(
      "Регистрация имени...",
    ),
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage(
      "Регистрация...",
    ),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage(
      "Регистрационная информация",
    ),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "Период регистрации",
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
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("Продлить"),
    "g_key_ens_renew_cost": MessageLookupByLibrary.simpleMessage(
      "Стоимость продления",
    ),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "Продлите регистрацию домена",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "Продление прошло успешно",
    ),
    "g_key_ens_renew_title": MessageLookupByLibrary.simpleMessage(
      "Продлить ENS",
    ),
    "g_key_ens_resolution_failed": MessageLookupByLibrary.simpleMessage(
      "Разрешение ENS не удалось",
    ),
    "g_key_ens_resolved_address": MessageLookupByLibrary.simpleMessage(
      "Разрешенный адрес",
    ),
    "g_key_ens_resolving": MessageLookupByLibrary.simpleMessage(
      "Решение ENS...",
    ),
    "g_key_ens_search": MessageLookupByLibrary.simpleMessage("Поиск"),
    "g_key_ens_search_desc": MessageLookupByLibrary.simpleMessage(
      "Найти доступные имена .eth",
    ),
    "g_key_ens_search_hint": MessageLookupByLibrary.simpleMessage(
      "Поиск имени .eth",
    ),
    "g_key_ens_search_prompt": MessageLookupByLibrary.simpleMessage(
      "Введите имя ENS для поиска",
    ),
    "g_key_ens_search_register": MessageLookupByLibrary.simpleMessage(
      "Поиск и регистрация",
    ),
    "g_key_ens_search_title": MessageLookupByLibrary.simpleMessage("Поиск ENS"),
    "g_key_ens_self_transfer": MessageLookupByLibrary.simpleMessage(
      "Нельзя отправить на собственный адрес",
    ),
    "g_key_ens_service": MessageLookupByLibrary.simpleMessage(
      "Служба имен Эфириума",
    ),
    "g_key_ens_set_primary": MessageLookupByLibrary.simpleMessage(
      "Установить как основной",
    ),
    "g_key_ens_standard_name": MessageLookupByLibrary.simpleMessage(
      "Стандартное имя",
    ),
    "g_key_ens_start_registration": MessageLookupByLibrary.simpleMessage(
      "Начать регистрацию",
    ),
    "g_key_ens_step_1": MessageLookupByLibrary.simpleMessage("Шаг 1"),
    "g_key_ens_step_2": MessageLookupByLibrary.simpleMessage("Шаг 2"),
    "g_key_ens_step_3": MessageLookupByLibrary.simpleMessage("Шаг 3"),
    "g_key_ens_step_commit": MessageLookupByLibrary.simpleMessage(
      "Зафиксировать",
    ),
    "g_key_ens_step_register": MessageLookupByLibrary.simpleMessage(
      "Зарегистрироваться",
    ),
    "g_key_ens_step_success": MessageLookupByLibrary.simpleMessage("Успех"),
    "g_key_ens_step_wait": MessageLookupByLibrary.simpleMessage("Подожди"),
    "g_key_ens_subdomain_create": MessageLookupByLibrary.simpleMessage(
      "Создать субдомен",
    ),
    "g_key_ens_subdomain_created": MessageLookupByLibrary.simpleMessage(
      "Субдомен создан",
    ),
    "g_key_ens_subdomain_delete": MessageLookupByLibrary.simpleMessage(
      "Удалить субдомен",
    ),
    "g_key_ens_subdomain_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "Этот поддомен будет удален навсегда.",
    ),
    "g_key_ens_subdomain_deleted": MessageLookupByLibrary.simpleMessage(
      "Субдомен удален.",
    ),
    "g_key_ens_subdomain_empty": MessageLookupByLibrary.simpleMessage(
      "Поддоменов пока нет",
    ),
    "g_key_ens_subdomain_invalid_label": MessageLookupByLibrary.simpleMessage(
      "Используйте только буквы, цифры и дефисы",
    ),
    "g_key_ens_subdomain_label": MessageLookupByLibrary.simpleMessage(
      "Метка субдомена",
    ),
    "g_key_ens_subdomain_label_hint": MessageLookupByLibrary.simpleMessage(
      "например блог, почта, приложение",
    ),
    "g_key_ens_subdomain_owner": MessageLookupByLibrary.simpleMessage(
      "Адрес владельца",
    ),
    "g_key_ens_subdomain_owner_hint": MessageLookupByLibrary.simpleMessage(
      "Оставьте пустым, чтобы использовать текущий кошелек",
    ),
    "g_key_ens_subdomains": MessageLookupByLibrary.simpleMessage("Субдомены"),
    "g_key_ens_success": MessageLookupByLibrary.simpleMessage("Успех!"),
    "g_key_ens_success_message": m31,
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage(
      "Предложения",
    ),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage(
      "Текстовые записи",
    ),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("Менеджер ЭНС"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("Итого"),
    "g_key_ens_total_cost": MessageLookupByLibrary.simpleMessage(
      "Общая стоимость",
    ),
    "g_key_ens_transfer": MessageLookupByLibrary.simpleMessage("Трансфер"),
    "g_key_ens_transfer_desc": MessageLookupByLibrary.simpleMessage(
      "Передача права собственности на другой адрес",
    ),
    "g_key_ens_transfer_success": MessageLookupByLibrary.simpleMessage(
      "Перенос успешен",
    ),
    "g_key_ens_transfer_warning": MessageLookupByLibrary.simpleMessage(
      "Передача необратима. Убедитесь, что адрес нового владельца правильный.",
    ),
    "g_key_ens_try_another": MessageLookupByLibrary.simpleMessage(
      "Попробуйте другое имя",
    ),
    "g_key_ens_two_step_process": MessageLookupByLibrary.simpleMessage(
      "Регистрация ENS — это двухэтапный процесс.",
    ),
    "g_key_ens_unavailable": MessageLookupByLibrary.simpleMessage("Недоступно"),
    "g_key_ens_wait": MessageLookupByLibrary.simpleMessage("Подожди"),
    "g_key_ens_wait_explanation": MessageLookupByLibrary.simpleMessage(
      "Период ожидания предотвращает быстрые атаки",
    ),
    "g_key_ens_wait_time_info": MessageLookupByLibrary.simpleMessage(
      "Период ожидания предотвращает опережение",
    ),
    "g_key_ens_wait_timer": m32,
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("Ожидание..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "Прежде чем продолжить, проверьте разрешенный адрес. Имена ENS могут передаваться или изменяться их владельцем.",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("год"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("годы"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "Ваша личность",
    ),
    "g_key_enter_confirm_password": MessageLookupByLibrary.simpleMessage(
      "Повторно введите новый пароль",
    ),
    "g_key_enter_email": MessageLookupByLibrary.simpleMessage(
      "Введите свой адрес электронной почты",
    ),
    "g_key_enter_new_password": MessageLookupByLibrary.simpleMessage(
      "Введите новый пароль",
    ),
    "g_key_enter_old_password": MessageLookupByLibrary.simpleMessage(
      "Введите текущий пароль",
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
    "g_key_ex_keystore_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Я понимаю, что любой, кто получит этот файл и пароль, будет иметь полный контроль над моими средствами — потеря необратима",
    ),
    "g_key_ex_keystore_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Введите пароль кошелька для подтверждения экспорта",
    ),
    "g_key_ex_pk_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Введите пароль кошелька для просмотра приватного ключа",
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
    "g_key_filter": MessageLookupByLibrary.simpleMessage("Фильтр"),
    "g_key_filter_type": MessageLookupByLibrary.simpleMessage("Тип"),
    "g_key_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Забыли пароль?",
    ),
    "g_key_gas_alert": MessageLookupByLibrary.simpleMessage("Газовая тревога"),
    "g_key_gas_alert_above": MessageLookupByLibrary.simpleMessage(
      "Оповещение, когда выше",
    ),
    "g_key_gas_alert_below": MessageLookupByLibrary.simpleMessage(
      "Оповещение, когда ниже",
    ),
    "g_key_gas_alert_save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "g_key_gas_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "Порог (Гвей)",
    ),
    "g_key_gas_auto_refresh": m33,
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
      "Цены на газ колеблются в зависимости от спроса в сети. Меньше газа = более медленное подтверждение, выше газа = более быстрое подтверждение.",
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
      "Ценовой тренд",
    ),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage(
      "Приоритетная комиссия",
    ),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "Цены на газ в реальном времени",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage("Настройки Gas"),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("Медленно"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("Стандарт"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage("Газовый трекер"),
    "g_key_gesture_medium": MessageLookupByLibrary.simpleMessage("Средний"),
    "g_key_gesture_strong": MessageLookupByLibrary.simpleMessage("Сильный"),
    "g_key_gesture_too_simple": MessageLookupByLibrary.simpleMessage(
      "Шаблон слишком простой, добавьте больше узлов",
    ),
    "g_key_gesture_weak": MessageLookupByLibrary.simpleMessage("Слабый"),
    "g_key_google_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Вход в Google отменен",
    ),
    "g_key_high_value_only": MessageLookupByLibrary.simpleMessage(
      "Только высокая стоимость",
    ),
    "g_key_hw_account_added": m34,
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "Аккаунт уже импортирован",
    ),
    "g_key_hw_accounts": MessageLookupByLibrary.simpleMessage("Аккаунты"),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("Добавить"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage(
      "Добавить аккаунт",
    ),
    "g_key_hw_add_account_content": m35,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Адрес скопирован",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Перед подключением убедитесь, что ваше устройство разблокировано и Bluetooth включен.",
    ),
    "g_key_hw_cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage(
      "Проверить приложение",
    ),
    "g_key_hw_confirm_on_device": MessageLookupByLibrary.simpleMessage(
      "Подтвердите на устройстве",
    ),
    "g_key_hw_connect": MessageLookupByLibrary.simpleMessage(
      "Подключить аппаратный кошелёк",
    ),
    "g_key_hw_connect_new_device": MessageLookupByLibrary.simpleMessage(
      "Подключить новое устройство",
    ),
    "g_key_hw_connect_new_keystone": MessageLookupByLibrary.simpleMessage(
      "Воздушный зазор с Keystone (QR)",
    ),
    "g_key_hw_connect_new_ledger": MessageLookupByLibrary.simpleMessage(
      "Подключить Леджер (Bluetooth)",
    ),
    "g_key_hw_connect_new_trezor": MessageLookupByLibrary.simpleMessage(
      "Подключите Трезор (USB)",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("Подключено"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage(
      "Подключение...",
    ),
    "g_key_hw_current_app_label": m36,
    "g_key_hw_days_ago": m37,
    "g_key_hw_derivation_path": MessageLookupByLibrary.simpleMessage(
      "Путь деривации",
    ),
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Отключить"),
    "g_key_hw_disconnected": MessageLookupByLibrary.simpleMessage("Отключено"),
    "g_key_hw_enable_bluetooth": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, включите Bluetooth",
    ),
    "g_key_hw_firmware": MessageLookupByLibrary.simpleMessage(
      "Версия прошивки",
    ),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("Назад"),
    "g_key_hw_import_failed": m38,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "Подключить Кистоун",
    ),
    "g_key_hw_keystone_invalid_response": MessageLookupByLibrary.simpleMessage(
      "Неверный ответ от устройства Keystone",
    ),
    "g_key_hw_keystone_scan_error": MessageLookupByLibrary.simpleMessage(
      "Не удалось проанализировать QR-код. Пожалуйста, попробуйте еще раз.",
    ),
    "g_key_hw_keystone_scan_request_hint": MessageLookupByLibrary.simpleMessage(
      "Отсканируйте этот QR-код с помощью устройства Keystone, чтобы подписать транзакцию.",
    ),
    "g_key_hw_keystone_scan_response_hint": MessageLookupByLibrary.simpleMessage(
      "Наведите камеру на QR-код, отображаемый на вашем устройстве Keystone.",
    ),
    "g_key_hw_keystone_scan_response_title":
        MessageLookupByLibrary.simpleMessage(
          "Сканировать трапецеидальную подпись",
        ),
    "g_key_hw_keystone_scan_xpub_hint": MessageLookupByLibrary.simpleMessage(
      "Отсканируйте QR-код на своем устройстве Keystone, чтобы импортировать учетные записи.",
    ),
    "g_key_hw_keystone_signature_received":
        MessageLookupByLibrary.simpleMessage("Подпись успешно получена"),
    "g_key_hw_keystone_signing": MessageLookupByLibrary.simpleMessage(
      "Ожидание подписи Keystone...",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Нажмите, чтобы отсканировать ответ Keystone",
    ),
    "g_key_hw_last_connected": m39,
    "g_key_hw_ledger": MessageLookupByLibrary.simpleMessage("Леджер"),
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
      "Ни одно приложение в данный момент не открыто",
    ),
    "g_key_hw_no_devices": MessageLookupByLibrary.simpleMessage(
      "Устройства не найдены",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Устройство не подключено",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Не подключен",
    ),
    "g_key_hw_open_app": m40,
    "g_key_hw_open_ledger_app_hint": m41,
    "g_key_hw_rejected": MessageLookupByLibrary.simpleMessage(
      "Отклонено на устройстве",
    ),
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("Удалить"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "Удалить устройство",
    ),
    "g_key_hw_remove_device_confirm": m42,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "Сохраненные устройства",
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
      "Поддерживаемые устройства",
    ),
    "g_key_hw_timeout": MessageLookupByLibrary.simpleMessage(
      "Тайм-аут подключения",
    ),
    "g_key_hw_title": MessageLookupByLibrary.simpleMessage(
      "Аппаратный кошелёк",
    ),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("Сегодня"),
    "g_key_hw_trezor": MessageLookupByLibrary.simpleMessage("Трезор"),
    "g_key_hw_trezor_connect_failed": MessageLookupByLibrary.simpleMessage(
      "Не удалось подключиться к Трезору. Убедитесь, что USB подключен.",
    ),
    "g_key_hw_trezor_connect_title": MessageLookupByLibrary.simpleMessage(
      "Подключить Трезор",
    ),
    "g_key_hw_trezor_connected": MessageLookupByLibrary.simpleMessage(
      "Трезор успешно подключился",
    ),
    "g_key_hw_trezor_connecting": MessageLookupByLibrary.simpleMessage(
      "Подключение к Трезору...",
    ),
    "g_key_hw_trezor_passphrase_required": MessageLookupByLibrary.simpleMessage(
      "Введите парольную фразу на своем устройстве Trezor",
    ),
    "g_key_hw_trezor_pin_required": MessageLookupByLibrary.simpleMessage(
      "Введите PIN-код на вашем устройстве Trezor",
    ),
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "Подключите устройство Trezor через USB-кабель и разблокируйте его.",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage(
      "Просмотр аккаунтов",
    ),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage(
      "Счета Кошелька",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("Вчера"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Кошелёк для данной валюты уже существует.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Не удалось прочитать Keystore",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage(
      "хранилище ключей",
    ),
    "g_key_link_account": MessageLookupByLibrary.simpleMessage(
      "Связать аккаунт",
    ),
    "g_key_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "Связанные аккаунты",
    ),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Войти"),
    "g_key_login_success": MessageLookupByLibrary.simpleMessage("Вход успешен"),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Выйти"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите выйти из приложения?",
    ),
    "g_key_loyalty_available_points": MessageLookupByLibrary.simpleMessage(
      "Доступно баллов",
    ),
    "g_key_loyalty_checked_today": MessageLookupByLibrary.simpleMessage(
      "Зарегистрировался сегодня!",
    ),
    "g_key_loyalty_checkin_btn": MessageLookupByLibrary.simpleMessage(
      "Зарегистрироваться",
    ),
    "g_key_loyalty_checkin_done": MessageLookupByLibrary.simpleMessage(
      "Готово",
    ),
    "g_key_loyalty_checkin_failed": MessageLookupByLibrary.simpleMessage(
      "Регистрация не удалась, попробуйте еще раз",
    ),
    "g_key_loyalty_checkin_success": MessageLookupByLibrary.simpleMessage(
      "Регистрация прошла успешно!",
    ),
    "g_key_loyalty_claim_points": MessageLookupByLibrary.simpleMessage(
      "Получить баллы",
    ),
    "g_key_loyalty_complete_failed": MessageLookupByLibrary.simpleMessage(
      "Задача не удалась, попробуйте еще раз",
    ),
    "g_key_loyalty_complete_success": MessageLookupByLibrary.simpleMessage(
      "Задача выполнена!",
    ),
    "g_key_loyalty_copy": MessageLookupByLibrary.simpleMessage("Копировать"),
    "g_key_loyalty_daily_checkin": MessageLookupByLibrary.simpleMessage(
      "Ежедневная отметка",
    ),
    "g_key_loyalty_earn_points": m43,
    "g_key_loyalty_earned": MessageLookupByLibrary.simpleMessage("Заработано"),
    "g_key_loyalty_history": MessageLookupByLibrary.simpleMessage(
      "История баллов",
    ),
    "g_key_loyalty_invite": MessageLookupByLibrary.simpleMessage("Пригласить"),
    "g_key_loyalty_invite_bonus": m44,
    "g_key_loyalty_invite_friends": MessageLookupByLibrary.simpleMessage(
      "Пригласить друзей",
    ),
    "g_key_loyalty_invited_friends": MessageLookupByLibrary.simpleMessage(
      "Приглашённые друзья",
    ),
    "g_key_loyalty_max_level": MessageLookupByLibrary.simpleMessage(
      "Максимальный уровень",
    ),
    "g_key_loyalty_next_prefix": MessageLookupByLibrary.simpleMessage("Далее"),
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
    "g_key_loyalty_points_to_next": m45,
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
    "g_key_loyalty_share": MessageLookupByLibrary.simpleMessage("Поделиться"),
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
      "Всего заработано",
    ),
    "g_key_loyalty_total_points": MessageLookupByLibrary.simpleMessage(
      "Всего баллов",
    ),
    "g_key_loyalty_used": MessageLookupByLibrary.simpleMessage("Б/у"),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Фейсбук"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Твиттер"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("Реддит"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("Браузер"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("Телеграмма"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("Раздор"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("Ютуб"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("Инстаграм"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("Рыночная капитализация"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("Объём торгов"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("Общий объём эмиссии"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("В обращении"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("О проекте"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("Ещё"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("Ссылки"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("Веб-сайт"),
    "g_key_manage_chains": MessageLookupByLibrary.simpleMessage(
      "Управление цепочками",
    ),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage("Доступно"),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "Требуется стейкинг",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage("Введите сид-фразу"),
    "g_key_new_airdrops": MessageLookupByLibrary.simpleMessage("Новые раздачи"),
    "g_key_new_password": MessageLookupByLibrary.simpleMessage("Новый пароль"),
    "g_key_new_password_same_as_old": MessageLookupByLibrary.simpleMessage(
      "Новый пароль должен отличаться от текущего пароля",
    ),
    "g_key_next": MessageLookupByLibrary.simpleMessage("Далее"),
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
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage(
      "Неверный адрес кошелька",
    ),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("Баланс"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "Это действие необратимо. NFT будет отправлен на адрес записи.",
    ),
    "g_key_nft_burn_evm_only": MessageLookupByLibrary.simpleMessage(
      "Запись поддерживается только в цепочках EVM.",
    ),
    "g_key_nft_burn_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Solana NFT-запись скоро начнется",
    ),
    "g_key_nft_burn_title": MessageLookupByLibrary.simpleMessage("Запись NFT"),
    "g_key_nft_collection": MessageLookupByLibrary.simpleMessage("Коллекция"),
    "g_key_nft_contract": MessageLookupByLibrary.simpleMessage("Контракт"),
    "g_key_nft_description": MessageLookupByLibrary.simpleMessage("Описание"),
    "g_key_nft_error_retry": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить NFT. Нажмите, чтобы повторить попытку.",
    ),
    "g_key_nft_filter_all": MessageLookupByLibrary.simpleMessage("Все"),
    "g_key_nft_filter_video": MessageLookupByLibrary.simpleMessage("Видео"),
    "g_key_nft_floor_price": MessageLookupByLibrary.simpleMessage("Этаж"),
    "g_key_nft_gallery": MessageLookupByLibrary.simpleMessage("Галерея НФТ"),
    "g_key_nft_inscription": MessageLookupByLibrary.simpleMessage("Надпись №"),
    "g_key_nft_no_items": MessageLookupByLibrary.simpleMessage(
      "NFT-файлы не найдены",
    ),
    "g_key_nft_no_url": MessageLookupByLibrary.simpleMessage(
      "Ссылка на проводник недоступна",
    ),
    "g_key_nft_no_video_support": MessageLookupByLibrary.simpleMessage(
      "Воспроизведение видео не поддерживается",
    ),
    "g_key_nft_open_browser": MessageLookupByLibrary.simpleMessage(
      "Посмотреть в Проводнике",
    ),
    "g_key_nft_ordinals": MessageLookupByLibrary.simpleMessage(
      "Порядковые номера",
    ),
    "g_key_nft_ordinals_unsupported": MessageLookupByLibrary.simpleMessage(
      "Передача порядковых номеров пока не поддерживается.",
    ),
    "g_key_nft_quantity": MessageLookupByLibrary.simpleMessage("Количество"),
    "g_key_nft_search_hint": MessageLookupByLibrary.simpleMessage(
      "Поиск по названию или коллекции",
    ),
    "g_key_nft_send": MessageLookupByLibrary.simpleMessage("Отправить NFT"),
    "g_key_nft_send_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Скоро появятся переводы Solana NFT",
    ),
    "g_key_nft_token_id": MessageLookupByLibrary.simpleMessage(
      "Идентификатор токена",
    ),
    "g_key_nft_type": MessageLookupByLibrary.simpleMessage("Тип"),
    "g_key_no_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "Нет связанных аккаунтов",
    ),
    "g_key_notification_settings": MessageLookupByLibrary.simpleMessage(
      "Настройки уведомлений",
    ),
    "g_key_oidc_login": MessageLookupByLibrary.simpleMessage(
      "Корпоративный вход (SSO)",
    ),
    "g_key_oidc_not_configured": MessageLookupByLibrary.simpleMessage(
      "Корпоративный единый вход не настроен",
    ),
    "g_key_old_password": MessageLookupByLibrary.simpleMessage(
      "Текущий пароль",
    ),
    "g_key_or": MessageLookupByLibrary.simpleMessage("или"),
    "g_key_password_changed_success": MessageLookupByLibrary.simpleMessage(
      "Пароль успешно изменен",
    ),
    "g_key_password_min_length": MessageLookupByLibrary.simpleMessage(
      "Пароль должен быть не менее 6 символов",
    ),
    "g_key_password_req_different": MessageLookupByLibrary.simpleMessage(
      "Отличается от текущего пароля",
    ),
    "g_key_password_req_length": MessageLookupByLibrary.simpleMessage(
      "Минимум 6 символов",
    ),
    "g_key_password_required": MessageLookupByLibrary.simpleMessage(
      "Требуется пароль",
    ),
    "g_key_password_requirements": MessageLookupByLibrary.simpleMessage(
      "Требования к паролю",
    ),
    "g_key_password_reset_success": MessageLookupByLibrary.simpleMessage(
      "Пароль успешно сброшен",
    ),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "Пароли не совпадают",
    ),
    "g_key_payment_amount_invalid": MessageLookupByLibrary.simpleMessage(
      "Неверная сумма",
    ),
    "g_key_payment_approx_token": m46,
    "g_key_payment_approx_usdt": m47,
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
    "g_key_resend_code": MessageLookupByLibrary.simpleMessage(
      "Повторно отправить код",
    ),
    "g_key_reset": MessageLookupByLibrary.simpleMessage("Сброс"),
    "g_key_reset_password": MessageLookupByLibrary.simpleMessage(
      "Сбросить пароль",
    ),
    "g_key_reset_password_email_desc": MessageLookupByLibrary.simpleMessage(
      "Введите свой адрес электронной почты, чтобы получить код подтверждения",
    ),
    "g_key_saml_login": MessageLookupByLibrary.simpleMessage("SAML-логин"),
    "g_key_saml_not_configured": MessageLookupByLibrary.simpleMessage(
      "SAML не настроен",
    ),
    "g_key_security_goplus_caution": MessageLookupByLibrary.simpleMessage(
      "Будьте осторожны",
    ),
    "g_key_security_goplus_checking": MessageLookupByLibrary.simpleMessage(
      "Проверка безопасности контракта...",
    ),
    "g_key_security_goplus_danger": MessageLookupByLibrary.simpleMessage(
      "Обнаружен высокий риск",
    ),
    "g_key_security_goplus_powered_by": MessageLookupByLibrary.simpleMessage(
      "ГоПлюс",
    ),
    "g_key_security_goplus_safe": MessageLookupByLibrary.simpleMessage(
      "Контракт проверен, безопасен",
    ),
    "g_key_send_code": MessageLookupByLibrary.simpleMessage(
      "Отправить код подтверждения",
    ),
    "g_key_send_memo_hint": MessageLookupByLibrary.simpleMessage(
      "Памятка/Примечание",
    ),
    "g_key_send_memo_label": MessageLookupByLibrary.simpleMessage(
      "Памятка/заметка (необязательно)",
    ),
    "g_key_set_new_password_desc": MessageLookupByLibrary.simpleMessage(
      "Установите новый пароль",
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
      "Войти не удалось",
    ),
    "g_key_sim_gas_estimate": m48,
    "g_key_sim_reverted": MessageLookupByLibrary.simpleMessage(
      "Транзакция, скорее всего, не удастся",
    ),
    "g_key_sim_reverted_reason": m49,
    "g_key_sim_simulating": MessageLookupByLibrary.simpleMessage(
      "Имитация транзакции…",
    ),
    "g_key_sim_success": MessageLookupByLibrary.simpleMessage(
      "Моделирование транзакции пройдено",
    ),
    "g_key_sim_unavailable": MessageLookupByLibrary.simpleMessage(
      "Моделирование недоступно для этой сети.",
    ),
    "g_key_social_login": MessageLookupByLibrary.simpleMessage(
      "Социальный вход",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Чат"),
    "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
      "Файл слишком большой для загрузки",
    ),
    "g_key_squad_k15": m50,
    "g_key_squad_k18": MessageLookupByLibrary.simpleMessage("Добавить контакт"),
    "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("Контакт"),
    "g_key_squad_k25": MessageLookupByLibrary.simpleMessage("Поиск по email"),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("Активный"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "Активные позиции",
    ),
    "g_key_stake_amount": MessageLookupByLibrary.simpleMessage("Сумма"),
    "g_key_stake_amount_unstake": MessageLookupByLibrary.simpleMessage(
      "Сумма для анстейкинга",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("APY"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("Средняя APY"),
    "g_key_stake_claim": MessageLookupByLibrary.simpleMessage(
      "Получить награды",
    ),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage("Комиссия"),
    "g_key_stake_d_unbond": m51,
    "g_key_stake_days_left": m52,
    "g_key_stake_days_remaining": m53,
    "g_key_stake_delegators": MessageLookupByLibrary.simpleMessage(
      "Делегаторы",
    ),
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "Оценка. Ежедневная награда",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "Оценка. Ежегодная награда",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage(
      "Перейти к обмену",
    ),
    "g_key_stake_liquid": MessageLookupByLibrary.simpleMessage(
      "Ликвидный стейкинг",
    ),
    "g_key_stake_liquid_staking_label": MessageLookupByLibrary.simpleMessage(
      "Жидкий стейкинг",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("Жидкость"),
    "g_key_stake_liquid_unstake_desc": MessageLookupByLibrary.simpleMessage(
      "Ваш ликвидный токен можно торговать напрямую на DEX. Используйте Swap, чтобы обменять его обратно на собственный актив.",
    ),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage("Мин. стейк"),
    "g_key_stake_no_active_positions": MessageLookupByLibrary.simpleMessage(
      "Нет активных позиций для анстейкинга",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage("Нет замка"),
    "g_key_stake_no_positions": MessageLookupByLibrary.simpleMessage(
      "Нет позиций стейкинга",
    ),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "Пока нет позиций для ставок",
    ),
    "g_key_stake_no_validators": MessageLookupByLibrary.simpleMessage(
      "Валидаторы не найдены",
    ),
    "g_key_stake_no_wallet": MessageLookupByLibrary.simpleMessage(
      "Адрес кошелька недоступен",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "Общий обзор ставок",
    ),
    "g_key_stake_pending_rewards": MessageLookupByLibrary.simpleMessage(
      "Ожидающие награды",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "Мои позиции",
    ),
    "g_key_stake_protocol": MessageLookupByLibrary.simpleMessage("Протокол"),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Протоколы"),
    "g_key_stake_restake": MessageLookupByLibrary.simpleMessage("Перестейкать"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("Награды"),
    "g_key_stake_search_validator": MessageLookupByLibrary.simpleMessage(
      "Поиск валидаторов...",
    ),
    "g_key_stake_select_a_validator": MessageLookupByLibrary.simpleMessage(
      "Выберите валидатор",
    ),
    "g_key_stake_select_position": MessageLookupByLibrary.simpleMessage(
      "Выберите позицию для отмены ставки",
    ),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "Выбрать валидатора",
    ),
    "g_key_stake_sort_by": MessageLookupByLibrary.simpleMessage(
      "Сортировать по",
    ),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("Застейкать"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("Ставка"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "Начать ставку",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("Стейкинг"),
    "g_key_stake_total_staked": MessageLookupByLibrary.simpleMessage(
      "Всего застейкано",
    ),
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage(
      "Транзакция успешно подготовлена",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage(
      "Разблокировка",
    ),
    "g_key_stake_unbonding_period": MessageLookupByLibrary.simpleMessage(
      "Период разблокировки",
    ),
    "g_key_stake_unbonding_warning": m54,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage("Снять стейк"),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage(
      "Обновление...",
    ),
    "g_key_stake_uptime": MessageLookupByLibrary.simpleMessage("Время работы"),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Валидатор"),
    "g_key_stake_validators": MessageLookupByLibrary.simpleMessage(
      "Валидаторы",
    ),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage(
      "Вы получите",
    ),
    "g_key_step_email": MessageLookupByLibrary.simpleMessage(
      "электронная почта",
    ),
    "g_key_step_password": MessageLookupByLibrary.simpleMessage("Пароль"),
    "g_key_step_verify": MessageLookupByLibrary.simpleMessage("Проверить"),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Завершено"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Цена газа"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Макс. комиссия за газ"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage(
      "Макс. плата за единицу газа",
    ),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("В ожидании"),
    "g_key_t_29": m55,
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
    "g_key_t_45": m56,
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
    "g_key_t_52": m57,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "У адреса получателя нет аккаунта, и первый перевод должен быть минимум 10XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Использовано газа"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Газ"),
    "g_key_time_days_ago": m58,
    "g_key_time_hours_ago": m59,
    "g_key_time_just_now": MessageLookupByLibrary.simpleMessage("только что"),
    "g_key_time_minutes_ago": m60,
    "g_key_token_discovery_add": MessageLookupByLibrary.simpleMessage(
      "Добавить",
    ),
    "g_key_token_discovery_add_selected": m61,
    "g_key_token_discovery_added": MessageLookupByLibrary.simpleMessage(
      "Токен добавлен",
    ),
    "g_key_token_discovery_banner": m62,
    "g_key_token_discovery_deselect_all": MessageLookupByLibrary.simpleMessage(
      "Отменить выбор всех",
    ),
    "g_key_token_discovery_empty": MessageLookupByLibrary.simpleMessage(
      "Новых токенов не найдено",
    ),
    "g_key_token_discovery_ignore": MessageLookupByLibrary.simpleMessage(
      "игнорировать",
    ),
    "g_key_token_discovery_select_all": MessageLookupByLibrary.simpleMessage(
      "Выбрать все",
    ),
    "g_key_token_discovery_title": MessageLookupByLibrary.simpleMessage(
      "Обнаруженные токены",
    ),
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage("История транзакций"),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage("Детали транзакции"),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage(
      "Просмотрите квитанции транзакций в истории",
    ),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("Сумма расхода"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("Сумма получения"),
    "g_key_tx_filter_date_from": MessageLookupByLibrary.simpleMessage(
      "Дата начала",
    ),
    "g_key_tx_filter_date_range": MessageLookupByLibrary.simpleMessage(
      "Диапазон дат",
    ),
    "g_key_tx_filter_date_to": MessageLookupByLibrary.simpleMessage(
      "Дата окончания",
    ),
    "g_key_tx_filter_direction": MessageLookupByLibrary.simpleMessage(
      "Направление",
    ),
    "g_key_tx_no_results": MessageLookupByLibrary.simpleMessage(
      "Нет транзакций, соответствующих вашему фильтру",
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
      "Отсоединить аккаунт",
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
    "g_key_uuid": MessageLookupByLibrary.simpleMessage("UUID"),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage(
      "Найдена последняя версия",
    ),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("Обновить сейчас"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage("Найдена новая версия"),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage(
      "У вас последняя версия",
    ),
    "g_key_verification_code": MessageLookupByLibrary.simpleMessage(
      "Код подтверждения",
    ),
    "g_key_verification_code_sent": m63,
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
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("одноразовый"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("Ускорить"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Заметка"),
    "g_key_wallet_m1": m64,
    "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите удалить аккаунт?",
    ),
    "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage(
      "Подтвердите выход",
    ),
    "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
      "Введите код Google Authenticator.",
    ),
    "g_key_wallet_m19": m65,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "Текущий токен не был добавлен.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Введите сид-фразу, разделяя слова пробелами",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage("Импорт кошелька"),
    "g_key_wallet_m3": m66,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "Недостаточный баланс текущего токена.",
    ),
    "g_key_wallet_m5": m67,
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
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "Введите адрес Эфириума (0x...)",
    ),
    "g_key_watch_only_banner": MessageLookupByLibrary.simpleMessage(
      "Только для просмотра",
    ),
    "g_key_watch_only_cant_send": MessageLookupByLibrary.simpleMessage(
      "Кошелек только для просмотра не может отправлять или подписывать транзакции",
    ),
    "g_key_watch_wallet": MessageLookupByLibrary.simpleMessage(
      "Смотреть кошелек",
    ),
    "g_key_watch_wallet_desc": MessageLookupByLibrary.simpleMessage(
      "Отслеживайте любой адрес EVM без закрытого ключа",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Зарезервировано"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Базовый резерв"),
    "g_key_xml_11": m68,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("Инкрементный резерв"),
    "g_key_xml_22": m69,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Количество принадлежащих объектов",
    ),
    "g_key_xml_33": m70,
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
    "g_lock_key21": m71,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Сбросить графический пароль",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Слишком много неверных попыток, сбросьте пароль",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Добавить пароль кошелька?",
    ),
    "g_lock_key25": m72,
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
    "g_market_30d_change": MessageLookupByLibrary.simpleMessage(
      "30D Изменение",
    ),
    "g_market_7d_change": MessageLookupByLibrary.simpleMessage("7D Изменение"),
    "g_market_ath": MessageLookupByLibrary.simpleMessage("АТН"),
    "g_market_atl": MessageLookupByLibrary.simpleMessage("АТЛ"),
    "g_market_depth": MessageLookupByLibrary.simpleMessage("Глубина рынка"),
    "g_market_empty_watchlist": MessageLookupByLibrary.simpleMessage(
      "Списка наблюдения пока нет",
    ),
    "g_market_empty_watchlist_hint": MessageLookupByLibrary.simpleMessage(
      "Нажмите ★ на любой монете, чтобы добавить ее.",
    ),
    "g_market_fdv": MessageLookupByLibrary.simpleMessage("ФДВ"),
    "g_market_high_24h": MessageLookupByLibrary.simpleMessage(
      "Высокий 24 часа",
    ),
    "g_market_liquidity_score": MessageLookupByLibrary.simpleMessage(
      "Оценка ликвидности",
    ),
    "g_market_low_24h": MessageLookupByLibrary.simpleMessage("Низкий 24 часа"),
    "g_market_news": MessageLookupByLibrary.simpleMessage("Новости"),
    "g_market_no_chart": MessageLookupByLibrary.simpleMessage(
      "Нет данных диаграммы",
    ),
    "g_market_no_results": MessageLookupByLibrary.simpleMessage(
      "Нет результатов",
    ),
    "g_market_rank": MessageLookupByLibrary.simpleMessage("Ранг"),
    "g_market_search": MessageLookupByLibrary.simpleMessage("Поиск"),
    "g_market_search_hint": MessageLookupByLibrary.simpleMessage(
      "Поиск монет...",
    ),
    "g_market_trending": MessageLookupByLibrary.simpleMessage("Тенденции"),
    "g_market_watchlist": MessageLookupByLibrary.simpleMessage(
      "Список наблюдения",
    ),
    "g_mining_inactivity_warning": MessageLookupByLibrary.simpleMessage(
      "Показатель неактивности валидатора высокий. Проверьте статус узла, чтобы избежать штрафов.",
    ),
    "g_mining_key15": MessageLookupByLibrary.simpleMessage(
      "Подробности задачи",
    ),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("Разблокировать N?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Активность облачной верификации",
    ),
    "g_mining_key33": MessageLookupByLibrary.simpleMessage(
      "Настройки проверки",
    ),
    "g_mining_key34": MessageLookupByLibrary.simpleMessage(
      "Фоновая музыка для проверки",
    ),
    "g_mining_key35": MessageLookupByLibrary.simpleMessage("По умолчанию"),
    "g_mining_key36": MessageLookupByLibrary.simpleMessage("Отключить звук"),
    "g_mining_key37": MessageLookupByLibrary.simpleMessage(
      "Если включена фоновая проверка, музыка будет воспроизводиться в фоновом режиме. Если музыка остановится, проверка также прекратится.",
    ),
    "g_mining_key38": MessageLookupByLibrary.simpleMessage("Ваш уровень"),
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
    "g_mining_key63": m73,
    "g_mining_key7": MessageLookupByLibrary.simpleMessage("Дата разблокировки"),
    "g_mining_key73": m74,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Я только что настроил ноду в @N42Wallet и начал верификацию на мобильных устройствах! Присоединяйтесь. Децентрализованное будущее — это мобильность!",
    ),
    "g_mining_key76": m75,
    "g_mining_key82": MessageLookupByLibrary.simpleMessage("Минерал"),
    "g_mining_key83": MessageLookupByLibrary.simpleMessage("Узел"),
    "g_mining_key84": MessageLookupByLibrary.simpleMessage("Сеть"),
    "g_mining_key85": MessageLookupByLibrary.simpleMessage(
      "Переключайтесь между тестовой сетью и основной сетью для облачного майнинга.",
    ),
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Выкуп доступен после 768 сек.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Запросы до этого момента не будут обработаны.",
    ),
    "g_mining_key_1": MessageLookupByLibrary.simpleMessage("Главная"),
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
    "g_mining_key_109": m76,
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
    "g_mining_key_116": m77,
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
      "Подробности задачи",
    ),
    "g_mining_key_19": MessageLookupByLibrary.simpleMessage("Резюме"),
    "g_mining_key_2": MessageLookupByLibrary.simpleMessage("Мероприятия"),
    "g_mining_key_20": MessageLookupByLibrary.simpleMessage(
      "Общая добытая стоимость",
    ),
    "g_mining_key_21": MessageLookupByLibrary.simpleMessage(
      "Проверка с момента",
    ),
    "g_mining_key_22": MessageLookupByLibrary.simpleMessage(
      "Распределение вознаграждений",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage(
      "Количество прибылей",
    ),
    "g_mining_key_24": MessageLookupByLibrary.simpleMessage(
      "Проверенная ценность",
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
    "g_mining_key_45": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите пропустить?",
    ),
    "g_mining_key_46": MessageLookupByLibrary.simpleMessage(
      "Вы не получите никаких вознаграждений за проверку, пока не выберете один из планов.",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Отключено"),
    "g_mining_key_48": MessageLookupByLibrary.simpleMessage("Награда"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("Показать ещё"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage(
      "Статус верификации",
    ),
    "g_mining_key_50": MessageLookupByLibrary.simpleMessage(
      "Чтобы разблокировать",
    ),
    "g_mining_key_52": MessageLookupByLibrary.simpleMessage("Пропустить"),
    "g_mining_key_58": MessageLookupByLibrary.simpleMessage("Прошлые 7 дней"),
    "g_mining_key_59": MessageLookupByLibrary.simpleMessage(
      "Накопленные награды",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Заблокируйте N для начала получения вознаграждений за верификацию.",
    ),
    "g_mining_key_60": MessageLookupByLibrary.simpleMessage("Награды получены"),
    "g_mining_key_61": MessageLookupByLibrary.simpleMessage("Расширенный"),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Начальный"),
    "g_mining_key_63": MessageLookupByLibrary.simpleMessage("Про"),
    "g_mining_key_64": MessageLookupByLibrary.simpleMessage("ПОЛНЫЙ УЗЕЛ"),
    "g_mining_key_65": MessageLookupByLibrary.simpleMessage("МИН/ДЕНЬ"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("Продвинутая нода"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Начальная нода"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Про нода"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 блоков/день~70 мин",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage(
      "Дата разблокировки",
    ),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 блоков/день~15 мин",
    ),
    "g_mining_key_71": m78,
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
    "g_mining_key_8": MessageLookupByLibrary.simpleMessage(
      "Сегодняшнее время проверки",
    ),
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
    "g_mining_key_98": m79,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Повторите пароль для подтверждения",
    ),
    "g_mining_node_key1": MessageLookupByLibrary.simpleMessage(
      "Детали Полного Узла",
    ),
    "g_mining_node_key2": MessageLookupByLibrary.simpleMessage("ID узла"),
    "g_mining_node_key3": MessageLookupByLibrary.simpleMessage("WS Подключён"),
    "g_mining_node_key4": MessageLookupByLibrary.simpleMessage("WS Отключён"),
    "g_mining_node_key5": MessageLookupByLibrary.simpleMessage(
      "WS Переподключение",
    ),
    "g_mining_node_key6": MessageLookupByLibrary.simpleMessage("Истечение"),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage(
      "Период разблокировки:",
    ),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "Разблокировка в любое время",
    ),
    "g_news_empty": MessageLookupByLibrary.simpleMessage(
      "Нет доступных новостей",
    ),
    "g_news_source": MessageLookupByLibrary.simpleMessage("Источник"),
    "g_notification_key_1": MessageLookupByLibrary.simpleMessage("Уведомления"),
    "g_phishing_go_back": MessageLookupByLibrary.simpleMessage(
      "Назад (Безопасно)",
    ),
    "g_phishing_proceed_anyway": MessageLookupByLibrary.simpleMessage(
      "Продолжить всё равно",
    ),
    "g_phishing_warning_body": MessageLookupByLibrary.simpleMessage(
      "Этот сайт был идентифицирован как потенциально вредоносный. Он может пытаться похитить ваши криптоактивы или закрытые ключи.",
    ),
    "g_phishing_warning_title": MessageLookupByLibrary.simpleMessage(
      "Предупреждение безопасности",
    ),
    "g_phishing_warning_url_label": MessageLookupByLibrary.simpleMessage(
      "Подозрительный URL:",
    ),
    "g_pnl_add_trade": MessageLookupByLibrary.simpleMessage(
      "Добавить торговлю",
    ),
    "g_pnl_avg_cost": MessageLookupByLibrary.simpleMessage("Средняя стоимость"),
    "g_pnl_buy_price_usd": MessageLookupByLibrary.simpleMessage(
      "Цена покупки (долл. США)",
    ),
    "g_pnl_cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage(
      "Основа стоимости",
    ),
    "g_pnl_no_trades": MessageLookupByLibrary.simpleMessage(
      "Сделки не зафиксированы",
    ),
    "g_pnl_quantity": MessageLookupByLibrary.simpleMessage("Количество"),
    "g_pnl_save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "g_pnl_unrealized": MessageLookupByLibrary.simpleMessage(
      "Нереализованные прибыли и убытки",
    ),
    "g_portfolio_24h": MessageLookupByLibrary.simpleMessage("24-часовая смена"),
    "g_portfolio_all_holdings": MessageLookupByLibrary.simpleMessage(
      "Все активы",
    ),
    "g_portfolio_allocation": MessageLookupByLibrary.simpleMessage(
      "Распределение активов",
    ),
    "g_portfolio_gainers": MessageLookupByLibrary.simpleMessage("Лидеры роста"),
    "g_portfolio_losers": MessageLookupByLibrary.simpleMessage(
      "Наибольшие потери",
    ),
    "g_portfolio_movers": MessageLookupByLibrary.simpleMessage(
      "Круглосуточные грузчики",
    ),
    "g_portfolio_no_assets": MessageLookupByLibrary.simpleMessage(
      "Активы не найдены",
    ),
    "g_portfolio_others": MessageLookupByLibrary.simpleMessage("Другие"),
    "g_portfolio_pie_total": MessageLookupByLibrary.simpleMessage("Итого"),
    "g_portfolio_title": MessageLookupByLibrary.simpleMessage("Портфолио"),
    "g_portfolio_total": MessageLookupByLibrary.simpleMessage(
      "Общая стоимость",
    ),
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage("Загружено"),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage(
      "Код приглашения",
    ),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("Приглашено"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage(
      "Майнинговые узлы",
    ),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("Награда (N)"),
    "g_referral_stats_title": MessageLookupByLibrary.simpleMessage(
      "Статистика рефералов",
    ),
    "g_setting_mining_v1_label": MessageLookupByLibrary.simpleMessage(
      "Классический майнинг (V1)",
    ),
    "g_setting_mining_v2_label": MessageLookupByLibrary.simpleMessage(
      "Майнинг (V2)",
    ),
    "g_setting_mining_version": MessageLookupByLibrary.simpleMessage(
      "Интерфейс майнинга",
    ),
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
    "g_swap_key_14": m80,
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
    "g_swap_key_20": m81,
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
    "g_swap_key_31": m82,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Обмены можно просмотреть в соответствующих обозревателях блокчейна (Etherscan, BscScan, TRONSCAN и наш собственный).",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Обменять на N"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Обмен"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Вы получаете"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("Предпросмотр обмена"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Повторить"),
    "g_theme_accent_color": MessageLookupByLibrary.simpleMessage(
      "Акцентный цвет",
    ),
    "g_theme_accent_reset": MessageLookupByLibrary.simpleMessage(
      "Сбросить настройки по умолчанию",
    ),
    "g_token_m_key_1": m83,
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
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("ПКП"),
    "g_token_m_key_18": MessageLookupByLibrary.simpleMessage("API"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Добавить пользовательскую сеть",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 ед."),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("Добавить токены"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage("Ошибка формата!"),
    "g_token_m_key_22": m84,
    "g_token_m_key_23": m85,
    "g_token_m_key_24": m86,
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
    "g_tx_risk_caution": MessageLookupByLibrary.simpleMessage("Осторожно"),
    "g_tx_risk_danger": MessageLookupByLibrary.simpleMessage("Высокий риск"),
    "g_tx_risk_safe": MessageLookupByLibrary.simpleMessage("Безопасно"),
    "g_unlock_key10": m87,
    "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
      "Отпечаток пальца или распознавание лица не включено?",
    ),
    "g_unlock_key3": MessageLookupByLibrary.simpleMessage(
      "Нарисуйте графический пароль",
    ),
    "g_unlock_key4": m88,
    "g_unlock_key5": MessageLookupByLibrary.simpleMessage("Введите пароль"),
    "g_unlock_key6": m89,
    "g_unlock_key7": MessageLookupByLibrary.simpleMessage(
      "Аутентификация не удалась",
    ),
    "g_unlock_key8": m90,
    "g_unlock_key9": MessageLookupByLibrary.simpleMessage("Вы также можете "),
    "g_version_later": MessageLookupByLibrary.simpleMessage("Позже"),
    "g_wc_connection_lost": MessageLookupByLibrary.simpleMessage(
      "Соединение потеряно. Пожалуйста, подключитесь снова.",
    ),
    "g_wc_dapp_disconnected": MessageLookupByLibrary.simpleMessage(
      "DApp отключился",
    ),
    "g_wc_disconnect_all": MessageLookupByLibrary.simpleMessage(
      "Отключить все",
    ),
    "g_wc_disconnect_all_confirm": MessageLookupByLibrary.simpleMessage(
      "Отключиться от всех DApp?",
    ),
    "g_wc_disconnect_confirm": MessageLookupByLibrary.simpleMessage(
      "Отключиться от этого DApp?",
    ),
    "g_wc_new_connection": MessageLookupByLibrary.simpleMessage(
      "Новое подключение",
    ),
    "g_wc_no_sessions": MessageLookupByLibrary.simpleMessage(
      "Нет активных подключений",
    ),
    "g_wc_no_sessions_desc": MessageLookupByLibrary.simpleMessage(
      "Отсканируйте QR-код для подключения к DApp",
    ),
    "g_wc_proposal_timeout": MessageLookupByLibrary.simpleMessage(
      "Запрос на подключение истёк",
    ),
    "g_wc_session_expired": MessageLookupByLibrary.simpleMessage(
      "Сессия истекла",
    ),
    "g_wc_sessions": MessageLookupByLibrary.simpleMessage("Подключённые DApp"),
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
    "google_verification_message21": m91,
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
    "nicknameMessage": m92,
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
    "push_permission_btn_dismiss": MessageLookupByLibrary.simpleMessage(
      "Не напоминать",
    ),
    "push_permission_btn_later": MessageLookupByLibrary.simpleMessage("Позже"),
    "push_permission_btn_settings": MessageLookupByLibrary.simpleMessage(
      "Перейти в настройки",
    ),
    "push_permission_dialog_content": MessageLookupByLibrary.simpleMessage(
      "Push-уведомления отключены. Вы можете пропустить сообщения чата и уведомления о переводах.\n\nВключите уведомления для этого приложения в настройках системы.",
    ),
    "push_permission_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Уведомления отключены",
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
