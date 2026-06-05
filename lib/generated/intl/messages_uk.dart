// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a uk locale. All the
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
  String get localeName => 'uk';

  static String m0(deviceName, os) =>
      "Ви щойно ввійшли в обліковий запис на ${deviceName} (${os}). Якщо це були не ви, радимо змінити пароль.";

  static String m1(price) => "Поточна ціна: \$${price}";

  static String m2(symbol) => "Сповіщення про ціну · ${symbol}";

  static String m3(s) => "Повторно надішліть через ${s}s";

  static String m4(message) => "Помилка покупки: ${message}";

  static String m5(productId) => "Покупку виконано: ${productId}";

  static String m6(productId) => "Відновлено: ${productId}";

  static String m7(value) => "Сума більша за ${value}.";

  static String m8(value) => "Гаманець уже існує, ім\'я гаманця \"${value}\"";

  static String m9(value) => "Введіть суму більше, ніж ${value}.";

  static String m10(value) => "Дубльована адреса в рядку ${value}";

  static String m11(value) =>
      "Недостатній баланс: загальна сума перевищить доступний ${value}";

  static String m12(value) => "Недійсна адреса в рядку ${value}";

  static String m13(value) => "Недійсна сума в рядку ${value}";

  static String m14(value) => "Максимальна кількість одержувачів ${value}";

  static String m15(token) => "Підтвердьте ${token}, щоб продовжити";

  static String m16(impact) =>
      "Високий вплив на ціну (${impact})! Дійте обережно.";

  static String m17(secs) => "Термін дії пропозиції закінчується через ${secs}";

  static String m18(value) => "Заробляйте до ${value}% APY";

  static String m19(value) => "Автоматичне оновлення кожні ${value} секунд";

  static String m20(address) => "Обліковий запис ${address} додано";

  static String m21(address, network) =>
      "Ви бажаєте відстежувати цей обліковий запис апаратного гаманця?\n\nАдреса: ${address}\nМережа: ${network}";

  static String m22(app) => "Поточний додаток: ${app}";

  static String m23(days) => "${days} днів тому";

  static String m24(value) =>
      "Не вдалося імпортувати обліковий запис: ${value}";

  static String m25(date) => "Останнє підключення: ${date}";

  static String m26(app) =>
      "Переконайтеся, що програму ${app} відкрито на вашому Ledger";

  static String m27(name) =>
      "Ви впевнені, що хочете видалити \"${name}\" зі збережених пристроїв?";

  static String m28(value) => "Приблизно газ: ~${value} од";

  static String m29(reason) => "Причина: ${reason}";

  static String m30(value) => "${value}d роз\'єднати";

  static String m31(value) => "Залишилося ${value} днів";

  static String m32(value) =>
      "Розставка займає ${value} днів. Протягом цього періоду ваші токени будуть заблоковані.";

  static String m33(value) => "Вам не вистачає \"${value}\"";

  static String m34(value) =>
      "Не вдалося отримати обліковий запис \"${value}\".";

  static String m35(value) => "Мінімальний ${value} XRP для першого переказу";

  static String m36(count) => "Додати (${count})";

  static String m37(count) =>
      "${Intl.plural(count, one: 'Виявлено 1 новий маркер', other: '${count} виявлено нові маркери')} — натисніть, щоб переглянути";

  static String m38(value) => "Ланцюжок ${value} не додано.";

  static String m39(value) =>
      "${value} має незавершені транзакції, спробуйте пізніше.";

  static String m40(value) => "Не знайдено адреси для ${value}.";

  static String m41(value) => "Недостатній баланс ${value}.";

  static String m42(value, value1) =>
      "Кожен обліковий запис XRP має резервувати ${value} XRP (зниження ${value1}) як базовий рівень, який не можна витрачати.";

  static String m43(value, value1) =>
      "Для кожного об’єкта, яким володіє обліковий запис, ${value} XRP (випадки ${value1}) додається до резерву.";

  static String m44(value, value1) =>
      "Цей обліковий запис володіє об’єктами ${value}, що означає, що зарезервовано додатковий ${value1} XRP.";

  static String m45(value) => "Невірний ключ, залишилось ${value} спроб";

  static String m46(value) => "Невірний ключ, залишилась ${value} спроба";

  static String m47(value) =>
      "Ви успішно налаштували ${value} і почнете перевірку за допомогою N42Wallet!";

  static String m48(value) =>
      "Приєднуйтеся до моєї групи ${value} на @N42Wallet, щоб стати першим майнером ланцюга рівня 1 і отримати криптовалюту на свій телефон!";

  static String m49(value, value1) =>
      "Ви впевнені, що бажаєте заблокувати ${value} N до ${value1} для запуску вузла?";

  static String m50(value) => "Помилка імпорту: ${value}";

  static String m51(value) =>
      "Щоб отримати винагороду, потрібен баланс ставки принаймні ${value}.";

  static String m52(value, value1) =>
      "${value} N кожні здобуті блоки ${value1}";

  static String m53(value) => "Має бути ${value} символів";

  static String m54(n) => "${n} хв";

  static String m55(n) => "Результат ${n}";

  static String m56(value) => "${value} Недостатній баланс.";

  static String m57(value) => "${value} вхідний...";

  static String m58(value) =>
      "${value}, замінений у додатку, незабаром буде розповсюджений у ваш гаманець і не може бути проданий через цей процес. Його можна використовувати для запуску вузла.";

  static String m59(value) => "Максимальна кількість символів: ${value}";

  static String m60(value) => "${value} chain APP вже підтримується!";

  static String m61(value) =>
      "${value} chain APP уже підтримується, хочете додати?";

  static String m62(value) => "Помилка перевірки адреси ${value}!";

  static String m63(value) => "0~${value} символів";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Edit": MessageLookupByLibrary.simpleMessage("Редагувати"),
    "Verification": MessageLookupByLibrary.simpleMessage("Перевірка"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Інформація про адресу",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Успішно скопійовано"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("Копіювати адресу"),
    "descO": MessageLookupByLibrary.simpleMessage("Опис (необов\'язково)"),
    "device_login_change_password": MessageLookupByLibrary.simpleMessage(
      "Змінити пароль",
    ),
    "device_login_dismiss": MessageLookupByLibrary.simpleMessage("зрозумів"),
    "device_login_message": m0,
    "device_login_title": MessageLookupByLibrary.simpleMessage(
      "Новий вхід на пристрій",
    ),
    "file": MessageLookupByLibrary.simpleMessage("Файл"),
    "g_alert_above": MessageLookupByLibrary.simpleMessage("Переходить вище ↑"),
    "g_alert_below": MessageLookupByLibrary.simpleMessage("Падає нижче ↓"),
    "g_alert_current_price": m1,
    "g_alert_direction": MessageLookupByLibrary.simpleMessage(
      "Повідомити мене про ціну",
    ),
    "g_alert_enable": MessageLookupByLibrary.simpleMessage(
      "Увімкнути це сповіщення",
    ),
    "g_alert_invalid_price": MessageLookupByLibrary.simpleMessage(
      "Введіть дійсну ціну більше 0",
    ),
    "g_alert_remove": MessageLookupByLibrary.simpleMessage("видалити"),
    "g_alert_set": MessageLookupByLibrary.simpleMessage(
      "Установити сповіщення",
    ),
    "g_alert_target_price": MessageLookupByLibrary.simpleMessage(
      "Цільова ціна (USD)",
    ),
    "g_alert_title": m2,
    "g_alert_update": MessageLookupByLibrary.simpleMessage(
      "Оновити сповіщення",
    ),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "Токени можна надсилати лише в межах однієї мережі. Надсилання з інших мереж може призвести до втрати.",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage(
      "Сканувати для отримання",
    ),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage(
      "Будь ласка, введіть URL",
    ),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage("Введіть опис"),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("Браузер"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage(
      "Очистити кеш браузера",
    ),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage(
      "Підключіть DApp автоматично",
    ),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("Закрити всі"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("Готово"),
    "g_browser_key18": MessageLookupByLibrary.simpleMessage("історія"),
    "g_browser_key19": MessageLookupByLibrary.simpleMessage(
      "Очистити всю історію",
    ),
    "g_browser_key20": MessageLookupByLibrary.simpleMessage(
      "Очистити всю історію веб-перегляду?",
    ),
    "g_browser_key21": MessageLookupByLibrary.simpleMessage("Історія очищена"),
    "g_browser_key22": MessageLookupByLibrary.simpleMessage("Сьогодні"),
    "g_browser_key23": MessageLookupByLibrary.simpleMessage("вчора"),
    "g_browser_key24": MessageLookupByLibrary.simpleMessage(
      "Відкрийте для себе DApps",
    ),
    "g_browser_key25": MessageLookupByLibrary.simpleMessage("Популярний"),
    "g_browser_key26": MessageLookupByLibrary.simpleMessage("DEX"),
    "g_browser_key27": MessageLookupByLibrary.simpleMessage("DeFi"),
    "g_browser_key28": MessageLookupByLibrary.simpleMessage("NFT"),
    "g_browser_key29": MessageLookupByLibrary.simpleMessage("Міст"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Закладки"),
    "g_browser_key30": MessageLookupByLibrary.simpleMessage("Інструменти"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage(
      "Закладок ще не додано",
    ),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("Закладка"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("Ім\'я"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage(
      "Будь ласка, введіть ім\'я",
    ),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("опис"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("Погодьтеся"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage(
      "Повідомлення видалено",
    ),
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("транзакції"),
    "g_connect_key1": MessageLookupByLibrary.simpleMessage("Підключитися"),
    "g_connect_key11": MessageLookupByLibrary.simpleMessage("Доступні мережі"),
    "g_connect_key12": MessageLookupByLibrary.simpleMessage(
      "Повідомлення знак",
    ),
    "g_connect_key13": MessageLookupByLibrary.simpleMessage("Підключення"),
    "g_connect_key14": MessageLookupByLibrary.simpleMessage(
      "Сполучення, зачекайте.",
    ),
    "g_connect_key2": MessageLookupByLibrary.simpleMessage("Відключити"),
    "g_connect_key3": MessageLookupByLibrary.simpleMessage("Відхиляти"),
    "g_dapp_security_blocked": MessageLookupByLibrary.simpleMessage(
      "заблоковано",
    ),
    "g_dapp_security_caution": MessageLookupByLibrary.simpleMessage("Обережно"),
    "g_dapp_security_safe": MessageLookupByLibrary.simpleMessage("Безпечний"),
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage(
      "Перевірено",
    ),
    "g_email_resend": MessageLookupByLibrary.simpleMessage(
      "Повторно надіслати код",
    ),
    "g_email_resend_countdown": m3,
    "g_face_1": MessageLookupByLibrary.simpleMessage(
      "Поради щодо біометричного сканування",
    ),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Скануйте свій відбиток пальця або обличчя для автентифікації.",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("Поради"),
    "g_face_5": MessageLookupByLibrary.simpleMessage("Встановити"),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Щоб продовжити, відскануйте своє обличчя або відбиток пальця.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Повернення"),
    "g_google_auth_key1": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator",
    ),
    "g_google_auth_key2": MessageLookupByLibrary.simpleMessage(
      "Відскануйте QR-код додатком Google Authenticator",
    ),
    "g_google_auth_key3": MessageLookupByLibrary.simpleMessage(
      "Або введіть ключ вручну:",
    ),
    "g_google_auth_key4": MessageLookupByLibrary.simpleMessage(
      "Введіть 6-значний код підтвердження",
    ),
    "g_google_auth_key5": MessageLookupByLibrary.simpleMessage(
      "Для підтвердження переказу потрібен Google Authenticator.",
    ),
    "g_google_auth_key6": MessageLookupByLibrary.simpleMessage(
      "Невірний код, спробуйте ще раз",
    ),
    "g_google_auth_key7": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator не налаштовано",
    ),
    "g_google_auth_key8": MessageLookupByLibrary.simpleMessage(
      "Прив\'язка успішна",
    ),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Профіль"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("Новини"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Перевірка"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Запросіть друга"),
    "g_iap_cancelled": MessageLookupByLibrary.simpleMessage("Скасовано"),
    "g_iap_check_network": MessageLookupByLibrary.simpleMessage(
      "Перевірте підключення до мережі і спробуйте знову",
    ),
    "g_iap_failed": m4,
    "g_iap_no_products": MessageLookupByLibrary.simpleMessage(
      "Немає доступних товарів",
    ),
    "g_iap_purchased": m5,
    "g_iap_restore": MessageLookupByLibrary.simpleMessage("Відновити покупки"),
    "g_iap_restored": m6,
    "g_iap_restoring": MessageLookupByLibrary.simpleMessage(
      "Відновлення покупок…",
    ),
    "g_iap_retry": MessageLookupByLibrary.simpleMessage("Повторити"),
    "g_iap_store_unavailable": MessageLookupByLibrary.simpleMessage(
      "Магазин недоступний",
    ),
    "g_iap_title": MessageLookupByLibrary.simpleMessage("Купити"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("Не вдалося видалити!"),
    "g_key_101": MessageLookupByLibrary.simpleMessage("Ліміт газу"),
    "g_key_105": MessageLookupByLibrary.simpleMessage("Не більше"),
    "g_key_106": MessageLookupByLibrary.simpleMessage("Завантаження "),
    "g_key_108": MessageLookupByLibrary.simpleMessage("Адресна книга"),
    "g_key_11": MessageLookupByLibrary.simpleMessage("Імпортний гаманець"),
    "g_key_110": MessageLookupByLibrary.simpleMessage("Керувати"),
    "g_key_112": MessageLookupByLibrary.simpleMessage("Нова адреса"),
    "g_key_113": MessageLookupByLibrary.simpleMessage("Видалити"),
    "g_key_115": MessageLookupByLibrary.simpleMessage("зберегти"),
    "g_key_119": MessageLookupByLibrary.simpleMessage("Копія"),
    "g_key_12": MessageLookupByLibrary.simpleMessage(
      "Створити/імпортувати гаманець",
    ),
    "g_key_126": MessageLookupByLibrary.simpleMessage("Тема"),
    "g_key_127": MessageLookupByLibrary.simpleMessage("система"),
    "g_key_128": MessageLookupByLibrary.simpleMessage("світло"),
    "g_key_129": MessageLookupByLibrary.simpleMessage("Темний"),
    "g_key_13": MessageLookupByLibrary.simpleMessage("Список гаманців"),
    "g_key_132": MessageLookupByLibrary.simpleMessage("Немає даних"),
    "g_key_134": MessageLookupByLibrary.simpleMessage("Сума недійсна"),
    "g_key_135": m7,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Основний гаманець"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("Трансакція успішна"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Невірний пароль"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("Testnet"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Основна мережа"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("Системна мова"),
    "g_key_15": MessageLookupByLibrary.simpleMessage(
      "Встановити як основний гаманець",
    ),
    "g_key_155": MessageLookupByLibrary.simpleMessage("Адреса гаманця"),
    "g_key_156": MessageLookupByLibrary.simpleMessage(
      "Сканувати, щоб скопіювати адресу",
    ),
    "g_key_159": MessageLookupByLibrary.simpleMessage("додати"),
    "g_key_16": MessageLookupByLibrary.simpleMessage(
      "Виберіть Перевірити гаманець",
    ),
    "g_key_163": MessageLookupByLibrary.simpleMessage("символ"),
    "g_key_166": MessageLookupByLibrary.simpleMessage("Вставити"),
    "g_key_17": MessageLookupByLibrary.simpleMessage("Виберіть Ланцюжок"),
    "g_key_175": MessageLookupByLibrary.simpleMessage("Помилка транзакції"),
    "g_key_179": MessageLookupByLibrary.simpleMessage("Це адреса мого гаманця"),
    "g_key_181": MessageLookupByLibrary.simpleMessage("інше"),
    "g_key_185": MessageLookupByLibrary.simpleMessage("Успішно збережено"),
    "g_key_191": MessageLookupByLibrary.simpleMessage("Успіх"),
    "g_key_192": MessageLookupByLibrary.simpleMessage(
      "Ви впевнені, що хочете видалити гаманець?",
    ),
    "g_key_193": MessageLookupByLibrary.simpleMessage("Активний"),
    "g_key_195": MessageLookupByLibrary.simpleMessage(
      "Немає дозволу на доступ до камери.",
    ),
    "g_key_196": MessageLookupByLibrary.simpleMessage("Провідник"),
    "g_key_197": MessageLookupByLibrary.simpleMessage("Макс"),
    "g_key_198": MessageLookupByLibrary.simpleMessage("Активи"),
    "g_key_2": MessageLookupByLibrary.simpleMessage("Книга порожня!"),
    "g_key_202": MessageLookupByLibrary.simpleMessage("Огляд транзакцій"),
    "g_key_203": MessageLookupByLibrary.simpleMessage(
      "помилка посилання, відскануйте QR-код ще раз.",
    ),
    "g_key_206": MessageLookupByLibrary.simpleMessage("Редагування пароля"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("Старий пароль"),
    "g_key_208": MessageLookupByLibrary.simpleMessage(
      "Синхронізація балансів...",
    ),
    "g_key_209": MessageLookupByLibrary.simpleMessage("Приватний ключ"),
    "g_key_21": MessageLookupByLibrary.simpleMessage("Введіть пароль гаманця"),
    "g_key_210": MessageLookupByLibrary.simpleMessage(
      "Помилка закритого ключа",
    ),
    "g_key_213": MessageLookupByLibrary.simpleMessage("Ринкова інформація"),
    "g_key_214": m8,
    "g_key_25": MessageLookupByLibrary.simpleMessage("Пароль не збігається."),
    "g_key_29": MessageLookupByLibrary.simpleMessage("Баланс"),
    "g_key_3": MessageLookupByLibrary.simpleMessage("Не вдалося додати!"),
    "g_key_33": MessageLookupByLibrary.simpleMessage("Отримати"),
    "g_key_37": MessageLookupByLibrary.simpleMessage("Трансфер"),
    "g_key_38": MessageLookupByLibrary.simpleMessage("до"),
    "g_key_4": MessageLookupByLibrary.simpleMessage("Відскануйте QR-код"),
    "g_key_41": MessageLookupByLibrary.simpleMessage("Введіть адресу гаманця"),
    "g_key_43": MessageLookupByLibrary.simpleMessage("Доступний баланс"),
    "g_key_44": MessageLookupByLibrary.simpleMessage("Сума"),
    "g_key_46": m9,
    "g_key_47": MessageLookupByLibrary.simpleMessage(
      "Недостатньо коштів для покриття цієї операції.",
    ),
    "g_key_48": MessageLookupByLibrary.simpleMessage("Надіслати"),
    "g_key_5": MessageLookupByLibrary.simpleMessage("Не вдалося завантажити!"),
    "g_key_6": MessageLookupByLibrary.simpleMessage("Гаманець"),
    "g_key_7": MessageLookupByLibrary.simpleMessage("Створити"),
    "g_key_75": MessageLookupByLibrary.simpleMessage("Від"),
    "g_key_78": MessageLookupByLibrary.simpleMessage("Підтвердити"),
    "g_key_79": MessageLookupByLibrary.simpleMessage("Скасувати"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("Усі жетони"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("Налаштування"),
    "g_key_aa_account_created": MessageLookupByLibrary.simpleMessage(
      "Обліковий запис успішно створено",
    ),
    "g_key_aa_account_details": MessageLookupByLibrary.simpleMessage(
      "Реквізити облікового запису",
    ),
    "g_key_aa_account_name": MessageLookupByLibrary.simpleMessage(
      "Ім\'я облікового запису",
    ),
    "g_key_aa_account_name_hint": MessageLookupByLibrary.simpleMessage(
      "Введіть назву облікового запису",
    ),
    "g_key_aa_account_type": MessageLookupByLibrary.simpleMessage(
      "Тип облікового запису",
    ),
    "g_key_aa_active": MessageLookupByLibrary.simpleMessage("Активний"),
    "g_key_aa_add_first_operation": MessageLookupByLibrary.simpleMessage(
      "Додайте першу операцію",
    ),
    "g_key_aa_add_operation": MessageLookupByLibrary.simpleMessage(
      "Додати операцію",
    ),
    "g_key_aa_address_calculating": MessageLookupByLibrary.simpleMessage(
      "Розрахунок адреси...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "Не вдалося обчислити адресу. Спробуйте ще раз.",
    ),
    "g_key_aa_approve": MessageLookupByLibrary.simpleMessage("Затвердити"),
    "g_key_aa_batch": MessageLookupByLibrary.simpleMessage("партія"),
    "g_key_aa_batch_atomic": MessageLookupByLibrary.simpleMessage(
      "Атомна страта",
    ),
    "g_key_aa_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Виконуйте декілька операцій одночасно",
    ),
    "g_key_aa_batch_description": MessageLookupByLibrary.simpleMessage(
      "Надсилайте кілька транзакцій за одну операцію",
    ),
    "g_key_aa_batch_failed": MessageLookupByLibrary.simpleMessage(
      "Помилка пакетного виконання",
    ),
    "g_key_aa_batch_no_templates": MessageLookupByLibrary.simpleMessage(
      "Немає збережених шаблонів",
    ),
    "g_key_aa_batch_operations": MessageLookupByLibrary.simpleMessage(
      "Пакетні операції",
    ),
    "g_key_aa_batch_save_gas": MessageLookupByLibrary.simpleMessage(
      "Економте газ",
    ),
    "g_key_aa_batch_save_template": MessageLookupByLibrary.simpleMessage(
      "Зберегти як шаблон",
    ),
    "g_key_aa_batch_submitting": MessageLookupByLibrary.simpleMessage(
      "Подання...",
    ),
    "g_key_aa_batch_success": MessageLookupByLibrary.simpleMessage(
      "Пакет успішно надіслано",
    ),
    "g_key_aa_batch_template_load": MessageLookupByLibrary.simpleMessage(
      "Завантажити шаблон",
    ),
    "g_key_aa_batch_template_name": MessageLookupByLibrary.simpleMessage(
      "Назва шаблону",
    ),
    "g_key_aa_batch_template_name_hint": MessageLookupByLibrary.simpleMessage(
      "Введіть назву шаблону",
    ),
    "g_key_aa_batch_template_saved": MessageLookupByLibrary.simpleMessage(
      "Шаблон збережено",
    ),
    "g_key_aa_batch_templates": MessageLookupByLibrary.simpleMessage("Шаблони"),
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage(
      "Пакетна транзакція",
    ),
    "g_key_aa_benefit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Схвалення та обмін в одній транзакції — більше ніяких двоетапних підтверджень",
    ),
    "g_key_aa_benefit_batch_title": MessageLookupByLibrary.simpleMessage(
      "Пакетні дії в один клік",
    ),
    "g_key_aa_benefit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "Спонсоруйте транзакції або сплачуйте комісії за допомогою токенів ERC-20 замість ETH",
    ),
    "g_key_aa_benefit_gas_title": MessageLookupByLibrary.simpleMessage(
      "Оплачуйте бензин будь-яким жетоном",
    ),
    "g_key_aa_benefit_recovery_desc": MessageLookupByLibrary.simpleMessage(
      "Відновіть доступ через довірені контакти, якщо ви втратите свій закритий ключ",
    ),
    "g_key_aa_benefit_recovery_title": MessageLookupByLibrary.simpleMessage(
      "Соціальне відновлення",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "Модульний смарт-акаунт ERC-7579 із підтримкою безгазових транзакцій",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("за"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("ланцюг"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage("ID ланцюга"),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("Зміна"),
    "g_key_aa_check_status": MessageLookupByLibrary.simpleMessage(
      "Перевірте статус",
    ),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage("Незабаром"),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "Це контрфактична адреса. Його буде розгорнуто під час вашої першої транзакції.",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "Створити розумний обліковий запис",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "Створіть свій перший розумний обліковий запис",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "Створити ключ сеансу",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("Створено"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "Обліковий запис буде розгорнуто автоматично під час вашої першої транзакції",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("Розгорнуто"),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage(
      "Розгортання...",
    ),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "Розгортання відбудеться автоматично з вашою першою транзакцією.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "Відчуйте наступне покоління облікових записів Ethereum із покращеними функціями",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("Подробиці"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "Гібридний EOA/Smart Account - розгортання не потрібне",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("Помилка"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "Розрахунковий газ",
    ),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage(
      "Виконати пакет",
    ),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage(
      "Термін дії минув",
    ),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage(
      "Термін дії закінчується",
    ),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("Фабрика"),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("БЕЗКОШТОВНО"),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "Помилка оцінки газу, використовується за умовчанням",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage("Оплата газу"),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Варіанти оплати за газ",
    ),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "Газовий спонсор",
    ),
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("Безгазовий"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "Безгазові транзакції та пакетні операції",
    ),
    "g_key_aa_kernel_desc": MessageLookupByLibrary.simpleMessage(
      "Модульний обліковий запис із підтримкою плагінів від ZeroDev",
    ),
    "g_key_aa_label": MessageLookupByLibrary.simpleMessage("Мітка"),
    "g_key_aa_last_activity": MessageLookupByLibrary.simpleMessage(
      "Остання активність",
    ),
    "g_key_aa_my_accounts": MessageLookupByLibrary.simpleMessage(
      "Мої розумні облікові записи",
    ),
    "g_key_aa_no_accounts": MessageLookupByLibrary.simpleMessage(
      "Розумних облікових записів ще немає",
    ),
    "g_key_aa_no_accounts_filter": MessageLookupByLibrary.simpleMessage(
      "Жоден обліковий запис не відповідає вашому фільтру",
    ),
    "g_key_aa_no_operations": MessageLookupByLibrary.simpleMessage(
      "Жодних операцій не додано",
    ),
    "g_key_aa_no_session_keys": MessageLookupByLibrary.simpleMessage(
      "Немає сеансових ключів",
    ),
    "g_key_aa_not_deployed": MessageLookupByLibrary.simpleMessage(
      "Не розгорнуто",
    ),
    "g_key_aa_onboard_step1": MessageLookupByLibrary.simpleMessage(
      "Створіть розумний обліковий запис (безкоштовно, ETH не потрібен)",
    ),
    "g_key_aa_onboard_step2": MessageLookupByLibrary.simpleMessage(
      "Профінансуйте це — отримайте будь-який токен EVM",
    ),
    "g_key_aa_onboard_step3": MessageLookupByLibrary.simpleMessage(
      "Здійснюйте транзакції без газу з Paymaster",
    ),
    "g_key_aa_operations": MessageLookupByLibrary.simpleMessage("Операції"),
    "g_key_aa_owner": MessageLookupByLibrary.simpleMessage("Власник"),
    "g_key_aa_pay_gas_with_token": MessageLookupByLibrary.simpleMessage(
      "Оплатіть газ жетоном",
    ),
    "g_key_aa_pay_gas_yourself": MessageLookupByLibrary.simpleMessage(
      "Оплачуйте бензин своїм ETH",
    ),
    "g_key_aa_pay_with": MessageLookupByLibrary.simpleMessage("Платити з"),
    "g_key_aa_pay_with_eth": MessageLookupByLibrary.simpleMessage(
      "Оплатіть ETH",
    ),
    "g_key_aa_paymaster_chains_supported": MessageLookupByLibrary.simpleMessage(
      "ланцюги підтримуються",
    ),
    "g_key_aa_paymaster_checking": MessageLookupByLibrary.simpleMessage(
      "Перевірка наявності...",
    ),
    "g_key_aa_paymaster_coverage": MessageLookupByLibrary.simpleMessage(
      "Покриття ланцюга",
    ),
    "g_key_aa_paymaster_description": MessageLookupByLibrary.simpleMessage(
      "Виберіть, як ви бажаєте сплачувати комісію за газ",
    ),
    "g_key_aa_paymaster_est_cost": MessageLookupByLibrary.simpleMessage(
      "Приблизно вартість",
    ),
    "g_key_aa_paymaster_load_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити параметри газу",
    ),
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage(
      "Повторіть спробу",
    ),
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("В очікуванні"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("Дозвіл"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "Попередній перегляд адреси",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("Готовий"),
    "g_key_aa_receive_address": MessageLookupByLibrary.simpleMessage(
      "Отримати адресу",
    ),
    "g_key_aa_retry": MessageLookupByLibrary.simpleMessage("Повторіть спробу"),
    "g_key_aa_revoke": MessageLookupByLibrary.simpleMessage("Відкликати"),
    "g_key_aa_revoke_confirm": MessageLookupByLibrary.simpleMessage(
      "Ви впевнені, що бажаєте відкликати цей ключ сеансу? Авторизований DApp більше не зможе виконувати транзакції.",
    ),
    "g_key_aa_revoke_session": MessageLookupByLibrary.simpleMessage(
      "Відкликати ключ сеансу",
    ),
    "g_key_aa_revoked": MessageLookupByLibrary.simpleMessage(
      "Ключ сеансу анульовано",
    ),
    "g_key_aa_revoked_status": MessageLookupByLibrary.simpleMessage(
      "Відкликано",
    ),
    "g_key_aa_revoking": MessageLookupByLibrary.simpleMessage(
      "Відкликання ключа сеансу...",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "Мультипідписний обліковий запис із розширеними функціями безпеки",
    ),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("збережено"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "Виберіть Ланцюжок",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Виберіть Paymaster",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("Вибране"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "Надсилайте токени за допомогою свого смарт-облікового запису",
    ),
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1 день"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1 година"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30 днів"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7 днів"),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "напр. 100,00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "Максимальна сума",
    ),
    "g_key_aa_session_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Я розумію дозволи цього ключа",
    ),
    "g_key_aa_session_contract_can": MessageLookupByLibrary.simpleMessage(
      "Взаємодія з затвердженими контрактами DApp",
    ),
    "g_key_aa_session_create_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося створити ключ сеансу",
    ),
    "g_key_aa_session_create_success": MessageLookupByLibrary.simpleMessage(
      "Ключ сеансу створено",
    ),
    "g_key_aa_session_dapp_hint": MessageLookupByLibrary.simpleMessage(
      "напр. Uniswap, Aave...",
    ),
    "g_key_aa_session_dapp_label": MessageLookupByLibrary.simpleMessage(
      "Назва ярлика / DApp",
    ),
    "g_key_aa_session_details": MessageLookupByLibrary.simpleMessage(
      "Ключові деталі сеансу",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage(
      "Дійсний для",
    ),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "Високий ризик — довіряйте лише перевіреним DApps",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage(
      "Ключі сесії",
    ),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "Авторизуйте DApps з тимчасовим доступом до вашого смарт-облікового запису",
    ),
    "g_key_aa_session_preset_contract": MessageLookupByLibrary.simpleMessage(
      "Доступ DApp",
    ),
    "g_key_aa_session_preset_full": MessageLookupByLibrary.simpleMessage(
      "Повний контроль",
    ),
    "g_key_aa_session_preset_transfer": MessageLookupByLibrary.simpleMessage(
      "Тільки відправити",
    ),
    "g_key_aa_session_risk_high": MessageLookupByLibrary.simpleMessage(
      "Високий ризик",
    ),
    "g_key_aa_session_risk_low": MessageLookupByLibrary.simpleMessage(
      "Низький ризик",
    ),
    "g_key_aa_session_risk_medium": MessageLookupByLibrary.simpleMessage(
      "Середній ризик",
    ),
    "g_key_aa_session_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Перегляньте дозволи перед підтвердженням",
    ),
    "g_key_aa_session_select_preset": MessageLookupByLibrary.simpleMessage(
      "Виберіть рівень дозволу",
    ),
    "g_key_aa_session_transfer_can": MessageLookupByLibrary.simpleMessage(
      "Передайте токени в межах встановленого ліміту",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "Базовий смарт-акаунт з одним власником - рекомендований для більшості користувачів",
    ),
    "g_key_aa_smart_accounts": MessageLookupByLibrary.simpleMessage(
      "Розумні облікові записи",
    ),
    "g_key_aa_smart_wallet": MessageLookupByLibrary.simpleMessage(
      "Розумний гаманець",
    ),
    "g_key_aa_spending_limit": MessageLookupByLibrary.simpleMessage(
      "Ліміт витрат",
    ),
    "g_key_aa_sponsored": MessageLookupByLibrary.simpleMessage(
      "Спонсорований (безкоштовний)",
    ),
    "g_key_aa_title": MessageLookupByLibrary.simpleMessage(
      "Розумний обліковий запис",
    ),
    "g_key_aa_total_gas": MessageLookupByLibrary.simpleMessage("Загальний газ"),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage("транзакції"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage(
      "Переглянути всі",
    ),
    "g_key_address": MessageLookupByLibrary.simpleMessage("Адреса"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage(
      "Будь ласка, введіть ім\'я",
    ),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage(
      "Будь ласка, введіть адресу",
    ),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage(
      "Виберіть тип монети",
    ),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage(
      "Редагувати адресу",
    ),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage("Успішно видалено"),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage("Виберіть монети"),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage("Пошук монет"),
    "g_key_advanced_features": MessageLookupByLibrary.simpleMessage(
      "Розширені функції",
    ),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage(
      "Додати одержувача",
    ),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage(
      "Трансляція...",
    ),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage(
      "Очистити все",
    ),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Підтвердити пакетну передачу",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("Продовжити"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "Формат CSV: адреса, сума, мітка",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("Готово"),
    "g_key_batch_duplicate_address": m10,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Оцінка газу...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "Пакетна передача підтримує лише ланцюжки EVM",
    ),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage(
      "Експорт CSV",
    ),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "Довідка щодо пакетного перенесення",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "Імпорт CSV",
    ),
    "g_key_batch_insufficient_balance": m11,
    "g_key_batch_invalid_address": m12,
    "g_key_batch_invalid_amount": m13,
    "g_key_batch_max_recipients": m14,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "Пам\'ятка необов\'язкова",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Використовуйте Multicall3, щоб знизити плату за газ",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "Немає підтримуваних токенів",
    ),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage(
      "Одержувачі",
    ),
    "g_key_batch_select_token": MessageLookupByLibrary.simpleMessage(
      "Виберіть Токен",
    ),
    "g_key_batch_send_multiple": MessageLookupByLibrary.simpleMessage(
      "Надішліть токени на кілька адрес за одну транзакцію",
    ),
    "g_key_batch_signing": MessageLookupByLibrary.simpleMessage(
      "Підписання...",
    ),
    "g_key_batch_swipe_remove": MessageLookupByLibrary.simpleMessage(
      "Проведіть пальцем ліворуч, щоб видалити одержувача",
    ),
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage(
      "Пакетна передача",
    ),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage(
      "Загальна сума",
    ),
    "g_key_bridge_chain_not_supported": MessageLookupByLibrary.simpleMessage(
      "Ланцюг не підтримується",
    ),
    "g_key_bridge_cheapest": MessageLookupByLibrary.simpleMessage(
      "Найдешевший",
    ),
    "g_key_bridge_estimated_receive": MessageLookupByLibrary.simpleMessage(
      "Ви отримаєте (приблизно)",
    ),
    "g_key_bridge_fastest": MessageLookupByLibrary.simpleMessage("Найшвидший"),
    "g_key_bridge_get_quote": MessageLookupByLibrary.simpleMessage(
      "Отримати пропозицію",
    ),
    "g_key_bridge_history": MessageLookupByLibrary.simpleMessage(
      "Історія мосту",
    ),
    "g_key_bridge_no_routes": MessageLookupByLibrary.simpleMessage(
      "Немає доступних маршрутів",
    ),
    "g_key_bridge_recommended": MessageLookupByLibrary.simpleMessage(
      "Рекомендовано",
    ),
    "g_key_bridge_refresh": MessageLookupByLibrary.simpleMessage("Оновити"),
    "g_key_bridge_route": MessageLookupByLibrary.simpleMessage("Маршрут"),
    "g_key_bridge_search_chain": MessageLookupByLibrary.simpleMessage(
      "Пошуковий ланцюжок...",
    ),
    "g_key_bridge_select": MessageLookupByLibrary.simpleMessage("Виберіть"),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage(
      "Виберіть Токен",
    ),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage("Ковзання"),
    "g_key_bridge_status_completed": MessageLookupByLibrary.simpleMessage(
      "Виконано",
    ),
    "g_key_bridge_status_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося",
    ),
    "g_key_bridge_status_in_progress": MessageLookupByLibrary.simpleMessage(
      "В роботі",
    ),
    "g_key_bridge_status_pending": MessageLookupByLibrary.simpleMessage(
      "В очікуванні",
    ),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("Міст"),
    "g_key_bridge_tx_failed": MessageLookupByLibrary.simpleMessage(
      "Міст не вдається",
    ),
    "g_key_bridge_tx_pending": MessageLookupByLibrary.simpleMessage(
      "Трансакція очікує на розгляд",
    ),
    "g_key_bridge_tx_success": MessageLookupByLibrary.simpleMessage(
      "Міст Успішний",
    ),
    "g_key_btc_redeem_locked_until": MessageLookupByLibrary.simpleMessage(
      "Заблоковано до",
    ),
    "g_key_btc_redeem_reminder": MessageLookupByLibrary.simpleMessage(
      "Переконайтеся, що період блокування минув, перш ніж надсилати викуп.",
    ),
    "g_key_btc_redeem_still_locked": MessageLookupByLibrary.simpleMessage(
      "BTC все ще заблоковано",
    ),
    "g_key_btc_redeem_title": MessageLookupByLibrary.simpleMessage(
      "Викупити vBTC",
    ),
    "g_key_btc_redeem_unlocked": MessageLookupByLibrary.simpleMessage(
      "Розблоковано — готовий до викупу",
    ),
    "g_key_btc_stake_acknowledge": MessageLookupByLibrary.simpleMessage(
      "Я розумію ризики та хочу продовжити",
    ),
    "g_key_btc_stake_continue": MessageLookupByLibrary.simpleMessage(
      "Продовжуйте робити ставки",
    ),
    "g_key_btc_stake_how_it_works": MessageLookupByLibrary.simpleMessage(
      "Як це працює",
    ),
    "g_key_btc_stake_reminder": MessageLookupByLibrary.simpleMessage(
      "BTC буде заблоковано до закінчення часу блокування. Завершіть процес стекінгу в інтерфейсі нижче.",
    ),
    "g_key_btc_stake_risk1": MessageLookupByLibrary.simpleMessage(
      "Ваші BTC будуть заблоковані на весь період стекінгу. Дострокове зняття неможливе.",
    ),
    "g_key_btc_stake_risk2": MessageLookupByLibrary.simpleMessage(
      "Блокування виконується біткойн OP_CHECKLOCKTIMEVERIFY (CLTV) і його неможливо обійти.",
    ),
    "g_key_btc_stake_risk3": MessageLookupByLibrary.simpleMessage(
      "Ризик смарт-контракту: хоча перевірено, жоден протокол не є повністю вільним від ризику.",
    ),
    "g_key_btc_stake_risk4": MessageLookupByLibrary.simpleMessage(
      "Мінімальна ставка: 0,001 BTC. Мінімальний період блокування: 0,125 дня (~3 години).",
    ),
    "g_key_btc_stake_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Попередження про ризик",
    ),
    "g_key_btc_stake_step1_desc": MessageLookupByLibrary.simpleMessage(
      "Ваші BTC заблоковані в адресі 2 з 2 з кількома підписами з блокуванням часу (CLTV), захищеним вашим ключем і каністерним ключем N42.",
    ),
    "g_key_btc_stake_step1_title": MessageLookupByLibrary.simpleMessage(
      "Заблокуйте свій BTC",
    ),
    "g_key_btc_stake_step2_desc": MessageLookupByLibrary.simpleMessage(
      "Після підтвердження в мережі vBTC карбується у ваш гаманець у співвідношенні 1:1.",
    ),
    "g_key_btc_stake_step2_title": MessageLookupByLibrary.simpleMessage(
      "Монетний двір vBTC",
    ),
    "g_key_btc_stake_step3_desc": MessageLookupByLibrary.simpleMessage(
      "Тримайте vBTC, щоб отримати винагороду за ставки. vBTC також можна використовувати в протоколах DeFi.",
    ),
    "g_key_btc_stake_step3_title": MessageLookupByLibrary.simpleMessage(
      "Заробляйте нагороди",
    ),
    "g_key_btc_stake_step4_desc": MessageLookupByLibrary.simpleMessage(
      "Коли період блокування закінчиться, запишіть свій vBTC, щоб отримати свій оригінальний BTC.",
    ),
    "g_key_btc_stake_step4_title": MessageLookupByLibrary.simpleMessage(
      "Викупити після розблокування",
    ),
    "g_key_btc_stake_title": MessageLookupByLibrary.simpleMessage(
      "Ставка самостійної опіки BTC",
    ),
    "g_key_burn_got_it": MessageLookupByLibrary.simpleMessage("зрозумів"),
    "g_key_burn_nft_step1": MessageLookupByLibrary.simpleMessage(
      "1. Виберіть токен із підтримкою NFT",
    ),
    "g_key_burn_nft_step2": MessageLookupByLibrary.simpleMessage(
      "2. Перейдіть на вкладку NFT",
    ),
    "g_key_burn_nft_step3": MessageLookupByLibrary.simpleMessage(
      "3. Виберіть NFT, який ви хочете записати",
    ),
    "g_key_burn_nft_step4": MessageLookupByLibrary.simpleMessage(
      "4. Натисніть кнопку «Записати».",
    ),
    "g_key_burn_nft_steps": MessageLookupByLibrary.simpleMessage("Кроки:"),
    "g_key_burn_nft_tip": MessageLookupByLibrary.simpleMessage(
      "Щоб записати NFT, перейдіть на сторінку деталей NFT і натисніть кнопку «Записати».",
    ),
    "g_key_chain_transfer_not_supported": MessageLookupByLibrary.simpleMessage(
      "Ця мережа ще не підтримує перекази, слідкуйте за оновленнями",
    ),
    "g_key_coin_list_all_hidden": MessageLookupByLibrary.simpleMessage(
      "Усі активи нижчі за 1 долар США",
    ),
    "g_key_coin_list_separator": MessageLookupByLibrary.simpleMessage(
      "Інші активи",
    ),
    "g_key_coin_list_show_all": MessageLookupByLibrary.simpleMessage(
      "Торкніться, щоб показати все",
    ),
    "g_key_coin_search_recent": MessageLookupByLibrary.simpleMessage("Останні"),
    "g_key_dex_approval_success": MessageLookupByLibrary.simpleMessage(
      "Затверджено! Натисніть «Поміняти», щоб продовжити.",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage(
      "Точна сума",
    ),
    "g_key_dex_approve_required": m15,
    "g_key_dex_approve_unlimited": MessageLookupByLibrary.simpleMessage(
      "Необмежений",
    ),
    "g_key_dex_approve_unlimited_info": MessageLookupByLibrary.simpleMessage(
      "Необмежене схвалення: маршрутизатор може витратити цей токен будь-коли. Стандартна практика, але несе ризики, якщо контракт буде порушено.",
    ),
    "g_key_dex_approving": MessageLookupByLibrary.simpleMessage("Схвалення…"),
    "g_key_dex_best_route": MessageLookupByLibrary.simpleMessage(
      "Найкращий маршрут",
    ),
    "g_key_dex_best_source": MessageLookupByLibrary.simpleMessage(
      "Найкраще джерело",
    ),
    "g_key_dex_chain": MessageLookupByLibrary.simpleMessage("ланцюг"),
    "g_key_dex_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Підтвердити обмін",
    ),
    "g_key_dex_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Кошторис газу",
    ),
    "g_key_dex_history_title": MessageLookupByLibrary.simpleMessage(
      "Історія DEX",
    ),
    "g_key_dex_min_received": MessageLookupByLibrary.simpleMessage(
      "Мін. Отримано",
    ),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage(
      "Ніяких жетонів",
    ),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "Токенів не знайдено",
    ),
    "g_key_dex_price_chart": MessageLookupByLibrary.simpleMessage(
      "Діаграма цін",
    ),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage(
      "Вплив ціни",
    ),
    "g_key_dex_price_impact_high": m16,
    "g_key_dex_quote_expires": m17,
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Помилка цитати",
    ),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "Символ пошуку / ім\'я / адреса",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage("Виберіть"),
    "g_key_dex_slippage_label": MessageLookupByLibrary.simpleMessage(
      "Максимальне ковзання",
    ),
    "g_key_dex_status_confirmed": MessageLookupByLibrary.simpleMessage(
      "Підтверджено",
    ),
    "g_key_dex_status_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося",
    ),
    "g_key_dex_status_pending": MessageLookupByLibrary.simpleMessage(
      "В очікуванні",
    ),
    "g_key_dex_status_quoted": MessageLookupByLibrary.simpleMessage(
      "Процитований",
    ),
    "g_key_dex_swap_btn": MessageLookupByLibrary.simpleMessage("Обмін"),
    "g_key_dex_swap_success": MessageLookupByLibrary.simpleMessage(
      "Обмін успішно надіслано",
    ),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("Ви платите"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage(
      "Ви отримуєте",
    ),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "Активні продукти",
    ),
    "g_key_earn_batch": MessageLookupByLibrary.simpleMessage("партія"),
    "g_key_earn_burn": MessageLookupByLibrary.simpleMessage("спалити"),
    "g_key_earn_buy_n": MessageLookupByLibrary.simpleMessage("Купити Н"),
    "g_key_earn_buy_n_desc": MessageLookupByLibrary.simpleMessage(
      "Купуйте N з протоколом AST",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "Перехресна передача",
    ),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage("Обмін DEX"),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("газ"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage(
      "Почніть робити ставки",
    ),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("Леджер"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage(
      "Завантаження APY...",
    ),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage("Майнінг"),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage(
      "Заробляйте більше",
    ),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "Рідна ставка Солана",
    ),
    "g_key_earn_no_positions": MessageLookupByLibrary.simpleMessage(
      "Немає активних позицій",
    ),
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "Отримуйте нагороди, беручи участь у видобутку вузлів",
    ),
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage(
      "Швидкі інструменти",
    ),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage(
      "Рекомендовано",
    ),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage(
      "Виберіть Тип обміну",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Ставте ETH з Lido",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("Обмін"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("заробити"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage(
      "Загальний прибуток",
    ),
    "g_key_earn_up_to_apy": m18,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage(
      "Переглянути всі",
    ),
    "g_key_ens_address_updated": MessageLookupByLibrary.simpleMessage(
      "Вирішена адреса оновлена",
    ),
    "g_key_ens_advanced": MessageLookupByLibrary.simpleMessage("Просунутий"),
    "g_key_ens_annual_fee": MessageLookupByLibrary.simpleMessage("Річна плата"),
    "g_key_ens_available": MessageLookupByLibrary.simpleMessage("в наявності"),
    "g_key_ens_base_price": MessageLookupByLibrary.simpleMessage("Базова ціна"),
    "g_key_ens_checking": MessageLookupByLibrary.simpleMessage(
      "Перевірка наявності...",
    ),
    "g_key_ens_commit": MessageLookupByLibrary.simpleMessage("Здійснити"),
    "g_key_ens_commit_failed": MessageLookupByLibrary.simpleMessage(
      "Помилка фіксації",
    ),
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "Термін дії реєстраційного зобов’язання закінчився. Будь ласка, почніть процес реєстрації знову.",
    ),
    "g_key_ens_committing": MessageLookupByLibrary.simpleMessage(
      "Здійснення...",
    ),
    "g_key_ens_confirm_renew": MessageLookupByLibrary.simpleMessage(
      "Підтвердити поновлення",
    ),
    "g_key_ens_confirm_send": MessageLookupByLibrary.simpleMessage(
      "Підтвердити та надіслати",
    ),
    "g_key_ens_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Підтвердьте дозвіл ENS",
    ),
    "g_key_ens_copy_address": MessageLookupByLibrary.simpleMessage(
      "Адресу скопійовано",
    ),
    "g_key_ens_current_expiry": MessageLookupByLibrary.simpleMessage(
      "Поточний термін дії",
    ),
    "g_key_ens_days_left": MessageLookupByLibrary.simpleMessage(
      "залишилося днів",
    ),
    "g_key_ens_description": MessageLookupByLibrary.simpleMessage(
      "Зареєструйте свої доменні імена .eth і керуйте ними",
    ),
    "g_key_ens_detected": MessageLookupByLibrary.simpleMessage(
      "Виявлено назву ENS",
    ),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage(
      "Термін дії минув",
    ),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage(
      "Термін дії закінчується",
    ),
    "g_key_ens_extend_period": MessageLookupByLibrary.simpleMessage(
      "Подовження терміну реєстрації",
    ),
    "g_key_ens_failed": MessageLookupByLibrary.simpleMessage("Не вдалося"),
    "g_key_ens_finalizing": MessageLookupByLibrary.simpleMessage(
      "Завершення реєстрації",
    ),
    "g_key_ens_get_started": MessageLookupByLibrary.simpleMessage(
      "Почніть роботу з ENS",
    ),
    "g_key_ens_get_your_name": MessageLookupByLibrary.simpleMessage(
      "Отримайте своє ім’я .eth",
    ),
    "g_key_ens_invalid_address": MessageLookupByLibrary.simpleMessage(
      "Недійсна адреса (має бути 0x + 40 шістнадцяткових символів)",
    ),
    "g_key_ens_invalid_name": MessageLookupByLibrary.simpleMessage(
      "Недійсна назва ENS",
    ),
    "g_key_ens_is_yours": MessageLookupByLibrary.simpleMessage("тепер ваш!"),
    "g_key_ens_keep_app_open": MessageLookupByLibrary.simpleMessage(
      "Будь ласка, тримайте додаток відкритим під час реєстрації",
    ),
    "g_key_ens_manage_your_identity": MessageLookupByLibrary.simpleMessage(
      "Керуйте своєю ідентифікацією Web3",
    ),
    "g_key_ens_min_length": MessageLookupByLibrary.simpleMessage(
      "Мінімум 3 символи",
    ),
    "g_key_ens_my_domains": MessageLookupByLibrary.simpleMessage("Мої домени"),
    "g_key_ens_name": MessageLookupByLibrary.simpleMessage("Назва ENS"),
    "g_key_ens_new_expiry": MessageLookupByLibrary.simpleMessage(
      "Новий термін дії",
    ),
    "g_key_ens_new_owner": MessageLookupByLibrary.simpleMessage(
      "Нова адреса власника",
    ),
    "g_key_ens_no_domains": MessageLookupByLibrary.simpleMessage(
      "Доменів ще немає",
    ),
    "g_key_ens_owner": MessageLookupByLibrary.simpleMessage("Власник"),
    "g_key_ens_please_wait": MessageLookupByLibrary.simpleMessage(
      "Будь ласка, зачекайте",
    ),
    "g_key_ens_premium_name": MessageLookupByLibrary.simpleMessage(
      "Преміум ім\'я",
    ),
    "g_key_ens_price_breakdown": MessageLookupByLibrary.simpleMessage(
      "Розбивка цін",
    ),
    "g_key_ens_primary": MessageLookupByLibrary.simpleMessage("Первинний"),
    "g_key_ens_primary_set": MessageLookupByLibrary.simpleMessage(
      "Первинне ім\'я встановлено успішно",
    ),
    "g_key_ens_processing": MessageLookupByLibrary.simpleMessage("Обробка..."),
    "g_key_ens_purchase_title": MessageLookupByLibrary.simpleMessage(
      "Зареєструвати ENS",
    ),
    "g_key_ens_register": MessageLookupByLibrary.simpleMessage(
      "зареєструватися",
    ),
    "g_key_ens_register_description": MessageLookupByLibrary.simpleMessage(
      "Ваша децентралізована ідентифікація в Ethereum",
    ),
    "g_key_ens_register_failed": MessageLookupByLibrary.simpleMessage(
      "Помилка реєстрації",
    ),
    "g_key_ens_register_now": MessageLookupByLibrary.simpleMessage(
      "Зареєструватися зараз",
    ),
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage(
      "Реєстрація...",
    ),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage(
      "Реєстраційна інформація",
    ),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "Період реєстрації",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage(
      "Увімкнути нагадування про закінчення терміну дії",
    ),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "Повідомити за 30, 7 і 1 день до закінчення терміну дії",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("Відновити"),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "Продовжте реєстрацію домену",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "Оновлення успішне",
    ),
    "g_key_ens_resolved_address": MessageLookupByLibrary.simpleMessage(
      "Вирішена адреса",
    ),
    "g_key_ens_resolving": MessageLookupByLibrary.simpleMessage(
      "Вирішення ENS...",
    ),
    "g_key_ens_search": MessageLookupByLibrary.simpleMessage("Пошук"),
    "g_key_ens_search_desc": MessageLookupByLibrary.simpleMessage(
      "Знайдіть доступні імена .eth",
    ),
    "g_key_ens_search_hint": MessageLookupByLibrary.simpleMessage(
      "Знайдіть назву .eth",
    ),
    "g_key_ens_search_prompt": MessageLookupByLibrary.simpleMessage(
      "Введіть назву ENS для пошуку",
    ),
    "g_key_ens_search_register": MessageLookupByLibrary.simpleMessage(
      "Пошук і реєстрація",
    ),
    "g_key_ens_search_title": MessageLookupByLibrary.simpleMessage("Пошук ENS"),
    "g_key_ens_self_transfer": MessageLookupByLibrary.simpleMessage(
      "Неможливо відправити на власну адресу",
    ),
    "g_key_ens_service": MessageLookupByLibrary.simpleMessage(
      "Служба імен Ethereum",
    ),
    "g_key_ens_set_primary": MessageLookupByLibrary.simpleMessage(
      "Установити як основний",
    ),
    "g_key_ens_standard_name": MessageLookupByLibrary.simpleMessage(
      "Стандартна назва",
    ),
    "g_key_ens_start_registration": MessageLookupByLibrary.simpleMessage(
      "Почніть реєстрацію",
    ),
    "g_key_ens_step_1": MessageLookupByLibrary.simpleMessage("Крок 1"),
    "g_key_ens_step_2": MessageLookupByLibrary.simpleMessage("Крок 2"),
    "g_key_ens_step_3": MessageLookupByLibrary.simpleMessage("Крок 3"),
    "g_key_ens_subdomain_create": MessageLookupByLibrary.simpleMessage(
      "Створити субдомен",
    ),
    "g_key_ens_subdomain_created": MessageLookupByLibrary.simpleMessage(
      "Субдомен створено",
    ),
    "g_key_ens_subdomain_delete": MessageLookupByLibrary.simpleMessage(
      "Видалити субдомен",
    ),
    "g_key_ens_subdomain_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "Цей субдомен буде остаточно видалено.",
    ),
    "g_key_ens_subdomain_deleted": MessageLookupByLibrary.simpleMessage(
      "Субдомен видалено",
    ),
    "g_key_ens_subdomain_empty": MessageLookupByLibrary.simpleMessage(
      "Субдоменів ще немає",
    ),
    "g_key_ens_subdomain_invalid_label": MessageLookupByLibrary.simpleMessage(
      "Використовуйте лише літери, цифри та дефіси",
    ),
    "g_key_ens_subdomain_label": MessageLookupByLibrary.simpleMessage(
      "Мітка субдомену",
    ),
    "g_key_ens_subdomain_label_hint": MessageLookupByLibrary.simpleMessage(
      "напр. блог, пошта, додаток",
    ),
    "g_key_ens_subdomain_owner": MessageLookupByLibrary.simpleMessage(
      "Адреса власника",
    ),
    "g_key_ens_subdomain_owner_hint": MessageLookupByLibrary.simpleMessage(
      "Залиште пустим, щоб використовувати поточний гаманець",
    ),
    "g_key_ens_subdomains": MessageLookupByLibrary.simpleMessage("Субдомени"),
    "g_key_ens_success": MessageLookupByLibrary.simpleMessage("Успіх!"),
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage("Пропозиції"),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage(
      "Текстові записи",
    ),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("Менеджер ENS"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("Всього"),
    "g_key_ens_transfer": MessageLookupByLibrary.simpleMessage("Трансфер"),
    "g_key_ens_transfer_desc": MessageLookupByLibrary.simpleMessage(
      "Передача права власності на іншу адресу",
    ),
    "g_key_ens_transfer_success": MessageLookupByLibrary.simpleMessage(
      "Передача успішна",
    ),
    "g_key_ens_transfer_warning": MessageLookupByLibrary.simpleMessage(
      "Передача необоротна. Переконайтеся, що нова адреса власника правильна.",
    ),
    "g_key_ens_try_another": MessageLookupByLibrary.simpleMessage(
      "Спробуйте інше ім\'я",
    ),
    "g_key_ens_two_step_process": MessageLookupByLibrary.simpleMessage(
      "Реєстрація ENS складається з двох етапів",
    ),
    "g_key_ens_unavailable": MessageLookupByLibrary.simpleMessage(
      "Недоступний",
    ),
    "g_key_ens_wait": MessageLookupByLibrary.simpleMessage("Зачекайте"),
    "g_key_ens_wait_explanation": MessageLookupByLibrary.simpleMessage(
      "Період очікування запобігає фронтальним атакам",
    ),
    "g_key_ens_wait_time_info": MessageLookupByLibrary.simpleMessage(
      "Період очікування запобігає передові",
    ),
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("Очікування..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "Перш ніж продовжити, перевірте вибрану адресу. Імена ENS можуть бути передані або змінені їх власником.",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("рік"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("років"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "Ваша особистість",
    ),
    "g_key_error_1": MessageLookupByLibrary.simpleMessage(
      "Помилка аналізу даних відповіді!",
    ),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("Помилка Dio"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage(
      "Синтаксична помилка запиту",
    ),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage(
      "Не авторизовано, будь ласка, увійдіть",
    ),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage("Доступ заборонено"),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("Помилка запиту"),
    "g_key_error_15": MessageLookupByLibrary.simpleMessage(
      "Час очікування запиту минув",
    ),
    "g_key_error_16": MessageLookupByLibrary.simpleMessage(
      "Ненормальний сервер",
    ),
    "g_key_error_17": MessageLookupByLibrary.simpleMessage(
      "Послуга не реалізована",
    ),
    "g_key_error_18": MessageLookupByLibrary.simpleMessage("Помилка шлюзу"),
    "g_key_error_19": MessageLookupByLibrary.simpleMessage(
      "Послуга недоступна",
    ),
    "g_key_error_20": MessageLookupByLibrary.simpleMessage(
      "Час очікування шлюзу",
    ),
    "g_key_error_21": MessageLookupByLibrary.simpleMessage(
      "Версія HTTP не підтримується",
    ),
    "g_key_error_22": MessageLookupByLibrary.simpleMessage(
      "Запит не виконано, код помилки:",
    ),
    "g_key_error_23": MessageLookupByLibrary.simpleMessage(
      "Система зайнята, спробуйте пізніше",
    ),
    "g_key_error_24": MessageLookupByLibrary.simpleMessage(
      "Частота запитів занадто висока",
    ),
    "g_key_error_25": MessageLookupByLibrary.simpleMessage(
      "Помилка декодування",
    ),
    "g_key_error_26": MessageLookupByLibrary.simpleMessage(
      "Транзакція вже в ланцюжку",
    ),
    "g_key_error_27": MessageLookupByLibrary.simpleMessage(
      "Помилка налаштування сертифіката!",
    ),
    "g_key_error_28": MessageLookupByLibrary.simpleMessage(
      "Помилка конфігурації коду стану!",
    ),
    "g_key_error_3": MessageLookupByLibrary.simpleMessage("Невідома помилка!"),
    "g_key_error_4": MessageLookupByLibrary.simpleMessage(
      "Час очікування підключення до мережі закінчився, перевірте налаштування мережі!",
    ),
    "g_key_error_5": MessageLookupByLibrary.simpleMessage(
      "Сервер ненормальний. Спробуйте пізніше!",
    ),
    "g_key_error_8": MessageLookupByLibrary.simpleMessage(
      "Запит скасовано, надішліть запит ще раз!",
    ),
    "g_key_ex_keystore": MessageLookupByLibrary.simpleMessage(
      "Експортувати сховище ключів",
    ),
    "g_key_ex_keystore_1": MessageLookupByLibrary.simpleMessage(
      "Поради щодо резервного копіювання",
    ),
    "g_key_ex_keystore_10": MessageLookupByLibrary.simpleMessage(
      "Для зберігання використовуйте інструмент керування паролями.",
    ),
    "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("Скопійовано"),
    "g_key_ex_keystore_12": MessageLookupByLibrary.simpleMessage(
      "Копіювання скасовано",
    ),
    "g_key_ex_keystore_13": MessageLookupByLibrary.simpleMessage(
      "Ідентифікаційний гаманець",
    ),
    "g_key_ex_keystore_15": MessageLookupByLibrary.simpleMessage(
      "Зашифрований файл закритого ключа.",
    ),
    "g_key_ex_keystore_16": MessageLookupByLibrary.simpleMessage(
      "Спосіб імпорту",
    ),
    "g_key_ex_keystore_17": MessageLookupByLibrary.simpleMessage(
      "Файл сховища ключів",
    ),
    "g_key_ex_keystore_18": MessageLookupByLibrary.simpleMessage(
      "Введіть інформацію про сховище ключів.",
    ),
    "g_key_ex_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Експорт приватного ключа",
    ),
    "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
      "Отримання сховища ключів і пароля дасть власнику повний контроль над активами гаманця.",
    ),
    "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
      "Ретельно записуйте та зберігайте в надійному місці. Зберігання кількох фізичних копій є найбезпечнішим способом зберігання.",
    ),
    "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
      "Якщо ваш закритий ключ втрачено, його неможливо відновити. Створіть його фізичну резервну копію та надійно зберігайте.",
    ),
    "g_key_ex_keystore_5": MessageLookupByLibrary.simpleMessage(
      "Зберегти офлайн",
    ),
    "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
      "Не зберігайте в поштову скриньку, блокнот, мережевий диск або програмне забезпечення для чату, яке є незахищеним.",
    ),
    "g_key_ex_keystore_7": MessageLookupByLibrary.simpleMessage(
      "Будь ласка, використовуйте мережеву передачу",
    ),
    "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
      "Будь ласка, не забудьте передати його через мережеві інструменти. Як тільки хакери його отримають, це спричинить непоправні економічні втрати",
    ),
    "g_key_ex_keystore_9": MessageLookupByLibrary.simpleMessage(
      "Використовуйте інструменти для збереження",
    ),
    "g_key_ex_keystore_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Я розумію, що будь-хто, хто отримає цей файл і пароль, має повний контроль над моїми коштами — втрата є постійною та непоправною",
    ),
    "g_key_ex_keystore_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Введіть пароль гаманця, щоб підтвердити експорт",
    ),
    "g_key_ex_pk_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Введіть пароль гаманця, щоб переглянути закритий ключ",
    ),
    "g_key_filter": MessageLookupByLibrary.simpleMessage("фільтр"),
    "g_key_gas_alert": MessageLookupByLibrary.simpleMessage(
      "Сповіщення про газ",
    ),
    "g_key_gas_alert_above": MessageLookupByLibrary.simpleMessage(
      "Сповіщати, коли вище",
    ),
    "g_key_gas_alert_below": MessageLookupByLibrary.simpleMessage(
      "Сповіщення, коли нижче",
    ),
    "g_key_gas_alert_save": MessageLookupByLibrary.simpleMessage("зберегти"),
    "g_key_gas_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "Поріг (Gwei)",
    ),
    "g_key_gas_auto_refresh": m19,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("Базовий збір"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("швидко"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "Ціни на газ коливаються залежно від попиту в мережі. Менший газ = повільніше підтвердження, більший газ = швидше підтвердження.",
    ),
    "g_key_gas_max_fee": MessageLookupByLibrary.simpleMessage(
      "Максимальна комісія",
    ),
    "g_key_gas_network_busy": MessageLookupByLibrary.simpleMessage(
      "Мережа зайнята",
    ),
    "g_key_gas_network_idle": MessageLookupByLibrary.simpleMessage(
      "Мережа неактивна",
    ),
    "g_key_gas_network_normal": MessageLookupByLibrary.simpleMessage(
      "Мережа нормальна",
    ),
    "g_key_gas_price_trend": MessageLookupByLibrary.simpleMessage(
      "Тенденція цін",
    ),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage(
      "Плата за пріоритет",
    ),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "Ціни на газ у реальному часі",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage(
      "Налаштування газу",
    ),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("Повільно"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("Стандартний"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage("Газовий трекер"),
    "g_key_hw_account_added": m20,
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "Обліковий запис уже імпортовано",
    ),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("додати"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage(
      "Додати обліковий запис",
    ),
    "g_key_hw_add_account_content": m21,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Адресу скопійовано",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Перед підключенням переконайтеся, що ваш пристрій розблоковано та Bluetooth увімкнено.",
    ),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage(
      "Перевірте додаток",
    ),
    "g_key_hw_connect_new_device": MessageLookupByLibrary.simpleMessage(
      "Підключити новий пристрій",
    ),
    "g_key_hw_connect_new_keystone": MessageLookupByLibrary.simpleMessage(
      "Повітряний зазор із трапецеїдальним спотворенням (QR)",
    ),
    "g_key_hw_connect_new_ledger": MessageLookupByLibrary.simpleMessage(
      "Підключити Ledger (Bluetooth)",
    ),
    "g_key_hw_connect_new_trezor": MessageLookupByLibrary.simpleMessage(
      "Підключити Trezor (USB)",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("Підключено"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage(
      "Підключення...",
    ),
    "g_key_hw_current_app_label": m22,
    "g_key_hw_days_ago": m23,
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Відключити"),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage(
      "Повернутися назад",
    ),
    "g_key_hw_import_failed": m24,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "Підключіть Keystone",
    ),
    "g_key_hw_keystone_scan_request_hint": MessageLookupByLibrary.simpleMessage(
      "Відскануйте цей QR-код за допомогою пристрою Keystone, щоб підписати транзакцію",
    ),
    "g_key_hw_keystone_scan_response_hint": MessageLookupByLibrary.simpleMessage(
      "Наведіть камеру на QR-код, який відображається на вашому пристрої Keystone",
    ),
    "g_key_hw_keystone_scan_response_title":
        MessageLookupByLibrary.simpleMessage("Сканування підпису Keystone"),
    "g_key_hw_keystone_scan_xpub_hint": MessageLookupByLibrary.simpleMessage(
      "Відскануйте QR-код зі свого пристрою Keystone, щоб імпортувати облікові записи",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Торкніться, щоб відсканувати відповідь Keystone",
    ),
    "g_key_hw_last_connected": m25,
    "g_key_hw_load_more": MessageLookupByLibrary.simpleMessage(
      "Завантажити більше",
    ),
    "g_key_hw_loading_accounts": MessageLookupByLibrary.simpleMessage(
      "Завантаження облікових записів...",
    ),
    "g_key_hw_loading_hint": MessageLookupByLibrary.simpleMessage(
      "Підтвердьте на своєму пристрої, якщо буде запропоновано",
    ),
    "g_key_hw_no_accounts_found": MessageLookupByLibrary.simpleMessage(
      "Облікові записи не знайдено",
    ),
    "g_key_hw_no_app_open": MessageLookupByLibrary.simpleMessage(
      "Наразі жодна програма не відкрита",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Пристрій не підключено",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Не підключено",
    ),
    "g_key_hw_open_ledger_app_hint": m26,
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("видалити"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "Видалити пристрій",
    ),
    "g_key_hw_remove_device_confirm": m27,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "Збережені пристрої",
    ),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage(
      "Підтримувані пристрої",
    ),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("Сьогодні"),
    "g_key_hw_trezor_connect_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося підключитися до Trezor. Переконайтеся, що USB підключено.",
    ),
    "g_key_hw_trezor_connect_title": MessageLookupByLibrary.simpleMessage(
      "Підключіть Trezor",
    ),
    "g_key_hw_trezor_connected": MessageLookupByLibrary.simpleMessage(
      "Trezor підключився успішно",
    ),
    "g_key_hw_trezor_connecting": MessageLookupByLibrary.simpleMessage(
      "Підключення до Trezor...",
    ),
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "Підключіть свій пристрій Trezor через USB-кабель і розблокуйте його",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage(
      "Перегляд облікових записів",
    ),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage(
      "Облікові записи Wallet",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("вчора"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Поточний валютний гаманець уже існує.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Не вдалося прочитати Keystore",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("Сховище ключів"),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Увійти"),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Вийти"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Ви впевнені, що бажаєте вийти з програми?",
    ),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebook"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Twitter"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("Reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("Браузер"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("Телеграма"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("Розбрат"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("Youtube"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("Instagram"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("Ринкова капіталізація"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("Обсяг торгів"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("Загальна пропозиція"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("В обігу"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("про"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("більше"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("Посилання"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("Веб-сайт"),
    "g_key_manage_chains": MessageLookupByLibrary.simpleMessage(
      "Керуйте ланцюгами",
    ),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage(
      "в наявності",
    ),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "Вимагає ставки",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Введіть вихідну фразу",
    ),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Всього"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Ім\'я"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Назад"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("Трансакцію подано"),
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage(
      "Недійсна адреса гаманця",
    ),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("Баланс"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "Ця дія незворотна. NFT буде надіслано на адресу запису.",
    ),
    "g_key_nft_burn_title": MessageLookupByLibrary.simpleMessage(
      "Записати NFT",
    ),
    "g_key_nft_collection": MessageLookupByLibrary.simpleMessage("Колекція"),
    "g_key_nft_contract": MessageLookupByLibrary.simpleMessage("Договір"),
    "g_key_nft_description": MessageLookupByLibrary.simpleMessage("опис"),
    "g_key_nft_error_retry": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити NFT. Торкніться, щоб повторити спробу.",
    ),
    "g_key_nft_filter_all": MessageLookupByLibrary.simpleMessage("всі"),
    "g_key_nft_filter_video": MessageLookupByLibrary.simpleMessage("відео"),
    "g_key_nft_floor_price": MessageLookupByLibrary.simpleMessage("Поверх"),
    "g_key_nft_gallery": MessageLookupByLibrary.simpleMessage("Галерея NFT"),
    "g_key_nft_inscription": MessageLookupByLibrary.simpleMessage("напис #"),
    "g_key_nft_no_items": MessageLookupByLibrary.simpleMessage(
      "NFT не знайдено",
    ),
    "g_key_nft_no_url": MessageLookupByLibrary.simpleMessage(
      "Немає доступного посилання на провідник",
    ),
    "g_key_nft_no_video_support": MessageLookupByLibrary.simpleMessage(
      "Відтворення відео не підтримується",
    ),
    "g_key_nft_ordinals": MessageLookupByLibrary.simpleMessage("Порядкові"),
    "g_key_nft_ordinals_unsupported": MessageLookupByLibrary.simpleMessage(
      "Порядкові перекази ще не підтримуються",
    ),
    "g_key_nft_quantity": MessageLookupByLibrary.simpleMessage("Кількість"),
    "g_key_nft_search_hint": MessageLookupByLibrary.simpleMessage(
      "Пошук за назвою або колекцією",
    ),
    "g_key_nft_send": MessageLookupByLibrary.simpleMessage("Надіслати NFT"),
    "g_key_nft_send_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Перекази Solana NFT будуть незабаром",
    ),
    "g_key_nft_token_id": MessageLookupByLibrary.simpleMessage(
      "Ідентифікатор маркера",
    ),
    "g_key_nft_type": MessageLookupByLibrary.simpleMessage("Тип"),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "Паролі не збігаються",
    ),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Виберіть із галереї телефону",
    ),
    "g_key_reset": MessageLookupByLibrary.simpleMessage("Скинути"),
    "g_key_security_goplus_caution": MessageLookupByLibrary.simpleMessage(
      "Будьте обережні",
    ),
    "g_key_security_goplus_checking": MessageLookupByLibrary.simpleMessage(
      "Перевірка безпеки контракту...",
    ),
    "g_key_security_goplus_danger": MessageLookupByLibrary.simpleMessage(
      "Виявлено високий ризик",
    ),
    "g_key_security_goplus_powered_by": MessageLookupByLibrary.simpleMessage(
      "GoPlus",
    ),
    "g_key_security_goplus_safe": MessageLookupByLibrary.simpleMessage(
      "Контракт підтверджено безпечно",
    ),
    "g_key_send_memo_hint": MessageLookupByLibrary.simpleMessage(
      "Пам\'ятка / Примітка",
    ),
    "g_key_send_memo_label": MessageLookupByLibrary.simpleMessage(
      "Пам\'ятка / Примітка (необов\'язково)",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage(
      "Поділіться QR-кодом",
    ),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage(
      "Поділитися посиланням",
    ),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage(
      "Метод спільного використання",
    ),
    "g_key_sim_gas_estimate": m28,
    "g_key_sim_reverted": MessageLookupByLibrary.simpleMessage(
      "Транзакція, ймовірно, не вдасться",
    ),
    "g_key_sim_reverted_reason": m29,
    "g_key_sim_simulating": MessageLookupByLibrary.simpleMessage(
      "Імітація транзакції…",
    ),
    "g_key_sim_success": MessageLookupByLibrary.simpleMessage(
      "Симуляція транзакцій пройдена",
    ),
    "g_key_sim_unavailable": MessageLookupByLibrary.simpleMessage(
      "Симуляція недоступна для цієї мережі",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Чат"),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("Активний"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "Активні позиції",
    ),
    "g_key_stake_amount": MessageLookupByLibrary.simpleMessage("Сума"),
    "g_key_stake_amount_unstake": MessageLookupByLibrary.simpleMessage(
      "Сума для зняття ставки",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("APY"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("Середній APY"),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage("Комісія"),
    "g_key_stake_d_unbond": m30,
    "g_key_stake_days_remaining": m31,
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "Приблизно Щоденна винагорода",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "Приблизно Щорічна винагорода",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage(
      "Перейдіть до Swap",
    ),
    "g_key_stake_liquid_staking_label": MessageLookupByLibrary.simpleMessage(
      "Рідкий стейкинг",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("Рідина"),
    "g_key_stake_liquid_unstake_desc": MessageLookupByLibrary.simpleMessage(
      "Ваш ліквідний токен можна торгувати безпосередньо на DEX. Використовуйте Swap, щоб обміняти його назад на рідний ресурс.",
    ),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage(
      "Мінімальна ставка",
    ),
    "g_key_stake_no_active_positions": MessageLookupByLibrary.simpleMessage(
      "Немає активних позицій для скасування ставок",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage("Без замка"),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "Поки що немає ставок",
    ),
    "g_key_stake_no_validators": MessageLookupByLibrary.simpleMessage(
      "Валідаторів не знайдено",
    ),
    "g_key_stake_no_wallet": MessageLookupByLibrary.simpleMessage(
      "Адреса гаманця недоступна",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "Огляд загальної ставки",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "Мої позиції",
    ),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Протоколи"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("Нагороди"),
    "g_key_stake_search_validator": MessageLookupByLibrary.simpleMessage(
      "Пошук валідаторів...",
    ),
    "g_key_stake_select_a_validator": MessageLookupByLibrary.simpleMessage(
      "Виберіть валідатор",
    ),
    "g_key_stake_select_position": MessageLookupByLibrary.simpleMessage(
      "Виберіть позицію для зняття ставки",
    ),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "Виберіть засіб перевірки",
    ),
    "g_key_stake_sort_by": MessageLookupByLibrary.simpleMessage("Сортувати за"),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("Ставка"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("Ставили"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "Почніть робити ставки",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("Ставка"),
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage(
      "Трансакцію підготовлено успішно",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage(
      "Роз\'єднання",
    ),
    "g_key_stake_unbonding_warning": m32,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage("Зняти ставку"),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage(
      "Оновлення...",
    ),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Валідатор"),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage(
      "Ви отримаєте",
    ),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Повний"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Ціна на газ"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage(
      "Максимальна плата за газ",
    ),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage(
      "Максимальна плата за газ",
    ),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("В очікуванні"),
    "g_key_t_29": m33,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("провал"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Продовжуйте"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("Пароль гаманця"),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage(
      "Неправильний пароль гаманця",
    ),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage(
      "Введіть пароль гаманця",
    ),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage("Ставка плати за газ"),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage(
      "Середня ставка плати за газ останнього блоку",
    ),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage("Передача"),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage(
      "Введіть ціле число, більше 0.",
    ),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage(
      "Не вдалося отримати дані",
    ),
    "g_key_t_45": m34,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage(
      "Перевірте рахунок адреси отримання",
    ),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("знайти"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage(
      "Немає облікового запису",
    ),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage("Трансфер в"),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage("Недійсна адреса"),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage(
      "Перевірка облікового запису успішна",
    ),
    "g_key_t_52": m35,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "Адреса отримання не має облікового запису, і перший переказ становить принаймні 10 XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Використаний газ"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("газ"),
    "g_key_token_discovery_add": MessageLookupByLibrary.simpleMessage("додати"),
    "g_key_token_discovery_add_selected": m36,
    "g_key_token_discovery_added": MessageLookupByLibrary.simpleMessage(
      "Маркер додано",
    ),
    "g_key_token_discovery_banner": m37,
    "g_key_token_discovery_deselect_all": MessageLookupByLibrary.simpleMessage(
      "Зняти вибір із усіх",
    ),
    "g_key_token_discovery_empty": MessageLookupByLibrary.simpleMessage(
      "Нові маркери не знайдено",
    ),
    "g_key_token_discovery_ignore": MessageLookupByLibrary.simpleMessage(
      "Ігнорувати",
    ),
    "g_key_token_discovery_select_all": MessageLookupByLibrary.simpleMessage(
      "Вибрати все",
    ),
    "g_key_token_discovery_title": MessageLookupByLibrary.simpleMessage(
      "Виявлені жетони",
    ),
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage("Історія транзакцій"),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage("Деталі транзакції"),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage(
      "Перегляньте квитанції про операції в історії",
    ),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("Сума витрат"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("Отримати суму"),
    "g_key_tx_filter_date_from": MessageLookupByLibrary.simpleMessage(
      "Дата початку",
    ),
    "g_key_tx_filter_date_range": MessageLookupByLibrary.simpleMessage(
      "Діапазон дат",
    ),
    "g_key_tx_filter_date_to": MessageLookupByLibrary.simpleMessage(
      "Дата закінчення",
    ),
    "g_key_tx_filter_direction": MessageLookupByLibrary.simpleMessage(
      "Напрямок",
    ),
    "g_key_tx_no_results": MessageLookupByLibrary.simpleMessage(
      "Жодна трансакція не відповідає вашому фільтру",
    ),
    "g_key_uuid": MessageLookupByLibrary.simpleMessage("UUID"),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage(
      "Знайдіть останню версію",
    ),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("Оновіть негайно"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage("Знайдено нову версію"),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage("Вже остання версія"),
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage(
      "Переглянути вихідну фразу",
    ),
    "g_key_wallet_c12": MessageLookupByLibrary.simpleMessage(
      "Тепер спробуйте ще раз поставити початкову фразу.",
    ),
    "g_key_wallet_c13": MessageLookupByLibrary.simpleMessage(
      "Імпорт облікового запису",
    ),
    "g_key_wallet_c14": MessageLookupByLibrary.simpleMessage("Створити акаунт"),
    "g_key_wallet_c15": MessageLookupByLibrary.simpleMessage("Ви все зробили!"),
    "g_key_wallet_c16": MessageLookupByLibrary.simpleMessage(
      "Тепер ви можете сповна користуватися своїм гаманцем.",
    ),
    "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("Почніть роботу"),
    "g_key_wallet_c18": MessageLookupByLibrary.simpleMessage(
      "Пропустити поки що",
    ),
    "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
      "Ви можете поки що пропустити резервне копіювання вихідної фрази та зробити це знову в налаштуваннях у будь-який час, якщо потрібно.",
    ),
    "g_key_wallet_c21": MessageLookupByLibrary.simpleMessage(
      "Створити безпосередньо",
    ),
    "g_key_wallet_c22": MessageLookupByLibrary.simpleMessage(
      "створено успішно",
    ),
    "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
      "Якщо ви хочете перевірити деталі свого гаманця або експортувати сховище ключів, перейдіть до Бічна панель > Керувати гаманцем ",
    ),
    "g_key_wallet_c24": MessageLookupByLibrary.simpleMessage(
      "Експортувати моє сховище ключів",
    ),
    "g_key_wallet_c25": MessageLookupByLibrary.simpleMessage(
      "Захистіть свій гаманець, створивши його резервну копію",
    ),
    "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
      "Сховище ключів — це сховище сертифікатів безпеки та пов’язаних із ними закритих ключів.",
    ),
    "g_key_wallet_c27": MessageLookupByLibrary.simpleMessage(
      "Крок 1. Перейдіть до «Керування гаманцем».",
    ),
    "g_key_wallet_c28": MessageLookupByLibrary.simpleMessage(
      "Крок 2: Виберіть адресу гаманця.",
    ),
    "g_key_wallet_c29": MessageLookupByLibrary.simpleMessage(
      "Крок 3. Натисніть Export Keystore.",
    ),
    "g_key_wallet_c30": MessageLookupByLibrary.simpleMessage(
      "Перейдіть до «Керування гаманцем».",
    ),
    "g_key_wallet_c31": MessageLookupByLibrary.simpleMessage(
      "Повернутися на головну сторінку",
    ),
    "g_key_wallet_c32": MessageLookupByLibrary.simpleMessage("Додати гаманець"),
    "g_key_wallet_c33": MessageLookupByLibrary.simpleMessage(
      "Створіть гаманець за допомогою початкової фрази.",
    ),
    "g_key_wallet_c34": MessageLookupByLibrary.simpleMessage(
      "Введіть назву гаманця",
    ),
    "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage(
      "Ви не створили резервну копію початкової фрази свого гаманця!",
    ),
    "g_key_wallet_c36": MessageLookupByLibrary.simpleMessage(
      "Резервне копіювання зараз",
    ),
    "g_key_wallet_c37": MessageLookupByLibrary.simpleMessage(
      "Встановити пароль гаманця",
    ),
    "g_key_wallet_c38": MessageLookupByLibrary.simpleMessage(
      "Резервний гаманець",
    ),
    "g_key_wallet_c39": MessageLookupByLibrary.simpleMessage(
      "Будь ласка, запишіть наступну вихідну фразу",
    ),
    "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("старт"),
    "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
      "Пристрої, підключені до Інтернету, можуть відкрити вашу інформацію. Ми рекомендуємо вам записати початкову фразу та надійно зберігати її.",
    ),
    "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
      "Попередження: нікому не розголошуйте свою вихідну фразу. N42Wallet ніколи не запитуватиме у вас цю інформацію. Будьте дуже обережні та безпечно зберігайте його в автономному режимі. Якщо ваша вихідна фраза буде розкрита, ви можете втратити всі свої активи та не зможете їх відновити.",
    ),
    "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
      "Попередження: початкова фраза — це єдиний спосіб відновити активи вашого гаманця.",
    ),
    "g_key_wallet_c43": MessageLookupByLibrary.simpleMessage("Наступний крок"),
    "g_key_wallet_c44": MessageLookupByLibrary.simpleMessage(
      "Клацніть, щоб переглянути вихідну фразу",
    ),
    "g_key_wallet_c45": MessageLookupByLibrary.simpleMessage(
      "Будь ласка, переконайтеся, що поблизу немає інших людей або камер",
    ),
    "g_key_wallet_c46": MessageLookupByLibrary.simpleMessage(
      "Підтвердьте вихідну фразу",
    ),
    "g_key_wallet_c47": MessageLookupByLibrary.simpleMessage(
      "Інформація про гаманець",
    ),
    "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage("Назва гаманця"),
    "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage(
      "Спершу зробіть резервну копію вихідної фрази свого гаманця!",
    ),
    "g_key_wallet_c6": MessageLookupByLibrary.simpleMessage(
      "Перевірте початкову фразу",
    ),
    "g_key_wallet_c7": MessageLookupByLibrary.simpleMessage(
      "Тепер введіть початкову фразу.",
    ),
    "g_key_wallet_c8": MessageLookupByLibrary.simpleMessage("Встановити фразу"),
    "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
      "Будь ласка, переконайтеся, що ви записали свою початкову фразу та безпечно її зберігали. Він знадобиться вам, щоб імпортувати або відновити свій криптовалютний гаманець.",
    ),
    "g_key_wallet_edit": MessageLookupByLibrary.simpleMessage(
      "Редагування гаманця",
    ),
    "g_key_wallet_k25": MessageLookupByLibrary.simpleMessage("час"),
    "g_key_wallet_k33": MessageLookupByLibrary.simpleMessage("Результат"),
    "g_key_wallet_k37": MessageLookupByLibrary.simpleMessage("Хеш транзакції"),
    "g_key_wallet_k47": MessageLookupByLibrary.simpleMessage("додати"),
    "g_key_wallet_k53": MessageLookupByLibrary.simpleMessage("шлях"),
    "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("Блокувати"),
    "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("Значення"),
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("Один раз"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("Прискорити"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Примітка"),
    "g_key_wallet_m1": m38,
    "g_key_wallet_m19": m39,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "Поточний маркер не додано.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Введіть початкову фразу словами, розділеними пробілами",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage("Імпорт гаманця"),
    "g_key_wallet_m3": m40,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "Поточний баланс токенів недостатній.",
    ),
    "g_key_wallet_m5": m41,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("Помилка підпису"),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Керувати Wallet",
    ),
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "Введіть адресу Ethereum (0x...)",
    ),
    "g_key_watch_only_cant_send": MessageLookupByLibrary.simpleMessage(
      "Гаманець лише для перегляду не може надсилати або підписувати транзакції",
    ),
    "g_key_watch_wallet": MessageLookupByLibrary.simpleMessage("Watch Wallet"),
    "g_key_watch_wallet_desc": MessageLookupByLibrary.simpleMessage(
      "Відстежуйте будь-яку адресу EVM без закритого ключа",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Зарезервовано"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Базовий резерв"),
    "g_key_xml_11": m42,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("Додатковий резерв"),
    "g_key_xml_22": m43,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Підрахунок об\'єктів власності",
    ),
    "g_key_xml_33": m44,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "Як розрахувати загальну зарезервовану суму",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "Загальний резерв = базовий резерв + (кількість об’єктів власності × додатковий резерв)",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID і Face ID"),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("Графічний пароль"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage(
      "Встановити графічний пароль",
    ),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "Намалюйте графічний ключ",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "Підтвердіть графічний ключ",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage(
      "Намалюйте поточний графічний ключ",
    ),
    "g_lock_key21": m45,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Скинути графічний пароль",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Забагато невдалих спроб, повторіть",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Додати пароль Wallet?",
    ),
    "g_lock_key25": m46,
    "g_lock_key26": MessageLookupByLibrary.simpleMessage(
      "Transfer Verification",
    ),
    "g_lock_key27": MessageLookupByLibrary.simpleMessage(
      "Require biometric authentication (Face ID / fingerprint) to confirm each wallet transfer.",
    ),
    "g_lock_key28": MessageLookupByLibrary.simpleMessage(
      "Графічний пароль не встановлено",
    ),
    "g_lock_key29": MessageLookupByLibrary.simpleMessage(
      "Для підтвердження переказу потрібна графічна автентифікація.",
    ),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Вдався"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Не вдалося"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "Біометричне розпізнавання не ввімкнено",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "Додати біометричне підтвердження?",
    ),
    "g_market_30d_change": MessageLookupByLibrary.simpleMessage("Зміна 30D"),
    "g_market_7d_change": MessageLookupByLibrary.simpleMessage("Зміна 7D"),
    "g_market_ath": MessageLookupByLibrary.simpleMessage("ATH"),
    "g_market_atl": MessageLookupByLibrary.simpleMessage("ATL"),
    "g_market_depth": MessageLookupByLibrary.simpleMessage("Глибина ринку"),
    "g_market_empty_watchlist": MessageLookupByLibrary.simpleMessage(
      "Ще немає списку спостереження",
    ),
    "g_market_fdv": MessageLookupByLibrary.simpleMessage("FDV"),
    "g_market_high_24h": MessageLookupByLibrary.simpleMessage(
      "Висока 24 години",
    ),
    "g_market_liquidity_score": MessageLookupByLibrary.simpleMessage(
      "Показник ліквідності",
    ),
    "g_market_low_24h": MessageLookupByLibrary.simpleMessage(
      "Низька 24 години",
    ),
    "g_market_news": MessageLookupByLibrary.simpleMessage("Новини"),
    "g_market_no_chart": MessageLookupByLibrary.simpleMessage(
      "Немає даних діаграми",
    ),
    "g_market_no_results": MessageLookupByLibrary.simpleMessage(
      "Результатів немає",
    ),
    "g_market_rank": MessageLookupByLibrary.simpleMessage("ранг"),
    "g_market_search": MessageLookupByLibrary.simpleMessage("Пошук"),
    "g_market_search_hint": MessageLookupByLibrary.simpleMessage(
      "Пошук монет...",
    ),
    "g_market_trending": MessageLookupByLibrary.simpleMessage("В тренді"),
    "g_market_watchlist": MessageLookupByLibrary.simpleMessage(
      "Список спостереження",
    ),
    "g_mining_inactivity_warning": MessageLookupByLibrary.simpleMessage(
      "Показник бездіяльності валідатора високий. Перевірте статус свого вузла, щоб уникнути штрафів.",
    ),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("Розблокувати N?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage("Хмарна перевірка"),
    "g_mining_key33": MessageLookupByLibrary.simpleMessage(
      "Налаштування перевірки",
    ),
    "g_mining_key34": MessageLookupByLibrary.simpleMessage(
      "Фонова музика перевірки",
    ),
    "g_mining_key35": MessageLookupByLibrary.simpleMessage("За замовчуванням"),
    "g_mining_key36": MessageLookupByLibrary.simpleMessage("Вимкнути звук"),
    "g_mining_key37": MessageLookupByLibrary.simpleMessage(
      "Якщо фонову перевірку ввімкнено, музика відтворюватиметься у фоновому режимі. Якщо музика припиниться, перевірка також припиниться.",
    ),
    "g_mining_key38": MessageLookupByLibrary.simpleMessage("Ваш рівень"),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage(
      "Для налаштування потрібна невелика кількість газу.",
    ),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "Ви успішно приєдналися до вузла групи на N42Wallet. Поділіться посиланням, щоб запросити друзів, активувати Node і почати верифікацію!",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage(
      "Поділіться з друзями",
    ),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("Продовжити"),
    "g_mining_key63": m47,
    "g_mining_key73": m48,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Я щойно налаштував вузол на @N42Wallet і почав перевірку на мобільних пристроях! Приходь і приєднуйся до мене. Децентралізоване майбутнє – це мобільно!",
    ),
    "g_mining_key76": m49,
    "g_mining_key82": MessageLookupByLibrary.simpleMessage("мінеральні"),
    "g_mining_key83": MessageLookupByLibrary.simpleMessage("Вузол"),
    "g_mining_key84": MessageLookupByLibrary.simpleMessage("Мережа"),
    "g_mining_key85": MessageLookupByLibrary.simpleMessage(
      "Перемикайтеся між testnet і mainnet для хмарного майнінгу.",
    ),
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Викуп доступний після 768 с.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Запити до цього часу не оброблятимуться.",
    ),
    "g_mining_key_1": MessageLookupByLibrary.simpleMessage("додому"),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage(
      "Сьогоднішня винагорода",
    ),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "Розглядайте наведені нижче дані як важливий ключ. Рекомендуємо негайно скопіювати та створити резервну копію в надійному місці.",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("Копіювати дані"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("Неактивний"),
    "g_mining_key_104": MessageLookupByLibrary.simpleMessage("Імпорт успішний"),
    "g_mining_key_105": MessageLookupByLibrary.simpleMessage(
      "Зашифровані дані не можуть бути порожніми!",
    ),
    "g_mining_key_106": MessageLookupByLibrary.simpleMessage(
      "Пароль не може бути пустим!",
    ),
    "g_mining_key_107": MessageLookupByLibrary.simpleMessage(
      "Не вдалося розшифрувати. Перевірте, будь ласка, чи правильний пароль!",
    ),
    "g_mining_key_108": MessageLookupByLibrary.simpleMessage(
      "Непідтримуваний формат зашифрованих даних!",
    ),
    "g_mining_key_109": m50,
    "g_mining_key_11": MessageLookupByLibrary.simpleMessage(
      "Вчорашні нагороди",
    ),
    "g_mining_key_110": MessageLookupByLibrary.simpleMessage(
      "Зашифровані дані",
    ),
    "g_mining_key_111": MessageLookupByLibrary.simpleMessage("Імпорт файлів"),
    "g_mining_key_112": MessageLookupByLibrary.simpleMessage(
      "Будь ласка, введіть зашифровані дані.",
    ),
    "g_mining_key_113": MessageLookupByLibrary.simpleMessage("Імпорт..."),
    "g_mining_key_114": MessageLookupByLibrary.simpleMessage("Підтвердження"),
    "g_mining_key_115": MessageLookupByLibrary.simpleMessage(
      "Погашення займає деякий час, зачекайте трохи!",
    ),
    "g_mining_key_116": m51,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "Винагорода накопичується щодня та надсилається на ваш гаманець N лише тоді, коли вона досягає ~0,5 N.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage(
      "Загальна кількість винагород",
    ),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage(
      "Видобуте значення",
    ),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
      "Деталізація завдання",
    ),
    "g_mining_key_19": MessageLookupByLibrary.simpleMessage("Резюме"),
    "g_mining_key_2": MessageLookupByLibrary.simpleMessage("Діяльність"),
    "g_mining_key_20": MessageLookupByLibrary.simpleMessage(
      "Загальна вартість видобутого",
    ),
    "g_mining_key_21": MessageLookupByLibrary.simpleMessage("Перевірка З"),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage(
      "Підрахунок прибутку",
    ),
    "g_mining_key_24": MessageLookupByLibrary.simpleMessage(
      "Перевірене значення",
    ),
    "g_mining_key_31": MessageLookupByLibrary.simpleMessage("Виберіть Плани"),
    "g_mining_key_32": MessageLookupByLibrary.simpleMessage(
      "Період розблокування: можна розблокувати в будь-який час",
    ),
    "g_mining_key_33": MessageLookupByLibrary.simpleMessage(
      "Максимальна винагорода на рік",
    ),
    "g_mining_key_34": MessageLookupByLibrary.simpleMessage(
      "Розподіл винагороди",
    ),
    "g_mining_key_35": MessageLookupByLibrary.simpleMessage("Денний ліміт"),
    "g_mining_key_36": MessageLookupByLibrary.simpleMessage("швидкість"),
    "g_mining_key_37": MessageLookupByLibrary.simpleMessage("Плани перевірки"),
    "g_mining_key_38": MessageLookupByLibrary.simpleMessage(
      "Виберіть спосіб оплати",
    ),
    "g_mining_key_39": MessageLookupByLibrary.simpleMessage("Способи оплати"),
    "g_mining_key_40": MessageLookupByLibrary.simpleMessage(
      "Оплатіть за допомогою N",
    ),
    "g_mining_key_42": MessageLookupByLibrary.simpleMessage("Баланс гаманця"),
    "g_mining_key_43": MessageLookupByLibrary.simpleMessage(
      "У вас недостатньо N для цієї транзакції",
    ),
    "g_mining_key_45": MessageLookupByLibrary.simpleMessage(
      "Ви впевнені, що бажаєте пропустити?",
    ),
    "g_mining_key_46": MessageLookupByLibrary.simpleMessage(
      "Ви не отримаєте жодних винагород за підтвердження, доки не виберете 1 із планів.",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Вимкнено"),
    "g_mining_key_48": MessageLookupByLibrary.simpleMessage("Винагорода"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage(
      "Переглянути більше",
    ),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage("Статус перевірки"),
    "g_mining_key_50": MessageLookupByLibrary.simpleMessage("Щоб розблокувати"),
    "g_mining_key_52": MessageLookupByLibrary.simpleMessage("Пропустити"),
    "g_mining_key_58": MessageLookupByLibrary.simpleMessage(
      "За останні 7 днів",
    ),
    "g_mining_key_59": MessageLookupByLibrary.simpleMessage(
      "Накопичені винагороди",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Заблокуйте N, щоб почати перевірку нагород.",
    ),
    "g_mining_key_60": MessageLookupByLibrary.simpleMessage(
      "Нагороди отримано",
    ),
    "g_mining_key_61": MessageLookupByLibrary.simpleMessage("Просунутий"),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Вхід"),
    "g_mining_key_63": MessageLookupByLibrary.simpleMessage("Pro"),
    "g_mining_key_64": MessageLookupByLibrary.simpleMessage("ПОВНИЙ ВУЗОЛ"),
    "g_mining_key_65": MessageLookupByLibrary.simpleMessage("ХВ/ДЕНЬ"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("Розширений вузол"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Вузол входу"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Pro Node"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 блоків/день ~ 70 хв",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage(
      "Дата розблокування",
    ),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 блоків/день ~ 15 хв",
    ),
    "g_mining_key_71": m52,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "128 секунд на перевірку",
    ),
    "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
      "Тестовий ланцюжок оновлюється, тому тимчасово неможливо перевірити блоки.",
    ),
    "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
      "Невиконання завдань протягом чотирьох днів поспіль призведе до відсутності прибутку та ризику штрафу.",
    ),
    "g_mining_key_76": MessageLookupByLibrary.simpleMessage("Оцінка ризику"),
    "g_mining_key_77": MessageLookupByLibrary.simpleMessage("Викупити"),
    "g_mining_key_78": MessageLookupByLibrary.simpleMessage(
      "Будь ласка, спочатку збережіть пару відкритих і закритих ключів верифікатора.",
    ),
    "g_mining_key_79": MessageLookupByLibrary.simpleMessage("Експорт"),
    "g_mining_key_8": MessageLookupByLibrary.simpleMessage(
      "Сьогоднішній час перевірки",
    ),
    "g_mining_key_80": MessageLookupByLibrary.simpleMessage(
      "Недостатньо коштів для переказу.",
    ),
    "g_mining_key_81": MessageLookupByLibrary.simpleMessage(
      "Список валідатора",
    ),
    "g_mining_key_82": MessageLookupByLibrary.simpleMessage(
      "Валідатор імпорту",
    ),
    "g_mining_key_83": MessageLookupByLibrary.simpleMessage(
      "Валідатор уже існує",
    ),
    "g_mining_key_84": MessageLookupByLibrary.simpleMessage("Низький ризик"),
    "g_mining_key_85": MessageLookupByLibrary.simpleMessage("Помірний ризик"),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage(
      "7-денні винагороди",
    ),
    "g_mining_key_87": MessageLookupByLibrary.simpleMessage("Високий ризик"),
    "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
      "Договір завантажується, і наразі його неможливо перевірити. Зачекайте, будь ласка!",
    ),
    "g_mining_key_89": MessageLookupByLibrary.simpleMessage("Поради з безпеки"),
    "g_mining_key_9": MessageLookupByLibrary.simpleMessage("Перевірка даних"),
    "g_mining_key_90": MessageLookupByLibrary.simpleMessage(
      "Зберігайте свій особистий ключ або мнемонічну фразу в безпеці.",
    ),
    "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
      "Ваш приватний ключ або мнемонічна фраза є єдиними обліковими даними для доступу до активів вашого гаманця.",
    ),
    "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
      "Будь ласка, зберігайте його в безпечному місці (папір, менеджер паролів тощо).",
    ),
    "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
      "Не робіть знімки екрана, не завантажуйте їх в Інтернет і не діліться ними з ким-небудь.",
    ),
    "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
      "Після втрати або зламу активи вашого гаманця не можна відновити.",
    ),
    "g_mining_key_95": MessageLookupByLibrary.simpleMessage(
      "Підтвердити та зберегти",
    ),
    "g_mining_key_96": MessageLookupByLibrary.simpleMessage(
      "Встановіть пароль і зашифруйте",
    ),
    "g_mining_key_97": MessageLookupByLibrary.simpleMessage(
      "Будь ласка, введіть пароль для шифрування",
    ),
    "g_mining_key_98": m53,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Введіть свій пароль повторно, щоб переконатися, що він правильний",
    ),
    "g_mining_node_key1": MessageLookupByLibrary.simpleMessage(
      "Повна деталь вузла",
    ),
    "g_mining_node_key2": MessageLookupByLibrary.simpleMessage(
      "Ідентифікатор вузла",
    ),
    "g_mining_node_key3": MessageLookupByLibrary.simpleMessage("WS Connected"),
    "g_mining_node_key4": MessageLookupByLibrary.simpleMessage("WS Відключено"),
    "g_mining_node_key5": MessageLookupByLibrary.simpleMessage(
      "WS Повторне підключення",
    ),
    "g_mining_node_key6": MessageLookupByLibrary.simpleMessage("Термін дії"),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage(
      "Період розблокування:",
    ),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "Можна розблокувати в будь-який час",
    ),
    "g_news_empty": MessageLookupByLibrary.simpleMessage("Немає новин"),
    "g_phishing_go_back": MessageLookupByLibrary.simpleMessage(
      "Повернутися назад (безпечно)",
    ),
    "g_phishing_proceed_anyway": MessageLookupByLibrary.simpleMessage(
      "Все одно продовжити",
    ),
    "g_phishing_warning_body": MessageLookupByLibrary.simpleMessage(
      "Цей веб-сайт визначено як потенційно шкідливий. Можливо, він намагається викрасти ваші криптографічні активи або особисті ключі.",
    ),
    "g_phishing_warning_title": MessageLookupByLibrary.simpleMessage(
      "Попередження безпеки",
    ),
    "g_phishing_warning_url_label": MessageLookupByLibrary.simpleMessage(
      "Підозрілий URL:",
    ),
    "g_pnl_add_trade": MessageLookupByLibrary.simpleMessage("Додати торгівлю"),
    "g_pnl_avg_cost": MessageLookupByLibrary.simpleMessage("Середня вартість"),
    "g_pnl_buy_price_usd": MessageLookupByLibrary.simpleMessage(
      "Ціна покупки (USD)",
    ),
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage("Основа витрат"),
    "g_pnl_quantity": MessageLookupByLibrary.simpleMessage("Кількість"),
    "g_pnl_save": MessageLookupByLibrary.simpleMessage("зберегти"),
    "g_pnl_unrealized": MessageLookupByLibrary.simpleMessage(
      "Нереалізовані прибутки та збитки",
    ),
    "g_portfolio_24h": MessageLookupByLibrary.simpleMessage("Зміна 24 години"),
    "g_portfolio_all_holdings": MessageLookupByLibrary.simpleMessage(
      "Усі холдинги",
    ),
    "g_portfolio_allocation": MessageLookupByLibrary.simpleMessage(
      "Розподіл активів",
    ),
    "g_portfolio_gainers": MessageLookupByLibrary.simpleMessage(
      "Найпопулярніші",
    ),
    "g_portfolio_losers": MessageLookupByLibrary.simpleMessage("Кращі невдахи"),
    "g_portfolio_movers": MessageLookupByLibrary.simpleMessage(
      "Перевізники 24 години",
    ),
    "g_portfolio_no_assets": MessageLookupByLibrary.simpleMessage(
      "Активи не знайдено",
    ),
    "g_portfolio_others": MessageLookupByLibrary.simpleMessage("інші"),
    "g_portfolio_pie_total": MessageLookupByLibrary.simpleMessage("Всього"),
    "g_portfolio_title": MessageLookupByLibrary.simpleMessage("Портфоліо"),
    "g_portfolio_total": MessageLookupByLibrary.simpleMessage(
      "Загальна вартість",
    ),
    "g_pred_add_outcome": MessageLookupByLibrary.simpleMessage(
      "Додати результат",
    ),
    "g_pred_create_title": MessageLookupByLibrary.simpleMessage(
      "Почати прогноз",
    ),
    "g_pred_creating": MessageLookupByLibrary.simpleMessage("Створення…"),
    "g_pred_deadline": MessageLookupByLibrary.simpleMessage("Дедлайн"),
    "g_pred_err_outcomes": MessageLookupByLibrary.simpleMessage(
      "Щонайменше два дійсні результати",
    ),
    "g_pred_err_question": MessageLookupByLibrary.simpleMessage(
      "Введіть запитання",
    ),
    "g_pred_minutes": m54,
    "g_pred_no": MessageLookupByLibrary.simpleMessage("Ні"),
    "g_pred_outcome_n": m55,
    "g_pred_outcomes": MessageLookupByLibrary.simpleMessage("Результати"),
    "g_pred_publish": MessageLookupByLibrary.simpleMessage("Опублікувати"),
    "g_pred_q_hint": MessageLookupByLibrary.simpleMessage(
      "Питання прогнозу, напр.: Хто виграє цей раунд?",
    ),
    "g_pred_unlimited": MessageLookupByLibrary.simpleMessage(
      "Без обмежень (закрити вручну)",
    ),
    "g_pred_yes": MessageLookupByLibrary.simpleMessage("Так"),
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage(
      "Завантажено",
    ),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage(
      "Код запрошення",
    ),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("Запрошений"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage(
      "Майнінгові вузли",
    ),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("Винагорода (N)"),
    "g_setting_mining_v1_label": MessageLookupByLibrary.simpleMessage(
      "Класичний майнінг (V1)",
    ),
    "g_setting_mining_v2_label": MessageLookupByLibrary.simpleMessage(
      "Майнінг (V2)",
    ),
    "g_setting_mining_version": MessageLookupByLibrary.simpleMessage(
      "Інтерфейс майнінгу",
    ),
    "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("Поділіться"),
    "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("Направлення"),
    "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage(
      "Запропонуйте друзям і отримайте N токенів!",
    ),
    "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage("Ви встаєте до "),
    "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage(
      " N, коли ваш реферал починає перевірку!",
    ),
    "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage(
      "Зверніться через",
    ),
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("Посилання"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("код"),
    "g_swap_key_14": m56,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage(
      "Отримати помилку ціни монети.",
    ),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage(
      "Продовжуючи, ви погоджуєтеся з наступним ",
    ),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage("Правила та умови."),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("Закінчити"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
      "Ваш обмін буде розповсюджено незабаром. Будь ласка, будьте терплячі.",
    ),
    "g_swap_key_20": m57,
    "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
      "Витрати на запуск вузла: Групова перевірка 1-49 N Базовий вузол: 50 N Преміум-вузол: 100 N Професійний вузол: 500 N.",
    ),
    "g_swap_key_22": MessageLookupByLibrary.simpleMessage("закінчується"),
    "g_swap_key_23": MessageLookupByLibrary.simpleMessage("Неоплачений"),
    "g_swap_key_24": MessageLookupByLibrary.simpleMessage(
      "Підтвердження платежу",
    ),
    "g_swap_key_25": MessageLookupByLibrary.simpleMessage("Для розповсюдження"),
    "g_swap_key_28": MessageLookupByLibrary.simpleMessage("Підсумок обміну"),
    "g_swap_key_29": MessageLookupByLibrary.simpleMessage("Новий баланс"),
    "g_swap_key_3": MessageLookupByLibrary.simpleMessage("Ви платите"),
    "g_swap_key_30": MessageLookupByLibrary.simpleMessage("Дата"),
    "g_swap_key_31": m58,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Свопи можна переглянути у відповідних дослідниках ланцюгів (Etherscan, BscScan, TRONSCAN і наш власний).",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Обмін на N"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Обмін"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Ви отримуєте"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage(
      "Попередній перегляд обміну",
    ),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Спробуйте знову"),
    "g_theme_accent_color": MessageLookupByLibrary.simpleMessage(
      "Колір акценту",
    ),
    "g_theme_accent_reset": MessageLookupByLibrary.simpleMessage(
      "Скинути до замовчування",
    ),
    "g_token_m_key_1": m59,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "Будь-хто може створити маркер, у тому числі створити підроблені версії існуючих маркерів. Завжди досліджуйте токен перед його імпортом.",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("Жетони"),
    "g_token_m_key_12": MessageLookupByLibrary.simpleMessage("Маркер пошуку"),
    "g_token_m_key_13": MessageLookupByLibrary.simpleMessage("Назва ланцюга"),
    "g_token_m_key_14": MessageLookupByLibrary.simpleMessage("Символ ланцюга"),
    "g_token_m_key_15": MessageLookupByLibrary.simpleMessage("ID ланцюга"),
    "g_token_m_key_16": MessageLookupByLibrary.simpleMessage("Десятковий"),
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("RPC"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Додайте спеціальний ланцюжок",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 одиниць"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("Додати жетони"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage(
      "Помилка формату!",
    ),
    "g_token_m_key_22": m60,
    "g_token_m_key_23": m61,
    "g_token_m_key_24": m62,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("Імпорт жетонів"),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("Всі мережі"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage(
      "Спеціальний маркер",
    ),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage("Адреса маркера"),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("Символ маркера"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage("Токен десятковий"),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("Імпорт"),
    "g_tx_risk_caution": MessageLookupByLibrary.simpleMessage("Обережно"),
    "g_tx_risk_danger": MessageLookupByLibrary.simpleMessage("Високий ризик"),
    "g_tx_risk_safe": MessageLookupByLibrary.simpleMessage("Безпечний"),
    "g_version_later": MessageLookupByLibrary.simpleMessage("Пізніше"),
    "g_wc_connection_lost": MessageLookupByLibrary.simpleMessage(
      "З\'єднання втрачено. Підключіться повторно.",
    ),
    "g_wc_dapp_disconnected": MessageLookupByLibrary.simpleMessage(
      "DApp відключено",
    ),
    "g_wc_disconnect_all": MessageLookupByLibrary.simpleMessage(
      "Відключити все",
    ),
    "g_wc_disconnect_all_confirm": MessageLookupByLibrary.simpleMessage(
      "Відключитися від усіх DApps?",
    ),
    "g_wc_disconnect_confirm": MessageLookupByLibrary.simpleMessage(
      "Відключитися від цього DApp?",
    ),
    "g_wc_no_sessions": MessageLookupByLibrary.simpleMessage(
      "Немає активних з\'єднань",
    ),
    "g_wc_no_sessions_desc": MessageLookupByLibrary.simpleMessage(
      "Відскануйте QR-код, щоб підключитися до програми DApp",
    ),
    "g_wc_proposal_timeout": MessageLookupByLibrary.simpleMessage(
      "Запит на підключення минув",
    ),
    "g_wc_session_expired": MessageLookupByLibrary.simpleMessage(
      "Сеанс закінчився",
    ),
    "g_wc_sessions": MessageLookupByLibrary.simpleMessage("Підключені DApps"),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Посилання",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage(
      "Важливе повідомлення",
    ),
    "login_email": MessageLookupByLibrary.simpleMessage("Електронна пошта"),
    "login_password": MessageLookupByLibrary.simpleMessage("Пароль"),
    "next": MessageLookupByLibrary.simpleMessage("Далі"),
    "nicknameMessage": m63,
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Редагувати профіль",
    ),
    "photograph": MessageLookupByLibrary.simpleMessage("Фотографія"),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Будь ласка, введіть адресу",
    ),
    "push_permission_btn_dismiss": MessageLookupByLibrary.simpleMessage(
      "Більше не нагадувати",
    ),
    "push_permission_btn_later": MessageLookupByLibrary.simpleMessage(
      "Пізніше",
    ),
    "push_permission_btn_settings": MessageLookupByLibrary.simpleMessage(
      "Перейти до налаштувань",
    ),
    "push_permission_dialog_content": MessageLookupByLibrary.simpleMessage(
      "Push-сповіщення вимкнені. Ви можете пропустити повідомлення чату та сповіщення про перекази.\n\nБудь ласка, увімкніть сповіщення для цього додатку в системних налаштуваннях.",
    ),
    "push_permission_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Сповіщення вимкнені",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage(
      "Повторно введіть пароль",
    ),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "Виберіть пароль (8~18 символів)",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage(
      "Підтвердьте пароль",
    ),
    "s_key_10": MessageLookupByLibrary.simpleMessage("Про додаток"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Безпека"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("Транзакція"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Мова"),
    "search": MessageLookupByLibrary.simpleMessage("Пошук"),
    "verification": MessageLookupByLibrary.simpleMessage("перевірка"),
    "w_item_1": MessageLookupByLibrary.simpleMessage(
      "Якщо я втрачу свою секретну фразу, мої кошти будуть втрачені назавжди.",
    ),
    "w_item_2": MessageLookupByLibrary.simpleMessage(
      "Якщо я комусь розкрию або поділюся своєю початковою фразою, мої кошти можуть вкрасти.",
    ),
    "w_item_3": MessageLookupByLibrary.simpleMessage(
      "Я відповідаю за безпеку своєї вихідної фрази.",
    ),
    "w_key_12": MessageLookupByLibrary.simpleMessage(
      "Неправильна фраза про насіння.",
    ),
    "w_key_8": MessageLookupByLibrary.simpleMessage(
      "Введіть початкову фразу для гаманця, який ви хочете імпортувати.",
    ),
  };
}
