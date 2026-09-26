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

  static String m3(s) => "Отправить повторно через ${s}s";

  static String m4(message) => "Ошибка покупки: ${message}";

  static String m5(productId) => "Покупка выполнена: ${productId}";

  static String m6(productId) => "Восстановлено: ${productId}";

  static String m7(value) => "Сумма больше ${value}.";

  static String m8(value) =>
      "Кошелёк уже существует, название кошелька \"${value}\"";

  static String m9(value) => "Введите сумму больше ${value}.";

  static String m10(value) => "Дубликат адреса в строке ${value}";

  static String m11(value) =>
      "Недостаточный баланс: общая сумма превысит доступный ${value}";

  static String m12(value) => "Неверный адрес в строке ${value}";

  static String m13(value) => "Неверная сумма в строке ${value}";

  static String m14(value) => "Максимум ${value} получателей";

  static String m15(token) => "Подтвердите ${token}, чтобы продолжить.";

  static String m16(impact) =>
      "Влияние высокой цены (${impact})! Действуйте осторожно.";

  static String m17(secs) => "Срок действия котировки истекает через ${secs}s";

  static String m18(value) => "Зарабатывайте до ${value}% APY";

  static String m19(value) =>
      "Автоматическое обновление каждые ${value} секунд.";

  static String m20(address) => "Счёт ${address} добавлен";

  static String m21(address, network) =>
      "Хотите отслеживать этот счёт аппаратного кошелька?\n\nАдрес: ${address}\nСеть: ${network}";

  static String m22(app) => "Текущее приложение: ${app}.";

  static String m23(days) => "${days} дней назад";

  static String m24(value) => "Не удалось импортировать счёт: ${value}";

  static String m25(date) => "Последнее подключение: ${date}";

  static String m26(app) =>
      "Убедитесь, что приложение ${app} открыто на Ledger";

  static String m27(name) =>
      "Вы уверены, что хотите удалить «${name}» из сохраненных устройств?";

  static String m28(value) => "Получите ${value} очков";

  static String m29(amount, symbol, network) =>
      "Запросите ${amount} ${symbol} в сети ${network}";

  static String m30(value) =>
      "Удалить пользовательскую сеть ${value}? Балансы в этой сети больше не будут отображаться. Ваши активы в цепочке не затронуты.";

  static String m31(value) => "Оценка. газ: ~${value} единиц";

  static String m32(reason) => "Причина: ${reason}";

  static String m33(value) => "${value}d разрыв связи";

  static String m34(value) => "${value} осталось дней";

  static String m35(value) =>
      "Анстейкинг занимает ${value} дней. В течение этого периода ваши токены будут заблокированы.";

  static String m36(value) => "У вас недостаточно \"${value}\"";

  static String m37(value) => "Не удалось получить аккаунт \"${value}\"";

  static String m38(value) => "Минимум ${value} XRP для первого перевода";

  static String m39(count) => "Добавить (${count})";

  static String m40(count) =>
      "${Intl.plural(count, one: 'Обнаружен 1 новый токен', other: '${count} обнаружены новые токены')} — нажмите, чтобы просмотреть";

  static String m41(value) => "Сеть ${value} не добавлена.";

  static String m42(value) =>
      "У ${value} есть незавершённые транзакции, попробуйте позже.";

  static String m43(value) => "Адрес для ${value} не найден.";

  static String m44(value) => "Недостаточный баланс ${value}.";

  static String m45(value, value1) =>
      "Каждый аккаунт XRP должен резервировать ${value} XRP (${value1} drops) в качестве базового минимума, который нельзя потратить.";

  static String m46(value, value1) =>
      "За каждый объект, принадлежащий аккаунту, к резерву добавляется ${value} XRP (${value1} drops).";

  static String m47(value, value1) =>
      "Этот аккаунт владеет ${value} объектами, что означает дополнительный резерв в ${value1} XRP.";

  static String m48(message) => "Не удалось войти в комнату\n${message}";

  static String m49(value) => "Неверный ключ, осталось попыток: ${value}";

  static String m50(value) => "Неверный ключ, осталась попытка: ${value}";

  static String m51(value) =>
      "Вы успешно настроили ${value} и начнёте верификацию с N42Wallet!";

  static String m52(value) =>
      "Присоединяйтесь к моей группе ${value} в @N42Wallet, чтобы стать ранним майнером Layer 1 сети и получать крипто на свой телефон!";

  static String m53(value, value1) =>
      "Вы уверены, что хотите заблокировать ${value} N до ${value1} для запуска узла?";

  static String m54(value) => "Импорт не удался:${value}";

  static String m55(value) =>
      "Для получения вознаграждений требуется баланс стейкинга не менее ${value}.";

  static String m56(value, value1) =>
      "${value} N каждые ${value1} добытых блоков";

  static String m57(value) => "Должно быть ${value} символов";

  static String m58(symbol) => "Сумма (${symbol})";

  static String m59(amount, symbol) => "Баланс: ${amount} ${symbol}";

  static String m60(label) =>
      "Объявить «${label}» победителем и рассчитать? Это необратимо.";

  static String m61(n) => "${n} мин";

  static String m62(n) => "Исход ${n}";

  static String m63(label, pct) => "${label} побеждает (${pct}%)";

  static String m64(shares, avg, after) =>
      "Ожид. ${shares} долей · средн. ${avg}% · после ${after}%";

  static String m65(reason) => "Ошибка погашения: ${reason}";

  static String m66(label) => "Результат: ${label}";

  static String m67(n) => "Продать ${n}";

  static String m68(value) => "Недостаточный баланс ${value}.";

  static String m69(value) => "${value} поступает...";

  static String m70(value) =>
      "${value} обменянные в приложении будут в ближайшее время распределены на ваш кошелёк и не могут быть проданы через этот процесс. Их можно использовать для запуска ноды.";

  static String m71(value) => "Максимум ${value} символов";

  static String m72(value) => "Сеть ${value} уже поддерживается приложением!";

  static String m73(value) =>
      "Сеть ${value} уже поддерживается приложением, хотите её добавить?";

  static String m74(value) =>
      "Тестовое подключение к адресу ${value} не удалось!";

  static String m75(value) =>
      "RPC сообщает идентификатор цепочки ${value}, который не совпадает со введённым вами значением.";

  static String m76(asset, contract, address) =>
      "Актив ${asset} (${contract}) не был добавлен в кошелёк ${address}.";

  static String m77(imported, skipped) =>
      "Кошельки импортированы: ${imported}. Пропущено: ${skipped}.";

  static String m78(value) => "Баланс: ${value}";

  static String m79(value) => "Базовая плата: ${value} Gwei";

  static String m80(value) =>
      "Буфер обмена автоматически очистится через ${value} сек";

  static String m81(value) => "Строка ${value}: отсутствуют поля";

  static String m82(value) => "${value}д";

  static String m83(value) => "Подключено к ${value}";

  static String m84(value) => "Газ: ${value}";

  static String m85(value) => "${value}ч";

  static String m86(value) => "Импорт допустимых получателей (${value})";

  static String m87(quote, base) => "Лимитная цена (${quote} за ${base})";

  static String m88(value) => "Лимит ${value}";

  static String m89(value) => "Рынки (${value})";

  static String m90(value) => "Минимальный баланс: ${value}";

  static String m91(value) => "Заказы (${value})";

  static String m92(value) => "Позиции (${value})";

  static String m93(value) => "Получатели: ${value}";

  static String m94(value) => "Токен найден: ${value}";

  static String m95(value) => "Токен: ${value}";

  static String m96(value) => "Транзакция: ${value}";

  static String m97(valid, issues) =>
      "Допустимо: ${valid}. Проблемы: ${issues}.";

  static String m98(value) => "… и ещё ${value} проблем";

  static String m99(volume, interest) => "Объём: ${volume} · OI: ${interest}";

  static String m100(value) => "Кошелёк ${value}";

  static String m101(value) => "Обновлено ${value} часов назад";

  static String m102(value) => "Обновлено ${value} минут назад";

  static String m103(value) => "0~${value} символов";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
    "Verification": MessageLookupByLibrary.simpleMessage("Верификация"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Информация об адресе",
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
    "file": MessageLookupByLibrary.simpleMessage("Файл"),
    "g_aggregate_cached_balance": MessageLookupByLibrary.simpleMessage(
      "Сохранённый баланс · не удалось обновить",
    ),
    "g_aggregate_known_balance": MessageLookupByLibrary.simpleMessage(
      "Известный баланс",
    ),
    "g_aggregate_mainnet_note": MessageLookupByLibrary.simpleMessage(
      "Только балансы основной сети. Пропущенные или неудачные запросы к сети не учитываются как ноль.",
    ),
    "g_aggregate_network_balances": MessageLookupByLibrary.simpleMessage(
      "Балансы по сети",
    ),
    "g_aggregate_no_mainnet": MessageLookupByLibrary.simpleMessage(
      "Нет активного основного кошелька сети для этой сети",
    ),
    "g_aggregate_not_loaded": MessageLookupByLibrary.simpleMessage(
      "Баланс не загружен",
    ),
    "g_aggregate_open_network": MessageLookupByLibrary.simpleMessage(
      "Открыть сеть",
    ),
    "g_aggregate_unavailable": MessageLookupByLibrary.simpleMessage(
      "Этот актив больше недоступен в выбранном кошельке. Вернитесь в кошелёк, чтобы выбрать актив.",
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
    "g_audit_aa_history_external": MessageLookupByLibrary.simpleMessage(
      "Открыть блокчейн-эксплорер для просмотра активности этого смарт-кошелька в блокчейне.",
    ),
    "g_audit_about_desc": MessageLookupByLibrary.simpleMessage(
      "Версия, веб-сайт и поддержка",
    ),
    "g_audit_activity_error": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить историю транзакций.",
    ),
    "g_audit_activity_local": MessageLookupByLibrary.simpleMessage(
      "Локальная история транзакций во всех ваших кошельках. Откройте актив, чтобы синхронизировать его последнюю активность.",
    ),
    "g_audit_all": MessageLookupByLibrary.simpleMessage("Все"),
    "g_audit_approval_spender": MessageLookupByLibrary.simpleMessage(
      "Разрешение на расходование",
    ),
    "g_audit_approval_token": MessageLookupByLibrary.simpleMessage(
      "Контракт токена",
    ),
    "g_audit_batch": MessageLookupByLibrary.simpleMessage("Пакетная отправка"),
    "g_audit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Отправка нескольким получателям или импорт CSV-файла",
    ),
    "g_audit_biometrics": MessageLookupByLibrary.simpleMessage(
      "Биометрическая аутентификация",
    ),
    "g_audit_biometrics_desc": MessageLookupByLibrary.simpleMessage(
      "Настройки Face ID / отпечатка пальца",
    ),
    "g_audit_connections_desc": MessageLookupByLibrary.simpleMessage(
      "Управление сеансами; отключение не отменяет разрешения на токены",
    ),
    "g_audit_currency": MessageLookupByLibrary.simpleMessage(
      "Валюта отображения",
    ),
    "g_audit_currency_usd": MessageLookupByLibrary.simpleMessage(
      "Стоимость портфеля отображается в долларах США.",
    ),
    "g_audit_defi_error": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить позиции в DeFi. Нажмите, чтобы повторить.",
    ),
    "g_audit_defi_loading": MessageLookupByLibrary.simpleMessage(
      "Загрузка позиций в DeFi…",
    ),
    "g_audit_defi_positions": MessageLookupByLibrary.simpleMessage(
      "Позиции в DeFi",
    ),
    "g_audit_display_language": MessageLookupByLibrary.simpleMessage(
      "Язык отображения приложения",
    ),
    "g_audit_encrypted_backup": MessageLookupByLibrary.simpleMessage(
      "Экспорт зашифрованной резервной копии кошелька",
    ),
    "g_audit_funding": MessageLookupByLibrary.simpleMessage(
      "Текущая ставка финансирования",
    ),
    "g_audit_gas": MessageLookupByLibrary.simpleMessage("Трекер газа"),
    "g_audit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "Стоимость сетевых комиссий и оповещения о ценах",
    ),
    "g_audit_hardware": MessageLookupByLibrary.simpleMessage(
      "Аппаратный кошелёк",
    ),
    "g_audit_load_more": MessageLookupByLibrary.simpleMessage(
      "Загрузить больше",
    ),
    "g_audit_mainnet": MessageLookupByLibrary.simpleMessage("Основная сеть"),
    "g_audit_manage_settings": MessageLookupByLibrary.simpleMessage(
      "Управление вашим кошельком и настройками",
    ),
    "g_audit_manage_wallets": MessageLookupByLibrary.simpleMessage(
      "Создание, импорт и управление кошельками",
    ),
    "g_audit_mark_price": MessageLookupByLibrary.simpleMessage("Рыночная цена"),
    "g_audit_max_leverage": MessageLookupByLibrary.simpleMessage(
      "Максимальное плечо",
    ),
    "g_audit_network_desc": MessageLookupByLibrary.simpleMessage(
      "Управление сетями и конечными точками RPC",
    ),
    "g_audit_open_interest": MessageLookupByLibrary.simpleMessage(
      "Открытый интерес",
    ),
    "g_audit_oracle_price": MessageLookupByLibrary.simpleMessage(
      "Цена оракула",
    ),
    "g_audit_protect_wallet": MessageLookupByLibrary.simpleMessage(
      "Аутентификация и защита кошелька",
    ),
    "g_audit_quote_changed": MessageLookupByLibrary.simpleMessage(
      "Ценовое предложение для обмена изменилось или истекло. Проверьте последнее предложение по обмену перед подтверждением.",
    ),
    "g_audit_rate": MessageLookupByLibrary.simpleMessage("Оцените N42"),
    "g_audit_rate_desc": MessageLookupByLibrary.simpleMessage(
      "Открыть магазин приложений",
    ),
    "g_audit_saved_addresses": MessageLookupByLibrary.simpleMessage(
      "Сохранённые адреса получателей",
    ),
    "g_audit_show_less": MessageLookupByLibrary.simpleMessage(
      "Показать меньше",
    ),
    "g_audit_testnet": MessageLookupByLibrary.simpleMessage("Тестовая сеть"),
    "g_audit_theme_desc": MessageLookupByLibrary.simpleMessage(
      "Внешний вид и режим отображения",
    ),
    "g_audit_volume": MessageLookupByLibrary.simpleMessage(
      "Объём за 24 часа (USD)",
    ),
    "g_audit_wallet_management": MessageLookupByLibrary.simpleMessage(
      "Управление кошельками",
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
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("Принять"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage("Сообщение удалено"),
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
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage(
      "Проверено",
    ),
    "g_dex_account_unavailable": MessageLookupByLibrary.simpleMessage(
      "Выберите доступный основной кошелёк сети для этой сети. Кошельки только для просмотра не могут подписывать обмены.",
    ),
    "g_dex_execution_invalid": MessageLookupByLibrary.simpleMessage(
      "Параметры транзакции недействительны или выполнение не удалось. Обновите предложение по цене обмена и попробуйте снова.",
    ),
    "g_dex_history_record_failed": MessageLookupByLibrary.simpleMessage(
      "Обмен отправлен, но история не была обновлена. Не отправляйте его повторно.",
    ),
    "g_dex_smart_account_fees": MessageLookupByLibrary.simpleMessage(
      "Стоимость сетевых комиссий оплачивается этим умным кошельком.",
    ),
    "g_dex_spending_account": MessageLookupByLibrary.simpleMessage(
      "Счет для расходов",
    ),
    "g_dex_use_smart_account": MessageLookupByLibrary.simpleMessage(
      "Использовать умный кошелёк",
    ),
    "g_email_resend": MessageLookupByLibrary.simpleMessage(
      "Отправить код повторно",
    ),
    "g_email_resend_countdown": m3,
    "g_face_1": MessageLookupByLibrary.simpleMessage(
      "Подсказки биометрического сканирования",
    ),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Отсканируйте отпечаток пальца или лицо для аутентификации.",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("Подсказки"),
    "g_face_5": MessageLookupByLibrary.simpleMessage("Настроить"),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Отсканируйте лицо или отпечаток пальца для продолжения.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Назад"),
    "g_google_auth_key1": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator",
    ),
    "g_google_auth_key2": MessageLookupByLibrary.simpleMessage(
      "Отсканируйте QR-код приложением Google Authenticator",
    ),
    "g_google_auth_key3": MessageLookupByLibrary.simpleMessage(
      "Или введите ключ вручную:",
    ),
    "g_google_auth_key4": MessageLookupByLibrary.simpleMessage(
      "Введите 6-значный код подтверждения",
    ),
    "g_google_auth_key5": MessageLookupByLibrary.simpleMessage(
      "Для подтверждения перевода требуется Google Authenticator.",
    ),
    "g_google_auth_key6": MessageLookupByLibrary.simpleMessage(
      "Неверный код, повторите попытку",
    ),
    "g_google_auth_key7": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator не настроен",
    ),
    "g_google_auth_key8": MessageLookupByLibrary.simpleMessage(
      "Привязка выполнена успешно",
    ),
    "g_history_clear_dates": MessageLookupByLibrary.simpleMessage(
      "Очистить даты",
    ),
    "g_history_export_all": MessageLookupByLibrary.simpleMessage(
      "Экспорт соответствующих локальных записей (CSV)",
    ),
    "g_history_export_error": MessageLookupByLibrary.simpleMessage(
      "Не удалось экспортировать историю транзакций. Пожалуйста, попробуйте снова.",
    ),
    "g_history_local_scope": MessageLookupByLibrary.simpleMessage(
      "Фильтры и экспорт CSV включают все соответствующие записи, сохранённые на этом устройстве. Откройте актив, чтобы синхронизировать более новые действия в блокчейне.",
    ),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Профиль"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("Новости"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Верификация"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Пригласить друга"),
    "g_home_market": MessageLookupByLibrary.simpleMessage("Рынки"),
    "g_iap_cancelled": MessageLookupByLibrary.simpleMessage("Отменено"),
    "g_iap_check_network": MessageLookupByLibrary.simpleMessage(
      "Проверьте подключение к сети и попробуйте ещё раз",
    ),
    "g_iap_failed": m4,
    "g_iap_no_products": MessageLookupByLibrary.simpleMessage(
      "Нет доступных товаров",
    ),
    "g_iap_purchased": m5,
    "g_iap_restore": MessageLookupByLibrary.simpleMessage(
      "Восстановить покупки",
    ),
    "g_iap_restored": m6,
    "g_iap_restoring": MessageLookupByLibrary.simpleMessage(
      "Восстановление покупок…",
    ),
    "g_iap_retry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "g_iap_store_unavailable": MessageLookupByLibrary.simpleMessage(
      "Магазин недоступен",
    ),
    "g_iap_title": MessageLookupByLibrary.simpleMessage("Купить"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("Не удалось удалить!"),
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
    "g_key_135": m7,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Основной кошелёк"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("Транзакция успешна"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Неверный пароль"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("Тестовая сеть"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Основная сеть"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("Системный язык"),
    "g_key_15": MessageLookupByLibrary.simpleMessage(
      "Установить как основной кошелёк",
    ),
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
    "g_key_213": MessageLookupByLibrary.simpleMessage("Информация о рынке"),
    "g_key_214": m8,
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
    "g_key_46": m9,
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
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage("Скоро"),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "Это контрфактическое обращение. Он будет развернут при вашей первой транзакции.",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "Создать смарт-аккаунт",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "Создайте свой первый смарт-аккаунт",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "Создать сеансовый ключ",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("Создано"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("Пользовательский"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "Учетная запись будет развернута автоматически при вашей первой транзакции.",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("Развернуто"),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage(
      "Развертывание...",
    ),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "Развертывание произойдет автоматически при первой транзакции.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "Испытайте новое поколение учетных записей Ethereum с расширенными функциями.",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("Подробности"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "Гибридная учетная запись EOA/Smart Account — развертывание не требуется",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("Ошибка"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "Расчетный газ",
    ),
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
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("БЕСПЛАТНО"),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "Оценка газа не удалась, используется значение по умолчанию",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage("Оплата газа"),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Варианты оплаты газа",
    ),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "Спонсор газа",
    ),
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("Безгазовый"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "Безгазовые транзакции и пакетные операции",
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
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage(
      "Повторить",
    ),
    "g_key_aa_paymaster_unavailable": MessageLookupByLibrary.simpleMessage(
      "Спонсорство газа ещё недоступно. Пожалуйста, оплатите газ со своего баланса.",
    ),
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("Ожидается"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("Разрешение"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "Предварительный адрес",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("Готово"),
    "g_key_aa_receive_address": MessageLookupByLibrary.simpleMessage(
      "Получить адрес",
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
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "Учетная запись с несколькими подписями и расширенными функциями безопасности",
    ),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("сохранено"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "Выберите цепочку",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Выберите Paymaster",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("Выбрано"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "Отправляйте токены, используя свой смарт-аккаунт",
    ),
    "g_key_aa_send_failed": MessageLookupByLibrary.simpleMessage(
      "Транзакция не удалась",
    ),
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1 день"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1 час"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30 дней"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7 дней"),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "напр. 100.00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "Макс. сумма",
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
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "Базовая смарт-учетная запись с одним владельцем — рекомендуется для большинства пользователей.",
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
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage("Транзакции"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage("Посмотреть все"),
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
    "g_key_airdrop_discover": MessageLookupByLibrary.simpleMessage(
      "Обнаружить",
    ),
    "g_key_airdrop_distribute": MessageLookupByLibrary.simpleMessage(
      "Распределить",
    ),
    "g_key_airdrop_expired": MessageLookupByLibrary.simpleMessage("Завершено"),
    "g_key_airdrop_no_airdrops": MessageLookupByLibrary.simpleMessage(
      "Нет доступных подтвержденных кампаний",
    ),
    "g_key_airdrop_pending": MessageLookupByLibrary.simpleMessage("В ожидании"),
    "g_key_airdrop_sources": MessageLookupByLibrary.simpleMessage("Источники"),
    "g_key_airdrop_sources_hint": MessageLookupByLibrary.simpleMessage(
      "Откройте «Источники», чтобы просмотреть каталоги кампаний, поддерживаемые провайдерами.",
    ),
    "g_key_airdrop_thirdparty_warning": MessageLookupByLibrary.simpleMessage(
      "Кампании сторонних провайдеров могут быть вредоносными. Убедитесь в подлинности домена проекта и деталей транзакции перед подписанием.",
    ),
    "g_key_airdrop_title": MessageLookupByLibrary.simpleMessage(
      "Раздача токенов",
    ),
    "g_key_airdrop_upcoming": MessageLookupByLibrary.simpleMessage("Скоро"),
    "g_key_badge_hot": MessageLookupByLibrary.simpleMessage("ГОРЯЧИЙ"),
    "g_key_badge_live": MessageLookupByLibrary.simpleMessage("В ЭФИРЕ"),
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
    "g_key_batch_duplicate_address": m10,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Оценка газа...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "Пакетная передача поддерживает только цепочки EVM.",
    ),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage(
      "Экспорт CSV",
    ),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "Справка по пакетному переносу",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "Импорт CSV",
    ),
    "g_key_batch_insufficient_balance": m11,
    "g_key_batch_invalid_address": m12,
    "g_key_batch_invalid_amount": m13,
    "g_key_batch_max_recipients": m14,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "Памятка не является обязательной",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Используйте Multicall3 для снижения платы за газ",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "Нет поддерживаемых токенов",
    ),
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
    "g_key_block_explorer_optional": MessageLookupByLibrary.simpleMessage(
      "URL проводника блоков (необязательно)",
    ),
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
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("Мост"),
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
    "g_key_chain_presets": MessageLookupByLibrary.simpleMessage(
      "Популярные сети (нажмите, чтобы заполнить)",
    ),
    "g_key_chain_transfer_not_supported": MessageLookupByLibrary.simpleMessage(
      "Эта цепочка пока не поддерживает переводы, следите за обновлениями",
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
    "g_key_dapp_connect_account": MessageLookupByLibrary.simpleMessage("Счёт"),
    "g_key_dapp_connect_desc": MessageLookupByLibrary.simpleMessage(
      "Этот сайт запрашивает доступ к вашему адресу кошелька и предлагает транзакции. Он не может переместить средства без вашего согласия.",
    ),
    "g_key_dapp_connect_title": MessageLookupByLibrary.simpleMessage(
      "Подключить кошелёк",
    ),
    "g_key_device_security_warning_message": MessageLookupByLibrary.simpleMessage(
      "Похоже, на этом устройстве получены root-права или выполнен джейлбрейк. Использование кошелька на устройстве с нарушенной защитой повышает риск кражи ключей и несанкционированного доступа. Будьте осторожны.",
    ),
    "g_key_device_security_warning_title": MessageLookupByLibrary.simpleMessage(
      "Предупреждение о безопасности устройства",
    ),
    "g_key_dex_approval_success": MessageLookupByLibrary.simpleMessage(
      "Одобрено! Нажмите «Обменять», чтобы продолжить.",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage(
      "Точная сумма",
    ),
    "g_key_dex_approve_required": m15,
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
    "g_key_dex_price_impact_high": m16,
    "g_key_dex_quote_expires": m17,
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Ошибка котировки",
    ),
    "g_key_dex_quote_unavailable": MessageLookupByLibrary.simpleMessage(
      "Сервис предложения цены обмена временно недоступен. Пожалуйста, попробуйте позже.",
    ),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "Поиск по символу / имени / адресу",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage("Выбрать"),
    "g_key_dex_slippage_label": MessageLookupByLibrary.simpleMessage(
      "Макс. проскальзывание",
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
    "g_key_dex_tokens_offline": MessageLookupByLibrary.simpleMessage(
      "Сервис токенов недоступен. Отображается ограниченный список в автономном режиме.",
    ),
    "g_key_dex_untrusted_router": MessageLookupByLibrary.simpleMessage(
      "Обмен заблокирован: адрес маршрутизатора не распознан. Для вашей безопасности эта транзакция отменена.",
    ),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("Вы Платите"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage(
      "Вы Получаете",
    ),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "Активные продукты",
    ),
    "g_key_earn_batch": MessageLookupByLibrary.simpleMessage(
      "Пакетный перевод",
    ),
    "g_key_earn_best_apy": MessageLookupByLibrary.simpleMessage(
      "Лучший годовой доход",
    ),
    "g_key_earn_burn": MessageLookupByLibrary.simpleMessage("Сжечь"),
    "g_key_earn_buy_n": MessageLookupByLibrary.simpleMessage("Купить N"),
    "g_key_earn_buy_n_desc": MessageLookupByLibrary.simpleMessage(
      "Купить N с помощью протокола N42",
    ),
    "g_key_earn_claim_free": MessageLookupByLibrary.simpleMessage(
      "Найти проверенные кампании сторонних провайдеров",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "Межсетевой перевод",
    ),
    "g_key_earn_daily_bonus": MessageLookupByLibrary.simpleMessage(
      "Ежедневные баллы в блокчейне",
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
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "Зарабатывайте вознаграждения, участвуя в майнинге узлов",
    ),
    "g_key_earn_perps": MessageLookupByLibrary.simpleMessage(
      "Перпетуальные контракты",
    ),
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage(
      "Быстрые инструменты",
    ),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage(
      "Рекомендуется",
    ),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage(
      "Выбрать тип обмена",
    ),
    "g_key_earn_stablecoin_deposit": MessageLookupByLibrary.simpleMessage(
      "Внести",
    ),
    "g_key_earn_stablecoin_desc": MessageLookupByLibrary.simpleMessage(
      "Получайте ежедневный доход на USDC / USDT / DAI",
    ),
    "g_key_earn_stablecoin_empty": MessageLookupByLibrary.simpleMessage(
      "В данный момент доступных рынков стейблкоинов нет",
    ),
    "g_key_earn_stablecoin_title": MessageLookupByLibrary.simpleMessage(
      "Доход с стейблкоинов",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Ставьте ETH с помощью Lido",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("Обменять"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("Заработать"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage(
      "Общий доход",
    ),
    "g_key_earn_up_to_apy": m18,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage(
      "Посмотреть все",
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
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage(
      "Срок действия истек",
    ),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage(
      "Срок действия истекает",
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
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage(
      "Регистрация...",
    ),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage(
      "Регистрационная информация",
    ),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "Период регистрации",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage(
      "Включить напоминание об истечении срока",
    ),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "Уведомить за 30, 7 и 1 день до истечения срока",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("Продлить"),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "Продлите регистрацию домена",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "Продление прошло успешно",
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
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage(
      "Предложения",
    ),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage(
      "Текстовые записи",
    ),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("Менеджер ЭНС"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("Итого"),
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
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("Ожидание..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "Прежде чем продолжить, проверьте разрешенный адрес. Имена ENS могут передаваться или изменяться их владельцем.",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("год"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("годы"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "Ваша личность",
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
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("Ошибка запроса"),
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
    "g_key_filter": MessageLookupByLibrary.simpleMessage("Фильтр"),
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
    "g_key_gas_auto_refresh": m19,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage(
      "Базовая комиссия",
    ),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage(
      "Пользовательский",
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
    "g_key_hw_account_added": m20,
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "Аккаунт уже импортирован",
    ),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("Добавить"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage(
      "Добавить аккаунт",
    ),
    "g_key_hw_add_account_content": m21,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Адрес скопирован",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Перед подключением убедитесь, что ваше устройство разблокировано и Bluetooth включен.",
    ),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage(
      "Проверить приложение",
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
    "g_key_hw_current_app_label": m22,
    "g_key_hw_days_ago": m23,
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Отключить"),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("Назад"),
    "g_key_hw_import_failed": m24,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "Подключить Кистоун",
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
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Нажмите, чтобы отсканировать ответ Keystone",
    ),
    "g_key_hw_last_connected": m25,
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
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Устройство не подключено",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Не подключен",
    ),
    "g_key_hw_open_ledger_app_hint": m26,
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("Удалить"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "Удалить устройство",
    ),
    "g_key_hw_remove_device_confirm": m27,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "Сохраненные устройства",
    ),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage(
      "Поддерживаемые устройства",
    ),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("Сегодня"),
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
    "g_key_login": MessageLookupByLibrary.simpleMessage("Войти"),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Выйти"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите выйти из приложения?",
    ),
    "g_key_loyalty_available_points": MessageLookupByLibrary.simpleMessage(
      "Доступные очки",
    ),
    "g_key_loyalty_checked_today": MessageLookupByLibrary.simpleMessage(
      "Уже зарегистрированы сегодня",
    ),
    "g_key_loyalty_checkin_btn": MessageLookupByLibrary.simpleMessage(
      "Зарегистрироваться",
    ),
    "g_key_loyalty_checkin_done": MessageLookupByLibrary.simpleMessage(
      "Готово",
    ),
    "g_key_loyalty_checkin_failed": MessageLookupByLibrary.simpleMessage(
      "Регистрация не удалась",
    ),
    "g_key_loyalty_checkin_success": MessageLookupByLibrary.simpleMessage(
      "Регистрация подтверждена на N42",
    ),
    "g_key_loyalty_copy": MessageLookupByLibrary.simpleMessage("Копировать"),
    "g_key_loyalty_daily_checkin": MessageLookupByLibrary.simpleMessage(
      "Ежедневная регистрация",
    ),
    "g_key_loyalty_earn_points": m28,
    "g_key_loyalty_empty_leaderboard": MessageLookupByLibrary.simpleMessage(
      "Рейтинг пуст",
    ),
    "g_key_loyalty_history": MessageLookupByLibrary.simpleMessage("История"),
    "g_key_loyalty_invite_description": MessageLookupByLibrary.simpleMessage(
      "Поделитесь своим реферальным кодом",
    ),
    "g_key_loyalty_invite_friends": MessageLookupByLibrary.simpleMessage(
      "Пригласить друзей",
    ),
    "g_key_loyalty_leaderboard": MessageLookupByLibrary.simpleMessage(
      "Таблица лидеров",
    ),
    "g_key_loyalty_no_history": MessageLookupByLibrary.simpleMessage(
      "Нет истории очков",
    ),
    "g_key_loyalty_no_referrals": MessageLookupByLibrary.simpleMessage(
      "Пока нет рефералов. Поделитесь своим кодом, чтобы начать",
    ),
    "g_key_loyalty_no_rewards": MessageLookupByLibrary.simpleMessage(
      "Нет доступных наград",
    ),
    "g_key_loyalty_no_tasks": MessageLookupByLibrary.simpleMessage(
      "Нет доступных заданий",
    ),
    "g_key_loyalty_no_wallet": MessageLookupByLibrary.simpleMessage(
      "Активный кошелёк отсутствует",
    ),
    "g_key_loyalty_referral": MessageLookupByLibrary.simpleMessage("Рефералы"),
    "g_key_loyalty_rewards": MessageLookupByLibrary.simpleMessage("Награды"),
    "g_key_loyalty_tasks": MessageLookupByLibrary.simpleMessage("Задания"),
    "g_key_loyalty_title": MessageLookupByLibrary.simpleMessage("Очки"),
    "g_key_loyalty_total_earned": MessageLookupByLibrary.simpleMessage(
      "Всего начислено",
    ),
    "g_key_loyalty_unavailable": MessageLookupByLibrary.simpleMessage(
      "Сервис недоступен",
    ),
    "g_key_loyalty_used": MessageLookupByLibrary.simpleMessage("Использовано"),
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
    "g_key_msgsign_btn": MessageLookupByLibrary.simpleMessage("Подписать"),
    "g_key_msgsign_empty": MessageLookupByLibrary.simpleMessage(
      "Сначала введите сообщение",
    ),
    "g_key_msgsign_failed": MessageLookupByLibrary.simpleMessage(
      "Ошибка подписи",
    ),
    "g_key_msgsign_input_hint": MessageLookupByLibrary.simpleMessage(
      "Введите сообщение для подписи",
    ),
    "g_key_msgsign_result": MessageLookupByLibrary.simpleMessage("Подпись"),
    "g_key_msgsign_title": MessageLookupByLibrary.simpleMessage(
      "Подписать сообщение",
    ),
    "g_key_msgsign_unsupported": MessageLookupByLibrary.simpleMessage(
      "Подпись сообщений пока не поддерживается для этой цепочки",
    ),
    "g_key_msgsign_warning": MessageLookupByLibrary.simpleMessage(
      "Подписывайте только те сообщения, которым полностью доверяете. Злонамеренное сообщение может быть использовано для авторизации действий от вашего имени.",
    ),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Всего"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Название"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Назад"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage(
      "Транзакция отправлена",
    ),
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage(
      "Неверный адрес кошелька",
    ),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("Баланс"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "Это действие необратимо. NFT будет отправлен на адрес записи.",
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
    "g_key_nft_hide_spam": MessageLookupByLibrary.simpleMessage("Скрыть спам"),
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
    "g_key_nft_uncategorized": MessageLookupByLibrary.simpleMessage("Другие"),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "Пароли не совпадают",
    ),
    "g_key_perps_read_only": MessageLookupByLibrary.simpleMessage(
      "Данные рынка только для чтения. В этом выпуске размещение ордеров не поддерживается.",
    ),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Выбрать из галереи телефона",
    ),
    "g_key_pubkey": MessageLookupByLibrary.simpleMessage("Публичный ключ"),
    "g_key_receive_payment_request": MessageLookupByLibrary.simpleMessage(
      "Запрос платежа",
    ),
    "g_key_receive_request_line": m29,
    "g_key_remove_network": MessageLookupByLibrary.simpleMessage(
      "Удалить сеть",
    ),
    "g_key_remove_network_confirm": m30,
    "g_key_reset": MessageLookupByLibrary.simpleMessage("Сброс"),
    "g_key_retry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "g_key_scan_pay_unsupported": MessageLookupByLibrary.simpleMessage(
      "Токен или цепочка запроса платежа не входят в этот кошелёк",
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
    "g_key_send_memo_hint": MessageLookupByLibrary.simpleMessage(
      "Памятка/Примечание",
    ),
    "g_key_send_memo_label": MessageLookupByLibrary.simpleMessage(
      "Памятка/заметка (необязательно)",
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
    "g_key_sim_gas_estimate": m31,
    "g_key_sim_reverted": MessageLookupByLibrary.simpleMessage(
      "Транзакция, скорее всего, не удастся",
    ),
    "g_key_sim_reverted_reason": m32,
    "g_key_sim_simulating": MessageLookupByLibrary.simpleMessage(
      "Имитация транзакции…",
    ),
    "g_key_sim_success": MessageLookupByLibrary.simpleMessage(
      "Моделирование транзакции пройдено",
    ),
    "g_key_sim_unavailable": MessageLookupByLibrary.simpleMessage(
      "Моделирование недоступно для этой сети.",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Чат"),
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
    "g_key_stake_broadcast_unsupported": MessageLookupByLibrary.simpleMessage(
      "Транзакция создана, но отправка транзакции из кошелька для этой цепочки ещё не поддерживается.",
    ),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage("Комиссия"),
    "g_key_stake_d_unbond": m33,
    "g_key_stake_days_remaining": m34,
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "Оценка. Ежедневная награда",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "Оценка. Ежегодная награда",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage(
      "Перейти к обмену",
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
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "Мои позиции",
    ),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Протоколы"),
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
    "g_key_stake_submitted": MessageLookupByLibrary.simpleMessage(
      "Транзакция стейкинга отправлена",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("Стейкинг"),
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage(
      "Транзакция успешно подготовлена",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage(
      "Разблокировка",
    ),
    "g_key_stake_unbonding_warning": m35,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage("Снять стейк"),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage(
      "Обновление...",
    ),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Валидатор"),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage(
      "Вы получите",
    ),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Завершено"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Цена газа"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Макс. комиссия за газ"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage(
      "Макс. плата за единицу газа",
    ),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("В ожидании"),
    "g_key_t_29": m36,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("Неудача"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Продолжить"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("Пароль кошелька"),
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
    "g_key_t_45": m37,
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
    "g_key_t_52": m38,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "У адреса получателя нет аккаунта, и первый перевод должен быть минимум 10XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Использовано газа"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Газ"),
    "g_key_token_discovery_add": MessageLookupByLibrary.simpleMessage(
      "Добавить",
    ),
    "g_key_token_discovery_add_selected": m39,
    "g_key_token_discovery_added": MessageLookupByLibrary.simpleMessage(
      "Токен добавлен",
    ),
    "g_key_token_discovery_banner": m40,
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
    "g_key_uuid": MessageLookupByLibrary.simpleMessage("UUID"),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage(
      "Найдена последняя версия",
    ),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("Обновить сейчас"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage("Найдена новая версия"),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage(
      "У вас последняя версия",
    ),
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage(
      "Просмотр сид-фразы",
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
    "g_key_wallet_m1": m41,
    "g_key_wallet_m19": m42,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "Текущий токен не был добавлен.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Введите сид-фразу, разделяя слова пробелами",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage("Импорт кошелька"),
    "g_key_wallet_m3": m43,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "Недостаточный баланс текущего токена.",
    ),
    "g_key_wallet_m5": m44,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("Ошибка подписи"),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Управление кошельком",
    ),
    "g_key_wallet_tx_replace_hint": MessageLookupByLibrary.simpleMessage(
      "Будет отправлена заменяющая транзакция с тем же nonce и комиссией за газ примерно на 20% выше. Она действует только пока исходная транзакция ожидает подтверждения.",
    ),
    "g_key_wallet_tx_replace_submitted": MessageLookupByLibrary.simpleMessage(
      "Отправлена транзакция замены",
    ),
    "g_key_wallet_tx_speedup": MessageLookupByLibrary.simpleMessage("Ускорить"),
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "Введите адрес Эфириума (0x...)",
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
    "g_key_xml_11": m45,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("Инкрементный резерв"),
    "g_key_xml_22": m46,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Количество принадлежащих объектов",
    ),
    "g_key_xml_33": m47,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "Как рассчитать общую сумму резерва",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "Общий резерв = Базовый резерв + (Количество объектов × Инкрементный резерв)",
    ),
    "g_live_ended": MessageLookupByLibrary.simpleMessage(
      "Прямой эфир завершён",
    ),
    "g_live_enter_room_failed": m48,
    "g_live_follow": MessageLookupByLibrary.simpleMessage("Подписаться"),
    "g_live_follow_wip": MessageLookupByLibrary.simpleMessage(
      "Функция подписки скоро",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID и Face ID"),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("Графический пароль"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage(
      "Установить графический пароль",
    ),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "Нарисуйте графический ключ",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "Подтвердите графический ключ",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage(
      "Нарисуйте текущий графический ключ",
    ),
    "g_lock_key21": m49,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Сбросить графический пароль",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Слишком много неверных попыток, повторите",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Добавить пароль кошелька?",
    ),
    "g_lock_key25": m50,
    "g_lock_key26": MessageLookupByLibrary.simpleMessage("Проверка перевода"),
    "g_lock_key27": MessageLookupByLibrary.simpleMessage(
      "Требуется биометрическая аутентификация (Face ID / отпечаток пальца) для подтверждения каждой транзакции в кошельке.",
    ),
    "g_lock_key28": MessageLookupByLibrary.simpleMessage(
      "Графический пароль не установлен",
    ),
    "g_lock_key29": MessageLookupByLibrary.simpleMessage(
      "Для подтверждения перевода требуется графический ключ.",
    ),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Успешно"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Неудача"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "Биометрическое распознавание не включено",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "Добавить биометрическую верификацию?",
    ),
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
    "g_mining_key63": m51,
    "g_mining_key73": m52,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Я только что настроил ноду в @N42Wallet и начал верификацию на мобильных устройствах! Присоединяйтесь. Децентрализованное будущее — это мобильность!",
    ),
    "g_mining_key76": m53,
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
    "g_mining_key_109": m54,
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
    "g_mining_key_116": m55,
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
    "g_mining_key_71": m56,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "128 секунд на проверку",
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
    "g_mining_key_98": m57,
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
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage(
      "Основа стоимости",
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
    "g_pred_add_outcome": MessageLookupByLibrary.simpleMessage(
      "Добавить исход",
    ),
    "g_pred_amount_input": m58,
    "g_pred_balance": m59,
    "g_pred_buy": MessageLookupByLibrary.simpleMessage("Купить"),
    "g_pred_cancel_refund": MessageLookupByLibrary.simpleMessage(
      "Отменить и вернуть",
    ),
    "g_pred_close_only": MessageLookupByLibrary.simpleMessage("Только закрыть"),
    "g_pred_closed_waiting": MessageLookupByLibrary.simpleMessage(
      "Закрыто, ожидание расчёта",
    ),
    "g_pred_confirm_resolve": MessageLookupByLibrary.simpleMessage(
      "Подтвердить расчёт",
    ),
    "g_pred_confirm_resolve_msg": m60,
    "g_pred_create_title": MessageLookupByLibrary.simpleMessage(
      "Начать прогноз",
    ),
    "g_pred_creating": MessageLookupByLibrary.simpleMessage("Создание…"),
    "g_pred_deadline": MessageLookupByLibrary.simpleMessage("Срок"),
    "g_pred_err_amount_low": MessageLookupByLibrary.simpleMessage(
      "Сумма должна быть больше 0",
    ),
    "g_pred_err_insufficient_balance": MessageLookupByLibrary.simpleMessage(
      "Недостаточно средств",
    ),
    "g_pred_err_insufficient_shares": MessageLookupByLibrary.simpleMessage(
      "Недостаточно долей",
    ),
    "g_pred_err_invalid_outcome": MessageLookupByLibrary.simpleMessage(
      "Недопустимый исход",
    ),
    "g_pred_err_invalid_state": MessageLookupByLibrary.simpleMessage(
      "Рынок уже закрыт, действие недопустимо",
    ),
    "g_pred_err_market_closed": MessageLookupByLibrary.simpleMessage(
      "Рынок закрыт, торговля недоступна",
    ),
    "g_pred_err_market_not_found": MessageLookupByLibrary.simpleMessage(
      "Рынок не найден",
    ),
    "g_pred_err_not_resolved": MessageLookupByLibrary.simpleMessage(
      "Рынок не рассчитан, погашение невозможно",
    ),
    "g_pred_err_not_resolver": MessageLookupByLibrary.simpleMessage(
      "Только создатель этого рынка может выполнить это действие",
    ),
    "g_pred_err_outcomes": MessageLookupByLibrary.simpleMessage(
      "Минимум два допустимых исхода",
    ),
    "g_pred_err_question": MessageLookupByLibrary.simpleMessage(
      "Введите вопрос",
    ),
    "g_pred_err_slippage": MessageLookupByLibrary.simpleMessage(
      "Превышено проскальзывание, повторите",
    ),
    "g_pred_minutes": m61,
    "g_pred_no": MessageLookupByLibrary.simpleMessage("Нет"),
    "g_pred_outcome_n": m62,
    "g_pred_outcome_win": m63,
    "g_pred_outcomes": MessageLookupByLibrary.simpleMessage("Исходы"),
    "g_pred_pick_winner": MessageLookupByLibrary.simpleMessage(
      "Выберите победный исход для расчёта (выплата по результату)",
    ),
    "g_pred_processing": MessageLookupByLibrary.simpleMessage("Обработка…"),
    "g_pred_publish": MessageLookupByLibrary.simpleMessage("Опубликовать"),
    "g_pred_q_hint": MessageLookupByLibrary.simpleMessage(
      "Вопрос прогноза, напр.: Кто победит в этом раунде?",
    ),
    "g_pred_quote_info": m64,
    "g_pred_redeem_failed": m65,
    "g_pred_resolved": MessageLookupByLibrary.simpleMessage("Рассчитано"),
    "g_pred_result_label": m66,
    "g_pred_sell_n": m67,
    "g_pred_unlimited": MessageLookupByLibrary.simpleMessage(
      "Без лимита (закрыть вручную)",
    ),
    "g_pred_yes": MessageLookupByLibrary.simpleMessage("Да"),
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage("Загружено"),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage(
      "Код приглашения",
    ),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("Приглашено"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage(
      "Майнинговые узлы",
    ),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("Награда (N)"),
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
    "g_swap_key_14": m68,
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
    "g_swap_key_20": m69,
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
    "g_swap_key_31": m70,
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
    "g_theme_mode": MessageLookupByLibrary.simpleMessage("Внешний вид"),
    "g_theme_style": MessageLookupByLibrary.simpleMessage("Стиль"),
    "g_theme_style_custom": MessageLookupByLibrary.simpleMessage(
      "Пользовательский",
    ),
    "g_token_m_key_1": m71,
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
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Добавить пользовательскую сеть",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 ед."),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("Добавить токены"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage("Ошибка формата!"),
    "g_token_m_key_22": m72,
    "g_token_m_key_23": m73,
    "g_token_m_key_24": m74,
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
    "g_token_m_key_chainid_conflict": MessageLookupByLibrary.simpleMessage(
      "Этот идентификатор цепочки уже используется другой сетью.",
    ),
    "g_token_m_key_chainid_mismatch": m75,
    "g_tx_risk_caution": MessageLookupByLibrary.simpleMessage("Осторожно"),
    "g_tx_risk_danger": MessageLookupByLibrary.simpleMessage("Высокий риск"),
    "g_tx_risk_safe": MessageLookupByLibrary.simpleMessage("Безопасно"),
    "g_ui_aave_lending": MessageLookupByLibrary.simpleMessage("Займы Aave V3"),
    "g_ui_account_email": MessageLookupByLibrary.simpleMessage(
      "Электронная почта учётной записи",
    ),
    "g_ui_algo_asset_add_fee": MessageLookupByLibrary.simpleMessage(
      "Добавление этого актива требует сетевой комиссии. Нажмите «Добавить», чтобы продолжить.",
    ),
    "g_ui_algo_asset_missing": m76,
    "g_ui_assistant_hint": MessageLookupByLibrary.simpleMessage(
      "Спросите о балансе, портфеле, газе",
    ),
    "g_ui_back_code": MessageLookupByLibrary.simpleMessage("Назад к коду"),
    "g_ui_back_email": MessageLookupByLibrary.simpleMessage(
      "Назад к электронной почте",
    ),
    "g_ui_backup_create_save": MessageLookupByLibrary.simpleMessage(
      "Создать и сохранить резервную копию",
    ),
    "g_ui_backup_empty": MessageLookupByLibrary.simpleMessage(
      "В файле резервной копии не найдено кошельков",
    ),
    "g_ui_backup_encryption_hint": MessageLookupByLibrary.simpleMessage(
      "Ваша резервная копия зашифрована с помощью AES-256 + PBKDF2. Только правильный пароль может её восстановить.",
    ),
    "g_ui_backup_enter_password": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите пароль резервной копии",
    ),
    "g_ui_backup_export": MessageLookupByLibrary.simpleMessage(
      "Экспорт резервной копии в облако",
    ),
    "g_ui_backup_export_failed": MessageLookupByLibrary.simpleMessage(
      "Не удалось создать резервную копию. Пожалуйста, попробуйте снова.",
    ),
    "g_ui_backup_file": MessageLookupByLibrary.simpleMessage(
      "Файл резервной копии",
    ),
    "g_ui_backup_file_access": MessageLookupByLibrary.simpleMessage(
      "Невозможно получить доступ к выбранному файлу",
    ),
    "g_ui_backup_import": MessageLookupByLibrary.simpleMessage(
      "Импортировать облачную резервную копию",
    ),
    "g_ui_backup_import_failed": MessageLookupByLibrary.simpleMessage(
      "Не удалось восстановить резервную копию. Проверьте пароль и файл резервной копии, затем попробуйте снова.",
    ),
    "g_ui_backup_import_result": m77,
    "g_ui_backup_import_wallets": MessageLookupByLibrary.simpleMessage(
      "Импортировать кошельки",
    ),
    "g_ui_backup_invalid_file": MessageLookupByLibrary.simpleMessage(
      "Не является допустимым файлом резервной копии N42Wallet",
    ),
    "g_ui_backup_no_file": MessageLookupByLibrary.simpleMessage(
      "Файл не выбран",
    ),
    "g_ui_backup_no_selection": MessageLookupByLibrary.simpleMessage(
      "Нет выбранных кошельков для резервного копирования",
    ),
    "g_ui_backup_password": MessageLookupByLibrary.simpleMessage(
      "Пароль резервного копирования",
    ),
    "g_ui_backup_password_hint": MessageLookupByLibrary.simpleMessage(
      "Установите надёжный пароль резервной копии (минимум 8 символов)",
    ),
    "g_ui_backup_password_min": MessageLookupByLibrary.simpleMessage(
      "Пароль должен содержать не менее 8 символов",
    ),
    "g_ui_backup_password_repeat": MessageLookupByLibrary.simpleMessage(
      "Повторите пароль резервной копии",
    ),
    "g_ui_backup_restore_hint": MessageLookupByLibrary.simpleMessage(
      "Восстановите свои кошельки из зашифрованного резервного копии, хранящейся в iCloud Drive или Google Drive.",
    ),
    "g_ui_backup_restore_none": MessageLookupByLibrary.simpleMessage(
      "Невозможно восстановить кошельки из этой резервной копии",
    ),
    "g_ui_backup_restore_password_hint": MessageLookupByLibrary.simpleMessage(
      "Введите пароль, использованный при создании резервной копии",
    ),
    "g_ui_backup_select_file_first": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, сначала выберите файл резервной копии",
    ),
    "g_ui_backup_select_wallet": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, выберите хотя бы один кошелёк для резервного копирования",
    ),
    "g_ui_backup_select_wallets": MessageLookupByLibrary.simpleMessage(
      "Выберите кошельки для резервного копирования",
    ),
    "g_ui_backup_share_subject": MessageLookupByLibrary.simpleMessage(
      "Резервная копия N42Wallet",
    ),
    "g_ui_backup_warning": MessageLookupByLibrary.simpleMessage(
      "Эта резервная копия содержит ваши закрытые ключи / мнемонические фразы, пароли кошелька и настройки кошелька. Храните файл резервной копии и пароль в безопасности. Никогда не сообщайте их никому.",
    ),
    "g_ui_balance_value": m78,
    "g_ui_base_fee_value": m79,
    "g_ui_buy_n_description": MessageLookupByLibrary.simpleMessage(
      "Покупка N через протокол N42",
    ),
    "g_ui_calldata_hex": MessageLookupByLibrary.simpleMessage(
      "Данные вызова (hex)",
    ),
    "g_ui_camera_permission": MessageLookupByLibrary.simpleMessage(
      "Для сканирования кода требуется разрешение на камеру.",
    ),
    "g_ui_cancel_order": MessageLookupByLibrary.simpleMessage("Отменить ордер"),
    "g_ui_change_email": MessageLookupByLibrary.simpleMessage(
      "Изменить электронную почту",
    ),
    "g_ui_checking_approval": MessageLookupByLibrary.simpleMessage(
      "Проверка разрешения…",
    ),
    "g_ui_clipboard_clear": m80,
    "g_ui_clipboard_empty": MessageLookupByLibrary.simpleMessage(
      "Буфер обмена пуст",
    ),
    "g_ui_coins_load_failed": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить монеты. Попробуйте снова.",
    ),
    "g_ui_confirm_password": MessageLookupByLibrary.simpleMessage(
      "Подтвердите пароль",
    ),
    "g_ui_confirm_update": MessageLookupByLibrary.simpleMessage(
      "Подтвердить обновление",
    ),
    "g_ui_contract_info": MessageLookupByLibrary.simpleMessage(
      "Информация о контракте",
    ),
    "g_ui_create_wallet": MessageLookupByLibrary.simpleMessage(
      "Создать кошелёк",
    ),
    "g_ui_csv_header_only": MessageLookupByLibrary.simpleMessage(
      "Строки данных не найдены (обнаружен только заголовок).",
    ),
    "g_ui_csv_missing_fields": m81,
    "g_ui_csv_no_data": MessageLookupByLibrary.simpleMessage(
      "Данные не найдены после удаления комментариев.",
    ),
    "g_ui_custom_tag": MessageLookupByLibrary.simpleMessage("Создать метку..."),
    "g_ui_days": m82,
    "g_ui_destination_tag": MessageLookupByLibrary.simpleMessage(
      "Тег назначения",
    ),
    "g_ui_device_connected": m83,
    "g_ui_dex_description": MessageLookupByLibrary.simpleMessage(
      "Обмен токенов через Uniswap / 1inch / Jupiter",
    ),
    "g_ui_email_code_accepted": MessageLookupByLibrary.simpleMessage(
      "Код подтверждения принят",
    ),
    "g_ui_email_code_sent": MessageLookupByLibrary.simpleMessage(
      "Запрос кода подтверждения отправлен",
    ),
    "g_ui_ens_price_failed": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить цены продления ENS. Пожалуйста, попробуйте снова.",
    ),
    "g_ui_ens_renew_failed": MessageLookupByLibrary.simpleMessage(
      "Продление ENS не удалось. Пожалуйста, попробуйте снова.",
    ),
    "g_ui_entry_price": MessageLookupByLibrary.simpleMessage("Цена входа"),
    "g_ui_expires_in": MessageLookupByLibrary.simpleMessage("Истекает через:"),
    "g_ui_fear_greed": MessageLookupByLibrary.simpleMessage("Страх и жадность"),
    "g_ui_file_picker_failed": MessageLookupByLibrary.simpleMessage(
      "Невозможно открыть выбор файла. Пожалуйста, попробуйте снова.",
    ),
    "g_ui_file_read_failed": MessageLookupByLibrary.simpleMessage(
      "Невозможно прочитать выбранный файл. Пожалуйста, попробуйте снова.",
    ),
    "g_ui_free_margin": MessageLookupByLibrary.simpleMessage("Свободный"),
    "g_ui_gas_prediction": MessageLookupByLibrary.simpleMessage(
      "Прогноз стоимости газа в следующем блоке",
    ),
    "g_ui_gas_value": m84,
    "g_ui_hours": m85,
    "g_ui_import_valid": m86,
    "g_ui_invalid_email": MessageLookupByLibrary.simpleMessage(
      "Введите корректный адрес электронной почты",
    ),
    "g_ui_issues_label": MessageLookupByLibrary.simpleMessage("Проблемы:"),
    "g_ui_keystone_paired": MessageLookupByLibrary.simpleMessage(
      "Keystone успешно подключен",
    ),
    "g_ui_limit_orders": MessageLookupByLibrary.simpleMessage("Ордера лимита"),
    "g_ui_limit_price": MessageLookupByLibrary.simpleMessage("Цена лимита"),
    "g_ui_limit_price_pair": m87,
    "g_ui_limit_value": m88,
    "g_ui_liquidation_price": MessageLookupByLibrary.simpleMessage(
      "Цена ликвидации",
    ),
    "g_ui_margin_utilization": MessageLookupByLibrary.simpleMessage(
      "Использование",
    ),
    "g_ui_markets_count": m89,
    "g_ui_memo": MessageLookupByLibrary.simpleMessage("Примечание"),
    "g_ui_mempool": MessageLookupByLibrary.simpleMessage(
      "Очередь транзакций (mempool)",
    ),
    "g_ui_message": MessageLookupByLibrary.simpleMessage("Сообщение"),
    "g_ui_min_balance_value": m90,
    "g_ui_mnemonic_wallet": MessageLookupByLibrary.simpleMessage(
      "Мнемонический кошелёк",
    ),
    "g_ui_mpc_intro": MessageLookupByLibrary.simpleMessage(
      "Войдите в свой аккаунт в социальной сети, чтобы создать безопасный MPC-кошелёк. Ваш закрытый ключ делится на зашифрованные части — не нужно беспокоиться о потере семантической фразы.",
    ),
    "g_ui_mpc_no_phrase": MessageLookupByLibrary.simpleMessage(
      "Семейная фраза не требуется",
    ),
    "g_ui_mpc_security": MessageLookupByLibrary.simpleMessage(
      "Работает на основе MPC-TSS. Ваш ключ делится на 3 зашифрованные части, распределённые между вашим устройством, нашими серверами и резервной копией восстановления.",
    ),
    "g_ui_new_email": MessageLookupByLibrary.simpleMessage(
      "Новый адрес электронной почты",
    ),
    "g_ui_no_cached_email": MessageLookupByLibrary.simpleMessage(
      "На этом устройстве нет сохранённого адреса электронной почты",
    ),
    "g_ui_no_coins": MessageLookupByLibrary.simpleMessage("Ещё нет монет"),
    "g_ui_no_dapps": MessageLookupByLibrary.simpleMessage("Нет DApps"),
    "g_ui_no_limit_orders": MessageLookupByLibrary.simpleMessage(
      "Нет ордеров лимита",
    ),
    "g_ui_no_orders": MessageLookupByLibrary.simpleMessage(
      "Нет открытых заказов",
    ),
    "g_ui_no_positions": MessageLookupByLibrary.simpleMessage(
      "Нет открытых позиций",
    ),
    "g_ui_no_wallet": MessageLookupByLibrary.simpleMessage(
      "Кошелёк ещё не создан",
    ),
    "g_ui_optional": MessageLookupByLibrary.simpleMessage("Необязательно"),
    "g_ui_order_cancel_failed": MessageLookupByLibrary.simpleMessage(
      "Не удалось отменить ордер",
    ),
    "g_ui_order_cancelled": MessageLookupByLibrary.simpleMessage(
      "Ордер отменён",
    ),
    "g_ui_order_create_failed": MessageLookupByLibrary.simpleMessage(
      "Не удалось создать ордер",
    ),
    "g_ui_order_created": MessageLookupByLibrary.simpleMessage(
      "Ордер лимита создан",
    ),
    "g_ui_order_executed": MessageLookupByLibrary.simpleMessage("Выполнен"),
    "g_ui_order_place": MessageLookupByLibrary.simpleMessage(
      "Создать ордер лимита",
    ),
    "g_ui_order_triggered": MessageLookupByLibrary.simpleMessage("Сработано"),
    "g_ui_orders_count": m91,
    "g_ui_orders_load_failed": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить ордера лимита",
    ),
    "g_ui_password_mismatch": MessageLookupByLibrary.simpleMessage(
      "Пароли не совпадают",
    ),
    "g_ui_paste_connection": MessageLookupByLibrary.simpleMessage(
      "Вставить ссылку на подключение",
    ),
    "g_ui_pending_mempool": MessageLookupByLibrary.simpleMessage(
      "Ожидание (mempool)",
    ),
    "g_ui_popular_tokens": MessageLookupByLibrary.simpleMessage(
      "Популярные токены",
    ),
    "g_ui_position_size": MessageLookupByLibrary.simpleMessage("Размер"),
    "g_ui_positions_count": m92,
    "g_ui_private_key_wallet": MessageLookupByLibrary.simpleMessage(
      "Кошелёк с закрытым ключом",
    ),
    "g_ui_read_only": MessageLookupByLibrary.simpleMessage("Только для чтения"),
    "g_ui_recipients_count": m93,
    "g_ui_room_id": MessageLookupByLibrary.simpleMessage("ID комнаты"),
    "g_ui_save_failed": MessageLookupByLibrary.simpleMessage(
      "Сохранение не удалось. Попробуйте снова.",
    ),
    "g_ui_send_code": MessageLookupByLibrary.simpleMessage("Отправить код"),
    "g_ui_sending_request": MessageLookupByLibrary.simpleMessage(
      "Отправка запроса...",
    ),
    "g_ui_swap_mode": MessageLookupByLibrary.simpleMessage(
      "Выберите режим обмена",
    ),
    "g_ui_tags": MessageLookupByLibrary.simpleMessage("Метки"),
    "g_ui_template_copied": MessageLookupByLibrary.simpleMessage(
      "Шаблон скопирован",
    ),
    "g_ui_token_contract_hint": MessageLookupByLibrary.simpleMessage(
      "Адрес контракта токена (0x...)",
    ),
    "g_ui_token_found": m94,
    "g_ui_token_lookup": MessageLookupByLibrary.simpleMessage(
      "Поиск информации о токене…",
    ),
    "g_ui_token_manual": MessageLookupByLibrary.simpleMessage(
      "Токен не найден в списке — введите символ и количество знаков вручную",
    ),
    "g_ui_token_value": m95,
    "g_ui_trade_delete_failed": MessageLookupByLibrary.simpleMessage(
      "Не удалось удалить сделку. Пожалуйста, попробуйте снова.",
    ),
    "g_ui_trade_save_failed": MessageLookupByLibrary.simpleMessage(
      "Не удалось сохранить сделку. Пожалуйста, попробуйте снова.",
    ),
    "g_ui_transaction_hash_value": m96,
    "g_ui_unknown_status": MessageLookupByLibrary.simpleMessage(
      "Неизвестный статус",
    ),
    "g_ui_update": MessageLookupByLibrary.simpleMessage("Обновить"),
    "g_ui_update_email": MessageLookupByLibrary.simpleMessage(
      "Обновить электронную почту",
    ),
    "g_ui_validation_counts": m97,
    "g_ui_validation_issues": MessageLookupByLibrary.simpleMessage(
      "Проблемы проверки",
    ),
    "g_ui_validation_more": m98,
    "g_ui_verification_code": MessageLookupByLibrary.simpleMessage(
      "Код подтверждения",
    ),
    "g_ui_verify_code": MessageLookupByLibrary.simpleMessage("Подтвердить код"),
    "g_ui_view_market": MessageLookupByLibrary.simpleMessage(
      "Просмотр данных рынка",
    ),
    "g_ui_volume_24h": MessageLookupByLibrary.simpleMessage("Объём за 24 часа"),
    "g_ui_volume_interest": m99,
    "g_ui_wallet_ai": MessageLookupByLibrary.simpleMessage("AI кошелёк"),
    "g_ui_wallet_get_started": MessageLookupByLibrary.simpleMessage(
      "Создайте или импортируйте кошелёк, чтобы начать",
    ),
    "g_ui_wallet_load_failed": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить кошелёк",
    ),
    "g_ui_wallet_loading": MessageLookupByLibrary.simpleMessage(
      "Загрузка кошелька...",
    ),
    "g_ui_wallet_number": m100,
    "g_version_later": MessageLookupByLibrary.simpleMessage("Позже"),
    "g_wallet_balance_warning": MessageLookupByLibrary.simpleMessage(
      "Баланс не удалось обновить",
    ),
    "g_wallet_coin_total_value": MessageLookupByLibrary.simpleMessage(
      "Общая стоимость",
    ),
    "g_wallet_coin_unit_price": MessageLookupByLibrary.simpleMessage("Цена"),
    "g_wallet_group_hd": MessageLookupByLibrary.simpleMessage(
      "HD-кошелёк · Мнемоника",
    ),
    "g_wallet_group_single": MessageLookupByLibrary.simpleMessage(
      "Одна сеть · Импорт",
    ),
    "g_wallet_pin_token": MessageLookupByLibrary.simpleMessage(
      "Закрепить токен",
    ),
    "g_wallet_prices_cached": MessageLookupByLibrary.simpleMessage(
      "Сохранённые цены",
    ),
    "g_wallet_prices_hours": m101,
    "g_wallet_prices_just_updated": MessageLookupByLibrary.simpleMessage(
      "Обновлено сейчас",
    ),
    "g_wallet_prices_minutes": m102,
    "g_wallet_prices_partial": MessageLookupByLibrary.simpleMessage(
      "Частичные цены",
    ),
    "g_wallet_prices_unavailable": MessageLookupByLibrary.simpleMessage(
      "Цены недоступны",
    ),
    "g_wallet_receiver_address": MessageLookupByLibrary.simpleMessage(
      "Адрес получателя",
    ),
    "g_wallet_sender_address": MessageLookupByLibrary.simpleMessage(
      "Адрес отправителя",
    ),
    "g_wallet_unpin_token": MessageLookupByLibrary.simpleMessage(
      "Открепить токен",
    ),
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
    "g_xrp_dest_tag_hint": MessageLookupByLibrary.simpleMessage(
      "Обычно требуется при отправке на биржу",
    ),
    "g_xrp_optional": MessageLookupByLibrary.simpleMessage("(Необязательно)"),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Связать",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage(
      "Важное уведомление",
    ),
    "login_email": MessageLookupByLibrary.simpleMessage("Электронная почта"),
    "login_password": MessageLookupByLibrary.simpleMessage("Пароль"),
    "next": MessageLookupByLibrary.simpleMessage("Далее"),
    "nicknameMessage": m103,
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Редактировать профиль",
    ),
    "photograph": MessageLookupByLibrary.simpleMessage("Фотография"),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Введите адрес",
    ),
    "push_bg_delivery_dialog_content": MessageLookupByLibrary.simpleMessage(
      "На этом устройстве ограничена работа приложений в фоновом режиме, поэтому вы можете пропустить сообщения чата и уведомления о переводах, когда приложение находится в фоне или закрыто.\n\nНажмите «Перейти к настройкам», чтобы разрешить фоновую активность, а затем включить автозапуск для этого приложения.",
    ),
    "push_bg_delivery_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Работа в фоновом режиме может быть ограничена",
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
    "s_key_10": MessageLookupByLibrary.simpleMessage("О приложении"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Безопасность"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("Транзакция"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Язык"),
    "search": MessageLookupByLibrary.simpleMessage("Поиск"),
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
